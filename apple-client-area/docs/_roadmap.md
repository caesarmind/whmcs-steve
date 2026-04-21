# apple-client-area — Cross-page Roadmap

Tracks decisions and patterns that apply to **all** dashboard HTML files,
separate from any single page's own MD.

---

## Standing requirement: dev preview chip on every dashboard page

Every dashboard HTML file (`clientarea*`, `account-*`, `viewinvoice`, `viewticket`,
`supportticket*`, `homepage`, etc.) should eventually get a draggable, translucent
dev preview chip with at minimum these three groups:

- **Auth** — Logged in / Logged out (state: `body[data-auth]`)
- **Layout** — Top nav / Sidebar / Icon rail (state: `body[data-layout]`,
  must actually restructure the DOM, not just set the attribute)
- **Palette** — Blue / Emerald / Violet / Rose / Amber / Slate
  (state: `<html data-palette>`)

**Each page gets its own localStorage keys** scoped by filename prefix so settings
don't leak across pages (e.g. `clientareaProductsPalette`, `clientareaDomainsPalette`, …).

### Layout implementation pattern (fully wired on `clientareaproducts.html` 2026-04-20)

- Add `.client-top-nav` markup at the top of `<body>` (hidden by default, shown when `body[data-layout="top"]`)
- Wrap each sidebar-item's text in `<span class="sidebar-label">…</span>` and add a `data-label` attribute to the anchor for rail-mode tooltips
- Add the six CSS blocks to the page's inline `<style>`:
  - `.client-top-nav` + `.client-top-nav-inner` + `.client-top-nav-brand` + `.client-top-nav-links`
  - `body[data-layout="top"] { … sidebar hidden, top-nav shown, margin 0 … }`
  - `body[data-layout="rail"] { … sidebar 60px, labels/search/section-labels/badges hidden … }`
  - `body[data-layout="rail"] .sidebar-item:hover::after { content: attr(data-label); … }` for hover tooltips
  - `@media (max-width: 820px) { body[data-layout="side"] { … auto-rail … } }` responsive fallback

See `clientareaproducts.html` lines 80–165 (style block) and the `.client-top-nav` markup near the top
of `<body>` for the reference implementation. Copy-paste is fine for now.

### Pages still needing this treatment

Top priority (most-visited client-area pages):
- [ ] `clientareahome.html` — the dashboard
- [ ] `clientareadomains.html`
- [ ] `clientareainvoices.html`
- [ ] `viewinvoice.html`
- [ ] `supportticketslist.html`
- [ ] `viewticket.html`

Medium priority (account + billing):
- [ ] `clientareadetails.html`
- [ ] `clientareasecurity.html`
- [ ] `account-paymentmethods.html`
- [ ] `account-paymentmethods-manage.html`
- [ ] `account-paymentmethods-billing-contacts.html`
- [ ] `account-contacts-manage.html`
- [ ] `account-contacts-new.html`
- [ ] `account-user-management.html`
- [ ] `account-user-permissions.html`
- [ ] `clientareaemails.html`
- [ ] `viewemail.html`
- [ ] `clientareaaddfunds.html`
- [ ] `masspay.html`
- [ ] `clientareaquotes.html`
- [ ] `viewquote.html`
- [ ] `subscription-manage.html`

Domain management:
- [ ] `clientareadomaindetails.html`
- [ ] `clientareadomainaddons.html`
- [ ] `clientareadomaincontactinfo.html`
- [ ] `clientareadomaindns.html`
- [ ] `clientareadomainemailforwarding.html`
- [ ] `clientareadomaingetepp.html`
- [ ] `clientareadomainregisterns.html`
- [ ] `bulkdomainmanagement.html`
- [ ] `domain-pricing.html`

Support:
- [ ] `supportticketsubmit.html`
- [ ] `supportticketsubmit-steptwo.html`
- [ ] `supportticketsubmit-confirm.html`
- [ ] `ticketfeedback.html`
- [ ] `knowledgebase.html`
- [ ] `knowledgebasecat.html`
- [ ] `knowledgebasearticle.html`
- [ ] `announcements.html`
- [ ] `viewannouncement.html`
- [ ] `downloads.html`
- [ ] `downloadscat.html`

SSL / Upgrades / Affiliates:
- [ ] `configuressl-stepone.html`
- [ ] `configuressl-steptwo.html`
- [ ] `configuressl-complete.html`
- [ ] `managessl.html`
- [ ] `upgrade.html`
- [ ] `upgrade-configure.html`
- [ ] `upgradesummary.html`
- [ ] `clientareacancelrequest.html`
- [ ] `affiliates.html`

User:
- [ ] `user-profile.html`
- [ ] `user-password.html`
- [ ] `user-security.html`

Already done:
- [x] `portal-home.html` — full chip with Auth + Layout (all 3 variants) + Palette (6 presets)
- [x] `clientareaproducts.html` — full chip with Auth + Layout (all 3 variants) + Palette (6 presets)

**Don't port in bulk** — do it on demand when the user asks for a specific page. The implementation
is nearly identical each time, but each page may have its own nuances (e.g. the header bar, forms,
tables) that affect how `body[data-layout="rail"]` and `body[data-layout="top"]` should behave on that page.

---

## Other cross-cutting patterns

- **Profile avatar + dropdown** — the `clientareadomainaddons.html` pattern (`.topbar-btn` bell with
  red dot, `.topbar-btn` cart, `.topbar-avatar` circle opening `#profileDropdown`) is canonical.
  Every logged-in page should have it in the top-right of its topbar / nav. See
  `clientareaproducts.md` todo for the wiring checklist.

- **Lang key strategy** — when the apple HTML gets ported to WHMCS `.tpl` files, every hard-coded
  string becomes a `{lang key='...'}` call. See the companion `hostnodes-apple/` theme for the conversion.
  Apple HTML stays English-only as design reference.

- **Dark mode** — `[data-theme="dark"]` already cascades everywhere via `apple-theme.css`. Any new
  bespoke per-page CSS must include a `[data-theme="dark"]` override block if it uses raw hex colors.
