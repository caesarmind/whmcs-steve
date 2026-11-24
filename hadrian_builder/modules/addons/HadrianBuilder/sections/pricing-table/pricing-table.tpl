{* Columns are the plans whose product exists; a missing or retired product
   drops its column and, with it, that column's line of every row.

   Rows that follow each other with the same group go under one heading row.
   The theme script folds a group by matching the heading's data-section with
   the data-group of its rows, so each run of rows gets its own key (g1, g2). *}
{assign var=hbCount value=0}
{foreach $s.plans as $plan}{if $plan.productData}{assign var=hbCount value=$hbCount+1}{/if}{/foreach}
{if $hbCount > 0}
{assign var=hbSpan value=$hbCount+1}
<section class="hp-pricing-compare-table">
    {if $s.title !== '' || $s.subtitle !== ''}
        <div class="cmp-header">
            {if $s.title !== ''}<h2>{$s.title|escape}</h2>{/if}
            {if $s.subtitle !== ''}<p class="cmp-sub">{$s.subtitle|escape}</p>{/if}
        </div>
    {/if}
    <div class="cmp-scroll">
        <table class="cmp-grid">
            <thead>
                <tr>
                    <th class="cmp-corner" scope="col">{if $s.featuresLabel !== ''}<span class="sr-only">{$s.featuresLabel|escape}</span>{/if}</th>
                    {foreach $s.plans as $plan}
                        {if $plan.productData}
                            {assign var=hbProduct value=$plan.productData}
                            <th scope="col"{if $plan.highlight} class="cmp-featured-col"{/if}>
                                {if $plan.badge !== ''}<div class="cmp-plan-ribbon">{$plan.badge|escape}</div>{/if}
                                <div class="cmp-plan-name">{$hbProduct.name|escape}</div>
                                {if $hbProduct.free}
                                    <div class="cmp-plan-price cmp-price-custom">{$s.freeLabel|escape}</div>
                                {elseif $hbProduct.price !== ''}
                                    <div class="cmp-plan-price">{$hbProduct.price|escape}{if $hbProduct.per !== ''}<span>{$hbProduct.per|escape}</span>{/if}</div>
                                {/if}
                                {if $s.buttonLabel !== ''}<a href="{$hbProduct.orderUrl|escape}" class="cmp-plan-btn{if $plan.highlight} primary{/if}">{$s.buttonLabel|escape}</a>{/if}
                            </th>
                        {/if}
                    {/foreach}
                </tr>
            </thead>
            {if $s.rows}
                <tbody>
                    {assign var=hbGroup value=''}
                    {assign var=hbGroupNo value=0}
                    {foreach $s.rows as $row}
                        {if $row.label !== ''}
                            {if $row.group !== $hbGroup}
                                {assign var=hbGroup value=$row.group}
                                {assign var=hbGroupNo value=$hbGroupNo+1}
                                {if $row.group !== ''}
                                    <tr class="cmp-section-row" data-section="g{$hbGroupNo|escape}"><th colspan="{$hbSpan|escape}" scope="colgroup"><button type="button" class="cmp-section-toggle" aria-expanded="true"><span class="chev" aria-hidden="true">&#9662;</span><span>{$row.group|escape}</span></button></th></tr>
                                {/if}
                            {/if}
                            <tr{if $row.group !== ''} data-group="g{$hbGroupNo|escape}"{/if}>
                                <th scope="row">{$row.label|escape}{if $row.tip !== ''} <span class="cmp-tip" tabindex="0" role="note" data-tip="{$row.tip|escape}">i</span>{/if}</th>
                                {foreach $s.plans as $plan}
                                    {if $plan.productData}
                                        {assign var=hbValue value=''}
                                        {if isset($row.valuesLines[$plan@index])}{assign var=hbValue value=$row.valuesLines[$plan@index]}{/if}
                                        {assign var=hbKey value=$hbValue|lower}
                                        <td{if $plan.highlight} class="cmp-featured"{/if}>{if $hbKey === 'yes'}<span class="cmp-check" aria-hidden="true">&#10003;</span>{if $s.yesLabel !== ''}<span class="sr-only">{$s.yesLabel|escape}</span>{/if}{elseif $hbKey === 'no' || $hbKey === '-'}<span class="cmp-dash" aria-hidden="true">&mdash;</span>{if $s.noLabel !== ''}<span class="sr-only">{$s.noLabel|escape}</span>{/if}{else}{$hbValue|escape}{/if}</td>
                                    {/if}
                                {/foreach}
                            </tr>
                        {/if}
                    {/foreach}
                </tbody>
            {/if}
        </table>
    </div>
</section>
{/if}
