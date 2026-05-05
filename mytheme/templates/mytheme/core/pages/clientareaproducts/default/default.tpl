{* Hostnodes — My Products & Services (Apple-style card grid).

   WHMCS standard variables expected:
     $products        — array of associative arrays per service
                        Keys: id, name|productname, groupname, domain,
                              firstpaymentamount, recurringamount, billingcycle,
                              nextduedate, status, statusClass
     $statusFilter    — current filter (e.g. "Active") or empty for All

   Variant config from $myTheme.pages.clientareaproducts.config:
     viewMode      — grid|list                 (default: grid)
     gridCols      — 2|3|4                     (default: 3)
     showFilters   — bool                      (default: true)
     showActions   — bool                      (default: true)
     showSearch    — bool                      (default: true)
     showPromo     — bool                      (default: false)
*}

{assign var=viewMode value='grid'}
{assign var=gridCols value='3'}
{assign var=showFilters value=true}
{assign var=showActions value=true}
{assign var=showSearch value=true}
{assign var=showPromo value=false}

{assign var=count_all value=0}
{assign var=count_active value=0}
{assign var=count_pending value=0}
{assign var=count_suspended value=0}
{assign var=count_terminated value=0}
{assign var=count_cancelled value=0}
{assign var=count_fraud value=0}
{if isset($products) && $products}
    {assign var=count_all value=$products|count}
    {foreach $products as $_p}
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

{* Icon palettes — cycle by index in the loop so each card gets a different colour *}
{assign var=icoPalettes value=['blue','purple','green','orange','red']}

{* Page-specific stylesheet *}
<link rel="stylesheet" href="{$WEB_ROOT}/templates/{$template}/assets/css/pages/clientareaproducts.css?v={$myTheme.version|default:'1.0'}">

{* Hand layout signals to body for CSS toggles *}
<script>
(function () {
    var b = document.body;
    if (!b) return;
    {if $showFilters}
    b.setAttribute('data-svc-filters', 'on');
    {else}
    b.setAttribute('data-svc-filters', 'off');
    {/if}
    b.setAttribute('data-data',        '{$dashIsEmpty}');
})();
</script>

<header class="page-header">
    <h1>{$LANG.productsservices|default:'My Products & Services'}</h1>
    <p class="page-subtitle">{$LANG.productsservicessub|default:'Manage the services on your account — filter by status, place new orders, or explore add-ons.'}</p>
</header>

<div class="svc-split">

    {* ══════════ LEFT: filters + actions ══════════ *}
    {if $showFilters || $showActions || $showPromo}
    <aside class="svc-aside">

        {if $showFilters}
        <div class="card filter-card">
            <div class="filter-heading">{$LANG.view|default:'View'}</div>
            <a href="{$WEB_ROOT}/clientarea.php?action=services" class="filter-item{if !$currentFilter} active{/if}">
                <span class="filter-item-label">{$LANG.all|default:'All'}</span>
                <span class="filter-item-count">{$count_all}</span>
            </a>
            <a href="{$WEB_ROOT}/clientarea.php?action=services&status=Active" class="filter-item{if $currentFilter == 'Active'} active{/if}">
                <span class="filter-item-label">{$LANG.statusactive|default:'Active'}</span>
                <span class="filter-item-count">{$count_active}</span>
            </a>
            <a href="{$WEB_ROOT}/clientarea.php?action=services&status=Pending" class="filter-item{if $currentFilter == 'Pending'} active{/if}">
                <span class="filter-item-label">{$LANG.statuspending|default:'Pending'}</span>
                <span class="filter-item-count">{$count_pending}</span>
            </a>
            <a href="{$WEB_ROOT}/clientarea.php?action=services&status=Suspended" class="filter-item{if $currentFilter == 'Suspended'} active{/if}">
                <span class="filter-item-label">{$LANG.statussuspended|default:'Suspended'}</span>
                <span class="filter-item-count">{$count_suspended}</span>
            </a>
            <a href="{$WEB_ROOT}/clientarea.php?action=services&status=Terminated" class="filter-item{if $currentFilter == 'Terminated'} active{/if}">
                <span class="filter-item-label">{$LANG.statusterminated|default:'Terminated'}</span>
                <span class="filter-item-count">{$count_terminated}</span>
            </a>
            <a href="{$WEB_ROOT}/clientarea.php?action=services&status=Cancelled" class="filter-item{if $currentFilter == 'Cancelled'} active{/if}">
                <span class="filter-item-label">{$LANG.statuscancelled|default:'Cancelled'}</span>
                <span class="filter-item-count">{$count_cancelled}</span>
            </a>
            {if $count_fraud > 0}
            <a href="{$WEB_ROOT}/clientarea.php?action=services&status=Fraud" class="filter-item{if $currentFilter == 'Fraud'} active{/if}">
                <span class="filter-item-label">{$LANG.statusfraud|default:'Fraud'}</span>
                <span class="filter-item-count">{$count_fraud}</span>
            </a>
            {/if}
        </div>
        {/if}

        {if $showActions}
        <div class="card actions-card">
            <div class="filter-heading">{$LANG.actions|default:'Actions'}</div>
            <a href="{$WEB_ROOT}/cart.php" class="action-link">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="9" cy="21" r="1"/><circle cx="20" cy="21" r="1"/><path d="M1 1h4l2.68 13.39a2 2 0 002 1.61h9.72a2 2 0 002-1.61L23 6H6"/></svg>
                {$LANG.placeneworder|default:'Place a new order'}
            </a>
            <a href="{$WEB_ROOT}/cart.php?gid=addons" class="action-link">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
                {$LANG.viewavailableaddons|default:'View available addons'}
            </a>
        </div>
        {/if}

        {* promo-slider include removed (file_exists not supported) *}

    </aside>
    {/if}

    {* ══════════ RIGHT: toolbar + grid + paging ══════════ *}
    <div class="svc-main">

        {* Toolbar — Search + Add new *}
        {if $showSearch && $count_all > 0}
        <div class="svc-toolbar when-full">
            <div class="svc-search">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="11" cy="11" r="7"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>
                <input type="search" id="svcSearchInput" placeholder="{$LANG.searchservices|default:'Search services…'}" autocomplete="off" aria-label="{$LANG.searchservices|default:'Search services'}">
            </div>
            <div class="svc-toolbar-spacer"></div>
            <a href="{$WEB_ROOT}/cart.php" class="btn-primary">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
                {$LANG.addnew|default:'Add new'}
            </a>
        </div>
        {/if}

        {* ─── GRID VIEW ─── *}
        {if $viewMode != 'list' && $count_all > 0}
        <div class="svc-grid when-full" data-cols="{$gridCols|escape}">
            {foreach $products as $product}
                {assign var=_idx value=$product@index%5}
                {assign var=icoClass value=$icoPalettes[$_idx]}
                <a href="{$WEB_ROOT}/clientarea.php?action=productdetails&id={$product.id}" class="svc-card">
                    <div class="svc-card-top">
                        <div class="svc-card-ico {$icoClass}">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><rect x="2" y="3" width="20" height="14" rx="2"/><path d="M8 21h8"/><path d="M12 17v4"/></svg>
                        </div>
                        <div class="svc-card-head">
                            <h3 class="svc-card-name">
                                {$product.groupname|default:'Service'|escape}
                                {if $product.productname || $product.name}<span class="tier"> — {$product.productname|default:$product.name|escape}</span>{/if}
                            </h3>
                            <p class="svc-card-domain">{$product.domain|default:'—'|escape}</p>
                        </div>
                    </div>
                    <div class="svc-card-meta">
                        <div class="svc-card-meta-block">
                            <div class="svc-card-meta-label">{$LANG.pricing|default:'Pricing'}</div>
                            <div class="svc-card-meta-value">
                                {if $product.recurringamount}{$product.recurringamount}{elseif $product.firstpaymentamount}{$product.firstpaymentamount}{else}—{/if}
                                {if $product.billingcycle}<span class="cycle">{$product.billingcycle|escape}</span>{/if}
                            </div>
                        </div>
                        <div class="svc-card-meta-block">
                            <div class="svc-card-meta-label">{$LANG.nextduedate|default:'Next due'}</div>
                            <div class="svc-card-meta-value right">{$product.nextduedate|default:'—'|escape}</div>
                        </div>
                    </div>
                    <div class="svc-card-foot">
                        <span class="status-pill {$product.statusClass|default:$product.status|lower|escape}">{$product.status|escape|default:'Active'}</span>
                        <span class="svc-card-manage">
                            {$LANG.manageproduct|default:'Manage'}
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><polyline points="9 18 15 12 9 6"/></svg>
                        </span>
                    </div>
                </a>
            {/foreach}
        </div>
        {/if}

        {* ─── LIST VIEW ─── *}
        {if $viewMode == 'list' && $count_all > 0}
        <div class="svc-list when-full">
            {foreach $products as $product}
                {assign var=_idx value=$product@index%5}
                {assign var=icoClass value=$icoPalettes[$_idx]}
                <a href="{$WEB_ROOT}/clientarea.php?action=productdetails&id={$product.id}" class="svc-list-row">
                    <div class="svc-card-ico {$icoClass}">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><rect x="2" y="3" width="20" height="14" rx="2"/><path d="M8 21h8"/><path d="M12 17v4"/></svg>
                    </div>
                    <div class="svc-list-info">
                        <p class="svc-list-name">
                            {$product.groupname|default:'Service'|escape}
                            {if $product.productname || $product.name} — {$product.productname|default:$product.name|escape}{/if}
                        </p>
                        <p class="svc-list-domain">{$product.domain|default:'—'|escape}</p>
                    </div>
                    <div class="svc-list-due">{$product.nextduedate|default:'—'|escape}</div>
                    <div class="svc-list-status"><span class="status-pill {$product.statusClass|default:$product.status|lower|escape}">{$product.status|escape|default:'Active'}</span></div>
                    <svg class="svc-list-chev" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><polyline points="9 18 15 12 9 6"/></svg>
                </a>
            {/foreach}
        </div>
        {/if}

        {* ─── EMPTY STATE ─── *}
        <div class="when-empty svc-empty">
            <div class="svc-empty-ico">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><rect x="2" y="3" width="20" height="14" rx="2"/><path d="M8 21h8"/><path d="M12 17v4"/></svg>
            </div>
            <p class="svc-empty-title">{$LANG.noproductsactive|default:'No services yet'}</p>
            <p class="svc-empty-sub">{$LANG.noproductssub|default:"You don't have any products or services on this account. Browse our catalogue to get started."}</p>
            <a href="{$WEB_ROOT}/cart.php" class="btn-primary">{$LANG.placeanorder|default:'Place an order'}</a>
        </div>

        {* ─── PAGING (count summary) ─── *}
        {if $count_all > 0}
        <div class="svc-paging when-full">
            <span class="svc-paging-count">
                <strong>{$count_all}</strong>
                {if $count_all == 1}{$LANG.serviceLower|default:'service'}{else}{$LANG.servicesLower|default:'services'}{/if}
                {if $currentFilter} · {$LANG.filteredby|default:'filtered by'} <strong>{$currentFilter|escape}</strong>{/if}
            </span>
        </div>
        {/if}
    </div>
</div>

{* ─── Client-side search filtering ─── *}
{if $showSearch}
<script>
(function () {
    var input = document.getElementById('svcSearchInput');
    if (!input) return;
    var grid = document.querySelector('.svc-grid, .svc-list');
    if (!grid) return;
    var rows = grid.querySelectorAll('[data-search], .svc-list-row');
    input.addEventListener('input', function () {
        var q = (input.value || '').trim().toLowerCase();
        rows.forEach(function (row) {
            var hay = (row.getAttribute('data-search') || row.textContent || '').toLowerCase();
            row.style.display = (!q || hay.indexOf(q) !== -1) ? '' : 'none';
        });
    });
})();
</script>
{/if}
