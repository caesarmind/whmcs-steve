{* Hostnodes — Contacts.

   WHMCS v9 data (verified against Nexus account-contacts-manage.tpl):
     $contacts                 — Collection / array of { .id, .name, .email }
                                  (the dropdown picker list)
     $contactid                — currently-selected contact id ("" if none)
     $formdata                 — pre-filled form data for the selected contact:
                                  firstname, lastname, companyname, email,
                                  phonenumber, tax_id, address1, address2,
                                  city, state, postcode
                                  emailPreferences — { typeKey: bool, … }
     $taxIdLabel               — lang key for the tax field's label
     $countriesdropdown        — pre-rendered HTML <select> for country
     $errorMessageHtml         — error block HTML (when validation failed)
     $token                    — CSRF token

   POST routes:
     {routePath('account-contacts')}        — dropdown picker submit (changes $contactid)
     {routePath('account-contacts-save')}   — save the form
     {routePath('account-contacts-delete')} — delete the selected contact

   Nexus's UX (preserved):
     1. Dropdown to pick which contact to edit (or "new")
     2. Big two-column form below
     3. Email-preferences checkbox group
     4. Save / Reset / Delete buttons
*}

<link rel="stylesheet" href="{$WEB_ROOT}/templates/{$template}/assets/css/pages/account-contacts-manage.css?v={$hadrian.version|default:'1.0'}">
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/intl-tel-input@18.5.3/build/css/intlTelInput.css">

<header class="page-header">
    <h1>{$LANG.contacts|default:'Contacts'}</h1>
    <p class="page-subtitle">{$hadrianLang.account.contactsSub}</p>
</header>

<div class="ct-split">
    <div class="ct-main">

        {if $message = get_flash_message()}
            <div class="ct-alert ct-alert-{if $message.type == 'error'}error{elseif $message.type == 'success'}success{elseif $message.type == 'warning'}warn{else}info{/if}">
                {$message.text}
            </div>
        {/if}
        {if isset($errorMessageHtml) && $errorMessageHtml}
            <div class="ct-alert ct-alert-error">{$errorMessageHtml}</div>
        {/if}

        {* ── Contact picker ── *}
        <form method="post" action="{routePath('account-contacts')}" class="card ct-picker">
            <input type="hidden" name="token" value="{$token|default:''|escape}">
            <label for="ct-contactid" class="ct-label">{$LANG.clientareachoosecontact}</label>
            <div class="ct-picker-row">
                <select name="contactid" id="ct-contactid" class="ct-input ct-select" onchange="this.form.submit()">
                    {if isset($contacts)}
                        {foreach $contacts as $contact}
                            <option value="{$contact.id|escape}"{if isset($contactid) && $contact.id eq $contactid} selected{/if}>{$contact.name|escape} — {$contact.email|escape}</option>
                        {/foreach}
                    {/if}
                    <option value="new"{if $contactid eq 'new'} selected{/if}>+ {$LANG.clientareanavaddcontact}</option>
                </select>
                <button type="submit" class="btn-secondary ct-picker-go">{$LANG.go}</button>
            </div>
        </form>

        {* ── Edit form for the selected contact ── *}
        <form method="post" action="{routePath('account-contacts-save')}" class="ct-form">
            <input type="hidden" name="token" value="{$token|default:''|escape}">
            <input type="hidden" name="contactid" value="{$contactid|default:''|escape}">

            <div class="card ct-card">
                <div class="ct-card-header"><h2 class="ct-card-title">{$LANG.contactDetails}</h2></div>
                <div class="ct-card-body">
                    <div class="ct-form-grid">
                        {* Left col *}
                        <div class="ct-form-col">
                            <div class="ct-form-row">
                                <label class="ct-label" for="ct-first">{$LANG.clientareafirstname}</label>
                                <input type="text" name="firstname" id="ct-first" class="ct-input" value="{$formdata.firstname|default:''|escape}" autocomplete="given-name">
                            </div>
                            <div class="ct-form-row">
                                <label class="ct-label" for="ct-last">{$LANG.clientarealastname}</label>
                                <input type="text" name="lastname" id="ct-last" class="ct-input" value="{$formdata.lastname|default:''|escape}" autocomplete="family-name">
                            </div>
                            <div class="ct-form-row">
                                <label class="ct-label" for="ct-company">{$LANG.clientareacompanyname}</label>
                                <input type="text" name="companyname" id="ct-company" class="ct-input" value="{$formdata.companyname|default:''|escape}" autocomplete="organization">
                            </div>
                            <div class="ct-form-row">
                                <label class="ct-label" for="ct-email">{$LANG.clientareaemail}</label>
                                <input type="email" name="email" id="ct-email" class="ct-input" value="{$formdata.email|default:''|escape}" autocomplete="email">
                            </div>
                            <div class="ct-form-row">
                                <label class="ct-label" for="ct-phone">{$LANG.clientareaphonenumber}</label>
                                <input type="tel" name="phonenumber" id="ct-phone" class="ct-input" value="{$formdata.phonenumber|default:''|escape}" autocomplete="tel">
                            </div>
                            {if isset($taxIdLabel)}
                            <div class="ct-form-row">
                                <label class="ct-label" for="ct-taxid">{$LANG[$taxIdLabel]|default:'Tax ID'}</label>
                                <input type="text" name="tax_id" id="ct-taxid" class="ct-input" value="{$formdata.tax_id|default:''|escape}">
                            </div>
                            {/if}
                        </div>
                        {* Right col *}
                        <div class="ct-form-col">
                            <div class="ct-form-row">
                                <label class="ct-label" for="ct-addr1">{$LANG.clientareaaddress1}</label>
                                <input type="text" name="address1" id="ct-addr1" class="ct-input" value="{$formdata.address1|default:''|escape}" autocomplete="address-line1">
                            </div>
                            <div class="ct-form-row">
                                <label class="ct-label" for="ct-addr2">{$LANG.clientareaaddress2}</label>
                                <input type="text" name="address2" id="ct-addr2" class="ct-input" value="{$formdata.address2|default:''|escape}" autocomplete="address-line2">
                            </div>
                            <div class="ct-form-row">
                                <label class="ct-label" for="ct-city">{$LANG.clientareacity}</label>
                                <input type="text" name="city" id="ct-city" class="ct-input" value="{$formdata.city|default:''|escape}" autocomplete="address-level2">
                            </div>
                            <div class="ct-form-row">
                                <label class="ct-label" for="ct-state">{$LANG.clientareastate}</label>
                                <input type="text" name="state" id="ct-state" class="ct-input" value="{$formdata.state|default:''|escape}" autocomplete="address-level1">
                            </div>
                            <div class="ct-form-row">
                                <label class="ct-label" for="ct-zip">{$LANG.clientareapostcode}</label>
                                <input type="text" name="postcode" id="ct-zip" class="ct-input" value="{$formdata.postcode|default:''|escape}" autocomplete="postal-code">
                            </div>
                            <div class="ct-form-row">
                                <label class="ct-label">{$LANG.clientareacountry}</label>
                                <div class="ct-countries">{if isset($countriesdropdown)}{$countriesdropdown}{/if}</div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            {if isset($formdata.emailPreferences)}
            <div class="card ct-card">
                <div class="ct-card-header"><h2 class="ct-card-title">{$LANG.clientareacontactsemails}</h2></div>
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
                {if $contactid && $contactid neq 'new'}
                    <button type="button" class="btn-secondary ct-delete-btn" data-ct-delete>{$LANG.clientareadeletecontact}</button>
                {/if}
                <div class="ct-actions-right">
                    <button type="reset" class="btn-secondary">{$LANG.cancel}</button>
                    <button type="submit" name="save" value="1" class="btn-primary">{$LANG.clientareasavechanges}</button>
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
                {$LANG.paymentMethods.title}
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

{* Hidden delete form — triggered by data-ct-delete button *}
<form method="post" action="{routePath('account-contacts-delete')}" id="ctDeleteForm" style="display:none">
    <input type="hidden" name="token" value="{$token|default:''|escape}">
    <input type="hidden" name="contactid" value="{$contactid|default:''|escape}">
</form>

<script>
var _localLang = {
    'deleteContactConfirm': '{$LANG.clientareadeletecontactareyousure|escape:"javascript"}'
};
</script>
<script>{literal}
(function(){
    var btn = document.querySelector('[data-ct-delete]');
    if (!btn) return;
    btn.addEventListener('click', function(){
        if (!confirm(_localLang.deleteContactConfirm)) return;
        document.getElementById('ctDeleteForm').submit();
    });
})();
{/literal}</script>

{* Phone country-code picker — same as registration. Keeps phonenumber as the
   NATIONAL number and submits the dial code in the hidden country-calling-code
   field WHMCS expects. *}
<script src="https://cdn.jsdelivr.net/npm/intl-tel-input@18.5.3/build/js/intlTelInput.min.js"></script>
<script>{literal}
(function () {
    var phoneEl = document.getElementById('ct-phone');
    if (!phoneEl || typeof window.intlTelInput !== 'function') { return; }
    var form = phoneEl.form;
    var countryEl = form ? form.querySelector('select[name="country"]') : document.querySelector('select[name="country"]');
    var fieldName = phoneEl.getAttribute('name') || 'phonenumber';

    var cc = document.createElement('input');
    cc.type = 'hidden';
    cc.name = 'country-calling-code-' + fieldName;
    cc.id = 'populatedCountryCode' + fieldName;
    phoneEl.parentNode.insertBefore(cc, phoneEl);

    var iti = window.intlTelInput(phoneEl, {
        separateDialCode: true,
        dropdownContainer: document.body,
        preferredCountries: ['us', 'gb', 'ca', 'au', 'de', 'fr', 'nl', 'es', 'it'],
        initialCountry: (function () {
            var c = countryEl ? (countryEl.value || '') : '';
            return (c && c.length === 2) ? c.toLowerCase() : 'us';
        })(),
        utilsScript: 'https://cdn.jsdelivr.net/npm/intl-tel-input@18.5.3/build/js/utils.js?onlyCountries=false'
    });

    function syncDialCode() {
        var d = iti.getSelectedCountryData();
        cc.value = (d && d.dialCode) ? d.dialCode : '';
    }
    syncDialCode();
    phoneEl.addEventListener('countrychange', syncDialCode);
    phoneEl.addEventListener('blur', function () {
        if (typeof iti.getNumber !== 'function') { return; }
        var number = iti.getNumber();
        var d = iti.getSelectedCountryData();
        var prefix = '+' + ((d && d.dialCode) ? d.dialCode : '');
        if (number && number.indexOf(prefix) === 0 && (number.match(/\+/g) || []).length > 1) {
            iti.setNumber(number.substr(prefix.length));
        }
        syncDialCode();
    });
    if (countryEl) {
        countryEl.addEventListener('change', function () {
            if (phoneEl.value.trim() !== '') { return; }
            var c = (this.value || '').toLowerCase();
            if (!c || c.length !== 2) { return; }
            try { iti.setCountry(c); } catch (e) {}
            syncDialCode();
        });
    }
})();
{/literal}</script>
