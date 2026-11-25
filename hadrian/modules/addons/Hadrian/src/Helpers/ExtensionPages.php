<?php
declare(strict_types=1);

namespace Hadrian\Helpers;

/**
 * Pages that an extension module adds to the site, listed and configured in
 * Hadrian's Pages screen beside the theme's own.
 *
 * Hadrian knows nothing about any particular extension. A module such as the
 * Page Builder calls register() from its hooks.php with a prefix and a
 * provider, and from then on each page the provider reports:
 *
 *   - is a row in Pages, in the module's own group, with the same settings as
 *     a theme page: SEO, indexing, visibility, area, layout override
 *   - is in the sitemap when it is public and live
 *   - gets those settings applied when the theme draws it (Service\Hooks
 *     resolves the page through keyFor())
 *
 * The page's CONTENT stays the module's business. Pages links to the module's
 * own editor for that ("Edit content") and never touches it.
 *
 * A module can also put its own controls in Pages, so it needs no list screen
 * of its own: a "new page" form on its tab, a panel above its pages (a
 * site-wide switch, say), and a panel on each page's editor (what only that
 * module can set for the page). Those two panels are HTML the module renders
 * and Hadrian prints as given. That is the same trust an addon already has:
 * it runs PHP in this admin. The forms in them post to the module itself.
 *
 * A page is known by a key, "<prefix>-<id>" ("built-12"). The key is what the
 * hadrian_pages registry stores, so it is built from the module's numeric id,
 * which survives a rename or a change of address.
 *
 * The theme treats these the way it already treats the order-form pages: a
 * page with no folder under core/pages, whose description is synthesised
 * (Template::getPageMeta).
 *
 * Per request, no state of its own. A module that is deactivated stops
 * registering; its pages leave the list, and Service\PageRegistry drops their
 * rows the next time the module's pages are synced.
 */
final class ExtensionPages
{
    /** The template an extension's page is drawn through (theme: module-page.tpl). */
    public const TEMPLATE = 'module-page';

    /** @var array<string, array<string,mixed>> by prefix: id, prefix, label, group, createUrl, createLabel, createPlaceholder, panel, pagePanel, provider */
    private static array $modules = [];

    /** @var array<string, array<string,mixed>>|null key => meta, once asked for */
    private static ?array $pages = null;

    /** @var array<string, list<string>>|null theme page => notes */
    private static ?array $notes = null;

    /**
     * @param array<string,mixed> $module
     *        id        the extension's id, as given to Extensions::register()
     *        prefix    2-12 lowercase letters; page keys are "<prefix>-<id>"
     *        label     the module's name, for the row ("Page Builder")
     *        group     the tab its pages are listed under ("Built")
     *        createUrl   "?module=X&..." in the admin: where a new page is
     *                    made. Pages posts a "name" field to it, with the
     *                    admin token, from a small form on the module's tab.
     *        createLabel the form's button ("Create page")
     *        createPlaceholder  hint inside the name field
     *        panel       callable(): string. HTML shown above the module's
     *                    pages on its tab.
     *        pagePanel   callable(int $id): string. HTML shown on the editor
     *                    of one of the module's pages.
     *        contentPanel callable(int $id): string. HTML shown first in that
     *                    editor's main column, beside the SEO rail: a module's
     *                    own controls for what is on the page (Page Builder:
     *                    the page's sections as a list). It sits inside the
     *                    settings form for the layout, so its controls must
     *                    carry NO name= attribute (they would post with Save
     *                    changes) and save through the module's own requests.
     *                    Hadrian stops Enter in its fields submitting the form.
     *        provider  callable(): list<array>, one entry per page:
     *                    id           int, the module's own id for the page
     *                    name         string
     *                    description  string, one line for the row
     *                    url          path from the site root, '' when the page has no address yet
     *                    live         bool, visitors can reach it now
     *                    status       short word for the row: "Published", "Draft"
     *                    editUrl      "?module=X&..." in the admin: where the content is edited
     *                    seoTitle, seoDescription  strings: what the page shows when Pages sets none
     *                    replaces     a theme page this page currently stands in for, '' otherwise
     */
    public static function register(array $module): void
    {
        $prefix   = (string)($module['prefix'] ?? '');
        $provider = $module['provider'] ?? null;
        $label    = trim((string)($module['label'] ?? ''));
        if (!preg_match('/^[a-z]{2,12}$/', $prefix) || !is_callable($provider) || $label === '') {
            return;
        }
        self::$modules[$prefix] = [
            'id'       => strtolower(trim((string)($module['id'] ?? $prefix))),
            'prefix'   => $prefix,
            'label'    => self::cut($label, 40),
            'group'    => self::cut(trim((string)($module['group'] ?? '')) ?: $label, 30),
            'createUrl'   => self::adminUrl((string)($module['createUrl'] ?? '')),
            'createLabel' => self::cut(trim((string)($module['createLabel'] ?? '')), 30) ?: 'Create page',
            'createPlaceholder' => self::cut(trim((string)($module['createPlaceholder'] ?? '')), 80),
            'panel'     => is_callable($module['panel'] ?? null) ? $module['panel'] : null,
            'pagePanel' => is_callable($module['pagePanel'] ?? null) ? $module['pagePanel'] : null,
            'contentPanel' => is_callable($module['contentPanel'] ?? null) ? $module['contentPanel'] : null,
            'provider' => $provider,
        ];
        self::$pages = null;
        self::$notes = null;
    }

    /** Does this key belong to a registered module? No provider is called. */
    public static function owns(string $key): bool
    {
        return preg_match('/^([a-z]{2,12})-[1-9]\d{0,9}$/', $key, $m) === 1 && isset(self::$modules[$m[1]]);
    }

    /**
     * The groups extension pages are listed under, for the Pages screen:
     * group => the module's name, where a new page is made, and the module's
     * own panel for the top of the tab.
     *
     * @return array<string, array{label:string, createUrl:string, createLabel:string, createPlaceholder:string, panelHtml:string}>
     */
    public static function groups(): array
    {
        $out = [];
        foreach (self::$modules as $module) {
            $out[$module['group']] = [
                'label'             => $module['label'],
                'createUrl'         => $module['createUrl'],
                'createLabel'       => $module['createLabel'],
                'createPlaceholder' => $module['createPlaceholder'],
                'panelHtml'         => self::render($module, 'panel'),
            ];
        }
        return $out;
    }

    /**
     * The owning module's panel for one of its pages, for that page's editor
     * in Pages. '' for a theme page, an unknown page, or a module with none.
     */
    public static function pagePanel(string $key): string
    {
        if (!self::owns($key) || !isset(self::all()[$key])) {
            return '';
        }
        [$prefix, $id] = explode('-', $key, 2);
        return self::render(self::$modules[$prefix], 'pagePanel', (int)$id);
    }

    /**
     * The owning module's content controls for one of its pages, for the top
     * of that page's editor in Pages. '' when there are none.
     */
    public static function contentPanel(string $key): string
    {
        if (!self::owns($key) || !isset(self::all()[$key])) {
            return '';
        }
        [$prefix, $id] = explode('-', $key, 2);
        return self::render(self::$modules[$prefix], 'contentPanel', (int)$id);
    }

    /**
     * Run one of a module's panel callbacks. A module whose panel fails shows
     * none; the screen it would have sat on still renders.
     *
     * @param array<string,mixed> $module
     */
    private static function render(array $module, string $which, mixed ...$args): string
    {
        if (!is_callable($module[$which] ?? null)) {
            return '';
        }
        try {
            $html = ($module[$which])(...$args);
            return is_string($html) ? $html : '';
        } catch (\Throwable $e) {
            error_log('Hadrian: extension "' . $module['id'] . '" could not render its ' . $which . ': ' . $e->getMessage());
            return '';
        }
    }

    /** @return list<string> the prefixes of the modules registered on this request */
    public static function prefixes(): array
    {
        return array_keys(self::$modules);
    }

    /**
     * Every extension page, as key => page meta in the shape of a theme
     * page's page.php, plus an `extension` block for the Pages screen.
     *
     * @return array<string, array<string,mixed>>
     */
    public static function all(): array
    {
        if (self::$pages !== null) {
            return self::$pages;
        }
        $pages = [];
        $notes = [];
        foreach (self::$modules as $prefix => $module) {
            try {
                $rows = ($module['provider'])();
            } catch (\Throwable $e) {
                // A module that cannot list its pages lists none; Pages still works.
                error_log('Hadrian: extension "' . $module['id'] . '" could not list its pages: ' . $e->getMessage());
                continue;
            }
            foreach (is_array($rows) ? $rows : [] as $row) {
                $id = (int)(is_array($row) ? ($row['id'] ?? 0) : 0);
                if ($id < 1) {
                    continue;
                }
                $name = self::cut(trim((string)($row['name'] ?? '')), 120);
                $key  = $prefix . '-' . $id;
                $url  = self::path((string)($row['url'] ?? ''));
                $edit = (string)($row['editUrl'] ?? '');
                $live = !empty($row['live']);

                $pages[$key] = [
                    'display_name'     => $name !== '' ? $name : ucfirst($prefix) . ' page ' . $id,
                    'group'            => $module['group'],
                    'type'             => 'extension',
                    'description'      => self::cut(trim((string)($row['description'] ?? '')), 160),
                    'listDisplay'      => true,
                    'supportedOptions' => [],
                    // A module's pages are part of the website unless an admin moves one.
                    'area'             => PageArea::WEBSITE,
                    'seoDefaults'      => [
                        'title'       => self::cut(trim((string)($row['seoTitle'] ?? '')), 200),
                        'description' => self::cut(trim((string)($row['seoDescription'] ?? '')), 400),
                    ],
                    'extension'        => [
                        'id'      => $module['id'],
                        'label'   => $module['label'],
                        'live'    => $live,
                        'status'  => self::cut(trim((string)($row['status'] ?? '')), 20) ?: ($live ? 'Published' : 'Draft'),
                        'editUrl' => self::adminUrl($edit),
                    ],
                ];
                if ($url !== '') {
                    $pages[$key]['url'] = $url;
                }

                $replaces = (string)($row['replaces'] ?? '');
                if ($live && preg_match('/^[a-z0-9][a-z0-9-]{0,60}$/', $replaces)) {
                    $notes[$replaces][] = 'Replaced by ' . $pages[$key]['display_name'];
                    $pages[$key]['extension']['replaces'] = $replaces;
                }
            }
        }
        self::$notes = $notes;
        return self::$pages = $pages;
    }

    /** @return array<string,mixed> the page's meta, [] when there is no such page */
    public static function meta(string $key): array
    {
        return self::owns($key) ? (self::all()[$key] ?? []) : [];
    }

    /**
     * What extensions have to say about a THEME page, for its row in Pages:
     * for example that a built page is standing in for the homepage.
     *
     * @return list<string>
     */
    public static function notesFor(string $themePage): array
    {
        if (self::$notes === null) {
            self::all();
        }
        return self::$notes[$themePage] ?? [];
    }

    /**
     * The key of the extension page a request is drawing, or null.
     *
     * A module draws its page through the theme's module-page template and
     * names it in the `modulePage` template variable (`pageKey`). Only a key
     * that a registered module's provider actually reports is accepted, so a
     * template variable cannot point the theme at another page's settings.
     *
     * @param array<string,mixed> $vars the ClientAreaPage hook's variables
     */
    public static function keyFor(array $vars): ?string
    {
        if (($vars['templatefile'] ?? '') !== self::TEMPLATE || !is_array($vars['modulePage'] ?? null)) {
            return null;
        }
        $key = $vars['modulePage']['pageKey'] ?? null;
        return is_string($key) && self::owns($key) && isset(self::all()[$key]) ? $key : null;
    }

    /**
     * Ask the providers again on the next read. For a module that has just
     * changed one of its pages and wants the registry brought up to date in
     * the same request.
     */
    public static function refresh(): void
    {
        self::$pages = null;
        self::$notes = null;
    }

    /** Forget what was registered and listed. For tests. */
    public static function reset(): void
    {
        self::$modules = [];
        self::$pages   = null;
        self::$notes   = null;
    }

    /**
     * A link into the admin, or ''. Same rule as an extension's nav link: a
     * query string for addonmodules.php, nothing that could lead off-site.
     */
    private static function adminUrl(string $url): string
    {
        return preg_match('/^\?module=[A-Za-z0-9_]+(&[A-Za-z0-9_=&%.-]*)?$/', $url) ? $url : '';
    }

    /** A path from the site root, or '' when it is not shaped like one. */
    private static function path(string $url): string
    {
        $url = ltrim(trim($url), '/');
        return preg_match('#^[A-Za-z0-9][A-Za-z0-9/_.-]{0,159}$#', $url) && !str_contains($url, '..') ? $url : '';
    }

    private static function cut(string $s, int $n): string
    {
        return function_exists('mb_substr') ? mb_substr($s, 0, $n) : substr($s, 0, $n);
    }
}
