/* MyTheme — Dynamic AJAX Loading for Data Tables.
 *
 * Server-side DataTables for the client-area list pages. When the admin enables
 * "Enable Dynamic AJAX Loading", each list template renders a table skeleton with
 *   <table id="..." data-mt-action="tableInvoices" data-mt-type="invoices"
 *          data-mt-endpoint="/clientarea.php" data-mt-order="0:desc" data-mt-length="10">
 * plus controls tagged data-mt-for="<tableId>". This script:
 *   - inits DataTables in serverSide mode (paging/search/sort done at the DB),
 *   - POSTs mtAction + DataTables params to the endpoint (hooks.php dispatch),
 *   - rebuilds the Apple row markup from the JSON via per-type render functions,
 *   - drives the existing Apple search box / pager / info text and the row-click
 *     navigation + kebab menus through event delegation.
 *
 * Row markup here mirrors the Smarty {foreach} fallback in each template. All
 * dynamic values pass through esc() before hitting innerHTML.
 *
 * Loaded only when the feature is on. Requires jQuery + DataTables (loaded by the
 * list template). If either is missing it no-ops.
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

    // ---------------------------------------------------------------- helpers

    var ESC_MAP = { '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' };
    function esc(s) {
        if (s === null || s === undefined) { return ''; }
        return String(s).replace(/[&<>"']/g, function (c) { return ESC_MAP[c]; });
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

    // ---------------------------------------------------------- column defs

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
              + ' aria-label="Previous page">' + SVG.chevL + '</button>';
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
              + ' aria-label="Next page">' + SVG.chevR + '</button>';
        el.innerHTML = html;
    }

    function updateControls(id, dt) {
        var info = dt.page.info();
        var infoEl = ctrl('data-dt-info', id);
        if (infoEl) {
            var from = info.recordsDisplay ? info.start + 1 : 0;
            infoEl.textContent = 'Showing ' + from + '–' + info.end + ' of ' + info.recordsDisplay;
        }
        var pagerEl = ctrl('data-dt-pager', id);
        if (pagerEl) { buildPager(pagerEl, info); }
    }

    // --------------------------------------------------------------- wiring

    function wireControls(id, dt, state) {
        // Search
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
                state.filter = btn.getAttribute('data-mt-filter') || '';
                dt.ajax.reload();
            });
        });

        // Page-size select
        var lenSel = ctrl('data-dt-length', id);
        if (lenSel) {
            lenSel.value = String(dt.page.len());
            lenSel.addEventListener('change', function () {
                var n = parseInt(this.value, 10);
                if (n > 0) { dt.page.len(n).draw(); }
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

    function buildTable(tableEl) {
        var id = tableEl.id;
        var type = tableEl.getAttribute('data-mt-type');
        var cols = COLUMNS[type];
        if (!id || !cols) { return; }

        var orderParts = (tableEl.getAttribute('data-mt-order') || '0:desc').split(':');
        var orderIdx = parseInt(orderParts[0], 10) || 0;
        var orderDir = orderParts[1] === 'asc' ? 'asc' : 'desc';
        var len = parseInt(tableEl.getAttribute('data-mt-length'), 10) || 10;
        var action = tableEl.getAttribute('data-mt-action');
        var endpoint = tableEl.getAttribute('data-mt-endpoint') || 'clientarea.php';

        var state = { filter: '' };
        var activeFilter = document.querySelector('[data-mt-filter].active[data-mt-for="' + id + '"]');
        if (activeFilter) { state.filter = activeFilter.getAttribute('data-mt-filter') || ''; }

        var dt = $('#' + id).DataTable({
            serverSide: true,
            processing: true,
            ordering: true,
            autoWidth: false,
            deferRender: true,
            dom: 'rt',
            pageLength: len,
            order: [[orderIdx, orderDir]],
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
            drawCallback: function () { updateControls(id, dt); }
        });

        wireControls(id, dt, state);
    }

    // ------------------------------------------------- global delegation

    function closeKebabs() {
        document.querySelectorAll('[data-mt-kebab].open').forEach(function (w) {
            w.classList.remove('open');
            var b = w.querySelector('[data-mt-kebab-btn]');
            if (b) { b.setAttribute('aria-expanded', 'false'); }
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
            // Click inside an open menu (a link) — let it navigate, don't close early.
            if (e.target.closest('[data-mt-kebab]')) { return; }

            // Row navigation — only for our AJAX tables, and not when clicking a control.
            if (!e.target.closest('a, button, input, select, label')) {
                var tr = e.target.closest('table[data-mt-action] tbody tr[data-href]');
                if (tr) {
                    window.location.href = tr.getAttribute('data-href');
                    return;
                }
            }
            closeKebabs();
        });

        document.addEventListener('keydown', function (e) {
            if (e.key === 'Escape') { closeKebabs(); return; }
            if (e.key === 'Enter' || e.key === ' ') {
                var tr = e.target.closest ? e.target.closest('table[data-mt-action] tbody tr[data-href]') : null;
                if (tr && e.target === tr) {
                    e.preventDefault();
                    window.location.href = tr.getAttribute('data-href');
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
            + 'table[data-mt-action] tbody tr[data-href]{cursor:pointer}'
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
            // Domains AJAX table reuses the existing .domain-row / .dom-list-head-row
            // CSS grid; reset the <table> to block so those grid rules drive layout.
            + '.dom-table,.dom-table thead,.dom-table tbody{display:block}'
            + '.dom-table{width:100%}'
            + '.dom-table thead tr,.dom-table tbody tr{box-sizing:border-box}'
            + '.dom-table th{font:inherit;text-align:left}';
        var s = document.createElement('style');
        s.id = 'mt-dt-styles';
        s.textContent = css;
        document.head.appendChild(s);
    }

    // ------------------------------------------------------------- bootstrap

    function init() {
        var tables = document.querySelectorAll('table[data-mt-action][data-mt-type]');
        if (!tables.length) { return; }
        injectStyles();
        initDelegation();
        Array.prototype.forEach.call(tables, function (t) {
            try { buildTable(t); } catch (err) { if (window.console) { console.error('MyTheme table init failed', err); } }
        });
    }

    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', init);
    } else {
        init();
    }

    // Expose the registry so later phases / overrides can add table types.
    window.MyThemeTables = { columns: COLUMNS, esc: esc, pill: pill, kebab: kebab, SVG: SVG };
})();
