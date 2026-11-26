<?php
/**
 * Setup page: what the checklist says about an install, when the go-live
 * button is allowed, and that switching the theme on can be undone.
 *
 * Runs Hadrian's real SetupChecks and ThemeSwitch classes. SetupChecks takes
 * plain facts, so no WHMCS is needed; ThemeSwitch runs against an in-memory
 * stand-in for tblconfiguration and a throwaway templates folder.
 *
 *   php tests/static/test-setup.php
 */

declare(strict_types=1);

namespace Hadrian\Models {
    /** In-memory stand-in for tblconfiguration. Declared before the real one can load. */
    final class Configuration
    {
        /** @var array<string,string> */
        public static array $rows = [];

        public static function getValue(string $key): ?string
        {
            return self::$rows[$key] ?? null;
        }

        public static function setValue(string $key, string $value): void
        {
            self::$rows[$key] = $value;
        }

        public static function deleteValue(string $key): void
        {
            unset(self::$rows[$key]);
        }
    }
}

namespace {
    use Hadrian\Helpers\SetupChecks as C;
    use Hadrian\Helpers\ThemeSwitch as S;
    use Hadrian\Models\Configuration;

    $src = dirname(__DIR__, 2) . '/hadrian/modules/addons/Hadrian/src/Helpers';
    require $src . '/SetupChecks.php';
    require $src . '/ThemeSwitch.php';

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

    /** A healthy install that has not gone live yet; each test changes one thing. */
    function facts(array $over = []): array
    {
        return array_replace_recursive([
            'slugs'            => ['theme' => 'hadrian', 'cart' => 'hadrian_cart'],
            'theme'            => ['path' => 'templates/hadrian', 'present' => true, 'missing' => [], 'version' => '1.2.3'],
            'cart'             => ['path' => 'templates/orderforms/hadrian_cart', 'present' => true, 'missing' => []],
            'hook'             => ['path' => 'includes/hooks/hostnodes_theme_license.php', 'present' => true],
            'requires'         => ['php' => '>=8.1', 'whmcs' => '>=9.0'],
            'php'              => '8.3.30',
            'whmcs'            => '9.0.8',
            'extensions'       => ['curl' => true, 'mbstring' => true],
            'uploads_path'     => 'templates/hadrian/assets/img/branding',
            'uploads_writable' => true,
            'migrations'       => ['total' => 6, 'pending' => [], 'error' => ''],
            'menus'            => 8,
            'license'          => ['key' => 'k', 'status' => 'Active', 'active' => true],
            'live'             => ['template' => 'six', 'orderform' => 'standard_cart', 'prev_template' => '', 'prev_orderform' => ''],
        ], $over);
    }

    /** @return array{0:array<string,string>,1:array<string,string>,2:array<string,mixed>} group states, row states, summary */
    function judge(array $f): array
    {
        $groups = C::evaluate($f);
        $g = [];
        $r = [];
        foreach ($groups as $group) {
            $g[$group['key']] = $group['state'];
            foreach ($group['rows'] as $row) {
                $r[$row['key']] = $row['state'];
            }
        }
        return [$g, $r, C::summary($groups, $f)];
    }

    // ------------------------------------------------------- a healthy install
    $section = 'ready to go live';
    [$g, $r, $s] = judge(facts());
    same('every step before go-live is ready', [$g['files'], $g['requirements'], $g['database'], $g['license']], ['ok', 'ok', 'ok', 'ok']);
    same('go-live is the one step left', $g['golive'], 'todo');
    same('the button is allowed', $s['blocked'], false);
    same('not finished until it is live', $s['finished'], false);
    same('four of five steps done', [$s['done'], $s['total']], [4, 5]);
    same('nothing to switch back to yet', $s['canSwitchBack'], false);

    $section = 'live';
    [$g, $r, $s] = judge(facts(['live' => ['template' => 'hadrian', 'orderform' => 'hadrian_cart', 'prev_template' => 'six']]));
    same('finished', [$s['finished'], $s['live'], $s['cartLive'], $g['golive']], [true, true, true, 'ok']);
    same('the earlier theme can come back', $s['canSwitchBack'], true);

    [$g, $r, $s] = judge(facts(['live' => ['template' => 'hadrian', 'orderform' => 'standard_cart']]));
    same('live with the old order form is not finished while the cart is uploaded', [$s['finished'], $r['live-cart']], [false, 'todo']);

    // ------------------------------------------------------------------- files
    $section = 'files';
    [$g, $r, $s] = judge(facts(['theme' => ['present' => false]]));
    same('no theme folder stops go-live', [$r['theme'], $s['blocked']], ['fail', true]);

    [$g, $r, $s] = judge(facts(['theme' => ['missing' => ['core/pages/homepage', 'header.tpl']]]));
    same('a partly uploaded theme stops go-live', [$r['theme'], $s['blocked']], ['fail', true]);

    $many = C::evaluate(facts(['theme' => ['missing' => ['a', 'b', 'c', 'd', 'e', 'f', 'g']]]))[0]['rows'][0]['detail'];
    same('a long list of missing files is cut short', str_contains($many, 'a, b, c, d and 3 more'), true);

    [$g, $r, $s] = judge(facts(['cart' => ['present' => false]]));
    same('no order form is a warning, not a stop', [$r['cart'], $g['files'], $s['blocked']], ['warn', 'warn', false]);
    same('and go-live then has no order form row', array_key_exists('live-cart', $r), false);
    same('and the theme alone going live is finished', judge(facts(['cart' => ['present' => false], 'live' => ['template' => 'hadrian']]))[2]['finished'], true);

    [$g, $r, $s] = judge(facts(['cart' => ['missing' => ['checkout.tpl']]]));
    same('a partly uploaded order form stops go-live', [$r['cart'], $s['blocked'], $s['cartReady']], ['fail', true, false]);

    [$g, $r, $s] = judge(facts(['hook' => ['present' => false]]));
    same('no license check file stops go-live', [$r['hook'], $s['blocked']], ['fail', true]);

    $section = 'release marks';
    same('a source checkout carries no marks and gets no row', array_key_exists('release', judge(facts(['release' => ['theme' => '', 'cart' => '', 'addon' => '']]))[1]), false);
    [$g, $r, $s] = judge(facts(['release' => ['theme' => '1.8.0', 'cart' => '1.8.0', 'addon' => '1.8.0']]));
    same('one release everywhere is ready', [$r['release'], $s['blocked']], ['ok', false]);
    [$g, $r, $s] = judge(facts(['release' => ['theme' => '1.8.0', 'cart' => '1.8.0', 'addon' => '1.7.1']]));
    same('a new theme beside an old addon stops go-live', [$r['release'], $s['blocked']], ['fail', true]);
    $said = C::evaluate(facts(['release' => ['theme' => '1.8.0', 'cart' => '', 'addon' => '1.8.0']]))[0]['rows'][3];
    same('a folder with no mark among marked ones is a mismatch', [$said['state'], str_contains($said['detail'], 'order form unmarked')], ['fail', true]);
    [$g, $r, $s] = judge(facts(['cart' => ['present' => false], 'release' => ['theme' => '1.8.0', 'cart' => null, 'addon' => '1.8.0']]));
    same('an order form that is not uploaded is left out of the comparison', $r['release'], 'ok');

    // ------------------------------------------------------------ requirements
    $section = 'requirements';
    same('8.3.30 meets >=8.1', C::meets('8.3.30', '>=8.1'), true);
    same('8.0.30 does not meet >=8.1', C::meets('8.0.30', '>=8.1'), false);
    same('8.10 is newer than 8.9', C::meets('8.10.0', '>=8.9'), true);
    same('a release suffix is ignored', C::meets('9.0.8-release.1', '>=9.0'), true);
    same('no operator means at least', [C::meets('9.1', '9.0'), C::meets('8.9', '9.0')], [true, false]);
    same('a constraint that cannot be read blocks nobody', C::meets('1.0', 'latest'), true);

    [$g, $r, $s] = judge(facts(['php' => '8.0.2']));
    same('old PHP stops go-live', [$r['php'], $s['blocked']], ['fail', true]);
    [$g, $r, $s] = judge(facts(['whmcs' => '8.13.1']));
    same('old WHMCS stops go-live', [$r['whmcs'], $s['blocked']], ['fail', true]);
    [$g, $r, $s] = judge(facts(['whmcs' => '']));
    same('an unreadable WHMCS version is a warning', [$r['whmcs'], $s['blocked']], ['warn', false]);
    [$g, $r, $s] = judge(facts(['extensions' => ['curl' => false]]));
    same('a missing extension stops go-live', [$r['extensions'], $s['blocked']], ['fail', true]);
    [$g, $r, $s] = judge(facts(['uploads_writable' => false]));
    same('an unwritable upload folder is a warning', [$r['uploads'], $s['blocked']], ['warn', false]);

    // ---------------------------------------------------------------- database
    $section = 'database';
    [$g, $r, $s] = judge(facts(['migrations' => ['pending' => ['Pages']]]));
    same('a pending update is a step to do, and stops go-live', [$r['tables'], $g['database'], $s['blocked']], ['todo', 'todo', true]);
    [$g, $r, $s] = judge(facts(['menus' => 0]));
    same('no menus is a step to do', [$r['menus'], $s['blocked']], ['todo', true]);
    [$g, $r, $s] = judge(facts(['migrations' => ['error' => 'SQLSTATE[HY000]']]));
    same('a database that cannot be read is a problem', [$r['tables'], $s['blocked']], ['fail', true]);

    // ----------------------------------------------------------------- license
    $section = 'license';
    $license = static fn(string $status): array => judge(facts(['license' => ['status' => $status, 'active' => false]]));
    same('no key is a step to do', [$license('No key')[1]['license'], $license('No key')[2]['blocked']], ['todo', true]);
    same('an invalid key is a problem', [$license('Invalid')[1]['license'], $license('Invalid')[2]['blocked']], ['fail', true]);
    same('a revoked key is a problem', $license('Banned')[1]['license'], 'fail');
    same('a status this page has never heard of is a problem', $license('Whatever')[1]['license'], 'fail');
    same('a lapsed license still lets the theme run', [$license('Expired')[1]['license'], $license('Expired')[2]['blocked']], ['warn', false]);
    same('an unreachable license server does not stop go-live', [$license('Unreachable')[1]['license'], $license('Unreachable')[2]['blocked']], ['warn', false]);

    // ------------------------------------------------------- switching on, off
    $section = 'switching';
    $root = sys_get_temp_dir() . '/hadrian-setup-test-' . bin2hex(random_bytes(4));
    mkdir($root . '/templates/twenty-one', 0777, true);
    mkdir($root . '/templates/orderforms/standard_cart', 0777, true);

    Configuration::$rows = ['Template' => 'twenty-one', 'OrderFormTemplate' => 'standard_cart'];
    S::goLive(withCart: true);
    same('both are switched on', [Configuration::getValue('Template'), Configuration::getValue('OrderFormTemplate')], ['hadrian', 'hadrian_cart']);
    same('and what they replaced is remembered', [S::state()['prev_template'], S::state()['prev_orderform']], ['twenty-one', 'standard_cart']);

    S::goLive(withCart: true);
    same('going live twice does not forget the earlier theme', S::state()['prev_template'], 'twenty-one');

    same('switching back works', S::switchBack($root), null);
    same('and puts both back', [Configuration::getValue('Template'), Configuration::getValue('OrderFormTemplate')], ['twenty-one', 'standard_cart']);
    same('and has nothing left to undo', is_string(S::switchBack($root)), true);

    Configuration::$rows = ['Template' => 'twenty-one', 'OrderFormTemplate' => 'standard_cart'];
    S::goLive(withCart: false);
    same('without the cart the order form is left alone', [Configuration::getValue('Template'), Configuration::getValue('OrderFormTemplate'), S::state()['prev_orderform']], ['hadrian', 'standard_cart', '']);

    Configuration::$rows = ['Template' => 'twenty-one', 'OrderFormTemplate' => 'standard_cart'];
    S::goLive(withCart: true);
    Configuration::setValue('Template', 'nexus');       // the admin picked another theme since
    same('switching back still succeeds', S::switchBack($root), null);
    same('but leaves the theme the admin picked', [Configuration::getValue('Template'), Configuration::getValue('OrderFormTemplate')], ['nexus', 'standard_cart']);

    Configuration::$rows = ['Template' => 'gone', 'OrderFormTemplate' => 'standard_cart'];
    S::goLive(withCart: true);
    same('an earlier theme that was deleted is refused', is_string(S::switchBack($root)), true);
    same('and nothing is changed, order form included', [Configuration::getValue('Template'), Configuration::getValue('OrderFormTemplate')], ['hadrian', 'hadrian_cart']);

    rmdir($root . '/templates/orderforms/standard_cart');
    rmdir($root . '/templates/orderforms');
    rmdir($root . '/templates/twenty-one');
    rmdir($root . '/templates');
    rmdir($root);

    echo "\n" . ($ok + $fails) . " checks, {$fails} failing\n";
    exit($fails ? 1 : 0);
}
