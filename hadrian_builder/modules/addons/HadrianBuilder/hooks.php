<?php
declare(strict_types=1);

/**
 * Hadrian Page Builder: hook registrations.
 *
 * WHMCS loads this file on every request while the addon is active, in no
 * promised order relative to Hadrian's own hooks.php. Nothing here assumes
 * Hadrian loaded first; src/Bridge.php brings its classes in on demand.
 */

if (!defined('WHMCS')) {
    exit('This file cannot be accessed directly');
}

require_once __DIR__ . DIRECTORY_SEPARATOR . 'autoload.php';

use HadrianBuilder\AdminController;
use HadrianBuilder\Bridge;
use HadrianBuilder\Router;

// ============================================================================
// NO ADMIN REQUEST IS ANSWERED FROM THIS FILE.
//
// The editor's JSON endpoints (preview, save, publish) are handled in
// AdminController::dispatch(), reached through HadrianBuilder_output(). WHMCS
// loads hooks.php BEFORE it checks that anyone is signed in, so a handler
// that answered and exited here would run for anyone on the internet.
// _output() runs after WHMCS has enforced the admin login AND this addon's
// role permissions, so the endpoints inherit both.
// ============================================================================

// ============================================================================
// Built pages.
//
// A path WHMCS has no route for reaches this hook as its "page not found"
// page, before anything is sent. If the path is the address of a published
// page, Router draws that page through the theme instead. Every other
// request passes straight through: the hook returns [] and adds nothing.
//
// The priority is low so this runs before hooks that prepare the not-found
// page, which would be wasted work for a page that exists.
// ============================================================================
add_hook('ClientAreaPage', -5000, function ($vars) {
    return Router::intercept(is_array($vars) ? $vars : []);
});

// ============================================================================
// Admin page chrome: Hadrian's stylesheet in the <head> of this module's page,
// so it is in place before first paint. Hadrian's own hook only emits it on
// Hadrian's page.
// ============================================================================
add_hook('AdminAreaHeadOutput', 1, function ($vars) {
    if (($_GET['module'] ?? '') !== AdminController::MODULE) {
        return '';
    }
    $css = Bridge::shellCss();
    return $css === '' ? '' : "<style id=\"mt-admin-css\">\n" . $css . "\n</style>";
});

// ============================================================================
// A tab in Hadrian's admin navigation and a card on its Extensions page.
// Admin requests only: nothing in the client area reads the registry.
// ============================================================================
if (defined('ADMINAREA')) {
    Bridge::register([
        'id'          => 'builder',
        'label'       => 'Builder',
        'name'        => 'Page Builder',
        'description' => 'Build marketing pages from sections and publish them at their own addresses.',
        'url'         => AdminController::BASE,
        'version'     => AdminController::VERSION,
    ]);
}
