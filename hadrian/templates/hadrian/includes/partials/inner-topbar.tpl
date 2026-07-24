{* Topbar shown on sidebar + rail layouts (hidden on top-nav). *}
{assign var=_first value=''}
{assign var=_last value=''}
{assign var=_email value=''}
{if isset($clientsdetails) && is_array($clientsdetails)}
    {assign var=_first value=$clientsdetails.firstname|default:''}
    {assign var=_last value=$clientsdetails.lastname|default:''}
    {assign var=_email value=$clientsdetails.email|default:''}
{/if}
{assign var=user_initials value=$_first|truncate:1:''|upper}
{assign var=user_fullname value=$_first|cat:' '|cat:$_last}
<div class="ph-side-topbar only-inner">
    <div class="ph-side-topbar-inner">
        <button type="button" class="ph-side-iconbtn ph-mobile-toggle" aria-label="{$hadrianLang.nav.openNavigation}" aria-controls="appSidebar" aria-expanded="false" data-nav-toggle>
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="3" y1="6" x2="21" y2="6"/><line x1="3" y1="12" x2="21" y2="12"/><line x1="3" y1="18" x2="21" y2="18"/></svg>
        </button>
        {* Mobile-only brand: on <=900px the sidebar/rail (which normally shows
           the logo) collapses into the drawer, so surface the logo here so it's
           visible without opening the menu. Hidden on desktop via CSS. *}
        {if !empty($hadrian.branding.logo.light)}
            <a href="{$WEB_ROOT}/" class="ph-side-logo img-logo">
                <img src="{$hadrian.branding.logo.light|escape}" alt="{$companyname|escape}"
                     {if !empty($hadrian.branding.logo.dark) && $hadrian.branding.logo.dark != $hadrian.branding.logo.light}data-logo-dark="{$hadrian.branding.logo.dark|escape}"{/if}>
            </a>
        {else}
            <a href="{$WEB_ROOT}/" class="ph-side-logo text-logo">{$companyname|escape}</a>
        {/if}
        <div class="ph-side-crumbs">
            <a href="{$WEB_ROOT}/">{$LANG.home|default:'Portal Home'}</a>
            <span class="sep">›</span>
            <span class="current" aria-current="page" data-current-page>{$mt_pageLabel|default:$pagetitle|default:$hadrianLang.common.page}</span>
        </div>
        <div class="ph-side-topbar-actions">
            {if $loggedin}
                <div class="notification-wrapper only-in" id="sideNotifyWrap">
                    <button type="button" class="ph-side-iconbtn" aria-label="{$LANG.notifications}" onclick="togglePortalNotifications && togglePortalNotifications(event, 'side')">
                        <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M18 8A6 6 0 006 8c0 7-3 9-3 9h18s-3-2-3-9"/><path d="M13.73 21a2 2 0 01-3.46 0"/></svg>
                        {if (isset($clientAlerts) && $clientAlerts|count > 0) || (isset($publishedAnnouncements) && $publishedAnnouncements|count > 0)}<div class="topbar-notification-dot"></div>{/if}
                    </button>
                    <div class="notification-dropdown" id="notificationDropdownSide">
                        <div class="notification-dropdown-header">
                            <span class="notification-dropdown-title">{$LANG.notifications}</span>
                        </div>
                        {assign var=naHasAlerts value=false}
                        {if isset($clientAlerts) && $clientAlerts|count > 0}{assign var=naHasAlerts value=true}{/if}
                        {assign var=naHasAnns value=false}
                        {if isset($publishedAnnouncements) && $publishedAnnouncements|count > 0}{assign var=naHasAnns value=true}{/if}
                        {if $naHasAlerts}
                            {foreach $clientAlerts as $alert}
                                <a href="{$alert->getLink()}" class="notification-item">
                                    <div class="notification-dot-indicator {if $alert->getSeverity() == 'danger'}red{elseif $alert->getSeverity() == 'warning'}orange{elseif $alert->getSeverity() == 'info'}blue{else}green{/if}"></div>
                                    <div class="notification-content">
                                        <div class="notification-text">{$alert->getMessage()}</div>
                                    </div>
                                </a>
                            {/foreach}
                        {/if}
                        {if $naHasAnns}
                            {foreach $publishedAnnouncements as $ann}
                                <a href="{$WEB_ROOT}/announcements.php?id={$ann.id}" class="notification-item">
                                    <div class="notification-dot-indicator blue"></div>
                                    <div class="notification-content">
                                        <div class="notification-text">{$ann.title|escape}</div>
                                        <div class="notification-time">{if isset($carbon) && isset($ann.timestamp) && $ann.timestamp}{$carbon->createFromTimestamp($ann.timestamp)->format('F j, Y')}{else}{$ann.date|default:''|strip_tags|escape}{/if}</div>
                                    </div>
                                </a>
                                {if $ann@iteration >= 5}{break}{/if}
                            {/foreach}
                        {/if}
                        {if !$naHasAlerts && !$naHasAnns}
                            <div class="notification-item" style="justify-content:center;color:var(--color-text-tertiary);font-size:13px;">
                                {$LANG.nonotifications}
                            </div>
                        {/if}
                    </div>
                </div>
            {/if}
            <a href="{$WEB_ROOT}/cart.php?a=view" class="ph-side-iconbtn topbar-cart-btn" aria-label="{$LANG.carttitle}">
                <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="9" cy="21" r="1"/><circle cx="20" cy="21" r="1"/><path d="M1 1h4l2.68 13.39a2 2 0 002 1.61h9.72a2 2 0 002-1.61L23 6H6"/></svg>
                {* $globalCartCount is injected by Hadrian's ClientAreaPage
                   hook (hooks.php) on every page. $cartitems / $cartcount
                   are fallbacks for cart-flow pages if the hook isn't run. *}
                {if $globalCartCount && $globalCartCount > 0}
                    <span class="topbar-cart-badge" aria-label="{$hadrianLang.nav.itemsInCart|replace:'%s':$globalCartCount}">{$globalCartCount}</span>
                {elseif $cartitems && $cartitems > 0}
                    <span class="topbar-cart-badge" aria-label="{$hadrianLang.nav.itemsInCart|replace:'%s':$cartitems}">{$cartitems}</span>
                {elseif $cartcount && $cartcount > 0}
                    <span class="topbar-cart-badge" aria-label="{$hadrianLang.nav.itemsInCart|replace:'%s':$cartcount}">{$cartcount}</span>
                {/if}
            </a>
            {if $mtShowDarkToggle}
            <a href="#" onclick="toggleDarkMode && toggleDarkMode(); return false;" class="ph-side-iconbtn" aria-label="{$hadrianLang.common.toggleTheme}">
                <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M21 12.79A9 9 0 1 1 11.21 3 7 7 0 0 0 21 12.79z"/></svg>
            </a>
            {/if}
            {if $loggedin}
                <div class="profile-dropdown-wrapper only-in" id="sideUserWrap">
                    <div class="topbar-avatar" onclick="togglePortalProfile && togglePortalProfile(event, 'side')" title="{$LANG.accounttab|default:'Account'}">{$user_initials|default:'U'}</div>
                    {include file="`$template`/includes/partials/profile-dropdown.tpl" ddId="profileDropdownSide"}
                </div>
            {else}
                <a href="{$WEB_ROOT}/login.php" class="ph-side-signin only-out">{$LANG.login}</a>
            {/if}
        </div>
    </div>
</div>
