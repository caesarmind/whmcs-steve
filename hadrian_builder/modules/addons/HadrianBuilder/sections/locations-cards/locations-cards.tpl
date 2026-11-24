{* A location with no name is skipped. Fewer than four cards are centred
   instead of leaving empty columns in the theme's four-column grid. *}
{assign var=hbCount value=0}
{foreach $s.items as $item}{if $item.name !== ''}{assign var=hbCount value=$hbCount+1}{/if}{/foreach}
{assign var=hbWidth value=$hbCount*260}
{if $hbCount > 0 || $s.title !== '' || $s.subtitle !== ''}
<section class="hp-locations-section">
    {if $s.title !== ''}<h2>{$s.title|escape}</h2>{/if}
    {if $s.subtitle !== ''}<p class="loc-sub">{$s.subtitle|escape}</p>{/if}
    {if $hbCount > 0}
        <div class="hp-loc-grid"{if $hbCount < 4} style="grid-template-columns: repeat(auto-fit, minmax(160px, 1fr)); max-width: {$hbWidth|escape}px;"{/if}>
            {foreach $s.items as $item}
                {if $item.name !== ''}
                    <div class="hp-loc-card">
                        {if $item.code !== ''}<div class="loc-flag">{$item.code|escape}</div>{/if}
                        <h4>{$item.name|escape}</h4>
                        {if $item.detail !== ''}<p>{$item.detail|escape}</p>{/if}
                    </div>
                {/if}
            {/foreach}
        </div>
    {/if}
</section>
{/if}
