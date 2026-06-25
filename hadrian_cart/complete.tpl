{*
 * hadrian_cart/complete.tpl
 *
 * Order-confirmation page. No form contract — the order is already
 * placed by the time this renders. Just shows the order number,
 * invoice link, addon HTML hooks, and the "back to client area" CTA.
 *
 * Apple visual sources: success card pattern, large order-number
 * chip, optional product-recommendations include below.
 *}

{include file="orderforms/$carttpl/common.tpl"}

<div id="order-standard_cart">

    <div class="row">
        <div class="cart-sidebar">
            {include file="orderforms/$carttpl/sidebar-categories.tpl"}
        </div>

        <div class="cart-body">

            {include file="orderforms/$carttpl/sidebar-categories-collapsed.tpl"}

            {* ─── Apple success hero ─── *}
            <div class="order-complete-hero">
                <div class="order-complete-ico">
                    <i class="fas fa-check"></i>
                </div>
                <h1 class="font-size-36">{$LANG.orderconfirmation}</h1>
                <p>{$LANG.orderreceived}</p>
            </div>

            <div class="row">
                <div class="col-sm-8 col-sm-offset-2 offset-sm-2">
                    <div class="alert alert-info order-confirmation">
                        {$LANG.ordernumberis} <span>{$ordernumber}</span>
                    </div>
                </div>
            </div>

            <p class="text-center order-final-instructions">{$LANG.orderfinalinstructions}</p>

            {if $expressCheckoutInfo}
                <div class="alert alert-info text-center">
                    {$expressCheckoutInfo}
                </div>
            {elseif $expressCheckoutError}
                <div class="alert alert-danger text-center">
                    {$expressCheckoutError}
                </div>
            {elseif $invoiceid && !$ispaid}
                <div class="alert alert-warning text-center">
                    <i class="fas fa-exclamation-triangle"></i>
                    {$LANG.ordercompletebutnotpaid}
                    <br /><br />
                    <a href="{$WEB_ROOT}/viewinvoice.php?id={$invoiceid}" target="_blank" class="alert-link">
                        <i class="fas fa-file-invoice-dollar"></i>
                        {$LANG.invoicenumber}{$invoiceid}
                    </a>
                </div>
            {/if}

            {foreach $addons_html as $addon_html}
                <div class="order-confirmation-addon-output">
                    {$addon_html}
                </div>
            {/foreach}

            {if $ispaid}
                {* Conversion / affiliate tracking scripts go here *}
            {/if}

            <div class="text-center order-complete-cta">
                <a href="{$WEB_ROOT}/clientarea.php" class="btn btn-primary btn-lg">
                    {$LANG.orderForm.continueToClientArea}
                    &nbsp;<i class="fas fa-arrow-circle-right"></i>
                </a>
            </div>

            {if $hasRecommendations}
                {include file="orderforms/$carttpl/includes/product-recommendations.tpl"}
            {/if}
        </div>
    </div>
</div>
