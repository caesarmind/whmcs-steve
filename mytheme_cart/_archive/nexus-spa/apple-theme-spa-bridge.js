/*
 * mytheme_cart/_archive/nexus-spa/apple-theme-spa-bridge.js
 *
 * ARCHIVED — NOT LOADED ANYWHERE.
 *
 * Two IIFEs that previously lived at the bottom of
 * mytheme/templates/mytheme/assets/js/apple-theme.js to bridge mytheme's
 * Apple visual language into nexus_cart's WHMCS-shipped Vue SPA. Removed
 * when /cart.php?a=view was reverted to the Smarty-rendered viewcart.tpl
 * (commit 8cd392a) for pixel-faithful mockup match.
 *
 * Kept as reference in case we ever want to reconsider the SPA path:
 *
 *   IIFE #1 -- Apple --* CSS variable seeder
 *     Sets unprefixed --primary / --bg / --text / --rounding-* etc. on
 *     document.documentElement. nexus_cart's auto-loaded custom.css
 *     does --vl-primary: var(--primary) on :host, :root, so populating
 *     the unprefixed layer cascades the Apple light palette into the
 *     SPA's open Shadow DOM via custom-property inheritance.
 *
 *   IIFE #2 -- Page chrome + Shadow DOM Apple-tuning
 *     a) Injects <header.vc-page-header> + <div.vc-steps> 5-step strip
 *        ABOVE the SPA mount (because WHMCS sanitizes that markup out
 *        of cart TPL output for authenticated sessions).
 *     b) Adopts a Constructable Stylesheet INSIDE the shadow DOM via
 *        adoptedStyleSheets to override --vl-rounding-* / --vl-text-* /
 *        --vl-letter-spacing / --vl-outline-* with Apple values that
 *        beat the SPA's compiled :host defaults.
 *     c) Walks the shadow DOM and tags duplicate UI elements (the SPA's
 *        own "Shopping Cart" h1, "Shopping Cart > Checkout" inner
 *        breadcrumb, and "Browse Products & Services" back-arrow row)
 *        with data-apple-hide for the [data-apple-hide]{display:none}
 *        rule in the same adopted stylesheet.
 *     d) MutationObserver re-tags on Vue re-render (debounced via RAF).
 *
 * To re-enable:
 *   1. Move both IIFEs back to the bottom of
 *      mytheme/templates/mytheme/assets/js/apple-theme.js
 *   2. Restore mytheme_cart/viewcart.tpl from this archive's
 *      viewcart.spa-shell.tpl (or revert mytheme_cart/viewcart.tpl
 *      to commit 80139ad / 16819e2 / 00cfe4f -- the SPA-shell history).
 *   3. Bump mytheme/templates/mytheme/core/mytheme.php version so
 *      cached apple-theme.js refreshes.
 */

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
    '}' +
    // Hide elements we tag with data-apple-hide via tagShadowElements()
    // below. Targets the duplicate "Shopping Cart" h1, the inner
    // Shopping Cart > Checkout breadcrumb, and the SPA's own
    // "Browse Products & Services" back-arrow link (we already render
    // a Browse pill in the page-level vc-page-header).
    '[data-apple-hide]{display:none !important;}';

    // Walk the SPA's open shadow DOM and tag elements we want hidden
    // with data-apple-hide. Targeting by structural / text matching
    // rather than the SPA's minified Tailwind class names so future
    // nexus_cart bundle updates don't silently break our overrides.
    function tagShadowElements(sh) {
        // 1. Duplicate "Shopping Cart" h1 (text-2xl div with exactly
        //    that text content -- avoids accidentally hiding the
        //    "Order Summary" h1 which shares the same Tailwind classes)
        sh.querySelectorAll('div').forEach(function (d) {
            var direct = Array.from(d.childNodes)
                .filter(function (c) { return c.nodeType === 3 && c.textContent.trim(); })
                .map(function (c) { return c.textContent.trim(); })
                .join('|');
            if (direct === 'Shopping Cart' && /text-2xl/.test(d.className || '')) {
                d.setAttribute('data-apple-hide', 'duplicate-h1');
            }
            // Inner breadcrumb container: parent of a div whose only
            // text-content child is "Checkout", with exactly 3 sibling
            // children (Shopping Cart link + > separator + Checkout).
            if (direct === 'Checkout' && d.parentElement &&
                d.parentElement.children.length === 3) {
                d.parentElement.setAttribute('data-apple-hide', 'inner-breadcrumb');
            }
        });
        // 2. SPA's "Browse Products & Services" back-arrow link --
        //    we render an equivalent pill in vc-page-header above.
        //    Tag the PARENT row (which also contains the chevron SVG
        //    sibling) so we don't leave the icon orphaned next to a
        //    hidden link.
        sh.querySelectorAll('a').forEach(function (a) {
            if ((a.textContent || '').trim() === 'Browse Products & Services') {
                var row = a.parentElement;
                if (row && row.children.length === 2) {
                    row.setAttribute('data-apple-hide', 'spa-browse-row');
                } else {
                    a.setAttribute('data-apple-hide', 'spa-browse-link');
                }
            }
        });
    }

    function injectShadowSheet() {
        var mount = document.getElementById('nexus-root');
        if (!mount) return false;
        var sh = mount.shadowRoot;
        if (!sh) return false; // SPA hasn't mounted yet
        if (mount.dataset.appleSheetInjected) {
            tagShadowElements(sh); // re-tag on subsequent calls (Vue may have re-rendered)
            return true;
        }
        if (!('adoptedStyleSheets' in sh) || typeof CSSStyleSheet === 'undefined' ||
            !CSSStyleSheet.prototype.replaceSync) return false;
        try {
            var sheet = new CSSStyleSheet();
            sheet.replaceSync(SHADOW_OVERRIDES);
            sh.adoptedStyleSheets = [].concat(sh.adoptedStyleSheets || [], sheet);
            mount.dataset.appleSheetInjected = '1';
            tagShadowElements(sh);
            // MutationObserver re-tags when Vue re-renders (debounced via
            // requestAnimationFrame to avoid thrashing on every tick).
            if (typeof MutationObserver !== 'undefined') {
                var pending = false;
                var observer = new MutationObserver(function () {
                    if (pending) return;
                    pending = true;
                    requestAnimationFrame(function () {
                        pending = false;
                        tagShadowElements(sh);
                    });
                });
                observer.observe(sh, { childList: true, subtree: true });
            }
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
