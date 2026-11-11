<?php
/**
 * Regression harness for the light-scope colour leak.
 *
 * Builds four pages against the REAL apple-theme.css + apple-layout.css, each
 * carrying the block Hooks::buildColorsHead emits -- with the selector read out
 * of Hooks.php itself, so this cannot pass while the shipped selector says
 * something else.
 *
 * The scenario is the reported bug: "Generate from one colour" nudges the LIGHT
 * neutrals a few units toward the seed hue while the DARK ones come back equal
 * to their defaults, and saveColorsAction leaves defaults unstored. So a light
 * override exists with no dark counterpart -- and --sidebar-text is declared
 * only at :root as a var() chain, with nothing in the dark block to beat it.
 *
 *   php tests/static/check-colors-scope-leak.php   -> tests/.local/adminpreview/scopeleak.html
 * then measure the four panes in a browser.
 */

$root = dirname(__DIR__, 2);
$tpl  = $root . '/hadrian/templates/hadrian';

$hooks = file_get_contents($root . '/hadrian/modules/addons/Hadrian/src/Service/Hooks.php');
if (!preg_match('/\$scopes = \[\s*\'([^\']+)\'\s*\n?\s*=>/', $hooks, $m)) {
    fwrite(STDERR, "could not read the light selector out of Hooks.php\n");
    exit(1);
}
$lightSel = $m[1];
if (!preg_match('/\'(html\[data-theme="dark"\])\'\s*=>/', $hooks, $m2)) {
    fwrite(STDERR, "could not read the dark selector out of Hooks.php\n");
    exit(1);
}
$darkSel = $m2[1];
echo "light selector from Hooks.php : {$lightSel}\n";
echo "dark  selector from Hooks.php : {$darkSel}\n";

$css = file_get_contents($tpl . '/assets/css/apple-theme.css')
     . "\n" . file_get_contents($tpl . '/assets/css/apple-layout.css');

/* Light-scope overrides only -- no dark counterpart, exactly as saved. */
$lightDecls = '--sidebar-text:#1d1d21;--sidebar-text-muted:#87868a;'
            . '--color-text-primary:#1d1d21;--color-text-tertiary:#87868a;--color-accent:#7c3aed;';
$emitted = $lightSel . '{' . $lightDecls . '}';

$panes = '';
foreach ([
    'light'              => ['light', ''],
    'dark'               => ['dark',  ''],
    'light + ?palette'   => ['light', ' data-palette="emerald"'],
    'dark + ?palette'    => ['dark',  ' data-palette="emerald"'],
] as $name => [$theme, $paletteAttr]) {
    $panes .= "<section class=\"probe\" data-case=\"{$name}\">"
            . "<h3>{$name}</h3>"
            . "<div class=\"host\" data-theme=\"{$theme}\"{$paletteAttr}>"
            . "<aside class=\"sidebar\"><div class=\"sidebar-group-label\">HOME</div>"
            . "<a class=\"sidebar-item\">Portal Home</a></aside></div></section>\n";
}

/* The real selectors are html-scoped; retarget them at the per-pane host so
   four states can sit on one page. Only the `html` token is rewritten, so the
   attribute conditions being tested are still the shipped ones. */
$retarget = function (string $sel): string {
    return str_replace('html', '.host', $sel);
};
$cssScoped = str_replace(
    ['html[data-theme="dark"]', 'html[data-palette=', ':root'],
    ['.host[data-theme="dark"]', '.host[data-palette=', '.host'],
    $css
);
$emittedScoped = $retarget($lightSel) . '{' . $lightDecls . '}';

$html = "<!doctype html><html><head><meta charset=\"utf-8\"><title>colour scope leak</title>\n"
      . "<style>{$cssScoped}</style>\n"
      . "<style id=\"emitted\">{$emittedScoped}</style>\n"
      . "<style>body{margin:0;font:14px system-ui;background:#888}"
      . ".probe{padding:10px}.probe h3{margin:0 0 6px;font:600 12px system-ui;color:#fff}"
      . ".host{padding:10px}.host[data-theme=dark]{background:#1c1c1e}"
      . ".host[data-theme=light]{background:#fff}</style>\n"
      . "</head><body>\n{$panes}</body></html>";

@mkdir($root . '/tests/.local/adminpreview', 0777, true);
file_put_contents($root . '/tests/.local/adminpreview/scopeleak.html', $html);
echo "wrote tests/.local/adminpreview/scopeleak.html\n";
