# CSS & SASS Architecture

### SCSS Compilation

The main SCSS entry point is `sass/theme.scss`, which imports all partials:

```scss
@import "../../../node_modules/bootstrap-four/scss/bootstrap";
@import "global";
@import "forms";
@import "layout";
@import "buttons";
@import "colors";
@import "tabs";
@import "pagination";
@import "sidebar";
@import "home";
@import "client-home";
@import "two-factor";
@import "popover";
@import "captcha";
@import "email-verification";
@import "markdown";
@import "marketconnect";
@import "socials";
@import "upgrades";
@import "affiliate";
@import "support";
@import "registration";
@import "payments";
@import "product-details";
@import "tlds";
@import "tables";
@import "products";
@import "cart";
```

This compiles to `css/theme.css` and `css/theme.min.css`.

A separate `sass/invoice.scss` compiles to `css/invoice.css`.

### SCSS Partial Purposes

| Partial | Purpose |
|---------|---------|
| `_global.scss` | Base typography, body styles, utility classes, overlay, form error states, print styles |
| `_layout.scss` | Header, footer, navbar, main-body section, grid layout |
| `_colors.scss` | Card accent colors, background colors, label colors, status colors |
| `_forms.scss` | Form controls, input groups, validation states |
| `_buttons.scss` | Button variants and overrides |
| `_tables.scss` | Table styles, DataTables overrides |
| `_tabs.scss` | Tab navigation component |
| `_pagination.scss` | Pagination component |
| `_sidebar.scss` | Sidebar cards, list groups, mobile select |
| `_home.scss` | Public homepage styles (hero, domain search, action icons) |
| `_client-home.scss` | Client dashboard tiles, stats, panels |
| `_products.scss` | Product listing pages |
| `_product-details.scss` | Individual product detail page |
| `_payments.scss` | Payment form styles |
| `_billing-address.scss` | Billing address form |
| `_cart.scss` | Shopping cart pages |
| `_registration.scss` | Client registration form |
| `_support.scss` | Support ticket pages |
| `_affiliate.scss` | Affiliate program pages |
| `_upgrades.scss` | Upgrade/renewal pages |
| `_view-invoice.scss` | Invoice viewing page |
| `_two-factor.scss` | Two-factor authentication pages |
| `_email-verification.scss` | Email verification UI |
| `_popover.scss` | Popover UI component |
| `_socials.scss` | Social media/linked accounts |
| `_marketconnect.scss` | MarketConnect store integration |
| `_markdown.scss` | Markdown editor/preview |
| `_tlds.scss` | TLD/domain pricing styles |
| `_captcha.scss` | CAPTCHA styling |

### CSS Variables System

The Nexus theme uses CSS custom properties (variables) extensively. Override them in `custom.css`:

```css
:root {
    /* Neutral shades (50-950 scale) */
    --neutral-50: #value;
    --neutral-100: #value;
    /* ... through --neutral-950 */

    /* Semantic colors */
    --primary-color: #your-brand-color;
    --secondary: #value;
    --success: #value;
    --info: #value;
    --notice: #value;
    --warning: #value;
    --error: #value;

    /* Text colors */
    --text: #value;
    --text-lifted: #value;
    --text-accented: #value;
    --text-muted: #value;
    --text-inverted: #value;

    /* Border colors */
    --border: #value;
    --border-lifted: #value;
    --border-accented: #value;
    --border-muted: #value;

    /* Background colors */
    --bg-lifted: #value;
    --bg-accented: #value;
    --bg-inverted: #value;

    /* Typography */
    --font-size-xs: #value;
    --font-size-sm: #value;
    --font-size-md: #value;
    --font-size-lg: #value;

    /* Spacing */
    --spacing-sm: #value;
    --spacing-md: #value;
    --spacing-lg: #value;

    /* Rounding */
    --rounding-sm: #value;
    --rounding-md: #value;
    --rounding-lg: #value;

    /* Other */
    --letter-spacing: #value;
    --disabled-opacity: #value;
}
```

### Color Accent Classes

Defined in `_colors.scss`, these classes are used throughout the theme:

```scss
/* Card accent colors (top border) */
.card-accent-gold      { border-top: 3px solid var(--yellow-300); }
.card-accent-green     { border-top: 3px solid var(--success-accented); }
.card-accent-red       { border-top: 3px solid var(--error); }
.card-accent-blue      { border-top: 3px solid var(--info); }
.card-accent-teal      { border-top: 3px solid var(--teal-300); }
/* ... and more (see full list in _colors.scss) */

/* Background color classes */
.bg-color-gold   { background-color: var(--yellow-300); }
.bg-color-green  { background-color: var(--success); }
.bg-color-red    { background-color: var(--error); }
.bg-color-blue   { background-color: var(--info); }
/* ... */

/* Status colors */
.status-active, .status-open, .status-completed { background-color: var(--success); }
.status-pending          { background-color: var(--warning); }
.status-suspended        { background-color: var(--yellow-300); }
.status-terminated       { background-color: var(--neutral); }
.status-unpaid           { background-color: var(--error); }
.status-paid             { background-color: var(--success); }
/* ... full list in _colors.scss */
```

### Customizing with `custom.css`

The `css/custom.css` file loads last and overrides everything. Best practice for style-only modifications:

```css
/* Override brand colors */
:root {
    --primary-color: #2563eb;
    --success: #16a34a;
}

/* Override specific elements */
.header {
    background-color: #1e293b;
}

.navbar-brand img {
    max-height: 50px;
}

/* Custom homepage styling */
.home-domain-search {
    background: linear-gradient(135deg, #667eea, #764ba2);
}
```
