{* The number sits half above its card, so the row keeps clear of the heading
   when there is no subheading, and of the row above when the steps wrap. *}
{assign var=hbCount value=0}
{foreach $s.steps as $step}{if $step.title !== '' || $step.text !== ''}{assign var=hbCount value=$hbCount+1}{/if}{/foreach}
{if $hbCount > 0 || $s.title !== ''}
<section class="hp-features-section hp-onboarding-steps">
    {if $s.title !== ''}<h2>{$s.title|escape}</h2>{/if}
    {if $s.subtitle !== ''}<p class="feat-sub">{$s.subtitle|escape}</p>{/if}
    {if $hbCount > 0}
        <div class="hp-onboarding-steps-row" style="row-gap: 40px;{if $s.title !== '' && $s.subtitle === ''} margin-top: 38px;{/if}">
            {assign var=hbAt value=0}
            {foreach $s.steps as $step}
                {if $step.title !== '' || $step.text !== ''}
                    {assign var=hbAt value=$hbAt+1}
                    <div class="hp-feature-card" style="position: relative;">
                        <div style="position: absolute; top: -18px; left: 50%; transform: translateX(-50%); width: 36px; height: 36px; border-radius: 50%; background: var(--color-accent); color: #fff; display: flex; align-items: center; justify-content: center; font-size: var(--text-md); font-weight: var(--fw-bold);">{$hbAt|escape}</div>
                        {if $step.iconSvg !== ''}<div class="feat-icon {$step.colour|escape}">{$step.iconSvg nofilter}</div>{/if}
                        {if $step.title !== ''}<h4>{$step.title|escape}</h4>{/if}
                        {if $step.text !== ''}<p>{$step.text|escape|nl2br}</p>{/if}
                    </div>
                {/if}
            {/foreach}
        </div>
    {/if}
</section>
{/if}
