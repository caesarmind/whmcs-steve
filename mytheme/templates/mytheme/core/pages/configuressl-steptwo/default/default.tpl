{* Hostnodes - Configure SSL, step 2 (Apple-style): domain validation method.

   WHMCS variables (cross-checked against Lagom configuressl-steptwo.tpl):
     $cert            - cert token (form posts to configuressl.php?cert=...&step=3)
     $errormessage    - validation error HTML (if any)
     $approvalMethods - array of allowed methods: 'email','dns-txt-token','file'
                        (empty => email is the implicit default)
     $approveremails  - array num => email address (for the email method)
   We iterate $approvalMethods rather than calling in_array() (not Smarty-whitelisted).
   Demo data under ?preview=1.
*}

{assign var=hasCert value=false}
{if isset($cert) && $cert}{assign var=hasCert value=true}{/if}

{assign var=isPreview value=false}
{if isset($smarty.get.preview) && $smarty.get.preview == '1'}{assign var=isPreview value=true}{/if}

{assign var=sslDemo value=false}
{if !$hasCert && $isPreview}
    {assign var=sslDemo value=true}
    {assign var=hasCert value=true}
    {assign var=cert value='demo'}
    {assign var=approvalMethods value=['email','dns-txt-token','file']}
    {assign var=approveremails value=['admin@hendersondesign.com','webmaster@hendersondesign.com','hostmaster@hendersondesign.com']}
{/if}

{assign var=methods value=$approvalMethods|default:[]}
{assign var=sslForm value=$hasCert}
{if $sslForm}{assign var=dashIsEmpty value='full'}{else}{assign var=dashIsEmpty value='empty'}{/if}

<link rel="stylesheet" href="{$WEB_ROOT}/templates/{$template}/assets/css/pages/configuressl-steptwo.css?v={$myTheme.version|default:'1.0'}">

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
    <h1>{$LANG.sslselectvalidation|default:'Verify domain ownership'}</h1>
    <p class="page-subtitle">{$LANG.sslvalidationintro|default:'Choose how you want to prove control of the domain so the certificate authority can issue your certificate.'}</p>
</header>

<div class="ssl-steps">
    <div class="ssl-step done">
        <span class="ssl-step-num">1</span>
        <span class="ssl-step-label">{$LANG.sslstepconfig|default:'Configuration'}</span>
    </div>
    <span class="ssl-step-sep"></span>
    <div class="ssl-step active">
        <span class="ssl-step-num">2</span>
        <span class="ssl-step-label">{$LANG.sslstepvalidate|default:'Validation'}</span>
    </div>
    <span class="ssl-step-sep"></span>
    <div class="ssl-step">
        <span class="ssl-step-num">3</span>
        <span class="ssl-step-label">{$LANG.sslstepcomplete|default:'Complete'}</span>
    </div>
</div>

{if isset($errormessage) && $errormessage}
<div class="ssl-alert error">
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>
    <div>{$errormessage|strip_tags}</div>
</div>
{/if}

{if $sslForm}
<div class="when-full">
<form method="post" action="{$WEB_ROOT}/configuressl.php?cert={$cert|default:''|escape}&amp;step=3">
    <div class="card">
        <div class="card-header"><h2 class="card-title">{$LANG.sslselectvalidation|default:'Domain validation method'}</h2></div>
        <div class="card-body">

            {if $methods|@count > 0}
                {foreach $methods as $m}
                    <label class="ssl-radio">
                        <input type="radio" name="approval_method" value="{$m|escape}"{if $m@index == 0} checked{/if}>
                        <div>
                            {if $m == 'email'}
                                <div class="ssl-radio-title">{$LANG.sslemailmethod|default:'Email validation'}</div>
                                <div class="ssl-radio-sub">{$LANG.sslemailmethoddesc|default:'A validation link is emailed to an approved address on the domain.'}</div>
                            {elseif $m == 'dns-txt-token'}
                                <div class="ssl-radio-title">{$LANG.ssldnsmethod|default:'DNS (TXT record)'}</div>
                                <div class="ssl-radio-sub">{$LANG.ssldnsmethoddesc|default:'Add a TXT record to your domain DNS to prove control.'}</div>
                            {elseif $m == 'file'}
                                <div class="ssl-radio-title">{$LANG.sslfilemethod|default:'HTTP file upload'}</div>
                                <div class="ssl-radio-sub">{$LANG.sslfilemethoddesc|default:'Upload a verification file to your web server root.'}</div>
                            {else}
                                <div class="ssl-radio-title">{$m|escape}</div>
                            {/if}
                        </div>
                    </label>
                {/foreach}
            {else}
                <label class="ssl-radio">
                    <input type="radio" name="approval_method" value="email" checked>
                    <div>
                        <div class="ssl-radio-title">{$LANG.sslemailmethod|default:'Email validation'}</div>
                        <div class="ssl-radio-sub">{$LANG.sslemailmethoddesc|default:'A validation link is emailed to an approved address on the domain.'}</div>
                    </div>
                </label>
            {/if}

            {* Approver-email picker (email method) *}
            {if isset($approveremails) && $approveremails|@count > 0}
            <div class="ssl-approver-list" id="sslApproverList">
                <div class="form-label">{$LANG.sslselectemail|default:'Select the address to receive the validation email'}</div>
                {foreach $approveremails as $num => $approveremail}
                    <label class="ssl-approver">
                        <input type="radio" name="approveremail" value="{$approveremail|escape}"{if $num == 0} checked{/if}>
                        <span>{$approveremail|escape}</span>
                    </label>
                {/foreach}
            </div>
            {/if}

            <div class="btn-group" style="margin-top: 20px;">
                <button type="submit" id="btnOrderContinue" class="btn-primary">{$LANG.continue|default:'Continue'}</button>
                <a href="{$WEB_ROOT}/clientarea.php?action=services" class="btn-secondary">{$LANG.cancel|default:'Cancel'}</a>
            </div>
        </div>
    </div>
</form>
</div>{* /.when-full *}
{/if}

{if !$sslForm}
<div class="when-empty">
    <div class="ssl-notice">
        <div class="ssl-notice-ico">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="11" width="18" height="11" rx="2"/><path d="M7 11V7a5 5 0 0 1 10 0v4"/></svg>
        </div>
        <p class="ssl-notice-title">{$LANG.sslstep1incomplete|default:'Configuration not complete'}</p>
        <p class="ssl-notice-sub">{$LANG.sslstep1incompletesub|default:'Finish the certificate configuration step before choosing a validation method.'}</p>
        <a href="{$WEB_ROOT}/configuressl.php" class="btn-primary">{$LANG.back|default:'Back to configuration'}</a>
    </div>
</div>
{/if}

{if $sslForm}
<script>
{literal}
(function () {
    var radios = document.querySelectorAll('input[name="approval_method"]');
    var emailBlock = document.getElementById('sslApproverList');
    if (!radios.length) return;
    function sync() {
        var v = '';
        radios.forEach(function (r) { if (r.checked) v = r.value; });
        if (emailBlock) { emailBlock.style.display = (v === 'email') ? 'block' : 'none'; }
    }
    radios.forEach(function (r) { r.addEventListener('change', sync); });
    sync();
})();
{/literal}
</script>
{/if}
