{* A figure with neither a value nor a label is skipped. *}
{assign var=hbCount value=0}
{foreach $s.stats as $stat}{if $stat.value !== '' || $stat.label !== ''}{assign var=hbCount value=$hbCount+1}{/if}{/foreach}
{if $hbCount > 0 || $s.regionsLines || $s.title !== '' || $s.subtitle !== ''}
<section class="hp-locations-visual">
    {if $s.title !== ''}<h2>{$s.title|escape}</h2>{/if}
    {if $s.subtitle !== ''}<p class="loc-sub">{$s.subtitle|escape}</p>{/if}
    {if $s.regionsLines}
        <div class="loc-map-dots">
            {foreach $s.regionsLines as $region}
                <span class="hp-loc-dot"><span class="dot"></span> {$region|escape}</span>
            {/foreach}
        </div>
    {/if}
    {if $hbCount > 0}
        <div class="loc-stats-row">
            {foreach $s.stats as $stat}
                {if $stat.value !== '' || $stat.label !== ''}
                    <div class="loc-stat">
                        {if $stat.value !== ''}<div class="num">{$stat.value|escape}</div>{/if}
                        {if $stat.label !== ''}<div class="label">{$stat.label|escape}</div>{/if}
                    </div>
                {/if}
            {/foreach}
        </div>
    {/if}
</section>
{/if}
