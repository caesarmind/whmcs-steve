{include file="includes/header.tpl"}

<header class="mt-page-header">
    <div class="mt-page-eyebrow">Theme</div>
    <h1 class="mt-page-title">License</h1>
    <p class="mt-page-subtitle">Enter your Hadrian theme license key for this site.</p>
</header>

{* Live status — checked against the Licensing Manager right now *}
{if $active}
    <div class="mt-alert mt-alert-success"><strong>License active.</strong> This theme is licensed for this domain.</div>
{elseif $status == 'No key'}
    <div class="mt-alert mt-alert-warning"><strong>No license key.</strong> Enter your key below to activate the theme.</div>
{elseif $status == 'Suspended' || $status == 'Expired'}
    <div class="mt-alert mt-alert-warning"><strong>License {$status|escape}.</strong> The theme keeps working, but you won&rsquo;t receive theme updates until you renew.</div>
{elseif $status == 'Banned' || $status == 'Cancelled' || $status == 'Revoked'}
    <div class="mt-alert mt-alert-danger"><strong>License revoked.</strong> This license has been revoked for this site; the client area reverts to the default theme.</div>
{elseif $status == 'Unreachable' || $status == 'Unknown'}
    <div class="mt-alert mt-alert-warning"><strong>Could not verify right now.</strong> The license server was unreachable; the theme keeps working during the grace period. Try again shortly.</div>
{else}
    <div class="mt-alert mt-alert-danger"><strong>Not active.</strong> This license key is not valid for this domain.</div>
{/if}

{* Enforcement — what the front-end hook last decided to do *}
<div class="mt-panel" style="max-width:560px;">
<section class="mt-section">
    <header class="mt-section-header">
        <h2 class="mt-section-title">Enforcement</h2>
    </header>
    <dl class="mt-deflist">
        <dt>Mode</dt>
        <dd>
            {if $enforce === true}<span class="mt-badge mt-badge-success">Enforcing</span>
            {elseif $enforce === false}<span class="mt-badge mt-badge-warning">Dry-run (not enforcing)</span>
            {else}<span class="mt-badge mt-badge-neutral">Hook not detected yet</span>{/if}
        </dd>

        <dt>Current decision</dt>
        <dd>
            {if $decLevel == 'success'}<span class="mt-badge mt-badge-success">OK</span>
            {elseif $decLevel == 'danger'}<span class="mt-badge mt-badge-danger">Reverted</span>
            {elseif $decLevel == 'warning'}<span class="mt-badge mt-badge-warning">Attention</span>
            {else}<span class="mt-badge mt-badge-neutral">&mdash;</span>{/if}
            <div class="mt-field-help">{$decText|escape}</div>
        </dd>

        {if $reverted}
        <dt>Active template</dt>
        <dd><span class="mt-badge mt-badge-danger">Default (six)</span> <span class="mt-text-3">the theme is currently reverted</span></dd>
        {/if}
    </dl>
</section>

{* Key entry *}
<section class="mt-section">
    <header class="mt-section-header">
        <h2 class="mt-section-title">License key</h2>
    </header>
    <form method="post" action="" class="mt-section-body">
        <div class="mt-field">
            <label class="mt-field-label" for="mt-license-key">Key</label>
            <input id="mt-license-key" class="mt-input" type="text" name="license_key"
                   value="{$key|escape}" placeholder="hadrian-XXXXX-XXXXX-XXXXX">
            <div class="mt-field-help">The key from your order.</div>
        </div>
        <div class="mt-form-actions">
            <button type="submit" class="mt-btn mt-btn-primary">Save &amp; check</button>
        </div>
    </form>
</section>
</div>

{include file="includes/footer.tpl"}
