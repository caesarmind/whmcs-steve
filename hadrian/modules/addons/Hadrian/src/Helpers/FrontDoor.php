<?php
declare(strict_types=1);

namespace Hadrian\Helpers;

/**
 * The address visitors end up at for the theme pages whose own script only
 * redirects.
 *
 * WHMCS serves the announcements list and the knowledgebase index through
 * its router. announcements.php and knowledgebase.php still exist, and
 * answer with a 301 to the routed address, in whichever form the install's
 * "Friendly URLs" setting gives it: /announcements or
 * /index.php?rp=/announcements.
 *
 * The page registry stores the script name for these pages, because that is
 * what an admin recognises and it works as a link. Anything that tells a
 * search engine where a page lives has to name the address the page is
 * served at, not one that redirects to it:
 *   - sitemap.xml and robots.txt (Service\SitemapGenerator)
 *   - the canonical link of a module's page standing in for one of these
 *     pages (Service\Hooks::resolveSeoContext)
 */
final class FrontDoor
{
    /** theme page => [the script that redirects, the WHMCS route it redirects to] */
    private const PAGES = [
        'announcements' => ['announcements.php', 'announcement-index'],
        'knowledgebase' => ['knowledgebase.php', 'knowledgebase-index'],
    ];

    /**
     * The routed address of a page: a path from the domain root, with a
     * query string where the install's URL form needs one. Null for a page
     * that has no route of its own, and when WHMCS cannot resolve it.
     */
    public static function path(string $page): ?string
    {
        $route = self::PAGES[$page][1] ?? null;
        if ($route === null || !function_exists('routePath')) {
            return null;
        }
        try {
            $path = (string)routePath($route);
        } catch (\Throwable $e) {
            return null;
        }
        return $path !== '' && !str_contains($path, 'route-not-defined') ? $path : null;
    }

    /**
     * Is this stored address just the page's redirecting script? An admin
     * who typed an address of their own into Pages gets that address used
     * as it is.
     */
    public static function isScript(string $page, string $url): bool
    {
        $script = self::PAGES[$page][0] ?? null;
        return $script !== null && strcasecmp(ltrim(trim($url), '/'), $script) === 0;
    }
}
