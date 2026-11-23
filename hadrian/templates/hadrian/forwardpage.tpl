{* Forward page - "please wait, taking you to the payment gateway".

   WHMCS renders it when a gateway needs the customer's browser to POST to the
   gateway's own site (PayPal Standard and most hosted-page gateways):
     $message    WHMCS's "you will be redirected..." text
     $code       the gateway's own HTML: usually a <form> to the gateway plus
                 its submit button
     $invoiceid  the invoice being paid (when there is one)

   Twenty-one auto-submits with autoSubmitFormByContainer() from its own
   scripts.js, which Hadrian does not load - so the hand-off is done here, and
   the gateway's own button stays visible in case the script never runs. *}
<header class="page-header">
    <h1>{$LANG.pleasewait|default:'Please wait...'}</h1>
</header>

<div class="card" style="max-width:560px;margin:0 auto">
    <div class="card-body" style="display:flex;flex-direction:column;align-items:center;gap:20px;text-align:center">
        {include file="$template/includes/alert.tpl" type="info" msg=$message textcenter=true}
        <div class="mt-forward-spinner" role="progressbar" aria-label="{$LANG.loading|default:'Loading'}"></div>
        <div id="frmPayment">{$code}</div>
        <a href="{$WEB_ROOT}/{if $invoiceid}viewinvoice.php?id={$invoiceid|escape:'url'}{else}clientarea.php{/if}" class="btn-secondary">{$LANG.cancel|default:'Cancel'}</a>
    </div>
</div>

<style>
.mt-forward-spinner { width: 36px; height: 36px; border-radius: 50%; border: 3px solid var(--color-separator, #e5e5ea); border-top-color: var(--color-blue, #0071e3); animation: mtForwardSpin .9s linear infinite; }
@keyframes mtForwardSpin { to { transform: rotate(360deg); } }
@media (prefers-reduced-motion: reduce) { .mt-forward-spinner { animation-duration: 3s; } }
</style>
<script>
(function () {
    function go() {
        var form = document.querySelector('#frmPayment form');
        if (form) { form.submit(); }
    }
    setTimeout(go, 3000);
})();
</script>
