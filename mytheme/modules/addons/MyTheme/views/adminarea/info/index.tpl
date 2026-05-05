{include file="includes/header.tpl"}

<header class="mt-page-header">
    <div class="mt-page-eyebrow">Theme</div>
    <h1 class="mt-page-title">Info</h1>
    <p class="mt-page-subtitle">Version, license, and subscription information for this theme.</p>
</header>

{if $info.devMode}
    <div class="mt-alert mt-alert-warning">
        <strong>Development mode is active.</strong>
        License checks are bypassed. To enable real license validation, edit
        <code>templates/mytheme/core/mytheme.php</code> and set <code>'dev_mode' =&gt; false</code>.
    </div>
{/if}

<section class="mt-section">
    <header class="mt-section-header">
        <h2 class="mt-section-title">Theme Information</h2>
    </header>
    <dl class="mt-deflist">
        <dt>Theme Version</dt>
        <dd>{$info.version|escape}{if $info.newVersion} <span class="mt-badge mt-badge-primary">New version available</span>{/if}</dd>

        <dt>Registration Date</dt>
        <dd>{if $info.registrationDate}{$info.registrationDate|escape}{else}<span class="mt-badge mt-badge-neutral">—</span>{/if}</dd>

        <dt>Next Due Date</dt>
        <dd>{if $info.nextDueDate}{$info.nextDueDate|escape}{else}<span class="mt-badge mt-badge-neutral">—</span>{/if}</dd>

        <dt>First Payment Amount</dt>
        <dd>{if $info.firstPaymentAmount}{$info.firstPaymentAmount|escape}{else}<span class="mt-badge mt-badge-neutral">—</span>{/if}</dd>

        <dt>Recurring Amount</dt>
        <dd>{if $info.recurringAmount}{$info.recurringAmount|escape}{else}<span class="mt-badge mt-badge-neutral">—</span>{/if}</dd>

        <dt>Payment Method</dt>
        <dd>{if $info.paymentMethod}{$info.paymentMethod|escape}{else}<span class="mt-badge mt-badge-neutral">—</span>{/if}</dd>

        <dt>Support &amp; Updates</dt>
        <dd>{if $info.supportExpired}<span class="mt-badge mt-badge-warning">Expired</span>{else}<span class="mt-badge mt-badge-success">Active</span>{/if}</dd>

        <dt>License Key</dt>
        <dd>
            {if $info.licenseKey}<code>{$info.licenseKey|escape}</code>{else}<span class="mt-text-3">Not set</span>{/if}
            <a href="{$viewHelper->url('license')}" class="mt-btn mt-btn-ghost mt-btn-sm">{if $info.licenseKey}Change{else}Set key{/if}</a>
        </dd>

        <dt>License Status</dt>
        <dd>
            {if $info.devMode}
                <span class="mt-badge mt-badge-warning">Dev mode</span>
            {elseif $info.licenseStatus == 'Active'}
                <span class="mt-badge mt-badge-success">Active</span>
            {else}
                <span class="mt-badge mt-badge-danger">{$info.licenseStatus|escape}</span>
            {/if}
        </dd>
    </dl>
</section>

{include file="includes/footer.tpl"}
