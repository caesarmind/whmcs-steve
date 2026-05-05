# Build Pipeline

## Prerequisites

- **Node.js 20+** and npm
- **PHP 8.1+** (the WHMCS 9 minimum; the code stays portable across 8.1, 8.2, 8.3, 8.4)
- **WHMCS 9.0+** (uses Smarty 4 in the `\Smarty\Smarty` namespace; the addon also auto-detects Smarty 3 for legacy WHMCS 8 hosts)
- **ionCube Encoder 13+** (commercial — required for production builds; optional for development. Use 14+ if you want to ship PHP 8.3 builds.)

## Quick reference

```bash
npm install                    # install build deps
npm run build                  # full build: scss + js + integrity hashes
npm run build:css              # SCSS → CSS only
npm run build:js               # JS bundling only
npm run build:integrity        # recompute integrity hashes (run after every PHP edit)
npm run watch                  # rebuild on file change (development)
npm run package                # zip everything for distribution
```

## What gets built

| Source | Output |
|---|---|
| `templates/mytheme/assets/scss/theme.scss` | `templates/mytheme/assets/css/theme.css` (minified) |
| `templates/mytheme/assets/scss/site.scss` | `templates/mytheme/assets/css/site.css` (minified) |
| `templates/mytheme/assets/scss/theme-rtl.scss` | `templates/mytheme/assets/css/theme-rtl.css` |
| `templates/mytheme/assets/scss/site-rtl.scss` | `templates/mytheme/assets/css/site-rtl.css` |
| Per-style SCSS in `templates/mytheme/core/styles/<name>/assets/_*.scss` | Concatenated into per-style `style.css` |
| `templates/mytheme/assets/js/src/*.js` | `templates/mytheme/assets/js/dist/{theme.js,theme.min.js}` |

Source maps are generated for development builds (`NODE_ENV=development`); stripped for production.

## Integrity hashes (the load-bearing anti-tamper)

The starter includes `scripts/inject-integrity-hashes.mjs`. It:

1. Computes `sha256_file()` of the load-bearing files: `License.php`, `LicenseHelper.php`, `Template.php`, plus any others you add to `scripts/integrity-targets.json`.
2. Writes the hashes into a generated PHP file at `modules/addons/MyTheme/src/Helpers/IntegrityHashes.php`.
3. Stub files (auto-injected at the top of every encoded PHP file) call `IntegrityHashes::verifyOrDie($targetFile)` — which checks the runtime sha256 against the build-time hash and renders an error page on mismatch.

**Run integrity hash injection AFTER any PHP edit and BEFORE encoding.**

```bash
npm run build:integrity
```

If you skip this step, ionCube-encoded files will refuse to run (because runtime sha256 won't match the stale build-time hash).

## Encoding for production

After `npm run build`:

```bash
# ionCube Encoder 14+ — supports PHP 8.3
ioncube_encoder \
  --no-doc-comments \
  --replace-target \
  --encode src/Template/License.php \
  --encode src/Template/LicenseHelper.php \
  --encode src/Template/LicenseState.php \
  --encode src/Template/Template.php \
  --encode src/Helpers/LicenseHelper.php \
  --encode src/Helpers/IntegrityHashes.php \
  --encode src/Helpers/AddonHelper.php \
  --encode src/Helpers/ThemeManifest.php \
  --encode src/Service/Hooks.php \
  --encode src/Models/Configuration.php \
  --encode src/Models/Settings.php \
  --encode MyTheme.php \
  --encode hooks.php \
  --encode adminHooks.php \
  --encode autoload.php \
  --target-version 8.1 \
  --target-php81 \
  modules/addons/MyTheme/
```

(adjust paths and target-version per supported PHP minor; PHP 8.1 is the minimum because the code uses backed enums and readonly properties)

**What to encode:**
- All PHP under `modules/addons/MyTheme/src/`
- `MyTheme.php`, `hooks.php`, `adminHooks.php`, `autoload.php`
- `templates/mytheme/core/mytheme.php` (the per-template `secret_key` file)

**What NOT to encode** (leave plain so customers can customize):
- All `.tpl` files
- All static assets (`templates/mytheme/assets/**`)
- All admin views (`modules/addons/MyTheme/views/**/*.tpl`)
- `templates/mytheme/theme.json` (manifest)

## Multi-PHP-version builds

WHMCS 9 supports PHP 8.1+. The code in this scaffold avoids PHP 8.2/8.3-only features so a single source tree encodes cleanly for all supported runtimes:

```
dist/
├── php81/modules/addons/MyTheme/...    # encoded for PHP 8.1 (WHMCS 9 minimum)
├── php82/modules/addons/MyTheme/...    # encoded for PHP 8.2
├── php83/modules/addons/MyTheme/...    # encoded for PHP 8.3
└── php84/modules/addons/MyTheme/...    # encoded for PHP 8.4 (once ionCube supports it)
```

ionCube encoding is PHP-version-locked: an 8.1-encoded file won't run on 8.3 (different bytecode). Generate one folder per supported runtime. The non-encoded files (`.tpl`, assets, json, SCSS sources, build scripts) are identical across all versions.

If you want to use PHP 8.2/8.3 features (typed class constants, `readonly class`, `Random\Randomizer`, `json_validate()`):
- Bump `composer.json` `php` requirement to `>=8.3`
- Add the features
- Drop the `php81/` and `php82/` build targets

## Watch mode

```bash
npm run watch
```

Rebuilds CSS on `.scss` change, JS on `.js` change. Skips integrity-hash regeneration (you don't run encoded files in development — too slow).

## Packaging for distribution

```bash
npm run package        # produces dist/MyTheme-<version>.zip
```

The packaged zip:
- Runs `npm run build`
- Encodes the protected files
- Strips source maps and `.scss` files (for the buyer-facing zip; ship `BUILD.md` separately or in `dist/source/`)
- Generates a manifest with file hashes for the installer to verify
- Bundles into `dist/MyTheme-<version>.zip`

## Recommended workflow

```
develop:  npm run watch
test:     copy modules/ + templates/ → local WHMCS install
release:  npm run build && npm run build:integrity && encode → npm run package
```

## When a build fails

| Error | Likely cause | Fix |
|---|---|---|
| `Sass compilation failed` | SCSS syntax error | check `assets/scss/_*.scss` for the file noted |
| `IntegrityHashes mismatch on <file>` at runtime | Forgot to run `build:integrity` after editing PHP | `npm run build:integrity` then re-encode |
| `License check fails on every page` | TLS issue or license key not set | check `tblconfiguration['MyTheme-<template>-license']`; check the license server URL in `src/Template/License.php` |
| ionCube error 199 ("Loader not installed") | Trying to run encoded files without ionCube | use plain (development) build, or install ionCube on the test server |
