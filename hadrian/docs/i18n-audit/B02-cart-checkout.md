# B02 — Cart Checkout

## Summary
- **Total strings reported:** 33
- **WHMCS (real key — strip `|default`):** 8
- **CUSTOM (invented LANG key / hardcoded → rebadge):** 25
- **js-string:** 0 (every `<script>` block here is contract wiring + comments only; no user-facing JS strings)
- **SKIP worth noting:** many bare `{$LANG.*}` / `{lang key=...}` (already correct), `placeholder="MM / YY"` / `placeholder="—"` (format/symbol), `?` CVV-help button glyph, `&times;` close glyph. These are NOT reported.

### Evidence anchors (real WHMCS keys, used bare in references)
- `ordersummary` — standard_cart/viewcart.tpl:538, lagom2 ordersummary.tpl:100
- `ordersubtotal` — standard_cart/viewcart.tpl:542 (already bare in summary-aside.tpl:47, not reported)
- `ordertotalduetoday` — standard_cart/checkout.tpl:572, standard_cart/viewcart.tpl:593
- `orderpaymentmethod` — lagom2/includes/viewcart/form-payment-gateway.tpl:6, nexus/upgradesummary.tpl:120
- `orderForm.checkout` — standard_cart/checkout.tpl:26, lagom2/viewcart.tpl:226
- `orderForm.createAccount` — standard_cart/checkout.tpl:118, lagom2/includes/viewcart/form-billing.tpl:121
- `orderForm.alreadyRegistered` — standard_cart/checkout.tpl:33
- `checkout` — standard_cart/domainregister.tpl:125 (`{lang key='checkout'}`), hadrian_cart/domainregister.tpl:330

---

### hadrian_cart/checkout.tpl
| Line | Type | Current text | Class | Proposed reference | Evidence / Notes | Conf |
|------|------|--------------|-------|--------------------|------------------|------|
| 1397 | text | Your cart | WHMCS | {$LANG.orderForm.checkout} | real key (standard_cart/checkout.tpl:26 bare) → strip default. AMBIGUITY: real string renders "Checkout"; here the literal is "Your cart" (an H1). If the "Your cart" wording must persist, make it CUSTOM `{$hadrianLang.cart.yourCartTitle}` instead | med |
| 1398 | text | Almost there. Enter your details, choose how you'd like to pay… | CUSTOM | {$hadrianLang.cart.checkoutSubtitle} | invented LANG key (`orderForm.almostDone` only ever with default) → rebadge | high |
| 1402 | text | Back to cart | CUSTOM | {$hadrianLang.cart.backToCart} | invented (`orderForm.backToCart` only with default; no bare ref) → rebadge. Dedupe w/ summary-aside.tpl:95 | high |
| 1406 | aria-label | Checkout progress | CUSTOM | {$hadrianLang.cart.checkoutProgress} | hardcoded aria-label; no WHMCS key | med |
| 1407 | text | Choose plan | CUSTOM | {$hadrianLang.cart.chooseProduct} | invented (`orderForm.chooseProduct` only with default) → rebadge | high |
| 1409 | text | Domain | CUSTOM | {$hadrianLang.cart.stepDomain} | `cartdomain` has no real bare usage (standard_cart uses cartdomains/cartdomaininvalid, not cartdomain) → invented | med |
| 1411 | text | Configure | CUSTOM | {$hadrianLang.cart.stepConfigure} | `cartconfigure` has no real bare usage (only `cartconfiguredesc` exists) → invented | med |
| 1413 | text | Cart | CUSTOM | {$hadrianLang.cart.stepCart} | plain hardcoded step label (no LANG var at all); no WHMCS key | high |
| 1415 | text | Checkout | WHMCS | {$LANG.checkout} | real key (standard_cart/domainregister.tpl:125 `{lang key='checkout'}`) → strip default | high |
| 1431 | text | Please correct the errors below | SKIP→ok | — | `{$LANG.orderForm.correctErrors}` bare (no default); already correct — not reported | — |
| 1472 | text | Last chance | CUSTOM | {$hadrianLang.cart.lastChanceBadge} | invented (`lastchance` only with default; no bare ref) → rebadge. Dedupe w/ viewcart.tpl:1334 | high |
| 1473 | text | Protect your services and add value | CUSTOM | {$hadrianLang.cart.lastChanceTitle} | invented (`lastchancetitle` only with default) → rebadge. Dedupe w/ viewcart.tpl:1335 | high |
| 1474 | text | One-click add. Remove anytime. | CUSTOM | {$hadrianLang.cart.oneClickAdd} | invented (`oneclickadd` only with default) → rebadge. Dedupe w/ viewcart.tpl:1336 | high |
| 1513 | text | (Additional Notes) | SKIP→ok | — | `{$LANG.orderForm.additionalNotes}` bare; already correct — not reported | — |
| 1514 | text | Optional | WHMCS | {$LANG.orderForm.optional} | `orderForm.optional` is real (used bare as `({$LANG.orderForm.optional})` in account.tpl:181) → strip default | high |
| 1514 | text | included with your order | CUSTOM | {$hadrianLang.cart.includedWithOrder} | invented (`includedwithyourorder` only with default; no ref) → rebadge | high |

_All `<script>` blocks (lines 75–195, 1579–1871): JS identifiers + comments only — no user-facing string literals. SKIP._

---

### hadrian_cart/includes/checkout/account.tpl
| Line | Type | Current text | Class | Proposed reference | Evidence / Notes | Conf |
|------|------|--------------|-------|--------------------|------------------|------|
| 97 | text | Your account | CUSTOM | {$hadrianLang.cart.yourAccount} | invented (`orderForm.yourAccount` only with default; no bare ref) → rebadge | high |
| 101 | text | Create an account | WHMCS | {$LANG.orderForm.createAccount} | real key (standard_cart/checkout.tpl:118 bare) → strip default | high |
| 104 | text | I already have one | WHMCS | {$LANG.orderForm.alreadyRegistered} | real key (standard_cart/checkout.tpl:33 bare). AMBIGUITY: real string is "Already Registered?" — wording shifts from "I already have one". Per policy (prefer real key even if wording shifts) → WHMCS | med |
| 282 | text | or sign up with | CUSTOM | {$hadrianLang.cart.orSignUpWith} | invented (`orderForm.orSignUpWith` only with default) → rebadge | high |
| 286 | text | Sign up with Apple | CUSTOM | {$hadrianLang.cart.signupApple} | invented (`orderForm.signupApple` only with default). "Apple" is a brand but the sentence is tokenizable | high |
| 290 | text | Sign up with Google | CUSTOM | {$hadrianLang.cart.signupGoogle} | invented (`orderForm.signupGoogle` only with default). "Google" is a brand but the sentence is tokenizable | high |
| 319 | text | Forgot your password? | WHMCS | {$LANG.loginforgotten} | AMBIGUITY: `loginforgotten` is a canonical stock WHMCS key but is found ONLY with `|default` in this repo (hadrian login pages + here) — no bare cite in references. Policy "prefer real key" → WHMCS; flag for confirm. (If treated as unproven → CUSTOM `{$hadrianLang.cart.forgotPassword}`) | med |

_Bare/correct (NOT reported): `switchAccount.title` (34), `closed`/`noPermission` (52/54), `orderForm.createAccount` lang-key (79), `orderForm.enterPersonalDetails` (110), `orderForm.personalInformation` (133), placeholders `orderForm.firstName/lastName/emailAddress/phoneNumber/companyName/optional/streetAddress/streetAddress2/city/state/postcode` (142–224), `$taxLabel` (247), `orderadditionalrequiredinfo`+`orderForm.requiredField` (255), `orderForm.billingAddress` (172), `orderForm.existingCustomerLogin` (299), `clientareapassword` (321), `login`/`pleasewait` (328/329), `orderForm.additionalInformation` (341)._

---

### hadrian_cart/includes/checkout/domain-registrant.tpl
| Line | Type | Current text | Class | Proposed reference | Evidence / Notes | Conf |
|------|------|--------------|-------|--------------------|------------------|------|
| _—_ | | _None found._ | | | Every string is a bare `{$LANG.*}` or `{$taxLabel}` with no `|default` (e.g. `domainregistrantinfo` 18, `orderForm.domainAlternativeContact` 21, `usedefaultcontact` 26, `clientareanavaddcontact` 33, all field placeholders). Identical to standard_cart/checkout.tpl:347–476. Already correct — SKIP | |

---

### hadrian_cart/includes/checkout/generate-password-modal.tpl
| Line | Type | Current text | Class | Proposed reference | Evidence / Notes | Conf |
|------|------|--------------|-------|--------------------|------------------|------|
| _—_ | | _None found._ | | | All labels use bare `{lang key='generatePassword.*'}` / `{lang key='close'}` (title 25, close 26/50, lengthValidationError 31, pwLength 34, generatedPw 39, generateNew 42/44, copyAndInsert 52). No `|default`, no hardcoded text. `placeholder="—"` is a symbol → SKIP. Already correct | |

---

### hadrian_cart/includes/checkout/payment.tpl
| Line | Type | Current text | Class | Proposed reference | Evidence / Notes | Conf |
|------|------|--------------|-------|--------------------|------------------|------|
| 24 | text | Payment method | WHMCS | {$LANG.orderpaymentmethod} | real key (lagom2/includes/viewcart/form-payment-gateway.tpl:6 bare `{$LANG.orderpaymentmethod}`) → strip default. (standard_cart uses `orderForm.paymentDetails` here; either is fine — keep orderpaymentmethod) | high |
| 28 | text | (Total Due Today) | SKIP→ok | — | `{$LANG.ordertotalduetoday}` bare; already correct — not reported | — |
| 87 | text | Cards are processed securely by Stripe. | CUSTOM | {$hadrianLang.cart.gatewaySubStripe} | hardcoded gateway sub-text; "Stripe" brand inside a tokenizable sentence; no WHMCS key | high |
| 89 | text | Visa · Mastercard · Amex — processed securely. | CUSTOM | {$hadrianLang.cart.gatewaySubCard} | hardcoded gateway sub-text; brand names inside a tokenizable sentence | high |
| 91 | text | You'll be redirected to authorise the charge. | CUSTOM | {$hadrianLang.cart.gatewaySubPaypal} | hardcoded gateway sub-text (PayPal branch); no WHMCS key | high |
| 93 | text | Direct debit or bank transfer, depending on gateway setup. | CUSTOM | {$hadrianLang.cart.gatewaySubBank} | hardcoded gateway sub-text (bank/ACH branch); no WHMCS key | high |
| 95 | text | Pay securely using this gateway. | CUSTOM | {$hadrianLang.cart.gatewaySubGeneric} | hardcoded gateway sub-text (fallback branch); no WHMCS key | high |

_Bare/correct (NOT reported): `cart.availableCreditBalance` (32), `cart.applyCreditAmountNoFurtherPayment` (37), `cart.applyCreditAmount` (41), `cart.applyCreditSkip` (45), `paymentMethodsManage.cvcNumberNotValid` (130/177), `creditcardenternewcard` (141), `creditcardcvvnumbershort` (123/170), `orderForm.cardNumber` (151), `paymentMethodsManage.unsupportedCardType`/`cardNumberNotValid`/`expiryDateNotValid` (151/161), `creditcardcardexpires/cardstart/cardissuenum` (160/186/194), `paymentMethods.descriptionInput`+`paymentMethodsManage.optional` (206), `yes`/`no` (212), `creditCardStore` (215), `paymentPreApproved` (227). `placeholder="MM / YY"` (160/186) = format → SKIP. `?` glyph (127/172) → SKIP._

---

### hadrian_cart/includes/checkout/security.tpl
| Line | Type | Current text | Class | Proposed reference | Evidence / Notes | Conf |
|------|------|--------------|-------|--------------------|------------------|------|
| _—_ | | _None found._ | | | Every string is a bare `{$LANG.*}` with no `|default` (`orderForm.accountSecurity` 25, `clientareapassword` 35, `clientareaconfirmpassword` 43, `generatePassword.btnLabel` 49, `pwstrength`+`pwstrengthenter` 57, `clientareasecurityquestion` 65, `clientareasecurityanswer` 78). Identical to standard_cart/checkout.tpl:482–540. Already correct — SKIP | |

---

### hadrian_cart/includes/checkout/summary-aside.tpl
| Line | Type | Current text | Class | Proposed reference | Evidence / Notes | Conf |
|------|------|--------------|-------|--------------------|------------------|------|
| 24 | text | Order summary | WHMCS | {$LANG.ordersummary} | real key (standard_cart/viewcart.tpl:538 bare) → strip default | high |
| 47 | text | (Subtotal) | SKIP→ok | — | `{$LANG.ordersubtotal}` bare; already correct — not reported | — |
| 71 | text | Total due today | WHMCS | {$LANG.ordertotalduetoday} | real key (standard_cart/checkout.tpl:572 bare) → strip default | high |
| 76 | text | Recurring | CUSTOM | {$hadrianLang.cart.recurringTotal} | invented (`orderForm.recurringTotal` only with default; no bare ref) → rebadge | high |
| 90 | text | (Complete Order) | SKIP→ok | — | `{$LANG.completeorder}` / `{$LANG.confirmAndPay}` bare; already correct — not reported | — |
| 95 | text | Back to cart | CUSTOM | {$hadrianLang.cart.backToCart} | invented; dedupe w/ checkout.tpl:1402 (same key) | high |
| 100 | text | 256-bit SSL · PCI-DSS Level 1 | CUSTOM | {$hadrianLang.cart.securedBadge} | invented (`cartsecured` only with default; no bare ref) → rebadge. NOTE: configureproduct.tpl:588 uses a DIFFERENT literal for the same key ("Secured by 256-bit SSL - PCI-DSS Level 1") — reconcile to one value | high |
| 101 | text | 30-day money-back guarantee | CUSTOM | {$hadrianLang.cart.moneyBackBadge} | invented (`cartmoneyback` only with default; no bare ref) → rebadge. Dedupe w/ viewcart.tpl:1526 | high |

---

### hadrian_cart/includes/existing-paymethods.tpl
| Line | Type | Current text | Class | Proposed reference | Evidence / Notes | Conf |
|------|------|--------------|-------|--------------------|------------------|------|
| _—_ | | _None found._ | | | Only user-facing label is `{$LANG.clientareaexpired}` (130) — bare, no default, already correct (matches standard_cart/includes/existing-paymethods.tpl:43). Brand badges (VISA/MC/AMEX/DISC/CARD/BANK, lines 67–84) are payment-network proper nouns → SKIP. All else is `$payMethod->*` data output → SKIP | |

---

## Proposed custom keys
```
hadrianLang.cart.checkoutSubtitle = "Almost there. Enter your details, choose how you'd like to pay, and complete your order."
hadrianLang.cart.backToCart = "Back to cart"
hadrianLang.cart.checkoutProgress = "Checkout progress"
hadrianLang.cart.chooseProduct = "Choose plan"
hadrianLang.cart.stepDomain = "Domain"
hadrianLang.cart.stepConfigure = "Configure"
hadrianLang.cart.stepCart = "Cart"
hadrianLang.cart.lastChanceBadge = "Last chance"
hadrianLang.cart.lastChanceTitle = "Protect your services and add value"
hadrianLang.cart.oneClickAdd = "One-click add. Remove anytime."
hadrianLang.cart.includedWithOrder = "included with your order"
hadrianLang.cart.yourAccount = "Your account"
hadrianLang.cart.orSignUpWith = "or sign up with"
hadrianLang.cart.signupApple = "Sign up with Apple"
hadrianLang.cart.signupGoogle = "Sign up with Google"
hadrianLang.cart.gatewaySubStripe = "Cards are processed securely by Stripe."
hadrianLang.cart.gatewaySubCard = "Visa · Mastercard · Amex — processed securely."
hadrianLang.cart.gatewaySubPaypal = "You'll be redirected to authorise the charge."
hadrianLang.cart.gatewaySubBank = "Direct debit or bank transfer, depending on gateway setup."
hadrianLang.cart.gatewaySubGeneric = "Pay securely using this gateway."
hadrianLang.cart.recurringTotal = "Recurring"
hadrianLang.cart.securedBadge = "256-bit SSL · PCI-DSS Level 1"
hadrianLang.cart.moneyBackBadge = "30-day money-back guarantee"
```
_If `loginforgotten` is ruled unproven (no bare cite), add: `hadrianLang.cart.forgotPassword = "Forgot your password?"`._
_If the "Your cart" H1 wording must persist over the real `orderForm.checkout` ("Checkout"), add: `hadrianLang.cart.yourCartTitle = "Your cart"`._
