<?php
declare(strict_types=1);

namespace MyTheme\Template;

use MyTheme\Models\Settings;

/**
 * Discovery cache for `core/pages/*` page directories.
 *
 * Built at addon activation and on explicit admin action (Tools tab → Rebuild,
 * or first visit to the Pages tab when the cache is missing). Adheres to the
 * HYBRID-STRUCTURE.md hard rule "no runtime filesystem scans" — scans happen
 * only on admin actions, never during client-area request handling.
 *
 * Storage: one mytheme_settings row per template, keyed `<slug>_pages_discovered`.
 * Payload shape (JSON):
 *   ['version' => '<theme version>', 'pages' => ['login', …], 'generated_at' => 'ISO8601']
 *
 * Invalidation: stored version != current $template->getVersion() → treated as
 * stale, ensure() will rebuild. Bumping the theme.json version triggers a
 * fresh scan on the next admin visit.
 */
final class PagesCache
{
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
        $raw = Settings::getValue(self::settingsKey($template), null);
        if (!is_array($raw) || empty($raw['pages']) || !is_array($raw['pages'])) {
            return null;
        }
        if (($raw['version'] ?? '') !== $template->getVersion()) {
            return null;
        }
        $pages = array_values(array_filter($raw['pages'], 'is_string'));
        return $pages;
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
     * Called from MyTheme_activate() and from the admin Tools tab button.
     *
     * @return list<string>
     */
    public static function rebuild(Template $template): array
    {
        $pages = self::scan($template);
        Settings::setValue(self::settingsKey($template), [
            'version'      => $template->getVersion(),
            'pages'        => $pages,
            'generated_at' => date('c'),
        ], 'json');
        return $pages;
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
