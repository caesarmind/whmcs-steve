{include file="includes/header.tpl"}

<header class="mt-page-header">
    <div class="mt-page-eyebrow">Theme</div>
    <h1 class="mt-page-title">Pages {include file="includes/doclink.tpl" article="page-manager"}</h1>
    <p class="mt-page-subtitle">Set the template variant, SEO, indexing, visibility and layout overrides for each WHMCS page.</p>
</header>

<div class="mt-search mt-pages-search">
    <span class="mt-search-icon" aria-hidden="true">
        <svg viewBox="0 0 16 16" fill="none">
            <circle cx="7" cy="7" r="4.5" stroke="currentColor" stroke-width="1.6"/>
            <path d="M10.5 10.5L14 14" stroke="currentColor" stroke-width="1.6" stroke-linecap="round"/>
        </svg>
    </span>
    <input type="search" id="mt-pages-search" class="mt-input" placeholder="Search pages&hellip;"
           autocomplete="off" spellcheck="false" aria-label="Search pages">
    <button type="button" class="mt-search-clear" id="mt-pages-search-clear" aria-label="Clear search" hidden>&#10005;</button>
</div>

{* System pages -- wizard sub-steps, included partials and error states -- are
   hidden by default because an admin never navigates to them. They are
   FILTERED, not dropped: page.php's own listDisplay => false would make them
   reachable only by typing a ?sub=edit&page= URL, and some of them (the 2FA
   challenge, the upgrade summary) are pages a visitor really sees and an admin
   may legitimately want to set a layout override or a noindex on. *}
{if $systemCount > 0}
    <label class="mt-sys-toggle">
        <input type="checkbox" id="mt-pages-showsys">
        <span>Show {$systemCount} system pages</span>
        {include file="includes/tip.tpl" text="Wizard steps, partials included by another page, and error states WHMCS renders in place of whatever you asked for. They are hidden because you never navigate to them - not because they cannot be configured." article="page-manager" anchor="the-page-list"}
    </label>
{/if}

<div class="mt-tabs" id="mt-pages-tabs" role="tablist">
    <a class="mt-tab is-active" href="#tab=all" data-tab="all" role="tab">
        All <span class="mt-tab-pill" data-tab-pill>{$totalCount}</span>
    </a>
    {foreach $groups as $g}
        <a class="mt-tab" href="#tab={$g|escape:'url'}" data-tab="{$g|escape}" role="tab">
            {$g|escape} <span class="mt-tab-pill" data-tab-pill>{$pagesByGroup[$g]|count}</span>
        </a>
    {/foreach}
</div>

{* Between the tab strip and the group cards, so the confirmation sits with the
   content it describes rather than above the search box. *}
{if $flashMsg == 'saved'}
    <div class="mt-alert mt-alert-success mt-alert-lead">
        <span class="mt-alert-icon" aria-hidden="true"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"><path d="M5 12l5 5L20 7"/></svg></span>
        <span>Page settings saved.</span>
    </div>
{/if}

{literal}
<style>
/* A bare count that inherits the tab's own colour (so it goes accent at 60% on
   the active tab), not a filled pill with a background of its own. */
.mt-tab-pill { margin-left:6px; font-size:11px; opacity:0.6; }

/* Search ------------------------------------------------------------- */
.mt-pages-search { margin: 0 0 10px; }

/* System-pages toggle. Sits under the search, above the tabs. */
.mt-sys-toggle { display:inline-flex; align-items:center; gap:8px; margin:0 0 14px;
    font-size:12.5px; color:var(--mt-text-2); cursor:pointer; user-select:none; }
.mt-sys-toggle input { accent-color:var(--mt-primary); width:14px; height:14px; margin:0; cursor:pointer; }
/* While a search is running the toggle does nothing (search reveals system
   pages regardless), so it reads as unavailable rather than broken. */
.mt-sys-toggle.is-muted { opacity:0.45; cursor:default; }
.mt-sys-toggle.is-muted input { cursor:default; }
/* A revealed system row is dimmed so it stays visually secondary to the real
   pages it sits among. */
.mt-pagerow.is-system .mt-pagerow-name { color:var(--mt-text-2); }
/* Radius scoped to this page so the global .mt-input (var(--mt-radius), 12px)
   is left alone on every other admin screen. */
.mt-pages-search .mt-input { padding-right: 34px; border-radius: 10px; }
.mt-pages-search .mt-search-icon svg { width: 16px; height: 16px; }
/* Suppress the native WebKit clear affordance -- we render our own so the
   control looks identical across browsers. */
.mt-pages-search input[type="search"]::-webkit-search-cancel-button,
.mt-pages-search input[type="search"]::-webkit-search-decoration { -webkit-appearance: none; appearance: none; }
.mt-search-clear { position:absolute; right:8px; top:50%; transform:translateY(-50%); display:flex; align-items:center; justify-content:center; width:22px; height:22px; padding:0; border:none; border-radius:50%; background:transparent; color:var(--mt-text-3); font-size:12px; line-height:1; cursor:pointer; transition:background 0.15s ease, color 0.15s ease; }
.mt-search-clear:hover { background:var(--mt-neutral-tint); color:var(--mt-text); }
.mt-search-clear:focus-visible { outline:2px solid var(--mt-primary); outline-offset:1px; }
.mt-search-clear[hidden] { display:none; }

/* Section heading: 22px title with the count as a sub-line beneath it. */
.mt-pages-section .mt-section-title { font-size:22px; letter-spacing:-0.02em; }

/* Page rows ----------------------------------------------------------- */
.mt-pagerow-scroll { overflow-x:auto; }
/* The wrapper is ours, not the reference's: a bare 1fr first track collapses
   the name cell inside the WHMCS admin content column. At normal widths it
   changes nothing. */
/* 750, not 640: the Open column adds 84 + one 14px gap. Miss this and the
   badges compress before .mt-pagerow-scroll engages. */
.mt-pagerow-grid { min-width:750px; }
.mt-pagerow-head,
.mt-pagerow { display:grid; grid-template-columns:minmax(200px,1fr) 92px 56px 92px 104px 84px 18px; gap:14px; align-items:center; }
.mt-pagerow-head { padding:0 14px 8px; }
.mt-pagerow-head span { font-size:10px; font-weight:700; letter-spacing:0.1em; text-transform:uppercase; color:var(--mt-text-4); }
.mt-pagerow-list { display:flex; flex-direction:column; gap:6px; }
.mt-pagerow { padding:12px 14px; border:1px solid var(--mt-border); border-radius:10px; background:var(--mt-surface); text-decoration:none; color:inherit; transition:background 0.15s ease; }
.mt-pagerow:hover { background:var(--mt-surface-2); text-decoration:none; }
/* Row-scoped badge metrics. Deliberately NOT applied to the global .mt-badge:
   .mt-lay-aud-cta on the Layouts cards is hand-tuned to .mt-badge's exact box
   (3px padding + 1.5 line-height on 12px) so an "Activate" row is the same
   height as an "Active" one -- changing the global would break that. */
.mt-pagerow .mt-badge { padding:3px 9px; font-size:11px; letter-spacing:0.02em; }
/* position:relative anchors the stretched overlay below. */
.mt-pagerow { position:relative; }
/* The name cell is the editor link; its ::after covers the whole row so
   clicking anywhere still opens the editor, exactly as when the row itself
   was an anchor.
   position:static is LOAD-BEARING and looks like a no-op: without it the
   inset:0 overlay would size to this cell instead of the row, and the
   whole-row click target silently disappears. */
.mt-pagerow-edit { position:static; text-decoration:none; color:inherit; }
.mt-pagerow-edit:hover { text-decoration:none; color:inherit; }
.mt-pagerow-edit::after { content:""; position:absolute; inset:0; border-radius:10px; }
/* The row is a div now and cannot take focus, so the ring moves to the link
   that can. Inset offset because .mt-pagerow-scroll is overflow-x:auto, which
   clips in BOTH axes and would shave a positive-offset ring off the edge
   rows. */
.mt-pagerow-edit:focus-visible { outline:none; }
.mt-pagerow-edit:focus-visible::after { outline:2px solid var(--mt-primary); outline-offset:-1px; }
/* 0,2,0 so it beats the 0,1,0 display:grid above -- the search JS toggles this. */
.mt-pagerow[hidden] { display:none; }

/* Open cell: sits above the overlay so it wins the click. */
.mt-pagerow-open { position:relative; z-index:1; justify-self:start; }
.mt-pagerow-openlink { display:inline-flex; align-items:center; gap:5px; padding:3px 9px;
    border:1px solid var(--mt-border); border-radius:999px; background:var(--mt-surface);
    color:var(--mt-primary); font-size:11px; font-weight:600; letter-spacing:0.02em;
    text-decoration:none; white-space:nowrap; transition:background .12s ease, border-color .12s ease; }
.mt-pagerow-openlink:hover { background:var(--mt-primary-tint); border-color:var(--mt-primary);
    color:var(--mt-primary); text-decoration:none; }
.mt-pagerow-openlink:focus-visible { outline:2px solid var(--mt-primary); outline-offset:1px; }
.mt-pagerow-openlink svg { width:11px; height:11px; display:block; flex-shrink:0; }
/* cursor:help -- the dash's title carries the reason there is no link. */
.mt-pagerow-open .mt-pagerow-dash { cursor:help; }
.mt-pagerow-main { min-width:0; }
.mt-pagerow-name { display:block; font-size:14px; font-weight:600; color:var(--mt-text); }
.mt-pagerow-desc { display:block; font-size:12px; color:var(--mt-text-3); margin-top:2px; white-space:nowrap; overflow:hidden; text-overflow:ellipsis; }
.mt-pagerow-variant { font-size:12.5px; color:var(--mt-text-2); }
.mt-pagerow-dash { color:var(--mt-text-4); }
.mt-pagerow-chev { color:var(--mt-text-3); font-size:13px; text-align:right; }

.mt-pages-noresults .mt-empty-title { font-size:17px; }
.mt-pages-panel[hidden], .mt-pages-noresults[hidden] { display:none; }
</style>
{/literal}

<div class="mt-panel pad mt-pages-noresults" id="mt-pages-noresults" hidden>
    <div class="mt-empty">
        <div class="mt-empty-icon mt-empty-icon-circle" aria-hidden="true">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linecap="round"><circle cx="11" cy="11" r="7"/><path d="M21 21l-4-4"/></svg>
        </div>
        <h3 class="mt-empty-title">No pages match &ldquo;<span id="mt-pages-noresults-q"></span>&rdquo;</h3>
        <p>Try a different search term, or switch to another group.</p>
    </div>
</div>

{foreach $groups as $g}
    {assign var=groupRows value=$pagesByGroup[$g]}
    <div class="mt-panel pad mt-pages-panel" data-group-panel="{$g|escape}">
    <section class="mt-section mt-pages-section" data-group-section="{$g|escape}">
        <header class="mt-section-header">
            {* One wrapper div, so .mt-section-header's space-between has a
               single left child and the count reads as a sub-line of the title.
               [data-group-count] and data-total move WITH it -- the search JS
               selects by attribute and reads data-total off this element. *}
            <div>
                <h2 class="mt-section-title">{$g|escape} pages</h2>
                <div class="mt-section-sub" data-group-count data-total="{$groupRows|count}">{$groupRows|count} pages</div>
            </div>
        </header>

        {if $groupRows|count}
            <div class="mt-pagerow-scroll">
                <div class="mt-pagerow-grid">
                    <div class="mt-pagerow-head" aria-hidden="true">
                        <span>Page</span>
                        <span>Variant</span>
                        <span>SEO</span>
                        <span>Indexing</span>
                        <span>Visibility</span>
                        <span>Open</span>
                        <span></span>
                    </div>
                    <div class="mt-pagerow-list">
                        {foreach $groupRows as $page}
                            {* The row is a DIV, not an anchor. It used to be an
                               <a> wrapping every cell, but the Open link below
                               is a second anchor and anchors cannot nest --
                               the parser would close the outer one early and
                               re-parent the remaining cells as siblings,
                               shattering the grid. Instead the NAME cell is
                               the anchor and a stretched ::after restores the
                               whole-row click target. *}
                            <div class="mt-pagerow{if $page.isSystem} is-system{/if}"
                                 data-page-row{if $page.isSystem} data-system{/if}
                                 data-search="{$page.label|lower|escape} {$page.description|lower|escape} {$page.name|lower|escape} {$page.variantLabel|lower|escape}">
                                <a class="mt-pagerow-main mt-pagerow-edit"
                                   href="?module=Hadrian&amp;action=pages&amp;sub=edit&amp;page={$page.name|escape:'url'}">
                                    <span class="mt-pagerow-name">{$page.label|escape}</span>
                                    {if $page.description}
                                        <span class="mt-pagerow-desc">{$page.description|escape}</span>
                                    {/if}
                                </a>
                                <span class="mt-pagerow-variant">{$page.variantLabel|escape}</span>
                                <span>
                                    {if $page.hasSeo}
                                        <span class="mt-badge mt-badge-primary">SEO</span>
                                    {else}
                                        <span class="mt-pagerow-dash">&mdash;</span>
                                    {/if}
                                </span>
                                <span>
                                    {if $page.indexing == 'allow'}
                                        <span class="mt-badge mt-badge-success">Allow</span>
                                    {elseif $page.indexing == 'disallow'}
                                        <span class="mt-badge mt-badge-warning">Disallow</span>
                                    {else}
                                        <span class="mt-badge mt-badge-neutral">Inherit</span>
                                    {/if}
                                </span>
                                <span>
                                    {if $page.visibility == 'disabled'}
                                        <span class="mt-badge mt-badge-warning">Disabled</span>
                                    {elseif $page.visibility == 'auth'}
                                        <span class="mt-badge mt-badge-primary">Auth only</span>
                                    {else}
                                        <span class="mt-badge mt-badge-success">Public</span>
                                    {/if}
                                </span>
                                {* Sits ABOVE the stretched overlay (z-index), so
                                   clicking Open opens the client-area page while
                                   clicking anywhere else in the row still opens
                                   the editor. plain |escape, never |escape:'url'
                                   -- the value carries its own ?a=b query. *}
                                <span class="mt-pagerow-open">
                                    {if $page.publicUrl}
                                        <a class="mt-pagerow-openlink" href="{$page.publicUrl|escape}"
                                           target="_blank" rel="noopener"
                                           title="Opens {$page.publicUrl|escape} in a new tab.">
                                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M14 4h6v6"/><path d="M20 4l-8 8"/><path d="M18 14v4a2 2 0 0 1-2 2H6a2 2 0 0 1-2-2V8a2 2 0 0 1 2-2h4"/></svg>
                                            Open
                                        </a>
                                    {else}
                                        <span class="mt-pagerow-dash" title="{$page.publicReason|escape}">&mdash;</span>
                                    {/if}
                                </span>
                                <span class="mt-pagerow-chev" aria-hidden="true">&rsaquo;</span>
                            </div>
                        {/foreach}
                    </div>
                </div>
            </div>
        {else}
            <div class="mt-empty">
                <h3 class="mt-empty-title">No pages in this group</h3>
                <p>Add a <code>core/pages/&lt;page&gt;/page.php</code> with <code>'group' =&gt; '{$g|escape}'</code> and rebuild discovery from the Tools tab.</p>
            </div>
        {/if}
    </section>
    </div>
{/foreach}

{literal}
<script>
(function() {
    var tabs     = document.querySelectorAll('#mt-pages-tabs .mt-tab');
    var panels   = document.querySelectorAll('.mt-pages-panel');
    var input    = document.getElementById('mt-pages-search');
    var clearBtn = document.getElementById('mt-pages-search-clear');
    var noRes    = document.getElementById('mt-pages-noresults');
    var noResQ   = document.getElementById('mt-pages-noresults-q');
    if (!tabs.length || !panels.length) return;

    var validTabs = {};
    Array.prototype.forEach.call(tabs, function(t) { validTabs[t.getAttribute('data-tab')] = true; });

    var activeTab = 'all';
    var query     = '';
    // Not persisted on purpose: a returning admin must never land on a
    // filtered list they did not choose. Off is the honest default.
    var sysToggle  = document.getElementById('mt-pages-showsys');
    var showSystem = false;

    // Single source of truth: a row is visible when it belongs to the active
    // tab AND matches the query. Group panels hide when they have no visible
    // rows, so searching collapses irrelevant groups the way the tabs do.
    function apply() {
        var q = query.trim().toLowerCase();
        var totalVisible = 0;
        var panelCounts = {};

        Array.prototype.forEach.call(panels, function(panel) {
            var group   = panel.getAttribute('data-group-panel');
            var inTab   = (activeTab === 'all') || (group === activeTab);
            var rows    = panel.querySelectorAll('[data-page-row]');
            var shown   = 0;

            Array.prototype.forEach.call(rows, function(row) {
                // A system page is suppressed unless the toggle is on -- EXCEPT
                // when it matches an explicit search, because someone typing
                // "two-factor" is looking for exactly that row and silently
                // withholding it would read as the page not existing.
                var isSys   = row.hasAttribute('data-system');
                var sysOk   = !isSys || showSystem || !!q;
                var hit = inTab && sysOk && (!q || row.getAttribute('data-search').indexOf(q) !== -1);
                if (hit) { row.removeAttribute('hidden'); shown++; }
                else     { row.setAttribute('hidden', ''); }
            });

            // Counts must describe what is ON SCREEN. The server-rendered
            // total includes system pages, so with them suppressed an
            // unadjusted "22 pages" over a list of 19 would simply be wrong.
            var countable = 0;
            Array.prototype.forEach.call(rows, function(r) {
                if (!r.hasAttribute('data-system') || showSystem) { countable++; }
            });
            panelCounts[group] = countable;

            var countEl = panel.querySelector('[data-group-count]');
            if (countEl) {
                countEl.textContent = q
                    ? (shown + ' of ' + countable + ' pages')
                    : (countable + (countable === 1 ? ' page' : ' pages'));
            }

            // A group with zero rows on the server still shows its own empty
            // state, but only while it is in the active tab and unfiltered.
            var serverEmpty = rows.length === 0;
            var visible = inTab && (serverEmpty ? !q : shown > 0);
            if (visible) { panel.removeAttribute('hidden'); }
            else         { panel.setAttribute('hidden', ''); }

            totalVisible += shown;
        });

        var noneAtAll = q && totalVisible === 0;
        if (noneAtAll) {
            noResQ.textContent = query.trim();
            noRes.removeAttribute('hidden');
        } else {
            noRes.setAttribute('hidden', '');
        }

        if (clearBtn) {
            if (query) { clearBtn.removeAttribute('hidden'); }
            else       { clearBtn.setAttribute('hidden', ''); }
        }

        // Tab pills follow the same rule as the group counts: they name what
        // the tab would show, not what the server rendered.
        var grand = 0;
        Array.prototype.forEach.call(tabs, function(t) {
            var name = t.getAttribute('data-tab');
            var pill = t.querySelector('[data-tab-pill]');
            if (!pill || name === 'all') { return; }
            var n = panelCounts[name] || 0;
            grand += n;
            pill.textContent = n;
        });
        var allPill = document.querySelector('[data-tab="all"] [data-tab-pill]');
        if (allPill) { allPill.textContent = grand; }

        // The toggle is a no-op while a query is running (search already
        // reveals system pages), so say so instead of leaving it looking broken.
        if (sysToggle) {
            sysToggle.disabled = !!q;
            var lbl = sysToggle.closest('.mt-sys-toggle');
            if (lbl) { lbl.classList.toggle('is-muted', !!q); }
        }
    }

    function activate(name, push) {
        if (!validTabs[name]) name = 'all';
        activeTab = name;
        Array.prototype.forEach.call(tabs, function(t) {
            t.classList.toggle('is-active', t.getAttribute('data-tab') === name);
        });
        apply();
        if (push !== false) {
            try { history.replaceState(null, '', '#tab=' + encodeURIComponent(name)); } catch (e) {}
            try { localStorage.setItem('mt-pages-tab', name); } catch (e) {}
        }
    }

    Array.prototype.forEach.call(tabs, function(t) {
        t.addEventListener('click', function(e) {
            e.preventDefault();
            activate(t.getAttribute('data-tab'));
        });
    });

    if (input) {
        input.addEventListener('input', function() { query = input.value; apply(); });
        input.addEventListener('keydown', function(e) {
            if (e.key === 'Escape' && input.value) {
                e.preventDefault();
                input.value = ''; query = ''; apply();
            }
        });
    }
    if (clearBtn) {
        clearBtn.addEventListener('click', function() {
            input.value = ''; query = ''; apply();
            input.focus();
        });
    }
    if (sysToggle) {
        sysToggle.addEventListener('change', function() {
            showSystem = sysToggle.checked;
            apply();
        });
    }

    // Resolve initial tab: URL hash > localStorage > default 'all'.
    var initial = null;
    var m = window.location.hash.match(/tab=([^&]+)/);
    if (m) { try { initial = decodeURIComponent(m[1]); } catch (e) {} }
    if (!initial) { try { initial = localStorage.getItem('mt-pages-tab'); } catch (e) {} }
    if (!initial) initial = 'all';
    activate(initial);

    // React to back/forward navigation that changes the hash.
    window.addEventListener('hashchange', function() {
        var mm = window.location.hash.match(/tab=([^&]+)/);
        if (mm) { try { activate(decodeURIComponent(mm[1]), false); } catch (e) {} }
    });
})();
</script>
{/literal}

{include file="includes/footer.tpl"}
