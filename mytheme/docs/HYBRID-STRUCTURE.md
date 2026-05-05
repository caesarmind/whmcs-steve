# Hybrid Structure: WHMCS 9 Native + Lagom-Style Management

This is the target structure for MyTheme as a managed WHMCS 9 theme. It keeps the runtime close to WHMCS/Nexus and uses the addon for management, discovery, licensing, branding, and configuration.

For the detailed visual theme layer review, see [TEMPLATE-STRUCTURE.md](TEMPLATE-STRUCTURE.md).

## Principle

**WHMCS owns the data and native objects. MyTheme owns presentation and admin-selected options.**

**Commercial rule:** MyTheme is a two-piece licensed product. The template must not be useful by itself. The addon/license layer is load-bearing and must be active before the theme renders.

Use this rule whenever deciding whether to copy a Lagom system:

| Area | Use WHMCS 9 native | Borrow from Lagom | MyTheme direction |
|---|---|---|---|
| Dashboard data | `$panels`, `ClientAreaHomepagePanels`, native `MenuItem` children | Nice cards, empty states, ordering controls | Render native panels with MyTheme cards; addon only controls visibility/order/style |
| Menus | `ClientAreaPrimaryNavbar`, `ClientAreaSecondaryNavbar`, native `MenuItem` API | Admin menu builder UX | Store menu rules in addon settings; apply through native menu hooks |
| Sidebars | `ClientAreaPrimarySidebar`, `ClientAreaSecondarySidebar` | Sidebar assignment UI | Store sidebar rules in addon settings; apply through native sidebar hooks |
| Page variants | WHMCS `templatefile` and Smarty entry points | Admin variant picker | Manifest declares variants; addon chooses active variant |
| Styles | Compiled CSS/SCSS assets | Style presets/color groups UI | Presets live in `core/styles`; addon selects preset and CSS variables |
| Layouts | Smarty includes and WHMCS template variables | Layout picker UI | Layouts live in `core/layouts`; addon selects active layout |
| Widgets | Native panels and hooks | Polished widget UI | Do not replace native panels; create wrapper components only |
| Integrations | WHMCS module templates/hooks | Product-specific UI shortcuts | Optional extension packages under `core/extensions` or separate addons |

## Commercial licensing model

The production package should be sold as:

```text
modules/addons/MyTheme/   # encoded engine, license client, hooks, admin UI
templates/mytheme/        # visual layer, guarded by addon-provided $myTheme.license
```

Runtime licensing requirements:

1. `templates/mytheme/core/mytheme.php` must ship with `dev_mode => false`.
2. The addon must be active in WHMCS.
3. A valid license cache or successful license server response must exist.
4. `Hooks::clientAreaPage()` must expose `$myTheme.license.canRender = true`.
5. If the addon is inactive or the license is missing/invalid, the template shows only the license-required screen and hides normal page output.
6. If WHMCS is configured to use an unlicensed MyTheme template, the addon resets the client template to `six` and the order form to `standard_cart`.

This protects the commercial product from the easiest piracy path: copying only `templates/mytheme` without installing or licensing the addon.

Production license package checklist:

- Replace the license server public key in `License.php`.
- Replace `License::$licenseServerUrl` with your real licensing endpoint.
- Generate a unique 64-character per-template `secret_key`.
- Set `dev_mode` to `false` before encoding.
- Encode the addon engine and `core/mytheme.php` with ionCube.
- Generate integrity hashes after final production edits.
- Test three states before release: no addon, addon with no key, addon with valid key.

## Target folder structure

```text
mytheme/
├── modules/addons/MyTheme/                     # addon engine, encoded for production
│   ├── MyTheme.php                             # WHMCS addon lifecycle
│   ├── hooks.php                               # one registration layer, native hooks only
│   ├── adminHooks.php                          # admin-area helper hooks
│   ├── config/
│   │   └── app.php                             # addon-level metadata and defaults
│   ├── resources/
│   │   └── migrations/                         # schema migrations
│   ├── src/
│   │   ├── Controller/Admin/                   # addon management screens
│   │   │   ├── BrandingController.php
│   │   │   ├── ExtensionsController.php
│   │   │   ├── LayoutsController.php
│   │   │   ├── MenuController.php
│   │   │   ├── PagesController.php
│   │   │   ├── SettingsController.php
│   │   │   ├── StylesController.php
│   │   │   └── ToolsController.php
│   │   ├── Models/
│   │   │   ├── Configuration.php               # WHMCS tblconfiguration bridge
│   │   │   └── Settings.php                    # typed mytheme_settings key/value store
│   │   ├── Service/
│   │   │   ├── Hooks.php                       # native hook runtime
│   │   │   ├── HookDispatcher.php
│   │   │   └── AjaxService.php
│   │   ├── Template/                           # manifest, license, template discovery
│   │   ├── Helpers/
│   │   └── View/
│   └── views/adminarea/                        # Lagom-style admin UX, MyTheme internals
│
└── templates/mytheme/                          # visual layer, mostly plain files
    ├── theme.json                              # declared capabilities; no runtime scanning
    ├── core/mytheme.php                        # per-template encoded config
    ├── *.tpl                                   # WHMCS entry files; tiny include dispatchers
    ├── core/
    │   ├── styles/<style>/style.php            # style preset metadata + variables
    │   ├── layouts/main-menu/<layout>/          # top, sidebar, rail, future layouts
    │   ├── layouts/footer/<layout>/             # footer variants
    │   ├── pages/<templatefile>/<variant>/      # page variants selected by addon
    │   ├── components/                         # reusable cards, rows, alerts, panels
    │   ├── extensions/<extension>/              # optional feature packages
    │   ├── integrations/<module>/               # optional module-specific presentation
    │   ├── lang/                               # theme language files
    │   └── config/                             # static defaults consumed by addon/runtime
    ├── includes/                               # shared Smarty partials
    ├── modules/                                # WHMCS module template overrides
    ├── overwrites/                             # buyer escape hatch, checked first
    └── assets/                                 # SCSS, CSS, JS, fonts, SVG, images
```

## Addon-managed areas

The addon should manage **selection and configuration**, not replace WHMCS internals.

| Admin area | Current base | Target behavior | Storage |
|---|---|---|---|
| Info | Exists | Show active template, version, WHMCS/PHP compatibility, cache status | read-only |
| License | Exists | License key, status, grace period, disabled-template guard | `tblconfiguration` + signed local cache |
| Templates | Exists | Installed templates, activation eligibility | manifest + `tblconfiguration.Template` |
| Styles | Exists | Select style preset; later edit CSS variable groups | `<slug>_active_style`, `<slug>_style_vars` |
| Layouts | Exists | Select main menu/footer layout; later per-page layout override | `<slug>_active_layout_<kind>` |
| Pages | Exists, partial | Select variant per WHMCS `templatefile`; set SEO/hero/page options | `<slug>_page_variant_<page>`, `<slug>_page_options_<page>` |
| Menu | Exists, stub | Build primary/secondary/footer menu rules; apply through native navbar hooks | `<slug>_navigation_<slot>` as JSON |
| Sidebar | Planned | Build sidebar rules; apply through native sidebar hooks | `<slug>_sidebar_<slot>` as JSON |
| Dashboard | Planned | Reorder/hide native panels; choose card style; keep `$panels` data native | `<slug>_dashboard_panels` as JSON |
| Branding | Exists | Logos, favicon, social image, custom head snippets | `<slug>_branding` as JSON |
| Extensions | Exists | Enable optional theme extensions and integrations | `<slug>_extensions` as JSON |
| Tools | Exists | Clear cache, export/import config, verify manifest/integrity | settings + filesystem cache |

## Runtime flow

```text
WHMCS request
  ↓
Native WHMCS hooks run and create standard variables/panels/menus/sidebars
  ↓
MyTheme hooks.php validates addon/template license and registers one native-first dispatch layer
  ↓
Hooks::clientAreaPage() creates $myTheme from manifest + mytheme_settings + license render flag
  ↓
WHMCS header blocks rendering if $myTheme.license.canRender is missing
  ↓
WHMCS-named root tpl selects configured page variant when licensed
  ↓
Variant renders native WHMCS objects with MyTheme markup
```

The template should never need to query WHMCS tables directly for normal page data. If a page needs fallback data, use `localAPI` in the addon and keep native objects as the first source.

## Manifest contract

`theme.json` is the source of what the theme can provide. The addon can only manage items declared there.

Minimum contract:

```json
{
  "provides": {
    "styles": ["default", "dark"],
    "layouts": {
      "main-menu": ["top", "sidebar", "rail"],
      "footer": ["default"]
    },
    "pages": ["clientareahome", "login"],
    "extensions": [],
    "widgets": []
  }
}
```

Future optional contract:

```json
{
  "admin": {
    "managedAreas": ["branding", "styles", "layouts", "pages", "menu", "sidebar", "dashboard", "extensions"],
    "nativeFirst": true
  }
}
```

## Native hook mapping

| MyTheme feature | WHMCS hook to use | Rule |
|---|---|---|
| Global Smarty variables | `ClientAreaPage` | Build `$myTheme`; do not overwrite WHMCS core vars |
| Head assets/snippets | `ClientAreaHeadOutput` | Output configured assets and custom CSS variables |
| Footer scripts | `ClientAreaFooterOutput` | Output extension scripts and deferred JS |
| Dashboard cards | `ClientAreaHomepagePanels` | Adjust native panels only when needed |
| Dashboard fallback data | `ClientAreaPageHome` | Fallback only; templates should prefer `$panels` |
| Primary menu | `ClientAreaPrimaryNavbar` | Add/remove/reorder native `MenuItem` children |
| Secondary menu | `ClientAreaSecondaryNavbar` | Same as primary |
| Primary sidebar | `ClientAreaPrimarySidebar` | Add/remove/reorder native sidebar children |
| Secondary sidebar | `ClientAreaSecondarySidebar` | Same as primary sidebar |

## Database strategy

Keep the existing lightweight model:

| Table/store | Use |
|---|---|
| `tblconfiguration` | WHMCS-native active template/order form template, addon activation, license interop |
| `mytheme_settings` | All theme-specific settings as typed key/value rows |

Avoid new tables until one setting row becomes too large or needs relational querying. Prefer JSON rows for admin-managed trees:

```text
mytheme_navigation_primary      json
mytheme_sidebar_primary         json
mytheme_dashboard_panels        json
mytheme_branding                json
mytheme_extensions              json
```

## Implementation phases

### Phase 1: Stabilize native-first foundation

- Keep dashboard services/tickets/news rendering from native `$panels`.
- Align `theme.json` with actual style/layout/page directories.
- Fix stale docs that refer to `{extends}` dispatch.
- Keep the one-dispatch hook architecture.

### Phase 2: Make existing admin screens real

- Save page variants from `PagesController` into `mytheme_settings`.
- Replace menu stub data with JSON-backed menu profiles.
- Add native navbar/sidebar hook methods to apply configured rules.
- Add branding upload/settings support and expose it through `$myTheme.branding`.

### Phase 3: Add optional managed systems

- Dashboard panel order/visibility controls that still render native panel children.
- Import/export theme configuration from `mytheme_settings`.
- Extension registry for optional features.
- Cache warming/manifest validation tools.

### Phase 4: Productize

- Encode addon engine only.
- Encode `templates/<slug>/core/<slug>.php` because it contains the local license-cache HMAC secret.
- Set `dev_mode` to `false` and verify the theme cannot render with no key.
- Ship SCSS sources and plain Smarty templates.
- Keep buyer overrides in `overwrites/`.
- Keep module-specific integrations as optional extensions or separate addons.

## Hard rules

1. Do not replace WHMCS native data with custom duplicate queries unless it is a fallback.
2. Do not copy Lagom's full widget engine; wrap native panels instead.
3. Do not add runtime filesystem scans for styles/layouts/pages.
4. Do not store presentation state across multiple tables when `mytheme_settings` is enough.
5. Do not put large business logic in Smarty templates.
6. Do not make buyer overrides edit encoded files.
7. Do not remove WHMCS-native compatibility for menus, sidebars, panels, or order forms.
8. Do not let `templates/mytheme` render normal pages when the addon/license layer is absent.

## Next code targets

1. Build and test the real license server endpoint.
2. Add save handling to `PagesController::editAction()`.
3. Replace `MenuController` stub data with JSON-backed settings.
4. Add `clientAreaPrimaryNavbar()`, `clientAreaSecondaryNavbar()`, `clientAreaPrimarySidebar()`, and `clientAreaSecondarySidebar()` methods to `Hooks`.
5. Add dashboard settings UI only after the native `$panels` rendering is stable in production.