# WHMCS pages — master reference

Every page WHMCS can render in the client portal, grouped by purpose. Use this as the single source of truth when scoping work — `docs/PAGE-CHECKLIST.md` describes *how* to build a page, this file lists *which* pages exist.

Sources: Lagom 2.3.0 (`templates/lagom2/*.tpl`), Nexus / WHMCS 9.0.2 official (`templates/nexus/*.tpl`), and our live pages.csv. URL patterns are observed defaults; some installs route through different paths (e.g. `/clientarea.php?action=X` vs `/account/X` vs `/X.php`).

## Status legend
- ✅ **Full** — real WHMCS variables wired, polished UI, lint-clean
- ⚠️ **Scaffold** — 5-file skeleton in place, default.tpl renders a real H1 + page-prefix div, but real WHMCS variable wiring is pending
- ❌ **Missing** — no dispatcher, no skeleton, WHMCS falls back to error or Six's tpl

The **URL** column shows the user-visible path. The **Templatefile** column shows WHMCS's internal name (sometimes differs from the URL slug — see §10 trap in PAGE-CHECKLIST). The dispatcher tpl in `templates/mytheme/` matches the templatefile name.

---

## 1. Authentication & onboarding

| Templatefile | URL | Status | Notes |
|---|---|---|---|
| `login` | `/clientarea.php` (logged out) | ✅ | Default landing for unauthenticated visitors |
| `clientregister` | `/register` | ✅ | New-account registration form |
| `user-invite-accept` | `/user-invite-accept?token=…` | ✅ | Accept a sub-user invitation |
| `user-verify-email` | `/clientarea.php?action=verify-email` | ✅ | Result of clicking the email-verification link |
| `two-factor-challenge` | `/login` (during 2FA challenge) | ✅ | Enter TOTP / backup code |
| `two-factor-new-backup-code` | `/clientarea.php?action=twofactor&sub=backup` | ✅ | Show newly-generated backup codes |
| `password-reset-container` | `/pwreset.php` (landing) | ✅ | Wrapper / status after submitting email |
| `password-reset-email-prompt` | `/pwreset.php` (step 1) | ✅ | Enter your email |
| `password-reset-security-prompt` | `/pwreset.php` (step 2) | ✅ | Answer security question |
| `password-reset-change-prompt` | `/pwreset.php` (step 3) | ✅ | Pick new password |

All four `password-reset-*` dispatchers forward to a single shared `pwreset/default/default.tpl` that branches on `$templatefile`.

## 2. Core client area

| Templatefile | URL | Status | Notes |
|---|---|---|---|
| `clientareahome` | `/clientarea.php` | ✅ | Dashboard with active-services / open-tickets / recent-invoices / news |
| `clientareaproducts` | `/clientarea.php?action=services` | ✅ | Services list with status filter |
| `clientareaproductdetails` | `/clientarea.php?action=productdetails&id=X` | ✅ | Single service: overview / login info / upgrade / cancel sub-tabs |
| `clientareadomains` | `/clientarea.php?action=domains` | ✅ | Domains list |
| `clientareaquotes` | `/clientarea.php?action=quotes` | ✅ | Sales quotes list with stage filter |
| `clientareainvoices` | `/clientarea.php?action=invoices` | ✅ | Invoices list with DataTables sort |
| `homepage` | `/` | ✅ | Public landing |

## 3. Domain management

| Templatefile | URL | Status | Notes |
|---|---|---|---|
| `clientareadomaindetails` | `/clientarea.php?action=domaindetails&id=X` | ⚠️ | Single domain — tabs for nameservers / addons / contact info etc. |
| `clientareadomaindns` | `/clientarea.php?action=domaindns&id=X` | ⚠️ | DNS record editor (A / AAAA / MX / TXT / CNAME) |
| `clientareadomainemailforwarding` | `/clientarea.php?action=emailforwarding&id=X` | ⚠️ | Email-forwarding rules per domain |
| `clientareadomainregisterns` | `/clientarea.php?action=registerns&id=X` | ⚠️ | Register custom nameservers at registrar |
| `clientareadomaingetepp` | `/clientarea.php?action=getepp&id=X` | ⚠️ | Retrieve domain auth code |
| `clientareadomainaddons` | `/clientarea.php?action=domainaddons&id=X` | ⚠️ | WHOIS privacy / ID protection toggles |
| `clientareadomaincontactinfo` | `/clientarea.php?action=contactinfo&id=X` | ⚠️ | Registrant / admin / tech / billing contact editor |
| `bulkdomainmanagement` | `/clientarea.php?action=bulkdomainmanagement` | ⚠️ | Apply NS / auto-renew / lock changes to many domains |
| `domain-pricing` | `/cart.php?a=add&domain=register` | ⚠️ | Public TLD pricing table |

## 4. Billing

| Templatefile | URL | Status | Notes |
|---|---|---|---|
| `viewinvoice` | `/viewinvoice.php?id=X` | ✅ | Single invoice — line items, totals, transactions, pay-now |
| `invoicepdf` | `/viewinvoice.php?id=X&pdf=true` | — | PDF render via TCPDF, not a Smarty template — lives in `templates/pdf/` if customisation is ever needed. Out of scope for the client-area theme. |
| `invoice-payment` | `/viewinvoice.php?id=X` (with `?paynow=true`) | ✅ | Standalone payment screen (gateway selection) |
| `viewquote` | `/viewquote.php?id=X` | ⚠️ | Single quote — line items, accept/decline |
| `quotepdf` | `/viewquote.php?id=X&pdf=true` | — | Same situation as invoicepdf — TCPDF render under `templates/pdf/`, out of scope for the client-area theme. |
| `clientareaaddfunds` | `/clientarea.php?action=addfunds` | ✅ | Top-up account credit with preset chips + live summary |
| `masspay` | `/clientarea.php?action=masspay&all=true` | ✅ | Bulk-pay unpaid invoices |
| `clientareacancelrequest` | `/clientarea.php?action=cancel&id=X` | ⚠️ | Cancellation reason + timing form |
| `subscription-manage` | `/clientarea.php?action=subscriptions` | ⚠️ | Pause / resume / change cycle for recurring subscriptions |
| `usagebillingpricing` | `/usagebillingpricing.php` | ⚠️ | Usage-based pricing table reference |

## 5. Upgrades

| Templatefile | URL | Status | Notes |
|---|---|---|---|
| `upgrade` | `/upgrade.php?type=package&id=X` | ⚠️ | Step 1: pick new plan |
| `upgrade-configure` | `/upgrade.php?type=configoptions&id=X` | ⚠️ | Step 2: configure addons / cycle |
| `upgradesummary` | `/upgrade.php?type=summary` | ⚠️ | Step 3: confirm + checkout |

## 6. Support

| Templatefile | URL | Status | Notes |
|---|---|---|---|
| `supportticketslist` | `/supporttickets.php` | ✅ | Tickets list — **URL says `supporttickets` but WHMCS uses templatefile `supportticketslist`** |
| `supporttickets` | (alias) | ✅ | Aliased dispatcher that forwards to supportticketslist's tpl |
| `viewticket` | `/viewticket.php?tid=X&c=Y` | ✅ | Conversation thread, reply composer, ticket info sidebar |
| `supportticketsubmit` | `/submitticket.php` | ✅ | Multi-step submit; dept picker + form |
| `supportticketsubmit-stepone` | `/submitticket.php` (step 1) | ✅ | Forwarder — same shared tpl |
| `supportticketsubmit-steptwo` | `/submitticket.php` (step 2) | ✅ | Forwarder — same shared tpl |
| `supportticketsubmit-customfields` | (variant) | ⚠️ | Department-specific custom-fields screen |
| `supportticketsubmit-kbsuggestions` | (variant) | ⚠️ | KB-article suggestions interstitial |
| `supportticketsubmit-confirm` | (post-submit) | ⚠️ | Submission confirmation |
| `ticketfeedback` | `/ticketfeedback.php?tid=X` | ⚠️ | Post-resolution rating + comment |

## 7. Knowledgebase

| Templatefile | URL | Status | Notes |
|---|---|---|---|
| `knowledgebase` | `/knowledgebase.php` | ✅ | Hero search + category grid + popular articles |
| `knowledgebasecat` | `/knowledgebase.php?action=displaycat&catid=X` | ✅ | Articles within a category |
| `knowledgebasearticle` | `/knowledgebase.php?action=displayarticle&id=X` | ✅ | Single article + "Was this helpful?" + related |

## 8. Announcements

| Templatefile | URL | Status | Notes |
|---|---|---|---|
| `announcements` | `/announcements.php` | ✅ | List of announcements |
| `viewannouncement` | `/announcements.php?id=X` | ✅ | Single announcement — **URL says `announcements` but templatefile is `viewannouncement`** |

## 9. Account & profile

| Templatefile | URL | Status | Notes |
|---|---|---|---|
| `clientareadetails` | `/clientarea.php?action=details` | ✅ | Account / billing profile form |
| `account-contacts-manage` | `/clientarea.php?action=contacts` | ✅ | Sub-account contacts list (alias `clientareacontacts.tpl` also present) |
| `account-contacts-new` | `/clientarea.php?action=contacts&sub=new` | ⚠️ | Add new contact form |
| `account-user-management` | `/clientarea.php?action=users` | ✅ | Sub-user list (alias `clientareausers.tpl` also present) |
| `account-user-permissions` | `/clientarea.php?action=users&sub=permissions&userid=X` | ⚠️ | Per-user permission matrix |
| `account-paymentmethods` | `/clientarea.php?action=paymentmethods` | ✅ | Saved cards / bank accounts |
| `account-paymentmethods-manage` | `/clientarea.php?action=paymentmethods&sub=manage` | ⚠️ | Add / edit a payment method |
| `account-paymentmethods-billing-contacts` | `/clientarea.php?action=paymentmethods&sub=contacts` | ⚠️ | Billing-contact addresses for stored methods |
| `clientareaemails` | `/clientarea.php?action=emails` | ⚠️ | Sent-to-client email log |
| `viewemail` | `/clientarea.php?action=emails&id=X` | ⚠️ | Single email view |
| `user-profile` | `/account/profile` | ✅ | User-level profile form: name + email + language. Smaller than `clientareadetails` (which is account-level / billing address). |
| `user-password` | `/clientarea.php?action=changepw` | ✅ | Change password (alias `changepassword.tpl`, `changepw.tpl`) |
| `user-security` | `/account/security` | ✅ | Forwarder to `clientareasecurity` — WHMCS 9 split user-level vs account-level security, but the controls are identical (2FA + login alerts + sessions). One design, two dispatchers. |
| `clientareasecurity` | `/clientarea.php?action=security` | ✅ | Account-level 2FA + login alerts + active sessions |
| `user-switch-account` | `/clientarea.php?action=switchaccount` | ✅ | Multi-account switcher — avatar + name + email per account, "Switch to" pill, current row highlighted. Empty state when only one account is on the login. |

## 10. SSL

| Templatefile | URL | Status | Notes |
|---|---|---|---|
| `configuressl-stepone` | `/configuressl.php` | ⚠️ | CSR generation / paste |
| `configuressl-steptwo` | `/configuressl.php?step=2` | ⚠️ | Server software + admin contact |
| `configuressl-complete` | `/configuressl.php?step=3` | ⚠️ | Installation instructions |
| `managessl` | `/clientarea.php?action=ssl` | ⚠️ | Active certificates list |

## 11. Public / informational

| Templatefile | URL | Status | Notes |
|---|---|---|---|
| `contact` | `/contact.php` | ✅ | Public contact form |
| `serverstatus` | `/serverstatus.php` | ⚠️ | Server / service status dashboard |
| `downloads` | `/downloads.php` | ⚠️ | Download categories |
| `downloadscat` | `/downloads.php?action=displaycat&catid=X` | ⚠️ | Files within a category |
| `downloaddenied` | `/downloads.php` (denied) | ⚠️ | Access-denied notice for a specific file |

## 12. Error & utility

| Templatefile | URL | Status | Notes |
|---|---|---|---|
| `access-denied` | (conditional) | ⚠️ | Generic permission denied |
| `banned` | (conditional) | ⚠️ | Account banned notification |
| `3dsecure` | (payment flow) | ⚠️ | 3D Secure iframe wrapper |
| `markdown-guide` | (modal / reference) | ⚠️ | Markdown syntax cheatsheet |

## 13. Out of scope (different theme system)

| Page | Why excluded |
|---|---|
| `cart.php` and the entire order-form funnel | Lives in `templates/orderforms/<style>/` not `templates/mytheme/`. Requires a separate theme directory hierarchy; the apple-style funnel is planned but not part of the client-area scope. |
| Admin area templates | Admin theme is separate from client-area theme. |
| Email templates (`templates/emails/*.tpl`) | WHMCS handles transactional emails through its own template system. |

---

## Coverage summary

- **Full (real content):** 35 pages — every Smarty-renderable WHMCS client-area page that this theme targets
- **Scaffold (skeleton, real content pending):** 31 pages — render structurally and pass the lint, but the WHMCS variable wiring is still placeholder
- **Out of scope:** 2 PDF templates (`invoicepdf`, `quotepdf`) — these are TCPDF renders under `templates/pdf/`, not Smarty; they live in a different theming surface
- **Missing:** 0 — the theme covers every targeted client-area page

Total: **66 client-area pages tracked + 2 PDFs out of scope**, plus ~14 alias / step-variant dispatchers that forward to shared tpls.

## When something doesn't work

Three places to look first:

1. **Empty `.content-area` in view-source** — WHMCS can't find the templatefile. Add `<!-- tpl: {$templatefile} -->` to `header.tpl` (or use the existing `data-tpl="…"` body attribute) to see the actual templatefile name, then either rename your dispatcher to match or add an alias forwarder.
2. **PHP TypeError "Cannot access offset of type string on string"** — you're treating a top-level scalar variable as a nested array (`$service.status` when `$service` is just the product name string). See §10 trap in PAGE-CHECKLIST.
3. **`AprApr/SatSat/2026202620262026`-style mangled dates** — you used `|date_format:"%X..."`; on PHP 8.1+ this breaks for Carbon-typed timestamps. Use `$carbon->createFromTimestamp($timestamp)->format('F j, Y')` instead.

For deeper debug, run `bash scripts/check-pages.sh all` — it greps for known anti-patterns and curls each live URL.
