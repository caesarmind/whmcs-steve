{* SSL competitive upgrade: a visitor with a certificate from another provider
   checks their site and, if eligible, gets the months left on it added free
   to a new certificate. Same contract as stock twenty-one: the form posts
   url to cart-ssl-certificates-competitiveupgrade-validate, which comes back
   with $validated, $eligible, $expirationDate, $monthsRemaining,
   $freeExtensionMonths, $maxPotentialSavingAmount, $connectionError /
   $error, and $productGroupSlug for the Continue link. Copy is WHMCS's
   store.ssl.competitiveUpgrades.* strings. *}
<script>
(function () {
    var b = document.body;
    if (b) b.setAttribute('data-svc-layout', 'inside');
})();
</script>

<section class="hp-hero-split" style="padding: 60px 22px 24px;">
    <div class="hp-split-text">
        <div class="hp-eyebrow">{lang key='store.ssl.competitiveUpgrade'}</div>
        <h1>{lang key='store.ssl.competitiveUpgrades.switch'}</h1>
        <p>{lang key='store.ssl.competitiveUpgrades.replace'}</p>
    </div>
</section>

<section style="max-width: var(--w-prose); margin: 0 auto; padding: 24px 22px 64px;">
    <h2 style="margin: 0 0 16px;">{lang key='store.ssl.competitiveUpgrades.buyWithTime'} <strong>{lang key='store.ssl.competitiveUpgrades.foc'}</strong>.</h2>

    <div class="callout warning" role="note">
        <div class="callout-text">
            <strong style="display:block;margin-bottom:4px">{lang key='store.ssl.competitiveUpgrades.exampleScenario'}</strong>
            {lang key='store.ssl.competitiveUpgrades.example.line1'}
            {lang key='store.ssl.competitiveUpgrades.example.line2'}
            {lang key='store.ssl.competitiveUpgrades.example.line3'}
        </div>
    </div>

    <p style="color: var(--color-text-secondary);">{lang key='store.ssl.competitiveUpgrades.eligibilityCheck'}</p>

    {if isset($connectionError) && $connectionError}
        <div class="callout error" role="alert"><div class="callout-text">{lang key='store.ssl.competitiveUpgrades.checkFailed'}</div></div>
    {elseif isset($error) && $error}
        <div class="callout error" role="alert"><div class="callout-text">{$error}</div></div>
    {/if}

    <form method="post" action="{routePath('cart-ssl-certificates-competitiveupgrade-validate')}">
        {if isset($validated) && $validated}
            {if $eligible}
                <div class="callout success" role="status"><div class="callout-text">{lang key='store.ssl.competitiveUpgrades.eligible'}</div></div>
                <div class="settings-group">
                    <div class="settings-item"><div class="settings-item-content"><div class="settings-item-label">{lang key='store.ssl.competitiveUpgrades.expirationDate'}</div></div><div class="settings-item-action"><span class="settings-item-value">{$expirationDate}</span></div></div>
                    <div class="settings-item"><div class="settings-item-content"><div class="settings-item-label">{lang key='store.ssl.competitiveUpgrades.monthsRemaining'}</div></div><div class="settings-item-action"><span class="settings-item-value">{lang key='store.ssl.competitiveUpgrades.months' months=$monthsRemaining}</span></div></div>
                    <div class="settings-item"><div class="settings-item-content"><div class="settings-item-label">{lang key='store.ssl.competitiveUpgrades.freeExtension'}</div></div><div class="settings-item-action"><span class="settings-item-value">{lang key='store.ssl.competitiveUpgrades.months' months=$freeExtensionMonths}{if $freeExtensionMonths < $monthsRemaining} ({lang key='store.ssl.competitiveUpgrades.maxMonths'}){/if}</span></div></div>
                    {if isset($maxPotentialSavingAmount)}
                    <div class="settings-item"><div class="settings-item-content"><div class="settings-item-label">{lang key='store.ssl.competitiveUpgrades.saving'}</div></div><div class="settings-item-action"><span class="settings-item-value">{lang key='store.ssl.competitiveUpgrades.savingInfomation' saveAmount=$maxPotentialSavingAmount}</span></div></div>
                    {/if}
                </div>
                <a class="hp-buy-btn" href="{routePath('store-product-group', $productGroupSlug, 'ev')}">{lang key='store.ssl.competitiveUpgrades.continue'}</a>
            {else}
                <div class="callout warning" role="status"><div class="callout-text">{lang key='store.ssl.competitiveUpgrades.ineligible'}*.</div></div>
            {/if}
        {/if}

        {if !isset($validated) || !$validated || !$eligible}
            <div style="display:flex;gap:8px;align-items:stretch;margin-top:12px;">
                <span style="display:flex;align-items:center;padding:0 12px;border:.5px solid var(--color-border);border-radius:var(--radius-md);background:var(--color-surface-secondary);color:var(--color-text-secondary);">https://</span>
                <input type="text" name="url" value="{$url|default:''}" class="form-input" style="flex:1;min-width:0;" placeholder="{lang key='store.ssl.competitiveUpgrades.enterDomain'}" aria-label="{lang key='store.ssl.competitiveUpgrades.enterDomain'}">
                <button type="submit" class="btn-primary">{lang key='store.ssl.competitiveUpgrades.validate'}</button>
            </div>
            <p style="font-size:var(--text-sm);color:var(--color-text-tertiary);margin-top:8px;">* {lang key='store.ssl.competitiveUpgrades.competitors'}</p>
        {/if}
    </form>
</section>
