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
| `templates/hadrian/assets/scss/theme.scss` | `templates/hadrian/assets/css/theme.css` (minified) |
| `templates/hadrian/assets/scss/site.scss` | `templates/hadrian/assets/css/site.css` (minified) |
| `templates/hadrian/assets/scss/theme-rtl.scss` | `templates/hadrian/assets/css/theme-rtl.css` |
| `templates/hadrian/assets/scss/site-rtl.scss` | `templates/hadrian/assets/css/site-rtl.css` |
| Per-style SCSS in `templates/hadrian/core/styles/<name>/assets/_*.scss` | Concatenated into per-style `style.css` |
| `templates/hadrian/assets/js/src/*.js` | `templates/hadrian/assets/js/dist/{theme.js,theme.min.js}` |

Source maps are generated for development builds (`NODE_ENV=development`); stripped for production.

## Integrity hashes (the load-bearing anti-tamper)

The starter includes `scripts/inject-integrity-hashes.mjs`. It:

1. Computes `sha256_file()` of the load-bearing files: `License.php`, `LicenseHelper.php`, `Template.php`, plus any others you add to `scripts/integrity-targets.json`.
2. Writes the hashes into a generated PHP file at `modules/addons/Hadrian/src/Helpers/IntegrityHashes.php`.
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
  --encode Hadrian.php \
  --encode hooks.php \
  --encode adminHooks.php \
  --encode autoload.php \
  --target-version 8.1 \
  --target-php81 \
  modules/addons/Hadrian/
```

(adjust paths and target-version per supported PHP minor; PHP 8.1 is the minimum because the code uses backed enums and readonly properties)

**What to encode:**
- All PHP under `modules/addons/Hadrian/src/`
- `Hadrian.php`, `hooks.php`, `adminHooks.php`, `autoload.php`
- `templates/hadrian/core/hadrian.php` (the per-template `secret_key` file)

**What NOT to encode** (leave plain so customers can customize):
- All `.tpl` files
- All static assets (`templates/hadrian/assets/**`)
- All admin views (`modules/addons/Hadrian/views/**/*.tpl`)
- `templates/hadrian/theme.json` (manifest)

## Multi-PHP-version builds

WHMCS 9 supports PHP 8.1+. The code in this scaffold avoids PHP 8.2/8.3-only features so a single source tree encodes cleanly for all supported runtimes:

```
dist/
├── php81/modules/addons/Hadrian/...    # encoded for PHP 8.1 (WHMCS 9 minimum)
├── php82/modules/addons/Hadrian/...    # encoded for PHP 8.2
├── php83/modules/addons/Hadrian/...    # encoded for PHP 8.3
└── php84/modules/addons/Hadrian/...    # encoded for PHP 8.4 (once ionCube supports it)
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
node hadrian/scripts/package.mjs --hooks <dir> --version 1.8.0
# or, from hadrian/:  npm run package -- --hooks <dir> --version 1.8.0
```

It writes `dist/Hadrian-<version>.zip`, laid out like a WHMCS installation so a buyer extracts it at their WHMCS root:

```
templates/hadrian/                    from hadrian/templates/hadrian
templates/orderforms/hadrian_cart/    from hadrian_cart (repo root)
modules/addons/Hadrian/               from hadrian/modules/addons/Hadrian
includes/hooks/                       the two license files in --hooks
```

What it does, in order:

1. Lists the files to ship with git. Only tracked files go in, so branding uploads, generated CSS and anything else git ignores stay out. It stops if those folders have uncommitted changes (`--allow-dirty` overrides that for a test build).
2. Copies them into `dist/stage/`, text with LF line endings. `.scss`, `.map`, `.ts` and the cart's `_archive/` are left out.
3. Copies `hostnodes_theme_license.php` and `hostnodes_license_config.php` from `--hooks`, byte for byte. It stops if the first one is not encoded, because in plain form its licence check can simply be edited out (`--allow-plain-hook` overrides that for a test build). The hook holds only the licence server's public key, so nothing secret is in it either way.
4. Stamps the release version into the staged `Hadrian.php`, `core/hadrian.php` and `theme.json`, and writes a `release.json` into each of the three folders. The addon's Setup page compares those marks to catch a half-finished upload.
5. Computes the integrity hashes from the staged files and writes `IntegrityHashes.php` there.
6. Writes the zip. No `zip` binary and no `npm install` are needed.

The working tree is never changed. Its own version numbers keep their jobs: `core/hadrian.php` is the CSS cache-buster and is bumped far more often than releases happen.

The version comes from `--version`, or from `"version"` in `hadrian/package.json`.

### Encoding

The hashes must describe the files exactly as the buyer receives them, so encoding goes between staging and hashing:

```bash
node hadrian/scripts/package.mjs --hooks <dir> --version 1.8.0 --stage-only
# encode the PHP inside hadrian/dist/stage/ in place
node hadrian/scripts/package.mjs --version 1.8.0 --from-stage
```

Do not run `npm run build:integrity` on the working tree for a release. It hashes the unstamped source files, and the next PHP edit trips the check on any site running from that tree.

### Checking a build

`node tests/static/check-release-package.mjs` builds a throwaway release and reads it back with PHP's `ZipArchive`: four folders, one version, hashes that match the zipped bytes, and every file the Setup page looks for. It runs in the static test tier.

## Recommended workflow

```
develop:  edit, then node tests/run.mjs --tier static,compile
test:     the local stack junctions the working tree into WHMCS (scripts/local-stack)
release:  commit → package.mjs --stage-only → encode dist/stage → package.mjs --from-stage
```

## When a build fails

| Error | Likely cause | Fix |
|---|---|---|
| `Sass compilation failed` | SCSS syntax error | check `assets/scss/_*.scss` for the file noted |
| `IntegrityHashes mismatch on <file>` at runtime | Forgot to run `build:integrity` after editing PHP | `npm run build:integrity` then re-encode |
| `License check fails on every page` | TLS issue or license key not set | check `tblconfiguration['Hadrian-<template>-license']`; check the license server URL in `src/Template/License.php` |
| ionCube error 199 ("Loader not installed") | Trying to run encoded files without ionCube | use plain (development) build, or install ionCube on the test server |
