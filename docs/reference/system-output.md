# System Output Variables

WHMCS injects generated HTML into templates through special output variables. Understanding what each variable contains is critical when creating custom header.tpl, footer.tpl, or other templates - you must render these variables or features will break, but you must NOT duplicate what they inject.

## Overview

| Variable | Location | Purpose |
|----------|----------|---------|
| `{$headoutput}` | `<head>` section | CSS, meta tags, scripts for head |
| `{$headeroutput}` | After `<body>` opening | Header-specific HTML |
| `{$footeroutput}` | Before `</body>` closing | Scripts, tracking, CSRF setup |
| `{$moduleclientarea}` | Product details page | Service-specific module HTML |
| `{$registrarclientarea}` | Domain details page | Registrar-specific HTML |
| `{$hookOutput}` | Various | Array of hook-returned HTML |
| `{$addons_html}` | Client home | Array of addon HTML outputs |

---

## `{$headoutput}` — Head Section Output

**Where:** Inside `<head>` of `header.tpl`, AFTER `{include file="$template/includes/head.tpl"}`

**What it contains:**
- Additional CSS from system (admin, modules, addons)
- CAPTCHA initialization scripts (reCAPTCHA API script)
- Meta tags from modules
- Analytics/tracking code
- PWA manifest links (if enabled)
- Addon module head output
- Hook output from `ClientAreaHeadOutput` hook

**Usage in template:**

```smarty
<head>
    <meta charset="{$charset}">
    <title>{$pagetitle} - {$companyname}</title>
    {include file="$template/includes/head.tpl"}
    {$headoutput}  {* Required - DO NOT OMIT *}
</head>
```

**What you should NOT duplicate in custom templates:**
- reCAPTCHA loader script (already injected if CAPTCHA enabled)
- Module-specific CSS
- WHMCS system CSS fragments

**What you CAN add before `{$headoutput}`:**
- Your theme's CSS files (loaded first for lower specificity)
- Custom meta tags
- Favicon links

---

## `{$headeroutput}` — Header Region Output

**Where:** Right after `<body>` tag, before your custom header HTML

**What it contains:**
- Header-specific hook output (`ClientAreaHeaderOutput`)
- Module/addon header HTML
- Admin masquerade banner (when applicable)

**Usage:**

```smarty
<body>
    {if $captcha}{$captcha->getMarkup()}{/if}
    {$headeroutput}  {* Required before your header *}

    <header id="header">
        <!-- Your header content -->
    </header>
```

---

## `{$footeroutput}` — Footer Region Output

**CRITICAL:** This MUST be included before `</body>`. Without it, the client area will not function correctly.

**Where:** Right before `</body>` in `footer.tpl`

**What it contains:**
- jQuery (injected if not already present)
- jQuery UI
- Bootstrap JS
- WHMCS JavaScript API (`WHMCS.http`, `WHMCS.payment`, `WHMCS.utils`)
- CSRF token JavaScript setup
- Language string globals (`langPasswordStrength`, etc.)
- DataTables library (if used on page)
- Module/addon footer JS
- Analytics tracking code (Google Analytics, Facebook Pixel, etc.)
- Hook output from `ClientAreaFooterOutput` hook

**Usage:**

```smarty
    {* End of your content *}

    {$footeroutput}  {* CRITICAL - client area breaks without this *}
</body>
</html>
```

**What you should NOT duplicate:**
- jQuery initialization
- WHMCS core JavaScript
- CSRF token setup
- Analytics tracking

**What you CAN add after `{$footeroutput}`:**
- Theme-specific JavaScript that depends on WHMCS globals
- Chat widgets (Intercom, Drift, etc.) — though better to use hooks

---

## `{$moduleclientarea}` — Service Module Output

**Where:** Used in `clientareaproductdetails.tpl`

**What it contains:**

Server module-specific HTML for managing the client's service. Examples:
- **cPanel**: Login button, disk/bandwidth stats, account info
- **Plesk**: Dashboard link, usage stats
- **DirectAdmin**: Login, stats
- **VirtualMin**: Panel links
- **Custom modules**: Module's `ClientArea()` function output

**Raw HTML structure varies by module** — typically contains:
- Buttons (Single Sign-On, Control Panel)
- Resource usage displays
- Status indicators
- Module-specific forms

**Usage:**

```smarty
<div class="module-output">
    {$moduleclientarea}
</div>
```

**Important notes:**
- Output includes its own `<script>` tags
- May include module-specific CSS classes
- Can contain forms that POST to module endpoints
- Use minimal wrapper styling to avoid layout issues

---

## `{$registrarclientarea}` — Registrar Module Output

**Where:** Used in `clientareadomaindetails.tpl`

**What it contains:**

Registrar-specific HTML for domain management. Varies by registrar:
- **Enom**: Nameserver management, contact info links
- **ResellerClub**: Panel access, DNS management
- **Namecheap**: Management buttons, transfer status
- **Custom registrar modules**: Registrar's `ClientArea()` function output

**Usage:**

```smarty
<div class="registrar-output">
    {$registrarclientarea}
</div>
```

**Related variables:**
- `{$registrarcustombuttonresult}` - Result of custom button action (success/error messages)
- `{$registrarclientarea}` only rendered when registrar provides client-area function

---

## `{$hookOutput}` — Hook Output Array

**Where:** Various pages

**What it is:** Associative array where keys are hook names, values are HTML strings returned by hooks.

**Usage pattern:**

```smarty
{* Iterate all hook outputs *}
{foreach $hookOutput as $hookName => $html}
    {$html}
{/foreach}

{* Or specific hook *}
{if isset($hookOutput.ClientAreaHomepage)}
    {$hookOutput.ClientAreaHomepage}
{/if}
```

**Use cases:**
- Custom dashboards adding widgets via hooks
- Third-party module output injection
- Conditional display of hook-generated content

---

## `{$addons_html}` — Addon HTML Output

**Where:** Used in `clientareahome.tpl` and various client area pages

**What it is:** Array of HTML strings from addon modules that hook into the client area.

**Usage:**

```smarty
{foreach $addons_html as $addon_html}
    <div class="addon-output">
        {$addon_html}
    </div>
{/foreach}
```

**Common addons that output here:**
- Support billing addons
- Automation tools
- Analytics dashboards
- Custom client-area addons

---

## `{$modulecustombuttonresult}` — Custom Button Result

**Where:** `clientareaproductdetails.tpl`

**What it is:** Result message from clicking a custom module button (e.g., "Restart Service", "Change Password").

**Typical values:**
- `"success"` — Button action succeeded
- `"error"` — Button action failed
- Custom message strings from module

**Usage:**

```smarty
{if $modulecustombuttonresult == "success"}
    {include file="$template/includes/alert.tpl" 
             type="success" 
             msg="{lang key='moduleActionSuccess'}"}
{elseif $modulecustombuttonresult}
    {include file="$template/includes/alert.tpl" 
             type="error" 
             msg=$modulecustombuttonresult}
{/if}
```

---

## `{$registrarcustombuttonresult}` — Registrar Custom Button Result

**Where:** `clientareadomaindetails.tpl`

**What it is:** Similar to `$modulecustombuttonresult` but for registrar module buttons.

**Usage:**

```smarty
{if $registrarcustombuttonresult == "success"}
    {include file="$template/includes/alert.tpl" 
             type="success" 
             msg="{lang key='changessavedsuccessfully'}"}
{elseif $registrarcustombuttonresult}
    {include file="$template/includes/alert.tpl" 
             type="error" 
             msg=$registrarcustombuttonresult}
{/if}
```

---

## `{$modulechangepwresult}` / `{$modulechangepasswordmessage}` — Password Change Result

**Where:** `clientareaproductdetails.tpl`

**What they contain:**
- `{$modulechangepwresult}` — Result code of password change attempt
- `{$modulechangepasswordmessage}` — Human-readable message

**Usage:**

```smarty
{if $modulechangepwresult == "success"}
    {include file="$template/includes/alert.tpl" 
             type="success" 
             msg="{lang key='clientareachangepasswordsuccessful'}"}
{elseif $modulechangepwresult}
    {include file="$template/includes/alert.tpl" 
             type="error" 
             msg=$modulechangepasswordmessage}
{/if}
```

---

## Asset Loading Variables

### `{$BASE_PATH_CSS}`, `{$BASE_PATH_JS}`, `{$BASE_PATH_IMG}`, `{$BASE_PATH_FONTS}`

Points to shared WHMCS asset directories (not theme-specific):

```smarty
<link href="{$BASE_PATH_CSS}/shared.css" rel="stylesheet">
<script src="{$BASE_PATH_JS}/StatesDropdown.js"></script>
<img src="{$BASE_PATH_IMG}/logo.png">
```

Typical paths:
- `{$BASE_PATH_CSS}` → `/assets/css/`
- `{$BASE_PATH_JS}` → `/assets/js/`
- `{$BASE_PATH_IMG}` → `/assets/img/`
- `{$BASE_PATH_FONTS}` → `/assets/fonts/`

### `{$WEB_ROOT}`

Base URL of WHMCS installation. Use for:
- Cross-page links: `{$WEB_ROOT}/clientarea.php`
- Direct asset references: `{$WEB_ROOT}/assets/img/logo.png`
- Form actions pointing to core scripts

### `{assetPath file='name'}`

Theme-specific asset. Resolves to your theme's assets directory:

```smarty
<link href="{assetPath file='theme.min.css'}" rel="stylesheet">
```

Benefits over direct paths:
- Child theme aware (falls back to parent)
- Version hashing support via `?v={$versionHash}`
- Resolves correct theme when previewing

---

## CSRF Token Variables

### `{$token}`

CSRF token for POST forms. **Every POST form needs this**:

```smarty
<form method="post" action="...">
    <input type="hidden" name="token" value="{$token}" />
    <!-- form fields -->
</form>
```

Also available in JavaScript (set by `head.tpl`):

```javascript
// In scripts.js or custom JS
var csrfToken = '{$token}';

// For AJAX
fetch(url, {
    method: 'POST',
    headers: { 'X-CSRF-Token': csrfToken },
    body: formData
});
```

---

## What Gets Auto-Injected

Understanding what WHMCS adds automatically helps you avoid duplication:

### Via `{$headoutput}`

- [x] reCAPTCHA script (`<script src="https://www.google.com/recaptcha/api.js">`)
- [x] System-wide meta tags
- [x] Module CSS
- [x] Hook output from `ClientAreaHeadOutput`

### Via `{$footeroutput}`

- [x] jQuery 1.12.4 (if not already loaded)
- [x] jQuery UI
- [x] Bootstrap 4 JavaScript
- [x] `WHMCS.http`, `WHMCS.payment`, `WHMCS.utils` objects
- [x] CSRF token JavaScript setup
- [x] Hook output from `ClientAreaFooterOutput`
- [x] Analytics/tracking (if configured)

### Via `{$captcha->getPageJs()}` (in head.tpl)

- [x] reCAPTCHA callback functions
- [x] CAPTCHA-specific initialization

---

## Debugging System Output

To see what's being injected at each point:

```smarty
{* Temporarily add to your template to inspect *}
<pre>
HEAD OUTPUT:
{$headoutput|escape}

FOOTER OUTPUT:
{$footeroutput|escape}
</pre>
```

**⚠️ Remove before production — exposes internal paths and tokens.**

Alternative:
- View page source in browser — compare with custom vs. default theme
- Check `/includes/classes/` for PHP that generates these variables

---

## Customization via Hooks (Recommended)

Instead of trying to modify `$headoutput` / `$footeroutput` directly, use hooks:

```php
// /includes/hooks/custom_head.php
add_hook('ClientAreaHeadOutput', 1, function($vars) {
    return '<link rel="icon" href="/custom-favicon.png">
            <meta name="theme-color" content="#2563eb">';
});

add_hook('ClientAreaFooterOutput', 1, function($vars) {
    return '<script>console.log("Custom footer script");</script>';
});
```

This ensures your additions work across all pages AND other themes.

---

## Common Mistakes

### ❌ Removing `{$footeroutput}`

```smarty
{* BAD - Breaks entire client area *}
<footer>
    <p>&copy; 2026</p>
</footer>
</body>
```

### ✅ Always include it

```smarty
<footer>
    <p>&copy; 2026</p>
</footer>
{$footeroutput}
</body>
```

### ❌ Duplicating jQuery

```smarty
<head>
    {$headoutput}
</head>
<body>
    <!-- content -->
    {* BAD - jQuery already loaded via footeroutput *}
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    {$footeroutput}
</body>
```

### ✅ Rely on WHMCS's jQuery

```smarty
<body>
    <!-- content -->
    {$footeroutput}  {* jQuery 1.12.4 injected here *}
    <script>
        // Your code using $ / jQuery
    </script>
</body>
```

### ❌ Loading reCAPTCHA manually

```smarty
{* BAD - Already loaded if CAPTCHA enabled *}
<script src="https://www.google.com/recaptcha/api.js"></script>
```

### ✅ Use the captcha object

```smarty
{if $captcha->isEnabled()}
    {include file="$template/includes/captcha.tpl"}
{/if}
{* API script auto-loaded via $headoutput *}
```
