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
    /* ── Apple-themed customization of nexus_cart ──
       nexus_cart auto-loads its own custom.css AFTER any inline styles
       we add here, and that file maps every --vl-* variable from an
       unprefixed --* (e.g. --vl-primary: var(--primary)). So setting
       --vl-* directly gets overwritten. We set the unprefixed --*
       layer instead -- nexus's mapping then carries our values into
       the SPA's Shadow DOM via custom-property inheritance.
       Values mirror apple-client-area/css/apple-theme.css's light
       palette. */
    :root, :host {
        /* Primary -- Apple blue */
        --primary:           #0071e3;
        --primary-lifted:    #0077ed;
        --primary-accented:  #005bb5;

        /* Secondary -- neutral chip / muted button */
        --secondary:           #f5f5f7;
        --secondary-lifted:    #ebebef;
        --secondary-accented:  #e8e8ed;

        /* Status colors */
        --success:           #34c759;
        --success-lifted:    #30b751;
        --success-accented:  #2aa24a;
        --info:              #0071e3;
        --info-lifted:       #0077ed;
        --info-accented:     #005bb5;
        --notice:            #ff9f0a;
        --notice-lifted:     #ff8e00;
        --notice-accented:   #e07a00;
        --warning:           #ff9500;
        --warning-lifted:    #f08a00;
        --warning-accented:  #d97a00;
        --error:             #ff3b30;
        --error-lifted:      #ef352b;
        --error-accented:    #d62d24;

        /* Grayscale / neutral */
        --grayscale:           #1d1d1f;
        --grayscale-lifted:    #2c2c2e;
        --grayscale-accented:  #000000;
        --neutral:           #6e6e73;
        --neutral-lifted:    #86868b;
        --neutral-accented:  #4a4a4f;

        /* Text hierarchy */
        --text:           #1d1d1f;
        --text-lifted:    #6e6e73;
        --text-accented:  #000000;
        --text-muted:     #86868b;
        --text-inverted:  #ffffff;

        /* Border hierarchy */
        --border:           #e8e8ed;
        --border-muted:     #f0f0f5;
        --border-lifted:    #d2d2d7;
        --border-accented:  #1d1d1f;

        /* Background hierarchy */
        --bg:           #fbfbfd;
        --bg-muted:     #f5f5f7;
        --bg-lifted:    #ffffff;
        --bg-accented:  #fafafa;
        --bg-inverted:  #1d1d1f;

        /* Typography (Apple system font sizing) */
        --text-xs:  11.5px;
        --text-sm:  13px;
        --text-md:  15px;
        --text-lg:  17px;

        /* Spacing -- focus rings */
        --outline-sm: 2px;
        --outline-md: 3px;
        --outline-lg: 4px;

        /* Rounding -- Apple uses generous rounding + pills */
        --rounding-sm:  8px;
        --rounding-md:  12px;
        --rounding-lg:  999px;

        /* Letter spacing matches Apple SF Pro tracking at body sizes */
        --letter-spacing:    -0.008em;
        --disabled-opacity:  0.5;
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
