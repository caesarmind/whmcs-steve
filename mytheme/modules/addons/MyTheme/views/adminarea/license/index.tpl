{include file="includes/header.tpl"}

<header class="mt-page-header">
    <h1 class="mt-page-title">License</h1>
    <p class="mt-page-subtitle">
        License status for <strong>{$template|escape}</strong>.
    </p>
</header>

{if $devMode}
    <div class="mt-alert mt-alert-warning">
        <strong>Development mode is active.</strong>
        License checks are bypassed; the theme renders as if licensed. To enable real license validation:
        <ol>
            <li>Edit <code>templates/{$template|escape}/core/{$template|escape}.php</code></li>
            <li>Set <code>'dev_mode' =&gt; false</code></li>
            <li>Replace <code>secret_key</code> with 64 random hex characters</li>
            <li>In <code>modules/addons/MyTheme/src/Template/License.php</code>, replace
                <code>LICENSE_SERVER_PUBLIC_KEY</code> and <code>$licenseServerUrl</code></li>
        </ol>
    </div>
{elseif $isActive}
    <div class="mt-alert mt-alert-success">
        <strong>License is active.</strong>
        Theme is rendering normally.
    </div>
{else}
    <div class="mt-alert mt-alert-danger">
        <strong>License is not active.</strong>
        Enter your license key below or contact support.
    </div>
{/if}

<section class="mt-section" style="max-width:560px">
    <header class="mt-section-header">
        <h2 class="mt-section-title">License key</h2>
    </header>
    <form method="post" action="" class="mt-section-body">
        <div class="mt-field">
            <label class="mt-field-label" for="mt-license-key">Key</label>
            <input id="mt-license-key" class="mt-input" type="text" name="license_key"
                   value="{$key|escape}"
                   {if $devMode}disabled{/if}
                   placeholder="Paste your license key…">
            <div class="mt-field-help">
                {if $devMode}
                    Form is disabled while <code>dev_mode</code> is active.
                {else}
                    Find your key in your customer portal.
                {/if}
            </div>
        </div>
        <div class="mt-form-actions">
            <button type="submit" class="mt-btn mt-btn-primary" {if $devMode}disabled{/if}>Save and check</button>
            <button type="submit" name="refresh" value="1" class="mt-btn mt-btn-secondary" {if $devMode}disabled{/if}>Refresh now</button>
        </div>
    </form>
</section>

{include file="includes/footer.tpl"}
