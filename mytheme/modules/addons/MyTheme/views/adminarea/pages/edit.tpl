{include file="includes/header.tpl"}

<div class="mt-toolbar">
    <a class="mt-back" href="{$viewHelper->url('pages')}">
        <svg viewBox="0 0 16 16" fill="none"><path d="M10 13L5 8l5-5" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round"/></svg>
        Back to Pages
    </a>
    <button form="page-edit-form" class="mt-btn mt-btn-primary mt-btn-sm">Save changes</button>
</div>

<header class="mt-page-header">
    <h1 class="mt-page-title">{$pageLabel|escape} <span class="mt-page-meta">/ Page editor</span></h1>
    <p class="mt-page-subtitle">Pick a template variant, override layout, and tune SEO for this page.</p>
</header>

<form id="page-edit-form" method="post" action="">
    <input type="hidden" name="page" value="{$page|escape}">

    <section class="mt-section">
        <header class="mt-section-header"><h2 class="mt-section-title">Page Template</h2></header>
        <div class="mt-variant-grid">
            {foreach $variants as $key => $label}
                <label class="mt-variant {if $key == $activeVariant}is-active{/if}">
                    <input type="radio" name="variant" value="{$key|escape}" {if $key == $activeVariant}checked{/if} hidden>
                    <div>
                        <div class="mt-variant-name">{$label|escape}</div>
                    </div>
                    {if $key == $activeVariant}
                        <span class="mt-badge mt-badge-success">Active</span>
                    {else}
                        <span class="mt-badge mt-badge-neutral">Click to activate</span>
                    {/if}
                </label>
            {/foreach}
        </div>
    </section>

    <section class="mt-section">
        <header class="mt-section-header"><h2 class="mt-section-title">Template Settings</h2></header>
        <div class="mt-row">
            <div>
                <div class="mt-row-label">Full Page</div>
                <div class="mt-row-help">Hide the standard navbar and footer.</div>
            </div>
            <label class="mt-toggle"><input type="checkbox" name="full_page"><span class="mt-toggle-track"><span class="mt-toggle-thumb"></span></span></label>
        </div>
        <div class="mt-row">
            <div>
                <div class="mt-row-label">Show Logo</div>
                <div class="mt-row-help">Show the brand logo at the top of the page.</div>
            </div>
            <label class="mt-toggle"><input type="checkbox" name="show_logo" checked><span class="mt-toggle-track"><span class="mt-toggle-thumb"></span></span></label>
        </div>
    </section>

    <section class="mt-section">
        <header class="mt-section-header"><h2 class="mt-section-title">Page Settings — SEO</h2></header>

        <div class="mt-inline-row">
            <div class="mt-row-label">Search Engine Indexing</div>
            <select class="mt-select" name="indexing">
                <option value="allow">Allow</option>
                <option value="disallow">Disallow</option>
                <option value="inherit">Inherit from site default</option>
            </select>
        </div>

        <div class="mt-field" style="margin-top:16px">
            <div class="mt-field-row">
                <label class="mt-field-label" for="seo-title">SEO Title</label>
                <div class="mt-field-tools">
                    <span class="mt-charcount">0/64</span>
                </div>
            </div>
            <input id="seo-title" class="mt-input" type="text" name="seo_title" maxlength="64" placeholder="{$pageLabel|escape} — Hostnodes">
        </div>

        <div class="mt-field">
            <div class="mt-field-row">
                <label class="mt-field-label" for="seo-desc">SEO Description</label>
                <div class="mt-field-tools">
                    <span class="mt-charcount">0/160</span>
                </div>
            </div>
            <textarea id="seo-desc" class="mt-textarea" name="seo_description" rows="3" maxlength="160"></textarea>
        </div>

        <div class="mt-field">
            <label class="mt-field-label">Social Image</label>
            <div class="mt-upload">
                <svg class="mt-upload-icon" width="28" height="28" viewBox="0 0 40 40" fill="none"><path d="M20 6v22M11 15l9-9 9 9M6 28v3a3 3 0 003 3h22a3 3 0 003-3v-3" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/></svg>
                <div class="mt-upload-text">Click to upload</div>
                <div class="mt-upload-hint">Recommended: 1200×630</div>
            </div>
        </div>
    </section>

    <section class="mt-section">
        <header class="mt-section-header"><h2 class="mt-section-title">Custom Layout</h2></header>
        <div class="mt-inline-row">
            <div>
                <div class="mt-row-label">Main Menu Layout</div>
                <div class="mt-row-help">Override the global main-menu layout for this page only.</div>
            </div>
            <select class="mt-select" name="main_menu_layout">
                <option>Default</option>
                <option>Banner</option>
                <option>Condensed</option>
                <option>Left</option>
            </select>
        </div>
        <div class="mt-inline-row">
            <div>
                <div class="mt-row-label">Footer Layout</div>
                <div class="mt-row-help">Override the global footer layout for this page only.</div>
            </div>
            <select class="mt-select" name="footer_layout">
                <option>Default</option>
                <option>Extended</option>
            </select>
        </div>
    </section>
</form>

{include file="includes/footer.tpl"}
