{include file="includes/header.tpl"}

<header class="mt-page-header">
    <div class="mt-page-eyebrow">Theme</div>
    <h1 class="mt-page-title">Pages</h1>
    <p class="mt-page-subtitle">Configure template variant, SEO, options and layout overrides for each WHMCS page.</p>
</header>

{if $flashMsg == 'saved'}
    <div class="mt-alert mt-alert-success">Page settings saved.</div>
{/if}

{if $groups|count > 1}
    <div class="mt-tabs">
        {foreach $groups as $g}
            <a class="mt-tab {if $tab == $g}is-active{/if}" href="?module=MyTheme&action=pages&tab={$g|escape:'url'}">{$g|escape}</a>
        {/foreach}
    </div>
{/if}

<section class="mt-section">
    <header class="mt-section-header">
        <h2 class="mt-section-title">{$tab|escape} Pages</h2>
        <span class="mt-section-count">{$pages|count}</span>
    </header>

    {if $pages|count}
        <div class="mt-table-wrap">
            <table class="mt-table">
                <thead>
                    <tr>
                        <th>Name</th>
                        <th>Variant</th>
                        <th>SEO</th>
                        <th>Indexing</th>
                        <th>Visibility</th>
                        <th></th>
                    </tr>
                </thead>
                <tbody>
                    {foreach $pages as $page}
                        <tr>
                            <td class="mt-table-name">
                                <div>{$page.label|escape}</div>
                                {if $page.description}
                                    <div style="font-size:12px;color:var(--mt-text-3);margin-top:2px;">{$page.description|escape}</div>
                                {/if}
                            </td>
                            <td>{$page.variantLabel|escape}</td>
                            <td>
                                {if $page.hasSeo}
                                    <span class="mt-badge mt-badge-success">SEO</span>
                                {else}
                                    <span class="mt-badge mt-badge-neutral">—</span>
                                {/if}
                            </td>
                            <td>
                                {if $page.indexing == 'allow'}
                                    <span class="mt-badge mt-badge-success">Allow</span>
                                {elseif $page.indexing == 'disallow'}
                                    <span class="mt-badge mt-badge-warning">Disallow</span>
                                {else}
                                    <span class="mt-badge mt-badge-neutral">Inherit</span>
                                {/if}
                            </td>
                            <td>
                                {if $page.visibility == 'disabled'}
                                    <span class="mt-badge mt-badge-warning">Disabled</span>
                                {elseif $page.visibility == 'auth'}
                                    <span class="mt-badge mt-badge-primary">Auth only</span>
                                {else}
                                    <span class="mt-badge mt-badge-neutral">Public</span>
                                {/if}
                            </td>
                            <td class="mt-table-actions">
                                <a href="?module=MyTheme&action=pages&sub=edit&page={$page.name|escape:'url'}" class="mt-btn mt-btn-ghost mt-btn-sm">Edit</a>
                            </td>
                        </tr>
                    {/foreach}
                </tbody>
            </table>
        </div>
    {else}
        <div class="mt-empty">
            <h3 class="mt-empty-title">No pages in this group</h3>
            <p>Add pages to <code>templates/&lt;slug&gt;/theme.json</code> under <code>provides.pages</code>, then create <code>core/pages/&lt;page&gt;/page.php</code> with the matching group.</p>
        </div>
    {/if}
</section>

{include file="includes/footer.tpl"}
