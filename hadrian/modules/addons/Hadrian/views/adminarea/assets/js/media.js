/* Media screen controller (views/adminarea/media/index.tpl).
 *
 * Inlined into the page by MediaScreenController, so two rules from the
 * picker apply here too:
 *   - no string may contain a literal opening form tag. The WHMCS admin
 *     output filter regex-scans the response for one and injects a hidden
 *     token field after it, content-blind, which would land inside the string.
 *   - everything that came from the server enters the DOM through textContent
 *     or an attribute set from the server's own url field. Nothing is put
 *     into innerHTML: a file that arrived by FTP must not be able to inject.
 *
 * It talks to MediaController's JSON endpoints, the same ones the picker
 * uses: list, upload, delete, plus rename, optimize, restore and settings.
 */
(function () {
    'use strict';

    var rootEl = document.getElementById('mt-ml');
    var bootEl = document.getElementById('mt-ml-data');
    if (!rootEl || !bootEl || !window.FormData || !window.XMLHttpRequest) return;

    var BOOT;
    try { BOOT = JSON.parse(bootEl.textContent || '{}'); } catch (e) { return; }

    function $(id) { return document.getElementById(id); }
    var UI = {
        panel: $('mt-ml-panel'), q: $('mt-ml-q'), show: $('mt-ml-show'), sort: $('mt-ml-sort'),
        file: $('mt-ml-file'), stats: $('mt-ml-stats'), status: $('mt-ml-status'), queue: $('mt-ml-queue'),
        grid: $('mt-ml-grid'), empty: $('mt-ml-empty'), emptyT: $('mt-ml-empty-title'), emptyS: $('mt-ml-empty-sub'),
        sideEmpty: $('mt-ml-side-empty'), detail: $('mt-ml-detail'),
        bulk: $('mt-ml-bulk'), bulkCount: $('mt-ml-bulk-count'), bulkAll: $('mt-ml-bulk-all'),
        bulkNone: $('mt-ml-bulk-none'), bulkOpt: $('mt-ml-bulk-opt'), bulkDel: $('mt-ml-bulk-del'),
        optToggle: $('mt-ml-opt-toggle'), optAll: $('mt-ml-optall'), optAllHelp: $('mt-ml-optall-help'),
        dialog: $('mt-ml-dialog'), dialogTitle: $('mt-ml-dialog-title'), dialogBody: $('mt-ml-dialog-body'),
        dialogNo: $('mt-ml-dialog-no'), dialogYes: $('mt-ml-dialog-yes')
    };

    var state = {
        items: [], loaded: false, q: '', show: 'all', sort: 'new',
        picked: {},            // name -> true: the ticked tiles
        current: null,         // name of the image in the details panel
        inflight: 0,           // uploads still running
        working: false,        // an optimise run is going
        optimizer: false
    };

    // ---- small helpers ----

    function el(tag, cls, text) {
        var n = document.createElement(tag);
        if (cls) n.className = cls;
        if (text !== undefined && text !== null) n.textContent = text;
        return n;
    }
    function btn(cls, text) {
        var b = el('button', cls, text);
        b.type = 'button';
        return b;
    }
    function human(b) {
        if (b < 1024) return b + ' B';
        if (b < 1048576) return Math.round(b / 1024) + ' KB';
        return (b / 1048576).toFixed(1) + ' MB';
    }
    function plural(n, one, many) { return n + ' ' + (n === 1 ? one : many); }
    function byName(n) {
        for (var i = 0; i < state.items.length; i++) if (state.items[i].name === n) return state.items[i];
        return null;
    }
    function uses(it) { return (it.usage && it.usage.length) || 0; }
    function pickedNames() {
        return Object.keys(state.picked).filter(function (n) { return state.picked[n] && byName(n); });
    }
    function say(msg, kind) {
        UI.status.textContent = msg || '';
        UI.status.className = 'mt-media-status' + (kind ? ' is-' + kind : '');
    }
    function dateOf(ts) {
        if (!ts) return '';
        try { return new Date(ts * 1000).toLocaleDateString(undefined, { year: 'numeric', month: 'short', day: 'numeric' }); }
        catch (e) { return ''; }
    }

    // ---- transport ----

    function post(sub, data, done, fail) {
        var xhr = new XMLHttpRequest();
        xhr.open('POST', BOOT.endpoint + sub, true);
        xhr.setRequestHeader('X-Requested-With', 'XMLHttpRequest');
        xhr.onload = function () {
            var res;
            try { res = JSON.parse(xhr.responseText); }
            catch (e) { fail('The server did not answer as expected (HTTP ' + xhr.status + '). Reload the page and try again.'); return; }
            if (!res || !res.ok) { fail((res && res.error) || 'The request failed.'); return; }
            done(res);
        };
        xhr.onerror = function () { fail('Network error. Check your connection and try again.'); };
        data.append('collection', BOOT.collection);
        data.append('token', BOOT.token);
        xhr.send(data);
        return xhr;
    }

    // ---- what is shown ----

    function visible() {
        var q = state.q.trim().toLowerCase();
        var list = state.items.filter(function (it) {
            if (state.show === 'used' && !uses(it)) return false;
            if (state.show === 'unused' && uses(it)) return false;
            return !q || (it.label + ' ' + it.name).toLowerCase().indexOf(q) !== -1;
        });
        list.sort(function (a, b) {
            if (state.sort === 'name') return a.label.toLowerCase() < b.label.toLowerCase() ? -1 : (a.label.toLowerCase() > b.label.toLowerCase() ? 1 : 0);
            if (state.sort === 'big') return b.bytes - a.bytes;
            if (state.sort === 'old') return a.mtime - b.mtime;
            return b.mtime - a.mtime;
        });
        return list;
    }

    function dimsText(it) {
        return (it.w && it.h ? it.w + ' x ' + it.h + '  ' : '') + it.human;
    }

    function tile(it) {
        var t = el('div', 'mt-media-tile mt-ml-tile');
        t.setAttribute('data-name', it.name);
        t.setAttribute('tabindex', '0');
        t.setAttribute('role', 'button');
        t.setAttribute('aria-label', it.label + ', ' + (uses(it) ? 'used in ' + plural(uses(it), 'place', 'places') : 'not used'));
        if (state.current === it.name) t.classList.add('is-current');

        var thumb = el('span', 'mt-media-thumb');
        var img = document.createElement('img');
        img.loading = 'lazy';
        img.alt = '';
        img.src = it.url + '?v=' + it.mtime;         // a restore or optimise changes the file, not its name
        img.addEventListener('load', function () {
            // Files that predate recorded sizes: read it off the image.
            if (!it.w && img.naturalWidth) {
                it.w = img.naturalWidth; it.h = img.naturalHeight;
                dims.textContent = dimsText(it);
                if (state.current === it.name) paintDetail();
            }
        });
        thumb.appendChild(img);

        var meta = el('span', 'mt-media-meta');
        meta.appendChild(el('span', 'mt-media-name', it.label));
        var dims = el('span', 'mt-media-dims', dimsText(it));
        meta.appendChild(dims);

        // A real checkbox inside a label, so it is reachable by keyboard and
        // a click on it does not also open the details.
        var pick = el('label', 'mt-ml-pick');
        var box = document.createElement('input');
        box.type = 'checkbox';
        box.checked = !!state.picked[it.name];
        box.setAttribute('aria-label', 'Select ' + it.label);
        box.addEventListener('change', function () {
            state.picked[it.name] = box.checked;
            t.classList.toggle('is-picked', box.checked);
            paintBulk();
        });
        pick.appendChild(box);
        pick.addEventListener('click', function (e) { e.stopPropagation(); });
        if (box.checked) t.classList.add('is-picked');

        t.appendChild(thumb);
        t.appendChild(meta);
        t.appendChild(pick);
        if (!uses(it)) t.appendChild(el('span', 'mt-badge mt-badge-neutral mt-ml-flag', 'Unused'));

        function open() {
            state.current = it.name;
            paintCurrent();
            paintDetail();
            // Stacked layout (a narrow window): the details sit above the
            // grid, so bring them to the image that was just chosen.
            if (window.matchMedia && window.matchMedia('(max-width: 980px)').matches && UI.detail.scrollIntoView) {
                UI.detail.parentNode.scrollIntoView({ behavior: 'smooth', block: 'start' });
            }
        }
        t.addEventListener('click', open);
        t.addEventListener('keydown', function (e) {
            if (e.target !== t) return;
            if (e.key === 'Enter' || e.key === ' ') { e.preventDefault(); open(); }
        });
        return t;
    }

    function paintCurrent() {
        Array.prototype.forEach.call(UI.grid.children, function (n) {
            n.classList.toggle('is-current', n.getAttribute('data-name') === state.current);
        });
    }

    function paintStats() {
        if (!state.loaded) { UI.stats.textContent = ''; return; }
        var bytes = 0, saved = 0, unused = 0;
        state.items.forEach(function (it) {
            bytes += it.bytes; saved += it.saved || 0;
            if (!uses(it)) unused++;
        });
        var parts = [state.items.length + ' of ' + BOOT.maxFiles + ' images', human(bytes)];
        if (unused) parts.push(unused + ' unused');
        if (saved) parts.push(human(saved) + ' saved by optimising');
        UI.stats.textContent = parts.join('  ·  ');
    }

    function paintGrid() {
        var list = visible();
        UI.grid.textContent = '';
        list.forEach(function (it) { UI.grid.appendChild(tile(it)); });

        var none = state.items.length === 0;
        UI.empty.hidden = list.length > 0 || !state.loaded;
        if (!UI.empty.hidden) {
            if (none) {
                UI.emptyT.textContent = 'No images yet';
                UI.emptyS.textContent = 'Upload one here, or from any image field in Pages, Email or the Page Builder.';
            } else {
                UI.emptyT.textContent = state.show === 'unused' && !state.q ? 'Nothing is unused' : 'No images match';
                UI.emptyS.textContent = state.show === 'unused' && !state.q
                    ? 'Every image in the library is used somewhere.'
                    : 'Try another search, or show all images.';
            }
        }
    }

    function paintBulk() {
        var n = pickedNames().length;
        UI.bulk.hidden = n === 0;
        UI.bulkCount.textContent = plural(n, 'image', 'images') + ' selected';
    }

    function paint() {
        paintStats();
        paintGrid();
        paintBulk();
        paintDetail();
    }

    // ---- details panel ----

    function fact(dl, k, v, cls) {
        if (!v) return;
        dl.appendChild(el('dt', null, k));
        dl.appendChild(el('dd', cls || null, v));
    }

    function paintDetail() {
        var it = state.current ? byName(state.current) : null;
        UI.detail.textContent = '';
        UI.detail.hidden = !it;
        UI.sideEmpty.hidden = !!it;
        if (!it) return;

        var view = el('a', 'mt-ml-view');
        view.href = it.url;
        view.target = '_blank';
        view.rel = 'noopener';
        view.title = 'Open the image in a new tab';
        var img = document.createElement('img');
        img.alt = '';
        img.src = it.url + '?v=' + it.mtime;
        view.appendChild(img);
        UI.detail.appendChild(view);

        // Name. The file on disk keeps its own name; this is what the
        // library shows and searches.
        var nameField = el('div', 'mt-field');
        var nameLabel = el('label', 'mt-field-label', 'Name');
        nameLabel.setAttribute('for', 'mt-ml-name');
        var name = el('input', 'mt-input mt-input-compact');
        name.type = 'text';
        name.id = 'mt-ml-name';
        name.maxLength = 80;
        name.value = it.label;
        function saveName() {
            var v = name.value.trim();
            if (v === '' || v === it.label) { name.value = it.label; return; }
            var fd = new FormData();
            fd.append('name', it.name);
            fd.append('label', v);
            post('rename', fd, function (res) { replace(res.item); say('Renamed to "' + res.item.label + '".', 'ok'); },
                function (err) { name.value = it.label; say(err, 'error'); });
        }
        name.addEventListener('change', saveName);
        name.addEventListener('keydown', function (e) { if (e.key === 'Enter') { e.preventDefault(); name.blur(); } });
        nameField.appendChild(nameLabel);
        nameField.appendChild(name);
        UI.detail.appendChild(nameField);

        var dl = el('dl', 'mt-ml-facts');
        fact(dl, 'Size', (it.w && it.h ? it.w + ' x ' + it.h + ' px, ' : '') + it.human);
        fact(dl, 'Type', (it.ext || '').toUpperCase());
        fact(dl, 'Added', dateOf(it.mtime));
        fact(dl, 'File', it.name, 'is-file');
        UI.detail.appendChild(dl);

        // Address, with a copy button.
        var urlField = el('div', 'mt-field');
        var urlLabel = el('label', 'mt-field-label', 'Address');
        urlLabel.setAttribute('for', 'mt-ml-url');
        var row = el('div', 'mt-ml-copy');
        var url = el('input', 'mt-input mt-input-compact');
        url.type = 'text';
        url.id = 'mt-ml-url';
        url.readOnly = true;
        url.value = it.absUrl || it.url;
        url.addEventListener('focus', function () { url.select(); });
        var copy = btn('mt-btn mt-btn-secondary mt-btn-sm', 'Copy');
        copy.addEventListener('click', function () {
            function ok() { copy.textContent = 'Copied'; setTimeout(function () { copy.textContent = 'Copy'; }, 1500); }
            if (navigator.clipboard && navigator.clipboard.writeText) {
                navigator.clipboard.writeText(url.value).then(ok, function () { url.select(); });
            } else {
                url.select();
                try { if (document.execCommand('copy')) ok(); } catch (e) {}
            }
        });
        row.appendChild(url);
        row.appendChild(copy);
        urlField.appendChild(urlLabel);
        urlField.appendChild(row);
        UI.detail.appendChild(urlField);

        // Where it is used.
        var used = el('div', 'mt-ml-used');
        used.appendChild(el('div', 'mt-field-label', uses(it) ? 'Used in ' + plural(uses(it), 'place', 'places') : 'Used in'));
        if (uses(it)) {
            var ul = el('ul', 'mt-ml-usedlist');
            it.usage.forEach(function (u) {
                var li = el('li');
                if (u.url) {
                    var a = el('a', null, u.where);
                    a.href = u.url;
                    li.appendChild(a);
                } else {
                    li.textContent = u.where;
                }
                ul.appendChild(li);
            });
            used.appendChild(ul);
        } else {
            used.appendChild(el('p', 'mt-field-help', 'Nowhere that Hadrian can see. An address pasted outside Hadrian, in a product description for example, is not counted.'));
        }
        UI.detail.appendChild(used);

        // Optimising.
        if (state.optimizer) {
            var opt = el('div', 'mt-ml-opt');
            if (it.optimized) {
                opt.appendChild(el('span', 'mt-badge mt-badge-success', 'Optimised'));
                opt.appendChild(el('span', 'mt-ml-opt-note', it.savedHuman + ' smaller'));
                var back = btn('mt-btn mt-btn-ghost mt-btn-sm', 'Restore original');
                back.addEventListener('click', function () {
                    back.disabled = true;
                    var fd = new FormData();
                    fd.append('name', it.name);
                    post('restore', fd, function (res) { replace(res.item); say('The original of "' + res.item.label + '" is back.', 'ok'); },
                        function (err) { back.disabled = false; say(err, 'error'); });
                });
                opt.appendChild(back);
            } else {
                var go = btn('mt-btn mt-btn-secondary mt-btn-sm', 'Optimise');
                go.addEventListener('click', function () { optimise([it.name], true); });
                opt.appendChild(go);
            }
            UI.detail.appendChild(opt);
        }

        var del = btn('mt-btn mt-btn-danger mt-btn-sm mt-ml-del', 'Delete image');
        del.addEventListener('click', function () { askDelete([it.name]); });
        UI.detail.appendChild(del);
    }

    /** Put a fresh copy of one image into the list and repaint. */
    function replace(item) {
        if (!item) return;
        for (var i = 0; i < state.items.length; i++) {
            if (state.items[i].name === item.name) { state.items[i] = item; break; }
        }
        paint();
    }

    // ---- load ----

    function load() {
        UI.grid.textContent = '';
        for (var i = 0; i < 8; i++) {
            var s = el('div', 'mt-media-skel');
            s.appendChild(el('div', 'mt-media-skel-thumb'));
            s.appendChild(el('div', 'mt-media-skel-line'));
            UI.grid.appendChild(s);
        }
        var fd = new FormData();
        fd.append('usage', '1');
        post('list', fd, function (res) {
            state.items = res.items || [];
            state.optimizer = !!res.optimizer;
            state.loaded = true;
            UI.file.setAttribute('accept', res.accept || BOOT.accept);
            paint();
        }, function (err) {
            UI.grid.textContent = '';
            say(err, 'error');
        });
    }

    // ---- upload ----

    function enqueue(files) {
        if (!files || !files.length) return;
        say('');
        Array.prototype.forEach.call(files, uploadOne);
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

        function fail(msg) { row.classList.add('is-error'); st.textContent = msg; }
        if (BOOT.maxBytes && file.size > BOOT.maxBytes) { fail('Too large (' + human(file.size) + '). The limit is ' + human(BOOT.maxBytes) + '.'); return; }

        var fd = new FormData();
        fd.append('file', file);
        st.textContent = 'Uploading';
        state.inflight++;
        var xhr = post('upload', fd, function (res) {
            state.inflight--;
            row.classList.add('is-done');
            st.textContent = res.optimized ? 'Done, and optimised' : 'Done';
            fill.style.width = '100%';
            state.items.unshift(res.item);
            state.current = res.item.name;
            paint();
            // A finished row has said what it had to say.
            setTimeout(function () { if (row.parentNode) row.parentNode.removeChild(row); }, 2500);
        }, function (err) {
            state.inflight--;
            fail(err);
        });
        xhr.upload.onprogress = function (e) {
            if (e.lengthComputable) fill.style.width = ((e.loaded / e.total) * 100) + '%';
        };
    }

    // ---- delete ----

    function askDelete(names) {
        names = names.filter(byName);
        if (!names.length) return;
        var inUse = names.map(byName).filter(uses);

        UI.dialogTitle.textContent = names.length === 1
            ? 'Delete "' + byName(names[0]).label + '"?'
            : 'Delete ' + names.length + ' images?';
        UI.dialogBody.textContent = '';
        if (inUse.length) {
            UI.dialogBody.appendChild(el('p', 'mt-ml-warn',
                inUse.length === 1 && names.length === 1
                    ? 'This image is in use. Deleting it leaves an empty space where it is shown:'
                    : plural(inUse.length, 'of these images is', 'of these images are') + ' in use. Deleting leaves an empty space where they are shown:'));
            var ul = el('ul', 'mt-ml-usedlist');
            var shown = 0;
            inUse.forEach(function (it) {
                it.usage.forEach(function (u) {
                    if (shown++ < 8) ul.appendChild(el('li', null, (names.length > 1 ? it.label + ': ' : '') + u.where));
                });
            });
            if (shown > 8) ul.appendChild(el('li', null, 'and ' + (shown - 8) + ' more'));
            UI.dialogBody.appendChild(ul);
        }
        UI.dialogBody.appendChild(el('p', null, 'This cannot be undone.'));
        UI.dialogYes.textContent = inUse.length ? 'Delete anyway' : 'Delete';

        openDialog(function () { doDelete(names); });
    }

    function doDelete(names) {
        var fd = new FormData();
        names.forEach(function (n) { fd.append('name[]', n); });
        fd.append('force', '1');                 // the dialog above showed where each one is used
        post('delete', fd, function (res) {
            var gone = 0, left = 0;
            names.forEach(function (n) {
                var outcome = (res.results && res.results[n]) || '';
                if (outcome === 'deleted' || outcome === 'not-found') {
                    gone++;
                    state.items = state.items.filter(function (i) { return i.name !== n; });
                    delete state.picked[n];
                    if (state.current === n) state.current = null;
                } else {
                    left++;
                }
            });
            paint();
            if (left) say(plural(left, 'image', 'images') + ' could not be deleted.', 'error');
            else say('Deleted ' + plural(gone, 'image', 'images') + '.', 'ok');
        }, function (err) { say(err, 'error'); });
    }

    // ---- confirm dialog ----

    var dialogYes = null, dialogOpener = null;
    function openDialog(onYes) {
        dialogYes = onYes;
        dialogOpener = document.activeElement;
        var admin = document.getElementById('mt-admin-root');
        UI.dialog.setAttribute('data-theme', (admin && admin.getAttribute('data-theme')) || 'light');
        UI.dialog.hidden = false;
        UI.dialogNo.focus();
    }
    function closeDialog() {
        UI.dialog.hidden = true;
        dialogYes = null;
        if (dialogOpener && dialogOpener.focus && document.body.contains(dialogOpener)) dialogOpener.focus();
    }
    // Out of the page flow, like the picker: a fixed layer must not sit
    // inside a transformed or clipped ancestor. .mt-wrap carries the tokens.
    UI.dialog.classList.add('mt-wrap');
    document.body.appendChild(UI.dialog);
    UI.dialogNo.addEventListener('click', closeDialog);
    UI.dialogYes.addEventListener('click', function () { var fn = dialogYes; closeDialog(); if (fn) fn(); });
    UI.dialog.addEventListener('click', function (e) { if (e.target === UI.dialog) closeDialog(); });
    document.addEventListener('keydown', function (e) {
        if (e.key === 'Escape' && !UI.dialog.hidden) { e.stopPropagation(); closeDialog(); }
    }, true);

    // ---- optimise ----

    /**
     * Optimise the named images, a few per request, and report as it goes.
     * `quiet` skips nothing; `one` words the result for a single image.
     */
    function optimise(names, one) {
        if (state.working || !names.length) return;
        state.working = true;
        var total = names.length, done = 0, smaller = 0, saved = 0, lastReason = '';
        var todo = names.slice();
        if (UI.optAll) UI.optAll.disabled = true;
        if (UI.bulkOpt) UI.bulkOpt.disabled = true;

        function finish(err) {
            state.working = false;
            if (UI.optAll) UI.optAll.disabled = false;
            if (UI.bulkOpt) UI.bulkOpt.disabled = false;
            paint();
            if (err) { say(err, 'error'); return; }
            if (one) {
                say(smaller ? 'Optimised: ' + human(saved) + ' smaller.' : (lastReason || 'Already as small as it gets.'), smaller ? 'ok' : '');
            } else {
                say(smaller
                    ? 'Optimised ' + plural(smaller, 'image', 'images') + ', ' + human(saved) + ' saved.' + (total - smaller ? ' ' + (total - smaller) + ' left as they were.' : '')
                    : 'Nothing got smaller. ' + (total === 1 && lastReason ? lastReason : 'These images are already as small as this can make them.'), smaller ? 'ok' : '');
            }
        }

        function step() {
            if (!todo.length) { finish(); return; }
            var batch = todo.splice(0, 4);
            var fd = new FormData();
            batch.forEach(function (n) { fd.append('name[]', n); });
            if (!one) say('Optimising ' + Math.min(done + batch.length, total) + ' of ' + total + '…');
            post('optimize', fd, function (res) {
                Object.keys(res.results || {}).forEach(function (n) {
                    var r = res.results[n];
                    done++;
                    if (r.status === 'optimized' && r.item) { smaller++; saved += r.item.saved || 0; }
                    else if (r.reason) lastReason = r.reason;
                    if (r.item) {
                        for (var i = 0; i < state.items.length; i++) {
                            if (state.items[i].name === n) { state.items[i] = r.item; break; }
                        }
                    }
                });
                // Whatever the server ran out of time for goes back in the queue.
                if (res.pending && res.pending.length) todo = res.pending.concat(todo);
                step();
            }, finish);
        }
        step();
    }

    // ---- wiring ----

    UI.q.addEventListener('input', function () { state.q = UI.q.value; paintGrid(); });
    UI.q.addEventListener('keydown', function (e) { if (e.key === 'Enter') e.preventDefault(); });
    UI.sort.addEventListener('change', function () { state.sort = UI.sort.value; paintGrid(); });
    Array.prototype.forEach.call(UI.show.querySelectorAll('button'), function (b) {
        b.addEventListener('click', function () {
            state.show = b.getAttribute('data-show');
            Array.prototype.forEach.call(UI.show.querySelectorAll('button'), function (o) {
                o.classList.toggle('is-active', o === b);
                o.setAttribute('aria-pressed', o === b ? 'true' : 'false');
            });
            paintGrid();
        });
    });

    UI.file.addEventListener('change', function () {
        enqueue(UI.file.files);
        try { UI.file.value = ''; } catch (e) {}
    });

    // Drop anywhere on the panel. preventDefault on dragover AND drop, or the
    // browser opens the dropped file and the admin loses the page.
    var dragDepth = 0;
    function hasFiles(e) {
        var t = e.dataTransfer && e.dataTransfer.types;
        return !!t && Array.prototype.indexOf.call(t, 'Files') !== -1;
    }
    UI.panel.addEventListener('dragenter', function (e) {
        if (!hasFiles(e)) return;
        e.preventDefault(); dragDepth++; UI.panel.classList.add('is-over');
    });
    UI.panel.addEventListener('dragover', function (e) { if (hasFiles(e)) e.preventDefault(); });
    UI.panel.addEventListener('dragleave', function (e) {
        if (!hasFiles(e)) return;
        dragDepth = Math.max(0, dragDepth - 1);
        if (!dragDepth) UI.panel.classList.remove('is-over');
    });
    UI.panel.addEventListener('drop', function (e) {
        if (!hasFiles(e)) return;
        e.preventDefault();
        dragDepth = 0;
        UI.panel.classList.remove('is-over');
        enqueue(e.dataTransfer.files);
    });

    UI.bulkAll.addEventListener('click', function () {
        visible().forEach(function (it) { state.picked[it.name] = true; });
        paintGrid(); paintBulk();
    });
    UI.bulkNone.addEventListener('click', function () { state.picked = {}; paintGrid(); paintBulk(); });
    UI.bulkDel.addEventListener('click', function () { askDelete(pickedNames()); });
    if (UI.bulkOpt) UI.bulkOpt.addEventListener('click', function () {
        optimise(pickedNames().filter(function (n) { return !byName(n).optimized; }), false);
    });

    if (UI.optAll) UI.optAll.addEventListener('click', function () {
        // Not the ones already done, and not one whose original was put back
        // on purpose.
        // Nor a GIF, which is never re-encoded (it may be an animation).
        var names = state.items.filter(function (it) { return !it.optimized && !it.skipOptimize && it.ext !== 'gif'; })
            .map(function (it) { return it.name; });
        if (!names.length) { say('Nothing to do: every image that can be optimised already is.'); return; }
        optimise(names, false);
    });

    if (UI.optToggle) UI.optToggle.addEventListener('change', function () {
        var want = UI.optToggle.checked;
        var fd = new FormData();
        fd.append('optimize', want ? '1' : '0');
        post('settings', fd, function (res) {
            UI.optToggle.checked = !!res.optimizeUploads;
            say(res.optimizeUploads ? 'New uploads will be optimised.' : 'New uploads are kept exactly as uploaded.', 'ok');
        }, function (err) {
            UI.optToggle.checked = !want;
            say(err, 'error');
        });
    });

    // For the tests: the list as the screen holds it, and whether it is busy.
    window.hadrianMedia = {
        state: state,
        idle: function () { return state.loaded && state.inflight === 0 && !state.working; }
    };

    load();
})();
