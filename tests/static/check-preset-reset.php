<?php
/**
 * "Reset to preset" -- does it actually reach a style that was already seeded?
 *
 * The bug it exists for: seedStyleColors is once-only, so a style activated
 * while an OLDER manifest was deployed keeps those colours forever. Every
 * assertion below is about that, and the subtle one is #3 -- writing [] instead
 * of DELETING leaves a row, and hasStoredColors treats any row as buyer-owned,
 * so the re-seed silently no-ops and the reset appears to do nothing.
 *
 *   php tests/static/check-preset-reset.php
 */

namespace Hadrian\Controller {
    class Redirected extends \Exception { public string $url = ''; }
    abstract class AbstractController {
        public function __construct(array $p = []) {}
        protected function redirect(string $url): never {
            $e = new Redirected(); $e->url = $url; throw $e;
        }
        protected function view(string $t, array $d = []): string { return ''; }
    }
}

namespace Hadrian\Models {
    class Settings
    {
        public static array $store = [];
        public static function getValue(string $key, $default = null)
        {
            return array_key_exists($key, self::$store) ? self::$store[$key] : $default;
        }
        public static function setValue(string $key, $value, string $type = ''): void
        {
            self::$store[$key] = $value;
        }
        public static function deleteValue(string $key): void { unset(self::$store[$key]); }
    }
}

namespace {

$root  = dirname(__DIR__, 2);
$admin = $root . '/hadrian/modules/addons/Hadrian';
require $admin . '/src/Helpers/ThemeManifest.php';
require $admin . '/src/Controller/Admin/StylesController.php';

use Hadrian\Models\Settings;

$styles = json_decode(file_get_contents($root . '/hadrian/templates/hadrian/theme.json'), true)['provides']['styles'];

$template = new class ($root, $styles) {
    public function __construct(private string $root, private array $styles) {}
    public function getFullPath(): string { return $this->root . '/hadrian/templates/hadrian'; }
    public function getName(): string { return 'hadrian'; }
    public function getStyles(): array { return $this->styles; }
    public function resolveStyleName(string $s): string
    {
        $s = trim($s);
        if ($s === '' || $s === 'dark') { return 'default'; }
        return in_array($s, $this->styles, true) ? $s : 'default';
    }
};

$ctl   = new \Hadrian\Controller\Admin\StylesController();
$reset = new ReflectionMethod($ctl, 'resetPresetColorsAction');
$reset->setAccessible(true);

$fails = 0;
$check = function (string $what, $got, $expect) use (&$fails) {
    $ok = $got === $expect;
    if (!$ok) { $fails++; }
    printf("%-5s %-56s got=%-24s expected=%s\n", $ok ? 'ok' : 'FAIL', $what,
        var_export($got, true), var_export($expect, true));
};
$run = function (string $style, string $scope = 'light') use ($reset, $ctl, $template): string {
    $_POST = ['style' => $style, 'scope' => $scope];
    try { $reset->invoke($ctl, $template); }
    catch (\Hadrian\Controller\Redirected $e) { return $e->url; }
    return '(no redirect)';
};

/* The manifest value we expect a reset to restore. */
$manifest = (array)(require $root . '/hadrian/templates/hadrian/core/styles/rose/style.php');
$roseAccent = $manifest['colors']['light']['--color-accent'];
printf("rose manifest accent: %s\n\n", $roseAccent);

/* 1. THE REPORTED CASE: a style seeded from an OLDER manifest is stuck. */
Settings::$store = ['hadrian_colors_rose_light' => ['--color-accent' => '#ea0045']];
$url = $run('rose');
$check('reset restores the CURRENT manifest accent',
    Settings::$store['hadrian_colors_rose_light']['--color-accent'] ?? null, $roseAccent);
$check('  ...and redirects back to the colours panel', str_contains($url, 'subcat=colors'), true);
$check('  ...with the flash the view reads',            str_contains($url, 'preset_restored=1'), true);

/* 2. Both scopes are cleared, not just the one being edited -- a stale dark
      palette under a fresh light one is the same bug wearing a hat. */
Settings::$store = [
    'hadrian_colors_rose_light' => ['--color-accent' => '#ea0045'],
    'hadrian_colors_rose_dark'  => ['--color-accent' => '#ff5487'],
];
$run('rose', 'light');
$check('the DARK scope is re-seeded too, not left stale',
    Settings::$store['hadrian_colors_rose_dark']['--color-accent'] ?? null,
    $manifest['colors']['dark']['--color-accent']);

/* 3. THE SUBTLE ONE. Emptying the row instead of deleting it would leave
      hasStoredColors reporting "buyer-owned", and the re-seed would no-op. */
Settings::$store = ['hadrian_colors_rose_light' => []];
$run('rose');
$check('an EMPTY stored row does not block the re-seed',
    Settings::$store['hadrian_colors_rose_light']['--color-accent'] ?? null, $roseAccent);

/* 4. Default ships no palette, so resetting it must leave NO rows at all --
      that is what makes the card blue again rather than keeping a green
      generated palette. Legacy key names included. */
Settings::$store = [
    'hadrian_colors_default_light' => ['--color-accent' => '#43e123'],
    'hadrian_colors_default'       => ['--color-accent' => '#43e123'],
    'hadrian_colors_dark'          => ['--color-accent' => '#3af100'],
];
$run('default');
$check('default: per-scope row removed',  isset(Settings::$store['hadrian_colors_default_light']), false);
$check('default: legacy light row removed', isset(Settings::$store['hadrian_colors_default']), false);
$check('default: legacy dark row removed',  isset(Settings::$store['hadrian_colors_dark']), false);

/* 5. One style's reset must not touch another's. */
Settings::$store = [
    'hadrian_colors_rose_light'  => ['--color-accent' => '#ea0045'],
    'hadrian_colors_amber_light' => ['--color-accent' => '#ac6300'],
];
$run('rose');
$check('resetting Rose leaves Amber alone',
    Settings::$store['hadrian_colors_amber_light']['--color-accent'] ?? null, '#ac6300');

/* 6. A hand-edited ?style= naming a retired preset must not delete anything
      belonging to a real one. */
Settings::$store = ['hadrian_colors_default_light' => ['--color-accent' => '#43e123']];
$run('aqueduct');   // retired -> resolves to default
$check('a retired style name resolves rather than acting on nothing',
    isset(Settings::$store['hadrian_colors_default_light']), false);

printf("\n%d failing\n", $fails);
exit($fails ? 1 : 0);

}
