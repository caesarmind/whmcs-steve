{* With no image the theme's .spotlight-visual panel shows the icon. The theme
   stretches an svg in that panel to its full width, so the icon sits in a
   narrower box. *}
{assign var=hbStats value=0}
{foreach $s.stats as $stat}{if $stat.value !== ''}{assign var=hbStats value=$hbStats+1}{/if}{/foreach}
{if $s.title !== '' || $s.text !== ''}
<section class="hp-feature-spotlight">
    <div class="spotlight-inner">
        <div class="spotlight-text">
            {if $s.eyebrow !== ''}<div class="hp-eyebrow">{$s.eyebrow|escape}</div>{/if}
            {if $s.title !== ''}<h3>{$s.title|escape}</h3>{/if}
            {if $s.text !== ''}<p>{$s.text|escape|nl2br}</p>{/if}
            {if $hbStats > 0}
                <div class="spotlight-stats">
                    {foreach $s.stats as $stat}
                        {if $stat.value !== ''}
                            <div class="sp-stat">
                                <div class="num">{$stat.value|escape}</div>
                                {if $stat.label !== ''}<div class="label">{$stat.label|escape}</div>{/if}
                            </div>
                        {/if}
                    {/foreach}
                </div>
            {/if}
        </div>
        {if $s.image !== ''}
            <img class="hb-media" src="{$s.image|escape}" alt="{$s.imageAlt|escape}" loading="lazy">
        {else}
            <div class="spotlight-visual" aria-hidden="true">
                {if $s.iconSvg !== ''}<div style="display: flex; width: 45%; max-width: 160px; color: var(--color-accent);">{$s.iconSvg nofilter}</div>{/if}
            </div>
        {/if}
    </div>
</section>
{/if}
