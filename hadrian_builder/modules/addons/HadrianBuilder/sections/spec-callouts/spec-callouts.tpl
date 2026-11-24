{* Even rows are reversed: the theme gives them the wide column on the right, so
   the copy is printed first there. The small square in the badge takes the
   badge's own text colour, which the theme sets for both colours and modes. *}
{assign var=hbCount value=0}
{foreach $s.rows as $row}{if $row.badge !== '' || $row.lead !== '' || $row.text !== '' || $row.metaTitle !== '' || $row.metaText !== '' || $row.image !== ''}{assign var=hbCount value=$hbCount+1}{/if}{/foreach}
{if $hbCount > 0}
<section class="hp-chip-spec">
    {assign var=hbAt value=0}
    {foreach $s.rows as $row}
        {if $row.badge !== '' || $row.lead !== '' || $row.text !== '' || $row.metaTitle !== '' || $row.metaText !== '' || $row.image !== ''}
            {assign var=hbAt value=$hbAt+1}
            {capture assign=hbVisual}
                {if $row.image !== ''}
                    <div class="hp-chip-visual"><img class="hb-media" style="border-radius: 0;" src="{$row.image|escape}" alt="{$row.imageAlt|escape}" loading="lazy"></div>
                {else}
                    <div class="hp-chip-visual" aria-hidden="true"></div>
                {/if}
            {/capture}
            <div class="hp-chip-row{if $hbAt is even} reverse{/if}">
                {if $hbAt is odd}{$hbVisual nofilter}{/if}
                <div class="hp-chip-copy">
                    {if $row.badge !== ''}
                        <div class="chip-badge{if $row.tone == 'blue'} pro{/if}"><span style="display: inline-block; width: 12px; height: 12px; border-radius: 3px; background: currentColor;" aria-hidden="true"></span> {$row.badge|escape}</div>
                    {/if}
                    {if $row.lead !== '' || $row.text !== ''}
                        <p class="chip-lead">{if $row.lead !== ''}<strong>{$row.lead|escape}</strong> {/if}{$row.text|escape|nl2br}</p>
                    {/if}
                    {if $row.metaTitle !== '' || $row.metaText !== ''}
                        <div class="chip-meta">{if $row.metaTitle !== ''}<strong>{$row.metaTitle|escape}</strong>{/if}{$row.metaText|escape}</div>
                    {/if}
                </div>
                {if $hbAt is even}{$hbVisual nofilter}{/if}
            </div>
        {/if}
    {/foreach}
</section>
{/if}
