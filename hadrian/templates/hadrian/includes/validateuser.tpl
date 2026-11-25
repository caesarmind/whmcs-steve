{* User-validation banner - the WHMCS shared include, shown across the client
   area like stock Nexus. WHMCS sets $showUserValidationBanner when the fraud
   check (Validation.com) wants documents from this user, with the
   submission page in $userValidationUrl. Stock opens that page in a
   Bootstrap modal iframe; Hadrian loads no Bootstrap JS, so the button opens
   it in a new tab. Dismiss posts to WHMCS's dismiss-user-validation route,
   as stock's JS does. Reuses the email-verification banner's classes. *}
{if isset($showUserValidationBanner) && $showUserValidationBanner}
<div class="mt-verify-banner user-validation" id="hnUserValidation"
     data-dismiss-uri="{routePath('dismiss-user-validation')|escape}"
     data-token="{$token|default:''|escape}">
    <span class="mt-verify-ico">
        <svg aria-hidden="true" focusable="false" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.9" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="4" width="18" height="16" rx="2"/><circle cx="9" cy="11" r="2.5"/><path d="M5.5 17c.8-1.7 2-2.5 3.5-2.5s2.7.8 3.5 2.5"/><line x1="15" y1="9" x2="19" y2="9"/><line x1="15" y1="13" x2="18" y2="13"/></svg>
    </span>
    <span class="mt-verify-text">{lang key='fraud.furtherValShort'}</span>
    <a href="{$userValidationUrl}" target="_blank" rel="noopener" class="mt-verify-resend" style="display:inline-flex;align-items:center;text-decoration:none;">{lang key='fraud.submitDocs'}</a>
    <button type="button" class="mt-verify-close" data-hn-dismiss aria-label="{$LANG.close}">
        <svg aria-hidden="true" focusable="false" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/></svg>
    </button>
</div>
<script>{literal}
(function () {
    var b = document.getElementById('hnUserValidation');
    var x = b ? b.querySelector('[data-hn-dismiss]') : null;
    if (!x) { return; }
    x.addEventListener('click', function () {
        var token = b.getAttribute('data-token') || '';
        try {
            fetch(b.getAttribute('data-dismiss-uri'), {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded', 'X-CSRF-Token': token },
                body: 'token=' + encodeURIComponent(token),
                credentials: 'same-origin'
            });
        } catch (e) {}
        b.parentNode.removeChild(b);
    });
})();
{/literal}</script>
{/if}
