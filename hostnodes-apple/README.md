# Hostnodes Apple — WHMCS 9 Client Area Theme

Cupertino-inspired client area theme for WHMCS 9. Converted from the `apple-client-area/` static prototype.

## Install

1. Copy the `hostnodes-apple/` folder into `<whmcs>/templates/hostnodes-apple/`.
2. In the WHMCS admin, open **General Settings → General** and set the **Template** to `hostnodes-apple`.
3. Clear `templates_c/` (Utilities → System → PHP Info → "Empty Template Cache").
4. Reload `/login.php` — the apple sign-in card should render.

## Build (SCSS)

`sass/` contains the theme source. `css/theme.css` and `css/theme.min.css` are already compiled for immediate use. To rebuild after editing:

```sh
sass sass/theme.scss:css/theme.css --style=compressed --no-source-map
cp css/theme.css css/theme.min.css
```

> Note: the 2,929 lines of apple-theme.css are currently consolidated inside `sass/_theme.scss`. The other partials listed in `sass/theme.scss` (global, layout, sidebar, topbar, buttons, etc.) are commented stubs — split later as a maintenance task.

## What's included

- **~195 `.tpl` files** covering login, registration, client dashboard, 10 domain management pages, invoices, quotes, support tickets, knowledge base, announcements, downloads, SSL configuration, service upgrades, affiliates, OAuth, and the full store (SSL family + 12 vendor landings + addon/config/dynamic/promos).
- **22 reusable includes** in `includes/` (sidebar, topbar, head, navbar, flashmessage, alert, panel, modal, captcha, tablelist, pwstrength, generate-password, confirmation, verifyemail, validateuser, network-issues-notifications, linkedaccounts, social-accounts, active-products-services-item, breadcrumb, notification-dropdown, profile-dropdown, domain-search).
- **7 payment partials** in `payment/{card,bank}/` and `payment/{billing-address,invoice-summary}.tpl` for card/bank input forms used during checkout and saved-method flows.
- **4 error pages** in `error/` (page-not-found, internal-error, rate-limit-exceeded, unknown-routepath).
- **Dark-mode** toggle with localStorage persistence (built into the apple-theme CSS via `[data-theme="dark"]`).

## Notes

- **No Bootstrap.** `theme.yaml` omits the `bootstrap:` key; apple CSS is self-contained. jQuery + FontAwesome are still declared because WHMCS core modules rely on them.
- **Server-driven active-nav.** `includes/sidebar.tpl` iterates `$primarySidebar` and uses `$childItem->isCurrent()` for the active class — no JS-based filename detection.
- **WHMCS menus expect the child item's `extra('color')` to be `'blue'`/`'green'`/`'orange'`/`'red'`/`'purple'`/`'teal'`/`'indigo'`/`'pink'`/`'gray'`** to style sidebar icons. Use the Menu Manager or hooks to set these.
- **Store vendor pages** are minimal scaffolds that iterate `$packages` with name, price, cycle, features — adapt per product needs.
- **OAuth layout (`oauth/layout.tpl`)** is a self-contained shell separate from the main header/footer.

## Source references

Kept read-only for visual & variable reference:

- `apple-client-area/` — design source of truth.
- `apple-client-area/css/apple-theme.css` — styling source (now in `sass/_theme.scss`).
- `apple-client-area/js/apple-theme.js` — presentation JS (now adapted in `js/scripts.js`).
- `nexus/` — canonical WHMCS 9 theme with all Smarty variable names.
