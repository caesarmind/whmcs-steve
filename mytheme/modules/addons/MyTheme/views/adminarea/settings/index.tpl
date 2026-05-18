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
    .mt-chip-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(180px, 1fr)); gap: 8px; margin-top: 4px; }
    .mt-chip-check { position: relative; display: block; cursor: pointer; }
    .mt-chip-check input { position: absolute; opacity: 0; pointer-events: none; }
    .mt-chip-check .mt-chip-body { display: flex; align-items: center; gap: 8px; padding: 10px 12px; border: 1px solid var(--mt-border); border-radius: 8px; background: #fff; font-size: 13px; color: var(--mt-text-1); transition: border-color .15s ease, background .15s ease; }
    .mt-chip-check:hover .mt-chip-body { border-color: var(--mt-text-3); }
    .mt-chip-check input:checked + .mt-chip-body { border-color: var(--mt-accent, #0071e3); background: rgba(0, 113, 227, 0.06); color: var(--mt-text-1); }
    .mt-chip-check input:focus-visible + .mt-chip-body { outline: 2px solid var(--mt-accent, #0071e3); outline-offset: 2px; }
    .mt-chip-check .mt-chip-tick { width: 14px; height: 14px; display: inline-flex; align-items: center; justify-content: center; border: 1px solid var(--mt-border); border-radius: 4px; flex-shrink: 0; }
    .mt-chip-check input:checked + .mt-chip-body .mt-chip-tick { border-color: var(--mt-accent, #0071e3); background: var(--mt-accent, #0071e3); color: #fff; }
    .mt-chip-check .mt-chip-tick svg { width: 10px; height: 10px; opacity: 0; }
    .mt-chip-check input:checked + .mt-chip-body .mt-chip-tick svg { opacity: 1; }
    .mt-language-section[hidden] { display: none; }
    .mt-language-actions { display: flex; gap: 8px; margin-top: 10px; }
    .mt-link-btn { background: none; border: 0; padding: 0; color: var(--mt-accent, #0071e3); font: inherit; cursor: pointer; font-size: 13px; }
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
            <div class="mt-row">
                <div>
                    <div class="mt-row-label">{$meta[0]|escape}</div>
                    <div class="mt-row-help">{$meta[1]|escape}</div>
                </div>
                <label class="mt-toggle">
                    <input type="checkbox" name="{$key|escape}" {if $key == 'custom_language_list'}data-toggle-target="mt-language-picker" {/if}{if $values[$key]}checked{/if}>
                    <span class="mt-toggle-track"><span class="mt-toggle-thumb"></span></span>
                </label>
            </div>
        {/foreach}
    </section>

    {* Language picker — only meaningful when "Custom Language List" is on, but
       always rendered (collapsed) so the admin can preview the choices before
       enabling. The toggle controls visibility via JS; values are submitted
       under {$langListKey}[] regardless of toggle state, and Hooks.php only
       reads them when the toggle is active. *}
    <section class="mt-section mt-language-section" id="mt-language-picker" {if !$values.custom_language_list}hidden{/if}>
        <header class="mt-section-header">
            <h2 class="mt-section-title">Languages shown to clients</h2>
            <div class="mt-section-tools">
                <span class="mt-section-count" id="mt-lang-count"></span>
            </div>
        </header>

        <p class="mt-row-help" style="margin: -8px 0 14px;">
            Pick which languages appear in the locale chooser. Only languages installed in <code>/lang/</code> are shown.
            {if !$installedLanguages}<strong>No language files found.</strong>{/if}
        </p>

        {if $installedLanguages}
            <div class="mt-chip-grid" id="mt-lang-grid">
                {foreach $installedLanguages as $code}
                    <label class="mt-chip-check">
                        <input type="checkbox" name="{$langListKey|escape}[]" value="{$code|escape}"{if in_array($code, $selectedLanguages)} checked{/if}>
                        <span class="mt-chip-body">
                            <span class="mt-chip-tick" aria-hidden="true">
                                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"/></svg>
                            </span>
                            <span>{$code|escape|capitalize}</span>
                        </span>
                    </label>
                {/foreach}
            </div>

            <div class="mt-language-actions">
                <button type="button" class="mt-link-btn" data-lang-select-all>Select all</button>
                <span style="color: var(--mt-text-3)">·</span>
                <button type="button" class="mt-link-btn" data-lang-select-none>Clear</button>
            </div>
        {/if}
    </section>

    <div style="margin-top:16px;display:flex;justify-content:flex-end">
        <button type="submit" class="mt-btn mt-btn-primary">Save changes</button>
    </div>
</form>

<script>
(function () {
    var toggle = document.querySelector('[data-toggle-target="mt-language-picker"]');
    var section = document.getElementById('mt-language-picker');
    var grid = document.getElementById('mt-lang-grid');
    var counter = document.getElementById('mt-lang-count');

    function refreshCount() {
        if (!grid || !counter) return;
        var checked = grid.querySelectorAll('input[type="checkbox"]:checked').length;
        var total = grid.querySelectorAll('input[type="checkbox"]').length;
        counter.textContent = checked + ' of ' + total + ' selected';
    }

    if (toggle && section) {
        toggle.addEventListener('change', function () {
            section.hidden = !toggle.checked;
        });
    }

    if (grid) {
        grid.addEventListener('change', refreshCount);
        refreshCount();
    }

    var selectAll = document.querySelector('[data-lang-select-all]');
    var selectNone = document.querySelector('[data-lang-select-none]');
    if (selectAll && grid) {
        selectAll.addEventListener('click', function () {
            grid.querySelectorAll('input[type="checkbox"]').forEach(function (cb) { cb.checked = true; });
            refreshCount();
        });
    }
    if (selectNone && grid) {
        selectNone.addEventListener('click', function () {
            grid.querySelectorAll('input[type="checkbox"]').forEach(function (cb) { cb.checked = false; });
            refreshCount();
        });
    }
})();
</script>

{include file="includes/footer.tpl"}
