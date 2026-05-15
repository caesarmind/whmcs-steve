{*
 * mytheme_cart/viewcart.tpl -- nexus_cart SPA shell
 *
 * The Nexus cart Vue.js SPA (shipped with WHMCS, lives at
 * /templates/orderforms/nexus_cart/) is the modern replacement for
 * the standard_cart Smarty-rendered viewcart. Per the WHMCS9 docs
 * (section 18 / 27): "the layout of Nexus SPA pages cannot be
 * modified -- only CSS customization is allowed."
 *
 * So this TPL only does three things:
 *
 *   1. Mount points: <div data-app="cart-module" data-init="{getNexusData}">
 *      hands hydration JSON to the SPA. {getNexusData} is a WHMCS-
 *      provided Smarty function that serializes cart state.
 *
 *   2. Asset wiring: load nexus_cart's compiled bundle by absolute
 *      path so this works without changing mytheme_cart's parent
 *      inheritance (which would also pull in nexus's domainregister
 *      and could surprise other pages we've already themed).
 *
 *   3. Apple theming: override the SPA's --vl-* CSS variables to
 *      match the Apple visual language. The SPA uses Shadow DOM,
 *      so set the variables on BOTH :host and :root so they reach
 *      the shadow tree via custom-property inheritance.
 *
 * KEEP standard_cart/checkout.tpl include for the {if $checkout}
 * branch -- the SPA does NOT cover the post-cart checkout step on
 * this install (cart -> /cart.php?a=checkout still hits Smarty).
 *}

{if $checkout}

    {include file="orderforms/$carttpl/checkout.tpl"}

{else}

    {include file="orderforms/standard_cart/common.tpl"}

    {* The Apple --primary / --bg / --text variable overrides for the
       Vue SPA live in mytheme/templates/mytheme/assets/js/apple-theme.js
       (loaded globally by mytheme on every page including this one).
       We can't inject them from this TPL because WHMCS strips any
       <script src=>, <style>, <link>, style=, or inline <script> we
       add to cart TPL output when the page renders with the full
       mytheme layout shell. Putting the IIFE in the always-loaded
       global script reliably seeds the SPA's variable surface before
       main.min.js initializes its Shadow DOM.

       The .vc-* CSS rules used by the page-level chrome below live in
       mytheme/templates/mytheme/assets/css/apple-theme.css for the same
       reason -- inline <style>/<link> in this TPL would be stripped. *}

    {* ── Page-level chrome wrapping the Nexus SPA ──
       The SPA's layout is locked by WHMCS (sect 18 docs), so the only
       way to add Apple-mockup framing is page-level markup ABOVE the
       mount. The SPA's own "Shopping Cart" h1 + breadcrumb still
       render below this -- they live in the Shadow DOM, no way to
       hide them from outside. *}

    <header class="vc-page-header">
        <div>
            <h1>{$LANG.viewcart|default:'Your cart'}</h1>
            <p class="vc-sub">{$LANG.cartreviewcheckoutdesc|default:'Review the items in your cart, apply a promo code, and head to checkout.'}</p>
        </div>
        <a href="{$WEB_ROOT}/cart.php" class="vc-browse-btn">
            <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="5" y1="12" x2="19" y2="12"/><polyline points="12 5 5 12 12 19"/></svg>
            {$LANG.orderForm.continueShopping|default:'Browse products & services'}
        </a>
    </header>

    <div class="vc-steps" aria-label="Checkout progress">
        <span class="vc-step done"><span class="vc-step-num"><svg width="10" height="10" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3.2" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"/></svg></span>{$LANG.orderForm.chooseProduct|default:'Choose plan'}</span>
        <span class="vc-step-sep">&rsaquo;</span>
        <span class="vc-step done"><span class="vc-step-num"><svg width="10" height="10" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3.2" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"/></svg></span>{$LANG.cartdomain|default:'Domain'}</span>
        <span class="vc-step-sep">&rsaquo;</span>
        <span class="vc-step done"><span class="vc-step-num"><svg width="10" height="10" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3.2" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"/></svg></span>{$LANG.cartconfigure|default:'Configure'}</span>
        <span class="vc-step-sep">&rsaquo;</span>
        <span class="vc-step active"><span class="vc-step-num">4</span>{$LANG.cart|default:'Cart'}</span>
        <span class="vc-step-sep">&rsaquo;</span>
        <span class="vc-step"><span class="vc-step-num">5</span>{$LANG.checkout|default:'Checkout'}</span>
    </div>

    <div id="order-standard_cart">
        <div id="nexus-root" data-app="cart-module" data-init="{getNexusData}"></div>
    </div>

    <script type="text/javascript" src="{$WEB_ROOT}/templates/orderforms/nexus_cart/js/main.min.js"></script>

{/if}
