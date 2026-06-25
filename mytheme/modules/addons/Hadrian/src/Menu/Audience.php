<?php
declare(strict_types=1);

namespace Hadrian\Menu;

/**
 * Audience detection — "is the current request from a logged-in client?"
 *
 * Wraps the session/cookie heuristics so callers don't bake them in. If WHMCS
 * v10 changes the session key, we change one method here instead of grepping.
 *
 * v9 NOTES (verified against Hostnodes' production install):
 *   - $_SESSION['uid'] is still set on login (legacy compatibility)
 *   - WHMCS\Session is the new API but $_SESSION still works
 *   - 'login_auth_tk' is the cookie for "remember me" persistence; presence
 *     means a returning session that hasn't been bootstrapped yet, but the
 *     middleware turns it into a $_SESSION['uid'] very early in the request
 *     cycle, so reading $_SESSION['uid'] alone is enough for hook-time
 *     decisions.
 */
final class Audience
{
    public const CLIENT = 'client';
    public const GUEST  = 'guest';
    public const ALL    = 'all';

    public static function current(): string
    {
        if (!empty($_SESSION['uid']) || !empty($_SESSION['adminid'])) {
            return self::CLIENT;
        }
        if (!empty($_COOKIE['WHMCSUser'])) {
            return self::CLIENT;
        }
        return self::GUEST;
    }

    public static function isClient(): bool
    {
        return self::current() === self::CLIENT;
    }

    public static function isGuest(): bool
    {
        return self::current() === self::GUEST;
    }

    /**
     * Whether an item with the given audience setting should render
     * for the current request.
     */
    public static function allows(string $itemAudience): bool
    {
        if ($itemAudience === self::ALL || $itemAudience === '') {
            return true;
        }
        return $itemAudience === self::current();
    }
}
