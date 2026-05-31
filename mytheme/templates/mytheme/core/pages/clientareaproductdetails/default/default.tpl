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
    {if !empty($serverhostname)}
    <div class="settings-item"><div class="settings-item-content"><div class="settings-item-label">{$LANG.serverhostname|default:'Server'}</div></div><div class="settings-item-action"><span class="settings-item-value" style="font-family:var(--font-mono);font-size:13px;">{$serverhostname|escape}</span></div></div>
    {/if}
    {if !empty($dedicatedip)}
    <div class="settings-item"><div class="settings-item-content"><div class="settings-item-label">{$LANG.dedicatedip|default:'IP address'}</div></div><div class="settings-item-action"><span class="settings-item-value" style="font-family:var(--font-mono);font-size:13px;">{$dedicatedip|escape}</span></div></div>
    {/if}
    {if !empty($ns1) || !empty($ns2)}
    <div class="settings-item"><div class="settings-item-content"><div class="settings-item-label">{$LANG.nameservers|default:'Nameservers'}</div></div><div class="settings-item-action"><span class="settings-item-value" style="font-size:13px;">{$ns1|default:''|escape}{if !empty($ns2)}<br>{$ns2|escape}{/if}</span></div></div>
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

{* ── Resource usage ────────────────────────────────────────────────── *}
{if !empty($disklimit) && !empty($diskusage)}
<div class="card">
    <div class="card-header"><h2 class="card-title">{$LANG.usagestats|default:'Resource Usage'}</h2></div>
    <div class="card-body">
        <div class="usage-bar-container">
            <div class="usage-bar-header"><span class="usage-bar-label">{$LANG.diskspace|default:'Disk space'}</span><span class="usage-bar-value">{$diskusage|escape} / {$disklimit|escape}</span></div>
            <div class="usage-bar"><div class="usage-bar-fill blue" style="width:50%;"></div></div>
        </div>
        {if !empty($bwlimit) && !empty($bwusage)}
        <div class="usage-bar-container">
            <div class="usage-bar-header"><span class="usage-bar-label">{$LANG.bandwidth|default:'Bandwidth'}</span><span class="usage-bar-value">{$bwusage|escape} / {$bwlimit|escape}</span></div>
            <div class="usage-bar"><div class="usage-bar-fill green" style="width:50%;"></div></div>
        </div>
        {/if}
    </div>
</div>
{/if}

{* ── Login / control panel info ────────────────────────────────────── *}
{if !empty($username)}
<div class="settings-group">
    <div class="settings-group-header"><div class="settings-group-title">{$LANG.loginsection|default:'Login info'}</div></div>
    <div class="settings-item"><div class="settings-item-content"><div class="settings-item-label">{$LANG.username|default:'Username'}</div></div><div class="settings-item-action"><span class="settings-item-value" style="font-family:var(--font-mono);font-size:13px;">{$username|escape}</span></div></div>
    {if !empty($password)}
    <div class="settings-item"><div class="settings-item-content"><div class="settings-item-label">{$LANG.password|default:'Password'}</div></div><div class="settings-item-action"><span class="settings-item-value pd-mono" data-pd-secret>&bull;&bull;&bull;&bull;&bull;&bull;&bull;&bull;</span><button type="button" class="btn-secondary pd-cred-toggle" data-pd-reveal="{$password|escape}" style="margin-left:10px;height:28px;padding:0 12px;font-size:12px;">{$LANG.show|default:'Show'}</button></div></div>
    {/if}
    {if !empty($loginButton)}
    <div class="settings-item"><div class="settings-item-content"><div class="settings-item-label">{$LANG.login|default:'Control panel'}</div></div><div class="settings-item-action">{$loginButton}</div></div>
    {/if}
</div>
{/if}

{* ── Quick actions ─────────────────────────────────────────────────── *}
<div class="settings-group">
    <div class="settings-group-header"><div class="settings-group-title">{$LANG.actions|default:'Quick Actions'}</div></div>
    <a href="{$WEB_ROOT}/clientarea.php?action=services" class="settings-item" style="text-decoration:none;color:inherit;">
        <div class="settings-item-content"><div class="settings-item-label">{$LANG.backtoservices|default:'Back to services'}</div></div>
        <div class="settings-item-action"><span class="settings-item-chevron"><svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="9 18 15 12 9 6"/></svg></span></div>
    </a>
    {if !empty($id)}
    <a href="{$WEB_ROOT}/clientarea.php?action=productdetails&id={$id|escape}&modop=custom&a=Renew" class="settings-item" style="text-decoration:none;color:inherit;">
        <div class="settings-item-content"><div class="settings-item-label">{$LANG.renew|default:'Renew now'}</div></div>
        <div class="settings-item-action"><span class="settings-item-chevron"><svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="9 18 15 12 9 6"/></svg></span></div>
    </a>
    {/if}
    {if isset($upgrades) && $upgrades|@count > 0}
    <a href="{$WEB_ROOT}/upgrade.php?type=package&id={$id|default:0|escape}" class="settings-item" style="text-decoration:none;color:inherit;">
        <div class="settings-item-content"><div class="settings-item-label">{$LANG.upgrade|default:'Upgrade / Downgrade'}</div><div class="settings-item-sublabel">{$LANG.upgradeavailable|default:'Change your hosting plan'}</div></div>
        <div class="settings-item-action"><span class="settings-item-chevron"><svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="9 18 15 12 9 6"/></svg></span></div>
    </a>
    {/if}
</div>

{* ── Cancel service ────────────────────────────────────────────────── *}
{if (!isset($pendingcancellation) || !$pendingcancellation) && $svcStatusLower == 'active'}
<div style="margin-top:24px;">
    <a href="{$WEB_ROOT}/clientarea.php?action=cancel&id={$id|default:0|escape}" class="btn-danger">{$LANG.requestcancellation|default:'Request cancellation'}</a>
</div>
{/if}

<script>
{literal}
document.addEventListener('DOMContentLoaded', function () {
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
