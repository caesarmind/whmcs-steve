{include file="includes/header.tpl"}

<header class="mt-page-header">
    <div class="mt-page-eyebrow">Theme</div>
    <h1 class="mt-page-title">Menu</h1>
    <p class="mt-page-subtitle">Build navigation menus and assign them to client / guest audiences.</p>
</header>

<div class="mt-tabs">
    <a class="mt-tab {if $tab == 'main'}is-active{/if}"             href="?module=MyTheme&action=menu&tab=main">Main</a>
    <a class="mt-tab {if $tab == 'secondary'}is-active{/if}"        href="?module=MyTheme&action=menu&tab=secondary">Secondary</a>
    <a class="mt-tab {if $tab == 'footer'}is-active{/if}"           href="?module=MyTheme&action=menu&tab=footer">Footer</a>
    <a class="mt-tab {if $tab == 'footer-secondary'}is-active{/if}" href="?module=MyTheme&action=menu&tab=footer-secondary">Footer secondary</a>
</div>

{if $flashMsg == 'seeded-0'}
    <div class="mt-alert mt-alert-info">Re-seed finished — every preset was already complete, nothing to add.</div>
{elseif $flashMsg|substr:0:7 == 'seeded-'}
    <div class="mt-alert mt-alert-info">Re-seeded {$flashMsg|replace:'seeded-':''|escape} preset(s).</div>
{elseif $flashMsg|substr:0:16 == 'reset-defaults-'}
    <div class="mt-alert mt-alert-info">Reset {$flashMsg|replace:'reset-defaults-':''|escape} WHMCS Defaults preset(s) to factory items.</div>
{/if}

{* Runtime diagnostic — what the frontend will actually render for each
   audience right now. If "Items: 0" or "Picked: (none)" shows below,
   that's why the sidebar looks empty on the public site. *}
<section class="mt-section" style="margin-bottom:18px">
    <header class="mt-section-header">
        <h2 class="mt-section-title">Live state</h2>
        <span class="mt-table-muted" style="font-size:12px">What the frontend renders right now for each audience.</span>
    </header>
    <div class="mt-diag-grid">
        {foreach ['client', 'guest'] as $aud}
        <div class="mt-diag-card{if !$diag[$aud].picked_id} is-warn{/if}">
            <div class="mt-diag-eyebrow">{$aud|capitalize} audience</div>
            <div class="mt-diag-title">
                {if $diag[$aud].picked_name}{$diag[$aud].picked_name|escape}{else}<em>(no active menu)</em>{/if}
            </div>
            <div class="mt-diag-meta">
                {if $diag[$aud].picked_id}
                    {$diag[$aud].picked_items} item{if $diag[$aud].picked_items != 1}s{/if}
                    {if $diag[$aud].picked_items == 0} — that's why the sidebar looks empty{/if}
                {else}
                    Activate a menu for this audience, or click <a href="?module=MyTheme&action=menu&sub=seed">Re-seed presets</a>.
                {/if}
            </div>
        </div>
        {/foreach}
    </div>
</section>

<section class="mt-section">
    <header class="mt-section-header">
        <h2 class="mt-section-title">{if $tab == 'footer-secondary'}Footer Secondary Menu{elseif $tab == 'footer'}Footer Menu{elseif $tab == 'secondary'}Secondary Menu{else}Main Menu{/if}</h2>
        <div class="mt-section-tools">
            <a class="mt-btn mt-btn-ghost mt-btn-sm" href="?module=MyTheme&action=menu&sub=seed" title="Re-seed any missing preset items (won't overwrite existing items)">Re-seed presets</a>
            <a class="mt-btn mt-btn-ghost mt-btn-sm" href="?module=MyTheme&action=menu&sub=reset-defaults" title="Wipe and rebuild the factory preset menus (WHMCS Defaults + Footer Secondary) to match the latest preset" onclick="return confirm('Reset the WHMCS Defaults menus and the Footer Secondary menu? Custom user-curated menus are unaffected.');">Reset WHMCS Defaults</a>
            <form method="post" action="?module=MyTheme&action=menu&sub=create" style="display:inline">
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
