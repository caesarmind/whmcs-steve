# Shared Header & Navigation

Not a page — documents the global header rendered on **every** WHMCS client-area page. Lives in `header.tpl` (+ partials). Every page spec in this folder references this instead of repeating it.

## WHMCS source

| Field | Value |
|---|---|
| Template files | `header.tpl` (+ optional partials: `includes/navbar.tpl`, `includes/navmenu.tpl`) |
| Applies to | All client-area and public pages that use the portal chrome (i.e. everything *except* standalone PDF/email/error skeletons that use `minimal.tpl`) |
| Auth state | Single template — conditionally toggles blocks based on `$loggedin` / `$adminMasqueradingAsClient` |

## Structure (top → bottom)

The header renders up to 4 horizontal strips plus a breadcrumb nav below it. **The topbar and the contents of the primary/secondary navbars differ between logged-in and logged-out states — not just by hiding items, but as entirely different menu trees.**

```
┌─ Topbar ────────────────────────────────────────────────┐  LOGGED-IN ONLY
│   notifications · "Logged in as: …" · [masquerade ret.] │  (absent when logged out)
├─ Brand Navbar ─ [logo]  [KB search]      [cart] [burger]┤  always
├─ Primary Navbar ─ (see menu trees below) ───────────────┤  always — tree varies by auth
├─ Master Breadcrumb ─ Portal Home › ... › Current Page ──┤  always
└──────────────────────────────────────────────────────────┘
```

### Auth-state summary

| Strip | Logged out | Logged in |
|---|---|---|
| Topbar | **Not rendered** | Rendered (notifications + active-client + optional masquerade return) |
| Brand Navbar | Same | Same |
| Primary Navbar | "Store" dropdown + flat info links (see tree A) | Client-centric tree with `Services`, `Domains`, `Billing`, `Support`, `Open Ticket` (see tree B) |
| Secondary Navbar | `Account ▾` → Login / Register / Forgot Password | `Hello, {firstname}! ▾` → account management + Logout |
| Home link target | `/index.php` | `/clientarea.php` |
| Language modal form action | `/?` | `/index.php?` |

---

### 1. Topbar (`.topbar`) — logged-in only

Wrapped in `{if $loggedin}`. Contains two halves:

**Left — Notifications popover**

- Default: button labeled `No Notifications` with count badge `0` and `far fa-flag` icon.
- Dynamic: `{$clientAlerts}` array. If populated, the button label becomes the count and the popover body lists each alert (message + severity + optional link). Typical alert types: unpaid invoice, overdue invoice, password-age, expiring domain, product overdue.
- Smarty: `{$clientAlerts}`, `$LANG.nonotifications`, `$LANG.notifications`.

**Right — Active-client + masquerade controls**

- "Logged in as: **{client name}**" — `.btn-active-client` links to `/clientarea.php?action=details`. The name is `{$clientsdetails.fullname}` or, when on a sub-account, `{$activeClient.name}`.
- Account switcher button (`fad fa-random`) → `/index.php/user/accounts` — only shown when the user has access to multiple client accounts (`{if count($usersAccounts) > 1}`).
- **Return to admin** strip — rendered only when `$adminMasqueradingAsClient` is true. Links to `/logout.php?returntoadmin=1`, icon `fas fa-redo-alt`.

---

### 2. Brand Navbar (`.navbar.navbar-light`)

Always visible. Three zones:

- **Brand** — `/index.php` link. Content is `{$logo}` if a logo image is configured in *General Settings*, else `{$companyname}` text fallback.
- **KB Search form** — visible at `≥ xl`. POST `/index.php/knowledgebase/search`, input `name="search"`. Hidden when KB is disabled (`{if $kbenabled}`). Emits `{$token}`.
- **Toolbar (right)** — always present:
  - Cart button → `/cart.php?a=view`, badge `#cartItemCount` = `{$cartitemcount}` (JS keeps it in sync).
  - Mobile burger toggler `data-target="#mainNavbar"` (visible `< xl`).

---

### 3. Primary Navbar (`#mainNavbar`) — the main menu

This is the core of the navigation. Emitted from **`{$primaryNavbar}`** menu object. Below `xl` it collapses into the mobile drawer (which also contains a second copy of the KB search form).

**How WHMCS builds it**

- `$primaryNavbar` is a `WHMCS\View\Menu\Item` tree built at page load. Each node has:
  - `name` → emitted as `menuItemName="…"` and `id="Primary_Navbar-…"` on the `<li>`.
  - `label` → visible text.
  - `uri` → anchor href.
  - `order` → sort order.
  - `badge`, `icon`, `class`, `attributes` → optional adornments.
  - `children` → nested menu (renders as Bootstrap dropdown).
- Hooks can add, remove, reorder, or replace items via `ClientAreaPrimaryNavbar` (public) and `ClientAreaPrimarySidebar` (not this menu but worth knowing).
- Items are **conditionally visible** based on: module enable flags, auth state (some only appear when `$loggedin`), and per-item permission checks.

WHMCS emits **two different default trees** for `$primaryNavbar` depending on `$loggedin`. Both trees are mutable via the `ClientAreaPrimaryNavbar` hook, but the out-of-the-box structure differs significantly.

#### Tree A — Logged-out (public / marketing mode)

Optimised for browsing and self-service — no "my account" operations surfaced.

| menuItemName | Href | Children |
|---|---|---|
| `Home` | `/index.php` | — |
| `Store` | `#` (dropdown) | `Browse Products Services` → `/index.php/store`, **divider**, then product-group / MarketConnect children: `WordPress Hosting` → `/index.php/store/wordpress-hosting`, `socialbee`, `symantec` (SSL Certificates), `threesixtymonitoring` (Site & Server Monitoring), `nordvpn` (VPN), `spamexperts` (E-mail Services), `ox` (Professional Email), `siteBuilder`, `marketgoo` (SEO Tools), `codeguard` (Website Backup), `sitelock` (Website Security), `weebly` (Website Builder), **divider**, `Register a New Domain` → `/cart.php?a=add&domain=register`, `Transfer a Domain to Us` → `/cart.php?a=add&domain=transfer` |
| `Announcements` | `/index.php/announcements` | — (only if `$announcementsenabled`) |
| `Knowledgebase` | `/index.php/knowledgebase` | — (only if `$kbenabled`) |
| `Network Status` | `/serverstatus.php` | — (only if `$networkissuesenabled`) |
| `Contact Us` | `/contact.php` | — |

Note: the logged-out version has **no `Services`, `Domains`, `Billing`, `Support`, or `Open Ticket`** items — those require a session. Instead, everything shoppable is consolidated under `Store ▾`, and the info/support links are surfaced as flat top-level items.

#### Tree B — Logged-in (client-area mode)

Optimised for managing existing services.

| menuItemName | Href | Visible when | Children |
|---|---|---|---|
| `Home` | `/clientarea.php` | always | — |
| `Services` | `#` (dropdown) | always (logged in) | `My Services`, **divider**, `Order New Services` → `/cart.php`, `View Available Addons` → `/cart.php?gid=addons` |
| `Domains` | `#` (dropdown) | `$domainsenabled` | `My Domains`, **divider**, `Renew Domains`, `Register a New Domain`, `Transfer a Domain to Us`, **divider**, `Domain Search` |
| `Website Security` | `#` (dropdown) | MarketConnect enabled | Product shortcuts: `socialbee`, `symantec`, `threesixtymonitoring`, `nordvpn`, `spamexperts`, `ox`, `siteBuilder`, `marketgoo`, `codeguard`, `sitelock`, `weebly`, **divider**, `Manage SSL Certificates` → `/index.php/clientarea/ssl-certificates/manage` |
| `Billing` | `#` (dropdown) | always | `My Invoices`, `My Quotes`, **divider**, `Payment Methods` |
| `Support` | `#` (dropdown) | always | `Tickets`, `Announcements`, `Knowledgebase`, `Downloads`, `Network Status` |
| `Open Ticket` | `/submitticket.php` | `$ticketsenabled` | — |

#### Dividers & general rules

- Dividers inside dropdowns render as `<div class="dropdown-divider"></div>` — emitted by a menu item with `class="dropdown-divider"` and no label.
- `menuItemName` is the stable key hooks target. The visible label comes from `$item->getLabel()` and can be language-keyed.
- Store-linked children (MarketConnect products) only appear when that product is enabled in *Setup → Addons → MarketConnect*. Disabling NordVPN removes its menu child in both trees.
- A hidden overflow dropdown `.collapsable-dropdown` exists for when too many items overflow the bar — JS moves overflowing `<li>` into the `More ▾` dropdown at runtime.

**Smarty**: `{$primaryNavbar}` — rendered via a recursive `{include file="includes/navmenu.tpl" menu=$primaryNavbar}` partial. The partial walks the same tree regardless of auth; auth-based differences are already baked into `$primaryNavbar` by WHMCS before the template runs.

---

### 4. Secondary Navbar — account dropdown

Right-aligned inside the same `#mainNavbar` wrapper. Built from **`{$secondaryNavbar}`**. Like the primary navbar, WHMCS emits a different default tree depending on auth state — both rooted in a single top-level `Account` dropdown but with different labels and children.

#### Logged-out — `Account ▾`

Top-level label is the literal word `Account`. Dropdown contents:

| menuItemName | Href |
|---|---|
| `Login` | `/clientarea.php` (redirects to login form, then back to client area) |
| `Register` | `/register.php` |
| *divider* | — |
| `Forgot Password?` | `/index.php/password/reset` |

#### Logged-in — `Hello, {firstname}! ▾`

Top-level label is `Hello, {$clientsdetails.firstname}!`. Dropdown contents:

| menuItemName | Href |
|---|---|
| `Edit Account Details` | `/clientarea.php?action=details` |
| `User Management` | `/index.php/account/users` |
| `Payment Methods` | `/index.php/account/paymentmethods` |
| `Contacts` | `/index.php/account/contacts` |
| `Email History` | `/clientarea.php?action=emails` |
| *divider* | — |
| `Profile` | `/index.php/user/profile` |
| `Change Password` | `/index.php/user/password` |
| `Security Settings` | `/index.php/user/security` |
| *divider* | — |
| `Logout` | `/logout.php` |

**Hook**: `ClientAreaSecondaryNavbar` mutates this tree. Examples in the wild: adding an "Affiliates" or "Referrals" link when the affiliate module is active.

---

### 5. Master Breadcrumb (`nav.master-breadcrumb`)

Sits **outside** the `<header>` but always renders (except on pages that explicitly suppress it, like standalone cart/checkout wide layouts).

- Built from `{$breadcrumbs}` or `{$breadcrumbNav}` — ordered list of `{label, uri}` objects.
- First crumb is always `Portal Home` → `/index.php`.
- Last crumb is the current page title, unlinked, with `aria-current="page"`.
- Per-page specs should note the expected breadcrumb trail (e.g., Portal Home › Store › SSL Certificates).

---

## Global page bottom — things that live in `footer.tpl`

Not part of the nav but always co-present:

- **Footer bar** — language/currency chooser button (opens `#modalChooseLanguage`), contact link, copyright (`&copy; {$date_year} {$companyname}`).
- **Language modal** (`#modalChooseLanguage`) — item grid from `{$locales}`, submits to current URL with `?language=…`.
- **AJAX loader overlay** (`#fullpage-overlay`) — used by WHMCS JS for long-running actions.
- **Shared system modals** — `#modalAjax` (generic AJAX modal), `#modalGeneratePassword` (password generator, used on any form with a "generate password" helper).

These partials are rendered regardless of the page content.

---

## CSRF & assets injected globally

Inside `<head>`:

- `{$token}` is made available in JS via:
  ```html
  <script>
      var csrfToken = '{$token}',
          markdownGuide = '{$LANG.markdownguide}',
          locale = '{$locale}',
          saved = '{$LANG.saved}',
          saving = '{$LANG.autosaving}',
          whmcsBaseUrl = "{$WEB_ROOT}";
  </script>
  ```
- Dynamic `{$headerincludes}` — emits any CSS/JS added by modules or hooks (`ClientAreaHeadOutput`).
- Font Awesome CSS files are emitted redundantly for "Dynamic Template Compatibility" — a WHMCS quirk where the core injects them in case the theme forgot.

Inside body end (`footer.tpl`):

- `{$footeroutput}` — hook output (`ClientAreaFooterOutput`).
- Global JS bundle: `/templates/{$template}/js/scripts.min.js`.

---

## Hooks that affect the nav

Document these so an AI converting a page knows what's user-configurable:

| Hook | Tree mutated |
|---|---|
| `ClientAreaPrimaryNavbar` | `$primaryNavbar` |
| `ClientAreaSecondaryNavbar` | `$secondaryNavbar` |
| `ClientAreaHeadOutput` | `<head>` additions |
| `ClientAreaFooterOutput` | end-of-body additions |
| `ClientAreaPageStore` | primary navbar items visible on store pages |

---

## Conversion notes (for Apple theme)

- The Apple mockup uses `<nav class="homepage-nav">` with hard-coded menu items and a "mega menu" for Hosting. When converting to Smarty, **the hard-coded list must be replaced** by a recursive walk of `{$primaryNavbar}` — otherwise hook additions/removals and MarketConnect module toggles won't take effect.
- Each `<li>` emitted must preserve `menuItemName="{$item->getName()}"` and `id="Primary_Navbar-{$item->getName()|replace:' ':'_'}"` — this is what hooks target to insert before/after a known anchor.
- The Apple nav's icon row (search, cart, dark-mode, sign in) must map to: KB search form (collapsible), `/cart.php?a=view` with `#cartItemCount` badge bound to `{$cartitemcount}`, theme toggle (Apple-only, not WHMCS), and `Login`/Account dropdown from `{$secondaryNavbar}`.
- Mobile: the burger must toggle a Bootstrap `.collapse` region (or an Apple-styled drawer) that contains **the same `$primaryNavbar` tree** plus the KB search form.
- Masquerade-admin return button must remain present and functional when `$adminMasqueradingAsClient` is true — otherwise support staff get stranded.
- Breadcrumb trail comes from `{$breadcrumbNav}`. Most per-page specs note the expected trail; honor it.
- **Do not hard-code language labels.** Every visible string (`Home`, `Services`, `Hello, {name}!`, `No Notifications`, etc.) must route through `{$LANG.*}` keys or `{$item->getLabel()}`.
