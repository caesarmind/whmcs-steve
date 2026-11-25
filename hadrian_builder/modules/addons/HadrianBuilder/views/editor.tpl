{include file="includes/header.tpl"}

{* The stylesheet and the script are separate files under assets/, read by
   AdminController and printed here as values. Smarty never parses a value, so
   neither needs a literal wrapper, and nothing depends on the addon's asset
   directory being reachable over HTTP.

   Layout: a rail (Add, Layers, Page) and one panel on the left, the page on
   the right. The panel's content is drawn by page-builder.js. *}
<style>{$editorCss}</style>

<div class="hbx hbx-editor" id="hbx">

    <div class="hbx-bar">
        <a class="mt-back" href="{$pagesUrl|escape}">
            <svg viewBox="0 0 16 16" fill="none" aria-hidden="true"><path d="M10 3L5 8l5 5" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round"/></svg>
            Pages
        </a>
        <span class="hbx-sep"></span>
        <div class="hbx-title">
            <span class="hbx-name" id="hbx-name">{$name|escape}</span>
            <span class="mt-badge mt-badge-neutral" id="hbx-status"></span>
        </div>
        <div class="hbx-tools">
            <button type="button" class="hbx-ico" id="hbx-undo" title="Undo (Ctrl+Z)" aria-label="Undo" disabled>
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M9 7L4 12l5 5"/><path d="M4 12h11a5 5 0 010 10h-2"/></svg>
            </button>
            <button type="button" class="hbx-ico" id="hbx-redo" title="Redo (Ctrl+Shift+Z)" aria-label="Redo" disabled>
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M15 7l5 5-5 5"/><path d="M20 12H9a5 5 0 000 10h2"/></svg>
            </button>
            <span class="hbx-sep"></span>
            <select class="hbx-lang" id="hbx-lang" aria-label="Language"></select>
            <div class="hbx-seg" id="hbx-device" role="group" aria-label="Preview width">
                <button type="button" data-v="desktop" class="is-active" title="Desktop" aria-label="Desktop">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><rect x="3" y="4" width="18" height="12" rx="2"/><path d="M8 20h8M12 16v4"/></svg>
                </button>
                <button type="button" data-v="tablet" title="Tablet" aria-label="Tablet">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><rect x="5" y="3" width="14" height="18" rx="2"/><path d="M11 18h2"/></svg>
                </button>
                <button type="button" data-v="mobile" title="Mobile" aria-label="Mobile">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><rect x="7" y="3" width="10" height="18" rx="2"/><path d="M11 18h2"/></svg>
                </button>
            </div>
            <span class="hbx-sep"></span>
            <a class="mt-btn mt-btn-secondary mt-btn-sm" id="hbx-view" href="#" target="_blank" rel="noopener" hidden>View page</a>
            <button type="button" class="mt-btn mt-btn-secondary mt-btn-sm" id="hbx-save">Save draft</button>
            <button type="button" class="mt-btn mt-btn-primary mt-btn-sm" id="hbx-publish">Publish</button>
        </div>
    </div>

    <div class="hbx-notice" id="hbx-notice" aria-live="polite"></div>

    <div class="hbx-main">

        <nav class="hbx-rail" aria-label="Editor panels">
            <button type="button" class="hbx-rail-btn" data-panel="add" id="hbx-addbtn">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M12 5v14M5 12h14"/></svg>
                Add
            </button>
            <button type="button" class="hbx-rail-btn" data-panel="layers" id="hbx-layersbtn">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M12 3l9 5-9 5-9-5z"/><path d="M3 12l9 5 9-5"/><path d="M3 16l9 5 9-5"/></svg>
                Layers
                <span class="hbx-badge" id="hbx-count">0</span>
            </button>
            <button type="button" class="hbx-rail-btn" data-panel="page" id="hbx-pagebtn">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M7 3h7l5 5v13H7z"/><path d="M14 3v5h5"/><path d="M10 13h6M10 17h4"/></svg>
                Page
            </button>
        </nav>

        <aside class="hbx-panel" id="hbx-panel" aria-live="polite"></aside>

        <section class="hbx-canvas">
            <div class="hbx-look" id="hbx-look" hidden></div>
            <div class="hbx-stage" id="hbx-stage">
                <div class="hbx-device" id="hbx-canvas">
                    <iframe class="hbx-frame" id="hbx-frame" title="Page preview"></iframe>
                    <div class="hbx-busy" id="hbx-busy" hidden>Updating</div>
                </div>
            </div>
            <div class="hbx-foot">
                <span>Click a section to edit it. Click text to find its setting, double-click to type on the page. Links are switched off here.</span>
                <span class="hbx-keys"><kbd>Esc</kbd> deselect <kbd>Alt</kbd>+<kbd>&uarr;</kbd><kbd>&darr;</kbd> move <kbd>Ctrl</kbd>+<kbd>Z</kbd> undo</span>
                <span class="hbx-scale" id="hbx-scale"></span>
            </div>
        </section>

    </div>

    <div class="hbx-peek" id="hbx-peek" aria-hidden="true">
        <div class="hbx-peek-head" id="hbx-peek-head"></div>
        <div class="hbx-peek-box"><iframe id="hbx-peek-frame" title="Section preview" tabindex="-1"></iframe></div>
    </div>
    <div class="hbx-toast" id="hbx-toast" role="status"></div>
</div>

<script type="application/json" id="hbx-boot">{$boot}</script>
<script>{$editorJs}</script>

{include file="includes/footer.tpl"}
