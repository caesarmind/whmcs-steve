# Cart Theme (nexus_cart)

### Overview

The Nexus cart theme is a separate order form template that controls the shopping cart pages.

**Key constraint:** The layout of Nexus SPA (Single Page Application) pages cannot be modified - only CSS customization is allowed.

### Structure

```
nexus_cart/
├── theme.yaml              # Parent: standard_cart
├── css/
│   ├── custom.css          # CSS variable overrides
│   └── style.min.css       # Compiled cart styles
├── js/
│   └── main.min.js         # Cart JavaScript
├── domainregister.tpl      # Domain registration page
├── viewcart.tpl            # View cart page
├── images/
│   └── tldLogos/           # TLD logo images (19 files)
└── thumbnail.gif           # Theme preview
```

### Configuration

```yaml
# nexus_cart/theme.yaml
config:
  parent: standard_cart
```

### CSS Customization

The Nexus Cart supports CSS variable overrides in `css/custom.css`:

```css
:root {
    /* Neutral shades */
    --neutral-50: #value;
    /* through --neutral-950 */

    /* Semantic colors */
    --primary-color: #value;
    --secondary: #value;
    --success: #value;
    --info: #value;
    --notice: #value;
    --warning: #value;
    --error: #value;

    /* Text, border, background variants */
    --text: #value;
    --text-lifted: #value;
    --text-accented: #value;
    --border: #value;
    --bg-lifted: #value;

    /* Typography */
    --font-size-xs: #value;
    --font-size-sm: #value;
    --font-size-md: #value;
    --font-size-lg: #value;

    /* Spacing & rounding */
    --spacing-sm: #value;
    --rounding-sm: #value;
    --letter-spacing: #value;
    --disabled-opacity: #value;
}
```

### SPA Pages (CSS-Only Customization)

- Domain pricing page
- Domain search results
- View cart page
- Checkout flow

### Preview Cart Theme

```
https://yourdomain.com/whmcs/cart.php?carttpl=nexus_cart
```

### Activation

Configuration > System Settings > General Settings > Ordering tab, or per product group.

### Nexus Cart SPA Architecture

The cart templates use a **Single Page Application** approach with Vue.js:

```smarty
{* domainregister.tpl *}
<div id="order-standard_cart">
    <div data-app="domain-module" data-init="{getNexusData}"></div>
</div>
<script src="{assetPath file='main.min.js'}"></script>
```

```smarty
{* viewcart.tpl *}
<div id="order-standard_cart">
    {if $checkout}
        {include file="orderforms/{$carttpl}/checkout.tpl"}
    {else}
        <div data-app="cart-module" data-init="{getNexusData}"></div>
    {/if}
</div>
```

**Key patterns:**
- `{getNexusData}` - Custom Smarty function that outputs JSON configuration
- `data-app` - Identifies which Vue component to mount
- Parent template: `standard_cart` (inherited via theme.yaml)
- Includes from parent: `orderforms/standard_cart/common.tpl`

### Cart CSS Variables (Shadow DOM Prefix)

The cart uses `--vl-` prefixed CSS variables (different from main theme):

```css
:root {
    /* Primary color variations */
    --vl-primary: #value;
    --vl-primary-lifted: #value;
    --vl-primary-accented: #value;

    /* Secondary */
    --vl-secondary: #value;
    --vl-secondary-lifted: #value;
    --vl-secondary-accented: #value;

    /* Status colors - each with lifted/accented variants */
    --vl-success: #value;
    --vl-info: #value;
    --vl-notice: #value;
    --vl-warning: #value;
    --vl-error: #value;

    /* Grayscale/Neutral */
    --vl-grayscale: #value;
    --vl-neutral: #value;

    /* Text hierarchy */
    --vl-text-inverted: #value;
    --vl-text-muted: #value;
    --vl-text-lifted: #value;
    --vl-text-accented: #value;
    --vl-text: #value;

    /* Border hierarchy */
    --vl-border-muted: #value;
    --vl-border: #value;
    --vl-border-lifted: #value;
    --vl-border-accented: #value;

    /* Background hierarchy */
    --vl-bg: #value;
    --vl-bg-muted: #value;
    --vl-bg-lifted: #value;
    --vl-bg-accented: #value;
    --vl-bg-inverted: #value;

    /* Typography */
    --vl-text-xs: #value;
    --vl-text-sm: #value;
    --vl-text-md: #value;
    --vl-text-lg: #value;

    /* Spacing */
    --vl-outline-sm: #value;
    --vl-outline-md: #value;
    --vl-outline-lg: #value;

    /* Rounding */
    --vl-rounding-sm: #value;
    --vl-rounding-md: #value;
    --vl-rounding-lg: #value;

    /* Other */
    --vl-letter-spacing: #value;
    --vl-disabled-opacity: #value;
}
```

**Important:** The cart CSS variables use `--vl-` prefix while the main theme uses plain names (e.g., `--primary-color`, `--success`). These are different variable systems.

### Cart Template Inline Overrides

The `viewcart.tpl` includes inline CSS to override main theme layout:

```html
<style>
    /* Hide main navigation on cart pages */
    .navbar { display: none; }
    /* Override main body background */
    section#main-body { background: white; }
</style>
```
