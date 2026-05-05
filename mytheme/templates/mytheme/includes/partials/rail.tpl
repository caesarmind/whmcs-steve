{* Hostnodes — 80px icon rail (rendered when body[data-layout="rail"]).
   Paired with rail-panels for hover flyouts. *}
<aside class="ph-rail only-rail">
    <a href="{$WEB_ROOT}/" class="ph-rail-logo" aria-label="{$LANG.home|default:'Portal Home'}">
        <svg viewBox="0 0 24 24" fill="currentColor"><rect x="4" y="4" width="16" height="16" rx="4"/></svg>
    </a>
    <div class="ph-rail-items">
        {* Logged-out *}
        <button type="button" class="ph-rail-item only-out" data-rail="shop-out">
            <span class="rail-ico teal"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="9" cy="21" r="1"/><circle cx="20" cy="21" r="1"/><path d="M1 1h4l2.68 13.39a2 2 0 002 1.61h9.72a2 2 0 002-1.61L23 6H6"/></svg></span>
            <span>{$LANG.shop|default:'Shop'}</span>
        </button>
        <button type="button" class="ph-rail-item only-out" data-rail="domains-out">
            <span class="rail-ico green"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="2" y1="12" x2="22" y2="12"/><path d="M12 2a15.3 15.3 0 014 10 15.3 15.3 0 01-4 10 15.3 15.3 0 01-4-10 15.3 15.3 0 014-10z"/></svg></span>
            <span>{$LANG.navdomains|default:'Domains'}</span>
        </button>
        <button type="button" class="ph-rail-item only-out" data-rail="info-out">
            <span class="rail-ico red"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M21 15a2 2 0 01-2 2H7l-4 4V5a2 2 0 012-2h14a2 2 0 012 2z"/></svg></span>
            <span>{$LANG.supporttickets|default:'Support'}</span>
        </button>

        {* Logged-in *}
        <a href="{$WEB_ROOT}/clientarea.php" class="ph-rail-item only-in" data-nav="dashboard">
            <span class="rail-ico blue"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="3" width="7" height="7" rx="1"/><rect x="14" y="3" width="7" height="7" rx="1"/><rect x="3" y="14" width="7" height="7" rx="1"/><rect x="14" y="14" width="7" height="7" rx="1"/></svg></span>
            <span>{$LANG.clientareanavhome|default:'Dashboard'}</span>
        </a>
        <button type="button" class="ph-rail-item only-in" data-rail="services" data-nav="services">
            <span class="rail-ico purple"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><rect x="2" y="3" width="20" height="14" rx="2"/><path d="M8 21h8"/><path d="M12 17v4"/></svg></span>
            <span>{$LANG.navservices|default:'Services'}</span>
        </button>
        <button type="button" class="ph-rail-item only-in" data-rail="domains-in" data-nav="domains">
            <span class="rail-ico green"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="2" y1="12" x2="22" y2="12"/><path d="M12 2a15.3 15.3 0 014 10 15.3 15.3 0 01-4 10 15.3 15.3 0 01-4-10 15.3 15.3 0 014-10z"/></svg></span>
            <span>{$LANG.navdomains|default:'Domains'}</span>
        </button>
        <button type="button" class="ph-rail-item only-in" data-rail="billing" data-nav="billing">
            <span class="rail-ico indigo"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><rect x="1" y="4" width="22" height="16" rx="2"/><line x1="1" y1="10" x2="23" y2="10"/></svg></span>
            <span>{$LANG.invoicestab|default:'Billing'}</span>
        </button>
        <button type="button" class="ph-rail-item only-in" data-rail="support" data-nav="support">
            <span class="rail-ico red"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M21 15a2 2 0 01-2 2H7l-4 4V5a2 2 0 012-2h14a2 2 0 012 2z"/></svg></span>
            <span>{$LANG.supporttickets|default:'Support'}</span>
        </button>
        <button type="button" class="ph-rail-item only-in" data-rail="account" data-nav="account">
            <span class="rail-ico gray"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M20 21v-2a4 4 0 00-4-4H8a4 4 0 00-4 4v2"/><circle cx="12" cy="7" r="4"/></svg></span>
            <span>{$LANG.accounttab|default:'Account'}</span>
        </button>
    </div>
    <div class="ph-rail-spacer"></div>
    {if $loggedin}
        <a href="{$WEB_ROOT}/clientarea.php?action=details" class="ph-rail-user only-in">{($clientsdetails.firstname|default:'')|truncate:1:''|upper}</a>
    {else}
        <a href="{$WEB_ROOT}/login.php" class="ph-rail-item only-out" style="margin-top:auto">
            <span class="rail-ico" style="background:var(--color-accent);color:#fff"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M15 3h4a2 2 0 012 2v14a2 2 0 01-2 2h-4"/><polyline points="10 17 15 12 10 7"/><line x1="15" y1="12" x2="3" y2="12"/></svg></span>
            <span>{$LANG.login|default:'Sign in'}</span>
        </a>
    {/if}
</aside>
