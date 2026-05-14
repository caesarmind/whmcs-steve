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

`mytheme_cart` inherits from `standard_cart` — **not** `nexus_cart`. We're rebuilding the cart UI as traditional Smarty templates instead of inheriting the locked Vue SPA, because the user wanted full visual + structural control across the cart flow.

The trade-off: we lose the SPA's client-side reactivity (real-time cart updates, AJAX-driven domain validation), but gain full Apple-language styling control and the ability to redesign any page. Nexus's SPA can still be re-inherited later by flipping `parent` back in `theme.yaml`.

## File status

| File | Status | Source mockup |
| --- | --- | --- |
| `theme.yaml` | ✓ | — |
| `css/style.min.css` | ✓ | `apple-client-area/store.html` (.st-* layout) + dynamic-store block fallbacks (.ds-*) from `apple-client-area/store/wordpress-hosting.html` |
| `css/custom.css` | ✓ | — (Apple `--vl-*` tokens for any Shadow DOM fallback) |
| `common.tpl` | ✓ | — (shared partial — loads CSS + resets WHMCS chrome) |
| `products.tpl` | ✓ | `apple-client-area/store.html` (sidebar + plan grid + cycle pills + guarantees) |
| `configureproductdomain.tpl` | ✓ | `apple-client-area/configureproductdomain.html` (domain method picker — register / transfer / use own) |
| `viewcart.tpl` | ✓ | `apple-client-area/cart.html` + `cart-empty.html` |
| `configureproduct.tpl` | ✓ | `apple-client-area/configureproduct.html` |
| `checkout.tpl` | ✓ | `apple-client-area/checkout.html` |
| `domainregister.tpl` | ✓ | `apple-client-area/cart-domain-register.html` |
| `domaintransfer.tpl` | ✓ | `apple-client-area/cart-domain-transfer.html` |
| `signup.tpl` | ✓ | `apple-client-area/clientregister.html` |
| `sidebar-categories.tpl` | ✓ | reusable partial extracted from `products.tpl` sidebar |

## Smarty variable shapes (what we actually learned from live rendering)

The first deploy hit two classes of bugs that turned out to be hidden assumptions in the WHMCS 9 docs. These are the empirical shapes confirmed against the live `bill.hostnodes.com` install:

### `$products` is an ARRAY of associative arrays

Each `$product` item looks like:

```php
[
    'pid'         => 12,             // (sometimes also .id — use $product.pid|default:$product.id)
    'name'        => 'Pro Plan',
    'description' => 'Built for…',   // string, can contain HTML
    'paytype'     => 'recurring',    // 'recurring' | 'onetime' | 'free'
    'pricing'     => [
        'type'         => 'recurring',  // ← METADATA, not a price. Skip it.
        'monthly'      => '$2.99 USD',
        'quarterly'    => '$8.97 USD',
        'semiannually' => '$17.94 USD',
        'annually'     => '$35.88 USD',
        'biennially'   => '$71.76 USD',
        'triennially'  => '...',
        'minimum'      => '...',         // ← min cycle, also metadata
    ],
    // ...
]
```

**Do NOT** call methods on `$product` — `$product->isFree()` and `$product->pricing()->first()` will fatal with *"Call to a member function on array"*. The WHMCS 9 docs §27 show object syntax (`$plan->pricing()->first()->toPrefixedString()`); that's only valid in the **dynamic-store** context, not the traditional `products.tpl` cart-product loop.

Read cycle prices directly: `$product.pricing.monthly`, `$product.pricing.annually`, etc. Skip the `'type'` and `'minimum'` keys when iterating — they're metadata, not prices. Cycles that are disabled for a product show `'-1.00'` and should be skipped too.

### `$productgroups` / `$productgroup` can be array OR object

Depends on WHMCS minor version. The TPLs use a dual-fallback `$cat.id|default:$cat->id` pattern so the same code works for both shapes.

### `{lang key='X'|default:'Y'}` does NOT fall back when the key is missing

WHMCS's `{lang}` returns the **key itself** when there's no translation, which is a non-empty string, so the `|default:` modifier never fires. The whole `mytheme_cart/` set hardcodes English copy directly instead — admins who want localization should drop a language override file at `lang/overrides/<locale>.php` or override the TPLs in a child theme. The only `{lang key=…}` reference left is `orderpaymenttermfree`, which is a real WHMCS-shipped key.

## Cart-template-agnostic chrome

`mytheme/` (the client-area theme) wraps every order-form page inside its own `.content-area` regardless of which cart template is active. Three pieces of integration live in `mytheme/` so any cart template — `mytheme_cart`, `standard_cart`, `nexus_cart`, anything else — renders correctly:

1. **Wrapper resets** (`assets/css/apple-layout.css` → `Cart-page wrapper integration`): hide WHMCS's duplicate `.main-navbar-wrapper`, flatten `#main-body` padding, neutralize `#order-standard_cart` so our `.content-area` controls spacing.
2. **Bootstrap-grid + utilities shim** (same file → `Bootstrap grid + utilities shim for legacy cart templates`): provides `.row` / `.col-md-*` / `.panel` / `.card` / `.list-group` / `.btn` / `.alert` / form / utility rules in Apple visual tokens. Classic WHMCS order-form templates expect Bootstrap to be loaded by the client-area theme; mytheme uses its own design system, so without this shim the layout collapses to an unstyled stack.
3. **Bootstrap-JS escape hatch** (`header.tpl`): conditionally loads jQuery 3.7.1 + Bootstrap 4.6.2 from CDN **only** when `$templatefile` is a cart-flow value AND the active cart theme is NOT `mytheme_cart`. Lets `standard_cart`'s interactive bits (`data-toggle="tab"`, dropdowns, panel collapse) work without bloating mytheme_cart pages where none of that matters.

All three pieces are targeted on `body[data-tpl="cart" | "viewcart" | "configureproduct" | "configureproductdomain" | "checkout" | "products" | ...]` — the `$templatefile` value WHMCS sets on the wrapper. The chrome stays consistent regardless of which cart template renders the content.

## Common conventions across every TPL

- `{include file="orderforms/$carttpl/common.tpl"}` at the top — loads `style.min.css` + `custom.css`. (The chrome resets are NOT here anymore — see "Cart-template-agnostic chrome" above.)
- Form actions go to real WHMCS endpoints: `cart.php?a=add`, `cart.php?a=view`, `cart.php?a=confproduct&i=N`, `cart.php?a=update`, `cart.php?a=remove`, `cart.php?a=checkout`, `cart.php?a=add&domain=register|transfer`.
- Inline `<style>{literal}…{/literal}</style>` block per page for page-specific component vocabulary (`.ct-*` cart, `.cp-*` configure, `.co-*` checkout, `.dr-*` domain register, `.dt-*` domain transfer, `.su-*` signup). Shared tokens + the `.st-*` products-page styles live in `style.min.css`.
- Cycle pills on `products.tpl` actually filter the displayed plan price (each plan card emits every available cycle as a hidden `.cycle-price[data-cycle-price="X"]` span; the active pill toggles `is-active`). The pill choice is persisted to `sessionStorage` so `configureproduct.tpl` can preselect it.

## Local preview

This theme cannot be previewed inside the `apple-client-area` dev server — the `.tpl` files only run on a WHMCS install. For visual reference, the Apple-themed mockups that match how each page should look:

| Mockup | Maps to |
| --- | --- |
| [apple-client-area/store.html](../apple-client-area/store.html) | **`products.tpl`** (group landing — primary target) |
| [apple-client-area/store/wordpress-hosting.html](../apple-client-area/store/wordpress-hosting.html) | `products.tpl` alt-style — dynamic-store builder marketing landing (only when WHMCS dynamic store is configured) |
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

## Troubleshooting

- **Page shows "Array" or fatals with "member function on array"** — a TPL is calling a method on a variable that's actually an associative array. Switch to dot access (`$x.key`) and use the shapes documented above.
- **Visible label shows as `store.X` or `cart.X`** — a leftover `{lang key='X'}` reference. Replace with the English string directly (only `{lang key='orderpaymenttermfree'}` should remain).
- **Page renders but with the wrong WHMCS chrome** — the parent theme `standard_cart` might not be activated, or the `common.tpl` reset isn't loading. Check that `css/style.min.css` and `css/custom.css` URLs resolve in the page's `<head>`.
