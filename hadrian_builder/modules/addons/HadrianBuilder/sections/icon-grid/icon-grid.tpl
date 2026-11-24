{* The heading sits inside the grid, so it spans every column and drops the
   padding the theme gives it for standing on its own. *}
{assign var=hbCount value=0}
{foreach $s.items as $item}{if $item.title !== '' || $item.text !== ''}{assign var=hbCount value=$hbCount+1}{/if}{/foreach}
{if $hbCount > 0}
<section class="hp-icon-grid{if $s.columns != '3'} cols-{$s.columns|escape}{/if}">
    {if $s.title !== '' || $s.subtitle !== ''}
        <div class="hp-icon-grid-header" style="grid-column: 1 / -1; padding: 0;">
            {if $s.title !== ''}<h2>{$s.title|escape}</h2>{/if}
            {if $s.subtitle !== ''}<p>{$s.subtitle|escape}</p>{/if}
        </div>
    {/if}
    {foreach $s.items as $item}
        {if $item.title !== '' || $item.text !== ''}
            <div class="hp-icon-item">
                {if $item.iconSvg !== ''}<div class="icon-circle {$item.colour|escape}">{$item.iconSvg nofilter}</div>{/if}
                {if $item.title !== ''}<h4>{$item.title|escape}</h4>{/if}
                {if $item.text !== ''}<p>{$item.text|escape}</p>{/if}
            </div>
        {/if}
    {/foreach}
</section>
{/if}
