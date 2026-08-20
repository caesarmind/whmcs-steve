{include file="includes/header.tpl"}

<header class="mt-page-header">
    <div class="mt-page-eyebrow">Theme</div>
    <h1 class="mt-page-title">Info {include file="includes/doclink.tpl" article="introduction"}</h1>
    <p class="mt-page-subtitle">Version and license information for this theme.</p>
</header>

<div class="mt-panel">
<section class="mt-section">
    <header class="mt-section-header">
        <h2 class="mt-section-title">Theme Information</h2>
        {include file="includes/doclink.tpl" article="introduction" anchor="requirements"}
    </header>
    <dl class="mt-deflist">
        <dt>Theme Version</dt>
        <dd>{$info.version|escape}{if $info.newVersion} <span class="mt-badge mt-badge-primary">New version available</span>{/if}</dd>
    </dl>
</section>

<section class="mt-section">
    <header class="mt-section-header">
        <h2 class="mt-section-title">License</h2>
        {include file="includes/doclink.tpl" article="licensing" anchor="what-each-status-means"}
    </header>
    <dl class="mt-deflist">
        <dt>Status</dt>
        <dd>
            {if $license.active}<span class="mt-badge mt-badge-success">Active</span>
            {elseif $license.status == 'No key'}<span class="mt-badge mt-badge-neutral">No key set</span>
            {elseif $license.status == 'Suspended' || $license.status == 'Expired'}<span class="mt-badge mt-badge-warning">{$license.status|escape} &middot; theme running</span>
            {elseif $license.status == 'Banned' || $license.status == 'Cancelled' || $license.status == 'Revoked'}<span class="mt-badge mt-badge-danger">Revoked</span>
            {elseif $license.status == 'Unreachable' || $license.status == 'Unknown'}<span class="mt-badge mt-badge-warning">Unverified</span>
            {else}<span class="mt-badge mt-badge-danger">Not active</span>{/if}
        </dd>

        <dt>License Key</dt>
        <dd>{if $license.key}<code>{$license.key|escape}</code>{else}<span class="mt-text-3">Not set</span>{/if}</dd>

        <dt>Support &amp; Updates</dt>
        <dd>{if $license.active}<span class="mt-badge mt-badge-success">Entitled</span>{else}<span class="mt-badge mt-badge-warning">Paused &middot; renew to update</span>{/if}</dd>

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
</section>
</div>

{include file="includes/footer.tpl"}
