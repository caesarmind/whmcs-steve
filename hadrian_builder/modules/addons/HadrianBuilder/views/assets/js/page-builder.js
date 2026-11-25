/* Page builder editor. Inlined into views/editor.tpl by AdminController.
   Plain browser JavaScript, no build step, ASCII only.

   The page is one document (state.doc): an ordered list of sections. Every
   control on this screen is generated from the section schemas the server
   sent in the boot data, so adding a section type needs no change here.

   Layout: a rail (Add, Layers, Page) and one panel on the left, the page on
   the right. Selecting a section, on the page or in Layers, turns the panel
   into that section's settings.

   The preview is the real page. Each change posts the document, the server
   keeps it for this admin's session, and the frame loads the address where
   the theme draws it. While that is on its way, text being typed is swapped
   into the frame in place, so the page follows the keyboard. */
(function () {
    'use strict';

    var boot = JSON.parse(document.getElementById('hbx-boot').textContent);
    var byId = function (id) { return document.getElementById(id); };
    var LOOKS = boot.looks || null;

    var state = {
        doc: boot.doc, name: boot.name, slug: boot.slug, meta: boot.meta,
        status: boot.status, changed: boot.changed, pageUrl: boot.pageUrl,
        sel: null,          // id of the selected section
        lang: '_',          // '_' edits the default text
        dirty: false,
        open: {},           // which item of a list field is expanded: "sectionId.field" -> index
        errors: {},         // field -> message, from the last save
        panel: boot.doc.sections.length ? 'layers' : 'add',
        cat: null,          // the open category in Add
        query: '',          // the search in Add
        insertAt: null,     // where Add puts a section; null: after the selected one, or at the end
        tab: 'content',     // content | section
        hover: null,        // section under the pointer, on the page or in Layers
        look: LOOKS ? { style: LOOKS.site.style, nav: LOOKS.site.nav, footer: LOOKS.site.footer, theme: LOOKS.site.theme } : null
    };
    var past = [], future = [], lastTouch = { key: '', at: 0 };

    // ------------------------------------------------------------- helpers
    // Field controls, icons and the category chips are shared with the section
    // list in Pages (fields.js). The hooks tell the kit about this screen.

    var kit = window.HadrianBuilderKit(boot, {
        lang: function () { return state.lang; },
        open: state.open,
        touch: function (key) { touch(key); },
        changed: function (structural) { changed(structural); },
        rerender: function () { renderPanel(); },
        // A keystroke in a field that shows as text: find it on the page
        // first, then put the new text there before the server redraws.
        typed: {
            before: function (p) { var section = sectionById(state.sel); if (section) { target(section, p); } },
            after: function (p, row, text) {
                var section = sectionById(state.sel), ok;
                if (!section) { return; }
                ok = applyText(section, p, text);
                row.classList.toggle('has-target', ok);
                if (ok) { highlightField(section, p, false); placeUi(); }
            }
        }
    });
    var el = kit.el, clone = kit.clone, esc = kit.esc, svg = kit.svg, iconBtn = kit.iconBtn,
        catOf = kit.catOf, catTile = kit.catTile, typeDef = kit.typeDef, GROUPS = kit.GROUPS,
        pick = kit.pick, summary = kit.summary, fieldEl = kit.fieldEl, setValue = kit.setValue;

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
    /* After a change. `structural` redraws the panel; typing does not, so the
       field being typed in keeps its focus. */
    function changed(structural) {
        state.dirty = true;
        renderStatus();
        if (structural) { renderPanel(); } else { refreshLabels(); }
        schedulePreview();
    }
    function restore(json) {
        var s = JSON.parse(json);
        state.doc = s.doc; state.name = s.name; state.slug = s.slug; state.meta = s.meta;
        if (state.sel && !sectionById(state.sel)) { state.sel = null; if (state.panel === 'edit') { state.panel = 'layers'; } }
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
    var toastTimer = null;
    function toast(message) {
        var t = byId('hbx-toast');
        t.textContent = message;
        t.classList.add('is-on');
        window.clearTimeout(toastTimer);
        toastTimer = window.setTimeout(function () { t.classList.remove('is-on'); }, 2600);
    }
    /* A save refused because of a page field (name, address): show it there. */
    function showFieldError(res) {
        if (!res.field) { return; }
        state.errors[res.field] = res.error;
        state.sel = null;
        state.panel = 'page';
        renderAll();
    }

    function save() {
        notice('', '');
        setBusy(true);
        return api('api-save', { doc: state.doc, name: state.name, slug: state.slug, meta: state.meta }).then(function (res) {
            setBusy(false);
            state.errors = {};
            if (!res.ok) {
                showFieldError(res);
                notice('danger', res.error);
                return false;
            }
            state.doc = res.doc; state.meta = res.meta; state.name = res.name; state.slug = res.slug;
            state.status = res.status; state.changed = res.changed; state.pageUrl = res.pageUrl;
            state.dirty = false;
            if (state.sel && !sectionById(state.sel)) { state.sel = null; if (state.panel === 'edit') { state.panel = 'layers'; } }
            byId('hbx-name').textContent = state.name;
            renderAll();
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
                    showFieldError(res);
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
            renderAll();
            notice('info', 'The page is offline. Your draft is kept.');
        });
    }

    // -------------------------------------------------------------- preview

    var frame = byId('hbx-frame'), fdoc = null, fwin = null, pvTimer = null, pvSeq = 0, scrollToSel = false;
    // A preview is settled when no update is waiting and the newest one has loaded.
    var pvQueued = false, pvLoading = false, pvAssigned = 0;
    var lookQuery = '';         // the look parameter of the newest preview, for the Add list's samples too
    var inlineEditing = false;  // typing on the page itself: do not reload under the cursor

    function setBusy(on) { byId('hbx-busy').hidden = !on; }

    /* Lay the frame out at the device's real width and scale it to fit the
       stage, so "Desktop" shows the desktop layout beside the panel. */
    var DEVICE = { desktop: 1280, tablet: 820, mobile: 390 }, device = 'desktop';
    function fitFrame() {
        var stage = byId('hbx-stage'), canvas = byId('hbx-canvas');
        var availW = Math.max(240, stage.clientWidth - 36), availH = Math.max(320, stage.clientHeight - 18);
        var width = DEVICE[device], scale = Math.min(1, availW / width);
        canvas.style.width = Math.round(width * scale) + 'px';
        canvas.style.height = availH + 'px';
        frame.style.width = width + 'px';
        frame.style.height = Math.round(availH / scale) + 'px';
        frame.style.transform = scale < 1 ? 'scale(' + scale + ')' : 'none';
        byId('hbx-scale').textContent = width + ' px wide' + (scale < 1 ? ', shown at ' + Math.round(scale * 100) + '%' : '');
        window.setTimeout(function () { if (state.sel) { reveal(state.sel); } placeUi(); }, 80);
    }

    function schedulePreview(now) {
        window.clearTimeout(pvTimer);
        pvQueued = true;
        pvTimer = window.setTimeout(runPreview, now ? 0 : 450);
    }
    function runPreview() {
        if (inlineEditing) { schedulePreview(); return; }
        var seq = ++pvSeq, payload = { doc: state.doc, lang: state.lang };
        pvQueued = false;
        pvLoading = true;
        setBusy(true);
        if (state.look) { payload.look = state.look; }
        api('api-preview', payload).then(function (res) {
            if (seq !== pvSeq) { return; }
            if (!res.ok) { pvLoading = false; setBusy(false); notice('danger', res.error); return; }
            var y = 0, m = /[?&](hadrian_look=[^&]+)/.exec(res.url);
            lookQuery = m ? '&' + m[1] : '';
            try { y = frame.contentWindow.pageYOffset || 0; } catch (e) { y = 0; }
            frame.setAttribute('data-restore', String(y));
            pvAssigned = seq;
            frame.src = res.url;
        });
    }

    /* Drawn inside the page: outlines, the name tag and toolbar of the
       selected section, and the line a dragged section drops on. Its own
       class names (hbp-) so the theme cannot style it. */
    var FRAME_CSS = [
        '[data-hb-id]{cursor:pointer}',
        '.hbp-field-hl{outline:2px dashed #0071e3!important;outline-offset:4px;border-radius:8px}',
        '.hbp-editing{outline:2px solid #0071e3!important;outline-offset:4px;border-radius:8px;cursor:text!important}',
        '#hbp-ui{all:initial;position:fixed;inset:0;pointer-events:none;z-index:2147483000;font:500 12px/1 -apple-system,BlinkMacSystemFont,"SF Pro Text","Segoe UI",system-ui,sans-serif}',
        '#hbp-ui *{box-sizing:border-box}',
        '.hbp-box{position:fixed;display:none}',
        '.hbp-box.on{display:block}',
        '#hbp-hover{border:2px dashed rgba(0,113,227,.6)}',
        '#hbp-sel{border:2px solid #0071e3;box-shadow:0 0 0 4px rgba(0,113,227,.12)}',
        '.hbp-tag{position:absolute;left:-2px;display:inline-flex;align-items:center;gap:6px;height:24px;padding:0 10px 0 3px;border-radius:8px;color:#fff;white-space:nowrap;font-weight:600}',
        '.hbp-tag i{display:grid;place-items:center;width:18px;height:18px;border-radius:50%;background:#fff}',
        '.hbp-tag svg{width:12px;height:12px}',
        '.hbp-tag small{font-weight:400;opacity:.8}',
        '#hbp-hover .hbp-tag{background:rgba(29,29,31,.82)}',
        '#hbp-sel .hbp-tag{background:#0071e3}',
        '.hbp-out{top:-28px}.hbp-in{top:6px;left:6px}',
        '.hbp-bar{position:absolute;right:-2px;display:flex;gap:1px;padding:2px;border-radius:12px;background:#1d1d1f;pointer-events:auto;box-shadow:0 4px 32px rgba(0,0,0,.12),0 0 1px rgba(0,0,0,.08)}',
        '.hbp-bar.hbp-in{right:6px;left:auto}',
        '.hbp-bar button{all:unset;width:28px;height:26px;display:grid;place-items:center;border-radius:8px;color:#fff;cursor:pointer}',
        '.hbp-bar button svg{width:15px;height:15px}',
        '.hbp-bar button:hover{background:rgba(255,255,255,.16)}',
        '.hbp-bar button[disabled]{opacity:.3;cursor:default;background:none}',
        '.hbp-bar .sep{width:1px;margin:5px 2px;background:rgba(255,255,255,.2)}',
        '.hbp-plus{all:unset;position:absolute;left:50%;width:28px;height:28px;margin-left:-14px;display:grid;place-items:center;border-radius:50%;background:#0071e3;color:#fff;pointer-events:auto;cursor:pointer;box-shadow:0 0 0 4px #fff,0 2px 12px rgba(0,0,0,.12);transition:transform .15s ease}',
        '.hbp-plus svg{width:16px;height:16px}',
        '.hbp-plus:hover{transform:scale(1.12)}',
        '.hbp-plus.top{top:-14px}.hbp-plus.bot{bottom:-14px}',
        '#hbp-drop{position:fixed;left:0;right:0;height:0;display:none}',
        '#hbp-drop.on{display:block}',
        '#hbp-drop::before{content:"";position:absolute;left:12px;right:12px;top:-2px;height:4px;border-radius:999px;background:#0071e3;box-shadow:0 0 0 3px rgba(0,113,227,.2)}',
        '#hbp-drop span{position:absolute;left:50%;top:-14px;transform:translateX(-50%);height:28px;padding:0 12px;display:flex;align-items:center;border-radius:999px;background:#0071e3;color:#fff;font-weight:600;white-space:nowrap}'
    ].join('\n');

    function frameDoc() {
        try { return frame.contentDocument; } catch (e) { return null; }
    }
    function sectionEl(id) { return fdoc ? fdoc.querySelector('[data-hb-id="' + id + '"]') : null; }
    function rectOf(id) { var n = sectionEl(id); return n ? n.getBoundingClientRect() : null; }

    frame.addEventListener('load', function () {
        var doc = frameDoc(), style, ui, y;
        if (!frame.getAttribute('src')) { return; }
        if (pvAssigned === pvSeq) { pvLoading = false; }
        setBusy(false);
        if (!doc || !doc.body) { return; }
        fdoc = doc; fwin = frame.contentWindow;
        binds = {}; hlEl = null;
        style = doc.createElement('style');
        style.textContent = FRAME_CSS;
        doc.head.appendChild(style);
        ui = doc.createElement('div');
        ui.id = 'hbp-ui';
        ui.innerHTML = '<div class="hbp-box" id="hbp-hover"><span class="hbp-tag hbp-out"></span></div>'
            + '<div class="hbp-box" id="hbp-sel"><span class="hbp-tag hbp-out"></span><div class="hbp-bar hbp-out"></div>'
            + '<button type="button" class="hbp-plus top" data-act="add-before" title="Add a section above" aria-label="Add a section above">' + svg('plus', 2) + '</button>'
            + '<button type="button" class="hbp-plus bot" data-act="add-after" title="Add a section below" aria-label="Add a section below">' + svg('plus', 2) + '</button></div>'
            + '<div id="hbp-drop"><span></span></div>';
        doc.body.appendChild(ui);
        wireFrame(doc);
        y = parseInt(frame.getAttribute('data-restore') || '0', 10);
        if (!scrollToSel && y > 0) { fwin.scrollTo(0, y); }
        if (scrollToSel && state.sel) { reveal(state.sel, true); }
        scrollToSel = false;
        placeUi();
        // The field being typed in stays pointed at on the redrawn page.
        var focused = document.activeElement && document.activeElement.closest ? document.activeElement.closest('.hbx-field[data-path]') : null;
        if (focused && state.sel) { highlightField(sectionById(state.sel), parsePath(focused.getAttribute('data-path')), false); }
    });

    function wireFrame(doc) {
        doc.addEventListener('mousemove', function (e) {
            if (dragType) { return; }
            var sec = e.target.closest ? e.target.closest('[data-hb-id]') : null;
            setHover(sec ? sec.getAttribute('data-hb-id') : null);
        });
        doc.addEventListener('mouseleave', function () { setHover(null); });
        // Nothing in the preview navigates or submits: a click only selects.
        doc.addEventListener('click', function (e) {
            var t = e.target, act = t.closest ? t.closest('[data-act]') : null, sec, id, hit;
            if (act && act.closest('#hbp-ui')) { e.preventDefault(); frameAction(act.getAttribute('data-act')); return; }
            if (t.closest && t.closest('.hbp-editing')) { return; }
            if (t.closest && t.closest('a, button[type="submit"], input[type="submit"]')) { e.preventDefault(); }
            sec = t.closest ? t.closest('[data-hb-id]') : null;
            if (!sec) { return; }
            id = sec.getAttribute('data-hb-id');
            if (state.sel !== id) { select(id, false); return; }
            // Already selected: point at the setting for what was clicked.
            hit = fieldForElement(sectionById(id), t);
            if (hit) { focusField(hit, false); }
        }, true);
        doc.addEventListener('submit', function (e) { e.preventDefault(); }, true);
        doc.addEventListener('dblclick', function (e) {
            var sec = e.target.closest ? e.target.closest('[data-hb-id]') : null, id, hit;
            if (!sec) { return; }
            id = sec.getAttribute('data-hb-id');
            if (state.sel !== id) { select(id, false); }
            hit = fieldForElement(sectionById(id), e.target);
            if (hit) { e.preventDefault(); inlineEdit(hit); }
        });
        doc.addEventListener('keydown', keys);
        fwin.addEventListener('scroll', placeUi, { passive: true });
        fwin.addEventListener('resize', placeUi);

        // A section dragged from Add onto the page.
        doc.addEventListener('dragover', function (e) {
            if (!dragType) { return; }
            e.preventDefault();
            e.dataTransfer.dropEffect = 'copy';
            showDrop(dropIndex(e.clientY));
        });
        doc.addEventListener('dragleave', function (e) { if (!e.relatedTarget) { hideDrop(); } });
        doc.addEventListener('drop', function (e) {
            if (!dragType) { return; }
            e.preventDefault();
            var type = dragType;
            dragType = null;
            hideDrop();
            addSection(type, dropIndex(e.clientY));
        });
    }

    function setHover(id) {
        if (state.hover === id) { return; }
        state.hover = id;
        var rows = document.querySelectorAll('.hbx-out'), i;
        for (i = 0; i < rows.length; i++) { rows[i].classList.toggle('is-hover', rows[i].getAttribute('data-id') === id); }
        placeUi();
    }
    function tagHtml(section, extra) {
        var def = typeDef(section.type), c = catOf(def.group);
        return '<i style="color:' + c[1] + '">' + svg(c[0], 2) + '</i>' + esc(def.label) + (extra ? ' <small>' + esc(extra) + '</small>' : '');
    }
    /* Put the outlines, tag and toolbar over the sections they belong to. */
    function placeUi() {
        if (!fdoc || !fdoc.getElementById('hbp-ui')) { return; }
        var hov = fdoc.getElementById('hbp-hover'), sel = fdoc.getElementById('hbp-sel'), vh = fwin.innerHeight, vw = fwin.innerWidth;
        function place(box, id) {
            var r = id ? rectOf(id) : null, room, parts, i;
            if (!r || r.bottom < 0 || r.top > vh || r.height === 0) { box.classList.remove('on'); return; }
            box.classList.add('on');
            box.style.left = Math.max(0, r.left) + 'px';
            box.style.top = r.top + 'px';
            box.style.width = Math.min(r.width, vw - Math.max(0, r.left)) + 'px';
            box.style.height = r.height + 'px';
            room = r.top > 34;
            parts = box.querySelectorAll('.hbp-tag, .hbp-bar');
            for (i = 0; i < parts.length; i++) { parts[i].classList.toggle('hbp-out', room); parts[i].classList.toggle('hbp-in', !room); }
        }
        var hs = state.hover && state.hover !== state.sel ? sectionById(state.hover) : null;
        if (hs) { hov.querySelector('.hbp-tag').innerHTML = tagHtml(hs, hs.hidden ? 'hidden' : ''); }
        place(hov, hs ? hs.id : null);
        var ss = state.sel ? sectionById(state.sel) : null, i, n;
        if (ss) {
            i = indexOf(ss.id); n = state.doc.sections.length;
            sel.querySelector('.hbp-tag').innerHTML = tagHtml(ss, (i + 1) + ' of ' + n + (ss.hidden ? ', hidden' : ''));
            sel.querySelector('.hbp-bar').innerHTML =
                '<button type="button" data-act="up" title="Move up" aria-label="Move up"' + (i === 0 ? ' disabled' : '') + '>' + svg('up', 2) + '</button>'
                + '<button type="button" data-act="down" title="Move down" aria-label="Move down"' + (i === n - 1 ? ' disabled' : '') + '>' + svg('down', 2) + '</button>'
                + '<span class="sep"></span>'
                + '<button type="button" data-act="dup" title="Duplicate" aria-label="Duplicate">' + svg('copy', 2) + '</button>'
                + '<button type="button" data-act="hide" title="' + (ss.hidden ? 'Show on the page' : 'Hide from the page') + '" aria-label="' + (ss.hidden ? 'Show on the page' : 'Hide from the page') + '">' + svg(ss.hidden ? 'eyeOff' : 'eye', 2) + '</button>'
                + '<button type="button" data-act="del" title="Remove" aria-label="Remove">' + svg('trash', 2) + '</button>';
        }
        place(sel, ss ? ss.id : null);
    }
    function frameAction(act) {
        var id = state.sel, i = indexOf(id);
        if (!id) { return; }
        if (act === 'up') { moveBy(id, -1); }
        else if (act === 'down') { moveBy(id, 1); }
        else if (act === 'dup') { duplicateSection(id); }
        else if (act === 'hide') { toggleHidden(id); }
        else if (act === 'del') { removeSection(id); }
        else if (act === 'add-before') { openAdd(i); }
        else if (act === 'add-after') { openAdd(i + 1); }
    }
    /* Scroll the page so a section is in view, when it is not already. */
    function reveal(id, force) {
        var n = sectionEl(id), r;
        if (!n || !fwin) { return; }
        r = n.getBoundingClientRect();
        if (force || r.top < 60 || r.top > fwin.innerHeight * 0.6) {
            fwin.scrollBy(0, r.top - 80);
            placeUi();
        }
    }

    // ------------------------------------------- drag and drop onto the page

    var dragType = null;
    function dropIndex(y) {
        var i, r;
        for (i = 0; i < state.doc.sections.length; i++) {
            r = rectOf(state.doc.sections[i].id);
            if (r && y < r.top + r.height / 2) { return i; }
        }
        return state.doc.sections.length;
    }
    function showDrop(at) {
        var d = fdoc && fdoc.getElementById('hbp-drop'), y, last, r;
        if (!d) { return; }
        if (at < state.doc.sections.length) { r = rectOf(state.doc.sections[at].id); y = r ? r.top : 80; }
        else { last = state.doc.sections[state.doc.sections.length - 1]; r = last ? rectOf(last.id) : null; y = r ? r.bottom : 120; }
        d.style.top = Math.max(16, Math.min(fwin.innerHeight - 16, y)) + 'px';
        d.querySelector('span').textContent = 'Drop to add ' + typeDef(dragType).label + ' here';
        d.classList.add('on');
    }
    function hideDrop() { var d = fdoc && fdoc.getElementById('hbp-drop'); if (d) { d.classList.remove('on'); } }

    // ------------------------------------- settings <-> what they change on the page

    var binds = {};     // sectionId -> "path" -> {node, attr, part}; found by text, kept until the next redraw
    var hlEl = null;

    function pathKey(p) { return p.join('.'); }
    function parsePath(s) { return String(s).split('.').map(function (x) { return /^\d+$/.test(x) ? parseInt(x, 10) : x; }); }
    function holderOf(section, p) { return p.length === 3 ? (section.props[p[0]] || [])[p[1]] : section.props; }
    function fieldDef(section, p) {
        var fields = typeDef(section.type).fields, f = null, i;
        for (i = 0; i < fields.length; i++) { if (fields[i].key === p[0]) { f = fields[i]; } }
        if (f && p.length === 3) {
            var sub = null;
            for (i = 0; i < f.fields.length; i++) { if (f.fields[i].key === p[2]) { sub = f.fields[i]; } }
            f = sub;
        }
        return f;
    }
    function shownAt(section, p) {
        var h = holderOf(section, p);
        return h ? pick(h[p[p.length - 1]]) : '';
    }
    /* Every field whose value is text on the page. */
    function eachTextField(section, fn) {
        typeDef(section.type).fields.forEach(function (f) {
            if (f.type === 'list') {
                (section.props[f.key] || []).forEach(function (item, i) {
                    f.fields.forEach(function (sf) { if (sf.type === 'text' || sf.type === 'textarea' || sf.type === 'link') { fn([f.key, i, sf.key], sf); } });
                });
            } else if (f.type === 'text' || f.type === 'textarea' || f.type === 'link') { fn([f.key], f); }
        });
    }
    /* Where on the page a field shows: a text node, or a link's address. */
    function target(section, p) {
        var key = pathKey(p), b = (binds[section.id] = binds[section.id] || {}), root, f, cur, claimed = [], found = null, k, w, node, t, first, partial = null, links, i, h;
        if (b[key] && b[key].node.isConnected) { return b[key]; }
        root = sectionEl(section.id); f = fieldDef(section, p); cur = shownAt(section, p);
        if (!root || !f || cur === '') { return null; }
        cur = String(cur).replace(/^\s+|\s+$/g, '');
        for (k in b) { if (Object.prototype.hasOwnProperty.call(b, k)) { claimed.push(b[k].node); } }
        if (f.type === 'link') {
            links = root.querySelectorAll('a[href], form[action]');
            for (i = 0; i < links.length && !found; i++) {
                h = links[i].getAttribute('href') || links[i].getAttribute('action') || '';
                if (claimed.indexOf(links[i]) < 0 && (h === cur || h.slice(-cur.length) === cur)) { found = { node: links[i], attr: links[i].hasAttribute('href') ? 'href' : 'action' }; }
            }
        } else {
            first = cur.split(/\n/)[0].replace(/\s+/g, ' ');
            w = fdoc.createTreeWalker(root, 4 /* text nodes */);
            while ((node = w.nextNode())) {
                if (claimed.indexOf(node) >= 0) { continue; }
                t = node.nodeValue.replace(/\s+/g, ' ').replace(/^\s+|\s+$/g, '');
                if (t === first) { found = { node: node }; break; }
                if (!partial && first.length > 3 && t.indexOf(first) >= 0) { partial = { node: node, part: first }; }
            }
            found = found || partial;
            if (!found) {
                links = root.querySelectorAll('[placeholder]');
                for (i = 0; i < links.length && !found; i++) { if (links[i].getAttribute('placeholder') === cur) { found = { node: links[i], attr: 'placeholder' }; } }
            }
        }
        if (found) { b[key] = found; }
        return found;
    }
    function targetEl(t) { return t ? (t.node.nodeType === 3 ? t.node.parentElement : t.node) : null; }
    /* Put the new text on the page now; the redraw that follows confirms it. */
    function applyText(section, p, after) {
        var t = target(section, p), line;
        if (!t) { return false; }
        if (t.attr) { t.node.setAttribute(t.attr, after); return true; }
        line = String(after).split(/\n/)[0];
        if (t.part) { t.node.nodeValue = t.node.nodeValue.replace(t.part, line); t.part = line; }
        else { t.node.nodeValue = /^\s*/.exec(t.node.nodeValue)[0] + line + /\s*$/.exec(t.node.nodeValue)[0]; }
        return true;
    }
    function fieldForElement(section, node) {
        var hit = null;
        if (!section) { return null; }
        eachTextField(section, function (p) {
            if (hit) { return; }
            var t = target(section, p), te = targetEl(t);
            if (te && (te === node || (t.node.nodeType === 3 && node.contains(t.node) && node.textContent.length < t.node.nodeValue.length + 40))) { hit = p; }
        });
        return hit;
    }
    function clearFieldHl() { if (hlEl) { hlEl.classList.remove('hbp-field-hl'); hlEl = null; } }
    function highlightField(section, p, scroll) {
        clearFieldHl();
        var node = section ? targetEl(target(section, p)) : null, r;
        if (!node) { return; }
        node.classList.add('hbp-field-hl');
        hlEl = node;
        r = node.getBoundingClientRect();
        if (scroll !== false && (r.top < 70 || r.bottom > fwin.innerHeight - 20)) { fwin.scrollBy(0, r.top - fwin.innerHeight / 3); placeUi(); }
    }
    /* Open a field in the panel, flash it, and point at it on the page. */
    function focusField(p, takeFocus) {
        var key, row, d, input, section = sectionById(state.sel);
        if (state.tab !== 'content' || state.panel !== 'edit') { state.tab = 'content'; state.panel = 'edit'; renderPanel(); }
        if (p.length === 3) {
            key = state.sel + '.' + p[0];
            if (state.open[key] !== p[1]) { state.open[key] = p[1]; renderPanel(); }
        }
        row = byId('hbx-panel').querySelector('.hbx-field[data-path="' + pathKey(p) + '"]');
        if (!row) { return; }
        d = row.closest('details');
        while (d) { d.open = true; d = d.parentElement ? d.parentElement.closest('details') : null; }
        row.scrollIntoView({ block: 'center' });
        row.classList.add('is-flash');
        window.setTimeout(function () { row.classList.remove('is-flash'); }, 1200);
        input = row.querySelector('input, textarea, select, [contenteditable]');
        if (input && takeFocus !== false) { input.focus(); }
        highlightField(section, p);
    }
    /* Type on the page itself. The panel's field follows; the redraw waits
       until typing stops (Enter, Escape or clicking away). */
    function inlineEdit(p) {
        var section = sectionById(state.sel), f = fieldDef(section, p), t = target(section, p), node, before, range, s;
        if (!t || t.attr || !f || f.type === 'link') { focusField(p); return; }
        node = t.node.parentElement;
        before = shownAt(section, p);
        inlineEditing = true;
        node.classList.add('hbp-editing');
        node.setAttribute('contenteditable', 'plaintext-only');
        if (node.contentEditable !== 'plaintext-only') { node.setAttribute('contenteditable', 'true'); }
        node.focus();
        range = fdoc.createRange(); range.selectNodeContents(node);
        s = fwin.getSelection(); s.removeAllRanges(); s.addRange(range);
        focusField(p, false);
        function sync() {
            var v = node.textContent.replace(/^\s+|\s+$/g, ''), input;
            touch(pathKey(p));
            setValue(f, holderOf(section, p), v);
            input = byId('hbx-panel').querySelector('.hbx-field[data-path="' + pathKey(p) + '"] input, .hbx-field[data-path="' + pathKey(p) + '"] textarea');
            if (input) { input.value = v; }
            state.dirty = true;
            renderStatus();
        }
        function done() {
            node.removeAttribute('contenteditable');
            node.classList.remove('hbp-editing');
            node.removeEventListener('input', sync);
            node.removeEventListener('blur', done);
            node.removeEventListener('keydown', key);
            inlineEditing = false;
            refreshLabels();
            schedulePreview(true);
        }
        function key(e) {
            if (e.key === 'Enter' && !e.shiftKey) { e.preventDefault(); node.blur(); }
            else if (e.key === 'Escape') { node.textContent = before; sync(); node.blur(); }
        }
        node.addEventListener('input', sync);
        node.addEventListener('blur', done);
        node.addEventListener('keydown', key);
    }

    // --------------------------------------------------------- the document

    function select(id, scroll) {
        if (id !== null && !sectionById(id)) { id = null; }
        clearFieldHl();
        state.sel = id;
        if (id) { state.panel = 'edit'; state.tab = 'content'; }
        else if (state.panel === 'edit') { state.panel = 'layers'; }
        renderAll();
        if (id && scroll) { reveal(id); }
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
        var at = indexOf(id), def;
        if (at < 0) { return; }
        def = typeDef(state.doc.sections[at].type);
        touch('');
        state.doc.sections.splice(at, 1);
        if (state.sel === id) { state.sel = null; if (state.panel === 'edit') { state.panel = 'layers'; } }
        changed(true);
        toast(def.label + ' removed. Press Ctrl+Z to bring it back.');
    }
    function duplicateSection(id) {
        var at = indexOf(id), copy;
        if (at < 0) { return; }
        touch('');
        copy = clone(state.doc.sections[at]);
        copy.id = kit.newId();
        copy.style.anchor = '';        // two elements cannot share an id
        state.doc.sections.splice(at + 1, 0, copy);
        state.sel = copy.id;
        state.panel = 'edit';
        scrollToSel = true;
        changed(true);
    }
    function toggleHidden(id) {
        var section = sectionById(id);
        if (!section) { return; }
        touch('');
        section.hidden = !section.hidden;
        changed(true);
        toast(section.hidden ? 'Hidden. Visitors will not see it; it stays here, faded.' : 'Shown on the page again.');
    }
    /* A new section of `type` at position `at` (default: after the selected one, or at the end). */
    function addSection(type, at) {
        var section = kit.makeSection(type);
        if (!section) { return; }
        touch('');
        if (at === null || at === undefined) { at = state.insertAt !== null ? state.insertAt : (state.sel ? indexOf(state.sel) + 1 : state.doc.sections.length); }
        at = Math.max(0, Math.min(at, state.doc.sections.length));
        state.doc.sections.splice(at, 0, section);
        state.sel = section.id;
        state.panel = 'edit';
        state.tab = 'content';
        state.insertAt = null;
        hidePeek();
        scrollToSel = true;
        changed(true);
    }

    // ------------------------------------------------------------- the panel

    function renderAll() { renderRail(); renderPanel(); renderStatus(); placeUi(); }

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

    function renderRail() {
        var btns = document.querySelectorAll('.hbx-rail-btn'), i, p;
        for (i = 0; i < btns.length; i++) {
            p = btns[i].getAttribute('data-panel');
            btns[i].classList.toggle('is-active', p === state.panel || (p === 'layers' && state.panel === 'edit'));
        }
        byId('hbx-count').textContent = String(state.doc.sections.length);
    }

    function renderPanel() {
        var box = byId('hbx-panel'), view = state.panel + ':' + (state.sel || '') + ':' + state.cat + ':' + state.tab + ':' + state.lang;
        var same = box.getAttribute('data-view') === view, keep = box.scrollTop;
        box.textContent = '';
        kit.resetIds();
        if (state.panel === 'add') { addPanel(box); }
        else if (state.panel === 'page') { pagePanel(box); }
        else if (state.panel === 'edit' && sectionById(state.sel)) { editPanel(box, sectionById(state.sel)); }
        else { state.panel = 'layers'; layersPanel(box); }
        box.setAttribute('data-view', view);
        box.scrollTop = same ? keep : 0;
        renderRail();
        stuck();
    }
    function stuck() { var ph = byId('hbx-panel').querySelector('.hbx-ph'); if (ph) { ph.classList.toggle('is-stuck', byId('hbx-panel').scrollTop > 4); } }
    /* After typing: the names that follow a field, without redrawing the panel. */
    function refreshLabels() {
        var section = state.sel ? sectionById(state.sel) : null, sum = byId('hbx-id-sum');
        if (section && sum) { sum.textContent = summary(section); }
    }
    function head(title, sub, extra) {
        return el('div', { 'class': 'hbx-ph' }, [el('h2', { text: title }), sub ? el('p', { text: sub }) : null].concat(extra || []));
    }

    // Add: categories, a category's sections, or what the search finds.
    function addPanel(box) {
        var q = state.query.replace(/^\s+|\s+$/g, '').toLowerCase(), body = el('div', { 'class': 'hbx-pb' });
        var search = el('input', { type: 'search', 'class': 'mt-input', id: 'hbx-palfilter', placeholder: 'Search ' + Object.keys(boot.types).length + ' sections',
            'aria-label': 'Search sections', autocomplete: 'off', value: state.query,
            oninput: function (e) { state.query = e.target.value; renderPanel(); var s = byId('hbx-palfilter'); s.focus(); s.setSelectionRange(s.value.length, s.value.length); } });
        var extra = [el('label', { 'class': 'hbx-search' }, [el('span', { html: svg('search') }), search])];
        if (state.insertAt !== null) {
            var at = state.insertAt, where;
            if (at <= 0) { where = 'Goes at the <b>top of the page</b>'; }
            else if (at >= state.doc.sections.length) { where = 'Goes at the <b>end of the page</b>'; }
            else { where = 'Goes after <b>' + esc(typeDef(state.doc.sections[at - 1].type).label) + '</b>'; }
            extra.push(el('div', { 'class': 'hbx-where' }, [el('span', { html: svg('target') }), el('span', { html: where }),
                el('button', { type: 'button', text: 'At the end', onclick: function () { state.insertAt = state.doc.sections.length; renderPanel(); } })]));
        }
        box.appendChild(head('Add a section', 'Click to add, or drag onto the page.', extra));

        if (q) {
            var hits = 0;
            GROUPS.forEach(function (g) {
                var types = g.types.filter(function (t) { var d = boot.types[t]; return (d.label + ' ' + d.hint + ' ' + g.name).toLowerCase().indexOf(q) !== -1; });
                if (!types.length) { return; }
                hits += types.length;
                body.appendChild(el('div', { 'class': 'hbx-lib-group', html: catTile(g.name, 'sm') + esc(g.name) }));
                body.appendChild(el('div', { 'class': 'hbx-lib' }, types.map(palCard)));
            });
            if (!hits) { body.appendChild(el('div', { 'class': 'hbx-empty', text: 'No section matches "' + state.query + '".' })); }
        } else if (!state.cat) {
            body.appendChild(el('div', { 'class': 'hbx-cats' }, GROUPS.map(function (g) {
                return el('button', { type: 'button', 'class': 'hbx-cat-card', 'data-cat': g.name, onclick: function () { state.cat = g.name; renderPanel(); } }, [
                    el('span', { html: catTile(g.name) }),
                    el('span', {}, [el('b', { text: g.name }), el('small', { text: g.types.length + (g.types.length === 1 ? ' section' : ' sections') })])
                ]);
            })));
            body.appendChild(el('div', { 'class': 'hbx-tip', html: svg('info') + '<span>Hover a section to see it drawn by your theme. The colour of a category marks its sections in Layers and on the page too.</span>' }));
        } else {
            var group = null;
            GROUPS.forEach(function (g) { if (g.name === state.cat) { group = g; } });
            if (!group) { state.cat = null; return addPanel(box); }
            body.appendChild(el('button', { type: 'button', 'class': 'hbx-crumb', html: svg('left', 2) + 'All categories', onclick: function () { state.cat = null; renderPanel(); } }));
            body.appendChild(el('div', { 'class': 'hbx-cat-head' }, [el('span', { html: catTile(group.name, 'lg') }),
                el('div', {}, [el('b', { text: group.name }), el('small', { text: catOf(group.name)[2] })])]));
            body.appendChild(el('div', { 'class': 'hbx-lib', style: 'margin-top:14px' }, group.types.map(palCard)));
        }
        box.appendChild(body);
    }
    function palCard(type) {
        var def = boot.types[type];
        return el('button', { type: 'button', 'class': 'hbx-pal', 'data-type': type, draggable: 'true', 'aria-label': 'Add ' + def.label,
            onclick: function () { addSection(type); },
            onmouseenter: function (e) { queuePeek(e.currentTarget); },
            onmouseleave: function () { queuePeek(null); },
            ondragstart: function (e) { dragType = type; hidePeek(); e.dataTransfer.effectAllowed = 'copy'; e.dataTransfer.setData('text/plain', type); },
            ondragend: function () { dragType = null; hideDrop(); } }, [
            el('span', { 'class': 'hbx-grip', html: svg('grip') }),
            el('span', { html: catTile(def.group, 'sm') }),
            el('span', { 'class': 'hbx-txt' }, [el('strong', { text: def.label }), el('span', { text: def.hint })]),
            el('span', { 'class': 'hbx-pal-add', html: svg('plus', 2) })
        ]);
    }

    // Hover a section in Add: the theme draws it beside the list.
    var peekTimer = null, peekFor = '', peekFrame = byId('hbx-peek-frame');
    function queuePeek(card) {
        window.clearTimeout(peekTimer);
        if (!card) { peekTimer = window.setTimeout(hidePeek, 120); return; }
        peekTimer = window.setTimeout(function () { showPeek(card); }, 180);
    }
    function showPeek(card) {
        var type = card.getAttribute('data-type'), def = typeDef(type), p = byId('hbx-peek'), r = card.getBoundingClientRect();
        byId('hbx-peek-head').innerHTML = catTile(def.group, 'sm') + esc(def.label) + '<small>As your theme draws it</small>';
        var key = type + lookQuery + state.lang;
        if (peekFor !== key) {
            peekFor = key;
            p.classList.add('is-loading');
            peekFrame.src = boot.previewPath + '?hb_sample=' + encodeURIComponent(type) + '&hb_lang=' + encodeURIComponent(state.lang) + lookQuery;
        }
        p.style.top = Math.min(Math.max(70, r.top - 40), window.innerHeight - 330) + 'px';
        p.style.left = (byId('hbx-panel').getBoundingClientRect().right + 12) + 'px';
        p.classList.add('is-on');
    }
    function hidePeek() { window.clearTimeout(peekTimer); byId('hbx-peek').classList.remove('is-on'); }
    peekFrame.addEventListener('load', function () {
        var d, s, kids, i;
        try { d = peekFrame.contentDocument; } catch (e) { d = null; }
        if (d && d.body) {
            // Only the section: the theme's header, menu and footer are the same for every one.
            s = d.querySelector('[data-hb-id]');
            if (s) {
                kids = d.body.children;
                for (i = kids.length - 1; i >= 0; i--) { if (kids[i].tagName !== 'SCRIPT') { kids[i].remove(); } }
                d.body.appendChild(s);
                d.body.style.margin = '0';
            }
        }
        byId('hbx-peek').classList.remove('is-loading');
    });

    // Layers: the page's sections, top to bottom.
    var dragId = null;
    function layersPanel(box) {
        var n = state.doc.sections.length, list = el('ol', { 'class': 'hbx-outline', id: 'hbx-outline' });
        box.appendChild(head('Layers', n ? n + (n === 1 ? ' section' : ' sections') + ', top to bottom. Drag to reorder.' : 'This page has no sections yet.'));
        state.doc.sections.forEach(function (section, i) {
            var def = typeDef(section.type);
            var item = el('li', {
                'class': 'hbx-out' + (section.id === state.sel ? ' is-sel' : '') + (section.hidden ? ' is-hidden' : '') + (section.id === state.hover ? ' is-hover' : ''),
                draggable: 'true', 'data-id': section.id,
                onclick: function () { select(section.id, true); },
                onmouseenter: function () { setHover(section.id); },
                onmouseleave: function () { setHover(null); },
                ondragstart: function (e) { dragId = section.id; item.classList.add('is-dragged'); e.dataTransfer.effectAllowed = 'move'; e.dataTransfer.setData('text/plain', section.id); },
                ondragend: function () { dragId = null; renderPanel(); },
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
                el('span', { 'class': 'hbx-grip', html: svg('grip'), title: 'Drag to reorder' }),
                el('span', { 'class': 'hbx-num', text: String(i + 1) }),
                el('span', { html: catTile(def.group) }),
                el('span', { 'class': 'hbx-txt' }, [el('b', { text: summary(section) }), el('small', { text: def.label })]),
                section.hidden ? el('span', { 'class': 'hbx-pill', text: 'Hidden' }) : null,
                el('span', { 'class': 'hbx-out-act' }, [
                    iconBtn(section.hidden ? 'eyeOff' : 'eye', section.hidden ? 'Show on the page' : 'Hide from the page', function (e) { e.stopPropagation(); toggleHidden(section.id); }),
                    iconBtn('copy', 'Duplicate section', function (e) { e.stopPropagation(); duplicateSection(section.id); }),
                    iconBtn('trash', 'Remove section', function (e) { e.stopPropagation(); removeSection(section.id); })
                ])
            ]);
            list.appendChild(item);
        });
        box.appendChild(el('div', { 'class': 'hbx-pb' }, [list,
            el('button', { type: 'button', 'class': 'hbx-add-wide', html: svg('plus', 2) + 'Add a section', onclick: function () { openAdd(state.doc.sections.length); } })]));
    }

    // Page: name, address, search and sharing.
    function pagePanel(box) {
        var body = el('div', { 'class': 'hbx-pb' }), id, group;
        box.appendChild(head('Page', 'What this page is called, where it lives, and how it shows in search results.'));

        group = el('div', { 'class': 'hbx-group-body', style: 'padding-top:14px' });
        id = 'hbx-page-name';
        group.appendChild(pageField('Name', id, el('input', { type: 'text', 'class': 'mt-input', id: id, maxlength: '120', value: state.name,
            oninput: function (e) { touch('page.name'); state.name = e.target.value; byId('hbx-name').textContent = state.name; changed(false); } }),
            'Only you see this, in the list of pages.', state.errors.name));
        id = 'hbx-page-slug';
        group.appendChild(pageField('Address', id, el('div', { 'class': 'hbx-addr' }, [
            el('span', { text: boot.siteUrl }),
            el('input', { type: 'text', id: id, value: state.slug, placeholder: 'hosting/wordpress', autocomplete: 'off', spellcheck: 'false',
                oninput: function (e) { touch('page.slug'); state.slug = e.target.value; changed(false); } })
        ]), 'Lowercase letters, numbers and hyphens. An address WHMCS already uses keeps showing the WHMCS page.', state.errors.slug));
        body.appendChild(el('div', { 'class': 'hbx-group', style: 'margin-top:4px' }, [group]));

        group = el('div', { 'class': 'hbx-group-body' });
        group.appendChild(fieldEl({ key: 'title', type: 'text', label: 'Title', translatable: true,
            help: 'Shown in the browser tab and in search results. The page name is used when this is empty.' }, state.meta, 'page.meta', null));
        group.appendChild(fieldEl({ key: 'description', type: 'textarea', label: 'Description', translatable: true,
            help: 'One or two sentences for search results.' }, state.meta, 'page.meta', null));
        body.appendChild(el('details', { 'class': 'hbx-group', open: true }, [
            el('summary', { html: 'Search and sharing<span class="hbx-chev">' + svg('chevDown') + '</span>' }), group]));

        body.appendChild(el('p', { 'class': 'hbx-help', style: 'margin-top:14px', text: 'Who can see the page, its layout and the rest of its SEO are set in Pages, as for every other page.' }));
        if (state.status === 'published') {
            body.appendChild(el('button', { type: 'button', 'class': 'mt-btn mt-btn-secondary mt-btn-block hbx-danger', text: 'Take this page offline', onclick: unpublish }));
        }
        box.appendChild(body);
    }
    function pageField(label, id, control, help, error) {
        var field = el('div', { 'class': 'hbx-field' }, [el('label', { 'class': 'hbx-label', 'for': id }, [el('span', { text: label })]), control]);
        if (error) { field.appendChild(el('p', { 'class': 'hbx-error', text: error })); }
        else if (help) { field.appendChild(el('p', { 'class': 'hbx-help', text: help })); }
        return field;
    }

    // The selected section's settings.
    function editPanel(box, section) {
        var def = typeDef(section.type), at = indexOf(section.id), n = state.doc.sections.length, c = catOf(def.group);
        var ph = el('div', { 'class': 'hbx-ph' }, [
            el('button', { type: 'button', 'class': 'hbx-crumb', html: svg('left', 2) + 'Layers', onclick: function () { select(null); } }),
            el('div', { 'class': 'hbx-id', style: '--c:' + c[1] }, [
                el('span', { html: catTile(def.group, 'lg') }),
                el('div', { 'class': 'hbx-id-txt' }, [
                    el('span', { 'class': 'hbx-id-kind', text: def.group }),
                    el('span', { 'class': 'hbx-id-name', text: def.label }),
                    el('span', { 'class': 'hbx-id-sum', id: 'hbx-id-sum', text: summary(section) })
                ])
            ]),
            el('div', { 'class': 'hbx-id-row' }, [
                el('span', { 'class': 'hbx-id-pos', text: 'Section ' + (at + 1) + ' of ' + n + (section.hidden ? ', hidden' : '') }),
                iconBtn('chevUp', 'Previous section', function () { if (at > 0) { select(state.doc.sections[at - 1].id, true); } }, at === 0 ? 'is-off' : ''),
                iconBtn('chevDown', 'Next section', function () { if (at < n - 1) { select(state.doc.sections[at + 1].id, true); } }),
                el('span', { 'class': 'hbx-sep' }),
                iconBtn('up', 'Move section up', function () { moveBy(section.id, -1); }),
                iconBtn('down', 'Move section down', function () { moveBy(section.id, 1); }),
                iconBtn('copy', 'Duplicate section', function () { duplicateSection(section.id); }),
                iconBtn(section.hidden ? 'eyeOff' : 'eye', section.hidden ? 'Show on the page' : 'Hide from the page', function () { toggleHidden(section.id); }),
                iconBtn('trash', 'Remove section', function () { removeSection(section.id); })
            ]),
            el('div', { 'class': 'hbx-tabs', role: 'tablist' }, [
                el('button', { type: 'button', role: 'tab', 'class': state.tab === 'content' ? 'is-active' : '', 'aria-selected': String(state.tab === 'content'), text: 'Content', onclick: function () { state.tab = 'content'; renderPanel(); } }),
                el('button', { type: 'button', role: 'tab', 'class': state.tab === 'section' ? 'is-active' : '', 'aria-selected': String(state.tab === 'section'), text: 'Section', onclick: function () { state.tab = 'section'; renderPanel(); } })
            ])
        ]);
        box.appendChild(ph);
        var body = el('div', { 'class': 'hbx-pb' });
        box.appendChild(body);

        if (state.tab === 'section') {
            body.appendChild(el('div', { 'class': 'hbx-group', style: 'margin-top:4px' }, [el('div', { 'class': 'hbx-group-body', style: 'padding-top:14px' }, kit.sectionEls(section))]));
            body.appendChild(el('button', { type: 'button', 'class': 'mt-btn mt-btn-secondary mt-btn-block hbx-danger', text: 'Remove this section', onclick: function () { removeSection(section.id); } }));
            return;
        }
        body.appendChild(el('div', { 'class': 'hbx-tip', style: 'margin-top:4px', html: svg('info') + '<span>Click text on the page to jump to its setting. Double-click to type on the page itself.</span>' }));
        kit.contentEls(section).forEach(function (node) { body.appendChild(node); });
    }

    // ------------------------------------------------- preview with another look

    function lookName(k, v) {
        var list = k === 'style' ? LOOKS.styles : (k === 'nav' ? LOOKS.layouts['main-menu'] : LOOKS.layouts.footer), i;
        if (k === 'theme') { return v === 'dark' ? 'Dark' : 'Light'; }
        for (i = 0; i < (list || []).length; i++) { if (list[i].name === v) { return list[i].label; } }
        return v;
    }
    function lookDiffers() { return ['style', 'nav', 'footer', 'theme'].some(function (k) { return state.look[k] !== LOOKS.site[k]; }); }
    function setLook(k, v) {
        if (!state.look || state.look[k] === v) { return; }
        state.look[k] = v;
        peekFor = '';
        renderLook();
        schedulePreview(true);
    }
    function renderLook() {
        var bar = byId('hbx-look'), diff, opts, accent = '#0071e3', i;
        if (!LOOKS || !LOOKS.styles || !LOOKS.styles.length) { bar.hidden = true; return; }
        bar.hidden = false;
        diff = lookDiffers();
        bar.classList.toggle('is-diff', diff);
        for (i = 0; i < LOOKS.styles.length; i++) { if (LOOKS.styles[i].name === state.look.style) { accent = LOOKS.styles[i].accent || accent; } }
        opts = function (k, list) {
            return (list || []).map(function (o) {
                return '<option value="' + esc(o.name) + '"' + (state.look[k] === o.name ? ' selected' : '') + '>' + esc(o.label) + (LOOKS.site[k] === o.name ? '  (your site)' : '') + '</option>';
            }).join('');
        };
        bar.innerHTML =
            '<span class="hbx-look-lbl">' + svg('eye') + 'Preview with</span>'
            + '<label class="hbx-look-pick" title="The colours of the whole site"><span class="hbx-look-dot" style="background:' + esc(accent) + '"></span><span class="k">Style</span>'
            + '<select data-look="style" aria-label="Style">' + opts('style', LOOKS.styles) + '</select></label>'
            + '<label class="hbx-look-pick"><span class="k">Navigation</span><select data-look="nav" aria-label="Navigation">' + opts('nav', LOOKS.layouts['main-menu']) + '</select></label>'
            + '<label class="hbx-look-pick"><span class="k">Footer</span><select data-look="footer" aria-label="Footer">' + opts('footer', LOOKS.layouts.footer) + '</select></label>'
            + (LOOKS.darkMode ? '<div class="hbx-seg" role="group" aria-label="Light or dark">'
                + '<button type="button" data-look-theme="light" class="' + (state.look.theme === 'light' ? 'is-active' : '') + '">Light</button>'
                + '<button type="button" data-look-theme="dark" class="' + (state.look.theme === 'dark' ? 'is-active' : '') + '">Dark</button></div>' : '')
            + '<span class="hbx-look-note">' + (diff
                ? '<b>Preview only.</b> Visitors still see ' + esc([lookName('style', LOOKS.site.style), lookName('nav', LOOKS.site.nav), lookName('footer', LOOKS.site.footer)].join(', ')) + '.'
                    + ' <button type="button" data-look-reset>Back to the site look</button>'
                : 'This is how your site looks now.') + '</span>'
            + '<a class="hbx-look-link" href="' + esc(boot.customizeUrl) + '" target="_blank" rel="noopener">Change the site look' + svg('right', 2) + '</a>';
    }
    (function () {
        var bar = byId('hbx-look');
        bar.addEventListener('change', function (e) { var k = e.target.getAttribute('data-look'); if (k) { setLook(k, e.target.value); } });
        bar.addEventListener('click', function (e) {
            var t = e.target.closest ? e.target.closest('[data-look-theme], [data-look-reset]') : null;
            if (!t) { return; }
            if (t.hasAttribute('data-look-theme')) { setLook('theme', t.getAttribute('data-look-theme')); return; }
            state.look = { style: LOOKS.site.style, nav: LOOKS.site.nav, footer: LOOKS.site.footer, theme: LOOKS.site.theme };
            peekFor = '';
            renderLook();
            schedulePreview(true);
        });
    })();

    // ----------------------------------------------------------------- wire

    function openAdd(at) {
        clearFieldHl();
        state.panel = 'add'; state.insertAt = at === undefined ? null : at; state.cat = null; state.query = '';
        if (state.sel) { state.sel = null; }
        renderAll();
        var s = byId('hbx-palfilter');
        if (s) { s.focus(); }
    }

    (function () {
        var btns = document.querySelectorAll('.hbx-rail-btn'), i;
        for (i = 0; i < btns.length; i++) {
            btns[i].addEventListener('click', function (e) {
                var p = e.currentTarget.getAttribute('data-panel');
                if (p === 'add') { openAdd(state.sel ? indexOf(state.sel) + 1 : null); return; }
                clearFieldHl();
                state.sel = null;
                state.insertAt = null;
                state.panel = p;
                renderAll();
            });
        }
    })();

    (function () {
        var sel = byId('hbx-lang');
        boot.languages.forEach(function (l) { sel.appendChild(el('option', { value: l.code, text: l.label })); });
        sel.addEventListener('change', function () {
            state.lang = sel.value;
            peekFor = '';
            renderPanel(); schedulePreview(true);
        });
    })();

    byId('hbx-device').addEventListener('click', function (e) {
        var b = e.target.closest ? e.target.closest('button[data-v]') : null, i, all;
        if (!b) { return; }
        all = byId('hbx-device').querySelectorAll('button');
        for (i = 0; i < all.length; i++) { all[i].classList.toggle('is-active', all[i] === b); }
        device = b.getAttribute('data-v');
        fitFrame();
    });

    byId('hbx-save').addEventListener('click', function () { save().then(function (ok) { if (ok) { notice('success', 'Draft saved. Visitors still see the published version until you publish.'); schedulePreview(true); } }); });
    byId('hbx-publish').addEventListener('click', publish);
    byId('hbx-undo').addEventListener('click', undo);
    byId('hbx-redo').addEventListener('click', redo);
    byId('hbx-panel').addEventListener('scroll', function () { stuck(); hidePeek(); });

    function keys(e) {
        var t = e.target, typing = t && (t.tagName === 'INPUT' || t.tagName === 'TEXTAREA' || t.tagName === 'SELECT' || t.isContentEditable);
        if ((e.ctrlKey || e.metaKey) && (e.key === 's' || e.key === 'S')) { e.preventDefault(); byId('hbx-save').click(); return; }
        if (typing) { return; }   // inside a text field the browser's own undo is the one people expect
        if (e.ctrlKey || e.metaKey) {
            if ((e.key === 'z' || e.key === 'Z') && !e.shiftKey) { e.preventDefault(); undo(); }
            else if (e.key === 'y' || e.key === 'Y' || ((e.key === 'z' || e.key === 'Z') && e.shiftKey)) { e.preventDefault(); redo(); }
            return;
        }
        if (e.key === 'Escape') {
            if (state.sel) { select(null); }
            else if (state.panel === 'add') { state.panel = 'layers'; state.insertAt = null; renderAll(); }
            return;
        }
        if (e.altKey && state.sel && (e.key === 'ArrowUp' || e.key === 'ArrowDown')) { e.preventDefault(); moveBy(state.sel, e.key === 'ArrowUp' ? -1 : 1); }
    }
    document.addEventListener('keydown', keys);

    window.addEventListener('beforeunload', function (e) {
        if (state.dirty) { e.preventDefault(); e.returnValue = ''; }
    });

    // For the test suite: the live state, and whether the preview is settled.
    window.hbBuilder = { state: state, idle: function () { return !pvQueued && !pvLoading; } };

    window.addEventListener('resize', fitFrame);
    renderLook();
    renderAll();
    fitFrame();
    schedulePreview(true);
})();
