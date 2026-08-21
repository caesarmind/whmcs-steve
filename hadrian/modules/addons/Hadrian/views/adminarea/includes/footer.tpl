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
    var SYSTEM   = (fonts && fonts.getAttribute('data-ff-system')) || 'system-ui';
    function q(n){ return form.querySelector('[name="' + n + '"]'); }
    var gsel = q('ff_google'),  gstk = q('ff_google_stack');
    var fname = q('ff_folder'), fstk = q('ff_folder_stack'),  fapp = q('ff_folder_system');
    /* ff_google is a hidden input behind the searchable picker below, not the
       <select> it once was; the button is what a person actually operates, so
       that is what mode-switching enables and disables. The hidden input stays
       enabled either way so a saved family round-trips even while another mode
       is selected. The save path only reads it when ff_mode is 'google'. */
    var gbtn = form.querySelector('[data-fontpick-field]');

    function mode() { var c = form.querySelector('input[name="ff_mode"]:checked'); return c ? c.value : 'default'; }
    function sync() {
        var m = mode();
        if (gbtn) gbtn.disabled = m !== 'google';
        if (fname) fname.disabled = m !== 'folder';
        if (fapp) fapp.disabled = m !== 'folder';
    }
    function selectMode(m) { var r = form.querySelector('input[name="ff_mode"][value="' + m + '"]'); if (r) { r.checked = true; sync(); } }
    function famOf(sel, quote) {
        if (!sel || !sel.value) return '';
        var opt = sel.options && sel.selectedIndex >= 0 ? sel.options[sel.selectedIndex] : null;
        var name = (opt && opt.getAttribute('data-family')) || sel.value.replace(/\.(woff2?|ttf|otf)$/i, '');
        return quote + name + quote;
    }
    function build(stk, sel, systemFirst, quote) {
        if (!stk || !sel) return;
        var fam = famOf(sel, quote);
        if (!fam) return;
        stk.value = (systemFirst ? SYSTEM + ', ' : '') + fam + ', ' + FALLBACK;
    }
    if (gsel) gsel.addEventListener('change', function(){ build(gstk, gsel, false, "'"); selectMode('google'); });
    if (fname) fname.addEventListener('input', function(){ build(fstk, fname, fapp && fapp.checked, '"'); });
    if (fapp) fapp.addEventListener('change', function(){ build(fstk, fname, fapp.checked, '"'); });
    [].slice.call(form.querySelectorAll('input[name="ff_mode"]')).forEach(function(r){ r.addEventListener('change', sync); });
    sync();
})();

/* Google Font picker -- searchable combobox over the whole library.
   Three things make ~1,900 families workable where a <select> was not:
   search + category filter, a capped render window (the list is filtered in
   memory but only a slice reaches the DOM), and a preview that renders each
   name in its own face -- because "Caveat" and "Cinzel" mean nothing as text.
   Writes to the hidden ff_google input and fires `change` on it, so the stack
   builder in the block above is untouched by any of this. */
(function(){
    var wrap = document.querySelector('[data-fontpick]');
    if (!wrap) return;

    var value   = wrap.querySelector('[data-fontpick-value]');
    var field   = wrap.querySelector('[data-fontpick-field]');
    var label   = wrap.querySelector('[data-fontpick-label]');
    var meta    = wrap.querySelector('[data-fontpick-meta]');
    var panel   = wrap.querySelector('[data-fontpick-panel]');
    var search  = wrap.querySelector('[data-fontpick-search]');
    var options = wrap.querySelector('[data-fontpick-options]');
    var empty   = wrap.querySelector('[data-fontpick-empty]');
    /* label and meta are guarded too: paint() writes to both unconditionally,
       and it runs on load, so a missing one would throw before the picker was
       ever opened and take the mode-sync block down with it. */
    if (!value || !field || !label || !meta || !panel || !options) return;

    var CATS  = { sans: 'Sans Serif', serif: 'Serif', display: 'Display', hand: 'Handwriting', mono: 'Monospace' };
    var PAGE  = 60;   /* rows per render window */
    var BATCH = 24;   /* families per preview stylesheet request */

    var catalog = null, popular = [], cat = '', shown = PAGE, rows = [], cursor = -1;
    var loaded = {};
    /* The empty-state copy, taken from what the server rendered rather than
       restated here -- a second copy would drift from the .tpl, and the
       em dash in it is the one character this otherwise-ASCII file avoids. */
    var PLACEHOLDER = label.textContent;

    /* Parsed on first open: the catalog is ~88KB of JSON and most visits to the
       Styles page never touch the font picker. */
    function load() {
        if (catalog) return catalog;
        function parse(sel, dflt) {
            var el = wrap.querySelector(sel);
            try { return el ? JSON.parse(el.textContent) : dflt; } catch (_) { return dflt; }
        }
        catalog = parse('[data-fontpick-catalog]', []) || [];
        popular = parse('[data-fontpick-popular]', []) || [];
        return catalog;
    }

    /* Ask Google for just the glyphs in the names being previewed (`text=`),
       the same trick fonts.google.com uses -- a batch of 24 families costs a
       few KB rather than a few hundred. Nothing here is required for the
       picker to work: if the request is blocked, names render in the panel
       font and everything else behaves identically. */
    function preview(names) {
        var want = names.filter(function(n){ return !loaded[n]; });
        if (!want.length) return;
        while (want.length) {
            var batch = want.splice(0, BATCH), chars = {};
            batch.forEach(function(n){
                loaded[n] = true;
                n.split('').forEach(function(c){ chars[c] = true; });
            });
            var link = document.createElement('link');
            link.rel = 'stylesheet';
            link.href = 'https://fonts.googleapis.com/css2?'
                + batch.map(function(n){ return 'family=' + encodeURIComponent(n); }).join('&')
                + '&text=' + encodeURIComponent(Object.keys(chars).join(''))
                + '&display=swap';
            document.head.appendChild(link);
        }
    }

    function describe(row) {
        var n = row[2].length;
        /* CATS maps the five known slugs to labels; the server (loadGoogleFontCatalog)
           drops any row whose category is not one of them, so row[1] always resolves
           here. NO `|| row[1]` fallback: describe()'s return is concatenated straight
           into options.innerHTML below, so echoing an unrecognised category verbatim
           would be an injection sink. An unknown slug degrades to '' instead. */
        return (CATS[row[1]] || '') + ', ' + n + (n === 1 ? ' weight' : ' weights') + (row[3] ? ', italic' : '');
    }

    /* Reflect the current pick onto the closed field. Called on load too, so a
       saved family shows its category and previews itself without opening. */
    function paint() {
        var name = value.value;
        label.textContent = name || PLACEHOLDER;
        label.classList.toggle('is-placeholder', !name);
        /* NOT "'Name', inherit": `inherit` is a CSS-wide keyword, legal only as
           a declaration's sole value, so that list is invalid and the whole
           declaration gets dropped -- the preview would silently never render.
           --mt-fontpick-fallback (admin.css) carries the panel stack instead. */
        label.style.fontFamily = name ? "'" + name + "', var(--mt-fontpick-fallback)" : '';
        var row = name ? find(name) : null;
        meta.textContent = row ? describe(row) : '';
        if (name) preview([name]);
    }

    function find(name) {
        var list = load();
        for (var i = 0; i < list.length; i++) if (list[i][0] === name) return list[i];
        return null;
    }

    function filter() {
        var qs = (search && search.value || '').trim().toLowerCase();
        rows = load().filter(function(r){
            if (cat && r[1] !== cat) return false;
            return !qs || r[0].toLowerCase().indexOf(qs) !== -1;
        });
        /* Popular is a shortcut, not a filter: it only leads when the admin has
           not started narrowing, otherwise it would push matches down the list. */
        if (!qs && !cat) {
            var pinned = popular.map(find).filter(Boolean);
            var names  = {};
            pinned.forEach(function(r){ names[r[0]] = true; });
            rows = pinned.concat(rows.filter(function(r){ return !names[r[0]]; }));
            rows.pinned = pinned.length;
        } else {
            rows.pinned = 0;
        }
        shown  = PAGE;
        cursor = -1;
        render();
    }

    function render() {
        var slice = rows.slice(0, shown);
        var html  = '';
        slice.forEach(function(r, i){
            if (rows.pinned && i === 0)           html += '<div class="mt-fontpick-group">Popular</div>';
            if (rows.pinned && i === rows.pinned) html += '<div class="mt-fontpick-group">All fonts</div>';
            html += '<button type="button" class="mt-fontpick-option' + (r[0] === value.value ? ' is-selected' : '')
                 +  '" role="option" aria-selected="' + (r[0] === value.value) + '" data-name="' + r[0] + '" data-i="' + i + '">'
                 +  '<span class="mt-fontpick-option-name" style="font-family:\'' + r[0] + '\', var(--mt-fontpick-fallback)">' + r[0] + '</span>'
                 +  '<span class="mt-fontpick-option-meta">' + describe(r) + '</span>'
                 +  '</button>';
        });
        if (rows.length > shown) {
            html += '<div class="mt-fontpick-more">' + (rows.length - shown) + ' more - keep scrolling or refine your search</div>';
        }
        options.innerHTML = html;
        if (empty) empty.hidden = rows.length > 0;
        preview(slice.map(function(r){ return r[0]; }));
    }

    /* Family names are validated to [A-Za-z0-9 ] both when the catalog is
       generated and again when the server reads it, so the innerHTML above and
       this attribute read stay in step with what can actually be in the file. */
    function pick(name) {
        value.value = name;
        paint();
        value.dispatchEvent(new Event('change', { bubbles: true }));
        close();
        field.focus();
    }

    function open() {
        load();
        filter();
        panel.hidden = false;
        field.classList.add('is-open');
        field.setAttribute('aria-expanded', 'true');
        /* Flip above the field when there is more room up than down -- the
           picker sits low on a long Typography panel. */
        var box = field.getBoundingClientRect();
        panel.classList.toggle('mt-fontpick-panel--up', box.bottom + 380 > window.innerHeight && box.top > 380);
        if (search) { search.value = ''; search.focus(); }
    }
    function close() {
        panel.hidden = true;
        field.classList.remove('is-open');
        field.setAttribute('aria-expanded', 'false');
    }

    function move(delta) {
        var last = Math.min(shown, rows.length) - 1;
        if (last < 0) return;
        cursor = cursor < 0 ? (delta > 0 ? 0 : last) : Math.max(0, Math.min(last, cursor + delta));
        var els = options.querySelectorAll('.mt-fontpick-option');
        [].forEach.call(els, function(el){ el.classList.remove('is-cursor'); });
        var el = options.querySelector('.mt-fontpick-option[data-i="' + cursor + '"]');
        if (el) { el.classList.add('is-cursor'); el.scrollIntoView({ block: 'nearest' }); }
    }

    field.addEventListener('click', function(){ panel.hidden ? open() : close(); });
    if (search) {
        search.addEventListener('input', filter);
        search.addEventListener('keydown', function(e){
            if (e.key === 'ArrowDown')      { e.preventDefault(); move(1); }
            else if (e.key === 'ArrowUp')   { e.preventDefault(); move(-1); }
            else if (e.key === 'Enter')     { e.preventDefault(); if (rows[cursor]) pick(rows[cursor][0]); }
            else if (e.key === 'Escape')    { e.preventDefault(); close(); field.focus(); }
        });
    }
    [].forEach.call(wrap.querySelectorAll('.mt-fontpick-cat'), function(btn){
        btn.addEventListener('click', function(){
            cat = btn.getAttribute('data-cat') || '';
            [].forEach.call(wrap.querySelectorAll('.mt-fontpick-cat'), function(b){ b.classList.toggle('is-active', b === btn); });
            filter();
            if (search) search.focus();
        });
    });
    options.addEventListener('click', function(e){
        var btn = e.target.closest && e.target.closest('.mt-fontpick-option');
        if (btn) pick(btn.getAttribute('data-name'));
    });
    /* Grow the window as the list is scrolled rather than putting 1,900 rows in
       the DOM up front. */
    options.addEventListener('scroll', function(){
        if (shown >= rows.length) return;
        if (options.scrollTop + options.clientHeight >= options.scrollHeight - 80) { shown += PAGE; render(); }
    });
    document.addEventListener('click', function(e){ if (!wrap.contains(e.target)) close(); });

    paint();
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

    /* `input.mt-color-text` OR `select.mt-color-text`. Not every token in the
       schema is a colour -- the Gradient direction is a select -- and a row that
       this cannot find is a row the style chips silently fail to write and the
       scope switch silently fails to swap, with nothing anywhere saying so. */
    function textFor(name){ return form.querySelector('.mt-color-text[data-var="' + name + '"]'); }
    function swatchFor(name){ return form.querySelector('input.mt-color-swatch-input[data-for="' + name + '"]'); }
    // The scope you are NOT looking at, carried in a hidden twin of every row.
    function otherFor(name){ return form.querySelector('input.mt-color-other[data-var="' + name + '"]'); }

    function syncSwatch(name, value){
        var sw = swatchFor(name); if (!sw) return;
        /* The visible face is the LABEL, painted with the raw value, so an
           rgba row shows its actual translucency. The input inside it only
           ever holds an opaque hex for the native picker to open on. */
        var face = sw.parentNode && sw.parentNode.classList
            && sw.parentNode.classList.contains('mt-color-swatch') ? sw.parentNode : null;
        var raw = String(value == null ? '' : value).trim();
        if (face) {
            // Empty is a STATE, not a colour: show the slash, and hand the
            // picker a mid grey so opening it does not start from black.
            face.classList.toggle('is-empty', raw === '');
            face.style.background = raw === '' ? '' : raw;
        }
        if (raw === '') { sw.value = '#888888'; return; }
        var h = clean(raw);
        if (h) { sw.value = '#' + h; return; }
        var rgb = toRgb(raw);
        if (rgb) sw.value = toHex(rgb);
    }
    function setToken(name, value){
        var t = textFor(name); if (!t) return;
        t.value = value;
        syncSwatch(name, value);
    }

    [].slice.call(form.querySelectorAll('input.mt-color-swatch-input')).forEach(function(sw){
        sw.addEventListener('input', function(){
            var name = sw.getAttribute('data-for'), t = textFor(name);
            if (!t) return;
            /* Keep the row's ALPHA. Writing the picker's bare hex straight in
               turned rgba(246,246,248,0.80) into #f6f6f8 -- one click silently
               destroying the frosted nav that those tokens' own hints warn
               about ("keep some alpha or the frost effect is lost"), on five
               rows of the nav group. Same "output format follows the ROW" rule
               the generator already applies. */
            var cur = parseCol(t.value);
            t.value = (cur && cur.a !== null) ? rgba(toRgb(sw.value), cur.a) : sw.value;
            syncSwatch(name, t.value);
        });
    });
    [].slice.call(form.querySelectorAll('input.mt-color-text')).forEach(function(t){
        t.addEventListener('input', function(){ syncSwatch(t.getAttribute('data-var'), t.value); });
    });

    /* Accent presets. Two things were wrong here and both are the same shape as
       the generator's bug: it wrote only the scope on screen, and it wrote
       through setToken, which assigns .value directly and fires no input event
       -- so the dark-follows-light link never heard about it either.

       It also FROZE the three rows that are meant to derive. Writing a literal
       into accent hover, link and link hover is exactly what their own hints
       warn against ("Set a value only to break that link"), so a preset was
       quietly pinning the very family it was supposed to move. They are reset
       to their defaults instead, which lets core-theme.css derive them from
       the new accent. */
    function applyAccentPreset(hex){
        var h = clean(hex); if (!h) return;
        // Always drive from the LIGHT scope: propagate() reads the visible
        // input as light and the hidden twin as dark, so a preset clicked while
        // viewing Dark has to swap first or it writes the pair backwards.
        var wasDark = curScope() === 'dark';
        if (wasDark) swapScope('light');

        setToken('--color-accent', '#' + h);
        propagate('--color-accent');          // dark follows by the shipped delta

        // The tint is the accent at whatever alpha each scope's default carries
        var accD = otherFor('--color-accent');
        [['--color-accent-light', textFor, '#' + h], ['--color-accent-light', otherFor, accD && accD.value]]
            .forEach(function(spec){
                var el = spec[1]('--color-accent-light'); if (!el || !spec[2]) return;
                var d = parseCol(el.getAttribute('data-default')), src = parseCol(spec[2]);
                if (!src) return;
                var v = (d && d.a !== null) ? rgba(src.rgb, d.a) : toHex(src.rgb);
                if (spec[1] === textFor) setToken('--color-accent-light', v); else el.value = v;
            });

        ['--color-accent-hover', '--color-link', '--color-link-hover'].forEach(function(n){
            var t = textFor(n), o = otherFor(n);
            if (t) setToken(n, t.getAttribute('data-default'));
            if (o) o.value = o.getAttribute('data-default');
        });

        if (wasDark) swapScope('dark');
        sbtRefresh();
    }
    /* Mark the preset the current Accent actually matches. Nothing stored which
       preset was picked -- and nothing should, since every field is editable
       afterwards -- so it is DERIVED from the accent each time. That also means
       it lights up when the accent arrives by any route: a preset click, the
       generator, or typing the hex by hand. */
    function markActivePreset(){
        var cur = clean(fieldVal('--color-accent'));
        [].slice.call(form.querySelectorAll('.mt-scheme[data-accent]')).forEach(function(c){
            c.classList.toggle('is-active', !!cur && clean(c.getAttribute('data-accent')) === cur);
        });
    }
    [].slice.call(form.querySelectorAll('.mt-scheme[data-accent]')).forEach(function(chip){
        chip.addEventListener('click', function(){
            applyAccentPreset(chip.getAttribute('data-accent'));
            markActivePreset();
        });
    });
    form.addEventListener('input', markActivePreset);
    markActivePreset();

    /* ------------------------------------------------------------------
       Light <-> Dark without a reload.

       Every row carries its other scope in a hidden twin, so switching is a
       swap of values and defaults rather than a page load: no round trip, and
       nothing unsaved is thrown away. Both post, and saveColorsAction writes
       both, so one Save covers light and dark.
       ------------------------------------------------------------------ */
    var scopeField  = form.querySelector('input[name="scope"]');
    var scopeSwitch = form.querySelector('[data-scope-switch]');
    function curScope(){ return scopeField && scopeField.value === 'dark' ? 'dark' : 'light'; }

    /* Dark shows fewer rows than Light. 14 of the 57 ship the same value in
       both modes -- the nine icon tiles, the three status bases,
       --color-on-accent, --sidebar-color -- so in Dark they are not a decision,
       they are the same question asked twice. Hidden there, with a count and a
       way back: "the default matches" is not "you may never differ here".

       Hidden, not removed. The inputs still post, so their values survive
       untouched and saveColorsAction drops them for equalling the default. */
    var sharedShown = false;
    function applyShared(){
        var dark = curScope() === 'dark', hide = dark && !sharedShown, n = 0;
        [].slice.call(form.querySelectorAll('.mt-color-row[data-shared]')).forEach(function(r){
            r.hidden = hide; n++;
        });
        // A group whose rows all vanished should not leave a heading behind
        [].slice.call(form.querySelectorAll('.mt-color-rows')).forEach(function(g){
            var vis = [].slice.call(g.querySelectorAll('.mt-color-row')).some(function(r){ return !r.hidden; });
            var sec = g.closest('.mt-section');
            if (sec) sec.hidden = !vis;
        });
        var note = form.querySelector('.mt-shared-note');
        if (note) {
            note.hidden = !dark;
            var c = note.querySelector('.mt-shared-count');
            if (c) c.textContent = n + (n === 1 ? ' colour is' : ' colours are');
            var b = note.querySelector('.mt-shared-toggle');
            if (b) b.textContent = sharedShown ? 'Hide them' : 'Show them';
        }
    }
    var sharedBtn = form.querySelector('.mt-shared-toggle');
    if (sharedBtn) sharedBtn.addEventListener('click', function(){
        sharedShown = !sharedShown; applyShared();
    });
    applyShared();   // the page can load straight into the dark scope

    /* ------------------------------------------------------------------
       Linked rows. Two links, one idiom: a row keeps following until you
       set it yourself, exactly as the Accent hover row has always described.

       (1) FOLLOWS -- the seven sidebar rows already track the page ramp in
           CSS. The panel now mirrors the source into them so the swatch is
           not stale, instead of restating a literal that freezes on touch.

       (2) DARK FOLLOWS LIGHT -- by each token's OWN shipped relationship,
           not one global rule. There is no global rule: the lightness gap
           between the shipped pairs runs from 0.03 on --color-text-tertiary
           to 1.00 on the alpha-flip rows, with --color-surface at 0.71.
           Taking the delta from each row's own two defaults reproduces the
           shipped pair exactly when nothing has been touched, and carries
           the same relationship onto whatever you pick.

       A row that already carries a stored override starts UNLINKED, so
       loading a saved palette never silently rewrites it.
       ------------------------------------------------------------------ */
    /* TWO links, tracked separately, because breaking one must not break the
       other: setting a sidebar colour by hand should stop it following the
       page ramp, but its own dark counterpart should still track it. */
    var manualDark = {};    // this row's dark no longer follows its light
    var manualFollow = {};  // this row no longer follows its source row
    function normv(s){ return String(s == null ? '' : s).trim().toLowerCase().replace(/\s+/g, ''); }
    var followers = {}, isFollower = {};
    [].slice.call(form.querySelectorAll('.mt-color-row[data-follows]')).forEach(function(r){
        var src = r.getAttribute('data-follows'), tgt = r.getAttribute('data-var');
        (followers[src] = followers[src] || []).push(tgt);
        isFollower[tgt] = true;
    });
    // A stored override means the buyer already decided; never rewrite it.
    [].slice.call(form.querySelectorAll('input.mt-color-other')).forEach(function(o){
        var n = o.getAttribute('data-var'), t = textFor(n);
        if (normv(o.value) !== normv(o.getAttribute('data-default'))) manualDark[n] = true;
        if (isFollower[n] && t && normv(t.value) !== normv(t.getAttribute('data-default'))) manualFollow[n] = true;
    });

    /* The dark counterpart of a light value, carrying this row's shipped
       light->dark delta in OKLCH. Alpha is taken from the dark default
       outright rather than shifted: the alpha bumps are fixed steps
       (0.10 -> 0.16), not a function of the colour. */
    function darkFrom(name, lightStr){
        var t = textFor(name), o = otherFor(name);
        if (!t || !o) return null;
        var dl = parseCol(t.getAttribute('data-default')),
            dd = parseCol(o.getAttribute('data-default')),
            cur = parseCol(lightStr);
        if (!dl || !dd || !cur) return null;
        var a = toLch(dl.rgb), b = toLch(dd.rgb), c = toLch(cur.rgb);
        return fmtCol(lchToRgb(
            Math.max(0, Math.min(1, c.L + (b.L - a.L))),
            Math.max(0, c.C + (b.C - a.C)),
            ((c.H + (b.H - a.H)) % 360 + 360) % 360
        ), dd.a);
    }

    function propagate(name){
        var t = textFor(name); if (!t) return;
        /* This row's own dark counterpart FIRST. Followers copy the source's
           dark value, so recomputing it afterwards would hand them the stale
           one -- the sidebar text kept the shipped dark while the page text
           had already moved. */
        var o = otherFor(name);
        if (o && !manualDark[name]) {
            var v = darkFrom(name, t.value);
            if (v) o.value = v;
        }
        // ...then the rows that follow this one, in both scopes at once
        (followers[name] || []).forEach(function(tgt){
            if (manualFollow[tgt]) return;
            if (textFor(tgt)) setToken(tgt, t.value);
            var to = otherFor(tgt);
            if (to && o && !manualDark[tgt]) to.value = o.value;
        });
    }

    form.addEventListener('input', function(e){
        var el = e.target;
        if (!el || !el.getAttribute) return;
        var name = el.classList && el.classList.contains('mt-color-text')
            ? el.getAttribute('data-var')
            : (el.classList && el.classList.contains('mt-color-swatch-input')
                ? el.getAttribute('data-for') : null);
        if (!name) return;
        /* Editing while looking at Dark IS editing the dark value, so it
           breaks that link rather than driving it. Editing in Light drives. */
        if (curScope() === 'dark') { manualDark[name] = true; return; }
        /* Setting a follower by hand stops it following its source -- but its
           own dark counterpart still tracks it, which is why the two flags are
           separate. Without this, editing the sidebar border then editing the
           page border overwrote the sidebar again. */
        if (isFollower[name]) manualFollow[name] = true;
        propagate(name);
    });
    function swapScope(want){
        if (want === curScope()) return;
        [].slice.call(form.querySelectorAll('input.mt-color-text')).forEach(function(t){
            var name = t.getAttribute('data-var'), o = otherFor(name);
            if (!o) return;
            var v = t.value, d = t.getAttribute('data-default');
            t.value = o.value; t.setAttribute('data-default', o.getAttribute('data-default'));
            o.value = v;       o.setAttribute('data-default', d);
            syncSwatch(name, t.value);
        });
        // Anything holding a per-scope value has to swap with them, or it goes
        // on describing the scope you just left.
        [].slice.call(form.querySelectorAll('[data-sbt-tokens]')).forEach(function(b){
            ['-tokens', '-css'].forEach(function(sfx){
                var a = b.getAttribute('data-sbt' + sfx), z = b.getAttribute('data-sbt' + sfx + '-other');
                b.setAttribute('data-sbt' + sfx, z === null ? '' : z);
                b.setAttribute('data-sbt' + sfx + '-other', a === null ? '' : a);
            });
        });
        var genEl = form.querySelector('.mt-gen');
        if (genEl) genEl.setAttribute('data-scope', want);
        if (scopeField) scopeField.value = want;
        if (scopeSwitch) [].slice.call(scopeSwitch.querySelectorAll('[data-scope-set]')).forEach(function(x){
            x.classList.toggle('is-active', x.getAttribute('data-scope-set') === want); });
        sbtRefresh();
        applyShared();
    }
    if (scopeSwitch) scopeSwitch.addEventListener('click', function(e){
        var b = e.target.closest('[data-scope-set]');
        if (b) swapScope(b.getAttribute('data-scope-set'));
    });

    var reset = form.querySelector('#mt-colors-reset');
    if (reset) reset.addEventListener('click', function(){
        // Both scopes: "Reset all to default" that left dark overridden would
        // be a reset in name only, now that one Save writes both.
        [].slice.call(form.querySelectorAll('input.mt-color-text')).forEach(function(t){
            setToken(t.getAttribute('data-var'), t.getAttribute('data-default'));
        });
        [].slice.call(form.querySelectorAll('input.mt-color-other')).forEach(function(o){
            o.value = o.getAttribute('data-default');
        });
        genUndoState(null);
    });

    /* ------------------------------------------------------------------
       Sidebar style presets.

       A STYLE IS A SET OF COLOURS. Clicking a chip writes that style's whole
       token set into the sidebar rows -- the same thing the palette generator
       does for the palette -- and every row keeps its own picker afterwards.
       Nothing is stored until Save colors, and saveColorsAction still drops any
       row that ends up equal to its default.

       An earlier pass had a style be ONE value that the CSS derivation expanded.
       That left these ten rows inert: whatever you typed into them was
       overridden by the derived value, so the pickers were decoration.

       Values may contain var(--color-accent). The admin has no --color-accent of
       its own, so the Accent FIELD is substituted and the browser resolves the
       color-mix() down to a literal at click time. Correct for the accent you
       have; re-pick to follow a rebrand. That is the trade for keeping the rows
       editable, since what gets stored has to be a literal either way.

       Placed above the generator's early return: the presets are not part of the
       generator and must still work if that section is absent.
       ------------------------------------------------------------------ */
    var sbt = form.querySelector('[data-sbt]');
    var sbtRefresh = function(){};
    if (sbt) {
        /* Resolving CSS to a literal needs somewhere to compute it. The probe
           lives inside the form so it inherits the same context, and the canvas
           converts whatever colour space the browser hands back -- color-mix()
           computes to color(srgb ...), which is not something the save path
           accepts. */
        /* The probe sits inside a wrapper whose colour is a sentinel, because a
           failed var() does NOT leave the previous value behind -- it is
           invalid at computed-value time, and for an inherited property that
           means INHERIT. Without the wrapper every unresolvable style quietly
           produced the admin's own text colour and stored it as if it had
           worked: eleven rows of #1d1d1f. */
        var sbWrap = document.createElement('span');
        sbWrap.style.display = 'none';
        sbWrap.style.color = 'rgb(1, 2, 3)';
        var sbProbe = document.createElement('span');
        sbWrap.appendChild(sbProbe);
        form.appendChild(sbWrap);
        var sbCvs = document.createElement('canvas'); sbCvs.width = sbCvs.height = 1;
        var sbCtx = sbCvs.getContext('2d', { willReadFrequently: true });

        function sbAccent(other){
            var el = other ? otherFor('--color-accent') : textFor('--color-accent');
            var h = el ? clean(el.value) : null;
            return h ? '#' + h : '#0071e3';
        }
        /* Declare the token ON the probe rather than string-substituting it.
           A style value is CSS, so let CSS resolve it: any token a future style
           references just needs declaring here, and there is no regex to get
           wrong. (The regex version silently matched nothing.) */
        function sbResolve(css, other){
            // Each scope resolves against ITS OWN accent, which is the whole
            // reason a style can fill both at once and be right in each.
            sbProbe.style.setProperty('--color-accent', sbAccent(other));
            sbProbe.style.color = '';
            sbProbe.style.color = String(css);
            var c = getComputedStyle(sbProbe).color;
            if (!c || c === 'rgb(1, 2, 3)') return null;
            sbCtx.clearRect(0, 0, 1, 1);
            sbCtx.fillStyle = '#000'; sbCtx.fillStyle = c;
            sbCtx.fillRect(0, 0, 1, 1);
            var d = sbCtx.getImageData(0, 0, 1, 1).data, a = d[3] / 255;
            // Output must match what the row expects: hex when opaque, rgba when
            // not. isColor() accepts both and nothing else.
            return a >= 0.999 ? toHex([d[0], d[1], d[2]])
                              : rgba([d[0], d[1], d[2]], Math.round(a * 100) / 100);
        }

        // Which rows a style owns, learned from the styles themselves so Light
        // resets exactly the set the others write.
        var sbRows = {};
        [].slice.call(sbt.querySelectorAll('.mt-sbt-mode')).forEach(function(b){
            var raw = b.getAttribute('data-sbt-tokens'); if (!raw) return;
            try { Object.keys(JSON.parse(raw)).forEach(function(v){ sbRows[v] = true; }); }
            catch (e) {}
        });

        function sbPaintDots(){
            // Same trick as the probe: declare the token on the container and
            // the chips' own var() references resolve against it.
            sbt.style.setProperty('--color-accent', sbAccent());
            [].slice.call(sbt.querySelectorAll('.mt-sbt-mode')).forEach(function(b){
                var dot = b.querySelector('.mt-sbt-dot'); if (!dot) return;
                var css = b.getAttribute('data-sbt-css');
                // Light has no CSS of its own: it IS --sidebar-bg's default,
                // which is literally what the nav renders untinted.
                dot.style.background = css || defVal('--sidebar-bg') || '#f6f6f8';
            });
        }
        function sbApply(btn){
            [].slice.call(sbt.querySelectorAll('.mt-sbt-mode')).forEach(function(b){
                b.classList.toggle('is-active', b === btn); });
            var raw = btn.getAttribute('data-sbt-tokens');
            if (!raw) {
                // Light: reset rather than write, so the rows go back to being
                // unstored and saveColorsAction persists nothing for them.
                // Both scopes, or picking Light would leave dark still tinted.
                Object.keys(sbRows).forEach(function(v){
                    var t = textFor(v), o = otherFor(v);
                    if (t) setToken(v, t.getAttribute('data-default'));
                    if (o) o.value = o.getAttribute('data-default');
                });
                return;
            }
            /* Fill BOTH scopes. A style is a look, not a light-mode look, and
               the buyer's dark mode is a click away on the same page -- having
               to switch scope and pick again would be the reload we just
               removed, wearing a different hat. */
            var auto = btn.getAttribute('data-sbt-autoink') === '1';
            var fill = function(json, other){
                if (!json) return;
                var map; try { map = JSON.parse(json); } catch (e) { return; }
                var put = function(v, lit){
                    if (other) { var o = otherFor(v); if (o) o.value = lit; }
                    else setToken(v, lit);
                };
                Object.keys(map).forEach(function(v){
                    var lit = sbResolve(map[v], other);
                    if (lit) put(v, lit);
                });
                /* Ink chosen from the RESOLVED background, at the WCAG
                   crossover, for styles that say so -- the same primitive the
                   theme uses. Without it a pale brand keeps the hardcoded white
                   ramp and measures 2.6:1, and no amount of deepening the
                   background rescues it because a deepened yellow is still
                   light. Runs after the loop so it overrides the declared ink. */
                if (!auto) return;
                var bgLit = sbResolve(map['--sidebar-bg'], other);
                if (!bgLit) return;
                var c = toRgb(bgLit) || [0, 0, 0];
                var f = function(x){ x /= 255; return x <= 0.03928 ? x/12.92 : Math.pow((x+0.055)/1.055, 2.4); };
                var dark = (0.2126*f(c[0]) + 0.7152*f(c[1]) + 0.0722*f(c[2])) > 0.179129;
                var ink = dark ? '0,0,0' : '255,255,255';
                put('--sidebar-text', dark ? '#000000' : '#ffffff');
                [['--sidebar-text-secondary', dark ? 0.78 : 0.82],
                 ['--sidebar-text-muted',     dark ? 0.62 : 0.70],
                 ['--sidebar-text-faint',     dark ? 0.45 : 0.55],
                 ['--sidebar-border',         dark ? 0.16 : 0.20],
                 ['--sidebar-field-bg',       dark ? 0.10 : 0.16],
                 ['--sidebar-item-hover-bg',  dark ? 0.08 : 0.14],
                 ['--sidebar-item-active-bg', dark ? 0.14 : 0.22],
                 ['--sidebar-scroll-thumb',   dark ? 0.22 : 0.30]
                ].forEach(function(p){ put(p[0], 'rgba(' + ink + ',' + p[1] + ')'); });
            };
            fill(raw, false);
            fill(btn.getAttribute('data-sbt-tokens-other'), true);
        }
        sbt.addEventListener('click', function(e){
            var b = e.target.closest('.mt-sbt-mode'); if (b) sbApply(b);
        });
        /* WHICH STYLE IS IN FORCE is a property of the saved values, not of the
           markup. It used to be hardcoded onto the Light chip, so every reload
           claimed Light: the colours applied correctly on the site while the
           panel disagreed with itself, which reads as "my save was lost".

           Compare, not guess. A chip is active when EVERY token it would write
           already equals what the field holds -- both scopes, since a style
           fills both and matching one alone would call a half-applied style
           active. Resolution goes through sbResolve, the same path sbApply
           writes with, so a color-mix() recipe and a stored literal are compared
           as the same colour rather than as two different strings.

           Nothing matching is a real answer and stays unmarked: a buyer who
           hand-edited one row is not on any style, and lighting a chip up would
           claim their edit away. Light is the exception -- it IS the defaults,
           so it matches when every row the styles touch sits at its default. */
        function sbDetectActive(){
            var modes = [].slice.call(sbt.querySelectorAll('.mt-sbt-mode'));
            var same = function(a, b){
                return String(a || '').trim().toLowerCase().replace(/\s+/g, '')
                    === String(b || '').trim().toLowerCase().replace(/\s+/g, '');
            };
            var matches = function(json, other){
                if (!json) return true;              // no set for this scope -> nothing to contradict
                var map; try { map = JSON.parse(json); } catch (e) { return false; }
                return Object.keys(map).every(function(v){
                    var el = other ? otherFor(v) : textFor(v);
                    if (!el) return true;            // row not on the page (hidden scope) -> ignore
                    var lit = sbResolve(map[v], other);
                    return lit ? same(el.value, lit) : true;
                });
            };
            var hit = null;
            modes.forEach(function(b){
                if (hit || b.getAttribute('data-sbt-mode') === 'off') return;
                if (matches(b.getAttribute('data-sbt-tokens'), false)
                 && matches(b.getAttribute('data-sbt-tokens-other'), true)) { hit = b; }
            });
            if (!hit) {
                // Light: every row the styles touch is at its default.
                var allDefault = Object.keys(sbRows).every(function(v){
                    var t = textFor(v);
                    return !t || same(t.value, t.getAttribute('data-default'));
                });
                if (allDefault) { hit = modes[0]; }
            }
            modes.forEach(function(b){ b.classList.toggle('is-active', b === hit); });
        }

        sbtRefresh = sbPaintDots;
        /* Delegated, because the Accent changes without its own field ever
           firing input: the swatch handler assigns .value directly and the
           generator writes through setToken. Repainting five dots is free. */
        form.addEventListener('input', sbPaintDots);
        if (reset) reset.addEventListener('click', function(){
            /* Re-derive rather than blank. "Restore defaults" puts every row
               back to its default, which IS the Light style -- clearing all the
               chips left the control claiming no style at all. Deferred a tick
               so it reads the fields the reset handler has just written. */
            setTimeout(sbDetectActive, 0);
        });
        sbPaintDots();
        sbDetectActive();
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

        var activeDark = gen.getAttribute('data-scope') === 'dark';
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
        var lifted = false, written = 0, cleared = 0;

        var before = PAIRS.map(function(p){ return pairRatio(p[0], p[1]); });
        // Snapshot BOTH scopes -- Undo has to put back what Generate touched,
        // and Generate now touches both.
        var snapshot = {};
        [].slice.call(form.querySelectorAll('input.mt-color-text')).forEach(function(t){
            var n = t.getAttribute('data-var'), o = otherFor(n);
            snapshot[n] = { v: t.value, o: o ? o.value : null };
        });

        /* Run the whole recipe once PER SCOPE. It used to run only for the one
           on screen, so generating in Light left Dark on the old palette -- and
           the dark-follows-light link could not rescue it either, because
           setToken assigns .value directly and fires no input event.

           Each scope resolves against its OWN accent and its OWN row defaults,
           which is the same reason the sidebar styles fill both: a palette is
           not a light-mode palette. */
        function runScope(isDark, other){
            var el   = function(n){ return other ? otherFor(n) : textFor(n); };
            var defOf = function(n){ var e = el(n); return e ? e.getAttribute('data-default') : null; };
            var put  = function(n, val){
                if (other) { var o = otherFor(n); if (o) o.value = val; }
                else setToken(n, val);
            };
            var A = isDark ? Ad : Al;

            /* THE BRAND ACCENT IS THE BRAND ACCENT, in both modes. An earlier
               version raised it in dark for legibility; the owner's call is
               that a brand colour does not change with the time of day, and
               for the 105 places it is a BACKGROUND that costs nothing --
               --color-on-accent picks its ink at the crossover either way. */
            var seed = { L: S.L, C: S.C, H: S.H };

            /* The link rows are the exception, and they are not a hedge. Light
               mode already makes link DARKER than the accent, because accent-
               coloured text on a card needs more contrast than an accent fill
               does; dark mode needs the same move in the other direction. Left
               deriving, dark ships --color-link as var(--color-accent) outright
               and a deep brand lands accent-coloured text at 2.6:1 -- 1.61:1
               for a purple. Lifted to the AA line instead. */
            var linkSeed = seed;
            if (isDark) {
                linkSeed = { L: Math.max(S.L, Ad.L),
                             C: S.C * (Al.C > 0.002 ? Ad.C / Al.C : 1), H: S.H };
                var surfDef = parseCol(defOf('--color-surface'));
                var guard = 0;
                while (surfDef && contrast(lchToRgb(linkSeed.L, linkSeed.C, linkSeed.H), surfDef.rgb) < 4.5
                       && linkSeed.L < 0.92 && guard++ < 80) {
                    linkSeed.L += 0.01; lifted = true;
                }
            }

            [].slice.call(form.querySelectorAll('input.mt-color-text')).forEach(function(t){
                var name = t.getAttribute('data-var'), cls = GEN_CLASS[name];
                if (!cls || cls === 'skip' || !want[cls]) return;
                var d = parseCol(defOf(name));
                if (!d) return;
                var T = toLch(d.rgb), out;

                if (name === '--color-accent') out = seed;
                else if (name === '--color-on-accent') {
                    // black or white at the exact WCAG crossover, against the NEW accent
                    put(name, lum(lchToRgb(seed.L, seed.C, seed.H)) > 0.179129 ? '#000000' : '#ffffff');
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

                put(name, fmtCol(lchToRgb(out.L, out.C, out.H), d.a));
                written++;
            });

            /* The three rows core-theme.css derives get RESET, not skipped.
               Left alone they keep whatever was pinned there before, and a
               pinned hover does not follow a rebrand -- generate a terracotta
               palette and the hover stays blue. Reset to default they are
               dropped by saveColorsAction and the @supports block derives them
               from the new accent. Their swatches still read stock, exactly as
               the row hint warns: writing the derived colour HERE would store
               it and freeze the very link it exists to preserve.
               --sidebar-color is left alone either way; a sidebar tint is a
               separate decision from a rebrand. */
            if (want.brand) {
                ['--color-accent-hover', '--color-link', '--color-link-hover'].forEach(function(n){
                    var e = el(n); if (!e) return;
                    /* In DARK the two link rows are written, not reset: the CSS
                       would otherwise derive them from an accent that is now
                       the unlifted brand colour. Accent hover still derives --
                       it is a fill, so its ink is handled at the crossover. */
                    if (isDark && n !== '--color-accent-hover') {
                        var L = n === '--color-link-hover'
                            ? Math.min(0.95, linkSeed.L + 0.05) : linkSeed.L;
                        put(n, toHex(lchToRgb(L, linkSeed.C, linkSeed.H)));
                        written++;
                        return;
                    }
                    if (e.value !== e.getAttribute('data-default')) cleared++;
                    put(n, e.getAttribute('data-default'));
                });
            }
        }
        runScope(activeDark, false);
        runScope(!activeDark, true);

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
            + (lifted ? ' &middot; the accent is identical in both modes; dark <b>link</b> colours were lifted to stay legible on a dark card' : '')
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
        Object.keys(prev).forEach(function(k){
            setToken(k, prev[k].v);
            var o = otherFor(k);
            if (o && prev[k].o !== null) o.value = prev[k].o;   // the other scope too
        });
        genUndoState(null);
        sbtRefresh();
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
        // Optional "Learn more" line -- shown only when the trigger carries
        // data-tip-href (includes/tip.tpl's article/anchor params). A real
        // <a>, not innerHTML on txt: data-tip is plain-text escaped copy, and
        // building a link by string-concatenating it into markup would be an
        // XSS hole the moment any tip text ever contained a stray "<".
        var link = document.createElement('a');
        link.className = 'mt-tip-link';
        link.target = '_blank';
        link.rel = 'noopener';
        link.textContent = 'Learn more';
        pop.appendChild(link);
        pop._link = link;
        document.body.appendChild(pop);
        // A hover onto the panel itself keeps it open (so it can be read/copied,
        // and so the Learn more link is reachable by mouse without the popup
        // vanishing on the trip from trigger to link).
        pop.addEventListener('mouseenter', function(){ clearTimeout(hideT); });
        pop.addEventListener('mouseleave', hideSoon);
    }
    function bottomLimit(){
        // A page-level Save bar (includes/savebar.tpl) is position:fixed at
        // the viewport bottom, z-index 80. .mt-tip-pop's 10000 paints over it
        // fine, but window.innerHeight alone doesn't know the bar is there --
        // so a tip on the page's last row(s) sized "below" against the full
        // viewport and could open straight into the bar's band, dragging the
        // "Learn more" link into it too. Clamp against whichever savebar is
        // actually on screen (pages that render several panels give each its
        // own bar with [hidden] on the rest -- those collapse to a zero rect).
        var bars = document.querySelectorAll('.mt-savebar');
        for (var i = 0; i < bars.length; i++) {
            var br = bars[i].getBoundingClientRect();
            if (br.height > 0) return br.top;
        }
        return window.innerHeight;
    }
    function place(btn){
        var r = btn.getBoundingClientRect();
        pop.style.visibility = 'hidden'; pop.style.display = 'block';
        pop.style.left = '0px'; pop.style.top = '0px';
        var ph = pop.offsetHeight, pw = pop.offsetWidth;
        var limit = bottomLimit();
        var below = limit - r.bottom - 10, above = r.top - 10;
        var side = (ph <= below || below >= above) ? 'bottom' : 'top';
        pop.setAttribute('data-side', side);
        var top = side === 'bottom' ? r.bottom + 8 : r.top - ph - 8;
        var mid = r.left + r.width / 2;
        var left = Math.max(8, Math.min(mid - pw / 2, window.innerWidth - pw - 8));
        pop.style.top = Math.max(8, Math.min(top, limit - ph - 8)) + 'px';
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
        var href = btn.getAttribute('data-tip-href');
        if (href) { pop._link.href = href; pop._link.hidden = false; }
        else { pop._link.removeAttribute('href'); pop._link.hidden = true; }
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
