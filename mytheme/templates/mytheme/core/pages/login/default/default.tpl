{* Hostnodes — Sign in page (Apple-style centered card).

   WHMCS standard variables expected:
     $token             — CSRF token for the login form
     $incorrect         — set when previous login attempt failed
     $rememberMe        — bool/string for the remember-me checkbox
     $ssoProviders      — optional array of SSO buttons (when configured)
     $logout            — set when user just signed out (success notice)
     $verifylinkexpired — set when an email-verify link expired

   Variant config from $myTheme.pages.login.config:
     showEyebrow     — bool   (default: true)
     allowRemember   — bool   (default: true)
     showCreateLink  — bool   (default: true)
     showForgotLink  — bool   (default: true)
*}

{assign var=showEyebrow value=true}
{assign var=allowRemember value=true}
{assign var=showCreateLink value=true}
{assign var=showForgotLink value=true}

<link rel="stylesheet" href="{$WEB_ROOT}/templates/{$template}/assets/css/pages/login.css?v={$myTheme.version|default:'1.0'}">

<header class="page-header">
    {if $showEyebrow}<p class="page-eyebrow">{$hadrianLang.auth.account}</p>{/if}
    <h1>{$LANG.clientareahomeloginbtn}</h1>
    <p class="page-subtitle">{$hadrianLang.auth.welcomeBack}</p>
</header>

<div class="auth-card-wrap">
    <div class="auth-card">

        {* The routed /index.php/login flow reports a failed login (and other
           notices) through get_flash_message(), NOT the legacy $incorrect var —
           render it so failed sign-ins actually surface an error. *}
        {if $message = get_flash_message()}
            <div class="auth-notice{if $message.type == 'success'} success{elseif $message.type == 'warning' || $message.type == 'info'} info{/if}">
                {$message.text}
            </div>
        {/if}

        {if $logout}
            <div class="auth-notice success">
                {$hadrianLang.auth.logoutSuccessful}
            </div>
        {/if}

        {if $incorrect}
            <div class="auth-notice">
                {$hadrianLang.auth.loginDetailsIncorrect}
            </div>
        {/if}

        {if $verifylinkexpired}
            <div class="auth-notice">
                {$hadrianLang.auth.verifyLinkExpired}
            </div>
        {/if}

        {if $passwordResetSuccessful}
            <div class="auth-notice success">
                {$hadrianLang.auth.pwResetSuccess}
            </div>
        {/if}

        <form class="auth-form" method="post" action="{routePath('login-validate')}">
            <input type="hidden" name="token" value="{$token}" />

            <div class="form-group">
                <label class="form-label" for="loginEmail">{$LANG.loginemail}</label>
                <input type="email" id="loginEmail" name="username" class="form-input" placeholder="you@example.com" autocomplete="email" autofocus required>
            </div>

            <div class="form-group">
                <label class="form-label" for="loginPassword">{$LANG.clientareapassword}</label>
                <div class="password-wrapper">
                    <input type="password" id="loginPassword" name="password" class="form-input" placeholder="{$hadrianLang.auth.passwordPlaceholder}" autocomplete="current-password" required>
                    <button type="button" class="password-toggle" aria-label="{$hadrianLang.auth.togglePassword}" data-toggle-pwd>
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/><circle cx="12" cy="12" r="3"/></svg>
                    </button>
                </div>
            </div>

            {if $allowRemember}
            <div class="form-row-inline">
                <label class="checkbox-label">
                    <input type="checkbox" name="rememberme" class="form-checkbox" {if $rememberMe}checked{/if}>
                    <span>{$LANG.loginrememberme}</span>
                </label>
                {if $showForgotLink}
                <a href="{$WEB_ROOT}/pwreset.php" class="auth-link">{$LANG.forgotpw}</a>
                {/if}
            </div>
            {elseif $showForgotLink}
            <div class="auth-link-row" style="text-align:right;margin:-4px 0 0;">
                <a href="{$WEB_ROOT}/pwreset.php" class="auth-link">{$LANG.forgotpw}</a>
            </div>
            {/if}

            {* CAPTCHA — renders only when enabled for the login form in admin.
               getMarkup() emits the widget; reCAPTCHA api.js is auto-injected by {$headoutput}. *}
            {if isset($captcha) && $captcha->isEnabled() && $captcha->isEnabledForForm($captchaForm)}
            <div class="form-group auth-captcha">{include file="`$template`/includes/captcha.tpl"}</div>
            {/if}

            <button type="submit" class="btn-primary btn-lg btn-full{if isset($captcha) && $captcha}{$captcha->getButtonClass($captchaForm)}{/if}">{$LANG.loginbutton}</button>
        </form>

        {if $ssoProviders|default:false && $ssoProviders|@count > 0}
            <div class="auth-divider">{$LANG.or}</div>
            <div class="auth-sso-row">
                {foreach $ssoProviders as $provider}
                    <a href="{$provider.url|escape}" class="auth-sso-btn">
                        {if $provider.icon}<img src="{$provider.icon|escape}" alt="">{/if}
                        <span>{$provider.label|escape|default:$hadrianLang.auth.continueSso}</span>
                    </a>
                {/foreach}
            </div>
        {/if}

        {if $showCreateLink}
        <div class="auth-footer">
            {$LANG.userLogin.notRegistered}
            <a href="{$WEB_ROOT}/register.php" class="auth-link">{$LANG.userLogin.createAccount}</a>
        </div>
        {/if}

    </div>
</div>

<script>
(function () {
    document.querySelectorAll('[data-toggle-pwd]').forEach(function (btn) {
        btn.addEventListener('click', function () {
            var input = btn.parentNode.querySelector('input');
            if (!input) return;
            input.type = (input.type === 'password') ? 'text' : 'password';
        });
    });
})();
</script>
