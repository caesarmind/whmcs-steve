{* =========================================================================
   oauth/layout.tpl — minimal shell for OAuth flow pages (login, authorize,
   consent, error). Independent of header.tpl/footer.tpl.
   ========================================================================= *}
<!doctype html>
<html lang="{$activeLocale.language|default:'en'}" data-theme="light">
<head>
    <meta charset="{$charset}">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>{$pagetitle} - {$companyname}</title>
    <link href="{assetPath file='theme.min.css'}?v={$versionHash}" rel="stylesheet">
    <link href="{$WEB_ROOT}/assets/fonts/css/fontawesome.min.css" rel="stylesheet">
    <link href="{$WEB_ROOT}/assets/fonts/css/fontawesome-solid.min.css" rel="stylesheet">
    <link href="{$WEB_ROOT}/assets/fonts/css/fontawesome-regular.min.css" rel="stylesheet">
    {assetExists file="custom.css"}<link href="{$__assetPath__}" rel="stylesheet">{/assetExists}
    <script src="{assetPath file='scripts.min.js'}?v={$versionHash}"></script>
</head>
<body class="auth-layout oauth-layout">
    {if $captcha}{$captcha->getMarkup()}{/if}

    <nav class="homepage-nav">
        <div class="homepage-nav-inner">
            <a href="{$WEB_ROOT}" class="nav-logo">{if $assetLogoPath}<img src="{$assetLogoPath}" alt="{$companyname}">{else}<i class="fas fa-cube"></i>{/if}</a>
            <span class="nav-brand">{$companyname}</span>
        </div>
    </nav>

    <div class="auth-container">
        {$contents}
    </div>
</body>
</html>
