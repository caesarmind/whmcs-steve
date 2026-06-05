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

{* Unified list-table engine (client-side + Dynamic AJAX Loading) — loaded once. *}
{include file="`$template`/includes/partials/list-table-assets.tpl"}

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
            <h1>{$LANG.navquotes|default:'Quotes'}</h1>
            <p class="page-subtitle">{$hadrianLang.billing.quotesSubtitle}</p>
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
            <span><strong>{$deliveredCount} {if $deliveredCount == 1}{$hadrianLang.billing.quoteDeliveredSingular}{else}{$hadrianLang.billing.quoteDeliveredPlural}{/if}</strong>.</span>
            <span class="spacer"></span>
        </div>
        {/if}

        <div class="filter-tabs when-full">
            <a href="{$WEB_ROOT}/clientarea.php?action=quotes" class="filter-tab{if !$currentFilter} active{/if}" data-mt-for="qtTable" data-mt-filter="">{$hadrianLang.common.filterAll}</a>
            <a href="{$WEB_ROOT}/clientarea.php?action=quotes&stage=Draft" class="filter-tab{if $currentFilter == 'Draft'} active{/if}" data-mt-for="qtTable" data-mt-filter="Draft">{$LANG.quotestagedraft|default:'Draft'}</a>
            <a href="{$WEB_ROOT}/clientarea.php?action=quotes&stage=Delivered" class="filter-tab{if $currentFilter == 'Delivered'} active{/if}" data-mt-for="qtTable" data-mt-filter="Delivered">{$LANG.quotestagedelivered}</a>
            <a href="{$WEB_ROOT}/clientarea.php?action=quotes&stage=Accepted" class="filter-tab{if $currentFilter == 'Accepted'} active{/if}" data-mt-for="qtTable" data-mt-filter="Accepted">{$LANG.quotestageaccepted}</a>
            <a href="{$WEB_ROOT}/clientarea.php?action=quotes&stage=Lost" class="filter-tab{if $currentFilter == 'Lost'} active{/if}" data-mt-for="qtTable" data-mt-filter="Lost">{$LANG.quotestagelost}</a>
            <span class="mt-list-search"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="11" cy="11" r="7"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg><input type="search" placeholder="{$LANG.search}…" aria-label="{$LANG.search}" data-mt-search data-mt-for="qtTable"></span>
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
                    <p class="q-empty-title">{$hadrianLang.billing.noQuotesTitle}</p>
                    <p class="q-empty-sub">{$hadrianLang.billing.noQuotesSub}</p>
                    <a href="{$WEB_ROOT}/contact.php" class="btn-secondary">{$hadrianLang.billing.contactSales}</a>
                </div>

                {if $qtCount > 0}
                <table class="q-table when-full" id="qtTable" data-mt-type="quotes" data-mt-order="{$sortColIdx}:{$sortDir|lower}" data-mt-length="10" data-mt-filter-col="4"{if $mtAjaxTables} data-mt-action="tableQuotes" data-mt-endpoint="{$WEB_ROOT}/clientarea.php"{/if}>
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
                            <th class="hl-quote">{$LANG.quotenumber} <span class="q-sort-ico"></span></th>
                            <th class="hl-date">{$LANG.quotedatecreated} <span class="q-sort-ico"></span></th>
                            <th class="hl-valid">{$LANG.quotevaliduntil} <span class="q-sort-ico"></span></th>
                            <th class="hl-amount">{$LANG.invoicesamount} <span class="q-sort-ico"></span></th>
                            <th class="hl-status">{$LANG.quotestage} <span class="q-sort-ico"></span></th>
                            <th class="hl-actions" data-mt-noorder aria-hidden="true"></th>
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
                                <div class="q-menu-wrap" data-mt-kebab>
                                    <button type="button" class="q-menu-btn" aria-label="{$LANG.actions}" aria-haspopup="true" aria-expanded="false" data-mt-kebab-btn>
                                        <svg viewBox="0 0 24 24" fill="currentColor"><circle cx="5" cy="12" r="2"/><circle cx="12" cy="12" r="2"/><circle cx="19" cy="12" r="2"/></svg>
                                    </button>
                                    <div class="q-menu" role="menu">
                                        <a href="{$WEB_ROOT}/viewquote.php?id={$qt.id}" class="q-menu-item" role="menuitem">
                                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/><circle cx="12" cy="12" r="3"/></svg>
                                            {$hadrianLang.billing.viewQuote}
                                        </a>
                                        <a href="{$WEB_ROOT}/dl.php?type=q&amp;id={$qt.id}" class="q-menu-item" role="menuitem">
                                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M21 15v4a2 2 0 01-2 2H5a2 2 0 01-2-2v-4"/><polyline points="7 10 12 15 17 10"/><line x1="12" y1="15" x2="12" y2="3"/></svg>
                                            {$LANG.quotedownload}
                                        </a>
                                        {if $qtStage == 'Delivered'}
                                        <a href="{$WEB_ROOT}/viewquote.php?id={$qt.id}&action=accept" class="q-menu-item" role="menuitem">
                                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"/></svg>
                                            {$LANG.quoteacceptbtn}
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
                    {$hadrianLang.common.tableShow}
                    <select aria-label="{$hadrianLang.common.rowsPerPage}" data-dt-length data-mt-for="qtTable">
                        <option>10</option>
                        <option>25</option>
                        <option>50</option>
                    </select>
                    {$hadrianLang.common.tableEntries}
                </div>
                <div class="spacer"></div>
                <span data-dt-info data-mt-for="qtTable">{$hadrianLang.common.tableShowing} 1–{$qtCount} {$hadrianLang.common.tableOf} {$numquotes|default:$qtCount}</span>
                <div class="q-pages" data-dt-pager data-mt-for="qtTable">
                    <button type="button" disabled aria-label="{$hadrianLang.common.previousPage}"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="15 18 9 12 15 6"/></svg></button>
                    <button type="button" class="active">1</button>
                    <button type="button" disabled aria-label="{$hadrianLang.common.nextPage}"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="9 18 15 12 9 6"/></svg></button>
                </div>
            </div>

        </div>{* /.q-stack *}
    </div>

    {* ══ RIGHT: Billing sub-nav (same as invoices) ══ *}
    <aside>
        <div class="card subnav-card">
            <div class="subnav-heading">{$hadrianLang.billing.sidebarHeading}</div>
            <a href="{$WEB_ROOT}/clientarea.php?action=invoices" class="subnav-item">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><rect x="1" y="4" width="22" height="16" rx="2"/><line x1="1" y1="10" x2="23" y2="10"/></svg>
                {$LANG.navinvoices}
            </a>
            <a href="{$WEB_ROOT}/clientarea.php?action=quotes" class="subnav-item active">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M14 2H6a2 2 0 00-2 2v16a2 2 0 002 2h12a2 2 0 002-2V8z"/><polyline points="14 2 14 8 20 8"/><line x1="9" y1="13" x2="15" y2="13"/><line x1="9" y1="17" x2="15" y2="17"/></svg>
                {$LANG.navquotes|default:'Quotes'}
                <span class="subnav-count">{$qtCount}</span>
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
</div>{* /.q-split *}
