{* A number with neither a figure nor a caption is skipped. The figure takes
   the band's own text colour: the theme gives it the colour of the band's
   background, which hides it. *}
{assign var=hbCount value=0}
{foreach $s.stats as $stat}{if $stat.value !== '' || $stat.label !== ''}{assign var=hbCount value=$hbCount+1}{/if}{/foreach}
{if $s.title !== '' || $s.text !== '' || $hbCount > 0}
<section class="hp-hero-dark">
    {if $s.title !== ''}<h1>{$s.title|escape}</h1>{/if}
    {if $s.text !== ''}<p class="hp-hero-sub">{$s.text|escape|nl2br}</p>{/if}
    {if $hbCount > 0}
        <div class="hp-hero-stats">
            {foreach $s.stats as $stat}
                {if $stat.value !== '' || $stat.label !== ''}
                    <div class="hp-hero-stat">
                        {if $stat.value !== ''}<div class="stat-num" style="color: inherit;">{$stat.value|escape}</div>{/if}
                        {if $stat.label !== ''}<div class="stat-label">{$stat.label|escape}</div>{/if}
                    </div>
                {/if}
            {/foreach}
        </div>
    {/if}
</section>
{/if}
