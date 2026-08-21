{*
 * Right-rail sticky order summary (.co-summary-card).
 *
 * Order:
 *   .co-summary-head   -> "Order summary" label
 *   .co-summary-list   -> per-item rows + subtotal/discount/tax
 *                         (#subtotal, #discount, #taxTotal1, #taxTotal2
 *                         are required IDs CartTotalUpdater.js targets
 *                         when the user toggles applycredit etc.)
 *   .co-summary-total  -> Total Due Today (also #totalDueToday)
 *   .co-summary-cycle  -> recurring price line (#totalCartPrice)
 *   .co-summary-footer -> Complete Order pill + Back to cart link
 *   .co-trust-strip    -> static SSL + money-back row
 *
 * The Complete Order button uses HTML5 form="frmCheckout" attribute
 * to submit the form that lives in .co-left -- the button itself
 * sits outside the <form> in the DOM. Matches
 * apple-client-area/checkout.html.
 *}

<aside>
    <div class="co-summary-card">
        <div class="co-summary-head">
            <h2>{$LANG.ordersummary}</h2>
        </div>
        <div class="co-summary-list">
            {foreach $products as $num => $product}
                <div class="co-summary-line">
                    <span class="label">{$product.productinfo.name}{if $product.billingcyclefriendly} &middot; {$product.billingcyclefriendly}{/if}</span>
                    <span class="value">{include file="orderforms/{$carttpl|default:'hadrian_cart'}/includes/free-price.tpl" hnPrice=$product.pricing.totalTodayExcludingTaxSetup}</span>
                </div>
            {/foreach}
            {foreach $domains as $num => $domain}
                <div class="co-summary-line">
                    <span class="label">{if $domain.type eq "register"}{$LANG.orderdomainregistration}{else}{$LANG.orderdomaintransfer}{/if} &middot; {$domain.domain}</span>
                    <span class="value">{include file="orderforms/{$carttpl|default:'hadrian_cart'}/includes/free-price.tpl" hnPrice=$domain.price}</span>
                </div>
            {/foreach}
            {foreach $addons as $num => $addon}
                <div class="co-summary-line">
                    <span class="label">+ {$addon.name}</span>
                    <span class="value">{include file="orderforms/{$carttpl|default:'hadrian_cart'}/includes/free-price.tpl" hnPrice=$addon.totaltoday}</span>
                </div>
            {/foreach}

            <div class="co-summary-line divider">
                <span class="label">{$LANG.ordersubtotal}</span>
                <span class="value" id="subtotal">{include file="orderforms/{$carttpl|default:'hadrian_cart'}/includes/free-price.tpl" hnPrice=$subtotal}</span>
            </div>
            {if $promotioncode}
                <div class="co-summary-line">
                    <span class="label">{$promotiondescription}</span>
                    <span class="value good" id="discount">{$discount}</span>
                </div>
            {/if}
            {if $taxrate}
                <div class="co-summary-line">
                    <span class="label">{$taxname} @ {$taxrate}%</span>
                    <span class="value muted" id="taxTotal1">{$taxtotal}</span>
                </div>
            {/if}
            {if $taxrate2}
                <div class="co-summary-line">
                    <span class="label">{$taxname2} @ {$taxrate2}%</span>
                    <span class="value muted" id="taxTotal2">{$taxtotal2}</span>
                </div>
            {/if}
        </div>

        <div class="co-summary-total">
            <span class="label">{$LANG.ordertotalduetoday}</span>
            <span class="value" id="totalDueToday">{include file="orderforms/{$carttpl|default:'hadrian_cart'}/includes/free-price.tpl" hnPrice=$total}</span>
        </div>

        {if $totalrecurring}
            <p class="co-summary-cycle">{$hadrianLang.cart.recurringTotal}: <strong id="totalCartPrice">{$totalrecurring}</strong></p>
        {/if}

        {* Complete Order lives inside the sticky summary card (mirrors
           apple-client-area/checkout.html). The form= attribute binds
           the button to the form even though it sits outside the
           <form> in the DOM. *}
        <div class="co-summary-footer">
            <button type="submit"
                    form="frmCheckout"
                    id="btnCompleteOrder"
                    class="btn btn-primary btn-lg disable-on-click spinner-on-click{if $captcha}{$captcha->getButtonClass($captchaForm)}{/if}"
                    {if $cartitems==0}disabled="disabled"{/if}
            >
                {if $inExpressCheckout}{$LANG.confirmAndPay}{else}{$LANG.completeorder}{/if}
                <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="margin-left: 6px;"><polyline points="9 18 15 12 9 6"/></svg>
            </button>
            <a href="{$WEB_ROOT}/cart.php?a=view" class="co-back-link">
                <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="15 18 9 12 15 6"/></svg>
                {$hadrianLang.cart.backToCart}
            </a>
        </div>

        <div class="co-trust-strip">
            <span class="item"><i class="fas fa-lock"></i> {$hadrianLang.cart.trustSsl}</span>
            <span class="item"><i class="fas fa-check"></i> {$hadrianLang.cart.trustMoneyBack}</span>
        </div>
    </div>
</aside>
