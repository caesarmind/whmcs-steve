/* ============================================================
   core-layout.js — Shared layout system for every page
   ------------------------------------------------------------
   Pairs with css/core-layout.css and ./partials/. Handles:
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
        palette:       'hn.palette',
        data:          'hn.data',
        align:         'hn.align',
        subnav:        'hn.subnav',
        subnavSide:    'hn.subnavSide',
        tiles:         'hn.tiles',
        form:          'hn.form',
        product:       'hn.product',
        plan:          'hn.plan',
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
        // ?preview=1 unlocks the dev chip's live toggles. Outside preview none
        // of this dev/mockup state (layout, data, variants, palette…) is read
        // from the URL or localStorage, so it can't leak into the real portal.
        var previewMode = params.get('preview') === '1';

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

        // Layout. The server renders the admin-picked layout in production and
        // only that layout's markup exists in the DOM. The live switch (URL /
        // localStorage) is a ?preview=1-only affordance — outside preview we
        // MUST honor the server's data-layout, or we'd point it at markup that
        // isn't on the page.
        var layoutButtons = document.querySelectorAll('.state-chip [data-layout-set]');
        // The server-rendered token is ALWAYS valid — for a custom layout it
        // names markup that genuinely is on the page. The old hardcoded
        // ['top','side','rail'] check coerced any unknown token to 'top' even
        // outside preview, which pointed the page at markup that was NOT in
        // the DOM and hid the custom layout's own chrome: the exact bug the
        // comment above this block warns against. Valid = a chip button's
        // token (switchable markup is in the preview DOM) or the server's own.
        var serverLayout = body.dataset.layout || 'side';
        var chipTokens = Array.prototype.map.call(layoutButtons, function (b) {
            return b.dataset.layoutSet;
        });
        function applyLayout(layout, persist) {
            if (chipTokens.indexOf(layout) === -1 && layout !== serverLayout) {
                layout = serverLayout;
            }
            body.dataset.layout = layout;
            layoutButtons.forEach(function (b) {
                b.classList.toggle('active', b.dataset.layoutSet === layout);
            });
            body.classList.remove('rail-panel-open');
            if (persist !== false) { try { localStorage.setItem(KEYS.layout, layout); } catch (e) {} }
        }
        if (previewMode) {
            var savedLayout; try { savedLayout = localStorage.getItem(KEYS.layout); } catch (e) {}
            applyLayout(params.get('layout') || savedLayout || serverLayout);
        } else {
            // Respect the server-rendered layout; don't clobber the dev's saved choice.
            applyLayout(serverLayout, false);
        }
        layoutButtons.forEach(function (btn) {
            btn.addEventListener('click', function () { applyLayout(this.dataset.layoutSet); });
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
        if (previewMode) {
            var savedAlign; try { savedAlign = localStorage.getItem(KEYS.align); } catch (e) {}
            applyAlign(params.get('align') || savedAlign || 'center');
        }
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
        if (previewMode) {
            var savedSubnav; try { savedSubnav = localStorage.getItem(KEYS.subnav); } catch (e) {}
            applySubnav(params.get('subnav') || savedSubnav || body.dataset.subnav || 'on');
        }
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
        if (previewMode) {
            var savedSubnavSide; try { savedSubnavSide = localStorage.getItem(KEYS.subnavSide); } catch (e) {}
            applySubnavSide(params.get('subnavSide') || savedSubnavSide || 'right');
        }
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
        if (previewMode) {
            var savedSvcLayout; try { savedSvcLayout = localStorage.getItem(KEYS.svcLayout); } catch (e) {}
            applySvcLayout(params.get('svcLayout') || savedSvcLayout || 'inside');
        }
        svcLayoutButtons.forEach(function (btn) {
            btn.addEventListener('click', function () { applySvcLayout(this.dataset.svcLayoutSet); });
        });

        // Hide the Services (inside/outside) chip on pages where the toggle does
        // nothing. It now responds wherever there's a content card, a settings-group,
        // or a known bespoke surface wrapper (see core-layout.css svc-layout rules) --
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
        // The page tpl's inline script sets body[data-data] from real WHMCS
        // record counts — that reality is authoritative. In preview the chip
        // (URL/saved) may override it to demo empty states; outside preview we
        // never read saved/URL, so the real data state always wins.
        var existingData = body.hasAttribute('data-data') ? body.dataset.data : null;
        if (previewMode) {
            var savedData; try { savedData = localStorage.getItem(KEYS.data); } catch (e) {}
            applyData(params.get('data') || existingData || savedData || 'full');
        } else {
            applyData(existingData || 'full');
        }
        dataButtons.forEach(function (btn) {
            btn.addEventListener('click', function () { applyData(this.dataset.dataSet); });
        });

        // Hide variant-picker groups on pages that have nothing to switch.
        // Each picker's parent .chip-group collapses if no matching .*-variant nodes exist.
        [
            { selector: '.tile-variant', pickerAttr: '[data-tiles-set]' },
            { selector: '.form-variant', pickerAttr: '[data-form-set]' },
            { selector: '.product-variant', pickerAttr: '[data-product-set]' },
            { selector: '.plan-variant', pickerAttr: '[data-plan-set]' }
        ].forEach(function (cfg) {
            if (document.querySelector(cfg.selector)) return;
            var btn = document.querySelector('.state-chip ' + cfg.pickerAttr);
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
        if (previewMode) {
            var savedTiles; try { savedTiles = localStorage.getItem(KEYS.tiles); } catch (e) {}
            applyTiles(params.get('tiles') || savedTiles || 'all');
        }
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
        if (previewMode) {
            var savedForm; try { savedForm = localStorage.getItem(KEYS.form); } catch (e) {}
            applyForm(params.get('form') || savedForm || 'all');
        }
        formButtons.forEach(function (btn) {
            btn.addEventListener('click', function () { applyForm(this.dataset.formSet); });
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
        if (previewMode) {
            var savedPlan; try { savedPlan = localStorage.getItem(KEYS.plan); } catch (e) {}
            applyPlan(params.get('plan') || savedPlan || 'all');
        }
        planButtons.forEach(function (btn) {
            btn.addEventListener('click', function () { applyPlan(this.dataset.planSet); });
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
        if (previewMode) {
            var savedProduct; try { savedProduct = localStorage.getItem(KEYS.product); } catch (e) {}
            applyProduct(params.get('product') || savedProduct || 'all');
        }
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
        if (previewMode) {
            var savedPalette; try { savedPalette = localStorage.getItem(KEYS.palette); } catch (e) {}
            applyPalette(params.get('palette') || savedPalette || 'blue');
        }
        paletteButtons.forEach(function (btn) {
            btn.addEventListener('click', function () { applyPalette(this.dataset.palette); });
        });
    }

    // ── Notifications + profile dropdowns (nav + side + rail) ─────
    function initDropdowns() {
        // Every panel id must be listed here or outside-click never closes it.
        var ALL = ['notificationDropdownNav', 'notificationDropdownSide',
                   'profileDropdown', 'profileDropdownSide', 'profileDropdownSidebar',
                   'profileDropdownRail', 'profileDropdownBand'];
        // Keep the trigger's aria-expanded honest. The panels are toggled by a
        // class, and nothing was syncing the attribute -- so a trigger that
        // declared aria-expanded="false" kept claiming it while its menu was
        // open, which is worse for a screen reader than not declaring it at
        // all. Finds the trigger as the aria-haspopup element beside the panel;
        // call sites that do not declare one are unaffected.
        function setExpanded(dd, open) {
            var wrap = dd && dd.parentElement;
            var trigger = wrap && wrap.querySelector('[aria-haspopup]');
            if (trigger) trigger.setAttribute('aria-expanded', open ? 'true' : 'false');
        }
        function closeAll(except) {
            ALL.forEach(function (id) {
                if (id === except) return;
                var el = document.getElementById(id);
                if (el) { el.classList.remove('open'); setExpanded(el, false); }
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
            setExpanded(dd, !wasOpen);
        };
        window.togglePortalProfile = function (e, which) {
            if (e) e.stopPropagation();
            var id = which === 'sidebar' ? 'profileDropdownSidebar'
                   : which === 'side'    ? 'profileDropdownSide'
                   : which === 'rail'    ? 'profileDropdownRail'
                   : which === 'band'    ? 'profileDropdownBand'
                                         : 'profileDropdown';
            var dd = document.getElementById(id);
            if (!dd) return;
            var wasOpen = dd.classList.contains('open');
            closeAll(id);
            dd.classList.toggle('open', !wasOpen);
            setExpanded(dd, !wasOpen);
        };
        document.addEventListener('click', function (e) {
            ALL.forEach(function (id) {
                var dd = document.getElementById(id);
                if (!dd || !dd.classList.contains('open')) return;
                var wrap = dd.parentElement;
                if (wrap && !wrap.contains(e.target)) { dd.classList.remove('open'); setExpanded(dd, false); }
            });
        });
        // The rail and sidebar triggers are <div role="button">, not <button>,
        // so the browser does not synthesise a click from Enter/Space the way
        // it does for real buttons -- keyboard users could focus the avatar and
        // get nothing. Delegated so it covers both, and any future one.
        document.addEventListener('keydown', function (e) {
            if (e.key !== 'Enter' && e.key !== ' ' && e.key !== 'Spacebar') return;
            var t = e.target;
            if (!t || !t.closest) return;
            var trigger = t.closest('.profile-dropdown-wrapper [role="button"]');
            if (!trigger) return;
            e.preventDefault();          // stop Space scrolling the page
            trigger.click();
        });
        // Escape closes whatever is open, and returns focus nowhere special --
        // the trigger keeps focus because we never moved it.
        document.addEventListener('keydown', function (e) {
            if (e.key === 'Escape') closeAll(null);
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

        // The drawer is the rail on the rail layout, the sidebar otherwise.
        var drawer = body.dataset.layout === 'rail'
            ? document.getElementById('appRail')
            : document.getElementById('appSidebar');
        if (drawer && drawer.id === 'appRail') {
            document.querySelectorAll('[data-nav-toggle]').forEach(function (b) {
                b.setAttribute('aria-controls', 'appRail');
            });
        }
        var lastToggle = null;

        // While the drawer is closed and off screen (<=900px) it must not
        // take focus: its links sat first in the tab order, invisible
        // (WCAG 2.4.3, 2.4.7). Above 900px it is the visible sidebar or rail.
        function syncInert() {
            if (!drawer) return;
            var hidden = MQ.matches && !body.classList.contains('nav-open');
            if (hidden) drawer.setAttribute('inert', ''); else drawer.removeAttribute('inert');
        }

        function open() {
            body.classList.add('nav-open');
            document.querySelectorAll('[data-nav-toggle]').forEach(function (b) {
                b.setAttribute('aria-expanded', 'true');
            });
            syncInert();
            // Move focus into the drawer: it sits before the button in the
            // page, so Tab from the button would skip past it.
            if (drawer && MQ.matches) {
                var first = drawer.querySelector('a[href], button:not([disabled]), input:not([type="hidden"]), [tabindex="0"]');
                if (first) setTimeout(function () { first.focus(); }, 30);
            }
        }
        function close(restoreFocus) {
            var wasOpen = body.classList.contains('nav-open');
            body.classList.remove('nav-open');
            document.querySelectorAll('[data-nav-toggle]').forEach(function (b) {
                b.setAttribute('aria-expanded', 'false');
            });
            syncInert();
            if (wasOpen && restoreFocus === true && lastToggle) lastToggle.focus();
        }
        function toggle() {
            if (body.classList.contains('nav-open')) close(true); else open();
        }

        document.querySelectorAll('[data-nav-toggle]').forEach(function (btn) {
            btn.addEventListener('click', function (e) {
                e.stopPropagation();
                // Remember the button that opened it, not the drawer's own
                // Close button: focus goes back there, outside the drawer.
                if (!drawer || !drawer.contains(btn)) lastToggle = btn;
                toggle();
            });
        });

        backdrop.addEventListener('click', close);

        document.addEventListener('keydown', function (e) {
            if (e.key === 'Escape' && body.classList.contains('nav-open')) close(true);
        });

        // Close after navigating via a sidebar link (only on mobile)
        document.querySelectorAll('.sidebar a, .ph-rail-item').forEach(function (a) {
            a.addEventListener('click', function () {
                if (MQ.matches) close();
            });
        });

        // If we resize back into desktop, drop the drawer state
        function syncMQ() { if (!MQ.matches) close(); syncInert(); }
        if (MQ.addEventListener) MQ.addEventListener('change', syncMQ);
        else MQ.addListener(syncMQ);
        syncInert();
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
            // Skip if the inline script in sidebar.tpl already attached a
            // handler. Without this guard we'd attach a second toggle and
            // both fire per click — net result: no change.
            if (toggle.dataset.mtBound === '1') return;
            toggle.dataset.mtBound = '1';
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

        // preventDefault matters: the footer trigger is a <button>, but the
        // menu switchers and the cart's currency link are <a href="#">, which
        // would open the modal AND jump the page to the top.
        function open(e) {
            if (e && typeof e.preventDefault === 'function') e.preventDefault();
            modal.classList.add('open');
            document.body.style.overflow = 'hidden';
        }
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
                var currentLang = modal.dataset.currentLang || '';
                var currentCurrId = modal.dataset.currentCurrencyId || '';
                var url = new URL(window.location.href);
                var changed = false;
                if (lang && lang.dataset.lang && lang.dataset.lang !== currentLang) {
                    url.searchParams.set('language', lang.dataset.lang);
                    changed = true;
                }
                // WHMCS expects ?currency=<numeric id>. The static fallback buttons have
                // no data-currency-id, so currency switching only works when the page
                // exposes $currencies (hadrian renders real IDs in the modal partial).
                if (curr && curr.dataset.currencyId && curr.dataset.currencyId !== currentCurrId) {
                    url.searchParams.set('currency', curr.dataset.currencyId);
                    changed = true;
                }
                if (changed) {
                    window.location.href = url.toString();
                } else {
                    close();
                }
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

    // ── Affixed navigation (admin "Affixed Navigation" toggle) ─
    // Scroll-direction reveal: the top bar hides while scrolling DOWN and
    // returns on the first scroll UP. Gated on <body data-affixed-nav="1">;
    // all the showing/hiding is CSS (core-layout.css) keyed off the three
    // body classes set here, so this function only classifies scroll state.
    //
    // Deliberately different from Lagom's implementation in three ways:
    //   1. rAF-throttled on a passive scroll listener, instead of a 50ms
    //      setInterval that keeps polling for the life of the page even when
    //      nobody is scrolling.
    //   2. No element measuring, no body padding-top juggling and no resize
    //      recalculation — our bars stay position:sticky and are merely
    //      translated, so the document flow never changes.
    //   3. Bails out entirely when the page cannot scroll, so short pages
    //      never register a listener at all.
    function initAffixedNav() {
        if (document.body.dataset.affixedNav !== '1') return;

        var bar = document.querySelector('.topbar, .ph-side-topbar');
        if (!bar) return;

        // Ignore deltas smaller than the bar's own height: without this a
        // trackpad's sub-pixel jitter flips the state constantly.
        var threshold = Math.max(bar.offsetHeight, 44);
        var last = window.pageYOffset || 0;
        var ticking = false;

        function classify() {
            ticking = false;
            var y = window.pageYOffset || 0;
            var cl = document.body.classList;

            // At (or rubber-banded above) the top: always show.
            if (y <= 0) {
                cl.add('scrolled-top');
                cl.remove('scroll-down', 'scroll-up');
                last = 0;
                return;
            }
            if (Math.abs(y - last) < threshold) return;

            cl.remove('scrolled-top');
            // Never hide past the very end of the document — with the bar
            // gone there is nothing left to scroll back up to reveal it.
            var atEnd = (y + window.innerHeight) >= (document.documentElement.scrollHeight - 2);
            if (y > last && !atEnd) {
                cl.add('scroll-down');
                cl.remove('scroll-up');
            } else {
                cl.add('scroll-up');
                cl.remove('scroll-down');
            }
            last = y;
        }

        function onScroll() {
            if (ticking) return;
            ticking = true;
            window.requestAnimationFrame(classify);
        }

        window.addEventListener('scroll', onScroll, { passive: true });
        classify();
    }

    // ── "0.00" -> "Free" for JS-driven prices ──────────────
    // The server-rendered side is handled by includes/common/price.tpl and
    // PriceHelper. The order form is not reachable that way: its card prices
    // are rewritten client-side from data-price-<cycle> every time a visitor
    // clicks a billing-cycle pill, so a server-rendered label would be undone
    // on the first interaction. This covers those surfaces.
    //
    // Same digits-only test as the PHP and Smarty twins: strip every non-digit,
    // and treat it as free only when what remains is all zeros. Naturally
    // idempotent — the label itself contains no digits, so re-running can never
    // convert an already-converted element.
    function initFreePriceLabels() {
        if (document.body.dataset.freeLabel !== '1') return;

        var LABEL = document.body.dataset.freeLabelText || 'Free';
        var SELECTOR = '[data-price-display], .cp-cycle-price .amount';

        function isZero(text) {
            var digits = String(text).replace(/\D/g, '');
            return digits !== '' && !/[1-9]/.test(digits);
        }

        function apply(root) {
            var scope = root || document;
            var nodes = scope.querySelectorAll(SELECTOR);
            for (var i = 0; i < nodes.length; i++) {
                var el = nodes[i];
                var text = (el.textContent || '').trim();
                if (isZero(text)) el.textContent = LABEL;
            }
        }

        // Exposed so the cart's cycle-switcher can route its own writes through
        // the same test rather than duplicating it.
        window.hnFreePrice = { apply: apply, isZero: isZero, label: LABEL };
        apply();
    }

    // ── Dismissible notices ────────────────────────────────
    // [data-dismiss] with no value. Bootstrap ships on these pages but binds
    // [data-dismiss="alert"], so a valueless attribute matched nothing — the
    // X on the dashboard's overdue-invoice and expiring-domain notices was
    // styled as an interactive control (cursor:pointer plus a hover state) and
    // did nothing when clicked.
    function initDismissibles() {
        document.addEventListener('click', function (e) {
            var btn = e.target.closest ? e.target.closest('[data-dismiss]') : null;
            if (!btn) return;
            // Leave Bootstrap's own components alone.
            if (btn.getAttribute('data-dismiss')) return;
            e.preventDefault();
            var notice = btn.closest('.notice, .alert, .mt-notice') || btn.parentElement;
            if (notice) notice.remove();
        });
    }

    // ── Dark-mode logo swap ────────────────────────────────
    // Branding lets an admin upload a separate dark-surface logo; the templates
    // render it as data-logo-dark and nothing ever swapped it in, so the light
    // logo showed on dark backgrounds. Runs on load and again whenever the
    // theme changes, since the toggle flips <html data-theme> at runtime.
    function initLogoSwap() {
        var imgs = document.querySelectorAll('img[data-logo-dark]');
        if (!imgs.length) return;

        function apply() {
            var dark = document.documentElement.getAttribute('data-theme') === 'dark';
            for (var i = 0; i < imgs.length; i++) {
                var img = imgs[i];
                // Remember the light source the first time, so toggling back
                // does not need the template to re-render.
                if (!img.dataset.logoLight) img.dataset.logoLight = img.getAttribute('src') || '';
                var next = dark ? img.getAttribute('data-logo-dark') : img.dataset.logoLight;
                if (next && img.getAttribute('src') !== next) img.setAttribute('src', next);
            }
        }

        apply();
        new MutationObserver(apply).observe(document.documentElement, {
            attributes: true, attributeFilter: ['data-theme']
        });
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
            initAffixedNav();
            initFreePriceLabels();
            initDismissibles();
            initLogoSwap();
            document.dispatchEvent(new CustomEvent('hadrian-layout:ready'));
        });
    }

    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', boot);
    } else {
        boot();
    }
})();

/* ===== Accessibility helpers ==============================================
   docs/accessibility-hadrian-plan.md, phase 3. Generic behaviour for the
   widget patterns the theme uses, so each page does not need its own:

     dialogs     any open [role=dialog][aria-modal=true] (and Bootstrap
                 .modal): focus moves in, Tab stays inside, focus goes back to
                 the opener when it closes (WCAG 2.4.3, 2.1.2)
     menus       Escape returns focus to the button that opened the account
                 or notification menu
     sidebar     group toggles report aria-expanded (WCAG 4.1.2)
     top nav     dropdown buttons toggle on click, report aria-expanded, and
                 Escape dismisses a menu opened by hover or focus (1.4.13)
     rail        flyout state on the rail items, Escape closes it
     tabs        children of [role=tablist] become role=tab with
                 aria-selected from their .active class; arrows, Home, End
     radios      buttons in [role=radiogroup] become role=radio with
                 aria-checked from .active; arrows move the choice
     FAQ         checkbox-driven answers report aria-expanded and open with
                 Enter or Space
     tooltips    Escape hides a .cmp-tip shown by hover or focus
     dark mode   every switch reports aria-checked

   Each part watches the classes the existing scripts already toggle, so no
   page script had to change. */
(function () {
    'use strict';
    var FOCUSABLE = 'a[href], area[href], button:not([disabled]), input:not([disabled]):not([type="hidden"]), select:not([disabled]), textarea:not([disabled]), summary, [tabindex]:not([tabindex="-1"]), [contenteditable="true"]';
    var ACTIVE = function (el) {
        return el.classList.contains('active') || el.classList.contains('is-active') || el.getAttribute('aria-pressed') === 'true';
    };
    function shown(el) {
        if (!el || !el.isConnected || el.hidden || el.closest('[hidden]')) return false;
        var cs = getComputedStyle(el);
        if (cs.display === 'none' || cs.visibility === 'hidden') return false;
        var r = el.getBoundingClientRect();
        return r.width > 0 && r.height > 0;
    }
    function focusables(root) {
        return Array.prototype.filter.call(root.querySelectorAll(FOCUSABLE), function (e) {
            return !e.closest('[inert]') && shown(e);
        });
    }
    var uid = 0;
    function idFor(el, prefix) { if (!el.id) el.id = prefix + '-' + (++uid); return el.id; }
    function later(fn) { setTimeout(fn, 0); }

    // ---- dialogs ----------------------------------------------------------
    var DIALOGS = '[role="dialog"][aria-modal="true"], [role="alertdialog"], .modal[role="dialog"]';
    var openDialogs = [];           // [{ el, opener }] in opening order
    function checkDialogs() {
        var now = Array.prototype.filter.call(document.querySelectorAll(DIALOGS), shown);
        // Closed since last time: give focus back.
        openDialogs = openDialogs.filter(function (d) {
            if (now.indexOf(d.el) !== -1) return true;
            var a = document.activeElement;
            if ((!a || a === document.body || d.el.contains(a)) && d.opener && d.opener.isConnected && shown(d.opener)) {
                try { d.opener.focus(); } catch (e) {}
            }
            return false;
        });
        // Newly open: remember the opener, move focus in.
        now.forEach(function (el) {
            if (openDialogs.some(function (d) { return d.el === el; })) return;
            var opener = document.activeElement && document.activeElement !== document.body ? document.activeElement : null;
            openDialogs.push({ el: el, opener: opener });
            setTimeout(function () {
                if (el.contains(document.activeElement)) return;   // the page focused a field itself
                var target = el.querySelector('[autofocus]') || el.querySelector('[role="radio"][aria-checked="true"]') || focusables(el)[0];
                if (target) target.focus();
                else { el.setAttribute('tabindex', '-1'); el.focus(); }
            }, 40);
        });
    }
    var pending = false;
    function schedule() { if (pending) return; pending = true; setTimeout(function () { pending = false; checkDialogs(); syncAll(); }, 30); }
    document.addEventListener('keydown', function (e) {
        if (e.key !== 'Tab' || !openDialogs.length) return;
        var top = openDialogs[openDialogs.length - 1].el;
        var items = focusables(top);
        if (!items.length) { e.preventDefault(); return; }
        var first = items[0], last = items[items.length - 1];
        if (!top.contains(document.activeElement)) { e.preventDefault(); first.focus(); return; }
        if (e.shiftKey && document.activeElement === first) { e.preventDefault(); last.focus(); }
        else if (!e.shiftKey && document.activeElement === last) { e.preventDefault(); first.focus(); }
    });

    // ---- menus: Escape returns focus to their button ------------------------
    document.addEventListener('keydown', function (e) {
        if (e.key !== 'Escape') return;
        var a = document.activeElement;
        var wrap = a && a.closest && a.closest('.notification-wrapper, .profile-dropdown-wrapper');
        if (!wrap) return;
        var trigger = wrap.querySelector('[aria-haspopup]');
        if (trigger && trigger !== a) later(function () { trigger.focus(); });
    }, true);

    // ---- sidebar groups ------------------------------------------------------
    function syncSidebarGroups() {
        document.querySelectorAll('.sidebar-group').forEach(function (g) {
            var t = g.querySelector('.sidebar-group-toggle'), items = g.querySelector('.sidebar-group-items');
            if (!t) return;
            if (items) t.setAttribute('aria-controls', idFor(items, 'sbgroup'));
            t.setAttribute('aria-expanded', g.classList.contains('open') ? 'true' : 'false');
        });
    }

    // ---- top-nav dropdowns ---------------------------------------------------
    function initTopnav() {
        document.querySelectorAll('.nav-dropdown-wrap').forEach(function (wrap) {
            var t = wrap.querySelector('.nav-dropdown-toggle'), menu = wrap.querySelector('.nav-dropdown-menu');
            if (!t || !menu || t.dataset.a11y) return;
            t.dataset.a11y = '1';
            t.setAttribute('aria-controls', idFor(menu, 'navmenu'));
            function sync() {
                var open = !wrap.classList.contains('is-dismissed') &&
                    (wrap.classList.contains('is-open') || wrap.matches(':hover') || wrap.matches(':focus-within'));
                t.setAttribute('aria-expanded', open ? 'true' : 'false');
            }
            t.addEventListener('click', function (e) {
                e.preventDefault();
                var open = t.getAttribute('aria-expanded') === 'true' && !wrap.classList.contains('is-dismissed');
                wrap.classList.toggle('is-open', !open);
                wrap.classList.toggle('is-dismissed', open);
                sync();
            });
            wrap.addEventListener('mouseenter', function () { wrap.classList.remove('is-dismissed'); sync(); });
            wrap.addEventListener('mouseleave', function () { wrap.classList.remove('is-open'); later(sync); });
            wrap.addEventListener('focusin', sync);
            wrap.addEventListener('focusout', function () {
                later(function () {
                    if (!wrap.contains(document.activeElement)) wrap.classList.remove('is-open', 'is-dismissed');
                    sync();
                });
            });
            wrap.addEventListener('keydown', function (e) {
                if (e.key !== 'Escape' || t.getAttribute('aria-expanded') !== 'true') return;
                wrap.classList.add('is-dismissed');
                wrap.classList.remove('is-open');
                t.focus();
                sync();
            });
            sync();
        });
    }

    // ---- rail flyouts --------------------------------------------------------
    function syncRail() {
        var panel = document.querySelector('.ph-rail-panel');
        if (!panel) return;
        var open = document.body.classList.contains('rail-panel-open');
        document.querySelectorAll('.ph-rail-item[data-rail]').forEach(function (b) {
            b.setAttribute('aria-controls', idFor(panel, 'railpanel'));
            b.setAttribute('aria-expanded', open && b.classList.contains('active') ? 'true' : 'false');
        });
    }
    document.addEventListener('keydown', function (e) {
        if (e.key !== 'Escape' || !document.body.classList.contains('rail-panel-open')) return;
        var a = document.activeElement;
        if (!a || !a.closest || !a.closest('.ph-rail, .ph-rail-panel')) return;
        document.body.classList.remove('rail-panel-open');
        var item = document.querySelector('.ph-rail-item.active');
        if (item && a.closest('.ph-rail-panel')) item.focus();
        syncRail();
    });

    // ---- tabs and radio groups -----------------------------------------------
    function members(group, selector) {
        return Array.prototype.filter.call(group.querySelectorAll(selector), function (b) {
            return b.closest('[role="tablist"], [role="radiogroup"]') === group;
        });
    }
    function syncGroups() {
        document.querySelectorAll('[role="tablist"]').forEach(function (list) {
            var tabs = members(list, 'button, a, [role="tab"]');
            var any = tabs.some(ACTIVE);
            tabs.forEach(function (t, i) {
                if (!t.getAttribute('role')) t.setAttribute('role', 'tab');
                var on = any ? ACTIVE(t) : (t.getAttribute('aria-selected') === 'true' || (i === 0 && !tabs.some(function (x) { return x.getAttribute('aria-selected') === 'true'; })));
                t.setAttribute('aria-selected', on ? 'true' : 'false');
                t.setAttribute('tabindex', on ? '0' : '-1');
            });
        });
        document.querySelectorAll('[role="radiogroup"]').forEach(function (g) {
            var opts = members(g, 'button, [role="radio"]');
            if (!opts.length) return;
            var any = opts.some(ACTIVE);
            opts.forEach(function (o, i) {
                o.setAttribute('role', 'radio');
                var on = ACTIVE(o);
                o.setAttribute('aria-checked', on ? 'true' : 'false');
                o.setAttribute('tabindex', on || (!any && i === 0) ? '0' : '-1');
            });
        });
    }
    document.addEventListener('keydown', function (e) {
        var k = e.key;
        if (['ArrowLeft', 'ArrowRight', 'ArrowUp', 'ArrowDown', 'Home', 'End'].indexOf(k) === -1) return;
        var me = e.target;
        if (!me || !me.getAttribute || me.tagName === 'INPUT') return;
        var role = me.getAttribute('role');
        if (role !== 'tab' && role !== 'radio') return;
        var group = me.closest(role === 'tab' ? '[role="tablist"]' : '[role="radiogroup"]');
        if (!group) return;
        var list = members(group, '[role="' + role + '"]').filter(shown);
        var i = list.indexOf(me);
        if (i === -1) return;
        var next = k === 'Home' ? 0 : k === 'End' ? list.length - 1
            : (k === 'ArrowLeft' || k === 'ArrowUp') ? (i - 1 + list.length) % list.length : (i + 1) % list.length;
        e.preventDefault();
        list[next].focus();
        list[next].click();          // the page's own handler moves .active
        later(syncGroups);
    });

    // ---- FAQ answers driven by a checkbox -------------------------------------
    function syncFaq() {
        document.querySelectorAll('.faq-item').forEach(function (item) {
            var box = item.querySelector('.faq-toggle'), q = item.querySelector('.faq-question');
            if (box && q) q.setAttribute('aria-expanded', box.checked ? 'true' : 'false');
        });
    }
    document.addEventListener('change', function (e) { if (e.target.classList && e.target.classList.contains('faq-toggle')) syncFaq(); });
    document.addEventListener('keydown', function (e) {
        if (e.key !== 'Enter' && e.key !== ' ') return;
        var q = e.target.closest && e.target.closest('label.faq-question[role="button"]');
        if (!q) return;
        e.preventDefault();
        q.click();
    });

    // ---- tooltips: Escape hides one shown by hover or focus -------------------
    document.addEventListener('keydown', function (e) {
        if (e.key !== 'Escape') return;
        document.querySelectorAll('.cmp-tip:hover, .cmp-tip:focus').forEach(function (t) { t.classList.add('is-dismissed'); });
    });
    ['mouseleave', 'blur'].forEach(function (ev) {
        document.addEventListener(ev, function (e) {
            if (e.target.classList && e.target.classList.contains('cmp-tip')) e.target.classList.remove('is-dismissed');
        }, true);
    });

    // ---- dark mode switches ----------------------------------------------------
    function syncDarkSwitches() {
        var dark = document.documentElement.getAttribute('data-theme') === 'dark';
        document.querySelectorAll('[data-dark-toggle], #darkModeToggle').forEach(function (s) {
            s.classList.toggle('active', dark);
            if (s.getAttribute('role') === 'switch') s.setAttribute('aria-checked', dark ? 'true' : 'false');
        });
    }

    function syncAll() { syncSidebarGroups(); syncRail(); syncGroups(); syncFaq(); syncDarkSwitches(); }
    function boot() {
        initTopnav();
        syncAll();
        checkDialogs();
        new MutationObserver(function (list) {
            for (var i = 0; i < list.length; i++) {
                var m = list[i];
                // Our own writes (aria-*, tabindex, role, id) are not in the filter,
                // so they never trigger another round.
                if (m.type === 'attributes' || m.addedNodes.length || m.removedNodes.length) { schedule(); return; }
            }
        }).observe(document.documentElement, { subtree: true, childList: true, attributes: true, attributeFilter: ['class', 'hidden', 'style', 'data-theme', 'aria-pressed'] });
    }
    if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', boot);
    else boot();
})();
