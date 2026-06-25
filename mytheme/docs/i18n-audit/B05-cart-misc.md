# B05 — cart misc (complete / summary / fraud / error / linked accounts / MarketConnect / renewals)

## Summary
- **Total in-scope strings: 2** (both `{$LANG.key|default:'…'}` red flags)
- **WHMCS: 2**
- **CUSTOM: 0**
- **js-string: 0**
- **SKIP-worth-noting: many** — these files are already almost fully tokenized. Nearly every
  user-facing string uses a bare `{$LANG.key}` or `{lang key='…'}` (verified-real WHMCS keys,
  per spec "skip"). No `$rslang.*` legacy tokens appear in this batch. The only real findings
  are the two `|default` literals below, and BOTH turn out to be real WHMCS keys (strip the
  default). There are zero invented keys and zero hardcoded UI text in JS.

Notable SKIP detail: `{$hadrian.assetVersion|default:'18'}` (common.tpl:25,28,36) is a
`|default` but the literal is a version number, not user-facing text → SKIP. Hidden-input
`value="remove"` / `value="service"` (service-renewals.tpl:136–139) are code, not UI → SKIP.

---

### hadrian_cart/common.tpl
_None found._ (only `assetVersion|default:'18'` version numbers + a `data-svc-layout` JS bootstrap; no user-facing strings.)

### hadrian_cart/complete.tpl
_None found._ (all strings are bare verified-real keys: `{$LANG.orderconfirmation}`, `{$LANG.orderreceived}`, `{$LANG.ordernumberis}`, `{$LANG.orderfinalinstructions}`, `{$LANG.ordercompletebutnotpaid}`, `{$LANG.invoicenumber}`, `{$LANG.orderForm.continueToClientArea}`.)

### hadrian_cart/ordersummary.tpl
_None found._ (all strings are bare verified-real keys / `{lang key='…'}`: `ordersetupfee`, `cartsetupfees`, `ordertotalduetoday`, `renewService.titleAltPlural`, `renewServiceAddon.titleAltPlural`, `domainrenewals`, `orderForm.year`/`years`, `domaindnsmanagement`, `domainemailforwarding`, `domainidprotection`, `domainRenewal.graceFee`/`redemptionFee`, `ordersubtotal`.)

### hadrian_cart/fraudcheck.tpl
_None found._ (all bare verified-real keys / `{lang key='…'}`: `cartfraudcheck`, `fraud.furtherVal`, `fraud.submitDocs`, `close`, `orderForm.submitTicket`, `orderForm.returnToClientArea`.)

### hadrian_cart/error.tpl
_None found._ (all bare verified-real keys: `thereisaproblem`, `problemgoback`, `orderForm.submitTicket`.)

### hadrian_cart/linkedaccounts.tpl
_None found._ (all `{lang key='remoteAuthn.*'}` verified-real keys: `noLinkedAccounts`, `provider`, `name`, `emailAddress`, `actions`, `unavailable`, `error`, `connectError`, `completeSignIn`, `redirecting`, `success`, `accountNowLinked`, `linkInitiated`, `oneTimeAuthRequired`, `completeRegistrationForm`, `completeNewAccountForm`, `linkedToAnotherClient`, `alreadyLinkedToYou`, `titleSignUpVerb`, `titleOr`, `saveTimeByLinking`, `mayHaveMultipleLinks`.)

### hadrian_cart/marketconnect-promo.tpl
| Line | Type | Current text | Class | Proposed reference | Evidence / Notes | Conf |
|------|------|--------------|-------|--------------------|------------------|------|
| 61 | title | Click to learn more | WHMCS | `{$LANG.recommendations.learnMore}` (i.e. `{lang key='recommendations.learnMore'}`) | real key — strip `\|default`. Used bare in standard_cart/recommendations-modal.tpl:42 and standard_cart/includes/product-recommendations.tpl:89 as `{lang key="recommendations.learnMore"}`; also lagom2.3/orderforms/lagom2/includes/recommendations-modal.tpl:47. (standard_cart/marketconnect-promo.tpl:21 even hardcodes the same English.) | high |

(Other strings here are bare verified-real keys: `orderfree`, `addtocart` — SKIP.)

### hadrian_cart/service-renewal-item.tpl
| Line | Type | Current text | Class | Proposed reference | Evidence / Notes | Conf |
|------|------|--------------|-------|--------------------|------------------|------|
| 124 | text | Addons | WHMCS | `{$LANG.cartproductaddons}` (i.e. `{lang key='cartproductaddons'}`) | real key — strip `\|default`. Used bare as `{$LANG.cartproductaddons}` in standard_cart/addons.tpl:14 and lagom2.3/orderforms/lagom2/sidebar-categories-selector.tpl:49. | high |

(Other strings here are bare verified-real keys: `renewService.renewalUnavailable`, `renewService.renewingIn`, `renewService.serviceNextDueDateBasic`/`Extended`, `na`, `renewService.renewalPeriodLabel`/`renewalPeriod`, `addtocart`, `domaincheckeradded` — SKIP.)

### hadrian_cart/service-renewals.tpl
_None found._ (all bare verified-real keys / `{lang key='…'}`: `renewService.titlePlural`/`titleSingular`, `renewService.hideShowServices.hide`/`show`, `renewService.searchPlaceholder`, `renewService.noServices`, `orderForm.returnToClientArea`, `renewService.showingServices`, `domainRenewal.showAll`, `ordersummary`, `viewcart`, `orderForm.close`, `orderForm.removeItem`, `cartremoveitemconfirm`, `no`, `yes`. The bottom `<script>recalculateRenewalTotals();</script>` contains no string literals.)

---

## Proposed custom keys
_None._ (Both findings map to existing WHMCS keys — no `$hadrianLang.*` keys needed for this batch.)
