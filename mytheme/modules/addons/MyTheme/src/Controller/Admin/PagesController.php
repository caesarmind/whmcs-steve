<?php
declare(strict_types=1);

namespace MyTheme\Controller\Admin;

use MyTheme\Controller\AbstractController;
use MyTheme\Helpers\AddonHelper;
use MyTheme\Models\Settings;
use MyTheme\Template\PagesCache;
use MyTheme\Template\Template;

/**
 * Admin: list, edit, save per-page configuration.
 *
 * Routing — MainController::pagesAction reads ?sub= and dispatches:
 *   index   → grouped page list (?tab=Public|Authentication|… filters group)
 *   edit    → editor for one page (?page=login)
 *   save    → POST handler that writes mytheme_settings rows
 *
 * Storage:
 *   mytheme_<slug>_page_variant_<page>    string  — active variant name
 *   mytheme_<slug>_page_options_<page>    json    — see savedOptionsShape() below
 */
final class PagesController extends AbstractController
{
    /** @var list<string> */
    private const VALID_INDEXING   = ['allow', 'disallow', 'inherit'];
    /** @var list<string> */
    private const VALID_VISIBILITY = ['public', 'auth', 'disabled'];

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

        $rows = [];
        $allGroups = [];
        foreach ($template->getPages() as $page) {
            $meta    = $template->getPageMeta($page);
            $group   = (string)($meta['group'] ?? 'Other');
            $allGroups[$group] = true;

            $variant = (string)Settings::getValue(
                $template->getName() . '_page_variant_' . $page,
                (string)($meta['defaultVariant'] ?? 'default')
            );
            $options = $this->readPageOptions($template, $page, $meta);

            $rows[] = [
                'name'         => $page,
                'label'        => (string)($meta['display_name'] ?? ucwords(str_replace(['-', '_'], ' ', $page))),
                'group'        => $group,
                'description'  => (string)($meta['description'] ?? ''),
                'variant'      => $variant,
                'variantLabel' => ucfirst(str_replace(['-', '_'], ' ', $variant)),
                'hasSeo'       => $options['seo']['title'] !== '' || $options['seo']['description'] !== '',
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
        $defaultVar    = (string)($meta['defaultVariant'] ?? 'default');
        $activeVariant = (string)Settings::getValue(
            $template->getName() . '_page_variant_' . $page,
            $defaultVar
        );

        $options          = $this->readPageOptions($template, $page, $meta);
        $supportedOptions = is_array($meta['supportedOptions'] ?? null) ? $meta['supportedOptions'] : [];

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
            'seo'              => $options['seo'],
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
        Settings::setValue($template->getName() . '_page_variant_' . $page, $chosenVariant);

        // Indexing & visibility — whitelist.
        $indexing   = (string)($_POST['indexing']   ?? 'inherit');
        $visibility = (string)($_POST['visibility'] ?? 'public');
        if (!in_array($indexing,   self::VALID_INDEXING,   true)) { $indexing   = 'inherit'; }
        if (!in_array($visibility, self::VALID_VISIBILITY, true)) { $visibility = 'public'; }

        // SEO — trim, length-cap, and decode WHMCS 9's POST-time htmlspecialchars
        // wrap so `AT&T` doesn't round-trip as `AT&amp;amp;T` after one save +
        // one render (same fix the menu builder applies to its JSON fields).
        $seo = [
            'title'        => substr(htmlspecialchars_decode(trim((string)($_POST['seo_title']        ?? '')), ENT_QUOTES), 0, 200),
            'description'  => substr(htmlspecialchars_decode(trim((string)($_POST['seo_description']  ?? '')), ENT_QUOTES), 0, 400),
            'social_image' => substr(htmlspecialchars_decode(trim((string)($_POST['seo_social_image'] ?? '')), ENT_QUOTES), 0, 500),
        ];

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

        $payload = [
            'indexing'         => $indexing,
            'visibility'       => $visibility,
            'seo'              => $seo,
            'options'          => $options,
            'layout_overrides' => $layoutOverrides,
        ];
        Settings::setValue($template->getName() . '_page_options_' . $page, $payload, 'json');

        $this->redirect('?module=MyTheme&action=pages&sub=edit&page=' . urlencode($page) . '&flash=saved');
    }

    /**
     * Read stored options and merge with page.php seoDefaults.
     *
     * @return array{
     *   indexing: string,
     *   visibility: string,
     *   seo: array{title:string,description:string,social_image:string},
     *   options: array<string,bool|int|string>,
     *   layout_overrides: array{main-menu: ?string, footer: ?string},
     * }
     */
    private function readPageOptions(Template $template, string $page, array $meta): array
    {
        $stored = Settings::getValue($template->getName() . '_page_options_' . $page, null);
        if (!is_array($stored)) {
            $stored = [];
        }
        $seoDefaults = is_array($meta['seoDefaults'] ?? null) ? $meta['seoDefaults'] : [];

        return [
            'indexing'   => (string)($stored['indexing']   ?? $seoDefaults['indexing'] ?? 'inherit'),
            'visibility' => (string)($stored['visibility'] ?? 'public'),
            'seo' => [
                'title'        => (string)($stored['seo']['title']        ?? $seoDefaults['title']        ?? ''),
                'description'  => (string)($stored['seo']['description']  ?? $seoDefaults['description']  ?? ''),
                'social_image' => (string)($stored['seo']['social_image'] ?? ''),
            ],
            'options' => is_array($stored['options'] ?? null) ? $stored['options'] : [],
            'layout_overrides' => [
                'main-menu' => isset($stored['layout_overrides']['main-menu']) && is_string($stored['layout_overrides']['main-menu'])
                    ? $stored['layout_overrides']['main-menu'] : null,
                'footer'    => isset($stored['layout_overrides']['footer']) && is_string($stored['layout_overrides']['footer'])
                    ? $stored['layout_overrides']['footer'] : null,
            ],
        ];
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
