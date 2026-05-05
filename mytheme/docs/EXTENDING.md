# Extending the Theme

How to add the things buyers will ask for.

> Targets WHMCS 9 + PHP 8.3 + Smarty 4. PHP code uses backed enums, `readonly`, typed constants, and `match` expressions — write yours the same way for consistency.

## Add a new style preset

```bash
# 1. Create the directory
mkdir -p templates/mytheme/core/styles/sunset/assets

# 2. Add the manifest
cat > templates/mytheme/core/styles/sunset/style.php <<'EOF'
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
cat > templates/mytheme/core/styles/sunset/_overrides.scss <<'EOF'
.theme-sunset {
    --color-primary: #f97316;
    --color-secondary: #fbbf24;
}
EOF
# (remember to @use this in templates/mytheme/assets/scss/theme.scss)

# 4. Register in theme.json
# Add "sunset" to provides.styles array

# 5. Add a thumbnail
# Drop a 200x125 thumb.png in core/styles/sunset/

# 6. Bump theme.json version
# 7. Build CSS, regenerate integrity hashes
npm run build
```

## Add a new layout

```bash
# 1. Create directory
mkdir -p templates/mytheme/core/layouts/main-menu/condensed

# 2. Manifest
cat > templates/mytheme/core/layouts/main-menu/condensed/layout.php <<'EOF'
<?php
return [
    'displayName' => 'Condensed',
    'description' => 'Smaller navbar with icons',
    'preview'     => 'thumb.png',
    'order'       => 3,
    'variables'   => [
        'bodyClass' => 'layout-condensed',
        'sidebarPresent' => false,
    ],
];
EOF

# 3. The actual layout tpl
cat > templates/mytheme/core/layouts/main-menu/condensed/default.tpl <<'EOF'
<header class="app-nav app-nav--condensed">
    {* your markup *}
</header>
EOF

# 4. Add to theme.json provides.layouts.main-menu
```

## Add a new page variant

```bash
# Each WHMCS page can have multiple variants
mkdir -p templates/mytheme/core/pages/clientareahome/compact

# Variant settings (admin-editable checkboxes etc.)
cat > templates/mytheme/core/pages/clientareahome/compact/pageoption.php <<'EOF'
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
cat > templates/mytheme/core/pages/clientareahome/compact/compact.tpl <<'EOF'
<div class="dashboard-compact">
    {* your markup *}
</div>
EOF
```

The variant becomes selectable in the admin UI under Pages → Dashboard.

## Add a translation

```bash
# Copy the English file as a starting point
cp templates/mytheme/core/lang/english.php templates/mytheme/core/lang/spanish.php

# Edit each value. Don't change keys.
```

`Helpers\Lang::factory()` picks the file matching `$_SESSION['Language']`; falls back to English when missing.

## Add a hook

The addon-side: edit `modules/addons/MyTheme/src/Service/Hooks.php` and add a new private method matching the hook name (lowercase first letter):

```php
// inside Hooks class
private function clientAreaPageInvoices(array $vars, Template $template): array
{
    return [
        'invoiceFilters' => ['unpaid', 'paid', 'cancelled'],
    ];
}
```

Then register it in `modules/addons/MyTheme/hooks.php`:

```php
add_hook('ClientAreaPageInvoices', 1, fn($vars) =>
    HookService::instance()->dispatch('ClientAreaPageInvoices', $vars));
```

## Add a setting

```php
// Anywhere
\MyTheme\Models\Settings::setValue('show_search_box', true, 'bool');
$shown = \MyTheme\Models\Settings::getValue('show_search_box', false);
```

In Smarty: `{$myTheme.addonSettings.show_search_box}`.

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
templates/mytheme/overwrites/header.tpl       # overrides header.tpl
templates/mytheme/includes/common/overwrites/logo.tpl   # overrides includes/common/logo.tpl
templates/mytheme/core/pages/clientareahome/overwrites/  # not yet supported by dispatcher; document if you add it
```

The overrides escape hatch is per-file: each tpl that includes another via `{include}` checks for an `overwrites/` sibling first.

## When something breaks

| Symptom | Likely cause |
|---|---|
| "Access has been blocked!" page on every request | Forgot `npm run build:integrity` after a PHP edit |
| Template isn't selectable in WHMCS admin | License invalid; check addon → License tab |
| Style change not visible | CSS cached; bump `theme.json` version OR clear browser cache |
| Variant not appearing in admin UI | Forgot to add it to `theme.json` `provides.styles` / `provides.layouts.main-menu` |
| Smarty error "unknown template" | Check the `{include file=...}` path; should start with backtick-delimited `{$template}/` |
