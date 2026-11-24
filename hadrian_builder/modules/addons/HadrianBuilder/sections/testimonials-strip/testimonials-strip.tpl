{* The theme colours the quote and the name with the same token as the band
   behind them, so both take the heading's colour here. It also leaves the
   colour of the letter circle to the markup. The theme script needs both
   arrows to be present. *}
{assign var=hbCount value=0}
{foreach $s.items as $item}{if $item.quote !== ''}{assign var=hbCount value=$hbCount+1}{/if}{/foreach}
{if $hbCount > 0}
<section class="hp-testimonials-scroll">
    {if $s.title !== ''}<h2>{$s.title|escape}</h2>{/if}
    <div class="hp-testimonials-strip">
        {foreach $s.items as $item}
            {if $item.quote !== ''}
                <div class="hp-testi-slide">
                    {if $item.rating > 0}<div class="stars" role="img" aria-label="{$item.rating|escape} / 5">{for $hbStar=1 to $item.rating}&#9733;{/for}</div>{/if}
                    <div class="quote" style="color: var(--color-surface);">{$item.quote|escape|nl2br}</div>
                    {if $item.name !== '' || $item.role !== ''}
                        <div class="author">
                            {if $item.image !== ''}
                                <img class="author-avatar hb-media" src="{$item.image|escape}" alt="" loading="lazy" style="object-fit: cover;">
                            {elseif $item.name !== ''}
                                <div class="author-avatar" style="background-color: var(--color-accent);" aria-hidden="true">{$item.name|truncate:1:''|upper|escape}</div>
                            {/if}
                            <div>
                                {if $item.name !== ''}<div class="author-name" style="color: var(--color-surface);">{$item.name|escape}</div>{/if}
                                {if $item.role !== ''}<div class="author-role">{$item.role|escape}</div>{/if}
                            </div>
                        </div>
                    {/if}
                </div>
            {/if}
        {/foreach}
    </div>
    {if $hbCount > 1}
        <div class="carousel-scroll-nav">
            <button type="button" class="carousel-arrow prev"{if $s.prevLabel !== ''} aria-label="{$s.prevLabel|escape}"{/if}><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" aria-hidden="true"><polyline points="15 18 9 12 15 6"/></svg></button>
            <button type="button" class="carousel-arrow next"{if $s.nextLabel !== ''} aria-label="{$s.nextLabel|escape}"{/if}><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" aria-hidden="true"><polyline points="9 6 15 12 9 18"/></svg></button>
        </div>
    {/if}
</section>
{/if}
