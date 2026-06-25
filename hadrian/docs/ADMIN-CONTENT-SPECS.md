# Hadrian Admin Panel — Page Content Specifications

A **style-agnostic content blueprint** of the **Hadrian addon's admin panel** — the configuration UI an administrator sees inside WHMCS admin (Addons → Hadrian). Hand this to a design AI to regenerate the admin panel in a different aesthetic: the specs describe **what content, controls, and settings** each screen must contain — never how it currently looks.

> **Generated:** 2026-05-26 · Source of truth: the `.tpl` files under `modules/addons/Hadrian/views/adminarea/`.
>
> **Scope:** this documents the *admin configuration panel only* — NOT the client-area theme it configures (that lives in `templates/hadrian/` and is documented separately in `CONTENT-SPECS.md`).

---

## How to use this document

- Each page entry is a **content contract**: keep the controls, settings, and data; restyle the presentation freely.
- **Controls are described by function** ("toggle switch", "color swatch + hex field", "drag-and-drop tree"), not by the current CSS classes or visual style.
- The whole panel renders inside one shared shell (below) and one shared design system. Design those once; each page just fills the content card.

### Per-page schema (legend)

| Field | Meaning |
|---|---|
| **Route** | WHMCS admin path (`?module=Hadrian&action=…`). |
| **Purpose** | One sentence: what the admin accomplishes here. |
| **Layout shape** | Structural arrangement only (card, columns, table, grid). |
| **Page header** | Eyebrow / title / subtitle text. |
| **Sections** | Ordered content blocks, top → bottom. |
| **Key data fields / settings** | The settings, inputs, options, and data shown. |
| **Actions / CTAs** | Buttons, links, form submits, save/reset actions. |
| **States & conditionals** | Empty vs populated, flash banners, gated blocks. |
| **Interactions** | Client-side behaviour (tabs, AJAX save, drag-reorder, pickers, live preview). |

---

## The admin shell (wraps every page)

Every admin page is `{include}`-wrapped by `includes/header.tpl` (opens) and `includes/footer.tpl` (closes + ships the design system). The chrome is identical on every page:

- **Brand bar** — a brand mark + product name + version on the left; "Docs" and "Report bug" outbound links on the right.
- **Pill top-nav** — the primary navigation: **Info · Settings · Styles · Layouts · Pages · Menu · Branding · Extensions · Tools**. The active section is highlighted; sub-views (e.g. edit-style, edit-menu, license, templates) map back to their parent tab for highlighting.
- **Content card** — a single rounded surface that every page's body renders inside.
- **Page header pattern** — most pages open with an eyebrow (small overline), a large title, and a subtitle line (optionally with an inline meta count).

The shell is centred, max-width-constrained, and fully self-contained (its CSS is scoped so it never leaks into the rest of WHMCS admin).

### Implementation conventions (re-skin must preserve these)

- **Inline assets per page** — each page's page-specific CSS/JS is inlined and wrapped in Smarty `{literal}` blocks (WHMCS's Smarty otherwise mis-parses `{ }`).
- **No-JS fallback + AJAX enhancement** — interactive pages (Branding uploads, Styles panels, Menu builder) work as plain server-posted forms with flash banners, then layer AJAX/live behaviour on top when JS is available.
- **License gate** — a license banner/page can gate the panel when the addon isn't licensed (see the License page + banner partial).

---

## Shared control vocabulary (reused across pages)

Design each once; pages compose them. (Named by function, not by current styling.)

- **Page header** — eyebrow + title + subtitle (+ optional meta count).
- **Section** — a titled group with an optional header tools row (count, buttons, search).
- **Tabs / segmented control** — in-card view switchers (e.g. Light/Dark, panel tabs).
- **Sub-category nav** — a vertical list that switches the active right-hand panel (used by the Styles editor).
- **Badge** — small status label (success / warning / danger / primary / neutral).
- **Buttons** — primary, secondary (outline), ghost; plus a small size and a disabled state.
- **Form controls** — text input, select (custom caret), textarea; field label + help text + char counter; inline label↔control rows.
- **Toggle switch** — on/off setting control.
- **Row / definition list** — label-on-left, value-or-control-on-right setting rows; and read-only key/value detail lists.
- **Data table** — sortable/hoverable rows with a name cell and right-aligned actions.
- **Card grid** — selectable cards (e.g. templates/variants) with thumbnail, title, meta, edit link, radio-select.
- **Scheme chips** — pill-shaped preset selectors with a colour dot.
- **Colour controls** — per-token row = native colour swatch + hex/rgba text field (kept in sync); colour-tile grids; gradient tiles.
- **Variant tiles** — selectable option tiles (active state).
- **Upload dropzone** — dashed drop area with icon + hint, or a filled preview with replace/remove overlay; loading + error states.
- **Toolbar / back link** — sub-view top bar with a back affordance.
- **Menu tree** — drag-and-drop nested list with handles, type badges, per-row actions, drop indicators, and an add-row.
- **Icon picker** — trigger showing the current icon + a searchable popover grid of icons.
- **Diagnostics grid** — read-only info/status cards (used by Tools/Info).
- **Empty state** — icon + title + copy when a list/table has no rows.
- **Alert banner** — info / success / warning / danger, often listing validation errors.

---

## Contents

1. **Info & system pages** — Info/overview, License, Templates (list + detail), Extensions, Tools, plus the landing and error pages.
2. **Configuration** — Settings, Layouts, Pages (list + edit), Menu (tree builder + item editor), Branding.
3. **Styles customizer** — the style editor shell + six panels: Colors, Typography, Buttons, Forms, Layout, Elements.

---

# Page specifications

## Info & system pages

### `index` — Addon dispatch / landing
- **Route:** Admin -> Addons -> Hadrian (?module=Hadrian&action=index)
- **Purpose:** Entry point for the addon; the default landing that resolves to the Info overview.
- **Layout shape:** No own body — a one-line Smarty stub that `{include}`s `templates/index.tpl`. (In practice the controller never renders this file: `action=index` is routed server-side to the Info controller, so the landing page is the Info page below.)
- **Page header:** none (inherited from whatever view it delegates to)
- **Sections (top → bottom):**
  1. **(delegation only)** — file body is a single include of the Templates list view; comment notes it is unused/kept as a guard so Smarty doesn't resolve the wrong file.
- **Key data fields / settings:** none of its own.
- **Actions / CTAs:** none of its own.
- **States & conditionals:** none.
- **Interactions:** Static, none.

### `info/index` — Info / overview
- **Route:** Admin -> Addons -> Hadrian -> Info (?module=Hadrian&action=info, also the default action=index)
- **Purpose:** Read-only overview of the active theme's version, license, and subscription/billing details.
- **Layout shape:** Single card; optional alert banner above a definition list (label/value pairs).
- **Page header:** eyebrow = "Theme"; title = "Info"; subtitle = "Version, license, and subscription information for this theme."
- **Sections (top → bottom):**
  1. **Dev-mode alert (conditional)** — warning banner shown only when development mode is on; explains license checks are bypassed and names the config file/flag (`core/hadrian.php` → `'dev_mode' => false`) to enable real validation.
  2. **Theme Information** — section titled "Theme Information" containing a definition list of read-only fields.
- **Key data fields / settings:** Theme Version (with optional "New version available" badge); Registration Date; Next Due Date; First Payment Amount; Recurring Amount; Payment Method; Support & Updates (Active vs Expired badge); License Key (shown as code, or "Not set"); License Status (badge: Dev mode / Active / other status text). Empty values render as a neutral "—" badge.
- **Actions / CTAs:** inline link beside License Key — "Set key" (when no key) or "Change" (when a key exists) → goes to the License page.
- **States & conditionals:** dev-mode banner only when devMode on; per-field empty placeholders ("—" / "Not set"); License Status badge branches on devMode vs Active vs other; Support badge branches on supportExpired; many fields are placeholders pending license-server/update-check wiring.
- **Interactions:** Static, none.

### `license/index` — License
- **Route:** Admin -> Addons -> Hadrian -> License (?module=Hadrian&action=license)
- **Purpose:** Show license state for the active template and let the admin enter/save and re-check the license key.
- **Layout shape:** Status alert banner above a single narrow card containing a key-entry form with an actions row.
- **Page header:** title = "License"; subtitle = "License status for <template name>."
- **Sections (top → bottom):**
  1. **Status alert (state-driven)** — one of three banners: dev-mode warning (with a numbered how-to-disable list referencing config files/keys: `core/<template>.php` → `dev_mode`, replace `secret_key`, and replace `LICENSE_SERVER_PUBLIC_KEY` / `$licenseServerUrl` in `License.php`); "License is active" success; or "License is not active" danger prompting to enter a key or contact support.
  2. **License key form** — section titled "License key"; a single text input for the key (with placeholder + help text) and an actions row.
- **Key data fields / settings:** license_key (text input, prefilled with current key, disabled in dev mode); help text varies by mode ("Form is disabled while dev_mode is active" vs "Find your key in your customer portal").
- **Actions / CTAs:** "Save and check" (submit — saves key and validates); "Refresh now" (submit with `refresh=1` — re-checks current key). Both disabled in dev mode. Form posts to self.
- **States & conditionals:** three mutually exclusive banner states (dev mode / active / inactive); input + both buttons disabled when devMode on.
- **Interactions:** standard form POST to self; no AJAX.

### `license/banner` — License-state dashboard banner (partial)
- Reusable warning/info banner partial (NOT a full page); rendered onto the WHMCS AdminHomepage by `License::getDashboardBanner()`. Branches color/severity by license state (DEV_MODE → warning; EXPIRED/INVALID/CANCELLED/BANNED → danger; else info), shows a state/days-aware message (e.g. "license expired", "expires in N days"), and offers two link buttons: "Renew" (external account URL, hidden in dev mode) and "Manage" (→ `action=license`). Carries its own small inline `<style>` block.

### `templates/index` — Templates
- **Route:** Admin -> Addons -> Hadrian -> Templates (?module=Hadrian&action=templates)
- **Purpose:** List installed themes/templates and pick one to configure (styles, layouts, pages).
- **Layout shape:** Single card containing a responsive grid of template cards; empty-state block when none.
- **Page header:** title = "Templates"; subtitle = "Manage installed themes. Pick one to configure styles, layouts and pages."
- **Sections (top → bottom):**
  1. **Installed** — section titled "Installed" with a count chip ("N found"); body holds either the card grid or the empty state.
  2. **Template cards (data-driven, repeating)** — one card per template: thumbnail showing the first initial, display name, "Version X" meta, and a status/action footer.
- **Key data fields / settings:** per template — slug, displayName, version, isActive, canActivate. Footer badge resolves to: Active / Ready (license valid) or "License invalid" (cannot activate).
- **Actions / CTAs:** per card — "Configure" → single-template detail page (`action=template` with `templateName=slug`) when licensable; otherwise "Set key" → License page. Active card is flagged.
- **States & conditionals:** populated grid vs empty state ("No templates installed" with instructions to drop a dir into `templates/`); per-card branch on canActivate (Configure vs Set key) and isActive (Active vs Ready badge).
- **Interactions:** Static, none (plain links).

### `templates/show` — Template detail
- **Route:** Admin -> Addons -> Hadrian -> Template (?module=Hadrian&action=template&templateName=<slug>)
- **Purpose:** Read-only summary of one template's available styles, layouts, and declared pages, with shortcuts into their editors.
- **Layout shape:** Two cards side-by-side (Styles, Layouts) followed by a full-width card (Pages); each card holds a simple list.
- **Page header:** title = template name with an inline "vX" version meta; subtitle = "Configure styles, layouts, and pages for this template."
- **Sections (top → bottom):**
  1. **Styles** — section titled "Styles" with a count chip; a list of style names; "Manage styles" button.
  2. **Layouts** — section titled "Layouts"; two sub-grouped lists under kickers "Main menu" and "Footer"; "Manage layouts" button.
  3. **Pages** — full-width section titled "Pages" with a "N declared" count chip; a flat list of declared page names (no actions).
- **Key data fields / settings:** template.name, version, styles[] (capitalized names), layouts['main-menu'][] and layouts.footer[], pages[] (declared page identifiers).
- **Actions / CTAs:** "Manage styles" → Styles picker (`action=styles`); "Manage layouts" → Layouts picker (`action=layouts`). Pages list has no CTA.
- **States & conditionals:** lists simply iterate provided arrays (empty arrays render nothing); invalid slug is handled upstream by rendering the generic error page instead.
- **Interactions:** Static, none.

### `extensions/index` — Extensions
- **Route:** Admin -> Addons -> Hadrian -> Extensions (?module=Hadrian&action=extensions)
- **Purpose:** Show optional theme add-ons (module integrations, custom widgets) registered for the theme.
- **Layout shape:** Single card with a grid of extension cards; empty-state block when none.
- **Page header:** eyebrow = "Theme"; title = "Extensions"; subtitle = "Optional theme add-ons (module integrations, custom widgets, etc.)."
- **Sections (top → bottom):**
  1. **Extension cards (data-driven, repeating)** — one card per extension: initial-letter thumbnail, extension name, "Theme extension" meta, and an "Enabled" status badge footer.
  2. **Empty state (conditional)** — "No extensions installed" with instructions to add under `core/extensions/<name>/` and register in `theme.json`.
- **Key data fields / settings:** extensions[] — a flat list of extension names; each is implicitly shown as Enabled.
- **Actions / CTAs:** none (display-only; no enable/disable/configure controls).
- **States & conditionals:** populated grid vs empty state.
- **Interactions:** Static, none.

### `tools/index` — Tools
- **Route:** Admin -> Addons -> Hadrian -> Tools (?module=Hadrian&action=tools)
- **Purpose:** Operational/diagnostic utilities — clear caches, rebuild discovery, refresh license, generate rewrite rules.
- **Layout shape:** Single card containing a vertical list of action rows (label + help on the left, a button on the right); optional success banner above.
- **Page header:** eyebrow = "Theme"; title = "Tools"; subtitle = "Operational utilities — cache flush, license refresh, htaccess generation."
- **Sections (top → bottom):**
  1. **Result banner (conditional)** — success alert showing the message returned after running a tool.
  2. **Tools form (single form, multiple submit buttons)** — six labeled action rows, each with its own submit button posting a distinct `tool` value.
- **Key data fields / settings:** each row = a named operation: Clear template cache (`clear_template_cache` — recompile Smarty next request); Refresh menu cache (`refresh_menu_cache`); Rebuild pages discovery (`rebuild_pages_cache` — re-scan `core/pages/`); Convert custom links to WHMCS pages (`migrate_menu_pages` — re-type matching `custom_link` menu items to `whmcs_page`, skipping cart deeplinks/external URLs, idempotent); Refresh license (`refresh_license` — force license-server callback); Generate Nginx / .htaccess rules (`generate_htaccess` — build SEO redirect rules).
- **Actions / CTAs:** per row a submit button (Clear / Refresh / Rebuild / Convert / Refresh / Generate); all post to self carrying the row's `tool` value; each triggers its server-side operation and returns a status message.
- **States & conditionals:** success banner only present after an operation runs (when a message exists).
- **Interactions:** standard form POST per button; no AJAX.

### `error` — Addon error
- **Route:** rendered by any addon action on failure (e.g. invalid `templateName` on `action=template`); no dedicated action of its own.
- **Purpose:** Generic fallback page shown when an addon action throws/fails.
- **Layout shape:** Single danger alert banner followed by a back link.
- **Page header:** title = "Error" (no subtitle).
- **Sections (top → bottom):**
  1. **Error alert** — danger banner: "Something went wrong." plus the escaped error message.
  2. **Back link** — button to return to the addon landing.
- **Key data fields / settings:** error (the exception/error message string).
- **Actions / CTAs:** "Back to templates" → addon index/landing (`action=index`).
- **States & conditionals:** always shows the single error state; message text varies by failure.
- **Interactions:** Static, none.

## Configuration

### `settings/index` — Settings
- **Route:** Admin -> Addons -> Hadrian -> Settings (?module=Hadrian&action=settings); two sub-tabs via `&tab=general` (default) and `&tab=order`.
- **Purpose:** Toggle all theme-wide on/off behavior flags, plus compound pickers (which languages clients can pick, sub-nav per-page exceptions, controls-layout per-page exceptions).
- **Layout shape:** Tab strip below header; single card whose rows are a uniform list of label+help on the left and a toggle switch on the right; certain toggles spawn an indented sub-block directly beneath them; save button in the card header and a second one in a footer row. Rows belonging to the inactive tab are hidden client-side.
- **Page header:** eyebrow = "Theme"; title = "Settings"; subtitle = "Theme-wide options. Save to apply."
- **Sections (top → bottom):**
  1. **Tab strip** — two tabs: "General" and "Order Process". Switching tabs reloads with `&tab=`; the active tab's rows show, others are hidden (display:none).
  2. **Settings card** — header with title ("General Settings" / "Order Process Settings") + inline "Save changes" button. Body is a data-driven loop over the flag list; each flag = one toggle row. Four specific flags also render an indented sub-block right under their row (no divider above it):
     - **Custom Language List** sub-block ("Languages shown to clients") — a chip multi-select (see below) listing installed `/lang/` languages, plus a selection counter; hidden until the toggle is on; shows "No language files found." when none installed.
     - **Order Category Sidebar** sub-block ("Per-page exceptions") — chip multi-select of order/cart pages that flip the global order-sidebar toggle.
     - **Website Section Sidebar** sub-block ("Per-page exceptions") — chip multi-select of client-area (non-order) pages that flip the global section-sidebar toggle.
     - **Float Controls Outside Cards** sub-block ("Per-page exceptions") — chip multi-select of ALL pages that flip the inside/outside controls choice.
  3. **Footer save row** — second "Save changes" submit, right-aligned.
- **Key data fields / settings:** all are boolean toggles unless noted. General tab: Custom Logo URL (logo click sends visitor to a URL), Sticky Sidebars, Gravatar (avatars by user details), Affixed Navigation (pin navbar on scroll), Cookie Box (consent banner), "0.00" → "Free" (render free items as "Free"), Show Status Icon (status icons in product/service lists), Table Cache Duration (cache rendered tables), Show Client ID (numeric ID in account dropdown), Enable Alternate Links (SEO multi-lang alternate links), Section Titles Capitalization (uppercase section titles), Disable CMS Menu Cache (dev bypass), Hide Billing Cycle Discounts (hide % savings), Enable Dynamic AJAX Loading (lazy-load panels), Custom Language List (toggle + a list of language codes), Enable Dark Mode (let visitors toggle dark), Top-Nav Icons (icons in top nav, off by default), Website Section Sidebar (+ exceptions list `subnav_pages_website`), Float Controls Outside Cards (+ exceptions list `controls_pages`). Order Process tab: Order Category Sidebar (Categories/Actions sidebar on cart pages; + exceptions list `subnav_pages_order`). Compound stored values: selected language codes array, three page-exception arrays.
- **Actions / CTAs:** "Save changes" (×2, both submit the whole form via POST to the same page); per-chip remove (×) buttons; "All" pseudo-chip in the language picker. No per-toggle save — everything persists on form submit.
- **States & conditionals:** rows hidden when not on the active tab; language sub-block hidden when its toggle is off (revealed by JS on toggle change) and shows a "no language files" message when `/lang/` is empty; language picker has tri-state (empty / partial / all) where "All" collapses to one chip and disables the per-language "All" option when a specific language is chosen. No flash banner on this page (saves silently, just re-renders).
- **Interactions:** client-side tab show/hide; JS reveal of the language sub-block tied to its toggle; chip multi-select widgets (click field → dropdown with search box + checkable option rows, click adds chip, × removes, outside-click/Escape closes, dropdown flips upward near viewport bottom). Hidden checkbox group is the real form state; the visible chips just mirror it. No AJAX — full form POST to save.

### `layouts/index` — Layouts
- **Route:** Admin -> Addons -> Hadrian -> Layouts (?module=Hadrian&action=layouts); sub-tabs `&kind=main-menu` and `&kind=footer`.
- **Purpose:** Choose which navigation (main-menu) and footer arrangement is active, set independently for guests vs. logged-in clients, plus any per-layout option (e.g. alignment).
- **Layout shape:** Tab strip ("Main menu" / "Footer"); per tab a card containing a responsive grid of layout cards; each card = thumbnail diagram + title + description + two activation rows + optional option control.
- **Page header:** title = "Layouts"; subtitle = "Pick the navigation and footer arrangement for **{template}**. Each layout has two independent activations — one for guests (unauthenticated visitors) and one for existing clients (logged in)."
- **Sections (top → bottom):**
  1. **Tab strip** — "Main menu" and "Footer"; client-side switch (no reload), real `?kind=` hrefs as fallback.
  2. **Layout group card(s)** — one card section per kind ("Main menu layouts" / "Footer layouts") with a count badge of how many variants. Inside: a grid of layout cards.
  3. **Layout card (repeated)** — schematic thumbnail (SVG wireframe keyed off layout name: top / sidebar / rail / extended / extended-info / default-footer), layout display name, optional description, an "activations" row, and an optional per-layout option control. Card is visually marked "on" if active for either audience.
- **Key data fields / settings:** per layout — name (machine), display name, description, isActiveGuest, isActiveClient, and optional `options.align` (label + choices map + current value). The two activation targets are audience = "guest" and audience = "client". Option example: alignment with a set of choices (segmented control).
- **Actions / CTAs:** per layout, per audience — "Activate" button (POST with kind+layout+audience) OR an "Active" badge when already active; per-option segmented buttons each submit (POST kind+layout+option+value) to set that option.
- **States & conditionals:** "Active" success badge replaces the Activate button for the audience that's live; card gets an "on" treatment when active for either audience; main-menu layouts with no alignment option show an italic note "No alignment option — content is always centered."; footer cards / unknown names fall back to a default wireframe thumbnail.
- **Interactions:** client-side tab switch between kinds (panels show/hide, no reload); every activation and option change is a real form POST (page reload). Segmented option control marks the current choice.

### `pages/index` — Pages
- **Route:** Admin -> Addons -> Hadrian -> Pages (?module=Hadrian&action=pages).
- **Purpose:** Browse every WHMCS page the theme knows about, grouped, and jump into per-page settings; shows each page's current variant, SEO/indexing/visibility status at a glance.
- **Layout shape:** Tab strip (one per group + "All", each with a count pill); per group a card holding a full-width data table; tabs filter which group section is visible.
- **Page header:** eyebrow = "Theme"; title = "Pages"; subtitle = "Configure template variant, SEO, options and layout overrides for each WHMCS page."
- **Sections (top → bottom):**
  1. **Flash banner (conditional)** — success alert "Page settings saved." when returning from a save.
  2. **Tab strip** — "All" tab (total count pill) plus one tab per page group, each with a count pill; tabs filter the sections below.
  3. **Group section (repeated)** — header with "{group} pages" title + count; a data table of that group's pages, OR an empty-state with instructions to add a `core/pages/<page>/page.php` with the right group and rebuild discovery from the Tools tab.
- **Key data fields / settings:** table columns — Name (label + optional description sub-line), Variant (active variant label), SEO (badge: "SEO" if custom SEO set, else "—"), Indexing (badge: Allow / Disallow / Inherit), Visibility (badge: Public / Auth only / Disabled), and a trailing actions cell.
- **Actions / CTAs:** per row "Edit" link → page editor (`&sub=edit&page=<name>`). Tabs are anchor links with `#tab=` hashes.
- **States & conditionals:** flash success banner only after a save; per-group empty-state when a group has no pages; status badges vary by each page's stored indexing/visibility/SEO state.
- **Interactions:** client-side tab filtering (show/hide group sections, no reload); active tab persisted to URL hash + localStorage and restored on load; reacts to back/forward hash changes.

### `pages/edit` — Page editor
- **Route:** Admin -> Addons -> Hadrian -> Pages -> Edit (?module=Hadrian&action=pages&sub=edit&page=<name>); saves to `&sub=save`.
- **Purpose:** Edit one page's template variant, page-specific options, SEO metadata, layout overrides, sub-nav, controls layout, and visibility.
- **Layout shape:** Toolbar (back link + save) above header; then a vertical stack of cards, one per settings group; each card holds either a selectable tile grid, toggle/text rows, or labeled inline select/field rows. Everything is one form.
- **Page header:** eyebrow = page's group; title = "{page label} / Page editor"; subtitle = page description (if any).
- **Sections (top → bottom):**
  1. **Toolbar** — "Back to Pages" link (returns to the page list anchored to this group's tab) + "Save changes" submit.
  2. **Flash banner (conditional)** — "Saved." success alert after save.
  3. **Template variant** — a grid of selectable tiles (radio behavior), one per discovered variant: variant label + optional description + an "Active"/"Click to activate" badge; empty-state if no variants exist under `core/pages/<page>/`.
  4. **Page options (conditional)** — only if the page declares options; each option renders as a toggle row (bool) or a labeled text input (string), with optional help.
  5. **SEO** — indexing dropdown (Inherit / Allow / Disallow); SEO title text input (maxlength 64, char counter, placeholder = page label); SEO description textarea (maxlength 160, char counter); Social image URL text input (maxlength 500, placeholder hints 1200×630).
  6. **Layout overrides** — Main menu layout dropdown + Footer layout dropdown, each overriding the global layout for this page only.
  7. **Sub-navigation** — "Section sub-nav" dropdown: Inherit / On (always show) / Off (always hide); help notes Inherit follows the global Settings toggle.
  8. **Controls layout** — "Inside / outside cards" dropdown: Inherit / Inside / Outside; help notes Inherit follows the global Float Controls toggle.
  9. **Visibility** — "Who can see this page" dropdown: Public / Authenticated only / Disabled (404); help notes disabled = 404 and auth-only redirects logged-out visitors to login.
- **Key data fields / settings:** hidden page name; variant (radio); option[<key>] (bool toggles paired with a hidden 0 fallback, or text); indexing; seo_title; seo_description; seo_social_image; layout_main_menu; layout_footer; subnav (inherit/on/off); svclayout (inherit/inside/outside); visibility (public/auth/disabled).
- **Actions / CTAs:** "Save changes" (top toolbar; submits the form via the form= attribute) → POST to `&sub=save`; "Back to Pages" link; variant tiles act as the radio selector (click to choose, saved on submit).
- **States & conditionals:** flash success banner after save; variant section shows empty-state when no variants; Page options section only renders when the page has options; active variant gets a success badge, others a neutral "Click to activate" badge.
- **Interactions:** char counters on SEO title/description (live, maxlength-bounded); variant tile radio selection; otherwise static selects/inputs; single form POST to save (no AJAX).

### `menu/index` — Menu
- **Route:** Admin -> Addons -> Hadrian -> Menu (?module=Hadrian&action=menu); sub-tabs `&tab=main|secondary|footer|footer-secondary`. Sub-actions: `&sub=seed`, `&sub=reset-defaults`, `&sub=create` (POST), `&sub=edit&id=`.
- **Purpose:** Manage the navigation menus for each location/audience — see what the frontend currently renders, create menus, re-seed presets, and open a menu for editing.
- **Layout shape:** Tab strip (4 menu locations); a "Live state" diagnostic card with a small grid of audience cards; then the menu-list card with a toolbar of actions and a full-width data table (or empty-state).
- **Page header:** eyebrow = "Theme"; title = "Menu"; subtitle = "Build navigation menus and assign them to client / guest audiences."
- **Sections (top → bottom):**
  1. **Tab strip** — Main / Secondary / Footer / Footer secondary (link reloads with `&tab=`).
  2. **Flash banner (conditional)** — info alerts for re-seed result ("nothing to add" / "Re-seeded N preset(s)") and reset-defaults result.
  3. **Live state card** — header "Live state" + note; a grid of two diagnostic cards (Client audience, Guest audience). Each shows the picked active menu name (or "(no active menu)"), and item count (with "that's why the sidebar looks empty" when 0); a card with no active menu is flagged as a warning and offers a Re-seed link.
  4. **Menu list card** — header titled per tab ("Main Menu" etc.) + tools (Re-seed presets, Reset WHMCS Defaults, "+ New menu"); a note explaining one active menu per audience; a data table of menus, OR an empty-state offering to seed the 4 presets.
- **Key data fields / settings:** diagnostic per audience — picked_id, picked_name, picked_items. Table columns — Name (link to editor + optional "edited" badge), Audience (badge: Client / Guest / All), Items (count), Status (badge: Active / Disabled), and an Edit action cell. New-menu form carries the current location.
- **Actions / CTAs:** "Re-seed presets" (link, `&sub=seed`, adds missing preset items without overwriting); "Reset WHMCS Defaults" (link, `&sub=reset-defaults`, confirm() then wipes+rebuilds factory presets, leaves custom menus); "+ New menu" (POST `&sub=create` with location → opens editor); per-row "Edit" link / name link → `&sub=edit&id=`; diagnostic + empty-state Re-seed links.
- **States & conditionals:** flash info banners after seed/reset; diagnostic card warning style + Re-seed prompt when an audience has no active menu, and an explicit "0 items" empty-sidebar callout; empty-state with "Seed the 4 preset menus" when the location has no menus; "edited" badge on user-modified menus; "Active"/"Disabled" status badges.
- **Interactions:** Reset WHMCS Defaults shows a JS confirm() before proceeding; otherwise static links/forms (full reloads). No drag/AJAX on this page.

### `menu/edit` — Menu editor
- **Route:** Admin -> Addons -> Hadrian -> Menu -> Edit (?module=Hadrian&action=menu&sub=edit&id=<id>); saves via POST to `&sub=save`.
- **Purpose:** Build and reorder a single menu's item tree (drag-and-drop, 2 levels deep) and edit each item's type, label, link/page, icon, dropdown style, visibility, and advanced display rules — plus the menu's own name, audience, and active status.
- **Layout shape:** Toolbar (back + save) above an editable title header; a two-column grid — left = the item tree (drag-reorderable list with per-row controls and an inline expanding property panel); right = a sticky "Menu Settings" card. A single hidden item-editor panel is relocated into whichever row is expanded. Mobile collapses to one column and swaps drag for up/down buttons.
- **Page header:** editable text input for the menu name + meta label "/ Menu editor"; subtitle = "Expand a row to edit its properties. Drag the grip to reorder, or use the arrows on touch devices."
- **Sections (top → bottom):**
  1. **Hidden form-array fields** — server-rendered `items[N][...]` hidden inputs (id, item_type, parent_id, position, label_json, config_json, active) so a no-JS / pristine save submits natively; a legacy `items_json` fallback input. JS replaces these on a dirty submit.
  2. **Toolbar** — "Back to menus" link (to this location's tab) + inline flash messages (Saved / created / empty-payload-rejected) + "Save changes" submit.
  3. **Save-refused / warning banners (conditional)** — hard-fail banner when host `max_input_vars` is too low (save NOT processed, shows the host's limit vs. required field count + cPanel fix steps); a softer pre-emptive warning when the item count will exceed the limit.
  4. **Left column — Menu Items tree** — header "Menu Items" + live item count; a nested list (`ul` → `li`, 2 levels) where each row has: drag grip, expand chevron, a type tag pill, the item label, and a control cluster (Add child [dropdowns only], Delete, visible toggle, Move up, Move down). Empty-state "No Menu Items Created" when the menu has none. Below the list: an "add item" row = a type dropdown + "+ Add item" button (adds a top-level item).
  5. **Right column — Menu Settings (sticky)** — "Display Rule" dropdown (Existing Client / Guest Client / All visitors) and a "Status" toggle (active = renders on matching pages).
  6. **Parked property panel (the per-item editor)** — lives off-DOM until a row is expanded, then injected inline under that row. Its fields (described below) carry NO name= and never submit directly; on save JS transcribes the in-memory tree into the hidden form-array.
- **Per-item editor fields (property panel):**
  - **Type** — dropdown of all item types; help notes changing type hides inapplicable fields and keeps existing values.
  - **Name** — English label text input (with help that the WHMCS lang key wins if set). Hidden for types that have no label (divider, language, currency, whmcs_default).
  - **WHMCS Page** (only for `whmcs_page`) — a searchable, grouped page picker: a trigger button showing the current page, a dropdown with a search box and page tiles grouped by section; tiles marked "WHMCS default" auto-fill the label/lang-key when picked.
  - **URL** (only for `custom_link`) — URL text input + "Open in new tab" checkbox (sets target=_blank).
  - **Dropdown style** (only for `dropdown_parent`) — dropdown: Default (classic) / Mega menu; help explains how Header/Divider children behave in each.
  - **Icon** — an icon picker: trigger showing current icon preview + name, dropdown grid of SVG icon tiles plus a "no icon" clear tile; help notes top-nav icons only render when the global Top-Nav Icons setting is on. Hidden for header/divider/language/currency/whmcs_default.
  - **Advanced label (collapsible)** — "WHMCS lang key" text input (wins over the English label when set).
  - **Display & advanced (collapsible)** — Position dropdown (Auto / Left / Right); per-item "Visible to" dropdown (All / Clients only / Guests only); Layouts checkboxes (Top nav / Sidebar / Icon rail; none ticked = all); Custom CSS class text input; "Show in menu" checkbox (mirrors the row visibility toggle).
- **Key data fields / settings:** menu — id (hidden), name (editable title), audience (client/guest/all), active. Per item — id, item_type, parent_id, position, active, label `{whmcs, custom.english}`, config `{page, url, target, dropdown_style, icon, position_side, audience, theme_layouts[], css_class}`. Item types: WHMCS Page, Custom Link, Dropdown, Section Header, Divider, Language Switcher, Currency Switcher, Login Button, Account Dropdown, WHMCS Default — each shown with a short type-tag pill (Page / Link / Dropdown / Header / Divider / Language / Currency / Login / Account / Default).
- **Actions / CTAs:** "Save changes" (POST `&sub=save`); "Back to menus"; "+ Add item" (adds top-level item of the chosen type); per-row Add child / Delete (with confirm) / Move up / Move down / visibility toggle; expand chevron or row-name click toggles the inline editor; icon-tile and page-tile picks; collapsible section headers.
- **States & conditionals:** flash success/created/refused banners; max_input_vars hard-fail (nothing saved) vs. soft warning; tree empty-state; rows visually marked open / hidden / dragging; per-type field visibility (fields show/hide by selected type); "+ Add child" only present on dropdown types; switching a dropdown that has children to another type prompts a confirm() warning about hiding children; up/down buttons auto-disable at list ends; pristine submit skips JS regen and submits server inputs as-is; empty-payload submit is blocked client-side to avoid wiping the menu.
- **Interactions:** HTML5 drag-and-drop reorder via the grip (with drop-indicator lines), up/down buttons as a touch fallback; inline expanding property panel (single panel relocated into the active row); searchable grouped page picker + searchable icon-grid picker (outside-click closes both); collapsible advanced sub-sections; live row-label/type-tag updates as you type/select; row toggle ↔ panel "Show in menu" two-way sync; in-memory tree serialized into hidden form-array inputs on dirty submit with extensive console logging. Save is a full form POST (no AJAX).

### `menu/error` — Menu error
- Small error fragment: header (eyebrow "Menu", title "Couldn't load that") + a card with the escaped error message, an explanation that the requested menu id didn't match a row in `hadrian_menus` (deleted or invalid id), and a "Back to menus" button.

### `branding` — Branding
- **Route:** Admin → Addons → Hadrian → Branding (`?module=Hadrian&action=branding`)
- **Purpose:** Upload the theme's logo/favicon image assets and set brand info (footer description + social URLs).
- **Layout shape:** Single content card; stacked labeled sections of upload tiles; a 2-column field grid for brand info; a save row at the bottom.
- **Page header:** eyebrow = "Theme"; title = "Branding"; subtitle = "Upload your logo and favicon. Each file is saved the moment you pick it — no Save needed."
- **Sections (top → bottom):**
  1. **Flash / status banner (conditional)** — server-rendered success/warning/danger banners (saved / removed / partially saved / nothing saved / invalid-field) for the no-JS path, plus a live aria-status line populated after each AJAX upload/remove.
  2. **Image upload sections (data-driven)** — one section per brand-asset group; the favicon is a single tile, others are light/dark pairs. Each tile is either a **filled** state (current-image preview with a Replace/Remove hover overlay) or an **empty** state ("Click to upload" dropzone with help text + max-size hint); plus an inline per-tile error slot and a filename meta line.
  3. **Brand Info section** — a Footer description textarea (with maxlength + char counter) and a 2-up grid of social URL fields (validated as URLs).
  4. **Save row** — a "Save changes" submit button.
- **Key data fields / settings:** per asset — field key, label, variant (light/dark), accepted file types, max size, current url + filename; brandInfo — `footer_description` and the social URL fields (each: field, label, value, max length).
- **Actions / CTAs:** pick/replace a file (auto-uploads via AJAX); Remove file (confirm → AJAX); Save changes (no-JS fallback for images, and the primary save for Brand Info text).
- **States & conditionals:** each tile is filled (preview) vs empty (dropzone); flash banners appear only on the no-JS submit path; a per-tile loading overlay (spinner + progress bar) shows during upload; a per-tile error state shows on rejection.
- **Interactions:** AJAX file upload with a progress bar and inline preview swap (no reload); Remove with a `confirm()` prompt; live char counter on the description; graceful degradation to a plain multipart form when JS is unavailable.

## Styles customizer

### `styles/index.tpl` — Styles (landing)
- **Route:** Admin -> Addons -> Hadrian -> Styles (?module=Hadrian&action=styles)
- **Purpose:** Pick which style preset is active for the current template, and jump into the editor for any preset.
- **Layout shape:** Page header, then one titled section with a count badge wrapping a responsive grid of selectable preset cards (the grid is itself a single POST form).
- **Page header:** title = "Styles"; subtitle = "Pick a style preset for **{template name}**, then use **Customize** to edit its colors, typography, and components. Dark mode is managed under **Customize > Colors**." (no eyebrow)
- **Sections (top -> bottom):**
  1. **"Available styles" section** — header with title + a count of available presets; body = the preset card grid.
  2. **Preset card (repeated per style)** — a selectable card containing: a hidden radio (the selector), a thumbnail tile showing the preset's first initial, a body block (display name + the fixed sub-label "Style preset"), and a footer with a status badge + a "Customize >" link. The active card carries an active-state marker.
- **Key data fields / settings:** the active-style choice (radio `style`, value = preset machine name); per card: machine name, display name, active flag. Selecting a radio = setting that preset active.
- **Actions / CTAs:** click a card's radio -> auto-submits the form (activates that preset); per card "Customize >" link -> opens the editor at that style on the Typography subcat (does NOT toggle the radio).
- **States & conditionals:** each card is either active (shows an "Active" badge) or inactive (shows a "Click to activate" badge + active-state styling only on the active one).
- **Interactions:** radio `onchange` auto-submits the whole form (no explicit save button); the "Customize" anchor navigates instead of selecting because it is interactive content inside the label.

### `styles/edit.tpl` — Style editor (shell)
- **Route:** Admin -> Addons -> Hadrian -> Styles -> Customize (?module=Hadrian&action=editStyle&style={name}&tab={variables|settings|custom-css}&subcat={colors|typography|...})
- **Purpose:** Editor shell that hosts the per-style designer: a top toolbar, three top-level tabs, and (on the Variables tab) a sub-category nav driving six pre-rendered panels switched client-side.
- **Layout shape:** Toolbar row (back link + save) above a page header; a horizontal top-tab strip; then on Variables a two-column split (left vertical sub-category nav + right panel area holding all panels, only one visible). Settings/Custom CSS tabs each render a single full-width block instead of the split.
- **Page header:** title = "{Style name} / Style editor" (with a de-emphasized "/ Style editor" suffix); subtitle = "Edit color scheme, typography, and component variables for this style preset." (no eyebrow)
- **Sections (top -> bottom):**
  1. **Toolbar** — a "Back to Styles" link (with chevron) + a "Save changes" button.
  2. **Top tabs** — three links: **Style Variables**, **Style Settings**, **Custom CSS** (active one marked; switch via `?tab=`).
  3. **Variables tab -> sub-category nav** — vertical list of 9 links: **Colors, Typography, General, Navigation, Layout, Buttons, Forms, Elements, Site** (active one marked).
  4. **Variables tab -> panel area** — all panels rendered up-front and toggled: 6 functional panels (`_colors`, `_typography`, `_buttons`, `_forms`, `_layout`, `_elements`) + 3 placeholder panels (General, Navigation, Site) each showing an empty-state ("This panel isn't available yet.").
  5. **Settings tab** — a single empty-state placeholder ("Style Settings ... isn't available yet.").
  6. **Custom CSS tab** — a POST form: optional "Custom CSS saved." success alert; a titled section with help text ("Injected into every client-area page after the theme styles, so it overrides them. Applies site-wide regardless of active style."); a large code textarea (spellcheck off, placeholder shows an example rule); a "Save CSS" submit. Hidden fields carry the save flag + style name.
- **Key data fields / settings:** current style name; active top tab; active sub-category; selected color mode; the raw global Custom CSS string. Each functional panel owns its own settings (documented below).
- **Actions / CTAs:** Back to Styles; "Save changes" (toolbar); top-tab links; sub-category links; per-panel save/reset (within each panel); Custom CSS "Save CSS".
- **States & conditionals:** which top tab is active (gates the whole body); which sub-category panel is visible (one shown, rest hidden); 3 sub-categories + the Settings tab show "not available yet" empty states; Custom CSS success alert only after a save; panel view-models are built ONLY on the Variables tab.
- **Interactions:** sub-category nav clicks toggle the pre-rendered panels with no reload and rewrite `?subcat=` in the URL (the `<a>` hrefs are a no-JS fallback that full-reloads); top tabs and the Custom CSS form are plain navigations/posts.

### `styles/_colors.tpl` — Colors panel
- **Route:** ?module=Hadrian&action=editStyle&subcat=colors&colormode={light|dark}
- **Purpose:** Govern dark-mode policy and tune the full palette token-by-token for the selected light/dark mode.
- **Layout shape:** Two stacked POST forms — a dark-mode governance card, then the palette editor (mode switch + preset chips + a series of titled token-group sections each holding label-on-left / control-on-right token rows) ending in an action row.
- **Page header:** none of its own (inherits the editor shell header); each section has its own title + status sub-label.
- **Sections (top -> bottom):**
  1. **Dark mode (form 1)** — section titled "Dark mode" with a status sub-label reflecting the current policy (Off / User choice / Forced); help text explaining the three modes; a 3-way segmented radio: **Off**, **User choice**, **Forced dark**. Optional "Dark mode setting saved." success alert.
  2. **Color Scheme (form 2 head)** — section titled "Color Scheme" with a sub-label ("Editing light/dark palette"); help text; a **Light / Dark** palette switch (two links that full-reload via `?colormode=`); a row of **accent preset chips** (each a color dot + name). Optional "Colors saved." success alert.
  3. **Token-group sections (repeated)** — one titled section per group; inside, a list of token rows. Each row = a label + a native color swatch picker + a hex/rgba text field (carrying the token's current value and its per-mode default).
  4. **Action row** — "Reset all to default" + "Save {light|dark} colors".
- **Key data fields / settings:**
  - Dark-mode policy: `off` | `optional` (visitor toggle, defaults light) | `forced` (always dark).
  - Selected color mode (light vs dark palette being edited).
  - Accent presets (cascade only): Default, Emerald, Violet, Rose, Amber, Slate (each carries an accent hex).
  - Per-mode color tokens grouped as: **Brand** (Accent, Accent hover, Accent tint, Link, Link hover); **Backgrounds** (Page, Surface, Surface 2, Surface 3); **Text** (Primary, Secondary, Tertiary, Quaternary); **Borders** (Border, Border light, Card border); **Status** (Success/Success text/Success fill, Warning/Warning text/Warning fill, Danger/Danger text/Danger fill); **Badges** (Info, Info fill, Neutral, Neutral fill); **Sidebar** (Background, Item hover, Item active, Icon tile); **Topbar** (Background); **Icon tiles** (Blue, Purple, Orange, Green, Red, Teal, Gray, Indigo, Pink). Each token = a CSS custom-property value (hex or rgba/hsl).
- **Actions / CTAs:** dark-mode radios auto-submit (form 1); Light/Dark switch links (full reload); preset chips (client-side cascade, no submit); "Reset all to default"; "Save {mode} colors" submit. Hidden fields carry save flags + current color mode.
- **States & conditionals:** two independent success alerts (dark saved / colors saved); section sub-labels reflect current policy + which palette is being edited; only tokens changed from default are persisted.
- **Interactions:** native swatch <-> hex/rgba text field kept in two-way sync per row; preset chip click cascades only the brand tokens (accent, accent-hover [auto-darkened], accent tint [derived rgba], link, link-hover) and leaves all other tokens untouched; "Reset all" restores every text field to its `data-default` and re-syncs swatches; dark-mode radios + the Light/Dark switch reload server-side.

### `styles/_typography.tpl` — Typography panel
- **Route:** ?module=Hadrian&action=editStyle&style={name}&subcat=typography
- **Purpose:** Choose the site font family (with several source modes) and set the font-size scale + font-weight scale.
- **Layout shape:** Single POST form with three titled sections — Font Family (radio list with dependent inputs), Font Size (grouped numeric-field grids), Font Weight (a grid of dropdowns) — ending in a save row.
- **Page header:** none of its own; per-section titles only.
- **Sections (top -> bottom):**
  1. **Font Family** — a vertical set of font-mode radios, each with an optional dependent control: **Default** (system/bundled stack, no input); **Google Font** (+ Google-font dropdown); **Your fonts** (+ dropdown of files dropped into `/assets/fonts/custom`, shown only if any exist); **Custom font stack** (+ free-text CSS font-stack input).
  2. **Font Size** — repeated per size group; each group = a group label + a grid of fields. Each field = a label + a numeric px input (bounded by min/max) with a "px" affix.
  3. **Font Weight** — a grid of fields; each = a label + a weight dropdown.
  4. **Save row** — "Save typography".
- **Key data fields / settings:**
  - Font-family mode (`default` | `google` | `folder` | `custom`) + the chosen Google font / folder file / custom stack string.
  - Google-font picklist: Inter, Roboto, Open Sans, Lato, Poppins, Montserrat, Nunito Sans, Work Sans, Manrope, DM Sans, Source Sans 3, Plus Jakarta Sans.
  - Size tokens (px), grouped: **Body** (Extra Small, Small, Base, Medium, Large, Extra Large, Super Large, 3XL); **Headings** (h6, h5, h4, h3, h2, h1); **Display** (Display Small, Display, Display Large, Display XL). Bounds 8-160px.
  - Weight tokens: Light, Base, Medium, Semibold, Bold, Black — each a dropdown of allowed weights (100-900).
- **Actions / CTAs:** "Save typography" submit. Hidden fields carry the save flag + style name.
- **States & conditionals:** "Typography saved." success alert after save; "Your fonts" radio + dropdown only appear when custom font files are present; only values changed from default are persisted.
- **Interactions:** only the input matching the chosen font-mode is enabled (others disabled); focusing a dependent control auto-selects its radio so the active font source is unambiguous; otherwise plain form submit.

### `styles/_buttons.tpl` — Buttons panel
- **Route:** ?module=Hadrian&action=editStyle&style={name}&subcat=buttons
- **Purpose:** Size every button tier from the typography scale and recolor each button variant via a per-variant color-slot matrix (site-wide).
- **Layout shape:** Single POST form: an intro section, a "Sizes" section (per-tier grouped dropdown grids), a "Variant colours" section (per-variant cards each holding a matrix of label + swatch + dropdown cells), ending in a reset/save action row.
- **Page header:** none of its own; per-section titles + a "Applies site-wide" sub-label on the intro and a variant count on the matrix.
- **Sections (top -> bottom):**
  1. **Intro** — title "Buttons" + "Applies site-wide" sub-label; help text ("Size and recolour every button variant. Colours come from the theme palette so they track accent + dark mode; only changed values saved; applies across all styles.").
  2. **Sizes** — per size tier (Small / Base / Large): a tier label + a grid of fields. Each field is normally a scale dropdown (font size / weight / line height / radius), with a px-input+affix fallback path supported but unused. Trailing help text explaining each tier is built from the typography scale and height follows font size.
  3. **Variant colours** — a count of variants, then one card per variant. Each card = variant name + its `.btn-{key}` class code, plus a matrix of 8 color slots. Each cell = slot label + a preview swatch + a grouped dropdown (optgroups) of palette color options.
  4. **Action row** — "Reset all to default" + "Save buttons".
- **Key data fields / settings:**
  - Size tiers x fields (all scale dropdowns): **Small / Base / Large** each = Font size (font scale: Extra Small..2X Large), Font weight (Light..Bold), Line height (Tight/Snug/Normal/Relaxed), Radius (None/Small/Medium/Large/Pill). Each stores a scale KEY (default differs per tier; e.g. Base font = Medium, all radii = Pill).
  - 8 color slots per variant: Background, Border, Text, Hover bg, Hover border, Hover text, Active bg, Active border.
  - 9 variants (matrix rows): Default, Primary, Primary faded, Secondary, Success, Info, Warning, Danger, Light (on dark). Each slot stores a palette-option KEY.
  - Palette color options (the dropdown choices, grouped into optgroups): **Primary** ramp (Primary, Primary hover, Primary darker, Primary tint 70/84/92%); **Slate** (Slate, Slate darker, Slate tint 84%); **Status** (Info/Info darker, Success/darker/fill/text, Warning/darker/fill/text, Danger/darker/fill/text); **Neutral** (Text, Text secondary, Surface, Surface 2, Border); **Basic** (White, Black, Transparent, White 8/16/24%). Each option carries a preview swatch.
- **Actions / CTAs:** "Reset all to default"; "Save buttons" submit. Hidden fields carry the save flag + style name.
- **States & conditionals:** "Buttons saved." success alert after save; only sizes/slots changed from default (and valid) are persisted; site-wide (one mapping covers light + dark).
- **Interactions:** each matrix dropdown drives its adjacent preview swatch on change (swatch color comes from the option's `data-swatch`); "Reset all" sets every size + matrix dropdown back to its `data-default` and re-syncs matrix swatches.

### `styles/_forms.tpl` — Forms panel
- **Route:** ?module=Hadrian&action=editStyle&style={name}&subcat=forms
- **Purpose:** Style form fields, labels, and checkboxes/radios — sizes from scales, colors from the palette (site-wide).
- **Layout shape:** Single POST form: intro section, a "Sizes" section (grouped field grids of dropdowns/px), a "Colours" section (grouped matrices of label + swatch + dropdown cells), ending in a reset/save row.
- **Page header:** none of its own; per-section titles + an "Applies site-wide" sub-label on the intro.
- **Sections (top -> bottom):**
  1. **Intro** — title "Forms" + "Applies site-wide" sub-label; help text ("Style inputs, labels and checkboxes. Sizes reference Typography & radius scales; colours come from the palette and track accent/dark mode; only changed values saved.").
  2. **Sizes** — per section group (Field / Label / Checkbox & radio): a group label + a grid of fields. Each field is either a scale dropdown or a px-input+affix.
  3. **Colours** — per section group: a group label + a matrix of cells; each cell = label + preview swatch + a grouped dropdown of palette color options.
  4. **Action row** — "Reset all to default" + "Save forms".
- **Key data fields / settings:**
  - Size fields: **Field** = Font size (font scale, default Large), Radius (radius scale, default Small), Border width (Hairline 0.5px / Thin 1px / Medium 2px, default Hairline); **Label** = Font size (default Base), Font weight (default Medium); **Checkbox & radio** = Size (px input, default 18).
  - Color fields (each stores a palette-option key): **Field** = Background, Border, Text, Placeholder, Focus border, Focus ring, Disabled bg; **Label** = Text; **Checkbox & radio** = Accent.
  - Palette color options (dropdown choices, in optgroups): **Primary** (Primary, Primary hover, Accent tint); **Status** (Success, Warning, Danger, Info); **Neutral** (Text, Text secondary, Text tertiary, Text muted, Surface, Surface 2, Border, Border light); **Basic** (White, Transparent). Each carries a preview swatch.
- **Actions / CTAs:** "Reset all to default"; "Save forms" submit. Hidden fields carry the save flag + style name.
- **States & conditionals:** "Forms saved." success alert after save; only values changed from default (and valid) persisted; site-wide.
- **Interactions:** each color dropdown drives its preview swatch on change; "Reset all" restores every size + color control to its `data-default` and re-syncs swatches.

### `styles/_layout.tpl` — Layout panel
- **Route:** ?module=Hadrian&action=editStyle&style={name}&subcat=layout
- **Purpose:** Set page-structure dimensions (content column, sidebar, topbar geometry) in pixels, site-wide.
- **Layout shape:** Single POST form: intro section, then one section containing grouped grids of px fields, ending in a reset/save row.
- **Page header:** none of its own; intro section title + "Applies site-wide" sub-label.
- **Sections (top -> bottom):**
  1. **Intro** — title "Layout" + "Applies site-wide" sub-label; help text ("Page-structure dimensions in pixels — the content column, sidebar and topbar geometry; only changed values saved.").
  2. **Dimensions** — per size group: a group label + a grid of fields; each field = a label + a numeric px input (bounds 0-4000) with a "px" affix.
  3. **Action row** — "Reset all to default" + "Save layout".
- **Key data fields / settings:** px dimension tokens grouped as **Content** (Max width default 1120, Padding X default 48) and **Sidebar & topbar** (Sidebar width default 260, Topbar height default 44). All plain px (no scales). Distinct from the top-level Layouts manager.
- **Actions / CTAs:** "Reset all to default"; "Save layout" submit. Hidden fields carry the save flag + style name.
- **States & conditionals:** "Layout saved." success alert after save; only in-bounds values changed from default persisted; site-wide.
- **Interactions:** "Reset all" restores every px field to its `data-default`; otherwise plain form submit (no swatches/previews).

### `styles/_elements.tpl` — Elements panel
- **Route:** ?module=Hadrian&action=editStyle&style={name}&subcat=elements
- **Purpose:** Set component SHAPE (radius / shadow / padding) for cards and pagination, site-wide (colors stay in the Colors panel).
- **Layout shape:** Single POST form: intro section, then one section of grouped grids (scale dropdowns + px fields), ending in a reset/save row.
- **Page header:** none of its own; intro section title + "Applies site-wide" sub-label.
- **Sections (top -> bottom):**
  1. **Intro** — title "Elements" + "Applies site-wide" sub-label; help text ("Shape of UI components — radius, shadow and padding. Colours stay in the Colors panel. Sizes reference the theme radius scale; only changed values saved.").
  2. **Shape fields** — per size group: a group label + a grid of fields; each field is either a scale dropdown or a px-input+affix.
  3. **Action row** — "Reset all to default" + "Save elements".
- **Key data fields / settings:** shape tokens grouped as **Card** = Radius (radius scale None/Small/Medium/Large/Pill, default Large), Shadow (shadow scale None/Soft/Medium/Strong, default Soft), Padding (px, default 24); **Pagination** = Button radius (radius scale, default Small). Px bounds 0-999.
- **Actions / CTAs:** "Reset all to default"; "Save elements" submit. Hidden fields carry the save flag + style name.
- **States & conditionals:** "Elements saved." success alert after save; only values changed from default (and valid) persisted; site-wide.
- **Interactions:** "Reset all" restores every px + scale field to its `data-default`; otherwise plain form submit (no live preview swatches).
