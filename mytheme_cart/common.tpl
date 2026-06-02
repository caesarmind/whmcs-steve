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
<link rel="stylesheet" href="{$WEB_ROOT}/templates/orderforms/{$carttpl}/css/style.min.css?v={$myTheme.assetVersion|default:'18'}">

{* --vl-* token overrides (safety net -- applies inside any Vue Shadow DOM that loads) *}
<link rel="stylesheet" href="{$WEB_ROOT}/templates/orderforms/{$carttpl}/css/custom.css?v={$myTheme.assetVersion|default:'18'}">

{* Inherited from standard_cart: scripts.min.js defines recalctotals(),
   selectChangeNavigate(), the addon-recommendations modal trigger, and
   other cart-page JS that WHMCS expects available globally. mytheme_cart
   doesn't ship its own scripts.min.js, so load standard_cart's directly
   -- it lives at templates/orderforms/standard_cart/js/scripts.min.js
   on the server regardless of which orderform is active. *}
<script src="{$WEB_ROOT}/templates/orderforms/standard_cart/js/scripts.min.js?v={$myTheme.assetVersion|default:'18'}"></script>

{* ── Opt the whole order form OUT of the client-area "controls outside"
      card treatment ──────────────────────────────────────────────────
   mytheme's header emits data-svc-layout (Hooks::resolveSvcLayout runs on
   EVERY page, cart pages included) and defaults it to "outside". The
   apple-layout.css "outside" rules flatten any bare .card that lacks a
   .card-header/.card-body child -- transparent bg, no border/radius/shadow
   -- which is right for client-area service/billing LIST cards but wrong
   for the cart, whose cards (.cp-section, .ct-product, .st-guarantee,
   .cd-domain-card, …) are bespoke solid panels. Left as "outside" the cart
   loses every card background (see configureproduct / viewcart).

   The order form is never a controls-outside list, so force "inside" for
   all cart pages here -- common.tpl is included at the top of every
   order-form template, so document.body already exists and the cards below
   paint with the corrected attribute (no flash). Same idiom viewinvoice /
   viewquote / clientareainvoices use for their bespoke (no .card-body)
   cards. We deliberately don't touch data-subnav-* -- the cart manages its
   own sub-nav scope (data-subnav-order). *}
<script>
(function () {
    var b = document.body;
    if (b) b.setAttribute('data-svc-layout', 'inside');
})();
</script>
