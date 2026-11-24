<?php
/**
 * One fingerprint of everything the Hadrian admin can write, for tests that
 * must prove a refused request changed NOTHING.
 *
 *   php tests/php/admin-state.php hash
 *       JSON: a sha1 per table, and one overall.
 *   php tests/php/admin-state.php get <setting>
 *       JSON: one hadrian_settings value (null when the row is absent).
 *
 * Covered: hadrian_settings (minus the two discovery caches the admin rebuilds
 * on its own), hadrian_pages, hadrian_menus, hadrian_menu_items, and the
 * licence key row in tblconfiguration. Timestamps are left out on purpose: a
 * write that stores the same values is still a write, but a read never bumps
 * them, so this compares the values themselves.
 *
 * Read-only. Refuses unless SystemURL is localhost.
 */

declare(strict_types=1);

$whmcsRoot = getenv('WHMCS_ROOT') ?: 'C:/laragon/www/whmcs';
chdir($whmcsRoot);
require_once $whmcsRoot . '/init.php';

use WHMCS\Database\Capsule as DB;

$systemUrl = (string) DB::table('tblconfiguration')->where('setting', 'SystemURL')->value('value');
if (!preg_match('~^https?://(localhost|127\.0\.0\.1)([:/]|$)~i', $systemUrl)) {
    fwrite(STDERR, "REFUSING TO RUN: SystemURL is '{$systemUrl}', which is not a local install.\n");
    exit(2);
}

$rows = static function (string $table, array $without, ?callable $filter = null): array {
    if (!DB::schema()->hasTable($table)) {
        return [];
    }
    $out = [];
    foreach (DB::table($table)->get() as $r) {
        $a = (array) $r;
        foreach ($without as $col) {
            unset($a[$col]);
        }
        if ($filter === null || $filter($a)) {
            $out[] = $a;
        }
    }
    usort($out, static fn($x, $y) => strcmp(json_encode($x), json_encode($y)));
    return $out;
};

switch ($argv[1] ?? '') {
    case 'hash':
        $parts = [
            'settings'   => $rows('hadrian_settings', ['created_at', 'updated_at'],
                static fn(array $a) => !in_array($a['setting'], ['hadrian_pages_discovered', 'hadrian_layouts_discovered'], true)),
            'pages'      => $rows('hadrian_pages', ['created_at', 'updated_at']),
            'menus'      => $rows('hadrian_menus', ['created_at', 'updated_at']),
            'menu_items' => $rows('hadrian_menu_items', ['created_at', 'updated_at']),
            'license'    => [DB::table('tblconfiguration')->where('setting', 'hadrian_license_key')->value('value')],
        ];
        $out = [];
        foreach ($parts as $name => $data) {
            $out[$name] = sha1((string) json_encode($data));
        }
        $out['all'] = sha1(implode('', $out));
        echo json_encode($out), "\n";
        break;

    case 'get':
        $row = DB::table('hadrian_settings')->where('setting', (string) ($argv[2] ?? ''))->value('value');
        echo json_encode($row), "\n";
        break;

    default:
        fwrite(STDERR, "usage: admin-state.php hash | get <setting>\n");
        exit(1);
}
