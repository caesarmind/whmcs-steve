# B01 — Cart: View Cart (viewcart + sidebar-categories ×3 + empty-cart / remove-item modals)

## Summary

Scope = 6 cart templates: the main `viewcart.tpl`, the three category-sidebar partials, and the
two confirm modals. Per the updated spec, the **primary target is `{$LANG.key|default:'English'}`**
(many keys are invented and silently fall back to English, hiding any genuine WHMCS string).
Counts below include those `|default` red-flags plus a couple of bare hardcoded fragments.

| Metric | Count |
|--------|-------|
| Total in-scope strings | 26 |
| WHMCS (real key — strip `\|default`, or already-correct) | 9 |
| CUSTOM (invented key → rebadge to `$hadrianLang`) | 15 |
| js-string | 0 |
| SKIP-worth-noting | many (see notes) |

Type split of the 26: text 22, title 0 (the `title="…"` attrs all use bare real keys → SKIP),
placeholder 0 (the one promo placeholder is a bare real key → SKIP), plus 4 sidebar fallback labels.

**Key cross-file finding — `$LANG.viewcart` is overloaded.** It is used with `|default` for THREE
different English strings across the theme: `'Your cart'` (viewcart.tpl:902), `'View Cart'`
(sidebar-categories.tpl:102), and `'Open'` (downloadscat default.tpl:121). `viewcart` IS a real
WHMCS key, but its true string is the sidebar action label **"View Cart"** — so using it for an
`<h1>Your cart</h1>` page title is wrong (it would render "View Cart"). The stock order form uses a
*different* key for the page H1: `{$LANG.cartreviewcheckout}` ("Review & Checkout",
standard_cart/viewcart.tpl:25, also lagom layouts-vars.tpl:80). See the per-row notes.

**Both modals + the whole sidebar `$secondarySidebar` path are already correct.** `empty-cart.tpl`,
`remove-item.tpl`, and the primary branch of all three `sidebar-categories*` files use bare real
`$LANG`/`{lang key=}` tokens or menu-object `getLabel()` calls — verified 1:1 against stock
standard_cart. The only sidebar findings are in the **defensive `{else}` fallback** of
`sidebar-categories.tpl` (rendered only when `$secondarySidebar` is empty), which hand-rolls a
Categories/Actions panel with `|default` labels.

**Note on the 4 sidebar fallback action labels** (`cartrenewdomains`, `cartregisterdomain`,
`carttransferdomain`, `categories`): these read like genuine stock WHMCS sidebar lang keys, BUT
neither stock nor lagom ever emits them as `$LANG` keys (both build that panel from
`$secondarySidebar` menu objects via `getLabel()`), so I have **zero bare-usage evidence**. Per the
spec's strict rule ("found ONLY ever with a `|default` → invented"), I class them CUSTOM, but flag
them low/med confidence — if you can confirm them against the server `lang/english.php`, they should
flip to WHMCS (strip the default). This is the main ambiguity in this batch.

---

### hadrian_cart/viewcart.tpl

| Line | Type | Current text | Class | Proposed reference | Evidence / Notes | Conf |
|------|------|--------------|-------|--------------------|------------------|------|
| 902 | text | Your cart | WHMCS | `{$LANG.cartreviewcheckout}` | page H1. `viewcart\|default:'Your cart'` is WRONG — `viewcart` renders "View Cart". Stock uses `{$LANG.cartreviewcheckout}` for this H1 (standard_cart/viewcart.tpl:25; lagom layouts-vars.tpl:80). Switch key. | high |
| 905 | text | item / items | CUSTOM | `{$hadrianLang.cart.itemCount}` | `{$cartitems} item(s)` count suffix; inline `{if ==1}item{else}items{/if}`. No WHMCS key; needs a plural-aware token (or 2 keys `itemSingular`/`itemPlural`). Repeated at line 1374. | high |
| 907 | text | Your cart is empty | WHMCS | `{$LANG.cartempty}` | real key — strip `\|default`. Bare `{$LANG.cartempty}` in standard_cart/viewcart.tpl:430 + lagom/viewcart.tpl:19. Dedupe with line 1540. | high |
| 913 | text | Continue shopping | WHMCS | `{$LANG.orderForm.continueShopping}` | real key — strip `\|default`. Bare at standard_cart/viewcart.tpl:611; nexus/lagom store/order.tpl. Dedupe (used bare already at 1520). | high |
| 918 | aria-label | Checkout progress | CUSTOM | `{$hadrianLang.cart.checkoutProgress}` | `aria-label` on the `.ct-steps` strip; bespoke Apple stepper, no WHMCS key. | med |
| 919 | text | Choose plan | CUSTOM | `{$hadrianLang.cart.stepChoosePlan}` | stepper step label; no WHMCS key. (Matches B03 `stepChoosePlan` — dedupe across cart.) | high |
| 921 | text | Domain | CUSTOM | `{$hadrianLang.cart.stepDomain}` | stepper step label. (`$LANG.domain` may exist but stepper wording is bespoke.) | med |
| 923 | text | Configure | CUSTOM | `{$hadrianLang.cart.stepConfigure}` | stepper step label; no WHMCS key. (Dedupe with B03.) | high |
| 925 | text | Cart | CUSTOM | `{$hadrianLang.cart.stepCart}` | stepper step label. (Dedupe with B03.) | med |
| 927 | text | Checkout | CUSTOM | `{$hadrianLang.cart.stepCheckout}` | stepper step label. NOTE distinct from the button at 1516 which correctly uses `{$LANG.orderForm.checkout}`; the stepper word is bespoke. | med |
| 978 | text | Configuration | CUSTOM | `{$hadrianLang.cart.configuration}` | `orderForm.config` only ever appears with `\|default` (no bare usage anywhere) → invented. Section heading over config-option rows. | med |
| 992 | text | Included addons | CUSTOM | `{$hadrianLang.cart.includedAddons}` | `orderaddons\|default` only — invented (distinct from real `orderaddon` singular at 1053/1396). Section heading. | med |
| 1017 | text | Edit configuration | WHMCS | `{$LANG.orderForm.edit}` | `orderForm.edit` is real — strip `\|default`. Bare at standard_cart/viewcart.tpl:92,229; lagom summary-table.tpl:109. ("Edit configuration" → "Edit" wording shift is acceptable per policy.) | high |
| 1023 | text | Billing cycle | CUSTOM | `{$hadrianLang.cart.billingCycle}` | `cartbillingcycle\|default` only — invented (also in configureproduct.tpl:155). Repeated 5× (1023/1063/1152/1176/1236) → one key. | high |
| 1109 | text | Edit | WHMCS | `{$LANG.orderForm.edit}` | real key — strip `\|default`. Same evidence as 1017. | high |
| 1114 | text | Registration period | CUSTOM | `{$hadrianLang.cart.registrationPeriod}` | `orderForm.registrationPeriod\|default` only — invented (and used for 2 different strings: 'Registration period' here, 'Period' at 1206). Dedupe both to this key. | med |
| 1206 | text | Period | CUSTOM | `{$hadrianLang.cart.registrationPeriod}` | same invented key as 1114, different `\|default` literal — reuse one key ("Registration period"). | med |
| 1334 | text | Last chance | CUSTOM | `{$hadrianLang.cart.lastChance}` | `lastchance\|default` only — invented. Also in checkout.tpl:1472 → dedupe. Badge over `$hookOutput` recommendations. | high |
| 1335 | text | Protect your services and add value | CUSTOM | `{$hadrianLang.cart.lastChanceTitle}` | `lastchancetitle\|default` only — invented. Also checkout.tpl:1473 → dedupe. | high |
| 1336 | text | One-click add. Remove anytime. | CUSTOM | `{$hadrianLang.cart.oneClickAdd}` | `oneclickadd\|default` only — invented. Also checkout.tpl:1474 → dedupe. | high |
| 1525 | text | 256-bit SSL · PCI-DSS Level 1 | CUSTOM | `{$hadrianLang.cart.trustSsl}` | `cartsecured\|default` only — invented, and used for 3 different literals theme-wide (this; "256-bit SSL &middot; PCI-DSS Level 1" summary-aside.tpl:100; "Secured by 256-bit SSL - PCI-DSS Level 1" configureproduct.tpl:588). Pick ONE canonical value. | high |
| 1526 | text | 30-day money-back guarantee | CUSTOM | `{$hadrianLang.cart.trustMoneyBack}` | `cartmoneyback\|default` only — invented. Also summary-aside.tpl:101 → dedupe. | high |
| 1540 | text | Your cart is empty | WHMCS | `{$LANG.cartempty}` | real key — strip `\|default`. Empty-state H2. Dedupe with line 907. | high |
| 1541 | text | Browse our plans and add something to get started… | CUSTOM | `{$hadrianLang.cart.emptySub}` | `cartemptysub\|default` only — invented. Empty-state sub-copy. | high |
| 1545 | text | Browse plans | WHMCS | `{$LANG.orderForm.continueShopping}` | `orderForm.continueShopping\|default:'Browse plans'` — real key, wording shift. Per policy prefer the real key (renders "Continue Shopping"). If "Browse plans" wording is required, make it CUSTOM `{$hadrianLang.cart.browsePlans}` instead — flag for decision. | med |
| 1549 | text | Register a domain | WHMCS* | `{$LANG.cartregisterdomainchoice}` (⚠ see note) | `cartregisterdomainchoice` IS real BUT stock uses it as `\|sprintf2:$companyname` → renders a long sentence ("Register a new domain for use with %s …"), NOT a 2-word button label (standard_cart/configureproductdomain.tpl:46; lagom). Using it bare here would render the wrong/long text. Recommend CUSTOM `{$hadrianLang.cart.registerDomain}` = "Register a domain" instead. | low |

SKIP-worth-noting in this file (verified-real bare keys / `{lang key=}` — already correct, NOT
reported above): `LANG.orderForm.correctErrors` (879), `promoappliedbutnodiscount` (883),
`orderForm.promotionAccepted` (885), `bundlereqsnotmet` (890), `orderForm.remove` (972/1057/1102/1146/1170/1200/1230 `title=`),
`no` (985), `orderForm.qty` (1005/1037/1076/1249), `orderForm.update` (1007/1039/1078/1251),
`ordersetupfee` (1000/1029/1069), `orderprorata` (1030/1070), `orderaddon` (1053/1396),
`orderdomainregistration`/`orderdomaintransfer` (1092/1405), `domaindnsmanagement`/`domainemailforwarding`/`domainidprotection`
(1096-1098/1194-1196), `renewService.titleAltSingular` (1142/1414), `renewServiceAddon.titleAltSingular` (1166/1423),
`domainrenewal` (1190/1432), `orderyears` (1207/1432), `domainrenewalprice` (1126), `orderForm.year`/`orderForm.years` (1121),
`upgrade` (1220/1440), `upgradeCredit` (1243), `upgradeCreditDescription` (1244), `emptycart` (1262 — real),
`orderForm.applyPromoCode` (1270), `orderForm.estimateTaxes` (1274), `orderForm.removePromotionCode` (1286),
`orderPromoCodePlaceholder` (1293 placeholder — real), `orderpromovalidatebutton` (1295 value+text — real),
`orderForm.state`/`country`/`updateTotals` (1306/1310/1318), `ordersummary` (1372), `ordersubtotal` (1450),
`orderForm.totals` (1476), `orderpaymentterm*` (1479-1494), `ordertotalduetoday` (1500), `or` (1508),
`orderForm.checkout` (1516), `orderForm.continueShopping` (1520 — already bare). The two inline `<script>`
blocks (864-868 localStorage bootstrap; 1566-1605 tab/modal/expander wiring) contain **no** user-facing
string literals → no js-string findings.

---

### hadrian_cart/sidebar-categories.tpl

Findings are ONLY in the defensive `{else}` fallback (lines 69-108), rendered when `$secondarySidebar`
is empty. The primary `{if $secondarySidebar}` branch uses menu-object `getLabel()`/`getBadge()` → SKIP.

| Line | Type | Current text | Class | Proposed reference | Evidence / Notes | Conf |
|------|------|--------------|-------|--------------------|------------------|------|
| 73 | text | Categories | CUSTOM | `{$hadrianLang.cart.categories}` | `categories\|default` only — no bare `$LANG.categories` anywhere. Fallback panel heading. (May be a real WHMCS key — no evidence; flag.) | low |
| 86 | text | Actions | WHMCS | `{$LANG.actions}` | `actions` IS real — bare `{$LANG.actions}` in lagom viewquote.tpl:173 + viewinvoice.tpl:273. Strip `\|default`. (Also used `\|default` widely in hadrian client-area pages.) | high |
| 89 | text | Renew Domains | CUSTOM | `{$hadrianLang.cart.renewDomains}` | `cartrenewdomains\|default` only — no bare usage in any reference (stock/lagom build this panel from `$secondarySidebar` menu objects). Likely a real WHMCS sidebar key; flag for server check. | low |
| 93 | text | Register a New Domain | CUSTOM | `{$hadrianLang.cart.registerNewDomain}` | `cartregisterdomain\|default` only — no bare usage (distinct from real `cartregisterdomainchoice`). Flag for server check. | low |
| 97 | text | Transfer in a Domain | CUSTOM | `{$hadrianLang.cart.transferDomain}` | `carttransferdomain\|default` only — no bare usage (distinct from real `carttransferdomainchoice`). Flag for server check. | low |
| 102 | text | View Cart | WHMCS | `{$LANG.viewcart}` | real key — strip `\|default`. "View Cart" is `viewcart`'s genuine string (this is the CORRECT use of the key — contrast the page-H1 misuse at viewcart.tpl:902). | high |

SKIP-worth-noting: `choosecurrency` (not in this file), `$child->getLabel()` etc. (menu objects),
`$cartcount` (var). The `{if $cartcount && $cartcount > 0}` badge is logic/var → SKIP.

---

### hadrian_cart/sidebar-categories-collapsed.tpl

| Line | Type | Current text | Class | Proposed reference | Evidence / Notes | Conf |
|------|------|--------------|-------|--------------------|------------------|------|
| 40 | text | choosecurrency (sr-only label) | — | (already token) | SKIP — bare `{$LANG.choosecurrency}`, verified real (standard_cart sidebar-categories-collapsed.tpl:13; lagom; nexus/footer.tpl). | — |
| 42 | option | choosecurrency | — | (already token) | SKIP — bare real key, same as above. | — |

_No hardcoded strings._ (Currency `<option>` labels are `{$listcurr.code}` = data; panel select is
included from sidebar-categories-selector.tpl.)

---

### hadrian_cart/sidebar-categories-selector.tpl

| Line | Type | Current text | Class | Proposed reference | Evidence / Notes | Conf |
|------|------|--------------|-------|--------------------|------------------|------|
| 54 | option | - Choose another category - | — | (already token) | SKIP — bare `{lang key="cartchooseanothercategory"}`, verified real (standard_cart sidebar-categories-selector.tpl:33; lagom). | — |

_No hardcoded strings._ (Panel heading/labels/badges are all menu-object `getLabel()`/`getBadge()`/`getName()`.)

---

### hadrian_cart/includes/viewcart/modal/empty-cart.tpl

_None found._ All strings are bare verified-real WHMCS keys, matching stock standard_cart/viewcart.tpl:658-670
exactly: `{$LANG.orderForm.close}` (14, aria-label), `{$LANG.emptycart}` (19), `{$LANG.cartemptyconfirm}` (20),
`{$LANG.no}` (23), `{$LANG.yes}` (24).

---

### hadrian_cart/includes/viewcart/modal/remove-item.tpl

_None found._ All strings are bare verified-real WHMCS keys via `{lang key=}`, matching stock
standard_cart/viewcart.tpl:632-644 exactly: `{lang key='orderForm.close'}` (19, aria-label),
`{lang key='orderForm.removeItem'}` (23), `{lang key='cartremoveitemconfirm'}` (25), `{lang key='no'}` (28),
`{lang key='yes'}` (29).

---

## Proposed custom keys

Deduped `$hadrianLang.cart.*` keys (English value from the `|default` literal). Stepper + trust +
last-chance keys are shared with other cart pages (B03/B05) — reuse, don't duplicate.

```
hadrianLang.cart.itemCount          = "item"          # + itemCountPlural = "items" (or a {n} plural token)
hadrianLang.cart.checkoutProgress   = "Checkout progress"
hadrianLang.cart.stepChoosePlan     = "Choose plan"
hadrianLang.cart.stepDomain         = "Domain"
hadrianLang.cart.stepConfigure      = "Configure"
hadrianLang.cart.stepCart           = "Cart"
hadrianLang.cart.stepCheckout       = "Checkout"
hadrianLang.cart.configuration      = "Configuration"
hadrianLang.cart.includedAddons     = "Included addons"
hadrianLang.cart.billingCycle       = "Billing cycle"
hadrianLang.cart.registrationPeriod = "Registration period"
hadrianLang.cart.lastChance         = "Last chance"
hadrianLang.cart.lastChanceTitle    = "Protect your services and add value"
hadrianLang.cart.oneClickAdd        = "One-click add. Remove anytime."
hadrianLang.cart.trustSsl           = "256-bit SSL · PCI-DSS Level 1"
hadrianLang.cart.trustMoneyBack     = "30-day money-back guarantee"
hadrianLang.cart.emptySub           = "Browse our plans and add something to get started. Everything comes with a 30-day money-back guarantee."
hadrianLang.cart.categories         = "Categories"          # ⚠ may be real WHMCS key — verify, flip to {$LANG.categories} if so
hadrianLang.cart.renewDomains       = "Renew Domains"        # ⚠ likely real WHMCS key cartrenewdomains — verify
hadrianLang.cart.registerNewDomain  = "Register a New Domain" # ⚠ likely real WHMCS key cartregisterdomain — verify
hadrianLang.cart.transferDomain     = "Transfer in a Domain" # ⚠ likely real WHMCS key carttransferdomain — verify
hadrianLang.cart.registerDomain     = "Register a domain"    # viewcart.tpl:1549 button (do NOT reuse cartregisterdomainchoice — that's a sprintf2 sentence)
hadrianLang.cart.browsePlans        = "Browse plans"         # OPTIONAL — only if you reject reusing {$LANG.orderForm.continueShopping} at viewcart.tpl:1545
```

### Decisions needed (ambiguities)
1. **`viewcart.tpl:902` H1** — confirm switch `{$LANG.viewcart|default:'Your cart'}` → `{$LANG.cartreviewcheckout}` (stock's H1 key, renders "Review & Checkout"). The current key renders "View Cart" on the page title, which is wrong.
2. **4 sidebar fallback labels** (`categories`, `cartrenewdomains`, `cartregisterdomain`, `carttransferdomain`) — are these real WHMCS keys? If yes → class WHMCS, strip `|default`. I had no bare-usage evidence so defaulted to CUSTOM.
3. **`cartregisterdomainchoice`** — real key but it's a `sprintf2:$companyname` *sentence*, not a button label. Confirm CUSTOM `registerDomain` rather than reusing it.
4. **Wording shifts** at 1545 ("Browse plans") and 1017 ("Edit configuration") — OK to fold into real keys `orderForm.continueShopping` / `orderForm.edit` (policy says prefer real key even if wording shifts)? Or keep bespoke CUSTOM wording?
5. **`itemCount` plural** — singular/plural is done inline (`{if ==1}item{else}items{/if}`). Needs either two keys or a `{n}`-aware plural mechanism; flag your preferred pattern.
