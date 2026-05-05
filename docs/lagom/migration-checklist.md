# Lagom-to-WHMCS 9 Native Migration Checklist

Use this checklist when extracting useful Lagom ideas into MyTheme or another WHMCS 9-native theme.

## Phase 1: Inventory Lagom usage

- [ ] Record active Lagom client theme style preset.
- [ ] Record active main-menu layout.
- [ ] Record active footer layout.
- [ ] Export or screenshot menu builder configuration.
- [ ] Export or screenshot sidebar builder configuration.
- [ ] Export or screenshot page variant configuration.
- [ ] Export widget configuration for the dashboard.
- [ ] Record any custom CSS in Lagom style folders.
- [ ] Record any custom header/footer overwrites.
- [ ] Record any CMS/custom pages and SEO metadata.
- [ ] Record active order form settings.
- [ ] Identify third-party modules that Lagom integrates with.

## Phase 2: Choose native replacements

| Lagom item | Replacement decision |
| --- | --- |
| Dashboard widgets | Replace with native `$panels` rendering |
| Menus | Convert to `ClientAreaPrimaryNavbar` / `ClientAreaSecondaryNavbar` hooks |
| Sidebars | Convert to `ClientAreaPrimarySidebar` / `ClientAreaSecondarySidebar` hooks |
| Page variants | Convert to `core/pages/<page>/<variant>` filesystem variants |
| Style preset | Convert to CSS variable preset |
| Layout | Convert to Smarty include selection |
| SEO metadata | Convert to `ClientAreaPage*` hook variables |
| Module CSS/JS | Convert to `ClientAreaHeadOutput` / `ClientAreaFooterOutput` |
| Order form cards | Keep native unless custom product-card UX is required |

## Phase 3: Implement in MyTheme

- [ ] Keep WHMCS-named root templates thin.
- [ ] Keep default implementations under `core/pages/<page>/default`.
- [ ] Add optional page variants only when needed.
- [ ] Keep overwrite folders for safe customer customization.
- [ ] Render native `$panels` before using fallback custom data.
- [ ] Use native `MenuItem` methods for navigation/sidebar modifications.
- [ ] Add CSS tokens for theme presets.
- [ ] Add body classes for layout/preset state.
- [ ] Keep admin settings small and typed.
- [ ] Avoid storing whole templates or menus in the database unless required.

## Phase 4: Dashboard-specific migration

For client area home:

- [ ] Use WHMCS native panel names such as `Active Products/Services`, `Recent Support Tickets`, and `Recent News`.
- [ ] Read panel children with `getChildren()`.
- [ ] Read child labels and URLs with `getLabel()` and `getUri()`.
- [ ] Respect badges with `hasBadge()` and `getBadge()`.
- [ ] Preserve `getBodyHtml()` and `getFooterHtml()` for panels without children.
- [ ] Keep empty states only when native panel and fallback data are both empty.
- [ ] Do not remove all native panels unless there is a strong reason.

## Phase 5: Styling migration

- [ ] Convert Lagom color/style choices to CSS custom properties.
- [ ] Put preset deltas in small CSS files.
- [ ] Keep dark mode token overrides separate.
- [ ] Keep RTL CSS separate or use logical CSS properties where possible.
- [ ] Avoid editing large generated CSS files directly.

## Phase 6: Validation

- [ ] Test dashboard with services, tickets, announcements, unpaid invoices, and no-data states.
- [ ] Test third-party modules that inject panels or output hooks.
- [ ] Test login/register/password reset pages.
- [ ] Test product details and domain details pages.
- [ ] Test invoice view and payment method pages.
- [ ] Test order form flow from product selection to checkout.
- [ ] Test mobile nav/sidebar behavior.
- [ ] Test dark mode and RTL if supported.
- [ ] Clear WHMCS template cache after template changes.

## Final recommendation

Treat Lagom as a UX and feature reference. Do not copy its entire architecture unless you specifically need a commercial admin-configurable theme platform.

For MyTheme, the best architecture is:

- Native WHMCS hooks.
- Native `$panels`.
- Thin Smarty dispatchers.
- File-based variants.
- Small typed settings.
- Customer-safe overwrite folders.
- CSS variable presets.
