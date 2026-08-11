{* Forms form (Lagom-style field / label / checkbox customizer). Rendered by
   StylesController::editAction; $forms carries grouped colour options, size
   groups (px value or scale current+options) and colour groups (current option
   key + preview swatch). Site-wide -> global mt_forms form, no per-style key.
   Swatch sync + reset wired in includes/footer.tpl. Mirrors _buttons.tpl. *}
<form method="post" action="?module=Hadrian&action=editStyle&style={$style|escape}&subcat=forms" class="mt-forms">
    <input type="hidden" name="mt_forms" value="1">
    <input type="hidden" name="style" value="{$style|escape}">

    {if $formsSaved}<div class="mt-alert mt-alert-success">Forms saved.</div>{/if}

    <section class="mt-section">
        <header class="mt-section-header">
            <h2 class="mt-section-title">Forms</h2>
            <span class="mt-section-count">Applies site-wide</span>
        </header>
        <p class="mt-field-help">Style inputs, labels and checkboxes. Sizes reference your Typography &amp; radius scales; colours come from the theme palette, so they track your accent and dark mode automatically. Only changed values are saved.</p>
    </section>

    <section class="mt-section">
        <header class="mt-section-header"><h2 class="mt-section-title">Sizes</h2></header>
        {foreach $forms.sizeGroups as $groupName => $fields}
        <div class="mt-typo-group-label">{$groupName|escape}</div>
        <div class="mt-typo-grid">
            {foreach $fields as $f}
            <div class="mt-typo-field">
                <label class="mt-typo-field-label" for="fz{$f.var|replace:'--':'_'}">{$f.label|escape}</label>
                {if $f.type == 'scale'}
                <select id="fz{$f.var|replace:'--':'_'}" name="size[{$f.var}]" class="mt-select mt-input-compact" data-default="{$f.default}">
                    {foreach $f.options as $o}
                    <option value="{$o.key}"{if $o.key == $f.current} selected{/if}>{$o.label|escape}</option>
                    {/foreach}
                </select>
                {else}
                <span class="mt-affix">
                    <input type="number" id="fz{$f.var|replace:'--':'_'}" name="size[{$f.var}]" class="mt-input mt-input-compact" value="{$f.value}" data-default="{$f.default}" min="0" max="999" step="1" inputmode="numeric">
                    <span class="mt-affix-unit">px</span>
                </span>
                {/if}
            </div>
            {/foreach}
        </div>
        {/foreach}
    </section>

    <section class="mt-section">
        <header class="mt-section-header"><h2 class="mt-section-title">Colours</h2></header>
        {foreach $forms.colorGroups as $groupName => $fields}
        <div class="mt-typo-group-label">{$groupName|escape}</div>
        <div class="mt-btn-matrix">
            {foreach $fields as $f}
            <label class="mt-btn-cell">
                <span class="mt-btn-cell-label">{$f.label|escape}</span>
                <span class="mt-btn-cell-control">
                    <span class="mt-btn-cell-swatch" data-swatch-for="{$f.var}" style="background:{$f.swatch}"></span>
                    <select class="mt-select mt-input-compact mt-form-select" name="c[{$f.var}]" data-var="{$f.var}" data-default="{$f.default}">
                        {foreach $forms.optionGroups as $optGroupName => $opts}
                        <optgroup label="{$optGroupName|escape}">
                            {foreach $opts as $o}
                            <option value="{$o.key}" data-swatch="{$o.swatch}"{if $o.key == $f.current} selected{/if}>{$o.label|escape}</option>
                            {/foreach}
                        </optgroup>
                        {/foreach}
                    </select>
                </span>
            </label>
            {/foreach}
        </div>
        {/foreach}
    </section>

    {* The inline action row became the floating save bar that every page with
       a page-level save now carries. Safe here even though all six style panels
       render into one document: the five inactive ones sit inside a [hidden]
       .mt-subcat-panel, and a position:fixed element inside a display:none
       ancestor has a zero rect -- measured, so exactly one bar paints.

       Reset keeps its id: the footer.tpl IIFE for this panel finds it by id
       inside the form, and the bar is inside the form. *}
    {assign var=mtCancel value="?module=Hadrian&action=editStyle&style=`$style|escape`&subcat=forms"}
    {include file="includes/savebar.tpl" cancel=$mtCancel quiet="Reset all to default" quietId="mt-forms-reset" label="Save forms"}
</form>
