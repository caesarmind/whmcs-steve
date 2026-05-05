{* =========================================================================
   forwardpage.tpl — auto-submits an off-site form (typically a payment
   gateway redirect). The container shows a loading spinner while the JS
   below auto-submits the form inside #frmPayment.
   ========================================================================= *}
<div class="auth-container">
    <div class="auth-card text-center">
        {include file="$template/includes/alert.tpl" type="info" msg=$message textcenter=true}

        <div class="forwardpage-spinner">
            <i class="fas fa-circle-notch fa-spin fa-3x"></i>
            <p class="form-hint">{lang key='loading'}</p>
        </div>

        <div id="frmPayment">
            {$code}
            <form method="post" action="{if $invoiceid}viewinvoice.php?id={$invoiceid}{else}clientarea.php{/if}"></form>
        </div>
    </div>
</div>

<script>
    setTimeout(function() { autoSubmitFormByContainer('frmPayment'); }, 5000);
</script>
