# B03 — Cart: Configure (product / domain / addons)

## Summary
- Files audited (in full): 5
- Total strings reported: **94**
- WHMCS (real key — strip `|default` or map to existing key): **41**
- CUSTOM (invented key → rebadge to `$hadrianLang`): **39**
- js-string (subset of the above; all CUSTOM): **14**
- SKIP noted (verified-real bare `{$LANG.x}`, `{lang key=…}`, `$rslang`): none reported per spec (skipped silently); a few are called out inline as context only.

Evidence sources used throughout:
- `standard_cart/standard_cart/<file>.tpl` — stock WHMCS order form, identical filenames (most authoritative for cart `$LANG` keys).
- `lagom2.3/orderforms/lagom2/<file>.tpl` — reference order form.
- `hadrian_cart/**` — our own already-tokenized usage.

Key cross-file determinations:
- **`orderyears`, `orderregperiod`, `domaineppcode`, `domainnameservers`, `domainnameserver1..5`, `cartnameserversdesc`, `hosting`, `cartdomainshashosting`, `cartdomainsnohosting`, `domaindnsmanagement`, `domainidprotection`, `domainemailforwarding`** are all REAL WHMCS keys — used bare in `lagom2.3/orderforms/lagom2/configuredomains.tpl` and `standard_cart/.../configuredomains.tpl`. Every `|default` on these → strip the default, class WHMCS.
- **Promo box**: hadrian invented `promotioncode`/`applypromo`. Stock uses real keys: placeholder `{lang key="orderPromoCodePlaceholder"}` (`standard_cart/.../viewcart.tpl:491`; `lagom2.3/orderforms/lagom2/includes/viewcart/promo-code.tpl:31`) and button `{$LANG.orderpromovalidatebutton}` (same files :493/:35). → class WHMCS, remap to those keys (not a literal strip).
- **`cartbillingcycle`** appears ONLY with `|default` across the whole `hadrian_cart` tree (configureproduct + viewcart×5) and never in lagom/standard_cart → INVENTED → CUSTOM (deduped to one key).
- **`cartconfigserver`** is a real key (bare in `lagom2.3/orderforms/lagom2/configureproduct.tpl:1028` and `standard_cart`), and hadrian already uses it bare → SKIP (not reported).
- `cartchangeplan / cartchangedomain / cartselectedplan / cartdomainincluded / cartreviewcart / cartbacktodomain / cartsummarycycle / cartsecured` and the empty-state `cart.*` keys are invented (never bare anywhere; absent from nexus) → CUSTOM.

---

### hadrian_cart/configureproduct.tpl
| Line | Type | Current text | Class | Proposed reference | Evidence / Notes | Conf |
|------|------|--------------|-------|--------------------|------------------|------|
| 59 | text | Configure your plan | WHMCS | {$LANG.orderconfigure} | real key — strip default; bare in standard_cart/.../configureproduct.tpl:19, lagom layouts-vars.tpl:74 | high |
| 60 | text | Pick your billing cycle, server region and any add-ons … | CUSTOM | {$hadrianLang.cart.configSubtitle} | invented LANG key `cartconfigsubtitle` → rebadge; no stock subtitle here | high |
| 68 | text | Choose plan | CUSTOM | {$hadrianLang.cart.stepChoosePlan} | step strip label; no WHMCS key; dedupe across cart files | high |
| 76 | text | Choose a domain | WHMCS | {$LANG.domaincheckerchoosedomain} | step strip; real key bare in standard_cart/.../configureproductdomain.tpl:12 | med |
| 78 | text | Configure | CUSTOM | {$hadrianLang.cart.stepConfigure} | step strip label; no WHMCS key; dedupe | high |
| 80 | text | Cart | CUSTOM | {$hadrianLang.cart.stepCart} | step strip label; dedupe | high |
| 82 | text | Checkout | WHMCS | {$LANG.checkout} | real WHMCS key (global "Checkout"); dedupe across cart files | med |
| 98 | text | Please correct the following errors | (skip) | {$LANG.orderForm.correctErrors} | already bare `{$LANG.orderForm.correctErrors}` — not reported | — |
| 115 | text | Selected plan | CUSTOM | {$hadrianLang.cart.selectedPlan} | invented LANG key `cartselectedplan` → rebadge | high |
| 122 | text | Change plan | CUSTOM | {$hadrianLang.cart.changePlan} | invented LANG key `cartchangeplan` → rebadge | high |
| 130 | text | Domain | WHMCS | {$LANG.domain} | real key — strip default; `$LANG.domain` is a standard WHMCS field label | high |
| 134 | text | Included | CUSTOM | {$hadrianLang.cart.domainIncluded} | invented LANG key `cartdomainincluded` → rebadge | high |
| 145 | text | Change | CUSTOM | {$hadrianLang.cart.changeDomain} | invented LANG key `cartchangedomain` → rebadge; reuse for the "Change" domain link | high |
| 155 | text | Billing cycle | CUSTOM | {$hadrianLang.cart.billingCycle} | invented LANG key `cartbillingcycle` → rebadge; ONLY ever used with `|default` (configureproduct + viewcart.tpl:1023…); dedupe | high |
| 156 | text | Longer commitments = bigger discounts. You can upgrade or switch later. | CUSTOM | {$hadrianLang.cart.billingCycleSub} | invented LANG key `cartbillingcyclesub` → rebadge | high |
| 171 | aria-label | {$LANG.cartchoosecycle} | (skip) | — | bare `{$LANG.cartchoosecycle}` real key (used bare in standard_cart/.../configureproduct.tpl:46) — not reported | — |
| 176 | text | Billed every month | CUSTOM | {$hadrianLang.cart.billedMonthly} | invented LANG key `cartbilledmonthly` → rebadge | high |
| 184 | text | Billed every 3 months | CUSTOM | {$hadrianLang.cart.billedQuarterly} | invented LANG key `cartbilledquarterly` → rebadge | high |
| 192 | text | Billed every 6 months | CUSTOM | {$hadrianLang.cart.billedSemiannually} | invented LANG key `cartbilledsemiannually` → rebadge | high |
| 200 | text | Billed once per year | CUSTOM | {$hadrianLang.cart.billedAnnually} | invented LANG key `cartbilledannually` → rebadge | high |
| 208 | text | Billed every 2 years | CUSTOM | {$hadrianLang.cart.billedBiennially} | invented LANG key `cartbilledbiennially` → rebadge | high |
| 216 | text | Billed every 3 years | CUSTOM | {$hadrianLang.cart.billedTriennially} | invented LANG key `cartbilledtriennially` → rebadge | high |
| 296 | text | Set the hostname, root password, and nameserver prefixes for your server. | CUSTOM | {$hadrianLang.cart.serverInfoSub} | bespoke description; no WHMCS key; not in stock | high |
| 356 | js-string | Weak | CUSTOM | {$hadrianLang.cart.pwWeak} | pw-strength meter label injected via textContent | high |
| 356 | js-string | Moderate | CUSTOM | {$hadrianLang.cart.pwModerate} | pw-strength meter label | high |
| 356 | js-string | Strong | CUSTOM | {$hadrianLang.cart.pwStrong} | pw-strength meter label | high |
| 393 | text | Customize storage, CPU, region, and other options for this plan. | CUSTOM | {$hadrianLang.cart.configOptionsSub} | bespoke description under `orderconfigpackage` heading | high |
| 478 | text | {lang key='orderForm.requiredField'} | (skip) | — | already `{lang key=…}` real WHMCS string — not reported | — |
| 501 | text | Optional extras to enhance your plan. Add or remove anytime. | CUSTOM | {$hadrianLang.cart.addonsSub} | bespoke description under `cartavailableaddons` heading | high |
| 547 | text | Order summary | WHMCS | {$LANG.ordersummary} | real key — strip default; bare in lagom configureproduct.tpl:1307, viewcart.tpl:195 | high |
| 564 | text | Cancel anytime - 30-day money-back guarantee. | CUSTOM | {$hadrianLang.cart.summaryReassurance} | invented LANG key `cartsummarycycle` → rebadge; static reassurance line | high |
| 567 | placeholder | Promo code | WHMCS | {lang key="orderPromoCodePlaceholder"} | invented `promotioncode`; stock uses real key `orderPromoCodePlaceholder` (standard_cart/.../viewcart.tpl:491; lagom promo-code.tpl:31) | high |
| 568 | text | Apply | WHMCS | {$LANG.orderpromovalidatebutton} | invented `applypromo`; stock button uses `orderpromovalidatebutton` (standard_cart/.../viewcart.tpl:493; lagom promo-code.tpl:35) | high |
| 573 | text | Review cart | CUSTOM | {$hadrianLang.cart.reviewCart} | invented LANG key `cartreviewcart` → rebadge (stock submit = `$LANG.continue`; wording differs intentionally) | med |
| 582 | text | Back to domain | CUSTOM | {$hadrianLang.cart.backToDomain} | invented LANG key `cartbacktodomain` → rebadge | high |
| 588 | text | Secured by 256-bit SSL - PCI-DSS Level 1 | CUSTOM | {$hadrianLang.cart.securedNote} | invented LANG key `cartsecured` → rebadge; dedupe with viewcart.tpl:1525 / checkout summary-aside.tpl:100 | high |
| 842 | js-string | Save %s% | CUSTOM | {$hadrianLang.cart.savePercent} | savings pill built via `'Save ' + n + '%'`; use %s for the number | high |
| 960 | js-string | Recalculating promo… | CUSTOM | {$hadrianLang.cart.recalculatingPromo} | placeholder discount-row text | high |
| 1007 | js-string | Promotion no longer applies to this configuration. | CUSTOM | {$hadrianLang.cart.promoNoLongerApplies} | inline info banner body | high |
| 1006,1196,1216,1230,1233,1242 | js-string | Promo code | CUSTOM | {$hadrianLang.cart.promoCodeTitle} | inline-banner title used in 6 places; dedupe | high |
| 1083 | js-string | Please correct the following: | WHMCS | {$LANG.orderForm.correctErrors} | default error-banner title; same string WHMCS uses (see line 98); emit via Smarty into the JS lang seed | med |
| 1216,1230 | js-string | Promo: %s / Promo code "%s" applied. | CUSTOM | {$hadrianLang.cart.promoApplied} | fallback promo description / accepted msg; %s = code | med |
| 1116,1243 | js-string | Network error -- please try again. | CUSTOM | {$hadrianLang.cart.networkError} | XHR failure message; dedupe (lines 1116 + 1243) | high |

_Note (not reported, context):_ `cartconfigserver` (295), `orderconfigpackage` (392), `cartavailableaddons` (500), `serverhostname` (340), `serverrootpw` (345/362), `serverns1prefix` (375), `serverns2prefix` (379), `enable` (420), `orderadditionalrequiredinfo` (477), the `orderpaymentterm*` cycle titles (175…215), and `metrics.*` (229/230/240/249) are all bare real `{$LANG.*}` — correct, skipped.

---

### hadrian_cart/configureproductdomain.tpl
| Line | Type | Current text | Class | Proposed reference | Evidence / Notes | Conf |
|------|------|--------------|-------|--------------------|------------------|------|
| 47 | text | Choose a domain | WHMCS | {$LANG.domaincheckerchoosedomain} | real key — strip default; bare in standard_cart/.../configureproductdomain.tpl:12 | high |
| 48 | text | Register something new, transfer one you already own… | CUSTOM | {$hadrianLang.cart.chooseDomainSubtitle} | invented LANG key `choosedomainsubtitle` → rebadge | high |
| 67 | text | Choose plan | CUSTOM | {$hadrianLang.cart.stepChoosePlan} | step strip; dedupe with configureproduct | high |
| 70 | text | Choose a domain | CUSTOM | {$hadrianLang.cart.stepChooseDomain} | step strip ACTIVE label (plain text, not the H1); dedupe | high |
| 72 | text | Configure | CUSTOM | {$hadrianLang.cart.stepConfigure} | step strip; dedupe | high |
| 74 | text | Cart | CUSTOM | {$hadrianLang.cart.stepCart} | step strip; dedupe | high |
| 76 | text | Checkout | WHMCS | {$LANG.checkout} | step strip; real WHMCS key; dedupe | med |
| 91 | aria-label | How you'll provide a domain | CUSTOM | {$hadrianLang.cart.domainOptionGroupLabel} | radiogroup aria-label; no WHMCS key | med |
| 104 | text | Use a domain that's already in your cart. | CUSTOM | {$hadrianLang.cart.useIncartDesc} | option sub-description; no WHMCS key | high |
| 119 | text | Search and register a brand-new domain name. | CUSTOM | {$hadrianLang.cart.registerDesc} | option sub-description; no WHMCS key | high |
| 134 | text | Move your domain to us — usually includes a free year extension. | CUSTOM | {$hadrianLang.cart.transferDesc} | option sub-description | high |
| 149 | text | Keep it with your current registrar and point DNS at us. | CUSTOM | {$hadrianLang.cart.owndomainDesc} | option sub-description | high |
| 164 | text | Use a subdomain on one of our shared domains. | CUSTOM | {$hadrianLang.cart.subdomainDesc} | option sub-description | high |
| 174 | text | Pick from the domains already in your cart. | CUSTOM | {$hadrianLang.cart.incartPanelHint} | panel hint | high |
| 181 | text | {$LANG.orderForm.use} | (skip) | — | bare real key (matches standard_cart:36) — not reported | — |
| 188 | text | Search by domain. We'll check availability across our registrar partners. | CUSTOM | {$hadrianLang.cart.registerPanelHint} | panel hint (HTML w/ `<strong>`) | high |
| 192 | placeholder | example | CUSTOM | {$hadrianLang.cart.registerSldPlaceholder} | SLD example placeholder; no WHMCS key | med |
| 200 | text | {$LANG.orderForm.check} | (skip) | — | bare real key (standard_cart:80) — not reported | — |
| 206 | text | Free domain on: | CUSTOM | {$hadrianLang.cart.freeDomainOn} | label; stock uses `orderfreedomainregistration`/`orderfreedomainappliesto` but wording differs — see ambiguity #4 | med |
| 214 | text | Transfer your domain from another registrar. Most transfers add a free extra year… | CUSTOM | {$hadrianLang.cart.transferPanelHint} | panel hint (HTML) | high |
| 218 | placeholder | mydomain | CUSTOM | {$hadrianLang.cart.transferSldPlaceholder} | SLD placeholder | med |
| 225 | text | {$LANG.orderForm.transfer} | (skip) | — | bare real key (standard_cart:136) — not reported | — |
| 228 | text | Before transferring: domain must be unlocked, registered for at least 60 days… | CUSTOM | {$hadrianLang.cart.transferRequirements} | help paragraph (HTML); no single WHMCS key | high |
| 241 | text | I'll use my existing domain and update my nameservers. Tell us which domain… | CUSTOM | {$hadrianLang.cart.owndomainPanelHint} | panel hint (HTML) | high |
| 245 | placeholder | mysite | WHMCS | {lang key='yourdomainplaceholder'} | invented `yourdomainplaceholder` default; stock uses real `{lang key='yourdomainplaceholder'}` (standard_cart:157) | high |
| 247 | placeholder | com | WHMCS | {$LANG.yourtldplaceholder} | invented default; stock uses bare `{$LANG.yourtldplaceholder}` (standard_cart:161) | high |
| 248 | text | {$LANG.orderForm.use} | (skip) | — | bare real key — not reported | — |
| 255 | text | Use a subdomain. Pick a parent domain and enter the prefix you'd like. | CUSTOM | {$hadrianLang.cart.subdomainPanelHint} | panel hint (HTML) | high |
| 257 | placeholder | yourname | CUSTOM | {$hadrianLang.cart.subdomainSldPlaceholder} | SLD placeholder (stock uses literal `yourname` too at standard_cart:187 — also untokenized there) | med |
| 263 | text | {$LANG.orderForm.check} | (skip) | — | bare real key — not reported | — |
| 272 | text | Your domain details stay private — WHOIS privacy included on every TLD that supports it. | CUSTOM | {$hadrianLang.cart.whoisPrivacyNote} | footer reassurance; no WHMCS key | high |
| 277 | text | Back | WHMCS | {$LANG.goback} | "Back" link; real WHMCS key `goback` ("Go Back"); wording shift acceptable — see ambiguity #2 | med |
| 280 | text | {$LANG.continue} | (skip) | — | bare real key — not reported | — |

_Note:_ `cartproductdomainuseincart` (103), `cartregisterdomainchoice` (118), `carttransferdomainchoice` (133), `cartexistingdomainchoice` (148), `cartsubdomainchoice` (163) are bare real keys (match standard_cart:21/46/111/146/177) — skipped.

---

### hadrian_cart/configuredomains.tpl
| Line | Type | Current text | Class | Proposed reference | Evidence / Notes | Conf |
|------|------|--------------|-------|--------------------|------------------|------|
| 365 | text | Domains Configuration | WHMCS | {$LANG.cartdomainsconfig} | real key — strip default; bare in standard_cart/.../configuredomains.tpl:18 | high |
| 366 | text | Please review your domain name selections and any addons that are available for them. | WHMCS | {$LANG.orderForm.reviewDomainAndAddons} | real key — strip default; bare in standard_cart/.../configuredomains.tpl:25 | high |
| 390 | text | Choose plan | CUSTOM | {$hadrianLang.cart.stepChoosePlan} | step strip; dedupe | high |
| 397 | text | Choose a domain | CUSTOM | {$hadrianLang.cart.stepChooseDomain} | step strip; dedupe | high |
| 400 | text | Configure | CUSTOM | {$hadrianLang.cart.stepConfigure} | step strip; dedupe | high |
| 402 | text | Cart | CUSTOM | {$hadrianLang.cart.stepCart} | step strip; dedupe | high |
| 404 | text | Checkout | WHMCS | {$LANG.checkout} | step strip; dedupe | med |
| 412 | text | Please correct the following errors | WHMCS | {$LANG.orderForm.correctErrors} | real key — strip default; bare in standard_cart/.../configuredomains.tpl:29 | high |
| 435 | text | Registration Period | WHMCS | {$LANG.orderregperiod} | real key — strip default; bare in lagom configuredomains.tpl:87, standard_cart:45 | high |
| 436 | text | Year/s | WHMCS | {$LANG.orderyears} | real key — strip default; bare in lagom configuredomains.tpl:87, standard_cart:47; dedupe (5 occurrences) | high |
| 439 | text | Hosting | WHMCS | {$LANG.hosting} | real key — strip default; bare in standard_cart:52 | high |
| 444 | text | Includes hosting | WHMCS | {$LANG.cartdomainshashosting} | real key — strip default; bare in lagom configuredomains.tpl:77, standard_cart:54 | high |
| 449 | text | No Hosting! Click to Add | WHMCS | {$LANG.cartdomainsnohosting} | real key — strip default; bare in lagom configuredomains.tpl:81, standard_cart:54 | high |
| 459 | text | EPP Code | WHMCS | {$LANG.domaineppcode} | real key — strip default; bare in lagom configuredomains.tpl:242, standard_cart:60 | high |
| 461 | text | {$LANG.domaineppcodedesc} | (skip) | — | bare real key — not reported | — |
| 480 | text | DNS Management | WHMCS | {$LANG.domaindnsmanagement} | real key — strip default; bare in lagom configuredomains.tpl:103, standard_cart:81 | high |
| 484 | text | Year/s | WHMCS | {$LANG.orderyears} | real key — strip default; dedupe | high |
| 485 | text | Add to cart | WHMCS | {$LANG.orderForm.addToCart} | real key — strip default; bare in standard_cart:90; dedupe (3×) | high |
| 494 | text | ID Protection | WHMCS | {$LANG.domainidprotection} | real key — strip default; bare in lagom configuredomains.tpl:143, standard_cart:102 | high |
| 498 | text | Year/s | WHMCS | {$LANG.orderyears} | real key — strip default; dedupe | high |
| 499 | text | Add to cart | WHMCS | {$LANG.orderForm.addToCart} | real key — strip default; dedupe | high |
| 508 | text | Email Forwarding | WHMCS | {$LANG.domainemailforwarding} | real key — strip default; bare in lagom configuredomains.tpl:184, standard_cart:123 | high |
| 512 | text | Year/s | WHMCS | {$LANG.orderyears} | real key — strip default; dedupe | high |
| 513 | text | Add to cart | WHMCS | {$LANG.orderForm.addToCart} | real key — strip default; dedupe | high |
| 540 | text | Nameservers | WHMCS | {$LANG.domainnameservers} | real key — strip default; bare in lagom configuredomains.tpl:268, standard_cart:152 | high |
| 541 | text | If you want to use custom nameservers then enter them below… | WHMCS | {$LANG.cartnameserversdesc} | real key — strip default; bare in lagom configuredomains.tpl:269, standard_cart:155 | high |
| 546 | text | Nameserver 1 | WHMCS | {$LANG.domainnameserver1} | real key — strip default; bare in lagom configuredomains.tpl:277, standard_cart:160 | high |
| 550 | text | Nameserver 2 | WHMCS | {$LANG.domainnameserver2} | real key — strip default; bare in standard_cart:166 | high |
| 554 | text | Nameserver 3 | WHMCS | {$LANG.domainnameserver3} | real key — strip default; bare in standard_cart:172 | high |
| 558 | text | Nameserver 4 | WHMCS | {$LANG.domainnameserver4} | real key — strip default; bare in standard_cart:178 | high |
| 562 | text | Nameserver 5 | WHMCS | {$LANG.domainnameserver5} | real key — strip default; bare in standard_cart:184 | high |
| 572 | text | Continue | WHMCS | {$LANG.continue} | real key — strip default; bare everywhere (standard_cart:194) | high |
| 591 | text | No domains to configure | CUSTOM | {$hadrianLang.cart.noDomainsToConfigure} | invented LANG key `cart.nodomainstoconfigure` → rebadge; empty-state, no stock equivalent | high |
| 592 | text | It looks like you haven't added any domains to your cart yet… | CUSTOM | {$hadrianLang.cart.noDomainsToConfigureDesc} | invented LANG key `cart.nodomainstoconfiguredesc` → rebadge | high |
| 594 | text | Browse plans | CUSTOM | {$hadrianLang.cart.browsePlans} | invented LANG key `cart.browseplans` → rebadge | high |

_Note:_ `domaineppcodedesc` (461), `domainaddonsdnsmanagementinfo` (482), `domainaddonsidprotectioninfo` (496), `domainaddonsemailforwardinginfo` (510) are bare real keys — skipped.

---

### hadrian_cart/domainoptions.tpl
| Line | Type | Current text | Class | Proposed reference | Evidence / Notes | Conf |
|------|------|--------------|-------|--------------------|------------------|------|
| 63 | text | {$LANG.cartdomaininvalid} | (skip) | — | bare real key (standard_cart:6) — not reported | — |
| 70 | text | {$LANG.cartdomainexists} | (skip) | — | bare real key (standard_cart:11) — not reported | — |
| 83 | text | {$LANG.cartcongratsdomainavailable\|sprintf2} | (skip) | — | bare real key + sprintf2 (standard_cart:22) — not reported | — |
| 91 | text | {$LANG.orderForm.domainAddedToCart} | (skip) | — | bare real key (standard_cart:30) — not reported | — |
| 97 | text | {$LANG.orderForm.registerLongerAndSave} | (skip) | — | bare real key (standard_cart:36) — not reported | — |
| 102,118,120 | text | {$LANG.orderyears} (period @ price) | (skip) | — | bare real key (standard_cart:41/53/55) — not reported | — |
| 112,221 | text | {lang key="domainChecker.additionalPricingOptions"} | (skip) | — | bare `{lang key=…}` real key (standard_cart:47) — not reported | — |
| 135 | text | {$LANG.cartdomaintaken\|sprintf2} | (skip) | — | bare real key (standard_cart:70) — not reported | — |
| 148 | text | {$LANG.carttransfernotregistered\|sprintf2} | (skip) | — | bare real key (standard_cart:82) — not reported | — |
| 151 | text | {$LANG.orderForm.tryRegisteringInstead} | (skip) | — | bare real key (standard_cart:84) — not reported | — |
| 158 | text | {$LANG.carttransferpossible\|sprintf2} | (skip) | — | bare real key (standard_cart:89) — not reported | — |
| 183 | text | {$LANG.cartotherdomainsuggestions} | (skip) | — | bare real key (standard_cart:113) — not reported | — |
| 206-229 | text | {$LANG.orderyears} (suggestion pricing) | (skip) | — | bare real key — not reported | — |
| 247 | text | {$LANG.orderForm.domainAvailabilityCached} | (skip) | — | bare real key (standard_cart:165) — not reported | — |
| 252 | text | {$LANG.continue} | (skip) | — | bare real key (standard_cart:170) — not reported | — |

**_No hardcoded strings._** Every user-facing string in this partial is already a bare real `{$LANG.*}` / `{lang key=…}` (verified line-for-line against `standard_cart/.../domainoptions.tpl`). The only literals are SVG/icon class names and `&nbsp;`. No `|default` anywhere.

---

### hadrian_cart/addons.tpl
| Line | Type | Current text | Class | Proposed reference | Evidence / Notes | Conf |
|------|------|--------------|-------|--------------------|------------------|------|
| 26 | text | {$LANG.cartproductaddons} | (skip) | — | bare real key (standard_cart:14) — not reported | — |
| 27 | text | Add-ons extend an existing service. Pick the service you'd like to attach each one to. | CUSTOM | {$hadrianLang.cart.addonsPageSubtitle} | bespoke subtitle; no stock equivalent (stock has no subtitle here) | high |
| 35 | text | {$LANG.cartproductaddonsnone} | (skip) | — | bare real key (standard_cart:20) — not reported | — |
| 41 | text | {$LANG.orderForm.returnToClientArea} | (skip) | — | bare real key (standard_cart:25) — not reported | — |
| 75 | text | {$LANG.orderfree} | (skip) | — | bare real key (standard_cart:56) — not reported | — |
| 79 | text | {$LANG.ordersetupfee} | (skip) | — | bare real key (standard_cart:59) — not reported | — |
| 85 | text | {$LANG.ordernowbutton} | (skip) | — | bare real key (standard_cart:64) — not reported | — |

Only one hardcoded string in this file (line 27). Everything else is bare real `{$LANG.*}`.

---

## Proposed custom keys
Deduped list of every `$hadrianLang.*` key proposed above, with its English value.

```
# Step-strip labels (shared across configureproduct / configureproductdomain / configuredomains)
hadrianLang.cart.stepChoosePlan = "Choose plan"
hadrianLang.cart.stepChooseDomain = "Choose a domain"
hadrianLang.cart.stepConfigure = "Configure"
hadrianLang.cart.stepCart = "Cart"

# configureproduct.tpl
hadrianLang.cart.configSubtitle = "Pick your billing cycle, server region and any add-ons — we'll total it up on the right."
hadrianLang.cart.selectedPlan = "Selected plan"
hadrianLang.cart.changePlan = "Change plan"
hadrianLang.cart.domainIncluded = "Included"
hadrianLang.cart.changeDomain = "Change"
hadrianLang.cart.billingCycle = "Billing cycle"
hadrianLang.cart.billingCycleSub = "Longer commitments = bigger discounts. You can upgrade or switch later."
hadrianLang.cart.billedMonthly = "Billed every month"
hadrianLang.cart.billedQuarterly = "Billed every 3 months"
hadrianLang.cart.billedSemiannually = "Billed every 6 months"
hadrianLang.cart.billedAnnually = "Billed once per year"
hadrianLang.cart.billedBiennially = "Billed every 2 years"
hadrianLang.cart.billedTriennially = "Billed every 3 years"
hadrianLang.cart.serverInfoSub = "Set the hostname, root password, and nameserver prefixes for your server."
hadrianLang.cart.configOptionsSub = "Customize storage, CPU, region, and other options for this plan."
hadrianLang.cart.addonsSub = "Optional extras to enhance your plan. Add or remove anytime."
hadrianLang.cart.summaryReassurance = "Cancel anytime - 30-day money-back guarantee."
hadrianLang.cart.reviewCart = "Review cart"
hadrianLang.cart.backToDomain = "Back to domain"
hadrianLang.cart.securedNote = "Secured by 256-bit SSL - PCI-DSS Level 1"
hadrianLang.cart.pwWeak = "Weak"
hadrianLang.cart.pwModerate = "Moderate"
hadrianLang.cart.pwStrong = "Strong"
hadrianLang.cart.savePercent = "Save %s%"
hadrianLang.cart.recalculatingPromo = "Recalculating promo…"
hadrianLang.cart.promoNoLongerApplies = "Promotion no longer applies to this configuration."
hadrianLang.cart.promoCodeTitle = "Promo code"
hadrianLang.cart.promoApplied = "Promo: %s"
hadrianLang.cart.networkError = "Network error -- please try again."

# configureproductdomain.tpl
hadrianLang.cart.chooseDomainSubtitle = "Register something new, transfer one you already own, or point an existing domain at our nameservers."
hadrianLang.cart.domainOptionGroupLabel = "How you'll provide a domain"
hadrianLang.cart.useIncartDesc = "Use a domain that's already in your cart."
hadrianLang.cart.registerDesc = "Search and register a brand-new domain name."
hadrianLang.cart.transferDesc = "Move your domain to us — usually includes a free year extension."
hadrianLang.cart.owndomainDesc = "Keep it with your current registrar and point DNS at us."
hadrianLang.cart.subdomainDesc = "Use a subdomain on one of our shared domains."
hadrianLang.cart.incartPanelHint = "Pick from the domains already in your cart."
hadrianLang.cart.registerPanelHint = "<strong>Search by domain.</strong> We'll check availability across our registrar partners."
hadrianLang.cart.registerSldPlaceholder = "example"
hadrianLang.cart.freeDomainOn = "Free domain on:"
hadrianLang.cart.transferPanelHint = "<strong>Transfer your domain from another registrar.</strong> Most transfers add a <strong>free extra year</strong> to your registration."
hadrianLang.cart.transferSldPlaceholder = "mydomain"
hadrianLang.cart.transferRequirements = "Before transferring: domain must be <strong>unlocked</strong>, registered for at least <strong>60 days</strong>, and you'll need the <strong>auth / EPP code</strong> from your current registrar."
hadrianLang.cart.owndomainPanelHint = "<strong>I'll use my existing domain and update my nameservers.</strong> Tell us which domain you'd like to use - after checkout we'll email you the nameservers to set at your current registrar."
hadrianLang.cart.subdomainPanelHint = "<strong>Use a subdomain.</strong> Pick a parent domain and enter the prefix you'd like."
hadrianLang.cart.subdomainSldPlaceholder = "yourname"
hadrianLang.cart.whoisPrivacyNote = "Your domain details stay private — WHOIS privacy included on every TLD that supports it."

# configuredomains.tpl (empty-state)
hadrianLang.cart.noDomainsToConfigure = "No domains to configure"
hadrianLang.cart.noDomainsToConfigureDesc = "It looks like you haven't added any domains to your cart yet. Pick a plan and choose a domain to continue."
hadrianLang.cart.browsePlans = "Browse plans"

# addons.tpl
hadrianLang.cart.addonsPageSubtitle = "Add-ons extend an existing service. Pick the service you'd like to attach each one to."
```

## New ambiguities (flag for reviewer)
1. **`checkout` step label** — proposed mapping to a global `{$LANG.checkout}`. I could not cite it bare in the cart references (the step strips are bespoke to hadrian). High-likelihood real WHMCS key but unverified in these files → marked confidence **med**. If it can't be confirmed, fall back to `hadrianLang.cart.stepCheckout = "Checkout"`.
2. **`Back` (configureproductdomain:277)** — mapped to `{$LANG.goback}` ("Go Back"); wording would shift from "Back" to "Go Back". If exact "Back" is required, use a custom `hadrianLang.common.back` instead.
3. **`Review cart` / `Back to domain` (configureproduct:573/582)** — stock submit button is `{$LANG.continue}`; hadrian intentionally reworded the CTA. Kept CUSTOM to preserve the bespoke wording, but a reviewer may prefer remapping 573 to `{$LANG.continue}` for consistency.
4. **`Free domain on:` (configureproductdomain:206)** — partial overlap with real keys `orderfreedomainregistration` + `orderfreedomainappliesto` (stock composes them at standard_cart configuredomains step / configureproductdomain.tpl:210). Kept CUSTOM because punctuation/wording differs; reviewer could instead reuse the two stock keys.
5. **`yourtldplaceholder` / `yourdomainplaceholder`** — these ARE real WHMCS keys (stock uses them bare / via `{lang key}`), yet hadrian wrapped them in `|default`. Classified WHMCS (strip default). Note casing/access differs: `yourtldplaceholder` is read as `{$LANG.yourtldplaceholder}` but stock reads `yourdomainplaceholder` via `{lang key='yourdomainplaceholder'}` — both valid forms of a real key.
6. **JS lang seeding** — the 14 js-string CUSTOM keys (pw meter, Save %, promo banners, network error) currently live as raw literals inside `{literal}` blocks. The file already seeds a `_localLang` object from Smarty at the top (configureproduct.tpl:44-48); these new keys should be added to that same object (outside `{literal}`) and referenced as `_localLang.xxx` — wiring mechanism already exists, no redesign needed.
