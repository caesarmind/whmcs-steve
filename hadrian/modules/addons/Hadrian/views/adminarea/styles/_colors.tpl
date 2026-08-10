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
        </header>
        <p class="mt-field-help">Every token below is editable independently. Quick presets just cascade the brand fields (accent, hover, tint, link) &mdash; tweak any value after. Editing the <strong>{$styleName|escape}</strong> style changes its <strong>{$colors.mode}</strong> colors; only changed tokens are saved, and they apply site-wide.</p>
        <div class="mt-schemes">
            {foreach $colors.presets as $p}
                <button type="button" class="mt-scheme" data-accent="{$p.accent|escape}">
                    <span class="mt-scheme-dot" style="background:{$p.accent}"></span>{$p.name|escape}
                </button>
            {/foreach}
        </div>
        {* Shown only in the Dark scope. Rows that ship the same value in both
           modes are not dark-mode decisions -- asking for them twice is asking
           the same question twice -- so Dark hides them and says how many.
           The escape hatch matters though: "the default is the same" is not
           "you may never differ here", so they can be brought back. *}
        <p class="mt-field-help mt-shared-note" hidden>
            <span class="mt-shared-count"></span> the same in both modes, so they are hidden here.
            <button type="button" class="mt-shared-toggle">Show them</button>
        </p>
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

    {* Light/Dark sits here rather than in the Color Scheme header: it governs
       the rows BELOW it, not the presets and generator above, and reading it
       immediately before the first group is what makes that obvious.

       Both scopes are IN THE PAGE -- the one you are not looking at rides along
       in a hidden field per row -- so switching swaps values client-side with
       no reload, and one Save writes both. It used to be a link that reloaded
       and threw away unsaved edits in the scope you were leaving. *}
    <div class="mt-scope-bar">
        <span class="mt-scope-lab">Editing</span>
        <div class="mt-tabs" data-scope-switch>
            <button type="button" class="mt-tab {if $colors.mode != 'dark'}is-active{/if}" data-scope-set="light">Light</button>
            <button type="button" class="mt-tab {if $colors.mode == 'dark'}is-active{/if}" data-scope-set="dark">Dark</button>
        </div>
    </div>

    {foreach $colors.groups as $groupName => $tokens}
    <section class="mt-section">
        <header class="mt-section-header"><h2 class="mt-section-title">{$groupName|escape}</h2></header>

        {* Sidebar style presets, at the head of the group that owns the sidebar
           rows -- the same relationship the accent chips at the top of the page
           have to the brand rows, and rendered with the same .mt-schemes markup.

           A STYLE IS A SET OF COLOURS. Clicking one fills the rows below with
           that style's values, resolving any var(--color-accent) against the
           Accent you currently have; every row then keeps its own picker and can
           be tweaked. Nothing is stored until Save colors.

           Light carries no tokens of its own because it IS the defaults, so it
           resets those rows rather than writing to them. *}
        {if $groupName == $colors.navGroup && $colors.sbStyles}
        <div class="mt-schemes mt-sbt" data-sbt>
            <span class="mt-sbt-lab">Style</span>
            <button type="button" class="mt-scheme mt-sbt-mode" data-sbt-mode="off">
                <span class="mt-scheme-dot mt-sbt-dot"></span>Light</button>
            {foreach $colors.sbStyles as $sbKey => $sb}
            {* data-sbt-tokens carries the style's whole token set as JSON, and
               data-sbt-css just its background for the chip dot. Both come
               straight from colors.php, so the admin holds no second copy of
               the values and cannot drift from what ships. *}
            <button type="button" class="mt-scheme mt-sbt-mode" data-sbt-mode="{$sbKey|escape}"
                    data-sbt-css="{$sb.dot|escape}" data-sbt-css-other="{$sb.dotOther|escape}"
                    data-sbt-tokens="{$sb.json|escape}" data-sbt-tokens-other="{$sb.jsonOther|escape}"
                    {if $sb.autoInk|default:false}data-sbt-autoink="1"{/if}>
                <span class="mt-scheme-dot mt-sbt-dot"></span>{$sb.label|escape}</button>
            {/foreach}
        </div>
        {/if}

        <div class="mt-color-rows">
            {foreach $tokens as $t}
            {* data-follows names a row this one already tracks IN CSS -- the
               seven sidebar rows are `var(--_sb-*, var(--color-*))`, so they
               fall back to the page ramp. The schema restated the resolved
               literal as their default, which made the admin show a stale
               swatch and, worse, freeze the link the moment the row was
               touched. Declaring it lets the panel mirror the source instead. *}
            <div class="mt-color-row" data-var="{$t.var|escape}"{if $t.shared|default:false} data-shared="1"{/if}{if $t.follows|default:''} data-follows="{$t.follows|escape}"{/if}>
                <label class="mt-color-row-label" for="c{$t.var|replace:'--':'_'}">{$t.label|escape}</label>
                <span class="mt-color-control">
                    <input type="color" class="mt-color-swatch-input" value="{$t.hex|escape}" data-for="{$t.var|escape}" aria-label="{$t.label|escape} picker">
                    <input type="text" id="c{$t.var|replace:'--':'_'}" name="c[{$t.var}]" data-var="{$t.var|escape}" class="mt-input mt-input-compact mt-color-text" value="{$t.value|escape}" data-default="{$t.default|escape}" spellcheck="false" {if $t.hint|default:''}aria-describedby="h{$t.var|replace:'--':'_'}"{/if}>
                    {* The scope you are NOT editing. Carried, posted and saved
                       alongside; the switch just swaps the two values and their
                       defaults, so no reload and nothing unsaved is lost. *}
                    <input type="hidden" name="o[{$t.var}]" class="mt-color-other" data-var="{$t.var|escape}" value="{$t.other|escape}" data-default="{$t.otherDef|escape}">
                </span>
                {* Optional per-token note from colors.php. Several labels are
                   honestly ambiguous on their own -- "Surface 3" says nothing
                   about the fact that its ordinal INVERTS between light and
                   dark, and six tokens ship values byte-identical to a page
                   token, so a buyer cannot tell them apart by swatch alone.

                   A SIBLING of the label, and placed AFTER the control, for two
                   reasons. It can then span the whole row instead of sharing a
                   ~150px column with the control, which is what turned a
                   twelve-word note into six lines. And a screen reader stops
                   reading the paragraph as part of the field's NAME --
                   aria-describedby announces it separately, after the label. *}
                {if $t.hint|default:''}<span class="mt-color-row-hint" id="h{$t.var|replace:'--':'_'}">{$t.hint|escape}</span>{/if}
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
