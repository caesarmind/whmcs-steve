<?php
declare(strict_types=1);

namespace Hadrian\Helpers;

/**
 * CSRF protection for every request that changes something in the Hadrian
 * admin.
 *
 * WHMCS does NOT do this for an addon. Measured on WHMCS 9.0.8: a signed-in
 * admin's POST to addonmodules.php with no token, or a wrong one, reaches
 * _output() and is acted on (security review 2026-10, finding Cand-A). So a
 * page on another site could make an admin's browser change Hadrian settings,
 * including Custom CSS, which is written into every client page.
 *
 * check() runs once, at the addon's single entry point
 * (AbstractController::adminArea), before any controller is chosen. Every POST
 * needs the token, and so do the few GET links that change state
 * (GET_WRITES). A new save route is covered the moment it exists.
 *
 * The token is WHMCS's own admin token. WHMCS injects it as a hidden
 * `token` input into every server-rendered POST form on the page, so forms
 * need no changes; the GET links carry it as `&token=` ({$csrfToken} in
 * every admin view).
 */
final class AdminCsrf
{
    /**
     * GET routes that change state, as action => subs. Each is a link in an
     * admin view, so it carries the token in its URL. Anything that changes
     * state and is not listed here must be a POST.
     */
    public const GET_WRITES = [
        'menu'    => ['seed', 'reset-defaults', 'create', 'delete'],
        'sitemap' => ['generate'],
    ];

    /** WHMCS's admin token for this session, or '' outside WHMCS. */
    public static function token(): string
    {
        try {
            return function_exists('generate_token') ? (string)generate_token('plain') : '';
        } catch (\Throwable $e) {
            return '';
        }
    }

    public static function valid(string $given): bool
    {
        $expected = self::token();
        return $expected !== '' && $given !== '' && hash_equals($expected, $given);
    }

    /** Does this request change state, and so need the token? */
    public static function needsToken(string $action, string $sub, string $method): bool
    {
        if (strtoupper($method) === 'POST') {
            return true;
        }
        return in_array($sub, self::GET_WRITES[$action] ?? [], true);
    }

    /**
     * Null when the request may proceed; otherwise why not, in words for the
     * admin. Reads the token from the body for a POST and from the URL for a
     * GET, never the other way round.
     */
    public static function check(string $action, string $sub, string $method): ?string
    {
        if (!self::needsToken($action, $sub, $method)) {
            return null;
        }
        $given = strtoupper($method) === 'POST'
            ? (string)($_POST['token'] ?? '')
            : (string)($_GET['token'] ?? '');
        if (self::valid($given)) {
            return null;
        }
        return 'Nothing was changed. The request did not come from a page of this admin, '
            . 'or the page was open long enough for your session to change. '
            . 'Go back, reload the page and try again.';
    }

    /** JSON callers get JSON; everything else gets the admin error page. */
    public static function isJsonRoute(string $action, string $sub): bool
    {
        return $action === 'media' || str_ends_with($sub, '-ajax');
    }
}
