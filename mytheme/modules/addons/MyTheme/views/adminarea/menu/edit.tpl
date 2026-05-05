{include file="includes/header.tpl"}

<div class="mt-toolbar">
    <a class="mt-back" href="{$viewHelper->url('menu')}">
        <svg viewBox="0 0 16 16" fill="none"><path d="M10 13L5 8l5-5" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round"/></svg>
        Back to Menu
    </a>
    <button class="mt-btn mt-btn-primary mt-btn-sm">Save changes</button>
</div>

<header class="mt-page-header">
    <h1 class="mt-page-title">{$menuName|escape} <span class="mt-page-meta">/ Menu editor</span></h1>
    <p class="mt-page-subtitle">Drag to reorder. Click a row to edit, or use the icon buttons on hover.</p>
</header>

<div class="mt-menu-split">
    <section class="mt-section">
        <header class="mt-section-header">
            <h2 class="mt-section-title">Menu Items</h2>
            <span class="mt-section-count">{$items|count} items</span>
        </header>

        {function name=menuRow}
            <div class="mt-menu-item{if $item.divider} is-divider{/if}">
                {if $item.divider}
                    divider
                {else}
                    <span class="mt-menu-handle"><svg viewBox="0 0 16 16" fill="none"><circle cx="6" cy="4" r="1" fill="currentColor"/><circle cx="10" cy="4" r="1" fill="currentColor"/><circle cx="6" cy="8" r="1" fill="currentColor"/><circle cx="10" cy="8" r="1" fill="currentColor"/><circle cx="6" cy="12" r="1" fill="currentColor"/><circle cx="10" cy="12" r="1" fill="currentColor"/></svg></span>
                    <span class="mt-menu-name">{$item.name|escape}</span>
                    {if $item.badge}<span class="mt-badge mt-badge-neutral">{$item.badge|escape}</span>{/if}
                {/if}
            </div>
        {/function}

        <div class="mt-menu-tree">
            {foreach $items as $item}
                {menuRow item=$item}
                {if $item.children}
                    <div class="mt-menu-children">
                        {foreach $item.children as $child}
                            {menuRow item=$child}
                        {/foreach}
                        <button type="button" class="mt-menu-add">+ Add child</button>
                    </div>
                {/if}
            {/foreach}
            <button type="button" class="mt-menu-add" style="margin-top:8px">+ Add menu item</button>
        </div>
    </section>

    <section class="mt-section">
        <header class="mt-section-header"><h2 class="mt-section-title">Menu Settings</h2></header>

        <div class="mt-field">
            <label class="mt-field-label" for="menu-name">Name</label>
            <input id="menu-name" class="mt-input" type="text" name="name" value="{$menuName|escape}">
        </div>

        <div class="mt-field">
            <label class="mt-field-label" for="menu-rule">Display Rule</label>
            <select id="menu-rule" class="mt-select" name="rule">
                <option {if $displayRule == 'Guest Client'}selected{/if}>Guest Client</option>
                <option {if $displayRule == 'Existing Client'}selected{/if}>Existing Client</option>
                <option>Both</option>
                <option>Unassigned</option>
            </select>
            <div class="mt-field-help">Decides for which audience this menu renders.</div>
        </div>

        <div class="mt-row">
            <div>
                <div class="mt-row-label">Status</div>
                <div class="mt-row-help">Active menus render in the client area.</div>
            </div>
            <label class="mt-toggle"><input type="checkbox" name="active" {if $active}checked{/if}><span class="mt-toggle-track"><span class="mt-toggle-thumb"></span></span></label>
        </div>
    </section>
</div>

{include file="includes/footer.tpl"}
