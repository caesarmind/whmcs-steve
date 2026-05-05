{* =========================================================================
   Pricing comparison table for a given SSL $type (dv | wildcard | ov | ev).
   ========================================================================= *}
<div class="card certificate-options {$type}">
    <div class="card-header">
        <h3 class="card-title">{lang key='store.ssl.shared.pricing'}</h3>
        {include file="$template/store/ssl/shared/currency-chooser.tpl"}
    </div>
    <div class="card-body">
        {if is_array($certificates.$type) && count($certificates.$type) > 0}
            <div class="table-container">
                <table class="table ssl-pricing-table">
                    <thead>
                        <tr>
                            <th></th>
                            {foreach $certificates.$type as $product}
                                <th class="ssl-col-header{if $product->isFeatured} featured{/if}">
                                    {if $product->isFeatured}<span class="status-pill active">{lang key='recommended'}</span>{/if}
                                    {$certificateFeatures.{$product->configoption1}.displayName}
                                </th>
                            {/foreach}
                        </tr>
                    </thead>
                    <tbody>
                        <tr><th>{lang key='store.ssl.shared.encryption256'}</th>{foreach $certificates.$type as $product}<td><i class="fas fa-check text-success"></i></td>{/foreach}</tr>
                        <tr><th>{lang key='store.ssl.shared.issuanceTime'}</th>{foreach $certificates.$type as $product}<td>{$certificateFeatures.{$product->configoption1}.issuance}</td>{/foreach}</tr>
                        <tr><th>{lang key='store.ssl.shared.greatFor'}</th>{foreach $certificates.$type as $product}<td>{$certificateFeatures.{$product->configoption1}.for}</td>{/foreach}</tr>
                        <tr><th>{lang key='store.ssl.shared.warrantyValue'}</th>{foreach $certificates.$type as $product}<td>USD ${$certificateFeatures.{$product->configoption1}.warranty}</td>{/foreach}</tr>
                        <tr><th>{lang key='store.ssl.shared.siteSeal'}</th>{foreach $certificates.$type as $product}<td><i class="fas fa-check text-success"></i></td>{/foreach}</tr>
                        <tr><th>{lang key='store.ssl.shared.freeReissues'}</th>{foreach $certificates.$type as $product}<td><i class="fas fa-check text-success"></i></td>{/foreach}</tr>
                        <tr><th>{lang key='store.ssl.shared.browserSupport'}</th>{foreach $certificates.$type as $product}<td>99.9%</td>{/foreach}</tr>
                        <tr><th>{lang key='store.ssl.shared.oneYearPrice'}</th>{foreach $certificates.$type as $product}<td class="ssl-price">{if $product->pricing()->annual()}{$product->pricing()->annual()->yearlyPrice()}{else}&mdash;{/if}</td>{/foreach}</tr>
                        <tr><th>{lang key='store.ssl.shared.twoYearPrice'}</th>{foreach $certificates.$type as $product}<td class="ssl-price">{if $product->pricing()->biennial()}{$product->pricing()->biennial()->yearlyPrice()}{else}&mdash;{/if}</td>{/foreach}</tr>
                        <tr><th>{lang key='store.ssl.shared.threeYearPrice'}</th>{foreach $certificates.$type as $product}<td class="ssl-price">{if $product->pricing()->triennial()}{$product->pricing()->triennial()->yearlyPrice()}{else}&mdash;{/if}</td>{/foreach}</tr>
                        <tr class="ssl-buy-row">
                            <th></th>
                            {foreach $certificates.$type as $product}
                                <td>
                                    <form method="post" action="{routePath('cart-order')}">
                                        <input type="hidden" name="pid" value="{$product->id}">
                                        <button type="submit" class="btn btn-primary btn-sm btn-full">{lang key='store.ssl.landingPage.buyNow'}</button>
                                    </form>
                                </td>
                            {/foreach}
                        </tr>
                    </tbody>
                </table>
            </div>
            <div class="text-center mt-3">
                <a href="{routePath('store-product-group', $routePathSlug)}#helpmechoose" class="auth-link">
                    <i class="far fa-question-circle"></i> {lang key='store.ssl.shared.helpMeChoose'}
                </a>
            </div>
        {else}
            {include file="$template/includes/alert.tpl" type="info" msg="{lang key='store.ssl.shared.noProducts'}" textcenter=true}
        {/if}
    </div>
</div>
