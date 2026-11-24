{* Items are WHMCS announcements, which have a title, a date and a body and
   nothing else. With none published the section prints nothing.

   The rail on the left shows the day and a short month name, both taken
   from the ISO date (the month name from the "Month names" field, so it can
   be translated). It is decoration: the date a visitor and a screen reader
   get is the <time> line, in the date format set in WHMCS. *}
{assign var=hbCount value=0}
{foreach $data.announcements as $item}{if $item.title !== ''}{assign var=hbCount value=$hbCount+1}{/if}{/foreach}
{if $hbCount > 0}
<section class="hp-announce-list">
    {if $s.title !== '' || $s.subtitle !== ''}
        <div class="hp-announce-list-header">
            {if $s.title !== ''}<h2>{$s.title|escape}</h2>{/if}
            {if $s.subtitle !== ''}<p>{$s.subtitle|escape}</p>{/if}
        </div>
    {/if}
    <div class="hp-announce-list-items">
        {foreach $data.announcements as $item}
            {if $item.title !== ''}
                {assign var=hbDay value=$item.dateIso|regex_replace:'/^\d+-\d+-/':''}
                {assign var=hbMonthNo value=$item.dateIso|regex_replace:'/^\d+-0?(\d+)-\d+$/':'$1'}
                {assign var=hbMonth value=''}
                {foreach $s.monthsLines as $name}{if $name@iteration == $hbMonthNo}{assign var=hbMonth value=$name}{/if}{/foreach}
                <article class="hp-announce-item">
                    <div class="announce-item-date" aria-hidden="true">
                        <div class="day">{$hbDay|escape}</div>
                        {if $hbMonth !== ''}<div class="month">{$hbMonth|escape}</div>{/if}
                    </div>
                    <div class="announce-item-body">
                        <div class="announce-item-meta"><time datetime="{$item.dateIso|escape}">{$item.date|escape}</time></div>
                        {if $s.readLabel !== ''}
                            <h3>{$item.title|escape}</h3>
                        {else}
                            <h3><a href="{$item.url|escape}" style="color: inherit; text-decoration: none;">{$item.title|escape}</a></h3>
                        {/if}
                        {if $item.text !== ''}<p>{$item.text|escape}</p>{/if}
                        {if $s.readLabel !== ''}<a href="{$item.url|escape}" class="announce-read">{$s.readLabel|escape} &rsaquo;</a>{/if}
                    </div>
                </article>
            {/if}
        {/foreach}
    </div>
    {if $s.viewAllLabel !== '' && $s.viewAllLink !== ''}<a href="{$s.viewAllLink|escape}" class="announce-view-all-btn">{$s.viewAllLabel|escape} &rsaquo;</a>{/if}
</section>
{/if}
