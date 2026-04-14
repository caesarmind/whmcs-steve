# OAuth Templates

### OAuth Layout

The OAuth flow uses a separate layout (`oauth/layout.tpl`) that doesn't use the main header/footer:

```smarty
<!DOCTYPE html>
<html lang="en">
<head>
    <link href="{assetPath file='all.min.css'}" rel="stylesheet">
    <link href="{assetPath file='theme.min.css'}" rel="stylesheet">
    <link href="{assetPath file='oauth.css'}" rel="stylesheet">
</head>
<body>
    <section id="header">
        <img src="{$logo}" />
        {* Login/logout controls *}
    </section>
    <section id="content">
        {$content}  {* OAuth page content injected here *}
    </section>
    <section id="footer">
        {lang key='oauth.copyrightFooter' dateYear=$date_year companyName=$companyname}
    </section>
</body>
</html>
```

### OAuth Templates

| Template | Purpose | Key Variables |
|----------|---------|---------------|
| `oauth/login.tpl` | OAuth login form | `$username`, `$errors` |
| `oauth/login-twofactorauth.tpl` | 2FA during OAuth | `$errors` |
| `oauth/authorize.tpl` | App authorization prompt | `$appName`, `$scopes`, `$request_hash` |
| `oauth/error.tpl` | OAuth error display | `$error`, `$errorDescription` |

### OAuth Template Variables

### `oauth/login.tpl`

| Variable | Type | Description |
|----------|------|-------------|
| `{$appLogo}` | string | Application logo URL |
| `{$appName}` | string | Application name |
| `{$issuerurl}` | string | OAuth issuer URL |
| `{$incorrect}` | boolean | Login credentials incorrect |
| `{$request_hash}` | string | OAuth request hash |

### `oauth/login-twofactorauth.tpl`

| Variable | Type | Description |
|----------|------|-------------|
| `{$challenge}` | string | 2FA challenge HTML |
| `{$backupcode}` | boolean | Using backup code |
| `{$incorrect}` | boolean | Code was incorrect |
| `{$error}` | string | Error message |
| `{$request_hash}` | string | OAuth request hash |

### `oauth/authorize.tpl`

| Variable | Type | Description |
|----------|------|-------------|
| `{$appLogo}` | string | Application logo URL |
| `{$appName}` | string | Application name |
| `{$requestedPermissions}` | array | Permissions list |
| `{$requestedAuthorizations}` | array | Authorization scopes |
| `{$request_hash}` | string | OAuth request hash |

### `oauth/error.tpl`

| Variable | Type | Description |
|----------|------|-------------|
| `{$error}` | string | Error message text |
