{* Hostnodes — Get EPP / Transfer Code (Apple-style).

   WHMCS variables:
     $domain, $domainid
     $eppcode (string when returned inline)
     $error (string when failed)
     (otherwise: code was emailed to the registered contact)
*}

<link rel="stylesheet" href="{$WEB_ROOT}/templates/{$template}/assets/css/pages/clientareadomaingetepp.css?v={$myTheme.version|default:'1.0'}">

<header class="page-header">
    <p class="page-eyebrow">{$domain|default:''|escape}</p>
    <h1>{$LANG.domaingeteppcode|default:'Transfer code (EPP)'}</h1>
    <p class="page-subtitle">{$LANG.domaingeteppcodeexplanation|default:'The EPP/auth code is required to transfer this domain to another registrar.'}</p>
</header>

<div class="epp-split">
    <div class="epp-main">

        {if !empty($error)}
            <div class="card epp-card epp-error">
                <div class="epp-icon"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg></div>
                <div class="epp-body">
                    <h3 class="epp-title">{$LANG.domaingeteppcodefailure|default:'Could not retrieve EPP code'}</h3>
                    <p class="epp-message">{$error|escape}</p>
                </div>
            </div>
        {elseif !empty($eppcode)}
            <div class="card epp-card">
                <div class="epp-icon epp-icon-ok"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="11" width="18" height="11" rx="2"/><path d="M7 11V7a5 5 0 0110 0v4"/></svg></div>
                <div class="epp-body">
                    <h3 class="epp-title">{$LANG.domaingeteppcodeis|default:'Your transfer code'}</h3>
                    <div class="epp-code" id="eppCode" data-code="{$eppcode|escape}">{$eppcode|escape}</div>
                    <button type="button" class="btn-secondary epp-copy" data-epp-copy>{$LANG.copy|default:'Copy code'}</button>
                    <p class="epp-help">{$LANG.domaingeteppwarning|default:'Keep this code private. Anyone with it can initiate a transfer of your domain.'}</p>
                </div>
            </div>
        {else}
            <div class="card epp-card">
                <div class="epp-icon epp-icon-ok"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z"/><polyline points="22,6 12,13 2,6"/></svg></div>
                <div class="epp-body">
                    <h3 class="epp-title">{$LANG.checkyouremail|default:'Check your email'}</h3>
                    <p class="epp-message">{$LANG.domaingeteppcodeemailconfirmation|default:'For security, the transfer code has been emailed to the registered domain contact.'}</p>
                </div>
            </div>
        {/if}

        <div class="card epp-info">
            <h4 class="epp-info-title">{$LANG.howtransferworks|default:'How a transfer works'}</h4>
            <ol class="epp-steps">
                <li>{$LANG.eppstep1|default:'Unlock the domain at the current registrar.'}</li>
                <li>{$LANG.eppstep2|default:'Request the EPP/auth code on this page.'}</li>
                <li>{$LANG.eppstep3|default:'Submit a transfer request at the gaining registrar with that code.'}</li>
                <li>{$LANG.eppstep4|default:'Approve the transfer email from the current registrar (usually within 5 days).'}</li>
            </ol>
        </div>

    </div>

    <aside class="epp-aside">
        <div class="card subnav-card">
            <div class="subnav-heading">{$LANG.domain|default:'Domain'}</div>
            <a href="{$WEB_ROOT}/clientarea.php?action=domaindetails&id={$domainid|escape}" class="subnav-item">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><polyline points="15 18 9 12 15 6"/></svg>
                {$LANG.domaindetails|default:'Domain details'}
            </a>
            <a href="{$WEB_ROOT}/clientarea.php?action=getepp&id={$domainid|escape}" class="subnav-item active">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="11" width="18" height="11" rx="2"/><path d="M7 11V7a5 5 0 0110 0v4"/></svg>
                {$LANG.eppcode|default:'EPP code'}
            </a>
        </div>
    </aside>
</div>

<script>{literal}
(function(){
    var btn = document.querySelector('[data-epp-copy]');
    if (!btn) return;
    btn.addEventListener('click', function(){
        var node = document.getElementById('eppCode');
        var code = (node && node.getAttribute('data-code')) || '';
        if (!code) return;
        if (navigator.clipboard && navigator.clipboard.writeText) {
            navigator.clipboard.writeText(code).then(function(){
                var orig = btn.textContent; btn.textContent = 'Copied'; setTimeout(function(){ btn.textContent = orig; }, 1400);
            });
        } else {
            var sel = document.createRange(); sel.selectNodeContents(node);
            var s = window.getSelection(); s.removeAllRanges(); s.addRange(sel);
            try { document.execCommand('copy'); var orig = btn.textContent; btn.textContent = 'Copied'; setTimeout(function(){ btn.textContent = orig; }, 1400); } catch(e){}
            s.removeAllRanges();
        }
    });
})();
{/literal}</script>
