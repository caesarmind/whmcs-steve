{* A figure with neither a value nor a label is skipped. *}
{assign var=hbCount value=0}
{foreach $s.items as $item}{if $item.value !== '' || $item.label !== ''}{assign var=hbCount value=$hbCount+1}{/if}{/foreach}
{if $hbCount > 0}
<section class="hp-stats-strip">
    <div class="stats-inner">
        {foreach $s.items as $item}
            {if $item.value !== '' || $item.label !== ''}
                <div class="hp-stat">
                    {if $item.value !== ''}<div class="stat-num">{$item.value|escape}</div>{/if}
                    {if $item.label !== ''}<div class="stat-label">{$item.label|escape}</div>{/if}
                </div>
            {/if}
        {/foreach}
    </div>
</section>
{/if}
