{* store/codeguard/index.tpl — CodeGuard landing page. *}
<div class="page-header">
    <h1 class="page-title">{lang key='store.codeguard.title'}</h1>
    <p class="page-subtitle">{lang key='store.codeguard.subtitle'}</p>
</div>

<div class="store-product-grid">
    {foreach $packages as $package}
        <div class="store-product-card card">
            <div class="card-header">
                <h3 class="card-title">{$package.name}</h3>
                {if $package.featured}<span class="status-pill active">{lang key='store.featured'}</span>{/if}
            </div>
            <div class="card-body">
                <div class="store-price">
                    <span class="store-price-amount">{$package.price}</span>
                    <span class="store-price-cycle">/{$package.cycle}</span>
                </div>
                {if $package.features}<ul class="store-features">{foreach $package.features as $f}<li><i class="fas fa-check"></i> {$f}</li>{/foreach}</ul>{/if}
                <a href="{routePath('cart-add', 'codeguard', $package.id)}" class="btn btn-primary btn-full">{lang key='orderNow'}</a>
            </div>
        </div>
    {/foreach}
</div>
