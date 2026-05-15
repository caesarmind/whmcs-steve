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

    {* Nexus SPA stylesheet + bundle. Referenced by absolute path so
       WHMCS's assetPath() resolution doesn't try to look them up in
       mytheme_cart/{js,css}/ (where they don't live). *}
    <link rel="stylesheet" href="{$WEB_ROOT}/templates/orderforms/nexus_cart/css/style.min.css">

    <style>{literal}
    /* ── Apple-themed overrides for nexus_cart's --vl-* variable surface ──
       Set on BOTH :root (page) and :host (Shadow DOM root) so the SPA
       picks them up through custom-property inheritance. Values mirror
       apple-client-area/css/apple-theme.css's light-mode palette. */
    :root, :host {
        /* Primary -- Apple blue */
        --vl-primary:           #0071e3;
        --vl-primary-lifted:    #0077ed;
        --vl-primary-accented:  #005bb5;

        /* Secondary -- neutral chip / muted button */
        --vl-secondary:           #f5f5f7;
        --vl-secondary-lifted:    #ebebef;
        --vl-secondary-accented:  #e8e8ed;

        /* Status colors */
        --vl-success:           #34c759;
        --vl-success-lifted:    #30b751;
        --vl-success-accented:  #2aa24a;
        --vl-info:              #0071e3;
        --vl-info-lifted:       #0077ed;
        --vl-info-accented:     #005bb5;
        --vl-notice:            #ff9f0a;
        --vl-notice-lifted:     #ff8e00;
        --vl-notice-accented:   #e07a00;
        --vl-warning:           #ff9500;
        --vl-warning-lifted:    #f08a00;
        --vl-warning-accented:  #d97a00;
        --vl-error:             #ff3b30;
        --vl-error-lifted:      #ef352b;
        --vl-error-accented:    #d62d24;

        /* Grayscale / neutral */
        --vl-grayscale:  #1d1d1f;
        --vl-neutral:    #6e6e73;

        /* Text hierarchy */
        --vl-text:           #1d1d1f;
        --vl-text-lifted:    #6e6e73;
        --vl-text-accented:  #000000;
        --vl-text-muted:     #86868b;
        --vl-text-inverted:  #ffffff;

        /* Border hierarchy */
        --vl-border:           #e8e8ed;
        --vl-border-muted:     #f0f0f5;
        --vl-border-lifted:    #d2d2d7;
        --vl-border-accented:  #1d1d1f;

        /* Background hierarchy */
        --vl-bg:           #fbfbfd;
        --vl-bg-muted:     #f5f5f7;
        --vl-bg-lifted:    #ffffff;
        --vl-bg-accented:  #fafafa;
        --vl-bg-inverted:  #1d1d1f;

        /* Typography (Apple system font sizing) */
        --vl-text-xs:  11.5px;
        --vl-text-sm:  13px;
        --vl-text-md:  15px;
        --vl-text-lg:  17px;

        /* Spacing -- focus rings */
        --vl-outline-sm: 2px;
        --vl-outline-md: 3px;
        --vl-outline-lg: 4px;

        /* Rounding -- Apple uses generous rounding + pills */
        --vl-rounding-sm:  8px;
        --vl-rounding-md:  12px;
        --vl-rounding-lg:  999px;

        /* Letter spacing matches Apple SF Pro tracking at body sizes */
        --vl-letter-spacing:    -0.008em;
        --vl-disabled-opacity:  0.5;
    }

    /* Hide old standard_cart wrapper artefacts that the global mytheme
       layout doesn't strip. Without these, the SPA mount has stray
       padding/borders inherited from #order-standard_cart. */
    #order-standard_cart {
        padding: 0 !important;
        background: transparent !important;
    }
    {/literal}</style>

    <div id="order-standard_cart">
        <div id="nexus-root" data-app="cart-module" data-init="{getNexusData}"></div>
    </div>

    <script type="text/javascript" src="{$WEB_ROOT}/templates/orderforms/nexus_cart/js/main.min.js"></script>

{/if}
