{* =========================================================================
   Single certificate block — one column in the SSL landing grid.
   Parameters: $blockTitle, $logo, $certificate, $description, $recommendedFor, $features
   ========================================================================= *}
<div class="ssl-card card">
    <div class="card-header">
        <h3 class="card-title">{lang key=$blockTitle}</h3>
        <div class="ssl-brand">
            <img src="{$WEB_ROOT}/{$logo}" alt="">
            <span>{$certificate->name}</span>
        </div>
    </div>
    <div class="card-body">
        <p>{lang key=$description}</p>
        <p class="form-hint"><strong>{lang key="store.ssl.landingPage.recommendedFor"}:</strong> {lang key=$recommendedFor}</p>
        <ul class="ssl-features">
            {foreach $features as $feature}
                <li><i class="fas fa-shield-alt"></i> {$feature}</li>
            {/foreach}
        </ul>
        <form method="post" action="{routePath('cart-order')}">
            <input type="hidden" name="pid" value="{$certificate->id}">
            <button type="submit" class="btn btn-primary btn-full">{lang key="store.ssl.landingPage.buy"}</button>
        </form>
    </div>
</div>
