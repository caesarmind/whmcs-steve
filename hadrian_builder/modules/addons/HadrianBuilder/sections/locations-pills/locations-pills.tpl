{* A location with no name is skipped. *}
{assign var=hbCount value=0}
{foreach $s.items as $item}{if $item.name !== ''}{assign var=hbCount value=$hbCount+1}{/if}{/foreach}
{if $hbCount > 0 || $s.title !== '' || $s.subtitle !== ''}
<section class="hp-locations-compact">
    {if $s.title !== ''}<h2>{$s.title|escape}</h2>{/if}
    {if $s.subtitle !== ''}<p class="loc-sub">{$s.subtitle|escape}</p>{/if}
    {if $hbCount > 0}
        <div class="loc-pills">
            {foreach $s.items as $item}
                {if $item.name !== ''}
                    <span class="loc-pill">{if $item.code !== ''}<span class="flag">{$item.code|escape}</span> {/if}{$item.name|escape}</span>
                {/if}
            {/foreach}
        </div>
    {/if}
</section>
{/if}
