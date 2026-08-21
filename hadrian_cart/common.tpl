{*
 * hadrian_cart — common partial included at the top of every cart page.
 *
 * Mirrors the WHMCS standard_cart pattern: every order-form template
 * (products.tpl, viewcart.tpl, configureproduct.tpl, etc.) opens with
 *   {include file="orderforms/$carttpl/common.tpl"}
 * so this is the single place to load shared CSS/JS for THIS cart
 * theme's content.
 *
 * NOTE on wrapper integration:
 * The "hide WHMCS's duplicate navbar" + "flatten #main-body" resets
 * that used to live here are now centralized in hadrian's stylesheet
 * (see core-layout.css → "Cart-page wrapper integration"). Keeping
 * them there means they apply for ANY cart theme the admin picks —
 * standard_cart, nexus_cart, hadrian_cart, etc. — not just
 * hadrian_cart. Each cart theme just ships its own content; the
 * client-area theme handles the chrome it nests inside.
 *
 * The outer <html>/<head>/<body> shell is rendered by WHMCS using
 * hadrian's header.tpl + footer.tpl, so this file only emits markup
 * that goes INSIDE that wrapper.
 *}

{* Hadrian design-language stylesheet -- owns all cart-page typography, layout, components *}
<link rel="stylesheet" href="{$WEB_ROOT}/templates/orderforms/{$carttpl}/css/style.min.css?v={$hadrian.assetVersion|default:'20'}">

{* --vl-* token overrides (safety net -- applies inside any Vue Shadow DOM that loads) *}
<link rel="stylesheet" href="{$WEB_ROOT}/templates/orderforms/{$carttpl}/css/custom.css?v={$hadrian.assetVersion|default:'20'}">

{* Inherited from standard_cart: scripts.min.js defines recalctotals(),
   selectChangeNavigate(), the addon-recommendations modal trigger, and
   other cart-page JS that WHMCS expects available globally. hadrian_cart
   doesn't ship its own scripts.min.js, so load standard_cart's directly
   -- it lives at templates/orderforms/standard_cart/js/scripts.min.js
   on the server regardless of which orderform is active. *}
<script src="{$WEB_ROOT}/templates/orderforms/standard_cart/js/scripts.min.js?v={$hadrian.assetVersion|default:'18'}"></script>

{* ── Opt the whole order form OUT of the client-area "controls outside"
      card treatment ──────────────────────────────────────────────────
   hadrian's header emits data-svc-layout (Hooks::resolveSvcLayout runs on
   EVERY page, cart pages included) and defaults it to "outside". The
   core-layout.css "outside" rules flatten any bare .card that lacks a
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

{* ── "0.00" -> "Free" for the cart's JS-written price slots ──────────
   Server-rendered prices are converted by includes/free-price.tpl; this
   covers the slots that standard_cart's inherited scripts.min.js (and the
   cart's own inline scripts) write AFTER render: domain-search results
   (primary / spotlight / suggestions), viewcart's period-select rewrite of
   [name="<domain>Price"], and the checkout/viewcart totals ids. Cart-owned
   (not in the theme's JS) so the order form stays self-contained.

   Gated on the data-free-label attribute hadrian's header.tpl stamps on
   <body>; under another client-area theme the attribute is absent and this
   whole block is inert (prices simply stay numeric — fail-safe).

   Same digits-only zero test as includes/free-price.tpl, the theme partial
   and PriceHelper: strip non-digits, free only when the non-empty remainder
   is all zeros. Conversion touches only an element's OWN text nodes, so a
   child span (e.g. the featured-TLD per-year suffix) survives — and its
   digits (e.g. "/3 yrs") never defeat the zero test. Idempotent: the label
   has no digits, so re-running can never double-convert. *}
<script>
(function () {
    var body = document.body;
    if (!body || body.getAttribute('data-free-label') !== '1') return;
    var LABEL = body.getAttribute('data-free-label-text') || 'Free';

    var SELECTOR = [
        '[data-price-display]',
        '.dr-tld-price',
        '.dr-sug-price',
        '.domain-price .price',
        '.ct-product-price .amount',
        '.ct-summary-product-price',
        '#subtotal',
        '#totalDueToday'
    ].join(', ');

    function isZero(text) {
        var digits = String(text).replace(/\D/g, '');
        return digits !== '' && !/[1-9]/.test(digits);
    }

    // Convert the element's own text nodes (children kept intact).
    function convertOwnText(el) {
        var own = '', n;
        for (n = el.firstChild; n; n = n.nextSibling) {
            if (n.nodeType === 3) own += n.nodeValue;
        }
        if (!isZero(own)) return;
        var done = false;
        for (n = el.firstChild; n; n = n.nextSibling) {
            if (n.nodeType === 3) { n.nodeValue = done ? '' : LABEL; done = true; }
        }
    }

    function applyCart() {
        var nodes = document.querySelectorAll(SELECTOR);
        for (var i = 0; i < nodes.length; i++) convertOwnText(nodes[i]);

        // configureproduct's cycle cards are split into .currency/.amount/
        // .period spans by an inline script; when the amount is (or has
        // already been converted to) the label, blank the siblings so the
        // card reads "Free", not "$Free/mo".
        var cards = document.querySelectorAll('.cp-cycle-price');
        for (var j = 0; j < cards.length; j++) {
            var amt = cards[j].querySelector('.amount');
            if (!amt) continue;
            if (isZero(amt.textContent)) amt.textContent = LABEL;
            if ((amt.textContent || '').trim() === LABEL) {
                var cur = cards[j].querySelector('.currency');
                var per = cards[j].querySelector('.period');
                if (cur) cur.textContent = '';
                if (per) per.textContent = '';
            }
        }
    }

    // Shared API for the cart's other scripts (products.tpl cycle switcher,
    // configureproduct's promo sync). The hadrian theme's own JS publishes a
    // compatible window.hnFreePrice for client-area surfaces; adopt that
    // name only when it is not already taken.
    window.hnCartFreePrice = { apply: applyCart, isZero: isZero, label: LABEL };
    if (!window.hnFreePrice) window.hnFreePrice = window.hnCartFreePrice;

    function boot() {
        applyCart();
        // The slots above are (re)written by jQuery AJAX handlers in the
        // inherited scripts.min.js, which this theme cannot patch. Re-running
        // after every AJAX completion is cheap, display-only and idempotent.
        if (window.jQuery) {
            window.jQuery(document).ajaxComplete(function () { applyCart(); });
        }
    }
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', boot);
    } else {
        boot();
    }
})();
</script>
