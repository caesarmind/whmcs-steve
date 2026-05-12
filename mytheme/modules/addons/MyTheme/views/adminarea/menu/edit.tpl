{include file="includes/header.tpl"}

<form id="menuForm" method="post" action="?module=MyTheme&action=menu&sub=save">
    <input type="hidden" name="id" value="{$menu->id|escape}">
    <input type="hidden" name="items_json" id="menuItemsJson" value="">
    <input type="hidden" name="deleted_ids_json" id="menuDeletedIdsJson" value="[]">

    <div class="mt-toolbar">
        <a class="mt-back" href="?module=MyTheme&action=menu&tab={$menu->location|escape}">
            <svg viewBox="0 0 16 16" fill="none"><path d="M10 13L5 8l5-5" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round"/></svg>
            Back to menus
        </a>
        <div style="flex:1"></div>
        {if $flash == 'saved'}<span class="mt-flash mt-flash-success">Saved</span>{/if}
        {if $flash == 'settings-only'}
            <span class="mt-flash mt-flash-warn">
                Saved the menu settings only — the browser sent no items so the existing items were left intact.
                If something seems off, hit reload and try again.
            </span>
        {/if}
        {if $flash == 'empty-payload-rejected'}
            <span class="mt-flash mt-flash-warn">
                Save refused — the browser sent zero items so we didn't wipe your menu.
                <a href="?module=MyTheme&action=menu&sub=seed" style="text-decoration:underline">Re-seed presets</a>
                if you want the defaults back.
            </span>
        {/if}
        <button type="submit" class="mt-btn mt-btn-primary mt-btn-sm">Save changes</button>
    </div>

    <header class="mt-page-header">
        <h1 class="mt-page-title">
            <input type="text" name="name" class="mt-page-title-input" value="{$menu->name|escape}">
            <span class="mt-page-meta">/ Menu editor</span>
        </h1>
        <p class="mt-page-subtitle">Drag the handle to reorder. Click a row to edit it in the drawer on the right.</p>
    </header>

    <div class="mt-menu-split">
        {* ── Tree ── *}
        <section class="mt-section">
            <header class="mt-section-header">
                <h2 class="mt-section-title">Menu Items</h2>
                <span class="mt-section-count" id="mtItemCount">0 items</span>
            </header>

            <div class="mt-menu-tree" id="mtMenuTree" data-tree-root>
                {* Two explicit levels of nesting — avoids fragile Smarty {function} recursion
                   which can silently render nothing on some WHMCS Smarty configurations and
                   then trip the persistItems mass-delete safety net on Save. 2 levels covers
                   every realistic menu shape; deeper trees would need a switch to
                   {include}-based recursion. *}
                <ul class="mt-menu-list" data-children>
                    {foreach $tree as $node}
                        {assign var=itm value=$node.item}
                        <li class="mt-menu-item" data-id="{$itm->id}" data-type="{$itm->item_type|escape}" data-active="{if $itm->active}1{else}0{/if}" data-label="{$itm->label_json|escape}" data-config="{$itm->config_json|escape}">
                            <div class="mt-menu-item-row">
                                <span class="mt-menu-handle" title="Drag to reorder">
                                    <svg viewBox="0 0 16 16" fill="none"><circle cx="6" cy="4" r="1" fill="currentColor"/><circle cx="10" cy="4" r="1" fill="currentColor"/><circle cx="6" cy="8" r="1" fill="currentColor"/><circle cx="10" cy="8" r="1" fill="currentColor"/><circle cx="6" cy="12" r="1" fill="currentColor"/><circle cx="10" cy="12" r="1" fill="currentColor"/></svg>
                                </span>
                                <span class="mt-menu-type-badge mt-type-{$itm->item_type|escape}">{$itemTypes[$itm->item_type]['label']|default:$itm->item_type|escape}</span>
                                <span class="mt-menu-name" data-role="label">{$itm->resolvedLabel()|escape}</span>
                                {if !$itm->active}<span class="mt-badge mt-badge-neutral">hidden</span>{/if}
                                <span class="mt-menu-actions">
                                    <button type="button" class="mt-icon-btn" data-action="edit-item" title="Edit"><svg viewBox="0 0 16 16" fill="none"><path d="M11.5 1.5l3 3L5 14l-4 1 1-4 9.5-9.5z" stroke="currentColor" stroke-width="1.2" stroke-linejoin="round"/></svg></button>
                                    <button type="button" class="mt-icon-btn" data-action="delete-item" title="Delete"><svg viewBox="0 0 16 16" fill="none"><path d="M2 4h12M5 4V2.5h6V4M6 7v5M10 7v5M3.5 4l1 10h7l1-10" stroke="currentColor" stroke-width="1.2" stroke-linecap="round"/></svg></button>
                                </span>
                            </div>
                            <ul class="mt-menu-children" data-children>
                                {foreach $node.children as $childNode}
                                    {assign var=childItm value=$childNode.item}
                                    <li class="mt-menu-item" data-id="{$childItm->id}" data-type="{$childItm->item_type|escape}" data-active="{if $childItm->active}1{else}0{/if}" data-label="{$childItm->label_json|escape}" data-config="{$childItm->config_json|escape}">
                                        <div class="mt-menu-item-row">
                                            <span class="mt-menu-handle">
                                                <svg viewBox="0 0 16 16" fill="none"><circle cx="6" cy="4" r="1" fill="currentColor"/><circle cx="10" cy="4" r="1" fill="currentColor"/><circle cx="6" cy="8" r="1" fill="currentColor"/><circle cx="10" cy="8" r="1" fill="currentColor"/><circle cx="6" cy="12" r="1" fill="currentColor"/><circle cx="10" cy="12" r="1" fill="currentColor"/></svg>
                                            </span>
                                            <span class="mt-menu-type-badge mt-type-{$childItm->item_type|escape}">{$itemTypes[$childItm->item_type]['label']|default:$childItm->item_type|escape}</span>
                                            <span class="mt-menu-name" data-role="label">{$childItm->resolvedLabel()|escape}</span>
                                            {if !$childItm->active}<span class="mt-badge mt-badge-neutral">hidden</span>{/if}
                                            <span class="mt-menu-actions">
                                                <button type="button" class="mt-icon-btn" data-action="edit-item">Edit</button>
                                                <button type="button" class="mt-icon-btn" data-action="delete-item">×</button>
                                            </span>
                                        </div>
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

        {* ── Settings + drawer ── *}
        <section class="mt-section">
            <header class="mt-section-header"><h2 class="mt-section-title">Menu Settings</h2></header>

            <div class="mt-field">
                <label class="mt-field-label" for="menu-audience">Audience</label>
                <select id="menu-audience" class="mt-select" name="audience">
                    <option value="client" {if $menu->audience == 'client'}selected{/if}>Client (logged-in)</option>
                    <option value="guest"  {if $menu->audience == 'guest'}selected{/if}>Guest (logged-out)</option>
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

            <hr class="mt-divider">

            <div id="mtItemDrawer" class="mt-item-drawer" hidden>
                <div class="mt-drawer-head">
                    <span class="mt-drawer-eyebrow" data-drawer-type></span>
                    <h3 class="mt-drawer-title">Edit item</h3>
                </div>

                <div class="mt-field">
                    <label class="mt-field-label" for="drawerLabelEn">Label (English)</label>
                    <input id="drawerLabelEn" class="mt-input" type="text" data-drawer-field="label.custom.english">
                </div>
                <div class="mt-field">
                    <label class="mt-field-label" for="drawerLabelWhmcs">…or use WHMCS lang key</label>
                    <input id="drawerLabelWhmcs" class="mt-input" type="text" placeholder="e.g. navhome" data-drawer-field="label.whmcs">
                    <div class="mt-field-help">If set, this lang-key wins over the English label.</div>
                </div>

                <div class="mt-field" data-drawer-show-when="whmcs_page">
                    <label class="mt-field-label" for="drawerPage">WHMCS Page</label>
                    <input id="drawerPage" class="mt-input" type="text" placeholder="e.g. clientareahome" data-drawer-field="config.page">
                </div>
                <div class="mt-field" data-drawer-show-when="custom_link">
                    <label class="mt-field-label" for="drawerUrl">URL</label>
                    <input id="drawerUrl" class="mt-input" type="text" placeholder="https://…" data-drawer-field="config.url">
                </div>
                <div class="mt-field" data-drawer-show-when="custom_link">
                    <label class="mt-field-label">
                        <input type="checkbox" data-drawer-field="config.target" data-drawer-checkbox-value="_blank"> Open in new tab
                    </label>
                </div>
                <div class="mt-field" data-drawer-show-when="dropdown_parent">
                    <label class="mt-field-label" for="drawerDropdown">Dropdown style</label>
                    <select id="drawerDropdown" class="mt-select" data-drawer-field="config.dropdown_style">
                        <option value="default">Default</option>
                        <option value="mega">Mega menu</option>
                    </select>
                </div>

                <div class="mt-field">
                    <label class="mt-field-label" for="drawerIcon">Icon</label>
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
                </div>

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
                    <label class="mt-checkbox"><input type="checkbox" data-drawer-field="active"> Visible</label>
                </div>

                <div class="mt-field">
                    <label class="mt-field-label" for="drawerCss">Custom CSS class</label>
                    <input id="drawerCss" class="mt-input" type="text" data-drawer-field="config.css_class">
                </div>
            </div>
            <div id="mtItemDrawerEmpty" class="mt-drawer-empty">Click a row in the tree to edit it.</div>
        </section>
    </div>
</form>

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
    // deletedIds tracks DB ids the admin removed via the × button. They're
    // submitted in deleted_ids_json. The controller ONLY deletes ids in this
    // list — no implicit sweep based on payload absence.
    var state = { items: [], deletedIds: [], nextTemp: 1 };
    var selectedTempId = null;

    function uid(){ return 'new_' + (state.nextTemp++); }

    // Build state from the DOM that Smarty rendered
    function ingestFromDom(){
        var root = document.querySelector('[data-tree-root] ul.mt-menu-list[data-children]');
        if (!root) return;
        var seenIds = new Set();
        function walk(ul, parentId){
            Array.from(ul.children).forEach(function(li, pos){
                if (li.tagName !== 'LI') return;
                var dbId = li.getAttribute('data-id');
                var type = li.getAttribute('data-type');
                var tempId = uid();
                li.setAttribute('data-temp', tempId);
                seenIds.add(tempId);
                var labelRaw  = li.getAttribute('data-label')  || '{"whmcs":"","custom":{}}';
                var configRaw = li.getAttribute('data-config') || '{}';
                var active    = li.getAttribute('data-active') !== '0';
                var label, config;
                try { label  = JSON.parse(labelRaw);  } catch(e){ label  = {whmcs:'', custom:{english: li.querySelector('[data-role=label]').textContent.trim()}}; }
                try { config = JSON.parse(configRaw); } catch(e){ config = {}; }
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
                var childUl = li.querySelector(':scope > ul[data-children]');
                if (childUl) walk(childUl, tempId);
            });
        }
        walk(root, null);
        updateCount();
    }

    function updateCount(){
        document.getElementById('mtItemCount').textContent = state.items.length + ' item' + (state.items.length === 1 ? '' : 's');
    }

    // ──────────────────────────────────────────────────────────────────────
    // Drag-drop (vanilla HTML5 — no jQuery UI, no Sortable.js)
    // ──────────────────────────────────────────────────────────────────────
    var draggingEl = null;
    document.addEventListener('dragstart', function(e){
        var li = e.target.closest('li.mt-menu-item');
        if (!li) return;
        draggingEl = li;
        li.classList.add('is-dragging');
        e.dataTransfer.effectAllowed = 'move';
        e.dataTransfer.setData('text/plain', li.getAttribute('data-temp') || '');
    });
    document.addEventListener('dragend', function(e){
        if (draggingEl){ draggingEl.classList.remove('is-dragging'); draggingEl = null; }
        document.querySelectorAll('.is-drag-over').forEach(function(el){ el.classList.remove('is-drag-over'); });
        syncStateFromDom();
    });
    document.addEventListener('dragover', function(e){
        var ul = e.target.closest('ul[data-children]');
        if (!ul) return;
        e.preventDefault();
        e.dataTransfer.dropEffect = 'move';
        ul.classList.add('is-drag-over');
        // Place dragging element above the nearest sibling by Y midpoint
        var after = null;
        Array.from(ul.children).forEach(function(child){
            if (child === draggingEl) return;
            var rect = child.getBoundingClientRect();
            if (e.clientY < rect.top + rect.height / 2) {
                if (after === null) after = child;
            }
        });
        if (draggingEl && draggingEl !== after){
            if (after) ul.insertBefore(draggingEl, after);
            else ul.appendChild(draggingEl);
        }
    });
    document.addEventListener('dragleave', function(e){
        var ul = e.target.closest('ul[data-children]');
        if (ul) ul.classList.remove('is-drag-over');
    });

    // Make all rows draggable
    function refreshDraggable(){
        document.querySelectorAll('li.mt-menu-item').forEach(function(li){
            li.setAttribute('draggable', 'true');
        });
    }

    function syncStateFromDom(){
        // Walk the DOM tree and update position + parent_id by current DOM order
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
    // Add / Delete
    // ──────────────────────────────────────────────────────────────────────
    document.getElementById('mtAddBtn').addEventListener('click', function(){
        var type = document.getElementById('mtAddType').value;
        var tempId = uid();
        var entry = {
            tempId: tempId, id: null, parent_id: null,
            position: 9999, item_type: type,
            label: {whmcs:'', custom:{english:'New ' + type}}, config: {}, active: true,
        };
        state.items.push(entry);
        appendRowToRoot(entry);
        syncStateFromDom();
        updateCount();
    });

    function appendRowToRoot(entry){
        var root = document.querySelector('[data-tree-root] ul.mt-menu-list[data-children]');
        if (!root) return;
        var li = document.createElement('li');
        li.className = 'mt-menu-item';
        li.setAttribute('data-temp', entry.tempId);
        li.setAttribute('data-type', entry.item_type);
        li.setAttribute('draggable', 'true');
        li.innerHTML = '' +
            '<div class="mt-menu-item-row">' +
                '<span class="mt-menu-handle"><svg viewBox="0 0 16 16" fill="none"><circle cx="6" cy="4" r="1" fill="currentColor"/><circle cx="10" cy="4" r="1" fill="currentColor"/><circle cx="6" cy="8" r="1" fill="currentColor"/><circle cx="10" cy="8" r="1" fill="currentColor"/><circle cx="6" cy="12" r="1" fill="currentColor"/><circle cx="10" cy="12" r="1" fill="currentColor"/></svg></span>' +
                '<span class="mt-menu-type-badge mt-type-' + entry.item_type + '">' + entry.item_type + '</span>' +
                '<span class="mt-menu-name" data-role="label">' + (entry.label.custom.english || entry.item_type) + '</span>' +
                '<span class="mt-menu-actions">' +
                    '<button type="button" class="mt-icon-btn" data-action="edit-item">Edit</button>' +
                    '<button type="button" class="mt-icon-btn" data-action="delete-item">×</button>' +
                '</span>' +
            '</div>' +
            '<ul class="mt-menu-children" data-children></ul>';
        root.appendChild(li);
    }

    document.addEventListener('click', function(e){
        var del = e.target.closest('[data-action=delete-item]');
        if (del) {
            var li = del.closest('li.mt-menu-item');
            if (!li) return;
            if (!confirm('Delete this item and any children?')) return;
            var tempId = li.getAttribute('data-temp');
            // Collect this row + descendants by tempId
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
            // Record DB ids of removed rows (skip new items — they were never persisted)
            state.items.forEach(function(it){
                if (toRemove.has(it.tempId) && it.id != null) {
                    if (state.deletedIds.indexOf(it.id) < 0) state.deletedIds.push(it.id);
                }
            });
            state.items = state.items.filter(function(it){ return !toRemove.has(it.tempId); });
            li.remove();
            updateCount();
            return;
        }
        var edit = e.target.closest('[data-action=edit-item], .mt-menu-name');
        if (edit){
            var li = edit.closest('li.mt-menu-item');
            if (li) openDrawer(li.getAttribute('data-temp'));
        }
    });

    // ──────────────────────────────────────────────────────────────────────
    // Drawer (read/write fields back into state)
    // ──────────────────────────────────────────────────────────────────────
    function openDrawer(tempId){
        var entry = state.items.find(function(it){ return it.tempId === tempId; });
        if (!entry) return;
        selectedTempId = tempId;
        var drawer = document.getElementById('mtItemDrawer');
        document.getElementById('mtItemDrawerEmpty').hidden = true;
        drawer.hidden = false;
        drawer.querySelector('[data-drawer-type]').textContent = entry.item_type;
        // Toggle per-type fields
        drawer.querySelectorAll('[data-drawer-show-when]').forEach(function(el){
            el.style.display = (el.getAttribute('data-drawer-show-when') === entry.item_type) ? '' : 'none';
        });
        // Populate fields
        drawer.querySelectorAll('[data-drawer-field]').forEach(function(el){
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
        // Reflect icon picker preview when drawer opens
        syncIconPickerFromEntry(entry);
    }

    // ──────────────────────────────────────────────────────────────────────
    // Icon picker (grid)
    // ──────────────────────────────────────────────────────────────────────
    // Lazy-read the registry so it works regardless of script ordering
    // (the JSON tag may live below this script).
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
        document.getElementById('drawerIcon').value = name;
        document.getElementById('drawerIconPreview').innerHTML = iconSvgFor(name) || '<span class="mt-icon-tile-clear">∅</span>';
        document.getElementById('drawerIconName').textContent = name || '(none)';
        // Highlight active tile in the panel
        document.querySelectorAll('#drawerIconPanel .mt-icon-tile').forEach(function(t){
            t.classList.toggle('is-active', t.getAttribute('data-icon-name') === name);
        });
    }
    document.getElementById('drawerIconBtn').addEventListener('click', function(e){
        e.preventDefault();
        var panel = document.getElementById('drawerIconPanel');
        panel.hidden = !panel.hidden;
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
        document.getElementById('drawerIconPanel').hidden = true;
    });
    // Close panel when clicking outside
    document.addEventListener('click', function(e){
        if (e.target.closest('.mt-icon-picker-wrap')) return;
        var panel = document.getElementById('drawerIconPanel');
        if (panel) panel.hidden = true;
    });

    document.addEventListener('input', function(e){
        var el = e.target.closest('[data-drawer-field]');
        if (!el || selectedTempId === null) return;
        var entry = state.items.find(function(it){ return it.tempId === selectedTempId; });
        if (!entry) return;
        var path = el.getAttribute('data-drawer-field');
        var multi = el.getAttribute('data-drawer-multi');
        var checkboxVal = el.getAttribute('data-drawer-checkbox-value');
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
        } else {
            writePath(entry, path, el.value);
        }
        // Reflect label changes in the tree row
        var li = document.querySelector('li[data-temp="' + selectedTempId + '"]');
        if (li){
            var labelEl = li.querySelector('[data-role=label]');
            if (labelEl){
                var l = entry.label || {};
                labelEl.textContent = (l.custom && l.custom.english) || l.whmcs || '(no label)';
            }
        }
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
            if (cur[p[i]] == null || typeof cur[p[i]] !== 'object') cur[p[i]] = {};
            cur = cur[p[i]];
        }
        cur[p[p.length - 1]] = value;
    }

    // ──────────────────────────────────────────────────────────────────────
    // Serialize on submit. Wrapped in try/catch so a JSON.stringify error
    // can't leave items_json empty and trigger the server-side "skip items"
    // safety net (which would silently drop the admin's changes).
    // ──────────────────────────────────────────────────────────────────────
    document.getElementById('menuForm').addEventListener('submit', function(e){
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
        // SAFETY: if state.items is empty AND there's still tree DOM, the
        // ingest never happened. Bail and ask the admin to reload — better
        // UX than a round-trip + flash-message redirect.
        if (payload.length === 0 && state.deletedIds.length === 0) {
            var existing = document.querySelectorAll('li.mt-menu-item').length;
            if (existing > 0) {
                e.preventDefault();
                alert('Refusing to save: the browser didn’t pick up any items from the tree. Reload the page and try again.');
                console.error('[MyTheme menu] empty payload while DOM still has', existing, 'items — submit blocked');
                return;
            }
        }
        var itemsJson = JSON.stringify(payload);
        var deletedJson = JSON.stringify(state.deletedIds);
        document.getElementById('menuItemsJson').value = itemsJson;
        document.getElementById('menuDeletedIdsJson').value = deletedJson;
        // Verbose dump for diagnosing "new items not saved" / "items deleted"
        // bugs. Each item shows id (null for new), type, label, parent_id, position.
        console.group('[MyTheme menu] submit');
        console.log('Total items in state:', state.items.length);
        console.log('Payload size (chars):', itemsJson.length);
        console.log('Deletions:', state.deletedIds);
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

    refreshDraggable();
    ingestFromDom();
})();
{/literal}</script>

{include file="includes/footer.tpl"}
