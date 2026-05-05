{* Topbar shown on sidebar + rail layouts (hidden on top-nav). *}
{$_first = ''}
{if isset($clientsdetails) && is_array($clientsdetails)}
    {$_first = $clientsdetails.firstname|default:''}
{/if}
{$user_initials = ($_first|truncate:1:'')|upper}
<div class="ph-side-topbar only-inner">
    <div class="ph-side-topbar-inner">
        <div class="ph-side-crumbs">
            <a href="{$WEB_ROOT}/">{$LANG.home|default:'Home'}</a>
            <span class="sep">›</span>
            <span class="current" aria-current="page" data-current-page>{$pagetitle|default:'Page'}</span>
        </div>
        <div class="ph-side-topbar-actions">
            {if $loggedin}
                <button type="button" class="ph-side-iconbtn only-in" aria-label="{$LANG.notifications|default:'Notifications'}">
                    <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M18 8A6 6 0 006 8c0 7-3 9-3 9h18s-3-2-3-9"/><path d="M13.73 21a2 2 0 01-3.46 0"/></svg>
                </button>
            {/if}
            <a href="{$WEB_ROOT}/cart.php" class="ph-side-iconbtn" aria-label="{$LANG.cartTitle|default:'Cart'}">
                <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="9" cy="21" r="1"/><circle cx="20" cy="21" r="1"/><path d="M1 1h4l2.68 13.39a2 2 0 002 1.61h9.72a2 2 0 002-1.61L23 6H6"/></svg>
            </a>
            <a href="#" onclick="toggleDarkMode && toggleDarkMode(); return false;" class="ph-side-iconbtn" aria-label="Toggle theme">
                <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M21 12.79A9 9 0 1 1 11.21 3 7 7 0 0 0 21 12.79z"/></svg>
            </a>
            {if $loggedin}
                <div class="profile-dropdown-wrapper only-in">
                    <div class="topbar-avatar" onclick="togglePortalProfile && togglePortalProfile(event, 'side')" title="{$LANG.accounttab|default:'Account'}">{$user_initials|default:'U'}</div>
                </div>
            {else}
                <a href="{$WEB_ROOT}/login.php" class="ph-side-signin only-out">{$LANG.login|default:'Sign in'}</a>
            {/if}
        </div>
    </div>
</div>
