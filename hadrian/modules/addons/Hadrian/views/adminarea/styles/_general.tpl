{* General form -- the SCALE LAYER the other panels select between: corner
   radius, shadow, control sizing and motion. Rendered by
   StylesController::editAction; $general.groups carries each field with its
   effective value + default, $general.shadowOptions the authored shadow stacks.

   Elements/Buttons/Forms let a buyer pick "Card radius = Large"; this panel is
   where Large gets its number. Site-wide -> global mt_general form. Mirrors
   _elements.tpl for the dropdowns. (The px fields moved to the Layouts
   page, onto the layout each dimension belongs to.) *}
<form method="post" action="?module=Hadrian&action=editStyle&style={$style|escape}&subcat=general" class="mt-general">
    <input type="hidden" name="mt_general" value="1">
    <input type="hidden" name="style" value="{$style|escape}">

    {if $generalSaved}<div class="mt-alert mt-alert-success">General saved.</div>{/if}

    <section class="mt-section">
        <header class="mt-section-header">
            {* Docs link nests in the h2 -- a third sibling in this
               space-between header strands the count badge dead-centre. *}
            <h2 class="mt-section-title mt-tip-line">General {include file="includes/doclink.tpl" article="styles" anchor="general-buttons-forms-and-elements"}</h2>
            <span class="mt-section-count">Applies site-wide</span>
        </header>
        <p class="mt-field-help">The shared scales the rest of the theme is built from. Corner radius, shadow depth, control sizing and animation speed &mdash; the Elements, Buttons and Forms panels choose <em>which</em> step to use, and this is where each step gets its value. Only changed values are saved.</p>
    </section>

    <section class="mt-section">
        {foreach $general.groups as $groupName => $fields}
        <div class="mt-typo-group-label">{$groupName|escape}</div>
        <div class="mt-typo-grid">
            {foreach $fields as $f}
            <div class="mt-typo-field">
                <label class="mt-typo-field-label" for="gn{$f.var|replace:'--':'_'}">{$f.label|escape}</label>
                {if $f.type == 'preset'}
                    {* Shadows are composite multi-layer strings with no
                       validator short of a CSS parser, so the control offers
                       the stacks we author rather than free text. *}
                    <select id="gn{$f.var|replace:'--':'_'}" name="gen[{$f.var}]" class="mt-input mt-input-compact" data-default="{$f.default|escape}">
                        {foreach $general.shadowOptions as $o}
                        <option value="{$o.key|escape}"{if $o.key == $f.value} selected{/if}>{$o.label|escape}</option>
                        {/foreach}
                    </select>
                {elseif $f.type == 'hex'}
                    {* Custom shadow tint. A native colour input posts #rrggbb,
                       the one form the save path accepts. *}
                    <span class="mt-shc-color">
                        <input type="color" id="gn{$f.var|replace:'--':'_'}" name="gen[{$f.var}]" class="mt-color-swatch-input" value="{$f.value|escape}" data-default="{$f.default|escape}" data-shc="{$f.var|escape}">
                        <code class="mt-shc-hex">{$f.value|escape}</code>
                    </span>
                {elseif isset($f.max)}
                    {* A bounded field (the Custom shadow offset, blur and
                       strength) is a slider with its value beside it. *}
                    <span class="mt-shc-slider">
                        <input type="range" id="gn{$f.var|replace:'--':'_'}" name="gen[{$f.var}]" value="{$f.value}" data-default="{$f.default}" min="{$f.min|default:0}" max="{$f.max}" step="1" data-shc="{$f.var|escape}" data-unit="{if $f.type == 'pct'}%{else}px{/if}">
                        <output class="mt-shc-out" for="gn{$f.var|replace:'--':'_'}">{$f.value}{if $f.type == 'pct'}%{else}px{/if}</output>
                    </span>
                {elseif $f.type == 'em'}
                    <span class="mt-affix">
                        <input type="number" id="gn{$f.var|replace:'--':'_'}" name="gen[{$f.var}]" class="mt-input mt-input-compact" value="{$f.value}" data-default="{$f.default}" min="0" max="20" step="0.01" inputmode="decimal">
                        <span class="mt-affix-unit">em</span>
                    </span>
                {else}
                    <span class="mt-affix">
                        <input type="number" id="gn{$f.var|replace:'--':'_'}" name="gen[{$f.var}]" class="mt-input mt-input-compact" value="{$f.value}" data-default="{$f.default}" min="0" max="4000" step="1" inputmode="numeric">
                        <span class="mt-affix-unit">{if $f.type == 'ms'}ms{else}px{/if}</span>
                    </span>
                {/if}
            </div>
            {/foreach}
        </div>
        {if $fields.0.var == '--shadow-custom-y'}
        {* Live preview. footer.tpl repaints it from the four controls, with
           the same formula core-theme.css composes --shadow-custom from. *}
        <div class="mt-shc-stage" aria-hidden="true"><div class="mt-shc-card" data-shc-preview>Custom shadow</div></div>
        <p class="mt-field-help">To use it, pick <b>Custom</b> in the Card, Card hover or Dropdown menu above, or in the Shadow menu on the Elements tab. Until something picks it, these values change nothing.</p>
        {/if}
        {/foreach}
    </section>
    {literal}<style>
    .mt-shc-slider { display: flex; align-items: center; gap: 10px; }
    .mt-shc-slider input[type="range"] { flex: 1; min-width: 0; accent-color: var(--mt-primary); margin: 0; }
    .mt-shc-out { min-width: 42px; text-align: right; font-variant-numeric: tabular-nums; font-size: 12px; color: var(--mt-text-2); }
    .mt-shc-color { display: inline-flex; align-items: center; gap: 8px; }
    .mt-shc-hex { font-size: 12px; color: var(--mt-text-2); }
    .mt-shc-stage { margin: 12px 0 8px; padding: 28px; border-radius: 12px; background: var(--mt-surface-2); display: flex; justify-content: center; }
    .mt-shc-card { width: 220px; padding: 18px 20px; border-radius: 12px; background: var(--mt-surface); color: var(--mt-text); font-size: 13px; font-weight: 500; text-align: center; }
    </style>{/literal}

    {* The inline action row became the floating save bar that every page with
       a page-level save now carries. Safe here even though all six style panels
       render into one document: the five inactive ones sit inside a [hidden]
       .mt-subcat-panel, and a position:fixed element inside a display:none
       ancestor has a zero rect -- measured, so exactly one bar paints.

       Reset keeps its id: the footer.tpl IIFE for this panel finds it by id
       inside the form, and the bar is inside the form. *}
    {assign var=mtCancel value="?module=Hadrian&action=editStyle&style=`$style|escape`&subcat=general"}
    {include file="includes/savebar.tpl" cancel=$mtCancel quiet="Reset all to default" quietId="mt-general-reset" label="Save general"}
</form>
