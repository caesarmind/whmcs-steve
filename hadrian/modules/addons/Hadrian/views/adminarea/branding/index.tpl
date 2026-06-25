{include file="includes/header.tpl"}

<header class="mt-page-header">
    <div class="mt-page-eyebrow">Theme</div>
    <h1 class="mt-page-title">Branding</h1>
    <p class="mt-page-subtitle">Upload your logo and favicon. Each file is saved the moment you pick it -- no Save needed.</p>
</header>

{* Server-rendered flash banner -- only shows when the page is reached via
   the form-based fallback path (JS disabled). The AJAX path updates inline
   per-tile and doesn't redirect, so these banners never appear under JS. *}
{if $flash == 'saved'}
    <div class="mt-alert mt-alert-success"><strong>Saved.</strong> Branding has been updated.</div>
{elseif $flash == 'removed'}
    <div class="mt-alert mt-alert-success"><strong>Removed.</strong> The file is gone and the slot is empty.</div>
{elseif $flash == 'partial'}
    <div class="mt-alert mt-alert-warning"><strong>Partially saved.</strong> Some files were rejected -- see the inline errors below.</div>
{elseif $flash == 'errors'}
    <div class="mt-alert mt-alert-danger"><strong>Nothing saved.</strong> Every uploaded file was rejected -- see the inline errors below.</div>
{elseif $flash == 'invalid-field'}
    <div class="mt-alert mt-alert-danger"><strong>Invalid request.</strong> Unknown branding field.</div>
{/if}

{* Top-of-page status line -- populated by the JS after each AJAX upload /
   remove. Stays empty under no-JS (the form-based banners above cover that
   case). aria-live so screen readers announce changes. *}
<div class="mt-branding-status" id="mt-branding-status" aria-live="polite" role="status"></div>

<form method="post" action="?module=Hadrian&action=branding" enctype="multipart/form-data" class="mt-branding-form" id="mt-branding-form">

<div class="mt-panel">
{foreach $sections as $sectionKey => $section}
    <section class="mt-section">
        <header class="mt-section-header"><h2 class="mt-section-title">{$section.title|escape}</h2></header>
        {if $sectionKey == 'favicon'}
            {* Favicon is a single-tile section. *}
            {foreach $section.rows as $row}
                <div style="max-width:320px">
                    {include file="branding/_tile.tpl" row=$row dark=false}
                </div>
            {/foreach}
        {else}
            <div class="mt-upload-pair">
                {foreach $section.rows as $row}
                    {include file="branding/_tile.tpl" row=$row dark=($row.variant == 'dark')}
                {/foreach}
            </div>
        {/if}
    </section>
{/foreach}

{* Brand Info — description + social URLs. Saved via the same form POST
   as the image uploads, so a single "Save changes" click persists
   everything together. Under JS, the AJAX upload path only touches
   $_FILES so these fields are unaffected by per-tile uploads. *}
<section class="mt-section">
    <header class="mt-section-header"><h2 class="mt-section-title">Brand Info</h2></header>
    {if isset($brandInfo.footer_description)}
        {$row = $brandInfo.footer_description}
        <div class="mt-brand-field">
            <label class="mt-brand-label" for="bi-{$row.field}">{$row.label|escape}</label>
            <textarea id="bi-{$row.field}" name="{$row.field}" class="mt-textarea{if $row.error} has-error{/if}" rows="2" maxlength="{$row.maxLen}" placeholder="Premium web hosting on Google Cloud...">{$row.value|escape}</textarea>
            {if $row.error}<div class="mt-upload-error">{$row.error|escape}</div>{else}<div class="mt-brand-help">{$row.help|escape}</div>{/if}
        </div>
    {/if}
    <div class="mt-brand-grid">
        {foreach $brandInfo as $row}
            {if $row.field != 'footer_description'}
                <div class="mt-brand-field">
                    <label class="mt-brand-label" for="bi-{$row.field}">{$row.label|escape}</label>
                    <input id="bi-{$row.field}" type="url" name="{$row.field}" value="{$row.value|escape}" class="mt-input{if $row.error} has-error{/if}" placeholder="https://" maxlength="{$row.maxLen}" inputmode="url" autocomplete="off">
                    {if $row.error}<div class="mt-upload-error">{$row.error|escape}</div>{/if}
                </div>
            {/if}
        {/foreach}
    </div>
</section>
</div>{* .mt-panel *}

    {* The Save button is only useful for no-JS fallback. JS hides it via
       the .is-ajax class added on load -- under JS, every pick auto-uploads.
       Brand Info fields, however, still need the Save button under JS since
       the AJAX path only handles $_FILES. *}
    <div class="mt-branding-save-row" style="display:flex;justify-content:flex-end;gap:8px;margin-top:8px">
        <button type="submit" class="mt-btn mt-btn-primary">Save changes</button>
    </div>
</form>

{* Smarty 4 (WHMCS 9) still parses `{ ... }` inside <style>/<script>
   blocks unless wrapped in {literal}. Auto-literal handling is brittle
   (works for `{` followed by whitespace but chokes on JS object
   literals, regex char classes containing `$`, CSS keyframe ranges,
   etc.) -- wrapping bypasses Smarty entirely for the inline assets. *}
{literal}
<style>
/* Branding-specific add-ons. Reuse mt-upload from footer.tpl; only the
   preview + remove + dark-tile + error + loading states live here. */
.mt-branding-tile {
    display: flex;
    flex-direction: column;
    gap: 8px;
    position: relative;
}
.mt-branding-current {
    position: relative;
    border: 1px solid var(--mt-border);
    border-radius: var(--mt-radius);
    background: var(--mt-surface);
    padding: 16px;
    display: flex;
    align-items: center;
    justify-content: center;
    min-height: 110px;
    overflow: hidden;
}
.mt-branding-current.is-dark { background: #1d1d1f; border-color: #3a3a3c; }
.mt-branding-current img {
    max-width: 100%;
    max-height: 80px;
    display: block;
    object-fit: contain;
}
.mt-branding-overlay {
    position: absolute;
    inset: 0;
    background: rgba(0, 0, 0, 0.45);
    color: #fff;
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 8px;
    opacity: 0;
    transition: opacity 0.15s ease;
}
.mt-branding-current:hover .mt-branding-overlay { opacity: 1; }
.mt-branding-overlay .mt-btn { color: #fff; }
.mt-branding-overlay .mt-btn-secondary { background: rgba(255, 255, 255, 0.12); border-color: rgba(255, 255, 255, 0.35); color: #fff; }
.mt-branding-overlay .mt-btn-secondary:hover { background: rgba(255, 255, 255, 0.2); color: #fff; }
.mt-branding-overlay .mt-btn-danger { background: var(--mt-danger); border-color: var(--mt-danger); color: #fff; }
.mt-branding-overlay .mt-btn-danger:hover { background: #c8231a; color: #fff; }
.mt-upload.is-dark { background: #1d1d1f; border-color: #3a3a3c; }
.mt-upload.is-dark .mt-upload-icon { color: #86868b; }
.mt-upload.is-dark .mt-upload-text { color: #f5f5f7; }
.mt-upload.is-dark .mt-upload-hint { color: #86868b; }
.mt-upload.has-error,
.mt-upload.is-dark.has-error { border-color: var(--mt-danger); background: var(--mt-danger-tint); }
.mt-upload-error {
    font-size: 12px;
    color: var(--mt-danger-text);
    background: var(--mt-danger-tint);
    border: 1px solid rgba(255, 59, 48, 0.25);
    border-radius: var(--mt-radius-sm);
    padding: 6px 10px;
    line-height: 1.4;
}
.mt-upload-file-meta {
    font-size: 11px;
    color: var(--mt-text-3);
    font-family: ui-monospace, "SF Mono", Menlo, Consolas, monospace;
    text-align: center;
    word-break: break-all;
}

/* ---------------- Loading state (injected by JS) ---------------- */
/* Covers the upload area (label OR preview) while an AJAX upload is
   in flight. Positioned absolute so we don't disturb the tile's flex
   layout -- the caption + error below stay where they are. */
.mt-tile-loading {
    position: absolute;
    top: 0; left: 0; right: 0;
    /* Cover only the upload-area height, not the caption/error below.
       110px matches .mt-upload min-height and .mt-branding-current min-height. */
    min-height: 110px;
    background: rgba(255, 255, 255, 0.92);
    backdrop-filter: blur(2px);
    border: 1px solid var(--mt-primary);
    border-radius: var(--mt-radius);
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    gap: 8px;
    padding: 12px 16px;
    z-index: 2;
    animation: mt-tile-loading-in 0.15s ease-out;
}
.mt-branding-tile[data-variant="dark"] .mt-tile-loading {
    background: rgba(29, 29, 31, 0.92);
    border-color: var(--mt-primary);
    color: #f5f5f7;
}
@keyframes mt-tile-loading-in {
    from { opacity: 0; transform: translateY(2px); }
    to   { opacity: 1; transform: translateY(0); }
}
.mt-tile-spinner {
    width: 20px;
    height: 20px;
    border: 2px solid var(--mt-border);
    border-top-color: var(--mt-primary);
    border-radius: 50%;
    animation: mt-spin 0.7s linear infinite;
}
.mt-branding-tile[data-variant="dark"] .mt-tile-spinner {
    border-color: rgba(255, 255, 255, 0.18);
    border-top-color: var(--mt-primary);
}
@keyframes mt-spin { to { transform: rotate(360deg); } }
.mt-tile-loading-text {
    font-size: 12px;
    color: var(--mt-text-2);
    font-weight: 500;
    max-width: 90%;
    text-align: center;
    word-break: break-all;
}
.mt-branding-tile[data-variant="dark"] .mt-tile-loading-text { color: #aeaeb2; }
.mt-tile-progress {
    width: 80%;
    height: 4px;
    background: var(--mt-border);
    border-radius: 999px;
    overflow: hidden;
}
.mt-tile-progress-bar {
    height: 100%;
    background: var(--mt-primary);
    width: 0%;
    transition: width 0.12s linear;
}

/* Brand Info section — text/URL fields rendered below the image tiles. */
.mt-brand-field { display: flex; flex-direction: column; gap: 6px; margin-bottom: 14px; }
.mt-brand-label { font-size: 13px; font-weight: 500; color: var(--mt-text); }
.mt-brand-help { font-size: 12px; color: var(--mt-text-3); }
.mt-brand-grid { display: grid; grid-template-columns: repeat(2, 1fr); gap: 14px 18px; margin-top: 4px; }
.mt-brand-grid .mt-brand-field { margin-bottom: 0; }
.mt-input.has-error, .mt-textarea.has-error { border-color: var(--mt-danger); background: var(--mt-danger-tint); }
@media (max-width: 720px) { .mt-brand-grid { grid-template-columns: 1fr; } }
/* The Save row used to be hidden under .is-ajax — but the new Brand Info
   section needs an explicit submit, so we keep it visible at all times.
   Image uploads still happen instantly via the AJAX path; clicking Save
   with no pending file selection is a harmless re-POST of the text vals. */

/* Top-of-page status banner -- populated by JS after each operation. */
.mt-branding-status:empty { display: none; }
.mt-branding-status {
    padding: 10px 14px;
    border-radius: var(--mt-radius-sm);
    font-size: 13px;
    margin-bottom: 16px;
    border: 1px solid transparent;
    transition: opacity 0.2s ease;
}
.mt-branding-status.is-success {
    background: var(--mt-success-tint);
    border-color: rgba(48,209,88,0.25);
    color: var(--mt-success-text);
}
.mt-branding-status.is-error {
    background: var(--mt-danger-tint);
    border-color: rgba(255,59,48,0.25);
    color: var(--mt-danger-text);
}
</style>

<script>
(function () {
    'use strict';

    var form = document.getElementById('mt-branding-form');
    if (!form || !window.FormData || !window.XMLHttpRequest) {
        // No fetch/FormData/XHR (very old browser) -- fall back to the
        // form-based path: admin picks files, clicks Save changes.
        return;
    }

    var UPLOAD_URL = '?module=Hadrian&action=branding&sub=upload-ajax';
    var REMOVE_URL = '?module=Hadrian&action=branding&sub=remove-ajax';
    var STATUS     = document.getElementById('mt-branding-status');

    // Mark the form as AJAX-active -- CSS hides the Save button.
    form.classList.add('is-ajax');

    // WHMCS auto-injects a hidden <input name="token" value="..."> into
    // every server-rendered POST <form>. Grab the first one we can find
    // and piggyback it on every AJAX POST so WHMCS's CSRF middleware
    // doesn't reject the request. The token rotates per session but is
    // stable across this page load.
    function getCsrfToken() {
        var t = document.querySelector('input[name="token"]');
        return t ? t.value : '';
    }

    // ---- helpers ----

    function escapeHtml(s) {
        return String(s).replace(/[<>&"']/g, function (c) {
            return { '<': '&lt;', '>': '&gt;', '&': '&amp;', '"': '&quot;', "'": '&#39;' }[c];
        });
    }

    function tileFor(field) {
        // Query document, not the form. HTML5 forbids nested forms, and any
        // future template change that re-introduces one would silently close
        // the outer form and strand later tiles outside it -- form-scoped
        // queries would miss them. document-scoped is robust to that.
        return document.querySelector('.mt-branding-tile[data-field="' + cssEscape(field) + '"]');
    }

    // CSS.escape polyfill (only used for our hex field names, but defensive).
    function cssEscape(s) {
        if (window.CSS && typeof window.CSS.escape === 'function') return CSS.escape(s);
        return String(s).replace(/[^a-zA-Z0-9_-]/g, '\\$&');
    }

    function setStatus(message, kind) {
        if (!STATUS) return;
        STATUS.textContent = message;
        STATUS.className = 'mt-branding-status' + (kind ? ' is-' + kind : '');
        if (kind === 'success' && message) {
            // Auto-clear success after 4s; errors stay until next action.
            setTimeout(function () {
                if (STATUS.textContent === message) {
                    STATUS.textContent = '';
                    STATUS.className = 'mt-branding-status';
                }
            }, 4000);
        }
    }

    function clearTileError(tile) {
        var err = tile.querySelector('.mt-upload-error');
        if (err) err.remove();
        var label = tile.querySelector('.mt-upload');
        if (label) label.classList.remove('has-error');
    }

    function setTileError(tile, message) {
        clearTileError(tile);
        var err = document.createElement('div');
        err.className = 'mt-upload-error';
        err.textContent = message;
        tile.appendChild(err);
        var label = tile.querySelector('.mt-upload');
        if (label) label.classList.add('has-error');
    }

    function showLoading(tile, filename) {
        clearTileError(tile);
        var existing = tile.querySelector('.mt-tile-loading');
        if (existing) existing.remove();
        var overlay = document.createElement('div');
        overlay.className = 'mt-tile-loading';
        overlay.innerHTML =
            '<div class="mt-tile-spinner" aria-hidden="true"></div>' +
            '<div class="mt-tile-loading-text"></div>' +
            '<div class="mt-tile-progress"><div class="mt-tile-progress-bar"></div></div>';
        overlay.querySelector('.mt-tile-loading-text').textContent =
            filename ? 'Uploading ' + filename + '...' : 'Working...';
        tile.appendChild(overlay);
    }

    function setProgress(tile, pct) {
        var bar = tile.querySelector('.mt-tile-progress-bar');
        if (bar) bar.style.width = Math.max(0, Math.min(100, pct)) + '%';
    }

    function clearLoading(tile) {
        var overlay = tile.querySelector('.mt-tile-loading');
        if (overlay) overlay.remove();
    }

    function renderFilled(tile, payload) {
        var field    = tile.getAttribute('data-field');
        var label    = tile.getAttribute('data-label');
        var accept   = tile.getAttribute('data-accept');
        var isDark   = tile.getAttribute('data-variant') === 'dark';

        // Build the filled state. NB: we deliberately do NOT emit a form
        // tag from JS here. WHMCS's admin output filter regex-scans the
        // response for opening POST forms and auto-injects a hidden CSRF
        // token field right after the opening tag -- even when the form
        // text happens to live inside a JS string literal or a JS
        // comment (the regex is content-blind). The injection lands
        // inside our quote-delimited string, breaking it across two
        // physical lines, and the JS parser throws "Invalid or
        // unexpected token". Using a plain button[data-remove] with a JS
        // click handler avoids the regex match entirely. The server-
        // rendered _tile.tpl still has the form for no-JS fallback
        // (that one gets the token legitimately and submits normally).
        tile.innerHTML =
            '<div class="mt-branding-current' + (isDark ? ' is-dark' : '') + '">' +
                '<img src="' + escapeHtml(payload.url) + '" alt="' + escapeHtml(label) + '">' +
                '<div class="mt-branding-overlay">' +
                    '<label class="mt-btn mt-btn-secondary mt-btn-sm" for="upload-' + escapeHtml(field) + '" style="cursor:pointer">Replace</label>' +
                    '<button type="button" class="mt-btn mt-btn-danger mt-btn-sm" data-remove="' + escapeHtml(field) + '">Remove</button>' +
                '</div>' +
            '</div>' +
            '<input id="upload-' + escapeHtml(field) + '" type="file" name="' + escapeHtml(field) + '" accept="' + escapeHtml(accept) + '" hidden data-upload="' + escapeHtml(field) + '">' +
            '<div class="mt-upload-file-meta">' + escapeHtml(payload.filename) + '</div>' +
            '<div class="mt-upload-caption">' + escapeHtml(label) + '</div>';

        bindTile(tile);
    }

    function renderEmpty(tile) {
        var field    = tile.getAttribute('data-field');
        var label    = tile.getAttribute('data-label');
        var help     = tile.getAttribute('data-help');
        var accept   = tile.getAttribute('data-accept');
        var maxHuman = tile.getAttribute('data-max-human');
        var isDark   = tile.getAttribute('data-variant') === 'dark';

        tile.innerHTML =
            '<label class="mt-upload' + (isDark ? ' is-dark' : '') + '" for="upload-' + escapeHtml(field) + '">' +
                '<svg class="mt-upload-icon" width="32" height="32" viewBox="0 0 40 40" fill="none">' +
                    '<path d="M20 6v22M11 15l9-9 9 9M6 28v3a3 3 0 003 3h22a3 3 0 003-3v-3" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>' +
                '</svg>' +
                '<div class="mt-upload-text">Click to upload</div>' +
                '<div class="mt-upload-hint">' + escapeHtml(help) + ' - max ' + escapeHtml(maxHuman) + '</div>' +
                '<input id="upload-' + escapeHtml(field) + '" type="file" name="' + escapeHtml(field) + '" accept="' + escapeHtml(accept) + '" hidden data-upload="' + escapeHtml(field) + '">' +
            '</label>' +
            '<div class="mt-upload-caption">' + escapeHtml(label) + '</div>';

        bindTile(tile);
    }

    // ---- upload / remove ----

    function doUpload(input) {
        var field = input.getAttribute('data-upload') || input.name;
        var file  = input.files && input.files[0];
        if (!field || !file) return;
        var tile = tileFor(field);
        if (!tile) return;

        showLoading(tile, file.name);
        setStatus('', '');

        var data = new FormData();
        data.append('field', field);
        data.append('file',  file);
        data.append('token', getCsrfToken());

        var xhr = new XMLHttpRequest();
        xhr.open('POST', UPLOAD_URL, true);
        xhr.responseType = 'text';

        xhr.upload.onprogress = function (e) {
            if (e.lengthComputable) {
                setProgress(tile, (e.loaded / e.total) * 100);
            }
        };

        xhr.onload = function () {
            clearLoading(tile);
            // Clear the file input so a subsequent fallback form-submit
            // wouldn't re-upload the same file.
            try { input.value = ''; } catch (e) {}

            var res;
            try { res = JSON.parse(xhr.responseText); }
            catch (e) {
                setTileError(tile, 'Server returned a non-JSON response (HTTP ' + xhr.status + ').');
                setStatus('Upload failed -- see the inline error.', 'error');
                return;
            }
            if (!res || !res.ok) {
                setTileError(tile, (res && res.error) || 'Upload failed.');
                setStatus('Upload failed -- see the inline error.', 'error');
                return;
            }
            renderFilled(tile, res);
            setStatus('Saved "' + (res.label || field) + '".', 'success');
        };

        xhr.onerror = function () {
            clearLoading(tile);
            setTileError(tile, 'Network error -- please retry.');
            setStatus('Upload failed -- network error.', 'error');
        };

        xhr.send(data);
    }

    function doRemove(field) {
        var tile = tileFor(field);
        if (!tile) return;

        showLoading(tile, '');
        setStatus('', '');

        var data = new FormData();
        data.append('field', field);
        data.append('token', getCsrfToken());

        var xhr = new XMLHttpRequest();
        xhr.open('POST', REMOVE_URL, true);
        xhr.onload = function () {
            clearLoading(tile);
            var res;
            try { res = JSON.parse(xhr.responseText); }
            catch (e) {
                setTileError(tile, 'Server returned a non-JSON response (HTTP ' + xhr.status + ').');
                setStatus('Remove failed -- see the inline error.', 'error');
                return;
            }
            if (!res || !res.ok) {
                setTileError(tile, (res && res.error) || 'Remove failed.');
                setStatus('Remove failed -- see the inline error.', 'error');
                return;
            }
            renderEmpty(tile);
            setStatus('Removed "' + (tile.getAttribute('data-label') || field) + '".', 'success');
        };
        xhr.onerror = function () {
            clearLoading(tile);
            setTileError(tile, 'Network error -- please retry.');
            setStatus('Remove failed -- network error.', 'error');
        };
        xhr.send(data);
    }

    // ---- event binding ----

    function bindTile(tile) {
        // File input change -> AJAX upload.
        var input = tile.querySelector('input[type="file"][data-upload]');
        if (input && !input.hasAttribute('data-bound')) {
            input.setAttribute('data-bound', '1');
            input.addEventListener('change', function () { doUpload(input); });
        }
        // Remove button click -> confirm -> AJAX remove.
        // We intercept the click (not the form submit) so we can keep the
        // <form> for no-JS fallback. preventDefault stops the submit.
        var btn = tile.querySelector('[data-remove]');
        if (btn && !btn.hasAttribute('data-bound')) {
            btn.setAttribute('data-bound', '1');
            btn.addEventListener('click', function (e) {
                e.preventDefault();
                var field = btn.getAttribute('data-remove');
                if (!field) return;
                var label = tile.getAttribute('data-label') || field;
                if (!confirm('Remove the ' + label + ' file?')) return;
                doRemove(field);
            });
        }
    }

    // Initial bind across every tile. document-scoped (not form-scoped):
    // until just now _tile.tpl emitted a nested <form> for the no-JS Remove
    // fallback, which browsers respond to by silently closing the outer
    // form at the inner <form> opening tag. That stranded the square-logo
    // and favicon tiles outside the outer form, so a form-scoped query
    // missed them entirely and their change handlers never bound -- the
    // tiles looked dead even though the file picker would open. We've
    // removed the nested form, but document-scoping the lookup defends
    // against the same shape of bug if anything similar regresses.
    Array.prototype.forEach.call(
        document.querySelectorAll('.mt-branding-tile'),
        bindTile
    );
})();
</script>
{/literal}

{include file="includes/footer.tpl"}
