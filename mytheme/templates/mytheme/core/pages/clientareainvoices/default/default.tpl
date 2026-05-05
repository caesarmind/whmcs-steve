{* Hostnodes — My Invoices list (Apple-style).

   WHMCS standard variables expected:
     $invoices         — array, each: id, invoicenum, datecreated, total, status,
                         statusClass, datepaid, duedate
     $statusFilter     — current filter (e.g. "Unpaid") or empty for All
     $startnumber      — pagination start offset
     $pagesize         — rows per page
     $numinvoices      — total invoice count
*}

{* Resolve totals + empty/full state *}
{if isset($invoices) && $invoices|count > 0}
    {assign var=dashIsEmpty value='full'}
    {assign var=invCount value=$invoices|count}
{else}
    {assign var=dashIsEmpty value='empty'}
    {assign var=invCount value=0}
{/if}

{assign var=currentFilter value=$statusFilter|default:''}

{* Tally unpaid amount *}
{assign var=unpaidCount value=0}
{assign var=unpaidTotal value=0}
{if isset($invoices) && $invoices|count > 0}
    {foreach $invoices as $_i}
        {if isset($_i.status) && ($_i.status == 'Unpaid' || $_i.status == 'Overdue')}
            {assign var=unpaidCount value=$unpaidCount+1}
        {/if}
    {/foreach}
{/if}

{* Page-specific stylesheet *}
<link rel="stylesheet" href="{$WEB_ROOT}/templates/{$template}/assets/css/pages/clientareainvoices.css?v={$myTheme.version|default:'1.0'}">

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
            <a href="{$WEB_ROOT}/clientarea.php?action=invoices" class="filter-tab{if !$currentFilter} active{/if}">{$LANG.all|default:'All'}</a>
            <a href="{$WEB_ROOT}/clientarea.php?action=invoices&status=Unpaid" class="filter-tab{if $currentFilter == 'Unpaid'} active{/if}">{$LANG.invoiceunpaid|default:'Unpaid'}</a>
            <a href="{$WEB_ROOT}/clientarea.php?action=invoices&status=Paid" class="filter-tab{if $currentFilter == 'Paid'} active{/if}">{$LANG.invoicepaid|default:'Paid'}</a>
            <a href="{$WEB_ROOT}/clientarea.php?action=invoices&status=Cancelled" class="filter-tab{if $currentFilter == 'Cancelled'} active{/if}">{$LANG.invoicecancelled|default:'Cancelled'}</a>
        </div>

        <div class="inv-stack">

            <div class="inv-table-head-row when-full">
                <div class="hl-cell hl-invoice"><button type="button" class="inv-sort active" data-sort="id" data-dir="desc">{$LANG.invoicenum|default:'Invoice'} <span class="inv-sort-ico"></span></button></div>
                <div class="hl-cell hl-date"><button type="button" class="inv-sort" data-sort="date" data-dir="">{$LANG.invoicedatecreated|default:'Date'} <span class="inv-sort-ico"></span></button></div>
                <div class="hl-cell hl-due"><button type="button" class="inv-sort" data-sort="due" data-dir="">{$LANG.invoicedatedue|default:'Due date'} <span class="inv-sort-ico"></span></button></div>
                <div class="hl-cell hl-amount"><button type="button" class="inv-sort" data-sort="amount" data-dir="">{$LANG.amount|default:'Amount'} <span class="inv-sort-ico"></span></button></div>
                <div class="hl-cell hl-status"><button type="button" class="inv-sort" data-sort="status" data-dir="">{$LANG.invoicesstatus|default:'Status'} <span class="inv-sort-ico"></span></button></div>
                <div class="hl-cell hl-actions" aria-hidden="true"></div>
            </div>

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

                {if isset($invoices) && $invoices|count > 0}
                <table class="inv-table when-full">
                    <colgroup>
                        <col class="inv-col-invoice">
                        <col class="inv-col-date">
                        <col class="inv-col-due">
                        <col class="inv-col-amount">
                        <col class="inv-col-status">
                        <col class="inv-col-actions">
                    </colgroup>
                    <tbody>
                        {foreach $invoices as $inv}
                        {assign var=invStatusLower value=$inv.status|lower}
                        {if isset($inv.invoicenum) && $inv.invoicenum}{assign var=invDisplayNum value=$inv.invoicenum}{else}{assign var=invDisplayNum value=$inv.id}{/if}
                        <tr data-href="{$WEB_ROOT}/viewinvoice.php?id={$inv.id}">
                            <td>
                                <div class="inv-id-cell">
                                    <div class="inv-id-ico"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><rect x="1" y="4" width="22" height="16" rx="2"/><line x1="1" y1="10" x2="23" y2="10"/></svg></div>
                                    <span class="inv-id-num">#{$invDisplayNum|escape}</span>
                                </div>
                            </td>
                            <td class="date">{$inv.datecreated|escape}</td>
                            <td class="date">{$inv.duedate|escape}</td>
                            <td class="amount{if $invStatusLower == 'unpaid' || $invStatusLower == 'overdue'} due{/if}">{$inv.total|escape}</td>
                            <td><span class="status-pill {$invStatusLower}">{$inv.status|escape}</span></td>
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
                    </tbody>
                </table>
                {/if}
            </div>

            <div class="inv-footer when-full">
                <div class="inv-page-size">
                    {$LANG.show|default:'Show'}
                    <select aria-label="{$LANG.rowsperpage|default:'Rows per page'}">
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
                <span>{$LANG.showing|default:'Showing'} {$startDisplay}–{$endDisplay} {$LANG.of|default:'of'} {$totalNum}</span>
                <div class="inv-pages">
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
            <a href="{$WEB_ROOT}/clientarea.php?action=paymentmethods" class="subnav-item">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><rect x="2" y="5" width="20" height="14" rx="2"/><path d="M2 10h20"/></svg>
                {$LANG.paymentmethods|default:'Payment Methods'}
            </a>
        </div>
    </aside>
</div>{* /.inv-split *}
