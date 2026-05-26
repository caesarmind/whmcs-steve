{* Elements form — component shape (radius / shadow / padding). Rendered by
   StylesController::editAction; $elements carries size groups (each field with
   a px value or a scale current+options). Site-wide -> global mt_elements form.
   Reset wired in includes/footer.tpl. Mirrors the Sizes section of _forms.tpl. *}
<form method="post" action="?module=MyTheme&action=editStyle&style={$style|escape}&subcat=elements" class="mt-elements">
    <input type="hidden" name="mt_elements" value="1">
    <input type="hidden" name="style" value="{$style|escape}">

    {if $elementsSaved}<div class="mt-alert mt-alert-success">Elements saved.</div>{/if}

    <section class="mt-section">
        <header class="mt-section-header">
            <h2 class="mt-section-title">Elements</h2>
            <span class="mt-section-count">Applies site-wide</span>
        </header>
        <p class="mt-field-help">Shape of UI components &mdash; radius, shadow and padding. Colours stay in the Colors panel. Sizes reference the theme radius scale; only changed values are saved.</p>
    </section>

    <section class="mt-section">
        {foreach $elements.sizeGroups as $groupName => $fields}
        <div class="mt-typo-group-label">{$groupName|escape}</div>
        <div class="mt-typo-grid">
            {foreach $fields as $f}
            <div class="mt-typo-field">
                <label class="mt-typo-field-label" for="el{$f.var|replace:'--':'_'}">{$f.label|escape}</label>
                {if $f.type == 'scale'}
                <select id="el{$f.var|replace:'--':'_'}" name="size[{$f.var}]" class="mt-select mt-input-compact" data-default="{$f.default}">
                    {foreach $f.options as $o}
                    <option value="{$o.key}"{if $o.key == $f.current} selected{/if}>{$o.label|escape}</option>
                    {/foreach}
                </select>
                {else}
                <span class="mt-affix">
                    <input type="number" id="el{$f.var|replace:'--':'_'}" name="size[{$f.var}]" class="mt-input mt-input-compact" value="{$f.value}" data-default="{$f.default}" min="0" max="999" step="1" inputmode="numeric">
                    <span class="mt-affix-unit">px</span>
                </span>
                {/if}
            </div>
            {/foreach}
        </div>
        {/foreach}
    </section>

    <div class="mt-typo-actions">
        <button type="button" class="mt-btn mt-btn-secondary" id="mt-elements-reset">Reset all to default</button>
        <button type="submit" class="mt-btn mt-btn-primary">Save elements</button>
    </div>
</form>
