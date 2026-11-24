{* A card with no title and no text is skipped. The large icon needs the
   height of a tall card, so a standard card does not print it. *}
{assign var=hbCount value=0}
{foreach $s.items as $item}{if $item.title !== '' || $item.text !== ''}{assign var=hbCount value=$hbCount+1}{/if}{/foreach}
{if $hbCount > 0}
<section class="hp-feature-masonry">
    {if $s.title !== ''}<h2>{$s.title|escape}</h2>{/if}
    {if $s.subtitle !== ''}<p class="feat-sub">{$s.subtitle|escape}</p>{/if}
    <div class="hp-masonry-grid">
        {foreach $s.items as $item}
            {if $item.title !== '' || $item.text !== ''}
                <div class="hp-masonry-card{if $item.tone != 'plain'} {$item.tone|escape}{/if}{if $item.tall} tall{/if}">
                    {if $item.iconSvg !== ''}<div class="m-icon">{$item.iconSvg nofilter}</div>{/if}
                    {if $item.title !== ''}<h4>{$item.title|escape}</h4>{/if}
                    {if $item.text !== ''}<p>{$item.text|escape|nl2br}</p>{/if}
                    {if $item.tall && $item.visualSvg !== ''}<div class="m-visual" aria-hidden="true">{$item.visualSvg nofilter}</div>{/if}
                </div>
            {/if}
        {/foreach}
    </div>
</section>
{/if}
