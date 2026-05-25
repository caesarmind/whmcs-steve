{* Typography settings form. Rendered by StylesController::editAction when
   subcat=typography; $typography view-model carries the schema + the current
   effective value per token. POSTs back to action=editStyle (PRG in editAction).
   Inherits $style / $saved from the parent edit.tpl. *}
<form method="post" action="?module=MyTheme&action=editStyle&style={$style|escape}&subcat=typography" class="mt-typography">
    <input type="hidden" name="mt_typography" value="1">
    <input type="hidden" name="style" value="{$style|escape}">

    {if $saved}<div class="mt-notice mt-notice-success">Typography saved.</div>{/if}

    <section class="mt-section">
        <header class="mt-section-header"><h2 class="mt-section-title">Font Family</h2></header>
        <div class="mt-field-stack">
            <label class="mt-radio">
                <input type="radio" name="ff_mode" value="default"{if $typography.fontFamily.mode == 'default'} checked{/if}>
                <span>System default <em>(San Francisco / Segoe / Roboto)</em></span>
            </label>
            <label class="mt-radio">
                <input type="radio" name="ff_mode" value="google"{if $typography.fontFamily.mode == 'google'} checked{/if}>
                <span>Google Font</span>
            </label>
            <select name="ff_google" class="mt-input">
                <option value="">&mdash; select a Google font &mdash;</option>
                {foreach $typography.googleFonts as $gf}
                    <option value="{$gf|escape}"{if $gf == $typography.fontFamily.google} selected{/if}>{$gf|escape}</option>
                {/foreach}
            </select>
            <label class="mt-radio">
                <input type="radio" name="ff_mode" value="custom"{if $typography.fontFamily.mode == 'custom'} checked{/if}>
                <span>Custom font stack</span>
            </label>
            <input type="text" name="ff_custom" class="mt-input" placeholder="'My Font', Helvetica, Arial, sans-serif" value="{$typography.fontFamily.custom|escape}">
        </div>
    </section>

    <section class="mt-section">
        <header class="mt-section-header"><h2 class="mt-section-title">Font Size</h2></header>
        {foreach $typography.sizeGroups as $groupName => $items}
            <h3 class="mt-color-group-title">{$groupName|escape}</h3>
            <div class="mt-field-grid">
                {foreach $items as $it}
                    <label class="mt-field">
                        <span class="mt-field-label">{$it.label|escape}</span>
                        <span class="mt-input-unit">
                            <input type="number" name="size_{$it.var|replace:'--':''}" value="{$it.value}" min="{$typography.sizeMin}" max="{$typography.sizeMax}" step="1" class="mt-input mt-input-num">
                            <em>px</em>
                        </span>
                    </label>
                {/foreach}
            </div>
        {/foreach}
    </section>

    <section class="mt-section">
        <header class="mt-section-header"><h2 class="mt-section-title">Font Weight</h2></header>
        <div class="mt-field-grid">
            {foreach $typography.weights as $it}
                <label class="mt-field">
                    <span class="mt-field-label">{$it.label|escape}</span>
                    <select name="weight_{$it.var|replace:'--':''}" class="mt-input">
                        {foreach $typography.weightOptions as $opt}
                            <option value="{$opt}"{if $opt == $it.value} selected{/if}>{$opt}</option>
                        {/foreach}
                    </select>
                </label>
            {/foreach}
        </div>
    </section>

    <div class="mt-toolbar">
        <button type="submit" class="mt-btn mt-btn-primary">Save typography</button>
    </div>
</form>
