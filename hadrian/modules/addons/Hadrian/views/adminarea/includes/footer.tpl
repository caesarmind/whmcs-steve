        {* Media picker: rendered on every admin page so any [data-mt-media]
           field gets it for free. Included INSIDE .mt-wrap so it inherits the
           --mt-* tokens; its script then relocates the modal to document.body.
           Costs nothing on pages with no media field (the script returns
           after finding no inputs to upgrade). *}
        {include file="includes/media-picker.tpl"}
        </div>{* /.mt-body *}
</div>{* /.mt-wrap *}


{literal}
<script>
(function(){
    document.querySelectorAll('.mt-wrap input[maxlength], .mt-wrap textarea[maxlength]').forEach(function(el) {
        var counter = el.parentElement && el.parentElement.querySelector('.mt-charcount');
        if (!counter) return;
        var max = parseInt(el.getAttribute('maxlength'), 10);
        function update() {
            counter.textContent = el.value.length + '/' + max;
            counter.classList.toggle('is-over', el.value.length >= max);
        }
        el.addEventListener('input', update);
    });
})();

/* Light/dark toggle. Scoped to the admin root (.mt-wrap#mt-admin-root) so it
   never touches WHMCS admin chrome. Persists to localStorage; the no-FOUC
   init in header.tpl applies the saved choice before paint. */
(function(){
    var root = document.getElementById('mt-admin-root');
    var btn  = document.getElementById('mt-theme-toggle');
    if (!root || !btn) return;
    btn.addEventListener('click', function(){
        var next = root.getAttribute('data-theme') === 'dark' ? 'light' : 'dark';
        root.setAttribute('data-theme', next);
        try { localStorage.setItem('hadrian-admin-theme', next); } catch (e) {}
    });
})();

/* Style editor: switch sub-category panels with no page reload. The <a> hrefs
   remain a no-JS fallback; here we just toggle the pre-rendered panels. */
(function(){
    var nav = document.querySelector('.mt-subcats');
    var content = document.querySelector('[data-subcats]');
    if (!nav || !content) return;
    var tabs = [].slice.call(nav.querySelectorAll('.mt-subcat[data-subcat]'));
    var panels = [].slice.call(content.querySelectorAll('.mt-subcat-panel[data-panel]'));
    function show(name) {
        var matched = false;
        panels.forEach(function(p){ var on = p.getAttribute('data-panel') === name; p.hidden = !on; if (on) matched = true; });
        if (!matched) return false;
        tabs.forEach(function(t){ t.classList.toggle('is-active', t.getAttribute('data-subcat') === name); });
        return true;
    }
    tabs.forEach(function(t){
        t.addEventListener('click', function(e){
            var name = t.getAttribute('data-subcat');
            if (!name) return;
            e.preventDefault();
            if (show(name)) {
                try { var u = new URL(window.location.href); u.searchParams.set('subcat', name); window.history.replaceState({}, '', u); } catch (_) {}
            }
        });
    });
})();

/* Typography: only the input matching the chosen font-family mode is enabled,
   and focusing a dependent control selects its radio. */
(function(){
    var form = document.querySelector('.mt-typography');
    if (!form) return;
    var fonts = form.querySelector('.mt-typo-fonts');
    var FALLBACK = (fonts && fonts.getAttribute('data-ff-fallback')) || 'system-ui, sans-serif';
    var APPLE    = (fonts && fonts.getAttribute('data-ff-apple')) || '-apple-system, BlinkMacSystemFont';
    function q(n){ return form.querySelector('[name="' + n + '"]'); }
    var gsel = q('ff_google'),  gstk = q('ff_google_stack');
    var fname = q('ff_folder'), fstk = q('ff_folder_stack'),  fapp = q('ff_folder_apple');

    function mode() { var c = form.querySelector('input[name="ff_mode"]:checked'); return c ? c.value : 'default'; }
    function sync() {
        var m = mode();
        if (gsel) gsel.disabled = m !== 'google';
        if (fname) fname.disabled = m !== 'folder';
        if (fapp) fapp.disabled = m !== 'folder';
    }
    function selectMode(m) { var r = form.querySelector('input[name="ff_mode"][value="' + m + '"]'); if (r) { r.checked = true; sync(); } }
    function famOf(sel, quote) {
        if (!sel || !sel.value) return '';
        var opt = sel.options[sel.selectedIndex];
        var name = (opt && opt.getAttribute('data-family')) || sel.value.replace(/\.(woff2?|ttf|otf)$/i, '');
        return quote + name + quote;
    }
    function build(stk, sel, apple, quote) {
        if (!stk || !sel) return;
        var fam = famOf(sel, quote);
        if (!fam) return;
        stk.value = (apple ? APPLE + ', ' : '') + fam + ', ' + FALLBACK;
    }
    if (gsel) gsel.addEventListener('change', function(){ build(gstk, gsel, false, "'"); selectMode('google'); });
    if (fname) fname.addEventListener('input', function(){ build(fstk, fname, fapp && fapp.checked, '"'); });
    if (fapp) fapp.addEventListener('change', function(){ build(fstk, fname, fapp.checked, '"'); });
    [].slice.call(form.querySelectorAll('input[name="ff_mode"]')).forEach(function(r){ r.addEventListener('change', sync); });
    sync();
})();

/* Colors panel: every token row has a native swatch + a hex/rgba text field
   kept in sync; preset chips cascade the brand-token fields; "Reset all" puts
   every field back to its per-style default. */
(function(){
    var form = document.querySelector('.mt-colors');
    if (!form) return;

    function clamp(n){ return Math.max(0, Math.min(255, Math.round(n))); }
    function clean(v){
        if (!v) return null;
        var s = ('' + v).trim();
        if (s.charAt(0) === '#') s = s.slice(1);
        if (s.length === 3) s = s.charAt(0) + s.charAt(0) + s.charAt(1) + s.charAt(1) + s.charAt(2) + s.charAt(2);
        if (s.length !== 6 || !/^[0-9a-f]+$/i.test(s)) return null;
        return s.toLowerCase();
    }
    function toRgb(hex){ var s = clean(hex); if (!s) return null; var i = parseInt(s, 16); return [(i >> 16) & 255, (i >> 8) & 255, i & 255]; }
    function hx(v){ return ('0' + clamp(v).toString(16)).slice(-2); }
    function toHex(rgb){ return '#' + hx(rgb[0]) + hx(rgb[1]) + hx(rgb[2]); }
    function shade(rgb, p){ return [0, 1, 2].map(function(i){ var c = rgb[i]; return clamp(p >= 0 ? c + (255 - c) * p : c * (1 + p)); }); }
    function rgba(rgb, a){ return 'rgba(' + clamp(rgb[0]) + ',' + clamp(rgb[1]) + ',' + clamp(rgb[2]) + ',' + a + ')'; }

    function textFor(name){ return form.querySelector('input.mt-color-text[data-var="' + name + '"]'); }
    function swatchFor(name){ return form.querySelector('input.mt-color-swatch-input[data-for="' + name + '"]'); }

    function syncSwatch(name, value){
        var sw = swatchFor(name); if (!sw) return;
        var h = clean(value);
        if (h) { sw.value = '#' + h; return; }
        var rgb = toRgb(value);
        if (rgb) sw.value = toHex(rgb);
    }
    function setToken(name, value){
        var t = textFor(name); if (!t) return;
        t.value = value;
        syncSwatch(name, value);
    }

    [].slice.call(form.querySelectorAll('input.mt-color-swatch-input')).forEach(function(sw){
        sw.addEventListener('input', function(){
            var t = textFor(sw.getAttribute('data-for'));
            if (t) t.value = sw.value;
        });
    });
    [].slice.call(form.querySelectorAll('input.mt-color-text')).forEach(function(t){
        t.addEventListener('input', function(){ syncSwatch(t.getAttribute('data-var'), t.value); });
    });

    [].slice.call(form.querySelectorAll('.mt-scheme[data-accent]')).forEach(function(chip){
        chip.addEventListener('click', function(){
            var h = clean(chip.getAttribute('data-accent')); if (!h) return;
            var rgb = toRgb('#' + h);
            var dark = toHex(shade(rgb, -0.08));
            setToken('--color-accent', '#' + h);
            setToken('--color-accent-hover', dark);
            setToken('--color-accent-light', rgba(rgb, 0.08));
            setToken('--color-link', '#' + h);
            setToken('--color-link-hover', dark);
        });
    });

    var reset = form.querySelector('#mt-colors-reset');
    if (reset) reset.addEventListener('click', function(){
        [].slice.call(form.querySelectorAll('input.mt-color-text')).forEach(function(t){
            setToken(t.getAttribute('data-var'), t.getAttribute('data-default'));
        });
        genUndoState(null);
    });

    /* ------------------------------------------------------------------
       Sidebar style: Light / the named styles from colors.php / Custom.

       The buttons hold no value of their own. They write '', a style NAME or a
       hex into the same c[--sidebar-color] field every other row posts through,
       so there is no new input, no new POST key and no new storage -- and the
       mode is READ BACK from the value, which means the two can never disagree.

       The style vocabulary is read off the buttons rather than duplicated here,
       so adding a style is a row in colors.php and nothing else.

       Placed above the generator's early return on purpose: the style switch is
       not part of the generator and must still work if that section is absent.
       ------------------------------------------------------------------ */
    var sbt = form.querySelector('[data-sbt]');
    // No-op stand-in so callers outside the block (the generator, the form-wide
    // input listener) can refresh the picker without caring whether the row is
    // on the page at all.
    var sbtRefresh = function(){};
    if (sbt) {
        var sbtField  = sbt.querySelector('input.mt-color-text'),
            sbtSwatch = sbt.querySelector('input.mt-color-swatch-input'),
            sbtCustom = sbt.querySelector('.mt-sbt-custom'),
            sbtPrev   = sbt.querySelector('.mt-sbt-preview'),
            sbtNames  = [].slice.call(sbt.querySelectorAll('.mt-sbt-mode'))
                          .map(function(b){ return b.getAttribute('data-sbt-mode'); })
                          .filter(function(k){ return k !== 'off' && k !== 'custom'; }),
            // Remembered so flipping Light -> Custom -> Light -> Custom does not
            // lose the colour that was picked.
            sbtLast   = clean(sbtField.value) ? '#' + clean(sbtField.value) : '';

        function sbtMode(){
            var v = (sbtField.value || '').trim().toLowerCase();
            if (v === '') return 'off';
            return sbtNames.indexOf(v) !== -1 ? v : 'custom';
        }
        /* Paint the preview with the style's own CSS, straight off the button.
           The browser resolves the color-mix() -- no colour maths here, and no
           second copy of the values to drift from colors.php. Light has no
           entry of its own, so it borrows the --sidebar-bg default, which is
           literally what the nav renders when no tint is set. */
        function sbtPaint(m){
            if (!sbtPrev) return;
            var css;
            if (m === 'off') css = defVal('--sidebar-bg') || '#f6f6f8';
            else {
                var b = sbt.querySelector('.mt-sbt-mode[data-sbt-mode="' + m + '"]');
                css = b ? (b.getAttribute('data-sbt-css') || '') : '';
            }
            if (!css) { sbtPrev.style.background = ''; return; }
            // The admin page has no --color-accent of its own, so substitute the
            // value sitting in the Accent field: the dot then tracks it live and
            // shows Tinted and Brand actually following a rebrand.
            var acc = clean(fieldVal('--color-accent'));
            sbtPrev.style.background = css.replace(/var\(--color-accent\)/g, acc ? '#' + acc : '#0071e3');
        }
        function sbtSync(){
            var m = sbtMode();
            [].slice.call(sbt.querySelectorAll('.mt-sbt-mode')).forEach(function(b){
                b.setAttribute('aria-pressed', String(b.getAttribute('data-sbt-mode') === m)); });
            sbtCustom.hidden = m !== 'custom';
            sbtField.hidden  = m !== 'custom';
            // In Custom the real picker IS the swatch, so two would be one too many
            if (sbtPrev) sbtPrev.hidden = m === 'custom';
            sbtPaint(m);
        }
        sbtRefresh = sbtSync;
        /* Delegated, because the Accent can change without its text field ever
           firing input: the swatch handler assigns .value directly, and the
           palette generator writes through setToken. Listening on the form
           catches both, and repainting one dot is free. */
        form.addEventListener('input', function(e){
            // ...but never while the buyer is typing in this row's OWN field.
            // Clearing it to retype would read as mode 'off' and yank the input
            // out from under the cursor mid-keystroke.
            if (e.target !== sbtField) sbtSync();
        });
        sbt.addEventListener('click', function(e){
            var b = e.target.closest('.mt-sbt-mode'); if (!b) return;
            var m = b.getAttribute('data-sbt-mode');
            if (m === 'custom') {
                // Opening Custom with nothing remembered seeds from the Accent
                // rather than #000000, which is what an empty colour input
                // shows and is never what anyone wants.
                var seed = sbtLast || (clean(fieldVal('--color-accent')) ? '#' + clean(fieldVal('--color-accent')) : '#1b2a4a');
                sbtField.value = seed; sbtSwatch.value = seed;
            } else {
                if (sbtMode() === 'custom' && clean(sbtField.value)) sbtLast = '#' + clean(sbtField.value);
                // 'off' is the ABSENCE of a value -- that emptiness is the
                // tint's off switch in apple-theme.css, not a colour meaning
                // "neutral". Every other mode stores its own name.
                sbtField.value = m === 'off' ? '' : m;
            }
            sbtSync();
        });
        sbtField.addEventListener('input', function(){
            if (clean(this.value)) sbtLast = '#' + clean(this.value);
        });
        // Reset-all writes every field back to its default (empty here), so the
        // three buttons have to be told; otherwise the row reads Off while
        // Custom still looks selected.
        if (reset) reset.addEventListener('click', sbtSync);
        sbtSync();
    }
    function fieldVal(name){ var t = textFor(name); return t ? t.value : ''; }

    /* ------------------------------------------------------------------
       Seeded generation. Rebuilds the palette from one brand colour and
       writes the result into the fields above; Save colors persists it.

       Deliberately produces LITERALS -- hex where the row ships hex, rgba
       (shipped alpha carried through) where it ships rgba. isColor() rejects
       color-mix() and relative colour syntax, so a generator emitting CSS
       functions would build rows saveColorsAction silently drops.

       Every row is rebuilt from its data-default, never from its current
       value, so generating twice gives the same answer and generating after
       a hand edit does not compound on it.
       ------------------------------------------------------------------ */
    var gen = form.querySelector('.mt-gen');
    if (!gen) return;

    function lin(v){ v /= 255; return v <= 0.04045 ? v / 12.92 : Math.pow((v + 0.055) / 1.055, 2.4); }
    function gam(v){ v = v <= 0.0031308 ? v * 12.92 : 1.055 * Math.pow(v, 1 / 2.4) - 0.055; return clamp(v * 255); }
    function toLch(rgb){
        var r = lin(rgb[0]), g = lin(rgb[1]), b = lin(rgb[2]);
        var l = Math.cbrt(0.4122214708 * r + 0.5363325363 * g + 0.0514459929 * b),
            m = Math.cbrt(0.2119034982 * r + 0.6806995451 * g + 0.1073969566 * b),
            s = Math.cbrt(0.0883024619 * r + 0.2817188376 * g + 0.6299787005 * b);
        var L =  0.2104542553 * l + 0.7936177850 * m - 0.0040720468 * s,
            A =  1.9779984951 * l - 2.4285922050 * m + 0.4505937099 * s,
            B =  0.0259040371 * l + 0.7827717662 * m - 0.8086757660 * s;
        var C = Math.sqrt(A * A + B * B);
        return { L: L, C: C, H: C < 1e-6 ? 0 : (Math.atan2(B, A) * 180 / Math.PI + 360) % 360 };
    }
    function lchRaw(L, C, H){
        var h = H * Math.PI / 180, A = C * Math.cos(h), B = C * Math.sin(h);
        var l = L + 0.3963377774 * A + 0.2158037573 * B,
            m = L - 0.1055613458 * A - 0.0638541728 * B,
            s = L - 0.0894841775 * A - 1.2914855480 * B;
        l = l * l * l; m = m * m * m; s = s * s * s;
        return [  4.0767416621 * l - 3.3077115913 * m + 0.2309699292 * s,
                 -1.2684380046 * l + 2.6097574011 * m - 0.3413193965 * s,
                 -0.0041960863 * l - 0.7034186147 * m + 1.7076147010 * s ];
    }
    /* Gamut mapping drops CHROMA and never lightness. The recipes pin L
       precisely because L is what contrast is made of, so clipping channels
       would quietly undo the ratio the recipe just guaranteed. */
    function lchToRgb(L, C, H){
        L = Math.max(0, Math.min(1, L));
        var ok = function(x){ return x[0] >= -0.0005 && x[0] <= 1.0005 && x[1] >= -0.0005
                                  && x[1] <= 1.0005 && x[2] >= -0.0005 && x[2] <= 1.0005; };
        var v = lchRaw(L, C, H);
        if (!ok(v)) {
            var lo = 0, hi = C, i, mid;
            for (i = 0; i < 26; i++) { mid = (lo + hi) / 2; if (ok(lchRaw(L, mid, H))) lo = mid; else hi = mid; }
            v = lchRaw(L, lo, H);
        }
        return [gam(v[0]), gam(v[1]), gam(v[2])];
    }
    function parseCol(s){
        s = ('' + (s || '')).trim();
        var h = clean(s);
        if (h && s.charAt(0) === '#') return { rgb: toRgb('#' + h), a: null };
        var m = /^rgba?\(\s*([\d.]+)\s*,\s*([\d.]+)\s*,\s*([\d.]+)\s*(?:,\s*([\d.]+)\s*)?\)$/i.exec(s);
        if (m) return { rgb: [+m[1], +m[2], +m[3]], a: m[4] === undefined ? null : m[4] };
        return null;
    }
    // Output format follows the ROW, not the maths: a row that ships rgba is
    // read back as rgba, and handing a hex to one the emitter expects to be
    // translucent turns a wash into a solid block.
    function fmtCol(rgb, a){ return a === null ? toHex(rgb) : rgba(rgb, a); }
    function lum(c){ return 0.2126 * lin(c[0]) + 0.7152 * lin(c[1]) + 0.0722 * lin(c[2]); }
    function contrast(a, b){ var x = lum(a), y = lum(b), hi = Math.max(x, y), lo = Math.min(x, y);
        return (hi + 0.05) / (lo + 0.05); }
    function overlay(fg, a, bg){ return [0,1,2].map(function(i){ return fg[i] * a + bg[i] * (1 - a); }); }

    var GEN_CLASS = {};
    [['skip', ['--sidebar-color','--color-accent-hover','--color-link','--color-link-hover']],
     ['brand', ['--color-accent','--color-accent-light','--color-on-accent','--color-avatar-from']],
     ['neutral', ['--color-bg','--color-surface','--color-surface-secondary','--color-surface-tertiary',
                  '--color-text-primary','--color-text-secondary','--color-text-tertiary',
                  '--color-text-quaternary','--color-border','--color-border-light','--color-border-card',
                  '--color-gray-text','--color-gray-bg','--sidebar-bg','--sidebar-panel-bg','--sidebar-text',
                  '--sidebar-text-secondary','--sidebar-text-muted','--sidebar-text-faint','--sidebar-border',
                  '--sidebar-field-bg','--sidebar-item-hover-bg','--sidebar-item-active-bg',
                  '--sidebar-scroll-thumb','--topbar-bg']],
     /* Info is NOT brand, though it ships equal to the accent. Its own row says
        why: a separate token so an info badge need not follow a rebrand. Made to
        follow, it measured 1.25:1 on a yellow brand -- yellow on a yellow wash. */
     ['status', ['--color-green','--color-green-text','--color-green-bg','--color-orange',
                 '--color-orange-text','--color-orange-bg','--color-red','--color-red-text',
                 '--color-red-bg','--color-blue-text','--color-blue-bg']],
     ['rotate', ['--color-icon-blue','--color-icon-purple','--color-icon-orange','--color-icon-green',
                 '--color-icon-red','--color-icon-teal','--color-icon-gray','--color-icon-indigo',
                 '--color-icon-pink','--color-avatar-to','--color-block-1','--color-block-2','--color-block-3']]
    ].forEach(function(p){ p[1].forEach(function(v){ GEN_CLASS[v] = p[0]; }); });

    var PAIRS = [
        ['--color-text-primary',   '--color-surface',   'Body text on a card'],
        ['--color-text-secondary', '--color-surface',   'Secondary text'],
        ['--color-text-primary',   '--color-bg',        'Body text on the page'],
        ['--color-on-accent',      '--color-accent',    'Button label on the accent'],
        ['--color-green-text',     '--color-green-bg',  'Success badge'],
        ['--color-orange-text',    '--color-orange-bg', 'Warning badge'],
        ['--color-red-text',       '--color-red-bg',    'Danger badge'],
        ['--color-blue-text',      '--color-blue-bg',   'Info badge'],
        ['--sidebar-text',         '--sidebar-bg',      'Nav label on the sidebar']
    ];
    function defVal(name){ var t = textFor(name); return t ? t.getAttribute('data-default') : ''; }
    /* Measured on the FIELD VALUES, not on anything rendered: every token is a
       literal sitting in an input, so the ratios can be computed outright
       instead of probing a preview that is not on this page. Translucent fills
       are composited arithmetically over the card. */
    function pairRatio(ink, bg){
        var b = parseCol(fieldVal(bg)), f = parseCol(fieldVal(ink));
        if (!b || !f) return null;
        var surf = parseCol(fieldVal('--color-surface'));
        var base = b.a !== null && +b.a < 0.999 && surf ? overlay(b.rgb, +b.a, surf.rgb) : b.rgb;
        var fc   = f.a !== null && +f.a < 0.999 ? overlay(f.rgb, +f.a, base) : f.rgb;
        return contrast(fc, base);
    }

    var genSeedSw  = gen.querySelector('.mt-gen-seed-sw'),
        genSeedTx  = gen.querySelector('.mt-gen-seed'),
        genTint    = gen.querySelector('.mt-gen-tint'),
        genTintOut = gen.querySelector('.mt-gen-tint-out'),
        genReport  = gen.querySelector('.mt-gen-report'),
        genUndoBtn = gen.querySelector('.mt-gen-undo'),
        GEN_PREV   = null;

    function genUndoState(snapshot){
        GEN_PREV = snapshot;
        if (genUndoBtn) genUndoBtn.disabled = !snapshot;
        if (!snapshot && genReport) genReport.hidden = true;
    }
    // Opens on whatever the Accent row currently holds, so the panel agrees
    // with the form instead of proposing a colour nobody chose.
    (function(){
        var cur = clean(fieldVal('--color-accent'));
        if (cur) { genSeedSw.value = '#' + cur; genSeedTx.value = '#' + cur; }
    })();
    genSeedSw.addEventListener('input', function(){ genSeedTx.value = this.value; });
    genTint.addEventListener('input', function(){ genTintOut.textContent = this.value + '%'; });
    [].slice.call(gen.querySelectorAll('.mt-gen-chip')).forEach(function(c){
        c.addEventListener('click', function(){
            var on = c.getAttribute('aria-pressed') !== 'true';
            c.setAttribute('aria-pressed', String(on));
            c.classList.toggle('is-on', on);
        });
    });

    function generate(){
        var seedHex = clean(genSeedTx.value);
        if (!seedHex) { genSeedTx.value = genSeedSw.value; seedHex = clean(genSeedSw.value); }
        if (!seedHex) return;
        genSeedSw.value = '#' + seedHex; genSeedTx.value = '#' + seedHex;

        var want = {};
        [].slice.call(gen.querySelectorAll('.mt-gen-chip')).forEach(function(c){
            want[c.getAttribute('data-what')] = c.getAttribute('aria-pressed') === 'true'; });

        var dark  = gen.getAttribute('data-scope') === 'dark';
        var tint  = (+genTint.value || 0) / 100;
        var alRaw = parseCol(gen.getAttribute('data-accent-light'));
        var adRaw = parseCol(gen.getAttribute('data-accent-dark'));
        if (!alRaw || !adRaw) return;
        var Al = toLch(alRaw.rgb), Ad = toLch(adRaw.rgb), S = toLch(toRgb('#' + seedHex));

        /* Saturation is measured against the LIGHT accent in both scopes, so
           the ratio is one number describing the brand -- "more muted than
           stock", not "more muted than stock-in-this-mode". The floor is the
           safety mechanism: a near-grey brand has a raw ratio near zero, and
           unfloored it turns danger into brick. */
        var sat = Al.C > 0.002 ? Math.max(0.70, Math.min(1.30, S.C / Al.C)) : 1;
        var dH  = S.H - Al.H;
        var A   = dark ? Ad : Al;
        var lifted = false;

        /* The dark seed is the brand colour RAISED TO the dark accent's
           lightness -- a floor, not an offset. Offsetting fails upward: a
           yellow brand is already lighter than the dark accent, and adding the
           same delta again lands on a near-white "brand" colour. Chroma still
           travels by the shipped ratio, so the stock accent is a fixed point. */
        var seed = dark
            ? { L: Math.max(S.L, Ad.L), C: S.C * (Al.C > 0.002 ? Ad.C / Al.C : 1), H: S.H }
            : { L: S.L, C: S.C, H: S.H };

        /* ...and then dark gets a measured lift on top, because the floor alone
           is not enough. In dark mode the theme ships --color-link as
           var(--color-accent) outright, so an accent that is merely lighter
           than the brand and still dark reads as an unclickable link. */
        if (dark) {
            var surfDef = parseCol(defVal('--color-surface'));
            var guard = 0;
            while (surfDef && contrast(lchToRgb(seed.L, seed.C, seed.H), surfDef.rgb) < 4.5
                   && seed.L < 0.92 && guard++ < 80) {
                seed.L += 0.01; lifted = true;
            }
        }

        var before = PAIRS.map(function(p){ return pairRatio(p[0], p[1]); });
        var snapshot = {}, written = 0;
        [].slice.call(form.querySelectorAll('input.mt-color-text')).forEach(function(t){
            snapshot[t.getAttribute('data-var')] = t.value; });

        [].slice.call(form.querySelectorAll('input.mt-color-text')).forEach(function(t){
            var name = t.getAttribute('data-var'), cls = GEN_CLASS[name];
            if (!cls || cls === 'skip' || !want[cls]) return;
            var d = parseCol(t.getAttribute('data-default'));
            if (!d) return;
            var T = toLch(d.rgb), out;

            if (name === '--color-accent') out = seed;
            else if (name === '--color-on-accent') {
                // black or white at the exact WCAG crossover, against the NEW accent
                setToken(name, lum(lchToRgb(seed.L, seed.C, seed.H)) > 0.179129 ? '#000000' : '#ffffff');
                written++; return;
            }
            else if (cls === 'brand')
                out = { L: seed.L + (T.L - A.L), C: T.C * (A.C > 0.002 ? seed.C / A.C : 1), H: seed.H };
            else if (cls === 'neutral')
                // L untouched. Chroma tapers as the grey lightens, or a
                // near-white surface picks up a cast long before a mid grey
                // looks tinted at all.
                out = { L: T.L, C: tint * 0.030 * (0.35 + 0.65 * (1 - T.L)), H: seed.H };
            else if (cls === 'status')
                out = { L: T.L, C: T.C * sat, H: T.H };
            else
                out = { L: T.L, C: T.C * sat, H: ((T.H + dH) % 360 + 360) % 360 };

            setToken(name, fmtCol(lchToRgb(out.L, out.C, out.H), d.a));
            written++;
        });

        /* The three rows apple-theme.css derives get RESET, not skipped. Left
           alone they keep whatever was pinned there before, and a pinned hover
           does not follow a rebrand -- generate a terracotta palette and the
           hover stays blue. Reset to default they are dropped by
           saveColorsAction and the @supports block derives them from the new
           accent. Their swatches still read stock, exactly as the row hint
           warns: writing the derived colour HERE would store it and freeze the
           very link it exists to preserve. --sidebar-color is left alone
           either way; a sidebar tint is a separate decision from a rebrand. */
        var cleared = 0;
        if (want.brand) {
            ['--color-accent-hover', '--color-link', '--color-link-hover'].forEach(function(n){
                var t = textFor(n); if (!t) return;
                if (t.value !== t.getAttribute('data-default')) cleared++;
                setToken(n, t.getAttribute('data-default'));
            });
        }

        // The generator writes the Accent through setToken, which fires no
        // input event, so the sidebar preview has to be told a rebrand happened.
        sbtRefresh();
        genUndoState(snapshot);
        genRender(written, before, PAIRS.map(function(p){ return pairRatio(p[0], p[1]); }), lifted, cleared);
    }

    function genRender(written, before, after, lifted, cleared){
        var fails = after.filter(function(r){ return r !== null && r < 4.5; }).length;
        var checked = after.filter(function(r){ return r !== null; }).length;
        var rows = PAIRS.map(function(p, i){
            var a = after[i], b = before[i];
            if (a === null) return '';
            var cls = a >= 4.5 ? 'is-ok' : a >= 3 ? 'is-mid' : 'is-bad';
            var moved = b !== null && Math.abs(a - b) >= 0.05;
            return '<tr><th scope="row">' + p[2] + '</th><td class="' + cls + '">' + a.toFixed(2)
                 + (moved ? '<span class="mt-gen-was">was ' + b.toFixed(2) + '</span>' : '') + '</td></tr>';
        }).join('');
        genReport.innerHTML =
            '<p class="mt-gen-sum"><b>' + written + '</b> rows filled in below &middot; '
            + (checked - fails) + ' of ' + checked + ' checked pairs clear AA'
            + (fails ? ', <span class="is-bad">' + fails + ' below 4.5</span>' : '')
            + (lifted ? ' &middot; the accent was <b>lifted</b> to stay legible on a dark card' : '')
            + (cleared ? ' &middot; <b>' + cleared + '</b> pinned row(s) released back to following the accent' : '')
            + '. Nothing is stored until you press <strong>Save colors</strong>.'
            + ' Accent hover, link and link hover keep deriving in CSS, so their swatches stay stock.</p>'
            + '<table class="mt-gen-tbl"><tbody>' + rows + '</tbody></table>';
        genReport.hidden = false;
    }

    gen.querySelector('.mt-gen-run').addEventListener('click', generate);
    genUndoBtn.addEventListener('click', function(){
        if (!GEN_PREV) return;
        var prev = GEN_PREV;
        Object.keys(prev).forEach(function(k){ setToken(k, prev[k]); });
        genUndoState(null);
    });
})();

/* Buttons panel: each matrix <select> drives its preview swatch; "Reset all"
   puts every size field + variant select back to its default. */
(function(){
    var form = document.querySelector('.mt-buttons');
    if (!form) return;
    function swatchFor(v, slot){ return form.querySelector('.mt-btn-cell-swatch[data-swatch-for="' + v + '.' + slot + '"]'); }
    function syncSelect(sel){
        var opt = sel.options[sel.selectedIndex];
        if (!opt) return;
        var sw = swatchFor(sel.getAttribute('data-variant'), sel.getAttribute('data-slot'));
        if (sw) sw.style.background = opt.getAttribute('data-swatch') || 'transparent';
    }
    [].slice.call(form.querySelectorAll('select.mt-btn-select')).forEach(function(sel){
        sel.addEventListener('change', function(){ syncSelect(sel); });
    });
    var breset = form.querySelector('#mt-buttons-reset');
    if (breset) breset.addEventListener('click', function(){
        [].slice.call(form.querySelectorAll('input[data-default], select[data-default]')).forEach(function(el){
            el.value = el.getAttribute('data-default');
            if (el.tagName === 'SELECT' && el.className.indexOf('mt-btn-select') !== -1) syncSelect(el);
        });
    });
})();

/* Forms panel: colour <select>s drive their preview swatch; "Reset all" puts
   every size + colour field back to default. */
(function(){
    var form = document.querySelector('.mt-forms');
    if (!form) return;
    function syncSelect(sel){
        var opt = sel.options[sel.selectedIndex];
        if (!opt) return;
        var sw = form.querySelector('.mt-btn-cell-swatch[data-swatch-for="' + sel.getAttribute('data-var') + '"]');
        if (sw) sw.style.background = opt.getAttribute('data-swatch') || 'transparent';
    }
    [].slice.call(form.querySelectorAll('select.mt-form-select')).forEach(function(sel){
        sel.addEventListener('change', function(){ syncSelect(sel); });
    });
    var freset = form.querySelector('#mt-forms-reset');
    if (freset) freset.addEventListener('click', function(){
        [].slice.call(form.querySelectorAll('input[data-default], select[data-default]')).forEach(function(el){
            el.value = el.getAttribute('data-default');
            if (el.tagName === 'SELECT' && el.className.indexOf('mt-form-select') !== -1) syncSelect(el);
        });
    });
})();

/* Layout panel: "Reset all" puts every px field back to default. */
(function(){
    var form = document.querySelector('.mt-layout');
    if (!form) return;
    var lreset = form.querySelector('#mt-layout-reset');
    if (lreset) lreset.addEventListener('click', function(){
        [].slice.call(form.querySelectorAll('input[data-default]')).forEach(function(el){
            el.value = el.getAttribute('data-default');
        });
    });
})();

/* General panel: "Reset all" puts radius/control/motion inputs AND the shadow
   selects back to default. Deliberately its own IIFE and its own form class --
   every subcat panel is rendered into the same document and merely hidden, so a
   shared selector would bind to whichever form happened to come first. */
(function(){
    var form = document.querySelector('.mt-general');
    if (!form) return;
    var greset = form.querySelector('#mt-general-reset');
    if (greset) greset.addEventListener('click', function(){
        [].slice.call(form.querySelectorAll('[data-default]')).forEach(function(el){
            el.value = el.getAttribute('data-default');
        });
    });
})();

/* Elements panel: "Reset all" puts every px + scale field back to default. */
(function(){
    var form = document.querySelector('.mt-elements');
    if (!form) return;
    var ereset = form.querySelector('#mt-elements-reset');
    if (ereset) ereset.addEventListener('click', function(){
        [].slice.call(form.querySelectorAll('input[data-default], select[data-default]')).forEach(function(el){
            el.value = el.getAttribute('data-default');
        });
    });
})();
</script>

<script>
/* Native <select> popup replacement. ONE body-level listbox shared by every
   .mt-select on the page. The native select is never hidden, wrapped or
   duplicated -- it keeps name/id/value and stays focused, so every existing
   change listener, [data-default] reset and form post is untouched. Coarse
   pointers keep the OS wheel. Deliberately its own script element: a parse
   error here cannot take down the shared admin script above. */
(function(){
    var root = document.getElementById('mt-admin-root');
    if (!root) return;
    if (window.matchMedia && window.matchMedia('(pointer: coarse)').matches) return;

    var pop = null, list = null, sel = null, startIndex = -1, rows = [];
    var typed = '', typedAt = 0, progScroll = false;

    function eligible(el){
        return !!el && el.tagName === 'SELECT' && el.classList.contains('mt-select')
            && !el.disabled && !el.multiple && el.size <= 1
            && !el.hasAttribute('data-mt-native') && el.options.length > 0;
    }
    /* Label activation forwards a click to the labelled control, so a click on
       a caption or swatch inside an implicit <label>, or on any label[for=],
       must resolve to the select or the OS picker still opens. */
    function selectFrom(target){
        if (!target || !target.closest) return null;
        var el = target.closest('select.mt-select');
        if (!el){
            var lab = target.closest('label');
            if (lab) el = lab.control || (lab.htmlFor && document.getElementById(lab.htmlFor)) || lab.querySelector('select.mt-select');
        }
        return eligible(el) ? el : null;
    }
    function build(){
        pop = document.createElement('div');
        pop.className = 'mt-wrap mt-selpop';
        pop.setAttribute('aria-hidden', 'true');   /* decorative: focus never leaves the select */
        list = document.createElement('div');
        list.className = 'mt-selpop-list';
        pop.appendChild(list);
        document.body.appendChild(pop);
        list.addEventListener('mousedown', function(e){ e.preventDefault(); });  /* keep focus on the select */
        list.addEventListener('mousemove', function(e){
            var r = e.target.closest('.mt-selpop-opt');
            if (r && !r.classList.contains('is-disabled')) markActive(parseInt(r.getAttribute('data-i'), 10));
        });
        list.addEventListener('click', function(e){
            var r = e.target.closest('.mt-selpop-opt');
            if (!r || r.classList.contains('is-disabled')) return;
            highlight(parseInt(r.getAttribute('data-i'), 10), false);
            close(true);
        });
    }
    function render(){
        list.textContent = ''; rows = [];
        var i = 0;
        function addOpt(o){
            var r = document.createElement('div');
            r.className = 'mt-selpop-opt' + (o.disabled ? ' is-disabled' : '');
            r.setAttribute('data-i', i);
            var sw = o.getAttribute('data-swatch');
            if (sw){ var d = document.createElement('span'); d.className = 'mt-selpop-dot'; d.style.background = sw; r.appendChild(d); }
            var t = document.createElement('span'); t.className = 'mt-selpop-txt'; t.textContent = o.text;
            r.appendChild(t); list.appendChild(r); rows[i] = r; i++;
        }
        [].forEach.call(sel.children, function(n){
            if (n.tagName === 'OPTGROUP'){
                var g = document.createElement('div'); g.className = 'mt-selpop-group'; g.textContent = n.label;
                list.appendChild(g);
                [].forEach.call(n.children, addOpt);
            } else if (n.tagName === 'OPTION'){ addOpt(n); }
        });
    }
    function markActive(i){ rows.forEach(function(r, n){ r.classList.toggle('is-active', n === i); }); }
    /* Scroll the panel's own list directly. scrollIntoView() walks every
       scrollable ancestor and can move the document scroller too. */
    function reveal(i){
        var r = rows[i]; if (!r) return;
        progScroll = true;
        var top = r.offsetTop - list.offsetTop, bot = top + r.offsetHeight;
        if (top < list.scrollTop) list.scrollTop = top;
        else if (bot > list.scrollTop + list.clientHeight) list.scrollTop = bot - list.clientHeight;
        setTimeout(function(){ progScroll = false; }, 0);
    }
    function highlight(i, scroll){
        if (i < 0 || i >= sel.options.length) return;
        if (sel.options[i].disabled) return;          /* one disabled rule for every entry point */
        sel.selectedIndex = i;                        /* real value moves; no event until commit */
        rows.forEach(function(r, n){
            r.classList.toggle('is-selected', n === i);
            r.classList.toggle('is-active', n === i);
        });
        if (scroll) reveal(i);
    }
    function step(dir){
        for (var n = sel.selectedIndex + dir; n >= 0 && n < sel.options.length; n += dir){
            if (!sel.options[n].disabled){ highlight(n, true); return; }
        }
    }
    function stepClosed(el, dir){
        for (var n = el.selectedIndex + dir; n >= 0 && n < el.options.length; n += dir){
            if (el.options[n].disabled) continue;
            el.selectedIndex = n;
            el.dispatchEvent(new Event('input',  { bubbles: true }));
            el.dispatchEvent(new Event('change', { bubbles: true }));
            return;
        }
    }
    function place(){
        if (!sel) return;
        var r = sel.getBoundingClientRect();
        pop.style.visibility = 'hidden'; pop.style.display = 'block';
        pop.style.left = '0px'; pop.style.top = '0px'; pop.style.minWidth = r.width + 'px';
        var ph = pop.offsetHeight, pw = pop.offsetWidth;
        var below = window.innerHeight - r.bottom - 8, above = r.top - 8;
        var top = (ph <= below || below >= above) ? r.bottom + 4 : r.top - ph - 4;
        pop.style.top  = Math.max(8, Math.min(top, window.innerHeight - ph - 8)) + 'px';
        pop.style.left = Math.max(8, Math.min(r.left, window.innerWidth - pw - 8)) + 'px';
        pop.style.visibility = '';
    }
    function open(el){
        if (sel === el){ close(true); return; }
        if (sel) close(true);
        if (!pop) build();
        sel = el; startIndex = el.selectedIndex;   /* index, not value: duplicate values stay unambiguous */
        pop.setAttribute('data-theme', root.getAttribute('data-theme') || 'light');
        render();
        rows.forEach(function(r, n){
            r.classList.toggle('is-selected', n === el.selectedIndex);
            r.classList.toggle('is-active', n === el.selectedIndex);
        });
        pop.style.display = 'block';
        place();
        reveal(el.selectedIndex);
        el.classList.add('is-selpop-open');
        try { el.focus({ preventScroll: true }); } catch (e) { el.focus(); }
    }
    function close(commit){
        if (!sel) return;
        var el = sel;
        if (!commit && el.selectedIndex !== startIndex) el.selectedIndex = startIndex;
        pop.style.display = 'none';
        el.classList.remove('is-selpop-open');
        sel = null; rows = []; typed = '';
        if (commit && el.selectedIndex !== startIndex){
            el.dispatchEvent(new Event('input',  { bubbles: true }));
            el.dispatchEvent(new Event('change', { bubbles: true }));
        }
    }

    document.addEventListener('mousedown', function(e){
        var el = (e.button === 0) ? selectFrom(e.target) : null;
        if (el){ e.preventDefault(); open(el); return; }
        if (sel && !(pop && pop.contains(e.target))) close(true);
    }, true);
    /* Belt and braces: label activation, and engines that open on click. */
    document.addEventListener('click', function(e){
        var el = selectFrom(e.target);
        if (!el) return;
        e.preventDefault();
        if (sel !== el) open(el);
    }, true);
    /* Focus can leave without a mousedown (the menu editor moves focus when a
       row is added, window blur, extensions). Bind the panel to the control. */
    document.addEventListener('focusout', function(e){ if (sel && e.target === sel) close(true); }, true);
    window.addEventListener('blur', function(){ if (sel) close(true); });

    document.addEventListener('keydown', function(e){
        var el = e.target;
        if (!eligible(el)) return;
        var k = e.key;
        if (sel !== el){
            /* Enter is deliberately NOT intercepted: it performs implicit form
               submission from a focused select and admins rely on that. */
            var buffering = (Date.now() - typedAt) < 900;
            if ((k === ' ' || k === 'Spacebar') && !buffering){ e.preventDefault(); open(el); return; }
            if ((k === 'ArrowDown' || k === 'ArrowUp') && e.altKey){ e.preventDefault(); open(el); return; }
            if (k === 'ArrowDown'){ e.preventDefault(); stepClosed(el,  1); return; }
            if (k === 'ArrowUp'){   e.preventDefault(); stepClosed(el, -1); return; }
            if (k.length === 1) typedAt = Date.now();   /* let native typeahead run, track the buffer */
            return;
        }
        if (k === 'Escape'){ e.preventDefault(); close(false); return; }
        if (k === 'Enter'){  e.preventDefault(); close(true);  return; }
        if (k === 'Tab'){    close(true); return; }
        if (k === 'ArrowDown'){ e.preventDefault(); step(1);  return; }
        if (k === 'ArrowUp'){   e.preventDefault(); step(-1); return; }
        if (k === 'Home'){ e.preventDefault(); highlight(0, true); return; }
        if (k === 'End'){  e.preventDefault(); highlight(sel.options.length - 1, true); return; }
        if (k.length === 1 && !e.ctrlKey && !e.metaKey && !e.altKey){
            e.preventDefault();
            var now = Date.now(), n, q;
            typed = (now - typedAt < 900) ? typed + k : k;
            typedAt = now;
            /* Same-key repeat cycles, like a native select: several option sets
               here share a long prefix ("Primary hover", "Primary text"...). */
            var repeat = typed.length > 1 && /^(.)\1+$/.test(typed);
            q = (repeat ? typed.charAt(0) : typed).toLowerCase();
            var from = repeat ? sel.selectedIndex + 1 : 0;
            for (var c = 0; c < sel.options.length; c++){
                n = (from + c) % sel.options.length;
                if (sel.options[n].disabled) continue;
                if (sel.options[n].text.toLowerCase().indexOf(q) === 0){ highlight(n, true); break; }
            }
        }
    }, true);

    /* A fixed panel must re-anchor, not vanish, and must ignore scrolls coming
       from its own overflowing list. Close only when the control itself leaves
       the viewport. */
    window.addEventListener('scroll', function(e){
        if (!sel || progScroll) return;
        if (pop && e.target && e.target.nodeType === 1 && (e.target === pop || pop.contains(e.target))) return;
        var r = sel.getBoundingClientRect();
        if (r.bottom < 0 || r.top > window.innerHeight) { close(true); return; }
        place();
    }, true);
    window.addEventListener('resize', function(){ if (sel) place(); });
})();
</script>

<script>
/* Info tooltips. ONE body-level panel shared by every .mt-tip button (authored
   in markup via includes/tip.tpl). Shows on hover AND focus, so it is keyboard
   reachable; dismissed on Escape, blur, scroll-away or resize. Copy comes from
   data-tip. Its own script element so a parse error cannot take down the shared
   admin script or the select popup above. */
(function(){
    var root = document.getElementById('mt-admin-root');
    if (!root) return;

    var pop = null, arrow = null, cur = null, hideT = null;

    function build(){
        pop = document.createElement('div');
        pop.className = 'mt-wrap mt-tip-pop';
        pop.setAttribute('role', 'tooltip');
        arrow = document.createElement('div');
        arrow.className = 'mt-tip-arrow';
        pop.appendChild(arrow);
        var txt = document.createElement('span');
        txt.className = 'mt-tip-txt';
        pop.appendChild(txt);
        pop._txt = txt;
        document.body.appendChild(pop);
        // A hover onto the panel itself keeps it open (so it can be read/copied).
        pop.addEventListener('mouseenter', function(){ clearTimeout(hideT); });
        pop.addEventListener('mouseleave', hideSoon);
    }
    function place(btn){
        var r = btn.getBoundingClientRect();
        pop.style.visibility = 'hidden'; pop.style.display = 'block';
        pop.style.left = '0px'; pop.style.top = '0px';
        var ph = pop.offsetHeight, pw = pop.offsetWidth;
        var below = window.innerHeight - r.bottom - 10, above = r.top - 10;
        var side = (ph <= below || below >= above) ? 'bottom' : 'top';
        pop.setAttribute('data-side', side);
        var top = side === 'bottom' ? r.bottom + 8 : r.top - ph - 8;
        var mid = r.left + r.width / 2;
        var left = Math.max(8, Math.min(mid - pw / 2, window.innerWidth - pw - 8));
        pop.style.top = Math.max(8, Math.min(top, window.innerHeight - ph - 8)) + 'px';
        pop.style.left = left + 'px';
        // Arrow tracks the trigger centre within the panel.
        var ax = Math.max(8, Math.min(mid - left - 4, pw - 16));
        arrow.style.left = ax + 'px'; arrow.style.right = 'auto';
        pop.style.visibility = '';
    }
    function show(btn){
        clearTimeout(hideT);
        if (cur === btn) return;
        if (!pop) build();
        cur = btn;
        pop._txt.textContent = btn.getAttribute('data-tip') || '';
        pop.setAttribute('data-theme', root.getAttribute('data-theme') || 'light');
        btn.setAttribute('data-open', '');
        pop.style.display = 'block';
        place(btn);
    }
    function hide(){
        clearTimeout(hideT);
        if (!cur) return;
        cur.removeAttribute('data-open');
        if (pop) pop.style.display = 'none';
        cur = null;
    }
    function hideSoon(){ clearTimeout(hideT); hideT = setTimeout(hide, 120); }

    document.addEventListener('mouseover', function(e){
        var btn = e.target.closest && e.target.closest('.mt-tip');
        if (btn) show(btn);
    }, true);
    document.addEventListener('mouseout', function(e){
        var btn = e.target.closest && e.target.closest('.mt-tip');
        if (btn && !(pop && pop.contains(e.relatedTarget))) hideSoon();
    }, true);
    document.addEventListener('focusin', function(e){
        var btn = e.target.closest && e.target.closest('.mt-tip');
        if (btn) show(btn); else if (cur) hide();
    }, true);
    document.addEventListener('focusout', function(e){
        var btn = e.target.closest && e.target.closest('.mt-tip');
        if (btn) hideSoon();
    }, true);
    document.addEventListener('keydown', function(e){
        if (e.key === 'Escape' && cur){ hide(); }
    }, true);
    /* A fixed panel must re-anchor, not drift, and must ignore scrolls from
       inside itself. Hide when the trigger scrolls out of view. */
    window.addEventListener('scroll', function(e){
        if (!cur) return;
        if (pop && e.target && e.target.nodeType === 1 && pop.contains(e.target)) return;
        var r = cur.getBoundingClientRect();
        if (r.bottom < 0 || r.top > window.innerHeight){ hide(); return; }
        place(cur);
    }, true);
    window.addEventListener('resize', function(){ if (cur) place(cur); });
})();
</script>
{/literal}
