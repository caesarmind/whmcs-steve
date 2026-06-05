/* MyTheme — Unified list-table engine (Lagom-parity Dynamic AJAX Loading).
 *
 * ONE engine drives every client-area list table (services, domains, invoices,
 * quotes, tickets, emails) in BOTH modes, chosen per <table> by whether the
 * admin "Enable Dynamic AJAX Loading" setting tagged it with data-mt-action:
 *
 *   • SERVER-SIDE (data-mt-action present): DataTables runs serverSide — paging,
 *     search, sort, and status-filter happen at the DB. The <tbody> ships empty
 *     and rows are rebuilt from JSON by the per-type render fns in COLUMNS. The
 *     request POSTs `mtAction` + DataTables params to the endpoint (hooks.php →
 *     AjaxService → TableData).
 *
 *   • CLIENT-SIDE (data-mt-type only, no data-mt-action): the page server-renders
 *     ALL rows into the <tbody>; DataTables enhances that static table for
 *     client-side paging/search/sort/filter. No network calls.
 *
 * Either way the SAME Apple chrome is driven through controls tagged
 * data-mt-for="<tableId>": the search box (data-mt-search), page-size <select>
 * (data-dt-length), pager (data-dt-pager), info text (data-dt-info) and the
 * filter tabs (data-mt-filter). Row-click navigation (tr[data-href]) and kebab
 * menus (data-mt-kebab / data-mt-kebab-btn) are handled by one global delegation
 * for both modes.
 *
 * Per-table config rides on the <table> as data-attributes:
 *   data-mt-type        list type — keys COLUMNS / TYPE_META          (required)
 *   data-mt-order       initial "<colIdx>:<asc|desc>"                  (default 0:desc)
 *   data-mt-length      initial page size                             (default 10)
 *   data-mt-filter-col  status column index for client-side filtering (optional; TYPE_META fallback)
 *   data-mt-action      server-side mtAction — its presence selects serverSide mode
 *   data-mt-endpoint    server-side POST URL                          (default clientarea.php)
 * Non-sortable headers are marked with th[data-mt-noorder].
 *
 * All user copy comes from window.MyThemeTablesLang (English fallback below) and
 * every dynamic value passes through esc() before hitting innerHTML.
 *
 * Loaded on every list page (both modes). Requires jQuery + DataTables; no-ops if
 * either is missing.
 */
(function () {
    'use strict';

    if (typeof jQuery === 'undefined' || !jQuery.fn || !jQuery.fn.DataTable) {
        return;
    }
    var $ = jQuery;

    // A failed request (e.g. flag turned off mid-session → 403) should not throw
    // a blocking alert; leave the table empty instead.
    $.fn.dataTable.ext.errMode = 'none';

    // ------------------------------------------------------------------ i18n

    var LANG_FALLBACK = {
        showing: 'Showing', to: '–', of: 'of',
        previousPage: 'Previous page', nextPage: 'Next page', viewAll: 'View all'
    };
    function lang(key) {
        var L = window.MyThemeTablesLang || {};
        var v = L[key];
        return (v === undefined || v === null || v === '') ? LANG_FALLBACK[key] : v;
    }

    // How long the client-side tables remember sort / page / search / filter (seconds).
    var STATE_DURATION = 60 * 60 * 2;

    // ---------------------------------------------------------------- helpers

    var ESC_MAP = { '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' };
    function esc(s) {
        if (s === null || s === undefined) { return ''; }
        return String(s).replace(/[&<>"']/g, function (c) { return ESC_MAP[c]; });
    }
    function escRegex(s) {
        return String(s).replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
    }
    function debounce(fn, ms) {
        var t;
        return function () {
            var args = arguments, ctx = this;
            clearTimeout(t);
            t = setTimeout(function () { fn.apply(ctx, args); }, ms);
        };
    }

    function ctrl(attr, id) {
        return document.querySelector('[' + attr + '][data-mt-for="' + id + '"]');
    }
    function ctrlAll(attr, id) {
        return document.querySelectorAll('[' + attr + '][data-mt-for="' + id + '"]');
    }

    // Static (non-user) SVG markup, lifted verbatim from the Smarty templates.
    var SVG = {
        dots:   '<svg viewBox="0 0 24 24" fill="currentColor"><circle cx="5" cy="12" r="2"/><circle cx="12" cy="12" r="2"/><circle cx="19" cy="12" r="2"/></svg>',
        eye:    '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/><circle cx="12" cy="12" r="3"/></svg>',
        dl:     '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M21 15v4a2 2 0 01-2 2H5a2 2 0 01-2-2v-4"/><polyline points="7 10 12 15 17 10"/><line x1="12" y1="15" x2="12" y2="3"/></svg>',
        pay:    '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><rect x="2" y="5" width="20" height="14" rx="2"/><path d="M2 10h20"/></svg>',
        check:  '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"/></svg>',
        invDoc: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><rect x="1" y="4" width="22" height="16" rx="2"/><line x1="1" y1="10" x2="23" y2="10"/></svg>',
        qDoc:   '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M14 2H6a2 2 0 00-2 2v16a2 2 0 002 2h12a2 2 0 002-2V8z"/><polyline points="14 2 14 8 20 8"/><line x1="9" y1="13" x2="15" y2="13"/><line x1="9" y1="17" x2="15" y2="17"/></svg>',
        chevL:  '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="15 18 9 12 15 6"/></svg>',
        chevR:  '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="9 18 15 12 9 6"/></svg>',
        pencil: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M12 20h9"/><path d="M16.5 3.5a2.121 2.121 0 013 3L7 19l-4 1 1-4 12.5-12.5z"/></svg>',
        upDown: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><polyline points="17 11 12 6 7 11"/><polyline points="17 18 12 13 7 18"/></svg>',
        plus:   '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>',
        ban:    '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="4.93" y1="4.93" x2="19.07" y2="19.07"/></svg>',
        servers:'<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><rect x="2" y="3" width="20" height="8" rx="1"/><rect x="2" y="13" width="20" height="8" rx="1"/><line x1="6" y1="7" x2="6.01" y2="7"/><line x1="6" y1="17" x2="6.01" y2="17"/></svg>',
        user:   '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M20 21v-2a4 4 0 00-4-4H8a4 4 0 00-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>',
        refresh:'<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M21 2v6h-6"/><path d="M3 12a9 9 0 0115-6.7L21 8"/><path d="M3 22v-6h6"/><path d="M21 12a9 9 0 01-15 6.7L3 16"/></svg>',
        renew:  '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><polyline points="23 4 23 10 17 10"/><polyline points="1 20 1 14 7 14"/><path d="M3.51 9a9 9 0 0114.85-3.36L23 10M1 14l4.64 4.36A9 9 0 0020.49 15"/></svg>',
        clip:   '<svg class="em-clip" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M21.44 11.05l-9.19 9.19a6 6 0 01-8.49-8.49l9.19-9.19a4 4 0 015.66 5.66l-9.2 9.19a2 2 0 01-2.83-2.83l8.49-8.48"/></svg>'
    };

    function pill(status, slug) {
        return '<span class="status-pill ' + esc(slug) + '">' + esc(status) + '</span>';
    }

    /** Build a kebab menu reusing a page's existing menu classes. items: [{href,label,svg}]. */
    function kebab(cls, items) {
        var menu = '';
        for (var i = 0; i < items.length; i++) {
            menu += '<a href="' + esc(items[i].href) + '" class="' + cls.item + '" role="menuitem">'
                  + items[i].svg + esc(items[i].label) + '</a>';
        }
        return '<div class="' + cls.wrap + '" data-mt-kebab>'
             + '<button type="button" class="' + cls.btn + '" aria-label="Actions" aria-haspopup="true" aria-expanded="false" data-mt-kebab-btn>'
             + SVG.dots + '</button>'
             + '<div class="' + cls.menu + '" role="menu">' + menu + '</div></div>';
    }

    function textCell(d) { return esc(d); }

    // ------------------------------------------------------------- type meta

    // Per-type metadata: the status column used for client-side filter tabs, and
    // the column→WHMCS-orderby-key map used to mirror sort state into the URL
    // (?orderby=&sort=) so a refresh keeps the order. Types without an orderKeys
    // map simply skip URL sync (sort still works client-side).
    var TYPE_META = {
        invoices: { filterCol: 4, orderKeys: { 0: 'id', 1: 'date', 2: 'due', 3: 'amount', 4: 'status' } },
        quotes:   { filterCol: 4, orderKeys: { 0: 'id', 1: 'date', 2: 'valid', 3: 'amount', 4: 'status' } },
        tickets:  { filterCol: 2, orderKeys: { 0: 'subject', 1: 'department', 2: 'status', 3: 'updated' }, forceStringSort: true },
        services: { filterCol: 3, orderKeys: null },
        domains:  { filterCol: 3, orderKeys: null },
        emails:   { filterCol: null, orderKeys: null }
    };

    // ---------------------------------------------------------- column defs
    // (server-side mode only — client-side mode reuses the server-rendered DOM)

    var COLUMNS = {
        invoices: [
            { data: 'num', render: function (d) {
                return '<div class="inv-id-cell"><div class="inv-id-ico">' + SVG.invDoc
                     + '</div><span class="inv-id-num">#' + esc(d) + '</span></div>';
            } },
            { data: 'date', className: 'date', render: textCell },
            { data: 'due', className: 'date', render: textCell },
            { data: 'amount', render: textCell, createdCell: function (td, cd, row) {
                td.classList.add('amount');
                if (row.unpaid) { td.classList.add('due'); }
            } },
            { data: 'status', render: function (d, t, row) { return pill(d, row.statusSlug); } },
            { data: null, orderable: false, className: 'actions', render: function (d, t, row) {
                var items = [
                    { href: row.urls.view, label: 'View Invoice', svg: SVG.eye },
                    { href: row.urls.pdf, label: 'Download PDF', svg: SVG.dl }
                ];
                if (row.unpaid) { items.push({ href: row.urls.view, label: 'Pay Invoice', svg: SVG.pay }); }
                return kebab({ wrap: 'inv-menu-wrap', btn: 'inv-menu-btn', menu: 'inv-menu', item: 'inv-menu-item' }, items);
            } }
        ],

        quotes: [
            { data: 'num', render: function (d, t, row) {
                var sub = row.subject ? '<span class="q-id-subject">' + esc(row.subject) + '</span>' : '';
                return '<div class="q-id-cell"><div class="q-id-ico">' + SVG.qDoc
                     + '</div><div class="q-id-meta"><span class="q-id-num">#' + esc(d) + '</span>' + sub + '</div></div>';
            } },
            { data: 'date', className: 'date', render: textCell },
            { data: 'valid', className: 'date', render: textCell },
            { data: 'amount', className: 'amount', render: textCell },
            { data: 'stage', render: function (d, t, row) { return pill(d, row.stageSlug); } },
            { data: null, orderable: false, className: 'actions', render: function (d, t, row) {
                var items = [
                    { href: row.urls.view, label: 'View Quote', svg: SVG.eye },
                    { href: row.urls.pdf, label: 'Download PDF', svg: SVG.dl }
                ];
                if (row.delivered) { items.push({ href: row.urls.view + '&action=accept', label: 'Accept Quote', svg: SVG.check }); }
                return kebab({ wrap: 'q-menu-wrap', btn: 'q-menu-btn', menu: 'q-menu', item: 'q-menu-item' }, items);
            } }
        ],

        tickets: [
            { data: 'subject', render: function (d, t, row) {
                var dot = (row.prio === 'high' || row.prio === 'medium')
                    ? '<span class="tk-prio-dot ' + esc(row.prio) + '"></span>' : '';
                return '<div class="tk-subject-cell"><div class="tk-subject-id">#' + esc(row.tid)
                     + '</div><div class="tk-subject-title">' + dot + esc(d) + '</div></div>';
            } },
            { data: 'department', render: textCell },
            { data: 'status', render: function (d, t, row) { return pill(d, row.statusSlug); } },
            { data: 'lastreply', render: function (d) { return '<div class="tk-updated-date">' + esc(d) + '</div>'; } }
        ],

        services: [
            { data: 'name', render: function (d, t, row) {
                var line = esc(row.group || 'Service') + (row.name ? ' — ' + esc(row.name) : '');
                var dom = row.domain ? esc(row.domain) : '—';
                return '<div class="svc-cell-product-info"><div class="svc-cell-product-name">' + line
                     + '</div><div class="svc-cell-product-domain">' + dom + '</div></div>';
            } },
            { data: 'amount', render: function (d, t, row) {
                var cyc = row.cycle ? '<span class="cycle">/' + esc(row.cycle) + '</span>' : '';
                return '<div class="svc-cell-price-main">' + (d ? esc(d) : '—') + cyc + '</div>';
            } },
            { data: 'due', render: function (d) { return d ? esc(d) : '—'; } },
            { data: 'status', render: function (d, t, row) { return pill(d, row.statusSlug); } },
            { data: null, orderable: false, className: 'svc-cell-actions', render: function (d, t, row) {
                return kebab({ wrap: 'svc-menu-wrap', btn: 'svc-menu-btn', menu: 'svc-menu', item: 'svc-menu-item' }, [
                    { href: row.urls.manage, label: 'Manage Product', svg: SVG.pencil },
                    { href: row.urls.upgrade, label: 'Upgrade / Downgrade', svg: SVG.upDown },
                    { href: row.urls.addons, label: 'View Addons', svg: SVG.plus },
                    { href: row.urls.cancel, label: 'Request Cancellation', svg: SVG.ban }
                ]);
            } }
        ],

        domains: [
            { data: 'domain', render: function (d) { return '<span class="domain-name">' + esc(d) + '</span>'; } },
            { data: 'registered', render: textCell },
            { data: 'expiry', render: textCell },
            { data: 'status', render: function (d, t, row) { return pill(d, row.statusSlug); } },
            { data: 'autorenew', orderable: false, render: function (d) {
                return '<span class="toggle-switch' + (d ? ' active' : '') + '" aria-hidden="true"></span>';
            } },
            { data: null, orderable: false, className: 'dom-cell-actions', render: function (d, t, row) {
                return kebab({ wrap: 'dom-menu-wrap', btn: 'dom-menu-btn', menu: 'dom-menu', item: 'dom-menu-item' }, [
                    { href: row.urls.manage, label: 'Manage Domain', svg: SVG.pencil },
                    { href: row.urls.nameservers, label: 'Manage Nameservers', svg: SVG.servers },
                    { href: row.urls.contacts, label: 'Edit Contact Information', svg: SVG.user },
                    { href: row.urls.autorenew, label: 'Auto Renewal Status', svg: SVG.refresh },
                    { href: row.urls.renew, label: 'Renew', svg: SVG.renew }
                ]);
            } }
        ],

        emails: [
            { data: 'date', className: 'em-date', render: textCell },
            { data: 'subject', render: function (d, t, row) {
                var clip = row.hasAttach ? SVG.clip : '';
                return '<div class="em-subject">' + clip + '<a href="' + esc(row.urls.view) + '">' + esc(d) + '</a></div>';
            } }
        ]
    };

    // ----------------------------------------------------------- pager / info

    function buildPager(el, info) {
        var page = info.page, pages = info.pages, html = '';
        html += '<button type="button" data-page="' + (page - 1) + '"' + (page <= 0 ? ' disabled' : '')
              + ' aria-label="' + esc(lang('previousPage')) + '">' + SVG.chevL + '</button>';
        if (pages > 0) {
            var win = 5,
                start = Math.max(0, page - Math.floor(win / 2)),
                end = Math.min(pages - 1, start + win - 1);
            start = Math.max(0, Math.min(start, end - win + 1));
            for (var p = start; p <= end; p++) {
                html += '<button type="button" data-page="' + p + '"' + (p === page ? ' class="active"' : '') + '>' + (p + 1) + '</button>';
            }
        } else {
            html += '<button type="button" class="active">1</button>';
        }
        html += '<button type="button" data-page="' + (page + 1) + '"' + (page >= pages - 1 ? ' disabled' : '')
              + ' aria-label="' + esc(lang('nextPage')) + '">' + SVG.chevR + '</button>';
        el.innerHTML = html;
    }

    function updateControls(id, dt) {
        var info = dt.page.info();
        var infoEl = ctrl('data-dt-info', id);
        if (infoEl) {
            var from = info.recordsDisplay ? info.start + 1 : 0;
            infoEl.textContent = lang('showing') + ' ' + from + lang('to') + info.end + ' ' + lang('of') + ' ' + info.recordsDisplay;
        }
        var pagerEl = ctrl('data-dt-pager', id);
        if (pagerEl) { buildPager(pagerEl, info); }
    }

    // --------------------------------------------------------------- wiring

    /** Wire the Apple footer/search/filter controls to a DataTable (either mode). */
    function wireControls(id, dt, opts) {
        // Search box
        var search = ctrl('data-mt-search', id);
        if (search) {
            search.addEventListener('input', debounce(function () {
                dt.search(this.value || '').draw();
            }, 300));
        }

        // Filter tabs / pills
        var filters = ctrlAll('data-mt-filter', id);
        Array.prototype.forEach.call(filters, function (btn) {
            btn.addEventListener('click', function (e) {
                e.preventDefault();
                Array.prototype.forEach.call(filters, function (b) { b.classList.toggle('active', b === btn); });
                var value = btn.getAttribute('data-mt-filter') || '';
                if (opts.mode === 'server') {
                    opts.state.filter = value;
                    dt.ajax.reload();
                } else {
                    applyClientFilter(dt, opts.filterCol, value);
                }
            });
        });

        // Page-size select
        var lenSel = ctrl('data-dt-length', id);
        if (lenSel) {
            lenSel.value = String(dt.page.len());
            lenSel.addEventListener('change', function () {
                var n = parseInt(this.value, 10);
                if (n > 0 || n === -1) { dt.page.len(n).draw(); }
            });
        }

        // Pager (delegated; innerHTML is rebuilt every draw)
        var pagerEl = ctrl('data-dt-pager', id);
        if (pagerEl) {
            pagerEl.addEventListener('click', function (e) {
                var b = e.target.closest('button[data-page]');
                if (!b || b.disabled) { return; }
                var p = parseInt(b.getAttribute('data-page'), 10);
                if (!isNaN(p) && p >= 0) { dt.page(p).draw(false); }
            });
        }
    }

    /** Client-side status filter on a column, anchored so "Paid" ≠ "Unpaid". */
    function applyClientFilter(dt, col, value) {
        if (col === null || col === undefined || col < 0) { dt.draw(); return; }
        if (!value || value.toLowerCase() === 'all') {
            dt.column(col).search('').draw();
        } else {
            dt.column(col).search('^\\s*' + escRegex(value) + '\\s*$', true, false).draw();
        }
    }

    /** Add a "View all" (-1) page-size option — client mode only (server mode caps rows). */
    function injectViewAllOption(id) {
        var sel = ctrl('data-dt-length', id);
        if (!sel || sel.querySelector('option[value="-1"]')) { return; }
        var opt = document.createElement('option');
        opt.value = '-1';
        opt.textContent = lang('viewAll');
        sel.appendChild(opt);
    }

    /** Highlight the filter tab matching the table's current column filter (after a state restore). */
    function syncFilterTabs(id, dt, filterCol) {
        if (filterCol === null || filterCol === undefined || filterCol < 0) { return; }
        var current = dt.column(filterCol).search();
        var tabs = ctrlAll('data-mt-filter', id);
        Array.prototype.forEach.call(tabs, function (btn) {
            var v = btn.getAttribute('data-mt-filter') || '';
            var expected = v ? ('^\\s*' + escRegex(v) + '\\s*$') : '';
            btn.classList.toggle('active', expected === current);
        });
    }

    /** Reflect the table's current sort column/direction on the Apple header buttons. */
    function reflectSortHeader(thead, dt) {
        if (!thead) { return; }
        thead.querySelectorAll('[data-sort], .svc-sort, [data-dir]').forEach(function (b) {
            b.setAttribute('data-dir', '');
            b.classList.remove('active');
        });
        var ord = dt.order();
        if (!ord || !ord.length) { return; }
        var th = (thead.rows.length ? thead.rows[0].cells : [])[ord[0][0]];
        if (th) {
            var b = th.querySelector('[data-sort], .svc-sort') || th;
            if (b.setAttribute) { b.setAttribute('data-dir', ord[0][1] || 'asc'); }
            if (b.classList) { b.classList.add('active'); }
        }
    }

    /** Mirror sort state into ?orderby=&sort= and reflect it on the Apple header. */
    function wireSortSync(id, dt, type) {
        var meta = TYPE_META[type] || {};
        var thead = document.getElementById(id);
        thead = thead ? thead.tHead : null;
        dt.on('order.dt', function () {
            reflectSortHeader(thead, dt);
            // URL sync (only for types with a known orderby key map).
            if (meta.orderKeys) {
                var ord = dt.order();
                if (!ord || !ord.length) { return; }
                var key = meta.orderKeys[ord[0][0]];
                if (!key) { return; }
                try {
                    var url = new URL(window.location.href);
                    url.searchParams.set('orderby', key);
                    url.searchParams.set('sort', (ord[0][1] || 'asc').toUpperCase());
                    window.history.replaceState({}, '', url.toString());
                } catch (err) { /* old browsers — ignore */ }
            }
        });
        // Reflect the restored / initial sort on first paint (a stateSave restore
        // fires order.dt during construction, before this listener is attached).
        reflectSortHeader(thead, dt);
    }

    // ------------------------------------------------------- table init (modes)

    function readConfig(tableEl) {
        var orderParts = (tableEl.getAttribute('data-mt-order') || '0:desc').split(':');
        var meta = TYPE_META[tableEl.getAttribute('data-mt-type')] || {};
        var filterCol = tableEl.hasAttribute('data-mt-filter-col')
            ? parseInt(tableEl.getAttribute('data-mt-filter-col'), 10)
            : (meta.filterCol === undefined ? null : meta.filterCol);
        return {
            id:       tableEl.id,
            type:     tableEl.getAttribute('data-mt-type'),
            orderIdx: parseInt(orderParts[0], 10) || 0,
            orderDir: orderParts[1] === 'asc' ? 'asc' : 'desc',
            len:      parseInt(tableEl.getAttribute('data-mt-length'), 10) || 10,
            filterCol: filterCol
        };
    }

    /** Column indices whose header carries data-mt-noorder → not sortable. */
    function noOrderTargets(tableEl) {
        var targets = [];
        var ths = tableEl.tHead ? tableEl.querySelectorAll('thead th') : [];
        Array.prototype.forEach.call(ths, function (th, i) {
            if (th.hasAttribute('data-mt-noorder')) { targets.push(i); }
        });
        return targets;
    }

    function initServerSide(tableEl) {
        var cfg = readConfig(tableEl);
        var cols = COLUMNS[cfg.type];
        if (!cfg.id || !cols) { return; }

        var action = tableEl.getAttribute('data-mt-action');
        var endpoint = tableEl.getAttribute('data-mt-endpoint') || 'clientarea.php';
        var state = { filter: '' };
        var activeFilter = document.querySelector('[data-mt-filter].active[data-mt-for="' + cfg.id + '"]');
        if (activeFilter) { state.filter = activeFilter.getAttribute('data-mt-filter') || ''; }

        var dt = $('#' + cfg.id).DataTable({
            serverSide: true,
            processing: true,
            ordering: true,
            autoWidth: false,
            deferRender: true,
            dom: 'rt',
            pageLength: cfg.len,
            order: [[cfg.orderIdx, cfg.orderDir]],
            ajax: {
                url: endpoint,
                type: 'POST',
                data: function (d) { d.mtAction = action; d.mtFilter = state.filter; }
            },
            columns: cols,
            createdRow: function (row) {
                row.setAttribute('role', 'link');
                row.setAttribute('tabindex', '0');
            },
            // Use this.api() — during the initial (synchronous) client-side draw the
            // outer `dt` var is not yet assigned, so referencing it would throw and
            // leave the info text / pager empty.
            drawCallback: function () { updateControls(cfg.id, this.api()); addExpanders(cfg.id, cfg.type); }
        });

        wireControls(cfg.id, dt, { mode: 'server', state: state, filterCol: cfg.filterCol });
        wireSortSync(cfg.id, dt, cfg.type);
    }

    function initClientSide(tableEl) {
        var cfg = readConfig(tableEl);
        if (!cfg.id) { return; }

        var meta = TYPE_META[cfg.type] || {};
        var columnDefs = [{ orderable: false, targets: noOrderTargets(tableEl) }];
        if (meta.forceStringSort) {
            // Force string sort on every column — auto-detection picks "num"/"date"
            // when a data-order value looks numeric, which breaks alphabetic sort on
            // text columns (e.g. ticket subject). ISO dates still sort chronologically.
            columnDefs.push({ type: 'string', targets: '_all' });
        }

        // Client mode keeps every row in the DOM, so offer a "View all" page size.
        injectViewAllOption(cfg.id);

        var dt = $('#' + cfg.id).DataTable({
            paging: true,
            searching: true,
            info: false,
            ordering: true,
            autoWidth: false,
            dom: 'rt',
            pageLength: cfg.len,
            order: [[cfg.orderIdx, cfg.orderDir]],
            columnDefs: columnDefs,
            // Remember sort / page / search / filter across reloads (client mode only;
            // server mode re-queries each load, and Lagom likewise skips state there).
            stateSave: true,
            stateDuration: STATE_DURATION,
            // Use this.api() — during the initial (synchronous) client-side draw the
            // outer `dt` var is not yet assigned, so referencing it would throw and
            // leave the info text / pager empty.
            drawCallback: function () { updateControls(cfg.id, this.api()); addExpanders(cfg.id, cfg.type); }
        });

        wireControls(cfg.id, dt, { mode: 'client', filterCol: cfg.filterCol });
        wireSortSync(cfg.id, dt, cfg.type);

        // Reconcile the Apple controls with whatever stateSave restored: a restored
        // column filter wins; otherwise honour the server-rendered active tab (the
        // ?status= initial filter) on first paint.
        var restoredFilter = (cfg.filterCol !== null && cfg.filterCol >= 0) ? dt.column(cfg.filterCol).search() : '';
        if (restoredFilter) {
            syncFilterTabs(cfg.id, dt, cfg.filterCol);
        } else {
            var activeFilter = document.querySelector('[data-mt-filter].active[data-mt-for="' + cfg.id + '"]');
            if (activeFilter) {
                var v = activeFilter.getAttribute('data-mt-filter') || '';
                if (v) { applyClientFilter(dt, cfg.filterCol, v); }
            }
        }
        // Restore the search box text to match a stateSave-restored global search.
        var searchInput = ctrl('data-mt-search', cfg.id);
        if (searchInput) { searchInput.value = dt.search() || ''; }
    }

    // ------------------------------------------------- global delegation

    function closeKebabs() {
        document.querySelectorAll('[data-mt-kebab].open').forEach(function (w) {
            w.classList.remove('open');
            var b = w.querySelector('[data-mt-kebab-btn]');
            if (b) { b.setAttribute('aria-expanded', 'false'); }
        });
    }

    function isMobileTable() {
        return !!(window.matchMedia && window.matchMedia('(max-width: 720px)').matches);
    }

    /** Lagom-style expandable rows: add a chevron to each row's first cell (skips the
     *  2-column emails list). Idempotent — safe to call after every DataTables draw. */
    function addExpanders(id, type) {
        if (type === 'emails') { return; }
        document.querySelectorAll('#' + id + ' tbody tr').forEach(function (tr) {
            var first = tr.children[0];
            if (first && !first.querySelector('.mt-expander')) {
                var btn = document.createElement('button');
                btn.type = 'button';
                btn.className = 'mt-expander';
                btn.setAttribute('aria-label', 'Show details');
                btn.innerHTML = SVG.chevR;
                first.appendChild(btn);
            }
        });
    }

    function initDelegation() {
        document.addEventListener('click', function (e) {
            var kebabBtn = e.target.closest('[data-mt-kebab-btn]');
            if (kebabBtn) {
                e.preventDefault();
                e.stopPropagation();
                var wrap = kebabBtn.closest('[data-mt-kebab]');
                var wasOpen = wrap.classList.contains('open');
                closeKebabs();
                if (!wasOpen) {
                    wrap.classList.add('open');
                    kebabBtn.setAttribute('aria-expanded', 'true');
                }
                return;
            }
            // Disclosure chevron (mobile) — expand/collapse the row's details.
            var expander = e.target.closest('.mt-expander');
            if (expander) {
                e.preventDefault();
                e.stopPropagation();
                var exRow = expander.closest('tr');
                if (exRow) { exRow.classList.toggle('mt-expanded'); }
                return;
            }
            // Click inside an open menu (a link) — let it navigate, don't close early.
            if (e.target.closest('[data-mt-kebab]')) { return; }

            // Row tap — navigate on desktop; on mobile expand the card (Lagom-style).
            if (!e.target.closest('a, button, input, select, label')) {
                var tr = e.target.closest('table[data-mt-type] tbody tr[data-href]');
                if (tr) {
                    if (isMobileTable()) { tr.classList.toggle('mt-expanded'); }
                    else { window.location.href = tr.getAttribute('data-href'); }
                    return;
                }
            }
            closeKebabs();
        });

        document.addEventListener('keydown', function (e) {
            if (e.key === 'Escape') { closeKebabs(); return; }
            if (e.key === 'Enter' || e.key === ' ') {
                var tr = e.target.closest ? e.target.closest('table[data-mt-type] tbody tr[data-href]') : null;
                if (tr && e.target === tr) {
                    e.preventDefault();
                    if (isMobileTable()) { tr.classList.toggle('mt-expanded'); }
                    else { window.location.href = tr.getAttribute('data-href'); }
                }
            }
        });
    }

    function injectStyles() {
        if (document.getElementById('mt-dt-styles')) { return; }
        var css = ''
            + '.mt-dt-search{position:relative;display:inline-flex;align-items:center}'
            + '.mt-dt-search input{font:inherit;color:inherit;padding:8px 12px;border:1px solid var(--border,rgba(0,0,0,.12));'
            + 'border-radius:10px;background:var(--surface,#fff);min-width:200px;outline:none}'
            + '.mt-dt-search input:focus{border-color:var(--accent,#0071e3);box-shadow:0 0 0 3px rgba(0,113,227,.15)}'
            + 'table[data-mt-type] tbody tr[data-href]{cursor:pointer}'
            + 'div.dataTables_processing{position:absolute;top:0;right:0;padding:6px 10px;font-size:13px;'
            + 'color:var(--text-secondary,#6e6e73);background:transparent;z-index:2}'
            // Generic footer used by pages that have no bespoke pager (e.g. emails).
            // Scoped to .mt-dt-foot so the styled inv-/q-/tk-/svc- pagers are untouched.
            + '.mt-dt-foot{display:flex;align-items:center;gap:12px;margin-top:14px;flex-wrap:wrap;'
            + 'font-size:13px;color:var(--text-secondary,#6e6e73)}'
            + '.mt-dt-foot .spacer{flex:1}'
            + '.mt-dt-foot [data-dt-pager]{display:inline-flex;gap:6px}'
            + '.mt-dt-foot [data-dt-pager] button{min-width:32px;height:32px;padding:0 8px;'
            + 'border:1px solid var(--border,rgba(0,0,0,.12));border-radius:8px;background:var(--surface,#fff);'
            + 'color:inherit;cursor:pointer;display:inline-flex;align-items:center;justify-content:center}'
            + '.mt-dt-foot [data-dt-pager] button.active{background:var(--accent,#0071e3);color:#fff;border-color:transparent}'
            + '.mt-dt-foot [data-dt-pager] button:disabled{opacity:.4;cursor:default}'
            + '.mt-dt-foot [data-dt-pager] svg{width:16px;height:16px}'
            // Domains table reuses the existing .domain-row / .dom-list-head-row
            // CSS grid; reset the <table> to block so those grid rules drive layout.
            + '.dom-table,.dom-table thead,.dom-table tbody{display:block}'
            + '.dom-table{width:100%}'
            + '.dom-table thead tr,.dom-table tbody tr{box-sizing:border-box}'
            + '.dom-table th{font:inherit;text-align:left}'
            // --- Mobile (<=720px) shared fixes for every list table ---
            // 1) Kebab menus: anchor to the card's right edge so they never run off
            //    the left of the screen once a row collapses to a single column.
            // Lagom-style disclosure chevron — sits top-right of each row; hidden on
            // desktop, shown on mobile where it toggles .mt-expanded.
            + '.mt-expander{display:none;position:absolute;top:10px;right:10px;width:30px;height:30px;align-items:center;justify-content:center;border:0;border-radius:50%;background:transparent;color:var(--color-text-tertiary,#86868b);cursor:pointer;padding:0;z-index:3}'
            + '.mt-expander:hover{background:var(--color-surface-secondary,rgba(0,0,0,.05))}'
            + '.mt-expander svg{width:18px;height:18px;transition:transform .2s ease}'
            // !important because on the live WHMCS page the per-page CSS <link> sits in
            // the body, so it loads AFTER this injected <style> and wins specificity ties
            // (e.g. `.svc-main .filter-tabs{flex-wrap:nowrap}`). !important keeps these
            // mobile overrides winning regardless of stylesheet order.
            + '@media (max-width:720px){'
            +   'table[data-mt-type] tbody tr{position:relative !important}'
            +   'tbody [data-mt-kebab],tbody td:has([data-mt-kebab]){position:static !important}'
            +   '[data-mt-kebab] [role="menu"]{right:12px !important;left:auto !important;min-width:0 !important;width:max-content;max-width:calc(100vw - 40px)}'
            // 2) Search box: drop it to its own full-width row below the filter chips,
            //    instead of stranding it off the end of the scrolling chip row.
            +   '.filter-tabs:has([data-mt-search]){flex-wrap:wrap !important;row-gap:8px}'
            +   '.filter-tabs>:has(>[data-mt-search]){flex:1 0 100% !important;max-width:none !important;margin-left:0 !important;order:2}'
            // 3) Expandable rows: collapse each row to its first cell (identity) + the
            //    chevron; .mt-expanded reveals the rest (the existing card layout).
            +   '.mt-expander{display:inline-flex !important}'
            +   'table[data-mt-type] tbody tr:not(.mt-expanded):has(.mt-expander)>td:not(:first-child){display:none !important}'
            +   'table[data-mt-type] tbody tr:has(.mt-expander)>td:first-child{padding-right:46px !important}'
            +   'table[data-mt-type] tbody tr.mt-expanded .mt-expander svg{transform:rotate(90deg)}'
            + '}';
        var s = document.createElement('style');
        s.id = 'mt-dt-styles';
        s.textContent = css;
        document.head.appendChild(s);
    }

    // ------------------------------------------------------------- bootstrap

    function init() {
        var tables = document.querySelectorAll('table[data-mt-type]');
        if (!tables.length) { return; }
        injectStyles();
        initDelegation();
        Array.prototype.forEach.call(tables, function (t) {
            try {
                if (t.hasAttribute('data-mt-action')) { initServerSide(t); }
                else { initClientSide(t); }
            } catch (err) {
                if (window.console) { console.error('MyTheme table init failed', err); }
            }
        });
    }

    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', init);
    } else {
        init();
    }

    // Expose the registry so later phases / overrides can add table types.
    window.MyThemeTables = { columns: COLUMNS, meta: TYPE_META, esc: esc, pill: pill, kebab: kebab, SVG: SVG };
})();
