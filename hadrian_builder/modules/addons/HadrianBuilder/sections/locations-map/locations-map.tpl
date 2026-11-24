{* The map picture is decoration: the theme fades it behind the pins. With
   no picture a dotted grid fills the frame so the pins still have a ground.
   A pin's place is its two percentages, printed as left and top. *}
{if $s.pins || $s.title !== '' || $s.subtitle !== ''}
<section class="hp-locations-map-section{if $s.dark} dark{/if}">
    {if $s.title !== ''}<h2>{$s.title|escape}</h2>{/if}
    {if $s.subtitle !== ''}<p class="loc-sub">{$s.subtitle|escape}</p>{/if}
    {if $s.pins}
        <div class="hp-world-map">
            {if $s.map !== ''}
                <img src="{$s.map|escape}" alt="" class="map-bg">
            {else}
                <svg class="map-overlay" viewBox="0 0 784 459" aria-hidden="true" focusable="false">
                    <defs>
                        <pattern id="hb-dots-{$id|escape}" width="16" height="16" patternUnits="userSpaceOnUse">
                            <circle cx="8" cy="8" r="1.4" style="fill: var(--color-text-tertiary);"/>
                        </pattern>
                    </defs>
                    <rect width="784" height="459" fill="url(#hb-dots-{$id|escape})" opacity="0.45"/>
                </svg>
            {/if}
            {foreach $s.pins as $pin}
                <div class="hp-map-pin" style="left: {$pin.x|escape}%; top: {$pin.y|escape}%;"{if !$s.showLabels && $pin.name !== ''} title="{$pin.name|escape}"{/if}>
                    <div class="pin-dot"></div>
                    <div class="pin-pulse"></div>
                    {if $s.showLabels && $pin.name !== ''}<div class="pin-label">{$pin.name|escape}</div>{/if}
                </div>
            {/foreach}
        </div>
    {/if}
</section>
{/if}
