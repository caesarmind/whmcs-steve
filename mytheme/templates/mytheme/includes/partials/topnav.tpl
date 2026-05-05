{* Hostnodes — top navigation (rendered when body[data-layout="top"]). *}
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
            <div class="profile-dropdown-wrapper only-in" id="navUserWrap">
                <div class="topbar-avatar" onclick="togglePortalProfile && togglePortalProfile(event)" title="{$LANG.accounttab|default:'Account'}">{$user_initials|default:'U'}</div>
                <div class="profile-dropdown" id="profileDropdown">
                    <div class="profile-dropdown-header">
                        <div class="profile-dropdown-name">{$user_fullname|escape|default:'Account'}</div>
                        <div class="profile-dropdown-email">{$_email|escape}</div>
                    </div>
                    <a href="{$WEB_ROOT}/clientarea.php?action=details" class="profile-dropdown-item">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M20 21v-2a4 4 0 00-4-4H8a4 4 0 00-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>
                        {$LANG.navchangedetails|default:'My Details'}
                    </a>
                    <a href="{$WEB_ROOT}/clientarea.php?action=security" class="profile-dropdown-item">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="11" width="18" height="11" rx="2"/><path d="M7 11V7a5 5 0 0110 0v4"/></svg>
                        {$LANG.twofactorauth|default:'Security Settings'}
                    </a>
                    <a href="{$WEB_ROOT}/clientarea.php?action=emails" class="profile-dropdown-item">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z"/><polyline points="22,6 12,13 2,6"/></svg>
                        {$LANG.emailstitle|default:'Email History'}
                    </a>
                    <div class="profile-dropdown-divider"></div>
                    <div class="theme-toggle-row">
                        <span class="theme-toggle-label">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21 12.79A9 9 0 1 1 11.21 3 7 7 0 0 0 21 12.79z"/></svg>
                            {$LANG.darkMode|default:'Dark Mode'}
                        </span>
                        <div class="toggle-switch" id="darkModeToggle" onclick="toggleDarkMode && toggleDarkMode()"></div>
                    </div>
                    <div class="profile-dropdown-divider"></div>
                    <a href="{$WEB_ROOT}/logout.php" class="profile-dropdown-item danger">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M9 21H5a2 2 0 01-2-2V5a2 2 0 012-2h4"/><polyline points="16 17 21 12 16 7"/><line x1="21" y1="12" x2="9" y2="12"/></svg>
                        {$LANG.logout|default:'Sign Out'}
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
