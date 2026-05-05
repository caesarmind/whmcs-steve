{* =========================================================================
   payment/card/select.tpl — choose between saved cards or enter a new one.
   ========================================================================= *}
<div class="form-group">
    <label class="form-label">{lang key='paymentMethods.existingCard'}</label>
    {foreach $savedCards as $card}
        <label class="radio-label">
            <input type="radio" name="ccinputs[selected]" value="{$card.id}"{if $card.default} checked{/if}>
            <span>{$card.description} &middot; <span class="form-hint">{$card.last4}</span></span>
        </label>
    {/foreach}
    <label class="radio-label">
        <input type="radio" name="ccinputs[selected]" value="new">
        <span>{lang key='paymentMethods.useNewCard'}</span>
    </label>
</div>

<div id="newCardFields" class="w-hidden">
    {include file="$template/payment/card/inputs.tpl"}
</div>
