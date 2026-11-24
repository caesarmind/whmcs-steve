{* The theme script reads the dots and arrows from the markup and pairs the
   nth .carousel-dot with the nth card, so a quote left empty is skipped in
   both. With a single card there is nothing to slide to and no controls. *}
{assign var=hbCount value=0}
{foreach $s.items as $item}{if $item.quote !== ''}{assign var=hbCount value=$hbCount+1}{/if}{/foreach}
{if $hbCount > 0}
<section class="hp-testimonials-grid">
    {if $s.title !== ''}<h2>{$s.title|escape}</h2>{/if}
    <div class="hp-testimonial-cards">
        {foreach $s.items as $item}
            {if $item.quote !== ''}
                <div class="hp-testimonial-card">
                    {if $item.rating > 0}<div class="stars" role="img" aria-label="{$item.rating|escape} / 5">{for $hbStar=1 to $item.rating}&#9733;{/for}</div>{/if}
                    <div class="quote">{$item.quote|escape|nl2br}</div>
                    {if $item.name !== '' || $item.role !== ''}
                        <div class="author">
                            {if $item.image !== ''}
                                <img class="author-avatar hb-media" src="{$item.image|escape}" alt="" loading="lazy" style="object-fit: cover;">
                            {elseif $item.name !== ''}
                                <div class="author-avatar" aria-hidden="true">{$item.name|truncate:1:''|upper|escape}</div>
                            {/if}
                            <div>
                                {if $item.name !== ''}<div class="author-name">{$item.name|escape}</div>{/if}
                                {if $item.role !== ''}<div class="author-role">{$item.role|escape}</div>{/if}
                            </div>
                        </div>
                    {/if}
                </div>
            {/if}
        {/foreach}
    </div>
    {if $hbCount > 1}
        <div class="carousel-nav">
            <button type="button" class="carousel-arrow prev"{if $s.prevLabel !== ''} aria-label="{$s.prevLabel|escape}"{/if}><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" aria-hidden="true"><polyline points="15 18 9 12 15 6"/></svg></button>
            <div class="carousel-dots">
                {assign var=hbSeen value=0}
                {foreach $s.items as $item}
                    {if $item.quote !== ''}
                        {assign var=hbSeen value=$hbSeen+1}
                        <button type="button" class="carousel-dot{if $hbSeen == 1} active{/if}" aria-label="{$hbSeen|escape}"></button>
                    {/if}
                {/foreach}
            </div>
            <button type="button" class="carousel-arrow next"{if $s.nextLabel !== ''} aria-label="{$s.nextLabel|escape}"{/if}><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" aria-hidden="true"><polyline points="9 6 15 12 9 18"/></svg></button>
        </div>
    {/if}
</section>
{/if}
