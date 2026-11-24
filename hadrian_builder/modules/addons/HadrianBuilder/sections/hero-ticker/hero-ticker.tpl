{* The theme's animation slides the line by half its width, so the phrases
   are printed twice. The second copy is hidden from screen readers. *}
{assign var=hbCount value=0}
{foreach $s.items as $item}{if $item.text !== ''}{assign var=hbCount value=$hbCount+1}{/if}{/foreach}
{if $s.title !== '' || $s.text !== '' || $hbCount > 0}
<section class="hp-hero-ticker">
    {if $s.title !== ''}<h1>{$s.title|escape}</h1>{/if}
    {if $s.text !== ''}<p class="ticker-sub">{$s.text|escape|nl2br}</p>{/if}
    {if $hbCount > 0}
        <div class="hp-ticker-track">
            {foreach $s.items as $item}
                {if $item.text !== ''}<span{if $item.accent} class="accent"{/if}>{$item.text|escape}</span><span class="accent" aria-hidden="true">&middot;</span>{/if}
            {/foreach}
            {foreach $s.items as $item}
                {if $item.text !== ''}<span{if $item.accent} class="accent"{/if} aria-hidden="true">{$item.text|escape}</span><span class="accent" aria-hidden="true">&middot;</span>{/if}
            {/foreach}
        </div>
    {/if}
</section>
{/if}
