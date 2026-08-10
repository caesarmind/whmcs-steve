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

    {* Seeded generation — the other way to set a palette, sitting beside the
       preset chips rather than replacing them. A preset cascades five brand
       fields from one accent; this rebuilds every row from it, on four recipes:
       brand takes the seed's hue and chroma with each row keeping its own
       distance from the accent, neutrals keep their LIGHTNESS (that is what
       contrast is made of) and take only the hue, status keeps its hue because
       a warning must stay amber and follows saturation alone, and icons and
       blocks rotate as a set. On the shipped accent it is a fixed point —
       brand, status and icons come back byte-identical — which is the check
       that it describes the theme rather than replacing it.

       It writes into the fields below and does nothing else. Saving is still
       the Save colors button, and saveColorsAction's drop-if-equal-to-default
       filter keeps the stored override set minimal without any help from here.
       Every button is type="button": inside a form, a bare <button> submits. *}
    <section class="mt-section mt-gen"
             data-scope="{$colors.mode}"
             data-accent-light="{$colors.accents.light|default:''|escape}"
             data-accent-dark="{$colors.accents.dark|default:''|escape}">
        <header class="mt-section-header"><h2 class="mt-section-title">Generate from one colour</h2></header>
        <p class="mt-field-help mt-gen-lede">
            Pick your brand colour and rebuild the whole palette around it. Lightness is preserved
            wherever contrast depends on it, and status colours keep their own hue &mdash; a warning
            stays amber whatever you pick.
            {if $colors.mode == 'dark'}
                You are editing the <strong>dark</strong> scope, so the accent is derived <em>lighter</em>
                than the colour you pick, far enough to stay legible on a dark card.
            {else}
                This writes the <strong>light</strong> scope only &mdash; switch to Dark above and
                generate again to do the other one.
            {/if}
        </p>

        <div class="mt-gen-rail">
            <div class="mt-gen-ctl">
                <span class="mt-gen-lab">Brand colour</span>
                <span class="mt-color-control">
                    <input type="color" class="mt-color-swatch-input mt-gen-seed-sw" value="#0071e3" aria-label="Brand colour picker">
                    <input type="text" class="mt-input mt-input-compact mt-gen-seed" value="#0071e3" spellcheck="false" aria-label="Brand colour hex">
                </span>
            </div>
            <div class="mt-gen-ctl">
                <span class="mt-gen-lab">What to rebuild</span>
                <div class="mt-gen-chips">
                    <button type="button" class="mt-gen-chip is-on" data-what="brand"   aria-pressed="true">Brand</button>
                    <button type="button" class="mt-gen-chip is-on" data-what="neutral" aria-pressed="true">Neutrals</button>
                    <button type="button" class="mt-gen-chip is-on" data-what="status"  aria-pressed="true">Status</button>
                    <button type="button" class="mt-gen-chip is-on" data-what="rotate"  aria-pressed="true">Icons &amp; blocks</button>
                </div>
            </div>
            <div class="mt-gen-ctl">
                <span class="mt-gen-lab">Neutral tint <b class="mt-gen-tint-out">30%</b></span>
                <input type="range" class="mt-gen-tint" min="0" max="100" step="5" value="30"
                       aria-label="How much of the brand hue the greys carry">
            </div>
            <div class="mt-gen-ctl mt-gen-ctl-act">
                <button type="button" class="mt-btn mt-btn-secondary mt-gen-run">Generate</button>
                <button type="button" class="mt-btn mt-btn-secondary mt-gen-undo" disabled>Undo</button>
            </div>
        </div>

        <div class="mt-gen-report" hidden></div>
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
