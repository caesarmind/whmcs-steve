<?php
declare(strict_types=1);

namespace HadrianBuilder;

/**
 * A built page standing in for one of the theme's website pages.
 *
 * Three settings decide what a visitor gets at, say, the homepage:
 *
 *   - the page: a built page names the theme page it replaces
 *     (hadrian_builder_pages.replaces, a key of TARGETS)
 *   - the site: "Website served by" is Theme or Page Builder
 *     (Store key SITE_MODE)
 *   - the exception: that built page's rule (replace_rule)
 *       follow   used when the site is on Page Builder
 *       always   used whatever the site says
 *       never    kept on standby whatever the site says
 *
 * Nothing is written outside the database: no rewrite rule, no file in the
 * WHMCS root. The theme's own template is never touched, so setting the site
 * back to Theme, or switching this module off, restores every page at once.
 * A built page also keeps its own address the whole time.
 */
final class Replace
{
    public const SITE_MODE    = 'site_mode';
    public const MODE_THEME   = 'theme';
    public const MODE_BUILDER = 'builder';

    public const RULES = ['follow', 'always', 'never'];

    /**
     * The theme pages a built page may replace: WHMCS templatefile => label.
     *
     * Public, read-only landing pages only. A page that takes a form post or
     * shows a client's own data needs WHMCS's template to work at all, so it
     * is not offered. Each entry here was served through Router on a real
     * WHMCS before it was added; add one only after doing the same.
     */
    public const TARGETS = [
        'homepage'      => 'Homepage',
        'announcements' => 'Announcements',
        'knowledgebase' => 'Knowledgebase',
        'contact'       => 'Contact Us',
    ];

    /**
     * The addresses each of those pages is itself served at, as
     * Router::requestedPath() reports them. WHMCS draws the same template for
     * more than the page's front door (a month of announcements, a
     * knowledgebase search); only the front door is replaced.
     */
    private const PATHS = [
        'homepage'      => ['', 'index.php'],
        'announcements' => ['announcements', 'announcements.php'],
        'knowledgebase' => ['knowledgebase', 'knowledgebase.php'],
        'contact'       => ['contact', 'contact.php'],
    ];

    /**
     * Query parameters that do not change which page is being asked for.
     * Anything else (a page number, a search, an action) means the visitor
     * wants something only the theme's page can give, so it is left alone.
     * "rp" is how WHMCS carries the path itself when URLs are not rewritten;
     * the path is checked separately. "hadrian_customize" is the token of
     * Hadrian's customizer, whose preview frame must show the same page a
     * visitor gets.
     */
    private const NEUTRAL_QUERY = ['language', 'currency', 'rp', 'systpl', 'carttpl', 'hadrian_customize'];

    public static function mode(): string
    {
        return Store::get(self::SITE_MODE) === self::MODE_BUILDER ? self::MODE_BUILDER : self::MODE_THEME;
    }

    public static function setMode(string $mode): void
    {
        Store::set(self::SITE_MODE, $mode === self::MODE_BUILDER ? self::MODE_BUILDER : self::MODE_THEME);
    }

    public static function isTarget(string $templatefile): bool
    {
        return isset(self::TARGETS[$templatefile]);
    }

    public static function rule(string $rule): string
    {
        return in_array($rule, self::RULES, true) ? $rule : 'follow';
    }

    /**
     * Does a built page with this rule and status serve in place of its
     * target under this site mode? The whole decision, with no I/O.
     */
    public static function serves(string $siteMode, string $rule, string $status): bool
    {
        if ($status !== 'published') {
            return false;
        }
        return match (self::rule($rule)) {
            'always' => true,
            'never'  => false,
            default  => $siteMode === self::MODE_BUILDER,
        };
    }

    /**
     * The built page to draw instead of this theme page right now, or null.
     *
     * @param string              $path  the requested path (Router::requestedPath())
     * @param array<string,mixed> $query the request's query parameters
     * @return array<string,mixed>|null
     */
    public static function pageFor(string $templatefile, string $path, array $query): ?array
    {
        if (!self::isTarget($templatefile) || !self::frontDoor($templatefile, $path) || !self::plainRequest($query)) {
            return null;
        }
        $page = Page::replacing($templatefile);
        if ($page === null || !self::serves(self::mode(), (string)($page['replace_rule'] ?? ''), (string)$page['status'])) {
            return null;
        }
        return $page;
    }

    /** Is this path the page's own address, not a view inside it? */
    public static function frontDoor(string $templatefile, string $path): bool
    {
        return in_array($path, self::PATHS[$templatefile] ?? [], true);
    }

    /** @param array<string,mixed> $query */
    public static function plainRequest(array $query): bool
    {
        foreach (array_keys($query) as $key) {
            if (!in_array((string)$key, self::NEUTRAL_QUERY, true)) {
                return false;
            }
        }
        return true;
    }
}
