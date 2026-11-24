{* A card with no title and no text is skipped. *}
{assign var=hbCount value=0}
{foreach $s.items as $item}{if $item.title !== '' || $item.text !== ''}{assign var=hbCount value=$hbCount+1}{/if}{/foreach}
{if $hbCount > 0}
<section class="hp-bento-section">
    {if $s.title !== ''}<h2>{$s.title|escape}</h2>{/if}
    <div class="hp-bento-grid">
        {foreach $s.items as $item}
            {if $item.title !== '' || $item.text !== ''}
                <div class="hp-bento-card{if $item.size != 'normal'} {$item.size|escape}{/if}{if $item.tone != 'plain'} {$item.tone|escape}{/if}">
                    {if $item.iconSvg !== ''}<div class="bento-icon">{$item.iconSvg nofilter}</div>{/if}
                    {if $item.title !== ''}<h4>{$item.title|escape}</h4>{/if}
                    {if $item.text !== ''}<p>{$item.text|escape|nl2br}</p>{/if}
                    {if $item.stat1Value !== '' || $item.stat2Value !== '' || $item.stat3Value !== ''}
                        <div class="bento-stat-bar">
                            {if $item.stat1Value !== ''}<div class="bento-stat"><div class="n">{$item.stat1Value|escape}</div>{if $item.stat1Label !== ''}<div class="l">{$item.stat1Label|escape}</div>{/if}</div>{/if}
                            {if $item.stat2Value !== ''}<div class="bento-stat"><div class="n">{$item.stat2Value|escape}</div>{if $item.stat2Label !== ''}<div class="l">{$item.stat2Label|escape}</div>{/if}</div>{/if}
                            {if $item.stat3Value !== ''}<div class="bento-stat"><div class="n">{$item.stat3Value|escape}</div>{if $item.stat3Label !== ''}<div class="l">{$item.stat3Label|escape}</div>{/if}</div>{/if}
                        </div>
                    {/if}
                    {assign var=hbTags value=0}
                    {foreach $item.tagsLines as $tag}{assign var=hbTags value=$hbTags+1}{/foreach}
                    {if $hbTags == 1}
                        {foreach $item.tagsLines as $tag}<div class="bento-tag{if $item.tagStyle == 'muted'} muted{/if}">{$tag|escape}</div>{/foreach}
                    {elseif $hbTags > 1}
                        <div class="bento-row-tags">
                            {foreach $item.tagsLines as $tag}<span class="bento-tag{if $item.tagStyle == 'muted'} muted{/if}">{$tag|escape}</span>{/foreach}
                        </div>
                    {/if}
                    {if $item.chart}
                        <div class="bento-mini-chart" aria-hidden="true"><span></span><span></span><span></span><span></span><span></span><span></span><span></span><span></span></div>
                    {/if}
                </div>
            {/if}
        {/foreach}
    </div>
</section>
{/if}
