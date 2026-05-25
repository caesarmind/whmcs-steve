{* Color Scheme form. Rendered by StylesController::editAction; $colors carries
   the preset list + the current effective accent + the active scheme name. POSTs
   back to action=editStyle (PRG in editAction). The preset chips, the hex/native
   pickers, and the live preview are wired by JS in includes/footer.tpl. Mirrors
   _typography.tpl. *}
<form method="post" action="?module=MyTheme&action=editStyle&style={$style|escape}&subcat=colors" class="mt-colors">
    <input type="hidden" name="mt_colors" value="1">
    <input type="hidden" name="style" value="{$style|escape}">

    {if $colorsSaved}<div class="mt-alert mt-alert-success">Color scheme saved.</div>{/if}

    <section class="mt-section">
        <header class="mt-section-header"><h2 class="mt-section-title">Color Scheme</h2></header>
        <p class="mt-field-help">Pick a preset or choose a custom accent. The accent drives buttons, links, focus rings, active states and highlights across the client area &mdash; in both light and dark mode. Applied site-wide after you save.</p>
        <div class="mt-schemes">
            {foreach $colors.presets as $p}
                <button type="button" class="mt-scheme{if $p.active} is-active{/if}" data-scheme="{$p.name|escape}" data-accent="{$p.accent|escape}">
                    <span class="mt-scheme-dot" style="background:{$p.accent}"></span>{$p.name|escape}
                </button>
            {/foreach}
            <button type="button" class="mt-scheme mt-scheme-custom{if $colors.activeScheme == 'custom'} is-active{/if}" data-scheme="custom">
                <span class="mt-scheme-dot" data-custom-dot style="background:{$colors.accent|escape}"></span>Custom
            </button>
        </div>
    </section>

    <section class="mt-section">
        <header class="mt-section-header"><h2 class="mt-section-title">Accent Color</h2></header>
        <div class="mt-color-picker-row">
            <input type="color" name="accent" id="mt-accent" class="mt-color-input" value="{$colors.accent|escape}">
            <input type="text" id="mt-accent-hex" class="mt-input mt-input-compact mt-color-hex-input" value="{$colors.accent|escape}" spellcheck="false" maxlength="7" aria-label="Accent hex value">
            <button type="button" class="mt-btn mt-btn-secondary mt-btn-sm" id="mt-accent-reset" data-default="{$colors.defaultAccent|escape}">Reset to default</button>
        </div>

        <div class="mt-color-group">
            <h3 class="mt-color-group-title">Live preview</h3>
            <div class="mt-preview-strip">
                <span class="mt-preview-chip"><span class="mt-preview-sw" data-sw="accent"></span>Main</span>
                <span class="mt-preview-chip"><span class="mt-preview-sw" data-sw="hover"></span>Hover</span>
                <span class="mt-preview-chip"><span class="mt-preview-sw" data-sw="light"></span>Tint</span>
            </div>
            <div class="mt-preview-demo">
                <button type="button" class="mt-preview-btn" data-prev-btn>Primary button</button>
                <a href="#" class="mt-preview-link" data-prev-link onclick="return false;">A sample link</a>
            </div>
            <p class="mt-field-help">Approximate &mdash; hover/tint/dark variants are derived from the accent when you save.</p>
        </div>
    </section>

    <div class="mt-typo-actions">
        <button type="submit" class="mt-btn mt-btn-primary">Save color scheme</button>
    </div>
</form>
