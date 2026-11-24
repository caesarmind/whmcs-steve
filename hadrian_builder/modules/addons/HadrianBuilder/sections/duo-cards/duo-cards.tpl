{* The picture leans left in odd cards and right in even ones. The theme has no
   panel for a card without a picture, so the stand-in below carries its own
   few styles; grey at low opacity reads on the card in light and dark mode. *}
{assign var=hbCount value=0}
{foreach $s.cards as $card}{if $card.lead !== '' || $card.text !== '' || $card.image !== ''}{assign var=hbCount value=$hbCount+1}{/if}{/foreach}
{if $hbCount > 0}
<section class="hp-duo-feature"{if $hbCount == 1} style="grid-template-columns: minmax(0, 1fr);"{/if}>
    {assign var=hbAt value=0}
    {foreach $s.cards as $card}
        {if $card.lead !== '' || $card.text !== '' || $card.image !== ''}
            {assign var=hbAt value=$hbAt+1}
            <div class="hp-duo-card">
                {if $card.lead !== '' || $card.text !== ''}
                    <p class="duo-text">{if $card.lead !== ''}<strong>{$card.lead|escape}</strong> {/if}{$card.text|escape|nl2br}</p>
                {/if}
                {if $card.image !== ''}
                    <div class="duo-visual {if $hbAt is odd}duo-visual--left{else}duo-visual--right{/if}">
                        <img class="hb-media" style="border-radius: 14px 14px 0 0;" src="{$card.image|escape}" alt="{$card.imageAlt|escape}" loading="lazy">
                    </div>
                {else}
                    <div class="duo-visual {if $hbAt is odd}duo-visual--left{else}duo-visual--right{/if}" aria-hidden="true">
                        <div style="flex: none; width: 120%; height: 260px; border-radius: 14px 14px 0 0; background: rgba(128, 128, 128, 0.22);"></div>
                    </div>
                {/if}
            </div>
        {/if}
    {/foreach}
</section>
{/if}
