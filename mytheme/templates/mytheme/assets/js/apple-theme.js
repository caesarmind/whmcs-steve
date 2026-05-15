/* ============================================
   WHMCS by Apple — Shared JavaScript
   ============================================ */

// Dynamic greeting based on time of day
(function() {
    const hour = new Date().getHours();
    let greeting;
    if (hour < 12) greeting = 'Good morning';
    else if (hour < 17) greeting = 'Good afternoon';
    else greeting = 'Good evening';

    const el = document.getElementById('greetingTitle');
    if (el) el.textContent = greeting + ', Alex.';
})();

// Profile dropdown toggle
function toggleProfileDropdown(e) {
    e.stopPropagation();
    const dropdown = document.getElementById('profileDropdown');
    dropdown.classList.toggle('open');
}

// Close dropdown on outside click
document.addEventListener('click', function(e) {
    const dropdown = document.getElementById('profileDropdown');
    const wrapper = dropdown ? dropdown.parentElement : null;
    if (dropdown && wrapper && !wrapper.contains(e.target)) {
        dropdown.classList.remove('open');
    }
});

// Dark mode toggle
function toggleDarkMode() {
    const html = document.documentElement;
    const toggle = document.getElementById('darkModeToggle');
    const isDark = html.getAttribute('data-theme') === 'dark';

    if (isDark) {
        html.setAttribute('data-theme', 'light');
        toggle.classList.remove('active');
        localStorage.setItem('apple-theme', 'light');
    } else {
        html.setAttribute('data-theme', 'dark');
        toggle.classList.add('active');
        localStorage.setItem('apple-theme', 'dark');
    }
}

// Theme initialization — check localStorage first, then system preference
(function() {
    const saved = localStorage.getItem('apple-theme');
    if (saved === 'dark' || (!saved && window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches)) {
        document.documentElement.setAttribute('data-theme', 'dark');
        const toggle = document.getElementById('darkModeToggle');
        if (toggle) toggle.classList.add('active');
    }
})();

// Active sidebar state — auto-detect from current page filename
(function() {
    const path = window.location.pathname;
    const filename = path.substring(path.lastIndexOf('/') + 1).replace('.html', '');

    const map = {
        'clientareahome': 'nav-dashboard',
        'clientareaproducts': 'nav-services',
        'clientareaproductdetails': 'nav-services',
        'clientareadomains': 'nav-domains',
        'clientareadomaindetails': 'nav-domains',
        'clientareainvoices': 'nav-invoices',
        'viewinvoice': 'nav-invoices',
        'supportticketslist': 'nav-tickets',
        'supportticketsubmit': 'nav-tickets',
        'viewticket': 'nav-tickets',
        'knowledgebase': 'nav-kb',
        'knowledgebasecat': 'nav-kb',
        'knowledgebasearticle': 'nav-kb',
        'viewannouncement': 'nav-announcements',
        'announcements': 'nav-announcements',
        'clientareadetails': 'nav-details',
        'clientareasecurity': 'nav-security',
    };

    // Remove all active states
    document.querySelectorAll('.sidebar-item.active').forEach(el => el.classList.remove('active'));

    // Set active state
    const navId = map[filename];
    if (navId) {
        const el = document.getElementById(navId);
        if (el) el.classList.add('active');
    }
})();

// Password visibility toggle
document.addEventListener('click', function(e) {
    const btn = e.target.closest('.password-toggle');
    if (!btn) return;
    const input = btn.parentElement.querySelector('input');
    if (input) {
        const isPassword = input.type === 'password';
        input.type = isPassword ? 'text' : 'password';
        btn.querySelector('.eye-open').style.display = isPassword ? 'none' : 'block';
        btn.querySelector('.eye-closed').style.display = isPassword ? 'block' : 'none';
    }
});

// Filter tabs
document.addEventListener('click', function(e) {
    const tab = e.target.closest('.filter-tab');
    if (!tab) return;
    const parent = tab.parentElement;
    parent.querySelectorAll('.filter-tab').forEach(t => t.classList.remove('active'));
    tab.classList.add('active');
});

// Notification dropdown toggle
function toggleNotifications(e) {
    e.stopPropagation();
    var dropdown = document.getElementById('notificationDropdown');
    if (dropdown) dropdown.classList.toggle('open');
    // Close profile dropdown if open
    var profile = document.getElementById('profileDropdown');
    if (profile) profile.classList.remove('open');
}

// Update the outside-click handler to also close notifications
(function() {
    document.addEventListener('click', function(e) {
        var nd = document.getElementById('notificationDropdown');
        var nw = nd ? nd.parentElement : null;
        if (nd && nw && !nw.contains(e.target)) {
            nd.classList.remove('open');
        }
    });
})();

// Billing toggle (monthly / annual)
document.addEventListener('click', function(e) {
    var btn = e.target.closest('.hp-billing-toggle button');
    if (!btn) return;
    var toggle = btn.parentElement;
    toggle.querySelectorAll('button').forEach(function(b) { b.classList.remove('active'); });
    btn.classList.add('active');
    var cycle = btn.getAttribute('data-cycle');
    var section = toggle.closest('.hp-pricing-toggle-section');
    if (section) {
        section.querySelectorAll('[data-monthly][data-annual]').forEach(function(el) {
            el.textContent = el.getAttribute('data-' + cycle);
        });
    }
});

// Testimonial card carousel — dots + arrows + auto-advance (only when visible)
(function() {
    // Skip auto-advance on pages that showcase components (gallery, styleguide)
    var isShowcase = /components\.html|styleguide\.html/.test(location.pathname);

    document.querySelectorAll('.hp-testimonials-grid').forEach(function(section) {
        var strip = section.querySelector('.hp-testimonial-cards');
        var dots = section.querySelectorAll('.carousel-dot');
        var prevBtn = section.querySelector('.carousel-arrow.prev');
        var nextBtn = section.querySelector('.carousel-arrow.next');
        if (!strip) return;
        var cards = strip.querySelectorAll('.hp-testimonial-card');
        var idx = 0;
        function goTo(i) {
            idx = ((i % cards.length) + cards.length) % cards.length;
            var card = cards[idx];
            var stripRect = strip.getBoundingClientRect();
            var cardRect = card.getBoundingClientRect();
            var delta = cardRect.left - stripRect.left;
            strip.scrollTo({ left: strip.scrollLeft + delta, behavior: 'smooth' });
            dots.forEach(function(d, j) { d.classList.toggle('active', j === idx); });
        }
        dots.forEach(function(d, i) { d.addEventListener('click', function() { goTo(i); }); });
        if (prevBtn) prevBtn.addEventListener('click', function() { goTo(idx - 1); });
        if (nextBtn) nextBtn.addEventListener('click', function() { goTo(idx + 1); });

        // Auto-advance only when in viewport + not hovering + not on showcase pages
        if (isShowcase) return;
        var timer = null;
        var hovered = false;
        var visible = false;
        function tick() { if (visible && !hovered) goTo(idx + 1); }
        function start() { if (!timer) timer = setInterval(tick, 5000); }
        function stop() { if (timer) { clearInterval(timer); timer = null; } }
        section.addEventListener('mouseenter', function() { hovered = true; });
        section.addEventListener('mouseleave', function() { hovered = false; });
        if ('IntersectionObserver' in window) {
            var io = new IntersectionObserver(function(entries) {
                entries.forEach(function(e) { visible = e.isIntersecting; visible ? start() : stop(); });
            }, { threshold: 0.3 });
            io.observe(section);
        } else {
            start();
        }
    });
    // Dark scroll carousel — arrow navigation
    document.querySelectorAll('.hp-testimonials-scroll').forEach(function(section) {
        var strip = section.querySelector('.hp-testimonials-strip');
        var prevBtn = section.querySelector('.carousel-arrow.prev');
        var nextBtn = section.querySelector('.carousel-arrow.next');
        if (!strip || !prevBtn) return;
        prevBtn.addEventListener('click', function() { strip.scrollBy({ left: -380, behavior: 'smooth' }); });
        nextBtn.addEventListener('click', function() { strip.scrollBy({ left: 380, behavior: 'smooth' }); });
    });
})();

// Drag-to-scroll for all carousels
(function() {
    var targets = document.querySelectorAll('.hp-testimonial-cards, .hp-testimonials-strip');
    targets.forEach(function(el) {
        var isDown = false, startX, scrollLeft;
        el.addEventListener('mousedown', function(e) {
            isDown = true; el.classList.add('dragging');
            startX = e.pageX - el.offsetLeft;
            scrollLeft = el.scrollLeft;
        });
        el.addEventListener('mouseleave', function() { isDown = false; el.classList.remove('dragging'); });
        el.addEventListener('mouseup', function() { isDown = false; el.classList.remove('dragging'); });
        el.addEventListener('mousemove', function(e) {
            if (!isDown) return;
            e.preventDefault();
            var x = e.pageX - el.offsetLeft;
            el.scrollLeft = scrollLeft - (x - startX);
        });
        // Touch support
        el.addEventListener('touchstart', function(e) {
            startX = e.touches[0].pageX - el.offsetLeft;
            scrollLeft = el.scrollLeft;
        }, { passive: true });
        el.addEventListener('touchmove', function(e) {
            var x = e.touches[0].pageX - el.offsetLeft;
            el.scrollLeft = scrollLeft - (x - startX);
        }, { passive: true });
    });
})();

// Feature tabs — click to switch active panel
(function() {
    document.querySelectorAll('.hp-feature-tabs').forEach(function(section) {
        var tabs = section.querySelectorAll('.hp-ft-tab');
        var panels = section.querySelectorAll('.hp-ft-panel');
        if (!tabs.length || !panels.length) return;
        tabs.forEach(function(tab, i) {
            tab.addEventListener('click', function() {
                tabs.forEach(function(t) { t.classList.remove('active'); });
                panels.forEach(function(p) { p.classList.remove('active'); });
                tab.classList.add('active');
                if (panels[i]) panels[i].classList.add('active');
            });
        });
    });
})();

// Financing pricing — toggle active option
(function() {
    document.querySelectorAll('.hp-pricing-finance').forEach(function(section) {
        var opts = section.querySelectorAll('.hp-finance-opt');
        opts.forEach(function(opt) {
            opt.addEventListener('click', function() {
                opts.forEach(function(o) { o.classList.remove('active'); });
                opt.classList.add('active');
            });
        });
    });
})();

// FAQ tabbed categories — switch panels
(function() {
    document.querySelectorAll('.hp-faq-tabs-section').forEach(function(section) {
        var cats = section.querySelectorAll('.hp-faq-cat');
        var panels = section.querySelectorAll('.hp-faq-cat-panel');
        if (!cats.length || !panels.length) return;
        cats.forEach(function(cat, i) {
            cat.addEventListener('click', function() {
                cats.forEach(function(c) { c.classList.remove('active'); });
                panels.forEach(function(p) { p.classList.remove('active'); });
                cat.classList.add('active');
                if (panels[i]) panels[i].classList.add('active');
            });
        });
    });
})();

// Product subnav — highlight active section on scroll
(function() {
    var subnav = document.querySelector('.homepage-subnav');
    if (!subnav) return;
    var links = subnav.querySelectorAll('.subnav-link[href^="#"]');
    if (!links.length) return;
    var items = [];
    links.forEach(function(link) {
        var id = link.getAttribute('href').slice(1);
        var target = document.getElementById(id);
        if (target) items.push({ link: link, target: target, id: id });
    });
    if (!items.length) return;

    function update() {
        var threshold = window.innerHeight * 0.35;
        var activeId = items[0].id;
        for (var i = 0; i < items.length; i++) {
            var top = items[i].target.getBoundingClientRect().top;
            if (top <= threshold) activeId = items[i].id;
        }
        items.forEach(function(it) {
            it.link.classList.toggle('active', it.id === activeId);
        });
    }

    var ticking = false;
    window.addEventListener('scroll', function() {
        if (!ticking) {
            requestAnimationFrame(function() { update(); ticking = false; });
            ticking = true;
        }
    }, { passive: true });
    window.addEventListener('resize', update, { passive: true });
    // Immediate activation on click (don't wait for scroll animation)
    items.forEach(function(it) {
        it.link.addEventListener('click', function() {
            items.forEach(function(other) {
                other.link.classList.toggle('active', other.id === it.id);
            });
        });
    });
    update();
})();

// Announcement notice — dismiss on X click
(function() {
    document.querySelectorAll('.hp-announce-notice .announce-notice-close').forEach(function(btn) {
        btn.addEventListener('click', function() {
            var notice = btn.closest('.hp-announce-notice');
            if (!notice) return;
            notice.style.transition = 'opacity 0.2s, transform 0.2s';
            notice.style.opacity = '0';
            notice.style.transform = 'scale(0.96)';
            setTimeout(function() { notice.style.display = 'none'; }, 200);
        });
    });
})();

// Compare table — collapsible feature sections
(function() {
    document.querySelectorAll('.hp-pricing-compare-table').forEach(function(table) {
        table.querySelectorAll('.cmp-section-toggle').forEach(function(btn) {
            btn.addEventListener('click', function() {
                var row = btn.closest('.cmp-section-row');
                if (!row) return;
                var section = row.getAttribute('data-section');
                var expanded = btn.getAttribute('aria-expanded') === 'true';
                btn.setAttribute('aria-expanded', expanded ? 'false' : 'true');
                table.querySelectorAll('tr[data-group="' + section + '"]').forEach(function(r) {
                    r.classList.toggle('cmp-hidden', expanded);
                });
            });
        });
    });
})();

// Newsletter form — fake submit
(function() {
    document.querySelectorAll('.hp-newsletter-form').forEach(function(form) {
        form.addEventListener('submit', function(e) {
            e.preventDefault();
            var btn = form.querySelector('button');
            var orig = btn.textContent;
            btn.textContent = 'Subscribed ✓';
            btn.disabled = true;
            setTimeout(function() { btn.textContent = orig; btn.disabled = false; form.reset(); }, 2500);
        });
    });
})();

// Apple --* CSS variables for nexus_cart Vue SPA
//
// Lives here (vs the cart TPL) because WHMCS's cart page render strips
// any <script src="..."> we add inside viewcart.tpl when the page is
// served with mytheme's full layout shell. apple-theme.js is loaded
// globally by mytheme on every page including the cart, so this IIFE
// reliably sets the unprefixed --* variables on document.documentElement
// before nexus_cart's main.min.js initializes its Vue Shadow DOM.
//
// nexus_cart's auto-loaded custom.css does --vl-primary: var(--primary)
// etc. on :host, :root -- so by populating the unprefixed layer here,
// every --vl-* downstream resolves to the Apple light palette and
// inherits through the open Shadow DOM into every Vue component.
//
// Harmless on non-cart pages: the variables are new names that don't
// collide with mytheme's existing --color-* / --color-accent surface,
// and nothing outside the cart SPA reads them.
(function () {
    var s = document.documentElement.style;
    var v = {
        // Primary / status (Apple system colors)
        'primary':            '#0071e3',
        'primary-lifted':     '#0077ed',
        'primary-accented':   '#005bb5',
        'secondary':          '#f5f5f7',
        'secondary-lifted':   '#ebebef',
        'secondary-accented': '#e8e8ed',
        'success':            '#34c759',
        'success-lifted':     '#30b751',
        'success-accented':   '#2aa24a',
        'info':               '#0071e3',
        'info-lifted':        '#0077ed',
        'info-accented':      '#005bb5',
        'notice':             '#ff9f0a',
        'notice-lifted':      '#ff8e00',
        'notice-accented':    '#e07a00',
        'warning':            '#ff9500',
        'warning-lifted':     '#f08a00',
        'warning-accented':   '#d97a00',
        'error':              '#ff3b30',
        'error-lifted':       '#ef352b',
        'error-accented':     '#d62d24',

        // Grayscale / neutral
        'grayscale':          '#1d1d1f',
        'grayscale-lifted':   '#2c2c2e',
        'grayscale-accented': '#000000',
        'neutral':            '#6e6e73',
        'neutral-lifted':     '#86868b',
        'neutral-accented':   '#4a4a4f',

        // Text / border / background hierarchy
        'text':               '#1d1d1f',
        'text-lifted':        '#6e6e73',
        'text-accented':      '#000000',
        'text-muted':         '#86868b',
        'text-inverted':      '#ffffff',

        'border':             '#e8e8ed',
        'border-muted':       '#f0f0f5',
        'border-lifted':      '#d2d2d7',
        'border-accented':    '#1d1d1f',

        'bg':                 '#fbfbfd',
        'bg-muted':           '#f5f5f7',
        'bg-lifted':          '#ffffff',
        'bg-accented':        '#fafafa',
        'bg-inverted':        '#1d1d1f',

        // Typography (Apple SF Pro sizing)
        'text-xs':            '11.5px',
        'text-sm':            '13px',
        'text-md':            '15px',
        'text-lg':            '17px',

        // Spacing / focus rings
        'outline-sm':         '2px',
        'outline-md':         '3px',
        'outline-lg':         '4px',

        // Rounding -- Apple uses generous rounding + pills
        'rounding-sm':        '8px',
        'rounding-md':        '12px',
        'rounding-lg':        '999px',

        'letter-spacing':     '-0.008em',
        'disabled-opacity':   '0.5'
    };
    for (var k in v) s.setProperty('--' + k, v[k]);
})();

// Cart page chrome + Shadow DOM Apple-tuning for /cart.php?a=view
//
// 1. Page chrome (header + 5-step strip): injected via JS rather than
//    mytheme_cart/viewcart.tpl because WHMCS strips arbitrary HTML from
//    cart TPL output when the page is rendered with mytheme's full
//    layout cookies. Verified live: anonymous CLI fetch sees the
//    markup, browser-with-session render does not.
//
// 2. Shadow DOM stylesheet adoption: the Nexus SPA's compiled :host
//    rule overrides our cascaded --vl-rounding-*, --vl-text-*,
//    --vl-outline-*, --vl-letter-spacing, --vl-disabled-opacity --
//    these get the SPA's defaults regardless of what we set on
//    documentElement. Use Constructable Stylesheets + adoptedStyleSheets
//    to inject a sheet INSIDE the shadow that wins via !important.
//    Only --vl-* names not in our injected sheet keep nexus's mapping
//    from custom.css (which already gives us the right colors).
//
// Both run only when #nexus-root exists, so this whole block is a
// no-op everywhere else mytheme is loaded.
(function () {
    var SHADOW_OVERRIDES = ':host{' +
        // Apple card-style rounding. The SPA maps Tailwind's
        // rounded-{sm,md,large} -> --vl-rounding-{sm,md,lg}, and the
        // product / summary / promo cards all use rounded-large -- so
        // we deliberately keep --vl-rounding-lg at Apple's CARD size
        // (~14px), NOT pill (999px), or the cards become stadium shaped.
        '--vl-rounding-sm: 6px !important;' +
        '--vl-rounding-md: 10px !important;' +
        '--vl-rounding-lg: 14px !important;' +
        // Apple SF Pro typography sizing -- bumped from nexus defaults
        // (0.625/0.75/0.875/1rem) to mockup-matching 11.5/13/14/15px
        '--vl-text-xs: 11.5px !important;' +
        '--vl-text-sm: 13px !important;' +
        '--vl-text-md: 14px !important;' +
        '--vl-text-lg: 15px !important;' +
        // Apple SF Pro tracking
        '--vl-letter-spacing: -0.008em !important;' +
        // Focus ring widths (subtle Apple)
        '--vl-outline-sm: 2px !important;' +
        '--vl-outline-md: 3px !important;' +
        '--vl-outline-lg: 4px !important;' +
        '--vl-disabled-opacity: 50% !important;' +
    '}';

    function injectShadowSheet() {
        var mount = document.getElementById('nexus-root');
        if (!mount) return false;
        var sh = mount.shadowRoot;
        if (!sh) return false; // SPA hasn't mounted yet
        if (mount.dataset.appleSheetInjected) return true; // re-entry guard
        if (!('adoptedStyleSheets' in sh) || typeof CSSStyleSheet === 'undefined' ||
            !CSSStyleSheet.prototype.replaceSync) return false;
        try {
            var sheet = new CSSStyleSheet();
            sheet.replaceSync(SHADOW_OVERRIDES);
            sh.adoptedStyleSheets = [].concat(sh.adoptedStyleSheets || [], sheet);
            mount.dataset.appleSheetInjected = '1';
            return true;
        } catch (e) {
            return false;
        }
    }

    // Poll until the SPA mounts its shadow root (Vue async mount).
    // Stops as soon as injection succeeds; gives up after ~10s.
    function startShadowWatch() {
        var attempts = 0;
        var iv = setInterval(function () {
            if (injectShadowSheet() || ++attempts > 100) clearInterval(iv);
        }, 100);
    }

    function init() {
        var mount = document.getElementById('nexus-root');
        if (!mount) return;
        startShadowWatch();
        if (document.querySelector('.vc-page-header')) return; // chrome re-entry guard
        var orderWrap = document.getElementById('order-standard_cart') || mount.parentElement;
        if (!orderWrap || !orderWrap.parentElement) return;

        var checkSvg = '<svg width="10" height="10" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3.2" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"/></svg>';
        var arrowSvg = '<svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="5" y1="12" x2="19" y2="12"/><polyline points="12 5 5 12 12 19"/></svg>';

        var header = document.createElement('header');
        header.className = 'vc-page-header';
        header.innerHTML =
            '<div>' +
                '<h1>Your cart</h1>' +
                '<p class="vc-sub">Review the items in your cart, apply a promo code, and head to checkout.</p>' +
            '</div>' +
            '<a href="/cart.php" class="vc-browse-btn">' + arrowSvg + 'Browse products &amp; services</a>';

        var steps = document.createElement('div');
        steps.className = 'vc-steps';
        steps.setAttribute('aria-label', 'Checkout progress');
        steps.innerHTML =
            '<span class="vc-step done"><span class="vc-step-num">' + checkSvg + '</span>Choose plan</span>' +
            '<span class="vc-step-sep">›</span>' +
            '<span class="vc-step done"><span class="vc-step-num">' + checkSvg + '</span>Domain</span>' +
            '<span class="vc-step-sep">›</span>' +
            '<span class="vc-step done"><span class="vc-step-num">' + checkSvg + '</span>Configure</span>' +
            '<span class="vc-step-sep">›</span>' +
            '<span class="vc-step active"><span class="vc-step-num">4</span>Cart</span>' +
            '<span class="vc-step-sep">›</span>' +
            '<span class="vc-step"><span class="vc-step-num">5</span>Checkout</span>';

        orderWrap.parentElement.insertBefore(header, orderWrap);
        orderWrap.parentElement.insertBefore(steps, orderWrap);
    }
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', init);
    } else {
        init();
    }
})();
