{* Buttons form (Lagom-style sizes + per-variant select-colors matrix). Rendered
   by StylesController::editAction; $buttons carries grouped colour options, the
   size fields (effective value + default) and the variant matrix (per slot:
   current option key, default, preview swatch). Buttons are SITE-WIDE (one
   mapping styles both light + dark), so this posts a global mt_buttons form —
   no per-style key. Swatch sync + reset + live preview wired in includes/
   footer.tpl. Mirrors _colors.tpl. *}
<form method="post" action="?module=Hadrian&action=editStyle&style={$style|escape}&subcat=buttons" class="mt-buttons">
    <input type="hidden" name="mt_buttons" value="1">
    <input type="hidden" name="style" value="{$style|escape}">

    {if $buttonsSaved}<div class="mt-alert mt-alert-success">Buttons saved.</div>{/if}

    <section class="mt-section">
        <header class="mt-section-header">
            {* Docs link nests in the h2 -- a third sibling in this
               space-between header strands the count badge dead-centre. *}
            <h2 class="mt-section-title mt-tip-line">Buttons {include file="includes/doclink.tpl" article="styles" anchor="general-buttons-forms-and-elements"}</h2>
            <span class="mt-section-count">Applies site-wide</span>
        </header>
        <p class="mt-field-help">Size and recolour every button variant. Colours are picked from the theme palette (so they track your accent + dark mode automatically) &mdash; only changed values are saved. These settings apply across all styles.</p>
    </section>

    <section class="mt-section">
        <header class="mt-section-header"><h2 class="mt-section-title">Sizes</h2></header>
        {foreach $buttons.sizeTiers as $tierName => $fields}
        <div class="mt-typo-group-label">{$tierName|escape}</div>
        <div class="mt-typo-grid">
            {foreach $fields as $f}
            <div class="mt-typo-field">
                <label class="mt-typo-field-label" for="sz{$f.var|replace:'--':'_'}">{$f.label|escape}</label>
                {if $f.type == 'scale'}
                <select id="sz{$f.var|replace:'--':'_'}" name="size[{$f.var}]" class="mt-select mt-input-compact" data-default="{$f.default}">
                    {foreach $f.options as $o}
                    <option value="{$o.key}"{if $o.key == $f.current} selected{/if}>{$o.label|escape}</option>
                    {/foreach}
                </select>
                {else}
                <span class="mt-affix">
                    <input type="number" id="sz{$f.var|replace:'--':'_'}" name="size[{$f.var}]" class="mt-input mt-input-compact" value="{$f.value}" data-default="{$f.default}" min="0" max="999" step="1" inputmode="numeric">
                    <span class="mt-affix-unit">px</span>
                </span>
                {/if}
            </div>
            {/foreach}
        </div>
        {/foreach}
        <p class="mt-field-help" style="margin-top:10px;">Each tier is built from your Typography scale &mdash; pick a font size, weight, line-height and radius. The button height follows the font size automatically; defaults keep the Apple look (pill radius).</p>
    </section>

    <section class="mt-section">
        <header class="mt-section-header">
            <h2 class="mt-section-title">Variant colours</h2>
            <span class="mt-section-count">{$buttons.variants|count} variants</span>
        </header>
        <div class="mt-btn-variants">
            {foreach $buttons.variants as $variant}
            <div class="mt-btn-variant" data-variant="{$variant.key}">
                <div class="mt-btn-variant-head">
                    <span class="mt-btn-variant-name">{$variant.label|escape}</span>
                    <code class="mt-btn-variant-class">.btn-{$variant.key}</code>
                </div>
                <div class="mt-btn-matrix">
                    {foreach $variant.cells as $cell}
                    <label class="mt-btn-cell">
                        <span class="mt-btn-cell-label">{$cell.label|escape}</span>
                        <span class="mt-btn-cell-control">
                            <span class="mt-btn-cell-swatch" data-swatch-for="{$variant.key}.{$cell.slot}" style="background:{$cell.swatch}"></span>
                            <select class="mt-select mt-input-compact mt-btn-select" name="v[{$variant.key}][{$cell.slot}]" data-variant="{$variant.key}" data-slot="{$cell.slot}" data-default="{$cell.default}">
                                {foreach $buttons.optionGroups as $optGroupName => $opts}
                                <optgroup label="{$optGroupName|escape}">
                                    {foreach $opts as $o}
                                    <option value="{$o.key}" data-swatch="{$o.swatch}"{if $o.key == $cell.current} selected{/if}>{$o.label|escape}</option>
                                    {/foreach}
                                </optgroup>
                                {/foreach}
                            </select>
                        </span>
                    </label>
                    {/foreach}
                </div>
            </div>
            {/foreach}
        </div>
    </section>

    {* The inline action row became the floating save bar that every page with
       a page-level save now carries. Safe here even though all six style panels
       render into one document: the five inactive ones sit inside a [hidden]
       .mt-subcat-panel, and a position:fixed element inside a display:none
       ancestor has a zero rect -- measured, so exactly one bar paints.

       Reset keeps its id: the footer.tpl IIFE for this panel finds it by id
       inside the form, and the bar is inside the form. *}
    {assign var=mtCancel value="?module=Hadrian&action=editStyle&style=`$style|escape`&subcat=buttons"}
    {include file="includes/savebar.tpl" cancel=$mtCancel quiet="Reset all to default" quietId="mt-buttons-reset" label="Save buttons"}
</form>
