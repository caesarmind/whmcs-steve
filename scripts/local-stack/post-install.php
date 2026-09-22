<?php
/**
 * Post-install wiring for the Hadrian local stack.
 *
 * Run from the WHMCS root with the Laragon PHP CLI:
 *   php post-install.php
 *
 * Does the two things the admin UI would do, without needing an admin login:
 *   1. Template -> hadrian, OrderFormTemplate -> hadrian_cart
 *   2. Activate the Hadrian addon (tbladdonmodules rows + Hadrian_activate(),
 *      which runs the migrator, the menu seeder and the pages cache)
 */

define('CLIENTAREA', false);
$whmcsRoot = 'C:/laragon/www/whmcs';
chdir($whmcsRoot);
require_once $whmcsRoot . '/init.php';

use WHMCS\Database\Capsule;

function setConfig(string $setting, string $value): void
{
    $existing = Capsule::table('tblconfiguration')->where('setting', $setting)->first();
    if ($existing) {
        Capsule::table('tblconfiguration')->where('setting', $setting)->update(['value' => $value]);
    } else {
        Capsule::table('tblconfiguration')->insert(['setting' => $setting, 'value' => $value]);
    }
    echo "  {$setting} = {$value}\n";
}

echo "== templates ==\n";
setConfig('Template', 'hadrian');
setConfig('OrderFormTemplate', 'hadrian_cart');

echo "== addon: Hadrian ==\n";
$addonFile = $whmcsRoot . '/modules/addons/Hadrian/Hadrian.php';
if (!file_exists($addonFile)) {
    echo "  MISSING: {$addonFile}\n";
    exit(1);
}
require_once $addonFile;

$config = Hadrian_config();
$version = $config['version'] ?? '1.0.0';

// WHMCS records an active addon as rows in tbladdonmodules: one per config
// field, plus 'version' and 'access' (a comma-separated list of admin role ids).
$roleIds = Capsule::table('tbladminroles')->pluck('id')->implode(',');
$rows = ['version' => $version, 'access' => $roleIds];
foreach (array_keys($config['fields'] ?? []) as $field) {
    $rows[$field] = $config['fields'][$field]['Default'] ?? '';
}
foreach ($rows as $setting => $value) {
    $exists = Capsule::table('tbladdonmodules')
        ->where('module', 'Hadrian')->where('setting', $setting)->exists();
    if ($exists) {
        Capsule::table('tbladdonmodules')
            ->where('module', 'Hadrian')->where('setting', $setting)
            ->update(['value' => (string) $value]);
    } else {
        Capsule::table('tbladdonmodules')
            ->insert(['module' => 'Hadrian', 'setting' => $setting, 'value' => (string) $value]);
    }
    echo "  {$setting} = {$value}\n";
}

// Activating through the admin UI also maintains two tblconfiguration caches.
// Writing tbladdonmodules alone is NOT enough:
//   ActiveAddonModules - AddonHelper::isActive() reads this
//   AddonModulesHooks  - WHMCS only loads modules/addons/<x>/hooks.php for
//                        modules listed here. Leave it empty and every hook
//                        silently no-ops: $hadrianLang renders as empty
//                        strings and the page falls back to template defaults.
foreach (['ActiveAddonModules', 'AddonModulesHooks'] as $key) {
    $current = (string) Capsule::table('tblconfiguration')->where('setting', $key)->value('value');
    $list = array_values(array_filter(array_map('trim', explode(',', $current))));
    if (!in_array('Hadrian', $list, true)) {
        $list[] = 'Hadrian';
    }
    setConfig($key, implode(',', $list));
}

// _activate() is idempotent by design (migrator tracks applied migrations,
// seeder skips existing presets), so running it here is safe.
echo "== Hadrian_activate() ==\n";
try {
    $result = Hadrian_activate();
    echo '  ' . json_encode($result) . "\n";
} catch (Throwable $e) {
    echo '  THREW: ' . get_class($e) . ': ' . $e->getMessage() . "\n";
    echo '  ' . $e->getFile() . ':' . $e->getLine() . "\n";
}

echo "== verify ==\n";
foreach (['Template', 'OrderFormTemplate', 'SystemURL'] as $s) {
    $v = Capsule::table('tblconfiguration')->where('setting', $s)->value('value');
    echo "  {$s} = {$v}\n";
}
$addonCount = Capsule::table('tbladdonmodules')->where('module', 'Hadrian')->count();
echo "  tbladdonmodules rows for Hadrian = {$addonCount}\n";
$tables = Capsule::connection()->select("SHOW TABLES LIKE 'hadrian%'");
echo '  hadrian tables = ' . count($tables) . "\n";
foreach ($tables as $t) { echo '    - ' . implode('', (array) $t) . "\n"; }
