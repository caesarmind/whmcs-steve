{include file="includes/header.tpl"}

<header class="mt-page-header">
    <div class="mt-page-eyebrow">Theme</div>
    <h1 class="mt-page-title">Menu</h1>
    <p class="mt-page-subtitle">Build navigation menus and assign them to display rules.</p>
</header>

<div class="mt-tabs">
    <a class="mt-tab {if $tab == 'main'}is-active{/if}" href="?module=MyTheme&action=menu&tab=main">Main</a>
    <a class="mt-tab {if $tab == 'secondary'}is-active{/if}" href="?module=MyTheme&action=menu&tab=secondary">Secondary</a>
    <a class="mt-tab {if $tab == 'footer'}is-active{/if}" href="?module=MyTheme&action=menu&tab=footer">Footer</a>
</div>

<section class="mt-section">
    <header class="mt-section-header">
        <h2 class="mt-section-title">{if $tab == 'footer'}Footer Menu{elseif $tab == 'secondary'}Secondary Menu{else}Main Menu{/if}</h2>
        <div class="mt-section-tools">
            <button class="mt-btn mt-btn-primary mt-btn-sm">+ New menu</button>
        </div>
    </header>

    <div class="mt-table-wrap">
        <table class="mt-table">
            <thead>
                <tr><th>Name</th><th>Rule</th><th>Status</th><th></th></tr>
            </thead>
            <tbody>
                {foreach $menus as $menu}
                    <tr {if $menu.active}class="is-active"{/if}>
                        <td class="mt-table-name">{$menu.name|escape}</td>
                        <td>{if $menu.rule == 'Unassigned'}<span class="mt-badge mt-badge-neutral">Unassigned</span>{else}{$menu.rule|escape}{/if}</td>
                        <td>{if $menu.active}<span class="mt-badge mt-badge-success">Active</span>{else}<span class="mt-badge mt-badge-neutral">Disabled</span>{/if}</td>
                        <td class="mt-table-actions">
                            <a href="{$viewHelper->url('editMenu', ['name' => $menu.name])}" class="mt-btn mt-btn-ghost mt-btn-sm">Edit</a>
                        </td>
                    </tr>
                {/foreach}
            </tbody>
        </table>
    </div>
</section>

{include file="includes/footer.tpl"}
