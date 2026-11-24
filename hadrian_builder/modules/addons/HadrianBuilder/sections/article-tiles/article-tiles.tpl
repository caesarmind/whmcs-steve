{* An article with no heading, text or image is skipped. The first one or two
   that are left go in the theme's two-column row as large tiles, the rest in
   its three-column row as compact ones; both rows wrap by themselves. *}
{assign var=hbCount value=0}
{foreach $s.items as $item}{if $item.title !== '' || $item.text !== '' || $item.image !== ''}{assign var=hbCount value=$hbCount+1}{/if}{/foreach}
{if $hbCount > 0}
<section class="hp-blog-tiles">
    {if $s.title !== '' || $s.subtitle !== '' || ($s.allLabel !== '' && $s.allLink !== '')}
        <div class="hp-blog-head">
            {if $s.title !== '' || $s.subtitle !== ''}
                <div>
                    {if $s.title !== ''}<h2>{$s.title|escape}</h2>{/if}
                    {if $s.subtitle !== ''}<p>{$s.subtitle|escape}</p>{/if}
                </div>
            {/if}
            {if $s.allLabel !== '' && $s.allLink !== ''}<a href="{$s.allLink|escape}" class="hp-blog-all-link">{$s.allLabel|escape} &rsaquo;</a>{/if}
        </div>
    {/if}
    <div class="hp-blog-inner">
        {assign var=hbLead value=$s.lead+0}
        {assign var=hbN value=0}
        {foreach $s.items as $item}
            {if $item.title !== '' || $item.text !== '' || $item.image !== ''}
                {assign var=hbN value=$hbN+1}
                {if $hbN == 1 && $hbLead > 0}
                    <div class="hp-blog-row"{if $hbLead == 1 || $hbCount == 1} style="grid-template-columns: minmax(0, 1fr);"{/if}>
                {/if}
                {if $hbN == $hbLead + 1}
                    <div class="hp-blog-row three">
                {/if}
                {* Plum keeps one background in light and dark mode, so its
                   text colour is fixed here to match it. *}
                <article class="hp-blog-card hp-tile-{$item.tone|escape}{if $hbN > $hbLead} compact{/if}"{if $item.tone == 'plum'} style="color: #f5f5f7;"{/if}>
                    {if $item.tag !== ''}
                        <div class="hp-blog-meta"><span class="hp-blog-cat{if $item.tone == 'dark'} blue{elseif $item.tone == 'cream'} green{elseif $item.tone == 'plum'} purple{/if}">{$item.tag|escape}</span></div>
                    {/if}
                    {if $item.title !== ''}<h3{if $hbN > $hbLead} class="smaller"{/if}>{$item.title|escape}</h3>{/if}
                    {if $item.text !== ''}<p>{$item.text|escape|nl2br}</p>{/if}
                    {if $item.image !== ''}
                        <div class="hp-blog-visual{if $hbN > $hbLead} compact{/if}">
                            <img class="hb-media" src="{$item.image|escape}" alt="{$item.imageAlt|escape}" loading="lazy">
                        </div>
                    {/if}
                    {if $item.date !== '' || ($item.link !== '' && $s.readLabel !== '')}
                        <div class="hp-blog-footer">
                            {if $item.date !== ''}<div class="hp-blog-author{if $hbN > $hbLead} compact{/if}"><div class="meta">{$item.date|escape}</div></div>{/if}
                            {if $item.link !== '' && $s.readLabel !== ''}<a href="{$item.link|escape}" class="hp-blog-read"{if $item.tone == 'dark'} style="color: var(--color-accent);"{elseif $item.tone == 'plum'} style="color: #cfb3ff;"{/if}>{$s.readLabel|escape} &rsaquo;</a>{/if}
                        </div>
                    {/if}
                </article>
                {if $hbN == $hbLead || $hbN == $hbCount}
                    </div>
                {/if}
            {/if}
        {/foreach}
    </div>
</section>
{/if}
