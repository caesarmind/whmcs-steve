{* =========================================================================
   user-verify-email.tpl — landing page after clicking an email verification
   link. Shows success / expired / not-found.
   ========================================================================= *}
<div class="auth-container">
    <div class="auth-card text-center">
        {if $success}
            <div class="auth-logo success-icon"><i class="fas fa-check"></i></div>
            <h1 class="auth-title">{lang key='emailVerification.success'}</h1>
        {elseif $expired}
            <div class="auth-logo warning-icon"><i class="far fa-clock"></i></div>
            <h1 class="auth-title">{lang key='emailVerification.expired'}</h1>
            {if $loggedin}
                <button class="btn btn-secondary btn-lg btn-resend-verify-email"
                        data-email-sent="{lang key='emailSent'}"
                        data-error-msg="{lang key='error'}"
                        data-uri="{routePath('user-email-verification-resend')}">
                    {lang key='resendEmail'}
                </button>
            {else}
                <p>{lang key='emailVerification.loginToRequest'}</p>
            {/if}
        {else}
            <div class="auth-logo error-icon"><i class="fas fa-times"></i></div>
            <h1 class="auth-title">{lang key='emailVerification.notFound'}</h1>
            {if !$loggedin}
                <p>{lang key='emailVerification.loginToRequest'}</p>
            {/if}
        {/if}

        <a href="{routePath('login-index')}" class="btn btn-primary btn-lg btn-full">
            {lang key='orderForm.continueToClientArea'} <i class="fas fa-arrow-right"></i>
        </a>
    </div>
</div>
