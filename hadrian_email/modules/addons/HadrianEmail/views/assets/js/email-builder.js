/* Email builder.
 *
 * One document (S.doc) is the single source of truth. Every edit mutates it
 * and asks the server for a fresh preview; the server is the only renderer, so
 * what the canvas shows is what will be sent.
 *
 * The preview is an iframe with sandbox="allow-same-origin" and NO
 * allow-scripts: an HTML block can hold anything an admin pasted, and a script
 * in there must not run with an admin session. With scripting off, listeners
 * attached inside the frame do not fire either, so all interaction happens on
 * a transparent overlay in this document. The frame is sized to its content
 * and never scrolls, which makes a block's rectangle inside the frame the same
 * as its rectangle on the overlay.
 */
(function () {
    'use strict';

    var bootEl = document.getElementById('hxb-boot');
    var root = document.getElementById('hxb');
    if (!bootEl || !root) { return; }
    var boot = JSON.parse(bootEl.textContent);

    var S = {
        doc: boot.doc,
        id: boot.id || 0,
        status: boot.status,
        pending: !!boot.pending,
        sel: null,
        lang: '_',
        scheme: 'light',
        device: 'desktop',
        dirty: false,
        busy: false
    };
    var TYPES = boot.types;
    var IS_LAYOUT = boot.kind === 'layout';

    var $ = function (id) { return document.getElementById(id); };
    var frame = $('hxb-frame'), overlay = $('hxb-overlay'), device = $('hxb-canvas');
    var outlineEl = $('hxb-outline'), inspEl = $('hxb-inspector'), noticeEl = $('hxb-notice');

    // ------------------------------------------------------------ utilities

    function el(tag, attrs, kids) {
        var n = document.createElement(tag);
        if (attrs) {
            Object.keys(attrs).forEach(function (k) {
                var v = attrs[k];
                if (v === null || v === undefined || v === false) { return; }
                if (k === 'class') { n.className = v; }
                else if (k === 'text') { n.textContent = v; }
                else if (k === 'html') { n.innerHTML = v; }
                else if (k.slice(0, 2) === 'on') { n.addEventListener(k.slice(2), v); }
                else { n.setAttribute(k, v === true ? '' : v); }
            });
        }
        (kids || []).forEach(function (c) { if (c) { n.appendChild(typeof c === 'string' ? document.createTextNode(c) : c); } });
        return n;
    }

    var ICONS = {
        header: '<path d="M3 5h18v5H3z"/><path d="M3 14h18M3 18h12"/>',
        footer: '<path d="M3 14h18v5H3z"/><path d="M3 6h18M3 10h12"/>',
        content: '<rect x="4" y="4" width="16" height="16" rx="3"/><path d="M8 9h8M8 13h8M8 17h5"/>',
        heading: '<path d="M6 5v14M18 5v14M6 12h12"/>',
        text: '<path d="M4 6h16M4 10h16M4 14h16M4 18h10"/>',
        button: '<rect x="3" y="8" width="18" height="8" rx="4"/><path d="M9 12h6"/>',
        details: '<path d="M4 7h6M14 7h6M4 12h6M14 12h6M4 17h6M14 17h6"/>',
        callout: '<rect x="3" y="5" width="18" height="14" rx="3"/><path d="M7 9v6"/><path d="M11 10h6M11 14h4"/>',
        image: '<rect x="3" y="5" width="18" height="14" rx="3"/><circle cx="9" cy="10" r="1.6"/><path d="M4 17l5-4 4 3 3-2 4 3"/>',
        divider: '<path d="M3 12h18"/><path d="M8 7h8M8 17h8" opacity=".35"/>',
        spacer: '<path d="M12 4v16M8 8l4-4 4 4M8 16l4 4 4-4"/>',
        html: '<path d="M8 8l-4 4 4 4M16 8l4 4-4 4M13 6l-2 12"/>',
        up: '<path d="M6 14l6-6 6 6"/>',
        down: '<path d="M6 10l6 6 6-6"/>',
        copy: '<rect x="8" y="8" width="11" height="11" rx="2"/><path d="M5 15V6a1 1 0 011-1h9"/>',
        trash: '<path d="M5 7h14M10 7V5h4v2M7 7l1 12h8l1-12"/>',
        grip: '<circle cx="9" cy="7" r="1.2"/><circle cx="15" cy="7" r="1.2"/><circle cx="9" cy="12" r="1.2"/><circle cx="15" cy="12" r="1.2"/><circle cx="9" cy="17" r="1.2"/><circle cx="15" cy="17" r="1.2"/>',
        x: '<path d="M6 6l12 12M18 6L6 18"/>'
    };
    function icon(name) {
        return '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">' + (ICONS[name] || ICONS.text) + '</svg>';
    }
    function iconBtn(name, title, fn, extra) {
        return el('button', { type: 'button', 'class': 'hxb-ico' + (extra ? ' ' + extra : ''), title: title, 'aria-label': title, html: icon(name),
            onclick: function (e) { e.stopPropagation(); fn(e); },
            onpointerdown: function (e) { e.stopPropagation(); } });
    }

    function uid() {
        var a = new Uint8Array(5), s = 'b';
        (window.crypto || window.msCrypto).getRandomValues(a);
        for (var i = 0; i < a.length; i++) { s += ('0' + a[i].toString(16)).slice(-2); }
        return s;
    }
    function clone(v) { return JSON.parse(JSON.stringify(v)); }
    function plain(html) { var d = document.createElement('div'); d.innerHTML = html || ''; return (d.textContent || '').replace(/\s+/g, ' ').trim(); }

    // A translatable value is {"_": default, "<language>": translation}.
    function tGet(v, lang) {
        if (v === null || v === undefined) { return ''; }
        if (typeof v === 'string') { return lang === '_' ? v : ''; }
        return typeof v[lang] === 'string' ? v[lang] : '';
    }
    function tSet(obj, key, lang, text) {
        var v = obj[key];
        if (typeof v !== 'object' || v === null || Array.isArray(v)) { v = { _: typeof v === 'string' ? v : '' }; }
        if (lang !== '_' && text === '') { delete v[lang]; } else { v[lang] = text; }
        obj[key] = v;
    }
    function langLabel() {
        for (var i = 0; i < boot.languages.length; i++) { if (boot.languages[i].code === S.lang) { return boot.languages[i].label; } }
        return '';
    }

    // ------------------------------------------------------- document edits

    function blocks() { return S.doc.blocks; }
    function indexOf(id) { for (var i = 0; i < blocks().length; i++) { if (blocks()[i].id === id) { return i; } } return -1; }
    function find(id) { var i = indexOf(id); return i < 0 ? null : blocks()[i]; }
    function fixed(b) { return !!(b && TYPES[b.type] && TYPES[b.type].fixed); }

    function make(type) {
        var props = {};
        TYPES[type].fields.forEach(function (f) { props[f.key] = clone(f['default']); });
        return { id: uid(), type: type, props: props };
    }
    function changed(structural) {
        S.dirty = true;
        renderBar();
        if (structural) { renderOutline(); drawOverlay(); }
        schedulePreview();
    }
    function insertAt(type, index) {
        var b = make(type);
        index = Math.max(0, Math.min(blocks().length, index));
        blocks().splice(index, 0, b);
        S.sel = b.id;
        changed(true);
        renderInspector();
    }
    function defaultIndex() {
        var at = indexOf(S.sel);
        if (at >= 0) { return at + 1; }
        if (IS_LAYOUT) {
            for (var i = 0; i < blocks().length; i++) { if (blocks()[i].type === 'footer') { return i; } }
        }
        return blocks().length;
    }
    function moveTo(id, index) {
        var from = indexOf(id);
        if (from < 0) { return; }
        var b = blocks().splice(from, 1)[0];
        if (index > from) { index--; }
        blocks().splice(Math.max(0, Math.min(blocks().length, index)), 0, b);
        changed(true);
    }
    function nudge(id, by) { var i = indexOf(id); if (i >= 0) { moveTo(id, by < 0 ? i - 1 : i + 2); } }
    function removeBlock(id) {
        var i = indexOf(id);
        if (i < 0 || fixed(blocks()[i])) { return; }
        blocks().splice(i, 1);
        if (S.sel === id) { S.sel = null; renderInspector(); }
        changed(true);
    }
    function duplicate(id) {
        var i = indexOf(id);
        if (i < 0 || fixed(blocks()[i])) { return; }
        var c = clone(blocks()[i]);
        c.id = uid();
        blocks().splice(i + 1, 0, c);
        S.sel = c.id;
        changed(true);
        renderInspector();
    }
    function select(id) {
        if (S.sel === id) { return; }
        S.sel = id;
        renderOutline();
        renderInspector();
        drawOverlay();
    }

    // ------------------------------------------------------------- top bar

    function renderBar() {
        var st = $('hxb-status'), label = 'Draft', cls = 'mt-badge-warning';
        if (IS_LAYOUT) {
            if (S.dirty) { label = 'Unsaved changes'; }
            else if (S.status === 'new') { label = 'Not saved yet'; cls = 'mt-badge-neutral'; }
            else { label = boot.enabled ? 'Saved and live' : 'Saved'; cls = 'mt-badge-success'; }
        } else if (S.status === 'published') {
            if (S.dirty || S.pending) { label = 'Published, with unpublished changes'; }
            else { label = 'Published'; cls = 'mt-badge-success'; }
        } else if (S.status === 'new') {
            label = 'Not saved yet'; cls = 'mt-badge-neutral';
        } else if (S.dirty) {
            label = 'Draft, unsaved changes';
        }
        st.className = 'mt-badge ' + cls;
        st.textContent = label;
        $('hxb-save').disabled = S.busy;
        if ($('hxb-publish')) { $('hxb-publish').disabled = S.busy; }
    }

    function seg(id, key, after) {
        var box = $(id);
        box.addEventListener('click', function (e) {
            var b = e.target.closest('button[data-v]');
            if (!b) { return; }
            S[key] = b.getAttribute('data-v');
            Array.prototype.forEach.call(box.querySelectorAll('button'), function (x) { x.classList.toggle('is-active', x === b); });
            after();
        });
    }

    // ------------------------------------------------------------- palette

    function renderPalette() {
        var box = $('hxb-palette');
        Object.keys(TYPES).forEach(function (type) {
            var t = TYPES[type];
            if (t.fixed) { return; }
            var btn = el('button', { type: 'button', 'class': 'hxb-pal', title: t.hint, 'data-type': type, html: icon(type) + '<span></span>' });
            btn.querySelector('span').textContent = t.label;
            btn.addEventListener('pointerdown', function (e) { startDrag(e, { kind: 'new', type: type, label: t.label }, btn); });
            // Keyboard and plain click: add after the selection.
            btn.addEventListener('click', function () { if (!drag.moved) { insertAt(type, defaultIndex()); } });
            box.appendChild(btn);
        });
    }

    // ------------------------------------------------------------- outline

    function summary(b) {
        var p = b.props;
        switch (b.type) {
            case 'heading': return tGet(p.text, '_');
            case 'text': case 'callout': return plain(tGet(p.html, '_'));
            case 'button': return tGet(p.label, '_');
            case 'details': return (p.rows || []).length + ' rows';
            case 'image': return p.src ? p.src.split('/').pop() : 'No image yet';
            case 'html': return plain(p.code).slice(0, 60) || 'Empty';
            case 'spacer': return p.height + 'px';
            case 'footer': return plain(tGet(p.text, '_'));
            case 'header': return (p.nav || []).length + ' links';
            default: return TYPES[b.type].hint || '';
        }
    }

    function renderOutline() {
        outlineEl.innerHTML = '';
        if (!blocks().length) {
            outlineEl.appendChild(el('li', { 'class': 'hxb-out-empty', text: 'No blocks yet. Add one from the list above.' }));
            return;
        }
        blocks().forEach(function (b, i) {
            var grip = el('span', { 'class': 'hxb-out-grip', title: 'Drag to reorder', html: icon('grip') });
            var li = el('li', { 'class': 'hxb-out' + (b.id === S.sel ? ' is-sel' : ''), 'data-id': b.id, onclick: function () { select(b.id); } }, [
                grip,
                el('div', { 'class': 'hxb-out-text' }, [
                    el('div', { 'class': 'hxb-out-type', text: TYPES[b.type].label }),
                    el('div', { 'class': 'hxb-out-sum', text: summary(b) })
                ]),
                iconBtn('up', 'Move up', function () { nudge(b.id, -1); }),
                iconBtn('down', 'Move down', function () { nudge(b.id, 1); }),
                fixed(b) ? null : iconBtn('trash', 'Delete', function () { removeBlock(b.id); }, 'is-danger')
            ]);
            if (i === 0) { li.querySelector('[title="Move up"]').disabled = true; }
            if (i === blocks().length - 1) { li.querySelector('[title="Move down"]').disabled = true; }
            grip.addEventListener('pointerdown', function (e) { startDrag(e, { kind: 'move', id: b.id, label: TYPES[b.type].label }, grip); });
            outlineEl.appendChild(li);
        });
    }

    // ------------------------------------------------------------- preview

    var previewTimer = 0, previewSeq = 0, busyEl = null;

    function api(sub, payload) {
        payload.token = boot.token;
        return fetch(boot.api + '&action=' + sub, {
            method: 'POST', credentials: 'same-origin',
            headers: { 'Content-Type': 'application/json', 'X-Requested-With': 'XMLHttpRequest' },
            body: JSON.stringify(payload)
        }).then(function (res) {
            return res.text().then(function (text) {
                var data = null;
                try { data = JSON.parse(text); } catch (e) { /* an HTML error or login page */ }
                if (!data) { throw new Error(res.status === 200 ? 'Your session expired. Reload the page and sign in again.' : 'The server returned an error (' + res.status + ').'); }
                if (!data.ok && !data.errors) { throw new Error(data.error || 'Request failed.'); }
                return data;
            });
        });
    }

    function schedulePreview(delay) {
        clearTimeout(previewTimer);
        previewTimer = setTimeout(loadPreview, delay === undefined ? 280 : delay);
    }
    function loadPreview() {
        var seq = ++previewSeq;
        if (!busyEl) { busyEl = el('div', { 'class': 'hxb-busy', text: 'Updating' }); }
        device.appendChild(busyEl);
        api('api-preview', { kind: boot.kind, doc: S.doc, lang: S.lang, scheme: S.scheme, target: boot.target })
            .then(function (r) {
                if (seq !== previewSeq) { return; }
                frame.srcdoc = r.html;
                $('hxb-bytes').textContent = (r.bytes / 1024).toFixed(1) + ' KB';
            })
            .catch(function (err) { if (seq === previewSeq) { notice('danger', err.message); if (busyEl.parentNode) { busyEl.parentNode.removeChild(busyEl); } } });
    }

    function frameDoc() { try { return frame.contentDocument; } catch (e) { return null; } }

    function fitFrame() {
        var d = frameDoc();
        if (!d || !d.documentElement) { return; }
        // Collapse first, or a frame that was tall never shrinks.
        frame.style.height = '0px';
        var h = Math.max(d.documentElement.scrollHeight, d.body ? d.body.scrollHeight : 0, 240);
        frame.style.height = h + 'px';
        drawOverlay();
    }
    frame.addEventListener('load', function () {
        if (busyEl && busyEl.parentNode) { busyEl.parentNode.removeChild(busyEl); }
        fitFrame();
        // Images arrive after load and change the height; scripts cannot run
        // in the frame to tell us, so look again a few times.
        [120, 500, 1500].forEach(function (ms) { setTimeout(fitFrame, ms); });
    });
    window.addEventListener('resize', function () { fitFrame(); });

    // ------------------------------------------------------------- overlay

    function rects() {
        var d = frameDoc(), out = [];
        if (!d) { return out; }
        Array.prototype.forEach.call(d.querySelectorAll('[data-hx-block]'), function (n) {
            var r = n.getBoundingClientRect();
            out.push({ id: n.getAttribute('data-hx-block'), top: r.top, left: r.left, width: r.width, height: r.height, bottom: r.bottom });
        });
        return out;
    }
    function slotRect() {
        var d = frameDoc(), n = d ? d.querySelector('[data-hx-slot]') : null;
        return n ? n.getBoundingClientRect() : null;
    }
    function rectOf(id) { var all = rects(); for (var i = 0; i < all.length; i++) { if (all[i].id === id) { return all[i]; } } return null; }
    function hit(y, x) {
        var all = rects(), best = null;
        all.forEach(function (r) {
            // Innermost wins: in a layout the content row contains nothing
            // selectable, but be exact anyway.
            if (y >= r.top && y <= r.bottom && x >= r.left && x <= r.left + r.width) {
                if (!best || r.height < best.height) { best = r; }
            }
        });
        return best;
    }

    var hoverId = null;
    function box(r, cls) {
        return el('div', { 'class': 'hxb-box ' + cls, style: 'top:' + r.top + 'px;left:' + r.left + 'px;width:' + r.width + 'px;height:' + r.height + 'px;' });
    }
    function drawOverlay() {
        overlay.innerHTML = '';
        if (!IS_LAYOUT && !blocks().length) {
            var s = slotRect();
            if (s) {
                overlay.appendChild(el('div', { 'class': 'hxb-empty', text: 'This email is using its WHMCS text. Add a block to start designing it.',
                    style: 'top:' + (s.top + 8) + 'px;left:' + (s.left + 8) + 'px;width:' + Math.max(0, s.width - 16) + 'px;height:' + Math.max(40, s.height - 16) + 'px;' }));
            }
        }
        if (hoverId && hoverId !== S.sel) {
            var hr = rectOf(hoverId);
            if (hr) { overlay.appendChild(box(hr, 'is-hover')); }
        }
        var b = find(S.sel), r = b ? rectOf(S.sel) : null;
        if (b && r) {
            var i = indexOf(b.id);
            var sel = box(r, 'is-sel' + (r.top < 34 ? ' is-low' : ''));
            sel.appendChild(el('span', { 'class': 'hxb-tag', text: TYPES[b.type].label }));
            var up = iconBtn('up', 'Move up', function () { nudge(b.id, -1); });
            var dn = iconBtn('down', 'Move down', function () { nudge(b.id, 1); });
            up.disabled = i === 0;
            dn.disabled = i === blocks().length - 1;
            sel.appendChild(el('span', { 'class': 'hxb-acts' }, [
                up, dn,
                fixed(b) ? null : iconBtn('copy', 'Duplicate', function () { duplicate(b.id); }),
                fixed(b) ? null : iconBtn('trash', 'Delete', function () { removeBlock(b.id); }, 'is-danger')
            ]));
            overlay.appendChild(sel);
        }
        if (drag.line) { overlay.appendChild(drag.line); }
    }

    function local(e) { var o = overlay.getBoundingClientRect(); return { x: e.clientX - o.left, y: e.clientY - o.top, inside: e.clientX >= o.left && e.clientX <= o.right && e.clientY >= o.top && e.clientY <= o.bottom }; }

    overlay.addEventListener('pointermove', function (e) {
        if (drag.active) { return; }
        var p = local(e), h = hit(p.y, p.x), id = h ? h.id : null;
        if (id !== hoverId) { hoverId = id; drawOverlay(); }
    });
    overlay.addEventListener('pointerleave', function () { if (hoverId) { hoverId = null; drawOverlay(); } });
    overlay.addEventListener('pointerdown', function (e) {
        if (e.button !== 0) { return; }
        var p = local(e), h = hit(p.y, p.x);
        overlay.focus({ preventScroll: true });
        if (!h) { select(null); return; }
        select(h.id);
        var b = find(h.id);
        if (b) { startDrag(e, { kind: 'move', id: b.id, label: TYPES[b.type].label }, overlay); }
    });
    overlay.addEventListener('keydown', function (e) {
        var i = indexOf(S.sel);
        if (e.key === 'Escape') { select(null); return; }
        if (i < 0) {
            if ((e.key === 'ArrowDown' || e.key === 'ArrowUp') && blocks().length) { select(blocks()[0].id); e.preventDefault(); }
            return;
        }
        if (e.key === 'ArrowUp' || e.key === 'ArrowDown') {
            e.preventDefault();
            var by = e.key === 'ArrowUp' ? -1 : 1;
            if (e.altKey) { nudge(S.sel, by); }
            else if (blocks()[i + by]) { select(blocks()[i + by].id); }
        } else if (e.key === 'Delete' || e.key === 'Backspace') {
            e.preventDefault(); removeBlock(S.sel);
        } else if ((e.ctrlKey || e.metaKey) && e.key.toLowerCase() === 'd') {
            e.preventDefault(); duplicate(S.sel);
        }
    });

    // ------------------------------------------------------- drag and drop
    //
    // Pointer events with capture, not HTML5 drag and drop: the drop target
    // sits over an iframe, and native drag events over a frame go to the
    // frame's document, where nothing can listen.

    var drag = { active: false, moved: false, line: null };

    function startDrag(e, payload, captureEl) {
        if (e.button !== 0) { return; }
        drag = { active: false, moved: false, line: null, payload: payload, x: e.clientX, y: e.clientY, index: -1, ghost: null, el: captureEl, pid: e.pointerId };
        try { captureEl.setPointerCapture(e.pointerId); } catch (err) { /* synthetic event */ }
        captureEl.addEventListener('pointermove', onDragMove);
        captureEl.addEventListener('pointerup', onDragEnd);
        captureEl.addEventListener('pointercancel', onDragCancel);
    }
    function dropIndexCanvas(y) {
        var all = rects().filter(function (r) { return indexOf(r.id) >= 0; });
        if (!all.length) {
            var s = slotRect();
            return { index: 0, top: s ? s.top + 10 : 20, left: s ? s.left + 10 : 20, width: s ? s.width - 20 : overlay.clientWidth - 40 };
        }
        for (var i = 0; i < all.length; i++) {
            if (y < all[i].top + all[i].height / 2) {
                return { index: indexOf(all[i].id), top: all[i].top, left: all[i].left, width: all[i].width };
            }
        }
        var last = all[all.length - 1];
        return { index: indexOf(last.id) + 1, top: last.bottom, left: last.left, width: last.width };
    }
    function dropIndexOutline(clientY) {
        var items = outlineEl.querySelectorAll('.hxb-out'), base = outlineEl.getBoundingClientRect();
        for (var i = 0; i < items.length; i++) {
            var r = items[i].getBoundingClientRect();
            if (clientY < r.top + r.height / 2) { return { index: i, top: r.top - base.top }; }
        }
        var lr = items.length ? items[items.length - 1].getBoundingClientRect() : base;
        return { index: items.length, top: lr.bottom - base.top };
    }
    function clearLines() {
        drag.line = null;
        var old = outlineEl.querySelector('.hxb-out-line');
        if (old) { old.parentNode.removeChild(old); }
    }
    function onDragMove(e) {
        if (!drag.active) {
            if (Math.abs(e.clientX - drag.x) + Math.abs(e.clientY - drag.y) < 6) { return; }
            drag.active = true;
            drag.moved = true;
            root.classList.add('is-dragging');
            drag.ghost = el('div', { 'class': 'mt-wrap hxb-ghost', text: drag.payload.label });
            document.body.appendChild(drag.ghost);
            hoverId = null;
        }
        drag.ghost.style.left = e.clientX + 'px';
        drag.ghost.style.top = e.clientY + 'px';
        clearLines();
        drag.index = -1;

        var p = local(e), ob = outlineEl.getBoundingClientRect();
        if (p.inside) {
            var d = dropIndexCanvas(p.y);
            drag.index = d.index;
            drag.line = el('div', { 'class': 'hxb-line', style: 'top:' + d.top + 'px;left:' + d.left + 'px;width:' + d.width + 'px;' });
        } else if (e.clientX >= ob.left && e.clientX <= ob.right && e.clientY >= ob.top - 20 && e.clientY <= ob.bottom + 20) {
            var o = dropIndexOutline(e.clientY);
            drag.index = o.index;
            outlineEl.appendChild(el('li', { 'class': 'hxb-out-line', style: 'top:' + o.top + 'px;', 'aria-hidden': 'true' }));
        }
        drawOverlay();
    }
    function endDrag() {
        var d = drag;
        if (d.el) {
            d.el.removeEventListener('pointermove', onDragMove);
            d.el.removeEventListener('pointerup', onDragEnd);
            d.el.removeEventListener('pointercancel', onDragCancel);
            try { d.el.releasePointerCapture(d.pid); } catch (err) { /* already released */ }
        }
        if (d.ghost && d.ghost.parentNode) { d.ghost.parentNode.removeChild(d.ghost); }
        root.classList.remove('is-dragging');
        clearLines();
        // `moved` survives one tick so the click that follows a drag on a
        // palette button is not also treated as "add this block".
        var wasMoved = d.moved;
        drag = { active: false, moved: wasMoved, line: null };
        setTimeout(function () { drag.moved = false; }, 0);
        return d;
    }
    function onDragEnd() {
        var d = endDrag();
        if (d.active && d.index >= 0) {
            if (d.payload.kind === 'new') { insertAt(d.payload.type, d.index); }
            else { moveTo(d.payload.id, d.index); }
        }
        drawOverlay();
    }
    function onDragCancel() { endDrag(); drawOverlay(); }

    // ------------------------------------------------- merge-field popover

    var pop = null;
    function closePop() { if (pop && pop.parentNode) { pop.parentNode.removeChild(pop); } pop = null; }
    function openFields(anchor, insert) {
        closePop();
        pop = el('div', { 'class': 'mt-wrap hxb-pop', 'data-theme': document.getElementById('mt-admin-root').getAttribute('data-theme') || 'light' });
        Object.keys(boot.mergeFields).forEach(function (group) {
            pop.appendChild(el('div', { 'class': 'hxb-pop-group', text: group }));
            boot.mergeFields[group].forEach(function (name) {
                pop.appendChild(el('button', { type: 'button', text: '{$' + name + '}', onclick: function () { insert('{$' + name + '}'); closePop(); } }));
            });
        });
        document.body.appendChild(pop);
        var r = anchor.getBoundingClientRect();
        pop.style.left = Math.max(8, Math.min(window.innerWidth - 258, r.right - 250)) + 'px';
        pop.style.top = (r.bottom + 6 + 320 > window.innerHeight ? Math.max(8, r.top - 326) : r.bottom + 6) + 'px';
    }
    document.addEventListener('pointerdown', function (e) {
        if (pop && !pop.contains(e.target) && !(e.target.closest && e.target.closest('.hxb-mf, .hxb-ico.is-text'))) { closePop(); }
    });

    function insertIntoInput(input, text) {
        var a = input.selectionStart === null ? input.value.length : input.selectionStart;
        var b = input.selectionEnd === null ? input.value.length : input.selectionEnd;
        input.value = input.value.slice(0, a) + text + input.value.slice(b);
        input.focus();
        input.selectionStart = input.selectionEnd = a + text.length;
        input.dispatchEvent(new Event('input', { bubbles: true }));
    }

    // ------------------------------------------------------- field editors
    //
    // Each returns a DOM node and writes straight into `props`. The inspector
    // is rebuilt only when the selection or the language changes, never on a
    // keystroke, so typing never loses its caret.

    function fieldLabel(f, forId) {
        var kids = [el('span', { text: f.label })];
        if (f.translatable && S.lang !== '_') { kids.push(el('small', { text: langLabel() })); }
        return el('label', { 'class': 'hxb-label', 'for': forId }, kids);
    }
    function wrapField(f, id, control, inline) {
        var kids = inline ? [el('div', { 'class': 'hxb-inline' }, [fieldLabel(f, id), control])] : [fieldLabel(f, id), control];
        if (f.help) { kids.push(el('p', { 'class': 'hxb-help', text: f.help })); }
        return el('div', { 'class': 'hxb-field' }, kids);
    }
    function mfButton(target) {
        return el('button', { type: 'button', 'class': 'hxb-mf', title: 'Insert a merge field', 'aria-label': 'Insert a merge field', text: '{ }',
            onclick: function (e) { openFields(e.currentTarget, function (t) { insertIntoInput(target, t); }); } });
    }

    function textInput(props, f, id, opts) {
        opts = opts || {};
        var tr = !!f.translatable;
        var input = el('input', { type: 'text', 'class': 'mt-input', id: id, autocomplete: 'off', spellcheck: tr ? 'true' : 'false',
            value: tr ? tGet(props[f.key], S.lang) : (props[f.key] || ''),
            placeholder: tr && S.lang !== '_' ? (tGet(props[f.key], '_') || opts.placeholder || '') : (opts.placeholder || '') });
        input.addEventListener('input', function () {
            if (tr) { tSet(props, f.key, S.lang, input.value); } else { props[f.key] = input.value; }
            changed(false); touchOutline();
        });
        return el('div', { 'class': 'hxb-with-btn' }, [input, opts.noFields ? null : mfButton(input)]);
    }

    function richInput(props, f, id) {
        var area = el('div', { 'class': 'hxb-rich', id: id, contenteditable: 'true', role: 'textbox', 'aria-multiline': 'true',
            'data-placeholder': S.lang !== '_' ? (plain(tGet(props[f.key], '_')) || 'Translation') : 'Write here' });
        area.innerHTML = tGet(props[f.key], S.lang);
        function commit() {
            var html = area.innerHTML;
            if (plain(html) === '' && html.indexOf('<img') === -1) { html = ''; }
            tSet(props, f.key, S.lang, html);
            changed(false); touchOutline();
        }
        function cmd(name, arg) { area.focus(); document.execCommand(name, false, arg === undefined ? null : arg); commit(); }
        area.addEventListener('input', commit);
        area.addEventListener('focus', function () { try { document.execCommand('defaultParagraphSeparator', false, 'p'); } catch (e) { /* not supported */ } });
        // Paste as plain text: Word and web pages bring markup an email cannot use.
        area.addEventListener('paste', function (e) {
            e.preventDefault();
            var t = (e.clipboardData || window.clipboardData).getData('text/plain');
            document.execCommand('insertText', false, t);
        });
        var bar = el('div', { 'class': 'hxb-rich-bar' }, [
            el('button', { type: 'button', 'class': 'hxb-ico', title: 'Bold', text: 'B', onclick: function () { cmd('bold'); } }),
            el('button', { type: 'button', 'class': 'hxb-ico', title: 'Italic', style: 'font-style:italic;', text: 'I', onclick: function () { cmd('italic'); } }),
            el('button', { type: 'button', 'class': 'hxb-ico', title: 'Bulleted list', html: icon('details'), onclick: function () { cmd('insertUnorderedList'); } }),
            el('button', { type: 'button', 'class': 'hxb-ico', title: 'Link', html: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" aria-hidden="true"><path d="M10 14a4 4 0 005.7 0l3-3a4 4 0 00-5.7-5.7l-1 1"/><path d="M14 10a4 4 0 00-5.7 0l-3 3a4 4 0 005.7 5.7l1-1"/></svg>',
                onclick: function () {
                    var url = window.prompt('Link address. A merge field such as {$whmcs_url} works too.', 'https://');
                    if (url === null) { return; }
                    if (url.trim() === '') { cmd('unlink'); } else { cmd('createLink', url.trim()); }
                } }),
            el('button', { type: 'button', 'class': 'hxb-ico', title: 'Remove formatting', html: icon('x'), onclick: function () { cmd('removeFormat'); cmd('unlink'); } }),
            el('button', { type: 'button', 'class': 'hxb-ico is-text', title: 'Insert a merge field', text: '{ }',
                onclick: function (e) { openFields(e.currentTarget, function (t) { area.focus(); document.execCommand('insertText', false, t); commit(); }); } })
        ]);
        return el('div', { 'class': 'hxb-rich-wrap' }, [bar, area]);
    }

    function repeater(props, f) {
        var second = f.type === 'links' ? 'url' : 'value';
        var box = el('div', { 'class': 'hxb-rep' });
        function draw() {
            box.innerHTML = '';
            (props[f.key] || []).forEach(function (item, i) {
                var lf = { key: 'label', translatable: true };
                var label = textInput(item, lf, '', { placeholder: 'Label', noFields: true });
                var sf = { key: second };
                var other = textInput(item, sf, '', { placeholder: second === 'url' ? 'https:// or a merge field' : 'Value or a merge field' });
                box.appendChild(el('div', { 'class': 'hxb-rep-item' }, [
                    el('div', { 'class': 'hxb-rep-fields' }, [label, other]),
                    iconBtn('trash', 'Remove', function () { props[f.key].splice(i, 1); draw(); changed(false); touchOutline(); }, 'is-danger')
                ]));
            });
            var add = el('button', { type: 'button', 'class': 'hxb-add', text: second === 'url' ? '+ Add link' : '+ Add row',
                onclick: function () {
                    var item = { label: { _: '' } };
                    item[second] = '';
                    props[f.key] = props[f.key] || [];
                    props[f.key].push(item);
                    draw(); changed(false); touchOutline();
                    var inputs = box.querySelectorAll('.hxb-rep-item:last-of-type input');
                    if (inputs[0]) { inputs[0].focus(); }
                } });
            if ((props[f.key] || []).length >= (f.max || 10)) { add.disabled = true; }
            box.appendChild(add);
        }
        draw();
        return box;
    }

    var fieldSeq = 0;
    function editor(props, f) {
        var id = 'hxb-f' + (++fieldSeq), c;
        switch (f.type) {
            case 'toggle':
                c = el('label', { 'class': 'mt-toggle' }, [
                    el('input', { type: 'checkbox', id: id, checked: !!props[f.key], onchange: function (e) { props[f.key] = e.target.checked; changed(false); } }),
                    el('span', { 'class': 'mt-toggle-track' }, [el('span', { 'class': 'mt-toggle-thumb' })])
                ]);
                return wrapField(f, id, c, true);
            case 'select':
                c = el('select', { 'class': 'mt-select', id: id, onchange: function (e) { props[f.key] = e.target.value; changed(false); touchOutline(); } },
                    Object.keys(f.options).map(function (v) { return el('option', { value: v, selected: String(props[f.key]) === v, text: f.options[v] }); }));
                return wrapField(f, id, c);
            case 'number':
                c = el('div', { 'class': 'hxb-unit' }, [
                    el('input', { type: 'number', 'class': 'mt-input', id: id, min: f.min, max: f.max, value: props[f.key],
                        oninput: function (e) {
                            var n = parseInt(e.target.value, 10);
                            if (!isNaN(n)) { props[f.key] = Math.max(f.min, Math.min(f.max, n)); changed(false); touchOutline(); }
                        } }),
                    f.unit ? el('span', { text: f.unit }) : null
                ]);
                return wrapField(f, id, c, true);
            case 'rich':
                return wrapField(f, id, richInput(props, f, id));
            case 'links':
            case 'rows':
                return wrapField(f, id, repeater(props, f));
            case 'code':
                c = el('textarea', { 'class': 'mt-textarea hxb-code', id: id, spellcheck: 'false', wrap: 'off',
                    oninput: function (e) { props[f.key] = e.target.value; changed(false); touchOutline(); } });
                c.value = props[f.key] || '';
                var bar = el('div', { style: 'display:flex;justify-content:flex-end;margin-bottom:6px;' }, [mfButton(c)]);
                return wrapField(f, id, el('div', null, [bar, c]));
            case 'image':
                c = el('input', { type: 'text', 'class': 'mt-input', id: id, value: props[f.key] || '', placeholder: 'Choose an image',
                    'data-mt-media': true, 'data-mt-media-value': 'url', 'data-mt-media-collection': 'library',
                    'data-mt-media-title': 'Email image', 'data-mt-media-hint': 'PNG or JPG. Mail apps do not show SVG or WebP.' });
                ['input', 'change'].forEach(function (ev) { c.addEventListener(ev, function () { props[f.key] = c.value; changed(false); touchOutline(); }); });
                return wrapField(f, id, c);
            case 'url':
                return wrapField(f, id, textInput(props, f, id, { placeholder: 'https:// or a merge field' }));
            default:
                return wrapField(f, id, textInput(props, f, id));
        }
    }

    var outlineTimer = 0;
    function touchOutline() { clearTimeout(outlineTimer); outlineTimer = setTimeout(renderOutline, 400); }

    // ----------------------------------------------------------- inspector

    function renderInspector() {
        closePop();
        inspEl.innerHTML = '';
        var b = find(S.sel);
        if (!b) { renderDocPanel(); return; }
        var t = TYPES[b.type];
        inspEl.appendChild(el('div', { 'class': 'hxb-insp-head' }, [
            el('div', { 'class': 'hxb-insp-title', text: t.label }),
            el('div', null, [
                fixed(b) ? null : iconBtn('copy', 'Duplicate', function () { duplicate(b.id); }),
                fixed(b) ? null : iconBtn('trash', 'Delete', function () { removeBlock(b.id); }, 'is-danger')
            ])
        ]));
        inspEl.appendChild(el('p', { 'class': 'hxb-insp-sub', text: t.hint }));
        t.fields.forEach(function (f) { inspEl.appendChild(editor(b.props, f)); });
        if (b.type === 'header') {
            inspEl.appendChild(el('p', { 'class': 'hxb-help', text: 'The logo is set under Appearance on the Email page. With no logo that mail apps can show, your company name is used.' }));
        }
    }

    function renderDocPanel() {
        var s = S.doc.settings;
        if (IS_LAYOUT) {
            inspEl.appendChild(el('div', { 'class': 'hxb-insp-title', text: 'Layout' }));
            inspEl.appendChild(el('p', { 'class': 'hxb-insp-sub', text: 'The header and footer around every email. Select a block to edit it. Each email\'s own text appears where "Email content" sits.' }));
            renderDesignPicker();
            inspEl.appendChild(el('p', { 'class': 'hxb-help', text: boot.enabled
                ? 'Hadrian email is on: saving the layout changes the emails that go out from now on.'
                : 'Hadrian email is off. Save the layout, then turn it on from the Email page to start using it.' }));
            inspEl.appendChild(el('p', { 'class': 'hxb-help', text: 'Merge fields work in the header and footer. Conditions such as {if} do not: this part is the same for every email.' }));
        } else {
            inspEl.appendChild(el('div', { 'class': 'hxb-insp-title', text: 'Email settings' }));
            inspEl.appendChild(el('p', { 'class': 'hxb-insp-sub', text: 'Select a block on the canvas to edit it, or set the details that belong to the whole email here.' }));
            inspEl.appendChild(wrapField({ label: 'Subject', translatable: true, help: 'Leave empty to keep the subject set in WHMCS.' }, 'hxb-subject',
                textInput(s, { key: 'subject', translatable: true }, 'hxb-subject', { placeholder: boot.subject })));
            inspEl.appendChild(wrapField({ label: 'Preview text', translatable: true, help: 'The line an inbox shows after the subject. Needs Hadrian email to be on.' }, 'hxb-preheader',
                textInput(s, { key: 'preheader', translatable: true }, 'hxb-preheader')));
            if (S.status === 'published') {
                inspEl.appendChild(el('div', { 'class': 'hxb-divider' }));
                inspEl.appendChild(el('button', { type: 'button', 'class': 'hxb-linkbtn', text: 'Unpublish and restore the WHMCS template', onclick: restore }));
            }
        }
        inspEl.appendChild(el('div', { 'class': 'hxb-divider' }));
        inspEl.appendChild(el('div', { 'class': 'hxb-h', text: 'Merge fields' }));
        inspEl.appendChild(el('p', { 'class': 'hxb-help', style: 'margin:0 0 4px;', text: 'Click one to copy it, or use the { } button beside a field. Any WHMCS merge field can also be typed by hand.' }));
        Object.keys(boot.mergeFields).forEach(function (group) {
            inspEl.appendChild(el('div', { 'class': 'hxb-group-label', text: group }));
            inspEl.appendChild(el('div', { 'class': 'hxb-fields-list' }, boot.mergeFields[group].map(function (name) {
                return el('button', { type: 'button', 'class': 'hxb-chip', text: name, title: 'Copy {$' + name + '}', onclick: function (e) {
                    var token = '{$' + name + '}', chip = e.currentTarget;
                    var done = function () { chip.textContent = 'copied'; setTimeout(function () { chip.textContent = name; }, 900); };
                    if (navigator.clipboard && navigator.clipboard.writeText) { navigator.clipboard.writeText(token).then(done, function () {}); }
                } });
            })));
        });
    }

    // The layout designs (Designs.php). Picking one sets the document's design
    // and the design's starting options on the blocks it names; everything
    // the admin wrote stays. Same rule as Designs::apply() on the server.
    function applyDesign(id) {
        var d = boot.designs[id];
        if (!d) { return; }
        S.doc.settings.design = id;
        blocks().forEach(function (b) {
            var set = d.presets[b.type];
            if (!set) { return; }
            Object.keys(set).forEach(function (k) { b.props[k] = set[k]; });
        });
        changed(true);
        renderInspector();
    }
    function renderDesignPicker() {
        var ids = Object.keys(boot.designs || {});
        if (!ids.length) { return; }
        var current = S.doc.settings.design || ids[0];
        inspEl.appendChild(el('div', { 'class': 'hxb-h', text: 'Design' }));
        var list = el('div', { 'class': 'hxb-designs', role: 'radiogroup', 'aria-label': 'Design' });
        ids.forEach(function (id) {
            var d = boot.designs[id];
            list.appendChild(el('button', {
                type: 'button', role: 'radio', 'aria-checked': id === current ? 'true' : 'false',
                'class': 'hxb-design' + (id === current ? ' is-active' : ''), 'data-design': id,
                onclick: function () { if (id !== S.doc.settings.design) { applyDesign(id); } }
            }, [el('strong', { text: d.label }), el('span', { text: d.description })]));
        });
        inspEl.appendChild(list);
        inspEl.appendChild(el('p', { 'class': 'hxb-help', text: 'Switching keeps your texts and links. It resets alignment, the content card and the subject title to suit the design.' }));
    }

    // -------------------------------------------------------------- saving

    function notice(kind, message, list) {
        noticeEl.innerHTML = '';
        if (!message) { return; }
        var box = el('div', { 'class': 'mt-alert mt-alert-' + kind, role: kind === 'danger' ? 'alert' : 'status' }, [el('span', { text: message })]);
        if (list && list.length) { box.appendChild(el('ul', null, list.map(function (t) { return el('li', { text: t }); }))); }
        noticeEl.appendChild(box);
    }
    function busy(on) { S.busy = on; renderBar(); }

    function save() {
        busy(true);
        return api('api-save', { id: S.id, kind: boot.kind, target: boot.target, doc: S.doc }).then(function (r) {
            S.id = r.id;
            S.status = r.status;
            S.dirty = false;
            if (S.status === 'published') { S.pending = true; }
            if (r.live !== undefined) { boot.enabled = !!r.live; }
            busy(false);
            return r;
        }, function (err) { busy(false); throw err; });
    }
    $('hxb-save').addEventListener('click', function () {
        save().then(function (r) {
            if (IS_LAYOUT) { notice('success', r.live ? 'Layout saved. Emails sent from now on use it.' : 'Layout saved. Turn Hadrian email on from the Email page to start using it.'); }
            else if (S.status === 'published') { notice('info', 'Saved. Clients still receive the published version until you publish again.'); }
            else { notice('success', 'Draft saved. Nothing changes in WHMCS until you publish.'); }
            if (!find(S.sel)) { renderInspector(); }
        }).catch(function (err) { notice('danger', err.message); });
    });
    if ($('hxb-publish')) {
        $('hxb-publish').addEventListener('click', function () {
            save().then(function () {
                busy(true);
                return api('api-publish', { id: S.id });
            }).then(function (r) {
                busy(false);
                if (!r.ok) { notice('danger', 'This design could not be published.', r.errors || []); return; }
                S.status = 'published';
                S.pending = false;
                renderBar();
                notice('success', 'Published to the "' + boot.target + '" email template' + (r.languages.length > 1 ? ' in ' + r.languages.length + ' languages' : '') + '.'
                    + (boot.enabled ? '' : ' Hadrian email is off, so it goes out inside WHMCS\'s own header and footer.'));
                if (!find(S.sel)) { renderInspector(); }
            }).catch(function (err) { busy(false); notice('danger', err.message); });
        });
    }
    function restore() {
        if (!window.confirm('Unpublish this design? The WHMCS email template goes back to how it was before the design was published. The design is kept as a draft.')) { return; }
        busy(true);
        api('api-restore', { id: S.id }).then(function () {
            S.status = 'draft';
            S.pending = false;
            busy(false);
            notice('success', 'Unpublished. WHMCS is using its original template again.');
            renderInspector();
        }).catch(function (err) { busy(false); notice('danger', err.message); });
    }

    window.addEventListener('beforeunload', function (e) {
        if (S.dirty) { e.preventDefault(); e.returnValue = ''; }
    });

    // ---------------------------------------------------------------- boot

    var langSel = $('hxb-lang');
    boot.languages.forEach(function (l) { langSel.appendChild(el('option', { value: l.code, text: l.label })); });
    langSel.addEventListener('change', function () { S.lang = langSel.value; renderInspector(); schedulePreview(0); });
    if (boot.languages.length < 2) { langSel.hidden = true; }

    seg('hxb-scheme', 'scheme', function () { schedulePreview(0); });
    seg('hxb-device', 'device', function () {
        device.classList.toggle('is-mobile', S.device === 'mobile');
        // The width transition changes the layout the rectangles were read from.
        [30, 260].forEach(function (ms) { setTimeout(fitFrame, ms); });
    });

    if (boot.drift && boot.drift.length) {
        notice('warning', 'This email\'s template was edited in WHMCS after it was published. Publishing again replaces that edit.');
    } else if (S.status === 'new' && !IS_LAYOUT) {
        notice('info', boot.starter
            ? 'This is a starter design for this email. Nothing changes in WHMCS until you publish.'
            : 'This email\'s current WHMCS text was carried over as a starting point. Nothing changes in WHMCS until you publish.');
    }

    renderPalette();
    renderOutline();
    renderInspector();
    renderBar();
    loadPreview();

    // For the test suite and for debugging from the console.
    window.hxBuilder = { state: S, rects: rects, insertAt: insertAt, moveTo: moveTo, select: select, removeBlock: removeBlock };
})();
