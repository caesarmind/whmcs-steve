{include file="includes/header.tpl"}

<header class="mt-page-header">
    <div class="mt-page-eyebrow">Theme</div>
    <h1 class="mt-page-title">Info</h1>
    <p class="mt-page-subtitle">Version information for this theme.</p>
</header>

<section class="mt-section">
    <header class="mt-section-header">
        <h2 class="mt-section-title">Theme Information</h2>
    </header>
    <dl class="mt-deflist">
        <dt>Theme Version</dt>
        <dd>{$info.version|escape}{if $info.newVersion} <span class="mt-badge mt-badge-primary">New version available</span>{/if}</dd>
    </dl>
</section>

<section class="mt-section">
    <header class="mt-section-header">
        <h2 class="mt-section-title">Licensing</h2>
    </header>
    <p class="mt-page-subtitle" style="margin-bottom:12px">
        Licensing is handled by the <strong>Licensing Manager</strong>
        (<code>modules/servers/licensing</code> + the <code>hostnodes_theme_license</code> hook).
        Set this site's license key here:
    </p>
    <a href="{$viewHelper->url('license')}" class="mt-btn mt-btn-primary mt-btn-sm">Manage license key</a>
</section>

{include file="includes/footer.tpl"}
