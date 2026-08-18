/* docs.js — the only script the documentation ships
   ---------------------------------------------------------------------------
   Everything the React prototype did at runtime, minus React: theme toggle,
   search, table-of-contents scroll-spy, mobile drawer. The pages themselves are
   already HTML by the time this loads, so nothing here is required for the
   content to be readable -- it all degrades to a plain, working document.
*/
(function () {
  'use strict';

  var BASE = window.DOCS_BASE || '';
  var $ = function (sel) { return document.querySelector(sel); };

  /* ── theme ─────────────────────────────────────────────────────────────
     The <head> has already applied the stored choice before first paint; this
     only handles the click. */
  var themeBtn = $('#doc-theme');
  if (themeBtn) {
    /* aria-pressed ships as "false" in the static HTML, but the <head> guard may
       already have restored dark before this runs -- so sync it on load, not
       only on click, or the button lies to a screen reader on every page. */
    var syncTheme = function () {
      themeBtn.setAttribute(
        'aria-pressed',
        document.documentElement.getAttribute('data-theme') === 'dark' ? 'true' : 'false'
      );
    };
    syncTheme();
    themeBtn.addEventListener('click', function () {
      var next = document.documentElement.getAttribute('data-theme') === 'dark' ? 'light' : 'dark';
      document.documentElement.setAttribute('data-theme', next);
      try { localStorage.setItem('hadrian-docs-theme', next); } catch (e) {}
      syncTheme();
    });
  }

  /* ── mobile drawer ─────────────────────────────────────────────────── */
  var burger = $('#doc-burger');
  var scrim = $('#doc-scrim');
  var drawers = [].slice.call(document.querySelectorAll('.doc-rail, .doc-sidebar'));

  /* Below the breakpoint the rail and sidebar are translated off-screen, which
     does NOT remove them from the tab order -- ten links stayed focusable with
     the ring painted off the left edge. inert fixes that, and unlike a CSS
     visibility rule it applies synchronously, so focusing the first link the
     moment the drawer opens actually works. Above the breakpoint they are
     ordinary page furniture and must never be inert. */
  function syncInert() {
    var drawerMode = window.innerWidth <= 980;
    var open = document.body.classList.contains('doc-nav-open');
    drawers.forEach(function (el) {
      if (drawerMode && !open) el.setAttribute('inert', '');
      else el.removeAttribute('inert');
    });
  }

  function closeNav(refocus) {
    if (!document.body.classList.contains('doc-nav-open')) return;
    document.body.classList.remove('doc-nav-open');
    syncInert();
    if (burger) {
      burger.setAttribute('aria-expanded', 'false');
      if (refocus) burger.focus();
    }
  }

  if (burger) {
    burger.addEventListener('click', function () {
      var open = document.body.classList.toggle('doc-nav-open');
      burger.setAttribute('aria-expanded', open ? 'true' : 'false');
      syncInert();
      if (open) {
        var firstLink = document.querySelector('.doc-sidebar-link');
        if (firstLink) firstLink.focus();
      }
    });
  }
  if (scrim) scrim.addEventListener('click', function () { closeNav(true); });

  document.addEventListener('keydown', function (e) {
    if (e.key === 'Escape') closeNav(true);
  });

  /* body gets overflow:hidden while the drawer is open. Widening the window
     past the breakpoint hides the drawer by media query but left that class
     behind, so the desktop page could no longer scroll at all. */
  window.addEventListener('resize', function () {
    if (window.innerWidth > 980) closeNav(false);
    syncInert();
  });

  syncInert();

  /* ── table of contents ─────────────────────────────────────────────────
     Same rule as the prototype: the active entry is the last h2 whose top has
     passed 120px. Cheap, and it never leaves nothing highlighted. */
  var tocLinks = [].slice.call(document.querySelectorAll('.doc-toc a[data-toc]'));
  function syncToc() {
    if (!tocLinks.length) return;
    var best = tocLinks[0];
    for (var i = 0; i < tocLinks.length; i++) {
      var el = document.getElementById(tocLinks[i].getAttribute('data-toc'));
      if (el && el.getBoundingClientRect().top <= 120) best = tocLinks[i];
    }
    /* On a short article the last sections sit inside the final viewport, so
       they never cross the 120px line and their entries could never light up --
       the reader scrolls to the bottom and the TOC still points halfway up.
       At the end of the document, the last heading is the honest answer.

       Guarded on the page actually being scrollable: when scrollHeight equals
       innerHeight this test is true at rest, which lit the LAST entry on load
       for every article too short to scroll. */
    var scrollable = document.documentElement.scrollHeight > window.innerHeight + 2;
    var atBottom = window.innerHeight + window.pageYOffset >= document.documentElement.scrollHeight - 2;
    if (scrollable && atBottom) best = tocLinks[tocLinks.length - 1];

    for (var j = 0; j < tocLinks.length; j++) {
      tocLinks[j].classList.toggle('is-on', tocLinks[j] === best);
    }
  }
  if (tocLinks.length) {
    window.addEventListener('scroll', syncToc, { passive: true });
    window.addEventListener('resize', syncToc);
    syncToc();
    tocLinks.forEach(function (a) {
      a.addEventListener('click', function (e) {
        var el = document.getElementById(a.getAttribute('data-toc'));
        if (!el) return;
        e.preventDefault();
        window.scrollTo({ top: el.getBoundingClientRect().top + window.pageYOffset - 76, behavior: 'smooth' });
        history.replaceState(null, '', '#' + a.getAttribute('data-toc'));
      });
    });
  }

  /* ── search ────────────────────────────────────────────────────────────
     The index carries each article's full body text, so "license key" finds
     Installation. The prototype only ever matched title + lead, which is why
     searching for anything in an article body came back empty.

     The index is fetched on first interaction, not on load: it is a few dozen
     KB that most readers never need. */
  var input = $('#doc-search-input');
  var panel = $('#doc-search-results');
  var clearBtn = $('#doc-search-clear');
  var live = $('#doc-search-live');
  var index = null;
  var loading = null;
  var cursor = -1;

  function load() {
    if (index) return Promise.resolve(index);
    if (!loading) {
      loading = fetch(BASE + '/search-index.json')
        .then(function (r) { return r.ok ? r.json() : []; })
        .then(function (data) { index = data; return index; })
        .catch(function () { index = []; return index; });
    }
    return loading;
  }

  function escapeHtml(s) {
    return String(s).replace(/[&<>"]/g, function (c) {
      return { '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;' }[c];
    });
  }

  /* A window of body text around the first hit, with every occurrence of the
     query marked.

     Matching happens on the RAW slice and the pieces are escaped individually
     as they are assembled. Escaping first and matching second looked safer but
     was wrong: the query "&" had to match the escaped text "&amp;", so it
     highlighted nothing, and a query like "amp" would have lit up the middle of
     an entity. Nothing raw ever reaches the output -- every fragment goes
     through escapeHtml() on its way into the string. */
  function snippet(text, q) {
    var at = text.indexOf(q);
    if (at < 0) return '';
    var from = Math.max(0, at - 45);
    var slice = text.slice(from, from + 150);

    var re = new RegExp(q.replace(/[.*+?^${}()|[\]\\]/g, '\\$&'), 'gi');
    var html = '';
    var last = 0;
    var m;
    while ((m = re.exec(slice)) !== null) {
      html += escapeHtml(slice.slice(last, m.index)) + '<mark>' + escapeHtml(m[0]) + '</mark>';
      last = m.index + m[0].length;
      if (m[0].length === 0) re.lastIndex++;   // a zero-width match would spin
    }
    html += escapeHtml(slice.slice(last));

    return (from > 0 ? '&hellip;' : '') + html + '&hellip;';
  }

  /* Rank by WHERE the term landed, not just whether it did. Scoring only on
     position in the body made "dark" return the Email overview -- which says
     the word once, early, in its lead -- above Style Manager, whose entire
     "Dark mode" section is the answer. A heading is the strongest signal short
     of the title itself. */
  function results(q) {
    q = q.trim().toLowerCase();
    if (!q || !index) return [];
    return index
      .map(function (a) {
        var inTitle = a.t.toLowerCase().indexOf(q);
        var inHead = (a.h || '').indexOf(q);
        var inLead = (a.l || '').toLowerCase().indexOf(q);
        var inBody = a.x.indexOf(q);
        if (inTitle < 0 && inHead < 0 && inLead < 0 && inBody < 0) return null;

        var score;
        if (inTitle >= 0) score = inTitle;                 //     0 - 999
        else if (inHead >= 0) score = 1000 + inHead;       //  1000 - 1999
        else if (inLead >= 0) score = 2000 + inLead;       //  2000 - 2999
        else score = 3000 + Math.min(inBody, 999);         //  3000 +
        return { a: a, score: score };
      })
      .filter(Boolean)
      .sort(function (m, n) { return m.score - n.score; })
      .slice(0, 8)
      .map(function (m) { return m.a; });
  }

  function draw(q) {
    if (!panel) return;
    var hits = results(q);
    cursor = -1;
    if (!q.trim()) {
      /* Emptying the markup matters as much as hiding the panel: the old
         version returned with the previous query's hits still in the DOM, so
         clearing the box and pressing Enter navigated to a result the reader
         could no longer see. */
      panel.innerHTML = '';
      panel.hidden = true;
      input.setAttribute('aria-expanded', 'false');
      return;
    }
    input.removeAttribute('aria-activedescendant');
    if (!hits.length) {
      panel.innerHTML = '<div class="doc-search-none">No results for &ldquo;' + escapeHtml(q) + '&rdquo;.</div>';
    } else {
      panel.innerHTML = hits.map(function (a, i) {
        var sn = snippet(a.x, q.trim().toLowerCase());
        return '<a class="doc-search-hit" role="option" aria-selected="false" ' +
          'id="doc-search-hit-' + i + '" href="' + a.u + '">' +
          '<span class="doc-search-hit-t">' + escapeHtml(a.t) + '</span>' +
          '<span class="doc-search-hit-c">' + (sn || escapeHtml(a.p + ' - ' + a.g)) + '</span></a>';
      }).join('');
    }
    panel.hidden = false;
    input.setAttribute('aria-expanded', 'true');
    if (live) live.textContent = hits.length ? hits.length + ' results' : 'No results';
  }

  /* aria-activedescendant is what makes arrow-keying the dropdown audible: the
     focus stays in the input, so without it a screen reader announces nothing
     as the cursor moves down the list. */
  function move(delta) {
    var hits = [].slice.call(panel.querySelectorAll('.doc-search-hit'));
    if (!hits.length) return;
    cursor = (cursor + delta + hits.length) % hits.length;
    hits.forEach(function (h, i) {
      h.classList.toggle('is-cursor', i === cursor);
      h.setAttribute('aria-selected', i === cursor ? 'true' : 'false');
    });
    hits[cursor].scrollIntoView({ block: 'nearest' });
    input.setAttribute('aria-activedescendant', hits[cursor].id);
  }

  if (input) {
    var onType = function () {
      if (clearBtn) clearBtn.hidden = !input.value;
      load().then(function () { draw(input.value); });
    };
    input.addEventListener('input', onType);
    /* draw() must wait for the index, or a value restored by the browser on
       back-navigation renders "No results" against a null index. */
    input.addEventListener('focus', function () {
      load().then(function () { if (input.value) draw(input.value); });
    });

    input.addEventListener('keydown', function (e) {
      if (e.key === 'ArrowDown') { e.preventDefault(); move(1); }
      else if (e.key === 'ArrowUp') { e.preventDefault(); move(-1); }
      else if (e.key === 'Enter') {
        if (panel.hidden) return;           // never navigate on hits nobody can see
        var sel = panel.querySelector('.doc-search-hit.is-cursor') || panel.querySelector('.doc-search-hit');
        if (sel) { e.preventDefault(); window.location.href = sel.getAttribute('href'); }
      } else if (e.key === 'Escape') {
        input.value = ''; if (clearBtn) clearBtn.hidden = true;
        panel.hidden = true; input.setAttribute('aria-expanded', 'false'); input.blur();
      }
    });

    if (clearBtn) {
      clearBtn.addEventListener('click', function () {
        input.value = ''; clearBtn.hidden = true;
        panel.hidden = true; input.setAttribute('aria-expanded', 'false'); input.focus();
      });
    }

    document.addEventListener('click', function (e) {
      if (panel && !panel.hidden && !e.target.closest('.doc-search')) {
        panel.hidden = true; input.setAttribute('aria-expanded', 'false');
      }
    });

    // "/" and Cmd/Ctrl-K land in the search box, as they do everywhere else
    document.addEventListener('keydown', function (e) {
      var typing = /^(INPUT|TEXTAREA|SELECT)$/.test(document.activeElement.tagName);
      if ((e.key === '/' && !typing) || ((e.metaKey || e.ctrlKey) && e.key.toLowerCase() === 'k')) {
        e.preventDefault();
        input.focus();
        input.select();
      }
    });
  }

  // exposed so the layout can be checked without synthesising scroll events
  window.__docs = { syncToc: syncToc, search: function (q) { return load().then(function () { return results(q); }); } };
})();
