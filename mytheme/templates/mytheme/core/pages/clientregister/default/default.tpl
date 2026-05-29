{* Hostnodes — Create Account (Apple-style), wired to the native WHMCS
   register.php contract.

   Verified WHMCS 9 variables on /register (see WHMCS9 theme docs +
   stock nexus/lagom clientregister.tpl):
     $registrationDisabled  — bool; new-account creation is turned off
     $clientfirstname …     — flat sticky values, repopulated on re-render
     $clientcountries       — country code => name array (NOT $countries)
     $defaultCountry        — default country code for the dropdown
     $optionalFields        — array of field names the admin marked optional;
                              a field is REQUIRED when NOT in this array
     $showTaxIdField/$taxLabel/$clientTaxId — VAT/Tax ID field
     $customfields          — admin-defined custom client fields ($cf.input)
     $currencies            — currency picker (when multi-currency)
     $accountDetailsExtraFields — module-injected extra fields
     $securityquestions/$securityqid — optional security question
     $showMarketingEmailOptIn / $marketingEmailOptInMessage /
       $marketingEmailOptIn — native mailing-list opt-in (#2)
     $accepttos / $tosurl   — native Terms of Service acceptance (#3)
     $captcha (object)      — ->isEnabled(), ->isEnabledForForm($captchaForm),
                              ->getMarkup(), ->getPageJs(), ->getButtonClass()
                              The reCAPTCHA/hCaptcha api.js is auto-injected by
                              {$headoutput} in header.tpl, so getMarkup() +
                              getPageJs() are self-sufficient here (#4)
     $errormessage          — validation errors (HTML)

   The form posts back to PHP_SELF with register=true — the contract
   register.php actually listens for.
*}

{* Defensive: register.php always sets $optionalFields, but guarantee it's an
   array so the in_array() required-field checks below never error. *}
{if !isset($optionalFields) || !is_array($optionalFields)}{assign var=optionalFields value=[]}{/if}

{* Phone country-code chooser (flag + dial code), same library/version as the
   mytheme_cart checkout. Pinned to v18 because v19+ drops the auto-bundled utils.
   Loaded BEFORE our page CSS so the Apple overrides below win specificity ties. *}
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/intl-tel-input@18.5.3/build/css/intlTelInput.css">
<link rel="stylesheet" href="{$WEB_ROOT}/templates/{$template}/assets/css/pages/clientregister.css?v={$myTheme.version|default:'1.0'}">

<div class="cr-wrap">
    <div class="card cr-card">
        <h1 class="cr-title">{$LANG.createaccount|default:'Create your account'}</h1>
        <p class="cr-sub">{$LANG.createaccountsub|default:'Already have an account?'} <a href="{$WEB_ROOT}/login">{$LANG.signin|default:'Sign in'}</a></p>

        {if $registrationDisabled}
        {* Admin has disabled standalone registration — point users at the order form. *}
        <div class="cr-error" role="alert">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>
            <div>{$LANG.registerCreateAccount|default:'New accounts can only be created during checkout.'} <a href="{$WEB_ROOT}/cart.php">{$LANG.registerCreateAccountOrder|default:'Place an order'}</a></div>
        </div>
        {else}

        {if isset($errormessage) && $errormessage}
        <div class="cr-error" role="alert">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>
            <div>{if is_array($errormessage)}{foreach $errormessage as $err}<div>{$err|strip_tags|escape}</div>{/foreach}{else}{$errormessage|strip_tags|escape}{/if}</div>
        </div>
        {/if}

        <form method="post" action="{$smarty.server.PHP_SELF}" class="cr-form" id="frmRegister" role="form" name="orderfrm">
            <input type="hidden" name="register" value="true">

            <section class="cr-section">
                <h2 class="cr-section-title">{$LANG.personalinformation|default:'Personal information'}</h2>
                <div class="form-row">
                    <div class="form-group">
                        <label class="form-label" for="cr-first">{$LANG.clientareafirstname|default:'First name'}{if !in_array('firstname', $optionalFields)}<span class="cr-req" aria-hidden="true">*</span>{else} <span class="cr-opt">({$LANG.optional|default:'optional'})</span>{/if}</label>
                        <input type="text" class="form-input" id="cr-first" name="firstname" value="{$clientfirstname|default:''|escape}" autocomplete="given-name"{if !in_array('firstname', $optionalFields)} required{/if} autofocus>
                    </div>
                    <div class="form-group">
                        <label class="form-label" for="cr-last">{$LANG.clientarealastname|default:'Last name'}{if !in_array('lastname', $optionalFields)}<span class="cr-req" aria-hidden="true">*</span>{else} <span class="cr-opt">({$LANG.optional|default:'optional'})</span>{/if}</label>
                        <input type="text" class="form-input" id="cr-last" name="lastname" value="{$clientlastname|default:''|escape}" autocomplete="family-name"{if !in_array('lastname', $optionalFields)} required{/if}>
                    </div>
                </div>
                <div class="form-row">
                    <div class="form-group">
                        <label class="form-label" for="cr-email">{$LANG.clientareaemail|default:'Email address'}<span class="cr-req" aria-hidden="true">*</span></label>
                        <input type="email" class="form-input" id="cr-email" name="email" value="{$clientemail|default:''|escape}" autocomplete="email" required>
                    </div>
                    <div class="form-group">
                        <label class="form-label" for="cr-phone">{$LANG.clientareaphonenumber|default:'Phone number'}{if !in_array('phonenumber', $optionalFields)}<span class="cr-req" aria-hidden="true">*</span>{else} <span class="cr-opt">({$LANG.optional|default:'optional'})</span>{/if}</label>
                        <input type="tel" class="form-input" id="cr-phone" name="phonenumber" value="{$clientphonenumber|default:''|escape}" autocomplete="tel"{if !in_array('phonenumber', $optionalFields)} required{/if}>
                    </div>
                </div>
            </section>

            <section class="cr-section">
                <h2 class="cr-section-title">{$LANG.billingaddress|default:'Billing address'}</h2>
                <div class="form-group">
                    <label class="form-label" for="cr-company">{$LANG.clientareacompanyname|default:'Company name'} <span class="cr-opt">({$LANG.optional|default:'optional'})</span></label>
                    <input type="text" class="form-input" id="cr-company" name="companyname" value="{$clientcompanyname|default:''|escape}" autocomplete="organization">
                </div>
                {if $showTaxIdField}
                <div class="form-group">
                    <label class="form-label" for="cr-taxid">{$taxLabel|default:'Tax ID'} <span class="cr-opt">({$LANG.optional|default:'optional'})</span></label>
                    <input type="text" class="form-input" id="cr-taxid" name="tax_id" value="{$clientTaxId|default:''|escape}">
                </div>
                {/if}
                <div class="form-group">
                    <label class="form-label" for="cr-addr1">{$LANG.clientareaaddress1|default:'Address line 1'}{if !in_array('address1', $optionalFields)}<span class="cr-req" aria-hidden="true">*</span>{else} <span class="cr-opt">({$LANG.optional|default:'optional'})</span>{/if}</label>
                    <input type="text" class="form-input" id="cr-addr1" name="address1" value="{$clientaddress1|default:''|escape}" autocomplete="address-line1"{if !in_array('address1', $optionalFields)} required{/if}>
                </div>
                <div class="form-group">
                    <label class="form-label" for="cr-addr2">{$LANG.clientareaaddress2|default:'Address line 2'} <span class="cr-opt">({$LANG.optional|default:'optional'})</span></label>
                    <input type="text" class="form-input" id="cr-addr2" name="address2" value="{$clientaddress2|default:''|escape}" autocomplete="address-line2">
                </div>
                <div class="form-row">
                    <div class="form-group">
                        <label class="form-label" for="cr-city">{$LANG.clientareacity|default:'City'}{if !in_array('city', $optionalFields)}<span class="cr-req" aria-hidden="true">*</span>{else} <span class="cr-opt">({$LANG.optional|default:'optional'})</span>{/if}</label>
                        <input type="text" class="form-input" id="cr-city" name="city" value="{$clientcity|default:''|escape}" autocomplete="address-level2"{if !in_array('city', $optionalFields)} required{/if}>
                    </div>
                    <div class="form-group">
                        <label class="form-label" for="cr-state">{$LANG.clientareastate|default:'State / region'}{if !in_array('state', $optionalFields)}<span class="cr-req" aria-hidden="true">*</span>{else} <span class="cr-opt">({$LANG.optional|default:'optional'})</span>{/if}</label>
                        <input type="text" class="form-input" id="cr-state" name="state" value="{$clientstate|default:''|escape}" autocomplete="address-level1"{if !in_array('state', $optionalFields)} required{/if}>
                    </div>
                </div>
                <div class="form-row">
                    <div class="form-group">
                        <label class="form-label" for="cr-zip">{$LANG.clientareapostcode|default:'Zip / postal code'}{if !in_array('postcode', $optionalFields)}<span class="cr-req" aria-hidden="true">*</span>{else} <span class="cr-opt">({$LANG.optional|default:'optional'})</span>{/if}</label>
                        <input type="text" class="form-input" id="cr-zip" name="postcode" value="{$clientpostcode|default:''|escape}" autocomplete="postal-code"{if !in_array('postcode', $optionalFields)} required{/if}>
                    </div>
                    <div class="form-group">
                        <label class="form-label" for="cr-country">{$LANG.clientareacountry|default:'Country'}<span class="cr-req" aria-hidden="true">*</span></label>
                        <select class="form-select" id="cr-country" name="country" autocomplete="country" required>
                            {if isset($clientcountries) && $clientcountries|@count > 0}
                                {foreach $clientcountries as $code => $name}
                                <option value="{$code|escape}"{if (!$clientcountry && $code == $defaultCountry) || ($code == $clientcountry)} selected{/if}>{$name|escape}</option>
                                {/foreach}
                            {/if}
                        </select>
                    </div>
                </div>
            </section>

            {if (isset($customfields) && $customfields) || (isset($currencies) && $currencies)}
            <section class="cr-section">
                <h2 class="cr-section-title">{$LANG.orderadditionalrequiredinfo|default:'Additional information'}</h2>
                {if isset($customfields) && $customfields}
                    {foreach from=$customfields item=customfield}
                    <div class="form-group cr-customfield">
                        {if $customfield.type == 'tickbox'}
                        <label class="cr-check" for="customfield{$customfield.id}">
                            {$customfield.input}
                            <span>{$customfield.name|strip_tags}{if $customfield.required}<span class="cr-req" aria-hidden="true">*</span>{else} <span class="cr-opt">({$LANG.optional|default:'optional'})</span>{/if}</span>
                        </label>
                        {else}
                        <label class="form-label" for="customfield{$customfield.id}">{$customfield.name|strip_tags}{if $customfield.required}<span class="cr-req" aria-hidden="true">*</span>{else} <span class="cr-opt">({$LANG.optional|default:'optional'})</span>{/if}</label>
                        {$customfield.input}
                        {/if}
                        {if isset($customfield.description) && $customfield.description}<p class="cr-help">{$customfield.description|strip_tags}</p>{/if}
                    </div>
                    {/foreach}
                {/if}
                {if isset($currencies) && $currencies}
                <div class="form-group">
                    <label class="form-label" for="cr-currency">{$LANG.choosecurrency|default:'Preferred currency'}<span class="cr-req" aria-hidden="true">*</span></label>
                    <select class="form-select" id="cr-currency" name="currency">
                        {foreach from=$currencies item=curr}
                        <option value="{$curr.id}"{if (!$smarty.post.currency && $curr.default) || $smarty.post.currency == $curr.id} selected{/if}>{$curr.code}</option>
                        {/foreach}
                    </select>
                </div>
                {/if}
            </section>
            {/if}

            {if isset($accountDetailsExtraFields) && !empty($accountDetailsExtraFields)}
            <section class="cr-section">
                <h2 class="cr-section-title">{$LANG.orderForm.additionalInformation|default:'Additional information'}</h2>
                {foreach $accountDetailsExtraFields as $field}
                <div class="form-group cr-customfield">{$field.input}</div>
                {/foreach}
            </section>
            {/if}

            <section class="cr-section">
                <h2 class="cr-section-title">{$LANG.accountsecurity|default:'Account security'}</h2>
                <div class="form-row">
                    <div class="form-group">
                        <label class="form-label" for="cr-pw1">{$LANG.password|default:'Password'}<span class="cr-req" aria-hidden="true">*</span></label>
                        <input type="password" class="form-input" id="cr-pw1" name="password" autocomplete="new-password" required>
                    </div>
                    <div class="form-group">
                        <label class="form-label" for="cr-pw2">{$LANG.confirmpassword|default:'Confirm password'}<span class="cr-req" aria-hidden="true">*</span></label>
                        <input type="password" class="form-input" id="cr-pw2" name="password2" autocomplete="new-password" required>
                    </div>
                </div>
                {* Generate-password helper — opens the modal below, fills both password
                   fields and copies the result to the clipboard. Mirrors the mytheme_cart
                   flow but self-contained (no jQuery/Bootstrap/WHMCS JS on this page). *}
                <button type="button" class="cr-gen-pw generate-password" data-targetfields="cr-pw1,cr-pw2">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M3 12a9 9 0 0 1 9-9 9.75 9.75 0 0 1 6.74 2.74L21 8"/><path d="M21 3v5h-5"/><path d="M21 12a9 9 0 0 1-9 9 9.75 9.75 0 0 1-6.74-2.74L3 16"/><path d="M8 16H3v5"/></svg>
                    {$LANG.generatePassword.btnLabel|default:'Generate password'}
                </button>
                {if isset($securityquestions) && $securityquestions}
                <div class="form-row">
                    <div class="form-group">
                        <label class="form-label" for="cr-secq">{$LANG.clientareasecurityquestion|default:'Security question'}<span class="cr-req" aria-hidden="true">*</span></label>
                        <select class="form-select" id="cr-secq" name="securityqid">
                            <option value="">{$LANG.clientareasecurityquestion|default:'Select a security question'}</option>
                            {foreach $securityquestions as $question}
                            <option value="{$question.id}"{if $question.id == $securityqid} selected{/if}>{$question.question|escape}</option>
                            {/foreach}
                        </select>
                    </div>
                    <div class="form-group">
                        <label class="form-label" for="cr-seca">{$LANG.clientareasecurityanswer|default:'Answer'}<span class="cr-req" aria-hidden="true">*</span></label>
                        <input type="password" class="form-input" id="cr-seca" name="securityqans" autocomplete="off">
                    </div>
                </div>
                {/if}
            </section>

            {* #2 — native WHMCS mailing-list opt-in. Renders only when the admin
               has enabled it; text comes straight from the admin-configured
               $marketingEmailOptInMessage, default state from $marketingEmailOptIn.
               The native field name is marketingoptin; styled as an Apple toggle. *}
            {if $showMarketingEmailOptIn}
            <section class="cr-section cr-marketing">
                <h2 class="cr-section-title">{$LANG.emailMarketing.joinOurMailingList|default:'Join our mailing list'}</h2>
                {if isset($marketingEmailOptInMessage) && $marketingEmailOptInMessage}
                <p class="cr-marketing-msg">{$marketingEmailOptInMessage}</p>
                {/if}
                <label class="cr-switch">
                    <input type="checkbox" name="marketingoptin" value="1"{if $marketingEmailOptIn} checked{/if}>
                    <span class="cr-switch-track"><span class="cr-switch-thumb"></span></span>
                    <span class="cr-switch-text">{$LANG.emailMarketing.optInLabel|default:'Yes, send me product news and special offers'}</span>
                </label>
            </section>
            {/if}

            {* #4 — native captcha. Only renders when enabled for this form in the
               admin. getMarkup() emits the right widget (built-in image, reCAPTCHA
               or hCaptcha); the provider api.js is auto-injected by {$headoutput}
               in header.tpl, and getPageJs() wires up the callbacks. *}
            {if isset($captcha) && $captcha->isEnabled() && $captcha->isEnabledForForm($captchaForm)}
            <section class="cr-section cr-captcha">
                {$captcha->getMarkup()}
            </section>
            <script>{$captcha->getPageJs()}</script>
            {/if}

            {* #3 — native Terms of Service. Renders only when TOS acceptance is
               configured in the admin; the link target is the admin-set $tosurl. *}
            {if $accepttos}
            <div class="cr-terms">
                <label class="cr-check">
                    <input type="checkbox" name="accepttos" class="accepttos" required>
                    <span>{$LANG.ordertosagreement|default:'I have read and agree to the'} <a href="{$tosurl}" target="_blank" rel="noopener">{$LANG.ordertos|default:'Terms of Service'}</a><span class="cr-req" aria-hidden="true">*</span></span>
                </label>
            </div>
            {/if}

            <button type="submit" class="btn-primary cr-submit{if isset($captcha) && $captcha}{$captcha->getButtonClass($captchaForm)}{/if}">{$LANG.clientregistertitle|default:'Create account'}</button>
        </form>
        {/if}
    </div>
</div>

{if !$registrationDisabled}
{* ── Generate-password modal ──────────────────────────────────────────────
   Same UX as the mytheme_cart checkout modal (pick length → see the password →
   copy & insert), but fully self-contained: the register page does not load
   jQuery / Bootstrap / WHMCS scripts.min.js, so this uses plain DOM + the
   Web Crypto API. Opened by any .generate-password button via its
   data-targetfields list. *}
<div class="cr-gp-modal" id="crGpModal" hidden role="dialog" aria-modal="true" aria-labelledby="crGpTitle">
    <div class="cr-gp-backdrop" data-gp-close></div>
    <div class="cr-gp-dialog" role="document">
        <div class="cr-gp-head">
            <h3 class="cr-gp-title" id="crGpTitle">{$LANG.generatePassword.title|default:'Generate a password'}</h3>
            <button type="button" class="cr-gp-x" data-gp-close aria-label="{$LANG.close|default:'Close'}">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/></svg>
            </button>
        </div>
        <div class="cr-gp-body">
            <div class="cr-gp-field">
                <label for="crGpLength">{$LANG.generatePassword.pwLength|default:'Password length'}</label>
                <input type="number" min="8" max="64" step="1" value="16" id="crGpLength">
            </div>
            <div class="cr-gp-field">
                <label for="crGpOutput">{$LANG.generatePassword.generatedPw|default:'Generated password'}</label>
                <div class="cr-gp-output-row">
                    <input type="text" id="crGpOutput" readonly placeholder="—">
                    <button type="button" class="cr-gp-ghost" id="crGpRegen" title="{$LANG.generatePassword.generateNew|default:'Generate new'}">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M3 12a9 9 0 0 1 9-9 9.75 9.75 0 0 1 6.74 2.74L21 8"/><path d="M21 3v5h-5"/><path d="M21 12a9 9 0 0 1-9 9 9.75 9.75 0 0 1-6.74-2.74L3 16"/><path d="M8 16H3v5"/></svg>
                        <span>{$LANG.generatePassword.generateNew|default:'New'}</span>
                    </button>
                </div>
            </div>
        </div>
        <div class="cr-gp-foot">
            <button type="button" class="btn-secondary" data-gp-close>{$LANG.close|default:'Cancel'}</button>
            <button type="button" class="btn-primary" id="crGpInsert">{$LANG.generatePassword.copyAndInsert|default:'Copy &amp; insert'}</button>
        </div>
    </div>
</div>
<script>{literal}
(function () {
    var modal = document.getElementById('crGpModal');
    if (!modal) return;
    /* Re-parent to <body> so position:fixed is viewport-relative regardless of
       any transformed layout ancestor. */
    if (modal.parentNode !== document.body) document.body.appendChild(modal);

    var lengthEl = document.getElementById('crGpLength');
    var outEl = document.getElementById('crGpOutput');
    var insertBtn = document.getElementById('crGpInsert');
    var regenBtn = document.getElementById('crGpRegen');
    var targets = [];

    function randInts(n) {
        var c = window.crypto || window.msCrypto;
        if (c && c.getRandomValues) { var a = new Uint32Array(n); c.getRandomValues(a); return a; }
        var f = []; for (var i = 0; i < n; i++) { f.push(Math.floor(Math.random() * 4294967296)); } return f;
    }
    function generate(len) {
        len = parseInt(len, 10); if (isNaN(len)) { len = 16; }
        len = Math.max(8, Math.min(64, len));
        var lower = 'abcdefghijkmnopqrstuvwxyz', upper = 'ABCDEFGHJKLMNPQRSTUVWXYZ',
            digits = '23456789', symbols = '!@#$%^&*()-_=+';
        var all = lower + upper + digits + symbols;
        var r = randInts(len);
        /* Guarantee at least one of each class, then fill the rest. */
        var out = [
            lower.charAt(r[0] % lower.length),
            upper.charAt(r[1] % upper.length),
            digits.charAt(r[2] % digits.length),
            symbols.charAt(r[3] % symbols.length)
        ];
        for (var i = 4; i < len; i++) { out.push(all.charAt(r[i] % all.length)); }
        /* Fisher–Yates shuffle so the guaranteed chars aren't always up front. */
        var s = randInts(len);
        for (var j = out.length - 1; j > 0; j--) {
            var k = s[j] % (j + 1), tmp = out[j]; out[j] = out[k]; out[k] = tmp;
        }
        return out.join('');
    }
    function regenerate() { outEl.value = generate(lengthEl.value); }
    function open(fields) {
        targets = (fields || '').split(',').map(function (x) { return x.trim(); }).filter(Boolean);
        if (!lengthEl.value) { lengthEl.value = 16; }
        regenerate();
        modal.hidden = false;
        document.body.classList.add('cr-gp-open');
        if (insertBtn) { insertBtn.focus(); }
    }
    function close() {
        modal.hidden = true;
        outEl.value = '';
        document.body.classList.remove('cr-gp-open');
    }

    var triggers = document.querySelectorAll('.generate-password');
    for (var t = 0; t < triggers.length; t++) {
        triggers[t].addEventListener('click', function (e) {
            e.preventDefault();
            open(this.getAttribute('data-targetfields'));
        });
    }
    if (regenBtn) { regenBtn.addEventListener('click', regenerate); }
    if (lengthEl) { lengthEl.addEventListener('input', regenerate); }
    if (insertBtn) {
        insertBtn.addEventListener('click', function () {
            var pwd = outEl.value; if (!pwd) { return; }
            for (var i = 0; i < targets.length; i++) {
                var el = document.getElementById(targets[i]);
                if (el) { el.value = pwd; el.dispatchEvent(new Event('input', { bubbles: true })); }
            }
            if (navigator.clipboard && navigator.clipboard.writeText) {
                try { navigator.clipboard.writeText(pwd); } catch (e) {}
            }
            close();
        });
    }
    var closers = modal.querySelectorAll('[data-gp-close]');
    for (var c = 0; c < closers.length; c++) { closers[c].addEventListener('click', close); }
    document.addEventListener('keydown', function (e) {
        if ((e.key === 'Escape' || e.keyCode === 27) && !modal.hidden) { close(); }
    });
})();
{/literal}</script>

{* ── Phone country-code chooser ───────────────────────────────────────────
   intl-tel-input adds a flag + dial-code dropdown to the phone field, mirroring
   the mytheme_cart checkout. Wired with plain DOM (this page has no jQuery).
   dropdownContainer:document.body keeps the country list out of the card's
   overflow:hidden clip; on submit the value is normalised to E.164 for WHMCS. *}
<script src="https://cdn.jsdelivr.net/npm/intl-tel-input@18.5.3/build/js/intlTelInput.min.js"></script>
<script>{literal}
(function () {
    var phoneEl = document.getElementById('cr-phone');
    if (!phoneEl || typeof window.intlTelInput !== 'function') { return; }
    var countryEl = document.getElementById('cr-country');
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

    /* Keep the dial-code country in step with the billing country the user
       picks — but only while they haven't deliberately changed it in the
       iti dropdown. */
    var lastSynced = '';
    if (countryEl) {
        countryEl.addEventListener('change', function () {
            var c = (this.value || '').toLowerCase();
            if (!c || c.length !== 2) { return; }
            var current = iti.getSelectedCountryData().iso2;
            if (current === lastSynced || lastSynced === '') {
                iti.setCountry(c);
                lastSynced = c;
            }
        });
    }

    /* Normalise to the canonical E.164 number on submit (capture phase so we
       run before any other submit handler). */
    var form = document.getElementById('frmRegister');
    if (form) {
        form.addEventListener('submit', function () {
            if (typeof iti.getNumber === 'function') {
                var n = iti.getNumber();
                if (n) { phoneEl.value = n; }
            }
        }, true);
    }
})();
{/literal}</script>
{/if}
