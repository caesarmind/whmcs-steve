# B12 — Billing (invoices, quotes, add funds, mass pay, cancel request, payment methods)

## Summary
- **Total strings (table rows):** 316 (most are deduped repeats: every billing page carries the same 6-item Billing/Account sub-nav card, and the table-footer pager/`Show N entries` controls repeat across the two list pages — distinct strings after dedupe ≈ 150)
- **WHMCS:** 227
- **CUSTOM:** 89
- **#SKIP-worth-noting:** see per-file Notes (subnav `Billing` heading is a **bare literal**, kept correct per memory; `$var`/`->method()` output, demo `{assign}` literals under `?preview=1`, SVG/`data-*`/URLs, currency-prefix numerals, card-mask placeholders)
- **#js-string:** 7 (all CUSTOM) — DataTables pager/info builders ("Previous page", "Next page", "Showing %s–%s of %s") in clientareainvoices + clientareaquotes, plus the two `confirm()` dialogs (paymentmethods list + manage delete)

### Evidence legend
- **nexus** uses `{lang key='x'}` (resolves real WHMCS `$_LANG`) → citing it proves the key is real.
- **lagom** (`lagom2.3/lagom2-theme/…`) uses `{$LANG.x}` → same proof.
- This theme uses `{$LANG.x|default:'…'}` on **every** string (never a bare `{$LANG.x}`), so per spec the `|default` literal is the "Current text"; a key provable in a reference → **WHMCS, strip default**; a `|default`-only key with no reference → **CUSTOM, rebadge**.
- **Big trap in this batch:** hadrian invented a parallel `invoice*` key set (`invoicenum`, `invoicedatecreated`, `invoicedatedue`, `invoicesstatus` used as a list header, `amount`, `myinvoices`, `myquotes`, `addfunds`, `masspayment`, `paymentmethods`) where WHMCS already ships the canonical key under a slightly different name (`invoicestitle`/`invoicesdatecreated`/`invoicesdatedue`/`invoicesstatus`/`invoicesamount`/`navinvoices`/`navquotes`/…). These are mapped to the **real** WHMCS key (prefer-real-keys policy); several are "real key piped a different `|default` literal" — noted inline.
- **`billing.*` ledger keys are nested & real but UNUSED here:** nexus/viewbillingnote use `billing.ledger.title/date/type/reference`, `billing.creditnote`, `billing.debitnote`, `billing.issuedby`, `billing.issuedto`, `billing.issuedate`. hadrian reinvented them as flat `invoicestrans*` / `invoicefrom` / `billingissuedate` `|default`s → mapped to the real nested keys.
- **`$LANG.billing` is an ARRAY on this install** (renders literal "Array"). The Billing sub-nav heading is a **bare literal `Billing`** in every file (NOT `{$LANG.billing}`), so it is already safe — flagged CUSTOM `{$hadrianLang.billing.sidebarHeading}` only so Phase B tokenizes it without re-introducing the array bug. Do NOT switch it to `{$LANG.billing}`.
- `$rslang.*` legacy keys: none appear in any B12 file. Legacy `core/lang/english.php` has only `footer`/`error`/`license`/`admin` groups — **no billing keys** to reuse.

---

### hadrian/templates/hadrian/core/pages/clientareainvoices/default/default.tpl
| Line | Type | Current text | Class | Proposed reference | Evidence / Notes | Conf |
|------|------|--------------|-------|--------------------|------------------|------|
| 69 | text | Invoices | WHMCS | {$LANG.navinvoices} | page H1; `navinvoices` real — `nexus/clientareahome.tpl:53` `{lang key='navinvoices'}`; strip default | high |
| 70 | text | Pay unpaid invoices, download PDFs, and review past payments. | CUSTOM | {$hadrianLang.billing.invoicesSubtitle} | `invoicessub` only ever `|default` → invented; no WHMCS subtitle key | high |
| 74 | text | Pay all unpaid | CUSTOM | {$hadrianLang.billing.payAllUnpaid} | `payallunpaid` invented; nexus/lagom have no "pay all" CTA. Closest real is `masspaymakepayment` ("Make Payment") — wording differs, keep CUSTOM | med |
| 89 | text | unpaid invoice | CUSTOM | {$hadrianLang.billing.unpaidInvoiceSingular} | `unpaidinvoicesingular` invented; banner count noun (singular) | high |
| 89 | text | unpaid invoices | CUSTOM | {$hadrianLang.billing.unpaidInvoicePlural} | `unpaidinvoicesplural` invented; banner count noun (plural). cf. lagom `clientHomePanels.unpaidInvoices` is a panel title, not this inline plural | med |
| 91 | text | Pay now | WHMCS | {$LANG.paynow} | standard WHMCS key (cart/invoice "Pay Now"); strip default | med |
| 96 | text | All | CUSTOM | {$hadrianLang.common.filterAll} | filter-tab label; `all` is generic — no citable WHMCS `all` key in references; rebadge (dedupe across invoices+quotes) | med |
| 97 | text | Unpaid | WHMCS | {$LANG.invoicesunpaid} | real status key — `nexus/viewinvoice.tpl:52` `{lang key='invoicesunpaid'}`; default here is `invoiceunpaid` (invented variant) → use real `invoicesunpaid`; strip default | high |
| 98 | text | Paid | WHMCS | {$LANG.invoicespaid} | real — `nexus/viewinvoice.tpl:54`; hadrian key `invoicepaid` is the invented variant; map to `invoicespaid` | high |
| 99 | text | Cancelled | WHMCS | {$LANG.invoicescancelled} | real — `nexus/viewinvoice.tpl:58` + `lagom viewinvoice.tpl:41`; hadrian `invoicecancelled` is invented variant; map to `invoicescancelled` | high |
| 100 | placeholder | Search | WHMCS | {$LANG.search} | standard WHMCS search key; strip default (trailing `…` is decorative) | med |
| 100 | aria-label | Search | WHMCS | {$LANG.search} | dedupe of line-100 placeholder | med |
| 127 | text | No invoices yet | CUSTOM | {$hadrianLang.billing.noInvoicesTitle} | `noinvoices` invented; reference empty state is `invoicesnoinvoices` ("You Have No Invoices") — `lagom clientareainvoices.tpl:182` — consider WHMCS `{$LANG.invoicesnoinvoices}`; kept CUSTOM because wording is a short title | med |
| 128 | text | When you purchase a service or a new billing cycle begins, your invoices will appear here. | CUSTOM | {$hadrianLang.billing.noInvoicesSub} | `noinvoicessub` invented; no WHMCS empty-state body key | high |
| 129 | text | Browse services | CUSTOM | {$hadrianLang.billing.browseServices} | `browseservices` invented; closest real `navservices` ("My Services") differs; keep CUSTOM | med |
| 144 | text | Invoice | WHMCS | {$LANG.invoicestitle} | list header; real — `nexus/clientareainvoices.tpl:29` + `lagom:117` use `invoicestitle`; hadrian `invoicenum` here is the invented variant → map to `invoicestitle`; strip default | high |
| 145 | text | Date | WHMCS | {$LANG.invoicesdatecreated} | list header; real — `nexus/clientareainvoices.tpl:30` + `lagom:118`; hadrian `invoicedatecreated` invented variant → `invoicesdatecreated`; strip default | high |
| 146 | text | Due date | WHMCS | {$LANG.invoicesdatedue} | list header; real — `nexus/clientareainvoices.tpl:31` + `lagom:119`; hadrian `invoicedatedue` invented variant → `invoicesdatedue`; strip default | high |
| 147 | text | Amount | WHMCS | {$LANG.invoicesamount} | real — `nexus/viewinvoice.tpl:194` `{lang key='invoicesamount'}`; hadrian `amount` is invented short variant → `invoicesamount`; strip default | high |
| 148 | text | Status | WHMCS | {$LANG.invoicesstatus} | list header; real — `nexus/clientareainvoices.tpl:33` + `lagom:121`; strip default | high |
| 180 | aria-label | Actions | WHMCS | {$LANG.actions} | real — `nexus/managessl.tpl:13` `{lang key='actions'}` + `lagom viewinvoice.tpl:273` `{$LANG.actions}`; strip default | high |
| 186 | text | View Invoice | CUSTOM | {$hadrianLang.billing.viewInvoice} | `invoiceview` invented; nexus row is `clickableSafeRedirect`, no menu item. Real adjacent `invoicesview`? not citable. Keep CUSTOM | med |
| 190 | text | Download PDF | WHMCS | {$LANG.invoicesdownload} | real — `nexus/viewinvoice.tpl:299` + `lagom clientareainvoices.tpl:160` use `invoicesdownload`; hadrian `invoicedownload` invented variant; default "Download PDF" vs WHMCS "Download" — strip default | high |
| 195 | text | Pay Invoice | CUSTOM | {$hadrianLang.billing.payInvoice} | `invoicepay` invented; no WHMCS "Pay Invoice" menu key (nexus uses `$paymentbutton`). Closest `paynow` differs; keep CUSTOM | med |
| 211 | text | Show | CUSTOM | {$hadrianLang.common.tableShow} | `show` invented; DataTables "Show N entries" affix; no WHMCS key (WHMCS uses DataTables lengthMenu lang). Dedupe across invoices+quotes | med |
| 212 | aria-label | Rows per page | CUSTOM | {$hadrianLang.common.rowsPerPage} | `rowsperpage` invented a11y label; dedupe | med |
| 217 | text | entries | CUSTOM | {$hadrianLang.common.tableEntries} | `entries` invented; pairs with `show`; dedupe | med |
| 224 | text | Showing | CUSTOM | {$hadrianLang.common.tableShowing} | `showing` invented; info-row prefix; dedupe | med |
| 224 | text | of | CUSTOM | {$hadrianLang.common.tableOf} | `of` invented connective; dedupe; risky to translate standalone — note | low |
| 226 | aria-label | Previous page | CUSTOM | {$hadrianLang.common.previousPage} | `previouspage` invented; pager a11y; dedupe | med |
| 228 | aria-label | Next page | CUSTOM | {$hadrianLang.common.nextPage} | `nextpage` invented; pager a11y; dedupe | med |
| 238 | text | Billing | CUSTOM | {$hadrianLang.billing.sidebarHeading} | **bare literal** (not `$LANG`); do NOT use `{$LANG.billing}` (array → "Array" bug, per memory); rebadge. Dedupe across all billing subnav cards | high |
| 241 | text | My Invoices | WHMCS | {$LANG.navinvoices} | subnav item; real `navinvoices`; default "My Invoices" matches WHMCS; strip default | high |
| 246 | text | My Quotes | WHMCS | {$LANG.navquotes} | real — `nexus/clientareahome.tpl` nav / standard `navquotes`; strip default | med |
| 250 | text | Mass Payment | WHMCS | {$LANG.masspaytitle} | real — `nexus/masspay.tpl:6` `{lang key="masspaytitle"}`; hadrian `masspayment` invented variant → `masspaytitle`; strip default | high |
| 254 | text | Add Funds | WHMCS | {$LANG.addfunds} | real — `nexus/clientareaaddfunds.tpl:53` + `lagom:68`; strip default | high |
| 258 | text | Payment Methods | WHMCS | {$LANG.paymentMethods.title} | real nested — `nexus/account-paymentmethods.tpl:22`; hadrian `paymentmethods` flat invented → use nested `paymentMethods.title`; strip default | high |
| 333 | js-string | Previous page | CUSTOM | {$hadrianLang.common.previousPage} | DataTables `buildPager` injects `aria-label="Previous page"`; dedupe of line 226; seed from Smarty | high |
| 339 | js-string | Next page | CUSTOM | {$hadrianLang.common.nextPage} | DataTables `buildPager`; dedupe of line 228 | high |
| 345 | js-string | Showing %s–%s of %s | CUSTOM | {$hadrianLang.common.tableShowingRange} | `updateControls` sets `infoEl.textContent='Showing '+from+'–'+info.end+' of '+…`; composite of `showing`/`of`; use one interpolated key | med |

Notes: `#{$invDisplayNum}`, `{$inv.*}`, `{$unpaidCount}`, `{$invCount}`, all `data-mt-*`/`data-order`/`onclick`/SVG/`{routePath}`/URLs skipped. The `<script>` body-attr setter and DataTables config (`order`, `dom:'rt'`, selectors) carry no UI strings. Numeric `<option>10/25/50` are values, not translatable.

---

### hadrian/templates/hadrian/core/pages/viewinvoice/default/default.tpl
| Line | Type | Current text | Class | Proposed reference | Evidence / Notes | Conf |
|------|------|--------------|-------|--------------------|------------------|------|
| 42 | text | Invoice | WHMCS | {$LANG.invoicestitle} | page eyebrow; real `invoicestitle`; hadrian `invoicenum` invented variant; strip default | high |
| 43 | text | Invoice | WHMCS | {$LANG.invoicestitle} | H1 prefix before `#{$invDisplayNum}`; dedupe of line 42 | high |
| 45 | text | Issued | CUSTOM | {$hadrianLang.billing.issuedOn} | `invoicedatecreated|default:'Issued'` — real key but WRONG default ("Issued" vs WHMCS "Invoice Date"). This is the inline subtitle label; "Issued" is bespoke microcopy → rebadge OR strip-default to `{$LANG.invoicesdatecreated}` if "Invoice Date" acceptable. Flag (real-key-different-default trap) | med |
| 46 | text | Due | CUSTOM | {$hadrianLang.billing.dueOn} | `invoicedatedue|default:'Due'` — same trap; "Due" bespoke vs WHMCS "Due Date". Rebadge or map to `{$LANG.invoicesdatedue}` | med |
| 64 | text | Total | WHMCS | {$LANG.invoicestotal} | real — `nexus/viewinvoice.tpl:221`; strip default | high |
| 64 | text | Amount due | CUSTOM | {$hadrianLang.billing.amountDue} | `amountdue` invented; no WHMCS "Amount Due" key in refs (nexus shows `$total` unlabelled). Dedupe (lines 64/236) | med |
| 68 | text | Due date | WHMCS | {$LANG.invoicesdatedue} | real `invoicesdatedue`; hadrian `invoicedatedue` invented variant; strip default | high |
| 72 | text | Invoice date | WHMCS | {$LANG.invoicesdatecreated} | real `invoicesdatecreated`; default "Invoice date" matches WHMCS wording; strip default | high |
| 85 | text | Apply credit | WHMCS | {$LANG.invoiceaddcreditapply} | real — `nexus/viewinvoice.tpl:158/170`; strip default | high |
| 87 | text | You have an available credit balance of | WHMCS | {$LANG.invoiceaddcreditdesc1} | real — `nexus/viewinvoice.tpl:163` `{lang key='invoiceaddcreditdesc1'}`; strip default (WHMCS wording differs slightly) | high |
| 87 | text | Enter how much to apply to this invoice | WHMCS | {$LANG.invoiceaddcreditdesc2} | real — `nexus/viewinvoice.tpl:163`; strip default | high |
| 92 | aria-label | Amount | WHMCS | {$LANG.invoiceaddcreditamount} | real — `nexus/viewinvoice.tpl:163` + `lagom viewinvoice.tpl:261`; strip default | high |
| 93 | text | Apply credit | WHMCS | {$LANG.invoiceaddcreditapply} | submit button; dedupe of line 85 | high |
| 104 | text | From | WHMCS | {$LANG.invoicespayto} | `invoicefrom|default:'From'` — real key is `invoicespayto` ("Pay To") used for the issuer block (`nexus/viewinvoice.tpl:99`). hadrian invented `invoicefrom`; map to `invoicespayto`; flag wording shift "From" vs "Pay To" | med |
| 110 | text | Bill to | WHMCS | {$LANG.invoicesinvoicedto} | `invoicebillto|default:'Bill to'` — real key is `invoicesinvoicedto` ("Invoiced To"), `nexus/viewinvoice.tpl:106` + `lagom viewinvoice.tpl:89`; hadrian invented `invoicebillto`; map to `invoicesinvoicedto` | high |
| 125 | text | Invoice details | WHMCS | {$LANG.invoicelineitems} | `invoicedetails|default:'Invoice details'` — real key is `invoicelineitems` ("Invoice Items"), `nexus/viewinvoice.tpl:187` + `lagom:109`; map to `invoicelineitems`; flag wording shift | high |
| 129 | text | Description | WHMCS | {$LANG.invoicesdescription} | `invoicesdescription` here uses default "Description"; real — `nexus/viewinvoice.tpl:193`; strip default | high |
| 130 | text | Amount | WHMCS | {$LANG.invoicesamount} | hadrian uses `amount|default` here; real `invoicesamount`; map + strip | high |
| 147 | text | Subtotal | WHMCS | {$LANG.invoicessubtotal} | real — `nexus/viewinvoice.tpl:205`; strip default | high |
| 150 | text | Tax | WHMCS | {$LANG.invoicestax} | real — standard `invoicestax`; nexus renders `{$taxrate}% {$taxname}` (dynamic), but `invoicestax` is the canonical label key; strip default | med |
| 153 | text | Tax | WHMCS | {$LANG.invoicestax} | dedupe of line 150 (Tax 2 row) | med |
| 156 | text | Credit applied | WHMCS | {$LANG.invoicescredit} | `invoicescredit|default:'Credit applied'` — real key `invoicescredit` ("Credit"), `nexus/viewinvoice.tpl` family + `lagom viewinvoice.tpl:148`; strip default (wording "Credit applied" vs "Credit") | high |
| 158 | text | Total | WHMCS | {$LANG.invoicestotal} | grand-total label (paid); dedupe of line 64 | high |
| 158 | text | Total due | WHMCS | {$LANG.invoicestotaldue} | real — `nexus/masspay.tpl:70` + `nexus/payment/invoice-summary.tpl:39` `{lang key="invoicestotaldue"}`; hadrian `totaldue` invented variant → `invoicestotaldue`; strip default | high |
| 168 | text | Transactions | WHMCS | {$LANG.billing.ledger.title} | nested real — `nexus/viewinvoice.tpl:238` `{lang key='billing.ledger.title'}`; hadrian `invoicestransactions` invented → map to nested `billing.ledger.title`; strip default | high |
| 172 | text | Date | WHMCS | {$LANG.billing.ledger.date} | nested real — `nexus/viewinvoice.tpl:244`; hadrian `invoicestransdate` invented → `billing.ledger.date` | high |
| 173 | text | Type | WHMCS | {$LANG.billing.ledger.type} | nested real — `nexus/viewinvoice.tpl:245`; hadrian `invoicestype` invented → `billing.ledger.type` | high |
| 174 | text | Reference | WHMCS | {$LANG.billing.ledger.reference} | nested real — `nexus/viewinvoice.tpl:246`; hadrian `invoicesrefnum` invented → `billing.ledger.reference` | high |
| 175 | text | Amount | WHMCS | {$LANG.invoicestransamount} | real — `nexus/viewinvoice.tpl:247` `{lang key='invoicestransamount'}`; hadrian `amount|default` → map to `invoicestransamount`; strip default | high |
| 183 | text | Credit Note | WHMCS | {$LANG.billing.creditnote} | nested real — `nexus/viewinvoice.tpl:265` `{lang key='billing.creditnote'}`; bare hardcoded literal here → tokenize | high |
| 183 | text | Debit Note | WHMCS | {$LANG.billing.debitnote} | nested real — `nexus/viewinvoice.tpl:267`; bare hardcoded literal → tokenize | high |
| 188 | text | No transactions have been recorded for this invoice yet. | WHMCS | {$LANG.invoicestransnonefound} | real — `nexus/viewinvoice.tpl:278`; strip default (WHMCS wording differs) | high |
| 192 | text | Balance | WHMCS | {$LANG.invoicesbalance} | real — `nexus/viewinvoice.tpl:282` + `lagom viewinvoice.tpl:194`; strip default | high |
| 202 | text | Make a payment | WHMCS | {$LANG.invoicemakepayment} | standard WHMCS key `invoicemakepayment`; not citable in nexus/lagom templates (they use `$paymentbutton`); strip default | low |
| 220 | text | Pay | WHMCS | {$LANG.invoicepay} | standard WHMCS `invoicepay` ("Pay Now"/"Pay") on the pay button; not citable in refs; strip default; note "Pay {$total}" composite | low |
| 230 | text | Summary | CUSTOM | {$hadrianLang.billing.summary} | `summary` invented; NO WHMCS `summary` key anywhere in refs; aside heading; dedupe (viewinvoice+viewquote) | high |
| 232 | text | Status | WHMCS | {$LANG.invoicesstatus} | aside; real `invoicesstatus`; strip default | high |
| 236 | text | Total | WHMCS | {$LANG.invoicestotal} | aside; dedupe | high |
| 236 | text | Amount due | CUSTOM | {$hadrianLang.billing.amountDue} | dedupe of line 64 | med |
| 240 | text | Due date | WHMCS | {$LANG.invoicesdatedue} | aside; real; map+strip | high |
| 246 | text | Actions | WHMCS | {$LANG.actions} | aside heading; real `actions`; strip default | high |
| 250 | text | Download | WHMCS | {$LANG.invoicesdownload} | real `invoicesdownload`; hadrian `invoicedownload` invented variant; strip default | high |
| 257 | text | Billing | CUSTOM | {$hadrianLang.billing.sidebarHeading} | bare literal; dedupe (do not use `$LANG.billing`) | high |
| 260 | text | My Invoices | WHMCS | {$LANG.navinvoices} | subnav; dedupe of clientareainvoices:241 | high |
| 264 | text | My Quotes | WHMCS | {$LANG.navquotes} | subnav; dedupe | med |
| 268 | text | Mass Payment | WHMCS | {$LANG.masspaytitle} | subnav; map+strip; dedupe | high |
| 272 | text | Add Funds | WHMCS | {$LANG.addfunds} | subnav; dedupe | high |
| 276 | text | Payment Methods | WHMCS | {$LANG.paymentMethods.title} | subnav; nested key; dedupe | high |
| 288 | text | Invoice not found | CUSTOM | {$hadrianLang.billing.invoiceNotFoundTitle} | `invoicenotfound` invented; nexus error path uses generic `invoiceserror` ("Invalid Invoice ID") — different wording; keep CUSTOM (or map to `{$LANG.invoiceserror}`) | med |
| 289 | text | This invoice doesn't exist or has been removed from your account. | CUSTOM | {$hadrianLang.billing.invoiceNotFoundSub} | `invoicenotfoundsub` invented; no WHMCS body key | high |
| 290 | text | All invoices | WHMCS | {$LANG.navinvoices} | `allinvoices|default:'All invoices'` invented key; map to real `navinvoices` (back-to-list link) or keep CUSTOM if "All invoices" wording matters; flag | med |

Notes: `{$total}`/`{$datedue}`/`{$status}`/`{$companyname}`/`{$clientsdetails.*}`/`{$invoiceitems}`/`{$transactions}`/`{$balance}`/`{$pm.*}`/`{$taxrate}`/`{$creditamount}`/`{$token}` all dynamic → SKIP. `PAY` (line 212 `$pm.shortname|default:'PAY'|truncate`) is a fallback on a dynamic gateway shortname, not standalone UI → SKIP. SVG/inline-styles/`{routePath}`/URLs skipped. Touch-comment line 37 is a `{* *}` comment → SKIP.

---

### hadrian/templates/hadrian/core/pages/clientareaquotes/default/default.tpl
| Line | Type | Current text | Class | Proposed reference | Evidence / Notes | Conf |
|------|------|--------------|-------|--------------------|------------------|------|
| 65 | text | My Quotes | WHMCS | {$LANG.navquotes} | H1; real `navquotes` (hadrian `myquotes` default matches "My Quotes"); strip default | med |
| 66 | text | Review delivered proposals, accept to convert into an invoice, or download as PDF. | CUSTOM | {$hadrianLang.billing.quotesSubtitle} | `myquotessub` invented; no WHMCS subtitle key | high |
| 79 | text | quote awaiting your decision | CUSTOM | {$hadrianLang.billing.quoteDeliveredSingular} | `quotedeliveredsingular` invented; banner count noun | high |
| 79 | text | quotes awaiting your decision | CUSTOM | {$hadrianLang.billing.quoteDeliveredPlural} | `quotedeliveredplural` invented; banner count noun | high |
| 85 | text | All | CUSTOM | {$hadrianLang.common.filterAll} | dedupe of clientareainvoices:96 | med |
| 86 | text | Draft | WHMCS | {$LANG.quotestagedraft} | real stage key — standard `quotestagedraft`; nexus uses `quotestagedelivered/accepted/onhold/lost/dead` bare (`nexus/viewquote.tpl:44-53`), draft is same family; strip default | med |
| 87 | text | Delivered | WHMCS | {$LANG.quotestagedelivered} | real — `nexus/viewquote.tpl:45` + `lagom viewquote.tpl:19`; strip default | high |
| 88 | text | Accepted | WHMCS | {$LANG.quotestageaccepted} | real — `nexus/viewquote.tpl:47`; strip default | high |
| 89 | text | Lost | WHMCS | {$LANG.quotestagelost} | real — `nexus/viewquote.tpl:51`; strip default | high |
| 90 | placeholder | Search | WHMCS | {$LANG.search} | dedupe of clientareainvoices:100 | med |
| 90 | aria-label | Search | WHMCS | {$LANG.search} | dedupe | med |
| 115 | text | No quotes yet | CUSTOM | {$hadrianLang.billing.noQuotesTitle} | `noquotes` invented; no WHMCS quotes-empty title (nexus has none) | high |
| 116 | text | When our team prepares a proposal for you, it will show up here. | CUSTOM | {$hadrianLang.billing.noQuotesSub} | `noquotessub` invented | high |
| 117 | text | Contact sales | CUSTOM | {$hadrianLang.billing.contactSales} | `contactsales` invented; no WHMCS key | med |
| 132 | text | Quote | WHMCS | {$LANG.quotenumber} | list header; real `quotenumber` — `nexus/clientareaquotes.tpl:25` (used as "Quote #" prefix); hadrian `quotenum` invented variant; map to `quotenumber`; note trailing "#" handled separately | med |
| 133 | text | Date | WHMCS | {$LANG.quotedatecreated} | real — `nexus/clientareaquotes.tpl:27` + `lagom viewquote.tpl:34`; strip default | high |
| 134 | text | Valid until | WHMCS | {$LANG.quotevaliduntil} | real — `nexus/clientareaquotes.tpl:28` + `lagom viewquote.tpl:38`; strip default | high |
| 135 | text | Amount | WHMCS | {$LANG.invoicesamount} | hadrian `amount|default`; map to real `invoicesamount`; strip | high |
| 136 | text | Status | WHMCS | {$LANG.quotestage} | real — `nexus/clientareaquotes.tpl:29` `{lang key='quotestage'}`; default "Status"; strip default | high |
| 165 | aria-label | Actions | WHMCS | {$LANG.actions} | real; dedupe of clientareainvoices:180 | high |
| 171 | text | View Quote | CUSTOM | {$hadrianLang.billing.viewQuote} | `viewquote` invented menu label; nexus has no view-menu (row redirect). Keep CUSTOM | med |
| 175 | text | Download PDF | WHMCS | {$LANG.quotedownload} | real — `nexus/clientareaquotes.tpl:45` `{lang key='quotedownload'}`; hadrian `downloadpdf` invented variant; map to `quotedownload`; strip default | high |
| 180 | text | Accept Quote | WHMCS | {$LANG.quoteacceptbtn} | `quoteaccept|default:'Accept Quote'` — real key is `quoteacceptbtn` ("Accept Quote"), `nexus/viewquote.tpl:59/190`; hadrian `quoteaccept` invented variant; map to `quoteacceptbtn` | high |
| 196 | text | Show | CUSTOM | {$hadrianLang.common.tableShow} | dedupe of clientareainvoices:211 | med |
| 197 | aria-label | Rows per page | CUSTOM | {$hadrianLang.common.rowsPerPage} | dedupe | med |
| 202 | text | entries | CUSTOM | {$hadrianLang.common.tableEntries} | dedupe | med |
| 205 | text | Showing | CUSTOM | {$hadrianLang.common.tableShowing} | dedupe | med |
| 205 | text | of | CUSTOM | {$hadrianLang.common.tableOf} | dedupe | low |
| 207 | aria-label | Previous page | CUSTOM | {$hadrianLang.common.previousPage} | dedupe | med |
| 209 | aria-label | Next page | CUSTOM | {$hadrianLang.common.nextPage} | dedupe | med |
| 219 | text | Billing | CUSTOM | {$hadrianLang.billing.sidebarHeading} | bare literal; dedupe | high |
| 222 | text | My Invoices | WHMCS | {$LANG.navinvoices} | subnav; dedupe | high |
| 226 | text | My Quotes | WHMCS | {$LANG.navquotes} | subnav; dedupe | med |
| 231 | text | Mass Payment | WHMCS | {$LANG.masspaytitle} | subnav; map+strip; dedupe | high |
| 235 | text | Add Funds | WHMCS | {$LANG.addfunds} | subnav; dedupe | high |
| 239 | text | Payment Methods | WHMCS | {$LANG.paymentMethods.title} | subnav; nested; dedupe | high |
| 311 | js-string | Previous page | CUSTOM | {$hadrianLang.common.previousPage} | DataTables `buildPager`; dedupe | high |
| 313 | js-string | Next page | CUSTOM | {$hadrianLang.common.nextPage} | DataTables `buildPager`; dedupe | high |
| 319 | js-string | Showing %s–%s of %s | CUSTOM | {$hadrianLang.common.tableShowingRange} | `updateControls`; dedupe of clientareainvoices:345 | med |

Notes: `{$qt.*}`/`{$deliveredCount}`/`{$qtCount}`/`{$numquotes}`/`{$qtSubject}`/`{$qtStage}` dynamic → SKIP. SVG/`data-mt-*`/`onclick`/URLs/`{routePath}` skipped. `<option>10/25/50` numeric values.

---

### hadrian/templates/hadrian/core/pages/viewquote/default/default.tpl
| Line | Type | Current text | Class | Proposed reference | Evidence / Notes | Conf |
|------|------|--------------|-------|--------------------|------------------|------|
| 77 | text | Quote | WHMCS | {$LANG.quotenumber} | eyebrow; `quotetitle|default:'Quote'` invented key; map to real `quotenumber` (or keep eyebrow CUSTOM). Flag | med |
| 78 | text | Quote # | WHMCS | {$LANG.quotenumber} | H1 prefix; real `quotenumber` ("Quote #") — `nexus/viewquote.tpl:38` + `lagom viewquote.tpl:17`; strip default | high |
| 81 | text | Issued | WHMCS | {$LANG.quotedatecreated} | `quotedatecreated|default:'Issued'` — real key, default "Issued" differs from WHMCS "Date Created"; strip default (or rebadge if "Issued" wording load-bearing) | med |
| 82 | text | Valid until | WHMCS | {$LANG.quotevaliduntil} | real `quotevaliduntil`; strip default | high |
| 101 | text | You must accept the terms of service to accept this quote. | WHMCS | {$LANG.ordererroraccepttos} | real — `nexus/viewquote.tpl:69` + `lagom viewquote.tpl:11` `ordererroraccepttos`; strip default | high |
| 109 | text | Total | WHMCS | {$LANG.invoicestotal} | `invoicestotal` default "Total"; real; strip default | high |
| 113 | text | Valid until | WHMCS | {$LANG.quotevaliduntil} | dedupe of line 82 | high |
| 117 | text | Issued | WHMCS | {$LANG.quotedatecreated} | dedupe of line 81 | med |
| 119 | text | # | CUSTOM | {$hadrianLang.billing.quoteNumberHash} | `quotenumber|default:'#'` — uses real key BUT default is just "#" (number prefix). Borderline SKIP (single symbol); kept because it reuses a real key with a degenerate default. Recommend strip-default → `{$LANG.quotenumber}` | low |
| 128 | text | From | WHMCS | {$LANG.invoicespayto} | `invoicespayto|default:'From'` — real key (default "Pay To"); `nexus/viewquote.tpl:90`; strip default (wording shift "From"); flag | high |
| 132 | text | Quote for | WHMCS | {$LANG.quoterecipient} | real — `nexus/viewquote.tpl:74` + `lagom viewquote.tpl:50`; default "Quote for" vs WHMCS "Quote Recipient"; strip default | high |
| 155 | text | Proposal | WHMCS | {$LANG.quoteproposal} | real — `nexus/viewquote.tpl:115`; strip default | high |
| 163 | text | Quote details | WHMCS | {$LANG.quotelineitems} | `quotelineitems|default:'Quote details'` — real key ("Line Items"), `nexus/viewquote.tpl:120`; strip default (wording shift) | high |
| 167 | text | Description | WHMCS | {$LANG.invoicesdescription} | real — `nexus/viewquote.tpl:127`; strip default | high |
| 168 | text | Discount | WHMCS | {$LANG.quotediscountheading} | real — `nexus/viewquote.tpl:128`; strip default | high |
| 169 | text | Amount | WHMCS | {$LANG.invoicesamount} | real — `nexus/viewquote.tpl:129`; strip default | high |
| 184 | text | Subtotal | WHMCS | {$LANG.invoicessubtotal} | real — `nexus/viewquote.tpl:141`; strip default | high |
| 187 | text | Total | WHMCS | {$LANG.quotelinetotal} | real — `nexus/viewquote.tpl:157` `{lang key='quotelinetotal'}`; strip default | high |
| 189 | text | Indicates taxable item | WHMCS | {$LANG.invoicestaxindicator} | real — `nexus/viewquote.tpl:171` + `nexus/viewinvoice.tpl:230`; strip default | high |
| 192 | text | Download PDF | WHMCS | {$LANG.invoicesdownload} | `invoicesdownload|default:'Download PDF'` — real key (default "Download"); `nexus/viewquote.tpl:176`; strip default | high |
| 202 | text | I have read and agree to the | WHMCS | {$LANG.ordertosagreement} | real — `nexus/viewquote.tpl:198` `{lang key='ordertosagreement'}`; strip default | high |
| 202 | text | Terms of Service | WHMCS | {$LANG.ordertos} | real — `nexus/viewquote.tpl:198`; strip default | high |
| 205 | text | Accept quote | WHMCS | {$LANG.quoteacceptbtn} | real — `nexus/viewquote.tpl:205`; strip default | high |
| 215 | text | Notes | WHMCS | {$LANG.invoicesnotes} | real — `nexus/viewquote.tpl:167` + `nexus/viewinvoice.tpl:182`; strip default | high |
| 231 | text | Quote unavailable | CUSTOM | {$hadrianLang.billing.quoteUnavailableTitle} | `quoteunavailable` invented; nexus error path is generic `invoiceserror`; keep CUSTOM | med |
| 232 | text | This quote has expired or is no longer available. Visit My Quotes to see your active proposals. | CUSTOM | {$hadrianLang.billing.quoteUnavailableSub} | `quoteunavailablesub` invented | high |
| 233 | text | Back to quotes | CUSTOM | {$hadrianLang.billing.backToQuotes} | `quotesnav` invented; closest real `navquotes` ("My Quotes") differs; keep CUSTOM | med |
| 243 | text | Summary | CUSTOM | {$hadrianLang.billing.summary} | dedupe of viewinvoice:230 | high |
| 245 | text | Status | WHMCS | {$LANG.invoicesstatus} | aside; real; strip default | high |
| 249 | text | Total | WHMCS | {$LANG.invoicestotal} | aside; dedupe | high |
| 253 | text | Valid until | WHMCS | {$LANG.quotevaliduntil} | aside; dedupe | high |
| 260 | text | Billing | CUSTOM | {$hadrianLang.billing.sidebarHeading} | bare literal; dedupe | high |
| 263 | text | My Invoices | WHMCS | {$LANG.navinvoices} | `invoices|default:'My Invoices'` — `invoices` is a real WHMCS section key; default "My Invoices" → prefer `navinvoices` (matches default); strip default | med |
| 267 | text | My Quotes | WHMCS | {$LANG.navquotes} | `quotestitle|default:'My Quotes'` — `quotestitle` real ("Quotes"); default "My Quotes" → use `navquotes`; flag two key shapes | med |
| 271 | text | Mass Payment | WHMCS | {$LANG.masspaytitle} | `masspaytitle|default:'Mass Payment'` — real key, default matches; strip default | high |
| 275 | text | Add Funds | WHMCS | {$LANG.addfunds} | subnav; dedupe | high |
| 279 | text | Payment Methods | WHMCS | {$LANG.paymentMethods.title} | subnav already uses correct nested key here; strip default | high |

Notes: lines 30-43 are `{assign}` DEMO data under `?preview=1` (`'QT-1042'`, `'Cloud Hosting'`, addresses, `<strong>Hostnodes</strong>…`) — assignment values, NOT emitted UI copy → SKIP (per B08 precedent for `$mt_pageLabel`). `{$qStage}`/`{$total}`/`{$validuntil}`/`{$clientsdetails.*}`/`{$customfields}`/`{$proposal}`/`{$notes}`/`{$item.*}`/`{$tosurl}` dynamic → SKIP. SVG/inline-styles/URLs skipped.

---

### hadrian/templates/hadrian/core/pages/clientareaaddfunds/default/default.tpl
| Line | Type | Current text | Class | Proposed reference | Evidence / Notes | Conf |
|------|------|--------------|-------|--------------------|------------------|------|
| 24 | text | Add funds | WHMCS | {$LANG.addfunds} | H1; real — `nexus/clientareaaddfunds.tpl:53` + `lagom:68`; strip default | high |
| 25 | text | Top up your account credit to cover upcoming invoices automatically. | CUSTOM | {$hadrianLang.billing.addFundsSubtitle} | `addfundssub` invented; distinct from `addfundsdescription` (the long intro); no WHMCS subtitle key | high |
| 39 | text | Your credit balance is | CUSTOM | {$hadrianLang.billing.creditBalanceLabel} | `yourcreditbalance` invented; no WHMCS key in refs (nexus addfunds has no balance card) | high |
| 41 | text | Applied automatically to new invoices | CUSTOM | {$hadrianLang.billing.creditAppliesNext} | `creditappliesnext` invented; no WHMCS key | high |
| 49 | text | Minimum deposit | WHMCS | {$LANG.addfundsminimum} | real — `nexus/clientareaaddfunds.tpl:18` `{lang key='addfundsminimum'}`; hadrian `minamount` invented variant; map to `addfundsminimum`; strip default | high |
| 55 | text | Maximum deposit | WHMCS | {$LANG.addfundsmaximum} | real — `nexus/clientareaaddfunds.tpl:22`; hadrian `maxamount` invented variant → `addfundsmaximum`; strip default | high |
| 61 | text | Maximum balance | WHMCS | {$LANG.addfundsmaximumbalance} | real — `nexus/clientareaaddfunds.tpl:26`; hadrian `maxbalance` invented variant → `addfundsmaximumbalance`; strip default | high |
| 70 | text | Add funds to your account with us to avoid lots of small transactions and to automatically take care of any new invoices that are generated. | WHMCS | {$LANG.addfundsdescription} | `addfundsintro|default:…` — real key is `addfundsdescription`, `lagom clientareaaddfunds.tpl:15` `{$LANG.addfundsdescription}`; hadrian invented `addfundsintro`; map to `addfundsdescription`; strip default | high |
| 73 | text | All deposits are non-refundable. | WHMCS | {$LANG.addfundsnonrefundable} | real — `nexus/clientareaaddfunds.tpl:59` `{lang key='addfundsnonrefundable'}`; strip default | high |
| 79 | text | Make a deposit | CUSTOM | {$hadrianLang.billing.makeDeposit} | `makedeposit` invented card heading; no WHMCS key | med |
| 85 | text | Payment method | WHMCS | {$LANG.orderpaymentmethod} | `paymentmethod|default:'Payment method'` — real key is `orderpaymentmethod` ("Payment Method"), `nexus/clientareaaddfunds.tpl:45` + `lagom:17`; map to `orderpaymentmethod`; strip default. (Flat `paymentmethod` may also exist but `orderpaymentmethod` is the proven one) | high |
| 95 | text | Amount to add | WHMCS | {$LANG.addfundsamount} | `amounttoadd|default:…` — real key is `addfundsamount` ("Amount To Add"), `nexus/clientareaaddfunds.tpl:40` + `lagom:25`; hadrian invented `amounttoadd`; map to `addfundsamount`; strip default | high |
| 102 | aria-label | Preset amounts | CUSTOM | {$hadrianLang.billing.presetAmounts} | bare hardcoded a11y label; no WHMCS key | med |
| 112 | text | Current balance | CUSTOM | {$hadrianLang.billing.currentBalance} | `currentbalance` invented; no WHMCS key (refs have no live summary) | high |
| 116 | text | Deposit | CUSTOM | {$hadrianLang.billing.deposit} | `deposit` invented summary label; no WHMCS key | med |
| 120 | text | New balance | CUSTOM | {$hadrianLang.billing.newBalance} | `newbalance` invented; no WHMCS key | high |
| 126 | text | Add funds | WHMCS | {$LANG.addfunds} | submit button; dedupe of line 24 | high |
| 135 | text | Billing | CUSTOM | {$hadrianLang.billing.sidebarHeading} | bare literal; dedupe | high |
| 138 | text | My Invoices | WHMCS | {$LANG.navinvoices} | subnav; dedupe | high |
| 142 | text | My Quotes | WHMCS | {$LANG.navquotes} | subnav; dedupe | med |
| 146 | text | Mass Payment | WHMCS | {$LANG.masspaytitle} | subnav; map+strip; dedupe | high |
| 150 | text | Add Funds | WHMCS | {$LANG.addfunds} | subnav; dedupe | high |
| 154 | text | Payment Methods | WHMCS | {$LANG.paymentMethods.title} | subnav; nested; dedupe | high |

Notes: `{$afCurPrefix}`/`{$afBalance}`/`{$minimumamount}`/`{$maximumamount}`/`{$maximumbalance}`/`{$amount}`/`{$pm.*}`/`{$errormessage}`/`{$token}` dynamic → SKIP. Preset button labels `$10/$25/$50/$100` (lines 103-106) and `$…`/`—` placeholders (117/121) are currency-prefix + numeral output → SKIP. The `<script>` summary-calc block contains only DOM/number logic, no UI strings → no js-string rows. `<option>` gateway labels are `$pm.displayname` dynamic.

---

### hadrian/templates/hadrian/core/pages/masspay/default/default.tpl
| Line | Type | Current text | Class | Proposed reference | Evidence / Notes | Conf |
|------|------|--------------|-------|--------------------|------------------|------|
| 26 | text | Mass payment | WHMCS | {$LANG.masspaytitle} | H1; `masspayment|default:'Mass payment'` — real key `masspaytitle`, `nexus/masspay.tpl:6` `{lang key="masspaytitle"}`; map+strip | high |
| 27 | text | Pay multiple unpaid invoices in one transaction. | WHMCS | {$LANG.masspaydescription} | `masspaymentsub|default:…` — real key `masspaydescription`, `nexus/masspay.tpl:7` `{lang key="masspaydescription"}`; map to `masspaydescription`; strip default (wording differs) | high |
| 44 | text | Invoice | WHMCS | {$LANG.invoicestitle} | table header; hadrian `invoicenum` invented variant; map to real `invoicestitle`; strip default (cf. nexus masspay groups by `invoicenumber`, but column-header semantics → `invoicestitle`) | med |
| 45 | text | Due date | WHMCS | {$LANG.invoicesdatedue} | header; hadrian `invoicedatedue` invented variant; map to `invoicesdatedue`; strip default | high |
| 46 | text | Amount | WHMCS | {$LANG.invoicesamount} | header; hadrian `amount`; map to `invoicesamount`; strip | high |
| 66 | text | Total | WHMCS | {$LANG.invoicestotaldue} | `total|default:'Total'` summary — semantically the mass-pay grand total; real key `invoicestotaldue`, `nexus/masspay.tpl:70`; map to `invoicestotaldue` (or `invoicestotal` if "Total" wording load-bearing); flag | med |
| 74 | text | Payment method | WHMCS | {$LANG.orderpaymentmethod} | `paymentmethod|default:…` — real `orderpaymentmethod`, `nexus/masspay.tpl:88`; map+strip. NOTE nexus titles this card with `masspaymentselectgateway` ("Select Payment Method") — consider that instead | high |
| 87 | text | Pay now | WHMCS | {$LANG.paynow} | submit; `paynow|default:'Pay now'`. Real masspay button is `masspaymakepayment` ("Make Payment"), `nexus/masspay.tpl:97`; `paynow` is also a real generic key — strip default; flag two options | med |
| 93 | text | No unpaid invoices | WHMCS | {$LANG.nounpaidinvoices} | `nounpaidinvoices|default:…` — `nounpaidinvoices` is a standard WHMCS key; refs use `noinvoicesduemsg` for the same empty state (`lagom masspay.tpl:101`); map to `nounpaidinvoices` (or `noinvoicesduemsg`); strip default; flag | med |
| 94 | text | You are all caught up — no balance due. | CUSTOM | {$hadrianLang.billing.noUnpaidInvoicesSub} | `nounpaidinvoicessub` invented; no WHMCS body key | high |
| 95 | text | View all invoices | WHMCS | {$LANG.navinvoices} | `viewinvoices|default:'View all invoices'` invented key; map to real `navinvoices` (back-to-list) or keep CUSTOM; flag | med |

Notes: `{$inv.*}`/`{$totalamount}`/`{$pm.*}`/`{$mpCount}`/`{$errormessage}` dynamic → SKIP. `#{$inv.invoicenum}` is dynamic. The `<script>` check-all/row-sync block has no UI strings → no js-string rows. No `{$token}` field here (form posts `paynow` only — note: nexus masspay posts `geninvoice`; hadrian's missing CSRF token is a possible bug, out of i18n scope).

---

### hadrian/templates/hadrian/core/pages/invoice-payment/default/default.tpl
| Line | Type | Current text | Class | Proposed reference | Evidence / Notes | Conf |
|------|------|--------------|-------|--------------------|------------------|------|
| 13 | text | Pay invoice | WHMCS | {$LANG.invoicepay} | `payinvoice|default:'Pay invoice'` — invented key `payinvoice`; real `invoicepay` ("Pay Invoice") is the WHMCS key; map to `invoicepay` (or keep CUSTOM if "Pay invoice" title vs "Pay Now" matters); flag | med |
| 14 | text | Invoice | WHMCS | {$LANG.invoicestitle} | sub-line; `invoicenum` invented variant; map to `invoicestitle`; strip default; note "Invoice #{$invoicenum}" composite | med |
| 22 | text | Balance due | WHMCS | {$LANG.invoicesbalance} | `invoicebalance|default:'Balance due'` — real key `invoicesbalance` ("Balance"), `nexus/viewinvoice.tpl:282`; hadrian invented `invoicebalance`; map to `invoicesbalance`; strip default (wording shift) | high |
| 32 | text | Payment method | WHMCS | {$LANG.orderpaymentmethod} | `paymentmethod|default:…`; map to `orderpaymentmethod`; strip default; dedupe | high |
| 44 | text | Pay now | WHMCS | {$LANG.paynow} | submit; standard `paynow`; strip default; dedupe | med |
| 45 | text | Cancel | WHMCS | {$LANG.cancel} | real — `nexus/viewquote.tpl:204` + `nexus/clientareacancelrequest.tpl:60` `{lang key='cancel'}`; strip default | high |

Notes: `{$invoicenum}`/`{$invoiceid}`/`{$balance}`/`{$total}`/`{$pm.*}`/`{$errormessage}` dynamic → SKIP. No `{$token}` field (posts `paynow` to viewinvoice.php). SVG/URLs skipped.

---

### hadrian/templates/hadrian/viewbillingnote.tpl
| Line | Type | Current text | Class | Proposed reference | Evidence / Notes | Conf |
|------|------|--------------|-------|--------------------|------------------|------|
| 50 | text | Billing note | CUSTOM | {$hadrianLang.billing.billingNoteEyebrow} | `$itemTableTitle|default:'Billing note'` — `$itemTableTitle` is a WHMCS var (the server supplies the real title); the `|default` literal is the fallback only. No `$LANG` key; rebadge the fallback literal. (Keep `$itemTableTitle` as primary.) | med |
| 52 | text | Issued | WHMCS | {$LANG.billing.issuedate} | `billingissuedate|default:'Issued'` — real nested key `billing.issuedate` ("Issued Date"), `nexus/viewbillingnote.tpl:71` `{lang key='billing.issuedate'}`; hadrian invented flat `billingissuedate`; map to `billing.issuedate`; strip default | high |
| 61 | text | Issued by | WHMCS | {$LANG.billing.issuedby} | `invoicefrom|default:'Issued by'` — real nested `billing.issuedby`, `nexus/viewbillingnote.tpl:43`; map to `billing.issuedby`; strip default | high |
| 65 | text | Tax ID | WHMCS | {$LANG.taxIdLabel}? | `$taxIdLabel|default:'Tax ID'` — `$taxIdLabel` is a WHMCS VARIABLE (admin-configured label name, e.g. "VAT Number"), output via `{lang key=$taxIdLabel}` in nexus (`account-paymentmethods-manage.tpl:249`). The `|default:'Tax ID'` is just a fallback → keep `$taxIdLabel`, rebadge the literal as `{$hadrianLang.billing.taxIdFallback}` if a fallback is wanted. NOT a fixed WHMCS key | low |
| 69 | text | Issued to | WHMCS | {$LANG.billing.issuedto} | `invoicebillto|default:'Issued to'` — real nested `billing.issuedto`, `nexus/viewbillingnote.tpl:50`; map to `billing.issuedto`; strip default | high |
| 84 | text | Details | CUSTOM | {$hadrianLang.billing.detailsFallback} | `$itemTableTitle|default:'Details'` — same as line 50: `$itemTableTitle` is the WHMCS var; this `|default` literal differs ("Details" vs "Billing note"). Keep `$itemTableTitle`; rebadge fallback | low |
| 88 | text | Description | WHMCS | {$LANG.invoicesdescription} | real — `nexus/viewbillingnote.tpl:89`; strip default | high |
| 89 | text | Amount | WHMCS | {$LANG.invoicesamount} | real — `nexus/viewbillingnote.tpl:90`; hadrian `amount`; map+strip | high |
| 102 | text | Subtotal | WHMCS | {$LANG.invoicessubtotal} | real — `nexus/viewbillingnote.tpl:101`; strip default | high |
| 106 | text | Total | WHMCS | {$LANG.invoicestotal} | real — `nexus/viewbillingnote.tpl:111`; strip default | high |
| 112 | text | Transactions | WHMCS | {$LANG.billing.ledger.title} | nested real — `nexus/viewbillingnote.tpl:128`; hadrian `invoicestransactions` invented; map to `billing.ledger.title`; dedupe of viewinvoice:168 | high |
| 116 | text | Date | WHMCS | {$LANG.billing.ledger.date} | nested real — `nexus/viewbillingnote.tpl:134`; map; dedupe | high |
| 117 | text | Type | WHMCS | {$LANG.billing.ledger.type} | nested real — `nexus/viewbillingnote.tpl:135`; map; dedupe | high |
| 118 | text | Reference | WHMCS | {$LANG.billing.ledger.reference} | nested real — `nexus/viewbillingnote.tpl:136`; map; dedupe | high |
| 119 | text | Amount | WHMCS | {$LANG.invoicestransamount} | real — `nexus/viewbillingnote.tpl:137`; hadrian `amount`; map; dedupe of viewinvoice:175 | high |
| 132 | text | No transactions found. | WHMCS | {$LANG.invoicestransnonefound} | `invoicestransnonefound|default:'No transactions found.'` — real key, `nexus/viewbillingnote.tpl:150`; strip default (WHMCS wording differs); note key differs from viewinvoice's longer default but SAME key | high |
| 136 | text | Balance | WHMCS | {$LANG.invoicesbalance} | real — `nexus/viewbillingnote.tpl:154`; strip default; dedupe | high |
| 150 | text | Print | WHMCS | {$LANG.print} | real — `nexus/viewbillingnote.tpl:164` + `nexus/viewinvoice.tpl:298` `{lang key='print'}`; strip default | high |
| 151 | text | Back to billing | WHMCS | {$LANG.invoicesbacktoclientarea} | `invoicesbacktoclientarea|default:'Back to billing'` — real key, `nexus/viewbillingnote.tpl:169` + `nexus/viewinvoice.tpl:306`; strip default (WHMCS "Return to Client Area") | high |

Notes: `<title>` (line 23) is `{$companyname} - {$pagetitle}` — both dynamic → SKIP. `{$billingNote->*}`/`{$transactions}`/`{$item->*}`/`{$tax->*}`/`{$logo}`/`{$notes}`/`{$dateIssued}`/`{$issuedBy}`/`{$taxCode}`/`{$companyname}`/`{$pagetitle}`/`{$clientsdetails.*}` dynamic → SKIP. `<style>{literal}` block, SVG/URLs skipped. `alt="{$companyname}"` (line 43) is dynamic → SKIP.

---

### hadrian/templates/hadrian/core/pages/clientareacancelrequest/default/default.tpl
| Line | Type | Current text | Class | Proposed reference | Evidence / Notes | Conf |
|------|------|--------------|-------|--------------------|------------------|------|
| 46 | text | Service | WHMCS | {$LANG.clientareacancelproduct} | `clientareaservices|default:'Service'` eyebrow — `clientareaservices` real? not citable; the cancel "Product/Service" label is `clientareacancelproduct` (`nexus/clientareacancelrequest.tpl:22`); map to `clientareacancelproduct` OR keep `clientareaservices`; flag | med |
| 47 | text | Request cancellation | CUSTOM | {$hadrianLang.billing.cancelRequestTitle} | `clientareacancellationrequest` only ever `|default` — invented; nexus has no page H1 (alert-driven). Real button key `clientareacancelrequestbutton` ("Request Cancellation") exists — consider mapping; kept CUSTOM as a heading | med |
| 48 | text | Tell us how and when you want this service cancelled. | CUSTOM | {$hadrianLang.billing.cancelRequestSubtitle} | `clientareacancelintro` invented; no WHMCS subtitle | high |
| 57 | text | Cancellation requested | WHMCS | {$LANG.clientareacancelconfirmation} | real — `nexus/clientareacancelrequest.tpl:10` + `lagom:10` `clientareacancelconfirmation`; strip default | high |
| 58 | text | Your cancellation request has been received. The service will be cancelled as scheduled. | CUSTOM | {$hadrianLang.billing.cancelConfirmationSub} | `clientareacancelconfirmationsub` invented; `clientareacancelconfirmation` IS the full WHMCS message — this sub-line is bespoke elaboration; keep CUSTOM | med |
| 59 | text | Back to service | WHMCS | {$LANG.clientareabacklink} | `clientareabacklink|default:'Back to service'` — real key, `nexus/clientareacancelrequest.tpl:5/13` + `lagom:7/12`; strip default | high |
| 69 | text | Nothing to cancel | CUSTOM | {$hadrianLang.billing.cancelInvalidTitle} | `clientareacancelinvalid|default:'Nothing to cancel'` — real key `clientareacancelinvalid` EXISTS (`nexus:3` + `lagom:5`) but its WHMCS wording is the full sentence ("This product/service cannot be cancelled"), used as the message body, not a short title. hadrian splits it into title (this) + sub (line 70). Title is bespoke → CUSTOM; flag (real key reused as a 2-line split) | med |
| 70 | text | This service is not valid for cancellation, or it could not be found. | WHMCS | {$LANG.clientareacancelinvalid} | maps to the real `clientareacancelinvalid` message body; `nexus:3`; strip default (WHMCS wording differs) | high |
| 71 | text | My services | WHMCS | {$LANG.clientareanavservices} | `clientareanavservices|default:'My services'` — `clientareanavservices` real WHMCS nav key; default matches; strip default | high |
| 81 | text | Cancelling this service permanently removes all associated data including files, databases, and email accounts. | CUSTOM | {$hadrianLang.billing.cancelWarning} | `clientareacancelwarning` invented; no WHMCS warning key (nexus has no such callout) | high |
| 87 | text | Please provide a reason for cancellation. | WHMCS | {$LANG.clientareacancelreasonrequired} | real — `nexus/clientareacancelrequest.tpl:19` + `lagom:16`; strip default | high |
| 97 | text | Service | WHMCS | {$LANG.clientareacancelproduct} | real — `nexus/clientareacancelrequest.tpl:22` `{lang key='clientareacancelproduct'}` + `lagom:18`; default "Service" vs WHMCS "Product/Service"; strip default | high |
| 111 | text | Associated domain | WHMCS | {$LANG.cancelrequestdomain} | real — `nexus/clientareacancelrequest.tpl:38` + `lagom:32` `cancelrequestdomain`; strip default | high |
| 114 | text | Also cancel the domain registered with this service. | WHMCS | {$LANG.cancelrequestdomainconfirm} | real — `nexus/clientareacancelrequest.tpl:41` + `lagom:36` `cancelrequestdomainconfirm`; strip default | high |
| 120 | text | Cancellation type | WHMCS | {$LANG.clientareacancellationtype} | real — `nexus/clientareacancelrequest.tpl:47` + `lagom:41`; strip default | high |
| 122 | option | At end of billing period | WHMCS | {$LANG.clientareacancellationendofbillingperiod} | real — `nexus/clientareacancelrequest.tpl:51` + `lagom:46`; strip default (WHMCS "End of Billing Period") | high |
| 123 | option | Immediately | WHMCS | {$LANG.clientareacancellationimmediate} | real — `nexus/clientareacancelrequest.tpl:50` + `lagom:44`; strip default (WHMCS "Immediate") | high |
| 128 | text | Reason for cancellation | WHMCS | {$LANG.clientareacancelreason} | real — `nexus/clientareacancelrequest.tpl:32` + `lagom:28`; strip default | high |
| 129 | placeholder | Let us know why you are cancelling... | CUSTOM | {$hadrianLang.billing.cancelReasonPlaceholder} | `clientareacancelreasonplaceholder` invented; nexus textarea has no placeholder | med |
| 133 | text | Request cancellation | WHMCS | {$LANG.clientareacancelrequestbutton} | real — `nexus/clientareacancelrequest.tpl:58` + `lagom:51`; strip default | high |
| 134 | text | Keep service | CUSTOM | {$hadrianLang.billing.keepService} | `clientareacancelkeep` invented; nexus cancel-button-row uses `cancel` ("Cancel"); "Keep service" is bespoke; keep CUSTOM (or map to `{$LANG.cancel}`) | med |

Notes: lines 26-30 are DEMO `{assign}` under `?preview=1` (`'Cloud Hosting'`, `'Business Cloud Pro'`, `'hendersondesign.com'`) → SKIP. `{$groupname}`/`{$productname}`/`{$domain}`/`{$id}`/`{$domainnextduedate}` dynamic → SKIP. SVG/URLs skipped. NOTE: nexus has `cancelrequestdomaindesc` (sprintf2 with due date/price/period) which hadrian does NOT render — no row needed (absent string).

---

### hadrian/templates/hadrian/core/pages/account-paymentmethods/default/default.tpl
| Line | Type | Current text | Class | Proposed reference | Evidence / Notes | Conf |
|------|------|--------------|-------|--------------------|------------------|------|
| 39 | text | Payment Methods | WHMCS | {$LANG.paymentMethods.title} | H1; real nested — `nexus/account-paymentmethods.tpl:22`; strip default | high |
| 40 | text | Cards and bank accounts you have saved for fast checkout. | WHMCS | {$LANG.paymentMethods.intro} | real nested — `nexus/account-paymentmethods.tpl:23` `{lang key='paymentMethods.intro'}`; strip default (WHMCS wording differs) | high |
| 53 | text | Payment method added. | WHMCS | {$LANG.paymentMethods.addedSuccess} | real — `nexus/account-paymentmethods.tpl:2` + `lagom:5`; strip default | high |
| 54 | text | Could not add the payment method. | WHMCS | {$LANG.paymentMethods.addFailed} | real — `nexus:4` + `lagom:7`; strip default | high |
| 55 | text | Payment method updated. | WHMCS | {$LANG.paymentMethods.updateSuccess} | real — `nexus:6` + `lagom:9`; strip default | high |
| 56 | text | Could not save the changes. | WHMCS | {$LANG.paymentMethods.saveFailed} | real — `nexus:8` + `lagom:11`; strip default | high |
| 57 | text | Default payment method updated. | WHMCS | {$LANG.paymentMethods.defaultUpdateSuccess} | real — `nexus:10` + `lagom:13`; strip default | high |
| 58 | text | Could not change the default. | WHMCS | {$LANG.paymentMethods.defaultUpdateFailed} | real — `nexus:12` + `lagom:15`; strip default | high |
| 59 | text | Payment method removed. | WHMCS | {$LANG.paymentMethods.deleteSuccess} | real — `nexus:14` + `lagom:17`; strip default | high |
| 60 | text | Could not remove the payment method. | WHMCS | {$LANG.paymentMethods.deleteFailed} | real — `nexus:16` + `lagom:19`; strip default | high |
| 84 | text | Default | WHMCS | {$LANG.paymentMethods.default} | real — `nexus/account-paymentmethods.tpl:59` + `lagom:53`; strip default | high |
| 85 | text | Expired | CUSTOM | {$hadrianLang.billing.pmExpired} | `paymentMethods.expired` — NOT in nexus/lagom (they show `getStatus()` + no "Expired" tag); likely invented under the real namespace. Treat CUSTOM unless verified on server; flag | low |
| 93 | text | Set default | WHMCS | {$LANG.paymentMethods.setAsDefault} | real — `nexus/account-paymentmethods.tpl:62` + `lagom:56`; strip default (WHMCS "Set as Default") | high |
| 96 | text | Edit | WHMCS | {$LANG.paymentMethods.edit} | real — `nexus/account-paymentmethods.tpl:66` + `lagom:59`; strip default | high |
| 99 | text | Delete | WHMCS | {$LANG.paymentMethods.delete} | real — `nexus/account-paymentmethods.tpl:71` + `lagom:63`; strip default | high |
| 111 | text | Add new credit card | WHMCS | {$LANG.paymentMethods.addNewCC} | real — `nexus/account-paymentmethods.tpl:29` + `lagom:75`; strip default | high |
| 117 | text | Add bank account | WHMCS | {$LANG.paymentMethods.addNewBank} | real — `nexus/account-paymentmethods.tpl:33` + `lagom:79`; strip default | high |
| 125 | text | No payment methods yet | WHMCS | {$LANG.paymentMethods.noPaymentMethodsCreated} | real — `nexus/account-paymentmethods.tpl:79` + `lagom:90`; strip default (WHMCS "You have not saved…") | high |
| 126 | text | Add a card or bank account for faster checkout next time you pay an invoice. | WHMCS | {$LANG.paymentMethods.intro} | reuses `paymentMethods.intro` with a DIFFERENT default than line 40 — real key, but the two `|default`s diverge; strip default (one canonical string); flag divergent-default | med |
| 134 | text | Account | WHMCS | {$LANG.accounttab} | aside heading; `accounttab` WHMCS section key (core-resolved, see B08); strip default | med |
| 137 | text | Account Details | WHMCS | {$LANG.accountdetails} | aside; `accountdetails` WHMCS account key (core-resolved); strip default | med |
| 141 | text | User Management | WHMCS | {$LANG.usermanagement} | aside; WHMCS account key (core-resolved); strip default | med |
| 145 | text | Payment Methods | WHMCS | {$LANG.paymentMethods.title} | aside; flat `paymentmethods` default → nested real key; strip default; dedupe | high |
| 149 | text | Contacts | WHMCS | {$LANG.contacts} | aside; WHMCS account key (core-resolved); strip default | med |
| 153 | text | Security | WHMCS | {$LANG.securitysettings} | aside; `securitysettings` WHMCS key (core-resolved); default "Security"; strip default | med |
| 181 | js-string | Remove this payment method? This cannot be undone. | CUSTOM | {$hadrianLang.billing.pmDeleteConfirm} | `confirm('Remove this payment method? This cannot be undone.')` in `[data-pm-delete]` handler — bare JS literal. Real WHMCS `paymentMethods.deletePaymentMethodConfirm` (`nexus:97`) + `paymentMethods.areYouSure` exist; consider seeding `{$LANG.paymentMethods.deletePaymentMethodConfirm}` into a JS var instead. Kept CUSTOM because wording differs; seed from Smarty | med |

Notes: `{$payMethod->*}`/`{$pmType}`/`{$pmKind}`/`{$client->*}`/`{$token}`/`{$createSuccess}` etc. dynamic → SKIP. `'fa fa-credit-card'` (line 79) is an icon class fallback → SKIP. `{routePath}`/SVG/`data-pm-*` skipped. The hidden POST forms (162-163) carry only `{$token}`.

---

### hadrian/templates/hadrian/core/pages/account-paymentmethods-manage/default/default.tpl
| Line | Type | Current text | Class | Proposed reference | Evidence / Notes | Conf |
|------|------|--------------|-------|--------------------|------------------|------|
| 50 | text | Manage payment method | CUSTOM | {$hadrianLang.billing.pmManageTitle} | `paymentMethods.manage` — NOT in refs; nexus/lagom title with `paymentMethodsManage.editPaymentMethod` ("Edit Payment Method") / `addPaymentMethod`. Likely invented; map to `{$LANG.paymentMethodsManage.editPaymentMethod}` OR keep CUSTOM; flag | med |
| 51 | text | Update card details, change the default, or remove this payment method. | CUSTOM | {$hadrianLang.billing.pmManageIntro} | `paymentMethods.manageintro` invented; no WHMCS intro for this page | high |
| 66 | text | Default | WHMCS | {$LANG.paymentMethods.default} | real; dedupe of list:84 | high |
| 73 | text | Update card details | CUSTOM | {$hadrianLang.billing.pmUpdateCard} | `paymentMethods.updateCard` — not in refs; nexus/lagom have no such card title (form is inline). Invented; keep CUSTOM | med |
| 78 | text | Card | WHMCS | {$LANG.creditcardenterdetails} | `creditcardenterdetails|default:'Card'` — `creditcardenterdetails` is a standard WHMCS key ("Enter Card Details"); not citable in nexus/lagom templates (gateway-injected); strip default; flag wording "Card" vs "Enter Card Details" | low |
| 80 | text | Cardholder name | WHMCS | {$LANG.creditcardcardholdername} | standard WHMCS `creditcardcardholdername`; not citable in refs (nexus uses tokenized gateways); strip default | med |
| 84 | text | Card number | WHMCS | {$LANG.creditcardcardnumber} | real — `nexus/account-paymentmethods-manage.tpl:69` + `lagom:76` `{lang key='creditcardcardnumber'}`; strip default | high |
| 89 | text | Expiration | WHMCS | {$LANG.creditcardcardexpires} | real — `nexus/account-paymentmethods-manage.tpl:92` + `lagom:107`; strip default (WHMCS "Card Expiry Date") | high |
| 93 | text | CVV | WHMCS | {$LANG.creditcardcvvnumber} | real — `nexus/account-paymentmethods-manage.tpl:112` + `lagom:115`; strip default | high |
| 98 | text | Billing address | WHMCS | {$LANG.billingAddress} | `invoicespayto|default:'Billing address'` — WRONG key. Real key is `billingAddress` ("Billing Address"), `lagom account-paymentmethods-manage.tpl:172` + `nexus:170`; map to `{$LANG.billingAddress}`; strip default. Flag (hadrian used `invoicespayto` = "Pay To") | high |
| 100 | text | Street address | WHMCS | {$LANG.clientareaaddress1} | real — `nexus/account-paymentmethods-manage.tpl:259` + `lagom:253`; default "Street address" vs WHMCS "Address 1"; strip default | high |
| 105 | text | City | WHMCS | {$LANG.clientareacity} | real — `nexus:271` + `lagom:265`; strip default | high |
| 109 | text | State / region | WHMCS | {$LANG.clientareastate} | real — `nexus:277` + `lagom:282`; strip default (WHMCS "State/Region") | high |
| 115 | text | Postcode | WHMCS | {$LANG.clientareapostcode} | real — `nexus:283` + `lagom:288`; strip default | high |
| 119 | text | Country | WHMCS | {$LANG.clientareacountry} | real — `nexus:289` + `lagom:271`; strip default | high |
| 126 | text | Default payment method | WHMCS | {$LANG.paymentMethods.setAsDefault} | `paymentMethods.setAsDefault|default:'Default payment method'` — real key (default "Set as Default"); checkbox label; strip default; flag wording shift | med |
| 130 | text | Save changes | WHMCS | {$LANG.clientareasavechanges} | real — `nexus/account-paymentmethods-manage.tpl:181` + `lagom:189`; strip default | high |
| 131 | text | Cancel | WHMCS | {$LANG.cancel} | real — `nexus:182` + `lagom:190`; strip default; dedupe | high |
| 140 | text | Remove this payment method | CUSTOM | {$hadrianLang.billing.pmRemoveTitle} | `paymentMethods.removeTitle` — not in refs; nexus delete is modal-driven (`paymentMethods.areYouSure`). Invented; keep CUSTOM | med |
| 141 | text | This payment method will be deleted and can no longer be used for automatic payments. | CUSTOM | {$hadrianLang.billing.pmRemoveSub} | `paymentMethods.removeSub` invented; no WHMCS body | high |
| 142 | text | Remove this payment method? | WHMCS | {$LANG.paymentMethods.deletePaymentMethodConfirm} | `onsubmit="return confirm('…')"` — `paymentMethods.removeConfirm` invented; real `paymentMethods.deletePaymentMethodConfirm` (`nexus:97`); map (seed into JS) or keep CUSTOM; flag | med |
| 144 | text | Delete payment method | WHMCS | {$LANG.paymentMethods.delete} | `paymentMethods.delete|default:'Delete payment method'` — real key (default "Delete"); `nexus:71`; strip default; flag wording | high |
| 159 | text | No payment method selected | CUSTOM | {$hadrianLang.billing.pmNoneSelected} | `paymentMethods.noneSelected` invented; empty/preview state has no WHMCS analog | high |
| 160 | text | Choose a saved method to edit, or add a new one. | CUSTOM | {$hadrianLang.billing.pmNoneSelectedSub} | `paymentMethods.noneSelectedSub` invented | high |
| 161 | text | Add payment method | CUSTOM | {$hadrianLang.billing.pmAdd} | `paymentMethods.add` invented; refs use `addNewCC`/`addNewBank` (specific). Keep CUSTOM (generic add) | med |
| 170 | text | Account | WHMCS | {$LANG.accounttab} | aside heading; dedupe of list:134 | med |
| 173 | text | Account Details | WHMCS | {$LANG.accountdetails} | aside; dedupe | med |
| 177 | text | Payment Methods | WHMCS | {$LANG.paymentMethods.title} | aside; flat→nested; dedupe | high |
| 181 | text | Billing Contacts | CUSTOM | {$hadrianLang.billing.billingContacts} | `paymentMethods.billingContacts` — not in nexus/lagom; the billing-contacts page is hadrian-bespoke. Invented; keep CUSTOM; dedupe (manage + billing-contacts page) | med |
| 185 | text | Contacts | WHMCS | {$LANG.contacts} | aside; dedupe | med |

Notes: lines 26-29 are DEMO `{assign}` (`'Visa ending in 4242'`, `'Arshile Gogia - Expires 12 / 2027'`, `'VISA'`) → SKIP. `{$pmName}`/`{$pmSub}`/`{$pmBrand}`/`{$payMethod->*}`/`{$ccinfo.*}`/`{$countriesdropdown}`/`{$token}` dynamic → SKIP. Card-number/expiry/CVV `placeholder` masks `1234 1234 1234 1234` / `MM / YY` / `123` (lines 85/90/94) are format hints — borderline; per B07 backup-code-mask precedent they are user-visible but format-pattern → SKIP (note: tokenize as `pmCardNumberPlaceholder` etc. if Phase B wants masks). SVG/`autocomplete`/`{routePath}` skipped.

---

### hadrian/templates/hadrian/core/pages/account-paymentmethods-billing-contacts/default/default.tpl
| Line | Type | Current text | Class | Proposed reference | Evidence / Notes | Conf |
|------|------|--------------|-------|--------------------|------------------|------|
| 40 | text | Billing contacts | CUSTOM | {$hadrianLang.billing.billingContacts} | `paymentMethods.billingContacts` — not a real WHMCS key (nexus `account-paymentmethods-billing-contacts.tpl` is the manage-form radio partial, NOT a recipients page); invented; dedupe of manage:181 | med |
| 41 | text | Recipients copied on invoice and payment receipt emails. | CUSTOM | {$hadrianLang.billing.billingContactsIntro} | `paymentMethods.billingContactsIntro` invented; no WHMCS intro | high |
| 45 | text | Add billing contact | WHMCS | {$LANG.clientareanavaddcontact} | `clientareanavaddcontact|default:'Add billing contact'` — `clientareanavaddcontact` is a standard WHMCS nav key ("Add New Contact"); not citable in nexus/lagom templates (core-resolved); strip default; flag wording | med |
| 59 | text | Primary | WHMCS | {$LANG.primary} | `primary` is a standard WHMCS key ("Primary"); not citable in these refs; strip default | low |
| 77 | text | No billing contacts | CUSTOM | {$hadrianLang.billing.noBillingContacts} | `paymentMethods.noBillingContacts` invented; bespoke page empty state | high |
| 78 | text | Add a contact to copy them on invoice and receipt emails. | CUSTOM | {$hadrianLang.billing.noBillingContactsSub} | `paymentMethods.noBillingContactsSub` invented | high |
| 79 | text | Add billing contact | WHMCS | {$LANG.clientareanavaddcontact} | dedupe of line 45 | med |
| 63 | title | Edit | WHMCS | {$LANG.edit} | `edit|default:'Edit'` — `edit` is a standard WHMCS key; also `paymentMethods.edit` real; strip default | med |
| 87 | text | Account | WHMCS | {$LANG.accounttab} | aside heading; dedupe | med |
| 90 | text | Payment Methods | WHMCS | {$LANG.paymentMethods.title} | aside; flat→nested; dedupe | high |
| 94 | text | Billing Contacts | CUSTOM | {$hadrianLang.billing.billingContacts} | aside; dedupe of line 40 | med |
| 98 | text | Contacts | WHMCS | {$LANG.contacts} | aside; dedupe | med |
| 102 | text | Account Details | WHMCS | {$LANG.accountdetails} | aside; dedupe | med |

Notes: lines 17-20 are DEMO `{assign}` contacts (`'Arshile Gogia'`, `'finance@hendersondesign.com'`, etc.) → SKIP. `{$c.name}`/`{$c.email}`/`{$c.primary}` dynamic → SKIP. `'?'` (line 57 avatar fallback) is a single-char placeholder → SKIP. SVG/`{routePath}` skipped.

---

## New ambiguities (flag for the user)
1. **Parallel invented `invoice*` key set vs canonical WHMCS keys.** hadrian minted `invoicenum`, `invoicedatecreated`, `invoicedatedue`, `invoiceunpaid`, `invoicepaid`, `invoicecancelled`, `invoicedownload`, `amount`, `myinvoices`, `myquotes`, `quotenum`, `downloadpdf`, `quoteaccept`, `masspayment`, `paymentmethods`, `minamount`/`maxamount`/`maxbalance`, `amounttoadd`, `addfundsintro`, `invoicefrom`/`invoicebillto`, `totaldue`, `invoicebalance` — each shadowing a REAL WHMCS key (`invoicestitle`/`invoicesdatecreated`/`invoicesdatedue`/`invoicesunpaid`/`invoicespaid`/`invoicescancelled`/`invoicesdownload`/`invoicesamount`/`navinvoices`/`navquotes`/`quotenumber`/`quotedownload`/`quoteacceptbtn`/`masspaytitle`/`paymentMethods.title`/`addfundsminimum`/`addfundsmaximum`/`addfundsmaximumbalance`/`addfundsamount`/`addfundsdescription`/`invoicespayto`/`invoicesinvoicedto`/`invoicestotaldue`/`invoicesbalance`). Mapped to the real key per "prefer real keys", but **stripping the default WILL change visible wording** in several spots (e.g. "From"→"Pay To", "Bill to"→"Invoiced To", "Invoice details"→"Line Items", "Credit applied"→"Credit"). Confirm these wording shifts are acceptable, else rebadge as CUSTOM keeping the bespoke English.
2. **`billing.*` nested ledger keys.** The transaction-ledger labels (`billing.ledger.title/date/type/reference`, `billing.creditnote`, `billing.debitnote`) and billing-note headers (`billing.issuedby/issuedto/issuedate`) are REAL nested WHMCS keys (proven in `nexus/viewinvoice.tpl` + `nexus/viewbillingnote.tpl`) but hadrian reinvented them flat (`invoicestransactions`, `invoicestransdate`, `invoicestype`, `invoicesrefnum`, `invoicefrom`, `billingissuedate`). Mapped to the nested real keys. Two rows (viewinvoice:183 "Credit Note"/"Debit Note") were **bare hardcoded literals** with no key at all.
3. **`$LANG.billing` ARRAY trap — Billing sub-nav heading.** Every billing page's subnav card heading is a **bare literal `Billing`** (correct — avoids the "Array" bug per memory). I propose `{$hadrianLang.billing.sidebarHeading}` so Phase B can tokenize it. **Do NOT "fix" it to `{$LANG.billing}`** — that reintroduces the literal-"Array" bug.
4. **Real key, divergent `|default` literals.** `paymentMethods.intro` carries "Cards and bank accounts you have saved for fast checkout." (list:40) AND "Add a card or bank account for faster checkout…" (list:126) — same key, two defaults. Stripping resolves to one WHMCS string; the second visible text changes. Also `invoicestransnonefound` has a long default in viewinvoice (188) vs short in viewbillingnote (132); `invoicesdownload` default "Download PDF" vs "Download"; `clientareacancelinvalid` used as both a short title and a body sentence.
5. **`paymentMethods.*` keys that may be invented under a real namespace.** `paymentMethods.expired`, `paymentMethods.manage`, `paymentMethods.manageintro`, `paymentMethods.updateCard`, `paymentMethods.removeTitle/removeSub/removeConfirm`, `paymentMethods.noneSelected(Sub)`, `paymentMethods.add`, `paymentMethods.billingContacts(Intro)`, `paymentMethods.noBillingContacts(Sub)` do NOT appear in nexus/lagom. They USE the genuine `paymentMethods.` prefix but the suffixes are unverifiable — treated CUSTOM. **Verify against server `lang/english.php`**; some (e.g. `expired`) may be real.
6. **`$itemTableTitle` / `$taxIdLabel` are WHMCS VARIABLES, not keys.** In viewbillingnote, `{$itemTableTitle|default:'Billing note'/'Details'}` and `{$taxIdLabel|default:'Tax ID'}` output server-supplied values; only the `|default` fallback literal is bespoke. Keep the variable as primary; rebadge the fallback literal (do NOT replace the var with a static key).
7. **DataTables JS strings (`common.*`).** The pager/info builders in clientareainvoices + clientareaquotes hardcode "Previous page"/"Next page"/"Showing %s–%s of %s" in JS (and as static markup). Proposed a shared `hadrianLang.common.*` set seeded from Smarty. No WHMCS equivalent (WHMCS' own DataTables lang is internal). The "of"/"Showing"/"Show"/"entries" fragments are risky to translate as standalone words — prefer the composite `tableShowingRange` key for the JS path.
8. **`masspay` / `invoice-payment` missing CSRF `{$token}`.** Out of i18n scope, but noted: nexus masspay posts `geninvoice` + token; hadrian posts only `paynow`. Flag for a separate review.
9. **Core-resolved account nav keys** (`accounttab`, `accountdetails`, `usermanagement`, `contacts`, `securitysettings`) reused in the paymentmethods asides are genuine WHMCS keys resolved in core navbar PHP (per B08) — kept WHMCS/med, "verify in lang/english.php; strip default".

---

## Proposed custom keys
```
hadrianLang.common.filterAll          = "All"
hadrianLang.common.tableShow          = "Show"
hadrianLang.common.tableEntries       = "entries"
hadrianLang.common.tableShowing       = "Showing"
hadrianLang.common.tableOf            = "of"
hadrianLang.common.tableShowingRange  = "Showing %s–%s of %s"
hadrianLang.common.rowsPerPage        = "Rows per page"
hadrianLang.common.previousPage       = "Previous page"
hadrianLang.common.nextPage           = "Next page"

hadrianLang.billing.sidebarHeading    = "Billing"
hadrianLang.billing.summary           = "Summary"

hadrianLang.billing.invoicesSubtitle  = "Pay unpaid invoices, download PDFs, and review past payments."
hadrianLang.billing.payAllUnpaid      = "Pay all unpaid"
hadrianLang.billing.unpaidInvoiceSingular = "unpaid invoice"
hadrianLang.billing.unpaidInvoicePlural   = "unpaid invoices"
hadrianLang.billing.noInvoicesTitle   = "No invoices yet"
hadrianLang.billing.noInvoicesSub     = "When you purchase a service or a new billing cycle begins, your invoices will appear here."
hadrianLang.billing.browseServices    = "Browse services"
hadrianLang.billing.viewInvoice       = "View Invoice"
hadrianLang.billing.payInvoice        = "Pay Invoice"
hadrianLang.billing.issuedOn          = "Issued"
hadrianLang.billing.dueOn             = "Due"
hadrianLang.billing.amountDue         = "Amount due"
hadrianLang.billing.invoiceNotFoundTitle = "Invoice not found"
hadrianLang.billing.invoiceNotFoundSub   = "This invoice doesn't exist or has been removed from your account."

hadrianLang.billing.quotesSubtitle    = "Review delivered proposals, accept to convert into an invoice, or download as PDF."
hadrianLang.billing.quoteDeliveredSingular = "quote awaiting your decision"
hadrianLang.billing.quoteDeliveredPlural   = "quotes awaiting your decision"
hadrianLang.billing.noQuotesTitle     = "No quotes yet"
hadrianLang.billing.noQuotesSub       = "When our team prepares a proposal for you, it will show up here."
hadrianLang.billing.contactSales      = "Contact sales"
hadrianLang.billing.viewQuote         = "View Quote"
hadrianLang.billing.quoteNumberHash   = "#"
hadrianLang.billing.quoteUnavailableTitle = "Quote unavailable"
hadrianLang.billing.quoteUnavailableSub   = "This quote has expired or is no longer available. Visit My Quotes to see your active proposals."
hadrianLang.billing.backToQuotes      = "Back to quotes"

hadrianLang.billing.addFundsSubtitle  = "Top up your account credit to cover upcoming invoices automatically."
hadrianLang.billing.creditBalanceLabel = "Your credit balance is"
hadrianLang.billing.creditAppliesNext = "Applied automatically to new invoices"
hadrianLang.billing.makeDeposit       = "Make a deposit"
hadrianLang.billing.presetAmounts     = "Preset amounts"
hadrianLang.billing.currentBalance    = "Current balance"
hadrianLang.billing.deposit           = "Deposit"
hadrianLang.billing.newBalance        = "New balance"

hadrianLang.billing.noUnpaidInvoicesSub = "You are all caught up — no balance due."

hadrianLang.billing.billingNoteEyebrow = "Billing note"
hadrianLang.billing.detailsFallback   = "Details"
hadrianLang.billing.taxIdFallback     = "Tax ID"

hadrianLang.billing.cancelRequestTitle    = "Request cancellation"
hadrianLang.billing.cancelRequestSubtitle = "Tell us how and when you want this service cancelled."
hadrianLang.billing.cancelConfirmationSub = "Your cancellation request has been received. The service will be cancelled as scheduled."
hadrianLang.billing.cancelInvalidTitle    = "Nothing to cancel"
hadrianLang.billing.cancelWarning         = "Cancelling this service permanently removes all associated data including files, databases, and email accounts."
hadrianLang.billing.cancelReasonPlaceholder = "Let us know why you are cancelling..."
hadrianLang.billing.keepService           = "Keep service"

hadrianLang.billing.pmExpired         = "Expired"
hadrianLang.billing.pmDeleteConfirm   = "Remove this payment method? This cannot be undone."
hadrianLang.billing.pmManageTitle     = "Manage payment method"
hadrianLang.billing.pmManageIntro     = "Update card details, change the default, or remove this payment method."
hadrianLang.billing.pmUpdateCard      = "Update card details"
hadrianLang.billing.pmRemoveTitle     = "Remove this payment method"
hadrianLang.billing.pmRemoveSub       = "This payment method will be deleted and can no longer be used for automatic payments."
hadrianLang.billing.pmNoneSelected    = "No payment method selected"
hadrianLang.billing.pmNoneSelectedSub = "Choose a saved method to edit, or add a new one."
hadrianLang.billing.pmAdd             = "Add payment method"
hadrianLang.billing.billingContacts   = "Billing Contacts"
hadrianLang.billing.billingContactsIntro = "Recipients copied on invoice and payment receipt emails."
hadrianLang.billing.noBillingContacts    = "No billing contacts"
hadrianLang.billing.noBillingContactsSub = "Add a contact to copy them on invoice and receipt emails."
```
