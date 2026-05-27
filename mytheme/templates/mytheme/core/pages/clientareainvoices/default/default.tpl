{* Hostnodes — My Invoices list (Apple-style).

   WHMCS standard variables expected:
     $invoices         — array, each: id, invoicenum, datecreated, total, status,
                         statusClass, datepaid, duedate
     $statusFilter     — current filter (e.g. "Unpaid") or empty for All
     $startnumber      — pagination start offset
     $pagesize         — rows per page
     $numinvoices      — total invoice count
*}

{* Prefer WHMCS-native $invoices; fall back to $mtInvoices populated by
   Hooks::clientAreaPageInvoices via localAPI when WHMCS doesn't expose
   $invoices in our included tpl scope. *}
{if isset($invoices) && $invoices|@count > 0}
    {assign var=invList value=$invoices}
{elseif isset($mtInvoices) && $mtInvoices|@count > 0}
    {assign var=invList value=$mtInvoices}
{else}
    {assign var=invList value=[]}
{/if}
{assign var=invCount value=$invList|@count}
{if $invCount > 0}
    {assign var=dashIsEmpty value='full'}
{else}
    {assign var=dashIsEmpty value='empty'}
{/if}

{assign var=currentFilter value=$statusFilter|default:''}

{* Dynamic AJAX Loading toggle (admin Settings -> enable_dynamic_ajax). When on,
   the table is loaded server-side in pages of 10 via dynamic-tables.js; when off,
   the {foreach} below renders every row (current behavior). *}
{assign var=mtAjaxTables value=$myTheme.addonSettings.enable_dynamic_ajax|default:false}

{* Tally unpaid count. Use strip_tags because WHMCS sometimes returns
   $invoice.status wrapped in <span class="textred">...</span> markup. *}
{assign var=unpaidCount value=0}
{foreach $invList as $_i}
    {assign var=_st value=$_i.status|strip_tags}
    {if $_st == 'Unpaid' || $_st == 'Overdue'}
        {assign var=unpaidCount value=$unpaidCount+1}
    {/if}
{/foreach}

{* Page-specific stylesheet *}
<link rel="stylesheet" href="{$WEB_ROOT}/templates/{$template}/assets/css/pages/clientareainvoices.css?v={$myTheme.version|default:'1.0'}">

{* Lagom-style instant sort: jQuery 3.x + DataTables 1.x for client-side reorder. *}
<script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
<script src="https://cdn.datatables.net/1.13.11/js/jquery.dataTables.min.js"></script>
{if $mtAjaxTables}<script src="{$WEB_ROOT}/templates/{$template}/assets/js/dynamic-tables.js?v={$myTheme.version|default:'1.0'}"></script>{/if}

<script>
(function () {
    var b = document.body;
    if (!b) return;
    b.setAttribute('data-data',          '{$dashIsEmpty}');
    b.setAttribute('data-subnav',        'on');
    b.setAttribute('data-svc-layout',    'inside');
})();
</script>

<div class="svc-table-card" aria-hidden="true"></div>

<header class="page-header">
    <div class="page-header-row">
        <div style="flex: 1; min-width: 0;">
            <h1>{$LANG.navinvoices|default:'Invoices'}</h1>
            <p class="page-subtitle">{$LANG.invoicessub|default:'Pay unpaid invoices, download PDFs, and review past payments.'}</p>
        </div>
        {if $unpaidCount > 0}
        <a href="{$WEB_ROOT}/clientarea.php?action=masspay&all=true" class="page-header-action when-full">
            {$LANG.payallunpaid|default:'Pay all unpaid'}
            <svg class="chev" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><polyline points="9 18 15 12 9 6"/></svg>
        </a>
        {/if}
    </div>
</header>

<div class="inv-split">
    <div class="inv-main">

        {if $unpaidCount > 0}
        <div class="inv-banner when-full">
            <span class="inv-banner-ico">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg>
            </span>
            <span><strong>{$unpaidCount} {if $unpaidCount == 1}{$LANG.unpaidinvoicesingular|default:'unpaid invoice'}{else}{$LANG.unpaidinvoicesplural|default:'unpaid invoices'}{/if}</strong>.</span>
            <span class="spacer"></span>
            <a href="{$WEB_ROOT}/clientarea.php?action=masspay&all=true" class="btn-secondary">{$LANG.paynow|default:'Pay now'}</a>
        </div>
        {/if}

        <div class="filter-tabs when-full">
            <a href="{$WEB_ROOT}/clientarea.php?action=invoices" class="filter-tab{if !$currentFilter} active{/if}" data-mt-for="invTable" data-mt-filter="">{$LANG.all|default:'All'}</a>
            <a href="{$WEB_ROOT}/clientarea.php?action=invoices&status=Unpaid" class="filter-tab{if $currentFilter == 'Unpaid'} active{/if}" data-mt-for="invTable" data-mt-filter="Unpaid">{$LANG.invoiceunpaid|default:'Unpaid'}</a>
            <a href="{$WEB_ROOT}/clientarea.php?action=invoices&status=Paid" class="filter-tab{if $currentFilter == 'Paid'} active{/if}" data-mt-for="invTable" data-mt-filter="Paid">{$LANG.invoicepaid|default:'Paid'}</a>
            <a href="{$WEB_ROOT}/clientarea.php?action=invoices&status=Cancelled" class="filter-tab{if $currentFilter == 'Cancelled'} active{/if}" data-mt-for="invTable" data-mt-filter="Cancelled">{$LANG.invoicecancelled|default:'Cancelled'}</a>
            {if $mtAjaxTables}<span class="mt-dt-search" style="margin-left:auto"><input type="search" placeholder="{$LANG.search|default:'Search'}…" aria-label="{$LANG.search|default:'Search'}" data-mt-search data-mt-for="invTable"></span>{/if}
        </div>

        {* Sort: DataTables.js handles instant client-side sort on header click (matches
           Lagom). Server returns rows pre-sorted per URL ?orderby=KEY&sort=ASC|DESC
           via Hooks::fetchAllInvoices, so initial render is correct + no-JS fallback works.
           DataTables init below reads the same URL params and applies them on load. *}
        {assign var=sortKey value=$smarty.get.orderby|default:'id'}
        {assign var=sortDir value=$smarty.get.sort|default:'DESC'}
        {if $sortDir != 'ASC' && $sortDir != 'DESC'}{assign var=sortDir value='DESC'}{/if}
        {* Map sortKey → column index for DataTables order() call. *}
        {if $sortKey == 'date'}{assign var=sortColIdx value=1}
        {elseif $sortKey == 'due'}{assign var=sortColIdx value=2}
        {elseif $sortKey == 'amount'}{assign var=sortColIdx value=3}
        {elseif $sortKey == 'status'}{assign var=sortColIdx value=4}
        {else}{assign var=sortColIdx value=0}
        {/if}

        <div class="inv-stack">

            <div class="card inv-table-card">

                {* Empty state *}
                <div class="when-empty inv-empty">
                    <div class="inv-empty-ico">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><rect x="1" y="4" width="22" height="16" rx="2"/><line x1="1" y1="10" x2="23" y2="10"/></svg>
                    </div>
                    <p class="inv-empty-title">{$LANG.noinvoices|default:'No invoices yet'}</p>
                    <p class="inv-empty-sub">{$LANG.noinvoicessub|default:'When you purchase a service or a new billing cycle begins, your invoices will appear here.'}</p>
                    <a href="{$WEB_ROOT}/cart.php" class="btn-secondary">{$LANG.browseservices|default:'Browse services'}</a>
                </div>

                {if $invCount > 0}
                <table class="inv-table when-full" id="invTable"{if $mtAjaxTables} data-mt-action="tableInvoices" data-mt-type="invoices" data-mt-endpoint="{$WEB_ROOT}/clientarea.php" data-mt-order="0:desc" data-mt-length="10"{/if}>
                    <colgroup>
                        <col class="inv-col-invoice">
                        <col class="inv-col-date">
                        <col class="inv-col-due">
                        <col class="inv-col-amount">
                        <col class="inv-col-status">
                        <col class="inv-col-actions">
                    </colgroup>
                    <thead>
                        <tr>
                            <th class="hl-invoice">{$LANG.invoicenum|default:'Invoice'} <span class="inv-sort-ico"></span></th>
                            <th class="hl-date">{$LANG.invoicedatecreated|default:'Date'} <span class="inv-sort-ico"></span></th>
                            <th class="hl-due">{$LANG.invoicedatedue|default:'Due date'} <span class="inv-sort-ico"></span></th>
                            <th class="hl-amount">{$LANG.amount|default:'Amount'} <span class="inv-sort-ico"></span></th>
                            <th class="hl-status">{$LANG.invoicesstatus|default:'Status'} <span class="inv-sort-ico"></span></th>
                            <th class="hl-actions" data-orderable="false" aria-hidden="true"></th>
                        </tr>
                    </thead>
                    <tbody>
                        {if !$mtAjaxTables}
                        {foreach $invList as $inv}
                        {* WHMCS returns $inv.status wrapped in <span class="textred">...</span>
                           when overdue — strip tags before using anywhere. *}
                        {assign var=invStatus value=$inv.status|strip_tags}
                        {assign var=invStatusLower value=$invStatus|lower}
                        {if isset($inv.invoicenum) && $inv.invoicenum}{assign var=invDisplayNum value=$inv.invoicenum}{else}{assign var=invDisplayNum value=$inv.id}{/if}
                        {* Raw sort values for DataTables — each <td data-order="..."> carries
                           the value used for sort comparisons, separate from the formatted
                           display. _sort_*_raw / _sort_amount come from Hooks::fetchAllInvoices;
                           fall back to display values if a different data source omits them. *}
                        {assign var=sortDateRaw value=$inv._sort_date_raw|default:$inv.datecreated|default:''}
                        {assign var=sortDueRaw  value=$inv._sort_due_raw|default:$inv.duedate|default:''}
                        {assign var=sortAmount  value=$inv._sort_amount|default:0}
                        <tr data-href="{$WEB_ROOT}/viewinvoice.php?id={$inv.id}">
                            <td data-order="{$inv.id}">
                                <div class="inv-id-cell">
                                    <div class="inv-id-ico"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><rect x="1" y="4" width="22" height="16" rx="2"/><line x1="1" y1="10" x2="23" y2="10"/></svg></div>
                                    <span class="inv-id-num">#{$invDisplayNum|escape}</span>
                                </div>
                            </td>
                            <td class="date" data-order="{$sortDateRaw|escape:'html'}">{$inv.datecreated|escape}</td>
                            <td class="date" data-order="{$sortDueRaw|escape:'html'}">{$inv.duedate|escape}</td>
                            <td class="amount{if $invStatusLower == 'unpaid' || $invStatusLower == 'overdue'} due{/if}" data-order="{$sortAmount}">{$inv.total|escape}</td>
                            <td data-order="{$invStatusLower|escape:'html'}"><span class="status-pill {$invStatusLower}">{$invStatus|escape}</span></td>
                            <td class="actions">
                                <div class="inv-menu-wrap" onclick="event.stopPropagation();">
                                    <button type="button" class="inv-menu-btn" aria-label="{$LANG.actions|default:'Actions'}" aria-haspopup="true" aria-expanded="false" onclick="toggleInvMenu(this, event)">
                                        <svg viewBox="0 0 24 24" fill="currentColor"><circle cx="5" cy="12" r="2"/><circle cx="12" cy="12" r="2"/><circle cx="19" cy="12" r="2"/></svg>
                                    </button>
                                    <div class="inv-menu" role="menu">
                                        <a href="{$WEB_ROOT}/viewinvoice.php?id={$inv.id}" class="inv-menu-item" role="menuitem">
                                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/><circle cx="12" cy="12" r="3"/></svg>
                                            {$LANG.invoiceview|default:'View Invoice'}
                                        </a>
                                        <a href="{$WEB_ROOT}/dl.php?type=i&id={$inv.id}" class="inv-menu-item" role="menuitem">
                                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M21 15v4a2 2 0 01-2 2H5a2 2 0 01-2-2v-4"/><polyline points="7 10 12 15 17 10"/><line x1="12" y1="15" x2="12" y2="3"/></svg>
                                            {$LANG.invoicedownload|default:'Download PDF'}
                                        </a>
                                        {if $invStatusLower == 'unpaid' || $invStatusLower == 'overdue'}
                                        <a href="{$WEB_ROOT}/viewinvoice.php?id={$inv.id}" class="inv-menu-item" role="menuitem">
                                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><rect x="2" y="5" width="20" height="14" rx="2"/><path d="M2 10h20"/></svg>
                                            {$LANG.invoicepay|default:'Pay Invoice'}
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

            <div class="inv-footer when-full">
                <div class="inv-page-size">
                    {$LANG.show|default:'Show'}
                    <select aria-label="{$LANG.rowsperpage|default:'Rows per page'}" data-dt-length data-mt-for="invTable">
                        <option>10</option>
                        <option>25</option>
                        <option>50</option>
                    </select>
                    {$LANG.entries|default:'entries'}
                </div>
                <div class="spacer"></div>
                {assign var=startNum value=$startnumber|default:0}
                {assign var=startDisplay value=$startNum+1}
                {assign var=endDisplay value=$startNum+$invCount}
                {assign var=totalNum value=$numinvoices|default:$invCount}
                <span data-dt-info data-mt-for="invTable">{$LANG.showing|default:'Showing'} {$startDisplay}–{$endDisplay} {$LANG.of|default:'of'} {$totalNum}</span>
                <div class="inv-pages" data-dt-pager data-mt-for="invTable">
                    <button type="button" disabled aria-label="{$LANG.previouspage|default:'Previous page'}"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="15 18 9 12 15 6"/></svg></button>
                    <button type="button" class="active">1</button>
                    <button type="button" disabled aria-label="{$LANG.nextpage|default:'Next page'}"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="9 18 15 12 9 6"/></svg></button>
                </div>
            </div>

        </div>{* /.inv-stack *}
    </div>

    {* ══ RIGHT: Billing sub-nav ══ *}
    <aside>
        <div class="card subnav-card">
            <div class="subnav-heading">{$LANG.billing|default:'Billing'}</div>
            <a href="{$WEB_ROOT}/clientarea.php?action=invoices" class="subnav-item active">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><rect x="1" y="4" width="22" height="16" rx="2"/><line x1="1" y1="10" x2="23" y2="10"/></svg>
                {$LANG.myinvoices|default:'My Invoices'}
                <span class="subnav-count">{$invCount}</span>
            </a>
            <a href="{$WEB_ROOT}/clientarea.php?action=quotes" class="subnav-item">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M14 2H6a2 2 0 00-2 2v16a2 2 0 002 2h12a2 2 0 002-2V8z"/><polyline points="14 2 14 8 20 8"/><line x1="9" y1="13" x2="15" y2="13"/><line x1="9" y1="17" x2="15" y2="17"/></svg>
                {$LANG.myquotes|default:'My Quotes'}
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
</div>{* /.inv-split *}

{if !$mtAjaxTables}
<script>
{literal}
// Row navigation — clicking a row goes to viewinvoice
document.addEventListener('DOMContentLoaded', function () {
    document.querySelectorAll('.inv-table tbody tr[data-href]').forEach(function (row) {
        row.setAttribute('tabindex', '0');
        row.setAttribute('role', 'link');
        row.addEventListener('click', function (e) {
            if (e.target.closest('a, button, input, select, .inv-menu-wrap')) return;
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
function toggleInvMenu(btn, e) {
    if (e) { e.preventDefault(); e.stopPropagation(); }
    var wrap = btn.closest('.inv-menu-wrap');
    var wasOpen = wrap.classList.contains('open');
    document.querySelectorAll('.inv-menu-wrap.open').forEach(function (w) {
        w.classList.remove('open');
        var b = w.querySelector('.inv-menu-btn');
        if (b) b.setAttribute('aria-expanded', 'false');
    });
    if (!wasOpen) {
        wrap.classList.add('open');
        btn.setAttribute('aria-expanded', 'true');
    }
}
document.addEventListener('click', function (e) {
    if (e.target.closest('.inv-menu-wrap')) return;
    document.querySelectorAll('.inv-menu-wrap.open').forEach(function (w) {
        w.classList.remove('open');
        var b = w.querySelector('.inv-menu-btn');
        if (b) b.setAttribute('aria-expanded', 'false');
    });
});
document.addEventListener('keydown', function (e) {
    if (e.key !== 'Escape') return;
    document.querySelectorAll('.inv-menu-wrap.open').forEach(function (w) {
        w.classList.remove('open');
        var b = w.querySelector('.inv-menu-btn');
        if (b) b.setAttribute('aria-expanded', 'false');
    });
});

{/literal}

// DataTables init — Lagom-style instant sort (no page reload, no custom JS engine).
// Initial sort column + direction come from the server-side URL params so the
// active-column indicator matches the data on first paint.
{literal}
if (typeof jQuery !== 'undefined' && jQuery.fn.DataTable) {
    jQuery(function ($) {
        var $tbl = $('#invTable');
        if (!$tbl.length) return;
        var table = $tbl.DataTable({
            paging:    false,
            searching: false,
            info:      false,
            autoWidth: false,
            ordering:  true,
{/literal}
            order:     [[{$sortColIdx}, '{$sortDir|lower}']],
{literal}
            columnDefs: [
                { orderable: false, targets: -1 }
            ]
        });
        // Map column index → URL param key so we can sync ?orderby=… after each sort.
        var keyByCol = { 0: 'id', 1: 'date', 2: 'due', 3: 'amount', 4: 'status' };
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
            } catch (err) { /* old browsers — ignore */ }
        });
    });
}
{/literal}
</script>
{/if}
