{* Hostnodes — top navigation (rendered when body[data-layout="top"]).
   The link list is admin-driven via the Hadrian menu-manager —
   $primaryNavbar is populated by the ClientAreaPrimaryNavbar hook. The
   logo on the left + utility buttons on the right (cart, notifications,
   profile) stay hardcoded as layout chrome. *}
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

{function name=mtTopnavIcon iconName=''}
    {if $iconName && isset($mtIcons[$iconName])}
        <svg viewBox="0 0 24 24" width="14" height="14" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round">{$mtIcons[$iconName] nofilter}</svg>
    {elseif $iconName}
        <i class="{$iconName|escape}"></i>
    {/if}
{/function}

{* Renders one entry from the $mtSidebarItems plain-array list (built by
   TreeRenderer::buildFlatList). Each entry has: type, name, label, uri, icon,
   color, side, css_class, badge_source, dropdown_style, target, children.
   We iterate THIS instead of $primaryNavbar->getChildren() because the
   WHMCS\View\Menu\Item tree reorders/filters children in ways we can't
   control — e.g. custom_link grandchildren of a dropdown_parent silently
   disappear from getChildren() on the top layout. The flat list bypasses
   that entirely. *}
{function name=mtTopnavItem item=null}
    {assign var=mtType value=$item.type|default:'whmcs_page'}
    {assign var=mtIconName value=$item.icon|default:''}
    {assign var=sideRight value=''}
    {if $item.side == 'right'}{assign var=sideRight value=' nav-item-right'}{/if}
    {if $mtType == 'header'}
        {* Headers are sidebar-only — collapse to a plain disabled span on top-nav *}
        <span class="nav-section{$sideRight}">{$item.label|escape}</span>
    {elseif $mtType == 'divider'}
        <span class="nav-divider{$sideRight}"></span>
    {elseif $mtType == 'dropdown_parent' || ($mtType == 'account_dropdown' && $item.children)}
        {assign var=mtDropdownStyle value=$item.dropdown_style|default:'default'}
        <div class="nav-dropdown-wrap{$sideRight}{if $mtDropdownStyle == 'mega'} nav-dropdown-wrap--mega{/if}">
            <a href="#" class="nav-dropdown-toggle">
                {if $mtTopnavShowIcons && $mtIconName}<span class="nav-item-icon">{mtTopnavIcon iconName=$mtIconName}</span>{/if}
                {$item.label|escape}
                <svg class="nav-chevron" viewBox="0 0 16 16" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"><polyline points="4 6 8 10 12 6"/></svg>
            </a>
            {if $item.children}
                {if $mtDropdownStyle == 'mega'}
                    {* MEGA: full-width panel split into columns by `header` items.
                       Items appearing before any header fall into an auto-opened
                       first column. Dividers are dropped (mega layout uses
                       columns instead of inline dividers). *}
                    <div class="nav-dropdown-menu nav-dropdown-menu--mega">
                        <div class="nav-mega-inner">
                            {assign var=_megaOpen value=false}
                            {foreach $item.children as $child}
                                {assign var=childType value=$child.type|default:'whmcs_page'}
                                {assign var=childIcon value=$child.icon|default:''}
                                {if $childType == 'header'}
                                    {if $_megaOpen}</div>{/if}
                                    <div class="nav-mega-col"><h4>{$child.label|escape}</h4>
                                    {assign var=_megaOpen value=true}
                                {elseif $childType != 'divider'}
                                    {if !$_megaOpen}<div class="nav-mega-col">{assign var=_megaOpen value=true}{/if}
                                    <a href="{$child.uri|escape}" class="nav-mega-item{if $mtTopnavShowIcons && $childIcon} nav-mega-item--icon{/if}"{if $child.target} target="{$child.target|escape}"{/if}>
                                        {if $mtTopnavShowIcons && $childIcon}
                                            <span class="nav-mega-icon">{mtTopnavIcon iconName=$childIcon}</span><span class="nav-mega-text"><span class="name">{$child.label|escape}</span></span>
                                        {else}
                                            <span class="name">{$child.label|escape}</span>
                                        {/if}
                                    </a>
                                {/if}
                            {/foreach}
                            {if $_megaOpen}</div>{/if}
                        </div>
                    </div>
                {else}
                    {* CLASSIC: narrow floating panel — items, headers as section
                       labels, dividers as thin separators. Icons render only
                       when topnav_show_icons is on AND the child has config.icon. *}
                    <div class="nav-dropdown-menu">
                        {foreach $item.children as $child}
                            {assign var=childType value=$child.type|default:'whmcs_page'}
                            {assign var=childIcon value=$child.icon|default:''}
                            {if $childType == 'divider'}
                                <div class="nav-dropdown-divider"></div>
                            {elseif $childType == 'header'}
                                <div class="nav-dropdown-section">{$child.label|escape}</div>
                            {else}
                                <a href="{$child.uri|escape}" class="nav-dropdown-item"{if $child.target} target="{$child.target|escape}"{/if}>
                                    {if $mtTopnavShowIcons && $childIcon}<span class="nav-dropdown-item-icon">{mtTopnavIcon iconName=$childIcon}</span>{/if}
                                    {$child.label|escape}
                                </a>
                            {/if}
                        {/foreach}
                    </div>
                {/if}
            {/if}
        </div>
    {elseif $mtType == 'login_button'}
        {* Logged-out only. The menu carries no client-status gate of its own, so
           without this a signed-in visitor still got a "Login" button sitting
           next to their own profile menu. *}
        {if !$loggedin}
        <a href="{$item.uri|escape}" class="nav-cta{$sideRight}">
            {if $mtTopnavShowIcons && $mtIconName}<span class="nav-item-icon">{mtTopnavIcon iconName=$mtIconName}</span>{/if}
            {$item.label|escape}
        </a>
        {/if}
    {elseif $mtType == 'language' || $mtType == 'currency'}
        {* data-locale-open, NOT data-switcher: nothing in core-layout.js has
           ever listened for [data-switcher], so language/currency menu items
           were links that did nothing. The locale modal (which covers both) is
           opened by [data-locale-open]. *}
        <a href="#" class="nav-switcher{$sideRight}" data-locale-open data-switcher="{$mtType|escape}">{$item.label|escape}</a>
    {else}
        <a href="{$item.uri|escape}" class="nav-item{$sideRight}"{if $item.target} target="{$item.target|escape}"{/if}>
            {if $mtTopnavShowIcons && $mtIconName}<span class="nav-item-icon">{mtTopnavIcon iconName=$mtIconName}</span>{/if}
            {$item.label|escape}
        </a>
    {/if}
{/function}

<nav class="homepage-nav only-top">
    <div class="homepage-nav-inner">
        {* Mobile drawer toggle — hidden on desktop; shown <=900px (core-layout.css).
           data-nav-toggle wires it to the shared body.nav-open drawer (core-layout.js);
           the off-canvas sidebar (rendered on this layout too) is what slides in. *}
        <button type="button" class="nav-mobile-toggle" aria-label="{$hadrianLang.nav.openNavigation}" aria-controls="appSidebar" aria-expanded="false" data-nav-toggle>
            <svg viewBox="0 0 24 24" width="20" height="20" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="3" y1="6" x2="21" y2="6"/><line x1="3" y1="12" x2="21" y2="12"/><line x1="3" y1="18" x2="21" y2="18"/></svg>
        </button>
        {* Admin Branding tab: prefer uploaded logo over the company-name
           fallback. Light variant is the default; the dark URL ships as a
           data-attribute so theme JS can swap it on data-theme="dark". *}
        {if !empty($hadrian.branding.logo.light)}
            <a href="{$WEB_ROOT}/" class="nav-logo img-logo">
                <img src="{$hadrian.branding.logo.light|escape}" alt="{$companyname|escape}"
                     {if !empty($hadrian.branding.logo.dark) && $hadrian.branding.logo.dark != $hadrian.branding.logo.light}data-logo-dark="{$hadrian.branding.logo.dark|escape}"{/if}>
            </a>
        {else}
            <a href="{$WEB_ROOT}/" class="nav-logo text-logo">{$companyname|escape}</a>
        {/if}

        {if isset($mtSidebarItems) && $mtSidebarItems}
            {foreach $mtSidebarItems as $item}
                {mtTopnavItem item=$item}
            {/foreach}
        {else}
            {* Fallback when the menu manager hasn't been configured *}
            <a href="{$WEB_ROOT}/" class="nav-item">{$LANG.home|default:'Portal Home'}</a>
            {if $loggedin}<a href="{$WEB_ROOT}/clientarea.php" class="nav-item">{$LANG.clientareanavhome|default:'Go to dashboard'}</a>{/if}
        {/if}

        <div class="nav-spacer"></div>

        {if $loggedin}
            <div class="notification-wrapper only-in" id="navNotifyWrap">
                <button type="button" class="topbar-btn" title="{$LANG.notifications}" onclick="togglePortalNotifications && togglePortalNotifications(event, 'nav')">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M18 8A6 6 0 006 8c0 7-3 9-3 9h18s-3-2-3-9"/><path d="M13.73 21a2 2 0 01-3.46 0"/></svg>
                    {if (isset($clientAlerts) && $clientAlerts|count > 0) || (isset($publishedAnnouncements) && $publishedAnnouncements|count > 0)}<div class="topbar-notification-dot"></div>{/if}
                </button>
                <div class="notification-dropdown" id="notificationDropdownNav">
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

        {* Locale control, in the utility group with the cart and theme toggle.
           The right-aligned menu group (Login / Register / Language) is hidden
           from 901px up so the bar runs one set of account controls — but that
           group's "Language" item was a [data-switcher] link, an attribute
           nothing in core-layout.js listens for, so it never opened anything.
           This is the working component the footers already use: it posts to
           the real locale modal via [data-locale-open].

           Sits OUTSIDE the logged-in/out branch below on purpose — choosing a
           language is not an account action.

           Desktop only: under 901px the drawer already carries the menu's own
           locale entry, and the bar has no room for a text pill next to the
           hamburger. *}
        <span class="nav-locale">
            {include file="`$template`/includes/partials/locale-btn.tpl"}
        </span>

        <a href="{$WEB_ROOT}/cart.php?a=view" class="topbar-btn topbar-cart-btn" title="{$LANG.carttitle}">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="9" cy="21" r="1"/><circle cx="20" cy="21" r="1"/><path d="M1 1h4l2.68 13.39a2 2 0 002 1.61h9.72a2 2 0 002-1.61L23 6H6"/></svg>
            {* Cart-count badge.
               $globalCartCount is injected on every client-area page by
               Hadrian's ClientAreaPage hook (see hooks.php). $cartitems is
               the WHMCS-native fallback on cart-flow pages in case the hook
               module isn't installed; $cartcount is the legacy fallback. *}
            {if $globalCartCount && $globalCartCount > 0}
                <span class="topbar-cart-badge" aria-label="{$hadrianLang.nav.itemsInCart|replace:'%s':$globalCartCount}">{$globalCartCount}</span>
            {elseif $cartitems && $cartitems > 0}
                <span class="topbar-cart-badge" aria-label="{$hadrianLang.nav.itemsInCart|replace:'%s':$cartitems}">{$cartitems}</span>
            {elseif $cartcount && $cartcount > 0}
                <span class="topbar-cart-badge" aria-label="{$hadrianLang.nav.itemsInCart|replace:'%s':$cartcount}">{$cartcount}</span>
            {/if}
        </a>

        {if $loggedin}
            <div class="profile-dropdown-wrapper only-in" id="navUserWrap">
                <div class="topbar-avatar" onclick="togglePortalProfile && togglePortalProfile(event)" title="{$LANG.accounttab|default:'Account'}">{$user_initials|default:'U'}</div>
                {include file="`$template`/includes/partials/profile-dropdown.tpl" ddId="profileDropdown" ddToggleId="darkModeToggle"}
            </div>
        {else}
            <a href="{$WEB_ROOT}/login.php" class="nav-signin only-out">{$LANG.login}</a>
            {if $mtShowDarkToggle}
            <a href="#" onclick="toggleDarkMode && toggleDarkMode(); return false;" class="topbar-btn only-out" aria-label="{$hadrianLang.common.toggleTheme}">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M21 12.79A9 9 0 1 1 11.21 3 7 7 0 0 0 21 12.79z"/></svg>
            </a>
            {/if}
        {/if}
    </div>
</nav>
