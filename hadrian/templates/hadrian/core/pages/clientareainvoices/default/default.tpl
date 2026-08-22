{* Hostnodes — My Invoices list.

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
{assign var=mtAjaxTables value=$hadrian.addonSettings.enable_dynamic_ajax|default:false}

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
<link rel="stylesheet" href="{$WEB_ROOT}/templates/{$template}/assets/css/pages/clientareainvoices.css?v={$hadrian.version|default:'1.0'}">

{* Unified list-table engine (client-side + Dynamic AJAX Loading) — loaded once. *}
{include file="`$template`/includes/partials/list-table-assets.tpl"}

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
            <h1>{$LANG.navinvoices}</h1>
            <p class="page-subtitle">{$hadrianLang.billing.invoicesSubtitle}</p>
        </div>
        {if $unpaidCount > 0}
        <a href="{$WEB_ROOT}/clientarea.php?action=masspay&all=true" class="page-header-action when-full">
            {$hadrianLang.billing.payAllUnpaid}
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
            <span><strong>{$unpaidCount} {if $unpaidCount == 1}{$hadrianLang.billing.unpaidInvoiceSingular}{else}{$hadrianLang.billing.unpaidInvoicePlural}{/if}</strong>.</span>
            <span class="spacer"></span>
            <a href="{$WEB_ROOT}/clientarea.php?action=masspay&all=true" class="btn-secondary">{$LANG.paynow|default:'Pay now'}</a>
        </div>
        {/if}

        <div class="filter-tabs when-full">
            <a href="{$WEB_ROOT}/clientarea.php?action=invoices" class="filter-tab{if !$currentFilter} active{/if}" data-mt-for="invTable" data-mt-filter="">{$hadrianLang.common.filterAll}</a>
            <a href="{$WEB_ROOT}/clientarea.php?action=invoices&status=Unpaid" class="filter-tab{if $currentFilter == 'Unpaid'} active{/if}" data-mt-for="invTable" data-mt-filter="Unpaid">{$LANG.invoicesunpaid}</a>
            <a href="{$WEB_ROOT}/clientarea.php?action=invoices&status=Paid" class="filter-tab{if $currentFilter == 'Paid'} active{/if}" data-mt-for="invTable" data-mt-filter="Paid">{$LANG.invoicespaid}</a>
            <a href="{$WEB_ROOT}/clientarea.php?action=invoices&status=Cancelled" class="filter-tab{if $currentFilter == 'Cancelled'} active{/if}" data-mt-for="invTable" data-mt-filter="Cancelled">{$LANG.invoicescancelled}</a>
            <span class="inv-search"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="11" cy="11" r="7"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg><input type="search" placeholder="{$LANG.search}…" aria-label="{$LANG.search}" data-mt-search data-mt-for="invTable"></span>
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
                    <p class="inv-empty-title">{$hadrianLang.billing.noInvoicesTitle}</p>
                    <p class="inv-empty-sub">{$hadrianLang.billing.noInvoicesSub}</p>
                    <a href="{$WEB_ROOT}/cart.php" class="btn-secondary">{$hadrianLang.billing.browseServices}</a>
                </div>

                {if $invCount > 0}
                <table class="inv-table when-full" id="invTable" data-mt-type="invoices" data-mt-order="{$sortColIdx}:{$sortDir|lower}" data-mt-length="10" data-mt-filter-col="4"{if $mtAjaxTables} data-mt-action="tableInvoices" data-mt-endpoint="{$WEB_ROOT}/clientarea.php"{/if}>
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
                            <th class="hl-invoice">{$LANG.invoicestitle} <span class="inv-sort-ico"></span></th>
                            <th class="hl-date">{$LANG.invoicesdatecreated} <span class="inv-sort-ico"></span></th>
                            <th class="hl-due">{$LANG.invoicesdatedue} <span class="inv-sort-ico"></span></th>
                            <th class="hl-amount">{$LANG.invoicesamount} <span class="inv-sort-ico"></span></th>
                            <th class="hl-status">{$LANG.invoicesstatus} <span class="inv-sort-ico"></span></th>
                            <th class="hl-actions" data-mt-noorder aria-hidden="true"></th>
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
                                <div class="inv-menu-wrap" data-mt-kebab>
                                    <button type="button" class="inv-menu-btn" aria-label="{$LANG.actions}" aria-haspopup="true" aria-expanded="false" data-mt-kebab-btn>
                                        <svg viewBox="0 0 24 24" fill="currentColor"><circle cx="5" cy="12" r="2"/><circle cx="12" cy="12" r="2"/><circle cx="19" cy="12" r="2"/></svg>
                                    </button>
                                    <div class="inv-menu" role="menu">
                                        <a href="{$WEB_ROOT}/viewinvoice.php?id={$inv.id}" class="inv-menu-item" role="menuitem">
                                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/><circle cx="12" cy="12" r="3"/></svg>
                                            {$hadrianLang.billing.viewInvoice}
                                        </a>
                                        <a href="{$WEB_ROOT}/dl.php?type=i&id={$inv.id}" class="inv-menu-item" role="menuitem">
                                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M21 15v4a2 2 0 01-2 2H5a2 2 0 01-2-2v-4"/><polyline points="7 10 12 15 17 10"/><line x1="12" y1="15" x2="12" y2="3"/></svg>
                                            {$LANG.invoicesdownload}
                                        </a>
                                        {if $invStatusLower == 'unpaid' || $invStatusLower == 'overdue'}
                                        <a href="{$WEB_ROOT}/viewinvoice.php?id={$inv.id}" class="inv-menu-item" role="menuitem">
                                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><rect x="2" y="5" width="20" height="14" rx="2"/><path d="M2 10h20"/></svg>
                                            {$hadrianLang.billing.payInvoice}
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
                    {$hadrianLang.common.tableShow}
                    <select aria-label="{$hadrianLang.common.rowsPerPage}" data-dt-length data-mt-for="invTable">
                        <option>10</option>
                        <option>25</option>
                        <option>50</option>
                    </select>
                    {$hadrianLang.common.tableEntries}
                </div>
                <div class="spacer"></div>
                {assign var=startNum value=$startnumber|default:0}
                {assign var=startDisplay value=$startNum+1}
                {assign var=endDisplay value=$startNum+$invCount}
                {assign var=totalNum value=$numinvoices|default:$invCount}
                <span data-dt-info data-mt-for="invTable">{$hadrianLang.common.tableShowing} {$startDisplay}–{$endDisplay} {$hadrianLang.common.tableOf} {$totalNum}</span>
                <div class="inv-pages" data-dt-pager data-mt-for="invTable">
                    <button type="button" disabled aria-label="{$hadrianLang.common.previousPage}"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="15 18 9 12 15 6"/></svg></button>
                    <button type="button" class="active">1</button>
                    <button type="button" disabled aria-label="{$hadrianLang.common.nextPage}"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="9 18 15 12 9 6"/></svg></button>
                </div>
            </div>

        </div>{* /.inv-stack *}
    </div>

    {* ══ RIGHT: Billing sub-nav ══ *}
    <aside>
        <div class="card subnav-card">
            <div class="subnav-heading">{$hadrianLang.billing.sidebarHeading}</div>
            <a href="{$WEB_ROOT}/clientarea.php?action=invoices" class="subnav-item active">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><rect x="1" y="4" width="22" height="16" rx="2"/><line x1="1" y1="10" x2="23" y2="10"/></svg>
                {$LANG.navinvoices}
                <span class="subnav-count">{$invCount}</span>
            </a>
            <a href="{$WEB_ROOT}/clientarea.php?action=quotes" class="subnav-item">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M14 2H6a2 2 0 00-2 2v16a2 2 0 002 2h12a2 2 0 002-2V8z"/><polyline points="14 2 14 8 20 8"/><line x1="9" y1="13" x2="15" y2="13"/><line x1="9" y1="17" x2="15" y2="17"/></svg>
                {$LANG.navquotes|default:'Quotes'}
            </a>
            <a href="{$WEB_ROOT}/clientarea.php?action=masspay&all=true" class="subnav-item">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><rect x="2" y="5" width="20" height="14" rx="2"/><path d="M2 10h20"/><path d="M6 15h4"/></svg>
                {$LANG.masspaytitle}
            </a>
            <a href="{$WEB_ROOT}/clientarea.php?action=addfunds" class="subnav-item">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="16"/><line x1="8" y1="12" x2="16" y2="12"/></svg>
                {$LANG.addfunds}
            </a>
            <a href="{routePath('account-paymentmethods')}" class="subnav-item">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><rect x="2" y="5" width="20" height="14" rx="2"/><path d="M2 10h20"/></svg>
                {$LANG.paymentMethods.title}
            </a>
        </div>
    </aside>
</div>{* /.inv-split *}
