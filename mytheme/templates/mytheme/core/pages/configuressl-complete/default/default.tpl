{* Hostnodes - Configure SSL, complete (Apple-style): submission result + validation steps.

   WHMCS variables (cross-checked against Lagom configuressl-complete.tpl):
     $errormessage - error HTML (if configuration failed)
     $domain       - the certificate domain
     $authData     - validation-method object (may be null), with:
                       methodNameConstant() => 'emailauth' | 'dnsauth' | 'fileauth'
                       ->email                          (emailauth)
                       ->type, ->host, ->value          (dnsauth)
                       ->filePath(), ->contents         (fileauth)
   We render only WHMCS-provided values (no invented issuer/serial/validity).
   Demo data under ?preview=1 shows a sample DNS-validation card.
*}

{assign var=isPreview value=false}
{if isset($smarty.get.preview) && $smarty.get.preview == '1'}{assign var=isPreview value=true}{/if}

{assign var=sslError value=false}
{if isset($errormessage) && $errormessage}{assign var=sslError value=true}{/if}

{assign var=sslDemo value=false}
{if !$sslError && !isset($authData) && $isPreview}{assign var=sslDemo value=true}{/if}

{assign var=sslOk value=true}
{if $sslError}{assign var=sslOk value=false}{/if}
{if $sslOk}{assign var=dashIsEmpty value='full'}{else}{assign var=dashIsEmpty value='empty'}{/if}

<link rel="stylesheet" href="{$WEB_ROOT}/templates/{$template}/assets/css/pages/configuressl-complete.css?v={$myTheme.version|default:'1.0'}">

<script>
(function () {
    var b = document.body;
    if (!b) return;
    b.setAttribute('data-data',   '{$dashIsEmpty}');
    b.setAttribute('data-subnav', 'off');
})();
</script>

<header class="page-header">
    <p class="page-eyebrow">{$LANG.domainssloptions|default:'SSL Certificate'}</p>
    <h1>{$LANG.sslconfigured|default:'Certificate request submitted'}</h1>
    <p class="page-subtitle">{$LANG.sslcompleteintro|default:'Complete the validation step below so the certificate authority can issue your certificate.'}</p>
</header>

<div class="ssl-steps">
    <div class="ssl-step done">
        <span class="ssl-step-num">1</span>
        <span class="ssl-step-label">{$LANG.sslstepconfig|default:'Configuration'}</span>
    </div>
    <span class="ssl-step-sep"></span>
    <div class="ssl-step done">
        <span class="ssl-step-num">2</span>
        <span class="ssl-step-label">{$LANG.sslstepvalidate|default:'Validation'}</span>
    </div>
    <span class="ssl-step-sep"></span>
    <div class="ssl-step active">
        <span class="ssl-step-num">3</span>
        <span class="ssl-step-label">{$LANG.sslstepcomplete|default:'Complete'}</span>
    </div>
</div>

{if $sslOk}
<div class="when-full">

    <div class="ssl-success">
        <div class="ssl-success-ico">
            <svg viewBox="0 0 24 24" fill="none" stroke="#fff" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"/></svg>
        </div>
        <h2>{$LANG.sslconfigcomplete|default:'Configuration complete'}</h2>
        <p>{if isset($domain) && $domain}{$LANG.sslcompletedfor|default:'Your certificate request for'} {$domain|escape} {$LANG.sslcompletedissued|default:'has been submitted.'}{else}{$LANG.sslcompletegeneric|default:'Your certificate request has been submitted.'}{/if}</p>
    </div>

    {* ---- Validation instructions ---- *}
    {if isset($authData) && $authData}
        {if $authData->methodNameConstant() == 'emailauth'}
        <div class="card" style="max-width: 600px; margin: 0 auto;">
            <div class="card-header"><h2 class="card-title">{$LANG.sslemailinformation|default:'Email validation'}</h2></div>
            <div class="card-body">
                <div class="ssl-alert info">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
                    <div>{$LANG.sslemailsteps|default:'A validation email has been sent. Click the link inside to approve issuance.'}</div>
                </div>
                <div class="form-group">
                    <label class="form-label">{$LANG.email|default:'Email'}</label>
                    <input type="text" class="form-input" value="{$authData->email|escape}" readonly>
                </div>
            </div>
        </div>
        {elseif $authData->methodNameConstant() == 'dnsauth'}
        <div class="card" style="max-width: 600px; margin: 0 auto;">
            <div class="card-header"><h2 class="card-title">{$LANG.ssldnsrecordinformation|default:'DNS record validation'}</h2></div>
            <div class="card-body">
                <div class="ssl-alert info">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
                    <div>{$LANG.ssldnssteps|default:'Add the following record to your domain DNS. Issuance completes automatically once it propagates.'}</div>
                </div>
                <div class="form-group">
                    <label class="form-label">{$LANG.ssltype|default:'Type'}</label>
                    <input type="text" class="form-input" value="{$authData->type|escape}" readonly>
                </div>
                <div class="form-group">
                    <label class="form-label">{$LANG.sslhost|default:'Host'}</label>
                    <div class="ssl-copy">
                        <input type="text" id="sslDnsHost" class="form-input" value="{$authData->host|escape}" readonly>
                        <button type="button" data-copy="#sslDnsHost" title="{$LANG.copy|default:'Copy'}"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><rect x="9" y="9" width="13" height="13" rx="2"/><path d="M5 15H4a2 2 0 01-2-2V4a2 2 0 012-2h9a2 2 0 012 2v1"/></svg></button>
                    </div>
                </div>
                <div class="form-group">
                    <label class="form-label">{$LANG.sslvalue|default:'Value'}</label>
                    <div class="ssl-copy">
                        <input type="text" id="sslDnsValue" class="form-input" value="{$authData->value|escape}" readonly>
                        <button type="button" data-copy="#sslDnsValue" title="{$LANG.copy|default:'Copy'}"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><rect x="9" y="9" width="13" height="13" rx="2"/><path d="M5 15H4a2 2 0 01-2-2V4a2 2 0 012-2h9a2 2 0 012 2v1"/></svg></button>
                    </div>
                </div>
            </div>
        </div>
        {elseif $authData->methodNameConstant() == 'fileauth'}
        <div class="card" style="max-width: 600px; margin: 0 auto;">
            <div class="card-header"><h2 class="card-title">{$LANG.sslfileinformation|default:'File validation'}</h2></div>
            <div class="card-body">
                <div class="ssl-alert info">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
                    <div>{$LANG.sslfilesteps|default:'Upload a file with the contents below to the URL shown on your web server.'}</div>
                </div>
                <div class="form-group">
                    <label class="form-label">{$LANG.sslurl|default:'File URL'}</label>
                    <div class="ssl-copy">
                        <input type="text" id="sslFileUrl" class="form-input" value="http://{$domain|default:''|escape}/{$authData->filePath()|escape}" readonly>
                        <button type="button" data-copy="#sslFileUrl" title="{$LANG.copy|default:'Copy'}"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><rect x="9" y="9" width="13" height="13" rx="2"/><path d="M5 15H4a2 2 0 01-2-2V4a2 2 0 012-2h9a2 2 0 012 2v1"/></svg></button>
                    </div>
                </div>
                <div class="form-group">
                    <label class="form-label">{$LANG.sslvalue|default:'File contents'}</label>
                    <div class="ssl-copy">
                        <input type="text" id="sslFileVal" class="form-input" value="{$authData->contents|escape}" readonly>
                        <button type="button" data-copy="#sslFileVal" title="{$LANG.copy|default:'Copy'}"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><rect x="9" y="9" width="13" height="13" rx="2"/><path d="M5 15H4a2 2 0 01-2-2V4a2 2 0 012-2h9a2 2 0 012 2v1"/></svg></button>
                    </div>
                </div>
            </div>
        </div>
        {/if}
    {elseif $sslDemo}
        <div class="card" style="max-width: 600px; margin: 0 auto;">
            <div class="card-header"><h2 class="card-title">{$LANG.ssldnsrecordinformation|default:'DNS record validation'}</h2></div>
            <div class="card-body">
                <div class="ssl-alert info">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
                    <div>{$LANG.ssldnssteps|default:'Add the following record to your domain DNS. Issuance completes automatically once it propagates.'}</div>
                </div>
                <dl class="ssl-dl">
                    <dt>{$LANG.ssltype|default:'Type'}</dt><dd>CNAME</dd>
                    <dt>{$LANG.sslhost|default:'Host'}</dt><dd>_acme-challenge.hendersondesign.com</dd>
                    <dt>{$LANG.sslvalue|default:'Value'}</dt><dd>a1b2c3d4e5f6.dcv.digicert.com</dd>
                </dl>
            </div>
        </div>
    {/if}

    <div class="btn-group" style="justify-content: center; margin-top: 24px;">
        <a href="{$WEB_ROOT}/clientarea.php?action=services" class="btn-primary">{$LANG.clientareanavservices|default:'View my services'}</a>
        <a href="{$WEB_ROOT}/supporttickets.php" class="btn-secondary">{$LANG.contactus|default:'Contact support'}</a>
    </div>

</div>{* /.when-full *}
{/if}

{if !$sslOk}
<div class="when-empty">
    <div class="ssl-notice">
        <div class="ssl-notice-ico">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/><line x1="12" y1="9" x2="12" y2="13"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>
        </div>
        <p class="ssl-notice-title">{$LANG.sslconfigfailed|default:'Configuration could not be completed'}</p>
        <p class="ssl-notice-sub">{if isset($errormessage) && $errormessage}{$errormessage|strip_tags}{else}{$LANG.sslconfigfailedsub|default:'Something went wrong while submitting your certificate request. Try again or contact support.'}{/if}</p>
        <a href="{$WEB_ROOT}/configuressl.php" class="btn-primary">{$LANG.tryagain|default:'Try again'}</a>
    </div>
</div>
{/if}

{if $sslOk}
<script>
{literal}
(function () {
    document.querySelectorAll('[data-copy]').forEach(function (btn) {
        btn.addEventListener('click', function () {
            var el = document.querySelector(btn.getAttribute('data-copy'));
            if (!el) return;
            try { el.select(); } catch (e) {}
            try {
                navigator.clipboard.writeText(el.value || el.textContent);
            } catch (e) {
                try { document.execCommand('copy'); } catch (e2) {}
            }
        });
    });
})();
{/literal}
</script>
{/if}
