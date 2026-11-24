{include file="includes/header.tpl"}

<header class="mt-page-header">
    <div class="mt-page-eyebrow">Theme</div>
    <h1 class="mt-page-title">Menu {include file="includes/doclink.tpl" article="menu-manager"}</h1>
    <p class="mt-page-subtitle">Build navigation menus and choose who sees them: guests, clients, or everyone in one area of the site.</p>
</header>

<div class="mt-tabs">
    <a class="mt-tab {if $tab == 'main'}is-active{/if}"             href="?module=Hadrian&action=menu&tab=main">Main</a>
    <a class="mt-tab {if $tab == 'secondary'}is-active{/if}"        href="?module=Hadrian&action=menu&tab=secondary">Secondary</a>
    <a class="mt-tab {if $tab == 'footer'}is-active{/if}"           href="?module=Hadrian&action=menu&tab=footer">Footer</a>
    <a class="mt-tab {if $tab == 'footer-secondary'}is-active{/if}" href="?module=Hadrian&action=menu&tab=footer-secondary">Footer secondary</a>
</div>

{if $flashMsg == 'seeded-0'}
    <div class="mt-alert mt-alert-info">Re-seed finished — every preset was already complete, nothing to add.</div>
{elseif $flashMsg|substr:0:7 == 'seeded-'}
    <div class="mt-alert mt-alert-info">Re-seeded {$flashMsg|replace:'seeded-':''|escape} preset(s).</div>
{elseif $flashMsg == 'areas-saved'}
    <div class="mt-alert mt-alert-info">Menus by area saved.</div>
{elseif $flashMsg|substr:0:16 == 'reset-defaults-'}
    <div class="mt-alert mt-alert-info">Reset {$flashMsg|replace:'reset-defaults-':''|escape} WHMCS Defaults preset(s) to factory items.</div>
{/if}

<div class="mt-panel pad">
<section class="mt-section">
    <header class="mt-section-header">
        <h2 class="mt-section-title">{if $tab == 'footer-secondary'}Footer Secondary Menu{elseif $tab == 'footer'}Footer Menu{elseif $tab == 'secondary'}Secondary Menu{else}Main Menu{/if}</h2>
        {include file="includes/doclink.tpl" article="menu-manager" anchor="building-a-menu"}
        <div class="mt-section-tools">
            <a class="mt-btn mt-btn-ghost mt-btn-sm" href="?module=Hadrian&action=menu&sub=seed&amp;token={$csrfToken|escape:'url'}" title="Re-seed any missing preset items (won't overwrite existing items)">Re-seed presets</a>
            <a class="mt-btn mt-btn-ghost mt-btn-sm" href="?module=Hadrian&action=menu&sub=reset-defaults&amp;token={$csrfToken|escape:'url'}" title="Wipe and rebuild the factory preset menus (WHMCS Defaults + Footer Secondary) to match the latest preset" onclick="return confirm('Reset the WHMCS Defaults menus and the Footer Secondary menu? Custom user-curated menus are unaffected.');">Reset WHMCS Defaults</a>
            <a class="mt-btn mt-btn-ghost mt-btn-sm" href="?module=Hadrian&action=menu&sub=seed&force=1&amp;token={$csrfToken|escape:'url'}" title="Rebuild ALL preset menus (main + footer) to exactly match the shipped presets, overwriting their current items with the latest defaults" onclick="return confirm('Force re-sync every preset menu (main + footer) to the shipped defaults? This overwrites their current items.');">Force re-sync to presets</a>
            <form method="post" action="?module=Hadrian&action=menu&sub=create" style="display:inline">
                <input type="hidden" name="location" value="{$tab|escape}">
                <button type="submit" class="mt-btn mt-btn-primary mt-btn-sm" title="Create a blank menu in this tab and open it for editing">+ New menu</button>
            </form>
        </div>
    </header>
    <p class="mt-section-note">
        Only one menu can be active per audience — activating a new <em>Client</em> menu automatically deactivates the previous Client menu, and the same for <em>Guest</em>. The other audience is unaffected.
    </p>

    {if !$menus}
        <div class="mt-empty">
            <p>No menus yet for this location.</p>
            <a class="mt-btn mt-btn-primary mt-btn-sm" href="?module=Hadrian&action=menu&sub=seed&amp;token={$csrfToken|escape:'url'}">Seed the 4 preset menus</a>
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
                            <a href="?module=Hadrian&action=menu&sub=edit&id={$menu.id}">{$menu.name|escape}</a>
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
                            {elseif empty($menu.areas)}<span class="mt-badge mt-badge-neutral">Disabled</span>{/if}
                            {if !empty($menu.areas)}
                                {foreach $menu.areas as $areaLabel}
                                    <span class="mt-badge mt-badge-primary" data-menu-area-badge title="Shown to everyone in this area">{$areaLabel|escape}</span>
                                {/foreach}
                            {/if}
                        </td>
                        <td class="mt-table-actions">
                            <a href="?module=Hadrian&action=menu&sub=edit&id={$menu.id}" class="mt-btn mt-btn-ghost mt-btn-sm">Edit</a>
                        </td>
                    </tr>
                {/foreach}
            </tbody>
        </table>
    </div>
    {/if}
</section>
</div>

{* One menu per area, as an alternative to one per visitor. Every area starts
   on "By visitor", which is the rule the table above describes, so this panel
   changes nothing until an area is given a menu. *}
{if $menus && !empty($areaLabels)}
<div class="mt-panel pad">
<section class="mt-section" data-menu-areas>
    <header class="mt-section-header">
        <h2 class="mt-section-title">Menus by area</h2>
        {include file="includes/doclink.tpl" article="menu-manager" anchor="menus-by-area"}
    </header>
    <p class="mt-section-note">
        Give a part of the site its own menu. Everyone there sees it, guest or client, whatever the menu's audience and status above. Its items still follow their own audience, so a <em>Sign in</em> item for guests stays hidden from clients.
    </p>
    <form method="post" action="?module=Hadrian&action=menu&sub=areas">
        <input type="hidden" name="location" value="{$tab|escape}">
        {foreach $areaLabels as $areaKey => $areaLabel}
            <div class="mt-row">
                <div>
                    <div class="mt-row-label">{$areaLabel|escape}</div>
                    <div class="mt-row-help">{$areaHelp[$areaKey]|default:''|escape}</div>
                </div>
                {assign var=areaPick value=$areaPicks[$areaKey]|default:0}
                <select class="mt-select" name="area_menu[{$areaKey|escape}]" data-menu-area="{$areaKey|escape}" style="max-width:320px">
                    <option value="0" {if $areaPick == 0}selected{/if}>By visitor (guest / client)</option>
                    {foreach $menus as $menu}
                        <option value="{$menu.id}" {if $areaPick == $menu.id}selected{/if}>{$menu.name|escape}</option>
                    {/foreach}
                </select>
            </div>
        {/foreach}
        <div style="display:flex;justify-content:flex-end;padding-top:16px">
            <button type="submit" class="mt-btn mt-btn-primary mt-btn-sm">Save menus by area</button>
        </div>
    </form>
</section>
</div>
{/if}

{include file="includes/footer.tpl"}
