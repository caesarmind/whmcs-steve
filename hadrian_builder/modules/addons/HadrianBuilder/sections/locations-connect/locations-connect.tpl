{* The frame is 784 by 459, the shape the theme gives hp-world-map, so a
   point's percentages become drawing units by multiplying by 7.84 and 4.59.
   Each line is a curve from the hub that bows upward on its way to a point.
   The names are printed as the theme's pin labels, outside the drawing, so
   they keep their size on a small screen. *}
{if $s.nodes || $s.title !== '' || $s.subtitle !== ''}
<section class="hp-locations-connect">
    {if $s.title !== ''}<h2>{$s.title|escape}</h2>{/if}
    {if $s.subtitle !== ''}<p class="sub">{$s.subtitle|escape}</p>{/if}
    {if $s.nodes}
        {assign var=hbHubX value=$s.hubX*7.84}
        {assign var=hbHubY value=$s.hubY*4.59}
        <div class="hp-world-map hp-connect-viz">
            {if $s.map !== ''}<img src="{$s.map|escape}" alt="" class="map-bg">{/if}
            <svg class="map-overlay" viewBox="0 0 784 459" aria-hidden="true" focusable="false">
                {if $s.map === ''}
                    <defs>
                        <pattern id="hb-dots-{$id|escape}" width="16" height="16" patternUnits="userSpaceOnUse">
                            <circle cx="8" cy="8" r="1.4" style="fill: var(--color-text-tertiary);"/>
                        </pattern>
                    </defs>
                    <rect width="784" height="459" fill="url(#hb-dots-{$id|escape})" opacity="0.45"/>
                {/if}
                <g fill="none" stroke-width="1.5" stroke-dasharray="5 5" opacity="0.75" style="stroke: var(--color-accent);">
                    {foreach $s.nodes as $node}
                        {assign var=hbX value=$node.x*7.84}
                        {assign var=hbY value=$node.y*4.59}
                        {assign var=hbMidX value=($hbHubX+$hbX)/2}
                        {assign var=hbMidY value=($hbHubY+$hbY)/2-45}
                        <path class="line" d="M{$hbHubX|escape},{$hbHubY|escape} Q{$hbMidX|escape},{$hbMidY|escape} {$hbX|escape},{$hbY|escape}"/>
                    {/foreach}
                </g>
                <circle class="hub" cx="{$hbHubX|escape}" cy="{$hbHubY|escape}" r="18" opacity="0.15"/>
                <circle class="hub" cx="{$hbHubX|escape}" cy="{$hbHubY|escape}" r="9"/>
                {foreach $s.nodes as $node}
                    {assign var=hbX value=$node.x*7.84}
                    {assign var=hbY value=$node.y*4.59}
                    <circle class="node" cx="{$hbX|escape}" cy="{$hbY|escape}" r="7"/>
                {/foreach}
            </svg>
            {if $s.hubName !== ''}
                <div class="hp-map-pin" style="left: {$s.hubX|escape}%; top: {$s.hubY|escape}%;"><div class="pin-label">{$s.hubName|escape}</div></div>
            {/if}
            {foreach $s.nodes as $node}
                {if $node.name !== ''}
                    <div class="hp-map-pin" style="left: {$node.x|escape}%; top: {$node.y|escape}%;"><div class="pin-label">{$node.name|escape}</div></div>
                {/if}
            {/foreach}
        </div>
    {/if}
</section>
{/if}
