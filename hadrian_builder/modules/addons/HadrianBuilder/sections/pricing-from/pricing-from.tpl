{* Nothing prints until a product is picked, or when it is missing or retired.
   The theme has no button rule inside hp-pricing-hero, so the order button
   is the theme's general hp-buy-btn. *}
{if $s.productData}
{assign var=hbProduct value=$s.productData}
{assign var=hbPrice value=$hbProduct.price}
{assign var=hbPer value=$hbProduct.per}
{if $s.show == 'monthly' && isset($hbProduct.cycles.monthly)}
    {assign var=hbPrice value=$hbProduct.cycles.monthly.price}
    {assign var=hbPer value=$hbProduct.cycles.monthly.per}
{elseif $s.show == 'annually' && isset($hbProduct.cycles.annually)}
    {assign var=hbPrice value=$hbProduct.cycles.annually.price}
    {assign var=hbPer value=$hbProduct.cycles.annually.per}
{elseif $s.show == 'permonth' && isset($hbProduct.cycles.annually.monthly) && isset($hbProduct.cycles.monthly) && $hbProduct.cycles.annually.monthly !== ''}
    {assign var=hbPrice value=$hbProduct.cycles.annually.monthly}
    {assign var=hbPer value=$hbProduct.cycles.monthly.per}
{/if}
<section class="hp-pricing-hero">
    {if $s.label !== ''}<h2 class="price-label" style="margin-top: 0;">{$s.label|escape}</h2>{/if}
    {if $hbProduct.free}
        <div class="price-big">{$s.freeLabel|escape}</div>
    {elseif $hbPrice !== ''}
        <div class="price-big">{$hbPrice|escape}{if $hbPer !== ''}<span class="per">{$hbPer|escape}</span>{/if}</div>
    {/if}
    <div class="price-sub">{if $s.text !== ''}{$s.text|escape}{else}{$hbProduct.name|escape}{/if}</div>
    {if $hbProduct.features}
        <ul class="feature-list">{foreach $hbProduct.features as $feature}<li>{$feature|escape}</li>{/foreach}</ul>
    {/if}
    {if $s.buttonLabel !== ''}
        <div{if $hbProduct.features} style="margin-top: 32px;"{/if}><a class="hp-buy-btn" href="{$hbProduct.orderUrl|escape}">{$s.buttonLabel|escape}</a></div>
    {/if}
</section>
{/if}
