# Extending the Theme

How to add the things buyers will ask for.

> Targets WHMCS 9 + PHP 8.3 + Smarty 4. PHP code uses backed enums, `readonly`, typed constants, and `match` expressions — write yours the same way for consistency.

## Add a new style preset

```bash
# 1. Create the directory
mkdir -p templates/hadrian/core/styles/sunset/assets

# 2. Add the manifest
cat > templates/hadrian/core/styles/sunset/style.php <<'EOF'
<?php
return [
    'name'        => 'Sunset',
    'description' => 'Warm orange + amber palette',
    'preview'     => 'thumb.png',
    'iconType'    => 'default',
    'variables'   => [
        'bodyClass' => 'theme-sunset',
        'colorMode' => 'light',
    ],
    'settings'    => [
        // Sub-style options (optional)
    ],
];
EOF

# 3. Add SCSS overrides for this style
cat > templates/hadrian/core/styles/sunset/_overrides.scss <<'EOF'
.theme-sunset {
    --color-primary: #f97316;
    --color-secondary: #fbbf24;
}
EOF
# (remember to @use this in templates/hadrian/assets/scss/theme.scss)

# 4. Register in theme.json
# Add "sunset" to provides.styles array

# 5. Add a thumbnail
# Drop a 200x125 thumb.png in core/styles/sunset/

# 6. Bump theme.json version
# 7. Build CSS, regenerate integrity hashes
npm run build
```

## Add a new layout

One folder. No `theme.json` edit, no `header.tpl` edit, no core CSS edit.
`LayoutsCache` scans `core/layouts/main-menu/` and `core/layouts/footer/` from
the admin entry points (Layouts page, Pages editor, activate, Tools → Rebuild);
any folder holding `layout.php` **and** `default.tpl` becomes an admin card,
badged **Custom**. The shipped `main-menu/topbar-minimal/` folder is a working
example of everything below — copy it to start.

```bash
# 1. The folder — its name is internal; lowercase letters, digits, hyphens
mkdir -p templates/hadrian/core/layouts/main-menu/condensed

# 2. layout.php — the manifest
cat > templates/hadrian/core/layouts/main-menu/condensed/layout.php <<'EOF'
<?php
return [
    'displayName' => 'Condensed',
    'description' => 'Smaller navbar with icons',
    'variables'   => [
        // REQUIRED. Becomes body[data-layout] and the .only-<token> gate
        // class. Must match /^[a-z][a-z0-9-]{1,30}$/ or the folder is
        // rejected (the Layouts page shows the reason).
        'dataLayout' => 'condensed',
    ],
    // OPTIONAL. The generated structural minimum, emitted server-side into
    // <style id="hadrian-layout-gates"> for the active layout. Omit the whole
    // block for a top bar; declare it for a pinned side column.
    'css' => [
        'contentOffset'  => 240,     // px margin on .ph-main-wrap
        'offsetSide'     => 'left',  // left | right
        'mobileCollapse' => true,    // offset -> 0 at <=900px (default true)
    ],
];
EOF

# 3. default.tpl — the markup. THE CONTRACT:
#    - root element carries class "only-<dataLayout>" (the generated gate
#      hides it whenever another layout is active, incl. ?preview=1)
#    - renders as a body-level sibling BEFORE .ph-main-wrap; close everything
#      you open
#    - the admin-driven menu arrives as $mtSidebarItems (same list the
#      shipped sidebar renders); branding as $hadrian.branding.logo.*
#    - mobile: the shell's inner-topbar + drawer render for every non-top
#      token — hide your chrome under 900px and you are done
cat > templates/hadrian/core/layouts/main-menu/condensed/default.tpl <<'EOF'
<nav class="cnd-bar only-condensed">
    {* your markup; see topbar-minimal/default.tpl for the full treatment *}
</nav>
EOF

# 4. layout.css (OPTIONAL) — your layout's own chrome, auto-linked with a
#    version stamp whenever your layout is active or previewed. Write it
#    against theme tokens (var(--color-surface) etc.), never hex, so it
#    follows the buyer's Style Manager palette and dark mode.
```

Then open **Hadrian → Layouts** — the card is there. `Activate` stores it per
audience, `Live preview` opens `?preview=1&layout=<token>`. The client area
picks it up through the same discovery cache; like new page variants, a
dropped-in folder appears after the next admin visit, not instantly.

Validation happens at scan time and failures are loud: a folder with a broken
manifest, a bad token, or a token colliding with a shipped layout is listed on
the Layouts page with the reason, instead of silently not appearing.

## Add a new page variant

```bash
# Each WHMCS page can have multiple variants
mkdir -p templates/hadrian/core/pages/clientareahome/compact

# Variant settings (admin-editable checkboxes etc.)
cat > templates/hadrian/core/pages/clientareahome/compact/pageoption.php <<'EOF'
<?php
return [
    'display_name' => 'Compact',
    'description'  => 'Single-column dashboard with no tiles',
    'preview'      => 'thumb.png',
    'settings'     => [
        'showTickets' => [
            'type' => 'checkbox',
            'name' => 'showTickets',
            'label' => 'Show recent tickets',
            'default' => true,
        ],
    ],
];
EOF

# Variant implementation
cat > templates/hadrian/core/pages/clientareahome/compact/compact.tpl <<'EOF'
<div class="dashboard-compact">
    {* your markup *}
</div>
EOF
```

The variant becomes selectable in the admin UI under Pages → Dashboard.

## Add a translation

```bash
# Copy the English file as a starting point
cp templates/hadrian/core/lang/english.php templates/hadrian/core/lang/spanish.php

# Edit each value. Don't change keys.
```

`Helpers\Lang::factory()` picks the file matching `$_SESSION['Language']`; falls back to English when missing.

## Add a hook

The addon-side: edit `modules/addons/Hadrian/src/Service/Hooks.php` and add a new private method matching the hook name (lowercase first letter):

```php
// inside Hooks class
private function clientAreaPageInvoices(array $vars, Template $template): array
{
    return [
        'invoiceFilters' => ['unpaid', 'paid', 'cancelled'],
    ];
}
```

Then register it in `modules/addons/Hadrian/hooks.php`:

```php
add_hook('ClientAreaPageInvoices', 1, fn($vars) =>
    HookService::instance()->dispatch('ClientAreaPageInvoices', $vars));
```

## Add a setting

```php
// Anywhere
\Hadrian\Models\Settings::setValue('show_search_box', true, 'bool');
$shown = \Hadrian\Models\Settings::getValue('show_search_box', false);
```

In Smarty: `{$hadrian.addonSettings.show_search_box}`.

## Add a build target for integrity check

Edit `scripts/integrity-targets.json` and add the path to the file. Rerun `npm run build:integrity`.

## Add an admin AJAX endpoint

`src/Service/AjaxService.php` already routes `$_POST['mtAction']` → `action<Name>` method. Add yours:

```php
private static function actionGetStats(array $payload): void
{
    self::respond([
        'tickets' => 5,
        'invoices' => 12,
    ]);
}
```

Trigger from JS: `fetch('/clientarea.php', { method: 'POST', body: 'mtAction=getStats' })`.

## Override a partial without forking

Buyers do this. Document it in your customer-facing readme:

```
templates/hadrian/overwrites/header.tpl       # overrides header.tpl
templates/hadrian/includes/common/overwrites/logo.tpl   # overrides includes/common/logo.tpl
templates/hadrian/core/pages/clientareahome/overwrites/  # not yet supported by dispatcher; document if you add it
```

The overrides escape hatch is per-file: each tpl that includes another via `{include}` checks for an `overwrites/` sibling first.

## When something breaks

| Symptom | Likely cause |
|---|---|
| "Access has been blocked!" page on every request | Forgot `npm run build:integrity` after a PHP edit |
| Template isn't selectable in WHMCS admin | License invalid; check addon → License tab |
| Style change not visible | CSS cached; bump `theme.json` version OR clear browser cache |
| Style not appearing in admin UI | Forgot to add it to `theme.json` `provides.styles` |
| Layout not appearing in admin UI | Folder missing `layout.php` or `default.tpl`, or rejected — the Layouts page lists rejected folders with the reason |
| Smarty error "unknown template" | Check the `{include file=...}` path; should start with backtick-delimited `{$template}/` |
