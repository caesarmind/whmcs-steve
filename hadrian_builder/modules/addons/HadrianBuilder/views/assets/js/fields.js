/* Page builder: the pieces both content screens share. Plain browser
   JavaScript, no build step, ASCII only.

   Two screens edit a built page's sections:
     - the visual editor (page-builder.js), with the page beside it
     - the section list at the top of the page's settings in Hadrian's Pages
       (content-list.js)
   Both build their controls from the section schemas in the boot data, with
   the functions here, so a field looks and behaves the same in each.

   HadrianBuilderKit(boot, ctx) returns the kit. ctx tells it about the
   screen that uses it:
     lang()               the language being edited, '_' for the default text
     open                 object: which item of a list field is expanded,
                          "<path>.<field>" -> index
     touch(key)           call BEFORE a change (undo, dirty state)
     changed(structural)  call AFTER a change; structural means the controls
                          must be drawn again (an item added, a toggle that
                          changes what is shown)
     rerender()           draw the controls again (a list item opened or closed)
     typed                optional {before(p), after(p, row, text)}: around a
                          keystroke in a field that shows as text on the page,
                          for a screen that mirrors it there */
(function () {
    'use strict';

    window.HadrianBuilderKit = function (boot, ctx) {

        // --------------------------------------------------------- helpers

        function el(tag, attrs, children) {
            var node = document.createElement(tag), k;
            attrs = attrs || {};
            for (k in attrs) {
                if (!Object.prototype.hasOwnProperty.call(attrs, k) || attrs[k] === null || attrs[k] === undefined) { continue; }
                if (k === 'text') { node.textContent = attrs[k]; }
                else if (k === 'html') { node.innerHTML = attrs[k]; }
                else if (k.slice(0, 2) === 'on') { node.addEventListener(k.slice(2), attrs[k]); }
                else if (k === 'checked' || k === 'selected' || k === 'disabled' || k === 'hidden' || k === 'open') { node[k] = !!attrs[k]; }
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
        function esc(s) {
            return String(s === null || s === undefined ? '' : s).replace(/[&<>"']/g, function (c) {
                return { '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[c];
            });
        }
        function cut(s, n) { s = String(s || '').replace(/\s+/g, ' ').replace(/^\s+|\s+$/g, ''); return s.length > n ? s.slice(0, n - 3) + '...' : s; }
        function pathKey(p) { return p.join('.'); }

        /* Line icons on a 24 grid (STYLEGUIDE.md: stroke, currentColor). */
        var ICON = {
            plus: '<path d="M12 5v14M5 12h14"/>',
            left: '<path d="M15 18l-6-6 6-6"/>',
            right: '<path d="M9 18l6-6-6-6"/>',
            up: '<path d="M12 19V5M6 11l6-6 6 6"/>',
            down: '<path d="M12 5v14M6 13l6 6 6-6"/>',
            chevUp: '<path d="M6 15l6-6 6 6"/>',
            chevDown: '<path d="M6 9l6 6 6-6"/>',
            copy: '<rect x="8" y="8" width="12" height="12" rx="2"/><path d="M16 8V6a2 2 0 00-2-2H6a2 2 0 00-2 2v8a2 2 0 002 2h2"/>',
            trash: '<path d="M4 7h16M10 11v6M14 11v6"/><path d="M6 7l1 13h10l1-13M9 7V4h6v3"/>',
            eye: '<path d="M2 12s3.6-6.5 10-6.5S22 12 22 12s-3.6 6.5-10 6.5S2 12 2 12z"/><circle cx="12" cy="12" r="3"/>',
            eyeOff: '<path d="M3 3l18 18"/><path d="M10.6 6.1A10.6 10.6 0 0112 6c6.4 0 10 6 10 6a17 17 0 01-3.3 3.9M6.6 6.6C3.7 8.4 2 12 2 12s3.6 6.5 10 6.5c1.6 0 3-.4 4.3-1"/><path d="M9.9 9.9a3 3 0 004.2 4.2"/>',
            grip: '<circle cx="9" cy="6" r="1"/><circle cx="15" cy="6" r="1"/><circle cx="9" cy="12" r="1"/><circle cx="15" cy="12" r="1"/><circle cx="9" cy="18" r="1"/><circle cx="15" cy="18" r="1"/>',
            search: '<circle cx="11" cy="11" r="6.5"/><path d="M16 16l4.5 4.5"/>',
            info: '<circle cx="12" cy="12" r="9"/><path d="M12 11v5M12 8h.01"/>',
            target: '<circle cx="12" cy="12" r="8"/><circle cx="12" cy="12" r="3"/>',
            link: '<path d="M10 14a4 4 0 005.7 0l3-3a4 4 0 00-5.7-5.7l-1 1"/><path d="M14 10a4 4 0 00-5.7 0l-3 3a4 4 0 005.7 5.7l1-1"/>',
            list: '<path d="M9 6h11M9 12h11M9 18h11"/><circle cx="4.5" cy="6" r="1"/><circle cx="4.5" cy="12" r="1"/><circle cx="4.5" cy="18" r="1"/>',
            external: '<path d="M14 4h6v6"/><path d="M20 4l-9 9"/><path d="M18 14v5a1 1 0 01-1 1H5a1 1 0 01-1-1V7a1 1 0 011-1h5"/>',
            x: '<path d="M6 6l12 12M18 6L6 18"/>',
            question: '<circle cx="12" cy="12" r="9"/><path d="M9.5 9.5a2.5 2.5 0 015 0c0 1.7-2.5 2-2.5 4"/><path d="M12 17h.01"/>',
            doc: '<path d="M7 3h7l5 5v13H7z"/><path d="M14 3v5h5M10 13h6M10 17h6"/>',
            rocket: '<path d="M12 15l-3-3c1-4.5 4-8 9-9-1 5-4.5 8-9 9z"/><path d="M9 12l-4 1 2 2M12 15l-1 4-2-2"/><circle cx="14.5" cy="9.5" r="1.2"/>',
            tag: '<path d="M3 12V4h8l10 10-8 8z"/><circle cx="7.5" cy="8.5" r="1.2"/>',
            layers: '<path d="M12 3l9 5-9 5-9-5z"/><path d="M3 12l9 5 9-5"/><path d="M3 16l9 5 9-5"/>',
            pin: '<path d="M12 21s7-6.2 7-11.5a7 7 0 10-14 0C5 14.8 12 21 12 21z"/><circle cx="12" cy="9.5" r="2.5"/>',
            chat: '<path d="M4 5h16v11H9l-5 4z"/><path d="M8 9h8M8 12h5"/>',
            chart: '<path d="M4 20V10"/><path d="M10 20V4"/><path d="M16 20v-7"/><path d="M22 20H2"/>',
            bolt: '<path d="M13 2L4 14h7l-1 8 9-12h-7z"/>',
            bell: '<path d="M6 16V11a6 6 0 0112 0v5l2 2H4z"/><path d="M10 20a2 2 0 004 0"/>',
            box: '<path d="M12 3l8 4.5v9L12 21l-8-4.5v-9z"/><path d="M4 7.5l8 4.5 8-4.5M12 12v9"/>'
        };
        function svg(name, sw) {
            return '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="' + (sw || 1.8) + '" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">' + (ICON[name] || '') + '</svg>';
        }
        function iconBtn(name, title, onclick, extra) {
            return el('button', { type: 'button', 'class': 'hbx-ico' + (extra ? ' ' + extra : ''), title: title, 'aria-label': title, html: svg(name), onclick: onclick });
        }

        /* Each category has one colour and icon, wherever a section is named.
           Only the brandbook's icon-chip colours and its neutral grey; red is
           left out because it means an error. The icon tells two categories
           that share a colour apart. */
        var BRAND = { blue: '#0071e3', green: '#30d158', purple: '#af82ff', orange: '#ff9f0a', teal: '#5ac8fa', grey: '#8e8e93' };
        var CAT = {
            'Hero': ['rocket', BRAND.blue, 'The opening of a page'],
            'Pricing': ['tag', BRAND.green, 'Plans and prices from WHMCS'],
            'Features': ['layers', BRAND.purple, 'What you offer, in cards and rows'],
            'Locations': ['pin', BRAND.teal, 'Where your servers are'],
            'Testimonials': ['chat', BRAND.orange, 'What customers say'],
            'Questions': ['question', BRAND.purple, 'Answers people look for'],
            'Trust and numbers': ['chart', BRAND.green, 'Figures, badges and logos'],
            'Call to action': ['bolt', BRAND.blue, 'Ask for the order'],
            'Announcements': ['bell', BRAND.orange, 'News from WHMCS'],
            'Articles': ['doc', BRAND.teal, 'Guides and notes'],
            'Product tiles': ['box', BRAND.grey, 'Large linked product tiles']
        };
        function catOf(group) { return CAT[group] || ['box', BRAND.grey, '']; }
        function catTile(group, size) {
            var c = catOf(group);
            return '<span class="hbx-cat' + (size ? ' is-' + size : '') + '" style="--c:' + c[1] + '">' + svg(c[0], 2) + '</span>';
        }
        function typeDef(type) { return boot.types[type] || { label: type, hint: '', group: 'Other', fields: [] }; }

        // The section types by category, in the schemas' own order.
        var GROUPS = (function () {
            var g = {}, list = [];
            Object.keys(boot.types).forEach(function (t) {
                var def = boot.types[t], name = def.group || 'Other';
                if (!g[name]) { g[name] = { name: name, order: 1e9, types: [] }; list.push(g[name]); }
                g[name].types.push(t);
                g[name].order = Math.min(g[name].order, def.order || 500);
            });
            list.forEach(function (x) { x.types.sort(function (a, b) { return (boot.types[a].order || 500) - (boot.types[b].order || 500); }); });
            return list.sort(function (a, b) { return a.order - b.order; });
        })();

        function langLabel() {
            var i, lang = ctx.lang();
            for (i = 0; i < boot.languages.length; i++) { if (boot.languages[i].code === lang) { return boot.languages[i].label; } }
            return '';
        }
        /* The text the page shows for a value in the language being edited. */
        function pick(v) {
            var lang = ctx.lang();
            if (v === null || v === undefined) { return ''; }
            if (typeof v !== 'object') { return String(v); }
            return (lang !== '_' && v[lang]) ? v[lang] : (v._ || '');
        }
        function productName(id) {
            var i;
            for (i = 0; i < boot.products.length; i++) { if (boot.products[i].id === Number(id)) { return boot.products[i].name; } }
            return '';
        }

        /* What tells two sections of one kind apart: their own headline. */
        function summary(section) {
            var def = typeDef(section.type), prefer = ['title', 'heading', 'quote', 'lead', 'text', 'tag', 'label', 'firstTitle', 'bigTitle', 'eyebrow'], i, f, v, items;
            for (i = 0; i < prefer.length; i++) {
                v = section.props[prefer[i]];
                if (v !== undefined && typeof v !== 'boolean' && typeof v !== 'number') {
                    v = pick(v);
                    if (v && v.replace(/<[^>]*>/g, '').replace(/\s+/g, '')) { return cut(v.replace(/<[^>]*>/g, ' '), 60); }
                }
            }
            for (i = 0; i < def.fields.length; i++) {
                f = def.fields[i];
                if ((f.type === 'text' || f.type === 'textarea') && pick(section.props[f.key])) { return cut(pick(section.props[f.key]), 60); }
                if (f.type === 'list') {
                    items = section.props[f.key];
                    if (Array.isArray(items) && items.length) { return items.length + ' ' + f.label.toLowerCase(); }
                }
            }
            return def.hint || def.label;
        }

        /* A new section of `type`, with every field at its default. */
        function makeSection(type) {
            var def = boot.types[type], props = {};
            if (!def) { return null; }
            def.fields.forEach(function (f) { props[f.key] = clone(f['default']); });
            return { id: newId(), type: type, props: props, style: { spacing: 'regular', anchor: '' }, hidden: false };
        }

        // ------------------------------------------------------------ fields

        function getValue(f, obj) {
            var v = obj[f.key], lang = ctx.lang();
            if (!f.translatable) { return v; }
            if (v === null || v === undefined || typeof v !== 'object') { v = obj[f.key] = { _: v === null || v === undefined ? '' : String(v) }; }
            return lang === '_' ? (v._ || '') : (v[lang] || '');
        }
        function setValue(f, obj, value) {
            var v, lang = ctx.lang();
            if (!f.translatable) { obj[f.key] = value; return; }
            v = obj[f.key];
            if (v === null || v === undefined || typeof v !== 'object') { v = obj[f.key] = { _: '' }; }
            if (lang === '_') { v._ = value; }
            else if (value === '') { delete v[lang]; }
            else { v[lang] = value; }
        }
        function translationHint(f, obj) {
            var v = obj[f.key];
            return (f.translatable && ctx.lang() !== '_' && v && typeof v === 'object') ? (v._ || '') : '';
        }

        function wrapField(f, id, control, p, inline) {
            var label = el('label', { 'class': 'hbx-label', 'for': id }, [el('span', { text: f.label })]);
            if (f.translatable && ctx.lang() !== '_') { label.appendChild(el('small', { text: langLabel() })); }
            if (p && ctx.typed) { label.appendChild(el('span', { 'class': 'hbx-loc', html: svg('target', 2) + 'On the page' })); }
            var field = el('div', { 'class': 'hbx-field', 'data-path': p ? pathKey(p) : null });
            if (inline) { field.appendChild(el('div', { 'class': 'hbx-inline' }, [label, control])); }
            else { field.appendChild(label); field.appendChild(control); }
            if (f.help) { field.appendChild(el('p', { 'class': 'hbx-help', text: f.help })); }
            return field;
        }

        var fieldSeq = 0;

        /* One control for one field. `obj` holds the value (a section's props,
           one item of a list, the page meta); `path` names it for undo; `p` is
           its place in the section ([key] or [list, index, key]) for fields
           that show on the page, null for the others. */
        function fieldEl(f, obj, path, p) {
            var id = 'hbx-f' + (++fieldSeq), key = path + '.' + f.key, c;
            var onText = function (e) {
                var row = e.target.closest('.hbx-field');
                if (p && ctx.typed) { ctx.typed.before(p); }
                ctx.touch(key);
                setValue(f, obj, e.target.value);
                if (p && ctx.typed && row) { ctx.typed.after(p, row, pick(obj[f.key])); }
                ctx.changed(false);
            };

            switch (f.type) {
                case 'text':
                case 'link':
                    c = el('input', { type: 'text', 'class': 'mt-input', id: id, value: getValue(f, obj) || '',
                        placeholder: f.type === 'link' ? 'https://, #section or cart.php?gid=1' : translationHint(f, obj), oninput: onText });
                    return wrapField(f, id, c, p);

                case 'textarea':
                    c = el('textarea', { 'class': 'mt-input', id: id, rows: '3', placeholder: translationHint(f, obj), oninput: onText });
                    c.value = getValue(f, obj) || '';
                    return wrapField(f, id, c, p);

                case 'lines':
                    c = el('textarea', { 'class': 'mt-input', id: id, rows: '5', placeholder: translationHint(f, obj) || 'One per line', oninput: onText });
                    c.value = getValue(f, obj) || '';
                    return wrapField(f, id, c, p);

                case 'rich':
                    return wrapField(f, id, richEl(f, obj, key, id), p);

                case 'image':
                    c = el('input', { type: 'text', 'class': 'mt-input', id: id, value: getValue(f, obj) || '', placeholder: 'Choose an image',
                        'data-mt-media': '', 'data-mt-media-value': 'url', 'data-mt-media-collection': 'library',
                        'data-mt-media-title': f.label, 'data-mt-media-hint': 'JPG, PNG, WebP or SVG', oninput: onText });
                    return wrapField(f, id, c, p);

                case 'number':
                    c = el('div', { 'class': 'hbx-unit' }, [
                        el('input', { type: 'number', 'class': 'mt-input', id: id, value: String(getValue(f, obj)), min: String(f.min), max: String(f.max),
                            oninput: function (e) { ctx.touch(key); obj[f.key] = parseInt(e.target.value, 10) || 0; ctx.changed(false); } }),
                        f.unit ? el('span', { text: f.unit }) : null
                    ]);
                    return wrapField(f, id, c, p, true);

                case 'toggle':
                    c = el('label', { 'class': 'mt-toggle' }, [
                        el('input', { type: 'checkbox', id: id, checked: !!obj[f.key], onchange: function (e) { ctx.touch(''); obj[f.key] = e.target.checked; ctx.changed(f.key === 'hidden'); } }),
                        el('span', { 'class': 'mt-toggle-track' }, [el('span', { 'class': 'mt-toggle-thumb' })])
                    ]);
                    return wrapField(f, id, c, p, true);

                case 'select':
                    c = el('select', { 'class': 'mt-select', id: id, onchange: function (e) { ctx.touch(''); obj[f.key] = e.target.value; ctx.changed(false); } },
                        Object.keys(f.options).map(function (v) { return el('option', { value: v, selected: String(obj[f.key]) === v, text: f.options[v] }); }));
                    return wrapField(f, id, c, p);

                case 'product':
                    return wrapField(f, id, productEl(f, obj, id), p);

                case 'icon':
                    return wrapField(f, id, iconEl(f, obj), p);
            }
            return el('div');
        }

        function richEl(f, obj, key, id) {
            var area = el('div', { 'class': 'hbx-rich', id: id, contenteditable: 'true', 'data-placeholder': translationHint(f, obj).replace(/<[^>]+>/g, '') || 'Write here' });
            area.innerHTML = getValue(f, obj) || '';
            var sync = function () { ctx.touch(key); setValue(f, obj, area.innerHTML === '<br>' ? '' : area.innerHTML); ctx.changed(false); };
            area.addEventListener('input', sync);
            var cmd = function (name, arg) { return function (e) { e.preventDefault(); area.focus(); document.execCommand(name, false, arg || null); sync(); }; };
            var bar = el('div', { 'class': 'hbx-rich-bar' }, [
                el('button', { type: 'button', 'class': 'hbx-ico', title: 'Bold', 'aria-label': 'Bold', text: 'B', onmousedown: cmd('bold') }),
                el('button', { type: 'button', 'class': 'hbx-ico', title: 'Italic', 'aria-label': 'Italic', text: 'I', style: 'font-style:italic', onmousedown: cmd('italic') }),
                el('button', { type: 'button', 'class': 'hbx-ico', title: 'Bulleted list', 'aria-label': 'Bulleted list', html: svg('list'), onmousedown: cmd('insertUnorderedList') }),
                el('button', { type: 'button', 'class': 'hbx-ico', title: 'Link', 'aria-label': 'Link', html: svg('link'), onmousedown: function (e) {
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
            var groups = {}, order = [], sel;
            boot.products.forEach(function (p) {
                var g = p.group || 'Products';
                if (!groups[g]) { groups[g] = []; order.push(g); }
                groups[g].push(p);
            });
            sel = el('select', { 'class': 'mt-select', id: id, onchange: function (e) { ctx.touch(''); obj[f.key] = parseInt(e.target.value, 10) || 0; ctx.changed(true); } },
                [el('option', { value: '0', text: 'Choose a product', selected: !obj[f.key] })]);
            order.forEach(function (g) {
                sel.appendChild(el('optgroup', { label: g }, groups[g].map(function (p) {
                    return el('option', { value: String(p.id), text: p.name, selected: Number(obj[f.key]) === p.id });
                })));
            });
            return sel;
        }

        function iconEl(f, obj) {
            var grid = el('div', { 'class': 'hbx-icons', role: 'group', 'aria-label': f.label });
            var choose = function (name) { return function () { ctx.touch(''); obj[f.key] = name; ctx.changed(true); }; };
            grid.appendChild(el('button', { type: 'button', 'class': 'hbx-icon is-none' + (!obj[f.key] ? ' is-active' : ''), title: 'No icon', text: 'None', onclick: choose('') }));
            Object.keys(boot.icons).forEach(function (name) {
                grid.appendChild(el('button', { type: 'button', 'class': 'hbx-icon' + (obj[f.key] === name ? ' is-active' : ''),
                    title: boot.iconNames[name] || name, 'aria-label': boot.iconNames[name] || name, html: boot.icons[name], onclick: choose(name) }));
            });
            return grid;
        }

        function groupEl(title, count, children) {
            return el('details', { 'class': 'hbx-group', open: true }, [
                el('summary', { html: esc(title) + (count !== null ? ' <small>' + count + '</small>' : '') + '<span class="hbx-chev">' + svg('chevDown') + '</span>' }),
                el('div', { 'class': 'hbx-group-body' }, children)
            ]);
        }

        /* A list field (plans, cards, questions): one row per item, opened to edit. */
        function listEl(f, obj, path) {
            var items = Array.isArray(obj[f.key]) ? obj[f.key] : (obj[f.key] = []);
            var openKey = path + '.' + f.key, rep = el('div', { 'class': 'hbx-rep' }), labelField = null;
            f.fields.forEach(function (sub) { if (sub.key === f.itemLabel) { labelField = sub; } });

            items.forEach(function (item, i) {
                var isOpen = ctx.open[openKey] === i, name = '';
                if (labelField && labelField.type === 'product') { name = productName(item[labelField.key]); }
                else if (labelField) { name = pick(item[labelField.key]); }
                if (!name) { f.fields.some(function (sub) { if (sub.type === 'product' && item[sub.key]) { name = productName(item[sub.key]); } return !!name; }); }
                var headRow = el('div', { 'class': 'hbx-rep-head', onclick: function () { ctx.open[openKey] = isOpen ? -1 : i; ctx.rerender(); } }, [
                    el('span', { 'class': 'hbx-rep-num', text: String(i + 1) }),
                    el('span', { 'class': 'hbx-rep-name', text: cut(name, 40) || (f.label + ' ' + (i + 1)) }),
                    iconBtn('chevUp', 'Move up', function (e) { e.stopPropagation(); if (i > 0) { ctx.touch(''); items.splice(i - 1, 0, items.splice(i, 1)[0]); ctx.open[openKey] = isOpen ? i - 1 : -1; ctx.changed(true); } }),
                    iconBtn('chevDown', 'Move down', function (e) { e.stopPropagation(); if (i < items.length - 1) { ctx.touch(''); items.splice(i + 1, 0, items.splice(i, 1)[0]); ctx.open[openKey] = isOpen ? i + 1 : -1; ctx.changed(true); } }),
                    iconBtn('trash', 'Remove', function (e) { e.stopPropagation(); ctx.touch(''); items.splice(i, 1); ctx.open[openKey] = -1; ctx.changed(true); })
                ]);
                var box = el('div', { 'class': 'hbx-rep-item' + (isOpen ? ' is-open' : '') }, [headRow]);
                if (isOpen) {
                    box.appendChild(el('div', { 'class': 'hbx-rep-body' }, f.fields.map(function (sub) {
                        return fieldEl(sub, item, openKey + '.' + i, [f.key, i, sub.key]);
                    })));
                }
                rep.appendChild(box);
            });

            rep.appendChild(el('button', { type: 'button', 'class': 'hbx-add', html: svg('plus', 2) + esc(f.addLabel), disabled: items.length >= f.max, onclick: function () {
                var item = {};
                f.fields.forEach(function (sub) { item[sub.key] = clone(sub['default']); });
                ctx.touch('');
                items.push(item);
                ctx.open[openKey] = items.length - 1;
                ctx.changed(true);
            } }));
            var kids = [rep];
            if (f.help) { kids.push(el('p', { 'class': 'hbx-help', text: f.help })); }
            return groupEl(f.label, items.length, kids);
        }

        /* A section's content fields, grouped: Text (with its lists right
           after it), Buttons and links, Image, Product, Options. */
        var GROUP_ORDER = ['Text', 'Buttons and links', 'Image', 'Product', 'Options'];
        function groupOf(f) {
            if (f.type === 'list') { return null; }
            if (f.type === 'image' || f.type === 'icon' || /alt$/i.test(f.key)) { return 'Image'; }
            if (f.type === 'product') { return 'Product'; }
            if (f.type === 'link' || (f.type === 'text' && /label$|link/i.test(f.key))) { return 'Buttons and links'; }
            if (f.type === 'toggle' || f.type === 'select' || f.type === 'number') { return 'Options'; }
            return 'Text';
        }
        function contentEls(section) {
            var def = typeDef(section.type), groups = {}, lists = [], out = [];
            def.fields.forEach(function (f) { var name = groupOf(f); if (name) { (groups[name] = groups[name] || []).push(f); } else { lists.push(f); } });
            GROUP_ORDER.forEach(function (name) {
                if (!groups[name]) { return; }
                out.push(groupEl(name, null, groups[name].map(function (f) { return fieldEl(f, section.props, section.id, [f.key]); })));
                // Lists (plans, cards, questions) right after the text they belong to.
                if (name === 'Text') { lists.forEach(function (f) { out.push(listEl(f, section.props, section.id)); }); lists = []; }
            });
            lists.forEach(function (f) { out.push(listEl(f, section.props, section.id)); });
            return out;
        }

        /* Space above and below, the anchor, and hidden: a section's own settings. */
        function sectionEls(section) {
            var spacing = el('div', { 'class': 'hbx-spacing', role: 'group', 'aria-label': 'Space above and below' });
            var heights = { compact: 12, regular: 20, roomy: 28 };
            Object.keys(boot.spacing).forEach(function (k) {
                spacing.appendChild(el('button', { type: 'button', 'class': section.style.spacing === k ? 'is-active' : '', 'aria-pressed': String(section.style.spacing === k),
                    html: '<i style="height:' + (heights[k] || 20) + 'px"></i>' + esc(boot.spacing[k]),
                    onclick: function () { ctx.touch(''); section.style.spacing = k; ctx.changed(true); } }));
            });
            return [
                el('div', { 'class': 'hbx-field' }, [el('div', { 'class': 'hbx-label' }, [el('span', { text: 'Space above and below' })]), spacing]),
                fieldEl({ key: 'anchor', type: 'text', label: 'Anchor',
                    help: 'A name other links can jump to. With "pricing" here, a button linking to #pricing scrolls to this section.' }, section.style, section.id + '.style', null),
                fieldEl({ key: 'hidden', type: 'toggle', label: 'Hide from the page', help: 'Kept in the page, but visitors do not see it.' }, section, section.id, null)
            ];
        }

        return {
            el: el, clone: clone, newId: newId, esc: esc, cut: cut, pathKey: pathKey,
            ICON: ICON, svg: svg, iconBtn: iconBtn, CAT: CAT, catOf: catOf, catTile: catTile,
            typeDef: typeDef, GROUPS: GROUPS, langLabel: langLabel, pick: pick, productName: productName,
            summary: summary, makeSection: makeSection,
            getValue: getValue, setValue: setValue, fieldEl: fieldEl, listEl: listEl, groupEl: groupEl,
            contentEls: contentEls, sectionEls: sectionEls,
            resetIds: function () { fieldSeq = 0; }
        };
    };
})();
