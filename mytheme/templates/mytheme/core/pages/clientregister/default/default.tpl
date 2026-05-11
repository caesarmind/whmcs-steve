{* Hostnodes — Create Account (Apple-style).

   WHMCS standard variables on /register:
     $clientsdetails  — sticky form values on validation re-render
     $countries       — country code => name array
     $states          — state code => name array
     $languages       — list of available locale codes
     $errormessage    — array/string of validation errors
     $loggedin        — bool (we redirect to clientarea if true)
     $captcha         — captcha widget if enabled
     $marketingoptin  — bool, default for the marketing checkbox
*}

<link rel="stylesheet" href="{$WEB_ROOT}/templates/{$template}/assets/css/pages/clientregister.css?v={$myTheme.version|default:'1.0'}">

<div class="cr-wrap">
    <div class="card cr-card">
        <h1 class="cr-title">{$LANG.createaccount|default:'Create your account'}</h1>
        <p class="cr-sub">{$LANG.createaccountsub|default:'Already have an account?'} <a href="{$WEB_ROOT}/login">{$LANG.signin|default:'Sign in'}</a></p>

        {if isset($errormessage) && $errormessage}
        <div class="cr-error">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>
            <div>{if is_array($errormessage)}{foreach $errormessage as $err}<div>{$err|strip_tags|escape}</div>{/foreach}{else}{$errormessage|strip_tags|escape}{/if}</div>
        </div>
        {/if}

        <form method="post" action="{$WEB_ROOT}/register.php" class="cr-form" id="frmRegister">
            <input type="hidden" name="newcustomer" value="1">

            <section class="cr-section">
                <h2 class="cr-section-title">{$LANG.personalinformation|default:'Personal information'}</h2>
                <div class="form-row">
                    <div class="form-group">
                        <label class="form-label" for="cr-first">{$LANG.clientareafirstname|default:'First name'}</label>
                        <input type="text" class="form-input" id="cr-first" name="firstname" value="{$clientsdetails.firstname|default:''|escape}" autocomplete="given-name" required>
                    </div>
                    <div class="form-group">
                        <label class="form-label" for="cr-last">{$LANG.clientarealastname|default:'Last name'}</label>
                        <input type="text" class="form-input" id="cr-last" name="lastname" value="{$clientsdetails.lastname|default:''|escape}" autocomplete="family-name" required>
                    </div>
                </div>
                <div class="form-row">
                    <div class="form-group">
                        <label class="form-label" for="cr-email">{$LANG.clientareaemail|default:'Email address'}</label>
                        <input type="email" class="form-input" id="cr-email" name="email" value="{$clientsdetails.email|default:''|escape}" autocomplete="email" required>
                    </div>
                    <div class="form-group">
                        <label class="form-label" for="cr-phone">{$LANG.clientareaphonenumber|default:'Phone number'}</label>
                        <input type="tel" class="form-input" id="cr-phone" name="phonenumber" value="{$clientsdetails.phonenumber|default:''|escape}" autocomplete="tel">
                    </div>
                </div>
                <div class="form-group">
                    <label class="form-label" for="cr-company">{$LANG.clientareacompanyname|default:'Company name'} <span class="cr-opt">({$LANG.optional|default:'optional'})</span></label>
                    <input type="text" class="form-input" id="cr-company" name="companyname" value="{$clientsdetails.companyname|default:''|escape}" autocomplete="organization">
                </div>
            </section>

            <section class="cr-section">
                <h2 class="cr-section-title">{$LANG.billingaddress|default:'Billing address'}</h2>
                <div class="form-group">
                    <label class="form-label" for="cr-addr1">{$LANG.clientareaaddress1|default:'Address line 1'}</label>
                    <input type="text" class="form-input" id="cr-addr1" name="address1" value="{$clientsdetails.address1|default:''|escape}" autocomplete="address-line1" required>
                </div>
                <div class="form-row">
                    <div class="form-group">
                        <label class="form-label" for="cr-city">{$LANG.clientareacity|default:'City'}</label>
                        <input type="text" class="form-input" id="cr-city" name="city" value="{$clientsdetails.city|default:''|escape}" autocomplete="address-level2" required>
                    </div>
                    <div class="form-group">
                        <label class="form-label" for="cr-state">{$LANG.clientareastate|default:'State / region'}</label>
                        <input type="text" class="form-input" id="cr-state" name="state" value="{$clientsdetails.state|default:''|escape}" autocomplete="address-level1">
                    </div>
                </div>
                <div class="form-row">
                    <div class="form-group">
                        <label class="form-label" for="cr-zip">{$LANG.clientareapostcode|default:'Zip / postal code'}</label>
                        <input type="text" class="form-input" id="cr-zip" name="postcode" value="{$clientsdetails.postcode|default:''|escape}" autocomplete="postal-code" required>
                    </div>
                    <div class="form-group">
                        <label class="form-label" for="cr-country">{$LANG.clientareacountry|default:'Country'}</label>
                        <select class="form-select" id="cr-country" name="country" autocomplete="country" required>
                            {if isset($countries) && $countries|@count > 0}
                                {foreach $countries as $code => $name}
                                <option value="{$code|escape}"{if isset($clientsdetails.country) && $clientsdetails.country == $code} selected{/if}>{$name|escape}</option>
                                {/foreach}
                            {/if}
                        </select>
                    </div>
                </div>
            </section>

            <section class="cr-section">
                <h2 class="cr-section-title">{$LANG.accountsecurity|default:'Account security'}</h2>
                <div class="form-row">
                    <div class="form-group">
                        <label class="form-label" for="cr-pw1">{$LANG.password|default:'Password'}</label>
                        <input type="password" class="form-input" id="cr-pw1" name="password" autocomplete="new-password" required>
                    </div>
                    <div class="form-group">
                        <label class="form-label" for="cr-pw2">{$LANG.confirmpassword|default:'Confirm password'}</label>
                        <input type="password" class="form-input" id="cr-pw2" name="password2" autocomplete="new-password" required>
                    </div>
                </div>
            </section>

            {if isset($captcha) && $captcha}
            <section class="cr-section cr-captcha">{$captcha}</section>
            {/if}

            <div class="cr-marketing">
                <label class="cr-check">
                    <input type="checkbox" name="marketingoptin" value="1"{if isset($marketingoptin) && $marketingoptin} checked{/if}>
                    <span>{$LANG.marketingoptin|default:'Yes, send me product news and special offers occasionally.'}</span>
                </label>
            </div>

            <div class="cr-terms">
                <label class="cr-check">
                    <input type="checkbox" name="accepttos" value="on" required>
                    <span>{$LANG.iaccept|default:'I have read and agree to the'} <a href="{$WEB_ROOT}/terms-of-service" target="_blank">{$LANG.tos|default:'Terms of Service'}</a></span>
                </label>
            </div>

            <button type="submit" class="btn-primary cr-submit">{$LANG.registerbutton|default:'Create account'}</button>
        </form>
    </div>
</div>
