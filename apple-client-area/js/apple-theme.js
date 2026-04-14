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

// Testimonial card carousel — dots + arrows + auto-advance
(function() {
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
            cards[idx].scrollIntoView({ behavior: 'smooth', block: 'nearest', inline: 'start' });
            dots.forEach(function(d, j) { d.classList.toggle('active', j === idx); });
        }
        dots.forEach(function(d, i) { d.addEventListener('click', function() { goTo(i); }); });
        if (prevBtn) prevBtn.addEventListener('click', function() { goTo(idx - 1); });
        if (nextBtn) nextBtn.addEventListener('click', function() { goTo(idx + 1); });
        var timer = setInterval(function() { goTo(idx + 1); }, 5000);
        section.addEventListener('mouseenter', function() { clearInterval(timer); });
        section.addEventListener('mouseleave', function() { timer = setInterval(function() { goTo(idx + 1); }, 5000); });
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
