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

    {* WHMCS aggressively sanitizes cart TPL output: <style>, <link>,
       style="..." attributes, AND inline <script> blocks all get
       stripped. The only injection points that survive are
       <script src="..."> and a fixed allowlist of attributes on the
       mount div (id / data-app / data-init).

       So Apple-theme the SPA via an EXTERNAL js file:
       js/apple-vars.js sets the unprefixed --* CSS variables on
       document.documentElement. nexus_cart's auto-loaded custom.css
       maps each --vl-* from var(--*), and the SPA's open Shadow DOM
       inherits through -- so every Vue component picks up the Apple
       palette. Loaded BEFORE main.min.js so the SPA paints with the
       right colors on first frame. *}

    {* apple-vars.js lives under templates/mytheme/assets/js/ (the same
       trusted path as apple-theme.js / apple-layout.js) because WHMCS's
       cart TPL sanitizer allows <script src=> from templates/mytheme/...
       and templates/orderforms/{standard_cart,nexus_cart}/... but
       STRIPS references to templates/orderforms/mytheme_cart/...
       Verified live: every script src= in the previous attempt was
       allowed except the mytheme_cart one. *}
    <script type="text/javascript" src="{$WEB_ROOT}/templates/mytheme/assets/js/apple-vars.js"></script>

    <div id="order-standard_cart">
        <div id="nexus-root" data-app="cart-module" data-init="{getNexusData}"></div>
    </div>

    <script type="text/javascript" src="{$WEB_ROOT}/templates/orderforms/nexus_cart/js/main.min.js"></script>

{/if}
