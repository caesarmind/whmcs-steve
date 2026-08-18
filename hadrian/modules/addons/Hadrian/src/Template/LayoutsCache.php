<?php
declare(strict_types=1);

namespace Hadrian\Template;

use Hadrian\Models\Settings;

/**
 * Discovery cache for buyer-created layouts under `core/layouts/<kind>/*`.
 *
 * Deliberate sibling of PagesCache — same Settings-row payload idea, same
 * version + directory-fingerprint invalidation, same ensure()/read()/rebuild()
 * shape — with ONE structural difference that must not be "fixed":
 *
 *   getLayouts() is on the CLIENT request path (Hooks validates per-page layout
 *   overrides there), so the client side calls readTrusted(), which does ZERO
 *   filesystem work — raw Settings row + per-request memo, no signature check.
 *   Freshness (ensure(), which does the scandir fingerprint) runs only from
 *   admin entry points: the Layouts page, the Pages editor, addon activation,
 *   and Tools → Rebuild. Consequence: a dropped folder appears on the next
 *   ADMIN visit — exactly the semantics pages already have, now for layouts.
 *   This honours HYBRID-STRUCTURE.md's "no runtime filesystem scans" rule.
 *
 * Discovery contract (what makes a folder a layout):
 *   core/layouts/<kind>/<name>/layout.php   the manifest
 *   core/layouts/<kind>/<name>/default.tpl  the markup (the same file the
 *                                           generic dispatch in header.tpl /
 *                                           footer.tpl includes)
 *
 * Validation happens at REBUILD, and failures are recorded with reasons the
 * admin Layouts page can show. That is the anti-Lagom stance: Lagom's scanner
 * admits any directory and lets a typo'd manifest key or colliding name fail
 * silently downstream (their shipped `displayName` vs `display_name` typo went
 * unnoticed because a fallback masked it). Here a broken folder is REJECTED
 * LOUDLY, next to the cards, with the reason.
 *
 * dataLayout is validated hard — /^[a-z][a-z0-9-]{1,30}$/ — because it is
 * emitted into an HTML attribute (body[data-layout]) and interpolated into
 * GENERATED CSS SELECTORS (Hooks::buildLayoutGatesHead). It is an injection
 * surface, and the emit side re-validates independently (both-ends checking,
 * the same stance the colour pipeline takes).
 *
 * Storage: one hadrian_settings row per template, keyed `<slug>_layouts_discovered`:
 *   ['version' => …, 'signature' => …,
 *    'layouts'  => ['main-menu' => ['name' => dataLayoutToken, …], 'footer' => […]],
 *    'rejected' => [['dir' => …, 'kind' => …, 'reason' => …], …],
 *    'generated_at' => ISO8601]
 */
final class LayoutsCache
{
    public const KINDS = ['main-menu', 'footer'];

    /** The one pattern a dataLayout token may take. Mirrored in Hooks::layoutTokenValid(). */
    public const TOKEN_PATTERN = '/^[a-z][a-z0-9-]{1,30}$/';

    /** In-process memo: settingsKey => payload|null, valid for one request. */
    private static array $memo = [];

    public static function settingsKey(Template $template): string
    {
        return $template->getName() . '_layouts_discovered';
    }

    /**
     * CLIENT-PATH read: the stored payload, trusted as-is. No scandir, no
     * signature check — a stale row is acceptable on the client (it only means
     * a freshly dropped folder is invisible until an admin visit rebuilds).
     * The version check is a string compare against the already-loaded
     * manifest, so it costs nothing and drops caches from a different theme
     * version outright.
     *
     * @return array{layouts: array<string, array<string,string>>, rejected: list<array{dir:string,kind:string,reason:string}>}
     */
    public static function readTrusted(Template $template): array
    {
        $key = self::settingsKey($template);
        if (array_key_exists($key, self::$memo)) {
            return self::$memo[$key];
        }

        $empty = ['layouts' => [], 'rejected' => []];
        $raw   = Settings::getValue($key, null);
        if (!is_array($raw) || ($raw['version'] ?? '') !== $template->getVersion()) {
            return self::$memo[$key] = $empty;
        }

        $layouts = [];
        foreach (self::KINDS as $kind) {
            $entries = $raw['layouts'][$kind] ?? [];
            if (!is_array($entries)) {
                continue;
            }
            foreach ($entries as $name => $token) {
                if (is_string($name) && $name !== '' && is_string($token)) {
                    $layouts[$kind][$name] = $token;
                }
            }
        }
        $rejected = [];
        foreach (($raw['rejected'] ?? []) as $row) {
            if (is_array($row) && isset($row['dir'], $row['kind'], $row['reason'])) {
                $rejected[] = ['dir' => (string)$row['dir'], 'kind' => (string)$row['kind'], 'reason' => (string)$row['reason']];
            }
        }

        return self::$memo[$key] = ['layouts' => $layouts, 'rejected' => $rejected];
    }

    /**
     * ADMIN-PATH freshness: rebuild when the stored row is missing, from a
     * different theme version, or the directory fingerprint moved. Idempotent;
     * memoized per request through readTrusted().
     */
    public static function ensure(Template $template): array
    {
        $key = self::settingsKey($template);
        $raw = Settings::getValue($key, null);
        $fresh = is_array($raw)
            && ($raw['version'] ?? '') === $template->getVersion()
            && ($raw['signature'] ?? null) === self::signature($template);
        if (!$fresh) {
            self::rebuild($template);
        }
        return self::readTrusted($template);
    }

    /**
     * Scan, validate, store. Called from Hadrian_activate(), the upgrade hook,
     * Tools → Rebuild, and (via ensure) the Layouts/Pages admin screens.
     */
    public static function rebuild(Template $template): array
    {
        [$layouts, $rejected] = self::scan($template);
        $key = self::settingsKey($template);
        Settings::setValue($key, [
            'version'      => $template->getVersion(),
            'signature'    => self::signature($template),
            'layouts'      => $layouts,
            'rejected'     => $rejected,
            'generated_at' => date('c'),
        ], 'json');
        unset(self::$memo[$key]);
        return self::readTrusted($template);
    }

    /**
     * Fingerprint of both kind directories: root mtimes + each layout dir's
     * name:mtime. Dropping a folder in, deleting one, or touching a manifest
     * inside one (dir mtime moves on direct child changes) flips it. Same
     * cheap-stat approach as PagesCache::signature(); admin-only.
     */
    private static function signature(Template $template): string
    {
        $parts = [];
        foreach (self::KINDS as $kind) {
            $root = self::kindRoot($template, $kind);
            if (!is_dir($root)) {
                $parts[] = $kind . ':absent';
                continue;
            }
            $parts[] = $kind . ':root:' . (string)(@filemtime($root) ?: 0);
            foreach (scandir($root) ?: [] as $entry) {
                if ($entry === '.' || $entry === '..') continue;
                $dir = $root . DIRECTORY_SEPARATOR . $entry;
                if (!is_dir($dir)) continue;
                $parts[] = $kind . ':' . $entry . ':' . (string)(@filemtime($dir) ?: 0);
            }
        }
        return hash('crc32b', implode('|', $parts));
    }

    /**
     * The scan + the anti-Lagom validation gate. Declared layouts (theme.json)
     * are NOT re-listed here — Template::getLayouts() puts them first and this
     * cache only carries the extras — but their names AND tokens are loaded so
     * a custom folder cannot shadow either namespace (dir `sidebar` owns token
     * `side`; both must be reserved).
     *
     * @return array{0: array<string, array<string,string>>, 1: list<array{dir:string,kind:string,reason:string}>}
     */
    private static function scan(Template $template): array
    {
        $layouts  = [];
        $rejected = [];

        foreach (self::KINDS as $kind) {
            $declaredNames  = [];
            $declaredTokens = [];
            foreach ($template->getDeclaredLayouts($kind) as $name) {
                $declaredNames[$name] = true;
                $meta  = self::loadManifest(self::kindRoot($template, $kind) . DIRECTORY_SEPARATOR . $name . DIRECTORY_SEPARATOR . 'layout.php');
                $token = is_array($meta) ? (string)($meta['variables']['dataLayout'] ?? '') : '';
                if ($token !== '') {
                    $declaredTokens[$token] = $name;
                }
            }

            $root = self::kindRoot($template, $kind);
            if (!is_dir($root)) {
                continue;
            }

            $seenTokens = [];
            $entries = scandir($root) ?: [];
            sort($entries);
            foreach ($entries as $entry) {
                if ($entry === '.' || $entry === '..') continue;
                $dir = $root . DIRECTORY_SEPARATOR . $entry;
                if (!is_dir($dir)) continue;
                if (isset($declaredNames[$entry])) continue;   // shipped — declared list owns it

                $reject = static function (string $reason) use (&$rejected, $entry, $kind): void {
                    $rejected[] = ['dir' => $entry, 'kind' => $kind, 'reason' => $reason];
                };

                if (!preg_match('/^[a-z][a-z0-9-]{1,40}$/', $entry)) {
                    $reject('Folder name must be lowercase letters, digits and hyphens.');
                    continue;
                }
                if (!is_file($dir . DIRECTORY_SEPARATOR . 'layout.php')) {
                    $reject('No layout.php manifest.');
                    continue;
                }
                if (!is_file($dir . DIRECTORY_SEPARATOR . 'default.tpl')) {
                    $reject('No default.tpl — this is the file the theme includes.');
                    continue;
                }

                $meta = self::loadManifest($dir . DIRECTORY_SEPARATOR . 'layout.php');
                if (!is_array($meta)) {
                    $reject('layout.php does not return an array (or has a syntax error).');
                    continue;
                }

                /* Footer layouts dispatch purely by folder name and declare no
                   dataLayout (matching the shipped three) — skip token checks. */
                $token = (string)($meta['variables']['dataLayout'] ?? '');
                if ($kind === 'main-menu') {
                    if ($token === '') {
                        $reject('layout.php must declare variables.dataLayout.');
                        continue;
                    }
                    if (!preg_match(self::TOKEN_PATTERN, $token)) {
                        $reject('variables.dataLayout must match ' . self::TOKEN_PATTERN . ' (it becomes body[data-layout] and a CSS selector).');
                        continue;
                    }
                    if (isset($declaredTokens[$token])) {
                        $reject("dataLayout '{$token}' is reserved by the shipped '{$declaredTokens[$token]}' layout.");
                        continue;
                    }
                    if (isset($seenTokens[$token])) {
                        $reject("dataLayout '{$token}' is already used by the '{$seenTokens[$token]}' folder.");
                        continue;
                    }
                    $seenTokens[$token] = $entry;
                }

                $layouts[$kind][$entry] = $token;
            }
        }

        return [$layouts, $rejected];
    }

    private static function kindRoot(Template $template, string $kind): string
    {
        return $template->getFullPath() . DIRECTORY_SEPARATOR . 'core'
             . DIRECTORY_SEPARATOR . 'layouts' . DIRECTORY_SEPARATOR . $kind;
    }

    /**
     * Load a buyer-authored PHP file without letting its failure take the
     * request down. ParseError/Error are Throwable in PHP 7+, so a syntax
     * error in a dropped-in manifest becomes a rejection reason, not a 500.
     * @return mixed
     */
    private static function loadManifest(string $file)
    {
        if (!is_file($file)) {
            return null;
        }
        try {
            return require $file;
        } catch (\Throwable $e) {
            return null;
        }
    }
}
