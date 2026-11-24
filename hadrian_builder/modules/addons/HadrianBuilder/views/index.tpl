{include file="includes/header.tpl"}

{* Page-local styles. Prefixed mt-pb- so nothing here can collide with a shared
   name in Hadrian's admin stylesheet; its shell classes (mt-panel, mt-table,
   mt-btn...) are used as they are. *}
<style>{literal}
.mt-pb-new { display: flex; gap: 10px; align-items: flex-end; flex-wrap: wrap; }
.mt-pb-new .mt-field { flex: 1; min-width: 240px; margin: 0; }
.mt-pb-table-wrap { border: 1px solid var(--mt-border); border-radius: var(--mt-radius); overflow: hidden; }
.mt-pb-name { font-weight: 500; }
.mt-pb-addr { font-family: ui-monospace, Menlo, Consolas, monospace; font-size: 12.5px; color: var(--mt-text-2); }
.mt-pb-none { color: var(--mt-text-3); }
.mt-pb-actions { display: flex; gap: 8px; align-items: center; justify-content: flex-end; flex-wrap: wrap; }
.mt-pb-actions form { margin: 0; }
.mt-pb-linkbtn { background: none; border: 0; padding: 0; font: inherit; font-size: 13px; color: var(--mt-text-3); cursor: pointer; }
.mt-pb-linkbtn:hover { color: var(--mt-danger); }
.mt-pb-site { display: flex; align-items: center; gap: 18px; flex-wrap: wrap; }
.mt-pb-site-text { flex: 1; min-width: 240px; }
.mt-pb-site-title { font-size: 15px; font-weight: 600; color: var(--mt-text); }
.mt-pb-site-sub { font-size: 12.5px; color: var(--mt-text-3); margin-top: 3px; }
.mt-pb-seg { display: inline-flex; gap: 2px; padding: 3px; margin: 0; background: var(--mt-surface-2); border: 1px solid var(--mt-border); border-radius: 999px; }
.mt-pb-seg button { border: 0; background: none; padding: 6px 16px; border-radius: 999px; font: inherit; font-size: 13px; font-weight: 600; color: var(--mt-text-2); cursor: pointer; }
.mt-pb-seg button.is-on { background: var(--mt-surface); color: var(--mt-text); box-shadow: 0 1px 2px rgba(0,0,0,.08), 0 0 0 1px var(--mt-border); }
.mt-pb-replace { display: flex; gap: 6px; margin: 0; }
.mt-pb-replace .mt-select { height: 32px; padding-top: 0; padding-bottom: 0; font-size: 12.5px; min-width: 0; }
.mt-pb-empty { padding: 28px 16px; text-align: center; color: var(--mt-text-3); font-size: 14px; }
{/literal}</style>

<header class="mt-page-header">
    <div class="mt-page-eyebrow">Website</div>
    <h1 class="mt-page-title">Page builder</h1>
    <p class="mt-page-subtitle">Build pages from sections, see them in your theme while you edit, and publish them at their own addresses or in place of a theme page.</p>
</header>

{if $flashMsg}<div class="mt-alert mt-alert-success">{$flashMsg|escape}</div>{/if}
{if $flashErr}<div class="mt-alert mt-alert-danger">{$flashErr|escape}</div>{/if}

{* Which version of the site visitors get. Only theme pages that have a built
   replacement change; see the Replaces column below. *}
<div class="mt-panel pad" id="pb-site">
    <div class="mt-pb-site">
        <div class="mt-pb-site-text">
            <div class="mt-pb-site-title">Website served by</div>
            <div class="mt-pb-site-sub">
                {if $siteMode == 'builder'}Theme pages that have a built replacement show it. Every other page keeps the theme.
                {else}Every website page uses the theme. Built replacements are kept, so switching is instant either way.{/if}
                {if $serving} <strong>{$serving}</strong> built {if $serving == 1}page is{else}pages are{/if} replacing a theme page now.{/if}
            </div>
        </div>
        <form method="post" action="{$base}&action=mode" class="mt-pb-seg" role="group" aria-label="Website served by">
            <input type="hidden" name="token" value="{$token|escape}">
            <button type="submit" name="mode" value="theme" class="{if $siteMode != 'builder'}is-on{/if}" aria-pressed="{if $siteMode != 'builder'}true{else}false{/if}">Theme</button>
            <button type="submit" name="mode" value="builder" class="{if $siteMode == 'builder'}is-on{/if}" aria-pressed="{if $siteMode == 'builder'}true{else}false{/if}">Page Builder</button>
        </form>
    </div>
</div>

<form method="post" action="{$base}&action=create" class="mt-panel pad">
    <input type="hidden" name="token" value="{$token|escape}">
    <div class="mt-pb-new">
        <div class="mt-field">
            <label class="mt-field-label" for="pb-name">New page</label>
            <input type="text" class="mt-input" id="pb-name" name="name" maxlength="120" placeholder="For example: WordPress hosting" required>
        </div>
        <button type="submit" class="mt-btn mt-btn-primary">Create page</button>
    </div>
    <p class="mt-row-help" style="margin:10px 0 0;">The page starts as a draft. Nothing is public until you publish it.</p>
</form>

<div class="mt-panel pad">
    <h2 class="mt-section-title" style="margin:0 0 12px;">Pages</h2>
    <div class="mt-pb-table-wrap">
        {if $pages}
            <table class="mt-table">
                <thead>
                    <tr><th>Name</th><th>Address</th><th>Replaces</th><th>Status</th><th></th></tr>
                </thead>
                <tbody>
                    {foreach $pages as $page}
                        <tr>
                            <td><a class="mt-pb-name" href="{$base}&action=edit&id={$page.id}">{$page.name|escape}</a></td>
                            <td>
                                {if $page.url !== ''}
                                    {if $page.status == 'published'}
                                        <a class="mt-pb-addr" href="{$page.url|escape}" target="_blank" rel="noopener">{$page.url|escape}</a>
                                    {else}
                                        <span class="mt-pb-addr">{$page.url|escape}</span>
                                    {/if}
                                {else}
                                    <span class="mt-pb-none">No address yet</span>
                                {/if}
                            </td>
                            <td>
                                <form method="post" action="{$base}&action=replace" class="mt-pb-replace">
                                    <input type="hidden" name="token" value="{$token|escape}">
                                    <input type="hidden" name="id" value="{$page.id}">
                                    <select class="mt-select" name="replaces" aria-label="Theme page this replaces" onchange="this.form.submit()">
                                        <option value="">Nothing</option>
                                        {foreach $targets as $key => $label}
                                            <option value="{$key|escape}"{if $page.replaces == $key} selected{/if}>{$label|escape}</option>
                                        {/foreach}
                                    </select>
                                    {if $page.replaces !== ''}
                                        <select class="mt-select" name="replace_rule" aria-label="When it replaces" onchange="this.form.submit()">
                                            <option value="follow"{if $page.replace_rule == 'follow'} selected{/if}>Follow site</option>
                                            <option value="always"{if $page.replace_rule == 'always'} selected{/if}>Always</option>
                                            <option value="never"{if $page.replace_rule == 'never'} selected{/if}>Never</option>
                                        </select>
                                    {/if}
                                </form>
                            </td>
                            <td>
                                {if $page.status != 'published'}<span class="mt-badge mt-badge-warning">Draft</span>
                                {elseif $page.serving}<span class="mt-badge mt-badge-primary">Serving</span>
                                {elseif $page.replaces !== ''}<span class="mt-badge mt-badge-neutral">Standby</span>
                                {else}<span class="mt-badge mt-badge-success">Published</span>{/if}
                            </td>
                            <td>
                                <div class="mt-pb-actions">
                                    <a class="mt-btn mt-btn-secondary mt-btn-sm" href="{$base}&action=edit&id={$page.id}">Edit</a>
                                    <form method="post" action="{$base}&action=delete" onsubmit="return confirm('Delete this page? This cannot be undone.');">
                                        <input type="hidden" name="token" value="{$token|escape}">
                                        <input type="hidden" name="id" value="{$page.id}">
                                        <button type="submit" class="mt-pb-linkbtn">Delete</button>
                                    </form>
                                </div>
                            </td>
                        </tr>
                    {/foreach}
                </tbody>
            </table>
        {else}
            <div class="mt-pb-empty">No pages yet. Name one above to start.</div>
        {/if}
    </div>
    <p class="mt-row-help" style="margin:12px 0 0;">{$sections} section types are installed. A built page's own address can never take over one WHMCS uses. Replaces lets a published page stand in for a theme page: Serving means visitors get it there now, Standby means the theme's page is showing.</p>
</div>

{include file="includes/footer.tpl"}
