{* The tabs are the distinct category names of the questions, in the order they
   first appear. The theme script pairs the first tab with the first panel, the
   second with the second and so on, so both loops below walk the same list.
   A question with no category is shown under every tab. With fewer than two
   categories there is nothing to switch, so the questions print as one list. *}
{strip}
{assign var=hbCount value=0}
{assign var=hbCats value=[]}
{assign var=hbCatCount value=0}
{foreach $s.items as $item}
    {if $item.question !== ''}
        {assign var=hbCount value=$hbCount+1}
        {if $item.category !== ''}
            {assign var=hbSeen value=false}
            {foreach $hbCats as $hbCat}{if $hbCat === $item.category}{assign var=hbSeen value=true}{break}{/if}{/foreach}
            {if !$hbSeen}{append var=hbCats value=$item.category}{assign var=hbCatCount value=$hbCatCount+1}{/if}
        {/if}
    {/if}
{/foreach}
{/strip}
{if $hbCount > 0}
<section class="hp-faq-tabs-section">
    {if $s.title !== ''}<h2>{$s.title|escape}</h2>{/if}
    {if $s.subtitle !== ''}<p class="sub">{$s.subtitle|escape}</p>{/if}
    {if $hbCatCount > 1}
        <div class="hp-faq-cat-tabs">
            {foreach $hbCats as $hbCat}
                <button type="button" class="hp-faq-cat{if $hbCat@first} active{/if}">{$hbCat|escape}</button>
            {/foreach}
        </div>
        {foreach $hbCats as $hbCat}
            <div class="hp-faq-cat-panel{if $hbCat@first} active{/if}">
                {foreach $s.items as $item}
                    {if $item.question !== '' && ($item.category === $hbCat || $item.category === '')}
                        <details class="hp-faq-item">
                            <summary>{$item.question|escape}</summary>
                            <div class="faq-body">{$item.answer nofilter}</div>
                        </details>
                    {/if}
                {/foreach}
            </div>
        {/foreach}
    {else}
        {foreach $s.items as $item}
            {if $item.question !== ''}
                <details class="hp-faq-item">
                    <summary>{$item.question|escape}</summary>
                    <div class="faq-body">{$item.answer nofilter}</div>
                </details>
            {/if}
        {/foreach}
    {/if}
</section>
{/if}
