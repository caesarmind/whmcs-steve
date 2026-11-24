{* A plan whose product is missing or retired is skipped, and the bar is
   sized for the columns that are left (the theme's count-1 to count-4). *}
{assign var=hbCount value=0}
{foreach $s.plans as $plan}{if $plan.productData}{assign var=hbCount value=$hbCount+1}{/if}{/foreach}
{if $hbCount > 0}
<section class="hp-pricing-segmented">
    {if $s.title !== ''}<h2>{$s.title|escape}</h2>{/if}
    {if $s.subtitle !== ''}<p class="sub">{$s.subtitle|escape}</p>{/if}
    <div class="hp-segmented-bar count-{if $hbCount >= 4}4{else}{$hbCount|escape}{/if}">
        {foreach $s.plans as $plan}
            {if $plan.productData}
                {assign var=hbProduct value=$plan.productData}
                <div class="hp-seg-col{if $plan.highlight} highlight{/if}">
                    <div class="tier">{$hbProduct.name|escape}</div>
                    {if $hbProduct.free}
                        <div class="price">{$s.freeLabel|escape}</div>
                    {elseif $hbProduct.price !== ''}
                        <div class="price">{$hbProduct.price|escape}{if $hbProduct.per !== ''}<span class="per">{$hbProduct.per|escape}</span>{/if}</div>
                    {/if}
                    {if $hbProduct.tagline !== ''}<div class="desc">{$hbProduct.tagline|escape}</div>{/if}
                    {* Printed even when empty: this list is what pushes the
                       button to the bottom of the column. *}
                    <ul class="seg-features">{foreach $hbProduct.features as $feature}<li>{$feature|escape}</li>{/foreach}</ul>
                    {if $s.buttonLabel !== ''}<a href="{$hbProduct.orderUrl|escape}" class="buy">{$s.buttonLabel|escape}</a>{/if}
                </div>
            {/if}
        {/foreach}
    </div>
</section>
{/if}
