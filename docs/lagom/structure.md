# Lagom Structure Review

## Package inventory

Analyzed path:

```text
C:\Users\iblac\Downloads\Lagom WHMCS Client Theme 2.3.0-b1\php71+
```

Observed package counts:

| Item | Count |
| --- | ---: |
| Root client-area `.tpl` files in `templates/lagom2` | 88 |
| Total `.tpl` files below `templates/lagom2` | 772 |
| Root order form `.tpl` files in `templates/orderforms/lagom2` | 23 |
| PHP files below `modules/addons/RSThemes` | 281 |
| Widget PHP files in `src/Widgets` | 12 |
| Page directories in `templates/lagom2/core/pages` | 89 |

File type distribution in the package is dominated by Smarty templates and PHP source:

| Extension | Count |
| --- | ---: |
| `.tpl` | 818 |
| `.php` | 736 |
| `.svg` | 88 |
| `.css` | 70 |
| `.png` | 64 |
| `.js` | 16 |
| `.json` | 15 |
| `.zip` | 5 |

## Top-level layout

```text
php71+/
├── lagom-theme.zip
├── modules.zip
├── modules/
│   └── addons/
│       └── RSThemes/
└── templates/
    ├── lagom2/
    └── orderforms/
        └── lagom2/
```

Lagom is not just a template. It is a commercial theme platform with:

- A client theme in `templates/lagom2`.
- A cart/order form theme in `templates/orderforms/lagom2`.
- A WHMCS addon module in `modules/addons/RSThemes`.

The addon is responsible for most dynamic behavior: settings, page variants, admin UI, menus, sidebars, widgets, style selection, display rules, and license controls.

## Client theme: `templates/lagom2`

Important areas:

```text
templates/lagom2/
├── *.tpl                     # WHMCS page entry templates
├── header.tpl
├── footer.tpl
├── theme.yaml
├── assets/
│   ├── css/
│   ├── js/
│   ├── fonts/
│   ├── img/
│   ├── svg-icon/
│   └── svg-illustrations/
├── core/
│   ├── api/
│   ├── config/
│   ├── extensions/
│   ├── hooks/
│   ├── lang/
│   ├── layouts/
│   ├── pages/
│   ├── styles/
│   └── widgets/
├── includes/
├── modules/
├── oauth/
├── payment/
└── store/
```

### Theme metadata

`templates/lagom2/theme.yaml` declares:

| Property | Value |
| --- | --- |
| Name | `Lagom 2` |
| Description | Simple, intuitive and fully responsive WHMCS theme |
| Author | RSStudio |
| `serverSidePagination` | `false` |
| Bootstrap | `4.5.3` |
| jQuery | `1.12.4` |
| Font Awesome | `5.10.1` |

This aligns with the WHMCS 9/Nexus dependency set, so many template-level patterns are compatible with native WHMCS 9.

## Addon module: `modules/addons/RSThemes`

Important areas:

```text
modules/addons/RSThemes/
├── RSThemes.php              # WHMCS addon entry point
├── hooks.php                 # Client/admin hook registrations
├── adminHooks.php            # Admin-side hooks
├── autoload.php
├── config/
├── resources/
├── src/
│   ├── Api/
│   ├── Controller/
│   ├── Database/
│   ├── Extensions/
│   ├── FormFields/
│   ├── Helpers/
│   ├── Hooks/
│   ├── Migrations/
│   ├── Models/
│   ├── Processors/
│   ├── Seeders/
│   ├── Service/
│   ├── Template/
│   ├── Traits/
│   ├── Updates/
│   ├── Validators/
│   ├── View/
│   └── Widgets/
└── views/
    └── adminarea/
```

Observed `src` file concentration:

| Area | File count | Role |
| --- | ---: | --- |
| `Models` | 47 | Database-backed theme state |
| `Service` | 25 | Hook orchestration, page/widget/style services |
| `Helpers` | 20 | Addon helper utilities |
| `Template` | 19 | Template/page/style/layout/widget abstractions |
| `Api` | 15 | Admin AJAX/API endpoints |
| `Migrations` | 12 | Custom table migrations |
| `Controller` | 12 | Admin UI controllers |
| `Widgets` | 12 | Dashboard widgets |

## Page entry pattern

Many root templates use a thin dispatch pattern:

```text
if RSThemes has a configured page path and the file exists:
    include that configured path
else:
    render the default root template logic
```

For example, `clientareahome.tpl` checks `$RSThemes['pages'][$templatefile]['fullPath']` before falling back to its built-in dashboard implementation.

This gives Lagom runtime page variants, but it also adds indirection and depends on the addon-populated `$RSThemes` array.

## Core page variants

`templates/lagom2/core/pages` contains page directories for WHMCS pages and optional variants such as:

| Page | Variants observed |
| --- | --- |
| `clientareahome` | `default` |
| `clientregister` | `default`, `sidebar` |
| `login` | `default`, `sidebar` |
| `homepage` | `default`, `modern` |
| `domainregister` | `default`, `modern` |
| `domaintransfer` | `default`, `modern` |
| `domain-renewals` | `default`, `table` |
| `configureproductdomain` | `boxed`, `default` |
| `supportticketsubmit-stepone` | `boxes`, `default` |
| `password-reset-container` | `default`, `sidebar` |

This is a valuable UX concept. The implementation can be simplified in WHMCS 9 by using filesystem-level variants and a small theme dispatcher instead of a database-backed page manager.

## Style and layout structure

Lagom ships style presets in:

```text
templates/lagom2/core/styles/
├── default/
├── depth/
├── futuristic/
└── modern/
```

Main menu and footer layouts live in:

```text
templates/lagom2/core/layouts/
├── main-menu/
│   ├── condensed/
│   ├── condensed-banner/
│   ├── default/
│   ├── left-nav/
│   └── left-nav-wide/
└── footer/
    ├── default/
    └── extended/
```

These are good reusable concepts, but WHMCS 9 can implement them with ordinary Smarty includes plus CSS body classes.

## Order form theme

`templates/orderforms/lagom2` is a separate cart/order form theme with its own template set:

```text
templates/orderforms/lagom2/
├── products.tpl
├── viewcart.tpl
├── checkout-related templates
├── configureproduct.tpl
├── configuredomains.tpl
├── domainregister.tpl
├── domaintransfer.tpl
├── service-renewals.tpl
├── sidebar-categories*.tpl
├── includes/
└── js/
```

The order form is visually aligned with the client theme and reads many `$RSThemes` config settings. That coupling means a Lagom order form is much less standalone than a normal WHMCS order form template.

## Important structural takeaways

1. Lagom has excellent coverage of WHMCS pages.
2. Most template files are plain Smarty and inspectable.
3. Runtime behavior depends heavily on `$RSThemes`, which is populated by the addon.
4. Page/layout/style/widget choices are dynamic and database/admin-UI driven.
5. WHMCS 9 already supports many lower-level primitives Lagom builds on: `theme.yaml`, template fallback, hooks, `MenuItem`, `$panels`, and output hooks.
