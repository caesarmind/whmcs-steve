# B08 — Page chrome (header, footer layouts, menus, sidebar/rail/topbar)

## Summary
- **Total strings (table rows):** 96
- **WHMCS:** 75
- **CUSTOM:** 21
- **Distinct strings after dedupe:** ~38 (the 3 near-identical account-dropdown partials — `topnav.tpl`, `inner-topbar.tpl`, and `sidebar/default.tpl`'s topbar — repeat the same ~20 account/profile rows; `itemsInCart`, `darkMode`, `openNavigation`, `toggleTheme`, copyright, etc. are flagged as dedupes)
- **#SKIP-worth-noting:** see notes below (legacy `$rslang` not present in these files; `$companyname`/`$mtBrand.*`/`$item.label` dynamic output skipped; brand/SVG/URLs skipped; landmark `aria-label`s "Main"/"Utility"/"breadcrumb" skipped)
- **#js-string:** 0 (the only `<script>` block — `sidebar.tpl` group-toggle binder — contains no user-facing strings)

### Evidence legend
- nexus uses `{lang key='x'}` (resolves real WHMCS `$_LANG`) — citing it proves a key is real.
- lagom uses `{$LANG.x}` — same proof.
- This theme uses `{$LANG.x|default:'...'}` **everywhere** (never a bare `{$LANG.x}`), so per-spec the `|default` literal is the "Current text" and the `|default`-only keys that are NOT provable elsewhere are treated as invented → CUSTOM.
- A large class of nav labels here (`clientareanavhome`, `servicestab`, `accounttab`, `invoicestab`, `supporttickets`, `navchangedetails`, `navsecurity`, `navemailshistory`) are **genuine WHMCS navigation `$_LANG` keys**, but WHMCS resolves them inside its core navbar/Menu objects (see `nexus/includes/navbar.tpl:5` → `$item->getLabel()`), so they never appear in a reference *template* and cannot be cited file:line. Policy is "prefer real WHMCS keys", so these are kept **WHMCS** at **low/med** confidence with the note "WHMCS nav key, core-resolved — verify in lang/english.php; strip default". They are flagged as a NEW AMBIGUITY below.

---

### hadrian/templates/hadrian/header.tpl
| Line | Type | Current text | Class | Proposed reference | Evidence / Notes | Conf |
|------|------|--------------|-------|--------------------|------------------|------|
| 38 | text | Theme License Required | CUSTOM | {$hadrianLang.common.licenseRequiredTitle} | license-gate `<title>`, only renders when Hadrian license invalid; bespoke copy | high |
| 359 | text | Home | WHMCS | {$LANG.home} | breadcrumb back-link; `home` is a standard WHMCS key (not citable in nexus/lagom templates); strip default | med |

Notes: lines 185/188/193/196/201/206/208 (`'Dashboard'`, `'My Products & Services'`, `'My Domains'`, `'My Invoices'`, `'Support Tickets'`, `'My Details'`, `'Announcements'`) are assigned to `$mt_pageLabel`, a Smarty *variable* used as a `data-page-title`/breadcrumb fallback — they are page-title strings rendered through `{$pagetitle}`/`$mt_pageLabel`, not literal text nodes. They duplicate the WHMCS page titles. **Borderline**: reported here as a group rather than 7 rows because they are assignment values, not emitted markup; if Phase B wants them tokenized use `{$LANG.clientareanavhome}` (Dashboard), `{$LANG.domains}` / `My Domains`, `{$LANG.invoices}` / `My Invoices`, `{$LANG.supporttickets}` (Support Tickets), `{$LANG.clientareanavdetails}` (My Details), `{$LANG.announcementstitle}` (Announcements). Flagged as ambiguity. SKIPPED as rows: `{$pagetitle}`, `{$companyname}`, all `data-*` attr values, `<base>`/CSS/CDN URLs, the inline `var csrfToken=…` JS (config values, not UI), `aria-label="breadcrumb"` (SKIP per spec? it is an a11y attr → see note), SVG path data.
> `aria-label="breadcrumb"` (line 355): landmark role-name; conventionally not translated and matches nexus pattern — SKIP.

---

### hadrian/templates/hadrian/core/layouts/footer/default/default.tpl
| Line | Type | Current text | Class | Proposed reference | Evidence / Notes | Conf |
|------|------|--------------|-------|--------------------|------------------|------|
| 9 | text | All rights reserved. | CUSTOM | {$hadrianLang.footer.allRightsReserved} | `allrightsreserved` NOT in nexus/lagom; the literal already exists as a Hadrian custom key `footer.allRightsReserved` in `hadrian/templates/hadrian/core/lang/english.php:10` → invented LANG key → rebadge | high |

Notes: `{$companyname}`, `{$smarty.now|date_format}`, `$mtFooterSecondaryItems[].label` (admin-driven), `&copy;` skipped.

---

### hadrian/templates/hadrian/core/layouts/footer/extended/default.tpl
| Line | Type | Current text | Class | Proposed reference | Evidence / Notes | Conf |
|------|------|--------------|-------|--------------------|------------------|------|
| 44 | text | All rights reserved. | CUSTOM | {$hadrianLang.footer.allRightsReserved} | dedupe of footer copyright; same as default/default.tpl:9 | high |

Notes: all column headings/links are admin-menu driven (`$col.label`, `$link.label`) → dynamic, SKIP.

---

### hadrian/templates/hadrian/core/layouts/footer/extended-info/default.tpl
| Line | Type | Current text | Class | Proposed reference | Evidence / Notes | Conf |
|------|------|--------------|-------|--------------------|------------------|------|
| 30 | text | Premium web hosting on Google Cloud. A genuinely free plan, isolated environments, no cPanel clutter. | CUSTOM | {$hadrianLang.footer.tagline} | `footertagline` NOT in nexus/lagom → invented LANG key → rebadge; falls back only when admin `$mtBrand.description` unset. "Google Cloud"/"cPanel" are brand nouns inside the sentence — sentence still tokenizable | high |
| 66 | text | All rights reserved. | CUSTOM | {$hadrianLang.footer.allRightsReserved} | dedupe of footer copyright | high |

Notes: social `aria-label`/`title` values (`"X (Twitter)"`, `"X"`, `"LinkedIn"`, `"Facebook"`, `"GitHub"`, `"YouTube"`, `"Instagram"`) on lines 33–38 are **brand/proper nouns** → SKIP per spec. `{$companyname}`, `$mtBrand.*`, SVG paths skipped.

---

### hadrian/templates/hadrian/core/layouts/main-menu/sidebar/default.tpl
| Line | Type | Current text | Class | Proposed reference | Evidence / Notes | Conf |
|------|------|--------------|-------|--------------------|------------------|------|
| 23 | placeholder | Search | WHMCS | {$LANG.searchbutton} | KB search box; `searchbutton` is a standard WHMCS key (nexus uses `searchOurKnowledgebase` for the same KB box, `nexus/header.tpl:97`); strip default | med |
| 32 | text | Dashboard | WHMCS | {$LANG.clientareanavhome} | WHMCS nav key, core-resolved (see legend); strip default | med |
| 35 | text | Services | WHMCS | {$LANG.servicestab} | WHMCS nav/section key, core-resolved; strip default | med |
| 41 | text | My Services | WHMCS | {$LANG.navservices} | real key — `nexus/clientareahome.tpl:9` `{lang key='navservices'}`, `lagom2.3/lagom2-theme/clientareahome.tpl:70`; strip default | high |
| 49 | text | My Domains | WHMCS | {$LANG.navdomains} | real key — `nexus/clientareahome.tpl:18`, `lagom2.3/lagom2-theme/clientareahome.tpl:78`; strip default | high |
| 53 | text | Billing | WHMCS | {$LANG.invoicestab} | WHMCS nav/section key, core-resolved; strip default | med |
| 59 | text | Invoices | WHMCS | {$LANG.navinvoices} | real key — `nexus/clientareahome.tpl:53` `{lang key='navinvoices'}`; strip default | high |
| 67 | text | Payment Methods | WHMCS | {$LANG.paymentMethods.title} | real nested key — `nexus/account-paymentmethods.tpl:22` `{lang key='paymentMethods.title'}`; already correct key, strip default | high |
| 70 | text | Support | WHMCS | {$LANG.supporttickets} | WHMCS section key (`supporttickets`), core-resolved; strip default | med |
| 76 | text | Support Tickets | WHMCS | {$LANG.navtickets} | real key — `nexus/clientareahome.tpl:45`, `lagom2.3/lagom2-theme/clientareahome.tpl:115`; strip default | high |
| 84 | text | Knowledge Base | WHMCS | {$LANG.knowledgebasetitle} | real key — `nexus/homepage.tpl:74` `{lang key='knowledgebasetitle'}`; strip default | high |
| 91 | text | Announcements | WHMCS | {$LANG.announcementstitle} | real key — `nexus/homepage.tpl:58` `{lang key='announcementstitle'}`; strip default | high |
| 94 | text | Account | WHMCS | {$LANG.accounttab} | WHMCS section key, core-resolved; strip default | med |
| 100 | text | My Details | WHMCS | {$LANG.navchangedetails} | WHMCS nav key, core-resolved (cf. real `clientareanavdetails`); strip default | med |
| 107 | text | Security | WHMCS | {$LANG.navsecurity} | WHMCS nav key, core-resolved; strip default | med |
| 134 | title | Notifications | WHMCS | {$LANG.notifications} | real key — `nexus/header.tpl:24` `{lang key='notifications'}`; note: default text "Notifications" but key var is `announcementstitle` in source (mismatch) — see ambiguity; strip default | high |
| 139 | title | Shopping Cart | WHMCS | {$LANG.carttitle} | real key — `nexus/header.tpl:106` `{lang key="carttitle"}`; strip default | high |
| 145 | title | Account | WHMCS | {$LANG.accounttab} | dedupe; WHMCS section key; strip default | med |
| 153 | text | My Details | WHMCS | {$LANG.navchangedetails} | dedupe of line 100 | med |
| 157 | text | Security Settings | WHMCS | {$LANG.navsecurity} | nav key; note default here is "Security Settings" vs line 107 "Security" — same key, divergent default; strip default | med |
| 161 | text | Email History | WHMCS | {$LANG.navemailshistory} | WHMCS nav key, core-resolved; strip default | med |
| 168 | text | Dark Mode | CUSTOM | {$hadrianLang.common.darkMode} | **bare hardcoded text** (NOT wrapped in any `$LANG`); theme feature label; cf. topnav uses `{$LANG.darkMode|default:'Dark Mode'}` (also invented) — unify under one custom key | high |
| 176 | text | Sign Out | WHMCS | {$LANG.logout} | real key — `nexus/oauth/login-twofactorauth.tpl` family / standard `logout`; default "Sign Out" vs WHMCS "Logout"; strip default | med |
| 181 | text | Sign In | WHMCS | {$LANG.login} | real key — `nexus/oauth/login-twofactorauth.tpl:15` `{lang key='login'}`; default "Sign In" vs WHMCS "Login"; strip default | high |

Notes: `$user_initials`, `$user_fullname`, `$clientsdetails.email`, `$pagetitle`, `$companyname`, all SVG/`data-*`/`onclick`/`id` skipped. `'U'`/`'User'`/`'Dashboard'` (lines 114/116/128) are `|default` fallbacks on dynamic vars (initials/name/page-title), not standalone UI copy → SKIP.

---

### hadrian/templates/hadrian/core/layouts/main-menu/top/default.tpl
_None found._ (pure `{include}` dispatch — no text, attrs, or JS strings.)

---

### hadrian/templates/hadrian/includes/menu/main-menu.tpl
_None found._ (nav labels come from `$item->getLabel()` on WHMCS Menu objects — dynamic, not hardcoded. `aria-label="Main"` is a landmark name; SKIP per convention, matches nexus.)

> Borderline: `aria-label="Main"` (line 2). Landmark role-name; conventionally untranslated → SKIP. If Phase B tokenizes landmarks, propose `{$hadrianLang.nav.mainLandmark}` = "Main".

---

### hadrian/templates/hadrian/includes/menu/top-nav.tpl
_None found._ (labels via `$item->getLabel()`; dynamic.)

> Borderline: `aria-label="Utility"` (line 2). Landmark role-name → SKIP. If tokenized: `{$hadrianLang.nav.utilityLandmark}` = "Utility".

---

### hadrian/templates/hadrian/includes/partials/topnav.tpl
| Line | Type | Current text | Class | Proposed reference | Evidence / Notes | Conf |
|------|------|--------------|-------|--------------------|------------------|------|
| 124 | aria-label | Open navigation | CUSTOM | {$hadrianLang.nav.openNavigation} | mobile drawer toggle; `menu` is real WHMCS but default wording "Open navigation" is custom a11y copy → rebadge (or map to `{$LANG.menu}` if exact "Menu" acceptable) | med |
| 145 | text | Home | WHMCS | {$LANG.home} | menu fallback link; standard WHMCS key; strip default | med |
| 146 | text | Dashboard | WHMCS | {$LANG.clientareanavhome} | menu fallback; WHMCS nav key, core-resolved; strip default | med |
| 153 | title | Notifications | WHMCS | {$LANG.notifications} | real key — `nexus/header.tpl:24`; strip default | high |
| 159 | text | Notifications | WHMCS | {$LANG.notifications} | dropdown header; real key; strip default | high |
| 189 | text | No notifications | WHMCS | {$LANG.nonotifications} | real key — `nexus/header.tpl:27` `{lang key='nonotifications'}`; strip default | high |
| 196 | title | Cart | WHMCS | {$LANG.carttitle} | real key — `nexus/header.tpl:106`; default "Cart" vs "Shopping Cart" (sidebar layout) — same key; strip default | high |
| 204 | aria-label | items in cart | CUSTOM | {$hadrianLang.nav.itemsInCart} | `cartItems` NOT in nexus/lagom/standard_cart → invented; a11y label, value form "%s items in cart"; rebadge | high |
| 206 | aria-label | items in cart | CUSTOM | {$hadrianLang.nav.itemsInCart} | dedupe of line 204 | high |
| 208 | aria-label | items in cart | CUSTOM | {$hadrianLang.nav.itemsInCart} | dedupe of line 204 | high |
| 214 | title | Account | WHMCS | {$LANG.accounttab} | WHMCS section key, core-resolved; strip default | med |
| 224 | text | Account Details | WHMCS | {$LANG.accountdetails} | WHMCS account key, core-resolved (cf. `clientareanavdetails`); strip default | med |
| 228 | text | User Management | WHMCS | {$LANG.usermanagement} | WHMCS account key; real variant `navUserManagement` exists in nexus key list; strip default | med |
| 232 | text | Payment Methods | WHMCS | {$LANG.paymentMethods.title} | flat `paymentmethods` default → map to real nested key `paymentMethods.title` (`nexus/account-paymentmethods.tpl:22`); strip default | high |
| 236 | text | Contacts | WHMCS | {$LANG.contacts} | WHMCS account key, core-resolved; strip default | med |
| 240 | text | Email History | WHMCS | {$LANG.emailstitle} | WHMCS account key, core-resolved; strip default | med |
| 248 | text | Your Profile | WHMCS | {$LANG.yourprofile} | WHMCS user-menu key, core-resolved; strip default | med |
| 252 | text | Switch Account | WHMCS | {$LANG.switchaccount} | WHMCS user-menu key, core-resolved; strip default | med |
| 256 | text | Change Password | WHMCS | {$LANG.clientareanavchangepassword} | WHMCS nav key, core-resolved; strip default | med |
| 260 | text | Security Settings | WHMCS | {$LANG.securitysettings} | WHMCS key, core-resolved; strip default | med |
| 272 | text | Dark Mode | CUSTOM | {$hadrianLang.common.darkMode} | `darkMode` NOT in nexus/lagom → invented theme label; dedupe with sidebar/default.tpl:168 | high |
| 283 | text | Logout | WHMCS | {$LANG.logout} | standard WHMCS key; strip default | high |
| 288 | text | Sign in | WHMCS | {$LANG.login} | real key — `nexus/oauth/login-twofactorauth.tpl:15`; default "Sign in" vs "Login"; strip default | high |
| 290 | aria-label | Toggle theme | CUSTOM | {$hadrianLang.common.toggleTheme} | bare hardcoded a11y label on dark-mode toggle; no WHMCS key | high |

Notes: `$user_initials`/`$user_fullname`/`$_email`/`$item.label`/`$child.label`/`$ann.title`/`$alert->getMessage()` all dynamic → SKIP. `'U'`/`'Account'` (lines 214/217) are `|default` on dynamic initials/name → SKIP. `$globalCartCount`/`$cartitems`/`$cartcount` numeric, SVG/`data-*`/`onclick` skipped.

---

### hadrian/templates/hadrian/includes/partials/sidebar.tpl
| Line | Type | Current text | Class | Proposed reference | Evidence / Notes | Conf |
|------|------|--------------|-------|--------------------|------------------|------|
| 111 | aria-label | Close menu | WHMCS | {$LANG.close} | real key — `nexus/footer.tpl:70` `{lang key='close'}`, `lagom2.3/lagom2-theme/core/layouts/footer/default/default.tpl:207`; default "Close menu" vs "Close" — same key; strip default | high |
| 117 | placeholder | Search | WHMCS | {$LANG.searchbutton} | KB search box; dedupe with sidebar/default.tpl:23; strip default | med |
| 137 | text | Home | WHMCS | {$LANG.home} | nav fallback link; standard WHMCS key; strip default | med |
| 139 | text | Dashboard | WHMCS | {$LANG.clientareanavhome} | nav fallback; WHMCS nav key, core-resolved; strip default | med |
| 143 | text | Configure menu… | CUSTOM | {$hadrianLang.nav.configureMenu} | bare hardcoded admin-fallback link (shows only when menu manager empty); bespoke copy | low |
| 161 | text | Sign in | WHMCS | {$LANG.login} | real key; default "Sign in"; strip default | high |
| 162 | text | Create account | WHMCS | {$LANG.createaccount} | WHMCS register key (cf. real `registerCreateAccount` in nexus key list); default "Create account"; strip default | med |

Notes: `$item.label`/`$child.label`/`$companyname`/`$user_fullname`/`$_email`/`$user_initials` dynamic → SKIP. `'U'` (line 152) `|default` on initials → SKIP. The `<script>` block (lines 168–190) is the sidebar-group toggle binder — **no user-facing strings** (only DOM selectors/dataset flags) → no js-string rows. SVG/`data-*`/inline-style skipped.

---

### hadrian/templates/hadrian/includes/partials/rail.tpl
| Line | Type | Current text | Class | Proposed reference | Evidence / Notes | Conf |
|------|------|--------------|-------|--------------------|------------------|------|
| 4 | aria-label | Portal Home | CUSTOM | {$hadrianLang.nav.portalHome} | rail logo a11y label; "Portal Home" is custom wording (vs bare "Home") — rebadge (or `{$LANG.home}` if "Home" acceptable) | med |
| 11 | text | Shop | WHMCS | {$LANG.shop} | rail item; `shop` is a standard WHMCS key (not citable in nexus/lagom templates); strip default | low |
| 15 | text | Domains | WHMCS | {$LANG.navdomains} | real key — `nexus/clientareahome.tpl:18`; default "Domains" vs "My Domains" — same key; strip default | high |
| 19 | text | Support | WHMCS | {$LANG.supporttickets} | WHMCS section key, core-resolved; strip default | med |
| 25 | text | Dashboard | WHMCS | {$LANG.clientareanavhome} | WHMCS nav key, core-resolved; strip default | med |
| 29 | text | Services | WHMCS | {$LANG.navservices} | real key — `nexus/clientareahome.tpl:9`; default "Services" vs "My Services"; strip default | high |
| 33 | text | Domains | WHMCS | {$LANG.navdomains} | dedupe of line 15 | high |
| 37 | text | Billing | WHMCS | {$LANG.invoicestab} | WHMCS section key, core-resolved; strip default | med |
| 41 | text | Support | WHMCS | {$LANG.supporttickets} | dedupe of line 19 | med |
| 45 | text | Account | WHMCS | {$LANG.accounttab} | WHMCS section key, core-resolved; strip default | med |
| 54 | text | Sign in | WHMCS | {$LANG.login} | real key; strip default | high |

Notes: `$clientsdetails.firstname` (line 50 initials) dynamic → SKIP. SVG/`data-*`/inline-style skipped.

---

### hadrian/templates/hadrian/includes/partials/inner-topbar.tpl
| Line | Type | Current text | Class | Proposed reference | Evidence / Notes | Conf |
|------|------|--------------|-------|--------------------|------------------|------|
| 14 | aria-label | Open navigation | CUSTOM | {$hadrianLang.nav.openNavigation} | mobile sidebar toggle; dedupe with topnav.tpl:124 | med |
| 29 | text | Home | WHMCS | {$LANG.home} | breadcrumb root; standard WHMCS key; strip default | med |
| 31 | text | Page | CUSTOM | {$hadrianLang.common.page} | `|default:'Page'` fallback on `$mt_pageLabel`/`$pagetitle`; generic placeholder when no page title — bespoke fallback | low |
| 36 | aria-label | Notifications | WHMCS | {$LANG.notifications} | real key — `nexus/header.tpl:24`; strip default | high |
| 42 | text | Notifications | WHMCS | {$LANG.notifications} | dropdown header; real key; strip default | high |
| 72 | text | No notifications | WHMCS | {$LANG.nonotifications} | real key — `nexus/header.tpl:27`; strip default | high |
| 78 | aria-label | Cart | WHMCS | {$LANG.carttitle} | real key — `nexus/header.tpl:106`; strip default | high |
| 84 | aria-label | items in cart | CUSTOM | {$hadrianLang.nav.itemsInCart} | dedupe of topnav.tpl:204; invented `cartItems` | high |
| 86 | aria-label | items in cart | CUSTOM | {$hadrianLang.nav.itemsInCart} | dedupe | high |
| 88 | aria-label | items in cart | CUSTOM | {$hadrianLang.nav.itemsInCart} | dedupe | high |
| 92 | aria-label | Toggle theme | CUSTOM | {$hadrianLang.common.toggleTheme} | bare hardcoded a11y label; dedupe with topnav.tpl:290 | high |
| 98 | title | Account | WHMCS | {$LANG.accounttab} | WHMCS section key, core-resolved; strip default | med |
| 108 | text | Account Details | WHMCS | {$LANG.accountdetails} | dedupe of topnav.tpl:224 | med |
| 112 | text | User Management | WHMCS | {$LANG.usermanagement} | dedupe of topnav.tpl:228 | med |
| 116 | text | Payment Methods | WHMCS | {$LANG.paymentMethods.title} | flat `paymentmethods` → real nested key; dedupe of topnav.tpl:232 | high |
| 120 | text | Contacts | WHMCS | {$LANG.contacts} | dedupe of topnav.tpl:236 | med |
| 124 | text | Email History | WHMCS | {$LANG.emailstitle} | dedupe of topnav.tpl:240 | med |
| 132 | text | Your Profile | WHMCS | {$LANG.yourprofile} | dedupe of topnav.tpl:248 | med |
| 136 | text | Switch Account | WHMCS | {$LANG.switchaccount} | dedupe of topnav.tpl:252 | med |
| 140 | text | Change Password | WHMCS | {$LANG.clientareanavchangepassword} | dedupe of topnav.tpl:256 | med |
| 144 | text | Security Settings | WHMCS | {$LANG.securitysettings} | dedupe of topnav.tpl:260 | med |
| 154 | text | Dark Mode | CUSTOM | {$hadrianLang.common.darkMode} | invented theme label; dedupe of sidebar/default.tpl:168 | high |
| 165 | text | Logout | WHMCS | {$LANG.logout} | standard key; dedupe of topnav.tpl:283 | high |
| 170 | text | Sign in | WHMCS | {$LANG.login} | real key; dedupe; strip default | high |

Notes: `$user_initials`/`$user_fullname`/`$_email`/`$ann.title`/`$alert->getMessage()` dynamic → SKIP. `'Account'` (line 101) `|default` on dynamic name → SKIP. `$globalCartCount`/`$cartitems`/`$cartcount` numeric, `‹›`/`›` separator glyphs (lines 30) punctuation → SKIP. SVG/`data-*`/`onclick`/inline-style skipped.

---

## New ambiguities (flag for the user)
1. **Core-resolved WHMCS nav keys can't be cited file:line.** `clientareanavhome`, `servicestab`, `accounttab`, `invoicestab`, `supporttickets`, `navchangedetails`, `navsecurity`, `navemailshistory`, `accountdetails`, `usermanagement`, `contacts`, `emailstitle`, `yourprofile`, `switchaccount`, `clientareanavchangepassword`, `securitysettings`, `home`, `shop`, `createaccount`, `searchbutton` are genuine WHMCS `$_LANG` keys but WHMCS resolves them inside its navbar/Menu PHP (proof of mechanism: `nexus/includes/navbar.tpl:5` uses `$item->getLabel()`, never `{lang key=...}`). Kept **WHMCS / med-low conf** per the "prefer real keys" policy. If the user wants strict citable-only, these flip to CUSTOM. **Recommend: verify each against the server `lang/english.php` before stripping defaults.**
2. **Divergent defaults on the same key.** Several keys carry different English fallbacks across files — `navsecurity`: "Security" (sidebar:107) vs "Security Settings" (sidebar:157); `logout`: "Sign Out" (sidebar:176) vs "Logout" (topnav:283); `navdomains`/`navservices`: "Domains"/"Services" (rail) vs "My Domains"/"My Services" (sidebar); `carttitle`: "Cart" vs "Shopping Cart". Stripping `|default` resolves these to one WHMCS string automatically — note the visible label WILL change on the rail/sign-out.
3. **`announcementstitle` reused as a Notifications title.** sidebar/default.tpl:134 sets `title="{$LANG.announcementstitle|default:'Notifications'}"` — the KEY says "announcements" but the default says "Notifications". The real intent is the notifications bell → should be `{$LANG.notifications}`, not `announcementstitle`. Mapped to `{$LANG.notifications}` in the table; flag as a likely pre-existing bug.
4. **Two `paymentMethods` key shapes coexist.** Sidebar layout already uses the correct nested `paymentMethods.title`; topnav/inner-topbar use a flat invented `paymentmethods`. Unify on the real nested `{$LANG.paymentMethods.title}`.
5. **`allRightsReserved` is already a Hadrian custom key.** It exists in `hadrian/templates/hadrian/core/lang/english.php:10` as `footer.allRightsReserved` (the legacy `$rslang` namespace that Phase B renames to `$hadrianLang`). The templates duplicate it as an invented `{$LANG.allrightsreserved|default:...}`. Rebadge to the existing custom key rather than minting a new one.
6. **Landmark `aria-label`s** ("Main", "Utility", "breadcrumb") left as SKIP per convention; listed as borderline in main-menu.tpl / top-nav.tpl / header.tpl notes in case Phase B tokenizes landmarks.
7. **`$mt_pageLabel` assignment literals** in header.tpl (Dashboard / My Products & Services / My Domains / My Invoices / Support Tickets / My Details / Announcements) are assignment values feeding a breadcrumb, not emitted text nodes — reported as a grouped note, not rows. Decide whether Phase B tokenizes header-level page-label assignments.

---

## Proposed custom keys
```
hadrianLang.common.licenseRequiredTitle = "Theme License Required"
hadrianLang.common.darkMode = "Dark Mode"
hadrianLang.common.toggleTheme = "Toggle theme"
hadrianLang.common.page = "Page"
hadrianLang.footer.allRightsReserved = "All rights reserved."
hadrianLang.footer.tagline = "Premium web hosting on Google Cloud. A genuinely free plan, isolated environments, no cPanel clutter."
hadrianLang.nav.openNavigation = "Open navigation"
hadrianLang.nav.itemsInCart = "%s items in cart"
hadrianLang.nav.configureMenu = "Configure menu…"
hadrianLang.nav.portalHome = "Portal Home"
```

### Optional (only if Phase B tokenizes landmark a11y names)
```
hadrianLang.nav.mainLandmark = "Main"
hadrianLang.nav.utilityLandmark = "Utility"
```
