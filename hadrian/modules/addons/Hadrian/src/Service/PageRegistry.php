<?php
declare(strict_types=1);

namespace Hadrian\Service;

use Hadrian\Helpers\ExtensionPages;
use Hadrian\Models\Page;
use Hadrian\Models\Settings;
use Hadrian\Template\Template;

/**
 * Seeds + maintains the `hadrian_pages` registry from the filesystem page set.
 *
 * Idempotent. Run ONLY from the admin Pages-tab self-heal — never from the
 * client-area render path. For each discovered page WITHOUT a row it creates
 * one, importing any legacy hadrian_settings `<tpl>_page_options_<page>` /
 * `<tpl>_page_variant_<page>` values first (those keys are NOT deleted — they
 * remain a rollback path). Existing rows are left untouched, so admin edits
 * are never clobbered.
 *
 * Seeding bakes `indexing`/`visibility` into the row (they're concrete
 * settings) but leaves seo_title/seo_description empty when there's no stored
 * override, so the readers' live `seoDefaults` fallback still applies.
 */
final class PageRegistry
{
    public static function sync(Template $template): void
    {
        $tpl  = $template->getName();
        $sort = 0;
        foreach ($template->getPages() as $page) {
            $sort += 10;
            if (Page::exists($tpl, $page)) {
                continue;
            }
            Page::upsert($tpl, $page, self::seedRow($template, $page, $sort));
        }
        self::syncExtensionPages($template);
    }

    /**
     * Keep the rows of extension pages (Helpers\ExtensionPages) in step with
     * the modules that own them.
     *
     * A new page gets a row, seeded like any other. On a row that exists,
     * only what the module owns is written: the address and whether the page
     * is live, which together decide whether it is in the sitemap. What an
     * admin set in Pages (SEO, visibility, area, layout) is never touched.
     * A row whose page the module no longer reports is removed, but only when
     * the module did report: one whose page list failed keeps every row.
     *
     * Cheap enough to call whenever a module changes one of its pages, which
     * is what keeps the sitemap right without a visit to the Pages screen.
     */
    public static function syncExtensionPages(Template $template): void
    {
        $tpl     = $template->getName();
        $pages   = ExtensionPages::all();
        $sort    = 100000;
        // Did anything the sitemap lists change: a page added or removed, its
        // address, or whether it is live?
        $changed = false;
        foreach ($pages as $page => $meta) {
            $sort += 10;
            $before = Page::get($tpl, $page);
            if ($before === null) {
                Page::upsert($tpl, $page, self::seedRow($template, $page, $sort));
            }
            $url  = isset($meta['url']) ? (string)$meta['url'] : null;
            $live = !empty($meta['extension']['live']);
            Page::upsert($tpl, $page, [
                'url'        => $url,
                'published'  => $live,
                'page_group' => (string)($meta['group'] ?? 'Other'),
            ]);
            $changed = $changed || $before === null
                || ($before['url'] ?? null) !== $url
                || !empty($before['published']) !== $live;
        }
        // Rows left behind by pages that are gone. Only keys of modules that
        // registered AND listed their pages on this request are considered: a
        // module that is switched off, or whose page list failed (a database
        // error, say), keeps its rows and the settings in them until it
        // answers again, or its pages are really deleted.
        foreach (Page::all($tpl) as $row) {
            $page = (string)($row['page'] ?? '');
            if (ExtensionPages::answered($page) && !isset($pages[$page])) {
                Page::delete($tpl, $page);
                $changed = true;
            }
        }
        // Which module pages stand in for which theme pages also decides what
        // the sitemap lists (SitemapGenerator), and no row records it: it
        // moves when the site is switched between Theme and Page Builder. A
        // remembered signature tells a switch from an ordinary visit. Left as
        // it is while a module could not list its pages: its stand-ins are
        // unknown, not gone.
        $standIns = [];
        foreach ($pages as $page => $meta) {
            $replaced = (string)($meta['extension']['replaces'] ?? '');
            if ($replaced !== '') {
                $standIns[$page] = $replaced;
            }
        }
        ksort($standIns);
        $signature = $standIns === [] ? '' : (string)json_encode($standIns);
        if (!ExtensionPages::anyFailed() && (string)Settings::getValue($tpl . '_extension_standins', '') !== $signature) {
            Settings::setValue($tpl . '_extension_standins', $signature);
            $changed = true;
        }

        // Only on a real change, so opening the Pages screen writes nothing.
        if ($changed) {
            SitemapGenerator::refresh($tpl);
        }
    }

    /** @return array<string,mixed> */
    private static function seedRow(Template $template, string $page, int $sort): array
    {
        $tpl  = $template->getName();
        $meta = $template->getPageMeta($page);

        // Import legacy key-value storage if present (preserves live overrides).
        $legacy  = Settings::getValue($tpl . '_page_options_' . $page, null);
        $variant = Settings::getValue($tpl . '_page_variant_' . $page, null);
        $legacy  = is_array($legacy) ? $legacy : [];

        $seoDefaults = is_array($meta['seoDefaults'] ?? null) ? $meta['seoDefaults'] : [];

        $title = (string)($legacy['seo']['title'] ?? '');
        $desc  = (string)($legacy['seo']['description'] ?? '');
        $image = (string)($legacy['seo']['social_image'] ?? '');

        $settings = [
            'options'          => is_array($legacy['options'] ?? null) ? $legacy['options'] : [],
            'layout_overrides' => is_array($legacy['layout_overrides'] ?? null)
                ? $legacy['layout_overrides'] : ['main-menu' => null, 'footer' => null],
            'subnav'           => (string)($legacy['subnav'] ?? 'inherit'),
            'svclayout'        => (string)($legacy['svclayout'] ?? 'inherit'),
        ];

        return [
            'url'             => self::urlFor($page, $meta),
            'page_group'      => (string)($meta['group'] ?? 'Other'),
            'seo_enabled'     => true,
            'indexing'        => (string)($legacy['indexing'] ?? $seoDefaults['indexing'] ?? 'inherit'),
            'visibility'      => (string)($legacy['visibility'] ?? 'public'),
            // Store only an explicit legacy override; empty stays null so the
            // reader falls back to the (live) page.php seoDefault.
            'seo_title'       => $title !== '' ? $title : null,
            'seo_description' => $desc  !== '' ? $desc  : null,
            'seo_image'       => $image,
            'variant'         => is_string($variant) && $variant !== '' ? $variant : null,
            'settings'        => $settings,
            'published'       => true,
            'sort'            => $sort,
        ];
    }

    /**
     * Public URL for a page (relative to the WHMCS system URL). An explicit
     * `url` in page.php meta wins; otherwise a conservative convention maps the
     * clearly public/crawlable WHMCS routes to their script. Auth-flow and
     * client-area pages return null (excluded from the sitemap by default); an
     * admin can set a URL on any page from the Pages editor.
     *
     * @param array<string,mixed> $meta
     */
    public static function urlFor(string $page, array $meta): ?string
    {
        if (isset($meta['url']) && is_string($meta['url']) && $meta['url'] !== '') {
            return ltrim($meta['url'], '/');
        }
        static $known = [
            'announcements' => 'announcements.php',
            'knowledgebase' => 'knowledgebase.php',
            'serverstatus'  => 'serverstatus.php',
            'contact'       => 'contact.php',
            // The storefront entry point. Keys here are PAGE SLUGS, and the
            // order form has no core/pages dir — its slugs come from
            // Template::ORDER_PAGES, where cart.php's landing view is
            // 'products'. (This entry was keyed 'cart' for a while, which
            // matches nothing and silently seeded no URL.) The per-group
            // /store/<slug> pages are the sitemap's Product Groups source,
            // same as Lagom — this row is just the group-less entry.
            'products'      => 'cart.php',
            'affiliates'    => 'affiliates.php',
        ];
        return $known[$page] ?? null;
    }
}
