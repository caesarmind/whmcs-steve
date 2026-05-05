{include file="includes/header.tpl"}

<header class="mt-page-header">
    <div class="mt-page-eyebrow">Theme</div>
    <h1 class="mt-page-title">Pages</h1>
    <p class="mt-page-subtitle">Configure variants and SEO for each WHMCS page.</p>
</header>

<div class="mt-tabs">
    <a class="mt-tab {if $tab == 'categories'}is-active{/if}" href="?module=MyTheme&action=pages&tab=categories">Categories</a>
    <a class="mt-tab {if $tab == 'client-area'}is-active{/if}" href="?module=MyTheme&action=pages&tab=client-area">Client Area</a>
    <a class="mt-tab {if $tab == 'order'}is-active{/if}" href="?module=MyTheme&action=pages&tab=order">Order</a>
</div>

<section class="mt-section">
    <header class="mt-section-header">
        <h2 class="mt-section-title">Client Area Pages</h2>
        <span class="mt-section-count">{$pages|count}</span>
    </header>

    {if $pages|count}
        <div class="mt-table-wrap">
            <table class="mt-table">
                <thead>
                    <tr><th>Name</th><th>SEO</th><th>Template</th><th></th></tr>
                </thead>
                <tbody>
                    {foreach $pages as $page}
                        <tr>
                            <td class="mt-table-name">{$page.label|escape}</td>
                            <td>{if $page.seo}<span class="mt-badge mt-badge-success">SEO</span>{else}<span class="mt-badge mt-badge-neutral">—</span>{/if}</td>
                            <td>{$page.variant|escape}</td>
                            <td class="mt-table-actions">
                                <a href="{$viewHelper->url('editPage', ['page' => $page.name])}" class="mt-btn mt-btn-ghost mt-btn-sm">Edit</a>
                            </td>
                        </tr>
                    {/foreach}
                </tbody>
            </table>
        </div>
    {else}
        <div class="mt-empty">
            <h3 class="mt-empty-title">No pages declared</h3>
            <p>Add pages to <code>templates/&lt;slug&gt;/theme.json</code> under <code>provides.pages</code>.</p>
        </div>
    {/if}
</section>

{include file="includes/footer.tpl"}
