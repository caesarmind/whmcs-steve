// hadrian-lp5-frames.jsx — the client area itself, embedded live
// ---------------------------------------------------------------------------
// The hero used to show screens/*.png: flat captures, one per layout, with a
// style rail that only restyled the window frame drawn around them. This mounts
// the real pages from ../apple-client-area instead, so every control on the
// stage drives the actual theme.
//
// Steering: apple-layout.js reads ?layout=/?palette=/… once, at boot, so driving
// a frame by URL would cost a full reload per click — and `npx serve` drops the
// query string on its clean-URL redirect anyway. The frame is same-origin, so we
// write the same attributes the theme's own state chip writes. Switching is
// instant, needs no reload, and leaves nothing behind in the theme's localStorage.

/* Where the client area sits, relative to this page. The build writes a different
   value into window.HADRIAN_PATHS because the deployed landing sits at the doc
   root with its siblings beneath it, rather than beside them. */
const CA_PATHS = (typeof window !== 'undefined' && window.HADRIAN_PATHS) || {};
const CA_BASE = CA_PATHS.clientArea || '../apple-client-area/';
const CA_WIDTH = 1440;    // below ~1100px the client area takes its tablet treatment
const CA_BOOT_MS = 7000;  // stop waiting for partials and keep the capture

// Those pages fetch() their layout partials, which file:// refuses — an unserved
// copy of this landing would show a client area with no navigation at all. Serve
// the folder and it embeds; open it off disk and the captures stand in.
const CA_EMBEDDABLE = /^https?:$/.test(location.protocol);

/* ── writing theme state into a frame ──────────────────────────────────────
   Mirrors apple-layout.js `initStateToggles`: every one of these is expressed
   by removing the attribute at its default value, so match that exactly or the
   frame ends up styled for a value the theme thinks it isn't in. */
function attr(el, name, value, dflt) {
  if (!value || value === dflt) el.removeAttribute(name);
  else el.setAttribute(name, value);
}
function paintFrame(doc, s) {
  if (!doc || !doc.body) return false;
  const html = doc.documentElement, body = doc.body;
  html.setAttribute('data-theme', s.dark ? 'dark' : 'light');
  // The admin panel keys off the same data-theme and nothing else here, so stop
  // rather than writing client-area attributes onto a page with no use for them.
  if (s.admin) return true;
  body.dataset.layout = s.layout || 'top';           // top | side | rail
  attr(body, 'data-sidebar', s.sidebar, 'light');    // light | dark | tinted | graphite | brand
  attr(body, 'data-align', s.align, 'center');       // center | left | content
  attr(body, 'data-icons', s.icons, 'colorful');     // colorful | mono
  attr(html, 'data-palette', s.palette, 'blue');     // blue | emerald | violet | rose | amber | slate
  // Top-bar controls. menu and toplinks are generic rows in apple-layout.js,
  // which ALWAYS write their attribute -- some CSS matches the default value
  // explicitly -- so they are set rather than removed at the default.
  body.setAttribute('data-menu', s.menu || 'left');            // left | center
  body.setAttribute('data-toplinks', s.toplinks || 'show');   // show | hide
  attr(body, 'data-crumbs', s.crumbs, 'trail');              // trail | plain | pill | chevron | back | none
  // the welcome band, on the dashboards that have one. gradient is the base
  // look with no rule behind it, so it is expressed by removing the attribute.
  attr(body, 'data-hero-tone', s.band, 'gradient');
  attr(body, 'data-hero-size', s.bandSize, 'full');   // full | slim
  if (s.auth) body.dataset.auth = s.auth;
  // the floating dev panel is ours, not the visitor's
  body.setAttribute('data-preview', 'off');
  body.classList.add('screenshot');
  return true;
}

/* Two things a live page inside a landing page must not do.

   Navigate: a click on any of the client area's own links would take the visitor
   off the landing page entirely. Buttons, dropdowns, the rail flyouts and the
   sidebar groups all still work — only navigation and submission are sealed.

   Swallow the keyboard: a client area holds around a hundred focusable controls,
   and Tab walks into an iframe whatever the iframe element says. `inert` would
   fix that, but an inert iframe is not hit-testable either, which costs the
   scrolling the hero is built around — so drop the contents out of the tab order
   one element at a time instead. Everything stays readable and clickable; Tab
   simply passes the window by. */
const FOCUSABLE = 'a[href],button,input,select,textarea,summary,[tabindex]:not([tabindex="-1"]),[contenteditable="true"]';
function sealFrame(doc) {
  if (doc.__sealed) return;
  doc.__sealed = true;
  doc.addEventListener('click', (e) => {
    const a = e.target.closest && e.target.closest('a[href]');
    if (a && !a.getAttribute('href').startsWith('#')) e.preventDefault();
  }, true);
  doc.addEventListener('submit', (e) => e.preventDefault(), true);
  const untab = () => {
    const nodes = doc.querySelectorAll(FOCUSABLE);
    for (let i = 0; i < nodes.length; i++) nodes[i].setAttribute('tabindex', '-1');
    return nodes.length;
  };
  untab();
  // the theme wires its dropdowns and rail panels after the partials land
  setTimeout(untab, 600);
}

/* loadPartials() stamps data-loaded on every include — "" once it lands, "error"
   when the fetch failed. That is an exact ready/failed signal, so we never guess
   from a timer. Pages with no includes at all (homepage.html) are ready at load. */
function frameStatus(doc) {
  const inc = Array.prototype.slice.call(doc.querySelectorAll('[data-include]'));
  if (inc.some((n) => n.getAttribute('data-loaded') === 'error')) return 'failed';
  if (!inc.every((n) => n.hasAttribute('data-loaded'))) return 'booting';
  // A page that mounts into #root -- the admin demo does, through Babel -- has a
  // root still empty at load. Reveal it then and you reveal a blank frame.
  const root = doc.getElementById('root');
  if (root && !root.firstElementChild) return 'booting';
  return 'ready';
}

/* ── scale ──────────────────────────────────────────────────────────────────
   The client area is laid out at CA_WIDTH and scaled down to whatever box it
   has been given, so it is never reflowed into its own tablet breakpoints —
   the same trick the captures got for free by being 2880px wide images. */
function useFrameBox(ref, width) {
  const [box, setBox] = React.useState({ scale: 0, h: 0 });
  const measure = React.useCallback(() => {
    const el = ref.current;
    if (!el) return;
    const r = el.getBoundingClientRect();
    if (r.width < 2 || r.height < 2) return;
    const scale = r.width / width;
    // only a real change commits, so this is safe to call from a render effect
    setBox((p) => (Math.abs(p.scale - scale) < 0.0005 ? p : { scale, h: r.height / scale }));
  }, [width]);
  React.useLayoutEffect(() => {
    window.addEventListener('resize', measure);
    let ro;
    if (typeof ResizeObserver !== 'undefined' && ref.current) {
      ro = new ResizeObserver(measure);
      ro.observe(ref.current);
    }
    // clamp()-driven heights and the webfont both settle after first paint
    const t1 = setTimeout(measure, 350);
    const t2 = setTimeout(measure, 1200);
    return () => { window.removeEventListener('resize', measure); if (ro) ro.disconnect(); clearTimeout(t1); clearTimeout(t2); };
  }, [measure]);
  // Re-measure on every render as well. Neither resize nor ResizeObserver is
  // guaranteed to arrive — some embedded viewers deliver neither — and a frame
  // laid out for the wrong width is worse than one measurement per interaction.
  React.useLayoutEffect(measure);
  return box;
}

/* ── one mounted page ─────────────────────────────────────────────────────── */
function Frame({ src, state, box, width, onReady, title, seal }) {
  const ref = React.useRef(null);
  const [live, setLive] = React.useState(false);
  const stateRef = React.useRef(state);
  stateRef.current = state;

  // repaint on every state change, without reloading the document
  React.useEffect(() => {
    if (!live) return;
    const f = ref.current;
    try { if (f && f.contentDocument) paintFrame(f.contentDocument, state); } catch (e) {}
  }, [live, state.layout, state.palette, state.sidebar, state.align, state.icons, state.dark, state.auth, state.menu, state.toplinks, state.crumbs, state.band, state.bandSize]);

  React.useEffect(() => {
    const f = ref.current;
    if (!f) return;
    let done = false, poll = null, giveUp = null;
    const finish = (ok) => {
      if (done) return;
      done = true;
      clearTimeout(poll); clearTimeout(giveUp);
      onReady(ok);
    };
    const settle = () => {
      if (done) return;
      let doc = null;
      try { doc = f.contentDocument; } catch (e) {}
      if (!doc || !doc.body) { finish(false); return; }
      const st = frameStatus(doc);
      if (st === 'booting') { poll = setTimeout(settle, 60); return; }
      if (st === 'failed') { finish(false); return; }
      paintFrame(doc, stateRef.current);
      if (seal !== false) sealFrame(doc);
      setLive(true);
      finish(true);
    };
    const onLoad = () => settle();
    f.addEventListener('load', onLoad);
    giveUp = setTimeout(() => finish(false), CA_BOOT_MS);
    return () => { done = true; f.removeEventListener('load', onLoad); clearTimeout(poll); clearTimeout(giveUp); };
  }, [src]);

  return (
    <iframe
      ref={ref}
      src={src}
      title={title}
      className="hf-frame"
      scrolling="yes"
      style={{
        width: width + 'px',
        height: (box.h || 900) + 'px',
        transform: `scale(${box.scale || 0.6})`,
        transformOrigin: 'top left',
        opacity: live ? 1 : 0,
      }}
    />
  );
}

/* ── the public component ─────────────────────────────────────────────────────
   Holds up to two mounted pages: the one on screen, and a new one booting behind
   it. The incoming page is only revealed once its partials have landed and its
   state has been written, so a page change never flashes the theme's defaults. */
function ThemeFrame({ page, state, poster, fallback, alt, width = CA_WIDTH, className = '', inert = false }) {
  const wrap = React.useRef(null);
  const box = useFrameBox(wrap, width);
  const seq = React.useRef(1);
  const [slots, setSlots] = React.useState(() => [{ k: 0, src: page }]);
  const [dead, setDead] = React.useState(!CA_EMBEDDABLE);

  React.useEffect(() => {
    if (dead) return;
    setSlots((cur) => (cur[cur.length - 1].src === page ? cur : cur.slice(-1).concat({ k: seq.current++, src: page })));
  }, [page, dead]);

  const settle = React.useCallback((k, ok) => {
    if (!ok) { setDead(true); setSlots((cur) => cur.slice(-1)); return; }
    setSlots((cur) => (cur[cur.length - 1].k === k ? cur.filter((s) => s.k === k) : cur));
  }, []);

  return (
    <div ref={wrap} className={`hf-live${dead ? ' is-poster' : ''} ${className}`}>
      {/* a capture when there is one, otherwise whatever the caller drew by hand */}
      {dead && fallback ? <div className="hf-fallback">{fallback}</div> : null}
      {poster && <img className="hf-poster" src={poster} alt={dead ? alt : ''} loading="lazy" aria-hidden={dead ? undefined : 'true'} />}
      {!dead && slots.map((s, i) => (
        <div key={s.k} className="hf-slot" style={{ zIndex: i + 1 }} {...(inert ? { inert: '' } : {})}>
          <Frame
            src={s.src}
            state={state}
            box={box}
            width={width}
            title={alt}
            seal={!inert}
            onReady={(ok) => settle(s.k, ok)}
          />
        </div>
      ))}
    </div>
  );
}

Object.assign(window, { ThemeFrame, CA_BASE, CA_WIDTH, CA_EMBEDDABLE, paintFrame, sealFrame });
