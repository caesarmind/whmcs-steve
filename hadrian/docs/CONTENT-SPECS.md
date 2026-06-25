# Hostnodes "hadrian" — Page Content Specifications

A **style-agnostic content blueprint** of every client-area page in the `hadrian` WHMCS 9 theme. Hand this to a design AI to regenerate the theme in a different aesthetic: the specs describe **what content, data, and actions** each page must contain — never how it currently looks.

> **Generated:** 2026-05-26 · Source of truth: the `.tpl` templates under `templates/hadrian/core/pages/`.

---

## How to use this document

- Each page entry is a **content contract**: keep the data, sections, and actions; restyle the presentation freely (colours, type, spacing, components, layout density).
- **Layout shape** is given as a structural hint (e.g. "two-column", "centered card"). A re-skin may change it, but the listed content must survive.
- **Routes and templatefile names are WHMCS conventions** — keep the dispatcher/file names identical when rebuilding, or WHMCS won't find the page.
- Every page also inherits the **global shell** (below). Don't redesign the shell per-page; design it once.

### Per-page schema (legend)

| Field | Meaning |
|---|---|
| **Route** | User-facing URL (WHMCS dispatches by templatefile, not slug). |
| **Purpose** | One sentence: what the user accomplishes here. |
| **Layout shape** | Structural arrangement only (column count, main+aside, table, grid). |
| **Page header** | Eyebrow / H1 / subtitle / status pill contents. |
| **Sections** | Ordered content blocks, top → bottom. |
| **Key data fields** | The dynamic values shown (and table columns). |
| **Actions / CTAs** | Every button, link, and form submit + destination. |
| **States & conditionals** | Empty vs populated, alerts, conditionally-shown blocks. |
| **Interactions** | Client-side behaviour (tabs, toggles, modals, filters). |

---

## The global shell (wraps every page)

Every page renders inside shared chrome from `header.tpl` + `footer.tpl`. The admin picks one of **three main-menu layouts**; the page content fills the main region in all three:

- **Sidebar (default)** — fixed left vertical nav + a slim top utility bar.
- **Rail** — collapsed icon-only left nav.
- **Top** — horizontal top navbar instead of a sidebar.

**Shell components (identical content across layouts):**

- **Brand** — admin-uploaded logo (Branding tab) or the company name as text, linking home.
- **Knowledgebase search** — search box (sidebar layout) that posts to `knowledgebase.php`.
- **Primary navigation** — Dashboard · *Services* (My Services — badge = active service count; My Domains — badge = active domain count) · *Billing* (Invoices — badge = unpaid count; Payment Methods) · *Support* (Support Tickets — badge = open count; Knowledge Base; Announcements) · *Account* (My Details; Security). Counts come from `$clientsstats`.
- **Top utility bar** — breadcrumb (`Home › <current page>`), notifications bell (lists up to 5 published announcements, or "No notifications"), shopping-cart button with item-count badge, and a profile avatar.
- **Profile dropdown** — Account Details · User Management · Payment Methods · Contacts · Email History — divider — Your Profile · Switch Account · Change Password · Security Settings — divider — Dark Mode toggle (only if admin enabled "user choice") — divider — Logout.
- **Breadcrumb (top layout)** — a single "‹ Home" back-link instead of a full trail.
- **Footer** — admin picks **default** (slim copyright row) or **extended** (multi-column sitemap driven by the Footer Menu).
- **Locale modal** — language + currency switcher, opened from the footer.
- **Auth state** — logged-out visitors see a "Sign in" link in place of the profile avatar/menu.

### Dev-only preview harness (NOT page content)

The `<body>` carries `data-*` attributes (`data-layout`, `data-align`, `data-palette`, `data-data=full|empty`, `data-tiles`, `data-form`, `data-plan`, `data-product`) driven by a floating **state-chip** panel and matching URL params. This is a **development preview tool** for toggling layout/skin/data variants — it is not user-facing content and should be ignored when restyling. The one thing worth preserving: pages support an **empty-data state** (`data-data="empty"`) using `.when-full` / `.when-empty` blocks, so every list/dashboard page has both a populated and an empty design.

---

## Shared content components (reused across pages)

These recur throughout; design each once and reuse:

- **Page header** — eyebrow (small overline label) + H1 + optional subtitle + optional status pill. Most content pages open with this.
- **Card** — the primary titled content container; pages compose one or more.
- **Subnav card** — a contextual "Actions" / related-links list (icon + label rows) shown in a right sidebar on detail pages.
- **Status pill / badge** — small state label (Active, Pending, Suspended, Paid, Unpaid, Overdue, Open, Answered, Closed…), colour-coded by state.
- **Alert banner** — inline notice (info / success / warning / error), often with a CTA (e.g. "Pay invoice").
- **Empty state** — icon + message + CTA shown when a list/table has no rows.
- **Data table** — list pages use sortable tables (DataTables on several) with per-row action buttons.
- **Meter / progress bar** — usage visualisations (disk, bandwidth, account credit).
- **Tabs** — in-card tabbed panels (service details, domain details).
- **Stepper** — multi-step flows (SSL config, ticket submit, upgrade) show numbered step progress.

---

## Contents

1. **Authentication, onboarding & utility** — login, register, invites, email verify, 2FA, password reset, access-denied, banned, 3D-Secure, markdown guide.
2. **Core client area, knowledgebase & announcements** — dashboard, services list + details, domains list, quotes, invoices, public homepage, KB (root / category / article), announcements (list / view).
3. **Domain management** — domain details, DNS, email forwarding, register NS, EPP code, addons, contact info, bulk management, TLD pricing.
4. **Billing & upgrades** — view invoice, invoice payment, view quote, add funds, mass pay, cancellation request, subscription manage, usage pricing, upgrade flow (pick / configure / summary).
5. **Support** — tickets list, view ticket, submit ticket flow, custom fields, KB suggestions, confirm, ticket feedback.
6. **Account & profile** — account details, contacts, sub-users + permissions, payment methods + billing contacts, email history, profile, password, security, switch account.
7. **SSL & public/informational** — SSL config wizard, manage SSL, contact, server status, downloads (root / category / denied).

---

# Page specifications

## Authentication, onboarding & utility

### `login` — Sign In
- **Route:** /login (or /index.php?rp=/login); form posts to /dologin.php
- **Purpose:** Authenticate an existing client with email + password.
- **Layout shape:** Centered single card with a page header above it.
- **Page header:** eyebrow = "Account"; H1 = "Sign in"; subtitle = "Welcome back. Enter your credentials to access your account."
- **Sections (top → bottom):**
  1. **Notice banners (conditional)** — logout-success, login-incorrect, expired-verify-link, password-reset-success messages.
  2. **Login form** — Email Address field; Password field with show/hide reveal toggle; "Remember me" checkbox + "Forgot password?" link on the same row; "Sign In" submit button.
  3. **SSO block (conditional)** — "or continue with" divider + a row of SSO provider buttons (icon + label) when providers are configured.
  4. **Footer (conditional)** — "Don't have an account? Create one" link.
- **Key data fields:** username/email, password, remember-me state (`$rememberMe`), CSRF `$token`, optional `$ssoProviders[]` (url, icon, label).
- **Actions / CTAs:** Sign In (→dologin.php); Forgot password? (→pwreset.php); Create one (→register.php); each SSO button (→provider url); password Show/Hide.
- **States & conditionals:** logout/incorrect/verifylinkexpired/passwordResetSuccessful notices each shown only when their flag is set; Remember-me row, Forgot link, Create link, and Eyebrow are each independently toggleable via page config (`allowRemember`, `showForgotLink`, `showCreateLink`, `showEyebrow`); SSO row only if providers exist.
- **Interactions:** password visibility toggle (JS).

### `clientregister` — Create Account
- **Route:** /register (form posts to /register.php with `newcustomer=1`)
- **Purpose:** Register a brand-new client (personal + billing + security details).
- **Layout shape:** Centered single card containing a multi-section form.
- **Page header:** none as a separate header; card title H1 = "Create your account"; sub-line = "Already have an account? Sign in".
- **Sections (top → bottom):**
  1. **Error banner (conditional)** — list of validation errors.
  2. **Personal information** — First name, Last name, Email address, Phone number (optional), Company name (optional).
  3. **Billing address** — Address line 1, City, State/region, Zip/postal code, Country (select populated from `$countries`).
  4. **Account security** — Password, Confirm password.
  5. **Captcha (conditional)** — renders `$captcha` widget if enabled.
  6. **Marketing opt-in checkbox** — "send me product news and special offers."
  7. **Terms checkbox** — "I agree to the Terms of Service" (required) linking to /terms-of-service.
  8. **Submit** — "Create account" button.
- **Key data fields:** firstname, lastname, email, phonenumber, companyname, address1, city, state, postcode, country; password/password2; marketingoptin; accepttos. Sticky values from `$clientsdetails`, country list from `$countries`.
- **Actions / CTAs:** Create account (→register.php); Sign in (→/login); Terms of Service (→/terms-of-service, new tab).
- **States & conditionals:** error banner only on validation failure (string or array); company/phone marked optional; captcha section only if enabled; marketing checkbox pre-checked per `$marketingoptin`.
- **Interactions:** Static, none (standard form submit).

### `user-invite-accept` — Accept Sub-User Invitation
- **Route:** /user-invite-accept?token=X (accept form posts to same with token)
- **Purpose:** Let an invited person accept access to manage another client's account.
- **Layout shape:** Centered single card, icon + heading + body + action buttons.
- **Page header:** none separate; card H1 = "You're invited to access <ClientName>"; sub = "<SenderName> has invited you to manage their account."
- **Sections (top → bottom):**
  1. **Valid-invite branch** — invite icon; title with client name; subtitle naming the sender; optional error banner; a note + action set that differs by login state.
  2. **Invalid-invite branch** — warning icon; "Invitation not found"; subtitle explaining link is invalid/used; single CTA back to client area.
- **Key data fields:** `$invite->getClientName()`, `$invite->getSenderName()`, `$invite->token`, `$loggedin`, `$errormessage`.
- **Actions / CTAs:** (logged in) Accept invitation (POST →user-invite-accept?token=) + Cancel (→clientarea.php); (logged out) Sign in (→/login) + Create account (→/register); (invalid) Continue to client area (→clientarea.php).
- **States & conditionals:** entire layout branches on whether `$invite` exists; within valid invite, logged-in vs logged-out renders different note + buttons; error banner only on validation failure.
- **Interactions:** Static, none.

### `user-verify-email` — Email Verification Result
- **Route:** /verify-email (token-based result page)
- **Purpose:** Show the outcome of clicking an email-verification link.
- **Layout shape:** Centered single card: status icon + heading + message + CTA.
- **Page header:** none separate; card H1 varies by outcome (see below).
- **Sections (top → bottom):**
  1. **Outcome block (one of three)** — Success: check icon, "Email verified", confirmation text. Expired: clock icon, "Verification link expired", text, plus a "Resend verification email" button if logged in. Not-found: X icon, "Verification link not found", text.
  2. **Continue CTA** — always-present "Continue to client area" button.
- **Key data fields:** `$success` (bool), `$expired` (bool), `$loggedin` (bool).
- **Actions / CTAs:** Resend verification email (POST →clientarea.php?action=verify-email-resend, expired+loggedin only); Continue to client area (→clientarea.php).
- **States & conditionals:** three mutually exclusive states (success / expired / not-found); resend button only when expired AND logged in.
- **Interactions:** Static, none.

### `two-factor-challenge` — Two-Factor Authentication Challenge
- **Route:** /login (2FA step); forms post to current URL
- **Purpose:** Enter a 2FA code (authenticator or backup) to complete sign-in.
- **Layout shape:** Centered single card: lock icon + heading + alert + two swappable forms + footer toggle.
- **Page header:** none separate; card H1 = "Two-factor authentication".
- **Sections (top → bottom):**
  1. **Alert / prompt** — success ("Backup code accepted, new codes emailed"), error ("code incorrect" or `$error`), or default prompt ("Enter the verification code from your authenticator app").
  2. **Authenticator form** — renders WHMCS `$challenge` widget (TOTP input / push status); hidden when using backup flow.
  3. **Backup-code form** — Backup code text input (xxxx-xxxx-xxxx) + "Sign in" submit; hidden unless using backup flow.
  4. **Footer toggle** — link switching between "Use a backup code" and "Use authenticator code instead."
- **Key data fields:** `$challenge` (raw 2FA widget HTML), `$usingBackup`, `$incorrect`, `$newbackupcode`, `$error`, `twofabackupcode` input.
- **Actions / CTAs:** Submit authenticator challenge; Sign in (backup-code form); toggle between authenticator/backup modes.
- **States & conditionals:** alert variant chosen by newbackupcode/incorrect/error/default; which form is visible determined by `$usingBackup` (server) and toggled client-side.
- **Interactions:** toggle button swaps visible form and updates its own label (JS).

### `two-factor-new-backup-code` — New Backup Codes
- **Route:** /clientarea.php?action=twofactor&sub=backup
- **Purpose:** Display freshly generated 2FA backup recovery codes for the user to save.
- **Layout shape:** Centered single card: icon + heading + code list + action row + warning.
- **Page header:** none separate; card H1 = "Backup codes".
- **Sections (top → bottom):**
  1. **Intro** — key icon; subtitle "Save these codes somewhere safe. Each one can be used once..."
  2. **Code list** — one or more backup codes rendered as individual items.
  3. **Actions** — "Copy" button (copies all codes) + "Done" button.
  4. **Warning** — "These codes will not be shown again. Once you leave this page they are gone."
- **Key data fields:** `$backupCodes[]` (multiple) or `$backupCode` (single).
- **Actions / CTAs:** Copy (copies all codes to clipboard); Done (→clientarea.php?action=security).
- **States & conditionals:** renders array form if `$backupCodes` present, else single `$backupCode`.
- **Interactions:** Copy button writes all codes to clipboard and briefly shows "Copied" (JS).

### `pwreset` — Password Reset (multi-step flow)
- **Route:** /pwreset (all steps post to /pwreset.php); single template branches on `$templatefile`
- **Purpose:** Reset a forgotten password via email → optional security question → new password.
- **Layout shape:** Centered single card with a 3-dot step indicator at top.
- **Page header:** none separate; card H1 varies per step (see sections).
- **Sections (top → bottom):**
  1. **Step indicator (conditional)** — 3 numbered steps with connecting bars; shown for all steps except the container/landing page; active/done states reflect progress.
  2. **Error banner (conditional)** — validation errors (string or array).
  3. **Container step** — success check icon; "Check your email"; text saying a reset link was sent; "Back to sign in" CTA.
  4. **Email-prompt step (1)** — H1 "Reset your password"; Email address field; optional captcha; "Send reset link" submit; "Back to sign in" link. (hidden `action=reset`.)
  5. **Security-prompt step (2)** — H1 "Verify your identity"; displays `$securityquestion`; Your-answer field; "Continue" submit. (hidden `action=reset` + `key=$verifyhash`.)
  6. **Change-prompt step (3)** — H1 "Choose a new password"; New password + Confirm new password fields; "Set new password" submit. (hidden `action=reset` + `key=$verifyhash`.)
  7. **Fallback** — unknown step renders the step-1 email form.
- **Key data fields:** `$templatefile` (selects step), `$email`, `$verifyhash` (carried token), `$securityquestion`, `$errormessage`, `$passwordresetstatus`, `$captcha`; inputs email / securityanswer / newpw / confirmnewpw.
- **Actions / CTAs:** Send reset link (step 1); Continue (step 2); Set new password (step 3); Back to sign in (container & step 1, →/login).
- **States & conditionals:** which step renders is driven by `$templatefile`; step indicator hidden on container; captcha only if enabled; security step only when a question is set; error banner only on failure.
- **Interactions:** Static, none (server-driven step progression).

### `password-reset-container` — Password Reset (landing/status)
Alias → forwards to `pwreset` (`{include}` of shared template); renders the **container** step: "Check your email" success landing with a Back-to-sign-in CTA.

### `password-reset-email-prompt` — Password Reset (step 1)
Alias → forwards to `pwreset`; renders the **email-prompt** step: enter account email to receive a reset link.

### `password-reset-security-prompt` — Password Reset (step 2)
Alias → forwards to `pwreset`; renders the **security-prompt** step: answer the security question to continue.

### `password-reset-change-prompt` — Password Reset (step 3)
Alias → forwards to `pwreset`; renders the **change-prompt** step: enter and confirm a new password.

### `access-denied` — Access Denied
- **Route:** shown whenever a permission/auth check fails (no fixed URL)
- **Purpose:** Inform the user they lack access to the requested page.
- **Layout shape:** Page header + centered single card (icon + heading + message + action row).
- **Page header:** eyebrow = "Error"; H1 = "Access denied".
- **Sections (top → bottom):**
  1. **Error card** — locked-padlock icon; H2 "You don't have access to this page"; body text (either `$errormessage` if provided, or a generic permission/sign-in-again message); two action buttons.
- **Key data fields:** optional `$errormessage` (specific reason).
- **Actions / CTAs:** Back to dashboard (→clientarea.php); Contact support (→supporttickets.php).
- **States & conditionals:** body text uses `$errormessage` when set, otherwise the default copy.
- **Interactions:** Static, none. (Sets `data-data=full`, `data-subnav=off` on body.)

### `banned` — Account Suspended
- **Route:** shown when a banned account attempts access (no fixed URL)
- **Purpose:** Notify the user their account access is suspended and direct them to support.
- **Layout shape:** Page header + centered single card (icon + heading + message + action).
- **Page header:** eyebrow = "Error"; H1 = "Account suspended".
- **Sections (top → bottom):**
  1. **Error card** — slashed-circle icon; H2 "Your account access is suspended"; body showing ban reason (if any) and expiry (if any), else generic restricted-access text; one action button.
- **Key data fields:** optional `$banreason` (reason text), optional `$banexpires` (expiry date/time).
- **Actions / CTAs:** Contact support (→contact.php).
- **States & conditionals:** reason line shown only if `$banreason` set (else default copy); expiry line shown only if `$banexpires` set.
- **Interactions:** Static, none. (Sets `data-data=full`, `data-subnav=off` on body.)

### `3dsecure` — 3D Secure Payment Verification
- **Route:** reached mid-payment when a gateway requires 3DS (no fixed URL)
- **Purpose:** Render the bank's 3-D Secure challenge inline to complete a card payment.
- **Layout shape:** Page header + info banner + single card holding an iframe.
- **Page header:** eyebrow = "Payment"; H1 = "Verify your payment".
- **Sections (top → bottom):**
  1. **Info banner** — shield icon + "Your bank requires an extra verification step..." text.
  2. **Frame card** — if gateway HTML present: a hidden container holding `$code` (the gateway's auto-submitting 3DS form) + a named iframe (`3dauth`) the challenge loads into. If absent: a loading spinner with "Waiting for the verification challenge..."
- **Key data fields:** `$code` (gateway's 3DS form HTML), `$hasCode` (derived), `$isPreview` (derived from `?preview=1`).
- **Actions / CTAs:** none explicit — the embedded gateway form is auto-submitted into the iframe.
- **States & conditionals:** card shows iframe path when `$code` exists, otherwise the waiting spinner.
- **Interactions:** on load, JS retargets the gateway form to the iframe and auto-submits it after ~800ms. (Sets `data-data=full`, `data-subnav=off` on body.)

### `markdown-guide` — Markdown Guide
- **Route:** /knowledgebase or support context markdown reference (static help page)
- **Purpose:** Reference for the markdown syntax usable in ticket replies/messages.
- **Layout shape:** Page header + responsive grid of syntax cards, with a wider table card below.
- **Page header:** eyebrow = "Support"; H1 = "Markdown guide"; subtitle = "Format your ticket replies and messages with simple markdown syntax."
- **Sections (top → bottom):**
  1. **Syntax card grid** — six cards each with an icon, title, and a code sample: Emphasis (bold/italic/strikethrough), Headers (#/##/###), Lists (bulleted + numbered), Links, Quotes (blockquote), Code (inline + fenced block).
  2. **Tables card** — full-width card with a pipe-table syntax sample + note that source columns need not line up.
- **Key data fields:** none dynamic — all sample text comes from `$LANG['markdown.*']` strings with English defaults.
- **Actions / CTAs:** none.
- **States & conditionals:** none (static reference).
- **Interactions:** Static, none. (Sets `data-data=full`, `data-subnav=off` on body.)

## Core client area, knowledgebase & announcements

### `clientareahome` — Client Home / Dashboard
- **Route:** /clientarea.php (logged-in landing)
- **Purpose:** Account overview hub — at-a-glance counts, active services, recent tickets, register-a-domain, recent news, and account quick-nav.
- **Layout shape:** Two-column: main content column + right sidebar (account sub-nav). Within the main column: counter tiles row, a full-width services card, a 2-up split row (tickets + domain search), then a full-width news card.
- **Page header:** H1 = "My Dashboard" (LANG.clientareanavhome). No subtitle/eyebrow/status pill.
- **Sections (top → bottom):**
  1. **Inline notices (conditional, full state)** — alert strip; (a) overdue/unpaid-invoice notice with count + total due amount and a "Pay now" link; (b) expiring-domains notice (next 45 days) with a "Renew" link. Each notice is individually dismissible.
  2. **Welcome notice (empty state)** — "Welcome to {company}. Start by ordering a service or registering a domain" with two inline links.
  3. **Counter tiles** — four metric tiles linking to Services / Domains / Unpaid Invoices / Tickets, each showing a number + label. Six interchangeable visual variants (A vertical, B horizontal, C tinted, D stacked list, E progress rings, F horizontal list) are all present in markup; admin picks one via `tilesVariant`. (Variant labels like "Variant A — vertical" are dev scaffolding text.)
  4. **Active Products/Services card** — header "Your Active Products/Services" + "View All" link; body lists service rows (icon, name, domain/badge, status pill, Manage). Three data sources in priority: WHMCS native panel children → `$dashboard.activeServices` → empty state.
  5. **Split row — Recent Support Tickets** — header + "Open New Ticket" link; rows show ticket subject, "#id · Updated {date}", status pill. Empty state CTA "Open a ticket".
  6. **Split row — Register a New Domain** — single text input + Transfer and Register submit buttons (a domain search form).
  7. **Recent News card** — header "Recent News" + "View All" link; up to 5 announcement rows (title + date). Empty state "No announcements".
  8. **Account sub-nav aside (conditional)** — heading "Account"; links: Dashboard (active), My Services (+count), My Domains (+count), Invoices (+count), Support Tickets (+count), My Details.
- **Key data fields:** firstname/lastname/email; productsnumactive, numactivedomains, numunpaidinvoices, unpaidinvoicesamount, numactivetickets, numoverdueinvoices, numexpiringdomains; per service: groupname/name, domain, status; per ticket: subject, tid, lastreply/date, status; per announcement: title, date/timestamp.
- **Actions / CTAs:** Pay now (→clientarea.php?action=invoices); Renew expiring (→action=domains); dismiss notice (×); tile links (→services/domains/invoices/supporttickets.php); View All services; Manage service (→productdetails); Open New Ticket / Open a ticket (→submitticket.php); domain Transfer (→cart.php?a=add&domain=transfer) + Register (→cart.php?a=add&domain=register) via domainchecker.php; View All news (→announcements.php); Order a service (→cart.php, empty state); sub-nav links incl. My Details (→action=details).
- **States & conditionals:** body `data-data` = full vs empty (computed from any nonzero stat / native panel / dashboard arrays / announcements). Notices only shown when `showAlerts` true and the relevant count > 0. Each panel independently shows native-data / dashboard-data / empty-state. Sub-nav hidden when `subnavMode == off`. Tile block hidden when `tilesEnabled` false.
- **Interactions:** dismiss buttons on notices (JS); body data-attributes drive layout (tiles variant, subnav side, card layout) consumed by apple-layout.js. Static otherwise.

### `clientareaproducts` — My Products & Services
- **Route:** /clientarea.php?action=services (optional &status=Active|Pending|Suspended|Terminated|Cancelled|Fraud)
- **Purpose:** Browse, filter, sort, and manage all purchased services.
- **Layout shape:** Two-column: main (banner + filter tabs + table + pager) + right sidebar (Services sub-nav).
- **Page header:** H1 = "Services"; subtitle = "Manage your active services, upgrades, and add-ons."; header action link "Order a service".
- **Sections (top → bottom):**
  1. **Renewal banner (full state)** — "{N} service(s) on this account." + "View all" button.
  2. **Filter tabs** — All / Active / Pending / Suspended / Terminated / Cancelled (+ Fraud if any); each a link with status query param; active reflects current filter.
  3. **Services table** — columns below; each row clickable to product details; per-row kebab actions menu.
  4. **Pagination footer** — rows-per-page select (10/25/50), "Showing 1–N of N", prev/page/next buttons (static, single page).
  5. **Empty state** — icon, "No services yet", sub, "Place an order" CTA.
  6. **Services sub-nav aside** — My Services (active, +count), Order New Services (→cart.php), View Available Addons (→cart.php?gid=addons), Upgrade/Downgrade (→upgrade.php).
- **Key data fields:** per product: id, groupname, productname/name, domain, recurringamount or firstpaymentamount, billingcycle, nextduedate, status, statusClass. Table columns: Product/Service (name + domain), Pricing (amount /cycle), Next due, Status (pill), Actions.
- **Actions / CTAs:** Order a service / Place an order (→cart.php); View all (→action=services); row → productdetails; kebab: Manage Product (→productdetails), Upgrade/Downgrade (→action=upgrade&id), View Addons (→productdetails&modop=custom&a=Addons), Request Cancellation (→action=cancel&id); sub-nav links.
- **States & conditionals:** full vs empty (`data-data`) from product count; Fraud tab only if fraud count > 0; data source = native `$products` else `$mtProducts`; status strings strip_tags'd before use.
- **Interactions:** whole-row click/Enter navigation (JS); per-row kebab menu open/close with outside-click + Escape (JS); column-header sort cycle none→asc→desc (JS, visual indicator only).

### `clientareaproductdetails` — Service Details
- **Route:** /clientarea.php?action=productdetails&id=X
- **Purpose:** View and manage a single purchased service/product.
- **Layout shape:** Two-column: main tabbed panel + right sidebar (actions).
- **Page header:** eyebrow = product group name; H1 = product name; subtitle = associated domain (if any); status pill = service status (Active/Suspended/etc).
- **Sections (top → bottom):**
  1. **Alert banners (conditional)** — pending-cancellation warning; unpaid-invoice error with a "Pay invoice" CTA.
  2. **Tabbed card** — tabs Overview / Login info / Upgrade / Cancel service (each tab conditional). Overview = info grid of billing/server fields + usage meters; Login info = control-panel username + masked password (reveal) + login button; Upgrade = explanatory text + CTA; Cancel = explanatory text + CTA.
  3. **Sidebar (Actions)** — Back to services; Renew now.
- **Key data fields:** first payment amount, recurring amount + billing cycle, registration date, next due date, payment method, dedicated IP, server hostname, nameservers (ns1/ns2), disk usage/limit, bandwidth usage/limit, username, password.
- **Actions / CTAs:** Pay invoice (→viewinvoice); View upgrade options (→upgrade.php); Request cancellation (→action=cancel&id); Back to services; Renew now; password Show/Hide; pre-rendered login button.
- **States & conditionals:** unpaid-invoice and pending-cancellation alerts only when applicable; Login/Upgrade/Cancel tabs render only when data exists / service is active; usage meters only if limits set.
- **Interactions:** tab switching (JS); password reveal toggle (JS).

### `clientareadomains` — My Domains
- **Route:** /clientarea.php?action=domains
- **Purpose:** View and manage registered/transferred domains, renewals, DNS, contacts, auto-renew.
- **Layout shape:** Two-column: main (banner + filter tabs + domain list + pager) + right sidebar (Domains sub-nav).
- **Page header:** H1 = "Domains"; subtitle = "Manage your registrations, renewals, and DNS."; header action "Register a domain".
- **Sections (top → bottom):**
  1. **Expiring-soon banner (conditional)** — "{N} domain(s) expiring in the next 30 days." + "Renew now" button (only when expiringCount > 0).
  2. **Filter tabs (full state)** — All / Active / Expiring Soon / Transferred Away (static buttons, no links).
  3. **Domain list head row + rows** — columns below; each row clickable to domain details; per-row auto-renew toggle switch + kebab menu.
  4. **Empty state** — icon, "No domains yet", sub, two CTAs: Register + Transfer.
  5. **Pagination footer (full state)** — rows-per-page (10/25/50), "Showing X–Y of total", prev/page/next.
  6. **Domains sub-nav aside** — My Domains (active, +count), Register a Domain, Transfer a Domain, Bulk Management (→action=bulkdomainmanagement), Domain Pricing (→cart.php?gid=domain), WHOIS Lookup (→whois.php).
- **Key data fields:** per domain: id, domain, registrationdate, expirydate, nextduedate, recurringamount, status, autorenew; pagination startnumber/pagesize/numdomains. List columns: Domain, Registered, Expires, Status (pill), Auto-Renew (toggle), Actions.
- **Actions / CTAs:** Register a domain (→cart.php?a=add&domain=register); Transfer (→cart.php?a=add&domain=transfer); Renew now (banner →action=domains); row → domaindetails; auto-renew toggle (visual); kebab: Manage Domain, Manage Nameservers (→…&modop=custom&a=nameservers), Edit Contact Information (→action=domaincontacts&domainid), Auto Renewal Status, Renew (→cart.php?gid=renewals); sub-nav links.
- **States & conditionals:** full vs empty (`data-data`) from domain count; expiring banner only when status flags "Expiring Soon"/"Expired" present; data source native `$domains` else `$mtDomains`; full-state blocks gated by `.when-full`, empty by `.when-empty`.
- **Interactions:** whole-row click/Enter navigation (JS); auto-renew toggle switch flips class on click (JS, presentational); per-row kebab menu (JS).

### `clientareaquotes` — My Quotes
- **Route:** /clientarea.php?action=quotes (optional &stage=Draft|Delivered|Accepted|Lost; sort via ?orderby=&sort=)
- **Purpose:** Review proposals/quotes, accept a delivered one to convert to invoice, or download as PDF.
- **Layout shape:** Two-column: main (banner + filter tabs + table + pager) + right sidebar (Billing sub-nav).
- **Page header:** H1 = "My Quotes"; subtitle = "Review delivered proposals, accept to convert into an invoice, or download as PDF." No header action.
- **Sections (top → bottom):**
  1. **Delivered banner (conditional)** — "{N} quote(s) awaiting your decision." (only when deliveredCount > 0).
  2. **Filter tabs** — All / Draft / Delivered / Accepted / Lost (stage query links).
  3. **Quotes table** — columns below; rows clickable to viewquote; per-row kebab.
  4. **Empty state** — icon, "No quotes yet", sub, "Contact sales" CTA (→contact.php).
  5. **Pagination footer** — rows-per-page (10/25/50), "Showing 1–N of N", prev/page/next.
  6. **Billing sub-nav aside** — My Invoices, My Quotes (active, +count), Mass Payment (→action=masspay&all=true), Add Funds (→action=addfunds), Payment Methods (→routePath account-paymentmethods).
- **Key data fields:** per quote: id, subject, datecreated, validuntil, total, stage, currency prefix/suffix; numquotes. Table columns: Quote (#id + subject), Date, Valid until, Amount, Status (stage pill), Actions.
- **Actions / CTAs:** row → viewquote.php?id; kebab: View Quote, Download PDF (→viewquote.php?id&pdf=true), Accept Quote (→viewquote.php?id&action=accept, only if stage Delivered); Contact sales (empty); sub-nav links.
- **States & conditionals:** full vs empty (`data-data`); banner only if delivered quotes exist; Accept menu item only for Delivered stage; data source native `$quotes` else `$mtQuotes`; stage strings strip_tags'd.
- **Interactions:** whole-row click/Enter navigation (JS); per-row kebab menu (JS); jQuery + DataTables instant client-side column sort that also syncs ?orderby/&sort into the URL (no reload). Initial sort from URL params.

### `clientareainvoices` — My Invoices
- **Route:** /clientarea.php?action=invoices (optional &status=Unpaid|Paid|Cancelled; sort via ?orderby=&sort=)
- **Purpose:** View, filter, sort invoices; pay unpaid ones; download PDFs.
- **Layout shape:** Two-column: main (banner + filter tabs + table + pager) + right sidebar (Billing sub-nav).
- **Page header:** H1 = "Invoices"; subtitle = "Pay unpaid invoices, download PDFs, and review past payments."; conditional header action "Pay all unpaid" (only when unpaidCount > 0).
- **Sections (top → bottom):**
  1. **Unpaid banner (conditional)** — "{N} unpaid invoice(s)." + "Pay now" button (→masspay&all=true).
  2. **Filter tabs** — All / Unpaid / Paid / Cancelled (status query links).
  3. **Invoices table** — columns below; rows clickable to viewinvoice; per-row kebab.
  4. **Empty state** — icon, "No invoices yet", sub, "Browse services" CTA (→cart.php).
  5. **Pagination footer** — rows-per-page (10/25/50), "Showing X–Y of total", prev/page/next.
  6. **Billing sub-nav aside** — My Invoices (active, +count), My Quotes, Mass Payment, Add Funds, Payment Methods.
- **Key data fields:** per invoice: id, invoicenum, datecreated, duedate, total, status, statusClass, datepaid; numinvoices, startnumber/pagesize. Table columns: Invoice (#num), Date, Due date, Amount (flagged "due" if unpaid/overdue), Status (pill), Actions.
- **Actions / CTAs:** Pay all unpaid / Pay now (→masspay&all=true); row → viewinvoice.php?id; kebab: View Invoice, Download PDF (→dl.php?type=i&id), Pay Invoice (→viewinvoice, only if unpaid/overdue); Browse services (empty); sub-nav links.
- **States & conditionals:** full vs empty (`data-data`); unpaid banner + "Pay all unpaid" header action only if unpaid/overdue invoices exist; Pay menu item only for unpaid/overdue rows; data source native `$invoices` else `$mtInvoices`; status strip_tags'd.
- **Interactions:** whole-row click/Enter navigation (JS); per-row kebab menu (JS); jQuery + DataTables instant client-side column sort syncing ?orderby/&sort into URL. Initial sort from URL params.

### `homepage` — Public Homepage / Portal
- **Route:** / (index.php — public landing, works logged-out or in)
- **Purpose:** Marketing/portal entry — search a domain, browse product categories, and jump to self-service and account areas.
- **Layout shape:** Full-width stacked sections: hero (with domain search) → 3-card product grid → quick-action grid → quick-action grid. Designed for top-nav layout.
- **Page header:** None as a standard header; hero acts as title — H1 = "Secure your domain name." (overridable via heroTitle); hero subtitle = "Search, register, and transfer — all in one place."
- **Sections (top → bottom):**
  1. **Hero + domain search** — H1, subtitle; Search/Transfer tab toggle; domain text input + submit button; footer note + "View all pricing" link (→cart.php?gid=domain).
  2. **Browse our products** — eyebrow "Products & Services" + H2 "Browse our products."; three cards: WordPress Hosting (→cart.php "Browse Products"), Register a New Domain (→cart.php?a=add&domain=register "Domain Search"), Transfer Your Domain (→cart.php?a=add&domain=transfer). Each card: icon, title, description, CTA.
  3. **How can we help today?** — eyebrow "Self-service" + H2; 5 action tiles (icon + label): Announcements, Network Status (→serverstatus.php), Knowledgebase, Downloads (→downloads.php), Submit a Ticket.
  4. **Your account** — eyebrow "Account" + H2; 5 action tiles: Your Account (→clientarea.php), Manage Services, Manage Domains, Support Requests (→supporttickets.php), Make a Payment (→masspay&all=true).
- **Key data fields:** $loggedin, $companyname, LANG.* copy strings; pageoption settings heroTitle, heroSubtitle, showQuickLinks, showAnnouncements (note: announcements list block described in pageoption is not present in this template variant).
- **Actions / CTAs:** domain search submit (→domainchecker.php, or cart.php transfer when Transfer tab active); View all pricing; three product CTAs; 10 quick-action tile links across the two grids.
- **States & conditionals:** Largely static marketing content; pageoption exposes toggles for hero text and quick-link grid; the rendered template always shows all sections.
- **Interactions:** Search/Transfer tab toggle swaps the form action between domainchecker.php and cart.php transfer (JS).

### `knowledgebase` — Knowledgebase Root
- **Route:** /knowledgebase.php
- **Purpose:** Search the KB and browse top-level help categories.
- **Layout shape:** Two-column: left sidebar (Support sub-nav + "Most popular" list) + main (search hero card containing a category grid).
- **Page header:** H1 = "Knowledgebase"; subtitle = "Setup guides, troubleshooting and answers to frequently asked questions."
- **Sections (top → bottom):**
  1. **Support sub-nav aside** — heading "Support"; My support tickets (→supporttickets.php), Announcements, Knowledgebase (active), Open ticket (→submitticket.php).
  2. **Most popular aside (conditional)** — top 5 popular articles, each: rank number, title, view count.
  3. **Hero + search card (full state)** — H2 "How can we help?", sub, search input (GET →knowledgebase.php) prefilled with current term.
  4. **Category grid** — cards linking to each category (→action=displaycat&catid): icon, category name, "{N} articles".
  5. **Empty state card** — icon, "No articles yet", sub, "Open a ticket instead" CTA.
- **Key data fields:** per category: id, name, description, numarticles; per popular article: id, title, views; kbsearchterm (current query).
- **Actions / CTAs:** KB search submit; category card → displaycat; popular article → displayarticle&id; sub-nav links; empty-state "Open a ticket instead" (→submitticket.php).
- **States & conditionals:** full vs empty (`data-data`) from category count; "Most popular" sidebar only if popular articles exist; hero+grid in `.when-full`, empty in `.when-empty`.
- **Interactions:** Static (search is a standard GET form submit).

### `knowledgebasecat` — Knowledgebase Category
- **Route:** /knowledgebase.php?action=displaycat&catid=X (optional &search=)
- **Purpose:** Browse sub-categories and articles within one category; search within it.
- **Layout shape:** Two-column: left sidebar (Support sub-nav) + main (in-category search bar + a flat list of sub-category and article rows in one card).
- **Page header:** H1 = category name (fallback "Knowledgebase"); subtitle = category description (truncated 240, stripped) or generic fallback copy.
- **Sections (top → bottom):**
  1. **Support sub-nav aside** — same 4 links as KB root (My support tickets, Announcements, Knowledgebase active, Open ticket).
  2. **In-category search (full state)** — search input with hidden action=displaycat + catid, placeholder "Search in this category…", prefilled with term.
  3. **Sub-category rows (conditional)** — each: folder icon, name, "{N} articles", chevron; → displaycat&catid.
  4. **Article rows (conditional)** — each: document icon, title, "{N} views", chevron; → displayarticle&id.
  5. **Empty state card** — icon, "No matching articles", sub, "All categories" CTA (→knowledgebase.php).
- **Key data fields:** category: id, name, description, parent; per sub-category: id, name, numarticles; per article: id, title, views; kbsearchterm.
- **Actions / CTAs:** in-category search submit; sub-category row → displaycat; article row → displayarticle; "All categories" (empty); sub-nav links.
- **States & conditionals:** full vs empty (`data-data`) = has articles OR sub-categories; content card `.when-full`, empty `.when-empty`; sub-category and article lists each render only if non-empty.
- **Interactions:** Static (search is a GET form submit).

### `knowledgebasearticle` — Knowledgebase Article
- **Route:** /knowledgebase.php?action=displayarticle&id=X
- **Purpose:** Read a single KB article, rate it helpful/not, and see related articles.
- **Layout shape:** Two-column: left sidebar (Support sub-nav) + main stacked cards (article, helpful-vote, related).
- **Page header:** H1 = "Knowledgebase"; subtitle = "Read the full article and rate it." (The article's own title is a separate H1 inside the article card.)
- **Sections (top → bottom):**
  1. **Support sub-nav aside** — same 4 links (Knowledgebase active).
  2. **Article card (full)** — article title, meta (view count), then full article body HTML.
  3. **Helpful card** — "Was this article helpful?", Yes / No vote buttons (POST), and a stats line ("{N} people found this helpful, {M} didn't") when votes exist.
  4. **Related articles card (conditional)** — rows: title, "{N} views", chevron → displayarticle.
  5. **Empty state** — icon, "Article not found", sub, "All categories" CTA.
- **Key data fields:** kbarticle: id, title, text (HTML), views, parentlink; relatedarticles[]; useful, notuseful vote counts; userVoted flag.
- **Actions / CTAs:** Yes vote (rate=useful, POST to displayarticle&id); No vote (rate=notuseful); related row → displayarticle; "All categories" (empty); sub-nav links.
- **States & conditionals:** full vs empty (`data-data`) from article title presence; helpful-stats line only when useful/notuseful > 0; related card only if related articles exist; main content `.when-full`, not-found `.when-empty`.
- **Interactions:** Static (votes are standard POST form submits).

### `announcements` — Announcements List
- **Route:** /announcements.php
- **Purpose:** Browse the list of news/announcement posts.
- **Layout shape:** Two-column: left sidebar (Support sub-nav) + main (stacked announcement cards).
- **Page header:** H1 = "Announcements"; subtitle = "Product updates, network notices, and news from Hostnodes."
- **Sections (top → bottom):**
  1. **Support sub-nav aside** — heading "Support"; My support tickets, Announcements (active), Knowledgebase, Downloads, Network status (→serverstatus.php), Open ticket, View RSS feed (→announcements.php?rss=true).
  2. **Empty state card** — icon, "No announcements yet", sub, "Subscribe to RSS" CTA.
  3. **Announcement cards (full)** — one card per post: title, excerpt (body stripped + truncated 240), footer with date and chevron; whole card links to the post.
- **Key data fields:** per announcement: id, date/timestamp, title, text; numannouncements, startnumber/pagesize (pagination vars present but no pager rendered).
- **Actions / CTAs:** announcement card → announcements.php?id; Subscribe to RSS / View RSS feed (→announcements.php?rss=true); sub-nav links.
- **States & conditionals:** full vs empty (`data-data`) from announcement count; list block `.when-full`, empty `.when-empty`; date formatted via $carbon from timestamp, else falls back to preformatted $ann.date.
- **Interactions:** Static, none.

### `viewannouncement` — View Announcement
- **Route:** /announcements.php?id=X
- **Purpose:** Read a single announcement in full.
- **Layout shape:** Two-column: left sidebar (Support sub-nav) + main (single article card).
- **Page header:** H1 = "Announcements"; subtitle = "Read the full announcement and related news." (The post's own title is a separate H1 inside the article card.)
- **Sections (top → bottom):**
  1. **Support sub-nav aside** — heading "Support"; My support tickets, Announcements (active), Knowledgebase, Network status, Open ticket, View RSS feed.
  2. **Article card (full)** — post title, meta (date · optional author), body HTML, footer with "All announcements" back link + "Copy link" share button.
  3. **Empty state** — icon, "Announcement not found", sub, "All announcements" CTA.
- **Key data fields:** id, title, text (HTML), timestamp (formatted via $carbon to "Month D, YYYY"), date (fallback), author (optional).
- **Actions / CTAs:** All announcements (→announcements.php); Copy link (copies current URL); sub-nav links.
- **States & conditionals:** full vs empty (`data-data`) from title presence; article `.when-full`, not-found `.when-empty`; date prefers $carbon(timestamp) then $date; author shown only if present.
- **Interactions:** "Copy link" button copies the permalink to clipboard and briefly shows a "Copied" confirmation (JS).

## Domain management

### `clientareadomaindetails` — Domain Details
- **Route:** /clientarea.php?action=domaindetails&id=X
- **Purpose:** View and manage a single registered domain (renewal info, nameservers, lock, addons).
- **Layout shape:** Two-column: main tabbed panel + right sidebar (sub-nav).
- **Page header:** eyebrow = "Domain"; H1 = domain name; subtitle = "Registered · {registration date}" (if present); status pill = domain status.
- **Sections (top → bottom):**
  1. **Alert banners (conditional)** — unpaid-invoice warning/error with a "Pay invoice" CTA; registrar custom-button success/failure result; "domain not active and cannot be managed" warning when systemStatus != Active.
  2. **Tabbed card** — tabs: Overview / Auto-renew / Nameservers (cond.) / Registrar Lock (cond.) / Addons (cond.).
     - **Overview** = info grid (see fields) + optional SSL status row + registrar module output (`$registrarclientarea`) + hook outputs + "Quick actions" list (Change nameservers, Update WHOIS contact, Change registrar lock, Renew domain — each conditional).
     - **Auto-renew** = explanatory text + current status tag (Enabled/Disabled) + single submit toggling enable/disable.
     - **Nameservers** = radio (registrar default vs custom) + 5 nameserver text inputs + Save.
     - **Registrar Lock** = explanatory text + status tag (Locked/Unlocked) + enable/disable submit.
     - **Addons** = list of up to 3 addon cards (ID Protection, DNS Management, Email Forwarding); each shows name, description, and either an Enabled tag + Manage/Disable, or a "Add {price}" buy button.
  3. **Sidebar (sub-nav)** — All domains; DNS records (cond.); Email forwarders (cond.); Glue records (cond.); EPP code (cond.); WHOIS contact (cond.).
- **Key data fields:** domain (links to http://domain), first payment amount, registration date, recurring amount + registration period (yrs), next due date, payment method, SSL status label, nameservers[1..5], auto-renew bool, registrar lock status, addon enabled flags + addon pricing.
- **Actions / CTAs:** Pay invoice (→viewinvoice.php?id); Enable/Disable auto-renew (POST sub=autorenew); Save nameservers (POST sub=savens); Enable/Disable registrar lock (POST sub=savereglock); addon Add/Disable/Manage (POST →domainaddons / link →domaindns / →domainemailforwarding); Renew domain (→cart.php?gid=renewals); Update WHOIS contact (→domaincontacts); sidebar links.
- **States & conditionals:** unpaid-invoice (overdue vs warn), custom-button result, and inactive-domain alerts only when applicable; Nameservers/Lock/Addons tabs render only when `$managementoptions` / addon flags allow; Quick-action items each gated on systemStatus=Active + management option; per-addon UI switches on `$addonstatus`.
- **Interactions:** tab switching (JS); quick-action "jump" links activate target tab + scroll to top; URL hash (#tabNameservers/#tabReglock/#tabAutorenew/#tabAddons) auto-opens matching tab on load.

### `clientareadomaindns` — DNS Records
- **Route:** /clientarea.php?action=domaindns&domainid=X
- **Purpose:** Add, edit, and remove DNS records for a domain.
- **Layout shape:** Two-column: main editable table card + right sidebar (sub-nav + help card).
- **Page header:** eyebrow = domain name; H1 = "DNS records"; subtitle = "Add, edit and remove DNS records… changes propagate within a few minutes."
- **Sections (top → bottom):**
  1. **Error alert (conditional)** — shows `$error`.
  2. **External-management notice (conditional)** — when `$external`, replaces the editor with a note + injected registrar HTML (`$code`).
  3. **DNS editor form (table)** — one row per existing record plus one blank "add new" row; footnote "Priority only applies to MX records."; Save changes + Cancel.
  4. **Sidebar** — sub-nav (Domain details / DNS records (active) / Email forwarders) + "Common record types" help card (A, AAAA, CNAME, MX, TXT definitions).
- **Key data fields:** per record — recid (hidden), hostname (Host), type (A/AAAA/CNAME/MX/MXE/TXT/URL/FRAME select), address (Value), priority (MX only). Table columns: Host, Type, Value, Priority.
- **Actions / CTAs:** Save changes (POST sub=save); Cancel (→domaindetails&id).
- **States & conditionals:** external vs editable mode; error alert when set; existing rows only when `$dnsrecords` non-empty (blank add-row always present); priority input only on MX rows (else hidden "N/A" + dash).
- **Interactions:** changing a row's Type select updates that row's `data-type` (JS); static otherwise.

### `clientareadomainemailforwarding` — Email Forwarding
- **Route:** /clientarea.php?action=domainemailforwarding&domainid=X
- **Purpose:** Manage email forwarders that redirect mail at the domain to external inboxes.
- **Layout shape:** Two-column: main editable table card + right sidebar (sub-nav).
- **Page header:** eyebrow = domain name; H1 = "Email forwarding"; subtitle = "Forward mail sent to any address at your domain to a real inbox elsewhere."
- **Sections (top → bottom):**
  1. **Error alert (conditional)** — shows `$error`.
  2. **External-management notice (conditional)** — when `$external`, renders injected registrar HTML (`$code`) instead of the editor.
  3. **Forwarder editor form (table)** — one row per existing forwarder plus one blank "add new" row; Save changes + Cancel.
  4. **Sidebar** — sub-nav (Domain details / DNS records / Email forwarders (active)).
- **Key data fields:** per forwarder — prefix (local part), fixed "@{domain}" middle column, forward-to address. Table columns: Prefix, At, Forward to.
- **Actions / CTAs:** Save changes (POST sub=save); Cancel (→domaindetails&id).
- **States & conditionals:** external vs editable mode; error alert when set; existing rows only when `$emailforwarders` non-empty (blank new-row uses `…new` field names).
- **Interactions:** Static, none.

### `clientareadomainregisterns` — Register Nameservers / Glue Records
- **Route:** /clientarea.php?action=registerns&id=X
- **Purpose:** Register, modify, or delete child (glue) nameservers under the domain.
- **Layout shape:** Two-column: main stack of three form cards + right sidebar (sub-nav).
- **Page header:** eyebrow = domain name; H1 = "Glue records"; subtitle = "Register your own child nameservers under this domain (e.g. ns1.yourdomain.com)."
- **Sections (top → bottom):**
  1. **Warning alert (conditional)** — shows `$result` message after a save.
  2. **Register card** — "Register a new nameserver"; Nameserver field (with ".{domain}" suffix) + IP address field; Register button.
  3. **Modify card** — "Modify a nameserver"; Nameserver (suffixed) + Current IP + New IP; Save changes button.
  4. **Delete card** — "Delete a nameserver"; Nameserver (suffixed); Delete button.
  5. **Sidebar** — sub-nav (Domain details / Glue records (active)).
- **Key data fields:** nameserver label (prefix to domain), IP address (register), current IP + new IP (modify), nameserver label (delete).
- **Actions / CTAs:** Register (POST sub=register); Save changes (POST sub=modify); Delete (POST sub=delete) — all →clientarea.php?action=registerns.
- **States & conditionals:** warning alert only after a save returns `$result`.
- **Interactions:** Static, none.

### `clientareadomaingetepp` — Transfer Code (EPP)
- **Route:** /clientarea.php?action=getepp&id=X
- **Purpose:** Retrieve the domain's EPP/auth code needed to transfer it to another registrar.
- **Layout shape:** Two-column: main result card + info card + right sidebar (sub-nav).
- **Page header:** eyebrow = domain name; H1 = "Transfer code (EPP)"; subtitle = "The EPP/auth code is required to transfer this domain to another registrar."
- **Sections (top → bottom):**
  1. **Result card (one of three states)** — Error: "Could not retrieve EPP code" + `$error`; Code returned: "Your transfer code" + the code block + Copy button + privacy warning; Else (emailed): "Check your email" + confirmation that the code was emailed to the registered contact.
  2. **Info card** — "How a transfer works" 4-step ordered list (unlock at current registrar → request EPP code → submit transfer at gaining registrar → approve transfer email).
  3. **Sidebar** — sub-nav (Domain details / EPP code (active)).
- **Key data fields:** eppcode (the transfer/auth code), error message.
- **Actions / CTAs:** Copy code (client-side copy to clipboard); sidebar links.
- **States & conditionals:** three mutually exclusive result states keyed on `$error` / `$eppcode` / neither (emailed).
- **Interactions:** Copy button writes code to clipboard (navigator.clipboard with execCommand fallback) and shows "Copied" for ~1.4s (JS).

### `clientareadomainaddons` — Domain Addon Confirmation
- **Route:** /clientarea.php?action=domainaddons&id=X (with buy/disable + addon params)
- **Purpose:** Confirm buying or disabling a single domain addon (DNS management, email forwarding, or ID protection).
- **Layout shape:** Centered single card.
- **Page header:** eyebrow = domain name; H1 = the resolved addon name.
- **Sections (top → bottom):**
  1. **Confirmation card** — addon icon (globe/envelope/shield by addon); addon description; price row (only for buy action); then one of: success alert ("addon cancelled successfully"), error alert ("action failed"), or the confirm form.
  2. **Confirm form** — Buy mode: "Buy now" submit; Disable mode: "Are you sure…" text + "Confirm cancellation" submit; plus "Back to domain" link.
- **Key data fields:** addon key (`dnsmanagement`/`emailfwd`/`idprotect`), resolved name + description, addon price (per year), action (`buy`/`disable`).
- **Actions / CTAs:** Buy now (POST enable=1, buy=addon); Confirm cancellation (POST enable=1, disable=addon) — both →domainaddons; Back to domain (→domaindetails&id).
- **States & conditionals:** success vs error vs form; price row only when buying and price set; buy vs disable button/copy chosen by `$action`.
- **Interactions:** Static, none.

### `clientareadomaincontactinfo` — WHOIS Contact Information
- **Route:** /clientarea.php?action=domaincontacts&domainid=X
- **Purpose:** Edit the public WHOIS contact details (registrant/admin/tech/billing) for a domain.
- **Layout shape:** Two-column: main tabbed form card + right sidebar (sub-nav).
- **Page header:** eyebrow = domain name; H1 = "WHOIS contact information"; subtitle = "Update the contact details that appear in the public WHOIS database for this domain."
- **Sections (top → bottom):**
  1. **Alert banners (conditional)** — success ("Changes saved"), pending ("contact change pending registry confirmation", `$pendingMessage`), error (`$error`).
  2. **Contact form (tabbed)** — one tab + panel per contact category (Registrant, Admin, Tech, Billing…). Each panel has: source radios ("Use an existing contact" vs "Use the details below"), an existing-contact `<select>` (primary account holder + saved contacts), and a grid of editable contact fields. Save changes + Cancel.
  3. **Empty state** — "No contact details available for this domain." when `$contactdetails` empty.
  4. **Sidebar** — sub-nav (Domain details / WHOIS contact (active)).
- **Key data fields:** per category, all contact fields keyed by `$contactdetails[category][fieldName]` with human labels from `$contactdetailstranslations` (e.g. firstname, lastname, address1/2, fullphonenumber, etc.); existing-contact options from account user id + `$contacts` list.
- **Actions / CTAs:** Save changes (POST sub=save →domaincontacts); Cancel (→domaindetails&id); per-category contact-source selection.
- **States & conditionals:** success/pending/error alerts when set; tabs/panels only when `$contactdetails` non-empty else empty message; first category tab/panel active by default.
- **Interactions:** tab switching between categories (JS); per-category radio toggles existing-contact select vs dims/disables the custom field inputs (JS).

### `bulkdomainmanagement` — Bulk Domain Management
- **Route:** /clientarea.php?action=bulkdomain (mode via `update=`, domains via `domids[]`)
- **Purpose:** Apply one change (nameservers, auto-renew, registrar lock, or contact info) to several selected domains at once.
- **Layout shape:** Full-width single-card form (mode-dependent body) with a preceding selected-domains chip list; separate centered empty-state card.
- **Page header:** eyebrow = "Domains"; H1 = "Bulk domain management"; subtitle = "Apply a change to all the domains you selected at once."
- **Sections (top → bottom):**
  1. **Save result alert (conditional)** — error list (`$errors`) or success ("Changes saved successfully").
  2. **Selected-domains list** — "These changes will affect:" + checkmark chips of each selected domain name.
  3. **Action card (one of four modes by `$update`)** — Nameservers: default-vs-custom radios + 5 nameserver inputs + Change/Cancel; Auto-renew: info note + Enable / or / Disable submits; Registrar lock: info note + Enable / or / Disable submits; Contact info: note that WHOIS is per-domain + "Go to my domains" link.
  4. **Empty state** — "No domains selected" icon + guidance + "My domains" CTA.
- **Key data fields:** `$update` mode, `$domains` (display names), `$domainids` (carried as `domids[]`), `$defaultns` bool, `$ns1..$ns5`, `$errors`.
- **Actions / CTAs:** Change nameservers (POST update=nameservers, save=1); Enable/Disable auto-renew; Enable/Disable registrar lock (POST enable/disable=1); Go to my domains / My domains / Cancel (→clientarea.php?action=domains).
- **States & conditionals:** full (domains selected) vs empty (none) via `body[data-data]`; save alert only after a post; NS custom fields shown only when custom chosen; contact-info mode redirects users to per-domain editing; under `?preview=1` with no real domains, demo domains + nameservers mode are injected. Sets `data-subnav=off`.
- **Interactions:** nameservers mode — radios toggle visibility of the 5 NS fields and a "checked" class (JS); other modes static.

### `domain-pricing` — Domain Pricing
- **Route:** /domainchecker.php (or cart domain-pricing view) — public TLD price list
- **Purpose:** Browse register/transfer/renew prices for every TLD offered.
- **Layout shape:** Full-width: toolbar (search + category filter) above a price table; separate centered empty-state card.
- **Page header:** eyebrow = "Domains"; H1 = "Domain pricing"; subtitle = "Registration, transfer and renewal prices for every extension we offer."
- **Sections (top → bottom):**
  1. **Toolbar** — search input (filter by extension) + category `<select>` (All + each `$tldCategories` with count).
  2. **Pricing table** — one row per TLD; an optional group badge (hot/new/sale) next to the extension.
  3. **Empty state** — "Pricing unavailable" icon + message + "Register a domain" CTA when no pricing.
- **Key data fields:** per extension — group label (hot/new/sale/none), first category, first-tier register price, first-tier transfer price, first-tier renew price. Table columns: Extension, Category, Register, Transfer, Renew. (`data-tld` + `data-cats` drive filtering.)
- **Actions / CTAs:** Register a domain (→cart.php?a=add&domain=register) in empty state; search + filter controls.
- **States & conditionals:** full vs empty via `body[data-data]`; group badge only when `$data.group` set; price cells fall back to "-" when a tier is missing; under `?preview=1` with no real data, demo pricing + categories are injected. Sets `data-subnav=off`.
- **Interactions:** client-side search (matches `data-tld`) and category filter (matches `data-cats`) hide/show table rows live (JS).

## Billing & upgrades

### `viewinvoice` — View Invoice
- **Route:** /viewinvoice.php?id=X
- **Purpose:** View a single invoice's line items, totals, and payment history, and pay it if unpaid.
- **Layout shape:** Two-column: stacked main cards (left) + actions/summary sidebar (right). Falls back to a single centered "not found" card.
- **Page header:** eyebrow = "Invoice"; H1 = "Invoice #<num>"; subtitle = "Issued <date> · Due <date>"; status pill = invoice status (paid/unpaid/overdue).
- **Sections (top → bottom):**
  1. **Invoice summary card** — three blocks: amount (labeled "Total" if paid, else "Amount due"), due date, invoice date + "#<num>".
  2. **Addresses card** — "From" (company name) and "Bill to" (client name, company, full street address, country).
  3. **Invoice details card** — line-item table; below it a totals block (subtotal, tax 1, tax 2, credit applied, grand total labeled "Total"/"Total due").
  4. **Transactions card** — table of recorded payments; empty-message text if none.
  5. **Make a payment card (conditional)** — only when unpaid/overdue: radio list of payment gateways + "Pay <total>" submit. Posts to viewinvoice.php with paynow=true + CSRF token.
  6. **Sidebar — Summary card** — status pill, amount due, due date.
  7. **Sidebar — Actions card** — Download (PDF) link (dl.php?type=i).
  8. **Sidebar — Billing sub-nav card** — links: My Invoices (active), My Quotes, Mass Payment, Add Funds, Payment Methods.
- **Key data fields:** invoice number/id, status, date created, date due, date paid, total, subtotal, credit, tax/taxrate/taxname (+tax2), company name, client bill-to address. Line-items table columns: Description, Amount. Transactions table columns: Date, Gateway, Transaction ID, Amount.
- **Actions / CTAs:** Pay <total> (form → viewinvoice.php, paynow); Download PDF (→dl.php?type=i&id); sub-nav links to invoices/quotes/masspay/addfunds/payment-methods; "All invoices" (empty state →clientarea.php?action=invoices).
- **States & conditionals:** empty state = "Invoice not found" card with "All invoices" CTA (when no invoiceid); payment card only when unpaid/overdue; tax rows only if tax set; credit row only if credit applied; transactions table swaps to empty message when none. pageoption.php toggles: show actions sidebar, show addresses, show transaction history.
- **Interactions:** Static, none (no JS beyond setting body data-data full/empty).

### `invoice-payment` — Pay Invoice (standalone)
- **Route:** /invoice-payment (or invoice payment landing) → posts to /viewinvoice.php?id=X
- **Purpose:** Standalone slim page to choose a gateway and pay one invoice's balance.
- **Layout shape:** Centered single card.
- **Page header:** none (card has its own H1). H1 = "Pay invoice"; sub = "Invoice #<num>".
- **Sections (top → bottom):**
  1. **Error banner (conditional)** — validation/error message(s).
  2. **Balance summary** — "Balance due" label + amount (balance, falls back to total).
  3. **Payment form** — radio list of payment methods (first checked); "Pay now" submit + "Cancel" link. Posts paynow=true to viewinvoice.php.
- **Key data fields:** invoice number/id, balance, total, available payment methods (module + display name).
- **Actions / CTAs:** Pay now (form submit →viewinvoice.php?id); Cancel (→viewinvoice.php?id).
- **States & conditionals:** error banner only when errormessage set; payment-method block only when gateways exist.
- **Interactions:** Static, none.

### `viewquote` — View Quote
- **Route:** /viewquote.php?id=X
- **Purpose:** Review a sales quote/proposal and accept it.
- **Layout shape:** Two-column: stacked main cards (left) + summary/sub-nav sidebar (right). Empty state = single centered card.
- **Page header:** eyebrow = "Quote"; H1 = "Quote #<num>"; subtitle = "Issued <date> · Valid until <date>" (full state only); status pill = stage (Delivered/Accepted/On Hold/Lost/Dead).
- **Sections (top → bottom):**
  1. **Accept-TOS warning (conditional)** — shown if TOS agreement required but missing.
  2. **Summary head card** — total, valid-until, issued date + "#<num>".
  3. **Addresses card** — "From" (payto issuer HTML or company) and "Quote for" (client name/company/address + any custom fields).
  4. **Proposal card (conditional)** — rich proposal HTML.
  5. **Quote details card** — line-item table; totals (subtotal, tax 1, tax 2, grand total); taxable-item footnote; actions row (Download PDF); accept form when stage allows.
  6. **Notes card (conditional)** — rich notes HTML.
  7. **Sidebar — Summary card** — status pill, total, valid until.
  8. **Sidebar — Billing sub-nav card** — My Invoices, My Quotes (active), Mass Payment, Add Funds, Payment Methods.
- **Key data fields:** quote id/number, stage, date created, valid until, client bill-to address, custom fields, proposal HTML, notes HTML, subtotal, tax/taxname/taxrate (+2), total, TOS url. Line-items table columns: Description (+ "*" if taxed), Discount (amount + %), Amount.
- **Actions / CTAs:** Download PDF (→dl.php?type=q&id); Accept quote (form POST →viewquote.php?id&action=accept, with optional agree-to-TOS checkbox); Back to quotes (empty state); sub-nav billing links.
- **States & conditionals:** empty state = "Quote unavailable" card (invalid/expired quote); Accept form only when stage is Delivered or On Hold; TOS checkbox only if tosurl set; proposal/notes/tax rows/custom fields each render only when present; demo data injected under `?preview=1`.
- **Interactions:** Static, none.

### `clientareaaddfunds` — Add Funds
- **Route:** /clientarea.php?action=addfunds
- **Purpose:** Top up prepaid account credit via a chosen gateway.
- **Layout shape:** Two-column: stacked main cards (left) + billing sub-nav sidebar (right).
- **Page header:** H1 = "Add funds"; subtitle = "Top up your account credit to cover upcoming invoices automatically."
- **Sections (top → bottom):**
  1. **Error banner (conditional)** — deposit validation errors.
  2. **Balance + rules card** — current credit balance (big), "applied automatically" note; deposit rules: minimum deposit, maximum deposit, maximum balance (each conditional).
  3. **Intro card** — explanatory copy + "All deposits are non-refundable" notice.
  4. **Make a deposit form card** — payment-method select; amount input (currency prefix, number field with min/max) + preset buttons ($10/$25/$50/$100); live summary (current balance, deposit, new balance); "Add funds" submit. Posts to clientarea.php?action=addfunds + CSRF token.
  5. **Sidebar — Billing sub-nav card** — My Invoices, My Quotes, Mass Payment, Add Funds (active), Payment Methods.
- **Key data fields:** current credit balance, minimum/maximum amount, maximum balance, currency prefix, available payment methods (module + display name).
- **Actions / CTAs:** preset amount buttons (set the input); Add funds (form submit); sub-nav billing links.
- **States & conditionals:** error banner only when errormessage set; each deposit-rule row only when that value is set; payment-method select only when gateways exist.
- **Interactions:** JS — preset buttons fill the amount + toggle active; amount input recalculates the live deposit/new-balance summary on input.

### `masspay` — Mass Payment
- **Route:** /clientarea.php?action=masspay (&all=true)
- **Purpose:** Pay several unpaid invoices together in one transaction.
- **Layout shape:** Single-column stack: table card + total + payment-method card + submit. Empty state = centered message block.
- **Page header:** H1 = "Mass payment"; subtitle = "Pay multiple unpaid invoices in one transaction."
- **Sections (top → bottom):**
  1. **Error banner (conditional)** — validation errors.
  2. **Invoice selection table card** — checkbox-per-row table of unpaid invoices (header has "select all" checkbox, all checked by default).
  3. **Total summary** — combined total of selected invoices.
  4. **Payment method card (conditional)** — radio list of gateways (first checked).
  5. **Submit** — "Pay now". Form posts paynow=true to clientarea.php?action=masspay.
- **Key data fields:** total amount; per-invoice id, invoice number, due date, total. Invoice table columns: select checkbox, Invoice (#num), Due date, Amount.
- **Actions / CTAs:** select-all + per-row checkboxes; Pay now (form submit); View all invoices (empty state →clientarea.php?action=invoices).
- **States & conditionals:** empty state = "No unpaid invoices / You are all caught up" with "View all invoices" CTA; payment-method card only when gateways exist; error banner only when errormessage set.
- **Interactions:** JS — header "select all" toggles every row checkbox; header checkbox auto-syncs (checked only when all rows checked). (Note: total is not recalculated client-side.)

### `clientareacancelrequest` — Request Cancellation
- **Route:** /clientarea.php?action=cancel&id=X
- **Purpose:** Submit a cancellation request for a purchased service.
- **Layout shape:** Centered single card (form), or a centered notice block for confirmation/invalid states.
- **Page header:** eyebrow = "Service"; H1 = "Request cancellation"; subtitle = "Tell us how and when you want this service cancelled."
- **Sections (top → bottom):**
  1. **Warning callout** — data-loss warning (cancelling permanently removes files/databases/email).
  2. **Reason-required error callout (conditional)** — shown when reason was left blank on submit.
  3. **Form card** — read-only service display (group + product name, domain); optional "also cancel domain" checkbox (with domain next-due date); cancellation-type select (End of Billing Period / Immediate); reason textarea; submit + "Keep service" link. Posts sub=submit to clientarea.php?action=cancel&id.
- **Key data fields:** service id, group name, product name, domain; associated domain id + next due date.
- **Actions / CTAs:** Request cancellation (danger submit →clientarea.php?action=cancel); Keep service (→productdetails); Back to service (confirmation state →productdetails); My services (invalid state →services).
- **States & conditionals:** confirmation state = success notice "Cancellation requested" (when `requested`); invalid state = "Nothing to cancel" notice (when `invalid`); reason-required error callout only on validation failure; "also cancel domain" block only when a domain is attached; demo data under `?preview=1`.
- **Interactions:** Static, none.

### `subscription-manage` — Email Subscription
- **Route:** /subscription-manage (email opt-in/opt-out link target)
- **Purpose:** Confirm an email-newsletter opt-in or opt-out action reached from an email link.
- **Layout shape:** Centered single card (icon + heading + text + button).
- **Page header:** eyebrow = "Email preferences"; H1 = "Email subscription".
- **Sections (top → bottom):**
  1. **Status card** — one icon + title + message chosen by state (see below), plus a "Back to dashboard" button.
- **Key data fields:** action ('optin' | 'optout'), error message, info message.
- **Actions / CTAs:** Back to dashboard (→clientarea.php); contextual inline link to account settings / resubscribe (→clientarea.php?action=details).
- **States & conditionals:** five mutually exclusive states — error ("Something went wrong"), info ("Subscription updated"), optin ("You're subscribed"), optout ("You've been unsubscribed" + resubscribe link), default ("Email preferences" + open-settings link). Demo shows optout under `?preview=1`.
- **Interactions:** Static, none.

### `usagebillingpricing` — Usage Pricing
- **Route:** /clientarea.php?action=productdetails... (usage/metered-billing pricing view; collection var install-dependent)
- **Purpose:** Show per-unit overage rates and included quotas for metered resources.
- **Layout shape:** Full-width table card + info note + action. Empty state = centered card.
- **Page header:** eyebrow = "Services"; H1 = "Usage pricing"; subtitle = "What you'll pay per unit beyond your included quotas."
- **Sections (top → bottom):**
  1. **Pricing table card** — row per metric: name + description, included quantity, overage rate (may list multiple pricing tiers with "from" thresholds).
  2. **Info note** — "How billing works" explanation (usage metered continuously, overages billed as next-invoice line items).
  3. **Actions** — "View my usage".
- **Key data fields:** per-metric display name, description, included quantity (+ units), pricing tiers (price per unit, unit name, from-threshold). Table columns: Resource, Included, Overage rate.
- **Actions / CTAs:** View my usage (→clientarea.php?action=services); All services (empty state →services).
- **States & conditionals:** empty state = "Pricing unavailable" card when no metrics; tier list collapses to "-" when no pricing/included data; demo rows under `?preview=1`.
- **Interactions:** Static, none.

### `upgrade` — Upgrade / Downgrade
- **Route:** /upgrade.php?type=package|configoptions&id=X
- **Purpose:** Pick a higher/lower product package, or change configurable options, for an existing service.
- **Layout shape:** Full-width: a row of plan cards (package mode) OR a stack of option-diff cards (configoptions mode). Empty/blocked state = centered card.
- **Page header:** eyebrow = "Services"; H1 = "Upgrade or downgrade"; subtitle = "Change your plan size or feature tier. Changes are prorated."
- **Sections (top → bottom):**
  1. **Current-plan callout (conditional)** — "Current plan: <group> - <product> (<domain>)".
  2. **Package mode — plan cards** — one form-card per available package: name (+ "Current" badge if it's the active plan), price (free / one-time / billing-cycle select with monthly→triennially options), feature description (HTML), "Choose this plan" submit (disabled for current plan). Each posts step=2, type=package, id, pid, billingcycle.
  3. **Configoptions mode — option-diff cards** — error callout (conditional); one card per configurable option showing Current (read-only) vs New (dropdown/checkbox/qty input by option type 1–4); Continue + Cancel actions. Posts step=2, type=configoptions, id, configoption[id].
- **Key data fields:** type, service id, group/product name, domain; per-package pid, name, description, pricing by term; per-config-option id, name, type, current selected name/qty, qty min/max, option list (id/name/price/selected).
- **Actions / CTAs:** Choose this plan (per-package submit →upgrade.php); Continue (configoptions submit →upgrade.php); Cancel (→productdetails); empty/blocked CTAs → My invoices or All services.
- **States & conditionals:** blocked/empty state when overdue invoice ("settle it before upgrading"), existing pending upgrade invoice, or no upgrade available — each with its own message + CTA; current package's button disabled; pricing UI varies by pricing type; demo package cards under `?preview=1`.
- **Interactions:** Static, none (billing-cycle is a plain select).

### `upgrade-configure` — Configure Upgrade
- **Route:** /upgrade-configure (non-standard; design page that funnels into upgrade.php) 
- **Purpose:** Choose a target plan and preview the prorated amount before confirming an upgrade.
- **Layout shape:** Full-width stacked cards: selectable plan list + (demo) summary card + action row. Empty state = centered card.
- **Page header:** eyebrow = "Services"; H1 = "Configure upgrade"; subtitle = "Pick your new plan and review the prorated amount before confirming."
- **Sections (top → bottom):**
  1. **Choose-your-new-plan card** — radio plan cards: name (+ "Current" badge), feature summary, price/period; one selected by default.
  2. **Upgrade summary card (demo only)** — current plan, new plan, prorated credit, amount due today.
  3. **Action row** — "Continue to confirm" + "Cancel".
- **Key data fields:** per-package pid, name, monthly price (real mode); demo adds feature summaries + proration figures (current/new price, prorated credit, amount due today).
- **Actions / CTAs:** plan radio selection; Continue to confirm (→upgrade.php); Cancel (→services); My services (empty state).
- **States & conditionals:** empty state = "Start an upgrade" card when no packages; summary card only in demo; demo data under `?preview=1`.
- **Interactions:** JS — clicking a plan card selects it (toggles `selected`, checks its hidden radio).

### `upgradesummary` — Upgrade Summary
- **Route:** /upgrade.php (confirm step, after choosing a package/options)
- **Purpose:** Confirm upgrade changes, apply a promo code, pick payment method, and check out.
- **Layout shape:** Two-column: stacked main cards (left) + order-summary sidebar (right). Empty state = centered card.
- **Page header:** eyebrow = "Services"; H1 = "Review your upgrade"; subtitle = "Confirm the changes and amount due before checkout."
- **Sections (top → bottom):**
  1. **Changes card** — line per upgrade: description ("old → new" product, or "configname: old → new" value) + price; proration note ("price reflects remaining time until renewal (<N> days)") for package upgrades.
  2. **Promotion code card** — promo input + Apply (or Remove if already applied) submit. Posts step=2 with carry-over hidden fields (type, id, pid, billingcycle, configoption[]).
  3. **Payment method + checkout card** — gateway select (with optional "Default" option); "Confirm & checkout" + "Cancel". Posts step=3 with all carry-over hidden fields.
  4. **Sidebar — Order summary card** — subtotal, tax 1, tax 2, promo discount, "Due today" total.
- **Key data fields:** type, service id; per-upgrade old/new product name, new product id, new billing cycle, price, days until renewal (or configname/originalvalue/newvalue/price); subtotal, taxname/taxrate/taxtotal (+2), total; promo code/desc/discount; gateways (sysname/name), selected gateway.
- **Actions / CTAs:** Apply / Remove promo (form submit, step=2); Confirm & checkout (form submit, step=3); Cancel (→productdetails).
- **States & conditionals:** empty state = "Nothing to confirm" card when no upgrades; proration note only for package type with daysuntilrenewal; tax rows only when set; promo row only when a code is applied; promo input disabled once applied; gateway select only when gateways exist; demo data under `?preview=1`.
- **Interactions:** Static, none.

## Support

### `supportticketslist` — Support Tickets (alias)
- Alias/forwarder: `default.tpl` simply `{include}`s `supporttickets/default/default.tpl`. Same content as `supporttickets` below. Route: /supportticketslist.php (WHMCS open-only ticket view).

### `supporttickets` — My Tickets
- **Route:** /supporttickets.php
- **Purpose:** Browse, filter, sort, and open the client's existing support tickets; jump to opening a new one.
- **Layout shape:** Two-column: main list (table + filters + pagination footer) + right sidebar (support sub-nav).
- **Page header:** H1 = "Tickets"; subtitle = "Open conversations with our team — filter by status or start a new ticket."; header-row also holds a primary "Open a ticket" link.
- **Sections (top → bottom):**
  1. **Unread-reply banner (conditional)** — count of tickets with a new staff reply (singular/plural) + "View replies" link to the first unread ticket. Shown only when `tkUnreadCount > 0`.
  2. **Status filter tabs** — All / Open / Answered / Customer-reply / Closed (client-side filter buttons).
  3. **Tickets table** — one row per ticket; whole row is clickable → viewticket. Columns: Subject (with `#TID` id, priority dot for high/medium), Department, Status (colored status pill), Last updated (date). Header cells are sortable.
  4. **Empty state** — mailbox icon, "No tickets yet" title, helper subtitle, "Open a ticket" CTA. (Replaces the table when no tickets.)
  5. **Table footer** — "Show N entries" page-size select (10/25/50/100), "Showing 1–N of N" count, prev/page/next pagination buttons.
  6. **Right sidebar (Support sub-nav)** — heading "Support" + links: My tickets (active, with ticket count badge), Open a ticket, Announcements, Knowledgebase, Downloads, Network status.
- **Key data fields:** per ticket — tid (id), c (verification hash), subject, department, status + statusClass/statusColor, lastreply (last-updated date), priority/urgency, unread flag. Aggregates: total count, unread count.
- **Actions / CTAs:** "Open a ticket" (header + empty state + sidebar → submitticket.php); "View replies" (banner → viewticket.php?tid=&c=); row click/Enter (→ viewticket.php?tid=&c=); filter tab buttons; sortable column headers; page-size select; pagination buttons; sidebar links (supporttickets, submitticket, announcements, knowledgebase, downloads, serverstatus).
- **States & conditionals:** empty vs populated (`data-data` empty/full via `.when-empty`/`.when-full`); unread banner only when unread tickets exist; priority dot only for high/medium; status pill inline color only when `statusColor` set; falls back to `$mtTickets` when `$tickets` not propagated.
- **Interactions:** client-side row navigation (JS click/keydown); status filter tabs hide non-matching rows (JS); DataTables instant column sort with URL `?orderby=&sort=` sync (no reload); page-size select is presentational.

### `viewticket` — View Support Ticket
- **Route:** /viewticket.php?tid=X&c=HASH
- **Purpose:** Read a ticket's full conversation thread and post a reply (or close the ticket).
- **Layout shape:** Header bar + two-column split: main (conversation thread + reply composer) + right sidebar (ticket information). Falls back to a single centered "not available" panel when invalid.
- **Page header:** ticket id eyebrow = `#TID`; H1 = ticket subject; right side = "Close Ticket" button (only when status ≠ closed).
- **Sections (top → bottom):**
  1. **Conversation thread** — section title "Conversation"; a card containing chronologically ordered message bubbles. First bubble = original ticket post (`$message`, authored by requester); then each reply, styled by author type (staff vs client). Each bubble shows sender name, message body (HTML), optional attachment list, and timestamp. Fallback "No conversation yet" line if neither message nor replies exist.
  2. **Reply composer / Ticket Settings (conditional, status ≠ closed)** — section title "Ticket Settings"; a tabbed card (single "Reply" tab). Panel contains an author bar (avatar initial + name + email), then a POST form: reply textarea (required), "Add Attachments…" file picker (multiple) + allowed-extensions/size hint, footer with "Send Message" submit + "Cancel" link.
  3. **Right sidebar (Ticket Information)** — section title "Ticket Information"; info card with rows: Status (pill), Requestor (avatar + name, conditional), Department (conditional), Submitted date (conditional), Last Updated (conditional), Priority (pill, conditional).
  4. **Not-available panel (conditional)** — mailbox icon, "Ticket not available" title, subtitle "This ticket may be closed, archived, or no longer accessible.", "All tickets" CTA.
- **Key data fields:** tid, c, subject, status (HTML-stripped), priority, department, date (submitted), lastreply, message (initial post), replies[] (name, requestor_type, date, message, attachments, id), attachments[] (ticket-level), clientsdetails (firstname, lastname, email). Reply form fields: replymessage, attachments[], token (hidden).
- **Actions / CTAs:** Close Ticket (→ viewticket.php?...&closeticket=true, confirm dialog); attachment download links (→ dl.php?type=at|ar&id=&i=); reply form submit "Send Message" (POST → viewticket.php?...&postreply=true, name=save); "Cancel" (→ supporttickets.php); "All tickets" (empty → supporttickets.php).
- **States & conditionals:** valid vs invalid ticket gating (`$tid`/`$replies` vs `$invalidTicketId`) toggles `.when-full` thread/composer vs `.when-empty` not-available panel; Close button + Ticket Settings composer hidden when status = closed; each sidebar info row rendered only when its value exists; attachment blocks only when attachments present; staff/client bubble class by `reply.requestor_type == 'admin'`.
- **Interactions:** tab switching markup (single "Reply" tab, role=tablist/tab/tabpanel); native file input for attachments; close-ticket JS confirm() prompt.

### `submitticket` — Submit a Ticket (alias)
- Alias/forwarder: `default.tpl` `{include}`s `supportticketsubmit/default/default.tpl`. Same content as `supportticketsubmit` below. Route: /submitticket.php.

### `supportticketsubmit` — Open a Ticket
- **Route:** /submitticket.php (step 1 dept picker; step 2 details via ?step=2)
- **Purpose:** Open a new support ticket — first choose a department, then fill in subject/priority/message/attachments.
- **Layout shape:** Header + two-column split: left sidebar (support sub-nav) + main form panel (single card).
- **Page header:** H1 = "Open a ticket"; subtitle = "Tell us what you need help with — our team will reply by email."
- **Sections (top → bottom):**
  1. **Left sidebar (Support sub-nav)** — heading "Support" + links: My tickets, Open a ticket (active), Announcements, Knowledgebase, Network status.
  2. **Error banner (conditional)** — validation errors (array or HTML string) shown above the form.
  3. **Step 1 — Department picker (when no department chosen)** — intro ("Step 1 of 2", "Choose a department", helper text); radio-card grid, one card per department with an icon (sales/abuse/tech inferred from name), department name, optional truncated description; footer with "Cancel" link + "Continue" submit (POST → ?step=2).
  4. **Step 2 — Ticket details (when department chosen)** — intro ("Step 2 of 2", "Ticket details", "Replying via <dept>"); form (POST → ?step=3, multipart) with fields: Name + Email (only when not logged in), Subject, Priority select (Low/Medium/High), Related service select (optional, conditional on service list), Message textarea, department custom fields (text/textarea, optional required), attachments file picker + hint; footer with "Back" link + "Submit ticket" submit.
  5. **Empty state (conditional)** — info icon, "No departments available" title, subtitle, "Contact us" CTA (→ contact.php). Shown when no departments configured.
- **Key data fields:** departments[] (id, name, description), step, deptid, deptname, subject, message, urgency (Low/Medium/High), servicelist[] (id, name/product, domain), relatedservice, customfields[] (id, name, type, value, required, description), name/email (guest), loggedin, token, errormessage.
- **Actions / CTAs:** "Continue" (step 1 submit → ?step=2); "Cancel" (→ supporttickets.php); "Back" (step 2 → submitticket.php); "Submit ticket" (step 2 submit → ?step=3); "Contact us" (empty → contact.php); sidebar links.
- **States & conditionals:** step 1 vs step 2 driven by `$hasDept` (`$deptid`/`$step>=2`); empty (no departments) `.when-empty` vs `.when-full`; name/email fields only when `!$loggedin`; related-service select only when `$servicelist` non-empty; custom fields only when present; per-field required flag; error banner only on validation errors.
- **Interactions:** native radio-card selection; native file input; otherwise standard multi-step form posts (no JS tabs/accordions).

### `supportticketsubmit-stepone` — Submit Ticket Step 1 (alias)
- Alias/forwarder: `default.tpl` `{include}`s `supportticketsubmit/default/default.tpl`. Step-1 (department picker) variant of the shared submit template above.

### `supportticketsubmit-steptwo` — Submit Ticket Step 2 (alias)
- Alias/forwarder: `default.tpl` `{include}`s `supportticketsubmit/default/default.tpl`. Step-2 (ticket details) variant of the shared submit template above.

### `supportticketsubmit-customfields` — Submit Ticket: Additional Details
- **Route:** fragment of /submitticket.php (department custom-fields step); standalone-previewable.
- **Purpose:** Collect department-specific custom fields during ticket submission.
- **Layout shape:** Header + centered single card holding a stacked list of form fields.
- **Page header:** eyebrow = "Support"; H1 = "Additional details"; subtitle = "A few department-specific details to help us route and resolve your ticket faster."
- **Sections (top → bottom):**
  1. **Custom fields card (populated)** — one form-group per custom field; renders WHMCS's raw field `input` HTML, with label + optional required marker; tickbox type shows checkbox inline before its label; optional field description hint below.
  2. **Empty state** — document icon, "No additional fields" title, subtitle "This department has no extra fields. Continue with your ticket.", "Open a ticket" CTA.
- **Key data fields:** customfields[] (id, type [tickbox/text/textarea/dropdown/link…], name, input [raw HTML], required marker, description).
- **Actions / CTAs:** "Open a ticket" (empty → submitticket.php). (Fields themselves submit as part of the parent submit form.)
- **States & conditionals:** populated `.when-full` vs empty `.when-empty` driven by `$customfields`; under `?preview=1` injects demo fields (Affected service dropdown, Order/invoice number text); tickbox vs other field-type rendering; required marker + description shown only when set.
- **Interactions:** Static, none (renders WHMCS-provided field HTML).

### `supportticketsubmit-kbsuggestions` — Before You Submit (KB Suggestions)
- **Route:** fragment of /submitticket.php (suggested KB articles step); standalone-previewable.
- **Purpose:** Surface knowledgebase articles matching the ticket subject so the user can self-resolve before submitting.
- **Layout shape:** Header + centered single card listing article links + an actions row.
- **Page header:** eyebrow = "Support"; H1 = "Before you submit"; subtitle = "These knowledgebase articles match your question and might resolve it instantly."
- **Sections (top → bottom):**
  1. **Suggested articles list (populated)** — card of article link rows; each shows a document icon, article title, and optional excerpt; opens the article in a new tab.
  2. **Actions row** — "None of these helped, continue" primary button (→ submitticket.php?step=2).
  3. **Empty state** — book icon, "No matching articles" title, subtitle "We couldn't find a related article. Go ahead and open your ticket.", "Open a ticket" CTA.
- **Key data fields:** kbarticles[] (id, title, article [excerpt]).
- **Actions / CTAs:** article links (→ knowledgebase.php?action=displayarticle&id=, new tab); "None of these helped, continue" (→ submitticket.php?step=2); "Open a ticket" (empty → submitticket.php).
- **States & conditionals:** populated `.when-full` vs empty `.when-empty` driven by `$kbarticles`; under `?preview=1` injects 3 demo articles; excerpt shown only when present.
- **Interactions:** Static, none (links open in new tab).

### `supportticketsubmit-confirm` — Ticket Created
- **Route:** /submitticket.php (post-submit confirmation, ?step=3 result)
- **Purpose:** Confirm the ticket was submitted and offer a link to view it.
- **Layout shape:** Header + single centered confirmation card.
- **Page header:** eyebrow = "Support"; H1 = "Ticket created".
- **Sections (top → bottom):**
  1. **Confirmation notice** — success check icon; title "Ticket created" + optional `#TID`; subtitle "Your ticket has been submitted. Our team will reply by email and you can follow the conversation in your client area."; primary CTA.
- **Key data fields:** tid (ticket id/mask), c (verification hash).
- **Actions / CTAs:** "View ticket" (→ viewticket.php?tid=&c=, when tid present) OR "My tickets" (→ supporttickets.php, when no tid).
- **States & conditionals:** CTA target switches on whether `$tid` exists; under `?preview=1` uses demo tid `HNX-481923`; always treated as "full" data state.
- **Interactions:** Static, none.

### `ticketfeedback` — Ticket Feedback
- **Route:** /ticketfeedback.php?tid=X&c=HASH
- **Purpose:** Rate the staff who handled a resolved ticket and leave comments.
- **Layout shape:** Header + centered single column; either a status notice card or a meta card stacked above a feedback form card.
- **Page header:** eyebrow = "Support"; H1 = "Ticket feedback".
- **Sections (top → bottom):**
  1. **Still-open notice (state=stillopen)** — warning icon, "Feedback not available yet" title, subtitle "This ticket is still open…", "Back to dashboard" CTA.
  2. **Already-done / success notice (state=done|success)** — check icon, title ("Feedback already submitted" or "Thank you for your feedback"), thank-you subtitle, "Back to dashboard" CTA.
  3. **Feedback form (default state):**
     - **Error banner (conditional)** — validation error message.
     - **Ticket meta card** — definition list: Opened, Last reply, Staff involved, Total duration.
     - **Per-staff rating blocks** — for each involved staff member: question "How well did <staff> handle your request?", a radio rating group (values from `$ratings`, e.g. 1–5), and a comments textarea.
     - **Generic comments block** — "Anything else we could improve?" with a comments textarea.
     - **Actions row** — "Submit feedback" submit + "Review ticket" link.
- **Key data fields:** state flags (stillopen, feedbackdone, success); errormessage; tid, c; meta (opened, lastreply, staffinvolvedtext, duration); staffinvolved (staffid → name); ratings[] (allowed values); rate (staffid → selected); comments (staffid → text, plus 'generic').
- **Actions / CTAs:** "Submit feedback" (POST → ticketfeedback.php?tid=&c=&feedback=1, validate=true, name=save); "Review ticket" (→ viewticket.php?tid=&c=); "Back to dashboard" (notice states → clientarea.php).
- **States & conditionals:** four states (stillopen / done / success / form) selected from flags; staff rating blocks only when staff involved; generic comments block always; error banner only on validation error; under `?preview=1` (form state, no real staff) injects demo meta + 2 demo staff + ratings 1–5.
- **Interactions:** native radio rating selection + textareas; otherwise standard form post (no JS).

## Account & profile

### `clientareadetails` — Account Details
- **Route:** /clientarea.php?action=details
- **Purpose:** Edit your personal info, billing address, and email notification preferences.
- **Layout shape:** Two-column: left account sub-nav aside + right stacked form cards (the whole block is wrapped in a populated/empty toggle).
- **Page header:** H1 = "Account Details"; subtitle = "Your personal information, billing address and email preferences." No eyebrow or status pill.
- **Sections (top → bottom):**
  1. **Account sub-nav (aside)** — links: Account Details (active), User Management, Payment Methods, Contacts, Email History.
  2. **Personal information card** — fields: First name, Last name, Email address, Phone number, and (conditional) Language dropdown.
  3. **Billing address card** — fields: Company name (optional), Address line 1, Address line 2 (optional), City, Country (select), State/Region, Zip/Postal code.
  4. **Email preferences card** — six opt-in checkboxes: General, Invoice, Support, Product, Domain, Affiliate emails (each with a sub-description).
  5. **Footer actions** — Cancel changes + Save changes.
  6. **Empty state (alternate)** — "Profile not yet set up" message with a "Set up profile" CTA.
- **Key data fields:** firstname, lastname, email, phonenumber, language, companyname, address1, address2, city, country, state, postcode; email-opt-out flags per category.
- **Actions / CTAs:** Save changes (POST →clientarea.php?action=details, save=true); Cancel changes (→clientarea.php); sub-nav links to Users/Payment Methods/Contacts/Email History; Set up profile (empty state).
- **States & conditionals:** body `data-data` = full vs empty based on `$clientsdetails`; Language selector only if `$languages` populated; country falls back to a single static option if `$countries` empty.
- **Interactions:** Static form; sub-nav is plain links. No JS widgets.
- **Variant options (pageoption.php):** toggles to show/hide the account sub-nav, the email-preferences card, and the language selector.

### `account-contacts-manage` — Contacts (manage)
- **Route:** /clientarea.php?action=contacts (POST routes account-contacts / -save / -delete)
- **Purpose:** Pick an existing additional contact (or "new"), edit their details and email preferences, save or delete.
- **Layout shape:** Two-column: main column (picker + edit form) + right account sub-nav aside.
- **Page header:** H1 = "Contacts"; subtitle = "Additional people authorised to manage parts of this account." No eyebrow/pill.
- **Sections (top → bottom):**
  1. **Alerts (conditional)** — flash message (error/success/warning/info) and a validation error block.
  2. **Contact picker card** — dropdown listing existing contacts ("Name — email") plus an "+ Add new contact" option, with a Go button; changing it auto-submits.
  3. **Contact details card** — two-column field grid. Left: First name, Last name, Company, Email, Phone, Tax ID (conditional). Right: Address 1, Address 2, City, State/region, ZIP, Country (pre-rendered select).
  4. **Email preferences card (conditional)** — checkbox per email-preference type (each paired with a hidden "0" fallback input).
  5. **Actions** — Delete contact (only for a saved contact), Cancel (reset), Save changes.
  6. **Sub-nav (aside)** — Account Details, User Management, Payment Methods, Contacts (active), Email History.
- **Key data fields:** contactid (selected); per-contact firstname, lastname, companyname, email, phonenumber, tax_id, address1, address2, city, state, postcode; emailPreferences map (type → bool); CSRF token.
- **Actions / CTAs:** Picker Go (POST →account-contacts, switches selected contact); Save changes (POST →account-contacts-save); Delete contact (POST →account-contacts-delete via hidden form); Cancel (form reset); sub-nav links.
- **States & conditionals:** Tax ID row only if `$taxIdLabel`; email-prefs card only if `$formdata.emailPreferences`; Delete button only when a real contact (not "new") is selected; alert blocks only when a flash/error exists.
- **Interactions:** Picker dropdown auto-submits on change (JS); Delete button shows a confirm() dialog then submits a hidden form (JS).

### `clientareacontacts` — Contacts (alias)
- Forwarder: `default.tpl` only `{include}`s `account-contacts-manage/default/default.tpl`. Identical content/behavior to **account-contacts-manage**.

### `account-contacts-new` — Add New Contact
- **Route:** /clientarea.php?action=contacts (new) — POST →account-contacts-save with contactid="new"
- **Purpose:** Create a brand-new additional contact for the account.
- **Layout shape:** Two-column: main column (single add form) + right account sub-nav aside.
- **Page header:** H1 = "Add new contact"; subtitle = "Add another person who can manage parts of this account."
- **Sections (top → bottom):**
  1. **Alerts (conditional)** — flash message + validation error block.
  2. **Contact details card** — same two-column field grid as account-contacts-manage. Left: First name, Last name, Company, Email, Phone, Tax ID (conditional). Right: Address 1, Address 2, City, State/region, ZIP, Country (select).
  3. **Email preferences card (conditional)** — checkbox per preference type with hidden "0" fallback.
  4. **Actions** — Cancel (link back to contacts) + Add contact (submit).
  5. **Sub-nav (aside)** — Account Details, User Management, Payment Methods, Contacts (active), Email History.
- **Key data fields:** firstname, lastname, companyname, email, phonenumber, tax_id, address1, address2, city, state, postcode, emailPreferences map; CSRF token; hidden contactid="new".
- **Actions / CTAs:** Add contact (POST →account-contacts-save, save=1); Cancel (→account-contacts); sub-nav links.
- **States & conditionals:** body always `data-data=full`; Tax ID row only if `$taxIdLabel`; email-prefs card only if `$formdata.emailPreferences`; alerts only when present.
- **Interactions:** Static form, no JS.

### `account-user-management` — User Management
- **Route:** /clientarea.php?action=security (User Management) — POST routes account-users-invite / -invite-resend / -invite-cancel / -remove
- **Purpose:** See who has access to the account, invite new users, manage/remove their access, and handle pending invites.
- **Layout shape:** Two-column: main column (users list + invite form) + right account sub-nav aside; main has populated vs empty variants.
- **Page header:** H1 = "User Management"; subtitle = "Invite people to access this account and choose what they can do."; header row also has an "Invite new user" action that jumps to the invite form.
- **Sections (top → bottom):**
  1. **Alert (conditional)** — flash message (error/success/warning/info).
  2. **Users list (populated)** — one row per user: avatar initial, name, Owner tag (if owner), email, 2FA-enabled shield icon (if enabled), last-login ("X ago" or "Never"); row actions Permissions (disabled for owner) and Remove (non-owners).
  3. **Pending invites (conditional, within list)** — section label + one row per invite: email, "Invited X ago", actions Resend (form) and Cancel.
  4. **Empty state (alternate)** — "No additional users" with explanatory copy.
  5. **Invite form card** — email field; permission mode radios ("All permissions" / "Choose individual permissions"); a hidden individual-permissions checklist (title + description per permission); Send invitation button.
  6. **Sub-nav (aside)** — Account Details, User Management (active), Payment Methods, Contacts, Email History.
- **Key data fields:** per user — id, firstname, lastname, email, owner flag, 2FA-enabled bool, last-login time; per invite — id, email, created_at; permissions list (key, title, description); formdata.inviteemail; CSRF token.
- **Actions / CTAs:** Invite new user (anchor →#umInviteForm); Send invitation (POST →account-users-invite); Resend (POST →account-users-invite-resend); Cancel invite (POST →account-users-invite-cancel via hidden form); Permissions (→account-users-permissions/{id}); Remove (POST →account-users-remove via hidden form); sub-nav links.
- **States & conditionals:** body `data-data` full vs empty from user+invite counts; owner row has Permissions disabled and no Remove; 2FA icon only if enabled; invite section only if invites exist; individual-perms checklist hidden until "choose" radio selected.
- **Interactions:** "choose" radio reveals the per-permission checklist (JS); Remove and Cancel-invite buttons each confirm() then submit a hidden form (JS).

### `clientareausers` — User Management (alias)
- Forwarder: `default.tpl` only `{include}`s `account-user-management/default/default.tpl`. Identical content/behavior to **account-user-management**.

### `account-user-permissions` — User Permissions
- **Route:** /clientarea.php?action=security (per-user permissions) — POST →account-users-permissions-save/{userId}
- **Purpose:** Toggle what an individual sub-user can see and do on the account.
- **Layout shape:** Two-column: main column (selected-user card + permissions form) + right account sub-nav aside; main has populated vs empty variants.
- **Page header:** eyebrow = "Account"; H1 = "User permissions"; subtitle = "Choose what this user can see and do on the account."
- **Sections (top → bottom):**
  1. **Selected-user card (populated)** — avatar initial + the user's email + "Permissions" sub-label.
  2. **Permissions card (populated)** — header "Permissions"; one row per permission: title, description, and an on/off toggle (checkbox) pre-checked from the user's current permissions.
  3. **Actions (populated)** — Save permissions + Cancel.
  4. **Empty state (alternate)** — "No user selected" with copy + a "User management" CTA.
  5. **Sub-nav (aside)** — Account Details, User Management (active), Payment Methods, Contacts.
- **Key data fields:** user id + email; permissions list (key, title, description); userPermissions->hasPermission(key) per-row checked state; CSRF token.
- **Actions / CTAs:** Save permissions (POST →account-users-permissions-save/{id}); Cancel (→account-users); empty-state User management (→account-users); sub-nav links.
- **States & conditionals:** body `data-data` full vs empty from whether permissions exist; under `?preview=1` with no real data, a hardcoded demo permission list renders (form action becomes "#"); per-row description shown only if present.
- **Interactions:** Static toggles (plain checkboxes styled as switches); no custom JS.

### `account-paymentmethods` — Payment Methods
- **Route:** /clientarea.php?action=details (Payment Methods) — routes account-paymentmethods-add / -view / -setdefault / -delete
- **Purpose:** List saved cards/bank accounts, add new ones, set a default, edit, or remove.
- **Layout shape:** Two-column: main column (results alerts + methods list + add buttons) + right account sub-nav aside; list has populated vs empty variants.
- **Page header:** H1 = "Payment Methods"; subtitle = "Cards and bank accounts you have saved for fast checkout."
- **Sections (top → bottom):**
  1. **Alerts (conditional)** — flash message plus result banners for add/update/set-default/delete success or failure.
  2. **Payment methods list (populated)** — one row per method: gateway icon, gateway display name, Default tag (if default), Expired tag (if expired), and either the user description or the method status; row actions Set default (non-default, non-expired), Edit (unless RemoteBankAccount), Delete (if allowed).
  3. **Add buttons** — "Add new credit card" (if allowed) and "Add bank account" (if allowed).
  4. **Empty state (alternate)** — "No payment methods yet" with copy.
  5. **Sub-nav (aside)** — Account Details, User Management, Payment Methods (active), Contacts, Security.
- **Key data fields:** per method — id, gateway display name, type, FontAwesome icon, description, status, isDefault, isExpired; feature flags allowCreditCard / allowBankDetails / allowDelete.
- **Actions / CTAs:** Set default (→account-paymentmethods-setdefault/{id}); Edit (→account-paymentmethods-view/{id}); Delete (→account-paymentmethods-delete/{id}, confirm); Add new credit card (→account-paymentmethods-add); Add bank account (→account-paymentmethods-add?type=bankacct); sub-nav links.
- **States & conditionals:** populated list shown only when methods exist (count>0), else empty state; Default/Expired tags conditional; Set-default hidden for default/expired; Edit hidden for RemoteBankAccount; Delete only if `$allowDelete`; add buttons gated by their feature flags; result banners only after the matching action.
- **Interactions:** Delete links trigger a confirm() before navigating (JS); otherwise static.

### `account-paymentmethods-manage` — Manage / Edit Payment Method
- **Route:** /clientarea.php (account-paymentmethods-view/{id}) — also targets account-paymentmethods-add and -delete
- **Purpose:** Edit a saved payment method's card and billing-address details, set it as default, or delete it.
- **Layout shape:** Two-column: main column (hero summary + edit form + danger zone) + right account sub-nav aside; main has populated vs empty variants.
- **Page header:** H1 = "Manage payment method"; subtitle = "Update card details, change the default, or remove this payment method."
- **Sections (top → bottom):**
  1. **Alert (conditional)** — flash message.
  2. **Method hero card (populated)** — card-brand visual, method name, Default pill (if default), and a sub-line (e.g. cardholder + expiry).
  3. **Update card details card (populated)** — "Card" group: Cardholder name, Card number, Expiration, CVV. "Billing address" group: Street address, City, State/region, Postcode, Country (select); plus a "Default payment method" checkbox; Save changes + Cancel.
  4. **Danger zone card (only for an existing method)** — "Remove this payment method" copy + Delete button.
  5. **Empty state (alternate)** — "No payment method selected" with an "Add payment method" CTA.
  6. **Sub-nav (aside)** — Account Details, Payment Methods (active), Billing Contacts, Contacts.
- **Key data fields:** payMethod id, description / gateway display name, type, isDefault, isExpired; card-capture fields ccname, ccnumber, ccexpiry, cccvv; billing address1, city, state, postcode, country; set_default flag; CSRF token. (Demo: "Visa ending in 4242", "Expires 12/2027".)
- **Actions / CTAs:** Save changes (POST →account-paymentmethods-view/{id}, or →add when new); Cancel (→account-paymentmethods); Delete payment method (POST →account-paymentmethods-delete/{id}, confirm); empty-state Add payment method (→account-paymentmethods-add); sub-nav links.
- **States & conditionals:** body `data-data` full vs empty from whether a method is loaded; under `?preview=1` with no real method, a demo method renders; danger-zone delete only when an existing method (`$pmHas`); card-capture form is the standard fallback (tokenized gateways inject their own).
- **Interactions:** Delete form uses an inline onsubmit confirm(); no other JS.

### `account-paymentmethods-billing-contacts` — Billing Contacts
- **Route:** /clientarea.php (account-paymentmethods-billing-contacts)
- **Purpose:** View the contacts who are copied on invoice and receipt emails; jump out to add/edit them.
- **Layout shape:** Two-column: main column (contacts list) + right account sub-nav aside; list has populated vs empty variants.
- **Page header:** H1 = "Billing contacts"; subtitle = "Recipients copied on invoice and payment receipt emails."; header row also has an "Add billing contact" CTA.
- **Sections (top → bottom):**
  1. **Billing contacts list (populated)** — one card per contact: avatar initials, name, Primary pill (if primary), email, and an Edit action.
  2. **Empty state (alternate)** — "No billing contacts" with copy + an "Add billing contact" CTA.
  3. **Sub-nav (aside)** — Payment Methods, Billing Contacts (active), Contacts, Account Details.
- **Key data fields:** per contact — id, name, email, primary flag. (Demo: "Arshile Gogia / arshileg@gmail.com" primary, "Finance Department".)
- **Actions / CTAs:** Add billing contact (header + empty state, →account-contacts); per-row Edit (→account-contacts); sub-nav links.
- **States & conditionals:** body `data-data` full vs empty from contact count; under `?preview=1` with none, a 2-row demo list renders; Primary pill only when flagged. (Note: editing/adding is delegated to the account-contacts page — this page is read/list only.)
- **Interactions:** Static, none.

### `clientareaemails` — Email History
- **Route:** /clientarea.php?action=emails
- **Purpose:** Browse the list of system emails sent to the account and open any to read it.
- **Layout shape:** Two-column: main column (full-width table inside a card) + right account sub-nav aside; table has populated vs empty variants.
- **Page header:** eyebrow = "Account"; H1 = "Email history"; subtitle = "Messages we have sent to your account email address."
- **Sections (top → bottom):**
  1. **Email table (populated)** — columns: **Date**, **Subject** (subject is a link; an attachment paperclip icon shows when attachmentCount>0); whole row is clickable.
  2. **Empty state (alternate)** — "No emails yet" with copy + an "Account details" CTA.
  3. **Sub-nav (aside)** — Account Details, Contacts, Email History (active), Security.
- **Key data fields:** per email — id, date, subject, attachmentCount. (Demo: 4 sample emails.)
- **Actions / CTAs:** open an email (link / row →viewemail.php?id={id}, opens in popup window); empty-state Account details (→clientarea.php?action=details); sub-nav links.
- **States & conditionals:** body `data-data` full vs empty from email count; under `?preview=1` with none, a demo list renders; paperclip icon only when the email has attachments.
- **Interactions:** Clicking a table row opens viewemail.php in a 680×520 popup window (JS); clicking the subject link behaves normally.

### `viewemail` — View Email (popup)
- **Route:** /viewemail.php?id=X (standalone popup window, no client-area chrome)
- **Purpose:** Read the full body of a single sent email and its attachments.
- **Layout shape:** Standalone HTML document — single centered card in a popup (emits its own `<html>`/`<head>`/`<body>`).
- **Page header:** eyebrow = "Email"; H1 = company name.
- **Sections (top → bottom):**
  1. **Message body (populated)** — the rendered email HTML body.
  2. **Attachments (conditional)** — "Attachments" label + one row per attached filename with a paperclip icon.
  3. **Empty state (alternate)** — "This email is no longer available."
- **Key data fields:** message (email body HTML), attachments (filenames array), companyname. (Demo body under preview.)
- **Actions / CTAs:** none (read-only viewer; attachment filenames are listed, not linked).
- **States & conditionals:** message body vs the "no longer available" empty message depending on `$message`; attachments block only if any exist; under `?preview=1` a demo body is shown.
- **Interactions:** Static, none.

### `user-profile` — Your Profile
- **Route:** /user/profile — POST routes user-profile-save and user-profile-email-save
- **Purpose:** Edit the name and email on your personal sign-in (user) account, separate from the client/billing account.
- **Layout shape:** Two-column: left "Your Profile" sub-nav aside + right main column with two stacked form cards.
- **Page header:** H1 = "Your Profile"; subtitle = "Personal information attached to your sign-in account."
- **Sections (top → bottom):**
  1. **Profile sub-nav (aside)** — Your Profile (active), Switch Account, Change Password, Security Settings.
  2. **Alert (conditional)** — flash message.
  3. **Personal information card** — First name + Last name fields (each disabled if listed uneditable); Cancel (reset) + Save changes.
  4. **Change email address card** — verification tag (Verified / Not verified); Email address field (disabled if uneditable) with "Used to sign in" help; Existing password field (required, only if email is editable) with help text; Cancel + Save changes (shown only when email editable).
- **Key data fields:** user.firstName, user.lastName, user.email; email verification state (needsToCompleteEmailVerification / emailVerified); uneditableFields list; existing_password; CSRF token.
- **Actions / CTAs:** Save changes — name (POST →user-profile-save); Save changes — email (POST →user-profile-email-save, requires existing password); Cancel buttons (form reset); sub-nav links.
- **States & conditionals:** Verified/Not-verified tag depends on verification state; any field disabled if its name is in `$uneditableFields`; the existing-password field and the email card's save actions appear only when email is editable.
- **Interactions:** Static forms, no JS.

### `user-password` — Change Password
- **Route:** /clientarea.php?action=changepw (POST to same)
- **Purpose:** Change your account password (current → new → confirm).
- **Layout shape:** Two-column: left "Your Profile" sub-nav aside + right single form card.
- **Page header:** H1 = "Change password"; subtitle = "Pick a strong new password — minimum 8 characters with mixed case and numbers."
- **Sections (top → bottom):**
  1. **Profile sub-nav (aside)** — Account Details, Change Password (active), Security Settings.
  2. **Alerts (conditional)** — success banner ("Password updated successfully.") and error banner listing validation messages.
  3. **Password form card** — Current password; New password (with a live strength meter bar + label); Confirm new password (with a live match message); Cancel + Change password.
- **Key data fields:** existingpw, newpw, confirmpw; success flag; errormessage (string or array); CSRF token.
- **Actions / CTAs:** Change password (POST →clientarea.php?action=changepw); Cancel (→clientarea.php?action=details); sub-nav links.
- **States & conditionals:** success banner only when `$successful`; error banner only when `$errormessage` present (iterated if an array).
- **Interactions:** JS password-strength meter (scores length/case/digits/symbols → Too weak…Strong) and a real-time "Passwords match / do not match" check on the confirm field.

### `changepassword` — Change Password (alias)
- Forwarder: `default.tpl` only `{include}`s `user-password/default/default.tpl` (dispatcher reads `$hadrian.pages.changepassword` so admin variant/SEO still apply). Identical content/behavior to **user-password**.

### `changepw` — Change Password (alias)
- Forwarder: `default.tpl` only `{include}`s `user-password/default/default.tpl`. Identical content/behavior to **user-password**.

### `clientareasecurity` — Security Settings
- **Route:** /clientarea.php?action=security
- **Purpose:** Manage two-factor authentication, login-alert preferences, and active sign-in sessions.
- **Layout shape:** Two-column: left "Your Profile" sub-nav aside + right main column with stacked cards.
- **Page header:** H1 = "Security settings"; subtitle = "Two-factor authentication, sign-in devices, and login alerts."
- **Sections (top → bottom):**
  1. **Profile sub-nav (aside)** — Account Details, Change Password, Security Settings (active), Logout (danger).
  2. **Two-factor authentication card** — shield icon (state-dependent); status row with title + Enabled/Disabled pill; descriptive copy (state-dependent); Enable/Disable two-factor CTA; a 3-item methods grid (Authenticator app [Recommended], Email codes [shows alert email], Security key).
  3. **Login alerts card** — three rows, each title + "Alerts sent to {email}" + an on/off toggle switch: new-device sign-in (on), password change (on), payment-method change (off).
  4. **Active sessions card** — "Current session" row tagged "This device" / "Active now"; footer note + "Sign out all other sessions" link.
- **Key data fields:** twoFactorEnabled, twoFactorEnforced, clientsdetails.email (alert recipient).
- **Actions / CTAs:** Enable/Disable two-factor (→clientarea.php?action=security&tfaEnable=true or &tfaDisable=true); Sign out all other sessions (→logout.php?all=true); Logout (→logout.php); sub-nav links.
- **States & conditionals:** shield icon, status pill, description text, and the Enable-vs-Disable CTA all switch on `$twoFactorEnabled`; email codes method line shows the account email.
- **Interactions:** Login-alert toggle switches flip visual state on click (JS, cosmetic only — no server persistence yet).

### `user-security` — User Security (alias)
- Forwarder: `default.tpl` only `{include}`s `clientareasecurity/default/default.tpl` (WHMCS 9 splits account- vs user-level security but the UI is shared). Identical content/behavior to **clientareasecurity**.

### `user-switch-account` — Switch Account
- **Route:** /user/accounts — POST →user-accounts (body has `id` of target account)
- **Purpose:** Choose which client account (of those you can access) to manage.
- **Layout shape:** Two-column: main column (accounts list) + right "Your Profile" sub-nav aside; list has populated vs empty variants.
- **Page header:** H1 = "Switch account"; subtitle = "Pick the account you want to manage."
- **Sections (top → bottom):**
  1. **Alert (conditional)** — flash message.
  2. **Accounts list (populated)** — one clickable row per account: avatar initial, display name, Owner tag (if owner), Closed status tag (if closed), account "#id", and a "Switch to" button (disabled label for closed accounts).
  3. **Empty state (alternate)** — "No accounts to switch to" with copy + a "Continue to client area" CTA.
  4. **Sub-nav (aside)** — Your Profile, Switch Account (active), Change Password, Security Settings.
- **Key data fields:** per account — id, displayName, status, authedUserIsOwner; CSRF token.
- **Actions / CTAs:** Switch to an account (clicking a row sets `id` and submits the hidden form →user-accounts); Continue to client area (empty state, →clientarea.php); sub-nav links.
- **States & conditionals:** body `data-data` full vs empty from account count; closed accounts render disabled (not clickable) with their status tag; Owner tag only for owned accounts.
- **Interactions:** Clicking an enabled account row sets the hidden `id` field and submits the switch form (JS); disabled rows do nothing.

## SSL & public/informational

### `configuressl-stepone` — Configure SSL · Step 1 (Configuration)
- **Route:** /configuressl.php?cert=X&step=1 (form posts to /configuressl.php?cert=X&step=2)
- **Purpose:** Supply server type, certificate signing request (CSR), and the administrative contact for a newly purchased SSL cert.
- **Layout shape:** Page header + 3-step wizard stepper + stacked cards; form spans two cards (single column, with a 2-column field grid inside the contact card).
- **Page header:** eyebrow = "SSL Certificate"; H1 = "Configure your SSL certificate"; subtitle = instruction to provide server type, CSR, and admin contact.
- **Sections (top → bottom):**
  1. **Wizard stepper** — 3 steps: 1 Configuration (active), 2 Validation, 3 Complete.
  2. **Error alert (conditional)** — `$errormessage` validation HTML.
  3. **Server configuration card** — info note; Server type select (`$webservertypes`: Apache+mod_ssl / Nginx / Microsoft IIS / Other; with empty "Please choose..." option); CSR textarea (placeholder `-----BEGIN CERTIFICATE REQUEST-----`); any `$additionalfields` (heading + raw-HTML inputs + descriptions).
  4. **Administrative contact card** — info note ("appears on the certificate and receives validation emails"); field grid: First name, Last name, Organization, Job title, Email, Phone number, Address line 1, Address line 2, City, State/region, Postcode, Country select (`$clientcountries`).
  5. **Button group** — Continue (submit); Cancel.
- **Key data fields:** cert token `$cert`, `$serviceid`, `$servertype`, `$csr`, `$additionalfields[heading][{name,input,description}]`, contact fields (firstname, lastname, orgname, jobtitle, email, phonenumber, address1, address2, city, state, postcode, country), `$clientcountries`, `$webservertypes`, `$status`.
- **Actions / CTAs:** Continue (submit →step=2); Cancel (→clientarea.php?action=services); empty-state buttons "My services" (→services).
- **States & conditionals:** form renders only when `$status == 'Awaiting Configuration'`; otherwise an empty notice card — one message if status exists but disallows config ("cannot be configured right now"), another if the link is invalid/expired ("No SSL certificate to configure"); error alert only when `$errormessage` set; preview demo data injected under `?preview=1`.
- **Interactions:** Static, none (no client-side JS on this step).

### `configuressl-steptwo` — Configure SSL · Step 2 (Validation method)
- **Route:** /configuressl.php?cert=X&step=2 (form posts to /configuressl.php?cert=X&step=3)
- **Purpose:** Choose how to prove domain ownership so the CA can issue the certificate.
- **Layout shape:** Page header + 3-step wizard stepper + single card holding a radio-list form.
- **Page header:** eyebrow = "SSL Certificate"; H1 = "Verify domain ownership"; subtitle explains choosing a control-proof method.
- **Sections (top → bottom):**
  1. **Wizard stepper** — step 1 done, step 2 active, step 3 upcoming.
  2. **Error alert (conditional)** — `$errormessage`.
  3. **Validation method card** — radio list from `$approvalMethods`: Email validation, DNS (TXT record), HTTP file upload (first option pre-checked; falls back to Email-only radio if list empty).
  4. **Approver-email picker (conditional)** — radio list of `$approveremails` to receive the email link; shown only with the Email method.
  5. **Button group** — Continue (submit); Cancel.
- **Key data fields:** cert token `$cert`, `$approvalMethods[]` (email | dns-txt-token | file), `$approveremails[]` (approved domain addresses).
- **Actions / CTAs:** Continue (submit →step=3); Cancel (→services); empty-state "Back to configuration" (→configuressl.php).
- **States & conditionals:** form renders only when a cert token exists, else empty notice ("Configuration not complete"); approver-email block only when `$approveremails` present; error alert when `$errormessage` set; preview demo data under `?preview=1`.
- **Interactions:** JS shows/hides the approver-email block based on which validation method radio is selected.

### `configuressl-complete` — Configure SSL · Step 3 (Complete / validation instructions)
- **Route:** /configuressl.php?cert=X&step=3 (terminal result page)
- **Purpose:** Confirm the cert request was submitted and show the remaining domain-validation instructions.
- **Layout shape:** Page header + 3-step wizard stepper + centered success block + a single centered instructions card; centered button group.
- **Page header:** eyebrow = "SSL Certificate"; H1 = "Certificate request submitted"; subtitle = complete the validation step below.
- **Sections (top → bottom):**
  1. **Wizard stepper** — steps 1 & 2 done, step 3 active.
  2. **Success block** — checkmark icon, "Configuration complete", sentence naming `$domain` if present.
  3. **Validation instructions card (conditional, branches on method):** Email → info note + read-only approver email field; DNS → info note + read-only Type / Host / Value fields (Host & Value have copy buttons); File → info note + read-only File URL (`http://{domain}/{filePath}`) and File contents fields (both with copy buttons).
  4. **Button group** — View my services; Contact support.
- **Key data fields:** `$domain`, `$authData` (method via `methodNameConstant()` = emailauth | dnsauth | fileauth; `->email`; `->type/->host/->value`; `->filePath()/->contents`).
- **Actions / CTAs:** View my services (→services); Contact support (→supporttickets.php); copy buttons on DNS/file values; failure-state "Try again" (→configuressl.php).
- **States & conditionals:** success state when no `$errormessage`; failure empty-state notice ("Configuration could not be completed", showing the error text) when `$errormessage` set; the instructions card renders only for the matching `$authData` method; a sample DNS card shows under `?preview=1` when no `$authData`.
- **Interactions:** JS copy-to-clipboard for `[data-copy]` fields (DNS host/value, file URL/contents).

### `managessl` — Manage SSL
- **Route:** /clientarea.php?action=ssl (or managessl.php)
- **Purpose:** List all SSL certificates on the account with status and configure/renew/manage actions.
- **Layout shape:** Page header with inline action button + full-width table inside a card; empty-state card otherwise.
- **Page header:** eyebrow = "SSL Certificates"; H1 = "Manage SSL"; subtitle = view status / configure / renew; right-aligned "Order new certificate" button (only when list populated).
- **Sections (top → bottom):**
  1. **Certificates table** — columns: Domain, Certificate (product name + validation-type badge DV/OV/EV), Status, Renews (next due date), Actions.
  2. **Empty state (conditional)** — shield icon, "No certificates yet", subtext, "Browse SSL" button.
- **Key data fields:** `$sslProducts` collection (each: `validationType` DV/OV/EV, `status`, domain via service or addon, product/addon name, `nextDueDateFormatted`, `nextDueDateProperties` isPast/isFuture/daysTillExpiry, `getConfigurationUrl()`, `getUpgradeUrl()`, `id`); status constants `$sslStatusAwaitingConfiguration`, `$sslStatusAwaitingIssuance`.
- **Actions / CTAs:** Order new certificate (→cart.php?gid=ssl); per-row Configure (→getConfigurationUrl / configuressl.php), Renew/Upgrade (POST form →getUpgradeUrl, disabled for EV), Manage (→services); empty-state "Browse SSL" (→cart.php?gid=ssl).
- **States & conditionals:** populated table vs empty card; per-row status pill resolves to Awaiting config / Awaiting issuance / Expired (isPast) / Expiring soon (<60 days) / Active; Configure action only when awaiting configuration; Renew/Upgrade only when isFuture (EV disabled); preview demo rows under `?preview=1`.
- **Interactions:** Static, none.

### `contact` — Contact Us
- **Route:** /contact.php (form posts to /contact.php with `send=true`)
- **Purpose:** Public contact form; send a message to a chosen department.
- **Layout shape:** Centered single card.
- **Page header:** none (card title H1 = "Contact us"; sub-line = "Send us a message and our team will follow up").
- **Sections (top → bottom):**
  1. **Success state (conditional)** — checkmark icon, "Message sent", thank-you subtext, "Back to home" button (replaces the form after submit).
  2. **Error banner (conditional)** — `$errormessage` (array or string of validation errors).
  3. **Contact form** — Your name + Email address (2-up row); Department select (conditional on `$departments`); Subject; Message textarea; captcha (conditional); "Send message" submit.
- **Key data fields:** `$departments[]` (id, name), sticky `$name`/`$email`/`$subject`/`$message`, `$errormessage`, `$captcha`, `$sent`.
- **Actions / CTAs:** Send message (submit →contact.php); Back to home (→/, shown after success).
- **States & conditionals:** success view vs form view (`$sent`); error banner only on validation failure; Department select only if `$departments` present; captcha only if enabled.
- **Interactions:** Static, none (native HTML5 required-field validation only).

### `serverstatus` — Server Status
- **Route:** /serverstatus.php (optional ?view=open|scheduled|resolved, ?page=N)
- **Purpose:** Public status page — live network/server availability plus active incidents and scheduled maintenance.
- **Layout shape:** Page header + two-column split: main column (status banner, filter tabs, incidents, servers table) + right "Support" sub-nav aside.
- **Page header:** H1 = "Server Status"; subtitle = live availability + incidents/maintenance (no eyebrow/pill).
- **Sections (top → bottom):**
  1. **Overall status banner** — dot + title + subtext; state = down (open incidents) / warn (scheduled) / ok (all operational); a "Preview" badge under `?preview=1`.
  2. **Issue filter tabs (conditional)** — All / Active(open count) / Scheduled(count) / Resolved, linking to `?view=` filters.
  3. **Incidents section** — list of `$issues` cards: title, severity badge (Critical/High/Medium/Low or Scheduled), affecting (type + server/region), "may be affecting your services" flag, description, meta row (status dot, start–end date, "Updated" lastupdate); pagination (Previous/Next) for live data.
  4. **Servers section** — table-like list: Server (host + status dot), Services (HTTP/FTP/POP3 port dots), Load (value + bar), Uptime, optional PHP-info link; legend = Operational / Disrupted / Checking.
  5. **Support sub-nav aside** — links: My support tickets, Announcements, Knowledgebase, Downloads, Server status (active), Open ticket.
- **Key data fields:** `$servers[]` (name, phpinfourl; live port/load/uptime filled via AJAX), `$issues[]` (title, status, priority/rawPriority, type, server, affecting, startdate, enddate, lastupdate, clientaffected, description), `$opencount`, `$scheduledcount`, `$resolvedcount`, `$view`, `$noissuesmsg`, `$prevpage`/`$nextpage`.
- **Actions / CTAs:** filter tabs (→?view=...); pagination Previous/Next; per-server PHP-info link (new tab); empty-state "Report a problem" (→submitticket.php); sub-nav links (supporttickets, announcements, knowledgebase, downloads, serverstatus, submitticket).
- **States & conditionals:** empty/all-clear state (no servers + no issues) shows "All systems operational" banner + "No servers monitored yet" card; populated state shows banner severity by open/scheduled counts; incidents list has its own no-issues fallback; pagination only with live data; preview demo servers+incidents under `?preview=1`.
- **Interactions:** JS polls `serverstatus.php` (POST ping per port 80/21/110) to set per-port status dots, then rolls them up into the server's overall dot; defers to core `getStats()` for load/uptime if present; live JS runs only with real servers (not in demo).

### `downloads` — Downloads (category browser)
- **Route:** /downloads.php
- **Purpose:** Browse downloadable files by category and see the most-popular files; search downloads.
- **Layout shape:** Page header + two-column split: left "Support" sub-nav aside + right content (search bar, category grid, popular-files list).
- **Page header:** H1 = "Downloads"; subtitle = software/guides/templates, browse by category or search (no eyebrow).
- **Sections (top → bottom):**
  1. **Support sub-nav aside** — My support tickets, Announcements, Knowledgebase, Downloads (active), Server status, Open ticket.
  2. **Search bar** — search input (posts to download-search route).
  3. **Categories grid** — `$dlcats` cards: folder icon, name + chevron, description, file count.
  4. **Most popular list** — `$mostdownloads` rows: file-type icon (PDF/ZIP/etc.), title (+ clients-only lock icon), filesize · download-count description, download action icon.
  5. **Empty state (conditional)** — download icon, "No downloads available", subtext, "Open knowledge base" button.
- **Key data fields:** `$dlcats[]` (id, urlfriendlyname, name, numarticles, description), `$mostdownloads[]` (link, title, clientsonly, filesize, description, type).
- **Actions / CTAs:** search submit (→download-search); category card (→download-by-cat route w/ id+slug); popular-file row (→file link); empty-state "Open knowledge base" (→knowledgebase.php); sub-nav links.
- **States & conditionals:** populated (categories and/or popular files) vs empty card; Categories block only if `$dlcats`; Most-popular block only if `$mostdownloads`; clients-only lock icon per file when flagged; preview demo categories + popular files under `?preview=1`.
- **Interactions:** Static, none (search is a server-side form submit).

### `downloadscat` — Download Category (files in a category)
- **Route:** /downloads.php?action=displaycat&catid=X (download-by-cat route)
- **Purpose:** List files (and any subcategories) within one download category; search/filter/sort client-side.
- **Layout shape:** Page header (with file-count meta) + two-column split: left "Support" sub-nav aside + right content card (category banner, subcategory rows, toolbar, file list, footer).
- **Page header:** H1 = category name (`$pagetitle`); subtitle = files in this category; meta = "{N} files" (when files exist; no eyebrow).
- **Sections (top → bottom):**
  1. **Support sub-nav aside** — same links as Downloads (Downloads active).
  2. **Category banner** — file icon + category title + sub-line.
  3. **Subcategories (conditional)** — `$dlcats` rows: folder icon, name, file count, "Open" affordance (→download-by-cat).
  4. **Toolbar (when files exist)** — in-category search input; type filter pills (All / PDF / ZIP / Other); sort select (Most recent / Alphabetical).
  5. **File list** — `$downloads` rows: file-type icon, title (+ "New" pill, + clients-only lock), description, filesize, "Download" button.
  6. **Footer** — "Showing {N}" count + "All downloads" link.
  7. **Empty state (conditional)** — file icon, "No downloads in this category", subtext, "All downloads" button.
- **Key data fields:** `$pagetitle` (category name), `$downloads[]` (link, title, clientsonly, filesize, description, type, isnew), `$dlcats[]` subcategories (id, urlfriendlyname, name, numarticles).
- **Actions / CTAs:** per-file Download (→file link); subcategory row (→download-by-cat); search/filter/sort (client-side); "All downloads" footer + empty-state buttons (→downloads.php); sub-nav links.
- **States & conditionals:** populated (files and/or subcategories) vs empty card; subcategory block only if `$dlcats`; toolbar/file-list/footer only if files exist; "New" pill per file when `isnew`; clients-only lock per file when flagged; preview demo files under `?preview=1`.
- **Interactions:** JS filtering by type pill + free-text search (hides rows), and re-sorting rows by recent (original index) or alphabetical name.

### `downloaddenied` — Download Denied
- **Route:** /dl.php (or downloads.php) when a protected file download is blocked
- **Purpose:** Inform the user they lack permission to download a requested file.
- **Layout shape:** Page header + single centered notice card.
- **Page header:** eyebrow = "Downloads"; H1 = "Download denied"; subtitle = "You don't have access to this download."
- **Sections (top → bottom):**
  1. **Denied notice card** — crossed-out download icon; heading "You don't have permission to download this file"; body text (shows `$errormessage` if set, else default about needing an active service / required role); actions row.
- **Key data fields:** `$errormessage` (optional reason text).
- **Actions / CTAs:** View my services (→clientarea.php?action=services); Contact support (→supporttickets.php); empty-state "All downloads" (→downloads.php).
- **States & conditionals:** real denial renders the populated notice (default); a preview-only empty variant ("No download in progress") exists for the state chip; body text swaps to `$errormessage` when present.
- **Interactions:** Static, none.
