# mytheme_cart

Apple-themed WHMCS 9 **order form / cart theme**. Pairs with `mytheme/` (the client area theme) the same way `nexus_cart/` pairs with `nexus/`.

## What this is

WHMCS 9 splits the client experience into two independent theme types:

| Folder | Server path | Renders |
| --- | --- | --- |
| `mytheme/` | `templates/mytheme/` | Client area pages: dashboard, services, invoices, support, `/store/order` (product configure) |
| **`mytheme_cart/`** | `templates/orderforms/mytheme_cart/` | The full cart + checkout flow: product group landing (`/store/<slug>`), `viewcart`, `domainregister`, `domaintransfer`, `configureproduct`, `checkout`, `signup` |

This folder is the second of those two. Activate it in **Configuration → System Settings → General Settings → Ordering** (or per product group).

## Parent theme

`mytheme_cart` inherits from `standard_cart` — **not** `nexus_cart`. We're rebuilding the cart UI as traditional Smarty templates instead of inheriting the locked Vue SPA, because the user wanted full visual + structural control across the cart flow (per the "everything needs to rebuild" direction).

The trade-off: we lose the SPA's client-side reactivity (real-time cart updates, AJAX-driven domain validation), but gain full Apple-language styling control and the ability to redesign any page. Nexus's SPA can still be re-inherited later by flipping `parent` back in `theme.yaml`.

## Structure (target)

```
mytheme_cart/
├── theme.yaml             # parent: standard_cart
├── css/
│   ├── style.min.css      # main Apple-language stylesheet (cart-page layout, components)
│   └── custom.css         # --vl-* token overrides (safety net for any Vue SPA bits)
├── common.tpl             # shared header partial (assets + WHMCS chrome reset)
├── products.tpl           # /store/<slug> — product group landing  ← DONE
├── viewcart.tpl           # /cart.php?a=view                       ← TODO
├── configureproduct.tpl   # /cart.php?a=confproduct                ← TODO
├── domainregister.tpl     # /cart.php?a=add&domains=register       ← TODO
├── domaintransfer.tpl     # /cart.php?a=add&domains=transfer       ← TODO
├── checkout.tpl           # /cart.php?a=checkout                   ← TODO
├── signup.tpl             # signup during checkout                 ← TODO
├── sidebar-categories.tpl # left rail with product group list      ← TODO
└── README.md              # this file
```

## Current status

| File | Status | Source mockup |
| --- | --- | --- |
| `theme.yaml` | ✓ | — |
| `css/style.min.css` | ✓ | `apple-client-area/store.html` (.st-* layout) + dynamic-store block fallbacks (.ds-*) from `apple-client-area/store/wordpress-hosting.html` |
| `css/custom.css` | ✓ | — (Apple `--vl-*` tokens for any Shadow DOM fallback) |
| `common.tpl` | ✓ | — |
| `products.tpl` | ✓ | `apple-client-area/store.html` (2-column sidebar + plan grid Variant A) |
| `viewcart.tpl` | ✓ | `apple-client-area/cart.html` + `cart-empty.html` |
| `configureproduct.tpl` | ✓ | `apple-client-area/configureproduct.html` |
| `domainregister.tpl` | pending | `apple-client-area/cart-domain-register.html` |
| `domaintransfer.tpl` | pending | `apple-client-area/cart-domain-transfer.html` |
| `checkout.tpl` | pending | `apple-client-area/checkout.html` |
| `signup.tpl` | pending | `apple-client-area/clientregister.html` |
| `sidebar-categories.tpl` | pending | — (Apple sidebar styling) |

The pending pieces all have approved visual mockups in `apple-client-area/` already (state-chip + `when-full`/`when-empty` per the per-page processing checklist), so each port is mechanical: strip the outer `<html>`/`<body>`/nav/footer (WHMCS provides those), translate hardcoded data into Smarty variables, inline only what doesn't already live in `style.min.css`.

## Local preview

This theme cannot be previewed inside the apple-client-area dev server — the `.tpl` files only run on a WHMCS install. For visual reference, the Apple-themed mockups that match how this theme should look once rendered live at:

| Mockup | Maps to |
| --- | --- |
| [apple-client-area/store.html](../apple-client-area/store.html) | **`products.tpl` (group landing, the actual target)** |
| [apple-client-area/store/wordpress-hosting.html](../apple-client-area/store/wordpress-hosting.html) | `products.tpl` alt-style — dynamic-store builder marketing landing (only relevant if WHMCS dynamic store is configured for a group) |
| [apple-client-area/cart.html](../apple-client-area/cart.html) | `viewcart.tpl` (cart contents) |
| [apple-client-area/cart-empty.html](../apple-client-area/cart-empty.html) | `viewcart.tpl` (empty state) |
| [apple-client-area/cart-domain-register.html](../apple-client-area/cart-domain-register.html) | `domainregister.tpl` |
| [apple-client-area/cart-domain-transfer.html](../apple-client-area/cart-domain-transfer.html) | `domaintransfer.tpl` |
| [apple-client-area/configureproduct.html](../apple-client-area/configureproduct.html) | `configureproduct.tpl` |
| [apple-client-area/checkout.html](../apple-client-area/checkout.html) | `checkout.tpl` |
| [apple-client-area/clientregister.html](../apple-client-area/clientregister.html) | `signup.tpl` |

The single client-area-theme route that's adjacent (not part of this folder):

| Mockup | Maps to |
| --- | --- |
| [apple-client-area/store/order.html](../apple-client-area/store/order.html) | **`mytheme/store/order.tpl`** — `/store/order` is a client-area route, lives in `mytheme/`, NOT here |

## Install on the server

```bash
# from the WHMCS root
cp -R mytheme_cart  templates/orderforms/mytheme_cart
```

Then in WHMCS admin: **Configuration → System Settings → General Settings → Ordering → Order Form Template → mytheme_cart**.

Preview from any URL with `?carttpl=mytheme_cart`, e.g.:

```
https://your-domain/cart.php?carttpl=mytheme_cart
https://your-domain/index.php/store/wordpress-hosting?carttpl=mytheme_cart
```

## Lang-key plumbing

Every visible string in `products.tpl` runs through `{lang key='...'|default:'...'}` so admins can translate via WHMCS's standard language overrides without editing TPLs. The defaults are the English copy from the mockup; new language packs only need to provide the keys that should change.
