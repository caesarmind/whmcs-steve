{* Hostnodes — Service Details (Apple-style).

   WHMCS exposes the service variables as TOP-LEVEL (not as a $service or
   $product object). Verified against Nexus and Lagom — these are the
   canonical names; do NOT nest them or assume an object wrapper:

     $product, $groupname, $domain, $type     — name + grouping
     $status, $rawstatus                       — display + lowercased
     $regdate, $nextduedate                    — formatted dates
     $firstpaymentamount, $recurringamount    — money strings
     $billingcycle, $paymentmethodname        — billing meta
     $dedicatedip, $assignedips                — IP info (top-level)
     $ns1, $ns2                                — domain nameservers (top-level)
     $serverdata.hostname / .ipaddress /
       .nameserver1..5 (+ .nameserver1ip..)    — SERVER info (NESTED object;
                                                 NOT $serverhostname/$serverip!)
     $diskusage/$disklimit/$bwusage/$bwlimit   — usage in MB
     $diskpercent, $bwpercent ("12%")          — usage % for the bar width
     $lastupdate                               — gates the usage block (set when
                                                 the server module last reported)
     $username, $password                      — control panel creds
     $loginButton                              — Hadrian-provided login URL (NOT a
                                                 stock WHMCS var; absent w/o module)
     $pendingcancellation                      — bool, cancellation pending
     $packagesupgrade                          — bool; true when package upgrade /
                                                 downgrade paths are configured for
                                                 this service (NOT $upgrades — that
                                                 array only exists on upgradesummary)

   Layout: single stacked column of standard settings-group / card sections
   (parity with the apple-client-area mockup). settings-group + card respond
   to the preview chip's Controls inside/outside (apple-layout.css svc-layout).
*}

{assign var=svcStatusText  value=$status|default:''|strip_tags}
{assign var=svcStatusLower value=$rawstatus|default:$svcStatusText|lower|replace:' ':'-'}

<link rel="stylesheet" href="{$WEB_ROOT}/templates/{$template}/assets/css/pages/clientareaproductdetails.css?v={$hadrian.version|default:'1.0'}">

<header class="page-header">
    <div class="page-header-row">
        <div style="flex:1; min-width:0;">
            <p class="page-eyebrow">{$groupname|default:''|escape}</p>
            <h1>{$product|default:$hadrianLang.services.serviceFallback|escape}</h1>
            {if !empty($domain)}<p class="page-subtitle">{$domain|escape}</p>{/if}
        </div>
        <span class="status-pill {$svcStatusLower|escape}">{$svcStatusText|escape}</span>
    </div>
</header>

{if isset($pendingcancellation) && $pendingcancellation}
<div class="pd-alert pd-alert-warn">
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>
    {$LANG.cancellationrequestedexplanation}
</div>
{/if}

{if isset($unpaidInvoice) && $unpaidInvoice}
<div class="pd-alert pd-alert-error">
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>
    <div>{$unpaidInvoiceMessage|default:$hadrianLang.services.unpaidInvoice}</div>
    <a href="{$WEB_ROOT}/viewinvoice.php?id={$unpaidInvoice|escape}" class="btn-primary pd-alert-cta">{$LANG.payInvoice}</a>
</div>
{/if}

{* Service-status gating — computed ONCE here, consumed by the sidebar AND the
   Manage / Quick Shortcuts cards below (so keep this above .pd-split):
     $pdIsCpanelSvc = cPanel module regardless of status (keeps cards visible,
                      with a notice, for suspended/pending — matches Lagom)
     $pdIsActive    = service is active
     $pdCanCancel   = cancellation is allowed
     $pdIsCpanel    = control-panel area actually available (active cPanel w/ output) *}
{assign var=pdIsCpanelSvc value=false}
{if $module == 'cpanel'}{assign var=pdIsCpanelSvc value=true}{/if}
{assign var=pdIsActive value=false}
{if $svcStatusLower == 'active'}{assign var=pdIsActive value=true}{/if}
{assign var=pdCanCancel value=false}
{if (!isset($pendingcancellation) || !$pendingcancellation) && ($pdIsActive || $svcStatusLower == 'suspended')}{assign var=pdCanCancel value=true}{/if}
{assign var=pdIsCpanel value=false}
{if $pdIsCpanelSvc && !empty($moduleclientarea)}{assign var=pdIsCpanel value=true}{/if}
{assign var=pdHasAddons value=false}
{if isset($addons) && $addons}{assign var=pdHasAddons value=true}{/if}
{* WHMCS sets $packagesupgrade (bool) on the productdetails page when this service
   has package upgrade/downgrade paths configured AND is in an upgradeable state
   — the same var nexus/lagom gate their Upgrade button on. (The $upgrades array
   only exists on upgradesummary.tpl, so the old $upgrades|@count check here was
   always false → the button never showed.) *}
{assign var=pdHasUpgrades value=false}
{if isset($packagesupgrade) && $packagesupgrade}{assign var=pdHasUpgrades value=true}{/if}
{assign var=pdHasActions value=false}
{if $pdIsCpanel || $pdHasUpgrades || $modulechangepassword || $pdCanCancel}{assign var=pdHasActions value=true}{/if}
{* This page emits a <base href="…/"> (header.tpl), so a bare "#anchor" link
   resolves against the SITE ROOT (→ homepage), not this page. Build an absolute
   self URL so in-page section links land here; JS also intercepts the click for
   smooth, no-reload scrolling. *}
{assign var=pdSid value=$id|default:0}
{assign var=pdSelfUrl value=$WEB_ROOT|cat:'/clientarea.php?action=productdetails&id='|cat:$pdSid}

{* ── Service details (Lagom-parity sidebar: Overview + Actions groups) ─── *}
<div class="pd-split">
<aside class="pd-aside">
{* "Wire it like Lagom": render WHMCS's NATIVE product-details sidebar menus.
   On this page WHMCS populates $primarySidebar with "Service Details Overview"
   (Information / Addons / Change Password / Downloads) and "Service Details
   Actions" (Login to cPanel / Webmail, Change Password, Cancel, Upgrade,
   Renew) — the exact menus Lagom iterates in includes/sidebar.tpl. We render
   them Apple-styled; WHMCS's tab-toggle items (built for a tabbed page) are
   remapped to hadrian's stacked-section anchors. If the theme context doesn't
   expose a populated $primarySidebar, we fall back to the hand-coded rail so
   the sidebar is never empty. *}
{if isset($primarySidebar) && $primarySidebar && $primarySidebar->hasChildren()}
    <!-- pd-sidebar:whmcs -->
    {foreach $primarySidebar->getChildren() as $sbGroup}
        {if $sbGroup->hasChildren()}
        {assign var=sbGroupName value=$sbGroup->getName()|lower}
        <div class="card subnav-card">
            <div class="subnav-heading">{if $sbGroupName|strstr:'action'}{$LANG.actions}{elseif $sbGroupName|strstr:'overview'}{$LANG.overview}{else}{$sbGroup->getLabel()}{/if}</div>
            {foreach $sbGroup->getChildren() as $sbItem}
                {assign var=sbName value=$sbItem->getName()|lower}
                {assign var=sbUri value=$sbItem->getUri()}
                {assign var=sbHref value=$sbUri}
                {assign var=sbMapped value=false}
                {assign var=sbTab value=false}
                {assign var=sbDanger value=false}
                {if $sbName|strstr:'information' || $sbName|strstr:'overview'}{assign var=sbHref value=$pdSelfUrl|cat:'#pd-service-info'}{assign var=sbMapped value=true}
                {elseif $sbName|strstr:'addon'}{assign var=sbHref value=$pdSelfUrl|cat:'#pd-addons'}{assign var=sbMapped value=true}
                {elseif $sbName|strstr:'password'}{assign var=sbHref value=$pdSelfUrl|cat:'#pd-changepw'}{assign var=sbMapped value=true}{assign var=sbTab value=true}
                {elseif $sbName|strstr:'cancel'}{assign var=sbDanger value=true}
                {/if}
                {assign var=sbIsHash value=false}
                {if $sbUri|substr:0:1 == '#'}{assign var=sbIsHash value=true}{/if}
                {if $sbUri && (!$sbIsHash || $sbMapped)}
                <a class="subnav-item{if $sbItem->isCurrent()} active{/if}{if $sbDanger} subnav-item-danger{/if}" href="{$sbHref}"{if $sbItem->getAttribute('target')} target="{$sbItem->getAttribute('target')}" rel="noopener"{/if}{if $sbTab} data-pd-open{/if}>
                    {if $sbName|strstr:'cpanel' || $sbName|strstr:'control' || $sbName|strstr:'whm' || $sbName|strstr:'plesk' || $sbName|strstr:'manage' || ($sbName|strstr:'login' && !($sbName|strstr:'webmail'))}<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M15 3h4a2 2 0 012 2v14a2 2 0 01-2 2h-4"/><polyline points="10 17 15 12 10 7"/><line x1="15" y1="12" x2="3" y2="12"/></svg>
                    {elseif $sbName|strstr:'webmail' || $sbName|strstr:'mail'}<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="5" width="18" height="14" rx="2"/><path d="M3 7l9 6 9-6"/></svg>
                    {elseif $sbName|strstr:'password'}<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="11" width="18" height="11" rx="2"/><path d="M7 11V7a5 5 0 0110 0v4"/></svg>
                    {elseif $sbName|strstr:'cancel'}<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="4.93" y1="4.93" x2="19.07" y2="19.07"/></svg>
                    {elseif $sbName|strstr:'upgrade' || $sbName|strstr:'downgrade'}<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><line x1="12" y1="4" x2="12" y2="20"/><polyline points="8 8 12 4 16 8"/><polyline points="8 16 12 20 16 16"/></svg>
                    {elseif $sbName|strstr:'renew'}<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M23 4v6h-6"/><path d="M20.49 15a9 9 0 11-2.12-9.36L23 10"/></svg>
                    {elseif $sbName|strstr:'addon'}<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M20.5 11H19V7a2 2 0 00-2-2h-4V3.5a2.5 2.5 0 00-5 0V5H4a2 2 0 00-2 2v3.8h1.5a2.7 2.7 0 010 5.4H2V20a2 2 0 002 2h3.8v-1.5a2.7 2.7 0 015.4 0V22H17a2 2 0 002-2v-4h1.5a2.5 2.5 0 000-5z"/></svg>
                    {elseif $sbName|strstr:'download'}<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M21 15v4a2 2 0 01-2 2H5a2 2 0 01-2-2v-4"/><polyline points="7 10 12 15 17 10"/><line x1="12" y1="15" x2="12" y2="3"/></svg>
                    {elseif $sbName|strstr:'information' || $sbName|strstr:'overview'}<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
                    {else}<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="9"/></svg>
                    {/if}
                    {$sbItem->getLabel()}
                </a>
                {/if}
            {/foreach}
        </div>
        {/if}
    {/foreach}
{else}
    <!-- pd-sidebar:handcoded -->

    {* Overview — in-page section jumps (mirrors Lagom's "Service Details Overview") *}
    <div class="card subnav-card">
        <div class="subnav-heading">{$LANG.overview}</div>
        <a class="subnav-item active" href="{$pdSelfUrl}#pd-service-info">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
            {$LANG.information|default:'Information'}
        </a>
        {if $lastupdate}
        <a class="subnav-item" href="{$pdSelfUrl}#pd-usage">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M22 12A10 10 0 1112 2"/><path d="M12 12l5-3"/><path d="M12 2a10 10 0 0110 10"/></svg>
            {$LANG.usagestats|default:'Resource Usage'}
        </a>
        {/if}
        {if $pdHasAddons}
        <a class="subnav-item" href="{$pdSelfUrl}#pd-addons">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M20.5 11H19V7a2 2 0 00-2-2h-4V3.5a2.5 2.5 0 00-5 0V5H4a2 2 0 00-2 2v3.8h1.5a2.7 2.7 0 010 5.4H2V20a2 2 0 002 2h3.8v-1.5a2.7 2.7 0 015.4 0V22H17a2 2 0 002-2v-4h1.5a2.5 2.5 0 000-5z"/></svg>
            {$LANG.clientareahostingaddons}
        </a>
        {/if}
        <a class="subnav-item" href="{$pdSelfUrl}#pd-billing">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><rect x="2" y="5" width="20" height="14" rx="2"/><line x1="2" y1="10" x2="22" y2="10"/></svg>
            {$LANG.billingOverview}
        </a>
    </div>

    {* Actions — control-panel + lifecycle (mirrors Lagom's "Service Details Actions") *}
    {if $pdHasActions}
    <div class="card subnav-card">
        <div class="subnav-heading">{$LANG.actions}</div>
        {if $pdIsCpanel}
        <a class="subnav-item" href="{$WEB_ROOT}/clientarea.php?action=productdetails&id={$id|default:0|escape}&dosinglesignon=1" target="_blank" rel="noopener">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M15 3h4a2 2 0 012 2v14a2 2 0 01-2 2h-4"/><polyline points="10 17 15 12 10 7"/><line x1="15" y1="12" x2="3" y2="12"/></svg>
            {$hadrianLang.services.loginCpanel}
        </a>
        <a class="subnav-item" href="{$WEB_ROOT}/clientarea.php?action=productdetails&id={$id|default:0|escape}&dosinglesignon=1&app=Email_Accounts" target="_blank" rel="noopener">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="5" width="18" height="14" rx="2"/><path d="M3 7l9 6 9-6"/></svg>
            {$hadrianLang.services.loginWebmail}
        </a>
        {/if}
        {if $pdHasUpgrades}
        <a class="subnav-item" href="{$WEB_ROOT}/upgrade.php?type=package&id={$id|default:0|escape}">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><line x1="12" y1="4" x2="12" y2="20"/><polyline points="8 8 12 4 16 8"/><polyline points="8 16 12 20 16 16"/></svg>
            {$LANG.upgrade}
        </a>
        {/if}
        {if $modulechangepassword}
        <a class="subnav-item" href="{$pdSelfUrl}#pd-changepw" data-pd-open>
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="11" width="18" height="11" rx="2"/><path d="M7 11V7a5 5 0 0110 0v4"/></svg>
            {$LANG.serverchangepassword}
        </a>
        {/if}
        {if $pdCanCancel}
        <a class="subnav-item subnav-item-danger" href="{$WEB_ROOT}/clientarea.php?action=cancel&id={$id|default:0|escape}">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="4.93" y1="4.93" x2="19.07" y2="19.07"/></svg>
            {$LANG.requestcancellation|default:'Request Cancellation'}
        </a>
        {/if}
    </div>
    {/if}
{/if}{* /sidebar source (whmcs $primarySidebar | hand-coded fallback) *}

</aside>
<div class="pd-main">

<div class="settings-group" id="pd-service-info">
    <div class="settings-group-header"><div class="settings-group-title">{$LANG.productdetails|default:'Service Information'}</div></div>
    {if !empty($domain)}
    <div class="settings-item"><div class="settings-item-content"><div class="settings-item-label">{$LANG.clientareahostingdomain}</div></div><div class="settings-item-action"><span class="settings-item-value">{$domain|escape}</span></div></div>
    {/if}
    {if $serverdata && !empty($serverdata.hostname)}
    <div class="settings-item"><div class="settings-item-content"><div class="settings-item-label">{$LANG.servername}</div></div><div class="settings-item-action"><span class="settings-item-value" style="font-family:var(--font-mono);font-size:13px;">{$serverdata.hostname|escape}</span></div></div>
    {/if}
    {if !empty($username)}
    <div class="settings-item"><div class="settings-item-content"><div class="settings-item-label">{$LANG.serverusername}</div></div><div class="settings-item-action"><span class="settings-item-value" style="font-family:var(--font-mono);font-size:13px;">{$username|escape}</span></div></div>
    {/if}
    {if !empty($dedicatedip)}
    <div class="settings-item"><div class="settings-item-content"><div class="settings-item-label">{$LANG.primaryIP}</div></div><div class="settings-item-action"><span class="settings-item-value" style="font-family:var(--font-mono);font-size:13px;">{$dedicatedip|escape}</span></div></div>
    {elseif $serverdata && !empty($serverdata.ipaddress)}
    <div class="settings-item"><div class="settings-item-content"><div class="settings-item-label">{$LANG.primaryIP}</div></div><div class="settings-item-action"><span class="settings-item-value" style="font-family:var(--font-mono);font-size:13px;">{$serverdata.ipaddress|escape}</span></div></div>
    {/if}
    {if !empty($assignedips)}
    <div class="settings-item"><div class="settings-item-content"><div class="settings-item-label">{$LANG.assignedIPs}</div></div><div class="settings-item-action"><span class="settings-item-value" style="font-family:var(--font-mono);font-size:13px;">{$assignedips|nl2br}</span></div></div>
    {/if}
    {if $serverdata && ($serverdata.nameserver1 || $serverdata.nameserver2)}
    <div class="settings-item"><div class="settings-item-content"><div class="settings-item-label">{$LANG.domainnameservers}</div></div><div class="settings-item-action"><span class="settings-item-value" style="font-size:13px;">{if $serverdata.nameserver1}{$serverdata.nameserver1|escape}{/if}{if $serverdata.nameserver2}<br>{$serverdata.nameserver2|escape}{/if}</span></div></div>
    {elseif !empty($ns1) || !empty($ns2)}
    <div class="settings-item"><div class="settings-item-content"><div class="settings-item-label">{$LANG.domainnameservers}</div></div><div class="settings-item-action"><span class="settings-item-value" style="font-size:13px;">{$ns1|default:''|escape}{if !empty($ns2)}<br>{$ns2|escape}{/if}</span></div></div>
    {/if}
</div>

{* ── Resource usage ──────────────────────────────────────────────────
   Header ALWAYS renders (unlike stock nexus/lagom, which hide it). The
   disk/bandwidth bars show only when the server module has reported usage
   ($lastupdate, set on the last sync); otherwise a short note. Bar width
   uses the real $diskpercent / $bwpercent (e.g. "12%"); values are in MB. *}
{* ── License Details (Software Licensing module output) ──────────────────
   hadrian replaced the raw $moduleclientarea dump with hosting status-cards
   (see the Manage card below), which hid the licensing module's panel. Render
   it here for any non-cPanel module service (licensing etc.), Apple-styled. *}
{if !empty($moduleclientarea) && !$pdIsCpanelSvc}
<style>{literal}
#pd-license .section-header,#pd-license .section-title{display:none}
#pd-license .panel,#pd-license .section{border:0;box-shadow:none;background:transparent;margin:0;padding:0}
#pd-license .panel-body{padding:0}
#pd-license h6{font-size:12px;text-transform:uppercase;letter-spacing:.04em;color:var(--color-text-tertiary,#86868b);margin:16px 0 6px;font-weight:600}
#pd-license h6:first-child{margin-top:0}
#pd-license .form-control{width:100%;font-family:ui-monospace,SFMono-Regular,Menlo,monospace;font-size:13px;line-height:1.5;padding:10px 12px;border:1px solid var(--color-border,#e3e8ee);border-radius:8px;background:var(--color-bg-subtle,#f7f8fa);color:var(--color-text,#1d1d1f);resize:vertical}
#pd-license .label{display:inline-block;padding:3px 11px;border-radius:20px;font-size:12px;font-weight:600}
#pd-license .label-success{background:#d4f4dd;color:#1a7f37}
#pd-license .label-info{background:#d6e9ff;color:#0b5cad}
#pd-license .label-warning{background:#fdf0c9;color:#9a6700}
#pd-license .label-danger{background:#fbe0e0;color:#b00020}
{/literal}</style>
<div class="card" id="pd-license">
    <div class="card-header"><h2 class="card-title">License Details</h2></div>
    <div class="card-body">{$moduleclientarea}</div>
</div>
{/if}

<div class="card" id="pd-usage">
    <div class="card-header"><h2 class="card-title">{$LANG.usagestats|default:'Resource Usage'}</h2></div>
    <div class="card-body">
        {if $lastupdate}
        <div class="usage-bar-container">
            <div class="usage-bar-header"><span class="usage-bar-label">{$LANG.diskSpace}</span><span class="usage-bar-value">{$diskusage|escape}MB / {$disklimit|escape}MB</span></div>
            <div class="usage-bar"><div class="usage-bar-fill blue" style="width:{$diskpercent|default:'0%'};"></div></div>
        </div>
        <div class="usage-bar-container">
            <div class="usage-bar-header"><span class="usage-bar-label">{$LANG.bandwidth}</span><span class="usage-bar-value">{$bwusage|escape}MB / {$bwlimit|escape}MB</span></div>
            <div class="usage-bar"><div class="usage-bar-fill green" style="width:{$bwpercent|default:'0%'};"></div></div>
        </div>
        <p style="font-size:12px;color:var(--color-text-tertiary);margin:14px 0 0;">{$LANG.clientarealastupdated}: {$lastupdate|escape}</p>
        {else}
        <p style="font-size:13px;color:var(--color-text-tertiary);margin:0;padding:4px 0;">{$hadrianLang.services.usageNotAvailable}</p>
        {/if}
    </div>
</div>

{* ── Manage (control-panel actions + lifecycle) ──────────────────────
   Option C (login CTAs + rows), native. cPanel / Webmail use WHMCS single
   sign-on (dosinglesignon=1 -- the same mechanism the cPanel module's own
   overview emits; see modules/servers/cpanel/overview.tpl), shown only for
   cPanel services ($module == 'cpanel') and requiring SSO to be enabled
   for the account. Change Password is the real module POST form
   (modulechangepassword=true, fields newpw/confirmpw, gated on
   $modulechangepassword). Request Cancellation is the core cancel action.
   Replaces the old raw $moduleclientarea dump. Status vars ($pdIsCpanelSvc,
   $pdIsActive, $pdCanCancel, $pdIsCpanel) are computed once at the top. *}
{if $pdIsCpanelSvc || $modulechangepassword || $pdCanCancel || $pdHasUpgrades}
<div class="card pd-manage-card" id="pd-manage">
    <div class="card-header"><h2 class="card-title">{$LANG.manage}</h2></div>

    <div class="card-body pd-manage-body">
    {if $pdIsCpanel}
    <div class="card-body">
        <div class="pd-manage-cta">
            <a href="{$WEB_ROOT}/clientarea.php?action=productdetails&id={$id|default:0|escape}&dosinglesignon=1" target="_blank" rel="noopener" class="btn-primary">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.9" stroke-linecap="round" stroke-linejoin="round"><path d="M15 3h4a2 2 0 012 2v14a2 2 0 01-2 2h-4"/><polyline points="10 17 15 12 10 7"/><line x1="15" y1="12" x2="3" y2="12"/></svg>
                {$hadrianLang.services.loginCpanel}
            </a>
            <a href="{$WEB_ROOT}/clientarea.php?action=productdetails&id={$id|default:0|escape}&dosinglesignon=1&app=Email_Accounts" target="_blank" rel="noopener" class="btn-secondary">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="5" width="18" height="14" rx="2"/><path d="M3 7l9 6 9-6"/></svg>
                {$hadrianLang.services.loginWebmail}
            </a>
        </div>
    </div>
    {/if}

    {if $pdIsCpanelSvc && !$pdIsActive}
    <div class="card-body">
        <div class="pd-alert pd-alert-warn">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>
            <div>{if !empty($suspendreason)}<strong>{$suspendreason|escape}</strong> &mdash; {/if}{if $svcStatusLower == 'pending'}{$hadrianLang.services.cpPendingNotice}{elseif $svcStatusLower == 'terminated' || $svcStatusLower == 'cancelled'}{$hadrianLang.services.cpUnavailableTerminated|replace:'%s':$svcStatusText|escape}{else}{$hadrianLang.services.cpUnavailableStatus|replace:'%s':$svcStatusText|escape}{if $svcStatusLower == 'suspended' && isset($unpaidInvoice) && $unpaidInvoice} {$hadrianLang.services.cpPayOverdue}{/if}{/if}</div>
        </div>
    </div>
    {/if}

    {if $pdHasUpgrades}
    <a href="{$WEB_ROOT}/upgrade.php?type=package&id={$id|default:0|escape}" class="settings-item pd-manage-upgrade" style="text-decoration:none;color:inherit;">
        <div class="settings-item-icon pd-manage-upgrade-ico">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><line x1="12" y1="4" x2="12" y2="20"/><polyline points="8 8 12 4 16 8"/><polyline points="8 16 12 20 16 16"/></svg>
        </div>
        <div class="settings-item-content"><div class="settings-item-label">{$LANG.upgrade}</div><div class="settings-item-sublabel">{$hadrianLang.services.upgradeSublabel}</div></div>
        <div class="settings-item-action"><span class="settings-item-chevron"><svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="9 18 15 12 9 6"/></svg></span></div>
    </a>
    {/if}

    {if $showRenewServiceButton === true}
    <a href="{routePath('service-renewals-service', $id)}" class="settings-item pd-manage-renew" style="text-decoration:none;color:inherit;">
        <div class="settings-item-icon pd-manage-renew-ico">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M23 4v6h-6"/><path d="M20.49 15a9 9 0 11-2.12-9.36L23 10"/></svg>
        </div>
        <div class="settings-item-content"><div class="settings-item-label">{$LANG.renewService.titleSingular}</div><div class="settings-item-sublabel">{$hadrianLang.services.renewSublabel}</div></div>
        <div class="settings-item-action"><span class="settings-item-chevron"><svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="9 18 15 12 9 6"/></svg></span></div>
    </a>
    {/if}

    {if $modulechangepassword}
    <details class="pd-manage-changepw" id="pd-changepw">
        <summary class="settings-item">
            <div class="settings-item-icon pd-manage-pw-ico">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="11" width="18" height="11" rx="2"/><path d="M7 11V7a5 5 0 0110 0v4"/></svg>
            </div>
            <div class="settings-item-content"><div class="settings-item-label">{$LANG.serverchangepassword}</div><div class="settings-item-sublabel">{$hadrianLang.services.changePwSublabel}</div></div>
            <div class="settings-item-action"><span class="settings-item-chevron"><svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="9 18 15 12 9 6"/></svg></span></div>
        </summary>
        <div class="pd-manage-changepw-body">
            {if $modulechangepwresult == 'success'}
            <div class="pd-alert pd-alert-success">{$modulechangepasswordmessage|default:''}</div>
            {elseif $modulechangepwresult == 'error'}
            <div class="pd-alert pd-alert-error">{$modulechangepasswordmessage|strip_tags}</div>
            {/if}
            <form method="post" action="{$WEB_ROOT}/clientarea.php?action=productdetails&id={$id|default:0|escape}">
                <input type="hidden" name="id" value="{$id|default:0|escape}">
                <input type="hidden" name="modulechangepassword" value="true">
                <label class="pd-field-label" for="pdNewPw">{$LANG.newpassword}</label>
                <input type="password" class="pd-field-input" id="pdNewPw" name="newpw" autocomplete="new-password">
                <label class="pd-field-label" for="pdConfirmPw">{$LANG.confirmnewpassword}</label>
                <input type="password" class="pd-field-input" id="pdConfirmPw" name="confirmpw" autocomplete="new-password">
                <button type="submit" class="btn-primary pd-field-submit">{$LANG.clientareasavechanges}</button>
            </form>
        </div>
    </details>
    {/if}

    {if $pdCanCancel}
    <a href="{$WEB_ROOT}/clientarea.php?action=cancel&id={$id|default:0|escape}" class="settings-item pd-manage-cancel" style="text-decoration:none;color:inherit;">
        <div class="settings-item-icon pd-manage-cancel-ico">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="4.93" y1="4.93" x2="19.07" y2="19.07"/></svg>
        </div>
        <div class="settings-item-content"><div class="settings-item-label pd-manage-cancel-label">{$LANG.requestcancellation|default:'Request Cancellation'}</div><div class="settings-item-sublabel">{$hadrianLang.services.cancelSublabel}</div></div>
        <div class="settings-item-action"><span class="settings-item-chevron"><svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="9 18 15 12 9 6"/></svg></span></div>
    </a>
    {/if}
    </div><!-- /.pd-manage-body -->
</div>
{/if}

{* ── Quick Shortcuts (cPanel feature launchpad) ──────────────────────
   Native Apple-styled grid of cPanel feature deep-links via WHMCS single
   sign-on app tokens (dosinglesignon=1&app=<token>), the same tokens the
   cPanel module's own overview.tpl emits. Shown only for active cPanel
   services. Labels are hardcoded English -- the cPanel module's
   $LANG.cPanel.* keys are not reliably loaded on the theme's product page. *}
{if $pdIsCpanelSvc}
<div class="card pd-shortcuts-card">
    <div class="card-header"><h2 class="card-title">{$LANG.quickShortcuts}</h2></div>
    <div class="card-body">
        {if $pdIsActive}
        <div class="pd-shortcuts">
            <a class="pd-shortcut" href="{$WEB_ROOT}/clientarea.php?action=productdetails&id={$id|default:0|escape}&dosinglesignon=1&app=Email_Accounts" target="_blank" rel="noopener">
                <span class="pd-shortcut-icon blue"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="5" width="18" height="14" rx="2"/><path d="M3 7l9 6 9-6"/></svg></span>
                <span class="pd-shortcut-label">{$hadrianLang.services.scEmailAccounts}</span>
            </a>
            <a class="pd-shortcut" href="{$WEB_ROOT}/clientarea.php?action=productdetails&id={$id|default:0|escape}&dosinglesignon=1&app=Email_Forwarders" target="_blank" rel="noopener">
                <span class="pd-shortcut-icon blue"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><polyline points="15 17 20 12 15 7"/><path d="M4 18v-2a4 4 0 014-4h12"/></svg></span>
                <span class="pd-shortcut-label">{$hadrianLang.services.scForwarders}</span>
            </a>
            <a class="pd-shortcut" href="{$WEB_ROOT}/clientarea.php?action=productdetails&id={$id|default:0|escape}&dosinglesignon=1&app=Email_AutoResponders" target="_blank" rel="noopener">
                <span class="pd-shortcut-icon blue"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><polyline points="9 17 4 12 9 7"/><path d="M20 18v-2a4 4 0 00-4-4H4"/></svg></span>
                <span class="pd-shortcut-label">{$hadrianLang.services.scAutoresponders}</span>
            </a>
            <a class="pd-shortcut" href="{$WEB_ROOT}/clientarea.php?action=productdetails&id={$id|default:0|escape}&dosinglesignon=1&app=FileManager_Home" target="_blank" rel="noopener">
                <span class="pd-shortcut-icon orange"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M3 7a2 2 0 012-2h4l2 2h8a2 2 0 012 2v8a2 2 0 01-2 2H5a2 2 0 01-2-2z"/></svg></span>
                <span class="pd-shortcut-label">{$hadrianLang.services.scFileManager}</span>
            </a>
            <a class="pd-shortcut" href="{$WEB_ROOT}/clientarea.php?action=productdetails&id={$id|default:0|escape}&dosinglesignon=1&app=Backups_Home" target="_blank" rel="noopener">
                <span class="pd-shortcut-icon orange"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M4 8v11a1 1 0 001 1h14a1 1 0 001-1V8"/><rect x="2" y="4" width="20" height="4" rx="1"/><line x1="10" y1="12" x2="14" y2="12"/></svg></span>
                <span class="pd-shortcut-label">{$hadrianLang.services.scBackup}</span>
            </a>
            <a class="pd-shortcut" href="{$WEB_ROOT}/clientarea.php?action=productdetails&id={$id|default:0|escape}&dosinglesignon=1&app=Domains_SubDomains" target="_blank" rel="noopener">
                <span class="pd-shortcut-icon green"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="9"/><line x1="3" y1="12" x2="21" y2="12"/><path d="M12 3c2.5 2.5 4 5.7 4 9s-1.5 6.5-4 9c-2.5-2.5-4-5.7-4-9s1.5-6.5 4-9z"/></svg></span>
                <span class="pd-shortcut-label">{$hadrianLang.services.scSubdomains}</span>
            </a>
            <a class="pd-shortcut" href="{$WEB_ROOT}/clientarea.php?action=productdetails&id={$id|default:0|escape}&dosinglesignon=1&app=Domains_AddonDomains" target="_blank" rel="noopener">
                <span class="pd-shortcut-icon green"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><polygon points="12 2 2 7 12 12 22 7 12 2"/><polyline points="2 17 12 22 22 17"/><polyline points="2 12 12 17 22 12"/></svg></span>
                <span class="pd-shortcut-label">{$hadrianLang.services.scAddonDomains}</span>
            </a>
            <a class="pd-shortcut" href="{$WEB_ROOT}/clientarea.php?action=productdetails&id={$id|default:0|escape}&dosinglesignon=1&app=Cron_Home" target="_blank" rel="noopener">
                <span class="pd-shortcut-icon gray"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="9"/><polyline points="12 7 12 12 15 14"/></svg></span>
                <span class="pd-shortcut-label">{$hadrianLang.services.scCronJobs}</span>
            </a>
            <a class="pd-shortcut" href="{$WEB_ROOT}/clientarea.php?action=productdetails&id={$id|default:0|escape}&dosinglesignon=1&app=Database_MySQL" target="_blank" rel="noopener">
                <span class="pd-shortcut-icon red"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><ellipse cx="12" cy="5" rx="8" ry="3"/><path d="M4 5v6c0 1.7 3.6 3 8 3s8-1.3 8-3V5"/><path d="M4 11v6c0 1.7 3.6 3 8 3s8-1.3 8-3v-6"/></svg></span>
                <span class="pd-shortcut-label">{$hadrianLang.services.scMysql}</span>
            </a>
            <a class="pd-shortcut" href="{$WEB_ROOT}/clientarea.php?action=productdetails&id={$id|default:0|escape}&dosinglesignon=1&app=Database_phpMyAdmin" target="_blank" rel="noopener">
                <span class="pd-shortcut-icon red"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="3" width="18" height="18" rx="2"/><line x1="3" y1="9" x2="21" y2="9"/><line x1="9" y1="9" x2="9" y2="21"/></svg></span>
                <span class="pd-shortcut-label">phpMyAdmin</span>
            </a>
            <a class="pd-shortcut" href="{$WEB_ROOT}/clientarea.php?action=productdetails&id={$id|default:0|escape}&dosinglesignon=1&app=Stats_AWStats" target="_blank" rel="noopener">
                <span class="pd-shortcut-icon gray"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M4 4v15a1 1 0 001 1h15"/><polyline points="7 14 11 10 14 13 19 7"/></svg></span>
                <span class="pd-shortcut-label">Awstats</span>
            </a>
        </div>
        {else}
        <div class="pd-alert pd-alert-warn">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>
            <div>{if $svcStatusLower == 'pending'}{$hadrianLang.services.scPendingNotice}{else}{$hadrianLang.services.scUnavailableStatus|replace:'%s':$svcStatusText|escape}{/if}</div>
        </div>
        {/if}
    </div>
</div>
{/if}

{* Quick actions folded into the Manage card (Upgrade / Downgrade); the
   standalone Back-to-services + Renew rows were retired to match the mockup. *}

{* ── Addons ──────────────────────────────────────────────────────────
   Lagom surfaces product addons in its sidebar Overview + an Addons tab.
   hadrian renders them as a compact section, only when the service has addons.
   Standard WHMCS productdetails addon vars: name / status / pricing /
   regdate / nextduedate / managementActions. *}
{if $pdHasAddons}
<div class="settings-group" id="pd-addons">
    <div class="settings-group-header"><div class="settings-group-title">{$LANG.clientareahostingaddons}</div></div>
    {foreach from=$addons item=addon}
    <div class="settings-item">
        <div class="settings-item-content">
            <div class="settings-item-label">{$addon.name|escape}</div>
            <div class="settings-item-sublabel">{if !empty($addon.status)}{$addon.status|strip_tags|escape}{/if}{if !empty($addon.nextduedate)} &middot; {$LANG.clientareahostingnextduedate}: {$addon.nextduedate|escape}{/if}</div>
        </div>
        {if !empty($addon.pricing)}<div class="settings-item-action"><span class="settings-item-value">{$addon.pricing}</span></div>{/if}
    </div>
    {/foreach}
</div>
{/if}

{* Billing overview -- the money fields, split out of Service Information into
   their own section at the end (matches Lagom's Billing Overview). *}
{if !empty($regdate) || !empty($nextduedate) || !empty($recurringamount) || !empty($paymentmethodname) || !empty($firstpaymentamount)}
<div class="settings-group" id="pd-billing">
    <div class="settings-group-header"><div class="settings-group-title">{$LANG.billingOverview}</div></div>
    {if !empty($regdate)}
    <div class="settings-item"><div class="settings-item-content"><div class="settings-item-label">{$LANG.clientareahostingregdate}</div></div><div class="settings-item-action"><span class="settings-item-value">{$regdate|escape}</span></div></div>
    {/if}
    {if !empty($nextduedate)}
    <div class="settings-item"><div class="settings-item-content"><div class="settings-item-label">{$LANG.clientareahostingnextduedate}</div></div><div class="settings-item-action"><span class="settings-item-value">{$nextduedate|escape}</span></div></div>
    {/if}
    {if !empty($recurringamount)}
    <div class="settings-item"><div class="settings-item-content"><div class="settings-item-label">{$LANG.recurringamount}</div></div><div class="settings-item-action"><span class="settings-item-value">{$recurringamount|escape}{if !empty($billingcycle)} / {$billingcycle|escape}{/if}</span></div></div>
    {/if}
    {if !empty($paymentmethodname)}
    <div class="settings-item"><div class="settings-item-content"><div class="settings-item-label">{$LANG.paymentmethod}</div></div><div class="settings-item-action"><span class="settings-item-value">{$paymentmethodname|escape}</span></div></div>
    {/if}
    {if !empty($firstpaymentamount)}
    <div class="settings-item"><div class="settings-item-content"><div class="settings-item-label">{$LANG.firstpaymentamount}</div></div><div class="settings-item-action"><span class="settings-item-value">{$firstpaymentamount|escape}</span></div></div>
    {/if}
</div>
{/if}

</div>{* /.pd-main *}
</div>{* /.pd-split *}

{* Sidebar behaviour: intercept in-page section links (they carry ABSOLUTE
   hrefs because the page has a <base href>, which would otherwise send a bare
   "#id" to the site root → homepage) and scroll smoothly without navigating —
   the same no-reload feel as Lagom's tab toggles. Also opens the Change
   Password expander and runs a scrollspy. Wrapped in a literal block so Smarty
   doesn't parse the JS braces. *}
<script>
{literal}
(function () {
    var anchors = Array.prototype.slice.call(
        document.querySelectorAll('.pd-aside a.subnav-item')
    ).filter(function (a) {
        return a.hash && a.hash.indexOf('#pd-') === 0 && document.querySelector(a.hash);
    });

    anchors.forEach(function (a) {
        a.addEventListener('click', function (e) {
            var el = document.querySelector(a.hash);
            if (!el) { return; }
            e.preventDefault();
            if (a.hasAttribute('data-pd-open') && el.tagName === 'DETAILS') { el.open = true; }
            el.scrollIntoView({ behavior: 'smooth', block: 'start' });
            if (window.history && history.replaceState) { history.replaceState(null, '', a.hash); }
        });
    });

    var map = {};
    var targets = [];
    anchors.forEach(function (a) {
        var el = document.querySelector(a.hash);
        if (el && !map[el.id]) { map[el.id] = a; targets.push(el); }
    });
    if ('IntersectionObserver' in window && targets.length) {
        var spy = new IntersectionObserver(function (entries) {
            entries.forEach(function (e) {
                if (e.isIntersecting && map[e.target.id]) {
                    anchors.forEach(function (l) { l.classList.remove('active'); });
                    map[e.target.id].classList.add('active');
                }
            });
        }, { rootMargin: '-45% 0px -50% 0px', threshold: 0 });
        targets.forEach(function (t) { spy.observe(t); });
    }
})();
{/literal}
</script>

