{* =========================================================================
   user-invite-accept.tpl — accept an account-manager invite.
   Shows either: side-by-side login/register (not logged in) or a single
   accept button (logged in), or a not-found error.
   ========================================================================= *}
<script src="{$BASE_PATH_JS}/PasswordStrength.js"></script>
<script>
    window.langPasswordStrength = "{lang key='pwstrength'}";
    window.langPasswordWeak = "{lang key='pwstrengthweak'}";
    window.langPasswordModerate = "{lang key='pwstrengthmoderate'}";
    window.langPasswordStrong = "{lang key='pwstrengthstrong'}";
    jQuery(document).ready(function() {
        jQuery("#inputPassword").keyup(registerFormPasswordStrengthFeedback);
    });
</script>

<div class="auth-container auth-container-wide">
    <div class="auth-card{if $loggedin || !$invite} auth-card-wide{/if} text-center">
        {if $invite}
            <div class="auth-logo invite-info-icon">
                <i class="fas fa-user-plus"></i>
            </div>
            <h1 class="auth-title">{lang key='accountInvite.youHaveBeenInvited' clientName=$invite->getClientName()}</h1>

            {include file="$template/includes/flashmessage.tpl"}

            <p class="auth-subtitle">{lang key='accountInvite.givenAccess' senderName=$invite->getSenderName() clientName=$invite->getClientName() ot="<strong>" ct="</strong>"}</p>

            {if $loggedin}
                <p>{lang key='accountInvite.inviteAcceptLoggedIn'}</p>
                <form method="post" action="{routePath('invite-validate', $invite->token)}" class="auth-form">
                    <button type="submit" class="btn btn-primary btn-lg btn-full">{lang key='accountInvite.accept'}</button>
                </form>
            {else}
                <p>{lang key='accountInvite.inviteAcceptLoggedOut'}</p>
                <div class="invite-two-col">
                    <div class="invite-box card">
                        <div class="card-header"><h3 class="card-title">{lang key='login'}</h3></div>
                        <div class="card-body">
                            <form method="post" action="{routePath('login-validate')}" class="auth-form">
                                <div class="form-group">
                                    <label for="inputLoginEmail" class="form-label">{lang key='loginemail'}</label>
                                    <input type="email" name="username" class="form-input" id="inputLoginEmail" value="{$formdata.email}">
                                </div>
                                <div class="form-group">
                                    <label for="inputLoginPassword" class="form-label">{lang key='loginpassword'}</label>
                                    <input type="password" name="password" class="form-input" id="inputLoginPassword">
                                </div>
                                {include file="$template/includes/captcha.tpl" captchaForm=$captchaForm nocache}
                                <button type="submit" class="btn btn-primary btn-lg btn-full{$captcha->getButtonClass($captchaForm)}">{lang key='login'}</button>
                            </form>
                        </div>
                    </div>
                    <div class="invite-box card">
                        <div class="card-header"><h3 class="card-title">{lang key='register'}</h3></div>
                        <div class="card-body">
                            <form method="post" action="{routePath('invite-validate', $invite->token)}" class="auth-form">
                                <div class="form-row">
                                    <div class="form-group">
                                        <label for="inputFirstName" class="form-label">{lang key='clientareafirstname'}</label>
                                        <input type="text" class="form-input" name="firstname" id="inputFirstName" value="{$formdata.firstname}">
                                    </div>
                                    <div class="form-group">
                                        <label for="inputLastName" class="form-label">{lang key='clientarealastname'}</label>
                                        <input type="text" class="form-input" name="lastname" id="inputLastName" value="{$formdata.lastname}">
                                    </div>
                                </div>
                                <div class="form-group">
                                    <label for="inputEmail" class="form-label">{lang key='loginemail'}</label>
                                    <input type="email" name="email" class="form-input" id="inputEmail" value="{$formdata.email}">
                                </div>
                                <div class="form-group">
                                    <label for="inputPassword" class="form-label">{lang key='loginpassword'}</label>
                                    <input type="password" class="form-input" name="password" id="inputPassword" data-error-threshold="{$pwStrengthErrorThreshold}" data-warning-threshold="{$pwStrengthWarningThreshold}" autocomplete="off">
                                    <div class="password-strength-meter">
                                        <div class="progress pw-strength-bar">
                                            <div class="progress-bar" role="progressbar" aria-valuenow="0" aria-valuemin="0" aria-valuemax="100" id="passwordStrengthMeterBar"></div>
                                        </div>
                                        <p class="form-hint" id="passwordStrengthTextLabel">{lang key='pwstrength'}: {lang key='pwstrengthenter'}</p>
                                    </div>
                                </div>
                                {if $accept_tos}
                                    <label class="checkbox-label">
                                        <input type="checkbox" class="form-checkbox" name="accept" id="accept">
                                        <span>{lang key='ordertosagreement'} <a href="{$tos_url}" target="_blank" class="auth-link">{lang key='ordertos'}</a></span>
                                    </label>
                                {/if}
                                {include file="$template/includes/captcha.tpl" captchaForm=$captchaFormRegister nocache}
                                <button type="submit" class="btn btn-primary btn-lg btn-full{$captcha->getButtonClass($captchaFormRegister)}">{lang key='register'}</button>
                            </form>
                        </div>
                    </div>
                </div>
            {/if}
        {else}
            <div class="auth-logo error-icon"><i class="fas fa-times"></i></div>
            <h1 class="auth-title">{lang key='accountInvite.notFound'}</h1>
            <p class="auth-subtitle">{lang key='accountInvite.contactAdministrator'}</p>
        {/if}
    </div>
</div>
