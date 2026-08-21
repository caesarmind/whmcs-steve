# Nexus cart SPA bridge -- archived

This directory holds the pieces that previously powered the
`/cart.php?a=view` page via WHMCS-shipped `nexus_cart`'s Vue SPA
(commits `80139ad` -> `00cfe4f`). The cart was reverted to the
mockup-faithful Smarty-rendered `viewcart.tpl` (commit `8cd392a`)
because the SPA's component tree cannot be made to pixel-match the
Apple mockup -- specifically it lacks the eyebrow tag / icon / mono
domain / "Included addons" header / Manage addons strip / trust
strip elements the design calls for, and CSS can only restyle
existing nodes, not create new ones.

These files are kept here for reference in case we ever revisit the
SPA path (e.g. WHMCS exposes more customization hooks in a future
release).

## Files

### `viewcart.spa-shell.tpl`
The 137-line `hadrian_cart/viewcart.tpl` that mounted the SPA. Drops
into `hadrian_cart/viewcart.tpl` to switch back to the SPA path.
Mounts `<div id="nexus-root" data-app="cart-module" data-init="{getNexusData}">`
and references `nexus_cart`'s compiled `main.min.js` bundle by
absolute URL.

### `apple-theme-spa-bridge.js`
The two IIFEs that lived at the bottom of
`hadrian/templates/hadrian/assets/js/core-theme.js`:

1. **CSS variable seeder** -- sets unprefixed `--primary`, `--bg`,
   `--text`, `--rounding-*`, etc. on `document.documentElement`.
   `nexus_cart/css/custom.css` (auto-loaded by WHMCS regardless of
   active cart theme) does `--vl-primary: var(--primary)` on
   `:host, :root`, so this populates the variable layer the SPA
   inherits through.

2. **Cart page chrome + Shadow DOM tuning**:
   - Inserts `<header.vc-page-header>` + `<div.vc-steps>` 5-step
     strip ABOVE the SPA mount (because WHMCS sanitizes that markup
     out of cart TPL output for authenticated sessions).
   - Adopts a Constructable Stylesheet INSIDE the SPA's open Shadow
     DOM via `adoptedStyleSheets` to override `--vl-rounding-*` /
     `--vl-text-*` / `--vl-letter-spacing` / `--vl-outline-*` with
     Apple values that beat the SPA's compiled `:host` defaults.
   - Walks the shadow DOM and tags duplicate UI elements (the SPA's
     own "Shopping Cart" h1, "Shopping Cart > Checkout" inner
     breadcrumb, and "Browse Products & Services" back-arrow row)
     with `data-apple-hide` for the
     `[data-apple-hide]{display:none}` rule in the same adopted
     stylesheet.
   - `MutationObserver` re-tags on Vue re-render (debounced via
     `requestAnimationFrame`).

The `.vc-page-header / .vc-steps / .vc-step / .vc-step-num /
.vc-step-sep` CSS rules these scripts depend on are still in
`hadrian/templates/hadrian/assets/css/core-theme.css`. Harmless
when no `.vc-*` markup exists -- left in place so this archive is
self-contained.

## To re-enable the SPA path

1. Copy `viewcart.spa-shell.tpl` over `hadrian_cart/viewcart.tpl`.
2. Append the contents of `apple-theme-spa-bridge.js` to the bottom
   of `hadrian/templates/hadrian/assets/js/core-theme.js`.
3. Bump `hadrian/templates/hadrian/core/hadrian.php` `version` so
   the cached `core-theme.js?v=` query string changes and browsers
   re-fetch.
4. Push.

## Why we walked away

The SPA gives reactive cart updates (cycle / addon / promo changes
without full page reload), but its layout is **locked by WHMCS** --
docs section 18: "the layout of Nexus SPA pages cannot be modified
-- only CSS customization is allowed." Pixel-match to the
`apple-client-area/cart.html` mockup needs structural pieces the
SPA doesn't render (eyebrow, icon, mono domain, "Included addons"
header, "Manage addons | Remove all addons" strip, trust strip,
mockup-style upsell rows, no "Addon" badge). CSS cannot create
those nodes; injecting them via JS would fight Vue's re-renders
forever. The Smarty viewcart at `8cd392a` produces the exact mockup
layout end-to-end at the cost of full-page reload on cycle / addon
changes -- which we accepted for visual fidelity.
