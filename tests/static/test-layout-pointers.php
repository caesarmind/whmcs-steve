<?php
/**
 * Layout picks: which layout is drawn, for whom, and which area a page is in.
 *
 * Runs Hadrian's real LayoutPointers and PageArea classes against an in-memory
 * stand-in for the settings table, so no WHMCS and no database is needed. The
 * client render and the admin Layouts page both resolve through
 * LayoutPointers, so what passes here is what both of them do.
 *
 *   php tests/static/test-layout-pointers.php
 */

declare(strict_types=1);

namespace Hadrian\Models {
    /** In-memory stand-in for hadrian_settings. Declared before the real one can load. */
    final class Settings
    {
        /** @var array<string,mixed> */
        public static array $rows = [];

        public static function getValue(string $key, mixed $default = null): mixed
        {
            return array_key_exists($key, self::$rows) ? self::$rows[$key] : $default;
        }

        public static function setValue(string $key, mixed $value, string $type = 'string'): void
        {
            self::$rows[$key] = $value;
        }
    }
}

namespace {
    use Hadrian\Helpers\LayoutPointers as P;
    use Hadrian\Helpers\PageArea as A;
    use Hadrian\Models\Settings;

    $src = dirname(__DIR__, 2) . '/hadrian/modules/addons/Hadrian/src/Helpers';
    require $src . '/PageArea.php';
    require $src . '/LayoutPointers.php';

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

    $menus   = ['top', 'sidebar', 'rail'];
    $footers = ['default', 'extended'];
    $valid   = ['main-menu' => $menus, 'footer' => $footers];
    $draw    = static fn(string $kind, string $audience, string $area): string => P::resolve('t', $kind, $audience, $area, $kind === 'footer' ? $footers : $menus);

    // ------------------------------------------------------------ page areas
    $section = 'areas';
    same('a page that states its area is believed', A::forPage('anything', true, ['area' => 'website', 'group' => 'Billing']), 'website');
    same('an area that is not one of the three is ignored', A::forPage('clientareahome', false, ['area' => 'moon', 'group' => 'Client Area']), 'client');
    same('the homepage is the website', A::forPage('homepage', false, ['group' => 'Public']), 'website');
    same('a store landing page is the website, even with the cart flag up', A::forPage('store/ox/index', true, ['group' => 'Shop']), 'website');
    same('the store order page states that it is part of an order', A::forPage('store/order', true, ['group' => 'Shop', 'area' => 'order']), 'order');
    same('an order-form step has no page of its own and follows the cart flag', A::forPage('configureproduct', true, []), 'order');
    same('the product listing served from a store route is an order step too', A::forPage('products', true, []), 'order');
    same('a page a module draws is the website', A::forPage('module-page', false, []), 'website');
    same('the dashboard is the client area', A::forPage('clientareahome', false, ['group' => 'Client Area']), 'client');
    same('support pages are the client area', A::forPage('supporttickets', false, ['group' => 'Support']), 'client');
    same('a page nothing is known about is the client area', A::forPage('some-module-page', false, []), 'client');
    // What a visitor meets before signing in belongs to the website.
    same('sign-in and registration are the website', [A::forPage('login', false, ['group' => 'Authentication']), A::forPage('clientregister', false, ['group' => 'Authentication'])], ['website', 'website']);
    same('a "no such address" page is the website', [A::forPage('error/page-not-found', false, []), A::forPage('error/unknown-routepath', false, [])], ['website', 'website']);
    // The pick an admin makes in the page editor beats everything else.
    same('an admin pick beats what the page declares', A::forPage('knowledgebase', false, ['group' => 'Support', 'area' => 'website'], 'client'), 'client');
    same('and beats the cart flag', A::forPage('viewcart', true, [], 'website'), 'website');
    same('an admin pick that is not an area is ignored', A::forPage('clientareahome', false, ['group' => 'Client Area'], 'moon'), 'client');
    same('no admin pick leaves the page to its own rules', A::forPage('knowledgebase', false, ['group' => 'Support', 'area' => 'website'], ''), 'website');

    // The shipped pages a guest reads say so themselves.
    $pagesDir = dirname(__DIR__, 2) . '/hadrian/templates/hadrian/core/pages';
    foreach (['knowledgebase', 'knowledgebasearticle', 'knowledgebasecat', 'announcements', 'viewannouncement', 'login', 'clientregister', 'homepage', 'contact'] as $guestPage) {
        $meta = require $pagesDir . '/' . $guestPage . '/page.php';
        same("{$guestPage} is filed under the website", A::forPage($guestPage, false, $meta), 'website');
    }
    foreach (['clientareahome', 'clientareainvoices', 'supporttickets', 'viewticket', 'clientareadetails'] as $portalPage) {
        $meta = require $pagesDir . '/' . $portalPage . '/page.php';
        same("{$portalPage} is filed under the client area", A::forPage($portalPage, false, $meta), 'client');
    }
    same('store-order is filed under the order process', A::forPage('store/order', true, require $pagesDir . '/store-order/page.php'), 'order');
    same('three areas, labelled and described', [array_keys(A::LABELS), array_keys(A::HELP)], [['website', 'client', 'order'], ['website', 'client', 'order']]);

    // --------------------------------------------------- by visitor (default)
    $section = 'by visitor';
    Settings::$rows = [];
    same('an install that never chose is in visitor mode', P::mode('t'), P::MODE_AUDIENCE);
    same('with nothing stored the menu is the sidebar', $draw('main-menu', 'guest', 'website'), 'sidebar');
    same('and the footer is the extended one', $draw('footer', 'client', 'client'), 'extended');

    Settings::$rows = ['t_active_layout_main-menu' => 'top'];
    same('the old single pick serves both audiences', [$draw('main-menu', 'guest', 'website'), $draw('main-menu', 'client', 'client')], ['top', 'top']);

    Settings::$rows = ['t_active_layout_main-menu' => 'top', 't_active_layout_main-menu_client' => 'rail'];
    same('a per-audience pick wins over it', [$draw('main-menu', 'guest', 'order'), $draw('main-menu', 'client', 'order')], ['top', 'rail']);
    same('the area makes no difference in visitor mode', [$draw('main-menu', 'client', 'website'), $draw('main-menu', 'client', 'client')], ['rail', 'rail']);

    Settings::$rows = ['t_active_layout_main-menu_guest' => 'deleted-layout'];
    same('a pick naming a layout that no longer exists draws the default', $draw('main-menu', 'guest', 'website'), 'sidebar');
    same('and the stored value is left alone', Settings::$rows['t_active_layout_main-menu_guest'], 'deleted-layout');

    // An area pick stored while in visitor mode must not leak in.
    Settings::$rows = ['t_active_layout_main-menu_area_website' => 'top'];
    same('an area pick is ignored in visitor mode', $draw('main-menu', 'guest', 'website'), 'sidebar');

    // ------------------------------------------------- switching to by area
    $section = 'switching';
    Settings::$rows = [
        't_active_layout_main-menu_guest'  => 'top',
        't_active_layout_main-menu_client' => 'rail',
        't_active_layout_footer_guest'     => 'default',
    ];
    $before = [
        'website/guest' => $draw('main-menu', 'guest', 'website'), 'order/guest' => $draw('main-menu', 'guest', 'order'),
        'client/client' => $draw('main-menu', 'client', 'client'), 'footer/guest' => $draw('footer', 'guest', 'website'),
        'footer/client' => $draw('footer', 'client', 'client'),
    ];
    P::setMode('t', 'area', $valid);
    same('the mode is stored', P::mode('t'), P::MODE_AREA);
    same('the website and the order process start from the guest pick, the client area from the client pick',
        [P::forArea('t', 'main-menu', 'website', $menus), P::forArea('t', 'main-menu', 'order', $menus), P::forArea('t', 'main-menu', 'client', $menus)],
        ['top', 'top', 'rail']);
    same('a guest on the website, a guest ordering and a client in the portal see what they saw before', [
        'website/guest' => $draw('main-menu', 'guest', 'website'), 'order/guest' => $draw('main-menu', 'guest', 'order'),
        'client/client' => $draw('main-menu', 'client', 'client'), 'footer/guest' => $draw('footer', 'guest', 'website'),
        'footer/client' => $draw('footer', 'client', 'client'),
    ], $before);
    same('the visitor picks are untouched', [Settings::$rows['t_active_layout_main-menu_guest'], Settings::$rows['t_active_layout_main-menu_client']], ['top', 'rail']);

    // ----------------------------------------------------------------- by area
    $section = 'by area';
    P::setForArea('t', 'main-menu', 'order', 'sidebar');
    same('each area draws its own pick', [$draw('main-menu', 'guest', 'website'), $draw('main-menu', 'guest', 'client'), $draw('main-menu', 'guest', 'order')], ['top', 'rail', 'sidebar']);
    same('whoever is looking', [$draw('main-menu', 'client', 'website'), $draw('main-menu', 'client', 'order')], ['top', 'sidebar']);
    same('an unknown area is treated as the client area', $draw('main-menu', 'guest', 'nowhere'), 'rail');
    P::setForArea('t', 'main-menu', 'nowhere', 'top');
    same('and cannot be written to', array_key_exists('t_active_layout_main-menu_area_nowhere', Settings::$rows), false);
    Settings::$rows['t_active_layout_main-menu_area_website'] = 'deleted-layout';
    same('a pick naming a layout that no longer exists draws the default', $draw('main-menu', 'guest', 'website'), 'sidebar');
    Settings::$rows['t_active_layout_main-menu_area_website'] = 'top';

    // ------------------------------------------------------- back and forth
    $section = 'back and forth';
    P::setMode('t', 'audience', $valid);
    same('back in visitor mode the visitor picks apply again', [$draw('main-menu', 'guest', 'order'), $draw('main-menu', 'client', 'order')], ['top', 'rail']);
    P::setForAudience('t', 'main-menu', 'guest', 'rail');
    P::setMode('t', 'area', $valid);
    same('returning to area mode keeps the area picks made earlier', [$draw('main-menu', 'guest', 'website'), $draw('main-menu', 'guest', 'order')], ['top', 'sidebar']);
    P::setMode('t', 'nonsense', $valid);
    same('an unknown mode is visitor mode', P::mode('t'), P::MODE_AUDIENCE);
    P::setForAudience('t', 'main-menu', 'everyone', 'top');
    same('an unknown audience cannot be written to', array_key_exists('t_active_layout_main-menu_everyone', Settings::$rows), false);

    // A second template keeps its own picks.
    $section = 'per template';
    same('another template is not affected', [P::mode('other'), P::resolve('other', 'main-menu', 'guest', 'website', $menus)], [P::MODE_AUDIENCE, 'sidebar']);

    echo "\n" . ($ok + $fails) . " checks, {$fails} failing\n";
    exit($fails ? 1 : 0);
}
