{* A plan whose product is missing or retired is skipped, and the grid is
   sized for the cards that are left.

   The theme script swaps the text of every element that carries both
   data-monthly and data-annual when a switch button is clicked, so a card
   with both cycles prints both prices that way. A product with one of the
   two cycles prints that price with no attributes and so keeps it in both
   states. The switch itself shows only when a card can change. *}
{assign var=hbCount value=0}
{assign var=hbSwitch value=false}
{foreach $s.plans as $plan}
    {if $plan.productData}
        {assign var=hbCount value=$hbCount+1}
        {if isset($plan.productData.cycles.monthly) && isset($plan.productData.cycles.annually)}{assign var=hbSwitch value=true}{/if}
    {/if}
{/foreach}
{if $s.monthlyLabel === '' || $s.annualLabel === ''}{assign var=hbSwitch value=false}{/if}
{if $hbCount > 0}
<section class="hp-pricing-toggle-section">
    {if $s.title !== ''}<h2>{$s.title|escape}</h2>{/if}
    {if $s.subtitle !== ''}<p class="sub">{$s.subtitle|escape}</p>{/if}
    {if $hbSwitch}
        <div class="hp-billing-toggle">
            <button type="button"{if !$s.startAnnual} class="active"{/if} data-cycle="monthly" aria-pressed="{if $s.startAnnual}false{else}true{/if}">{$s.monthlyLabel|escape}</button>
            <button type="button"{if $s.startAnnual} class="active"{/if} data-cycle="annual" aria-pressed="{if $s.startAnnual}true{else}false{/if}">{$s.annualLabel|escape}</button>
        </div>
    {/if}
    <div class="hp-pricing-grid{if $hbCount == 2} cols-2{elseif $hbCount >= 4} cols-4{/if}"{if $hbCount == 1} style="grid-template-columns: minmax(0, 360px); justify-content: center;"{/if}>
        {foreach $s.plans as $plan}
            {if $plan.productData}
                {assign var=hbProduct value=$plan.productData}
                {assign var=hbHasM value=false}
                {assign var=hbHasA value=false}
                {assign var=hbMPrice value=''}
                {assign var=hbMPer value=''}
                {assign var=hbAPrice value=''}
                {assign var=hbAPer value=''}
                {if isset($hbProduct.cycles.monthly)}
                    {assign var=hbHasM value=true}
                    {assign var=hbMPrice value=$hbProduct.cycles.monthly.price}
                    {assign var=hbMPer value=$hbProduct.cycles.monthly.per}
                {/if}
                {if isset($hbProduct.cycles.annually)}
                    {assign var=hbHasA value=true}
                    {assign var=hbAPrice value=$hbProduct.cycles.annually.price}
                    {assign var=hbAPer value=$hbProduct.cycles.annually.per}
                    {if $s.annualPerMonth && $hbHasM && isset($hbProduct.cycles.annually.monthly) && $hbProduct.cycles.annually.monthly !== ''}
                        {assign var=hbAPrice value=$hbProduct.cycles.annually.monthly}
                        {assign var=hbAPer value=$hbMPer}
                    {/if}
                {/if}
                <div class="hp-price-card {if $plan.highlight}highlight{else}dim{/if}">
                    <div class="label">{$hbProduct.name|escape}{if $plan.badge !== ''} - {$plan.badge|escape}{/if}</div>
                    {if $hbProduct.tagline !== ''}<h3>{$hbProduct.tagline|escape}</h3>{/if}
                    <div class="price-row">
                        {if $hbProduct.free}
                            <span class="price">{$s.freeLabel|escape}</span>
                        {elseif $hbHasM && $hbHasA}
                            <span class="price" data-monthly="{$hbMPrice|escape}" data-annual="{$hbAPrice|escape}">{if $s.startAnnual}{$hbAPrice|escape}{else}{$hbMPrice|escape}{/if}</span><span class="per" data-monthly="{$hbMPer|escape}" data-annual="{$hbAPer|escape}">{if $s.startAnnual}{$hbAPer|escape}{else}{$hbMPer|escape}{/if}</span>
                        {elseif $hbHasM}
                            <span class="price">{$hbMPrice|escape}</span>{if $hbMPer !== ''}<span class="per">{$hbMPer|escape}</span>{/if}
                        {elseif $hbHasA}
                            <span class="price">{$hbAPrice|escape}</span>{if $hbAPer !== ''}<span class="per">{$hbAPer|escape}</span>{/if}
                        {elseif $hbProduct.price !== ''}
                            <span class="price">{$hbProduct.price|escape}</span>{if $hbProduct.per !== ''}<span class="per">{$hbProduct.per|escape}</span>{/if}
                        {/if}
                    </div>
                    {if $hbProduct.features}
                        <ul>{foreach $hbProduct.features as $feature}<li>{$feature|escape}</li>{/foreach}</ul>
                    {/if}
                    {if $s.buttonLabel !== ''}
                        {if $hbHasM && $hbHasA && !$hbProduct.free}
                            <a class="buy" href="{$hbProduct.orderUrl|escape}&amp;billingcycle={if $s.startAnnual}annually{else}monthly{/if}" data-href-monthly="{$hbProduct.orderUrl|escape}&amp;billingcycle=monthly" data-href-annual="{$hbProduct.orderUrl|escape}&amp;billingcycle=annually">{$s.buttonLabel|escape}</a>
                        {else}
                            <a class="buy" href="{$hbProduct.orderUrl|escape}">{$s.buttonLabel|escape}</a>
                        {/if}
                    {/if}
                </div>
            {/if}
        {/foreach}
    </div>
</section>
{if $hbSwitch}
{* The theme script swaps the prices. This keeps each order link on the cycle
   the visitor is looking at, and tells assistive technology which is on. *}
<script>{literal}
(function () {
    var root = document.currentScript.previousElementSibling;
    if (!root || !root.querySelector) { return; }
    var buttons = root.querySelectorAll('.hp-billing-toggle button');
    buttons.forEach(function (btn) {
        btn.addEventListener('click', function () {
            var cycle = btn.getAttribute('data-cycle');
            buttons.forEach(function (b) { b.setAttribute('aria-pressed', b === btn ? 'true' : 'false'); });
            root.querySelectorAll('a[data-href-' + cycle + ']').forEach(function (a) {
                a.setAttribute('href', a.getAttribute('data-href-' + cycle));
            });
        });
    });
})();
{/literal}</script>
{/if}
{/if}
