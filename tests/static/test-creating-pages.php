<?php
/**
 * Functional test for the "Creating Pages" recipe (docs 07c-creating-pages.md).
 *
 * The docs claim a four-file recipe; this proves the three theme-side files
 * work through the REAL code paths, not by reading them:
 *
 *   1. discovery   - a new core/pages/<name>/ dir is picked up by the real
 *                    PagesCache signature invalidation against a STALE stored
 *                    cache (the "no version bump" claim), and Template::
 *                    getPageMeta / getPageVariants read its page.php + variants.
 *   2. dispatcher  - a renamed copy of custom-page.tpl compiles and renders
 *                    through real Smarty: the admin-selected-variant branch,
 *                    the no-addon fallback branch, and the documented
 *                    dot-notation-with-hyphen failure.
 *
 * The fixture page is DELIBERATELY hyphenated (test-about) because that is the
 * case the bracket-form warning exists for.
 *
 * The fourth file - the WHMCS-root entry .php - cannot run without WHMCS;
 * its chain is proven by the shipped example live at /custom-page.php.
 *
 * Self-contained: creates its fixtures, always deletes them (finally), exits
 * non-zero on any failure. Never leaves test files for a deploy to sweep up.
 *
 *   php tests/static/test-creating-pages.php
 */

namespace Hadrian\Models {
    /** In-memory stand-in for the hadrian_settings row PagesCache persists to. */
    final class Settings
    {
        public static array $store = [];
        public static function getValue(string $key, $default = null)
        {
            return self::$store[$key] ?? $default;
        }
        public static function setValue(string $key, $value): void
        {
            self::$store[$key] = $value;
        }
    }
}

namespace {

use Hadrian\Models\Settings;
use Hadrian\Template\PagesCache;
use Hadrian\Template\Template;

$root  = dirname(__DIR__, 2);
$admin = $root . '/hadrian/modules/addons/Hadrian';
$theme = $root . '/hadrian/templates/hadrian';

/* Smarty, installed by Composer beside this file: composer install -d tests/static */
if (!is_file(__DIR__ . '/vendor/autoload.php')) {
    fwrite(STDERR, "Smarty is not installed - run: composer install -d tests/static\n");
    exit(2);
}
require __DIR__ . '/vendor/autoload.php';
/* The anti-tamper hash table is a gitignored build artifact; load it the way
   the addon does (hooks.php) - the real one when present, the tracked stub
   otherwise. A checker that needed the generated file only ran on one machine. */
require is_file($admin . '/src/Helpers/IntegrityHashes.php')
    ? $admin . '/src/Helpers/IntegrityHashes.php'
    : $admin . '/src/Helpers/IntegrityHashes.fallback.php';
require $admin . '/src/Helpers/ThemeManifest.php';
// Template::getPages() also lists pages an extension module adds; none is
// registered here, so the list is the theme's own.
require $admin . '/src/Helpers/PageArea.php';
require $admin . '/src/Helpers/ExtensionPages.php';
require $admin . '/src/Template/PagesCache.php';
require $admin . '/src/Template/Template.php';

$SLUG = 'test-about';
$pageDir = $theme . '/core/pages/' . $SLUG;
$dispatcher = $theme . '/' . $SLUG . '.tpl';

$failures = [];
$pass = function (string $what) { echo "  ok    {$what}\n"; };
$fail = function (string $what) use (&$failures) { echo "  FAIL  {$what}\n"; $failures[] = $what; };

/** PagesCache memoises per request; between phases we are simulating separate
 *  admin visits, so the memo must be dropped the way a new request drops it. */
$clearMemo = function (): void {
    $p = new ReflectionProperty(PagesCache::class, 'memo');
    $p->setAccessible(true);
    $p->setValue(null, []);
};

$rmTree = function (string $dir) use (&$rmTree): void {
    if (!is_dir($dir)) return;
    foreach (scandir($dir) ?: [] as $e) {
        if ($e === '.' || $e === '..') continue;
        $p = $dir . '/' . $e;
        is_dir($p) ? $rmTree($p) : unlink($p);
    }
    rmdir($dir);
};

try {
    // -- Phase A: baseline scan, and keep it as the STALE stored cache ------
    $t = new Template('hadrian');
    $before = PagesCache::ensure($t);
    in_array($SLUG, $before, true)
        ? $fail("baseline already contains {$SLUG} - stale fixtures on disk?")
        : $pass('baseline scan does not contain ' . $SLUG);

    // -- Phase B: create the three theme-side files of the recipe -----------
    mkdir($pageDir . '/default', 0777, true);
    mkdir($pageDir . '/landing', 0777, true);
    file_put_contents($pageDir . '/page.php', <<<'PHP'
<?php
return [
    'display_name' => 'Test About',
    'group'        => 'Public',
    'description'  => 'Fixture page created by test-creating-pages.php.',
];
PHP);
    file_put_contents($pageDir . '/default/default.tpl', '<p>MARKER-DEFAULT-BODY</p>');
    file_put_contents($pageDir . '/landing/landing.tpl', '<p>MARKER-LANDING-BODY</p>');
    file_put_contents($pageDir . '/landing/landing.php', <<<'PHP'
<?php
return ['name' => 'Landing', 'description' => 'Fixture variant.', 'fullPage' => true];
PHP);

    // The docs' step 2: copy the shipped dispatcher, replace EVERY custom-page.
    $src = file_get_contents($theme . '/custom-page.tpl');
    file_put_contents($dispatcher, str_replace('custom-page', $SLUG, $src));

    // -- Phase C: discovery against the stale cache (new admin visit) -------
    $clearMemo();
    $after = PagesCache::ensure($t);   // stored payload is phase-A's - signature must invalidate it
    in_array($SLUG, $after, true)
        ? $pass('PagesCache signature invalidation discovered the new page (no version bump)')
        : $fail('PagesCache did not discover the new page against a stale stored cache');

    in_array($SLUG, $t->getPages(), true)
        ? $pass('Template::getPages() lists the page')
        : $fail('Template::getPages() does not list the page');

    $meta = $t->getPageMeta($SLUG);
    ($meta['display_name'] ?? '') === 'Test About'
        ? $pass("page.php read: display_name 'Test About'")
        : $fail('page.php display_name not read: ' . var_export($meta['display_name'] ?? null, true));

    $variants = $t->getPageVariants($SLUG);
    $names = array_column($variants, 'key') ?: array_keys($variants);
    $flat = json_encode($variants);
    (str_contains($flat, 'default') && str_contains($flat, 'landing'))
        ? $pass('both variants discovered (default, landing)')
        : $fail('variants missing from getPageVariants: ' . $flat);

    $vmeta = $t->getVariantMeta($SLUG, 'landing');
    (!empty($vmeta['fullPage']))
        ? $pass('landing/landing.php read: fullPage=true honoured by getVariantMeta')
        : $fail('variant meta fullPage not read: ' . json_encode($vmeta));

    // -- Phase D: the renamed dispatcher through real Smarty ----------------
    // file_exists("templates/...") in the dispatcher resolves from the WHMCS
    // root; hadrian/ plays that role here (it contains templates/hadrian).
    chdir($root . '/hadrian');

    $smarty = new Smarty();
    $smarty->setTemplateDir($root . '/hadrian/templates');
    $smarty->setCompileDir(sys_get_temp_dir() . '/hadrian-cp-test-compile');
    $smarty->caching = false;
    $smarty->force_compile = true;
    $smarty->error_reporting = 0;

    // (a) admin picked the landing variant -> resolveCurrentPage's fullPath shape
    $smarty->assign([
        'template' => 'hadrian',
        'hadrian'  => ['pages' => [$SLUG => [
            'fullPath' => "hadrian/core/pages/{$SLUG}/landing/landing.tpl",
        ]]],
    ]);
    $out = $smarty->fetch('hadrian/' . $SLUG . '.tpl');
    str_contains($out, 'MARKER-LANDING-BODY')
        ? $pass('dispatcher renders the admin-selected variant via fullPath')
        : $fail('dispatcher did not follow fullPath: ' . substr($out, 0, 120));

    // (b) addon absent -> fallback include of default/default.tpl
    $smarty->clearAllAssign();
    $smarty->assign('template', 'hadrian');
    $out = $smarty->fetch('hadrian/' . $SLUG . '.tpl');
    str_contains($out, 'MARKER-DEFAULT-BODY')
        ? $pass('dispatcher falls back to default/default.tpl without the addon payload')
        : $fail('dispatcher fallback broken: ' . substr($out, 0, 120));

    // (c) the documented footgun: dot notation + hyphenated slug
    $smarty->assign('hadrian', ['pages' => [$SLUG => ['fullPath' => 'x']]]);
    try {
        $out = $smarty->fetch("string:{\$hadrian.pages.{$SLUG}.fullPath}");
        // Smarty parses `test-about` as `test - about`: no error, wrong value.
        trim($out) === 'x'
            ? $fail('dot notation unexpectedly WORKED with a hyphenated slug - docs warning wrong?')
            : $pass('dot notation with a hyphenated slug silently yields garbage (docs warning correct)');
    } catch (\Throwable $e) {
        $pass('dot notation with a hyphenated slug fails to compile (docs warning correct)');
    }
} finally {
    // -- Cleanup: never leave fixtures for a deploy or another session ------
    @unlink($dispatcher);
    $rmTree($pageDir);
}

$left = array_filter([$dispatcher, $pageDir], fn ($p) => file_exists($p));
$left === []
    ? $pass('fixtures removed')
    : $fail('fixtures LEFT BEHIND: ' . implode(', ', $left));

echo $failures === [] ? "\n  all checks passed\n" : "\n  " . count($failures) . " FAILURE(S)\n";
exit($failures === [] ? 0 : 1);

}
