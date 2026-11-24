{* MarketConnect promotion banner. WHMCS renders this file from the active
   theme for its MarketConnect cross-sell promotions (SiteLock, CodeGuard,
   OX, SpamExperts ...), e.g. the ones it hands the product details page in
   $hookOutput and the cart's promotions. Stock contract (twenty-one):
     $promotion   getClass, getLearnMoreRoute, getImagePath, getHeadline,
                  getTagline, getDescription, hasFeatures, getFeatures, getCta
     $product     the promoted product (isFree, name, pricing()->first())
     $targetUrl   where the button posts, with $inputParameters as hidden
                  fields. Prices and copy all come from WHMCS. *}
<style>{literal}
.hn-promo{display:flex;gap:20px;align-items:flex-start;padding:20px 24px;margin:0 0 24px;border-radius:var(--radius-lg);background:var(--color-surface)}
.hn-promo-ico img{width:56px;height:56px;object-fit:contain}
.hn-promo-body{flex:1;min-width:0}
.hn-promo h3{margin:0 0 2px;font-size:var(--text-lg);font-weight:var(--fw-semibold);color:var(--color-text-primary)}
.hn-promo h3 a{margin-left:8px;font-size:var(--text-sm);font-weight:var(--fw-regular,400)}
.hn-promo h4{margin:0 0 10px;font-size:var(--text-md);font-weight:var(--fw-regular,400);color:var(--color-text-secondary)}
.hn-promo p{margin:0 0 10px;font-size:var(--text-sm);color:var(--color-text-secondary);line-height:1.5}
.hn-promo ul{display:grid;grid-template-columns:repeat(auto-fit,minmax(200px,1fr));gap:4px 16px;margin:0 0 14px;padding:0;list-style:none;font-size:var(--text-sm);color:var(--color-text-primary)}
.hn-promo li::before{content:"\2713";margin-right:6px;color:var(--color-green-text)}
@media (max-width:600px){.hn-promo{flex-direction:column}}
{/literal}</style>
<div class="hn-promo promo-banner {$promotion->getClass()}">
    <div class="hn-promo-ico">
        {if $promotion->getLearnMoreRoute()}<a href="{$promotion->getLearnMoreRoute()}">{/if}<img src="{$promotion->getImagePath()}" alt="">{if $promotion->getLearnMoreRoute()}</a>{/if}
    </div>
    <div class="hn-promo-body">
        <h3>{$promotion->getHeadline()}{if $promotion->getLearnMoreRoute()}<a href="{$promotion->getLearnMoreRoute()}">{lang key='learnmore'}</a>{/if}</h3>
        <h4>{$promotion->getTagline()}</h4>
        {if $promotion->getDescription()}<p>{$promotion->getDescription()}</p>{/if}
        {if $promotion->hasFeatures()}
            <ul>
                {foreach $promotion->getFeatures() as $feature}<li>{$feature}</li>{/foreach}
            </ul>
        {/if}
        <form method="post" action="{$targetUrl}">
            {foreach $inputParameters as $key => $value}
                <input type="hidden" name="{$key}" value="{$value}">
            {/foreach}
            <button type="submit" class="btn-primary">
                {if $product->isFree()}
                    {$promotion->getCta()} {lang key="orderfree"}
                {else}
                    {$promotion->getCta()} {$product->name}
                    {lang key="fromJust"}
                    {if $product->pricing()->first()->isYearly()}
                        {$product->pricing()->first()->yearlyPrice()}
                    {elseif $product->pricing()->first()->isOneTime()}
                        {$product->pricing()->first()->oneTimePrice()}
                    {else}
                        {$product->pricing()->first()->monthlyPrice()}
                    {/if}
                {/if}
            </button>
        </form>
    </div>
</div>
