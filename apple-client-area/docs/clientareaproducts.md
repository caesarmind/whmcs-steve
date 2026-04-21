# clientareaproducts.html — My Services

The authenticated list of active products/services the client has with the provider.
This is a **dashboard page** — it always renders with the fixed sidebar + topbar
shell (no top-nav / rail variants).

Preview URL: `http://localhost:3002/clientareaproducts.html`

---

## Changelog

- **2026-04-20** — Fully wired the three layout variants. Clicking the Layout pill-group now
  transforms the page:
  - **Sidebar** (default): fixed 260px sidebar + 44px topbar. No change from baseline.
  - **Top nav**: sidebar hidden, `.client-top-nav` (56px horizontal bar) shown with all 10 primary
    links. `.main-content` margin-left resets to 0 so content is full-width.
  - **Icon rail**: sidebar collapsed to 60px. Brand wordmark, search, section labels, item labels,
    badges, and user info/email all hidden. Centered icons remain. On hover, a floating tooltip
    shows the item's label (sourced from `data-label` attribute on each `<a class="sidebar-item">`).
    `.main-content` margin-left becomes 60px.
  - Responsive breakpoint: below 820px, the Sidebar layout auto-collapses to rail behavior so the
    sidebar doesn't eat the whole screen.
  - Sidebar `<a>` tags now wrap their text in `<span class="sidebar-label">…</span>` so rail mode
    can hide labels without losing them from the DOM.
- **2026-04-20** — Added Auth (Logged in / Logged out) and Layout (Top nav / Sidebar / Icon rail) pill-groups
  to the dev preview chip. State wired to `body[data-auth]` and `body[data-layout]`, persisted in
  `localStorage`.
- **2026-04-20** — Added draggable, translucent dev preview chip (top-center) with a Palette picker
  (6 presets: Blue / Emerald / Violet / Rose / Amber / Slate). State persists in `localStorage`.

---

## Page anatomy

### Sidebar (left, fixed, 260px)
- Brand logo + wordmark
- Search input
- Nav sections with colored icons:
  - Dashboard (blue)
  - **Services → `My Services` (active, purple) — badge: 3**
  - Services → My Domains (green, badge: 5)
  - Billing → Invoices (orange, badge: 2), Payment Methods (teal)
  - Support → Support Tickets (red, badge: 1), Knowledge Base (indigo), Announcements (pink)
  - Account → My Details (gray), Security (gray)
- Sidebar footer: user avatar "AH" + name + email

### Topbar (sticky, 44px)
- Breadcrumb: `My Services` (current page, no trailing links)
- System status: green dot · "All systems normal"
- Right actions:
  - Bell (notifications) with red dot
  - Shopping cart icon
  - Profile avatar "AH" (opens profile dropdown — not yet wired on this page; see portal-home.html for the full pattern)

### Content area
- Page header: `My Services` (h1)
- Service list card containing 3 `.service-item` rows:
  1. Business Cloud Pro · hendersondesign.com · Active · Due May 15, 2026 · Manage
  2. WordPress Starter · alexblog.net · Active · Due Jun 1, 2026 · Manage
  3. VPS 4GB — London · api.hendersondesign.com · Active · Due Apr 28, 2026 · Manage
- Page actions row: `Order New Service` primary button

### Dev preview chip (top-center, draggable)
- **Label:** `preview`
- **Groups (three, matching portal-home.html):**
  - **Auth:** Logged out · Logged in (default: Logged in) — sets `body[data-auth]`
  - **Layout:** Top nav · Sidebar (default) · Icon rail — sets `body[data-layout]`
  - **Palette:** Blue · Emerald · Violet · Rose · Amber · Slate (default: Blue) — sets `<html data-palette>`
- **Layout implementation status:** ALL THREE variants are fully wired as of 2026-04-20.
  - **Sidebar** (default): fixed 260px left sidebar — same as the baseline apple dashboard
  - **Top nav**: `.client-top-nav` horizontal bar replaces the sidebar; 10 primary links stack
    horizontally with `.nav-badge` pills; content is full-width
  - **Icon rail**: 60px collapsed sidebar with icon-only items + hover tooltips via `data-label`
    attribute on each sidebar anchor
  - Default Sidebar auto-collapses to rail behavior below 820px viewport width.
- **Auth implementation status:** only the **Logged in** view is rendered.
  Switching to **Logged out** sets `body[data-auth="out"]` for future `.only-in` /
  `.only-out` hooks but no logged-out variant is implemented here.
- **Palette swatches:** 6 circular color wells — click to swap accent color
  across the page via `<html data-palette="...">`. Active swatch shows a white ring.
  Fully functional — no pending implementation.
- **Drag behavior:** grab the `preview` tag on the left. Position persists in
  `localStorage["clientareaProductsChipPos"]`. Double-click the grip to reset.
- **Transparency:** `rgba(28,28,30,0.78)` + `backdrop-filter: saturate(180%) blur(14px)`
- **localStorage keys:**
  - `clientareaProductsAuth` — `"in"` | `"out"`
  - `clientareaProductsLayout` — `"top"` | `"side"` | `"rail"`
  - `clientareaProductsPalette` — `"blue"` | `"emerald"` | `"violet"` | `"rose"` | `"amber"` | `"slate"`
  - `clientareaProductsChipPos` — `{left, top}` after first drag
- **URL overrides:** `?auth=out`, `?layout=rail`, `?palette=violet` (all optional, chainable)

---

## Data / behavior todo

Tracking work that still needs to happen on this page. When the user asks to add
something below, move it to "Changelog" once shipped.

- [ ] Render **Logged out** variant — this would redirect to login, but if kept, show a "not signed in" empty card
- [ ] Wire the topbar profile avatar to a `#profileDropdown` panel (currently static — matches portal-home pattern once added)
- [ ] Make the notifications bell open a dropdown (matches clientareadomainaddons.html)
- [ ] Service-item status pill variants (Active / Pending / Suspended / Terminated)
- [ ] Filter tabs above service list (All / Active / Pending / Expired)
- [ ] Empty state when `services.length === 0`
- [ ] Pagination below list when service count > 10
- [ ] Bulk-action checkboxes + toolbar (cancel / renew / upgrade)
- [ ] Responsive breakpoints — sidebar collapses to drawer below 820px

---

## Design tokens this page uses

- `--color-accent` (primary button, active sidebar icon) — swappable via palette picker
- `--color-surface` (card backgrounds)
- `--color-border` (sidebar/topbar borders, service-item separators)
- `--color-text-primary` (headings, service names)
- `--color-text-tertiary` (breadcrumb inactive, service-meta labels)
- `--sidebar-width` (260px)
- `--topbar-height` (44px)
- `--radius-md` / `--radius-sm` / `--radius-pill`

All token definitions live in `css/apple-theme.css` `:root` + `[data-theme="dark"]`.
Palette overrides live inline in the `<style>` block at the top of this HTML file
(`html[data-palette="..."] { ... }`).

---

## Related pages

- `portal-home.html` — full preview-options chip with Auth + Layout + Palette + 3 layout variants
- `clientareadomainaddons.html` — canonical "top-right works" pattern (bell + cart + avatar dropdown)
- `clientareadomains.html` — sibling list page (domains)
- `clientareainvoices.html` — sibling list page (invoices)

---

## How to extend

1. **Add a new palette:**
   - Add a CSS swatch color rule `.state-chip .swatch-group button[data-palette="newname"] { color: #hex; }`
   - Add an `html[data-palette="newname"] { ... }` block overriding `--color-accent` etc.
   - Add a button to the markup: `<button type="button" data-palette="newname" title="Your Name"></button>`
   - Add `'newname'` to the `valid` array in the `applyPalette` function

2. **Add a new control group to the chip:**
   - Copy the `.chip-group` block, change `label` text, swap `.swatch-group` for `.pill-group`
   - Wire a handler similar to `applyPalette` that toggles a `<body>` or `<html>` attribute
   - Update this MD under "Page anatomy → Dev preview chip"

3. **Add a new service-item to the list:**
   - Duplicate one of the existing `<a class="service-item">` blocks in the card-body
   - Update the product name, domain, status pill, due date
