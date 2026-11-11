<?php
/**
 * Harness for the Colors panel, through REAL Smarty.
 *
 * .dashbuild/build-colors-admin-harness.mjs renders this same template through a JS subset
 * of Smarty, and that subset does not implement {include} or evaluate a
 * compound {if} on a view-model field -- so it silently drew the ELSE branch and
 * no tooltip at all, which looks exactly like the shipped template being broken.
 * A harness that cannot run the construct under test cannot report on it.
 *
 * This one calls the REAL StylesController::buildColorsViewModel() against a
 * stubbed Settings store and renders the REAL _colors.tpl through real Smarty,
 * so {include file="includes/tip.tpl"} and the select branch either work or the
 * render fails loudly.
 *
 *   php tests/static/check-colors-panel.php   -> tests/.local/adminpreview/colorspanel.html
 */

namespace Hadrian\Controller {
    abstract class AbstractController { public function __construct(array $p = []) {} }
}

namespace Hadrian\Models {
    class Settings {
        public static array $store = [];
        public static function getValue(string $k, $d = null) { return self::$store[$k] ?? $d; }
        public static function setValue(string $k, $v, string $t = ''): void { self::$store[$k] = $v; }
        public static function deleteValue(string $k): void { unset(self::$store[$k]); }
    }
}

namespace {

$root  = dirname(__DIR__, 2);
$admin = $root . '/hadrian/modules/addons/Hadrian';
$views = $admin . '/views/adminarea';

require __DIR__ . '/vendor/autoload.php';
require $admin . '/src/Helpers/ThemeManifest.php';
require $admin . '/src/Controller/Admin/StylesController.php';

use Hadrian\Models\Settings;

$template = new class ($root) {
    public function __construct(private string $root) {}
    public function getFullPath(): string { return $this->root . '/hadrian/templates/hadrian'; }
    public function getName(): string { return 'hadrian'; }
    public function getStyles(): array { return ['default']; }
    public function resolveStyleName(string $s): string { return 'default'; }
};

/* A saved GRADIENT, so the panel is rendered in the state the report is about:
   values stored, and the question being which chip the panel then claims. */
Settings::$store = ['hadrian_colors_default_light' => [
    '--sidebar-bg'        => '#0051a3',
    '--sidebar-panel-bg'  => '#0051a3',
    '--sidebar-grad-from' => '#0051a3',
    '--sidebar-grad-to'   => '#002d5b',
    '--sidebar-grad-angle'=> '135deg',
]];

$ctl = new \Hadrian\Controller\Admin\StylesController();
$m   = new ReflectionMethod($ctl, 'buildColorsViewModel');
$m->setAccessible(true);
$colors = $m->invoke($ctl, $template, 'default', 'light');

$smarty = new Smarty();
$smarty->setTemplateDir($views);
$smarty->setCompileDir(sys_get_temp_dir() . '/hadrian-colors-harness');
$smarty->setCacheDir(sys_get_temp_dir() . '/hadrian-colors-harness-cache');
$smarty->caching = false;
$smarty->assign([
    'colors'         => $colors,
    'style'          => 'default',
    'styleName'      => 'Default',
    'colorsSaved'    => false,
    'presetRestored' => false,
]);

$body = $smarty->fetch('styles/_colors.tpl');

$css = file_get_contents($views . '/assets/css/admin.css');
/* .mt-wrap is load-bearing, not decoration: admin.css hangs the ENTIRE --mt-*
   custom-property set AND the admin font off that one class. Rendering the
   panel without it silently produced Times New Roman with every colour
   variable unresolved -- which still looks like a plausible page, and shipped
   that way into eleven published docs screenshots. data-theme picks the light
   palette, exactly as includes/header.tpl emits it. */
$html = "<!doctype html><html><head><meta charset=\"utf-8\"><title>colors panel</title>\n"
      . "<style>{$css}</style>\n<style>body{margin:0;padding:16px;background:#f5f5f7}</style>\n"
      . "</head><body class=\"mt-wrap\" data-theme=\"light\">\n{$body}\n</body></html>";

@mkdir($root . '/tests/.local/adminpreview', 0777, true);
file_put_contents($root . '/tests/.local/adminpreview/colorspanel.html', $html);

/* Assert on the RENDERED markup, so a silent template regression fails here. */
$fails = 0;
$check = function (string $what, bool $ok, string $detail = '') use (&$fails) {
    if (!$ok) { $fails++; }
    printf("%-5s %s%s\n", $ok ? 'ok' : 'FAIL', $what, $detail !== '' ? "  ({$detail})" : '');
};
$tipCount = substr_count($body, 'class="mt-tip"');
$check('shared tooltip buttons render', $tipCount > 0, "{$tipCount} found");
$check('no legacy .mt-info buttons left', !str_contains($body, 'class="mt-info"'));
$check('direction renders as a <select>', (bool)preg_match('/<select[^>]*data-var="--sidebar-grad-angle"/', $body));
$check('  ...with the stored value selected', (bool)preg_match('/<option value="135deg" selected/', $body));
$check('  ...and posts under the same c[] name', str_contains($body, 'name="c[--sidebar-grad-angle]"'));
$check('  ...and keeps its hidden scope twin', (bool)preg_match('/class="mt-color-other" data-var="--sidebar-grad-angle"/', $body));
$check('colour rows still render a swatch', substr_count($body, 'mt-color-swatch') > 20);
$check('Light chip no longer hardcoded active', !preg_match('/mt-sbt-mode is-active/', $body));
$check('all five nav styles present', substr_count($body, 'data-sbt-mode=') === 5,
       substr_count($body, 'data-sbt-mode=') . ' chips');

printf("\nwrote tests/.local/adminpreview/colorspanel.html\n%d failing\n", $fails);
exit($fails ? 1 : 0);

}
