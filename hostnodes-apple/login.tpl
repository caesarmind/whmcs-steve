{* =========================================================================
   login.tpl — public sign-in page.
   Reads: $WEB_ROOT, $captcha, $captchaForm, $companyname, $assetLogoPath.
   Posts to {$WEB_ROOT}/dologin.php. WHMCS validates and redirects.
   ========================================================================= *}
<div class="auth-container">
    <div class="providerLinkingFeedback"></div>

    <div class="auth-card">
        <div class="auth-logo">
            {if $assetLogoPath}
                <img src="{$assetLogoPath}" alt="{$companyname}">
            {else}
                <i class="fas fa-cube"></i>
            {/if}
        </div>

        <h1 class="auth-title">{lang key='loginbutton'}</h1>
        <p class="auth-subtitle">{lang key='userLogin.signInToContinue'}</p>

        {include file="$template/includes/flashmessage.tpl"}

        <form method="post" action="{$WEB_ROOT}/dologin.php" class="auth-form" role="form">
            <input type="hidden" name="token" value="{$token}">

            <div class="form-group">
                <label for="inputEmail" class="form-label">{lang key='clientareaemail'}</label>
                <input type="email" name="username" id="inputEmail" class="form-input"
                       placeholder="name@example.com" autocomplete="email" autofocus required>
            </div>

            <div class="form-group">
                <div class="form-label-row">
                    <label for="inputPassword" class="form-label">{lang key='clientareapassword'}</label>
                    <a href="{routePath('password-reset-begin')}" class="auth-link-small" tabindex="-1">{lang key='forgotpw'}</a>
                </div>
                <div class="password-wrapper">
                    <input type="password" name="password" id="inputPassword" class="form-input pw-input"
                           placeholder="{lang key='clientareapassword'}" autocomplete="current-password" required>
                    <button type="button" class="password-toggle" tabindex="-1" aria-label="{lang key='showPassword'}">
                        <i class="far fa-eye eye-open"></i>
                        <i class="far fa-eye-slash eye-closed" style="display:none"></i>
                    </button>
                </div>
            </div>

            {if $captcha->isEnabled() && $captcha->isEnabledForForm($captchaForm)}
                {include file="$template/includes/captcha.tpl"}
            {/if}

            <div class="form-row-inline">
                <label class="checkbox-label">
                    <input type="checkbox" class="form-checkbox" name="rememberme">
                    <span>{lang key='loginrememberme'}</span>
                </label>
            </div>

            <button id="login" type="submit" class="btn btn-primary btn-lg btn-full{$captcha->getButtonClass($captchaForm)}">
                {lang key='loginbutton'}
            </button>
        </form>

        {include file="$template/includes/linkedaccounts.tpl" linkContext="login" customFeedback=true}

        <div class="auth-footer">
            <small>{lang key='userLogin.notRegistered'}</small>
            <a href="{$WEB_ROOT}/register.php" class="auth-link">{lang key='userLogin.createAccount'}</a>
        </div>
    </div>
</div>
