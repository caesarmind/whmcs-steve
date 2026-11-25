<?php
/**
 * The customizer: the preview gate, the state it accepts, and the colour
 * rules.
 *
 * Runs Hadrian's real CustomizePreview and ColorTokens classes with a plain
 * $_SESSION and $_GET, so no WHMCS and no database is needed. What the gate
 * decides here is what the client theme does: every preview hook asks
 * CustomizePreview first.
 *
 *   php tests/static/test-customize.php
 */

declare(strict_types=1);

namespace {
    use Hadrian\Helpers\ColorTokens as C;
    use Hadrian\Helpers\CustomizePreview as P;

    $repo = dirname(__DIR__, 2);
    $src  = $repo . '/hadrian/modules/addons/Hadrian/src';
    require $src . '/Helpers/PageArea.php';
    require $src . '/Helpers/LayoutPointers.php';
    require $src . '/Helpers/ColorTokens.php';
    require $src . '/Helpers/CustomizePreview.php';
    $cfg = require $repo . '/hadrian/templates/hadrian/core/config/colors.php';

    $ok = 0;
    $fails = 0;
    $section = '';
    function same(string $label, mixed $got, mixed $want): void
    {
        global $ok, $fails, $section;
        if ($got === $want) {
            $ok++;
            return;
        }
        $fails++;
        echo "FAIL  [{$section}] {$label}\n      got:  " . json_encode($got) . "\n      want: " . json_encode($want) . "\n";
    }

    // ------------------------------------------------------------------
    $section = 'colour rules';
    same('hex, rgb and hsl forms pass', array_map([C::class, 'isColor'], ['#fff', '#0071e3', '#0071e3cc', 'rgb(0, 113, 227)', 'rgba(0,113,227,0.08)', 'hsl(210, 100%, 45%)']), array_fill(0, 6, true));
    same('anything that could carry CSS does not', array_map([C::class, 'isColor'], ['red', 'var(--x)', '#12', 'color-mix(in srgb, red, blue)', '#fff;}body{display:none', 'url(x)', '']), array_fill(0, 7, false));
    same('the gradient angle is the one non-colour token', [C::accepts('--sidebar-grad-angle', '135deg'), C::accepts('--sidebar-grad-angle', '135deg;x'), C::accepts('--color-accent', '135deg')], [true, false, false]);

    // The two older copies of these checks must not drift from this one.
    $patterns = static function (string $file): array {
        preg_match_all("~preg_match\\('(/\\^(?:#|rgba|hsla)[^']+)'~", (string)file_get_contents($file), $m);
        return array_values(array_unique($m[1]));
    };
    $mine = $patterns($src . '/Helpers/ColorTokens.php');
    same('three colour patterns here', count($mine), 3);
    // (StylesController also has two looser hex patterns for its colour
    // swatches; those do not decide what is stored.)
    same('StylesController accepts the same colours', array_values(array_diff($mine, $patterns($src . '/Controller/Admin/StylesController.php'))), []);
    same('Service\\Hooks emits the same colours', array_values(array_diff($mine, $patterns($src . '/Service/Hooks.php'))), []);

    $schema = C::schema($cfg);
    same('the schema is read from colors.php', [isset($schema['--color-accent']), $schema['--color-accent']['light'], $schema['--color-accent']['dark'], $schema['--color-accent']['group']], [true, '#0071e3', '#2997ff', 'Brand']);
    same('every schema default is itself storable', array_filter(array_keys($schema), static fn ($v) => $schema[$v]['light'] !== '' && !C::accepts($v, $schema[$v]['light'])), []);

    same('only what differs from the default is kept', C::diff(['--color-accent' => '#ff2d55', '--color-bg' => '#FBFBFD', '--color-link' => ' #0066cc '], $cfg, 'light'), ['--color-accent' => '#ff2d55']);
    same('the default is per scope', C::diff(['--color-accent' => '#2997ff'], $cfg, 'light') === ['--color-accent' => '#2997ff'] && C::diff(['--color-accent' => '#2997ff'], $cfg, 'dark') === [], true);
    same('unknown tokens and bad values are dropped', C::diff(['--not-a-token' => '#fff', '--color-accent' => 'red', '--color-bg' => '#000;}x{', '--color-link' => ['#fff']], $cfg, 'light'), []);

    same('the css uses the selectors the theme prints', C::css(['--color-accent' => '#ff2d55'], ['--color-accent' => '#ff6482']), 'html:not([data-theme="dark"]):not([data-palette]){--color-accent:#ff2d55;}html[data-theme="dark"]{--color-accent:#ff6482;}');
    same('and those selectors are the ones in Service\\Hooks', [
        str_contains((string)file_get_contents($src . '/Service/Hooks.php'), "'" . C::SELECTOR_LIGHT . "'"),
        str_contains((string)file_get_contents($src . '/Service/Hooks.php'), "'" . C::SELECTOR_DARK . "'"),
    ], [true, true]);
    same('nothing to draw is an empty block', C::css([], []), '');
    same('a value that does not pass never reaches the css', C::css(['--color-accent' => 'red;}body{}', 'color' => '#fff'], []), '');

    // ------------------------------------------------------------------
    $section = 'state';
    $known = ['styles' => ['default', 'emerald'], 'layouts' => ['main-menu' => ['sidebar', 'top', 'rail'], 'footer' => ['default', 'extended']], 'colors' => $cfg];
    $saved = [
        'style' => 'default', 'theme' => 'light', 'colors' => ['light' => [], 'dark' => ['--color-accent' => '#111111']],
        'layouts' => [
            'mode' => 'audience',
            'audience' => ['main-menu' => ['guest' => 'top', 'client' => 'sidebar'], 'footer' => ['guest' => 'extended', 'client' => 'default']],
            'area' => ['main-menu' => ['website' => 'top', 'client' => 'sidebar', 'order' => 'top'], 'footer' => ['website' => 'extended', 'client' => 'default', 'order' => 'extended']],
        ],
    ];
    same('nothing sent gives the saved state back', P::normalise([], $known, $saved), $saved);
    same('a saved state passes through unchanged', P::normalise($saved, $known, $saved), $saved);

    $tried = P::normalise([
        'style' => 'emerald', 'theme' => 'dark',
        'colors' => ['light' => ['--color-accent' => '#14b17d', '--bogus' => '#fff'], 'dark' => []],
        'layouts' => ['mode' => 'area', 'audience' => ['main-menu' => ['guest' => 'rail']], 'area' => ['main-menu' => ['order' => 'rail'], 'footer' => ['website' => 'default']]],
    ], $known, $saved);
    same('a scheme, a mode and colours are taken', [$tried['style'], $tried['theme'], $tried['colors']], ['emerald', 'dark', ['light' => ['--color-accent' => '#14b17d'], 'dark' => []]]);
    same('an emptied scope is empty, not the saved one', $tried['colors']['dark'], []);
    same('layout picks are taken, the rest stay as saved', [$tried['layouts']['mode'], $tried['layouts']['audience']['main-menu'], $tried['layouts']['area']['main-menu'], $tried['layouts']['area']['footer']], ['area', ['guest' => 'rail', 'client' => 'sidebar'], ['website' => 'top', 'client' => 'sidebar', 'order' => 'rail'], ['website' => 'default', 'client' => 'default', 'order' => 'extended']]);

    $junk = P::normalise([
        'style' => '../../etc', 'theme' => 'neon', 'colors' => 'x',
        'layouts' => ['mode' => 'both', 'audience' => ['main-menu' => ['guest' => 'no-such-layout', 'everyone' => 'top'], 'sidebar' => ['guest' => 'top']], 'area' => 'x'],
    ], $known, $saved);
    same('a scheme, mode, layout or colour set that does not exist falls back', $junk, $saved);

    // ------------------------------------------------------------------
    $section = 'the gate';
    $ask = static function (array $session, array $get): array {
        $_SESSION = $session;
        $_GET     = $get;
        P::reset();
        return [P::active(), P::style(), P::theme(), P::colors('light'), P::layout('main-menu', 'guest', 'website', ['sidebar', 'top', 'rail']), P::footerScript() !== ''];
    };
    $off = [false, null, null, null, null, false];

    $_SESSION = ['adminid' => 1];
    $_GET = [];
    $token = P::token();
    same('a token is made on first use and kept', [strlen($token), P::token()], [32, $token]);
    P::put($tried);
    $session = $_SESSION;
    same('the state is held in the session', $session['hadrianCustomize']['state'], $tried);

    same('admin session + its token: a preview', $ask($session, [P::PARAM => $token]), [true, 'emerald', 'dark', ['--color-accent' => '#14b17d'], 'top', true]);
    same('no token in the URL: the live site', $ask($session, []), $off);
    same('a wrong token: the live site', $ask($session, [P::PARAM => str_repeat('0', 32)]), $off);
    same('a token that is not a string: the live site', $ask($session, [P::PARAM => [$token]]), $off);
    same('the right token without an admin session: the live site', $ask(['hadrianCustomize' => $session['hadrianCustomize']], [P::PARAM => $token]), $off);
    same('a signed-in client with the token: the live site', $ask(['uid' => 7, 'hadrianCustomize' => $session['hadrianCustomize']], [P::PARAM => $token]), $off);
    same('an admin with no state stored: the live site', $ask(['adminid' => 1, 'hadrianCustomize' => ['token' => $token, 'state' => null]], [P::PARAM => $token]), $off);
    same('an admin who never opened the customizer: the live site', $ask(['adminid' => 1], [P::PARAM => $token]), $off);

    // ------------------------------------------------------------------
    $section = 'what a preview draws';
    $_SESSION = $session;
    $_GET = [P::PARAM => $token];
    P::reset();
    $menus = ['sidebar', 'top', 'rail'];
    same('by area: the area decides, not the visitor', [P::layout('main-menu', 'guest', 'order', $menus), P::layout('main-menu', 'client', 'order', $menus), P::layout('main-menu', 'guest', 'client', $menus)], ['rail', 'rail', 'sidebar']);
    same('an unknown area is the client area', P::layout('main-menu', 'guest', 'moon', $menus), 'sidebar');
    same('a pick whose layout has gone is no answer', P::layout('main-menu', 'guest', 'order', ['sidebar', 'top']), null);
    same('each scope has its own colours, and empty is an answer', [P::colors('light'), P::colors('dark')], [['--color-accent' => '#14b17d'], []]);

    $byVisitor = $tried;
    $byVisitor['layouts']['mode'] = 'audience';
    P::put($byVisitor);
    P::reset();
    same('by visitor: the visitor decides, not the area', [P::layout('main-menu', 'guest', 'order', $menus), P::layout('main-menu', 'client', 'order', $menus), P::layout('footer', 'guest', 'website', ['default', 'extended'])], ['rail', 'sidebar', 'extended']);

    $script = P::footerScript();
    same('the frame script marks the page and carries the token', [str_contains($script, 'data-hadrian-preview'), str_contains($script, json_encode($token)), str_contains($script, json_encode(P::PARAM))], [true, true, true]);
    same('and it is one script element', [substr_count($script, '<script'), substr_count($script, '</script>')], [1, 1]);

    // ------------------------------------------------------------------
    // The second slot: an add-on drawing one of its pages under another look
    // (Helpers\SiteLook::preview(); Hadrian Page Builder's "Preview with").
    $section = 'the look slot';
    $_SESSION = $session;
    $_GET = [];
    P::reset();
    $look = $byVisitor;
    $look['style'] = 'violet';
    $look['theme'] = 'light';
    $lookToken = P::putLook($look);
    $both = $_SESSION;
    same('it has a token of its own', [strlen($lookToken), $lookToken !== $token, P::putLook($look)], [32, true, $lookToken]);
    same('and leaves what the customizer is trying alone', $both['hadrianCustomize'], $session['hadrianCustomize']);
    same('its token draws its look', array_slice($ask($both, [P::LOOK_PARAM => $lookToken]), 0, 3), [true, 'violet', 'light']);
    same('the customizer token still draws the customizer', array_slice($ask($both, [P::PARAM => $token]), 0, 3), [true, 'emerald', 'dark']);
    same('one slot\'s token under the other\'s name is no preview', [$ask($both, [P::PARAM => $lookToken])[0], $ask($both, [P::LOOK_PARAM => $token])[0]], [false, false]);
    same('the same gate: no admin, no preview', $ask(['hadrianLook' => $both['hadrianLook']], [P::LOOK_PARAM => $lookToken]), $off);
    $ask($both, [P::LOOK_PARAM => $lookToken]);
    $script = P::footerScript();
    same('the frame script carries the look token', [str_contains($script, json_encode($lookToken)), str_contains($script, json_encode(P::LOOK_PARAM))], [true, true]);

    echo "\n" . ($ok + $fails) . " checks, {$fails} failing\n";
    exit($fails ? 1 : 0);
}
