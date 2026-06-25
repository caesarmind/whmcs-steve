# hadrian_cart

Apple-themed WHMCS 9 **order form / cart theme**. Pairs with `hadrian/` (the client area theme) the same way `nexus_cart/` pairs with `nexus/`.

## What this is

WHMCS 9 splits the client experience into two independent theme types:

| Folder | Server path | Renders |
| --- | --- | --- |
| `hadrian/` | `templates/hadrian/` | Client area pages: dashboard, services, invoices, support, `/store/order` |
| **`hadrian_cart/`** | `templates/orderforms/hadrian_cart/` | The cart + checkout flow (`viewcart`, `configureproduct`, `configureproductdomain`, `checkout`, `domainregister`, etc.) |

This folder is the second of those two. Activate it in **Configuration → System Settings → General Settings → Ordering** (or per product group).

## Architecture: thin theme, not a full rewrite

Originally this folder shipped a complete Apple-language rewrite of every cart-flow template (configureproductdomain, viewcart, checkout, signup, etc.). After deploying, three failure classes surfaced:

1. **Form-field contract mismatch.** WHMCS's cart action handlers expect very specific field names (`domainoption`, `sld`/`tld`, `transfersld`/`transfertld`, `owndomainsld`/`owndomaintld`, `incart=1`, `pid`, …). Custom TPLs that diverge silently re-render the same page or fatal in the activity log.
2. **JS contract mismatch.** Standard_cart's `scripts.min.js` orchestrates a two-form pattern (`#frmProductDomain` for UI, `#frmProductDomainSelections` for the actual POST) keyed on specific element IDs (`#registersld`, `#registertld`, `#transfersld`, …). Replacing this with a custom flow loses domain availability checks, multiselect-driven cycle pickers, the AI-search advanced TLD picker, etc.
3. **PHP variable shape mismatches.** `$products`, `$product.pricing`, `$productgroup`, etc. shift between array and object across the cart flow. Defensive access via `.X|default:->X` patches each instance but is brittle.

The pragmatic resolution: inherit from `standard_cart` and only override what we can ship correctly. hadrian_cart is now a **thin Apple skin** rather than a full rewrite.

## What this folder contains

| File | Purpose |
| --- | --- |
| `theme.yaml` | `parent: standard_cart` — inherits every TPL we don't override |
| `css/style.min.css` | Apple-language stylesheet — owns hero, plan grid, sidebar, cycle pills, etc. |
| `css/custom.css` | `--vl-*` Shadow-DOM tokens (light + dark mode) — safety net for any Vue SPA leakage |
| `common.tpl` | Loads `style.min.css` + `custom.css`. Standard_cart's `common.tpl` (via inheritance) still loads `all.min.css` + `scripts.min.js` |
| `products.tpl` | **Custom Apple-language override** — 2-col sidebar + plan grid + cycle pills + guarantees. Matches `apple-client-area/store.html` |
| `sidebar-categories.tpl` | **Custom Apple-language override** — the left rail with Categories + Actions. Used by `products.tpl` |
| `README.md` | This file |

Every other cart-flow template (`viewcart`, `configureproduct`, `configureproductdomain`, `checkout`, `domainregister`, `domaintransfer`, `signup`, `addons`, `complete`, …) falls through to `standard_cart`'s versions. They're styled to look Apple-ish via:

- The **CSS resets + Bootstrap shim** in `hadrian/templates/hadrian/assets/css/apple-layout.css` (search for `Cart-page wrapper integration` and `Bootstrap grid + utilities shim`). Bootstrap classes (`.row`, `.col-md-*`, `.panel`, `.card`, `.list-group`, `.btn`, `.alert`) get rendered using Apple visual tokens, scoped to `body[data-tpl="cart"|"viewcart"|"configureproduct"|…]`.
- The **conditional jQuery + Bootstrap + multiselect + csrfToken load** in `hadrian/templates/hadrian/header.tpl`. These are loaded on every cart-flow page (regardless of which cart template is active) so `standard_cart`'s `scripts.min.js` has the dependencies it expects.

## Why we kept `products.tpl`

The store product-group landing page (`/store/<group-slug>` → `products.tpl`) is the customer's first impression — it's a static display of plan cards with no complex form logic, no `scripts.min.js` JS dependencies, and no field-contract gotchas. A custom Apple-language rewrite there is high-impact (visually-rich entry point) and low-risk (no form pipeline to break).

For every other cart-flow page, the cost/benefit flips: those pages have heavy form + JS contracts with WHMCS, and the visual gain from Apple-fying them doesn't outweigh the maintenance burden. They're styled by the CSS shim to look consistent enough.

## Re-introducing custom TPLs

If you ever want to bring back a custom Apple-language TPL for, say, `viewcart.tpl`:

1. Copy `standard_cart/standard_cart/viewcart.tpl` as a starting point (don't write from scratch — the form-field contract is non-obvious).
2. Reshape the HTML/CSS with Apple tokens, but **keep every `name=`, `id=`, hidden input, and form `action=`** WHMCS expects.
3. Keep the JS load in `hadrian/header.tpl` enabled — `scripts.min.js` still needs to bind handlers.
4. Test the full flow (Order Now → Configure Domain → View Cart → Checkout → Complete) end-to-end. The earlier custom TPLs failed in subtle ways at each transition.

The git history of this folder has the previous full-rewrite TPLs at commit `7e01514` and before, available via `git show 7e01514:hadrian_cart/viewcart.tpl` etc., if you want to reference them.

## Cart-template-agnostic chrome

`hadrian/` (the client-area theme) wraps every order-form page inside its own `.content-area` regardless of which cart template is active. Three pieces of integration live in `hadrian/` so any cart template — `hadrian_cart`, `standard_cart`, `nexus_cart`, anything else — renders correctly:

1. **Wrapper resets** (`assets/css/apple-layout.css` → `Cart-page wrapper integration`): hide WHMCS's duplicate `.main-navbar-wrapper`, flatten `#main-body` padding, neutralize `#order-standard_cart` so our `.content-area` controls spacing.
2. **Bootstrap-grid + utilities shim** (same file → `Bootstrap grid + utilities shim for legacy cart templates`): provides `.row` / `.col-md-*` / `.panel` / `.card` / `.list-group` / `.btn` / `.alert` / form / utility rules in Apple visual tokens. Classic WHMCS order-form templates expect Bootstrap to be loaded by the client-area theme; hadrian uses its own design system, so without this shim the layout collapses to an unstyled stack.
3. **Bootstrap-JS + globals injection** (`header.tpl`): conditionally loads jQuery 3.7.1 + Bootstrap 4.6.2 + bootstrap-multiselect 1.1.2 from CDN, and defines `csrfToken` / `language` / `WEB_ROOT` / `markdownGuideUri` as top-level globals — all the things `standard_cart`'s `scripts.min.js` references at runtime.

All three pieces are gated on `body[data-tpl="cart" | "viewcart" | "configureproduct" | ...]` — the `$templatefile` value WHMCS sets on the wrapper — so they apply on cart-flow pages only.

## Install on the server

```bash
# from the WHMCS root
cp -R hadrian_cart  templates/orderforms/hadrian_cart
```

Then in WHMCS admin: **Configuration → System Settings → General Settings → Ordering → Order Form Template → hadrian_cart**.

Preview from any URL with `?carttpl=hadrian_cart`, e.g.:

```
https://your-domain/cart.php?carttpl=hadrian_cart
https://your-domain/index.php/store/wordpress-hosting?carttpl=hadrian_cart
```

## Troubleshooting

- **Page shows "Array" or fatals with "member function on array"** — a TPL is calling a method on a variable that's actually an associative array. Switch to dot access (`$x.key`).
- **Page renders unstyled (no Apple look)** — `hadrian/`'s CSS isn't loading, or the `data-tpl` body attribute is missing (custom WHMCS pages don't always set `$templatefile`). Check `view-source` for the `<body data-tpl="...">`.
- **Form submit refreshes the same page** — WHMCS field-name mismatch. Inspect what fields `standard_cart`'s version of the same TPL submits and align the names.
- **JS error like `$ is not a function` or `.tooltip is not a function`** — the conditional script load in `hadrian/header.tpl` is being skipped. Confirm `$templatefile` is one of the cart-flow values listed in that conditional.
