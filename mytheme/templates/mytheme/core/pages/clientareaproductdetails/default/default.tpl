{* Hostnodes — Service Details (Apple-style).

   WHMCS exposes the service variables as TOP-LEVEL (not as a $service or
   $product object). Verified against Nexus and Lagom — these are the
   canonical names; do NOT nest them or assume an object wrapper:

     $product, $groupname, $domain, $type     — name + grouping
     $status, $rawstatus                       — display + lowercased
     $regdate, $nextduedate                    — formatted dates
     $firstpaymentamount, $recurringamount    — money strings
     $billingcycle, $paymentmethodname        — billing meta
     $dedicatedip, $assignedips                — IP info
     $ns1, $ns2                                — nameservers
     $serverhostname, $serverip                — server info
     $diskusage, $disklimit, $bwusage, $bwlimit — usage stats
     $username, $password                      — control panel creds
     $loginButton                              — pre-rendered login URL
     $pendingcancellation                      — bool, cancellation pending
     $upgrades                                 — array of available upgrade IDs
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

<div class="pd-split">
    <div class="pd-main">

        <div class="card" style="padding:0;">
            <div class="pd-tabs" role="tablist">
                <button type="button" class="pd-tab active" data-pd-tab="overview">{$LANG.overview|default:'Overview'}</button>
                {if !empty($username)}<button type="button" class="pd-tab" data-pd-tab="login">{$LANG.loginsection|default:'Login info'}</button>{/if}
                {if isset($upgrades) && $upgrades|@count > 0}<button type="button" class="pd-tab" data-pd-tab="upgrade">{$LANG.upgrade|default:'Upgrade'}</button>{/if}
                {if (!isset($pendingcancellation) || !$pendingcancellation) && $svcStatusLower == 'active'}<button type="button" class="pd-tab" data-pd-tab="cancel">{$LANG.requestcancellation|default:'Cancel service'}</button>{/if}
            </div>

            <div class="pd-tab-panel active" data-pd-panel="overview">
                <div class="pd-info-grid">
                    {if !empty($firstpaymentamount)}
                    <div class="pd-info-row">
                        <span class="pd-info-label">{$LANG.firstpaymentamount|default:'First payment'}</span>
                        <span class="pd-info-value">{$firstpaymentamount|escape}</span>
                    </div>
                    {/if}
                    {if !empty($recurringamount)}
                    <div class="pd-info-row">
                        <span class="pd-info-label">{$LANG.recurringamount|default:'Recurring'}</span>
                        <span class="pd-info-value">{$recurringamount|escape}{if !empty($billingcycle)} / {$billingcycle|escape}{/if}</span>
                    </div>
                    {/if}
                    {if !empty($regdate)}
                    <div class="pd-info-row">
                        <span class="pd-info-label">{$LANG.registrationdate|default:'Registration date'}</span>
                        <span class="pd-info-value">{$regdate|escape}</span>
                    </div>
                    {/if}
                    {if !empty($nextduedate)}
                    <div class="pd-info-row">
                        <span class="pd-info-label">{$LANG.invoicedatedue|default:'Next due date'}</span>
                        <span class="pd-info-value">{$nextduedate|escape}</span>
                    </div>
                    {/if}
                    {if !empty($paymentmethodname)}
                    <div class="pd-info-row">
                        <span class="pd-info-label">{$LANG.paymentmethod|default:'Payment method'}</span>
                        <span class="pd-info-value">{$paymentmethodname|escape}</span>
                    </div>
                    {/if}
                    {if !empty($dedicatedip)}
                    <div class="pd-info-row">
                        <span class="pd-info-label">{$LANG.dedicatedip|default:'Dedicated IP'}</span>
                        <span class="pd-info-value pd-mono">{$dedicatedip|escape}</span>
                    </div>
                    {/if}
                    {if !empty($serverhostname)}
                    <div class="pd-info-row">
                        <span class="pd-info-label">{$LANG.serverhostname|default:'Server hostname'}</span>
                        <span class="pd-info-value pd-mono">{$serverhostname|escape}</span>
                    </div>
                    {/if}
                    {if !empty($ns1) || !empty($ns2)}
                    <div class="pd-info-row">
                        <span class="pd-info-label">{$LANG.nameservers|default:'Nameservers'}</span>
                        <span class="pd-info-value pd-mono">{$ns1|default:''|escape}{if !empty($ns2)}<br>{$ns2|escape}{/if}</span>
                    </div>
                    {/if}
                </div>

                {if !empty($disklimit) && !empty($diskusage)}
                <div class="pd-usage">
                    <h3 class="pd-usage-title">{$LANG.usagestats|default:'Usage'}</h3>
                    <div class="pd-meter">
                        <div class="pd-meter-label">{$LANG.diskspace|default:'Disk space'}: {$diskusage|escape} / {$disklimit|escape}</div>
                        <div class="pd-meter-bar"><div class="pd-meter-fill" style="width:50%"></div></div>
                    </div>
                    {if !empty($bwlimit) && !empty($bwusage)}
                    <div class="pd-meter">
                        <div class="pd-meter-label">{$LANG.bandwidth|default:'Bandwidth'}: {$bwusage|escape} / {$bwlimit|escape}</div>
                        <div class="pd-meter-bar"><div class="pd-meter-fill" style="width:50%"></div></div>
                    </div>
                    {/if}
                </div>
                {/if}
            </div>

            {if !empty($username)}
            <div class="pd-tab-panel" data-pd-panel="login">
                <div class="pd-credential-row">
                    <span class="pd-cred-label">{$LANG.username|default:'Username'}</span>
                    <span class="pd-cred-value pd-mono">{$username|escape}</span>
                </div>
                {if !empty($password)}
                <div class="pd-credential-row">
                    <span class="pd-cred-label">{$LANG.password|default:'Password'}</span>
                    <span class="pd-cred-value pd-mono" data-pd-secret>••••••••</span>
                    <button type="button" class="pd-cred-toggle" data-pd-reveal="{$password|escape}">{$LANG.show|default:'Show'}</button>
                </div>
                {/if}
                {if !empty($loginButton)}
                <div class="pd-login-row">{$loginButton}</div>
                {/if}
            </div>
            {/if}

            {if isset($upgrades) && $upgrades|@count > 0}
            <div class="pd-tab-panel" data-pd-panel="upgrade">
                <p class="pd-section-text">{$LANG.upgradeavailable|default:'You can upgrade or downgrade this service to a different plan.'}</p>
                <a href="{$WEB_ROOT}/upgrade.php?type=package&id={$id|default:0|escape}" class="btn-primary">{$LANG.viewupgradeoptions|default:'View upgrade options'}</a>
            </div>
            {/if}

            {if (!isset($pendingcancellation) || !$pendingcancellation) && $svcStatusLower == 'active'}
            <div class="pd-tab-panel" data-pd-panel="cancel">
                <p class="pd-section-text">{$LANG.cancellationsub|default:'Request immediate or end-of-billing-cycle cancellation. This action is reviewed by our team before being processed.'}</p>
                <a href="{$WEB_ROOT}/clientarea.php?action=cancel&id={$id|default:0|escape}" class="btn-secondary pd-cancel-btn">{$LANG.requestcancellation|default:'Request cancellation'}</a>
            </div>
            {/if}
        </div>
    </div>

    <aside class="pd-aside">
        <div class="card subnav-card">
            <div class="subnav-heading">{$LANG.actions|default:'Actions'}</div>
            <a href="{$WEB_ROOT}/clientarea.php?action=services" class="subnav-item">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><polyline points="15 18 9 12 15 6"/></svg>
                {$LANG.backtoservices|default:'Back to services'}
            </a>
            {if !empty($id)}
            <a href="{$WEB_ROOT}/clientarea.php?action=productdetails&id={$id|escape}&modop=custom&a=Renew" class="subnav-item">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><polyline points="23 4 23 10 17 10"/><polyline points="1 20 1 14 7 14"/><path d="M3.51 9a9 9 0 0114.85-3.36L23 10M1 14l4.64 4.36A9 9 0 0020.49 15"/></svg>
                {$LANG.renew|default:'Renew now'}
            </a>
            {/if}
        </div>
    </aside>
</div>

<script>
{literal}
document.addEventListener('DOMContentLoaded', function () {
    document.querySelectorAll('.pd-tab').forEach(function (btn) {
        btn.addEventListener('click', function () {
            var target = btn.getAttribute('data-pd-tab');
            document.querySelectorAll('.pd-tab').forEach(function (t) { t.classList.toggle('active', t === btn); });
            document.querySelectorAll('.pd-tab-panel').forEach(function (p) {
                p.classList.toggle('active', p.getAttribute('data-pd-panel') === target);
            });
        });
    });
    document.querySelectorAll('.pd-cred-toggle').forEach(function (btn) {
        var secret = btn.getAttribute('data-pd-reveal');
        btn.addEventListener('click', function () {
            var span = btn.parentElement.querySelector('[data-pd-secret]');
            if (!span) return;
            var hidden = span.textContent.indexOf('•') !== -1;
            span.textContent = hidden ? secret : '••••••••';
            btn.textContent = hidden ? 'Hide' : 'Show';
        });
    });
});
{/literal}
</script>
