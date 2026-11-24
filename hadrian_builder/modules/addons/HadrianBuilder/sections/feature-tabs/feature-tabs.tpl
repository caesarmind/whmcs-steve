{* The theme script pairs the nth .hp-ft-tab with the nth .hp-ft-panel, so a
   tab with no label is left out of both rows. The first one shown is open. *}
{assign var=hbCount value=0}
{foreach $s.tabs as $tab}{if $tab.label !== ''}{assign var=hbCount value=$hbCount+1}{/if}{/foreach}
{if $hbCount > 0}
<section class="hp-feature-tabs">
    {if $s.title !== ''}<h2>{$s.title|escape}</h2>{/if}
    {if $s.subtitle !== ''}<p class="feat-sub">{$s.subtitle|escape}</p>{/if}
    <div class="hp-ft-tabs">
        {assign var=hbSeen value=0}
        {foreach $s.tabs as $tab}
            {if $tab.label !== ''}
                {assign var=hbSeen value=$hbSeen+1}
                <button type="button" class="hp-ft-tab{if $hbSeen == 1} active{/if}">{$tab.label|escape}</button>
            {/if}
        {/foreach}
    </div>
    {assign var=hbSeen value=0}
    {foreach $s.tabs as $tab}
        {if $tab.label !== ''}
            {assign var=hbSeen value=$hbSeen+1}
            <div class="hp-ft-panel{if $hbSeen == 1} active{/if}">
                <div class="ft-text">
                    {if $tab.title !== ''}<h3>{$tab.title|escape}</h3>{/if}
                    {if $tab.text !== ''}<p>{$tab.text|escape|nl2br}</p>{/if}
                    {if $tab.pointsLines}
                        <ul class="ft-list">
                            {foreach $tab.pointsLines as $point}<li>{$point|escape}</li>{/foreach}
                        </ul>
                    {/if}
                </div>
                {if $tab.image !== ''}
                    <img class="hb-media" src="{$tab.image|escape}" alt="{$tab.imageAlt|escape}" loading="lazy">
                {else}
                    <div class="ft-visual" aria-hidden="true">
                        {if $tab.iconSvg !== ''}<span style="display: flex; transform: scale(4); color: var(--color-accent);">{$tab.iconSvg nofilter}</span>{/if}
                    </div>
                {/if}
            </div>
        {/if}
    {/foreach}
</section>
{/if}
