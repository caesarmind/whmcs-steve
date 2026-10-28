<?php
/**
 * Checks for the theme translation loader + locale helpers, no WHMCS needed.
 *
 * Exercises the REAL Hooks::loadLanguage (via reflection - it only touches
 * the template path and pure PHP) against the REAL theme tree, with throwaway
 * fixture files created in core/lang/ and cleaned up afterwards. Proves the
 * three-layer merge semantics the Languages docs describe:
 *
 *   english.php  <-per-key-  <language>.php  <-per-key-  overrides/<language>.php
 *
 *   php tests/static/check-lang-loading.php   -> exit 0 all good / 1 + list
 */

$root  = dirname(__DIR__, 2);
$admin = $root . '/hadrian/modules/addons/Hadrian';
$tpl   = $root . '/hadrian/templates/hadrian';

/* The anti-tamper hash table is a gitignored build artifact; load it the way
   the addon does (hooks.php) - the real one when present, the tracked stub
   otherwise. A checker that needed the generated file only ran on one machine. */
require is_file($admin . '/src/Helpers/IntegrityHashes.php')
    ? $admin . '/src/Helpers/IntegrityHashes.php'
    : $admin . '/src/Helpers/IntegrityHashes.fallback.php';
require $admin . '/src/Helpers/ThemeManifest.php';
require $admin . '/src/Helpers/LocaleHelper.php';
require $admin . '/src/Template/Template.php';
require $admin . '/src/Template/PagesCache.php';
require $admin . '/src/Template/LayoutsCache.php';
/* Hooks itself: plain `final class Hooks` with no parent, so the class LOADS
   without WHMCS - its heavier dependencies only matter when methods touching
   them are invoked, and loadLanguage touches none of them. */
require $admin . '/src/Service/Hooks.php';

$fails = [];
$oks   = 0;
$check = function (bool $cond, string $what) use (&$fails, &$oks): void {
    if ($cond) { $oks++; } else { $fails[] = $what; }
};

/* ---- fixtures ------------------------------------------------------------ */

$langDir = $tpl . '/core/lang';
$ovrDir  = $langDir . '/overrides';
@mkdir($ovrDir, 0777, true);

/* A PARTIAL translation: one real key translated, everything else omitted. */
file_put_contents($langDir . '/zzcheck.php', "<?php\nreturn ['common' => ['localeChoose' => 'ZZ-TRANSLATED']];\n");
/* An override layer: beats the translation on one key, mints a new group. */
file_put_contents($ovrDir . '/zzcheck.php', "<?php\nreturn ['common' => ['localeChoose' => 'ZZ-OVERRIDDEN'], 'zzgroup' => ['zzkey' => 'ZZ-MINTED']];\n");
/* A deliberately broken override for a second language. */
file_put_contents($langDir . '/zzbroken.php', "<?php\nreturn ['common' => ['localeChoose' => 'ZZB-TRANSLATED']];\n");
file_put_contents($ovrDir . '/zzbroken.php', "<?php\nthis is not php at all {{{\n");

$cleanup = function () use ($langDir, $ovrDir): void {
    @unlink($langDir . '/zzcheck.php');
    @unlink($langDir . '/zzbroken.php');
    @unlink($ovrDir . '/zzcheck.php');
    @unlink($ovrDir . '/zzbroken.php');
    @rmdir($ovrDir); // only removes it if the buyer-style dir is otherwise empty
};

try {
    $template = new Hadrian\Template\Template('hadrian');
    $hooks    = (new ReflectionClass(Hadrian\Service\Hooks::class))->newInstanceWithoutConstructor();
    $load     = new ReflectionMethod(Hadrian\Service\Hooks::class, 'loadLanguage');
    $load->setAccessible(true);
    $lang     = fn (string $code): array => $load->invoke($hooks, $template, $code);

    $english = $lang('english');
    $check(($english['common']['localeChoose'] ?? '') !== '', 'english.php loads and has common.localeChoose');
    $englishValue = $english['common']['cookieMessage'] ?? '';
    $check($englishValue !== '', 'english.php has common.cookieMessage (the fallback probe)');

    $zz = $lang('zzcheck');
    $check(($zz['common']['localeChoose'] ?? '') === 'ZZ-OVERRIDDEN',
        'overrides/<lang>.php wins over <lang>.php on the same key');
    $check(($zz['common']['cookieMessage'] ?? '') === $englishValue,
        'a key MISSING from a partial translation falls back to English per-key');
    $check(($zz['zzgroup']['zzkey'] ?? '') === 'ZZ-MINTED',
        'an override file can mint brand-new strings');

    $zzb = $lang('zzbroken');
    $check(($zzb['common']['localeChoose'] ?? '') === 'ZZB-TRANSLATED',
        'a syntax-broken override is ignored, the translation still applies');
    $check(($zzb['common']['cookieMessage'] ?? '') === $englishValue,
        'a syntax-broken override does not poison the English base');

    $evil = $lang('../../evil');
    $check(($evil['common']['localeChoose'] ?? '') === ($english['common']['localeChoose'] ?? '-'),
        'a non-token language name is coerced to english (path guard)');

    $missing = $lang('zzmissing');
    $check($missing === $english, 'a missing language falls back to English wholesale');

    /* ---- locale helpers -------------------------------------------------- */

    $check(Hadrian\Helpers\LocaleHelper::flagFor('french') === "\u{1F1EB}\u{1F1F7}", 'flagFor(french) is the FR flag');
    $check(Hadrian\Helpers\LocaleHelper::flagFor('nonsense') === "\u{1F310}", 'flagFor(unknown) is the globe');
    $check(Hadrian\Helpers\LocaleHelper::nativeName('french') === "Fran\u{e7}ais", 'nativeName(french) is Francais');
    $check(Hadrian\Helpers\LocaleHelper::nativeName('klingon') === 'Klingon', 'nativeName(unknown) falls back to ucfirst');
    $names = Hadrian\Helpers\LocaleHelper::nativeNamesFor(['english', 'German']);
    $check(($names['german'] ?? '') === 'Deutsch', 'nativeNamesFor lowercases keys and maps values');

    /* ---- the render sites use the new data ------------------------------- */

    $btn = file_get_contents($tpl . '/includes/partials/locale-btn.tpl');
    $check(str_contains($btn, 'nativeNames'), 'locale button renders the native name');
    $modal = file_get_contents($tpl . '/includes/partials/locale-modal.tpl');
    $check(str_contains($modal, 'nativeNames'), 'locale modal renders native names');
    $hooksSrc = file_get_contents($admin . '/src/Service/Hooks.php');
    $check(str_contains($hooksSrc, "'localeFlag'"), 'Hooks assigns hadrian.localeFlag');
    $check(str_contains($hooksSrc, "'nativeNames'"), 'Hooks exposes locales.nativeNames');
} finally {
    $cleanup();
}

/* ---- report -------------------------------------------------------------- */

echo "  {$oks} check(s) passed\n";
if ($fails) {
    echo "  " . count($fails) . " FAILED:\n";
    foreach ($fails as $f) { echo "   - {$f}\n"; }
    exit(1);
}
echo "  All checks passed.\n";
