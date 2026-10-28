<?php
/**
 * Does a style card's swatch reflect the buyer's saved colours?
 *
 * Calls the REAL StylesController::buildStyleSwatch() (via reflection, it is
 * private) against a stubbed Settings store, so the precedence under test is
 * the shipped one. It used to read the style manifest and the colors.php schema
 * only, which is why changing colours in Customize > Colors never moved the
 * card.
 *
 * The per-style isolation case is the one that matters most: the swatch is
 * built in a loop over every style, so a lookup keyed on the wrong name would
 * paint every card with the active style's colours.
 *
 *   php tests/static/check-style-swatch.php
 */

namespace Hadrian\Controller {
    abstract class AbstractController { public function __construct(array $p = []) {} }
}

namespace Hadrian\Models {
    class Settings
    {
        public static array $store = [];
        public static function getValue(string $key, $default = null)
        {
            return self::$store[$key] ?? $default;
        }
        public static function setValue(string $key, $value): void { self::$store[$key] = $value; }
    }
}

namespace {

$root  = dirname(__DIR__, 2);
$admin = $root . '/hadrian/modules/addons/Hadrian';

require $admin . '/src/Helpers/ThemeManifest.php';
require $admin . '/src/Controller/Admin/StylesController.php';

use Hadrian\Models\Settings;

$template = new class ($root) {
    public function __construct(private string $root) {}
    public function getFullPath(): string { return $this->root . '/hadrian/templates/hadrian'; }
    public function getName(): string { return 'hadrian'; }
};

$ctl = new \Hadrian\Controller\Admin\StylesController();
$m   = new ReflectionMethod($ctl, 'buildStyleSwatch');
$m->setAccessible(true);

function meta(string $root, string $style): array
{
    $p = $root . '/hadrian/templates/hadrian/core/styles/' . $style . '/style.php';
    return file_exists($p) ? (array)(require $p) : [];
}

$swatch = fn ($style) => $m->invoke($ctl, $template, meta($root, $style), $style);

$fails = 0;
$check = function (string $what, $got, $expect) use (&$fails) {
    $ok = $got === $expect;
    if (!$ok) { $fails++; }
    printf("%-5s %-46s got=%-22s expected=%s\n", $ok ? 'ok' : 'FAIL', $what, var_export($got, true), var_export($expect, true));
};

/* 1. No overrides -> the shipped look, unchanged. */
Settings::$store = [];
$base = $swatch('default');
printf("baseline default swatch: primary=%s accent=%s\n\n", $base['primary'], $base['accent']);
$check('baseline is a real colour', $base['primary'] !== 'transparent', true);

/* 2. A saved LIGHT accent must reach the card. */
Settings::$store = ['hadrian_colors_default_light' => ['--color-accent' => '#7c3aed']];
$after = $swatch('default');
$check('saved light accent reaches the swatch', in_array('#7c3aed', [$after['primary'], $after['accent']], true), true);

/* 3. The pre-refactor key name is honoured too (same order as buildColorsHead). */
Settings::$store = ['hadrian_colors_default' => ['--color-accent' => '#00988f']];
$legacy = $swatch('default');
$check('legacy key honoured', in_array('#00988f', [$legacy['primary'], $legacy['accent']], true), true);

/* 4. PER-STYLE ISOLATION. An override saved for one style must not paint
      another style's card -- the swatch is built in a loop over all of them. */
Settings::$store = ['hadrian_colors_emerald_light' => ['--color-accent' => '#ff2d55']];
$defaultCard  = $swatch('default');
$emeraldCard = $swatch('emerald');
$check('emerald override does NOT touch default card', in_array('#ff2d55', [$defaultCard['primary'], $defaultCard['accent']], true), false);
$check('emerald override DOES touch emerald card',      in_array('#ff2d55', [$emeraldCard['primary'], $emeraldCard['accent']], true), true);

/* 5. THE CONTRACT: every card is surface-then-accent, and no card is ever one
      colour twice. The dark scope is not consulted at all -- a style is its
      light palette; dark is a mode applied on top. */
Settings::$store = [];
$dir = $root . '/hadrian/templates/hadrian/core/styles';
$seen = 0;
foreach (scandir($dir) as $s) {
    if ($s[0] === '.' || !file_exists("$dir/$s/style.php")) { continue; }
    $meta = (array)(require "$dir/$s/style.php");
    if ((($meta['variables']['colorMode'] ?? 'light') === 'dark')) { continue; }  // not an activatable style
    $sw = $m->invoke($ctl, $template, $meta, $s);
    $light = (array)($meta['colors']['light'] ?? []);
    $expectFirst = (string)($light['--sidebar-bg'] ?? $light['--color-bg'] ?? '#fbfbfd');
    $check("{$s}: first half is its surface", $sw['primary'], $expectFirst);
    $check("{$s}: two distinct halves",       $sw['primary'] !== $sw['accent'], true);
    $seen++;
}
$check('all activatable styles covered', $seen, 6);

/* ...including the case that started this: one accent for both modes. */
Settings::$store = ['hadrian_colors_default_light' => ['--color-accent' => '#7c3aed'],
                    'hadrian_colors_default_dark'  => ['--color-accent' => '#7c3aed']];
$same = $swatch('default');
$check('identical light/dark accent still gives two colours', $same['primary'] !== $same['accent'], true);
$check('  ...with the accent on the right', $same['accent'], '#7c3aed');
printf("      -> primary=%s accent=%s\n", $same['primary'], $same['accent']);

/* 6. Garbage stays out of the style="" attribute. The accent is the right-hand
      half now, so that is where a poisoned --color-accent lands; the surface on
      the left stays a real colour. */
Settings::$store = ['hadrian_colors_default_light' => ['--color-accent' => 'url(javascript:alert(1))']];
$evil = $swatch('default');
$check('non-colour accent dropped to transparent', $evil['accent'], 'transparent');
$check('  ...and the surface half is unaffected',  $evil['primary'], '#fbfbfd');

/* ...and a poisoned SURFACE is dropped too. */
Settings::$store = ['hadrian_colors_default_light' => ['--color-bg' => 'url(javascript:alert(1))']];
$evil2 = $swatch('default');
$check('non-colour surface dropped to transparent', $evil2['primary'], 'transparent');

echo "\n{$fails} failing\n";
exit($fails ? 1 : 0);

}
