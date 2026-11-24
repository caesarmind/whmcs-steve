{if $s.items || $s.title !== ''}
<section class="hp-features-section">
    {if $s.title !== ''}<h2>{$s.title|escape}</h2>{/if}
    {if $s.subtitle !== ''}<p class="feat-sub">{$s.subtitle|escape}</p>{/if}
    {if $s.items}
        <div class="hp-feature-cards{if $s.columns != '3'} cols-{$s.columns|escape}{/if}">
            {foreach $s.items as $item}
                <div class="hp-feature-card">
                    {if $item.iconSvg !== ''}<div class="feat-icon {$item.colour|escape}">{$item.iconSvg nofilter}</div>{/if}
                    {if $item.title !== ''}<h4>{$item.title|escape}</h4>{/if}
                    {if $item.text !== ''}<p>{$item.text|escape|nl2br}</p>{/if}
                </div>
            {/foreach}
        </div>
    {/if}
</section>
{/if}
