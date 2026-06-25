# B09 — Dashboard (client home + public homepage)

## Summary
- **Total table rows:** 113 (clientareahome: 73, homepage: 38, +2 SKIP-noted rows). After dedupe the **distinct strings** are far fewer — the 6 tile variants (A/B/C/D/E/F) repeat the same 4 labels (Services / Domains / Unpaid Invoices / Tickets), so ~24 tile rows collapse to 4 distinct keys.
- **WHMCS:** 74
- **CUSTOM:** 37
- **#SKIP-worth-noting:** 2 listed rows (lines 388 `'Service'`, 474 `'Open'` — `|default` on a *dynamic var*, not on `$LANG`) + the broad skips below (`$rslang` not present in either file; `$companyname`, `$clientsstats.*`, `$svc.*`, `$tkt.*`, `$ann.*`, menu-object `getLabel()/getBadge()/getName()` dynamic output; status-pill fallbacks; SVG/URLs/`data-*`/JS identifiers)
- **#js-string:** 0 (both `<script>` blocks set `data-*` attributes / wire form actions only — no user-facing string literals)

### Evidence legend (same as B08)
- nexus uses `{lang key='x'}` → resolves real WHMCS `$_LANG`; citing it proves the key is real.
- lagom uses `{$LANG.x}` (bare) → same proof.
- This theme writes `{$LANG.x|default:'...'}` **everywhere** (never a bare `{$LANG.x}`), so per spec the `|default` literal is the "Current text". A key provable elsewhere → **WHMCS** ("strip default"); a `|default`-only key with no external proof → **CUSTOM** ("invented LANG key → rebadge").
- Several nav labels here (`clientareanavhome`, `accounttab`, `navchangedetails`) are **genuine WHMCS nav `$_LANG` keys** that WHMCS resolves inside core Menu objects, so they never appear in a reference *template* and can't be cited file:line. Per "prefer real WHMCS keys" they stay **WHMCS** at med/low confidence (see B08 ambiguity note); flagged again below.

### Cross-cutting traps found (real key under a different name / different default)
- **`networkstatus` → real key is `networkstatustitle`.** hadrian: `{$LANG.networkstatus|default:'Network Status'}`. Real WHMCS key proven at `nexus/homepage.tpl:66` `{lang key='networkstatustitle'}` (+ lagom menu JSONs). `networkstatus` is invented. Switch to `{$LANG.networkstatustitle}`.
- **`domainsearch` → real key is `navdomainsearch`.** hadrian: `{$LANG.domainsearch|default:'Domain Search'}`. Real key at `nexus/homepage.tpl:29` `{lang key='navdomainsearch'}`. Switch to `{$LANG.navdomainsearch}`.
- **`productsservices` → real key is `clientHomePanels.productsAndServices`.** hadrian homepage eyebrow `{$LANG.productsservices|default:'Products & Services'}`. Real key at `nexus/homepage.tpl:2`. (Note: the eyebrow wording is "Products & Services" vs WHMCS "Products and Services" — same key, slight wording shift is acceptable per policy.)
- **`renew` → real key is `domainrenew`.** hadrian notice `{$LANG.renew|default:'Renew'}`. Real key at `lagom2.3/lagom2-theme/clientareahome.tpl:28` `{$LANG.domainrenew}`. Switch to `{$LANG.domainrenew}`.
- **homepage account tiles use lowercase invented keys where WHMCS has `homepage.*`.** `youraccount`/`manageservices`/`managedomains`/`supportrequests`/`submitticket`/`makepayment` → WHMCS `homepage.yourAccount`/`homepage.manageServices`/`homepage.manageDomains`/`homepage.supportRequests`/`homepage.submitTicket`/`homepage.makeAPayment` (all proven in `nexus/homepage.tpl:90-137`). `makepayment` (bare) is *also* a real key (lagom homepage.tpl:74) — either resolves; the `homepage.*` set matches this exact page 1:1, so it is the better target. Flagged as ambiguity.

---

### hadrian/templates/hadrian/core/pages/clientareahome/default/default.tpl
| Line | Type | Current text | Class | Proposed reference | Evidence / Notes | Conf |
|------|------|--------------|-------|--------------------|------------------|------|
| 102 | text | My Dashboard | WHMCS | {$LANG.clientareanavhome} | WHMCS nav key, core-resolved (cf. B08 line 102 same key); default here "My Dashboard" vs "Dashboard" on the aside line 570 — same key; strip default | med |
| 119 | text | You have | CUSTOM | {$hadrianLang.dashboard.youHave} | sentence fragment "You have <n> overdue invoice(s)"; no WHMCS key for the fragment; invented | med |
| 119 | text | overdue invoice | CUSTOM | {$hadrianLang.dashboard.overdueInvoice} | singular; `invoiceoverdue` is `|default`-only here, not provable | med |
| 119 | text | overdue invoices | CUSTOM | {$hadrianLang.dashboard.overdueInvoices} | plural; `invoicesoverdue` invented | med |
| 119 | text | with a total of | CUSTOM | {$hadrianLang.dashboard.withTotalOf} | sentence fragment; invented | med |
| 119 | text | due | CUSTOM | {$hadrianLang.dashboard.due} | trailing fragment ("… due."); invented | low |
| 120 | text | Pay now | WHMCS | {$LANG.invoicespaynow} | real key — `lagom2.3/lagom2-theme/clientareahome.tpl:23` `{$LANG.invoicespaynow}` (overdue-invoice alert "Pay Now"); default "Pay now" vs key; strip default | high |
| 122 | aria-label | Dismiss | CUSTOM | {$hadrianLang.dashboard.dismiss} | notice close button; `dismiss` is `|default`-only, no WHMCS key in refs (lagom uses `supportticketsclose` for alert close); invented | med |
| 133 | text | domain | CUSTOM | {$hadrianLang.dashboard.domainSingular} | "<n> domain expires…"; `domainexpiring` invented fragment | low |
| 133 | text | domains | CUSTOM | {$hadrianLang.dashboard.domainPlural} | plural fragment; `domainsexpiring` invented | low |
| 133 | text | expires in the next 45 days | CUSTOM | {$hadrianLang.dashboard.expireWithin45} | `expirewithin45` invented; bespoke copy | med |
| 134 | text | Renew | WHMCS | {$LANG.domainrenew} | real key — `lagom2.3/lagom2-theme/clientareahome.tpl:28` `{$LANG.domainrenew}`; hadrian's `renew|default:'Renew'` → switch to `domainrenew` | high |
| 134 | text | to keep active | CUSTOM | {$hadrianLang.dashboard.toKeepActive} | trailing fragment; invented | low |
| 136 | aria-label | Dismiss | CUSTOM | {$hadrianLang.dashboard.dismiss} | dedupe of line 122 | med |
| 150 | text | Welcome to | CUSTOM | {$hadrianLang.dashboard.welcomeTo} | empty-state greeting prefix; `welcometo` invented | med |
| 150 | text | Start by | CUSTOM | {$hadrianLang.dashboard.startBy} | `startbyordering` invented fragment | low |
| 150 | text | ordering a service | CUSTOM | {$hadrianLang.dashboard.orderingAService} | link text; `orderingaservice` invented | med |
| 150 | text | or | WHMCS | {$LANG.or} | real key — `lagom2.3/.../login.tpl:56`, `standard_cart`/lagom register-fields `{$LANG.or}`; strip default | high |
| 150 | text | registering a domain | CUSTOM | {$hadrianLang.dashboard.registeringADomain} | link text; `registeradomain` invented (distinct from WHMCS `registerdomain`="Register") | med |
| 161 | text | Variant A — vertical | CUSTOM | {$hadrianLang.dashboard.variantA} | dev/preview label inside `.variant-label`; only one variant is shown via `data-tiles`. Borderline — likely SKIP as dev scaffolding; tokenize only if these stay in prod | low |
| 166 | text | Services | WHMCS | {$LANG.servicesactive} | tile label; lagom tiles use `{$LANG.navservices}`(="My Services"); `servicesactive` is `|default`-only → consider `navservices`. Kept as WHMCS (servicesactive is a plausible real WHMCS key) but verify; strip default | low |
| 171 | text | Domains | WHMCS | {$LANG.navdomains} | real key — `nexus/clientareahome.tpl:18`, `lagom2.3/.../clientareahome.tpl:78`; default "Domains" vs "My Domains" same key; strip default | high |
| 176 | text | Unpaid Invoices | WHMCS | {$LANG.clientHomePanels.unpaidInvoices} | real key — `lagom2.3/.../clientareahome.tpl:108` `{$LANG.clientHomePanels.unpaidInvoices}`, masspay.tpl:7; hadrian's `unpaidinvoices` → switch; strip default | high |
| 181 | text | Tickets | WHMCS | {$LANG.supporttickets} | WHMCS section key (`supporttickets`), core-resolved (cf. B08); default "Tickets"; strip default | med |
| 188 | text | Variant B — horizontal | CUSTOM | {$hadrianLang.dashboard.variantB} | dev label; see line 161 note | low |
| 194 | text | Services | WHMCS | {$LANG.servicesactive} | dedupe of line 166 | low |
| 201 | text | Domains | WHMCS | {$LANG.navdomains} | dedupe of line 171 | high |
| 208 | text | Unpaid Invoices | WHMCS | {$LANG.clientHomePanels.unpaidInvoices} | dedupe of line 176 | high |
| 215 | text | Tickets | WHMCS | {$LANG.supporttickets} | dedupe of line 181 | med |
| 223 | text | Variant C — tinted | CUSTOM | {$hadrianLang.dashboard.variantC} | dev label | low |
| 228 | text | Services | WHMCS | {$LANG.servicesactive} | dedupe of line 166 | low |
| 233 | text | Domains | WHMCS | {$LANG.navdomains} | dedupe of line 171 | high |
| 238 | text | Unpaid Invoices | WHMCS | {$LANG.clientHomePanels.unpaidInvoices} | dedupe of line 176 | high |
| 243 | text | Tickets | WHMCS | {$LANG.supporttickets} | dedupe of line 181 | med |
| 250 | text | Variant D — list | CUSTOM | {$hadrianLang.dashboard.variantD} | dev label | low |
| 254 | text | Services | WHMCS | {$LANG.servicesactive} | dedupe of line 166 | low |
| 260 | text | Domains | WHMCS | {$LANG.navdomains} | dedupe of line 171 | high |
| 266 | text | Unpaid Invoices | WHMCS | {$LANG.clientHomePanels.unpaidInvoices} | dedupe of line 176 | high |
| 272 | text | Tickets | WHMCS | {$LANG.supporttickets} | dedupe of line 181 | med |
| 281 | text | Variant F — list (horizontal) | CUSTOM | {$hadrianLang.dashboard.variantF} | dev label | low |
| 286 | text | Services | WHMCS | {$LANG.servicesactive} | dedupe of line 166 | low |
| 293 | text | Domains | WHMCS | {$LANG.navdomains} | dedupe of line 171 | high |
| 300 | text | Unpaid | WHMCS | {$LANG.unpaid} | short tile label; `unpaid` is a standard WHMCS key (invoice status); `|default`-only here → verify, strip default | low |
| 307 | text | Tickets | WHMCS | {$LANG.supporttickets} | dedupe of line 181 | med |
| 316 | text | Variant E — rings | CUSTOM | {$hadrianLang.dashboard.variantE} | dev label | low |
| 323 | text | Services | WHMCS | {$LANG.servicesactive} | dedupe of line 166 | low |
| 330 | text | Domains | WHMCS | {$LANG.navdomains} | dedupe of line 171 | high |
| 337 | text | Unpaid Invoices | WHMCS | {$LANG.clientHomePanels.unpaidInvoices} | dedupe of line 176 | high |
| 344 | text | Tickets | WHMCS | {$LANG.supporttickets} | dedupe of line 181 | med |
| 354 | text | Your Active Products/Services | WHMCS | {$LANG.clientHomePanels.activeProductsServices} | panel header; WHMCS `clientHomePanels` group is real (cf. `clientHomePanels.unpaidInvoices`/`.activeProductsServicesNone` in lagom); this is the WHMCS home-panel name; strip default | med |
| 356 | text | View All | WHMCS | {$LANG.viewall} | `viewall` is a standard WHMCS key; reused across hadrian (`clientareaproducts.tpl:92`, `login/split.tpl:42`); `|default`-only in refs → verify, strip default | med |
| 388 | text | Service | SKIP | — | `|default` on dynamic `$svc.groupname|...|default:'Service'` (fallback title), not on `$LANG` → SKIP-worth-noting, not tokenizable | low |
| 399 | text | Manage | WHMCS | {$LANG.manageproduct} | real key reused theme-wide (`clientareaproducts.tpl:175` `manageproduct`="Manage Product", managessl `manageproduct`="Manage"); strip default | med |
| 410 | text | No services yet | CUSTOM | {$hadrianLang.dashboard.noServicesTitle} | empty-state title; `noproductsactive` is `|default`-only. (WHMCS has `clientHomePanels.activeProductsServicesNone` = the lagom empty msg — could be WHMCS; wording differs. Prefer WHMCS `{$LANG.clientHomePanels.activeProductsServicesNone}` if parity desired) | med |
| 411 | text | You don't have any active products. Browse our catalogue… | CUSTOM | {$hadrianLang.dashboard.noServicesSub} | `noproductssub` invented; bespoke copy | high |
| 412 | text | Order a service | WHMCS | {$LANG.orderproducts} | `orderproducts` is a standard WHMCS key ("Order New Products"); cf. lagom `navservicesorder`; `|default`-only → verify, strip default | low |
| 422 | text | Recent Support Tickets | WHMCS | {$LANG.recentSupportTickets} | WHMCS home-panel name "Recent Support Tickets" (the `$homePanel->getName()` matched at line 52); `|default`-only → core-resolved panel title; strip default | med |
| 424 | text | Open New Ticket | WHMCS | {$LANG.navopenticket} | real key — `lagom2.3/.../clientareahome.tpl:225` `{$LANG.navopenticket}`, pageheader.tpl:31; hadrian's `opennewticket` → switch; strip default | high |
| 453 | text | Updated | CUSTOM | {$hadrianLang.dashboard.updated} | ticket-row meta prefix "Updated <date>"; `updated` is `|default`-only, no WHMCS ref; invented | low |
| 472 | text | Updated | CUSTOM | {$hadrianLang.dashboard.updated} | dedupe of line 453 | low |
| 472 | text | Opened | CUSTOM | {$hadrianLang.dashboard.opened} | ticket-row meta prefix "Opened <date>"; `opened` invented | low |
| 474 | text | Open | SKIP | — | `|default` on dynamic `$tkt.status|...|default:'Open'`, not on `$LANG` → SKIP-worth-noting, not tokenizable | low |
| 484 | text | No tickets yet | CUSTOM | {$hadrianLang.dashboard.noTicketsTitle} | empty-state; `notickets` `|default`-only; invented | med |
| 485 | text | Need a hand with something? We're here to help. | CUSTOM | {$hadrianLang.dashboard.noTicketsSub} | `noticketssub` invented; bespoke copy | high |
| 486 | text | Open a ticket | WHMCS | {$LANG.navopenticket} | reuse of `navopenticket` (line 424); default "Open a ticket" vs "Open New Ticket" — same key | med |
| 494 | text | Register a New Domain | WHMCS | {$LANG.registerNewDomain} | WHMCS home-panel name "Register a New Domain" (matches `getName()=="Register a New Domain"` pattern used in nexus/lagom panels); `|default`-only → core panel title; strip default | med |
| 498 | placeholder | Find your new domain name | WHMCS | {$LANG.domainsfindyournew} | `domainsfindyournew` is a plausible real WHMCS domain-search placeholder key; `|default`-only → verify; (fallback CUSTOM `dashboard.findYourNewDomain` if not real) | low |
| 500 | value | Transfer | WHMCS | {$LANG.transferdomain} | submit button; real key — `standard_cart/domaintransfer.tpl:12` `{$LANG.transferdomain}`; strip default | high |
| 501 | value | Register | WHMCS | {$LANG.registerdomain} | submit button; real key — `standard_cart/domainregister.tpl:12` `{$LANG.registerdomain}`; strip default | high |
| 511 | text | Recent News | WHMCS | {$LANG.recentNews} | WHMCS home-panel name "Recent News" (matches `getName()=="Recent News"` at line 59); `|default`-only → core panel title; strip default | med |
| 513 | text | View All | WHMCS | {$LANG.viewall} | dedupe of line 356 | med |
| 554 | text | No announcements | CUSTOM | {$hadrianLang.dashboard.noAnnouncements} | empty-state; `announcementsnone` `|default`-only; invented (WHMCS has `announcementsnone`? not provable in refs) | low |
| 555 | text | Product updates and network notices will appear here. | CUSTOM | {$hadrianLang.dashboard.noAnnouncementsSub} | `announcementssub` invented; bespoke copy | high |
| 567 | text | Account | WHMCS | {$LANG.accounttab} | WHMCS nav key, core-resolved (cf. B08); strip default | med |
| 570 | text | Dashboard | WHMCS | {$LANG.clientareanavhome} | dedupe of line 102 (same key, default "Dashboard") | med |
| 574 | text | My Services | WHMCS | {$LANG.navservices} | real key — `nexus/clientareahome.tpl:9`, `lagom2.3/.../clientareahome.tpl:70`; strip default | high |
| 579 | text | My Domains | WHMCS | {$LANG.navdomains} | dedupe (real key, default "My Domains") | high |
| 584 | text | Invoices | WHMCS | {$LANG.navinvoices} | real key — `nexus/clientareahome.tpl:53` `{lang key='navinvoices'}`; strip default | high |
| 589 | text | Support Tickets | WHMCS | {$LANG.navtickets} | real key — `nexus/clientareahome.tpl:45`, `lagom2.3/.../clientareahome.tpl:115`; strip default | high |
| 594 | text | My Details | WHMCS | {$LANG.navchangedetails} | WHMCS nav key, core-resolved (cf. real `clientareanavdetails`); strip default | med |

Notes (clientareahome): SKIPPED — all `{$clientsstats.*}`, `{$companyname|escape}`, `{$nUnpaid}`, menu-object output (`$serviceItem->getLabel()`, `getBadge()`, `getName()`, `$ticketItem->*`, `$newsItem->*`), `$svc.*`/`$tkt.*`/`$ann.*` dynamic fields, status-pill class fallbacks, the `data-*` body attributes in the line 80-96 `<script>` (config values, no UI strings), all SVG/URLs/ids/classes. The status-text `|default` fallbacks at lines 388 (`'Service'`), 398 (`'Active'`), 474 (`'Open'`) sit on dynamic vars, not `$LANG` → noted, not rows.

---

### hadrian/templates/hadrian/core/pages/homepage/default/default.tpl
| Line | Type | Current text | Class | Proposed reference | Evidence / Notes | Conf |
|------|------|--------------|-------|--------------------|------------------|------|
| 17 | text | Secure your domain name. | CUSTOM | {$hadrianLang.dashboard.heroTitle} | hero H1; `homepageherotitle` invented marketing copy (lagom/nexus have no equivalent hero string — lagom uses `findyourdomain`) | high |
| 18 | text | Search, register, and transfer — all in one place. | CUSTOM | {$hadrianLang.dashboard.heroSubtitle} | hero sub; `homepageherosubtitle` invented | high |
| 21 | text | Search | WHMCS | {$LANG.search} | tab; real key — `standard_cart/domainregister.tpl:54`, lagom homepage.tpl:24 `{$LANG.search}`; strip default | high |
| 22 | text | Transfer | WHMCS | {$LANG.transferdomain} | tab; real key — `standard_cart/domaintransfer.tpl:12`; default "Transfer"; strip default | high |
| 28 | placeholder | eg. example.com | WHMCS | {$LANG.exampledomain} | domain-search placeholder; real key — `lagom2.3/lagom2-theme/homepage.tpl:14` `placeholder="{$LANG.exampledomain}"`; hadrian's `homepageherodomainplaceholder` → switch; strip default | high |
| 29 | text | Search | WHMCS | {$LANG.search} | submit button; dedupe of line 21 | high |
| 40 | text | Find the perfect name for your project. | CUSTOM | {$hadrianLang.dashboard.heroDomainSubtitle} | `homepageherodomainsubtitle` invented marketing copy | high |
| 41 | text | View all pricing | WHMCS | {$LANG.viewallpricing} | `viewallpricing` is a plausible WHMCS domain-pricing key; `|default`-only in hadrian (also used `domain-pricing` page) → verify; fallback CUSTOM `dashboard.viewAllPricing` | low |
| 50 | text | Products & Services | WHMCS | {$LANG.clientHomePanels.productsAndServices} | eyebrow; real key — `nexus/homepage.tpl:2` `{lang key='clientHomePanels.productsAndServices'}`; hadrian's `productsservices` → switch (wording "&" vs "and" ok); strip default | high |
| 51 | text | Browse our products. | CUSTOM | {$hadrianLang.dashboard.section1Title} | section H2; `homepagesection1title` invented (nexus uses the panel header, not this phrasing) | high |
| 58 | text | WordPress Hosting | CUSTOM | {$hadrianLang.dashboard.productCard1Title} | `homepagebrowseproductstitle1` invented; bespoke product card (brand word "WordPress" inside a label) | med |
| 59 | text | Managed WordPress built for speed, backed by automatic updates. | CUSTOM | {$hadrianLang.dashboard.productCard1Desc} | `homepagebrowseproductsdesc1` invented marketing copy | high |
| 60 | text | Browse Products | WHMCS | {$LANG.browseProducts} | CTA; real key — `nexus/homepage.tpl:14` `{lang key='browseProducts'}`; hadrian's lowercase `browseproducts` → switch to camelCase `browseProducts`; strip default | high |
| 66 | text | Register a New Domain | WHMCS | {$LANG.orderregisterdomain} | card H3; real key — `nexus/homepage.tpl:25` `{lang key='orderregisterdomain'}` ("Register a New Domain"); hadrian's `registerdomain`(="Register") here mismatches the long label → switch to `orderregisterdomain`; strip default | high |
| 67 | text | Secure your domain name by registering it today. | WHMCS | {$LANG.secureYourDomain} | card desc; real key — `nexus/homepage.tpl:27` `{lang key='secureYourDomain'}`; hadrian's `homepagebrowseproductsdesc2` → switch; strip default | high |
| 68 | text | Domain Search | WHMCS | {$LANG.navdomainsearch} | CTA; real key — `nexus/homepage.tpl:29` `{lang key='navdomainsearch'}`; hadrian's `domainsearch` → switch; strip default | high |
| 74 | text | Transfer Your Domain | WHMCS | {$LANG.transferYourDomain} | card H3; real key — `nexus/homepage.tpl:38/42` `{lang key='transferYourDomain'}`; hadrian's `transferdomain` (default "Transfer Your Domain") → switch to `transferYourDomain`; strip default | high |
| 75 | text | Transfer now to extend your domain by 1 year. | WHMCS | {$LANG.transferExtend} | card desc; real key — `nexus/homepage.tpl:40` `{lang key='transferExtend'}` (also `orderForm.transferExtend` in standard_cart/lagom); hadrian's `homepagebrowseproductsdesc3` → switch; strip default | high |
| 76 | text | Transfer Your Domain | WHMCS | {$LANG.transferYourDomain} | CTA; dedupe of line 74 | high |
| 84 | text | Self-service | CUSTOM | {$hadrianLang.dashboard.selfService} | eyebrow; `selfservice` `|default`-only, no WHMCS ref; invented | med |
| 85 | text | How can we help today? | WHMCS | {$LANG.howCanWeHelp} | section H2; real key — `nexus/homepage.tpl:50` `{lang key='howCanWeHelp'}`, `lagom2.3/.../homepage.tpl:47` `{$LANG.howcanwehelp}`; hadrian's `homepagesection2title` → switch; strip default | high |
| 92 | text | Announcements | WHMCS | {$LANG.announcementstitle} | action label; real key — `nexus/homepage.tpl:58` `{lang key='announcementstitle'}`; strip default | high |
| 98 | text | Network Status | WHMCS | {$LANG.networkstatustitle} | action label; real key — `nexus/homepage.tpl:66` `{lang key='networkstatustitle'}`; hadrian's `networkstatus` → switch; strip default | high |
| 104 | text | Knowledgebase | WHMCS | {$LANG.knowledgebasetitle} | action label; real key — `nexus/homepage.tpl:74` `{lang key='knowledgebasetitle'}`; strip default | high |
| 110 | text | Downloads | WHMCS | {$LANG.downloadstitle} | action label; real key — `nexus/homepage.tpl:82` `{lang key='downloadstitle'}`; strip default | high |
| 116 | text | Submit a Ticket | WHMCS | {$LANG.homepage.submitTicket} | action label; real key — `nexus/homepage.tpl:90` `{lang key='homepage.submitTicket'}`; hadrian's `submitticket` → switch; strip default | high |
| 124 | text | Account | WHMCS | {$LANG.accounttab} | eyebrow; WHMCS nav key (cf. B08); strip default | med |
| 125 | text | Your account. | WHMCS | {$LANG.homepage.yourAccount} | section H2; real key — `nexus/homepage.tpl:95` `{lang key='homepage.yourAccount'}`; hadrian's `homepagesection3title` → switch (default "Your account." vs "Your Account"); strip default | high |
| 132 | text | Your Account | WHMCS | {$LANG.homepage.yourAccount} | action label; real key — `nexus/homepage.tpl:103`; hadrian's `youraccount` → switch; dedupe with line 125 (same key) | high |
| 138 | text | Manage Services | WHMCS | {$LANG.homepage.manageServices} | action label; real key — `nexus/homepage.tpl:111` `{lang key='homepage.manageServices'}`; hadrian's `manageservices` → switch; strip default | high |
| 144 | text | Manage Domains | WHMCS | {$LANG.homepage.manageDomains} | action label; real key — `nexus/homepage.tpl:120` `{lang key='homepage.manageDomains'}`; hadrian's `managedomains` → switch; strip default | high |
| 150 | text | Support Requests | WHMCS | {$LANG.homepage.supportRequests} | action label; real key — `nexus/homepage.tpl:129` `{lang key='homepage.supportRequests'}`; hadrian's `supportrequests` → switch; strip default | high |
| 156 | text | Make a Payment | WHMCS | {$LANG.homepage.makeAPayment} | action label; real key — `nexus/homepage.tpl:137` `{lang key='homepage.makeAPayment'}`; hadrian's `makepayment` → switch (note: bare `makepayment` is also real — lagom homepage.tpl:74 — but `homepage.makeAPayment` matches this exact tile); strip default | high |

Notes (homepage): SKIPPED — `{$WEB_ROOT}`/all hrefs, `{$captcha->getButtonClass(...)}` and the captcha include, `{$companyname}` (not present), SVG path data, `data-dtab`/`role`/`aria-selected` attr values, the `&rarr;` entity, and the line 162-181 `<script>` (binds tab clicks + swaps `form.action` to a URL — no user-facing string literals → 0 js-string).

---

## NEW AMBIGUITIES (for the user / Phase B)
1. **`servicesactive` (tiles "Services")** — `|default`-only on this page; could be a real WHMCS key OR should reuse `navservices` (="My Services", what lagom tiles use). Kept WHMCS low-conf. Decide: `servicesactive` vs `navservices`.
2. **Core-resolved WHMCS panel names** — `clientHomePanels.activeProductsServices`, `recentSupportTickets`, `recentNews`, `registerNewDomain` are the literal WHMCS home-**panel** display names (matched against `$homePanel->getName()` in this very file). They're real WHMCS strings but resolve inside Menu/Panel objects, so not citable in a reference *template*. Treated WHMCS med-conf — verify the exact `$_LANG`/`clientHomePanels.*` key names in server `lang/english.php`.
3. **`makepayment` vs `homepage.makeAPayment`** (and the rest of the lowercase-vs-`homepage.*` set on the public homepage) — both resolve; `homepage.*` is the 1:1 nexus match for this page. Confirm which family to standardize on.
4. **Empty-state titles vs WHMCS `*None` keys** — hadrian's `noproductsactive`/`notickets`/`announcementsnone` (+`*sub`) are bespoke. WHMCS has `clientHomePanels.activeProductsServicesNone` (proven, lagom clientareaproducts.tpl:227) for the services empty msg; if exact-parity is wanted, prefer the WHMCS key for the title and keep only the `*sub` lines as CUSTOM. Currently classed CUSTOM.
5. **Variant dev labels (lines 161/188/223/250/281/316: "Variant A — vertical" … "Variant E — rings")** — visible text nodes, so in scope per spec, BUT they are preview/QA scaffolding for the tile-variant chooser (only one variant renders via `data-tiles`). Listed as CUSTOM `dashboard.variant*` but **recommend SKIP/remove** rather than translate. Confirm whether they ship to production.
6. **`domainsfindyournew` / `viewallpricing` / `unpaid` / `orderproducts` / `viewall`** — plausible real WHMCS keys used here `|default`-only with no reference-template citation. Classed WHMCS low-conf; verify against server `lang/english.php` (fallback CUSTOM names given inline).

## Proposed custom keys
```
hadrianLang.dashboard.youHave = "You have"
hadrianLang.dashboard.overdueInvoice = "overdue invoice"
hadrianLang.dashboard.overdueInvoices = "overdue invoices"
hadrianLang.dashboard.withTotalOf = "with a total of"
hadrianLang.dashboard.due = "due"
hadrianLang.dashboard.dismiss = "Dismiss"
hadrianLang.dashboard.domainSingular = "domain"
hadrianLang.dashboard.domainPlural = "domains"
hadrianLang.dashboard.expireWithin45 = "expires in the next 45 days"
hadrianLang.dashboard.toKeepActive = "to keep active"
hadrianLang.dashboard.welcomeTo = "Welcome to"
hadrianLang.dashboard.startBy = "Start by"
hadrianLang.dashboard.orderingAService = "ordering a service"
hadrianLang.dashboard.registeringADomain = "registering a domain"
hadrianLang.dashboard.noServicesTitle = "No services yet"
hadrianLang.dashboard.noServicesSub = "You don't have any active products. Browse our catalogue to get started."
hadrianLang.dashboard.noTicketsTitle = "No tickets yet"
hadrianLang.dashboard.noTicketsSub = "Need a hand with something? We're here to help."
hadrianLang.dashboard.noAnnouncements = "No announcements"
hadrianLang.dashboard.noAnnouncementsSub = "Product updates and network notices will appear here."
hadrianLang.dashboard.updated = "Updated"
hadrianLang.dashboard.opened = "Opened"
hadrianLang.dashboard.heroTitle = "Secure your domain name."
hadrianLang.dashboard.heroSubtitle = "Search, register, and transfer — all in one place."
hadrianLang.dashboard.heroDomainSubtitle = "Find the perfect name for your project."
hadrianLang.dashboard.section1Title = "Browse our products."
hadrianLang.dashboard.productCard1Title = "WordPress Hosting"
hadrianLang.dashboard.productCard1Desc = "Managed WordPress built for speed, backed by automatic updates."
hadrianLang.dashboard.selfService = "Self-service"
hadrianLang.dashboard.variantA = "Variant A — vertical"
hadrianLang.dashboard.variantB = "Variant B — horizontal"
hadrianLang.dashboard.variantC = "Variant C — tinted"
hadrianLang.dashboard.variantD = "Variant D — list"
hadrianLang.dashboard.variantE = "Variant E — rings"
hadrianLang.dashboard.variantF = "Variant F — list (horizontal)"
```
(Conditional fallbacks if the WHMCS-low-conf keys prove invented: `dashboard.findYourNewDomain` = "Find your new domain name", `dashboard.viewAllPricing` = "View all pricing".)
