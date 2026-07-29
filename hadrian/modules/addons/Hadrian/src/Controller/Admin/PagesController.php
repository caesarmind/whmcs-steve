<?php
declare(strict_types=1);

namespace Hadrian\Controller\Admin;

use Hadrian\Controller\AbstractController;
use Hadrian\Database\Migrator;
use Hadrian\Helpers\AddonHelper;
use Hadrian\Helpers\LocaleHelper;
use Hadrian\Helpers\PageUrlResolver;
use Hadrian\Helpers\ThemeManifest;
use Hadrian\Models\Settings;
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

            // Public URL for the "Open" link. Resolved from data we already
            // have in $options, so no extra query per row.
            $public = PageUrlResolver::resolve(
                $page,
                (string)($options['url'] ?? ''),
                (string)($options['visibility'] ?? 'public')
            );

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
                'publicUrl'    => $public['url'],
                'publicReason' => $public['reason'],
                // Filtered behind a toggle in the list, never dropped.
                'isSystem'     => in_array($page, self::SYSTEM_PAGES, true),
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
            'systemCount'  => count(array_filter($rows, static fn (array $r): bool => !empty($r['isSystem']))),
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

        // Languages for the multi-language SEO fields (one field per language;
        // a single-language install renders exactly one, as before).
        $seoLanguages = array_map(
            fn (string $l) => ['name' => $l, 'label' => ucwords(str_replace(['-', '_'], ' ', $l))],
            LocaleHelper::effectiveList()
        );
        // Which language the editor's picker should open on when nothing is
        // translated yet. Without this the view fell back to the first entry of
        // an alphabetical list, so a fresh install opened every page on Arabic.
        $seoDefaultLanguage = LocaleHelper::systemDefault();

        // Resolve the page's own public URL once, here, so the view never has
        // to build one (and can never build a different one from the list).
        $publicLink = PageUrlResolver::resolve(
            $page,
            (string)($options['url'] ?? ''),
            (string)($options['visibility'] ?? 'public')
        );

        // EVERY variant's options are rendered, each tagged with the variant
        // that owns it; the view shows only the selected one's and swaps them
        // as soon as a different template card is clicked. Rendering just the
        // active variant's meant its settings did not appear until the page had
        // been saved, which contradicts the panel's own copy ("Choosing a
        // different template changes what appears here").
        //
        // Rendering them all is also what preserves them: every field posts, so
        // an unselected template's values round-trip through the save untouched
        // rather than relying on the absent-key fallback.
        $supportedOptions = self::declaredOptions($template, $page, $meta);
        $variantLabels    = [];
        foreach ($variants as $v) {
            $variantLabels[(string)($v['name'] ?? '')] = (string)($v['label'] ?? $v['name'] ?? '');
        }

        // Project each declared option onto a uniform row the view can iterate.
        $optionRows = [];
        foreach ($supportedOptions as $key => $spec) {
            $optionRows[] = [
                'key'     => (string)$key,
                'type'    => (string)($spec['type'] ?? 'string'),
                'label'   => (string)($spec['label'] ?? ucwords(str_replace(['_', '-'], ' ', (string)$key))),
                // Every pageoption.php in the theme declares 'tooltip', not
                // 'help' — reading only 'help' meant all 60 help lines rendered
                // blank. 'help' stays first so an option can still use it.
                'help'    => (string)($spec['help'] ?? $spec['tooltip'] ?? ''),
                // Needed by the select branch in the view; without it a
                // declared select had no choices to draw.
                'options' => is_array($spec['options'] ?? null) ? array_values($spec['options']) : [],
                'default' => $spec['default'] ?? null,
                'value'   => $options['options'][$key] ?? $spec['default'] ?? null,
                // Which template owns this option; '' = applies to all of them.
                // The view tags each control with it so the client can swap the
                // visible set the instant a different template is picked.
                'variant' => (string)($spec['_variant'] ?? ''),
            ];
        }

        // Catalogue for any option declared with type 'sections'. Passed beside
        // $optionRows rather than folded into it: the projection above is a flat
        // scalar shape that four other option types depend on, and a 'sections'
        // option needs two nested maps (the section list and the width choices).
        // The view emits this as JSON for the layout builder to enhance the
        // option's plain text input into a sortable list.
        $sectionSpecs = [];
        foreach ($supportedOptions as $key => $spec) {
            if (!is_array($spec) || ($spec['type'] ?? '') !== 'sections') {
                continue;
            }
            $owner = (string)($spec['_variant'] ?? '');
            $sectionSpecs[(string)$key] = [
                // Heading for the builder's own card. Falls back to the option
                // label, which reads fine but carries the variant suffix.
                'title'        => (string)($spec['title'] ?? $spec['label'] ?? 'Sections'),
                'variant'      => $owner,
                'variantLabel' => $variantLabels[$owner] ?? $owner,
                'sections'     => is_array($spec['sections'] ?? null) ? $spec['sections'] : [],
                'widths'       => is_array($spec['widths'] ?? null) ? $spec['widths'] : [],
                // Palette the per-section colour control offers. Was computed
                // for the parser but never reached the view, so the builder
                // could not draw the control at all.
                'paints'       => $this->resolvePaintSwatches(
                    $template,
                    is_array($spec['paints'] ?? null) ? $spec['paints'] : []
                ),
                // Per-section "items shown" control. Declared by the variant
                // that wants it (bento) so it never appears for one whose
                // template would ignore it (minimal, which has Show more).
                'rowsControl'  => is_array($spec['rowsControl'] ?? null) ? $spec['rowsControl'] : null,
            ];
        }

        return $this->view('pages/edit', [
            'page'             => $page,
            'sectionSpecsJson' => (string)json_encode($sectionSpecs, JSON_UNESCAPED_SLASHES),
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
            'seoDefaultLanguage' => $seoDefaultLanguage,
            // Public URL for the "View page" link in the toolbar. Same
            // resolver as the list, so the two can never disagree.
            'publicUrl'        => $publicLink['url'],
            'publicUrlReason'  => $publicLink['reason'],
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

        // Supported options — type-coerce per spec. The declared set spans the
        // page AND every variant, so saving while template A is selected does
        // not drop template B's stored options.
        $supportedOptions = self::declaredOptions($template, $page, $meta);
        $submitted        = is_array($_POST['option'] ?? null) ? $_POST['option'] : [];
        $existing         = self::storedOptions($template->getName(), $page);
        $options          = [];
        foreach ($supportedOptions as $key => $spec) {
            $type = (string)($spec['type'] ?? 'string');

            // Not on this form at all — an option belonging to a variant that
            // is not currently selected. Carry the stored value through
            // untouched. Without this the coercion below would write it as
            // false/0/'' and wipe that template's configuration. (Rendered
            // controls always post: checkboxes ship a paired hidden 0, and
            // selects and text inputs always submit.)
            if (!array_key_exists($key, $submitted)) {
                if (array_key_exists($key, $existing)) {
                    $options[(string)$key] = $existing[$key];
                }
                continue;
            }

            $raw = $submitted[$key] ?? null;
            $options[(string)$key] = match ($type) {
                // 'checkbox' is what every pageoption.php actually declares;
                // without it here a toggle round-tripped as the string "1"/""
                // rather than a real bool.
                'bool', 'checkbox' => $raw !== null && $raw !== '' && $raw !== '0' && $raw !== 0 && $raw !== false,
                'int'   => (int)$raw,
                // Reject anything not on the declared list so a hand-edited
                // form can't store a value the page never offered.
                'select' => in_array((string)$raw, array_map('strval', (array)($spec['options'] ?? [])), true)
                    ? (string)$raw
                    : (string)($spec['default'] ?? ''),
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
     * Separator between an option key and the variant that owns it:
     * `min_sections__minimal`.
     *
     * MUST stay within [a-z0-9_]. This was '@' first, on the reasoning that PHP
     * only mangles dots and spaces in POST keys — but WHMCS's own input
     * handling drops the key entirely, so every variant-scoped option silently
     * failed to save while bare keys on the same form saved fine. Verified on
     * the live admin: option[heroTitle] persists, option[min_sections@minimal]
     * does not. Underscores are the character class every working option key
     * already uses.
     */
    private const VARIANT_SEP = '__';

    /**
     * The options currently stored for a page, raw. Used on save to carry
     * through anything the submitted form did not render.
     *
     * @return array<string,mixed>
     */
    private static function storedOptions(string $tpl, string $page): array
    {
        $row = \Hadrian\Models\Page::get($tpl, $page);
        if ($row === null) {
            return [];
        }
        $settings = is_array($row['settings'] ?? null) ? $row['settings'] : [];
        return is_array($settings['options'] ?? null) ? $settings['options'] : [];
    }

    /**
     * EVERY option this page can store: page.php's own (which apply whichever
     * template is selected) plus each variant's, namespaced `<key>@<variant>`.
     *
     * The full set matters on SAVE. saveAction rebuilds settings['options']
     * from scratch, so a key missing from the declared set is dropped — which
     * would mean selecting template A and saving silently destroyed template
     * B's block layout. Declaring all of them keeps every variant's config
     * alive regardless of which one is active.
     *
     * @param array<string,mixed> $meta page.php metadata
     * @return array<string, array<string,mixed>>
     */
    /**
     * Turn a variant's `paints` vocabulary into swatches the builder can draw.
     *
     * Each paint names the CSS token it resolves to at render time (the same
     * mapping the .min-section[data-blk-paint="..."] rules use), so the swatch
     * is resolved the way the front end resolves it: the per-mode default from
     * core/config/colors.php with the buyer's Styles > Colors override on top.
     * Hardcoding hexes here would look right on a stock install and lie on
     * every customised one -- and "Block accent 1/2/3" exist precisely to be
     * customised, so they would lie immediately.
     *
     * LIGHT mode, default style: the picker is a small preview, not a theme
     * switcher, and one honest value beats a dark-mode value on a light admin.
     *
     * Tolerates the legacy `key => 'Label'` shape, so a variant that has not
     * been migrated still lists its paints (without swatches) rather than
     * losing the control altogether.
     *
     * @param array<string, array{label?:string, var?:string}|string> $paints
     * @return array<string, array{label:string, swatch:string}>
     */
    /**
     * Mix two #rrggbb colours, $pct% of the first. Mirrors the CSS
     * color-mix(in srgb, A pct%, B) the derived paints use, so the admin swatch
     * and the rendered block agree. Returns '' for anything that is not a plain
     * hex pair -- rgba() tints and named colours are left to the caller's
     * fallback rather than approximated.
     */
    private static function mixHex(string $a, string $b, int $pct): string
    {
        if (preg_match('/^#([0-9a-f]{6})$/i', trim($a), $ma) !== 1
            || preg_match('/^#([0-9a-f]{6})$/i', trim($b), $mb) !== 1) {
            return '';
        }
        $pct = max(0, min(100, $pct)) / 100;
        $out = '#';
        for ($i = 0; $i < 3; $i++) {
            $ca = (int)hexdec(substr($ma[1], $i * 2, 2));
            $cb = (int)hexdec(substr($mb[1], $i * 2, 2));
            $out .= str_pad(dechex((int)round($ca * $pct + $cb * (1 - $pct))), 2, '0', STR_PAD_LEFT);
        }
        return $out;
    }

    private function resolvePaintSwatches(Template $template, array $paints): array
    {
        if ($paints === []) {
            return [];
        }

        $defaults = [];
        try {
            $cfg = ThemeManifest::loadVariantMeta(
                $template->getFullPath() . '/core/config/colors.php'
            );
            foreach (($cfg['groups'] ?? []) as $tokens) {
                foreach ($tokens as $t) {
                    if (isset($t['var'])) {
                        $defaults[(string)$t['var']] = (string)($t['light'] ?? '');
                    }
                }
            }
        } catch (\Throwable) {
            // No schema -- fall through to label-only chips rather than fail
            // the whole Pages screen over a decoration.
        }

        // The ACTIVE style, resolved exactly as Hooks::buildColorsHead resolves
        // it for the front end -- including the legacy dark/empty pointer and
        // the pre-refactor key. A swatch read from a style the site is not
        // using would be a picker that disagrees with the page it configures.
        $name   = $template->getName();
        $active = (string)Settings::getValue($name . '_active_style', 'default');
        if ($active === 'dark' || $active === '') {
            $active = 'default';
        }
        $stored = [];
        foreach (['_colors_' . $active . '_light', '_colors_' . $active] as $k) {
            $v = Settings::getValue($name . $k, null);
            if (is_array($v) && $v !== []) {
                $stored = $v;
                break;
            }
        }

        $out = [];
        foreach ($paints as $key => $spec) {
            $label = is_array($spec) ? (string)($spec['label'] ?? $key) : (string)$spec;
            $var   = is_array($spec) ? (string)($spec['var'] ?? '') : '';
            $value = $var !== '' ? (string)($stored[$var] ?? $defaults[$var] ?? '') : '';
            // A derived paint (the passive accent) is a mix in the CSS, so mix
            // it the same way here or the swatch shows the colour it was
            // derived FROM rather than the one the block will be.
            if ($value !== '' && is_array($spec) && isset($spec['mix'], $spec['mixWith'])) {
                $with = (string)$spec['mixWith'];
                $base = (string)($stored[$with] ?? $defaults[$with] ?? '#ffffff');
                $value = self::mixHex($value, $base, (int)$spec['mix']) ?: $value;
            }
            $out[(string)$key] = [
                'label'  => $label,
                'swatch' => $value,
                // What this key follows -- see the note beside the vocabulary
                // in <variant>.php. The picker groups on it, because a strip of
                // identical swatches gives no way to tell that Accent moves
                // with a preset and Purple does not.
                'track'  => is_array($spec) ? (string)($spec['track'] ?? 'token') : 'token',
            ];
        }
        return $out;
    }

    private static function declaredOptions(Template $template, string $page, array $meta): array
    {
        $out = is_array($meta['supportedOptions'] ?? null) ? $meta['supportedOptions'] : [];
        foreach ($template->getPageVariants($page) as $v) {
            $vName = (string)($v['name'] ?? '');
            $vMeta = $template->getVariantMeta($page, $vName);
            $vOpts = is_array($vMeta['supportedOptions'] ?? null) ? $vMeta['supportedOptions'] : [];
            foreach ($vOpts as $k => $spec) {
                if (!is_array($spec)) { continue; }
                $spec['_variant'] = $vName;
                $out[$k . self::VARIANT_SEP . $vName] = $spec;
            }
        }
        return $out;
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
    /**
     * Pages that exist so WHMCS has something to render mid-flow, but that an
     * admin never navigates to and rarely configures: wizard sub-steps,
     * partials included by another page, and error states WHMCS substitutes
     * for whatever page you asked for.
     *
     * These are FILTERED, not removed. The Pages list hides them behind a
     * "Show system pages" toggle rather than dropping them, because
     * page.php's own `listDisplay => false` makes a page reachable only by
     * typing its ?sub=edit&page= URL — fine for the four password-reset
     * dispatchers that genuinely have nothing to set, but wrong for a page
     * like two-factor-challenge that a visitor really sees and an admin may
     * legitimately want to give a layout override or a noindex.
     *
     * Classification comes from tracing each one to how WHMCS actually
     * reaches it; see the notes per entry.
     *
     * @var list<string>
     */
    private const SYSTEM_PAGES = [
        // Error states — WHMCS renders these INSTEAD of the page you asked for.
        'access-denied',
        'banned',
        'downloaddenied',
        // Not a routed page at all: a per-metric modal fragment that
        // clientareaproductdetails includes.
        'usagebillingpricing',
        // Gateway interstitial, auto-submitted mid-payment.
        '3dsecure',
        // Ticket submission: only the POST-entered confirmation and the two
        // partials step 2 includes. NOT -stepone or -steptwo, which are both
        // plain GET destinations -- verified live, /submitticket.php returns
        // data-tpl="supportticketsubmit-stepone" and
        // ?step=2&deptid=1 returns data-tpl="supportticketsubmit-steptwo"
        // (?step=3 redirects to login, so confirm really is unreachable).
        'supportticketsubmit-confirm',
        'supportticketsubmit-customfields',
        'supportticketsubmit-kbsuggestions',
        // SSL wizard steps 2 and 3 only: step 1 is GET-entered from the SSL
        // module's link (configuressl.php?cert=<hash>) and its own stock
        // template branches on {if !$status} to an "Invalid link" message,
        // which can only render on a bare GET. Steps 2-3 are POSTed to.
        'configuressl-steptwo',
        'configuressl-complete',
        // Upgrade wizard steps 2 and 3; step 1 is `upgrade`, which stays.
        'upgrade-configure',
        'upgradesummary',
        // Shown mid-login / once after generating a code.
        'two-factor-challenge',
        'two-factor-new-backup-code',
        // Per-domain buy/disable confirmation; needs domainid + action + addon.
        'clientareadomainaddons',

        // ── Legacy template names WHMCS 9 never renders ──────────────────
        // Each pairs with a modern templatefile that IS emitted, so the list
        // was showing two rows for one screen. Confirmed by their absence from
        // BOTH stock themes in this repo: `six` is what WHMCS falls back to
        // when the active theme lacks a template, so a name missing from six
        // AND nexus cannot be one WHMCS 9 emits. The legacy URLs still resolve
        // (clientarea.php?action=changepw|contacts|users all return 200) --
        // it is the URL that stayed compatible, not the templatefile.
        //
        // These rows are inert: Hooks::resolveCurrentPage keys off
        // $vars['templatefile'], so settings saved against them never reach a
        // request. Hiding the row loses nothing.
        //
        // DO NOT DELETE THE DIRECTORIES. Several are still load-bearing:
        // supporttickets/ holds the real 14 KB implementation that the
        // 74-byte supportticketslist/ forwards to, supportticketsubmit/ holds
        // the 21 KB implementation that -stepone and -steptwo include, and
        // most are menu URL targets (Menu\WhmcsDefaults) or picker entries
        // (Menu\MenuPages) with page names already persisted in seeded menus.
        'changepassword',       // -> user-password
        'changepw',             // -> user-password
        'clientareacontacts',   // -> account-contacts-manage
        'clientareausers',      // -> account-user-management
        'supporttickets',       // -> supportticketslist
        'submitticket',         // -> supportticketsubmit-stepone
        'supportticketsubmit',  // -> supportticketsubmit-stepone / -steptwo

        // NB deliberately NOT here: custom-page (the designed extension point),
        // the 13 bespoke store-* Shop pages, `upgrade` (GET-linked from
        // productdetails), and the four password-reset-* dirs, which already
        // carry listDisplay => false in their own page.php.
    ];

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
