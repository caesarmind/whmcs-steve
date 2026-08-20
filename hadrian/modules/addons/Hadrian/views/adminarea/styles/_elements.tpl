{* Elements form — component shape (radius / shadow / padding). Rendered by
   StylesController::editAction; $elements carries size groups (each field with
   a px value or a scale current+options). Site-wide -> global mt_elements form.
   Reset wired in includes/footer.tpl. Mirrors the Sizes section of _forms.tpl. *}
<form method="post" action="?module=Hadrian&action=editStyle&style={$style|escape}&subcat=elements" class="mt-elements">
    <input type="hidden" name="mt_elements" value="1">
    <input type="hidden" name="style" value="{$style|escape}">

    {if $elementsSaved}<div class="mt-alert mt-alert-success">Elements saved.</div>{/if}

    <section class="mt-section">
        <header class="mt-section-header">
            {* Docs link nests in the h2 -- a third sibling in this
               space-between header strands the count badge dead-centre. *}
            <h2 class="mt-section-title mt-tip-line">Elements {include file="includes/doclink.tpl" article="styles" anchor="general-buttons-forms-and-elements"}</h2>
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

    {* The inline action row became the floating save bar that every page with
       a page-level save now carries. Safe here even though all six style panels
       render into one document: the five inactive ones sit inside a [hidden]
       .mt-subcat-panel, and a position:fixed element inside a display:none
       ancestor has a zero rect -- measured, so exactly one bar paints.

       Reset keeps its id: the footer.tpl IIFE for this panel finds it by id
       inside the form, and the bar is inside the form. *}
    {assign var=mtCancel value="?module=Hadrian&action=editStyle&style=`$style|escape`&subcat=elements"}
    {include file="includes/savebar.tpl" cancel=$mtCancel quiet="Reset all to default" quietId="mt-elements-reset" label="Save elements"}
</form>
