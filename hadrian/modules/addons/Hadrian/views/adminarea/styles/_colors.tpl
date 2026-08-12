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
    {if $presetRestored}<div class="mt-alert mt-alert-success">{$styleName|escape} restored to its preset colours.</div>{/if}

    <section class="mt-section">
        <header class="mt-section-header mt-cs-head">
            <h2 class="mt-section-title">Color scheme</h2>
            {* Editing scope, top-right of the header per the design. Both scopes
               are IN THE PAGE -- the one you are not looking at rides along in a
               hidden field per row -- so switching swaps values client-side with
               no reload, and one Save writes both. It used to be a link that
               reloaded and threw away unsaved edits in the scope you were
               leaving. *}
            <div class="mt-cs-editing">
                <span class="mt-cs-editing-lab">Editing</span>
                <div class="mt-tabs" data-scope-switch>
                    <button type="button" class="mt-tab {if $colors.mode != 'dark'}is-active{/if}" data-scope-set="light">Light</button>
                    <button type="button" class="mt-tab {if $colors.mode == 'dark'}is-active{/if}" data-scope-set="dark">Dark</button>
                </div>
            </div>
        </header>
        <p class="mt-field-help">Every token below is editable independently. Quick presets just cascade the brand fields (accent, hover, tint, link) &mdash; tweak any value after. Only changed tokens are saved, and they apply site-wide.</p>
        <div class="mt-schemes">
            {foreach $colors.presets as $p}
                <button type="button" class="mt-scheme" data-accent="{$p.accent|escape}">
                    <span class="mt-scheme-dot" style="background:{$p.accent}"></span>{$p.name|escape}
                </button>
            {/foreach}
        </div>
        {* Seeding is once-only by design, so a style keeps whatever palette it
           had when you FIRST activated it -- your later edits are never stamped
           over. The cost is that an updated preset can otherwise never reach a
           style you already activated. This is the way back, and it is a real
           delete of the stored rows rather than a form reset: "Restore defaults"
           in the save bar sets the fields to stock Hadrian, this sets them to
           the palette THIS preset ships. *}
        <p class="mt-field-help">
            Edited this style, or want the palette it shipped with?
            <button type="submit" name="mt_colors_preset_reset" value="1" class="mt-btn mt-btn-ghost"
                    onclick="return confirm('Discard your saved colours for {$styleName|escape:'javascript'} and restore the palette this preset ships with?');">
                Reset to the {$styleName|escape} preset
            </button>
        </p>
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
            <div class="mt-gen-ctl mt-gen-ctl-seed">
                <span class="mt-gen-lab">Brand colour</span>
                <span class="mt-color-control">
                    <input type="color" class="mt-color-swatch-input mt-gen-seed-sw" value="#0071e3" aria-label="Brand colour picker">
                    <input type="text" class="mt-input mt-input-compact mt-gen-seed" value="#0071e3" spellcheck="false" aria-label="Brand colour hex">
                </span>
            </div>
            <div class="mt-gen-ctl mt-gen-ctl-what">
                <span class="mt-gen-lab">What to rebuild</span>
                <div class="mt-gen-chips">
                    <button type="button" class="mt-gen-chip is-on" data-what="brand"   aria-pressed="true">Brand</button>
                    <button type="button" class="mt-gen-chip is-on" data-what="neutral" aria-pressed="true">Neutrals</button>
                    <button type="button" class="mt-gen-chip is-on" data-what="status"  aria-pressed="true">Status</button>
                    <button type="button" class="mt-gen-chip is-on" data-what="rotate"  aria-pressed="true">Icons &amp; blocks</button>
                </div>
            </div>
            <div class="mt-gen-ctl mt-gen-ctl-tint">
                <span class="mt-gen-lab">Neutral tint &middot; <b class="mt-gen-tint-out">30%</b></span>
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
    <section class="mt-section mt-cs-group">
        <div class="mt-cs-group-head">
            <span class="mt-cs-group-lbl">{$groupName|escape}</span>
        </div>

        {* Sidebar style presets, at the head of the group that owns the sidebar
           rows -- the same relationship the accent chips at the top of the page
           have to the brand rows, and rendered with the same .mt-schemes markup.

           A STYLE IS A SET OF COLOURS. Clicking one fills the rows below with
           that style's values, resolving any var(--color-accent) against the
           Accent you currently have; every row then keeps its own picker and can
           be tweaked. Nothing is stored until Save colors.

           Light carries no tokens of its own because it IS the defaults, so it
           resets those rows rather than writing to them. *}

        <div class="mt-color-rows mt-cs-card">
        {if $groupName == $colors.navGroup && $colors.sbStyles}
        <div class="mt-schemes mt-sbt" data-sbt>
            <span class="mt-sbt-lab">Style</span>
            <button type="button" class="mt-scheme mt-sbt-mode is-active" data-sbt-mode="off">
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
            {foreach $tokens as $t}
            {* data-follows names a row this one already tracks IN CSS -- the
               seven sidebar rows are `var(--_sb-*, var(--color-*))`, so they
               fall back to the page ramp. The schema restated the resolved
               literal as their default, which made the admin show a stale
               swatch and, worse, freeze the link the moment the row was
               touched. Declaring it lets the panel mirror the source instead. *}
            <div class="mt-color-row" data-var="{$t.var|escape}"{if $t.shared|default:false} data-shared="1"{/if}{if $t.follows|default:''} data-follows="{$t.follows|escape}"{/if}>
                {* The note is a TOOLTIP now, not a line of prose under the row.
                   It lives on a focusable button so it is reachable by keyboard
                   and announced -- a title on a bare span is neither. The text
                   is still colors.php's `hint`, so nothing was rewritten to fit
                   a smaller space; it simply stopped occupying one. *}
                <label class="mt-color-row-label" for="c{$t.var|replace:'--':'_'}">{$t.label|escape}{if $t.hint|default:''}<button type="button" class="mt-info" tabindex="0" aria-label="About {$t.label|escape}" title="{$t.hint|escape}">i</button>{/if}</label>
                {* The swatch is a PAINTED LABEL with the native picker hidden
                   inside it at opacity 0, as the demo draws it. A bare
                   input[type=color] can only ever show an opaque hex, so the
                   five rgba rows in the nav group rendered their translucency
                   as solid colour -- "Item hover rgba(0,0,0,0.04)" painted pure
                   black. Painting the label with the raw token value shows what
                   the value actually is.

                   An EMPTY value gets the demo's red diagonal slash rather than
                   a black chip: --sidebar-color's whole contract is that empty
                   means off, and toHexInput() turning '' into #000000 made the
                   one row that means "nothing" read as "black is set". *}
                <span class="mt-color-control">
                    <label class="mt-color-swatch{if $t.value == ''} is-empty{/if}" title="Open colour picker"{if $t.value != ''} style="background:{$t.value|escape}"{/if}>
                        <input type="color" class="mt-color-swatch-input" value="{$t.hex|escape}" data-for="{$t.var|escape}" aria-label="{$t.label|escape} picker">
                    </label>
                    {* No aria-describedby: the note it pointed at no longer
                       exists as an element. The tooltip button beside the label
                       carries the text now, and a describedby aimed at a
                       missing id announces nothing while looking correct. *}
                    <input type="text" id="c{$t.var|replace:'--':'_'}" name="c[{$t.var}]" data-var="{$t.var|escape}" class="mt-input mt-color-text" value="{$t.value|escape}" data-default="{$t.default|escape}" spellcheck="false"{if $t.value == ''} placeholder="inherit"{/if}>
                    {* The scope you are NOT editing. Carried, posted and saved
                       alongside; the switch just swaps the two values and their
                       defaults, so no reload and nothing unsaved is lost. *}
                    <input type="hidden" name="o[{$t.var}]" class="mt-color-other" data-var="{$t.var|escape}" value="{$t.other|escape}" data-default="{$t.otherDef|escape}">
                </span>
            </div>
            {/foreach}
        </div>
    </section>
    {/foreach}

    {* Floating save bar, ported from the demo. The markup moved to
       includes/savebar.tpl when it went out to every page with a save; this was
       the copy it was lifted from, so it reads through the partial like the
       rest rather than keeping a private twin that can drift.

       Restore sits far left because margin-right:auto puts distance between the
       destructive action and the confirming one; Cancel reloads, which is the
       honest way to discard when every edit so far lives only in the form. *}
    {assign var=mtCancel value="?module=Hadrian&action=editStyle&style=`$style|escape`&subcat=colors&scope=`$colors.mode`"}
    {include file="includes/savebar.tpl"
             quiet="Restore defaults" quietId="mt-colors-reset"
             cancel=$mtCancel label="Save changes"}
</form>
