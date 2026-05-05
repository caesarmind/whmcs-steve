{* =========================================================================
   payment/bank/select.tpl — choose between saved bank accounts or enter new.
   ========================================================================= *}
<div class="form-group">
    <label class="form-label">{lang key='paymentMethods.existingBank'}</label>
    {foreach $savedBankAccounts as $bank}
        <label class="radio-label">
            <input type="radio" name="bankinputs[selected]" value="{$bank.id}"{if $bank.default} checked{/if}>
            <span>{$bank.description} &middot; <span class="form-hint">{$bank.last4}</span></span>
        </label>
    {/foreach}
    <label class="radio-label">
        <input type="radio" name="bankinputs[selected]" value="new">
        <span>{lang key='paymentMethods.useNewBank'}</span>
    </label>
</div>

<div id="newBankFields" class="w-hidden">
    {include file="$template/payment/bank/inputs.tpl"}
</div>
