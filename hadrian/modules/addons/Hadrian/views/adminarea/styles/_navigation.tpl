{* Navigation form -- main-menu GEOMETRY: logo height, menu icon tile + glyph,
   and the width or height each layout owns. Rendered by
   StylesController::editAction; $navigation.groups carries each field with its
   effective value, its default, and an "Applies to" caption derived from the
   layout manifests.

   These ten controls used to render on the Layouts page, inside its Containers
   section. They moved because that page answers "which layout do I run", not
   "how big is it", and because ten of them had outgrown a page-structure panel.
   core/config/navigation.php's header carries the full reasoning.

   Site-wide -> global mt_navigation form, stored in <tpl>_navigation_vars --
   its OWN row, never the _layout_vars blob the Layouts page merges into. Two
   panels writing one row, one merging and one wholesale, is how a saved content
   width gets erased by an unrelated save. Mirrors _general.tpl otherwise. *}
<form method="post" action="?module=Hadrian&action=editStyle&style={$style|escape}&subcat=navigation" class="mt-navigation">
    <input type="hidden" name="mt_navigation" value="1">
    <input type="hidden" name="style" value="{$style|escape}">

    {if $navigationSaved}<div class="mt-alert mt-alert-success">Navigation saved.</div>{/if}

    <section class="mt-section">
        <header class="mt-section-header">
            {* Docs link nests in the h2 -- a third sibling in this
               space-between header strands the count badge dead-centre. *}
            <h2 class="mt-section-title mt-tip-line">Navigation {include file="includes/doclink.tpl" article="styles" anchor="navigation"}</h2>
            <span class="mt-section-count">Applies site-wide</span>
        </header>
        <p class="mt-field-help">The measurements of the main menu &mdash; how tall the logo sits, how big a menu icon is, and the width or height each layout reserves for its own navigation. Colours for the same bars live under <strong>Colors</strong>, and their type under <strong>Typography</strong>. Only changed values are saved.</p>
    </section>

    <section class="mt-section">
        {foreach $navigation.groups as $groupName => $fields}
        <div class="mt-typo-group-label">{$groupName|escape}</div>
        {* Its own grid, not .mt-typo-grid: these fields carry a sentence
           underneath ("Applies to the Sidebar and Icon Rail layouts") and
           148px columns wrap it to four lines. *}
        <div class="mt-nav-grid">
            {foreach $fields as $f}
            <div class="mt-nav-field">
                <label class="mt-typo-field-label" for="nv{$f.var|replace:'--':'_'}">{$f.label|escape}</label>
                <span class="mt-affix">
                    <input type="number" id="nv{$f.var|replace:'--':'_'}" name="nav[{$f.var}]" class="mt-input mt-input-compact" value="{$f.value}" data-default="{$f.default}" min="0" max="4000" step="1" inputmode="numeric">
                    <span class="mt-affix-unit">px</span>
                </span>
                {* Derived from which layout manifests name this token in their
                   `sizes` array, NOT typed here -- so it stays true when a
                   layout is added, retired or dropped in. A token no layout
                   claims prints no caption rather than an invented one. *}
                {if $f.applies}
                    <span class="mt-nav-applies">Applies to the {$f.applies|escape} {if $f.plural}layouts{else}layout{/if}. Default {$f.default}px.</span>
                {else}
                    <span class="mt-nav-applies">Default {$f.default}px.</span>
                {/if}
            </div>
            {/foreach}
        </div>
        {/foreach}
    </section>

    {* The floating save bar every page with a page-level save now carries. Safe
       here even though all seven style panels render into one document: the six
       inactive ones sit inside a [hidden] .mt-subcat-panel, and a
       position:fixed element inside a display:none ancestor has a zero rect --
       measured, so exactly one bar paints.

       Reset gets its own id AND this form its own class (.mt-navigation): the
       footer.tpl IIFE finds the button by id inside the form, and a class shared
       with another panel would point one panel's reset at another panel's
       fields. *}
    {assign var=mtCancel value="?module=Hadrian&action=editStyle&style=`$style|escape`&subcat=navigation"}
    {include file="includes/savebar.tpl" cancel=$mtCancel quiet="Reset all to default" quietId="mt-navigation-reset" label="Save navigation"}
</form>
