{include file="includes/header.tpl"}

<header class="mt-page-header">
    <div class="mt-page-eyebrow">Theme</div>
    <h1 class="mt-page-title">Extensions {include file="includes/doclink.tpl" article="addon" anchor="sections"}</h1>
    <p class="mt-page-subtitle">Optional theme add-ons (module integrations, custom widgets, etc.).</p>
</header>

{* Extension modules: separate WHMCS addons that registered themselves with
   Helpers\Extensions. Listed first because they are the ones with a page to
   open; the theme extensions below are files inside the theme folder. *}
{if $mtExtensions|default:[]|count}
<div class="mt-panel pad">
<section class="mt-section">
    <header class="mt-section-header"><h2 class="mt-section-title">Modules</h2></header>
    <div class="mt-grid">
        {foreach $mtExtensions as $mtExt}
            <div class="mt-card">
                <div class="mt-card-thumb">{$mtExt.name|escape|truncate:1:""}</div>
                <div>
                    <h3 class="mt-card-title">{$mtExt.name|escape}</h3>
                    <p class="mt-card-meta">{$mtExt.description|escape}</p>
                </div>
                <div class="mt-card-footer">
                    <span class="mt-badge mt-badge-success">Active{if $mtExt.version} &middot; v{$mtExt.version|escape}{/if}</span>
                    <a class="mt-btn mt-btn-secondary mt-btn-sm" href="{$mtExt.url|escape}">Open</a>
                </div>
            </div>
        {/foreach}
    </div>
</section>
</div>
{/if}

<div class="mt-panel pad">
<section class="mt-section">
    {if $extensions|count}
        <div class="mt-grid">
            {foreach $extensions as $ext}
                <div class="mt-card">
                    <div class="mt-card-thumb">{$ext|escape|truncate:1:""}</div>
                    <div>
                        <h3 class="mt-card-title">{$ext|escape}</h3>
                        <p class="mt-card-meta">Theme extension</p>
                    </div>
                    <div class="mt-card-footer">
                        <span class="mt-badge mt-badge-success">Enabled</span>
                    </div>
                </div>
            {/foreach}
        </div>
    {else}
        <div class="mt-empty">
            <svg class="mt-empty-icon" viewBox="0 0 40 40" fill="none">
                <rect x="6" y="6" width="12" height="12" rx="2" stroke="currentColor" stroke-width="2"/>
                <rect x="22" y="6" width="12" height="12" rx="2" stroke="currentColor" stroke-width="2"/>
                <rect x="6" y="22" width="12" height="12" rx="2" stroke="currentColor" stroke-width="2"/>
            </svg>
            <h3 class="mt-empty-title">No extensions installed</h3>
            <p>Theme extensions appear here once added under <code>core/extensions/&lt;name&gt;/</code> and registered in <code>theme.json</code>.</p>
        </div>
    {/if}
</section>
</div>

{include file="includes/footer.tpl"}
