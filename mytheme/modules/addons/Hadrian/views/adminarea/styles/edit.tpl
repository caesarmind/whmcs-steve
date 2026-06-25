{include file="includes/header.tpl"}

<div class="mt-toolbar">
    <a class="mt-back" href="{$viewHelper->url('styles')}">
        <svg viewBox="0 0 16 16" fill="none"><path d="M10 13L5 8l5-5" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round"/></svg>
        Back to Styles
    </a>
    <button class="mt-btn mt-btn-primary mt-btn-sm">Save changes</button>
</div>

<header class="mt-page-header">
    <h1 class="mt-page-title">{$styleName|escape} <span class="mt-page-meta">/ Style editor</span></h1>
    <p class="mt-page-subtitle">Edit color scheme, typography, and component variables for this style preset.</p>
</header>

<div class="mt-tabs">
    <a class="mt-tab {if $tab == 'variables'}is-active{/if}" href="?module=Hadrian&action=editStyle&style={$style|escape}&tab=variables">Style Variables</a>
    <a class="mt-tab {if $tab == 'settings'}is-active{/if}" href="?module=Hadrian&action=editStyle&style={$style|escape}&tab=settings">Style Settings</a>
    <a class="mt-tab {if $tab == 'custom-css'}is-active{/if}" href="?module=Hadrian&action=editStyle&style={$style|escape}&tab=custom-css">Custom CSS</a>
</div>

{if $tab == 'variables'}
<div class="mt-split">
  <div class="mt-panel pad">
    <nav class="mt-subcats">
        <a class="mt-subcat {if $subcat == 'colors'}is-active{/if}"     data-subcat="colors"     href="?module=Hadrian&action=editStyle&style={$style|escape}&subcat=colors">Colors</a>
        <a class="mt-subcat {if $subcat == 'typography'}is-active{/if}" data-subcat="typography" href="?module=Hadrian&action=editStyle&style={$style|escape}&subcat=typography">Typography</a>
        <a class="mt-subcat {if $subcat == 'general'}is-active{/if}"    data-subcat="general"    href="?module=Hadrian&action=editStyle&style={$style|escape}&subcat=general">General</a>
        <a class="mt-subcat {if $subcat == 'navigation'}is-active{/if}" data-subcat="navigation" href="?module=Hadrian&action=editStyle&style={$style|escape}&subcat=navigation">Navigation</a>
        <a class="mt-subcat {if $subcat == 'layout'}is-active{/if}"     data-subcat="layout"     href="?module=Hadrian&action=editStyle&style={$style|escape}&subcat=layout">Layout</a>
        <a class="mt-subcat {if $subcat == 'buttons'}is-active{/if}"    data-subcat="buttons"    href="?module=Hadrian&action=editStyle&style={$style|escape}&subcat=buttons">Buttons</a>
        <a class="mt-subcat {if $subcat == 'forms'}is-active{/if}"      data-subcat="forms"      href="?module=Hadrian&action=editStyle&style={$style|escape}&subcat=forms">Forms</a>
        <a class="mt-subcat {if $subcat == 'elements'}is-active{/if}"   data-subcat="elements"   href="?module=Hadrian&action=editStyle&style={$style|escape}&subcat=elements">Elements</a>
        <a class="mt-subcat {if $subcat == 'site'}is-active{/if}"       data-subcat="site"       href="?module=Hadrian&action=editStyle&style={$style|escape}&subcat=site">Site</a>
    </nav>
  </div>

    {* All panels render so the JS in includes/footer.tpl can switch tabs with
       no page reload; the <a> hrefs above remain a no-JS fallback. *}
  <div class="mt-panel pad">
    <div class="mt-subcat-content" data-subcats>
        <div class="mt-subcat-panel" data-panel="colors"{if $subcat != 'colors'} hidden{/if}>
            {include file="styles/_colors.tpl"}
        </div>

        <div class="mt-subcat-panel" data-panel="typography"{if $subcat != 'typography'} hidden{/if}>
            {include file="styles/_typography.tpl"}
        </div>

        <div class="mt-subcat-panel" data-panel="buttons"{if $subcat != 'buttons'} hidden{/if}>
            {include file="styles/_buttons.tpl"}
        </div>

        <div class="mt-subcat-panel" data-panel="forms"{if $subcat != 'forms'} hidden{/if}>
            {include file="styles/_forms.tpl"}
        </div>

        <div class="mt-subcat-panel" data-panel="layout"{if $subcat != 'layout'} hidden{/if}>
            {include file="styles/_layout.tpl"}
        </div>

        <div class="mt-subcat-panel" data-panel="elements"{if $subcat != 'elements'} hidden{/if}>
            {include file="styles/_elements.tpl"}
        </div>

        {foreach ['general', 'navigation', 'site'] as $sc}
        <div class="mt-subcat-panel" data-panel="{$sc}"{if $subcat != $sc} hidden{/if}>
            <div class="mt-empty">
                <div class="mt-empty-title">{$sc|capitalize}</div>
                <p>This panel isn&rsquo;t available yet.</p>
            </div>
        </div>
        {/foreach}
    </div>
  </div>
</div>
{/if}{* /variables tab *}

{if $tab == 'settings'}
<div class="mt-panel pad">
<div class="mt-empty">
    <div class="mt-empty-title">Style Settings</div>
    <p>This panel isn&rsquo;t available yet.</p>
</div>
</div>
{/if}

{if $tab == 'custom-css'}
    <form method="post" action="?module=Hadrian&action=editStyle&style={$style|escape}&tab=custom-css" class="mt-custom-css">
        <input type="hidden" name="mt_custom_css_save" value="1">
        <input type="hidden" name="style" value="{$style|escape}">
        {if $cssSaved}<div class="mt-alert mt-alert-success">Custom CSS saved.</div>{/if}
        <div class="mt-panel">
        <section class="mt-section">
            <header class="mt-section-header"><h2 class="mt-section-title">Custom CSS</h2></header>
            <p class="mt-field-help">Injected into every client-area page <em>after</em> the theme styles, so it overrides them. Applies site-wide (regardless of active style).</p>
            <textarea name="custom_css" class="mt-textarea mt-code" rows="18" spellcheck="false" placeholder="/* Your CSS — e.g. */&#10;.card { border-radius: 18px; }">{$customCss|escape}</textarea>
        </section>
        </div>
        <div class="mt-typo-actions"><button type="submit" class="mt-btn mt-btn-primary">Save CSS</button></div>
    </form>
{/if}

{include file="includes/footer.tpl"}
