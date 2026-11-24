{* A link needs both its text and its address. The theme's script adds the
   "active" class to the link of the section in view. *}
{assign var=hbCount value=0}
{foreach $s.links as $item}{if $item.label !== '' && $item.link !== ''}{assign var=hbCount value=$hbCount+1}{/if}{/foreach}
{if $s.title !== '' || $hbCount > 0 || ($s.buttonLabel !== '' && $s.buttonLink !== '')}
<nav class="homepage-subnav"{if $s.navLabel !== ''} aria-label="{$s.navLabel|escape}"{/if}>
    <div class="homepage-subnav-inner">
        {if $s.title !== ''}<span class="subnav-title">{$s.title|escape}</span>{/if}
        {if $hbCount > 0 || ($s.buttonLabel !== '' && $s.buttonLink !== '')}
            <div class="subnav-links">
                {foreach $s.links as $item}
                    {if $item.label !== '' && $item.link !== ''}<a href="{$item.link|escape}" class="subnav-link">{$item.label|escape}</a>{/if}
                {/foreach}
                {if $s.buttonLabel !== '' && $s.buttonLink !== ''}
                    {if $hbCount > 0}<span class="subnav-sep" aria-hidden="true"></span>{/if}
                    <a href="{$s.buttonLink|escape}" class="subnav-btn subnav-btn-fill">{$s.buttonLabel|escape}</a>
                {/if}
            </div>
        {/if}
    </div>
</nav>
<script>{literal}
(function () {
    // The theme makes the bar stick below the site header, but a sticky
    // element only travels inside its parent, and the builder's wrapper is
    // no taller than the bar. So the wrapper is made to stick in its place.
    // Left alone in the editor, where the wrapper carries data-hb-id.
    var me = document.currentScript;
    var root = me ? me.previousElementSibling : null;
    var wrap = root ? root.parentNode : null;
    if (!wrap || !wrap.classList || !wrap.classList.contains('hb-section') || wrap.hasAttribute('data-hb-id')) {
        return;
    }
    var css = window.getComputedStyle(root);
    if (css.position !== 'sticky') {
        return;
    }
    wrap.style.position = 'sticky';
    wrap.style.top = css.top;
    wrap.style.zIndex = css.zIndex;
    root.style.position = 'relative';
    root.style.top = 'auto';
})();
{/literal}</script>
{/if}
