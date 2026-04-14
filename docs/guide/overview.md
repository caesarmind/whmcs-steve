# Overview & Architecture

### Theme Types

WHMCS supports three types of themes:

| Type | Description | Use Case |
|------|-------------|----------|
| **Parent Theme** | Complete standalone theme | Base for child themes |
| **Child Theme** | Inherits from parent, overrides selectively | Recommended for customization |
| **Order Form Template** | Controls shopping cart/product display | Cart customization |

### Available Parent Themes (WHMCS 9)

- **Nexus** - Default theme for WHMCS 9.0+ (Bootstrap 4.5.3, jQuery 1.12.4, FontAwesome 5.10.1)
- **Twenty-One** - Default for WHMCS 8.1+
- **Six** - Legacy theme

### Theme Directory Naming Rules

- Single words only (no spaces)
- Lowercase letters and numbers only
- Child themes can also use hyphens and underscores
- Location: `/templates/yourthemename/`

### Asset Loading Chain

The asset loading order is critical for CSS specificity:

```
1. Open Sans font CSS (loaded via PHP helper)
2. all.min.css (Bootstrap 4.5.3 + base styles)
3. theme.min.css (Nexus theme-specific overrides)
4. FontAwesome CSS (solid, regular, light, brands, duotone)
5. custom.css (user customizations - loaded last, highest priority)
6. scripts.min.js (main theme JavaScript)
```

This chain is defined in `includes/head.tpl`:

```smarty
{\WHMCS\View\Asset::fontCssInclude('open-sans-family.css')}
<link href="{assetPath file='all.min.css'}?v={$versionHash}" rel="stylesheet">
<link href="{assetPath file='theme.min.css'}?v={$versionHash}" rel="stylesheet">
<link href="{$WEB_ROOT}/assets/fonts/css/fontawesome.min.css" rel="stylesheet">
{assetExists file="custom.css"}
<link href="{$__assetPath__}" rel="stylesheet">
{/assetExists}
<script src="{assetPath file='scripts.min.js'}?v={$versionHash}"></script>
```

### theme.yaml Configuration

The `theme.yaml` file is the central configuration for every theme:

**Nexus theme.yaml:**
```yaml
name: "Nexus"
description: "The Default Theme for WHMCS 9.0"
author: "WHMCS Limited"
properties:
  serverSidePagination: false   # Client-side pagination via DataTables
provides:
  bootstrap: 4.5.3
  jquery: 1.12.4
  fontawesome: 5.10.1
```

**Parameters reference:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `name` | string | Display name in admin area |
| `description` | string | Theme explanation |
| `author` | string | Attribution |
| `config.parent` | string | Parent theme directory name (child themes only) |
| `properties.serverSidePagination` | boolean | Whether server handles pagination |
| `dependencies` | object | Required assets from parent theme |
| `provides` | object | Assets this theme provides to children |

Version flexibility: Missing version segments are assumed compatible (e.g., `fontawesome: 5` matches `5.10.1`).
