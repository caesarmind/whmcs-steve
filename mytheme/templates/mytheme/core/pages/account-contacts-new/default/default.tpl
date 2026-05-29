{* Hostnodes - New contact (Apple-style). Add-contact form variant of
   account-contacts-manage (shares the .ct-* component CSS).

   WHMCS v9 data (verified against account-contacts-manage / Nexus):
     $formdata          - optional pre-fill (firstname, lastname, companyname, email,
                          phonenumber, tax_id, address1, address2, city, state, postcode,
                          emailPreferences{ typeKey: bool })
     $taxIdLabel        - lang key for the tax field label
     $countriesdropdown - pre-rendered <select> HTML for country
     $errorMessageHtml  - validation error HTML
     $token             - CSRF token
   POST: {routePath('account-contacts-save')} with contactid='new'.
*}

{assign var=dashIsEmpty value='full'}

<link rel="stylesheet" href="{$WEB_ROOT}/templates/{$template}/assets/css/pages/account-contacts-new.css?v={$myTheme.version|default:'1.0'}">

<script>
(function () {
    var b = document.body;
    if (!b) return;
    b.setAttribute('data-data',   '{$dashIsEmpty}');
    b.setAttribute('data-subnav', 'on');
})();
</script>

<header class="page-header">
    <h1>{$LANG.clientareanavaddcontact|default:'Add new contact'}</h1>
    <p class="page-subtitle">{$LANG.contactsnewsub|default:'Add another person who can manage parts of this account.'}</p>
</header>

<div class="ct-split">
    <div class="ct-main">

        {if $message = get_flash_message()}
            <div class="ct-alert ct-alert-{if $message.type == 'error'}error{elseif $message.type == 'success'}success{elseif $message.type == 'warning'}warn{else}info{/if}">{$message.text}</div>
        {/if}
        {if isset($errorMessageHtml) && $errorMessageHtml}
            <div class="ct-alert ct-alert-error">{$errorMessageHtml}</div>
        {/if}

        <form method="post" action="{routePath('account-contacts-save')}" class="ct-form">
            <input type="hidden" name="token" value="{$token|default:''|escape}">
            <input type="hidden" name="contactid" value="new">

            <div class="card ct-card">
                <div class="ct-card-header"><h2 class="ct-card-title">{$LANG.contactDetails|default:'Contact details'}</h2></div>
                <div class="ct-card-body">
                    <div class="ct-form-grid">
                        <div class="ct-form-col">
                            <div class="ct-form-row">
                                <label class="ct-label" for="ct-first">{$LANG.clientareafirstname|default:'First name'}</label>
                                <input type="text" name="firstname" id="ct-first" class="ct-input" value="{$formdata.firstname|default:''|escape}" autocomplete="given-name">
                            </div>
                            <div class="ct-form-row">
                                <label class="ct-label" for="ct-last">{$LANG.clientarealastname|default:'Last name'}</label>
                                <input type="text" name="lastname" id="ct-last" class="ct-input" value="{$formdata.lastname|default:''|escape}" autocomplete="family-name">
                            </div>
                            <div class="ct-form-row">
                                <label class="ct-label" for="ct-company">{$LANG.clientareacompanyname|default:'Company'}</label>
                                <input type="text" name="companyname" id="ct-company" class="ct-input" value="{$formdata.companyname|default:''|escape}" autocomplete="organization">
                            </div>
                            <div class="ct-form-row">
                                <label class="ct-label" for="ct-email">{$LANG.clientareaemail|default:'Email address'}</label>
                                <input type="email" name="email" id="ct-email" class="ct-input" value="{$formdata.email|default:''|escape}" autocomplete="email">
                            </div>
                            <div class="ct-form-row">
                                <label class="ct-label" for="ct-phone">{$LANG.clientareaphonenumber|default:'Phone number'}</label>
                                <input type="tel" name="phonenumber" id="ct-phone" class="ct-input" value="{$formdata.phonenumber|default:''|escape}" autocomplete="tel">
                            </div>
                            {if isset($taxIdLabel)}
                            <div class="ct-form-row">
                                <label class="ct-label" for="ct-taxid">{$LANG[$taxIdLabel]|default:'Tax ID'}</label>
                                <input type="text" name="tax_id" id="ct-taxid" class="ct-input" value="{$formdata.tax_id|default:''|escape}">
                            </div>
                            {/if}
                        </div>
                        <div class="ct-form-col">
                            <div class="ct-form-row">
                                <label class="ct-label" for="ct-addr1">{$LANG.clientareaaddress1|default:'Address 1'}</label>
                                <input type="text" name="address1" id="ct-addr1" class="ct-input" value="{$formdata.address1|default:''|escape}" autocomplete="address-line1">
                            </div>
                            <div class="ct-form-row">
                                <label class="ct-label" for="ct-addr2">{$LANG.clientareaaddress2|default:'Address 2'}</label>
                                <input type="text" name="address2" id="ct-addr2" class="ct-input" value="{$formdata.address2|default:''|escape}" autocomplete="address-line2">
                            </div>
                            <div class="ct-form-row">
                                <label class="ct-label" for="ct-city">{$LANG.clientareacity|default:'City'}</label>
                                <input type="text" name="city" id="ct-city" class="ct-input" value="{$formdata.city|default:''|escape}" autocomplete="address-level2">
                            </div>
                            <div class="ct-form-row">
                                <label class="ct-label" for="ct-state">{$LANG.clientareastate|default:'State / region'}</label>
                                <input type="text" name="state" id="ct-state" class="ct-input" value="{$formdata.state|default:''|escape}" autocomplete="address-level1">
                            </div>
                            <div class="ct-form-row">
                                <label class="ct-label" for="ct-zip">{$LANG.clientareapostcode|default:'ZIP / postal code'}</label>
                                <input type="text" name="postcode" id="ct-zip" class="ct-input" value="{$formdata.postcode|default:''|escape}" autocomplete="postal-code">
                            </div>
                            <div class="ct-form-row">
                                <label class="ct-label">{$LANG.clientareacountry|default:'Country'}</label>
                                <div class="ct-countries">{if isset($countriesdropdown)}{$countriesdropdown}{/if}</div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            {if isset($formdata.emailPreferences)}
            <div class="card ct-card">
                <div class="ct-card-header"><h2 class="ct-card-title">{$LANG.clientareacontactsemails|default:'Email preferences'}</h2></div>
                <div class="ct-card-body">
                    <div class="ct-prefs">
                        {foreach $formdata.emailPreferences as $emailType => $value}
                            <label class="ct-pref">
                                <input type="hidden" name="email_preferences[{$emailType|escape}]" value="0">
                                <input type="checkbox" name="email_preferences[{$emailType|escape}]" value="1"{if $value} checked{/if}>
                                <span>{lang key="emailPreferences."|cat:$emailType}</span>
                            </label>
                        {/foreach}
                    </div>
                </div>
            </div>
            {/if}

            <div class="ct-actions">
                <div class="ct-actions-right">
                    <a href="{routePath('account-contacts')}" class="btn-secondary">{$LANG.cancel|default:'Cancel'}</a>
                    <button type="submit" name="save" value="1" class="btn-primary">{$LANG.clientareanavaddcontact|default:'Add contact'}</button>
                </div>
            </div>
        </form>

    </div>

    <aside>
        <div class="card subnav-card">
            <div class="subnav-heading">{$LANG.accounttab|default:'Account'}</div>
            <a href="{$WEB_ROOT}/clientarea.php?action=details" class="subnav-item">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M20 21v-2a4 4 0 00-4-4H8a4 4 0 00-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>
                {$LANG.accountdetails|default:'Account Details'}
            </a>
            <a href="{routePath('account-users')}" class="subnav-item">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M17 21v-2a4 4 0 00-4-4H5a4 4 0 00-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 00-3-3.87"/><path d="M16 3.13a4 4 0 010 7.75"/></svg>
                {$LANG.usermanagement|default:'User Management'}
            </a>
            <a href="{routePath('account-paymentmethods')}" class="subnav-item">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><rect x="2" y="5" width="20" height="14" rx="2"/><path d="M2 10h20"/></svg>
                {$LANG.paymentmethods|default:'Payment Methods'}
            </a>
            <a href="{routePath('account-contacts')}" class="subnav-item active">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M20 21v-2a4 4 0 00-4-4H8a4 4 0 00-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>
                {$LANG.contacts|default:'Contacts'}
            </a>
            <a href="{$WEB_ROOT}/clientarea.php?action=emails" class="subnav-item">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z"/><polyline points="22 6 12 13 2 6"/></svg>
                {$LANG.emailstitle|default:'Email History'}
            </a>
        </div>
    </aside>
</div>
