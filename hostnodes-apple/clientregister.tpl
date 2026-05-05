{* =========================================================================
   clientregister.tpl — new account registration form.
   Public page; renders inside <div class="auth-layout-body"> from header.tpl.
   ========================================================================= *}
{if in_array('state', $optionalFields)}
    <script>var statesTab = 10, stateNotRequired = true;</script>
{/if}
<script src="{$BASE_PATH_JS}/StatesDropdown.js"></script>
<script src="{$BASE_PATH_JS}/PasswordStrength.js"></script>
<script>
    window.langPasswordStrength = "{lang key='pwstrength'}";
    window.langPasswordWeak = "{lang key='pwstrengthweak'}";
    window.langPasswordModerate = "{lang key='pwstrengthmoderate'}";
    window.langPasswordStrong = "{lang key='pwstrengthstrong'}";
    jQuery(document).ready(function() {
        jQuery("#inputNewPassword1").keyup(registerFormPasswordStrengthFeedback);
    });
</script>

<div class="auth-container auth-container-wide">
    <div class="auth-card auth-card-wide">
        <h1 class="auth-title">{lang key='clientregistertitle'}</h1>
        <p class="auth-subtitle">{lang key='userLogin.registerDescription'}</p>

        {if $registrationDisabled}
            {include file="$template/includes/alert.tpl" type="error" msg="{lang key='registerCreateAccount'}"|cat:' <strong><a href="'|cat:"$WEB_ROOT"|cat:'/cart.php" class="callout-link">'|cat:"{lang key='registerCreateAccountOrder'}"|cat:'</a></strong>'}
        {/if}

        {if $errormessage}
            {include file="$template/includes/alert.tpl" type="error" errorshtml=$errormessage}
        {/if}

        {if !$registrationDisabled}
            <div id="registration">
                <form method="post" class="using-password-strength auth-form" action="{$smarty.server.PHP_SELF}" role="form" name="orderfrm" id="frmCheckout">
                    <input type="hidden" name="register" value="true">

                    <div id="containerNewUserSignup">
                        {include file="$template/includes/linkedaccounts.tpl" linkContext="registration"}

                        <div class="card">
                            <div class="card-header"><h3 class="card-title">{lang key='orderForm.personalInformation'}</h3></div>
                            <div class="card-body">
                                <div class="form-row">
                                    <div class="form-group">
                                        <label for="inputFirstName" class="form-label">{lang key='orderForm.firstName'}</label>
                                        <input type="text" name="firstname" id="inputFirstName" class="form-input" placeholder="{lang key='orderForm.firstName'}" value="{$clientfirstname}" {if !in_array('firstname', $optionalFields)}required{/if} autofocus>
                                    </div>
                                    <div class="form-group">
                                        <label for="inputLastName" class="form-label">{lang key='orderForm.lastName'}</label>
                                        <input type="text" name="lastname" id="inputLastName" class="form-input" placeholder="{lang key='orderForm.lastName'}" value="{$clientlastname}" {if !in_array('lastname', $optionalFields)}required{/if}>
                                    </div>
                                </div>
                                <div class="form-row">
                                    <div class="form-group">
                                        <label for="inputEmail" class="form-label">{lang key='orderForm.emailAddress'}</label>
                                        <input type="email" name="email" id="inputEmail" class="form-input" placeholder="name@example.com" value="{$clientemail}" required>
                                    </div>
                                    <div class="form-group">
                                        <label for="inputPhone" class="form-label">{lang key='orderForm.phoneNumber'}</label>
                                        <input type="tel" name="phonenumber" id="inputPhone" class="form-input" placeholder="+1 (555) 000-0000" value="{$clientphonenumber}">
                                    </div>
                                </div>
                            </div>
                        </div>

                        <div class="card">
                            <div class="card-header"><h3 class="card-title">{lang key='orderForm.billingAddress'}</h3></div>
                            <div class="card-body">
                                <div class="form-group">
                                    <label for="inputCompanyName" class="form-label">{lang key='orderForm.companyName'} <span class="form-label-optional">({lang key='orderForm.optional'})</span></label>
                                    <input type="text" name="companyname" id="inputCompanyName" class="form-input" value="{$clientcompanyname}">
                                </div>
                                <div class="form-group">
                                    <label for="inputAddress1" class="form-label">{lang key='orderForm.streetAddress'}</label>
                                    <input type="text" name="address1" id="inputAddress1" class="form-input" value="{$clientaddress1}" {if !in_array('address1', $optionalFields)}required{/if}>
                                </div>
                                <div class="form-group">
                                    <label for="inputAddress2" class="form-label">{lang key='orderForm.streetAddress2'} <span class="form-label-optional">({lang key='orderForm.optional'})</span></label>
                                    <input type="text" name="address2" id="inputAddress2" class="form-input" value="{$clientaddress2}">
                                </div>
                                <div class="form-row">
                                    <div class="form-group">
                                        <label for="inputCity" class="form-label">{lang key='orderForm.city'}</label>
                                        <input type="text" name="city" id="inputCity" class="form-input" value="{$clientcity}" {if !in_array('city', $optionalFields)}required{/if}>
                                    </div>
                                    <div class="form-group">
                                        <label for="state" class="form-label">{lang key='orderForm.state'}</label>
                                        <input type="text" name="state" id="state" class="form-input" value="{$clientstate}" {if !in_array('state', $optionalFields)}required{/if}>
                                    </div>
                                </div>
                                <div class="form-row">
                                    <div class="form-group">
                                        <label for="inputPostcode" class="form-label">{lang key='orderForm.postcode'}</label>
                                        <input type="text" name="postcode" id="inputPostcode" class="form-input" value="{$clientpostcode}" {if !in_array('postcode', $optionalFields)}required{/if}>
                                    </div>
                                    <div class="form-group">
                                        <label for="inputCountry" class="form-label">{lang key='orderForm.country'}</label>
                                        <select name="country" id="inputCountry" class="form-input">
                                            {foreach $clientcountries as $countryCode => $countryName}
                                                <option value="{$countryCode}"{if (!$clientcountry && $countryCode eq $defaultCountry) || ($countryCode eq $clientcountry)} selected{/if}>{$countryName}</option>
                                            {/foreach}
                                        </select>
                                    </div>
                                </div>
                                {if $showTaxIdField}
                                    <div class="form-group">
                                        <label for="inputTaxId" class="form-label">{$taxLabel} <span class="form-label-optional">({lang key='orderForm.optional'})</span></label>
                                        <input type="text" name="tax_id" id="inputTaxId" class="form-input" value="{$clientTaxId}">
                                    </div>
                                {/if}
                            </div>
                        </div>

                        {if $customfields || $currencies}
                            <div class="card">
                                <div class="card-header"><h3 class="card-title">{lang key='orderadditionalrequiredinfo'}</h3></div>
                                <div class="card-body">
                                    <div class="form-row">
                                        {if $customfields}
                                            {foreach $customfields as $customfield}
                                                <div class="form-group">
                                                    <label for="customfield{$customfield.id}" class="form-label">{$customfield.name} {$customfield.required}</label>
                                                    {$customfield.input}
                                                    {if $customfield.description}<span class="form-hint">{$customfield.description}</span>{/if}
                                                </div>
                                            {/foreach}
                                        {/if}
                                        {if $currencies}
                                            <div class="form-group">
                                                <label for="inputCurrency" class="form-label">{lang key='currency'}</label>
                                                <select id="inputCurrency" name="currency" class="form-input">
                                                    {foreach $currencies as $curr}
                                                        <option value="{$curr.id}"{if !$smarty.post.currency && $curr.default || $smarty.post.currency eq $curr.id} selected{/if}>{$curr.code}</option>
                                                    {/foreach}
                                                </select>
                                            </div>
                                        {/if}
                                    </div>
                                </div>
                            </div>
                        {/if}

                        {if isset($accountDetailsExtraFields) && !empty($accountDetailsExtraFields)}
                            <div class="card">
                                <div class="card-header"><h3 class="card-title">{lang key='orderForm.additionalInformation'}</h3></div>
                                <div class="card-body">
                                    <div class="form-row">
                                        {foreach $accountDetailsExtraFields as $field}
                                            <div class="form-group">{$field.input}</div>
                                        {/foreach}
                                    </div>
                                </div>
                            </div>
                        {/if}
                    </div>

                    <div id="containerNewUserSecurity"{if $remote_auth_prelinked && !$securityquestions} class="w-hidden"{/if}>
                        <div class="card">
                            <div class="card-header"><h3 class="card-title">{lang key='orderForm.accountSecurity'}</h3></div>
                            <div class="card-body">
                                <div id="containerPassword" class="form-row{if $remote_auth_prelinked && $securityquestions} w-hidden{/if}">
                                    <div class="callout info w-hidden" id="passwdFeedback"></div>
                                    <div class="form-group">
                                        <label for="inputNewPassword1" class="form-label">{lang key='clientareapassword'}</label>
                                        <input type="password" name="password" id="inputNewPassword1" class="form-input" data-error-threshold="{$pwStrengthErrorThreshold}" data-warning-threshold="{$pwStrengthWarningThreshold}" autocomplete="off"{if $remote_auth_prelinked} value="{$password}"{/if}>
                                    </div>
                                    <div class="form-group">
                                        <label for="inputNewPassword2" class="form-label">{lang key='clientareaconfirmpassword'}</label>
                                        <input type="password" name="password2" id="inputNewPassword2" class="form-input" autocomplete="off"{if $remote_auth_prelinked} value="{$password}"{/if}>
                                    </div>
                                </div>
                                <div class="form-group">
                                    <button type="button" class="btn btn-secondary btn-sm generate-password" data-targetfields="inputNewPassword1,inputNewPassword2">
                                        {lang key='generatePassword.btnLabel'}
                                    </button>
                                </div>
                                <div class="password-strength-meter">
                                    <div class="progress pw-strength-bar">
                                        <div class="progress-bar" role="progressbar" aria-valuenow="0" aria-valuemin="0" aria-valuemax="100" id="passwordStrengthMeterBar"></div>
                                    </div>
                                    <p class="form-hint" id="passwordStrengthTextLabel">{lang key='pwstrength'}: {lang key='pwstrengthenter'}</p>
                                </div>

                                {if $securityquestions}
                                    <div class="form-row">
                                        <div class="form-group">
                                            <label for="inputSecurityQId" class="form-label">{lang key='clientareasecurityquestion'}</label>
                                            <select name="securityqid" id="inputSecurityQId" class="form-input">
                                                <option value="">{lang key='clientareasecurityquestion'}</option>
                                                {foreach $securityquestions as $question}
                                                    <option value="{$question.id}"{if $question.id eq $securityqid} selected{/if}>{$question.question}</option>
                                                {/foreach}
                                            </select>
                                        </div>
                                        <div class="form-group">
                                            <label for="inputSecurityQAns" class="form-label">{lang key='clientareasecurityanswer'}</label>
                                            <input type="password" name="securityqans" id="inputSecurityQAns" class="form-input" autocomplete="off">
                                        </div>
                                    </div>
                                {/if}
                            </div>
                        </div>
                    </div>

                    {if $showMarketingEmailOptIn}
                        <div class="card">
                            <div class="card-header"><h3 class="card-title">{lang key='emailMarketing.joinOurMailingList'}</h3></div>
                            <div class="card-body">
                                <p>{$marketingEmailOptInMessage}</p>
                                <label class="checkbox-label">
                                    <input type="checkbox" name="marketingoptin" value="1"{if $marketingEmailOptIn} checked{/if} class="form-checkbox">
                                    <span>{lang key='yes'}</span>
                                </label>
                            </div>
                        </div>
                    {/if}

                    {include file="$template/includes/captcha.tpl"}

                    {if $accepttos}
                        <div class="form-row-inline">
                            <label class="checkbox-label">
                                <input type="checkbox" name="accepttos" class="form-checkbox accepttos">
                                <span>{lang key='ordertosagreement'} <a href="{$tosurl}" target="_blank" class="auth-link">{lang key='ordertos'}</a></span>
                            </label>
                        </div>
                    {/if}

                    <button type="submit" class="btn btn-primary btn-lg btn-full{$captcha->getButtonClass($captchaForm)}">
                        {lang key='clientregistertitle'}
                    </button>
                </form>
            </div>
        {/if}

        <div class="auth-footer">
            <small>{lang key='userLogin.alreadyHaveAccount'}</small>
            <a href="{$WEB_ROOT}/login.php" class="auth-link">{lang key='loginbutton'}</a>
        </div>
    </div>
</div>
