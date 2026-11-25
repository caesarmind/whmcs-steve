/* Page builder: a built page's sections as a list, at the top of its settings
   in Hadrian's Pages screen (ContentPanel). Plain browser JavaScript, ASCII.

   One row per section, in page order. A row opens in place to edit the
   section with the same controls as the visual editor (fields.js), drags to
   a new place, and can be hidden, duplicated or removed. "Add section" opens
   the categories in a dialog. Save draft writes the sections only
   (api-content); Publish makes the draft live (api-publish); Preview opens
   the page as it is now, unsaved changes included, in a new tab. */
(function () {
    'use strict';

    var bootEl = document.getElementById('hbc-boot');
    if (!bootEl || !window.HadrianBuilderKit) { return; }
    var boot = JSON.parse(bootEl.textContent);
    var byId = function (id) { return document.getElementById(id); };

    var state = {
        doc: boot.doc, status: boot.status, changed: boot.changed, pageUrl: boot.pageUrl,
        lang: '_',
        dirty: false,
        busy: false,
        openRows: {},       // sectionId -> true while its fields are shown (one at a time)
        open: {},           // list items expanded inside a section (fields.js)
        cat: null,          // the category open in the Add dialog
        query: ''
    };

    var kit = window.HadrianBuilderKit(boot, {
        lang: function () { return state.lang; },
        open: state.open,
        touch: function () {},
        changed: function (structural) { markDirty(); if (structural) { render(); } else { refreshSummaries(); } },
        rerender: function () { render(); }
    });
    var el = kit.el, svg = kit.svg, esc = kit.esc, iconBtn = kit.iconBtn, catTile = kit.catTile, typeDef = kit.typeDef;

    function indexOf(id) {
        var i;
        for (i = 0; i < state.doc.sections.length; i++) { if (state.doc.sections[i].id === id) { return i; } }
        return -1;
    }

    // ------------------------------------------------------------- status

    function markDirty() {
        state.dirty = true;
        renderStatus();
    }
    function renderStatus() {
        var badge = byId('hbc-status'), label, kind;
        if (state.dirty) { label = 'Unsaved changes'; kind = 'warning'; }
        else if (state.status === 'published' && state.changed) { label = 'Published, draft is newer'; kind = 'warning'; }
        else if (state.status === 'published') { label = 'Published'; kind = 'success'; }
        else { label = 'Draft'; kind = 'neutral'; }
        badge.textContent = label;
        badge.className = 'mt-badge mt-badge-' + kind;
        byId('hbc-save').disabled = !state.dirty || state.busy;
        byId('hbc-publish').disabled = state.busy;
        byId('hbc-publish').textContent = state.status === 'published' ? 'Publish changes' : 'Publish';
    }
    function notice(kind, message) {
        var box = byId('hbc-notice');
        box.textContent = '';
        if (message) { box.appendChild(el('div', { 'class': 'mt-alert mt-alert-' + kind, text: message })); }
    }

    // ------------------------------------------------------------- server

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
    function setBusy(on) { state.busy = on; renderStatus(); }

    function save() {
        notice('', '');
        setBusy(true);
        return api('api-content', { doc: state.doc }).then(function (res) {
            setBusy(false);
            if (!res.ok) { notice('danger', res.error); return false; }
            state.doc = res.doc;
            state.status = res.status; state.changed = res.changed; state.pageUrl = res.pageUrl;
            state.dirty = false;
            render();
            return true;
        });
    }
    function publish() {
        var first = state.dirty ? save() : Promise.resolve(true);
        first.then(function (ok) {
            if (!ok) { return; }
            setBusy(true);
            api('api-publish', {}).then(function (res) {
                setBusy(false);
                if (!res.ok) { notice('danger', res.error); return; }
                state.status = res.status; state.changed = res.changed; state.pageUrl = res.pageUrl;
                renderStatus();
                notice('success', 'Published. The page is live at ' + state.pageUrl);
            });
        });
    }
    /* The page as it is now, unsaved changes included, in a new tab. The tab
       is opened at once, while the click still counts, and pointed at the
       preview when the server has it. */
    function preview() {
        var tab = window.open('', '_blank');
        api('api-preview', { doc: state.doc, lang: state.lang }).then(function (res) {
            if (!res.ok) { if (tab) { tab.close(); } notice('danger', res.error); return; }
            if (tab) { tab.location = res.url; }
            else { notice('info', 'Your browser blocked the new tab. The preview is at ' + res.url); }
        });
    }

    // ---------------------------------------------------------------- list

    var dragId = null;

    function render() {
        var list = byId('hbc-list'), n = state.doc.sections.length;
        kit.resetIds();
        list.textContent = '';
        if (!n) {
            list.appendChild(el('li', { 'class': 'hbc-empty', text: 'This page has no sections yet. Add the first one below.' }));
        }
        state.doc.sections.forEach(function (section, i) { list.appendChild(row(section, i, n)); });
        renderStatus();
    }

    function row(section, i, n) {
        var def = typeDef(section.type), isOpen = !!state.openRows[section.id], item, head, body;
        // One section open at a time keeps the page short.
        var toggle = function () { state.openRows = {}; if (!isOpen) { state.openRows[section.id] = true; } render(); };
        // A click anywhere on the row opens it; the toggle button at its end is
        // the same action for the keyboard and screen readers. The row itself is
        // not a button: it holds buttons of its own.
        head = el('div', {
            'class': 'hbc-head-row', draggable: 'true',
            onclick: function (e) { if (!e.target.closest('button')) { toggle(); } },
            ondragstart: function (e) { dragId = section.id; item.classList.add('is-dragged'); e.dataTransfer.effectAllowed = 'move'; e.dataTransfer.setData('text/plain', section.id); },
            ondragend: function () { dragId = null; render(); }
        }, [
            el('span', { 'class': 'hbx-grip', html: svg('grip'), title: 'Drag to reorder' }),
            el('span', { 'class': 'hbc-num', text: String(i + 1) }),
            el('span', { html: catTile(def.group) }),
            el('span', { 'class': 'hbc-txt' }, [el('b', { 'class': 'hbc-sum', text: kit.summary(section) }), el('small', { text: def.label + ' - ' + def.group })]),
            section.hidden ? el('span', { 'class': 'hbx-pill', text: 'Hidden' }) : null,
            el('span', { 'class': 'hbc-act' }, [
                iconBtn('chevUp', 'Move section up', function () { move(section.id, -1); }, i === 0 ? 'is-off' : ''),
                iconBtn('chevDown', 'Move section down', function () { move(section.id, 1); }, i === n - 1 ? 'is-off' : ''),
                iconBtn(section.hidden ? 'eyeOff' : 'eye', section.hidden ? 'Show on the page' : 'Hide from the page', function () { section.hidden = !section.hidden; markDirty(); render(); }),
                iconBtn('copy', 'Duplicate section', function () { duplicate(section.id); }),
                iconBtn('trash', 'Remove section', function () { remove(section.id); })
            ]),
            el('button', { type: 'button', 'class': 'hbc-open', title: isOpen ? 'Close' : 'Edit', 'aria-label': (isOpen ? 'Close ' : 'Edit ') + def.label,
                'aria-expanded': String(isOpen), html: svg('chevDown'), onclick: toggle })
        ]);
        item = el('li', {
            'class': 'hbc-row' + (isOpen ? ' is-open' : '') + (section.hidden ? ' is-hidden' : ''), 'data-id': section.id,
            ondragover: function (e) {
                if (!dragId || dragId === section.id) { return; }
                e.preventDefault();
                var r = item.getBoundingClientRect(), before = e.clientY < r.top + Math.min(r.height, 64) / 2;
                item.classList.toggle('is-over-before', before);
                item.classList.toggle('is-over-after', !before);
            },
            ondragleave: function () { item.classList.remove('is-over-before', 'is-over-after'); },
            ondrop: function (e) {
                if (!dragId || dragId === section.id) { return; }
                e.preventDefault();
                var r = item.getBoundingClientRect(), before = e.clientY < r.top + Math.min(r.height, 64) / 2, from = indexOf(dragId), moved, to;
                moved = state.doc.sections.splice(from, 1)[0];
                to = indexOf(section.id);
                state.doc.sections.splice(before ? to : to + 1, 0, moved);
                dragId = null;
                markDirty();
                render();
            }
        }, [head]);
        if (isOpen) {
            body = el('div', { 'class': 'hbc-body' });
            kit.contentEls(section).forEach(function (node) { body.appendChild(node); });
            body.appendChild(el('details', { 'class': 'hbx-group' }, [
                el('summary', { html: 'Section settings <small>space, anchor, hidden</small><span class="hbx-chev">' + svg('chevDown') + '</span>' }),
                el('div', { 'class': 'hbx-group-body' }, kit.sectionEls(section))
            ]));
            item.appendChild(body);
        }
        return item;
    }
    /* After typing: the row's headline follows, without redrawing the fields. */
    function refreshSummaries() {
        var rows = byId('hbc-list').querySelectorAll('.hbc-row'), i, section;
        for (i = 0; i < rows.length; i++) {
            section = state.doc.sections[indexOf(rows[i].getAttribute('data-id'))];
            if (section) { rows[i].querySelector('.hbc-sum').textContent = kit.summary(section); }
        }
    }

    function move(id, delta) {
        var from = indexOf(id), to = from + delta, moved;
        if (from < 0 || to < 0 || to >= state.doc.sections.length) { return; }
        moved = state.doc.sections.splice(from, 1)[0];
        state.doc.sections.splice(to, 0, moved);
        markDirty();
        render();
    }
    function duplicate(id) {
        var at = indexOf(id), copy;
        if (at < 0) { return; }
        copy = kit.clone(state.doc.sections[at]);
        copy.id = kit.newId();
        copy.style.anchor = '';        // two elements cannot share an id
        state.doc.sections.splice(at + 1, 0, copy);
        state.openRows = {};
        state.openRows[copy.id] = true;
        markDirty();
        render();
    }
    function remove(id) {
        var at = indexOf(id), def;
        if (at < 0) { return; }
        def = typeDef(state.doc.sections[at].type);
        if (!window.confirm('Remove the "' + def.label + '" section? Nothing changes for visitors until you save and publish.')) { return; }
        state.doc.sections.splice(at, 1);
        delete state.openRows[id];
        markDirty();
        render();
    }
    function add(type) {
        var section = kit.makeSection(type), node;
        if (!section) { return; }
        state.doc.sections.push(section);
        state.openRows = {};
        state.openRows[section.id] = true;
        closeAdd();
        markDirty();
        render();
        node = byId('hbc-list').querySelector('[data-id="' + section.id + '"]');
        if (node) { node.scrollIntoView({ block: 'start', behavior: 'smooth' }); }
    }

    // ----------------------------------------------------------- Add dialog

    function openAdd() {
        state.cat = null; state.query = '';
        byId('hbc-q').value = '';
        byId('hbc-modal').hidden = false;
        renderAdd();
        byId('hbc-q').focus();
    }
    function closeAdd() { byId('hbc-modal').hidden = true; }
    function renderAdd() {
        var body = byId('hbc-modal-body'), q = state.query.replace(/^\s+|\s+$/g, '').toLowerCase(), total = Object.keys(boot.types).length;
        body.textContent = '';
        byId('hbc-modal-sub').textContent = total + ' sections in ' + kit.GROUPS.length + ' categories. A new section goes at the end; drag it where you want it.';
        var card = function (type) {
            var d = boot.types[type];
            return el('button', { type: 'button', 'class': 'hbx-pal', 'data-type': type, 'aria-label': 'Add ' + d.label, onclick: function () { add(type); } }, [
                el('span', { html: catTile(d.group, 'sm') }),
                el('span', { 'class': 'hbx-txt' }, [el('strong', { text: d.label }), el('span', { text: d.hint })]),
                el('span', { 'class': 'hbx-pal-add', html: svg('plus', 2) })
            ]);
        };
        if (q) {
            var hits = 0;
            kit.GROUPS.forEach(function (g) {
                var types = g.types.filter(function (t) { var d = boot.types[t]; return (d.label + ' ' + d.hint + ' ' + g.name).toLowerCase().indexOf(q) !== -1; });
                if (!types.length) { return; }
                hits += types.length;
                body.appendChild(el('div', { 'class': 'hbx-lib-group', html: catTile(g.name, 'sm') + esc(g.name) }));
                body.appendChild(el('div', { 'class': 'hbc-lib' }, types.map(card)));
            });
            if (!hits) { body.appendChild(el('div', { 'class': 'hbx-empty', text: 'No section matches "' + state.query + '".' })); }
        } else if (!state.cat) {
            body.appendChild(el('div', { 'class': 'hbc-cats' }, kit.GROUPS.map(function (g) {
                return el('button', { type: 'button', 'class': 'hbx-cat-card', 'data-cat': g.name, onclick: function () { state.cat = g.name; renderAdd(); } }, [
                    el('span', { html: catTile(g.name) }),
                    el('span', {}, [el('b', { text: g.name }), el('small', { text: g.types.length + (g.types.length === 1 ? ' section' : ' sections') })])
                ]);
            })));
        } else {
            var group = null;
            kit.GROUPS.forEach(function (g) { if (g.name === state.cat) { group = g; } });
            body.appendChild(el('button', { type: 'button', 'class': 'hbc-back', html: svg('left', 2) + 'All categories', onclick: function () { state.cat = null; renderAdd(); } }));
            body.appendChild(el('div', { 'class': 'hbx-cat-head' }, [el('span', { html: catTile(group.name, 'lg') }),
                el('div', {}, [el('b', { text: group.name }), el('small', { text: kit.catOf(group.name)[2] })])]));
            body.appendChild(el('div', { 'class': 'hbc-lib', style: 'margin-top:14px' }, group.types.map(card)));
        }
    }

    // ----------------------------------------------------------------- wire

    (function () {
        var sel = byId('hbc-lang');
        if (boot.languages.length < 2) { sel.hidden = true; return; }
        boot.languages.forEach(function (l) { sel.appendChild(el('option', { value: l.code, text: l.label })); });
        sel.addEventListener('change', function () { state.lang = sel.value; render(); });
    })();
    byId('hbc-save').addEventListener('click', function () { save().then(function (ok) { if (ok) { notice('success', 'Draft saved. Visitors still see the published version until you publish.'); } }); });
    byId('hbc-publish').addEventListener('click', publish);
    byId('hbc-preview').addEventListener('click', preview);
    byId('hbc-add').addEventListener('click', openAdd);
    byId('hbc-modal-x').addEventListener('click', closeAdd);
    byId('hbc-modal').addEventListener('click', function (e) { if (e.target === e.currentTarget) { closeAdd(); } });
    byId('hbc-q').addEventListener('input', function (e) { state.query = e.target.value; renderAdd(); });
    document.addEventListener('keydown', function (e) { if (e.key === 'Escape' && !byId('hbc-modal').hidden) { closeAdd(); } });
    // Leaving for the visual editor with unsaved changes: say so, as the browser would.
    byId('hbc-visual').addEventListener('click', function (e) {
        if (state.dirty && !window.confirm('You have unsaved changes in this list. Leave without saving them?')) { e.preventDefault(); }
        else { state.dirty = false; }
    });
    window.addEventListener('beforeunload', function (e) {
        if (state.dirty) { e.preventDefault(); e.returnValue = ''; }
    });

    // For the test suite.
    window.hbContent = { state: state };

    render();
})();
