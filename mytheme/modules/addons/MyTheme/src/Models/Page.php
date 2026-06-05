<?php
declare(strict_types=1);

namespace MyTheme\Models;

/**
 * Registry of theme pages (`mytheme_pages`) — one row per (template, page).
 *
 * Thin Capsule query-builder wrapper, mirroring Models\Settings (the addon
 * deliberately doesn't use Eloquent models). Single source of truth for
 * per-page SEO + sitemap config. JSON columns (seo_title, seo_description,
 * settings) are decoded on read and encoded on write.
 *
 * seo_title / seo_description hold EITHER a per-language map keyed by the WHMCS
 * language name ({"english":"…","french":"…"}) OR a plain string (legacy
 * import). Use self::lang() to resolve to one language with fallback.
 */
final class Page
{
    private const TABLE = 'mytheme_pages';

    /** @return array<string,mixed>|null */
    public static function get(string $template, string $page): ?array
    {
        $row = \WHMCS\Database\Capsule::table(self::TABLE)
            ->where('template', $template)
            ->where('page', $page)
            ->first();
        return $row ? self::hydrate($row) : null;
    }

    public static function exists(string $template, string $page): bool
    {
        return \WHMCS\Database\Capsule::table(self::TABLE)
            ->where('template', $template)->where('page', $page)->exists();
    }

    /**
     * Insert or update a page row. Only the keys present in $data are written
     * (so a partial update from the admin form never clobbers seeded columns
     * like seo_enabled/published/page_group). seo_title/seo_description/settings
     * are JSON-encoded when given as arrays.
     *
     * @param array<string,mixed> $data
     */
    public static function upsert(string $template, string $page, array $data): void
    {
        $now  = date('Y-m-d H:i:s');
        $cols = self::columnsFrom($data);

        if (self::exists($template, $page)) {
            $cols['updated_at'] = $now;
            \WHMCS\Database\Capsule::table(self::TABLE)
                ->where('template', $template)->where('page', $page)
                ->update($cols);
        } else {
            $cols['template']   = $template;
            $cols['page']       = $page;
            $cols['created_at'] = $now;
            $cols['updated_at'] = $now;
            \WHMCS\Database\Capsule::table(self::TABLE)->insert($cols);
        }
    }

    /** @return list<array<string,mixed>> */
    public static function all(string $template): array
    {
        return \WHMCS\Database\Capsule::table(self::TABLE)
            ->where('template', $template)
            ->orderBy('sort')->orderBy('page')
            ->get()->map(fn ($r) => self::hydrate($r))->all();
    }

    /**
     * Pages eligible for the sitemap: SEO-enabled, indexable, public,
     * published, with a non-null URL ('' is the site root, kept; null = no
     * crawlable URL, dropped).
     *
     * @return list<array<string,mixed>>
     */
    public static function forSitemap(string $template): array
    {
        return \WHMCS\Database\Capsule::table(self::TABLE)
            ->where('template', $template)
            ->where('seo_enabled', 1)
            ->where('indexing', '<>', 'disallow')
            ->where('visibility', 'public')
            ->where('published', 1)
            ->whereNotNull('url')
            ->orderBy('sort')->orderBy('page')
            ->get()->map(fn ($r) => self::hydrate($r))->all();
    }

    /**
     * Resolve a per-language stored value to a single string. Accepts a map
     * (lang => value), a plain string, or null; falls back to the first
     * non-empty value in a map when the requested language is missing.
     */
    public static function lang(mixed $raw, string $lang): string
    {
        if (is_array($raw)) {
            if (isset($raw[$lang]) && (string)$raw[$lang] !== '') {
                return (string)$raw[$lang];
            }
            foreach ($raw as $v) {
                if ((string)$v !== '') {
                    return (string)$v;
                }
            }
            return '';
        }
        return (string)($raw ?? '');
    }

    /** @return array<string,mixed> */
    private static function hydrate(object $r): array
    {
        $settings = self::decode($r->settings ?? null);
        return [
            'url'             => $r->url !== null ? (string)$r->url : null,
            'page_group'      => (string)($r->page_group ?? ''),
            'seo_enabled'     => (bool)$r->seo_enabled,
            'indexing'        => (string)$r->indexing,
            'visibility'      => (string)$r->visibility,
            'seo_title'       => self::decode($r->seo_title ?? null),
            'seo_description' => self::decode($r->seo_description ?? null),
            'seo_image'       => $r->seo_image !== null ? (string)$r->seo_image : '',
            'variant'         => $r->variant !== null ? (string)$r->variant : null,
            'settings'        => is_array($settings) ? $settings : [],
            'published'       => (bool)$r->published,
            'sort'            => (int)$r->sort,
        ];
    }

    /** Decode a JSON column; returns the raw string if it isn't valid JSON. */
    private static function decode(?string $raw): mixed
    {
        if ($raw === null || $raw === '') {
            return null;
        }
        $decoded = json_decode($raw, true);
        return json_last_error() === JSON_ERROR_NONE ? $decoded : $raw;
    }

    /**
     * Map writable $data keys to DB columns, JSON-encoding the complex ones.
     *
     * @param array<string,mixed> $data
     * @return array<string,mixed>
     */
    private static function columnsFrom(array $data): array
    {
        $cols = [];
        foreach (['url', 'page_group', 'seo_enabled', 'indexing', 'visibility', 'seo_image', 'variant', 'published', 'sort'] as $k) {
            if (array_key_exists($k, $data)) {
                $cols[$k] = $data[$k];
            }
        }
        foreach (['seo_title', 'seo_description', 'settings'] as $k) {
            if (array_key_exists($k, $data)) {
                $v = $data[$k];
                $cols[$k] = (is_string($v) || $v === null) ? $v : json_encode($v);
            }
        }
        return $cols;
    }
}
