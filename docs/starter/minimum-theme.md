# Minimum Viable Theme

The absolute minimum files needed to create a working WHMCS theme. This is the smallest functional theme you can ship.

## Two Approaches

### Approach A: Child Theme (Recommended)

Only **2 files required** — inherits everything else from the parent theme (Nexus or Twenty-One).

```
templates/mytheme/
├── theme.yaml           # REQUIRED
└── css/
    └── custom.css       # Optional - for style overrides
```

### Approach B: Standalone Parent Theme

**All 60+ templates required**. Much more work. Only use if you need complete layout control.

---

## Minimum Child Theme — 2 Files

### `theme.yaml` (REQUIRED)

```yaml
name: "My Custom Theme"
description: "Custom theme for My Company"
author: "My Company"
config:
  parent: nexus
```

**Available parent themes:**
- `nexus` — Default WHMCS 9 theme (recommended)
- `twenty-one` — WHMCS 8.1+ theme
- `six` — Legacy WHMCS 6/7 theme

### `css/custom.css` (Optional but typical)

```css
/* Override any Nexus variables */
:root {
    --primary-color: #2563eb;
    --success: #16a34a;
    --error: #dc2626;
}

/* Override specific components */
.navbar-brand img {
    max-height: 60px;
}

/* Add custom styles */
.my-custom-feature {
    padding: 2rem;
    background: #f8fafc;
}
```

**That's it.** With these 2 files, you have a working theme that:
- Shows up in Admin → General Settings → System Theme
- Inherits all 171 Nexus templates
- Inherits all JavaScript, CSS, images
- Only applies your `custom.css` overrides

---

## When to Copy Additional Template Files

Copy a template from the parent only when you need to modify it. The child theme resolver will:

1. Look for the file in your child theme first
2. Fall through to the parent theme if not found

### Common files to customize

```
templates/mytheme/
├── theme.yaml
├── css/
│   └── custom.css
├── header.tpl          # Modify navigation, branding
├── footer.tpl          # Modify footer links/layout
├── homepage.tpl        # Custom homepage
├── includes/
│   ├── head.tpl        # Add custom <head> tags
│   └── navbar.tpl      # Modify navigation rendering
```

**⚠️ Warning:** When you copy a template, you become responsible for maintaining it across WHMCS updates. Only override what you actually need to change.

---

## Mandatory vs Optional Files

### Truly Mandatory (when building standalone)

If you're NOT using a parent theme, these must exist:

| File | Purpose | Required? |
|------|---------|-----------|
| `theme.yaml` | Theme metadata | ✅ Yes |
| `header.tpl` | Page header + layout opening | ✅ Yes |
| `footer.tpl` | Page footer + layout closing | ✅ Yes |
| `homepage.tpl` | Public homepage | ✅ Yes |
| `includes/head.tpl` | CSS/JS loading | ✅ Yes |
| `includes/navbar.tpl` | Navigation rendering | ✅ Yes |
| `includes/sidebar.tpl` | Sidebar rendering | ✅ Yes |
| `includes/breadcrumb.tpl` | Breadcrumb | ✅ Yes |
| `includes/alert.tpl` | Alert messages | ✅ Yes |
| `includes/flashmessage.tpl` | Flash messages | ✅ Yes |
| `includes/modal.tpl` | Modal dialogs | ✅ Yes |
| `includes/captcha.tpl` | CAPTCHA | ✅ Yes |
| `login.tpl` | Login page | ✅ Yes |
| `clientregister.tpl` | Registration | ✅ Yes |
| `clientareahome.tpl` | Client dashboard | ✅ Yes |
| `clientareaproducts.tpl` | Services list | ✅ Yes |
| `clientareaproductdetails.tpl` | Service details | ✅ Yes |
| `clientareadomains.tpl` | Domain list | ✅ Yes |
| `clientareadomaindetails.tpl` | Domain details | ✅ Yes |
| `clientareainvoices.tpl` | Invoice list | ✅ Yes |
| `invoice-payment.tpl` | Invoice payment | ✅ Yes |
| `supportticketslist.tpl` | Ticket list | ✅ Yes |
| `viewticket.tpl` | Ticket view | ✅ Yes |
| `clientareadetails.tpl` | Account details | ✅ Yes |
| `announcements.tpl` | Announcements | ✅ Yes |
| `knowledgebase.tpl` | Knowledge base | ✅ Yes |
| `contact.tpl` | Contact form | ✅ Yes |
| `error/page-not-found.tpl` | 404 page | ✅ Yes |
| `error/internal-error.tpl` | 500 page | ✅ Yes |
| `payment/card/select.tpl` | Card select | ✅ Yes |
| `payment/card/inputs.tpl` | Card inputs | ✅ Yes |
| `payment/card/validate.tpl` | Card validation | ✅ Yes |
| `payment/billing-address.tpl` | Billing address | ✅ Yes |

### Optional (but recommended)

These templates enhance specific features. Missing them = broken feature, not broken site:

| File | Feature Broken If Missing |
|------|---------------------------|
| `affiliates.tpl` | Affiliate dashboard |
| `domain-pricing.tpl` | Domain pricing page |
| `serverstatus.tpl` | Server status page |
| `downloads.tpl` | Downloads section |
| `oauth/*.tpl` | OAuth integration |
| `store/*` | Marketplace/store |
| `upgrade*.tpl` | Service upgrades |

---

## Minimum theme.yaml Reference

### Child theme (simplest)

```yaml
name: "My Theme"
config:
  parent: nexus
```

### Child theme (with metadata)

```yaml
name: "My Custom Theme"
description: "Custom theme for ExampleHost"
author: "Your Company Name"
config:
  parent: nexus
```

### Standalone parent theme

```yaml
name: "Independent Theme"
description: "Fully standalone theme"
author: "Your Company"
properties:
  serverSidePagination: false
provides:
  bootstrap: 4.5.3
  jquery: 1.12.4
  fontawesome: 5.10.1
```

### Theme with explicit dependencies

```yaml
name: "Dependent Theme"
config:
  parent: nexus
dependencies:
  bootstrap: 4.5
  jquery: 1.12
```

---

## Activating Your Theme

### Via URL (preview without activating)

```
https://yourdomain.com/whmcs/?systpl=mytheme
```

### Via Admin

1. Navigate to **Configuration → System Settings → General Settings**
2. Find **System Theme** dropdown
3. Select your theme
4. Save Changes

### Via Database (advanced)

```sql
UPDATE tblconfiguration 
SET value = 'mytheme' 
WHERE setting = 'Template';
```

---

## Testing Checklist

Before deploying:

- [ ] Theme appears in System Theme dropdown
- [ ] Homepage loads correctly
- [ ] Login works
- [ ] Client dashboard renders
- [ ] Invoice pages display
- [ ] Support tickets work
- [ ] Domain/service lists populate
- [ ] Forms submit with valid CSRF
- [ ] Mobile responsive (check navbar)
- [ ] Footer `{$footeroutput}` present
- [ ] No JavaScript console errors
- [ ] Works in Firefox, Chrome, Safari, Edge

---

## Development Workflow

### 1. Create the skeleton

```bash
cd /path/to/whmcs/templates
mkdir mytheme
cd mytheme

# Create minimum files
cat > theme.yaml << EOF
name: "My Theme"
config:
  parent: nexus
EOF

mkdir css
touch css/custom.css
```

### 2. Preview

```
https://yourdomain.com/whmcs/?systpl=mytheme
```

### 3. Iterate

- Edit `css/custom.css` → refresh browser
- Copy templates from `templates/nexus/` → modify → refresh
- Use `{debug}` tag in any template to see all available variables

### 4. Activate when ready

Admin panel → System Theme → Select your theme

---

## Multi-Language Support

Your theme automatically inherits all language translations from `/lang/`. You don't need to do anything special.

To add custom language strings:

```php
// /lang/overrides/english.php
$_LANG['myCustom']['welcome'] = 'Welcome!';
$_LANG['myCustom']['cta'] = 'Get Started';
```

Then use: `{lang key='myCustom.welcome'}`

See [Language Keys Reference](/reference/language-keys.md) for details.

---

## Next Steps

- [Skeleton Files](/starter/skeleton-files.md) — Full directory structure reference
- [Header Template](/starter/header-template.md) — Complete `header.tpl` walkthrough
- [Footer Template](/starter/footer-template.md) — Complete `footer.tpl` walkthrough
- [Template Fallback](/starter/template-fallback.md) — How WHMCS resolves missing files
