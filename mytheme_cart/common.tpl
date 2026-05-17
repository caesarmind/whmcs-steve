{*
 * mytheme_cart — common partial included at the top of every cart page.
 *
 * Mirrors the WHMCS standard_cart pattern: every order-form template
 * (products.tpl, viewcart.tpl, configureproduct.tpl, etc.) opens with
 *   {include file="orderforms/$carttpl/common.tpl"}
 * so this is the single place to load shared CSS/JS for THIS cart
 * theme's content.
 *
 * NOTE on wrapper integration:
 * The "hide WHMCS's duplicate navbar" + "flatten #main-body" resets
 * that used to live here are now centralized in mytheme's stylesheet
 * (see apple-layout.css → "Cart-page wrapper integration"). Keeping
 * them there means they apply for ANY cart theme the admin picks —
 * standard_cart, nexus_cart, mytheme_cart, etc. — not just
 * mytheme_cart. Each cart theme just ships its own content; the
 * client-area theme handles the chrome it nests inside.
 *
 * The outer <html>/<head>/<body> shell is rendered by WHMCS using
 * mytheme's header.tpl + footer.tpl, so this file only emits markup
 * that goes INSIDE that wrapper.
 *}

{* Apple-language stylesheet -- owns all cart-page typography, layout, components *}
<link rel="stylesheet" href="{$WEB_ROOT}/templates/orderforms/{$carttpl}/css/style.min.css?v={$myTheme.assetVersion|default:'3'}">

{* --vl-* token overrides (safety net -- applies inside any Vue Shadow DOM that loads) *}
<link rel="stylesheet" href="{$WEB_ROOT}/templates/orderforms/{$carttpl}/css/custom.css?v={$myTheme.assetVersion|default:'3'}">

{* Inherited from standard_cart: scripts.min.js defines recalctotals(),
   selectChangeNavigate(), the addon-recommendations modal trigger, and
   other cart-page JS that WHMCS expects available globally. mytheme_cart
   doesn't ship its own scripts.min.js, so load standard_cart's directly
   -- it lives at templates/orderforms/standard_cart/js/scripts.min.js
   on the server regardless of which orderform is active. *}
<script src="{$WEB_ROOT}/templates/orderforms/standard_cart/js/scripts.min.js?v={$myTheme.assetVersion|default:'3'}"></script>

{* Plan-layout preference -- restore the user's A/B layout pick from
   localStorage and stamp it onto <body data-plan="x"> BEFORE the variant
   markup renders, so a B-preferring user doesn't flash A on every page
   load. Runs inline here (common.tpl is the first include in every
   cart TPL, executed inside <body> right after WHMCS opens it). The
   toggle UI + click handler live in products.tpl. *}
<script>
(function () {
    try {
        var p = localStorage.getItem('hn-cart-layout');
        if ((p === 'a' || p === 'b') && document.body) {
            document.body.setAttribute('data-plan', p);
        }
    } catch (e) { /* localStorage disabled -- fall back to CSS default (Variant A). */ }
})();
</script>
