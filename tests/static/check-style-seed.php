<?php
/**
 * Does every token a style preset declares actually SURVIVE seeding?
 *
 * seedStyleColors filters a manifest three ways and every one of them fails
 * silently: a token missing from core/config/colors.php is dropped, a value
 * isColor() rejects is dropped, and a value equal to the schema default is
 * deliberately not stored. So a preset can ship eighteen tokens, seed four, and
 * nothing anywhere says so -- the style just renders wrong.
 *
 * This calls the REAL StylesController::seedStyleColors() against a stubbed
 * Settings store and diffs what the manifest declared against what landed.
 *
 *   php tests/static/check-style-seed.php
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
        public static function setValue(string $key, $value, string $type = ''): void
        {
            self::$store[$key] = $value;
        }
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
$seed = new ReflectionMethod($ctl, 'seedStyleColors');
$seed->setAccessible(true);

/* The token names the schema actually knows about. */
$cfg = (array)(require $root . '/hadrian/templates/hadrian/core/config/colors.php');
$known = [];
foreach (($cfg['groups'] ?? []) as $tokens) {
    foreach ($tokens as $t) { $known[(string)$t['var']] = $t; }
}

$styles = json_decode(file_get_contents($root . '/hadrian/templates/hadrian/theme.json'), true)['provides']['styles'];
$fails  = 0;

foreach ($styles as $style) {
    $path = $root . "/hadrian/templates/hadrian/core/styles/{$style}/style.php";
    if (!file_exists($path)) {
        printf("FAIL  %-9s declared in theme.json but has no style.php\n", $style);
        $fails++;
        continue;
    }
    $meta = (array)(require $path);
    if ((($meta['variables']['colorMode'] ?? 'light') === 'dark')) {
        printf("skip  %-9s colorMode=dark (not an activatable style)\n", $style);
        continue;
    }

    foreach (['light', 'dark'] as $scope) {
        $declared = (array)($meta['colors'][$scope] ?? []);
        if ($declared === []) {
            printf("ok    %-9s %-5s ships no palette (baseline)\n", $style, $scope);
            continue;
        }

        Settings::$store = [];
        $seed->invoke($ctl, $template, $style);
        $stored = (array)(Settings::$store["hadrian_colors_{$style}_{$scope}"] ?? []);

        $lost = [];
        foreach ($declared as $var => $val) {
            if (isset($stored[$var])) { continue; }
            // Equal-to-default is a legitimate, intentional drop; unknown token
            // or rejected value is a bug in the manifest.
            $default = (string)($known[$var][$scope] ?? $known[$var]['light'] ?? '__none__');
            $reason  = !isset($known[$var])                          ? 'NOT IN SCHEMA'
                     : (strtolower(preg_replace('/\s+/', '', $val))
                        === strtolower(preg_replace('/\s+/', '', $default)) ? null : 'VALUE REJECTED');
            if ($reason !== null) { $lost[$var] = "{$reason} ({$val})"; }
        }

        if ($lost) {
            $fails++;
            printf("FAIL  %-9s %-5s %d/%d survived; dropped:\n", $style, $scope, count($stored), count($declared));
            foreach ($lost as $var => $why) { printf("           %-28s %s\n", $var, $why); }
        } else {
            printf("ok    %-9s %-5s %d/%d tokens seeded\n", $style, $scope, count($stored), count($declared));
        }
    }
}

/* Re-seeding must never stamp over a buyer's saved rows. */
Settings::$store = ['hadrian_colors_emerald_light' => ['--color-accent' => '#123456']];
$seed->invoke($ctl, $template, 'emerald');
$kept = Settings::$store['hadrian_colors_emerald_light']['--color-accent'] ?? null;
if ($kept !== '#123456') {
    printf("FAIL  re-seed overwrote a buyer's saved row (got %s)\n", var_export($kept, true));
    $fails++;
} else {
    printf("ok    re-seed leaves a buyer's saved row alone\n");
}

printf("\n%d failing\n", $fails);
exit($fails ? 1 : 0);

}
