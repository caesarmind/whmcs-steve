{* The points of light are decoration. Each one's place (x, y), size (s) and
   twinkle time (d) are read by the theme's CSS. The band is dark in both
   colour modes, so the headline is given a fixed light colour: the theme's
   own rule uses the page text colour, which is dark in light mode. *}
{if $s.eyebrow !== '' || $s.title !== '' || $s.text !== '' || ($s.primaryLabel !== '' && $s.primaryLink !== '') || ($s.secondaryLabel !== '' && $s.secondaryLink !== '')}
<section class="hp-hero-starfield">
    <div class="starfield-canvas" aria-hidden="true">
        <span style="--x:8%;--y:20%;--d:6s;--s:2px"></span>
        <span style="--x:18%;--y:62%;--d:9s;--s:1px"></span>
        <span style="--x:28%;--y:35%;--d:7s;--s:2px"></span>
        <span style="--x:42%;--y:78%;--d:11s;--s:1px"></span>
        <span style="--x:58%;--y:14%;--d:8s;--s:3px"></span>
        <span style="--x:68%;--y:52%;--d:10s;--s:1px"></span>
        <span style="--x:76%;--y:28%;--d:6.5s;--s:2px"></span>
        <span style="--x:86%;--y:68%;--d:9.5s;--s:1px"></span>
        <span style="--x:92%;--y:42%;--d:7.5s;--s:2px"></span>
        <span style="--x:12%;--y:84%;--d:12s;--s:1px"></span>
        <span style="--x:52%;--y:92%;--d:8.5s;--s:2px"></span>
        <span style="--x:34%;--y:8%;--d:10.5s;--s:1px"></span>
    </div>
    <div class="starfield-inner">
        {if $s.eyebrow !== ''}<div class="hp-eyebrow">{$s.eyebrow|escape}</div>{/if}
        {if $s.title !== ''}<h1 style="color: #f5f5f7;">{$s.title|escape}</h1>{/if}
        {if $s.text !== ''}<p>{$s.text|escape|nl2br}</p>{/if}
        {if ($s.primaryLabel !== '' && $s.primaryLink !== '') || ($s.secondaryLabel !== '' && $s.secondaryLink !== '')}
            <div class="hp-cta-row">
                {if $s.primaryLabel !== '' && $s.primaryLink !== ''}<a href="{$s.primaryLink|escape}" class="hp-buy-btn">{$s.primaryLabel|escape}</a>{/if}
                {if $s.secondaryLabel !== '' && $s.secondaryLink !== ''}<a href="{$s.secondaryLink|escape}">{$s.secondaryLabel|escape} &rsaquo;</a>{/if}
            </div>
        {/if}
    </div>
</section>
{/if}
