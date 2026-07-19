{* Back-to-top button. Self-contained: markup + CSS + JS, gated on the admin
   flag so the whole partial is a no-op (zero bytes of CSS/JS) when off.
   Included once from footer.tpl, outside any per-page wrapper. *}
{if $hadrian.addonSettings.back_to_top}
    <button type="button" class="mt-totop" id="mtBackToTop" data-show-at="320"
            aria-label="{$hadrianLang.common.backToTop|default:'Back to top'}">
        <svg viewBox="0 0 24 24" fill="none" aria-hidden="true">
            <path d="M12 19V5M5 12l7-7 7 7" stroke="currentColor" stroke-width="2"
                  stroke-linecap="round" stroke-linejoin="round"/>
        </svg>
    </button>
    {literal}
    <style>
    /* z-index 95, deliberately BELOW every modal in the theme (page modals sit
       at 1000+). A floating control that paints over a dialog's submit button
       is worse than one that hides behind it. 95 still clears ordinary page
       content and sits under the mobile drawer backdrop. */
    .mt-totop {
        position: fixed; right: 24px; bottom: 24px; z-index: 95;
        width: 44px; height: 44px; border-radius: 50%;
        display: flex; align-items: center; justify-content: center;
        appearance: none; -webkit-appearance: none; cursor: pointer; padding: 0;
        border: 0.5px solid var(--color-border, rgba(0,0,0,0.1));
        /* Opaque, no backdrop-filter: --color-surface is opaque in BOTH themes,
           so a filter could never render while still forcing a compositing
           layer on every scroll frame. */
        background: var(--color-surface, #fff);
        color: var(--color-text-secondary, #6e6e73);
        box-shadow: 0 6px 22px rgba(0,0,0,0.14);
        opacity: 0; visibility: hidden; pointer-events: none;
        transform: translateY(10px) scale(0.94);
        transition: opacity .22s ease, transform .22s ease, visibility .22s ease, color .15s ease;
    }
    .mt-totop.is-visible { opacity: 1; visibility: visible; pointer-events: auto; transform: none; }
    .mt-totop.is-visible:hover { color: var(--color-text-primary, #1d1d1f); transform: translateY(-2px); }
    .mt-totop:focus-visible { outline: 2px solid var(--color-accent, #0071e3); outline-offset: 3px; }
    .mt-totop svg { display: block; width: 18px; height: 18px; }

    /* Mobile drawer open: body.nav-open sets overflow:hidden, so no scroll event
       fires and .is-visible would persist as a live control over the backdrop.
       Declared AFTER .is-visible -- both are (0,2,0), so this wins on order. */
    body.nav-open .mt-totop { opacity: 0; visibility: hidden; pointer-events: none; }

    @media (max-width: 520px) {
        .mt-totop { right: 16px; bottom: 16px; }
    }
    @media (prefers-reduced-motion: reduce) {
        .mt-totop { transition: none; transform: none; }
        .mt-totop.is-visible:hover { transform: none; }
    }
    </style>
    <script>
    (function () {
        var btn = document.getElementById('mtBackToTop');
        if (!btn) return;
        var showAt = parseInt(btn.getAttribute('data-show-at'), 10) || 320;
        var ticking = false;
        // Own rAF-throttled passive listener. The existing scroll handler cannot
        // be reused: it returns early unless data-affixed-nav="1", so with that
        // toggle off there is no window scroll listener on the page at all.
        function classify() {
            ticking = false;
            var y = window.pageYOffset || document.documentElement.scrollTop || 0;
            btn.classList.toggle('is-visible', y > showAt);
        }
        function onScroll() {
            if (ticking) return;
            ticking = true;
            window.requestAnimationFrame(classify);
        }
        window.addEventListener('scroll', onScroll, { passive: true });
        classify();
        btn.addEventListener('click', function () {
            // apple-theme.css sets html{scroll-behavior:smooth} with no
            // reduced-motion guard. Per CSSOM-View, behavior:'auto' DEFERS to
            // that CSS value so it cannot force an instant jump, and
            // behavior:'instant' throws on older Safari. Overriding the inline
            // style is the only approach that works everywhere without throwing.
            var mq = window.matchMedia && window.matchMedia('(prefers-reduced-motion: reduce)');
            if (mq && mq.matches) {
                var root = document.documentElement;
                var prev = root.style.scrollBehavior;
                root.style.scrollBehavior = 'auto';
                window.scrollTo(0, 0);
                root.style.scrollBehavior = prev;
            } else if ('scrollBehavior' in document.documentElement.style) {
                window.scrollTo({ top: 0, left: 0, behavior: 'smooth' });
            } else {
                window.scrollTo(0, 0);
            }
            btn.blur();
        });
    })();
    </script>
    {/literal}
{/if}
