{* The theme sizes a mark inside logo-item but has no rule for a word, so
   the size and weight of the names are set here from its tokens. *}
{if $s.namesLines}
<section class="hp-logo-bar">
    <div class="hp-logo-bar-inner">
        {foreach $s.namesLines as $name}
            <span class="logo-item" style="font-size: var(--text-xl); font-weight: var(--fw-semibold);">{$name|escape}</span>
        {/foreach}
    </div>
</section>
{/if}
