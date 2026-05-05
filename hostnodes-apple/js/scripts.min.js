/* ============================================================================
 * Hostnodes Apple — Theme JavaScript
 *
 * Vanilla DOM-first; jQuery is available via WHMCS core ($) for the bridge
 * sections at the bottom (pwstrength, modal, domain-search, fullpage-overlay).
 *
 * All IIFEs are idempotent — safe to reload without duplicate bindings.
 * ==========================================================================*/

/* ----------------------------------------------------------------------------
 * Dark mode — localStorage-backed with system preference fallback.
 * -------------------------------------------------------------------------- */
function toggleDarkMode() {
    var html = document.documentElement;
    var toggle = document.getElementById('darkModeToggle');
    var isDark = html.getAttribute('data-theme') === 'dark';
    if (isDark) {
        html.setAttribute('data-theme', 'light');
        if (toggle) toggle.classList.remove('active');
        try { localStorage.setItem('apple-theme', 'light'); } catch (e) {}
    } else {
        html.setAttribute('data-theme', 'dark');
        if (toggle) toggle.classList.add('active');
        try { localStorage.setItem('apple-theme', 'dark'); } catch (e) {}
    }
}

(function initTheme() {
    var saved = null;
    try { saved = localStorage.getItem('apple-theme'); } catch (e) {}
    if (saved === 'dark' || (!saved && window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches)) {
        document.documentElement.setAttribute('data-theme', 'dark');
        document.addEventListener('DOMContentLoaded', function() {
            var toggle = document.getElementById('darkModeToggle');
            if (toggle) toggle.classList.add('active');
        });
    }
})();

/* ----------------------------------------------------------------------------
 * Profile dropdown (topbar avatar).
 * -------------------------------------------------------------------------- */
function toggleProfileDropdown(e) {
    if (e) e.stopPropagation();
    var dropdown = document.getElementById('profileDropdown');
    if (dropdown) dropdown.classList.toggle('open');
    var notif = document.getElementById('notificationDropdown');
    if (notif) notif.classList.remove('open');
}

/* ----------------------------------------------------------------------------
 * Notification dropdown (topbar bell).
 * -------------------------------------------------------------------------- */
function toggleNotifications(e) {
    if (e) e.stopPropagation();
    var dropdown = document.getElementById('notificationDropdown');
    if (dropdown) dropdown.classList.toggle('open');
    var profile = document.getElementById('profileDropdown');
    if (profile) profile.classList.remove('open');
}

/* Close both dropdowns when clicking outside. */
document.addEventListener('click', function(e) {
    var profile = document.getElementById('profileDropdown');
    var pWrap = profile ? profile.parentElement : null;
    if (profile && pWrap && !pWrap.contains(e.target)) {
        profile.classList.remove('open');
    }
    var notif = document.getElementById('notificationDropdown');
    var nWrap = notif ? notif.parentElement : null;
    if (notif && nWrap && !nWrap.contains(e.target)) {
        notif.classList.remove('open');
    }
});

/* ----------------------------------------------------------------------------
 * Password visibility toggle.
 * Expects markup: .password-wrapper > input + button.password-toggle with two
 * icons (.eye-open, .eye-closed). Safe if either icon is missing.
 * -------------------------------------------------------------------------- */
document.addEventListener('click', function(e) {
    var btn = e.target.closest ? e.target.closest('.password-toggle') : null;
    if (!btn) return;
    var input = btn.parentElement ? btn.parentElement.querySelector('input') : null;
    if (!input) return;
    var isPassword = input.type === 'password';
    input.type = isPassword ? 'text' : 'password';
    var open = btn.querySelector('.eye-open');
    var closed = btn.querySelector('.eye-closed');
    if (open) open.style.display = isPassword ? 'none' : '';
    if (closed) closed.style.display = isPassword ? '' : 'none';
});

/* ----------------------------------------------------------------------------
 * Filter tabs — swap active state within the parent tab group.
 * -------------------------------------------------------------------------- */
document.addEventListener('click', function(e) {
    var tab = e.target.closest ? e.target.closest('.filter-tab') : null;
    if (!tab || !tab.parentElement) return;
    tab.parentElement.querySelectorAll('.filter-tab').forEach(function(t) { t.classList.remove('active'); });
    tab.classList.add('active');
});

/* ----------------------------------------------------------------------------
 * Card minimise (collapsible .card / sidebar cards).
 * Click the card header's chevron to toggle .minimised on the card.
 * -------------------------------------------------------------------------- */
document.addEventListener('click', function(e) {
    var chev = e.target.closest ? e.target.closest('.card-minimise') : null;
    if (!chev) return;
    var card = chev.closest('.card');
    if (card) card.classList.toggle('minimised');
});

/* ----------------------------------------------------------------------------
 * Mobile sidebar toggle (hamburger in topbar on small screens).
 * -------------------------------------------------------------------------- */
document.addEventListener('click', function(e) {
    var btn = e.target.closest ? e.target.closest('[data-toggle="sidebar"]') : null;
    if (!btn) return;
    document.body.classList.toggle('sidebar-open');
});

/* ============================================================================
 * jQuery bridge — the rest of this file assumes WHMCS has loaded jQuery 1.12+.
 * Guard every block with `if (window.jQuery)` so the theme still degrades
 * gracefully on static preview pages.
 * ==========================================================================*/
(function bridge() {
    if (!window.jQuery) return;
    var $ = window.jQuery;

    /* Password strength meter (WHMCS pwstrength.tpl hooks into this). */
    $(function() {
        if ($.fn.pwstrength) {
            $('.pwstrength').each(function() {
                $(this).pwstrength({
                    ui: { showVerdictsInsideProgressBar: true, showPopover: false }
                });
            });
        }
    });

    /* Popover init fallback (Bootstrap has been dropped, but WHMCS still emits
       data-toggle="popover" on some buttons). Render as a lightweight tooltip. */
    $(document).on('mouseenter', '[data-toggle="popover"], [data-toggle="tooltip"]', function() {
        var el = this;
        var title = el.getAttribute('title') || el.getAttribute('data-original-title') || '';
        if (!title) return;
        if (el.getAttribute('data-original-title') === null) {
            el.setAttribute('data-original-title', title);
            el.removeAttribute('title');
        }
        var existing = document.querySelector('.apple-tooltip');
        if (existing) existing.remove();
        var tip = document.createElement('div');
        tip.className = 'apple-tooltip';
        tip.textContent = el.getAttribute('data-original-title');
        document.body.appendChild(tip);
        var rect = el.getBoundingClientRect();
        tip.style.position = 'fixed';
        tip.style.top = (rect.top - tip.offsetHeight - 8) + 'px';
        tip.style.left = (rect.left + (rect.width - tip.offsetWidth) / 2) + 'px';
    });
    $(document).on('mouseleave', '[data-toggle="popover"], [data-toggle="tooltip"]', function() {
        var existing = document.querySelector('.apple-tooltip');
        if (existing) existing.remove();
    });

    /* Modal dismiss — replace Bootstrap's data-dismiss="modal". */
    $(document).on('click', '[data-dismiss="modal"]', function() {
        var modal = this.closest ? this.closest('.modal') : null;
        if (modal) modal.classList.remove('show', 'in', 'open');
    });

    /* Fullpage overlay (WHMCS shows this during AJAX waits). */
    window.showFullpageOverlay = function(msg) {
        var overlay = document.getElementById('fullpage-overlay');
        if (!overlay) return;
        overlay.classList.remove('w-hidden');
        var span = overlay.querySelector('.msg');
        if (span) span.textContent = msg || '';
    };
    window.hideFullpageOverlay = function() {
        var overlay = document.getElementById('fullpage-overlay');
        if (overlay) overlay.classList.add('w-hidden');
    };

    /* Select-driven navigation (used by WHMCS sidebar mobile-select). */
    window.selectChangeNavigate = function(select) {
        if (select && select.value) window.location.href = select.value;
    };
})();

/* ----------------------------------------------------------------------------
 * Draggable dropdown — any element with [data-drag-target] acts as a drag
 * handle for the target element. Used by the profile dropdown header so users
 * can move the panel out of the way when it covers something they want to see.
 * First drag "detaches" the panel from its anchor (switches to position:fixed)
 * so it stays where the user leaves it even after the menu re-opens.
 * Double-click the grip to snap back to the default anchored position.
 * -------------------------------------------------------------------------- */
(function dragHandler() {
    function detach(target) {
        if (target.classList.contains('dragged')) return;
        var rect = target.getBoundingClientRect();
        target.style.position = 'fixed';
        target.style.top = rect.top + 'px';
        target.style.left = rect.left + 'px';
        target.style.right = 'auto';
        target.style.margin = '0';
        target.classList.add('dragged');
    }
    function clamp(target, nextLeft, nextTop) {
        var vw = window.innerWidth, vh = window.innerHeight;
        var rect = target.getBoundingClientRect();
        return {
            left: Math.max(8, Math.min(nextLeft, vw - rect.width - 8)),
            top:  Math.max(8, Math.min(nextTop,  vh - rect.height - 8))
        };
    }

    document.addEventListener('mousedown', function(e) {
        var handle = e.target.closest ? e.target.closest('[data-drag-target]') : null;
        if (!handle) return;
        var target = document.querySelector(handle.getAttribute('data-drag-target'));
        if (!target) return;
        e.preventDefault();
        detach(target);
        var startX = e.clientX, startY = e.clientY;
        var startTop = parseFloat(target.style.top) || 0;
        var startLeft = parseFloat(target.style.left) || 0;
        function onMove(ev) {
            var pos = clamp(target, startLeft + (ev.clientX - startX), startTop + (ev.clientY - startY));
            target.style.left = pos.left + 'px';
            target.style.top = pos.top + 'px';
        }
        function onUp() {
            document.removeEventListener('mousemove', onMove);
            document.removeEventListener('mouseup', onUp);
            document.body.style.userSelect = '';
        }
        document.body.style.userSelect = 'none';
        document.addEventListener('mousemove', onMove);
        document.addEventListener('mouseup', onUp);
    });

    document.addEventListener('touchstart', function(e) {
        var handle = e.target.closest ? e.target.closest('[data-drag-target]') : null;
        if (!handle || e.touches.length !== 1) return;
        var target = document.querySelector(handle.getAttribute('data-drag-target'));
        if (!target) return;
        detach(target);
        var t0 = e.touches[0];
        var startX = t0.clientX, startY = t0.clientY;
        var startTop = parseFloat(target.style.top) || 0;
        var startLeft = parseFloat(target.style.left) || 0;
        function onMove(ev) {
            if (ev.touches.length !== 1) return;
            var t = ev.touches[0];
            var pos = clamp(target, startLeft + (t.clientX - startX), startTop + (t.clientY - startY));
            target.style.left = pos.left + 'px';
            target.style.top = pos.top + 'px';
            ev.preventDefault();
        }
        function onEnd() {
            document.removeEventListener('touchmove', onMove);
            document.removeEventListener('touchend', onEnd);
        }
        document.addEventListener('touchmove', onMove, { passive: false });
        document.addEventListener('touchend', onEnd);
    }, { passive: true });

    document.addEventListener('dblclick', function(e) {
        var grip = e.target.closest ? e.target.closest('.profile-dropdown-grip') : null;
        if (!grip) return;
        var dropdown = grip.closest('.profile-dropdown');
        if (!dropdown) return;
        dropdown.classList.remove('dragged');
        dropdown.style.cssText = '';
    });
})();
