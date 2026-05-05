{* Hostnodes — top navigation (rendered when body[data-layout="top"]). *}
{$_first = ''}
{if isset($clientsdetails) && is_array($clientsdetails)}
    {$_first = $clientsdetails.firstname|default:''}
{/if}
{$user_initials = ($_first|truncate:1:'')|upper}
<nav class="homepage-nav only-top">
    <div class="homepage-nav-inner">
        <a href="{$WEB_ROOT}/" class="nav-logo text-logo">{$companyname|escape}</a>

        {* Logged-out *}
        <a href="{$WEB_ROOT}/cart.php" class="only-out">{$LANG.shop|default:'Store'}</a>
        <a href="{$WEB_ROOT}/announcements.php" class="only-out">{$LANG.announcementstitle|default:'Announcements'}</a>
        <a href="{$WEB_ROOT}/knowledgebase.php" class="only-out">{$LANG.knowledgebasetitle|default:'Knowledgebase'}</a>
        <a href="{$WEB_ROOT}/serverstatus.php" class="only-out">{$LANG.networkstatus|default:'Network Status'}</a>
        <a href="{$WEB_ROOT}/contact.php" class="only-out">{$LANG.contactus|default:'Contact Us'}</a>

        {* Logged-in *}
        <a href="{$WEB_ROOT}/clientarea.php?action=services" class="only-in">{$LANG.navservices|default:'Services'}</a>
        <a href="{$WEB_ROOT}/clientarea.php?action=domains" class="only-in">{$LANG.navdomains|default:'Domains'}</a>
        <a href="{$WEB_ROOT}/clientarea.php?action=invoices" class="only-in">{$LANG.navinvoices|default:'Billing'}</a>
        <a href="{$WEB_ROOT}/supporttickets.php" class="only-in">{$LANG.supporttickets|default:'Support'}</a>

        <div class="nav-spacer"></div>

        <a href="{$WEB_ROOT}/cart.php" class="topbar-btn" title="{$LANG.cartTitle|default:'Cart'}">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="9" cy="21" r="1"/><circle cx="20" cy="21" r="1"/><path d="M1 1h4l2.68 13.39a2 2 0 002 1.61h9.72a2 2 0 002-1.61L23 6H6"/></svg>
        </a>

        {if $loggedin}
            <div class="profile-dropdown-wrapper only-in">
                <div class="topbar-avatar" onclick="togglePortalProfile && togglePortalProfile(event)" title="{$LANG.accounttab|default:'Account'}">{$user_initials|default:'U'}</div>
            </div>
        {else}
            <a href="{$WEB_ROOT}/login.php" class="nav-signin only-out">{$LANG.login|default:'Sign in'}</a>
            <a href="#" onclick="toggleDarkMode && toggleDarkMode(); return false;" class="topbar-btn only-out" aria-label="Toggle theme">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M21 12.79A9 9 0 1 1 11.21 3 7 7 0 0 0 21 12.79z"/></svg>
            </a>
        {/if}
    </div>
</nav>
