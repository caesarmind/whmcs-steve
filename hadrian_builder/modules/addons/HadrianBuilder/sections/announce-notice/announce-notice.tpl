{* The theme script hides the pill when announce-notice-close is clicked. *}
{if $s.text !== '' || $s.lead !== ''}
<div class="hp-announce-notice-wrap">
    <div class="hp-announce-notice">
        {if $s.tag !== ''}<span class="announce-tag compact">{$s.tag|escape}</span>{/if}
        <span class="announce-msg">{if $s.lead !== ''}<strong>{$s.lead|escape}</strong>{if $s.text !== ''} {/if}{/if}{$s.text|escape}</span>
        {if $s.buttonLabel !== '' && $s.buttonLink !== ''}<a href="{$s.buttonLink|escape}" class="announce-notice-btn">{$s.buttonLabel|escape}</a>{/if}
        {if $s.dismissible}
            <button type="button" class="announce-notice-close"{if $s.closeLabel !== ''} aria-label="{$s.closeLabel|escape}"{/if}>
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/></svg>
            </button>
        {/if}
    </div>
</div>
{/if}
