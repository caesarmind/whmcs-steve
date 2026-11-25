<?php
declare(strict_types=1);

/**
 * Hadrian Email Templates: hook registrations.
 *
 * WHMCS loads this file on every request while the addon is active, in no
 * promised order relative to Hadrian's own hooks.php. Nothing here assumes
 * Hadrian loaded first; src/Bridge.php brings its classes in on demand.
 */

if (!defined('WHMCS')) {
    exit('This file cannot be accessed directly');
}

require_once __DIR__ . DIRECTORY_SEPARATOR . 'autoload.php';

use HadrianEmail\AdminController;
use HadrianEmail\Bridge;
use HadrianEmail\SendHook;

// ============================================================================
// NOTHING IS DISPATCHED FROM THIS FILE.
//
// The builder's AJAX endpoints (preview, save, publish, restore) are handled
// in AdminController::dispatch(), reached through HadrianEmail_output(). That
// is deliberate, and it is the opposite of what an early-exit handler placed
// here would do:
//
//   WHMCS loads hooks.php BEFORE it checks that anyone is signed in. A request
//   to /admin/addonmodules.php by a visitor with no session gets this file
//   loaded, with ADMINAREA defined, and only afterwards the redirect to the
//   login page. A handler that answered and exited here would run for anyone
//   on the internet -- measured on WHMCS 9.0.8, and the anonymous visitor's
//   own session supplies a CSRF token that passes.
//
// _output() runs after WHMCS has enforced the admin login AND this addon's
// role permissions, so the endpoints inherit both.
// ============================================================================

// ============================================================================
// The header and footer of every outgoing client email.
//
// While Hadrian email is on, WHMCS's global email header and footer hold a
// guarded placeholder (see Takeover) and this fills it in for the recipient's
// language. It answers [] when the feature is off. If this file is not loaded
// at all, the placeholder falls through to its static header and footer, so
// mail keeps its branding either way.
// ============================================================================
add_hook('EmailPreSend', 1, function ($vars) {
    return SendHook::handle(is_array($vars) ? $vars : []);
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
        'id'          => 'email',
        'label'       => 'Email',
        'name'        => 'Email Templates',
        'description' => 'A branded layout around every client email, and a block builder for the ones you redesign.',
        'url'         => AdminController::BASE,
        'version'     => '1.0.0',
    ]);

    // Which library images the emails use, for Hadrian's Media screen.
    // Read only when that screen, or a delete in the picker, asks.
    Bridge::registerMediaSource('email', [\HadrianEmail\MediaSource::class, 'rows']);
}
