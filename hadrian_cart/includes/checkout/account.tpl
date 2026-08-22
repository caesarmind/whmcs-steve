{*
 * Account section -- "who are you" half of the checkout form.
 *
 * Contains three mutually-exclusive containers that scripts.min.js
 * (and our toggle-hardening IIFE at the bottom of checkout.tpl) flip
 * between via .w-hidden + #btnAlreadyRegistered / #btnNewUserSignup:
 *
 *   #containerExistingAccountSelect -- shown only for logged-in users
 *      with multiple accounts; lets them pick which account this order
 *      bills to. Radio name="account_id".
 *
 *   #containerExistingUserSignin -- existing-customer login (email +
 *      password). #btnExistingLogin triggers WHMCS's AJAX login.
 *      #existingLoginMessage receives the error text on bad creds.
 *
 *   #containerNewUserSignup -- full new-user signup (Personal Info,
 *      Billing Address, optional Tax ID, optional custom fields).
 *
 * Plus $checkoutExtraFields rendered after the signup block.
 *
 * For GUEST users the existing-signin and new-signup containers are
 * wrapped in a .co-account-card with two .co-auth-tab buttons
 * (Create an account / I already have one). The tab clicks fall
 * through to the same showLogin/showSignup helpers in checkout.tpl's
 * IIFE, so the legacy w-hidden + inputCustType wiring stays intact.
 * Mirrors the v18 client-area checkout mockup, lines 1005-1085.
 *
 * Logged-in users skip the card entirely (the existing-account
 * picker covers their flow).
 *}

{* ─── Existing account picker (logged-in client) ─── *}
{if $custtype neq "new" && $loggedin}
    <div class="sub-heading">
        <span class="primary-bg-color">
            {lang key='switchAccount.title'}
        </span>
    </div>
    <div id="containerExistingAccountSelect" class="row account-select-container">
        {foreach $accounts as $account}
            <div class="col-sm-{if $accounts->count() == 1}12{else}6{/if}">
                <div class="account{if $selectedAccountId == $account->id} active{/if}">
                    <label class="radio-inline" for="account{$account->id}">
                        <input id="account{$account->id}" class="account-select{if $account->isClosed || $account->noPermission || $inExpressCheckout} disabled{/if}" type="radio" name="account_id" value="{$account->id}"{if $account->isClosed || $account->noPermission || $inExpressCheckout} disabled="disabled"{/if}{if $selectedAccountId == $account->id} checked="checked"{/if}>
                        <span class="address">
                            <strong>
                                {if $account->company}{$account->company}{else}{$account->fullName}{/if}
                            </strong>
                            {if $account->isClosed || $account->noPermission}
                                <span class="label label-default">
                                    {if $account->isClosed}
                                        {lang key='closed'}
                                    {else}
                                        {lang key='noPermission'}
                                    {/if}
                                </span>
                            {elseif $account->currencyCode}
                                <span class="label label-info">
                                    {$account->currencyCode}
                                </span>
                            {/if}
                            <br>
                            <span class="small">
                                {$account->address1}{if $account->address2}, {$account->address2}{/if}<br>
                                {if $account->city}{$account->city},{/if}
                                {if $account->state} {$account->state},{/if}
                                {if $account->postcode} {$account->postcode},{/if}
                                {$account->countryName}
                            </span>
                        </span>
                    </label>
                </div>
            </div>
        {/foreach}
        <div class="col-sm-12">
            <div class="account border-bottom{if !$selectedAccountId || !is_numeric($selectedAccountId)} active{/if}">
                <label class="radio-inline">
                    <input class="account-select" type="radio" name="account_id" value="new"{if !$selectedAccountId || !is_numeric($selectedAccountId)} checked="checked"{/if}{if $inExpressCheckout} disabled="disabled" class="disabled"{/if}>
                    {lang key='orderForm.createAccount'}
                </label>
            </div>
        </div>
    </div>
{/if}

{* ─── Account card (guest only): Create-account / Sign-in tabs ───
   Wraps WHMCS's #containerExistingUserSignin and #containerNewUserSignup
   in a rounded card with a two-tab switcher. The tab state mirrors
   the legacy .w-hidden toggle so scripts.min.js stays happy. Logged-in
   users skip the card entirely (the existing-account picker above
   already covers their flow). *}
{if !$loggedin}
{assign var=isExistingTab value=false}
{if $custtype eq "existing"}{assign var=isExistingTab value=true}{/if}
<div class="co-account-card">
    <div class="co-section-head">
        <h2 class="co-section-title">{$hadrianLang.cart.yourAccount}</h2>
    </div>
    <div class="co-auth-tabs" role="tablist">
        <button type="button" class="co-auth-tab{if !$isExistingTab} active{/if}" data-atab="create">
            {$LANG.orderForm.createAccount}
        </button>
        <button type="button" class="co-auth-tab{if $isExistingTab} active{/if}" data-atab="signin">
            {$LANG.orderForm.alreadyRegistered}
        </button>
    </div>

    {* Create-account panel wraps the full new-user signup form. *}
    <div class="co-auth-panel{if !$isExistingTab} is-active{/if}" data-apanel="create">
        <p class="co-auth-hint">{lang key='orderForm.enterPersonalDetails'}</p>
{/if}

{* ─── New-user signup (personal info + billing) ─── *}
<div id="containerNewUserSignup"
    {if
        $custtype === 'existing'
        || (is_numeric($selectedAccountId) && $selectedAccountId > 0)
        || (
            $loggedin
            && $selectedAccountId !== 'new'
            && $custtype !== 'add'
        )
    }
        class="w-hidden"
    {/if}
>

    <div{if $loggedin} class="w-hidden"{/if}>
        {include file="orderforms/$carttpl/linkedaccounts.tpl" linkContext="checkout-new"}
    </div>

    <div class="sub-heading">
        <span class="primary-bg-color">{$LANG.orderForm.personalInformation}</span>
    </div>

    <div class="row">
        <div class="col-sm-6">
            <div class="form-group prepend-icon">
                <label for="inputFirstName" class="field-icon">
                    <i class="fas fa-user"></i>
                </label>
                <input type="text" name="firstname" id="inputFirstName" class="field form-control" placeholder="{$LANG.orderForm.firstName}" value="{$clientsdetails.firstname}" autofocus>
            </div>
        </div>
        <div class="col-sm-6">
            <div class="form-group prepend-icon">
                <label for="inputLastName" class="field-icon">
                    <i class="fas fa-user"></i>
                </label>
                <input type="text" name="lastname" id="inputLastName" class="field form-control" placeholder="{$LANG.orderForm.lastName}" value="{$clientsdetails.lastname}">
            </div>
        </div>
        <div class="col-sm-6">
            <div class="form-group prepend-icon">
                <label for="inputEmail" class="field-icon">
                    <i class="fas fa-envelope"></i>
                </label>
                <input type="email" name="email" id="inputEmail" class="field form-control" placeholder="{$LANG.orderForm.emailAddress}" value="{$clientsdetails.email}">
            </div>
        </div>
        <div class="col-sm-6">
            <div class="form-group prepend-icon">
                <label for="inputPhone" class="field-icon">
                    <i class="fas fa-phone"></i>
                </label>
                <input type="tel" name="phonenumber" id="inputPhone" class="field form-control" placeholder="{$LANG.orderForm.phoneNumber}" value="{$clientsdetails.phonenumber}">
            </div>
        </div>
    </div>

    <div class="sub-heading">
        <span class="primary-bg-color">{$LANG.orderForm.billingAddress}</span>
    </div>

    <div class="row">
        <div class="col-sm-12">
            <div class="form-group prepend-icon">
                <label for="inputCompanyName" class="field-icon">
                    <i class="fas fa-building"></i>
                </label>
                <input type="text" name="companyname" id="inputCompanyName" class="field form-control" placeholder="{$LANG.orderForm.companyName} ({$LANG.orderForm.optional})" value="{$clientsdetails.companyname}">
            </div>
        </div>
        <div class="col-sm-12">
            <div class="form-group prepend-icon">
                <label for="inputAddress1" class="field-icon">
                    <i class="far fa-building"></i>
                </label>
                <input type="text" name="address1" id="inputAddress1" class="field form-control" placeholder="{$LANG.orderForm.streetAddress}" value="{$clientsdetails.address1}">
            </div>
        </div>
        <div class="col-sm-12">
            <div class="form-group prepend-icon">
                <label for="inputAddress2" class="field-icon">
                    <i class="fas fa-map-marker-alt"></i>
                </label>
                <input type="text" name="address2" id="inputAddress2" class="field form-control" placeholder="{$LANG.orderForm.streetAddress2}" value="{$clientsdetails.address2}">
            </div>
        </div>
        <div class="col-sm-4">
            <div class="form-group prepend-icon">
                <label for="inputCity" class="field-icon">
                    <i class="far fa-building"></i>
                </label>
                <input type="text" name="city" id="inputCity" class="field form-control" placeholder="{$LANG.orderForm.city}" value="{$clientsdetails.city}">
            </div>
        </div>
        <div class="col-sm-5">
            <div class="form-group prepend-icon">
                <label for="state" class="field-icon" id="inputStateIcon">
                    <i class="fas fa-map-signs"></i>
                </label>
                <label for="stateinput" class="field-icon" id="inputStateIcon">
                    <i class="fas fa-map-signs"></i>
                </label>
                <input type="text" name="state" id="inputState" class="field form-control" placeholder="{$LANG.orderForm.state}" value="{$clientsdetails.state}">
            </div>
        </div>
        <div class="col-sm-3">
            <div class="form-group prepend-icon">
                <label for="inputPostcode" class="field-icon">
                    <i class="fas fa-certificate"></i>
                </label>
                <input type="text" name="postcode" id="inputPostcode" class="field form-control" placeholder="{$LANG.orderForm.postcode}" value="{$clientsdetails.postcode}">
            </div>
        </div>
        <div class="col-sm-12">
            <div class="form-group prepend-icon">
                <label for="inputCountry" class="field-icon" id="inputCountryIcon">
                    <i class="fas fa-globe"></i>
                </label>
                <select name="country" id="inputCountry" class="field form-control">
                    {foreach $countries as $countrycode => $countrylabel}
                        <option value="{$countrycode}"{if (!$country && $countrycode == $defaultcountry) || $countrycode eq $country} selected{/if}>
                            {$countrylabel}
                        </option>
                    {/foreach}
                </select>
            </div>
        </div>
        {if $showTaxIdField}
            <div class="col-sm-12">
                <div class="form-group prepend-icon">
                    <label for="inputTaxId" class="field-icon">
                        <i class="fas fa-building"></i>
                    </label>
                    <input type="text" name="tax_id" id="inputTaxId" class="field form-control" placeholder="{$taxLabel}" value="{$clientsdetails.tax_id}" autocomplete="off">
                </div>
            </div>
        {/if}
    </div>

    {if $customfields}
        <div class="sub-heading">
            <span class="primary-bg-color">{$LANG.orderadditionalrequiredinfo}<br><i><small>{lang key='orderForm.requiredField'}</small></i></span>
        </div>
        <div class="field-container">
            <div class="row">
                {foreach $customfields as $customfield}
                    <div class="col-sm-6">
                        <div class="form-group">
                            <label for="customfield{$customfield.id}">{$customfield.name} {$customfield.required}</label>
                            {$customfield.input}
                            {if $customfield.description}
                                <span class="field-help-text">
                                    {$customfield.description}
                                </span>
                            {/if}
                        </div>
                    </div>
                {/foreach}
            </div>
        </div>
    {/if}

</div>

{if !$loggedin}
        {* Social signup placeholders (visual parity with the reference
           checkout). Real OAuth would need a WHMCS hook -- these are
           non-functional buttons for now. *}
        <div class="co-divider">{$hadrianLang.cart.orSignUpWith}</div>
        <div class="co-social">
            <button type="button" class="co-social-btn">
                <svg viewBox="0 0 24 24" fill="currentColor"><path d="M17.05 12.54c-.02-2.62 2.14-3.87 2.24-3.94-1.22-1.78-3.12-2.03-3.79-2.05-1.61-.16-3.15.95-3.97.95-.83 0-2.09-.93-3.45-.9-1.77.03-3.41 1.03-4.32 2.62-1.86 3.22-.47 7.97 1.32 10.58.88 1.28 1.92 2.71 3.28 2.66 1.32-.05 1.82-.85 3.42-.85 1.59 0 2.04.85 3.44.82 1.43-.02 2.32-1.29 3.18-2.58 1.01-1.48 1.42-2.92 1.44-3-.03-.01-2.77-1.06-2.79-4.21zM14.3 4.88c.72-.88 1.21-2.09 1.07-3.3-1.04.04-2.3.69-3.05 1.56-.67.77-1.25 2.01-1.09 3.19 1.16.09 2.35-.59 3.07-1.45z"/></svg>
                {$hadrianLang.cart.signupApple}
            </button>
            <button type="button" class="co-social-btn">
                <svg viewBox="0 0 24 24" fill="none"><path fill="#4285F4" d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z"/><path fill="#34A853" d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z"/><path fill="#FBBC05" d="M5.84 14.1c-.22-.66-.35-1.36-.35-2.1s.13-1.44.35-2.1V7.07H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.93l3.66-2.83z"/><path fill="#EA4335" d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z"/></svg>
                {$hadrianLang.cart.signupGoogle}
            </button>
        </div>
    </div>{* /.co-auth-panel[data-apanel=create] *}

    {* Sign-in panel: wraps the existing-login form. All input IDs
       (#inputLoginEmail, #inputLoginPassword, #btnExistingLogin,
       #existingLoginMessage) are preserved verbatim for scripts.min.js. *}
    <div class="co-auth-panel{if $isExistingTab} is-active{/if}" data-apanel="signin">
        <p class="co-auth-hint">{lang key='orderForm.existingCustomerLogin'}</p>
        <div id="containerExistingUserSignin"{if $custtype neq "existing"} class="w-hidden"{/if}>
            <div class="alert alert-danger w-hidden" id="existingLoginMessage">
            </div>

            <div class="row">
                <div class="col-sm-6">
                    <div class="form-group prepend-icon">
                        <label for="inputLoginEmail" class="field-icon">
                            <i class="fas fa-envelope"></i>
                        </label>
                        <input type="text" name="loginemail" id="inputLoginEmail" class="field form-control" placeholder="{$LANG.orderForm.emailAddress}" value="{$loginemail}">
                    </div>
                </div>
                <div class="col-sm-6">
                    <div class="form-group prepend-icon">
                        <div class="co-signin-row">
                            <label for="inputLoginPassword" class="field-icon">
                                <i class="fas fa-lock"></i>
                            </label>
                            <a href="{$WEB_ROOT}/pwreset.php" class="co-forgot-link">{$LANG.forgotpw}</a>
                        </div>
                        <input type="password" name="loginpassword" id="inputLoginPassword" class="field form-control" placeholder="{$LANG.clientareapassword}">
                    </div>
                </div>
            </div>

            <div class="text-center">
                <button type="button" id="btnExistingLogin" class="btn btn-primary btn-md">
                    <span id="existingLoginButton">{lang key='login'}</span>
                    <span id="existingLoginPleaseWait" class="w-hidden">{lang key='pleasewait'}</span>
                </button>
            </div>

            {include file="orderforms/$carttpl/linkedaccounts.tpl" linkContext="checkout-existing"}
        </div>
    </div>{* /.co-auth-panel[data-apanel=signin] *}
</div>{* /.co-account-card *}
{/if}

{if isset($checkoutExtraFields) && !empty($checkoutExtraFields)}
    <div class="sub-heading">
        <span class="primary-bg-color">{lang key='orderForm.additionalInformation'}</span>
    </div>
    <div class="row">
        {foreach $checkoutExtraFields as $field}
            <div class="col-sm-6">
                <div class="form-group">
                    <label for="{$field.name}">
                        {$field.label|escape}
                        {if $field.required}<span class="text-danger">*</span>{/if}
                    </label>
                    {$field.input}
                    {if $field.description}
                        <span class="field-help-text">{$field.description}</span>
                    {/if}
                </div>
            </div>
        {/foreach}
    </div>
{/if}
