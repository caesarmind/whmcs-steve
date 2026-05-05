{* store/dynamic/index.tpl — generic dynamic product landing page.
   Used when a product doesn't have a bespoke vendor folder. *}
<div class="page-header">
    <h1 class="page-title">{$product.name}</h1>
    {if $product.description}<p class="page-subtitle">{$product.description|strip_tags|truncate:160:"..."}</p>{/if}
</div>

{if $product.marketing_html}
    <div class="card">
        <div class="card-body product-marketing">{$product.marketing_html}</div>
    </div>
{/if}

<div class="store-product-grid">
    {foreach $packages as $package}
        <div class="store-product-card card">
            <div class="card-header"><h3 class="card-title">{$package.name}</h3></div>
            <div class="card-body">
                <div class="store-price"><span class="store-price-amount">{$package.price}</span><span class="store-price-cycle">/{$package.cycle}</span></div>
                {if $package.features}<ul class="store-features">{foreach $package.features as $f}<li><i class="fas fa-check"></i> {$f}</li>{/foreach}</ul>{/if}
                <a href="{routePath('cart-add', $product.slug, $package.id)}" class="btn btn-primary btn-full">{lang key='orderNow'}</a>
            </div>
        </div>
    {/foreach}
</div>
