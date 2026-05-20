{include file="includes/header.tpl"}

<div class="mt-toolbar">
    <a class="mt-back" href="?module=MyTheme&action=pages#tab={$pageGroup|escape:'url'}">
        <svg viewBox="0 0 16 16" fill="none"><path d="M10 13L5 8l5-5" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round"/></svg>
        Back to Pages
    </a>
    <button form="page-edit-form" class="mt-btn mt-btn-primary mt-btn-sm">Save changes</button>
</div>

<header class="mt-page-header">
    <div class="mt-page-eyebrow">{$pageGroup|escape}</div>
    <h1 class="mt-page-title">{$pageLabel|escape} <span class="mt-page-meta">/ Page editor</span></h1>
    {if $pageDescription}
        <p class="mt-page-subtitle">{$pageDescription|escape}</p>
    {/if}
</header>

{if $flashMsg == 'saved'}
    <div class="mt-alert mt-alert-success">Saved.</div>
{/if}

<form id="page-edit-form" method="post" action="?module=MyTheme&action=pages&sub=save">
    <input type="hidden" name="page" value="{$page|escape}">

    <section class="mt-section">
        <header class="mt-section-header"><h2 class="mt-section-title">Template variant</h2></header>
        {if $variants|count}
            <div class="mt-variant-grid">
                {foreach $variants as $v}
                    <label class="mt-variant {if $v.name == $activeVariant}is-active{/if}">
                        <input type="radio" name="variant" value="{$v.name|escape}" {if $v.name == $activeVariant}checked{/if} hidden>
                        <div>
                            <div class="mt-variant-name">{$v.label|escape}</div>
                            {if $v.description}
                                <div style="font-size:12px;color:var(--mt-text-3);margin-top:2px;">{$v.description|escape}</div>
                            {/if}
                        </div>
                        {if $v.name == $activeVariant}
                            <span class="mt-badge mt-badge-success">Active</span>
                        {else}
                            <span class="mt-badge mt-badge-neutral">Click to activate</span>
                        {/if}
                    </label>
                {/foreach}
            </div>
        {else}
            <div class="mt-empty">
                <p>No variants found under <code>core/pages/{$page|escape}/</code>.</p>
            </div>
        {/if}
    </section>

    {if $hasOptions}
        <section class="mt-section">
            <header class="mt-section-header"><h2 class="mt-section-title">Page options</h2></header>
            {foreach $optionRows as $opt}
                {if $opt.type == 'bool'}
                    <div class="mt-row">
                        <div>
                            <div class="mt-row-label">{$opt.label|escape}</div>
                            {if $opt.help}<div class="mt-row-help">{$opt.help|escape}</div>{/if}
                        </div>
                        <label class="mt-toggle">
                            <input type="hidden" name="option[{$opt.key|escape}]" value="0">
                            <input type="checkbox" name="option[{$opt.key|escape}]" value="1" {if $opt.value}checked{/if}>
                            <span class="mt-toggle-track"><span class="mt-toggle-thumb"></span></span>
                        </label>
                    </div>
                {else}
                    <div class="mt-field">
                        <label class="mt-field-label" for="opt-{$opt.key|escape}">{$opt.label|escape}</label>
                        {if $opt.help}<div class="mt-row-help">{$opt.help|escape}</div>{/if}
                        <input id="opt-{$opt.key|escape}" class="mt-input" type="text"
                               name="option[{$opt.key|escape}]" value="{$opt.value|escape}">
                    </div>
                {/if}
            {/foreach}
        </section>
    {/if}

    <section class="mt-section">
        <header class="mt-section-header"><h2 class="mt-section-title">SEO</h2></header>

        <div class="mt-inline-row">
            <div class="mt-row-label">Search engine indexing</div>
            <select class="mt-select" name="indexing">
                <option value="inherit"  {if $indexing == 'inherit'}selected{/if}>Inherit from site default</option>
                <option value="allow"    {if $indexing == 'allow'}selected{/if}>Allow</option>
                <option value="disallow" {if $indexing == 'disallow'}selected{/if}>Disallow</option>
            </select>
        </div>

        <div class="mt-field" style="margin-top:16px">
            <div class="mt-field-row">
                <label class="mt-field-label" for="seo-title">SEO title</label>
                <div class="mt-field-tools">
                    <span class="mt-charcount">{$seo.title|strlen}/64</span>
                </div>
            </div>
            <input id="seo-title" class="mt-input" type="text" name="seo_title" maxlength="64" value="{$seo.title|escape}" placeholder="{$pageLabel|escape}">
        </div>

        <div class="mt-field">
            <div class="mt-field-row">
                <label class="mt-field-label" for="seo-desc">SEO description</label>
                <div class="mt-field-tools">
                    <span class="mt-charcount">{$seo.description|strlen}/160</span>
                </div>
            </div>
            <textarea id="seo-desc" class="mt-textarea" name="seo_description" rows="3" maxlength="160">{$seo.description|escape}</textarea>
        </div>

        <div class="mt-field">
            <label class="mt-field-label" for="seo-social">Social image URL</label>
            <input id="seo-social" class="mt-input" type="text" name="seo_social_image" maxlength="500" value="{$seo.social_image|escape}" placeholder="/path/to/og-image.jpg (recommended 1200×630)">
        </div>
    </section>

    <section class="mt-section">
        <header class="mt-section-header"><h2 class="mt-section-title">Layout overrides</h2></header>
        <div class="mt-inline-row">
            <div>
                <div class="mt-row-label">Main menu layout</div>
                <div class="mt-row-help">Override the global main-menu layout for this page only.</div>
            </div>
            <select class="mt-select" name="layout_main_menu">
                {foreach $layoutChoices['main-menu'] as $choice}
                    <option value="{$choice.name|escape}" {if $choice.name == ($layoutOverrides['main-menu']|default:'')}selected{/if}>{$choice.label|escape}</option>
                {/foreach}
            </select>
        </div>
        <div class="mt-inline-row">
            <div>
                <div class="mt-row-label">Footer layout</div>
                <div class="mt-row-help">Override the global footer layout for this page only.</div>
            </div>
            <select class="mt-select" name="layout_footer">
                {foreach $layoutChoices['footer'] as $choice}
                    <option value="{$choice.name|escape}" {if $choice.name == ($layoutOverrides['footer']|default:'')}selected{/if}>{$choice.label|escape}</option>
                {/foreach}
            </select>
        </div>
    </section>

    <section class="mt-section">
        <header class="mt-section-header"><h2 class="mt-section-title">Sub-navigation</h2></header>
        <div class="mt-inline-row">
            <div>
                <div class="mt-row-label">Section sub-nav</div>
                <div class="mt-row-help">Show or hide this page's sidebar sub-nav. <strong>Inherit</strong> follows the global toggle (Settings → Order / Website Section Sidebar).</div>
            </div>
            <select class="mt-select" name="subnav">
                <option value="inherit" {if $subnav == 'inherit'}selected{/if}>Inherit (global default)</option>
                <option value="on"      {if $subnav == 'on'}selected{/if}>On (always show)</option>
                <option value="off"     {if $subnav == 'off'}selected{/if}>Off (always hide)</option>
            </select>
        </div>
    </section>

    <section class="mt-section">
        <header class="mt-section-header"><h2 class="mt-section-title">Visibility</h2></header>
        <div class="mt-inline-row">
            <div>
                <div class="mt-row-label">Who can see this page</div>
                <div class="mt-row-help">Disabled pages return 404. Auth-only pages redirect logged-out visitors to login.</div>
            </div>
            <select class="mt-select" name="visibility">
                <option value="public"   {if $visibility == 'public'}selected{/if}>Public</option>
                <option value="auth"     {if $visibility == 'auth'}selected{/if}>Authenticated only</option>
                <option value="disabled" {if $visibility == 'disabled'}selected{/if}>Disabled (404)</option>
            </select>
        </div>
    </section>
</form>

{include file="includes/footer.tpl"}
