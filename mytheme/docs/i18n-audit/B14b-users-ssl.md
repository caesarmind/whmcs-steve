# B14b — User account pages + SSL (account / ssl groups)

## Summary
- **Total strings reported:** 173
- **WHMCS** (real key, strip `|default` or already-correct key name): 121
- **CUSTOM** (invented LANG key → rebadge `$hadrianLang`): 47
- **js-string:** 5
- **SKIP-worth-noting:** legacy `$rslang` — none of these 13 files use `$rslang`; `core/lang/english.php` holds only `footer/error/license/admin` groups (no `account`/`ssl` keys), so no legacy collisions. Many bare `{$LANG.key}` (no default) and `{lang key=...}` calls (e.g. `affiliateWithdrawalSummary`, `$provider.code`) are correctly tokenized and skipped.

### New ambiguities / traps surfaced this batch
1. **`continuetoclientarea` is invented** (used ONLY with `|default` everywhere in hadrian). Real key = **`orderForm.continueToClientArea`** (nexus/user-verify-email.tpl:33, lagom user-verify-email.tpl:11, standard_cart/complete.tpl:58). Appears in user-verify-email, user-invite-accept, user-switch-account. → WHMCS, rename key.
2. **`signin` is invented** → real key **`login`** (nexus/user-invite-accept.tpl:43,56; oauth/login.tpl:41). **`createaccount` is invented** → real key **`register`** ("Register", nexus/user-invite-accept.tpl:64,110) OR **`orderForm.createAccount`** ("Create Account", standard_cart/checkout.tpl:36, lagom login.tpl:74) — the latter matches our "Create account" wording. Theme-wide (also on login/clientregister); flagged here for user-invite-accept.
3. **`contactsupport` is invented** → real key **`contactus`** ("Contact Us", nexus/footer.tpl:37, lagom user-invite.tpl:138). Appears user-security, clientareasecurity.
4. **`affiliatesvisitors` trap** — hadrian labels the visitors tile `affiliatesvisitors|default:'Visitors referred'`, but the real WHMCS key for that stat is **`affiliatesclicks`** (nexus/affiliates.tpl:20, lagom affiliates.tpl:17). → WHMCS, rename.
5. **`switchaccount` / `switchAccount.switchTo` traps** — the WHMCS string for the "Switch to/Switch Account" action button is **`navSwitchAccount`** (lagom user-switch-account.tpl:44). hadrian's `switchaccount` (nav label) and `switchAccount.switchTo` (row button) are both invented for that text. (Note `switchAccount.noneFound/.createInstructions/.choose` ARE real — see user-switch-account table.)
6. **Snake-case vs WHMCS dot-case family traps (whole-key class):**
   - `emailverification_*` (snake) → real keys are **`emailVerification.success/.expired/.notFound`** + **`emailVerification.loginToRequest`** (nexus & lagom user-verify-email).
   - `accountinvite_*` (snake) → real keys **`accountInvite.youHaveBeenInvited/.givenAccess/.inviteAcceptLoggedIn/.inviteAcceptLoggedOut/.accept/.notFound`** (nexus/user-invite-accept; lagom includes/login/user-invite.tpl).
   - SSL method/field keys `sslemailmethod`, `ssldnsmethod`, `sslfilemethod`, `sslselectvalidation`, `ssltype`, `sslhost`, `sslvalue`, `sslemailinformation`, `ssldnsrecordinformation`, `sslfileinformation`, `sslurl`, `sslemailsteps`, `ssldnssteps`, `sslfilesteps`, `sslselectemail` → real WHMCS keys are the **`ssl.*` dotted** family (`ssl.emailMethod`, `ssl.dnsMethod`, `ssl.fileMethod`, `ssl.selectValidation`, `ssl.type`, `ssl.host`, `ssl.value`, `ssl.emailInformation`, `ssl.dnsRecordInformation`, `ssl.fileInformation`, `ssl.url`, `ssl.emailSteps`, `ssl.dnsSteps`, `ssl.fileSteps`, `ssl.selectEmail`) — confirmed in BOTH nexus & lagom configuressl-step{one,two}/-complete.
7. **`pleasechoose` trap** — hadrian step-1 server-type placeholder uses `pleasechoose|default:'Please choose...'`; the WHMCS-native string for this exact `<option>` is **`ssl.selectWebserver`** (nexus configuressl-stepone.tpl:28, lagom :25). (`pleasechoose` may itself be a real generic key, but `ssl.selectWebserver` is the one WHMCS uses here.)
8. **Theme-wide nav keys with no in-batch reference cite** (`securitysettings`, `clientareanavchangepassword`, `accountdetails`, `logout`, `nav_manage_ssl`, `domainssloptions`, `manageproduct`, `renew`, `clientareanavservices`, `changepassword`): used ONLY with `|default` in our tree and NOT found bare in nexus/lagom. They are standard documented WHMCS `$_LANG` keys, so classed **WHMCS (strip default)** at **med** confidence (no reference cite this batch). If a stricter reading is wanted, treat as CUSTOM. Per-string notes mark each.

---

### hadrian/templates/hadrian/core/pages/user-profile/default/default.tpl
| Line | Type | Current text | Class | Proposed reference | Evidence / Notes | Conf |
|------|------|--------------|-------|--------------------|------------------|------|
| 22 | text | Your Profile | WHMCS | {$LANG.yourprofile} | real key — strip default (WHMCS account nav) | med |
| 23 | text | Personal information attached to your sign-in account. | CUSTOM | {$hadrianLang.account.profileSub} | `userProfile.profileSub` invented (only w/ default); page subtitle | high |
| 30 | text | Your Profile | WHMCS | {$LANG.yourprofile} | dedupe w/ L22 | med |
| 33 | text | Your Profile | WHMCS | {$LANG.yourprofile} | dedupe | med |
| 37 | text | Switch Account | WHMCS | {$LANG.navSwitchAccount} | lagom user-switch-account.tpl:44 (`navSwitchAccount`); `switchaccount` invented | med |
| 41 | text | Change Password | WHMCS | {$LANG.clientareanavchangepassword} | std WHMCS nav key; strip default | med |
| 45 | text | Security Settings | WHMCS | {$LANG.securitysettings} | std WHMCS nav key; strip default | med |
| 63 | text | Personal information | WHMCS | {$LANG.userProfile.profile} | real — nexus user-profile.tpl:5, lagom :7 (bare) | high |
| 67 | text | First name | WHMCS | {$LANG.clientareafirstname} | real — nexus :12, lagom :17 | high |
| 71 | text | Last name | WHMCS | {$LANG.clientarealastname} | real — nexus :27 | high |
| 77 | text | Cancel | WHMCS | {$LANG.cancel} | real — nexus user-profile.tpl:41 (bare) | high |
| 78 | text | Save changes | WHMCS | {$LANG.clientareasavechanges} | real — nexus :40 | high |
| 89 | text | Change email address | WHMCS | {$LANG.userProfile.changeEmail} | real — nexus :49, lagom :56 | high |
| 92 | text | Not verified | WHMCS | {$LANG.userProfile.notVerified} | real — nexus :53 | high |
| 94 | text | Verified | WHMCS | {$LANG.userProfile.verified} | real — nexus :55 | high |
| 100 | text | Email address | WHMCS | {$LANG.clientareaemail} | real — nexus :64 | high |
| 102 | text | Used to sign in to your account. | CUSTOM | {$hadrianLang.account.emailUsedToSignIn} | `youremailisusedforsign` invented (only w/ default); help text | med |
| 106 | text | Existing password | WHMCS | {$LANG.existingpassword} | real — nexus :79 (bare) | high |
| 108 | text | Required to confirm an email address change. | CUSTOM | {$hadrianLang.account.existingPasswordRequired} | `userProfile.existingPasswordRequired` invented | high |
| 114 | text | Cancel | WHMCS | {$LANG.cancel} | dedupe | high |
| 115 | text | Save changes | WHMCS | {$LANG.clientareasavechanges} | dedupe | high |

### hadrian/templates/hadrian/core/pages/user-security/default/default.tpl
| Line | Type | Current text | Class | Proposed reference | Evidence / Notes | Conf |
|------|------|--------------|-------|--------------------|------------------|------|
| 44 | text | Security settings | WHMCS | {$LANG.securitysettings} | std WHMCS nav key; strip default | med |
| 45 | text | Two-factor authentication and account-security options. | CUSTOM | {$hadrianLang.account.securitySettingsSub} | `usersecuritysub` invented; page subtitle | high |
| 53 | text | Your Profile | WHMCS | {$LANG.yourprofile} | strip default | med |
| 56 | text | Account Details | WHMCS | {$LANG.accountdetails} | std WHMCS key; strip default | med |
| 60 | text | Change Password | WHMCS | {$LANG.clientareanavchangepassword} | strip default | med |
| 64 | text | Security Settings | WHMCS | {$LANG.securitysettings} | dedupe | med |
| 68 | text | Logout | WHMCS | {$LANG.logout} | std WHMCS key; strip default | med |
| 84 | text | Two-factor authentication | WHMCS | {$LANG.twofactorauth} | real — nexus user-security.tpl:72, lagom :18 | high |
| 85 | text | Require a second step to sign in to your account. | CUSTOM | {$hadrianLang.account.twoFactorSub} | `twofactorauthsub` invented; card sub | high |
| 97 | text | Two-factor authentication | WHMCS | {$LANG.twofactorauth} | dedupe | high |
| 98 | text | Enabled | WHMCS | {$LANG.enabled} | real — nexus :78, lagom :41 (`enabled`) | high |
| 98 | text | Disabled | WHMCS | {$LANG.disabled} | real — nexus :79, lagom :44 | high |
| 99 | text | Required | WHMCS | {$LANG.required} | std WHMCS key; strip default | med |
| 103 | text | Two-factor authentication is active. Sign-ins require both your password and a code… | CUSTOM | {$hadrianLang.account.twoFactorEnabledDesc} | `twofactorenableddesc` invented; long copy | high |
| 105 | text | Your administrator requires two-factor authentication on this account… | WHMCS | {$LANG.clientAreaSecurityTwoFactorAuthRequired} | real — nexus :82, lagom :47 | high |
| 107 | text | Add an extra layer of security. After your password, you will be asked for a one-time code… | WHMCS | {$LANG.clientAreaSecurityTwoFactorAuthRecommendation} | real — nexus :84, lagom :49 | high |
| 113 | value/title | Disable two-factor | WHMCS | {$LANG.twofadisable} | real — nexus :87, lagom :51 (used twice: `data-tfa-title` + button text) | high |
| 115 | value/title | Enable two-factor | WHMCS | {$LANG.twofaenable} | real — nexus :90, lagom :54 | high |
| 126 | text | Security question | WHMCS | {$LANG.clientareanavsecurityquestions} | real — nexus :24, lagom :24 | high |
| 127 | text | A backup verification step used when recovering your account. | CUSTOM | {$hadrianLang.account.securityQuestionSub} | `securityquestionsub` invented; card sub | high |
| 139 | text | Security question | WHMCS | {$LANG.clientareasecurityquestion} | real — nexus :35, lagom :69 | high |
| 148 | text | Answer | WHMCS | {$LANG.clientareasecurityanswer} | real — nexus :48, lagom :81 | high |
| 152 | text | Confirm answer | WHMCS | {$LANG.clientareasecurityconfanswer} | real — nexus :54, lagom :87 | high |
| 156 | text | Save changes | WHMCS | {$LANG.clientareasavechanges} | dedupe | high |
| 166 | text | Linked accounts | WHMCS | {$LANG.remoteAuthn.titleLinkedAccounts} | real — nexus :8, lagom :11 | high |
| 167 | text | Connect a third-party sign-in provider so you can log in with it. | CUSTOM | {$hadrianLang.account.linkedAccountsSub} | `remoteAuthn.mayHaveMultipleLinks` invented (only w/ default) | med |
| 181 | text | No additional security options available | CUSTOM | {$hadrianLang.account.securityNoOptionsTitle} | `securitynooptionstitle` invented; empty state | high |
| 182 | text | Your administrator has not enabled any additional sign-in security features… | CUSTOM | {$hadrianLang.account.securityNoOptionsSub} | `securitynooptionssub` invented; empty state | high |
| 183 | text | Contact support | WHMCS | {$LANG.contactus} | `contactsupport` invented; real key `contactus` (nexus footer.tpl:37) | high |
| 211 | js-string | Close | WHMCS | {$LANG.close} | aria-label in JS-built modal; `close` is std WHMCS key. Seed from Smarty | med |
| 297 | js-string | Something went wrong — please try again. | CUSTOM | {$hadrianLang.account.tfaModalError} | hardcoded JS error string | med |

### hadrian/templates/hadrian/core/pages/user-password/default/default.tpl
| Line | Type | Current text | Class | Proposed reference | Evidence / Notes | Conf |
|------|------|--------------|-------|--------------------|------------------|------|
| 13 | text | Change password | WHMCS | {$LANG.clientareanavchangepassword} | std WHMCS nav key; strip default | med |
| 14 | text | Pick a strong new password — minimum 8 characters with mixed case and numbers. | CUSTOM | {$hadrianLang.account.changePasswordSub} | `changepasswordsub` invented; page subtitle | high |
| 22 | text | Your Profile | WHMCS | {$LANG.yourprofile} | strip default | med |
| 25 | text | Account Details | WHMCS | {$LANG.accountdetails} | strip default | med |
| 29 | text | Change Password | WHMCS | {$LANG.clientareanavchangepassword} | dedupe | med |
| 33 | text | Security Settings | WHMCS | {$LANG.securitysettings} | strip default | med |
| 44 | text | Password updated successfully. | WHMCS | {$LANG.changessavedsuccessfully} | std WHMCS key ("Changes Saved Successfully!"); strip default | med |
| 59 | text | Current password | WHMCS | {$LANG.currentpassword} | std WHMCS key; strip default | med |
| 64 | text | New password | WHMCS | {$LANG.newpassword} | real — nexus user-password.tpl:16, lagom :16 | high |
| 68 | text | Password strength | WHMCS | {$LANG.pwstrength} | real — nexus password-reset-change-prompt.tpl:18, lagom viewcart.tpl:83 (bare) | high |
| 73 | text | Confirm new password | WHMCS | {$LANG.confirmnewpassword} | real — nexus :28, lagom :24 | high |
| 79 | text | Cancel | WHMCS | {$LANG.cancel} | real — nexus :35; lagom user-password uses `clientareacancel` :31 | high |
| 80 | text | Change password | WHMCS | {$LANG.clientareanavchangepassword} | `changepassword` also a std key; reuse nav key for dedupe. strip default | med |
| 113 | js-string | Too weak / Weak / Fair / Good / Strong | CUSTOM | {$hadrianLang.account.pwStrength{VeryWeak…Strong}} | JS strength labels; WHMCS has `pwstrengthweak/moderate/strong` but set differs (5 levels). Seed from Smarty | med |
| 127 | js-string | Passwords match | CUSTOM | {$hadrianLang.account.passwordsMatch} | JS match message | high |
| 131 | js-string | Passwords do not match | CUSTOM | {$hadrianLang.account.passwordsNoMatch} | JS mismatch message | high |

### hadrian/templates/hadrian/core/pages/user-invite-accept/default/default.tpl
| Line | Type | Current text | Class | Proposed reference | Evidence / Notes | Conf |
|------|------|--------------|-------|--------------------|------------------|------|
| 24 | text | You're invited to access | WHMCS | {$LANG.accountInvite.youHaveBeenInvited} | `accountinvite_youhavebeen` invented; real dotted key takes `clientName` param — nexus :18, lagom :28 | high |
| 26 | text | has invited you to manage their account. | WHMCS | {$LANG.accountInvite.givenAccess} | `accountinvite_givenaccess` invented; real key takes senderName/clientName — nexus :23, lagom :36 | high |
| 35 | text | You are signed in — accept to add this account to your switcher. | WHMCS | {$LANG.accountInvite.inviteAcceptLoggedIn} | `accountinvite_inviteacceptloggedin` invented — nexus :26, lagom :38 | high |
| 38 | text | Accept invitation | WHMCS | {$LANG.accountInvite.accept} | `accountinvite_accept` invented — nexus :35, lagom :47 | high |
| 39 | text | Cancel | WHMCS | {$LANG.cancel} | std key | high |
| 42 | text | Sign in or create an account to accept the invitation. | WHMCS | {$LANG.accountInvite.inviteAcceptLoggedOut} | `accountinvite_inviteacceptloggedout` invented — nexus :28, lagom :40 | high |
| 47 | text | Sign in | WHMCS | {$LANG.login} | `signin` invented; real key `login` — nexus :43,56 | high |
| 51 | text | Email address | WHMCS | {$LANG.loginemail} | real — nexus :46, lagom :61 | high |
| 55 | text | Password | WHMCS | {$LANG.loginpassword} | real — nexus :50, lagom :66 | high |
| 61 | text | Sign in | WHMCS | {$LANG.login} | dedupe (button) | high |
| 67 | text | Create account | WHMCS | {$LANG.orderForm.createAccount} | `createaccount` invented; real `orderForm.createAccount` ("Create Account") standard_cart/checkout.tpl:36; or `register` (nexus :64) | high |
| 72 | text | First name | WHMCS | {$LANG.clientareafirstname} | real — nexus :67 | high |
| 76 | text | Last name | WHMCS | {$LANG.clientarealastname} | real — nexus :72 | high |
| 81 | text | Email address | WHMCS | {$LANG.loginemail} | dedupe — nexus :75 | high |
| 85 | text | Password | WHMCS | {$LANG.loginpassword} | dedupe — nexus :79 | high |
| 90 | text | Generate password | WHMCS | {$LANG.generatePassword.btnLabel} | real — nexus user-password.tpl:23, clientregister.tpl:253 | high |
| 92 | aria-label | Show or hide password | CUSTOM | {$hadrianLang.account.togglePasswordVisibility} | `togglepasswordvisibility` invented (only w/ default) | med |
| 104 | text | I have read and agree to the | WHMCS | {$LANG.ordertosagreement} | real — nexus :102, lagom :115 | high |
| 104 | text | Terms of Service | WHMCS | {$LANG.ordertos} | real — nexus :103, lagom :116 | high |
| 112 | text | Create account | WHMCS | {$LANG.orderForm.createAccount} | dedupe (button) | high |
| 120 | text | Invitation not found | WHMCS | {$LANG.accountInvite.notFound} | `accountinvite_invalid` invented; real — nexus :121, lagom :136 | high |
| 121 | text | This invitation link is no longer valid or has already been used. | CUSTOM | {$hadrianLang.account.inviteInvalidSub} | nexus/lagom use `accountInvite.contactAdministrator` (different wording); our copy is custom — rebadge | med |
| 122 | text | Continue to client area | WHMCS | {$LANG.orderForm.continueToClientArea} | `continuetoclientarea` invented; real — nexus user-verify-email.tpl:33 | high |
| 152 | js-string | Very weak / Weak / Fair / Good / Strong | CUSTOM | {$hadrianLang.account.pwStrength{VeryWeak…Strong}} | JS strength labels; dedupe w/ user-password set. Seed from Smarty | med |

### hadrian/templates/hadrian/core/pages/user-switch-account/default/default.tpl
| Line | Type | Current text | Class | Proposed reference | Evidence / Notes | Conf |
|------|------|--------------|-------|--------------------|------------------|------|
| 29 | text | Switch account | WHMCS | {$LANG.navSwitchAccount} | `switchaccount` invented; real `navSwitchAccount` (lagom user-switch-account.tpl:44) | med |
| 30 | text | Pick the account you want to manage. | WHMCS | {$LANG.switchAccount.choose} | real — nexus user-switch-account.tpl:15, lagom :17 | high |
| 59 | text | Owner | WHMCS | {$LANG.clientOwner} | real — nexus :22, lagom :34 | high |
| 68 | text | Switch to | WHMCS | {$LANG.navSwitchAccount} | `switchAccount.switchTo` invented; real `navSwitchAccount` (lagom :44) | med |
| 78 | text | No accounts to switch to | WHMCS | {$LANG.switchAccount.noneFound} | real — nexus :6, lagom :6 | high |
| 79 | text | You only have access to a single client account at the moment… | WHMCS | {$LANG.switchAccount.createInstructions} | real — nexus :7, lagom :7 (wording differs but it's the real key) | high |
| 80 | text | Continue to client area | WHMCS | {$LANG.orderForm.continueToClientArea} | `continuetoclientarea` invented; real key. (nexus uses `shopNow` here, but our CTA text = continue) | high |
| 87 | text | Your Profile | WHMCS | {$LANG.yourprofile} | strip default | med |
| 90 | text | Your Profile | WHMCS | {$LANG.yourprofile} | dedupe | med |
| 94 | text | Switch Account | WHMCS | {$LANG.navSwitchAccount} | dedupe | med |
| 98 | text | Change Password | WHMCS | {$LANG.clientareanavchangepassword} | strip default | med |
| 102 | text | Security Settings | WHMCS | {$LANG.securitysettings} | strip default | med |

### hadrian/templates/hadrian/core/pages/user-verify-email/default/default.tpl
| Line | Type | Current text | Class | Proposed reference | Evidence / Notes | Conf |
|------|------|--------------|-------|--------------------|------------------|------|
| 17 | text | Email verified | WHMCS | {$LANG.emailVerification.success} | `emailverification_success` invented; real — nexus user-verify-email.tpl:6, lagom :9 | high |
| 18 | text | Your email address is confirmed. You're all set. | CUSTOM | {$hadrianLang.account.emailVerifiedSub} | no WHMCS sub-text key (nexus shows only the title) | high |
| 23 | text | Verification link expired | WHMCS | {$LANG.emailVerification.expired} | `emailverification_expired` invented; real — nexus :10, lagom :17 | high |
| 24 | text | This verification link is no longer valid. Sign in to request a fresh one. | WHMCS | {$LANG.emailVerification.loginToRequest} | `emailverification_expired_sub` invented; real key — nexus :19, lagom :23 (close wording) | med |
| 27 | text | Resend verification email | WHMCS | {$LANG.resendEmail} | `resendemail` invented; real `resendEmail` — nexus :16, lagom :21 | high |
| 34 | text | Verification link not found | WHMCS | {$LANG.emailVerification.notFound} | `emailverification_notfound` invented; real — nexus :24, lagom :32 | high |
| 35 | text | We couldn't find this verification request… | CUSTOM | {$hadrianLang.account.emailNotFoundSub} | no WHMCS sub-text key for this | high |
| 39 | text | Continue to client area | WHMCS | {$LANG.orderForm.continueToClientArea} | `continuetoclientarea` invented; real — nexus :33, lagom :11 | high |

### hadrian/templates/hadrian/core/pages/affiliates/default/default.tpl
| Line | Type | Current text | Class | Proposed reference | Evidence / Notes | Conf |
|------|------|--------------|-------|--------------------|------------------|------|
| 76 | text | Affiliates | WHMCS | {$LANG.affiliatestitle} | std WHMCS key; strip default | med |
| 77 | text | Earn commission for every customer you refer to Hostnodes. Track your clicks… | CUSTOM | {$hadrianLang.account.affiliatesSub} | `affiliatessub` invented; page subtitle | high |
| 86 | text | The affiliate program is currently unavailable | WHMCS | {$LANG.affiliatesdisabled} | real — nexus affiliates.tpl:3, lagom :5 | high |
| 87 | text | Please check back later or contact support if you believe this is an error. | CUSTOM | {$hadrianLang.account.affiliatesDisabledSub} | `affiliatesdisabledsub` invented (no WHMCS sub) | high |
| 99 | text | Your withdrawal request has been submitted successfully. | WHMCS | {$LANG.affiliateswithdrawalrequestsuccessful} | real — nexus :10 | high |
| 110 | text | Visitors referred | WHMCS | {$LANG.affiliatesclicks} | `affiliatesvisitors` invented; real key `affiliatesclicks` — nexus :20, lagom :17 | high |
| 117 | text | Signups | WHMCS | {$LANG.affiliatessignups} | real — nexus :28, lagom :26 | high |
| 124 | text | Conversion rate | WHMCS | {$LANG.affiliatesconversionrate} | real — nexus :36, lagom :35 | high |
| 131 | text | Available balance | WHMCS | {$LANG.affiliatesbalance} | std WHMCS key; strip default | med |
| 138 | text | Your referral link | WHMCS | {$LANG.affiliatesreferallink} | real — nexus :45, lagom :45 | high |
| 139 | text | Share this link anywhere. When someone signs up through it… | WHMCS | {$LANG.affiliateslinktousexplanation} | std WHMCS key (`affiliateslinktousexplanation`); strip default | med |
| 145 | text | Copy | WHMCS | {$LANG.copy} | std WHMCS key; strip default | med |
| 153 | text | Commissions | WHMCS | {$LANG.affiliatescommissions} | std WHMCS key; strip default | med |
| 158 | text | Pending | WHMCS | {$LANG.affiliatescommissionspending} | real — nexus :55 | high |
| 163 | text | Available | WHMCS | {$LANG.affiliatescommissionsavailable} | real — nexus :59 | high |
| 167 | text | Withdrawn | WHMCS | {$LANG.affiliateswithdrawn} | real — nexus :63 | high |
| 179 | text | Request withdrawal | WHMCS | {$LANG.affiliatesrequestwithdrawal} | real — nexus :75 | high |
| 189 | text | Referrals | WHMCS | {$LANG.affiliatesreferals} | real — nexus :84, lagom :52 | high |
| 197 | text | No referrals yet | CUSTOM | {$hadrianLang.account.affiliatesNoReferrals} | `affiliatesnoreferrals` invented; empty state (refs use `norecordsfound`) | med |
| 198 | text | Share your referral link above to start earning commission… | CUSTOM | {$hadrianLang.account.affiliatesNoReferralsSub} | `affiliatesnoreferralssub` invented; empty state | high |
| 207 | text | Date | WHMCS | {$LANG.affiliatessignupdate} | real — nexus :108, lagom :103 | high |
| 208 | text | Product | WHMCS | {$LANG.orderproduct} | real — nexus :109, lagom :104 | high |
| 209 | text | Amount | WHMCS | {$LANG.affiliatesamount} | real — nexus :110, lagom :105 | high |
| 210 | text | Commission | WHMCS | {$LANG.affiliatescommission} | real — nexus :111, lagom :106 | high |
| 211 | text | Status | WHMCS | {$LANG.affiliatesstatus} | real — nexus :112, lagom :107 | high |
| 238 | text | Banners & links | WHMCS | {$LANG.affiliateslinktous} | real — nexus :133, lagom :139 | high |
| 239 | text | Paste one of these snippets on your site to link back… | WHMCS | {$LANG.affiliateslinktoussub} | std WHMCS key (`affiliateslinktoussub`); strip default | med |
| 255 | js-string | Copied | CUSTOM | {$hadrianLang.common.copied} | JS feedback after copy; reuse common.copied | high |

### hadrian/templates/hadrian/core/pages/affiliatessignup/default/default.tpl
| Line | Type | Current text | Class | Proposed reference | Evidence / Notes | Conf |
|------|------|--------------|-------|--------------------|------------------|------|
| 22 | text | Affiliates | WHMCS | {$LANG.affiliatestitle} | dedupe; strip default | med |
| 23 | text | Earn commission for every customer you refer to Hostnodes. | CUSTOM | {$hadrianLang.account.affiliatesSub} | `affiliatessub` invented; dedupe w/ affiliates page (shorter variant — note divergence) | high |
| 31 | text | Become a Hostnodes affiliate | WHMCS | {$LANG.affiliatesignuptitle} | real — nexus affiliatessignup.tpl:6, lagom :9 (contains brand "Hostnodes"; WHMCS string is generic) | high |
| 32 | text | Join the affiliate program and earn commission… one click to activate. | WHMCS | {$LANG.affiliatesignupintro} | real — nexus :7, lagom :10 | high |
| 37 | text | Earn commission on every referred sale | WHMCS | {$LANG.affiliatesignupinfo1} | real — nexus :10 | high |
| 41 | text | Track your clicks, signups and conversion rate in real time | WHMCS | {$LANG.affiliatesignupinfo2} | real — nexus :11 | high |
| 45 | text | Request a payout once you reach the minimum balance | WHMCS | {$LANG.affiliatesignupinfo3} | real — nexus :12 | high |
| 51 | text | Activate affiliate account | WHMCS | {$LANG.affiliatesactivate} | real — nexus :21, lagom :14 | high |
| 60 | text | The affiliate program is currently unavailable | WHMCS | {$LANG.affiliatesdisabled} | dedupe; real — nexus :29 | high |
| 61 | text | Please check back later or contact support if you believe this is an error. | CUSTOM | {$hadrianLang.account.affiliatesDisabledSub} | dedupe w/ affiliates page | high |

### hadrian/templates/hadrian/core/pages/clientareasecurity/default/default.tpl
| Line | Type | Current text | Class | Proposed reference | Evidence / Notes | Conf |
|------|------|--------------|-------|--------------------|------------------|------|
| 39 | text | Security settings | WHMCS | {$LANG.securitysettings} | strip default | med |
| 40 | text | Single sign-on and connected third-party accounts for your login. | CUSTOM | {$hadrianLang.account.securitySettingsSsoSub} | `securitysettingssub` invented; page subtitle | high |
| 48 | text | Your Profile | WHMCS | {$LANG.yourprofile} | strip default | med |
| 51 | text | Account Details | WHMCS | {$LANG.accountdetails} | strip default | med |
| 55 | text | Change Password | WHMCS | {$LANG.clientareanavchangepassword} | strip default | med |
| 59 | text | Security Settings | WHMCS | {$LANG.securitysettings} | dedupe | med |
| 63 | text | Logout | WHMCS | {$LANG.logout} | strip default | med |
| 75 | text | Single Sign-On | WHMCS | {$LANG.sso.title} | std WHMCS `sso.title`; strip default | med |
| 76 | text | Move between connected areas without signing in again. | CUSTOM | {$hadrianLang.account.ssoSummary} | `sso.summary` invented (only w/ default) | med |
| 85 | text | Single Sign-On | WHMCS | {$LANG.sso.title} | dedupe | med |
| 86 | text | You can turn this off at any time. | CUSTOM | {$hadrianLang.account.ssoDisableNotice} | `sso.disablenotice` invented | med |
| 88 | aria-label | Single Sign-On | WHMCS | {$LANG.sso.title} | dedupe (aria-label) | med |
| 101 | text | Linked accounts | WHMCS | {$LANG.remoteAuthn.titleLinkedAccounts} | real — nexus user-security.tpl:8 | high |
| 102 | text | Connect a third-party sign-in provider so you can log in with it. | CUSTOM | {$hadrianLang.account.linkedAccountsSub} | dedupe w/ user-security; `remoteAuthn.mayHaveMultipleLinks` invented | med |
| 116 | text | No additional security options available | CUSTOM | {$hadrianLang.account.securityNoOptionsTitle} | dedupe w/ user-security | high |
| 117 | text | Your administrator has not enabled any additional sign-in security features… | CUSTOM | {$hadrianLang.account.securityNoOptionsSsoSub} | `securitynooptionssub` invented (this variant mentions SSO/linked — differs from user-security copy) | high |
| 118 | text | Contact support | WHMCS | {$LANG.contactus} | `contactsupport` invented; real `contactus` | high |

### hadrian/templates/hadrian/core/pages/managessl/default/default.tpl
| Line | Type | Current text | Class | Proposed reference | Evidence / Notes | Conf |
|------|------|--------------|-------|--------------------|------------------|------|
| 51 | text | SSL Certificates | WHMCS | {$LANG.domainssloptions} | std WHMCS key ("SSL Certificate Options"); strip default | med |
| 52 | text | Manage SSL | WHMCS | {$LANG.nav_manage_ssl} | std WHMCS nav key; strip default | med |
| 53 | text | View status, configure, or renew the certificates on your account. | CUSTOM | {$hadrianLang.ssl.manageIntro} | `sslmanageintro` invented; page subtitle | high |
| 55 | text | Order new certificate | CUSTOM | {$hadrianLang.ssl.orderNew} | `sslordernew` invented (no WHMCS key for this CTA) | med |
| 66 | text | Domain | WHMCS | {$LANG.ssldomain} | real — nexus managessl.tpl:9, lagom :? (bare) | high |
| 67 | text | Certificate | WHMCS | {$LANG.sslproduct} | real — nexus :10 | high |
| 68 | text | Status | WHMCS | {$LANG.invoicesstatus} | real — nexus clientareainvoices.tpl:33 (nexus managessl uses `actions`/`sslorderdate` for these cols; `invoicesstatus` is the real "Status" key) | med |
| 69 | text | Renews | WHMCS | {$LANG.sslrenewaldate} | real — nexus :12 | high |
| 82 | text | Configure | WHMCS | {$LANG.sslconfigure} | real — nexus :47 | high |
| 83 | text | Renew | WHMCS | {$LANG.renew} | std WHMCS key; strip default (nexus uses `upgrade` for renew button) | med |
| 84 | text | Manage | WHMCS | {$LANG.manageproduct} | std WHMCS key; strip default | med |
| 127 | text | Awaiting configuration | WHMCS | {$LANG.sslawaitingconfig} | real — nexus :22 | high |
| 132 | text | Awaiting config | WHMCS | {$LANG.sslawaitingconfig} | dedupe — nexus :22 | high |
| 133 | text | Awaiting issuance | WHMCS | {$LANG.sslawaitingissuance} | std WHMCS key; strip default | med |
| 134 | text | Expired | WHMCS | {$LANG.clientareaexpired} | real — nexus :26, lagom :30 | high |
| 135 | text | Expiring soon | WHMCS | {$LANG.expiringsoon} | real — nexus :28 | high |
| 136 | text | Active | WHMCS | {$LANG.clientareaactive} | real — lagom clientareahome.tpl:176 (bare) | high |
| 144 | text | Renew | WHMCS | {$LANG.upgrade} | button uses upgrade flow; nexus :52 uses `upgrade` (label "Upgrade/Renew"). Our default 'Renew' diverges — real key `upgrade` | med |
| 147 | text | Manage | WHMCS | {$LANG.manageproduct} | dedupe | med |
| 166 | text | No certificates yet | CUSTOM | {$hadrianLang.ssl.noCertificates} | `sslnocertificates` invented; empty state | high |
| 167 | text | Once you order an SSL certificate it'll show up here for management. | CUSTOM | {$hadrianLang.ssl.noCertificatesSub} | `sslnocertificatessub` invented | high |
| 168 | text | Browse SSL | CUSTOM | {$hadrianLang.ssl.browse} | `sslordernew` invented; different text from L55 (note: same key, two literals — pick one) | med |

### hadrian/templates/hadrian/core/pages/configuressl-stepone/default/default.tpl
| Line | Type | Current text | Class | Proposed reference | Evidence / Notes | Conf |
|------|------|--------------|-------|--------------------|------------------|------|
| 46 | text | SSL Certificate | WHMCS | {$LANG.domainssloptions} | std WHMCS key; strip default | med |
| 47 | text | Configure your SSL certificate | CUSTOM | {$hadrianLang.ssl.configureTitle} | `configssl` invented; refs have no page-title here | med |
| 48 | text | Provide your server type and certificate signing request… | CUSTOM | {$hadrianLang.ssl.configIntro} | `sslconfigintro` invented; page subtitle | high |
| 55 | text | Configuration | CUSTOM | {$hadrianLang.ssl.stepConfig} | `sslstepconfig` invented; wizard stepper label (refs have no stepper) | high |
| 60 | text | Validation | CUSTOM | {$hadrianLang.ssl.stepValidate} | `sslstepvalidate` invented; stepper | high |
| 65 | text | Complete | CUSTOM | {$hadrianLang.ssl.stepComplete} | `sslstepcomplete` invented; stepper | high |
| 82 | text | Server configuration | WHMCS | {$LANG.sslserverinfo} | real — nexus configuressl-stepone.tpl:21, lagom :17 | high |
| 86 | text | Select the software running on your server and paste the certificate signing request (CSR)… | WHMCS | {$LANG.sslserverinfodetails} | real — nexus :23, lagom :21 | high |
| 89 | text | Server type | WHMCS | {$LANG.sslservertype} | real — nexus :26, lagom :23 | high |
| 91 | option | Please choose... | WHMCS | {$LANG.ssl.selectWebserver} | `pleasechoose` — WHMCS uses `ssl.selectWebserver` for this option (nexus :28, lagom :25) | med |
| 98 | text | Certificate signing request (CSR) | WHMCS | {$LANG.sslcsr} | real — nexus :38, lagom :34 | high |
| 99 | placeholder | -----BEGIN CERTIFICATE REQUEST----- | SKIP | — | not translatable (PEM marker literal) | high |
| 102 | text | {$heading} | SKIP | — | dynamic var (additional-fields heading) | high |
| 115 | text | Administrative contact | WHMCS | {$LANG.ssladmininfo} | real — nexus :61, lagom :58 | high |
| 119 | text | This contact appears on the certificate and receives validation emails. | WHMCS | {$LANG.ssladmininfodetails} | real — nexus :63, lagom :62 | high |
| 123 | text | First name | WHMCS | {$LANG.clientareafirstname} | real — nexus :67 | high |
| 128 | text | Last name | WHMCS | {$LANG.clientarealastname} | real — nexus :74 | high |
| 131 | text | Organization | WHMCS | {$LANG.organizationname} | real — nexus :81, lagom :77 | high |
| 135 | text | Job title | WHMCS | {$LANG.jobtitle} | real — nexus :88, lagom :83 | high |
| 139 | text | Email address | WHMCS | {$LANG.clientareaemail} | real — nexus :96 | high |
| 143 | text | Phone number | WHMCS | {$LANG.clientareaphonenumber} | real — nexus :149, lagom :136 | high |
| 147 | text | Address line 1 | WHMCS | {$LANG.clientareaaddress1} | real — nexus :103 | high |
| 151 | text | Address line 2 | WHMCS | {$LANG.clientareaaddress2} | real — nexus :110 | high |
| 155 | text | City | WHMCS | {$LANG.clientareacity} | real — nexus :117 | high |
| 159 | text | State / region | WHMCS | {$LANG.clientareastate} | real — nexus :124 | high |
| 163 | text | Postcode | WHMCS | {$LANG.clientareapostcode} | real — nexus :131 | high |
| 167 | text | Country | WHMCS | {$LANG.clientareacountry} | real — nexus :138 | high |
| 177 | text | Continue | WHMCS | {$LANG.continue} | real — lagom configuressl-stepone.tpl:147; nexus uses `ordercontinuebutton` | high |
| 178 | text | Cancel | WHMCS | {$LANG.cancel} | std key | high |
| 193 | text | This certificate cannot be configured right now | WHMCS | {$LANG.sslnoconfigurationpossible} | `sslnoconfigurationpossible` real — nexus :164, lagom :151 (our default text differs but it's the real key) | med |
| 194 | text | Its current status does not allow configuration. Open the service to review its state. | CUSTOM | {$hadrianLang.ssl.noConfigPossibleSub} | `sslnoconfigpossiblesub` invented | high |
| 195 | text | My services | WHMCS | {$LANG.clientareanavservices} | std WHMCS nav key; strip default | med |
| 197 | text | No SSL certificate to configure | WHMCS | {$LANG.sslinvalidlink} | `sslinvalidlink` real — nexus :4, lagom :5 (our wording differs; real key) | med |
| 198 | text | This configuration link is invalid or has expired. Open the service to start again. | CUSTOM | {$hadrianLang.ssl.invalidLinkSub} | `sslinvalidlinksub` invented | high |
| 199 | text | My services | WHMCS | {$LANG.clientareanavservices} | dedupe | med |

### hadrian/templates/hadrian/core/pages/configuressl-steptwo/default/default.tpl
| Line | Type | Current text | Class | Proposed reference | Evidence / Notes | Conf |
|------|------|--------------|-------|--------------------|------------------|------|
| 44 | text | SSL Certificate | WHMCS | {$LANG.domainssloptions} | strip default | med |
| 45 | text | Verify domain ownership | CUSTOM | {$hadrianLang.ssl.verifyTitle} | `sslselectvalidation` here renders a page title; refs use `ssl.selectValidation` only as card title. Our title text "Verify domain ownership" is custom | med |
| 46 | text | Choose how you want to prove control of the domain… | CUSTOM | {$hadrianLang.ssl.validationIntro} | `sslvalidationintro` invented; page subtitle | high |
| 52 | text | Configuration | CUSTOM | {$hadrianLang.ssl.stepConfig} | dedupe (stepper) | high |
| 57 | text | Validation | CUSTOM | {$hadrianLang.ssl.stepValidate} | dedupe | high |
| 62 | text | Complete | CUSTOM | {$hadrianLang.ssl.stepComplete} | dedupe | high |
| 77 | text | Domain validation method | WHMCS | {$LANG.ssl.selectValidation} | `sslselectvalidation` invented; real `ssl.selectValidation` — nexus :11, lagom :14 | high |
| 86 | text | Email validation | WHMCS | {$LANG.ssl.emailMethod} | `sslemailmethod` invented; real — nexus :15, lagom :22 | high |
| 87 | text | A validation link is emailed to an approved address on the domain. | WHMCS | {$LANG.ssl.emailMethodDescription} | `sslemailmethoddesc` invented; real — nexus :33, lagom :40 | high |
| 89 | text | DNS (TXT record) | WHMCS | {$LANG.ssl.dnsMethod} | `ssldnsmethod` invented; real — nexus :20, lagom :28 | high |
| 90 | text | Add a TXT record to your domain DNS to prove control. | WHMCS | {$LANG.ssl.dnsMethodDescription} | `ssldnsmethoddesc` invented; real — nexus :52, lagom :54 | high |
| 92 | text | HTTP file upload | WHMCS | {$LANG.ssl.fileMethod} | `sslfilemethod` invented; real — nexus :27, lagom :34 | high |
| 93 | text | Upload a verification file to your web server root. | WHMCS | {$LANG.ssl.fileMethodDescription} | `sslfilemethoddesc` invented; real — nexus :55, lagom :57 | high |
| 104 | text | Email validation | WHMCS | {$LANG.ssl.emailMethod} | dedupe (no-methods fallback) | high |
| 105 | text | A validation link is emailed to an approved address on the domain. | WHMCS | {$LANG.ssl.emailMethodDescription} | dedupe | high |
| 113 | text | Select the address to receive the validation email | WHMCS | {$LANG.ssl.selectEmail} | `sslselectemail` invented; real — nexus :34, lagom :41 | high |
| 124 | text | Continue | WHMCS | {$LANG.continue} | real — lagom :65 | high |
| 125 | text | Cancel | WHMCS | {$LANG.cancel} | std key | high |
| 139 | text | Configuration not complete | CUSTOM | {$hadrianLang.ssl.step1Incomplete} | `sslstep1incomplete` invented; empty state | high |
| 140 | text | Finish the certificate configuration step before choosing a validation method. | CUSTOM | {$hadrianLang.ssl.step1IncompleteSub} | `sslstep1incompletesub` invented | high |
| 141 | text | Back to configuration | WHMCS | {$LANG.back} | `back` real — lagom configuressl-stepone.tpl:7 (our wording adds "to configuration"; real key is `back`) | med |

### hadrian/templates/hadrian/core/pages/configuressl-complete/default/default.tpl
| Line | Type | Current text | Class | Proposed reference | Evidence / Notes | Conf |
|------|------|--------------|-------|--------------------|------------------|------|
| 40 | text | SSL Certificate | WHMCS | {$LANG.domainssloptions} | strip default | med |
| 41 | text | Certificate request submitted | CUSTOM | {$hadrianLang.ssl.requestSubmittedTitle} | `sslconfigured` invented; page title (refs have no title here) | med |
| 42 | text | Complete the validation step below so the certificate authority can issue your certificate. | CUSTOM | {$hadrianLang.ssl.completeIntro} | `sslcompleteintro` invented; page subtitle | high |
| 48 | text | Configuration | CUSTOM | {$hadrianLang.ssl.stepConfig} | dedupe (stepper) | high |
| 53 | text | Validation | CUSTOM | {$hadrianLang.ssl.stepValidate} | dedupe | high |
| 58 | text | Complete | CUSTOM | {$hadrianLang.ssl.stepComplete} | dedupe | high |
| 69 | text | Configuration complete | WHMCS | {$LANG.sslconfigcomplete} | real — nexus configuressl-complete.tpl:9, lagom :8 | high |
| 70 | text | Your certificate request for | CUSTOM | {$hadrianLang.ssl.completedForPrefix} | `sslcompletedfor` invented; sentence fragment around {$domain} | med |
| 70 | text | has been submitted. | CUSTOM | {$hadrianLang.ssl.completedForSuffix} | `sslcompletedissued` invented; sentence fragment | med |
| 70 | text | Your certificate request has been submitted. | CUSTOM | {$hadrianLang.ssl.completedGeneric} | `sslcompletegeneric` invented (no-domain variant) | med |
| 77 | text | Email validation | WHMCS | {$LANG.ssl.emailInformation} | `sslemailinformation` invented; real `ssl.emailInformation` — nexus :18, lagom :15 | high |
| 81 | text | A validation email has been sent. Click the link inside to approve issuance. | WHMCS | {$LANG.ssl.emailSteps} | `sslemailsteps` invented; real — nexus :14, lagom :19 | high |
| 84 | text | Email | WHMCS | {$LANG.email} | real — nexus :18, lagom :22 | high |
| 91 | text | DNS record validation | WHMCS | {$LANG.ssl.dnsRecordInformation} | `ssldnsrecordinformation` invented; real — nexus :26, lagom :35 | high |
| 95 | text | Add the following record to your domain DNS. Issuance completes automatically once it propagates. | WHMCS | {$LANG.ssl.dnsSteps} | `ssldnssteps` invented; real — nexus :25, lagom :39 | high |
| 98 | text | Type | WHMCS | {$LANG.ssl.type} | `ssltype` invented; real — nexus :28, lagom :42 | high |
| 102 | text | Host | WHMCS | {$LANG.ssl.host} | `sslhost` invented; real — nexus :34, lagom :48 | high |
| 105 | title | Copy | WHMCS | {$LANG.copy} | std key; strip default | med |
| 109 | text | Value | WHMCS | {$LANG.ssl.value} | `sslvalue` invented; real — nexus :47, lagom :61 | high |
| 112 | title | Copy | WHMCS | {$LANG.copy} | dedupe | med |
| 119 | text | File validation | WHMCS | {$LANG.ssl.fileInformation} | `sslfileinformation` invented; real — nexus :61, lagom :80 | high |
| 123 | text | Upload a file with the contents below to the URL shown on your web server. | WHMCS | {$LANG.ssl.fileSteps} | `sslfilesteps` invented; real — nexus :60, lagom :84 | high |
| 126 | text | File URL | WHMCS | {$LANG.ssl.url} | `sslurl` invented; real `ssl.url` — nexus :63, lagom :87 | high |
| 129 | title | Copy | WHMCS | {$LANG.copy} | dedupe | med |
| 133 | text | File contents | WHMCS | {$LANG.ssl.value} | `sslvalue` invented; real `ssl.value` (refs label file-contents row with `ssl.value`) — nexus :70, lagom :95 | high |
| 136 | title | Copy | WHMCS | {$LANG.copy} | dedupe | med |
| 144 | text | DNS record validation | WHMCS | {$LANG.ssl.dnsRecordInformation} | dedupe (demo block) | high |
| 148 | text | Add the following record to your domain DNS… | WHMCS | {$LANG.ssl.dnsSteps} | dedupe | high |
| 151 | text | Type | WHMCS | {$LANG.ssl.type} | dedupe | high |
| 152 | text | CNAME | SKIP | — | demo data literal (DNS record type value) | high |
| 153 | text | _acme-challenge.hendersondesign.com | SKIP | — | demo data literal | high |
| 154 | text | a1b2c3d4e5f6.dcv.digicert.com | SKIP | — | demo data literal | high |
| 152 | text | Host | WHMCS | {$LANG.ssl.host} | dedupe (dt label, L152 col) | high |
| 153 | text | Value | WHMCS | {$LANG.ssl.value} | dedupe (dt label) | high |
| 160 | text | View my services | WHMCS | {$LANG.clientareanavservices} | std WHMCS nav key; strip default | med |
| 161 | text | Contact support | WHMCS | {$LANG.contactus} | real — nexus footer.tpl:37, lagom user-invite.tpl:138 (`contactus`); our key `contactus` already correct, strip default | high |
| 173 | text | Configuration could not be completed | CUSTOM | {$hadrianLang.ssl.configFailed} | `sslconfigfailed` invented; error state | high |
| 174 | text | Something went wrong while submitting your certificate request. Try again or contact support. | CUSTOM | {$hadrianLang.ssl.configFailedSub} | `sslconfigfailedsub` invented | high |
| 175 | text | Try again | WHMCS | {$LANG.tryagain} | std WHMCS key; strip default | med |

---

## Proposed custom keys
```
hadrianLang.common.copied = "Copied"

hadrianLang.account.profileSub = "Personal information attached to your sign-in account."
hadrianLang.account.emailUsedToSignIn = "Used to sign in to your account."
hadrianLang.account.existingPasswordRequired = "Required to confirm an email address change."
hadrianLang.account.securitySettingsSub = "Two-factor authentication and account-security options."
hadrianLang.account.twoFactorSub = "Require a second step to sign in to your account."
hadrianLang.account.twoFactorEnabledDesc = "Two-factor authentication is active. Sign-ins require both your password and a code from your second factor."
hadrianLang.account.securityQuestionSub = "A backup verification step used when recovering your account."
hadrianLang.account.linkedAccountsSub = "Connect a third-party sign-in provider so you can log in with it."
hadrianLang.account.securityNoOptionsTitle = "No additional security options available"
hadrianLang.account.securityNoOptionsSub = "Your administrator has not enabled any additional sign-in security features (such as two-factor authentication) for your account. Please contact support if you would like extra protection added."
hadrianLang.account.securityNoOptionsSsoSub = "Your administrator has not enabled any additional sign-in security features (such as single sign-on, linked accounts, or two-factor authentication) for your account. Please contact support if you would like extra protection added."
hadrianLang.account.tfaModalError = "Something went wrong — please try again."
hadrianLang.account.changePasswordSub = "Pick a strong new password — minimum 8 characters with mixed case and numbers."
hadrianLang.account.pwStrengthVeryWeak = "Very weak"
hadrianLang.account.pwStrengthTooWeak = "Too weak"
hadrianLang.account.pwStrengthWeak = "Weak"
hadrianLang.account.pwStrengthFair = "Fair"
hadrianLang.account.pwStrengthGood = "Good"
hadrianLang.account.pwStrengthStrong = "Strong"
hadrianLang.account.passwordsMatch = "Passwords match"
hadrianLang.account.passwordsNoMatch = "Passwords do not match"
hadrianLang.account.togglePasswordVisibility = "Show or hide password"
hadrianLang.account.inviteInvalidSub = "This invitation link is no longer valid or has already been used."
hadrianLang.account.emailVerifiedSub = "Your email address is confirmed. You're all set."
hadrianLang.account.emailNotFoundSub = "We couldn't find this verification request. It may have been completed already, or the link is malformed."
hadrianLang.account.affiliatesSub = "Earn commission for every customer you refer to Hostnodes. Track your clicks, signups and payouts here."
hadrianLang.account.affiliatesDisabledSub = "Please check back later or contact support if you believe this is an error."
hadrianLang.account.affiliatesNoReferrals = "No referrals yet"
hadrianLang.account.affiliatesNoReferralsSub = "Share your referral link above to start earning commission. Every signup that comes through your link will appear here."
hadrianLang.account.securitySettingsSsoSub = "Single sign-on and connected third-party accounts for your login."
hadrianLang.account.ssoSummary = "Move between connected areas without signing in again."
hadrianLang.account.ssoDisableNotice = "You can turn this off at any time."

hadrianLang.ssl.manageIntro = "View status, configure, or renew the certificates on your account."
hadrianLang.ssl.orderNew = "Order new certificate"
hadrianLang.ssl.browse = "Browse SSL"
hadrianLang.ssl.noCertificates = "No certificates yet"
hadrianLang.ssl.noCertificatesSub = "Once you order an SSL certificate it'll show up here for management."
hadrianLang.ssl.configureTitle = "Configure your SSL certificate"
hadrianLang.ssl.configIntro = "Provide your server type and certificate signing request, then confirm the administrative contact."
hadrianLang.ssl.stepConfig = "Configuration"
hadrianLang.ssl.stepValidate = "Validation"
hadrianLang.ssl.stepComplete = "Complete"
hadrianLang.ssl.noConfigPossibleSub = "Its current status does not allow configuration. Open the service to review its state."
hadrianLang.ssl.invalidLinkSub = "This configuration link is invalid or has expired. Open the service to start again."
hadrianLang.ssl.verifyTitle = "Verify domain ownership"
hadrianLang.ssl.validationIntro = "Choose how you want to prove control of the domain so the certificate authority can issue your certificate."
hadrianLang.ssl.step1Incomplete = "Configuration not complete"
hadrianLang.ssl.step1IncompleteSub = "Finish the certificate configuration step before choosing a validation method."
hadrianLang.ssl.requestSubmittedTitle = "Certificate request submitted"
hadrianLang.ssl.completeIntro = "Complete the validation step below so the certificate authority can issue your certificate."
hadrianLang.ssl.completedForPrefix = "Your certificate request for"
hadrianLang.ssl.completedForSuffix = "has been submitted."
hadrianLang.ssl.completedGeneric = "Your certificate request has been submitted."
hadrianLang.ssl.configFailed = "Configuration could not be completed"
hadrianLang.ssl.configFailedSub = "Something went wrong while submitting your certificate request. Try again or contact support."
```
