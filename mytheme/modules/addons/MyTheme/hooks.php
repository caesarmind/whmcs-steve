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

    add_hook('ClientAreaHeadOutput', 1, function ($vars) {
        return HookService::instance()->dispatch('ClientAreaHeadOutput', $vars);
    });

    add_hook('ClientAreaFooterOutput', 1, function ($vars) {
        return HookService::instance()->dispatch('ClientAreaFooterOutput', $vars);
    });

    add_hook('ClientAreaHomepagePanels', 9, function (WHMCS\View\Menu\Item $panels) {
        return HookService::instance()->dispatch('ClientAreaHomepagePanels', $panels);
    });

    add_hook('ClientAreaPageHome', 1, function ($vars) {
        return HookService::instance()->dispatch('ClientAreaPageHome', $vars);
    });

    // AJAX dispatch (front-side)
    if (isset($_POST['mtAction'])) {
        \MyTheme\Service\AjaxService::handle($_POST['mtAction'], $_POST);
    }
}
