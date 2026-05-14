{*
 * mytheme_cart — common partial included at the top of every cart page.
 *
 * Mirrors the WHMCS standard_cart pattern: every order-form template
 * (products.tpl, viewcart.tpl, configureproduct.tpl, etc.) opens with
 *   {include file="orderforms/$carttpl/common.tpl"}
 * so this is the single place to load shared CSS/JS and set up any
 * page-scoped variables.
 *
 * The outer <html>/<head>/<body> shell is rendered by WHMCS using
 * mytheme's header.tpl + footer.tpl, so this file only emits markup
 * that goes INSIDE that wrapper.
 *}

{* Apple-language stylesheet — owns all cart-page typography, layout, components *}
<link rel="stylesheet" href="{$WEB_ROOT}/templates/orderforms/{$carttpl}/css/style.min.css?v={$myTheme.assetVersion|default:'1'}">

{* --vl-* token overrides (safety net — applies inside any Vue Shadow DOM that loads) *}
<link rel="stylesheet" href="{$WEB_ROOT}/templates/orderforms/{$carttpl}/css/custom.css?v={$myTheme.assetVersion|default:'1'}">

{* Hide WHMCS's default cart wrapper styling that fights ours. Inline because
   it's purely defensive and only relevant on cart pages — no point loading
   from CSS the rest of the site has to parse. *}
<style>
    /* WHMCS injects a generic .main-navbar-wrapper on order-form pages —
       mytheme's nav already handles auth + active state, so hide the dupe. */
    .main-navbar-wrapper,
    [data-target="#mainNavbar"] { display: none !important; }

    /* WHMCS's default #main-body padding/background fights edge-to-edge
       hero sections, so flatten it. */
    section#main-body { padding: 0 !important; background: var(--color-bg, #fbfbfd) !important; }
    section#main-body > .container { max-width: none !important; padding: 0 !important; }
</style>
