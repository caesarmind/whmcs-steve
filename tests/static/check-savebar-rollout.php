<?php
/**
 * Compile + structure check for the floating save bar rollout.
 *
 * Renders every admin template that includes includes/savebar.tpl through REAL
 * Smarty and asserts, for each:
 *   - it compiles at all (a Smarty error here would fall the page back to Six
 *     in production, and that is not recoverable by revert)
 *   - exactly ONE .mt-savebar is emitted
 *   - the bar is INSIDE a <form> (so a bare type=submit hits the right form)
 *   - no orphaned inline save button was left behind
 *
 * Undefined view vars render empty on purpose: this checks STRUCTURE, not
 * content. The settings page has a full model of its own in
 * .dashbuild/build-settings-admin-harness.php.
 *
 *   php tests/static/check-savebar-rollout.php
 */

namespace Hadrian\Controller { abstract class AbstractController {} }

namespace {

$root  = dirname(__DIR__, 2);
$views = $root . '/hadrian/modules/addons/Hadrian/views/adminarea';
require __DIR__ . '/vendor/autoload.php';

$targets = [];
foreach (new RecursiveIteratorIterator(new RecursiveDirectoryIterator($views)) as $f) {
    if ($f->getExtension() !== 'tpl') continue;
    $src = file_get_contents($f->getPathname());
    // Match a real {include file="includes/savebar.tpl" ...}, not any mention of
    // the path: footer.tpl names it in a JS comment and was being "checked" as
    // a savebar page with zero bars.
    if (!preg_match('/\{include\s[^}]*includes\/savebar\.tpl/', $src)) continue;
    if (strpos($f->getPathname(), 'includes' . DIRECTORY_SEPARATOR . 'savebar.tpl') !== false) continue;
    $targets[] = str_replace('\\', '/', substr($f->getPathname(), strlen($views) + 1));
}
sort($targets);

$viewHelper = new class {
    public function url(string $a, array $p = []): string { return '?module=Hadrian&action=' . $a; }
};
// $menu->location is dereferenced in menu/edit.tpl's cancel URL.
$menu = new class { public $location = 'primary'; public $name = 'Main'; public $active = 1; public $id = 1; };

$fails = 0;
foreach ($targets as $t) {
    $s = new Smarty();
    $s->setTemplateDir($views);
    $s->setCompileDir(sys_get_temp_dir() . '/hadrian-savebar-compile');
    $s->force_compile = true;
    $s->error_reporting = E_ALL & ~E_NOTICE & ~E_WARNING & ~E_DEPRECATED;
    // Per-template overrides. Two templates only render their save form under a
    // specific view state, and a checker that quietly renders the OTHER branch
    // reports "no save bar" as a template fault instead of a model gap -- which
    // is the harness lying, the failure mode this whole file exists to avoid.
    $overrides = [
        // The Custom CSS form is behind {if $tab == 'custom-css'}.
        'styles/edit.tpl' => ['tab' => 'custom-css'],
        // in_array() over the language list; null would fatal before the bar.
        'settings/index.tpl' => [
            'installedLanguages' => ['english', 'french'],
            'selectedLanguages'  => ['english'],
            'opHideNsGroups' => [], 'opHideHostGroups' => [], 'opCustomHostnameChars' => [],
            'productGroups' => [], 'orderPages' => [], 'websitePages' => [],
            'subnavOrderList' => [], 'subnavWebsiteList' => [], 'svcPages' => [],
            'svcLayoutList' => [], 'cookieBoxMessages' => [], 'values' => [],
            'flags' => [], 'flagGroups' => [], 'flagTabs' => [], 'searchTerms' => [],
        ],
    ];

    $s->assign(array_merge([
        'viewHelper' => $viewHelper, 'menu' => $menu, 'style' => 'default',
        'styleName' => 'Default', 'tab' => 'general', 'subcat' => 'colors',
        'currentAction' => 'settings', 'cfg' => ['robots' => true],
        'colors' => ['mode' => 'light', 'presets' => [], 'groups' => [], 'sbStyles' => [],
                     'navGroup' => '', 'accents' => ['light' => '#0071e3', 'dark' => '#2997ff']],
    ], $overrides[$t] ?? []));

    try {
        $out = $s->fetch($t);
    } catch (Throwable $e) {
        echo "FAIL  {$t}\n      compile/render: " . $e->getMessage() . "\n";
        $fails++;
        continue;
    }

    $bars = substr_count($out, 'class="mt-savebar"');
    // Is the bar inside a <form>? Count form open/close before the bar.
    $pos    = strpos($out, 'class="mt-savebar"');
    $before = $pos === false ? '' : substr($out, 0, $pos);
    $opens  = preg_match_all('/<form\b/i', $before);
    $closes = substr_count(strtolower($before), '</form>');
    $inForm = $pos !== false && $opens > $closes;

    // Any inline save button left behind outside the bar?
    $stray = preg_match_all('/<button[^>]*type="submit"[^>]*>\s*Save/i', $out)
           - preg_match_all('/mt-savebar[\s\S]{0,400}?<button[^>]*type="submit"[^>]*>\s*Save/i', $out);

    $ok = ($bars === 1 && $inForm && $stray <= 0);
    if (!$ok) $fails++;
    printf("%-5s %-28s bars=%d inForm=%s strayInlineSave=%d\n",
        $ok ? 'ok' : 'FAIL', $t, $bars, $inForm ? 'yes' : 'NO', max(0, $stray));
}

echo "\n" . count($targets) . " templates checked, {$fails} failing\n";
exit($fails ? 1 : 0);

}
