/*
 * The customizer (admin: Styles -> Open the customizer).
 *
 * Controls on the left, the real site in a frame on the right. Nothing here
 * is saved until Save is pressed: each change is posted to the admin's
 * session (sub=preview-ajax) and the frame, which carries that session's
 * preview token in its URL, draws it. See Helpers\CustomizePreview.
 *
 * A colour edit repaints the frame in place by rewriting the theme's own
 * <style id="hadrian-colors"> block. A style or layout change reloads the
 * frame, because the server decides the markup for those.
 *
 * Inlined into the page by CustomizeController, like the rest of the admin's
 * scripts, so it does not depend on the addon folder being web-reachable.
 */
(function () {
  'use strict';

  var dataEl = document.getElementById('mt-cz-data');
  var root = document.getElementById('mt-cz');
  if (!dataEl || !root) { return; }

  var D = JSON.parse(dataEl.textContent);
  var frame = root.querySelector('[data-cz-frame]');
  var viewport = root.querySelector('[data-cz-viewport]');
  // Save, Discard and the status line sit in the page header, outside #mt-cz.
  var $ = function (sel) { return document.querySelector(sel); };
  var clone = function (o) { return JSON.parse(JSON.stringify(o)); };
  var el = function (tag, attrs, text) {
    var node = document.createElement(tag);
    Object.keys(attrs || {}).forEach(function (k) { node.setAttribute(k, attrs[k]); });
    if (text !== undefined) { node.textContent = text; }
    return node;
  };

  // PHP prints an empty map as []; every colour set here must be an object.
  var asMap = function (x) { return x && typeof x === 'object' && !Array.isArray(x) ? x : {}; };
  var fixState = function (s) {
    s.colors = { light: asMap(s.colors && s.colors.light), dark: asMap(s.colors && s.colors.dark) };
    return s;
  };

  // ------------------------------------------------------------- the model
  var tokens = {};                       // var -> {label, group, light, dark}
  Object.keys(D.groups).forEach(function (g) {
    D.groups[g].forEach(function (t) { tokens[t['var']] = t; });
  });

  var saved = fixState(clone(D.saved));
  var state = clone(saved);

  // Colours being tried, per style, so switching style and back keeps them.
  // Only the selected style's colours are saved.
  var palette = {};
  var resetPalette = function () {
    Object.keys(D.schemes).forEach(function (name) {
      palette[name] = { light: Object.assign({}, asMap(D.schemes[name].colors.light)), dark: Object.assign({}, asMap(D.schemes[name].colors.dark)) };
    });
    palette[state.style] = state.colors;
  };
  resetPalette();

  var norm = function (v) { return String(v).replace(/\s+/g, '').toLowerCase(); };
  var COLOR = [
    /^#([0-9a-fA-F]{3,4}|[0-9a-fA-F]{6}|[0-9a-fA-F]{8})$/,
    /^rgba?\(\s*\d{1,3}\s*,\s*\d{1,3}\s*,\s*\d{1,3}\s*(,\s*(?:0|1|0?\.\d+)\s*)?\)$/i,
    /^hsla?\(\s*\d{1,3}\s*,\s*\d{1,3}%\s*,\s*\d{1,3}%\s*(,\s*(?:0|1|0?\.\d+)\s*)?\)$/i
  ];
  var isColor = function (v) { v = String(v).trim(); return COLOR.some(function (re) { return re.test(v); }); };
  // The one schema token that is not a colour (Helpers\ColorTokens).
  var accepts = function (name, v) {
    return name === '--sidebar-grad-angle' ? /^\d{1,3}deg$/.test(String(v).trim()) : isColor(v);
  };

  var scope = function () { return state.theme === 'dark' ? 'dark' : 'light'; };
  var valueOf = function (sc, name) {
    var v = state.colors[sc][name];
    return v !== undefined ? v : tokens[name][sc];
  };
  var shippedOf = function (sc, name) {
    var v = asMap(D.schemes[state.style].shipped[sc])[name];
    return v !== undefined ? v : tokens[name][sc];
  };
  var setColor = function (sc, name, v) {
    if (norm(v) === norm(tokens[name][sc])) { delete state.colors[sc][name]; } else { state.colors[sc][name] = String(v).trim(); }
  };

  // The same text Helpers\ColorTokens::css() prints on the server.
  var colorsCss = function () {
    return ['light', 'dark'].map(function (sc) {
      var decls = Object.keys(state.colors[sc]).map(function (name) { return name + ':' + state.colors[sc][name] + ';'; }).join('');
      return decls ? D.selectors[sc] + '{' + decls + '}' : '';
    }).join('');
  };

  // For <input type="color">, which takes #rrggbb only: let the browser
  // resolve whatever form the value is in.
  var probe = el('span', { style: 'display:none' });
  root.appendChild(probe);
  var toHex = function (v) {
    probe.style.color = '';
    probe.style.color = v;
    var m = /rgba?\(\s*(\d+)[,\s]+(\d+)[,\s]+(\d+)/.exec(getComputedStyle(probe).color || '');
    if (!m || !probe.style.color) { return '#888888'; }
    return '#' + [m[1], m[2], m[3]].map(function (n) { return ('0' + Number(n).toString(16)).slice(-2); }).join('');
  };

  // ------------------------------------------------------------- the frame
  var DEVICES = { desktop: 1280, tablet: 820, phone: 390 };
  var device = 'desktop';
  var currentPath = D.pages[0].path;
  var frameLoads = 0;
  var frameBusy = true;

  var frameUrl = function (path) {
    return D.siteRoot + path + (path.indexOf('?') < 0 ? '?' : '&') + encodeURIComponent(D.param) + '=' + encodeURIComponent(D.token);
  };
  var frameDoc = function () {
    try { return frame.contentDocument; } catch (e) { return null; }
  };

  // Lay the frame out at the device's real width and scale it to fit, so a
  // desktop page is not squeezed into tablet rules by the panel beside it.
  var fitFrame = function () {
    var w = DEVICES[device];
    var box = viewport.getBoundingClientRect();
    var s = Math.min(1, box.width / w);
    frame.style.width = w + 'px';
    frame.style.height = Math.round(box.height / s) + 'px';
    frame.style.transform = 'scale(' + s + ')';
    frame.style.marginLeft = Math.max(0, Math.round((box.width - w * s) / 2)) + 'px';
  };

  var paintFrame = function () {
    var doc = frameDoc();
    if (!doc || !doc.documentElement) { return; }
    var block = doc.getElementById('hadrian-colors');
    if (block) { block.textContent = colorsCss(); }
    doc.documentElement.setAttribute('data-theme', state.theme);
  };

  var loadFrame = function (path) {
    currentPath = path || currentPath;
    frameBusy = true;
    root.setAttribute('data-cz-loading', '1');
    frame.src = frameUrl(currentPath);
  };

  frame.addEventListener('load', function () {
    frameLoads += 1;
    frameBusy = false;
    root.removeAttribute('data-cz-loading');
    var doc = frameDoc();
    var inPreview = !!(doc && doc.documentElement && doc.documentElement.getAttribute('data-hadrian-preview') === '1');
    $('[data-cz-outside]').hidden = inPreview;
    if (inPreview) {
      paintFrame();
      // Keep the page list in step when a link inside the frame was followed.
      try {
        var here = frame.contentWindow.location;
        var rel = here.pathname.split('/').pop() + here.search;
        D.pages.forEach(function (p) {
          if (frameUrl(p.path).split('/').pop() === rel) { currentPath = p.path; $('[data-cz-page]').value = p.path; }
        });
      } catch (e) { /* cross-origin page: nothing to sync */ }
    }
  });

  // ------------------------------------------------------- talking to PHP
  var post = function (sub, payload) {
    var body = 'token=' + encodeURIComponent(D.csrf) + '&state=' + encodeURIComponent(JSON.stringify(payload));
    return fetch(D.endpoint + '&sub=' + sub, {
      method: 'POST',
      credentials: 'same-origin',
      headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
      body: body
    }).then(function (r) { return r.json(); }).then(function (json) {
      if (!json || !json.ok) { throw new Error((json && json.error) || 'The request was refused.'); }
      return json;
    });
  };

  var status = function (text, kind) {
    var node = $('[data-cz-status]');
    node.textContent = text || '';
    node.setAttribute('data-kind', kind || '');
  };

  var pushTimer = null;
  var pushSeq = 0;
  var queued = false;                    // a send is waiting on the timer
  var inFlight = 0;                      // sends the server has not answered
  var wantReload = false;
  var reloadOwed = false;
  // Send the state to the session. `reload` when the server has to redraw
  // the page (style, layouts); a colour or mode change repaints in place.
  var push = function (reload) {
    wantReload = wantReload || !!reload;
    refreshDirty();
    clearTimeout(pushTimer);
    queued = true;
    pushTimer = setTimeout(function () {
      var seq = ++pushSeq;
      var reloadNow = wantReload;
      wantReload = false;
      queued = false;
      inFlight += 1;
      post('preview-ajax', state).then(function () {
        inFlight -= 1;
        // Only the newest answer reloads: an older one describes a state
        // the frame should no longer be showing. The reload it asked for is
        // owed until the newest answer arrives.
        if (reloadNow) { reloadOwed = true; }
        if (seq === pushSeq && reloadOwed) { reloadOwed = false; loadFrame(); }
      }).catch(function (err) {
        inFlight -= 1;
        status(err.message, 'error');
      });
    }, reload ? 0 : 250);
  };

  var comparable = function (s) { return JSON.stringify([s.style, s.layouts, s.colors.light, s.colors.dark].map(sortKeys)); };
  function sortKeys(v) {
    if (!v || typeof v !== 'object' || Array.isArray(v)) { return v; }
    var out = {};
    Object.keys(v).sort().forEach(function (k) { out[k] = sortKeys(v[k]); });
    return out;
  }
  var isDirty = function () { return comparable(state) !== comparable(saved); };
  function refreshDirty() {
    var dirty = isDirty();
    $('[data-cz-save]').disabled = !dirty;
    $('[data-cz-discard]').disabled = !dirty;
    root.setAttribute('data-cz-dirty', dirty ? '1' : '0');
    if (dirty) { status('Unsaved changes. Only you see them.', ''); } else if ($('[data-cz-status]').getAttribute('data-kind') !== 'ok') { status('', ''); }
  }

  // -------------------------------------------------------------- schemes
  var renderSchemes = function () {
    var list = $('[data-cz-schemes]');
    list.textContent = '';
    Object.keys(D.schemes).forEach(function (name) {
      var sch = D.schemes[name];
      var colors = palette[name].light;
      var btn = el('button', { type: 'button', 'class': 'mt-cz-scheme' + (name === state.style ? ' is-on' : ''), 'data-cz-scheme': name });
      var sw = el('span', { 'class': 'mt-cz-swatch', 'aria-hidden': 'true' });
      [colors['--sidebar-bg'] || colors['--color-bg'] || tokens['--color-bg'].light, colors['--color-accent'] || tokens['--color-accent'].light].forEach(function (c) {
        var chip = el('i');
        chip.style.background = isColor(c) ? c : 'transparent';
        sw.appendChild(chip);
      });
      btn.appendChild(sw);
      var text = el('span', { 'class': 'mt-cz-scheme-text' });
      text.appendChild(el('strong', {}, sch.label));
      text.appendChild(el('small', {}, name === saved.style ? 'Active on the site' : sch.description));
      btn.appendChild(text);
      btn.addEventListener('click', function () {
        if (state.style === name) { return; }
        state.style = name;
        state.colors = palette[name];
        renderSchemes();
        renderColors();
        push(true);
      });
      list.appendChild(btn);
    });
  };

  // -------------------------------------------------------------- layouts
  var renderLayouts = function () {
    var box = $('[data-cz-layouts]');
    box.textContent = '';
    var mode = state.layouts.mode;

    var seg = el('div', { 'class': 'mt-cz-seg', role: 'group', 'aria-label': 'Choose layouts by' });
    [['audience', 'Visitor'], ['area', 'Area']].forEach(function (m) {
      var b = el('button', { type: 'button', 'data-cz-mode': m[0], 'class': m[0] === mode ? 'is-on' : '' }, m[1]);
      b.addEventListener('click', function () {
        if (state.layouts.mode === m[0]) { return; }
        state.layouts.mode = m[0];
        renderLayouts();
        push(true);
      });
      seg.appendChild(b);
    });
    var modeRow = el('div', { 'class': 'mt-cz-field' });
    modeRow.appendChild(el('span', { 'class': 'mt-cz-label' }, 'Choose layouts by'));
    modeRow.appendChild(seg);
    box.appendChild(modeRow);
    box.appendChild(el('p', { 'class': 'mt-cz-help' }, mode === 'area'
      ? 'One layout for each part of the site, whoever is looking.'
      : 'One layout for guests and one for signed-in clients, on every page.'));

    Object.keys(D.kindLabels).forEach(function (kind) {
      box.appendChild(el('h3', { 'class': 'mt-cz-sub' }, D.kindLabels[kind]));
      Object.keys(D.slots[mode]).forEach(function (slot) {
        var row = el('label', { 'class': 'mt-cz-field' });
        row.appendChild(el('span', { 'class': 'mt-cz-label' }, D.slots[mode][slot]));
        var sel = el('select', { 'class': 'mt-select', 'data-cz-layout': kind + ':' + slot });
        (D.layouts[kind] || []).forEach(function (l) {
          var opt = el('option', { value: l.name }, l.label);
          if (l.name === state.layouts[mode][kind][slot]) { opt.selected = true; }
          sel.appendChild(opt);
        });
        sel.addEventListener('change', function () {
          state.layouts[mode][kind][slot] = sel.value;
          push(true);
        });
        row.appendChild(sel);
        box.appendChild(row);
      });
    });
  };

  // -------------------------------------------------------------- colours
  var openGroups = {};
  var renderColors = function () {
    var box = $('[data-cz-colors]');
    box.textContent = '';
    var sc = scope();
    $('[data-cz-scope]').textContent = sc === 'dark' ? 'Dark mode colours' : 'Light mode colours';
    var first = true;
    Object.keys(D.groups).forEach(function (group) {
      var details = el('details', { 'class': 'mt-cz-group', 'data-cz-group': group });
      if (openGroups[group] === undefined ? first : openGroups[group]) { details.open = true; }
      first = false;
      details.addEventListener('toggle', function () { openGroups[group] = details.open; });
      var changed = D.groups[group].filter(function (t) { return norm(valueOf(sc, t['var'])) !== norm(shippedOf(sc, t['var'])); }).length;
      var summary = el('summary', {}, group);
      if (changed) { summary.appendChild(el('span', { 'class': 'mt-cz-count' }, String(changed))); }
      details.appendChild(summary);

      D.groups[group].forEach(function (t) {
        var name = t['var'];
        var row = el('div', { 'class': 'mt-cz-color', 'data-cz-token': name });
        row.appendChild(el('span', { 'class': 'mt-cz-color-label', title: name }, t.label));
        var picker = el('input', { type: 'color', 'aria-label': t.label + ' colour' });
        var text = el('input', { type: 'text', 'class': 'mt-input', spellcheck: 'false', 'aria-label': t.label + ' value' });
        var reset = el('button', { type: 'button', 'class': 'mt-cz-reset', title: "Back to the style's own value", 'aria-label': 'Reset ' + t.label }, '\u21BA');
        var isAngle = name === '--sidebar-grad-angle';
        var show = function () {
          var v = valueOf(sc, name);
          text.value = v;
          picker.value = toHex(v);
          picker.hidden = isAngle || v === '';
          reset.hidden = norm(v) === norm(shippedOf(sc, name));
          text.classList.remove('is-bad');
        };
        var apply = function (v) {
          setColor(sc, name, v);
          paintFrame();
          push(false);
          reset.hidden = norm(valueOf(sc, name)) === norm(shippedOf(sc, name));
        };
        picker.addEventListener('input', function () { text.value = picker.value; text.classList.remove('is-bad'); apply(picker.value); });
        text.addEventListener('change', function () {
          var v = text.value.trim();
          if (v === '' ) { apply(tokens[name][sc]); show(); return; }
          if (!accepts(name, v)) { text.classList.add('is-bad'); return; }
          apply(v);
          show();
        });
        reset.addEventListener('click', function () { apply(shippedOf(sc, name)); show(); renderSchemes(); });
        show();
        row.appendChild(picker);
        row.appendChild(text);
        row.appendChild(reset);
        details.appendChild(row);
      });
      box.appendChild(details);
    });
  };

  $('[data-cz-reset-all]').addEventListener('click', function () {
    ['light', 'dark'].forEach(function (sc) {
      Object.keys(state.colors[sc]).forEach(function (k) { delete state.colors[sc][k]; });
      Object.assign(state.colors[sc], asMap(D.schemes[state.style].shipped[sc]));
    });
    renderColors();
    renderSchemes();
    paintFrame();
    push(false);
  });

  // -------------------------------------------------------------- toolbar
  var pageSel = $('[data-cz-page]');
  var lastArea = null;
  var groupEl = null;
  D.pages.forEach(function (p) {
    if (p.area !== lastArea) {
      groupEl = el('optgroup', { label: p.areaLabel });
      pageSel.appendChild(groupEl);
      lastArea = p.area;
    }
    groupEl.appendChild(el('option', { value: p.path }, p.label));
  });
  pageSel.addEventListener('change', function () { loadFrame(pageSel.value); });

  root.querySelectorAll('[data-cz-device]').forEach(function (b) {
    b.addEventListener('click', function () {
      device = b.getAttribute('data-cz-device');
      root.querySelectorAll('[data-cz-device]').forEach(function (o) { o.classList.toggle('is-on', o === b); });
      fitFrame();
    });
  });

  var themeBtns = root.querySelectorAll('[data-cz-theme]');
  var showTheme = function () {
    themeBtns.forEach(function (b) { b.classList.toggle('is-on', b.getAttribute('data-cz-theme') === state.theme); });
  };
  themeBtns.forEach(function (b) {
    b.addEventListener('click', function () {
      state.theme = b.getAttribute('data-cz-theme');
      showTheme();
      renderColors();
      paintFrame();
      push(false);
    });
  });
  if (!D.darkMode) { $('[data-cz-themes]').hidden = true; }

  $('[data-cz-reload]').addEventListener('click', function () { loadFrame(); });

  root.querySelectorAll('[data-cz-tab]').forEach(function (tab) {
    tab.addEventListener('click', function () {
      var name = tab.getAttribute('data-cz-tab');
      root.querySelectorAll('[data-cz-tab]').forEach(function (o) { o.classList.toggle('is-on', o === tab); });
      root.querySelectorAll('[data-cz-panel]').forEach(function (p) { p.hidden = p.getAttribute('data-cz-panel') !== name; });
    });
  });

  // ------------------------------------------------------- save / discard
  var renderAll = function () { renderSchemes(); renderLayouts(); renderColors(); showTheme(); refreshDirty(); };

  $('[data-cz-save]').addEventListener('click', function () {
    var btn = this;
    btn.disabled = true;
    status('Saving...', '');
    post('save-ajax', state).then(function (json) {
      var theme = state.theme;
      saved = fixState(json.state);
      state = clone(saved);
      state.theme = theme;
      D.schemes[state.style].colors = clone(saved.colors);
      resetPalette();
      renderAll();
      status('Saved. The site now shows this.', 'ok');
    }).catch(function (err) {
      status(err.message, 'error');
      refreshDirty();
    });
  });

  $('[data-cz-discard]').addEventListener('click', function () {
    var theme = state.theme;
    state = clone(saved);
    state.theme = theme;
    resetPalette();
    renderAll();
    status('', '');
    push(true);
  });

  window.addEventListener('beforeunload', function (e) {
    if (isDirty()) { e.preventDefault(); e.returnValue = ''; }
  });
  window.addEventListener('resize', fitFrame);

  // ----------------------------------------------------------------- go
  renderAll();
  fitFrame();
  loadFrame(currentPath);

  // For the tests: the live state, and a promise that settles once nothing
  // is waiting to be sent and the frame has finished loading.
  window.hadrianCustomize = {
    state: function () { return state; },
    saved: function () { return saved; },
    loads: function () { return frameLoads; },
    idle: function () {
      return new Promise(function (resolve) {
        (function wait() { if (!queued && inFlight === 0 && !frameBusy) { resolve(); } else { setTimeout(wait, 50); } })();
      });
    }
  };
})();
