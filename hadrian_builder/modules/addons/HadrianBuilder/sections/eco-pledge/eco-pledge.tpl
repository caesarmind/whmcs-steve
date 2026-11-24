{* A figure with neither a value nor a label is skipped. The theme styles
   value-link only inside a value card, so the link's look is set here from
   the theme's tokens. *}
{assign var=hbCount value=0}
{foreach $s.stats as $stat}{if $stat.value !== '' || $stat.label !== ''}{assign var=hbCount value=$hbCount+1}{/if}{/foreach}
{if $hbCount > 0 || $s.title !== '' || $s.text !== ''}
<section class="hp-eco-section">
    {if $s.image !== ''}
        <div><img class="hb-media" src="{$s.image|escape}" alt="{$s.imageAlt|escape}" loading="lazy"></div>
    {else}
        <div class="hp-eco-visual" aria-hidden="true"></div>
    {/if}
    <div class="hp-eco-text">
        {if $s.title !== ''}<h2>{$s.title|escape}</h2>{/if}
        {if $s.text !== ''}<p>{$s.text|escape|nl2br}</p>{/if}
        {if $hbCount > 0}
            <div class="hp-eco-stats">
                {foreach $s.stats as $stat}
                    {if $stat.value !== '' || $stat.label !== ''}
                        <div class="hp-eco-stat">
                            {if $stat.value !== ''}<div class="n">{$stat.value|escape}</div>{/if}
                            {if $stat.label !== ''}<div class="l">{$stat.label|escape}</div>{/if}
                        </div>
                    {/if}
                {/foreach}
            </div>
        {/if}
        {if $s.linkLabel !== '' && $s.link !== ''}
            <a href="{$s.link|escape}" class="value-link" style="color: var(--color-link); font-size: var(--text-lg); text-decoration: none;">{$s.linkLabel|escape} &rsaquo;</a>
        {/if}
    </div>
</section>
{/if}
