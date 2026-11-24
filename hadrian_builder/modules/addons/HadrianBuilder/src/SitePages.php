<?php
declare(strict_types=1);

namespace HadrianBuilder;

/**
 * Built pages, inside Hadrian's Pages screen.
 *
 * Hadrian lists every page of the site in one place and gives each the same
 * settings: SEO, indexing, visibility, area, a layout of its own. This module
 * has no list screen of its own. It reports its pages to Hadrian (through
 * Bridge::registerPages), where they sit on a "Built" tab beside the theme's
 * pages, and it hands Hadrian the few controls only it understands:
 *
 *   - rows()        one entry per built page, for the list
 *   - groupPanel()  the "Website served by" switch, shown above the list
 *   - pagePanel()   what a built page replaces, and its delete button, shown
 *                   on that page's editor
 *
 * The forms in those panels post to this module's own actions
 * (AdminController), which answer by sending the admin back to Pages.
 *
 * What stays in this module is what only it knows: the sections on a page
 * (the editor), its address, whether it is published.
 *
 * A built page is known to Hadrian by a key made from its id ("built-12"),
 * which does not change when the page is renamed or moved.
 */
final class SitePages
{
    /** Key prefix. Hadrian accepts 2-12 lowercase letters. */
    public const PREFIX = 'built';

    /** The tab built pages are listed under in Pages (shown as "Built pages"). */
    public const GROUP = 'Built';

    public static function key(int $id): string
    {
        return self::PREFIX . '-' . $id;
    }

    /** Hadrian's Pages screen, on the Built tab. */
    public static function listUrl(string $query = ''): string
    {
        return '?module=Hadrian&action=pages' . $query . '#tab=' . rawurlencode(self::GROUP);
    }

    /** Where Hadrian's Pages screen edits one built page's settings. */
    public static function settingsUrl(int $id, string $query = ''): string
    {
        return '?module=Hadrian&action=pages&sub=edit&page=' . self::key($id) . $query;
    }

    /**
     * One entry per built page, in the shape Hadrian's ExtensionPages asks
     * for. Called by Hadrian when it needs the list: on its Pages screen,
     * when the sitemap rows are brought up to date, and when a built page is
     * being drawn.
     *
     * @return list<array<string,mixed>>
     */
    public static function rows(): array
    {
        $mode = Replace::mode();
        $lang = self::language();
        $rows = [];
        foreach (Page::forSite() as $page) {
            $slug      = (string)$page['slug'];
            $published = (string)$page['status'] === 'published';
            $replaces  = Replace::isTarget((string)($page['replaces'] ?? '')) ? (string)$page['replaces'] : '';
            $serving   = $replaces !== '' && Replace::serves($mode, (string)($page['replace_rule'] ?? ''), (string)$page['status']);
            $meta      = Document::normalizeMeta((array)($page['meta'] ?? []));

            $rows[] = [
                'id'          => (int)$page['id'],
                'name'        => (string)$page['name'],
                'description' => ($slug !== '' ? '/' . $slug : 'No address yet')
                    . ($replaces !== '' ? ' - replaces ' . Replace::TARGETS[$replaces] . ($serving ? '' : ' (standby)') : ''),
                'url'         => $slug,
                // Visitors can reach it: this is what puts it in the sitemap.
                'live'        => $published && $slug !== '',
                'status'      => !$published ? 'Draft' : ($serving ? 'Serving' : 'Published'),
                'editUrl'     => AdminController::BASE . '&action=edit&id=' . (int)$page['id'],
                // The description typed in the builder is the fallback; one
                // set in Pages wins. No title is offered: Hadrian would print
                // it as the whole <title>, and the page's own title already
                // reaches WHMCS, which adds the company name.
                'seoDescription' => Text::pick($meta['description'], $lang),
                'replaces'    => $serving ? $replaces : '',
            ];
        }
        return $rows;
    }

    /**
     * Above the list of built pages: which version of the site visitors get.
     * Only theme pages that have a built replacement change with it.
     */
    public static function groupPanel(): string
    {
        $mode    = Replace::mode();
        $serving = 0;
        foreach (Page::forSite() as $page) {
            $serving += Replace::isTarget((string)($page['replaces'] ?? ''))
                && Replace::serves($mode, (string)($page['replace_rule'] ?? ''), (string)$page['status']) ? 1 : 0;
        }
        $onBuilder = $mode === Replace::MODE_BUILDER;
        $sub = $onBuilder
            ? 'Theme pages that have a built replacement show it. Every other page keeps the theme.'
            : 'Every website page uses the theme. Built replacements are kept, so switching is instant either way.';
        if ($serving > 0) {
            $sub .= ' <strong>' . $serving . '</strong> built ' . ($serving === 1 ? 'page is' : 'pages are') . ' replacing a theme page now.';
        }
        $button = static fn (string $value, string $label, bool $on): string =>
            '<button type="submit" name="mode" value="' . $value . '"' . ($on ? ' class="is-on"' : '')
            . ' aria-pressed="' . ($on ? 'true' : 'false') . '">' . $label . '</button>';

        return self::STYLE
            . '<div class="mt-pb-site" id="pb-site">'
            . '<div class="mt-pb-site-text">'
            . '<div class="mt-pb-site-title">Website served by</div>'
            . '<div class="mt-pb-site-sub">' . $sub . '</div>'
            . '</div>'
            . '<form method="post" action="' . self::e(AdminController::BASE . '&action=mode') . '" class="mt-pb-seg" role="group" aria-label="Website served by">'
            . self::token()
            . $button(Replace::MODE_THEME, 'Theme', !$onBuilder)
            . $button(Replace::MODE_BUILDER, 'Page Builder', $onBuilder)
            . '</form>'
            . '</div>';
    }

    /**
     * On a built page's editor in Pages: the theme page it stands in for,
     * and its delete button. '' when the page is gone.
     */
    public static function pagePanel(int $id): string
    {
        $page = Page::find($id);
        if ($page === null) {
            return '';
        }
        $replaces  = Replace::isTarget((string)($page['replaces'] ?? '')) ? (string)$page['replaces'] : '';
        $rule      = Replace::rule((string)($page['replace_rule'] ?? ''));
        $published = (string)$page['status'] === 'published';
        $serving   = $replaces !== '' && Replace::serves(Replace::mode(), $rule, (string)$page['status']);

        $targets = '<option value="">Nothing</option>';
        foreach (Replace::TARGETS as $key => $label) {
            $targets .= '<option value="' . self::e($key) . '"' . ($key === $replaces ? ' selected' : '') . '>' . self::e($label) . '</option>';
        }
        $rules = '';
        if ($replaces !== '') {
            $rules = '<select class="mt-select" name="replace_rule" aria-label="When it replaces" onchange="this.form.submit()">';
            foreach (['follow' => 'Follow site', 'always' => 'Always', 'never' => 'Never'] as $key => $label) {
                $rules .= '<option value="' . $key . '"' . ($key === $rule ? ' selected' : '') . '>' . $label . '</option>';
            }
            $rules .= '</select>';
        }
        $state = match (true) {
            $replaces === '' => '',
            !$published      => '<span class="mt-badge mt-badge-warning" data-pb-state>Draft: not replacing yet</span>',
            $serving         => '<span class="mt-badge mt-badge-primary" data-pb-state>Serving</span>',
            default          => '<span class="mt-badge mt-badge-neutral" data-pb-state>Standby</span>',
        };

        return self::STYLE
            . '<div class="mt-row">'
            . '<div><div class="mt-row-label">Replaces ' . $state . '</div>'
            . '<div class="mt-row-help">Let this page stand in for one of the theme\'s website pages. <strong>Follow site</strong> uses it while the website is served by Page Builder, <strong>Always</strong> uses it whatever the site says, and <strong>Never</strong> keeps it on standby. The theme\'s own page is never touched.</div></div>'
            . '<form method="post" action="' . self::e(AdminController::BASE . '&action=replace') . '" class="mt-pb-replace">'
            . self::token() . '<input type="hidden" name="id" value="' . $id . '">'
            . '<select class="mt-select" name="replaces" aria-label="Theme page this replaces" onchange="this.form.submit()">' . $targets . '</select>'
            . $rules
            . '</form>'
            . '</div>'
            . '<div class="mt-row">'
            . '<div><div class="mt-row-label">Delete this page</div>'
            . '<div class="mt-row-help">Removes the page, its sections and its settings. This cannot be undone.</div></div>'
            . '<form method="post" action="' . self::e(AdminController::BASE . '&action=delete') . '" onsubmit="return confirm(\'Delete this page? This cannot be undone.\');">'
            . self::token() . '<input type="hidden" name="id" value="' . $id . '">'
            . '<button type="submit" class="mt-btn mt-btn-ghost mt-btn-sm" data-pb-delete>Delete page</button>'
            . '</form>'
            . '</div>';
    }

    /**
     * Styles for the two panels. Prefixed mt-pb- so nothing here can collide
     * with a name in Hadrian's admin stylesheet; its shared classes (mt-row,
     * mt-select, mt-btn, mt-badge) are used as they are.
     */
    private const STYLE = '<style>'
        . '.mt-pb-site{display:flex;align-items:center;gap:18px;flex-wrap:wrap;padding:4px 0 18px;margin-bottom:6px;border-bottom:1px solid var(--mt-border)}'
        . '.mt-pb-site-text{flex:1;min-width:240px}'
        . '.mt-pb-site-title{font-size:15px;font-weight:600;color:var(--mt-text)}'
        . '.mt-pb-site-sub{font-size:12.5px;color:var(--mt-text-3);margin-top:3px}'
        . '.mt-pb-seg{display:inline-flex;gap:2px;padding:3px;margin:0;background:var(--mt-surface-2);border:1px solid var(--mt-border);border-radius:999px}'
        . '.mt-pb-seg button{border:0;background:none;padding:6px 16px;border-radius:999px;font:inherit;font-size:13px;font-weight:600;color:var(--mt-text-2);cursor:pointer}'
        . '.mt-pb-seg button.is-on{background:var(--mt-surface);color:var(--mt-text);box-shadow:0 1px 2px rgba(0,0,0,.08),0 0 0 1px var(--mt-border)}'
        . '.mt-pb-replace{display:flex;gap:6px;margin:0;flex:none}'
        . '.mt-pb-replace .mt-select{width:auto;min-width:150px;padding-top:8px;padding-bottom:8px;font-size:13px}'
        . '</style>';

    private static function token(): string
    {
        return '<input type="hidden" name="token" value="' . self::e(AdminController::adminToken()) . '">';
    }

    private static function e(string $s): string
    {
        return htmlspecialchars($s, ENT_QUOTES, 'UTF-8');
    }

    private static function language(): string
    {
        $session = $_SESSION['Language'] ?? null;
        return is_string($session) && $session !== '' ? strtolower($session) : Bridge::defaultLanguage();
    }
}
