{* Hostnodes - secondary flyout panels for the 80px icon rail.

   Rendered as a SIBLING of .ph-rail (both sit before .ph-main-wrap), never
   nested inside it: initRail() in assets/js/apple-layout.js binds
   mouseleave/mouseenter to .ph-rail and .ph-rail-panel independently, and the
   180ms cancelClose bridge only works while the two boxes are edge-adjacent
   (panel is left:80px, exactly the rail's width).

   Each [data-panel] MUST match a [data-rail] on a button in rail.tpl --
   openFor() pairs them by plain string equality (item.dataset.rail ===
   g.dataset.panel), with no DOM traversal. rail.tpl currently emits 8:
   shop-out, domains-out, info-out (logged-out) and services, domains-in,
   billing, support, account (logged-in). Adding a group here without its
   button is dead markup that can never open.

   No group carries .active on render. openFor() always sets the correct group
   BEFORE adding body.rail-panel-open, so a preset active group is never seen
   and two preset groups (as in the apple-client-area mockup) would stack.

   Groups render unconditionally, not behind {if $loggedin}: .only-out/.only-in
   on the rail BUTTONS do the gating in CSS, which is also what lets the
   ?preview=1 state-chip flip auth live without a page load.

   Do NOT add a "Domain Search" link to domainchecker.php here. That endpoint is
   POST-only in practice -- every other reference in this theme is a <form
   method="post"> action, never an <a href>. A bare GET 302s harmlessly while
   logged out, but while logged IN it tries to redirect to
   clientarea.php?action=domains and WHMCS rejects the absolute URL with
   "Invalid filename for redirect", dropping the client on an error page.
   cart.php?a=add&domain=register IS the domain search, and it is already
   linked here as "Register a New Domain". *}
<aside class="ph-rail-panel only-rail" aria-label="{$hadrianLang.rail.panelLabel}">

    {* ---- Logged-out ---- *}
    <div class="ph-rail-panel-group" data-panel="shop-out">
        <div class="ph-rail-panel-header"><h3>{$LANG.shop|default:'Shop'}</h3></div>
        <div class="ph-rail-panel-items">
            <a href="{$WEB_ROOT}/cart.php"><svg class="lead-ico" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="3" width="7" height="7" rx="1"/><rect x="14" y="3" width="7" height="7" rx="1"/><rect x="3" y="14" width="7" height="7" rx="1"/><rect x="14" y="14" width="7" height="7" rx="1"/></svg>{$hadrianLang.rail.browseAll}</a>
            <a href="{$WEB_ROOT}/cart.php?a=add&amp;domain=register"><svg class="lead-ico" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="2" y1="12" x2="22" y2="12"/><path d="M12 2a15.3 15.3 0 014 10 15.3 15.3 0 01-4 10 15.3 15.3 0 01-4-10 15.3 15.3 0 014-10z"/></svg>{$hadrianLang.rail.registerDomain}</a>
            <a href="{$WEB_ROOT}/cart.php?a=add&amp;domain=transfer"><svg class="lead-ico" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M7 17l-4-4 4-4"/><path d="M3 13h14"/><path d="M17 7l4 4-4 4"/></svg>{$hadrianLang.rail.transferDomain}</a>
        </div>
    </div>

    <div class="ph-rail-panel-group" data-panel="domains-out">
        <div class="ph-rail-panel-header"><h3>{$LANG.navdomains}</h3></div>
        <div class="ph-rail-panel-items">
            <a href="{$WEB_ROOT}/cart.php?a=add&amp;domain=register"><svg class="lead-ico" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="2" y1="12" x2="22" y2="12"/><path d="M12 2a15.3 15.3 0 014 10 15.3 15.3 0 01-4 10 15.3 15.3 0 01-4-10 15.3 15.3 0 014-10z"/></svg>{$hadrianLang.rail.registerDomain}</a>
            <a href="{$WEB_ROOT}/cart.php?a=add&amp;domain=transfer"><svg class="lead-ico" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M7 17l-4-4 4-4"/><path d="M3 13h14"/><path d="M17 7l4 4-4 4"/></svg>{$hadrianLang.rail.transferDomain}</a>        </div>
    </div>

    <div class="ph-rail-panel-group" data-panel="info-out">
        <div class="ph-rail-panel-header"><h3>{$LANG.supporttickets|default:'Support'}</h3></div>
        <div class="ph-rail-panel-items">
            <a href="{$WEB_ROOT}/knowledgebase.php"><svg class="lead-ico" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M4 19.5A2.5 2.5 0 016.5 17H20"/><path d="M6.5 2H20v20H6.5A2.5 2.5 0 014 19.5v-15A2.5 2.5 0 016.5 2z"/></svg>{$hadrianLang.rail.knowledgebase}</a>
            <a href="{$WEB_ROOT}/announcements.php"><svg class="lead-ico" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M3 11l18-8v18l-18-8z"/><path d="M11.6 16.8a3 3 0 11-5.8-1.6"/></svg>{$hadrianLang.rail.announcements}</a>
            <a href="{$WEB_ROOT}/serverstatus.php"><svg class="lead-ico" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><rect x="2" y="2" width="20" height="8" rx="2"/><rect x="2" y="14" width="20" height="8" rx="2"/><line x1="6" y1="6" x2="6.01" y2="6"/><line x1="6" y1="18" x2="6.01" y2="18"/></svg>{$hadrianLang.rail.networkStatus}</a>
            <a href="{$WEB_ROOT}/contact.php"><svg class="lead-ico" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M21 15a2 2 0 01-2 2H7l-4 4V5a2 2 0 012-2h14a2 2 0 012 2z"/></svg>{$hadrianLang.rail.contactUs}</a>
        </div>
    </div>

    {* ---- Logged-in ---- *}
    <div class="ph-rail-panel-group" data-panel="services">
        <div class="ph-rail-panel-header"><h3>{$LANG.navservices}</h3></div>
        <div class="ph-rail-panel-items">
            <a href="{$WEB_ROOT}/clientarea.php?action=services"><svg class="lead-ico" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><rect x="2" y="3" width="20" height="14" rx="2"/><path d="M8 21h8"/><path d="M12 17v4"/></svg>{$hadrianLang.rail.myServices}</a>
            <a href="{$WEB_ROOT}/cart.php"><svg class="lead-ico" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="9" cy="21" r="1"/><circle cx="20" cy="21" r="1"/><path d="M1 1h4l2.68 13.39a2 2 0 002 1.61h9.72a2 2 0 002-1.61L23 6H6"/></svg>{$hadrianLang.rail.orderServices}</a>
        </div>
    </div>

    <div class="ph-rail-panel-group" data-panel="domains-in">
        <div class="ph-rail-panel-header"><h3>{$LANG.navdomains}</h3></div>
        <div class="ph-rail-panel-items">
            <a href="{$WEB_ROOT}/clientarea.php?action=domains"><svg class="lead-ico" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="2" y1="12" x2="22" y2="12"/><path d="M12 2a15.3 15.3 0 014 10 15.3 15.3 0 01-4 10 15.3 15.3 0 01-4-10 15.3 15.3 0 014-10z"/></svg>{$hadrianLang.rail.myDomains}</a>
            <a href="{$WEB_ROOT}/cart.php?a=add&amp;domain=register"><svg class="lead-ico" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><path d="M12 8v8M8 12h8"/></svg>{$hadrianLang.rail.registerDomain}</a>
            <a href="{$WEB_ROOT}/cart.php?a=add&amp;domain=transfer"><svg class="lead-ico" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M7 17l-4-4 4-4"/><path d="M3 13h14"/><path d="M17 7l4 4-4 4"/></svg>{$hadrianLang.rail.transferDomain}</a>        </div>
    </div>

    <div class="ph-rail-panel-group" data-panel="billing">
        <div class="ph-rail-panel-header"><h3>{$LANG.invoicestab|default:'Billing'}</h3></div>
        <div class="ph-rail-panel-items">
            <a href="{$WEB_ROOT}/clientarea.php?action=invoices"><svg class="lead-ico" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M14 2H6a2 2 0 00-2 2v16a2 2 0 002 2h12a2 2 0 002-2V8z"/><polyline points="14 2 14 8 20 8"/></svg>{$hadrianLang.rail.myInvoices}</a>
            <a href="{$WEB_ROOT}/clientarea.php?action=quotes"><svg class="lead-ico" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M9 11H5a2 2 0 00-2 2v7h18v-7a2 2 0 00-2-2h-4"/><path d="M9 11V4a2 2 0 012-2h2a2 2 0 012 2v7"/></svg>{$hadrianLang.rail.myQuotes}</a>
            <a href="{routePath('account-paymentmethods')}"><svg class="lead-ico" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><rect x="1" y="4" width="22" height="16" rx="2"/><line x1="1" y1="10" x2="23" y2="10"/></svg>{$LANG.paymentMethods.title}</a>
            <a href="{$WEB_ROOT}/clientarea.php?action=addfunds"><svg class="lead-ico" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="16"/><line x1="8" y1="12" x2="16" y2="12"/></svg>{$hadrianLang.rail.addFunds}</a>
        </div>
    </div>

    <div class="ph-rail-panel-group" data-panel="support">
        <div class="ph-rail-panel-header"><h3>{$LANG.supporttickets|default:'Support'}</h3></div>
        <div class="ph-rail-panel-items">
            <a href="{$WEB_ROOT}/supporttickets.php"><svg class="lead-ico" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M21 15a2 2 0 01-2 2H7l-4 4V5a2 2 0 012-2h14a2 2 0 012 2z"/></svg>{$hadrianLang.rail.myTickets}</a>
            <a href="{$WEB_ROOT}/submitticket.php"><svg class="lead-ico" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="16"/><line x1="8" y1="12" x2="16" y2="12"/></svg>{$hadrianLang.rail.openTicket}</a>
            <a href="{$WEB_ROOT}/knowledgebase.php"><svg class="lead-ico" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M4 19.5A2.5 2.5 0 016.5 17H20"/><path d="M6.5 2H20v20H6.5A2.5 2.5 0 014 19.5v-15A2.5 2.5 0 016.5 2z"/></svg>{$hadrianLang.rail.knowledgebase}</a>
            <a href="{$WEB_ROOT}/downloads.php"><svg class="lead-ico" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M21 15v4a2 2 0 01-2 2H5a2 2 0 01-2-2v-4"/><polyline points="7 10 12 15 17 10"/><line x1="12" y1="15" x2="12" y2="3"/></svg>{$hadrianLang.rail.downloads}</a>
            <a href="{$WEB_ROOT}/announcements.php"><svg class="lead-ico" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M3 11l18-8v18l-18-8z"/><path d="M11.6 16.8a3 3 0 11-5.8-1.6"/></svg>{$hadrianLang.rail.announcements}</a>
            <a href="{$WEB_ROOT}/serverstatus.php"><svg class="lead-ico" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><rect x="2" y="2" width="20" height="8" rx="2"/><rect x="2" y="14" width="20" height="8" rx="2"/><line x1="6" y1="6" x2="6.01" y2="6"/><line x1="6" y1="18" x2="6.01" y2="18"/></svg>{$hadrianLang.rail.networkStatus}</a>
        </div>
    </div>

    <div class="ph-rail-panel-group" data-panel="account">
        <div class="ph-rail-panel-header"><h3>{$LANG.accounttab|default:'Account'}</h3></div>
        <div class="ph-rail-panel-items">
            <a href="{$WEB_ROOT}/clientarea.php?action=details"><svg class="lead-ico" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M20 21v-2a4 4 0 00-4-4H8a4 4 0 00-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>{$LANG.accountdetails}</a>
            <a href="{$WEB_ROOT}/clientarea.php?action=contacts"><svg class="lead-ico" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M17 21v-2a4 4 0 00-4-4H5a4 4 0 00-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 00-3-3.87"/></svg>{$LANG.contacts}</a>
            <a href="{$WEB_ROOT}/clientarea.php?action=security"><svg class="lead-ico" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/></svg>{$LANG.securitysettings}</a>
            <a href="{$WEB_ROOT}/clientarea.php?action=changepw"><svg class="lead-ico" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="11" width="18" height="11" rx="2"/><path d="M7 11V7a5 5 0 0110 0v4"/></svg>{$LANG.clientareanavchangepassword}</a>
            <a href="{$WEB_ROOT}/clientarea.php?action=emails"><svg class="lead-ico" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><rect x="2" y="4" width="20" height="16" rx="2"/><path d="M22 6l-10 7L2 6"/></svg>{$LANG.emailstitle}</a>
            <a href="{$WEB_ROOT}/logout.php"><svg class="lead-ico" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M9 21H5a2 2 0 01-2-2V5a2 2 0 012-2h4"/><polyline points="16 17 21 12 16 7"/><line x1="21" y1="12" x2="9" y2="12"/></svg>{$LANG.logout}</a>
        </div>
    </div>
</aside>
