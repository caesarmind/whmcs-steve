{* The band is black in both colour modes, so the headline is given a fixed
   light colour: the theme's own rule uses the page text colour, which is
   dark in light mode. *}
{if $s.eyebrow !== '' || $s.title !== '' || $s.text !== '' || ($s.primaryLabel !== '' && $s.primaryLink !== '') || ($s.secondaryLabel !== '' && $s.secondaryLink !== '')}
<section class="hp-hero-bleed">
    <div class="bleed-inner">
        {if $s.eyebrow !== ''}<div class="hp-eyebrow">{$s.eyebrow|escape}</div>{/if}
        {if $s.title !== ''}<h1 style="color: #f5f5f7;">{$s.title|escape}</h1>{/if}
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
