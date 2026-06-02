{* Hostnodes — My Products & Services (Apple-style services table).

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
{assign var=mtAjaxTables value=$myTheme.addonSettings.enable_dynamic_ajax|default:false}

{* Page-specific stylesheet *}
<link rel="stylesheet" href="{$WEB_ROOT}/templates/{$template}/assets/css/pages/clientareaproducts.css?v={$myTheme.version|default:'1.0'}">
{if $mtAjaxTables}
<script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
<script src="https://cdn.datatables.net/1.13.11/js/jquery.dataTables.min.js"></script>
<script src="{$WEB_ROOT}/templates/{$template}/assets/js/dynamic-tables.js?v={$myTheme.version|default:'1.0'}"></script>
{/if}


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
            <h1>{$LANG.productsservices|default:'Services'}</h1>
            <p class="page-subtitle">{$LANG.productsservicessub|default:'Manage your active services, upgrades, and add-ons.'}</p>
        </div>
        <a href="{$WEB_ROOT}/cart.php" class="page-header-action">
            {$LANG.orderaservice|default:'Order a service'}
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
            <span><strong>{$count_all}</strong> {if $count_all == 1}{$LANG.serviceLower|default:'service'}{else}{$LANG.servicesLower|default:'services'}{/if} {$LANG.onthisaccount|default:'on this account'}.</span>
            <span class="spacer"></span>
            <a href="{$WEB_ROOT}/clientarea.php?action=services" class="btn-secondary">{$LANG.viewall|default:'View all'}</a>
        </div>

        {* Filter tabs (pill-group, outside the card) *}
        <div class="filter-tabs">
            <a href="{$WEB_ROOT}/clientarea.php?action=services" class="filter-tab{if !$currentFilter} active{/if}" data-mt-for="svcTable" data-mt-filter="">{$LANG.all|default:'All'}</a>
            <a href="{$WEB_ROOT}/clientarea.php?action=services&status=Active" class="filter-tab{if $currentFilter == 'Active'} active{/if}" data-mt-for="svcTable" data-mt-filter="Active">{$LANG.statusactive|default:'Active'}</a>
            <a href="{$WEB_ROOT}/clientarea.php?action=services&status=Pending" class="filter-tab{if $currentFilter == 'Pending'} active{/if}" data-mt-for="svcTable" data-mt-filter="Pending">{$LANG.statuspending|default:'Pending'}</a>
            <a href="{$WEB_ROOT}/clientarea.php?action=services&status=Suspended" class="filter-tab{if $currentFilter == 'Suspended'} active{/if}" data-mt-for="svcTable" data-mt-filter="Suspended">{$LANG.statussuspended|default:'Suspended'}</a>
            <a href="{$WEB_ROOT}/clientarea.php?action=services&status=Terminated" class="filter-tab{if $currentFilter == 'Terminated'} active{/if}" data-mt-for="svcTable" data-mt-filter="Terminated">{$LANG.statusterminated|default:'Terminated'}</a>
            <a href="{$WEB_ROOT}/clientarea.php?action=services&status=Cancelled" class="filter-tab{if $currentFilter == 'Cancelled'} active{/if}" data-mt-for="svcTable" data-mt-filter="Cancelled">{$LANG.statuscancelled|default:'Cancelled'}</a>
            {if $count_fraud > 0}
            <a href="{$WEB_ROOT}/clientarea.php?action=services&status=Fraud" class="filter-tab{if $currentFilter == 'Fraud'} active{/if}" data-mt-for="svcTable" data-mt-filter="Fraud">{$LANG.statusfraud|default:'Fraud'}</a>
            {/if}
            {if $mtAjaxTables}<span class="mt-dt-search" style="margin-left:auto"><input type="search" placeholder="{$LANG.search|default:'Search'}…" aria-label="{$LANG.search|default:'Search'}" data-mt-search data-mt-for="svcTable"></span>{/if}
        </div>

        {* Services stack: in "inside" mode it renders as one unified white card;
             in "outside" mode each child (titles, card, pager) floats on the page. *}
        <div class="svc-stack">

            {* Column titles (floating outside in "outside" mode, part of the card in "inside") *}
            <div class="svc-table-head-row">
                <div class="hl-cell hl-name"><button type="button" class="svc-sort" data-sort="name" data-dir="">Name <span class="svc-sort-ico"></span></button></div>
                <div class="hl-cell hl-pricing"><button type="button" class="svc-sort" data-sort="price" data-dir="">{$LANG.pricing|default:'Pricing'} <span class="svc-sort-ico"></span></button></div>
                <div class="hl-cell hl-due"><button type="button" class="svc-sort" data-sort="due" data-dir="">{$LANG.nextduedate|default:'Next due'} <span class="svc-sort-ico"></span></button></div>
                <div class="hl-cell hl-status"><button type="button" class="svc-sort" data-sort="status" data-dir="">{$LANG.status|default:'Status'} <span class="svc-sort-ico"></span></button></div>
                <div class="hl-cell hl-actions"></div>
            </div>

            {* Services card — wraps the table *}
            <div class="card svc-table-card">
                <div>
                    <table class="svc-table"{if $mtAjaxTables} id="svcTable" data-mt-action="tableServices" data-mt-type="services" data-mt-endpoint="{$WEB_ROOT}/clientarea.php" data-mt-order="0:asc" data-mt-length="10"{/if}>
                        <colgroup>
                            <col class="svc-col-product">
                            <col class="svc-col-pricing">
                            <col class="svc-col-due">
                            <col class="svc-col-status">
                            <col class="svc-col-actions">
                        </colgroup>
                        <thead>
                            <tr>
                                <th scope="col"><button type="button" class="svc-sort" data-sort="product" data-dir="">{$LANG.productservice|default:'Product / Service'} <span class="svc-sort-ico"></span></button></th>
                                <th scope="col"><button type="button" class="svc-sort" data-sort="price" data-dir="">{$LANG.pricing|default:'Pricing'} <span class="svc-sort-ico"></span></button></th>
                                <th scope="col"><button type="button" class="svc-sort" data-sort="due" data-dir="">{$LANG.nextduedate|default:'Next due'} <span class="svc-sort-ico"></span></button></th>
                                <th scope="col"><button type="button" class="svc-sort" data-sort="status" data-dir="">{$LANG.status|default:'Status'} <span class="svc-sort-ico"></span></button></th>
                                <th scope="col" aria-label="Actions"></th>
                            </tr>
                        </thead>
                        <tbody>
                            {if !$mtAjaxTables}
                            {foreach $svcList as $product}
                            <tr data-href="{$WEB_ROOT}/clientarea.php?action=productdetails&id={$product.id}">
                                <td>
                                    <div class="svc-cell-product-info">
                                        <div class="svc-cell-product-name">
                                            {$product.groupname|default:'Service'|escape}{if $product.productname || $product.name} &mdash; {$product.productname|default:$product.name|escape}{/if}
                                        </div>
                                        <div class="svc-cell-product-domain">{$product.domain|default:'—'|escape}</div>
                                    </div>
                                </td>
                                <td>
                                    <div class="svc-cell-price-main">
                                        {if $product.recurringamount}{$product.recurringamount}{elseif $product.firstpaymentamount}{$product.firstpaymentamount}{else}—{/if}
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
                                    <div class="svc-menu-wrap" onclick="event.stopPropagation();">
                                        <button type="button" class="svc-menu-btn" aria-label="Actions" aria-haspopup="true" aria-expanded="false" onclick="toggleSvcMenu(this, event)">
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
                                                Upgrade / Downgrade
                                            </a>
                                            {/if}
                                            <a href="{$WEB_ROOT}/clientarea.php?action=productdetails&id={$product.id}&modop=custom&a=Addons" class="svc-menu-item" role="menuitem">
                                                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
                                                {$LANG.viewavailableaddons|default:'View Addons'}
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
                    <select aria-label="Rows per page" data-dt-length data-mt-for="svcTable">
                        <option>10</option>
                        <option>25</option>
                        <option>50</option>
                    </select>
                    {$LANG.entries|default:'entries'}
                </div>
                <div class="spacer"></div>
                <span data-dt-info data-mt-for="svcTable">{$LANG.showing|default:'Showing'} 1&ndash;{$count_all} {$LANG.of|default:'of'} {$count_all}</span>
                <div class="svc-pages" data-dt-pager data-mt-for="svcTable">
                    <button type="button" disabled aria-label="Previous page"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="15 18 9 12 15 6"/></svg></button>
                    <button type="button" class="active">1</button>
                    <button type="button" disabled aria-label="Next page"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="9 18 15 12 9 6"/></svg></button>
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
                    <p class="svc-empty-title">{$LANG.noproductsactive|default:'No services yet'}</p>
                    <p class="svc-empty-sub">{$LANG.noproductssub|default:"You don't have any products or services on this account. Browse our catalogue to get started."}</p>
                    <a href="{$WEB_ROOT}/cart.php" class="btn-primary">{$LANG.placeanorder|default:'Place an order'}</a>
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
                Upgrade / Downgrade
            </a>
        </div>
    </aside>
</div>

{if !$mtAjaxTables}
<script>
// Row-level navigation — the whole .svc-table row is clickable to its data-href,
// while nested <a>/<button> elements keep their own behavior.
document.addEventListener('DOMContentLoaded', function () {
    document.querySelectorAll('.svc-table tbody tr[data-href]').forEach(function (row) {
        row.setAttribute('tabindex', '0');
        row.setAttribute('role', 'link');
        row.addEventListener('click', function (e) {
            if (e.target.closest('a, button, input, select, .svc-menu-wrap')) return;
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

// Kebab menu toggle for each service row
function toggleSvcMenu(btn, e) {
    if (e) { e.preventDefault(); e.stopPropagation(); }
    var wrap = btn.closest('.svc-menu-wrap');
    var wasOpen = wrap.classList.contains('open');
    document.querySelectorAll('.svc-menu-wrap.open').forEach(function (w) {
        w.classList.remove('open');
        var b = w.querySelector('.svc-menu-btn');
        if (b) b.setAttribute('aria-expanded', 'false');
    });
    if (!wasOpen) {
        wrap.classList.add('open');
        btn.setAttribute('aria-expanded', 'true');
    }
}
// Click outside / Escape closes any open menu
document.addEventListener('click', function (e) {
    if (e.target.closest('.svc-menu-wrap')) return;
    document.querySelectorAll('.svc-menu-wrap.open').forEach(function (w) {
        w.classList.remove('open');
        var b = w.querySelector('.svc-menu-btn');
        if (b) b.setAttribute('aria-expanded', 'false');
    });
});
document.addEventListener('keydown', function (e) {
    if (e.key === 'Escape') {
        document.querySelectorAll('.svc-menu-wrap.open').forEach(function (w) {
            w.classList.remove('open');
            var b = w.querySelector('.svc-menu-btn');
            if (b) b.setAttribute('aria-expanded', 'false');
        });
    }
});

// Sort cycle — click a header to toggle none → asc → desc → none
(function () {
    var sorts = document.querySelectorAll('.svc-sort');
    sorts.forEach(function (btn) {
        btn.addEventListener('click', function () {
            var dir = btn.getAttribute('data-dir');
            var next = dir === '' ? 'asc' : dir === 'asc' ? 'desc' : '';
            sorts.forEach(function (b) { b.setAttribute('data-dir', ''); b.classList.remove('active'); });
            btn.setAttribute('data-dir', next);
            if (next) btn.classList.add('active');
        });
    });
})();
</script>
{/if}
