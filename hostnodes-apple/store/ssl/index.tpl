{* =========================================================================
   store/ssl/index.tpl — SSL product family landing page.
   ========================================================================= *}
<div class="page-header">
    <h1 class="page-title">{lang key='store.ssl.title'}</h1>
    <p class="page-subtitle">{lang key='store.ssl.subtitle'}</p>
</div>

<div class="ssl-nav filter-tabs">
    <a href="{routePath('store-ssl-dv')}" class="filter-tab">{lang key='store.ssl.dv'}</a>
    <a href="{routePath('store-ssl-ov')}" class="filter-tab">{lang key='store.ssl.ov'}</a>
    <a href="{routePath('store-ssl-ev')}" class="filter-tab">{lang key='store.ssl.ev'}</a>
    <a href="{routePath('store-ssl-wildcard')}" class="filter-tab">{lang key='store.ssl.wildcard'}</a>
</div>

<div class="ssl-grid">
    {foreach $certificates as $cert}
        <div class="ssl-card card">
            <div class="card-header">
                <h3 class="card-title">{$cert.name}</h3>
                {if $cert.brand_logo}<img src="{$cert.brand_logo}" alt="" class="ssl-brand-logo">{/if}
            </div>
            <div class="card-body">
                <div class="ssl-price">
                    <span class="ssl-price-amount">{$cert.price}</span>
                    <span class="ssl-price-cycle">/{$cert.cycle}</span>
                </div>
                {if $cert.features}
                    <ul class="ssl-features">
                        {foreach $cert.features as $feature}
                            <li><i class="fas fa-check"></i> {$feature}</li>
                        {/foreach}
                    </ul>
                {/if}
                <a href="{routePath('cart-add', 'sslcert', $cert.id)}" class="btn btn-primary btn-full">{lang key='store.ssl.orderNow'}</a>
            </div>
        </div>
    {/foreach}
</div>
