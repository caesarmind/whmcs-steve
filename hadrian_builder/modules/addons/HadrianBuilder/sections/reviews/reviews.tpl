{* A breakdown row with no name is skipped. *}
{assign var=hbCount value=0}
{foreach $s.sources as $source}{if $source.name !== ''}{assign var=hbCount value=$hbCount+1}{/if}{/foreach}
{if $s.score !== '' || $s.caption !== '' || $hbCount > 0}
<section class="hp-testi-reviews">
    <div class="big-stars" role="img" aria-label="{$s.rating|escape} / 5">{for $hbStar=1 to $s.rating}&#9733;{/for}</div>
    {if $s.score !== ''}<div class="rating-num">{$s.score|escape}</div>{/if}
    {if $s.caption !== ''}<div class="rating-of">{$s.caption|escape}</div>{/if}
    {if $hbCount > 0}
        <div class="review-sources">
            {foreach $s.sources as $source}
                {if $source.name !== ''}
                    <div class="rev-src">
                        <div class="stars" role="img" aria-label="{$source.rating|escape} / 5">{for $hbStar=1 to $source.rating}&#9733;{/for}</div>
                        <div class="src-name">{$source.name|escape}</div>
                        {if $source.count !== ''}<div class="src-count">{$source.count|escape}</div>{/if}
                    </div>
                {/if}
            {/foreach}
        </div>
    {/if}
</section>
{/if}
