{* Hostnodes — My Quotes list (Apple-style).

   WHMCS standard variables expected:
     $quotes           — array, each: id, subject, datecreated, validuntil,
                         total, stage, currencyprefix, currencysuffix
     $stageFilter      — current filter or empty for All
     $numquotes        — total quote count
*}

{* Prefer WHMCS-native $quotes; fall back to $mtQuotes populated by
   Hooks::clientAreaPageQuotes via localAPI when WHMCS doesn't expose
   $quotes in our included tpl scope. *}
{if isset($quotes) && $quotes|@count > 0}
    {assign var=qtList value=$quotes}
{elseif isset($mtQuotes) && $mtQuotes|@count > 0}
    {assign var=qtList value=$mtQuotes}
{else}
    {assign var=qtList value=[]}
{/if}
{assign var=qtCount value=$qtList|@count}
{if $qtCount > 0}
    {assign var=dashIsEmpty value='full'}
{else}
    {assign var=dashIsEmpty value='empty'}
{/if}

{assign var=currentFilter value=$stageFilter|default:''}

{* Dynamic AJAX Loading toggle (admin Settings -> enable_dynamic_ajax). When on,
   the table loads server-side in pages of 10 via dynamic-tables.js. *}
{assign var=mtAjaxTables value=$myTheme.addonSettings.enable_dynamic_ajax|default:false}

{* Tally delivered (awaiting acceptance) quotes for the banner. *}
{assign var=deliveredCount value=0}
{foreach $qtList as $_q}
    {assign var=_st value=$_q.stage|strip_tags}
    {if $_st == 'Delivered'}
        {assign var=deliveredCount value=$deliveredCount+1}
    {/if}
{/foreach}

{* Page-specific stylesheet *}
<link rel="stylesheet" href="{$WEB_ROOT}/templates/{$template}/assets/css/pages/clientareaquotes.css?v={$myTheme.version|default:'1.0'}">

{* Lagom-style instant sort: jQuery 3.x + DataTables 1.x for client-side reorder. *}
<script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
<script src="https://cdn.datatables.net/1.13.11/js/jquery.dataTables.min.js"></script>
{if $mtAjaxTables}<script src="{$WEB_ROOT}/templates/{$template}/assets/js/dynamic-tables.js?v={$myTheme.version|default:'1.0'}"></script>{/if}

<script>
(function () {
    var b = document.body;
    if (!b) return;
    b.setAttribute('data-data',       '{$dashIsEmpty}');
    b.setAttribute('data-subnav',     'on');
    b.setAttribute('data-svc-layout', 'inside');
})();
</script>

<div class="svc-table-card" aria-hidden="true"></div>

<header class="page-header">
    <div class="page-header-row">
        <div style="flex: 1; min-width: 0;">
            <h1>{$LANG.myquotes|default:'My Quotes'}</h1>
            <p class="page-subtitle">{$LANG.myquotessub|default:'Review delivered proposals, accept to convert into an invoice, or download as PDF.'}</p>
        </div>
    </div>
</header>

<div class="q-split">
    <div class="q-main">

        {if $deliveredCount > 0}
        <div class="q-banner when-full">
            <span class="q-banner-ico">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg>
            </span>
            <span><strong>{$deliveredCount} {if $deliveredCount == 1}{$LANG.quotedeliveredsingular|default:'quote awaiting your decision'}{else}{$LANG.quotedeliveredplural|default:'quotes awaiting your decision'}{/if}</strong>.</span>
            <span class="spacer"></span>
        </div>
        {/if}

        <div class="filter-tabs when-full">
            <a href="{$WEB_ROOT}/clientarea.php?action=quotes" class="filter-tab{if !$currentFilter} active{/if}" data-mt-for="qtTable" data-mt-filter="">{$LANG.all|default:'All'}</a>
            <a href="{$WEB_ROOT}/clientarea.php?action=quotes&stage=Draft" class="filter-tab{if $currentFilter == 'Draft'} active{/if}" data-mt-for="qtTable" data-mt-filter="Draft">{$LANG.quotestagedraft|default:'Draft'}</a>
            <a href="{$WEB_ROOT}/clientarea.php?action=quotes&stage=Delivered" class="filter-tab{if $currentFilter == 'Delivered'} active{/if}" data-mt-for="qtTable" data-mt-filter="Delivered">{$LANG.quotestagedelivered|default:'Delivered'}</a>
            <a href="{$WEB_ROOT}/clientarea.php?action=quotes&stage=Accepted" class="filter-tab{if $currentFilter == 'Accepted'} active{/if}" data-mt-for="qtTable" data-mt-filter="Accepted">{$LANG.quotestageaccepted|default:'Accepted'}</a>
            <a href="{$WEB_ROOT}/clientarea.php?action=quotes&stage=Lost" class="filter-tab{if $currentFilter == 'Lost'} active{/if}" data-mt-for="qtTable" data-mt-filter="Lost">{$LANG.quotestagelost|default:'Lost'}</a>
            <span class="mt-list-search"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="11" cy="11" r="7"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg><input type="search" placeholder="{$LANG.search|default:'Search'}…" aria-label="{$LANG.search|default:'Search'}" data-mt-search data-mt-for="qtTable"></span>
        </div>

        {* Sort: DataTables.js handles instant client-side sort on header click.
           Server returns rows pre-sorted per URL ?orderby=KEY&sort=ASC|DESC via
           Hooks::fetchAllQuotes for initial render + no-JS fallback. *}
        {assign var=sortKey value=$smarty.get.orderby|default:'id'}
        {assign var=sortDir value=$smarty.get.sort|default:'DESC'}
        {if $sortDir != 'ASC' && $sortDir != 'DESC'}{assign var=sortDir value='DESC'}{/if}
        {if $sortKey == 'date'}{assign var=sortColIdx value=1}
        {elseif $sortKey == 'valid'}{assign var=sortColIdx value=2}
        {elseif $sortKey == 'amount'}{assign var=sortColIdx value=3}
        {elseif $sortKey == 'status'}{assign var=sortColIdx value=4}
        {else}{assign var=sortColIdx value=0}
        {/if}

        <div class="q-stack">

            <div class="card q-table-card">

                {* Empty state *}
                <div class="when-empty q-empty">
                    <div class="q-empty-ico">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M14 2H6a2 2 0 00-2 2v16a2 2 0 002 2h12a2 2 0 002-2V8z"/><polyline points="14 2 14 8 20 8"/><line x1="9" y1="13" x2="15" y2="13"/><line x1="9" y1="17" x2="15" y2="17"/></svg>
                    </div>
                    <p class="q-empty-title">{$LANG.noquotes|default:'No quotes yet'}</p>
                    <p class="q-empty-sub">{$LANG.noquotessub|default:'When our team prepares a proposal for you, it will show up here.'}</p>
                    <a href="{$WEB_ROOT}/contact.php" class="btn-secondary">{$LANG.contactsales|default:'Contact sales'}</a>
                </div>

                {if $qtCount > 0}
                <table class="q-table when-full" id="qtTable"{if $mtAjaxTables} data-mt-action="tableQuotes" data-mt-type="quotes" data-mt-endpoint="{$WEB_ROOT}/clientarea.php" data-mt-order="0:desc" data-mt-length="10"{/if}>
                    <colgroup>
                        <col class="q-col-quote">
                        <col class="q-col-date">
                        <col class="q-col-valid">
                        <col class="q-col-amount">
                        <col class="q-col-status">
                        <col class="q-col-actions">
                    </colgroup>
                    <thead>
                        <tr>
                            <th class="hl-quote">{$LANG.quotenum|default:'Quote'} <span class="q-sort-ico"></span></th>
                            <th class="hl-date">{$LANG.quotedatecreated|default:'Date'} <span class="q-sort-ico"></span></th>
                            <th class="hl-valid">{$LANG.quotevaliduntil|default:'Valid until'} <span class="q-sort-ico"></span></th>
                            <th class="hl-amount">{$LANG.amount|default:'Amount'} <span class="q-sort-ico"></span></th>
                            <th class="hl-status">{$LANG.quotestage|default:'Status'} <span class="q-sort-ico"></span></th>
                            <th class="hl-actions" data-orderable="false" aria-hidden="true"></th>
                        </tr>
                    </thead>
                    <tbody>
                        {if !$mtAjaxTables}
                        {foreach $qtList as $qt}
                        {assign var=qtStage value=$qt.stage|strip_tags}
                        {assign var=qtStageLower value=$qtStage|lower|replace:' ':'-'}
                        {assign var=qtSubject value=$qt.subject|default:''}
                        {assign var=sortDateRaw value=$qt._sort_date_raw|default:$qt.datecreated|default:''}
                        {assign var=sortValidRaw value=$qt._sort_valid_raw|default:$qt.validuntil|default:''}
                        {assign var=sortAmount value=$qt._sort_amount|default:0}
                        <tr data-href="{$WEB_ROOT}/viewquote.php?id={$qt.id}">
                            <td data-order="{$qt.id}">
                                <div class="q-id-cell">
                                    <div class="q-id-ico"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M14 2H6a2 2 0 00-2 2v16a2 2 0 002 2h12a2 2 0 002-2V8z"/><polyline points="14 2 14 8 20 8"/><line x1="9" y1="13" x2="15" y2="13"/><line x1="9" y1="17" x2="15" y2="17"/></svg></div>
                                    <div class="q-id-meta">
                                        <span class="q-id-num">#{$qt.id|escape}</span>
                                        {if $qtSubject}<span class="q-id-subject">{$qtSubject|escape}</span>{/if}
                                    </div>
                                </div>
                            </td>
                            <td class="date" data-order="{$sortDateRaw|escape:'html'}">{$qt.datecreated|escape}</td>
                            <td class="date" data-order="{$sortValidRaw|escape:'html'}">{$qt.validuntil|escape}</td>
                            <td class="amount" data-order="{$sortAmount}">{$qt.total|escape}</td>
                            <td data-order="{$qtStageLower|escape:'html'}"><span class="status-pill {$qtStageLower}">{$qtStage|escape}</span></td>
                            <td class="actions">
                                <div class="q-menu-wrap" onclick="event.stopPropagation();">
                                    <button type="button" class="q-menu-btn" aria-label="{$LANG.actions|default:'Actions'}" aria-haspopup="true" aria-expanded="false" onclick="toggleQtMenu(this, event)">
                                        <svg viewBox="0 0 24 24" fill="currentColor"><circle cx="5" cy="12" r="2"/><circle cx="12" cy="12" r="2"/><circle cx="19" cy="12" r="2"/></svg>
                                    </button>
                                    <div class="q-menu" role="menu">
                                        <a href="{$WEB_ROOT}/viewquote.php?id={$qt.id}" class="q-menu-item" role="menuitem">
                                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/><circle cx="12" cy="12" r="3"/></svg>
                                            {$LANG.viewquote|default:'View Quote'}
                                        </a>
                                        <a href="{$WEB_ROOT}/dl.php?type=q&amp;id={$qt.id}" class="q-menu-item" role="menuitem">
                                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M21 15v4a2 2 0 01-2 2H5a2 2 0 01-2-2v-4"/><polyline points="7 10 12 15 17 10"/><line x1="12" y1="15" x2="12" y2="3"/></svg>
                                            {$LANG.downloadpdf|default:'Download PDF'}
                                        </a>
                                        {if $qtStage == 'Delivered'}
                                        <a href="{$WEB_ROOT}/viewquote.php?id={$qt.id}&action=accept" class="q-menu-item" role="menuitem">
                                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"/></svg>
                                            {$LANG.quoteaccept|default:'Accept Quote'}
                                        </a>
                                        {/if}
                                    </div>
                                </div>
                            </td>
                        </tr>
                        {/foreach}
                        {/if}
                    </tbody>
                </table>
                {/if}
            </div>

            <div class="q-footer when-full">
                <div class="q-page-size">
                    {$LANG.show|default:'Show'}
                    <select aria-label="{$LANG.rowsperpage|default:'Rows per page'}" data-dt-length data-mt-for="qtTable">
                        <option>10</option>
                        <option>25</option>
                        <option>50</option>
                    </select>
                    {$LANG.entries|default:'entries'}
                </div>
                <div class="spacer"></div>
                <span data-dt-info data-mt-for="qtTable">{$LANG.showing|default:'Showing'} 1–{$qtCount} {$LANG.of|default:'of'} {$numquotes|default:$qtCount}</span>
                <div class="q-pages" data-dt-pager data-mt-for="qtTable">
                    <button type="button" disabled aria-label="{$LANG.previouspage|default:'Previous page'}"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="15 18 9 12 15 6"/></svg></button>
                    <button type="button" class="active">1</button>
                    <button type="button" disabled aria-label="{$LANG.nextpage|default:'Next page'}"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="9 18 15 12 9 6"/></svg></button>
                </div>
            </div>

        </div>{* /.q-stack *}
    </div>

    {* ══ RIGHT: Billing sub-nav (same as invoices) ══ *}
    <aside>
        <div class="card subnav-card">
            <div class="subnav-heading">Billing</div>
            <a href="{$WEB_ROOT}/clientarea.php?action=invoices" class="subnav-item">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><rect x="1" y="4" width="22" height="16" rx="2"/><line x1="1" y1="10" x2="23" y2="10"/></svg>
                {$LANG.myinvoices|default:'My Invoices'}
            </a>
            <a href="{$WEB_ROOT}/clientarea.php?action=quotes" class="subnav-item active">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M14 2H6a2 2 0 00-2 2v16a2 2 0 002 2h12a2 2 0 002-2V8z"/><polyline points="14 2 14 8 20 8"/><line x1="9" y1="13" x2="15" y2="13"/><line x1="9" y1="17" x2="15" y2="17"/></svg>
                {$LANG.myquotes|default:'My Quotes'}
                <span class="subnav-count">{$qtCount}</span>
            </a>
            <a href="{$WEB_ROOT}/clientarea.php?action=masspay&all=true" class="subnav-item">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><rect x="2" y="5" width="20" height="14" rx="2"/><path d="M2 10h20"/><path d="M6 15h4"/></svg>
                {$LANG.masspayment|default:'Mass Payment'}
            </a>
            <a href="{$WEB_ROOT}/clientarea.php?action=addfunds" class="subnav-item">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="16"/><line x1="8" y1="12" x2="16" y2="12"/></svg>
                {$LANG.addfunds|default:'Add Funds'}
            </a>
            <a href="{routePath('account-paymentmethods')}" class="subnav-item">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><rect x="2" y="5" width="20" height="14" rx="2"/><path d="M2 10h20"/></svg>
                {$LANG.paymentmethods|default:'Payment Methods'}
            </a>
        </div>
    </aside>
</div>{* /.q-split *}

{if !$mtAjaxTables}
<script>
{literal}
// Row navigation — clicking a row goes to viewquote
document.addEventListener('DOMContentLoaded', function () {
    document.querySelectorAll('.q-table tbody tr[data-href]').forEach(function (row) {
        row.setAttribute('tabindex', '0');
        row.setAttribute('role', 'link');
        row.addEventListener('click', function (e) {
            if (e.target.closest('a, button, input, select, .q-menu-wrap')) return;
            window.location.href = row.dataset.href;
        });
        row.addEventListener('keydown', function (e) {
            if (e.key === 'Enter' || e.key === ' ') {
                e.preventDefault();
                window.location.href = row.dataset.href;
            }
        });
    });
});

// Kebab menu — open/close per row, close on outside-click / Escape
function toggleQtMenu(btn, e) {
    if (e) { e.preventDefault(); e.stopPropagation(); }
    var wrap = btn.closest('.q-menu-wrap');
    var wasOpen = wrap.classList.contains('open');
    document.querySelectorAll('.q-menu-wrap.open').forEach(function (w) {
        w.classList.remove('open');
        var b = w.querySelector('.q-menu-btn');
        if (b) b.setAttribute('aria-expanded', 'false');
    });
    if (!wasOpen) {
        wrap.classList.add('open');
        btn.setAttribute('aria-expanded', 'true');
    }
}
document.addEventListener('click', function (e) {
    if (e.target.closest('.q-menu-wrap')) return;
    document.querySelectorAll('.q-menu-wrap.open').forEach(function (w) {
        w.classList.remove('open');
        var b = w.querySelector('.q-menu-btn');
        if (b) b.setAttribute('aria-expanded', 'false');
    });
});
document.addEventListener('keydown', function (e) {
    if (e.key !== 'Escape') return;
    document.querySelectorAll('.q-menu-wrap.open').forEach(function (w) {
        w.classList.remove('open');
        var b = w.querySelector('.q-menu-btn');
        if (b) b.setAttribute('aria-expanded', 'false');
    });
});
{/literal}

// DataTables init — same pattern as invoices.
{literal}
if (typeof jQuery !== 'undefined' && jQuery.fn.DataTable) {
    jQuery(function ($) {
        var $tbl = $('#qtTable');
        if (!$tbl.length) return;
        var TID = 'qtTable';
        function ctrl(attr) { return document.querySelector('[' + attr + '][data-mt-for="' + TID + '"]'); }
        function buildPager(el, info) {
            var page = info.page, pages = info.pages, html = '';
            var L = '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="15 18 9 12 15 6"/></svg>';
            var R = '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="9 18 15 12 9 6"/></svg>';
            html += '<button type="button" data-page="' + (page - 1) + '"' + (page <= 0 ? ' disabled' : '') + ' aria-label="Previous page">' + L + '</button>';
            if (pages > 0) { var win = 5, start = Math.max(0, page - 2), end = Math.min(pages - 1, start + win - 1); start = Math.max(0, Math.min(start, end - win + 1)); for (var p = start; p <= end; p++) { html += '<button type="button" data-page="' + p + '"' + (p === page ? ' class="active"' : '') + '>' + (p + 1) + '</button>'; } } else { html += '<button type="button" class="active">1</button>'; }
            html += '<button type="button" data-page="' + (page + 1) + '"' + (page >= pages - 1 ? ' disabled' : '') + ' aria-label="Next page">' + R + '</button>';
            el.innerHTML = html;
        }
        function updateControls(api) {
            var info = api.page.info();
            var infoEl = ctrl('data-dt-info');
            if (infoEl) { var from = info.recordsDisplay ? info.start + 1 : 0; infoEl.textContent = 'Showing ' + from + '–' + info.end + ' of ' + info.recordsDisplay; }
            var pagerEl = ctrl('data-dt-pager');
            if (pagerEl) { buildPager(pagerEl, info); }
        }
        var table = $tbl.DataTable({
            paging:    true,
            searching: true,
            info:      false,
            autoWidth: false,
            ordering:  true,
            pageLength: 10,
            dom:       'rt',
{/literal}
            order:     [[{$sortColIdx}, '{$sortDir|lower}']],
{literal}
            columnDefs: [{ orderable: false, targets: -1 }],
            drawCallback: function () { updateControls(this.api()); }
        });
        var searchEl = ctrl('data-mt-search');
        if (searchEl) { searchEl.addEventListener('input', function () { table.search(this.value || '').draw(); }); }
        var lenEl = ctrl('data-dt-length');
        if (lenEl) { lenEl.value = String(table.page.len()); lenEl.addEventListener('change', function () { var n = parseInt(this.value, 10); if (n > 0) { table.page.len(n).draw(); } }); }
        var pagerEl = ctrl('data-dt-pager');
        if (pagerEl) { pagerEl.addEventListener('click', function (e) { var b = e.target.closest('button[data-page]'); if (!b || b.disabled) return; var p = parseInt(b.getAttribute('data-page'), 10); if (!isNaN(p) && p >= 0) { table.page(p).draw(false); } }); }
        var keyByCol = { 0: 'id', 1: 'date', 2: 'valid', 3: 'amount', 4: 'status' };
        table.on('order.dt', function () {
            var ord = table.order();
            if (!ord || !ord.length) return;
            var key = keyByCol[ord[0][0]];
            var dir = (ord[0][1] || 'asc').toUpperCase();
            if (!key) return;
            try {
                var url = new URL(window.location.href);
                url.searchParams.set('orderby', key);
                url.searchParams.set('sort', dir);
                window.history.replaceState({}, '', url.toString());
            } catch (err) {}
        });
    });
}
{/literal}
</script>
{/if}
