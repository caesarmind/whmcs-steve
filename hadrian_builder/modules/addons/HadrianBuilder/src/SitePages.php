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
 *   - headerPanel() the "Website served by" switch, in the screen's header
 *   - groupPanel()  export and import, shown above the list of built pages
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
            $target    = $replaces !== '' ? Replace::TARGETS[$replaces] : '';
            [$status, $tone] = match (true) {
                !$published => ['Draft', 'warning'],
                $serving    => ['Serving as ' . $target, 'primary'],
                $replaces !== '' => ['Standby for ' . $target, 'neutral'],
                default     => ['Published', 'success'],
            };

            $rows[] = [
                'id'          => (int)$page['id'],
                'name'        => (string)$page['name'],
                'description' => ($slug !== '' ? '/' . $slug : 'No address yet')
                    . ($replaces !== '' ? ' - replaces ' . Replace::TARGETS[$replaces] . ($serving ? '' : ' (standby)') : ''),
                'url'         => $slug,
                // Visitors can reach it: this is what puts it in the sitemap.
                'live'        => $published && $slug !== '',
                'status'      => $status,
                'tone'        => $tone,
                'editUrl'     => AdminController::BASE . '&action=edit&id=' . (int)$page['id'],
                // The description typed in the builder is the fallback; one
                // set in Pages wins. No title is offered: Hadrian would print
                // it as the whole <title>, and the page's own title already
                // reaches WHMCS, which adds the company name.
                'seoDescription' => Text::pick($meta['description'], $lang),
                'replaces'    => $serving ? $replaces : '',
                // Set to stand in for a theme page, but not doing so now.
                'standby'     => $serving ? '' : $replaces,
            ];
        }
        return $rows;
    }

    /**
     * In the header of Pages: which version of the site visitors get. It
     * changes the live site at once, so a click asks first and lists the
     * theme pages that would change. Without script the buttons just post.
     *
     * Only built pages on the "Follow site" rule move with the switch: one on
     * "Always" serves either way, one on "Never" never does.
     */
    public static function headerPanel(): string
    {
        $mode      = Replace::mode();
        $onBuilder = $mode === Replace::MODE_BUILDER;
        $serving   = 0;
        $follows   = [];
        foreach (Page::forSite() as $page) {
            $replaces = (string)($page['replaces'] ?? '');
            if (!Replace::isTarget($replaces) || (string)$page['status'] !== 'published') {
                continue;
            }
            $rule = Replace::rule((string)($page['replace_rule'] ?? ''));
            $serving += Replace::serves($mode, $rule, 'published') ? 1 : 0;
            if ($rule === 'follow') {
                $follows[] = ['target' => Replace::TARGETS[$replaces], 'name' => (string)$page['name']];
            }
        }
        $n   = count($follows);
        $sub = match (true) {
            $onBuilder && $serving > 0 => $serving . ($serving === 1 ? ' theme page shows its' : ' theme pages show their') . ' built version',
            $onBuilder                 => 'No built page replaces a theme page yet',
            $n > 0                     => $n . ($n === 1 ? ' built page is' : ' built pages are') . ' ready to take over',
            default                    => 'No built page replaces a theme page yet',
        };

        $button = static fn (string $value, string $label, bool $on): string =>
            '<button type="submit" name="mode" value="' . $value . '"' . ($on ? ' class="is-on"' : '')
            . ' aria-pressed="' . ($on ? 'true' : 'false') . '">' . $label . '</button>';

        // What each direction changes, for the dialog. Rendered here so the
        // script only has to pick one list.
        $list = static function (bool $toBuilder) use ($follows): string {
            $out = '';
            foreach ($follows as $f) {
                $out .= '<li><span>' . self::e($f['target']) . '</span><span>'
                    . ($toBuilder ? 'now shows ' . self::e($f['name']) : 'back to the theme\'s page') . '</span></li>';
            }
            return $out;
        };
        $none = 'No built page replaces a theme page yet, so visitors see no difference until you give one a page to replace.';

        return self::STYLE
            . '<div class="mt-pb-served" id="pb-site">'
            . '<div class="mt-pb-served-text"><span class="mt-pb-served-title">Website served by</span>'
            . '<span class="mt-pb-served-sub" data-pb-served-sub>' . self::e($sub) . '</span></div>'
            . '<form method="post" action="' . self::e(AdminController::BASE . '&action=mode') . '" class="mt-pb-seg" role="group" aria-label="Website served by" data-pb-served>'
            . self::token()
            . $button(Replace::MODE_THEME, 'Theme', !$onBuilder)
            . $button(Replace::MODE_BUILDER, 'Page Builder', $onBuilder)
            . '</form>'
            . '</div>'
            . '<dialog class="mt-pb-dialog" id="pb-served-confirm" aria-labelledby="pb-served-title">'
            . '<div class="mt-pb-dialog-body">'
            . '<h2 id="pb-served-title" data-title-builder="Serve the website with Page Builder?" data-title-theme="Serve the website with the theme?"></h2>'
            . '<p data-pb-served-text'
            . ' data-text-builder="' . self::e($n ? 'Visitors get the built version of these pages right away. Every other page keeps the theme.' : $none) . '"'
            . ' data-text-theme="' . self::e($n ? 'These pages go back to the theme\'s version right away.' : $none) . '"></p>'
            . '<ul class="mt-pb-effect" data-list="builder" hidden>' . $list(true) . '</ul>'
            . '<ul class="mt-pb-effect" data-list="theme" hidden>' . $list(false) . '</ul>'
            . '<p class="mt-pb-dialog-note">Built pages keep their own addresses either way, and you can switch back at any time.</p>'
            . '<div class="mt-pb-dialog-foot">'
            . '<button type="button" class="mt-btn mt-btn-secondary mt-btn-sm" data-pb-served-cancel>Cancel</button>'
            . '<button type="button" class="mt-btn mt-btn-primary mt-btn-sm" data-pb-served-go'
            . ' data-label-builder="Switch to Page Builder" data-label-theme="Switch to the theme"></button>'
            . '</div></div></dialog>'
            . self::SERVED_SCRIPT;
    }

    /**
     * Above the list while it shows only built pages: moving pages between
     * sites.
     */
    public static function groupPanel(): string
    {
        return self::STYLE . self::movePanel(count(Page::all()));
    }

    /**
     * The confirm step for the switch. A click on the side that is not on
     * opens the dialog; confirming posts the form with that side. The choice
     * is applied from the button's own click, not from the dialog's close
     * event, which arrives a task later.
     */
    private const SERVED_SCRIPT = '<script>(function(){'
        . 'var f=document.querySelector("[data-pb-served]"),d=document.getElementById("pb-served-confirm");'
        . 'if(!f||!d||typeof d.showModal!=="function")return;'
        . 'var go=d.querySelector("[data-pb-served-go]");'
        . 'f.addEventListener("click",function(e){var b=e.target.closest("button[name=mode]");'
        . 'if(!b||b.classList.contains("is-on")){if(b)e.preventDefault();return;}'
        . 'e.preventDefault();var m=b.value;d.dataset.pending=m;'
        . 'd.querySelector("h2").textContent=d.querySelector("h2").getAttribute("data-title-"+m);'
        . 'var t=d.querySelector("[data-pb-served-text]");t.textContent=t.getAttribute("data-text-"+m);'
        . 'Array.prototype.forEach.call(d.querySelectorAll("[data-list]"),function(u){u.hidden=u.getAttribute("data-list")!==m||!u.children.length;});'
        . 'go.textContent=go.getAttribute("data-label-"+m);d.showModal();});'
        . 'd.querySelector("[data-pb-served-cancel]").addEventListener("click",function(){d.close();});'
        . 'go.addEventListener("click",function(){var i=document.createElement("input");i.type="hidden";i.name="mode";i.value=d.dataset.pending;'
        . 'f.appendChild(i);go.disabled=true;f.submit();});'
        . '})();</script>';

    /**
     * Under the site switch: take every built page out as one file, or bring
     * the pages of a file in. Choosing a file sends it at once; what it holds
     * is shown for review before anything is imported (AdminController).
     */
    private static function movePanel(int $pages): string
    {
        return '<div class="mt-pb-site" id="pb-move">'
            . '<div class="mt-pb-site-text">'
            . '<div class="mt-pb-site-title">Move pages between sites</div>'
            . '<div class="mt-pb-site-sub">Export saves your built pages and the images they use as one file. '
            . 'Import reads such a file and shows you what is in it before it adds anything; imported pages arrive as drafts.</div>'
            . '</div>'
            . '<div class="mt-pb-move">'
            . '<form method="post" action="' . self::e(AdminController::BASE . '&action=export') . '">'
            . self::token() . '<input type="hidden" name="all" value="1">'
            . '<button type="submit" class="mt-btn mt-btn-secondary mt-btn-sm" data-pb-export-all' . ($pages < 1 ? ' disabled' : '') . '>Export all</button>'
            . '</form>'
            . '<form method="post" enctype="multipart/form-data" action="' . self::e(AdminController::BASE . '&action=import') . '">'
            . self::token()
            . '<input type="file" name="file" id="pb-import-file" class="mt-pb-file" accept=".zip,.json,application/zip,application/json"'
            . ' aria-label="Pages file to import" onchange="if(this.files.length){this.form.submit()}">'
            . '<button type="button" class="mt-btn mt-btn-secondary mt-btn-sm" data-pb-import'
            . ' onclick="document.getElementById(\'pb-import-file\').click()">Import</button>'
            . '</form>'
            . '</div>'
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
            . '<div><div class="mt-row-label">Copy or export</div>'
            . '<div class="mt-row-help"><strong>Duplicate</strong> makes a second page with the same sections, as a draft. '
            . '<strong>Export</strong> saves this page and its images as a file you can import on another site.</div></div>'
            . '<div class="mt-pb-move">'
            . '<form method="post" action="' . self::e(AdminController::BASE . '&action=duplicate') . '">'
            . self::token() . '<input type="hidden" name="id" value="' . $id . '">'
            . '<button type="submit" class="mt-btn mt-btn-secondary mt-btn-sm" data-pb-duplicate>Duplicate</button>'
            . '</form>'
            . '<form method="post" action="' . self::e(AdminController::BASE . '&action=export') . '">'
            . self::token() . '<input type="hidden" name="id" value="' . $id . '">'
            . '<button type="submit" class="mt-btn mt-btn-secondary mt-btn-sm" data-pb-export>Export</button>'
            . '</form>'
            . '</div>'
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
        . '.mt-pb-site + .mt-pb-site{padding-top:18px}'
        . '.mt-pb-served{display:flex;align-items:center;gap:12px;padding:6px 6px 6px 16px;background:var(--mt-surface);border:1px solid var(--mt-border);border-radius:999px}'
        . '.mt-pb-served-text{display:flex;flex-direction:column;line-height:1.25;min-width:0}'
        . '.mt-pb-served-title{font-size:13px;font-weight:600;color:var(--mt-text)}'
        . '.mt-pb-served-sub{font-size:11.5px;color:var(--mt-text-3)}'
        . '.mt-pb-served .mt-pb-seg button.is-on{background:var(--mt-primary);color:#fff;box-shadow:none}'
        . '.mt-pb-dialog{border:0;border-radius:18px;padding:0;width:min(460px,92vw);background:var(--mt-surface);color:var(--mt-text);box-shadow:var(--mt-shadow-lg,0 20px 60px rgba(0,0,0,.25))}'
        . '.mt-pb-dialog::backdrop{background:rgba(0,0,0,.35)}'
        . '.mt-pb-dialog-body{padding:24px}'
        . '.mt-pb-dialog h2{margin:0 0 6px;font-size:20px;font-weight:600}'
        . '.mt-pb-dialog p{margin:0 0 16px;font-size:13.5px;line-height:1.5;color:var(--mt-text-2)}'
        . '.mt-pb-dialog .mt-pb-dialog-note{margin:12px 0 0;font-size:12.5px;color:var(--mt-text-3)}'
        . '.mt-pb-effect{list-style:none;margin:0;padding:0;border:1px solid var(--mt-border);border-radius:12px}'
        . '.mt-pb-effect[hidden]{display:none}'
        . '.mt-pb-effect li{display:flex;justify-content:space-between;gap:12px;padding:10px 14px;font-size:13.5px;border-bottom:1px solid var(--mt-border)}'
        . '.mt-pb-effect li:last-child{border-bottom:0}'
        . '.mt-pb-effect li span:last-child{color:var(--mt-text-3);text-align:right}'
        . '.mt-pb-dialog-foot{display:flex;justify-content:flex-end;gap:8px;margin-top:18px}'
        . '.mt-pb-move{display:flex;gap:8px;flex:none}'
        . '.mt-pb-move form{margin:0}'
        . '.mt-pb-file{position:absolute;width:1px;height:1px;opacity:0;pointer-events:none}'
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
