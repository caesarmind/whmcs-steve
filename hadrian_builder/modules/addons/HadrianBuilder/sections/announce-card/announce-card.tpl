{* Without an image the card shows the theme's drawing. Its gradient ids
   carry the section id, so two of these on one page do not share them. *}
{if $s.title !== '' || $s.text !== ''}
<section class="hp-announce-card">
    <div class="hp-announce-card-inner">
        <div class="announce-card-text">
            {if $s.eyebrow !== ''}<div class="announce-card-eyebrow">{$s.eyebrow|escape}</div>{/if}
            {if $s.title !== ''}<h2>{$s.title|escape}</h2>{/if}
            {if $s.text !== ''}<p>{$s.text|escape|nl2br}</p>{/if}
            {if ($s.primaryLabel !== '' && $s.primaryLink !== '') || ($s.secondaryLabel !== '' && $s.secondaryLink !== '')}
                <div class="announce-card-ctas">
                    {if $s.primaryLabel !== '' && $s.primaryLink !== ''}<a href="{$s.primaryLink|escape}" class="announce-card-btn primary">{$s.primaryLabel|escape}</a>{/if}
                    {if $s.secondaryLabel !== '' && $s.secondaryLink !== ''}<a href="{$s.secondaryLink|escape}" class="announce-card-btn-link">{$s.secondaryLabel|escape} &rsaquo;</a>{/if}
                </div>
            {/if}
        </div>
        <div class="announce-card-visual">
            {if $s.image !== ''}
                <img class="hb-media" src="{$s.image|escape}" alt="{$s.imageAlt|escape}" loading="lazy">
            {else}
                <svg viewBox="0 0 240 240" fill="none" aria-hidden="true">
                    <defs>
                        <linearGradient id="hb-board-{$id|escape}" x1="0%" y1="0%" x2="100%" y2="100%">
                            <stop offset="0%" stop-color="var(--color-accent)"/>
                            <stop offset="100%" stop-color="#64d2ff"/>
                        </linearGradient>
                        <linearGradient id="hb-glow-{$id|escape}" x1="50%" y1="0%" x2="50%" y2="100%">
                            <stop offset="0%" stop-color="#a1d6ff" stop-opacity="0.4"/>
                            <stop offset="100%" stop-color="#a1d6ff" stop-opacity="0"/>
                        </linearGradient>
                    </defs>
                    <circle cx="120" cy="120" r="96" fill="url(#hb-glow-{$id|escape})"/>
                    <rect x="48" y="72" width="144" height="96" rx="14" fill="url(#hb-board-{$id|escape})"/>
                    <rect x="64" y="88" width="112" height="18" rx="3" fill="#0a2e5c" opacity="0.4"/>
                    <rect x="64" y="114" width="72" height="14" rx="3" fill="#fff" opacity="0.85"/>
                    <rect x="64" y="134" width="96" height="14" rx="3" fill="#fff" opacity="0.6"/>
                    <circle cx="176" cy="88" r="4" fill="#30d158"/>
                    <circle cx="176" cy="100" r="4" fill="#ffd60a"/>
                </svg>
            {/if}
        </div>
    </div>
</section>
{/if}
