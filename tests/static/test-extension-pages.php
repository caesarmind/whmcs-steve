<?php
/**
 * Extension pages: pages a separate module adds to Hadrian's Pages screen.
 *
 * Runs Hadrian's real ExtensionPages class with made-up modules, so no WHMCS
 * and no database is needed. Everything Pages and the theme learn about a
 * module's page passes through this class, so what it refuses here cannot
 * reach either.
 *
 *   php tests/static/test-extension-pages.php
 */

declare(strict_types=1);

namespace {
    use Hadrian\Helpers\ExtensionPages as X;
    use Hadrian\Helpers\Extensions as E;

    $src = dirname(__DIR__, 2) . '/hadrian/modules/addons/Hadrian/src';
    require $src . '/Helpers/PageArea.php';
    require $src . '/Helpers/ExtensionPages.php';
    require $src . '/Helpers/Extensions.php';

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

    $calls = 0;
    $rows  = [
        ['id' => 12, 'name' => 'WordPress hosting', 'description' => '/wordpress', 'url' => '/wordpress', 'live' => true, 'status' => 'Published',
         'editUrl' => '?module=Demo&action=edit&id=12', 'seoTitle' => 'ignored by the builder', 'seoDescription' => 'Fast WordPress.', 'replaces' => 'homepage'],
        ['id' => 13, 'name' => 'Coming soon', 'url' => '', 'live' => false],
        ['id' => 14, 'name' => 'Standby', 'url' => 'standby', 'live' => false, 'replaces' => 'contact'],
    ];
    $module = static function (array $over = []) use (&$rows, &$calls): array {
        return $over + [
            'id' => 'demo', 'prefix' => 'built', 'label' => 'Demo Builder', 'group' => 'Built',
            'createUrl' => '?module=Demo&action=create', 'createLabel' => 'Create page', 'createPlaceholder' => 'New page',
            'panel' => static fn (): string => '<div id="demo-panel">site switch</div>',
            'pagePanel' => static fn (int $id): string => '<div id="demo-page">page ' . $id . '</div>',
            'provider' => static function () use (&$rows, &$calls): array { $calls++; return $rows; },
        ];
    };

    // ------------------------------------------------------------------
    $section = 'nothing registered';
    same('no pages', X::all(), []);
    same('no key is owned', [X::owns('built-12'), X::meta('built-12'), X::notesFor('homepage'), X::groups()], [false, [], [], []]);
    same('no request is an extension page', X::keyFor(['templatefile' => 'module-page', 'modulePage' => ['pageKey' => 'built-12']]), null);

    // ------------------------------------------------------------------
    $section = 'registering';
    X::register($module(['prefix' => 'Built']));
    X::register($module(['prefix' => 'b']));
    X::register($module(['prefix' => 'built-1']));
    X::register($module(['provider' => 'no such function']));
    X::register($module(['label' => '  ']));
    same('a bad prefix, provider or label registers nothing', X::prefixes(), []);
    X::register($module());
    same('a good one registers', X::prefixes(), ['built']);
    same('and no provider has been called yet', $calls, 0);
    same('its group says where a page is made, and carries the module\'s own panel', X::groups(), ['Built' => [
        'label' => 'Demo Builder', 'createUrl' => '?module=Demo&action=create', 'createLabel' => 'Create page', 'createPlaceholder' => 'New page',
        'panelHtml' => '<div id="demo-panel">site switch</div>',
    ]]);

    // ------------------------------------------------------------------
    $section = 'keys';
    same('a key is the prefix and a positive id', array_map([X::class, 'owns'], ['built-12', 'built-1', 'built-0', 'built-', 'built-12a', 'other-12', 'built-01', 'homepage', '../built-12']), [true, true, false, false, false, false, false, false, false]);
    same('checking a key calls no provider', $calls, 0);

    // ------------------------------------------------------------------
    $section = 'pages';
    $all = X::all();
    same('one entry per page, keyed', array_keys($all), ['built-12', 'built-13', 'built-14']);
    same('asked once however often it is read', [X::all() === $all, X::meta('built-12') === $all['built-12'], $calls], [true, true, 1]);

    $p = $all['built-12'];
    same('it reads like a theme page', [$p['display_name'], $p['group'], $p['type'], $p['description'], $p['listDisplay'], $p['supportedOptions'], $p['area']], ['WordPress hosting', 'Built', 'extension', '/wordpress', true, [], 'website']);
    same('its address is a path from the site root', $p['url'], 'wordpress');
    same('its description is a fallback for SEO', $p['seoDefaults'], ['title' => 'ignored by the builder', 'description' => 'Fast WordPress.']);
    same('the module is named, with where the content is edited', $p['extension'], ['id' => 'demo', 'label' => 'Demo Builder', 'live' => true, 'status' => 'Published', 'editUrl' => '?module=Demo&action=edit&id=12', 'replaces' => 'homepage']);

    same('a page with no address has no url key', [array_key_exists('url', $all['built-13']), $all['built-13']['extension']['live'], $all['built-13']['extension']['status']], [false, false, 'Draft']);
    same('an unknown page has no meta', [X::meta('built-99'), X::meta('other-12'), X::meta('homepage')], [[], [], []]);

    // ------------------------------------------------------------------
    $section = 'the module\'s own controls';
    same('a page of the module gets its panel, with the module\'s id for it', X::pagePanel('built-12'), '<div id="demo-page">page 12</div>');
    same('a page the module does not report gets none', [X::pagePanel('built-99'), X::pagePanel('other-12'), X::pagePanel('homepage')], ['', '', '']);

    // ------------------------------------------------------------------
    $section = 'notes on theme pages';
    same('a live replacement is noted on the page it replaces', X::notesFor('homepage'), ['Replaced by WordPress hosting']);
    same('one on standby is not', [X::notesFor('contact'), array_key_exists('replaces', $all['built-14']['extension'])], [[], false]);
    same('other pages have none', X::notesFor('login'), []);

    // ------------------------------------------------------------------
    $section = 'which page a request is drawing';
    $vars = static fn (mixed $key, string $tpl = 'module-page'): array => ['templatefile' => $tpl, 'modulePage' => ['pageKey' => $key]];
    same('a module page that names a known key', X::keyFor($vars('built-12')), 'built-12');
    same('a key the module does not report', X::keyFor($vars('built-99')), null);
    same('a key of no registered module', X::keyFor($vars('other-12')), null);
    same('a theme page cannot claim one', X::keyFor($vars('built-12', 'homepage')), null);
    same('a key that is not a string', [X::keyFor($vars(['built-12'])), X::keyFor($vars(12)), X::keyFor(['templatefile' => 'module-page'])], [null, null, null]);

    // ------------------------------------------------------------------
    $section = 'what a module cannot do';
    $rows = [
        ['id' => 1, 'name' => 'A', 'url' => 'https://evil.example/x', 'editUrl' => 'https://evil.example/', 'live' => true, 'replaces' => '../../x'],
        ['id' => 2, 'name' => 'B', 'url' => '../admin/x', 'editUrl' => 'javascript:alert(1)'],
        ['id' => 3, 'name' => 'C', 'url' => 'ok/path-1', 'editUrl' => '?module=Demo&action=edit&id=3"><script>'],
        ['id' => 0, 'name' => 'no id'],
        ['id' => -4, 'name' => 'negative'],
        'not a row',
        ['id' => 5, 'name' => str_repeat('n', 500)],
    ];
    X::refresh();
    $all = X::all();
    same('refresh asks the provider again', $calls, 2);
    same('rows without a positive id are dropped', array_keys($all), ['built-1', 'built-2', 'built-3', 'built-5']);
    same('an address that leaves the site is no address', [isset($all['built-1']['url']), isset($all['built-2']['url']), $all['built-3']['url']], [false, false, 'ok/path-1']);
    same('an edit link that leaves the admin is no link', [$all['built-1']['extension']['editUrl'], $all['built-2']['extension']['editUrl'], $all['built-3']['extension']['editUrl']], ['', '', '']);
    same('a replaced page that is not a page name is no note', [X::notesFor('../../x'), isset($all['built-1']['extension']['replaces'])], [[], false]);
    same('a long name is cut', strlen($all['built-5']['display_name']), 120);

    X::register($module(['id' => 'broken', 'prefix' => 'boom', 'label' => 'Broken', 'group' => 'Broken', 'provider' => static function (): array { throw new \RuntimeException('down'); }]));
    $logTo = ini_set('error_log', PHP_OS_FAMILY === 'Windows' ? 'NUL' : '/dev/null');
    same('a module that fails lists none, and the others still list', array_keys(X::all()), ['built-1', 'built-2', 'built-3', 'built-5']);
    ini_set('error_log', (string)$logTo);
    X::register($module(['id' => 'junk', 'prefix' => 'junk', 'label' => 'Junk', 'group' => 'Junk', 'createUrl' => 'https://evil.example/',
        'panel' => static function (): string { throw new \RuntimeException('down'); }, 'pagePanel' => 'no such function',
        'provider' => static fn () => 'not a list']));
    same('a provider that returns no list lists none', array_keys(X::all()), ['built-1', 'built-2', 'built-3', 'built-5']);
    same('a create address that leaves the admin is dropped', X::groups()['Junk']['createUrl'], '');
    $logTo = ini_set('error_log', PHP_OS_FAMILY === 'Windows' ? 'NUL' : '/dev/null');
    same('a panel that fails is no panel, and the screen still has its other groups', [X::groups()['Junk']['panelHtml'], X::groups()['Built']['panelHtml']], ['', '<div id="demo-panel">site switch</div>']);
    ini_set('error_log', (string)$logTo);

    X::reset();
    same('reset forgets everything', [X::prefixes(), X::all(), X::owns('built-1')], [[], [], false]);

    // ------------------------------------------------------------------
    $section = 'a module with no tab of its own';
    E::register(['id' => 'mail', 'label' => 'Email', 'url' => '?module=DemoMail']);
    E::register(['id' => 'builder', 'label' => 'Builder', 'name' => 'Page Builder', 'url' => '?module=Demo', 'tab' => false]);
    $listed = array_column(E::all(), 'tab', 'id');
    same('both are listed as extensions; only one asks for a tab', $listed, ['mail' => '1', 'builder' => '0']);
    same('the shared header honours that', str_contains((string)file_get_contents(dirname($src) . '/views/adminarea/includes/header.tpl'), "{if \$mtExt.tab|default:'1' != '0'}"), true);

    echo "\n" . ($ok + $fails) . " checks, {$fails} failing\n";
    exit($fails ? 1 : 0);
}
