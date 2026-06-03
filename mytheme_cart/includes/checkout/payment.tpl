{*
 * Payment details card -- wraps Total Due Today banner, apply-credit
 * radios, gateway selector, and the full credit-card input set.
 *
 * Form contract preserved:
 *   - #applyCreditContainer / applycredit (radio, 1|0)
 *   - .payment-methods radios with name="paymentmethod" -- WHMCS's
 *     scripts.min.js wires them via WHMCS.payment.event.gatewayInit
 *     (no-op stub at the top of checkout.tpl if not provided by host)
 *   - #paymentGatewayInput is where gateway-specific JS injects
 *     iframes / tokens (Stripe etc.)
 *   - #creditCardInputFields with ccnumber / ccexpirydate / cccvv /
 *     ccstartdate / ccissuenum / ccdescription / nostore for the
 *     "new card" path; existing saved cards via $carttpl/includes/existing-paymethods.tpl.
 *   - Express-checkout branch ({else}) emits $expressCheckoutOutput
 *     verbatim so the gateway's own checkout button renders.
 *
 * Outer .co-payment-card class applies Apple chrome via the CSS in
 * checkout.tpl. Mirrors lagom2's /includes/viewcart/form-payment-gateway.tpl.
 *}

<div class="co-payment-card">
<div class="sub-heading">
    <span class="primary-bg-color">{$LANG.orderpaymentmethod}</span>
</div>

<div class="alert alert-success text-center large-text" role="alert" id="totalDueToday">
    {$LANG.ordertotalduetoday}: &nbsp; <strong id="totalCartPrice">{$total}</strong>
</div>

{* Apply-credit choice -- rendered as Apple option cards (.ac-radio circle +
   .ac-text); the visual lives in #applyCreditContainer CSS in checkout.tpl. *}
<div id="applyCreditContainer" class="apply-credit-container{if !$canUseCreditOnCheckout} w-hidden{/if}" data-apply-credit="{$applyCredit}">
    <p>{lang key='cart.availableCreditBalance' amount=$creditBalance}</p>

    <label class="radio">
        <input id="useCreditOnCheckout" type="radio" name="applycredit" value="1"{if $applyCredit} checked{/if}>
        <span class="ac-radio" aria-hidden="true"></span>
        <span class="ac-text">
            <span id="spanFullCredit"{if !($creditBalance->toNumeric() >= $total->toNumeric())} class="w-hidden"{/if}>
                {lang key='cart.applyCreditAmountNoFurtherPayment' amount=$total}
            </span>
            <span id="spanUseCredit"{if $creditBalance->toNumeric() >= $total->toNumeric()} class="w-hidden"{/if}>
                {lang key='cart.applyCreditAmount' amount=$creditBalance}
            </span>
        </span>
    </label>
    <label class="radio">
        <input id="skipCreditOnCheckout" type="radio" name="applycredit" value="0"{if !$applyCredit} checked{/if}>
        <span class="ac-radio" aria-hidden="true"></span>
        <span class="ac-text">{lang key='cart.applyCreditSkip' amount=$creditBalance}</span>
    </label>
</div>

{if !$inExpressCheckout}
    <div id="paymentGatewaysContainer" class="form-group co-pay-gateways">
        <div class="co-pay-list" data-inputs-container>
            {foreach $gateways as $gateway}
                {assign var=gatewayKey value=$gateway.sysname|lower|replace:" ":"-"}
                {assign var=gatewayNameLower value=$gateway.name|lower}
                {assign var=gatewayLogoClass value="gateway"}
                {assign var=gatewayBadge value=$gateway.name|strip_tags|truncate:4:""|upper}
                {if $gatewayKey|strstr:"stripe" || $gatewayNameLower|strstr:"stripe"}
                    {assign var=gatewayLogoClass value="stripe"}
                    {assign var=gatewayBadge value="stripe"}
                {elseif $gateway.type eq "CC"}
                    {assign var=gatewayLogoClass value="card"}
                    {assign var=gatewayBadge value="CARD"}
                {elseif $gatewayKey|strstr:"paypal" || $gatewayNameLower|strstr:"paypal"}
                    {assign var=gatewayLogoClass value="pp"}
                    {assign var=gatewayBadge value="PP"}
                {elseif $gatewayKey|strstr:"bank" || $gatewayNameLower|strstr:"bank" || $gatewayKey|strstr:"ach" || $gatewayNameLower|strstr:"ach"}
                    {assign var=gatewayLogoClass value="bank"}
                    {assign var=gatewayBadge value="ACH"}
                {/if}

                <label class="co-pay co-pay-gateway {$gatewayKey}{if $gateway.type eq "CC"} new-card{/if}" data-virtual-input data-gateway="{$gatewayKey|escape}">
                    <input type="radio"
                           name="paymentmethod"
                           value="{$gateway.sysname}"
                           data-payment-type="{$gateway.payment_type}"
                           data-show-local="{$gateway.show_local_cards}"
                           data-remote-inputs="{$gateway.uses_remote_inputs}"
                           class="payment-methods{if $gateway.type eq "CC"} is-credit-card{/if}"
                            {if $selectedgateway eq $gateway.sysname} checked{/if}
                    />
                    <span class="co-pay-radio" aria-hidden="true"></span>
                    <span class="co-pay-logo {$gatewayLogoClass|escape}" aria-hidden="true">{$gatewayBadge|escape}</span>
                    <span class="co-pay-meta">
                        <span class="co-pay-name">{$gateway.name|escape}</span>
                        <span class="co-pay-sub">
                            {if $gatewayKey|strstr:"stripe" || $gatewayNameLower|strstr:"stripe"}
                                {$hadrianLang.cart.gatewaySubStripe}
                            {elseif $gateway.type eq "CC"}
                                {$hadrianLang.cart.gatewaySubCard}
                            {elseif $gatewayKey|strstr:"paypal" || $gatewayNameLower|strstr:"paypal"}
                                {$hadrianLang.cart.gatewaySubPaypal}
                            {elseif $gatewayKey|strstr:"bank" || $gatewayNameLower|strstr:"bank" || $gatewayKey|strstr:"ach" || $gatewayNameLower|strstr:"ach"}
                                {$hadrianLang.cart.gatewaySubBank}
                            {else}
                                {$hadrianLang.cart.gatewaySubGeneric}
                            {/if}
                        </span>
                    </span>
                </label>
            {/foreach}
        </div>
    </div>

    <div class="alert alert-danger text-center gateway-errors w-hidden"></div>

    <div class="clearfix"></div>

    <div id="paymentGatewayInput"></div>

    <div class="cc-input-container co-card-input-panel{if $selectedgatewaytype neq "CC"} w-hidden{/if}" id="creditCardInputFields">
        {if $client}
            <div id="existingCardsContainer" class="existing-cc-grid">
                {include file="orderforms/$carttpl/includes/existing-paymethods.tpl"}
            </div>
        {/if}
        <div class="row cvv-input" id="existingCardInfo">
            <div class="col-lg-3 col-sm-4">
                <div class="form-group prepend-icon">
                    <label for="inputCardCVV2" class="field-icon">
                        <i class="fas fa-barcode"></i>
                    </label>
                    <div class="input-group">
                        <input type="tel" name="cccvv" id="inputCardCVV2" class="field form-control" placeholder="{$LANG.creditcardcvvnumbershort}" autocomplete="cc-cvc">
                        <span class="input-group-btn input-group-append">
                            <button type="button" class="btn btn-default" data-toggle="popover" data-placement="bottom" data-content="<img src='{$BASE_PATH_IMG}/ccv.gif' width='210' />">
                                ?
                            </button>
                        </span>
                    </div>
                    <span class="field-error-msg">{lang key="paymentMethodsManage.cvcNumberNotValid"}</span>
                </div>
            </div>
        </div>

        <ul>
            <li>
                <label class="radio-inline">
                    <input type="radio" name="ccinfo" value="new" id="new" {if !$client || $client->payMethods->count() === 0} checked="checked"{/if} />
                    &nbsp;
                    {lang key='creditcardenternewcard'}
                </label>
            </li>
        </ul>

        <div class="row" id="newCardInfo">
            <div id="cardNumberContainer" class="col-sm-6 new-card-container">
                <div class="form-group prepend-icon">
                    <label for="inputCardNumber" class="field-icon">
                        <i class="fas fa-credit-card"></i>
                    </label>
                    <input type="tel" name="ccnumber" id="inputCardNumber" class="field form-control cc-number-field" placeholder="{$LANG.orderForm.cardNumber}" autocomplete="cc-number" data-message-unsupported="{lang key='paymentMethodsManage.unsupportedCardType'}" data-message-invalid="{lang key='paymentMethodsManage.cardNumberNotValid'}" data-supported-cards="{$supportedCardTypes}" />
                    <span class="field-error-msg"></span>
                </div>
            </div>
            <div class="col-sm-3 new-card-container">
                <div class="form-group prepend-icon">
                    <label for="inputCardExpiry" class="field-icon">
                        <i class="fas fa-calendar-alt"></i>
                    </label>
                    <input type="tel" name="ccexpirydate" id="inputCardExpiry" class="field form-control" placeholder="MM / YY{if $showccissuestart} ({$LANG.creditcardcardexpires}){/if}" autocomplete="cc-exp">
                    <span class="field-error-msg">{lang key="paymentMethodsManage.expiryDateNotValid"}</span>
                </div>
            </div>
            <div class="col-sm-3" id="cvv-field-container">
                <div class="form-group prepend-icon">
                    <label for="inputCardCVV" class="field-icon">
                        <i class="fas fa-barcode"></i>
                    </label>
                    <div class="input-group">
                        <input type="tel" name="cccvv" id="inputCardCVV" class="field form-control" placeholder="{$LANG.creditcardcvvnumbershort}" autocomplete="cc-cvc">
                        <span class="input-group-btn input-group-append">
                            <button type="button" class="btn btn-default" data-toggle="popover" data-placement="bottom" data-content="<img src='{$BASE_PATH_IMG}/ccv.gif' width='210' />">
                                ?
                            </button>
                        </span><br>
                    </div>
                    <span class="field-error-msg">{lang key="paymentMethodsManage.cvcNumberNotValid"}</span>
                </div>
            </div>
            {if $showccissuestart}
                <div class="col-sm-3 col-sm-offset-6 new-card-container offset-sm-6">
                    <div class="form-group prepend-icon">
                        <label for="inputCardStart" class="field-icon">
                            <i class="far fa-calendar-check"></i>
                        </label>
                        <input type="tel" name="ccstartdate" id="inputCardStart" class="field form-control" placeholder="MM / YY ({$LANG.creditcardcardstart})" autocomplete="cc-exp">
                    </div>
                </div>
                <div class="col-sm-3 new-card-container">
                    <div class="form-group prepend-icon">
                        <label for="inputCardIssue" class="field-icon">
                            <i class="fas fa-asterisk"></i>
                        </label>
                        <input type="tel" name="ccissuenum" id="inputCardIssue" class="field form-control" placeholder="{$LANG.creditcardcardissuenum}">
                    </div>
                </div>
            {/if}
        </div>
        <div id="newCardSaveSettings">
            <div class="row form-group new-card-container">
                <div id="inputDescriptionContainer" class="col-md-6">
                    <div class="prepend-icon">
                        <label for="inputDescription" class="field-icon">
                            <i class="fas fa-pencil"></i>
                        </label>
                        <input type="text" class="field form-control" id="inputDescription" name="ccdescription" autocomplete="off" value="" placeholder="{$LANG.paymentMethods.descriptionInput} {$LANG.paymentMethodsManage.optional}" />
                    </div>
                </div>
                {if $allowClientsToRemoveCards}
                    <div id="inputNoStoreContainer" class="col-md-6" style="line-height: 32px;">
                        <input type="hidden" name="nostore" value="1">
                        <input type="checkbox" class="toggle-switch-success no-icheck" data-size="mini" checked="checked" name="nostore" id="inputNoStore" value="0" data-on-text="{lang key='yes'}" data-off-text="{lang key='no'}">
                        <label for="inputNoStore" class="checkbox-inline no-padding">
                            &nbsp;&nbsp;
                            {$LANG.creditCardStore}
                        </label>
                    </div>
                {/if}
            </div>
        </div>
    </div>
{else}
    {if $expressCheckoutOutput}
        {$expressCheckoutOutput}
    {else}
        <p align="center">
            {lang key='paymentPreApproved' gateway=$expressCheckoutGateway}
        </p>
    {/if}
{/if}
</div>{* /.co-payment-card *}
