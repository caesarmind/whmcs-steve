<?php
declare(strict_types=1);

/**
 * MyTheme admin-side glue.
 *
 * Runs only when an admin is authenticated. Keeps caches in sync when admin
 * edits products/currencies/etc. Intercepts configgeneral.php POST to prevent
 * setting a license-disabled template as the system default.
 */

require_once __DIR__ . DIRECTORY_SEPARATOR . 'autoload.php';

use MyTheme\Helpers\AddonHelper;

$user = new WHMCS\Authentication\CurrentUser();
if (!$user->isAuthenticatedAdmin()) {
    return;
}

// ============================================================================
// Branding AJAX intercept — runs BEFORE WHMCS renders admin chrome
// ============================================================================
// WHMCS calls addonmodules.php → admin header echo → _output() → admin
// footer. Returning JSON from inside _output() corrupts the response
// because the header HTML has already been flushed. Intercepting here
// (which fires during WHMCS's hook init, before any HTML output) lets
// us reply with a clean JSON body.
//
// Gated to the two AJAX sub-routes only; everything else falls through
// to the normal addonmodules.php → MainController flow.
if (
    $_SERVER['REQUEST_METHOD'] === 'POST'
    && ($_GET['module'] ?? '') === 'MyTheme'
    && ($_GET['action'] ?? '') === 'branding'
    && in_array($_GET['sub'] ?? '', ['upload-ajax', 'remove-ajax'], true)
) {
    try {
        $brandingCtl = new \MyTheme\Controller\Admin\BrandingController();
        if ($_GET['sub'] === 'upload-ajax') {
            $brandingCtl->uploadAjaxAction();   // never returns
        }
        $brandingCtl->removeAjaxAction();        // never returns
    } catch (\Throwable $e) {
        error_log('MyTheme branding AJAX: ' . $e->getMessage());
        while (ob_get_level() > 0) { @ob_end_clean(); }
        if (!headers_sent()) {
            http_response_code(500);
            header('Content-Type: application/json; charset=utf-8');
        }
        echo json_encode(['ok' => false, 'error' => 'Server error — check the WHMCS activity log.']);
        exit;
    }
}

// ============================================================================
// configgeneral.php POST guard: rewrite license-disabled template to 'six'
// ============================================================================
if (
    $_SERVER['REQUEST_METHOD'] === 'POST'
    && basename($_SERVER['SCRIPT_NAME']) === 'configgeneral.php'
    && isset($_GET['action']) && $_GET['action'] === 'save'
) {
    $disabled = AddonHelper::getNotActiveTemplates();
    if (!empty($disabled)) {
        if (isset($_POST['template']) && in_array($_POST['template'], $disabled, true)) {
            $_REQUEST['template'] = 'six';
            $_POST['template']    = 'six';
        }
        if (isset($_POST['orderformtemplate']) && in_array($_POST['orderformtemplate'], $disabled, true)) {
            $_REQUEST['orderformtemplate'] = 'standard_cart';
            $_POST['orderformtemplate']    = 'standard_cart';
        }
    }
}

// ============================================================================
// Lazy-load admin-side hook fragments only on the addon's own page
// (avoids loading them on every admin request)
// ============================================================================
global $config;
if (
    isset($_GET['module'])
    && $_GET['module'] === 'MyTheme'
    && strstr($_SERVER['SCRIPT_NAME'] ?? '', $config->customadminpath . '/addonmodules.php')
) {
    $fragments = glob(__DIR__ . DS . 'src' . DS . 'Hooks' . DS . '*.php') ?: [];
    foreach ($fragments as $fragment) {
        require_once $fragment;
    }
}
