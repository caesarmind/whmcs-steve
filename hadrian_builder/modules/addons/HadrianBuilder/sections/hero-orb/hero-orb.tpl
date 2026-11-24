{* The orb is decoration, animated by the theme's CSS. *}
{if $s.eyebrow !== '' || $s.title !== '' || $s.text !== '' || ($s.primaryLabel !== '' && $s.primaryLink !== '') || ($s.secondaryLabel !== '' && $s.secondaryLink !== '')}
<section class="hp-hero-orb">
    <div class="orb-bg" aria-hidden="true"></div>
    <div class="orb-inner">
        {if $s.eyebrow !== ''}<div class="hp-eyebrow">{$s.eyebrow|escape}</div>{/if}
        {if $s.title !== ''}<h1>{$s.title|escape}</h1>{/if}
        {if $s.text !== ''}<p>{$s.text|escape|nl2br}</p>{/if}
        {if ($s.primaryLabel !== '' && $s.primaryLink !== '') || ($s.secondaryLabel !== '' && $s.secondaryLink !== '')}
            <div class="hp-cta-row">
                {if $s.primaryLabel !== '' && $s.primaryLink !== ''}<a href="{$s.primaryLink|escape}" class="hp-buy-btn">{$s.primaryLabel|escape}</a>{/if}
                {if $s.secondaryLabel !== '' && $s.secondaryLink !== ''}<a href="{$s.secondaryLink|escape}">{$s.secondaryLabel|escape} &rsaquo;</a>{/if}
            </div>
        {/if}
    </div>
</section>
{/if}
