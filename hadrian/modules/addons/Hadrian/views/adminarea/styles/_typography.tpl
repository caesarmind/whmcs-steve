{* Typography settings form. Rendered by StylesController::editAction;
   $typography view-model carries the schema + the current effective value per
   token. POSTs back to action=editStyle (PRG in editAction). The font-family
   controls + their enable/disable are wired by JS in includes/footer.tpl. *}
<form method="post" action="?module=Hadrian&action=editStyle&style={$style|escape}&subcat=typography" class="mt-typography">
    <input type="hidden" name="mt_typography" value="1">
    <input type="hidden" name="style" value="{$style|escape}">

    {if $saved}<div class="mt-alert mt-alert-success">Typography saved.</div>{/if}

    <section class="mt-section">
        <header class="mt-section-header"><h2 class="mt-section-title">Font Family</h2></header>
        <div class="mt-typo-fonts" data-ff-fallback="{$typography.ffFallback|escape}" data-ff-apple="{$typography.ffApplePrefix|escape}">
            <label class="mt-typo-radio">
                <input type="radio" name="ff_mode" value="default"{if $typography.fontFamily.mode == 'default'} checked{/if}>
                <span>Default <em>(San Francisco on Apple, bundled Inter on other platforms)</em></span>
            </label>

            <label class="mt-typo-radio">
                <input type="radio" name="ff_mode" value="system"{if $typography.fontFamily.mode == 'system'} checked{/if}>
                <span>System fonts <em>(each visitor's OS font &mdash; Segoe UI on Windows, San Francisco on Mac, system default on Linux; nothing downloads)</em></span>
            </label>
            <div class="mt-typo-dep">
                <div class="mt-typo-sublabel">How it's written into the system</div>
                <input type="text" name="ff_system" class="mt-input" value="{$typography.stacks.system|escape}" placeholder="system-ui, -apple-system, 'Segoe UI', Roboto, sans-serif">
            </div>

            <label class="mt-typo-radio">
                <input type="radio" name="ff_mode" value="google"{if $typography.fontFamily.mode == 'google'} checked{/if}>
                <span>Google Font</span>
            </label>
            <div class="mt-typo-dep">
                <select name="ff_google" class="mt-select">
                    <option value="">&mdash; select a Google font &mdash;</option>
                    {foreach $typography.googleFonts as $gf}
                        <option value="{$gf|escape}"{if $gf == $typography.fontFamily.google} selected{/if}>{$gf|escape}</option>
                    {/foreach}
                </select>
                <div class="mt-typo-sublabel">How it's written into the system</div>
                <input type="text" name="ff_google_stack" class="mt-input" value="{$typography.stacks.google|escape}" placeholder="'Roboto', system-ui, sans-serif">
            </div>

            <label class="mt-typo-radio">
                <input type="radio" name="ff_mode" value="folder"{if $typography.fontFamily.mode == 'folder'} checked{/if}>
                <span>Self-hosted font <em>(type the face name; drop the matching file into /assets/fonts/custom)</em></span>
            </label>
            <div class="mt-typo-dep">
                <input type="text" name="ff_folder" class="mt-input" value="{$typography.fontFamily.folder|escape}" placeholder="Font face name, e.g. BrandSans">
                <label class="mt-typo-check mt-typo-check-inline">
                    <input type="checkbox" name="ff_folder_apple" value="1"{if $typography.fontFamily.folderApple} checked{/if}>
                    <span>Keep the device's system font on Apple <em>(San Francisco on Apple, this font on the rest)</em></span>
                </label>
                <div class="mt-typo-sublabel">How it's written into the system</div>
                <input type="text" name="ff_folder_stack" class="mt-input" value="{$typography.stacks.folder|escape}" placeholder='"BrandSans", system-ui, sans-serif'>
            </div>
        </div>
    </section>

    <section class="mt-section">
        <header class="mt-section-header"><h2 class="mt-section-title">Font Size</h2></header>
        {foreach $typography.sizeGroups as $groupName => $items}
            <div class="mt-typo-group-label">{$groupName|escape}</div>
            <div class="mt-typo-grid">
                {foreach $items as $it}
                    <div class="mt-typo-field">
                        <label class="mt-typo-field-label" for="size_{$it.var|replace:'--':''}">{$it.label|escape}</label>
                        <span class="mt-affix">
                            <input type="number" id="size_{$it.var|replace:'--':''}" name="size_{$it.var|replace:'--':''}" value="{$it.value}" min="{$typography.sizeMin}" max="{$typography.sizeMax}" step="1" class="mt-input mt-input-compact">
                            <span class="mt-affix-unit">px</span>
                        </span>
                    </div>
                {/foreach}
            </div>
        {/foreach}
    </section>

    <section class="mt-section">
        <header class="mt-section-header"><h2 class="mt-section-title">Font Weight</h2></header>
        <div class="mt-typo-grid">
            {foreach $typography.weights as $it}
                <div class="mt-typo-field">
                    <label class="mt-typo-field-label" for="weight_{$it.var|replace:'--':''}">{$it.label|escape}</label>
                    <select id="weight_{$it.var|replace:'--':''}" name="weight_{$it.var|replace:'--':''}" class="mt-select mt-input-compact">
                        {foreach $typography.weightOptions as $opt}
                            <option value="{$opt}"{if $opt == $it.value} selected{/if}>{$opt}</option>
                        {/foreach}
                    </select>
                </div>
            {/foreach}
        </div>
    </section>

    {* The inline action row became the floating save bar that every page with
       a page-level save now carries. Safe here even though all six style panels
       render into one document: the five inactive ones sit inside a [hidden]
       .mt-subcat-panel, and a position:fixed element inside a display:none
       ancestor has a zero rect -- measured, so exactly one bar paints.

       No quiet action here: this panel is the one without a "Reset all to
       default", and the bar draws only what it is given. *}
    {assign var=mtCancel value="?module=Hadrian&action=editStyle&style=`$style|escape`&subcat=typography"}
    {include file="includes/savebar.tpl" cancel=$mtCancel label="Save typography"}
</form>
