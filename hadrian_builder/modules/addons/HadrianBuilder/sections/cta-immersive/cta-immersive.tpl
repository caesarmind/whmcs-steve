{if $s.title !== '' || $s.text !== '' || ($s.primaryLabel !== '' && $s.primaryLink !== '')}
<section class="hp-cta-immersive">
    <div class="inner">
        {if $s.title !== ''}<h2>{$s.title|escape}</h2>{/if}
        {if $s.text !== ''}<p>{$s.text|escape|nl2br}</p>{/if}
        {if $s.primaryLabel !== '' && $s.primaryLink !== ''}<a href="{$s.primaryLink|escape}" class="btn">{$s.primaryLabel|escape}</a>{/if}
    </div>
</section>
{/if}
