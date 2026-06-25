# B10 — Services & Upgrade pages

## Summary
- **Total strings flagged:** 121
- **WHMCS:** 88
- **CUSTOM:** 33
- **SKIP-worth-noting:** brand/proper nouns in `clientareaproductdetails` Quick-Shortcuts (cPanel feature names: Email Accounts, Forwarders, Autoresponders, File Manager, Backup, Subdomains, Addon Domains, Cron Jobs, MySQL Databases, phpMyAdmin, Awstats) and demo placeholder copy under `?preview=1` (plan names, GB/price strings) — not reported as tokenizable runtime copy; see notes.
- **js-string:** 0 (all `<script>` blocks here are pure behavior/DOM logic — no user-facing string literals built in JS).

Cross-cutting notes applied:
- All status/order/upgrade/metrics `$LANG.*` keys were checked against `nexus/*.tpl`, `lagom2.3/lagom2-theme/*.tpl`, `standard_cart/standard_cart/*.tpl` and our own `hadrian*` usage. Real WHMCS keys cited file:line.
- **`|default` traps flagged** (real key, but our `|default` literal differs from the genuine WHMCS string) — see `upgradecurrentconfig`, `metrics.pricing`, `metrics.includedInBase`, `newslettersubscribed`, `newsletterremoved`.
- `hadrian/templates/hadrian/core/lang/english.php` ($rslang legacy) holds only footer/error/license/admin groups — **none** of the strings below have a legacy `$rslang` key, so CUSTOM keys are minted fresh in group `services`.

---

### hadrian/templates/hadrian/core/pages/clientareaproducts/default/default.tpl
| Line | Type | Current text | Class | Proposed reference | Evidence / Notes | Conf |
|------|------|--------------|-------|--------------------|------------------|------|
| 70 | text | Services | WHMCS | {$LANG.productsservices} | real key — strip default; `clientareaproducts.tpl` self uses it (homepage default.tpl:50 same key). Genuine WHMCS = "Products & Services" | high |
| 71 | text | Manage your active services, upgrades, and add-ons. | CUSTOM | {$hadrianLang.services.productsServicesSub} | invented LANG key `productsservicessub` → rebadge; subtitle copy | high |
| 74 | text | Order a service | CUSTOM | {$hadrianLang.services.orderAService} | invented LANG key `orderaservice` (only ever with `\|default`) → rebadge | high |
| 90 | text | service | WHMCS | {$LANG.serviceLower} → see note | invented `serviceLower`/`servicesLower`; no clean WHMCS singular/plural-lower key. Treat as CUSTOM `{$hadrianLang.services.serviceLower}` = "service" | med |
| 90 | text | services | CUSTOM | {$hadrianLang.services.servicesLower} | invented `servicesLower` → rebadge ("services") | med |
| 90 | text | on this account | CUSTOM | {$hadrianLang.services.onThisAccount} | invented `onthisaccount` → rebadge | high |
| 92 | text | View all | WHMCS | {$LANG.viewall} | real key — strip default; used bare across hadrian (clientareahome default.tpl:356) | high |
| 97 | text | All | WHMCS | {$LANG.all} | real key — strip default (serverstatus default.tpl:130 etc.) | high |
| 98 | text | Active | CUSTOM | {$hadrianLang.services.statusActive} | invented `statusactive`; WHMCS status key is `clientareaactive` (different name). AMBIGUITY — see note | med |
| 99 | text | Pending | CUSTOM | {$hadrianLang.services.statusPending} | invented `statuspending`; WHMCS = `clientareapending`. AMBIGUITY | med |
| 100 | text | Suspended | CUSTOM | {$hadrianLang.services.statusSuspended} | invented `statussuspended`; WHMCS = `clientareasuspended`. AMBIGUITY | med |
| 101 | text | Terminated | CUSTOM | {$hadrianLang.services.statusTerminated} | invented `statusterminated`; WHMCS = `clientareaterminated`. AMBIGUITY | med |
| 102 | text | Cancelled | CUSTOM | {$hadrianLang.services.statusCancelled} | invented `statuscancelled`; WHMCS = `clientareacancelled`. AMBIGUITY | med |
| 104 | text | Fraud | CUSTOM | {$hadrianLang.services.statusFraud} | invented `statusfraud`; WHMCS = `clientareafraud`. AMBIGUITY | med |
| 106 | placeholder | Search… | WHMCS | {$LANG.search} | real key — strip default; used bare in cart (domainregister) + with default across hadrian list pages | high |
| 106 | aria-label | Search | WHMCS | {$LANG.search} | real key — strip default | high |
| 115 | text | Name | CUSTOM | {$hadrianLang.services.colName} | hardcoded `<button>` sort label (no LANG wrapper); WHMCS `$LANG.name` is an array on this install (prints "Array") → mint CUSTOM | high |
| 116 | text | Pricing | WHMCS | {$LANG.clientareaaddonpricing} | hardcoded; nexus clientareaproducts.tpl:27 uses `{lang key='clientareaaddonpricing'}` for this column | med |
| 117 | text | Next due | WHMCS | {$LANG.clientareahostingnextduedate} | hardcoded; nexus clientareaproducts.tpl:28 uses this key. Genuine = "Next Due Date" | high |
| 118 | text | Status | WHMCS | {$LANG.clientareastatus} | hardcoded; nexus clientareaproducts.tpl:29 uses `{lang key='clientareastatus'}` | high |
| 135 | text | Product / Service | WHMCS | {$LANG.orderproduct} | hardcoded `<th>` button; nexus clientareaproducts.tpl:25 uses `{lang key='orderproduct'}` | med |
| 136 | text | Pricing | WHMCS | {$LANG.clientareaaddonpricing} | dedupe with line 116 | med |
| 137 | text | Next due | WHMCS | {$LANG.clientareahostingnextduedate} | dedupe with line 117 | high |
| 138 | text | Status | WHMCS | {$LANG.clientareastatus} | dedupe with line 118 | high |
| 139 | aria-label | Actions | WHMCS | {$LANG.actions} | real key — used bare in lagom managessl.tpl:17; with default across hadrian | high |
| 149 | text | Service | CUSTOM | {$hadrianLang.services.serviceFallback} | `$product.groupname\|default:'Service'` — fallback label for missing group | med |
| 169 | aria-label | Actions | WHMCS | {$LANG.actions} | dedupe line 139 | high |
| 175 | text | Manage Product | WHMCS | {$LANG.manageproduct} | real key — strip default; used with default across hadrian (managessl, clientareahome). Genuine ≈ "Manage Product" | high |
| 185 | text | Upgrade / Downgrade | WHMCS | {$LANG.upgrade} | hardcoded (no wrapper); `$LANG.upgrade` real (viewcart.tpl:374 bare). Genuine = "Upgrade" only — see note | med |
| 190 | text | View Addons | WHMCS | {$LANG.viewavailableaddons} | real key — strip default (note: same key default varies: "View Addons" vs "View Available Addons" L263). Genuine ≈ "View Available Addons" | high |
| 194 | text | Request Cancellation | WHMCS | {$LANG.cancellationrequest} | real key — strip default; WHMCS cancellation request label | med |
| 210 | text | Show | WHMCS | {$LANG.show} | real key — strip default; used with default across hadrian list pages (clientareainvoices etc.) | high |
| 211 | aria-label | Rows per page | CUSTOM | {$hadrianLang.services.rowsPerPage} | hardcoded aria-label, no WHMCS key | high |
| 216 | text | entries | WHMCS | {$LANG.entries} | real key — strip default (DataTables label; hadrian list pages reuse) | high |
| 219 | text | Showing | WHMCS | {$LANG.showing} | real key — strip default | high |
| 219 | text | of | WHMCS | {$LANG.of} | real key — strip default | high |
| 221 | aria-label | Previous page | CUSTOM | {$hadrianLang.common.prevPage} | hardcoded pager aria-label; reuse common | high |
| 223 | aria-label | Next page | CUSTOM | {$hadrianLang.common.nextPage} | hardcoded pager aria-label; reuse common | high |
| 251 | text | Services | WHMCS | {$LANG.services} | real key — strip default; subnav heading. (`$LANG.services` is scalar here, distinct from `productsservices`) | high |
| 254 | text | My Services | WHMCS | {$LANG.myservices} | real key — strip default | high |
| 259 | text | Order New Services | WHMCS | {$LANG.ordernewservices} | real key — strip default; hadrian_cart products.tpl:119 uses it (default "Order new services") | high |
| 263 | text | View Available Addons | WHMCS | {$LANG.viewavailableaddons} | dedupe line 190 | high |
| 267 | text | Upgrade / Downgrade | WHMCS | {$LANG.upgrade} | hardcoded subnav text (no wrapper); dedupe note line 185 | med |
| 238 | text | No services yet | CUSTOM | {$hadrianLang.services.emptyTitle} | invented `noproductsactive` → rebadge; empty-state title (shared w/ clientareahome) | high |
| 239 | text | You don't have any products or services on this account. Browse our catalogue… | CUSTOM | {$hadrianLang.services.emptySub} | invented `noproductssub` → rebadge (clientareahome uses a slightly different default for same key — consolidate) | high |
| 240 | text | Place an order | CUSTOM | {$hadrianLang.services.placeAnOrder} | invented `placeanorder` → rebadge | high |

_Note (status pills, L98–104):_ the six `statusXxx` keys are invented (`|default` only). WHMCS ships real status strings under `clientareaactive`/`clientareapending`/`clientareasuspended`/`clientareaterminated`/`clientareacancelled`/`clientareafraud`. Recommend switching to those WHMCS keys rather than CUSTOM — flagged as primary ambiguity for the user.

_Note (table headers L115–118 vs L135–138):_ two header rows render the same columns (`.svc-table-head-row` floating titles + real `<thead>`); both are hardcoded plain text. Mapped to the same WHMCS column keys nexus uses. "Name" (L115) differs from "Product / Service" (L135) — first is the floating-title variant.

---

### hadrian/templates/hadrian/core/pages/clientareaproductdetails/default/default.tpl
| Line | Type | Current text | Class | Proposed reference | Evidence / Notes | Conf |
|------|------|--------------|-------|--------------------|------------------|------|
| 44 | text | Service | CUSTOM | {$hadrianLang.services.serviceFallback} | `$product\|default:'Service'` page title fallback; dedupe w/ products L149 | med |
| 54 | text | Cancellation has been requested for this service. | WHMCS | {$LANG.cancellationrequestedexplanation} | real key — strip default; nexus clientareaproductdetails.tpl:10 + lagom:23 use it bare | high |
| 61 | text | This service has an unpaid invoice. | CUSTOM | {$hadrianLang.services.unpaidInvoice} | `$unpaidInvoiceMessage\|default:'…'` — fallback for a WHMCS var, not a LANG key; mint CUSTOM for the literal | med |
| 62 | text | Pay invoice | WHMCS | {$LANG.payInvoice} | real key — strip default; nexus clientareaproductdetails.tpl:17 `{lang key='payInvoice'}` | high |
| 117 | text | Actions | WHMCS | {$LANG.actions} | real key — strip default | high |
| 117 | text | Overview | WHMCS | {$LANG.overview} | real key — strip default; nexus clientareadomaindetails.tpl:24 `{lang key='overview'}` | high |
| 157 | text | Overview | WHMCS | {$LANG.overview} | dedupe line 117 | high |
| 160 | text | Information | WHMCS | {$LANG.information} | real key — strip default; WHMCS sidebar "Information" item | med |
| 165 | text | Resource Usage | WHMCS | {$LANG.usagestats} | real key — strip default; WHMCS resource-usage tab label = "Resource Usage" | med |
| 171 | text | Addons | WHMCS | {$LANG.clientareahostingaddons} | real key — strip default; nexus:447 + lagom:500 use it bare | high |
| 176 | text | Billing | WHMCS | {$LANG.billingOverview} | real key — strip default; lagom cpanel/overview.tpl:467 `{lang key='billingOverview'}`. Genuine ≈ "Billing Overview" — minor shift | high |
| 183 | text | Actions | WHMCS | {$LANG.actions} | dedupe line 117 | high |
| 187 | text | Log in to cPanel | CUSTOM | {$hadrianLang.services.loginCpanel} | hardcoded (no wrapper); cPanel module's own label not loaded on theme page — mint CUSTOM ("cPanel" brand kept) | high |
| 191 | text | Log in to Webmail | CUSTOM | {$hadrianLang.services.loginWebmail} | hardcoded; mint CUSTOM | high |
| 197 | text | Upgrade / Downgrade | WHMCS | {$LANG.upgrade} | real key — strip default; genuine = "Upgrade". See note re: combined "/ Downgrade" wording | med |
| 203 | text | Change Password | WHMCS | {$LANG.serverchangepassword} | real key — strip default; nexus:487 + lagom:553 use it bare | high |
| 209 | text | Request Cancellation | WHMCS | {$LANG.requestcancellation} | real key — strip default; distinct from `cancellationrequest` (products page) but same English. AMBIGUITY note | med |
| 220 | text | Service Information | WHMCS | {$LANG.productdetails} | real key — strip default; WHMCS "Product Details" / service-info heading. Wording shifts slightly | med |
| 222 | text | Domain | WHMCS | {$LANG.domain} | real key — strip default; nexus uses `orderdomain`/`clientareahostingdomain` for this — see note | med |
| 225 | text | Server | WHMCS | {$LANG.servername} | real key — strip default; nexus clientareaproductdetails.tpl:233 `{lang key='servername'}` | high |
| 228 | text | Server username | WHMCS | {$LANG.serverusername} | real key — strip default; nexus:223 bare | high |
| 231 | text | IP address | WHMCS | {$LANG.primaryIP} | real key — strip default; nexus:182 + lagom:309 `{lang key='primaryIP'}` | high |
| 233 | text | IP address | WHMCS | {$LANG.primaryIP} | dedupe line 231 | high |
| 236 | text | Assigned IPs | WHMCS | {$LANG.assignedIPs} | real key — strip default; nexus:192 + lagom:315 bare | high |
| 239 | text | Nameservers | WHMCS | {$LANG.domainnameservers} | real key — strip default; nexus:202/250 + lagom:327 bare | high |
| 241 | text | Nameservers | WHMCS | {$LANG.domainnameservers} | dedupe line 239 | high |
| 251 | text | Resource Usage | WHMCS | {$LANG.usagestats} | dedupe line 165 | med |
| 255 | text | Disk space | WHMCS | {$LANG.diskSpace} | real key — strip default; nexus clientareaproductdetails.tpl:392 `{lang key='diskSpace'}` | high |
| 259 | text | Bandwidth | WHMCS | {$LANG.bandwidth} | real key — strip default; nexus:397 bare | high |
| 262 | text | Last updated | WHMCS | {$LANG.clientarealastupdated} | real key — strip default; nexus:404 + lagom:96 bare | high |
| 264 | text | Usage statistics are not available for this service yet. | CUSTOM | {$hadrianLang.services.usageNotAvailable} | invented `usagenotavailable` → rebadge; no WHMCS empty-usage string | high |
| 281 | text | Manage | WHMCS | {$LANG.manage} | real key — strip default; nexus:142 + lagom active-products-services-item.tpl bare | high |
| 289 | text | Log in to cPanel | CUSTOM | {$hadrianLang.services.loginCpanel} | dedupe line 187 | high |
| 293 | text | Log in to Webmail | CUSTOM | {$hadrianLang.services.loginWebmail} | dedupe line 191 | high |
| 303 | text | This service is still being set up — control-panel access will be available once it goes active. | CUSTOM | {$hadrianLang.services.cpPendingNotice} | invented inline status notice (no LANG); mint CUSTOM | high |
| 303 | text | This service has been %s; control-panel access is no longer available. | CUSTOM | {$hadrianLang.services.cpUnavailableTerminated} | inline; `%s` = status; mint CUSTOM | high |
| 303 | text | Control-panel access (cPanel / Webmail) is unavailable while this service is %s. | CUSTOM | {$hadrianLang.services.cpUnavailableStatus} | inline; `%s` = status; mint CUSTOM | high |
| 303 | text | Pay the overdue invoice to reactivate it. | CUSTOM | {$hadrianLang.services.cpPayOverdue} | inline append; mint CUSTOM | high |
| 313 | text | Upgrade / Downgrade | WHMCS | {$LANG.upgrade} | dedupe line 197 | med |
| 313 | text | Change your hosting plan | CUSTOM | {$hadrianLang.services.upgradeSublabel} | invented `upgradeavailable` → rebadge; sublabel copy | high |
| 323 | text | Renew now | WHMCS | {$LANG.renewService.titleSingular} | real key — strip default; nexus clientareaproductdetails.tpl:66 `{lang key='renewService.titleSingular'}` | high |
| 323 | text | Extend your service term | CUSTOM | {$hadrianLang.services.renewSublabel} | hardcoded sublabel (no LANG); mint CUSTOM | high |
| 334 | text | Change Password | WHMCS | {$LANG.serverchangepassword} | dedupe line 203 | high |
| 334 | text | Set a new control-panel password | CUSTOM | {$hadrianLang.services.changePwSublabel} | hardcoded sublabel; mint CUSTOM | high |
| 346 | text | New password | WHMCS | {$LANG.newpassword} | real key — strip default; nexus:502 + lagom user-password.tpl:16 bare | high |
| 348 | text | Confirm new password | WHMCS | {$LANG.confirmnewpassword} | real key — strip default; nexus:514 + lagom bare | high |
| 350 | text | Save changes | WHMCS | {$LANG.clientareasavechanges} | real key — strip default; nexus:523 + many lagom bare | high |
| 361 | text | Request Cancellation | WHMCS | {$LANG.requestcancellation} | dedupe line 209 | med |
| 361 | text | Schedule this service to be cancelled | CUSTOM | {$hadrianLang.services.cancelSublabel} | hardcoded sublabel; mint CUSTOM | high |
| 377 | text | Quick Shortcuts | WHMCS | {$LANG.quickShortcuts} | real key — strip default; lagom cpanel/overview.tpl:227 + plesk:227 `{lang key='quickShortcuts'}` | high |
| 383 | text | Email Accounts | SKIP→CUSTOM | {$hadrianLang.services.scEmailAccounts} | cPanel feature label; module `$LANG.cPanel.*` not loaded on theme page (per file comment) → mint CUSTOM. Brand-ish but translatable | med |
| 387 | text | Forwarders | CUSTOM | {$hadrianLang.services.scForwarders} | cPanel feature label; mint CUSTOM | med |
| 391 | text | Autoresponders | CUSTOM | {$hadrianLang.services.scAutoresponders} | cPanel feature label; mint CUSTOM | med |
| 395 | text | File Manager | CUSTOM | {$hadrianLang.services.scFileManager} | cPanel feature label; mint CUSTOM | med |
| 399 | text | Backup | CUSTOM | {$hadrianLang.services.scBackup} | cPanel feature label; mint CUSTOM | med |
| 403 | text | Subdomains | CUSTOM | {$hadrianLang.services.scSubdomains} | cPanel feature label; mint CUSTOM | med |
| 407 | text | Addon Domains | CUSTOM | {$hadrianLang.services.scAddonDomains} | cPanel feature label; mint CUSTOM | med |
| 411 | text | Cron Jobs | CUSTOM | {$hadrianLang.services.scCronJobs} | cPanel feature label; mint CUSTOM | med |
| 415 | text | MySQL Databases | CUSTOM | {$hadrianLang.services.scMysql} | cPanel feature label ("MySQL" brand kept); mint CUSTOM | med |
| 419 | text | phpMyAdmin | SKIP | — | brand/proper noun — do not translate | high |
| 423 | text | Awstats | SKIP | — | brand/proper noun — do not translate | high |
| 429 | text | Shortcuts will be available once this service is active. | CUSTOM | {$hadrianLang.services.scPendingNotice} | inline status notice; mint CUSTOM | high |
| 429 | text | cPanel shortcuts are unavailable while this service is %s. | CUSTOM | {$hadrianLang.services.scUnavailableStatus} | inline; `%s` = status; mint CUSTOM | high |
| 446 | text | Addons | WHMCS | {$LANG.clientareahostingaddons} | dedupe line 171 | high |
| 451 | text | Next due | WHMCS | {$LANG.clientareahostingnextduedate} | real key — strip default; nexus:470 `{lang key='clientareahostingnextduedate'}: {$addon.nextduedate}` | high |
| 463 | text | Billing Overview | WHMCS | {$LANG.billingOverview} | real key — strip default; dedupe key w/ line 176 (different default "Billing" vs "Billing Overview" — consolidate) | high |
| 465 | text | Registration date | WHMCS | {$LANG.clientareahostingregdate} | real key — strip default; nexus:88 `{lang key='clientareahostingregdate'}`. (`registrationdate` w/ default is NOT the canonical key — `clientareahostingregdate` is) — see note | med |
| 468 | text | Next due date | WHMCS | {$LANG.clientareahostingnextduedate} | real key; our default uses `invoicedatedue` key but renders next-due — key mismatch. Use `clientareahostingnextduedate` (canonical). TRAP — see note | med |
| 471 | text | Billing | WHMCS | {$LANG.recurringamount} | real key — strip default; nexus:97 bare. Genuine = "Recurring Amount" — wording shift (our "Billing") | high |
| 474 | text | Payment method | WHMCS | {$LANG.paymentmethod} | real key — strip default; lagom clientareadetails.tpl:140 bare | high |
| 477 | text | First payment | WHMCS | {$LANG.firstpaymentamount} | real key — strip default; nexus:92 + lagom:113 bare. Genuine ≈ "First Payment Amount" | high |

_Note (L222 "Domain"):_ our key is `domain`. nexus uses `clientareahostingdomain` (hosting) / `orderdomain` for the domain row. `$LANG.domain` may or may not exist; if it prints "Array"/empty, switch to `clientareahostingdomain`. Flagged.
_Note (L465/L468 reg-date / next-due-date):_ `registrationdate` and `invoicedatedue` are the keys used here, but the genuine WHMCS keys for these exact rows are `clientareahostingregdate` and `clientareahostingnextduedate` (proven in nexus). Recommend switching — both are real-key-with-wrong-name traps.
_Note (Upgrade "/ Downgrade"):_ `$LANG.upgrade` real value is just "Upgrade". Our copy appends "/ Downgrade". If exact parity wanted, use `{$LANG.upgrade}` and accept "Upgrade", or keep CUSTOM. Left as WHMCS (prefer-real policy).

---

### hadrian/templates/hadrian/core/pages/upgrade/default/default.tpl
| Line | Type | Current text | Class | Proposed reference | Evidence / Notes | Conf |
|------|------|--------------|-------|--------------------|------------------|------|
| 61 | text | Services | WHMCS | {$LANG.clientareaservices} | real key — strip default; eyebrow. (clientareacancelrequest default.tpl:46 same key) | high |
| 62 | text | Upgrade or downgrade | WHMCS | {$LANG.upgradedowngrade} | real key — strip default; WHMCS upgrade page title key. Genuine ≈ "Upgrade/Downgrade" | med |
| 63 | text | Change your plan size or feature tier. Changes are prorated. | CUSTOM | {$hadrianLang.services.upgradeIntro} | invented `upgradeintro` → rebadge; subtitle copy | high |
| 72 | text | Current plan | WHMCS | {$LANG.upgradecurrentconfig} | real key — strip default; nexus upgrade.tpl:45 bare. **TRAP**: genuine ≈ "Current Configuration", our default "Current plan" | high |
| 89 | text | (error message passthrough) | — | — | `$errormessage\|strip_tags` — WHMCS var, not a literal; SKIP | high |
| 97 | text | Current | WHMCS | {$LANG.upgradecurrentconfig} | dedupe line 72; here default literal is "Current" (3rd different default for same key) — TRAP | high |
| 101 | value | Enabled | CUSTOM | {$hadrianLang.services.enabledState} | `$LANG.yes\|default:'Enabled'` — **TRAP**: `$LANG.yes` real value is "Yes", not "Enabled". Mint CUSTOM for "Enabled" OR drop to `{$LANG.yes}` | high |
| 101 | value | Disabled | CUSTOM | {$hadrianLang.services.disabledState} | `$LANG.no\|default:'Disabled'` — same trap; real `$LANG.no` = "No" | high |
| 107 | text | New | WHMCS | {$LANG.upgradenewconfig} | real key — strip default; nexus upgrade.tpl:47/111 bare. Genuine ≈ "New Configuration" | high |
| 111 | option | (option label) | — | — | `$opt.nameonly\|default:$opt.name` — WHMCS data; SKIP | high |
| 115 | text | Enable this option | WHMCS | {$LANG.enable} | real key — strip default; standard_cart configureproduct.tpl:184 bare `{$LANG.enable}`. Genuine = "Enable" — wording shift | med |
| 125 | text | Continue | WHMCS | {$LANG.ordercontinuebutton} | real key — strip default; nexus configuressl-steptwo.tpl:61 bare. (`continue` also real — both work) | high |
| 126 | text | Cancel | WHMCS | {$LANG.cancel} | real key — strip default; lagom viewticket.tpl:66 bare | high |
| 145 | text | Current | WHMCS | {$LANG.upgradecurrentconfig} | dedupe line 72/97 (badge); TRAP note | high |
| 151 | text | Free | WHMCS | {$LANG.orderfree} | real key — strip default; standard_cart addons.tpl:56 + lagom ordersummary.tpl bare | high |
| 154 | text | one time | WHMCS | {$LANG.orderpaymenttermonetime} | real key — strip default; nexus upgrade.tpl:70 bare | high |
| 161 | text | mo | CUSTOM | {$hadrianLang.services.cycleMonthlyShort} | `$LANG.monthly\|default:'mo'` — TRAP: `$LANG.monthly` real value = "Monthly", our abbrev "mo". Mint CUSTOM for short form | high |
| 162 | text | qtr | CUSTOM | {$hadrianLang.services.cycleQuarterlyShort} | `$LANG.quarterly\|default:'qtr'` — TRAP; mint CUSTOM | high |
| 163 | text | 6 mo | CUSTOM | {$hadrianLang.services.cycleSemiannuallyShort} | `$LANG.semiannually\|default:'6 mo'` — TRAP; mint CUSTOM | high |
| 164 | text | yr | CUSTOM | {$hadrianLang.services.cycleAnnuallyShort} | `$LANG.annually\|default:'yr'` — TRAP; mint CUSTOM | high |
| 165 | text | 2 yr | CUSTOM | {$hadrianLang.services.cycleBienniallyShort} | `$LANG.biennially\|default:'2 yr'` — TRAP; mint CUSTOM | high |
| 166 | text | 3 yr | CUSTOM | {$hadrianLang.services.cycleTrienniallyShort} | `$LANG.triennially\|default:'3 yr'` — TRAP; mint CUSTOM | high |
| 176 | text | Current plan | WHMCS | {$LANG.upgradecurrentplan} | real key — strip default; WHMCS "Current Plan" key (distinct from `upgradecurrentconfig`) | med |
| 178 | text | Choose this plan | WHMCS | {$LANG.upgradedowngradechooseproduct} | real key — strip default; nexus upgrade.tpl:84 bare | high |
| 189 | text | Back to my service | CUSTOM | {$hadrianLang.services.backToMyService} | hardcoded (no LANG); WHMCS `clientareabacklink` ≈ "Go Back" differs. Mint CUSTOM | med |
| 189 | text | Back to services | CUSTOM | {$hadrianLang.services.backToServices} | hardcoded; mint CUSTOM | med |
| 201 | text | Services | WHMCS | {$LANG.services} | real key — strip default; aside heading (scalar `services`) | high |
| 204 | text | My Services | WHMCS | {$LANG.myservices} | dedupe (products L254) | high |
| 208 | text | Order New Services | WHMCS | {$LANG.ordernewservices} | dedupe (products L259) | high |
| 212 | text | View Available Addons | WHMCS | {$LANG.viewavailableaddons} | dedupe (products L263) | high |
| 216 | text | Upgrade / Downgrade | WHMCS | {$LANG.upgrade} | hardcoded subnav text; dedupe note | med |
| 233 | text | Upgrade not available | CUSTOM | {$hadrianLang.services.upgradeNotAvailTitle} | invented `upgradenotavailabletitle` → rebadge; empty-state title | high |
| 234 | text | You have an overdue invoice. Please settle it before upgrading. | WHMCS | {$LANG.upgradeerroroverdueinvoice} | real key — strip default; nexus upgrade.tpl:4 `{lang key='upgradeerroroverdueinvoice'}` | high |
| 235 | text | My invoices | WHMCS | {$LANG.invoices} | real key — strip default; viewquote default.tpl:263 uses `invoices`. Genuine ≈ "Invoices" | high |
| 237 | text | Upgrade not available | CUSTOM | {$hadrianLang.services.upgradeNotAvailTitle} | dedupe line 233 | high |
| 238 | text | There is already a pending upgrade invoice for this service. | WHMCS | {$LANG.upgradeexistingupgradeinvoice} | real key — strip default; nexus upgrade.tpl:6 bare | high |
| 239 | text | My invoices | WHMCS | {$LANG.invoices} | dedupe line 235 | high |
| 241 | text | No upgrade available | CUSTOM | {$hadrianLang.services.noUpgradeTitle} | `upgradenotavailabletitle` reused with a 2nd default "No upgrade available" — distinct copy → mint CUSTOM (or dedupe w/ 233) | med |
| 242 | text | This service doesn't have higher tiers, or upgrades are paused. | WHMCS | {$LANG.upgradeNotPossible} | real key — strip default; nexus upgrade.tpl:8 `{lang key='upgradeNotPossible'}`. Wording shift | high |
| 243 | text | All services | WHMCS | {$LANG.clientareanavservices} | real key — strip default; hostnodes-apple clientareaproducts.tpl:5 bare. (default varies "All services"/"My services") | high |

_Note (cycle abbreviations L161–166):_ all six pipe a real WHMCS billing-cycle key (`monthly`…`triennially`) but default to a short form ("mo","yr"). The real values are full words ("Monthly","Yearly"…). The short abbrevs are deliberate UI copy → CUSTOM. If full words are acceptable, switch to the bare WHMCS keys instead. Flagged.
_Note (L101 Enabled/Disabled):_ same class of trap — `$LANG.yes`/`$LANG.no` are "Yes"/"No"; using them for Enabled/Disabled is misleading. CUSTOM proposed.

---

### hadrian/templates/hadrian/core/pages/upgrade-configure/default/default.tpl
| Line | Type | Current text | Class | Proposed reference | Evidence / Notes | Conf |
|------|------|--------------|-------|--------------------|------------------|------|
| 34 | text | Services | WHMCS | {$LANG.clientareaservices} | real key — strip default; dedupe (upgrade L61) | high |
| 35 | text | Configure upgrade | WHMCS | {$LANG.upgradeconfigure} | real key — strip default; WHMCS upgrade-configure title. (lagom/nexus upgrade-configure render via `manage`) — med conf | med |
| 36 | text | Pick your new plan and review the prorated amount before confirming. | CUSTOM | {$hadrianLang.services.upgradeConfigureIntro} | invented `upgradeconfigureintro` → rebadge; subtitle | high |
| 43 | text | Choose your new plan | WHMCS | {$LANG.upgradenewconfig} | real key — strip default; dedupe (upgrade L107). Genuine ≈ "New Configuration" — wording shift | med |
| 50 | text | Pro | SKIP | — | demo plan name (`?preview=1` only) — product/proper noun; not runtime copy | high |
| 50 | text | Current | WHMCS | {$LANG.upgradecurrentconfig} | dedupe (upgrade L72); demo badge but real key | high |
| 50 | text | 100 GB SSD, 2 TB bandwidth | SKIP | — | demo feature copy (`?preview=1`); product spec, not translatable UI | high |
| 53,56,59 | text | Business / Enterprise + feature lines | SKIP | — | demo plan data under `?preview=1` — SKIP | high |
| 81 | text | Upgrade summary | WHMCS | {$LANG.ordersummary} | real key — strip default; standard_cart configureproduct.tpl:336 bare. Genuine = "Order Summary" — wording shift | high |
| 83 | text | Current plan | WHMCS | {$LANG.upgradecurrentconfig} | dedupe (upgrade L72); TRAP note | high |
| 83 | text | Pro ($20.33/mo) | SKIP | — | demo value (`?preview=1`) — SKIP | high |
| 84 | text | New plan | WHMCS | {$LANG.upgradenewconfig} | dedupe line 43 | high |
| 84 | text | Business ($41.58/mo) | SKIP | — | demo value — SKIP | high |
| 85 | text | Prorated credit | CUSTOM | {$hadrianLang.services.proratedCredit} | invented `proratedcredit` → rebadge; no WHMCS key for this line | high |
| 86 | text | Amount due today | WHMCS | {$LANG.ordertotalduetoday} | real key — strip default; standard_cart viewcart.tpl:593 bare. Genuine ≈ "Total Due Today" | high |
| 92 | text | Continue to confirm | WHMCS | {$LANG.ordercontinuebutton} | real key — strip default; dedupe (upgrade L125). default "Continue to confirm" shifts | med |
| 93 | text | Cancel | WHMCS | {$LANG.cancel} | dedupe (upgrade L126) | high |
| 106 | text | Start an upgrade | CUSTOM | {$hadrianLang.services.upgradePickFirstTitle} | invented `upgradepickfirst` → rebadge; empty-state title | high |
| 107 | text | Choose a service and a target plan to configure your upgrade. | CUSTOM | {$hadrianLang.services.upgradePickFirstSub} | invented `upgradepickfirstsub` → rebadge | high |
| 108 | text | My services | WHMCS | {$LANG.clientareanavservices} | dedupe (upgrade L243) | high |

---

### hadrian/templates/hadrian/core/pages/upgradesummary/default/default.tpl
| Line | Type | Current text | Class | Proposed reference | Evidence / Notes | Conf |
|------|------|--------------|-------|--------------------|------------------|------|
| 47 | text | Services | WHMCS | {$LANG.clientareaservices} | real key — strip default; dedupe (upgrade L61) | high |
| 48 | text | Review your upgrade | WHMCS | {$LANG.ordersummary} | real key — strip default; **TRAP**: `ordersummary` genuine = "Order Summary"; here default is "Review your upgrade". Reused 3× in this file with 2 different defaults (L48/L138) | high |
| 49 | text | Confirm the changes and amount due before checkout. | CUSTOM | {$hadrianLang.services.upgradeSummaryIntro} | invented `upgradesummaryintro` → rebadge; subtitle | high |
| 59 | text | Changes | WHMCS | {$LANG.orderdesc} | real key — strip default; nexus upgradesummary.tpl:19 `{lang key='orderdesc'}`. Genuine ≈ "Description" — wording shift | med |
| 72 | text | The price reflects the remaining time until renewal | WHMCS | {$LANG.upgradeproductlogic} | real key — strip default; nexus upgradesummary.tpl:67 bare | high |
| 72 | text | days | WHMCS | {$LANG.days} | real key — strip default; nexus upgradesummary.tpl:67 `{lang key='days'}` | high |
| 80 | text | Promotion code | WHMCS | {$LANG.orderpromotioncode} | real key — strip default; lagom/standard_cart use bare | high |
| 91 | placeholder | Promotion code | WHMCS | {$LANG.orderpromotioncode} | dedupe line 80; nexus upgradesummary.tpl:86 placeholder uses it | high |
| 93 | text | Remove | WHMCS | {$LANG.orderdontusepromo} | real key — strip default; nexus upgradesummary.tpl:91 bare | high |
| 95 | text | Apply | WHMCS | {$LANG.orderpromovalidatebutton} | real key — strip default; nexus:97 + lagom promo-code.tpl bare | high |
| 103 | text | Payment method | WHMCS | {$LANG.orderpaymentmethod} | real key — strip default; nexus upgradesummary.tpl:120 + lagom form-payment-gateway.tpl:6 bare | high |
| 117 | text | Payment method | WHMCS | {$LANG.orderpaymentmethod} | dedupe line 103 (label) | high |
| 119 | option | Default | WHMCS | {$LANG.paymentmethoddefault} | real key — strip default; nexus upgradesummary.tpl:124 + lagom clientareadetails.tpl:142 bare | high |
| 127 | text | Confirm & checkout | WHMCS | {$LANG.orderForm.checkout} | real key — strip default; WHMCS orderForm.checkout. Genuine ≈ "Checkout" — wording shift | med |
| 128 | text | Cancel | WHMCS | {$LANG.cancel} | dedupe (upgrade L126) | high |
| 138 | text | Order summary | WHMCS | {$LANG.ordersummary} | dedupe line 48 (here default "Order summary" = genuine). Consolidate the 2 defaults | high |
| 140 | text | Subtotal | WHMCS | {$LANG.ordersubtotal} | real key — strip default; standard_cart viewcart.tpl:542 + lagom bare | high |
| 143 | text | Promo | CUSTOM | {$hadrianLang.services.promoFallback} | `$promodesc\|default:'Promo'` — fallback for a WHMCS var; mint CUSTOM for the literal | med |
| 144 | text | Due today | WHMCS | {$LANG.ordertotalduetoday} | real key — strip default; dedupe (upgrade-configure L86). default "Due today" shift | high |
| 159 | text | Nothing to confirm | CUSTOM | {$hadrianLang.services.upgradeNoSummaryTitle} | invented `upgradenosummary` → rebadge; empty-state title | high |
| 160 | text | Start an upgrade from one of your services to see the summary here. | CUSTOM | {$hadrianLang.services.upgradeNoSummarySub} | invented `upgradenosummarysub` → rebadge | high |
| 161 | text | My services | WHMCS | {$LANG.clientareanavservices} | dedupe (upgrade L243) | high |

_Note (`ordersummary` reuse):_ L48 page-title default "Review your upgrade" and L138 aside default "Order summary" use the SAME key. The genuine WHMCS string is "Order Summary". Recommend stripping both defaults and accepting "Order Summary" in both spots, or keep the page-title as CUSTOM copy. Flagged.

---

### hadrian/templates/hadrian/core/pages/subscription-manage/default/default.tpl
| Line | Type | Current text | Class | Proposed reference | Evidence / Notes | Conf |
|------|------|--------------|-------|--------------------|------------------|------|
| 36 | text | Email preferences | CUSTOM | {$hadrianLang.services.emailSubscriptions} | invented `emailsubscriptions` (only with `\|default`); WHMCS `emailpreferences` may exist but unproven → CUSTOM. AMBIGUITY | med |
| 37 | text | Email subscription | CUSTOM | {$hadrianLang.services.subscriptionManage} | invented `subscriptionmanage` → rebadge; page title | med |
| 45 | text | Something went wrong | WHMCS | {$LANG.somethingwentwrong} | real key — strip default; WHMCS generic-error string (matches $rslang.error.serverError.title too). | med |
| 46 | text | (error message passthrough) | — | — | `$errorMessage\|strip_tags` — WHMCS var; SKIP | high |
| 51 | text | Subscription updated | CUSTOM | {$hadrianLang.services.subscriptionUpdated} | invented `subscriptionupdated` → rebadge | high |
| 52 | text | (info message passthrough) | — | — | `$infoMessage\|strip_tags` — WHMCS var; SKIP | high |
| 57 | text | You're subscribed | WHMCS | {$LANG.newslettersubscribed} | real key — strip default; nexus subscription-manage.tpl:15 + lagom:17 bare. **TRAP**: genuine `newslettersubscribed` is a full confirmation sentence, not the short title "You're subscribed" | med |
| 58 | text | You will now receive our product news and updates by email. | CUSTOM | {$hadrianLang.services.newsletterSubscribedSub} | invented `newslettersubscribedsub` → rebadge (no WHMCS sub-line) | high |
| 63 | text | You've been unsubscribed | WHMCS | {$LANG.newsletterremoved} | real key — strip default; nexus subscription-manage.tpl:20 + lagom:24 bare. **TRAP**: genuine `newsletterremoved` wording differs from "You've been unsubscribed" | med |
| 64 | text | You will no longer receive marketing emails. | CUSTOM | {$hadrianLang.services.newsletterResubscribeText} | invented `newsletterresubscribetext`; WHMCS has `newsletterresubscribe` (a sprintf2 link sentence) but not this plain line → CUSTOM | med |
| 64 | text | Resubscribe in account settings | CUSTOM | {$hadrianLang.services.newsletterResubscribeLink} | invented `newsletterresubscribelink`; WHMCS `newsletterresubscribe` embeds the link differently → CUSTOM | med |
| 69 | text | Email preferences | CUSTOM | {$hadrianLang.services.emailSubscriptions} | dedupe line 36 | med |
| 70 | text | Manage how we contact you from your account settings. | CUSTOM | {$hadrianLang.services.subscriptionManageSub} | invented `subscriptionmanagesub` → rebadge | high |
| 70 | text | Open account settings | CUSTOM | {$hadrianLang.services.accountSettings} | invented `accountsettings`; WHMCS `accountSettings`/`navaccount` may exist (≈ "Account") but not this phrasing → CUSTOM | med |
| 73 | text | Back to dashboard | WHMCS | {$LANG.returnhome} | real key — strip default; nexus subscription-manage.tpl:30 + lagom:31 bare. Genuine ≈ "Return Home" — wording shift | high |

_Note (newsletter strings):_ `newslettersubscribed`/`newsletterremoved` ARE real WHMCS keys but their genuine values are full sentences (e.g. "You have been subscribed to the newsletter."). Here they are used as short card titles. If exact WHMCS wording is acceptable, strip the default; if the short titles must stay, treat as CUSTOM. Flagged as ambiguity. `newsletterresubscribe` (real, sprintf2 link) does NOT match our split text+link pattern → CUSTOM for both halves.

---

### hadrian/templates/hadrian/core/pages/usagebillingpricing/default/default.tpl
| Line | Type | Current text | Class | Proposed reference | Evidence / Notes | Conf |
|------|------|--------------|-------|--------------------|------------------|------|
| 45 | text | Services | WHMCS | {$LANG.clientareaservices} | real key — strip default; dedupe (upgrade L61) | high |
| 46 | text | Usage pricing | WHMCS | {$LANG.metrics.pricing} | real key — strip default; nexus usagebillingpricing.tpl:5 + lagom:10 bare. **TRAP**: genuine `metrics.pricing` = "Pricing" (used as `{$metric.displayName} {Pricing}`), not "Usage pricing" | high |
| 47 | text | What you'll pay per unit beyond your included quotas. | CUSTOM | {$hadrianLang.services.usagePricingIntro} | invented `usagepricingintro` → rebadge; subtitle | high |
| 56 | text | Resource | CUSTOM | {$hadrianLang.services.metricResource} | invented `metrics.resource` (not found in references); real metrics header is `metrics.metric` ("Metric"). AMBIGUITY — could map to `metrics.metric` | med |
| 57 | text | Included | WHMCS | {$LANG.metrics.includedInBase} | real key — strip default; nexus usagebillingpricing.tpl:25 + lagom:33 bare. **TRAP**: genuine ≈ "included in base price", not bare "Included" | med |
| 58 | text | Overage rate | CUSTOM | {$hadrianLang.services.metricOverageRate} | invented `metrics.overagerate` (not in references); closest real is `metrics.pricePer`. Mint CUSTOM | med |
| 75 | text | (metric desc passthrough) | — | — | `$metric.pricingSchema.info\|strip_tags` — WHMCS var; SKIP | high |
| 83 | text | from %s | CUSTOM | {$hadrianLang.services.metricFrom} | hardcoded `(from {$tier.from})` tier-threshold label; mint CUSTOM (`%s` = qty). Lagom uses `metrics.startingQuantity` for the column header, not an inline "from" | med |
| 95 | text | How billing works. | CUSTOM | {$hadrianLang.services.usagePricingHowTitle} | invented `usagepricinghowtitle` → rebadge | high |
| 96 | text | Usage is metered continuously and totaled at the end of each billing cycle. Overages appear as line items on your next invoice. | CUSTOM | {$hadrianLang.services.usagePricingHow} | invented `usagepricinghow` → rebadge | high |
| 100 | text | View my usage | CUSTOM | {$hadrianLang.services.metricViewUsage} | invented `metrics.viewusage` (not in references); real is `metrics.currentUsage` ("Current Usage") but that's a column header, not a CTA. Mint CUSTOM | med |
| 112 | text | Pricing unavailable | CUSTOM | {$hadrianLang.services.usagePricingNoneTitle} | invented `usagepricingnone` → rebadge; empty-state title | high |
| 113 | text | We couldn't load usage tiers for this product right now. | CUSTOM | {$hadrianLang.services.usagePricingNoneSub} | invented `usagepricingnonesub` → rebadge | high |
| 114 | text | All services | WHMCS | {$LANG.clientareanavservices} | dedupe (upgrade L243) | high |

_Note (metrics.* keys):_ `metrics.pricing` and `metrics.includedInBase` are confirmed real (nexus + lagom). `metrics.resource`, `metrics.overagerate`, `metrics.viewusage` are NOT in any reference and are invented. Real metrics keys that exist: `metrics.metric`, `metrics.currentUsage`, `metrics.pricePer`, `metrics.startingQuantity`, `metrics.unit`, `metrics.title`, `metrics.explanation`. Consider mapping Resource→`metrics.metric`, Overage rate→`metrics.pricePer` if wording fits; otherwise CUSTOM as proposed. Flagged.

---

## Proposed custom keys
```
hadrianLang.common.prevPage = "Previous page"
hadrianLang.common.nextPage = "Next page"

hadrianLang.services.productsServicesSub = "Manage your active services, upgrades, and add-ons."
hadrianLang.services.orderAService = "Order a service"
hadrianLang.services.serviceLower = "service"
hadrianLang.services.servicesLower = "services"
hadrianLang.services.onThisAccount = "on this account"
hadrianLang.services.statusActive = "Active"
hadrianLang.services.statusPending = "Pending"
hadrianLang.services.statusSuspended = "Suspended"
hadrianLang.services.statusTerminated = "Terminated"
hadrianLang.services.statusCancelled = "Cancelled"
hadrianLang.services.statusFraud = "Fraud"
hadrianLang.services.colName = "Name"
hadrianLang.services.serviceFallback = "Service"
hadrianLang.services.rowsPerPage = "Rows per page"
hadrianLang.services.emptyTitle = "No services yet"
hadrianLang.services.emptySub = "You don't have any products or services on this account. Browse our catalogue to get started."
hadrianLang.services.placeAnOrder = "Place an order"

hadrianLang.services.unpaidInvoice = "This service has an unpaid invoice."
hadrianLang.services.loginCpanel = "Log in to cPanel"
hadrianLang.services.loginWebmail = "Log in to Webmail"
hadrianLang.services.usageNotAvailable = "Usage statistics are not available for this service yet."
hadrianLang.services.cpPendingNotice = "This service is still being set up — control-panel access will be available once it goes active."
hadrianLang.services.cpUnavailableTerminated = "This service has been %s; control-panel access is no longer available."
hadrianLang.services.cpUnavailableStatus = "Control-panel access (cPanel / Webmail) is unavailable while this service is %s."
hadrianLang.services.cpPayOverdue = "Pay the overdue invoice to reactivate it."
hadrianLang.services.upgradeSublabel = "Change your hosting plan"
hadrianLang.services.renewSublabel = "Extend your service term"
hadrianLang.services.changePwSublabel = "Set a new control-panel password"
hadrianLang.services.cancelSublabel = "Schedule this service to be cancelled"
hadrianLang.services.scEmailAccounts = "Email Accounts"
hadrianLang.services.scForwarders = "Forwarders"
hadrianLang.services.scAutoresponders = "Autoresponders"
hadrianLang.services.scFileManager = "File Manager"
hadrianLang.services.scBackup = "Backup"
hadrianLang.services.scSubdomains = "Subdomains"
hadrianLang.services.scAddonDomains = "Addon Domains"
hadrianLang.services.scCronJobs = "Cron Jobs"
hadrianLang.services.scMysql = "MySQL Databases"
hadrianLang.services.scPendingNotice = "Shortcuts will be available once this service is active."
hadrianLang.services.scUnavailableStatus = "cPanel shortcuts are unavailable while this service is %s."

hadrianLang.services.upgradeIntro = "Change your plan size or feature tier. Changes are prorated."
hadrianLang.services.enabledState = "Enabled"
hadrianLang.services.disabledState = "Disabled"
hadrianLang.services.cycleMonthlyShort = "mo"
hadrianLang.services.cycleQuarterlyShort = "qtr"
hadrianLang.services.cycleSemiannuallyShort = "6 mo"
hadrianLang.services.cycleAnnuallyShort = "yr"
hadrianLang.services.cycleBienniallyShort = "2 yr"
hadrianLang.services.cycleTrienniallyShort = "3 yr"
hadrianLang.services.backToMyService = "Back to my service"
hadrianLang.services.backToServices = "Back to services"
hadrianLang.services.upgradeNotAvailTitle = "Upgrade not available"
hadrianLang.services.noUpgradeTitle = "No upgrade available"

hadrianLang.services.upgradeConfigureIntro = "Pick your new plan and review the prorated amount before confirming."
hadrianLang.services.proratedCredit = "Prorated credit"
hadrianLang.services.upgradePickFirstTitle = "Start an upgrade"
hadrianLang.services.upgradePickFirstSub = "Choose a service and a target plan to configure your upgrade."

hadrianLang.services.upgradeSummaryIntro = "Confirm the changes and amount due before checkout."
hadrianLang.services.promoFallback = "Promo"
hadrianLang.services.upgradeNoSummaryTitle = "Nothing to confirm"
hadrianLang.services.upgradeNoSummarySub = "Start an upgrade from one of your services to see the summary here."

hadrianLang.services.emailSubscriptions = "Email preferences"
hadrianLang.services.subscriptionManage = "Email subscription"
hadrianLang.services.subscriptionUpdated = "Subscription updated"
hadrianLang.services.newsletterSubscribedSub = "You will now receive our product news and updates by email."
hadrianLang.services.newsletterResubscribeText = "You will no longer receive marketing emails."
hadrianLang.services.newsletterResubscribeLink = "Resubscribe in account settings"
hadrianLang.services.subscriptionManageSub = "Manage how we contact you from your account settings."
hadrianLang.services.accountSettings = "Open account settings"

hadrianLang.services.usagePricingIntro = "What you'll pay per unit beyond your included quotas."
hadrianLang.services.metricResource = "Resource"
hadrianLang.services.metricOverageRate = "Overage rate"
hadrianLang.services.metricFrom = "from %s"
hadrianLang.services.usagePricingHowTitle = "How billing works."
hadrianLang.services.usagePricingHow = "Usage is metered continuously and totaled at the end of each billing cycle. Overages appear as line items on your next invoice."
hadrianLang.services.metricViewUsage = "View my usage"
hadrianLang.services.usagePricingNoneTitle = "Pricing unavailable"
hadrianLang.services.usagePricingNoneSub = "We couldn't load usage tiers for this product right now."
```
