{* Hostnodes — My Domains list (Apple-style).

   WHMCS standard variables expected:
     $domains          — array, each: id, domain, registrationdate, expirydate,
                         nextduedate, recurringamount, status, autorenew
     $startnumber      — pagination start offset
     $pagesize         — rows per page
     $numdomains       — total domain count
*}

{* Resolve totals + empty/full state *}
{if isset($domains) && $domains|count > 0}
    {assign var=dashIsEmpty value='full'}
    {assign var=domCount value=$domains|count}
{else}
    {assign var=dashIsEmpty value='empty'}
    {assign var=domCount value=0}
{/if}

{* Count expiring soon (next 30 days bucket) — naive: rely on status flag if supplied *}
{assign var=expiringCount value=0}
{if isset($domains) && $domains|count > 0}
    {foreach $domains as $_d}
        {if isset($_d.status) && ($_d.status == 'Expiring Soon' || $_d.status == 'Expired')}
            {assign var=expiringCount value=$expiringCount+1}
        {/if}
    {/foreach}
{/if}

{* Page-specific stylesheet *}
<link rel="stylesheet" href="{$WEB_ROOT}/templates/{$template}/assets/css/pages/clientareadomains.css?v={$myTheme.version|default:'1.0'}">

{* Hand layout signals to body for CSS toggles *}
<script>
(function () {
    var b = document.body;
    if (!b) return;
    b.setAttribute('data-data',          '{$dashIsEmpty}');
    b.setAttribute('data-subnav',        'on');
    b.setAttribute('data-svc-layout',    'inside');
})();
</script>

{* Sentinel: enables state-chip Services pill on this page *}
<div class="svc-table-card" aria-hidden="true"></div>

<header class="page-header">
    <div class="page-header-row">
        <div style="flex: 1; min-width: 0;">
            <h1>{$LANG.navdomains|default:'Domains'}</h1>
            <p class="page-subtitle">{$LANG.domainsmanagesub|default:'Manage your registrations, renewals, and DNS.'}</p>
        </div>
        <a href="{$WEB_ROOT}/cart.php?a=add&domain=register" class="page-header-action">
            {$LANG.registeradomain|default:'Register a domain'}
            <svg class="chev" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><polyline points="9 18 15 12 9 6"/></svg>
        </a>
    </div>
</header>

<div class="dom-split">
    {* ══ LEFT: filter tabs + domain list / empty state ══ *}
    <div class="dom-main">

        {* Expiring soon banner *}
        {if $expiringCount > 0}
        <div class="dom-banner when-full">
            <span class="dom-banner-ico">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg>
            </span>
            <span><strong>{$expiringCount} {if $expiringCount == 1}{$LANG.domainsingular|default:'domain'}{else}{$LANG.domainsplural|default:'domains'}{/if}</strong> {$LANG.expirewithin30|default:'expiring in the next 30 days.'}</span>
            <span class="spacer"></span>
            <a href="{$WEB_ROOT}/clientarea.php?action=domains" class="btn-secondary">{$LANG.renewnow|default:'Renew now'}</a>
        </div>
        {/if}

        <div class="filter-tabs when-full">
            <button class="filter-tab active">{$LANG.all|default:'All'}</button>
            <button class="filter-tab">{$LANG.statusactive|default:'Active'}</button>
            <button class="filter-tab">{$LANG.expiringsoon|default:'Expiring Soon'}</button>
            <button class="filter-tab">{$LANG.transferredaway|default:'Transferred Away'}</button>
        </div>

        {* Domains stack: "inside" = unified card; "outside" = card + floating head row + floating pager *}
        <div class="dom-stack">

            <div class="dom-list-head-row when-full">
                <div>{$LANG.domain|default:'Domain'}</div>
                <div>{$LANG.registered|default:'Registered'}</div>
                <div>{$LANG.expires|default:'Expires'}</div>
                <div>{$LANG.status|default:'Status'}</div>
                <div>{$LANG.autorenew|default:'Auto-Renew'}</div>
                <div></div>
            </div>

            <div class="card dom-list-card">

                {if isset($domains) && $domains|count > 0}
                <div class="when-full">
                    <div class="card-body">
                        <div class="domain-list">
                            {foreach $domains as $d}
                            {assign var=statusLower value=$d.status|lower}
                            <div class="domain-row" data-href="{$WEB_ROOT}/clientarea.php?action=domaindetails&id={$d.id}" role="link" tabindex="0">
                                <div class="domain-name">{$d.domain|escape}</div>
                                <div class="domain-date">{$d.registrationdate|escape}</div>
                                <div class="domain-date">{$d.expirydate|escape}</div>
                                <div><span class="status-pill {$statusLower}">{$d.status|escape}</span></div>
                                <div>
                                    <div class="toggle-switch{if isset($d.autorenew) && $d.autorenew} active{/if}" onclick="event.preventDefault(); event.stopPropagation(); this.classList.toggle('active')"></div>
                                </div>
                                <div class="dom-menu-wrap" onclick="event.preventDefault(); event.stopPropagation();">
                                    <button type="button" class="dom-menu-btn" aria-label="{$LANG.actions|default:'Actions'}" aria-haspopup="true" aria-expanded="false" onclick="toggleDomMenu(this)">
                                        <svg viewBox="0 0 24 24" fill="currentColor"><circle cx="5" cy="12" r="2"/><circle cx="12" cy="12" r="2"/><circle cx="19" cy="12" r="2"/></svg>
                                    </button>
                                    <div class="dom-menu" role="menu">
                                        <a href="{$WEB_ROOT}/clientarea.php?action=domaindetails&id={$d.id}" class="dom-menu-item" role="menuitem">
                                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M12 20h9"/><path d="M16.5 3.5a2.121 2.121 0 013 3L7 19l-4 1 1-4 12.5-12.5z"/></svg>
                                            {$LANG.managedomain|default:'Manage Domain'}
                                        </a>
                                        <a href="{$WEB_ROOT}/clientarea.php?action=domaindetails&id={$d.id}&modop=custom&a=nameservers" class="dom-menu-item" role="menuitem">
                                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><rect x="2" y="3" width="20" height="8" rx="1"/><rect x="2" y="13" width="20" height="8" rx="1"/><line x1="6" y1="7" x2="6.01" y2="7"/><line x1="6" y1="17" x2="6.01" y2="17"/></svg>
                                            {$LANG.managens|default:'Manage Nameservers'}
                                        </a>
                                        <a href="{$WEB_ROOT}/clientarea.php?action=domaincontacts&domainid={$d.id}" class="dom-menu-item" role="menuitem">
                                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M20 21v-2a4 4 0 00-4-4H8a4 4 0 00-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>
                                            {$LANG.editcontactinfo|default:'Edit Contact Information'}
                                        </a>
                                        <a href="{$WEB_ROOT}/clientarea.php?action=domaindetails&id={$d.id}" class="dom-menu-item" role="menuitem">
                                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M21 2v6h-6"/><path d="M3 12a9 9 0 0115-6.7L21 8"/><path d="M3 22v-6h6"/><path d="M21 12a9 9 0 01-15 6.7L3 16"/></svg>
                                            {$LANG.autorenewstatus|default:'Auto Renewal Status'}
                                        </a>
                                        <a href="{$WEB_ROOT}/cart.php?gid=renewals" class="dom-menu-item" role="menuitem">
                                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><polyline points="23 4 23 10 17 10"/><polyline points="1 20 1 14 7 14"/><path d="M3.51 9a9 9 0 0114.85-3.36L23 10M1 14l4.64 4.36A9 9 0 0020.49 15"/></svg>
                                            {$LANG.renew|default:'Renew'}
                                        </a>
                                    </div>
                                </div>
                            </div>
                            {/foreach}
                        </div>
                    </div>
                </div>
                {/if}

                {* Empty state *}
                <div class="when-empty dom-empty">
                    <div class="dom-empty-ico">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="2" y1="12" x2="22" y2="12"/><path d="M12 2a15.3 15.3 0 014 10 15.3 15.3 0 01-4 10 15.3 15.3 0 01-4-10 15.3 15.3 0 014-10z"/></svg>
                    </div>
                    <p class="dom-empty-title">{$LANG.nodomains|default:'No domains yet'}</p>
                    <p class="dom-empty-sub">{$LANG.nodomainssub|default:"Register a new domain or transfer one you already own — it'll appear here once the order is processed."}</p>
                    <div class="dom-empty-actions">
                        <a href="{$WEB_ROOT}/cart.php?a=add&domain=register" class="btn-primary">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="16"/><line x1="8" y1="12" x2="16" y2="12"/></svg>
                            {$LANG.registerdomain|default:'Register'}
                        </a>
                        <a href="{$WEB_ROOT}/cart.php?a=add&domain=transfer" class="btn-secondary">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="17 1 21 5 17 9"/><path d="M3 11V9a4 4 0 014-4h14"/><polyline points="7 23 3 19 7 15"/><path d="M21 13v2a4 4 0 01-4 4H3"/></svg>
                            {$LANG.transferdomain|default:'Transfer'}
                        </a>
                    </div>
                </div>
            </div>

            {* Pagination footer *}
            <div class="dom-footer when-full">
                <div class="dom-page-size">
                    {$LANG.show|default:'Show'}
                    <select aria-label="{$LANG.rowsperpage|default:'Rows per page'}">
                        <option>10</option>
                        <option>25</option>
                        <option>50</option>
                    </select>
                    {$LANG.entries|default:'entries'}
                </div>
                <div class="spacer"></div>
                {assign var=startNum value=$startnumber|default:0}
                {assign var=startDisplay value=$startNum+1}
                {assign var=endDisplay value=$startNum+$domCount}
                {assign var=totalNum value=$numdomains|default:$domCount}
                <span>{$LANG.showing|default:'Showing'} {$startDisplay}–{$endDisplay} {$LANG.of|default:'of'} {$totalNum}</span>
                <div class="dom-pages">
                    <button type="button" disabled aria-label="{$LANG.previouspage|default:'Previous page'}"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="15 18 9 12 15 6"/></svg></button>
                    <button type="button" class="active">1</button>
                    <button type="button" disabled aria-label="{$LANG.nextpage|default:'Next page'}"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="9 18 15 12 9 6"/></svg></button>
                </div>
            </div>

        </div>{* /.dom-stack *}
    </div>

    {* ══ RIGHT: Domains sub-nav ══ *}
    <aside>
        <div class="card subnav-card">
            <div class="subnav-heading">{$LANG.navdomains|default:'Domains'}</div>
            <a href="{$WEB_ROOT}/clientarea.php?action=domains" class="subnav-item active">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="2" y1="12" x2="22" y2="12"/><path d="M12 2a15.3 15.3 0 014 10 15.3 15.3 0 01-4 10 15.3 15.3 0 01-4-10 15.3 15.3 0 014-10z"/></svg>
                {$LANG.mydomains|default:'My Domains'}
                <span class="subnav-count">{$domCount}</span>
            </a>
            <a href="{$WEB_ROOT}/cart.php?a=add&domain=register" class="subnav-item">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="16"/><line x1="8" y1="12" x2="16" y2="12"/></svg>
                {$LANG.registeradomain|default:'Register a Domain'}
            </a>
            <a href="{$WEB_ROOT}/cart.php?a=add&domain=transfer" class="subnav-item">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><polyline points="17 1 21 5 17 9"/><path d="M3 11V9a4 4 0 014-4h14"/><polyline points="7 23 3 19 7 15"/><path d="M21 13v2a4 4 0 01-4 4H3"/></svg>
                {$LANG.transferadomain|default:'Transfer a Domain'}
            </a>
            <a href="{$WEB_ROOT}/clientarea.php?action=bulkdomainmanagement" class="subnav-item">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="3" width="7" height="7" rx="1"/><rect x="14" y="3" width="7" height="7" rx="1"/><rect x="3" y="14" width="7" height="7" rx="1"/><rect x="14" y="14" width="7" height="7" rx="1"/></svg>
                {$LANG.bulkmanagement|default:'Bulk Management'}
            </a>
            <a href="{$WEB_ROOT}/cart.php?gid=domain" class="subnav-item">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><line x1="12" y1="1" x2="12" y2="23"/><path d="M17 5H9.5a3.5 3.5 0 000 7h5a3.5 3.5 0 010 7H6"/></svg>
                {$LANG.domainpricing|default:'Domain Pricing'}
            </a>
            <a href="{$WEB_ROOT}/whois.php" class="subnav-item">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="11" cy="11" r="7"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>
                {$LANG.whoislookup|default:'WHOIS Lookup'}
            </a>
        </div>
    </aside>
</div>{* /.dom-split *}
