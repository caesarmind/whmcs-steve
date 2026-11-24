{* The theme sizes .quote-avatar and styles a letter inside it, but leaves the
   circle's colour to the markup. *}
{if $s.quote !== ''}
<section class="hp-testimonial-hero">
    <div class="quote-mark" aria-hidden="true">&ldquo;</div>
    <blockquote>{$s.quote|escape|nl2br}</blockquote>
    {if $s.name !== '' || $s.role !== ''}
        <div class="quote-author">
            {if $s.image !== ''}
                <img class="quote-avatar hb-media" src="{$s.image|escape}" alt="" loading="lazy" style="object-fit: cover;">
            {elseif $s.name !== ''}
                <div class="quote-avatar" style="background-color: var(--color-accent);" aria-hidden="true">{$s.name|truncate:1:''|upper|escape}</div>
            {/if}
            <div class="quote-info">
                {if $s.name !== ''}<div class="name">{$s.name|escape}</div>{/if}
                {if $s.role !== ''}<div class="role">{$s.role|escape}</div>{/if}
            </div>
        </div>
    {/if}
</section>
{/if}
