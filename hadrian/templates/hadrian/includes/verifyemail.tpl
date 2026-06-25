{* Email-verification banner — shown across the client area when the admin has
   "Require Email Verification" enabled and the logged-in user's email is unverified
   ($showEmailVerificationBanner is set by WHMCS). Mirrors stock nexus/includes/verifyemail.tpl.

   Resend + dismiss are AJAX POSTs (token in the body) to the WHMCS routes, exactly
   like WHMCS's own JS — these routes return JSON, not a redirect, so they must be
   driven with JS (no plain-form fallback). hadrian loads no jQuery, so this is vanilla. *}
{if isset($showEmailVerificationBanner) && $showEmailVerificationBanner}
<div class="mt-verify-banner" id="mtVerifyBanner"
     data-resend="{routePath('user-email-verification-resend')|escape}"
     data-dismiss-uri="{routePath('dismiss-email-verification')|escape}"
     data-token="{$token|default:''|escape}"
     data-sent="{$LANG.emailSent|escape}"
     data-error="{$LANG.error|escape}">
    <span class="mt-verify-ico">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.9" stroke-linecap="round" stroke-linejoin="round"><path d="M10.29 3.86L1.82 18a2 2 0 001.71 3h16.94a2 2 0 001.71-3L13.71 3.86a2 2 0 00-3.42 0z"/><line x1="12" y1="9" x2="12" y2="13"/><line x1="12" y1="17" x2="12.01" y2="17"/></svg>
    </span>
    <span class="mt-verify-text">{$LANG.verifyEmailAddress}</span>
    <button type="button" class="mt-verify-resend" data-mt-resend>{$LANG.resendEmail}</button>
    <button type="button" class="mt-verify-close" data-mt-dismiss aria-label="{$LANG.close}">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/></svg>
    </button>
</div>
<script>{literal}
(function () {
    var b = document.getElementById('mtVerifyBanner');
    if (!b) { return; }
    var token = b.getAttribute('data-token') || '';
    function post(uri) {
        return fetch(uri, {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded', 'X-CSRF-Token': token },
            body: 'token=' + encodeURIComponent(token),
            credentials: 'same-origin'
        });
    }
    var resend = b.querySelector('[data-mt-resend]');
    if (resend) {
        resend.addEventListener('click', function () {
            resend.disabled = true;
            post(b.getAttribute('data-resend'))
                .then(function (r) { return r.json().catch(function () { return {}; }); })
                .then(function (d) { resend.textContent = (d && d.success) ? b.getAttribute('data-sent') : b.getAttribute('data-error'); })
                .catch(function () { resend.disabled = false; resend.textContent = b.getAttribute('data-error'); });
        });
    }
    var dismiss = b.querySelector('[data-mt-dismiss]');
    if (dismiss) {
        dismiss.addEventListener('click', function () {
            try { post(b.getAttribute('data-dismiss-uri')); } catch (e) {}
            if (b.parentNode) { b.parentNode.removeChild(b); }
        });
    }
})();
{/literal}</script>
{/if}
