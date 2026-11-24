{* The headline size and the highlight colour are set here because the theme has
   no rule for either. The icon is drawn at 24px, so the panel scales it up. *}
{if $s.tone == 'red'}{assign var=hbTone value='var(--color-red)'}
{elseif $s.tone == 'green'}{assign var=hbTone value='var(--color-green)'}
{elseif $s.tone == 'orange'}{assign var=hbTone value='var(--color-orange)'}
{else}{assign var=hbTone value='var(--color-accent)'}{/if}
{if $s.highlight !== '' || $s.title !== '' || $s.text !== ''}
<section class="hp-alternating hp-stat-callout">
    <div class="hp-alt-row">
        <div class="hp-alt-text">
            {if $s.eyebrow !== ''}<div class="hp-eyebrow">{$s.eyebrow|escape}</div>{/if}
            {if $s.highlight !== '' || $s.title !== ''}
                <h2 style="font-size: clamp(var(--text-h3), 6vw, var(--text-display-sm)); font-weight: var(--fw-bold); letter-spacing: -0.03em; line-height: 1.05; margin: 0 0 20px; color: var(--color-text-primary);">{if $s.highlight !== ''}<span style="color: {$hbTone|escape};">{$s.highlight|escape}</span> {/if}{$s.title|escape}</h2>
            {/if}
            {if $s.text !== ''}<p>{$s.text|escape|nl2br}</p>{/if}
        </div>
        <div class="hp-alt-visual">
            {if $s.image !== ''}
                <img class="hb-media" src="{$s.image|escape}" alt="{$s.imageAlt|escape}" loading="lazy">
            {else}
                <div class="visual-box" aria-hidden="true">
                    {if $s.iconSvg !== ''}<span style="display: inline-flex; transform: scale(4); color: {$hbTone|escape};">{$s.iconSvg nofilter}</span>{/if}
                </div>
            {/if}
        </div>
    </div>
</section>
{/if}
