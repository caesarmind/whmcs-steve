{* =========================================================================
   invoice-payment.tpl — landing/response page from payment gateway.
   ========================================================================= *}
<div class="page-header"><h1 class="page-title">{lang key='invoicespay'}</h1></div>

{include file="$template/includes/flashmessage.tpl"}

<div class="card">
    <div class="card-body text-center">
        {if $success}
            <div class="auth-logo success-icon"><i class="fas fa-check"></i></div>
            <h2>{lang key='invoicepaymentsuccessconfirmation'}</h2>
        {elseif $pending}
            <div class="auth-logo warning-icon"><i class="far fa-clock"></i></div>
            <h2>{lang key='invoicepaymentpendingreview'}</h2>
        {elseif $failed}
            <div class="auth-logo error-icon"><i class="fas fa-times"></i></div>
            <h2>{lang key='invoicepaymentfailedconfirmation'}</h2>
        {else}
            {$paymentform}
        {/if}

        <a href="viewinvoice.php?id={$invoiceid}" class="btn btn-primary btn-lg mt-3">{lang key='continue'} <i class="fas fa-arrow-right"></i></a>
    </div>
</div>
