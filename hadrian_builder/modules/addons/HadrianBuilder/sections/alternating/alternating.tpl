{if $s.rows}
<section class="hp-alternating">
    {foreach $s.rows as $row}
        <div class="hp-alt-row{if $row@iteration is even} reverse{/if}">
            <div class="hp-alt-text">
                {if $row.eyebrow !== ''}<div class="hp-eyebrow">{$row.eyebrow|escape}</div>{/if}
                {if $row.title !== ''}<h3>{$row.title|escape}</h3>{/if}
                {if $row.text !== ''}<p>{$row.text|escape|nl2br}</p>{/if}
            </div>
            <div class="hp-alt-visual">
                {if $row.image !== ''}
                    <img class="hb-media" src="{$row.image|escape}" alt="{$row.imageAlt|escape}" loading="lazy">
                {else}
                    <div class="visual-box{if $row.tone != 'plain'} {$row.tone|escape}{/if}" aria-hidden="true"></div>
                {/if}
            </div>
        </div>
    {/foreach}
</section>
{/if}
