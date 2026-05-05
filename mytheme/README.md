# MyTheme — WHMCS 9 Client Theme Starter (PHP 8.1+)

A production-grade scaffold for building and selling a commercial WHMCS client-area theme. Targets **WHMCS 9.0+** running on **PHP 8.1+** with **Smarty 4** (auto-falls-back to Smarty 3 for older WHMCS). Mimics the structural patterns of well-architected commercial themes (style/layout plug-in model, encoded core + plain templates, RSA-signed licensing, chained anti-tamper checks) and fixes the common anti-patterns (god-object hooks, MD5 MACs, no SCSS sources, filesystem-scan discovery).

**Modern PHP features used throughout**: backed enums (`LicenseState`), `readonly` properties, `match` expressions, named arguments, `never` return type, `str_contains()`. Avoids 8.2/8.3-only features (no typed class constants, no `json_validate()`, no `readonly class`) so it runs on the WHMCS 9 minimum (PHP 8.1).

## What ships

```
MyTheme-WHMCS-Starter/
├── README.md  BUILD.md  LICENSING-SETUP.md          ← guides
├── package.json                                     ← npm scripts
├── scripts/
│   ├── build-css.mjs                                ← SCSS → minified CSS
│   ├── build-js.mjs                                 ← JS bundling
│   └── inject-integrity-hashes.mjs                  ← build-time sha256 codegen
├── modules/addons/MyTheme/                          ← the engine (encode this)
│   ├── MyTheme.php  hooks.php  adminHooks.php  autoload.php
│   ├── src/
│   │   ├── Template/{Template,License,LicenseHelper}.php
│   │   ├── Helpers/{AddonHelper,ThemeManifest,Configuration}.php
│   │   ├── Service/{Hooks,HookDispatcher,AjaxService}.php
│   │   ├── Models/{Configuration,Settings}.php
│   │   ├── Controller/Admin/{MainController,StylesController,LayoutsController,PagesController,MenuController,...}.php
│   │   └── View/ViewHelper.php
│   ├── config/app.php
│   ├── resources/migrations/Initial.php
│   └── views/adminarea/                             ← admin UI tpls
└── templates/mytheme/                               ← the visual layer (mostly plain)
    ├── theme.json                                   ← MANIFEST (not filesystem scan)
    ├── core/mytheme.php                             ← per-template encoded config (secret_key)
    ├── *.tpl                                        ← WHMCS-named entry points (tiny {include} dispatchers)
    ├── core/{styles,layouts,pages,extensions,lang,api,hooks,config}/
    ├── includes/{common,menu,sidebar,tables}/
    ├── error/  oauth/  payment/{bank,card}/  modules/servers/
    ├── overwrites/                                  ← buyer escape hatch
    └── assets/{scss,css,js,fonts,img,svg-icon}/     ← SCSS sources ship!
```

## What's included vs. what you build

**Included (working scaffold):**
- Directory layout, naming conventions, manifest schemas
- Addon skeleton with WHMCS hooks wired up
- License client (HMAC-SHA256, RSA verification, nonce, grace period) — minus your private key + server
- `theme.json` manifest replacing filesystem-scan discovery
- Build pipeline: SCSS → CSS, JS bundling, integrity-hash codegen
- One default style + one dark style (manifest only)
- Three main-menu layouts (top-nav, sidebar, rail) + one footer layout
- One sample page variant (`clientareahome/default`) using native WHMCS panels first
- Admin UI scaffold for styles, layouts, pages, menu, branding, extensions, tools, templates, and license

**You build:**
- Visual design (the SCSS for components, your fonts, your icons)
- The full set of page tpls under `core/pages/<page>/<variant>/`
- Your license server (separate project — see [LICENSING-SETUP.md](LICENSING-SETUP.md))
- Marketing pages (`templates/mytheme/homepage.tpl` and friends)
- Translations (only `english.php` is stubbed)

## How it differs from typical commercial themes

| Pattern | Typical | This starter |
|---|---|---|
| Page dispatch | `{if file_exists($var)}{include}{else}<300 lines>{/if}` per WHMCS root tpl | Tiny WHMCS-named `{include}` dispatcher into `core/pages/<page>/<variant>/<variant>.tpl` |
| Variant discovery | Filesystem scan with `Symfony\Finder` on each request | `theme.json` manifest, parsed once, cached |
| Local license cache | `md5(serialize(...))` MAC | `hash_hmac('sha256', json_encode(...), $secret)` with `hash_equals` |
| License callback TLS | `CURLOPT_SSL_VERIFY*` disabled | Verified, with optional cert pinning |
| License replay | Captured response valid forever | Nonce + `signed_at` timestamp validated |
| Anti-tamper hashes | Hand-injected sha1 hardcoded in source | Build-time codegen with sha256 |
| Hooks | 6+ `ClientAreaPage` registrations with priority dance | One registration → `HookDispatcher::dispatch()` |
| CSS source | Minified-only, no SCSS shipped | SCSS sources + build pipeline included |
| Settings | 4 stores: `tbladdonmodules`, `tblconfiguration`, `mytheme_settings`, JSON-in-text columns | 2 stores: `tblconfiguration` for WHMCS interop, one typed `mytheme_settings` table for the rest |
| Per-vendor store partials | Inside the theme (17+ vendor dirs) | Out of scope for v1 — buyers add via separate addons |

## Quick start

```bash
cd MyTheme-WHMCS-Starter
npm install
npm run build              # compiles SCSS, bundles JS, computes integrity hashes
# Then copy modules/addons/MyTheme/ → <whmcs>/modules/addons/MyTheme/
# And copy templates/mytheme/ → <whmcs>/templates/mytheme/
# Activate "MyTheme" under WHMCS Admin → Setup → Addon Modules
# Then choose Active Template = "mytheme" under Setup → General Settings → Client Area Template
```

## Renaming for your own brand

Two slugs to change everywhere:
- **Addon name** (`MyTheme` PascalCase) — appears in addon class names, function prefixes, namespace
- **Theme slug** (`mytheme` lowercase) — appears in directory names, config keys, route paths

```bash
# Replace placeholders (example for renaming to "Aurora")
grep -rl 'MyTheme' . | xargs sed -i '' 's/MyTheme/Aurora/g'
grep -rl 'mytheme' . | xargs sed -i '' 's/mytheme/aurora/g'
mv modules/addons/MyTheme   modules/addons/Aurora
mv templates/mytheme        templates/aurora
mv templates/aurora/core/mytheme.php templates/aurora/core/aurora.php
```

(On Linux, drop the `''` after `-i`.)

## Next steps

1. Read [BUILD.md](BUILD.md) for the build pipeline
2. Read [LICENSING-SETUP.md](LICENSING-SETUP.md) for setting up a license server (separate project)
3. Read [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) for the design rationale
4. Read [docs/HYBRID-STRUCTURE.md](docs/HYBRID-STRUCTURE.md) for the addon-managed WHMCS-native target structure
5. Read [docs/TEMPLATE-STRUCTURE.md](docs/TEMPLATE-STRUCTURE.md) for the `templates/mytheme` commercial visual-layer structure
6. Read [docs/EXTENDING.md](docs/EXTENDING.md) to understand how to add styles, layouts, page variants

## License

Proprietary. Customize the LICENSE file before distributing.
