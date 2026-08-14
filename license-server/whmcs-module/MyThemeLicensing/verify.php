<?php
declare(strict_types=1);
/**
 * MyThemeLicensing call-home endpoint (the issuer side).
 *
 * The buyer's theme (MyTheme\Template\License) POSTs:
 *   licensekey, domain, ip, dir, version, template, clientdate, nonce
 *
 * and this returns the RSA-signed JSON it verifies:
 *   { license_status, expires, allowed_domains, features, nonce_echo, signed_at, signature }
 *
 * Point License::$licenseServerUrl at this file's public URL, e.g.
 *   https://billing.hostnodes.com/modules/servers/MyThemeLicensing/verify.php
 */

require __DIR__ . '/lib/Signer.php';
require __DIR__ . '/lib/LicenseStore.php';

use MyThemeLicensing\Signer;
use function MyThemeLicensing\make_store;

header('Content-Type: application/json; charset=utf-8');
header('X-Content-Type-Options: nosniff');

$privateKey = @file_get_contents(__DIR__ . '/keys/private.pem');
if ($privateKey === false || $privateKey === '') {
    http_response_code(500);
    echo json_encode(['error' => 'signing key not configured']);
    exit;
}

$post       = static fn (string $k): string => isset($_POST[$k]) ? trim((string) $_POST[$k]) : '';
$licenseKey = $post('licensekey');
$domain     = $post('domain');
$nonce      = $post('nonce');

try {
    $store = make_store();
    $rec   = $licenseKey !== '' ? $store->find($licenseKey) : null;
} catch (\Throwable $e) {
    // Never leak internals; a 'Unknown' lets the client keep its cached state.
    error_log('MyThemeLicensing verify: ' . $e->getMessage());
    $rec = ['license_status' => 'Unknown', 'expires' => '', 'allowed_domains' => [], 'features' => [], 'max_domains' => 0];
}

if ($rec === null) {
    $payload = ['license_status' => 'Invalid', 'expires' => '', 'allowed_domains' => [], 'features' => []];
} else {
    // Trust-on-first-use domain binding, up to max_domains. After that the set is
    // fixed and the client rejects any domain not in allowed_domains.
    if (
        $domain !== ''
        && !in_array($domain, $rec['allowed_domains'], true)
        && count($rec['allowed_domains']) < (int) ($rec['max_domains'] ?? 0)
    ) {
        try {
            $store->bindDomain($licenseKey, $domain);
            $rec['allowed_domains'][] = $domain;
        } catch (\Throwable $e) {
            error_log('MyThemeLicensing bindDomain: ' . $e->getMessage());
        }
    }

    $payload = [
        'license_status'  => $rec['license_status'],
        'expires'         => $rec['expires'],
        'allowed_domains' => array_values($rec['allowed_domains']),
        'features'        => array_values($rec['features']),
    ];
}

// Echo the nonce (anti-replay) and stamp the time (client tolerates <= 24h skew),
// then sign everything. The signature must be the LAST key added — it covers the
// payload WITHOUT itself.
$payload['nonce_echo'] = $nonce;
$payload['signed_at']  = gmdate('Y-m-d\TH:i:s\Z');
$payload['signature']  = Signer::sign($payload, $privateKey);

echo json_encode($payload, JSON_UNESCAPED_SLASHES);
