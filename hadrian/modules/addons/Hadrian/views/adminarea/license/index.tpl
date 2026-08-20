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

<div class="mt-panel" style="max-width:560px;">
{* Key entry *}
<section class="mt-section">
    <header class="mt-section-header">
        <h2 class="mt-section-title">License key</h2>
        {include file="includes/doclink.tpl" article="licensing" anchor="where-the-key-goes"}
    </header>
    <form method="post" action="" class="mt-section-body">
        <div class="mt-field">
            <label class="mt-field-label" for="mt-license-key">Key</label>
            <input id="mt-license-key" class="mt-input" type="text" name="license_key"
                   value="{$key|escape}" placeholder="hadrian-XXXXX-XXXXX-XXXXX">
            <div class="mt-field-help">The key from your order.</div>
        </div>
        {include file="includes/savebar.tpl" label="Save & check"}
    </form>
</section>
</div>

{include file="includes/footer.tpl"}
