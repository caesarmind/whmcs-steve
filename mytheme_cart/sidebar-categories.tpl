{*
 * mytheme_cart/sidebar-categories.tpl — Categories + Actions sidebar.
 *
 * A reusable partial that mirrors the sidebar built into products.tpl.
 * Any cart-flow TPL that wants the same 240px left rail (e.g. a
 * future bundle.tpl, an addon listing, a custom landing) can do:
 *
 *   {include file="orderforms/$carttpl/sidebar-categories.tpl"}
 *
 * Available Smarty variables:
 *   $productgroups  — all groups for the Categories list
 *   $productgroup   — current group (for the "active" highlight)
 *   $cartcount      — for the View-Cart badge
 *   $WEB_ROOT, $carttpl
 *
 * Wrap your container in .st-split (`grid-template-columns: 240px 1fr`)
 * for the layout to read correctly. The styles for .subnav-card,
 * .subnav-item etc. live in css/style.min.css.
 *}

<aside>
    {* Categories list *}
    <div class="card subnav-card">
        <div class="subnav-heading">{lang key='store.categories'|default:'Categories'}</div>
        {if $productgroups && count($productgroups) > 0}
            {foreach $productgroups as $cat}
                <a href="{$WEB_ROOT}/cart.php?gid={$cat.id|escape}"
                   class="subnav-item{if $cat.id == $productgroup->id} active{/if}">
                    {if $cat.image}
                        <img src="{$cat.image|escape}" alt="" style="width:14px;height:14px;object-fit:contain;">
                    {else}
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M21 16V8a2 2 0 00-1-1.73l-7-4a2 2 0 00-2 0l-7 4A2 2 0 003 8v8a2 2 0 001 1.73l7 4a2 2 0 002 0l7-4A2 2 0 0021 16z"/><polyline points="3.27 6.96 12 12.01 20.73 6.96"/><line x1="12" y1="22.08" x2="12" y2="12"/></svg>
                    {/if}
                    {$cat.name|escape}
                </a>
            {/foreach}
        {/if}
    </div>

    {* Actions block *}
    <div class="card subnav-card" style="margin-top: 12px;">
        <div class="subnav-heading">{lang key='store.actions'|default:'Actions'}</div>
        <a href="{$WEB_ROOT}/clientarea.php?action=domains" class="subnav-item">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M21 12a9 9 0 11-9-9c2.52 0 4.82.99 6.5 2.6"/><polyline points="22 4 22 10 16 10"/></svg>
            {lang key='store.renewdomains'|default:'Renew Domains'}
        </a>
        <a href="{$WEB_ROOT}/cart.php?a=add&domain=register" class="subnav-item">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="2" y1="12" x2="22" y2="12"/><path d="M12 2a15.3 15.3 0 014 10 15.3 15.3 0 01-4 10 15.3 15.3 0 01-4-10 15.3 15.3 0 014-10z"/></svg>
            {lang key='store.registerdomain'|default:'Register a New Domain'}
        </a>
        <a href="{$WEB_ROOT}/cart.php?a=add&domain=transfer" class="subnav-item">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M10 13a5 5 0 007.54.54l3-3a5 5 0 00-7.07-7.07l-1.72 1.71"/><path d="M14 11a5 5 0 00-7.54-.54l-3 3a5 5 0 007.07 7.07l1.71-1.71"/></svg>
            {lang key='store.transferdomain'|default:'Transfer in a Domain'}
        </a>
        <div class="subnav-divider"></div>
        <a href="{$WEB_ROOT}/cart.php?a=view" class="subnav-item">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="9" cy="21" r="1"/><circle cx="20" cy="21" r="1"/><path d="M1 1h4l2.68 13.39a2 2 0 002 1.61h9.72a2 2 0 002-1.61L23 6H6"/></svg>
            {lang key='store.viewcart'|default:'View Cart'}
            {if $cartcount && $cartcount > 0}
                <span class="subnav-badge">{$cartcount}</span>
            {/if}
        </a>
    </div>
</aside>
