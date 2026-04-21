# Template Fallback & Resolution

How WHMCS resolves template file lookups, including child theme inheritance. This is critical to understand when creating child themes or debugging "why isn't my template working?" issues.

## The Basic Rule

When WHMCS looks for a template file:

1. **First:** Check the active theme (child theme directory)
2. **Fallback:** Check the parent theme (if `config.parent` is set in theme.yaml)
3. **Final fallback:** System default templates
4. **Error:** Template not found — may throw error or render empty

## Resolution Order

Given this setup:
- Active theme: `mytheme`
- Parent in theme.yaml: `nexus`

When template requests `clientareahome.tpl`:

```
1. templates/mytheme/clientareahome.tpl       (exists? → use it)
      ↓ not found
2. templates/nexus/clientareahome.tpl          (exists? → use it)
      ↓ not found
3. Error / empty output
```

## Full Example

Let's say your child theme `mytheme` has:

```
templates/mytheme/
├── theme.yaml              (parent: nexus)
├── css/custom.css
├── header.tpl              ← You customized this
├── homepage.tpl            ← You customized this
└── includes/
    └── navbar.tpl          ← You customized this
```

When rendering different pages:

| Template Requested | Resolved From |
|---------------------|---------------|
| `header.tpl` | `mytheme/header.tpl` (your version) |
| `footer.tpl` | `nexus/footer.tpl` (inherited) |
| `homepage.tpl` | `mytheme/homepage.tpl` (your version) |
| `clientareahome.tpl` | `nexus/clientareahome.tpl` (inherited) |
| `includes/navbar.tpl` | `mytheme/includes/navbar.tpl` (your version) |
| `includes/alert.tpl` | `nexus/includes/alert.tpl` (inherited) |
| `store/order.tpl` | `nexus/store/order.tpl` (inherited) |
| Any error template | `nexus/error/*.tpl` (inherited) |

## How Include Paths Work

Within templates, the `{$template}` variable points to the ACTIVE theme name. So:

```smarty
{include file="$template/includes/alert.tpl"}
```

Resolves to:
- First: `templates/mytheme/includes/alert.tpl` (if exists)
- Fallback: `templates/nexus/includes/alert.tpl`

The path `$template/...` triggers the fallback mechanism automatically.

### Explicit parent reference (rare)

If you want to force using the parent:

```smarty
{include file="nexus/includes/alert.tpl"}
```

This skips the child theme entirely. Rarely needed.

---

## Asset Resolution

Similar cascade for assets loaded via `{assetPath}`:

```smarty
<link href="{assetPath file='custom.css'}" rel="stylesheet">
```

Resolves to:
1. `templates/mytheme/css/custom.css` (if exists)
2. `templates/nexus/css/custom.css`

The `{assetExists}` function checks if the file exists in either:

```smarty
{assetExists file="custom.css"}
    <link href="{$__assetPath__}" rel="stylesheet">
{/assetExists}
```

---

## What Happens When Templates Are Missing

### Scenario 1: Template missing from both child and parent

```smarty
{include file="$template/my-custom-widget.tpl"}
```

If `my-custom-widget.tpl` doesn't exist in `mytheme/` OR `nexus/`:

- **Development mode:** Smarty throws an error
- **Production:** Usually silent failure (empty output)
- **Log:** Error may appear in `templates_c/` cache errors

### Scenario 2: Template exists but is empty

The page renders with the empty template content. Useful for "disabling" a feature without removing it.

### Scenario 3: Child template references non-existent parent

```smarty
{* In mytheme/mycustom.tpl *}
{include file="$template/does-not-exist.tpl"}
```

Smarty error.

---

## SCSS Compilation & Child Themes

**Important:** If your child theme has its own SCSS, it must compile to:

```
templates/mytheme/css/theme.min.css
```

The base `head.tpl` loads `{assetPath file='theme.min.css'}` — if your child theme doesn't have one, it uses the parent's.

**Recommendation:** Don't duplicate theme.min.css. Instead:

1. Let parent's `theme.min.css` load first
2. Override via your `custom.css`

```smarty
{* head.tpl load order *}
<link href="{assetPath file='all.min.css'}">      {* Parent *}
<link href="{assetPath file='theme.min.css'}">    {* Parent (or child if overridden) *}
{assetExists file="custom.css"}
    <link href="{$__assetPath__}">                {* Child's custom.css *}
{/assetExists}
```

---

## Preview Mode & Development

### Preview a theme without activating

Add `?systpl=themename` to any WHMCS URL:

```
https://example.com/whmcs/?systpl=mytheme
https://example.com/whmcs/clientarea.php?systpl=mytheme
```

### Preview a cart theme

```
https://example.com/whmcs/cart.php?carttpl=mycart
```

### WHMCS validates dependencies

When previewing, WHMCS checks:
- `theme.yaml` exists and is valid
- Parent theme (if specified) exists
- Required dependencies are met
- Provided assets match dependent themes' needs

### Testing multiple themes

You can have many themes in `/templates/` simultaneously:

```
templates/
├── nexus/               (default)
├── twenty-one/          (old default)
├── mytheme-v1/
├── mytheme-v2/
└── mytheme-staging/
```

Switch between them via URL parameter during development.

---

## Template Caching

WHMCS compiles Smarty templates to PHP and caches them in:

```
templates_c/
├── [cache files]
```

### When templates don't update

If your edits aren't showing:

1. **Clear the cache:** Delete contents of `templates_c/`
2. **Admin → Utilities → System → Clear Template Cache**
3. **Disable caching during development** (see Smarty config)

### Cache implications for child themes

- Each theme is cached separately
- Switching themes: old theme's compiled cache stays until cleared
- Editing a template: cache invalidates automatically on next request

---

## Common Patterns

### Pattern 1: Override only what you need

```
templates/mytheme/
├── theme.yaml                  (parent: nexus)
└── homepage.tpl                (only customize homepage)
```

Everything else inherits.

### Pattern 2: Custom header/footer, everything else inherited

```
templates/mytheme/
├── theme.yaml
├── header.tpl
├── footer.tpl
└── css/custom.css
```

Provides full control over branding while inheriting all page logic.

### Pattern 3: Custom includes

```
templates/mytheme/
├── theme.yaml
└── includes/
    └── navbar.tpl              (custom navbar rendering)
```

Every template that uses `{include file="$template/includes/navbar.tpl"}` automatically uses your version.

### Pattern 4: Customize specific pages

```
templates/mytheme/
├── theme.yaml
├── clientareahome.tpl          (custom dashboard)
├── clientareaproducts.tpl      (custom services list)
└── clientareadomains.tpl       (custom domains list)
```

---

## Debugging Template Resolution

### Enable Smarty debug output

Add `{debug}` to any template:

```smarty
{* Your template *}
{debug}

{* Shows popup with all variables and paths *}
```

### Check which template rendered

Temporarily add a marker:

```smarty
{* Add at top of your custom template *}
<!-- Rendering from: mytheme/homepage.tpl -->
```

View page source in browser to see which version loaded.

### Inspect include resolution

```smarty
<pre>Template path: {$template}</pre>
<!-- Should output: mytheme -->
```

### Verify theme.yaml is correct

Missing or malformed `theme.yaml`:
- Theme won't appear in admin
- Preview with `?systpl=` returns 404
- Parent inheritance breaks

Common YAML mistakes:

```yaml
# ❌ Tab indentation (must be spaces)
config:
	parent: nexus

# ✅ Space indentation
config:
  parent: nexus

# ❌ Missing quote for value with colon
name: My Theme: Custom Edition

# ✅ Quoted
name: "My Theme: Custom Edition"
```

---

## Parent Theme Versioning

```yaml
# theme.yaml
name: "My Theme"
config:
  parent: nexus
dependencies:
  bootstrap: 4.5
  fontawesome: 5
```

**How version matching works:**

- `bootstrap: 4.5` matches `4.5.0`, `4.5.1`, `4.5.2`, `4.5.99`
- `bootstrap: 4` matches any `4.x.x`
- Missing version = assumed compatible
- Exact match: `bootstrap: 4.5.3`

**Parent provides assets via:**

```yaml
# nexus/theme.yaml
provides:
  bootstrap: 4.5.3
  jquery: 1.12.4
  fontawesome: 5.10.1
```

When your child declares dependencies, WHMCS checks the parent provides them.

---

## Grandparent Inheritance (Rare)

WHMCS only supports **one level** of inheritance:

```
✅ mytheme → nexus
✅ mytheme → twenty-one

❌ mytheme → mytheme-base → nexus
```

If you need shared customizations between themes, use hooks instead.

---

## Troubleshooting

### "Theme not showing in admin"

- Check `theme.yaml` exists in theme directory
- Validate YAML syntax
- Check directory name (only lowercase, numbers, hyphens, underscores)
- Clear template cache

### "My custom header.tpl isn't showing"

- Clear template cache (`templates_c/`)
- Verify file is in correct directory
- Check `{$template}` resolves to your theme name
- Verify parent theme (nexus) still exists and is healthy

### "Parent features broken when using child theme"

- Your child theme may be overriding a critical file
- Only customize files you actually modified
- Check that overridden file has required elements (e.g., `{$headoutput}`)

### "Child theme CSS not loading"

- Verify `custom.css` exists in `templates/mytheme/css/`
- Use `{assetExists}` check in `head.tpl`
- Clear browser cache (CSS may be cached with old version hash)

### "Preview works but activation breaks"

- Different admin/client URL bases
- Cache still serving old theme
- Dependencies not provided (check `theme.yaml`)

---

## Best Practices

### ✅ DO

- Use child themes for customization
- Only override files you actually changed
- Keep `theme.yaml` simple
- Test with `?systpl=themename` before activating
- Clear cache after structural changes
- Use `{assetExists}` for optional assets
- Rely on parent's `{$headoutput}` and `{$footeroutput}`

### ❌ DON'T

- Copy the entire parent theme
- Modify files in `templates/nexus/` directly
- Change `theme.yaml` to rename an existing theme (breaks references)
- Use tabs in YAML (only spaces)
- Skip `{$footeroutput}` in overridden `footer.tpl`
- Create grandparent inheritance chains
- Put language files in your theme directory

---

## Summary Diagram

```
Request: /clientarea.php
         ↓
WHMCS determines active theme: mytheme
         ↓
Read mytheme/theme.yaml → parent: nexus
         ↓
Need template: clientareahome.tpl
         ↓
    ┌──────────────────────────────┐
    │ Check mytheme/clientareahome.tpl  │
    └──────────────────────────────┘
         ↓ not found
    ┌──────────────────────────────┐
    │ Check nexus/clientareahome.tpl    │
    └──────────────────────────────┘
         ↓ found!
    Use nexus/clientareahome.tpl
         ↓
Smarty compiles to templates_c/
         ↓
Renders page with data
         ↓
    Page content rendered between
    mytheme/header.tpl (or nexus/header.tpl)
    and
    mytheme/footer.tpl (or nexus/footer.tpl)
```

---

## Next Steps

- [Minimum Theme](/starter/minimum-theme.md) — Quick-start guide
- [Skeleton Files](/starter/skeleton-files.md) — Full directory structure
- [Header Template](/starter/header-template.md) — Complete walkthrough
- [Footer Template](/starter/footer-template.md) — Complete walkthrough
