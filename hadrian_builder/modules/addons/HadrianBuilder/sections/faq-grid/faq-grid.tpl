{assign var=hbCount value=0}
{foreach $s.items as $item}{if $item.question !== ''}{assign var=hbCount value=$hbCount+1}{/if}{/foreach}
{if $hbCount > 0}
<section class="hp-faq-grid">
    {if $s.title !== ''}<h2>{$s.title|escape}</h2>{/if}
    <div class="faq-grid-inner">
        {foreach $s.items as $item}
            {if $item.question !== ''}
                <div class="hp-faq-card">
                    <h4>{$item.question|escape}</h4>
                    {$item.answer nofilter}
                </div>
            {/if}
        {/foreach}
    </div>
</section>
{/if}
