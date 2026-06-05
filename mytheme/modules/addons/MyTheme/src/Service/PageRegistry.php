<?php
declare(strict_types=1);

namespace MyTheme\Service;

use MyTheme\Models\Page;
use MyTheme\Models\Settings;
use MyTheme\Template\Template;

/**
 * Seeds + maintains the `mytheme_pages` registry from the filesystem page set.
 *
 * Idempotent. Run ONLY from the admin Pages-tab self-heal — never from the
 * client-area render path. For each discovered page WITHOUT a row it creates
 * one, importing any legacy mytheme_settings `<tpl>_page_options_<page>` /
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
            'cart'          => 'cart.php',
            'affiliates'    => 'affiliates.php',
        ];
        return $known[$page] ?? null;
    }
}
