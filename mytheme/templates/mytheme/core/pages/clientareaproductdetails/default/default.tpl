{* Hostnodes — Service Details (Apple-style).

   WHMCS standard variables on /clientarea.php?action=productdetails&id=X:
     $service           — service object (id, productname, groupname, domain,
                          status, statusClass, billingcycle, registrationdate,
                          nextduedate, firstpaymentamount, recurringamount,
                          paymentmethod, dedicatedip, assignedips, ns1, ns2,
                          serverhostname, serverip, diskusage, disklimit,
                          bwusage, bwlimit, suspendreason, ...)
     $product           — alternative name for the same object
     $clientsdetails    — client info
     $upgradesAvailable — bool, upgrade options exist
     $cancellationrequested — bool
     $loginbutton       — control panel login URL
*}

{assign var=svc value=$service|default:$product}
{assign var=svcStatus value=$svc.status|default:''}
{assign var=svcStatusClass value=$svc.statusClass|default:$svc.statusClass|default:$svcStatus|lower}

<link rel="stylesheet" href="{$WEB_ROOT}/templates/{$template}/assets/css/pages/clientareaproductdetails.css?v={$myTheme.version|default:'1.0'}">

<header class="page-header">
    <div class="page-header-row">
        <div style="flex:1; min-width:0;">
            <p class="page-eyebrow">{$svc.groupname|default:''|escape}</p>
            <h1>{$svc.productname|default:$svc.name|escape}</h1>
            {if !empty($svc.domain)}<p class="page-subtitle">{$svc.domain|escape}</p>{/if}
        </div>
        <span class="status-pill {$svcStatusClass|escape}">{$svcStatus|strip_tags|escape}</span>
    </div>
</header>

<div class="pd-split">
    <div class="pd-main">

        {* Tab nav *}
        <div class="card" style="padding:0;">
            <div class="pd-tabs" role="tablist">
                <button type="button" class="pd-tab active" data-pd-tab="overview">{$LANG.overview|default:'Overview'}</button>
                {if !empty($svc.username)}<button type="button" class="pd-tab" data-pd-tab="login">{$LANG.loginsection|default:'Login info'}</button>{/if}
                {if !empty($upgradesAvailable)}<button type="button" class="pd-tab" data-pd-tab="upgrade">{$LANG.upgrade|default:'Upgrade'}</button>{/if}
                {if !$cancellationrequested}<button type="button" class="pd-tab" data-pd-tab="cancel">{$LANG.requestcancellation|default:'Cancel service'}</button>{/if}
            </div>

            <div class="pd-tab-panel active" data-pd-panel="overview">
                <div class="pd-info-grid">
                    <div class="pd-info-row">
                        <span class="pd-info-label">{$LANG.firstpaymentamount|default:'First payment'}</span>
                        <span class="pd-info-value">{$svc.firstpaymentamount|default:''|escape}</span>
                    </div>
                    <div class="pd-info-row">
                        <span class="pd-info-label">{$LANG.recurringamount|default:'Recurring'}</span>
                        <span class="pd-info-value">{$svc.recurringamount|default:''|escape} / {$svc.billingcycle|default:''|escape}</span>
                    </div>
                    <div class="pd-info-row">
                        <span class="pd-info-label">{$LANG.registrationdate|default:'Registration date'}</span>
                        <span class="pd-info-value">{$svc.regdate|default:$svc.registrationdate|default:''|escape}</span>
                    </div>
                    <div class="pd-info-row">
                        <span class="pd-info-label">{$LANG.invoicedatedue|default:'Next due date'}</span>
                        <span class="pd-info-value">{$svc.nextduedate|default:''|escape}</span>
                    </div>
                    {if !empty($svc.paymentmethodname)}
                    <div class="pd-info-row">
                        <span class="pd-info-label">{$LANG.paymentmethod|default:'Payment method'}</span>
                        <span class="pd-info-value">{$svc.paymentmethodname|escape}</span>
                    </div>
                    {/if}
                    {if !empty($svc.dedicatedip)}
                    <div class="pd-info-row">
                        <span class="pd-info-label">{$LANG.dedicatedip|default:'Dedicated IP'}</span>
                        <span class="pd-info-value pd-mono">{$svc.dedicatedip|escape}</span>
                    </div>
                    {/if}
                    {if !empty($svc.serverhostname)}
                    <div class="pd-info-row">
                        <span class="pd-info-label">{$LANG.serverhostname|default:'Server hostname'}</span>
                        <span class="pd-info-value pd-mono">{$svc.serverhostname|escape}</span>
                    </div>
                    {/if}
                    {if !empty($svc.ns1) || !empty($svc.ns2)}
                    <div class="pd-info-row">
                        <span class="pd-info-label">{$LANG.nameservers|default:'Nameservers'}</span>
                        <span class="pd-info-value pd-mono">{$svc.ns1|default:''|escape}{if !empty($svc.ns2)}<br>{$svc.ns2|escape}{/if}</span>
                    </div>
                    {/if}
                </div>

                {if isset($svc.diskusage) && isset($svc.disklimit) && $svc.disklimit}
                <div class="pd-usage">
                    <h3 class="pd-usage-title">{$LANG.usagestats|default:'Usage'}</h3>
                    <div class="pd-meter">
                        <div class="pd-meter-label">{$LANG.diskspace|default:'Disk space'}: {$svc.diskusage|escape} / {$svc.disklimit|escape}</div>
                        <div class="pd-meter-bar"><div class="pd-meter-fill" style="width:{if $svc.disklimit > 0}{math equation="(usage / limit) * 100" usage=$svc.diskusage limit=$svc.disklimit}{else}0{/if}%"></div></div>
                    </div>
                    {if isset($svc.bwusage) && isset($svc.bwlimit) && $svc.bwlimit}
                    <div class="pd-meter">
                        <div class="pd-meter-label">{$LANG.bandwidth|default:'Bandwidth'}: {$svc.bwusage|escape} / {$svc.bwlimit|escape}</div>
                        <div class="pd-meter-bar"><div class="pd-meter-fill" style="width:{if $svc.bwlimit > 0}{math equation="(usage / limit) * 100" usage=$svc.bwusage limit=$svc.bwlimit}{else}0{/if}%"></div></div>
                    </div>
                    {/if}
                </div>
                {/if}
            </div>

            {if !empty($svc.username)}
            <div class="pd-tab-panel" data-pd-panel="login">
                <div class="pd-credential-row">
                    <span class="pd-cred-label">{$LANG.username|default:'Username'}</span>
                    <span class="pd-cred-value pd-mono">{$svc.username|escape}</span>
                </div>
                {if !empty($svc.password)}
                <div class="pd-credential-row">
                    <span class="pd-cred-label">{$LANG.password|default:'Password'}</span>
                    <span class="pd-cred-value pd-mono" data-pd-secret>••••••••</span>
                    <button type="button" class="pd-cred-toggle" data-pd-reveal="{$svc.password|escape}">{$LANG.show|default:'Show'}</button>
                </div>
                {/if}
                {if !empty($loginbutton) || !empty($svc.loginurl)}
                <a href="{$loginbutton|default:$svc.loginurl|default:'#'|escape}" target="_blank" class="btn-primary pd-login-btn">
                    {$LANG.cpanellogin|default:'Login to control panel'}
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M18 13v6a2 2 0 01-2 2H5a2 2 0 01-2-2V8a2 2 0 012-2h6"/><polyline points="15 3 21 3 21 9"/><line x1="10" y1="14" x2="21" y2="3"/></svg>
                </a>
                {/if}
            </div>
            {/if}

            {if !empty($upgradesAvailable)}
            <div class="pd-tab-panel" data-pd-panel="upgrade">
                <p class="pd-section-text">{$LANG.upgradeavailable|default:'You can upgrade or downgrade this service to a different plan.'}</p>
                <a href="{$WEB_ROOT}/upgrade.php?type=package&id={$svc.id|escape}" class="btn-primary">{$LANG.viewupgradeoptions|default:'View upgrade options'}</a>
            </div>
            {/if}

            {if !$cancellationrequested}
            <div class="pd-tab-panel" data-pd-panel="cancel">
                <p class="pd-section-text">{$LANG.cancellationsub|default:'Request immediate or end-of-billing-cycle cancellation. This action is reviewed by our team before being processed.'}</p>
                <a href="{$WEB_ROOT}/clientarea.php?action=cancel&id={$svc.id|escape}" class="btn-secondary pd-cancel-btn">{$LANG.requestcancellation|default:'Request cancellation'}</a>
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
            {if !empty($svc.id)}
            <a href="{$WEB_ROOT}/clientarea.php?action=productdetails&id={$svc.id|escape}&modop=custom&a=Renew" class="subnav-item">
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
