{* A tile with no eyebrow, heading, text or image is skipped; a tile left on
   its own takes the full width. *}
{assign var=hbCount value=0}
{foreach $s.tiles as $tile}{if $tile.eyebrow !== '' || $tile.title !== '' || $tile.text !== '' || $tile.image !== ''}{assign var=hbCount value=$hbCount+1}{/if}{/foreach}
{if $hbCount > 0}
<section class="hp-tiles-hero-pair"{if $hbCount == 1} style="grid-template-columns: minmax(0, 1fr);"{/if}>
    {foreach $s.tiles as $tile}
        {if $tile.eyebrow !== '' || $tile.title !== '' || $tile.text !== '' || $tile.image !== ''}
            {* Both tile colours keep one background in light and dark mode, so
               the text colour is fixed here to match it. *}
            <div class="hp-hero-tile tile-{$tile.tone|escape}" style="color: {if $tile.tone == 'graphite'}#f5f5f7{else}#1d1d1f{/if};">
                {if $tile.eyebrow !== ''}<div class="ht-eyebrow">{$tile.eyebrow|escape}</div>{/if}
                {if $tile.title !== ''}<h2>{$tile.title|escape}</h2>{/if}
                {if $tile.text !== ''}<p>{$tile.text|escape|nl2br}</p>{/if}
                {if ($tile.primaryLabel !== '' && $tile.primaryLink !== '') || ($tile.secondaryLabel !== '' && $tile.secondaryLink !== '')}
                    <div class="ht-ctas">
                        {if $tile.primaryLabel !== '' && $tile.primaryLink !== ''}<a href="{$tile.primaryLink|escape}"{if $tile.tone != 'graphite'} style="color: #0066cc;"{/if}>{$tile.primaryLabel|escape} &rsaquo;</a>{/if}
                        {if $tile.secondaryLabel !== '' && $tile.secondaryLink !== ''}<a href="{$tile.secondaryLink|escape}"{if $tile.tone != 'graphite'} style="color: #0066cc;"{/if}>{$tile.secondaryLabel|escape} &rsaquo;</a>{/if}
                    </div>
                {/if}
                {if $tile.image !== ''}
                    <div class="ht-visual" style="opacity: 1;">
                        <img class="hb-media" src="{$tile.image|escape}" alt="{$tile.imageAlt|escape}" loading="lazy">
                    </div>
                {elseif $tile.iconSvg !== ''}
                    {* The icon is drawn on a 24px grid; the inner box scales it
                       to the 72px the outer box reserves. *}
                    <div class="ht-visual" aria-hidden="true">
                        <div style="width: 72px; height: 72px;"><div style="display: flex; width: 24px; height: 24px; transform: scale(3); transform-origin: 0 0;">{$tile.iconSvg nofilter}</div></div>
                    </div>
                {/if}
            </div>
        {/if}
    {/foreach}
</section>
{/if}
