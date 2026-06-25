{*
 * hadrian_cart/sidebar-categories-collapsed.tpl
 *
 * Mobile / narrow-viewport reveal of the categories sidebar. Desktop
 * shows the full sidebar-categories.tpl in the gutter; on narrow
 * screens that gutter collapses and the apple-layout.css media query
 * (max-width: 880px) un-hides this .sidebar-collapsed wrapper.
 *
 * Each $panel in $secondarySidebar renders as a card-wrapped <select>
 * (see sidebar-categories-selector.tpl). The optional currency picker
 * sits beneath, for guest visitors with multi-currency enabled.
 *
 * Contract preserved verbatim:
 *   - <div class="sidebar-collapsed"> outer wrapper -- apple-layout.css
 *     keys its hide/show on this class.
 *   - $secondarySidebar panel loop with $panel->getClass() applied
 *     directly on the panel root.
 *   - <form method="post" action="{$WEB_ROOT}/cart.php?..."> currency
 *     selector with the action-string sprintf preserved.
 *
 * Apple visual layer:
 *   - .card primitive inherits rounded + bordered surface.
 *   - .currency-picker-form is a new wrapper so we can give the
 *     <select> a top divider on mobile without affecting desktop.
 *}

<div class="sidebar-collapsed">

    {if $secondarySidebar}
        {foreach $secondarySidebar as $panel}
            <div class="panel card card-subnav-collapsed{if $panel->getClass()} {$panel->getClass()|escape}{else} panel-default{/if}">
                {include file="orderforms/$carttpl/sidebar-categories-selector.tpl"}
            </div>
        {/foreach}
    {/if}

    {if !$loggedin && $currencies}
        <div class="currency-picker-form pull-right float-right form-inline">
            <form method="post" action="{$WEB_ROOT}/cart.php{if $action}?a={$action|escape}{if $domain}&domain={$domain|escape}{/if}{elseif $gid}?gid={$gid|escape}{/if}">
                <label for="cartCurrencyCollapsed" class="sr-only">{$LANG.choosecurrency}</label>
                <select id="cartCurrencyCollapsed" name="currency" onchange="submit()" class="form-control custom-select">
                    <option value="">{$LANG.choosecurrency}</option>
                    {foreach from=$currencies item=listcurr}
                        <option value="{$listcurr.id}"{if $listcurr.id == $activeCurrency.id} selected{/if}>{$listcurr.code|escape}</option>
                    {/foreach}
                </select>
            </form>
        </div>
    {/if}

</div>
