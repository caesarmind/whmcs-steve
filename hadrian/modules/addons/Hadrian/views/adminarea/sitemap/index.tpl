{include file="includes/header.tpl"}

<div class="mt-toolbar">
    {* The note stays; the button moved to the floating bar. It used to reach
       its form across the page with form="sitemap-form" -- inside the form it
       needs no association at all. *}
    <div class="mt-row-help" style="margin:0;">Written to your WHMCS web root as <code>sitemap.xml</code>{if $cfg.robots} and a managed block in <code>robots.txt</code>{/if}.</div>
</div>

<header class="mt-page-header">
    <div class="mt-page-eyebrow">SEO</div>
    <h1 class="mt-page-title">Sitemap <span class="mt-page-meta">/ robots.txt</span></h1>
    <p class="mt-page-subtitle">Generate <code>sitemap.xml</code> from your pages and content, and manage a preserved block in <code>robots.txt</code>.</p>
</header>

{if $flashMsg}<div class="mt-alert mt-alert-success">{$flashMsg|escape}</div>{/if}
{if $flashErr}<div class="mt-alert mt-alert-danger">{$flashErr|escape}</div>{/if}
{if !$rootWritable}
    <div class="mt-alert mt-alert-warning">The web root isn't writable by PHP, so generation will fail. Grant write permission to the WHMCS root directory and try again.</div>
{/if}

<form id="sitemap-form" method="post" action="?module=Hadrian&action=sitemap&sub=save">

    <div class="mt-panel">

    <section class="mt-section">
        <header class="mt-section-header"><h2 class="mt-section-title">Sitemap</h2></header>

        <div class="mt-row">
            <div>
                <div class="mt-row-label">Enable sitemap</div>
                <div class="mt-row-help">Generate and write <code>sitemap.xml</code> to the web root.</div>
            </div>
            <label class="mt-toggle">
                <input type="checkbox" name="enabled" value="1" {if $cfg.enabled}checked{/if}>
                <span class="mt-toggle-track"><span class="mt-toggle-thumb"></span></span>
            </label>
        </div>

        <div class="mt-inline-row">
            <div class="mt-row-label">Change frequency</div>
            <select class="mt-select" name="frequency">
                {foreach $frequencies as $f}
                    <option value="{$f}" {if $cfg.frequency == $f}selected{/if}>{$f|capitalize}</option>
                {/foreach}
            </select>
        </div>

        <div class="mt-row">
            <div>
                <div class="mt-row-label">Manage robots.txt</div>
                <div class="mt-row-help">Add a <code>Sitemap:</code> line plus <code>Disallow</code> rules for no-index pages, inside comment markers. Any existing <code>robots.txt</code> content is preserved.</div>
            </div>
            <label class="mt-toggle">
                <input type="checkbox" name="robots" value="1" {if $cfg.robots}checked{/if}>
                <span class="mt-toggle-track"><span class="mt-toggle-thumb"></span></span>
            </label>
        </div>
    </section>

    <section class="mt-section">
        <header class="mt-section-header"><h2 class="mt-section-title">Include in sitemap</h2></header>

        <div class="mt-row">
            <div>
                <div class="mt-row-label">Static pages</div>
                <div class="mt-row-help">Public, indexable pages with a URL set on the Pages tab. <strong>{$pageCount}</strong> currently qualify (always included).</div>
            </div>
            <span class="mt-badge mt-badge-neutral">{$pageCount}</span>
        </div>

        <div class="mt-row">
            <div>
                <div class="mt-row-label">Product groups</div>
                <div class="mt-row-help">One entry per visible store product group.</div>
            </div>
            <label class="mt-toggle">
                <input type="checkbox" name="productGroups" value="1" {if $cfg.productGroups}checked{/if}>
                <span class="mt-toggle-track"><span class="mt-toggle-thumb"></span></span>
            </label>
        </div>

        <div class="mt-row">
            <div>
                <div class="mt-row-label">Announcements</div>
                <div class="mt-row-help">One entry per published announcement.</div>
            </div>
            <label class="mt-toggle">
                <input type="checkbox" name="announcements" value="1" {if $cfg.announcements}checked{/if}>
                <span class="mt-toggle-track"><span class="mt-toggle-thumb"></span></span>
            </label>
        </div>

        <div class="mt-row">
            <div>
                <div class="mt-row-label">Knowledge base</div>
                <div class="mt-row-help">Public knowledge base categories and articles.</div>
            </div>
            <label class="mt-toggle">
                <input type="checkbox" name="knowledgebase" value="1" {if $cfg.knowledgebase}checked{/if}>
                <span class="mt-toggle-track"><span class="mt-toggle-thumb"></span></span>
            </label>
        </div>

        <div class="mt-row">
            <div>
                <div class="mt-row-label">Downloads</div>
                <div class="mt-row-help">Visible download categories. Off by default (downloads are often gated).</div>
            </div>
            <label class="mt-toggle">
                <input type="checkbox" name="downloads" value="1" {if $cfg.downloads}checked{/if}>
                <span class="mt-toggle-track"><span class="mt-toggle-thumb"></span></span>
            </label>
        </div>
    </section>

    </div>
    {include file="includes/savebar.tpl" label="Save & generate"}
</form>

<div class="mt-panel">

<section class="mt-section">
    <header class="mt-section-header"><h2 class="mt-section-title">Generate</h2></header>
    <p class="mt-row-help">
        {if $lastGenerated}Last written: <strong>{$lastGenerated|escape}</strong>.{else}Not generated yet.{/if}
        Saving the settings above also regenerates the files.
    </p>
    <div style="display:flex; gap:8px; flex-wrap:wrap;">
        <a class="mt-btn mt-btn-primary mt-btn-sm" href="?module=Hadrian&action=sitemap&sub=generate">Generate now</a>
        <a class="mt-btn mt-btn-secondary mt-btn-sm" href="?module=Hadrian&action=sitemap&sub=preview">Preview XML</a>
    </div>
</section>

{if $previewXml}
<section class="mt-section">
    <header class="mt-section-header"><h2 class="mt-section-title">Preview</h2></header>
    <pre style="margin:0; padding:14px; background:var(--mt-surface-2); border:1px solid var(--mt-border); border-radius:var(--mt-radius); font-size:12px; line-height:1.5; overflow:auto; max-height:460px; white-space:pre;">{$previewXml|escape}</pre>
</section>
{/if}

</div>

{include file="includes/footer.tpl"}
