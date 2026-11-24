{if $s.items}
<section class="hp-faq-section">
    {if $s.title !== ''}<h2>{$s.title|escape}</h2>{/if}
    {if $s.subtitle !== ''}<p class="faq-sub">{$s.subtitle|escape}</p>{/if}
    {foreach $s.items as $item}
        {if $item.question !== ''}
            <details class="hp-faq-item"{if $s.openFirst && $item@first} open{/if}>
                <summary>{$item.question|escape}</summary>
                <div class="faq-body">{$item.answer nofilter}</div>
            </details>
        {/if}
    {/foreach}
</section>
{/if}
