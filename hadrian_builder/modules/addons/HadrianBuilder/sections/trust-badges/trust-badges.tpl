{* A badge with neither a code nor a label is skipped. Fewer than six badges
   are centred instead of leaving empty columns in the theme's six-column
   grid. *}
{assign var=hbCount value=0}
{foreach $s.items as $item}{if $item.code !== '' || $item.label !== ''}{assign var=hbCount value=$hbCount+1}{/if}{/foreach}
{assign var=hbWidth value=$hbCount*170}
{if $hbCount > 0 || $s.title !== '' || $s.subtitle !== ''}
<section class="hp-trust-badges">
    {if $s.title !== ''}<h2>{$s.title|escape}</h2>{/if}
    {if $s.subtitle !== ''}<p class="sub">{$s.subtitle|escape}</p>{/if}
    {if $hbCount > 0}
        <div class="hp-badges-grid"{if $hbCount < 6} style="grid-template-columns: repeat(auto-fit, minmax(120px, 1fr)); max-width: {$hbWidth|escape}px; margin-inline: auto;"{/if}>
            {foreach $s.items as $item}
                {if $item.code !== '' || $item.label !== ''}
                    <div class="hp-badge">
                        {if $item.code !== ''}<div class="ic">{$item.code|escape}</div>{/if}
                        {if $item.label !== ''}<div class="name">{$item.label|escape}</div>{/if}
                    </div>
                {/if}
            {/foreach}
        </div>
    {/if}
</section>
{/if}
