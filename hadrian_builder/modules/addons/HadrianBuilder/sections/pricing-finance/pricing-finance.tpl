{* Nothing prints until a product is picked, or when it is missing or retired.

   The theme script moves the "active" class between the hp-finance-opt
   choices. With both cycles each choice also carries the order link for its
   cycle, and the script under the section points the button at it. A product
   with one of the two cycles shows one choice; a product with neither shows
   its own first price. *}
{if $s.productData}
{assign var=hbProduct value=$s.productData}
{assign var=hbHasM value=false}
{assign var=hbHasA value=false}
{if !$hbProduct.free && isset($hbProduct.cycles.monthly)}{assign var=hbHasM value=true}{/if}
{if !$hbProduct.free && isset($hbProduct.cycles.annually)}{assign var=hbHasA value=true}{/if}
{assign var=hbBoth value=false}
{if $hbHasM && $hbHasA}{assign var=hbBoth value=true}{/if}
{assign var=hbAnnualOn value=false}
{if $hbHasA && ($s.startAnnual || !$hbHasM)}{assign var=hbAnnualOn value=true}{/if}
<section class="hp-pricing-finance">
    {if $s.title !== ''}<h2>{$s.title|escape}</h2>{/if}
    {if $s.subtitle !== ''}<p class="sub">{$s.subtitle|escape}</p>{/if}
    <div class="hp-finance-card">
        <div class="hp-finance-options"{if !$hbBoth} style="grid-template-columns: minmax(0, 1fr);"{/if}>
            {if $hbHasM}
                <div class="hp-finance-opt{if !$hbAnnualOn} active{/if}"{if $hbBoth} role="button" tabindex="0" aria-pressed="{if $hbAnnualOn}false{else}true{/if}" data-href="{$hbProduct.orderUrl|escape}&amp;billingcycle=monthly"{/if}>
                    {if $s.monthlyLabel !== ''}<div class="label">{$s.monthlyLabel|escape}</div>{/if}
                    <div class="price">{$hbProduct.cycles.monthly.price|escape}{if $hbProduct.cycles.monthly.per !== ''}<span class="per">{$hbProduct.cycles.monthly.per|escape}</span>{/if}</div>
                    {if $s.monthlyNote !== ''}<div class="note">{$s.monthlyNote|escape}</div>{/if}
                </div>
            {/if}
            {if $hbHasA}
                {* The note may name the yearly price per month with [price].
                   When WHMCS gives no such figure, a note that needs it is left out. *}
                {assign var=hbPerMonth value=''}
                {if isset($hbProduct.cycles.annually.monthly)}{assign var=hbPerMonth value=$hbProduct.cycles.annually.monthly}{/if}
                {assign var=hbNote value=$s.annualNote|replace:'[price]':$hbPerMonth}
                {if $hbPerMonth === '' && $hbNote !== $s.annualNote}{assign var=hbNote value=''}{/if}
                <div class="hp-finance-opt{if $hbAnnualOn} active{/if}"{if $hbBoth} role="button" tabindex="0" aria-pressed="{if $hbAnnualOn}true{else}false{/if}" data-href="{$hbProduct.orderUrl|escape}&amp;billingcycle=annually"{/if}>
                    {if $s.annualLabel !== ''}<div class="label">{$s.annualLabel|escape}</div>{/if}
                    <div class="price">{$hbProduct.cycles.annually.price|escape}{if $hbProduct.cycles.annually.per !== ''}<span class="per">{$hbProduct.cycles.annually.per|escape}</span>{/if}</div>
                    {if $hbNote !== ''}<div class="note">{$hbNote|escape}</div>{/if}
                </div>
            {/if}
            {if !$hbHasM && !$hbHasA}
                <div class="hp-finance-opt active">
                    <div class="label">{$hbProduct.name|escape}</div>
                    {if $hbProduct.free}
                        <div class="price">{$s.freeLabel|escape}</div>
                    {elseif $hbProduct.price !== ''}
                        <div class="price">{$hbProduct.price|escape}{if $hbProduct.per !== ''}<span class="per">{$hbProduct.per|escape}</span>{/if}</div>
                    {/if}
                </div>
            {/if}
        </div>
        {if $s.buttonLabel !== ''}
            <a href="{$hbProduct.orderUrl|escape}{if $hbBoth}&amp;billingcycle={if $hbAnnualOn}annually{else}monthly{/if}{/if}" class="finance-cta">{$s.buttonLabel|escape}</a>
        {/if}
    </div>
</section>
{if $hbBoth}
{* The theme script marks the clicked choice. This points the button at that
   choice's billing cycle and lets the keyboard make the choice too. *}
<script>{literal}
(function () {
    var root = document.currentScript.previousElementSibling;
    if (!root || !root.querySelector) { return; }
    var cta = root.querySelector('.finance-cta');
    var opts = root.querySelectorAll('.hp-finance-opt[data-href]');
    opts.forEach(function (opt) {
        opt.addEventListener('click', function () {
            opts.forEach(function (o) { o.setAttribute('aria-pressed', o === opt ? 'true' : 'false'); });
            if (cta) { cta.setAttribute('href', opt.getAttribute('data-href')); }
        });
        opt.addEventListener('keydown', function (e) {
            if (e.key === 'Enter' || e.key === ' ') {
                e.preventDefault();
                opt.click();
            }
        });
    });
})();
{/literal}</script>
{/if}
{/if}
