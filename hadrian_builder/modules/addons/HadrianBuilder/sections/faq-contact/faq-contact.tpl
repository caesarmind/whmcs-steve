{* The panel is left out when it has no heading, text or working button, and
   the questions then take the full width. *}
{assign var=hbCount value=0}
{foreach $s.items as $item}{if $item.question !== ''}{assign var=hbCount value=$hbCount+1}{/if}{/foreach}
{assign var=hbPrimary value=($s.primaryLabel !== '' && $s.primaryLink !== '')}
{assign var=hbSecondary value=($s.secondaryLabel !== '' && $s.secondaryLink !== '')}
{assign var=hbPanel value=($s.panelTitle !== '' || $s.panelText !== '' || $hbPrimary || $hbSecondary)}
{if $hbCount > 0 || $hbPanel}
<section class="hp-faq-contact"{if $hbCount == 0 || !$hbPanel} style="grid-template-columns: minmax(0, 1fr);"{/if}>
    {if $hbCount > 0}
        <div>
            {if $s.title !== ''}<h2>{$s.title|escape}</h2>{/if}
            {assign var=hbAt value=0}
            {foreach $s.items as $item}
                {if $item.question !== ''}
                    {assign var=hbAt value=$hbAt+1}
                    <details class="hp-faq-item"{if $s.openFirst && $hbAt == 1} open{/if}>
                        <summary>{$item.question|escape}</summary>
                        <div class="faq-body">{$item.answer nofilter}</div>
                    </details>
                {/if}
            {/foreach}
        </div>
    {/if}
    {if $hbPanel}
        <div class="hp-faq-contact-card">
            {if $s.panelIconSvg !== ''}<div class="icon-lg">{$s.panelIconSvg nofilter}</div>{/if}
            {if $s.panelTitle !== ''}<h4>{$s.panelTitle|escape}</h4>{/if}
            {if $s.panelText !== ''}<p>{$s.panelText|escape|nl2br}</p>{/if}
            {if $hbPrimary}<a href="{$s.primaryLink|escape}" class="contact-btn">{$s.primaryLabel|escape}</a>{/if}
            {if $hbSecondary}<a href="{$s.secondaryLink|escape}" class="contact-link">{$s.secondaryLabel|escape} &rsaquo;</a>{/if}
        </div>
    {/if}
</section>
{/if}
