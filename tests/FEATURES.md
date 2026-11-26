# Hadrian feature inventory

Every feature the five products in this repo ship, one row each, with what a test has to check and which test checks it today. The IDs are stable, so a spec or a ticket can say which rows it covers.

Built on 2026-11-25 from the working tree of `builder/editor-redesign`, uncommitted builder and addon work included. It was assembled by reading the code, the customer docs in `hadrian-documentation/content/client-theme/` and everything under `tests/`. When code changes a row, change the row.

| Prefix | Product | Folder |
|---|---|---|
| TH | Client-area theme | `hadrian/templates/hadrian/` |
| AD | Admin addon | `hadrian/modules/addons/Hadrian/` |
| OF | Order form | `hadrian_cart/` |
| PB | Page Builder module | `hadrian_builder/modules/addons/HadrianBuilder/` |
| EM | Email Templates module | `hadrian_email/modules/addons/HadrianEmail/` |

## Reading the tables

The Coverage column says how much of the feature a test exercises today:

| Coverage | Meaning |
|---|---|
| Tested | A test performs the feature and checks the result. |
| Partial | Some paths or setting values are checked; the Tests cell says which are not. |
| Renders | A test only loads the page: HTTP 200, the right `data-tpl`, the oracles, no JS errors. |
| Static | Only a static or unit checker covers it. Nothing is requested from the site. |
| None | Nothing exercises it. |

`settings.spec` and `theme-settings.spec` write most settings straight into the database through `tests/php/settings.php` and then checks what the site does. Rows tested that way say **DB-set**: the effect is tested, but the admin Save button that stores the value is not.

Path shorthands: `T/` = `hadrian/templates/hadrian/`, `P/` = `T/core/pages/`, `A/` = `hadrian/modules/addons/Hadrian/`, `cart/` = `hadrian_cart/`, `PB/` and `EM/` = the module folders above. Specs live in `tests/e2e/`, checkers in `tests/static/`, PHP drivers in `tests/php/`.

The products' own tests run with `node tests/run.mjs`; see [tests/README.md](README.md) for the tiers and personas (`guest`, `full`, `empty`, `suspended`, `admin`).

## Coverage at a glance

| Product | Features | Tested | Partial | Renders | Static | None |
|---|---|---|---|---|---|---|
| Client-area theme (TH) | 124 | 96 | 14 | 0 | 6 | 8 |
| Admin addon (AD) | 98 | 21 | 25 | 5 | 16 | 31 |
| Order form (OF) | 95 | 67 | 18 | 1 | 1 | 8 |
| Page Builder (PB) | 68 | 24 | 18 | 1 | 12 | 13 |
| Email Templates (EM) | 53 | 20 | 16 | 0 | 7 | 10 |
| All | 438 | 228 | 91 | 7 | 42 | 70 |

## Bugs found while building this list

These turned up while mapping features to code. Write the test first, run it against today's code, and watch it fail.

### Confirmed (code path traced end to end)

1. **EM: unpublished edits to a published email went out to customers. Fixed 2026-11-25.** Saving an email that was already published wrote its one `doc` column and left the status at `published` (`EM/src/AdminController.php`, `apiSave`). `Publisher::republishAll()` compiled every published design from that saved `doc`. It runs on a plain visit to the Email overview whenever `Takeover::isStale()` is true (brand colours, logo or layout changed, or the year rolled over), and again on every Appearance save. Publish now also keeps the document it published, in `published_doc`, and the recompile uses that. Designs published before the column existed are left alone by the recompile until they're published once. Rows EM-11, EM-13, EM-38.
2. **EM: the inbox preview line changed as soon as a draft was saved. Fixed 2026-11-25.** `SendHook::preheader()` read the preheader from the saved `doc`. It now reads `published_doc`. Row EM-22.
3. **PB + AD: one database error on the builder's page list deleted the Pages settings of every built page. Fixed 2026-11-25.** `Page::forSite()` caught any error and returned `[]`. The builder was still registered, so `PageRegistry::syncExtensionPages()` saw no `built-*` pages and deleted their rows, with the SEO, indexing and visibility the admin set. A provider that threw did the same. Now `ExtensionPages` remembers which modules failed to list their pages, and the sync deletes rows only for modules that answered. It also leaves the stand-in signature, and so the sitemap, alone while any module has failed. `forSite()` answers `[]` only for a table that doesn't exist yet, and throws otherwise. Rows AD-54, PB-08.
4. **AD: long SEO text in a non-Latin script could wipe a page's SEO map. Fixed 2026-11-25.** `PagesController` cut titles at 200 bytes and descriptions at 400 bytes with `substr`. A cut inside a multibyte character left invalid UTF-8, the plain `json_encode` in `Page::upsert` returned `false`, and the column was stored as `"0"`. The same byte cut applied to the social image, the URL and every text page option, where it could cost a page its whole settings blob. All five now cut by characters. `Page::upsert` substitutes invalid UTF-8 and stops the save rather than store a failed encode. The editor's counters also counted bytes on first load ("180/64" for 60 Japanese characters); they count characters now. Row AD-51.
5. **AD: renaming an active preset menu brought the preset back and put it live. Fixed 2026-11-25.** `Seeder::existingMenu()` finds presets by name, so after a rename the next visit to the Menu screen created a fresh active copy. `Menu::pick()` takes the active menu with the highest id, so visitors got the preset instead of the admin's menu. The same happened after deleting a preset, and from the client-side footer top-ups, which call the same seeder. The seeder now records the presets it made (`hadrian_menu_presets_seeded`) and never re-creates one on its own. Only **Re-seed presets** or **Force re-sync** bring it back. A re-created preset also starts switched off when its place already has a live menu. Rows AD-60, AD-64.
6. **Tests: two static checkers ran without the theme's CSS. Fixed 2026-11-25.** `check-colors-scope-leak.php` and `check-login-styles.php` read `apple-theme.css` and `apple-layout.css`, which were renamed to `core-*` in `23959a02` (2026-08-21). From then on, every preview they wrote carried no theme rules. They now read the `core-*` files and stop if a sheet is missing. `e2e/colour-scope.spec.mjs` measures the scope-leak panes, so that check can fail on its own. Measured with the real CSS, the colour scoping is correct; the product had no bug here. Rows TH-58, TH-76, AD-92.
7. **OF: the configure step broke when WHMCS lived in a subfolder. Fixed 2026-11-25.** `cart/configureproduct.tpl` called `/cart.php` from the site root in four places (Review cart, its redirect, and the promo check twice) instead of using `WEB_ROOT`. `cart/configureproductdomain.tpl`'s own-domain fallback, used when WHMCS's script hasn't loaded, posted to `/index.php/domain/check` because its base, `window.WHMCS_BASE_URL`, was never set. Both now build the address from `WEB_ROOT` and `whmcsBaseUrl`, which `header.tpl` sets on every order-form page. The local stack runs at the root, so only the static check can see a regression. Rows OF-21, OF-22, OF-30.
8. **TH: the homepage hero title and subtitle set in Pages never showed. Fixed 2026-11-25.** `P/homepage/default/default.tpl` read `$hadrian.pages.homepage.config.*`, which the addon never builds, so the theme's own heading always won. It reads `.options.*` now and prints the two strings as text, so markup typed into them shows as typed. Classic (`portal`) reads both the same way. The category-rows switch reads `.options.categoryRows` too, but `page.php` doesn't declare it, so Pages still can't set it. Row TH-75.

Each open bug has a test that asserts the right behaviour and fails today. It's marked as a known bug, so the run reports it without blocking the gate, and the run fails once the bug is fixed until the marker is removed ([README](README.md), "Known bugs").

| Bug | Test | Today |
|---|---|---|
| 1 | `php/email-live.php` "a saved edit stays a draft until it is published" | Fixed; passes |
| 2 | same | Fixed; passes |
| 3 | `static/test-extension-page-rows.php` | Fixed; passes (17 checks) |
| 4 | `e2e/known-bugs.spec.mjs` "long SEO text in Japanese survives Save in Pages" | Fixed; passes |
| 5 | `e2e/known-bugs.spec.mjs` "a renamed preset menu stays the menu visitors see" | Fixed; passes |
| 6 | `e2e/colour-scope.spec.mjs` | Fixed; passes |
| 7 | `static/check-root-paths.mjs` | Fixed; passes, and fails any new root path |
| 8 | `e2e/known-bugs.spec.mjs` "the homepage hero shows the title and subtitle set in Pages" | Fixed; passes |

### Found by the client-area and order tests (2026-11-25)

Each open one has a test in the spec named below, marked as a known bug, that asserts the right behaviour and fails today. A fixed one keeps its test, which now passes.

| Bug | Row | What's wrong | Where | Test |
|---|---|---|---|---|
| 9 | TH-12, OF-91 | The canonical URL keeps every parameter after the first one. `REQUEST_URI` arrives HTML-escaped, so they come through as `amp;language=...` and aren't stripped. Every cart URL has two or more parameters, so every cart canonical is wrong, and hreflang carries `language` twice. | `A/src/Service/Hooks.php:3203-3207` | client-area.spec, order.spec |
| 10 | TH-12 | The canonical URL percent-encodes WHMCS routes: `rp=%2Fknowledgebase%2F1%2Fx.html`. | `Hooks.php:3222` (`http_build_query`) | client-area.spec |
| 11 | TH-27, TH-107 | Knowledgebase search finds nothing. The sidebar box and both KB pages send a GET to `knowledgebase.php?search=`, which WHMCS 301s to `/knowledgebase` and drops the query. Stock posts to `routePath('knowledgebase-search')`. | `partials/sidebar.tpl:144`, `P/knowledgebase/default/default.tpl:80`, `P/knowledgebasecat/default/default.tpl:66` | client-area.spec |
| 12 | TH-29 | Open sidebar groups are never remembered. The inline binder sets `data-mt-bound` first, so `initSidebarGroups` skips the handler that writes `hn.sidebarGroups`. | `sidebar.tpl:201-221`, `core-layout.js:638` | client-area.spec |
| 13 | TH-36 | Every `clientarea.php` page shows "Client Area" in the topbar crumb, not "My Invoices" and the rest. `applyPageTitle` overwrites the crumb with `$pagetitle`. | `core-layout.js:819` | client-area.spec |
| 14 | TH-37 | Nothing in the sidebar is ever highlighted. `applyActiveNav` looks for `data-nav="invoices"`; sidebar items carry `data-nav="mt-<id>"`. | `core-layout.js:802`, `sidebar.tpl:93`, `A/src/Menu/TreeRenderer.php:218` | client-area.spec |
| 15 | TH-43, OF-93 | Preview-only URL parameters work on the live site: `?palette=rose` recolours the accent and `?subnav=off` hides the side column. In the cart, `?plan=b` hides the shipped plan design and `?data=empty` hides the transfer form. | `T/header.tpl:131-227` (`?data` at 183-186, `?plan` at 206-211) | client-area.spec, order.spec |
| 16 | TH-71 | WHMCS error pages link `theme-rtl.css`, which 404s for an RTL language. They also link `theme.css`, which `hadrian/.gitignore` keeps out of a release, and `site.css`, which doesn't exist. | `T/includes/common/head.tpl:2,7` | client-area.spec |
| 17 | TH-73 | The dashboard's register-domain box loses the name. It posts it as `search`; the cart reads `query`. | `P/clientareahome/default/default.tpl:497-501` | client-area.spec |
| 18 | TH-79, TH-83 | The services list can't be sorted. The visible column titles have no handler, and the working DataTables header is hidden at 0px. | `P/clientareaproducts/default/default.tpl:129-132,149-152` | client-area.spec |
| 19 | TH-79, TH-96 | Invoices sort by nothing on Amount and Due Date. The template reads `_sort_amount` and `_sort_due_raw`, which WHMCS's rows don't have. | `P/clientareainvoices/default/default.tpl:162-164` | client-area.spec |
| 20 | TH-79, TH-96, TH-106 | Every status tab on invoices, quotes and tickets shows "No matching records found". The status cell's `data-order` holds the raw `<span>` HTML, and the tab filters on it. | `dynamic-tables.js:345`; `clientareainvoices :175`, `clientareaquotes :160`, `supporttickets :155` | client-area.spec |
| 21 | TH-79, TH-103 | Email history stops at 10 messages. Without a `theme.yaml` setting `serverSidePagination: false`, WHMCS sends 10 rows and the client-side pager sees only those. | no `T/theme.yaml` | client-area.spec |
| 22 | TH-93 | Glue records can't be registered. The forms post to `?action=registerns`, which redirects to the dashboard; the self-links on the EPP and domain-details pages do the same. | `P/clientareadomainregisterns/default/default.tpl:27,50,77,104`, `clientareadomaingetepp :68`, `clientareadomaindetails :409,415` | client-area.spec |
| 23 | TH-97 | Mass pay by bank transfer spins on "Please wait" for ever. `forwardpage.tpl` only submits a form found in `$code`, and bank transfer has none. Stock adds a fallback form to `viewinvoice.php`. | `T/forwardpage.tpl:30-37` | client-area.spec |
| 24 | TH-98 | "Amount due" prints `{$total}`, so after a $5 credit it still says $12.50 instead of the $7.50 balance. | `P/viewinvoice/default/default.tpl:86-87,289-290` | client-area.spec |
| 25 | TH-103 | Opening an email replaces the list with `viewemail.php`, a bare page with no navigation. Stock opens a popup. | `P/clientareaemails/default/default.tpl:72-77`, `dynamic-tables.js` row click | client-area.spec |
| 26 | TH-104 | The ticket form never asks for knowledgebase suggestions, though `SupportTicketKBSuggestions` is on and `getkbarticles` answers. | `P/supportticketsubmit-steptwo/` | client-area.spec |
| 27 | TH-106 | Ticket feedback can't be sent. The form posts to `ticketfeedback.php`, which doesn't exist. Stock posts to `viewticket.php`. | `P/ticketfeedback/default/default.tpl:91` | client-area.spec |
| 28 | TH-107 | The announcements RSS links 301 to the HTML page. The feed is at `rp=/announcements/rss`. | `P/announcements/default/default.tpl:64,82`, `viewannouncement :78` | client-area.spec |
| 29 | TH-111 | Account Details never prints `$successful` or `$errormessage`. A save gets no confirmation and a refused one fails silently. | `P/clientareadetails/default/default.tpl` | client-area.spec |
| 30 | TH-111 | Email preferences are never saved. The checkboxes are hardcoded and post `emailoptout_*`; WHMCS reads `email_preferences[...]`. | `P/clientareadetails/default/default.tpl:160-185` | client-area.spec |
| 31 | TH-81, TH-111 | Adding a contact creates nothing. The form posts to `account-contacts-save` with `contactid=new`; WHMCS answers "Contact updated successfully!". | `P/account-contacts-new/default/default.tpl:63` | client-area.spec |
| 32 | TH-81 | Re-saving a contact corrupts its phone number: `+44.7400123456` becomes `+44.07400 123456`. The phone input submits the national number with its trunk prefix. | `P/account-contacts-manage/default/default.tpl:232`, `account-contacts-new :200` | client-area.spec |
| 33 | TH-111 | Change Password does nothing. It posts to `clientarea.php?action=changepw`, which WHMCS 302s without processing; the old password still works. Stock posts to `routePath('user-password')`. | `P/user-password/default/default.tpl:55` | client-area.spec |
| 34 | TH-115 | A customer who unsubscribed can't join the mailing list again. Account Details has no `marketingoptin` control, yet the opt-out page sends them there to do it. | `P/clientareadetails/default/default.tpl` | client-area.spec |
| 35 | TH-74 | Bento's "Identity card beside the greeting" (`bnt_account`) does nothing. Pages offers it, but `bento.tpl` only assigns `$bnAcct` and nothing reads it since the identity card moved into the welcome band. | `P/clientareahome/bento/bento.php:101`, `bento.tpl:53-54` | theme-settings.spec |
| 36 | TH-75 | **Fixed 2026-11-25.** The five homepage show/hide switches (`show_domain_search`, `show_products`, `show_features`, `show_news`, `show_cta`) were offered in Pages and read by neither variant. Modern now reads all five, with `isset()` because Pages stores "off" as a real `false`. Turning the tiles off also drops the hero's "See how it works" link to them. Classic reads `show_domain_search`, its only one of the five sections. Both hide the domain search when WHMCS offers neither registration nor transfers, as the tooltip always said. | `P/homepage/{default,portal}/` | theme-settings.spec (7 tests), passing |
| 37 | OF-30 | **Fixed 2026-11-25.** "Use my own domain" sent an empty CSRF token: the script read `meta[name=csrf-token]`, which nothing prints, so `/domain/check` answered 302 and the fail handler submitted anyway. An invalid name like `x y.com` got into the cart (every cart page then returned 500 until it was emptied), a signed-in customer was signed out, and the cart was reset. The check now sends `window.csrfToken`, and since it adds the plan itself the page goes to `a=confproduct&i=<num>` instead of submitting the form. A failed check shows an error instead of submitting. | `cart/configureproductdomain.tpl` | order.spec (3 tests), passing |
| 38 | OF-31, OF-34 | **Fixed 2026-11-25.** Register and transfer through the product submitted with no check, so `x y` under Register went into the cart and every cart page returned 500. They now ask `/domain/check` first, as stock does. Register needs a valid, free name and transfer a valid, registered one; otherwise WHMCS's own message shows in the panel. The form posts the name WHMCS returned. Stock prints no `$errormessage` on this page either. | `cart/configureproductdomain.tpl` | order.spec, passing; plus taken-name and unregistered-transfer tests |
| 39 | OF-33 | **Fixed 2026-11-25.** "Use a domain already in cart" added the plan with no domain: the form posted `domainoption=incart&incartdomain=...`, which WHMCS ignores. It now goes through `/domain/check` with `type=incart`, like stock, which attaches the domain. | `cart/configureproductdomain.tpl` | order.spec, passing |
| 40 | OF-13 | The "Included" badge for an own domain never shows. It tests `$domainoption`, which is empty on the configure step. | `cart/configureproduct.tpl:143` | order.spec |
| 41 | OF-16 | The quantity slider is 0px wide, so "Extra IPv4 addresses" can't be set. It mounts in `.cp-opt-control`, which has no width. | `cart/configureproduct.tpl:442-468`, `cart/css/style.min.css:2605` | order.spec |
| 42 | OF-12 | Picking a category in the collapsed select throws: `selectChangeNavigate` lives only in six and twenty-one's `whmcs.js`. `common.tpl:30-31` says `scripts.min.js` provides it; it doesn't. | `cart/sidebar-categories-selector.tpl:43` | order.spec |
| 43 | OF-12 | The collapsed category selects also show at desktop width on six pages, so Categories and Actions appear twice at 1280px. No CSS hides `.sidebar-collapsed` above 880px. | `cart/addons.tpl:30`, `complete.tpl:23`, `error.tpl:34`, `fraudcheck.tpl:34`, `domain-renewals.tpl:76`, `service-renewals.tpl:67` | order.spec |
| 44 | OF-43 | The TLD category filters do nothing. They are `<a href="#">` with their handler in twenty-one's `scripts.js`, and with `<base href>` a click goes to the site root. | `cart/domainregister.tpl:486,603` | order.spec |
| 45 | OF-62, OF-74 | A mistyped card number shows no error, and the form posts anyway. `validateCheckoutCreditCardInput` calls `jQuery.fn.setInputError` and `showInputError`, which nothing loads; the checkout stubs only cover `WHMCS.payment`. | `cart/checkout.tpl:137-174` | order.spec |
| 46 | OF-75 | The checkout summary aside goes stale when the country changes: the banner says $21.83 with VAT, the aside $19.23 with no VAT line. `CartTotalUpdater.js` updates only the first `#totalCartPrice`; the aside's copy is rendered once. | `cart/includes/checkout/payment.tpl:28`, `summary-aside.tpl:55-60,71` | order.spec |
| 47 | OF-84 | The checkout summary aside leaves out renewals that the total charges for. | `cart/includes/checkout/summary-aside.tpl:26-43` | order.spec |

### Suspected (found by reading, not reproduced)

- EM: saving the layout writes straight into WHMCS's global email header with no compile or lint. A malformed tag there could make WHMCS refuse every client email. A merge field inside a link, such as `{$x" onmouseover="..."}`, may also break out of the `href`.
- EM: a plain deactivate overwrites edits made in WHMCS's Mail tab while the takeover was on.
- AD: the menu editor's Save deletes and recreates every item with no transaction. Items deeper than two levels are dropped, because the editor only draws two.
- AD: the licence status "Reissued" falls through to "Not active", which blocks go-live on the Setup page.
- AD: the Google font allow-list accepts any family name when `core/config/google-fonts.json` is missing.
- AD: Layouts max width and side padding are limited to 640-2400 and 0-160 in the HTML only. The server accepts 0-4000.
- PB: in-page `#anchor` links resolve against `<base href>` and go to the site root. For example, hero-split's default button is `#pricing`.
- PB: any signed-in admin can open drafts at `/hb-preview/<id>`, including one without the module's role permission.
- PB: the visual editor, the section list in Pages and a second tab all save the same draft with no version check. The last save wins.
- OF: the checkout summary aside leaves out upgrade lines, though the subtotal includes them. Renewals are confirmed (bug 47); upgrades aren't tested.
- OF: the cycle pills only know Monthly, Annual and Biennial. A group sold quarterly, semi-annually or triennially gets no switcher.
- OF: the Save-% maths runs `parseFloat` on formatted prices, which is wrong for currency formats 3 and 4.
- OF: the Bootstrap modals (remove item, empty cart, generate password, fraud check) do nothing if the Bootstrap CDN is blocked.
- OF: the fixture promo `HADRIAN10` has an empty "applies to", so it discounts nothing, and the `flows-more` promo test can't be seeing a real discount. `order.spec` makes its own `ORDERSPEC10` code. `tests/php/scenarios.php` should give `HADRIAN10` a product.
- OF: the store pills start on Annual, but Order Now opens the configure step on Monthly.
- OF: `cart/configuredomains.tpl:385-404` hardcodes English step labels.
- OF: `#generatePwLengthError` can never show, because the input's min and max stop the submit first.
- TH: WHMCS's 500 page prints raw Smarty (`{include ...}`, `{$hadrianLang...}`). Seen while bug 38 broke the cart; not traced.
- TH: in preview, `core-layout.js` reads `svcLayout` and `subnavSide` in camelCase while `header.tpl` uses `svclayout` and `subnavside`, so the script undoes the value the server rendered.
- Tests: two static checkers can't run beside another run of themselves, and the static tier takes no site lock. `check-savebar-rollout.php` compiles into a fixed `%TEMP%/hadrian-savebar-compile` folder and `test-creating-pages.php` writes a fixed `core/pages/test-about/` folder. With two sessions running the gate, both failed ("unable to write file", "mkdir(): File exists") and passed when run alone.
- Tests: the "valid 2x2 PNG" in `e2e/admin-uploads.spec.mjs` isn't valid. Its IDAT data fails the zlib check, so `getimagesize` accepts it but GD can't decode it, and `MediaOptimizer.php:109` logs an `imagecreatefrompng()` warning that fails the WHMCS-log check. The optimiser could also skip an image GD can't open without the warning.
- Tests: the promo flow's cleanup waits for a native dialog (`flows-more.spec.mjs:220`), but removing a cart item opens a Bootstrap modal, so the item is never removed.
- Tests: `tests/e2e/coverage.mjs:37` still names a `billing-contacts-fragment` entry that no longer exists.

## The docs promise things the code doesn't do

- ~~Homepage: the docs said all seven Homepage settings apply whichever template is active.~~ Fixed 2026-11-25 with bugs 8 and 36: Classic now uses the hero title, the hero subtitle and Show domain search, and the docs say so (TH-75).
- Sign-in "Show Logo" is read by no template. Beacon and Split always show the logo, and Default never does.
- Menu Manager: the docs say the main menu drives the icon rail's flyouts and that items can be limited to "Icon rail". The rail is hardcoded (TH-31).
- Menu Manager: "Re-seed presets" only re-creates presets that are missing or empty. It does not add back missing items.
- `includes/common/overwrites/logo.tpl` does nothing, because no template includes `logo.tpl`.
- apple-touch-icon needs a favicon as well as a square logo. The docs say the square logo is enough.
- Licensing: the "day 3" dashboard warning, the Invalid → grace → revert sequence, the twice-daily check and the `hostnodes_license_config.php` fallback are not in this repo. The addon's own banner is disabled (AD-88).
- Page Manager: the docs call the 64 and 160 counters beside the SEO title and description "guidance, not a limit; longer text saves fine". But the boxes carry `maxlength="64"` and `maxlength="160"`, so typing stops there. The server keeps up to 200 and 400 characters, so only text that doesn't come from typing in the box can be longer. Either the docs or the `maxlength` should change. Order Process pages are said to accept visibility, but the gate ignores them.
- SEO: "never half-writes a file". In fact `sitemap.xml` is written before `robots.txt` is tried.
- Order form: "one plan highlighted". Only a product the admin flagged as Featured is highlighted.
- Order form: "a live cart always renders the shipped layout". `?plan=` is read without the preview gate (bug 15).
- Order form: "Order Category Sidebar reaches four pages". The gate sits in `sidebar-categories.tpl`, so it also applies to configuredomains, addons, complete, fraudcheck, error and both renewal pages.
- `hadrian_cart/README.md` says only `products.tpl` and `sidebar-categories.tpl` are overridden. 30 templates are.

## Where to start

The highest-risk gaps across all five products: things that lose data, charge wrongly, leak drafts or lock people out, with no behavioural test today.

1. ~~EM-38, EM-22: a saved draft of a published email must not reach customers.~~ Bugs 1 and 2, fixed and tested 2026-11-25.
2. AD-66: the menu editor Save round trip, including three-level trees and many items.
3. ~~AD-54, PB-08: a failing page provider must not delete Pages rows.~~ Bug 3, fixed and tested 2026-11-25.
4. ~~AD-51: save a long Japanese SEO title and description, then read them back.~~ Bug 4, fixed and tested 2026-11-25.
5. AD-11, AD-19, AD-28, AD-38: press Save on Settings, Layouts and each Styles panel, then check the stored keys. Today every effect test is DB-set.
6. ~~OF-68, OF-72, OF-73: a signed-in checkout with credit, a saved card and a new card.~~ Tested 2026-11-25 in order.spec.
7. ~~OF-16, OF-17, OF-18: configurable options, custom fields and addons on the configure step, with their prices reaching the cart.~~ Tested 2026-11-25 in order.spec; the quantity slider is bug 41.
8. ~~OF-58, OF-75: tax estimate and the live checkout total. The GB 20% fixture already exists and nothing uses it.~~ Tested 2026-11-25 in order.spec; the summary aside is bug 46.
9. ~~TH-123, AD-48: visibility `disabled` returns 404 and `auth` sends guests to login on theme pages, with the admin bypass and the exempt pages.~~ Tested 2026-11-25 in theme-settings.spec, DB-set; the Pages Save (AD-48) still isn't.
10. ~~TH-32: the mobile navigation drawer. If it breaks, phone users have no menu.~~ Tested 2026-11-25 in client-area.spec.
11. PB-05, PB-06, PB-07: Page Builder with Hadrian off, out of date, or missing `module-page.tpl`. Email Templates already has this test (EM-05).
12. PB-02, EM-02: deactivate with and without "Remove data".
13. ~~Fix bugs 37-39 first (OF-30, OF-31, OF-33): the product domain step put invalid names in the cart (every cart page then returned 500), signed customers out and dropped domains.~~ Fixed 2026-11-25.
14. Fix bugs 30-33 next (TH-111, TH-81, tested but open): Change Password, adding a contact and email preferences do nothing (bugs 30, 31, 33), and re-saving a contact corrupts its phone number (bug 32).

## TH: Client-area theme

Every template is also compiled by WHMCS's own Smarty (`tests/compile/compile-all.php`), and every request is checked against WHMCS's error and activity logs (`tests/php/whmcs-log.php`). The rows below don't repeat that.

### TH-A Page shell

| ID | Feature | What to verify | Key files | Coverage | Tests |
|---|---|---|---|---|---|
| TH-01 | Licence gate | `mtLicenseGateEnabled` is hardcoded false and the addon always sets `canRender`, so the gate never shows | `T/header.tpl`, `T/footer.tpl`, `T/error/license-required.tpl` | None | Production only (README) |
| TH-02 | Body state attributes | `data-auth`, `data-tpl`, `data-layout`, `data-area`, `data-active-nav`, `data-page-title`, style `bodyClass` | `T/header.tpl` | Tested | smoke (`data-tpl`, `data-auth` on every route); settings.spec reads `data-area`, `data-layout`; client-area.spec signed out, signed in and per page |
| TH-03 | Base href and cart globals | Base from `BASE_PATH_HREF` or server name; cart pages get `csrfToken`, `whmcsBaseUrl` and load jQuery, Bootstrap 4, multiselect from CDNs | `T/header.tpl` | Tested | client-area.spec base href, cart globals only on order pages; flows.spec checkout, also with jsdelivr blocked |
| TH-04 | Full-page mode | Variant `fullPage` or page option `full_page` drops nav, sidebar, breadcrumb, footer, locale modal; cookie bar and back-to-top stay | `T/header.tpl`, `T/footer.tpl`, `A/src/Service/Hooks.php` (resolveCurrentPage) | Tested | settings.spec renders Beacon/Split; theme-settings.spec `full_page` on Default (DB-set) |
| TH-05 | Content banners | Email verification (resend and dismiss over AJAX), network issues, user validation; only when WHMCS sets the flag | `T/includes/verifyemail.tpl`, `validateuser.tpl`, `network-issues-notifications.tpl` | Partial | client-area.spec verify-email resend and dismiss, the emailed link clears it, network-issue banner; user validation: none (needs a fraud module) |
| TH-06 | Hook output | `$headoutput` at end of head, `$headeroutput` after body opens, `$footeroutput` before scripts | `T/header.tpl`, `T/footer.tpl` | Tested | theme-settings.spec, through a test hook file |
| TH-07 | Footer overwrite | `T/overwrites/footer.tpl` replaces the whole footer; the footer hook stops unless copied across | `T/footer.tpl` | Tested | theme-settings.spec, with a test `overwrites/footer.tpl` |
| TH-08 | theme.json | Declares styles, layouts, 13 pages, `extensions`, `rtlLanguages`; its version differs from `core/hadrian.php`, the release build stamps one | `T/theme.json` | Static | check-release-package |

### TH-B SEO and head

| ID | Feature | What to verify | Key files | Coverage | Tests |
|---|---|---|---|---|---|
| TH-09 | Page title | Per-language SEO title as typed, else "pagetitle - company"; same string in `og:title`, `twitter:title` | `T/header.tpl` | Tested | theme-settings.spec theme page, English and French (DB-set); builder.spec built pages |
| TH-10 | Meta description | SEO description, else the WHMCS tagline; left out when neither exists | `T/header.tpl` | Tested | theme-settings.spec (DB-set); builder.spec built pages |
| TH-11 | robots noindex meta | `noindex, nofollow` only when indexing = disallow; password-reset and legacy pages default to disallow | `T/header.tpl`, `P/*/page.php` | Tested | theme-settings.spec disallow vs allow, password reset noindex by default; sitemap.spec covers robots.txt |
| TH-12 | Canonical and og:url | Current URL without `currency`, `language`; a built stand-in names the theme page's address; check `rp=/` encoding | `T/header.tpl`, `Hooks.php` (resolveSeoContext) | Tested | client-area.spec one parameter stripped; several parameters (bug 9) and `rp=/` encoding (bug 10) are known bugs; sitemap.spec stand-in canonical |
| TH-13 | og:type | `article` on viewannouncement and knowledgebasearticle, `website` elsewhere | `Hooks.php` (OG_ARTICLE_PAGES) | Tested | client-area.spec announcement, KB article, other pages |
| TH-14 | Social image and Twitter card | Image set: `og:image`, `twitter:image`, `summary_large_image`; else `summary` | `T/header.tpl` | Tested | theme-settings.spec (DB-set) |
| TH-15 | hreflang alternates | With `enable_alternate_links`: x-default plus one per mapped language, respecting the custom language list; nothing when only x-default resolves | `T/header.tpl`, `Hooks.php` | Tested | settings.spec on/off count; theme-settings.spec custom list |
| TH-16 | html lang | Active locale code | `T/header.tpl` | Tested | flows-more (Arabic); client-area.spec language switch |
| TH-17 | Favicon and apple-touch-icon | Favicon tags only when one is uploaded; apple-touch-icon needs favicon and square logo | `T/header.tpl` | Tested | theme-settings.spec, test favicon and square logo (DB-set) |

### TH-C Layouts

| ID | Feature | What to verify | Key files | Coverage | Tests |
|---|---|---|---|---|---|
| TH-18 | Main-menu dispatch | Only the picked layout's chrome renders (side, top, rail, custom); the top layout also renders the sidebar as the mobile drawer | `T/header.tpl`, `T/includes/partials/{sidebar,topnav,rail,rail-panels,inner-topbar}.tpl` | Tested | settings.spec 4 layouts x guest/client and 375px; browser.spec measures sidebar and rail width |
| TH-19 | Layout by visitor | One pick for guests, one for clients | `A/src/Helpers/LayoutPointers.php` | Tested | test-layout-pointers; settings.spec |
| TH-20 | Layout by area | `hadrian_layout_mode=area`, one pick per website/client/order; a page can override its area | `A/src/Helpers/PageArea.php`, `T/header.tpl` | Tested | settings.spec (3 tests); test-layout-pointers |
| TH-21 | Per-page layout override | Pages > Custom layout (main menu or footer) beats the global pick | `Hooks.php` (layout_overrides) | Tested | theme-settings.spec main menu and footer override; a missing layout is ignored (DB-set) |
| TH-22 | Layout options | Sidebar and rail only: `align` to `data-align`, `side` to `data-sidebar-side`, `profile` to `data-nav-profile` | `T/core/layouts/main-menu/{sidebar,rail}/layout.php`, `core-layout.css` | Tested | theme-settings.spec sidebar align/side/profile, rail side/profile (DB-set) |
| TH-23 | Layout preview | `?preview=1` renders all three; `?layout`, `?align`, `?sidebarside`, `?navprofile`, `?svclayout` only in preview; custom tokens allow-listed | `T/header.tpl`, `state-chip.tpl`, `core-layout.js` | Tested | client-area.spec chip, live switch, parameters ignored outside preview; browser.spec geometry |
| TH-24 | Custom layouts | A folder with `layout.php`, `default.tpl`, `layout.css` is found with no config edit; a vanished folder falls back to sidebar | `T/core/layouts/main-menu/topbar-minimal/` | Tested | check-layout-dispatch; settings.spec topbar-minimal |
| TH-25 | Footer layouts | default (secondary links, locale button), extended (Footer menu columns), extended-info (adds logo, description, socials); unknown falls back to extended | `T/footer.tpl`, `T/core/layouts/footer/*` | Tested | settings.spec, including `hide_footer_socials` |
| TH-26 | Content width and container tokens | `content_width` full sets `data-content-width`; `--content-max-width` 1120, `--content-pad-x` 48 | `T/header.tpl`, `core-theme.css`, `T/core/config/layout.php` | Tested | settings.spec DB-set; theme-settings.spec tokens on `:root`, unknown token and out-of-range value dropped |

### TH-D Navigation chrome

| ID | Feature | What to verify | Key files | Coverage | Tests |
|---|---|---|---|---|---|
| TH-27 | Sidebar | Logo falls back full, square, company name; KB search box; menu with fallback; collapsible groups; account block or Login/Create | `partials/sidebar.tpl` | Tested | client-area.spec brand, groups, account block, sign-in; KB search box is a known bug (bug 11); oracles |
| TH-28 | Sidebar badges | Counts for services, unpaid invoices, open tickets, domains from `$clientsstats` | `partials/sidebar.tpl` | None | client-area.spec skips: no menu item on the install has a badge source |
| TH-29 | Sidebar group memory | Open groups restored from `localStorage` `hn.sidebarGroups` (suspected never saved) | `sidebar.tpl`, `core-layout.js` (initSidebarGroups) | Tested | client-area.spec; known bug 12 |
| TH-30 | Top nav | Dropdowns, mega menus, right-aligned items, guest login, language and currency switchers; icons only with `topnav_show_icons` | `partials/topnav.tpl` | Tested | client-area.spec dropdowns, mega, sign-in, locale; settings.spec icons toggle |
| TH-31 | Icon rail and flyouts | 8 hardcoded buttons (3 guest, 5 client); flyout on hover, click, focus with a 180 ms close bridge; Menu Manager doesn't reach it | `partials/rail.tpl`, `rail-panels.tpl`, `core-layout.js` (initRail) | Tested | client-area.spec guest and client flyouts on hover, click, focus, close delay; browser.spec rail width |
| TH-32 | Mobile drawer | At 900px and below the hamburger opens `body.nav-open`; backdrop, Esc, a link click or resizing back closes it | `core-layout.js` (initNavDrawer) | Tested | client-area.spec open, Esc, backdrop, link, resize |
| TH-33 | Profile dropdown | Account links, dark-mode switch, sign out; outside click or Esc closes; Enter or Space opens | `partials/profile-dropdown.tpl`, `core-layout.js` (initDropdowns) | Tested | client-area.spec click, Enter, Space, Esc, outside click; flows.spec dark toggle |
| TH-34 | Notifications | Dot when there are alerts or announcements; alerts by severity plus up to 5 announcements; empty message | `topnav.tpl`, `inner-topbar.tpl` | Tested | client-area.spec dot and list with alerts, empty message without |
| TH-35 | Cart badge | `globalCartCount`, then `cartitems`, then `cartcount` | `topnav.tpl`, `inner-topbar.tpl`, `A/hooks.php` | Tested | client-area.spec count on every page; flows.spec |
| TH-36 | Breadcrumb and hide toggle | Top layout: "< Home" link (not on homepage); side and rail: crumbs in the topbar; `hide_breadcrumb` hides both | `T/header.tpl`, `inner-topbar.tpl` | Tested | client-area.spec top, side and rail; settings.spec hide toggle; crumb label is a known bug (bug 13) |
| TH-37 | Active nav highlight | `data-active-nav` marks the item `.active` and opens its group | `core-layout.js` (applyActiveNav) | Tested | client-area.spec rail highlight; sidebar highlight is a known bug (bug 14) |
| TH-38 | Affixed navigation | Bar hides on scroll down, returns on scroll up | `core-layout.js` (initAffixedNav) | Tested | theme-settings.spec scroll down and up at 820px (DB-set) |
| TH-39 | Unpin sidebar | Sidebar scrolls with the page | `T/header.tpl`, `core-layout.css` | Tested | settings.spec CSS position, DB-set |

### TH-E Sub-nav, card treatment, preview parameters

| ID | Feature | What to verify | Key files | Coverage | Tests |
|---|---|---|---|---|---|
| TH-40 | Website sub-nav | Page editor beats `subnav_pages_website` beats `website_subnav`; off hides the side column, including invoice summary and service actions | `T/header.tpl`, `Hooks.php` (resolveSubnav) | Tested | settings.spec global off; theme-settings.spec exception list and page field (DB-set) |
| TH-41 | Order sub-nav | `cart_subnav` off removes the category rail | `T/header.tpl` | Tested | settings.spec (`.subnav-card` count); theme-settings.spec exception list |
| TH-42 | Card controls inside/outside | Per page beats `svc_layout_pages` beats `service_controls_outside` | `T/header.tpl`, `core-layout.css`, `Hooks.php` (resolveSvcLayout) | Tested | settings.spec attribute and clean pages; theme-settings.spec exception list and page field on services and emails (DB-set). Domains, invoices, quotes, tickets, add funds, the dashboard and store pages pin their own layout and ignore it |
| TH-43 | URL parameters outside preview | `?palette`, `?subnav`, `?subnavside`, `?data`, `?tiles`, `?form`, `?plan`, `?product` should need `?preview=1` and don't | `T/header.tpl` | Tested | client-area.spec; known bug 15 |
| TH-44 | Preview demo data | About 25 pages show demo rows only with `?preview=1` and no real data | `P/serverstatus` and others | Tested | client-area.spec with and without `?preview=1`, with and without real data |

### TH-F Global settings and overlays

| ID | Feature | What to verify | Key files | Coverage | Tests |
|---|---|---|---|---|---|
| TH-45 | Capitalize titles | Off sets `data-capitalize-titles=0`; eyebrows and store labels lose uppercase | `T/header.tpl`, `core-layout.css` | Tested | settings.spec, DB-set |
| TH-46 | "Free" label | `free_label` prints `$LANG.orderfree` for all-zero prices on services, product details, upgrade, summary; JS and PHP twins agree | `T/includes/common/price.tpl`, `core-layout.js`, `A/src/Helpers/PriceHelper.php` | Tested | check-free-price; settings.spec store page; theme-settings.spec services list and service page (DB-set) |
| TH-47 | Hide cycle discounts | `data-hide-discounts` hides `.cp-cycle-save` | `T/header.tpl`, `core-layout.css` | Tested | theme-settings.spec store and configure badges (DB-set) |
| TH-48 | Cookie box | Shows after 1.5 s unless `mt_cookie_consent` exists; position; button label; message falls back language, default language, built-in | `partials/cookie-box.tpl`, `Hooks.php` (resolveCookieMessage) | Tested | settings.spec delay, position, label, dismissal; theme-settings.spec per-language fallback (DB-set) |
| TH-49 | Back to top | Appears after scrolling, scrolls up | `partials/back-to-top.tpl` | Tested | settings.spec |
| TH-50 | Dismissible notices | A valueless `[data-dismiss]` removes the notice | `core-layout.js` (initDismissibles) | Tested | client-area.spec |
| TH-51 | Password show/hide, dark logo swap | `.password-toggle` flips the input type; `img[data-logo-dark]` swaps with the theme | `core-theme.js`, `core-layout.js` | Partial | client-area.spec eye button; dark logo swap: skipped, no dark logo uploaded |

### TH-G Dark mode

| ID | Feature | What to verify | Key files | Coverage | Tests |
|---|---|---|---|---|---|
| TH-52 | Off | Light only, no switch, a saved dark cookie is ignored | `A/hooks.php`, `T/header.tpl` | Tested | settings.spec |
| TH-53 | Optional (switcher) | Server renders the default; `mt_theme` cookie overrides it with no flash; legacy `apple-theme` localStorage migrated once | `core-theme.js`, `profile-dropdown.tpl` | Tested | flows.spec toggle survives reload; settings.spec default dark; client-area.spec cookie rendered by the server, `apple-theme` migration |
| TH-54 | Forced | No switch; default applies to everyone; JS clears any stored choice | `core-theme.js` | Tested | settings.spec forced dark; theme-settings.spec forced light |
| TH-55 | Guest toggle | Signed-out moon button in top nav and inner topbar, switcher mode only | `topnav.tpl`, `inner-topbar.tpl` | Tested | client-area.spec |
| TH-56 | Dark legibility | Text contrast at least 3:1 in dark | `core-theme.css` | Tested | browser.spec; settings.spec variants in light and dark; client-area.spec client pages |

### TH-H Styles and tokens

| ID | Feature | What to verify | Key files | Coverage | Tests |
|---|---|---|---|---|---|
| TH-57 | Style presets | default, emerald, violet, rose, amber, slate can be activated; `dark` cannot; body gets `theme-<name>` | `T/core/styles/*/style.php`, `Hooks.php` (buildColorsHead) | Tested | theme-settings.spec activates all 6 presets from the Styles screen; check-style-seed, check-preset-reset, check-style-swatch |
| TH-58 | Colour token output | `colors.php` into `:root` and `html[data-theme=dark]`; only changed values stored | `T/core/config/colors.php`, `core-theme.css` | Static | check-color-defaults, test-customize; colour-scope.spec measures the scope-leak panes |
| TH-59 | Typography output | Bundled Inter, system stack, Google Font (up to 5 weights), self-hosted `@font-face`, heading font, size, weight, line-height variables | `T/core/config/typography.php`, `T/assets/fonts/`, `Hooks.php` (buildTypographyHead) | Tested | theme-settings.spec Google and system fonts, weights, sizes, line height (DB-set) |
| TH-60 | Nav, button, form, element, general tokens | Size and shape variables printed in `:root` | `T/core/config/{navigation,buttons,forms,elements,general}.php` | Static | check-color-defaults |
| TH-61 | Custom CSS output | Admin CSS printed in head, `</style>` stripped | `Hooks.php` (buildCustomCss) | Tested | theme-settings.spec, including a `</style>` break-out (DB-set) |

### TH-I Menus (rendering)

| ID | Feature | What to verify | Key files | Coverage | Tests |
|---|---|---|---|---|---|
| TH-62 | Menu rendering | Main, footer, footer-secondary; item types header, divider, dropdown and mega, login, language, currency, link, account; `target=_blank` | `sidebar.tpl`, `topnav.tpl`, footers, `A/src/Menu/TreeRenderer.php` | Tested | client-area.spec every guest item type and the client menu; crawl, oracles |
| TH-63 | Menu audience | Guest vs client menu; per-item "Visible to" | `A/src/Menu/MenuPointers.php` | Tested | test-menu-pointers; settings.spec |
| TH-64 | Menus by area | An area's menu beats the visitor rule | `MenuPointers.php` | Tested | settings.spec |
| TH-65 | Item layout filter and fallback menu | Items limited to top, side or rail; no menu at all shows Home, Dashboard, "Configure menu" | `TreeRenderer.php`, `sidebar.tpl`, `topnav.tpl` | None | |
| TH-66 | Locale menu items | Hidden by the matching `hide_*` switch | `sidebar.tpl`, `topnav.tpl` | None | |

### TH-J Languages

| ID | Feature | What to verify | Key files | Coverage | Tests |
|---|---|---|---|---|---|
| TH-67 | Theme strings | `english.php`, then `<lang>.php`, then `overrides/<lang>.php`, merged per key; a broken override is skipped | `T/core/lang/`, `Hooks.php` (loadLanguage) | Tested | theme-settings.spec override wins, a broken file is skipped; check-lang-loading, i18n-safety |
| TH-68 | WHMCS `$LANG` keys | Every key used exists, with the right shape | all `.tpl` | Static | check-whmcs-lang-keys |
| TH-69 | Locale button | Flag, native name, currency when there is more than one; gone when both `hide_*` are on | `partials/locale-btn.tpl` | Tested | settings.spec both hidden; theme-settings.spec each part alone (DB-set) |
| TH-70 | Locale modal | Native names, custom list, currency grid; Apply reloads with `?language`, `?currency` | `partials/locale-modal.tpl`, `core-layout.js` | Partial | flows.spec open/close; settings.spec custom list; client-area.spec Apply; currency grid: none (one-currency install) |
| TH-71 | RTL | `rtlLanguages` in theme.json; error pages link `theme-rtl.css`, `site.css` that don't exist | `T/includes/common/head.tpl` | Partial | flows-more Arabic, no overflow; client-area.spec error page stylesheets, a known bug (bug 16) |

### TH-K Page variants

| ID | Feature | What to verify | Key files | Coverage | Tests |
|---|---|---|---|---|---|
| TH-72 | Variant dispatch | `overwrites.tpl`, then the picked variant, then `default/default.tpl`; options stored as `key__variant` | `T/*.tpl`, `Hooks.php` (resolveCurrentPage) | Tested | test-creating-pages; theme-settings.spec `overwrites.tpl` over a variant |
| TH-73 | Dashboard: Default | Notices, tiles, services, tickets, register-domain box, extra panels (affiliates, MarketConnect, addons) | `P/clientareahome/default/` | Tested | client-area.spec tiles and services panel; register-domain box is a known bug (bug 17); smoke personas; visual |
| TH-74 | Dashboard: Atrium, Bento, Minimal | Welcome band options, block builder, titles inside/outside, rows, search after N, paints | `P/clientareahome/{atrium,bento,minimal}/` | Tested | settings.spec marker, light/dark, 375px; theme-settings.spec Atrium, Bento, Minimal options (DB-set); Bento `bnt_account` is a known bug (bug 35) |
| TH-75 | Homepage: Modern, Classic | Hero, domain search and TLD strip, live product groups, announcements (skipped when none), CTA; hero title and subtitle from Pages; five section switches (Classic: domain search only) | `P/homepage/{default,portal}/` | Partial | smoke guest, full; settings.spec Classic marker; theme-settings.spec the five sections by default, each switch on Modern and the domain search on Classic (bug 36, fixed); known-bugs.spec the hero from Pages on both templates (bug 8, fixed) |
| TH-76 | Login: Default, Beacon, Split | Beacon field style, colour, news; Split panel style, colour, info; both full-page | `P/login/` | Tested | settings.spec signs in from each; check-login-styles (preview for a person) |
| TH-77 | Page discovery | A new `core/pages/<name>/` appears with no version bump | `A/src/Template/PagesCache.php` | Static | test-creating-pages |

### TH-L Shared components

| ID | Feature | What to verify | Key files | Coverage | Tests |
|---|---|---|---|---|---|
| TH-78 | Full and empty states | Inline script sets `data-data` from real counts; CSS hides `.when-full` or `.when-empty` | 68 `P/*/default.tpl`, `core-layout.css` | Tested | client-area.spec full and empty variants from real counts; oracles |
| TH-79 | List-table engine (6 lists) | Client mode: search, status tabs, page size, pager, sort, row click, kebab, 2 h state memory; server mode with `enable_dynamic_ajax`; libraries from CDN | `T/assets/js/dynamic-tables.js`, `partials/list-table-assets.tpl` | Tested | client-area.spec sort, search, kebab, row click, status tabs, saved state on all 6 lists; known bugs 18-21 (services sort, invoices sort, status tabs on 3 lists, emails past 10) |
| TH-80 | Captcha | Image captcha or reCAPTCHA on 12 forms when enabled for that form | `T/includes/captcha.tpl` | Tested | client-area.spec contact and register refuse a guest without it; not shown to clients |
| TH-81 | Phone field | intl-tel-input on register and contacts; national number plus hidden dial code | `P/clientregister/`, `P/account-contacts-*/` | Tested | client-area.spec display; flows-more register; adding a contact (bug 31) and re-saving one (bug 32) are known bugs |
| TH-82 | Generate-password modal | Web Crypto, fills both password fields | `P/clientregister/` | Tested | client-area.spec |

### TH-M Services

| ID | Feature | What to verify | Key files | Coverage | Tests |
|---|---|---|---|---|---|
| TH-83 | Services list | Status tabs with counts, search, row to details, "Free" label | `P/clientareaproducts/` | Tested | client-area.spec tabs, search, row click; sort is a known bug (bug 18); smoke |
| TH-84 | Service details | Status pill, pending-cancellation notice, side menu, billing, config options, custom fields, addons, module output | `P/clientareaproductdetails/` | Tested | client-area.spec status, options, custom field, addon, side menu, cancel request; smoke; visual |
| TH-85 | cPanel SSO | Login to cPanel and Webmail plus 11 shortcuts (`dosinglesignon=1&app=`); notice when suspended, pending, terminated | `T/modules/servers/cpanel/overview.tpl` | None | Production only; crawl skips SSO links |
| TH-86 | Module change password | Form, success and error alerts | `P/clientareaproductdetails/` | None | |
| TH-87 | Upgrade | Plan choice to summary; config-option upgrade; `/upgrade` to upgrade-configure | `P/upgrade/`, `upgradesummary/`, `upgrade-configure/` | Tested | flows-more (3 flows); client-area.spec plan names to the summary |
| TH-88 | Cancel request | Cancellation form | `P/clientareacancelrequest/` | Tested | client-area.spec request shows as pending |
| TH-89 | Module overviews | cPanel, Plesk, WP Squared: Sitejet, addons, WP Toolkit, quick email create | `T/modules/servers/*`, `T/includes/module-overview/*` | None | |
| TH-90 | SSL and usage billing | managessl list; configuressl steps 1-3; usage metrics | `P/managessl/`, `P/configuressl-*/`, `P/usagebillingpricing/` | Partial | client-area.spec managessl list; configuressl and usage billing: none (coverage.mjs: local) |

### TH-N Domains

| ID | Feature | What to verify | Key files | Coverage | Tests |
|---|---|---|---|---|---|
| TH-91 | Domains list and bulk | Ticking domains shows the bulk bar, which leads to the bulk page | `P/clientareadomains/`, `P/bulkdomainmanagement/` | Tested | flows-more; client-area.spec bulk bar |
| TH-92 | Domain details tabs | Autorenew toggle, nameserver save, registrar lock, addons, `#tab` deep links | `P/clientareadomaindetails/` | Partial | client-area.spec auto-renew, nameservers, tabs; flows-more deep link; registrar lock: none (WHMCS offers none for .uk) |
| TH-93 | DNS, email forwarding, register NS, EPP, contacts | Edit and save forms | `P/clientareadomain{dns,emailforwarding,registerns,getepp,contactinfo}/` | Tested | client-area.spec DNS, forwarding, WHOIS contacts, EPP copy; glue records are a known bug (bug 22) |
| TH-94 | Domain addons | Addon confirmation step | `P/clientareadomainaddons/` | Tested | client-area.spec disable ID protection |
| TH-95 | Domain pricing | TLD price table | `P/domain-pricing/` | Tested | client-area.spec TLD prices |

### TH-O Billing

| ID | Feature | What to verify | Key files | Coverage | Tests |
|---|---|---|---|---|---|
| TH-96 | Invoices list | Status tabs, search | `P/clientareainvoices/` | Tested | client-area.spec search, kebab, row click; sort (bug 19) and status tabs (bug 20) are known bugs |
| TH-97 | Mass pay | Unpaid invoices with a total | `P/masspay/` | Tested | flows-more; client-area.spec total; bank-transfer "Please wait" is a known bug (bug 23) |
| TH-98 | View invoice | Apply credit, line items, ledger, payment method, PDF, outcome panels | `P/viewinvoice/` | Tested | client-area.spec lines, PDF, method switch, apply credit; "Amount due" is a known bug (bug 24) |
| TH-99 | Invoice payment and 3-D Secure | Card or bank payment page; 3DS iframe auto-submit | `P/invoice-payment/`, `P/3dsecure/` | Partial | client-area.spec offline card; 3-D Secure: none (coverage.mjs: local) |
| TH-100 | Add funds | Amount and gateway form | `P/clientareaaddfunds/` | Tested | client-area.spec presets, minimum, invoice |
| TH-101 | Quotes | Accept posts `viewquote#accept` with token; decline; PDF | `P/clientareaquotes/`, `P/viewquote/` | Tested | client-area.spec Accept and PDF; flows-more Accept link (WHMCS has no client-side decline) |
| TH-102 | Payment methods | Add a card (number formatting), edit, delete, set default, billing contact fragment | `P/account-paymentmethods*/` | Tested | flows-more add, edit, delete; client-area.spec set default; check-form-contracts |
| TH-103 | Email history | List plus `viewemail` popup | `P/clientareaemails/`, `P/viewemail/` | Tested | client-area.spec opens a message; the popup is a known bug (bug 25) |

### TH-P Support

| ID | Feature | What to verify | Key files | Coverage | Tests |
|---|---|---|---|---|---|
| TH-104 | Submit ticket | Department, then subject, urgency, related service, custom fields, attachments, captcha; KB suggestions | `P/supportticketsubmit*/` | Partial | client-area.spec urgency, service, attachment; KB suggestions are a known bug (bug 26); custom fields: none (none exist) |
| TH-105 | View ticket | Thread, attachments, reply, Close (GET with token), missing and closed states | `P/viewticket/` | Tested | flows.spec close; flows-more reply; client-area.spec attachment, missing and closed states |
| TH-106 | Ticket list, feedback, markdown guide | Status tabs; rating form; editor fragment | `P/supporttickets/`, `P/ticketfeedback/`, `P/markdown-guide/` | Tested | client-area.spec markdown guide; feedback (bug 27) and status tabs (bug 20) are known bugs |

### TH-Q Content, account, sign-in

| ID | Feature | What to verify | Key files | Coverage | Tests |
|---|---|---|---|---|---|
| TH-107 | Knowledgebase, announcements, downloads | Search, helpful votes, RSS, copy link, categories | `P/knowledgebase*/`, `P/announcements/`, `P/viewannouncement/`, `P/downloads*/` | Tested | client-area.spec KB category, article, vote, announcements, copy link, downloads; KB search (bug 11) and RSS (bug 28) are known bugs |
| TH-108 | Server status | Live port checks, issue tabs | `P/serverstatus/` | Partial | client-area.spec issue tabs; live port checks: none (no server has a status address) |
| TH-109 | Contact | Contact form, captcha for guests | `P/contact/` | Tested | flows-more signed in; client-area.spec guest refused without the CAPTCHA |
| TH-110 | Custom page recipe | `custom-page.php` plus `custom-page.tpl` | `hadrian/custom-page.php`, `P/custom-page/` | Static | test-creating-pages |
| TH-111 | Account forms | Details, contacts, users and invites, permissions, profile, password | `P/clientareadetails/`, `P/account-*/`, `P/user-profile/`, `P/user-password/` | Tested | client-area.spec details, contacts, users, invites, profile; known bugs 29-31 and 33 (details messages, email preferences, add contact, Change Password) |
| TH-112 | Two-factor | Enable TOTP, backup-code sign-in | `P/user-security/`, `P/two-factor-*/` | Tested | flows-more; client-area.spec on and off |
| TH-113 | Switch account | Switch between accounts, forced switch | `P/user-switch-account/` | Tested | flows-more; client-area.spec |
| TH-114 | Invite accept, verify email | Accept an invite; verification result | `P/user-invite-accept/`, `P/user-verify-email/` | Tested | client-area.spec invite accept, emailed verify link |
| TH-115 | Marketing subscription | Opt in and out | `P/subscription-manage/` | Tested | client-area.spec emailed opt-out link, tampered link refused; re-subscribe is a known bug (bug 34) |
| TH-116 | Affiliates | Referral link copy, balance, withdraw, signup | `P/affiliates/`, `P/affiliatessignup/` | Partial | client-area.spec referral link, "off" message; sign-up and withdraw: none (affiliates off, zero balance) |
| TH-117 | Sign in | Notices, remember me, captcha, linked accounts | `P/login/` | Tested | flows.spec; client-area.spec remember-me and Sign Out; linked accounts: none (no provider) |
| TH-118 | Register | Sign-up form | `P/clientregister/` | Tested | flows-more; client-area.spec refused without the CAPTCHA |
| TH-119 | Password reset | Email, link, new password; security-question step | `P/pwreset/`, `P/password-reset-*/` | Partial | flows; client-area.spec emailed link, forged link refused; security question: none |

### TH-R Error pages, store, visibility, extensions

| ID | Feature | What to verify | Key files | Coverage | Tests |
|---|---|---|---|---|---|
| TH-120 | WHMCS error pages | 404, unknown route (with referrer note), rate limit, internal error | `T/error/*.tpl`, `T/includes/common/head.tpl` | Partial | client-area.spec 404 inside the chrome; unknown route, rate limit, internal error: none (not reachable locally) |
| TH-121 | Dead-end pages | Banned, access denied, download denied, store not found | `P/banned/`, `P/access-denied/`, `P/downloaddenied/`, `P/store-not-found/` | Partial | client-area.spec access denied and download denied; banned, store-not-found: none |
| TH-122 | Store landing pages | 11 MarketConnect landings plus order: real plans, add to cart, store strings, full-bleed | `T/store/`, `P/store-*/` | None | coverage.mjs: local |
| TH-123 | Visibility gate | `auth` sends guests to login (302); `disabled` gives everyone 404 except a signed-in admin; auth, order and dead-end pages exempt; fails open | `A/src/Helpers/VisibilityGate.php`, `Hooks.php` (enforceVisibility) | Tested | theme-settings.spec auth, disabled with the admin bypass, exemptions (DB-set); test-visibility-gate; builder.spec |
| TH-124 | Theme extensions | `core/extensions/<name>/<name>.php` adds head and footer output, only when listed in theme.json | `Hooks.php` (extensionOutput) | Tested | theme-settings.spec, through a test extension and a theme.json edit |

## AD: Admin addon

What each setting does on the site is listed under TH and OF. The rows here cover the admin side: the screens, what Save stores, validation and side effects. `C/` = `A/src/Controller/Admin/`, `H/` = `A/src/Helpers/`, `V/` = `A/views/adminarea/`.

### AD-A Landing, Info, Setup

| ID | Feature | What to verify | Key files | Coverage | Tests |
|---|---|---|---|---|---|
| AD-01 | Default landing | Bare `?module=Hadrian` shows Setup while the theme isn't live or migrations are pending, otherwise Info; unknown action falls back to index | `C/MainController.php`, `H/SetupProbe.php` | Renders | admin.spec |
| AD-02 | Info page | Theme version; licence badge, key, product, dates, domains (15-minute cache); "New version" flag never set | `C/InfoController.php`, `V/info/index.tpl` | None | `info` is not in `ADMIN_ACTIONS` |
| AD-03 | "Setup not finished" banner | On every screen except Setup while setup needs attention | `V/includes/header.tpl` | None | |
| AD-04 | Version source | Header pill, Info, Setup and cache invalidation read `core/hadrian.php` (1.1.242); `Hadrian.php` says 1.2.3 | `T/core/hadrian.php`, `A/Hadrian.php` | Static | check-release-package |
| AD-05 | Setup checklist | Files, Requirements, Database, License, Go live; each group takes its worst row; missing cart warns; mismatched release marks fail | `H/SetupChecks.php`, `H/SetupProbe.php`, `V/setup/index.tpl` | Static | test-setup, every branch |
| AD-06 | Setup: Run now | Migrations, preset menus, page and layout caches, branding folder with `.htaccess`; redirects to `done=installed` | `C/SetupController.php`, `A/src/Database/Installer.php` | Partial | admin-csrf, on an install that is already current |
| AD-07 | Setup: save licence key | Trims and stores `hadrian_license_key`, deletes `hn_theme_license.json`, forces a fresh check | `C/SetupController.php` | None | admin-csrf checks a forged post is refused |
| AD-08 | Go live | Refused while any group is todo or fail; sets `Template=hadrian`, and `OrderFormTemplate=hadrian_cart` if the cart is complete; remembers the old values | `H/ThemeSwitch.php` | Static | test-setup; through the screen: none |
| AD-09 | Switch back | Restores only rows still pointing at Hadrian; refuses if an old theme folder is gone, checking both first | `H/ThemeSwitch.php` | Static | test-setup |
| AD-10 | Preview link | `index.php?systpl=hadrian` | `C/SetupController.php` | None | |

### AD-B Settings screen

| ID | Feature | What to verify | Key files | Coverage | Tests |
|---|---|---|---|---|---|
| AD-11 | Save (General and Order Process tabs) | Every flag stored as `'1'` or `'0'` from `isset($_POST)`; Layouts-page flags skipped; hidden-tab rows still post | `C/SettingsController.php`, `V/settings/index.tpl` | None | admin-csrf posts the form unchanged; no per-key check |
| AD-12 | Search and tabs | Filter with synonyms ("gdpr"); Enter blocked in search; tab switch reloads | `V/settings/index.tpl` | Static | check-admin-js (parses) |
| AD-13 | Dark mode settings | `enable_dark_mode`, `dark_mode_display`, `dark_mode_default` allow-listed | `C/SettingsController.php`, `A/hooks.php` | Partial | settings.spec DB-set; flows.spec |
| AD-14 | Card controls exception list | `svc_layout_pages` filtered to `SVC_LAYOUT_PAGES` | `C/SettingsController.php` | None | |
| AD-15 | Sub-nav exception lists | `subnav_pages_website`, `subnav_pages_order` filtered to valid pages | `C/SettingsController.php` | None | |
| AD-16 | Custom language list | `custom_language_codes` filtered to installed languages | `H/LocaleHelper.php` | Partial | settings.spec chooser, DB-set; hreflang: none |
| AD-17 | Cookie box settings | Message map keeps installed non-empty languages; position allow-listed; button falls back to "Continue" | `C/SettingsController.php` | Partial | settings.spec DB-set; per-language message: none |
| AD-18 | Dynamic tables endpoint | `enable_dynamic_ajax`: 401 with no client, 403 with the flag off | `A/src/Service/AjaxService.php`, `TableData.php` | Partial | settings.spec rows load; guards: none |
| AD-19 | Order-process settings save | `op_hide_*` off/all/selected with group IDs filtered to existing groups; interfix clamped 8-50; suffix gets a leading dot; character set limited | `C/SettingsController.php` | None | Effects in OF-23 to OF-28 are DB-set |

### AD-C Styles

| ID | Feature | What to verify | Key files | Coverage | Tests |
|---|---|---|---|---|---|
| AD-20 | Activate a style | Only shipped styles; migrates legacy colours; seeds the preset palette once per scope; sets `<tpl>_active_style` | `C/StylesController.php` | Partial | check-style-seed; activation only through the customizer |
| AD-21 | Style card swatches | Reflect saved colours, isolated per style | `C/StylesController.php` | Static | check-style-swatch |
| AD-22 | Style editor routing | Subcategory and tab allow-listed; `?style=` resolved; migrations on GET | `C/StylesController.php`, `V/styles/edit.tpl` | Renders | admin.spec, every style editor |
| AD-23 | Colours save | Light and dark post together; only schema tokens with valid hex, rgb, hsl that differ from default are kept; the rest dropped silently | `C/StylesController.php`, `V/styles/_colors.tpl` | Static | check-colors-panel (render); test-customize (validation) |
| AD-24 | Reset to preset | Deletes both scope rows (and legacy keys for default), then re-seeds; check upgraded installs don't fall back to legacy keys | `C/StylesController.php` | Static | check-preset-reset |
| AD-25 | Quick presets, generate from one colour, undo | Client-side, one scope at a time | `V/includes/footer.tpl` | Static | check-admin-js (parses) |
| AD-26 | Typography save | Sizes, weights, line-heights kept only in bounds and not default; Google family checked against the catalog (any name passes if it is missing); self-hosted name sanitised; heading font | `C/StylesController.php`, `Hooks.php` (buildTypographyHead) | None | |
| AD-27 | Google Fonts catalog | Rows re-validated on read: name pattern, 5 categories, weights 100-900 | `T/core/config/google-fonts.json`, `scripts/fetch-google-fonts.mjs` | None | |
| AD-28 | General, Buttons, Forms, Elements, Navigation save | Only valid keys or in-range numbers that differ from default; out-of-range silently resets; legacy nav values move out of `_layout_vars` | `C/StylesController.php`, `T/core/config/*.php` | None | |
| AD-29 | Custom CSS save | Stored raw in `<tpl>_custom_css` | `C/StylesController.php` | Partial | admin-csrf (save stores a marker); output TH-61: none |

### AD-D Customizer

| ID | Feature | What to verify | Key files | Coverage | Tests |
|---|---|---|---|---|---|
| AD-30 | Open | Frame starts from saved state; older unsaved state dropped | `C/CustomizeController.php`, `V/assets/js/customize.js` | Tested | settings.spec |
| AD-31 | Preview | Posted state reduced to existing styles, layouts, valid colour diffs; held in session; 400 with no state, 409 with no template | `H/CustomizePreview.php`, `H/SiteLook.php` | Partial | test-customize; settings.spec frame |
| AD-32 | Preview gate | Needs a signed-in admin and the session token in the URL; links and GET forms carry the token | `H/CustomizePreview.php` | Tested | test-customize; settings.spec (token alone, other tabs, guests) |
| AD-33 | Save | `_active_style`, colours for both scopes, audience picks, area picks only in area mode | `C/CustomizeController.php` | Tested | settings.spec (site, Styles and Colors agree) |
| AD-34 | Discard, device widths, light/dark scope, area-mode picks | Client-side controls | `customize.js` | Static | customize-js (parses); area mode and dark colours: none |

### AD-E Layouts screen

| ID | Feature | What to verify | Key files | Coverage | Tests |
|---|---|---|---|---|---|
| AD-35 | By visitor / by area | First switch to area seeds each area from the visitor picks; switching back and forth loses nothing | `C/LayoutsController.php`, `H/LayoutPointers.php`, `H/PageArea.php` | Tested | settings.spec through the UI; test-layout-pointers |
| AD-36 | Activate per audience or area | Layout must be valid; an unknown audience mirrors to the legacy key and both audience keys | `C/LayoutsController.php` | Partial | area through the UI; audience buttons: none |
| AD-37 | Per-layout options | `layout_opts` value must be one of the declared choices | `C/LayoutsController.php`, `Hooks.php` (buildLayoutMeta) | None | |
| AD-38 | Header and footer flags | Only layout flags accepted; redirects back to the right tab | `C/LayoutsController.php` | None | Effects DB-set |
| AD-39 | Content width | boxed or full; old "fluid" reads as full | `C/LayoutsController.php` | Partial | settings.spec DB-set |
| AD-40 | Max width and side padding | Merged into `_layout_vars`; default or out-of-range removes it; server accepts 0-4000 while the HTML says 640-2400 and 0-160 | `C/LayoutsController.php` | None | |
| AD-41 | Custom layout folders | Found automatically; bad folders rejected with a reason; `dataLayout` validated; reserved names blocked; "Custom" badge | `A/src/Template/LayoutsCache.php` | Tested | check-layout-dispatch; settings.spec topbar-minimal |
| AD-42 | Live preview link | `?preview=1&layout=<dataLayout>` on main-menu cards | `V/layouts/index.tpl` | None | |

### AD-F Pages screen

| ID | Feature | What to verify | Key files | Coverage | Tests |
|---|---|---|---|---|---|
| AD-43 | List self-heal | Opening the list rebuilds page and layout caches, runs migrations and `PageRegistry::sync` (seeds rows, imports legacy settings) | `C/PagesController.php`, `A/src/Service/PageRegistry.php` | None | Indirect only |
| AD-44 | List UI | Group tabs, search, system-page toggle, SEO, indexing and visibility badges, Open link, "Replaced by" notes | `V/pages/index.tpl`, `H/PageUrlResolver.php` | Renders | admin.spec, every editor link |
| AD-45 | Variant pick | Only variants on disk; a stale stored variant falls back to default | `C/PagesController.php` | Partial | settings.spec renders each variant, DB-set; the pick: none |
| AD-46 | Template options save | Page and variant options merged as `key__variant`; options not on the form carried through; types coerced; selects allow-listed | `C/PagesController.php` | None | |
| AD-47 | Section options builder | Scoped to its variant; colour swatches resolved | `C/PagesController.php`, `H/SectionLayout.php` | None | |
| AD-48 | Visibility setting | public, auth, disabled allow-listed; offered on exempt pages where it does nothing | `C/PagesController.php` | Partial | See TH-123 |
| AD-49 | Sub-nav, area, controls placement per page | Allow-listed; empty area means automatic | `C/PagesController.php` | Partial | area: settings.spec; sub-nav, controls: none |
| AD-50 | Indexing and public URL | Indexing allow-listed; URL trimmed to 255, nothing else; Save refreshes the sitemap | `C/PagesController.php` | Tested | sitemap.spec (disallow reaches robots.txt and back) |
| AD-51 | SEO title and description | Per effective language; capped at 200 and 400 characters; empty map stored as null | `C/PagesController.php`, `A/src/Models/Page.php` | Tested | known-bugs.spec (long Japanese text saved through the editor, counter); builder.spec |
| AD-52 | Social image | Media picker, 500 characters, counted by MediaUsage | `V/pages/edit.tpl` | Tested | admin-uploads |
| AD-53 | Per-page layout override | Must be a valid layout; empty inherits | `C/PagesController.php` | None | |
| AD-54 | Extension pages | Rows and panels from modules; module-owned columns synced; rows of pages that are gone deleted, but never for a module whose listing failed | `H/ExtensionPages.php`, `PageRegistry.php` | Tested | test-extension-pages; test-extension-page-rows; builder.spec; php/sitemap.php |

### AD-G Sitemap

| ID | Feature | What to verify | Key files | Coverage | Tests |
|---|---|---|---|---|---|
| AD-55 | Save and generate | Six booleans plus frequency into `sitemap_settings`, then regenerate | `C/SitemapController.php`, `A/src/Service/SitemapGenerator.php` | Partial | admin-csrf; php/sitemap.php (PHP, not UI) |
| AD-56 | Generate now | Writes `sitemap.xml`, then `robots.txt` between markers, keeping hand-written lines; not atomic | `SitemapGenerator.php` | Partial | admin-csrf; php/sitemap.php check |
| AD-57 | Content rules | Eligible pages, routed announcement and KB addresses, hidden, private and translation rows left out, Disallow lines with `$` | `SitemapGenerator.php`, `H/FrontDoor.php` | Tested | php/sitemap.php (25+ checks) through sitemap.spec |
| AD-58 | Auto-refresh triggers | Page save, module publish, AnnouncementAdd/Edit, daily cron; only when configured and content changed | `A/hooks.php` | Partial | AnnouncementAdd; cron only by source string |
| AD-59 | Preview, last written, root-not-writable banner | Shown on the screen | `V/sitemap/index.tpl` | None | |

### AD-H Menu

| ID | Feature | What to verify | Key files | Coverage | Tests |
|---|---|---|---|---|---|
| AD-60 | Self-heal on every Menu request | Migrations, preset seeder, one-time custom-link conversion; a preset the admin renamed or deleted is not re-created | `C/MenuController.php`, `A/src/Menu/Seeder.php` | Partial | check-menu-migration-guards; known-bugs.spec (rename survives a Menu visit); empty-menu recovery: none |
| AD-61 | Menu list | Four locations, one table each, area badges | `V/menu/index.tpl` | Renders | admin.spec |
| AD-62 | New menu | Blank inactive menu in that location, opens the editor | `C/MenuController.php` | Tested | admin-csrf |
| AD-63 | Delete | GET `confirm=1` with token; items cascade; area picks forgotten; no UI link | `C/MenuController.php`, `A/src/Menu/MenuPointers.php` | Tested | admin-csrf; test-menu-pointers |
| AD-64 | Re-seed, force re-sync, reset WHMCS defaults | Re-seed fills missing or empty presets, a renamed one coming back switched off when its place has a live menu; force wipes and reseeds; reset rebuilds Defaults and Footer Secondary | `Seeder.php`, `A/src/Menu/Presets.php` | Partial | known-bugs.spec (re-seed after a rename); admin-csrf (flash); force and reset: none |
| AD-65 | Menus by area | Menu must exist in that location; 0 means by visitor | `C/MenuController.php` | Tested | settings.spec; test-menu-pointers |
| AD-66 | Editor save | Activating turns off peers in the slot; every item deleted and recreated without a transaction; refused near `max_input_vars` or with an empty list; name and audience not validated | `C/MenuController.php`, `V/menu/edit.tpl` | None | |
| AD-67 | Item editing | 10 item types, page picker, translations, 34 icons, per-item audience and layouts, position, reorder | `A/src/Menu/ItemTypes.php`, `TreeRenderer.php`, `Icons.php` | Static | parses; oracle on preset icons |
| AD-68 | Saved but not rendered | Description, badge, text transform, hide label, CSS class | `V/menu/edit.tpl` | None | Documented as not shown yet |
| AD-69 | Diagnose | GET JSON dump of a menu | `C/MenuController.php` | None | |

### AD-I Branding

| ID | Feature | What to verify | Key files | Coverage | Tests |
|---|---|---|---|---|---|
| AD-70 | Upload a slot | Five slots; MIME sniffed and `getimagesize` checked; SVG scanned; caps 2 MB, 1 MB, 256 KB; random name; old file deleted after the new one lands | `C/BrandingController.php`, `H/Uploader.php` | Partial | admin-uploads, light logo PNG only |
| AD-71 | Remove | Unknown field rejected; file deleted, setting cleared | `C/BrandingController.php` | Tested | admin-uploads |
| AD-72 | Form fallback | Multi-file post; flash `saved`, `partial`, `errors`, `noop` | `C/BrandingController.php` | None | |
| AD-73 | Brand info | Description up to 280 characters; social links must be http(s); blank clears | `C/BrandingController.php`, `A/hooks.php` (mtBrand) | Partial | footer render DB-set; validation: none |

### AD-J Media

| ID | Feature | What to verify | Key files | Coverage | Tests |
|---|---|---|---|---|---|
| AD-74 | Upload | Raster only, 5 MB, 50 MP, at most 500 files; label from filename; optimised if the switch is on | `C/MediaController.php`, `H/MediaLibrary.php` | Partial | admin-uploads; caps: none |
| AD-75 | Optimise and restore | Skips GIF, animated, lossless, non-sRGB; longest edge 2560; kept only at 95% or less of the original; original kept in `.originals`; 8-second batches | `H/MediaOptimizer.php` | Tested | admin-uploads; test-media |
| AD-76 | Usage and delete | Scans pages, settings, menus, module sources; an image in use is refused unless forced | `H/MediaUsage.php` | Tested | admin-uploads; test-media |
| AD-77 | Rename, filters, sort, bulk, optimise switch | Label cleaned to 80 characters | `V/assets/js/media.js` | Tested | admin-uploads |
| AD-78 | Media guards | POST, admin, token, `X-Requested-With`, known collection | `C/MediaController.php` | Partial | admin.spec, admin-uploads; header check: none |

### AD-K Extensions, Tools, Templates, Licence

| ID | Feature | What to verify | Key files | Coverage | Tests |
|---|---|---|---|---|---|
| AD-79 | Extensions page | Theme extensions from theme.json and registered modules | `C/ExtensionsController.php`, `H/Extensions.php` | Tested | test-extension-pages; builder.spec and email.spec cards |
| AD-80 | Tools: clear template cache | Empties the admin's own compile folder only | `C/ToolsController.php` | Tested | admin-csrf ("Cleared") |
| AD-81 | Tools: rebuild discovery | Rebuilds page and layout caches, reports counts | `C/ToolsController.php` | None | |
| AD-82 | Tools: refresh licence | Calls the dormant `Template\License`, a no-op in dev mode with a separate key | `A/src/Template/License.php` | None | |
| AD-83 | Templates list and show | `canActivate` per template; `show` reads `templateName` unvalidated | `C/TemplatesController.php` | Renders | list only |
| AD-84 | Licence page | Save and check; Active, No key, Expired, Revoked, Unverified, Not active; "Reissued" falls to Not active | `C/LicenseController.php`, `H/LicenseCheck.php`, `V/license/index.tpl` | None | Forged post refused only |

### AD-L Cross-cutting

| ID | Feature | What to verify | Key files | Coverage | Tests |
|---|---|---|---|---|---|
| AD-85 | CSRF | Every POST and the GET routes in `GET_WRITES` need the WHMCS token; JSON routes get a JSON 403, others the "Not saved" page | `H/AdminCsrf.php`, `A/src/Controller/AbstractController.php` | Tested | admin-csrf (16 POST and 4 GET routes, list pinned); customizer routes not in the list |
| AD-86 | AJAX guard | POST only, signed-in admin, token; JSON refusals | `H/AdminAjax.php` | Tested | admin.spec; admin-uploads |
| AD-87 | Licence state mapping | No key; Active; Expired and Suspended warn; Unreachable, Unknown, Error warn and aren't cached; Banned, Cancelled, Revoked fail | `H/LicenseCheck.php`, `H/SetupChecks.php` | Static | test-setup |
| AD-88 | Revert to `six` and dashboard banner | `License::deactivateTemplate` and the `adminHooks.php` guard exist but never run; `HOSTNODES_ENFORCE` is not in repo code | `A/src/Template/License.php`, `A/adminHooks.php` | None | Production only |
| AD-89 | Migrations and self-heal | Idempotent Migrator; runs on the Menu, Pages and Sitemap screens and the navbar hook; footer menus re-seeded on client pages when none exist | `A/src/Database/Migrator.php`, `A/hooks.php` | Partial | Setup no-op only |
| AD-90 | Deactivate with Database Clear | Rolls back migrations; deletes only `Hadrian-%` config rows | `A/Hadrian.php`, `A/resources/migrations/Initial.php` | None | |
| AD-91 | Front-end payload | `$hadrian.addonSettings` (the cart reads `op_*`, `free_label`), `mtBrand`, menus, dark-mode values | `Hooks.php`, `A/hooks.php` | Partial | settings.spec DB-set |
| AD-92 | Colour output scope | Light block scoped to `html:not([data-theme=dark]):not([data-palette])`; legacy keys when a row is empty | `Hooks.php` (buildColorsHead), `H/ColorTokens.php` | Static | colour-scope.spec measures check-colors-scope-leak's panes; test-customize |
| AD-93 | Admin dark mode | `localStorage` `hadrian-admin-theme`, no flash on load | `V/includes/header.tpl`, `footer.tpl` | None | |
| AD-94 | Doc links and tooltips | Every "Learn more" anchor exists in the built docs; every setting has a docs heading | `V/includes/tip.tpl`, `doclink.tpl` | Static | check-doc-anchors; check-settings-doc-coverage |
| AD-95 | Addons flyout and admin CSS | Inlined in the admin head; flyout sections match the top nav | `A/hooks.php`, `V/assets/js/addons-flyout.js` | Static | parses; check-admin-nav-sections |
| AD-96 | Bridge for other modules | `Extensions`, `ExtensionPages`, `PageRegistry::syncExtensionPages`, `MediaUsage::register`, `SiteLook`, `LocaleHelper`, `Menu::pick`, `TreeRenderer::buildFlatList`, `Settings::getValue` | `H/*`, `PageRegistry.php` | Partial | test-extension-pages; builder.spec; email.spec |
| AD-97 | Integrity hashes | The real hash table exists only in builds; a mismatch returns 503 on every page | `H/IntegrityHashes.php` | Static | check-release-package; runtime 503: none |
| AD-98 | `systpl` and `templateName` | An unvalidated slug reaches `new Template()`, which requires `core/<slug>.php`; needs a negative test | `H/AddonHelper.php`, `A/src/Template/Template.php` | None | |

## OF: Order form

`theme.yaml` sets `parent: standard_cart`, and 30 templates override every step of the flow. Flow shorthands in the Tests column: **F-buy** is flows.spec "new customer buys" (store, first plan, own domain, defaults, guest checkout by bank transfer, invoice); **F-nocdn** is the same with jsdelivr blocked; **F-domain**, **F-promo** and **F-free** are the domain, promo-code and free-product flows in flows-more.spec; **S-op** is the order-process block in settings.spec.

Branch coverage from `tests/reports/coverage/coverage.json` (2026-11-23, HTTP only, so flows don't count) shows 0% for checkout, its includes, ordersummary, configuredomains, complete and domainoptions, and 27 of 140 branches in configureproduct.

### OF-A Browse

| ID | Feature | What to verify | Key files | Coverage | Tests |
|---|---|---|---|---|---|
| OF-01 | Plan grid (design A) | One card per product or bundle; tag line is the description before its `<ul>`; Order Now goes to `productUrl` | `cart/products.tpl` | Tested | order.spec one card per product, tag line, Order Now; F-buy, F-nocdn, F-free; smoke, sweep, browser |
| OF-02 | Group resolution | `/store/<slug>` and `cart.php?gid=`; heading falls back headline, name, pagetitle | `cart/products.tpl` | Tested | order.spec heading fallback; smoke, both URLs |
| OF-03 | Landing tiles (no group) | Category tiles plus "select category"; WHMCS may redirect to the first group | `cart/products.tpl` | Partial | order.spec: no group lands on the first group; the tiles: none (WHMCS always redirects) |
| OF-04 | Empty group and error message | No products shows the empty card; error alert above it | `cart/products.tpl` | Partial | order.spec: an unknown group lands on the first group; empty group: none (it would show in every sidebar during a run) |
| OF-05 | Billing-cycle pills | Monthly, Annual, Biennial only; hides unused cycles, starts on Annual; per-month price and "Billed annually"; setup fee follows; currency formats 1-4; minimum-price fallback | `cart/products.tpl` (inline JS) | Tested | order.spec offered cycles only, Annual first, per-month price, billed line, setup fee |
| OF-06 | "Save N%" badge | Best saving, or "Save up to" when plans differ; removed by `hide_cycle_discounts` | `cart/products.tpl` | Partial | order.spec real saving (20% shared, 17% dedicated); theme-settings.spec `hide_cycle_discounts`; "Save up to": none (every group saves one percentage) |
| OF-07 | Featured badge | Only on a product the admin flagged as Featured | `cart/products.tpl` | Tested | order.spec, flips product 20 and restores it |
| OF-08 | Setup fee, "starting from", stock, bundles | `minprice.setupFee`; `hasconfigoptions`; stock quantity; bundle price and deal | `cart/products.tpl` | Partial | order.spec setup fee, "Starting from", stock left, out of stock; bundles: none (none exist) |
| OF-09 | Recommendations trigger | `data-has-recommendations` on the design-A button opens the modal | `cart/products.tpl`, `cart/recommendations-modal.tpl` | None | A `tblproduct_recommendations` row did not make WHMCS report recommendations |
| OF-10 | Plan designs B-H | `?plan=a..h` or `all` through `body[data-plan]`; not preview-gated | `cart/products.tpl`, `cart/css/style.min.css` | Tested | order.spec B to H under `?preview=1`; the live-site leak is bug 15 |
| OF-11 | Category rail | Sidebar panels with active state and View Cart badge, `$productgroups` fallback; hidden by Order Category Sidebar off, except under `?preview=1` | `cart/sidebar-categories.tpl` | Partial | order.spec groups, actions, active item, links; settings.spec `cart_subnav` off; View Cart badge: none (WHMCS sets none) |
| OF-12 | Collapsed rail and guest currency | Select navigates; guest currency change posts `currency` | `cart/sidebar-categories-collapsed.tpl`, `sidebar-categories-selector.tpl` | Tested | order.spec; the select (bug 42) and the selects shown at desktop width (bug 43) are known bugs; smoke, sweep |

### OF-B Configure product

| ID | Feature | What to verify | Key files | Coverage | Tests |
|---|---|---|---|---|---|
| OF-13 | Selected-plan hero | Name, description, Change plan; domain row "Included" for own domain or subdomain; Change domain | `cart/configureproduct.tpl` | Tested | order.spec plan, domain, both links back; the "Included" badge is a known bug (bug 40) |
| OF-14 | Billing-cycle cards | Recurring products only; change calls `updateConfigurableOptions` | `cart/configureproduct.tpl` | Tested | order.spec each cycle priced, re-pricing on change |
| OF-15 | "Save X%" on configure | Against monthly; skipped below 0.5%; suppressed by `hide_cycle_discounts` | `cart/configureproduct.tpl` | Tested | theme-settings.spec `hide_cycle_discounts` on configure (DB-set); settings.spec attribute |
| OF-16 | Configurable options | Select, radios, toggle, quantity (number or slider with maximum); each recalculates; fixtures 14 and 15 have options | `cart/configureproduct.tpl` | Tested | order.spec dropdown and yes/no change the summary and reach the invoice; the quantity slider is a known bug (bug 41) |
| OF-17 | Product custom fields | Required marker and help text; fixture product 15 "Project name" | `cart/configureproduct.tpl` | Tested | order.spec label, help text, optional, value on the invoice |
| OF-18 | Product addons and MarketConnect promos | `addons[id]` checkboxes recalculate; promo output above | `cart/configureproduct.tpl` | Partial | order.spec add-on changes the summary and reaches the invoice; MarketConnect promos: none |
| OF-19 | Usage-billing metrics | Metric rows and the pricing modal | `cart/configureproduct.tpl` | None | No product on the stack uses usage billing |
| OF-20 | Live order summary | `#producttotal`: lines, options, addons, setup, per cycle, tax 1 and 2, due today | `cart/ordersummary.tpl` | Tested | order.spec option, add-on and cycle changes; invoice lines |
| OF-21 | Review cart commit | XHR to `cart.php?ajax=1&a=confproduct` under `WEB_ROOT`; empty reply goes to viewcart, otherwise the inline banner shows the error | `cart/configureproduct.tpl` | Tested | order.spec validation banner, then commit; F-buy and others; check-root-paths; subfolder install: static only |
| OF-22 | Promo on the configure step | Commits, posts `validatepromo`, reads the banners, patches the discount row; refetches on change; "no longer applies" | `cart/configureproduct.tpl` | Tested | order.spec refused, no items qualify, accepted, re-priced after a change |

### OF-C Order-process settings in the cart

| ID | Feature | What to verify | Key files | Coverage | Tests |
|---|---|---|---|---|---|
| OF-23 | Server fields by default | Server products show hostname, root password, NS1/NS2 prefix | `cart/configureproduct.tpl` | Tested | S-op defaults |
| OF-24 | `op_hide_hostname` | all or selected groups; hidden inputs filled with a hostname and a 14-character password | `cart/configureproduct.tpl` | Tested | S-op hidden and non-empty, listed and unlisted group; theme-settings.spec WHMCS accepts the values (DB-set) |
| OF-25 | `op_hide_nameservers` | all or selected; submits NS defaults; section hidden when both hidden | `cart/configureproduct.tpl` | Partial | S-op "all"; "selected" and both hidden: none |
| OF-26 | `op_custom_hostname` | Random 8-50 block plus prefix and suffix; character set only when on; fallback `.<company>.com` | `cart/configureproduct.tpl` | Tested | S-op hostname pattern; theme-settings.spec the generated hostname is accepted (DB-set); toggle off with saved fields: none |
| OF-27 | `op_root_pw_strength` | Meter plus hidden `rootpwstrength`; the `ShoppingCartValidateProductUpdate` hook rejects scores under 50 | `cart/configureproduct.tpl`, `A/hooks.php` | Tested | S-op meter and hidden input; theme-settings.spec the hook refuses a weak password (DB-set) |
| OF-28 | `op_hide_hostname_checkout` | Hides the product's domain line on viewcart for matching groups | `cart/viewcart.tpl` | Tested | theme-settings.spec matching and other groups (DB-set) |

### OF-D Product domain step

| ID | Feature | What to verify | Key files | Coverage | Tests |
|---|---|---|---|---|---|
| OF-29 | Option cards | In cart, register, transfer, own domain, subdomain, each gated by WHMCS; starts on own domain when no register TLD is priced | `cart/configureproductdomain.tpl` | Tested | order.spec register, transfer, own domain panels; flows |
| OF-30 | Own domain | `/domain/check` with the CSRF token adds the plan, then the configure step opens; an invalid name gets WHMCS's inline error; a failed check shows an error and submits nothing | `cart/configureproductdomain.tpl` | Tested | order.spec invalid name, signed-in customer stays signed in, cart kept (bug 37, fixed); flows |
| OF-31 | Register through the product | TLD select; `/domain/check` refuses an invalid or taken name before the form posts; free-TLD hint; no-registrar notice | `cart/configureproductdomain.tpl` | Tested | order.spec POST contract, registration in the cart, mistyped and taken names refused (bug 38, fixed) |
| OF-32 | Transfer through the product | `/domain/check` refuses a name that is not registered; EPP asked later in configure domains | `cart/configureproductdomain.tpl` | Tested | order.spec unregistered name refused; EPP asked at checkout, refused empty, kept (uses `google.com`, so it needs WHMCS's lookup online) |
| OF-33 | Subdomain and domain already in cart | `sld.parent`; `incartdomain` select; both go through `/domain/check` like own domain | `cart/configureproductdomain.tpl` | Partial | order.spec a domain in the cart is offered and attaches to the plan (bug 39, fixed); subdomain: none (no subdomains configured) |
| OF-34 | Domain errors | WHMCS's answer to the check shows inline in the panel; the template prints no `$errormessage` (neither does stock) | `cart/configureproductdomain.tpl` | Tested | order.spec (bug 38, fixed) |
| OF-35 | POST contract | `a=add&pid&domainselect=1`, `domains[]`, `incartdomain` | `cart/configureproductdomain.tpl` | Tested | order.spec POST contract and the result in the cart; check-form-contracts |
| OF-36 | AJAX result fragment | Availability, period select, suggestions; probably no caller left | `cart/domainoptions.tpl` | Tested | order.spec register lookup |

### OF-E Domain register, transfer, search

| ID | Feature | What to verify | Key files | Coverage | Tests |
|---|---|---|---|---|---|
| OF-37 | AI and Classic tabs | Smart search on: AI form is live, Classic copies the query and clicks search; smart search off: one Classic form | `cart/domainregister.tpl` | Partial | F-domain, Classic, signed in; AI and smart-search off: none |
| OF-38 | Captcha inside the live form | Printed once, inside the live form, for guests | `cart/domainregister.tpl` | Tested | order.spec once, inside the live form, guests only; smoke, sweep |
| OF-39 | Filters dropdown | TLD multiselect (at least 1), length pills, safe search; AI mode only | `cart/domainregister.tpl` | Tested | order.spec TLD list, minimum one, length pills, safe search |
| OF-40 | Result states | Invalid, taken, TLD unavailable, available, contact support, IDN selector, add to cart | `cart/domainregister.tpl` | Partial | order.spec available, unsold TLD, add to cart; F-domain; invalid and taken: none (the smart lookup reports every name available) |
| OF-41 | Spotlight TLDs and suggestions | Spotlight grid; suggestions with "more" and sale chips; hidden on Classic | `cart/domainregister.tpl` | None | No spotlight TLDs; suggestions come from WHMCS's external smart lookup |
| OF-42 | `?query=` auto search | Searches on load; invalid state pre-rendered | `cart/domainregister.tpl` | Renders | smoke; sweep; order.spec skips: in smart mode WHMCS passes `?query=` as `$lookupTerm`, which the form never reads (stock does the same) |
| OF-43 | Featured TLDs and pricing table | Category filter; register, transfer, renew columns; Free and N/A; years labelled from the register key | `cart/domainregister.tpl` | Tested | order.spec register, transfer, renew per TLD; the category filter is a known bug (bug 44) |
| OF-44 | Transfer page | Domain, EPP, captcha, errors; AJAX `addDomainTransfer` | `cart/domaintransfer.tpl` | Partial | order.spec no captcha signed in, empty submit stopped, unregistered name refused; a successful transfer: none (the stub is never asked) |
| OF-45 | Several domains in a row | Results and spotlights added one after another | `cart/domainregister.tpl` | Tested | order.spec |

### OF-F Domain configuration

| ID | Feature | What to verify | Key files | Coverage | Tests |
|---|---|---|---|---|---|
| OF-46 | Per-domain card | Registration period, hosting status, "no hosting" link | `cart/configuredomains.tpl` | Tested | order.spec period, no-hosting link; F-domain |
| OF-47 | EPP code | `epp[n]` when EPP is enabled | `cart/configuredomains.tpl` | Tested | order.spec |
| OF-48 | DNS, ID protection, email forwarding | Toggles priced per registration period through `free-price.tpl` | `cart/configuredomains.tpl`, `cart/includes/free-price.tpl` | Tested | order.spec priced add-ons reach the cart and re-price with the period |
| OF-49 | Registrant and extra domain fields | ccTLD requirements | `cart/configuredomains.tpl` | Tested | order.spec .co.uk registry fields |
| OF-50 | Nameservers 1-5 | Shown when a domain has no hosting | `cart/configuredomains.tpl` | Tested | order.spec nameservers reach the cart |
| OF-51 | Errors, empty state, Continue | Error list; empty card; Continue to viewcart | `cart/configuredomains.tpl` | Tested | order.spec EPP error, Continue; F-domain |

### OF-G Cart

| ID | Feature | What to verify | Key files | Coverage | Tests |
|---|---|---|---|---|---|
| OF-52 | Line cards | Products (options, addons, setup, prorata), addons, domains, renewals, upgrades with credit | `cart/viewcart.tpl` | Tested | order.spec options and add-ons on the card, invoice lines; F-buy, F-domain |
| OF-53 | Edit links | `confproduct&i=` and `confdomains` | `cart/viewcart.tpl` | Tested | order.spec Edit reopens the choices |
| OF-54 | Remove item | Opens `#modalRemoveItem`, posts `a=remove`; needs Bootstrap | `cart/includes/viewcart/modal/remove-item.tpl` | Tested | order.spec through the Bootstrap modal |
| OF-55 | Empty cart | `#modalEmptyCart` posts `a=empty`; nothing happens without Bootstrap | `cart/includes/viewcart/modal/empty-cart.tpl` | Tested | order.spec through the Bootstrap modal |
| OF-56 | Quantity and domain period | `qty[]`, addon quantities, period select | `cart/viewcart.tpl` | Partial | order.spec period re-prices the domain and add-ons; quantities: none (no product allows them) |
| OF-57 | Promo apply and remove | Four banners: invalid, no discount, accepted, error; applied pill with remove | `cart/viewcart.tpl` | Tested | order.spec refused, no discount, accepted pill, removed; F-promo |
| OF-58 | Estimate taxes | Guest with tax on posts state and country; fixture GB 20% exists | `cart/viewcart.tpl` | Tested | order.spec GB guest, 20% VAT on the domain |
| OF-59 | Totals | Subtotal, discount, tax 1 and 2, recurring per cycle, due today | `cart/viewcart.tpl` | Tested | order.spec subtotal - discount + tax = due today |
| OF-60 | Hook, gateway, express output | "Last chance" card only for real hook markup; MarketConnect expander; gateway buttons | `cart/viewcart.tpl` | Partial | order.spec through the cart modals; hook, gateway and express output: none |
| OF-61 | Empty state | `data-data` from the cart items | `cart/viewcart.tpl` | Tested | order.spec empty state after emptying; smoke; sweep |

### OF-H Checkout

| ID | Feature | What to verify | Key files | Coverage | Tests |
|---|---|---|---|---|---|
| OF-62 | WHMCS JS stubs | Payment events, `jqClient`, module bootstrap defined before `scripts.min.js` | `cart/checkout.tpl` | Tested | order.spec; F-buy fails on any JS error; card validation stubs are missing (bug 45) |
| OF-63 | Create and Sign-in tabs | Sync `custtype`; hide password, security, opt-in for existing customers | `cart/checkout.tpl`, `cart/includes/checkout/account.tpl` | Tested | order.spec Sign-in tab; F-buy Create tab |
| OF-64 | New-customer fields | Name, email, phone, address, country, tax ID, custom fields | `cart/includes/checkout/account.tpl` | Partial | order.spec GB guest, custom field; F-buy, F-nocdn, F-free; tax ID: none |
| OF-65 | Phone field | Separate dial code, country from `#inputCountry`, hidden calling-code field, typed `+` stripped | `cart/checkout.tpl` | Tested | order.spec dial code follows the country; F-buy national number; F-nocdn plain field |
| OF-66 | Password, generator, security question | Strength meter; generate modal 8-64 with copy and insert; question | `cart/includes/checkout/security.tpl`, `generate-password-modal.tpl` | Partial | order.spec generator length check and insert; F-buy; security question: none |
| OF-67 | Existing-customer sign-in | `#btnExistingLogin` over AJAX; error shown; forgot-password link | `cart/includes/checkout/account.tpl` | Tested | order.spec wrong password inline, right one signs in |
| OF-68 | Signed-in account picker | `account_id` radios; closed accounts disabled; "create account" | `cart/includes/checkout/account.tpl` | Tested | order.spec toggle, closed account disabled, order on the picked account |
| OF-69 | Linked accounts and social sign-in | Provider buttons for new and existing customers | `cart/linkedaccounts.tpl` | None | Needs a provider |
| OF-70 | Domain registrant contact | `contact` select; "add new" reveals the fields | `cart/includes/checkout/domain-registrant.tpl` | Tested | order.spec "add new" registrant |
| OF-71 | Captcha, terms, notes, marketing opt-in | `accepttos`, `notes`, opt-in | `cart/checkout.tpl` | Partial | order.spec notes and opt-in saved; terms and captcha: none (both off on this install) |
| OF-72 | Credit and gateways | Apply-credit radios (full credit hides CVV); gateway cards; gateway errors | `cart/includes/checkout/payment.tpl` | Tested | order.spec full credit pays, partial credit 10.00 plus bank transfer; F-buy |
| OF-73 | Card and stored methods | New card fields (offline CC is active in fixtures); saved methods, brand detection, expired cards disabled | `cart/includes/checkout/payment.tpl`, `cart/includes/existing-paymethods.tpl` | Tested | order.spec new card, saved card brand, expired disabled, CVV |
| OF-74 | Summary and Complete Order | Lines and totals; button outside the form via `form=`; re-enabled after a gateway error | `cart/includes/checkout/summary-aside.tpl` | Tested | order.spec invoice lines; F-buy; a mistyped card number is a known bug (bug 45) |
| OF-75 | Live total and VAT | `CartTotalUpdater` on country, state, tax ID; `VatValidator`; duplicate ids | `cart/checkout.tpl` | Tested | order.spec total gains VAT, invoice tax 2.60; the summary aside is a known bug (bug 46) |
| OF-76 | Express checkout | Express output and "Confirm & Pay" label | `cart/includes/checkout/payment.tpl` | None | |

### OF-I After checkout

| ID | Feature | What to verify | Key files | Coverage | Tests |
|---|---|---|---|---|---|
| OF-77 | Complete page | Order number; express info and errors; unpaid-invoice notice with link; addon output; Continue | `cart/complete.tpl` | Partial | order.spec paid complete page; F-free; unpaid notice: none (`AutoRedirectoInvoice=gateway` skips the page) |
| OF-78 | Recommendations | Inline on complete; modal with a template | `cart/includes/product-recommendations.tpl`, `cart/recommendations-modal.tpl` | None | See OF-09: WHMCS reported no recommendations |
| OF-79 | Fraud check | Validation iframe modal, or error with a ticket link | `cart/fraudcheck.tpl` | None | coverage.mjs: local |
| OF-80 | Error page | Title, message, Go back, ticket link | `cart/error.tpl` | Tested | order.spec out-of-stock plan reaches the error page |
| OF-81 | MarketConnect promo | Price, add button, expander, features | `cart/marketconnect-promo.tpl` | None | |

### OF-J Renewals and addons

| ID | Feature | What to verify | Key files | Coverage | Tests |
|---|---|---|---|---|---|
| OF-82 | Domain renewals | Grace and redemption pills, period select with fees, AJAX add, filter, totals, remove | `cart/domain-renewals.tpl` | Tested | order.spec 2 years at 27.98, summary, cart, removed; smoke, sweep |
| OF-83 | Service and addon renewals | Recursive items; show non-renewable; filter; add | `cart/service-renewals.tpl`, `service-renewal-item.tpl` | Partial | order.spec non-renewable services behind the toggle; adding a service renewal: none (WHMCS lists none as renewable) |
| OF-84 | Renewals in cart and summary | Renewal cards; grace fees in the summary | `cart/viewcart.tpl`, `cart/ordersummary.tpl` | Tested | order.spec renewal card; the checkout aside is a known bug (bug 47) |
| OF-85 | Addons page | Product select, price, setup, `a=add&aid` | `cart/addons.tpl` | Tested | order.spec 99.00 add-on on an annual service; smoke, sweep |

### OF-K Cross-cutting

| ID | Feature | What to verify | Key files | Coverage | Tests |
|---|---|---|---|---|---|
| OF-86 | Assets and version | `style.min.css`, `custom.css`, standard_cart `scripts.min.js`; `?v=` bumped by hand in `common.tpl` | `cart/common.tpl` | Tested | order.spec `?v=` on every cart page; sweep, browser |
| OF-87 | Card controls forced inside | Body script sets `data-svc-layout="inside"` on every cart page | `cart/common.tpl` | Tested | order.spec every cart page |
| OF-88 | "Free" label in the cart | `free-price.tpl`, the `.hn-free-label` gate for AJAX fragments, `common.tpl` JS on `ajaxComplete`, cycle switcher, configure promo | `cart/includes/free-price.tpl`, `cart/common.tpl`, `cart/css/custom.css` | Tested | settings.spec store page; theme-settings.spec cart and checkout summary (DB-set); domain search: none; check-free-price skips the cart copies |
| OF-89 | Dark mode and style inheritance | Type scale and font from the theme; bridged `--vl-*` tokens | `cart/css/style.min.css`, `cart/css/custom.css` | Tested | order.spec checkout, configure, domains in light and dark; browser.spec store, product, viewcart |
| OF-90 | CDN dependencies | jQuery, Bootstrap, multiselect, intl-tel-input from CDNs; no local fallback | `T/header.tpl`, `cart/checkout.tpl` | Tested | order.spec jQuery CDN blocked; F-nocdn jsdelivr blocked |
| OF-91 | Canonical and hreflang in the cart | Built by `resolveSeoContext`; `currency`, `language` stripped | `T/header.tpl`, `Hooks.php` | Tested | order.spec; known bug 9 |
| OF-92 | Order-area layouts | Cart pages report `data-area="order"` and use that area's pick | `Hooks.php`, `T/header.tpl` | Tested | settings.spec layouts by area |
| OF-93 | Preview parameters on a live cart | `?plan`, `?data`, `?product` not gated; `?subnav=off` is | `T/header.tpl` | Tested | order.spec `?plan` and `?data`; known bug 15 |
| OF-94 | Template safety | Compile, form contracts, lang keys, foreach props, ASCII CSS | `tests/compile/compile-all.php`, `tests/static/` | Static | blocking static tier |
| OF-95 | Source deny | `.htaccess` refuses direct requests for `.tpl`, `.md`, `.yaml`, `.json` | `cart/.htaccess` | Tested | order.spec `.tpl`, `.md`, `.yaml` 403, CSS 200 |

## PB: Page Builder module

Requires Hadrian and the theme's `module-page.tpl`. Built pages are listed in Hadrian's Pages screen; the module keeps only its editor. Pages are served from their slugs through WHMCS's not-found hook, with no `.htaccess`.

### PB-A Lifecycle and schema

| ID | Feature | What to verify | Key files | Coverage | Tests |
|---|---|---|---|---|---|
| PB-01 | Activate | Creates `hadrian_builder_settings` and `hadrian_builder_pages`; returns "info" with the reason when Hadrian can't be used | `PB/HadrianBuilder.php`, `PB/src/Schema.php` | None | |
| PB-02 | Deactivate | "Remove data" drops both tables (every page); without it rows stay and pages stop being served | `PB/HadrianBuilder.php` | None | |
| PB-03 | Upgrade and self-heal | `ensure()` on upgrade and every admin request adds the `replaces` and `replace_rule` columns and index | `PB/src/Schema.php` | None | Local tables already exist |
| PB-04 | Settings store | JSON key/value; a missing table returns the default and isn't cached | `PB/src/Store.php` | Partial | php/builder.php mode, indirect |

### PB-B Contract with Hadrian

| ID | Feature | What to verify | Key files | Coverage | Tests |
|---|---|---|---|---|---|
| PB-05 | Availability gate | Hadrian autoload missing, Hadrian inactive, or theme without `module-page.tpl`: "needs Hadrian" box, nothing deleted | `PB/src/Bridge.php`, `AdminController::unavailable` | None | |
| PB-06 | Older Hadrian | No `ExtensionPages` class: the editor refuses with "Update Hadrian" | `Bridge::listsPages` | None | |
| PB-07 | Router degrades | Hadrian unavailable or an exception: WHMCS's own 404 | `PB/src/Router.php` | None | |
| PB-08 | Registry sync | `pagesChanged()` after create, save, publish, unpublish, delete, mode, replace; never throws; a failed page list is reported, not answered as no pages | `Bridge::pagesChanged`, `PB/src/Page.php` (forSite) | Tested | builder.spec registry checks; test-extension-page-rows |
| PB-09 | Admin shell and Extensions card | Hadrian header and footer; Pages highlighted; version pill; card on Extensions, no nav tab | `PB/hooks.php`, `AdminController::view` | Tested | builder.spec test 1 |

### PB-C Admin actions

| ID | Feature | What to verify | Key files | Coverage | Tests |
|---|---|---|---|---|---|
| PB-10 | Module URL redirect | `?module=HadrianBuilder` or an unknown action goes to `Pages#tab=Built` | `AdminController::dispatch` | Tested | builder.spec |
| PB-11 | Create page | Name required, up to 120; slug suggested and left blank if taken; meta title = name | `AdminController::create`, `PB/src/SitePages.php` | Partial | suggested slug; empty name, taken slug: none |
| PB-12 | Delete page | POST after a confirm; removes the row and preview session; registry row dropped | `AdminController::delete` | Tested | builder.spec |
| PB-13 | Website served by | Mode `theme` or `builder` only; the panel counts pages serving | `setMode`, `PB/src/Replace.php` | Tested | builder.spec replace test |
| PB-14 | Replaces and rule | Targets only; rule follow, always, never; one page per target; Standby, Serving, Draft badge | `setReplaces`, `PB/src/Page.php` | Partial | builder.spec; one page per target: none |
| PB-15 | Built-tab rows | Draft, Published, Serving; builder description as SEO fallback | `SitePages::rows` | Partial | status; fallback: none |

### PB-D Visual editor

| ID | Feature | What to verify | Key files | Coverage | Tests |
|---|---|---|---|---|---|
| PB-16 | Editor layout | Rail and panel on the left, live preview on the right; boot JSON hex-escaped | `PB/views/editor.tpl` | Renders | builder.spec loads and settles |
| PB-17 | Add a section | Categories; search across all 75; inserts after the selection or at the end | `page-builder.js` | Tested | builder.spec |
| PB-18 | Drag onto the page and "+" buttons | Drop line in the frame; "+" above or below a section | `page-builder.js` | None | |
| PB-19 | Hover preview | `?hb_sample=<type>` draws one section with the current language and look | `Router::sample` | Tested | builder.spec |
| PB-20 | Select and locate | Click in the frame selects; text click flashes its field; prev/next | `page-builder.js` | Tested | builder.spec |
| PB-21 | Inline typing | Double-click types on the page; Enter commits, Esc reverts; reload held while typing | `page-builder.js` | Partial | Enter only |
| PB-22 | Move | Panel buttons, frame toolbar, Alt+Up/Down, drag in Layers | `page-builder.js` | Partial | panel button, Layers drag |
| PB-23 | Duplicate, hide, remove | Duplicate gets a new id and a cleared anchor; hide drops it live; remove has a toast, no confirm | `page-builder.js` | Partial | count, hidden marker; anchor clearing: none |
| PB-24 | Undo and redo | 80 steps; keystrokes within 1 s merge; Ctrl+Z, Ctrl+Y, Ctrl+Shift+Z | `page-builder.js` | Partial | buttons only |
| PB-25 | Save, publish, take offline | Ctrl+S saves; publish saves first; offline confirms; draft-newer badge | `page-builder.js` | Partial | Ctrl+S: none |
| PB-26 | Page panel | Name, address with inline errors, translatable meta title and description | `page-builder.js` | Partial | slug errors |
| PB-27 | Section tab | Spacing, anchor, hide from page | `PB/views/assets/js/fields.js` | Static | wrapper output only |
| PB-28 | Field controls | Text, textarea, lines, link, number, toggle, select, product, icon grid, rich text, image picker, lists | `fields.js` | Partial | text, product, "Add plan" |
| PB-29 | Device and look | Desktop 1280, tablet 820, mobile 390; "Preview with" style, nav, footer, theme for this admin only | `page-builder.js`, `Bridge::lookQuery` | Tested | builder.spec, including guest 404 on the look token |
| PB-30 | Unsaved-changes guard | `beforeunload` warning | `page-builder.js` | None | |
| PB-31 | Script integrity | Editor, fields and section-list scripts parse | `PB/views/assets/js/` | Static | builder-editor-js, builder-fields-js, builder-content-js |

### PB-E Section list in Pages

| ID | Feature | What to verify | Key files | Coverage | Tests |
|---|---|---|---|---|---|
| PB-32 | Render | Printed outside Hadrian's settings form; empty when Hadrian is unavailable or the page is gone | `PB/src/ContentPanel.php` | Tested | builder.spec |
| PB-33 | Add and edit | Dialog with categories and search; one row open; summary follows typing | `content-list.js` | Tested | builder.spec |
| PB-34 | Reorder, hide, duplicate, remove | Buttons and drag; remove confirms; no undo | `content-list.js` | Partial | move up only |
| PB-35 | Save draft and publish | Saves sections only; publish saves first if dirty | `content-list.js`, `apiContent` | Tested | builder.spec |
| PB-36 | Preview, language, leave guard | Preview in a new tab with popup-blocked message; language select; confirm before leaving when dirty | `content-list.js` | None | |

### PB-F JSON API, auth, CSRF

| ID | Feature | What to verify | Key files | Coverage | Tests |
|---|---|---|---|---|---|
| PB-37 | API dispatch | Inside `_output` after WHMCS login; 405 not POST, 400 bad JSON, 403 token, 409 Hadrian down, 404 unknown page, 500 | `AdminController::api` | Partial | guest 302 and wrong token 403; others: none |
| PB-38 | Form-post CSRF | create, delete, mode, replace need POST and token | `requirePost` | Partial | forged create and delete; mode and replace: none |
| PB-39 | api-preview | Normalised document in the session; URL with language, cache-buster, look token | `apiPreview` | Tested | builder.spec |
| PB-40 | api-save | Name required; slug up to 3 parts, lowercase and hyphens, not `hb-preview/*`, unique, required while published | `apiSave` | Partial | bad slug, empty on publish; duplicate, reserved, name: none |
| PB-41 | api-publish and api-unpublish | Publish needs a slug and copies draft to published; unpublish keeps both | `Page::publish` | Tested | builder.spec |

### PB-G Document and sanitiser

| ID | Feature | What to verify | Key files | Coverage | Tests |
|---|---|---|---|---|---|
| PB-42 | Document normalise | Version 1, up to 60 sections, unknown types dropped without a warning, duplicate ids re-minted, spacing, anchor, hidden | `PB/src/Document.php` | Static | test-builder-engine |
| PB-43 | Prop casting | Typed per field; text 500, textarea 4000; lists capped; unknown props dropped | `PB/src/Sections.php` | Static | test-builder-engine |
| PB-44 | Translations | Default `_` kept; uninstalled languages and empty translations dropped | `Sections::l10n`, `PB/src/Text.php` | Static | test-builder-engine |
| PB-45 | Links, images, slugs | `javascript:`, `data:`, `vbscript:`, `file:`, `//` refused; bare domains get https | `PB/src/Text.php` | Static | test-builder-engine |
| PB-46 | Rich-text sanitiser | DOM allow-list; script, iframe, svg dropped with content; only `href` kept; `rel=noopener` on external links | `PB/src/Sanitizer.php` | Static | test-builder-engine |
| PB-47 | Template injection | Values assigned, never compiled; every print escaped | `PB/src/Renderer.php`, `PB/sections/*.tpl` | Static | check-builder-section; test-builder-engine |

### PB-H Rendering and live data

| ID | Feature | What to verify | Key files | Coverage | Tests |
|---|---|---|---|---|---|
| PB-48 | Page render | Own Smarty; hidden sections skipped; a failing section dropped live and explained in preview; empty-page note | `PB/src/Renderer.php` | Static | test-builder-engine; failing section: none |
| PB-49 | Products | One catalogue call per section; prices in the visitor's currency; retired products hidden; add-to-cart links | `PB/src/Catalog.php` | Partial | stand-in catalogue; one real price in builder.spec; cycles, retired: none |
| PB-50 | Announcements | Newest published, 1-24, translated, 180-character excerpt | `Catalog::announcements` | Static | stand-in data only |
| PB-51 | Theme overrides | `templates/<theme>/core/sections/<name>/` replaces or adds a section | `Sections::dirs` | Static | test-builder-engine |

### PB-I Routing and serving

| ID | Feature | What to verify | Key files | Coverage | Tests |
|---|---|---|---|---|---|
| PB-52 | Not-found hook | GET and HEAD only; `/slug`, `/index.php/slug`, `?rp=`; install folder stripped; paths over 160 ignored | `Router::intercept` | Partial | `/slug` and `?rp=`; `/index.php/slug`, subfolder, POST: none |
| PB-53 | Serve | 200; title from meta or name; `module-page.tpl`; `pageKey built-<id>` | `Router::serve` | Tested | builder.spec |
| PB-54 | WHMCS routes win | A slug WHMCS answers never reaches the hook | `PB/src/Router.php` | Tested | builder.spec (knowledgebase) |
| PB-55 | Drafts and preview | Only published pages by slug; `/hb-preview/<id>` for admins with noindex and no-store | `Page::bySlug`, `Router::resolve` | Tested | builder.spec |

### PB-J Replacing theme pages

| ID | Feature | What to verify | Key files | Coverage | Tests |
|---|---|---|---|---|---|
| PB-56 | Targets and rules | Homepage, announcements, knowledgebase, contact; drafts never serve | `PB/src/Replace.php` | Tested | test-builder-engine; builder.spec |
| PB-57 | Front door only | Own path plus neutral query keys | `Replace::frontDoor` | Tested | test-builder-engine; builder.spec (`?page=2`) |
| PB-58 | Admin bypass | `?hb_original=1` shows the theme page to a signed-in admin; nothing links to it | `Router::interceptReplaced` | None | |
| PB-59 | Canonical address | A stand-in names the theme page's canonical and `og:url` | Hadrian `Hooks.php` | Tested | sitemap.spec; php/sitemap.php standin |

### PB-K Pages, SEO, languages, media, sections

| ID | Feature | What to verify | Key files | Coverage | Tests |
|---|---|---|---|---|---|
| PB-60 | Registry row lifecycle | Created on save; URL and published synced; settings made in Pages kept; removed on delete | `SitePages::rows`, Hadrian `PageRegistry` | Tested | builder.spec |
| PB-61 | Sitemap | Listed only when live and public | Hadrian `SitemapGenerator` | Tested | builder.spec |
| PB-62 | Visibility | Pages "auth" sends guests to login | Hadrian `Hooks.php` | Tested | builder.spec |
| PB-63 | SEO description precedence | Pages description wins over the builder's | `SitePages`, `ExtensionPages` | Partial | Pages description; fallback: none |
| PB-64 | Translations served | Editor shows Hadrian's languages; visitor language from WHMCS | `Router::language` | Tested | builder.spec `?language=` |
| PB-65 | Per-language meta | Title and description per language | `Document::normalizeMeta` | None | |
| PB-66 | Image picker and "used in" | Hadrian media picker; `MediaSource::rows` feeds the Media screen | `fields.js`, `PB/src/MediaSource.php` | None | test-media uses hand-built rows |
| PB-67 | Section catalogue | 75 sections, each `name.php` plus `name.tpl`; renders defaults, empty and hostile input; tags balance; no inline handlers; no dead links | `PB/sections/*` | Static | check-builder-section, server render only |
| PB-68 | Section scripts in a browser | pricing-toggle, pricing-finance, tab-switcher, sticky section-nav, accordions, testimonial carousels, maps and globe, marquees; `#anchor` links | `PB/sections/*` | None | |

Section families: hero (12), pricing (7), features (20), locations (7), testimonials (6), questions (4), trust and numbers (7), call to action (3), announcements (5), articles (1), product tiles (3). Announce-grid and announce-list read live announcements. All 7 pricing sections and hero-centered read live prices.

### Unfinished in Page Builder

- The working tree's ContentPanel, MediaSource, field and section-list assets, the look bar and `Router::sample` depend on Hadrian files that are untracked or modified (`Helpers/SiteLook.php`, `Helpers/MediaUsage.php`, `CustomizePreview::LOOK_PARAM`). Committing the builder alone would break it.
- The empty-preview note says "fill in its fields on the right". The fields are on the left now.
- The AdminController docblock still describes the old list screen. `Page::all()` and `Store::flush()` are unused.
- The visual editor has undo and removes without asking. The section list has no undo and asks before removing.

## EM: Email Templates module

Requires Hadrian. It wraps WHMCS's client emails in a global header, footer and CSS, and can replace individual email bodies. Turning it off must restore WHMCS byte for byte.

### EM-A Lifecycle

| ID | Feature | What to verify | Key files | Coverage | Tests |
|---|---|---|---|---|---|
| EM-01 | Activate | Creates the designs and settings tables; mail untouched until "Turn on"; "info" if Hadrian can't be used | `EM/HadrianEmail.php`, `EM/src/Schema.php` | None | |
| EM-02 | Deactivate | Always runs `Takeover::disable()`; "Remove data" restores every published template, then drops the tables | `EM/HadrianEmail.php` | None | `Takeover::disable` itself: email-live |
| EM-03 | Upgrade and self-heal | `ensure()` on upgrade and every admin request | `AdminController::ensureSchema` | None | |
| EM-04 | Own settings table | The WHMCS mail backup survives Hadrian's Database Clear | `EM/src/Store.php` | Partial | email-live, indirect |

### EM-B Contract with Hadrian

| ID | Feature | What to verify | Key files | Coverage | Tests |
|---|---|---|---|---|---|
| EM-05 | Availability | Fails only when Hadrian's autoload is missing or Hadrian is inactive | `EM/src/Bridge.php` | Tested | email.spec "stands down" |
| EM-06 | Stand-down screen | "Needs Hadrian"; with the takeover on, `disable-standalone` gives WHMCS its mail settings back | `AdminController::unavailable` | Partial | message, no Turn on, forged enable refused; disable-standalone: none |
| EM-07 | Sending without Hadrian | The hook answers nothing; the guarded static header still brands the mail | `EM/src/SendHook.php` | Partial | email-live, forced with `enabled=false` |
| EM-08 | Brand data | Theme colours and overrides, font stack, company, logos, social links, footer-secondary links | `Bridge`, `EM/src/Theme.php`, `EM/src/Palette.php` | Partial | test-email-engine palette; logos, social, links: none |
| EM-09 | Nav and shell | Email tab, Extensions card, Hadrian CSS in head | `EM/hooks.php` | Tested | email.spec test 1 |

### EM-C Overview screen

| ID | Feature | What to verify | Key files | Coverage | Tests |
|---|---|---|---|---|---|
| EM-10 | Turn on and off | On: default layout if none, backs up the 3 WHMCS settings once, writes guarded placeholders. Off: confirm, restore, forget the backup | `AdminController::enable`, `disable`, `EM/src/Takeover.php` | Tested | email.spec with Mailpit; email-live; byte-for-byte afterAll |
| EM-11 | Refresh on visit | A plain GET recomputes the signature (brand, layout, year) and, if changed, rewrites the header and recompiles every published design from its published copy | `AdminController::index`, `Takeover::isStale` | None | The recompile itself: email-live (EM-38) |
| EM-12 | Design cards | Card, Banner, Letter rendered live; "Use X" switches and keeps content | `EM/src/Designs.php` | Tested | email.spec, Banner and Letter in Mailpit |
| EM-13 | Appearance | Mode auto, light, dark; logos; width 480-720; radius 0-28; custom CSS up to 8000 with `</style>` and comments stripped; saving recompiles published designs from their published copies | `saveSettings`, `Theme::normalizeSettings` | None | Guest 302 only |
| EM-14 | Logo warning | SVG or WebP logo warns and the company name is used | `Theme::logos` | None | |
| EM-15 | Email list | Client templates by type (admin and notification hidden), filter, badges, starter and disabled tags | `EM/views/index.tpl`, `Publisher::templates` | Partial | rows, admin hidden, Published badge; "Edited in WHMCS" badge: none |
| EM-16 | Mail-tab drift banner | Names the edited setting; "Use the Hadrian layout again" or "Keep that edit and turn off" | `EM/views/index.tpl`, `reapply`, `disable(keep)` | Partial | email-live detects and forces; UI: none |
| EM-17 | Remove design | Confirm; restores the WHMCS template if published; deletes the row | `AdminController::delete` | Tested | email.spec, template hash back |

### EM-D Takeover and send hook

| ID | Feature | What to verify | Key files | Coverage | Tests |
|---|---|---|---|---|---|
| EM-18 | Guarded placeholder | `{if $field}{$field}{else}static{/if}`, entity-encoded the way WHMCS stores it | `Takeover::refresh` | Tested | email-live |
| EM-19 | Backup safety | Turning on twice must not back up Hadrian's own placeholders as the originals | `Takeover::enable` | None | |
| EM-20 | Byte-for-byte restore | Off writes the backed-up values back exactly | `Takeover::disable` | Tested | email-live; email.spec afterAll |
| EM-21 | Drift guard | A background refresh skips settings edited in WHMCS; a forced one overwrites | `Takeover::drift` | Tested | email-live |
| EM-22 | Send hook | Recipient language picks the layout; subject title, preheader (from the published copy) and merge fields filled; any error answers nothing | `EM/src/SendHook.php` | Tested | email-live, including a saved edit not reaching the preview line; email.spec Mailpit |
| EM-23 | Static fallback | Default-language Smarty with per-email fields removed, logic stripped, CSS in `{literal}`, stray braces escaped | `Renderer::fallback`, `Merge::protect` | Tested | email-live; test-email-engine |

### EM-E Builder

| ID | Feature | What to verify | Key files | Coverage | Tests |
|---|---|---|---|---|---|
| EM-24 | Open | Layout or a named template; starts from the saved design, a starter or the imported WHMCS body; unknown template redirects | `AdminController::builder`, `EM/src/Presets.php` | Tested | email.spec |
| EM-25 | Insert and drag | Insert after the selection; drag onto canvas or outline | `email-builder.js` | Tested | email.spec |
| EM-26 | Keyboard | Arrows, Alt+arrows, Delete, Ctrl+D, Esc; the content slot can't be deleted | `email-builder.js` | Partial | Ctrl+D: none |
| EM-27 | Inspector fields | Rich text, url, image, number, select, toggle, link and row repeaters, raw code | `email-builder.js` | Partial | heading, callout text |
| EM-28 | Email settings | Subject (empty keeps WHMCS's), preview text, translatable; "Unpublish and restore" | `email-builder.js` | None | |
| EM-29 | Merge-field help | Fields by template type; chips copy; popover inserts at the cursor | `EM/src/MergeFields.php` | None | |
| EM-30 | Preview | Sandboxed frame, light and dark, desktop and mobile, size in KB, sample data | `apiPreview`, `EM/src/Samples.php` | Partial | dark background; RTL through the API |
| EM-31 | Status and unsaved guard | Status labels; `beforeunload` | `email-builder.js` | Partial | some labels |
| EM-32 | Script integrity | Builder script parses; templates balance | `EM/views/` | Static | email-builder-js; email-smarty-lint |

### EM-F Save, publish, restore

| ID | Feature | What to verify | Key files | Coverage | Tests |
|---|---|---|---|---|---|
| EM-33 | Save an email | Creates or updates the design; status kept; unknown template 422 | `apiSave` | Partial | indirect; 422: none |
| EM-34 | Save the layout | Live at once: rewrites WHMCS's header with no lint | `apiSave`, `Takeover::refresh` | Tested | email.spec in Mailpit |
| EM-35 | Publish | Refuses an empty design; compiles and lints every language first; one transaction | `Publisher::publish` | Partial | email-live; error paths: none |
| EM-36 | Restore | Puts the backed-up rows back exactly; deletes rows it created | `Publisher::restore` | Tested | email-live; email.spec |
| EM-37 | Edited in WHMCS | Per-language hash drift: badge, builder warning, skipped by bulk recompile | `Publisher::drift` | Partial | email-live; badge: none |
| EM-38 | Bulk recompile | `republishAll` republishes every non-drifted published design from its published copy and leaves the saved draft alone; designs with no copy yet are skipped | `Publisher::republishAll` | Tested | email-live: drifted case, and a saved edit staying a draft |

### EM-G Document

| ID | Feature | What to verify | Key files | Coverage | Tests |
|---|---|---|---|---|---|
| EM-39 | Blocks | 13 types scoped to layout, message or both; exactly one content slot; raw HTML in messages only | `EM/src/Blocks.php` | Static | test-email-engine |
| EM-40 | Casting limits | Up to 60 blocks; numbers clamped; code up to 60000; ids re-minted | `Blocks::cast` | Static | test-email-engine |
| EM-41 | URLs and images | Dangerous schemes refused; http(s), mailto, tel, merge fields kept | `Blocks::url` | Static | test-email-engine |
| EM-42 | Rich-text sanitiser | Allow-listed tags; only `href`; Smarty operators restored inside tags; quote inside a merge field untested | `EM/src/Sanitizer.php` | Static | test-email-engine |
| EM-43 | Merge handling | Stray braces escaped; single-pass substitution; Price objects to strings; block balance lint | `EM/src/Merge.php` | Static | test-email-engine |

### EM-H Rendering

| ID | Feature | What to verify | Key files | Coverage | Tests |
|---|---|---|---|---|---|
| EM-44 | Skeleton | Table layout, Outlook conditionals, preheader, color-scheme metas, no web fonts, opaque hex, small size | `EM/src/Renderer.php` | Tested | test-email-engine; email-live under 30 KB |
| EM-45 | Light and dark | Auto adds a media query, Outlook rules and the dark logo; forced writes colours inline | `Renderer::css` | Tested | test-email-engine; email.spec |
| EM-46 | Designs | Card, Banner (band readable at 4.5:1), Letter | `Designs`, `Palette` | Tested | test-email-engine; email.spec; email-live |
| EM-47 | Block output | Heading, text, button, details, callout, image (absolute, width limited), divider, spacer, raw HTML | `Renderer` | Partial | image, details: none |

### EM-I Languages

| ID | Feature | What to verify | Key files | Coverage | Tests |
|---|---|---|---|---|---|
| EM-48 | Per-language publish | One template row per translated language; fallback; subject only if translated; row comes back if a translation goes | `Publisher` | Tested | email-live |
| EM-49 | Recipient language at send | `client_language` picks the header and footer language | `SendHook` | Static | French footer render only |
| EM-50 | RTL | `dir=rtl` with mirrored alignment | `Theme::isRtl`, `Renderer` | Tested | test-email-engine; email.spec; email-live |

### EM-J API and media

| ID | Feature | What to verify | Key files | Coverage | Tests |
|---|---|---|---|---|---|
| EM-51 | JSON endpoints | preview, save, publish, restore: POST, JSON, token, 409 without Hadrian | `AdminController::api` | Partial | guest 302 and wrong token 403 |
| EM-52 | Form posts | enable, disable, reapply, settings, delete, design need POST and token | `requirePost` | Partial | guest 302 on 5 (not `design`); forged enable only |
| EM-53 | Pickers and "used in" | Logo and image pickers; `rows()` also counts images in the backed-up WHMCS header | `EM/src/MediaSource.php` | None | |

### Unfinished in Email Templates

- The builder has no undo or redo.
- The version is hardcoded as `'1.0.0'` in both `HadrianEmail.php` and `hooks.php`.
- The `pending` flag compares a fresh compile to the published hash, so any theme colour change marks every published design as changed.
- `Design::tableExists()` and `Store::flush()` are unused; `Renderer::forSend()` is used only by tests.
