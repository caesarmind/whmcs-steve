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
 *   3. Activate Hadrian Email Templates the same way, when its folder is
 *      mounted (it is a separate module that requires Hadrian)
 *   4. Activate Hadrian Page Builder the same way, when its folder is mounted
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

/**
 * Activate one addon module the way the admin UI would.
 *
 * $required = false is for a module that is a separate product (Hadrian Email
 * Templates): a checkout without its folder mounted is a valid local stack,
 * so its absence is reported and skipped rather than treated as a failure.
 */
function activateAddon(string $module, string $whmcsRoot, bool $required = true): void
{
    echo "== addon: {$module} ==\n";
    $addonFile = $whmcsRoot . "/modules/addons/{$module}/{$module}.php";
    if (!file_exists($addonFile)) {
        echo "  " . ($required ? 'MISSING' : 'not mounted, skipped') . ": {$addonFile}\n";
        if ($required) {
            exit(1);
        }
        return;
    }
    require_once $addonFile;

    $config  = ($module . '_config')();
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
            ->where('module', $module)->where('setting', $setting)->exists();
        if ($exists) {
            Capsule::table('tbladdonmodules')
                ->where('module', $module)->where('setting', $setting)
                ->update(['value' => (string) $value]);
        } else {
            Capsule::table('tbladdonmodules')
                ->insert(['module' => $module, 'setting' => $setting, 'value' => (string) $value]);
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
        if (!in_array($module, $list, true)) {
            $list[] = $module;
        }
        setConfig($key, implode(',', $list));
    }

    // _activate() is idempotent by design in both modules (Hadrian's migrator
    // tracks applied migrations and its seeder skips existing presets; Hadrian
    // Email only creates tables that are missing), so running it here is safe.
    echo "== {$module}_activate() ==\n";
    try {
        $result = ($module . '_activate')();
        echo '  ' . json_encode($result) . "\n";
    } catch (Throwable $e) {
        echo '  THREW: ' . get_class($e) . ': ' . $e->getMessage() . "\n";
        echo '  ' . $e->getFile() . ':' . $e->getLine() . "\n";
    }
}

activateAddon('Hadrian', $whmcsRoot);
// A separate product that requires Hadrian, so it goes second.
activateAddon('HadrianEmail', $whmcsRoot, false);
activateAddon('HadrianBuilder', $whmcsRoot, false);

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
