{include file="includes/header.tpl"}

{* The stylesheet and the script are separate files under assets/, read by
   AdminController and printed here as values. Smarty never parses a value, so
   neither needs a literal wrapper, and nothing depends on the addon's asset
   directory being reachable over HTTP. *}
<style>{$builderCss}</style>

<div class="hxb" id="hxb">

    <div class="hxb-bar">
        <a class="mt-back" href="{$base}">
            <svg viewBox="0 0 16 16" fill="none" aria-hidden="true"><path d="M10 3L5 8l5 5" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round"/></svg>
            Email
        </a>
        <div class="hxb-title">
            <span class="hxb-name">{$name|escape}</span>
            <span class="mt-badge mt-badge-neutral" id="hxb-status"></span>
        </div>
        <div class="hxb-tools">
            <select class="mt-select" id="hxb-lang" aria-label="Language"></select>
            <div class="hxb-seg" id="hxb-scheme" role="group" aria-label="Colour scheme">
                <button type="button" data-v="light" class="is-active">Light</button>
                <button type="button" data-v="dark">Dark</button>
            </div>
            <div class="hxb-seg" id="hxb-device" role="group" aria-label="Preview width">
                <button type="button" data-v="desktop" class="is-active">Desktop</button>
                <button type="button" data-v="mobile">Mobile</button>
            </div>
            <span class="hxb-sep"></span>
            {if $isLayout}
                <button type="button" class="mt-btn mt-btn-primary mt-btn-sm" id="hxb-save">Save layout</button>
            {else}
                <button type="button" class="mt-btn mt-btn-secondary mt-btn-sm" id="hxb-save">Save draft</button>
                <button type="button" class="mt-btn mt-btn-primary mt-btn-sm" id="hxb-publish">Publish</button>
            {/if}
        </div>
    </div>

    <div class="hxb-notice" id="hxb-notice" aria-live="polite"></div>

    <div class="hxb-main">

        <aside class="hxb-side hxb-left">
            <div class="hxb-h">Blocks</div>
            <div class="hxb-palette" id="hxb-palette"></div>
            <p class="hxb-hint">Drag a block onto the email, or click it to add it after the selected block.</p>

            <div class="hxb-h">Outline</div>
            <ol class="hxb-outline" id="hxb-outline"></ol>
        </aside>

        <div class="hxb-stage">
            <div class="hxb-device" id="hxb-canvas">
                <iframe class="hxb-frame" id="hxb-frame" title="Email preview" sandbox="allow-same-origin"></iframe>
                <div class="hxb-overlay" id="hxb-overlay" tabindex="0" role="application"
                     aria-label="Email canvas. Arrow keys move between blocks, Alt and an arrow key moves the selected block, Delete removes it."></div>
            </div>
            <div class="hxb-meta">
                <span>Merge fields show sample data. Conditions show their first branch.</span>
                <span id="hxb-bytes"></span>
            </div>
        </div>

        <aside class="hxb-side hxb-right" id="hxb-inspector"></aside>

    </div>
</div>

<script type="application/json" id="hxb-boot">{$boot}</script>
<script>{$builderJs}</script>

{include file="includes/footer.tpl"}
