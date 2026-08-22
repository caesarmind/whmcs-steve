{* Hostnodes — My Products & Services (services table).

   WHMCS standard variables expected:
     $products        — array of associative arrays per service
                        Keys: id, name|productname, groupname, domain,
                              firstpaymentamount, recurringamount, billingcycle,
                              nextduedate, status, statusClass
     $statusFilter    — current filter (e.g. "Active") or empty for All
*}

{assign var=count_all value=0}
{assign var=count_active value=0}
{assign var=count_pending value=0}
{assign var=count_suspended value=0}
{assign var=count_terminated value=0}
{assign var=count_cancelled value=0}
{assign var=count_fraud value=0}

{* Prefer native $products from WHMCS; fall back to $mtProducts populated
   by Hooks::clientAreaPageProductsServices via localAPI. *}
{if isset($products) && $products|@count > 0}
    {assign var=svcList value=$products}
{elseif isset($mtProducts) && $mtProducts|@count > 0}
    {assign var=svcList value=$mtProducts}
{else}
    {assign var=svcList value=[]}
{/if}

{if $svcList|@count > 0}
    {assign var=count_all value=$svcList|@count}
    {foreach $svcList as $_p}
        {if $_p.status == 'Active'}{assign var=count_active value=$count_active+1}
        {elseif $_p.status == 'Pending'}{assign var=count_pending value=$count_pending+1}
        {elseif $_p.status == 'Suspended'}{assign var=count_suspended value=$count_suspended+1}
        {elseif $_p.status == 'Terminated'}{assign var=count_terminated value=$count_terminated+1}
        {elseif $_p.status == 'Cancelled'}{assign var=count_cancelled value=$count_cancelled+1}
        {elseif $_p.status == 'Fraud'}{assign var=count_fraud value=$count_fraud+1}
        {/if}
    {/foreach}
{/if}

{if $count_all == 0}{assign var=dashIsEmpty value='empty'}{else}{assign var=dashIsEmpty value='full'}{/if}
{assign var=currentFilter value=$statusFilter|default:''}

{* Dynamic AJAX Loading toggle (admin Settings -> enable_dynamic_ajax). When on,
   the table loads server-side in pages of 10 via dynamic-tables.js. *}
{assign var=mtAjaxTables value=$hadrian.addonSettings.enable_dynamic_ajax|default:false}

{* Page-specific stylesheet *}
<link rel="stylesheet" href="{$WEB_ROOT}/templates/{$template}/assets/css/pages/clientareaproducts.css?v={$hadrian.version|default:'1.0'}">
{* Unified list-table engine (client-side + Dynamic AJAX Loading) — loaded once. *}
{include file="`$template`/includes/partials/list-table-assets.tpl"}


{* Hand layout signals to body for CSS toggles *}
<script>
(function () {
    var b = document.body;
    if (!b) return;
    b.setAttribute('data-data', '{$dashIsEmpty}');
})();
</script>

<header class="page-header">
    <div class="page-header-row">
        <div style="flex: 1; min-width: 0;">
            <h1>{$LANG.productsservices|default:'Products & Services'}</h1>
            <p class="page-subtitle">{$hadrianLang.services.productsServicesSub}</p>
        </div>
        <a href="{$WEB_ROOT}/cart.php" class="page-header-action">
            {$hadrianLang.services.orderAService}
            <svg class="chev" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><polyline points="9 18 15 12 9 6"/></svg>
        </a>
    </div>
</header>

<div class="svc-split">
    {* ══ LEFT: banner + tabs + table + paging ══ *}
    <div class="svc-main">

        {if $count_all > 0}
        {* Renewal banner *}
        <div class="svc-banner">
            <span class="svc-banner-ico">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg>
            </span>
            <span><strong>{$count_all}</strong> {if $count_all == 1}{$hadrianLang.services.serviceLower}{else}{$hadrianLang.services.servicesLower}{/if} {$hadrianLang.services.onThisAccount}.</span>
            <span class="spacer"></span>
            <a href="{$WEB_ROOT}/clientarea.php?action=services" class="btn-secondary">{$LANG.viewall|default:'View All'}</a>
        </div>

        {* Filter tabs (pill-group, outside the card) *}
        {* Status tabs: show ALL + only statuses that have >=1 service. Prefer the
           reliable per-status counts from Hooks::clientAreaPageProductsServices
           (all services, independent of any ?status filter); fall back to the
           in-page tally if they're unavailable. *}
        {if isset($mtServiceStatusCounts)}
            {assign var=avActive value=$mtServiceStatusCounts.Active|default:0}
            {assign var=avPending value=$mtServiceStatusCounts.Pending|default:0}
            {assign var=avSuspended value=$mtServiceStatusCounts.Suspended|default:0}
            {assign var=avTerminated value=$mtServiceStatusCounts.Terminated|default:0}
            {assign var=avCancelled value=$mtServiceStatusCounts.Cancelled|default:0}
            {assign var=avFraud value=$mtServiceStatusCounts.Fraud|default:0}
        {else}
            {assign var=avActive value=$count_active}
            {assign var=avPending value=$count_pending}
            {assign var=avSuspended value=$count_suspended}
            {assign var=avTerminated value=$count_terminated}
            {assign var=avCancelled value=$count_cancelled}
            {assign var=avFraud value=$count_fraud}
        {/if}
        <div class="filter-tabs">
            <a href="{$WEB_ROOT}/clientarea.php?action=services" class="filter-tab{if !$currentFilter} active{/if}" data-mt-for="svcTable" data-mt-filter="">{$LANG.all}</a>
            {if $avActive > 0}<a href="{$WEB_ROOT}/clientarea.php?action=services&status=Active" class="filter-tab{if $currentFilter == 'Active'} active{/if}" data-mt-for="svcTable" data-mt-filter="Active">{$LANG.clientareaactive}</a>{/if}
            {if $avPending > 0}<a href="{$WEB_ROOT}/clientarea.php?action=services&status=Pending" class="filter-tab{if $currentFilter == 'Pending'} active{/if}" data-mt-for="svcTable" data-mt-filter="Pending">{$LANG.clientareapending}</a>{/if}
            {if $avSuspended > 0}<a href="{$WEB_ROOT}/clientarea.php?action=services&status=Suspended" class="filter-tab{if $currentFilter == 'Suspended'} active{/if}" data-mt-for="svcTable" data-mt-filter="Suspended">{$LANG.clientareasuspended}</a>{/if}
            {if $avTerminated > 0}<a href="{$WEB_ROOT}/clientarea.php?action=services&status=Terminated" class="filter-tab{if $currentFilter == 'Terminated'} active{/if}" data-mt-for="svcTable" data-mt-filter="Terminated">{$LANG.clientareaterminated}</a>{/if}
            {if $avCancelled > 0}<a href="{$WEB_ROOT}/clientarea.php?action=services&status=Cancelled" class="filter-tab{if $currentFilter == 'Cancelled'} active{/if}" data-mt-for="svcTable" data-mt-filter="Cancelled">{$LANG.clientareacancelled}</a>{/if}
            {if $avFraud > 0}<a href="{$WEB_ROOT}/clientarea.php?action=services&status=Fraud" class="filter-tab{if $currentFilter == 'Fraud'} active{/if}" data-mt-for="svcTable" data-mt-filter="Fraud">{$LANG.clientareafraud}</a>{/if}
            <span class="mt-list-search"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="11" cy="11" r="7"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg><input type="search" placeholder="{$LANG.search}…" aria-label="{$LANG.search}" data-mt-search data-mt-for="svcTable"></span>
        </div>

        {* Services stack: in "inside" mode it renders as one unified white card;
             in "outside" mode each child (titles, card, pager) floats on the page. *}
        <div class="svc-stack">

            {* Column titles (floating outside in "outside" mode, part of the card in "inside") *}
            <div class="svc-table-head-row">
                <div class="hl-cell hl-name"><button type="button" class="svc-sort" data-sort="name" data-dir="">{$hadrianLang.services.colName} <span class="svc-sort-ico"></span></button></div>
                <div class="hl-cell hl-pricing"><button type="button" class="svc-sort" data-sort="price" data-dir="">{$LANG.clientareaaddonpricing} <span class="svc-sort-ico"></span></button></div>
                <div class="hl-cell hl-due"><button type="button" class="svc-sort" data-sort="due" data-dir="">{$LANG.clientareahostingnextduedate} <span class="svc-sort-ico"></span></button></div>
                <div class="hl-cell hl-status"><button type="button" class="svc-sort" data-sort="status" data-dir="">{$LANG.clientareastatus} <span class="svc-sort-ico"></span></button></div>
                <div class="hl-cell hl-actions"></div>
            </div>

            {* Services card — wraps the table *}
            <div class="card svc-table-card">
                <div>
                    <table class="svc-table" id="svcTable" data-mt-type="services" data-mt-order="0:asc" data-mt-length="10" data-mt-filter-col="3"{if $mtAjaxTables} data-mt-action="tableServices" data-mt-endpoint="{$WEB_ROOT}/clientarea.php"{/if}>
                        <colgroup>
                            <col class="svc-col-product">
                            <col class="svc-col-pricing">
                            <col class="svc-col-due">
                            <col class="svc-col-status">
                            <col class="svc-col-actions">
                        </colgroup>
                        <thead>
                            <tr>
                                <th scope="col"><button type="button" class="svc-sort" data-sort="product" data-dir="">{$LANG.orderproduct} <span class="svc-sort-ico"></span></button></th>
                                <th scope="col"><button type="button" class="svc-sort" data-sort="price" data-dir="">{$LANG.clientareaaddonpricing} <span class="svc-sort-ico"></span></button></th>
                                <th scope="col"><button type="button" class="svc-sort" data-sort="due" data-dir="">{$LANG.clientareahostingnextduedate} <span class="svc-sort-ico"></span></button></th>
                                <th scope="col"><button type="button" class="svc-sort" data-sort="status" data-dir="">{$LANG.clientareastatus} <span class="svc-sort-ico"></span></button></th>
                                <th scope="col" aria-label="{$LANG.actions}" data-mt-noorder></th>
                            </tr>
                        </thead>
                        <tbody>
                            {if !$mtAjaxTables}
                            {foreach $svcList as $product}
                            <tr data-href="{$WEB_ROOT}/clientarea.php?action=productdetails&id={$product.id}">
                                <td>
                                    <div class="svc-cell-product-info">
                                        <div class="svc-cell-product-name">
                                            {$product.groupname|default:$hadrianLang.services.serviceFallback|escape}{if $product.productname || $product.name} &mdash; {$product.productname|default:$product.name|escape}{/if}
                                        </div>
                                        <div class="svc-cell-product-domain">{$product.domain|default:'—'|escape}</div>
                                    </div>
                                </td>
                                <td data-order="{if $product.recurringamount}{$product.recurringamount|regex_replace:'/[^0-9.\-]/':''}{elseif $product.firstpaymentamount}{$product.firstpaymentamount|regex_replace:'/[^0-9.\-]/':''}{else}0{/if}">
                                    <div class="svc-cell-price-main">
                                        {* Price via the shared partial so the admin's "0.00" -> "Free"
                                           flag applies. The data-order sort key above deliberately keeps
                                           the raw numeric — relabelling it would strip to "" and sort
                                           free services wrong. *}
                                        {if $product.recurringamount}{include file="`$template`/includes/common/price.tpl" hPrice=$product.recurringamount}{elseif $product.firstpaymentamount}{include file="`$template`/includes/common/price.tpl" hPrice=$product.firstpaymentamount}{else}—{/if}
                                        {if $product.billingcycle}<span class="cycle">/{$product.billingcycle|escape}</span>{/if}
                                    </div>
                                </td>
                                <td>{$product.nextduedate|default:'—'|escape}</td>
                                {* WHMCS may wrap $product.status in <span class="textred">…</span>
                                   for some statuses — strip_tags before piping into a class attr
                                   or display, otherwise we end up with nested broken HTML. *}
                                {assign var=svcStatus value=$product.status|strip_tags|default:'Active'}
                                {assign var=svcStatusClass value=$product.statusClass|default:$svcStatus|lower}
                                <td><span class="status-pill {$svcStatusClass|escape}">{$svcStatus|escape}</span></td>
                                <td class="svc-cell-actions">
                                    <div class="svc-menu-wrap" data-mt-kebab>
                                        <button type="button" class="svc-menu-btn" aria-label="{$LANG.actions}" aria-haspopup="true" aria-expanded="false" data-mt-kebab-btn>
                                            <svg viewBox="0 0 24 24" fill="currentColor"><circle cx="5" cy="12" r="2"/><circle cx="12" cy="12" r="2"/><circle cx="19" cy="12" r="2"/></svg>
                                        </button>
                                        <div class="svc-menu" role="menu">
                                            <a href="{$WEB_ROOT}/clientarea.php?action=productdetails&id={$product.id}" class="svc-menu-item" role="menuitem">
                                                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M12 20h9"/><path d="M16.5 3.5a2.121 2.121 0 013 3L7 19l-4 1 1-4 12.5-12.5z"/></svg>
                                                {$LANG.manageproduct|default:'Manage Product'}
                                            </a>
                                            {* Gate Upgrade like productdetails: WHMCS sets $product.packagesupgrade
                                               per row on native service data (true only when this service has
                                               package upgrade/downgrade paths). If the flag is absent (localAPI
                                               fallback rows that don't carry it), keep showing it so a real
                                               upgrade option is never hidden. *}
                                            {if !isset($product.packagesupgrade) || $product.packagesupgrade}
                                            <a href="{$WEB_ROOT}/upgrade.php?type=package&id={$product.id}" class="svc-menu-item" role="menuitem">
                                                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><polyline points="17 11 12 6 7 11"/><polyline points="17 18 12 13 7 18"/></svg>
                                                {$LANG.upgrade}
                                            </a>
                                            {/if}
                                            <a href="{$WEB_ROOT}/clientarea.php?action=productdetails&id={$product.id}&modop=custom&a=Addons" class="svc-menu-item" role="menuitem">
                                                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
                                                {$LANG.viewavailableaddons|default:'View Available Addons'}
                                            </a>
                                            <a href="{$WEB_ROOT}/clientarea.php?action=cancel&id={$product.id}" class="svc-menu-item" role="menuitem">
                                                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="4.93" y1="4.93" x2="19.07" y2="19.07"/></svg>
                                                {$LANG.cancellationrequest|default:'Request Cancellation'}
                                            </a>
                                        </div>
                                    </div>
                                </td>
                            </tr>
                            {/foreach}
                            {/if}
                        </tbody>
                    </table>
                </div>
            </div>

            {* Pagination footer — floats outside in "outside" mode, part of the card in "inside" *}
            <div class="svc-footer">
                <div class="svc-page-size">
                    {$LANG.show|default:'Show'}
                    <select aria-label="{$hadrianLang.services.rowsPerPage}" data-dt-length data-mt-for="svcTable">
                        <option>10</option>
                        <option>25</option>
                        <option>50</option>
                    </select>
                    {$LANG.entries|default:'entries'}
                </div>
                <div class="spacer"></div>
                <span data-dt-info data-mt-for="svcTable">{$LANG.showing|default:'Showing'} 1&ndash;{$count_all} {$LANG.of|default:'of'} {$count_all}</span>
                <div class="svc-pages" data-dt-pager data-mt-for="svcTable">
                    <button type="button" disabled aria-label="{$hadrianLang.common.previousPage}"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="15 18 9 12 15 6"/></svg></button>
                    <button type="button" class="active">1</button>
                    <button type="button" disabled aria-label="{$hadrianLang.common.nextPage}"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="9 18 15 12 9 6"/></svg></button>
                </div>
            </div>

        </div>{* /.svc-stack *}

        {else}

        {* ─── EMPTY STATE ─── *}
        <div class="svc-stack">
            <div class="card svc-table-card">
                <div class="svc-empty">
                    <div class="svc-empty-ico">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><rect x="2" y="3" width="20" height="14" rx="2"/><path d="M8 21h8"/><path d="M12 17v4"/></svg>
                    </div>
                    <p class="svc-empty-title">{$hadrianLang.services.emptyTitle}</p>
                    <p class="svc-empty-sub">{$hadrianLang.services.emptySub}</p>
                    <a href="{$WEB_ROOT}/cart.php" class="btn-primary">{$hadrianLang.services.placeAnOrder}</a>
                </div>
            </div>
        </div>

        {/if}
    </div>

    {* ══ RIGHT: Services sub-nav ══ *}
    <aside>
        <div class="card subnav-card">
            <div class="subnav-heading">{$LANG.services|default:'Services'}</div>
            <a href="{$WEB_ROOT}/clientarea.php?action=services" class="subnav-item active">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><rect x="2" y="3" width="20" height="14" rx="2"/><path d="M8 21h8"/><path d="M12 17v4"/></svg>
                {$LANG.myservices|default:'My Services'}
                <span class="subnav-count">{$count_all}</span>
            </a>
            <a href="{$WEB_ROOT}/cart.php" class="subnav-item">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="9" cy="21" r="1"/><circle cx="20" cy="21" r="1"/><path d="M1 1h4l2.68 13.39a2 2 0 002 1.61h9.72a2 2 0 002-1.61L23 6H6"/></svg>
                {$LANG.ordernewservices|default:'Order New Services'}
            </a>
            <a href="{$WEB_ROOT}/cart.php?gid=addons" class="subnav-item">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
                {$LANG.viewavailableaddons|default:'View Available Addons'}
            </a>
            <a href="{$WEB_ROOT}/upgrade.php" class="subnav-item">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><polyline points="17 11 12 6 7 11"/><polyline points="17 18 12 13 7 18"/></svg>
                {$LANG.upgrade}
            </a>
        </div>
    </aside>
</div>

