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
{/literal}
