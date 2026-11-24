{* Each panel is captured first: an empty one is left out, and the other
   then takes the full width. *}
{capture assign=hbFirst}{if $s.firstTitle !== ''}<h3>{$s.firstTitle|escape}</h3>{/if}{if $s.firstText !== ''}<p>{$s.firstText|escape|nl2br}</p>{/if}{if $s.firstLabel !== '' && $s.firstLink !== ''}<a href="{$s.firstLink|escape}" class="btn-primary-pill">{$s.firstLabel|escape}</a>{/if}{/capture}
{capture assign=hbSecond}{if $s.secondTitle !== ''}<h3>{$s.secondTitle|escape}</h3>{/if}{if $s.secondText !== ''}<p>{$s.secondText|escape|nl2br}</p>{/if}{if $s.secondLabel !== '' && $s.secondLink !== ''}<a href="{$s.secondLink|escape}" class="btn-outline-pill">{$s.secondLabel|escape}</a>{/if}{/capture}
{if $hbFirst !== '' || $hbSecond !== ''}
<div class="hp-split-cta-wrapper">
    <div class="hp-split-cta"{if $hbFirst === '' || $hbSecond === ''} style="grid-template-columns: minmax(0, 1fr);"{/if}>
        {if $hbFirst !== ''}<div class="cta-panel dark">{$hbFirst nofilter}</div>{/if}
        {if $hbSecond !== ''}<div class="cta-panel light">{$hbSecond nofilter}</div>{/if}
    </div>
</div>
{/if}
