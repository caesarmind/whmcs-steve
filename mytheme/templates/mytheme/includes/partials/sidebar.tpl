{* Hostnodes — Fixed 260px sidebar (rendered when body[data-layout="side"]).
   Items have data-nav so apple-layout.js can mark the active one. *}
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
<aside class="sidebar only-side">
    <div class="sidebar-header">
        <a href="{$WEB_ROOT}/" class="sidebar-home-link">
            <span class="sidebar-brand">{$companyname|escape}</span>
        </a>
    </div>
    <div class="sidebar-search">
        <form action="{$WEB_ROOT}/knowledgebase.php" method="get">
            <input type="text" name="search" class="sidebar-search-input" placeholder="{$LANG.searchbutton|default:'Search'}">
        </form>
    </div>
    <nav class="sidebar-nav">
        {* Portal home — always shown *}
        <a href="{$WEB_ROOT}/" class="sidebar-item" data-nav="portal-home">
            <div class="sidebar-item-icon blue"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M3 12l9-9 9 9M5 10v10h14V10"/></svg></div>
            {$LANG.home|default:'Portal Home'}
        </a>
        {* Dashboard — logged-in only *}
        <a href="{$WEB_ROOT}/clientarea.php" class="sidebar-item only-in" data-nav="dashboard">
            <div class="sidebar-item-icon indigo"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="3" width="7" height="7" rx="1"/><rect x="14" y="3" width="7" height="7" rx="1"/><rect x="3" y="14" width="7" height="7" rx="1"/><rect x="14" y="14" width="7" height="7" rx="1"/></svg></div>
            {$LANG.clientareanavhome|default:'Dashboard'}
        </a>

        {* ═══ Logged-out tree ═══ *}
        <div class="sidebar-section-label only-out">{$LANG.shop|default:'Shop'}</div>
        <a href="{$WEB_ROOT}/cart.php" class="sidebar-item only-out">
            <div class="sidebar-item-icon teal"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="9" cy="21" r="1"/><circle cx="20" cy="21" r="1"/><path d="M1 1h4l2.68 13.39a2 2 0 002 1.61h9.72a2 2 0 002-1.61L23 6H6"/></svg></div>
            {$LANG.orderproducts|default:'Browse Products'}
        </a>

        <div class="sidebar-section-label only-out">{$LANG.navdomains|default:'Domains'}</div>
        <a href="{$WEB_ROOT}/cart.php?a=add&domain=register" class="sidebar-item only-out">
            <div class="sidebar-item-icon green"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="2" y1="12" x2="22" y2="12"/><path d="M12 2a15.3 15.3 0 014 10 15.3 15.3 0 01-4 10 15.3 15.3 0 01-4-10 15.3 15.3 0 014-10z"/></svg></div>
            {$LANG.registerdomain|default:'Register a Domain'}
        </a>
        <a href="{$WEB_ROOT}/cart.php?a=add&domain=transfer" class="sidebar-item only-out">
            <div class="sidebar-item-icon teal"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M10 13a5 5 0 007.54.54l3-3a5 5 0 00-7.07-7.07l-1.72 1.71"/><path d="M14 11a5 5 0 00-7.54-.54l-3 3a5 5 0 007.07 7.07l1.71-1.71"/></svg></div>
            {$LANG.transferdomain|default:'Transfer a Domain'}
        </a>

        <div class="sidebar-section-label only-out">{$LANG.information|default:'Information'}</div>
        <a href="{$WEB_ROOT}/announcements.php" class="sidebar-item only-out">
            <div class="sidebar-item-icon pink"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M18 8A6 6 0 006 8c0 7-3 9-3 9h18s-3-2-3-9"/><path d="M13.73 21a2 2 0 01-3.46 0"/></svg></div>
            {$LANG.announcementstitle|default:'Announcements'}
        </a>
        <a href="{$WEB_ROOT}/knowledgebase.php" class="sidebar-item only-out">
            <div class="sidebar-item-icon orange"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M2 3h6a4 4 0 014 4v14a3 3 0 00-3-3H2z"/><path d="M22 3h-6a4 4 0 00-4 4v14a3 3 0 013-3h7z"/></svg></div>
            {$LANG.knowledgebasetitle|default:'Knowledgebase'}
        </a>
        <a href="{$WEB_ROOT}/serverstatus.php" class="sidebar-item only-out">
            <div class="sidebar-item-icon gray"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="2" y="4" width="20" height="7" rx="1.5"/><rect x="2" y="13" width="20" height="7" rx="1.5"/></svg></div>
            {$LANG.networkstatus|default:'Network Status'}
        </a>
        <a href="{$WEB_ROOT}/contact.php" class="sidebar-item only-out">
            <div class="sidebar-item-icon blue"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21 15a2 2 0 01-2 2H7l-4 4V5a2 2 0 012-2h14a2 2 0 012 2z"/></svg></div>
            {$LANG.contactus|default:'Contact Us'}
        </a>

        {* ═══ Logged-in tree ═══ *}
        <div class="sidebar-section-label only-in">{$LANG.servicestab|default:'Services'}</div>
        <a href="{$WEB_ROOT}/clientarea.php?action=services" class="sidebar-item only-in" data-nav="services">
            <div class="sidebar-item-icon purple"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="2" y="3" width="20" height="14" rx="2"/><path d="M8 21h8"/><path d="M12 17v4"/></svg></div>
            {$LANG.navservices|default:'My Services'}
            {if $clientsstats.productsnumactive > 0}<span class="sidebar-item-badge">{$clientsstats.productsnumactive}</span>{/if}
        </a>

        <div class="sidebar-section-label only-in">{$LANG.navdomains|default:'Domains'}</div>
        <a href="{$WEB_ROOT}/clientarea.php?action=domains" class="sidebar-item only-in" data-nav="domains">
            <div class="sidebar-item-icon green"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="2" y1="12" x2="22" y2="12"/><path d="M12 2a15.3 15.3 0 014 10 15.3 15.3 0 01-4 10 15.3 15.3 0 01-4-10 15.3 15.3 0 014-10z"/></svg></div>
            {$LANG.navdomains|default:'My Domains'}
            {if $clientsstats.numactivedomains > 0}<span class="sidebar-item-badge">{$clientsstats.numactivedomains}</span>{/if}
        </a>

        <div class="sidebar-section-label only-in">{$LANG.invoicestab|default:'Billing'}</div>
        <a href="{$WEB_ROOT}/clientarea.php?action=invoices" class="sidebar-item only-in" data-nav="invoices">
            <div class="sidebar-item-icon indigo"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="1" y="4" width="22" height="16" rx="2"/><line x1="1" y1="10" x2="23" y2="10"/></svg></div>
            {$LANG.navinvoices|default:'Invoices'}
            {if $clientsstats.numunpaidinvoices > 0}<span class="sidebar-item-badge">{$clientsstats.numunpaidinvoices}</span>{/if}
        </a>
        <a href="{$WEB_ROOT}/clientarea.php?action=quotes" class="sidebar-item only-in" data-nav="quotes">
            <div class="sidebar-item-icon orange"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M14 2H6a2 2 0 00-2 2v16a2 2 0 002 2h12a2 2 0 002-2V8z"/><polyline points="14 2 14 8 20 8"/></svg></div>
            {$LANG.navquotes|default:'Quotes'}
        </a>
        <a href="{$WEB_ROOT}/clientarea.php?action=paymentmethods" class="sidebar-item only-in" data-nav="payment-methods">
            <div class="sidebar-item-icon gray"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21 12V7H5a2 2 0 010-4h14v4"/><path d="M3 5v14a2 2 0 002 2h16v-5"/><path d="M18 12a2 2 0 000 4h4v-4Z"/></svg></div>
            {$LANG.paymentMethods.title|default:'Payment Methods'}
        </a>

        <div class="sidebar-section-label only-in">{$LANG.supporttickets|default:'Support'}</div>
        <a href="{$WEB_ROOT}/supporttickets.php" class="sidebar-item only-in" data-nav="tickets">
            <div class="sidebar-item-icon red"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21 15a2 2 0 01-2 2H7l-4 4V5a2 2 0 012-2h14a2 2 0 012 2z"/></svg></div>
            {$LANG.navtickets|default:'Tickets'}
            {if $clientsstats.numactivetickets > 0}<span class="sidebar-item-badge">{$clientsstats.numactivetickets}</span>{/if}
        </a>
        <a href="{$WEB_ROOT}/submitticket.php" class="sidebar-item only-in">
            <div class="sidebar-item-icon green"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 5v14M5 12h14"/></svg></div>
            {$LANG.opennewticket|default:'Open Ticket'}
        </a>
        <a href="{$WEB_ROOT}/knowledgebase.php" class="sidebar-item only-in" data-nav="knowledgebase">
            <div class="sidebar-item-icon orange"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M2 3h6a4 4 0 014 4v14a3 3 0 00-3-3H2z"/><path d="M22 3h-6a4 4 0 00-4 4v14a3 3 0 013-3h7z"/></svg></div>
            {$LANG.knowledgebasetitle|default:'Knowledgebase'}
        </a>
        <a href="{$WEB_ROOT}/announcements.php" class="sidebar-item only-in" data-nav="announcements">
            <div class="sidebar-item-icon pink"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M18 8A6 6 0 006 8c0 7-3 9-3 9h18s-3-2-3-9"/><path d="M13.73 21a2 2 0 01-3.46 0"/></svg></div>
            {$LANG.announcementstitle|default:'Announcements'}
        </a>

        <div class="sidebar-section-label only-in">{$LANG.accounttab|default:'Account'}</div>
        <a href="{$WEB_ROOT}/clientarea.php?action=details" class="sidebar-item only-in" data-nav="details">
            <div class="sidebar-item-icon gray"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M20 21v-2a4 4 0 00-4-4H8a4 4 0 00-4 4v2"/><circle cx="12" cy="7" r="4"/></svg></div>
            {$LANG.navchangedetails|default:'My Details'}
        </a>
        <a href="{$WEB_ROOT}/clientarea.php?action=security" class="sidebar-item only-in" data-nav="security-account">
            <div class="sidebar-item-icon gray"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="11" width="18" height="11" rx="2"/><path d="M7 11V7a5 5 0 0110 0v4"/></svg></div>
            {$LANG.navsecurity|default:'Security'}
        </a>
    </nav>
    <div class="sidebar-footer">
        {if $loggedin}
            <div class="profile-dropdown-wrapper only-in">
                <div class="sidebar-user" role="button" tabindex="0" onclick="togglePortalProfile && togglePortalProfile(event, 'sidebar')">
                    <div class="sidebar-avatar">{$user_initials|default:'U'}</div>
                    <div class="sidebar-user-info">
                        <div class="sidebar-user-name">{$user_fullname|escape}</div>
                        <div class="sidebar-user-email">{$_email|escape}</div>
                    </div>
                </div>
            </div>
        {else}
            <div class="only-out" style="padding:12px;display:flex;flex-direction:column;gap:8px">
                <a href="{$WEB_ROOT}/login.php" style="padding:9px 14px;border-radius:10px;background:var(--color-accent);color:#fff;text-align:center;font-size:13px;font-weight:500;text-decoration:none">{$LANG.login|default:'Sign in'}</a>
                <a href="{$WEB_ROOT}/register.php" style="padding:9px 14px;border-radius:10px;background:var(--color-surface-secondary);color:var(--color-text-primary);text-align:center;font-size:13px;font-weight:500;text-decoration:none">{$LANG.createaccount|default:'Create account'}</a>
            </div>
        {/if}
    </div>
</aside>
