{*
 * hadrian_cart/sidebar-categories.tpl — Categories + Actions sidebar.
 *
 * Reads the WHMCS-built `$secondarySidebar` panel collection. Each
 * `$panel` is a Menu node with a label + children (each child is a
 * menu item with getUri(), getLabel(), getIcon(), isCurrent(),
 * hasBadge(), getBadge()).
 *
 * Why $secondarySidebar (not $productgroups):
 *   The "Categories" panel in $secondarySidebar contains every active
 *   product group with the correct isCurrent() state already set by
 *   WHMCS. The flat $productgroups collection may filter differently
 *   (e.g., based on the user's group visibility), and lacks per-item
 *   active state. Standard_cart uses $secondarySidebar too — see
 *   standard_cart/sidebar-categories.tpl. The "Actions" panel comes
 *   for free in the same loop (Renew Domains / Register / Transfer
 *   / View Cart with the cart-count badge).
 *
 * Fallback to $productgroups: if $secondarySidebar is somehow not
 * populated (defensive), we still render a Categories list from
 * $productgroups + a hardcoded Actions panel, so the page never
 * ships an empty sidebar.
 *
 * Icons: the partial outputs a single generic cube SVG per item,
 * regardless of $child->getIcon(). WHMCS exposes icons as FontAwesome
 * class names (e.g. "fas fa-cube"); we don't load FontAwesome on the
 * cart pages, so any class-based icon would render as empty. The cube
 * SVG is a neutral placeholder that visually balances the Apple
 * primitives. Per-category-name icon mapping can be layered on later.
 *}

{* Server-side gate for the admin "Order Category Sidebar" toggle. In production
   we skip the markup entirely when the order sub-nav is off; in preview we still
   render it so the dev chip can toggle it live. ($mt_subnavOrder / $mt_preview
   are set in hadrian's header.tpl, which wraps the cart pages.) *}
{if ($mt_preview|default:false) || ($mt_subnavOrder|default:'') != 'off'}
<aside>
    {if $secondarySidebar}
        {foreach $secondarySidebar as $panel}
            <div class="card subnav-card{if !$panel@first} subnav-card--gap{/if}">
                <div class="subnav-heading">{$panel->getLabel()|escape}</div>

                {if $panel->hasChildren()}
                    {foreach $panel->getChildren() as $child}
                        {if $child->getUri()}
                            <a href="{$child->getUri()}"
                               class="subnav-item{if $child->isCurrent()} active{/if}{if $child->isDisabled()} disabled{/if}"
                               id="{$child->getId()|escape}">
                                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M21 16V8a2 2 0 00-1-1.73l-7-4a2 2 0 00-2 0l-7 4A2 2 0 003 8v8a2 2 0 001 1.73l7 4a2 2 0 002 0l7-4A2 2 0 0021 16z"/><polyline points="3.27 6.96 12 12.01 20.73 6.96"/><line x1="12" y1="22.08" x2="12" y2="12"/></svg>
                                <span class="subnav-item-label">{$child->getLabel()|escape}</span>
                                {if $child->hasBadge()}
                                    <span class="subnav-badge">{$child->getBadge()|escape}</span>
                                {/if}
                            </a>
                        {else}
                            <div class="subnav-item subnav-item--static" id="{$child->getId()|escape}">
                                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M21 16V8a2 2 0 00-1-1.73l-7-4a2 2 0 00-2 0l-7 4A2 2 0 003 8v8a2 2 0 001 1.73l7 4a2 2 0 002 0l7-4A2 2 0 0021 16z"/><polyline points="3.27 6.96 12 12.01 20.73 6.96"/><line x1="12" y1="22.08" x2="12" y2="12"/></svg>
                                <span class="subnav-item-label">{$child->getLabel()|escape}</span>
                                {if $child->hasBadge()}
                                    <span class="subnav-badge">{$child->getBadge()|escape}</span>
                                {/if}
                            </div>
                        {/if}
                    {/foreach}
                {/if}
            </div>
        {/foreach}

    {else}
        {* ── Defensive fallback when $secondarySidebar is unavailable ── *}

        <div class="card subnav-card">
            <div class="subnav-heading">{$hadrianLang.cart.categories}</div>
            {if $productgroups}
                {foreach $productgroups as $cat}
                    <a href="{$WEB_ROOT}/cart.php?gid={$cat.id|default:$cat->id}"
                       class="subnav-item{if ($cat.id|default:$cat->id) == ($productgroup.id|default:$productgroup->id)} active{/if}">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M21 16V8a2 2 0 00-1-1.73l-7-4a2 2 0 00-2 0l-7 4A2 2 0 003 8v8a2 2 0 001 1.73l7 4a2 2 0 002 0l7-4A2 2 0 0021 16z"/><polyline points="3.27 6.96 12 12.01 20.73 6.96"/><line x1="12" y1="22.08" x2="12" y2="12"/></svg>
                        <span class="subnav-item-label">{$cat.name|default:$cat->name|escape}</span>
                    </a>
                {/foreach}
            {/if}
        </div>

        <div class="card subnav-card subnav-card--gap">
            <div class="subnav-heading">{$LANG.actions}</div>
            <a href="{$WEB_ROOT}/clientarea.php?action=domains" class="subnav-item">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M21 12a9 9 0 11-9-9c2.52 0 4.82.99 6.5 2.6"/><polyline points="22 4 22 10 16 10"/></svg>
                <span class="subnav-item-label">{$hadrianLang.cart.renewDomains}</span>
            </a>
            <a href="{$WEB_ROOT}/cart.php?a=add&domain=register" class="subnav-item">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="2" y1="12" x2="22" y2="12"/><path d="M12 2a15.3 15.3 0 014 10 15.3 15.3 0 01-4 10 15.3 15.3 0 01-4-10 15.3 15.3 0 014-10z"/></svg>
                <span class="subnav-item-label">{$hadrianLang.cart.registerNewDomain}</span>
            </a>
            <a href="{$WEB_ROOT}/cart.php?a=add&domain=transfer" class="subnav-item">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M10 13a5 5 0 007.54.54l3-3a5 5 0 00-7.07-7.07l-1.72 1.71"/><path d="M14 11a5 5 0 00-7.54-.54l-3 3a5 5 0 007.07 7.07l1.71-1.71"/></svg>
                <span class="subnav-item-label">{$hadrianLang.cart.transferDomain}</span>
            </a>
            <div class="subnav-divider"></div>
            <a href="{$WEB_ROOT}/cart.php?a=view" class="subnav-item">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="9" cy="21" r="1"/><circle cx="20" cy="21" r="1"/><path d="M1 1h4l2.68 13.39a2 2 0 002 1.61h9.72a2 2 0 002-1.61L23 6H6"/></svg>
                <span class="subnav-item-label">{$LANG.viewcart}</span>
                {if $cartcount && $cartcount > 0}
                    <span class="subnav-badge">{$cartcount}</span>
                {/if}
            </a>
        </div>
    {/if}
</aside>
{/if}
