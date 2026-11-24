{include file="includes/header.tpl"}

{* The stylesheet and the script are separate files under assets/, read by
   AdminController and printed here as values. Smarty never parses a value, so
   neither needs a literal wrapper, and nothing depends on the addon's asset
   directory being reachable over HTTP. *}
<style>{$editorCss}</style>

<div class="hbx" id="hbx">

    <div class="hbx-bar">
        <a class="mt-back" href="{$base}">
            <svg viewBox="0 0 16 16" fill="none" aria-hidden="true"><path d="M10 3L5 8l5 5" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round"/></svg>
            Pages
        </a>
        <div class="hbx-title">
            <span class="hbx-name" id="hbx-name">{$name|escape}</span>
            <span class="mt-badge mt-badge-neutral" id="hbx-status"></span>
        </div>
        <div class="hbx-tools">
            <button type="button" class="hbx-ico" id="hbx-undo" title="Undo (Ctrl+Z)" aria-label="Undo" disabled>
                <svg viewBox="0 0 16 16" fill="none" aria-hidden="true"><path d="M6 3L2.5 6.5 6 10M3 6.5h6.5a3.5 3.5 0 010 7H7" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/></svg>
            </button>
            <button type="button" class="hbx-ico" id="hbx-redo" title="Redo (Ctrl+Shift+Z)" aria-label="Redo" disabled>
                <svg viewBox="0 0 16 16" fill="none" aria-hidden="true"><path d="M10 3l3.5 3.5L10 10M13 6.5H6.5a3.5 3.5 0 000 7H9" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/></svg>
            </button>
            <span class="hbx-sep"></span>
            <select class="mt-select" id="hbx-lang" aria-label="Language"></select>
            <div class="hbx-seg" id="hbx-device" role="group" aria-label="Preview width">
                <button type="button" data-v="desktop" class="is-active">Desktop</button>
                <button type="button" data-v="tablet">Tablet</button>
                <button type="button" data-v="mobile">Mobile</button>
            </div>
            <span class="hbx-sep"></span>
            <a class="mt-btn mt-btn-secondary mt-btn-sm" id="hbx-view" href="#" target="_blank" rel="noopener" hidden>View page</a>
            <button type="button" class="mt-btn mt-btn-secondary mt-btn-sm" id="hbx-save">Save draft</button>
            <button type="button" class="mt-btn mt-btn-primary mt-btn-sm" id="hbx-publish">Publish</button>
        </div>
    </div>

    <div class="hbx-notice" id="hbx-notice" aria-live="polite"></div>

    <div class="hbx-main">

        <aside class="hbx-side hbx-left">
            <div class="hbx-h">On this page</div>
            <ol class="hbx-outline" id="hbx-outline"></ol>
            <button type="button" class="hbx-pagebtn" id="hbx-pagebtn">Page settings</button>

            <div class="hbx-h">Add a section</div>
            <input type="search" class="mt-input hbx-palfilter" id="hbx-palfilter" placeholder="Find a section" aria-label="Find a section" autocomplete="off">
            <div class="hbx-palette" id="hbx-palette"></div>
            <p class="hbx-hint">A new section goes after the selected one, or at the end.</p>
        </aside>

        <div class="hbx-stage">
            <div class="hbx-device" id="hbx-canvas">
                <iframe class="hbx-frame" id="hbx-frame" title="Page preview"></iframe>
                <div class="hbx-busy" id="hbx-busy" hidden>Updating</div>
            </div>
            <div class="hbx-meta">
                <span>This is the page as your theme draws it. Click a section to edit it. Links are switched off here.</span>
                <span id="hbx-scale"></span>
            </div>
        </div>

        <aside class="hbx-side hbx-right" id="hbx-inspector"></aside>

    </div>
</div>

<script type="application/json" id="hbx-boot">{$boot}</script>
<script>{$editorJs}</script>

{include file="includes/footer.tpl"}
