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
    {if $showEyebrow}<p class="page-eyebrow">{$LANG.accounttab|default:'Account'}</p>{/if}
    <h1>{$LANG.clientareanavlogin|default:'Sign in'}</h1>
    <p class="page-subtitle">{$LANG.welcomeback|default:'Welcome back. Enter your credentials to access your account.'}</p>
</header>

<div class="auth-card-wrap">
    <div class="auth-card">

        {if $logout}
            <div class="auth-notice success">
                {$LANG.logoutsuccessful|default:'You have been logged out. See you next time.'}
            </div>
        {/if}

        {if $incorrect}
            <div class="auth-notice">
                {$LANG.logindetailsincorrect|default:'The email address or password you entered is incorrect. Please try again.'}
            </div>
        {/if}

        {if $verifylinkexpired}
            <div class="auth-notice">
                {$LANG.verifylinkexpired|default:'This email-verification link has expired. Sign in to request a new one.'}
            </div>
        {/if}

        {if $passwordResetSuccessful}
            <div class="auth-notice success">
                {$LANG.pwresetsuccess|default:'Your password has been reset. Sign in with your new password.'}
            </div>
        {/if}

        <form class="auth-form" method="post" action="{$WEB_ROOT}/dologin.php">
            <input type="hidden" name="token" value="{$token}" />

            <div class="form-group">
                <label class="form-label" for="loginEmail">{$LANG.loginemail|default:'Email Address'}</label>
                <input type="email" id="loginEmail" name="username" class="form-input" placeholder="you@example.com" autocomplete="email" autofocus required>
            </div>

            <div class="form-group">
                <label class="form-label" for="loginPassword">{$LANG.loginpassword|default:'Password'}</label>
                <div class="password-wrapper">
                    <input type="password" id="loginPassword" name="password" class="form-input" placeholder="{$LANG.loginpasswordplaceholder|default:'Enter your password'}" autocomplete="current-password" required>
                    <button type="button" class="password-toggle" aria-label="{$LANG.togglepasswordvisibility|default:'Show or hide password'}" data-toggle-pwd>
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/><circle cx="12" cy="12" r="3"/></svg>
                    </button>
                </div>
            </div>

            {if $allowRemember}
            <div class="form-row-inline">
                <label class="checkbox-label">
                    <input type="checkbox" name="rememberme" class="form-checkbox" {if $rememberMe}checked{/if}>
                    <span>{$LANG.loginrememberme|default:'Remember me'}</span>
                </label>
                {if $showForgotLink}
                <a href="{$WEB_ROOT}/pwreset.php" class="auth-link">{$LANG.loginforgotten|default:'Forgot password?'}</a>
                {/if}
            </div>
            {elseif $showForgotLink}
            <div class="auth-link-row" style="text-align:right;margin:-4px 0 0;">
                <a href="{$WEB_ROOT}/pwreset.php" class="auth-link">{$LANG.loginforgotten|default:'Forgot password?'}</a>
            </div>
            {/if}

            <button type="submit" class="btn-primary btn-lg btn-full">{$LANG.loginbutton|default:'Sign In'}</button>
        </form>

        {if $ssoProviders|default:false && $ssoProviders|count > 0}
            <div class="auth-divider">{$LANG.orcontinuewith|default:'or continue with'}</div>
            <div class="auth-sso-row">
                {foreach $ssoProviders as $provider}
                    <a href="{$provider.url|escape}" class="auth-sso-btn">
                        {if $provider.icon}<img src="{$provider.icon|escape}" alt="">{/if}
                        <span>{$provider.label|escape|default:'Continue'}</span>
                    </a>
                {/foreach}
            </div>
        {/if}

        {if $showCreateLink}
        <div class="auth-footer">
            {$LANG.dontHaveAccount|default:"Don't have an account?"}
            <a href="{$WEB_ROOT}/register.php" class="auth-link">{$LANG.createaccount|default:'Create one'}</a>
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
