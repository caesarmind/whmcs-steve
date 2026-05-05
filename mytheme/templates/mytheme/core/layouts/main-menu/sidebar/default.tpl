{* Sidebar layout — renders <aside class="sidebar">, opens <div class="main">, topbar, and <div class="content">.
   The page content fills `.content`. footer.tpl closes the wrappers. *}

{$user_initials = ($clientsdetails.firstname|default:''|truncate:1:'')|upper|cat:($clientsdetails.lastname|default:''|truncate:1:'')|upper}
{$user_fullname = "`$clientsdetails.firstname|default:''` `$clientsdetails.lastname|default:''`"|trim}

<aside class="sidebar">
    <div class="sidebar-header">
        <div class="sidebar-logo">
            {if $logo}
                <img src="{$logo|escape}" alt="{$companyname|escape}" style="max-width:28px;max-height:28px">
            {else}
                <svg viewBox="0 0 24 24" fill="currentColor">
                    <path d="M18.71 19.5C17.88 20.74 17 21.95 15.66 21.97C14.32 21.99 13.89 21.18 12.37 21.18C10.84 21.18 10.37 21.95 9.1 21.99C7.79 22.03 6.8 20.68 5.96 19.47C4.25 16.99 2.97 12.5 4.7 9.56C5.55 8.08 7.13 7.16 8.84 7.14C10.13 7.12 11.34 8.01 12.14 8.01C12.94 8.01 14.41 6.93 15.95 7.11C16.59 7.14 18.37 7.36 19.53 9.06C19.43 9.12 17.2 10.42 17.22 13.11C17.25 16.33 20.05 17.37 20.09 17.38C20.06 17.47 19.61 18.98 18.71 19.5M13 3.5C13.73 2.67 14.94 2.04 15.94 2C16.07 3.17 15.6 4.35 14.9 5.19C14.21 6.04 13.07 6.7 11.95 6.61C11.8 5.46 12.36 4.26 13 3.5Z"/>
                </svg>
            {/if}
        </div>
        <span class="sidebar-brand">{$companyname|escape}</span>
    </div>

    <div class="sidebar-search">
        <form action="{$WEB_ROOT}/knowledgebase.php" method="get">
            <input type="text" name="search" class="sidebar-search-input" placeholder="{$LANG.searchbutton|default:'Search'}">
        </form>
    </div>

    <nav class="sidebar-nav">
        <a href="{$WEB_ROOT}/clientarea.php" class="sidebar-item {if $templatefile == 'clientareahome'}active{/if}">
            <div class="sidebar-item-icon blue">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="3" width="7" height="7" rx="1"/><rect x="14" y="3" width="7" height="7" rx="1"/><rect x="3" y="14" width="7" height="7" rx="1"/><rect x="14" y="14" width="7" height="7" rx="1"/></svg>
            </div>
            {$LANG.clientareanavhome|default:'Dashboard'}
        </a>

        <div class="sidebar-section-label">{$LANG.servicestab|default:'Services'}</div>

        <a href="{$WEB_ROOT}/clientarea.php?action=services" class="sidebar-item {if $templatefile|strstr:'clientareaproducts'}active{/if}">
            <div class="sidebar-item-icon purple">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="2" y="3" width="20" height="14" rx="2"/><path d="M8 21h8"/><path d="M12 17v4"/></svg>
            </div>
            {$LANG.navservices|default:'My Services'}
            {if $clientsstats.productsnumactive > 0}<span class="sidebar-item-badge">{$clientsstats.productsnumactive}</span>{/if}
        </a>

        <a href="{$WEB_ROOT}/clientarea.php?action=domains" class="sidebar-item {if $templatefile|strstr:'clientareadomain'}active{/if}">
            <div class="sidebar-item-icon green">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="2" y1="12" x2="22" y2="12"/><path d="M12 2a15.3 15.3 0 0 1 4 10 15.3 15.3 0 0 1-4 10 15.3 15.3 0 0 1-4-10 15.3 15.3 0 0 1 4-10z"/></svg>
            </div>
            {$LANG.navdomains|default:'My Domains'}
            {if $clientsstats.numactivedomains > 0}<span class="sidebar-item-badge">{$clientsstats.numactivedomains}</span>{/if}
        </a>

        <div class="sidebar-section-label">{$LANG.invoicestab|default:'Billing'}</div>

        <a href="{$WEB_ROOT}/clientarea.php?action=invoices" class="sidebar-item {if $templatefile == 'clientareainvoices'}active{/if}">
            <div class="sidebar-item-icon orange">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="1" y="4" width="22" height="16" rx="2"/><line x1="1" y1="10" x2="23" y2="10"/></svg>
            </div>
            {$LANG.navinvoices|default:'Invoices'}
            {if $clientsstats.numunpaidinvoices > 0}<span class="sidebar-item-badge">{$clientsstats.numunpaidinvoices}</span>{/if}
        </a>

        <a href="{$WEB_ROOT}/clientarea.php?action=paymentmethods" class="sidebar-item {if $templatefile|strstr:'paymentmethods'}active{/if}">
            <div class="sidebar-item-icon teal">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21 12V7H5a2 2 0 0 1 0-4h14v4"/><path d="M3 5v14a2 2 0 0 0 2 2h16v-5"/><path d="M18 12a2 2 0 0 0 0 4h4v-4Z"/></svg>
            </div>
            {$LANG.paymentMethods.title|default:'Payment Methods'}
        </a>

        <div class="sidebar-section-label">{$LANG.supporttickets|default:'Support'}</div>

        <a href="{$WEB_ROOT}/supporttickets.php" class="sidebar-item {if $templatefile|strstr:'supportticket'}active{/if}">
            <div class="sidebar-item-icon red">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"/></svg>
            </div>
            {$LANG.navtickets|default:'Support Tickets'}
            {if $clientsstats.numactivetickets > 0}<span class="sidebar-item-badge">{$clientsstats.numactivetickets}</span>{/if}
        </a>

        <a href="{$WEB_ROOT}/knowledgebase.php" class="sidebar-item {if $templatefile|strstr:'knowledgebase'}active{/if}">
            <div class="sidebar-item-icon indigo">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M2 3h6a4 4 0 0 1 4 4v14a3 3 0 0 0-3-3H2z"/><path d="M22 3h-6a4 4 0 0 0-4 4v14a3 3 0 0 1 3-3h7z"/></svg>
            </div>
            {$LANG.knowledgebasetitle|default:'Knowledge Base'}
        </a>

        <a href="{$WEB_ROOT}/announcements.php" class="sidebar-item {if $templatefile == 'announcements'}active{/if}">
            <div class="sidebar-item-icon pink">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M18 8A6 6 0 0 0 6 8c0 7-3 9-3 9h18s-3-2-3-9"/><path d="M13.73 21a2 2 0 0 1-3.46 0"/></svg>
            </div>
            {$LANG.announcementstitle|default:'Announcements'}
        </a>

        <div class="sidebar-section-label">{$LANG.accounttab|default:'Account'}</div>

        <a href="{$WEB_ROOT}/clientarea.php?action=details" class="sidebar-item {if $templatefile == 'clientareadetails'}active{/if}">
            <div class="sidebar-item-icon gray">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>
            </div>
            {$LANG.navchangedetails|default:'My Details'}
        </a>

        <a href="{$WEB_ROOT}/clientarea.php?action=security" class="sidebar-item {if $templatefile == 'clientareasecurity'}active{/if}">
            <div class="sidebar-item-icon gray">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="11" width="18" height="11" rx="2" ry="2"/><path d="M7 11V7a5 5 0 0 1 10 0v4"/></svg>
            </div>
            {$LANG.navsecurity|default:'Security'}
        </a>
    </nav>

    {if $loggedin}
        <div class="sidebar-footer">
            <div class="sidebar-user" onclick="toggleProfileDropdown(event)">
                <div class="sidebar-avatar">{$user_initials|default:'U'}</div>
                <div class="sidebar-user-info">
                    <div class="sidebar-user-name">{$user_fullname|escape|default:'User'}</div>
                    <div class="sidebar-user-email">{$clientsdetails.email|escape}</div>
                </div>
            </div>
        </div>
    {/if}
</aside>

<div class="main">
    <div class="topbar">
        <div class="topbar-breadcrumb">
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="3" width="7" height="7" rx="1"/><rect x="14" y="3" width="7" height="7" rx="1"/><rect x="3" y="14" width="7" height="7" rx="1"/><rect x="14" y="14" width="7" height="7" rx="1"/></svg>
            <span class="topbar-breadcrumb-current">{$pagetitle|escape|default:'Dashboard'}</span>
        </div>

        <div class="topbar-spacer"></div>

        <div class="topbar-actions">
            <a href="{$WEB_ROOT}/announcements.php" class="topbar-btn" title="{$LANG.announcementstitle|default:'Notifications'}">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M18 8A6 6 0 0 0 6 8c0 7-3 9-3 9h18s-3-2-3-9"/><path d="M13.73 21a2 2 0 0 1-3.46 0"/></svg>
                {if $clientsstats.unreadAnnouncements|default:0}<div class="topbar-notification-dot"></div>{/if}
            </a>

            <a href="{$WEB_ROOT}/cart.php" class="topbar-btn" title="{$LANG.cartTitle|default:'Shopping Cart'}">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="9" cy="21" r="1"/><circle cx="20" cy="21" r="1"/><path d="M1 1h4l2.68 13.39a2 2 0 0 0 2 1.61h9.72a2 2 0 0 0 2-1.61L23 6H6"/></svg>
            </a>

            {if $loggedin}
                <div class="profile-dropdown-wrapper">
                    <div class="topbar-avatar" onclick="toggleProfileDropdown(event)" title="{$LANG.accounttab|default:'Account'}">{$user_initials|default:'U'}</div>
                    <div class="profile-dropdown" id="profileDropdown">
                        <div class="profile-dropdown-header">
                            <div class="profile-dropdown-name">{$user_fullname|escape}</div>
                            <div class="profile-dropdown-email">{$clientsdetails.email|escape}</div>
                        </div>
                        <a href="{$WEB_ROOT}/clientarea.php?action=details" class="profile-dropdown-item">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>
                            {$LANG.navchangedetails|default:'My Details'}
                        </a>
                        <a href="{$WEB_ROOT}/clientarea.php?action=security" class="profile-dropdown-item">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="11" width="18" height="11" rx="2"/><path d="M7 11V7a5 5 0 0 1 10 0v4"/></svg>
                            {$LANG.navsecurity|default:'Security Settings'}
                        </a>
                        <a href="{$WEB_ROOT}/clientarea.php?action=emails" class="profile-dropdown-item">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z"/><polyline points="22,6 12,13 2,6"/></svg>
                            {$LANG.navemailshistory|default:'Email History'}
                        </a>
                        <div class="profile-dropdown-divider"></div>
                        <div class="theme-toggle-row">
                            <span class="theme-toggle-label">
                                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21 12.79A9 9 0 1 1 11.21 3 7 7 0 0 0 21 12.79z"/></svg>
                                Dark Mode
                            </span>
                            <div class="toggle-switch" id="darkModeToggle" onclick="toggleDarkMode()"></div>
                        </div>
                        <div class="profile-dropdown-divider"></div>
                        <a href="{$WEB_ROOT}/logout.php" class="profile-dropdown-item danger">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4"/><polyline points="16 17 21 12 16 7"/><line x1="21" y1="12" x2="9" y2="12"/></svg>
                            {$LANG.logout|default:'Sign Out'}
                        </a>
                    </div>
                </div>
            {else}
                <a href="{$WEB_ROOT}/login.php" class="topbar-btn">{$LANG.login|default:'Sign In'}</a>
            {/if}
        </div>
    </div>

    <div class="content">
