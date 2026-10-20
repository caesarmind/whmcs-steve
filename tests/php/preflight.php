<?php
/**
 * Preflight - report the local WHMCS state as JSON for tests/lib/preflight.mjs.
 *
 *   php tests/php/preflight.php
 *
 * Read-only. Every field here maps to a failure we have actually hit, so a
 * broken environment fails ONE clear preflight check instead of 75 page tests
 * that all look like theme bugs:
 *
 *   addonModulesHooks - empty => hooks.php never loads, $hadrianLang renders
 *                       as empty strings, every heading on the site is blank
 *   installDirPresent - WHMCS answers every page with "Security Warning"
 *   template          - not 'hadrian' => the suite would be testing Six
 */

declare(strict_types=1);

$whmcsRoot = getenv('WHMCS_ROOT') ?: 'C:/laragon/www/whmcs';
$out = ['ok' => true, 'whmcsRoot' => $whmcsRoot];

if (!is_file($whmcsRoot . '/init.php')) {
    echo json_encode(['ok' => false, 'error' => "WHMCS not found at {$whmcsRoot}"]);
    exit(0);
}
$out['installDirPresent'] = is_dir($whmcsRoot . '/install');
if ($out['installDirPresent']) {
    // init.php refuses to boot while install/ exists, so stop here.
    echo json_encode($out, JSON_UNESCAPED_SLASHES);
    exit(0);
}

chdir($whmcsRoot);
try {
    require_once $whmcsRoot . '/init.php';
} catch (Throwable $e) {
    echo json_encode(['ok' => false, 'error' => 'init.php failed: ' . $e->getMessage()]);
    exit(0);
}

use WHMCS\Database\Capsule;

$cfg = fn(string $k) => (string) Capsule::table('tblconfiguration')->where('setting', $k)->value('value');
$list = fn(string $k) => array_values(array_filter(array_map('trim', explode(',', $cfg($k)))));

$out += [
    'whmcsVersion'       => $cfg('Version'),
    'phpVersion'         => PHP_VERSION,
    'ioncube'            => function_exists('ioncube_loader_version') ? ioncube_loader_version() : null,
    'systemUrl'          => $cfg('SystemURL'),
    'template'           => $cfg('Template'),
    'orderFormTemplate'  => $cfg('OrderFormTemplate'),
    'activeAddonModules' => $list('ActiveAddonModules'),
    'addonModulesHooks'  => $list('AddonModulesHooks'),
    'hadrianTables'      => count(Capsule::connection()->select("SHOW TABLES LIKE 'hadrian\\_%'")),
    'hadrianMenus'       => Capsule::schema()->hasTable('hadrian_menus') ? Capsule::table('hadrian_menus')->count() : 0,
    'counts' => [
        'clients'  => Capsule::table('tblclients')->count(),
        'products' => Capsule::table('tblproducts')->count(),
        'services' => Capsule::table('tblhosting')->count(),
        'invoices' => Capsule::table('tblinvoices')->count(),
    ],
    'paymentGateways' => Capsule::table('tblpaymentgateways')->where('setting', 'name')->pluck('gateway')->all(),
];
echo json_encode($out, JSON_UNESCAPED_SLASHES);
