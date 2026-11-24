{* The large tile prints when it has an eyebrow, a heading, text or an image;
   a small tile when it has an eyebrow, a heading or text. Whichever side is
   left on its own takes the full width. *}
{assign var=hbBig value=false}
{if $s.eyebrow !== '' || $s.title !== '' || $s.text !== '' || $s.image !== ''}{assign var=hbBig value=true}{/if}
{assign var=hbCount value=0}
{foreach $s.items as $item}{if $item.eyebrow !== '' || $item.title !== '' || $item.text !== ''}{assign var=hbCount value=$hbCount+1}{/if}{/foreach}
{if $hbBig || $hbCount > 0}
<section class="hp-tiles-magazine"{if !$hbBig || $hbCount == 0} style="grid-template-columns: minmax(0, 1fr);"{/if}>
    {if $hbBig}
        <div class="mag-big">
            {if $s.eyebrow !== ''}<div class="eb">{$s.eyebrow|escape}</div>{/if}
            {if $s.title !== ''}<h2>{$s.title|escape}</h2>{/if}
            {if $s.text !== ''}<p>{$s.text|escape|nl2br}</p>{/if}
            {if $s.linkLabel !== '' && $s.link !== ''}<a href="{$s.link|escape}" class="link">{$s.linkLabel|escape} &rsaquo;</a>{/if}
            {if $s.image !== ''}
                <div class="mag-visual" style="opacity: 1;">
                    <img class="hb-media" src="{$s.image|escape}" alt="{$s.imageAlt|escape}" loading="lazy" style="margin: 0 auto;">
                </div>
            {elseif $s.iconSvg !== ''}
                {* The icon is drawn on a 24px grid; the inner box scales it to
                   the 96px the outer box reserves. *}
                <div class="mag-visual" aria-hidden="true">
                    <div style="width: 96px; height: 96px; margin: 0 auto;"><div style="display: flex; width: 24px; height: 24px; transform: scale(4); transform-origin: 0 0;">{$s.iconSvg nofilter}</div></div>
                </div>
            {/if}
        </div>
    {/if}
    {if $hbCount > 0}
        <div class="hp-mag-small-grid">
            {foreach $s.items as $item}
                {if $item.eyebrow !== '' || $item.title !== '' || $item.text !== ''}
                    {* Cream and plum keep one background in light and dark
                       mode, so their text colour is fixed here to match it. *}
                    <div class="hp-mag-small mag-{$item.tone|escape}"{if $item.tone == 'cream'} style="color: #1d1d1f;"{elseif $item.tone == 'plum'} style="color: #f5f5f7;"{/if}>
                        {if $item.eyebrow !== ''}<div class="eb-sm">{$item.eyebrow|escape}</div>{/if}
                        {if $item.title !== ''}<h3>{if $item.link !== ''}<a href="{$item.link|escape}" style="color: inherit;">{$item.title|escape}</a>{else}{$item.title|escape}{/if}</h3>{/if}
                        {if $item.text !== ''}<p>{$item.text|escape}</p>{/if}
                        {if $item.iconSvg !== ''}
                            <div class="mvsm" aria-hidden="true">
                                <div style="width: 36px; height: 36px; margin: 0 auto;"><div style="display: flex; width: 24px; height: 24px; transform: scale(1.5); transform-origin: 0 0;">{$item.iconSvg nofilter}</div></div>
                            </div>
                        {/if}
                    </div>
                {/if}
            {/foreach}
        </div>
    {/if}
</section>
{/if}
