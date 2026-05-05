{* Hostnodes — Account Details (Apple-style).

   WHMCS standard variables expected:
     $clientsdetails    — firstname, lastname, companyname, email, address1,
                          address2, city, state, postcode, country, phonenumber,
                          currency, language
     $countries         — country options array (code => name)
     $states            — state options array
     $languages         — available languages array
*}

{if isset($clientsdetails) && $clientsdetails}
    {assign var=dashIsEmpty value='full'}
{else}
    {assign var=dashIsEmpty value='empty'}
{/if}

{* Page-specific stylesheet *}
<link rel="stylesheet" href="{$WEB_ROOT}/templates/{$template}/assets/css/pages/clientareadetails.css?v={$myTheme.version|default:'1.0'}">

<script>
(function () {
    var b = document.body;
    if (!b) return;
    b.setAttribute('data-data', '{$dashIsEmpty}');
})();
</script>

<header class="page-header">
    <h1>{$LANG.accountdetails|default:'Account Details'}</h1>
    <p class="page-subtitle">{$LANG.accountdetailssub|default:'Your personal information, billing address and email preferences.'}</p>
</header>

<div class="when-full"><div class="acct-split">

    {* ══ LEFT: Account sub-nav ══ *}
    <aside class="card subnav-card">
        <div class="subnav-heading">{$LANG.accounttab|default:'Account'}</div>
        <a href="{$WEB_ROOT}/clientarea.php?action=details" class="subnav-item active">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M20 21v-2a4 4 0 00-4-4H8a4 4 0 00-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>
            {$LANG.accountdetails|default:'Account Details'}
        </a>
        <a href="{$WEB_ROOT}/account.php?action=usermanagement" class="subnav-item">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M17 21v-2a4 4 0 00-4-4H5a4 4 0 00-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 00-3-3.87"/><path d="M16 3.13a4 4 0 010 7.75"/></svg>
            {$LANG.usermanagement|default:'User Management'}
        </a>
        <a href="{$WEB_ROOT}/account.php?action=paymentmethods" class="subnav-item">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><rect x="1" y="4" width="22" height="16" rx="2"/><line x1="1" y1="10" x2="23" y2="10"/></svg>
            {$LANG.paymentmethods|default:'Payment Methods'}
        </a>
        <a href="{$WEB_ROOT}/clientarea.php?action=contacts" class="subnav-item">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M20 21v-2a4 4 0 00-4-4H8a4 4 0 00-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>
            {$LANG.contacts|default:'Contacts'}
        </a>
        <a href="{$WEB_ROOT}/clientarea.php?action=emails" class="subnav-item">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z"/><polyline points="22,6 12,13 2,6"/></svg>
            {$LANG.emailhistory|default:'Email History'}
        </a>
    </aside>

    {* ══ RIGHT: form area ══ *}
    <form action="{$WEB_ROOT}/clientarea.php?action=details" method="post">
        <input type="hidden" name="token" value="{$token|default:''|escape}">
        <input type="hidden" name="save" value="true">

        {* Personal Information *}
        <div class="card">
            <div class="card-header"><h2 class="card-title">{$LANG.personalinformation|default:'Personal information'}</h2></div>
            <div class="card-body">
                <div class="form-row">
                    <div class="form-group">
                        <label class="form-label" for="ad-first">{$LANG.clientareafirstname|default:'First name'}</label>
                        <input type="text" class="form-input" id="ad-first" name="firstname" value="{$clientsdetails.firstname|default:''|escape}" autocomplete="given-name" required>
                    </div>
                    <div class="form-group">
                        <label class="form-label" for="ad-last">{$LANG.clientarealastname|default:'Last name'}</label>
                        <input type="text" class="form-input" id="ad-last" name="lastname" value="{$clientsdetails.lastname|default:''|escape}" autocomplete="family-name" required>
                    </div>
                </div>
                <div class="form-row">
                    <div class="form-group">
                        <label class="form-label" for="ad-email">{$LANG.clientareaemail|default:'Email address'}</label>
                        <input type="email" class="form-input" id="ad-email" name="email" value="{$clientsdetails.email|default:''|escape}" autocomplete="email" required>
                    </div>
                    <div class="form-group">
                        <label class="form-label" for="ad-phone">{$LANG.clientareaphonenumber|default:'Phone number'}</label>
                        <input type="tel" class="form-input" id="ad-phone" name="phonenumber" value="{$clientsdetails.phonenumber|default:''|escape}" autocomplete="tel">
                    </div>
                </div>
                {if isset($languages) && $languages|count > 0}
                <div class="form-group">
                    <label class="form-label" for="ad-lang">{$LANG.clientarealanguage|default:'Language'}</label>
                    <select class="form-select" id="ad-lang" name="language">
                        {foreach $languages as $lang}
                        <option value="{$lang|escape}"{if isset($clientsdetails.language) && $clientsdetails.language == $lang} selected{/if}>{$lang|escape|capitalize}</option>
                        {/foreach}
                    </select>
                </div>
                {/if}
            </div>
        </div>

        {* Billing Address *}
        <div class="card">
            <div class="card-header"><h2 class="card-title">{$LANG.billingaddress|default:'Billing address'}</h2></div>
            <div class="card-body">
                <div class="form-row">
                    <div class="form-group">
                        <label class="form-label" for="ad-company">{$LANG.clientareacompanyname|default:'Company name'} <span style="opacity:0.5; font-weight:400;">({$LANG.optional|default:'optional'})</span></label>
                        <input type="text" class="form-input" id="ad-company" name="companyname" value="{$clientsdetails.companyname|default:''|escape}" autocomplete="organization">
                    </div>
                    <div class="form-group">
                        <label class="form-label" for="ad-addr1">{$LANG.clientareaaddress1|default:'Address line 1'}</label>
                        <input type="text" class="form-input" id="ad-addr1" name="address1" value="{$clientsdetails.address1|default:''|escape}" autocomplete="address-line1" required>
                    </div>
                </div>
                <div class="form-row">
                    <div class="form-group">
                        <label class="form-label" for="ad-addr2">{$LANG.clientareaaddress2|default:'Address line 2'} <span style="opacity:0.5; font-weight:400;">({$LANG.optional|default:'optional'})</span></label>
                        <input type="text" class="form-input" id="ad-addr2" name="address2" value="{$clientsdetails.address2|default:''|escape}" autocomplete="address-line2">
                    </div>
                    <div class="form-group">
                        <label class="form-label" for="ad-city">{$LANG.clientareacity|default:'City'}</label>
                        <input type="text" class="form-input" id="ad-city" name="city" value="{$clientsdetails.city|default:''|escape}" autocomplete="address-level2" required>
                    </div>
                </div>
                <div class="form-row">
                    <div class="form-group">
                        <label class="form-label" for="ad-country">{$LANG.clientareacountry|default:'Country'}</label>
                        <select class="form-select" id="ad-country" name="country" autocomplete="country">
                            {if isset($countries) && $countries|count > 0}
                                {foreach $countries as $code => $name}
                                <option value="{$code|escape}"{if isset($clientsdetails.country) && $clientsdetails.country == $code} selected{/if}>{$name|escape}</option>
                                {/foreach}
                            {else}
                                <option value="{$clientsdetails.country|default:''|escape}" selected>{$clientsdetails.country|default:''|escape}</option>
                            {/if}
                        </select>
                    </div>
                    <div class="form-group">
                        <label class="form-label" for="ad-state">{$LANG.clientareastate|default:'State / Region'}</label>
                        <input type="text" class="form-input" id="ad-state" name="state" value="{$clientsdetails.state|default:''|escape}" autocomplete="address-level1">
                    </div>
                </div>
                <div class="form-row">
                    <div class="form-group">
                        <label class="form-label" for="ad-zip">{$LANG.clientareapostcode|default:'Zip / Postal code'}</label>
                        <input type="text" class="form-input" id="ad-zip" name="postcode" value="{$clientsdetails.postcode|default:''|escape}" autocomplete="postal-code" required>
                    </div>
                    <div class="form-group"></div>
                </div>
            </div>
        </div>

        {* Email Preferences *}
        <div class="card">
            <div class="card-header"><h2 class="card-title">{$LANG.emailpreferences|default:'Email preferences'}</h2></div>
            <div class="card-body">
                <div class="pref-row">
                    <input type="checkbox" id="ad-pref-general" name="emailoptout_general" value="on"{if !$clientsdetails.emailoptout} checked{/if}>
                    <label for="ad-pref-general"><strong>{$LANG.generalemails|default:'General emails'}</strong><br><span class="pref-sub">{$LANG.generalemailssub|default:'All account-related emails and password reminders'}</span></label>
                </div>
                <div class="pref-row">
                    <input type="checkbox" id="ad-pref-invoice" name="emailoptout_invoice" value="on" checked>
                    <label for="ad-pref-invoice"><strong>{$LANG.invoiceemails|default:'Invoice emails'}</strong><br><span class="pref-sub">{$LANG.invoiceemailssub|default:'New invoices, reminders, and overdue notices'}</span></label>
                </div>
                <div class="pref-row">
                    <input type="checkbox" id="ad-pref-support" name="emailoptout_support" value="on" checked>
                    <label for="ad-pref-support"><strong>{$LANG.supportemails|default:'Support emails'}</strong><br><span class="pref-sub">{$LANG.supportemailssub|default:'Receive a CC of all support ticket communications'}</span></label>
                </div>
                <div class="pref-row">
                    <input type="checkbox" id="ad-pref-product" name="emailoptout_product" value="on" checked>
                    <label for="ad-pref-product"><strong>{$LANG.productemails|default:'Product emails'}</strong><br><span class="pref-sub">{$LANG.productemailssub|default:'Welcome emails, suspensions and other lifecycle notifications'}</span></label>
                </div>
                <div class="pref-row">
                    <input type="checkbox" id="ad-pref-domain" name="emailoptout_domain" value="on" checked>
                    <label for="ad-pref-domain"><strong>{$LANG.domainemails|default:'Domain emails'}</strong><br><span class="pref-sub">{$LANG.domainemailssub|default:'Registration, transfer confirmations and renewal notices'}</span></label>
                </div>
                <div class="pref-row">
                    <input type="checkbox" id="ad-pref-affiliate" name="emailoptout_affiliate" value="on">
                    <label for="ad-pref-affiliate"><strong>{$LANG.affiliateemails|default:'Affiliate emails'}</strong><br><span class="pref-sub">{$LANG.affiliateemailssub|default:'Notifications about your affiliate account and payouts'}</span></label>
                </div>
            </div>
        </div>

        {* Footer actions *}
        <div class="form-footer">
            <a href="{$WEB_ROOT}/clientarea.php" class="btn-secondary">{$LANG.cancelchanges|default:'Cancel changes'}</a>
            <button type="submit" class="btn-primary">{$LANG.savechanges|default:'Save changes'}</button>
        </div>
    </form>
</div></div>

<div class="when-empty" style="text-align:center;padding:60px 24px;background:var(--color-surface);border:1px solid var(--color-border);border-radius:14px;">
    <div style="width:56px;height:56px;border-radius:50%;background:var(--color-bg);display:inline-flex;align-items:center;justify-content:center;margin-bottom:16px;color:var(--color-text-tertiary);">
        <svg viewBox="0 0 24 24" width="22" height="22" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round">
            <circle cx="12" cy="12" r="10"/><path d="M20 21v-1a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v1"/><circle cx="12" cy="10" r="3"/>
        </svg>
    </div>
    <p style="font-size:17px;font-weight:600;color:var(--color-text-primary);margin:0 0 6px;">{$LANG.profilenotsetup|default:'Profile not yet set up'}</p>
    <p style="font-size:14px;color:var(--color-text-secondary);margin:0 0 20px;max-width:380px;margin-left:auto;margin-right:auto;line-height:1.5;">{$LANG.profilenotsetupsub|default:'Complete your account profile to keep your billing and contact info up to date.'}</p>
    <a href="{$WEB_ROOT}/clientarea.php?action=details" class="btn-primary">{$LANG.setupprofile|default:'Set up profile'}</a>
</div>
