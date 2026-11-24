{* The band is black in both colour modes. The theme colours the eyebrow,
   the headline and bold words with the page text colour, which is dark in
   light mode, so that colour is set to a fixed light one for this band. *}
{if $s.eyebrow !== '' || $s.title !== '' || $s.text !== ''}
<section class="hp-silicon-hero" style="--color-text-primary: #f5f5f7;">
    <div class="hp-silicon-hero-inner">
        {if $s.eyebrow !== ''}<div class="eyebrow">{$s.eyebrow|escape}</div>{/if}
        {if $s.title !== ''}<h1>{$s.title|escape}</h1>{/if}
        {if $s.text !== ''}<div class="lead">{$s.text nofilter}</div>{/if}
    </div>
</section>
{/if}
