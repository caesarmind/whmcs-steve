{include file="includes/header.tpl"}

{* Importing pages from a file, in two screens drawn by this one template:

     review   what the file holds, page by page, and a choice for each.
              Nothing has been imported yet.
     done     what was imported, with a way into each page.

   Every text here is a value from AdminController (describeImport), escaped
   on output. The styles are this screen's own and prefixed mt-pb-; the rest
   are Hadrian's shared classes. *}
{literal}
<style>
.mt-pb-imp-file { display:flex; align-items:center; gap:10px; flex-wrap:wrap; font-size:13px; color:var(--mt-text-3); margin:-8px 0 22px; }
.mt-pb-imp-file strong { color:var(--mt-text); font-weight:600; }
.mt-pb-imp-page { display:grid; grid-template-columns:minmax(0,1fr) minmax(220px,300px); gap:8px 28px; padding:20px 0; border-bottom:1px solid var(--mt-border); }
.mt-pb-imp-page:first-child { padding-top:0; }
.mt-pb-imp-page:last-child { border-bottom:0; padding-bottom:0; }
.mt-pb-imp-name { font-size:16px; font-weight:600; color:var(--mt-text); }
.mt-pb-imp-meta { font-size:12.5px; color:var(--mt-text-3); margin-top:3px; }
.mt-pb-imp-list { list-style:none; margin:12px 0 0; padding:0; display:grid; gap:7px; }
.mt-pb-imp-list li { position:relative; padding-left:18px; font-size:13px; line-height:1.5; color:var(--mt-text-2); }
.mt-pb-imp-list li::before { content:""; position:absolute; left:3px; top:8px; width:6px; height:6px; border-radius:50%; background:var(--mt-text-3); opacity:.6; }
.mt-pb-imp-list li.is-warn { color:var(--mt-text); }
.mt-pb-imp-list li.is-warn::before { background:var(--mt-warning); opacity:1; }
.mt-pb-imp-do label { display:block; font-size:12px; font-weight:600; color:var(--mt-text-2); margin-bottom:6px; }
.mt-pb-imp-do .mt-select { width:100%; font-size:13px; }
.mt-pb-imp-hint { font-size:12.5px; line-height:1.5; color:var(--mt-text-3); margin-top:8px; }
.mt-pb-imp-foot { display:flex; align-items:center; justify-content:flex-end; gap:10px; margin-top:20px; }
.mt-pb-imp-foot .mt-pb-imp-say { margin-right:auto; font-size:12.5px; color:var(--mt-text-3); }
.mt-pb-imp-foot form { margin:0; }
.mt-pb-imp-done { display:flex; align-items:center; justify-content:space-between; gap:16px; flex-wrap:wrap; padding:14px 0; border-bottom:1px solid var(--mt-border); }
.mt-pb-imp-done:last-child { border-bottom:0; }
.mt-pb-imp-done-links { display:flex; gap:8px; }
.mt-pb-imp-foot .mt-btn { white-space:nowrap; }
@media (max-width: 760px) {
    .mt-pb-imp-page { grid-template-columns:minmax(0,1fr); }
    .mt-pb-imp-do { margin-top:8px; }
    .mt-pb-imp-foot { flex-wrap:wrap; }
    .mt-pb-imp-foot .mt-pb-imp-say { flex-basis:100%; margin-right:0; }
}
</style>
{/literal}

<div class="mt-toolbar">
    <a class="mt-back" href="{$pagesUrl|escape}">
        <svg viewBox="0 0 16 16" fill="none" aria-hidden="true"><path d="M10 13L5 8l5-5" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round"/></svg>
        Back to Pages
    </a>
</div>

{if $step == 'review'}

<header class="mt-page-header">
    <div class="mt-page-eyebrow">Built pages</div>
    <h1 class="mt-page-title">Import pages</h1>
    <p class="mt-page-subtitle">Nothing has been imported yet. Check what the file holds and choose what to do with each page.</p>
</header>

<div class="mt-pb-imp-file" data-pb-import-file>
    <span>File: <strong>{$fileLabel|escape}</strong></span>
    {if $exported}<span>Exported {$exported|escape}</span>{/if}
    <span>{$pages|count} {if $pages|count == 1}page{else}pages{/if}</span>
</div>

<form method="post" action="{$base|escape}&amp;action=import-apply" id="pb-import-form">
    <input type="hidden" name="token" value="{$token|escape}">
    <input type="hidden" name="t" value="{$t|escape}">

    <div class="mt-panel pad">
        {foreach $pages as $p}
            <div class="mt-pb-imp-page" data-pb-import-page="{$p.index}">
                <div>
                    <div class="mt-pb-imp-name">{$p.name|escape}</div>
                    <div class="mt-pb-imp-meta">
                        {if $p.slug}/{$p.slug|escape}{else}No address{/if} &middot; {$p.brings|escape}
                    </div>
                    {if $p.warnings || $p.notes || $p.empty}
                        <ul class="mt-pb-imp-list">
                            {if $p.empty}<li class="is-warn">None of this page's sections can be imported here, so it would arrive empty.</li>{/if}
                            {foreach $p.warnings as $w}<li class="is-warn">{$w|escape}</li>{/foreach}
                            {foreach $p.notes as $n}<li>{$n|escape}</li>{/foreach}
                        </ul>
                    {/if}
                </div>
                <div class="mt-pb-imp-do">
                    <label for="pb-choice-{$p.index}">What to do</label>
                    <select class="mt-select" id="pb-choice-{$p.index}" name="choice[{$p.index}]" data-pb-choice
                            data-new-hint="{$p.asNew|escape}{if $p.match} {$p.match|escape}{/if}">
                        {foreach $p.options as $o}
                            <option value="{$o.value|escape}">{$o.label|escape}</option>
                        {/foreach}
                    </select>
                    <div class="mt-pb-imp-hint" data-pb-hint>{$p.asNew|escape}{if $p.match} {$p.match|escape}{/if}</div>
                </div>
            </div>
        {/foreach}
    </div>
</form>

<div class="mt-pb-imp-foot">
    <span class="mt-pb-imp-say">Imported pages are drafts. Nothing visitors see changes until you publish.</span>
    <form method="post" action="{$base|escape}&amp;action=import-cancel">
        <input type="hidden" name="token" value="{$token|escape}">
        <input type="hidden" name="t" value="{$t|escape}">
        <button type="submit" class="mt-btn mt-btn-secondary">Cancel</button>
    </form>
    <button type="submit" form="pb-import-form" class="mt-btn mt-btn-primary" id="pb-import-go">Import</button>
</div>

{literal}
<script>
// The line under each choice says what that choice will do, and the button
// says how many pages are about to be imported.
(function () {
    var selects = Array.prototype.slice.call(document.querySelectorAll('[data-pb-choice]'));
    var go = document.getElementById('pb-import-go');
    function refresh() {
        var n = 0;
        selects.forEach(function (s) {
            var hint = s.parentNode.querySelector('[data-pb-hint]');
            var text = '';
            if (s.value === 'new') {
                text = s.getAttribute('data-new-hint') || '';
                n++;
            } else if (s.value === 'skip') {
                text = 'This page will not be imported.';
            } else {
                text = 'Its sections replace that page\'s draft. The name, address and settings stay, and what visitors see does not change until you publish.';
                n++;
            }
            if (hint) { hint.textContent = text; }
        });
        if (go) {
            go.disabled = n === 0;
            go.textContent = n === 0 ? 'Nothing to import' : 'Import ' + n + (n === 1 ? ' page' : ' pages');
        }
    }
    selects.forEach(function (s) { s.addEventListener('change', refresh); });
    refresh();
})();
</script>
{/literal}

{else}

<header class="mt-page-header">
    <div class="mt-page-eyebrow">Built pages</div>
    <h1 class="mt-page-title">Import finished</h1>
    <p class="mt-page-subtitle">
        {if !$created && !$replaced}
            No pages were imported from {$fileLabel|escape}.
        {else}
            From {$fileLabel|escape}:
            {if $created}{$created|count} {if $created|count == 1}page{else}pages{/if} added{/if}{if $created && $replaced}, {/if}{if $replaced}{$replaced|count} {if $replaced|count == 1}page{else}pages{/if} given new sections{/if}{if $images}, {$images} {if $images == 1}image{else}images{/if} in the media library{/if}.
            Nothing visitors see has changed: an imported page is a draft until you publish it.
        {/if}
    </p>
</header>

{if $notes}
    <div class="mt-alert mt-alert-warning" data-pb-import-notes>
        <strong>Not everything came across.</strong>
        <ul>
            {foreach $notes as $n}<li>{$n|escape}</li>{/foreach}
        </ul>
    </div>
{/if}

{if $created || $replaced}
    <div class="mt-panel pad" data-pb-import-result>
        {foreach $created as $p}
            <div class="mt-pb-imp-done">
                <div>
                    <div class="mt-pb-imp-name">{$p.name|escape} <span class="mt-badge mt-badge-neutral">New draft</span></div>
                </div>
                <div class="mt-pb-imp-done-links">
                    <a class="mt-btn mt-btn-secondary mt-btn-sm" href="{$p.settingsUrl|escape}">Settings</a>
                    <a class="mt-btn mt-btn-primary mt-btn-sm" href="{$p.editUrl|escape}">Open in the editor</a>
                </div>
            </div>
        {/foreach}
        {foreach $replaced as $p}
            <div class="mt-pb-imp-done">
                <div>
                    <div class="mt-pb-imp-name">{$p.name|escape} <span class="mt-badge mt-badge-warning">Draft changed</span></div>
                    <div class="mt-pb-imp-meta">Its sections were replaced in the draft. Publish it to show them to visitors.</div>
                </div>
                <div class="mt-pb-imp-done-links">
                    <a class="mt-btn mt-btn-secondary mt-btn-sm" href="{$p.settingsUrl|escape}">Settings</a>
                    <a class="mt-btn mt-btn-primary mt-btn-sm" href="{$p.editUrl|escape}">Open in the editor</a>
                </div>
            </div>
        {/foreach}
    </div>
{/if}

<div class="mt-pb-imp-foot">
    <a class="mt-btn mt-btn-secondary" href="{$pagesUrl|escape}">Back to Pages</a>
</div>

{/if}

{include file="includes/footer.tpl"}
