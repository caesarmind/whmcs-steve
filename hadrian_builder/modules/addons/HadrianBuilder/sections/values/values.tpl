{* A value with neither a title nor a text is skipped. *}
{assign var=hbCount value=0}
{foreach $s.items as $item}{if $item.title !== '' || $item.text !== ''}{assign var=hbCount value=$hbCount+1}{/if}{/foreach}
{if $hbCount > 0 || $s.title !== ''}
<section class="hp-values-section">
    {if $s.title !== ''}<h2>{$s.title|escape}</h2>{/if}
    {if $hbCount > 0}
        <div class="hp-values-grid">
            {foreach $s.items as $item}
                {if $item.title !== '' || $item.text !== ''}
                    <div class="hp-value-item">
                        {if $item.iconSvg !== ''}<div class="value-icon">{$item.iconSvg nofilter}</div>{/if}
                        {if $item.title !== ''}<h3>{$item.title|escape}</h3>{/if}
                        {if $item.text !== ''}<p>{$item.text|escape|nl2br}</p>{/if}
                        {if $item.linkLabel !== '' && $item.link !== ''}<a href="{$item.link|escape}" class="value-link">{$item.linkLabel|escape} &rsaquo;</a>{/if}
                    </div>
                {/if}
            {/foreach}
        </div>
    {/if}
</section>
{/if}
