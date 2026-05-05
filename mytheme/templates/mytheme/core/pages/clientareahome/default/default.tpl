{* Client Home dashboard — Hostnodes Apple-style.
   Variables expected from WHMCS:
     $clientsdetails.firstname / .lastname / .email
     $clientsstats.productsnumactive
     $clientsstats.numactivedomains
     $clientsstats.numunpaidinvoices
     $clientsstats.unpaidinvoicesamount  (formatted)
     $clientsstats.numactivetickets
     $panels — Menu\Item collection populated by WHMCS for clientareahome
   Optional from MyTheme hooks ($myTheme.dashboard):
     activeServices[], recentInvoices[], openTickets[], announcement *}

{$user_firstname = $clientsdetails.firstname|default:'there'}

<div class="greeting">
    <h1 class="greeting-title" id="greetingTitle">Welcome back, {$user_firstname|escape}.</h1>
    <p class="greeting-subtitle">Here's what's happening with your account.</p>
</div>

{* === Summary Tiles === *}
<div class="summary-tiles">
    <a href="{$WEB_ROOT}/clientarea.php?action=services" class="tile">
        <div class="tile-icon blue">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="2" y="3" width="20" height="14" rx="2"/><path d="M8 21h8"/><path d="M12 17v4"/></svg>
        </div>
        <div class="tile-value">{$clientsstats.productsnumactive|default:0}</div>
        <div class="tile-label">{$LANG.servicesactive|default:'Active Services'}</div>
    </a>

    <a href="{$WEB_ROOT}/clientarea.php?action=domains" class="tile">
        <div class="tile-icon green">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="2" y1="12" x2="22" y2="12"/><path d="M12 2a15.3 15.3 0 0 1 4 10 15.3 15.3 0 0 1-4 10 15.3 15.3 0 0 1-4-10 15.3 15.3 0 0 1 4-10z"/></svg>
        </div>
        <div class="tile-value">{$clientsstats.numactivedomains|default:0}</div>
        <div class="tile-label">{$LANG.navdomains|default:'Domains'}</div>
    </a>

    <a href="{$WEB_ROOT}/clientarea.php?action=invoices" class="tile">
        <div class="tile-icon orange">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="1" y="4" width="22" height="16" rx="2"/><line x1="1" y1="10" x2="23" y2="10"/></svg>
        </div>
        <div class="tile-value">
            {if $clientsstats.unpaidinvoicesamount}{$clientsstats.unpaidinvoicesamount}{else}{$clientsstats.numunpaidinvoices|default:0}{/if}
        </div>
        <div class="tile-label">{$LANG.clientHomePanels.unpaidInvoices|default:'Unpaid Invoices'}</div>
    </a>

    <a href="{$WEB_ROOT}/supporttickets.php" class="tile">
        <div class="tile-icon red">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"/></svg>
        </div>
        <div class="tile-value">{$clientsstats.numactivetickets|default:0}</div>
        <div class="tile-label">{$LANG.supportTicketsOpen|default:'Open Tickets'}</div>
    </a>
</div>

{* === Active Services === *}
<div class="card">
    <div class="card-header">
        <h2 class="card-title">{$LANG.clientHomePanels.activeProductsServices|default:'Active Services'}</h2>
        <a href="{$WEB_ROOT}/clientarea.php?action=services" class="card-action">
            {$LANG.viewall|default:'View All'} <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><polyline points="9 18 15 12 9 6"/></svg>
        </a>
    </div>
    <div class="card-body">
        {if $dashboard.activeServices && $dashboard.activeServices|count > 0}
            {foreach $dashboard.activeServices as $svc}
                <div class="service-item">
                    <div class="service-icon">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><rect x="2" y="3" width="20" height="14" rx="2"/><path d="M8 21h8"/><path d="M12 17v4"/></svg>
                    </div>
                    <div class="service-info">
                        <div class="service-name">{$svc.name|escape}</div>
                        {if $svc.domain}<div class="service-domain">{$svc.domain|escape}</div>{/if}
                    </div>
                    <div class="service-meta">
                        <span class="status-pill {$svc.status|lower|default:'active'}">{$svc.status|escape|default:'Active'}</span>
                        {if $svc.nextDueDate}
                            <div class="service-due">
                                <div>{$svc.nextDueDate|escape}</div>
                                <div class="service-due-label">{$LANG.invoicesduedate|default:'Next due'}</div>
                            </div>
                        {/if}
                        <a href="{$svc.manageUrl|default:"`$WEB_ROOT`/clientarea.php?action=productdetails&id=`$svc.id`"}" class="service-manage">
                            {$LANG.manageproduct|default:'Manage'} <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><polyline points="9 18 15 12 9 6"/></svg>
                        </a>
                    </div>
                </div>
            {/foreach}
        {else}
            <p style="padding:8px 4px;color:var(--color-text-tertiary);font-size:14px">
                {$LANG.noproductsactive|default:'No active services yet.'}
                <a href="{$WEB_ROOT}/cart.php">{$LANG.orderproducts|default:'Order a service'}</a>
            </p>
        {/if}
    </div>
</div>

{* === Recent Invoices === *}
<div class="card">
    <div class="card-header">
        <h2 class="card-title">{$LANG.clientHomePanels.recentInvoices|default:'Recent Invoices'}</h2>
        <a href="{$WEB_ROOT}/clientarea.php?action=invoices" class="card-action">
            {$LANG.viewall|default:'View All'} <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><polyline points="9 18 15 12 9 6"/></svg>
        </a>
    </div>
    <div class="card-body">
        {if $dashboard.recentInvoices && $dashboard.recentInvoices|count > 0}
            <table class="invoice-table">
                <thead>
                    <tr>
                        <th>{$LANG.invoicenumber|default:'Invoice'}</th>
                        <th>{$LANG.invoicesdatecreated|default:'Date'}</th>
                        <th>{$LANG.invoicestotal|default:'Amount'}</th>
                        <th>{$LANG.invoicesstatus|default:'Status'}</th>
                        <th></th>
                    </tr>
                </thead>
                <tbody>
                    {foreach $dashboard.recentInvoices as $inv}
                        <tr>
                            <td><a href="{$WEB_ROOT}/viewinvoice.php?id={$inv.id}" class="invoice-id">#{$inv.id|escape}</a></td>
                            <td class="invoice-date">{$inv.date|escape}</td>
                            <td class="invoice-amount">{$inv.total|escape}</td>
                            <td><span class="status-pill {$inv.status|lower}">{$inv.status|escape}</span></td>
                            <td>
                                <a href="{$WEB_ROOT}/viewinvoice.php?id={$inv.id}" class="service-manage">
                                    {$LANG.viewinvoice|default:'View'} <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><polyline points="9 18 15 12 9 6"/></svg>
                                </a>
                            </td>
                        </tr>
                    {/foreach}
                </tbody>
            </table>
        {else}
            <p style="padding:8px 4px;color:var(--color-text-tertiary);font-size:14px">
                {$LANG.noinvoicesfound|default:'No recent invoices.'}
            </p>
        {/if}
    </div>
</div>

{* === Open Tickets === *}
{if $dashboard.openTickets && $dashboard.openTickets|count > 0}
    <div class="card">
        <div class="card-header">
            <h2 class="card-title">{$LANG.supportTicketsOpen|default:'Open Tickets'}</h2>
            <a href="{$WEB_ROOT}/supporttickets.php" class="card-action">
                {$LANG.viewall|default:'View All'} <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><polyline points="9 18 15 12 9 6"/></svg>
            </a>
        </div>
        <div class="card-body">
            {foreach $dashboard.openTickets as $tkt}
                <div class="ticket-item">
                    <div class="ticket-priority {$tkt.priority|lower|default:'medium'}"></div>
                    <div class="ticket-info">
                        <div class="ticket-subject">{$tkt.subject|escape}</div>
                        <div class="ticket-meta-text">#{$tkt.tid|escape} · Opened {$tkt.date|escape} · {$tkt.priority|escape} Priority</div>
                    </div>
                    <span class="status-pill {$tkt.status|lower}">{$tkt.status|escape}</span>
                    <a href="{$WEB_ROOT}/viewticket.php?tid={$tkt.tid|escape}&c={$tkt.c|escape}" class="service-manage">
                        {$LANG.viewinvoice|default:'View'} <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><polyline points="9 18 15 12 9 6"/></svg>
                    </a>
                </div>
            {/foreach}
        </div>
    </div>
{/if}

{* === Two-column: Announcement + Help === *}
<div class="split-row">
    <div class="card">
        <div class="card-header">
            <h2 class="card-title">{$LANG.announcementstitle|default:'Announcements'}</h2>
            <a href="{$WEB_ROOT}/announcements.php" class="card-action">
                {$LANG.viewall|default:'View All'} <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><polyline points="9 18 15 12 9 6"/></svg>
            </a>
        </div>
        <div class="card-body">
            {if $publishedAnnouncements && $publishedAnnouncements|count > 0}
                {$ann = $publishedAnnouncements|@reset}
                {if $ann.tag}<div class="announcement-tag">{$ann.tag|escape}</div>{/if}
                <h3 class="announcement-title"><a href="{$WEB_ROOT}/announcements.php?id={$ann.id}">{$ann.title|escape}</a></h3>
                <p class="announcement-excerpt">{$ann.announcement}</p>
                <div class="announcement-date">{$ann.date|escape}</div>
            {else}
                <p style="color:var(--color-text-tertiary);font-size:14px;padding:8px 0">
                    {$LANG.announcementsnone|default:'No announcements yet.'}
                </p>
            {/if}
        </div>
    </div>

    <div class="card">
        <div class="card-body">
            <div class="help-card-inner">
                <div class="help-icon">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><path d="M9.09 9a3 3 0 0 1 5.83 1c0 2-3 3-3 3"/><line x1="12" y1="17" x2="12.01" y2="17"/></svg>
                </div>
                <div class="help-title">{$LANG.supportticketshelp|default:'Need help?'}</div>
                <div class="help-subtitle">{$LANG.supportticketshelpsub|default:'Our support team is here for you.'}</div>
                <div class="btn-group" style="justify-content: center;">
                    <a href="{$WEB_ROOT}/submitticket.php" class="btn-primary">
                        <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
                        {$LANG.opennewticket|default:'New Ticket'}
                    </a>
                    <a href="{$WEB_ROOT}/knowledgebase.php" class="btn-secondary">{$LANG.knowledgebasetitle|default:'Knowledge Base'}</a>
                </div>
            </div>
        </div>
    </div>
</div>

{* === Quick Actions === *}
<div class="card">
    <div class="card-header">
        <h2 class="card-title">{$LANG.quickactions|default:'Quick Actions'}</h2>
    </div>
    <div class="card-body">
        <div class="quick-actions">
            <a href="{$WEB_ROOT}/clientarea.php?action=invoices" class="quick-action">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="1" y="4" width="22" height="16" rx="2"/><line x1="1" y1="10" x2="23" y2="10"/></svg>
                {$LANG.makepayment|default:'Make a Payment'}
            </a>
            <a href="{$WEB_ROOT}/cart.php?a=add&domain=register" class="quick-action">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="2" y1="12" x2="22" y2="12"/><path d="M12 2a15.3 15.3 0 0 1 4 10 15.3 15.3 0 0 1-4 10 15.3 15.3 0 0 1-4-10 15.3 15.3 0 0 1 4-10z"/></svg>
                {$LANG.registerdomain|default:'Register Domain'}
            </a>
            <a href="{$WEB_ROOT}/cart.php" class="quick-action">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
                {$LANG.orderproducts|default:'Order New Service'}
            </a>
        </div>
    </div>
</div>
