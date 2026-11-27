<?php
/**
 * Read and back up what the Hadrian admin writes, for the admin audit
 * (tests/e2e/audit/). The audit drives every admin screen through the real
 * browser and proves each Save with the stored value before and after.
 *
 *   php tests/php/audit-state.php setting <key>          hadrian_settings value (null = no row)
 *   php tests/php/audit-state.php settings <prefix>      every hadrian_settings row whose key starts with <prefix>
 *   php tests/php/audit-state.php config <key>           tblconfiguration value
 *   php tests/php/audit-state.php page <page> [tpl]      the hadrian_pages row (default tpl hadrian)
 *   php tests/php/audit-state.php menus                  every menu with its item count
 *   php tests/php/audit-state.php menu <id>              one menu and its items
 *   php tests/php/audit-state.php file <path>            exists, size, sha1, mtime (path relative to the WHMCS root)
 *   php tests/php/audit-state.php backup                 every Hadrian table + Hadrian's tblconfiguration rows -> tests/.local/audit-backup.json
 *   php tests/php/audit-state.php restore                put that backup back EXACTLY, then delete it
 *
 * Every command prints one JSON line. backup and restore change state, so they
 * take the site-lock guard like settings.php; the reads do not. A backup that
 * is still on disk when the next backup starts is restored first: a run that
 * died halfway heals instead of stacking a second backup on a dirty install.
 *
 * Refuses to run unless SystemURL is localhost.
 */

declare(strict_types=1);

$cmd = $argv[1] ?? '';
if (in_array($cmd, ['backup', 'restore'], true)) {
    require_once __DIR__ . '/site-lock.php';
    hadrian_site_lock_guard('audit-state.php');
}

$whmcsRoot  = getenv('WHMCS_ROOT') ?: 'C:/laragon/www/whmcs';
$backupFile = dirname(__DIR__) . '/.local/audit-backup.json';
chdir($whmcsRoot);
require_once $whmcsRoot . '/init.php';

use WHMCS\Database\Capsule as DB;

$systemUrl = (string) DB::table('tblconfiguration')->where('setting', 'SystemURL')->value('value');
if (!preg_match('~^https?://(localhost|127\.0\.0\.1)([:/]|$)~i', $systemUrl)) {
    fwrite(STDERR, "REFUSING TO RUN: SystemURL is '{$systemUrl}', which is not a local install.\n");
    exit(2);
}

$out = static function ($v): void {
    echo json_encode($v, JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE | JSON_PARTIAL_OUTPUT_ON_ERROR), "\n";
};

// Hadrian's own tables, the builder's and the email module's (they share the
// prefix), and the tblconfiguration rows the addon writes.
$tables = static function (): array {
    $names = [];
    foreach (DB::select("SELECT table_name AS t FROM information_schema.tables WHERE table_schema = DATABASE() AND table_name LIKE 'hadrian\\_%'") as $r) {
        $names[] = (string) $r->t;
    }
    sort($names);
    return $names;
};
$configKeys = static function (): array {
    return DB::table('tblconfiguration')
        ->where(static function ($q) {
            $q->where('setting', 'like', 'hadrian%')
              ->orWhere('setting', 'like', 'mytheme%')
              ->orWhereIn('setting', ['Template', 'OrderFormTemplate']);
        })
        ->pluck('setting')->all();
};

$restore = static function () use ($backupFile): array {
    $b = json_decode((string) file_get_contents($backupFile), true);
    if (!is_array($b) || !isset($b['tables'], $b['config'])) {
        throw new RuntimeException("{$backupFile} is not an audit backup");
    }
    DB::statement('SET FOREIGN_KEY_CHECKS = 0');
    try {
        foreach ($b['tables'] as $table => $rows) {
            if (!DB::schema()->hasTable($table)) {
                continue;   // dropped since (a Database Clear test): migrations bring it back
            }
            DB::table($table)->truncate();
            foreach (array_chunk($rows, 200) as $chunk) {
                DB::table($table)->insert($chunk);
            }
        }
    } finally {
        DB::statement('SET FOREIGN_KEY_CHECKS = 1');
    }
    // Config rows: put each back, delete the Hadrian ones added since.
    $keep = array_keys($b['config']);
    DB::table('tblconfiguration')
        ->where(static function ($q) {
            $q->where('setting', 'like', 'hadrian%')->orWhere('setting', 'like', 'mytheme%');
        })
        ->whereNotIn('setting', $keep)->delete();
    foreach ($b['config'] as $k => $v) {
        DB::table('tblconfiguration')->updateOrInsert(['setting' => $k], ['value' => $v]);
    }
    unlink($backupFile);
    return ['restored' => array_keys($b['tables']), 'config' => count($b['config']), 'taken' => $b['taken']];
};

switch ($cmd) {
    case 'setting':
        $out(DB::table('hadrian_settings')->where('setting', (string) ($argv[2] ?? ''))->value('value'));
        break;

    case 'settings':
        $prefix = (string) ($argv[2] ?? '');
        $out(DB::table('hadrian_settings')->where('setting', 'like', addcslashes($prefix, '%_') . '%')
            ->orderBy('setting')->pluck('value', 'setting'));
        break;

    case 'config':
        $out(DB::table('tblconfiguration')->where('setting', (string) ($argv[2] ?? ''))->value('value'));
        break;

    case 'page':
        $row = DB::table('hadrian_pages')
            ->where('page', (string) ($argv[2] ?? ''))
            ->where('template', (string) ($argv[3] ?? 'hadrian'))->first();
        $out($row ? (array) $row : null);
        break;

    case 'menus':
        $rows = [];
        foreach (DB::table('hadrian_menus')->orderBy('id')->get() as $m) {
            $a = (array) $m;
            $a['items'] = DB::table('hadrian_menu_items')->where('menu_id', $m->id)->count();
            $rows[] = $a;
        }
        $out($rows);
        break;

    case 'menu':
        $id = (int) ($argv[2] ?? 0);
        $m  = DB::table('hadrian_menus')->where('id', $id)->first();
        $out($m ? ['menu' => (array) $m, 'items' => array_map(static fn($r) => (array) $r,
            DB::table('hadrian_menu_items')->where('menu_id', $id)->orderBy('parent_id')->orderBy('position')->get()->all())] : null);
        break;

    case 'file':
        $p = $whmcsRoot . '/' . ltrim((string) ($argv[2] ?? ''), '/');
        clearstatcache(true, $p);
        $out(is_file($p)
            ? ['exists' => true, 'size' => filesize($p), 'sha1' => sha1_file($p), 'mtime' => filemtime($p)]
            : ['exists' => false]);
        break;

    case 'backup':
        $healed = null;
        if (is_file($backupFile)) {
            $healed = $restore();
        }
        $b = ['taken' => date('c'), 'tables' => [], 'config' => []];
        foreach ($tables() as $t) {
            $b['tables'][$t] = array_map(static fn($r) => (array) $r, DB::table($t)->get()->all());
        }
        foreach ($configKeys() as $k) {
            $b['config'][$k] = DB::table('tblconfiguration')->where('setting', $k)->value('value');
        }
        if (!is_dir(dirname($backupFile))) {
            mkdir(dirname($backupFile), 0777, true);
        }
        file_put_contents($backupFile, json_encode($b, JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE));
        $out(['backup' => $backupFile, 'tables' => array_map('count', $b['tables']), 'config' => count($b['config']), 'healed' => $healed]);
        break;

    case 'restore':
        $out(is_file($backupFile) ? $restore() : ['restored' => false, 'reason' => 'no backup on disk']);
        break;

    default:
        fwrite(STDERR, "usage: audit-state.php setting|settings|config|page|menus|menu|file|backup|restore ...\n");
        exit(1);
}
