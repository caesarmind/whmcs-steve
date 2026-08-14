<?php
declare(strict_types=1);
/**
 * Gold-standard proof: verifies a server response with the REAL PHP openssl_verify,
 * using the exact algorithm from MyTheme\Template\License::verifyResponse +
 * canonicalArray. If this prints PASS, License.php inside WHMCS accepts the response.
 *
 *   php verify.php [path-to-response.json] [expected-nonce]
 *
 * Defaults to test/sample-response.json + test/sample-nonce.txt (written by test-handshake.mjs).
 */

$dir   = __DIR__;
$pubPem = file_get_contents($dir . '/../keys/dev-public.pem');
$respPath = $argv[1] ?? ($dir . '/sample-response.json');
$noncePath = $dir . '/sample-nonce.txt';
$expectedNonce = $argv[2] ?? (is_file($noncePath) ? trim((string)file_get_contents($noncePath)) : null);

$raw = is_file($respPath) ? (string)file_get_contents($respPath) : '';
if ($raw === '') {
    fwrite(STDERR, "no response file at {$respPath} — run `node test/test-handshake.mjs` first\n");
    exit(2);
}

// --- copied verbatim from License.php -------------------------------------
function canonicalArray(array $a): array {
    if (array_is_list($a)) {
        foreach ($a as &$v) { if (is_array($v)) { $v = canonicalArray($v); } }
        return $a;
    }
    ksort($a);
    foreach ($a as &$v) { if (is_array($v)) { $v = canonicalArray($v); } }
    return $a;
}
function canonicalJson(array $data): string {
    return (string)json_encode(canonicalArray($data), JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE);
}
// --------------------------------------------------------------------------

$data = json_decode($raw, true);
if (!is_array($data) || !isset($data['signature'], $data['nonce_echo'], $data['signed_at'])) {
    echo "FAIL: missing required fields\n"; exit(1);
}

$checks = [];

// 1. nonce (replay protection)
if ($expectedNonce !== null) {
    $checks['nonce'] = hash_equals($expectedNonce, (string)$data['nonce_echo']);
}

// 2. recency
$signedAt = (int)strtotime((string)$data['signed_at']);
$checks['signed_at <= 24h'] = ($signedAt !== 0 && abs(time() - $signedAt) <= 86400);

// 3. signature
$sig = base64_decode((string)$data['signature'], true);
$payload = $data;
unset($payload['signature']);
$canonical = canonicalJson($payload);
$pubKey = openssl_pkey_get_public($pubPem);
$checks['RSA signature'] = ($pubKey !== false && openssl_verify($canonical, (string)$sig, $pubKey, OPENSSL_ALGO_SHA256) === 1);

$allPass = !in_array(false, $checks, true);

echo "PHP openssl_verify proof (mirrors License::verifyResponse)\n";
echo str_repeat('-', 56) . "\n";
foreach ($checks as $name => $ok) {
    echo sprintf("  %-18s %s\n", $name, $ok ? 'PASS' : 'FAIL');
}
echo str_repeat('-', 56) . "\n";
echo "  license_status     {$data['license_status']}\n";
echo "  allowed_domains    " . implode(', ', $data['allowed_domains'] ?: ['(none)']) . "\n";
echo $allPass
    ? ">> PASS — License.php WILL accept this response.\n"
    : ">> FAIL — License.php would reject this response.\n";
exit($allPass ? 0 : 1);
