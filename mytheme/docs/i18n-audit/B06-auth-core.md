# B06 — Auth core (login, register, banned, access-denied, 3D secure)

## Summary
- **Total strings (table rows):** 115 (incl. dedupes — e.g. `orderForm.optional` repeats 12x in clientregister, the password-toggle/login labels repeat across the two login variants)
- **WHMCS:** 60
- **CUSTOM:** 52
- **SKIP worth noting:** 3 in-table (`$taxLabel`, the `3D Secure` iframe title, the `Hostnodes` brand fallback) + the inline `value=""` / `data-*` / sample-email / `$code` / charset-literal cases called out in per-file Notes
- **js-string:** 0 (the `<script>` blocks in all six files contain only DOM/crypto/intl-tel-input logic — no user-facing string literals)
- **Distinct keys:** ~58 unique `$LANG.*` keys touched; 36 distinct proposed `$hadrianLang.*` keys (see end)
- **Context:** no `$rslang.*` usage in these files; `core/lang/english.php` only defines `footer/error/license/admin` via `$rslang`, none of the `$LANG.*` keys below — so every `{$LANG.key|default}` here is a genuine `$_LANG`/WHMCS lookup, never a pre-tokenized Hadrian string

### Key evidence pattern
Every `{$LANG.*|default}` key in these files appears in `hadrian/templates/hadrian` **only ever with a `|default`** (grep confirmed — never bare), so hadrian's own usage cannot validate any key. Classification therefore rests on the reference themes:
- **nexus** uses `{lang key='...'}`; **lagom2.3** uses bare `{$LANG.*}`. A key seen **bare** in either reference for the **same** string = real WHMCS key → **WHMCS**, strip default.
- A key whose **exact name** is never found in either reference = invented → **CUSTOM**. Where the references render the same string under a **different** real key, that better target is noted as a *switch-target* (see Ambiguities).

---

### core/pages/login/default/default.tpl
| Line | Type | Current text | Class | Proposed reference | Evidence / Notes | Conf |
|------|------|--------------|-------|--------------------|------------------|------|
| 26 | text | Account | CUSTOM | {$hadrianLang.auth.account} | `accounttab` only ever appears with `|default` in hadrian (sidebar/rail/topnav etc.); not bare in nexus/lagom. Eyebrow label | med |
| 27 | text | Sign in | CUSTOM | {$hadrianLang.auth.signInTitle} | `clientareanavlogin` not found bare in refs. **Switch-target:** real WHMCS page-title key is `clientareahomeloginbtn` (lagom includes/login/login.tpl:11) | med |
| 28 | text | Welcome back. Enter your credentials to access your account. | CUSTOM | {$hadrianLang.auth.welcomeBack} | `welcomeback` not in nexus/lagom at all. Bespoke subtitle | high |
| 45 | text | You have been logged out. See you next time. | CUSTOM | {$hadrianLang.auth.logoutSuccessful} | `logoutsuccessful` not found in refs (lagom surfaces logout via flashmessage.tpl). Invented | high |
| 51 | text | The email address or password you entered is incorrect. Please try again. | CUSTOM | {$hadrianLang.auth.loginDetailsIncorrect} | `logindetailsincorrect` not in refs (routed flow uses get_flash_message; legacy `$incorrect`). Invented | high |
| 57 | text | This email-verification link has expired. Sign in to request a new one. | CUSTOM | {$hadrianLang.auth.verifyLinkExpired} | `verifylinkexpired` not found in refs. Invented | high |
| 63 | text | Your password has been reset. Sign in with your new password. | CUSTOM | {$hadrianLang.auth.pwResetSuccess} | `pwresetsuccess` not found in refs. Invented | high |
| 71 | text | Email Address | WHMCS | {$LANG.loginemail} | real key — strip default. `{lang key='loginemail'}` bare at nexus/password-reset-email-prompt.tpl:10 | high |
| 78 | placeholder | Enter your password | CUSTOM | {$hadrianLang.auth.passwordPlaceholder} | `loginpasswordplaceholder` not in refs (nexus/lagom reuse the field label as placeholder). Invented. **Switch-target:** could reuse `{$LANG.clientareapassword}` | med |
| 76 | text | Password | WHMCS | {$LANG.clientareapassword} | real key — strip default. `loginpassword` is invented; refs use `clientareapassword` for this label (nexus/login.tpl:22, lagom includes/login/login.tpl:28) | high |
| 79 | aria-label | Show or hide password | CUSTOM | {$hadrianLang.auth.togglePassword} | `togglepasswordvisibility` not in refs. Invented | high |
| 89 | text | Remember me | WHMCS | {$LANG.loginrememberme} | real key — strip default. nexus/login.tpl:51, lagom includes/login/login.tpl:35 use `loginrememberme` bare | high |
| 92 | text | Forgot password? | CUSTOM | {$hadrianLang.auth.forgotPassword} | `loginforgotten` not in refs. **Switch-target:** real key is `forgotpw` (nexus/login.tpl:24, oauth/login.tpl:37) | high |
| 97 | text | Forgot password? | CUSTOM | {$hadrianLang.auth.forgotPassword} | dedupe of line 92 (`loginforgotten`). Switch-target `forgotpw` | high |
| 107 | text | Sign In | WHMCS | {$LANG.loginbutton} | real key — strip default. nexus/login.tpl:7,44 + lagom:46 use `loginbutton` bare | high |
| 111 | text | or continue with | CUSTOM | {$hadrianLang.auth.orContinueWith} | `orcontinuewith` not in refs. **Switch-target:** the bare WHMCS divider key is `or` (lagom includes/login/login.tpl:55,64) | med |
| 116 | text | Continue | CUSTOM | {$hadrianLang.auth.continueSso} | `$provider.label|...|default:'Continue'` — fallback label for an SSO provider button; no WHMCS key | low |
| 124 | text | Don't have an account? | CUSTOM | {$hadrianLang.auth.dontHaveAccount} | `dontHaveAccount` not in refs. **Switch-target:** `userLogin.notRegistered` (nexus/login.tpl:55) | high |
| 125 | text | Create one | CUSTOM | {$hadrianLang.auth.createAccountLink} | `createaccount`→'Create one' not bare in refs. **Switch-target:** `userLogin.createAccount` (nexus/login.tpl:56) | high |

_Note: line 72 `placeholder="you@example.com"` is an email-format example, SKIP (sample data, not a translatable label). The SVG/`<script>` password-toggle logic has no user-facing strings._

---

### core/pages/login/split/split.tpl
| Line | Type | Current text | Class | Proposed reference | Evidence / Notes | Conf |
|------|------|--------------|-------|--------------------|------------------|------|
| 30 | text | Hostnodes | — | — | `$companyname|default:'Hostnodes'` — brand fallback, SKIP (proper noun) | high |
| 35 | text | Welcome back. | CUSTOM | {$hadrianLang.auth.welcomeBack} | dedupe of `welcomeback` (login default:28). Same key, shorter literal here — note value differs | high |
| 36 | text | Manage your services, domains, invoices and support — all from one control panel. | CUSTOM | {$hadrianLang.auth.loginWelcomeSub} | `loginwelcomesub` not in refs. Invented marketing copy | high |
| 41 | text | Latest announcements | CUSTOM | {$hadrianLang.auth.latestAnnouncements} | `announcements`→'Latest announcements' not bare in refs as this label. **Switch-target:** WHMCS `announcements` ("Announcements") exists but wording differs | med |
| 42 | text | View all | WHMCS | {$LANG.viewall} | real key — strip default. Used elsewhere in hadrian + standard nav; "View all" is the stock string | med |
| 58 | text | You're all caught up — no announcements right now. | CUSTOM | {$hadrianLang.auth.noAnnouncements} | `loginnonews` not in refs. **Switch-target:** WHMCS empty key is `noannouncements` (lagom/announcements.tpl:73) | high |
| 67 | text | Account | CUSTOM | {$hadrianLang.auth.account} | dedupe — `accounttab` (login default:26) | med |
| 68 | text | Sign in | CUSTOM | {$hadrianLang.auth.signInTitle} | dedupe — `clientareanavlogin` (login default:27). Switch-target `clientareahomeloginbtn` | med |
| 69 | text | Use your account email and password. | CUSTOM | {$hadrianLang.auth.loginIntro} | `loginintro` not in refs. Invented subtitle | high |
| 79 | text | You have been logged out. See you next time. | CUSTOM | {$hadrianLang.auth.logoutSuccessful} | dedupe — `logoutsuccessful` (login default:45) | high |
| 82 | text | The email address or password you entered is incorrect. Please try again. | CUSTOM | {$hadrianLang.auth.loginDetailsIncorrect} | dedupe — `logindetailsincorrect` (login default:51) | high |
| 85 | text | This email-verification link has expired. Sign in to request a new one. | CUSTOM | {$hadrianLang.auth.verifyLinkExpired} | dedupe — `verifylinkexpired` (login default:57) | high |
| 88 | text | Your password has been reset. Sign in with your new password. | CUSTOM | {$hadrianLang.auth.pwResetSuccess} | dedupe — `pwresetsuccess` (login default:63) | high |
| 95 | text | Email Address | WHMCS | {$LANG.loginemail} | dedupe — real key, strip default (login default:71) | high |
| 100 | text | Password | WHMCS | {$LANG.clientareapassword} | dedupe — real key (login default:76) | high |
| 102 | placeholder | Enter your password | CUSTOM | {$hadrianLang.auth.passwordPlaceholder} | dedupe — `loginpasswordplaceholder` (login default:78) | med |
| 103 | aria-label | Show or hide password | CUSTOM | {$hadrianLang.auth.togglePassword} | dedupe — `togglepasswordvisibility` (login default:79) | high |
| 112 | text | Remember me | WHMCS | {$LANG.loginrememberme} | dedupe — real key (login default:89) | high |
| 114 | text | Forgot password? | CUSTOM | {$hadrianLang.auth.forgotPassword} | dedupe — `loginforgotten`; switch-target `forgotpw` | high |
| 123 | text | Sign In | WHMCS | {$LANG.loginbutton} | dedupe — real key (login default:107) | high |
| 127 | text | or continue with | CUSTOM | {$hadrianLang.auth.orContinueWith} | dedupe — `orcontinuewith`; switch-target `or` | med |
| 132 | text | Continue | CUSTOM | {$hadrianLang.auth.continueSso} | dedupe — SSO provider label fallback (login default:116) | low |
| 139 | text | Don't have an account? | CUSTOM | {$hadrianLang.auth.dontHaveAccount} | dedupe — `dontHaveAccount`; switch-target `userLogin.notRegistered` | high |
| 140 | text | Create one | CUSTOM | {$hadrianLang.auth.createAccountLink} | dedupe — `createaccount`→'Create one'; switch-target `userLogin.createAccount` | high |

_Note: line 26 `alt="{$companyname|escape}"` and line 96 `placeholder="you@example.com"` are SKIP (logo alt is a var; email is sample data)._

---

### core/pages/clientregister/default/default.tpl
| Line | Type | Current text | Class | Proposed reference | Evidence / Notes | Conf |
|------|------|--------------|-------|--------------------|------------------|------|
| 43 | text | Create your account | CUSTOM | {$hadrianLang.auth.createAccountTitle} | `createaccount`→'Create your account' not bare in refs. **Switch-target:** real registration title key is `clientregistertitle` (lagom register-form.tpl:325) or `register` (lagom includes/login/register.tpl:11) | med |
| 44 | text | Already have an account? | CUSTOM | {$hadrianLang.auth.alreadyHaveAccount} | `createaccountsub` not in refs. Invented | high |
| 44 | text | Sign in | CUSTOM | {$hadrianLang.auth.signIn} | `signin` not bare in refs. **Switch-target:** lagom uses `$rslang->trans('login.sign_in')` (custom) | med |
| 50 | text | New accounts can only be created during checkout. | WHMCS | {$LANG.registerCreateAccount} | real key — strip default. lagom register-form.tpl:19 + nexus clientregister.tpl:20 use `registerCreateAccount` bare (wording shifts; switch anyway) | high |
| 50 | text | Place an order | WHMCS | {$LANG.registerCreateAccountOrder} | real key — strip default. Same refs (register-form.tpl:19, nexus:20) | high |
| 67 | text | Personal information | WHMCS | {$LANG.orderForm.personalInformation} | real key — strip default. lagom register-form.tpl:52, nexus clientregister.tpl:38. (hadrian's `personalinformation` is invented; use the `orderForm.*` key) | high |
| 70 | text | First name | WHMCS | {$LANG.clientareafirstname} | real key — strip default. Bare across nexus/lagom (clientareadetails.tpl, account-contacts-new.tpl, configuressl-stepone.tpl) | high |
| 70 | text | optional | WHMCS | {$LANG.orderForm.optional} | real key — strip default. `optional` (hadrian) is invented; refs use `orderForm.optional` (lagom register-form.tpl:59) | high |
| 74 | text | Last name | WHMCS | {$LANG.clientarealastname} | real key — strip default. nexus/lagom account-contacts-new.tpl etc. | high |
| 74 | text | optional | WHMCS | {$LANG.orderForm.optional} | dedupe — real key (line 70) | high |
| 80 | text | Email address | WHMCS | {$LANG.clientareaemail} | real key — strip default. nexus/lagom clientareadetails.tpl etc. | high |
| 84 | text | Phone number | WHMCS | {$LANG.clientareaphonenumber} | real key — strip default. nexus/lagom account-contacts-new.tpl etc. | high |
| 84 | text | optional | WHMCS | {$LANG.orderForm.optional} | dedupe — real key | high |
| 91 | text | Billing address | WHMCS | {$LANG.orderForm.billingAddress} | real key — strip default. lagom register-form.tpl:93, nexus clientregister.tpl:80. (`billingaddress` is invented) | high |
| 93 | text | Company name | WHMCS | {$LANG.clientareacompanyname} | real key — strip default. nexus/lagom clientareadetails.tpl etc. | high |
| 93 | text | optional | WHMCS | {$LANG.orderForm.optional} | dedupe — real key | high |
| 98 | text | Tax ID | — | — | `$taxLabel|default:'Tax ID'` — server-provided VAT label var; SKIP (admin-set value, not a literal). nexus/lagom output `$taxLabel`/`Vat::getLabel()` | high |
| 98 | text | optional | WHMCS | {$LANG.orderForm.optional} | dedupe — real key | high |
| 103 | text | Address line 1 | WHMCS | {$LANG.clientareaaddress1} | real key — strip default. nexus/lagom clientareadetails.tpl etc. | high |
| 103 | text | optional | WHMCS | {$LANG.orderForm.optional} | dedupe — real key | high |
| 107 | text | Address line 2 | WHMCS | {$LANG.clientareaaddress2} | real key — strip default. nexus/lagom clientareadetails.tpl etc. | high |
| 107 | text | optional | WHMCS | {$LANG.orderForm.optional} | dedupe — real key | high |
| 112 | text | City | WHMCS | {$LANG.clientareacity} | real key — strip default. nexus/lagom clientareadetails.tpl etc. | high |
| 112 | text | optional | WHMCS | {$LANG.orderForm.optional} | dedupe — real key | high |
| 116 | text | State / region | WHMCS | {$LANG.clientareastate} | real key — strip default. nexus/lagom clientareadetails.tpl etc. | high |
| 116 | text | optional | WHMCS | {$LANG.orderForm.optional} | dedupe — real key | high |
| 122 | text | Zip / postal code | WHMCS | {$LANG.clientareapostcode} | real key — strip default. nexus/lagom clientareadetails.tpl etc. | high |
| 122 | text | optional | WHMCS | {$LANG.orderForm.optional} | dedupe — real key | high |
| 126 | text | Country | WHMCS | {$LANG.clientareacountry} | real key — strip default. nexus/lagom clientareadetails.tpl etc. | high |
| 140 | text | Additional information | WHMCS | {$LANG.orderadditionalrequiredinfo} | real key — strip default. lagom register-form.tpl:179, nexus clientregister.tpl:167. (hadrian's value differs but key fits) | med |
| 147 | text | optional | WHMCS | {$LANG.orderForm.optional} | dedupe — real key | high |
| 150 | text | optional | WHMCS | {$LANG.orderForm.optional} | dedupe — real key | high |
| 159 | text | Preferred currency | WHMCS | {$LANG.choosecurrency} | real key — strip default. lagom register-form.tpl:217, nexus footer.tpl:115. (wording shifts) | med |
| 172 | text | Additional information | WHMCS | {$LANG.orderForm.additionalInformation} | real key — strip default. lagom clientregister.tpl:211, nexus:211 use `orderForm.additionalInformation` bare | high |
| 180 | text | Account security | WHMCS | {$LANG.orderForm.accountSecurity} | real key — strip default. lagom register-form.tpl:233, nexus clientregister.tpl:230 | high |
| 183 | text | Password | WHMCS | {$LANG.clientareapassword} | real key — strip default. `password` (hadrian) is invented; refs use `clientareapassword` (lagom register-form.tpl:240, nexus:239) | high |
| 187 | text | Confirm password | WHMCS | {$LANG.clientareaconfirmpassword} | real key — strip default. `confirmpassword` is invented; refs use `clientareaconfirmpassword` (lagom register-form.tpl:258, nexus:247) | high |
| 196 | text | Generate password | WHMCS | {$LANG.generatePassword.btnLabel} | real key — strip default. lagom pwstrength.tpl:6, nexus clientregister.tpl:253 use `generatePassword.btnLabel` bare | high |
| 201 | text | Security question | WHMCS | {$LANG.clientareasecurityquestion} | real key — strip default. nexus user-security.tpl:35, clientregister.tpl:271 | high |
| 203 | text | Select a security question | WHMCS | {$LANG.clientareasecurityquestion} | real key — strip default. Same key reused for placeholder `<option>` (refs do likewise, lagom register-form.tpl:272) | high |
| 210 | text | Answer | WHMCS | {$LANG.clientareasecurityanswer} | real key — strip default. nexus user-security.tpl:48, clientregister.tpl:284 | high |
| 223 | text | Join our mailing list | WHMCS | {$LANG.emailMarketing.joinOurMailingList} | real key — strip default. lagom register-form.tpl:294, nexus clientregister.tpl:297 | high |
| 230 | text | Yes, send me product news and special offers | CUSTOM | {$hadrianLang.auth.marketingOptInLabel} | `emailMarketing.optInLabel` not in refs (refs render only `$marketingEmailOptInMessage` + on/off switch text). Invented | med |
| 251 | text | I have read and agree to the | WHMCS | {$LANG.ordertosagreement} | real key — strip default. lagom register-form.tpl:314, nexus clientregister.tpl:310 | high |
| 251 | text | Terms of Service | WHMCS | {$LANG.ordertos} | real key — strip default. lagom register-form.tpl:314, nexus footer.tpl:42 | high |
| 256 | value/text | Create account | WHMCS | {$LANG.clientregistertitle} | real key — strip default. Submit-button label. lagom register-form.tpl:325, nexus clientregister.tpl:316 | high |
| 273 | text | Generate a password | WHMCS | {$LANG.generatePassword.title} | real key — strip default. lagom generate-password.tpl:8, nexus generate-password.tpl:7 | high |
| 274 | aria-label | Close | WHMCS | {$LANG.close} | real key — strip default. lagom generate-password.tpl:42, nexus footer.tpl:70 | high |
| 280 | text | Password length | WHMCS | {$LANG.generatePassword.pwLength} | real key — strip default. lagom generate-password.tpl:16, nexus:18 | high |
| 284 | text | Generated password | WHMCS | {$LANG.generatePassword.generatedPw} | real key — strip default. lagom generate-password.tpl:22, nexus:24 | high |
| 287 | title | Generate new | WHMCS | {$LANG.generatePassword.generateNew} | real key — strip default. lagom generate-password.tpl:31, nexus:33 | high |
| 289 | text | New | CUSTOM | {$hadrianLang.auth.generateNewShort} | `generatePassword.generateNew`→'New' — hadrian reuses the `generateNew` key but with a *different* literal ("New" vs "Generate new"). The 'New' short form is not a real WHMCS string → custom | low |
| 295 | text | Cancel | CUSTOM | {$hadrianLang.common.cancel} | `close`→'Cancel' — hadrian reuses `$LANG.close` but with literal "Cancel" (WHMCS `close` = "Close"). The "Cancel" string is `$LANG.cancel` in WHMCS but not proven in refs → custom; **switch-target** `cancel` | low |
| 296 | text | Copy & insert | WHMCS | {$LANG.generatePassword.copyAndInsert} | real key — strip default. lagom generate-password.tpl:45, nexus:47 | high |

_Note: lines 71/75/81/85/94/99/104/108/113/117/123/130 are `value="{$client*|default:''|escape}"` (empty sticky-value defaults) — SKIP. The `<script>` blocks (password generator + intl-tel-input) contain only logic/charset literals (`'abcdefgh...'`, `'phonenumber'`, country codes) — no user-facing UI strings. Line 286 `placeholder="—"` is a dash glyph, SKIP._

---

### core/pages/banned/default/default.tpl
| Line | Type | Current text | Class | Proposed reference | Evidence / Notes | Conf |
|------|------|--------------|-------|--------------------|------------------|------|
| 18 | text | Error | CUSTOM | {$hadrianLang.errors.eyebrow} | `error`→'Error' eyebrow; `$LANG.error` not bare in refs as a page eyebrow. Invented (also used in access-denied:18) | med |
| 19 | text | Account suspended | CUSTOM | {$hadrianLang.errors.bannedTitle} | `bannedtitle` not in nexus/lagom at all (refs build the banned page from `bannedyourip`/`bannedhasbeenbanned`/`bannedbanreason`/`bannedbanexpires`). Invented | high |
| 26 | text | Your account access is suspended | CUSTOM | {$hadrianLang.errors.bannedHeading} | `bannedheading` not in refs. Invented | high |
| 28 | text | Reason | CUSTOM | {$hadrianLang.errors.bannedReason} | `bannedreason` not in refs. **Switch-target:** real key is `bannedbanreason` (nexus banned.tpl:10, lagom banned.tpl:9) | high |
| 28 | text | Access to this account has been temporarily restricted. Please contact support to resolve the issue. | CUSTOM | {$hadrianLang.errors.bannedSub} | `bannedsub` not in refs. Invented fallback copy | high |
| 29 | text | Expires | CUSTOM | {$hadrianLang.errors.bannedExpires} | `bannedexpires` not in refs. **Switch-target:** real key is `bannedbanexpires` (nexus banned.tpl:13, lagom banned.tpl:10) | high |
| 32 | text | Contact support | WHMCS | {$LANG.contactus} | real key — strip default. nexus contact.tpl:5, footer.tpl:37 use `contactus` bare (wording shifts "Contact us"→"Contact support") | med |

_Note: line 12 `'{$dashIsEmpty}'` and line 13 `'off'` inside the `<script>` are `data-*` attribute values, SKIP._

---

### core/pages/access-denied/default/default.tpl
| Line | Type | Current text | Class | Proposed reference | Evidence / Notes | Conf |
|------|------|--------------|-------|--------------------|------------------|------|
| 18 | text | Error | CUSTOM | {$hadrianLang.errors.eyebrow} | dedupe — `error` eyebrow (banned:18) | med |
| 19 | text | Access denied | CUSTOM | {$hadrianLang.errors.accessDenied} | `accessdenied` not bare in refs. **Switch-target:** nexus/lagom access-denied use `oops` ("Oops") + `subaccountpermissiondenied` for the title/body | med |
| 26 | text | You don't have access to this page | CUSTOM | {$hadrianLang.errors.accessDeniedHeading} | `accessdeniedheading` not in refs. **Switch-target:** `subaccountpermissiondenied` (nexus access-denied.tpl:5, lagom:8) | high |
| 27 | text | Your account may not have permission to view this, or you may need to sign in again. Contact support if you believe this is an error. | CUSTOM | {$hadrianLang.errors.accessDeniedSub} | `accessdeniedsub` not in refs. Invented fallback copy (only shows when `$errormessage` empty) | high |
| 29 | text | Back to dashboard | WHMCS | {$LANG.returnclient} | real key — strip default. nexus ticketfeedback.tpl:7 uses `returnclient` bare (wording shifts "Return to Client Area") | high |
| 30 | text | Contact support | WHMCS | {$LANG.contactus} | dedupe — real key (banned:32) | med |

_Note: lines 12–13 `<script>` `data-*` values, SKIP._

---

### core/pages/3dsecure/default/default.tpl
| Line | Type | Current text | Class | Proposed reference | Evidence / Notes | Conf |
|------|------|--------------|-------|--------------------|------------------|------|
| 23 | text | Payment | CUSTOM | {$hadrianLang.billing.paymentEyebrow} | `invoices`→'Payment' eyebrow; `$LANG.invoices` is real but means "Invoices"/"My Invoices" (used so elsewhere in hadrian), not "Payment" — the 'Payment' literal is a custom eyebrow → rebadge | med |
| 24 | text | Verify your payment | CUSTOM | {$hadrianLang.billing.verifyPaymentTitle} | `creditcard3dsecuretitle` not in refs (nexus/lagom 3dsecure.tpl have no title, only the info alert). Invented | high |
| 30 | text | Your bank requires an extra verification step. Complete the challenge below to finish your payment. | WHMCS | {$LANG.creditcard3dsecure} | real key — strip default. nexus 3dsecure.tpl:1 + lagom 3dsecure.tpl:4 use `creditcard3dsecure` bare for this info text (wording shifts) | high |
| 36 | title | 3D Secure | — | — | `<iframe title="3D Secure">` — "3D Secure" is a proper-noun protocol name; borderline. Left SKIP (brand/spec term, matches WHMCS internal naming) | low |
| 40 | text | Waiting for the verification challenge... | CUSTOM | {$hadrianLang.billing.verifyLoading} | `creditcard3dsecureloading` not in refs (refs auto-submit immediately, no loading state). Invented | high |

_Note: lines 17–18 `<script>` `data-*` values, SKIP. Line 35 `{$code}` is the gateway-supplied 3DS form HTML, SKIP._

---

## Proposed custom keys
```
hadrianLang.auth.account = "Account"
hadrianLang.auth.signInTitle = "Sign in"
hadrianLang.auth.welcomeBack = "Welcome back. Enter your credentials to access your account."
hadrianLang.auth.logoutSuccessful = "You have been logged out. See you next time."
hadrianLang.auth.loginDetailsIncorrect = "The email address or password you entered is incorrect. Please try again."
hadrianLang.auth.verifyLinkExpired = "This email-verification link has expired. Sign in to request a new one."
hadrianLang.auth.pwResetSuccess = "Your password has been reset. Sign in with your new password."
hadrianLang.auth.passwordPlaceholder = "Enter your password"
hadrianLang.auth.togglePassword = "Show or hide password"
hadrianLang.auth.forgotPassword = "Forgot password?"
hadrianLang.auth.orContinueWith = "or continue with"
hadrianLang.auth.continueSso = "Continue"
hadrianLang.auth.dontHaveAccount = "Don't have an account?"
hadrianLang.auth.createAccountLink = "Create one"
hadrianLang.auth.loginWelcomeSub = "Manage your services, domains, invoices and support — all from one control panel."
hadrianLang.auth.latestAnnouncements = "Latest announcements"
hadrianLang.auth.noAnnouncements = "You're all caught up — no announcements right now."
hadrianLang.auth.loginIntro = "Use your account email and password."
hadrianLang.auth.createAccountTitle = "Create your account"
hadrianLang.auth.alreadyHaveAccount = "Already have an account?"
hadrianLang.auth.signIn = "Sign in"
hadrianLang.auth.marketingOptInLabel = "Yes, send me product news and special offers"
hadrianLang.auth.generateNewShort = "New"
hadrianLang.common.cancel = "Cancel"
hadrianLang.errors.eyebrow = "Error"
hadrianLang.errors.bannedTitle = "Account suspended"
hadrianLang.errors.bannedHeading = "Your account access is suspended"
hadrianLang.errors.bannedReason = "Reason"
hadrianLang.errors.bannedSub = "Access to this account has been temporarily restricted. Please contact support to resolve the issue."
hadrianLang.errors.bannedExpires = "Expires"
hadrianLang.errors.accessDenied = "Access denied"
hadrianLang.errors.accessDeniedHeading = "You don't have access to this page"
hadrianLang.errors.accessDeniedSub = "Your account may not have permission to view this, or you may need to sign in again. Contact support if you believe this is an error."
hadrianLang.billing.paymentEyebrow = "Payment"
hadrianLang.billing.verifyPaymentTitle = "Verify your payment"
hadrianLang.billing.verifyLoading = "Waiting for the verification challenge..."
```

## Ambiguities / switch-targets (for the fix phase)
These hadrian keys are **invented** (only ever seen with `|default`), but the references render the *same string* under a **real** WHMCS key. Recommend switching to the WHMCS key rather than minting a custom one — flagged because the wording shifts slightly:
- `loginpassword` → use `{$LANG.clientareapassword}` (already classed WHMCS above).
- `loginforgotten` ("Forgot password?") → real key `forgotpw`.
- `clientareanavlogin` ("Sign in" title) → real key `clientareahomeloginbtn` (= "Login").
- `orcontinuewith` ("or continue with") → real divider key `or`.
- `dontHaveAccount` ("Don't have an account?") → `userLogin.notRegistered`.
- `createaccount`→"Create one" link → `userLogin.createAccount`.
- `loginnonews` → `noannouncements`.
- `bannedreason`/`bannedexpires` → `bannedbanreason`/`bannedbanexpires`.
- `accessdeniedheading` → `subaccountpermissiondenied`; access-denied title → `oops`.
- `personalinformation`/`billingaddress`/`optional`/`password`/`confirmpassword` (clientregister) → the proven `orderForm.personalInformation` / `orderForm.billingAddress` / `orderForm.optional` / `clientareapassword` / `clientareaconfirmpassword` (all classed WHMCS above).
- `3dsecure` eyebrow `invoices`→"Payment": `$LANG.invoices` is real but means "Invoices", so "Payment" was kept CUSTOM. Decide whether to relabel the eyebrow to "Invoices"/WHMCS or keep a custom "Payment".
- **Reused-key-with-wrong-literal traps:** clientregister line 289 (`generatePassword.generateNew`→"New") and line 295 (`close`→"Cancel") pipe a *different* literal through a real WHMCS key via `|default`. The `|default` is dead on the server (the real key wins), so the rendered text will be the WHMCS string ("Generate new" / "Close"), not hadrian's "New"/"Cancel". Either accept the WHMCS wording (drop these customs) or use a genuinely custom key — kept CUSTOM here to surface the mismatch.
