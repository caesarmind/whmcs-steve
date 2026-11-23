<?php
/**
 * Change Hadrian's settings for a test, and put them back afterwards.
 *
 *   php tests/php/settings.php snapshot
 *   php tests/php/settings.php set '{"hide_breadcrumb":["1","bool"]}'
 *   php tests/php/settings.php variant '{"login":"split"}'
 *   php tests/php/settings.php restore
 *
 * snapshot copies every hadrian_settings row and every hadrian_pages variant
 * of the hadrian template to tests/.local/settings-snapshot.json. restore puts
 * that state back EXACTLY (rows added since are deleted) and removes the file.
 * The preflight runs restore whenever the file exists, so a run that died
 * halfway through a settings test heals on the next run instead of leaving
 * the local install in a state nobody chose.
 *
 * Writes go straight to the tables, not through the admin save path: these
 * tests are about what each setting DOES on the client side. The save path
 * has its own coverage (admin.spec, settings-doc-coverage).
 *
 * Refuses to run unless SystemURL is localhost.
 */

declare(strict_types=1);

$whmcsRoot = getenv('WHMCS_ROOT') ?: 'C:/laragon/www/whmcs';
$snapFile  = dirname(__DIR__) . '/.local/settings-snapshot.json';
chdir($whmcsRoot);
require_once $whmcsRoot . '/init.php';

use WHMCS\Database\Capsule as DB;

$systemUrl = (string) DB::table('tblconfiguration')->where('setting', 'SystemURL')->value('value');
if (!preg_match('~^https?://(localhost|127\.0\.0\.1)([:/]|$)~i', $systemUrl)) {
    fwrite(STDERR, "REFUSING TO RUN: SystemURL is '{$systemUrl}', which is not a local install.\n");
    exit(2);
}

const TEMPLATE = 'hadrian';
$cmd = $argv[1] ?? '';
$arg = isset($argv[2]) ? json_decode($argv[2], true) : null;
$now = date('Y-m-d H:i:s');

// Page-level caches the addon keeps in hadrian_settings are NOT part of what
// a test sets, and the addon rewrites them on its own; leave them alone.
$isCache = fn(string $k) => in_array($k, ['hadrian_pages_discovered', 'hadrian_layouts_discovered'], true);

switch ($cmd) {
    case 'snapshot':
        if (is_file($snapFile)) { echo "snapshot already exists - keeping the older one\n"; break; }
        $settings = [];
        foreach (DB::table('hadrian_settings')->get(['setting', 'value', 'value_type']) as $r) {
            if (!$isCache($r->setting)) $settings[$r->setting] = [$r->value, $r->value_type];
        }
        $variants = DB::table('hadrian_pages')->where('template', TEMPLATE)->pluck('variant', 'page')->all();
        file_put_contents($snapFile, json_encode(['takenAt' => $now, 'settings' => $settings, 'variants' => $variants], JSON_PRETTY_PRINT));
        echo 'snapshot: ' . count($settings) . " settings\n";
        break;

    case 'set':
        if (!is_file($snapFile)) { fwrite(STDERR, "take a snapshot first\n"); exit(3); }
        foreach ((array) $arg as $key => $v) {
            if ($v === null) { DB::table('hadrian_settings')->where('setting', $key)->delete(); continue; }
            [$value, $type] = is_array($v) ? $v : [(string) $v, 'string'];
            if ($type === 'json' && !is_string($value)) $value = json_encode($value);
            DB::table('hadrian_settings')->updateOrInsert(['setting' => $key], ['value' => (string) $value, 'value_type' => $type, 'updated_at' => $now]);
        }
        echo "set\n";
        break;

    case 'variant':
        if (!is_file($snapFile)) { fwrite(STDERR, "take a snapshot first\n"); exit(3); }
        foreach ((array) $arg as $page => $variant) {
            $n = DB::table('hadrian_pages')->where('template', TEMPLATE)->where('page', $page)->update(['variant' => (string) $variant, 'updated_at' => $now]);
            if (!$n) { fwrite(STDERR, "no hadrian_pages row for page '$page' (open the admin Pages tab once to seed the registry)\n"); exit(4); }
        }
        echo "variant\n";
        break;

    case 'restore':
        if (!is_file($snapFile)) { echo "nothing to restore\n"; break; }
        $snap = json_decode((string) file_get_contents($snapFile), true);
        foreach (DB::table('hadrian_settings')->pluck('setting') as $k) {
            if (!$isCache($k) && !array_key_exists($k, $snap['settings'])) DB::table('hadrian_settings')->where('setting', $k)->delete();
        }
        foreach ($snap['settings'] as $k => [$value, $type]) {
            DB::table('hadrian_settings')->updateOrInsert(['setting' => $k], ['value' => $value, 'value_type' => $type, 'updated_at' => $now]);
        }
        foreach ($snap['variants'] as $page => $variant) {
            DB::table('hadrian_pages')->where('template', TEMPLATE)->where('page', $page)->update(['variant' => $variant]);
        }
        unlink($snapFile);
        echo "restored the settings snapshot from {$snap['takenAt']}\n";
        break;

    default:
        fwrite(STDERR, "usage: settings.php snapshot | set <json> | variant <json> | restore\n");
        exit(1);
}
