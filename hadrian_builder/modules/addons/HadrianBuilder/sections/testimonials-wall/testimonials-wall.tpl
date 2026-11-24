{* A quote left empty is skipped. The theme has no letter style for the
   tile's .avatar, so the circle shows only when there is a photo. *}
{assign var=hbCount value=0}
{foreach $s.items as $item}{if $item.quote !== ''}{assign var=hbCount value=$hbCount+1}{/if}{/foreach}
{if $hbCount > 0}
<section class="hp-testi-masonry">
    {if $s.title !== ''}<h2>{$s.title|escape}</h2>{/if}
    {if $s.subtitle !== ''}<p class="hp-testi-masonry-sub">{$s.subtitle|escape}</p>{/if}
    <div class="hp-testi-masonry-grid">
        {foreach $s.items as $item}
            {if $item.quote !== ''}
                <div class="hp-testi-tile{if $item.tall} tall{/if}{if $item.tone != 'plain'} {$item.tone|escape}{/if}">
                    {if $item.rating > 0}<div class="stars" role="img" aria-label="{$item.rating|escape} / 5">{for $hbStar=1 to $item.rating}&#9733;{/for}</div>{/if}
                    <p class="quote">{$item.quote|escape|nl2br}</p>
                    {if $item.name !== '' || $item.role !== ''}
                        <div class="author">
                            {if $item.image !== ''}<img class="avatar hb-media" src="{$item.image|escape}" alt="" loading="lazy" style="object-fit: cover;">{/if}
                            <div>
                                {if $item.name !== ''}<div class="name">{$item.name|escape}</div>{/if}
                                {if $item.role !== ''}<div class="role">{$item.role|escape}</div>{/if}
                            </div>
                        </div>
                    {/if}
                </div>
            {/if}
        {/foreach}
    </div>
</section>
{/if}
