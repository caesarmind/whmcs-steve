{* The poster fills .vid-thumb behind the theme's tint and the play button.
   The theme has no letter style for .vid-author .avatar, so the circle shows
   only when there is a photo. *}
{if $s.quote !== ''}
<section class="hp-testi-video">
    {if $s.title !== ''}<h2>{$s.title|escape}</h2>{/if}
    <div class="hp-testi-vid-card">
        <div class="vid-thumb" style="cursor: default;">
            {if $s.image !== ''}
                <img class="hb-media" src="{$s.image|escape}" alt="{$s.imageAlt|escape}" loading="lazy" style="position: absolute; inset: 0; width: 100%; height: 100%; max-width: none; object-fit: cover; border-radius: 0;">
            {/if}
            {if $s.link !== ''}
                <a class="play-btn" href="{$s.link|escape}" target="_blank" rel="noopener"{if $s.playLabel !== ''} aria-label="{$s.playLabel|escape}"{/if}>
                    <svg viewBox="0 0 24 24" fill="currentColor" aria-hidden="true"><polygon points="5 3 19 12 5 21 5 3"/></svg>
                </a>
            {/if}
        </div>
        <div class="vid-text">
            <blockquote>{$s.quote|escape|nl2br}</blockquote>
            {if $s.name !== '' || $s.role !== ''}
                <div class="vid-author">
                    {if $s.avatar !== ''}<img class="avatar hb-media" src="{$s.avatar|escape}" alt="" loading="lazy" style="object-fit: cover;">{/if}
                    <div>
                        {if $s.name !== ''}<div class="name">{$s.name|escape}</div>{/if}
                        {if $s.role !== ''}<div class="role">{$s.role|escape}</div>{/if}
                    </div>
                </div>
            {/if}
        </div>
    </div>
</section>
{/if}
