<?php
declare(strict_types=1);

namespace Hadrian\Helpers;

use Hadrian\Template\Template;

/**
 * The decision half of per-page Visibility enforcement.
 *
 * The admin Pages editor stores visibility = public | auth | disabled per page
 * and its help text promises "Disabled pages return 404. Auth-only pages
 * redirect logged-out visitors to login." This class decides whether the
 * current request keeps that promise; Hooks::enforceVisibility() is the thin
 * I/O wrapper that acts on the verdict (redirect + exit).
 *
 * Deliberately pure — no session, no DB, no headers — so it is testable
 * outside WHMCS (.dashbuild/test-visibility-gate.php drives every case).
 *
 * GUARDRAILS, the reason this is not a one-liner:
 *
 *   - Authentication-group pages are never gated. Gating the login page on
 *     "auth" is a redirect loop; gating a password-reset page locks out the
 *     people who most need it. The group comes from the page's own page.php
 *     and is stored on the row, so a page author opts INTO this protection by
 *     filing the page under Authentication.
 *   - Order-form pages (Template::ORDER_PAGES) are never gated. A dropdown
 *     must not be able to sever mid-checkout navigation; cart access rules
 *     are WHMCS's own business.
 *   - The dead-end pages WHMCS lands people on (banned, access-denied,
 *     store-not-found) are never gated — they must render for exactly the
 *     visitors a gate would turn away.
 *   - A signed-in ADMIN bypasses "disabled", so a disabled page can still be
 *     previewed from the same browser session the admin area runs in.
 *   - Unknown/blank visibility values fail OPEN. Enforcement must never be
 *     the reason a page stops rendering on a weird row.
 */
final class VisibilityGate
{
    /** Send the visitor to the 404 route. */
    public const NOT_FOUND = 'not-found';
    /** Send the visitor to the login page. */
    public const LOGIN = 'login';

    /**
     * Pages never gated regardless of their stored visibility — the dead ends
     * WHMCS itself routes rejected visitors to.
     */
    private const EXEMPT_PAGES = [
        'banned'          => true,
        'access-denied'   => true,
        'store-not-found' => true,
    ];

    /**
     * @param string|null $visibility the row's stored value (public|auth|disabled)
     * @param string|null $pageGroup  the row's page_group
     * @param string      $page       the templatefile / page slug
     * @param bool        $isClient   a client (or masquerading admin) is signed in
     * @param bool        $isAdmin    an admin session exists in this browser
     *
     * @return self::NOT_FOUND|self::LOGIN|null null = render normally
     */
    public static function decide(?string $visibility, ?string $pageGroup, string $page, bool $isClient, bool $isAdmin): ?string
    {
        if ($visibility === null || $visibility === '' || $visibility === 'public') {
            return null;
        }
        if (isset(self::EXEMPT_PAGES[$page]) || isset(Template::ORDER_PAGES[$page])) {
            return null;
        }
        if ($pageGroup === 'Authentication') {
            return null;
        }

        if ($visibility === 'disabled') {
            return $isAdmin ? null : self::NOT_FOUND;
        }
        if ($visibility === 'auth') {
            return ($isClient || $isAdmin) ? null : self::LOGIN;
        }

        // A value this build does not know. Fail open.
        return null;
    }
}
