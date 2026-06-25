# B04 — Cart: domains + products

## Summary
- **Total in-scope strings reported: 80** (table rows)
  - **WHMCS: 16** (real `$LANG` keys carrying a needless `|default` → strip the default)
  - **CUSTOM: 64** (invented `|default` keys to rebadge as `$hadrianLang.*`, plus genuinely hardcoded English text/attributes/JS)
  - **js-string: 1 row** (products.tpl:829-830 `CYCLE_LABEL` object — covers 6 cycle-label literals; it is the JS twin of the inline CUSTOM `[data-period-display]` set at products.tpl:261ff, which is `text` type)
- **SKIP-worth-noting:** The overwhelming majority of these six files is already correctly tokenized as **bare** `{lang key='…'}` / `{$LANG.…}` with NO `|default` (verified against `standard_cart/standard_cart/<same file>.tpl`, which renders identically). Those are genuine WHMCS strings, already correct, and are NOT listed below. Examples confirmed bare in stock standard_cart and therefore skipped: `registerdomain`, `transferdomain`, `findyourdomain`, `search`, `addtocart`, `checkout`, `loading`, `domaincheckertaken`, `domainavailablemessage`, `domainContactUs`, `domainunavailable`, `domaincheckeradded`, `orderyears`, `ordersetupfee`, `ordersummary`, `viewcart`, `bundledeal`, `startingfrom`, `orderavailable`, `ordernowbutton`, `orderpaymentterm*`, `orderfree`, `na`, `yes`, `no`, every `domainSearch.*` / `orderForm.*` / `domainRenewal.*` / `pricing.*` / `recommendations.*` / `cart.idnLanguage*` / `domainCheckerSalesGroup.*` key used WITHOUT a default.

### Cross-file note on the two "canonical-but-undefaulted" WHMCS keys
`ordernewservices` and `changecurrency` appear in this batch ONLY with a `|default` and I could not cite a bare reference-theme usage. They are nonetheless canonical WHMCS lang keys (the key *name* follows WHMCS convention exactly and the English matches a known WHMCS string), so I classed them **WHMCS / med** with "strip default" rather than minting a shadowing Hadrian key. Flagged as an ambiguity at the bottom.

---

### hadrian_cart/domainregister.tpl
Note: this file is mostly bare `{lang key=…}` (SKIP). Only the rows below are in scope.

| Line | Type | Current text | Class | Proposed reference | Evidence / Notes | Conf |
|------|------|--------------|-------|--------------------|------------------|------|
| 82 | text | Order | CUSTOM | {$hadrianLang.cart.order} | `$LANG.cart.order` found only here w/ default; no WHMCS `cart.order` key in any reference. Page eyebrow | high |
| 107 | aria-label | Search mode | CUSTOM | {$hadrianLang.cart.searchModeLabel} | hardcoded on `role="tablist"`; no WHMCS key | high |
| 112 | text | AI Generator | CUSTOM | {$hadrianLang.cart.aiGenerator} | hardcoded mode-tab label (hadrian-only AI/Classic tabs; stock renders one form). Dedupe w/ empty-state? no | high |
| 118 | text | Classic Search | CUSTOM | {$hadrianLang.cart.classicSearch} | hardcoded mode-tab label; no WHMCS equivalent | high |
| 165 | text | Filters | CUSTOM | {$hadrianLang.cart.filters} | hardcoded filters-toggle label. stock standard_cart had no toggle (bootstrap-multiselect). Lagom uses `order.filters` in $rslang only | high |
| 185 | text | No matches | CUSTOM | {$hadrianLang.cart.noMatches} | hardcoded TLD-search empty row; no WHMCS key | high |
| 342 | text | Most popular | CUSTOM | {$hadrianLang.cart.mostPopularTlds} | `orderForm.mostPopular` found ONLY here w/ default; invented (stock has no spotlight heading) | high |
| 343 | text | A handful of the best-known extensions for your domain. | CUSTOM | {$hadrianLang.cart.popularTldsHint} | `orderForm.popularTldsHint` invented (only here w/ default) | high |
| 388 | text | Availability is checked in real time when you add to the cart. | CUSTOM | {$hadrianLang.cart.suggestedDomainsHint} | `orderForm.suggestedDomainsHint` invented (only here w/ default); stock heading is just `orderForm.suggestedDomains` (bare, kept) | high |
| 571 | text | Search a domain | CUSTOM | {$hadrianLang.cart.searchDomainTitle} | `orderForm.searchDomain` invented (empty-state; only here w/ default) | high |
| 572 | text | Type a domain name in the search box above to check availability. | CUSTOM | {$hadrianLang.cart.searchDomainHint} | `orderForm.searchDomainHint` invented (only here w/ default) | high |

_Skipped (already correct, bare): line 84 `orderForm.findNewDomain[Ai]` (bare in standard_cart:17); 138/141 `domainSearch.domainOrAiPrompt`/`Instruction`; 173/176/190/199 `domainSearch.tlds`/`search`/`maxLength`/`safeSearch`; 211/239 `search`; 262 `cartSimpleCaptcha`; 265 `orderForm.required`; 288/292 `domainSearch.topSuggestion`/`exactMatch`; 299–306 `orderForm.searching`/`domainLetterOrNumber`/`domainLengthRequirements`/`domainIsUnavailable`/`domainHasUnavailableTld`; 307/308 `domainavailablemessage`/`domainContactUs`; 311/314/320 `cart.idnLanguageDescription`/`idnLanguage`/`selectIdnLanguageForRegister` (bare in standard_cart:100/107/113); 316 `idnLanguage.*`; 326/330/331 `addtocart`/`checkout`/`domaincheckertaken`; 328/368/418 `loading`; 357/360/363 `domainunavailable`; 366/374/424 `orderForm.add`/`domainChecker.contactSupport`; 387/391/394 `orderForm.suggestedDomains`/`generatingSuggestions`/`domainSearch.errors.noSuggestions`; 408–410 `domainCheckerSalesGroup.hot/new/sale`; 430/431 `domainsmoresuggestions`/`domaincheckernomoresuggestions`; 434 `domainssuggestionswarnings`; 452 `orderForm.shortPerYear[s]`; 454 `domainregnotavailable`; 463 `pricing.browseExtByCategory`; 469 `domainTldCategory.$category`; 476 `orderdomain`; 479–481 `pricing.register/transfer/renewal`; 491 `domainCheckerSalesGroup.$group`; 500/510/520 `orderForm.year[s]`; 502/512/522 `orderfree`; 504/514/524 `na`; 533 `pricing.selectExtCategory`; 543–561 `orderForm.transferToUs`/`transferExtend`/`extendExclusions`/`transferDomain`/`addHosting`/`chooseFromRange`/`packagesForBudget`/`exploreNow` — all bare in standard_cart:332-357._

---

### hadrian_cart/domaintransfer.tpl
This file replaced every stock bare key with a `|default` copy. Cross-referenced against `standard_cart/standard_cart/domaintransfer.tpl` (lines cited) and `lagom2.3/orderforms/lagom2/domaintransfer.tpl`: the `orderForm.*` / page keys ARE real (used bare there) → strip default. The `dt.*` keys are invented marketing copy → rebadge.

| Line | Type | Current text | Class | Proposed reference | Evidence / Notes | Conf |
|------|------|--------------|-------|--------------------|------------------|------|
| 289 | text | Transfer a Domain | WHMCS | {$LANG.transferdomain} | real key — strip default. Bare in standard_cart:13 (`{$LANG.transferdomain}`) | high |
| 290 | text | Move your domain from another registrar to us… | WHMCS | {$LANG.orderForm.transferExtend} | real key — strip default. Bare in standard_cart:19 + lagom domaintransfer:15. (Wording differs but key is the source of truth) | high |
| 321 | placeholder | yourdomain.com | WHMCS | {lang key='yourdomainplaceholder'}.{lang key='yourtldplaceholder'} | real keys — strip both defaults. Bare in standard_cart:35 + lagom domaintransfer:26 | high |
| 323 | title | Enter the domain you want to transfer | WHMCS | {$LANG.orderForm.enterDomain} | real key — strip default. Bare in standard_cart:35 (`title="{lang key='orderForm.enterDomain'}"`) | high |
| 331 | text | Transfer | WHMCS | {$LANG.orderForm.addToCart} | real key — strip default. Bare in standard_cart:67 (`<span id="addToCart">{lang key="orderForm.addToCart"}`) | high |
| 340 | text | Authorization code (EPP) | WHMCS | {$LANG.orderForm.authCode} | real key — strip default. Bare in standard_cart:39 + lagom epp-code modal:11/16 | high |
| 343 | title | Your current registrar will provide this code… | WHMCS | {$LANG.orderForm.authCodeTooltip} | real key — strip default. Bare in standard_cart:40 + lagom epp-code:14 | high |
| 345 | text | What is this? | WHMCS | {$LANG.orderForm.help} | real key — strip default. Bare in standard_cart:40 (`<i…></i> {lang key='orderForm.help'}`) | high |
| 352 | placeholder | Paste your transfer code here | WHMCS | {$LANG.orderForm.authCodePlaceholder} | real key — strip default. Bare in standard_cart:42 + lagom epp-code:18 | high |
| 354 | title | Required | WHMCS | {$LANG.orderForm.required} | real key — strip default. Bare in standard_cart:42 | high |
| 361 | text | Enter the characters shown below | WHMCS | {$LANG.cartSimpleCaptcha} | real key — strip default. Bare in standard_cart:48 (`<p>{lang key="cartSimpleCaptcha"}</p>`) | high |
| 366 | title | Required | WHMCS | {$LANG.orderForm.required} | real key — strip default. Dedupe w/ line 354. Bare in standard_cart:51 | high |
| 385 | text | Transfer in 3 steps | CUSTOM | {$hadrianLang.domains.transferStepsTitle} | `dt.howittitle` invented (hadrian-only marketing section; no stock/lagom equivalent) | high |
| 386 | text | Simple, fast, and we'll guide you through each step. | CUSTOM | {$hadrianLang.domains.transferStepsDesc} | `dt.howitdesc` invented | high |
| 393 | text | 1. Unlock your domain | CUSTOM | {$hadrianLang.domains.transferStep1Title} | `dt.step1title` invented | high |
| 394 | text | At your current registrar, disable the transfer lock… | CUSTOM | {$hadrianLang.domains.transferStep1Desc} | `dt.step1desc` invented | high |
| 400 | text | 2. Get your auth code | CUSTOM | {$hadrianLang.domains.transferStep2Title} | `dt.step2title` invented | high |
| 401 | text | Your current registrar will email you a transfer authorization (EPP) code. | CUSTOM | {$hadrianLang.domains.transferStep2Desc} | `dt.step2desc` invented | high |
| 407 | text | 3. Submit and done | CUSTOM | {$hadrianLang.domains.transferStep3Title} | `dt.step3title` invented | high |
| 408 | text | Enter the domain and code above. We handle the rest… | CUSTOM | {$hadrianLang.domains.transferStep3Desc} | `dt.step3desc` invented | high |
| 416 | text | Why transfer to us | CUSTOM | {$hadrianLang.domains.transferWhyTitle} | `dt.whytitle` invented | high |
| 423 | text | +1 free year | CUSTOM | {$hadrianLang.domains.transferWhyExtendTitle} | `dt.whyextendtitle` invented | high |
| 424 | text | Every transfer includes an additional year of registration at no extra cost. | CUSTOM | {$hadrianLang.domains.transferWhyExtendDesc} | `dt.whyextenddesc` invented | high |
| 430 | text | 24-hour transfer | CUSTOM | {$hadrianLang.domains.transferWhy24Title} | `dt.why24title` invented | high |
| 431 | text | Most transfers complete within 24 hours — no downtime for your site. | CUSTOM | {$hadrianLang.domains.transferWhy24Desc} | `dt.why24desc` invented | high |
| 437 | text | Free WHOIS privacy | CUSTOM | {$hadrianLang.domains.transferWhyPrivacyTitle} | `dt.whyprivacytitle` invented | high |
| 438 | text | Included with every transfer, on every eligible TLD… | CUSTOM | {$hadrianLang.domains.transferWhyPrivacyDesc} | `dt.whyprivacydesc` invented | high |
| 443 | text | Some TLDs are excluded from the free year extension… | WHMCS | {$LANG.orderForm.extendExclusions} | real key — strip default. Bare in standard_cart:357 + lagom domaintransfer:52 | high |
| 457 | text | Enter a domain to transfer | CUSTOM | {$hadrianLang.domains.transferEmptyTitle} | `dt.emptytitle` invented (state-chip Empty preview) | high |
| 458 | text | Type your existing domain above and we'll start the transfer flow. | CUSTOM | {$hadrianLang.domains.transferEmptyDesc} | `dt.emptydesc` invented | high |
| 460 | text | Start a transfer | CUSTOM | {$hadrianLang.domains.transferEmptyCta} | `dt.emptycta` invented | high |

_Skipped (already correct, bare): line 362 `alt="captcha"` is decorative non-translatable (image alt for a captcha; SKIP — pure marker, not user copy)._

---

### hadrian_cart/domain-renewals.tpl
Fully bare-tokenized; verified line-for-line against `standard_cart/standard_cart/domain-renewals.tpl` (identical keys). No `|default` anywhere.

_None found._ (All visible strings are bare `{lang key='…'}` / `{$LANG.…}` WHMCS keys: `navrenewdomains`, `domainrenew`, `searchenterdomain`, `domainRenewal.noDomains`, `orderForm.returnToClientArea`, `domainRenewal.showingDomains`/`showAll`, `clientareadomainexpirydate`, `domainRenewal.freeWithService`/`unavailable`/`expiringIn`/`maximumAdvanceRenewal`/`expiredDaysAgo`/`freeWithServiceDesc`/`availablePeriods`/`graceFee`/`redemptionFee`/`graceRenewalPeriodDescription`, `domainrenewalspastgraceperiod`, `expiresToday`, `orderyears`, `addtocart`, `domaincheckeradded`, `ordersummary`, `viewcart`, `orderForm.close`/`removeItem`, `cartremoveitemconfirm`, `no`, `yes` — all confirmed bare in standard_cart.)

---

### hadrian_cart/products.tpl
The bulk of plan-grid strings are bare `{$LANG.…}` (SKIP, confirmed in standard_cart:44/66/72/92/98 + lagom products.tpl). In scope: the `|default` headers, the bespoke `cart.*` copy, the variant/billing/badge hardcodes, and the JS cycle labels.

| Line | Type | Current text | Class | Proposed reference | Evidence / Notes | Conf |
|------|------|--------------|-------|--------------------|------------------|------|
| 119 | text | Order new services | WHMCS | {$LANG.ordernewservices} | strip default. Canonical WHMCS key (no bare ref in batch, but used w/ default in hadrian upgrade:208 + clientareaproducts:259). See ambiguity note | med |
| 120 | text | Browse our plans and add the ones you need to your cart… | CUSTOM | {$hadrianLang.cart.orderServicesTagline} | `ordernewservicestagline` invented (only here w/ default) | high |
| 181 | text | Available plans | CUSTOM | {$hadrianLang.cart.plansHeading} | `cart.plansheading` invented; heading fallback | high |
| 193 | text | Monthly | CUSTOM | {$hadrianLang.cart.cycleMonthly} | hardcoded billing-pill (hadrian-only cycle switcher; no WHMCS key for the short label). See `pricingCycleShort` note | high |
| 193 | text | Annual | CUSTOM | {$hadrianLang.cart.cycleAnnual} | hardcoded billing-pill | high |
| 193 | text | Save 20% | CUSTOM | {$hadrianLang.cart.cycleSaving} | hardcoded saving chip; "20%" is hardcoded copy (not data-driven) — interpolate as `Save %s%%`? recommend literal for now | med |
| 194 | text | Biennial | CUSTOM | {$hadrianLang.cart.cycleBiennial} | hardcoded billing-pill | high |
| 215 | text | Variant A · 3-up · feature list | CUSTOM | {$hadrianLang.cart.variantLabelA} | dev-preview label (only visible in state-chip "All" mode). Low priority but user-visible | low |
| 229 | text | Most popular | CUSTOM | {$hadrianLang.cart.mostPopular} | hardcoded `.st-plan-badge`. Dedupe across 229/480/602 (Variants A/E/G). No WHMCS key | high |
| 261 | text | /mo · /qtr · /6mo · /yr · /2yr · /3yr | CUSTOM | {$hadrianLang.cart.cycleShortMonthly} … (6 keys) | hardcoded cycle abbreviations in `[data-period-display]`; repeated in Variants A–H (lines 261,325,380,426,507,528,572,623,684). WHMCS has `pricingCycleShort.*` (real, lagom configureproduct:138) but with no leading slash — see ambiguity note | med |
| 281 | (skip) | — | — | — | `{$product.qty} {$LANG.orderavailable}` bare — SKIP | — |
| 300 | text | Variant B · 4-up · minimal cards | CUSTOM | {$hadrianLang.cart.variantLabelB} | dev-preview label | low |
| 343 | text | Variant C · horizontal rows | CUSTOM | {$hadrianLang.cart.variantLabelC} | dev-preview label | low |
| 397 | text | Variant D · comparison table | CUSTOM | {$hadrianLang.cart.variantLabelD} | dev-preview label | low |
| 472 | text | Variant E · bento (hero + minis) | CUSTOM | {$hadrianLang.cart.variantLabelE} | dev-preview label | low |
| 480 | text | Most popular | CUSTOM | {$hadrianLang.cart.mostPopular} | dedupe w/ 229 | high |
| 551 | text | Variant F · segmented bar | CUSTOM | {$hadrianLang.cart.variantLabelF} | dev-preview label | low |
| 594 | text | Variant G · spec matrix | CUSTOM | {$hadrianLang.cart.variantLabelG} | dev-preview label | low |
| 602 | text | Most popular | CUSTOM | {$hadrianLang.cart.mostPopular} | dedupe w/ 229 (`.st-matrix-eyebrow`) | high |
| 641 | text | Variant H · addon cards with radio tiers | CUSTOM | {$hadrianLang.cart.variantLabelH} | dev-preview label | low |
| 697 | text | Not sure which plan is right for you? | CUSTOM | {$hadrianLang.cart.comparePlans} | `cart.compareplans` invented | high |
| 698 | text | Compare all features | CUSTOM | {$hadrianLang.cart.compareAll} | `cart.compareall` invented | high |
| 700 | text | Prices in | CUSTOM | {$hadrianLang.cart.pricesIn} | `cart.pricesin` invented | high |
| 700 | text | Change currency | WHMCS | {$LANG.changecurrency} | strip default. Canonical WHMCS key (no bare ref in batch). See ambiguity note | med |
| 718 | text | No packages in this category yet | CUSTOM | {$hadrianLang.cart.emptyGroupTitle} | `cart.emptygroup` invented (empty-state) | high |
| 719 | text | We're preparing plans for this service… | CUSTOM | {$hadrianLang.cart.emptyGroupDesc} | `cart.emptygroupdesc` invented | high |
| 723 | text | Request a quote | CUSTOM | {$hadrianLang.cart.requestQuote} | `cart.requestquote` invented | high |
| 727 | text | Browse all categories | CUSTOM | {$hadrianLang.cart.browseAll} | `cart.browseall` invented (dedupe w/ nothing else here) | high |
| 744 | text | 30-day money back | CUSTOM | {$hadrianLang.cart.moneyBack} | `cart.moneyback` invented (guarantee card) | high |
| 745 | text | Full refund if you're not happy — no questions asked. | CUSTOM | {$hadrianLang.cart.moneyBackSub} | `cart.moneybacksub` invented | high |
| 753 | text | 24/7 support | CUSTOM | {$hadrianLang.cart.support247} | `cart.support247` invented | high |
| 754 | text | Reach a human engineer any time via chat or ticket. | CUSTOM | {$hadrianLang.cart.support247Sub} | `cart.support247sub` invented | high |
| 762 | text | 99.99% uptime SLA | CUSTOM | {$hadrianLang.cart.uptime} | `cart.uptime` invented | high |
| 763 | text | Backed by global anycast and redundant power. | CUSTOM | {$hadrianLang.cart.uptimeSub} | `cart.uptimesub` invented | high |
| 780 | text | Choose a category to get started | CUSTOM | {$hadrianLang.cart.pickCategoryTitle} | `cart.pickcategorytitle` invented (landing card) | high |
| 781 | text | Browse our plans by service. All plans come with a 30-day money-back guarantee. | CUSTOM | {$hadrianLang.cart.pickCategoryDesc} | `cart.pickcategorydesc` invented | high |
| 796 | text | View plans | CUSTOM | {$hadrianLang.cart.viewPlans} | `cart.viewplans` invented (category tile CTA) | high |
| 829-830 | js-string | /mo · /qtr · /6mo · /yr · /2yr · /3yr | CUSTOM | {$hadrianLang.cart.cycleShortMonthly} … (6 keys) | `CYCLE_LABEL` JS object literal; dedupe w/ the inline line-261 set. Needs JS lang seeding (file has no `_localLang` bootstrap yet) | med |

_Skipped (already correct, bare): line 136 `orderForm.selectCategory`; 255/325/380/426/507/528/572/623/684 `bundledeal`; 258 `startingfrom`; 265 `ordersetupfee`; 281 `orderavailable`; 288/332/382/458/509/539/583/625/689 `ordernowbutton`. All bare in standard_cart/lagom products.tpl._

---

### hadrian_cart/recommendations-modal.tpl
Fully bare-tokenized; verified against `standard_cart/standard_cart/recommendations-modal.tpl`. Only one non-WHMCS literal.

| Line | Type | Current text | Class | Proposed reference | Evidence / Notes | Conf |
|------|------|--------------|-------|--------------------|------------------|------|
| 54 | aria-label | Close | WHMCS | {$LANG.orderForm.close} | hardcoded `aria-label="Close"`. Stock standard_cart:15 ALSO hardcodes `aria-label="Close"`, but hadrian's own domain-renewals.tpl:264 tokenizes the close button as `{lang key='orderForm.close'}` → use that real key. Dedupe (domains) | high |

_Skipped (already correct, bare): line 47/49 `recommendations.title.generic`/`addedTo`; 73 `continue`; 85 `orderfree`; 88 `ordersetupfee`; 92 `addtocart`; 100 `recommendations.learnMore`; 104 `recommendations.taglinePlaceholder` — all bare in standard_cart._

---

### hadrian_cart/includes/product-recommendations.tpl
Fully bare-tokenized; verified line-for-line against `standard_cart/standard_cart/includes/product-recommendations.tpl` (identical `recommendations.*` keys).

_None found._ (All visible strings are bare `{lang key='…'}` WHMCS keys: `recommendations.productAdded`, `ordersetupfee`, `orderpaymentterm`+cycle, `recommendations.explain.product`/`generic`/`ordered`, `recommendations.title.generic`/`yourOrder`/`yourProducts`, `orderfree`, `addtocart`, `recommendations.learnMore`, `recommendations.taglinePlaceholder` — all confirmed bare in standard_cart.)

---

## Proposed custom keys
```
# --- domains group (domaintransfer.tpl marketing/empty-state) ---
hadrianLang.domains.transferStepsTitle      = "Transfer in 3 steps"
hadrianLang.domains.transferStepsDesc       = "Simple, fast, and we'll guide you through each step."
hadrianLang.domains.transferStep1Title      = "1. Unlock your domain"
hadrianLang.domains.transferStep1Desc       = "At your current registrar, disable the transfer lock so we can pull it over."
hadrianLang.domains.transferStep2Title      = "2. Get your auth code"
hadrianLang.domains.transferStep2Desc       = "Your current registrar will email you a transfer authorization (EPP) code."
hadrianLang.domains.transferStep3Title      = "3. Submit and done"
hadrianLang.domains.transferStep3Desc       = "Enter the domain and code above. We handle the rest -- you'll see confirmation within 24 hours."
hadrianLang.domains.transferWhyTitle        = "Why transfer to us"
hadrianLang.domains.transferWhyExtendTitle  = "+1 free year"
hadrianLang.domains.transferWhyExtendDesc   = "Every transfer includes an additional year of registration at no extra cost."
hadrianLang.domains.transferWhy24Title      = "24-hour transfer"
hadrianLang.domains.transferWhy24Desc       = "Most transfers complete within 24 hours -- no downtime for your site."
hadrianLang.domains.transferWhyPrivacyTitle = "Free WHOIS privacy"
hadrianLang.domains.transferWhyPrivacyDesc  = "Included with every transfer, on every eligible TLD. Keep your info private."
hadrianLang.domains.transferEmptyTitle      = "Enter a domain to transfer"
hadrianLang.domains.transferEmptyDesc       = "Type your existing domain above and we'll start the transfer flow."
hadrianLang.domains.transferEmptyCta        = "Start a transfer"

# --- cart group (domainregister.tpl + products.tpl) ---
hadrianLang.cart.order                = "Order"
hadrianLang.cart.searchModeLabel      = "Search mode"
hadrianLang.cart.aiGenerator          = "AI Generator"
hadrianLang.cart.classicSearch        = "Classic Search"
hadrianLang.cart.filters              = "Filters"
hadrianLang.cart.noMatches            = "No matches"
hadrianLang.cart.mostPopularTlds      = "Most popular"
hadrianLang.cart.popularTldsHint      = "A handful of the best-known extensions for your domain."
hadrianLang.cart.suggestedDomainsHint = "Availability is checked in real time when you add to the cart."
hadrianLang.cart.searchDomainTitle    = "Search a domain"
hadrianLang.cart.searchDomainHint     = "Type a domain name in the search box above to check availability."
hadrianLang.cart.orderServicesTagline = "Browse our plans and add the ones you need to your cart. All plans come with a 30-day money-back guarantee."
hadrianLang.cart.plansHeading         = "Available plans"
hadrianLang.cart.cycleMonthly         = "Monthly"
hadrianLang.cart.cycleAnnual          = "Annual"
hadrianLang.cart.cycleBiennial        = "Biennial"
hadrianLang.cart.cycleSaving          = "Save 20%"
hadrianLang.cart.mostPopular          = "Most popular"
hadrianLang.cart.cycleShortMonthly      = "/mo"
hadrianLang.cart.cycleShortQuarterly    = "/qtr"
hadrianLang.cart.cycleShortSemiannually = "/6mo"
hadrianLang.cart.cycleShortAnnually     = "/yr"
hadrianLang.cart.cycleShortBiennially   = "/2yr"
hadrianLang.cart.cycleShortTriennially  = "/3yr"
hadrianLang.cart.variantLabelA        = "Variant A · 3-up · feature list"
hadrianLang.cart.variantLabelB        = "Variant B · 4-up · minimal cards"
hadrianLang.cart.variantLabelC        = "Variant C · horizontal rows"
hadrianLang.cart.variantLabelD        = "Variant D · comparison table"
hadrianLang.cart.variantLabelE        = "Variant E · bento (hero + minis)"
hadrianLang.cart.variantLabelF        = "Variant F · segmented bar"
hadrianLang.cart.variantLabelG        = "Variant G · spec matrix"
hadrianLang.cart.variantLabelH        = "Variant H · addon cards with radio tiers"
hadrianLang.cart.comparePlans         = "Not sure which plan is right for you?"
hadrianLang.cart.compareAll           = "Compare all features"
hadrianLang.cart.pricesIn             = "Prices in"
hadrianLang.cart.emptyGroupTitle      = "No packages in this category yet"
hadrianLang.cart.emptyGroupDesc       = "We're preparing plans for this service. Browse another category or get in touch -- our team can put together a custom quote for you."
hadrianLang.cart.requestQuote         = "Request a quote"
hadrianLang.cart.browseAll            = "Browse all categories"
hadrianLang.cart.moneyBack            = "30-day money back"
hadrianLang.cart.moneyBackSub         = "Full refund if you're not happy -- no questions asked."
hadrianLang.cart.support247           = "24/7 support"
hadrianLang.cart.support247Sub        = "Reach a human engineer any time via chat or ticket."
hadrianLang.cart.uptime               = "99.99% uptime SLA"
hadrianLang.cart.uptimeSub            = "Backed by global anycast and redundant power."
hadrianLang.cart.pickCategoryTitle    = "Choose a category to get started"
hadrianLang.cart.pickCategoryDesc     = "Browse our plans by service. All plans come with a 30-day money-back guarantee."
hadrianLang.cart.viewPlans            = "View plans"
```

## New ambiguities (for the user to resolve)
1. **`ordernewservices` (products.tpl:119) and `changecurrency` (products.tpl:700)** — classed **WHMCS / med** despite having no bare reference-theme usage in this batch. Both are canonical WHMCS lang-key names whose English matches a known WHMCS string, so rebadging them as Hadrian keys would risk *shadowing* a real translation. If you'd rather only trust reference-cited keys, downgrade these two to CUSTOM (`hadrianLang.cart.orderNewServices` / `hadrianLang.cart.changeCurrency`). Note the existing hadrian usages are inconsistent: cart says "Order new services", clientareaproducts/upgrade say "Order New Services".
2. **Cycle-short labels `/mo /qtr /6mo /yr /2yr /3yr`** — classed CUSTOM because the leading-slash forms are bespoke, but WHMCS ships a real `$LANG.pricingCycleShort.{monthly,quarterly,semiannually,annually,biennially,triennially}` array (confirmed bare in `lagom2.3/orderforms/lagom2/configureproduct.tpl:138`, `summary-table.tpl:326`). If you want WHMCS parity, drop the leading slash and use `{$LANG.pricingCycleShort.<cycle>}` instead of new Hadrian keys — but the rendered text would then be WHMCS's wording (e.g. "yr"/"mo"), not your "/yr"/"/mo". This pair (inline at line 261ff + the JS `CYCLE_LABEL` at 824-831) must stay in sync; the JS half also needs a Smarty→JS lang bootstrap, which products.tpl doesn't currently have.
3. **`.st-variant-label` rows (Variant A–H, classed low)** — these are state-chip developer-preview labels, only rendered when the chip is in "All" mode (never to an end user in production). They are technically visible text so I reported them, but tokenizing them is low value; you may legitimately choose to SKIP them and leave them as English dev affordances.
4. **`Save 20%` (products.tpl:193)** — the "20%" is hardcoded marketing copy, not derived from any product's actual configured discount, so a static `Save 20%` string is fine; but if discounts ever vary per group this should become an interpolated `Save %s%%`. Flagged so it isn't mistaken for data-driven.
```
