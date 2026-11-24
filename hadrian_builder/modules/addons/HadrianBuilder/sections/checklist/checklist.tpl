{* An item with no title and no text is skipped. *}
{assign var=hbCount value=0}
{foreach $s.items as $item}{if $item.title !== '' || $item.text !== ''}{assign var=hbCount value=$hbCount+1}{/if}{/foreach}
{if $hbCount > 0}
<section class="hp-features-checklist">
    {if $s.title !== ''}<h2>{$s.title|escape}</h2>{/if}
    {if $s.subtitle !== ''}<p class="feat-sub">{$s.subtitle|escape}</p>{/if}
    <div class="hp-checklist-grid">
        {foreach $s.items as $item}
            {if $item.title !== '' || $item.text !== ''}
                <div class="hp-check-item">
                    <div class="check-icon" aria-hidden="true">&#10003;</div>
                    <div class="check-text">
                        {if $item.title !== ''}<h4>{$item.title|escape}</h4>{/if}
                        {if $item.text !== ''}<p>{$item.text|escape}</p>{/if}
                    </div>
                </div>
            {/if}
        {/foreach}
    </div>
</section>
{/if}
