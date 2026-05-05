{* Hostnodes — Client Home dashboard (Apple-style).

   Variables expected from WHMCS:
     $clientsdetails.firstname / .lastname / .email
     $clientsstats.productsnumactive
     $clientsstats.numactivedomains
     $clientsstats.numunpaidinvoices
     $clientsstats.unpaidinvoicesamount  (formatted)
     $clientsstats.numactivetickets
     $publishedAnnouncements           (array from WHMCS)

   Optional from MyTheme hooks ($dashboard):
     activeServices[], recentInvoices[], openTickets[]

   Variant config from $myTheme.pages.clientareahome.config:
     tilesVariant   — a|b|c|d|e|f         (default: a)
     subnavMode     — right|left|outside|outside-left|off (default: right)
     cardLayout     — inside|outside       (default: inside)
     showAlerts     — bool                 (default: true)
     tilesEnabled   — bool                 (default: true)
     showPromo      — bool                 (default: true)
*}

<!-- DASHBOARD-V1-START -->

{* Resolve variant config with hard-coded defaults (no $myTheme dependency) *}
{assign var=tilesVariant value='a'}
{assign var=subnavMode value='right'}
{assign var=cardLayout value='inside'}
{assign var=showAlerts value=true}
{assign var=tilesEnabled value=true}
{assign var=showPromo value=true}
{assign var=hasNativeTickets value=false}
{assign var=ticketPanel value=false}

{if isset($panels)}
    {foreach $panels as $homePanel}
        {if $homePanel->getName() == "Recent Support Tickets"}
            {assign var=ticketPanel value=$homePanel}
            {if $homePanel->hasChildren()}
                {assign var=hasNativeTickets value=true}
            {/if}
        {/if}
    {/foreach}
{/if}

{if $clientsstats.productsnumactive > 0 || $clientsstats.numactivedomains > 0 || $clientsstats.numunpaidinvoices > 0 || $clientsstats.numactivetickets > 0 || (isset($dashboard.activeServices) && $dashboard.activeServices|count > 0) || (isset($dashboard.openTickets) && $dashboard.openTickets|count > 0) || $hasNativeTickets || (isset($publishedAnnouncements) && $publishedAnnouncements|count > 0)}
    {assign var=dashIsEmpty value='full'}
{else}
    {assign var=dashIsEmpty value='empty'}
{/if}

{* Page-specific stylesheet *}
<link rel="stylesheet" href="{$WEB_ROOT}/templates/{$template}/assets/css/pages/clientareahome.css?v={$myTheme.version|default:'1.0'}">

{* Hand layout signals to the body — picked up by apple-layout.js + page CSS *}
<script>
(function () {
    var b = document.body;
    if (!b) return;
    b.setAttribute('data-tiles',         '{$tilesVariant|escape:'javascript'}');
    {if $subnavMode == 'off'}
    b.setAttribute('data-subnav',        'off');
    {else}
    b.setAttribute('data-subnav',        'on');
    {/if}
    {if $subnavMode != 'off' && $subnavMode != 'right'}
    b.setAttribute('data-subnav-side',   '{$subnavMode|escape:'javascript'}');
    {/if}
    b.setAttribute('data-svc-layout',    '{$cardLayout|escape:'javascript'}');
    b.setAttribute('data-data',          '{$dashIsEmpty}');
})();
</script>

{* ════════════════════════════════════════════════════ *}
{* Sentinel: enables the state-chip Services pill on this page *}
<div class="svc-table-card" aria-hidden="true"></div>

<h1 class="dash-heading">{$LANG.clientareanavhome|default:'My Dashboard'}</h1>

<div class="dash-split">

    {* ══════════ MAIN COLUMN ══════════ *}
    <div class="dash-main-col">

        {* ─── Inline notices (when there's something to act on) ─── *}
        {if $showAlerts}
        <div class="notices-group when-full">
            {if $clientsstats.numoverdueinvoices > 0 || $clientsstats.numunpaidinvoices > 0}
            <div class="notice">
                <div class="notice-ico">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><line x1="12" y1="8" x2="12" y2="13"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>
                </div>
                <div class="notice-text">
                    {if $clientsstats.numoverdueinvoices}{assign var=nUnpaid value=$clientsstats.numoverdueinvoices}{elseif $clientsstats.numunpaidinvoices}{assign var=nUnpaid value=$clientsstats.numunpaidinvoices}{else}{assign var=nUnpaid value=0}{/if}
                    {$LANG.youhave|default:'You have'} <strong>{$nUnpaid} {if $nUnpaid == 1}{$LANG.invoiceoverdue|default:'overdue invoice'}{else}{$LANG.invoicesoverdue|default:'overdue invoices'}{/if}</strong>{if $clientsstats.unpaidinvoicesamount} {$LANG.totalingdue|default:'with a total of'} <strong>{$clientsstats.unpaidinvoicesamount}</strong> {$LANG.dueamount|default:'due'}{/if}.
                    <a href="{$WEB_ROOT}/clientarea.php?action=invoices">{$LANG.makepayment|default:'Pay now'}</a>.
                </div>
                <button class="notice-dismiss" aria-label="{$LANG.dismiss|default:'Dismiss'}" data-dismiss>
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/></svg>
                </button>
            </div>
            {/if}
            {if $clientsstats.numexpiringdomains > 0}
            <div class="notice">
                <div class="notice-ico">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><line x1="12" y1="8" x2="12" y2="13"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>
                </div>
                <div class="notice-text">
                    <strong>{$clientsstats.numexpiringdomains} {if $clientsstats.numexpiringdomains == 1}{$LANG.domainexpiring|default:'domain'}{else}{$LANG.domainsexpiring|default:'domains'}{/if}</strong> {$LANG.expirewithin45|default:'expires in the next 45 days'}.
                    <a href="{$WEB_ROOT}/clientarea.php?action=domains">{$LANG.renew|default:'Renew'}</a> {$LANG.tokeepactive|default:'to keep active'}.
                </div>
                <button class="notice-dismiss" aria-label="{$LANG.dismiss|default:'Dismiss'}" data-dismiss>
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/></svg>
                </button>
            </div>
            {/if}
        </div>
        {/if}

        {* ─── Welcome notice (empty state) ─── *}
        <div class="notice when-empty">
            <div class="notice-ico">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"/></svg>
            </div>
            <div class="notice-text">
                {$LANG.welcometo|default:'Welcome to'} {$companyname|escape}. {$LANG.startbyordering|default:'Start by'} <a href="{$WEB_ROOT}/cart.php">{$LANG.orderingaservice|default:'ordering a service'}</a> {$LANG.or|default:'or'} <a href="{$WEB_ROOT}/cart.php?a=add&domain=register">{$LANG.registeradomain|default:'registering a domain'}</a>.
            </div>
        </div>

        {* ─── Promo slider (optional) ─── *}

        {* ═══ TILES ═══ *}
        {if $tilesEnabled}

        {* Variant A — vertical (default) *}
        <div class="tile-variant" data-variant="a">
            <p class="variant-label">Variant A — vertical</p>
            <div class="tiles-row">
                <a href="{$WEB_ROOT}/clientarea.php?action=services" class="tile">
                    <div class="tile-icon blue"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="2" y="3" width="20" height="14" rx="2"/><path d="M8 21h8"/><path d="M12 17v4"/></svg></div>
                    <div class="tile-value">{$clientsstats.productsnumactive|default:0}</div>
                    <div class="tile-label">{$LANG.servicesactive|default:'Services'}</div>
                </a>
                <a href="{$WEB_ROOT}/clientarea.php?action=domains" class="tile">
                    <div class="tile-icon green"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="2" y1="12" x2="22" y2="12"/><path d="M12 2a15.3 15.3 0 014 10 15.3 15.3 0 01-4 10 15.3 15.3 0 01-4-10 15.3 15.3 0 014-10z"/></svg></div>
                    <div class="tile-value">{$clientsstats.numactivedomains|default:0}</div>
                    <div class="tile-label">{$LANG.navdomains|default:'Domains'}</div>
                </a>
                <a href="{$WEB_ROOT}/clientarea.php?action=invoices" class="tile">
                    <div class="tile-icon red"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="1" y="4" width="22" height="16" rx="2"/><line x1="1" y1="10" x2="23" y2="10"/></svg></div>
                    <div class="tile-value">{$clientsstats.numunpaidinvoices|default:0}</div>
                    <div class="tile-label">{$LANG.unpaidinvoices|default:'Unpaid Invoices'}</div>
                </a>
                <a href="{$WEB_ROOT}/supporttickets.php" class="tile">
                    <div class="tile-icon orange"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21 15a2 2 0 01-2 2H7l-4 4V5a2 2 0 012-2h14a2 2 0 012 2z"/></svg></div>
                    <div class="tile-value">{$clientsstats.numactivetickets|default:0}</div>
                    <div class="tile-label">{$LANG.supporttickets|default:'Tickets'}</div>
                </a>
            </div>
        </div>

        {* Variant B — horizontal *}
        <div class="tile-variant" data-variant="b">
            <p class="variant-label">Variant B — horizontal</p>
            <div class="tiles-row-b">
                <a href="{$WEB_ROOT}/clientarea.php?action=services" class="tile-h">
                    <div class="tile-icon blue"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="2" y="3" width="20" height="14" rx="2"/><path d="M8 21h8"/><path d="M12 17v4"/></svg></div>
                    <div class="tile-h-info">
                        <div class="tile-h-value">{$clientsstats.productsnumactive|default:0}</div>
                        <div class="tile-h-label">{$LANG.servicesactive|default:'Services'}</div>
                    </div>
                </a>
                <a href="{$WEB_ROOT}/clientarea.php?action=domains" class="tile-h">
                    <div class="tile-icon green"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="2" y1="12" x2="22" y2="12"/><path d="M12 2a15.3 15.3 0 014 10 15.3 15.3 0 01-4 10 15.3 15.3 0 01-4-10 15.3 15.3 0 014-10z"/></svg></div>
                    <div class="tile-h-info">
                        <div class="tile-h-value">{$clientsstats.numactivedomains|default:0}</div>
                        <div class="tile-h-label">{$LANG.navdomains|default:'Domains'}</div>
                    </div>
                </a>
                <a href="{$WEB_ROOT}/clientarea.php?action=invoices" class="tile-h">
                    <div class="tile-icon red"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="1" y="4" width="22" height="16" rx="2"/><line x1="1" y1="10" x2="23" y2="10"/></svg></div>
                    <div class="tile-h-info">
                        <div class="tile-h-value">{$clientsstats.numunpaidinvoices|default:0}</div>
                        <div class="tile-h-label">{$LANG.unpaidinvoices|default:'Unpaid Invoices'}</div>
                    </div>
                </a>
                <a href="{$WEB_ROOT}/supporttickets.php" class="tile-h">
                    <div class="tile-icon orange"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21 15a2 2 0 01-2 2H7l-4 4V5a2 2 0 012-2h14a2 2 0 012 2z"/></svg></div>
                    <div class="tile-h-info">
                        <div class="tile-h-value">{$clientsstats.numactivetickets|default:0}</div>
                        <div class="tile-h-label">{$LANG.supporttickets|default:'Tickets'}</div>
                    </div>
                </a>
            </div>
        </div>

        {* Variant C — tinted iOS-widget feel *}
        <div class="tile-variant" data-variant="c">
            <p class="variant-label">Variant C — tinted</p>
            <div class="tiles-row-c">
                <a href="{$WEB_ROOT}/clientarea.php?action=services" class="tile-c blue">
                    <span class="tile-c-ghost"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="2" y="3" width="20" height="14" rx="2"/><path d="M8 21h8"/><path d="M12 17v4"/></svg></span>
                    <div class="tile-c-value">{$clientsstats.productsnumactive|default:0}</div>
                    <div class="tile-c-label">{$LANG.servicesactive|default:'Services'}</div>
                </a>
                <a href="{$WEB_ROOT}/clientarea.php?action=domains" class="tile-c green">
                    <span class="tile-c-ghost"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="2" y1="12" x2="22" y2="12"/><path d="M12 2a15.3 15.3 0 014 10 15.3 15.3 0 01-4 10 15.3 15.3 0 01-4-10 15.3 15.3 0 014-10z"/></svg></span>
                    <div class="tile-c-value">{$clientsstats.numactivedomains|default:0}</div>
                    <div class="tile-c-label">{$LANG.navdomains|default:'Domains'}</div>
                </a>
                <a href="{$WEB_ROOT}/clientarea.php?action=invoices" class="tile-c red">
                    <span class="tile-c-ghost"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="1" y="4" width="22" height="16" rx="2"/><line x1="1" y1="10" x2="23" y2="10"/></svg></span>
                    <div class="tile-c-value">{$clientsstats.numunpaidinvoices|default:0}</div>
                    <div class="tile-c-label">{$LANG.unpaidinvoices|default:'Unpaid Invoices'}</div>
                </a>
                <a href="{$WEB_ROOT}/supporttickets.php" class="tile-c orange">
                    <span class="tile-c-ghost"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21 15a2 2 0 01-2 2H7l-4 4V5a2 2 0 012-2h14a2 2 0 012 2z"/></svg></span>
                    <div class="tile-c-value">{$clientsstats.numactivetickets|default:0}</div>
                    <div class="tile-c-label">{$LANG.supporttickets|default:'Tickets'}</div>
                </a>
            </div>
        </div>

        {* Variant D — single card, stacked rows *}
        <div class="tile-variant" data-variant="d">
            <p class="variant-label">Variant D — list</p>
            <div class="tile-d-card">
                <a href="{$WEB_ROOT}/clientarea.php?action=services" class="tile-d-row">
                    <div class="tile-d-ico blue"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="2" y="3" width="20" height="14" rx="2"/><path d="M8 21h8"/><path d="M12 17v4"/></svg></div>
                    <div class="tile-d-label">{$LANG.servicesactive|default:'Services'}</div>
                    <div class="tile-d-value">{$clientsstats.productsnumactive|default:0}</div>
                    <svg class="tile-d-chev" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><polyline points="9 18 15 12 9 6"/></svg>
                </a>
                <a href="{$WEB_ROOT}/clientarea.php?action=domains" class="tile-d-row">
                    <div class="tile-d-ico green"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="2" y1="12" x2="22" y2="12"/><path d="M12 2a15.3 15.3 0 014 10 15.3 15.3 0 01-4 10 15.3 15.3 0 01-4-10 15.3 15.3 0 014-10z"/></svg></div>
                    <div class="tile-d-label">{$LANG.navdomains|default:'Domains'}</div>
                    <div class="tile-d-value">{$clientsstats.numactivedomains|default:0}</div>
                    <svg class="tile-d-chev" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><polyline points="9 18 15 12 9 6"/></svg>
                </a>
                <a href="{$WEB_ROOT}/clientarea.php?action=invoices" class="tile-d-row{if $clientsstats.numunpaidinvoices > 0} alert{/if}">
                    <div class="tile-d-ico red"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="1" y="4" width="22" height="16" rx="2"/><line x1="1" y1="10" x2="23" y2="10"/></svg></div>
                    <div class="tile-d-label">{$LANG.unpaidinvoices|default:'Unpaid Invoices'}</div>
                    <div class="tile-d-value">{$clientsstats.numunpaidinvoices|default:0}</div>
                    <svg class="tile-d-chev" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><polyline points="9 18 15 12 9 6"/></svg>
                </a>
                <a href="{$WEB_ROOT}/supporttickets.php" class="tile-d-row">
                    <div class="tile-d-ico orange"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21 15a2 2 0 01-2 2H7l-4 4V5a2 2 0 012-2h14a2 2 0 012 2z"/></svg></div>
                    <div class="tile-d-label">{$LANG.supporttickets|default:'Tickets'}</div>
                    <div class="tile-d-value">{$clientsstats.numactivetickets|default:0}</div>
                    <svg class="tile-d-chev" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><polyline points="9 18 15 12 9 6"/></svg>
                </a>
            </div>
        </div>

        {* Variant F — D's horizontal sibling *}
        <div class="tile-variant" data-variant="f">
            <p class="variant-label">Variant F — list (horizontal)</p>
            <div class="tile-f-card">
                <a href="{$WEB_ROOT}/clientarea.php?action=services" class="tile-f-cell">
                    <div class="tile-f-ico blue"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="2" y="3" width="20" height="14" rx="2"/><path d="M8 21h8"/><path d="M12 17v4"/></svg></div>
                    <div class="tile-f-text">
                        <div class="tile-f-label">{$LANG.servicesactive|default:'Services'}</div>
                        <div class="tile-f-value">{$clientsstats.productsnumactive|default:0}</div>
                    </div>
                </a>
                <a href="{$WEB_ROOT}/clientarea.php?action=domains" class="tile-f-cell">
                    <div class="tile-f-ico green"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="2" y1="12" x2="22" y2="12"/><path d="M12 2a15.3 15.3 0 014 10 15.3 15.3 0 01-4 10 15.3 15.3 0 01-4-10 15.3 15.3 0 014-10z"/></svg></div>
                    <div class="tile-f-text">
                        <div class="tile-f-label">{$LANG.navdomains|default:'Domains'}</div>
                        <div class="tile-f-value">{$clientsstats.numactivedomains|default:0}</div>
                    </div>
                </a>
                <a href="{$WEB_ROOT}/clientarea.php?action=invoices" class="tile-f-cell{if $clientsstats.numunpaidinvoices > 0} alert{/if}">
                    <div class="tile-f-ico red"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="1" y="4" width="22" height="16" rx="2"/><line x1="1" y1="10" x2="23" y2="10"/></svg></div>
                    <div class="tile-f-text">
                        <div class="tile-f-label">{$LANG.unpaid|default:'Unpaid'}</div>
                        <div class="tile-f-value">{$clientsstats.numunpaidinvoices|default:0}</div>
                    </div>
                </a>
                <a href="{$WEB_ROOT}/supporttickets.php" class="tile-f-cell">
                    <div class="tile-f-ico orange"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21 15a2 2 0 01-2 2H7l-4 4V5a2 2 0 012-2h14a2 2 0 012 2z"/></svg></div>
                    <div class="tile-f-text">
                        <div class="tile-f-label">{$LANG.supporttickets|default:'Tickets'}</div>
                        <div class="tile-f-value">{$clientsstats.numactivetickets|default:0}</div>
                    </div>
                </a>
            </div>
        </div>

        {* Variant E — progress rings *}
        <div class="tile-variant" data-variant="e">
            <p class="variant-label">Variant E — rings</p>
            <div class="tiles-row-e">
                <a href="{$WEB_ROOT}/clientarea.php?action=services" class="tile-e blue">
                    <div class="tile-e-ring">
                        <svg viewBox="0 0 64 64"><circle class="bg" cx="32" cy="32" r="27"/><circle class="fg" cx="32" cy="32" r="27"/></svg>
                        <div class="tile-e-value">{$clientsstats.productsnumactive|default:0}</div>
                    </div>
                    <div class="tile-e-label">{$LANG.servicesactive|default:'Services'}</div>
                </a>
                <a href="{$WEB_ROOT}/clientarea.php?action=domains" class="tile-e green">
                    <div class="tile-e-ring">
                        <svg viewBox="0 0 64 64"><circle class="bg" cx="32" cy="32" r="27"/><circle class="fg" cx="32" cy="32" r="27"/></svg>
                        <div class="tile-e-value">{$clientsstats.numactivedomains|default:0}</div>
                    </div>
                    <div class="tile-e-label">{$LANG.navdomains|default:'Domains'}</div>
                </a>
                <a href="{$WEB_ROOT}/clientarea.php?action=invoices" class="tile-e red">
                    <div class="tile-e-ring">
                        <svg viewBox="0 0 64 64"><circle class="bg" cx="32" cy="32" r="27"/><circle class="fg" cx="32" cy="32" r="27"/></svg>
                        <div class="tile-e-value">{$clientsstats.numunpaidinvoices|default:0}</div>
                    </div>
                    <div class="tile-e-label">{$LANG.unpaidinvoices|default:'Unpaid Invoices'}</div>
                </a>
                <a href="{$WEB_ROOT}/supporttickets.php" class="tile-e orange">
                    <div class="tile-e-ring">
                        <svg viewBox="0 0 64 64"><circle class="bg" cx="32" cy="32" r="27"/><circle class="fg" cx="32" cy="32" r="27"/></svg>
                        <div class="tile-e-value">{$clientsstats.numactivetickets|default:0}</div>
                    </div>
                    <div class="tile-e-label">{$LANG.supporttickets|default:'Tickets'}</div>
                </a>
            </div>
        </div>

        {/if}{* /tilesEnabled *}

        {* ─── Active Products / Services ─── *}
        <div class="card" style="margin-bottom: 0;">
            <div class="card-header">
                <h2 class="card-title">{$LANG.clientHomePanels.activeProductsServices|default:'Your Active Products/Services'}</h2>
                <a href="{$WEB_ROOT}/clientarea.php?action=services" class="card-action">
                    {$LANG.viewall|default:'View All'} <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><polyline points="9 18 15 12 9 6"/></svg>
                </a>
            </div>
            {if isset($dashboard.activeServices) && $dashboard.activeServices|count > 0}
            <div class="card-body when-full" style="padding: 4px 24px 12px;">
                {foreach $dashboard.activeServices as $svc}
                    <a href="{$svc.manageUrl|default:"`$WEB_ROOT`/clientarea.php?action=productdetails&id=`$svc.id`"}" class="service-item">
                        <div class="service-icon">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><rect x="2" y="3" width="20" height="14" rx="2"/><path d="M8 21h8"/><path d="M12 17v4"/></svg>
                        </div>
                        <div class="service-info">
                            <div class="service-name"><strong>{$svc.groupname|default:$svc.product|escape}</strong>{if $svc.name} — {$svc.name|escape}{/if}</div>
                            {if $svc.domain}<div class="service-domain">{$svc.domain|escape}</div>{/if}
                        </div>
                        <div class="service-meta">
                            <span class="status-pill {$svc.status|lower|default:'active'}">{$svc.status|escape|default:'Active'}</span>
                            <span class="service-manage"><span class="btn-secondary">{$LANG.manageproduct|default:'Manage'}</span></span>
                        </div>
                    </a>
                {/foreach}
            </div>
            {else}
            <div class="card-body when-empty">
                <div class="empty-state">
                    <div class="empty-ico">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><rect x="2" y="3" width="20" height="14" rx="2"/><path d="M8 21h8"/><path d="M12 17v4"/></svg>
                    </div>
                    <h3 class="empty-state-title">{$LANG.noproductsactive|default:'No services yet'}</h3>
                    <p class="empty-state-sub">{$LANG.noproductssub|default:"You don't have any active products. Browse our catalogue to get started."}</p>
                    <a href="{$WEB_ROOT}/cart.php" class="btn-primary">{$LANG.orderproducts|default:'Order a service'}</a>
                </div>
            </div>
            {/if}
        </div>

        {* ─── Split row: Recent Tickets + Register Domain ─── *}
        <div class="split-row">
            <div class="card" style="margin-bottom: 0;">
                <div class="card-header">
                    <h2 class="card-title">{$LANG.recentSupportTickets|default:'Recent Support Tickets'}</h2>
                    <a href="{$WEB_ROOT}/submitticket.php" class="card-action">
                        {$LANG.opennewticket|default:'Open New Ticket'} <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
                    </a>
                </div>
                {if $hasNativeTickets}
                <div class="card-body when-full" style="padding: 4px 24px 12px;">
                    {foreach $ticketPanel->getChildren() as $ticketItem}
                        {if $ticketItem->getUri()}
                            <a menuItemName="{$ticketItem->getName()}" href="{$ticketItem->getUri()}" class="service-item ticket-row{if $ticketItem->getClass()} {$ticketItem->getClass()}{/if}{if $ticketItem->isCurrent()} active{/if}"{if $ticketItem->getAttribute('dataToggleTab')} data-toggle="tab"{/if}{if $ticketItem->getAttribute('target')} target="{$ticketItem->getAttribute('target')}"{/if} id="{$ticketItem->getId()}">
                        {else}
                            <div menuItemName="{$ticketItem->getName()}" class="service-item ticket-row{if $ticketItem->getClass()} {$ticketItem->getClass()}{/if}" id="{$ticketItem->getId()}">
                        {/if}
                                <div class="service-info">
                                    <div class="service-name">{$ticketItem->getLabel()}</div>
                                    {if $ticketItem->hasBadge()}<div class="service-domain">{$ticketItem->getBadge()}</div>{/if}
                                </div>
                                {if $ticketItem->getUri()}
                                    <span class="service-chevron"><svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><polyline points="9 18 15 12 9 6"/></svg></span>
                                {/if}
                        {if $ticketItem->getUri()}
                            </a>
                        {else}
                            </div>
                        {/if}
                    {/foreach}
                </div>
                {elseif isset($dashboard.openTickets) && $dashboard.openTickets|count > 0}
                <div class="card-body when-full" style="padding: 4px 24px 12px;">
                    {foreach $dashboard.openTickets as $tkt}
                        <a href="{$WEB_ROOT}/viewticket.php?tid={$tkt.tid|escape}{if $tkt.c}&c={$tkt.c|escape}{/if}" class="service-item ticket-row">
                            <div class="service-info">
                                <div class="service-name">{$tkt.subject|escape}</div>
                                <div class="service-domain">#{$tkt.tid|escape}{if $tkt.lastreply} · {$LANG.updated|default:'Updated'} {$tkt.lastreply|escape}{elseif $tkt.date} · {$LANG.opened|default:'Opened'} {$tkt.date|escape}{/if}</div>
                            </div>
                            <span class="status-pill {$tkt.status|lower|replace:' ':'-'|replace:'_':'-'|default:'open'}">{$tkt.status|escape|default:'Open'}</span>
                        </a>
                    {/foreach}
                </div>
                {else}
                <div class="card-body when-empty">
                    <div class="empty-state">
                        <div class="empty-ico">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M21 15a2 2 0 01-2 2H7l-4 4V5a2 2 0 012-2h14a2 2 0 012 2z"/></svg>
                        </div>
                        <h3 class="empty-state-title">{$LANG.notickets|default:'No tickets yet'}</h3>
                        <p class="empty-state-sub">{$LANG.noticketssub|default:"Need a hand with something? We're here to help."}</p>
                        <a href="{$WEB_ROOT}/submitticket.php" class="btn-primary">{$LANG.opennewticket|default:'Open a ticket'}</a>
                    </div>
                </div>
                {/if}
            </div>

            <div class="card" style="margin-bottom: 0;">
                <div class="card-header">
                    <h2 class="card-title">{$LANG.registerNewDomain|default:'Register a New Domain'}</h2>
                </div>
                <div class="card-body">
                    <form class="rd-form" id="rdForm" action="{$WEB_ROOT}/domainchecker.php" method="post">
                        <input type="text" name="search" class="rd-input" id="rdInput" placeholder="{$LANG.domainsfindyournew|default:'Find your new domain name'}" autocapitalize="none" autocomplete="off" required>
                        <div class="rd-actions">
                            <button type="submit" class="btn-secondary" name="transfer" value="1" formaction="{$WEB_ROOT}/cart.php?a=add&domain=transfer">{$LANG.transferdomain|default:'Transfer'}</button>
                            <button type="submit" class="btn-primary" name="register" value="1" formaction="{$WEB_ROOT}/cart.php?a=add&domain=register">{$LANG.registerdomain|default:'Register'}</button>
                        </div>
                    </form>
                </div>
            </div>
        </div>

        {* ─── Recent News (announcements) ─── *}
        <div class="card" style="margin-bottom: 0;">
            <div class="card-header">
                <h2 class="card-title">{$LANG.recentNews|default:'Recent News'}</h2>
                <a href="{$WEB_ROOT}/announcements.php" class="card-action">
                    {$LANG.viewall|default:'View All'} <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><polyline points="9 18 15 12 9 6"/></svg>
                </a>
            </div>
            {if isset($publishedAnnouncements) && $publishedAnnouncements|count > 0}
            <div class="card-body when-full">
                <div class="news-list">
                    {foreach $publishedAnnouncements as $ann}
                        <a href="{$WEB_ROOT}/announcements.php?id={$ann.id}" class="news-row">
                            <div class="news-title">{$ann.title|escape}</div>
                            <div class="news-date">{$ann.date|escape}</div>
                        </a>
                        {if $ann@iteration >= 5}{break}{/if}
                    {/foreach}
                </div>
            </div>
            {else}
            <div class="card-body when-empty">
                <div class="empty-state">
                    <div class="empty-ico">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M18 8A6 6 0 006 8c0 7-3 9-3 9h18s-3-2-3-9"/><path d="M13.73 21a2 2 0 01-3.46 0"/></svg>
                    </div>
                    <h3 class="empty-state-title">{$LANG.announcementsnone|default:'No announcements'}</h3>
                    <p class="empty-state-sub">{$LANG.announcementssub|default:'Product updates and network notices will appear here.'}</p>
                </div>
            </div>
            {/if}
        </div>

    </div>{* /.dash-main-col *}

    {* ══════════ ACCOUNT SUB-NAV ASIDE ══════════ *}
    {if $subnavMode != 'off'}
    <aside>
        <div class="card subnav-card">
            <div class="subnav-heading">{$LANG.accounttab|default:'Account'}</div>
            <a href="{$WEB_ROOT}/clientarea.php" class="subnav-item active">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="3" width="7" height="7" rx="1"/><rect x="14" y="3" width="7" height="7" rx="1"/><rect x="3" y="14" width="7" height="7" rx="1"/><rect x="14" y="14" width="7" height="7" rx="1"/></svg>
                {$LANG.clientareanavhome|default:'Dashboard'}
            </a>
            <a href="{$WEB_ROOT}/clientarea.php?action=services" class="subnav-item">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><rect x="2" y="3" width="20" height="14" rx="2"/><path d="M8 21h8"/><path d="M12 17v4"/></svg>
                {$LANG.navservices|default:'My Services'}
                <span class="subnav-count">{$clientsstats.productsnumactive|default:0}</span>
            </a>
            <a href="{$WEB_ROOT}/clientarea.php?action=domains" class="subnav-item">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="2" y1="12" x2="22" y2="12"/><path d="M12 2a15.3 15.3 0 014 10 15.3 15.3 0 01-4 10 15.3 15.3 0 01-4-10 15.3 15.3 0 014-10z"/></svg>
                {$LANG.navdomains|default:'My Domains'}
                <span class="subnav-count">{$clientsstats.numactivedomains|default:0}</span>
            </a>
            <a href="{$WEB_ROOT}/clientarea.php?action=invoices" class="subnav-item">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><rect x="1" y="4" width="22" height="16" rx="2"/><line x1="1" y1="10" x2="23" y2="10"/></svg>
                {$LANG.navinvoices|default:'Invoices'}
                <span class="subnav-count">{$clientsstats.numunpaidinvoices|default:0}</span>
            </a>
            <a href="{$WEB_ROOT}/supporttickets.php" class="subnav-item">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M21 15a2 2 0 01-2 2H7l-4 4V5a2 2 0 012-2h14a2 2 0 012 2z"/></svg>
                {$LANG.navtickets|default:'Support Tickets'}
                <span class="subnav-count">{$clientsstats.numactivetickets|default:0}</span>
            </a>
            <a href="{$WEB_ROOT}/clientarea.php?action=details" class="subnav-item">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M20 21v-2a4 4 0 00-4-4H8a4 4 0 00-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>
                {$LANG.navchangedetails|default:'My Details'}
            </a>
        </div>
    </aside>
    {/if}

</div>{* /.dash-split *}
