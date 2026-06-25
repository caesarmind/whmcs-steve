# Phase B — implementation progress: COMPLETE

Foundation:
- [x] Promote consolidated lang draft → live `core/lang/english.php` (devchip dropped; php-lint clean; 16 groups, 640 keys)
- [x] Rename `$rslang` → `$hadrianLang` (Hooks.php:108 + 2 error tpls; no stray refs)
- [x] Validator `hadrian/scripts/check-i18n-safety.mjs` (internal Smarty balance + ref resolution)

Implementation chunks — all applied + validated:
- [x] B01 cart-viewcart · B02 cart-checkout · B03 cart-configure (14 js via `_localLang`) · B04 cart-domains-products (CYCLE_LABEL js) · B05 cart-misc
- [x] B06 auth-core (clientregister New/Cancel wrong-key bugs fixed) · B07 auth-password-2fa
- [x] B08 chrome (announcementstitle→notifications bug fixed) · B08b chrome-misc (license-required)
- [x] B09 dashboard · B10 services (status pills→real keys)
- [x] B11 domains (getepp Copied js) · B12 billing (invoice*→invoices*, $LANG.billing array trap, **CSRF token fix** on masspay + invoice-payment)
- [x] B13a support (DataTables affixes→common.*) · B13b kb-content (markdown.* + wrapped bold/italic, viewcart mis-key fixed)
- [x] B14a account ($LANG.name array trap, permission label, confirm() seeds) · B14b users-ssl (ssl.* dotted switches, emailVerification.*/accountInvite.*)

Cleanup (gaps agents correctly refused to invent):
- [x] banned + access-denied: added `error.bannedTitle/bannedHeading/bannedSub/accessDeniedSub`; `$LANG.error` stripped
- [x] account-user-permissions: stripped `userManagement.permissions` + `clientareasavechanges`; kept `account.managePermissionsSub` (help sentence)
- [x] downloads empty-state: `downloadsnone`/`knowledgebasetitle` stripped; added `support.downloadsEmptySub`
- [x] configureproductdomain JS: `_localLang` seed before `{literal}` → `cart.ownDomainNeedBoth`, `cart.domainChecking`, real `cartdomaininvalid`

Final validation (all green):
- [x] php -l english.php — no syntax errors
- [x] check-i18n-safety.mjs — 111 changed tpls internally balanced + every `$hadrianLang` ref resolves
- [x] check-smarty-balance.mjs — 190 files balanced · check-html-balance.mjs — 102 pages, 0 mismatch
- [x] leftover `{$LANG.x|default:'Text'}` user-facing strings = 0

NOT committed / NOT pushed — gated on user review + testing.
