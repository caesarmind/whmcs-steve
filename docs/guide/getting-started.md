# Getting Started

### Creating a Child Theme (Recommended)

**Step 1: Create the directory**

```
/templates/mytheme/
```

**Step 2: Create `theme.yaml`**

```yaml
name: "My Custom Theme"
description: "Custom theme for my hosting company"
author: "Your Company"
config:
  parent: nexus
```

**Step 3: Create `css/custom.css`**

```css
/* Loads after all parent styles - highest specificity */
.primary-bg-color {
    background-color: #your-brand-color;
}
```

**Step 4: Copy only templates you want to customize**

Copy individual `.tpl` files from the parent theme. Uncustomized files automatically fall through to the parent version. Essential files to copy for structural changes:
- `header.tpl`
- `footer.tpl`

**Step 5: Preview your theme**

```
https://yourdomain.com/whmcs/?systpl=mytheme
```

**Step 6: Activate**

Configuration > System Settings > General Settings > System Theme dropdown.

### Loading Custom Assets

Use the `{assetPath}` function to reference theme-local assets:

```html
<link href="{assetPath file='mycssfile.css'}" rel="stylesheet">
<script src="{assetPath file='myjsfile.js'}"></script>
```

For assets in subdirectories (like the dynamic store):

```html
<link href="{assetPath ns='store/dynamic/assets' file='dynamic-store.css'}" rel="stylesheet">
```
