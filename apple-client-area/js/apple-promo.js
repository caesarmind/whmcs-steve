/* Promotional landing pages (promo-*.html).
   1. Countdown: every [data-countdown] block counts down to body[data-promo-ends].
      [data-cd-compact] gets a one-line "3d 04:12:09" version (subnav).
      When the time runs out, body gets data-promo-ended and the CSS swaps the
      sale content for the "sale has ended" card (same card as Data: Empty).
      ?ends=<ISO date> overrides the end date for previewing.
   2. Billing term switch: radios named "term-<group>" re-price every
      [data-plan-group="<group>"] card from its data-price-<months> /
      data-was-<months> attributes. */
(function () {
    'use strict';

    var body = document.body;
    var params = new URLSearchParams(window.location.search);
    var endsAttr = params.get('ends') || body.getAttribute('data-promo-ends');
    var ends = endsAttr ? new Date(endsAttr).getTime() : NaN;

    function pad(n) { return (n < 10 ? '0' : '') + n; }

    function tick() {
        if (isNaN(ends)) return;
        var left = Math.max(0, Math.floor((ends - Date.now()) / 1000));
        var d = Math.floor(left / 86400);
        var h = Math.floor((left % 86400) / 3600);
        var m = Math.floor((left % 3600) / 60);
        var s = left % 60;
        var parts = { d: d, h: h, m: m, s: s };

        document.querySelectorAll('[data-countdown] [data-cd]').forEach(function (el) {
            el.textContent = pad(parts[el.getAttribute('data-cd')]);
        });
        document.querySelectorAll('[data-cd-compact]').forEach(function (el) {
            el.textContent = (d > 0 ? d + 'd ' : '') + pad(h) + ':' + pad(m) + ':' + pad(s);
        });

        if (left === 0) {
            body.setAttribute('data-promo-ended', '');
            if (timer) { clearInterval(timer); timer = null; }
        } else {
            body.removeAttribute('data-promo-ended');
        }
    }

    // Human end date, e.g. "Sale ends Monday, November 30 at 11:59 PM."
    if (!isNaN(ends)) {
        var label = new Date(ends).toLocaleString(undefined, {
            weekday: 'long', month: 'long', day: 'numeric', hour: 'numeric', minute: '2-digit'
        });
        document.querySelectorAll('[data-ends-label]').forEach(function (el) {
            el.textContent = el.getAttribute('data-ends-label').replace('%s', label);
        });
    }

    var timer = setInterval(tick, 1000);
    tick();

    // Billing term switch
    document.querySelectorAll('.pr-terms input[type="radio"]').forEach(function (input) {
        input.addEventListener('change', function () {
            var group = input.name.replace(/^term-/, '');
            var months = input.value;
            document.querySelectorAll('[data-plan-group="' + group + '"]').forEach(function (card) {
                var price = card.getAttribute('data-price-' + months);
                var was = card.getAttribute('data-was-' + months);
                var priceEl = card.querySelector('.price');
                var wasEl = card.querySelector('.pr-was');
                var perEl = card.querySelector('.per');
                if (price && priceEl) priceEl.textContent = '$' + price;
                if (was && wasEl) wasEl.textContent = '$' + was;
                if (perEl) {
                    perEl.textContent = months === '12'
                        ? '/mo, billed yearly'
                        : '/mo for ' + months + ' months';
                }
                var buy = card.querySelector('.buy');
                if (buy && buy.dataset.href) {
                    buy.href = buy.dataset.href + '&billingcycle=' + (
                        { '12': 'annually', '24': 'biennially', '36': 'triennially' }[months]
                    );
                }
            });
        });
    });
})();
