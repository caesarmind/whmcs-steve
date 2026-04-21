# Portal Home

Apple mockup: [portal-home.html](../../portal-home.html)

## WHMCS source

| Field | Value |
|---|---|
| Template file | `homepage.tpl` |
| Route | `/index.php` (root of the WHMCS install) |
| Layout context | Public portal entry page — uses the global header + footer + primary navbar + master breadcrumb |
| Auth state | Renders for **both logged-out and logged-in** users. Body layout is identical in both states; the header chrome differs significantly (topbar missing when logged out, different primary + secondary nav trees, domain form gains a captcha). See [_shared-header-nav.md](_shared-header-nav.md) for header differences. |
| System name | `Home` / `Portal Home` |

## Purpose

First-touch hub. Gives visitors a domain search, a browseable list of product groups sold by the host, a set of self-service shortcuts (KB, status, downloads, ticket), and — when logged in — a shortcut to account/services/domains/billing.

## Breadcrumb

Single crumb: **Portal Home** (active, not linked). No parent.

## Content sections

Sections appear in this order inside `#main-body`:

### 1. Domain Search Banner (always visible)

Full-width band above `#main-body`, inside a `<form action="domainchecker.php">`.

- **Default content**
  - Heading: `Secure your domain name`
  - Text input `name="domain"` (placeholder `eg. example.com`)
  - Two submit buttons: **Search** (`btnDomainSearch`, primary) and **Transfer** (`btnTransfer`, success, `data-domain-action="transfer"`)
  - Hidden `name="transfer"` input toggled by the Transfer button
  - CSRF hidden `name="token"` = `{$token}`
  - Link `View all pricing` → `/index.php/domain/pricing`
  - Mobile variant duplicates the two buttons as block buttons (`btnDomainSearch2`, `btnTransfer2`)
- **Possible / dynamic content**
  - Entire banner is suppressed if the admin has disabled domain registration (`{if $registerdomainenabled || $transferdomainenabled}`).
  - Shows only Search if transfer disabled, only Transfer if register disabled.
  - Domain TLD pricing link only shown if domain pricing page is enabled.
  - **CAPTCHA block** (`.domainchecker-homepage-captcha` / `#default-captcha-domainchecker`) — renders only when the visitor is **logged out** and WHMCS is configured to require captcha on domain search (`{if $captcha && !$loggedin}` in the stock template). Shows the captcha image (`<img id="inputCaptchaImage" src="/includes/verifyimage.php">`) and a 6-char input `name="code"` (`#inputCaptcha`). Google reCAPTCHA is also supported — WHMCS swaps this block for a `g-recaptcha` widget when reCAPTCHA is enabled.
- **Smarty variables**: `$token`, `$registerdomainenabled`, `$transferdomainenabled`, `$domain` (repopulates input on re-submit), `$captcha`, `$captchaForm`, `$captchaType` (`default` | `recaptcha` | `invisible`), `$loggedin`, language keys `$LANG.securedomainname`, `$LANG.domainchecker.search`, `$LANG.transfer`, `$LANG.viewallpricing`, `$LANG.egexample`, `$LANG.captchaverify`.
- **Form action**: `POST domainchecker.php`.

### 2. Browse our Products / Services (always visible)

Section heading + `.card-columns.home` holding one card per WHMCS product group.

- **Default content**: Cards pulled from the `{$productGroups}` loop. Each card renders:
  - `<h3 class="card-title pricing-card-title">` — product group name (`{$productGroup.name}`)
  - `<p>` — group tagline / headline (`{$productGroup.headline}` or `{$productGroup.tagline}`)
  - "Browse Products" CTA → `/index.php/store/{$productGroup.slug}`
  - Always-present hard-coded cards: **Register a New Domain** (`cart.php?a=add&domain=register`) and **Transfer Your Domain** (`cart.php?a=add&domain=transfer`).
- **Possible / dynamic content**
  - Number of cards = number of public product groups defined in `Setup → Products/Services → Product Groups`. Cards can also show per-group feature bullets (`{$productGroup.features}`), a custom image (`{$productGroup.image}`), or a "From $X" starting price (`{$productGroup.starting_price}`), depending on admin config.
  - Domain register/transfer cards only appear when the respective feature is enabled (`$registerdomainenabled`, `$transferdomainenabled`).
- **Smarty variables**: `$productGroups` (array), `$registerdomainenabled`, `$transferdomainenabled`, `$LANG.ourproducts`, `$LANG.browseproducts`, `$LANG.domaincheckerregister`, `$LANG.domaincheckertransfer`.

### 3. How can we help today (always visible)

Section heading + 5-column `.action-icon-btns` row of colored icon cards.

- **Default content** — fixed set of 5 shortcuts, always rendered:
  1. **Announcements** → `/index.php/announcements` (`fa-bullhorn`, teal)
  2. **Network Status** → `serverstatus.php` (`fa-server`, pomegranate)
  3. **Knowledgebase** → `/index.php/knowledgebase` (`fa-book`, sun-flower)
  4. **Downloads** → `/index.php/download` (`fa-download`, asbestos)
  5. **Submit a Ticket** → `submitticket.php` (`fa-life-ring`, green)
- **Possible / dynamic content**
  - Links may be hidden if the matching module is disabled in WHMCS (`{if $announcementsenabled}`, `{if $networkissuesenabled}`, etc.). When a module is off, the `<div class="col…">` for that card should not render, and the grid reflows (that's why the existing markup uses responsive `offset-*` classes).
  - Label text is language-keyed and can be rebranded per-locale.
- **Smarty variables**: `$announcementsenabled`, `$networkissuesenabled`, `$kbenabled`, `$downloadsenabled`, `$ticketsenabled`, corresponding `$LANG.*` keys.

### 4. Your Account (always rendered)

Section heading + second `.action-icon-btns` row. **Rendered regardless of auth state.** Not wrapped in `{if $loggedin}` in the stock template — each link simply points at a protected client-area URL that triggers a login redirect when hit anonymously. (Confirmed by inspecting both logged-in and logged-out renders of this page — body markup is identical.)

- **Default content** — 5 shortcuts (`card-accent-midnight-blue`):
  1. **Your Account** → `clientarea.php`
  2. **Manage Services** → `clientarea.php?action=services`
  3. **Manage Domains** → `clientarea.php?action=domains` (the `<div class="col…">` wrapper is conditional on `$domainsenabled`)
  4. **Support Requests** → `supporttickets.php`
  5. **Make a Payment** → `clientarea.php?action=masspay&all=true`
- **Possible / dynamic content**
  - Manage Domains card hidden when the domains module is disabled (`{if $domainsenabled}`).
  - Support Requests can be hidden if the ticket system is disabled (`{if $ticketsenabled}`).
  - Make a Payment — shown by default regardless of outstanding-invoice count (unlike the topbar notification, this card doesn't key off `$unpaidinvoicescount`).
  - Responsive offset classes (`offset-md-2`, `offset-3`, etc.) are hard-coded for the 5-item layout and will reflow oddly if items are hidden. If a host disables domains, the Downloads/Ticket offset classes in the sibling "How can we help" row should be recalculated — same consideration applies here.
- **Smarty variables**: `$domainsenabled`, `$ticketsenabled`, `$LANG.youraccount`, `$LANG.manageservices`, `$LANG.managedomains`, `$LANG.supportrequests`, `$LANG.makepayment`.

## Header / Footer (global, same on all pages)

The topbar, brand navbar, primary navbar, secondary (account) navbar, master breadcrumb, language modal, and footer all come from `header.tpl` / `footer.tpl` — **not** from `homepage.tpl` — and appear identically on every client-area page.

See [_shared-header-nav.md](_shared-header-nav.md) for the full spec: menu trees (`$primaryNavbar`, `$secondaryNavbar`), auth-state toggles, hooks, language modal, masquerade controls, CSRF/assets, and conversion notes.

**Breadcrumb on this page**: single crumb `Portal Home` (already covered above).

## Forms & actions

| Form ID | Method | Action | Purpose |
|---|---|---|---|
| `frmDomainHomepage` | POST | `domainchecker.php` | Domain search or transfer |

## Conversion notes (for Apple theme)

- The Apple mockup replaces this page's visual identity entirely but must **preserve the same functional slots**: domain search → domain checker, product group cards → loop over `$productGroups`, help shortcuts → conditional on module enable flags, account shortcuts → inside `{if $loggedin}`.
- Language strings must route through `{$LANG.*}` keys, not hard-coded English.
- The mockup's static text in product-group cards (e.g. "Product Group Tagline") is a placeholder — the Smarty output must come from `$productGroups`.
- CSRF token must be emitted via `{$token}` for any form.
- Keep the masquerade-admin return strip functional when `$adminMasqueradingAsClient` is true.
- FontAwesome classes used on icons (`fal fa-bullhorn`, etc.) can be swapped for any icon set the Apple theme ships — but the five help shortcuts and five account shortcuts must remain wired to the same URLs.
