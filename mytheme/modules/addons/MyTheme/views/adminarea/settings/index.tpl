{include file="includes/header.tpl"}

<header class="mt-page-header">
    <div class="mt-page-eyebrow">Theme</div>
    <h1 class="mt-page-title">Settings</h1>
    <p class="mt-page-subtitle">Theme-wide options. Save to apply.</p>
</header>

<div class="mt-tabs" role="tablist">
    <a class="mt-tab {if $tab == 'general'}is-active{/if}" href="?module=MyTheme&action=settings&tab=general">General</a>
    <a class="mt-tab {if $tab == 'order'}is-active{/if}" href="?module=MyTheme&action=settings&tab=order">Order Process</a>
</div>

<style>
    .mt-row-with-sub { border-bottom: 0; }
    .mt-row-sub { padding: 4px 0 18px; border-bottom: 1px solid var(--mt-border); }
    .mt-row-sub[hidden] { display: none; }
    .mt-row-sub-head { display: flex; align-items: baseline; justify-content: space-between; gap: 16px; margin-bottom: 4px; }
    .mt-row-sub-title { font-size: 14px; font-weight: 500; margin: 0; }
    .mt-row-sub-help { font-size: 12px; color: var(--mt-text-3); margin: 0 0 14px; }
    .mt-row-sub-count { font-size: 13px; color: var(--mt-text-3); }

    /* Chip multi-select — single field with removable chips + dropdown picker.
       Replaces the previous grid of checkbox-chips. The real form fields
       live in a hidden .mt-multi-inputs container; the visible widget is
       just a view onto their state. */
    .mt-multi-wrap { position: relative; max-width: 520px; }
    .mt-multi {
        width: 100%;
        min-height: 40px;
        padding: 5px 32px 5px 8px;
        border: 1px solid var(--mt-input-border);
        border-radius: 8px;
        background: #fff;
        display: flex;
        flex-wrap: wrap;
        align-items: center;
        gap: 4px;
        cursor: pointer;
        position: relative;
        transition: border-color .15s, box-shadow .15s;
    }
    .mt-multi:hover { border-color: var(--mt-text-3); }
    .mt-multi.is-focused { border-color: var(--mt-primary, #0071e3); box-shadow: 0 0 0 3px rgba(0,113,227,0.15); }
    .mt-multi-caret {
        position: absolute;
        right: 12px;
        top: 50%;
        transform: translateY(-50%);
        color: var(--mt-text-4);
        pointer-events: none;
    }
    .mt-multi-caret svg { width: 12px; height: 12px; display: block; }
    .mt-multi-placeholder { color: var(--mt-text-3); font-size: 13px; padding: 6px 4px; }
    .mt-multi-placeholder[hidden] { display: none; }
    .mt-multi-chip {
        display: inline-flex;
        align-items: center;
        gap: 4px;
        height: 26px;
        padding: 0 4px 0 9px;
        background: var(--mt-surface-2, #f5f5f7);
        border: 1px solid var(--mt-border);
        border-radius: 6px;
        font-size: 12.5px;
        color: var(--mt-text);
    }
    .mt-multi-chip-x {
        color: var(--mt-primary, #0071e3);
        cursor: pointer;
        padding: 0 4px;
        line-height: 1;
        font-size: 14px;
        font-weight: 500;
        border-radius: 3px;
        user-select: none;
    }
    .mt-multi-chip-x:hover { background: rgba(0,113,227,0.10); }

    .mt-multi-panel {
        position: absolute;
        left: 0; right: 0; top: calc(100% + 4px);
        background: #fff;
        border: 1px solid var(--mt-border);
        border-radius: 8px;
        box-shadow: 0 8px 24px rgba(0,0,0,0.08);
        z-index: 30;
        max-height: 300px;
        display: flex;
        flex-direction: column;
        overflow: hidden;
    }
    .mt-multi-panel[hidden] { display: none; }
    .mt-multi-search-wrap { padding: 8px; border-bottom: 1px solid var(--mt-border); }
    .mt-multi-search-wrap input { width: 100%; padding: 6px 10px; font-size: 13px; border: 1px solid var(--mt-input-border); border-radius: 6px; background: #fff; font: inherit; }
    .mt-multi-search-wrap input:focus { outline: none; border-color: var(--mt-primary, #0071e3); box-shadow: 0 0 0 2px rgba(0,113,227,0.15); }
    .mt-multi-options { padding: 4px; overflow-y: auto; flex: 1; }
    .mt-multi-option {
        display: flex;
        align-items: center;
        gap: 9px;
        width: 100%;
        padding: 7px 10px;
        border: 0;
        background: transparent;
        border-radius: 4px;
        font: inherit;
        font-size: 13px;
        color: var(--mt-text);
        cursor: pointer;
        text-align: left;
    }
    .mt-multi-option:hover { background: var(--mt-surface-2, #f5f5f7); }
    .mt-multi-option .mt-multi-check {
        width: 14px;
        height: 14px;
        border: 1.5px solid var(--mt-input-border);
        border-radius: 3px;
        display: inline-flex;
        align-items: center;
        justify-content: center;
        flex-shrink: 0;
        background: #fff;
    }
    .mt-multi-option.is-checked .mt-multi-check { background: var(--mt-primary, #0071e3); border-color: var(--mt-primary, #0071e3); }
    .mt-multi-option .mt-multi-check svg { width: 10px; height: 10px; opacity: 0; }
    .mt-multi-option.is-checked .mt-multi-check svg { opacity: 1; }
    .mt-multi-empty { padding: 14px; text-align: center; color: var(--mt-text-3); font-size: 12px; }
    .mt-multi-actions { padding: 6px 12px; border-top: 1px solid var(--mt-border); display: flex; gap: 14px; }
    .mt-link-btn { background: none; border: 0; padding: 0; color: var(--mt-primary, #0071e3); font: inherit; cursor: pointer; font-size: 12px; }
    .mt-link-btn:hover { text-decoration: underline; }
</style>

<form method="post" action="" novalidate>
    <section class="mt-section">
        <header class="mt-section-header">
            <h2 class="mt-section-title">General Settings</h2>
            <div class="mt-section-tools">
                <button type="submit" class="mt-btn mt-btn-primary mt-btn-sm">Save changes</button>
            </div>
        </header>

        {foreach $flags as $key => $meta}
            {assign var=mtIsLangToggle value=($key == 'custom_language_list')}
            <div class="mt-row{if $mtIsLangToggle} mt-row-with-sub{/if}">
                <div>
                    <div class="mt-row-label">{$meta[0]|escape}</div>
                    <div class="mt-row-help">{$meta[1]|escape}</div>
                </div>
                <label class="mt-toggle">
                    <input type="checkbox" name="{$key|escape}" {if $mtIsLangToggle}data-toggle-target="mt-language-picker" {/if}{if $values[$key]}checked{/if}>
                    <span class="mt-toggle-track"><span class="mt-toggle-thumb"></span></span>
                </label>
            </div>

            {* Lagom-style sub-field: the language picker lives directly below
               the toggle row it belongs to, with no border separating them.
               Always renders so the form can submit; hidden by default when
               the toggle is off — JS reveals it on toggle change. *}
            {if $mtIsLangToggle}
                <div class="mt-row-sub" id="mt-language-picker"{if !$values[$key]} hidden{/if}>
                    <header class="mt-row-sub-head">
                        <h3 class="mt-row-sub-title">Languages shown to clients</h3>
                        <span class="mt-row-sub-count" id="mt-lang-count"></span>
                    </header>
                    <p class="mt-row-sub-help">
                        Pick which languages appear in the locale chooser. Only languages installed in <code>/lang/</code> are shown.
                        {if !$installedLanguages}<strong>No language files found.</strong>{/if}
                    </p>

                    {if $installedLanguages}
                        <div class="mt-multi-wrap" id="mt-lang-wrap">
                            {* Hidden form fields — the source of truth for submission. The
                               visible widget below just mirrors their checked state. *}
                            <div class="mt-multi-inputs" hidden id="mt-lang-inputs">
                                {foreach $installedLanguages as $code}
                                    <input type="checkbox" name="{$langListKey|escape}[]" value="{$code|escape}"{if in_array($code, $selectedLanguages)} checked{/if}>
                                {/foreach}
                            </div>

                            {* Visible chip field *}
                            <div class="mt-multi" id="mt-lang-multi" tabindex="0" role="combobox" aria-haspopup="listbox" aria-expanded="false">
                                <div class="mt-multi-chips" id="mt-lang-chips"></div>
                                <span class="mt-multi-placeholder" id="mt-lang-placeholder">Click to add languages…</span>
                                <span class="mt-multi-caret" aria-hidden="true">
                                    <svg viewBox="0 0 16 16" fill="none"><path d="M4 6l4 4 4-4" stroke="currentColor" stroke-width="1.5" stroke-linecap="round"/></svg>
                                </span>
                            </div>

                            {* Dropdown panel *}
                            <div class="mt-multi-panel" id="mt-lang-panel" hidden role="listbox" aria-multiselectable="true">
                                <div class="mt-multi-search-wrap">
                                    <input type="search" id="mt-lang-search" placeholder="Search languages…" autocomplete="off" aria-label="Search languages">
                                </div>
                                <div class="mt-multi-options" id="mt-lang-options">
                                    {foreach $installedLanguages as $code}
                                        <button type="button" class="mt-multi-option" data-code="{$code|escape}" role="option" aria-selected="false">
                                            <span class="mt-multi-check" aria-hidden="true">
                                                <svg viewBox="0 0 16 16" fill="none" stroke="#fff" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><polyline points="3 8 7 12 13 4"/></svg>
                                            </span>
                                            <span>{$code|escape|capitalize}</span>
                                        </button>
                                    {/foreach}
                                </div>
                                <div class="mt-multi-empty" id="mt-lang-empty" hidden>No languages match.</div>
                                <div class="mt-multi-actions">
                                    <button type="button" class="mt-link-btn" id="mt-lang-all">Select all</button>
                                    <button type="button" class="mt-link-btn" id="mt-lang-none">Clear</button>
                                </div>
                            </div>
                        </div>
                    {/if}
                </div>
            {/if}
        {/foreach}
    </section>

    <div style="margin-top:16px;display:flex;justify-content:flex-end">
        <button type="submit" class="mt-btn mt-btn-primary">Save changes</button>
    </div>
</form>

<script>
(function () {
    // ── Toggle reveal (parent row toggle ↔ sub-section) ──
    var toggle  = document.querySelector('[data-toggle-target="mt-language-picker"]');
    var section = document.getElementById('mt-language-picker');
    if (toggle && section) {
        toggle.addEventListener('change', function () {
            section.hidden = !toggle.checked;
        });
    }

    // ── Chip multi-select ──
    var inputs      = document.getElementById('mt-lang-inputs');
    var multi       = document.getElementById('mt-lang-multi');
    var chips       = document.getElementById('mt-lang-chips');
    var placeholder = document.getElementById('mt-lang-placeholder');
    var panel       = document.getElementById('mt-lang-panel');
    var options     = document.getElementById('mt-lang-options');
    var search      = document.getElementById('mt-lang-search');
    var empty       = document.getElementById('mt-lang-empty');
    var counter     = document.getElementById('mt-lang-count');
    if (!inputs || !multi) return;

    function capitalize(s) { return s.charAt(0).toUpperCase() + s.slice(1); }

    function checkboxFor(code) {
        // Defensive value selector — language codes are ASCII so CSS.escape
        // isn't strictly needed, but use it when available for safety.
        var esc = (window.CSS && CSS.escape) ? CSS.escape(code) : code.replace(/[^a-zA-Z0-9_-]/g, '\\$&');
        return inputs.querySelector('input[value="' + esc + '"]');
    }

    function selectedCodes() {
        return Array.prototype.map.call(inputs.querySelectorAll('input:checked'), function (cb) { return cb.value; });
    }

    function render() {
        var selected = selectedCodes();
        // Rebuild chip row
        chips.innerHTML = '';
        selected.forEach(function (code) {
            var chip = document.createElement('span');
            chip.className = 'mt-multi-chip';
            var label = document.createElement('span');
            label.textContent = capitalize(code);
            var x = document.createElement('span');
            x.className = 'mt-multi-chip-x';
            x.setAttribute('data-remove', code);
            x.setAttribute('role', 'button');
            x.setAttribute('aria-label', 'Remove ' + code);
            x.innerHTML = '&times;';
            chip.appendChild(label);
            chip.appendChild(x);
            chips.appendChild(chip);
        });
        placeholder.hidden = selected.length > 0;
        // Update option ticks
        var selectedSet = {};
        selected.forEach(function (c) { selectedSet[c] = true; });
        Array.prototype.forEach.call(options.querySelectorAll('.mt-multi-option'), function (opt) {
            var on = !!selectedSet[opt.getAttribute('data-code')];
            opt.classList.toggle('is-checked', on);
            opt.setAttribute('aria-selected', on ? 'true' : 'false');
        });
        // Sub-header counter
        if (counter) {
            var total = inputs.querySelectorAll('input').length;
            counter.textContent = selected.length + ' of ' + total + ' selected';
        }
    }

    function setSelection(code, on) {
        var cb = checkboxFor(code);
        if (!cb) return;
        cb.checked = on;
        render();
    }

    function openPanel() {
        panel.hidden = false;
        multi.classList.add('is-focused');
        multi.setAttribute('aria-expanded', 'true');
        if (search) {
            search.value = '';
            filter('');
            setTimeout(function () { search.focus(); }, 0);
        }
    }
    function closePanel() {
        panel.hidden = true;
        multi.classList.remove('is-focused');
        multi.setAttribute('aria-expanded', 'false');
    }

    function filter(q) {
        q = (q || '').toLowerCase().trim();
        var anyVisible = false;
        Array.prototype.forEach.call(options.querySelectorAll('.mt-multi-option'), function (opt) {
            var code = (opt.getAttribute('data-code') || '').toLowerCase();
            var match = !q || code.indexOf(q) >= 0;
            opt.style.display = match ? '' : 'none';
            if (match) anyVisible = true;
        });
        if (empty) empty.hidden = anyVisible;
    }

    // Open the panel on field click OR keyboard activation. Chip × is
    // handled here too so a click on × removes the chip but doesn't bubble
    // up to open the panel.
    multi.addEventListener('click', function (e) {
        var rm = e.target.closest('[data-remove]');
        if (rm) {
            e.stopPropagation();
            setSelection(rm.getAttribute('data-remove'), false);
            return;
        }
        if (panel.hidden) openPanel();
    });
    multi.addEventListener('keydown', function (e) {
        if (e.key === 'Enter' || e.key === ' ' || e.key === 'ArrowDown') {
            e.preventDefault();
            if (panel.hidden) openPanel();
        }
        if (e.key === 'Escape') closePanel();
    });

    // Outside click closes
    document.addEventListener('click', function (e) {
        if (multi.contains(e.target) || panel.contains(e.target)) return;
        closePanel();
    });

    // Option pick — toggle selection. Keeps panel open for multi-pick.
    options.addEventListener('click', function (e) {
        var opt = e.target.closest('.mt-multi-option');
        if (!opt) return;
        e.preventDefault();
        var code = opt.getAttribute('data-code');
        var cb = checkboxFor(code);
        if (!cb) return;
        setSelection(code, !cb.checked);
    });

    // Search filter
    if (search) {
        search.addEventListener('input', function () { filter(search.value); });
        search.addEventListener('keydown', function (e) { if (e.key === 'Escape') closePanel(); });
    }

    // Select all / Clear
    var bSelectAll = document.getElementById('mt-lang-all');
    var bSelectNone = document.getElementById('mt-lang-none');
    if (bSelectAll) bSelectAll.addEventListener('click', function () {
        Array.prototype.forEach.call(inputs.querySelectorAll('input'), function (cb) { cb.checked = true; });
        render();
    });
    if (bSelectNone) bSelectNone.addEventListener('click', function () {
        Array.prototype.forEach.call(inputs.querySelectorAll('input'), function (cb) { cb.checked = false; });
        render();
    });

    render();
})();
</script>

{include file="includes/footer.tpl"}
