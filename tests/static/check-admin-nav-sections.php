<?php
/**
 * Hadrian's admin sections are listed in two places:
 *   - views/adminarea/includes/header.tpl, the top-nav tabs (hand-written,
 *     because Hadrian's extension modules and the .dashbuild harnesses render
 *     that header with their own ViewHelper)
 *   - ViewHelper::SECTIONS, which hooks.php reads to build the flyout under
 *     WHMCS's Addons > Hadrian menu entry
 * This fails when the two disagree on which sections there are, their labels
 * or their order, so a new tab cannot be missing from the flyout.
 *
 *   php tests/static/check-admin-nav-sections.php
 */

$root   = dirname(__DIR__, 2) . '/hadrian/modules/addons/Hadrian';
$header = (string) file_get_contents($root . '/views/adminarea/includes/header.tpl');
require_once $root . '/src/View/ViewHelper.php';

// Every Hadrian tab: <a ... href="{$viewHelper->url('x')}">Label</a>
preg_match_all('/href="\{\$viewHelper->url\(\'([a-z]+)\'\)\}">([^<]+)<\/a>/', $header, $m, PREG_SET_ORDER);
$tabs = [];
foreach ($m as $hit) {
    $tabs[] = $hit[1] . '=' . trim($hit[2]);
}

$want = [];
foreach (\Hadrian\View\ViewHelper::SECTIONS as $action => $label) {
    $want[] = $action . '=' . $label;
}

$fails = 0;
if ($tabs === []) {
    echo "FAIL  no tabs found in header.tpl: has its markup changed? Update the pattern here.\n";
    $fails++;
} elseif ($tabs !== $want) {
    echo "FAIL  header.tpl tabs and ViewHelper::SECTIONS differ\n";
    echo '      header.tpl: ' . implode(', ', $tabs) . "\n";
    echo '      SECTIONS:   ' . implode(', ', $want) . "\n";
    $fails++;
}

// The extension-module tabs sit just in front of Extensions in both lists:
// the flyout puts the modules under its Extensions heading.
$loop = strpos($header, '{foreach $mtExtensions');
$ext  = strpos($header, "url('extensions')");
$prev = strpos($header, "url('branding')");
if ($loop === false || $ext === false || $prev === false || !($prev < $loop && $loop < $ext)) {
    echo "FAIL  header.tpl: the extension-module tabs are no longer between Branding and Extensions\n";
    $fails++;
}

echo $fails === 0
    ? count($want) . " sections match in header.tpl and ViewHelper::SECTIONS\n"
    : "$fails problem(s)\n";
exit($fails === 0 ? 0 : 1);
