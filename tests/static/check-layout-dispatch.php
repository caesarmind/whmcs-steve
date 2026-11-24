<?php
/**
 * End-to-end check for the custom-layout extension point, no WHMCS needed.
 *
 * Runs the REAL LayoutsCache::rebuild() (with an in-memory Settings stub)
 * against the REAL theme tree, so the discovery pipeline is exercised, not
 * restated: the shipped `topbar-minimal` fixture must be discovered, a broken
 * folder must be rejected WITH a reason, and every file the dispatch chain
 * touches must hold up its end of the contract.
 *
 *   php tests/static/check-layout-dispatch.php     -> exit 0 all good / 1 + list
 */

namespace Hadrian\Models {
    /** In-memory stand-in. rebuild() writes here; readTrusted() reads it back. */
    final class Settings
    {
        public static array $rows = [];
        public static function getValue(string $key, $default = null)
        {
            return array_key_exists($key, self::$rows) ? self::$rows[$key] : $default;
        }
        public static function setValue(string $key, $value, string $type = 'string'): void
        {
            self::$rows[$key] = $value;
        }
    }
}

namespace {

$root  = dirname(__DIR__, 2);
$admin = $root . '/hadrian/modules/addons/Hadrian';
$tpl   = $root . '/hadrian/templates/hadrian';

$fails = [];
$oks   = 0;
$check = function (bool $cond, string $what) use (&$fails, &$oks): void {
    if ($cond) { $oks++; } else { $fails[] = $what; }
};

/* ---- 1. The real discovery pipeline over the real tree ------------------- */

/* The REAL Template, not a double: LayoutsCache type-hints it, and the
   constructor runs standalone (IntegrityHashes is a dev no-op, templatesRoot
   falls back to the repo, core/hadrian.php + theme.json are present). Same
   pattern the admin harnesses rely on. */
/* The anti-tamper hash table is a gitignored build artifact; load it the way
   the addon does (hooks.php) - the real one when present, the tracked stub
   otherwise. A checker that needed the generated file only ran on one machine. */
require is_file($admin . '/src/Helpers/IntegrityHashes.php')
    ? $admin . '/src/Helpers/IntegrityHashes.php'
    : $admin . '/src/Helpers/IntegrityHashes.fallback.php';
require $admin . '/src/Helpers/ThemeManifest.php';
require $admin . '/src/Template/Template.php';
require $admin . '/src/Template/PagesCache.php';
require $admin . '/src/Template/LayoutsCache.php';

$templateDouble = new Hadrian\Template\Template('hadrian');

/* A deliberately broken folder, to prove rejection is loud. Cleaned up below. */
$brokenDir = $tpl . '/core/layouts/main-menu/zz-broken-check';
@mkdir($brokenDir, 0777, true);
file_put_contents($brokenDir . '/layout.php', "<?php return ['displayName' => 'Broken'];\n"); // no default.tpl

try {
    $result = Hadrian\Template\LayoutsCache::rebuild($templateDouble);
} finally {
    @unlink($brokenDir . '/layout.php');
    @rmdir($brokenDir);
}

$menu = $result['layouts']['main-menu'] ?? [];
$check(isset($menu['topbar-minimal']), 'fixture topbar-minimal is discovered');
$check(($menu['topbar-minimal'] ?? '') === 'topbar-minimal', 'fixture token read from its manifest');
$check(!isset($menu['top']) && !isset($menu['sidebar']) && !isset($menu['rail']),
    'shipped (declared) layouts are NOT re-listed as discovered');

$rejected = $result['rejected'] ?? [];
$brokenRejection = null;
foreach ($rejected as $row) {
    if (($row['dir'] ?? '') === 'zz-broken-check') { $brokenRejection = $row; }
}
$check($brokenRejection !== null, 'a folder without default.tpl is rejected');
$check($brokenRejection !== null && str_contains((string)$brokenRejection['reason'], 'default.tpl'),
    'the rejection carries a reason naming the missing file');

$check(preg_match(Hadrian\Template\LayoutsCache::TOKEN_PATTERN, 'topbar-minimal') === 1,
    'fixture token satisfies TOKEN_PATTERN');
$check(preg_match(Hadrian\Template\LayoutsCache::TOKEN_PATTERN, 'Bad Token!') !== 1,
    'TOKEN_PATTERN rejects unsafe tokens');

/* ---- 2. The fixture honours the markup contract -------------------------- */

$fixTpl = file_get_contents($tpl . '/core/layouts/main-menu/topbar-minimal/default.tpl');
$check(str_contains($fixTpl, 'only-topbar-minimal'), 'fixture root carries only-<token>');
$check(str_contains($fixTpl, '$mtSidebarItems'), 'fixture consumes the admin menu list');
$check(is_file($tpl . '/core/layouts/main-menu/topbar-minimal/layout.css'), 'fixture ships layout.css');

$fixCss = file_get_contents($tpl . '/core/layouts/main-menu/topbar-minimal/layout.css');
$check(!preg_match('/#[0-9a-fA-F]{3,8}\b/', $fixCss),
    'fixture layout.css uses tokens, not hex (the example teaches the rule)');

/* ---- 3. The dispatch chain --------------------------------------------- */

$header = file_get_contents($tpl . '/header.tpl');
$check(str_contains($header, "core/layouts/main-menu/`\$mt_layout_dir`/default.tpl"),
    'header.tpl has the generic custom dispatch');
$check(str_contains($header, 'hadrian.preview.layoutTokens'),
    'header.tpl preview whitelist is data-driven');
$check(!preg_match('/\$_q\s*==\s*\'top\'\s*\|\|/', $header),
    'the old hardcoded preview whitelist is gone');
$check(str_contains($header, 'layout.css?v='), 'header.tpl links the custom layout.css');

$js = file_get_contents($tpl . '/assets/js/core-layout.js');
$check(!str_contains($js, "['top', 'side', 'rail'].indexOf"),
    'core-layout.js no longer hardcodes the token list');
$check(str_contains($js, 'serverLayout'), 'core-layout.js honours the server token');

$hooks = file_get_contents($admin . '/src/Service/Hooks.php');
$check(str_contains($hooks, 'buildLayoutGatesHead'), 'Hooks emits generated gates');
$check(str_contains($hooks, 'resolvePreviewLayoutTokens'), 'Hooks builds the preview token map');
// The guard moved with the pointer logic into LayoutPointers, which the client
// render and the admin page both resolve through. Its behaviour is tested in
// test-layout-pointers.php; here it is enough that Hooks goes through it.
$check(str_contains($hooks, 'LayoutPointers::resolve(')
    && str_contains((string)file_get_contents($admin . '/src/Helpers/LayoutPointers.php'), 'in_array($value, $valid, true)'),
    'stale pointers are validated where the active layout is resolved');

$adminTpl = file_get_contents($admin . '/views/adminarea/layouts/index.tpl');
$check(str_contains($adminTpl, 'Custom layout wireframe'), 'admin has a main-menu custom wireframe');
$check(str_contains($adminTpl, 'layoutsRejected'), 'admin renders discovery rejections');
$check(str_contains($adminTpl, '>Custom</span>'), 'admin badges custom layouts');

$check(!is_file($tpl . '/core/layouts/main-menu/top/default.tpl')
    && !is_file($tpl . '/core/layouts/main-menu/sidebar/default.tpl'),
    'the dead decoy templates are gone');

/* ---- report -------------------------------------------------------------- */

echo "  {$oks} check(s) passed\n";
if ($fails) {
    echo "  " . count($fails) . " FAILED:\n";
    foreach ($fails as $f) { echo "   - {$f}\n"; }
    exit(1);
}
echo "  All checks passed.\n";

}
