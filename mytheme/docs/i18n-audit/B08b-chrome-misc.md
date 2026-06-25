# B08b — Page chrome (misc partials: locale / head / logo / seo / captcha / verifyemail / cookie-box / state-chip / errors)

## Summary
- **Total strings (table rows):** 18
- **WHMCS:** 9
- **CUSTOM:** 9
- **#js-string:** 0 (the only `<script>` blocks — `cookie-box.tpl` consent binder, `verifyemail.tpl` resend/dismiss binder, captcha `$_capPageJs` echo — contain **no hardcoded user-facing strings**; verifyemail's resend success/error labels come from `data-*` attrs that ARE reported as the attr rows, not as js-strings)
- **#SKIP-worth-noting:** error/* + locale-modal already-tokenized via legacy `$rslang.*`/`$LANG` keys (see notes — not reported as hardcoded per task); the 28 language *autonyms* + 6 currency-code labels in locale-modal's static fallback (proper nouns / native script — SKIP); state-chip.tpl is **dev-preview-only** chrome (`?preview=1`, never in production) — reported as a grouped note, not rows (see decision below); `alt="CAPTCHA"` acronym, `'english'` locale-code fallback, brand/SVG/URL/`data-*` skipped.

### Evidence legend
- nexus uses `{lang key='x'}` (resolves real WHMCS `$_LANG`) — citing it proves a key is real.
- lagom uses `{$LANG.x}` — same proof.
- **`hostnodes-apple/footer.tpl`** is an EARLIER build of THIS theme's own locale modal and uses the real WHMCS keys (`chooselanguage`, `choosecurrency`, `close`, `apply`) bare — strongest same-install proof for the locale partials.
- This theme uses `{$LANG.x|default:'…'}` almost everywhere; per spec the `|default` literal is the "Current text", and `|default`-only keys not provable elsewhere are **invented → CUSTOM**.
- Legacy custom keys live in `hadrian/templates/hadrian/core/lang/english.php` under `$rslang.*` (Phase B renames to `$hadrianLang`). The error/* files + license banner already reference these.

---

### hadrian/templates/hadrian/includes/partials/locale-btn.tpl
| Line | Type | Current text | Class | Proposed reference | Evidence / Notes | Conf |
|------|------|--------------|-------|--------------------|------------------|------|
| 7 | aria-label | Choose language and currency | CUSTOM | {$hadrianLang.common.localeChoose} | bare hardcoded a11y label (built with an inline `{if}` → "Choose language" + " and currency"); no single WHMCS key for the combined phrase; reuse the same custom key as the modal title (locale-modal:9) | med |

Notes: `{$hadrian.localeFlag|...}`, `{$language|default:'english'|capitalize}` (line 9 — `'english'` is a **locale identifier/data value**, not UI copy → SKIP), `{$activeCurrency.prefix}`/`{$activeCurrency.code|default:'USD'}` (currency code/data → SKIP), `/` separator glyph, SVG path → SKIP. The "and currency" fragment is part of the line-7 aria-label sentence, not a standalone row.

---

### hadrian/templates/hadrian/includes/partials/locale-modal.tpl
| Line | Type | Current text | Class | Proposed reference | Evidence / Notes | Conf |
|------|------|--------------|-------|--------------------|------------------|------|
| 9 | text | Choose language & currency | CUSTOM | {$hadrianLang.common.localeChoose} | `localechoose` found ONLY here with a `|default` → **invented LANG key**; nexus/hostnodes-apple build this heading by concatenating two real keys (`chooselanguage` / `choosecurrency`), there is no single WHMCS key for the combined phrase → rebadge | high |
| 10 | aria-label | Close | WHMCS | {$LANG.close} | real key — `hostnodes-apple/footer.tpl:73` `{lang key='close'}`, `nexus/footer.tpl:70`, `lagom2.3/.../footer/default/default.tpl:207`; **strip default** | high |
| 25 | text | Language | WHMCS | {$LANG.chooselanguage} | `languagechoose` is **invented** (only ever with `|default`); the real WHMCS key for this section label is `chooselanguage` — `hostnodes-apple/footer.tpl:77` & `nexus/footer.tpl:102` `{lang key='chooselanguage'}`; wording shifts "Language"→"Choose Language" (acceptable per policy) | high |
| 26 | aria-label | Language | WHMCS | {$LANG.chooselanguage} | dedupe of line 25 (radiogroup a11y label) | high |
| 64 | text | Currency | WHMCS | {$LANG.choosecurrency} | `currencychoose` is **invented**; real key is `choosecurrency` — `hostnodes-apple/footer.tpl:88` & `nexus/footer.tpl:115` `{lang key='choosecurrency'}` (cf. flat `currency` at `hostnodes-apple/clientregister.tpl:131`); "Currency"→"Choose Currency" | high |
| 65 | aria-label | Currency | WHMCS | {$LANG.choosecurrency} | dedupe of line 64 (radiogroup a11y label) | high |
| 82 | text | Apply | WHMCS | {$LANG.apply} | real key — `hostnodes-apple/footer.tpl:100`, `nexus/footer.tpl:129` `{lang key='apply'}`; **strip default** | high |

Notes (SKIP): the 28 static-fallback language buttons (lines 32–57: `العربية`, `Azerbaijani`, `Català`, `中文`, `Hrvatski`, `English`, `Deutsch`, `Français`, `Español`, … ) are **language autonyms / native-script proper nouns** — not translatable UI copy → SKIP. The 6 static currency buttons (lines 71–76: `$ USD`, `€ EUR`, `£ GBP`, `$ CAD`, `$ AUD`, `¥ JPY`) are currency codes + symbols → SKIP. `data-lang`/`data-currency`/`role`/`id` attrs, `{$lang|capitalize}`/`{$cur.code}` dynamic output skipped.

---

### hadrian/templates/hadrian/includes/partials/state-chip.tpl
_None reported — dev-only._ Every visible string in this file ("preview", "Layout:", "Top nav", "Sidebar", "Icon rail", "Data:", "Full", "Empty", "Align:", "Center", "Content", "Left", "Sub-nav:", "Show", "Hide", "Sub-nav side:", "Right", "Outside L/R", "Services:", "Controls inside/outside", "Tiles:", "Plan:", "Palette:", all the `title=` variant tooltips, and `aria-label="Preview options"` / `"Color palette"`) is **developer-only chrome**: the whole partial is gated `{if $smarty.get.preview == '1'}` (lines 7–12) and the header comment states it "Renders ONLY on ?preview=1 — never in the live portal, admins included." It is an internal layout/palette dev tool, not customer-facing UI.

> **Decision:** SKIP for translation (per the spec's "not translatable" spirit — never reaches an end user). Flagged as an ambiguity in case the user wants dev-tooling localized; if so, ~40 strings would go CUSTOM under a new `$hadrianLang.devchip.*` group. **Recommend SKIP.**

---

### hadrian/templates/hadrian/includes/partials/cookie-box.tpl
| Line | Type | Current text | Class | Proposed reference | Evidence / Notes | Conf |
|------|------|--------------|-------|--------------------|------------------|------|
| 23 | text | Continue | WHMCS | {$LANG.continue} | dismiss-button **fallback** label (admin-overridable via `cookie_box_button`, PHP default also "Continue" — `SettingsController.php:122,174`); `continue` is a real WHMCS key used widely in this theme (e.g. `configuressl-stepone/...:177`, `supportticketsubmit/...:128`) → map the literal fallback to it | med |
| 24 | aria-label | Cookie notice | CUSTOM | {$hadrianLang.common.cookieNotice} | bare hardcoded dialog a11y label; no WHMCS key (Lagom's cookie bar is data-driven, no `$LANG`) | high |
| 29 | text | We use cookies to improve your experience. By continuing to browse, you agree to our use of cookies. | CUSTOM | {$hadrianLang.common.cookieMessage} | consent **fallback** message (renders only when admin `cookie_box_message` is empty; PHP default is `''` — `SettingsController.php:120`); bespoke copy, no WHMCS key | high |

Notes: `{$mtCookieBtn|escape}` / `{$mtCookieMsg}` are the dynamic admin-set values (the literals above are the inline `{if}…{else}` fallbacks). `mtCookiePos` enum, all CSS in the `{literal}<style>`, and the `{literal}<script>` consent binder (DOM/cookie logic, **no UI strings**) → SKIP. `role`/`data-*`/SVG skipped.

---

### hadrian/templates/hadrian/includes/common/head.tpl
_None found._ (Pure asset `<link>` tags built from `{$WEB_ROOT}`/`{$template}`/`{$hadrian.version}`/`{$language}` + `{if}`/`in_array` logic — no text nodes, user-facing attrs, or JS strings. CSS filenames/URLs SKIP per spec.)

---

### hadrian/templates/hadrian/includes/common/logo.tpl
_None found._ (`alt="{$companyname|escape}"` and `<span>{$companyname}</span>` are **dynamic** company-name output — SKIP per spec. `file_exists`/`{include}`/`{assign}` logic, `href`/`src`/`data-logo-dark` attrs, class names SKIP.)

---

### hadrian/templates/hadrian/includes/common/seo.tpl
_None found._ (`<title>` = `{$pagetitle}` + `{$companyname}` dynamic; `<meta description>` = `{$tagline}` dynamic; canonical `href` is a URL. No hardcoded strings.)

---

### hadrian/templates/hadrian/includes/captcha.tpl
| Line | Type | Current text | Class | Proposed reference | Evidence / Notes | Conf |
|------|------|--------------|-------|--------------------|------------------|------|
| 18 | text | Type the characters shown in the image | WHMCS | {$LANG.captchaverify} | real key — `nexus/includes/captcha.tpl:12` `{lang key="captchaverify"}`, `lagom2.3/lagom2-theme/includes/captcha.tpl:24` `{lang key="captchaverify"}`; the `|default` wording differs slightly from the WHMCS string but it's the same key → **strip default** | high |

Notes: `alt="CAPTCHA"` (line 19) is an **acronym/proper term** (nexus/lagom give the image no alt at all) → SKIP. `{$captchaForm}`/`{$_capPageJs}` dynamic; the reCAPTCHA `<div>`/`<input>` are markup; `{$_capPageJs}` echo carries WHMCS-generated JS (not authored UI strings) → SKIP.

---

### hadrian/templates/hadrian/includes/verifyemail.tpl
| Line | Type | Current text | Class | Proposed reference | Evidence / Notes | Conf |
|------|------|--------------|-------|--------------------|------------------|------|
| 13 | value | Verification email sent | WHMCS | {$LANG.emailSent} | real key — `nexus/includes/verifyemail.tpl:13` & `lagom2.3/.../includes/verifyemail.tpl:11` `data-email-sent="{lang key='emailSent'}"`/`{$LANG.emailSent}`; (`data-sent` attr → resend success toast) **strip default** | high |
| 14 | value | Something went wrong — please try again | WHMCS | {$LANG.error} | real key — `nexus/includes/verifyemail.tpl:13` & `lagom2.3/.../includes/verifyemail.tpl:11` `data-error-msg="{lang key='error'}"`/`{$LANG.error}`; **note:** WHMCS `error` = "Error", our literal is a longer custom sentence — stripping the default changes the wording; **strip default** (or keep as CUSTOM if the longer phrasing must be preserved) | high |
| 18 | text | Please verify your email address — check your inbox for the verification link… | WHMCS | {$LANG.verifyEmailAddress} | real key — `nexus/includes/verifyemail.tpl:10` `{lang key='verifyEmailAddress'}`, `lagom2.3/.../includes/verifyemail.tpl:9` `{$LANG.verifyEmailAddress}`; default wording is custom-expanded vs WHMCS string → **strip default** | high |
| 19 | text | Resend email | WHMCS | {$LANG.resendEmail} | real key — `nexus/includes/verifyemail.tpl:15` `{lang key='resendEmail'}`, `lagom2.3/.../includes/verifyemail.tpl:12` `{$LANG.resendEmail}`; **strip default** | high |
| 20 | aria-label | Dismiss | WHMCS | {$LANG.close} | close button a11y label; real key `close` (see locale-modal:10 evidence); default "Dismiss" vs WHMCS "Close" — same key; **strip default** | med |

Notes: `data-resend`/`data-dismiss-uri` = `routePath(...)`, `data-token` = `{$token}` dynamic → SKIP. The `{literal}<script>` resend/dismiss binder builds NO strings of its own — its success/error text is read from the `data-sent`/`data-error` attrs (rows 13/14 above) → **no js-string rows**. SVG paths SKIP.

---

### hadrian/templates/hadrian/error/internal-error.tpl
| Line | Type | Current text | Class | Proposed reference | Evidence / Notes | Conf |
|------|------|--------------|-------|--------------------|------------------|------|
| — | — | _Already tokenized via legacy `$rslang.error.serverError.*` / `$rslang.error.backHome` (lines 3–5)._ | — | — | keys EXIST in `core/lang/english.php:19-23` (the `|default` literals merely mirror them); per task: legacy `$rslang.*` = already-tokenized, not hardcoded → **note only, Phase B renames to `$hadrianLang`**. No native WHMCS key exists (WHMCS's own `error/internal-error.tpl` is static HTML with `{{placeholder}}` mustache, not `$_LANG` — `nexus/error/internal-error.tpl:48-50` "Oops!" etc.) | — |

_No NEW hardcoded strings._ (`{include head.tpl}`, `{$WEB_ROOT}` href, class names SKIP.)

---

### hadrian/templates/hadrian/error/page-not-found.tpl
| Line | Type | Current text | Class | Proposed reference | Evidence / Notes | Conf |
|------|------|--------------|-------|--------------------|------------------|------|
| — | — | _Already tokenized via legacy `$rslang.error.notFound.*` / `$rslang.error.backHome` (lines 3–5)._ | — | — | keys EXIST in `core/lang/english.php:15-23`; legacy `$rslang.*` → **note only** (Phase B rename). No native WHMCS `$_LANG` equivalent (WHMCS 404 page is not `$_LANG`-driven) | — |

_No NEW hardcoded strings._

---

### hadrian/templates/hadrian/error/license-required.tpl
| Line | Type | Current text | Class | Proposed reference | Evidence / Notes | Conf |
|------|------|--------------|-------|--------------------|------------------|------|
| 3 | text | Theme license required | CUSTOM | {$hadrianLang.common.licenseRequiredTitle} | **NOT tokenized** (raw hardcoded, no `$rslang`/`$LANG`); dedupe with `header.tpl:38` "Theme License Required" (B08 already proposed `hadrianLang.common.licenseRequiredTitle`) — **note casing differs** ("license" lc here vs "License" Title-case in header); unify | high |
| 4 | text | This commercial theme cannot render until the Hadrian addon is active and a valid license is available. | CUSTOM | {$hadrianLang.common.licenseRequiredBody} | raw hardcoded body copy; no WHMCS key; bespoke license-gate message. "Hadrian" is a brand noun inside the sentence — sentence still tokenizable | high |

Notes: this file is the one error/* template that is **fully un-tokenized** (the `$rslang` license group `core/lang/english.php:26-34` only covers the license *banner*: `expiringIn`/`expired`/`invalid`/`renew`/`contact` — NOT this hard license-gate page). `role`/`aria-labelledby`/`id`/class attrs SKIP.

---

## New ambiguities (flag for the user)
1. **`state-chip.tpl` is dev-only — translate or not?** ~40 visible strings ("Top nav", "Controls inside", palette/tile/plan tooltips, `aria-label="Preview options"`, …) live behind `?preview=1` and never render for end users. **Recommended SKIP.** If the user wants the dev chip localized, mint a `$hadrianLang.devchip.*` group (not done here).
2. **`verifyemail.tpl` line 14 — longer custom error wording.** Our `|default:'Something went wrong — please try again'` is friendlier than WHMCS `error` ("Error"). Both nexus & lagom feed THIS exact `data-error-msg` from `{lang key='error'}`, so mapping to `{$LANG.error}` is consistent — **but stripping the default will shorten the toast to "Error".** Decide: accept WHMCS wording (→ WHMCS) or preserve the sentence (→ CUSTOM `$hadrianLang.common.genericError`).
3. **Locale section labels: real key wording shift.** `chooselanguage`/`choosecurrency` render "Choose Language"/"Choose Currency", whereas our invented `languagechoose`/`currencychoose` render bare "Language"/"Currency". Mapped to the real keys per "prefer real WHMCS keys" — note the visible label gains the "Choose " prefix. (If bare "Language"/"Currency" is required, those become CUSTOM.)
4. **`licenseRequiredTitle` casing collision.** `header.tpl:38` uses "Theme License Required" (Title-case); `error/license-required.tpl:3` uses "Theme license required" (sentence-case). Same proposed key `hadrianLang.common.licenseRequiredTitle` — **pick one canonical casing.** I listed the key's value as the header's Title-case form below.
5. **Cookie button → WHMCS `continue`.** The "Continue" fallback maps cleanly to the real WHMCS `continue` key, BUT the admin can override it via `cookie_box_button`, and Lagom's parity bar treats it as free admin text. Low-risk mapping; flag in case the user prefers the cookie button stay a pure admin/custom string (then → `$hadrianLang.common.cookieAccept`).
6. **error/* `$rslang` keys not citable as WHMCS.** WHMCS's native 404/500 pages are mustache-templated (`{{stacktrace}}`, `{{systemurl}}`), not `$_LANG`-driven (proof: `nexus/error/internal-error.tpl` is static "Oops!" HTML). So the error copy is legitimately theme-custom — the existing `$rslang.error.*` keys are the correct mechanism; Phase B only needs to rename the namespace, not source WHMCS keys.

---

## Proposed custom keys
```
hadrianLang.common.localeChoose = "Choose language & currency"
hadrianLang.common.cookieNotice = "Cookie notice"
hadrianLang.common.cookieMessage = "We use cookies to improve your experience. By continuing to browse, you agree to our use of cookies."
hadrianLang.common.licenseRequiredTitle = "Theme License Required"
hadrianLang.common.licenseRequiredBody = "This commercial theme cannot render until the Hadrian addon is active and a valid license is available."
```
_Note: `licenseRequiredTitle` is a dedupe of B08 (header.tpl:38) — do not double-add; reconcile casing (ambiguity 4)._

### Optional (only if Phase B keeps the longer verifyemail error wording instead of WHMCS `error`)
```
hadrianLang.common.genericError = "Something went wrong — please try again"
```

### Optional (only if the user wants the dev-preview chip localized — recommended SKIP)
```
(~40 strings under $hadrianLang.devchip.* — not enumerated; see ambiguity 1)
```
