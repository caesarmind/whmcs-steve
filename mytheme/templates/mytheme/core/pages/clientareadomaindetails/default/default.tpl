{* Hostnodes — Domain Details (Apple-style).

   WHMCS top-level variables for this page (verified against Nexus/Lagom):
     $domain, $domainid, $registrationdate, $nextduedate
     $firstpaymentamount, $recurringamount, $registrationperiod
     $status, $systemStatus, $paymentmethod
     $nameservers (array, $nameservers[1..5].value)
     $defaultns (bool) — using default registrar NS
     $autorenew (bool), $changeAutoRenewStatusSuccessful
     $lockstatus ("locked"|"unlocked"|"")
     $managementoptions.{nameservers,contacts,locking,...}
     $renew (bool — renew allowed)
     $unpaidInvoice, $unpaidInvoiceMessage, $unpaidInvoiceOverdue
     $addons.{idprotection,dnsmanagement,emailforwarding}
     $addonstatus.{idprotection,dnsmanagement,emailforwarding}
     $addonspricing.*
     $sslStatus (object, may be null)
     $registrarclientarea (HTML), $hookOutput (array)
*}

{assign var=ddStatusText  value=$status|default:''|strip_tags}
{assign var=ddStatusLower value=$ddStatusText|lower|replace:' ':'-'}
{assign var=ddSysActive   value=($systemStatus|default:'')|lower|replace:' ':'-'}

<link rel="stylesheet" href="{$WEB_ROOT}/templates/{$template}/assets/css/pages/clientareadomaindetails.css?v={$myTheme.version|default:'1.0'}">

<header class="page-header">
    <div class="page-header-row">
        <div style="flex:1; min-width:0;">
            <p class="page-eyebrow">{$LANG.domain|default:'Domain'}</p>
            <h1>{$domain|default:'Domain'|escape}</h1>
            {if !empty($registrationdate)}<p class="page-subtitle">{$LANG.clientareahostingregdate|default:'Registered'} · {$registrationdate|escape}</p>{/if}
        </div>
        {if !empty($ddStatusText)}<span class="status-pill {$ddStatusLower|escape}">{$ddStatusText|escape}</span>{/if}
    </div>
</header>

{if !empty($unpaidInvoice)}
<div class="dd-alert {if $unpaidInvoiceOverdue|default:false}dd-alert-error{else}dd-alert-warn{/if}">
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>
    <div>{$unpaidInvoiceMessage|default:'This domain has an unpaid invoice.'}</div>
    <a href="{$WEB_ROOT}/viewinvoice.php?id={$unpaidInvoice|escape}" class="btn-primary dd-alert-cta">{$LANG.payinvoice|default:'Pay invoice'}</a>
</div>
{/if}

{if !empty($registrarcustombuttonresult)}
    {if $registrarcustombuttonresult == 'success'}
        <div class="dd-alert dd-alert-success">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"/></svg>
            <div>{$LANG.moduleactionsuccess|default:'Action completed successfully.'}</div>
        </div>
    {else}
        <div class="dd-alert dd-alert-error">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/></svg>
            <div>{$LANG.moduleactionfailed|default:'Action failed.'}</div>
        </div>
    {/if}
{/if}

{if !empty($systemStatus) && $systemStatus != 'Active'}
<div class="dd-alert dd-alert-warn">
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/></svg>
    <div>{$LANG.domainCannotBeManagedUnlessActive|default:'This domain is not active and cannot be managed.'}</div>
</div>
{/if}

<div class="dd-split">
    <div class="dd-main">

        <div class="card" style="padding:0;">
            <div class="dd-tabs" role="tablist">
                <button type="button" class="dd-tab active" data-dd-tab="overview">{$LANG.overview|default:'Overview'}</button>
                <button type="button" class="dd-tab" data-dd-tab="autorenew">{$LANG.domainsautorenew|default:'Auto-renew'}</button>
                {if isset($managementoptions.nameservers) && $managementoptions.nameservers}<button type="button" class="dd-tab" data-dd-tab="nameservers">{$LANG.domainnameservers|default:'Nameservers'}</button>{/if}
                {if isset($managementoptions.locking) && $managementoptions.locking}<button type="button" class="dd-tab" data-dd-tab="reglock">{$LANG.domainregistrarlock|default:'Registrar Lock'}</button>{/if}
                {if !empty($addons.idprotection) || !empty($addons.dnsmanagement) || !empty($addons.emailforwarding)}<button type="button" class="dd-tab" data-dd-tab="addons">{$LANG.domainaddons|default:'Addons'}</button>{/if}
            </div>

            {* ============ OVERVIEW ============ *}
            <div class="dd-tab-panel active" data-dd-panel="overview">
                <div class="dd-info-grid">
                    {if !empty($domain)}
                    <div class="dd-info-row">
                        <span class="dd-info-label">{$LANG.clientareahostingdomain|default:'Domain'}</span>
                        <span class="dd-info-value"><a href="http://{$domain|escape}" target="_blank" rel="noopener" class="dd-link">{$domain|escape}</a></span>
                    </div>
                    {/if}
                    {if !empty($firstpaymentamount)}
                    <div class="dd-info-row">
                        <span class="dd-info-label">{$LANG.firstpaymentamount|default:'First payment'}</span>
                        <span class="dd-info-value">{$firstpaymentamount|escape}</span>
                    </div>
                    {/if}
                    {if !empty($registrationdate)}
                    <div class="dd-info-row">
                        <span class="dd-info-label">{$LANG.clientareahostingregdate|default:'Registration date'}</span>
                        <span class="dd-info-value">{$registrationdate|escape}</span>
                    </div>
                    {/if}
                    {if !empty($recurringamount)}
                    <div class="dd-info-row">
                        <span class="dd-info-label">{$LANG.recurringamount|default:'Recurring'}</span>
                        <span class="dd-info-value">{$recurringamount|escape}{if !empty($registrationperiod)} / {$registrationperiod|escape} {$LANG.orderyears|default:'yrs'}{/if}</span>
                    </div>
                    {/if}
                    {if !empty($nextduedate)}
                    <div class="dd-info-row">
                        <span class="dd-info-label">{$LANG.clientareahostingnextduedate|default:'Next due date'}</span>
                        <span class="dd-info-value">{$nextduedate|escape}</span>
                    </div>
                    {/if}
                    {if !empty($paymentmethod)}
                    <div class="dd-info-row">
                        <span class="dd-info-label">{$LANG.orderpaymentmethod|default:'Payment method'}</span>
                        <span class="dd-info-value">{$paymentmethod|escape}</span>
                    </div>
                    {/if}
                </div>

                {if !empty($sslStatus)}
                <div class="dd-ssl">
                    <div class="dd-ssl-row">
                        <span class="dd-info-label">{$LANG.sslState.sslStatus|default:'SSL status'}</span>
                        <span class="dd-info-value">{$sslStatus->getStatusDisplayLabel()|default:'—'|escape}</span>
                    </div>
                </div>
                {/if}

                {if !empty($registrarclientarea)}
                <div class="dd-module-output">
                    {$registrarclientarea|replace:'modulebutton':'btn-secondary'}
                </div>
                {/if}

                {if isset($hookOutput) && $hookOutput|@count > 0}
                    {foreach $hookOutput as $output}
                        <div class="dd-hook-output">{$output}</div>
                    {/foreach}
                {/if}

                {if !empty($managementoptions) && ($managementoptions.nameservers || $managementoptions.contacts || $managementoptions.locking || !empty($renew))}
                <div class="dd-quickactions">
                    <h3 class="dd-section-title">{$LANG.doToday|default:'Quick actions'}</h3>
                    <div class="dd-action-list">
                        {if $systemStatus == 'Active' && !empty($managementoptions.nameservers)}
                            <a href="#" class="dd-action" data-dd-jump="nameservers">
                                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="2" y1="12" x2="22" y2="12"/><path d="M12 2a15.3 15.3 0 0 1 4 10 15.3 15.3 0 0 1-4 10 15.3 15.3 0 0 1-4-10 15.3 15.3 0 0 1 4-10z"/></svg>
                                {$LANG.changeDomainNS|default:'Change nameservers'}
                            </a>
                        {/if}
                        {if $systemStatus == 'Active' && !empty($managementoptions.contacts)}
                            <a href="{$WEB_ROOT}/clientarea.php?action=domaincontacts&domainid={$domainid|escape}" class="dd-action">
                                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M20 21v-2a4 4 0 00-4-4H8a4 4 0 00-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>
                                {$LANG.updateWhoisContact|default:'Update WHOIS contact'}
                            </a>
                        {/if}
                        {if $systemStatus == 'Active' && !empty($managementoptions.locking)}
                            <a href="#" class="dd-action" data-dd-jump="reglock">
                                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="11" width="18" height="11" rx="2"/><path d="M7 11V7a5 5 0 0110 0v4"/></svg>
                                {$LANG.changeRegLock|default:'Change registrar lock'}
                            </a>
                        {/if}
                        {if !empty($renew)}
                            <a href="{$WEB_ROOT}/cart.php?gid=renewals" class="dd-action">
                                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><polyline points="23 4 23 10 17 10"/><polyline points="1 20 1 14 7 14"/><path d="M3.51 9a9 9 0 0114.85-3.36L23 10M1 14l4.64 4.36A9 9 0 0020.49 15"/></svg>
                                {$LANG.domainrenew|default:'Renew domain'}
                            </a>
                        {/if}
                    </div>
                </div>
                {/if}
            </div>

            {* ============ AUTO-RENEW ============ *}
            <div class="dd-tab-panel" data-dd-panel="autorenew">
                {if !empty($changeAutoRenewStatusSuccessful)}
                    <div class="dd-alert dd-alert-success">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"/></svg>
                        <div>{$LANG.changessavedsuccessfully|default:'Changes saved.'}</div>
                    </div>
                {/if}
                <p class="dd-section-text">{$LANG.domainrenewexp|default:'Auto-renew automatically renews this domain before it expires, helping you avoid losing it.'}</p>

                <div class="dd-status-row">
                    <span class="dd-info-label">{$LANG.domainautorenewstatus|default:'Auto-renew status'}</span>
                    <span class="dd-status-tag {if $autorenew}dd-tag-on{else}dd-tag-off{/if}">
                        {if $autorenew}{$LANG.domainsautorenewenabled|default:'Enabled'}{else}{$LANG.domainsautorenewdisabled|default:'Disabled'}{/if}
                    </span>
                </div>

                <form method="post" action="{$smarty.server.PHP_SELF}?action=domaindetails#tabAutorenew" class="dd-toggle-form">
                    <input type="hidden" name="token" value="{$token|default:''|escape}">
                    <input type="hidden" name="id" value="{$domainid|escape}">
                    <input type="hidden" name="sub" value="autorenew">
                    {if $autorenew}
                        <input type="hidden" name="autorenew" value="disable">
                        <button type="submit" class="btn-secondary dd-danger-btn">{$LANG.domainsautorenewdisable|default:'Disable auto-renew'}</button>
                    {else}
                        <input type="hidden" name="autorenew" value="enable">
                        <button type="submit" class="btn-primary">{$LANG.domainsautorenewenable|default:'Enable auto-renew'}</button>
                    {/if}
                </form>
            </div>

            {* ============ NAMESERVERS ============ *}
            {if isset($managementoptions.nameservers) && $managementoptions.nameservers}
            <div class="dd-tab-panel" data-dd-panel="nameservers">
                {if !empty($nameservererror)}
                    <div class="dd-alert dd-alert-error">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/></svg>
                        <div>{$nameservererror|escape}</div>
                    </div>
                {/if}
                {if $subaction|default:'' eq 'savens'}
                    {if !empty($updatesuccess)}
                        <div class="dd-alert dd-alert-success">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"/></svg>
                            <div>{$LANG.changessavedsuccessfully|default:'Changes saved.'}</div>
                        </div>
                    {elseif !empty($error)}
                        <div class="dd-alert dd-alert-error">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/></svg>
                            <div>{$error|escape}</div>
                        </div>
                    {/if}
                {/if}

                <p class="dd-section-text">{$LANG.domainnsexp|default:'Choose between your registrar\'s default nameservers, or specify your own.'}</p>

                <form method="post" action="{$smarty.server.PHP_SELF}?action=domaindetails#tabNameservers" class="dd-form">
                    <input type="hidden" name="token" value="{$token|default:''|escape}">
                    <input type="hidden" name="id" value="{$domainid|escape}">
                    <input type="hidden" name="sub" value="savens">

                    <label class="dd-radio">
                        <input type="radio" name="nschoice" value="default"{if $defaultns} checked{/if}>
                        <span>{$LANG.nschoicedefault|default:'Use registrar defaults'}</span>
                    </label>
                    <label class="dd-radio">
                        <input type="radio" name="nschoice" value="custom"{if !$defaultns} checked{/if}>
                        <span>{$LANG.nschoicecustom|default:'Use custom nameservers'}</span>
                    </label>

                    <div class="dd-ns-grid">
                        {for $num=1 to 5}
                            <div class="dd-ns-row">
                                <label for="inputNs{$num}" class="dd-ns-label">{$LANG.clientareanameserver|default:'Nameserver'} {$num}</label>
                                <input type="text" name="ns{$num}" class="dd-input" id="inputNs{$num}" value="{$nameservers[$num].value|default:''|escape}" placeholder="ns{$num}.example.com">
                            </div>
                        {/for}
                    </div>

                    <div class="dd-form-actions">
                        <button type="submit" class="btn-primary">{$LANG.changenameservers|default:'Save changes'}</button>
                    </div>
                </form>
            </div>
            {/if}

            {* ============ REGISTRAR LOCK ============ *}
            {if isset($managementoptions.locking) && $managementoptions.locking}
            <div class="dd-tab-panel" data-dd-panel="reglock">
                {if $subaction|default:'' eq 'savereglock'}
                    {if !empty($updatesuccess)}
                        <div class="dd-alert dd-alert-success">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"/></svg>
                            <div>{$LANG.changessavedsuccessfully|default:'Changes saved.'}</div>
                        </div>
                    {elseif !empty($error)}
                        <div class="dd-alert dd-alert-error">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/></svg>
                            <div>{$error|escape}</div>
                        </div>
                    {/if}
                {/if}

                <p class="dd-section-text">{$LANG.domainlockingexp|default:'Registrar Lock prevents unauthorized transfer of your domain to another registrar.'}</p>

                <div class="dd-status-row">
                    <span class="dd-info-label">{$LANG.domainreglockstatus|default:'Registrar Lock'}</span>
                    <span class="dd-status-tag {if $lockstatus == 'locked'}dd-tag-on{else}dd-tag-off{/if}">
                        {if $lockstatus == 'locked'}{$LANG.locked|default:'Locked'}{else}{$LANG.unlocked|default:'Unlocked'}{/if}
                    </span>
                </div>

                <form method="post" action="{$smarty.server.PHP_SELF}?action=domaindetails#tabReglock" class="dd-toggle-form">
                    <input type="hidden" name="token" value="{$token|default:''|escape}">
                    <input type="hidden" name="id" value="{$domainid|escape}">
                    <input type="hidden" name="sub" value="savereglock">
                    {if $lockstatus == 'locked'}
                        <button type="submit" class="btn-secondary dd-danger-btn">{$LANG.domainreglockdisable|default:'Disable lock'}</button>
                    {else}
                        <button type="submit" name="reglock" value="1" class="btn-primary">{$LANG.domainreglockenable|default:'Enable lock'}</button>
                    {/if}
                </form>
            </div>
            {/if}

            {* ============ ADDONS ============ *}
            {if !empty($addons.idprotection) || !empty($addons.dnsmanagement) || !empty($addons.emailforwarding)}
            <div class="dd-tab-panel" data-dd-panel="addons">
                <p class="dd-section-text">{$LANG.domainaddonsinfo|default:'Enable additional services to enhance your domain.'}</p>

                <div class="dd-addon-list">
                    {if !empty($addons.idprotection)}
                    <div class="dd-addon">
                        <div class="dd-addon-icon">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/></svg>
                        </div>
                        <div class="dd-addon-body">
                            <h4 class="dd-addon-name">{$LANG.domainidprotection|default:'ID Protection'}</h4>
                            <p class="dd-addon-desc">{$LANG.domainaddonsidprotectioninfo|default:'Hide your contact details from public WHOIS lookups.'}</p>
                        </div>
                        <div class="dd-addon-action">
                            <form action="{$WEB_ROOT}/clientarea.php?action=domainaddons" method="post">
                                <input type="hidden" name="token" value="{$token|default:''|escape}">
                                <input type="hidden" name="id" value="{$domainid|escape}">
                                {if !empty($addonstatus.idprotection)}
                                    <input type="hidden" name="disable" value="idprotect">
                                    <span class="dd-addon-tag dd-tag-on">{$LANG.enabled|default:'Enabled'}</span>
                                    <button type="submit" class="btn-secondary dd-addon-btn">{$LANG.disable|default:'Disable'}</button>
                                {else}
                                    <input type="hidden" name="buy" value="idprotect">
                                    <button type="submit" class="btn-primary dd-addon-btn">{$LANG.domainaddonsbuynow|default:'Add'} {$addonspricing.idprotection|default:''|escape}</button>
                                {/if}
                            </form>
                        </div>
                    </div>
                    {/if}

                    {if !empty($addons.dnsmanagement)}
                    <div class="dd-addon">
                        <div class="dd-addon-icon">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M18 10h-1.26A8 8 0 109 20h9a5 5 0 000-10z"/></svg>
                        </div>
                        <div class="dd-addon-body">
                            <h4 class="dd-addon-name">{$LANG.domainaddonsdnsmanagement|default:'DNS Management'}</h4>
                            <p class="dd-addon-desc">{$LANG.domainaddonsdnsmanagementinfo|default:'Edit DNS records (A, MX, CNAME, TXT) directly from your client area.'}</p>
                        </div>
                        <div class="dd-addon-action">
                            <form action="{$WEB_ROOT}/clientarea.php?action=domainaddons" method="post">
                                <input type="hidden" name="token" value="{$token|default:''|escape}">
                                <input type="hidden" name="id" value="{$domainid|escape}">
                                {if !empty($addonstatus.dnsmanagement)}
                                    <input type="hidden" name="disable" value="dnsmanagement">
                                    <a class="btn-primary dd-addon-btn" href="{$WEB_ROOT}/clientarea.php?action=domaindns&domainid={$domainid|escape}">{$LANG.manage|default:'Manage'}</a>
                                    <button type="submit" class="btn-secondary dd-addon-btn">{$LANG.disable|default:'Disable'}</button>
                                {else}
                                    <input type="hidden" name="buy" value="dnsmanagement">
                                    <button type="submit" class="btn-primary dd-addon-btn">{$LANG.domainaddonsbuynow|default:'Add'} {$addonspricing.dnsmanagement|default:''|escape}</button>
                                {/if}
                            </form>
                        </div>
                    </div>
                    {/if}

                    {if !empty($addons.emailforwarding)}
                    <div class="dd-addon">
                        <div class="dd-addon-icon">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z"/><polyline points="22,6 12,13 2,6"/></svg>
                        </div>
                        <div class="dd-addon-body">
                            <h4 class="dd-addon-name">{$LANG.domainemailforwarding|default:'Email Forwarding'}</h4>
                            <p class="dd-addon-desc">{$LANG.domainaddonsemailforwardinginfo|default:'Forward incoming mail from your domain to any address.'}</p>
                        </div>
                        <div class="dd-addon-action">
                            <form action="{$WEB_ROOT}/clientarea.php?action=domainaddons" method="post">
                                <input type="hidden" name="token" value="{$token|default:''|escape}">
                                <input type="hidden" name="id" value="{$domainid|escape}">
                                {if !empty($addonstatus.emailforwarding)}
                                    <input type="hidden" name="disable" value="emailfwd">
                                    <a class="btn-primary dd-addon-btn" href="{$WEB_ROOT}/clientarea.php?action=domainemailforwarding&domainid={$domainid|escape}">{$LANG.manage|default:'Manage'}</a>
                                    <button type="submit" class="btn-secondary dd-addon-btn">{$LANG.disable|default:'Disable'}</button>
                                {else}
                                    <input type="hidden" name="buy" value="emailfwd">
                                    <button type="submit" class="btn-primary dd-addon-btn">{$LANG.domainaddonsbuynow|default:'Add'} {$addonspricing.emailforwarding|default:''|escape}</button>
                                {/if}
                            </form>
                        </div>
                    </div>
                    {/if}
                </div>
            </div>
            {/if}

        </div>
    </div>

    <aside class="dd-aside">
        <div class="card subnav-card">
            <div class="subnav-heading">{$LANG.domain|default:'Domain'}</div>
            <a href="{$WEB_ROOT}/clientarea.php?action=domains" class="subnav-item">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><polyline points="15 18 9 12 15 6"/></svg>
                {$LANG.alldomains|default:'All domains'}
            </a>
            {if isset($managementoptions.dnsmanagement) && $managementoptions.dnsmanagement && !empty($addonstatus.dnsmanagement)}
            <a href="{$WEB_ROOT}/clientarea.php?action=domaindns&domainid={$domainid|escape}" class="subnav-item">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="2" y1="12" x2="22" y2="12"/></svg>
                {$LANG.dnsmanagement|default:'DNS records'}
            </a>
            {/if}
            {if isset($managementoptions.emailforwarding) && $managementoptions.emailforwarding && !empty($addonstatus.emailforwarding)}
            <a href="{$WEB_ROOT}/clientarea.php?action=domainemailforwarding&domainid={$domainid|escape}" class="subnav-item">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z"/><polyline points="22,6 12,13 2,6"/></svg>
                {$LANG.emailforwarding|default:'Email forwarders'}
            </a>
            {/if}
            {if isset($managementoptions.registerns) && $managementoptions.registerns}
            <a href="{$WEB_ROOT}/clientarea.php?action=registerns&id={$domainid|escape}" class="subnav-item">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M12 2L2 7l10 5 10-5-10-5z"/><polyline points="2 17 12 22 22 17"/><polyline points="2 12 12 17 22 12"/></svg>
                {$LANG.privatenameservers|default:'Glue records'}
            </a>
            {/if}
            {if isset($managementoptions.epp) && $managementoptions.epp}
            <a href="{$WEB_ROOT}/clientarea.php?action=getepp&id={$domainid|escape}" class="subnav-item">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="11" width="18" height="11" rx="2"/><path d="M7 11V7a5 5 0 0110 0v4"/></svg>
                {$LANG.eppcode|default:'EPP code'}
            </a>
            {/if}
            {if isset($managementoptions.contacts) && $managementoptions.contacts}
            <a href="{$WEB_ROOT}/clientarea.php?action=domaincontacts&domainid={$domainid|escape}" class="subnav-item">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M20 21v-2a4 4 0 00-4-4H8a4 4 0 00-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>
                {$LANG.whoismodify|default:'WHOIS contact'}
            </a>
            {/if}
        </div>
    </aside>
</div>

<script>{literal}
(function(){
    var tabs = document.querySelectorAll('[data-dd-tab]');
    var panels = document.querySelectorAll('[data-dd-panel]');
    function go(name){
        tabs.forEach(function(t){ t.classList.toggle('active', t.getAttribute('data-dd-tab') === name); });
        panels.forEach(function(p){ p.classList.toggle('active', p.getAttribute('data-dd-panel') === name); });
    }
    tabs.forEach(function(t){
        t.addEventListener('click', function(){ go(t.getAttribute('data-dd-tab')); });
    });
    document.querySelectorAll('[data-dd-jump]').forEach(function(a){
        a.addEventListener('click', function(e){ e.preventDefault(); go(a.getAttribute('data-dd-jump')); window.scrollTo({top:0,behavior:'smooth'}); });
    });
    // Open hash-targeted tab on load (e.g. #tabNameservers)
    var h = (location.hash || '').toLowerCase();
    if (h.indexOf('tabname') === 0) go('nameservers');
    else if (h.indexOf('tabreglock') === 0) go('reglock');
    else if (h.indexOf('tabauto')   === 0) go('autorenew');
    else if (h.indexOf('tabaddons') === 0) go('addons');
})();
{/literal}</script>
