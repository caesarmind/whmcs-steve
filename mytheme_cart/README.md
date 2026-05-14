# mytheme_cart

Apple-themed WHMCS 9 **order form / cart theme**. Pairs with `mytheme/` (the client area theme) the same way `nexus_cart/` pairs with `nexus/`.

## What this is

WHMCS 9 splits the client experience into two independent theme types:

| Folder | Server path | Renders |
| --- | --- | --- |
| `mytheme/` | `templates/mytheme/` | Client area pages: dashboard, services, invoices, support, `/store/order` (product configure) |
| **`mytheme_cart/`** | `templates/orderforms/mytheme_cart/` | The cart + checkout flow: `viewcart`, `domainregister`, `checkout` |

This folder is the second of those two. Activate it in **Configuration → System Settings → General Settings → Ordering** (or per product group).

## Structure

```
mytheme_cart/
├── theme.yaml         # parent: nexus_cart  (inherit the Vue SPA)
├── css/
│   └── custom.css     # Apple visual language via --vl-* overrides
└── README.md          # this file
```

That's the whole theme. The cart UI itself is a locked Vue SPA shipped by WHMCS — see "Customization limits" below.

## How it works

1. `theme.yaml` declares `parent: nexus_cart`. WHMCS loads everything from `nexus_cart` (the SPA mount points `viewcart.tpl` / `domainregister.tpl`, the `main.min.js` Vue bundle, the `common.tpl` page chrome) and then layers our theme on top.
2. `css/custom.css` re-defines the `--vl-*` Shadow-DOM variables that the SPA's components read. Our values come straight from `apple-client-area/css/apple-theme.css`, so the cart looks like the rest of the Apple-themed client area.
3. Anything outside the SPA Shadow DOM (the wrapper page, header, breadcrumb, footer pulled in from `standard_cart/common.tpl`) is styled by the same tokens via `:root`, plus a small block at the bottom of `custom.css` that sets the Apple system font and link colour on the wrapper.

## Customization limits

Per `WHMCS9-Theme-Development-Documentation.md` §18:

> The layout of Nexus SPA pages cannot be modified — only CSS customization is allowed.

That covers the four SPA-rendered pages: **domain pricing**, **domain search results**, **view cart**, and **checkout**. Their HTML structure is locked. The four CSS variable categories below are what we can move:

- **Colors** — `--vl-primary`, `--vl-secondary`, `--vl-success`, `--vl-info`, `--vl-notice`, `--vl-warning`, `--vl-error`, `--vl-grayscale`, `--vl-neutral` (each with `-lifted` and `-accented` variants)
- **Text / border / background hierarchy** — `--vl-text*`, `--vl-border*`, `--vl-bg*`
- **Typography** — `--vl-text-xs`, `--vl-text-sm`, `--vl-text-md`, `--vl-text-lg`
- **Geometry** — `--vl-outline-*`, `--vl-rounding-*`, `--vl-letter-spacing`, `--vl-disabled-opacity`

If you need to change the actual cart layout (rearrange columns, add a hero, remove a section), the only options are: (a) override `viewcart.tpl` / `domainregister.tpl` to swap the SPA out for traditional Smarty templates from `standard_cart`, or (b) inject changes via post-render JS — both fall outside what this theme is doing.

## Local preview

This theme cannot be previewed inside the apple-client-area dev server — the Vue SPA and the `{getNexusData}` Smarty function only exist on a real WHMCS install. For visual reference, the Apple-themed mockups that match how this theme should look once rendered live at:

| Mockup | Maps to |
| --- | --- |
| [apple-client-area/cart.html](../apple-client-area/cart.html) | `viewcart.tpl` (full cart) |
| [apple-client-area/cart-empty.html](../apple-client-area/cart-empty.html) | `viewcart.tpl` (empty state) |
| [apple-client-area/cart-domain-register.html](../apple-client-area/cart-domain-register.html) | `domainregister.tpl` (register flow) |
| [apple-client-area/cart-domain-transfer.html](../apple-client-area/cart-domain-transfer.html) | `domainregister.tpl` (transfer flow) |
| [apple-client-area/checkout.html](../apple-client-area/checkout.html) | `checkout.tpl` (inherited from `standard_cart`) |
| [apple-client-area/store/order.html](../apple-client-area/store/order.html) | **`mytheme/store/order.tpl`** — lives in the *client area* theme, NOT here |

The last row is the catch we just untangled: `/store/order` (the per-product configure form that submits to `cart-order-addtocart`) is a **client area** route in WHMCS 9, so its template lives in `mytheme/`, not `mytheme_cart/`. It pairs with `nexus/store/order.tpl`, not anything inside `nexus_cart/`.

## Install on the server

```bash
# from the WHMCS root
cp -R mytheme_cart  templates/orderforms/mytheme_cart
```

Then in WHMCS admin: **Configuration → System Settings → General Settings → Ordering → Order Form Template → mytheme_cart**.

Preview from any URL with `?carttpl=mytheme_cart`, e.g.:

```
https://your-domain/cart.php?carttpl=mytheme_cart
```

## Extending

If you later decide you want to move past CSS-only customization, the two practical escape hatches are:

1. **Override the SPA mount with traditional templates.** Drop `viewcart.tpl` and `domainregister.tpl` into this folder, copy them from `standard_cart` (not `nexus_cart`), and you get full Smarty control at the cost of the SPA's reactivity.
2. **Override non-SPA pages.** `configureproduct.tpl`, `products.tpl`, `checkout.tpl`, and `signup.tpl` from `standard_cart` are regular Smarty and can be redesigned freely — they're outside the SPA constraint.

For the matching reference TPL set, look at `templates/orderforms/standard_cart/` on your WHMCS install.
