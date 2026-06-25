{*
 * hadrian_cart/error.tpl
 *
 * Generic cart-flow error page. WHMCS renders this when any cart
 * action (add-to-cart, configure-product, checkout, etc.) raises a
 * recoverable error -- bad SKU, fraudcheck failure that isn't
 * fraudcheck.tpl's specific path, invalid domain step, etc.
 *
 * No form contract -- this is a leaf page. Only the back-button is
 * functional.
 *
 * Variables WHMCS hands in:
 *   $errortitle   short heading (string, may contain HTML)
 *   $errormsg     longer body (string, may contain HTML)
 *
 * Apple visual layer:
 *   - .order-error-hero -- same composition as .order-complete-hero
 *     in complete.tpl (icon-tile + h1 + p), but using a warning
 *     palette. Both share .cart-hero base styling in style.min.css.
 *   - Single primary CTA ("Go Back") + secondary link to support.
 *}

{include file="orderforms/$carttpl/common.tpl"}

<div id="order-standard_cart">

    <div class="row">
        <div class="cart-sidebar">
            {include file="orderforms/$carttpl/sidebar-categories.tpl"}
        </div>

        <div class="cart-body">

            {include file="orderforms/$carttpl/sidebar-categories-collapsed.tpl"}

            {* ─── Apple error hero ─── *}
            <div class="order-error-hero">
                <div class="order-error-ico">
                    <i class="fas fa-exclamation-triangle"></i>
                </div>
                <h1 class="font-size-36">{$LANG.thereisaproblem}</h1>
                {if $errortitle}
                    <p class="order-error-title">{$errortitle}</p>
                {/if}
            </div>

            <div class="row">
                <div class="col-sm-8 col-sm-offset-2 offset-sm-2">
                    {if $errormsg}
                        <div class="alert alert-danger error-heading order-error-body">
                            <i class="fas fa-info-circle"></i>
                            <span>{$errormsg}</span>
                        </div>
                    {/if}

                    <div class="text-center order-error-actions">
                        <a href="javascript:history.go(-1)" class="btn btn-primary btn-lg">
                            <i class="fas fa-arrow-left"></i>&nbsp;
                            {$LANG.problemgoback}
                        </a>
                        <br><br>
                        <a href="{$WEB_ROOT}/submitticket.php" class="btn-link order-error-support">
                            {$LANG.orderForm.submitTicket}
                            &nbsp;<i class="fas fa-arrow-right"></i>
                        </a>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
