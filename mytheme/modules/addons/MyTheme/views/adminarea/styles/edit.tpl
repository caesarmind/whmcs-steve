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
    <a class="mt-tab {if $tab == 'variables'}is-active{/if}" href="?module=MyTheme&action=editStyle&style={$style|escape}&tab=variables">Style Variables</a>
    <a class="mt-tab {if $tab == 'settings'}is-active{/if}" href="?module=MyTheme&action=editStyle&style={$style|escape}&tab=settings">Style Settings</a>
    <a class="mt-tab {if $tab == 'custom-css'}is-active{/if}" href="?module=MyTheme&action=editStyle&style={$style|escape}&tab=custom-css">Custom CSS</a>
</div>

{if $tab == 'variables'}
<div class="mt-split">
    <nav class="mt-subcats">
        <a class="mt-subcat {if $subcat == 'colors'}is-active{/if}"     data-subcat="colors"     href="?module=MyTheme&action=editStyle&style={$style|escape}&subcat=colors">Colors</a>
        <a class="mt-subcat {if $subcat == 'typography'}is-active{/if}" data-subcat="typography" href="?module=MyTheme&action=editStyle&style={$style|escape}&subcat=typography">Typography</a>
        <a class="mt-subcat {if $subcat == 'general'}is-active{/if}"    data-subcat="general"    href="?module=MyTheme&action=editStyle&style={$style|escape}&subcat=general">General</a>
        <a class="mt-subcat {if $subcat == 'navigation'}is-active{/if}" data-subcat="navigation" href="?module=MyTheme&action=editStyle&style={$style|escape}&subcat=navigation">Navigation</a>
        <a class="mt-subcat {if $subcat == 'layout'}is-active{/if}"     data-subcat="layout"     href="?module=MyTheme&action=editStyle&style={$style|escape}&subcat=layout">Layout</a>
        <a class="mt-subcat {if $subcat == 'buttons'}is-active{/if}"    data-subcat="buttons"    href="?module=MyTheme&action=editStyle&style={$style|escape}&subcat=buttons">Buttons</a>
        <a class="mt-subcat {if $subcat == 'forms'}is-active{/if}"      data-subcat="forms"      href="?module=MyTheme&action=editStyle&style={$style|escape}&subcat=forms">Forms</a>
        <a class="mt-subcat {if $subcat == 'elements'}is-active{/if}"   data-subcat="elements"   href="?module=MyTheme&action=editStyle&style={$style|escape}&subcat=elements">Elements</a>
        <a class="mt-subcat {if $subcat == 'site'}is-active{/if}"       data-subcat="site"       href="?module=MyTheme&action=editStyle&style={$style|escape}&subcat=site">Site</a>
    </nav>

    {* All panels render so the JS in includes/footer.tpl can switch tabs with
       no page reload; the <a> hrefs above remain a no-JS fallback. *}
    <div class="mt-subcat-content" data-subcats>
        <div class="mt-subcat-panel" data-panel="colors"{if $subcat != 'colors'} hidden{/if}>
            <section class="mt-section">
                <header class="mt-section-header"><h2 class="mt-section-title">Color Schemes</h2></header>
                <div class="mt-schemes">
                    {foreach $schemes as $scheme}
                        <a class="mt-scheme {if $scheme.active}is-active{/if}" href="#">
                            <span class="mt-scheme-dot" style="background:{$scheme.dot}"></span>{$scheme.name|escape}
                        </a>
                    {/foreach}
                </div>

                <header class="mt-section-header"><h2 class="mt-section-title">Colors</h2></header>

                {* Sample color groups — real impl reads tokens from core/styles/<style>/style.php *}
                <div class="mt-color-group"><h3 class="mt-color-group-title">Primary</h3><div class="mt-color-grid">
                    <div class="mt-color-tile"><div class="mt-color-swatch" style="background:#1062fe"></div><div class="mt-color-meta"><div class="mt-color-name">Main</div><div class="mt-color-hex">#1062fe</div></div></div>
                    <div class="mt-color-tile"><div class="mt-color-swatch" style="background:#009AFF"></div><div class="mt-color-meta"><div class="mt-color-name">Lighter</div><div class="mt-color-hex">#009AFF</div></div></div>
                    <div class="mt-color-tile"><div class="mt-color-swatch" style="background:#003CB2"></div><div class="mt-color-meta"><div class="mt-color-name">Darker</div><div class="mt-color-hex">#003CB2</div></div></div>
                    <div class="mt-color-tile is-gradient" style="--g1:#1966FF;--g2:#009AFF"><div class="mt-color-swatch"></div><div class="mt-color-meta"><div class="mt-color-name">Gradient</div><div class="mt-color-hex"><span>#1966FF</span><em>→</em><span>#009AFF</span></div></div></div>
                </div></div>

                <div class="mt-color-group"><h3 class="mt-color-group-title">Success</h3><div class="mt-color-grid">
                    <div class="mt-color-tile"><div class="mt-color-swatch" style="background:#30d158"></div><div class="mt-color-meta"><div class="mt-color-name">Main</div><div class="mt-color-hex">#30d158</div></div></div>
                    <div class="mt-color-tile"><div class="mt-color-swatch" style="background:#248a3d"></div><div class="mt-color-meta"><div class="mt-color-name">Darker</div><div class="mt-color-hex">#248a3d</div></div></div>
                </div></div>

                <div class="mt-color-group"><h3 class="mt-color-group-title">Warning</h3><div class="mt-color-grid">
                    <div class="mt-color-tile"><div class="mt-color-swatch" style="background:#ff9f0a"></div><div class="mt-color-meta"><div class="mt-color-name">Main</div><div class="mt-color-hex">#ff9f0a</div></div></div>
                    <div class="mt-color-tile"><div class="mt-color-swatch" style="background:#c27400"></div><div class="mt-color-meta"><div class="mt-color-name">Darker</div><div class="mt-color-hex">#c27400</div></div></div>
                </div></div>

                <div class="mt-color-group"><h3 class="mt-color-group-title">Danger</h3><div class="mt-color-grid">
                    <div class="mt-color-tile"><div class="mt-color-swatch" style="background:#ff3b30"></div><div class="mt-color-meta"><div class="mt-color-name">Main</div><div class="mt-color-hex">#ff3b30</div></div></div>
                    <div class="mt-color-tile"><div class="mt-color-swatch" style="background:#d70015"></div><div class="mt-color-meta"><div class="mt-color-name">Darker</div><div class="mt-color-hex">#d70015</div></div></div>
                </div></div>
            </section>
        </div>

        <div class="mt-subcat-panel" data-panel="typography"{if $subcat != 'typography'} hidden{/if}>
            {include file="styles/_typography.tpl"}
        </div>

        {foreach ['general', 'navigation', 'layout', 'buttons', 'forms', 'elements', 'site'] as $sc}
        <div class="mt-subcat-panel" data-panel="{$sc}"{if $subcat != $sc} hidden{/if}>
            <div class="mt-empty">
                <div class="mt-empty-title">{$sc|capitalize}</div>
                <p>This panel isn&rsquo;t available yet.</p>
            </div>
        </div>
        {/foreach}
    </div>
</div>
{/if}{* /variables tab *}

{if $tab == 'settings'}
<div class="mt-empty">
    <div class="mt-empty-title">Style Settings</div>
    <p>This panel isn&rsquo;t available yet.</p>
</div>
{/if}

{if $tab == 'custom-css'}
    <form method="post" action="?module=MyTheme&action=editStyle&style={$style|escape}&tab=custom-css" class="mt-custom-css">
        <input type="hidden" name="mt_custom_css_save" value="1">
        <input type="hidden" name="style" value="{$style|escape}">
        {if $cssSaved}<div class="mt-alert mt-alert-success">Custom CSS saved.</div>{/if}
        <section class="mt-section">
            <header class="mt-section-header"><h2 class="mt-section-title">Custom CSS</h2></header>
            <p class="mt-field-help">Injected into every client-area page <em>after</em> the theme styles, so it overrides them. Applies site-wide (regardless of active style).</p>
            <textarea name="custom_css" class="mt-textarea mt-code" rows="18" spellcheck="false" placeholder="/* Your CSS — e.g. */&#10;.card { border-radius: 18px; }">{$customCss|escape}</textarea>
        </section>
        <div class="mt-typo-actions"><button type="submit" class="mt-btn mt-btn-primary">Save CSS</button></div>
    </form>
{/if}

{include file="includes/footer.tpl"}
