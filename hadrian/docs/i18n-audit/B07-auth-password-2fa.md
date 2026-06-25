# B07 — Auth: Password Reset & Two-Factor

## Summary
- **Total strings:** 33
- **WHMCS:** 21
- **CUSTOM:** 12
- **SKIP-worth-noting:** 0
- **js-string:** 2 (both CUSTOM)

Nine files audited. Six are pure forwarders (`{include}` one-liners, no hardcoded
strings of their own): the four `password-reset-*` dispatchers forward to `pwreset`,
and `changepassword` / `changepw` forward to the canonical `core/pages/user-password`
variant (NOT in this batch's scope — audit it under its own slug). All real strings
live in three files: `pwreset`, `two-factor-challenge`, `two-factor-new-backup-code`.

**Pattern across the batch:** every user-facing string is `{$LANG.key|default:'English'}`.
The form-mechanic keys (`pwreset`, `newpassword`, `confirmnewpassword`, `loginemail`,
`pwresetsubmit`, `pwresetenternewpw`, `pwresetemailneeded`, `pwresetsecurityquestionrequired`,
`clientareasavechanges`, `twofactorauth`, `twofa*`, `loginbutton`, `copy`,
`noPasswordResetWhenLoggedIn`, `clientareanavhome`) are **real WHMCS keys** — proven by
the prior Apple theme `hostnodes-apple/*.tpl` and `nexus`/`lagom` using them bare via
`{lang key='…'}` / `{$LANG.…}`. → strip the `|default`.

The **invented** keys are the bespoke headings/microcopy this theme added that no WHMCS
key covers: the per-step reset *titles* (`pwresetsecuritytitle`, `pwresetnewtitle`,
`pwresetcheckemailtitle`), the back-to-login link (`backtologin`), the security answer
label (`youranswer`), the plural "Backup codes" page copy (`twofabackupcodes`,
`twofabackupcodessub`, `twofabackupwarn`), the `Done` button (`done`), the TOTP/backup
toggle pair (`usetotpinstead`, `usebackupcode`), and their JS-string twins.

---

### hadrian/templates/hadrian/core/pages/password-reset-change-prompt/default/default.tpl
_None found._ (forwards to `pwreset/default/default.tpl`; only a `{* *}` comment + `{include}`.)

### hadrian/templates/hadrian/core/pages/password-reset-container/default/default.tpl
_None found._ (forwards to `pwreset/default/default.tpl`.)

### hadrian/templates/hadrian/core/pages/password-reset-email-prompt/default/default.tpl
_None found._ (forwards to `pwreset/default/default.tpl`.)

### hadrian/templates/hadrian/core/pages/password-reset-security-prompt/default/default.tpl
_None found._ (forwards to `pwreset/default/default.tpl`.)

### hadrian/templates/hadrian/core/pages/pwreset/default/default.tpl
| Line | Type | Current text | Class | Proposed reference | Evidence / Notes | Conf |
|------|------|--------------|-------|--------------------|------------------|------|
| 31 | text | You are already signed in — log out first to reset your password. | WHMCS | {$LANG.noPasswordResetWhenLoggedIn} | hostnodes-apple/password-reset-container.tpl:9 + lagom .../includes/login/password-reset.tpl:20 use `noPasswordResetWhenLoggedIn` bare; real key — strip default (WHMCS wording differs) | high |
| 33 | text | Go to dashboard | WHMCS | {$LANG.clientareanavhome} | real nav key; used bare across WHMCS; hadrian topnav.tpl:146/sidebar.tpl:139 carry it (with default "Dashboard") — strip default | high |
| 38 | text | Check your email | CUSTOM | {$hadrianLang.auth.pwresetCheckEmailTitle} | invented LANG key → rebadge; only ever appears with `|default`. NOTE: this branch already prefers the WHMCS server var `$successTitle` and only falls back to this literal — keep that fallback, just rebadge the literal | high |
| 40 | text | Back to sign in | CUSTOM | {$hadrianLang.auth.backToLogin} | invented LANG key → rebadge; `backtologin` never appears bare. Closest real key is `loginbutton` ("Sign In") but wording is a back-link, not a verb — keep CUSTOM | med |
| 52 | text | Verify your identity | CUSTOM | {$hadrianLang.auth.pwresetSecurityTitle} | invented LANG key → rebadge; reference reset step-2 has NO bespoke title (reuses `{$LANG.pwreset}` as heading — hostnodes-apple/password-reset-security-prompt.tpl:4) | high |
| 53 | text | Answer your security question to continue. | WHMCS | {$LANG.pwresetsecurityquestionrequired} | nexus/password-reset-security-prompt.tpl:7 + hostnodes-apple/password-reset-security-prompt.tpl:5 use it bare; real key — strip default | high |
| 59 | text | Your answer | CUSTOM | {$hadrianLang.auth.yourAnswer} | invented LANG key → rebadge; all references label this input with the `$securityQuestion` server var, no separate "Your answer" label exists (nexus pwreset-security-prompt.tpl:11) | high |
| 62 | value | Continue | WHMCS | {$LANG.pwresetsubmit} | reused submit key; nexus/password-reset-security-prompt.tpl:17 uses `pwresetsubmit` bare on the step-2 button — strip default (button text, type=submit) | high |
| 67 | text | Choose a new password | CUSTOM | {$hadrianLang.auth.pwresetNewTitle} | invented LANG key → rebadge; reference step-3 heading is the real `{$LANG.newpassword}` (hostnodes-apple/password-reset-change-prompt.tpl:4), not a bespoke title | high |
| 68 | text | Enter a new password for your account. | WHMCS | {$LANG.pwresetenternewpw} | nexus/password-reset-change-prompt.tpl:1 + lagom user-password path use `pwresetenternewpw` bare — strip default | high |
| 72 | text | New password | WHMCS | {$LANG.newpassword} | nexus/password-reset-change-prompt.tpl:7 + lagom2 user-password.tpl:16 use it bare; also hadrian user-password.tpl:64 — strip default | high |
| 76 | text | Confirm new password | WHMCS | {$LANG.confirmnewpassword} | nexus/password-reset-change-prompt.tpl:12 + lagom2 user-password.tpl:24 use it bare — strip default | high |
| 79 | value | Set new password | WHMCS | {$LANG.clientareasavechanges} | nexus/password-reset-change-prompt.tpl:24 + lagom2 user-password.tpl:20/30 use `clientareasavechanges` bare on this submit — strip default (wording differs, key is right) | high |
| 84 | text | Reset your password | WHMCS | {$LANG.pwreset} | nexus/password-reset-email-prompt.tpl:2 + hostnodes-apple/password-reset-email-prompt.tpl:5 use `pwreset` bare as the step-1 heading — strip default | high |
| 85 | text | Enter the email associated with your account and we will send a reset link. | WHMCS | {$LANG.pwresetemailneeded} | nexus/password-reset-email-prompt.tpl:3 + hostnodes-apple/...email-prompt.tpl:6 use it bare — strip default | high |
| 89 | text | Email address | WHMCS | {$LANG.loginemail} | nexus/password-reset-email-prompt.tpl:10 + hostnodes-apple/...email-prompt.tpl:12 use `loginemail` bare — strip default | high |
| 96 | value | Send reset link | WHMCS | {$LANG.pwresetsubmit} | nexus/password-reset-email-prompt.tpl:27 uses `pwresetsubmit` bare on this button — strip default (button text; wording differs, key is right) | high |
| 98 | text | Back to sign in | CUSTOM | {$hadrianLang.auth.backToLogin} | dedupe of line 40; same invented `backtologin` literal | med |

### hadrian/templates/hadrian/core/pages/two-factor-challenge/default/default.tpl
| Line | Type | Current text | Class | Proposed reference | Evidence / Notes | Conf |
|------|------|--------------|-------|--------------------|------------------|------|
| 17 | text | Two-factor authentication | WHMCS | {$LANG.twofactorauth} | hostnodes-apple/two-factor-challenge.tpl:7 + lagom .../includes/login/two-factor.tpl:11 + nexus/two-factor-challenge.tpl use `twofactorauth` bare — strip default | high |
| 20 | text | Backup code accepted. New codes have been emailed to you. | WHMCS | {$LANG.twofabackupcodereset} | hostnodes-apple/two-factor-challenge.tpl:12 + lagom .../two-factor.tpl:19 use `twofabackupcodereset` bare — strip default (WHMCS wording differs) | high |
| 22 | text | The code you entered is incorrect. Try again. | WHMCS | {$LANG.twofa2ndfactorincorrect} | hostnodes-apple/two-factor-challenge.tpl:14 + lagom .../two-factor.tpl:21 use `twofa2ndfactorincorrect` bare — strip default | high |
| 26 | text | Enter the verification code from your authenticator app to continue. | WHMCS | {$LANG.twofa2ndfactorreq} | hostnodes-apple/two-factor-challenge.tpl:18 + lagom .../two-factor.tpl:25 use `twofa2ndfactorreq` bare — strip default (WHMCS wording differs) | high |
| 34 | text | Backup code | WHMCS | {$LANG.twofabackupcodelogin} | hostnodes-apple/two-factor-challenge.tpl:27 uses `twofabackupcodelogin` bare as this label; lagom uses it as the input placeholder (two-factor.tpl:42) — strip default | high |
| 35 | placeholder | xxxx-xxxx-xxxx | CUSTOM | {$hadrianLang.auth.backupCodePlaceholder} | format mask, not a WHMCS string; lowercase x's are a literal pattern hint. NOTE: arguably SKIP-able as a format token, but it is user-visible copy → rebadge | low |
| 36 | value | Sign in | WHMCS | {$LANG.loginbutton} | hostnodes-apple/two-factor-challenge.tpl:30 + lagom .../two-factor.tpl:32/45 use `loginbutton` bare on this submit — strip default | high |
| 41 | text | Use authenticator code instead | CUSTOM | {$hadrianLang.auth.useTotpInstead} | invented LANG key → rebadge; `usetotpinstead` never bare. No WHMCS key for the "switch back to TOTP" direction (references only have the one-way `twofaloginusingbackupcode`) | high |
| 41 | text | Use a backup code | CUSTOM | {$hadrianLang.auth.useBackupCode} | invented LANG key → rebadge; `usebackupcode` never bare. Real adjacent key is `twofaloginusingbackupcode` ("Use a backup code") — hostnodes-apple/two-factor-challenge.tpl:36 — consider WHMCS `{$LANG.twofaloginusingbackupcode}` instead (same English); kept CUSTOM only because this file pairs it with the no-key TOTP direction | med |
| 58 | js-string | Use a backup code | CUSTOM | {$hadrianLang.auth.useBackupCode} | JS toggle re-sets `toggle.textContent`; dedupe of line-41 "Use a backup code". Seed from Smarty into a JS var | high |
| 58 | js-string | Use authenticator code instead | CUSTOM | {$hadrianLang.auth.useTotpInstead} | JS toggle alternate label; dedupe of line-41 "Use authenticator code instead" | high |

### hadrian/templates/hadrian/core/pages/two-factor-new-backup-code/default/default.tpl
| Line | Type | Current text | Class | Proposed reference | Evidence / Notes | Conf |
|------|------|--------------|-------|--------------------|------------------|------|
| 13 | text | Backup codes | CUSTOM | {$hadrianLang.auth.backupCodesTitle} | invented LANG key → rebadge; `twofabackupcodes` (plural) never bare. Reference page shows a SINGLE code titled `twofanewbackupcodeis` (hostnodes-apple/two-factor-new-backup-code.tpl:11) — this theme's plural-list heading has no WHMCS equivalent | high |
| 14 | text | Save these codes somewhere safe. Each one can be used once to sign in if you lose access to your authenticator device. | CUSTOM | {$hadrianLang.auth.backupCodesSub} | invented LANG key → rebadge; `twofabackupcodessub` never bare. Reference uses `twofabackupcodeexpl` for its (different) single-code explainer | high |
| 29 | text | Copy | WHMCS | {$LANG.copy} | real key; hadrian affiliates.tpl:145 + clientareadomaingetepp.tpl:35 + configuressl-complete.tpl use `{$LANG.copy}` — strip default | high |
| 31 | text | Done | CUSTOM | {$hadrianLang.auth.done} | invented LANG key → rebadge; `done` never bare anywhere. Reference end-of-flow CTA is the real `{$LANG.continue}` (hostnodes-apple/two-factor-new-backup-code.tpl:20) — consider WHMCS `{$LANG.continue}` ("Continue") if a wording shift is acceptable | med |
| 36 | text | These codes will not be shown again. Once you leave this page they are gone. | CUSTOM | {$hadrianLang.auth.backupCodesWarn} | invented LANG key → rebadge; `twofabackupwarn` never bare; no WHMCS warning key for this plural-list page | high |
| 53 | js-string | Copied | CUSTOM | {$hadrianLang.auth.copied} | JS sets `btn.textContent='Copied'` after clipboard write; transient confirmation. No WHMCS key; seed from Smarty | high |

---

## Proposed custom keys
```
hadrianLang.auth.pwresetCheckEmailTitle = "Check your email"
hadrianLang.auth.backToLogin            = "Back to sign in"
hadrianLang.auth.pwresetSecurityTitle   = "Verify your identity"
hadrianLang.auth.yourAnswer             = "Your answer"
hadrianLang.auth.pwresetNewTitle        = "Choose a new password"
hadrianLang.auth.backupCodePlaceholder  = "xxxx-xxxx-xxxx"
hadrianLang.auth.useTotpInstead         = "Use authenticator code instead"
hadrianLang.auth.useBackupCode          = "Use a backup code"
hadrianLang.auth.backupCodesTitle       = "Backup codes"
hadrianLang.auth.backupCodesSub         = "Save these codes somewhere safe. Each one can be used once to sign in if you lose access to your authenticator device."
hadrianLang.auth.done                   = "Done"
hadrianLang.auth.backupCodesWarn        = "These codes will not be shown again. Once you leave this page they are gone."
hadrianLang.auth.copied                 = "Copied"
```
