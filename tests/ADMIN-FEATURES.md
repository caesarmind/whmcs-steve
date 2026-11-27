# Hadrian admin features, tested one by one

Every feature of the Hadrian admin addon (`hadrian/modules/addons/Hadrian/`), with what it promises and whether a test proved it does that. The list and the IDs come from the AD section of [FEATURES.md](FEATURES.md).

Each test works the way an admin does: it opens the screen in Chromium, changes the control and presses Save. Then it proves the change three ways:
- **stored:** the database value before and after
- **effect:** the client area, the order form or the file on disk, before and after
- **seen:** screenshots of the admin screen and of the effect

Everything an admin can write is backed up before each test file and put back after it.

Run it against the local site, then rebuild this file:

```
cd tests
npx playwright test --project=admin-audit
node lib/admin-audit-report.mjs
```

The full proof (steps, values, every check, screenshots) is in `tests/reports/admin-audit/REPORT.md` on the machine that ran it. Tests live in `tests/e2e/audit/`.

**Last run:** 2026-11-27T16:02:51.251Z. **98 features.** Works: 88 · Works (part not testable here): 3 · Not tested: 1 · Not in this audit: 6

## Bugs found by the first run, all fixed

The first run (2026-11-27) found these. Each was fixed the same day, and the test in `tests/e2e/audit/` that asserts the promise now passes. They stay listed so a regression is easy to recognise.

1. **AD-26.** Styles saves a font stack HTML-escaped. WHMCS escapes every admin POST; `StylesController.php:654` stores the stack as posted, so quotes arrive as `&#039;`, and `Hooks.php:794` strips `&` and `;`. Visitors get `--font-family:039Roboto039, ...`: a Google body font picked in Styles never applies, and self-hosted fonts break the same way. The Customizer decodes its POST (`CustomizeController.php:263`) and is not affected.
2. **AD-29.** Custom CSS is stored HTML-escaped (`StylesController.php:698`), so `body > .x` is saved as `body &gt; .x` and quotes as `&quot;`. Those rules do not apply on the site, and the box shows the entities after a reload. CSS without `<`, `>`, `&` or quotes works.
3. **AD-38.** Affixed Navigation does nothing on the Top layout. `core-layout.js:882` looks for `.topbar, .ph-side-topbar`, but the Top layout draws `nav.homepage-nav` (`includes/partials/topnav.tpl:131`), so the script stops before it listens.
4. **AD-47.** Saving one dashboard variant rewrites another variant's section layout. `pages/edit.tpl:1246` marks any non-empty layout as changed and `:1281` re-serialises it on every submit, so saving Minimal rewrote Bento's stored `services:1/1,tickets:1/2` into the full list.
5. **AD-64.** Reset WHMCS Defaults never says how many presets it reset. `menu/index.tpl:22` takes 16 characters of the flash and compares them with the 15-character `reset-defaults-`.
6. **AD-66.** Moving an active menu to the other audience leaves two active menus there. `MenuController.php:301` compares with `$menu->audience` after line 295 already set it to the posted value, so the peers are never switched off.
7. **AD-67.** A dropdown and its child added in the same save lose the child. The editor sends the parent as `new_<tempId>` (`menu/edit.tpl:2102`) but the server keys new rows `new_<payload index>` (`MenuController.php:591`); the child ends up as its own parent and renders nowhere.
8. **AD-68.** Menu item description, badge, text transform, hide label and CSS class are saved but never shown. `TreeRenderer.php:224` drops the first four, and the templates never print `css_class`. Known and documented, now proven.
9. **AD-12.** Settings search from one tab finds a row on the other tab but cannot show it: it says "1 setting matches (across both tabs)" and shows nothing, because the other tab's rows keep `.mt-tab-off` (`display:none !important`) and the script only clears `hidden` (`settings/index.tpl:1373-1381`).
10. **AD-19.** With "Use Custom Hostname" off, the cart still uses the custom length, zone and domain; the help text says a random string is used. Only the character set is gated on the flag (`hadrian_cart/configureproduct.tpl:312-318`, `:327`).
11. **AD-87.** A licence status of "Error" shows as "This key is not valid for this domain" (a fail, not a warn): `SetupChecks.php:265-276` has no branch for it, and `LicenseCheck.php:91-93` caches it for 15 minutes like any signed answer. Whether the server ever sends "Error" is not known.
12. **AD-25.** Colour presets and "Generate from one colour" also write the dark scope, while the panel says "writes the light scope only" (`styles/_colors.tpl:93`; `includes/footer.tpl:450`, `:1201-1202`). A code comment calls this deliberate, so the panel text may be what is stale.

Smaller things, also fixed:
- Menu editor: the max_input_vars warning starts at 950 estimated fields but Save is refused above 900, so a menu of about 128 to 134 items is refused with no warning first.
- Templates screen (AD-83): `templateName` goes into a file path unchecked, and an unknown name prints the absolute server path (`TemplatesController.php:29-31`).
- AD-04: FEATURES.md quotes the theme version as 1.1.242; `core/hadrian.php` now says 1.1.247.

## AD-A Landing, Info, Setup

| ID | Feature | Promises | Verdict | Proof |
|---|---|---|---|---|
| AD-01 | Default landing | Bare `?module=Hadrian` shows Setup while the theme isn't live or migrations are pending, otherwise Info; unknown action falls back to index | Works | 10/10 checks. `Template` hadrian -> twenty-one |
| AD-02 | Info page | Theme version; licence badge, key, product, dates, domains (15-minute cache); "New version" flag never set | Works | 11/11 checks |
| AD-03 | "Setup not finished" banner | On every screen except Setup while setup needs attention | Works | 13/13 checks |
| AD-04 | Version source | Header pill, Info, Setup and cache invalidation read the version in `core/hadrian.php`; `Hadrian.php` says 1.2.3 | Works | 7/7 checks |
| AD-05 | Setup checklist | Files, Requirements, Database, License, Go live; each group takes its worst row; missing cart warns; mismatched release marks fail | Works | 19/19 checks. `Files > Order form state` ok -> warn |
| AD-06 | Setup: Run now | Migrations, preset menus, page and layout caches, branding folder with `.htaccess`; redirects to `done=installed` | Works | 16/16 checks. `menus` 0 -> 6; `hadrian_pages_discovered pages` null -> 103 |
| AD-07 | Setup: save licence key | Trims and stores `hadrian_license_key`, deletes `hn_theme_license.json`, forces a fresh check | Works | 10/10 checks. `hadrian_license_key` null -> HN-AUDIT-NOT-A-KEY; `License row state` todo -> fail |
| AD-08 | Go live | Refused while any group is todo or fail; sets `Template=hadrian`, and `OrderFormTemplate=hadrian_cart` if the cart is complete; remembers the old values | Works (part not testable here) | 3/3 checks. skipped: Needs a live licence server: going live requires an Active key from license.hostnodes.com (and the enforcement hook, which calls that server on every page). Faking the answer is not allowed. |
| AD-09 | Switch back | Restores only rows still pointing at Hadrian; refuses if an old theme folder is gone, checking both first | Works | 30/30 checks. `Template / OrderFormTemplate` ["hadrian","premium_comparison"] -> ["twenty-one","premium_comparison"]; `Template / OrderFormTemplate` ["hadrian","hadrian_cart"] -> ["twenty-one","standard_cart"] |
| AD-10 | Preview link | `index.php?systpl=hadrian` | Works | 8/8 checks |

## AD-B Settings screen

| ID | Feature | Promises | Verdict | Proof |
|---|---|---|---|---|
| AD-11 | Save (General and Order Process tabs) | Every flag stored as `'1'` or `'0'` from `isset($_POST)`; Layouts-page flags skipped; hidden-tab rows still post | Works | 102/102 checks. `free_label` 0 -> 1; `free_label (second save)` 1 -> 0 |
| AD-12 | Search and tabs | Filter with synonyms ("gdpr"); Enter blocked in search; tab switch reloads | Works | 21/21 checks |
| AD-13 | Dark mode settings | `enable_dark_mode`, `dark_mode_display`, `dark_mode_default` allow-listed | Works | 6/6 checks. `dark_mode_display, dark_mode_default` {"display":"switcher","def":"light"} -> {"display":"forced","def":"dark"}; `dark_mode_display, dark_mode_default` {"display":"forced","def":"dark"} -> {"display":"switcher","def":"l |
| AD-14 | Card controls exception list | `svc_layout_pages` filtered to `SVC_LAYOUT_PAGES` | Works | 4/4 checks. `svc_layout_pages` [] -> ["clientareaproducts"] |
| AD-15 | Sub-nav exception lists | `subnav_pages_website`, `subnav_pages_order` filtered to valid pages | Works | 8/8 checks. `subnav_pages_website, subnav_pages_order` {"website":[],"order":[]} -> {"website":["clientareahome"],"order":["products"]} |
| AD-16 | Custom language list | `custom_language_codes` filtered to installed languages | Works | 4/4 checks. `custom_language_codes` [] -> ["english","french"] |
| AD-17 | Cookie box settings | Message map keeps installed non-empty languages; position allow-listed; button falls back to "Continue" | Works | 8/8 checks. `cookie_box_message, position, button` {"message":"[]","position":"bottom-right","button":"Got it"} -> {"message":"{\"english\":\"Audit cookie message in English\",\"french\":\"Message cookie audit en francais\"}","posit |
| AD-18 | Dynamic tables endpoint | `enable_dynamic_ajax`: 401 with no client, 403 with the flag off | Works | 12/12 checks. `enable_dynamic_ajax` 0 -> 1; `enable_dynamic_ajax` 1 -> 0 |
| AD-19 | Order-process settings save | `op_hide_*` off/all/selected with group IDs filtered to existing groups; interfix clamped 8-50; suffix gets a leading dot; character set limited | Works | 34/34 checks. `interfix, op_hide_nameservers, chars` {"interfix":"20","ns":"off","chars":["numbers"]} -> {"interfix":"50","ns":"all","chars":[]}; `op_root_pw_strength` 0 -> 1 |

## AD-C Styles

| ID | Feature | Promises | Verdict | Proof |
|---|---|---|---|---|
| AD-20 | Activate a style | Only shipped styles; migrates legacy colours; seeds the preset palette once per scope; sets `<tpl>_active_style` | Works | 26/26 checks. `hadrian_active_style` default -> emerald; `hadrian_colors_emerald_light` null -> {"--color-accent":"#14b17d","--color-accent-hover":"#0fa370","--color-accent-light":"rgba(20,177,125,0.10)","--color-link":"#0c7f57","--co |
| AD-21 | Style card swatches | Reflect saved colours, isolated per style | Works | 6/6 checks. `accent band per card` {"rose":"rgb(255, 45, 107)","emerald":"rgb(20, 177, 125)","default":"rgb(0, 113, 227)"} -> {"rose":"rgb(18, 171, 52)","emerald":"rgb(20, 177, 125)","default":"rgb(0, 113, 227)"} |
| AD-22 | Style editor routing | Subcategory and tab allow-listed; `?style=` resolved; migrations on GET | Works | 17/17 checks. `colours, navigation and layout rows` {"dark":null,"nav":null,"layout":{"--sidebar-width":300,"--content-max-width":1000}} -> {"dark":{"--color-accent":"#445566"},"nav":{"--sidebar-width":300},"layout":{"--content-max-wi |
| AD-23 | Colours save | Light and dark post together; only schema tokens with valid hex, rgb, hsl that differ from default are kept; the rest dropped silently | Works | 21/21 checks. `hadrian_colors_default_light` null -> {"--color-link":"hsl(120, 50%, 40%)","--color-bg":"rgb(1,2,3)"}; `hadrian_colors_default_light / _dark` {"light":null,"dark":null} -> {"light":{"--color-accent":"#12ab34"},"dark":{" |
| AD-24 | Reset to preset | Deletes both scope rows (and legacy keys for default), then re-seeds; check upgraded installs don't fall back to legacy keys | Works | 13/13 checks. `hadrian_colors_emerald_light / _dark` {"light":{"--color-accent":"#12ab34"},"dark":{"--color-accent":"#222222"}} -> {"light":{"--color-accent":"#14b17d","--color-accent-hover":"#0fa370","--color-accent-light":"rgba(20,1 |
| AD-25 | Quick presets, generate from one colour, undo | Client-side; fills the light and dark palettes together (dark accent derived lighter); nothing stored until Save | Works | 15/15 checks. `dark Accent (hidden twin): start, after Generate, after a preset` #2997ff -> ["#12ab34","#8794a4"] |
| AD-26 | Typography save | Sizes, weights, line-heights kept only in bounds and not default; Google family checked against the catalog (any name passes if it is missing); self-hosted name sanitised; heading font | Works | 40/40 checks. `hadrian_typography` null -> {"fontFamily":{"mode":"google","google":"Made Up Family","stack":"'Made Up Family', system-ui, sans-serif"}}; `hadrian_typography (unknown family)` {"fontFamily":{"mode":"google","google":"Ro |
| AD-27 | Google Fonts catalog | Rows re-validated on read: name pattern, 5 categories, weights 100-900 | Works | 10/10 checks. `hadrian_typography` [] -> {"fontFamily":{"mode":"google","google":"Audit Weights Font","googleWeights":[400,700],"stack":"'Audit Weights Font', system-ui, sans-serif"}} |
| AD-28 | General, Buttons, Forms, Elements, Navigation save | Only valid keys or in-range numbers that differ from default; out-of-range silently resets; legacy nav values move out of `_layout_vars` | Works | 37/37 checks. `hadrian_buttons` null -> {"sizes":{"--btn-radius":"sm"},"variants":{"primary":{"bg":"danger"}}}; `hadrian_elements` null -> {"sizes":{"--card-radius":"none","--card-pad":32}} |
| AD-29 | Custom CSS save | Stored raw in `<tpl>_custom_css` | Works | 12/12 checks. `hadrian_custom_css` null -> body{outline:3px solid rgb(1,2,3)}; `hadrian_custom_css` null -> body > .audit-x{outline:2px solid rgb(4,5,6)} .audit-x::after{content:"a&b"} |

## AD-D Customizer

| ID | Feature | Promises | Verdict | Proof |
|---|---|---|---|---|
| AD-30 | Open | Frame starts from saved state; older unsaved state dropped | Works | 12/12 checks |
| AD-31 | Preview | Posted state reduced to existing styles, layouts, valid colour diffs; held in session; 400 with no state, 409 with no template | Works (part not testable here) | 19/19 checks. `posted -> held state` {"style":"nope","theme":"dark","colors":{"light":{"--color-accent":"#12ab34","--evil-token":"#ffffff","--color-bg":"javascript:alert(1)","--color-surface":"#FFFFFF","--color-border":"red"},"dark":". skipped: Dead path in the admin: AddonHelper::getTemplate() falls back to the Hadrian template under ADMINAREA, so templateOrRefuse() can only refuse if the theme folder itself is gone, which would wreck the i |
| AD-32 | Preview gate | Needs a signed-in admin and the session token in the URL; links and GET forms carry the token | Works | 11/11 checks. `links and forms` null -> {"same":"http://localhost:8088/cart.php?a=view&hadrian_customize=8e56eeca519022536b5dd11a0a1442de","outside":"https://example.invalid/page","getForm":true,"postForm":false,"realHref":"http://loc |
| AD-33 | Save | `_active_style`, colours for both scopes, audience picks, area picks only in area mode | Works | 21/21 checks. `hadrian_layout_mode` null -> area; `hadrian_active_layout_*` {"hadrian_active_layout_main-menu_client":"sidebar","hadrian_active_layout_main-menu_guest":"sidebar"} -> {"hadrian_active_layout_footer_area_client":"extende |
| AD-34 | Discard, device widths, light/dark scope, area-mode picks | Client-side controls | Works | 25/25 checks |

## AD-E Layouts screen

| ID | Feature | Promises | Verdict | Proof |
|---|---|---|---|---|
| AD-35 | By visitor / by area | First switch to area seeds each area from the visitor picks; switching back and forth loses nothing | Works | 18/18 checks. `layout_mode` null -> area; `main-menu pointers` {"hadrian_active_layout_main-menu_client":"rail","hadrian_active_layout_main-menu_guest":"top"} -> {"hadrian_active_layout_main-menu_area_client":"rail","hadrian_active_la |
| AD-36 | Activate per audience or area | Layout must be valid; an unknown audience mirrors to the legacy key and both audience keys | Works | 14/14 checks. `guest, client pointers` ["sidebar","sidebar"] -> ["top","sidebar"]; `main-menu pointers` {"hadrian_active_layout_main-menu_client":"sidebar","hadrian_active_layout_main-menu_guest":"sidebar"} -> {"hadrian_active_layout_ |
| AD-37 | Per-layout options | `layout_opts` value must be one of the declared choices | Works | 12/12 checks. `hadrian_layout_opts_main-menu_sidebar` null -> {"side":"right"}; `hadrian_layout_opts_main-menu_sidebar` {"side":"right"} -> {"side":"right","align":"left"} |
| AD-38 | Header and footer flags | Only layout flags accepted; redirects back to the right tab | Works | 64/64 checks. `affixed_navigation` 0 -> 1; `affixed_navigation (second save)` 1 -> 0 |
| AD-39 | Content width | boxed or full; old "fluid" reads as full | Works | 9/9 checks. `content_width` boxed -> full |
| AD-40 | Max width and side padding | Merged into `_layout_vars`; default or out-of-range removes it; server accepts 0-4000 while the HTML says 640-2400 and 0-160 | Works | 14/14 checks. `hadrian_layout_vars` null -> {"--content-max-width":1400}; `hadrian_layout_vars` {"--content-max-width":1400} -> {"--content-max-width":1400,"--content-pad-x":24} |
| AD-41 | Custom layout folders | Found automatically; bad folders rejected with a reason; `dataLayout` validated; reserved names blocked; "Custom" badge | Works | 16/16 checks |
| AD-42 | Live preview link | `?preview=1&layout=<dataLayout>` on main-menu cards | Works | 10/10 checks |

## AD-F Pages screen

| ID | Feature | Promises | Verdict | Proof |
|---|---|---|---|---|
| AD-43 | List self-heal | Opening the list rebuilds page and layout caches, runs migrations and `PageRegistry::sync` (seeds rows, imports legacy settings) | Works | 10/10 checks. `hadrian_pages login row` null -> {"variant":"split","indexing":"disallow","seo_title":"Legacy audit title"} |
| AD-44 | List UI | Group tabs, search, system-page toggle, SEO, indexing and visibility badges, Open link, "Replaced by" notes | Works | 16/16 checks |
| AD-45 | Variant pick | Only variants on disk; a stale stored variant falls back to default | Works | 13/13 checks. `variant` removed-variant -> default; `variant` default -> split |
| AD-46 | Template options save | Page and variant options merged as `key__variant`; options not on the form carried through; types coerced; selects allow-listed | Works | 12/12 checks. `min_visible_rows__minimal` 7abc -> 7; `settings.options` {"bcn_field_style__beacon":"solid","info_right":false} -> {"full_page":false,"show_logo":true,"info_right":true,"bcn_field_style__beacon":"solid","bcn_field_colou |
| AD-47 | Section options builder | Scoped to its variant; colour swatches resolved | Works | 16/16 checks. `min_sections__minimal`  -> tickets:1/2::green_tint,services:1/1,domains:off,invoices:1/2,announcements:off,domainreg:off,profile:off |
| AD-48 | Visibility setting | public, auth, disabled allow-listed; offered on exempt pages where it does nothing | Works | 17/17 checks. `visibility` public -> auth |
| AD-49 | Sub-nav, area, controls placement per page | Allow-listed; empty area means automatic | Works | 26/26 checks. `settings.area`  -> client; `settings.svclayout` inherit -> outside |
| AD-50 | Indexing and public URL | Indexing allow-listed; URL trimmed to 255, nothing else; Save refreshes the sitemap | Works | 15/15 checks. `indexing` inherit -> disallow; `url` contact.php -> audit-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx |
| AD-51 | SEO title and description | Per effective language; capped at 200 and 400 characters; empty map stored as null | Works | 12/12 checks. `seo_title, seo_description` [{"arabic":"お問い合わせページの説明文です。検索結果に表示されます。お問い合わせページの説明文です。検索結果に表示されます。お問い合わせページの説明文です。検索結果に表示されます。お問い合わせページの説明文です。検索結果に表示されます。お問い合わせページの説明文です。検索結果に表示されます。お問い合わせページの説明文です。検索結果に表示されます。お問い合わせページの説 |
| AD-52 | Social image | Media picker, 500 characters, counted by MediaUsage | Works | 8/8 checks. `seo_image`  -> http://localhost:8088/templates/hadrian/assets/img/media/audit-social-image.png |
| AD-53 | Per-page layout override | Must be a valid layout; empty inherits | Works | 8/8 checks. `settings.layout_overrides` {"main-menu":null,"footer":null} -> {"main-menu":"top","footer":"default"} |
| AD-54 | Extension pages | Rows and panels from modules; module-owned columns synced; rows of pages that are gone deleted, but never for a module whose listing failed | Works | 10/10 checks |

## AD-G Sitemap

| ID | Feature | Promises | Verdict | Proof |
|---|---|---|---|---|
| AD-55 | Save and generate | Six booleans plus frequency into `sitemap_settings`, then regenerate | Works | 55/55 checks. `sitemap_settings.announcements` true -> false; `sitemap_settings.announcements (set back)` false -> true |
| AD-56 | Generate now | Writes `sitemap.xml`, then `robots.txt` between markers, keeping hand-written lines; not atomic | Works | 15/15 checks. `sitemap.xml sha1, mtime` {"exists":true,"size":422,"sha1":"0f679938bd00858b2da791bb10b642d37bfcbfe1","mtime":1795790797} -> {"exists":true,"size":5164,"sha1":"c2be15ff4b788c552e22821f6f510024fd5024ba","mtime":1795794400 |
| AD-57 | Content rules | Eligible pages, routed announcement and KB addresses, hidden, private and translation rows left out, Disallow lines with `$` | Works | 26/26 checks. `hadrian_pages.indexing (knowledgebase)` inherit -> disallow |
| AD-58 | Auto-refresh triggers | Page save, module publish, AnnouncementAdd/Edit, daily cron; only when configured and content changed | Works | 14/14 checks. `hadrian_pages.indexing (contact)` inherit -> disallow; `sitemap.xml sha1, mtime` {"exists":true,"size":5164,"sha1":"c2be15ff4b788c552e22821f6f510024fd5024ba","mtime":1795790838} -> {"exists":true,"size":5054,"sha1":"74a |
| AD-59 | Preview, last written, root-not-writable banner | Shown on the screen | Works | 12/12 checks |

## AD-H Menu

| ID | Feature | Promises | Verdict | Proof |
|---|---|---|---|---|
| AD-60 | Self-heal on every Menu request | Migrations, preset seeder, one-time custom-link conversion; a preset the admin renamed or deleted is not re-created | Works | 18/18 checks. `menu name` Guest Main Menu -> Guest Main Menu (audit); `Footer Secondary Menu items, active` {"items":0,"active":0} -> {"items":5,"active":1} |
| AD-61 | Menu list | Four locations, one table each, area badges | Works | 19/19 checks |
| AD-62 | New menu | Blank inactive menu in that location, opens the editor | Works | 6/6 checks. `footer menus` 1 -> 2 |
| AD-63 | Delete | GET `confirm=1` with token; items cascade; area picks forgotten; no UI link | Works | 11/11 checks. `hadrian_menu_items rows for the menu` 1 -> 0 |
| AD-64 | Re-seed, force re-sync, reset WHMCS defaults | Re-seed fills missing or empty presets, a renamed one coming back switched off when its place has a live menu; force wipes and reseeds; reset rebuilds Defaults and Footer Secondary | Works | 29/29 checks. `menus` 6 -> 7; `Guest Main Menu — WHMCS Defaults items` 23 -> 24 |
| AD-65 | Menus by area | Menu must exist in that location; 0 means by visitor | Works | 10/10 checks. `menus_by_area` {} -> {"main":{"website":28}} |
| AD-66 | Editor save | Activating turns off peers in the slot; every item deleted and recreated without a transaction; refused near `max_input_vars` (warned first) or with an empty list; a blank name keeps the old one; audience limited to client, guest, all | Works | 17/17 checks. `main menus active` {"Client Main Menu":1,"Client Main Menu — WHMCS Defaults":0,"Guest Main Menu":1,"Guest Main Menu — WHMCS Defaults":0} -> {"Client Main Menu":0,"Client Main Menu — WHMCS Defaults":0,"Guest Main Menu":1 |
| AD-67 | Item editing | 10 item types, page picker, translations, 34 icons, per-item audience and layouts, position, reorder | Works | 20/20 checks. `Footer Secondary order` ["Privacy Policy","Terms of Use","Cookie Policy","Sitemap","Accessibility","Audit Link A"] -> ["Privacy Policy","Terms of Use","Cookie Policy","Audit Link Renamed","Sitemap","Accessibility"]; `Au |
| AD-68 | Item styling fields | Description (tooltip; second line in the mega menu), badge, text transform, hide label (only beside an icon) and CSS class are shown wherever the menu renders | Works | 3/3 checks |
| AD-69 | Diagnose | GET JSON dump of a menu | Works | 6/6 checks |

## AD-I Branding

| ID | Feature | Promises | Verdict | Proof |
|---|---|---|---|---|
| AD-70 | Upload a slot | Five slots; MIME sniffed and `getimagesize` checked; SVG scanned; caps 2 MB, 1 MB, 256 KB; random name; old file deleted after the new one lands | Works | 97/97 checks. `logo_light` 22291bcec7ad572e774d21c259afacb8.png -> 92147f5f3c39787524f4fed0655cdfa6.png; `favicon`  -> 40fcfa89b700484b98009b2883b59645.png |
| AD-71 | Remove | Unknown field rejected; file deleted, setting cleared | Works | 10/10 checks. `favicon` 0935b7ac3c256d1c7692f73bb8fbd621.png ->  |
| AD-72 | Form fallback | Multi-file post; flash `saved`, `partial`, `errors`, `noop` | Works | 15/15 checks. `logo_light, favicon` ["",""] -> ["132df89199ff659f6aee5f027d72e15b.png","6bcabe29207f8859110660714cd98c61.png"] |
| AD-73 | Brand info | Description up to 280 characters; social links must be http(s); blank clears | Works | 22/22 checks. `footer_description, footer_social_x, footer_social_github` {"d":"","x":"","gh":""} -> {"d":"Audit hosting on fast hardware and honest prices.","x":"https://x.com/hadrian-audit","gh":"https://github.com/hadrian-audit"};  |

## AD-J Media

| ID | Feature | Promises | Verdict | Proof |
|---|---|---|---|---|
| AD-74 | Upload | Raster only, 5 MB, 50 MP, at most 500 files; label from filename; optimised if the switch is on | Works | 32/32 checks. `manifest entry` undefined -> {"w":1400,"h":900,"skipOptimize":0,"label":"Audit Hero Photo","at":1795794978}; `library count line` 1 of 500 images  ·  41 KB  ·  1 unused -> 2 of 500 images  ·  105 KB  ·  2 unused  ·  97  |
| AD-75 | Optimise and restore | Skips GIF, animated, lossless, non-sRGB; longest edge 2560; kept only at 95% or less of the original; original kept in `.originals`; 8-second batches | Works | 30/30 checks. `88e74c834330f95323b5262d3b1724fa.jpg bytes` 164109 -> 65019; `media_optimize_max_edge` null -> 1600 |
| AD-76 | Usage and delete | Scans pages, settings, menus, module sources; an image in use is refused unless forced | Works | 16/16 checks. `hadrian_pages.user-invite-accept.seo_image`  -> http://localhost:8088/templates/hadrian/assets/img/media/7141672e15d1e9d86c7b83d12527a7ea.png |
| AD-77 | Rename, filters, sort, bulk, optimise switch | Label cleaned to 80 characters | Works | 27/27 checks. `manifest label` Audit Rename Me -> Audit Renamed xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx |
| AD-78 | Media guards | POST, admin, token, `X-Requested-With`, known collection | Not in this audit | Request guards (POST, admin, token, X-Requested-With). Security checks, left to admin.spec and admin-uploads.spec in the pre-push gate. |

## AD-K Extensions, Tools, Templates, Licence

| ID | Feature | Promises | Verdict | Proof |
|---|---|---|---|---|
| AD-79 | Extensions page | Theme extensions from theme.json and registered modules | Works | 7/7 checks |
| AD-80 | Tools: clear template cache | Empties the admin's own compile folder only | Works | 6/6 checks. `files in temp/hadrian-smarty` 32 -> 6 |
| AD-81 | Tools: rebuild discovery | Rebuilds page and layout caches, reports counts | Works | 6/6 checks. `hadrian_pages_discovered (version, count, generated_at)` ["0-audit",1,"2000-01-01T00:00:00+00:00"] -> ["1.1.248",103,"2026-11-27T15:59:32+00:00"]; `hadrian_layouts_discovered generated_at` 2026-11-27T14:43:59+00:00 -> 2 |
| AD-82 | Tools: refresh licence | Calls the dormant `Template\License`, a no-op in dev mode with a separate key | Works | 5/5 checks |
| AD-83 | Templates list and show | `canActivate` per template; `show` opens only a template from the list; an unknown name gets a plain error | Works | 17/17 checks |
| AD-84 | Licence page | Save and check; Active, No key, Expired, Revoked, Unverified, Not active; "Reissued" falls to Not active | Works (part not testable here) | 7/7 checks. `hadrian_license_key` null -> . skipped: The licence-server budget for this run (2 calls) was spent by a-setup.audit.mjs (AD-07). |

## AD-L Cross-cutting

| ID | Feature | Promises | Verdict | Proof |
|---|---|---|---|---|
| AD-85 | CSRF | Every POST and the GET routes in `GET_WRITES` need the WHMCS token; JSON routes get a JSON 403, others the "Not saved" page | Not in this audit | CSRF on every POST and GET_WRITES route. Covered by admin-csrf.spec in the pre-push gate (16 POST and 4 GET routes). |
| AD-86 | AJAX guard | POST only, signed-in admin, token; JSON refusals | Not in this audit | AJAX guard. Covered by admin.spec and admin-uploads.spec in the pre-push gate. |
| AD-87 | Licence state mapping | No key; Active; Expired and Suspended warn; Unreachable, Unknown, Error warn and aren't cached; Banned, Cancelled, Revoked fail | Works | 16/16 checks |
| AD-88 | Revert to `six` and dashboard banner | `License::deactivateTemplate` and the `adminHooks.php` guard exist but never run; `HOSTNODES_ENFORCE` is not in repo code | Not tested | 9/9 checks. skipped: Dead code path: nothing in the repo runs it (proven by reading the code above). Exercising it would mean editing product code. |
| AD-89 | Migrations and self-heal | Idempotent Migrator; runs on the Menu, Pages and Sitemap screens and the navbar hook; footer menus re-seeded on client pages when none exist | Works | 36/36 checks. `hadrian_migrations.MenusAddFooterSecondary` null -> {"name":"MenusAddFooterSecondary","ran_at":"2026-11-27 16:00:28"}; `hadrian_migrations.MenusAddFooterSecondary` null -> {"name":"MenusAddFooterSecondary","ran_at":"202 |
| AD-90 | Deactivate with Database Clear | Rolls back migrations; deletes only `Hadrian-%` config rows | Not in this audit | Deactivate with Database Clear wipes the install; not run against the shared local site. |
| AD-91 | Front-end payload | `$hadrian.addonSettings` (the cart reads `op_*`, `free_label`), `mtBrand`, menus, dark-mode values | Works | 9/9 checks. `free_label` 0 -> 1; `op_root_pw_strength` 0 -> 1 |
| AD-92 | Colour output scope | Light block scoped to `html:not([data-theme=dark]):not([data-palette])`; legacy keys when a row is empty | Works | 10/10 checks. `hadrian_colors_default_light / _dark` null -> {"light":{"--color-accent":"#12ab34","--color-text-primary":"#101112"},"dark":[]} |
| AD-93 | Admin dark mode | `localStorage` `hadrian-admin-theme`, no flash on load | Works | 8/8 checks. `localStorage hadrian-admin-theme` null -> dark; `localStorage hadrian-admin-theme (second click)` dark -> light |
| AD-94 | Doc links and tooltips | Every "Learn more" anchor exists in the built docs; every setting has a docs heading | Works | 7/7 checks |
| AD-95 | Addons flyout and admin CSS | Inlined in the admin head; flyout sections match the top nav | Works | 9/9 checks |
| AD-96 | Bridge for other modules | `Extensions`, `ExtensionPages`, `PageRegistry::syncExtensionPages`, `MediaUsage::register`, `SiteLook`, `LocaleHelper`, `Menu::pick`, `TreeRenderer::buildFlatList`, `Settings::getValue` | Works | 10/10 checks |
| AD-97 | Integrity hashes | The real hash table exists only in builds; a mismatch returns 503 on every page | Not in this audit | Integrity hashes exist only in release builds; check-release-package covers the table. |
| AD-98 | `systpl` and `templateName` | An unvalidated `systpl` slug reaches `new Template()`, which requires `core/<slug>.php`; needs a negative test. `templateName` (Templates screen) is limited to listed templates | Not in this audit | The systpl slug is a security probe, left out of this functional audit. templateName on the Templates screen is limited to listed templates since 2026-11-27 (AD-83). |

