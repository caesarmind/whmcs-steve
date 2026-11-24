{include file="includes/header.tpl"}

{* The customizer: a style, layouts and colours tried out on the real site in a
   frame, saved only when Save is pressed. The controls are built by
   assets/js/customize.js from the JSON block at the foot of this file; this
   template is the shell they are built into.

   Styles are page-local, like the Layouts page's .mt-lay-*: nothing else in
   the admin uses .mt-cz-*. *}
{literal}
<style>
    /* The one screen that wants the whole window: a 1180px column would leave
       the framed site narrower than a phone beside the controls. */
    .mt-body:has(.mt-cz){max-width:none}
    .mt-cz-head{display:flex;align-items:flex-end;justify-content:space-between;gap:24px;flex-wrap:wrap}
    .mt-cz-head .mt-page-title{font-size:28px}
    .mt-cz-actions{display:flex;align-items:center;gap:10px;padding-bottom:6px}
    .mt-cz-status{font-size:13px;color:var(--mt-text-2);min-height:18px}
    .mt-cz-status[data-kind="ok"]{color:var(--mt-success-text)}
    .mt-cz-status[data-kind="error"]{color:var(--mt-danger-text)}

    .mt-cz{display:grid;grid-template-columns:340px minmax(0,1fr);gap:20px;align-items:start}
    .mt-cz-side{position:sticky;top:12px;max-height:calc(100vh - 24px);display:flex;flex-direction:column;overflow:hidden;padding:0}
    .mt-cz-tabs{display:flex;gap:4px;padding:10px;border-bottom:1px solid var(--mt-border)}
    .mt-cz-tabs button{flex:1;border:0;background:transparent;color:var(--mt-text-2);font:inherit;font-size:13px;font-weight:600;padding:8px 6px;border-radius:var(--mt-radius-sm);cursor:pointer}
    .mt-cz-tabs button.is-on{background:var(--mt-surface-2);color:var(--mt-text)}
    .mt-cz-panel{padding:16px;overflow:auto}
    .mt-cz-help{font-size:12.5px;line-height:1.5;color:var(--mt-text-3);margin:0 0 14px}
    .mt-cz-sub{font-size:12px;font-weight:600;letter-spacing:.04em;text-transform:uppercase;color:var(--mt-text-3);margin:18px 0 8px}

    .mt-cz-scheme{display:flex;align-items:center;gap:12px;width:100%;text-align:left;border:1px solid var(--mt-border);background:var(--mt-surface);color:var(--mt-text);border-radius:var(--mt-radius);padding:10px 12px;margin-bottom:8px;font:inherit;cursor:pointer}
    .mt-cz-scheme:hover{border-color:var(--mt-input-border)}
    .mt-cz-scheme.is-on{border-color:var(--mt-primary);box-shadow:0 0 0 3px var(--mt-primary-ring)}
    .mt-cz-swatch{display:flex;flex:none;width:44px;height:30px;border-radius:8px;overflow:hidden;border:1px solid var(--mt-border)}
    .mt-cz-swatch i{display:block;flex:2}
    .mt-cz-swatch i + i{flex:1}
    .mt-cz-scheme-text{display:flex;flex-direction:column;min-width:0}
    .mt-cz-scheme-text strong{font-size:14px;font-weight:600}
    .mt-cz-scheme-text small{font-size:12px;color:var(--mt-text-3);white-space:nowrap;overflow:hidden;text-overflow:ellipsis}

    .mt-cz-field{display:flex;align-items:center;justify-content:space-between;gap:12px;margin-bottom:10px}
    .mt-cz-label{font-size:13px;color:var(--mt-text);flex:none}
    .mt-cz-field .mt-select{max-width:170px;padding:8px 12px;font-size:13px}
    .mt-cz-seg{display:inline-flex;background:var(--mt-surface-2);border-radius:var(--mt-radius-sm);padding:3px}
    .mt-cz-seg button{border:0;background:transparent;color:var(--mt-text-2);font:inherit;font-size:13px;font-weight:500;padding:6px 14px;border-radius:6px;cursor:pointer;line-height:1.2}
    .mt-cz-seg button.is-on{background:var(--mt-surface);color:var(--mt-text);box-shadow:var(--mt-shadow-seg)}
    .mt-cz-seg button svg{display:block}

    .mt-cz-scopebar{display:flex;align-items:center;justify-content:space-between;gap:10px;margin-bottom:12px}
    .mt-cz-scopebar strong{font-size:13px}
    .mt-cz-link{border:0;background:none;color:var(--mt-link);font:inherit;font-size:12.5px;padding:0;cursor:pointer}
    .mt-cz-group{border-top:1px solid var(--mt-border)}
    .mt-cz-group summary{display:flex;align-items:center;gap:8px;padding:11px 0;font-size:13px;font-weight:600;cursor:pointer;list-style:none}
    .mt-cz-group summary::-webkit-details-marker{display:none}
    .mt-cz-group summary::before{content:"";width:6px;height:6px;border-right:1.6px solid var(--mt-text-3);border-bottom:1.6px solid var(--mt-text-3);transform:rotate(-45deg);transition:transform .15s}
    .mt-cz-group[open] summary::before{transform:rotate(45deg)}
    .mt-cz-count{margin-left:auto;font-size:11px;font-weight:600;color:var(--mt-primary);background:var(--mt-primary-tint);border-radius:980px;padding:1px 7px}
    .mt-cz-color{display:grid;grid-template-columns:minmax(0,1fr) 28px 128px 20px;align-items:center;gap:8px;padding:0 0 8px}
    .mt-cz-color-label{font-size:12.5px;color:var(--mt-text-2);white-space:nowrap;overflow:hidden;text-overflow:ellipsis}
    .mt-cz-color input[type="color"]{width:28px;height:28px;padding:0;border:1px solid var(--mt-input-border);border-radius:8px;background:none;cursor:pointer}
    .mt-cz-color input[type="color"]::-webkit-color-swatch-wrapper{padding:2px}
    .mt-cz-color input[type="color"]::-webkit-color-swatch{border:0;border-radius:5px}
    .mt-cz-color .mt-input{grid-column:3;padding:6px 8px;font-size:12px;font-family:ui-monospace,SFMono-Regular,Menlo,Consolas,monospace}
    .mt-cz-color .mt-input.is-bad{border-color:var(--mt-danger)}
    .mt-cz-reset{grid-column:4;border:0;background:none;color:var(--mt-text-3);font-size:15px;line-height:1;padding:0;cursor:pointer}
    .mt-cz-reset:hover{color:var(--mt-primary)}

    .mt-cz-stage{padding:0;overflow:hidden;display:flex;flex-direction:column;height:calc(100vh - 24px);min-height:520px;position:sticky;top:12px}
    .mt-cz-bar{display:flex;align-items:center;gap:12px;padding:10px 14px;border-bottom:1px solid var(--mt-border);flex-wrap:wrap}
    .mt-cz-bar .mt-select{width:auto;min-width:190px;padding:7px 12px;font-size:13px}
    .mt-cz-bar-space{flex:1}
    .mt-cz-outside{margin:0;padding:8px 14px;font-size:12.5px;color:var(--mt-warning-text);background:var(--mt-warning-tint)}
    .mt-cz-viewport{position:relative;flex:1;min-height:0;overflow:hidden;background:var(--mt-surface-2)}
    .mt-cz-viewport iframe{display:block;border:0;background:#fff;transform-origin:0 0}
    .mt-cz[data-cz-loading] .mt-cz-viewport iframe{opacity:.55;transition:opacity .15s}

    @media (max-width: 1000px){
        .mt-cz{grid-template-columns:1fr}
        .mt-cz-side,.mt-cz-stage{position:static;max-height:none}
        .mt-cz-stage{height:80vh}
    }
</style>
{/literal}

<div class="mt-toolbar">
    <a class="mt-back" href="{$viewHelper->url('styles')}">
        <svg viewBox="0 0 16 16" fill="none"><path d="M10 13L5 8l5-5" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round"/></svg>
        Back to Styles
    </a>
</div>

<header class="mt-page-header mt-cz-head">
    <div>
        <h1 class="mt-page-title">Customizer {include file="includes/doclink.tpl" article="styles" anchor="the-customizer"}</h1>
        <p class="mt-page-subtitle">Try a style, layouts and colours on the real site. Only you see the changes until you save.</p>
    </div>
    <div class="mt-cz-actions">
        <span class="mt-cz-status" data-cz-status role="status"></span>
        <button type="button" class="mt-btn mt-btn-ghost mt-btn-sm" data-cz-discard disabled>Discard</button>
        <button type="button" class="mt-btn mt-btn-primary mt-btn-sm" data-cz-save disabled>Save</button>
    </div>
</header>

<div class="mt-cz" id="mt-cz">
    <aside class="mt-panel mt-cz-side">
        <div class="mt-cz-tabs" role="tablist">
            <button type="button" class="is-on" data-cz-tab="scheme">Style</button>
            <button type="button" data-cz-tab="layouts">Layouts</button>
            <button type="button" data-cz-tab="colors">Colours</button>
        </div>

        <div class="mt-cz-panel" data-cz-panel="scheme">
            <p class="mt-cz-help">A style is a colour palette. Saving makes the selected one active and stores its colours.</p>
            <div data-cz-schemes></div>
        </div>

        <div class="mt-cz-panel" data-cz-panel="layouts" hidden>
            <div data-cz-layouts></div>
            <p class="mt-cz-help" style="margin-top:14px">A page with its own layout set in Pages keeps it.</p>
        </div>

        <div class="mt-cz-panel" data-cz-panel="colors" hidden>
            <div class="mt-cz-scopebar">
                <strong data-cz-scope>Light mode colours</strong>
                <button type="button" class="mt-cz-link" data-cz-reset-all>Reset all to the style</button>
            </div>
            <p class="mt-cz-help">These belong to the selected style. The light / dark switch above the preview chooses which set you edit.</p>
            <div data-cz-colors></div>
        </div>
    </aside>

    <section class="mt-panel mt-cz-stage">
        <div class="mt-cz-bar">
            <select class="mt-select" data-cz-page aria-label="Page to preview"></select>
            <button type="button" class="mt-btn mt-btn-ghost mt-btn-sm" data-cz-reload title="Load the page again">Reload</button>
            <span class="mt-cz-bar-space"></span>
            <div class="mt-cz-seg" data-cz-themes role="group" aria-label="Colour mode">
                <button type="button" data-cz-theme="light">Light</button>
                <button type="button" data-cz-theme="dark">Dark</button>
            </div>
            <div class="mt-cz-seg" role="group" aria-label="Preview width">
                <button type="button" class="is-on" data-cz-device="desktop">Desktop</button>
                <button type="button" data-cz-device="tablet">Tablet</button>
                <button type="button" data-cz-device="phone">Phone</button>
            </div>
        </div>
        <p class="mt-cz-outside" data-cz-outside hidden>This page is outside the preview and shows the saved site. Pick a page above to come back.</p>
        <div class="mt-cz-viewport" data-cz-viewport>
            <iframe data-cz-frame title="Site preview"></iframe>
        </div>
    </section>
</div>

{if !$clientSignedIn}
    <p class="mt-section-note" style="margin-top:14px">
        Client-area pages such as the dashboard need a client session. Use <em>Login as Client</em> from a client's profile in this browser, then reload this screen, and they join the page list.
    </p>
{/if}

<script type="application/json" id="mt-cz-data">{$customizeJson nofilter}</script>
<script>{$customizeJs nofilter}</script>

{include file="includes/footer.tpl"}
