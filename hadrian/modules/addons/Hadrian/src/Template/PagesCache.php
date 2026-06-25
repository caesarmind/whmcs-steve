<?php
declare(strict_types=1);

namespace Hadrian\Template;

use Hadrian\Models\Settings;

/**
 * Discovery cache for `core/pages/*` page directories.
 *
 * Built at addon activation and on explicit admin action (Tools tab → Rebuild,
 * or first visit to the Pages tab when the cache is missing). Adheres to the
 * HYBRID-STRUCTURE.md hard rule "no runtime filesystem scans" — scans happen
 * only on admin actions, never during client-area request handling. (getPages()
 * — the sole consumer — is admin-only; the client-area path resolves a single
 * known page via Template::getPageMeta(), never the discovery list.)
 *
 * Storage: one hadrian_settings row per template, keyed `<slug>_pages_discovered`.
 * Payload shape (JSON):
 *   ['version' => '<theme version>', 'signature' => '<dir fingerprint>',
 *    'pages' => ['login', …], 'generated_at' => 'ISO8601']
 *
 * Invalidation (Lagom parity — a newly added page must appear without a manual
 * version bump): the cache is stale when EITHER
 *   - stored version   != current $template->getVersion(), OR
 *   - stored signature != signature() — a cheap fingerprint of the core/pages
 *     directory (root mtime + each subdir name:mtime). Adding/removing a page
 *     dir, or an existing dir gaining its first page.php, changes the fingerprint
 *     and triggers a rebuild on the next admin visit.
 * Bumping the theme.json version still forces a fresh scan as a secondary trigger.
 */
final class PagesCache
{
    /** In-process memo: settingsKey => list<string>|null, valid for one request. */
    private static array $memo = [];

    public static function settingsKey(Template $template): string
    {
        return $template->getName() . '_pages_discovered';
    }

    /**
     * Return the cached discovered pages, or null when the cache is missing or
     * stale. Does NOT trigger a rebuild — use ensure() for that.
     *
     * @return list<string>|null
     */
    public static function read(Template $template): ?array
    {
        $key = self::settingsKey($template);
        if (array_key_exists($key, self::$memo)) {
            return self::$memo[$key];
        }

        $raw = Settings::getValue($key, null);
        if (!is_array($raw) || empty($raw['pages']) || !is_array($raw['pages'])) {
            return self::$memo[$key] = null;
        }
        if (($raw['version'] ?? '') !== $template->getVersion()) {
            return self::$memo[$key] = null;
        }
        if (($raw['signature'] ?? null) !== self::signature($template)) {
            return self::$memo[$key] = null;
        }
        $pages = array_values(array_filter($raw['pages'], 'is_string'));
        return self::$memo[$key] = $pages;
    }

    /**
     * Idempotent: return the cached list if fresh, otherwise rebuild and return.
     * Safe to call from any admin path.
     *
     * @return list<string>
     */
    public static function ensure(Template $template): array
    {
        $cached = self::read($template);
        if ($cached !== null) {
            return $cached;
        }
        return self::rebuild($template);
    }

    /**
     * Force a rebuild — scan the filesystem and overwrite the cached row.
     * Called from Hadrian_activate() and from the admin Tools tab button.
     *
     * @return list<string>
     */
    public static function rebuild(Template $template): array
    {
        $pages = self::scan($template);
        $key   = self::settingsKey($template);
        Settings::setValue($key, [
            'version'      => $template->getVersion(),
            'signature'    => self::signature($template),
            'pages'        => $pages,
            'generated_at' => date('c'),
        ], 'json');
        return self::$memo[$key] = $pages;
    }

    /**
     * Cheap fingerprint of the core/pages directory used to detect added/removed
     * pages without a full qualifying scan. Combines the root dir mtime with each
     * immediate subdir's name and mtime: adding or removing a page dir changes the
     * root mtime + entry set, and an existing dir gaining its first page.php
     * changes that subdir's mtime. One scandir + N filemtime stats — admin-only,
     * so it does not breach the "no runtime filesystem scans" rule.
     */
    private static function signature(Template $template): string
    {
        $root = $template->getFullPath() . DIRECTORY_SEPARATOR . 'core' . DIRECTORY_SEPARATOR . 'pages';
        if (!is_dir($root)) {
            return '0';
        }
        $parts = ['root:' . (string)(@filemtime($root) ?: 0)];
        foreach (scandir($root) ?: [] as $entry) {
            if ($entry === '.' || $entry === '..') continue;
            $dir = $root . DIRECTORY_SEPARATOR . $entry;
            if (!is_dir($dir)) continue;
            $parts[] = $entry . ':' . (string)(@filemtime($dir) ?: 0);
        }
        return hash('crc32b', implode('|', $parts));
    }

    /**
     * Filesystem walk over `core/pages/*`. A directory counts as a page when
     * it contains a `page.php` metadata file OR at least one variant tpl
     * (`<v>/<v>.tpl`). Empty scaffolds and dot-dirs are excluded.
     *
     * @return list<string>
     */
    private static function scan(Template $template): array
    {
        $root = $template->getFullPath() . DIRECTORY_SEPARATOR . 'core' . DIRECTORY_SEPARATOR . 'pages';
        if (!is_dir($root)) {
            return [];
        }

        $found = [];
        foreach (scandir($root) ?: [] as $entry) {
            if ($entry === '.' || $entry === '..') continue;
            $dir = $root . DIRECTORY_SEPARATOR . $entry;
            if (!is_dir($dir)) continue;

            if (self::dirQualifies($dir)) {
                $found[] = $entry;
            }
        }
        sort($found);
        return $found;
    }

    /** A page directory qualifies when it has page.php or at least one <v>/<v>.tpl. */
    private static function dirQualifies(string $dir): bool
    {
        if (file_exists($dir . DIRECTORY_SEPARATOR . 'page.php')) {
            return true;
        }
        foreach (scandir($dir) ?: [] as $sub) {
            if ($sub === '.' || $sub === '..') continue;
            $subDir = $dir . DIRECTORY_SEPARATOR . $sub;
            if (is_dir($subDir) && file_exists($subDir . DIRECTORY_SEPARATOR . $sub . '.tpl')) {
                return true;
            }
        }
        return false;
    }
}
