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
     $loginButton                              — MyTheme-provided login URL (NOT a
                                                 stock WHMCS var; absent w/o module)
     $pendingcancellation                      — bool, cancellation pending
     $upgrades                                 — array of available upgrade IDs

   Layout: single stacked column of standard settings-group / card sections
   (parity with the apple-client-area mockup). settings-group + card respond
   to the preview chip's Controls inside/outside (apple-layout.css svc-layout).
*}

{assign var=svcStatusText  value=$status|default:''|strip_tags}
{assign var=svcStatusLower value=$rawstatus|default:$svcStatusText|lower|replace:' ':'-'}

<link rel="stylesheet" href="{$WEB_ROOT}/templates/{$template}/assets/css/pages/clientareaproductdetails.css?v={$myTheme.version|default:'1.0'}">

<header class="page-header">
    <div class="page-header-row">
        <div style="flex:1; min-width:0;">
            <p class="page-eyebrow">{$groupname|default:''|escape}</p>
            <h1>{$product|default:'Service'|escape}</h1>
            {if !empty($domain)}<p class="page-subtitle">{$domain|escape}</p>{/if}
        </div>
        <span class="status-pill {$svcStatusLower|escape}">{$svcStatusText|escape}</span>
    </div>
</header>

{if isset($pendingcancellation) && $pendingcancellation}
<div class="pd-alert pd-alert-warn">
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>
    {$LANG.cancellationrequestedexplanation|default:'Cancellation has been requested for this service.'}
</div>
{/if}

{if isset($unpaidInvoice) && $unpaidInvoice}
<div class="pd-alert pd-alert-error">
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>
    <div>{$unpaidInvoiceMessage|default:'This service has an unpaid invoice.'}</div>
    <a href="{$WEB_ROOT}/viewinvoice.php?id={$unpaidInvoice|escape}" class="btn-primary pd-alert-cta">{$LANG.payinvoice|default:'Pay invoice'}</a>
</div>
{/if}

{* ── Service information ───────────────────────────────────────────── *}
<div class="settings-group">
    <div class="settings-group-header"><div class="settings-group-title">{$LANG.productdetails|default:'Service Information'}</div></div>
    {if !empty($domain)}
    <div class="settings-item"><div class="settings-item-content"><div class="settings-item-label">{$LANG.domain|default:'Domain'}</div></div><div class="settings-item-action"><span class="settings-item-value">{$domain|escape}</span></div></div>
    {/if}
    {if $serverdata && !empty($serverdata.hostname)}
    <div class="settings-item"><div class="settings-item-content"><div class="settings-item-label">{$LANG.servername|default:'Server'}</div></div><div class="settings-item-action"><span class="settings-item-value" style="font-family:var(--font-mono);font-size:13px;">{$serverdata.hostname|escape}</span></div></div>
    {/if}
    {if !empty($username)}
    <div class="settings-item"><div class="settings-item-content"><div class="settings-item-label">{$LANG.serverusername|default:'Server username'}</div></div><div class="settings-item-action"><span class="settings-item-value" style="font-family:var(--font-mono);font-size:13px;">{$username|escape}</span></div></div>
    {/if}
    {if !empty($dedicatedip)}
    <div class="settings-item"><div class="settings-item-content"><div class="settings-item-label">{$LANG.primaryIP|default:'IP address'}</div></div><div class="settings-item-action"><span class="settings-item-value" style="font-family:var(--font-mono);font-size:13px;">{$dedicatedip|escape}</span></div></div>
    {elseif $serverdata && !empty($serverdata.ipaddress)}
    <div class="settings-item"><div class="settings-item-content"><div class="settings-item-label">{$LANG.primaryIP|default:'IP address'}</div></div><div class="settings-item-action"><span class="settings-item-value" style="font-family:var(--font-mono);font-size:13px;">{$serverdata.ipaddress|escape}</span></div></div>
    {/if}
    {if !empty($assignedips)}
    <div class="settings-item"><div class="settings-item-content"><div class="settings-item-label">{$LANG.assignedIPs|default:'Assigned IPs'}</div></div><div class="settings-item-action"><span class="settings-item-value" style="font-family:var(--font-mono);font-size:13px;">{$assignedips|nl2br}</span></div></div>
    {/if}
    {if $serverdata && ($serverdata.nameserver1 || $serverdata.nameserver2)}
    <div class="settings-item"><div class="settings-item-content"><div class="settings-item-label">{$LANG.domainnameservers|default:'Nameservers'}</div></div><div class="settings-item-action"><span class="settings-item-value" style="font-size:13px;">{if $serverdata.nameserver1}{$serverdata.nameserver1|escape}{/if}{if $serverdata.nameserver2}<br>{$serverdata.nameserver2|escape}{/if}</span></div></div>
    {elseif !empty($ns1) || !empty($ns2)}
    <div class="settings-item"><div class="settings-item-content"><div class="settings-item-label">{$LANG.domainnameservers|default:'Nameservers'}</div></div><div class="settings-item-action"><span class="settings-item-value" style="font-size:13px;">{$ns1|default:''|escape}{if !empty($ns2)}<br>{$ns2|escape}{/if}</span></div></div>
    {/if}
    {if !empty($regdate)}
    <div class="settings-item"><div class="settings-item-content"><div class="settings-item-label">{$LANG.registrationdate|default:'Registration date'}</div></div><div class="settings-item-action"><span class="settings-item-value">{$regdate|escape}</span></div></div>
    {/if}
    {if !empty($nextduedate)}
    <div class="settings-item"><div class="settings-item-content"><div class="settings-item-label">{$LANG.invoicedatedue|default:'Next due date'}</div></div><div class="settings-item-action"><span class="settings-item-value">{$nextduedate|escape}</span></div></div>
    {/if}
    {if !empty($recurringamount)}
    <div class="settings-item"><div class="settings-item-content"><div class="settings-item-label">{$LANG.recurringamount|default:'Billing'}</div></div><div class="settings-item-action"><span class="settings-item-value">{$recurringamount|escape}{if !empty($billingcycle)} / {$billingcycle|escape}{/if}</span></div></div>
    {/if}
    {if !empty($paymentmethodname)}
    <div class="settings-item"><div class="settings-item-content"><div class="settings-item-label">{$LANG.paymentmethod|default:'Payment method'}</div></div><div class="settings-item-action"><span class="settings-item-value">{$paymentmethodname|escape}</span></div></div>
    {/if}
    {if !empty($firstpaymentamount)}
    <div class="settings-item"><div class="settings-item-content"><div class="settings-item-label">{$LANG.firstpaymentamount|default:'First payment'}</div></div><div class="settings-item-action"><span class="settings-item-value">{$firstpaymentamount|escape}</span></div></div>
    {/if}
</div>

{* ── Resource usage ──────────────────────────────────────────────────
   Header ALWAYS renders (unlike stock nexus/lagom, which hide it). The
   disk/bandwidth bars show only when the server module has reported usage
   ($lastupdate, set on the last sync); otherwise a short note. Bar width
   uses the real $diskpercent / $bwpercent (e.g. "12%"); values are in MB. *}
<div class="card">
    <div class="card-header"><h2 class="card-title">{$LANG.usagestats|default:'Resource Usage'}</h2></div>
    <div class="card-body">
        {if $lastupdate}
        <div class="usage-bar-container">
            <div class="usage-bar-header"><span class="usage-bar-label">{$LANG.diskSpace|default:'Disk space'}</span><span class="usage-bar-value">{$diskusage|escape}MB / {$disklimit|escape}MB</span></div>
            <div class="usage-bar"><div class="usage-bar-fill blue" style="width:{$diskpercent|default:'0%'};"></div></div>
        </div>
        <div class="usage-bar-container">
            <div class="usage-bar-header"><span class="usage-bar-label">{$LANG.bandwidth|default:'Bandwidth'}</span><span class="usage-bar-value">{$bwusage|escape}MB / {$bwlimit|escape}MB</span></div>
            <div class="usage-bar"><div class="usage-bar-fill green" style="width:{$bwpercent|default:'0%'};"></div></div>
        </div>
        <p style="font-size:12px;color:var(--color-text-tertiary);margin:14px 0 0;">{$LANG.clientarealastupdated|default:'Last updated'}: {$lastupdate|escape}</p>
        {else}
        <p style="font-size:13px;color:var(--color-text-tertiary);margin:0;padding:4px 0;">{$LANG.usagenotavailable|default:'Usage statistics are not available for this service yet.'}</p>
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
   Replaces the old raw $moduleclientarea dump. *}
{assign var=pdCanCancel value=false}
{if (!isset($pendingcancellation) || !$pendingcancellation) && $svcStatusLower == 'active'}{assign var=pdCanCancel value=true}{/if}
{assign var=pdIsCpanel value=false}
{if $module == 'cpanel' && !empty($moduleclientarea)}{assign var=pdIsCpanel value=true}{/if}
{if $pdIsCpanel || $modulechangepassword || $pdCanCancel || (isset($upgrades) && $upgrades|@count > 0)}
<div class="card pd-manage-card">
    <div class="card-header"><h2 class="card-title">{$LANG.manage|default:'Manage'}</h2></div>

    {if $pdIsCpanel}
    <div class="card-body">
        <div class="pd-manage-cta">
            <a href="{$WEB_ROOT}/clientarea.php?action=productdetails&id={$id|default:0|escape}&dosinglesignon=1" target="_blank" rel="noopener" class="btn-primary">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.9" stroke-linecap="round" stroke-linejoin="round"><path d="M15 3h4a2 2 0 012 2v14a2 2 0 01-2 2h-4"/><polyline points="10 17 15 12 10 7"/><line x1="15" y1="12" x2="3" y2="12"/></svg>
                Log in to cPanel
            </a>
            <a href="{$WEB_ROOT}/clientarea.php?action=productdetails&id={$id|default:0|escape}&dosinglesignon=1&app=Email_Accounts" target="_blank" rel="noopener" class="btn-secondary">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="5" width="18" height="14" rx="2"/><path d="M3 7l9 6 9-6"/></svg>
                Log in to Webmail
            </a>
        </div>
    </div>
    {/if}

    {if isset($upgrades) && $upgrades|@count > 0}
    <a href="{$WEB_ROOT}/upgrade.php?type=package&id={$id|default:0|escape}" class="settings-item pd-manage-upgrade" style="text-decoration:none;color:inherit;">
        <div class="settings-item-icon pd-manage-upgrade-ico">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><line x1="12" y1="4" x2="12" y2="20"/><polyline points="8 8 12 4 16 8"/><polyline points="8 16 12 20 16 16"/></svg>
        </div>
        <div class="settings-item-content"><div class="settings-item-label">{$LANG.upgrade|default:'Upgrade / Downgrade'}</div><div class="settings-item-sublabel">{$LANG.upgradeavailable|default:'Change your hosting plan'}</div></div>
        <div class="settings-item-action"><span class="settings-item-chevron"><svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="9 18 15 12 9 6"/></svg></span></div>
    </a>
    {/if}

    {if $svcStatusLower == 'active'}
    <a href="{$WEB_ROOT}/clientarea.php?action=productdetails&id={$id|escape}&modop=custom&a=Renew" class="settings-item pd-manage-renew" style="text-decoration:none;color:inherit;">
        <div class="settings-item-icon pd-manage-renew-ico">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M23 4v6h-6"/><path d="M20.49 15a9 9 0 11-2.12-9.36L23 10"/></svg>
        </div>
        <div class="settings-item-content"><div class="settings-item-label">{$LANG.renew|default:'Renew now'}</div><div class="settings-item-sublabel">Extend your service term</div></div>
        <div class="settings-item-action"><span class="settings-item-chevron"><svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="9 18 15 12 9 6"/></svg></span></div>
    </a>
    {/if}

    {if $modulechangepassword}
    <details class="pd-manage-changepw">
        <summary class="settings-item">
            <div class="settings-item-icon pd-manage-pw-ico">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="11" width="18" height="11" rx="2"/><path d="M7 11V7a5 5 0 0110 0v4"/></svg>
            </div>
            <div class="settings-item-content"><div class="settings-item-label">{$LANG.serverchangepassword|default:'Change Password'}</div><div class="settings-item-sublabel">Set a new control-panel password</div></div>
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
                <label class="pd-field-label" for="pdNewPw">{$LANG.newpassword|default:'New password'}</label>
                <input type="password" class="pd-field-input" id="pdNewPw" name="newpw" autocomplete="new-password">
                <label class="pd-field-label" for="pdConfirmPw">{$LANG.confirmnewpassword|default:'Confirm new password'}</label>
                <input type="password" class="pd-field-input" id="pdConfirmPw" name="confirmpw" autocomplete="new-password">
                <button type="submit" class="btn-primary pd-field-submit">{$LANG.clientareasavechanges|default:'Save changes'}</button>
            </form>
        </div>
    </details>
    {/if}

    {if $pdCanCancel}
    <a href="{$WEB_ROOT}/clientarea.php?action=cancel&id={$id|default:0|escape}" class="settings-item pd-manage-cancel" style="text-decoration:none;color:inherit;">
        <div class="settings-item-icon pd-manage-cancel-ico">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="4.93" y1="4.93" x2="19.07" y2="19.07"/></svg>
        </div>
        <div class="settings-item-content"><div class="settings-item-label pd-manage-cancel-label">{$LANG.requestcancellation|default:'Request Cancellation'}</div><div class="settings-item-sublabel">Schedule this service to be cancelled</div></div>
        <div class="settings-item-action"><span class="settings-item-chevron"><svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="9 18 15 12 9 6"/></svg></span></div>
    </a>
    {/if}
</div>
{/if}

{* ── Quick Shortcuts (cPanel feature launchpad) ──────────────────────
   Native Apple-styled grid of cPanel feature deep-links via WHMCS single
   sign-on app tokens (dosinglesignon=1&app=<token>), the same tokens the
   cPanel module's own overview.tpl emits. Shown only for active cPanel
   services. Labels are hardcoded English -- the cPanel module's
   $LANG.cPanel.* keys are not reliably loaded on the theme's product page. *}
{if $pdIsCpanel && $svcStatusLower == 'active'}
<div class="card pd-shortcuts-card">
    <div class="card-header"><h2 class="card-title">{$LANG.quickShortcuts|default:'Quick Shortcuts'}</h2></div>
    <div class="card-body">
        <div class="pd-shortcuts">
            <a class="pd-shortcut" href="{$WEB_ROOT}/clientarea.php?action=productdetails&id={$id|default:0|escape}&dosinglesignon=1&app=Email_Accounts" target="_blank" rel="noopener">
                <span class="pd-shortcut-icon blue"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="5" width="18" height="14" rx="2"/><path d="M3 7l9 6 9-6"/></svg></span>
                <span class="pd-shortcut-label">Email Accounts</span>
            </a>
            <a class="pd-shortcut" href="{$WEB_ROOT}/clientarea.php?action=productdetails&id={$id|default:0|escape}&dosinglesignon=1&app=Email_Forwarders" target="_blank" rel="noopener">
                <span class="pd-shortcut-icon blue"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><polyline points="15 17 20 12 15 7"/><path d="M4 18v-2a4 4 0 014-4h12"/></svg></span>
                <span class="pd-shortcut-label">Forwarders</span>
            </a>
            <a class="pd-shortcut" href="{$WEB_ROOT}/clientarea.php?action=productdetails&id={$id|default:0|escape}&dosinglesignon=1&app=Email_AutoResponders" target="_blank" rel="noopener">
                <span class="pd-shortcut-icon blue"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><polyline points="9 17 4 12 9 7"/><path d="M20 18v-2a4 4 0 00-4-4H4"/></svg></span>
                <span class="pd-shortcut-label">Autoresponders</span>
            </a>
            <a class="pd-shortcut" href="{$WEB_ROOT}/clientarea.php?action=productdetails&id={$id|default:0|escape}&dosinglesignon=1&app=FileManager_Home" target="_blank" rel="noopener">
                <span class="pd-shortcut-icon orange"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M3 7a2 2 0 012-2h4l2 2h8a2 2 0 012 2v8a2 2 0 01-2 2H5a2 2 0 01-2-2z"/></svg></span>
                <span class="pd-shortcut-label">File Manager</span>
            </a>
            <a class="pd-shortcut" href="{$WEB_ROOT}/clientarea.php?action=productdetails&id={$id|default:0|escape}&dosinglesignon=1&app=Backups_Home" target="_blank" rel="noopener">
                <span class="pd-shortcut-icon orange"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M4 8v11a1 1 0 001 1h14a1 1 0 001-1V8"/><rect x="2" y="4" width="20" height="4" rx="1"/><line x1="10" y1="12" x2="14" y2="12"/></svg></span>
                <span class="pd-shortcut-label">Backup</span>
            </a>
            <a class="pd-shortcut" href="{$WEB_ROOT}/clientarea.php?action=productdetails&id={$id|default:0|escape}&dosinglesignon=1&app=Domains_SubDomains" target="_blank" rel="noopener">
                <span class="pd-shortcut-icon green"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="9"/><line x1="3" y1="12" x2="21" y2="12"/><path d="M12 3c2.5 2.5 4 5.7 4 9s-1.5 6.5-4 9c-2.5-2.5-4-5.7-4-9s1.5-6.5 4-9z"/></svg></span>
                <span class="pd-shortcut-label">Subdomains</span>
            </a>
            <a class="pd-shortcut" href="{$WEB_ROOT}/clientarea.php?action=productdetails&id={$id|default:0|escape}&dosinglesignon=1&app=Domains_AddonDomains" target="_blank" rel="noopener">
                <span class="pd-shortcut-icon green"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><polygon points="12 2 2 7 12 12 22 7 12 2"/><polyline points="2 17 12 22 22 17"/><polyline points="2 12 12 17 22 12"/></svg></span>
                <span class="pd-shortcut-label">Addon Domains</span>
            </a>
            <a class="pd-shortcut" href="{$WEB_ROOT}/clientarea.php?action=productdetails&id={$id|default:0|escape}&dosinglesignon=1&app=Cron_Home" target="_blank" rel="noopener">
                <span class="pd-shortcut-icon gray"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="9"/><polyline points="12 7 12 12 15 14"/></svg></span>
                <span class="pd-shortcut-label">Cron Jobs</span>
            </a>
            <a class="pd-shortcut" href="{$WEB_ROOT}/clientarea.php?action=productdetails&id={$id|default:0|escape}&dosinglesignon=1&app=Database_MySQL" target="_blank" rel="noopener">
                <span class="pd-shortcut-icon red"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><ellipse cx="12" cy="5" rx="8" ry="3"/><path d="M4 5v6c0 1.7 3.6 3 8 3s8-1.3 8-3V5"/><path d="M4 11v6c0 1.7 3.6 3 8 3s8-1.3 8-3v-6"/></svg></span>
                <span class="pd-shortcut-label">MySQL Databases</span>
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
    </div>
</div>
{/if}

{* Quick actions folded into the Manage card (Upgrade / Downgrade); the
   standalone Back-to-services + Renew rows were retired to match the mockup. *}

