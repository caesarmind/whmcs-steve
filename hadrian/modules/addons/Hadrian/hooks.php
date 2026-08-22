<?php
declare(strict_types=1);

/**
 * Hadrian front-of-house hook registrations.
 *
 * One ClientAreaPage hook → HookDispatcher (consolidated dispatch instead of Lagom's
 * 6-separate-registrations pattern).
 *
 * Run order:
 *   priority 1   → standard hooks (template guard, auth-related data)
 *   priority -1  → Hadrian variable assembly (runs LAST, sees all other hooks' output)
 */

// Load the IntegrityHashes class BEFORE the PSR-4 autoloader is registered.
// In source-tree installs (no build:integrity run yet) the real file is
// absent and only IntegrityHashes.fallback.php exists — but the autoloader
// maps Hadrian\Helpers\IntegrityHashes → src/Helpers/IntegrityHashes.php,
// not the .fallback.php variant, so it can't lazy-load the stub. License,
// LicenseHelper, and Template all call IntegrityHashes::verifyOrDie() from
// their constructors — without this explicit require, every Template
// instantiation in a hook context fatals with "Class … not found", which
// makes the whole $hadrian payload silently disappear from the front-end.
// Hadrian.php (admin entry point) already does this; we need the same in
// hooks.php because WHMCS loads hooks.php directly, not via Hadrian.php.
$_mtIntegrity = __DIR__ . DIRECTORY_SEPARATOR . 'src' . DIRECTORY_SEPARATOR
              . 'Helpers' . DIRECTORY_SEPARATOR . 'IntegrityHashes.php';
if (file_exists($_mtIntegrity)) {
    require_once $_mtIntegrity;
} else {
    require_once __DIR__ . DIRECTORY_SEPARATOR . 'src' . DIRECTORY_SEPARATOR
               . 'Helpers' . DIRECTORY_SEPARATOR . 'IntegrityHashes.fallback.php';
}
unset($_mtIntegrity);

require_once __DIR__ . DIRECTORY_SEPARATOR . 'autoload.php';

use Hadrian\Helpers\AddonHelper;
use Hadrian\Models\Configuration;
use Hadrian\Service\Hooks as HookService;

// ============================================================================
// Branding AJAX intercept — runs BEFORE WHMCS renders admin chrome
// ============================================================================
// Previously lived in adminHooks.php, but adminHooks.php isn't reliably
// auto-loaded on all WHMCS 9 installs for AJAX POSTs (observed: request
// fell through to the normal addonmodules.php → MainController flow,
// which redirected and returned HTML, breaking the JS JSON.parse).
// hooks.php IS reliably auto-loaded for every request, so moving the
// intercept here guarantees it fires. The admin-auth gate below means
// non-admin requests can't reach the upload endpoint by URL guessing.
// ADMINAREA is defined by /admin/addonmodules.php BEFORE init.php is
// included. init.php then does the admin auth check and exit()s with a
// login redirect if the user isn't authenticated -- BEFORE reaching
// the hooks loader. So if this code is executing AND ADMINAREA is
// defined, the user is already verified by WHMCS. No need to repeat
// the session check ourselves (and observed: $_SESSION['adminid'] and
// \WHMCS\Authentication\CurrentUser::isAuthenticatedAdmin() both
// returned empty/false at this lifecycle point on a real WHMCS 9
// install, because the canonical admin-session shape varies across
// versions and init phases).
if (
    defined('ADMINAREA')
    && $_SERVER['REQUEST_METHOD'] === 'POST'
    && ($_GET['module'] ?? '') === 'Hadrian'
    && ($_GET['action'] ?? '') === 'branding'
    && in_array($_GET['sub'] ?? '', ['upload-ajax', 'remove-ajax'], true)
) {
    try {
        $_mtBrandingCtl = new \Hadrian\Controller\Admin\BrandingController();
        if ($_GET['sub'] === 'upload-ajax') {
            $_mtBrandingCtl->uploadAjaxAction();   // never returns
        }
        $_mtBrandingCtl->removeAjaxAction();        // never returns
    } catch (\Throwable $_mtAjaxEx) {
        error_log('Hadrian branding AJAX: ' . $_mtAjaxEx->getMessage()
            . ' at ' . $_mtAjaxEx->getFile() . ':' . $_mtAjaxEx->getLine());
        while (ob_get_level() > 0) { @ob_end_clean(); }
        if (!headers_sent()) {
            http_response_code(500);
            header('Content-Type: application/json; charset=utf-8');
        }
        // Surface the real exception message so the admin can diagnose
        // without grepping the PHP error log. The endpoint is admin-only
        // (gated above), so leaking internals here is acceptable.
        echo json_encode([
            'ok'    => false,
            'error' => 'Server error: ' . $_mtAjaxEx->getMessage(),
        ]);
        exit;
    }
}

// ============================================================================
// Media library AJAX (the image picker behind any [data-mt-media] field).
//
// A SEPARATE gate block on purpose. The branding block above dispatches with
// an else-less fall-through:
//     if ($sub === 'upload-ajax') { uploadAjaxAction(); }
//     removeAjaxAction();
// so any sub added to ITS in_array() that is not 'upload-ajax' silently lands
// in removeAjaxAction(). Here every arm of the match returns `never`, so
// there is nothing to fall through to.
//
// Same auth posture and the same reason as the branding block above: by the
// time this runs, WHMCS has already verified the admin (ADMINAREA is only
// defined inside the admin bootstrap). POST-only, which is why `list` is a
// POST despite being a read — a GET would fall through to addonmodules.php
// and return admin HTML that the caller cannot JSON.parse.
if (
    defined('ADMINAREA')
    && $_SERVER['REQUEST_METHOD'] === 'POST'
    && ($_GET['module'] ?? '') === 'Hadrian'
    && ($_GET['action'] ?? '') === 'media'
    && in_array($_GET['sub'] ?? '', ['list', 'upload', 'delete'], true)
) {
    try {
        $_mtMediaCtl = new \Hadrian\Controller\Admin\MediaController();
        match ($_GET['sub']) {
            'list'   => $_mtMediaCtl->listAction(),    // never returns
            'upload' => $_mtMediaCtl->uploadAction(),  // never returns
            'delete' => $_mtMediaCtl->deleteAction(),  // never returns
        };
    } catch (\Throwable $_mtMediaEx) {
        error_log('Hadrian media AJAX: ' . $_mtMediaEx->getMessage()
            . ' at ' . $_mtMediaEx->getFile() . ':' . $_mtMediaEx->getLine());
        while (ob_get_level() > 0) { @ob_end_clean(); }
        if (!headers_sent()) {
            http_response_code(500);
            header('Content-Type: application/json; charset=utf-8');
        }
        echo json_encode([
            'ok'    => false,
            'error' => 'Server error: ' . $_mtMediaEx->getMessage(),
        ]);
        exit;
    }
}

// ============================================================================
// Admin addon page: full-width canvas (no sidebar flash).
//
// Inject the sidebar/title-hiding CSS into the admin <head> so it applies
// before first paint. The WHMCS left sidebar then never renders on our page,
// so there's no fade/flash on refresh -- unlike hiding it from the addon's own
// body output (which runs after the sidebar has already painted). Registered
// unconditionally (admin chrome shouldn't depend on license state) but the
// CSS is only emitted on the Hadrian addon page; every other admin page keeps
// its sidebar. Mirrors how themes like Lagom style the admin via *HeadOutput.
// ============================================================================
add_hook('AdminAreaHeadOutput', 1, function ($vars) {
    if (($_GET['module'] ?? '') !== 'Hadrian') {
        return '';
    }
    // Inline the whole admin stylesheet into the <head> so it loads before first
    // paint -- otherwise the CSS (previously a <style> at the end of the addon's
    // body output) arrived after the brand bar had already painted, flashing the
    // unstyled "Hostnodes / Hadrian" text. Read server-side: no extra HTTP
    // request and no dependency on the assets path being web-accessible. The
    // sidebar/full-width rules live at the top of admin.css.
    $cssFile = __DIR__ . '/views/adminarea/assets/css/admin.css';
    $css = is_file($cssFile) ? (string) file_get_contents($cssFile) : '';
    return "<style id=\"mt-admin-css\">\n" . $css . "\n</style>";
});

// ============================================================================
// Licensing is handled externally by whmcs-licensing-modern
// (modules/servers/licensing + includes/hooks/hostnodes_theme_license.php).
//
// The Hadrian addon's own license enforcement, admin dashboard banner, and
// "hide disabled templates" hooks are intentionally DISABLED so the two
// systems don't conflict — and so the dev-mode nag (which steers you to flip
// dev_mode, re-activating this dormant path) never appears. The License*
// classes remain under src/Template/ but are now unused.
// ============================================================================

// ============================================================================
// The main client-area dispatch — ONE hook → HookDispatcher
// ============================================================================
if (AddonHelper::isActive()) {

    // priority -1 = runs LAST, after all per-page hooks have populated their data
    add_hook('ClientAreaPage', -1, function ($vars) {
        return HookService::instance()->dispatch('ClientAreaPage', $vars);
    });

    // Record the request language for the ClientAreaPrimaryNavbar /
    // ClientAreaSecondaryNavbar populate() paths, which receive no $vars.
    // Priority -1000 so it precedes every other ClientAreaPage hook. The three
    // buildFlatList hooks record it themselves, so the sidebar/footer path does
    // NOT depend on this ordering.
    add_hook('ClientAreaPage', -1000, function ($vars) {
        Hadrian\Helpers\LocaleHelper::rememberRequestLocale((string)($vars['language'] ?? ''));
        return null;
    });

    // Expose the menu icon registry to Smarty as $mtIcons (map of name → SVG
    // path data). sidebar.tpl / topnav.tpl look up {$mtIcons[$name]} when
    // rendering a menu item whose config.icon is a known registry name.
    //
    // Also surfaces $mtTopnavShowIcons (boolean) — the admin Settings flag
    // that gates per-item icon rendering in the top-nav. Defaults to false,
    // so unconfigured installs get a clean text-only nav.
    //
    // Dark-mode variables (Lagom-parity model):
    //   $mtEnableDarkMode  (bool)  — master "Enable Dark Mode" flag.
    //   $mtShowDarkToggle  (bool)  — show the light/dark switcher? Only when
    //                                enabled AND Display Type = Switcher
    //                                (Forced hides it). Gates the toggle markup.
    //   $mtThemeMode       (string)— initial data-theme: the Default Mode when
    //                                enabled, else 'light'. Server-rendered so
    //                                there's no flash for the default.
    //   $mtDarkMode        (string)— 'off' | 'switcher' | 'forced'; read by
    //                                core-theme.js to decide whether a saved
    //                                preference may override the default.
    add_hook('ClientAreaPage', 2, function ($vars) {
        $darkEnabled = (bool)Hadrian\Models\Settings::getValue('enable_dark_mode', true);
        $darkDisplay = (string)Hadrian\Models\Settings::getValue('dark_mode_display', 'switcher');
        $darkDefault = (string)Hadrian\Models\Settings::getValue('dark_mode_default', 'light');
        if (!in_array($darkDisplay, ['switcher', 'forced'], true)) { $darkDisplay = 'switcher'; }
        if (!in_array($darkDefault, ['light', 'dark'], true))      { $darkDefault = 'light'; }

        /* The visitor's own choice, read SERVER-side so the very first painted
           frame is already right.

           It used to live only in localStorage, which the server cannot see:
           header.tpl rendered the admin's default, then core-theme.js -- loaded
           down in footer.tpl -- corrected it after the page had already painted.
           A returning visitor who had chosen dark on a light-default site
           therefore saw the whole page flash light on every single load.

           Same shape as the mt_layout cookie in Menu\TreeRenderer: read it,
           allow-list it, fall back to the configured default. Only honoured
           under 'switcher' -- 'forced' means the admin decided, so a stale
           cookie must not override it (core-theme.js clears it in that mode). */
        $themeMode = $darkEnabled ? $darkDefault : 'light';
        if ($darkEnabled && $darkDisplay === 'switcher') {
            $cookie = $_COOKIE['mt_theme'] ?? null;
            if (in_array($cookie, ['light', 'dark'], true)) {
                $themeMode = $cookie;
            }
        }

        return [
            'mtIcons'            => Hadrian\Menu\Icons::all(),
            'mtTopnavShowIcons'  => (bool)Hadrian\Models\Settings::getValue('topnav_show_icons', false),
            'mtEnableDarkMode'   => $darkEnabled,
            'mtShowDarkToggle'   => $darkEnabled && $darkDisplay === 'switcher',
            'mtThemeMode'        => $themeMode,
            'mtDarkMode'         => $darkEnabled ? $darkDisplay : 'off',
        ];
    });

    // Global cart count → $globalCartCount on EVERY client-area page.
    //
    // WHMCS only populates $cartitems on cart-flow pages (cart.php, viewcart,
    // configureproduct, etc.), so the .topbar-cart-badge in topnav.tpl /
    // inner-topbar.tpl can't render on plain clientarea routes
    // (clientareahome, services, domains, etc.) even when items ARE in the
    // session cart. This hook inspects the cart on every page render and
    // surfaces the total item count so the badge fires everywhere.
    //
    // Strategy:
    //  1. Prefer WHMCS\Cart\Cart::getInstance() with getProductCount() +
    //     getDomainCount() — the documented API.
    //  2. Fall back to a direct $_SESSION['cart'] inspection counting
    //     products + domains + addons (mirrors how WHMCS itself derives
    //     $cartitems inside cart.php).
    //  3. Always return an int — 0 when no cart session exists.
    //
    // Defensive throughout: any exception falls through to the session
    // count, and any malformed session still yields 0 instead of fataling.
    add_hook('ClientAreaPage', 2, function ($vars) {
        $count = 0;
        try {
            if (class_exists('\\WHMCS\\Cart\\Cart')) {
                $cart = \WHMCS\Cart\Cart::getInstance();
                if (method_exists($cart, 'getProductCount')) {
                    $count += (int) $cart->getProductCount();
                }
                if (method_exists($cart, 'getDomainCount')) {
                    $count += (int) $cart->getDomainCount();
                }
            }
        } catch (\Throwable $e) {
            // Fall through to the session-based fallback below.
        }
        if ($count === 0 && isset($_SESSION['cart']) && is_array($_SESSION['cart'])) {
            foreach (['products', 'domains', 'addons'] as $bucket) {
                if (isset($_SESSION['cart'][$bucket]) && is_array($_SESSION['cart'][$bucket])) {
                    $count += count($_SESSION['cart'][$bucket]);
                }
            }
        }
        return ['globalCartCount' => $count];
    });

    add_hook('ClientAreaHeadOutput', 1, function ($vars) {
        return HookService::instance()->dispatch('ClientAreaHeadOutput', $vars);
    });

    add_hook('ClientAreaFooterOutput', 1, function ($vars) {
        return HookService::instance()->dispatch('ClientAreaFooterOutput', $vars);
    });

    // Login page — expose the latest published announcements to the login
    // template ($loginAnnouncements). The "split" login variant features them
    // in its side panel; other variants simply ignore the var.
    add_hook('ClientAreaPageLogin', 1, function ($vars) {
        return HookService::instance()->dispatch('ClientAreaPageLogin', $vars);
    });

    // Public homepage — expose the real product catalogue as $homeProductGroups
    // so the "product categories" section renders live groups and prices rather
    // than hardcoded tiers. WHMCS has no ClientAreaPageHomepage hook, so this
    // rides the generic ClientAreaPage and guards on templatefile — the same
    // approach Lagom uses for its homepage vars.
    //
    // $announcements is NOT fetched here: WHMCS already passes it to
    // homepage.tpl natively (see stock six/homepage.tpl).
    add_hook('ClientAreaPage', 2, function ($vars) {
        if (($vars['templatefile'] ?? '') !== 'homepage') {
            return null;
        }
        return HookService::instance()->dispatch('ClientAreaPageHomepage', $vars);
    });

    add_hook('ClientAreaHomepagePanels', 9, function (WHMCS\View\Menu\Item $panels) {
        return HookService::instance()->dispatch('ClientAreaHomepagePanels', $panels);
    });

    // Primary navbar — pull active Menu from DB and repopulate. Priority 100
    // so WHMCS's own default-item registrations have all run first; we stash
    // their result into $GLOBALS for the whmcs_default item type to pick up.
    add_hook('ClientAreaPrimaryNavbar', 100, function (WHMCS\View\Menu\Item $primaryNavbar) {
        try {
            // Self-heal: if the menu tables don't exist yet (admin upgraded
            // Hadrian without going through _upgrade), migrate + seed now.
            // Migrator tracks executed migrations so this is idempotent and
            // costs ~1 ms on subsequent requests.
            if (!\WHMCS\Database\Capsule::schema()->hasTable('hadrian_menus')) {
                $addonRoot = __DIR__;
                (new Hadrian\Database\Migrator($addonRoot))->migrate();
                (new Hadrian\Menu\Seeder())->run();
            }

            $audience = Hadrian\Menu\Audience::current();
            $menu     = Hadrian\Models\Menu::pick('main', $audience);
            if ($menu === null) {
                return; // no custom menu — leave WHMCS's default alone
            }
            // Capture native children before we clear them, so whmcs_default can pass through
            $native = [];
            foreach ($primaryNavbar->getChildren() as $name => $child) {
                $native[$name] = $child;
            }
            $GLOBALS['__hadrian_native_navbar_children'] = $native;

            foreach (array_keys($native) as $name) {
                $primaryNavbar->removeChild($name);
            }
            Hadrian\Menu\TreeRenderer::populate($primaryNavbar, $menu);
        } catch (\Throwable $e) {
            // Don't blow up the page if the menu system fails. Log and let the
            // default WHMCS navbar render.
            if (class_exists('\\WHMCS\\Module\\Addon\\Logger')) {
                logActivity('Hadrian menu render failed: ' . $e->getMessage());
            }
        }
    });

    // Surface the menu as a flat ordered list to Smarty. We build this
    // INDEPENDENTLY of WHMCS's $primaryNavbar (which is populated by
    // ClientAreaPrimaryNavbar hooks that fire LATER in the page lifecycle,
    // after ClientAreaPage hooks). Building it here means $mtSidebarItems is
    // ready when the template renders — no race condition.
    add_hook('ClientAreaPage', 3, function ($vars) {
        try {
            Hadrian\Helpers\LocaleHelper::rememberRequestLocale((string)($vars['language'] ?? ''));
            if (!\WHMCS\Database\Capsule::schema()->hasTable('hadrian_menus')) {
                return null;
            }
            $audience = Hadrian\Menu\Audience::current();
            $menu     = Hadrian\Models\Menu::pick('main', $audience);
            if ($menu === null) return null;
            $items = Hadrian\Menu\TreeRenderer::buildFlatList($menu);
            return ['mtSidebarItems' => $items];
        } catch (\Throwable $e) {
            error_log('Hadrian buildFlatList failed: ' . $e->getMessage());
            return null;
        }
    });

    // Footer menu — same pattern as the sidebar, but for location=footer.
    // Surfaces $mtFooterItems so footer.tpl renders the admin-driven column
    // layout. Audience falls back to 'all' inside Menu::pick when no
    // audience-specific footer is configured.
    add_hook('ClientAreaPage', 3, function ($vars) {
        try {
            Hadrian\Helpers\LocaleHelper::rememberRequestLocale((string)($vars['language'] ?? ''));
            if (!\WHMCS\Database\Capsule::schema()->hasTable('hadrian_menus')) {
                return null;
            }
            // Self-heal: the main-menu seed runs only when the whole menus
            // table is empty (see MenuController::indexAction). Existing
            // installs that already had main-menu rows when the footer
            // preset shipped never get the footer seeded automatically.
            // Top up here once, idempotent — the Seeder skips menus whose
            // (name, location) already exists.
            if (Hadrian\Models\Menu::where('location', 'footer')->count() === 0) {
                (new Hadrian\Menu\Seeder())->run();
            }
            $audience = Hadrian\Menu\Audience::current();
            $menu     = Hadrian\Models\Menu::pick('footer', $audience);
            if ($menu === null) return null;
            $items = Hadrian\Menu\TreeRenderer::buildFlatList($menu);
            return ['mtFooterItems' => $items];
        } catch (\Throwable $e) {
            error_log('Hadrian footer buildFlatList failed: ' . $e->getMessage());
            return null;
        }
    });

    // Footer secondary menu — drives the bottom legal-links row of the
    // footer (Privacy / Terms / etc.). Same pattern as the footer hook
    // above. Items are returned as a flat list; footer TPLs render leaf
    // links only — dropdowns are not surfaced for this location.
    add_hook('ClientAreaPage', 3, function ($vars) {
        try {
            Hadrian\Helpers\LocaleHelper::rememberRequestLocale((string)($vars['language'] ?? ''));
            if (!\WHMCS\Database\Capsule::schema()->hasTable('hadrian_menus')) {
                return null;
            }
            // Self-heal: if the seed predates the footer-secondary preset,
            // run the Seeder once to top up. Same idempotency guard as the
            // footer hook above — Seeder skips menus that already exist.
            if (Hadrian\Models\Menu::where('location', 'footer-secondary')->count() === 0) {
                (new Hadrian\Menu\Seeder())->run();
            }
            $audience = Hadrian\Menu\Audience::current();
            $menu     = Hadrian\Models\Menu::pick('footer-secondary', $audience);
            if ($menu === null) return null;
            $items = Hadrian\Menu\TreeRenderer::buildFlatList($menu);
            return ['mtFooterSecondaryItems' => $items];
        } catch (\Throwable $e) {
            error_log('Hadrian footer-secondary buildFlatList failed: ' . $e->getMessage());
            return null;
        }
    });

    // Brand info — exposes $mtBrand to all client-area templates. Drives the
    // footer brand block (logo, description, social URLs) and is intended to
    // be the single source of truth for brand display across layouts. Empty
    // values are kept as empty strings so TPLs can `{if !empty(...)}`-guard
    // each piece individually without `isset()` ceremony.
    add_hook('ClientAreaPage', 3, function ($vars) {
        try {
            $uploader = new Hadrian\Helpers\Uploader();
            $logoLight = (string)Hadrian\Models\Settings::getValue('logo_light', '');
            $logoDark  = (string)Hadrian\Models\Settings::getValue('logo_dark',  '');
            $socials = [];
            foreach (['x', 'linkedin', 'facebook', 'github', 'youtube', 'instagram'] as $platform) {
                $socials[$platform] = (string)Hadrian\Models\Settings::getValue('footer_social_' . $platform, '');
            }
            return [
                'mtBrand' => [
                    'description' => (string)Hadrian\Models\Settings::getValue('footer_description', ''),
                    // Each variant falls back to the other, matching
                    // Hooks::buildBranding. Without the mirror, an install with
                    // only a light logo emitted an empty logoDarkUrl -- the
                    // footer template skips the <img> entirely, and the footer
                    // CSS hides .is-light under [data-theme="dark"], so the
                    // brand vanished from the footer in dark mode rather than
                    // falling back to the one file that was uploaded.
                    'logoUrl'     => $logoLight !== '' ? $uploader->webUrlFor($logoLight)
                                                       : ($logoDark !== '' ? $uploader->webUrlFor($logoDark) : ''),
                    'logoDarkUrl' => $logoDark  !== '' ? $uploader->webUrlFor($logoDark)
                                                       : ($logoLight !== '' ? $uploader->webUrlFor($logoLight) : ''),
                    'socials'     => $socials,
                ],
            ];
        } catch (\Throwable $e) {
            error_log('Hadrian brand-info hook failed: ' . $e->getMessage());
            return null;
        }
    });

    // Secondary navbar — same pattern (location = secondary). If no menu, leave alone.
    add_hook('ClientAreaSecondaryNavbar', 100, function (WHMCS\View\Menu\Item $secondaryNavbar) {
        try {
            $audience = Hadrian\Menu\Audience::current();
            $menu     = Hadrian\Models\Menu::pick('secondary', $audience);
            if ($menu === null) return;
            $native = [];
            foreach ($secondaryNavbar->getChildren() as $name => $child) {
                $native[$name] = $child;
            }
            $GLOBALS['__hadrian_native_navbar_children'] = $native;
            foreach (array_keys($native) as $name) {
                $secondaryNavbar->removeChild($name);
            }
            Hadrian\Menu\TreeRenderer::populate($secondaryNavbar, $menu);
        } catch (\Throwable $e) {
            if (function_exists('logActivity')) {
                logActivity('Hadrian secondary menu render failed: ' . $e->getMessage());
            }
        }
    });

    add_hook('ClientAreaPageHome', 1, function ($vars) {
        return HookService::instance()->dispatch('ClientAreaPageHome', $vars);
    });

    // Populate $mtProducts on the My Services page so the tpl can fall back
    // to it when WHMCS's native $products variable isn't available in scope.
    add_hook('ClientAreaPageProductsServices', 1, function ($vars) {
        return HookService::instance()->dispatch('ClientAreaPageProductsServices', $vars);
    });

    // Same belt-and-braces fallback for tickets / invoices / domains —
    // exposes $mtTickets / $mtInvoices / $mtDomains so each list page
    // renders even when WHMCS doesn't propagate its native variable to
    // our included variant tpl.
    add_hook('ClientAreaPageSupportTickets', 1, function ($vars) {
        return HookService::instance()->dispatch('ClientAreaPageSupportTickets', $vars);
    });

    add_hook('ClientAreaPageInvoices', 1, function ($vars) {
        return HookService::instance()->dispatch('ClientAreaPageInvoices', $vars);
    });

    add_hook('ClientAreaPageDomains', 1, function ($vars) {
        return HookService::instance()->dispatch('ClientAreaPageDomains', $vars);
    });

    add_hook('ClientAreaPageQuotes', 1, function ($vars) {
        return HookService::instance()->dispatch('ClientAreaPageQuotes', $vars);
    });

    // ── Order Process: server-side root-password strength enforcement ──────
    // The cart's Configure Server step (hadrian_cart/configureproduct.tpl)
    // posts a hidden rootpwstrength=true alongside the root password when the
    // "Enable Password Strength" order-process setting is on. Re-score it here
    // with the SAME algorithm as the client meter (ported from Lagom's
    // PasswordStrength.js) so a weak password can't slip through with JS off
    // or tampered. Returning a non-empty array blocks the cart update.
    // Mirrors Lagom's ShoppingCartValidateProductUpdate hook.
    add_hook('ShoppingCartValidateProductUpdate', 1, function ($vars) {
        $flag = (string)($vars['rootpwstrength'] ?? $_POST['rootpwstrength'] ?? '');
        if ($flag !== 'true') {
            return;
        }
        if (!(bool)Hadrian\Models\Settings::getValue('op_root_pw_strength', false)) {
            return;
        }
        $pw = (string)($vars['rootpw'] ?? $_POST['rootpw'] ?? '');
        if ($pw === '') {
            return; // empty hostname/pw handling is WHMCS's own concern
        }
        // getPasswordStrength() parity: length(<=5)*10-20 + numeric(<=3)*10
        // + symbols(<=3)*15 + upper(<=3)*10, clamped 0-100. <50 = "weak".
        $len     = min(strlen($pw), 5);
        $numeric = min((int)preg_match_all('/[0-9]/', $pw), 3);
        $symbols = min((int)preg_match_all('/\W/', $pw), 3);
        $upper   = min((int)preg_match_all('/[A-Z]/', $pw), 3);
        $score   = max(0, min(100, ($len * 10 - 20) + ($numeric * 10) + ($symbols * 15) + ($upper * 10)));
        if ($score < 50) {
            return ['The root password is too weak. Please choose a stronger password (mix upper & lowercase letters, numbers and symbols).'];
        }
    });

    // AJAX dispatch (front-side)
    if (isset($_POST['mtAction'])) {
        \Hadrian\Service\AjaxService::handle($_POST['mtAction'], $_POST);
    }
}
