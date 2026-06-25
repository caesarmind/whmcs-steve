{* Hostnodes - Configure SSL, step 1 (Apple-style): server type + CSR + admin contact.

   WHMCS SSL-configuration variables (cross-checked against Lagom configuressl-stepone.tpl):
     $status          - cert state; the form shows on 'Awaiting Configuration'
     $errormessage    - validation error HTML (if any)
     $cert            - cert token (form posts to configuressl.php?cert=...&step=2)
     $serviceid       - related service id
     $webservertypes  - array webservertypeid => label
     $servertype      - currently selected server type
     $csr             - CSR text (if already supplied)
     $additionalfields - array heading => fields[], each: name, input (raw HTML), description
     admin contact: $firstname,$lastname,$orgname,$jobtitle,$email,$address1,$address2,
                    $city,$state,$postcode,$country,$phonenumber
     $clientcountries - array code => name
   Demo data under ?preview=1 when no live cert is in scope.
*}

{assign var=sslStatus value=$status|default:''}
{assign var=isPreview value=false}
{if isset($smarty.get.preview) && $smarty.get.preview == '1'}{assign var=isPreview value=true}{/if}

{assign var=sslDemo value=false}
{if !$sslStatus && $isPreview}
    {assign var=sslDemo value=true}
    {assign var=sslStatus value='Awaiting Configuration'}
    {assign var=webservertypes value=['apache2'=>'Apache + mod_ssl','nginx'=>'Nginx','iis'=>'Microsoft IIS','other'=>'Other / Plesk / cPanel']}
    {assign var=clientcountries value=['US'=>'United States','GB'=>'United Kingdom','CA'=>'Canada','AU'=>'Australia','DE'=>'Germany','FR'=>'France']}
{/if}

{assign var=sslForm value=false}
{if $sslStatus == 'Awaiting Configuration'}{assign var=sslForm value=true}{/if}
{if $sslForm}{assign var=dashIsEmpty value='full'}{else}{assign var=dashIsEmpty value='empty'}{/if}

<link rel="stylesheet" href="{$WEB_ROOT}/templates/{$template}/assets/css/pages/configuressl-stepone.css?v={$hadrian.version|default:'1.0'}">

<script>
(function () {
    var b = document.body;
    if (!b) return;
    b.setAttribute('data-data',   '{$dashIsEmpty}');
    b.setAttribute('data-subnav', 'off');
})();
</script>

<header class="page-header">
    <p class="page-eyebrow">{$LANG.domainssloptions|default:'SSL Certificates'}</p>
    <h1>{$hadrianLang.ssl.configureTitle}</h1>
    <p class="page-subtitle">{$hadrianLang.ssl.configIntro}</p>
</header>

{* ---- Wizard stepper ---- *}
<div class="ssl-steps">
    <div class="ssl-step active">
        <span class="ssl-step-num">1</span>
        <span class="ssl-step-label">{$hadrianLang.ssl.stepConfig}</span>
    </div>
    <span class="ssl-step-sep"></span>
    <div class="ssl-step">
        <span class="ssl-step-num">2</span>
        <span class="ssl-step-label">{$hadrianLang.ssl.stepValidate}</span>
    </div>
    <span class="ssl-step-sep"></span>
    <div class="ssl-step">
        <span class="ssl-step-num">3</span>
        <span class="ssl-step-label">{$hadrianLang.ssl.stepComplete}</span>
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
<form method="post" action="{$WEB_ROOT}/configuressl.php?cert={$cert|default:''|escape}&amp;step=2">

    {* ---- Server configuration ---- *}
    <div class="card">
        <div class="card-header"><h2 class="card-title">{$LANG.sslserverinfo}</h2></div>
        <div class="card-body">
            <div class="ssl-alert info">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
                <div>{$LANG.sslserverinfodetails}</div>
            </div>
            <div class="form-group">
                <label class="form-label" for="inputServerType">{$LANG.sslservertype}</label>
                <select name="servertype" id="inputServerType" class="form-select">
                    <option value="">{$LANG.ssl.selectWebserver}</option>
                    {if isset($webservertypes)}{foreach $webservertypes as $wsId => $wsName}
                        <option value="{$wsId|escape}"{if isset($servertype) && $servertype == $wsId} selected{/if}>{$wsName|escape}</option>
                    {/foreach}{/if}
                </select>
            </div>
            <div class="form-group">
                <label class="form-label" for="inputCsr">{$LANG.sslcsr}</label>
                <textarea name="csr" id="inputCsr" rows="7" class="form-textarea" placeholder="-----BEGIN CERTIFICATE REQUEST-----">{if isset($csr) && $csr}{$csr|escape}{/if}</textarea>
            </div>
            {if isset($additionalfields)}{foreach $additionalfields as $heading => $fields}
                <h3 class="card-title" style="font-size:15px;margin:18px 0 10px;">{$heading|escape}</h3>
                {foreach $fields as $vals}
                    <div class="form-group">
                        <label class="form-label">{$vals.name|escape}</label>
                        {$vals.input} {if $vals.description}<span class="form-hint">{$vals.description|strip_tags}</span>{/if}
                    </div>
                {/foreach}
            {/foreach}{/if}
        </div>
    </div>

    {* ---- Administrative information ---- *}
    <div class="card">
        <div class="card-header"><h2 class="card-title">{$LANG.ssladmininfo}</h2></div>
        <div class="card-body">
            <div class="ssl-alert info">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
                <div>{$LANG.ssladmininfodetails}</div>
            </div>
            <div class="ssl-grid">
                <div class="form-group">
                    <label class="form-label" for="inputFirstName">{$LANG.clientareafirstname}</label>
                    <input type="text" class="form-input" name="firstname" id="inputFirstName" value="{$firstname|default:''|escape}">
                </div>
                <div class="form-group">
                    <label class="form-label" for="inputLastName">{$LANG.clientarealastname}</label>
                    <input type="text" class="form-input" name="lastname" id="inputLastName" value="{$lastname|default:''|escape}">
                </div>
                <div class="form-group">
                    <label class="form-label" for="inputOrgName">{$LANG.organizationname}</label>
                    <input type="text" class="form-input" name="orgname" id="inputOrgName" value="{$orgname|default:''|escape}">
                </div>
                <div class="form-group">
                    <label class="form-label" for="inputJobTitle">{$LANG.jobtitle}</label>
                    <input type="text" class="form-input" name="jobtitle" id="inputJobTitle" value="{$jobtitle|default:''|escape}">
                </div>
                <div class="form-group">
                    <label class="form-label" for="inputEmail">{$LANG.clientareaemail}</label>
                    <input type="email" class="form-input" name="email" id="inputEmail" value="{$email|default:''|escape}">
                </div>
                <div class="form-group">
                    <label class="form-label" for="inputPhoneNumber">{$LANG.clientareaphonenumber}</label>
                    <input type="tel" class="form-input" name="phonenumber" id="inputPhoneNumber" value="{$phonenumber|default:''|escape}">
                </div>
                <div class="form-group full">
                    <label class="form-label" for="inputAddress1">{$LANG.clientareaaddress1}</label>
                    <input type="text" class="form-input" name="address1" id="inputAddress1" value="{$address1|default:''|escape}">
                </div>
                <div class="form-group full">
                    <label class="form-label" for="inputAddress2">{$LANG.clientareaaddress2}</label>
                    <input type="text" class="form-input" name="address2" id="inputAddress2" value="{$address2|default:''|escape}">
                </div>
                <div class="form-group">
                    <label class="form-label" for="inputCity">{$LANG.clientareacity}</label>
                    <input type="text" class="form-input" name="city" id="inputCity" value="{$city|default:''|escape}">
                </div>
                <div class="form-group">
                    <label class="form-label" for="inputState">{$LANG.clientareastate}</label>
                    <input type="text" class="form-input" name="state" id="inputState" value="{$state|default:''|escape}">
                </div>
                <div class="form-group">
                    <label class="form-label" for="inputPostcode">{$LANG.clientareapostcode}</label>
                    <input type="text" class="form-input" name="postcode" id="inputPostcode" value="{$postcode|default:''|escape}">
                </div>
                <div class="form-group">
                    <label class="form-label" for="inputCountry">{$LANG.clientareacountry}</label>
                    <select name="country" id="inputCountry" class="form-select">
                        {if isset($clientcountries)}{foreach $clientcountries as $cCode => $cName}
                            <option value="{$cCode|escape}"{if isset($country) && $country == $cCode} selected{/if}>{$cName|escape}</option>
                        {/foreach}{/if}
                    </select>
                </div>
            </div>

            <div class="btn-group">
                <button type="submit" id="btnOrderContinue" class="btn-primary">{$LANG.continue}</button>
                <a href="{$WEB_ROOT}/clientarea.php?action=services" class="btn-secondary">{$LANG.cancel}</a>
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
        {if isset($status) && $status && $status != 'Awaiting Configuration'}
            <p class="ssl-notice-title">{$LANG.sslnoconfigurationpossible}</p>
            <p class="ssl-notice-sub">{$hadrianLang.ssl.noConfigPossibleSub}</p>
            <a href="{$WEB_ROOT}/clientarea.php?action=services" class="btn-primary">{$LANG.clientareanavservices|default:'View my services'}</a>
        {else}
            <p class="ssl-notice-title">{$LANG.sslinvalidlink}</p>
            <p class="ssl-notice-sub">{$hadrianLang.ssl.invalidLinkSub}</p>
            <a href="{$WEB_ROOT}/clientarea.php?action=services" class="btn-primary">{$LANG.clientareanavservices|default:'View my services'}</a>
        {/if}
    </div>
</div>
{/if}
