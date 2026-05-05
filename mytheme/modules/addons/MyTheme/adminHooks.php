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
