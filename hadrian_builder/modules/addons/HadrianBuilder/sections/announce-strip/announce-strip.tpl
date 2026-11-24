{if $s.text !== ''}
<div class="hp-announce-strip">
    <div class="hp-announce-strip-inner">
        {if $s.tag !== ''}<span class="announce-tag">{$s.tag|escape}</span>{/if}
        <span class="announce-msg">{$s.text|escape}</span>
        {if $s.linkLabel !== '' && $s.link !== ''}<a href="{$s.link|escape}" class="announce-link">{$s.linkLabel|escape} &rsaquo;</a>{/if}
    </div>
</div>
{/if}
