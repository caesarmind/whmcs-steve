{* The theme has no size for an icon in .strip-visual, so the icon is scaled
   up here inside a box that keeps room for it. *}
{assign var=hbCount value=0}
{foreach $s.cards as $card}{if $card.title !== '' || $card.text !== ''}{assign var=hbCount value=$hbCount+1}{/if}{/foreach}
{if $hbCount > 0}
<section class="hp-strip-section">
    {if $s.title !== ''}
        <div class="hp-strip-header"><h2>{$s.title|escape}</h2></div>
    {/if}
    <div class="hp-strip-scroll">
        {foreach $s.cards as $card}
            {if $card.title !== '' || $card.text !== ''}
                <div class="hp-strip-card {$card.tone|escape}">
                    {if $card.tag !== ''}<div class="tag">{$card.tag|escape}</div>{/if}
                    {if $card.title !== ''}<h3>{$card.title|escape}</h3>{/if}
                    {if $card.text !== ''}<p>{$card.text|escape|nl2br}</p>{/if}
                    {if $card.iconSvg !== ''}
                        <div class="strip-visual" aria-hidden="true">
                            <span style="display: flex; align-items: center; justify-content: center; width: 72px; height: 72px;"><span style="display: flex; transform: scale(3);">{$card.iconSvg nofilter}</span></span>
                        </div>
                    {/if}
                </div>
            {/if}
        {/foreach}
    </div>
</section>
{/if}
