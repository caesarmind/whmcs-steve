# Template Layer: `templates/mytheme`

This document describes the sellable visual theme package. The directory is intentionally **not standalone**: it requires `modules/addons/MyTheme` to render normal pages.

## Role

`templates/mytheme` is the plain visual layer:

- WHMCS-named entry templates.
- Smarty page variants.
- Header/footer/layout partials.
- SCSS/CSS/JS/assets.
- Buyer-safe overwrite folders.

The addon is the protected engine:

- License validation.
- `$myTheme` runtime variables.
- Active style/layout/page variant selection.
- Admin UI and settings storage.

## Commercial rule

The template must not be useful without the addon.

Current safeguards:

1. `header.tpl` checks `$myTheme.license.canRender`.
2. If the addon is missing or unlicensed, normal output is wrapped in a hidden container.
3. `footer.tpl` closes only the license-required screen in the blocked state.
4. `error/license-required.tpl` displays the commercial license message.
5. `core/mytheme.php` contains the per-template secret and must be encoded for production.
6. `theme.json` declares `commercial.licenseRequired` and the `renderGuard` contract.

Production requirement: set `core/mytheme.php` `dev_mode` to `false` before encoding.

## Current structure

```text
templates/mytheme/
├── theme.json                         # manifest consumed by addon
├── core/mytheme.php                   # per-template config + license secret, encoded in production
├── header.tpl                         # layout shell + license guard
├── footer.tpl                         # layout shell close + license guard close
├── *.tpl                              # WHMCS entry dispatchers
├── core/
│   ├── pages/<page>/<variant>/         # page implementations
│   ├── styles/<style>/style.php        # style presets
│   ├── layouts/main-menu/<layout>/      # top/sidebar/rail layouts
│   ├── layouts/footer/<layout>/         # footer layouts
│   ├── lang/                           # theme language files
│   ├── components/                     # target location for reusable UI parts
│   ├── extensions/                     # optional feature packages
│   ├── integrations/                   # optional module-specific presentation
│   └── config/                         # static defaults
├── includes/                           # shared partials
├── modules/                            # WHMCS module overrides
├── oauth/ payment/ error/              # WHMCS special template areas
├── overwrites/                         # buyer escape hatch
└── assets/                             # SCSS, compiled CSS, JS, fonts, images, icons
```

## Entry template dispatch

Every WHMCS-named root template should stay tiny. It checks whether the addon selected a valid variant path, then falls back to the default variant.

Example:

```smarty
{if isset($myTheme.pages.clientareahome.fullPath) && $myTheme.pages.clientareahome.fullPath && file_exists("templates/`$myTheme.pages.clientareahome.fullPath`")}
    {include file="`$myTheme.pages.clientareahome.fullPath`"}
{else}
    {include file="`$template`/core/pages/clientareahome/default/default.tpl"}
{/if}
```

This is the key bridge between the admin addon and the visual theme.

## Manifest contract

`theme.json` now declares only pages that exist as root templates and core page implementations:

- `announcements`
- `clientareadetails`
- `clientareadomains`
- `clientareahome`
- `clientareainvoices`
- `clientareaproducts`
- `homepage`
- `login`
- `supporttickets`
- `viewinvoice`
- `viewticket`

When adding a new WHMCS page:

1. Add root dispatcher: `templates/mytheme/<templatefile>.tpl`.
2. Add default implementation: `core/pages/<templatefile>/default/default.tpl`.
3. Add metadata: `core/pages/<templatefile>/page.php`.
4. Add variant options if needed: `core/pages/<templatefile>/default/pageoption.php`.
5. Add the page name to `theme.json` `provides.pages`.

## What is ready

- Commercial render guard exists.
- Addon-selected page variant dispatch is wired into root templates.
- Manifest matches the currently implemented page set.
- Style/layout/page architecture is compatible with addon management.
- SCSS source structure is preserved, which is better for selling/updates than minified-only CSS.

## What still needs completion before selling

### 1. Full WHMCS page coverage

The current page set is a strong starter, not yet full commercial coverage. Before selling, add or verify templates for common WHMCS flows:

- register/client registration
- password reset
- account users and contacts
- payment methods
- domain detail tabs
- product detail tabs
- ticket submit steps
- knowledgebase/downloads/network status
- cart/order form templates
- error pages
- OAuth pages
- 2FA/security pages

### 2. Move preview controls behind dev/admin mode

`header.tpl` still supports URL preview toggles such as `layout`, `palette`, `tiles`, and `data`. These are useful during design but should be restricted or removed in production unless intentionally sold as a public preview feature.

### 3. Finish addon-backed settings

The root dispatchers are ready, but the admin controllers still need full save/read behavior for:

- page variants;
- page options;
- menu trees;
- sidebar trees;
- branding;
- dashboard panel controls.

### 4. Harden buyer overrides

Keep `overwrites/` available, but document exactly which override files are supported. Buyers should never edit encoded files or root license-guard logic.

### 5. Production package split

Ship two folders together:

```text
modules/addons/MyTheme/
templates/mytheme/
```

The sales package should fail gracefully if either piece is missing, but normal rendering should require both.

## Recommended next template work

1. Add missing commercial WHMCS page implementations in priority order: account, product details, domain details, tickets, knowledgebase, cart.
2. Add `page.php` metadata for every page in `theme.json`.
3. Move page-specific CSS loading into a consistent partial or page metadata field.
4. Add documented override examples in `overwrites/README.md`.
5. Test no-addon, invalid-license, valid-license, and dev-mode scenarios.