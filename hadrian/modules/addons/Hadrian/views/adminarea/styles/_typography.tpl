{* Typography settings form. Rendered by StylesController::editAction;
   $typography view-model carries the schema + the current effective value per
   token. POSTs back to action=editStyle (PRG in editAction). The font-family
   controls + their enable/disable are wired by JS in includes/footer.tpl. *}
<form method="post" action="?module=Hadrian&action=editStyle&style={$style|escape}&subcat=typography" class="mt-typography">
    <input type="hidden" name="mt_typography" value="1">
    <input type="hidden" name="style" value="{$style|escape}">

    {if $saved}<div class="mt-alert mt-alert-success">Typography saved.</div>{/if}

    <section class="mt-section">
        <header class="mt-section-header"><h2 class="mt-section-title">Font Family</h2>{include file="includes/doclink.tpl" article="styles" anchor="font-family"}</header>
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
                {* Searchable picker over the whole Google Fonts library. This
                   used to be a <select> of twelve hand-picked names; the catalog
                   (core/config/google-fonts.json, refreshed by
                   scripts/fetch-google-fonts.mjs) now carries every family, which
                   is far past what a native <select> can be used with.

                   The hidden input IS the form field -- everything visible below
                   is a view onto it, the same shape the Settings page's .mt-multi
                   chip picker uses. Same shape, NOT the same classes: .mt-multi-*
                   is declared in a <style> block inside settings/index.tpl and so
                   does not exist on this page. .mt-fontpick-* in admin.css carries
                   every rule this needs.

                   Rows are built by JS in includes/footer.tpl; with JS off the
                   hidden input still round-trips whatever was already saved, so an
                   existing choice is never silently lost. *}
                <div class="mt-fontpick-wrap" data-fontpick data-count="{$typography.googleCount}">
                    <input type="hidden" name="ff_google" value="{$typography.fontFamily.google|escape}" data-fontpick-value>

                    <button type="button" class="mt-fontpick" data-fontpick-field
                            aria-haspopup="listbox" aria-expanded="false">
                        <span class="mt-fontpick-name" data-fontpick-label>&mdash; select a Google font &mdash;</span>
                        <span class="mt-fontpick-meta" data-fontpick-meta></span>
                        <span class="mt-fontpick-caret" aria-hidden="true">
                            <svg viewBox="0 0 16 16" fill="none"><path d="M4 6l4 4 4-4" stroke="currentColor" stroke-width="1.5" stroke-linecap="round"/></svg>
                        </span>
                    </button>

                    <div class="mt-fontpick-panel" hidden data-fontpick-panel role="listbox">
                        <div class="mt-fontpick-head">
                            <input type="search" placeholder="Search {$typography.googleCount} Google fonts&hellip;" autocomplete="off"
                                   aria-label="Search Google fonts" data-fontpick-search>
                            <div class="mt-fontpick-cats" role="group" aria-label="Filter by category">
                                <button type="button" class="mt-fontpick-cat is-active" data-cat="">All</button>
                                <button type="button" class="mt-fontpick-cat" data-cat="sans">Sans</button>
                                <button type="button" class="mt-fontpick-cat" data-cat="serif">Serif</button>
                                <button type="button" class="mt-fontpick-cat" data-cat="display">Display</button>
                                <button type="button" class="mt-fontpick-cat" data-cat="hand">Handwriting</button>
                                <button type="button" class="mt-fontpick-cat" data-cat="mono">Mono</button>
                            </div>
                        </div>
                        <div class="mt-fontpick-options" data-fontpick-options></div>
                        <div class="mt-fontpick-empty" hidden data-fontpick-empty>No fonts match.</div>
                    </div>

                    {* Parsed on first open, not at page load -- type="application/json"
                       means the browser stores it as text and never runs it as script.
                       Embedded rather than fetched because the theme's .htaccess denies
                       .json over HTTP. *}
                    <script type="application/json" data-fontpick-catalog>{$typography.googleCatalog nofilter}</script>
                    <script type="application/json" data-fontpick-popular>{$typography.googlePopular nofilter}</script>
                </div>
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
        <header class="mt-section-header"><h2 class="mt-section-title">Font Size</h2>{include file="includes/doclink.tpl" article="styles" anchor="font-size-and-font-weight"}</header>
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
        <header class="mt-section-header"><h2 class="mt-section-title">Font Weight</h2>{include file="includes/doclink.tpl" article="styles" anchor="font-size-and-font-weight"}</header>
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
