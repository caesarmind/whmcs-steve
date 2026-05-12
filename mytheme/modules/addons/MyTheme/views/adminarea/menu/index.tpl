{include file="includes/header.tpl"}

<header class="mt-page-header">
    <div class="mt-page-eyebrow">Theme</div>
    <h1 class="mt-page-title">Menu</h1>
    <p class="mt-page-subtitle">Build navigation menus and assign them to client / guest audiences.</p>
</header>

<div class="mt-tabs">
    <a class="mt-tab {if $tab == 'main'}is-active{/if}"      href="?module=MyTheme&action=menu&tab=main">Main</a>
    <a class="mt-tab {if $tab == 'secondary'}is-active{/if}" href="?module=MyTheme&action=menu&tab=secondary">Secondary</a>
    <a class="mt-tab {if $tab == 'footer'}is-active{/if}"    href="?module=MyTheme&action=menu&tab=footer">Footer</a>
</div>

<section class="mt-section">
    <header class="mt-section-header">
        <h2 class="mt-section-title">{if $tab == 'footer'}Footer Menu{elseif $tab == 'secondary'}Secondary Menu{else}Main Menu{/if}</h2>
        <div class="mt-section-tools">
            <a class="mt-btn mt-btn-ghost mt-btn-sm" href="?module=MyTheme&action=menu&sub=seed" title="Re-seed any missing preset items (won't overwrite existing items)">Re-seed presets</a>
            <button class="mt-btn mt-btn-primary mt-btn-sm" disabled title="Coming next">+ New menu</button>
        </div>
    </header>
    <p class="mt-section-note">
        Only one menu can be active per audience — activating a new <em>Client</em> menu automatically deactivates the previous Client menu, and the same for <em>Guest</em>. The other audience is unaffected.
    </p>

    {if !$menus}
        <div class="mt-empty">
            <p>No menus yet for this location.</p>
            <a class="mt-btn mt-btn-primary mt-btn-sm" href="?module=MyTheme&action=menu&sub=seed">Seed the 4 preset menus</a>
        </div>
    {else}
    <div class="mt-table-wrap">
        <table class="mt-table">
            <thead>
                <tr><th>Name</th><th>Audience</th><th>Items</th><th>Status</th><th></th></tr>
            </thead>
            <tbody>
                {foreach $menus as $menu}
                    <tr {if $menu.active}class="is-active"{/if}>
                        <td class="mt-table-name">
                            <a href="?module=MyTheme&action=menu&sub=edit&id={$menu.id}">{$menu.name|escape}</a>
                            {if $menu.changed}<span class="mt-badge mt-badge-info" title="Edited by you">edited</span>{/if}
                        </td>
                        <td>
                            {if $menu.audience == 'client'}<span class="mt-badge mt-badge-neutral">Client</span>
                            {elseif $menu.audience == 'guest'}<span class="mt-badge mt-badge-neutral">Guest</span>
                            {else}<span class="mt-badge mt-badge-neutral">All</span>{/if}
                        </td>
                        <td>{$menu.item_count} <span class="mt-table-muted">items</span></td>
                        <td>
                            {if $menu.active}<span class="mt-badge mt-badge-success">Active</span>
                            {else}<span class="mt-badge mt-badge-neutral">Disabled</span>{/if}
                        </td>
                        <td class="mt-table-actions">
                            <a href="?module=MyTheme&action=menu&sub=edit&id={$menu.id}" class="mt-btn mt-btn-ghost mt-btn-sm">Edit</a>
                        </td>
                    </tr>
                {/foreach}
            </tbody>
        </table>
    </div>
    {/if}
</section>

{include file="includes/footer.tpl"}
