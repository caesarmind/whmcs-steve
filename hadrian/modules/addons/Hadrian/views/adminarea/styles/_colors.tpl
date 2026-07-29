{* Colors form (Lagom-style per-token editor). Rendered by
   StylesController::editAction; $colors carries the token schema grouped, each
   row's effective value + per-style default + a hex for the native swatch, plus
   the accent presets and the resolved mode. POSTs back to action=editStyle (PRG
   in editAction) as c[--token]=value. Preset cascade + swatch<->text sync are
   wired by JS in includes/footer.tpl. Mirrors _typography.tpl. *}
<form method="post" action="?module=Hadrian&action=editStyle&style={$style|escape}&subcat=colors&scope={$colors.mode}" class="mt-colors">
    <input type="hidden" name="mt_colors" value="1">
    <input type="hidden" name="style" value="{$style|escape}">
    <input type="hidden" name="scope" value="{$colors.mode}">

    {if $colorsSaved}<div class="mt-alert mt-alert-success">Colors saved.</div>{/if}

    <section class="mt-section">
        <header class="mt-section-header">
            <h2 class="mt-section-title">Color Scheme</h2>
            {* Light/Dark scope toggle — each style carries both color sets.
               Switching reloads the editor for that scope (full nav, like the
               subcat links); unsaved edits in the other scope aren't kept. *}
            <div class="mt-tabs">
                <a class="mt-tab {if $colors.mode != 'dark'}is-active{/if}" href="?module=Hadrian&action=editStyle&style={$style|escape}&subcat=colors&scope=light">Light</a>
                <a class="mt-tab {if $colors.mode == 'dark'}is-active{/if}" href="?module=Hadrian&action=editStyle&style={$style|escape}&subcat=colors&scope=dark">Dark</a>
            </div>
        </header>
        <p class="mt-field-help">Every token below is editable independently. Quick presets just cascade the brand fields (accent, hover, tint, link) &mdash; tweak any value after. Editing the <strong>{$styleName|escape}</strong> style changes its <strong>{$colors.mode}</strong> colors; only changed tokens are saved, and they apply site-wide.</p>
        <div class="mt-schemes">
            {foreach $colors.presets as $p}
                <button type="button" class="mt-scheme" data-accent="{$p.accent|escape}">
                    <span class="mt-scheme-dot" style="background:{$p.accent}"></span>{$p.name|escape}
                </button>
            {/foreach}
        </div>
    </section>

    {foreach $colors.groups as $groupName => $tokens}
    <section class="mt-section">
        <header class="mt-section-header"><h2 class="mt-section-title">{$groupName|escape}</h2></header>
        <div class="mt-color-rows">
            {foreach $tokens as $t}
            <div class="mt-color-row" data-var="{$t.var|escape}">
                <label class="mt-color-row-label" for="c{$t.var|replace:'--':'_'}">
                    {$t.label|escape}
                    {* Optional per-token note from colors.php. Several labels
                       are honestly ambiguous on their own -- "Surface 3" says
                       nothing about the fact that its ordinal INVERTS between
                       light and dark, and six tokens ship values byte-identical
                       to a page token, so a buyer cannot tell them apart by
                       swatch alone. *}
                    {if $t.hint|default:''}<span class="mt-color-row-hint">{$t.hint|escape}</span>{/if}
                </label>
                <span class="mt-color-control">
                    <input type="color" class="mt-color-swatch-input" value="{$t.hex|escape}" data-for="{$t.var|escape}" aria-label="{$t.label|escape} picker">
                    <input type="text" id="c{$t.var|replace:'--':'_'}" name="c[{$t.var}]" data-var="{$t.var|escape}" class="mt-input mt-input-compact mt-color-text" value="{$t.value|escape}" data-default="{$t.default|escape}" spellcheck="false">
                </span>
            </div>
            {/foreach}
        </div>
    </section>
    {/foreach}

    <div class="mt-typo-actions">
        <button type="button" class="mt-btn mt-btn-secondary" id="mt-colors-reset">Reset all to default</button>
        <button type="submit" class="mt-btn mt-btn-primary">Save colors</button>
    </div>
</form>
