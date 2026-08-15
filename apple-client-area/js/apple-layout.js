/* ============================================================
   apple-layout.js — Shared layout system for every page
   ------------------------------------------------------------
   Pairs with css/apple-layout.css and ./partials/. Handles:
     · Partial loader for <div data-include="partials/x.html">
     · State chip (drag, auth/layout/palette toggles)
     · Notification + profile dropdowns (nav + inner-topbar)
     · Sidebar collapsible groups
     · Rail hover/click interactions
     · Locale (language + currency) modal
     · Active nav highlight from body[data-active-nav]

   Storage keys are namespaced `hn.*` so they persist across all
   pages in the theme (not just portal-home).
   ============================================================ */

(function () {
    'use strict';

    // ── Storage keys ───────────────────────────────────────
    var KEYS = {
        auth:          'hn.auth',
        layout:        'hn.layout',
        sidebar:       'hn.sidebar',
        icons:         'hn.icons',
        palette:       'hn.palette',
        data:          'hn.data',
        align:         'hn.align',
        subnav:        'hn.subnav',
        subnavSide:    'hn.subnavSide',
        tiles:         'hn.tiles',
        form:          'hn.form',
        product:       'hn.product',
        plan:          'hn.plan',
        packages:      'hn.packages',
        crumbs:        'hn.crumbs',
        svcLayout:     'hn.svcLayout',
        chipPos:       'hn.chipPos',
        sidebarGroups: 'hn.sidebarGroups'
    };

    // ── Legacy key migration (portal-home prototype) ───────
    // Pull prior selections from the old page-scoped keys if
    // present so returning users don't lose state.
    var LEGACY = {
        portalHomeAuthState:       'hn.auth',
        portalHomeLayoutState:     'hn.layout',
        portalHomePalette:         'hn.palette',
        portalHomeChipPos:         'hn.chipPos',
        portalHomeSidebarGroups:   'hn.sidebarGroups'
    };
    try {
        Object.keys(LEGACY).forEach(function (old) {
            var v = localStorage.getItem(old);
            if (v !== null && localStorage.getItem(LEGACY[old]) === null) {
                localStorage.setItem(LEGACY[old], v);
            }
        });
    } catch (e) {}

    // ── Partial loader ─────────────────────────────────────
    // Find every <X data-include="path"> and replace its inner
    // HTML with the contents of that file. Resolves once every
    // include finishes; dispatches `partials:loaded` on document.
    function loadPartials() {
        var nodes = Array.prototype.slice.call(document.querySelectorAll('[data-include]'));
        if (!nodes.length) return Promise.resolve();
        var jobs = nodes.map(function (node) {
            var path = node.getAttribute('data-include');
            return fetch(path, { cache: 'no-cache' })
                .then(function (r) { return r.ok ? r.text() : ''; })
                .then(function (html) {
                    node.innerHTML = html;
                    node.setAttribute('data-loaded', '');
                })
                .catch(function () {
                    node.setAttribute('data-loaded', 'error');
                });
        });
        return Promise.all(jobs);
    }

    // ── State-chip drag ────────────────────────────────────
    function initChipDrag(chip) {
        var grip = chip.querySelector('.dev-tag');
        if (!grip) return;

        function detach() {
            if (chip.classList.contains('dragged')) return;
            var rect = chip.getBoundingClientRect();
            chip.style.left = rect.left + 'px';
            chip.style.top = rect.top + 'px';
            chip.style.right = 'auto';
            chip.classList.add('dragged');
        }
        function clamp(nextLeft, nextTop) {
            var vw = window.innerWidth, vh = window.innerHeight;
            var r = chip.getBoundingClientRect();
            return {
                left: Math.max(8, Math.min(nextLeft, vw - r.width - 8)),
                top:  Math.max(8, Math.min(nextTop,  vh - r.height - 8))
            };
        }
        function savePos() {
            try {
                localStorage.setItem(KEYS.chipPos, JSON.stringify({
                    left: chip.style.left, top: chip.style.top
                }));
            } catch (e) {}
        }
        function resetPos() {
            chip.classList.remove('dragged');
            chip.style.cssText = '';
            try { localStorage.removeItem(KEYS.chipPos); } catch (e) {}
        }

        // Restore saved position
        try {
            var saved = localStorage.getItem(KEYS.chipPos);
            if (saved) {
                var p = JSON.parse(saved);
                chip.classList.add('dragged');
                chip.style.left = p.left;
                chip.style.top = p.top;
                chip.style.right = 'auto';
            }
        } catch (e) {}

        grip.addEventListener('mousedown', function (e) {
            e.preventDefault();
            detach();
            var startX = e.clientX, startY = e.clientY;
            var startTop = parseFloat(chip.style.top) || 0;
            var startLeft = parseFloat(chip.style.left) || 0;
            function onMove(ev) {
                var pos = clamp(startLeft + (ev.clientX - startX), startTop + (ev.clientY - startY));
                chip.style.left = pos.left + 'px';
                chip.style.top = pos.top + 'px';
            }
            function onUp() {
                document.removeEventListener('mousemove', onMove);
                document.removeEventListener('mouseup', onUp);
                savePos();
            }
            document.addEventListener('mousemove', onMove);
            document.addEventListener('mouseup', onUp);
        });

        grip.addEventListener('touchstart', function (e) {
            if (e.touches.length !== 1) return;
            detach();
            var t0 = e.touches[0];
            var startX = t0.clientX, startY = t0.clientY;
            var startTop = parseFloat(chip.style.top) || 0;
            var startLeft = parseFloat(chip.style.left) || 0;
            function onMove(ev) {
                if (ev.touches.length !== 1) return;
                var t = ev.touches[0];
                var pos = clamp(startLeft + (t.clientX - startX), startTop + (t.clientY - startY));
                chip.style.left = pos.left + 'px';
                chip.style.top = pos.top + 'px';
                ev.preventDefault();
            }
            function onEnd() {
                document.removeEventListener('touchmove', onMove);
                document.removeEventListener('touchend', onEnd);
                savePos();
            }
            document.addEventListener('touchmove', onMove, { passive: false });
            document.addEventListener('touchend', onEnd);
        }, { passive: true });

        grip.addEventListener('dblclick', resetPos);
    }

    // ── Auth / Layout / Palette toggles ────────────────────
    function initStateToggles(params) {
        var body = document.body;

        // Auth
        var authButtons = document.querySelectorAll('.state-chip [data-auth-set]');
        function applyAuth(state) {
            if (state !== 'in' && state !== 'out') state = 'in';
            body.dataset.auth = state;
            authButtons.forEach(function (b) {
                b.classList.toggle('active', b.dataset.authSet === state);
            });
            try { localStorage.setItem(KEYS.auth, state); } catch (e) {}
        }
        var savedAuth; try { savedAuth = localStorage.getItem(KEYS.auth); } catch (e) {}
        // Respect `data-auth` if the page already declared one (letting a page
        // force a specific auth state without reading from storage).
        applyAuth(params.get('state') || body.dataset.auth || savedAuth || 'in');
        authButtons.forEach(function (btn) {
            btn.addEventListener('click', function () { applyAuth(this.dataset.authSet); });
        });

        // Layout
        var layoutButtons = document.querySelectorAll('.state-chip [data-layout-set]');
        function applyLayout(layout) {
            if (['top', 'side', 'rail'].indexOf(layout) === -1) layout = 'top';
            body.dataset.layout = layout;
            layoutButtons.forEach(function (b) {
                b.classList.toggle('active', b.dataset.layoutSet === layout);
            });
            body.classList.remove('rail-panel-open');
            try { localStorage.setItem(KEYS.layout, layout); } catch (e) {}
        }
        var savedLayout; try { savedLayout = localStorage.getItem(KEYS.layout); } catch (e) {}
        applyLayout(params.get('layout') || savedLayout || body.dataset.layout || 'top');
        layoutButtons.forEach(function (btn) {
            btn.addEventListener('click', function () { applyLayout(this.dataset.layoutSet); });
        });

        // Sidebar tone (light / dark / tinted — retones the side menu only)
        var sidebarButtons = document.querySelectorAll('.state-chip [data-sidebar-set]');
        function applySidebar(tone) {
            if (['light', 'dark', 'tinted', 'graphite', 'brand', 'gradient'].indexOf(tone) === -1) tone = 'light';
            if (tone === 'light') {
                body.removeAttribute('data-sidebar');
            } else {
                body.setAttribute('data-sidebar', tone);
            }
            sidebarButtons.forEach(function (b) {
                b.classList.toggle('active', b.dataset.sidebarSet === tone);
            });
            try { localStorage.setItem(KEYS.sidebar, tone); } catch (e) {}
        }
        var savedSidebar; try { savedSidebar = localStorage.getItem(KEYS.sidebar); } catch (e) {}
        applySidebar(params.get('sidebar') || savedSidebar || 'light');
        sidebarButtons.forEach(function (btn) {
            btn.addEventListener('click', function () { applySidebar(this.dataset.sidebarSet); });
        });

        // Icon style (colorful / mono — colored tiles vs uniform muted glyphs,
        // applies to both the sidebar and the icon rail)
        var iconButtons = document.querySelectorAll('.state-chip [data-icons-set]');
        function applyIcons(mode) {
            if (mode !== 'mono' && mode !== 'colorful') mode = 'colorful';
            if (mode === 'colorful') {
                body.removeAttribute('data-icons');
            } else {
                body.setAttribute('data-icons', mode);
            }
            iconButtons.forEach(function (b) {
                b.classList.toggle('active', b.dataset.iconsSet === mode);
            });
            try { localStorage.setItem(KEYS.icons, mode); } catch (e) {}
        }
        var savedIcons; try { savedIcons = localStorage.getItem(KEYS.icons); } catch (e) {}
        applyIcons(params.get('icons') || savedIcons || 'colorful');
        iconButtons.forEach(function (btn) {
            btn.addEventListener('click', function () { applyIcons(this.dataset.iconsSet); });
        });

        // Align (center / left — preview toggle for content horizontal alignment)
        var alignButtons = document.querySelectorAll('.state-chip [data-align-set]');
        function applyAlign(state) {
            if (['left', 'center', 'content'].indexOf(state) === -1) state = 'center';
            if (state === 'center') {
                body.removeAttribute('data-align');
            } else {
                body.setAttribute('data-align', state);
            }
            alignButtons.forEach(function (b) {
                b.classList.toggle('active', b.dataset.alignSet === state);
            });
            try { localStorage.setItem(KEYS.align, state); } catch (e) {}
        }
        var savedAlign; try { savedAlign = localStorage.getItem(KEYS.align); } catch (e) {}
        applyAlign(params.get('align') || savedAlign || 'center');
        alignButtons.forEach(function (btn) {
            btn.addEventListener('click', function () { applyAlign(this.dataset.alignSet); });
        });

        // Sub-nav (show / hide — preview toggle for in-page content sidebar)
        var subnavButtons = document.querySelectorAll('.state-chip [data-subnav-set]');
        function applySubnav(state) {
            if (state !== 'off' && state !== 'on') state = 'on';
            if (state === 'on') {
                body.removeAttribute('data-subnav');
            } else {
                body.setAttribute('data-subnav', 'off');
            }
            subnavButtons.forEach(function (b) {
                b.classList.toggle('active', b.dataset.subnavSet === state);
            });
            try { localStorage.setItem(KEYS.subnav, state); } catch (e) {}
        }
        var savedSubnav; try { savedSubnav = localStorage.getItem(KEYS.subnav); } catch (e) {}
        applySubnav(params.get('subnav') || savedSubnav || body.dataset.subnav || 'on');
        subnavButtons.forEach(function (btn) {
            btn.addEventListener('click', function () { applySubnav(this.dataset.subnavSet); });
        });
        // Sub-nav side (left / right — which side the content sidebar sits on)
        var subnavSideButtons = document.querySelectorAll('.state-chip [data-subnav-side-set]');
        function applySubnavSide(side) {
            if (['left', 'right', 'outside', 'outside-left'].indexOf(side) === -1) side = 'right';
            body.setAttribute('data-subnav-side', side);
            subnavSideButtons.forEach(function (b) {
                b.classList.toggle('active', b.dataset.subnavSideSet === side);
            });
            try { localStorage.setItem(KEYS.subnavSide, side); } catch (e) {}
        }
        var savedSubnavSide; try { savedSubnavSide = localStorage.getItem(KEYS.subnavSide); } catch (e) {}
        applySubnavSide(params.get('subnavSide') || savedSubnavSide || 'right');
        subnavSideButtons.forEach(function (btn) {
            btn.addEventListener('click', function () { applySubnavSide(this.dataset.subnavSideSet); });
        });

        // Hide the Sub-nav + Sub-nav side chips on pages that have no content sidebar.
        // Any "*-split > aside" pattern counts (.dom-split, .svc-split, etc.).
        if (!document.querySelector('.dom-split > aside, .svc-split > aside, [class*="-split"] > aside')) {
            var subnavGroup = subnavButtons[0] && subnavButtons[0].closest('.chip-group');
            if (subnavGroup) subnavGroup.style.display = 'none';
            var subnavSideGroup = subnavSideButtons[0] && subnavSideButtons[0].closest('.chip-group');
            if (subnavSideGroup) subnavSideGroup.style.display = 'none';
        }

        // Services layout (inside / outside — whether search + pagination live inside
        // the table card or float on the page surface above/below it).
        var svcLayoutButtons = document.querySelectorAll('.state-chip [data-svc-layout-set]');
        function applySvcLayout(state) {
            if (state !== 'inside' && state !== 'outside') state = 'inside';
            if (state === 'inside') {
                body.removeAttribute('data-svc-layout');
            } else {
                body.setAttribute('data-svc-layout', 'outside');
            }
            svcLayoutButtons.forEach(function (b) {
                b.classList.toggle('active', b.dataset.svcLayoutSet === state);
            });
            try { localStorage.setItem(KEYS.svcLayout, state); } catch (e) {}
        }
        var savedSvcLayout; try { savedSvcLayout = localStorage.getItem(KEYS.svcLayout); } catch (e) {}
        applySvcLayout(params.get('svcLayout') || savedSvcLayout || 'inside');
        svcLayoutButtons.forEach(function (btn) {
            btn.addEventListener('click', function () { applySvcLayout(this.dataset.svcLayoutSet); });
        });

        // Hide the Services (inside/outside) chip on pages where the toggle does
        // nothing. It now responds wherever there's a content card, a settings-group,
        // or a known bespoke surface wrapper (see apple-layout.css svc-layout rules) --
        // so show it on any such page, not just the legacy table-card/.pd3-stack pages.
        if (!document.querySelector('.content-area .card:not(.subnav-card), .content-area .settings-group, .content-area .bdm-group, .content-area .email-card, .content-area .ds-suggested-list, .content-area .hp-feature-card, .svc-table-card, .dom-list-card, .inv-table-card, .tk-table-card, .pd3-stack')) {
            var svcLayoutGroup = svcLayoutButtons[0] && svcLayoutButtons[0].closest('.chip-group');
            if (svcLayoutGroup) svcLayoutGroup.style.display = 'none';
        }

        // Data (full / empty — preview toggle for empty-state variants)
        var dataButtons = document.querySelectorAll('.state-chip [data-data-set]');
        function applyData(state) {
            if (state !== 'empty' && state !== 'full') state = 'full';
            if (state === 'full') {
                body.removeAttribute('data-data');
            } else {
                body.setAttribute('data-data', 'empty');
            }
            dataButtons.forEach(function (b) {
                b.classList.toggle('active', b.dataset.dataSet === state);
            });
            try { localStorage.setItem(KEYS.data, state); } catch (e) {}
        }
        var savedData; try { savedData = localStorage.getItem(KEYS.data); } catch (e) {}
        // Page reality wins over saved chip preference (URL param > body > localStorage)
        var existingData = body.hasAttribute('data-data') ? body.dataset.data : null;
        applyData(params.get('data') || existingData || savedData || 'full');
        dataButtons.forEach(function (btn) {
            btn.addEventListener('click', function () { applyData(this.dataset.dataSet); });
        });

        // Hide variant-picker groups on pages that have nothing to switch.
        // Each picker's parent .chip-group collapses if no matching .*-variant nodes exist.
        [
            { selector: '.tile-variant', pickerAttr: '[data-tiles-set]' },
            { selector: '.form-variant', pickerAttr: '[data-form-set]' },
            { selector: '.product-variant', pickerAttr: '[data-product-set]' },
            { selector: '.plan-variant', pickerAttr: '[data-plan-set]' },
            { selector: '.plan-variant', pickerAttr: '[data-packages-set]' }
        ].forEach(function (cfg) {
            if (document.querySelector(cfg.selector)) return;
            var btn = document.querySelector('.state-chip ' + cfg.pickerAttr);
            var group = btn && btn.closest('.chip-group');
            if (group) group.style.display = 'none';
        });

        // ── Brand logo ─────────────────────────────────────────
        // Swap the "Hostnodes" text wordmark for the real Hadrian logo wherever
        // a brand appears. Done here rather than in ~150 page files so every
        // mockup picks it up from one place, and so the partials (sidebar, rail)
        // are already in the DOM by the time it runs.
        (function () {
            var SRC = 'img/branding/hadrian-logo.png';
            function mark() {
                var el = document.createElement('img');
                el.className = 'brand-logo';
                el.src = SRC;
                el.alt = 'Hadrian';
                return el;
            }
            function swap(el, keepClass) {
                if (!el || el.querySelector('.brand-logo')) return;
                el.textContent = '';
                /* the deployed theme marks an image brand as .img-logo (which
                   drops the text logo's padding), so mirror that here */
                if (!keepClass) { el.classList.remove('text-logo'); el.classList.add('img-logo'); }
                el.appendChild(mark());
            }
            [].slice.call(document.querySelectorAll('.nav-logo.text-logo')).forEach(function (a) { swap(a); });
            swap(document.querySelector('.sidebar-brand'), true);
            // the rail carries the mark only; CSS crops the wordmark away
            var rail = document.querySelector('.ph-rail-logo');
            if (rail && !rail.querySelector('.brand-logo')) { rail.innerHTML = ''; rail.appendChild(mark()); }
        })();

        // ── Top-bar utility links ──────────────────────────────
        // The quiet resource links live in the TOP BAR (the thin auth strip
        // above the header), right-aligned beside "Return to admin" - not in
        // the header itself, which belongs to the product nav. Built here so
        // every page carries them without touching ~150 files.
        (function () {
            var strip = document.querySelector('.ph-auth-strip-inner');
            if (!strip || strip.querySelector('.nav-utility')) return;
            var LINKS = [
                ['knowledgebase.html', 'Docs'],
                ['serverstatus.html', 'Status'],
                ['contact.html', 'Support']
            ];
            var wrap = document.createElement('div');
            wrap.className = 'nav-utility';
            LINKS.forEach(function (l) {
                var a = document.createElement('a');
                a.href = l[0]; a.textContent = l[1];
                wrap.appendChild(a);
            });
            /* sit just before the right-hand cluster that holds the masq chip */
            var right = strip.lastElementChild;
            if (right && right !== strip.firstElementChild) { strip.insertBefore(wrap, right); }
            else { strip.appendChild(wrap); }
        })();

        // ── Top-nav menu group ─────────────────────────────────
        // The nav items sit as flat siblings between the brand and the spacer,
        // so there is nothing to center as a unit. Wrap them once here; the
        // wrapper is display:contents by default, which leaves the flex layout
        // byte-identical until the Menu chip switches it to centered.
        (function () {
            var inner = document.querySelector('.homepage-nav-inner');
            if (!inner || inner.querySelector('.nav-menu-group')) return;
            var spacer = inner.querySelector('.nav-spacer');
            if (!spacer) return;
            var items = [], n = spacer.previousElementSibling;
            while (n && !n.classList.contains('nav-logo')) { items.unshift(n); n = n.previousElementSibling; }
            if (!items.length) return;
            var group = document.createElement('div');
            group.className = 'nav-menu-group';
            spacer.parentNode.insertBefore(group, spacer);
            items.forEach(function (el) { group.appendChild(el); });
        })();

        // Everything after the spacer (utility links + icon cluster) becomes
        // the right zone. With the brand as the left zone and both set to
        // flex:1, the menu group centers exactly in the bar while staying IN
        // FLOW - absolute centering collided with the utility links once the
        // 1024px bar got busy.
        (function () {
            var inner = document.querySelector('.homepage-nav-inner');
            if (!inner || inner.querySelector('.nav-right')) return;
            var spacer = inner.querySelector('.nav-spacer');
            if (!spacer) return;
            var right = document.createElement('div');
            right.className = 'nav-right';
            inner.appendChild(right);
            var n = spacer.nextElementSibling;
            while (n && n !== right) { var next = n.nextElementSibling; right.appendChild(n); n = next; }
        })();

        // ── Simple body-attribute toggles ──────────────────────
        // Chip groups whose whole job is to flip one attribute on <body>; the
        // CSS does the rest. Wiring them here is what makes them clickable --
        // without it the buttons render but nothing listens, which reads as a
        // broken control. Each entry:
        //   set   - the data-*-set attribute on the buttons
        //   attr  - the body attribute its CSS keys off
        //   def   - fallback when the page sets no default and nothing is saved
        //   key   - localStorage key, or null for page-scoped (not persisted)
        //   needs - selector the page must contain, else the group is hidden
        [
            { set: 'header',      attr: 'data-header',       def: 'light',   key: 'hn.header' },
            { set: 'menu',        attr: 'data-menu',         def: 'left',    key: 'hn.menu',     needs: '.homepage-nav' },
            { set: 'toplinks',    attr: 'data-toplinks',     def: 'show',    key: 'hn.topLinks', needs: '.homepage-nav' },
            { set: 'mintitle',    attr: 'data-min-title',    def: 'outside', key: 'hn.minTitle', needs: '.min-section' },
            { set: 'sidebarlogo', attr: 'data-sidebar-logo', def: 'show',    key: 'hn.sidebarLogo' },
            { set: 'boxsidebar',  attr: 'data-box-sidebar',  def: 'show',    key: null },
            { set: 'boxframe',    attr: 'data-box-frame',    def: 'card',    key: null },
            { set: 'status',      attr: 'data-status',       def: 'active',  key: 'hn.status' }
        ].forEach(function (cfg) {
            var buttons = document.querySelectorAll('.state-chip [data-' + cfg.set + '-set]');
            if (!buttons.length) return;
            var group = buttons[0].closest('.chip-group');
            // nothing on this page responds to it, so don't offer a dead control
            if (cfg.needs && !document.querySelector(cfg.needs)) {
                if (group) group.style.display = 'none';
                return;
            }
            var valid = [];
            buttons.forEach(function (b) { valid.push(b.getAttribute('data-' + cfg.set + '-set')); });
            function apply(v) {
                if (valid.indexOf(v) === -1) v = cfg.def;
                // always written, never removed: some CSS matches the default
                // value explicitly (body[data-status="active"]), so dropping the
                // attribute on the default would silently unstyle the page
                body.setAttribute(cfg.attr, v);
                buttons.forEach(function (b) {
                    b.classList.toggle('active', b.getAttribute('data-' + cfg.set + '-set') === v);
                });
                if (cfg.key) { try { localStorage.setItem(cfg.key, v); } catch (e) {} }
            }
            // the page's own attribute wins over the shared default, so a page
            // can ship its own starting state (box sidebar, service status)
            var saved = null;
            if (cfg.key) { try { saved = localStorage.getItem(cfg.key); } catch (e) {} }
            apply(params.get(cfg.set) || saved || body.getAttribute(cfg.attr) || cfg.def);
            buttons.forEach(function (b) {
                b.addEventListener('click', function () { apply(this.getAttribute('data-' + cfg.set + '-set')); });
            });
        });

        // Retired controls: these two shipped in the chip partial but never had
        // any CSS or JS behind them on any page, so they were permanently dead
        // buttons. Hide them rather than leave something unclickable on show.
        ['[data-blkstyle-set]', '[data-layoutmap-set]'].forEach(function (sel) {
            var btn = document.querySelector('.state-chip ' + sel);
            var group = btn && btn.closest('.chip-group');
            if (group) group.style.display = 'none';
        });

        // Tiles (A/B/C/D/E/F or All — pages with tile-variant blocks show only the chosen one)
        var tilesButtons = document.querySelectorAll('.state-chip [data-tiles-set]');
        function applyTiles(variant) {
            var valid = ['all', 'a', 'b', 'c', 'd', 'e', 'f'];
            if (valid.indexOf(variant) === -1) variant = 'all';
            if (variant === 'all') {
                body.removeAttribute('data-tiles');
            } else {
                body.setAttribute('data-tiles', variant);
            }
            tilesButtons.forEach(function (b) {
                b.classList.toggle('active', b.dataset.tilesSet === variant);
            });
            try { localStorage.setItem(KEYS.tiles, variant); } catch (e) {}
        }
        var savedTiles; try { savedTiles = localStorage.getItem(KEYS.tiles); } catch (e) {}
        applyTiles(params.get('tiles') || savedTiles || 'all');
        tilesButtons.forEach(function (btn) {
            btn.addEventListener('click', function () { applyTiles(this.dataset.tilesSet); });
        });

        // Form (A/B/C or All — pages with form-variant blocks show only the chosen one)
        var formButtons = document.querySelectorAll('.state-chip [data-form-set]');
        function applyForm(variant) {
            var valid = ['all', 'a', 'b', 'c'];
            if (valid.indexOf(variant) === -1) variant = 'all';
            if (variant === 'all') {
                body.removeAttribute('data-form');
            } else {
                body.setAttribute('data-form', variant);
            }
            formButtons.forEach(function (b) {
                b.classList.toggle('active', b.dataset.formSet === variant);
            });
            try { localStorage.setItem(KEYS.form, variant); } catch (e) {}
        }
        var savedForm; try { savedForm = localStorage.getItem(KEYS.form); } catch (e) {}
        applyForm(params.get('form') || savedForm || 'all');
        formButtons.forEach(function (btn) {
            btn.addEventListener('click', function () { applyForm(this.dataset.formSet); });
        });

        // Crumbs (trail/back/none — top-layout breadcrumb treatment; markup lives
        // per-page, e.g. user-profile.html has both .crumbs-trail and .crumbs-back)
        // Back mode needs a back-link to show. Only a couple of pages author
        // one, so build it here from the first crumb - otherwise "Back" just
        // strips the grey band and leaves the full trail behind.
        (function () {
            var bar = document.querySelector('.ph-breadcrumb');
            if (!bar || bar.querySelector('.crumbs-back')) return;
            var trail = bar.querySelector('.ph-breadcrumb-inner');
            if (!trail) return;
            trail.classList.add('crumbs-trail');
            var first = trail.querySelector('a');
            var back = document.createElement('div');
            back.className = 'ph-breadcrumb-inner crumbs-back';
            var a = document.createElement('a');
            a.className = 'ph-back-link';
            a.href = first ? first.getAttribute('href') : 'index.html';
            a.innerHTML = '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"><polyline points="15 18 9 12 15 6"/></svg>';
            a.appendChild(document.createTextNode(first ? first.textContent.trim() : 'Back'));
            back.appendChild(a);
            bar.appendChild(back);
        })();

        var crumbsButtons = document.querySelectorAll('.state-chip [data-crumbs-set]');
        function applyCrumbs(variant) {
            var valid = ['trail', 'plain', 'pill', 'chevron', 'back', 'none'];
            if (valid.indexOf(variant) === -1) variant = 'trail';
            if (variant === 'trail') body.removeAttribute('data-crumbs');
            else body.setAttribute('data-crumbs', variant);
            crumbsButtons.forEach(function (b) {
                b.classList.toggle('active', b.dataset.crumbsSet === variant);
            });
            try { localStorage.setItem(KEYS.crumbs, variant); } catch (e) {}
        }
        var savedCrumbs; try { savedCrumbs = localStorage.getItem(KEYS.crumbs); } catch (e) {}
        applyCrumbs(params.get('crumbs') || savedCrumbs || 'trail');
        crumbsButtons.forEach(function (btn) {
            btn.addEventListener('click', function () { applyCrumbs(this.dataset.crumbsSet); });
        });

        // Plan (A/B/C/D or All — pricing package variants on the catalog page)
        var planButtons = document.querySelectorAll('.state-chip [data-plan-set]');
        function applyPlan(variant) {
            var valid = ['all', 'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h'];
            if (valid.indexOf(variant) === -1) variant = 'all';
            if (variant === 'all') body.removeAttribute('data-plan');
            else body.setAttribute('data-plan', variant);
            planButtons.forEach(function (b) {
                b.classList.toggle('active', b.dataset.planSet === variant);
            });
            try { localStorage.setItem(KEYS.plan, variant); } catch (e) {}
        }
        var savedPlan; try { savedPlan = localStorage.getItem(KEYS.plan); } catch (e) {}
        applyPlan(params.get('plan') || savedPlan || 'all');
        planButtons.forEach(function (btn) {
            btn.addEventListener('click', function () { applyPlan(this.dataset.planSet); });
        });

        // Packages (all/1/2/3/4 — caps how many packages each plan variant shows)
        var packagesButtons = document.querySelectorAll('.state-chip [data-packages-set]');
        function applyPackages(count) {
            var valid = ['all', '1', '2', '3', '4'];
            if (valid.indexOf(count) === -1) count = 'all';
            if (count === 'all') body.removeAttribute('data-packages');
            else body.setAttribute('data-packages', count);
            packagesButtons.forEach(function (b) {
                b.classList.toggle('active', b.dataset.packagesSet === count);
            });
            try { localStorage.setItem(KEYS.packages, count); } catch (e) {}
        }
        var savedPackages; try { savedPackages = localStorage.getItem(KEYS.packages); } catch (e) {}
        applyPackages(params.get('packages') || savedPackages || 'all');
        packagesButtons.forEach(function (btn) {
            btn.addEventListener('click', function () { applyPackages(this.dataset.packagesSet); });
        });

        // Product (A/B/All — pages with product-variant blocks show only the chosen one)
        var productButtons = document.querySelectorAll('.state-chip [data-product-set]');
        function applyProduct(variant) {
            var valid = ['all', 'a', 'b', 'c'];
            if (valid.indexOf(variant) === -1) variant = 'all';
            if (variant === 'all') body.removeAttribute('data-product');
            else body.setAttribute('data-product', variant);
            productButtons.forEach(function (b) {
                b.classList.toggle('active', b.dataset.productSet === variant);
            });
            try { localStorage.setItem(KEYS.product, variant); } catch (e) {}
        }
        var savedProduct; try { savedProduct = localStorage.getItem(KEYS.product); } catch (e) {}
        applyProduct(params.get('product') || savedProduct || 'all');
        productButtons.forEach(function (btn) {
            btn.addEventListener('click', function () { applyProduct(this.dataset.productSet); });
        });

        // Palette
        var paletteButtons = document.querySelectorAll('.state-chip [data-palette]');
        function applyPalette(name) {
            var valid = ['blue', 'emerald', 'violet', 'rose', 'amber', 'slate'];
            if (valid.indexOf(name) === -1) name = 'blue';
            if (name === 'blue') {
                document.documentElement.removeAttribute('data-palette');
            } else {
                document.documentElement.setAttribute('data-palette', name);
            }
            paletteButtons.forEach(function (b) {
                b.classList.toggle('active', b.dataset.palette === name);
            });
            try { localStorage.setItem(KEYS.palette, name); } catch (e) {}
        }
        var savedPalette; try { savedPalette = localStorage.getItem(KEYS.palette); } catch (e) {}
        applyPalette(params.get('palette') || savedPalette || 'blue');
        paletteButtons.forEach(function (btn) {
            btn.addEventListener('click', function () { applyPalette(this.dataset.palette); });
        });
    }

    // ── Notifications + profile dropdowns (nav + side) ─────
    function initDropdowns() {
        var ALL = ['notificationDropdownNav', 'notificationDropdownSide',
                   'profileDropdown', 'profileDropdownSide', 'profileDropdownSidebar'];
        function closeAll(except) {
            ALL.forEach(function (id) {
                if (id === except) return;
                var el = document.getElementById(id);
                if (el) el.classList.remove('open');
            });
        }
        window.togglePortalNotifications = function (e, which) {
            if (e) e.stopPropagation();
            var id = which === 'side' ? 'notificationDropdownSide' : 'notificationDropdownNav';
            var dd = document.getElementById(id);
            if (!dd) return;
            var wasOpen = dd.classList.contains('open');
            closeAll(id);
            dd.classList.toggle('open', !wasOpen);
        };
        window.togglePortalProfile = function (e, which) {
            if (e) e.stopPropagation();
            var id = which === 'sidebar' ? 'profileDropdownSidebar'
                   : which === 'side'    ? 'profileDropdownSide'
                                         : 'profileDropdown';
            var dd = document.getElementById(id);
            if (!dd) return;
            var wasOpen = dd.classList.contains('open');
            closeAll(id);
            dd.classList.toggle('open', !wasOpen);
        };
        document.addEventListener('click', function (e) {
            ALL.forEach(function (id) {
                var dd = document.getElementById(id);
                if (!dd || !dd.classList.contains('open')) return;
                var wrap = dd.parentElement;
                if (wrap && !wrap.contains(e.target)) dd.classList.remove('open');
            });
        });
    }

    // ── Mobile sidebar drawer (≤900px, side/rail) ──────────
    // Wires the hamburger button(s) in the inner-topbar to toggle
    // body.nav-open. ESC, backdrop click, link click, and resize
    // back to desktop all close the drawer.
    function initNavDrawer() {
        var body = document.body;
        var MQ = window.matchMedia('(max-width: 900px)');

        // Inject backdrop once
        var backdrop = document.querySelector('.ph-nav-backdrop');
        if (!backdrop) {
            backdrop = document.createElement('div');
            backdrop.className = 'ph-nav-backdrop';
            backdrop.setAttribute('aria-hidden', 'true');
            document.body.appendChild(backdrop);
        }

        function open() {
            if (body.dataset.layout === 'top') return;
            body.classList.add('nav-open');
            document.querySelectorAll('[data-nav-toggle]').forEach(function (b) {
                b.setAttribute('aria-expanded', 'true');
            });
        }
        function close() {
            body.classList.remove('nav-open');
            document.querySelectorAll('[data-nav-toggle]').forEach(function (b) {
                b.setAttribute('aria-expanded', 'false');
            });
        }
        function toggle() {
            if (body.classList.contains('nav-open')) close(); else open();
        }

        document.querySelectorAll('[data-nav-toggle]').forEach(function (btn) {
            btn.addEventListener('click', function (e) { e.stopPropagation(); toggle(); });
        });

        backdrop.addEventListener('click', close);

        document.addEventListener('keydown', function (e) {
            if (e.key === 'Escape' && body.classList.contains('nav-open')) close();
        });

        // Close after navigating via a sidebar link (only on mobile)
        document.querySelectorAll('.sidebar a, .ph-rail-item').forEach(function (a) {
            a.addEventListener('click', function () {
                if (MQ.matches) close();
            });
        });

        // If we resize back into desktop, drop the drawer state
        function syncMQ() { if (!MQ.matches) close(); }
        if (MQ.addEventListener) MQ.addEventListener('change', syncMQ);
        else MQ.addListener(syncMQ);
    }

    // ── Sidebar collapsible groups ─────────────────────────
    function initSidebarGroups() {
        var saved;
        try { saved = JSON.parse(localStorage.getItem(KEYS.sidebarGroups) || '[]'); }
        catch (e) { saved = []; }
        if (!saved.length) saved = ['services']; // sensible default for logged-in
        document.querySelectorAll('.sidebar-group').forEach(function (group) {
            var id = group.dataset.group;
            if (saved.indexOf(id) !== -1) group.classList.add('open');
            var toggle = group.querySelector('.sidebar-group-toggle');
            if (!toggle) return;
            toggle.addEventListener('click', function () {
                group.classList.toggle('open');
                var openNow = Array.prototype.slice.call(
                    document.querySelectorAll('.sidebar-group.open')
                ).map(function (g) { return g.dataset.group; });
                try { localStorage.setItem(KEYS.sidebarGroups, JSON.stringify(openNow)); }
                catch (e) {}
            });
        });
    }

    // ── Rail hover/click interaction ───────────────────────
    function initRail() {
        var body = document.body;
        var railEl = document.querySelector('.ph-rail');
        var panelEl = document.querySelector('.ph-rail-panel');
        if (!railEl || !panelEl) return;

        var hoverTimer;
        function openFor(item) {
            clearTimeout(hoverTimer);
            var target = item.dataset.rail;
            document.querySelectorAll('.ph-rail-item').forEach(function (b) { b.classList.remove('active'); });
            item.classList.add('active');
            document.querySelectorAll('.ph-rail-panel-group').forEach(function (g) {
                g.classList.toggle('active', g.dataset.panel === target);
            });
            body.classList.add('rail-panel-open');
        }
        function scheduleClose() {
            clearTimeout(hoverTimer);
            hoverTimer = setTimeout(function () {
                body.classList.remove('rail-panel-open');
                document.querySelectorAll('.ph-rail-item').forEach(function (b) { b.classList.remove('active'); });
            }, 180);
        }
        function cancelClose() { clearTimeout(hoverTimer); }

        function pickDefault() {
            var firstVisible = Array.prototype.slice.call(document.querySelectorAll('.ph-rail-item[data-rail]'))
                .find(function (b) { return getComputedStyle(b).display !== 'none'; });
            if (!firstVisible) return;
            var target = firstVisible.dataset.rail;
            document.querySelectorAll('.ph-rail-item').forEach(function (b) { b.classList.remove('active'); });
            firstVisible.classList.add('active');
            document.querySelectorAll('.ph-rail-panel-group').forEach(function (g) {
                g.classList.toggle('active', g.dataset.panel === target);
            });
        }

        document.querySelectorAll('.ph-rail-item[data-rail]').forEach(function (btn) {
            btn.addEventListener('mouseenter', function () { if (body.dataset.layout === 'rail') openFor(btn); });
            btn.addEventListener('click', function () { openFor(btn); });
            btn.addEventListener('focus', function () { if (body.dataset.layout === 'rail') openFor(btn); });
        });
        railEl.addEventListener('mouseleave', scheduleClose);
        railEl.addEventListener('mouseenter', cancelClose);
        panelEl.addEventListener('mouseleave', scheduleClose);
        panelEl.addEventListener('mouseenter', cancelClose);

        // When auth flips while in rail layout, re-pick a visible item
        new MutationObserver(function () {
            if (body.dataset.layout !== 'rail') return;
            var current = document.querySelector('.ph-rail-item.active');
            var visible = current && getComputedStyle(current).display !== 'none';
            if (!visible) pickDefault();
        }).observe(body, { attributes: true, attributeFilter: ['data-auth'] });
    }

    // ── Promo slider (shared store-promo carousel) ─────────
    // Any element with [data-slider] auto-advances every 5.5s, pauses on
    // hover, dots jump + restart the timer.
    function initPromoSliders() {
        document.querySelectorAll('[data-slider]').forEach(function (slider) {
            if (slider.dataset.sliderInited === '1') return;
            slider.dataset.sliderInited = '1';
            var track = slider.querySelector('.promo-slider-track');
            var slides = slider.querySelectorAll('.promo-slide');
            var dots = slider.querySelectorAll('.promo-slider-dot');
            if (!track || !slides.length) return;
            var current = 0, timer;
            function go(i) {
                current = (i + slides.length) % slides.length;
                track.style.transform = 'translateX(-' + (current * 100) + '%)';
                dots.forEach(function (d, idx) { d.classList.toggle('active', idx === current); });
            }
            function tick() { go(current + 1); }
            function start() { stop(); timer = setInterval(tick, 5500); }
            function stop() { if (timer) clearInterval(timer); timer = null; }
            dots.forEach(function (dot) {
                dot.addEventListener('click', function () {
                    go(parseInt(dot.dataset.slideTo, 10) || 0);
                    start();
                });
            });
            slider.addEventListener('mouseenter', stop);
            slider.addEventListener('mouseleave', start);
            start();
        });
    }

    // ── Locale (language + currency) modal ─────────────────
    function initLocaleModal() {
        var modal = document.getElementById('localeModal');
        if (!modal) return;
        var openBtns = document.querySelectorAll('[data-locale-open]');
        var closeBtn = document.getElementById('localeModalClose');
        var applyBtn = document.getElementById('localeApply');

        function open() { modal.classList.add('open'); document.body.style.overflow = 'hidden'; }
        function close() { modal.classList.remove('open'); document.body.style.overflow = ''; }

        openBtns.forEach(function (btn) { btn.addEventListener('click', open); });
        if (closeBtn) closeBtn.addEventListener('click', close);
        modal.addEventListener('click', function (e) { if (e.target === modal) close(); });
        document.addEventListener('keydown', function (e) {
            if (e.key === 'Escape' && modal.classList.contains('open')) close();
        });
        modal.querySelectorAll('.locale-grid').forEach(function (grid) {
            grid.addEventListener('click', function (e) {
                var btn = e.target.closest('button');
                if (!btn) return;
                grid.querySelectorAll('button').forEach(function (b) { b.classList.remove('active'); });
                btn.classList.add('active');
            });
        });
        if (applyBtn) {
            applyBtn.addEventListener('click', function () {
                var lang = modal.querySelector('[data-lang].active');
                var curr = modal.querySelector('[data-currency].active');
                var flagMap = {
                    english: '🇺🇸', german: '🇩🇪', french: '🇫🇷', spanish: '🇪🇸', italian: '🇮🇹',
                    chinese: '🇨🇳', japanese: '🇯🇵', russian: '🇷🇺', portuguese: '🇵🇹',
                    'portuguese-br': '🇧🇷', dutch: '🇳🇱', swedish: '🇸🇪', norwegian: '🇳🇴',
                    danish: '🇩🇰', turkish: '🇹🇷', ukrainian: '🇺🇦'
                };
                var flag = (lang && flagMap[lang.dataset.lang]) || '🌐';
                openBtns.forEach(function (summary) {
                    var flagEl = summary.querySelector('.flag');
                    if (flagEl) flagEl.textContent = flag;
                    var spans = summary.querySelectorAll('span');
                    if (spans[1]) spans[1].textContent = lang ? lang.textContent.trim() : 'English';
                    if (spans[3]) spans[3].textContent = curr ? curr.textContent.trim() : '$ USD';
                });
                close();
            });
        }
    }

    // ── Active nav highlight from <body data-active-nav="..."> ─
    function applyActiveNav() {
        var active = document.body.dataset.activeNav;
        if (!active) return;
        document.querySelectorAll('[data-nav="' + active + '"]').forEach(function (el) {
            el.classList.add('active');
        });
        // Also open the parent sidebar-group (if any) so the active child is visible.
        document.querySelectorAll('[data-nav="' + active + '"]').forEach(function (el) {
            var group = el.closest('.sidebar-group');
            if (group) group.classList.add('open');
        });
    }

    // ── Breadcrumb "current page" fill-in ──────────────────
    // Any element with [data-current-page] gets its text set to
    // <body data-page-title="...">. Saves per-page partials from
    // having to duplicate the page name.
    function applyPageTitle() {
        var title = document.body.dataset.pageTitle;
        if (!title) return;
        document.querySelectorAll('[data-current-page]').forEach(function (el) {
            el.textContent = title;
        });
    }

    // Live color control panel: a floating, draggable, collapsible panel that
    // live-edits every --color-* token by writing inline custom-props on <html>
    // (which override :root + dark mode). Prototyping aid for the mockup;
    // "Copy CSS" exports only the tokens you changed.
    function initColorPanel() {
        if (document.querySelector('.cp-panel')) return;
        var root = document.documentElement;

        var GROUPS = [
            ['Brand', [['--color-accent', 'Accent'], ['--color-accent-hover', 'Accent hover'], ['--color-accent-light', 'Accent tint'], ['--color-link', 'Link'], ['--color-link-hover', 'Link hover']]],
            ['Backgrounds', [['--color-bg', 'Page'], ['--color-surface', 'Surface'], ['--color-surface-secondary', 'Surface 2'], ['--color-surface-tertiary', 'Surface 3']]],
            ['Text', [['--color-text-primary', 'Primary'], ['--color-text-secondary', 'Secondary'], ['--color-text-tertiary', 'Tertiary'], ['--color-text-quaternary', 'Quaternary']]],
            ['Borders', [['--color-border', 'Border'], ['--color-border-light', 'Border light'], ['--color-border-card', 'Card border']]],
            ['Status', [['--color-green', 'Success'], ['--color-green-text', 'Success text'], ['--color-green-bg', 'Success fill'], ['--color-orange', 'Warning'], ['--color-orange-text', 'Warning text'], ['--color-orange-bg', 'Warning fill'], ['--color-red', 'Danger'], ['--color-red-text', 'Danger text'], ['--color-red-bg', 'Danger fill']]],
            ['Badges', [['--color-blue-text', 'Info'], ['--color-blue-bg', 'Info fill'], ['--color-gray-text', 'Neutral'], ['--color-gray-bg', 'Neutral fill']]],
            ['Sidebar', [['--sidebar-bg', 'Background'], ['--sidebar-item-hover', 'Item hover'], ['--sidebar-item-active', 'Item active'], ['--sidebar-icon-bg', 'Icon tile']]],
            ['Topbar', [['--topbar-bg', 'Background']]],
            ['Icon tiles', [['--color-icon-blue', 'Blue'], ['--color-icon-purple', 'Purple'], ['--color-icon-orange', 'Orange'], ['--color-icon-green', 'Green'], ['--color-icon-red', 'Red'], ['--color-icon-teal', 'Teal'], ['--color-icon-gray', 'Gray'], ['--color-icon-indigo', 'Indigo'], ['--color-icon-pink', 'Pink'], ['--color-icon-mono', 'Uniform (mono)']]]
        ];
        var PRESETS = [
            ['Default', '#0071e3'], ['Emerald', '#14b17d'], ['Violet', '#8c5cff'], ['Rose', '#ff2d6b'], ['Amber', '#f08a00'], ['Slate', '#64748b'],
            // [name, primary, deep] — Roman brand palettes (gold accent flagged separately).
            ['Hadrian', '#0d5c56', '#0a4944'], ['Augustus', '#4a2545', '#2f1a2d'], ['Trajan', '#1f3a5f', '#142844'], ['Aurelius', '#2d4a2a', '#1a2e18'], ['Constantine', '#5b2a2a', '#3a1818']
        ];

        var css = [
            '.cp-fab{position:fixed;right:16px;bottom:16px;z-index:99998;display:inline-flex;align-items:center;gap:6px;padding:9px 14px;border:0;border-radius:980px;background:#1d1d1f;color:#fff;font:600 13px -apple-system,system-ui,sans-serif;cursor:pointer;box-shadow:0 4px 16px rgba(0,0,0,0.2);}',
            '.cp-fab svg{width:14px;height:14px;}',
            '.cp-panel{position:fixed;right:16px;bottom:16px;z-index:99999;width:300px;max-height:82vh;display:flex;flex-direction:column;background:#fff;color:#1d1d1f;border:1px solid #e8e8ed;border-radius:14px;box-shadow:0 12px 48px rgba(0,0,0,0.22);font:13px -apple-system,system-ui,sans-serif;overflow:hidden;}',
            '.cp-head{display:flex;align-items:center;gap:4px;padding:9px 12px;border-bottom:1px solid #e8e8ed;cursor:move;background:#fafafa;}',
            '.cp-title{font-weight:600;flex:1;font-size:13px;}',
            '.cp-head button{border:0;background:transparent;cursor:pointer;font:500 12px -apple-system,system-ui,sans-serif;color:#0071e3;padding:4px 7px;border-radius:6px;}',
            '.cp-head button:hover{background:#eef0f3;}',
            '.cp-body{overflow-y:auto;padding:10px 12px;}',
            '.cp-presets{display:flex;flex-wrap:wrap;gap:6px;margin-bottom:10px;}',
            '.cp-preset{display:inline-flex;align-items:center;gap:5px;padding:4px 9px;border:1px solid #e8e8ed;border-radius:980px;background:#fff;cursor:pointer;font:500 12px -apple-system,system-ui,sans-serif;color:#1d1d1f;}',
            '.cp-dot{width:11px;height:11px;border-radius:50%;}',
            '.cp-grp{font-size:10px;font-weight:700;text-transform:uppercase;letter-spacing:.05em;color:#86868b;margin:12px 0 5px;}',
            '.cp-grp.first{margin-top:0;}',
            '.cp-row{display:flex;align-items:center;gap:8px;padding:3px 0;}',
            '.cp-label{flex:1;font-size:12px;color:#6e6e73;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;}',
            '.cp-sw{width:26px;height:26px;padding:2px;border:1px solid #d2d2d7;border-radius:6px;background:#fff;cursor:pointer;flex-shrink:0;}',
            '.cp-tx{width:104px;flex-shrink:0;font:12px ui-monospace,SFMono-Regular,Menlo,monospace;padding:5px 7px;border:1px solid #d2d2d7;border-radius:6px;color:#1d1d1f;}',
            '.cp-foot{padding:8px 12px;border-top:1px solid #e8e8ed;font-size:11px;color:#86868b;line-height:1.4;}',
            '.cp-iconmode{display:inline-flex;background:#eef0f3;border-radius:8px;padding:2px;margin:2px 0 8px;}',
            '.cp-iconmode button{border:0;background:transparent;font:500 12px -apple-system,system-ui,sans-serif;color:#6e6e73;padding:5px 12px;border-radius:6px;cursor:pointer;}',
            '.cp-iconmode button.active{background:#fff;color:#1d1d1f;box-shadow:0 1px 2px rgba(0,0,0,0.08);}',
            'body[data-preview="off"] .cp-fab,body[data-preview="off"] .cp-panel,body.screenshot .cp-fab,body.screenshot .cp-panel{display:none!important;}'
        ].join('');
        var st = document.createElement('style'); st.textContent = css; document.head.appendChild(st);

        function cur(v) { return getComputedStyle(root).getPropertyValue(v).trim(); }
        function cl(n) { return Math.max(0, Math.min(255, Math.round(n))); }
        function h2(n) { return ('0' + cl(n).toString(16)).slice(-2); }
        function toHex(v) {
            v = (v || '').trim();
            var m = v.match(/^#([0-9a-f]{6})$/i); if (m) return '#' + m[1].toLowerCase();
            m = v.match(/^#([0-9a-f]{3})$/i); if (m) { var c = m[1]; return ('#' + c[0] + c[0] + c[1] + c[1] + c[2] + c[2]).toLowerCase(); }
            m = v.match(/rgba?\(\s*(\d+)\s*,\s*(\d+)\s*,\s*(\d+)/i); if (m) return '#' + h2(+m[1]) + h2(+m[2]) + h2(+m[3]);
            return '#000000';
        }
        function toRgb(v) { var i = parseInt(toHex(v).slice(1), 16); return [(i >> 16) & 255, (i >> 8) & 255, i & 255]; }
        function darken(v, p) { var r = toRgb(v); return '#' + h2(r[0] * (1 - p)) + h2(r[1] * (1 - p)) + h2(r[2] * (1 - p)); }
        function rgba(v, a) { var r = toRgb(v); return 'rgba(' + r[0] + ',' + r[1] + ',' + r[2] + ',' + a + ')'; }

        var inner = '<div class="cp-presets">';
        PRESETS.forEach(function (p) { inner += '<button type="button" class="cp-preset" data-accent="' + p[1] + '"' + (p[2] ? ' data-deep="' + p[2] + '"' : '') + '><span class="cp-dot" style="background:' + p[1] + '"></span>' + p[0] + '</button>'; });
        inner += '</div>';
        GROUPS.forEach(function (g, gi) {
            inner += '<div class="cp-grp' + (gi === 0 ? ' first' : '') + '">' + g[0] + '</div>';
            if (g[0] === 'Icon tiles') {
                inner += '<div class="cp-iconmode"><button type="button" data-iconmode="colorful">Colorful</button><button type="button" data-iconmode="mono">Mono</button></div>';
            }
            g[1].forEach(function (t) {
                var val = cur(t[0]);
                inner += '<div class="cp-row" data-var="' + t[0] + '"><span class="cp-label">' + t[1] + '</span><input type="color" class="cp-sw" value="' + toHex(val) + '"><input type="text" class="cp-tx" spellcheck="false" value="' + val + '"></div>';
            });
        });

        var panel = document.createElement('div'); panel.className = 'cp-panel'; panel.hidden = true;
        panel.innerHTML = '<div class="cp-head"><span class="cp-title">Colors</span><button type="button" data-cp="reset">Reset</button><button type="button" data-cp="copy">Copy CSS</button><button type="button" data-cp="close" title="Close">Done</button></div><div class="cp-body">' + inner + '</div><div class="cp-foot">Live preview &mdash; this browser only. Edits the active mode. &ldquo;Copy CSS&rdquo; exports changed tokens.</div>';
        document.body.appendChild(panel);

        var fab = document.createElement('button'); fab.type = 'button'; fab.className = 'cp-fab';
        fab.innerHTML = '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="13.5" cy="6.5" r=".5"/><circle cx="17.5" cy="10.5" r=".5"/><circle cx="8.5" cy="7.5" r=".5"/><circle cx="6.5" cy="12.5" r=".5"/><path d="M12 2C6.5 2 2 6.5 2 12s4.5 10 10 10c.9 0 1.5-.7 1.5-1.5 0-.4-.2-.8-.4-1-.3-.3-.4-.6-.4-1 0-.8.7-1.5 1.5-1.5H16c3.3 0 6-2.7 6-6 0-4.4-4.5-8-10-8z"/></svg>Colors';
        document.body.appendChild(fab);

        function rowEls(v) { var r = panel.querySelector('.cp-row[data-var="' + v + '"]'); return r ? { sw: r.querySelector('.cp-sw'), tx: r.querySelector('.cp-tx') } : null; }
        function setVar(v, val, fromTx) { root.style.setProperty(v, val); var e = rowEls(v); if (e) { e.sw.value = toHex(val); if (!fromTx) e.tx.value = val; } }

        panel.querySelectorAll('.cp-sw').forEach(function (sw) { sw.addEventListener('input', function () { setVar(sw.closest('.cp-row').getAttribute('data-var'), sw.value, false); }); });
        panel.querySelectorAll('.cp-tx').forEach(function (tx) { tx.addEventListener('input', function () { setVar(tx.closest('.cp-row').getAttribute('data-var'), tx.value, true); }); });
        panel.querySelectorAll('.cp-preset').forEach(function (b) {
            b.addEventListener('click', function () {
                var hx = b.getAttribute('data-accent');
                var deep = b.getAttribute('data-deep') || darken(hx, 0.08);
                setVar('--color-accent', hx); setVar('--color-accent-hover', deep); setVar('--color-accent-light', rgba(hx, 0.08)); setVar('--color-link', hx); setVar('--color-link-hover', deep);
            });
        });
        fab.addEventListener('click', function () { panel.hidden = false; fab.style.display = 'none'; });

        // Colorful / Mono icon toggle inside the panel (mirrors the state-chip "Icons").
        var imBtns = [].slice.call(panel.querySelectorAll('[data-iconmode]'));
        function applyIconMode(mode) {
            if (mode !== 'mono') mode = 'colorful';
            if (mode === 'colorful') { document.body.removeAttribute('data-icons'); } else { document.body.setAttribute('data-icons', 'mono'); }
            imBtns.forEach(function (b) { b.classList.toggle('active', b.getAttribute('data-iconmode') === mode); });
            [].slice.call(document.querySelectorAll('.state-chip [data-icons-set]')).forEach(function (b) { b.classList.toggle('active', b.dataset.iconsSet === mode); });
            try { localStorage.setItem('hn.icons', mode); } catch (e) {}
        }
        imBtns.forEach(function (b) { b.addEventListener('click', function () { applyIconMode(b.getAttribute('data-iconmode')); }); });
        applyIconMode(document.body.getAttribute('data-icons') === 'mono' ? 'mono' : 'colorful');
        panel.querySelector('[data-cp="close"]').addEventListener('click', function () { panel.hidden = true; fab.style.display = ''; });
        panel.querySelector('[data-cp="reset"]').addEventListener('click', function () {
            GROUPS.forEach(function (g) { g[1].forEach(function (t) { root.style.removeProperty(t[0]); }); });
            panel.querySelectorAll('.cp-row').forEach(function (r) { var v = r.getAttribute('data-var'), val = cur(v); r.querySelector('.cp-sw').value = toHex(val); r.querySelector('.cp-tx').value = val; });
        });
        panel.querySelector('[data-cp="copy"]').addEventListener('click', function (e) {
            var lines = [];
            GROUPS.forEach(function (g) { g[1].forEach(function (t) { var ov = root.style.getPropertyValue(t[0]); if (ov) lines.push('  ' + t[0] + ': ' + ov.trim() + ';'); }); });
            var out = lines.length ? ':root {\n' + lines.join('\n') + '\n}' : '/* no changes yet */';
            var btn = e.target, orig = btn.textContent;
            var done = function () { btn.textContent = 'Copied!'; setTimeout(function () { btn.textContent = orig; }, 1200); };
            if (navigator.clipboard && navigator.clipboard.writeText) { navigator.clipboard.writeText(out).then(done, function () { window.prompt('Copy these tokens:', out); }); }
            else { window.prompt('Copy these tokens:', out); }
        });

        var head = panel.querySelector('.cp-head'), dragging = false, sx, sy, ox, oy;
        head.addEventListener('mousedown', function (e) {
            if (e.target.tagName === 'BUTTON') return;
            var r = panel.getBoundingClientRect();
            panel.style.right = 'auto'; panel.style.bottom = 'auto'; panel.style.left = r.left + 'px'; panel.style.top = r.top + 'px';
            ox = r.left; oy = r.top; sx = e.clientX; sy = e.clientY; dragging = true; e.preventDefault();
        });
        document.addEventListener('mousemove', function (e) { if (!dragging) return; panel.style.left = Math.max(4, ox + (e.clientX - sx)) + 'px'; panel.style.top = Math.max(4, oy + (e.clientY - sy)) + 'px'; });
        document.addEventListener('mouseup', function () { dragging = false; });
    }

    // ── Bootstrap ──────────────────────────────────────────
    function boot() {
        var params = new URLSearchParams(window.location.search);
        var previewState = (params.get('preview') || '').toLowerCase();
        if (['0', 'off', 'false', 'hide', 'none'].indexOf(previewState) !== -1 || params.get('screenshot') === '1') {
            document.body.setAttribute('data-preview', 'off');
            document.body.classList.add('screenshot');
        }
        return loadPartials().then(function () {
            var chip = document.querySelector('.state-chip');
            if (chip) initChipDrag(chip);
            initStateToggles(params);
            initDropdowns();
            initSidebarGroups();
            initNavDrawer();
            initRail();
            initPromoSliders();
            initLocaleModal();
            applyActiveNav();
            applyPageTitle();
            initColorPanel();
            document.dispatchEvent(new CustomEvent('apple-layout:ready'));
        });
    }

    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', boot);
    } else {
        boot();
    }
})();
