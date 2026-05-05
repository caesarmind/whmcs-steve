{* =========================================================================
   oauth/login.tpl — OAuth sign-in form. Rendered via oauth/layout.tpl.
   ========================================================================= *}
<div class="auth-card">
    <h1 class="auth-title">{lang key='loginbutton'}</h1>
    <p class="auth-subtitle">{lang key='userLogin.signInToContinue'}</p>

    {include file="$template/includes/flashmessage.tpl"}

    <form method="post" action="{$loginUrl}" class="auth-form">
        <input type="hidden" name="token" value="{$token}">
        <input type="hidden" name="returnurl" value="{$returnurl|escape}">

        <div class="form-group">
            <label for="inputEmail" class="form-label">{lang key='clientareaemail'}</label>
            <input type="email" name="username" id="inputEmail" class="form-input" autofocus required>
        </div>
        <div class="form-group">
            <label for="inputPassword" class="form-label">{lang key='clientareapassword'}</label>
            <input type="password" name="password" id="inputPassword" class="form-input" required>
        </div>

        {if $captcha && $captcha->isEnabled()}
            {include file="$template/includes/captcha.tpl"}
        {/if}

        <button type="submit" class="btn btn-primary btn-lg btn-full{$captcha->getButtonClass($captchaForm)}">{lang key='loginbutton'}</button>
    </form>
</div>
