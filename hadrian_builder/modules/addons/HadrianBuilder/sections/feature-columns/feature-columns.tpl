{* A column with no title and no text is skipped, and the numbers stay in order. *}
{assign var=hbCount value=0}
{foreach $s.items as $item}{if $item.title !== '' || $item.text !== ''}{assign var=hbCount value=$hbCount+1}{/if}{/foreach}
{if $hbCount > 0}
<section class="hp-feature-columns">
    {if $s.title !== ''}<h2>{$s.title|escape}</h2>{/if}
    {if $s.subtitle !== ''}<p class="feat-sub">{$s.subtitle|escape}</p>{/if}
    <div class="hp-columns-row">
        {assign var=hbNum value=0}
        {foreach $s.items as $item}
            {if $item.title !== '' || $item.text !== ''}
                {assign var=hbNum value=$hbNum+1}
                <div class="hp-column-item">
                    {if $s.numbered || $item.label !== ''}
                        <div class="col-num">{if $s.numbered}0{$hbNum|escape}{/if}{if $s.numbered && $item.label !== ''} &middot; {/if}{$item.label|escape}</div>
                    {/if}
                    {if $item.title !== ''}<h4>{$item.title|escape}</h4>{/if}
                    {if $item.text !== ''}<p>{$item.text|escape|nl2br}</p>{/if}
                    {if $item.linkLabel !== '' && $item.link !== ''}<a href="{$item.link|escape}" class="col-link">{$item.linkLabel|escape} &rsaquo;</a>{/if}
                </div>
            {/if}
        {/foreach}
    </div>
</section>
{/if}
