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
       and even style="..." attributes on rendered elements all get
       stripped. The only injection points that survive are <script>
       tags and a fixed allowlist of attributes on the mount div
       (id / data-app / data-init).

       So Apple-theme the SPA via JS: set the unprefixed --* CSS
       variables on document.documentElement BEFORE main.min.js runs.
       nexus_cart's custom.css is auto-loaded and maps each --vl-*
       from var(--*), so by the time the Vue app initializes its
       Shadow DOM the variables are in place and inherit through.

       Values mirror apple-client-area/css/apple-theme.css's light
       palette. Kept inline (vs an external file) so a stale CDN
       cache can't strand the page in the wrong palette. *}

    <script>{literal}
    (function () {
        var s = document.documentElement.style;
        var v = {
            // Primary / status (Apple system colors)
            'primary':'#0071e3', 'primary-lifted':'#0077ed', 'primary-accented':'#005bb5',
            'secondary':'#f5f5f7', 'secondary-lifted':'#ebebef', 'secondary-accented':'#e8e8ed',
            'success':'#34c759', 'success-lifted':'#30b751', 'success-accented':'#2aa24a',
            'info':'#0071e3', 'info-lifted':'#0077ed', 'info-accented':'#005bb5',
            'notice':'#ff9f0a', 'notice-lifted':'#ff8e00', 'notice-accented':'#e07a00',
            'warning':'#ff9500', 'warning-lifted':'#f08a00', 'warning-accented':'#d97a00',
            'error':'#ff3b30', 'error-lifted':'#ef352b', 'error-accented':'#d62d24',
            // Grayscale / neutral
            'grayscale':'#1d1d1f', 'grayscale-lifted':'#2c2c2e', 'grayscale-accented':'#000000',
            'neutral':'#6e6e73', 'neutral-lifted':'#86868b', 'neutral-accented':'#4a4a4f',
            // Text / border / background hierarchy
            'text':'#1d1d1f', 'text-lifted':'#6e6e73', 'text-accented':'#000000',
            'text-muted':'#86868b', 'text-inverted':'#ffffff',
            'border':'#e8e8ed', 'border-muted':'#f0f0f5',
            'border-lifted':'#d2d2d7', 'border-accented':'#1d1d1f',
            'bg':'#fbfbfd', 'bg-muted':'#f5f5f7', 'bg-lifted':'#ffffff',
            'bg-accented':'#fafafa', 'bg-inverted':'#1d1d1f',
            // Typography (Apple SF Pro sizing)
            'text-xs':'11.5px', 'text-sm':'13px', 'text-md':'15px', 'text-lg':'17px',
            // Spacing / rounding (Apple uses generous rounding + pills)
            'outline-sm':'2px', 'outline-md':'3px', 'outline-lg':'4px',
            'rounding-sm':'8px', 'rounding-md':'12px', 'rounding-lg':'999px',
            'letter-spacing':'-0.008em', 'disabled-opacity':'0.5'
        };
        for (var k in v) s.setProperty('--' + k, v[k]);
    })();
    {/literal}</script>

    <div id="order-standard_cart">
        <div id="nexus-root" data-app="cart-module" data-init="{getNexusData}"></div>
    </div>

    <script type="text/javascript" src="{$WEB_ROOT}/templates/orderforms/nexus_cart/js/main.min.js"></script>

{/if}
