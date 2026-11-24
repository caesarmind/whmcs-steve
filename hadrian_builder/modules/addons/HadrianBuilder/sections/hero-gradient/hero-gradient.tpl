{* A card with neither a title nor a line is skipped. *}
{assign var=hbCount value=0}
{foreach $s.cards as $card}{if $card.label !== '' || $card.sub !== ''}{assign var=hbCount value=$hbCount+1}{/if}{/foreach}
{if $s.title !== '' || $s.text !== '' || $hbCount > 0}
<section class="hp-hero-gradient {$s.colour|escape}">
    {if $s.title !== ''}<h1>{$s.title|escape}</h1>{/if}
    {if $s.text !== ''}<p class="hp-hero-sub">{$s.text|escape|nl2br}</p>{/if}
    {if $hbCount > 0}
        <div class="hp-floating-cards">
            {foreach $s.cards as $card}
                {if $card.label !== '' || $card.sub !== ''}
                    <div class="hp-floating-card">
                        {if $card.iconSvg !== ''}<div class="card-icon">{$card.iconSvg nofilter}</div>{/if}
                        {if $card.label !== ''}<div class="card-label">{$card.label|escape}</div>{/if}
                        {if $card.sub !== ''}<div class="card-sub">{$card.sub|escape}</div>{/if}
                    </div>
                {/if}
            {/foreach}
        </div>
    {/if}
</section>
{/if}
