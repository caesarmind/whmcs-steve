/* Page builder editor. Inlined into views/editor.tpl by AdminController.
   Plain browser JavaScript, no build step, ASCII only.

   The page is one document (state.doc): an ordered list of sections. Every
   control on this screen is generated from the section schemas the server
   sent in the boot data, so adding a section type needs no change here.

   The preview is the real page. Each change posts the document, the server
   keeps it for this admin's session, and the frame loads the address where
   the theme draws it. */
(function () {
    'use strict';

    var boot = JSON.parse(document.getElementById('hbx-boot').textContent);
    var byId = function (id) { return document.getElementById(id); };

    var state = {
        doc: boot.doc, name: boot.name, slug: boot.slug, meta: boot.meta,
        status: boot.status, changed: boot.changed, pageUrl: boot.pageUrl,
        sel: null,          // id of the selected section; null shows page settings
        lang: '_',          // '_' edits the default text
        dirty: false,
        open: {},           // which item of a list field is expanded: "sectionId.field" -> index
        errors: {}          // field -> message, from the last save
    };
    var past = [], future = [], lastTouch = { key: '', at: 0 };

    // ------------------------------------------------------------- helpers

    function el(tag, attrs, children) {
        var node = document.createElement(tag), k;
        attrs = attrs || {};
        for (k in attrs) {
            if (!Object.prototype.hasOwnProperty.call(attrs, k) || attrs[k] === null || attrs[k] === undefined) { continue; }
            if (k === 'text') { node.textContent = attrs[k]; }
            else if (k === 'html') { node.innerHTML = attrs[k]; }
            else if (k.slice(0, 2) === 'on') { node.addEventListener(k.slice(2), attrs[k]); }
            else if (k === 'checked' || k === 'selected' || k === 'disabled' || k === 'hidden') { node[k] = !!attrs[k]; }
            else if (k === 'value') { node.value = attrs[k]; }
            else { node.setAttribute(k, attrs[k]); }
        }
        (children || []).forEach(function (c) { if (c) { node.appendChild(typeof c === 'string' ? document.createTextNode(c) : c); } });
        return node;
    }
    function clone(v) { return JSON.parse(JSON.stringify(v)); }
    function newId() {
        var s = 's', hex = '0123456789abcdef', i;
        for (i = 0; i < 10; i++) { s += hex.charAt(Math.floor(Math.random() * 16)); }
        return s;
    }
    function icon(d) {
        return '<svg viewBox="0 0 16 16" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">' + d + '</svg>';
    }
    var ICON = {
        grip: '<circle cx="5" cy="4" r="1" fill="currentColor"/><circle cx="11" cy="4" r="1" fill="currentColor"/><circle cx="5" cy="8" r="1" fill="currentColor"/><circle cx="11" cy="8" r="1" fill="currentColor"/><circle cx="5" cy="12" r="1" fill="currentColor"/><circle cx="11" cy="12" r="1" fill="currentColor"/>',
        up: '<path d="M4 10l4-4 4 4"/>',
        down: '<path d="M4 6l4 4 4-4"/>',
        copy: '<rect x="5" y="5" width="8" height="8" rx="2"/><path d="M3 10V4a1 1 0 011-1h6"/>',
        trash: '<path d="M3 4h10M6 4V3h4v1M5 4l1 9h4l1-9"/>',
        eye: '<path d="M1.5 8S4 3.5 8 3.5 14.5 8 14.5 8 12 12.5 8 12.5 1.5 8 1.5 8z"/><circle cx="8" cy="8" r="2"/>',
        eyeOff: '<path d="M2 2l12 12M6.5 4A6.8 6.8 0 0114.5 8a8 8 0 01-1.8 2.3M10 11.9A6.8 6.8 0 011.5 8 8 8 0 014 5.2"/>'
    };
    function iconBtn(name, title, onclick, extra) {
        return el('button', { type: 'button', 'class': 'hbx-ico' + (extra ? ' ' + extra : ''), title: title, 'aria-label': title, html: icon(ICON[name]), onclick: onclick });
    }
    function sectionById(id) {
        var i;
        for (i = 0; i < state.doc.sections.length; i++) { if (state.doc.sections[i].id === id) { return state.doc.sections[i]; } }
        return null;
    }
    function indexOf(id) {
        var i;
        for (i = 0; i < state.doc.sections.length; i++) { if (state.doc.sections[i].id === id) { return i; } }
        return -1;
    }
    function langLabel() {
        var i;
        for (i = 0; i < boot.languages.length; i++) { if (boot.languages[i].code === state.lang) { return boot.languages[i].label; } }
        return '';
    }
    function pick(v) {
        if (v === null || v === undefined) { return ''; }
        if (typeof v !== 'object') { return String(v); }
        return (state.lang !== '_' && v[state.lang]) ? v[state.lang] : (v._ || '');
    }

    // ------------------------------------------------------- history + dirty

    function snapshot() { return JSON.stringify({ doc: state.doc, name: state.name, slug: state.slug, meta: state.meta }); }

    /* Call BEFORE changing state. Typing in one field within a second is one
       undo step, not one per keystroke. */
    function touch(key) {
        var now = Date.now();
        if (!(key && key === lastTouch.key && now - lastTouch.at < 1000)) {
            past.push(snapshot());
            if (past.length > 80) { past.shift(); }
            future = [];
        }
        lastTouch = { key: key || '', at: now };
    }
    function changed(structural) {
        state.dirty = true;
        renderStatus();
        renderOutline();
        if (structural) { renderInspector(); }
        schedulePreview();
    }
    function restore(json) {
        var s = JSON.parse(json);
        state.doc = s.doc; state.name = s.name; state.slug = s.slug; state.meta = s.meta;
        if (state.sel && !sectionById(state.sel)) { state.sel = null; }
        lastTouch = { key: '', at: 0 };
        byId('hbx-name').textContent = state.name;
        changed(true);
    }
    function undo() { if (past.length) { future.push(snapshot()); restore(past.pop()); } }
    function redo() { if (future.length) { past.push(snapshot()); restore(future.pop()); } }

    // --------------------------------------------------------------- server

    function api(action, payload) {
        payload.token = boot.token;
        payload.id = boot.id;
        return fetch(boot.api + '&action=' + action, {
            method: 'POST', credentials: 'same-origin',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(payload)
        }).then(function (r) {
            return r.json().catch(function () {
                return { ok: false, error: 'The server sent a reply this page could not read (HTTP ' + r.status + '). You may have been signed out.' };
            });
        }).catch(function () {
            return { ok: false, error: 'Could not reach the server. Check your connection and try again.' };
        });
    }

    function notice(kind, message) {
        var box = byId('hbx-notice');
        box.textContent = '';
        if (message) { box.appendChild(el('div', { 'class': 'mt-alert mt-alert-' + kind, text: message })); }
    }

    function save() {
        notice('', '');
        setBusy(true);
        return api('api-save', { doc: state.doc, name: state.name, slug: state.slug, meta: state.meta }).then(function (res) {
            setBusy(false);
            state.errors = {};
            if (!res.ok) {
                if (res.field) { state.errors[res.field] = res.error; state.sel = null; renderOutline(); renderInspector(); }
                notice('danger', res.error);
                return false;
            }
            state.doc = res.doc; state.meta = res.meta; state.name = res.name; state.slug = res.slug;
            state.status = res.status; state.changed = res.changed; state.pageUrl = res.pageUrl;
            state.dirty = false;
            if (state.sel && !sectionById(state.sel)) { state.sel = null; }
            byId('hbx-name').textContent = state.name;
            renderStatus(); renderOutline(); renderInspector();
            return true;
        });
    }

    function publish() {
        save().then(function (ok) {
            if (!ok) { return; }
            setBusy(true);
            api('api-publish', {}).then(function (res) {
                setBusy(false);
                if (!res.ok) {
                    if (res.field) { state.errors[res.field] = res.error; state.sel = null; renderOutline(); renderInspector(); }
                    notice('danger', res.error);
                    return;
                }
                state.status = res.status; state.changed = res.changed; state.pageUrl = res.pageUrl;
                renderStatus();
                notice('success', 'Published. The page is live at ' + state.pageUrl);
            });
        });
    }

    function unpublish() {
        if (!window.confirm('Take this page offline? Its address will show "page not found" until you publish it again.')) { return; }
        api('api-unpublish', {}).then(function (res) {
            if (!res.ok) { notice('danger', res.error); return; }
            state.status = res.status; state.changed = false;
            renderStatus(); renderInspector();
            notice('info', 'The page is offline. Your draft is kept.');
        });
    }

    // -------------------------------------------------------------- preview

    var frame = byId('hbx-frame'), pvTimer = null, pvSeq = 0, scrollToSel = false;
    // A preview is settled when no update is waiting and the newest one has loaded.
    var pvQueued = false, pvLoading = false, pvAssigned = 0;

    function setBusy(on) { byId('hbx-busy').hidden = !on; }

    /* Lay the frame out at the device's real width and scale it to fit the
       stage, so "Desktop" shows the desktop layout even beside two panels. */
    var DEVICE = { desktop: 1280, tablet: 820, mobile: 390 }, device = 'desktop';
    function fitFrame() {
        var canvas = byId('hbx-canvas'), stage = canvas.parentNode;
        var avail = Math.max(240, stage.clientWidth - 50);
        var width = DEVICE[device], scale = Math.min(1, avail / width);
        var height = Math.max(480, window.innerHeight - 170);
        canvas.style.width = Math.round(width * scale) + 'px';
        canvas.style.height = height + 'px';
        frame.style.width = width + 'px';
        frame.style.height = Math.round(height / scale) + 'px';
        frame.style.transform = scale < 1 ? 'scale(' + scale + ')' : 'none';
        byId('hbx-scale').textContent = width + ' px wide' + (scale < 1 ? ', shown at ' + Math.round(scale * 100) + '%' : '');
    }

    function schedulePreview(now) {
        window.clearTimeout(pvTimer);
        pvQueued = true;
        pvTimer = window.setTimeout(runPreview, now ? 0 : 450);
    }
    function runPreview() {
        var seq = ++pvSeq;
        pvQueued = false;
        pvLoading = true;
        setBusy(true);
        api('api-preview', { doc: state.doc, lang: state.lang }).then(function (res) {
            if (seq !== pvSeq) { return; }
            if (!res.ok) { pvLoading = false; setBusy(false); notice('danger', res.error); return; }
            var y = 0;
            try { y = frame.contentWindow.pageYOffset || 0; } catch (e) { y = 0; }
            frame.setAttribute('data-restore', String(y));
            pvAssigned = seq;
            frame.src = res.url;
        });
    }
    function frameDoc() {
        try { return frame.contentDocument; } catch (e) { return null; }
    }
    function markSelected() {
        var doc = frameDoc(), nodes, i, target = null;
        if (!doc) { return; }
        nodes = doc.querySelectorAll('[data-hb-id]');
        for (i = 0; i < nodes.length; i++) {
            if (nodes[i].getAttribute('data-hb-id') === state.sel) { nodes[i].classList.add('hbx-sel'); target = nodes[i]; }
            else { nodes[i].classList.remove('hbx-sel'); }
        }
        if (target && scrollToSel) { target.scrollIntoView({ block: 'start' }); }
        scrollToSel = false;
    }
    frame.addEventListener('load', function () {
        var doc = frameDoc(), style, y;
        if (!frame.getAttribute('src')) { return; }
        if (pvAssigned === pvSeq) { pvLoading = false; }
        setBusy(false);
        if (!doc || !doc.body) { return; }
        style = doc.createElement('style');
        style.textContent = '[data-hb-id]{cursor:pointer}'
            + '[data-hb-id]:hover{outline:1px solid rgba(0,113,227,.55);outline-offset:-1px}'
            + '[data-hb-id].hbx-sel{outline:2px solid #0071e3;outline-offset:-2px}';
        doc.head.appendChild(style);
        // Nothing in the preview navigates or submits: a click only selects.
        doc.addEventListener('click', function (e) {
            var t = e.target, link = t.closest ? t.closest('a, button[type="submit"]') : null, sec = t.closest ? t.closest('[data-hb-id]') : null;
            if (link) { e.preventDefault(); }
            if (sec) { select(sec.getAttribute('data-hb-id'), false); }
        }, true);
        doc.addEventListener('submit', function (e) { e.preventDefault(); }, true);
        y = parseInt(frame.getAttribute('data-restore') || '0', 10);
        if (!scrollToSel && y > 0) { frame.contentWindow.scrollTo(0, y); }
        markSelected();
    });

    // --------------------------------------------------------------- status

    function renderStatus() {
        var badge = byId('hbx-status'), label, kind, view = byId('hbx-view');
        if (state.dirty) { label = 'Unsaved changes'; kind = 'warning'; }
        else if (state.status === 'published' && state.changed) { label = 'Published, draft is newer'; kind = 'warning'; }
        else if (state.status === 'published') { label = 'Published'; kind = 'success'; }
        else { label = 'Draft'; kind = 'neutral'; }
        badge.textContent = label;
        badge.className = 'mt-badge mt-badge-' + kind;
        byId('hbx-publish').textContent = state.status === 'published' ? 'Publish changes' : 'Publish';
        view.hidden = !(state.status === 'published' && state.pageUrl);
        if (state.pageUrl) { view.setAttribute('href', state.pageUrl); }
        byId('hbx-undo').disabled = past.length === 0;
        byId('hbx-redo').disabled = future.length === 0;
    }

    // -------------------------------------------------------------- outline

    function summary(section) {
        var def = boot.types[section.type], i, f, v;
        if (!def) { return ''; }
        for (i = 0; i < def.fields.length; i++) {
            f = def.fields[i];
            if (f.type === 'text') {
                v = pick(section.props[f.key]);
                if (v) { return v; }
            }
        }
        return '';
    }

    var dragId = null;

    function renderOutline() {
        var list = byId('hbx-outline');
        list.textContent = '';
        if (!state.doc.sections.length) {
            list.appendChild(el('li', { 'class': 'hbx-out-empty', text: 'No sections yet. Add one below.' }));
        }
        state.doc.sections.forEach(function (section) {
            var def = boot.types[section.type] || { label: section.type };
            var item = el('li', {
                'class': 'hbx-out' + (section.id === state.sel ? ' is-sel' : '') + (section.hidden ? ' is-hidden' : ''),
                draggable: 'true', 'data-id': section.id,
                onclick: function () { select(section.id, true); },
                ondragstart: function (e) { dragId = section.id; item.classList.add('is-dragged'); e.dataTransfer.effectAllowed = 'move'; e.dataTransfer.setData('text/plain', section.id); },
                ondragend: function () { dragId = null; renderOutline(); },
                ondragover: function (e) {
                    if (!dragId || dragId === section.id) { return; }
                    e.preventDefault();
                    var r = item.getBoundingClientRect(), before = e.clientY < r.top + r.height / 2;
                    item.classList.toggle('is-over-before', before);
                    item.classList.toggle('is-over-after', !before);
                },
                ondragleave: function () { item.classList.remove('is-over-before', 'is-over-after'); },
                ondrop: function (e) {
                    if (!dragId || dragId === section.id) { return; }
                    e.preventDefault();
                    var r = item.getBoundingClientRect(), before = e.clientY < r.top + r.height / 2;
                    moveTo(dragId, section.id, before);
                }
            }, [
                el('span', { 'class': 'hbx-out-grip', html: icon(ICON.grip), title: 'Drag to reorder' }),
                el('span', { 'class': 'hbx-out-text' }, [
                    el('div', { 'class': 'hbx-out-type', text: def.label }),
                    el('div', { 'class': 'hbx-out-sum', text: section.hidden ? 'Hidden' : summary(section) })
                ]),
                iconBtn(section.hidden ? 'eyeOff' : 'eye', section.hidden ? 'Show on the page' : 'Hide from the page', function (e) {
                    e.stopPropagation(); touch(''); section.hidden = !section.hidden; changed(true);
                }),
                iconBtn('trash', 'Remove section', function (e) { e.stopPropagation(); removeSection(section.id); }, 'is-danger')
            ]);
            list.appendChild(item);
        });
        byId('hbx-pagebtn').classList.toggle('is-sel', state.sel === null);
    }

    function select(id, scroll) {
        if (id !== null && !sectionById(id)) { id = null; }
        state.sel = id;
        scrollToSel = !!scroll;
        renderOutline();
        renderInspector();
        markSelected();
    }

    function moveTo(id, targetId, before) {
        var from = indexOf(id), moved, to;
        if (from < 0) { return; }
        touch('');
        moved = state.doc.sections.splice(from, 1)[0];
        to = indexOf(targetId);
        state.doc.sections.splice(before ? to : to + 1, 0, moved);
        changed(true);
    }
    function moveBy(id, delta) {
        var from = indexOf(id), to = from + delta, moved;
        if (from < 0 || to < 0 || to >= state.doc.sections.length) { return; }
        touch('');
        moved = state.doc.sections.splice(from, 1)[0];
        state.doc.sections.splice(to, 0, moved);
        scrollToSel = true;
        changed(true);
    }
    function removeSection(id) {
        var at = indexOf(id);
        if (at < 0) { return; }
        touch('');
        state.doc.sections.splice(at, 1);
        if (state.sel === id) { state.sel = null; }
        changed(true);
    }
    function duplicateSection(id) {
        var at = indexOf(id), copy;
        if (at < 0) { return; }
        touch('');
        copy = clone(state.doc.sections[at]);
        copy.id = newId();
        copy.style.anchor = '';        // two elements cannot share an id
        state.doc.sections.splice(at + 1, 0, copy);
        state.sel = copy.id;
        scrollToSel = true;
        changed(true);
    }
    function addSection(type) {
        var def = boot.types[type], props = {}, section, at;
        if (!def) { return; }
        def.fields.forEach(function (f) { props[f.key] = clone(f['default']); });
        section = { id: newId(), type: type, props: props, style: { spacing: 'regular', anchor: '' }, hidden: false };
        touch('');
        at = state.sel ? indexOf(state.sel) + 1 : state.doc.sections.length;
        state.doc.sections.splice(at, 0, section);
        state.sel = section.id;
        scrollToSel = true;
        changed(true);
    }

    function renderPalette() {
        var box = byId('hbx-palette'), groups = {}, order = [];
        Object.keys(boot.types).forEach(function (type) {
            var g = boot.types[type].group || 'Other';
            if (!groups[g]) { groups[g] = []; order.push(g); }
            groups[g].push(type);
        });
        box.textContent = '';
        order.forEach(function (g) {
            box.appendChild(el('div', { 'class': 'hbx-pal-group', text: g }));
            groups[g].forEach(function (type) {
                box.appendChild(el('button', { type: 'button', 'class': 'hbx-pal', onclick: function () { addSection(type); } }, [
                    el('strong', { text: boot.types[type].label }),
                    el('span', { text: boot.types[type].hint })
                ]));
            });
        });
    }

    // ------------------------------------------------------------ inspector

    var fieldSeq = 0;

    function getValue(f, obj) {
        var v = obj[f.key];
        if (!f.translatable) { return v; }
        if (v === null || v === undefined || typeof v !== 'object') { v = obj[f.key] = { _: v === null || v === undefined ? '' : String(v) }; }
        return state.lang === '_' ? (v._ || '') : (v[state.lang] || '');
    }
    function setValue(f, obj, value) {
        var v;
        if (!f.translatable) { obj[f.key] = value; return; }
        v = obj[f.key];
        if (v === null || v === undefined || typeof v !== 'object') { v = obj[f.key] = { _: '' }; }
        if (state.lang === '_') { v._ = value; }
        else if (value === '') { delete v[state.lang]; }
        else { v[state.lang] = value; }
    }
    function translationHint(f, obj) {
        var v = obj[f.key];
        return (f.translatable && state.lang !== '_' && v && typeof v === 'object') ? (v._ || '') : '';
    }

    function wrapField(f, id, control, inline) {
        var label = el('label', { 'class': 'hbx-label', 'for': id }, [el('span', { text: f.label })]);
        if (f.translatable && state.lang !== '_') { label.appendChild(el('small', { text: langLabel() })); }
        var field = el('div', { 'class': 'hbx-field' });
        if (inline) { field.appendChild(el('div', { 'class': 'hbx-inline' }, [label, control])); }
        else { field.appendChild(label); field.appendChild(control); }
        if (f.help) { field.appendChild(el('p', { 'class': 'hbx-help', text: f.help })); }
        return field;
    }

    /* One control for one field. `obj` is the object that holds the value
       (a section's props, or one item of a list); `path` names it for undo. */
    function fieldEl(f, obj, path) {
        var id = 'hbx-f' + (++fieldSeq), key = path + '.' + f.key, c;
        var onText = function (e) { touch(key); setValue(f, obj, e.target.value); changed(false); };

        switch (f.type) {
            case 'text':
            case 'link':
                c = el('input', { type: 'text', 'class': 'mt-input', id: id, value: getValue(f, obj) || '',
                    placeholder: f.type === 'link' ? 'https://, #section or cart.php?gid=1' : translationHint(f, obj), oninput: onText });
                return wrapField(f, id, c);

            case 'textarea':
                c = el('textarea', { 'class': 'mt-input', id: id, rows: '3', placeholder: translationHint(f, obj), oninput: onText });
                c.value = getValue(f, obj) || '';
                return wrapField(f, id, c);

            case 'rich':
                return wrapField(f, id, richEl(f, obj, key, id));

            case 'image':
                c = el('input', { type: 'text', 'class': 'mt-input', id: id, value: getValue(f, obj) || '', placeholder: 'Choose an image',
                    'data-mt-media': '', 'data-mt-media-value': 'url', 'data-mt-media-collection': 'library',
                    'data-mt-media-title': f.label, 'data-mt-media-hint': 'JPG, PNG, WebP or SVG', oninput: onText });
                return wrapField(f, id, c);

            case 'number':
                c = el('div', { 'class': 'hbx-unit' }, [
                    el('input', { type: 'number', 'class': 'mt-input', id: id, value: String(getValue(f, obj)), min: String(f.min), max: String(f.max),
                        oninput: function (e) { touch(key); obj[f.key] = parseInt(e.target.value, 10) || 0; changed(false); } }),
                    f.unit ? el('span', { text: f.unit }) : null
                ]);
                return wrapField(f, id, c, true);

            case 'toggle':
                c = el('label', { 'class': 'mt-toggle' }, [
                    el('input', { type: 'checkbox', id: id, checked: !!obj[f.key], onchange: function (e) { touch(''); obj[f.key] = e.target.checked; changed(false); } }),
                    el('span', { 'class': 'mt-toggle-track' }, [el('span', { 'class': 'mt-toggle-thumb' })])
                ]);
                return wrapField(f, id, c, true);

            case 'select':
                c = el('select', { 'class': 'mt-select', id: id, onchange: function (e) { touch(''); obj[f.key] = e.target.value; changed(false); } },
                    Object.keys(f.options).map(function (v) { return el('option', { value: v, selected: String(obj[f.key]) === v, text: f.options[v] }); }));
                return wrapField(f, id, c);

            case 'product':
                return wrapField(f, id, productEl(f, obj, id));

            case 'icon':
                return wrapField(f, id, iconEl(f, obj));

            case 'list':
                return listEl(f, obj, path);
        }
        return el('div');
    }

    function richEl(f, obj, key, id) {
        var area = el('div', { 'class': 'hbx-rich', id: id, contenteditable: 'true', 'data-placeholder': translationHint(f, obj).replace(/<[^>]+>/g, '') || 'Write here' });
        area.innerHTML = getValue(f, obj) || '';
        var sync = function () { touch(key); setValue(f, obj, area.innerHTML === '<br>' ? '' : area.innerHTML); changed(false); };
        area.addEventListener('input', sync);
        var cmd = function (name, arg) { return function (e) { e.preventDefault(); area.focus(); document.execCommand(name, false, arg || null); sync(); }; };
        var bar = el('div', { 'class': 'hbx-rich-bar' }, [
            el('button', { type: 'button', 'class': 'hbx-ico', title: 'Bold', text: 'B', onmousedown: cmd('bold') }),
            el('button', { type: 'button', 'class': 'hbx-ico', title: 'Italic', text: 'I', style: 'font-style:italic', onmousedown: cmd('italic') }),
            el('button', { type: 'button', 'class': 'hbx-ico', title: 'Bulleted list', html: icon('<path d="M6 4h8M6 8h8M6 12h8"/><circle cx="2.5" cy="4" r="1" fill="currentColor"/><circle cx="2.5" cy="8" r="1" fill="currentColor"/><circle cx="2.5" cy="12" r="1" fill="currentColor"/>'), onmousedown: cmd('insertUnorderedList') }),
            el('button', { type: 'button', 'class': 'hbx-ico', title: 'Link', html: icon('<path d="M7 9a3 3 0 004.2 0l2-2a3 3 0 00-4.2-4.2l-.7.7"/><path d="M9 7a3 3 0 00-4.2 0l-2 2a3 3 0 004.2 4.2l.7-.7"/>'), onmousedown: function (e) {
                e.preventDefault();
                area.focus();
                var url = window.prompt('Link address. Leave empty to remove the link.', 'https://');
                if (url === null) { return; }
                document.execCommand(url === '' || url === 'https://' ? 'unlink' : 'createLink', false, url);
                sync();
            } })
        ]);
        return el('div', { 'class': 'hbx-rich-wrap' }, [bar, area]);
    }

    function productEl(f, obj, id) {
        var groups = {}, order = [], select;
        boot.products.forEach(function (p) {
            var g = p.group || 'Products';
            if (!groups[g]) { groups[g] = []; order.push(g); }
            groups[g].push(p);
        });
        select = el('select', { 'class': 'mt-select', id: id, onchange: function (e) { touch(''); obj[f.key] = parseInt(e.target.value, 10) || 0; changed(true); } },
            [el('option', { value: '0', text: 'Choose a product', selected: !obj[f.key] })]);
        order.forEach(function (g) {
            select.appendChild(el('optgroup', { label: g }, groups[g].map(function (p) {
                return el('option', { value: String(p.id), text: p.name, selected: Number(obj[f.key]) === p.id });
            })));
        });
        return select;
    }
    function productName(id) {
        var i;
        for (i = 0; i < boot.products.length; i++) { if (boot.products[i].id === Number(id)) { return boot.products[i].name; } }
        return '';
    }

    function iconEl(f, obj) {
        var grid = el('div', { 'class': 'hbx-icons', role: 'group', 'aria-label': f.label });
        var choose = function (name) { return function () { touch(''); obj[f.key] = name; changed(true); }; };
        grid.appendChild(el('button', { type: 'button', 'class': 'hbx-icon is-none' + (!obj[f.key] ? ' is-active' : ''), title: 'No icon', text: 'None', onclick: choose('') }));
        Object.keys(boot.icons).forEach(function (name) {
            grid.appendChild(el('button', { type: 'button', 'class': 'hbx-icon' + (obj[f.key] === name ? ' is-active' : ''),
                title: boot.iconNames[name] || name, 'aria-label': boot.iconNames[name] || name, html: boot.icons[name], onclick: choose(name) }));
        });
        return grid;
    }

    function listEl(f, obj, path) {
        var items = Array.isArray(obj[f.key]) ? obj[f.key] : (obj[f.key] = []);
        var openKey = path + '.' + f.key;
        var wrap = el('div', { 'class': 'hbx-field' }, [el('div', { 'class': 'hbx-label' }, [el('span', { text: f.label })])]);
        var rep = el('div', { 'class': 'hbx-rep' });

        var labelField = null;
        f.fields.forEach(function (sub) { if (sub.key === f.itemLabel) { labelField = sub; } });

        items.forEach(function (item, i) {
            var isOpen = state.open[openKey] === i, name = '';
            if (labelField && labelField.type === 'product') { name = productName(item[labelField.key]); }
            else if (labelField) { name = pick(item[labelField.key]); }
            var head = el('div', { 'class': 'hbx-rep-head', onclick: function () { state.open[openKey] = isOpen ? -1 : i; renderInspector(); } }, [
                el('span', { 'class': 'hbx-rep-name', text: name || (f.label + ' ' + (i + 1)) }),
                iconBtn('up', 'Move up', function (e) { e.stopPropagation(); if (i > 0) { touch(''); items.splice(i - 1, 0, items.splice(i, 1)[0]); state.open[openKey] = isOpen ? i - 1 : -1; changed(true); } }),
                iconBtn('down', 'Move down', function (e) { e.stopPropagation(); if (i < items.length - 1) { touch(''); items.splice(i + 1, 0, items.splice(i, 1)[0]); state.open[openKey] = isOpen ? i + 1 : -1; changed(true); } }),
                iconBtn('trash', 'Remove', function (e) { e.stopPropagation(); touch(''); items.splice(i, 1); state.open[openKey] = -1; changed(true); }, 'is-danger')
            ]);
            var box = el('div', { 'class': 'hbx-rep-item' }, [head]);
            if (isOpen) {
                box.appendChild(el('div', { 'class': 'hbx-rep-body' }, f.fields.map(function (sub) { return fieldEl(sub, item, openKey + '.' + i); })));
            }
            rep.appendChild(box);
        });

        rep.appendChild(el('button', { type: 'button', 'class': 'hbx-add', text: '+ ' + f.addLabel, disabled: items.length >= f.max, onclick: function () {
            var item = {};
            f.fields.forEach(function (sub) { item[sub.key] = clone(sub['default']); });
            touch('');
            items.push(item);
            state.open[openKey] = items.length - 1;
            changed(true);
        } }));
        wrap.appendChild(rep);
        if (f.help) { wrap.appendChild(el('p', { 'class': 'hbx-help', text: f.help })); }
        return wrap;
    }

    function renderInspector() {
        var box = byId('hbx-inspector'), section = state.sel ? sectionById(state.sel) : null;
        var scroll = box.scrollTop;
        box.textContent = '';
        fieldSeq = 0;
        if (section) { renderSectionInspector(box, section); } else { renderPageInspector(box); }
        box.scrollTop = scroll;
        renderStatus();
    }

    function renderSectionInspector(box, section) {
        var def = boot.types[section.type], at = indexOf(section.id);
        box.appendChild(el('div', { 'class': 'hbx-insp-head' }, [
            el('div', { 'class': 'hbx-insp-title', text: def ? def.label : section.type }),
            el('div', {}, [
                iconBtn('up', 'Move section up', function () { moveBy(section.id, -1); }, at === 0 ? 'is-off' : ''),
                iconBtn('down', 'Move section down', function () { moveBy(section.id, 1); }),
                iconBtn('copy', 'Duplicate section', function () { duplicateSection(section.id); })
            ])
        ]));
        box.appendChild(el('p', { 'class': 'hbx-insp-sub', text: def ? def.hint : '' }));
        if (!def) { return; }

        def.fields.forEach(function (f) { box.appendChild(fieldEl(f, section.props, section.id)); });

        box.appendChild(el('div', { 'class': 'hbx-divider' }));
        box.appendChild(el('div', { 'class': 'hbx-group-label', text: 'Section' }));
        box.appendChild(fieldEl({ key: 'spacing', type: 'select', label: 'Space above and below', options: boot.spacing }, section.style, section.id + '.style'));
        box.appendChild(fieldEl({ key: 'anchor', type: 'text', label: 'Anchor',
            help: 'A name other links can jump to. With "pricing" here, a button linking to #pricing scrolls to this section.' }, section.style, section.id + '.style'));
        box.appendChild(fieldEl({ key: 'hidden', type: 'toggle', label: 'Hide from the page' }, section, section.id));
        box.appendChild(el('div', { 'class': 'hbx-divider' }));
        box.appendChild(el('button', { type: 'button', 'class': 'hbx-linkbtn', text: 'Remove this section', onclick: function () { removeSection(section.id); } }));
    }

    function renderPageInspector(box) {
        var id;
        box.appendChild(el('div', { 'class': 'hbx-insp-head' }, [el('div', { 'class': 'hbx-insp-title', text: 'Page settings' })]));
        box.appendChild(el('p', { 'class': 'hbx-insp-sub', text: 'Select a section on the left or in the preview to edit it.' }));

        id = 'hbx-page-name';
        box.appendChild(pageField('Name', id, el('input', { type: 'text', 'class': 'mt-input', id: id, maxlength: '120', value: state.name,
            oninput: function (e) { touch('page.name'); state.name = e.target.value; byId('hbx-name').textContent = state.name; changed(false); } }),
            'Only you see this, in the list of pages.', state.errors.name));

        id = 'hbx-page-slug';
        box.appendChild(pageField('Address', id, el('div', { 'class': 'hbx-addr' }, [
            el('span', { text: boot.siteUrl }),
            el('input', { type: 'text', id: id, value: state.slug, placeholder: 'hosting/wordpress', autocomplete: 'off', spellcheck: 'false',
                oninput: function (e) { touch('page.slug'); state.slug = e.target.value; changed(false); } })
        ]), 'Lowercase letters, numbers and hyphens. An address WHMCS already uses keeps showing the WHMCS page.', state.errors.slug));

        box.appendChild(el('div', { 'class': 'hbx-divider' }));
        box.appendChild(el('div', { 'class': 'hbx-group-label', text: 'Search and sharing' }));
        box.appendChild(fieldEl({ key: 'title', type: 'text', label: 'Title', translatable: true,
            help: 'Shown in the browser tab and in search results. The page name is used when this is empty.' }, state.meta, 'page.meta'));
        box.appendChild(fieldEl({ key: 'description', type: 'textarea', label: 'Description', translatable: true,
            help: 'One or two sentences for search results.' }, state.meta, 'page.meta'));

        if (state.status === 'published') {
            box.appendChild(el('div', { 'class': 'hbx-divider' }));
            box.appendChild(el('button', { type: 'button', 'class': 'hbx-linkbtn', text: 'Take this page offline', onclick: unpublish }));
        }
    }
    function pageField(label, id, control, help, error) {
        var field = el('div', { 'class': 'hbx-field' }, [el('label', { 'class': 'hbx-label', 'for': id }, [el('span', { text: label })]), control]);
        if (error) { field.appendChild(el('p', { 'class': 'hbx-error', text: error })); }
        else if (help) { field.appendChild(el('p', { 'class': 'hbx-help', text: help })); }
        return field;
    }

    // ----------------------------------------------------------------- wire

    (function () {
        var select = byId('hbx-lang');
        boot.languages.forEach(function (l) { select.appendChild(el('option', { value: l.code, text: l.label })); });
        select.addEventListener('change', function () {
            state.lang = select.value;
            renderOutline(); renderInspector(); schedulePreview(true);
        });
    })();

    byId('hbx-device').addEventListener('click', function (e) {
        var b = e.target.closest ? e.target.closest('button[data-v]') : null, canvas = byId('hbx-canvas'), i, all;
        if (!b) { return; }
        all = byId('hbx-device').querySelectorAll('button');
        for (i = 0; i < all.length; i++) { all[i].classList.toggle('is-active', all[i] === b); }
        device = b.getAttribute('data-v');
        canvas.classList.toggle('is-mobile', device === 'mobile');
        fitFrame();
    });

    byId('hbx-save').addEventListener('click', function () { save().then(function (ok) { if (ok) { notice('success', 'Draft saved. Visitors still see the published version until you publish.'); schedulePreview(true); } }); });
    byId('hbx-publish').addEventListener('click', publish);
    byId('hbx-undo').addEventListener('click', undo);
    byId('hbx-redo').addEventListener('click', redo);
    byId('hbx-pagebtn').addEventListener('click', function () { select(null, false); });

    document.addEventListener('keydown', function (e) {
        var t = e.target, typing = t && (t.tagName === 'INPUT' || t.tagName === 'TEXTAREA' || t.tagName === 'SELECT' || t.isContentEditable);
        if (!(e.ctrlKey || e.metaKey)) { return; }
        if (e.key === 's' || e.key === 'S') { e.preventDefault(); byId('hbx-save').click(); return; }
        // Inside a text field the browser's own undo is the one people expect.
        if (typing) { return; }
        if ((e.key === 'z' || e.key === 'Z') && !e.shiftKey) { e.preventDefault(); undo(); }
        else if (e.key === 'y' || e.key === 'Y' || ((e.key === 'z' || e.key === 'Z') && e.shiftKey)) { e.preventDefault(); redo(); }
    });

    window.addEventListener('beforeunload', function (e) {
        if (state.dirty) { e.preventDefault(); e.returnValue = ''; }
    });

    // For the test suite: the live state, and whether the preview is settled.
    window.hbBuilder = { state: state, idle: function () { return !pvQueued && !pvLoading; } };

    window.addEventListener('resize', fitFrame);
    fitFrame();

    renderPalette();
    renderOutline();
    renderInspector();
    schedulePreview(true);
})();
