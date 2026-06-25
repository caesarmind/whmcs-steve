# B11 — Domains (client-area domain pages)

## Summary
- **Total strings reported:** 159
- **WHMCS** (real key — strip/fix `|default`): 117
- **CUSTOM** (invented LANG key → rebadge to `$hadrianLang.domains.*`): 42
- **js-string:** 1 ("Copied" in getepp copy button)
- **SKIP-worth-noting:** see notes — DNS record-type `<option>` codes (A/AAAA/CNAME/MX/MXE/TXT/URL/FRAME) are protocol tokens (SKIP); brand/proper nouns none; `$rslang`/legacy keys: **none** (`core/lang/english.php` has NO domain keys, so nothing pre-tokenized to preserve).

**Cross-cutting traps found (real key piped a *different* `|default` literal — fix the literal, keep/repoint key):**
- `payinvoice` (lowercase) → real key is **`payInvoice`** (camelCase). Casing trap. (`lagom2.3/.../clientareadomaindetails.tpl:17`, `nexus/clientareadomaindetails.tpl:11`)
- `status` (header "Status") → real domain key is **`domainstatus`**. (`lagom2.3/.../clientareadomains.tpl:118`)
- `autorenew` (header "Auto-Renew") → real domain key is **`domainsautorenew`** ("Auto Renew"). (`lagom2.3/.../clientareadomains.tpl:117`)
- `managens` ("Manage Nameservers") → real key is **`domainmanagens`**. (`lagom2.3/.../clientareadomains.tpl:234`)
- `editcontactinfo` ("Edit Contact Information") → real key is **`domaincontactinfoedit`**. (`lagom2.3/.../clientareadomains.tpl:237`)
- `autorenewstatus` ("Auto Renewal Status") → real key is **`domainautorenewstatus`**. (`lagom2.3/.../clientareadomains.tpl:240`)
- `dnsmanagement` (sidebar "DNS records") → real key is **`domaindnsmanagement`** ("DNS Management"). (`lagom2.3/.../clientareadomaindns.tpl:6`)
- `emailforwarding` (sidebar "Email forwarders") → real key is **`domainemailforwarding`** ("Email Forwarding"). (`lagom2.3/.../clientareadomainemailforwarding.tpl:6`)
- `pricingregister` / `pricingtransfer` / `pricingrenewal` (no dot) → real keys are dotted **`pricing.register` / `pricing.transfer` / `pricing.renewal`**. (`nexus/domain-pricing.tpl:39-41`, `lagom2.3/.../domain-pricing.tpl:39-41`)
- `domainaddonsbuynow` is reused by our theme for **three different literals** ("Add", "Buy now", "Price") — the real key value is "Buy now". The "Add"/"Price" labels are wrong reuses → see per-row notes.

**New ambiguities flagged (no reference evidence either way):**
- `expires` (col header) — no bare WHMCS `expires` key found (refs use `nextdue`/`clientareahostingexpirydate`). Treated CUSTOM; could repoint to `clientareahostingexpirydate` if that string reads ("Expiry Date").
- `delete` (registerns Delete button) — generic; not used on any reference domain page, but almost certainly a real WHMCS generic key. Treated CUSTOM, med-conf it's actually real.
- `at` (email-forwarding "At" column) — no key anywhere. CUSTOM.
- `help` (`{$LANG.help|default:'Common record types'}`) — `help` is a real WHMCS key but its value is "Help", NOT "Common record types"; this is an invented-literal-on-real-key. Reported CUSTOM (rebadge the literal); do not strip to `{$LANG.help}` or copy changes to "Help".

---

### hadrian/templates/hadrian/core/pages/clientareadomains/default/default.tpl
| Line | Type | Current text | Class | Proposed reference | Evidence / Notes | Conf |
|------|------|--------------|-------|--------------------|------------------|------|
| 67 | text | Domains | WHMCS | {$LANG.navdomains} | real key — strip default; `lagom2.3/clientareahome.tpl:78` `{$LANG.navdomains}` | high |
| 67 | text | Manage your registrations, renewals, and DNS. | CUSTOM | {$hadrianLang.domains.manageSub} | invented `domainsmanagesub` → rebadge; no WHMCS key | high |
| 70 | text | Register a domain | WHMCS | {$LANG.registeradomain} | close to real `registeradomain` ("Register a Domain"); slight wording shift OK per policy | med |
| 86 | text | domain | WHMCS | {$LANG.domainsingular} | invented `domainsingular`; ambiguous — see note. Treated CUSTOM below | — |
| 86 | text | domain (singular) | CUSTOM | {$hadrianLang.domains.singular} | invented `domainsingular` → rebadge | med |
| 86 | text | domains (plural) | CUSTOM | {$hadrianLang.domains.plural} | invented `domainsplural` → rebadge | med |
| 86 | text | expiring in the next 30 days. | CUSTOM | {$hadrianLang.domains.expireWithin30} | invented `expirewithin30`; no WHMCS key | high |
| 88 | text | Renew now | CUSTOM | {$hadrianLang.domains.renewNow} | invented `renewnow`; refs use `domainmassrenew`/`domainsrenew` (different) | med |
| 93 | text | All | WHMCS | {$LANG.all} | real key — strip default; `lagom2.3/domain-pricing.tpl:19` `{lang key='all'}` | high |
| 94 | text | Active | WHMCS | {$LANG.statusactive} | real key — strip default (status filter); used theme-wide for "Active" | high |
| 95 | text | Expiring Soon | WHMCS | {$LANG.expiringsoon} | real key — strip default; `nexus/managessl.tpl:28` `{lang key='expiringsoon'}` | high |
| 96 | text | Transferred Away | CUSTOM | {$hadrianLang.domains.transferredAway} | invented `transferredaway`; no WHMCS key found | med |
| 97 | placeholder | Search… | WHMCS | {$LANG.search} | real key — strip default; theme-wide `{$LANG.search}` | high |
| 97 | aria-label | Search | WHMCS | {$LANG.search} | real key — strip default | high |
| 104 | text | Domain | WHMCS | {$LANG.domain} | real key — strip default; `nexus/clientareadomaindetails.tpl` `clientareahostingdomain`/`domain` used bare | high |
| 105 | text | Registered | WHMCS | {$LANG.registered} | real key — strip default; `nexus/clientareaproductdetails.tpl:467` `{lang key='registered'}` | high |
| 106 | text | Expires | CUSTOM | {$hadrianLang.domains.expires} | no bare `expires` key; refs use `nextdue`/`clientareahostingexpirydate`. See ambiguity note | med |
| 107 | text | Status | WHMCS | {$LANG.domainstatus} | **trap**: invented `status` → real `domainstatus`; `lagom2.3/clientareadomains.tpl:118` | high |
| 108 | text | Auto-Renew | WHMCS | {$LANG.domainsautorenew} | **trap**: invented `autorenew` → real `domainsautorenew`; `lagom2.3/clientareadomains.tpl:117` | high |
| 122 | text | Domain | WHMCS | {$LANG.domain} | dup of L104 (DataTable header) | high |
| 123 | text | Registered | WHMCS | {$LANG.registered} | dup of L105 | high |
| 124 | text | Expires | CUSTOM | {$hadrianLang.domains.expires} | dup of L106 | med |
| 125 | text | Status | WHMCS | {$LANG.domainstatus} | dup of L107 trap | high |
| 126 | text | Auto-Renew | WHMCS | {$LANG.domainsautorenew} | dup of L108 trap | high |
| 144 | aria-label | Actions | WHMCS | {$LANG.actions} | real key — strip default; `lagom2.3` `{lang key='actions'}` | high |
| 150 | text | Manage Domain | WHMCS | {$LANG.managedomain} | real key — strip default; `lagom2.3/clientareadomains.tpl:229`, `nexus/clientareaproductdetails.tpl:321` | high |
| 154 | text | Manage Nameservers | WHMCS | {$LANG.domainmanagens} | **trap**: invented `managens` → real `domainmanagens`; `lagom2.3/clientareadomains.tpl:234` | high |
| 158 | text | Edit Contact Information | WHMCS | {$LANG.domaincontactinfoedit} | **trap**: invented `editcontactinfo` → real `domaincontactinfoedit`; `lagom2.3/clientareadomains.tpl:237` | high |
| 162 | text | Auto Renewal Status | WHMCS | {$LANG.domainautorenewstatus} | **trap**: invented `autorenewstatus` → real `domainautorenewstatus`; `lagom2.3/clientareadomains.tpl:240` | high |
| 166 | text | Renew | WHMCS | {$LANG.renew} | real key — strip default; theme-wide `{$LANG.renew}` ("Renew") | high |
| 183 | text | No domains yet | CUSTOM | {$hadrianLang.domains.emptyTitle} | invented `nodomains`; Lagom uses `clientareadomainnone` (diff wording) | med |
| 184 | text | Register a new domain or transfer one you already own — it'll appear here once the order is processed. | CUSTOM | {$hadrianLang.domains.emptySub} | invented `nodomainssub`; no WHMCS key | high |
| 188 | text | Register | WHMCS | {$LANG.registerdomain} | real key — strip default; `lagom2.3/.../layouts-vars.tpl:82` `{$LANG.registerdomain}` | high |
| 192 | text | Transfer | WHMCS | {$LANG.transferdomain} | real key — strip default; `lagom2.3/.../layouts-vars.tpl:84` `{$LANG.transferdomain}` | high |
| 201 | text | Show | WHMCS | {$LANG.show} | real key — strip default (DataTables "Show"); theme-wide | med |
| 202 | aria-label | Rows per page | CUSTOM | {$hadrianLang.domains.rowsPerPage} | invented `rowsperpage`; no WHMCS key | med |
| 207 | text | entries | WHMCS | {$LANG.entries} | real key — strip default (DataTables "entries") | med |
| 214 | text | Showing | WHMCS | {$LANG.showing} | real key — strip default (DataTables "Showing") | med |
| 214 | text | of | WHMCS | {$LANG.of} | real key — strip default (DataTables "of") | med |
| 216 | aria-label | Previous page | CUSTOM | {$hadrianLang.common.previousPage} | invented `previouspage`; pager a11y; no WHMCS key | med |
| 218 | aria-label | Next page | CUSTOM | {$hadrianLang.common.nextPage} | invented `nextpage`; pager a11y; no WHMCS key | med |
| 228 | text | Domains | WHMCS | {$LANG.navdomains} | dup of L67 (sidebar heading) | high |
| 231 | text | My Domains | CUSTOM | {$hadrianLang.domains.myDomains} | invented `mydomains`; no bare WHMCS key | med |
| 236 | text | Register a Domain | WHMCS | {$LANG.registeradomain} | real key — strip default; matches `registeradomain` exactly | high |
| 240 | text | Transfer a Domain | WHMCS | {$LANG.transferadomain} | close to real `transferadomain` ("Transfer a Domain") | med |
| 244 | text | Bulk Management | CUSTOM | {$hadrianLang.domains.bulkManagement} | invented `bulkmanagement` (short); page title uses `domainbulkmanagement` (diff) | med |
| 248 | text | Domain Pricing | CUSTOM | {$hadrianLang.domains.domainPricing} | invented `domainpricing`; no bare WHMCS key found | med |
| 252 | text | WHOIS Lookup | CUSTOM | {$hadrianLang.domains.whoisLookup} | invented `whoislookup`; no WHMCS key | med |

_Note L86 `domain`/`domains`: the inline plural uses `domainsingular`/`domainsplural`; both invented → CUSTOM (`singular`/`plural`)._

---

### hadrian/templates/hadrian/core/pages/clientareadomaindetails/default/default.tpl
| Line | Type | Current text | Class | Proposed reference | Evidence / Notes | Conf |
|------|------|--------------|-------|--------------------|------------------|------|
| 30 | text | Domain | WHMCS | {$LANG.domain} | real key — strip default (eyebrow) | high |
| 32 | text | Registered | WHMCS | {$LANG.clientareahostingregdate} | real key — strip default; `lagom2.3/clientareadomaindetails.tpl:51` `{$LANG.clientareahostingregdate}` | high |
| 41 | text | This domain has an unpaid invoice. | CUSTOM | {$hadrianLang.domains.unpaidInvoice} | `$unpaidInvoiceMessage` is the var; `|default` literal is fallback copy → rebadge | med |
| 42 | text | Pay invoice | WHMCS | {$LANG.payInvoice} | **casing trap**: `payinvoice`→`payInvoice`; `lagom2.3/clientareadomaindetails.tpl:17` `{lang key='payInvoice'}` | high |
| 50 | text | Action completed successfully. | WHMCS | {$LANG.moduleactionsuccess} | real key — strip default; `lagom2.3/clientareadomaindetails.tpl:5` `$LANG.moduleactionsuccess` | high |
| 55 | text | Action failed. | WHMCS | {$LANG.moduleactionfailed} | real key — strip default; `lagom2.3/clientareadomaindetails.tpl:7` | high |
| 63 | text | This domain is not active and cannot be managed. | WHMCS | {$LANG.domainCannotBeManagedUnlessActive} | real key — strip default; `lagom2.3/clientareadomaindetails.tpl:26` | high |
| 72 | text | Overview | WHMCS | {$LANG.overview} | real key — strip default; theme/nexus `{lang key='overview'}` | high |
| 73 | text | Auto-renew | WHMCS | {$LANG.domainsautorenew} | real key — strip default; `lagom2.3/clientareadomaindetails.tpl:191` | high |
| 74 | text | Nameservers | WHMCS | {$LANG.domainnameservers} | real key — strip default; `nexus/clientareadomaindetails.tpl:236` `{lang key='domainnameservers'}` | high |
| 75 | text | Registrar Lock | WHMCS | {$LANG.domainregistrarlock} | real key — strip default; `lagom2.3/clientareadomaindetails.tpl:286` | high |
| 76 | text | Addons | WHMCS | {$LANG.domainaddons} | real key — strip default; `lagom2.3/clientareadomaindetails.tpl:357` | high |
| 84 | text | Domain | WHMCS | {$LANG.clientareahostingdomain} | real key — strip default; `nexus` `clientareahostingdomain` | high |
| 90 | text | First payment | WHMCS | {$LANG.firstpaymentamount} | real key — strip default; `lagom2.3/clientareadomaindetails.tpl:59` | high |
| 96 | text | Registration date | WHMCS | {$LANG.clientareahostingregdate} | real key — strip default; dup of L32 | high |
| 102 | text | Recurring | WHMCS | {$LANG.recurringamount} | real key — strip default; `lagom2.3/clientareadomaindetails.tpl:63` | high |
| 103 | text | yrs | WHMCS | {$LANG.orderyears} | real key — strip default; `lagom2.3/clientareadomaindetails.tpl:64` `{$LANG.orderyears}` | high |
| 108 | text | Next due date | WHMCS | {$LANG.clientareahostingnextduedate} | real key — strip default; `lagom2.3/clientareadomaindetails.tpl:55` | high |
| 114 | text | Payment method | WHMCS | {$LANG.orderpaymentmethod} | real key — strip default; `lagom2.3/clientareadomaindetails.tpl:67` | high |
| 123 | text | SSL status | WHMCS | {$LANG.sslState.sslStatus} | real key — strip default; `lagom2.3/clientareadomaindetails.tpl:82` `{$LANG.sslState.sslStatus}` | high |
| 143 | text | Quick actions | WHMCS | {$LANG.doToday} | real key — strip default; `lagom2.3/clientareadomaindetails.tpl:153` `{$LANG.doToday}` | high |
| 148 | text | Change nameservers | WHMCS | {$LANG.changeDomainNS} | real key — strip default; `lagom2.3/clientareadomaindetails.tpl:159` | high |
| 154 | text | Update WHOIS contact | WHMCS | {$LANG.updateWhoisContact} | real key — strip default; `lagom2.3/clientareadomaindetails.tpl:166` | high |
| 160 | text | Change registrar lock | WHMCS | {$LANG.changeRegLock} | real key — strip default; `lagom2.3/clientareadomaindetails.tpl:173` | high |
| 166 | text | Renew domain | WHMCS | {$LANG.domainrenew} | real key — strip default; `lagom2.3/clientareadomaindetails.tpl:180` | high |
| 179 | text | Changes saved. | WHMCS | {$LANG.changessavedsuccessfully} | real key — strip default; `lagom2.3/clientareadomaindetails.tpl:196` | high |
| 182 | text | Auto-renew automatically renews this domain before it expires… | WHMCS | {$LANG.domainrenewexp} | real key — strip default; `lagom2.3/clientareadomaindetails.tpl:192` | high |
| 185 | text | Auto-renew status | WHMCS | {$LANG.domainautorenewstatus} | real key — strip default; `lagom2.3/clientareadomaindetails.tpl:203` | high |
| 187 | text | Enabled | WHMCS | {$LANG.domainsautorenewenabled} | real key — strip default; `lagom2.3/clientareadomaindetails.tpl:185` | high |
| 187 | text | Disabled | WHMCS | {$LANG.domainsautorenewdisabled} | real key — strip default; `lagom2.3/clientareadomaindetails.tpl:187` | high |
| 197 | text | Disable auto-renew | WHMCS | {$LANG.domainsautorenewdisable} | real key — strip default; `lagom2.3/bulkdomainmanagement.tpl:111` | high |
| 200 | text | Enable auto-renew | WHMCS | {$LANG.domainsautorenewenable} | real key — strip default; `lagom2.3/bulkdomainmanagement.tpl:106` | high |
| 228 | text | Choose between your registrar's default nameservers, or specify your own. | WHMCS | {$LANG.domainnsexp} | real key — strip default; `lagom2.3/clientareadomaindetails.tpl:226` | high |
| 237 | text | Use registrar defaults | WHMCS | {$LANG.nschoicedefault} | real key — strip default; `lagom2.3/clientareadomaindetails.tpl:248` | high |
| 241 | text | Use custom nameservers | WHMCS | {$LANG.nschoicecustom} | real key — strip default; `lagom2.3/clientareadomaindetails.tpl:258` | high |
| 247 | text | Nameserver | WHMCS | {$LANG.clientareanameserver} | real key — strip default; `lagom2.3/clientareadomaindetails.tpl:267` | high |
| 254 | text | Save changes | WHMCS | {$LANG.changenameservers} | real key — strip default; `lagom2.3/clientareadomaindetails.tpl:277` (value="{$LANG.changenameservers}") | high |
| 267 | text | Changes saved. | WHMCS | {$LANG.changessavedsuccessfully} | dup of L179 | high |
| 277 | text | Registrar Lock prevents unauthorized transfer of your domain to another registrar. | WHMCS | {$LANG.domainlockingexp} | real key — strip default; `lagom2.3/clientareadomaindetails.tpl:287` | high |
| 280 | text | Registrar Lock | WHMCS | {$LANG.domainreglockstatus} | real key — strip default; `lagom2.3/clientareadomaindetails.tpl:281` `domainreglockstatus` | high |
| 282 | text | Locked | WHMCS | {$LANG.locked} | real key — strip default (generic "Locked"); refs use `domaincurrentlylocked`-family, `locked` generic | med |
| 282 | text | Unlocked | WHMCS | {$LANG.unlocked} | real key — strip default; generic "Unlocked" | med |
| 291 | text | Disable lock | WHMCS | {$LANG.domainreglockdisable} | real key — strip default; `lagom2.3/bulkdomainmanagement.tpl:158` | high |
| 293 | text | Enable lock | WHMCS | {$LANG.domainreglockenable} | real key — strip default; `lagom2.3/bulkdomainmanagement.tpl:156` | high |
| 302 | text | Enable additional services to enhance your domain. | WHMCS | {$LANG.domainaddonsinfo} | real key — strip default; `lagom2.3/clientareadomaindetails.tpl:358` | high |
| 311 | text | ID Protection | WHMCS | {$LANG.domainidprotection} | real key — strip default; `lagom2.3/clientareadomaindetails.tpl:367` | high |
| 312 | text | Hide your contact details from public WHOIS lookups. | WHMCS | {$LANG.domainaddonsidprotectioninfo} | real key — strip default; `lagom2.3/clientareadomaindetails.tpl:372` | high |
| 320 | text | Enabled | WHMCS | {$LANG.enabled} | real key — strip default; `lagom2.3` `{lang key='enabled'}` | high |
| 321 | text | Disable | WHMCS | {$LANG.disable} | real key — strip default; `lagom2.3/clientareadomaindetails.tpl:385` `{$LANG.disable}` | high |
| 324 | text | Add | WHMCS | {$LANG.domainaddonsbuynow} | **trap**: real `domainaddonsbuynow`="Buy now" but our literal is "Add"; key is right, the literal is a wrong reuse — value should read "Buy now" | med |
| 337 | text | DNS Management | WHMCS | {$LANG.domainaddonsdnsmanagement} | real key — strip default; `lagom2.3/clientareadomaindetails.tpl:409` | high |
| 338 | text | Edit DNS records (A, MX, CNAME, TXT) directly from your client area. | WHMCS | {$LANG.domainaddonsdnsmanagementinfo} | real key — strip default; `lagom2.3/clientareadomaindetails.tpl:414` | high |
| 346 | text | Manage | WHMCS | {$LANG.manage} | real key — strip default; `lagom2.3/clientareadomaindetails.tpl:420` `{$LANG.manage}` | high |
| 347 | text | Disable | WHMCS | {$LANG.disable} | dup of L321 | high |
| 350 | text | Add | WHMCS | {$LANG.domainaddonsbuynow} | dup of L324 trap | med |
| 363 | text | Email Forwarding | WHMCS | {$LANG.domainemailforwarding} | real key — strip default; `lagom2.3/clientareadomaindetails.tpl:453` | high |
| 364 | text | Forward incoming mail from your domain to any address. | WHMCS | {$LANG.domainaddonsemailforwardinginfo} | real key — strip default; `lagom2.3/clientareadomaindetails.tpl:458` | high |
| 372 | text | Manage | WHMCS | {$LANG.manage} | dup of L346 | high |
| 373 | text | Disable | WHMCS | {$LANG.disable} | dup of L321 | high |
| 376 | text | Add | WHMCS | {$LANG.domainaddonsbuynow} | dup of L324 trap | med |
| 391 | text | Domain | WHMCS | {$LANG.domain} | real key — strip default (sidebar heading) | high |
| 394 | text | All domains | CUSTOM | {$hadrianLang.domains.allDomains} | invented `alldomains` (short); no bare WHMCS key | med |
| 399 | text | DNS records | WHMCS | {$LANG.domaindnsmanagement} | **trap**: invented `dnsmanagement`→real `domaindnsmanagement` ("DNS Management") | high |
| 405 | text | Email forwarders | WHMCS | {$LANG.domainemailforwarding} | **trap**: invented `emailforwarding`→real `domainemailforwarding` ("Email Forwarding") | high |
| 411 | text | Glue records | WHMCS | {$LANG.privatenameservers} | close to real `privatenameservers` ("Private Nameservers"); wording shift OK | med |
| 417 | text | EPP code | CUSTOM | {$hadrianLang.domains.eppCode} | invented `eppcode` (short); page uses `domaingeteppcode` (diff) | med |
| 423 | text | WHOIS contact | CUSTOM | {$hadrianLang.domains.whoisContact} | invented `whoismodify`; no bare WHMCS key found | med |

---

### hadrian/templates/hadrian/core/pages/clientareadomaindns/default/default.tpl
| Line | Type | Current text | Class | Proposed reference | Evidence / Notes | Conf |
|------|------|--------------|-------|--------------------|------------------|------|
| 15 | text | DNS records | WHMCS | {$LANG.domaindnsmanagement} | real key — strip default (value "DNS Management"); `lagom2.3/clientareadomaindns.tpl:6` | high |
| 16 | text | Add, edit and remove DNS records for this domain. Changes propagate within a few minutes. | WHMCS | {$LANG.domaindnsmanagementdesc} | real key — strip default; `lagom2.3/clientareadomaindns.tpl:7` | high |
| 45 | text | Host | WHMCS | {$LANG.domaindnshostname} | real key — strip default; `lagom2.3/clientareadomaindns.tpl:25` | high |
| 46 | text | Type | WHMCS | {$LANG.domaindnsrecordtype} | real key — strip default; `lagom2.3/clientareadomaindns.tpl:26` | high |
| 47 | text | Value | WHMCS | {$LANG.domaindnsaddress} | real key — strip default; `lagom2.3/clientareadomaindns.tpl:27` | high |
| 48 | text | Priority | WHMCS | {$LANG.domaindnspriority} | real key — strip default; `lagom2.3/clientareadomaindns.tpl:28` | high |
| 106 | text | Priority only applies to MX records. | WHMCS | {$LANG.domaindnsmxonly} | real key — strip default; `lagom2.3/clientareadomaindns.tpl:74` | high |
| 109 | text | Save changes | WHMCS | {$LANG.clientareasavechanges} | real key — strip default; `lagom2.3/clientareadomaindns.tpl:77` | high |
| 110 | text | Cancel | WHMCS | {$LANG.clientareacancel} | real key — strip default; `lagom2.3/clientareadomaindns.tpl:77` | high |
| 31 | text | DNS for this domain is managed externally by the registrar. | CUSTOM | {$hadrianLang.domains.dnsExternal} | invented `dnsexternalmanagement`; no WHMCS key found | med |
| 120 | text | Domain | WHMCS | {$LANG.domain} | real key — strip default (sidebar heading) | high |
| 123 | text | Domain details | CUSTOM | {$hadrianLang.domains.domainDetails} | invented `domaindetails` (short); no bare WHMCS key | med |
| 127 | text | DNS records | WHMCS | {$LANG.domaindnsmanagement} | **trap**: invented `dnsmanagement`→real `domaindnsmanagement` | high |
| 131 | text | Email forwarders | WHMCS | {$LANG.domainemailforwarding} | **trap**: invented `emailforwarding`→real `domainemailforwarding` | high |
| 135 | text | Common record types | CUSTOM | {$hadrianLang.domains.dnsHelpTitle} | **trap**: `help` is a real key but ="Help"; our literal is invented → rebadge (do NOT strip to `{$LANG.help}`) | high |
| 137 | text | IPv4 address (e.g. 192.0.2.1) | CUSTOM | {$hadrianLang.domains.dnsHelpA} | help-card body; no WHMCS key | med |
| 138 | text | IPv6 address (e.g. 2001:db8::1) | CUSTOM | {$hadrianLang.domains.dnsHelpAaaa} | help-card body; no WHMCS key | med |
| 139 | text | Alias to another hostname | CUSTOM | {$hadrianLang.domains.dnsHelpCname} | help-card body; no WHMCS key | med |
| 140 | text | Mail server with priority | CUSTOM | {$hadrianLang.domains.dnsHelpMx} | help-card body; no WHMCS key | med |
| 141 | text | Verification / SPF / DKIM strings | CUSTOM | {$hadrianLang.domains.dnsHelpTxt} | help-card body; no WHMCS key | med |

_SKIP: `<option>` codes A/AAAA/CNAME/MX/MXE/TXT/URL/FRAME (L61-68, L89-96) — DNS record-type protocol tokens, not translatable. `<dt>` glossary terms A/AAAA/CNAME/MX/TXT (L137-141) likewise protocol tokens (only the `<dd>` definitions are tokenized above)._

---

### hadrian/templates/hadrian/core/pages/clientareadomaincontactinfo/default/default.tpl
| Line | Type | Current text | Class | Proposed reference | Evidence / Notes | Conf |
|------|------|--------------|-------|--------------------|------------------|------|
| 16 | text | WHOIS contact information | WHMCS | {$LANG.domaincontactinfo} | real key — strip default; `lagom2.3/clientareadomaincontactinfo.tpl:6` | high |
| 17 | text | Update the contact details that appear in the public WHOIS database for this domain. | WHMCS | {$LANG.whoisContactWarning} | real key — strip default; `lagom2.3/clientareadomaincontactinfo.tpl:7` | high |
| 23 | text | Changes saved successfully. | WHMCS | {$LANG.changessavedsuccessfully} | real key — strip default; `lagom2.3/clientareadomaincontactinfo.tpl:11` | high |
| 30 | text | A contact change is pending registry confirmation. | CUSTOM | {$hadrianLang.domains.contactPending} | `$pendingMessage` is the var; `|default` is fallback copy (close to `domains.contactChangePending`) | med |
| 63 | text | Use an existing contact | WHMCS | {$LANG.domaincontactusexisting} | real key — strip default; `lagom2.3/clientareadomaincontactinfo.tpl:43` | high |
| 67 | text | Use the details below | WHMCS | {$LANG.domaincontactusecustom} | real key — strip default; `lagom2.3/clientareadomaincontactinfo.tpl:70` | high |
| 71 | text | Choose contact | WHMCS | {$LANG.domaincontactchoose} | real key — strip default; `lagom2.3/clientareadomaincontactinfo.tpl:52` | high |
| 73 | text | Primary account holder | WHMCS | {$LANG.domaincontactprimary} | real key — strip default; `lagom2.3/clientareadomaincontactinfo.tpl:54` | high |
| 96 | text | Save changes | WHMCS | {$LANG.clientareasavechanges} | real key — strip default; `lagom2.3/clientareadomaincontactinfo.tpl:98` | high |
| 97 | text | Cancel | WHMCS | {$LANG.clientareacancel} | real key — strip default; `lagom2.3/clientareadomaincontactinfo.tpl:99` | high |
| 100 | text | No contact details available for this domain. | CUSTOM | {$hadrianLang.domains.noContactDetails} | invented `nocontactdetails`; no WHMCS key found | med |
| 108 | text | Domain | WHMCS | {$LANG.domain} | real key — strip default (sidebar heading) | high |
| 111 | text | Domain details | CUSTOM | {$hadrianLang.domains.domainDetails} | dup; invented `domaindetails` (short) | med |
| 115 | text | WHOIS contact | CUSTOM | {$hadrianLang.domains.whoisContact} | dup; invented `whoismodify` | med |

_Note: tab labels (L52) and field labels (L86) come from `$category`/`$contactdetailstranslations` — WHMCS-supplied data, not hardcoded. SKIP._

---

### hadrian/templates/hadrian/core/pages/clientareadomainemailforwarding/default/default.tpl
| Line | Type | Current text | Class | Proposed reference | Evidence / Notes | Conf |
|------|------|--------------|-------|--------------------|------------------|------|
| 14 | text | Email forwarding | WHMCS | {$LANG.domainemailforwarding} | real key — strip default; `lagom2.3/clientareadomainemailforwarding.tpl:6` | high |
| 15 | text | Forward mail sent to any address at your domain to a real inbox elsewhere. | WHMCS | {$LANG.domainemailforwardingdesc} | real key — strip default; `lagom2.3/clientareadomainemailforwarding.tpl:7` | high |
| 41 | text | Prefix | WHMCS | {$LANG.domainemailforwardingprefix} | real key — strip default; `lagom2.3/clientareadomainemailforwarding.tpl:25` | high |
| 42 | text | At | CUSTOM | {$hadrianLang.domains.emailAt} | invented `at`; no WHMCS key anywhere (false-positive was "Vat") | med |
| 43 | text | Forward to | WHMCS | {$LANG.domainemailforwardingforwardto} | real key — strip default; `lagom2.3/clientareadomainemailforwarding.tpl:27` | high |
| 67 | text | Save changes | WHMCS | {$LANG.clientareasavechanges} | real key — strip default; `lagom2.3/clientareadomainemailforwarding.tpl:47` | high |
| 68 | text | Cancel | WHMCS | {$LANG.clientareacancel} | real key — strip default; `lagom2.3/clientareadomainemailforwarding.tpl:47` | high |
| 77 | text | Domain | WHMCS | {$LANG.domain} | real key — strip default (sidebar heading) | high |
| 80 | text | Domain details | CUSTOM | {$hadrianLang.domains.domainDetails} | dup; invented `domaindetails` (short) | med |
| 84 | text | DNS records | WHMCS | {$LANG.domaindnsmanagement} | **trap**: invented `dnsmanagement`→real `domaindnsmanagement` | high |
| 88 | text | Email forwarders | WHMCS | {$LANG.domainemailforwarding} | **trap**: invented `emailforwarding`→real `domainemailforwarding` | high |

---

### hadrian/templates/hadrian/core/pages/clientareadomaingetepp/default/default.tpl
| Line | Type | Current text | Class | Proposed reference | Evidence / Notes | Conf |
|------|------|--------------|-------|--------------------|------------------|------|
| 14 | text | Transfer code (EPP) | WHMCS | {$LANG.domaingeteppcode} | real key — strip default; `lagom2.3/clientareadomaingetepp.tpl:6` | high |
| 15 | text | The EPP/auth code is required to transfer this domain to another registrar. | WHMCS | {$LANG.domaingeteppcodeexplanation} | real key — strip default; `lagom2.3/clientareadomaingetepp.tpl:7` | high |
| 25 | text | Could not retrieve EPP code | WHMCS | {$LANG.domaingeteppcodefailure} | real key — strip default; `lagom2.3/clientareadomaingetepp.tpl:11` | high |
| 33 | text | Your transfer code | WHMCS | {$LANG.domaingeteppcodeis} | real key — strip default; `lagom2.3/clientareadomaingetepp.tpl:13` | high |
| 35 | text | Copy code | WHMCS | {$LANG.copy} | real key — strip default (value "Copy"); `lagom2.3` `{lang key='copy'}` | med |
| 36 | text | Keep this code private. Anyone with it can initiate a transfer of your domain. | CUSTOM | {$hadrianLang.domains.eppWarning} | invented `domaingeteppwarning`; no WHMCS key | high |
| 43 | text | Check your email | WHMCS | {$LANG.checkyouremail} | real key — strip default; theme-wide `checkyouremail` (auth flows) | med |
| 44 | text | For security, the transfer code has been emailed to the registered domain contact. | WHMCS | {$LANG.domaingeteppcodeemailconfirmation} | real key — strip default; `lagom2.3/clientareadomaingetepp.tpl:15` | high |
| 50 | text | How a transfer works | CUSTOM | {$hadrianLang.domains.howTransferWorks} | invented `howtransferworks`; no WHMCS key | high |
| 52 | text | Unlock the domain at the current registrar. | CUSTOM | {$hadrianLang.domains.eppStep1} | invented `eppstep1`; no WHMCS key | high |
| 53 | text | Request the EPP/auth code on this page. | CUSTOM | {$hadrianLang.domains.eppStep2} | invented `eppstep2`; no WHMCS key | high |
| 54 | text | Submit a transfer request at the gaining registrar with that code. | CUSTOM | {$hadrianLang.domains.eppStep3} | invented `eppstep3`; no WHMCS key | high |
| 55 | text | Approve the transfer email from the current registrar (usually within 5 days). | CUSTOM | {$hadrianLang.domains.eppStep4} | invented `eppstep4`; no WHMCS key | high |
| 63 | text | Domain | WHMCS | {$LANG.domain} | real key — strip default (sidebar heading) | high |
| 66 | text | Domain details | CUSTOM | {$hadrianLang.domains.domainDetails} | dup; invented `domaindetails` (short) | med |
| 70 | text | EPP code | CUSTOM | {$hadrianLang.domains.eppCode} | dup; invented `eppcode` (short) | med |
| 86 | js-string | Copied | CUSTOM | {$hadrianLang.domains.copied} | JS `btn.textContent='Copied'` (also L91); inject via seeded lang or strip-tagged literal | med |

---

### hadrian/templates/hadrian/core/pages/clientareadomainregisterns/default/default.tpl
| Line | Type | Current text | Class | Proposed reference | Evidence / Notes | Conf |
|------|------|--------------|-------|--------------------|------------------|------|
| 12 | text | Glue records | WHMCS | {$LANG.privatenameservers} | close to real `privatenameservers` ("Private Nameservers"); wording shift OK | med |
| 13 | text | Register your own child nameservers under this domain (e.g. ns1.yourdomain.com). | WHMCS | {$LANG.domainregisternsexplanation} | real key — strip default; `lagom2.3/clientareadomainregisterns.tpl:9` | high |
| 32 | text | Register a new nameserver | WHMCS | {$LANG.domainregisternsreg} | real key — strip default; `lagom2.3/clientareadomainregisterns.tpl:17` | high |
| 35 | text | Nameserver | WHMCS | {$LANG.domainregisternsns} | real key — strip default; `lagom2.3/clientareadomainregisterns.tpl:26` | high |
| 42 | text | IP address | WHMCS | {$LANG.domainregisternsip} | real key — strip default; `lagom2.3/clientareadomainregisterns.tpl:39` | high |
| 46 | text | Register | WHMCS | {$LANG.register} | real key — strip default (generic "Register"); `lagom2.3/includes/login/register.tpl:11` `{$LANG.register}` | med |
| 55 | text | Modify a nameserver | WHMCS | {$LANG.domainregisternsmod} | real key — strip default; `lagom2.3/clientareadomainregisterns.tpl:54` | high |
| 58 | text | Nameserver | WHMCS | {$LANG.domainregisternsns} | dup of L35 | high |
| 65 | text | Current IP | WHMCS | {$LANG.domainregisternscurrentip} | real key — strip default; `lagom2.3/clientareadomainregisterns.tpl:76` | high |
| 69 | text | New IP | WHMCS | {$LANG.domainregisternsnewip} | real key — strip default; `lagom2.3/clientareadomainregisterns.tpl:82` | high |
| 73 | text | Save changes | WHMCS | {$LANG.clientareasavechanges} | real key — strip default; `lagom2.3/clientareadomainregisterns.tpl:89` | high |
| 82 | text | Delete a nameserver | WHMCS | {$LANG.domainregisternsdel} | real key — strip default; `lagom2.3/clientareadomainregisterns.tpl:97` | high |
| 85 | text | Nameserver | WHMCS | {$LANG.domainregisternsns} | dup of L35 | high |
| 92 | text | Delete | CUSTOM | {$hadrianLang.domains.delete} | `delete` not on any ref domain page; likely real generic WHMCS key but no evidence — see ambiguity note | med |
| 99 | text | Domain | WHMCS | {$LANG.domain} | real key — strip default (sidebar heading) | high |
| 102 | text | Domain details | CUSTOM | {$hadrianLang.domains.domainDetails} | dup; invented `domaindetails` (short) | med |
| 106 | text | Glue records | WHMCS | {$LANG.privatenameservers} | dup of L12 | med |

---

### hadrian/templates/hadrian/core/pages/clientareadomainaddons/default/default.tpl
| Line | Type | Current text | Class | Proposed reference | Evidence / Notes | Conf |
|------|------|--------------|-------|--------------------|------------------|------|
| 17 | text | DNS management | WHMCS | {$LANG.domainaddonsdnsmanagement} | real key — strip default; `lagom2.3/clientareadomaindetails.tpl:409` | high |
| 18 | text | Edit DNS records (A, MX, CNAME, TXT) directly from your client area. | WHMCS | {$LANG.domainaddonsdnsmanagementinfo} | real key — strip default; `lagom2.3/clientareadomaindetails.tpl:414` | high |
| 22 | text | Email forwarding | WHMCS | {$LANG.domainemailforwarding} | real key — strip default; `lagom2.3/clientareadomainaddons.tpl` family | high |
| 23 | text | Forward mail sent to your domain to a real inbox elsewhere. | WHMCS | {$LANG.domainaddonsemailforwardinginfo} | real key — strip default; `lagom2.3/clientareadomaindetails.tpl:458` | high |
| 27 | text | ID Protection | WHMCS | {$LANG.domainidprotection} | real key — strip default; `lagom2.3/clientareadomaindetails.tpl:367` | high |
| 28 | text | Hide your contact details from public WHOIS lookups. | WHMCS | {$LANG.domainaddonsidprotectioninfo} | real key — strip default; `lagom2.3/clientareadomaindetails.tpl:372` | high |
| 56 | text | Price | WHMCS | {$LANG.domainaddonsbuynow} | **trap**: real `domainaddonsbuynow`="Buy now" but literal here is "Price" (wrong reuse). Consider CUSTOM `price` if a "Price" label is wanted | med |
| 57 | text | /yr | WHMCS | {$LANG.domainaddonsperyear} | real key — strip default; `lagom2.3/clientareadomainaddons.tpl:24` | high |
| 64 | text | The addon has been cancelled successfully. | WHMCS | {$LANG.domainaddonscancelsuccess} | real key — strip default; `lagom2.3/clientareadomainaddons.tpl:81` | high |
| 69 | text | Action failed. Please contact support. | WHMCS | {$LANG.domainaddonscancelfailed} | real key — strip default; `lagom2.3/clientareadomainaddons.tpl:83` | high |
| 78 | text | Buy now | WHMCS | {$LANG.domainaddonsbuynow} | real key — strip default; `lagom2.3/clientareadomainaddons.tpl:24` (value uses `domainaddonsbuynow`) | high |
| 81 | text | Are you sure you want to disable this addon? | WHMCS | {$LANG.domainaddonscancelareyousure} | real key — strip default; `lagom2.3/clientareadomainaddons.tpl:86` | high |
| 82 | text | Confirm cancellation | WHMCS | {$LANG.domainaddonsconfirm} | real key — strip default; `lagom2.3/clientareadomainaddons.tpl:89` | high |
| 84 | text | Back to domain | WHMCS | {$LANG.clientareabacklink} | real key — strip default; `lagom2.3/clientareadomainaddons.tpl:25` | high |

---

### hadrian/templates/hadrian/core/pages/bulkdomainmanagement/default/default.tpl
| Line | Type | Current text | Class | Proposed reference | Evidence / Notes | Conf |
|------|------|--------------|-------|--------------------|------------------|------|
| 43 | text | Domains | WHMCS | {$LANG.domains} | `$LANG.domains` is an array on this install (prints "Array") — see MEMORY caveat; prefer {$LANG.navdomains} | med |
| 44 | text | Bulk domain management | WHMCS | {$LANG.domainbulkmanagement} | real key — strip default; nexus/lagom `domainbulkmanagement*` family | med |
| 45 | text | Apply a change to all the domains you selected at once. | CUSTOM | {$hadrianLang.domains.bulkIntro} | invented `domainbulkmanagementintro`; no WHMCS key | med |
| 56 | text | Please fix the following: | WHMCS | {$LANG.clientareaerrors} | real key — strip default; `lagom2.3/bulkdomainmanagement.tpl:17` | high |
| 61 | text | Changes saved successfully. | WHMCS | {$LANG.changessavedsuccessfully} | real key — strip default; `lagom2.3/bulkdomainmanagement.tpl:28` | high |
| 66 | text | These changes will affect | WHMCS | {$LANG.domainbulkmanagementchangesaffect} | real key — strip default; `lagom2.3/bulkdomainmanagement.tpl:33` | high |
| 84 | text | Change nameservers | WHMCS | {$LANG.changenameservers} | real key — strip default; `lagom2.3/bulkdomainmanagement.tpl:80` | high |
| 88 | text | Use default nameservers | WHMCS | {$LANG.nschoicedefault} | real key — strip default; `lagom2.3/bulkdomainmanagement.tpl:51` | high |
| 92 | text | Use custom nameservers | WHMCS | {$LANG.nschoicecustom} | real key — strip default; `lagom2.3/bulkdomainmanagement.tpl:61` | high |
| 96-100 | text | Nameserver (×5) | WHMCS | {$LANG.clientareanameserver} | real key — strip default; `lagom2.3/bulkdomainmanagement.tpl:70` (one key, 5 uses) | high |
| 103 | text | Change nameservers | WHMCS | {$LANG.changenameservers} | dup of L84 | high |
| 104 | text | Cancel | WHMCS | {$LANG.cancel} | real key — strip default; generic `cancel` ("Cancel") | high |
| 108 | text | Auto-renew | WHMCS | {$LANG.domainsautorenew} | real key — strip default; `lagom2.3/bulkdomainmanagement.tpl:90` | high |
| 109 | text | We recommend keeping auto-renew enabled so your domains never expire. | WHMCS | {$LANG.domainautorenewrecommend} | real key — strip default; `lagom2.3/bulkdomainmanagement.tpl:94` | high |
| 111 | text | Enable auto-renew | WHMCS | {$LANG.domainsautorenewenable} | real key — strip default; `lagom2.3/bulkdomainmanagement.tpl:106` | high |
| 112 | text | or | WHMCS | {$LANG.or} | real key — strip default; `lagom2.3` `$LANG.or` (3 uses) | high |
| 113 | text | Disable auto-renew | WHMCS | {$LANG.domainsautorenewdisable} | real key — strip default; `lagom2.3/bulkdomainmanagement.tpl:111` | high |
| 117 | text | Registrar lock | WHMCS | {$LANG.domainregistrarlock} | real key — strip default; `lagom2.3/bulkdomainmanagement.tpl:139` | high |
| 118 | text | Registrar lock helps prevent unauthorized domain transfers. | WHMCS | {$LANG.domainreglockrecommend} | real key — strip default; `lagom2.3/bulkdomainmanagement.tpl:143` | high |
| 120 | text | Enable registrar lock | WHMCS | {$LANG.domainreglockenable} | real key — strip default; `lagom2.3/bulkdomainmanagement.tpl:156` | high |
| 121 | text | or | WHMCS | {$LANG.or} | dup of L112 | high |
| 122 | text | Disable registrar lock | WHMCS | {$LANG.domainreglockdisable} | real key — strip default; `lagom2.3/bulkdomainmanagement.tpl:158` | high |
| 126 | text | Contact information | WHMCS | {$LANG.domaincontactinfo} | real key — strip default; `lagom2.3/clientareadomaincontactinfo.tpl:6` ("WHOIS Contact Information") | med |
| 127 | text | WHOIS contact details are managed per domain. Open a domain to update its registrant, admin, tech and billing contacts. | CUSTOM | {$hadrianLang.domains.bulkContactInfo} | invented `domainbulkcontactinfo`; no WHMCS key | high |
| 129 | text | Go to my domains | CUSTOM | {$hadrianLang.domains.goToMyDomains} | invented `clientareanavdomains`; no bare WHMCS key | med |
| 146 | text | No domains selected | CUSTOM | {$hadrianLang.domains.bulkNoneTitle} | invented `domainbulkmanagementnodomains`; no WHMCS key | high |
| 147 | text | Select one or more domains from your domains list, then choose a bulk action. | CUSTOM | {$hadrianLang.domains.bulkNoneSub} | invented `domainbulkmanagementnodomainssub`; no WHMCS key | high |
| 148 | text | My domains | CUSTOM | {$hadrianLang.domains.myDomains} | dedupe with clientareadomains `myDomains` (`clientareanavdomains` literal) | med |

---

### hadrian/templates/hadrian/core/pages/domain-pricing/default/default.tpl
| Line | Type | Current text | Class | Proposed reference | Evidence / Notes | Conf |
|------|------|--------------|-------|--------------------|------------------|------|
| 47 | text | Domains | WHMCS | {$LANG.navdomains} | real key — strip default (eyebrow); `$LANG.domains` is array-typed (avoid) | med |
| 48 | text | Domain pricing | WHMCS | {$LANG.domainpricing} | invented? `domainpricing` not found bare in refs — but page name; treat med. Could be CUSTOM | med |
| 49 | text | Registration, transfer and renewal prices for every extension we offer. | CUSTOM | {$hadrianLang.domains.pricingIntro} | invented `domainpricingintro`; no WHMCS key | high |
| 57 | placeholder | Search extensions, e.g. .com | CUSTOM | {$hadrianLang.domains.searchExtensions} | invented `searchdomain` (no such key; `searchdomains` is a module name) | high |
| 60 | aria-label | Category | WHMCS | {$LANG.category} | real key — strip default; `nexus/domain-pricing.tpl:83` `{lang key='category'}` | high |
| 61 | text | All categories | WHMCS | {$LANG.all} | **trap**: real `all`="All"; our literal adds "categories". Key right, literal extends — `lagom2.3/domain-pricing.tpl:19` | med |
| 73 | text | Extension | WHMCS | {$LANG.domaintld} | real key — strip default; `nexus/domain-pricing.tpl:36` `{lang key='domaintld'}` | high |
| 74 | text | Category | WHMCS | {$LANG.category} | dup of L60 (table header) | high |
| 75 | text | Register | WHMCS | {$LANG.pricing.register} | **trap**: invented `pricingregister`→dotted real `pricing.register`; `nexus/domain-pricing.tpl:39` | high |
| 76 | text | Transfer | WHMCS | {$LANG.pricing.transfer} | **trap**: invented `pricingtransfer`→`pricing.transfer`; `nexus/domain-pricing.tpl:40` | high |
| 77 | text | Renew | WHMCS | {$LANG.pricing.renewal} | **trap**: invented `pricingrenewal`→`pricing.renewal`; `nexus/domain-pricing.tpl:41` | high |
| 89 | text | Category: | WHMCS | {$LANG.category} | dup; responsive `.dp-label` repeat of L60 | high |
| 90 | text | Register: | WHMCS | {$LANG.pricing.register} | dup of L75 trap | high |
| 91 | text | Transfer: | WHMCS | {$LANG.pricing.transfer} | dup of L76 trap | high |
| 92 | text | Renew: | WHMCS | {$LANG.pricing.renewal} | dup of L77 trap | high |
| 108 | text | Pricing unavailable | CUSTOM | {$hadrianLang.domains.pricingEmptyTitle} | invented `pricingnoextensions`; real key `pricing.noExtensionsDefined` exists but its value differs ("No extensions defined") | med |
| 109 | text | Domain pricing could not be loaded right now. Please check back shortly. | CUSTOM | {$hadrianLang.domains.pricingEmptySub} | invented `pricingnoextensionssub`; no WHMCS key | high |
| 110 | text | Register a domain | WHMCS | {$LANG.registerdomain} | real key — strip default; dup of clientareadomains L188 | high |

_Note L108: real `pricing.noExtensionsDefined` (`nexus/domain-pricing.tpl:161`) covers an empty-table message but reads "No extensions defined"; our copy is a connectivity-error message, so CUSTOM is correct. If wording is relaxed, repoint to `{$LANG.pricing.noExtensionsDefined}`._

---

## Proposed custom keys
```
hadrianLang.domains.manageSub = "Manage your registrations, renewals, and DNS."
hadrianLang.domains.singular = "domain"
hadrianLang.domains.plural = "domains"
hadrianLang.domains.expireWithin30 = "expiring in the next 30 days."
hadrianLang.domains.renewNow = "Renew now"
hadrianLang.domains.transferredAway = "Transferred Away"
hadrianLang.domains.expires = "Expires"
hadrianLang.domains.emptyTitle = "No domains yet"
hadrianLang.domains.emptySub = "Register a new domain or transfer one you already own — it'll appear here once the order is processed."
hadrianLang.domains.rowsPerPage = "Rows per page"
hadrianLang.domains.myDomains = "My Domains"
hadrianLang.domains.bulkManagement = "Bulk Management"
hadrianLang.domains.domainPricing = "Domain Pricing"
hadrianLang.domains.whoisLookup = "WHOIS Lookup"
hadrianLang.domains.unpaidInvoice = "This domain has an unpaid invoice."
hadrianLang.domains.allDomains = "All domains"
hadrianLang.domains.eppCode = "EPP code"
hadrianLang.domains.whoisContact = "WHOIS contact"
hadrianLang.domains.domainDetails = "Domain details"
hadrianLang.domains.dnsExternal = "DNS for this domain is managed externally by the registrar."
hadrianLang.domains.dnsHelpTitle = "Common record types"
hadrianLang.domains.dnsHelpA = "IPv4 address (e.g. 192.0.2.1)"
hadrianLang.domains.dnsHelpAaaa = "IPv6 address (e.g. 2001:db8::1)"
hadrianLang.domains.dnsHelpCname = "Alias to another hostname"
hadrianLang.domains.dnsHelpMx = "Mail server with priority"
hadrianLang.domains.dnsHelpTxt = "Verification / SPF / DKIM strings"
hadrianLang.domains.contactPending = "A contact change is pending registry confirmation."
hadrianLang.domains.noContactDetails = "No contact details available for this domain."
hadrianLang.domains.emailAt = "At"
hadrianLang.domains.eppWarning = "Keep this code private. Anyone with it can initiate a transfer of your domain."
hadrianLang.domains.howTransferWorks = "How a transfer works"
hadrianLang.domains.eppStep1 = "Unlock the domain at the current registrar."
hadrianLang.domains.eppStep2 = "Request the EPP/auth code on this page."
hadrianLang.domains.eppStep3 = "Submit a transfer request at the gaining registrar with that code."
hadrianLang.domains.eppStep4 = "Approve the transfer email from the current registrar (usually within 5 days)."
hadrianLang.domains.copied = "Copied"
hadrianLang.domains.delete = "Delete"
hadrianLang.domains.bulkIntro = "Apply a change to all the domains you selected at once."
hadrianLang.domains.bulkContactInfo = "WHOIS contact details are managed per domain. Open a domain to update its registrant, admin, tech and billing contacts."
hadrianLang.domains.goToMyDomains = "Go to my domains"
hadrianLang.domains.bulkNoneTitle = "No domains selected"
hadrianLang.domains.bulkNoneSub = "Select one or more domains from your domains list, then choose a bulk action."
hadrianLang.domains.pricingIntro = "Registration, transfer and renewal prices for every extension we offer."
hadrianLang.domains.searchExtensions = "Search extensions, e.g. .com"
hadrianLang.domains.pricingEmptyTitle = "Pricing unavailable"
hadrianLang.domains.pricingEmptySub = "Domain pricing could not be loaded right now. Please check back shortly."
hadrianLang.common.previousPage = "Previous page"
hadrianLang.common.nextPage = "Next page"
```
