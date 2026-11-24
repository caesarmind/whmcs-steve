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
.mt-pb-empty { padding: 28px 16px; text-align: center; color: var(--mt-text-3); font-size: 14px; }
{/literal}</style>

<header class="mt-page-header">
    <div class="mt-page-eyebrow">Website</div>
    <h1 class="mt-page-title">Page builder</h1>
    <p class="mt-page-subtitle">Build pages from sections, see them in your theme while you edit, and publish them at their own addresses.</p>
</header>

{if $flashMsg}<div class="mt-alert mt-alert-success">{$flashMsg|escape}</div>{/if}
{if $flashErr}<div class="mt-alert mt-alert-danger">{$flashErr|escape}</div>{/if}

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
                    <tr><th>Name</th><th>Address</th><th>Status</th><th></th></tr>
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
                                {if $page.status == 'published'}<span class="mt-badge mt-badge-success">Published</span>
                                {else}<span class="mt-badge mt-badge-warning">Draft</span>{/if}
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
    <p class="mt-row-help" style="margin:12px 0 0;">{$sections} section types are installed. A built page can never replace an address WHMCS itself uses: WHMCS's own pages always win.</p>
</div>

{include file="includes/footer.tpl"}
