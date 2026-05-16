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
 * Mirrors lagom2's /includes/viewcart/form-billing.tpl in spirit --
 * one partial owns the whole "account + billing fields" block.
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

{* ─── Existing customer login ─── *}
<div id="containerExistingUserSignin"{if $loggedin || $custtype neq "existing"} class="w-hidden"{/if}>
    <div class="sub-heading">
        <span class="primary-bg-color">{$LANG.orderForm.existingCustomerLogin}</span>
    </div>

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
                <label for="inputLoginPassword" class="field-icon">
                    <i class="fas fa-lock"></i>
                </label>
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

    {include file="orderforms/standard_cart/linkedaccounts.tpl" linkContext="checkout-existing"}
</div>

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
        {include file="orderforms/standard_cart/linkedaccounts.tpl" linkContext="checkout-new"}
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
