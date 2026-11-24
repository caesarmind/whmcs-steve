{* The form is a plain GET to the WHMCS cart, which runs the domain search. *}
{capture assign=hbVisual}{if $s.image !== ''}
    <div class="hp-split-visual">
        <img class="hb-media" src="{$s.image|escape}" alt="{$s.imageAlt|escape}">
    </div>
{/if}{/capture}
<section class="hp-hero-split"{if $s.image === ''} style="grid-template-columns: minmax(0, 1fr);"{/if}>
    {if $s.flip}{$hbVisual nofilter}{/if}
    <div class="hp-split-text">
        {if $s.eyebrow !== ''}<div class="hp-eyebrow">{$s.eyebrow|escape}</div>{/if}
        {if $s.title !== ''}<h1>{$s.title|escape}</h1>{/if}
        {if $s.text !== ''}<p>{$s.text|escape|nl2br}</p>{/if}
        <form class="ds-search-form" method="get" action="{$ctx.webRoot|escape}/cart.php"{if $s.image === ''} style="max-width: 540px;"{/if}>
            <input type="hidden" name="a" value="add">
            <input type="hidden" name="domain" value="register">
            <div class="ds-search-box">
                <svg class="ds-search-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>
                <input type="text" class="ds-search-input" name="query"{if $s.placeholder !== ''} placeholder="{$s.placeholder|escape}"{/if}{if $s.searchLabel !== ''} aria-label="{$s.searchLabel|escape}"{/if} autocomplete="off" autocapitalize="none" spellcheck="false">
                {if $s.buttonLabel !== ''}<button type="submit" class="ds-generate-btn">{$s.buttonLabel|escape}</button>{/if}
            </div>
        </form>
    </div>
    {if !$s.flip}{$hbVisual nofilter}{/if}
</section>
