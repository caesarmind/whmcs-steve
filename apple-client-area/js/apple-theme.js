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
