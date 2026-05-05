{* =========================================================================
   oauth/login-twofactorauth.tpl — 2FA prompt during OAuth login.
   ========================================================================= *}
<div class="auth-card">
    <h1 class="auth-title">{lang key='twofactorauth'}</h1>
    <p class="auth-subtitle">{lang key='twofa2ndfactorreq'}</p>

    {if $error}{include file="$template/includes/alert.tpl" type="error" msg=$error textcenter=true}{/if}

    <form method="post" action="{$verifyUrl}" class="auth-form">
        <input type="hidden" name="token" value="{$token}">
        {$challenge}
    </form>
</div>
