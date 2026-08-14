<?php
declare(strict_types=1);
/**
 * Drives the REAL MyTheme\Template\License class (not a mirror) against the dev
 * server, with an in-memory Configuration so no WHMCS DB is needed. Exercises the
 * full path: phone-home -> RSA verify -> HMAC cache write/read -> state machine
 * -> canActivate().
 *
 *   node ../server.mjs            # must be running
 *   php client-sim.php
 */

// ---- in-memory stand-in for MyTheme\Models\Configuration (tblconfiguration) ----
namespace MyTheme\Models {
    final class Configuration {
        /** @var array<string,string> */
        public static array $store = [];
        public static function getValue(string $k): ?string { return self::$store[$k] ?? null; }
        public static function setValue(string $k, string $v): void { self::$store[$k] = $v; }
        public static function deleteValue(string $k): void { unset(self::$store[$k]); }
    }
}

namespace {
    use MyTheme\Template\Template;
    use MyTheme\Template\License;

    // The client treats no SERVER_NAME as CLI/cron and skips the call — set one.
    $_SERVER['SERVER_NAME'] = $argv[1] ?? 'bill.hostnodes.com';

    $base = realpath(__DIR__ . '/../../mytheme/modules/addons/MyTheme/src');
    foreach ([
        '/Helpers/IntegrityHashes.php',
        '/Helpers/ThemeManifest.php',
        '/Template/LicenseState.php',
        '/Template/License.php',
        '/Template/LicenseHelper.php',
        '/Template/Template.php',
    ] as $f) {
        require $base . $f;
    }

    License::$licenseServerUrl = getenv('LICENSE_URL') ?: 'http://127.0.0.1:8787/check';

    $t   = new Template('mytheme');
    $lic = $t->license();

    echo "Real License class vs dev server   (domain: {$_SERVER['SERVER_NAME']})\n";
    echo str_repeat('-', 64) . "\n";
    echo sprintf("  dev_mode = %s\n\n", $t->devMode ? 'true' : 'false');

    $scenarios = [
        'Active key, authorized domain' => 'HOSTNODES-DEV-ACTIVE-0001',
        'Cancelled key'                 => 'HOSTNODES-DEV-CANCELLED',
        'Bogus key'                     => 'TOTALLY-MADE-UP-KEY',
    ];

    foreach ($scenarios as $label => $key) {
        $lic->setLicenseKey($key);   // writes key, clears cache
        $lic->refreshNow();          // forces a fresh phone-home + verify + cache
        $cacheBlob = \MyTheme\Models\Configuration::getValue('MyTheme-mytheme-license-data');
        $hasMac    = $cacheBlob !== null && str_contains($cacheBlob, '|');
        echo sprintf(
            "  %-32s canActivate=%-5s  cache=%s\n",
            $label,
            $t->canActivate() ? 'true' : 'false',
            $hasMac ? 'written+HMAC' : '(none)',
        );
    }

    // Wrong-domain run: valid key but the server's allowed_domains won't contain us.
    $_SERVER['SERVER_NAME'] = 'pirate.example';
    $lic->setLicenseKey('HOSTNODES-DEV-ACTIVE-0001');
    $lic->refreshNow();
    echo sprintf(
        "  %-32s canActivate=%-5s  (signature OK, domain rejected)\n",
        'Active key, WRONG domain',
        $t->canActivate() ? 'true' : 'false',
    );

    echo str_repeat('-', 64) . "\n";
    echo "Expected: Active=true, Cancelled=false, Bogus=false, wrong-domain=false\n";
}
