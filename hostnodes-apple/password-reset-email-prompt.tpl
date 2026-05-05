{* =========================================================================
   Inner partial rendered inside password-reset-container.tpl (step 1 —
   email input).
   ========================================================================= *}
<h1 class="auth-title">{lang key='pwreset'}</h1>
<p class="auth-subtitle">{lang key='pwresetemailneeded'}</p>

<form method="post" action="{routePath('password-reset-validate-email')}" class="auth-form" role="form">
    <input type="hidden" name="action" value="reset">

    <div class="form-group">
        <label for="inputEmail" class="form-label">{lang key='loginemail'}</label>
        <input type="email" class="form-input" name="email" id="inputEmail" placeholder="name@example.com" autofocus required>
    </div>

    {if $captcha && $captcha->isEnabled() && $showCaptchaAfterLimit}
        {include file="$template/includes/captcha.tpl"}
    {/if}

    <button type="submit" id="resetPasswordButton" class="btn btn-primary btn-lg btn-full{$captcha->getButtonClass($captchaForm)}">
        {lang key='pwresetsubmit'}
    </button>
</form>
