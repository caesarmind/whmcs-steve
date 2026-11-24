{* Each panel is left out when all its fields are empty, and the one that is
   left takes the full width. An empty picture slot keeps the plain block the
   theme draws for it. *}
{assign var=hbBig value=($s.bigEyebrow !== '' || $s.bigTitle !== '' || $s.bigLead !== '' || $s.bigText !== '' || $s.bigImage !== '')}
{assign var=hbSmall value=($s.smallTitle !== '' || $s.smallText !== '' || $s.smallImage !== '')}
{if $hbBig || $hbSmall}
<section class="hp-intel-duo"{if !$hbBig || !$hbSmall} style="grid-template-columns: minmax(0, 1fr);"{/if}>
    {if $hbBig}
        <div class="hp-intel-big">
            {if $s.bigEyebrow !== ''}<div class="eyebrow">{$s.bigEyebrow|escape}</div>{/if}
            {if $s.bigTitle !== ''}<h2>{$s.bigTitle|escape}</h2>{/if}
            {if $s.bigLead !== '' || $s.bigText !== ''}
                <p>{if $s.bigLead !== ''}<strong>{$s.bigLead|escape}</strong> {/if}{$s.bigText|escape|nl2br}</p>
            {/if}
            {if $s.bigLinkLabel !== '' && $s.bigLink !== ''}<a href="{$s.bigLink|escape}" class="link">{$s.bigLinkLabel|escape} &rsaquo;</a>{/if}
            {if $s.bigImage !== ''}
                <div class="intel-visual"><img class="hb-media" style="border-radius: 0;" src="{$s.bigImage|escape}" alt="{$s.bigImageAlt|escape}" loading="lazy"></div>
            {else}
                <div class="intel-visual" aria-hidden="true"></div>
            {/if}
        </div>
    {/if}
    {if $hbSmall}
        <div class="hp-intel-small">
            {if $s.smallImage !== ''}
                <div class="intel-small-shot"><img class="hb-media" style="border-radius: 0;" src="{$s.smallImage|escape}" alt="{$s.smallImageAlt|escape}" loading="lazy"></div>
            {else}
                <div class="intel-small-shot" aria-hidden="true"></div>
            {/if}
            <div class="intel-small-content">
                {if $s.smallIconSvg !== ''}<div class="icon-badge">{$s.smallIconSvg nofilter}</div>{/if}
                {if $s.smallTitle !== ''}<h3>{$s.smallTitle|escape}</h3>{/if}
                {if $s.smallText !== ''}<p>{$s.smallText|escape|nl2br}</p>{/if}
            </div>
        </div>
    {/if}
</section>
{/if}
