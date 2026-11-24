{* A step with no title and no text is skipped, and the numbers stay in order. *}
{assign var=hbCount value=0}
{foreach $s.items as $item}{if $item.title !== '' || $item.text !== ''}{assign var=hbCount value=$hbCount+1}{/if}{/foreach}
{if $hbCount > 0}
<section class="hp-features-numbered">
    {if $s.title !== ''}<h2>{$s.title|escape}</h2>{/if}
    <div class="hp-numbered-list">
        {assign var=hbNum value=0}
        {foreach $s.items as $item}
            {if $item.title !== '' || $item.text !== ''}
                {assign var=hbNum value=$hbNum+1}
                <div class="hp-numbered-item">
                    <div class="num">{if $hbNum < 10}0{/if}{$hbNum|escape}</div>
                    <div>
                        {if $item.title !== ''}<h4>{$item.title|escape}</h4>{/if}
                        {if $item.text !== ''}<p>{$item.text|escape|nl2br}</p>{/if}
                    </div>
                </div>
            {/if}
        {/foreach}
    </div>
</section>
{/if}
