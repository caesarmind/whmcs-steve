{if $s.title !== '' || $s.text !== ''}
<section class="hp-final-cta">
    {if $s.title !== ''}<h2>{$s.title|escape}</h2>{/if}
    {if $s.text !== ''}<p>{$s.text|escape|nl2br}</p>{/if}
    {if ($s.primaryLabel !== '' && $s.primaryLink !== '') || ($s.secondaryLabel !== '' && $s.secondaryLink !== '')}
        <div>
            {if $s.primaryLabel !== '' && $s.primaryLink !== ''}<a href="{$s.primaryLink|escape}" class="btn">{$s.primaryLabel|escape}</a>{/if}
            {if $s.secondaryLabel !== '' && $s.secondaryLink !== ''}<a href="{$s.secondaryLink|escape}" class="second-link">{$s.secondaryLabel|escape} &rsaquo;</a>{/if}
        </div>
    {/if}
</section>
{/if}
