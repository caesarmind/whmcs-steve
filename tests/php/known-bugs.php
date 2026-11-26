<?php
/**
 * The live half of tests/e2e/known-bugs.spec.mjs: set up each confirmed bug in
 * tests/FEATURES.md against the local WHMCS, report what happened as one JSON
 * line, and put everything back.
 *
 *   php tests/php/known-bugs.php menu-rename            bug 5, before the Menu screen is opened
 *   php tests/php/known-bugs.php menu-state '<json>'    bug 5, after
 *   php tests/php/known-bugs.php menu-restore '<json>'  bug 5, clean up
 *   php tests/php/known-bugs.php page-row <page>        bug 4, read a hadrian_pages row
 *
 * Reports facts, not verdicts: the spec decides what is right. Exit 0 means
 * the scenario ran; anything else means it could not be set up and the spec
 * fails outright. Refuses unless SystemURL is localhost.
 *
 * Bugs 1 and 2 (email drafts) are fixed; their checks are in email-live.php.
 */

declare(strict_types=1);

// Not while another test run holds the local site (tests/php/site-lock.php).
require_once __DIR__ . '/site-lock.php';
hadrian_site_lock_guard('known-bugs.php');

$whmcsRoot = getenv('WHMCS_ROOT') ?: 'C:/laragon/www/whmcs';
chdir($whmcsRoot);
require_once $whmcsRoot . '/init.php';
require_once $whmcsRoot . '/modules/addons/Hadrian/autoload.php';

use WHMCS\Database\Capsule as DB;

$systemUrl = (string) DB::table('tblconfiguration')->where('setting', 'SystemURL')->value('value');
if (!preg_match('~^https?://(localhost|127\.0\.0\.1)([:/]|$)~i', $systemUrl)) {
    fwrite(STDERR, "REFUSING TO RUN: SystemURL is '{$systemUrl}', which is not a local install.\n");
    exit(2);
}

$cmd = $argv[1] ?? '';
$arg = $argv[2] ?? '';
$say = static function (array $out): never {
    echo json_encode($out, JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE) . "\n";
    exit(0);
};
$refuse = static function (string $why, int $code = 3): never {
    fwrite(STDERR, $why . "\n");
    exit($code);
};

switch ($cmd) {
    // ---------------------------------------------------------------- bug 5
    case 'menu-rename':
        // The preset visitors see when signed out, exactly as the seeder ships it.
        $preset = null;
        foreach (\Hadrian\Menu\Presets::all() as $p) {
            if ($p['location'] === 'main' && $p['audience'] === 'guest' && !empty($p['active'])) {
                $preset = $p;
                break;
            }
        }
        $preset ?? $refuse('no active guest main-menu preset in Presets::all()');
        $menu = \Hadrian\Models\Menu::where('name', $preset['name'])->where('location', 'main')->first();
        $picked = \Hadrian\Models\Menu::pick('main', 'guest');
        if (!$menu || !$menu->active || !$picked || (int) $picked->id !== (int) $menu->id) {
            $refuse("the guest main menu is not the shipped preset '{$preset['name']}' on this install; nothing was changed");
        }
        $state = [
            'id'       => (int) $menu->id,
            'name'     => (string) $menu->name,
            'renamed'  => $menu->name . ' (renamed by a test)',
            'changed'  => (bool) $menu->changed_by_user,
            'maxId'    => (int) \Hadrian\Models\Menu::max('id'),
        ];
        // What saving the menu editor with a new name does to the row.
        $menu->name = $state['renamed'];
        $menu->changed_by_user = true;
        $menu->save();
        $say($state);

    case 'menu-state':
        $s = json_decode($arg, true) ?: $refuse('menu-state needs the JSON menu-rename printed');
        $picked = \Hadrian\Models\Menu::pick('main', 'guest');
        $copies = \Hadrian\Models\Menu::where('name', $s['name'])->where('location', 'main')
            ->where('id', '>', (int) $s['maxId'])->get(['id', 'active']);
        $say([
            'pickedId'     => $picked ? (int) $picked->id : null,
            'pickedName'   => $picked ? (string) $picked->name : null,
            'copies'       => $copies->pluck('id')->map(fn ($v) => (int) $v)->all(),
            'activeCopies' => $copies->where('active', true)->count(),
        ]);

    case 'menu-restore':
        $s = json_decode($arg, true) ?: $refuse('menu-restore needs the JSON menu-rename printed');
        $copies = \Hadrian\Models\Menu::where('name', $s['name'])->where('location', 'main')
            ->where('id', '>', (int) $s['maxId'])->pluck('id')->all();
        foreach ($copies as $id) {
            \Hadrian\Models\MenuItem::where('menu_id', $id)->delete();
            \Hadrian\Models\Menu::where('id', $id)->delete();
        }
        \Hadrian\Models\Menu::where('id', (int) $s['id'])->update(['name' => $s['name'], 'changed_by_user' => (bool) $s['changed']]);
        $picked = \Hadrian\Models\Menu::pick('main', 'guest');
        $say(['removed' => count($copies), 'restored' => $picked && (int) $picked->id === (int) $s['id']]);

    // ---------------------------------------------------------------- bug 4
    case 'page-row':
        $row = DB::table('hadrian_pages')->where('template', 'hadrian')->where('page', $arg)
            ->first(['page', 'seo_title', 'seo_description']);
        $row ?? $refuse("no hadrian_pages row for '{$arg}'");
        $say((array) $row);

    default:
        $refuse('usage: known-bugs.php menu-rename | menu-state <json> | menu-restore <json> | page-row <page>', 1);
}
