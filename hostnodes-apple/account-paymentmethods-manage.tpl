{* =========================================================================
   account-paymentmethods-manage.tpl — add or edit a saved payment method.
   ========================================================================= *}
<div class="page-header"><h1 class="page-title">{if $paymethod}{lang key='paymentMethods.edit'}{else}{lang key='paymentMethods.add'}{/if}</h1></div>

{include file="$template/includes/flashmessage.tpl"}

<form method="post" action="{$smarty.server.PHP_SELF}">
    <input type="hidden" name="token" value="{$token}">
    <input type="hidden" name="sub" value="save">
    {if $paymethod.id}<input type="hidden" name="id" value="{$paymethod.id}">{/if}

    <div class="card">
        <div class="card-header"><h3 class="card-title">{lang key='paymentMethods.details'}</h3></div>
        <div class="card-body">
            <div class="form-group">
                <label for="description" class="form-label">{lang key='paymentMethods.description'}</label>
                <input type="text" name="description" id="description" value="{$paymethod.description}" class="form-input">
            </div>
            <div class="form-group">
                <label class="form-label">{lang key='paymentMethods.type'}</label>
                <label class="radio-label"><input type="radio" name="type" value="card"{if !$paymethod || $paymethod.type == 'card'} checked{/if}> {lang key='paymentMethods.card'}</label>
                <label class="radio-label"><input type="radio" name="type" value="bank"{if $paymethod.type == 'bank'} checked{/if}> {lang key='paymentMethods.bank'}</label>
            </div>

            <div id="cardFields">{include file="$template/payment/card/inputs.tpl"}</div>
            <div id="bankFields" class="w-hidden">{include file="$template/payment/bank/inputs.tpl"}</div>

            <hr>
            {include file="$template/payment/billing-address.tpl"}
        </div>
    </div>

    <div class="btn-group">
        <button type="submit" class="btn btn-primary">{lang key='clientareasavechanges'}</button>
        <a href="{routePath('account-payment-methods')}" class="btn btn-secondary">{lang key='cancel'}</a>
    </div>
</form>
