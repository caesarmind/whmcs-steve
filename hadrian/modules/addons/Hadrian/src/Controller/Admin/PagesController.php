<?php
declare(strict_types=1);

namespace Hadrian\Controller\Admin;

use Hadrian\Controller\AbstractController;
use Hadrian\Database\Migrator;
use Hadrian\Helpers\AddonHelper;
use Hadrian\Helpers\LocaleHelper;
use Hadrian\Models\Page;
use Hadrian\Service\PageRegistry;
use Hadrian\Template\PagesCache;
use Hadrian\Template\Template;

/**
 * Admin: list, edit, save per-page configuration.
 *
 * Routing — MainController::pagesAction reads ?sub= and dispatches:
 *   index   → grouped page list (?tab=Public|Authentication|… filters group)
 *   edit    → editor for one page (?page=login)
 *   save    → POST handler that writes the hadrian_pages registry row
 *
 * Storage: one row per (template, page) in the hadrian_pages table (see
 * Models\Page). PagesController self-heals on the index hit — Migrator creates
 * the table and PageRegistry::sync seeds a row per filesystem page, importing
 * any legacy hadrian_settings `<tpl>_page_options_<page>` /
 * `<tpl>_page_variant_<page>` rows (kept untouched as a rollback path).
 */
final class PagesController extends AbstractController
{
    /** @var list<string> */
    private const VALID_INDEXING   = ['allow', 'disallow', 'inherit'];
    /** @var list<string> */
    private const VALID_VISIBILITY = ['public', 'auth', 'disabled'];
    /** @var list<string> */
    private const VALID_SUBNAV     = ['inherit', 'on', 'off'];
    /** @var list<string> */
    private const VALID_SVCLAYOUT  = ['inherit', 'inside', 'outside'];

    public function indexAction(): string
    {
        $template = AddonHelper::getTemplate();
        if ($template === null) {
            return $this->view('error', ['error' => 'No active template']);
        }

        // Self-heal: build the discovery cache on the first admin visit
        // when activation hasn't populated it yet (e.g. addon was already
        // active before pages discovery existed). Idempotent + admin-only,
        // so this honors the "no runtime filesystem scans" rule for the
        // client-area path while still surfacing every page in the editor.
        PagesCache::ensure($template);

        // Self-heal: create/upgrade the hadrian_pages table and seed a row for
        // every discovered page (importing any legacy hadrian_settings page
        // config). Idempotent + admin-only — never runs on the client-area path.
        try {
            (new Migrator(dirname(__DIR__, 3)))->migrate();
            PageRegistry::sync($template);
        } catch (\Throwable $e) {
            error_log('Hadrian pages self-heal failed: ' . $e->getMessage());
        }

        $rows = [];
        $allGroups = [];
        foreach ($template->getPages() as $page) {
            $meta    = $template->getPageMeta($page);
            // Honor the page.php `listDisplay` flag (Lagom parity). Pages that opt
            // out (e.g. the include-only password-reset step dispatchers, which all
            // forward to the shared pwreset implementation) are hidden from the grid
            // so it isn't cluttered with near-duplicate, non-configurable rows. They
            // still render normally and stay reachable via a direct ?sub=edit&page=
            // URL — this only affects listing.
            if (($meta['listDisplay'] ?? true) === false) {
                continue;
            }
            $group   = (string)($meta['group'] ?? 'Other');
            $allGroups[$group] = true;

            $options = $this->readPageOptions($template, $page, $meta);
            $variant = $options['variant'];

            $rows[] = [
                'name'         => $page,
                'label'        => (string)($meta['display_name'] ?? ucwords(str_replace(['-', '_'], ' ', $page))),
                'group'        => $group,
                'description'  => (string)($meta['description'] ?? ''),
                'variant'      => $variant,
                'variantLabel' => ucfirst(str_replace(['-', '_'], ' ', $variant)),
                'hasSeo'       => $options['hasSeo'],
                'indexing'     => $options['indexing'],
                'visibility'   => $options['visibility'],
            ];
        }

        $groups = array_keys($allGroups);
        usort($groups, function ($a, $b) {
            $oa = $this->groupOrder($a);
            $ob = $this->groupOrder($b);
            return $oa === $ob ? strcmp($a, $b) : $oa <=> $ob;
        });

        // Bucket rows by group and sort each bucket alphabetically by label.
        // Tab switching is now client-side (no server-side filtering) so every
        // bucket is rendered once and shown/hidden by the inline script.
        $pagesByGroup = array_fill_keys($groups, []);
        foreach ($rows as $r) {
            $g = (string)($r['group'] ?? 'Other');
            if (!isset($pagesByGroup[$g])) $pagesByGroup[$g] = [];
            $pagesByGroup[$g][] = $r;
        }
        foreach ($pagesByGroup as &$bucket) {
            usort($bucket, fn ($a, $b) => strcmp($a['label'], $b['label']));
        }
        unset($bucket);

        return $this->view('pages/index', [
            'groups'       => $groups,
            'pagesByGroup' => $pagesByGroup,
            'totalCount'   => count($rows),
            'flashMsg'     => (string)($_GET['flash'] ?? ''),
        ]);
    }

    public function editAction(): string
    {
        $template = AddonHelper::getTemplate();
        if ($template === null) {
            return $this->view('error', ['error' => 'No active template']);
        }

        $page = (string)($_GET['page'] ?? '');
        if ($page === '' || !in_array($page, $template->getPages(), true)) {
            return $this->view('error', ['error' => 'Unknown page: ' . htmlspecialchars($page, ENT_QUOTES)]);
        }

        $meta          = $template->getPageMeta($page);
        $variants      = $template->getPageVariants($page);

        $options          = $this->readPageOptions($template, $page, $meta);
        $activeVariant    = $options['variant'];
        $supportedOptions = is_array($meta['supportedOptions'] ?? null) ? $meta['supportedOptions'] : [];

        // Languages for the multi-language SEO fields (one field per language;
        // a single-language install renders exactly one, as before).
        $seoLanguages = array_map(
            fn (string $l) => ['name' => $l, 'label' => ucwords(str_replace(['-', '_'], ' ', $l))],
            LocaleHelper::effectiveList()
        );

        // Project each declared option onto a uniform row the view can iterate.
        $optionRows = [];
        foreach ($supportedOptions as $key => $spec) {
            $optionRows[] = [
                'key'     => (string)$key,
                'type'    => (string)($spec['type'] ?? 'string'),
                'label'   => (string)($spec['label'] ?? ucwords(str_replace(['_', '-'], ' ', (string)$key))),
                'help'    => (string)($spec['help'] ?? ''),
                'default' => $spec['default'] ?? null,
                'value'   => $options['options'][$key] ?? $spec['default'] ?? null,
            ];
        }

        return $this->view('pages/edit', [
            'page'             => $page,
            'pageLabel'        => (string)($meta['display_name'] ?? ucwords(str_replace(['-', '_'], ' ', $page))),
            'pageGroup'        => (string)($meta['group'] ?? 'Other'),
            'pageDescription'  => (string)($meta['description'] ?? ''),
            'variants'         => $variants,
            'activeVariant'    => $activeVariant,
            'optionRows'       => $optionRows,
            'hasOptions'       => count($optionRows) > 0,
            'indexing'         => $options['indexing'],
            'visibility'       => $options['visibility'],
            'subnav'           => $options['subnav'],
            'svclayout'          => $options['svclayout'],
            'svcLayoutApplicable' => in_array($page, Template::SVC_LAYOUT_PAGES, true),
            'seo'              => $options['seo'],
            'seoUrl'           => $options['url'],
            'seoLanguages'     => $seoLanguages,
            'layoutChoices'    => [
                'main-menu' => $this->layoutChoices($template, 'main-menu'),
                'footer'    => $this->layoutChoices($template, 'footer'),
            ],
            'layoutOverrides'  => $options['layout_overrides'],
            'flashMsg'         => (string)($_GET['flash'] ?? ''),
        ]);
    }

    public function saveAction(): string
    {
        $template = AddonHelper::getTemplate();
        if ($template === null) {
            return $this->view('error', ['error' => 'No active template']);
        }

        $page = (string)($_POST['page'] ?? '');
        if (!in_array($page, $template->getPages(), true)) {
            return $this->view('error', ['error' => 'Unknown page: ' . htmlspecialchars($page, ENT_QUOTES)]);
        }

        $meta       = $template->getPageMeta($page);
        $variants   = $template->getPageVariants($page);
        $defaultVar = (string)($meta['defaultVariant'] ?? 'default');

        // Variant — accept only filesystem-discovered names.
        $submittedVariant = (string)($_POST['variant'] ?? '');
        $validNames       = array_column($variants, 'name');
        $chosenVariant    = in_array($submittedVariant, $validNames, true) ? $submittedVariant : $defaultVar;

        // Indexing & visibility — whitelist.
        $indexing   = (string)($_POST['indexing']   ?? 'inherit');
        $visibility = (string)($_POST['visibility'] ?? 'public');
        $subnav     = (string)($_POST['subnav']     ?? 'inherit');
        $svclayout  = (string)($_POST['svclayout']  ?? 'inherit');
        if (!in_array($indexing,   self::VALID_INDEXING,   true)) { $indexing   = 'inherit'; }
        if (!in_array($visibility, self::VALID_VISIBILITY, true)) { $visibility = 'public'; }
        if (!in_array($subnav,     self::VALID_SUBNAV,     true)) { $subnav     = 'inherit'; }
        if (!in_array($svclayout,  self::VALID_SVCLAYOUT,  true)) { $svclayout  = 'inherit'; }

        // SEO title/description are per-language maps keyed by WHMCS language
        // name; the editor submits seo_title[<lang>] / seo_description[<lang>].
        // Trim, length-cap, and decode WHMCS 9's POST-time htmlspecialchars wrap
        // so `AT&T` doesn't round-trip as `AT&amp;amp;T` (same fix the menu
        // builder applies). Only non-empty languages are stored; an all-empty
        // field becomes null so the reader falls back to the page seoDefault.
        $titleIn  = self::postLangMap('seo_title');
        $descIn   = self::postLangMap('seo_description');
        $titleMap = [];
        $descMap  = [];
        foreach (LocaleHelper::effectiveList() as $lang) {
            $t = substr(htmlspecialchars_decode(trim((string)($titleIn[$lang] ?? '')), ENT_QUOTES), 0, 200);
            $d = substr(htmlspecialchars_decode(trim((string)($descIn[$lang]  ?? '')), ENT_QUOTES), 0, 400);
            if ($t !== '') { $titleMap[$lang] = $t; }
            if ($d !== '') { $descMap[$lang]  = $d; }
        }
        $socialImage = substr(htmlspecialchars_decode(trim((string)($_POST['seo_social_image'] ?? '')), ENT_QUOTES), 0, 500);

        // Public URL — relative to the system URL; blank = not crawlable (null).
        $urlRaw = trim((string)($_POST['url'] ?? ''));
        $url    = $urlRaw === '' ? null : ltrim(substr($urlRaw, 0, 255), '/');

        // Supported options — type-coerce per page.php spec.
        $supportedOptions = is_array($meta['supportedOptions'] ?? null) ? $meta['supportedOptions'] : [];
        $submitted        = is_array($_POST['option'] ?? null) ? $_POST['option'] : [];
        $options          = [];
        foreach ($supportedOptions as $key => $spec) {
            $type = (string)($spec['type'] ?? 'string');
            $raw  = $submitted[$key] ?? null;
            $options[(string)$key] = match ($type) {
                'bool'  => $raw !== null && $raw !== '' && $raw !== '0' && $raw !== 0 && $raw !== false,
                'int'   => (int)$raw,
                default => substr((string)$raw, 0, 500),
            };
        }

        // Layout overrides — empty string = inherit (null in stored shape).
        $layoutOverrides = [];
        foreach (['main-menu', 'footer'] as $kind) {
            $key      = 'layout_' . str_replace('-', '_', $kind);
            $override = trim((string)($_POST[$key] ?? ''));
            if ($override !== '' && in_array($override, $template->getLayouts($kind), true)) {
                $layoutOverrides[$kind] = $override;
            } else {
                $layoutOverrides[$kind] = null;
            }
        }

        // Single source of truth: write the hadrian_pages row. Only the keys
        // present here are touched, so seeded columns (seo_enabled/published)
        // are preserved. The legacy hadrian_settings keys are intentionally
        // left untouched as a rollback path.
        Page::upsert($template->getName(), $page, [
            'url'             => $url,
            'page_group'      => (string)($meta['group'] ?? 'Other'),
            'indexing'        => $indexing,
            'visibility'      => $visibility,
            'variant'         => $chosenVariant,
            'seo_title'       => $titleMap !== [] ? $titleMap : null,
            'seo_description' => $descMap  !== [] ? $descMap  : null,
            'seo_image'       => $socialImage,
            'settings'        => [
                'options'          => $options,
                'layout_overrides' => $layoutOverrides,
                'subnav'           => $subnav,
                'svclayout'        => $svclayout,
            ],
        ]);

        $this->redirect('?module=Hadrian&action=pages&sub=edit&page=' . urlencode($page) . '&flash=saved');
    }

    /**
     * Read a page's config from the hadrian_pages registry for the admin editor,
     * merged with page.php seoDefaults. SEO title/description come back as
     * per-language field maps (keyed by WHMCS language name) for the
     * multi-language editor; when nothing is stored in any language the
     * default-language field is pre-filled with the page seoDefault (so the
     * editor shows the effective value, matching the prior single-field UX).
     *
     * @param array<string,mixed> $meta
     * @return array{
     *   variant: string,
     *   url: string,
     *   indexing: string,
     *   visibility: string,
     *   subnav: string,
     *   svclayout: string,
     *   seo: array{title: array<string,string>, description: array<string,string>, social_image: string},
     *   hasSeo: bool,
     *   options: array<string,bool|int|string>,
     *   layout_overrides: array{main-menu: ?string, footer: ?string},
     * }
     */
    private function readPageOptions(Template $template, string $page, array $meta): array
    {
        $row         = Page::get($template->getName(), $page) ?? [];
        $settings    = is_array($row['settings'] ?? null) ? $row['settings'] : [];
        $seoDefaults = is_array($meta['seoDefaults'] ?? null) ? $meta['seoDefaults'] : [];
        $langs       = LocaleHelper::effectiveList();
        if ($langs === []) { $langs = ['english']; }
        $defaultLang = $langs[0];

        $titleFields = self::seoFieldMap($row['seo_title'] ?? null, $langs);
        $descFields  = self::seoFieldMap($row['seo_description'] ?? null, $langs);
        // Pre-fill the default-language field with the page seoDefault when the
        // admin hasn't set anything in any language.
        if (trim(implode('', $titleFields)) === '' && (string)($seoDefaults['title'] ?? '') !== '') {
            $titleFields[$defaultLang] = (string)$seoDefaults['title'];
        }
        if (trim(implode('', $descFields)) === '' && (string)($seoDefaults['description'] ?? '') !== '') {
            $descFields[$defaultLang] = (string)$seoDefaults['description'];
        }

        $lo = is_array($settings['layout_overrides'] ?? null) ? $settings['layout_overrides'] : [];

        return [
            'variant'    => (string)($row['variant'] ?? '') !== ''
                ? (string)$row['variant'] : (string)($meta['defaultVariant'] ?? 'default'),
            'url'        => (string)($row['url'] ?? ''),
            'indexing'   => (string)($row['indexing'] ?? $seoDefaults['indexing'] ?? 'inherit'),
            'visibility' => (string)($row['visibility'] ?? 'public'),
            'subnav'     => (string)($settings['subnav'] ?? 'inherit'),
            'svclayout'  => (string)($settings['svclayout'] ?? 'inherit'),
            'seo' => [
                'title'        => $titleFields,
                'description'  => $descFields,
                'social_image' => (string)($row['seo_image'] ?? ''),
            ],
            'hasSeo'  => trim(implode('', $titleFields)) !== '' || trim(implode('', $descFields)) !== '',
            'options' => is_array($settings['options'] ?? null) ? $settings['options'] : [],
            'layout_overrides' => [
                'main-menu' => isset($lo['main-menu']) && is_string($lo['main-menu']) ? $lo['main-menu'] : null,
                'footer'    => isset($lo['footer']) && is_string($lo['footer']) ? $lo['footer'] : null,
            ],
        ];
    }

    /**
     * Project a stored per-language value (map | string | null) onto an editor
     * field map: one entry per effective language, '' when unset. A legacy plain
     * string binds to the first language only.
     *
     * @param list<string> $langs
     * @return array<string,string>
     */
    private static function seoFieldMap(mixed $raw, array $langs): array
    {
        $first = $langs[0] ?? 'english';
        $out   = [];
        foreach ($langs as $l) {
            $out[$l] = is_array($raw)
                ? (string)($raw[$l] ?? '')
                : ($l === $first ? (string)($raw ?? '') : '');
        }
        return $out;
    }

    /**
     * Read a per-language form field (seo_title[<lang>]) as a map, tolerating a
     * legacy plain-string POST by binding it to the first effective language.
     *
     * @return array<string,string>
     */
    private static function postLangMap(string $field): array
    {
        $raw = $_POST[$field] ?? [];
        if (is_string($raw)) {
            $langs = LocaleHelper::effectiveList();
            return [($langs[0] ?? 'english') => $raw];
        }
        return is_array($raw) ? $raw : [];
    }

    /** Canonical ordering of page groups; unknown groups bucket at the end. */
    private function groupOrder(string $group): int
    {
        return match ($group) {
            'Public'         => 1,
            'Authentication' => 2,
            'Client Area'    => 3,
            'Account'        => 4,
            'Billing'        => 5,
            'Support'        => 6,
            'Shop'           => 7,
            'Order Process'  => 8,
            default          => 99,
        };
    }

    /** @return list<array{name:string,label:string}> */
    private function layoutChoices(Template $template, string $kind): array
    {
        $out = [['name' => '', 'label' => '— Inherit —']];
        foreach ($template->getLayouts($kind) as $name) {
            $out[] = ['name' => $name, 'label' => ucwords(str_replace(['-', '_'], ' ', $name))];
        }
        return $out;
    }
}
