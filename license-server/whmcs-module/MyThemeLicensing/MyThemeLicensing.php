<?php
declare(strict_types=1);
/**
 * MyThemeLicensing — WHMCS server (provisioning) module.
 *
 * The ISSUER side of MyTheme / Hadrian licensing. Install this on the WHMCS you
 * SELL from (never ships to buyers). A license becomes a normal WHMCS product:
 *   - Order placed  -> CreateAccount() generates a license key
 *   - Invoice unpaid -> WHMCS suspends -> verify.php returns Suspended
 *   - Cancelled/terminated -> verify.php returns Cancelled -> theme falls back
 *
 * This is the Lagom (RSLicensing) architecture. The call-home handler is
 * verify.php in this directory; it RSA-signs responses the buyer's theme checks.
 */

if (!defined('WHMCS')) {
    die('This file cannot be accessed directly');
}

use WHMCS\Database\Capsule;

const MYTHEMELICENSING_TABLE = 'mod_mytheme_licenses';

function MyThemeLicensing_MetaData(): array
{
    return [
        'DisplayName'                => 'MyTheme / Hadrian Licensing',
        'APIVersion'                 => '1.1',
        'RequiresServer'             => false,
        'DefaultNonSSLPort'          => '',
        'DefaultSSLPort'             => '',
        'ServiceSingleSignOnLabel'   => '',
    ];
}

/** Product config options (per-product on the WHMCS product setup screen). */
function MyThemeLicensing_ConfigOptions(): array
{
    return [
        'Features' => [
            'Type'        => 'text',
            'Size'        => '40',
            'Default'     => 'dark-mode,cms-pages',
            'Description' => 'Comma-separated feature flags returned to the theme.',
        ],
        'Max Domains' => [
            'Type'        => 'text',
            'Size'        => '5',
            'Default'     => '1',
            'Description' => 'How many domains this license may bind (trust-on-first-use).',
        ],
    ];
}

function MyThemeLicensing_CreateAccount(array $params): string
{
    try {
        mythemelicensing_ensure_table();

        $serviceId = (int) $params['serviceid'];
        $features  = (string) ($params['configoption1'] ?? '');
        $maxDomain = max(1, (int) ($params['configoption2'] ?? 1));

        // Reuse an existing key if the service already has one (re-runs of Create).
        $existing = Capsule::table(MYTHEMELICENSING_TABLE)->where('serviceid', $serviceId)->first();
        if ($existing === null) {
            Capsule::table(MYTHEMELICENSING_TABLE)->insert([
                'serviceid'       => $serviceId,
                'license_key'     => mythemelicensing_genkey(),
                'allowed_domains' => '',
                'features'        => $features,
                'max_domains'     => $maxDomain,
                'created_at'      => date('Y-m-d H:i:s'),
            ]);
        }

        return 'success';
    } catch (\Throwable $e) {
        logModuleCall('MyThemeLicensing', 'CreateAccount', $params, $e->getMessage());
        return $e->getMessage();
    }
}

// Status is read live from tblhosting in verify.php, so suspend/unsuspend/
// terminate just need to succeed — WHMCS flips the service status itself.
function MyThemeLicensing_SuspendAccount(array $params): string   { return 'success'; }
function MyThemeLicensing_UnsuspendAccount(array $params): string { return 'success'; }

function MyThemeLicensing_TerminateAccount(array $params): string
{
    // Keep the license row so verify.php can answer "Cancelled" (vs vanishing to
    // "Invalid"); WHMCS has already set the service status to Terminated.
    return 'success';
}

function MyThemeLicensing_ChangePackage(array $params): string
{
    try {
        Capsule::table(MYTHEMELICENSING_TABLE)
            ->where('serviceid', (int) $params['serviceid'])
            ->update([
                'features'    => (string) ($params['configoption1'] ?? ''),
                'max_domains' => max(1, (int) ($params['configoption2'] ?? 1)),
            ]);
        return 'success';
    } catch (\Throwable $e) {
        logModuleCall('MyThemeLicensing', 'ChangePackage', $params, $e->getMessage());
        return $e->getMessage();
    }
}

/** Admin "Module Commands" buttons on the service page. */
function MyThemeLicensing_AdminCustomButtonArray(): array
{
    return [
        'Regenerate Key' => 'RegenerateKey',
        'Reset Domains'  => 'ResetDomains',
    ];
}

function MyThemeLicensing_RegenerateKey(array $params): string
{
    try {
        Capsule::table(MYTHEMELICENSING_TABLE)
            ->where('serviceid', (int) $params['serviceid'])
            ->update(['license_key' => mythemelicensing_genkey(), 'allowed_domains' => '']);
        return 'success';
    } catch (\Throwable $e) {
        return $e->getMessage();
    }
}

function MyThemeLicensing_ResetDomains(array $params): string
{
    try {
        Capsule::table(MYTHEMELICENSING_TABLE)
            ->where('serviceid', (int) $params['serviceid'])
            ->update(['allowed_domains' => '']);
        return 'success';
    } catch (\Throwable $e) {
        return $e->getMessage();
    }
}

/** Fields shown on the admin "Products/Services" page for this service. */
function MyThemeLicensing_AdminServicesTabFields(array $params): array
{
    $row = Capsule::table(MYTHEMELICENSING_TABLE)->where('serviceid', (int) $params['serviceid'])->first();
    if ($row === null) {
        return ['License' => '<em>No license row yet — run Create.</em>'];
    }
    return [
        'License Key'   => '<input type="text" readonly value="' . htmlspecialchars($row->license_key) . '" style="width:340px">',
        'Bound Domains' => htmlspecialchars($row->allowed_domains ?: '(none yet — binds on first check)'),
        'Max Domains'   => (int) $row->max_domains,
        'Features'      => htmlspecialchars($row->features ?: '(none)'),
    ];
}

/** Customer-facing license panel in the client area. */
function MyThemeLicensing_ClientArea(array $params): array
{
    $row = Capsule::table(MYTHEMELICENSING_TABLE)->where('serviceid', (int) $params['serviceid'])->first();
    return [
        'templatefile' => 'clientarea',
        'vars'         => [
            'licenseKey'    => $row->license_key ?? '',
            'boundDomains'  => $row->allowed_domains ?? '',
            'maxDomains'    => (int) ($row->max_domains ?? 1),
        ],
    ];
}

// --------------------------------------------------------------------- helpers

function mythemelicensing_genkey(): string
{
    $raw = strtoupper(bin2hex(random_bytes(10)));   // 20 hex chars
    return 'HADRIAN-' . implode('-', str_split($raw, 5));
}

function mythemelicensing_ensure_table(): void
{
    if (Capsule::schema()->hasTable(MYTHEMELICENSING_TABLE)) {
        return;
    }
    Capsule::schema()->create(MYTHEMELICENSING_TABLE, function ($t) {
        $t->increments('id');
        $t->integer('serviceid')->index();
        $t->string('license_key')->unique();
        $t->text('allowed_domains')->nullable();
        $t->text('features')->nullable();
        $t->integer('max_domains')->default(1);
        $t->string('created_at')->nullable();
    });
}
