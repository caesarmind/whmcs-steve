{* A tile with no eyebrow, heading, text or image is skipped. In the plain
   layout the tiles are wrapped two to a row; in the other two the theme lays
   them out three across by itself. *}
{assign var=hbCount value=0}
{foreach $s.tiles as $tile}{if $tile.eyebrow !== '' || $tile.title !== '' || $tile.text !== '' || $tile.image !== ''}{assign var=hbCount value=$hbCount+1}{/if}{/foreach}
{if $hbCount > 0}
<section class="hp-tiles-section{if $s.layout != 'rows'} {$s.layout|escape}{/if}">
    <div class="hp-tiles-inner">
        {assign var=hbN value=0}
        {foreach $s.tiles as $tile}
            {if $tile.eyebrow !== '' || $tile.title !== '' || $tile.text !== '' || $tile.image !== ''}
                {assign var=hbN value=$hbN+1}
                {* Sky, plum and graphite keep one background in light and dark
                   mode, so their text colour is fixed here to match it. The
                   eyebrow and link colours follow the tile colour. *}
                {assign var=hbInk value=''}
                {assign var=hbAccent value=''}
                {assign var=hbLink value=''}
                {if $tile.tone == 'light'}
                    {assign var=hbAccent value='var(--color-accent)'}
                {elseif $tile.tone == 'dark'}
                    {assign var=hbAccent value='var(--color-accent)'}
                    {assign var=hbLink value='var(--color-accent)'}
                {elseif $tile.tone == 'cream'}
                    {assign var=hbAccent value='var(--color-green-text)'}
                {elseif $tile.tone == 'sky'}
                    {assign var=hbInk value='#1d1d1f'}
                    {assign var=hbLink value='#0066cc'}
                {elseif $tile.tone == 'plum'}
                    {assign var=hbInk value='#f5f5f7'}
                    {assign var=hbAccent value='#bf96ff'}
                    {assign var=hbLink value='#bf96ff'}
                {elseif $tile.tone == 'graphite'}
                    {assign var=hbInk value='#f5f5f7'}
                    {assign var=hbAccent value='#ffd60a'}
                    {assign var=hbLink value='#ffd60a'}
                {/if}
                {if $s.layout == 'rows' && $hbN % 2 == 1}
                    <div class="hp-tiles-row"{if $hbN == $hbCount} style="grid-template-columns: minmax(0, 1fr);"{/if}>
                {/if}
                <div class="hp-tile hp-tile-{$tile.tone|escape}{if $s.layout == 'rows' && $hbN <= 2} tall{/if}"{if $hbInk !== ''} style="color: {$hbInk|escape};"{/if}>
                    {if $tile.eyebrow !== ''}<div class="hp-tile-eyebrow"{if $hbAccent !== ''} style="color: {$hbAccent|escape};"{/if}>{$tile.eyebrow|escape}</div>{/if}
                    {if $tile.title !== ''}<h2{if $s.layout == 'rows' && $hbN > 2} class="smaller"{/if}>{$tile.title|escape}</h2>{/if}
                    {if $tile.text !== ''}<p>{$tile.text|escape|nl2br}</p>{/if}
                    {if ($tile.primaryLabel !== '' && $tile.primaryLink !== '') || ($tile.secondaryLabel !== '' && $tile.secondaryLink !== '')}
                        <div class="hp-tile-links">
                            {if $tile.primaryLabel !== '' && $tile.primaryLink !== ''}<a href="{$tile.primaryLink|escape}"{if $hbLink !== ''} style="color: {$hbLink|escape};"{else} class="blue"{/if}>{$tile.primaryLabel|escape} &rsaquo;</a>{/if}
                            {if $tile.secondaryLabel !== '' && $tile.secondaryLink !== ''}<a href="{$tile.secondaryLink|escape}"{if $hbLink !== ''} style="color: {$hbLink|escape};"{else} class="blue"{/if}>{$tile.secondaryLabel|escape} &rsaquo;</a>{/if}
                        </div>
                    {/if}
                    {if $tile.image !== ''}
                        <div class="hp-tile-visual">
                            <img class="hb-media" src="{$tile.image|escape}" alt="{$tile.imageAlt|escape}" loading="lazy"{if $s.layout == 'rich'} style="max-height: 160px; width: auto;"{/if}>
                        </div>
                    {/if}
                </div>
                {if $s.layout == 'rows' && ($hbN % 2 == 0 || $hbN == $hbCount)}
                    </div>
                {/if}
            {/if}
        {/foreach}
    </div>
</section>
{/if}
