{include file="includes/header.tpl"}

<header class="mt-page-header">
    <div class="mt-page-eyebrow">Theme</div>
    <h1 class="mt-page-title">License</h1>
    <p class="mt-page-subtitle">Enter this site's Hadrian theme license key. Validation is handled by the Licensing Manager.</p>
</header>

{if !$hookPresent}
    <div class="mt-alert mt-alert-danger"><strong>License hook not installed.</strong> {$detail|escape}</div>
{elseif $status == 'Active'}
    <div class="mt-alert mt-alert-success"><strong>License active.</strong> {$detail|escape}</div>
{else}
    <div class="mt-alert mt-alert-warning"><strong>{$status|escape}.</strong> {$detail|escape}</div>
{/if}

<section class="mt-section" style="max-width:560px">
    <header class="mt-section-header">
        <h2 class="mt-section-title">License key</h2>
    </header>
    <form method="post" action="" class="mt-section-body">
        <div class="mt-field">
            <label class="mt-field-label" for="mt-license-key">Key</label>
            <input id="mt-license-key" class="mt-input" type="text" name="license_key"
                   value="{$key|escape}" placeholder="hadrian-XXXXX-XXXXX-XXXXX">
            <div class="mt-field-help">The key issued for this domain (from your order / service Domain field).</div>
        </div>
        <div class="mt-form-actions">
            <button type="submit" class="mt-btn mt-btn-primary">Save &amp; check</button>
        </div>
    </form>
</section>

{include file="includes/footer.tpl"}
