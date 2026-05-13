<?php
declare(strict_types=1);

/**
 * MyTheme front-of-house hook registrations.
 *
 * One ClientAreaPage hook → HookDispatcher (consolidated dispatch instead of Lagom's
 * 6-separate-registrations pattern).
 *
 * Run order:
 *   priority 1   → standard hooks (template guard, auth-related data)
 *   priority -1  → MyTheme variable assembly (runs LAST, sees all other hooks' output)
 */

require_once __DIR__ . DIRECTORY_SEPARATOR . 'autoload.php';

use MyTheme\Helpers\AddonHelper;
use MyTheme\Models\Configuration;
use MyTheme\Service\Hooks as HookService;

// ============================================================================
// License enforcement: kill ?systpl= override of disabled templates
// ============================================================================
add_hook('ClientAreaPage', 1, function ($vars) {
    $disabled = AddonHelper::getNotActiveTemplates();
    if (empty($disabled)) {
        return null;
    }

    $activeTemplate = AddonHelper::getActiveTemplateName();

    if (isset($_SESSION['Template']) && in_array($_SESSION['Template'], $disabled, true)) {
        unset($_SESSION['Template']);
    }
    if (isset($_SESSION['OrderFormTemplate']) && in_array($_SESSION['OrderFormTemplate'], $disabled, true)) {
        unset($_SESSION['OrderFormTemplate']);
    }
    if (isset($_GET['systpl']) && in_array($_GET['systpl'], $disabled, true)) {
        http_response_code(403);
        exit('Template license is not active');
    }

    if (in_array($activeTemplate, $disabled, true)) {
        if (Configuration::getValue('Template') === $activeTemplate) {
            Configuration::setValue('Template', 'six');
        }
        if (Configuration::getValue('OrderFormTemplate') === $activeTemplate) {
            Configuration::setValue('OrderFormTemplate', 'standard_cart');
        }

        if (!headers_sent() && !AddonHelper::isCli()) {
            header('Location: ' . ($_SERVER['REQUEST_URI'] ?? '/'), true, 302);
            exit;
        }

        http_response_code(403);
        exit('Template license is not active');
    }
});

// ============================================================================
// Admin homepage: show license-expiry / license-error banner
// ============================================================================
add_hook('AdminHomepage', 1, function () {
    $template = AddonHelper::getTemplate();
    if ($template === null) {
        return null;
    }
    return $template->license()->getDashboardBanner();
});

// ============================================================================
// Admin head: hide license-disabled templates from the WHMCS template picker
// ============================================================================
add_hook('AdminAreaHeadOutput', 1, function () {
    $disabled = AddonHelper::getNotActiveTemplates();
    if (empty($disabled)) {
        return null;
    }
    $url = (new MyTheme\View\ViewHelper())->script('hide-disabled-templates.js');
    $list = implode(',', $disabled);
    return '<script src="' . htmlspecialchars($url, ENT_QUOTES) . '" data-mytheme-disabled="' . htmlspecialchars($list, ENT_QUOTES) . '"></script>';
});

// ============================================================================
// The main client-area dispatch — ONE hook → HookDispatcher
// ============================================================================
if (AddonHelper::isActive()) {

    // priority -1 = runs LAST, after all per-page hooks have populated their data
    add_hook('ClientAreaPage', -1, function ($vars) {
        return HookService::instance()->dispatch('ClientAreaPage', $vars);
    });

    // Expose the menu icon registry to Smarty as $mtIcons (map of name → SVG
    // path data). sidebar.tpl / topnav.tpl look up {$mtIcons[$name]} when
    // rendering a menu item whose config.icon is a known registry name.
    add_hook('ClientAreaPage', 2, function ($vars) {
        return ['mtIcons' => MyTheme\Menu\Icons::all()];
    });

    add_hook('ClientAreaHeadOutput', 1, function ($vars) {
        return HookService::instance()->dispatch('ClientAreaHeadOutput', $vars);
    });

    add_hook('ClientAreaFooterOutput', 1, function ($vars) {
        return HookService::instance()->dispatch('ClientAreaFooterOutput', $vars);
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
            // MyTheme without going through _upgrade), migrate + seed now.
            // Migrator tracks executed migrations so this is idempotent and
            // costs ~1 ms on subsequent requests.
            if (!\WHMCS\Database\Capsule::schema()->hasTable('mytheme_menus')) {
                $addonRoot = __DIR__;
                (new MyTheme\Database\Migrator($addonRoot))->migrate();
                (new MyTheme\Menu\Seeder())->run();
            }

            $audience = MyTheme\Menu\Audience::current();
            $menu     = MyTheme\Models\Menu::pick('main', $audience);
            if ($menu === null) {
                return; // no custom menu — leave WHMCS's default alone
            }
            // Capture native children before we clear them, so whmcs_default can pass through
            $native = [];
            foreach ($primaryNavbar->getChildren() as $name => $child) {
                $native[$name] = $child;
            }
            $GLOBALS['__mytheme_native_navbar_children'] = $native;

            foreach (array_keys($native) as $name) {
                $primaryNavbar->removeChild($name);
            }
            MyTheme\Menu\TreeRenderer::populate($primaryNavbar, $menu);
            // Stash the ordered flat list in a global so the next
            // ClientAreaPage hook (priority lower than this 100) can expose
            // it to Smarty as $mtSidebarItems. We can't directly return
            // template vars from a Navbar hook.
            $GLOBALS['__mytheme_sidebar_items'] = MyTheme\Menu\TreeRenderer::orderedTopLevel();
        } catch (\Throwable $e) {
            // Don't blow up the page if the menu system fails. Log and let the
            // default WHMCS navbar render.
            if (class_exists('\\WHMCS\\Module\\Addon\\Logger')) {
                logActivity('MyTheme menu render failed: ' . $e->getMessage());
            }
        }
    });

    // Surface the ordered top-level list to Smarty. Runs at priority 3 —
    // AFTER the ClientAreaPrimaryNavbar hook above (which fires earlier in
    // the page lifecycle and populates $GLOBALS) and AFTER the icon registry
    // hook at priority 2, but before the priority 1 / -1 dispatch hooks.
    add_hook('ClientAreaPage', 3, function ($vars) {
        $items = $GLOBALS['__mytheme_sidebar_items'] ?? null;
        return is_array($items) ? ['mtSidebarItems' => $items] : null;
    });

    // Secondary navbar — same pattern (location = secondary). If no menu, leave alone.
    add_hook('ClientAreaSecondaryNavbar', 100, function (WHMCS\View\Menu\Item $secondaryNavbar) {
        try {
            $audience = MyTheme\Menu\Audience::current();
            $menu     = MyTheme\Models\Menu::pick('secondary', $audience);
            if ($menu === null) return;
            $native = [];
            foreach ($secondaryNavbar->getChildren() as $name => $child) {
                $native[$name] = $child;
            }
            $GLOBALS['__mytheme_native_navbar_children'] = $native;
            foreach (array_keys($native) as $name) {
                $secondaryNavbar->removeChild($name);
            }
            MyTheme\Menu\TreeRenderer::populate($secondaryNavbar, $menu);
        } catch (\Throwable $e) {
            if (function_exists('logActivity')) {
                logActivity('MyTheme secondary menu render failed: ' . $e->getMessage());
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

    // AJAX dispatch (front-side)
    if (isset($_POST['mtAction'])) {
        \MyTheme\Service\AjaxService::handle($_POST['mtAction'], $_POST);
    }
}
