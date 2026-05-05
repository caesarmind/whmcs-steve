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
        applySubnav(params.get('subnav') || savedSubnav || 'on');
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

        // Hide the Services chip on pages without a stack that uses this toggle.
        if (!document.querySelector('.svc-table-card, .dom-list-card, .inv-table-card, .tk-table-card, .pd3-stack')) {
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
        applyData(params.get('data') || savedData || 'full');
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

    // ── Bootstrap ──────────────────────────────────────────
    function boot() {
        var params = new URLSearchParams(window.location.search);
        return loadPartials().then(function () {
            var chip = document.querySelector('.state-chip');
            if (chip) initChipDrag(chip);
            initStateToggles(params);
            initDropdowns();
            initSidebarGroups();
            initRail();
            initPromoSliders();
            initLocaleModal();
            applyActiveNav();
            applyPageTitle();
            document.dispatchEvent(new CustomEvent('apple-layout:ready'));
        });
    }

    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', boot);
    } else {
        boot();
    }
})();
