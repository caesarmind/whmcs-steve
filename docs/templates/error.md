# Error Templates

Located in `error/`, these templates display error pages:

| Template | Purpose | Key Variables |
|----------|---------|---------------|
| `error/page-not-found.tpl` | 404 Not Found | `{$systemurl}` |
| `error/internal-error.tpl` | 500 Internal Error | `{$systemurl}` |
| `error/rate-limit-exceeded.tpl` | Rate Limiting | |
| `error/unknown-routepath.tpl` | Unknown Route | |

### Error Page Pattern

```smarty
<div class="container">
    <div class="text-center p-5">
        <i class="fas fa-exclamation-circle display-1 text-primary"></i>
        <h1 class="display-1 font-weight-bold text-primary">{lang key="errorPage.404.title"}</h1>
        <h3>{lang key="errorPage.404.subtitle"}</h3>
        <p>{lang key="errorPage.404.description"}</p>
        <a href="{$systemurl}" class="btn btn-primary">{lang key="errorPage.404.home"}</a>
        <a href="{$systemurl}contact.php" class="btn btn-info">{lang key="errorPage.404.submitTicket"}</a>
    </div>
</div>
```

### `error/internal-error.tpl` - Non-Smarty Template

This template uses **double-curly-brace placeholders** instead of Smarty:

```html
<!-- NOT Smarty syntax - PHP string replacement -->
<a href="mailto:{{email}}">{{email}}</a>
<a href="{{systemurl}}">{{systemurl}}</a>
{{environmentIssues}}
{{adminHelp}}
{{stacktrace}}
```

**Important:** If creating custom error pages, the internal error template does NOT use the Smarty engine because it displays when the system itself has failed.

### `error/unknown-routepath.tpl`

This template includes the 404 page and adds referrer info:

```smarty
{include file="$template/error/page-not-found.tpl"}
{* Also uses: $referrer|escape *}
```
