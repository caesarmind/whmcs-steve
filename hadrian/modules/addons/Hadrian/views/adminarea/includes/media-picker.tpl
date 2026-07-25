{*
    Media picker — ONE modal shared by every image field in the admin.

    Opt in from any text input by adding data-mt-media:

      <input type="text" name="seo_social_image" class="mt-input"
             data-mt-media
             data-mt-media-value="url"          {* url | filename *}
             data-mt-media-collection="library"
             data-mt-media-title="Social image"
             data-mt-media-hint="1200 x 630 recommended">

    The presence of data-mt-media is the ONLY switch — a single delegated
    listener upgrades matching inputs, including any injected after load.
    The picker only ever sets input.value and dispatches input + change, so
    the owning form's save path is untouched and no-JS degrades to a plain
    typeable URL field.

    Included from includes/footer.tpl INSIDE .mt-wrap so it inherits the
    --mt-* tokens; the script then relocates the modal to document.body
    (the same idiom as .mt-selpop / .mt-tip-pop) so position:fixed is immune
    to a transformed ancestor and it can never end up owned by a form
    element. Note the deliberate avoidance of a literal opening form tag
    anywhere in this file, including comments -- see the JS header below.
*}
<div class="mt-modal mt-media-modal" id="mt-media-modal" hidden>
    <div class="mt-modal-card" role="dialog" aria-modal="true" aria-labelledby="mt-media-title">
        <div class="mt-modal-head">
            <div>
                {* The heading text lives in its own span because the script
                   rewrites it per field; setting textContent on the row itself
                   would delete the tip button along with the old text. The tip
                   popup is body-appended at z-index 10000 and this modal is
                   2000, so it correctly paints above the dialog. *}
                <div class="mt-modal-title mt-tip-line">
                    <span id="mt-media-title">Media</span>
                    {include file="includes/tip.tpl" text="One shared library for the whole admin. Uploads stay here until you delete them, and the same image can be used on any number of pages."}
                </div>
                <div class="mt-modal-sub" id="mt-media-sub">Choose an image or upload a new one.</div>
            </div>
            <button type="button" class="mt-modal-x" id="mt-media-x" aria-label="Close">&times;</button>
        </div>

        <div class="mt-tabs mt-media-tabs" role="tablist">
            <button type="button" class="mt-tab is-active" data-mtab="library" role="tab" aria-selected="true">Library<span class="mt-media-tabcount" id="mt-media-count"></span></button>
            <button type="button" class="mt-tab" data-mtab="upload" role="tab" aria-selected="false">Upload</button>
        </div>

        <div class="mt-modal-tools" id="mt-media-tools">
            {* No name= on the filter: it is UI only and must never post. Enter
               is trapped in the JS or it would submit the owning page form. *}
            <input type="text" class="mt-input" id="mt-media-filter" placeholder="Filter images&hellip;" autocomplete="off">
            <div class="mt-modal-tools-gap"></div>
            <span class="mt-media-footinfo" id="mt-media-limits"></span>
        </div>

        <div class="mt-modal-body">
            <div class="mt-media-status" id="mt-media-status" role="status" aria-live="polite"></div>

            <div class="mt-media-pane" id="mt-media-pane-library">
                <div class="mt-media-grid" id="mt-media-grid" role="listbox" aria-label="Media library"></div>
                <div class="mt-empty" id="mt-media-empty" hidden>
                    <div class="mt-empty-icon mt-empty-icon-circle" aria-hidden="true">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="3" width="18" height="18" rx="2"/><circle cx="8.5" cy="8.5" r="1.5"/><path d="M21 15l-5-5L5 21"/></svg>
                    </div>
                    <h3 class="mt-empty-title" id="mt-media-empty-title">No images yet</h3>
                    <p id="mt-media-empty-sub">Upload one to get started.</p>
                    <p><button type="button" class="mt-btn mt-btn-primary mt-btn-sm" id="mt-media-empty-cta">Upload an image</button></p>
                </div>
            </div>

            <div class="mt-media-pane" id="mt-media-pane-upload" hidden>
                {* admin.css hides input[type=file] outright, so the label IS
                   the control — clicking it opens the picker natively. *}
                <label class="mt-upload mt-media-drop" id="mt-media-drop" for="mt-media-file">
                    <svg class="mt-upload-icon" width="32" height="32" viewBox="0 0 40 40" fill="none">
                        <path d="M20 6v22M11 15l9-9 9 9M6 28v3a3 3 0 003 3h22a3 3 0 003-3v-3" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
                    </svg>
                    <div class="mt-upload-text">Click to upload, or drop images here</div>
                    <div class="mt-upload-hint" id="mt-media-accepthint"></div>
                    <input type="file" id="mt-media-file" multiple hidden>
                </label>
                <div class="mt-media-queue" id="mt-media-queue"></div>
            </div>
        </div>

        <div class="mt-modal-foot">
            <span class="mt-media-footinfo" id="mt-media-selinfo"></span>
            <button type="button" class="mt-btn mt-btn-secondary mt-btn-sm" id="mt-media-cancel">Cancel</button>
            <button type="button" class="mt-btn mt-btn-primary mt-btn-sm" id="mt-media-use" disabled>Use image</button>
        </div>
    </div>
</div>

{literal}
<script>
/* Media picker controller.

   NOTE: no string in this file may contain a literal opening form tag — the
   WHMCS admin output filter regex-scans the response for one and injects a
   hidden CSRF field after it, content-blind, which lands inside the JS string
   and breaks the parse. (Same hazard documented in branding/index.tpl.)

   Everything server-derived enters the DOM via textContent or a src built
   only from the server's own url field; nothing is interpolated into
   innerHTML. A filename that arrived out of band by FTP must not be able to
   inject into this UI. */
(function () {
    'use strict';

    var modal = document.getElementById('mt-media-modal');
    if (!modal || !window.FormData || !window.XMLHttpRequest) return;

    var root = document.getElementById('mt-admin-root');

    // Relocate to <body>: escapes any ancestor transform/overflow and
    // guarantees the dialog is never inside a form. Carry .mt-wrap so the
    // --mt-* tokens resolve, and mirror the theme for dark mode.
    modal.classList.add('mt-wrap');
    modal.setAttribute('data-theme', (root && root.getAttribute('data-theme')) || 'light');
    document.body.appendChild(modal);

    var UI = {
        card:    modal.querySelector('.mt-modal-card'),
        title:   document.getElementById('mt-media-title'),
        sub:     document.getElementById('mt-media-sub'),
        count:   document.getElementById('mt-media-count'),
        filter:  document.getElementById('mt-media-filter'),
        limits:  document.getElementById('mt-media-limits'),
        status:  document.getElementById('mt-media-status'),
        grid:    document.getElementById('mt-media-grid'),
        empty:   document.getElementById('mt-media-empty'),
        emptyT:  document.getElementById('mt-media-empty-title'),
        emptyS:  document.getElementById('mt-media-empty-sub'),
        emptyC:  document.getElementById('mt-media-empty-cta'),
        paneLib: document.getElementById('mt-media-pane-library'),
        paneUp:  document.getElementById('mt-media-pane-upload'),
        drop:    document.getElementById('mt-media-drop'),
        file:    document.getElementById('mt-media-file'),
        queue:   document.getElementById('mt-media-queue'),
        accept:  document.getElementById('mt-media-accepthint'),
        selinfo: document.getElementById('mt-media-selinfo'),
        use:     document.getElementById('mt-media-use'),
        cancel:  document.getElementById('mt-media-cancel'),
        x:       document.getElementById('mt-media-x'),
        tools:   document.getElementById('mt-media-tools')
    };

    var state = {
        input: null, opener: null, collection: 'library', valueMode: 'url',
        items: [], selected: null, deletable: true, accept: '', maxBytes: 0,
        loaded: false, inflight: 0
    };

    // ---- transport ----

    function csrf() {
        var t = document.querySelector('input[name="token"]');
        return t ? t.value : '';
    }
    function post(sub, data, done, fail) {
        var xhr = new XMLHttpRequest();
        xhr.open('POST', '?module=Hadrian&action=media&sub=' + sub, true);
        xhr.setRequestHeader('X-Requested-With', 'XMLHttpRequest');
        xhr.onload = function () {
            var res;
            try { res = JSON.parse(xhr.responseText); }
            catch (e) {
                // The fingerprint of the hooks.php gate not matching: the
                // request fell through and we got admin HTML back.
                fail('Server returned a non-JSON response (HTTP ' + xhr.status + ').');
                return;
            }
            if (!res || !res.ok) { fail((res && res.error) || 'Request failed.'); return; }
            done(res);
        };
        xhr.onerror = function () { fail('Network error - please retry.'); };
        data.append('collection', state.collection);
        data.append('token', csrf());
        xhr.send(data);
        return xhr;
    }
    function say(msg, kind) {
        UI.status.textContent = msg || '';
        UI.status.className = 'mt-media-status' + (kind ? ' is-' + kind : '');
    }

    // ---- rendering ----

    function el(tag, cls, text) {
        var n = document.createElement(tag);
        if (cls) n.className = cls;
        if (text !== undefined && text !== null) n.textContent = text;
        return n;
    }

    function tile(item) {
        var b = el('button', 'mt-media-tile');
        b.type = 'button';
        b.setAttribute('role', 'option');
        b.setAttribute('aria-selected', 'false');
        b.setAttribute('data-name', item.name);
        b.title = item.label;

        var thumb = el('span', 'mt-media-thumb');
        var img = document.createElement('img');
        img.loading = 'lazy';
        img.alt = '';
        img.src = item.url;                     // server-built path only
        // Dimensions come off the loaded image, so the server never has to
        // open 500 files to answer a list.
        img.addEventListener('load', function () {
            if (img.naturalWidth) {
                dims.textContent = img.naturalWidth + ' x ' + img.naturalHeight + '  ' + item.human;
            }
        });
        thumb.appendChild(img);

        var meta = el('span', 'mt-media-meta');
        var name = el('span', 'mt-media-name', item.label);
        var dims = el('span', 'mt-media-dims', item.human);
        meta.appendChild(name);
        meta.appendChild(dims);

        b.appendChild(thumb);
        b.appendChild(meta);
        b.appendChild(el('span', 'mt-media-radio'));

        if (state.deletable) {
            var del = el('button', 'mt-media-del', '×');
            del.type = 'button';
            del.setAttribute('aria-label', 'Delete ' + item.label);
            del.addEventListener('click', function (e) {
                e.stopPropagation();
                confirmDelete(b, item);
            });
            b.appendChild(del);
        }

        b.addEventListener('click', function () { select(item.name); });
        b.addEventListener('dblclick', function () { select(item.name); commit(); });
        return b;
    }

    function skeletons(n) {
        UI.grid.textContent = '';
        for (var i = 0; i < n; i++) {
            var s = el('div', 'mt-media-skel');
            s.appendChild(el('div', 'mt-media-skel-thumb'));
            s.appendChild(el('div', 'mt-media-skel-line'));
            UI.grid.appendChild(s);
        }
    }

    function paint() {
        UI.grid.textContent = '';
        state.items.forEach(function (it) { UI.grid.appendChild(tile(it)); });
        UI.count.textContent = state.items.length ? ' ' + state.items.length : '';
        applyFilter();
        if (state.selected) markSelected();
    }

    function applyFilter() {
        var q = (UI.filter.value || '').trim().toLowerCase();
        var shown = 0;
        Array.prototype.forEach.call(UI.grid.children, function (node) {
            if (!node.classList.contains('mt-media-tile')) return;
            var it = byName(node.getAttribute('data-name'));
            var hay = it ? (it.label + ' ' + it.name).toLowerCase() : '';
            var ok = !q || hay.indexOf(q) !== -1;
            node.hidden = !ok;
            if (ok) shown++;
        });
        var none = state.items.length === 0;
        UI.empty.hidden = !(none || shown === 0);
        if (!UI.empty.hidden) {
            if (none) {
                UI.emptyT.textContent = 'No images yet';
                UI.emptyS.textContent = 'Upload one to get started.';
                UI.emptyC.hidden = false;
            } else {
                UI.emptyT.textContent = 'No images match "' + q + '"';
                UI.emptyS.textContent = 'Try a different search term.';
                UI.emptyC.hidden = true;
            }
        }
    }

    function byName(n) {
        for (var i = 0; i < state.items.length; i++) if (state.items[i].name === n) return state.items[i];
        return null;
    }

    function markSelected() {
        Array.prototype.forEach.call(UI.grid.children, function (node) {
            if (!node.classList.contains('mt-media-tile')) return;
            var on = node.getAttribute('data-name') === state.selected;
            node.setAttribute('aria-selected', on ? 'true' : 'false');
        });
        var it = byName(state.selected);
        UI.use.disabled = !it;
        UI.selinfo.textContent = it ? it.label : '';
    }

    function select(name) {
        state.selected = name;
        markSelected();
    }

    // ---- load ----

    function load(cb) {
        skeletons(8);
        say('');
        post('list', new FormData(), function (res) {
            state.items     = res.items || [];
            state.deletable = !!res.deletable;
            state.accept    = res.accept || '';
            state.maxBytes  = res.maxBytes || 0;
            state.loaded    = true;
            UI.file.setAttribute('accept', state.accept);
            UI.accept.textContent = 'PNG, JPG, GIF or WebP - max ' + (res.maxHuman || '');
            UI.limits.textContent = res.total + (res.total === 1 ? ' image' : ' images');
            paint();
            if (cb) cb();
        }, function (err) {
            UI.grid.textContent = '';
            say(err, 'error');
        });
    }

    // ---- delete ----

    function confirmDelete(tileEl, item) {
        if (tileEl.querySelector('.mt-media-confirm')) return;
        var box = el('div', 'mt-media-confirm');
        box.appendChild(el('div', 'mt-media-confirm-text', 'Delete "' + item.label + '"?'));
        var row = el('div', 'mt-media-confirm-row');
        var no  = el('button', 'mt-btn mt-btn-secondary mt-btn-sm', 'Cancel');
        var yes = el('button', 'mt-btn mt-btn-danger mt-btn-sm', 'Delete');
        no.type = 'button'; yes.type = 'button';
        no.addEventListener('click', function (e) { e.stopPropagation(); box.remove(); });
        yes.addEventListener('click', function (e) { e.stopPropagation(); doDelete(item, box); });
        row.appendChild(no); row.appendChild(yes);
        box.appendChild(row);
        box.addEventListener('click', function (e) { e.stopPropagation(); });
        tileEl.appendChild(box);
        yes.focus();
    }

    function doDelete(item, box) {
        var fd = new FormData();
        fd.append('name[]', item.name);
        post('delete', fd, function (res) {
            var outcome = (res.results && res.results[item.name]) || 'unknown';
            if (outcome === 'deleted' || outcome === 'not-found') {
                state.items = state.items.filter(function (i) { return i.name !== item.name; });
                if (state.selected === item.name) { state.selected = null; }
                paint();
                markSelected();
                UI.limits.textContent = state.items.length + (state.items.length === 1 ? ' image' : ' images');
                // Housekeeping must never silently rewrite a saved value.
                if (state.input && state.input.value && state.input.value.indexOf(item.name) !== -1) {
                    say('Deleted. The field still points at that file - pick another image before saving.', 'error');
                } else {
                    say('Deleted "' + item.label + '".', 'ok');
                }
            } else {
                if (box) box.remove();
                say('Could not delete "' + item.label + '" (' + outcome + ').', 'error');
            }
        }, function (err) {
            if (box) box.remove();
            say(err, 'error');
        });
    }

    // ---- upload ----

    function humanBytes(b) {
        if (b < 1024) return b + ' B';
        if (b < 1048576) return Math.round(b / 1024) + ' KB';
        return (b / 1048576).toFixed(1) + ' MB';
    }

    function enqueue(files) {
        if (!files || !files.length) return;
        tab('upload');
        Array.prototype.forEach.call(files, function (f) { uploadOne(f); });
    }

    function uploadOne(file) {
        var row = el('div', 'mt-media-q');
        row.appendChild(el('div', 'mt-media-q-name', file.name));
        var st = el('div', 'mt-media-q-state', 'Waiting');
        row.appendChild(st);
        var bar = el('div', 'mt-media-q-bar');
        var fill = el('div', 'mt-media-q-fill');
        bar.appendChild(fill);
        row.appendChild(bar);
        UI.queue.appendChild(row);

        if (state.maxBytes && file.size > state.maxBytes) {
            row.classList.add('is-error');
            st.textContent = 'Too large (' + humanBytes(file.size) + ')';
            return;
        }

        var fd = new FormData();
        fd.append('file', file);
        st.textContent = 'Uploading';
        state.inflight++;

        var xhr = new XMLHttpRequest();
        xhr.open('POST', '?module=Hadrian&action=media&sub=upload', true);
        xhr.setRequestHeader('X-Requested-With', 'XMLHttpRequest');
        xhr.upload.onprogress = function (e) {
            if (e.lengthComputable) fill.style.width = ((e.loaded / e.total) * 100) + '%';
        };
        xhr.onload = function () {
            state.inflight--;
            var res;
            try { res = JSON.parse(xhr.responseText); }
            catch (e) {
                row.classList.add('is-error');
                st.textContent = 'Server returned a non-JSON response (HTTP ' + xhr.status + ').';
                return;
            }
            if (!res || !res.ok) {
                row.classList.add('is-error');
                st.textContent = res && res.error ? res.error : 'Upload failed.';
                return;
            }
            row.classList.add('is-done');
            st.textContent = 'Done';
            fill.style.width = '100%';
            state.items.unshift(res.item);
            paint();
            select(res.item.name);
            UI.limits.textContent = state.items.length + (state.items.length === 1 ? ' image' : ' images');
            if (state.inflight === 0) {
                // Hand back to the library once the queue drains, with the
                // last upload already selected.
                setTimeout(function () {
                    if (state.inflight !== 0) return;
                    tab('library');
                    var node = UI.grid.querySelector('[data-name="' + cssEscape(res.item.name) + '"]');
                    if (node) { node.scrollIntoView({ block: 'nearest' }); node.focus(); }
                }, 500);
            }
        };
        xhr.onerror = function () {
            state.inflight--;
            row.classList.add('is-error');
            st.textContent = 'Network error.';
        };
        fd.append('collection', state.collection);
        fd.append('token', csrf());
        xhr.send(fd);
    }

    function cssEscape(s) {
        if (window.CSS && typeof window.CSS.escape === 'function') return CSS.escape(s);
        return String(s).replace(/[^a-zA-Z0-9_-]/g, '\\$&');
    }

    // ---- tabs ----

    function tab(which) {
        Array.prototype.forEach.call(modal.querySelectorAll('.mt-media-tabs .mt-tab'), function (t) {
            var on = t.getAttribute('data-mtab') === which;
            t.classList.toggle('is-active', on);
            t.setAttribute('aria-selected', on ? 'true' : 'false');
        });
        UI.paneLib.hidden = which !== 'library';
        UI.paneUp.hidden  = which !== 'upload';
        UI.tools.hidden   = which !== 'library';
    }

    // ---- open / close ----

    function open(input) {
        state.input      = input;
        state.opener     = input;
        state.collection = input.getAttribute('data-mt-media-collection') || 'library';
        state.valueMode  = input.getAttribute('data-mt-media-value') || 'url';
        state.selected   = null;

        UI.title.textContent = input.getAttribute('data-mt-media-title') || 'Media';
        UI.sub.textContent   = input.getAttribute('data-mt-media-hint') || 'Choose an image or upload a new one.';
        UI.filter.value = '';
        UI.queue.textContent = '';
        UI.use.disabled = true;
        UI.selinfo.textContent = '';
        modal.setAttribute('data-theme', (root && root.getAttribute('data-theme')) || 'light');
        modal.hidden = false;
        tab('library');
        load(function () {
            // Pre-select whatever the field already points at.
            var cur = (input.value || '').trim();
            if (!cur) return;
            for (var i = 0; i < state.items.length; i++) {
                if (cur.indexOf(state.items[i].name) !== -1) { select(state.items[i].name); break; }
            }
        });
        UI.filter.focus();
    }

    function close() {
        modal.hidden = true;
        if (state.opener && state.opener.focus) {
            var well = state.opener.parentNode && state.opener.parentNode.querySelector('[data-mt-media-open]');
            (well || state.opener).focus();
        }
        state.input = null;
    }

    function commit() {
        var it = byName(state.selected);
        if (!it || !state.input) return;
        state.input.value = state.valueMode === 'filename' ? it.name : (it.absUrl || it.url);
        // Bubbling so the field's own listeners (char counter, well preview)
        // react exactly as they would to typing.
        state.input.dispatchEvent(new Event('input',  { bubbles: true }));
        state.input.dispatchEvent(new Event('change', { bubbles: true }));
        close();
    }

    // ---- wiring ----

    UI.use.addEventListener('click', commit);
    UI.cancel.addEventListener('click', close);
    UI.x.addEventListener('click', close);
    UI.emptyC.addEventListener('click', function () { tab('upload'); });
    modal.addEventListener('click', function (e) { if (e.target === modal) close(); });
    UI.card.addEventListener('click', function (e) { e.stopPropagation(); });

    Array.prototype.forEach.call(modal.querySelectorAll('.mt-media-tabs .mt-tab'), function (t) {
        t.addEventListener('click', function () { tab(t.getAttribute('data-mtab')); });
    });

    UI.filter.addEventListener('input', applyFilter);
    UI.filter.addEventListener('keydown', function (e) {
        // The picker lives outside any form now, but a stray Enter should
        // still filter rather than do nothing surprising.
        if (e.key === 'Enter') { e.preventDefault(); applyFilter(); }
    });

    UI.file.addEventListener('change', function () {
        enqueue(UI.file.files);
        try { UI.file.value = ''; } catch (e) {}
    });

    ['dragenter', 'dragover'].forEach(function (ev) {
        UI.drop.addEventListener(ev, function (e) { e.preventDefault(); UI.drop.classList.add('is-over'); });
    });
    ['dragleave', 'drop'].forEach(function (ev) {
        UI.drop.addEventListener(ev, function (e) { e.preventDefault(); UI.drop.classList.remove('is-over'); });
    });
    UI.drop.addEventListener('drop', function (e) {
        // Without preventDefault on BOTH dragover and drop the browser
        // navigates to the dropped file and the admin loses the page.
        e.preventDefault();
        if (e.dataTransfer && e.dataTransfer.files) enqueue(e.dataTransfer.files);
    });

    // CAPTURE phase on purpose. The shared tooltip controller in footer.tpl
    // also handles Escape in capture, and it hides the popup before a bubble
    // listener would ever see the event -- so a keyboard user who tabs to an
    // info tip and presses Escape to dismiss it would lose the whole dialog
    // too. Running first lets us see that a tip is open and defer to it.
    // Escape peels one layer at a time: tooltip, then delete-confirm, then
    // the modal.
    document.addEventListener('keydown', function (e) {
        if (modal.hidden || e.key !== 'Escape') return;
        var tip = document.querySelector('.mt-tip-pop');
        if (tip && getComputedStyle(tip).display !== 'none') return;   // tip owns this press
        var openConfirm = modal.querySelector('.mt-media-confirm');
        if (openConfirm) { openConfirm.remove(); return; }
        close();
    }, true);

    // Delegated opener: any [data-mt-media] input, including ones added later.
    document.addEventListener('click', function (e) {
        var t = e.target;
        if (!t || !t.closest) return;
        var trigger = t.closest('[data-mt-media-open]');
        if (!trigger) return;
        var field = trigger.closest('.mt-media-field');
        var input = field && field.querySelector('[data-mt-media]');
        if (input) { e.preventDefault(); open(input); }
    });

    // ---- upgrade every opted-in field ----

    function preview(field) {
        var input = field.querySelector('[data-mt-media]');
        var well  = field.querySelector('[data-mt-media-open]');
        if (!input || !well) return;
        var url = (input.value || '').trim();
        well.textContent = '';
        if (url) {
            var img = document.createElement('img');
            img.className = 'mt-media-well-img';
            img.alt = '';
            img.src = url;
            img.addEventListener('error', function () { well.classList.remove('is-filled'); emptyWell(well, input); });
            well.classList.add('is-filled');
            well.appendChild(img);
            var over = el('span', 'mt-media-well-over');
            over.appendChild(el('span', 'mt-btn mt-btn-secondary mt-btn-sm', 'Change'));
            well.appendChild(over);
        } else {
            well.classList.remove('is-filled');
            emptyWell(well, input);
        }
    }

    function emptyWell(well, input) {
        well.textContent = '';
        var svg = document.createElementNS('http://www.w3.org/2000/svg', 'svg');
        svg.setAttribute('viewBox', '0 0 24 24');
        svg.setAttribute('fill', 'none');
        svg.setAttribute('stroke', 'currentColor');
        svg.setAttribute('stroke-width', '1.7');
        var p = document.createElementNS('http://www.w3.org/2000/svg', 'path');
        p.setAttribute('d', 'M3 5h18v14H3zM3 16l5-5 4 4 3-3 6 6');
        svg.appendChild(p);
        well.appendChild(svg);
        well.appendChild(el('span', 'mt-media-well-label', 'Choose image'));
        var hint = input.getAttribute('data-mt-media-hint');
        if (hint) well.appendChild(el('span', 'mt-media-well-hint', hint));
    }

    function upgrade(input) {
        if (input.getAttribute('data-mt-media-ready')) return;
        input.setAttribute('data-mt-media-ready', '1');

        // A wrapper div does not change form ownership, so the input keeps
        // posting exactly as before and stays typeable (an external CDN URL
        // is a legitimate value the library will never contain).
        var field = el('div', 'mt-media-field');
        input.parentNode.insertBefore(field, input);

        var well = el('button', 'mt-media-well');
        well.type = 'button';
        well.setAttribute('data-mt-media-open', '1');
        field.appendChild(well);
        field.appendChild(input);
        field.appendChild(el('div', 'mt-media-hint', 'or paste an image URL below'));

        input.addEventListener('input', function () { preview(field); });
        preview(field);
    }

    Array.prototype.forEach.call(document.querySelectorAll('[data-mt-media]'), upgrade);
})();
</script>
{/literal}
