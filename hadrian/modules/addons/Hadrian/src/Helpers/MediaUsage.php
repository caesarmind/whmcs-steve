<?php
declare(strict_types=1);

namespace Hadrian\Helpers;

/**
 * Where each library image is used, so the Media screen can say "used in 3
 * places" and so a delete cannot quietly leave a broken image on a page.
 *
 * Nothing records a use when an image is picked. The picker only writes the
 * image's URL into whatever field opened it, and that field may be saved in
 * any table of any module. So this works the other way round: it reads the
 * places that can hold an image and looks for library file names in them.
 * That is always current, needs no bookkeeping, and cannot drift.
 *
 * A "source" is a callable returning the texts to look in:
 *
 *   list<array{where: string, url: string, text: string}>
 *     where  what the admin calls the place: "Page: Homepage"
 *     url    a link into the admin to it, "?module=...", or ''
 *     text   anything that may contain the image's URL: a field, a JSON
 *            document, a block of CSS
 *
 * Hadrian's own sources are built in (page SEO images, settings, menu
 * items). An extension module adds its own with register(), from its
 * hooks.php, the same way it registers its tab: the Page Builder reports its
 * pages, Email Templates its designs.
 *
 * What it cannot see, and the screen says so: an image URL pasted somewhere
 * outside Hadrian (a WHMCS product description, a hand-edited template).
 */
final class MediaUsage
{
    /** @var array<string, callable> by source id */
    private static array $sources = [];

    /** @var array<string, list<array{where:string,url:string}>>|null */
    private static ?array $map = null;

    /** Add a source. $id is a short slug; registering it again replaces it. */
    public static function register(string $id, callable $source): void
    {
        if (preg_match('/^[a-z0-9][a-z0-9-]{0,30}$/', $id)) {
            self::$sources[$id] = $source;
            self::$map = null;
        }
    }

    /**
     * Stored file name => the places it is used. An image used nowhere has
     * no entry.
     *
     * @return array<string, list<array{where:string,url:string}>>
     */
    public static function map(): array
    {
        if (self::$map !== null) {
            return self::$map;
        }
        $map = [];
        foreach (['hadrian' => [self::class, 'ownSources']] + self::$sources as $id => $source) {
            try {
                $rows = $source();
            } catch (\Throwable $e) {
                // A source that fails reports nothing; the rest still count.
                error_log('Hadrian media: source "' . $id . '" could not be read: ' . $e->getMessage());
                continue;
            }
            foreach (is_array($rows) ? $rows : [] as $row) {
                if (!is_array($row)) {
                    continue;
                }
                $where = self::cut(trim((string)($row['where'] ?? '')), 120);
                $url   = (string)($row['url'] ?? '');
                $url   = preg_match('/^\?module=[A-Za-z0-9_]+(&[A-Za-z0-9_=&%.-]*)?$/', $url) ? $url : '';
                if ($where === '') {
                    continue;
                }
                foreach (self::namesIn((string)($row['text'] ?? '')) as $name) {
                    $place = ['where' => $where, 'url' => $url];
                    if (!in_array($place, $map[$name] ?? [], true)) {
                        $map[$name][] = $place;
                    }
                }
            }
        }
        return self::$map = $map;
    }

    /**
     * @param list<string> $names stored file names
     * @return array<string, list<array{where:string,url:string}>> only the ones in use
     */
    public static function of(array $names): array
    {
        return array_intersect_key(self::map(), array_flip($names));
    }

    /**
     * The library file names a text points at. A reference is the library's
     * folder followed by a file name, which is how every picker value is
     * shaped whatever the site's address is. JSON-escaped slashes count.
     *
     * @return list<string>
     */
    public static function namesIn(string $text): array
    {
        if ($text === '' || stripos($text, 'media') === false) {
            return [];
        }
        $text = str_replace('\\/', '/', $text);
        $dir  = preg_quote(trim((string)MediaLibrary::config(MediaLibrary::DEFAULT_COLLECTION)['webDir'], '/'), '~');
        if (!preg_match_all('~' . $dir . '/([A-Za-z0-9][A-Za-z0-9._-]*\.(?:png|jpe?g|gif|webp))(?![A-Za-z0-9._-])~i', $text, $m)) {
            return [];
        }
        return array_values(array_unique($m[1]));
    }

    /** Forget the sources and the map. For tests. */
    public static function reset(): void
    {
        self::$sources = [];
        self::$map     = null;
    }

    // ------------------------------------------------------------ internals

    /**
     * Hadrian's own places. Each table is read on its own, so one that does
     * not exist yet (a fresh install, an old schema) costs that source only.
     *
     * @return list<array{where:string,url:string,text:string}>
     */
    private static function ownSources(): array
    {
        if (!class_exists('\\WHMCS\\Database\\Capsule')) {
            return [];
        }
        $db  = '\\WHMCS\\Database\\Capsule';
        $out = [];

        try {
            foreach ($db::table('hadrian_pages')->whereNotNull('seo_image')->where('seo_image', '!=', '')->get(['page', 'seo_image']) as $r) {
                $out[] = [
                    'where' => 'Social image of the page "' . $r->page . '"',
                    'url'   => '?module=Hadrian&action=pages&sub=edit&page=' . rawurlencode((string)$r->page),
                    'text'  => (string)$r->seo_image,
                ];
            }
        } catch (\Throwable $e) {
            // No registry table yet.
        }

        try {
            foreach ($db::table('hadrian_settings')->where('value', 'like', '%/media/%')->get(['setting', 'value']) as $r) {
                $out[] = [
                    'where' => 'Setting "' . $r->setting . '"',
                    'url'   => '?module=Hadrian&action=settings',
                    'text'  => (string)$r->value,
                ];
            }
        } catch (\Throwable $e) {
            // No settings table yet.
        }

        try {
            foreach ($db::table('hadrian_menu_items')->where('config_json', 'like', '%media%')->get(['menu_id', 'label_json', 'config_json']) as $r) {
                $label = json_decode((string)$r->label_json, true);
                $name  = '';
                if (is_array($label)) {
                    $custom = is_array($label['custom'] ?? null) ? array_filter(array_map('strval', $label['custom'])) : [];
                    $name   = (string)(reset($custom) ?: ($label['whmcs'] ?? ''));
                }
                $out[] = [
                    'where' => $name !== '' ? 'Menu item "' . $name . '"' : 'A menu item',
                    'url'   => '?module=Hadrian&action=editMenu&id=' . (int)$r->menu_id,
                    'text'  => (string)$r->config_json,
                ];
            }
        } catch (\Throwable $e) {
            // No menu table, or a schema without these columns.
        }

        return $out;
    }

    private static function cut(string $s, int $n): string
    {
        return function_exists('mb_substr') ? mb_substr($s, 0, $n) : substr($s, 0, $n);
    }
}
