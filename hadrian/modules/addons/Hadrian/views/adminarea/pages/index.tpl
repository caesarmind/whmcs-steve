{include file="includes/header.tpl"}

{* Pages: every page of the site in one list.

   Left, a rail that narrows the list: by area (Website, Client area, Order
   process), or to the pages an admin changed, the pages that offer more than
   one template, and the pages a module such as the Page Builder made. Right,
   one table, one line per page: its name, its address, what was changed, and
   the buttons that open it.

   The server renders every row once, sorted by name. The script below only
   shows, hides and regroups them, so the list works (flat, unfiltered)
   without it. *}

{assign var=createGroups value=[]}
{foreach $extensionGroups as $g => $ext}{if $ext.createUrl}{$createGroups[$g] = $ext}{/if}{/foreach}

<header class="mt-page-header mt-pl-head">
    <div>
        <div class="mt-page-eyebrow">Theme</div>
        <h1 class="mt-page-title">Pages {include file="includes/doclink.tpl" article="page-manager"}</h1>
        <p class="mt-page-subtitle">Every page on your site. Choose one to change its template, its SEO, who can see it, and its layout.</p>
    </div>
    <div class="mt-pl-head-right">
        {* A module's control for the whole site ("Website served by"),
           rendered by the module (Helpers\ExtensionPages, "headerPanel"). *}
        {foreach $extensionGroups as $g => $ext}
            {if $ext.headerHtml}<div class="mt-pl-head-ext" data-header-extension>{$ext.headerHtml nofilter}</div>{/if}
        {/foreach}
        {foreach $createGroups as $g => $ext}
            <button type="button" class="mt-btn mt-btn-primary" data-add-page="{$ext@index}">
                <svg width="14" height="14" viewBox="0 0 16 16" fill="none" aria-hidden="true"><path d="M8 3v10M3 8h10" stroke="currentColor" stroke-width="1.8" stroke-linecap="round"/></svg>
                Add page{if $createGroups|count > 1} in {$ext.label|escape}{/if}
            </button>
        {/foreach}
    </div>
</header>

{if $extOk|default:''}<div class="mt-alert mt-alert-success" data-ext-flash>{$extOk|escape}</div>{/if}
{if $extErr|default:''}<div class="mt-alert mt-alert-danger" data-ext-flash>{$extErr|escape}</div>{/if}
{if $flashMsg == 'saved'}
    <div class="mt-alert mt-alert-success mt-alert-lead">
        <span class="mt-alert-icon" aria-hidden="true"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"><path d="M5 12l5 5L20 7"/></svg></span>
        <span>Page settings saved.</span>
    </div>
{/if}

{literal}
<style>
/* Page-local: every name here starts .mt-pl- so nothing collides with the
   shared admin stylesheet. */
.mt-pl-head { display:flex; align-items:flex-end; justify-content:space-between; gap:24px; flex-wrap:wrap; }
.mt-pl-head .mt-page-subtitle { max-width:480px; }
.mt-pl-head-right { display:flex; align-items:center; gap:16px; flex-wrap:wrap; margin-left:auto; justify-content:flex-end; }

.mt-pl-layout { display:grid; grid-template-columns:220px minmax(0,1fr); gap:24px; align-items:start; }

/* Rail */
.mt-pl-rail { position:sticky; top:16px; padding:10px; }
.mt-pl-rail-label { font-size:11px; font-weight:600; letter-spacing:.05em; text-transform:uppercase; color:var(--mt-text-3); padding:12px 10px 6px; }
.mt-pl-rail-btn { display:flex; align-items:center; justify-content:space-between; gap:8px; width:100%; border:0; background:none; padding:9px 10px; border-radius:8px; font:inherit; font-size:14px; color:var(--mt-text); cursor:pointer; text-align:left; }
.mt-pl-rail-btn:hover { background:var(--mt-surface-2); }
.mt-pl-rail-btn:focus-visible { outline:2px solid var(--mt-primary); outline-offset:-2px; }
.mt-pl-rail-btn.is-on { background:var(--mt-primary-tint); color:var(--mt-primary); font-weight:600; }
.mt-pl-rail-btn .n { font-size:12px; color:var(--mt-text-3); font-weight:500; }
.mt-pl-rail-btn.is-on .n { color:var(--mt-primary); }
.mt-pl-rail-help { font-size:11.5px; line-height:1.45; color:var(--mt-text-3); padding:2px 10px 8px; margin:0; }
.mt-pl-rail-help[hidden] { display:none; }
.mt-pl-rail hr { border:0; border-top:1px solid var(--mt-border); margin:8px 4px; }
.mt-pl-sys { display:flex; align-items:center; justify-content:space-between; gap:10px; padding:10px; font-size:13px; color:var(--mt-text-2); cursor:pointer; }
.mt-pl-sys .n { color:var(--mt-text-4); }

/* Toolbar */
.mt-pl-panel { padding:0; overflow:hidden; }
.mt-pl-tools { display:flex; align-items:center; gap:12px; padding:14px 16px; border-bottom:1px solid var(--mt-border); }
.mt-pl-tools .mt-search { flex:1; max-width:420px; }
.mt-pl-tools .mt-input { padding-top:9px; padding-bottom:9px; padding-right:34px; font-size:14px; }
.mt-pl-tools input[type="search"]::-webkit-search-cancel-button { -webkit-appearance:none; appearance:none; }
.mt-pl-clear { position:absolute; right:8px; top:50%; transform:translateY(-50%); display:flex; align-items:center; justify-content:center; width:22px; height:22px; padding:0; border:0; border-radius:50%; background:transparent; color:var(--mt-text-3); font-size:12px; cursor:pointer; }
.mt-pl-clear:hover { background:var(--mt-neutral-tint); color:var(--mt-text); }
.mt-pl-clear[hidden] { display:none; }
.mt-pl-count { margin-left:auto; font-size:13px; color:var(--mt-text-3); white-space:nowrap; }

/* A module's own controls, shown while the list shows its pages. */
.mt-pl-extpanel { padding:16px 16px 0; border-bottom:1px solid var(--mt-border); background:var(--mt-surface-2); }
.mt-pl-extpanel[hidden] { display:none; }

/* Table */
.mt-pl-table { width:100%; border-collapse:collapse; table-layout:fixed; }
.mt-pl-table col.c-page { width:30%; }
.mt-pl-table col.c-addr { width:22%; }
.mt-pl-table col.c-act { width:220px; }
.mt-pl-table th { text-align:left; font-size:11px; font-weight:600; letter-spacing:.05em; text-transform:uppercase; color:var(--mt-text-3); padding:9px 16px; background:var(--mt-surface-2); border-bottom:1px solid var(--mt-border); }
.mt-pl-table td { padding:8px 16px; height:46px; border-bottom:1px solid var(--mt-border); font-size:14px; vertical-align:middle; }
.mt-pl-table tbody tr:last-child td { border-bottom:0; }
.mt-pl-row { cursor:pointer; }
.mt-pl-row:hover td { background:var(--mt-surface-3); }
.mt-pl-row[hidden], .mt-pl-grp[hidden] { display:none; }
.mt-pl-grp td { height:auto; padding:18px 16px 6px; font-size:12px; font-weight:600; color:var(--mt-text-2); cursor:default; }
.mt-pl-grp .n { color:var(--mt-text-4); font-weight:500; margin-left:6px; }
.mt-pl-name { display:flex; align-items:center; gap:8px; min-width:0; }
.mt-pl-name a { font-weight:500; color:var(--mt-text); text-decoration:none; overflow:hidden; text-overflow:ellipsis; white-space:nowrap; min-width:0; }
.mt-pl-name a:hover { color:var(--mt-text); text-decoration:none; }
.mt-pl-name a:focus-visible { outline:2px solid var(--mt-primary); outline-offset:2px; border-radius:4px; }
.mt-pl-row.is-system .mt-pl-name a { color:var(--mt-text-2); }
.mt-pl-built { flex:none; font-size:10.5px; font-weight:600; letter-spacing:.04em; text-transform:uppercase; color:var(--mt-primary); background:var(--mt-primary-tint); border-radius:5px; padding:2px 6px; }
.mt-pl-info { flex:none; display:inline-flex; color:var(--mt-text-4); cursor:help; }
.mt-pl-info svg { width:15px; height:15px; display:block; }
.mt-pl-addr { display:block; font-family:ui-monospace,SFMono-Regular,Menlo,Consolas,monospace; font-size:12.5px; color:var(--mt-text-3); white-space:nowrap; overflow:hidden; text-overflow:ellipsis; }
.mt-pl-addr a { color:inherit; text-decoration:none; }
.mt-pl-addr a:hover { color:var(--mt-link); text-decoration:underline; }
.mt-pl-none { color:var(--mt-text-4); font-size:13px; cursor:help; }
.mt-pl-badges { display:flex; gap:6px; flex-wrap:wrap; align-items:center; }
.mt-pl-badges .mt-badge { font-size:11.5px; padding:2px 9px; }
.mt-pl-badges [hidden] { display:none; }
.mt-pl-act { text-align:right; white-space:nowrap; }
.mt-pl-act .mt-btn { padding:6px 14px; font-size:13px; }
.mt-pl-act .mt-btn + .mt-btn { margin-left:6px; }

.mt-pl-sr { position:absolute; width:1px; height:1px; overflow:hidden; clip:rect(0 0 0 0); white-space:nowrap; }
.mt-pl-empty { padding:56px 24px; text-align:center; color:var(--mt-text-3); font-size:14px; }
.mt-pl-empty strong { display:block; color:var(--mt-text); font-size:16px; font-weight:600; margin-bottom:6px; }
.mt-pl-empty[hidden] { display:none; }

/* Add page */
.mt-pl-dialog { border:0; border-radius:18px; padding:0; width:min(440px,92vw); box-shadow:var(--mt-shadow-lg, 0 20px 60px rgba(0,0,0,.25)); background:var(--mt-surface); color:var(--mt-text); }
.mt-pl-dialog::backdrop { background:rgba(0,0,0,.35); }
.mt-pl-dialog form { padding:24px; margin:0; }
.mt-pl-dialog h2 { margin:0 0 6px; font-size:20px; font-weight:600; }
.mt-pl-dialog p { margin:0 0 16px; font-size:13.5px; color:var(--mt-text-2); line-height:1.5; }
.mt-pl-dialog-foot { display:flex; justify-content:flex-end; gap:8px; margin-top:18px; }

/* WHMCS's admin sets no mobile viewport, so a phone draws this screen about
   980px wide: the narrow layout has to start above that, not at 900. */
@media (max-width: 1100px) {
    .mt-pl-layout { grid-template-columns:1fr; }
    .mt-pl-rail { position:static; display:flex; flex-wrap:wrap; gap:4px; }
    .mt-pl-rail-btn { width:auto; }
    .mt-pl-rail-label, .mt-pl-rail-help, .mt-pl-rail hr { display:none; }
    .mt-pl-sys { padding:9px 10px; }
    .mt-pl-head-right { margin-left:0; justify-content:flex-start; }
}
@media (max-width: 760px) {
    .mt-pl-col-addr { display:none; }
    .mt-pl-table col.c-page { width:auto; }
    .mt-pl-table col.c-act { width:104px; }
    .mt-pl-act [data-page-content] { display:none; }
}
</style>
{/literal}

<div class="mt-pl-layout">
    <aside class="mt-panel mt-pl-rail" aria-label="Filter pages" id="mt-pl-rail">
        <div class="mt-pl-rail-label">Area</div>
        <button type="button" class="mt-pl-rail-btn is-on" data-view="all" aria-pressed="true">All pages <span class="n" data-count-for="all">{$totalCount}</span></button>
        {foreach $areas as $areaKey => $areaLabel}
            <button type="button" class="mt-pl-rail-btn" data-view="{$areaKey|escape}" aria-pressed="false">{$areaLabel|escape} <span class="n" data-count-for="{$areaKey|escape}">{$areaCounts[$areaKey]}</span></button>
            <p class="mt-pl-rail-help" data-help-for="{$areaKey|escape}" hidden>{$areaHelp[$areaKey]|escape}.</p>
        {/foreach}
        <hr>
        <div class="mt-pl-rail-label">Show</div>
        <button type="button" class="mt-pl-rail-btn" data-view="changed" aria-pressed="false">Changed by you <span class="n" data-count-for="changed"></span></button>
        <p class="mt-pl-rail-help" data-help-for="changed" hidden>Pages where you set a template, SEO, visibility, indexing, an area or a layout of their own.</p>
        <button type="button" class="mt-pl-rail-btn" data-view="templates" aria-pressed="false">With templates <span class="n" data-count-for="templates"></span></button>
        <p class="mt-pl-rail-help" data-help-for="templates" hidden>Pages that offer more than one template to choose from.</p>
        {foreach $extensionGroups as $g => $ext}
            <button type="button" class="mt-pl-rail-btn" data-view="ext-{$ext@index}" data-ext-group="{$g|escape}" aria-pressed="false">Built with {$ext.label|escape} <span class="n" data-count-for="ext-{$ext@index}"></span></button>
        {/foreach}
        {if $systemCount > 0}
            <hr>
            <label class="mt-pl-sys">
                <span>System pages <span class="n">{$systemCount}</span></span>
                <span class="mt-toggle"><input type="checkbox" id="mt-pages-showsys"><span class="mt-toggle-track"><span class="mt-toggle-thumb"></span></span></span>
            </label>
            {* Hidden by default because an admin never navigates to them.
               FILTERED, not dropped: some (the 2FA challenge, the upgrade
               summary) are pages a visitor really sees, and an admin may
               want a layout override or a noindex on one. *}
            <p class="mt-pl-rail-help">Error pages, wizard steps and parts of other pages. Visitors only reach them mid-flow.</p>
        {/if}
    </aside>

    <section class="mt-panel mt-pl-panel">
        <div class="mt-pl-tools">
            <label class="mt-search">
                <span class="mt-search-icon" aria-hidden="true"><svg viewBox="0 0 16 16" fill="none"><circle cx="7" cy="7" r="5" stroke="currentColor" stroke-width="1.6"/><path d="M11 11l3 3" stroke="currentColor" stroke-width="1.6" stroke-linecap="round"/></svg></span>
                <input type="search" class="mt-input" id="mt-pages-search" placeholder="Search by name or address"
                       autocomplete="off" spellcheck="false" aria-label="Search pages">
                <button type="button" class="mt-pl-clear" id="mt-pages-search-clear" aria-label="Clear search" hidden>&#10005;</button>
            </label>
            <span class="mt-pl-count" id="mt-pl-count" aria-live="polite">{$totalCount} pages</span>
        </div>

        {* The owning module's own controls for its pages, rendered by the
           module (Helpers\ExtensionPages, "panel"). Shown while the list
           shows only that module's pages. *}
        {foreach $extensionGroups as $g => $ext}
            {if $ext.panelHtml}
                <div class="mt-pl-extpanel" data-view-panel="ext-{$ext@index}" data-group-extension hidden>{$ext.panelHtml nofilter}</div>
            {/if}
        {/foreach}

        <table class="mt-pl-table">
            <colgroup><col class="c-page"><col class="c-addr mt-pl-col-addr"><col><col class="c-act"></colgroup>
            <thead><tr><th scope="col">Page</th><th scope="col" class="mt-pl-col-addr">Address</th><th scope="col">Changed</th><th scope="col"><span class="mt-pl-sr">Actions</span></th></tr></thead>
            <tbody id="mt-pl-body">
            {foreach $pages as $page}
                {assign var=editUrl value="?module=Hadrian&action=pages&sub=edit&page={$page.name|escape:'url'}"}
                <tr class="mt-pl-row{if $page.isSystem} is-system{/if}" data-page-row
                    data-key="{$page.name|escape}" data-area="{$page.area|escape}" data-group="{$groupLabels[$page.group]|default:$page.group|escape}"
                    {if $page.extension} data-ext-group="{$page.group|escape}"{/if}
                    {if $page.isSystem} data-system{/if}
                    {if $page.changes || $page.notes || !empty($page.extension.replaces)} data-changed{/if}
                    data-templates="{$page.templateCount}"
                    data-search="{$page.label|lower|escape} {$page.description|lower|escape} {$page.name|lower|escape} {$page.address|lower|escape}">
                    <td>
                        <span class="mt-pl-name">
                            <a href="{$editUrl|escape}" data-page-edit title="{$page.label|escape}">{$page.label|escape}</a>
                            {if $page.extension}<span class="mt-pl-built">Built</span>{/if}
                            {if $page.description}
                                <span class="mt-pl-info" title="{$page.description|escape}" aria-label="{$page.description|escape}" role="img"><svg viewBox="0 0 16 16" fill="none" aria-hidden="true"><circle cx="8" cy="8" r="6.2" stroke="currentColor" stroke-width="1.3"/><path d="M8 7.2v3.6M8 5.2v.01" stroke="currentColor" stroke-width="1.5" stroke-linecap="round"/></svg></span>
                            {/if}
                        </span>
                    </td>
                    <td class="mt-pl-col-addr">
                        {if $page.publicUrl}
                            {* plain |escape, never |escape:'url': the value carries its own ?a=b query. *}
                            <span class="mt-pl-addr"><a href="{$page.publicUrl|escape}" target="_blank" rel="noopener" data-page-open title="Open {$page.address|escape} in a new tab">{$page.address|escape}</a></span>
                        {elseif $page.address}
                            <span class="mt-pl-addr" title="Not live yet, so there is nothing to open">{$page.address|escape}</span>
                        {else}
                            <span class="mt-pl-none" title="{$page.publicReason|escape}">No direct address</span>
                        {/if}
                    </td>
                    <td>
                        <div class="mt-pl-badges">
                            {if $page.extension}
                                <span class="mt-badge mt-badge-{$page.extension.tone|default:'success'|escape}" data-page-status>{$page.extension.status|escape}</span>
                            {/if}
                            {foreach $page.notes as $note}
                                <span class="mt-badge mt-badge-{$note.tone|escape}" data-page-note>{$note.text|escape}</span>
                            {/foreach}
                            {* Shown on the "With templates" view only, for a page
                               still on its first template: which one it uses. *}
                            {assign var=tplChanged value=false}
                            {foreach $page.changes as $c}{if $c[0] == 'template'}{assign var=tplChanged value=true}{/if}{/foreach}
                            {if $page.templateCount > 1 && !$tplChanged}
                                <span class="mt-badge mt-badge-neutral" data-template-info title="{$page.templateNames|escape}" hidden>{$page.templateLabel|escape} &middot; {$page.templateCount} available</span>
                            {/if}
                            {foreach $page.changes as $c}
                                <span class="mt-badge {if $c[0] == 'auth'}mt-badge-warning{elseif $c[0] == 'off'}mt-badge-danger{elseif $c[0] == 'noindex' || $c[0] == 'area'}mt-badge-neutral{else}mt-badge-primary{/if}" data-page-change="{$c[0]|escape}">{$c[1]|escape}</span>
                            {/foreach}
                        </div>
                    </td>
                    <td class="mt-pl-act">
                        {if $page.extension && $page.extension.editUrl}
                            <a class="mt-btn mt-btn-secondary" href="{$page.extension.editUrl|escape}" data-page-content title="Opens this page in {$page.extension.label|escape}">Edit content</a>
                        {/if}
                        <a class="mt-btn mt-btn-secondary" href="{$editUrl|escape}" data-page-manage>Manage</a>
                    </td>
                </tr>
            {/foreach}
            </tbody>
        </table>
        <div class="mt-pl-empty" id="mt-pl-empty" hidden><strong id="mt-pl-empty-title"></strong><span id="mt-pl-empty-text"></span></div>
    </section>
</div>

{foreach $createGroups as $g => $ext}
    <dialog class="mt-pl-dialog" data-add-dialog="{$ext@index}" aria-labelledby="mt-pl-add-title-{$ext@index}">
        {* Posts to the module, which answers by opening its editor on the new page. *}
        <form method="post" action="{$ext.createUrl|escape}" data-group-create>
            <h2 id="mt-pl-add-title-{$ext@index}">Add a page</h2>
            <p>Name the page. It opens in {$ext.label|escape} as a draft, and nothing is public until you publish it.</p>
            <input type="text" class="mt-input" name="name" maxlength="120" required
                   placeholder="{$ext.createPlaceholder|escape}" aria-label="Name of the new page">
            <div class="mt-pl-dialog-foot">
                <button type="button" class="mt-btn mt-btn-secondary mt-btn-sm" data-dialog-cancel>Cancel</button>
                <button type="submit" class="mt-btn mt-btn-primary mt-btn-sm">{$ext.createLabel|escape}</button>
            </div>
        </form>
    </dialog>
{/foreach}

{literal}
<script>
(function () {
    var body = document.getElementById('mt-pl-body');
    if (!body) { return; }
    var rows    = Array.prototype.slice.call(body.querySelectorAll('[data-page-row]'));
    var rail    = document.getElementById('mt-pl-rail');
    var input   = document.getElementById('mt-pages-search');
    var clear   = document.getElementById('mt-pages-search-clear');
    var sys     = document.getElementById('mt-pages-showsys');
    var countEl = document.getElementById('mt-pl-count');
    var empty   = document.getElementById('mt-pl-empty');
    var AREA_ORDER = ['website', 'client', 'order'];
    var AREA_LABEL = {};
    var views = {};
    Array.prototype.forEach.call(rail.querySelectorAll('[data-view]'), function (b) {
        views[b.getAttribute('data-view')] = b;
        if (AREA_ORDER.indexOf(b.getAttribute('data-view')) >= 0) {
            AREA_LABEL[b.getAttribute('data-view')] = b.firstChild.textContent.trim();
        }
    });
    // Groups in the order the server listed them (the page's own group).
    var groupOrder = [];
    rows.forEach(function (r) {
        var g = r.getAttribute('data-group');
        if (groupOrder.indexOf(g) < 0) { groupOrder.push(g); }
    });

    var state = { view: 'all', q: '', system: false };

    function inView(r, view) {
        if (!state.system && r.hasAttribute('data-system')) { return false; }
        if (view === 'all') { return true; }
        if (view === 'changed') { return r.hasAttribute('data-changed'); }
        if (view === 'templates') { return +r.getAttribute('data-templates') > 1; }
        if (view.indexOf('ext-') === 0) { return r.getAttribute('data-ext-group') === views[view].getAttribute('data-ext-group'); }
        return r.getAttribute('data-area') === view;
    }
    function matches(r) {
        if (!state.q) { return true; }
        var hay = r.getAttribute('data-search');
        return state.q.split(/\s+/).every(function (w) { return hay.indexOf(w) >= 0; });
    }

    function render() {
        var q = state.q;
        // A search reveals system pages: someone typing "two-factor" is
        // looking for exactly that row, and withholding it would read as
        // the page not existing.
        var shown = rows.filter(function (r) {
            var sysOk = state.system || !r.hasAttribute('data-system') || !!q;
            var ok = sysOk && (q ? matches(r) && inViewIgnoringSystem(r) : inView(r, state.view));
            r.hidden = !ok;
            return ok;
        });

        // Group by area where the list spans areas; inside one area, by the
        // page's own group (Billing, Support, Built pages).
        var byArea = AREA_ORDER.indexOf(state.view) < 0;
        var key = function (r) { return byArea ? r.getAttribute('data-area') : r.getAttribute('data-group'); };
        var order = byArea ? AREA_ORDER : groupOrder;
        Array.prototype.forEach.call(body.querySelectorAll('.mt-pl-grp'), function (g) { g.remove(); });
        var frag = document.createDocumentFragment();
        order.forEach(function (k) {
            var inGroup = shown.filter(function (r) { return key(r) === k; });
            if (!inGroup.length) { return; }
            var tr = document.createElement('tr');
            tr.className = 'mt-pl-grp';
            var td = document.createElement('td');
            td.colSpan = 4;
            td.textContent = byArea ? (AREA_LABEL[k] || k) : k;
            var n = document.createElement('span');
            n.className = 'n';
            n.textContent = inGroup.length;
            td.appendChild(n);
            tr.appendChild(td);
            frag.appendChild(tr);
            inGroup.forEach(function (r) { frag.appendChild(r); });
        });
        rows.forEach(function (r) { if (r.hidden) { frag.appendChild(r); } });
        body.appendChild(frag);

        // The template badge says which template a page uses, on the view
        // that is about templates.
        Array.prototype.forEach.call(body.querySelectorAll('[data-template-info]'), function (b) {
            b.hidden = state.view !== 'templates';
        });

        Object.keys(views).forEach(function (v) {
            var on = v === state.view;
            views[v].classList.toggle('is-on', on);
            views[v].setAttribute('aria-pressed', on ? 'true' : 'false');
            var n = rail.querySelector('[data-count-for="' + v + '"]');
            if (n) { n.textContent = rows.filter(function (r) { return inView(r, v); }).length; }
        });
        Array.prototype.forEach.call(rail.querySelectorAll('[data-help-for]'), function (p) {
            p.hidden = p.getAttribute('data-help-for') !== state.view;
        });
        Array.prototype.forEach.call(document.querySelectorAll('[data-view-panel]'), function (p) {
            p.hidden = p.getAttribute('data-view-panel') !== state.view;
        });

        countEl.textContent = shown.length + (shown.length === 1 ? ' page' : ' pages');
        clear.hidden = !input.value;
        empty.hidden = shown.length > 0;
        if (!shown.length) {
            var title, text;
            if (q) {
                title = 'No pages match “' + input.value.trim() + '”';
                text = 'Try another word, or look in All pages.';
            } else if (state.view === 'changed') {
                title = 'Nothing changed yet';
                text = 'Every page uses the theme’s defaults. Pages you change show up here.';
            } else if (state.view.indexOf('ext-') === 0) {
                title = 'No pages yet';
                text = 'Use Add page to make the first one.';
            } else {
                title = 'No pages here';
                text = 'Turn on System pages to see the ones that are hidden.';
            }
            document.getElementById('mt-pl-empty-title').textContent = title;
            document.getElementById('mt-pl-empty-text').textContent = text;
        }
    }
    // While searching, the view still narrows the list, but system pages are
    // not held back.
    function inViewIgnoringSystem(r) {
        var keep = state.system;
        state.system = true;
        var ok = inView(r, state.view);
        state.system = keep;
        return ok;
    }

    function setView(v, remember) {
        state.view = views[v] ? v : 'all';
        render();
        if (remember !== false) {
            try { history.replaceState(null, '', '#view=' + encodeURIComponent(state.view)); } catch (e) {}
            try { localStorage.setItem('mt-pages-view', state.view); } catch (e) {}
        }
    }
    // "#view=client", or the old "#tab=Built" a module may still link to.
    function fromHash() {
        var m = location.hash.match(/view=([^&]+)/);
        if (m) { try { return decodeURIComponent(m[1]); } catch (e) {} }
        var t = location.hash.match(/tab=([^&]+)/);
        if (t) {
            var group = '';
            try { group = decodeURIComponent(t[1]); } catch (e) {}
            var hit = rail.querySelector('[data-ext-group="' + (window.CSS && CSS.escape ? CSS.escape(group) : group) + '"]');
            return hit ? hit.getAttribute('data-view') : 'all';
        }
        return null;
    }

    rail.addEventListener('click', function (e) {
        var b = e.target.closest('[data-view]');
        if (b) { setView(b.getAttribute('data-view')); }
    });
    if (sys) {
        sys.addEventListener('change', function () { state.system = sys.checked; render(); });
    }
    input.addEventListener('input', function () { state.q = input.value.trim().toLowerCase(); render(); });
    input.addEventListener('keydown', function (e) {
        if (e.key === 'Escape' && input.value) { e.preventDefault(); input.value = ''; state.q = ''; render(); }
    });
    clear.addEventListener('click', function () { input.value = ''; state.q = ''; render(); input.focus(); });

    // Anywhere on a row opens its settings, except its own links and buttons.
    body.addEventListener('click', function (e) {
        if (e.target.closest('a, button, input, select, textarea, label')) { return; }
        var r = e.target.closest('[data-page-row]');
        if (!r) { return; }
        var a = r.querySelector('[data-page-edit]');
        if (a) { location.href = a.getAttribute('href'); }
    });

    // Add page
    Array.prototype.forEach.call(document.querySelectorAll('[data-add-page]'), function (b) {
        var d = document.querySelector('[data-add-dialog="' + b.getAttribute('data-add-page') + '"]');
        if (!d || typeof d.showModal !== 'function') { return; }
        b.addEventListener('click', function () { d.showModal(); var f = d.querySelector('input[name="name"]'); if (f) { f.focus(); } });
        d.querySelector('[data-dialog-cancel]').addEventListener('click', function () { d.close(); });
    });

    var initial = fromHash();
    if (!initial) { try { initial = localStorage.getItem('mt-pages-view'); } catch (e) {} }
    setView(initial || 'all', false);
    window.addEventListener('hashchange', function () { var v = fromHash(); if (v) { setView(v, false); } });
})();
</script>
{/literal}

{include file="includes/footer.tpl"}
