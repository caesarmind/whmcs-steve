<?php
/**
 * Every setting on the Settings page must have its own block in the docs.
 *
 * The Settings article documents one setting per ### heading, and the admin's
 * "Learn more" tooltips deep-link to those headings by id. A setting added to
 * SettingsController::FLAGS with no corresponding heading ships a control
 * nobody can look up - and the failure is silent, because the tooltip still
 * renders and just drops the reader at the top of the page.
 *
 * This reads the REAL constants off the REAL controller (with a stubbed
 * AbstractController, the same trick the admin harnesses use) and slugifies
 * each label exactly the way scripts/build-docs.mjs does, then requires a
 * matching heading in the article source.
 *
 *   php tests/static/check-settings-doc-coverage.php   -> exit 0 / 1 + list
 */

namespace Hadrian\Controller {
    /** Stub. Only exists so the real controller class can be declared. */
    abstract class AbstractController {}
}

namespace {

$root = dirname(__DIR__, 2);
$admin = $root . '/hadrian/modules/addons/Hadrian';
$article = $root . '/hadrian-documentation/content/client-theme/03a-settings.md';

require $admin . '/src/Controller/Admin/SettingsController.php';

/** Mirror of slugify() in scripts/build-docs.mjs. Keep the two in step. */
function docSlug(string $s): string
{
    $s = mb_strtolower($s, 'UTF-8');
    $s = preg_replace('/[\x{2018}\x{2019}\x{201C}\x{201D}]/u', '', $s); // curly quotes vanish
    $s = preg_replace('/[^a-z0-9]+/u', '-', $s);
    return trim((string)$s, '-');
}

$md = file_get_contents($article);
$headings = [];
foreach (explode("\n", $md) as $line) {
    if (preg_match('/^###?\s+(.+?)\s*$/', $line, $m)) {
        $headings[docSlug($m[1])] = trim($m[1]);
    }
}

$fails = [];
$oks   = 0;

/* ---- 1. Every toggle the Settings page renders ------------------------- */

$flags = Hadrian\Controller\Admin\SettingsController::settingsPageFlags();
if (count($flags) < 10) {
    $fails[] = 'settingsPageFlags() returned ' . count($flags) . ' flags - the constant probably moved';
}
foreach ($flags as $key => $meta) {
    $label = (string)$meta[0];
    $slug  = docSlug($label);
    if (isset($headings[$slug])) {
        $oks++;
    } else {
        $fails[] = "flag '{$key}' (\"{$label}\") has no ### heading - expected id \"{$slug}\"";
    }
}

/* ---- 2. The Order Process settings, which are not FLAGS ---------------- */

/* Labels are written into settings/index.tpl by hand (they carry sub-fields
   and enums, so they never became FLAGS rows). Read them back OUT of the
   template rather than restating them here, so a renamed row is caught. */
$tpl = file_get_contents($admin . '/views/adminarea/settings/index.tpl');
$opLabels = [];
foreach ([
    'Hide Product Nameservers',
    'Hide Product Hostname',
    'Use Custom Hostname',
    'Hide on Checkout page',
    'Enable Password Strength For Root Password Field',
] as $label) {
    if (!str_contains($tpl, '>' . $label . ' ') && !str_contains($tpl, '>' . $label . '<')) {
        $fails[] = "Order Process row \"{$label}\" is not in settings/index.tpl any more - update this check";
        continue;
    }
    $opLabels[] = $label;
}
foreach ($opLabels as $label) {
    $slug = docSlug($label);
    if (isset($headings[$slug])) {
        $oks++;
    } else {
        $fails[] = "Order Process setting \"{$label}\" has no ### heading - expected id \"{$slug}\"";
    }
}

/* ---- 3. Anchors the admin hard-codes must exist too -------------------- */

preg_match_all('/anchor="([a-z0-9-]+)"/', $tpl, $mLiteral);
preg_match_all("/\{assign\s+var=\w*[Aa]nchor\s+value='([a-z0-9-]+)'\}/", $tpl, $mAssigned);
$anchors = array_values(array_unique(array_merge($mLiteral[1], $mAssigned[1])));
foreach ($anchors as $anchor) {
    if (isset($headings[$anchor])) {
        $oks++;
    } else {
        $fails[] = "admin links #{$anchor} but the article has no heading with that id";
    }
}

echo "  {$oks} check(s) passed (" . count($flags) . " flags, " . count($opLabels) . " order-process rows)\n";
if ($fails) {
    echo "  " . count($fails) . " FAILED:\n";
    foreach ($fails as $f) { echo "   - {$f}\n"; }
    exit(1);
}
echo "  All checks passed.\n";

}
