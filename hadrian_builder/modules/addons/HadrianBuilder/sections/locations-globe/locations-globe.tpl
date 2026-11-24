{* A figure with neither a value nor a label is skipped. The globe is
   decoration and is drawn whenever the section has anything to show. *}
{assign var=hbCount value=0}
{foreach $s.stats as $stat}{if $stat.value !== '' || $stat.label !== ''}{assign var=hbCount value=$hbCount+1}{/if}{/foreach}
{if $hbCount > 0 || $s.title !== '' || $s.subtitle !== ''}
<section class="hp-locations-globe">
    {if $s.title !== ''}<h2>{$s.title|escape}</h2>{/if}
    {if $s.subtitle !== ''}<p class="sub">{$s.subtitle|escape}</p>{/if}
    <div class="hp-globe-wrap" aria-hidden="true"><div class="hp-globe-sphere"></div></div>
    {if $hbCount > 0}
        <div class="hp-globe-stats">
            {foreach $s.stats as $stat}
                {if $stat.value !== '' || $stat.label !== ''}
                    <div class="hp-globe-stat">
                        {if $stat.value !== ''}<div class="n">{$stat.value|escape}</div>{/if}
                        {if $stat.label !== ''}<div class="l">{$stat.label|escape}</div>{/if}
                    </div>
                {/if}
            {/foreach}
        </div>
    {/if}
</section>
{/if}
