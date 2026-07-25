{include file="includes/header.tpl"}

<div class="mt-toolbar">
    <a class="mt-back" href="?module=Hadrian&action=pages#tab={$pageGroup|escape:'url'}">
        <svg viewBox="0 0 16 16" fill="none"><path d="M10 13L5 8l5-5" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round"/></svg>
        Back to Pages
    </a>
    <button form="page-edit-form" class="mt-btn mt-btn-primary mt-btn-sm">Save changes</button>
</div>

<header class="mt-page-header">
    <div class="mt-page-eyebrow">{$pageGroup|escape}</div>
    <h1 class="mt-page-title">{$pageLabel|escape}</h1>
    {if $pageDescription}
        <p class="mt-page-subtitle">{$pageDescription|escape}</p>
    {/if}
</header>

{* Same icon-chip alert as the Pages list, so a save reads identically whether
   you land back on the list or stay on the editor. *}
{if $flashMsg == 'saved'}
    <div class="mt-alert mt-alert-success mt-alert-lead">
        <span class="mt-alert-icon" aria-hidden="true"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"><path d="M5 12l5 5L20 7"/></svg></span>
        <span>Page settings saved.</span>
    </div>
{/if}

{literal}
<style>
/* Two-column page editor: wide main column + fixed 300px rail.
   align-items:start so the two columns size independently -- otherwise the
   shorter one stretches and its last card grows a dead white tail. */
.mt-pd-grid { display: grid; grid-template-columns: 1fr 300px; gap: 20px; align-items: start; }
/* min-width:0 on the main column: a grid item's default min-width:auto refuses
   to shrink below its content, so a long option label would push the rail off. */
.mt-pd-main, .mt-pd-side { display: flex; flex-direction: column; gap: 20px; min-width: 0; }
/* The flex gap owns the spacing now; .mt-panel's own margin would double it. */
.mt-pd-main > .mt-panel, .mt-pd-side > .mt-panel { margin-bottom: 0; }
/* Below ~1000px the rail has nowhere to go -- stack it under the main column
   rather than crushing both. */
@media (max-width: 1000px) { .mt-pd-grid { grid-template-columns: 1fr; } }

/* Variant cards: name + state badge on one row, description beneath, so the
   description gets the full card width instead of competing with the badge. */
.mt-pd-variants { grid-template-columns: repeat(2, 1fr); }
.mt-pd-variants .mt-variant { display: block; padding: 14px; border-radius: 10px; }
.mt-pd-variants .mt-variant.is-active { background: var(--mt-primary-tint); box-shadow: none; }
.mt-variant-top { display: flex; align-items: center; justify-content: space-between; gap: 8px; }
.mt-pd-variants .mt-variant-name { font-size: 14px; font-weight: 600; }
.mt-variant-desc { font-size: 12px; color: var(--mt-text-3); margin-top: 4px; line-height: 1.4; }
/* 100 of the theme's 102 pages ship exactly one variant (only homepage and
   login have more), so the common case is a single card. Let it span the row
   instead of sitting in the left half beside a hole. */
.mt-pd-variants .mt-variant:only-child { grid-column: 1 / -1; }
@media (max-width: 620px) { .mt-pd-variants { grid-template-columns: 1fr; } }

/* Rule between the variant picker and its settings, inside the same card. */
.mt-pd-div { border-top: 1px solid var(--mt-border); margin: 20px 0 16px; }
.mt-pd-none { font-size: 13px; color: var(--mt-text-3); padding: 4px 0; }

/* A .mt-row's bottom border is a separator; on the final row of a card it is a
   stray line above the padding. */
.mt-pd-rows .mt-row:last-child { border-bottom: none; padding-bottom: 0; }
/* .mt-field carries margin-bottom:16px for stacking; on the final control it
   just adds to the card's own 28px padding and the card reads bottom-heavy. */
.mt-pd-rows .mt-field:last-child { margin-bottom: 0; }
/* Keep the control column narrow enough that label and control stay on one
   line, but wide enough for the longest option label ("Inherit (global
   default)"). */
.mt-pd-rows .mt-select { max-width: 220px; }

/* Rail: stacked full-width fields, not label-left/control-right -- 300px is too
   narrow to split. */
.mt-pd-side .mt-field { margin-bottom: 14px; }
.mt-pd-side .mt-field:last-child { margin-bottom: 0; }
.mt-pd-side .mt-select, .mt-pd-side .mt-input, .mt-pd-side .mt-textarea { width: 100%; max-width: none; }
/* -- Per-language SEO ------------------------------------------------------
   Two display modes over ONE set of inputs:
     .is-single  (rail)  -> only [data-active] is visible
     .is-table   (modal) -> every language as a row
   Nothing is added or removed from the DOM in either mode, so the form always
   posts all 26 title/description pairs. */
.mt-pd-langbar { display: flex; align-items: center; gap: 8px; margin: 16px 0 6px; padding-top: 14px; border-top: 1px solid var(--mt-border); }
.mt-pd-langbar .mt-field-label { margin: 0; }
.mt-pd-langcount { margin-left: auto; font-size: 11.5px; font-weight: 600; color: var(--mt-success-text); }
.mt-pd-bulk-btn { display: flex; align-items: center; justify-content: center; gap: 6px; width: 100%; padding: 7px 0; margin-bottom: 14px; border: 1px solid var(--mt-border); border-radius: 8px; background: var(--mt-surface); color: var(--mt-primary); font: inherit; font-size: 12.5px; font-weight: 600; cursor: pointer; transition: background .15s ease, border-color .15s ease; }
.mt-pd-bulk-btn:hover { background: var(--mt-primary-tint); border-color: var(--mt-primary); }
.mt-pd-bulk-btn:focus-visible { outline: 2px solid var(--mt-primary); outline-offset: 2px; }
.mt-pd-bulk-btn svg { width: 13px; height: 13px; display: block; flex-shrink: 0; }

/* The language name is redundant in the rail -- the picker already says which
   one you are editing, and on a single-language install there IS no picker
   because the whole block is skipped. Only the table needs a label column. */
.mt-seo-lang-head { display: none; }

/* Rail mode: one language at a time. */
.mt-seo-langs.is-single .mt-seo-lang { display: none; }
.mt-seo-langs.is-single .mt-seo-lang[data-active] { display: block; }

/* Table mode: language column + title + description, per the reference. */
.mt-seo-langs.is-table .mt-seo-lang { display: grid; grid-template-columns: 170px 1fr 1fr; gap: 12px; align-items: start; padding: 10px 0; border-top: 1px solid var(--mt-border); }
.mt-seo-langs.is-table .mt-seo-lang-head { display: flex; align-items: center; gap: 8px; padding-top: 26px; }
.mt-seo-langs.is-table .mt-field { margin-bottom: 0; }
.mt-seo-lang-name { font-size: 13px; font-weight: 600; color: var(--mt-text); }
.mt-seo-lang-code { font-family: ui-monospace, "SF Mono", Menlo, Consolas, monospace; font-size: 10.5px; color: var(--mt-text-4); text-transform: uppercase; }
.mt-seo-dot { width: 7px; height: 7px; border-radius: 50%; background: var(--mt-text-4); flex-shrink: 0; }
.mt-seo-lang.is-filled .mt-seo-dot { background: var(--mt-success); }
.mt-seo-lang[hidden] { display: none !important; }
@media (max-width: 760px) { .mt-seo-langs.is-table .mt-seo-lang { grid-template-columns: 1fr; } .mt-seo-langs.is-table .mt-seo-lang-head { padding-top: 0; } }

/* -- Modal ---------------------------------------------------------------- */
/* z-index band, measured against the live admin rather than guessed:
     1050  WHMCS's own Bootstrap modals (.whmcs-modal, .modal-my-notes)
     2000  this modal -- must clear them
     9999  .mt-selpop, 10000 .mt-tip-pop (admin.css)
   Deliberately BELOW our own popups: a <select> opened inside this modal has
   to paint on top of it. The reference's 200 would have put us under WHMCS. */
.mt-modal { position: fixed; inset: 0; z-index: 2000; background: rgba(0,0,0,0.45); display: flex; align-items: center; justify-content: center; padding: 28px; }
.mt-modal[hidden] { display: none; }
.mt-modal-card { width: min(1040px, 96vw); max-height: 90vh; background: var(--mt-surface); border: 1px solid var(--mt-border); border-radius: 18px; box-shadow: 0 30px 80px rgba(0,0,0,0.4); display: flex; flex-direction: column; overflow: hidden; }
.mt-modal-head { display: flex; align-items: center; justify-content: space-between; gap: 16px; padding: 16px 20px; border-bottom: 1px solid var(--mt-border); }
.mt-modal-title { font-size: 16px; font-weight: 600; color: var(--mt-text); }
.mt-modal-sub { font-size: 12.5px; color: var(--mt-text-3); margin-top: 2px; }
.mt-modal-x { width: 32px; height: 32px; border-radius: 50%; border: 1px solid var(--mt-border); background: var(--mt-surface); color: var(--mt-text-2); font-size: 18px; line-height: 1; cursor: pointer; flex-shrink: 0; }
.mt-modal-x:hover { background: var(--mt-surface-2); }
.mt-modal-tools { display: flex; align-items: center; gap: 10px; padding: 12px 20px; border-bottom: 1px solid var(--mt-border); background: var(--mt-surface-2); flex-wrap: wrap; }
.mt-modal-tools .mt-input { width: 200px; }
.mt-modal-tools-gap { flex: 1; }
.mt-modal-check { display: inline-flex; align-items: center; gap: 7px; font-size: 12.5px; color: var(--mt-text-2); cursor: pointer; }
.mt-modal-check input { accent-color: var(--mt-primary); width: 15px; height: 15px; }
.mt-modal-body { overflow: auto; padding: 4px 20px 12px; }
.mt-modal-foot { display: flex; justify-content: flex-end; gap: 10px; padding: 14px 20px; border-top: 1px solid var(--mt-border); }
.mt-modal-empty { font-size: 13px; color: var(--mt-text-3); padding: 18px 0; }
</style>
{/literal}

<form id="page-edit-form" method="post" action="?module=Hadrian&action=pages&sub=save">
    <input type="hidden" name="page" value="{$page|escape}">

    <div class="mt-pd-grid">

    {* ── Main column ──────────────────────────────────────────────── *}
    <div class="mt-pd-main">

        {* Template variant + the options that belong to it, in ONE card: the
           options ARE the settings for the chosen template, so splitting them
           into two cards made them read as unrelated. *}
        <div class="mt-panel pad">
            <div class="mt-subhead">Page template</div>
            {if $variants|count}
                <div class="mt-variant-grid mt-pd-variants" data-saved-variant="{$activeVariant|escape}">
                    {foreach $variants as $v}
                        <label class="mt-variant {if $v.name == $activeVariant}is-active{/if}">
                            <input type="radio" name="variant" value="{$v.name|escape}" {if $v.name == $activeVariant}checked{/if} hidden>
                            <div class="mt-variant-top">
                                <span class="mt-variant-name">{$v.label|escape}</span>
                                {if $v.name == $activeVariant}
                                    <span class="mt-badge mt-badge-success">Active</span>
                                {else}
                                    <span class="mt-badge mt-badge-neutral">Activate</span>
                                {/if}
                            </div>
                            {if $v.description}
                                <div class="mt-variant-desc">{$v.description|escape}</div>
                            {/if}
                        </label>
                    {/foreach}
                </div>
            {else}
                <div class="mt-pd-none">No variants found under <code>core/pages/{$page|escape}/</code>.</div>
            {/if}

            <div class="mt-pd-div"></div>
            <div class="mt-subhead">Template settings</div>
            {if $hasOptions}
                <div class="mt-pd-rows">
                {foreach $optionRows as $opt}
                    {* 'checkbox' is the type every pageoption.php in the theme
                       actually declares; only 'bool' was handled here, so 48
                       toggles across the page editor rendered as text inputs an
                       admin could not meaningfully switch off. *}
                    {if $opt.type == 'bool' || $opt.type == 'checkbox'}
                        <div class="mt-row">
                            <div>
                                <div class="mt-row-label">{$opt.label|escape}</div>
                                {if $opt.help}<div class="mt-row-help">{$opt.help|escape}</div>{/if}
                            </div>
                            <label class="mt-toggle">
                                <input type="hidden" name="option[{$opt.key|escape}]" value="0">
                                <input type="checkbox" name="option[{$opt.key|escape}]" value="1" {if $opt.value}checked{/if}>
                                <span class="mt-toggle-track"><span class="mt-toggle-thumb"></span></span>
                            </label>
                        </div>
                    {elseif $opt.type == 'select' && $opt.options}
                        <div class="mt-row">
                            <div>
                                <div class="mt-row-label">{$opt.label|escape}</div>
                                {if $opt.help}<div class="mt-row-help">{$opt.help|escape}</div>{/if}
                            </div>
                            <select id="opt-{$opt.key|escape}" class="mt-select" name="option[{$opt.key|escape}]">
                                {foreach $opt.options as $mtChoice}
                                    <option value="{$mtChoice|escape}"{if (string)$opt.value == (string)$mtChoice} selected{/if}>{$mtChoice|escape}</option>
                                {/foreach}
                            </select>
                        </div>
                    {else}
                        {* Free text needs the full width, so it stays a stacked
                           field rather than a label-left row. *}
                        <div class="mt-field">
                            <label class="mt-field-label" for="opt-{$opt.key|escape}">{$opt.label|escape}</label>
                            {if $opt.help}<div class="mt-row-help">{$opt.help|escape}</div>{/if}
                            <input id="opt-{$opt.key|escape}" class="mt-input" type="text"
                                   name="option[{$opt.key|escape}]" value="{$opt.value|escape}">
                        </div>
                    {/if}
                {/foreach}
                </div>
            {else}
                <div class="mt-pd-none">There are no settings for the current option.</div>
            {/if}
        </div>

        {* Everything that governs the page itself rather than its template:
           who reaches it, and what chrome it renders. *}
        <div class="mt-panel pad">
            <div class="mt-subhead">Page settings</div>
            <div class="mt-pd-rows">
                <div class="mt-row">
                    <div>
                        <div class="mt-row-label">Visibility</div>
                        <div class="mt-row-help">Disabled pages return 404. Auth-only pages redirect logged-out visitors to login.</div>
                    </div>
                    <select class="mt-select" name="visibility">
                        <option value="public"   {if $visibility == 'public'}selected{/if}>Public</option>
                        <option value="auth"     {if $visibility == 'auth'}selected{/if}>Authenticated only</option>
                        <option value="disabled" {if $visibility == 'disabled'}selected{/if}>Disabled (404)</option>
                    </select>
                </div>

                <div class="mt-row">
                    <div>
                        <div class="mt-row-label">Section sub-nav</div>
                        <div class="mt-row-help">Show or hide this page's sidebar sub-nav. <strong>Inherit</strong> follows the global toggle (Settings &rarr; Order / Website Section Sidebar).</div>
                    </div>
                    <select class="mt-select" name="subnav">
                        <option value="inherit" {if $subnav == 'inherit'}selected{/if}>Inherit (global default)</option>
                        <option value="on"      {if $subnav == 'on'}selected{/if}>On (always show)</option>
                        <option value="off"     {if $subnav == 'off'}selected{/if}>Off (always hide)</option>
                    </select>
                </div>

                {if $svcLayoutApplicable}
                    <div class="mt-row">
                        <div>
                            <div class="mt-row-label">Controls placement</div>
                            <div class="mt-row-help">Where this page's search &amp; pagination controls sit. <strong>Inside</strong> keeps them in the white card; <strong>Outside</strong> floats them on the page. <strong>Inherit</strong> follows the global toggle (Settings &rarr; Service List Controls).</div>
                        </div>
                        <select class="mt-select" name="svclayout">
                            <option value="inherit" {if $svclayout == 'inherit'}selected{/if}>Inherit (global default)</option>
                            <option value="inside"  {if $svclayout == 'inside'}selected{/if}>Inside the card</option>
                            <option value="outside" {if $svclayout == 'outside'}selected{/if}>Outside the card</option>
                        </select>
                    </div>
                {/if}
            </div>
        </div>
    </div>

    {* ── Rail ─────────────────────────────────────────────────────── *}
    <div class="mt-pd-side">

        <div class="mt-panel pad">
            <div class="mt-subhead">SEO</div>

            <div class="mt-field">
                <label class="mt-field-label" for="seo-indexing">Indexing</label>
                <select id="seo-indexing" class="mt-select" name="indexing">
                    <option value="inherit"  {if $indexing == 'inherit'}selected{/if}>Inherit from site default</option>
                    <option value="allow"    {if $indexing == 'allow'}selected{/if}>Allow indexing</option>
                    <option value="disallow" {if $indexing == 'disallow'}selected{/if}>Disallow indexing</option>
                </select>
            </div>

            <div class="mt-field">
                <label class="mt-field-label" for="seo-url">Public URL</label>
                <input id="seo-url" class="mt-input" type="text" name="url" maxlength="255" value="{$seoUrl|escape}" placeholder="page.php">
                <div class="mt-row-help">Path relative to your site root, used in the sitemap. Leave blank to keep this page out of the sitemap.</div>
            </div>

            {* Per-language SEO. This install runs 26 languages, which as a flat
               stack made the SEO panel 6,814px tall on its own -- so the pairs
               all render, but only the picked language is VISIBLE (one <select>
               below), exactly as the reference does it.

               Every pair stays in the DOM and inside this <form> at all times,
               including while the bulk modal is open, so all 26 title +
               description values post on Save regardless of what is on screen.
               Nothing here is conditional on the picker.

               Stored + submitted as seo_title[<lang>] / seo_description[<lang>]. *}
            {assign var=titleMap value=$seo.title}
            {assign var=descMap value=$seo.description}

            {if $seoLanguages|count > 1}
                <div class="mt-pd-langbar">
                    <label class="mt-field-label" for="seo-lang-pick">Language</label>
                    <span class="mt-pd-langcount" id="seo-lang-count"></span>
                </div>
                <div class="mt-field">
                    <select id="seo-lang-pick" class="mt-select">
                        {foreach $seoLanguages as $lng}
                            <option value="{$lng.name|escape}">{$lng.label|escape}</option>
                        {/foreach}
                    </select>
                </div>
                <button type="button" class="mt-pd-bulk-btn" id="seo-bulk-open">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><rect x="3" y="3" width="18" height="18" rx="2"/><path d="M3 9h18M9 9v12"/></svg>
                    Edit all languages
                </button>
            {/if}

            <div id="seo-langs" class="mt-seo-langs{if $seoLanguages|count > 1} is-single{/if}">
                {foreach $seoLanguages as $lng}
                    {assign var=lcode value=$lng.name}
                    <div class="mt-seo-lang" data-lang="{$lcode|escape}" data-label="{$lng.label|escape}">
                        {* Shown only in the bulk table; the rail already names the
                           language in its picker. *}
                        <div class="mt-seo-lang-head">
                            <span class="mt-seo-dot" aria-hidden="true"></span>
                            <span class="mt-seo-lang-name">{$lng.label|escape}</span>
                            <span class="mt-seo-lang-code">{$lcode|escape}</span>
                        </div>
                        <div class="mt-field mt-seo-title">
                            <div class="mt-field-row">
                                <label class="mt-field-label" for="seo-title-{$lcode|escape}">SEO title</label>
                                <div class="mt-field-tools">
                                    <span class="mt-charcount">{$titleMap[$lcode]|default:''|strlen}/64</span>
                                </div>
                            </div>
                            <input id="seo-title-{$lcode|escape}" class="mt-input" type="text" name="seo_title[{$lcode|escape}]" maxlength="64" value="{$titleMap[$lcode]|default:''|escape}" placeholder="{$pageLabel|escape}">
                        </div>

                        <div class="mt-field mt-seo-desc">
                            <div class="mt-field-row">
                                <label class="mt-field-label" for="seo-desc-{$lcode|escape}">SEO description</label>
                                <div class="mt-field-tools">
                                    <span class="mt-charcount">{$descMap[$lcode]|default:''|strlen}/160</span>
                                </div>
                            </div>
                            <textarea id="seo-desc-{$lcode|escape}" class="mt-textarea" name="seo_description[{$lcode|escape}]" rows="3" maxlength="160">{$descMap[$lcode]|default:''|escape}</textarea>
                        </div>
                    </div>
                {/foreach}
            </div>

            <div class="mt-field">
                <label class="mt-field-label" for="seo-social">Social image URL</label>
                <input id="seo-social" class="mt-input" type="text" name="seo_social_image" maxlength="500" value="{$seo.social_image|escape}" placeholder="https://… (1200×630)">
            </div>
        </div>

        <div class="mt-panel pad">
            <div class="mt-subhead">Custom layout</div>
            <div class="mt-field">
                <label class="mt-field-label" for="lay-main">Main menu</label>
                <select id="lay-main" class="mt-select" name="layout_main_menu">
                    {foreach $layoutChoices['main-menu'] as $choice}
                        <option value="{$choice.name|escape}" {if $choice.name == ($layoutOverrides['main-menu']|default:'')}selected{/if}>{$choice.label|escape}</option>
                    {/foreach}
                </select>
            </div>
            <div class="mt-field">
                <label class="mt-field-label" for="lay-footer">Footer</label>
                <select id="lay-footer" class="mt-select" name="layout_footer">
                    {foreach $layoutChoices['footer'] as $choice}
                        <option value="{$choice.name|escape}" {if $choice.name == ($layoutOverrides['footer']|default:'')}selected{/if}>{$choice.label|escape}</option>
                    {/foreach}
                </select>
            </div>
            <div class="mt-row-help">Override the global layout for this page only.</div>
        </div>
    </div>

    </div>{* .mt-pd-grid *}

    {* All-languages editor. Deliberately rendered INSIDE the form: opening it
       MOVES #seo-langs in here rather than cloning, so there is exactly one set
       of inputs and no draft/sync layer to drift. A node outside the <form>
       would silently stop submitting, so this placement is load-bearing --
       position:fixed only affects painting, not form ownership. *}
    {if $seoLanguages|count > 1}
        <div class="mt-modal" id="seo-bulk" hidden>
            <div class="mt-modal-card" role="dialog" aria-modal="true" aria-labelledby="seo-bulk-title">
                <div class="mt-modal-head">
                    <div>
                        <div class="mt-modal-title" id="seo-bulk-title">SEO translations &mdash; {$pageLabel|escape}</div>
                        <div class="mt-modal-sub"><span id="seo-bulk-count"></span> &middot; empty languages fall back to the site default.</div>
                    </div>
                    <button type="button" class="mt-modal-x" id="seo-bulk-close" aria-label="Close">&times;</button>
                </div>
                <div class="mt-modal-tools">
                    {* No name= on either control: they are UI only and must not
                       post. The Enter key is trapped in the JS below, or it
                       would submit the whole page editor from inside a filter. *}
                    <input type="text" class="mt-input" id="seo-bulk-filter" placeholder="Filter languages&hellip;" autocomplete="off">
                    <label class="mt-modal-check">
                        <input type="checkbox" id="seo-bulk-missing"> Only missing
                    </label>
                    <div class="mt-modal-tools-gap"></div>
                    <button type="button" class="mt-btn mt-btn-secondary mt-btn-sm" id="seo-bulk-copy">Copy default &rarr; empty</button>
                </div>
                <div class="mt-modal-body" id="seo-bulk-body"></div>
                <div class="mt-modal-foot">
                    <button type="button" class="mt-btn mt-btn-primary mt-btn-sm" id="seo-bulk-done">Done</button>
                </div>
            </div>
        </div>
    {/if}
</form>

{literal}
<script>
// Variant picker: the cards are <label>s around hidden radios, so selection
// works natively — but nothing highlights on click. Wire live feedback and
// explicitly set the radio so the choice is reliable, then Save persists it.
(function () {
    var grid = document.querySelector('.mt-variant-grid');
    if (!grid) return;
    var cards = Array.prototype.slice.call(grid.querySelectorAll('.mt-variant'));
    if (cards.length < 2) return;
    var saved = grid.getAttribute('data-saved-variant') || '';

    function render() {
        var checked = grid.querySelector('input[name="variant"]:checked');
        var sel = checked ? checked.value : '';
        cards.forEach(function (card) {
            var radio = card.querySelector('input[name="variant"]');
            var isSel = !!(radio && radio.value === sel);
            card.classList.toggle('is-active', isSel);
            var badge = card.querySelector('.mt-badge');
            if (!badge) return;
            badge.textContent = isSel
                ? (radio.value === saved ? 'Active' : 'Selected — Save to apply')
                : 'Activate';
            badge.classList.remove('mt-badge-success', 'mt-badge-neutral');
            badge.classList.add(isSel ? 'mt-badge-success' : 'mt-badge-neutral');
        });
    }

    cards.forEach(function (card) {
        card.addEventListener('click', function () {
            var radio = card.querySelector('input[name="variant"]');
            if (radio) radio.checked = true;
            render();
        });
    });
})();

// Per-language SEO. This install runs 26 languages; rendering them as a flat
// stack made the SEO panel 6,814px tall, so the rail shows one at a time and
// the modal shows them as a table. Both modes drive the SAME inputs — the
// container is MOVED, never cloned — so there is no draft state to reconcile
// and every language still posts on Save.
(function () {
    var box = document.getElementById('seo-langs');
    if (!box) return;
    var langs = Array.prototype.slice.call(box.querySelectorAll('.mt-seo-lang'));
    var pick  = document.getElementById('seo-lang-pick');
    if (!pick || langs.length < 2) return;   // single-language install: nothing to switch

    var countEl = document.getElementById('seo-lang-count');
    var modal   = document.getElementById('seo-bulk');
    var railSlot = box.parentNode, railNext = box.nextSibling;

    function fieldsOf(l) {
        return [l.querySelector('input[type="text"]'), l.querySelector('textarea')];
    }
    function isFilled(l) {
        return fieldsOf(l).some(function (f) { return f && f.value.trim() !== ''; });
    }
    function refreshCounts() {
        var done = langs.filter(isFilled).length;
        langs.forEach(function (l) { l.classList.toggle('is-filled', isFilled(l)); });
        if (countEl) countEl.textContent = done + '/' + langs.length + ' translated';
        var bulkCount = document.getElementById('seo-bulk-count');
        if (bulkCount) bulkCount.textContent = done + '/' + langs.length + ' languages have content';
    }
    function showLang(code) {
        langs.forEach(function (l) {
            if (l.getAttribute('data-lang') === code) l.setAttribute('data-active', '');
            else l.removeAttribute('data-active');
        });
    }

    // Live char counter, so "12/64" is not stale the moment you type.
    box.addEventListener('input', function (e) {
        var f = e.target;
        if (!f.maxLength || f.maxLength < 0) return;
        var wrap = f.closest('.mt-field');
        var c = wrap && wrap.querySelector('.mt-charcount');
        if (c) c.textContent = f.value.length + '/' + f.maxLength;
        refreshCounts();
    });

    pick.addEventListener('change', function () { showLang(pick.value); });
    // Prefer the language that already has content, else the first option.
    var initial = (langs.filter(isFilled)[0] || langs[0]).getAttribute('data-lang');
    pick.value = initial;
    showLang(initial);
    refreshCounts();

    // ---- bulk modal ----
    if (!modal) return;
    var openBtn  = document.getElementById('seo-bulk-open');
    var closeBtn = document.getElementById('seo-bulk-close');
    var doneBtn  = document.getElementById('seo-bulk-done');
    var bodyEl   = document.getElementById('seo-bulk-body');
    var filter   = document.getElementById('seo-bulk-filter');
    var missing  = document.getElementById('seo-bulk-missing');
    var copyBtn  = document.getElementById('seo-bulk-copy');

    function applyFilter() {
        var q = (filter.value || '').trim().toLowerCase();
        var only = missing.checked, shown = 0;
        langs.forEach(function (l) {
            var name = (l.getAttribute('data-label') || '') + ' ' + (l.getAttribute('data-lang') || '');
            var ok = (!q || name.toLowerCase().indexOf(q) !== -1) && (!only || !isFilled(l));
            l.hidden = !ok;
            if (ok) shown++;
        });
        var empty = document.getElementById('seo-bulk-empty');
        if (!shown && !empty) {
            empty = document.createElement('div');
            empty.id = 'seo-bulk-empty';
            empty.className = 'mt-modal-empty';
            empty.textContent = 'No languages match.';
            bodyEl.appendChild(empty);
        } else if (shown && empty) {
            empty.remove();
        }
    }
    function open() {
        bodyEl.appendChild(box);              // MOVE — same nodes, still inside the form
        box.classList.remove('is-single');
        box.classList.add('is-table');
        modal.hidden = false;
        refreshCounts();
        applyFilter();
        filter.focus();
    }
    function close() {
        box.classList.remove('is-table');
        box.classList.add('is-single');
        langs.forEach(function (l) { l.hidden = false; });   // clear filter state
        railSlot.insertBefore(box, railNext);                // back to its exact slot
        modal.hidden = true;
        showLang(pick.value);
        refreshCounts();
        openBtn.focus();
    }

    openBtn.addEventListener('click', open);
    closeBtn.addEventListener('click', close);
    doneBtn.addEventListener('click', close);
    // Backdrop click, but not a click inside the card.
    modal.addEventListener('click', function (e) { if (e.target === modal) close(); });
    document.addEventListener('keydown', function (e) {
        if (e.key === 'Escape' && !modal.hidden) close();
    });
    // The filter lives inside the page-edit form; Enter would submit it and
    // navigate away mid-edit.
    filter.addEventListener('keydown', function (e) {
        if (e.key === 'Enter') { e.preventDefault(); applyFilter(); }
    });
    filter.addEventListener('input', applyFilter);
    missing.addEventListener('change', applyFilter);

    copyBtn.addEventListener('click', function () {
        // Seed every empty language from the one the picker is on, so a site
        // has something indexable everywhere before translations land.
        var src = langs.filter(function (l) { return l.getAttribute('data-lang') === pick.value; })[0] || langs[0];
        var s = fieldsOf(src);
        langs.forEach(function (l) {
            if (l === src || isFilled(l)) return;
            var d = fieldsOf(l);
            if (d[0] && s[0]) d[0].value = s[0].value;
            if (d[1] && s[1]) d[1].value = s[1].value;
            d.forEach(function (f) {
                if (!f) return;
                var w = f.closest('.mt-field'), c = w && w.querySelector('.mt-charcount');
                if (c) c.textContent = f.value.length + '/' + f.maxLength;
            });
        });
        refreshCounts();
        applyFilter();
    });
})();
</script>
{/literal}

{include file="includes/footer.tpl"}
