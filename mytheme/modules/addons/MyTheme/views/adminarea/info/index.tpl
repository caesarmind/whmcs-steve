{include file="includes/header.tpl"}

<header class="mt-page-header">
    <div class="mt-page-eyebrow">Theme</div>
    <h1 class="mt-page-title">Info</h1>
    <p class="mt-page-subtitle">Version and license information for this theme.</p>
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
        <h2 class="mt-section-title">License</h2>
    </header>
    <dl class="mt-deflist">
        <dt>Status</dt>
        <dd>
            {if $license.status == 'Active'}<span class="mt-badge mt-badge-success">Active</span>
            {elseif $license.status == 'No key'}<span class="mt-badge mt-badge-neutral">No key set</span>
            {elseif $license.status == 'Hook not installed'}<span class="mt-badge mt-badge-warning">Hook not installed</span>
            {else}<span class="mt-badge mt-badge-danger">{$license.status|escape}</span>{/if}
        </dd>

        <dt>License Key</dt>
        <dd>{if $license.key}<code>{$license.key|escape}</code>{else}<span class="mt-text-3">Not set</span>{/if}</dd>

        {if $license.data.productname}<dt>Product</dt>
        <dd>{$license.data.productname|escape}</dd>{/if}

        {if $license.data.regdate}<dt>Registration Date</dt>
        <dd>{$license.data.regdate|escape}</dd>{/if}

        {if $license.data.nextduedate}<dt>Next Due Date</dt>
        <dd>{$license.data.nextduedate|escape}</dd>{/if}

        {if $license.data.billingcycle}<dt>Billing Cycle</dt>
        <dd>{$license.data.billingcycle|escape}</dd>{/if}

        {if $license.data.validdomain}<dt>Valid Domain(s)</dt>
        <dd>{$license.data.validdomain|escape}</dd>{/if}
    </dl>

    <div style="margin-top:16px">
        <a href="{$viewHelper->url('license')}" class="mt-btn mt-btn-primary mt-btn-sm" style="color:#fff">Manage license key</a>
    </div>
    <p class="mt-card-meta" style="margin-top:10px">
        Handled by the Licensing Manager (<code>modules/servers/licensing</code> + the <code>hostnodes_theme_license</code> hook).
    </p>
</section>

{include file="includes/footer.tpl"}
