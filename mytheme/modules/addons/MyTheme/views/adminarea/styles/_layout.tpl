{* Layout form — page-structure dimensions (px). Rendered by
   StylesController::editAction; $layoutVars carries size groups (each field with
   its effective px value + default). Site-wide -> global mt_layout form. Reset
   wired in includes/footer.tpl. Mirrors the Sizes section of _forms.tpl. *}
<form method="post" action="?module=MyTheme&action=editStyle&style={$style|escape}&subcat=layout" class="mt-layout">
    <input type="hidden" name="mt_layout" value="1">
    <input type="hidden" name="style" value="{$style|escape}">

    {if $layoutSaved}<div class="mt-alert mt-alert-success">Layout saved.</div>{/if}

    <section class="mt-section">
        <header class="mt-section-header">
            <h2 class="mt-section-title">Layout</h2>
            <span class="mt-section-count">Applies site-wide</span>
        </header>
        <p class="mt-field-help">Page-structure dimensions in pixels &mdash; the content column, sidebar and topbar geometry across the client area. Only changed values are saved.</p>
    </section>

    <section class="mt-section">
        {foreach $layoutVars.sizeGroups as $groupName => $fields}
        <div class="mt-typo-group-label">{$groupName|escape}</div>
        <div class="mt-typo-grid">
            {foreach $fields as $f}
            <div class="mt-typo-field">
                <label class="mt-typo-field-label" for="ly{$f.var|replace:'--':'_'}">{$f.label|escape}</label>
                <span class="mt-affix">
                    <input type="number" id="ly{$f.var|replace:'--':'_'}" name="size[{$f.var}]" class="mt-input mt-input-compact" value="{$f.value}" data-default="{$f.default}" min="0" max="4000" step="1" inputmode="numeric">
                    <span class="mt-affix-unit">px</span>
                </span>
            </div>
            {/foreach}
        </div>
        {/foreach}
    </section>

    <div class="mt-typo-actions">
        <button type="button" class="mt-btn mt-btn-secondary" id="mt-layout-reset">Reset all to default</button>
        <button type="submit" class="mt-btn mt-btn-primary">Save layout</button>
    </div>
</form>
