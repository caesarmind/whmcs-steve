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
        try { localStorage.setItem('mytheme-admin-theme', next); } catch (e) {}
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
{/literal}
