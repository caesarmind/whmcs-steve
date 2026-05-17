{* Hostnodes — top navigation (rendered when body[data-layout="top"]).
   The link list is admin-driven via the MyTheme menu-manager —
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

{function name=mtTopnavItem item=null}
    {assign var=mtType value=$item->getAttribute('data-mt-type')|default:'whmcs_page'}
    {assign var=mtIconName value=$item->getAttribute('data-mt-icon')|default:$item->getIcon()|default:''}
    {assign var=sideRight value=''}
    {if $item->getAttribute('data-mt-side') == 'right'}{assign var=sideRight value=' nav-item-right'}{/if}
    {if $mtType == 'header'}
        {* Headers are sidebar-only — collapse to a plain disabled span on top-nav *}
        <span class="nav-section{$sideRight}">{$item->getLabel()|escape}</span>
    {elseif $mtType == 'divider'}
        <span class="nav-divider{$sideRight}"></span>
    {elseif $mtType == 'dropdown_parent'}
        <div class="nav-dropdown-wrap{$sideRight}">
            <a href="#" class="nav-dropdown-toggle">
                {if $mtIconName}<span class="nav-item-icon">{mtTopnavIcon iconName=$mtIconName}</span>{/if}
                {$item->getLabel()|escape}
                <svg class="nav-chevron" viewBox="0 0 16 16" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"><polyline points="4 6 8 10 12 6"/></svg>
            </a>
            {if $item->getChildren()}
                <div class="nav-dropdown-menu">
                    {foreach $item->getChildren() as $child}
                        {assign var=childType value=$child->getAttribute('data-mt-type')|default:'whmcs_page'}
                        {assign var=childIcon value=$child->getAttribute('data-mt-icon')|default:$child->getIcon()|default:''}
                        {if $childType == 'divider'}
                            <div class="nav-dropdown-divider"></div>
                        {elseif $childType == 'header'}
                            <div class="nav-dropdown-section">{$child->getLabel()|escape}</div>
                        {else}
                            <a href="{$child->getUri()|escape}" class="nav-dropdown-item">
                                {if $childIcon}<span class="nav-dropdown-item-icon">{mtTopnavIcon iconName=$childIcon}</span>{/if}
                                {$child->getLabel()|escape}
                            </a>
                        {/if}
                    {/foreach}
                </div>
            {/if}
        </div>
    {elseif $mtType == 'login_button'}
        <a href="{$item->getUri()|escape}" class="nav-cta{$sideRight}">
            {if $mtIconName}<span class="nav-item-icon">{mtTopnavIcon iconName=$mtIconName}</span>{/if}
            {$item->getLabel()|escape}
        </a>
    {elseif $mtType == 'language' || $mtType == 'currency'}
        <a href="#" class="nav-switcher{$sideRight}" data-switcher="{$mtType|escape}">{$item->getLabel()|escape}</a>
    {else}
        <a href="{$item->getUri()|escape}" class="nav-item{$sideRight}">
            {if $mtIconName}<span class="nav-item-icon">{mtTopnavIcon iconName=$mtIconName}</span>{/if}
            {$item->getLabel()|escape}
        </a>
    {/if}
{/function}

<nav class="homepage-nav only-top">
    <div class="homepage-nav-inner">
        {* Admin Branding tab: prefer uploaded logo over the company-name
           fallback. Light variant is the default; the dark URL ships as a
           data-attribute so theme JS can swap it on data-theme="dark". *}
        {if !empty($myTheme.branding.logo.light)}
            <a href="{$WEB_ROOT}/" class="nav-logo img-logo">
                <img src="{$myTheme.branding.logo.light|escape}" alt="{$companyname|escape}"
                     {if !empty($myTheme.branding.logo.dark) && $myTheme.branding.logo.dark != $myTheme.branding.logo.light}data-logo-dark="{$myTheme.branding.logo.dark|escape}"{/if}>
            </a>
        {else}
            <a href="{$WEB_ROOT}/" class="nav-logo text-logo">{$companyname|escape}</a>
        {/if}

        {if isset($primaryNavbar) && $primaryNavbar->getChildren()}
            {foreach $primaryNavbar->getChildren() as $item}
                {mtTopnavItem item=$item}
            {/foreach}
        {else}
            {* Fallback when the menu manager hasn't been configured *}
            <a href="{$WEB_ROOT}/" class="nav-item">{$LANG.home|default:'Home'}</a>
            {if $loggedin}<a href="{$WEB_ROOT}/clientarea.php" class="nav-item">{$LANG.clientareanavhome|default:'Dashboard'}</a>{/if}
        {/if}

        <div class="nav-spacer"></div>

        {if $loggedin}
            <div class="notification-wrapper only-in" id="navNotifyWrap">
                <button type="button" class="topbar-btn" title="{$LANG.notifications|default:'Notifications'}" onclick="togglePortalNotifications && togglePortalNotifications(event, 'nav')">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M18 8A6 6 0 006 8c0 7-3 9-3 9h18s-3-2-3-9"/><path d="M13.73 21a2 2 0 01-3.46 0"/></svg>
                    {if isset($publishedAnnouncements) && $publishedAnnouncements|count > 0}<div class="topbar-notification-dot"></div>{/if}
                </button>
                <div class="notification-dropdown" id="notificationDropdownNav">
                    <div class="notification-dropdown-header">
                        <span class="notification-dropdown-title">{$LANG.notifications|default:'Notifications'}</span>
                    </div>
                    {if isset($publishedAnnouncements) && $publishedAnnouncements|count > 0}
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
                    {else}
                        <div class="notification-item" style="justify-content:center;color:var(--color-text-tertiary);font-size:13px;">
                            {$LANG.nonotifications|default:'No notifications'}
                        </div>
                    {/if}
                </div>
            </div>
        {/if}

        <a href="{$WEB_ROOT}/cart.php?a=view" class="topbar-btn topbar-cart-btn" title="{$LANG.cartTitle|default:'Cart'}">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="9" cy="21" r="1"/><circle cx="20" cy="21" r="1"/><path d="M1 1h4l2.68 13.39a2 2 0 002 1.61h9.72a2 2 0 002-1.61L23 6H6"/></svg>
            {if $cartcount && $cartcount > 0}
                <span class="topbar-cart-badge" aria-label="{$cartcount} {$LANG.cartItems|default:'items in cart'}">{$cartcount}</span>
            {/if}
        </a>

        {if $loggedin}
            <div class="profile-dropdown-wrapper only-in" id="navUserWrap">
                <div class="topbar-avatar" onclick="togglePortalProfile && togglePortalProfile(event)" title="{$LANG.accounttab|default:'Account'}">{$user_initials|default:'U'}</div>
                <div class="profile-dropdown" id="profileDropdown">
                    <div class="profile-dropdown-header">
                        <div class="profile-dropdown-name">{$user_fullname|escape|default:'Account'}</div>
                        <div class="profile-dropdown-email">{$_email|escape}</div>
                    </div>

                    {* — Account section — *}
                    <a href="{$WEB_ROOT}/clientarea.php?action=details" class="profile-dropdown-item">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M20 21v-2a4 4 0 00-4-4H8a4 4 0 00-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>
                        {$LANG.accountdetails|default:'Account Details'}
                    </a>
                    <a href="{routePath('account-users')}" class="profile-dropdown-item">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M17 21v-2a4 4 0 00-4-4H5a4 4 0 00-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 00-3-3.87"/><path d="M16 3.13a4 4 0 010 7.75"/></svg>
                        {$LANG.usermanagement|default:'User Management'}
                    </a>
                    <a href="{routePath('account-paymentmethods')}" class="profile-dropdown-item">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="1" y="4" width="22" height="16" rx="2"/><line x1="1" y1="10" x2="23" y2="10"/></svg>
                        {$LANG.paymentmethods|default:'Payment Methods'}
                    </a>
                    <a href="{routePath('account-contacts')}" class="profile-dropdown-item">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M20 21v-2a4 4 0 00-4-4H8a4 4 0 00-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>
                        {$LANG.contacts|default:'Contacts'}
                    </a>
                    <a href="{$WEB_ROOT}/clientarea.php?action=emails" class="profile-dropdown-item">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z"/><polyline points="22,6 12,13 2,6"/></svg>
                        {$LANG.emailstitle|default:'Email History'}
                    </a>

                    <div class="profile-dropdown-divider"></div>

                    {* — Profile section — *}
                    <a href="{routePath('user-profile')}" class="profile-dropdown-item">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><path d="M12 14a4 4 0 100-8 4 4 0 000 8z"/><path d="M19.5 19a8 8 0 00-15 0"/></svg>
                        {$LANG.yourprofile|default:'Your Profile'}
                    </a>
                    <a href="{routePath('user-accounts')}" class="profile-dropdown-item">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="17 1 21 5 17 9"/><path d="M3 11V9a4 4 0 014-4h14"/><polyline points="7 23 3 19 7 15"/><path d="M21 13v2a4 4 0 01-4 4H3"/></svg>
                        {$LANG.switchaccount|default:'Switch Account'}
                    </a>
                    <a href="{routePath('user-password')}" class="profile-dropdown-item">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21 2l-2 2m-7.61 7.61a5.5 5.5 0 11-7.778 7.778 5.5 5.5 0 017.777-7.777zm0 0L15.5 7.5m0 0l3 3L22 7l-3-3m-3.5 3.5L19 4"/></svg>
                        {$LANG.clientareanavchangepassword|default:'Change Password'}
                    </a>
                    <a href="{routePath('user-security')}" class="profile-dropdown-item">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="11" width="18" height="11" rx="2"/><path d="M7 11V7a5 5 0 0110 0v4"/></svg>
                        {$LANG.securitysettings|default:'Security Settings'}
                    </a>

                    <div class="profile-dropdown-divider"></div>

                    {* — Theme toggle (small utility) — *}
                    <div class="theme-toggle-row">
                        <span class="theme-toggle-label">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21 12.79A9 9 0 1 1 11.21 3 7 7 0 0 0 21 12.79z"/></svg>
                            {$LANG.darkMode|default:'Dark Mode'}
                        </span>
                        <div class="toggle-switch" id="darkModeToggle" onclick="toggleDarkMode && toggleDarkMode()"></div>
                    </div>

                    <div class="profile-dropdown-divider"></div>

                    {* — Sign out — *}
                    <a href="{$WEB_ROOT}/logout.php" class="profile-dropdown-item danger">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M9 21H5a2 2 0 01-2-2V5a2 2 0 012-2h4"/><polyline points="16 17 21 12 16 7"/><line x1="21" y1="12" x2="9" y2="12"/></svg>
                        {$LANG.logout|default:'Logout'}
                    </a>
                </div>
            </div>
        {else}
            <a href="{$WEB_ROOT}/login.php" class="nav-signin only-out">{$LANG.login|default:'Sign in'}</a>
            <a href="#" onclick="toggleDarkMode && toggleDarkMode(); return false;" class="topbar-btn only-out" aria-label="Toggle theme">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M21 12.79A9 9 0 1 1 11.21 3 7 7 0 0 0 21 12.79z"/></svg>
            </a>
        {/if}
    </div>
</nav>
