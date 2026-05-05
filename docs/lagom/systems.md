# Lagom Systems Review

## 1. Two-piece architecture

Lagom is a theme plus an addon module:

| Layer | Path | Responsibility |
| --- | --- | --- |
| Client theme | `templates/lagom2` | Smarty templates, CSS/JS/images, page variants, shared includes |
| Order form theme | `templates/orderforms/lagom2` | Cart/order form templates aligned with Lagom styling |
| Addon module | `modules/addons/RSThemes` | Admin UI, hooks, database-backed settings, styles, pages, menus, sidebars, widgets, licensing |

The theme is tightly coupled to the addon through the `$RSThemes` Smarty variable. Many templates check `$RSThemes` to decide which layout, style, page variant, display mode, and page config to use.

## 2. Hook system

`modules/addons/RSThemes/hooks.php` registers a broad hook layer. Important observed hooks include:

| Hook | Purpose |
| --- | --- |
| `ClientAreaPage` | License/session protection, `$RSThemes` variable population, SEO/page metadata, addon flags |
| `ClientAreaHomepagePanels` | Dashboard panel manipulation |
| `ClientAreaPageHome` | Lagom widgets injection on the client dashboard |
| `ClientAreaHeadOutput` | Module integration CSS injection |
| `ClientAreaFooterOutput` | Module integration JS injection |
| `AdminAreaHeadOutput` | Addon admin UI styling and inactive-template cleanup scripts |
| `ProductEdit` / `ProductDelete` | Pricing/cache invalidation |
| Page-specific hooks | Products, services, tickets, affiliates, domains, invoices, quotes |

### Notes

- Lagom still uses WHMCS native hooks underneath.
- It adds a large service layer on top of those hooks.
- `ClientAreaPage` is used multiple times for different concerns, which is powerful but harder to trace.
- `ClientAreaHomepagePanels` and `ClientAreaPageHome` are central to the dashboard/widget system.

## 3. Page variant system

Lagom page entry templates often do this:

```text
if $RSThemes['pages'][$templatefile]['fullPath'] exists:
    include that file
else:
    render default template
```

This supports addon-controlled page variants such as:

- Default page layout.
- Sidebar version for auth pages.
- Modern homepage/domain search variants.
- Boxed or table versions for some flows.
- CMS/custom page display modes.

### Strength

This gives non-developers control through the Lagom admin UI.

### Cost

The active page is not obvious by reading the root `.tpl` alone. You must also know the addon database state and computed `$RSThemes['pages']` values.

### WHMCS 9-native replacement

Use a simpler version of the same idea:

- Keep thin WHMCS-named entry templates.
- Include `core/pages/<page>/<variant>/<variant>.tpl` based on a small theme setting.
- Store defaults in code or `tblconfiguration`, not large custom page tables unless an admin UI is truly needed.

MyTheme already follows a simplified variant-dispatch pattern, which is a good middle ground.

## 4. Dashboard and widgets

Lagom has two dashboard approaches in the analyzed package:

1. The root `clientareahome.tpl` can render native `$panels` with custom Lagom markup.
2. The addon can replace the native panel children and inject `RSWidgets` through `ClientAreaPageHome`.

Observed widget files include:

| Widget | Likely purpose |
| --- | --- |
| `AccountWidget.php` | Account summary / avatar / credits / invoices |
| `ServicesWidget.php` | Services list or counters |
| `DomainsWidget.php` | Domains list or counters |
| `InvoicesWidget.php` | Invoice summaries |
| `TicketsWidget.php` | Ticket summaries |
| `ServersWidget.php` | Server/network status |
| `AnnouncementsWidget.php` | Recent announcements |
| `AffiliatesWidget.php` | Affiliate summary |
| `Quotations.php` | Quotes summary |

`config/widgets.php` exposes admin-editable settings for widgets such as name, status filters, product group filters, limits, avatar visibility, available credits, invoice/ticket type, and icon choices.

### Strength

The widget system is configurable and attractive for administrators.

### Weakness

It duplicates WHMCS native homepage panels and can hide or replace native core/addon panel behavior.

### WHMCS 9-native replacement

Prefer native `$panels` and `ClientAreaHomepagePanels`:

- Let WHMCS core and modules populate dashboard panels.
- Render panel children in your design.
- Add extra panels with `ClientAreaHomepagePanels` only when needed.
- Use custom API/localAPI data as fallback, not the primary source.

This is the approach already chosen for MyTheme's dashboard fixes.

## 5. Menu and sidebar system

Lagom provides addon-managed menus and sidebars. The admin UI under `views/adminarea/menu` and `views/adminarea/sidebar` supports editing structured navigation without code.

Conceptual capabilities:

- Multiple menu locations.
- Nested menu items.
- Per-item types and content bags.
- Active/inactive state.
- Sidebar item/page mapping.
- Runtime rendering from saved addon configuration.

### Strength

Excellent for non-technical users who need to edit navigation from WHMCS admin.

### Weakness

Navigation becomes database state instead of code. It is harder to review in Git, harder to deploy consistently, and easier to drift between environments.

### WHMCS 9-native replacement

Use native MenuItem hooks:

- `ClientAreaPrimaryNavbar`
- `ClientAreaSecondaryNavbar`
- `ClientAreaPrimarySidebar`
- `ClientAreaSecondarySidebar`

The documented `MenuItem` API supports `addChild()`, `removeChild()`, `setLabel()`, `setUri()`, `setOrder()`, `setIcon()`, `setBadge()`, `setExtra()`, and related methods.

## 6. Styling and design system

Lagom styling is driven by:

- `templates/lagom2/assets/css/theme.css`
- `templates/lagom2/assets/css/site.css`
- RTL variants: `theme-rtl.css`, `site-rtl.css`
- Style presets under `core/styles/default`, `depth`, `futuristic`, and `modern`
- Runtime CSS injection through `$RSThemes['styles']['colors']->cssInjector()` when available
- Dynamic body classes from `header.tpl`

`includes/head.tpl` loads:

1. Favicon assets from `$RSThemes.faviconDir`.
2. CSS variables / style vars.
3. Main theme CSS or RTL theme CSS.
4. Site CSS for site/CMS pages.
5. Style-specific `custom.css` / `theme-custom.css` if present.
6. Optional one-page order form CSS.
7. WHMCS script variables.
8. Lagom scripts: `scripts.min.js` and `core.min.js`.

### Strength

The style system supports presets, RTL, CMS/site styling, custom CSS layers, dark mode, and layout-specific head includes.

### Weakness

The package ships compiled CSS, not a clean SCSS source tree. This makes deep customization harder and increases risk during updates.

### WHMCS 9-native replacement

Use:

- `theme.yaml` for dependency declarations.
- `assetPath` and `assetExists` for asset loading.
- `custom.css` or a generated `theme.min.css` for overrides.
- CSS custom properties for presets.
- Body classes from a small hook or header logic.

## 7. Layout system

Lagom has selectable layout families:

- Main menu: default, condensed, condensed-banner, left-nav, left-nav-wide.
- Footer: default and extended.

`header.tpl` includes the active main-menu layout from `$RSThemes['layouts']['mediumPath']`. `footer.tpl` includes the active footer layout from `$RSThemes['footer-layouts']['mediumPath']`.

### WHMCS 9-native replacement

This can be implemented with a smaller filesystem pattern:

```text
core/layouts/main-menu/<layout>/<layout>.tpl
core/layouts/footer/<layout>/<layout>.tpl
```

Then choose the layout with a theme setting or `tblconfiguration` value. No large addon framework is required unless users need a GUI.

## 8. Order form system

Lagom includes a separate order form theme at `templates/orderforms/lagom2`.

Important points:

- It uses the same `$RSThemes` page config concept.
- `products.tpl` supports product display options like horizontal packages, product columns, monthly price breakdown, one-time price handling, discount-center compatibility, and sidebar hiding.
- It includes category sidebars and collapsed sidebar variants.

### Strength

The cart/order flow is integrated with the client theme and has many presentation options.

### Weakness

The order form is not fully standalone; it depends on RSThemes settings and addon-calculated variables.

### WHMCS 9-native replacement

Use a normal WHMCS order form template and keep behavior close to Nexus/standard cart unless there is a clear business reason for a custom product-card system.

## 9. Overwrite escape hatch

Lagom supports overwrite files such as:

```text
templates/lagom2/overwrites/header.tpl
templates/lagom2/overwrites/footer.tpl
templates/lagom2/includes/overwrites/head.tpl
```

This is one of Lagom's best extension ideas: users can override a partial without editing the vendor file.

### Recommendation for MyTheme

Keep or expand this pattern. It is simpler than a full addon-driven page manager and useful for customer-safe customization.

## 10. SEO / CMS / display modes

Lagom uses page metadata and active display modes from addon models. Hooks return values such as:

- `pageType`
- `pageSeo`
- `activeDisplay`
- custom page data

### Native replacement

For WHMCS 9:

- Use template variables and header includes for SEO tags.
- Add page-specific variables through `ClientAreaPage*` hooks.
- For static pages, prefer filesystem templates or a small custom page table only if admin editing is required.

## 11. License and integrity controls

The package includes commercial license and file-integrity behavior in the addon. This documentation does not cover bypassing it.

Architecturally, the important lesson is that license control increases coupling:

- The theme depends on the addon being active.
- The addon can reset `Template` / `OrderFormTemplate` session choices when a license is invalid.
- Some config files include integrity checks.

For MyTheme, keep licensing separate from normal rendering wherever possible so basic theme behavior remains debuggable.
