{include file="includes/header.tpl"}

<div class="mt-toolbar">
    <a class="mt-back" href="?module=Hadrian&action=pages#tab={$pageGroup|escape:'url'}">
        <svg viewBox="0 0 16 16" fill="none"><path d="M10 13L5 8l5-5" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round"/></svg>
        Back to Pages
    </a>
    <div class="mt-toolbar-right">
        {* Opens the real client-area page. Rendered only when the URL is
           certain -- see Helpers\PageUrlResolver; pages that need a record id,
           or that are one step inside a flow, get the muted note instead of a
           link that would 404.

           NB plain |escape, NOT |escape:'url'. The value is a whole path plus
           query ("clientarea.php?action=services"); url-escaping would
           percent-encode the ? and = and produce a dead link. This is the
           opposite of the {$layout.dataLayout|escape:'url'} idiom on the
           Layouts page, where only a bare value is spliced into a query
           string someone else wrote. *}
        {if $publicUrl}
            <a class="mt-viewpage" href="{$publicUrl|escape}" target="_blank" rel="noopener"
               title="Opens {$publicUrl|escape} in a new tab.">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M14 4h6v6"/><path d="M20 4l-8 8"/><path d="M18 14v4a2 2 0 0 1-2 2H6a2 2 0 0 1-2-2V8a2 2 0 0 1 2-2h4"/></svg>
                View page
            </a>
        {elseif $publicUrlReason}
            <span class="mt-viewpage-none" title="{$publicUrlReason|escape}">No public URL</span>
        {/if}
        <button form="page-edit-form" class="mt-btn mt-btn-primary mt-btn-sm">Save changes</button>
    </div>
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

/* Toolbar right cluster: View page + Save, so Save keeps its far-right slot. */
.mt-toolbar-right { display: flex; align-items: center; gap: 10px; }
.mt-viewpage { display: inline-flex; align-items: center; gap: 6px; padding: 7px 14px;
    border: 1px solid var(--mt-border); border-radius: 8px; background: var(--mt-surface);
    color: var(--mt-primary); font-size: 13px; font-weight: 600; text-decoration: none;
    transition: background .15s ease, border-color .15s ease; }
.mt-viewpage:hover { background: var(--mt-primary-tint); border-color: var(--mt-primary);
    color: var(--mt-primary); text-decoration: none; }
.mt-viewpage:focus-visible { outline: 2px solid var(--mt-primary); outline-offset: 2px; }
.mt-viewpage svg { width: 13px; height: 13px; display: block; flex-shrink: 0; }
/* cursor:help so the title is discoverable -- the reason IS the content here. */
.mt-viewpage-none { font-size: 12.5px; color: var(--mt-text-3); cursor: help; }

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
/* Numeric option. .mt-row is a flex row, so the input would otherwise stretch;
   size it to the value it holds rather than to the panel. */
.mt-pd-rows .mt-input-num { width: 90px; flex: none; text-align: center; }

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
/* The title/description tips live inside the per-language block, so the rail
   (one language at a time) shows one of each -- but the bulk table renders all
   26 rows at once and 52 info icons is noise. The column context there makes
   them redundant anyway. */
.mt-seo-langs.is-table .mt-tip { display: none; }
@media (max-width: 760px) { .mt-seo-langs.is-table .mt-seo-lang { grid-template-columns: 1fr; } .mt-seo-langs.is-table .mt-seo-lang-head { padding-top: 0; } }

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
            <div class="mt-subhead mt-tip-line">Page template {include file="includes/tip.tpl" text="Which template file renders this page. Most pages ship a single option; only a few, like the homepage and login, offer alternatives."}</div>
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
            <div class="mt-subhead mt-tip-line">Template settings {include file="includes/tip.tpl" text="Options declared by the template selected above. Choosing a different template changes what appears here."}</div>
            {if $hasOptions}
                {* Shown by the variant filter when the selected template
                   declares no settings of its own. Every template's controls
                   are rendered (so they all keep posting) and hidden client
                   side, so this cannot be a server-side {if}. *}
                <div class="mt-pd-none mt-pd-none-options mt-opt-hidden">There are no settings for the selected template.</div>
                <div class="mt-pd-rows">
                {foreach $optionRows as $opt}
                    {* 'checkbox' is the type every pageoption.php in the theme
                       actually declares; only 'bool' was handled here, so 48
                       toggles across the page editor rendered as text inputs an
                       admin could not meaningfully switch off. *}
                    {if $opt.type == 'bool' || $opt.type == 'checkbox'}
                        <div class="mt-row" data-opt-variant="{$opt.variant|escape}">
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
                        <div class="mt-row" data-opt-variant="{$opt.variant|escape}">
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
                    {elseif $opt.type == 'int'}
                        {* A number is a two-character value; without this branch
                           it fell into the free-text catch-all below and drew a
                           full-width input the length of the panel, sitting oddly
                           beside the compact toggle and select rows. Same
                           label-left / control-right row as its neighbours. *}
                        <div class="mt-row" data-opt-variant="{$opt.variant|escape}">
                            <div>
                                <div class="mt-row-label">{$opt.label|escape}</div>
                                {if $opt.help}<div class="mt-row-help">{$opt.help|escape}</div>{/if}
                            </div>
                            <input id="opt-{$opt.key|escape}" class="mt-input mt-input-num" type="number"
                                   min="0" step="1" inputmode="numeric"
                                   name="option[{$opt.key|escape}]" value="{$opt.value|escape}">
                        </div>
                    {else}
                        {* Free text needs the full width, so it stays a stacked
                           field rather than a label-left row. *}
                        <div class="mt-field" data-opt-variant="{$opt.variant|escape}">
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

        {* Mount point for the section-layout builder (the script at the foot of
           this file fills it). It is its OWN card here, a sibling between
           Template settings and Page settings, matching the admin reference
           where the block composer is a standalone card rather than a settings
           row -- composing a page's blocks is a different job from toggling an
           option, and it needs the full width.

           Stays empty and invisible when the page declares no option of type
           'sections', or when JS is off. The field it drives lives in the rows
           above and keeps posting either way. *}
        {assign var=mtSecVariant value=$activeVariant}
        {foreach $variants as $mtV}{if $mtV.name == $activeVariant}{assign var=mtSecVariant value=$mtV.label}{/if}{/foreach}
        <div id="mt-seclay-mount" data-variant="{$mtSecVariant|escape}"></div>

        {* Everything that governs the page itself rather than its template:
           who reaches it, and what chrome it renders. *}
        <div class="mt-panel pad">
            <div class="mt-subhead mt-tip-line">Page settings {include file="includes/tip.tpl" text="Who can reach this page, and which pieces of chrome it renders. These apply whichever template is selected."}</div>
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
            <div class="mt-subhead mt-tip-line">SEO {include file="includes/tip.tpl" text="How this page appears in search results and when its link is shared. Languages you leave blank fall back to the site default."}</div>

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

            <div id="seo-langs" class="mt-seo-langs{if $seoLanguages|count > 1} is-single{/if}" data-default-lang="{$seoDefaultLanguage|escape}">
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
                                <span class="mt-tip-line"><label class="mt-field-label" for="seo-title-{$lcode|escape}">SEO title</label>{include file="includes/tip.tpl" text="The page title tag, and the headline shown in search results. Aim for 50-60 characters; longer titles get truncated."}</span>
                                <div class="mt-field-tools">
                                    <span class="mt-charcount">{$titleMap[$lcode]|default:''|strlen}/64</span>
                                </div>
                            </div>
                            <input id="seo-title-{$lcode|escape}" class="mt-input" type="text" name="seo_title[{$lcode|escape}]" maxlength="64" value="{$titleMap[$lcode]|default:''|escape}" placeholder="{$pageLabel|escape}">
                        </div>

                        <div class="mt-field mt-seo-desc">
                            <div class="mt-field-row">
                                <span class="mt-tip-line"><label class="mt-field-label" for="seo-desc-{$lcode|escape}">SEO description</label>{include file="includes/tip.tpl" text="The snippet under the title in search results. Keep it under 160 characters. It does not affect ranking, but it drives click-through."}</span>
                                <div class="mt-field-tools">
                                    <span class="mt-charcount">{$descMap[$lcode]|default:''|strlen}/160</span>
                                </div>
                            </div>
                            <textarea id="seo-desc-{$lcode|escape}" class="mt-textarea" name="seo_description[{$lcode|escape}]" rows="3" maxlength="160">{$descMap[$lcode]|default:''|escape}</textarea>
                        </div>
                    </div>
                {/foreach}
            </div>

            {* data-mt-media upgrades this into a picker (library + upload) via
               includes/media-picker.tpl. The input itself is untouched: same
               name, same maxlength, still typeable, so the save path is
               unchanged and it degrades to a plain URL field without JS.
               value="url" because header.tpl emits this straight into
               og:image / twitter:image with no resolver, and Open Graph
               requires an absolute URL. *}
            <div class="mt-field">
                <label class="mt-field-label" for="seo-social">Social image URL</label>
                <input id="seo-social" class="mt-input" type="text" name="seo_social_image" maxlength="500" value="{$seo.social_image|escape}" placeholder="https://… (1200×630)"
                       data-mt-media
                       data-mt-media-value="url"
                       data-mt-media-collection="library"
                       data-mt-media-title="Social image"
                       data-mt-media-hint="1200 x 630 recommended">
            </div>
        </div>

        <div class="mt-panel pad">
            <div class="mt-subhead mt-tip-line">Custom layout {include file="includes/tip.tpl" text="Override the site-wide Layouts settings for this page only. Leave both on the global option to follow whatever Layouts is set to."}</div>
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
            if (radio && !radio.checked) {
                radio.checked = true;
                // Setting .checked in script does NOT fire 'change', and the
                // radios are hidden so the label's native activation cannot be
                // relied on either. Announce the selection explicitly, or
                // anything listening for it never hears -- which is exactly how
                // the per-template settings filter below ended up only updating
                // after a save round-trip.
                radio.dispatchEvent(new Event('change', { bubbles: true }));
            }
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
    // Open on a language that already has content; otherwise the WHMCS system
    // default. Falling back to langs[0] alone meant a fresh install (nothing
    // translated anywhere) opened every page on Arabic -- first alphabetically.
    var def = box.getAttribute('data-default-lang') || '';
    var defBlock = langs.filter(function (l) { return l.getAttribute('data-lang') === def; })[0];
    var initial = (langs.filter(isFilled)[0] || defBlock || langs[0]).getAttribute('data-lang');
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

{* ── Section layout builder ───────────────────────────────────────────────
   Progressive enhancement over the plain text input that an option of type
   'sections' renders (the {else} catch-all above). The input is KEPT -- same
   element, same name="option[...]", same position inside #page-edit-form --
   and only switched to type=hidden. That is load-bearing: saveAction rewrites
   EVERY declared option key from the POST on every save of this page for any
   reason, so a control that stopped posting would silently reset an admin's
   layout the next time they edited an unrelated SEO field.

   Design follows the Caesarthemes admin reference (the "Homepage blocks"
   composer in hadrian-admin-panel/apple-admin.jsx): an uppercase eyebrow, a
   six-column visual preview of the resulting layout, then one row per section
   with a drag grip, a segmented width control, move arrows and an on/off
   toggle. Its per-block settings expander is intentionally not carried over --
   our sections have no per-section options to put in it.

   With JS off, or if this script throws, the admin still sees and edits the
   raw string; nothing is hidden until the builder has actually rendered. *}
<script id="mtSectionSpecs" type="application/json">{$sectionSpecsJson|default:'{}' nofilter}</script>

{literal}
<style>
/* The builder is its own card in the main column. Hidden until the script has
   populated it, so a JS failure leaves no empty shell behind. */
#mt-seclay-mount:not([data-ready]) { display: none; }
/* A control belonging to a template that is not the one selected. It stays in
   the DOM and keeps posting -- hiding it is purely so the admin sees the
   settings for the template they are actually looking at. */
.mt-opt-hidden { display: none !important; }
.mt-seclay-head { font-size: 12.5px; color: var(--mt-text-3); line-height: 1.5; margin: -4px 0 14px; max-width: 620px; }
.mt-seclay-head b { color: var(--mt-text-2); font-weight: 600; }
/* The option's own text field is redundant once the builder renders -- the card
   carries the heading and help. The input STAYS in the DOM and in the form so
   it keeps posting; only its wrapper is hidden. */
.mt-field.mt-seclay-raw { display: none; }

/* Visual preview -- the same six-column grid the client area renders, so an
   admin can see a half-filled row before saving rather than after. */
.mt-seclay-prev { background: var(--mt-surface-2); border: 1px solid var(--mt-border); border-radius: var(--mt-radius); padding: 12px; margin-bottom: 16px; }
.mt-seclay-prev-grid { display: grid; grid-template-columns: repeat(6, minmax(0, 1fr)); gap: 6px; }
.mt-seclay-cell { min-height: 46px; background: var(--mt-surface); border: 1px solid var(--mt-primary); border-radius: var(--mt-radius-sm); display: flex; flex-direction: column; align-items: center; justify-content: center; gap: 2px; padding: 6px; text-align: center; }
.mt-seclay-cell b { font-size: 11px; font-weight: 600; color: var(--mt-text); line-height: 1.2; }
.mt-seclay-cell i { font-size: 10px; font-style: normal; font-weight: 600; color: var(--mt-primary); }
.mt-seclay-prev-empty { grid-column: span 6; padding: 18px 0; text-align: center; font-size: 12.5px; color: var(--mt-text-3); }

/* Rows */
.mt-seclay-list { list-style: none; margin: 0; padding: 0; display: flex; flex-direction: column; gap: 6px; }
.mt-seclay-item { position: relative; display: flex; align-items: center; gap: 10px; padding: 9px 12px; background: var(--mt-surface); border: 1px solid var(--mt-border); border-radius: 10px; }
.mt-seclay-item.is-off { opacity: 0.5; }
.mt-seclay-item.is-dragging { opacity: 0.35; }
.mt-seclay-item.is-drop-before::before,
.mt-seclay-item.is-drop-after::after { content: ''; position: absolute; left: 0; right: 0; height: 2px; background: var(--mt-primary); z-index: 5; pointer-events: none; }
.mt-seclay-item.is-drop-before::before { top: -4px; }
.mt-seclay-item.is-drop-after::after { bottom: -4px; }
.mt-seclay-grip { cursor: grab; color: var(--mt-text-4); font-size: 13px; user-select: none; line-height: 1; }
.mt-seclay-grip:active { cursor: grabbing; }
.mt-seclay-name { flex: 1; min-width: 0; font-size: 13.5px; font-weight: 500; color: var(--mt-text); }

/* Segmented width control -- same shape as the admin top-nav pill. */
.mt-seclay-w { display: inline-flex; background: var(--mt-surface-2); padding: 2px; border-radius: 7px; gap: 2px; }
.mt-seclay-w button { padding: 3px 8px; font: inherit; font-size: 11px; font-weight: 600; border: none; border-radius: 5px; cursor: pointer; background: transparent; color: var(--mt-text-3); }
.mt-seclay-w button:hover { color: var(--mt-text); }
.mt-seclay-w button.is-active { background: var(--mt-surface); color: var(--mt-primary); box-shadow: var(--mt-shadow-seg); }

.mt-seclay-move button { background: transparent; border: none; cursor: pointer; color: var(--mt-text-3); font-size: 12px; padding: 3px 5px; line-height: 1; }
.mt-seclay-move button:disabled { opacity: 0.3; cursor: default; }
.mt-seclay-move button:not(:disabled):hover { color: var(--mt-text); }

/* Per-section settings drawer. Row and drawer join into one card while open,
   the way the reference's block composer does it. */
.mt-seclay-item.is-open { border-color: var(--mt-primary); background: var(--mt-primary-tint); border-radius: 10px 10px 0 0; border-bottom: none; }
.mt-seclay-disc { flex: 1; min-width: 0; display: flex; align-items: center; gap: 7px; background: transparent; border: none; padding: 0; text-align: left; cursor: pointer; font: inherit; }
.mt-seclay-disc:disabled { cursor: default; }
/* display is belt-and-braces only: as a flex child this span is blockified
   anyway, so the rotation below works without it. Kept so the rule does not
   depend on the parent staying a flex container. */
.mt-seclay-chev { display: inline-block; width: 11px; flex-shrink: 0; font-size: 11px; color: var(--mt-text-4); transition: transform .15s ease; }
.mt-seclay-item.is-open .mt-seclay-chev { transform: rotate(90deg); color: var(--mt-primary); }
.mt-seclay-count { font-size: 10px; color: var(--mt-text-4); }
.mt-seclay-drawer { margin-top: -6px; margin-bottom: 4px; padding: 16px 20px 20px; background: var(--mt-surface); border: 1px solid var(--mt-primary); border-top: 1px solid var(--mt-border); border-radius: 0 0 12px 12px; }
.mt-seclay-drawer-h { display: flex; align-items: center; gap: 9px; font-size: 13.5px; font-weight: 600; color: var(--mt-text); margin-bottom: 12px; }
.mt-seclay-drawer-h span.dot { width: 6px; height: 6px; border-radius: 50%; background: var(--mt-primary); flex-shrink: 0; }
.mt-seclay-opts { background: var(--mt-surface-2); border-radius: 10px; padding: 14px 16px; display: flex; flex-direction: column; gap: 12px; }
.mt-seclay-opt { display: flex; align-items: center; justify-content: space-between; gap: 14px; }
.mt-seclay-opt-l { font-size: 12.5px; font-weight: 500; color: var(--mt-text-2); }
.mt-seclay-opt-h { font-size: 11.5px; color: var(--mt-text-3); margin-top: 2px; line-height: 1.45; max-width: 460px; }

.mt-seclay-presets { display: flex; flex-wrap: wrap; gap: 6px; margin-top: 12px; }
.mt-seclay-presets button { border: 1px solid var(--mt-border); background: var(--mt-surface); color: var(--mt-text); border-radius: 6px; padding: 4px 10px; font: inherit; font-size: 12px; cursor: pointer; }
.mt-seclay-presets button:hover { border-color: var(--mt-primary); color: var(--mt-primary); }
.mt-seclay-note { font-size: 12.5px; color: var(--mt-text-3); margin-top: 10px; line-height: 1.5; }
.mt-seclay-note b { color: var(--mt-text-2); font-weight: 600; }
</style>
<script>
(function () {
    var SPAN = { '1/1': 6, '2/3': 4, '1/2': 3, '1/3': 2 };
    var specsEl = document.getElementById('mtSectionSpecs');
    if (!specsEl) return;
    var specs; try { specs = JSON.parse(specsEl.textContent || '{}'); } catch (e) { return; }

    // Show the settings belonging to the template currently selected, and swap
    // them the moment a different card is picked -- no save round-trip. Every
    // control stays in the DOM and keeps posting whichever template is chosen,
    // so an unselected one's values survive the save untouched.
    function applyVariantFilter() {
        var picked = document.querySelector('input[name="variant"]:checked');
        var name = picked ? picked.value : '';
        var any = false;
        document.querySelectorAll('[data-opt-variant]').forEach(function (el) {
            var owner = el.getAttribute('data-opt-variant');
            var show = !owner || owner === name;
            el.classList.toggle('mt-opt-hidden', !show);
            if (show) any = true;
        });
        // "There are no settings for the current option." should track the
        // selection too, not the last saved template.
        var none = document.querySelector('.mt-pd-none-options');
        if (none) { none.classList.toggle('mt-opt-hidden', any); }
    }
    document.querySelectorAll('input[name="variant"]').forEach(function (r) {
        r.addEventListener('change', applyVariantFilter);
    });
    // Belt and braces: the variant cards are label-wrapped hidden radios driven
    // by their own click handler. That handler now dispatches 'change', but a
    // click listener on the grid means the filter still tracks the selection if
    // the picker is ever reworked to set .checked silently again. Deferred a
    // tick so it reads the radio AFTER that handler has set it. Idempotent.
    var vGrid = document.querySelector('.mt-variant-grid');
    if (vGrid) {
        vGrid.addEventListener('click', function () { setTimeout(applyVariantFilter, 0); });
    }

    Object.keys(specs).forEach(function (key) {
        var input = document.getElementById('opt-' + key);
        if (!input || !input.form) return;              // no field -> leave the page alone
        var spec = specs[key] || {};
        var cat = spec.sections || {};
        var widths = Object.keys(spec.widths || {});
        var keys = Object.keys(cat);
        if (!keys.length || !widths.length) return;

        // The builder renders into its own card between Template settings and
        // Page settings. The input stays exactly where it is, inside the form,
        // just hidden along with its now-redundant label and help text.
        var mount = document.getElementById('mt-seclay-mount');
        if (!mount) return;
        var field = input.closest('.mt-field');

        // Parse the stored string. Empty means "built-in arrangement": show the
        // catalogue in factory order but DO NOT write anything back, so saving
        // an unrelated field leaves it empty and the page keeps its default.
        function readState() {
            var raw = (input.value || '').trim(), seen = {}, out = [];
            if (raw) {
                raw.split(',').forEach(function (part) {
                    var bits = part.split(':');
                    var k = (bits[0] || '').trim().toLowerCase();
                    var w = (bits[1] || '').trim().toLowerCase();
                    var f = (bits[2] || '').trim().toLowerCase();
                    // Whitelist the flags field, mirroring SectionLayout::parse.
                    // A mistyped comma puts a section KEY here, and most keys
                    // contain an 'e' -- a bare indexOf would invent settings.
                    if (f && !/^e*$/.test(f)) { f = ''; }
                    if (!cat[k] || seen[k]) return;
                    if (w !== 'off' && SPAN[w] === undefined) return;
                    seen[k] = 1;
                    out.push({ key: k, on: w !== 'off', w: w === 'off' ? (cat[k].w || '1/1') : w,
                               hideEmpty: f.indexOf('e') !== -1 });
                });
            }
            keys.forEach(function (k) {
                if (!seen[k]) out.push({ key: k, on: true, w: cat[k].w || '1/1', hideEmpty: false });
            });
            return out;
        }

        var state = readState();
        var dirty = (input.value || '').trim() !== '';
        var openKey = null;   // which section's settings drawer is open

        function serialise() {
            return state.map(function (s) {
                return s.key + ':' + (s.on ? s.w : 'off') + (s.hideEmpty ? ':e' : '');
            }).join(',');
        }
        function commit() { dirty = true; input.value = serialise(); paint(); }
        // The hidden field is the source of truth at submit; bfcache restores
        // control state but not programmatic value changes.
        input.form.addEventListener('submit', function () { if (dirty) input.value = serialise(); });
        window.addEventListener('pageshow', function () { if (dirty) input.value = serialise(); });

        var box = document.createElement('div');
        box.className = 'mt-panel pad mt-seclay';
        // Tagged like every other control, so the same filter shows this card
        // only while its own template is the one selected.
        box.setAttribute('data-opt-variant', spec.variant || '');
        var head = document.createElement('div');
        head.className = 'mt-subhead';
        head.textContent = spec.title || 'Sections';
        var blurb = document.createElement('div');
        blurb.className = 'mt-seclay-head';
        var vName = (spec.variantLabel || '').replace(/[<&>]/g, '');
        blurb.innerHTML = (vName ? 'Sections available to the <b>' + vName + '</b> template. ' : '') +
            'Choose which appear, drag to reorder, and set each one’s width.';
        box.appendChild(head);
        box.appendChild(blurb);
        var prev = document.createElement('div');
        prev.className = 'mt-seclay-prev';
        var prevGrid = document.createElement('div');
        prevGrid.className = 'mt-seclay-prev-grid';
        prev.appendChild(prevGrid);
        var list = document.createElement('ul');
        list.className = 'mt-seclay-list';
        var note = document.createElement('div');
        note.className = 'mt-seclay-note';
        box.appendChild(prev); box.appendChild(list); box.appendChild(note);

        function label(k) { return (cat[k] && cat[k].label) || k; }

        function paintPreview() {
            prevGrid.innerHTML = '';
            var shown = state.filter(function (s) { return s.on; });
            if (!shown.length) {
                var e = document.createElement('div');
                e.className = 'mt-seclay-prev-empty';
                e.textContent = 'No sections shown.';
                prevGrid.appendChild(e);
                return;
            }
            shown.forEach(function (s) {
                var c = document.createElement('div');
                c.className = 'mt-seclay-cell';
                c.style.gridColumn = 'span ' + (SPAN[s.w] || 6);
                var b = document.createElement('b'); b.textContent = label(s.key);
                var i = document.createElement('i'); i.textContent = s.w;
                c.appendChild(b); c.appendChild(i);
                prevGrid.appendChild(c);
            });
        }

        function paint() {
            list.innerHTML = '';
            state.forEach(function (s, idx) {
                var li = document.createElement('li');
                li.className = 'mt-seclay-item' + (s.on ? '' : ' is-off');
                li.dataset.key = s.key;

                var grip = document.createElement('span');
                grip.className = 'mt-seclay-grip';
                grip.textContent = '⠿';
                grip.title = 'Drag to reorder';
                // Arm draggable only while the grip is held, so text stays
                // selectable and the row is not draggable from anywhere.
                grip.addEventListener('mousedown', function () { li.draggable = true; });
                grip.addEventListener('mouseup', function () { li.draggable = false; });
                li.appendChild(grip);

                // Name doubles as the disclosure for this section's own
                // settings, matching the reference's block rows.
                var disc = document.createElement('button');
                disc.type = 'button';
                disc.className = 'mt-seclay-disc';
                var chev = document.createElement('span');
                chev.className = 'mt-seclay-chev';
                chev.textContent = '›';
                var name = document.createElement('span');
                name.className = 'mt-seclay-name';
                name.textContent = label(s.key);
                var cnt = document.createElement('span');
                cnt.className = 'mt-seclay-count';
                // State-derived, so a flag set behind a collapsed drawer is
                // still visible on the row.
                cnt.textContent = s.hideEmpty ? 'Hides when empty' : '1 setting';
                disc.appendChild(chev); disc.appendChild(name); disc.appendChild(cnt);
                disc.addEventListener('click', function () {
                    openKey = (openKey === s.key) ? null : s.key;
                    paint();
                });
                li.appendChild(disc);

                var seg = document.createElement('span');
                seg.className = 'mt-seclay-w';
                widths.forEach(function (w) {
                    var b = document.createElement('button');
                    b.type = 'button';
                    b.textContent = w;
                    b.title = spec.widths[w];
                    if (s.w === w) b.className = 'is-active';
                    b.addEventListener('click', function () { s.w = w; s.on = true; commit(); });
                    seg.appendChild(b);
                });
                li.appendChild(seg);

                // Up / down are NOT polish: HTML5 drag-and-drop is mouse-only,
                // so these are the entire touch and keyboard path.
                var mv = document.createElement('span');
                mv.className = 'mt-seclay-move';
                [['↑', -1], ['↓', 1]].forEach(function (pair) {
                    var b = document.createElement('button');
                    b.type = 'button';
                    b.textContent = pair[0];
                    b.title = pair[1] < 0 ? 'Move up' : 'Move down';
                    b.disabled = (pair[1] < 0 && idx === 0) || (pair[1] > 0 && idx === state.length - 1);
                    b.addEventListener('click', function () {
                        var j = idx + pair[1];
                        if (j < 0 || j >= state.length) return;
                        var t = state[idx]; state[idx] = state[j]; state[j] = t;
                        commit();
                    });
                    mv.appendChild(b);
                });
                li.appendChild(mv);

                var tog = document.createElement('label');
                tog.className = 'mt-toggle';
                tog.title = 'Show this section';
                var cb = document.createElement('input');
                cb.type = 'checkbox'; cb.checked = s.on;
                cb.addEventListener('change', function () { s.on = cb.checked; commit(); });
                var track = document.createElement('span'); track.className = 'mt-toggle-track';
                var thumb = document.createElement('span'); thumb.className = 'mt-toggle-thumb';
                track.appendChild(thumb);
                tog.appendChild(cb); tog.appendChild(track);
                li.appendChild(tog);
                if (openKey === s.key) { li.classList.add('is-open'); }
                list.appendChild(li);

                if (openKey === s.key) {
                    var dr = document.createElement('li');
                    dr.className = 'mt-seclay-drawer';
                    var h = document.createElement('div');
                    h.className = 'mt-seclay-drawer-h';
                    var dot = document.createElement('span'); dot.className = 'dot';
                    var ht = document.createElement('span'); ht.textContent = label(s.key) + ' settings';
                    h.appendChild(dot); h.appendChild(ht);
                    var opts = document.createElement('div');
                    opts.className = 'mt-seclay-opts';

                    var opt = document.createElement('div');
                    opt.className = 'mt-seclay-opt';
                    var lw = document.createElement('div');
                    var ll = document.createElement('div');
                    ll.className = 'mt-seclay-opt-l';
                    ll.textContent = 'Hide when empty';
                    var lh = document.createElement('div');
                    lh.className = 'mt-seclay-opt-h';
                    lh.textContent = 'Leave this section out altogether when the client has nothing in it, instead of showing an empty card. The rest of the layout closes up around it.';
                    lw.appendChild(ll); lw.appendChild(lh);
                    var ht2 = document.createElement('label');
                    ht2.className = 'mt-toggle';
                    var hcb = document.createElement('input');
                    hcb.type = 'checkbox'; hcb.checked = !!s.hideEmpty;
                    hcb.addEventListener('change', function () { s.hideEmpty = hcb.checked; commit(); });
                    var htr = document.createElement('span'); htr.className = 'mt-toggle-track';
                    var hth = document.createElement('span'); hth.className = 'mt-toggle-thumb';
                    htr.appendChild(hth); ht2.appendChild(hcb); ht2.appendChild(htr);
                    opt.appendChild(lw); opt.appendChild(ht2);
                    opts.appendChild(opt);

                    dr.appendChild(h); dr.appendChild(opts);
                    list.appendChild(dr);
                }
            });

            paintPreview();
            var shown = state.filter(function (s) { return s.on; }).length;
            note.innerHTML = '<b>' + shown + '</b> of ' + state.length +
                ' sections shown. Widths run on a six-column grid, so a row fills up when its widths add to a whole; anything left over stays blank.' +
                (dirty ? '' : ' <b>Currently using the built-in arrangement.</b>');
        }

        // Drag to reorder.
        // An open drawer is a sibling <li> in the same list, so a plain
        // closest('.mt-seclay-item') returns null anywhere over that ~150px
        // band: dragover would bail before preventDefault, the browser would
        // refuse the drop, and a stale insertion line stayed lit. Resolve the
        // drawer to the row that owns it -- always its previous sibling.
        function rowFor(target) {
            var li = target.closest ? target.closest('.mt-seclay-item') : null;
            if (li) return li;
            var dr = target.closest ? target.closest('.mt-seclay-drawer') : null;
            var own = dr && dr.previousElementSibling;
            return (own && own.classList.contains('mt-seclay-item')) ? own : null;
        }
        var dragKey = null;
        list.addEventListener('dragstart', function (e) {
            var li = e.target.closest('.mt-seclay-item'); if (!li) return;
            dragKey = li.dataset.key; li.classList.add('is-dragging');
            try { e.dataTransfer.setData('text/plain', dragKey); } catch (err) {}
            e.dataTransfer.effectAllowed = 'move';
        });
        list.addEventListener('dragover', function (e) {
            var li = rowFor(e.target); if (!li || !dragKey) return;
            e.preventDefault();
            var r = li.getBoundingClientRect();
            // Over the drawer always means "after the section that owns it".
            var after = e.target.closest('.mt-seclay-drawer')
                ? true : (e.clientY - r.top) > r.height / 2;
            [].forEach.call(list.children, function (n) { n.classList.remove('is-drop-before', 'is-drop-after'); });
            li.classList.add(after ? 'is-drop-after' : 'is-drop-before');
        });
        list.addEventListener('drop', function (e) {
            var li = rowFor(e.target); if (!li || !dragKey) return;
            e.preventDefault();
            var r = li.getBoundingClientRect();
            var after = e.target.closest('.mt-seclay-drawer')
                ? true : (e.clientY - r.top) > r.height / 2;
            var from = state.findIndex(function (s) { return s.key === dragKey; });
            if (from < 0 || li.dataset.key === dragKey) { dragKey = null; paint(); return; }
            var moved = state.splice(from, 1)[0];
            var at = state.findIndex(function (s) { return s.key === li.dataset.key; }) + (after ? 1 : 0);
            state.splice(at, 0, moved);
            dragKey = null;
            commit();
        });
        list.addEventListener('dragend', function () {
            dragKey = null;
            [].forEach.call(list.children, function (n) {
                n.classList.remove('is-dragging', 'is-drop-before', 'is-drop-after');
                n.draggable = false;
            });
        });

        var presets = document.createElement('div');
        presets.className = 'mt-seclay-presets';
        // Presets carry a WIDTH RESOLVER, not a finished string, so they can
        // rewrite order and width while preserving each section's own settings.
        // Rebuilding the string from the catalogue would silently clear every
        // "Hide when empty" flag -- and those live behind a collapsed drawer,
        // so the admin would not see them go. 'Restore default' is the one that
        // legitimately clears everything, which is its whole job.
        [
            ['Restore default', null],
            ['Two columns', function (k, n) { return n < 2 ? '1/1' : '1/2'; }],
            ['Single column', function () { return '1/1'; }],
            ['Thirds', function (k, n) { return n < 2 ? '1/1' : '1/3'; }],
        ].forEach(function (p) {
            var b = document.createElement('button');
            b.type = 'button';
            b.textContent = p[0];
            b.addEventListener('click', function () {
                if (!p[1]) {                       // Restore default
                    input.value = '';
                    state = readState();
                    dirty = false;
                    paint();
                    return;
                }
                var prev = {};
                state.forEach(function (s) { prev[s.key] = s; });
                state = keys.map(function (k, n) {
                    return { key: k, on: true, w: p[1](k, n),
                             hideEmpty: !!(prev[k] && prev[k].hideEmpty) };
                });
                commit();
            });
            presets.appendChild(b);
        });
        box.appendChild(presets);

        input.type = 'hidden';                 // keep the SAME element and name
        if (field) { field.classList.add('mt-seclay-raw'); }
        mount.appendChild(box);
        paint();
        mount.setAttribute('data-ready', '1'); // only now is the builder usable
    });

    // Run last, so the freshly built cards are filtered along with everything else.
    applyVariantFilter();
})();
</script>
{/literal}

{include file="includes/footer.tpl"}
