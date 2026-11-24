{* The price line shows only for a chosen product that has a price. *}
{assign var=hbPrice value=''}
{assign var=hbPer value=''}
{if $s.productData && !$s.productData.free && $s.productData.price !== ''}
    {assign var=hbPrice value=$s.productData.price}
    {assign var=hbPer value=$s.productData.per}
{/if}
{if $s.eyebrow !== '' || $s.title !== '' || $s.text !== '' || ($s.primaryLabel !== '' && $s.primaryLink !== '') || ($s.secondaryLabel !== '' && $s.secondaryLink !== '')}
<section class="hp-hero">
    {if $s.eyebrow !== ''}<div class="hp-eyebrow">{$s.eyebrow|escape}</div>{/if}
    {if $s.title !== ''}<h1>{$s.title|escape}</h1>{/if}
    {if $s.text !== ''}<p class="hp-subhead">{$s.text|escape|nl2br}</p>{/if}
    {if ($s.primaryLabel !== '' && $s.primaryLink !== '') || ($s.secondaryLabel !== '' && $s.secondaryLink !== '') || $hbPrice !== ''}
        <div class="hp-cta-row">
            {if $s.primaryLabel !== '' && $s.primaryLink !== ''}<a href="{$s.primaryLink|escape}" class="hp-buy-btn">{$s.primaryLabel|escape}</a>{/if}
            {if $hbPrice !== ''}
                <span style="font-weight: var(--fw-semibold); color: var(--color-text-primary);">{if $s.pricePrefix !== ''}{$s.pricePrefix|escape} {/if}{$hbPrice|escape}{if $hbPer !== ''}<span style="font-size: var(--text-md); font-weight: var(--fw-normal); color: var(--color-text-secondary); margin-left: 2px;">{$hbPer|escape}</span>{/if}</span>
            {/if}
            {if $s.secondaryLabel !== '' && $s.secondaryLink !== ''}<a href="{$s.secondaryLink|escape}">{$s.secondaryLabel|escape} &rsaquo;</a>{/if}
        </div>
    {/if}
</section>
{/if}
