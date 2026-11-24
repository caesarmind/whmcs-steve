{* A plan whose product is missing or retired is skipped, along with its line
   of every spec row. The theme's grid is three columns wide, so one or two
   cards get a grid of their own size; it still folds to one column on a
   phone.

   The theme has no rule for a link inside hp-glance-card, so the order link
   carries its few styles inline, from theme tokens. *}
{assign var=hbCount value=0}
{foreach $s.plans as $plan}{if $plan.productData}{assign var=hbCount value=$hbCount+1}{/if}{/foreach}
{if $hbCount > 0}
<section class="hp-compare-glance">
    {if $s.title !== ''}<h2>{$s.title|escape}</h2>{/if}
    <div class="hp-glance-grid"{if $hbCount == 1} style="grid-template-columns: minmax(0, 360px); justify-content: center;"{elseif $hbCount == 2} style="grid-template-columns: repeat(auto-fit, minmax(240px, 1fr));"{/if}>
        {foreach $s.plans as $plan}
            {if $plan.productData}
                {assign var=hbProduct value=$plan.productData}
                {assign var=hbCol value=$plan@index}
                {assign var=hbSpecs value=0}
                {foreach $s.specs as $spec}{if $spec.label !== '' && isset($spec.valuesLines[$hbCol])}{assign var=hbSpecs value=$hbSpecs+1}{/if}{/foreach}
                <div class="hp-glance-card{if $plan.highlight} featured{/if}">
                    {if $plan.badge !== ''}<div class="tier-name">{$plan.badge|escape}</div>{/if}
                    <div class="prod-name">{$hbProduct.name|escape}</div>
                    {if $hbSpecs > 0}
                        <ul class="hp-glance-specs">
                            {foreach $s.specs as $spec}
                                {if $spec.label !== '' && isset($spec.valuesLines[$hbCol])}
                                    <li><span class="spec-label">{$spec.label|escape}</span><span class="spec-val">{$spec.valuesLines[$hbCol]|escape}</span></li>
                                {/if}
                            {/foreach}
                        </ul>
                    {/if}
                    {if $hbProduct.free}
                        <div class="price-line">{$s.freeLabel|escape}</div>
                    {elseif $hbProduct.price !== ''}
                        <div class="price-line">{$hbProduct.price|escape}{$hbProduct.per|escape}</div>
                    {/if}
                    {if $s.buttonLabel !== ''}
                        <a href="{$hbProduct.orderUrl|escape}" style="display: inline-block; margin-top: 12px; color: var(--color-link); font-size: var(--text-md); font-weight: var(--fw-medium); text-decoration: none;">{$s.buttonLabel|escape} &rsaquo;</a>
                    {/if}
                </div>
            {/if}
        {/foreach}
    </div>
</section>
{/if}
