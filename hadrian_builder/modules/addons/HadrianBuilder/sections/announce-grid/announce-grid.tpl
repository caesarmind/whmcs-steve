{* Cards are WHMCS announcements, which have a title, a date and a body and
   nothing else. With none published the section prints nothing. The whole
   card is the link, as on the theme's own home page, and one or two cards
   fill the row (the theme's count-1 and count-2). *}
{assign var=hbCount value=0}
{foreach $data.announcements as $item}{if $item.title !== ''}{assign var=hbCount value=$hbCount+1}{/if}{/foreach}
{if $hbCount > 0}
<section class="hp-announce-grid">
    {if $s.title !== '' || $s.subtitle !== '' || ($s.viewAllLabel !== '' && $s.viewAllLink !== '')}
        <div class="hp-announce-grid-header">
            <div>
                {if $s.title !== ''}<h2>{$s.title|escape}</h2>{/if}
                {if $s.subtitle !== ''}<p>{$s.subtitle|escape}</p>{/if}
            </div>
            {if $s.viewAllLabel !== '' && $s.viewAllLink !== ''}<a href="{$s.viewAllLink|escape}" class="announce-view-all">{$s.viewAllLabel|escape} &rsaquo;</a>{/if}
        </div>
    {/if}
    <div class="hp-announce-cards{if $hbCount == 1} count-1{elseif $hbCount == 2} count-2{/if}">
        {foreach $data.announcements as $item}
            {if $item.title !== ''}
                <a href="{$item.url|escape}" class="hp-announce-item-card">
                    <h3>{$item.title|escape}</h3>
                    {if $item.text !== ''}<p>{$item.text|escape}</p>{/if}
                    <div class="announce-foot">
                        <time datetime="{$item.dateIso|escape}">{$item.date|escape}</time>
                        {if $s.readLabel !== ''}<span class="announce-read">{$s.readLabel|escape} &rsaquo;</span>{/if}
                    </div>
                </a>
            {/if}
        {/foreach}
    </div>
</section>
{/if}
