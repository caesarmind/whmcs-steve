<?php
declare(strict_types=1);

namespace Hadrian\Helpers;

/**
 * The gate for the addon's JSON endpoints (branding uploads, media library).
 *
 * WHERE these endpoints run is the main protection, and it is not in this
 * file: they are dispatched from Hadrian_output() via MainController, which
 * WHMCS calls only after it has checked the admin login and this addon's role
 * permissions. They used to be dispatched from hooks.php, which WHMCS loads
 * BEFORE that check, so anyone on the internet could list, upload and delete
 * media (security review 2026-10, finding C1).
 *
 * AdminCsrf::check(), run by AbstractController::adminArea before any
 * controller, already refuses a POST without the token. guard() repeats the
 * checks inside the endpoint itself, so that moving a route back into
 * hooks.php (which runs before both) cannot silently reopen the hole:
 *   - POST only
 *   - a signed-in admin
 *   - the WHMCS admin CSRF token. Not sufficient on its own (a visitor who is
 *     not signed in has a session with a valid token of its own: the login
 *     form prints it), but it stops another site from posting here with a
 *     signed-in admin's cookies.
 *
 * Every refusal is JSON, because every caller is an XMLHttpRequest that
 * JSON.parse()s the answer.
 */
final class AdminAjax
{
    public static function guard(): void
    {
        if (($_SERVER['REQUEST_METHOD'] ?? '') !== 'POST') {
            self::refuse('POST only.', 405);
        }
        if (!self::isAdmin()) {
            self::refuse('You are signed out. Reload the page and sign in again.', 401);
        }
        if (!self::tokenOk((string)($_POST['token'] ?? ''))) {
            self::refuse('Your session expired. Reload the page and try again.', 403);
        }
    }

    /** True when the request comes from a signed-in WHMCS admin. */
    public static function isAdmin(): bool
    {
        try {
            if (class_exists('\\WHMCS\\Authentication\\CurrentUser')) {
                $user = new \WHMCS\Authentication\CurrentUser();
                if (method_exists($user, 'isAuthenticatedAdmin') && $user->isAuthenticatedAdmin()) {
                    return true;
                }
                if (method_exists($user, 'admin') && $user->admin()) {
                    return true;
                }
            }
        } catch (\Throwable $e) {
            // Fall through to the session.
        }
        return (int)($_SESSION['adminid'] ?? 0) > 0;
    }

    /**
     * The token WHMCS puts in every admin form (the JS callers read it from
     * the page and send it as `token`). One implementation, in AdminCsrf.
     */
    public static function tokenOk(string $given): bool
    {
        return AdminCsrf::valid($given);
    }

    public static function refuse(string $message, int $code): never
    {
        while (ob_get_level() > 0) {
            @ob_end_clean();
        }
        if (!headers_sent()) {
            http_response_code($code);
            header('Content-Type: application/json; charset=utf-8');
            header('X-Content-Type-Options: nosniff');
            header('Cache-Control: no-store');
        }
        echo (string)json_encode(['ok' => false, 'error' => $message]);
        exit;
    }
}
