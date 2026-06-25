# i18n Audit - Consolidation Notes

Consolidation of the 17 batch reports (B01..B14b) in this directory into
`_HADRIAN-LANG-DRAFT.php`. The draft contains **only genuine CUSTOM strings** (no
native WHMCS `$_LANG` key covers them), deduped by `group.key`, merged on top of
the legacy `core/lang/english.php` groups (footer / error / license / admin).

---

## Per-batch totals

Counts are read from each report's own `## Summary`. "Total rows" = in-scope table
rows reported (incl. dedupe repeats and, for some batches, a few in-table SKIP `-`
rows). "js-string" is the count the report tagged `js-string`; in most batches the
js rows are a **subset** of the CUSTOM (or WHMCS) totals, not additive.

| Batch | Files | Total rows | WHMCS | CUSTOM | js-string |
|-------|-------|-----------:|------:|-------:|----------:|
| B01 cart-viewcart        | 6  | 26  | 9   | 15 | 0  |
| B02 cart-checkout        | 8  | 33  | 8   | 25 | 0  |
| B03 cart-configure       | 5  | 94  | 41  | 39 | 14 |
| B04 cart-domains-products| 6  | 80  | 16  | 64 | 1  |
| B05 cart-misc            | 9  | 2   | 2   | 0  | 0  |
| B06 auth-core            | 6  | 115 | 60  | 52 | 0  |
| B07 auth-password-2fa    | 9  | 33  | 21  | 12 | 2  |
| B08 chrome               | 13 | 96  | 75  | 21 | 0  |
| B08b chrome-misc         | 12 | 18  | 9   | 9  | 0  |
| B09 dashboard            | 2  | 113 | 74  | 37 | 0  |
| B10 services             | 7  | 121 | 88  | 33 | 0  |
| B11 domains              | 11 | 159 | 117 | 42 | 1  |
| B12 billing              | 14 | 316 | 227 | 89 | 7  |
| B13a support             | 11 | 143 | 93  | 50 | 3  |
| B13b kb-content          | 13 | 217 | 139 | 78 | 1  |
| B14a account             | 11 | 177 | 141 | 32 | 7  |
| B14b users-ssl           | 13 | 173 | 121 | 47 | 5  |
| **GRAND TOTAL**          | **156** | **1936** | **1241** | **655** | **41** |

Notes on the grand total:
- A handful of batches report a Total that is 2-3 higher than WHMCS+CUSTOM because
  they list in-table SKIP (`-`) rows (B01 +2, B06 +3, B09 +2, B14a +4). The
  WHMCS/CUSTOM columns are summed as reported.
- The **655 raw CUSTOM rows** collapse to **627 distinct custom keys after dedupe**
  (see next section). The shrink is small here because most cross-batch repeats
  (stepper labels, trust badges, "Copied", pager affixes) were already deduped
  *within* the cart / billing / support reports before consolidation; the
  remaining cross-batch merges are listed under "Collisions / conflicts".
- js-string rows are a subset of CUSTOM/WHMCS (not additive); the ~41 figure
  includes rows that map to WHMCS keys (e.g. B13a/B14a pager + confirm dialogs),
  so only ~25 of them are genuinely custom js literals.

---

## Distinct custom-key count per group (after dedupe)

From the built `_HADRIAN-LANG-DRAFT.php` (counted programmatically). Legacy
footer/error/license/admin leaves that were merged from `core/lang/english.php` are
**excluded** here except `footer.tagline`, which is a new custom string.

| Group     | Distinct custom keys |
|-----------|---------------------:|
| common    | 24  |
| nav       | 4   |
| footer    | 1   (tagline; allRightsReserved/poweredBy are reused legacy) |
| auth      | 36  |
| dashboard | 29  |
| services  | 77  |
| domains   | 64  |
| billing   | 63  |
| support   | 86  |
| account   | 64  |
| ssl       | 23  |
| network   | 15  |
| cart      | 127 |
| devchip   | 14  (dev-only; drop before shipping) |
| **TOTAL** | **627** |

(The PHP file additionally carries the 20 pre-existing legacy leaves under
footer/error/license/admin, so the file's total leaf count is 646.)

---

## Collisions / conflicts resolved

1. **`licenseRequiredTitle` casing** (B08 header.tpl vs B08b error/license-required.tpl).
   - header.tpl: "Theme License Required" (Title case) - **chosen canonical**.
   - error/license-required.tpl: "Theme license required" (sentence case) - dropped.
   - One key: `common.licenseRequiredTitle = "Theme License Required"`.

2. **`allRightsReserved` / `poweredBy` already exist as legacy custom keys.**
   They live in `core/lang/english.php` under the `footer` group (the legacy
   `$rslang` namespace). The chrome templates duplicate `allRightsReserved` as an
   invented `{$LANG.allrightsreserved|default:...}` (B08). **Reused the existing
   legacy `footer.allRightsReserved`; did NOT mint a new key.** `poweredBy` was
   already only legacy.

3. **`cartsecured` bound to conflicting literals across files** (B01/B02/B03).
   The same invented `cartsecured` key carried three different English literals:
   - "256-bit SSL - PCI-DSS Level 1" (viewcart.tpl:1525, summary-aside.tpl:100)
   - "Secured by 256-bit SSL - PCI-DSS Level 1" (configureproduct.tpl:588)
   Resolved by splitting into **two distinct keys** preserving both literals
   (they render in different spots): `cart.trustSsl = "256-bit SSL - PCI-DSS Level 1"`
   (badge/aside) and `cart.securedNote = "Secured by 256-bit SSL - PCI-DSS Level 1"`
   (configure footer). Listed here as the conflict the auditors flagged.

4. **Cart stepper labels deduped across 4 cart pages** (B01/B02/B03). viewcart,
   checkout, configureproduct, configureproductdomain, configuredomains each
   reported their own `stepChoosePlan / stepDomain / stepConfigure / stepCart /
   stepCheckout / stepChooseDomain / checkoutProgress`. Collapsed to ONE set under
   `cart.*`. (B02 had proposed `cart.chooseProduct = "Choose plan"` for the same
   string as `stepChoosePlan` - merged into `stepChoosePlan`; B02 `lastChanceBadge`
   merged into `cart.lastChance`.)

5. **Trust / last-chance / money-back badges deduped** (B01/B02). `lastChance`,
   `lastChanceTitle`, `oneClickAdd`, `trustMoneyBack`/`moneyBackBadge`,
   `backToCart`, `checkoutProgress` appeared in both viewcart and checkout - one key each.

6. **Pager / DataTables affixes deduped across list pages** (B10/B11/B12/B13a/B14a).
   "Show / entries / Showing / of / Previous page / Next page / Rows per page /
   Showing %s-%s of %s / All" were re-proposed per batch under each batch's own
   group (`services.*`, `domains.*`, `billing.common.*`, `support.*`, `account.*`).
   **Consolidated to a single `common.*` set** (`common.tableShow`, `tableEntries`,
   `tableShowing`, `tableOf`, `tableShowingRange`, `previousPage`, `nextPage`,
   `rowsPerPage`, `filterAll`). NOTE B13a + B14a flagged `previouspage`/`nextpage`
   as **real WHMCS keys** (`$LANG.previouspage`/`$LANG.nextpage`) - those page-nav
   words are dropped to WHMCS (see next section); the kept `common.previousPage`/
   `nextPage` cover the bespoke a11y/aria + JS-pager usages on the list pages whose
   auditors classed them CUSTOM (B11/B12/B10). Flagged as needing one decision: if
   `previouspage`/`nextpage` are confirmed real, fold these into the WHMCS keys too.

7. **"Copied" / "Copy link" deduped.** "Copied" JS toast appears in B07 (2FA),
   B11 (getepp), B13b (announcement), B14b (affiliates). Mapped to a per-group
   `copied` where the surrounding context differs (auth/domains/support) and to
   `common.copied`; the B14b affiliate + B14b SSL pages explicitly reuse
   `common.copied`. Kept context copies where the report deduped within-batch.

8. **`backToHome` triple-spec** (B13b contact). "Back to home" is (a) invented
   `LANG.backtohome`, (b) already the legacy custom `error.backHome`, (c) the real
   WHMCS `errorPage.404.home`. **Did not mint a new key** - it maps to the existing
   legacy `error.backHome` if kept custom, else to WHMCS (recorded in "Dropped").

9. **Status pills `Active/Pending/Suspended/...`** (B10). Kept as
   `services.status*` custom because the auditor classed the invented `statusactive`
   etc. CUSTOM, BUT flagged the real WHMCS twins (`clientareaactive` etc.) under
   "Needs server verification" - if confirmed they flip to WHMCS.

10. **Variant labels split into `devchip` group** (B04 products, B09 dashboard).
    "Variant A-H" (cart) + "Variant A-F" (dashboard) are dev-only `?preview=1`
    scaffolding. Per the task they live in a separate `devchip` group (cart =
    `cartVariant*`, dashboard = `dashVariant*`) so they are trivial to drop. NOT
    mixed into `cart`/`dashboard`.

11. **state-chip.tpl (~40 dev strings) intentionally NOT enumerated** (B08b). The
    whole partial is gated `?preview=1` and never reaches end users; the auditor
    recommended SKIP. Not added (would otherwise be a large `devchip` block).

12. **Divergent `|default` literals on the same real key** were resolved by the
    auditors in favor of the WHMCS string (those rows are WHMCS, not custom) -
    noted in "Dropped". Where hadrian used a real key with a *bespoke* literal that
    must persist, a custom key was minted instead (e.g. `services.enabledState`/
    `disabledState` because `$LANG.yes/no` = "Yes"/"No"; the `services.cycle*Short`
    abbreviations because `$LANG.monthly..` = full words).

---

## Dropped from custom (-> real WHMCS key)

Proposed-custom keys excluded because a real WHMCS twin exists. These become
`{$LANG.realkey}` in Phase B, NOT custom strings. (Grouped; the arrow shows the
real key the auditor identified.)

### Auth (B06/B07)
- `loginforgotten` / `auth.forgotPassword` -> `$LANG.forgotpw`
- `clientareanavlogin` / `auth.signInTitle` -> `$LANG.clientareahomeloginbtn`
- `orcontinuewith` / `auth.orContinueWith` -> `$LANG.or`
- `dontHaveAccount` -> `$LANG.userLogin.notRegistered`
- `createaccount`(->"Create one") -> `$LANG.userLogin.createAccount`
- `loginnonews` / `auth.noAnnouncements` -> `$LANG.noannouncements`
- `loginpassword` -> `$LANG.clientareapassword`
- clientregister: `personalinformation` -> `$LANG.orderForm.personalInformation`;
  `billingaddress` -> `$LANG.orderForm.billingAddress`; `optional` ->
  `$LANG.orderForm.optional`; `password` -> `$LANG.clientareapassword`;
  `confirmpassword` -> `$LANG.clientareaconfirmpassword`
- `useBackupCode` candidate -> `$LANG.twofaloginusingbackupcode` (kept custom only
  because paired with the no-key TOTP direction; flagged)
- `done` candidate -> `$LANG.continue` (kept custom; wording shift)

### Errors (B06)
- `bannedreason` -> `$LANG.bannedbanreason`; `bannedexpires` -> `$LANG.bannedbanexpires`
- `accessdeniedheading` -> `$LANG.subaccountpermissiondenied`; access-denied title -> `$LANG.oops`
- banned/access-denied `Contact support` -> `$LANG.contactus`;
  `Back to dashboard` -> `$LANG.returnclient`

### Chrome / nav (B08, B08b)
- Footer copyright literal -> reuses legacy `footer.allRightsReserved` (not WHMCS).
- Locale section labels: `languagechoose` -> `$LANG.chooselanguage`;
  `currencychoose` -> `$LANG.choosecurrency`; `Close` -> `$LANG.close`;
  `Apply` -> `$LANG.apply`
- Captcha "Type the characters..." -> `$LANG.captchaverify`
- verifyemail: `emailSent`/`error`/`verifyEmailAddress`/`resendEmail`/`Dismiss(close)` -> real keys
- Cookie button "Continue" -> `$LANG.continue`
- A large class of core-resolved nav/section keys (`clientareanavhome`,
  `servicestab`, `accounttab`, `invoicestab`, `supporttickets`, `navchangedetails`,
  `navsecurity`, `navemailshistory`, `accountdetails`, `usermanagement`, `contacts`,
  `emailstitle`, `yourprofile`, `switchaccount`, `clientareanavchangepassword`,
  `securitysettings`, `home`, `shop`, `createaccount`, `searchbutton`, `logout`,
  `login`, `notifications`, `nonotifications`, `carttitle`, `paymentMethods.title`)
  -> kept WHMCS (med/low conf, see "Needs server verification").

### Dashboard (B09)
- `networkstatus` -> `$LANG.networkstatustitle`
- `domainsearch` -> `$LANG.navdomainsearch`
- `productsservices` -> `$LANG.clientHomePanels.productsAndServices`
- `renew` -> `$LANG.domainrenew`
- `unpaidinvoices` -> `$LANG.clientHomePanels.unpaidInvoices`
- `opennewticket` -> `$LANG.navopenticket`
- homepage `homepage.*` set: `youraccount`/`manageservices`/`managedomains`/
  `supportrequests`/`submitticket`/`makepayment` -> `$LANG.homepage.yourAccount`
  /`.manageServices`/`.manageDomains`/`.supportRequests`/`.submitTicket`/`.makeAPayment`
- homepage `browseproducts` -> `$LANG.browseProducts`; `transferdomain`(card) ->
  `$LANG.transferYourDomain`; `secureYourDomain`, `howCanWeHelp`, `exampledomain`,
  `orderregisterdomain` -> real keys
- `viewall` -> `$LANG.viewall`; `or` -> `$LANG.or`

### Cart (B01-B05)
- viewcart H1 "Your cart" -> `$LANG.cartreviewcheckout` (NOT `viewcart`)
- `cartempty`, `orderForm.continueShopping`, `orderForm.edit`, `viewcart`(sidebar),
  `actions` -> real keys (strip default)
- B02 checkout: `orderForm.optional`, `orderForm.createAccount`,
  `orderForm.alreadyRegistered`, `ordersummary`, `ordertotalduetoday`,
  `orderpaymentmethod`, `checkout` -> real keys
- B03 configure: `orderconfigure`, `domain`, `domaincheckerchoosedomain`,
  `ordersummary`, `orderPromoCodePlaceholder`, `orderpromovalidatebutton`,
  `cartdomainsconfig`, `orderForm.reviewDomainAndAddons`, `orderregperiod`,
  `orderyears`, `hosting`, `cartdomainshashosting`, `cartdomainsnohosting`,
  `domaineppcode`, `domaindnsmanagement`, `orderForm.addToCart`, `domainidprotection`,
  `domainemailforwarding`, `domainnameservers`, `cartnameserversdesc`,
  `domainnameserver1..5`, `continue`, `yourdomainplaceholder`, `yourtldplaceholder` -> real
- B04: `transferdomain`, `orderForm.transferExtend`, `orderForm.enterDomain`,
  `orderForm.addToCart`, `orderForm.authCode(Tooltip)(Placeholder)`, `orderForm.help`,
  `orderForm.required`, `cartSimpleCaptcha`, `orderForm.extendExclusions`,
  `orderForm.close`, `ordernewservices`, `changecurrency` -> real keys
- B05: `recommendations.learnMore`, `cartproductaddons` -> real keys (the only 2
  rows in B05; zero custom)

### Services (B10)
- `viewall`, `all`, `search`, `actions`, `manageproduct`, `manage`, `overview`,
  `information`, `usagestats`, `clientareahostingaddons`, `billingOverview`,
  `productsservices`, `clientareaservices`, `myservices`, `ordernewservices`,
  `viewavailableaddons`, `cancellationrequest`/`requestcancellation`, `upgrade`,
  `upgradedowngrade`, `upgradecurrentconfig`, `upgradenewconfig`, `enable`,
  `ordercontinuebutton`, `cancel`, `orderfree`, `orderpaymenttermonetime`,
  `upgradecurrentplan`, `upgradedowngradechooseproduct`, `invoices`,
  `upgradeerroroverdueinvoice`, `upgradeexistingupgradeinvoice`, `upgradeNotPossible`,
  `clientareanavservices`, `upgradeconfigure`, `ordersummary`, `ordertotalduetoday`,
  `orderdesc`, `upgradeproductlogic`, `days`, `orderpromotioncode`, `orderdontusepromo`,
  `orderpromovalidatebutton`, `orderpaymentmethod`, `paymentmethoddefault`,
  `orderForm.checkout`, `ordersubtotal`, `somethingwentwrong`, `newslettersubscribed`,
  `newsletterremoved`, `returnhome`, `metrics.pricing`, `metrics.includedInBase`,
  column headers (`clientareaaddonpricing`, `clientareahostingnextduedate`,
  `clientareastatus`, `orderproduct`), product-detail rows (`servername`,
  `serverusername`, `primaryIP`, `assignedIPs`, `domainnameservers`, `diskSpace`,
  `bandwidth`, `clientarealastupdated`, `serverchangepassword`, `newpassword`,
  `confirmnewpassword`, `clientareasavechanges`, `quickShortcuts`, `clientareahostingregdate`,
  `recurringamount`, `paymentmethod`, `firstpaymentamount`, `renewService.titleSingular`,
  `cancellationrequestedexplanation`, `payInvoice`, `productdetails`) -> real keys
- `serviceLower`("service") kept CUSTOM (no clean WHMCS singular-lower); `servicesLower` custom

### Domains (B11)
- Trap fixes (invented -> real, value corrected): `status`->`domainstatus`,
  `autorenew`->`domainsautorenew`, `managens`->`domainmanagens`,
  `editcontactinfo`->`domaincontactinfoedit`, `autorenewstatus`->`domainautorenewstatus`,
  `dnsmanagement`->`domaindnsmanagement`, `emailforwarding`->`domainemailforwarding`,
  `pricingregister/transfer/renewal`->`pricing.register/.transfer/.renewal`,
  `payinvoice`->`payInvoice`, `domainaddonsbuynow` (relabel "Add"/"Price"->"Buy now")
- ~90 further real keys across clientareadomaindetails / dns / contactinfo /
  emailforwarding / getepp / registerns / addons / bulkdomainmanagement /
  domain-pricing (e.g. `navdomains`, `registeradomain`, `transferadomain`, `all`,
  `statusactive`, `expiringsoon`, `domain`, `registered`, `managedomain`, `renew`,
  `show`, `entries`, `showing`, `of`, `clientareasavechanges`, `clientareacancel`,
  `domaindns*`, `domaincontact*`, `domainreg*`, `domainaddons*`, `category`,
  `domaintld`, etc.) -> real keys
- `privatenameservers` ("Glue records"), `registered`, `locked`/`unlocked`,
  `enabled`/`disable`, `manage` -> real keys (wording shift acceptable)

### Billing (B12) - the big invented-twin set
- `invoicenum`->`invoicestitle`, `invoicedatecreated`->`invoicesdatecreated`,
  `invoicedatedue`->`invoicesdatedue`, `invoiceunpaid`->`invoicesunpaid`,
  `invoicepaid`->`invoicespaid`, `invoicecancelled`->`invoicescancelled`,
  `invoicedownload`->`invoicesdownload`, `amount`->`invoicesamount`,
  `myinvoices`/`invoices`->`navinvoices`, `myquotes`/`quotestitle`->`navquotes`,
  `quotenum`/`quotetitle`->`quotenumber`, `downloadpdf`->`quotedownload`,
  `quoteaccept`->`quoteacceptbtn`, `masspayment`->`masspaytitle`,
  `paymentmethods`->`paymentMethods.title`, `minamount`->`addfundsminimum`,
  `maxamount`->`addfundsmaximum`, `maxbalance`->`addfundsmaximumbalance`,
  `amounttoadd`->`addfundsamount`, `addfundsintro`->`addfundsdescription`,
  `invoicefrom`->`invoicespayto`, `invoicebillto`->`invoicesinvoicedto`,
  `totaldue`->`invoicestotaldue`, `invoicebalance`->`invoicesbalance`,
  `invoicedetails`->`invoicelineitems`, `invoicescredit` (strip default)
- Nested ledger keys: `invoicestransactions`->`billing.ledger.title`,
  `invoicestransdate`->`billing.ledger.date`, `invoicestype`->`billing.ledger.type`,
  `invoicesrefnum`->`billing.ledger.reference`, "Credit Note"/"Debit Note"->
  `billing.creditnote`/`billing.debitnote`, `billingissuedate`->`billing.issuedate`,
  `invoicefrom`(billingnote)->`billing.issuedby`, `invoicebillto`(billingnote)->`billing.issuedto`
- Payment-methods page: ~30 real `paymentMethods.*` keys (`title`, `intro`,
  `addedSuccess`..`deleteFailed`, `default`, `setAsDefault`, `edit`, `delete`,
  `addNewCC`, `addNewBank`, `noPaymentMethodsCreated`), card fields
  (`creditcardcardnumber`, `creditcardcardexpires`, `creditcardcvvnumber`,
  `billingAddress`, `clientareaaddress1/city/state/postcode/country`), `cancel`,
  `clientareasavechanges`, `clientareanavaddcontact`, `primary`, `edit`
- Cancel-request: `clientareacancelproduct`, `clientareacancelconfirmation`,
  `clientareabacklink`, `clientareacancelinvalid`, `clientareacancelreasonrequired`,
  `cancelrequestdomain(confirm)`, `clientareacancellationtype/endofbillingperiod/immediate`,
  `clientareacancelreason`, `clientareacancelrequestbutton`, `clientareanavservices` -> real
- `addfundsnonrefundable`, `addfundsminimum/maximum/maximumbalance`, `paynow`,
  `nounpaidinvoices`, `masspaydescription`, `print`, `invoicesbacktoclientarea`,
  `invoicestransnonefound`, `invoicesbalance`, `invoicesdescription`, `invoicessubtotal`,
  `invoicestotal`, `invoicestax`, `invoicestaxindicator`, `invoicesnotes`,
  `ordertosagreement`, `ordertos`, `quoteproposal`, `quotelineitems`, `quotediscountheading`,
  `quotelinetotal`, `quoterecipient`, `quotevaliduntil`, `quotedatecreated`,
  `quotestage*`, `ordererroraccepttos` -> real keys

### Support (B13a/B13b)
- `navtickets`, `opennewticket`, `all`, `supportticketsstatus*`, `search`,
  `supportticketssubject/department/status/ticketlastupdated`, `previouspage`,
  `nextpage`, `supporttab`, `mytickets`, `announcementstitle`, `knowledgebasetitle`,
  `downloadstitle`, `networkstatus`, step-2 field keys
  (`supportticketsticketsubject`, `supportticketspriority`,
  `supportticketsticketurgency{low,medium,high}`, `relatedservice`, `none`,
  `contactmessage`, `supportticketsticketattachments`, `chooseFile`,
  `orderForm.remove`, `addmore`, `supportticketsallowedextensions`, `back`,
  `supportticketsticketsubmit`, `contactus`, `cancel`, `continue`),
  confirm page (`supportticketsticketcreated(desc)`),
  kbsuggestions (`kbsuggestionsexplanation`), viewticket
  (`confirmcloseticket`, `supportticketsclose`, `support.attachmentsRemoved`,
  `download`, `supportticketsreply`, `chooseFile`, `addmore`, `ticketinfo`,
  `supportticketsstatus`, `supportticketsdepartment`, `supportticketssubmitted`,
  `supportticketsticketlastupdated`, `supportticketspriority`),
  feedback (all `feedback*` keys + `returnclient`, `none`, `clientareasavechanges`) -> real
- KB/announce/downloads/markdown (B13b): `knowledgebasetitle`, `knowledgebasepopular`,
  `howcanwehelp`, `clientHomeSearchKb`, `knowledgebasenoarticles`, `knowledgebasehelpful`,
  `knowledgebaseArticleRatingThanks`, `knowledgebaseyes/no`, `knowledgebaserelated`,
  `announcementstitle`, `noannouncements`, `contactsent`, `contactus`,
  `supportticketsclientname/clientemail`, `contactdepartment`,
  `supportticketsticketsubject`, `contactmessage`, `contactsend`, `downloadstitle`,
  `downloadssearch`, `downloadscategories`, `downloadsfiles`, `downloadspopular`,
  `restricted`, `downloadbutton`, `login`, `new`, all `markdown.*` (incl. wrapping
  hardcoded "bold text"/"italic text" in `markdown.bold`/`markdown.italics`),
  `errorPage.404.home` -> real
- serverstatus: `serverstatustitle`, `serverstatusheadingtext`, `all`,
  `networkissuesstatus{open,scheduled,resolved}`, `networkstatustitle`,
  `networkissuesaffecting`, `networkIssues.affectingYou`, `networkissueslastupdated`,
  `networkstatusnone`, `previouspage`, `nextpage`, `servername`,
  `serverstatusserverload`, `serverstatusuptime`, `serverstatusphpinfo`,
  `serverstatusnoservers` -> real keys

### Account / SSL (B14a/B14b)
- All contact/details/permission **form-field** keys (`clientareafirstname`..
  `clientareacountry`, `clientareaemail`, `clientareaphonenumber`, `clientarealanguage`,
  `contactDetails`, `clientareachoosecontact`, `clientareanavaddcontact`, `go`,
  `clientareadeletecontact`, `clientareacontactsemails`, `clientareasavechanges`,
  `cancel`) -> real keys
- Section titles: `personalinformation`->`orderForm.personalInformation`;
  `billingaddress`->`orderForm.billingAddress`; `emailpreferences`->`clientareacontactsemails`
- User management: `usermanagement`/`navUserManagement`, `userManagement.inviteNewUser`,
  `clientOwner`, `twoFactor.enabled`, `userManagement.lastLogin`, `never`,
  `userManagement.managePermissions/removeAccess/pendingInvites/inviteSent/
  resendInvite/cancelInvite/accountOwnerPermissionsInfo/inviteNewUserDescription/
  emailAddress/permissions/allPermissions/choosePermissions/sendInvite`,
  `close`, confirm dialogs (`clientareadeletecontactareyousure`,
  `userManagement.removeAccessSure`, `userManagement.cancelInviteSure`) -> real
- Email history headers: `clientareaemailsdate`, `clientareaemailssubject`, `search`,
  `accountdetails`, `security`, viewemail (`clientareaemails`,
  `supportticketsticketattachments`, `clientareaemailsnone`) -> real
- B14b traps: `continuetoclientarea`->`orderForm.continueToClientArea`;
  `signin`->`login`; `createaccount`->`orderForm.createAccount`(or `register`);
  `contactsupport`->`contactus`; `affiliatesvisitors`->`affiliatesclicks`;
  `switchaccount`/`switchAccount.switchTo`->`navSwitchAccount`;
  `emailverification_*`->`emailVerification.*`; `accountinvite_*`->`accountInvite.*`;
  `ssl{email,dns,file}method`/`sslselectvalidation`/`ssltype`/`sslhost`/`sslvalue`/
  `sslemailinformation`/`ssldnsrecordinformation`/`sslfileinformation`/`sslurl`/
  `ssl{email,dns,file}steps`/`sslselectemail` -> dotted `ssl.*` real keys;
  `pleasechoose`->`ssl.selectWebserver`; `resendemail`->`resendEmail`
- All `userProfile.*`, `twofactorauth`, `twofa{enable,disable}`, `enabled`/`disabled`,
  `clientAreaSecurityTwoFactorAuth{Required,Recommendation}`,
  `remoteAuthn.titleLinkedAccounts`, `clientareasecurity*`, `sso.title`,
  affiliate stat/label keys (`affiliatestitle`, `affiliatesdisabled`,
  `affiliateswithdrawalrequestsuccessful`, `affiliatessignups`,
  `affiliatesconversionrate`, `affiliatesbalance`, `affiliatesreferallink`,
  `affiliateslinktousexplanation`, `copy`, `affiliatescommissions*`,
  `affiliateswithdrawn`, `affiliatesrequestwithdrawal`, `affiliatesreferals`,
  `affiliatessignupdate`, `orderproduct`, `affiliatesamount`, `affiliatescommission`,
  `affiliatesstatus`, `affiliateslinktous(sub)`, all `affiliatesignup*`), SSL real
  keys (`domainssloptions`, `nav_manage_ssl`, `ssldomain`, `sslproduct`,
  `sslrenewaldate`, `sslconfigure`, `renew`, `manageproduct`, `sslawaitingconfig`,
  `sslawaitingissuance`, `clientareaexpired`, `expiringsoon`, `clientareaactive`,
  `upgrade`, `sslserverinfo(details)`, `sslservertype`, `sslcsr`, `ssladmininfo(details)`,
  `organizationname`, `jobtitle`, `continue`, `cancel`, `sslnoconfigurationpossible`,
  `sslinvalidlink`, `sslconfigcomplete`, `email`, `tryagain`) -> real keys

---

## Needs server verification (med/low confidence)

Keys auditors classed but flagged pending a check of the server `lang/english.php`.
If confirmed real, the listed custom keys should flip to WHMCS (drop from the draft);
if confirmed absent/wrong-string, keep as custom.

- **Core-resolved nav/section keys (B08/B09/B13a/B14a)** - genuine WHMCS keys
  resolved inside WHMCS's navbar/Menu PHP, so not citable in a reference *template*.
  Kept WHMCS at med/low conf; verify before stripping defaults:
  `clientareanavhome`, `servicestab`, `accounttab`, `invoicestab`, `supporttickets`,
  `supporttab`, `navchangedetails`, `navsecurity`, `navemailshistory`,
  `accountdetails`, `usermanagement`, `contacts`, `emailstitle`, `yourprofile`,
  `switchaccount`/`navSwitchAccount`, `clientareanavchangepassword`,
  `securitysettings`, `security`, `home`, `shop`, `createaccount`, `searchbutton`,
  `logout`, `login`, `mytickets`, `networkstatus`, `downloadstitle`, `downloadbutton`,
  `new`, `contactdepartment`.
- **Cart sidebar fallback labels (B01)** - `categories`, `cartrenewdomains`,
  `cartregisterdomain`, `carttransferdomain` (kept CUSTOM as `cart.categories`/
  `renewDomains`/`registerNewDomain`/`transferDomain`; likely real WHMCS sidebar
  keys with zero bare-usage evidence). **If real, strip default -> WHMCS.**
- **Service status pills (B10)** - `services.statusActive/Pending/Suspended/
  Terminated/Cancelled/Fraud`: real WHMCS twins are `clientareaactive`/
  `clientareapending`/`clientareasuspended`/`clientareaterminated`/
  `clientareacancelled`/`clientareafraud`. If parity wanted -> WHMCS.
- **Dashboard low-conf (B09)** - `servicesactive` (vs `navservices`), `unpaid`,
  `orderproducts`, `viewall`, `domainsfindyournew`, `viewallpricing`,
  `clientHomePanels.activeProductsServices`, `recentSupportTickets`, `recentNews`,
  `registerNewDomain` (panel names): verify exact `$_LANG`/`clientHomePanels.*` keys.
  (Auditor classed these WHMCS; listed here because unverifiable in a template.)
- **Domains low-conf (B11)** - `expires` (vs `clientareahostingexpirydate`),
  `delete` (generic), `domainpricing`, `domainbulkmanagement`,
  `pricing.noExtensionsDefined` (for the empty-table message). `domains.expires`/
  `domains.delete` kept custom.
- **Billing `paymentMethods.*` suffixes (B12)** - `paymentMethods.expired`,
  `.manage`, `.manageintro`, `.updateCard`, `.removeTitle/removeSub/removeConfirm`,
  `.noneSelected(Sub)`, `.add`, `.billingContacts(Intro)`, `.noBillingContacts(Sub)`
  use the genuine `paymentMethods.` prefix but the suffixes are unverifiable.
  Kept custom under `billing.pm*` / `billing.billingContacts*`; some (esp.
  `expired`) may be real. Also `creditcardenterdetails`, `creditcardcardholdername`
  classed WHMCS but uncited.
- **Support low-conf (B13a/B13b)** - `requestor` (WHMCS has only
  `support.requestor.<type>`, no standalone label) kept custom; `views`,
  `articlesCount`/`kbarticles`, `downloadsfiles` (count-suffix vs section-title
  semantics), `helpfulVotes`/`knowledgebaseratingtext` - verify; `kbsuggestions`
  ("Before you submit" vs WHMCS "Knowledgebase Suggestions") + `feedbackclosed`
  (title vs body) are real-key-wrong-default traps left as custom titles.
- **SSL/account low-conf (B14b)** - `securitysettings`, `clientareanavchangepassword`,
  `accountdetails`, `logout`, `nav_manage_ssl`, `domainssloptions`, `manageproduct`,
  `renew`, `clientareanavservices`, `changepassword`, `pleasechoose`,
  `sslawaitingissuance`, `affiliatesbalance`, `affiliateslinktous(sub)`,
  `affiliateslinktousexplanation` used only with `|default` (no in-batch ref cite);
  classed WHMCS at med conf. Verify before stripping.

---

## Open decisions the consolidation could not settle (carry to Phase B)

1. **Pager words `previousPage`/`nextPage`**: B13a + B14a found `$LANG.previouspage`/
   `$LANG.nextpage` are **real** (cited in lagom serverstatus); B10/B11/B12 classed
   the same words CUSTOM. The draft keeps `common.previousPage`/`nextPage` for the
   bespoke a11y/JS-pager spots, but they should likely drop to WHMCS everywhere -
   one decision.
2. **`itemCount` plural** (cart): kept as two keys `cart.itemCount`/`itemCountPlural`;
   if a `{n}`-aware plural helper is introduced, collapse to one.
3. **`services.serviceLower`/`servicesLower`** ("service"/"services" lowercase) -
   no clean WHMCS singular/plural-lower key; kept custom, flag if a plural mechanism lands.
4. **Wording shifts when stripping defaults** (B12 invoice set, B11 domain traps,
   B13b serverstatus/downloads): mapping invented keys to real ones changes visible
   text ("From"->"Pay To", "Bill to"->"Invoiced To", "Active"->"Open",
   "Incidents & maintenance"->"Network Status", etc.). The auditors chose the WHMCS
   string per the prefer-real-keys policy; confirm these are acceptable, else mint
   custom keys to preserve the bespoke English.
5. **devchip group**: ship-time decision to keep or drop the 14 variant labels
   (recommended: drop) and whether to localize the ~40 state-chip dev strings
   (recommended: skip - not enumerated here).
