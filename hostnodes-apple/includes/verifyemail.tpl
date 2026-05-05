{* =========================================================================
   Email verification banner — prompt user to verify their email and offer a
   resend action. AJAX-driven by WHMCS core.
   ========================================================================= *}
{if $showEmailVerificationBanner}
    <div class="verification-banner callout warning email-verification">
        <div class="verification-banner-inner">
            <span class="verification-banner-text">
                <i class="fas fa-exclamation-triangle"></i>
                {lang key='verifyEmailAddress'}
            </span>
            <button id="btnResendVerificationEmail" class="btn btn-sm btn-secondary btn-resend-verify-email btn-action"
                    data-email-sent="{lang key='emailSent'}"
                    data-error-msg="{lang key='error'}"
                    data-uri="{routePath('user-email-verification-resend')}">
                <span class="loader w-hidden"><i class="fa fa-spinner fa-spin"></i></span>
                {lang key='resendEmail'}
            </button>
            <button id="btnEmailVerificationClose" type="button" class="verification-banner-close"
                    data-uri="{routePath('dismiss-email-verification')}"
                    aria-label="{lang key='close'}">&times;</button>
        </div>
    </div>
{/if}
