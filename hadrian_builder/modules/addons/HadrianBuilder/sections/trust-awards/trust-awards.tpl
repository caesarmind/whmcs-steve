{* An entry with neither text nor an attribution is skipped. The stars are
   the plain star character, written as an entity to keep this file ASCII.
   The theme has no rule for the attribution, so it is set lighter and
   smaller here from the theme's tokens. *}
{assign var=hbCount value=0}
{foreach $s.items as $item}{if $item.text !== '' || $item.source !== ''}{assign var=hbCount value=$hbCount+1}{/if}{/foreach}
{if $hbCount > 0}
<section class="hp-trust-awards">
    {if $s.label !== ''}<div class="award-label">{$s.label|escape}</div>{/if}
    <div class="hp-awards-row">
        {foreach $s.items as $item}
            {if $item.text !== '' || $item.source !== ''}
                <div class="hp-award gtm">
                    {if $item.stars > 0}<span class="stars-sm" aria-hidden="true">{for $hbStar=1 to $item.stars}&#9733;{/for}</span>{/if}
                    {if $item.text !== ''}<span>{$item.text|escape}</span>{/if}
                    {if $item.source !== ''}<span style="font-size: var(--text-md); font-weight: var(--fw-normal);">{$item.source|escape}</span>{/if}
                </div>
            {/if}
        {/foreach}
    </div>
</section>
{/if}
