{include file="includes/header.tpl"}

{* Short labels for the row-level type tag — keeps "WHMCS Default Navigation
   (pass-through)" from blowing out the row, and gives every type a
   compact, scannable identifier. Falls back to the raw item_type if a
   future PHP type is added without an entry here. *}
{assign var="mtTagFor" value=[
    'whmcs_page'       => 'Page',
    'custom_link'      => 'Link',
    'dropdown_parent'  => 'Dropdown',
    'header'           => 'Header',
    'divider'          => 'Divider',
    'language'         => 'Language',
    'currency'         => 'Currency',
    'login_button'     => 'Login',
    'account_dropdown' => 'Account',
    'whmcs_default'    => 'Default'
]}

<form id="menuForm" method="post" action="?module=MyTheme&action=menu&sub=save">
    <input type="hidden" name="id" value="{$menu->id|escape}">

    {* Resilient form-array fields — one input per (item, property). The
       browser serializes these natively into $_POST['items'] so the save
       works even if JS is broken / disabled. JS still maintains state.items
       for the UX, and at submit time (if dirty) it REPLACES this entire
       <div> with a fresh set of inputs matching state.items.

       IMPORTANT: `parentIdx` must be the parent's DB id, NOT its form-array
       index. The server's persistItems() resolves parent_id by looking up
       the value in $idMap, which is keyed by DB id (string) or 'new_X' for
       new items. Sending the form-array index instead made $idMap[index]
       always miss → parent_id silently became null → on no-op save, every
       child item got flattened to top-level. *}
    <div id="mtItemsFields">
        {function name=mtItemFields idx=0 item=null parentDbId=''}
            <input type="hidden" name="items[{$idx}][id]"           value="{$item->id|escape}">
            <input type="hidden" name="items[{$idx}][item_type]"    value="{$item->item_type|escape}">
            <input type="hidden" name="items[{$idx}][parent_id]"    value="{$parentDbId|escape}">
            <input type="hidden" name="items[{$idx}][position]"     value="{$item->position|escape}">
            <input type="hidden" name="items[{$idx}][label_json]"   value="{$item->label_json|escape}">
            <input type="hidden" name="items[{$idx}][config_json]"  value="{$item->config_json|escape}">
            <input type="hidden" name="items[{$idx}][active]"       value="{if $item->active}1{else}0{/if}">
        {/function}
        {assign var=mtIdx value=0}
        {foreach $tree as $node}
            {mtItemFields idx=$mtIdx item=$node.item parentDbId=''}
            {assign var=mtIdx value=$mtIdx+1}
            {foreach $node.children as $child}
                {mtItemFields idx=$mtIdx item=$child.item parentDbId=$node.item->id}
                {assign var=mtIdx value=$mtIdx+1}
            {/foreach}
        {/foreach}
    </div>

    {* Legacy JSON fallback — used only if form-array regen fails. *}
    <input type="hidden" name="items_json" id="menuItemsJson" value="">

    <div class="mt-toolbar">
        <a class="mt-back" href="?module=MyTheme&action=menu&tab={$menu->location|escape}">
            <svg viewBox="0 0 16 16" fill="none"><path d="M10 13L5 8l5-5" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round"/></svg>
            Back to menus
        </a>
        <div style="flex:1"></div>
        {if $flash == 'saved'}<span class="mt-flash mt-flash-success">Saved</span>{/if}
        {if $flash == 'created'}<span class="mt-flash mt-flash-success">Menu created — set the name, display rule, and status, then add items.</span>{/if}
        {if $flash == 'empty-payload-rejected'}
            <span class="mt-flash mt-flash-warn">
                Save refused — the browser sent zero items so we didn't wipe your menu.
                <a href="?module=MyTheme&action=menu&sub=seed" style="text-decoration:underline">Re-seed presets</a>
                if you want the defaults back.
            </span>
        {/if}
        <button type="submit" class="mt-btn mt-btn-primary mt-btn-sm">Save changes</button>
    </div>

    {* HARD-FAIL BANNER — shown when saveAction refused to save because
       max_input_vars on this host is too low. The save was NOT processed;
       the admin must raise the host limit. *}
    {if $flash == 'max-input-vars-exceeded'}
        <div class="mt-flash mt-flash-warn" style="margin: 12px 0; padding: 16px 20px; display: block; border-left: 4px solid #d97706;">
            <strong style="display: block; margin-bottom: 6px; font-size: 14px;">Save refused — PHP max_input_vars too low</strong>
            <p style="margin: 0 0 8px;">
                Your host's PHP <code>max_input_vars</code> setting is
                <strong>{$smarty.get.limit|escape|default:'?'}</strong>, but this menu would submit
                <strong>{$smarty.get.count|escape|default:'?'}</strong> form fields. PHP would
                silently truncate the request mid-save and your label / URL data would be lost.
            </p>
            <p style="margin: 0 0 6px;"><strong>Fix:</strong> ask your host to raise
                <code>max_input_vars</code> in <code>php.ini</code> to <code>2000</code> or higher.
                On cPanel: <em>Software → Select PHP Version → Options → max_input_vars</em>.
            </p>
            <p style="margin: 0; font-size: 12px; opacity: .75;">
                Nothing was saved on this attempt — your menu is unchanged. Try again after raising the limit.
            </p>
        </div>
    {/if}

    {if $inputVarsWarning}
        <div class="mt-flash mt-flash-warn" style="margin: 12px 0; padding: 12px 16px; display: block; border-left: 4px solid #d97706;">
            <strong>Heads up:</strong> this menu has {$itemCount} items (~{$estimatedVars} form fields per save),
            and your host's <code>max_input_vars</code> is only <code>{$maxInputVars}</code>. Saving WILL
            fail — ask your host to raise <code>max_input_vars</code> in <code>php.ini</code> to
            <code>2000</code> or higher. On cPanel: <em>Software → Select PHP Version → Options → max_input_vars</em>.
        </div>
    {/if}

    <header class="mt-page-header">
        <h1 class="mt-page-title">
            <input type="text" name="name" class="mt-page-title-input" value="{$menu->name|escape}">
            <span class="mt-page-meta">/ Menu editor</span>
        </h1>
        <p class="mt-page-subtitle">Expand a row to edit its properties. Drag the grip to reorder, or use the arrows on touch devices.</p>
    </header>

    {* Two-column grid: tree on the left, menu-level settings as a sticky
       sidebar on the right. The per-item drawer that used to live in this
       right column is now relocated INLINE into the active item's
       .mt-menu-props-slot (see mtPanelHome below + JS openInlinePanel). *}
    <div class="mt-menu-grid">

        {* ────── LEFT: items list ────── *}
        <section class="mt-section mt-menu-tree-col">
            <header class="mt-section-header">
                <h2 class="mt-section-title">Menu Items</h2>
                <span class="mt-section-count" id="mtItemCount">0 items</span>
            </header>

            <div class="mt-menu-tree" id="mtMenuTree" data-tree-root>
                {if empty($tree)}
                    <div class="mt-empty mt-menu-empty" data-empty-state>
                        <p><strong>No Menu Items Created</strong></p>
                        <p class="mt-table-muted">Use the picker below to start adding new menu items.</p>
                    </div>
                {/if}

                {* Two explicit levels of nesting — avoids fragile Smarty {function} recursion
                   which can silently render nothing on some WHMCS Smarty configurations and
                   then trip the persistItems mass-delete safety net on Save. 2 levels covers
                   every realistic menu shape; deeper trees would need a switch to
                   {include}-based recursion. *}
                <ul class="mt-menu-list" data-children>
                    {foreach $tree as $node}
                        {assign var=itm value=$node.item}
                        <li class="mt-menu-item"
                            data-id="{$itm->id}"
                            data-type="{$itm->item_type|escape}"
                            data-active="{if $itm->active}1{else}0{/if}"
                            data-label="{$itm->label_json|escape}"
                            data-config="{$itm->config_json|escape}">
                            <div class="mt-menu-item-row">
                                <span class="mt-menu-grip" aria-hidden="true" title="Drag to reorder">
                                    <svg viewBox="0 0 12 16" fill="none"><circle cx="4" cy="3" r="1" fill="currentColor"/><circle cx="8" cy="3" r="1" fill="currentColor"/><circle cx="4" cy="8" r="1" fill="currentColor"/><circle cx="8" cy="8" r="1" fill="currentColor"/><circle cx="4" cy="13" r="1" fill="currentColor"/><circle cx="8" cy="13" r="1" fill="currentColor"/></svg>
                                </span>
                                <button type="button" class="mt-menu-chev" data-action="toggle-item" title="Expand">
                                    <svg viewBox="0 0 14 14" fill="none"><path d="M5 3l4 4-4 4" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round"/></svg>
                                </button>
                                <span class="mt-menu-type-tag mt-menu-type-tag-{$itm->item_type|escape}" data-role="type-tag">{$mtTagFor[$itm->item_type]|default:$itm->item_type|escape}</span>
                                <span class="mt-menu-name" data-role="label">{$itm->resolvedLabel()|escape}</span>
                                <div class="mt-menu-ctrls">
                                    {if $itemTypes[$itm->item_type]['accepts_children']}
                                        <button type="button" class="mt-menu-btn mt-menu-btn-add" data-action="add-child" title="Add child item">
                                            <svg viewBox="0 0 14 14" fill="none"><path d="M7 3v8M3 7h8" stroke="currentColor" stroke-width="1.6" stroke-linecap="round"/></svg>
                                        </button>
                                    {/if}
                                    <button type="button" class="mt-menu-btn mt-menu-btn-del" data-action="delete-item" title="Delete">
                                        <svg viewBox="0 0 14 14" fill="none"><path d="M2 4h10M5 4V2.5h4V4M5.5 7v4M8.5 7v4M3 4l.8 8h6.4l.8-8" stroke="currentColor" stroke-width="1.2" stroke-linecap="round"/></svg>
                                    </button>
                                    <label class="mt-toggle mt-toggle-sm" data-row-toggle title="Visible on frontend">
                                        <input type="checkbox" {if $itm->active}checked{/if} data-action="toggle-visible">
                                        <span class="mt-toggle-track"><span class="mt-toggle-thumb"></span></span>
                                    </label>
                                    <button type="button" class="mt-menu-btn" data-action="move-up" title="Move up">
                                        <svg viewBox="0 0 14 14" fill="none"><path d="M3 9l4-4 4 4" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round"/></svg>
                                    </button>
                                    <button type="button" class="mt-menu-btn" data-action="move-down" title="Move down">
                                        <svg viewBox="0 0 14 14" fill="none"><path d="M3 5l4 4 4-4" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round"/></svg>
                                    </button>
                                </div>
                            </div>
                            <div class="mt-menu-props-slot" hidden></div>
                            <ul class="mt-menu-children" data-children>
                                {foreach $node.children as $childNode}
                                    {assign var=childItm value=$childNode.item}
                                    <li class="mt-menu-item"
                                        data-id="{$childItm->id}"
                                        data-type="{$childItm->item_type|escape}"
                                        data-active="{if $childItm->active}1{else}0{/if}"
                                        data-label="{$childItm->label_json|escape}"
                                        data-config="{$childItm->config_json|escape}">
                                        <div class="mt-menu-item-row">
                                            <span class="mt-menu-grip" aria-hidden="true" title="Drag to reorder">
                                                <svg viewBox="0 0 12 16" fill="none"><circle cx="4" cy="3" r="1" fill="currentColor"/><circle cx="8" cy="3" r="1" fill="currentColor"/><circle cx="4" cy="8" r="1" fill="currentColor"/><circle cx="8" cy="8" r="1" fill="currentColor"/><circle cx="4" cy="13" r="1" fill="currentColor"/><circle cx="8" cy="13" r="1" fill="currentColor"/></svg>
                                            </span>
                                            <button type="button" class="mt-menu-chev" data-action="toggle-item" title="Expand">
                                                <svg viewBox="0 0 14 14" fill="none"><path d="M5 3l4 4-4 4" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round"/></svg>
                                            </button>
                                            <span class="mt-menu-type-tag mt-menu-type-tag-{$childItm->item_type|escape}" data-role="type-tag">{$mtTagFor[$childItm->item_type]|default:$childItm->item_type|escape}</span>
                                            <span class="mt-menu-name" data-role="label">{$childItm->resolvedLabel()|escape}</span>
                                            <div class="mt-menu-ctrls">
                                                <button type="button" class="mt-menu-btn mt-menu-btn-del" data-action="delete-item" title="Delete">
                                                    <svg viewBox="0 0 14 14" fill="none"><path d="M2 4h10M5 4V2.5h4V4M5.5 7v4M8.5 7v4M3 4l.8 8h6.4l.8-8" stroke="currentColor" stroke-width="1.2" stroke-linecap="round"/></svg>
                                                </button>
                                                <label class="mt-toggle mt-toggle-sm" data-row-toggle title="Visible on frontend">
                                                    <input type="checkbox" {if $childItm->active}checked{/if} data-action="toggle-visible">
                                                    <span class="mt-toggle-track"><span class="mt-toggle-thumb"></span></span>
                                                </label>
                                                <button type="button" class="mt-menu-btn" data-action="move-up" title="Move up">
                                                    <svg viewBox="0 0 14 14" fill="none"><path d="M3 9l4-4 4 4" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round"/></svg>
                                                </button>
                                                <button type="button" class="mt-menu-btn" data-action="move-down" title="Move down">
                                                    <svg viewBox="0 0 14 14" fill="none"><path d="M3 5l4 4 4-4" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round"/></svg>
                                                </button>
                                            </div>
                                        </div>
                                        <div class="mt-menu-props-slot" hidden></div>
                                        <ul class="mt-menu-children" data-children></ul>
                                    </li>
                                {/foreach}
                            </ul>
                        </li>
                    {/foreach}
                </ul>

                <div class="mt-menu-add-row">
                    <select class="mt-input mt-input-sm" id="mtAddType">
                        {foreach $itemTypes as $key => $meta}
                            <option value="{$key|escape}">{$meta.label|escape}</option>
                        {/foreach}
                    </select>
                    <button type="button" class="mt-btn mt-btn-ghost mt-btn-sm" id="mtAddBtn">+ Add item</button>
                </div>
            </div>
        </section>

        {* ────── RIGHT: menu-level settings (sticky sidebar) ────── *}
        <section class="mt-section mt-menu-settings-col">
            <header class="mt-section-header"><h2 class="mt-section-title">Menu Settings</h2></header>

            <div class="mt-menu-settings-card">
                <div class="mt-field">
                    <label class="mt-field-label" for="menu-audience">Display Rule</label>
                    <select id="menu-audience" class="mt-select" name="audience">
                        <option value="client" {if $menu->audience == 'client'}selected{/if}>Existing Client</option>
                        <option value="guest"  {if $menu->audience == 'guest'}selected{/if}>Guest Client</option>
                        <option value="all"    {if $menu->audience == 'all'}selected{/if}>All visitors</option>
                    </select>
                    <div class="mt-field-help">Decides for which audience this menu renders.</div>
                </div>

                <div class="mt-row">
                    <div>
                        <div class="mt-row-label">Status</div>
                        <div class="mt-row-help">Active menus render on the matching pages.</div>
                    </div>
                    <label class="mt-toggle"><input type="checkbox" name="active" value="1" {if $menu->active}checked{/if}><span class="mt-toggle-track"><span class="mt-toggle-thumb"></span></span></label>
                </div>
            </div>
        </section>

    </div>
</form>

{* ────── PARKED PROPERTY PANEL ──────
   This is the per-item editor. It lives here when no row is expanded; when
   the admin clicks a row's chevron, openInlinePanel(tempId) moves this
   whole DOM subtree into that row's .mt-menu-props-slot. Field IDs remain
   unique because there's only ever one panel — the existing icon-picker,
   page-picker and data-drawer-field handlers all keep working unchanged.

   The panel is OUTSIDE the form here, so its inputs (which carry NO name=)
   would never submit even if we forgot to relocate it. The form-submit
   regen path in the script below is what actually transcribes state.items
   into items[N][...] hidden inputs on save. *}
<div id="mtPanelHome" hidden>
    <div id="mtItemDrawer" class="mt-menu-props">

        <div class="mt-menu-sect">
            <div class="mt-menu-sect-label">Type</div>
            <div>
                <select id="drawerType" class="mt-select" data-drawer-field="item_type">
                    {foreach $itemTypes as $key => $meta}
                        <option value="{$key|escape}">{$meta.label|escape}</option>
                    {/foreach}
                </select>
                <div class="mt-menu-sect-help" style="margin-top:6px">
                    Changing the type hides fields that don't apply. Existing label / icon / URL values are kept in case you switch back.
                </div>
            </div>
        </div>

        <div class="mt-menu-sect" data-section="name">
            <div class="mt-menu-sect-label">Name</div>
            <input id="drawerLabelEn" class="mt-input" type="text" data-drawer-field="label.custom.english" placeholder="English label">
            <div class="mt-menu-sect-help">Shown to clients. The WHMCS lang key (in <em>Advanced label</em>) takes precedence if set.</div>
        </div>

        <div class="mt-menu-sect" data-drawer-show-when="whmcs_page">
            <div class="mt-menu-sect-label">WHMCS Page</div>
            <div class="mt-icon-picker-wrap">
                <button type="button" class="mt-icon-picker-trigger" id="drawerPagePickerBtn">
                    <span class="mt-page-picker-current" id="drawerPagePickerLabel">— Choose a page —</span>
                    <span class="mt-icon-picker-caret">▾</span>
                </button>
                <input type="hidden" id="drawerPage" data-drawer-field="config.page" value="">
                <div class="mt-icon-picker-panel mt-page-picker-panel" id="drawerPagePickerPanel" hidden>
                    <div class="mt-page-picker-search-wrap">
                        <input id="drawerPagePickerSearch" type="search" class="mt-input" placeholder="Search pages…" autocomplete="off">
                    </div>
                    <div class="mt-page-picker-list" id="drawerPagePickerList">
                        {foreach $pagesByGroup as $g => $rows}
                            <div class="mt-page-picker-group" data-page-group="{$g|escape}">
                                <div class="mt-page-picker-group-label">{$g|escape}</div>
                                {foreach $rows as $p}
                                    <button type="button" class="mt-page-picker-tile"
                                            data-page-name="{$p.name|escape}"
                                            data-page-label="{$p.display_name|escape}"
                                            data-page-group="{$g|escape}"
                                            data-page-lang-key="{$p.whmcs_lang_key|default:''|escape}"
                                            data-page-default-label="{$p.whmcs_default_label|default:''|escape}"
                                            data-page-haystack="{$p.name|lower|escape} {$p.display_name|lower|escape} {$g|lower|escape}">
                                        <span class="mt-page-picker-tile-name">
                                            {$p.display_name|escape}{if $p.whmcs_lang_key} <span class="mt-page-picker-default-pill" title="WHMCS default menu destination — picking auto-fills label">WHMCS default</span>{/if}
                                        </span>
                                        <span class="mt-page-picker-tile-meta">{$p.name|escape}</span>
                                    </button>
                                {/foreach}
                            </div>
                        {/foreach}
                    </div>
                    <div class="mt-page-picker-empty" hidden>No pages match.</div>
                </div>
            </div>
        </div>

        <div class="mt-menu-sect" data-drawer-show-when="custom_link">
            <div class="mt-menu-sect-label">URL</div>
            <input id="drawerUrl" class="mt-input" type="text" placeholder="https://…" data-drawer-field="config.url">
            <label class="mt-checkbox" style="margin-top:8px">
                <input type="checkbox" data-drawer-field="config.target" data-drawer-checkbox-value="_blank"> Open in new tab
            </label>
        </div>

        <div class="mt-menu-sect" data-drawer-show-when="dropdown_parent">
            <div class="mt-menu-sect-label">Dropdown style</div>
            <select id="drawerDropdown" class="mt-select" data-drawer-field="config.dropdown_style">
                <option value="default">Default (classic)</option>
                <option value="mega">Mega menu</option>
            </select>
            <div class="mt-menu-sect-help">
                <strong>Classic</strong> — narrow floating panel. Use <em>Header</em> children as section labels, <em>Divider</em> children as separators.<br>
                <strong>Mega menu</strong> — full-width panel; <em>Header</em> children become column titles, items between headers fill that column.
            </div>
        </div>

        <div class="mt-menu-sect" data-section="icon">
            <div class="mt-menu-sect-label">Icon</div>
            <div class="mt-icon-picker-wrap">
                <button type="button" class="mt-icon-picker-trigger" id="drawerIconBtn">
                    <span class="mt-icon-picker-preview" id="drawerIconPreview"></span>
                    <span class="mt-icon-picker-name" id="drawerIconName">(none)</span>
                    <span class="mt-icon-picker-caret">▾</span>
                </button>
                <input type="hidden" id="drawerIcon" data-drawer-field="config.icon" value="">
                <div class="mt-icon-picker-panel" id="drawerIconPanel" hidden>
                    <div class="mt-icon-picker-grid">
                        <button type="button" class="mt-icon-tile" data-icon-name="" title="No icon">
                            <span class="mt-icon-tile-clear">✕</span>
                        </button>
                        {foreach $icons as $ico}
                            <button type="button" class="mt-icon-tile" data-icon-name="{$ico.name|escape}" title="{$ico.name|escape}">
                                {$ico.svg nofilter}
                            </button>
                        {/foreach}
                    </div>
                </div>
            </div>
            <div class="mt-menu-sect-help">
                Top-nav icons render only when the global <a href="?module=MyTheme&amp;action=settings" target="_blank">Top-Nav Icons</a> setting is on. Sidebar and rail layouts always show icons.
            </div>
        </div>

        {* COLLAPSIBLE — Advanced label *}
        <div class="mt-menu-sub" data-sub="label" data-section="langKey">
            <button type="button" class="mt-menu-sub-h">
                <span>Advanced label</span>
                <span class="mt-menu-sub-chev"><svg viewBox="0 0 14 14" fill="none"><path d="M5 3l4 4-4 4" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round"/></svg></span>
            </button>
            <div class="mt-menu-sub-body" hidden>
                <div class="mt-field">
                    <label class="mt-field-label" for="drawerLabelWhmcs">WHMCS lang key</label>
                    <input id="drawerLabelWhmcs" class="mt-input" type="text" placeholder="e.g. navhome" data-drawer-field="label.whmcs">
                    <div class="mt-field-help">If set, this lang-key wins over the English label.</div>
                </div>
            </div>
        </div>

        {* COLLAPSIBLE — Display & Advanced settings *}
        <div class="mt-menu-sub" data-sub="display" data-section="display">
            <button type="button" class="mt-menu-sub-h">
                <span>Display &amp; advanced</span>
                <span class="mt-menu-sub-chev"><svg viewBox="0 0 14 14" fill="none"><path d="M5 3l4 4-4 4" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round"/></svg></span>
            </button>
            <div class="mt-menu-sub-body" hidden>
                <div class="mt-field">
                    <label class="mt-field-label" for="drawerPosition">Position</label>
                    <select id="drawerPosition" class="mt-select" data-drawer-field="config.position_side">
                        <option value="">Auto</option>
                        <option value="left">Left</option>
                        <option value="right">Right</option>
                    </select>
                </div>

                <div class="mt-field">
                    <label class="mt-field-label" for="drawerAudience">Visible to (per-item)</label>
                    <select id="drawerAudience" class="mt-select" data-drawer-field="config.audience">
                        <option value="all">All</option>
                        <option value="client">Clients only</option>
                        <option value="guest">Guests only</option>
                    </select>
                </div>

                <div class="mt-field">
                    <div class="mt-field-label">Layouts</div>
                    <label class="mt-checkbox"><input type="checkbox" data-drawer-field="config.theme_layouts" data-drawer-multi="top"> Top nav</label>
                    <label class="mt-checkbox"><input type="checkbox" data-drawer-field="config.theme_layouts" data-drawer-multi="side"> Sidebar</label>
                    <label class="mt-checkbox"><input type="checkbox" data-drawer-field="config.theme_layouts" data-drawer-multi="rail"> Icon rail</label>
                    <div class="mt-field-help">If none ticked, item shows on all layouts.</div>
                </div>

                <div class="mt-field">
                    <label class="mt-field-label" for="drawerCss">Custom CSS class</label>
                    <input id="drawerCss" class="mt-input" type="text" data-drawer-field="config.css_class">
                </div>

                {* The "Visible" checkbox mirrors the row-level toggle.
                   We keep it in the panel for keyboard/discoverability —
                   the row toggle handles the common case. *}
                <div class="mt-field">
                    <label class="mt-checkbox"><input type="checkbox" data-drawer-field="active"> Show in menu</label>
                </div>
            </div>
        </div>

    </div>
</div>

<style>
/* ============================================================================
   Menu editor — inline expand layout, grip-based reorder, sectioned panel.
   Lives in the .mt-wrap admin shell (footer.tpl provides .mt-*, .mt-toggle,
   .mt-input, etc.) — this file only adds the menu-editor-specific bits.
============================================================================ */

/* WHMCS-page picker — reuses .mt-icon-picker-wrap shell, adds list-specific bits. */
.mt-page-picker-panel { max-height: 360px; padding: 0; display: flex; flex-direction: column; overflow: hidden; }
.mt-page-picker-panel[hidden] { display: none !important; }
.mt-page-picker-search-wrap { padding: 8px; border-bottom: 1px solid var(--mt-border); flex-shrink: 0; }
.mt-page-picker-search-wrap .mt-input { padding: 6px 10px; font-size: 13px; }
.mt-page-picker-list { padding: 4px 6px 8px; overflow-y: auto; flex: 1; }
.mt-page-picker-group { margin-top: 8px; }
.mt-page-picker-group:first-child { margin-top: 2px; }
.mt-page-picker-group-label { font-size: 10px; font-weight: 600; color: var(--mt-text-3); text-transform: uppercase; letter-spacing: 0.04em; padding: 6px 10px 2px; }
.mt-page-picker-tile { display: flex; flex-direction: column; align-items: flex-start; width: 100%; gap: 1px; padding: 6px 10px; margin: 1px 0; border: 1px solid transparent; border-radius: 6px; background: transparent; font: inherit; color: var(--mt-text); cursor: pointer; text-align: left; }
.mt-page-picker-tile:hover { background: var(--mt-surface-2); }
.mt-page-picker-tile.is-active { background: var(--mt-primary-tint); border-color: rgba(0,113,227,0.18); }
.mt-page-picker-tile-name { font-size: 13px; font-weight: 500; line-height: 1.3; }
.mt-page-picker-tile-meta { font-size: 11px; color: var(--mt-text-3); font-family: ui-monospace, "SF Mono", Menlo, Consolas, monospace; }
.mt-page-picker-empty { padding: 14px; text-align: center; color: var(--mt-text-3); font-size: 12px; }
.mt-page-picker-current { flex: 1; text-align: left; font-size: 13px; color: var(--mt-text); white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
.mt-page-picker-current.is-placeholder { color: var(--mt-text-3); }
.mt-page-picker-default-pill { display: inline-block; margin-left: 6px; padding: 0 6px; border-radius: 999px; background: var(--mt-primary-tint); color: var(--mt-primary); font-size: 9px; font-weight: 600; text-transform: uppercase; letter-spacing: 0.04em; vertical-align: middle; }

/* ----- Two-column edit grid (tree left, sticky settings right) ----- */
.mt-menu-grid {
    display: grid;
    grid-template-columns: 1fr 320px;
    gap: 20px;
    align-items: start;
}
@media (max-width: 1000px) { .mt-menu-grid { grid-template-columns: 1fr; } }
.mt-menu-settings-col .mt-menu-settings-card {
    background: var(--mt-surface);
    border: 1px solid var(--mt-border);
    border-radius: var(--mt-radius);
    padding: 16px;
    position: sticky;
    top: 16px;
}

/* ----- Compact toggle (used on each item row) ----- */
.mt-toggle-sm { width: 32px; height: 18px; }
.mt-toggle-sm .mt-toggle-thumb { width: 14px; height: 14px; top: 2px; left: 2px; }
.mt-toggle-sm input:checked ~ .mt-toggle-track .mt-toggle-thumb { transform: translateX(14px); }

/* ----- Items list (flat hairline-divided rows, left accent bar on open) ----- */
.mt-menu-tree-col .mt-menu-tree { display: flex; flex-direction: column; gap: 0; }
.mt-menu-tree-col ul.mt-menu-list { display: flex; flex-direction: column; gap: 0; list-style: none; margin: 0; padding: 0; }

/* Override footer.tpl's global .mt-menu-add-row that draws a dashed
   top-border + padding-top — those produce a visible second horizontal
   line below the last item ("double line"). Inside the new flat tree
   we just want breathing space, no extra rule. */
.mt-menu-tree-col .mt-menu-add-row {
    border-top: 0;
    padding-top: 0;
    margin-top: 12px;
}
.mt-menu-tree-col ul.mt-menu-children { list-style: none; margin: 0 0 0 22px; padding: 8px 0 8px 12px; border-left: 1.5px solid var(--mt-border); display: flex; flex-direction: column; gap: 0; background: transparent; }
.mt-menu-tree-col ul.mt-menu-children:empty { display: none; }

.mt-menu-tree-col li.mt-menu-item {
    background: var(--mt-surface);
    border: 1px solid var(--mt-border);
    border-top: 0;
    border-radius: 0;
    position: relative;
    list-style: none;
}
/* Connected-row treatment — adjacent items share a single 1px border, no
   double-line at the seam. Top-level + children both follow the same
   pattern: first child draws the top border (+ rounded top corners), last
   child rounds the bottom corners. Plain children carry no special radii
   so they fit flush. */
.mt-menu-tree-col ul.mt-menu-list > li.mt-menu-item:first-child { border-top: 1px solid var(--mt-border); border-top-left-radius: 8px; border-top-right-radius: 8px; }
.mt-menu-tree-col ul.mt-menu-list > li.mt-menu-item:last-child  { border-bottom-left-radius: 8px; border-bottom-right-radius: 8px; }
.mt-menu-tree-col ul.mt-menu-children > li.mt-menu-item:first-child { border-top: 1px solid var(--mt-border); border-top-left-radius: 6px; border-top-right-radius: 6px; }
.mt-menu-tree-col ul.mt-menu-children > li.mt-menu-item:last-child  { border-bottom-left-radius: 6px; border-bottom-right-radius: 6px; }

.mt-menu-tree-col li.mt-menu-item.is-open {
    box-shadow: inset 3px 0 0 var(--mt-primary);
    z-index: 1;
}
.mt-menu-tree-col li.mt-menu-item.is-dragging { opacity: 0.4; }

/* Drag-over insertion line (drop indicator) */
.mt-menu-tree-col li.mt-menu-item.is-drop-before::before,
.mt-menu-tree-col li.mt-menu-item.is-drop-after::after {
    content: '';
    position: absolute;
    left: 0; right: 0;
    height: 2px;
    background: var(--mt-primary);
    z-index: 5;
    pointer-events: none;
}
.mt-menu-tree-col li.mt-menu-item.is-drop-before::before { top: -1px; }
.mt-menu-tree-col li.mt-menu-item.is-drop-after::after  { bottom: -1px; }

/* Hidden state — name dims, row tints slightly */
.mt-menu-tree-col li.mt-menu-item.is-row-hidden > .mt-menu-item-row > .mt-menu-name { color: var(--mt-text-4); }
.mt-menu-tree-col li.mt-menu-item.is-row-hidden > .mt-menu-item-row { background: var(--mt-surface-2); }

/* ----- The row itself ----- */
.mt-menu-tree-col .mt-menu-item-row {
    display: flex;
    align-items: center;
    gap: 4px;
    padding: 8px 12px 8px 6px;
    min-height: 42px;
    cursor: default;
    background: transparent;
}

.mt-menu-grip {
    display: inline-flex;
    width: 18px;
    height: 28px;
    align-items: center;
    justify-content: center;
    color: var(--mt-text-4);
    cursor: grab;
    flex-shrink: 0;
    opacity: 0.4;
    transition: opacity .15s, color .15s;
}
.mt-menu-item-row:hover .mt-menu-grip { opacity: 1; }
.mt-menu-grip:active { cursor: grabbing; }
.mt-menu-grip:hover { color: var(--mt-text-2); }
.mt-menu-grip svg { width: 12px; height: 16px; display: block; }

.mt-menu-chev {
    width: 22px;
    height: 22px;
    border: 0;
    background: transparent;
    color: var(--mt-text-3);
    border-radius: 4px;
    cursor: pointer;
    display: inline-flex;
    align-items: center;
    justify-content: center;
    flex-shrink: 0;
    transition: color .15s, background .15s;
}
.mt-menu-chev:hover { background: var(--mt-surface-2); color: var(--mt-text); }
.mt-menu-chev svg { width: 12px; height: 12px; transition: transform .2s ease; }
.mt-menu-item.is-open > .mt-menu-item-row > .mt-menu-chev { color: var(--mt-primary); }
.mt-menu-item.is-open > .mt-menu-item-row > .mt-menu-chev svg { transform: rotate(90deg); }

/* Type tag — small uppercase pill before the name so admins can tell
   pages / links / headers / dividers / special types apart at a glance. */
.mt-menu-type-tag {
    font-size: 10px;
    font-weight: 700;
    text-transform: uppercase;
    letter-spacing: 0.05em;
    padding: 2px 7px;
    border-radius: 4px;
    flex-shrink: 0;
    line-height: 1.5;
    margin-left: 2px;
    background: rgba(120,113,108,0.10);
    color: #57534e;
}
.mt-menu-type-tag-whmcs_page       { background: rgba(0,113,227,0.10);  color: #0040A0; }
.mt-menu-type-tag-custom_link      { background: rgba(255,159,10,0.14); color: #b35900; }
.mt-menu-type-tag-dropdown_parent  { background: rgba(48,209,88,0.14);  color: #1e7e34; }
.mt-menu-type-tag-header           { background: rgba(120,113,108,0.18); color: #44403c; }
.mt-menu-type-tag-divider          { background: rgba(120,113,108,0.10); color: #78716c; }
.mt-menu-type-tag-language         { background: rgba(99,102,241,0.10); color: #4338ca; }
.mt-menu-type-tag-currency         { background: rgba(168,85,247,0.10); color: #6b21a8; }
.mt-menu-type-tag-login_button     { background: rgba(236,72,153,0.10); color: #be185d; }
.mt-menu-type-tag-account_dropdown { background: rgba(20,184,166,0.12); color: #0f766e; }
.mt-menu-type-tag-whmcs_default    { background: rgba(100,116,139,0.12); color: #475569; }

.mt-menu-name {
    flex: 1;
    font-size: 13.5px;
    font-weight: 500;
    color: var(--mt-text);
    min-width: 0;
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
    padding-left: 4px;
    cursor: pointer;
}
.mt-menu-name:hover { color: var(--mt-primary); }

/* Per-type row variants — reinforce the type-tag visually so a row's
   purpose is readable even at a glance. */
.mt-menu-item[data-type="dropdown_parent"] > .mt-menu-item-row > .mt-menu-name { font-weight: 600; }
.mt-menu-item[data-type="header"] > .mt-menu-item-row > .mt-menu-name {
    text-transform: uppercase;
    letter-spacing: 0.05em;
    font-size: 11.5px;
    font-weight: 600;
    color: var(--mt-text-2);
}
.mt-menu-item[data-type="divider"] > .mt-menu-item-row > .mt-menu-name {
    color: var(--mt-text-4);
    font-style: italic;
    font-size: 12px;
}
/* Divider row renders a thin dashed rule across the name area for visual cue */
.mt-menu-item[data-type="divider"] > .mt-menu-item-row > .mt-menu-name::before {
    content: '';
    display: inline-block;
    width: 18px;
    border-top: 1px dashed var(--mt-text-4);
    vertical-align: middle;
    margin-right: 8px;
}
.mt-menu-item[data-type="divider"] > .mt-menu-item-row > .mt-menu-name::after {
    content: '';
    display: inline-block;
    width: 18px;
    border-top: 1px dashed var(--mt-text-4);
    vertical-align: middle;
    margin-left: 8px;
}

.mt-menu-ctrls { display: flex; align-items: center; gap: 1px; flex-shrink: 0; margin-left: auto; }
.mt-menu-btn {
    width: 26px;
    height: 26px;
    border: 0;
    background: transparent;
    color: var(--mt-text-4);
    border-radius: 4px;
    cursor: pointer;
    display: inline-flex;
    align-items: center;
    justify-content: center;
    padding: 0;
    transition: color .15s, background .15s;
}
.mt-menu-btn:hover { background: var(--mt-surface-2); color: var(--mt-text); }
.mt-menu-btn:disabled { opacity: 0.25; cursor: not-allowed; pointer-events: none; }
.mt-menu-btn svg { width: 13px; height: 13px; display: block; }
.mt-menu-btn-add:hover { background: var(--mt-primary-tint); color: var(--mt-primary); }
.mt-menu-btn-del:hover { background: var(--mt-danger-tint); color: var(--mt-danger); }
.mt-menu-ctrls .mt-toggle-sm { margin: 0 6px; }

/* ----- Inline property panel (relocated from #mtPanelHome on expand) ----- */
.mt-menu-props-slot { display: block; }
.mt-menu-props-slot[hidden] { display: none; }
.mt-menu-props {
    background: var(--mt-surface);
    border-top: 1px solid var(--mt-border-2);
    padding: 0;
}

.mt-menu-sect {
    display: grid;
    grid-template-columns: 140px 1fr;
    align-items: start;
    gap: 14px;
    padding: 14px 16px 14px 32px;
    border-top: 1px solid var(--mt-border-2);
}
.mt-menu-sect:first-child { border-top: 0; }
.mt-menu-sect-label {
    font-size: 11px;
    color: var(--mt-text-3);
    font-weight: 600;
    text-transform: uppercase;
    letter-spacing: 0.04em;
    padding-top: 9px;
    display: flex;
    align-items: center;
    gap: 5px;
}
.mt-menu-sect > :not(.mt-menu-sect-label) { grid-column: 2; min-width: 0; }
.mt-menu-sect-help { font-size: 12px; color: var(--mt-text-3); line-height: 1.5; }
.mt-menu-sect-help em { font-style: normal; color: var(--mt-text); }
.mt-menu-sect[data-drawer-show-when][style*="none"] { display: none; }

.mt-menu-sect .mt-input,
.mt-menu-sect .mt-select { width: 100%; }
.mt-menu-sect > .mt-checkbox { font-size: 13px; }

/* ----- Collapsible sub-sections (Advanced label / Display & advanced) ----- */
.mt-menu-sub { border-top: 1px solid var(--mt-border-2); background: var(--mt-surface); }
.mt-menu-sub-h {
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: 12px 16px 12px 32px;
    cursor: pointer;
    background: transparent;
    border: 0;
    width: 100%;
    text-align: left;
    font: inherit;
    font-size: 13px;
    font-weight: 500;
    color: var(--mt-text);
}
.mt-menu-sub-h:hover { background: var(--mt-surface-2); }
.mt-menu-sub-chev { color: var(--mt-text-4); display: inline-flex; align-items: center; }
.mt-menu-sub-chev svg { width: 12px; height: 12px; transition: transform .15s; }
.mt-menu-sub.is-open .mt-menu-sub-chev svg { transform: rotate(90deg); color: var(--mt-primary); }
.mt-menu-sub.is-open .mt-menu-sub-chev { color: var(--mt-primary); }
.mt-menu-sub-body { padding: 4px 16px 16px 32px; border-top: 1px solid var(--mt-border-2); padding-top: 14px; }
.mt-menu-sub-body[hidden] { display: none; }
.mt-menu-sub-body .mt-field { margin-bottom: 12px; }
.mt-menu-sub-body .mt-field:last-child { margin-bottom: 0; }

@media (max-width: 640px) {
    .mt-menu-grip { display: none; } /* hide on touch — use up/down buttons */
    .mt-menu-sect { grid-template-columns: 1fr; padding-left: 16px; gap: 6px; }
    .mt-menu-sub-h, .mt-menu-sub-body { padding-left: 16px; }
    .mt-menu-tree-col ul.mt-menu-children { margin-left: 12px; padding-left: 8px; }
}
</style>

{* Icon registry as JSON — placed BEFORE the IIFE so the iconMap() lazy
   lookup can read its textContent immediately. *}
<script id="mtIconRegistry" type="application/json">{$iconsJson nofilter}</script>

<script>{literal}
(function(){
    // ──────────────────────────────────────────────────────────────────────
    // State — the canonical in-memory tree. Serialized to items_json on save.
    // Each entry: { tempId, id|null, parent_id|null, position, item_type,
    //               label:{whmcs,custom}, config:{...}, active }
    // ──────────────────────────────────────────────────────────────────────
    // `pristine` starts true and stays true until the admin actually edits
    // something (add / delete / drag / panel field input / icon pick). On
    // submit, if pristine, we LEAVE the server-rendered <input> form-array
    // fields untouched and let the browser submit them natively. This avoids
    // the JS regen path entirely, which is the place where a JSON round-trip
    // bug could corrupt label / config on a no-op save.
    var state = { items: [], nextTemp: 1, pristine: true };
    var selectedTempId = null;

    // Human-readable labels for the item_type values. Mirrors
    // ItemTypes::all() in PHP — kept in sync manually. Used for the
    // "(Divider)" fallback label on label-less rows.
    var TYPE_LABELS = {
        whmcs_page:       'WHMCS Page',
        custom_link:      'Custom Link',
        dropdown_parent:  'Dropdown',
        header:           'Section Header',
        divider:          'Divider',
        language:         'Language Switcher',
        currency:         'Currency Switcher',
        login_button:     'Login Button',
        account_dropdown: 'Account Dropdown',
        whmcs_default:    'WHMCS Default'
    };

    // Short tag text rendered on each row's type pill. Mirrors the
    // $mtTagFor array in the Smarty header above.
    var TYPE_TAGS = {
        whmcs_page:       'Page',
        custom_link:      'Link',
        dropdown_parent:  'Dropdown',
        header:           'Header',
        divider:          'Divider',
        language:         'Language',
        currency:         'Currency',
        login_button:     'Login',
        account_dropdown: 'Account',
        whmcs_default:    'Default'
    };
    function typeTagText(type) { return TYPE_TAGS[type] || type; }

    function updateTypeTag(li, type) {
        var tag = li.querySelector(':scope > .mt-menu-item-row > [data-role="type-tag"]');
        if (!tag) return;
        // Strip any existing per-type modifier class; add the new one.
        tag.className = tag.className.replace(/\bmt-menu-type-tag-\S+/g, '').trim();
        tag.classList.add('mt-menu-type-tag', 'mt-menu-type-tag-' + type);
        tag.textContent = typeTagText(type);
    }

    // Field-visibility map per type. Each key here corresponds to a
    // [data-section="..."] element in the inline panel; `false` hides it
    // for that type. The per-type Page / URL / Dropdown sections still use
    // [data-drawer-show-when="<exact type>"] since they're single-type
    // exclusives. Unknown types default to "show everything" so a future
    // PHP type addition doesn't blank the panel.
    var TYPE_FIELDS = {
        whmcs_page:       { name: true,  icon: true,  langKey: true,  display: true  },
        custom_link:      { name: true,  icon: true,  langKey: true,  display: true  },
        dropdown_parent:  { name: true,  icon: true,  langKey: true,  display: true  },
        header:           { name: true,  icon: false, langKey: true,  display: true  },
        divider:          { name: false, icon: false, langKey: false, display: true  },
        language:         { name: false, icon: false, langKey: false, display: true  },
        currency:         { name: false, icon: false, langKey: false, display: true  },
        login_button:     { name: true,  icon: true,  langKey: true,  display: true  },
        account_dropdown: { name: true,  icon: true,  langKey: true,  display: true  },
        whmcs_default:    { name: false, icon: false, langKey: false, display: true  }
    };
    var TYPE_FIELDS_DEFAULT = { name: true, icon: true, langKey: true, display: true };

    function applyTypeVisibility(type) {
        var fields = TYPE_FIELDS[type] || TYPE_FIELDS_DEFAULT;
        panel.querySelectorAll('[data-section]').forEach(function (el) {
            var key = el.getAttribute('data-section');
            el.style.display = fields[key] === false ? 'none' : '';
        });
    }

    // Tree-row label shown next to the chevron. For types without a Name
    // field (divider, language, etc.) we fall back to a parenthesized type
    // name so the row isn't empty after a switch.
    function rowLabelFor(entry) {
        var fields = TYPE_FIELDS[entry.item_type] || TYPE_FIELDS_DEFAULT;
        if (fields.name === false) {
            return '(' + (TYPE_LABELS[entry.item_type] || entry.item_type) + ')';
        }
        var l = entry.label || {};
        return (l.custom && l.custom.english) || l.whmcs || '(no label)';
    }

    // Show or hide the per-row "+ Add child" button based on whether the
    // type accepts children. Only dropdown_parent does today.
    function refreshAddChildButton(li, type) {
        var row = li.querySelector(':scope > .mt-menu-item-row');
        if (!row) return;
        var ctrls = row.querySelector('.mt-menu-ctrls');
        var existing = row.querySelector('.mt-menu-btn-add');
        if (type === 'dropdown_parent') {
            if (!existing && ctrls) {
                var btn = document.createElement('button');
                btn.type = 'button';
                btn.className = 'mt-menu-btn mt-menu-btn-add';
                btn.setAttribute('data-action', 'add-child');
                btn.title = 'Add child item';
                btn.innerHTML = '<svg viewBox="0 0 14 14" fill="none"><path d="M7 3v8M3 7h8" stroke="currentColor" stroke-width="1.6" stroke-linecap="round"/></svg>';
                ctrls.insertBefore(btn, ctrls.firstChild);
            }
        } else if (existing) {
            existing.remove();
        }
    }

    // Side effect for item_type changes — confirm before orphaning children,
    // sync DOM state (data-type + Add Child button), refresh visibility maps.
    function onTypeChanged(entry, oldType) {
        if (oldType === 'dropdown_parent' && entry.item_type !== 'dropdown_parent') {
            var hasChildren = state.items.some(function (it) { return it.parent_id === entry.tempId; });
            if (hasChildren) {
                if (!confirm('This dropdown has child items. Changing type will hide them on the frontend (they stay in the menu data and re-appear if you switch back). Continue?')) {
                    entry.item_type = oldType;
                    var sel = document.getElementById('drawerType');
                    if (sel) sel.value = oldType;
                    return;
                }
            }
        }
        var li = document.querySelector('li[data-temp="' + entry.tempId + '"]');
        if (li) {
            li.setAttribute('data-type', entry.item_type);
            refreshAddChildButton(li, entry.item_type);
            updateTypeTag(li, entry.item_type);
        }
        applyTypeVisibility(entry.item_type);
        panel.querySelectorAll('[data-drawer-show-when]').forEach(function (el) {
            el.style.display = (el.getAttribute('data-drawer-show-when') === entry.item_type) ? '' : 'none';
        });
    }

    function uid(){ return 'new_' + (state.nextTemp++); }
    function markDirty(){ state.pristine = false; }

    // Cached DOM refs that don't move.
    var panelHome = document.getElementById('mtPanelHome');
    var panel     = document.getElementById('mtItemDrawer');

    // Build state from the DOM that Smarty rendered
    function ingestFromDom(){
        var root = document.querySelector('[data-tree-root] ul.mt-menu-list[data-children]');
        if (!root) return;
        function walk(ul, parentId){
            Array.from(ul.children).forEach(function(li, pos){
                if (li.tagName !== 'LI') return;
                var dbId = li.getAttribute('data-id');
                var type = li.getAttribute('data-type');
                var tempId = uid();
                li.setAttribute('data-temp', tempId);
                var labelRaw  = li.getAttribute('data-label')  || '{"whmcs":"","custom":{}}';
                var configRaw = li.getAttribute('data-config') || '{}';
                var active    = li.getAttribute('data-active') !== '0';
                var label, config;
                try { label  = JSON.parse(labelRaw);  } catch(e){ label  = {whmcs:'', custom:{}}; }
                try { config = JSON.parse(configRaw); } catch(e){ config = {}; }
                if (Array.isArray(label) || typeof label !== 'object' || label === null) {
                    label = {whmcs:'', custom:{}};
                }
                if (Array.isArray(label.custom)) label.custom = {};
                if (Array.isArray(config) || typeof config !== 'object' || config === null) {
                    config = {};
                }
                state.items.push({
                    tempId: tempId,
                    id: dbId ? Number(dbId) : null,
                    parent_id: parentId,
                    position: pos,
                    item_type: type,
                    label: label,
                    config: config,
                    active: active,
                });
                // Reflect row-hidden visual state based on initial active.
                if (!active) li.classList.add('is-row-hidden');
                var childUl = li.querySelector(':scope > ul[data-children]');
                if (childUl) walk(childUl, tempId);
            });
        }
        walk(root, null);
        updateCount();
        refreshUpDownDisabled();
    }

    function updateCount(){
        document.getElementById('mtItemCount').textContent = state.items.length + ' item' + (state.items.length === 1 ? '' : 's');
    }

    function refreshUpDownDisabled(){
        // Disable Up on the first item, Down on the last item, at every depth.
        var root = document.querySelector('[data-tree-root]');
        if (!root) return;
        root.querySelectorAll('ul[data-children]').forEach(function(ul){
            var kids = Array.prototype.filter.call(ul.children, function(c){
                return c.tagName === 'LI' && c.classList.contains('mt-menu-item');
            });
            kids.forEach(function(k, i){
                var up   = k.querySelector(':scope > .mt-menu-item-row [data-action="move-up"]');
                var down = k.querySelector(':scope > .mt-menu-item-row [data-action="move-down"]');
                if (up)   up.disabled   = (i === 0);
                if (down) down.disabled = (i === kids.length - 1);
            });
        });
    }

    // Null-safe getElementById event binder. A missing id throws and would
    // abort the entire IIFE, including the form-submit handler far below.
    function on(id, evt, fn) {
        var el = document.getElementById(id);
        if (el) el.addEventListener(evt, fn);
        else console.warn('[MyTheme menu] #' + id + ' not found — skipping ' + evt);
    }

    // ──────────────────────────────────────────────────────────────────────
    // Drag-drop (vanilla HTML5 — no jQuery UI, no Sortable.js)
    // The grip has cursor:grab as the affordance; the whole <li> is draggable
    // and dragstart is cancelled if the user grabbed from a control.
    // ──────────────────────────────────────────────────────────────────────
    var draggingEl = null;
    function makeDraggable(){
        document.querySelectorAll('li.mt-menu-item').forEach(function(li){
            li.setAttribute('draggable', 'true');
        });
    }
    document.addEventListener('dragstart', function(e){
        // Cancel if the user grabbed from a control. The grip itself is a
        // <span> so it doesn't match — only the grip area starts a drag.
        if (e.target.closest('button, input, select, textarea, label, a')) {
            e.preventDefault();
            return;
        }
        var li = e.target.closest('li.mt-menu-item');
        if (!li) return;
        draggingEl = li;
        li.classList.add('is-dragging');
        try {
            e.dataTransfer.effectAllowed = 'move';
            e.dataTransfer.setData('text/plain', li.getAttribute('data-temp') || '');
        } catch (err) {}
    });
    document.addEventListener('dragover', function(e){
        var ul = e.target.closest('ul[data-children]');
        if (!ul || !draggingEl) return;
        e.preventDefault();
        e.dataTransfer.dropEffect = 'move';
        // Place dragging element above the nearest sibling by Y midpoint.
        var after = null;
        Array.from(ul.children).forEach(function(child){
            if (child === draggingEl || child.tagName !== 'LI') return;
            var rect = child.getBoundingClientRect();
            if (e.clientY < rect.top + rect.height / 2) {
                if (after === null) after = child;
            }
        });
        if (draggingEl !== after){
            if (after) ul.insertBefore(draggingEl, after);
            else ul.appendChild(draggingEl);
        }
    });
    document.addEventListener('dragend', function(){
        if (draggingEl){ draggingEl.classList.remove('is-dragging'); draggingEl = null; }
        syncStateFromDom();
        refreshUpDownDisabled();
        markDirty();
    });

    function syncStateFromDom(){
        function walk(ul, parentTempId){
            Array.from(ul.children).forEach(function(li, pos){
                if (li.tagName !== 'LI') return;
                var tempId = li.getAttribute('data-temp');
                var entry = state.items.find(function(it){ return it.tempId === tempId; });
                if (entry){
                    entry.parent_id = parentTempId;
                    entry.position = pos;
                }
                var childUl = li.querySelector(':scope > ul[data-children]');
                if (childUl) walk(childUl, tempId);
            });
        }
        var root = document.querySelector('[data-tree-root] ul.mt-menu-list[data-children]');
        if (root) walk(root, null);
    }

    // ──────────────────────────────────────────────────────────────────────
    // Inline panel relocation. There's exactly ONE panel DOM subtree (#mtItemDrawer)
    // and it lives in #mtPanelHome until a row is expanded — then it moves
    // into that row's .mt-menu-props-slot. This keeps field IDs unique so the
    // existing icon-picker, page-picker and data-drawer-field handlers below
    // need zero changes.
    // ──────────────────────────────────────────────────────────────────────
    function closeInlinePanel(){
        if (!panel || panel.parentNode === panelHome) return;
        // Find the host slot and item.
        var slot = panel.parentNode;
        var item = slot ? slot.closest('li.mt-menu-item') : null;
        panelHome.appendChild(panel);
        if (slot) slot.hidden = true;
        if (item) item.classList.remove('is-open');
        selectedTempId = null;
    }

    function openInlinePanel(tempId){
        var li = document.querySelector('li.mt-menu-item[data-temp="' + tempId + '"]');
        if (!li) return;
        // If already open, toggle closed.
        if (li.classList.contains('is-open')) { closeInlinePanel(); return; }
        // Close any other open item.
        closeInlinePanel();

        var slot = li.querySelector(':scope > .mt-menu-props-slot');
        if (!slot) return;
        slot.appendChild(panel);
        slot.hidden = false;
        li.classList.add('is-open');
        selectedTempId = tempId;
        populatePanelFromEntry(tempId);
    }

    function populatePanelFromEntry(tempId){
        var entry = state.items.find(function(it){ return it.tempId === tempId; });
        if (!entry) return;
        // Per-type field visibility (drives data-section show/hide).
        applyTypeVisibility(entry.item_type);
        // Toggle per-type-exclusive sections (Page / URL / Dropdown).
        panel.querySelectorAll('[data-drawer-show-when]').forEach(function(el){
            el.style.display = (el.getAttribute('data-drawer-show-when') === entry.item_type) ? '' : 'none';
        });
        // Populate fields by path.
        panel.querySelectorAll('[data-drawer-field]').forEach(function(el){
            var path = el.getAttribute('data-drawer-field');
            var multi = el.getAttribute('data-drawer-multi');
            var checkboxVal = el.getAttribute('data-drawer-checkbox-value');
            var v = readPath(entry, path);
            if (multi){
                el.checked = Array.isArray(v) && v.indexOf(multi) >= 0;
            } else if (checkboxVal){
                el.checked = v === checkboxVal;
            } else if (el.type === 'checkbox'){
                el.checked = !!v;
            } else {
                el.value = v == null ? '' : v;
            }
        });
        syncIconPickerFromEntry(entry);
        syncPagePickerFromEntry(entry);
    }

    // ──────────────────────────────────────────────────────────────────────
    // Click delegation — single listener handles all row actions.
    // ──────────────────────────────────────────────────────────────────────
    document.addEventListener('click', function(e){
        // Sub-section collapse/expand (Advanced label, Display & advanced)
        var subBtn = e.target.closest('.mt-menu-sub-h');
        if (subBtn) {
            e.preventDefault();
            var sub = subBtn.closest('.mt-menu-sub');
            var body = sub.querySelector(':scope > .mt-menu-sub-body');
            if (body){
                body.hidden = !body.hidden;
                sub.classList.toggle('is-open', !body.hidden);
            }
            return;
        }

        var actEl = e.target.closest('[data-action]');
        if (!actEl) {
            // Click on row name also toggles
            var nameEl = e.target.closest('.mt-menu-name');
            if (nameEl) {
                var li = nameEl.closest('li.mt-menu-item');
                if (li) openInlinePanel(li.getAttribute('data-temp'));
            }
            return;
        }
        var action = actEl.getAttribute('data-action');

        // Visibility toggle — change event, not click. Skip here (handled in change listener).
        if (action === 'toggle-visible') return;

        var li = actEl.closest('li.mt-menu-item');

        if (action === 'toggle-item') {
            if (li) openInlinePanel(li.getAttribute('data-temp'));
            return;
        }

        if (action === 'delete-item') {
            if (!li) return;
            if (!confirm('Delete this item and any children?')) return;
            var tempId = li.getAttribute('data-temp');
            // If the deleted item is currently expanded, park the panel first.
            if (selectedTempId === tempId) closeInlinePanel();
            // Collect this row + descendants by tempId.
            var toRemove = new Set([tempId]);
            var changed = true;
            while (changed){
                changed = false;
                state.items.forEach(function(it){
                    if (it.parent_id && toRemove.has(it.parent_id) && !toRemove.has(it.tempId)){
                        toRemove.add(it.tempId); changed = true;
                    }
                });
            }
            state.items = state.items.filter(function(it){ return !toRemove.has(it.tempId); });
            li.remove();
            updateCount();
            refreshUpDownDisabled();
            markDirty();
            return;
        }

        if (action === 'move-up' || action === 'move-down') {
            if (!li) return;
            var parent = li.parentNode;
            if (action === 'move-up') {
                var prev = li.previousElementSibling;
                while (prev && prev.tagName !== 'LI') prev = prev.previousElementSibling;
                if (prev) parent.insertBefore(li, prev);
            } else {
                var next = li.nextElementSibling;
                while (next && next.tagName !== 'LI') next = next.nextElementSibling;
                if (next) parent.insertBefore(next, li);
            }
            syncStateFromDom();
            refreshUpDownDisabled();
            markDirty();
            return;
        }

        if (action === 'add-child') {
            if (!li) return;
            var parentTempId = li.getAttribute('data-temp');
            var childUl = li.querySelector(':scope > ul.mt-menu-children');
            if (!childUl) return;
            var typeEl = document.getElementById('mtAddType');
            var type = typeEl ? typeEl.value : 'custom_link';
            var entry = createNewItemEntry(type, parentTempId);
            state.items.push(entry);
            childUl.appendChild(buildItemLi(entry));
            syncStateFromDom();
            updateCount();
            refreshUpDownDisabled();
            markDirty();
            return;
        }
    });

    // Visibility toggle (change event on row checkbox)
    document.addEventListener('change', function(e){
        var t = e.target.closest('[data-action="toggle-visible"]');
        if (!t) return;
        var li = t.closest('li.mt-menu-item');
        if (!li) return;
        var tempId = li.getAttribute('data-temp');
        var entry = state.items.find(function(it){ return it.tempId === tempId; });
        if (!entry) return;
        entry.active = t.checked;
        li.classList.toggle('is-row-hidden', !t.checked);
        // Keep the "Show in menu" checkbox in the inline panel in sync if open.
        if (selectedTempId === tempId) {
            var panelCb = panel.querySelector('[data-drawer-field="active"]');
            if (panelCb) panelCb.checked = t.checked;
        }
        markDirty();
    });

    // ──────────────────────────────────────────────────────────────────────
    // Add top-level item from the picker at the bottom of the tree
    // ──────────────────────────────────────────────────────────────────────
    on('mtAddBtn', 'click', function(){
        var typeEl = document.getElementById('mtAddType');
        var type = typeEl ? typeEl.value : 'custom_link';
        var entry = createNewItemEntry(type, null);
        state.items.push(entry);
        var root = document.querySelector('[data-tree-root] ul.mt-menu-list[data-children]');
        if (root) root.appendChild(buildItemLi(entry));
        var emptyState = document.querySelector('[data-empty-state]');
        if (emptyState) emptyState.remove();
        syncStateFromDom();
        updateCount();
        refreshUpDownDisabled();
        markDirty();
    });

    function createNewItemEntry(type, parentTempId){
        return {
            tempId: uid(),
            id: null,
            parent_id: parentTempId,
            position: 9999,
            item_type: type,
            label: { whmcs: '', custom: { english: 'New ' + type } },
            config: {},
            active: true,
        };
    }

    function buildItemLi(entry){
        var li = document.createElement('li');
        li.className = 'mt-menu-item';
        li.setAttribute('data-temp', entry.tempId);
        li.setAttribute('data-type', entry.item_type);
        li.setAttribute('draggable', 'true');
        // Use the same SVG grip / chev / buttons as the server-rendered rows.
        // accepts-children: only show + add-child for dropdown_parent type.
        var acceptsKids = (entry.item_type === 'dropdown_parent');
        li.innerHTML = '' +
            '<div class="mt-menu-item-row">' +
                '<span class="mt-menu-grip" aria-hidden="true" title="Drag to reorder">' +
                    '<svg viewBox="0 0 12 16" fill="none"><circle cx="4" cy="3" r="1" fill="currentColor"/><circle cx="8" cy="3" r="1" fill="currentColor"/><circle cx="4" cy="8" r="1" fill="currentColor"/><circle cx="8" cy="8" r="1" fill="currentColor"/><circle cx="4" cy="13" r="1" fill="currentColor"/><circle cx="8" cy="13" r="1" fill="currentColor"/></svg>' +
                '</span>' +
                '<button type="button" class="mt-menu-chev" data-action="toggle-item" title="Expand">' +
                    '<svg viewBox="0 0 14 14" fill="none"><path d="M5 3l4 4-4 4" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round"/></svg>' +
                '</button>' +
                '<span class="mt-menu-type-tag mt-menu-type-tag-' + entry.item_type + '" data-role="type-tag">' + escapeHtml(typeTagText(entry.item_type)) + '</span>' +
                '<span class="mt-menu-name" data-role="label">' + escapeHtml(rowLabelFor(entry)) + '</span>' +
                '<div class="mt-menu-ctrls">' +
                    (acceptsKids ?
                    '<button type="button" class="mt-menu-btn mt-menu-btn-add" data-action="add-child" title="Add child"><svg viewBox="0 0 14 14" fill="none"><path d="M7 3v8M3 7h8" stroke="currentColor" stroke-width="1.6" stroke-linecap="round"/></svg></button>' : '') +
                    '<button type="button" class="mt-menu-btn mt-menu-btn-del" data-action="delete-item" title="Delete"><svg viewBox="0 0 14 14" fill="none"><path d="M2 4h10M5 4V2.5h4V4M5.5 7v4M8.5 7v4M3 4l.8 8h6.4l.8-8" stroke="currentColor" stroke-width="1.2" stroke-linecap="round"/></svg></button>' +
                    '<label class="mt-toggle mt-toggle-sm" title="Visible on frontend"><input type="checkbox" checked data-action="toggle-visible"><span class="mt-toggle-track"><span class="mt-toggle-thumb"></span></span></label>' +
                    '<button type="button" class="mt-menu-btn" data-action="move-up" title="Move up"><svg viewBox="0 0 14 14" fill="none"><path d="M3 9l4-4 4 4" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round"/></svg></button>' +
                    '<button type="button" class="mt-menu-btn" data-action="move-down" title="Move down"><svg viewBox="0 0 14 14" fill="none"><path d="M3 5l4 4 4-4" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round"/></svg></button>' +
                '</div>' +
            '</div>' +
            '<div class="mt-menu-props-slot" hidden></div>' +
            '<ul class="mt-menu-children" data-children></ul>';
        return li;
    }

    function escapeHtml(s){ return String(s).replace(/[<>&"']/g, function(c){ return {'<':'&lt;','>':'&gt;','&':'&amp;','"':'&quot;',"'":'&#39;'}[c]; }); }

    // ──────────────────────────────────────────────────────────────────────
    // Icon picker (grid) — UNCHANGED from previous edit.tpl, just uses
    // the relocated panel's IDs which are still unique.
    // ──────────────────────────────────────────────────────────────────────
    var _iconMap = null;
    function iconMap(){
        if (_iconMap) return _iconMap;
        var el = document.getElementById('mtIconRegistry');
        try { _iconMap = JSON.parse((el && el.textContent) || '{}'); } catch(e){ _iconMap = {}; }
        return _iconMap;
    }
    function iconSvgFor(name){
        if (!name) return '';
        var map = iconMap();
        if (map[name]) {
            return '<svg viewBox="0 0 24 24" width="18" height="18" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round">' + map[name] + '</svg>';
        }
        return '<i class="' + name.replace(/"/g, '&quot;') + '"></i>';
    }
    function syncIconPickerFromEntry(entry){
        var name = (entry && entry.config && entry.config.icon) || '';
        var iconInput   = document.getElementById('drawerIcon');
        var iconPreview = document.getElementById('drawerIconPreview');
        var iconName    = document.getElementById('drawerIconName');
        if (iconInput)   iconInput.value = name;
        if (iconPreview) iconPreview.innerHTML = iconSvgFor(name) || '<span class="mt-icon-tile-clear">∅</span>';
        if (iconName)    iconName.textContent = name || '(none)';
        document.querySelectorAll('#drawerIconPanel .mt-icon-tile').forEach(function(t){
            t.classList.toggle('is-active', t.getAttribute('data-icon-name') === name);
        });
    }
    on('drawerIconBtn', 'click', function(e){
        e.preventDefault();
        var pagePanel = document.getElementById('drawerPagePickerPanel');
        if (pagePanel) pagePanel.hidden = true;
        var panel = document.getElementById('drawerIconPanel');
        if (panel) panel.hidden = !panel.hidden;
    });
    document.addEventListener('click', function(e){
        var tile = e.target.closest('#drawerIconPanel .mt-icon-tile');
        if (!tile) return;
        var name = tile.getAttribute('data-icon-name') || '';
        if (selectedTempId === null) return;
        var entry = state.items.find(function(it){ return it.tempId === selectedTempId; });
        if (!entry) return;
        if (!entry.config) entry.config = {};
        if (name) entry.config.icon = name; else delete entry.config.icon;
        syncIconPickerFromEntry(entry);
        markDirty();
        document.getElementById('drawerIconPanel').hidden = true;
    });
    // Close icon/page panels when clicking outside.
    document.addEventListener('click', function(e){
        if (e.target.closest('.mt-icon-picker-wrap')) return;
        var ip = document.getElementById('drawerIconPanel');
        if (ip) ip.hidden = true;
        var pp = document.getElementById('drawerPagePickerPanel');
        if (pp) pp.hidden = true;
    });

    // ──────────────────────────────────────────────────────────────────────
    // WHMCS-page picker (grouped, searchable) — UNCHANGED.
    // ──────────────────────────────────────────────────────────────────────
    function syncPagePickerFromEntry(entry){
        var labelEl = document.getElementById('drawerPagePickerLabel');
        var hidden  = document.getElementById('drawerPage');
        if (!labelEl || !hidden) return;
        var current = (entry && entry.config && entry.config.page) || '';
        hidden.value = current;
        if (!current) {
            labelEl.textContent = '— Choose a page —';
            labelEl.classList.add('is-placeholder');
        } else {
            var tile = document.querySelector('#drawerPagePickerList .mt-page-picker-tile[data-page-name="' + current.replace(/"/g, '\\"') + '"]');
            if (tile) {
                labelEl.textContent = tile.getAttribute('data-page-label') + ' · ' + tile.getAttribute('data-page-group');
                labelEl.classList.remove('is-placeholder');
            } else {
                labelEl.textContent = current + ' (unknown templatefile)';
                labelEl.classList.remove('is-placeholder');
            }
        }
        document.querySelectorAll('#drawerPagePickerList .mt-page-picker-tile').forEach(function(t){
            t.classList.toggle('is-active', t.getAttribute('data-page-name') === current);
        });
    }
    on('drawerPagePickerBtn', 'click', function(e){
        e.preventDefault();
        var iconPanel = document.getElementById('drawerIconPanel');
        if (iconPanel) iconPanel.hidden = true;
        var panel = document.getElementById('drawerPagePickerPanel');
        if (!panel) return;
        panel.hidden = !panel.hidden;
        if (!panel.hidden) {
            var s = document.getElementById('drawerPagePickerSearch');
            if (s) { s.value = ''; filterPagePicker(''); setTimeout(function(){ s.focus(); }, 0); }
        }
    });
    function filterPagePicker(query){
        var q = (query || '').toLowerCase().trim();
        var tiles = document.querySelectorAll('#drawerPagePickerList .mt-page-picker-tile');
        var groups = document.querySelectorAll('#drawerPagePickerList .mt-page-picker-group');
        var visibleCount = 0;
        Array.prototype.forEach.call(tiles, function(tile){
            var hay = tile.getAttribute('data-page-haystack') || '';
            var match = !q || hay.indexOf(q) >= 0;
            tile.style.display = match ? '' : 'none';
            if (match) visibleCount++;
        });
        Array.prototype.forEach.call(groups, function(g){
            var any = g.querySelector('.mt-page-picker-tile:not([style*="display: none"])');
            g.style.display = any ? '' : 'none';
        });
        var empty = document.querySelector('#drawerPagePickerPanel .mt-page-picker-empty');
        if (empty) empty.hidden = visibleCount > 0;
    }
    document.addEventListener('input', function(e){
        if (e.target && e.target.id === 'drawerPagePickerSearch') {
            filterPagePicker(e.target.value);
        }
    });
    document.addEventListener('click', function(e){
        var tile = e.target.closest('#drawerPagePickerList .mt-page-picker-tile');
        if (!tile) return;
        if (selectedTempId === null) return;
        var entry = state.items.find(function(it){ return it.tempId === selectedTempId; });
        if (!entry) return;
        if (!entry.config) entry.config = {};
        var pageName     = tile.getAttribute('data-page-name')          || '';
        var langKey      = tile.getAttribute('data-page-lang-key')      || '';
        var defaultLabel = tile.getAttribute('data-page-default-label') || '';
        entry.config.page = pageName;

        if (!entry.label || typeof entry.label !== 'object') entry.label = {whmcs:'', custom:{}};
        if (!entry.label.custom || typeof entry.label.custom !== 'object') entry.label.custom = {};
        if (langKey) {
            entry.label.whmcs = langKey;
            var currentEn = entry.label.custom.english || '';
            if (!currentEn || /^New\s/i.test(currentEn)) {
                entry.label.custom.english = defaultLabel;
            }
        }
        var langInput = document.getElementById('drawerLabelWhmcs');
        if (langInput) langInput.value = entry.label.whmcs || '';
        var enInput = document.getElementById('drawerLabelEn');
        if (enInput) enInput.value = entry.label.custom.english || '';

        var li = document.querySelector('li[data-temp="' + selectedTempId + '"]');
        if (li) {
            var labelEl = li.querySelector('[data-role=label]');
            if (labelEl) {
                labelEl.textContent = entry.label.custom.english || entry.label.whmcs || '(no label)';
            }
        }
        syncPagePickerFromEntry(entry);
        markDirty();
        var panel = document.getElementById('drawerPagePickerPanel');
        if (panel) panel.hidden = true;
    });

    // ──────────────────────────────────────────────────────────────────────
    // Generic field listener — reads/writes state via data-drawer-field path.
    // ──────────────────────────────────────────────────────────────────────
    document.addEventListener('input', function(e){
        var el = e.target.closest('[data-drawer-field]');
        if (!el || selectedTempId === null) return;
        var entry = state.items.find(function(it){ return it.tempId === selectedTempId; });
        if (!entry) return;
        var path = el.getAttribute('data-drawer-field');
        var multi = el.getAttribute('data-drawer-multi');
        var checkboxVal = el.getAttribute('data-drawer-checkbox-value');
        // Capture old value when changing item_type so onTypeChanged can
        // detect dropdown_parent → other-type transitions and warn.
        var oldType = (path === 'item_type') ? readPath(entry, path) : null;
        if (multi){
            var arr = readPath(entry, path) || [];
            if (!Array.isArray(arr)) arr = [];
            if (el.checked && arr.indexOf(multi) < 0) arr.push(multi);
            if (!el.checked) arr = arr.filter(function(x){ return x !== multi; });
            writePath(entry, path, arr);
        } else if (checkboxVal){
            writePath(entry, path, el.checked ? checkboxVal : '');
        } else if (el.type === 'checkbox'){
            writePath(entry, path, el.checked);
            // If toggling the "active" field in the panel, mirror to the row toggle.
            if (path === 'active') {
                var li2 = document.querySelector('li[data-temp="' + selectedTempId + '"]');
                if (li2){
                    var rowCb = li2.querySelector(':scope > .mt-menu-item-row [data-action="toggle-visible"]');
                    if (rowCb) rowCb.checked = el.checked;
                    li2.classList.toggle('is-row-hidden', !el.checked);
                }
            }
        } else {
            writePath(entry, path, el.value);
        }
        // item_type side-effects: re-apply visibility + may revert on user cancel.
        if (path === 'item_type') {
            onTypeChanged(entry, oldType);
        }
        markDirty();
        // Reflect label changes in the tree row (type-aware fallback).
        var li = document.querySelector('li[data-temp="' + selectedTempId + '"]');
        if (li){
            var labelEl = li.querySelector('[data-role=label]');
            if (labelEl){
                labelEl.textContent = rowLabelFor(entry);
            }
        }
    });
    // 'change' for checkboxes/selects too (input event doesn't fire on every browser for them).
    document.addEventListener('change', function(e){
        var el = e.target.closest('[data-drawer-field]');
        if (!el) return;
        if (el.tagName !== 'SELECT' && el.type !== 'checkbox') return;
        // Reuse the input handler logic.
        var evt = new Event('input', { bubbles: true });
        el.dispatchEvent(evt);
    });

    function readPath(obj, path){
        var p = path.split('.');
        var cur = obj;
        for (var i = 0; i < p.length; i++){
            if (cur == null) return null;
            cur = cur[p[i]];
        }
        return cur;
    }
    function writePath(obj, path, value){
        var p = path.split('.');
        var cur = obj;
        for (var i = 0; i < p.length - 1; i++){
            // Replace null OR ARRAY parents — setting a string-keyed
            // property on a JS array gets silently dropped by
            // JSON.stringify (arrays serialize only their indexed items).
            // This was the root cause of "save empties all label/config
            // fields": after a previous round-trip, label.custom or config
            // would come back as an empty array `[]` instead of `{}`.
            if (cur[p[i]] == null || typeof cur[p[i]] !== 'object' || Array.isArray(cur[p[i]])) {
                cur[p[i]] = {};
            }
            cur = cur[p[i]];
        }
        cur[p[p.length - 1]] = value;
    }

    function deepObjectify(v){
        if (v === null || v === undefined) return {};
        if (Array.isArray(v)) {
            if (v.length === 0) return {};
            return v.map(deepObjectify);
        }
        if (typeof v !== 'object') return v;
        var out = {};
        Object.keys(v).forEach(function(k){ out[k] = deepObjectify(v[k]); });
        return out;
    }

    // ──────────────────────────────────────────────────────────────────────
    // Serialize on submit — wrapped in try/catch so a JSON.stringify error
    // can't leave items_json empty and trigger the server-side "skip items"
    // safety net (which would silently drop the admin's changes).
    // ──────────────────────────────────────────────────────────────────────
    on('menuForm', 'submit', function(e){
        // PRISTINE FAST PATH — if the admin made zero edits, leave the
        // server-rendered form-array inputs untouched.
        if (state.pristine) {
            console.log('[MyTheme menu] submit (pristine) — skipping JS regen, server inputs submit as-is');
            return;
        }

        try { syncStateFromDom(); } catch (err) { console.error('[MyTheme menu] syncStateFromDom failed', err); }

        var payload;
        try {
            payload = state.items.map(function(it){
                return {
                    id: it.id,
                    parent_id: (function(){
                        if (it.parent_id == null) return null;
                        var p = state.items.find(function(x){ return x.tempId === it.parent_id; });
                        return p ? (p.id || it.parent_id) : null;
                    })(),
                    position: it.position,
                    item_type: it.item_type,
                    label: it.label,
                    config: it.config,
                    active: it.active,
                };
            });
        } catch (err) {
            console.error('[MyTheme menu] payload build failed — submit blocked', err);
            e.preventDefault();
            alert('Could not build the save payload — open the browser console for details.');
            return;
        }
        if (payload.length === 0) {
            var existing = document.querySelectorAll('li.mt-menu-item').length;
            if (existing > 0) {
                e.preventDefault();
                alert('Refusing to save: the browser didn’t pick up any items from the tree. Reload the page and try again.');
                console.error('[MyTheme menu] empty payload while DOM still has', existing, 'items — submit blocked');
                return;
            }
        }
        var fields = document.getElementById('mtItemsFields');
        if (fields) {
            fields.innerHTML = '';
            payload.forEach(function(it, i){
                function addField(name, value) {
                    var inp = document.createElement('input');
                    inp.type = 'hidden';
                    inp.name = 'items[' + i + '][' + name + ']';
                    inp.value = value == null ? '' : String(value);
                    fields.appendChild(inp);
                }
                var labelOut = deepObjectify(it.label || {whmcs:'', custom:{}});
                if (it.id == null) {
                    if (!labelOut || typeof labelOut !== 'object') labelOut = {whmcs:'', custom:{}};
                    if (!labelOut.custom || typeof labelOut.custom !== 'object') labelOut.custom = {};
                    var hasAnyLabel = (labelOut.whmcs && labelOut.whmcs !== '');
                    if (!hasAnyLabel) {
                        Object.keys(labelOut.custom).forEach(function(k){
                            if (labelOut.custom[k] && labelOut.custom[k] !== '') hasAnyLabel = true;
                        });
                    }
                    if (!hasAnyLabel) {
                        labelOut.custom.english = 'New ' + (it.item_type || 'item');
                    }
                }
                addField('id',           it.id == null ? '' : it.id);
                addField('item_type',    it.item_type || '');
                addField('parent_id',    it.parent_id == null ? '' : it.parent_id);
                addField('position',     it.position == null ? i : it.position);
                addField('label_json',   JSON.stringify(labelOut));
                addField('config_json',  JSON.stringify(deepObjectify(it.config || {})));
                addField('active',       it.active ? '1' : '0');
            });
        }
        var itemsJson = JSON.stringify(payload);
        var itemsInput = document.getElementById('menuItemsJson');
        if (!itemsInput) {
            itemsInput = document.createElement('input');
            itemsInput.type = 'hidden';
            itemsInput.name = 'items_json';
            itemsInput.id = 'menuItemsJson';
            this.appendChild(itemsInput);
        }
        itemsInput.value = itemsJson;
        console.group('[MyTheme menu] submit (dirty)');
        console.log('Total items in state:', state.items.length);
        console.log('Payload size (chars):', itemsJson.length);
        console.table(payload.map(function(p, i){
            return {
                idx: i,
                id: p.id == null ? 'NEW' : p.id,
                type: p.item_type,
                label: (p.label && p.label.custom && p.label.custom.english) || (p.label && p.label.whmcs) || '(no label)',
                parent: p.parent_id == null ? 'top' : p.parent_id,
                pos: p.position,
                active: p.active,
            };
        }));
        console.groupEnd();
    });

    makeDraggable();
    ingestFromDom();
})();
{/literal}</script>

{include file="includes/footer.tpl"}
