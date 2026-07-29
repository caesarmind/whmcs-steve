{* General form -- the SCALE LAYER the other panels select between: corner
   radius, shadow, control sizing and motion. Rendered by
   StylesController::editAction; $general.groups carries each field with its
   effective value + default, $general.shadowOptions the authored shadow stacks.

   Elements/Buttons/Forms let a buyer pick "Card radius = Large"; this panel is
   where Large gets its number. Site-wide -> global mt_general form. Mirrors
   _layout.tpl for the px fields and _elements.tpl for the dropdowns. *}
<form method="post" action="?module=Hadrian&action=editStyle&style={$style|escape}&subcat=general" class="mt-general">
    <input type="hidden" name="mt_general" value="1">
    <input type="hidden" name="style" value="{$style|escape}">

    {if $generalSaved}<div class="mt-alert mt-alert-success">General saved.</div>{/if}

    <section class="mt-section">
        <header class="mt-section-header">
            <h2 class="mt-section-title">General</h2>
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
        {/foreach}
    </section>

    <div class="mt-typo-actions">
        <button type="button" class="mt-btn mt-btn-secondary" id="mt-general-reset">Reset all to default</button>
        <button type="submit" class="mt-btn mt-btn-primary">Save general</button>
    </div>
</form>
