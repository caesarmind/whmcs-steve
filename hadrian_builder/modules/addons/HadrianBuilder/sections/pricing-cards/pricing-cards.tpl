{* A plan whose product is missing or retired is skipped, and the grid is
   sized for the cards that are left. *}
{assign var=hbCount value=0}
{foreach $s.plans as $plan}{if $plan.productData}{assign var=hbCount value=$hbCount+1}{/if}{/foreach}
{if $hbCount > 0}
<section class="hp-pricing-section">
    {if $s.title !== ''}<h2>{$s.title|escape}</h2>{/if}
    {if $s.subtitle !== ''}<p class="sub">{$s.subtitle|escape}</p>{/if}
    <div class="hp-pricing-grid{if $hbCount == 2} cols-2{elseif $hbCount >= 4} cols-4{/if}"{if $hbCount == 1} style="grid-template-columns: minmax(0, 360px); justify-content: center;"{/if}>
        {foreach $s.plans as $plan}
            {if $plan.productData}
                {assign var=hbProduct value=$plan.productData}
                <div class="hp-price-card {if $plan.highlight}highlight{else}dim{/if}">
                    <div class="label">{$hbProduct.name|escape}{if $plan.badge !== ''} - {$plan.badge|escape}{/if}</div>
                    {if $hbProduct.tagline !== ''}<h3>{$hbProduct.tagline|escape}</h3>{/if}
                    <div class="price-row">
                        {if $hbProduct.free}
                            <span class="price">{$s.freeLabel|escape}</span>
                        {elseif $hbProduct.price !== ''}
                            <span class="price">{$hbProduct.price|escape}</span>{if $hbProduct.per !== ''}<span class="per">{$hbProduct.per|escape}</span>{/if}
                        {/if}
                    </div>
                    {if $hbProduct.features}
                        <ul>{foreach $hbProduct.features as $feature}<li>{$feature|escape}</li>{/foreach}</ul>
                    {/if}
                    <a class="buy" href="{$hbProduct.orderUrl|escape}">{$s.buttonLabel|escape}</a>
                </div>
            {/if}
        {/foreach}
    </div>
</section>
{/if}
