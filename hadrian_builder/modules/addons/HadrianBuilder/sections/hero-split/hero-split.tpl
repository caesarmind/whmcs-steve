{capture assign=hbVisual}{if $s.image !== ''}
    <div class="hp-split-visual">
        <img class="hb-media" src="{$s.image|escape}" alt="{$s.imageAlt|escape}">
    </div>
{/if}{/capture}
<section class="hp-hero-split"{if $s.image === ''} style="grid-template-columns: minmax(0, 1fr);"{/if}>
    {if $s.flip}{$hbVisual nofilter}{/if}
    <div class="hp-split-text">
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
    {if !$s.flip}{$hbVisual nofilter}{/if}
</section>
