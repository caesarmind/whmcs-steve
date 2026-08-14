// hadrian-lp5-app.jsx — Hadrian landing, Apple V2 (built from the theme's component library)
// Scroll reveal, rect-based and deterministic: every scroll/resize re-evaluates
// all pending nodes, so no callback can be "dropped" and leave content hidden.
// Scroll reveal that cannot fail closed: the gate is only armed for a wrapper
// that is genuinely below the fold, each one is released by its OWN observer,
// and a timeout releases unconditionally. Reduced motion never gates at all.
const revealOK = () => typeof IntersectionObserver !== 'undefined'
  && !(window.matchMedia && matchMedia('(prefers-reduced-motion: reduce)').matches);
let revealArmed = false;
function armReveal() {
  if (revealArmed) return;
  revealArmed = true;
  document.documentElement.classList.add('js-reveal');
}
function gate(el) {
  if (!el || !revealOK()) return () => {};
  // already on screen (deep link, restored scroll, first paint) — never hide it
  const r = el.getBoundingClientRect();
  const vh = window.innerHeight || 800;
  if (r.top < vh * 0.94 && r.bottom > -1) { el.classList.add('in'); return () => {}; }
  armReveal();
  const release = () => el.classList.add('in');
  const io = new IntersectionObserver((es) => {
    if (es.some((x) => x.isIntersecting)) { release(); io.disconnect(); }
  }, { threshold: 0, rootMargin: '0px 0px -6% 0px' });
  io.observe(el);
  const t = setTimeout(() => { release(); io.disconnect(); }, 3000);
  return () => { clearTimeout(t); io.disconnect(); release(); };
}
/* One throwing widget must not take the page with it. There is no build step and
   no server render here, so an unhandled error inside any demo unmounts the whole
   root and the visitor gets a white screen instead of a sales page. Anything
   decorative gets wrapped in this and simply goes missing if it fails. */
class Safe extends React.Component {
  constructor(p) { super(p); this.state = { dead: false }; }
  static getDerivedStateFromError() { return { dead: true }; }
  componentDidCatch(err) { if (window.console) console.error('[hadrian-lp]', this.props.name || 'widget', err); }
  render() { return this.state.dead ? (this.props.fallback || null) : this.props.children; }
}
function Up({ children, style, className = '' }) {
  const ref = React.useRef(null);
  React.useLayoutEffect(() => gate(ref.current), []);
  return <div ref={ref} className={`hp-up ${className}`} style={style}>{children}</div>;
}

/* ── .hp-announce-strip ── */
function Strip({ onFounding }) {
  return (
    <div className="hp-banner">
      <div className="inner">
        <span className="ico" aria-hidden="true">
          <svg width="17" height="17" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.9" strokeLinecap="round" strokeLinejoin="round"><path d="M20.6 12.4 12.4 20.6a2 2 0 0 1-2.8 0l-6.2-6.2a2 2 0 0 1-.6-1.6l.5-6a2 2 0 0 1 1.8-1.8l6-.5a2 2 0 0 1 1.6.6l6.2 6.2a2 2 0 0 1 0 2.8Z" /><circle cx="8.6" cy="8.6" r="1.4" /></svg>
        </span>
        <p>Founding offer — <b>a single license is $20 instead of $99</b>, and founding clients set the roadmap.</p>
        <button onClick={onFounding}>See the offer <span aria-hidden="true">↗</span></button>
        {/* Decoration: a 110px rotated crop, masked and faded out. Deliberately
            still the captures — a live frame here would cost three more page
            renders above the fold to draw something illegible at 7% scale.
            The live theme runs in the hero, where it can actually be read. */}
        <span className="fan" aria-hidden="true">
          <img src="screens/rail-dashboard.png" alt="" loading="lazy" decoding="async" />
          <img src="screens/topnav-dashboard.png" alt="" loading="lazy" decoding="async" />
          <img src="screens/sidebar-dashboard.png" alt="" loading="lazy" decoding="async" />
        </span>
      </div>
    </div>
  );
}

/* ── .hp-utility · thin secondary bar ── */
function Utility({ dark, onDark }) {
  return (
    <div className="hp-utility">
      <div className="inner">
        <span className="by">By <b>Caesarthemes</b></span>
        <div className="right">
          {['Documentation', 'Changelog', 'Contact', 'My Account'].map((l) => <a key={l} href="#">{l}</a>)}
          <span className="sep"></span>
          <span className="cur">USD <span aria-hidden="true">▾</span></span>
          <button className="mode" onClick={onDark} aria-pressed={dark} aria-label="Toggle dark mode">
            <span className="knob">{dark ? '☀' : '☾'}</span>
            <span className="txt">{dark ? 'ON' : 'OFF'}</span>
          </button>
        </div>
      </div>
    </div>
  );
}

/* ── .homepage-nav · main bar ── */
function Nav({ dark, onDark, onDemo }) {
  const links = [['#features', 'Features', true], ['#layouts', 'Layouts', false], ['#extensions', 'Extensions', false], ['#pricing', 'Pricing', false], ['#faq', 'FAQ', false]];
  return (
    <nav className="homepage-nav">
      <div className="inner">
        <a href="#top" className="brand">
          <span className="hp-mark"></span>
          <span className="word">Hadrian</span>
        </a>
        <div className="links">
          {links.map(([h, l, on]) => <a key={h} href={h} className={on ? 'on' : ''}>{l}</a>)}
        </div>
        <div className="acts">
          <button onClick={onDemo} className="hp-btn ghost">Live demo</button>
          <a href="#pricing" className="hp-btn solid">Get Hadrian</a>
        </div>
      </div>
    </nav>
  );
}

/* ── .hp-accents · the six styles the module ships ──
   Names and accents are the ones in core/config/colors.php. A style is the
   palette and nothing else here — the sidebar treatment is its own setting —
   so each swatch pairs the accent with the tint that accent produces. */
const STYLES = [
  { id: 'blue', n: 'Default', brand: '#0071e3', d: 'The stock blue.' },
  { id: 'emerald', n: 'Emerald', brand: '#14b17d', d: 'Green, low chroma.' },
  { id: 'violet', n: 'Violet', brand: '#8c5cff', d: 'Cool, high chroma.' },
  { id: 'rose', n: 'Rose', brand: '#ff2d6b', d: 'Warm and loud.' },
  { id: 'amber', n: 'Amber', brand: '#f08a00', d: 'Warm and quiet.' },
  { id: 'slate', n: 'Slate', brand: '#64748b', d: 'Neutral, near-monochrome.' },
].map((s) => ({ ...s, chrome: `color-mix(in srgb, ${s.brand} 10%, #ffffff)`, ink: '#1d1d1f' }));
function AccentPanel({ dark, onDark }) {
  const [open, setOpen] = React.useState(false);
  const [i, setI] = React.useState(0);
  const apply = (st) => {
    const r = document.documentElement;
    r.style.setProperty('--color-accent', st.brand);
    r.style.setProperty('--color-accent-hover', st.brand);
    r.style.setProperty('--color-accent-light', `color-mix(in srgb, ${st.brand} 12%, transparent)`);
    r.style.setProperty('--color-link', st.brand);
    r.style.setProperty('--on-accent-tint', `color-mix(in srgb, ${st.brand} 74%, #000)`);
    r.style.setProperty('--color-chrome', st.chrome);
    r.style.setProperty('--color-chrome-ink', st.ink);
    try { localStorage.setItem('hadrian-style', st.id); } catch (e) {}
  };
  React.useEffect(() => {
    try {
      const saved = localStorage.getItem('hadrian-style');
      const k = STYLES.findIndex((x) => x.id === saved);
      if (k > 0) { setI(k); apply(STYLES[k]); }
    } catch (e) {}
  }, []);
  const pick = (k) => { setI(k); apply(STYLES[k]); };
  return (
    <div className={`hp-accents${open ? ' open' : ''}`}>
      {open && (
        <div className="panel" role="dialog" aria-label="Style presets">
          <div className="hd">
            <b>Available styles</b>
            <span className="ct">{STYLES.length}</span>
            <button onClick={() => setOpen(false)} aria-label="Close">✕</button>
          </div>
          <div className="cards" role="radiogroup" aria-label="Style">
            {STYLES.map((st, k) => (
              <button key={st.id} className={`sc${k === i ? ' on' : ''}`} role="radio" aria-checked={k === i} onClick={() => pick(k)}>
                <span className="pv">
                  <span className="c1" style={{ background: st.chrome }}></span>
                  <span className="c2" style={{ background: st.brand }}></span>
                </span>
                <b>{st.n}</b>
                <em>{st.d}</em>
                <span className="st">{k === i ? 'Active' : 'Activate'}</span>
              </button>
            ))}
          </div>
          <div className="row">
            <button className="mini" onClick={onDark}>{dark ? 'Light mode' : 'Dark mode'}</button>
            <button className="mini" onClick={() => pick(0)}>Reset</button>
          </div>
          <p className="note">Each style sets nine colour values — accent, links and avatar. The sidebar treatment is its own setting, and status colours stay fixed.</p>
        </div>
      )}
      <button className="fab" onClick={() => setOpen(!open)} aria-expanded={open}>
        <span className="pair">
          <span style={{ background: STYLES[i].chrome }}></span>
          <span style={{ background: STYLES[i].brand }}></span>
        </span>
        {STYLES[i].n}
      </button>
    </div>
  );
}

/* ── .hp-silicon-hero + hero F stage ──
   The window under these pickers is ../apple-client-area rendered live — see
   hadrian-lp5-frames.jsx. Every control writes a real setting into a real page,
   so there is nothing here the theme cannot actually do. */
const HF_PAGES = [
  { id: 'dashboard', t: 'Dashboard', src: 'clientareahome-v18.html', designs: true },
  { id: 'services', t: 'Services', src: 'clientareaproducts.html' },
  { id: 'store', t: 'Store', src: 'store.html' },
  { id: 'invoice', t: 'Invoice', src: 'viewinvoice.html' },
  { id: 'support', t: 'Support', src: 'supportticketslist.html' },
  { id: 'login', t: 'Login', src: 'login.html', auth: 'out' },
];
/* The four dashboard designs the module ships, and the mockup file each one was
   drawn as. Names and descriptions are the module's own, straight out of
   core/pages/clientareahome/<v>/<v>.php, so this list says what the Pages
   editor says -- except Default, which the module leaves undescribed and which
   reads as Classic here, since it is the older shape rather than the fallback.
   Picking one swaps the frame src, which the A/B slot absorbs without a flash.
   (The mockup holds nineteen further explorations, v2-v19 and -boxed. They are
   not offered here: a buyer cannot choose them.) */
const HF_DESIGNS = [
  { id: 'atrium', t: 'Atrium', f: 'clientareahome-v18.html',
    s: 'A welcome band, then an asymmetric two-column body: the collections you read down the wide side, the things you act on down the narrow one. Width assigns a block to a column rather than sizing it on a grid, so reordering moves a block within its column.' },
  { id: 'bento', t: 'Bento', f: 'clientareahome-v17.html',
    s: 'A bento grid of self-contained cards. Each collection gets its own tile with a count and its rows, arranged two-up on a six-column grid. Adds an attention strip that pulls the few things needing action out of the many rows, and an identity card beside the greeting.' },
  { id: 'minimal', t: 'Minimal', f: 'clientareahome-v15.html',
    s: 'A quieter dashboard: greeting, four summary tiles, quick actions, then services, domains, invoices, tickets and announcements as plain rows on one surface. No panel grid or account sub-nav aside.' },
  { id: 'default', t: 'Classic', f: 'clientareahome-v9.html',
    s: 'The familiar shape: a greeting hero over plain tables, one after another.' },
];
const hfDesign = (id) => HF_DESIGNS.find((d) => d.id === id) || HF_DESIGNS[0];
/* the captures stay on as posters — they cover the first boot, and they are the
   whole show when this folder is opened off disk, where the theme's own pages
   cannot fetch their layout partials */
const HF_SHOTS = {
  dashboard: { side: 'screens/sidebar-dashboard.png', top: 'screens/topnav-dashboard.png', rail: 'screens/rail-dashboard.png' },
  services: { side: 'screens/sidebar-resources.png' },
};
const hfPoster = (page, lay) => (HF_SHOTS[page] || {})[lay] || (HF_SHOTS[page] || {}).side || null;
/* body[data-layout] */
const HF_LAYOUTS = [
  { t: 'Sidebar', s: 'Left rail', wire: 'side' },
  { t: 'Top Nav', s: 'Horizontal bar', wire: 'top' },
  { t: 'Icon Rail', s: 'Compact icons', wire: 'rail' },
];
/* body[data-sidebar] — retones the side menu and the rail. Three tones, matching
   what the module actually ships: core/config/colors.php declares Tinted and Brand
   as presets and treats Light as the defaults. (The mockup still carries the older
   Dark and Graphite; they were dropped from the product, so they are not offered
   here.) Top Nav has no side menu to retone, so the rail disables itself there. */
const HF_TONES = [
  { id: 'light', t: 'Light', s: 'The stock chrome' },
  { id: 'tinted', t: 'Tinted', s: 'A wash of the accent' },
  { id: 'brand', t: 'Solid', s: 'Filled with the accent' },
  { id: 'gradient', t: 'Gradient', s: 'The accent, with a fall' },
];
/* html[data-palette] — the six shipped styles, at the values in colors.php */
const HF_PALETTES = [
  { id: 'blue', c: '#0071e3', t: 'Default' },
  { id: 'emerald', c: '#14b17d', t: 'Emerald' },
  { id: 'violet', c: '#8c5cff', t: 'Violet' },
  { id: 'rose', c: '#ff2d6b', t: 'Rose' },
  { id: 'amber', c: '#f08a00', t: 'Amber' },
  { id: 'slate', c: '#64748b', t: 'Slate' },
];
/* what the wireframes and swatches paint the menu with, mirroring the tone rules
   in apple-layout.css so the thumbnail and the frame agree. Those rules are
   scoped to html:not([data-theme="dark"]), so in dark mode every tone is a
   no-op and the menu is simply the dark surface.

   Stops are computed to literals rather than left as color-mix(): an SVG
   stop-color has to be a colour, and the swatch has to match the frame exactly
   or it lies about it. Mixing X% of a colour with black in sRGB is each channel
   scaled by X, which is all hfMix does. The percentages are per palette for the
   reason given in apple-layout.css — the lightest top stop each accent can
   carry with white labels on it and still clear 4.5. */
const hfMix = (hex, pct) => {
  const n = parseInt(String(hex).slice(1), 16);
  if (isNaN(n)) return hex;
  const f = Math.max(0, Math.min(100, pct)) / 100;
  return '#' + [(n >> 16) & 255, (n >> 8) & 255, n & 255]
    .map((v) => Math.round(v * f).toString(16).padStart(2, '0')).join('');
};
const HF_GRAD = { rose: [88, 69, 49], emerald: [76, 59, 43], amber: [72, 56, 40] };
const HF_GRAD_DEFAULT = [94, 73, 53];
const hfGradStops = (paletteId) => HF_GRAD[paletteId] || HF_GRAD_DEFAULT;
const hfGradient = (accent, paletteId) => {
  const at = ['0%', '46%', '100%'];
  return `linear-gradient(170deg, ${hfGradStops(paletteId).map((p, i) => `${hfMix(accent, p)} ${at[i]}`).join(', ')})`;
};
/* a paintable CSS background — may be a gradient */
const hfChrome = (tone, accent, dark, paletteId) => {
  if (dark) return '#2c2c2e';
  if (tone === 'gradient') return hfGradient(accent, paletteId);
  return { light: '#f5f5f7', tinted: `color-mix(in srgb, ${accent} 10%, #ffffff)`, brand: accent }[tone] || '#f5f5f7';
};
/* the same tone as one flat colour, for the SVG fills that cannot take a gradient */
const hfChromeSolid = (tone, accent, dark, paletteId) =>
  (!dark && tone === 'gradient' ? hfMix(accent, hfGradStops(paletteId)[1]) : hfChrome(tone, accent, dark, paletteId));
const hfChromeInk = (tone, dark) => (dark || tone === 'brand' || tone === 'gradient' ? '#f5f5f7' : '#1d1d1f');
/* the layout wireframes, same geometry as Hadrian's admin Layouts page */
function HFWire({ kind, active }) {
  // chrome = the sidebar / top-nav fill · chromeInk = the bars drawn inside it
  // page = the content area · accent = the one active nav item, so the brand half shows too
  const chrome = active ? 'var(--color-chrome,#f5f5f7)' : 'rgba(120,120,128,0.55)';
  const chromeInk = active ? 'var(--color-chrome-ink,#1d1d1f)' : 'var(--color-surface-secondary)';
  const page = 'var(--color-surface)';
  const accent = active ? 'var(--color-accent)' : 'rgba(120,120,128,0.4)';
  const line = active ? 'var(--color-text-primary)' : 'rgba(120,120,128,0.55)';
  const W = 150, H = 86;
  const f = (c) => <svg className="wire" viewBox={`0 0 ${W} ${H}`} width={W} height={H} style={{ background: page, display: 'block' }}>{c}</svg>;
  if (kind === 'top') return f(<><rect x="0" y="0" width={W} height="16" fill={chrome} stroke="var(--color-border)" strokeWidth="1" /><rect x="8" y="6" width="20" height="4" rx="2" fill={chromeInk} opacity="0.9" /><rect x="50" y="5" width="14" height="6" rx="3" fill={accent} /><rect x="70" y="6" width="12" height="4" rx="2" fill={chromeInk} opacity="0.5" /><rect x="86" y="6" width="12" height="4" rx="2" fill={chromeInk} opacity="0.5" /><rect x="14" y="26" width="64" height="6" rx="3" fill={line} opacity="0.4" /><rect x="14" y="40" width="122" height="34" rx="5" fill={line} opacity="0.14" /></>);
  if (kind === 'rail') return f(<><rect x="0" y="0" width="18" height={H} fill={chrome} stroke="var(--color-border)" strokeWidth="1" /><circle cx="9" cy="13" r="4" fill={accent} /><circle cx="9" cy="30" r="3" fill={chromeInk} opacity="0.5" /><circle cx="9" cy="43" r="3" fill={chromeInk} opacity="0.5" /><rect x="30" y="14" width="56" height="6" rx="3" fill={line} opacity="0.4" /><rect x="30" y="28" width="106" height="46" rx="5" fill={line} opacity="0.14" /></>);
  return f(<><rect x="0" y="0" width="38" height={H} fill={chrome} stroke="var(--color-border)" strokeWidth="1" /><rect x="7" y="9" width="24" height="5" rx="2" fill={chromeInk} opacity="0.9" /><rect x="7" y="24" width="24" height="4" rx="2" fill={accent} /><rect x="7" y="33" width="24" height="4" rx="2" fill={chromeInk} opacity="0.5" /><rect x="48" y="14" width="56" height="6" rx="3" fill={line} opacity="0.4" /><rect x="48" y="28" width="90" height="46" rx="5" fill={line} opacity="0.14" /></>);
}
/* the sidebar tone swatch — a menu column filled the way the theme fills it */
function HFToneGlyph({ tone, accent, dark, paletteId }) {
  // an SVG fill cannot take linear-gradient(), so the gradient tone paints from
  // a real <linearGradient> built off the same stops the CSS uses
  const grad = tone === 'gradient';
  const gid = `hf-tone-grad-${String(accent).replace('#', '')}`;
  const fill = grad ? `url(#${gid})` : hfChromeSolid(tone, accent, dark, paletteId);
  const ink = hfChromeInk(tone, dark);
  return (
    <svg viewBox="0 0 44 30" width="44" height="30" fill="none" aria-hidden="true">
      {grad && (
        <defs>
          <linearGradient id={gid} x1="0" y1="0" x2="0.35" y2="1">
            {hfGradStops(paletteId).map((p, i) => <stop key={i} offset={["0%", "46%", "100%"][i]} stopColor={hfMix(accent, p)} />)}
          </linearGradient>
        </defs>
      )}
      <rect x="0.5" y="0.5" width="43" height="29" rx="4.5" fill="var(--color-surface)" stroke="var(--color-border)" strokeWidth="1" />
      <path d="M1 5.5A4.5 4.5 0 0 1 5.5 1H16v28H5.5A4.5 4.5 0 0 1 1 24.5Z" fill={fill} />
      <rect x="4" y="6" width="9" height="2.5" rx="1.25" fill={ink} opacity="0.92" />
      <rect x="4" y="12.5" width="9" height="2.5" rx="1.25" fill={ink} opacity="0.5" />
      <rect x="4" y="19" width="9" height="2.5" rx="1.25" fill={ink} opacity="0.5" />
      <rect x="21" y="7" width="17" height="2.5" rx="1.25" fill="var(--color-text-primary)" opacity="0.34" />
      <rect x="21" y="13.5" width="17" height="9.5" rx="2" fill="var(--color-text-primary)" opacity="0.12" />
    </svg>
  );
}
/* showreel — steps the layout, advancing the palette on each wrap; pauses on hover,
   and any manual pick takes over until the Auto pill hands control back */
function useHFReel({ layIds, layId, setLay, palette, setPalette, ms = 3200 }) {
  // an unprompted carousel is exactly what reduced motion is asking us not to do,
  // so it starts paused there — the Play pill still hands it back on request
  const [on, setOn] = React.useState(() => !(window.matchMedia && matchMedia('(prefers-reduced-motion: reduce)').matches));
  const [hover, setHover] = React.useState(false);
  const [tick, setTick] = React.useState(0);
  const palIds = HF_PALETTES.map((x) => x.id);
  React.useEffect(() => {
    if (!on || hover || (layIds.length < 2 && palIds.length < 2)) return;
    const t = setTimeout(() => {
      // layout is the inner loop, palette the outer: all three navigations, then
      // the next brand colour. A design that brings its own shell offers no
      // layouts at all, so there the palette becomes the only loop.
      const nextLay = layIds.length ? (layIds.indexOf(layId) + 1) % layIds.length : 0;
      if (layIds.length) setLay(layIds[nextLay]);
      if (nextLay === 0) setPalette(palIds[(palIds.indexOf(palette) + 1) % palIds.length]);
      setTick((k) => k + 1);
    }, ms);
    return () => clearTimeout(t);
  }, [on, hover, layId, palette, tick, layIds.join(','), ms]);
  return { on, setOn, paused: hover, tick, ms,
    bind: { onMouseEnter: () => setHover(true), onMouseLeave: () => setHover(false) },
    manual: (fn) => (...a) => { setOn(false); fn(...a); } };
}
/* The stage is a fraction of the panel, and saying so with figures reads better
   than saying so with an apology. Every number here was counted in ../hadrian:
   102 page dirs, 133 'var' rows across core/config, 4 menu locations, 11 blocks
   on Atrium. Keep them counted, not estimated. */
const HF_MISSING = [
  ['96 more pages', 'each with its own template, SEO and layout override'],
  ['133 design tokens', 'colours, typography, buttons, forms, elements'],
  ['The homepage composer', 'up to eleven blocks, dragged into order and sized'],
  ['Four menu locations', 'nested, each item shown by layout and login state'],
  ['A layout per audience', 'guests get one, clients another, on the same URL'],
  ['Alignment, menu side, the account block', 'and a sub-nav with per-page exceptions'],
];
function HeroMore() {
  const [open, setOpen] = React.useState(false);
  return (
    <div className={`hf-more${open ? ' open' : ''}`}>
      <p className="hf-more-line">
        Every control on this stage is real. It is also a corner of the panel —
        <b> six of 102 pages</b>, and not one of the <b>133 tokens</b>.
      </p>
      <button className="hf-more-btn" onClick={() => setOpen(!open)} aria-expanded={open}>
        {open ? 'Close' : 'What would not fit'}
        <svg viewBox="0 0 24 24" width="13" height="13" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" aria-hidden="true"><path d="M6 9l6 6 6-6" /></svg>
      </button>
      {open && (
        <ul className="hf-more-list">
          {HF_MISSING.map(([h, s]) => <li key={h}><b>{h}</b><span>{s}</span></li>)}
        </ul>
      )}
    </div>
  );
}
function HeroStage({ dark }) {
  // off a file:// URL nothing can embed, so offer only the pages we hold a capture of
  const pages = React.useMemo(() => (CA_EMBEDDABLE ? HF_PAGES : HF_PAGES.filter((p) => hfPoster(p.id, 'side'))), []);
  const [page, setPage] = React.useState(pages[0].id);
  const [lay, setLay] = React.useState('side');
  const [tone, setTone] = React.useState('light');
  const [design, setDesign] = React.useState('atrium');
  const [palette, setPalette] = React.useState('blue');
  const pg = pages.find((p) => p.id === page) || pages[0];
  const pal = HF_PALETTES.find((p) => p.id === palette) || HF_PALETTES[0];
  // only the dashboard has more than one design, and one of those brings its own
  // shell — a design with no partials has nothing for layout or tone to act on
  const dsn = pg.designs ? hfDesign(design) : null;
  const src = dsn ? dsn.f : pg.src;
  // a top bar has no side menu to retone, and the login page ships its own chrome
  const toneable = lay !== 'top';
  const layIds = CA_EMBEDDABLE ? HF_LAYOUTS.map((l) => l.wire) : Object.keys(HF_SHOTS[pg.id] || { side: 1 });
  const layId = layIds.indexOf(lay) === -1 ? (layIds[0] || 'top') : lay;
  const reel = useHFReel({ layIds, layId, setLay, palette, setPalette });
  const state = React.useMemo(() => ({
    layout: layId, palette, sidebar: toneable ? tone : 'light', dark, auth: pg.auth || 'in',
  }), [layId, palette, tone, toneable, dark, pg.auth]);
  return (
    <div className="hf" style={{ '--color-accent': pal.c, '--color-accent-light': `color-mix(in srgb, ${pal.c} 12%, transparent)`, '--on-accent-tint': `color-mix(in srgb, ${pal.c} 74%, #000)`, '--color-chrome': hfChromeSolid(toneable ? tone : 'light', pal.c, dark, pal.id), '--color-chrome-ink': hfChromeInk(toneable ? tone : 'light', dark) }} {...reel.bind} data-screen-label="Hero screens">
      <div className="hf-pagectl">
        <span className="hf-lbl">{pages.length > 1 ? 'Page' : 'Client area'}
          <button className="hf-reel" aria-pressed={reel.on} onClick={() => reel.setOn(!reel.on)} title={reel.on ? 'Pause' : 'Play'}>
            <span className="ic">{reel.on ? '❙❙' : '▶'}</span>
            <span>{reel.on ? (reel.paused ? 'Paused' : 'Auto') : 'Play'}</span>
            {reel.on && !reel.paused && <span key={reel.tick} className="prog" style={{ animationDuration: reel.ms + 'ms' }}></span>}
          </button>
        </span>
        <span className="hf-seg" role="tablist" aria-label="Page">
          {pages.map((p) => (
            <button key={p.id} role="tab" aria-selected={page === p.id} onClick={reel.manual(() => setPage(p.id))}>{p.t}</button>
          ))}
        </span>
      </div>
      {pg.designs && (
        <div className="hf-designs">
          <span className="hf-lbl">Dashboard design</span>
          <span className="hf-seg" role="tablist" aria-label="Dashboard design">
            {HF_DESIGNS.map((d) => (
              <button key={d.id} role="tab" aria-selected={design === d.id}
                      onClick={reel.manual(() => setDesign(d.id))}>{d.t}</button>
            ))}
          </span>
          <p className="hf-designnote">{dsn ? dsn.s : ''}</p>
        </div>
      )}
      <div className="hf-picker" role="tablist" aria-label="Navigation layout">
        {HF_LAYOUTS.filter((p) => layIds.indexOf(p.wire) !== -1).map((p) => (
          <button key={p.wire} role="tab" aria-selected={layId === p.wire} onClick={reel.manual(() => setLay(p.wire))} title={p.t}>
            <HFWire kind={p.wire} active={layId === p.wire} />
            <b>{p.t}</b><span>{p.s}</span>
          </button>
        ))}
      </div>
      <div className="hf-stage">
        <div className="hf-rail left" role="tablist" aria-label="Sidebar tone">
          <span className="hf-lbl">Sidebar tone</span>
          {HF_TONES.map((x) => (
            <button key={x.id} role="tab" aria-selected={toneable && tone === x.id} disabled={!toneable} title={toneable ? x.t : 'Top Nav has no side menu to retone'} onClick={reel.manual(() => setTone(x.id))}>
              <HFToneGlyph tone={x.id} accent={pal.c} dark={dark} paletteId={pal.id} />
              <em><b>{x.t}</b><i>{x.s}</i></em>
            </button>
          ))}
        </div>
        <div className="hf-win">
          <div className="hf-art">
            <ThemeFrame
              page={CA_BASE + src}
              state={state}
              poster={hfPoster(pg.id, layId)}
              alt={`Hadrian ${pg.t.toLowerCase()} — ${(HF_LAYOUTS.find((l) => l.wire === layId) || {}).t} layout`}
            />
          </div>
        </div>
        <div className="hf-rail right" role="tablist" aria-label="Brand colour">
          <span className="hf-lbl">Brand colour</span>
          {HF_PALETTES.map((x) => (
            <button key={x.id} role="tab" aria-selected={palette === x.id} onClick={reel.manual(() => setPalette(x.id))} title={x.t}>
              <span className="pair"><i style={{ background: hfChrome(toneable ? tone : 'light', x.c, dark, x.id) }}></i><i style={{ background: x.c }}></i></span><em><b>{x.t}</b></em>
            </button>
          ))}
        </div>
      </div>
      <div className="hf-note">{CA_EMBEDDABLE ? 'The real client area, live — scroll inside the window ↓' : 'Serve this folder over http to run the client area live in the window'}</div>
      <HeroMore />
    </div>
  );
}

function Hero({ onDemo, dark }) {
  const C = (typeof window !== 'undefined' && window.HERO_COPY) || null;
  return (
    <header className={`hp-silicon-hero${C ? ' ' + (C.cls || '') : ''}`} data-screen-label="Hero">
      <div className="hp-wrap" style={{ textAlign: 'center' }}>
        <div className="chip">{C ? C.chip : 'Hadrian · WHMCS client theme'}</div>
        {C
          ? <><h1 className="rom">{C.line1}<br /><span className="rom-2">{C.line2}</span></h1>
              {C.stack
                ? <div className="rom-stack">{C.stack.map((t) => <div key={t}>{t}</div>)}</div>
                : <div className="rom-sub">{C.spaced}</div>}</>
          : <h1>The client area,<br /><em>rebuilt to be used.</em></h1>}
        <p className="copy">{C ? C.copy : <>Six feature levers, six styles and three navigation layouts — <b>every one an admin setting</b>, not a template fork. Here is what your customers actually see.</>}</p>
        <div style={{ display: 'flex', gap: 12, marginTop: 26, flexWrap: 'wrap', justifyContent: 'center' }}>
          <button onClick={onDemo} className="hp-btn solid" style={{ cursor: 'pointer', border: 'none' }}>Open the live demo</button>
          <a href="#features" className="hp-btn ghost">See the features<span aria-hidden="true">›</span></a>
        </div>
      </div>
      <Safe name="HeroStage"><HeroStage dark={dark} /></Safe>
    </header>
  );
}

/* ── .hp-tiles-section.rich ── */
const TILES = [
  {
    k: 'Login-based layouts', h: 'Two audiences.\nOne URL.', V: VizLogin, wide: true,
    p: 'Guests land on a marketing page; clients land on a focused dashboard. Assigned per layout, no hooks required.',
    long: 'Every layout in Hadrian carries two independent activation states — one for guest visitors and one for signed-in clients. The same URL can therefore serve a marketing-led page to a stranger and a dense account dashboard to a customer, decided at render time from the WHMCS session.',
    long2: 'That means no duplicated pages to keep in sync, and no conditional blocks bolted into a template. A host can run a Top Nav marketing shell for acquisition and a Sidebar dashboard for retention, and change either one without touching the other.',
    steps: [['Pick a layout', 'Open Layouts and choose Top Nav, Sidebar or Icon Rail.'], ['Set the two states', 'Toggle Guest client and Existing client independently — Active or Inactive.'], ['Preview it live', 'The preview button opens the real client area, not a mockup.']],
    caption: 'One URL, two rendered experiences',
    points: ['Separate Active / Inactive state per audience on every layout', 'Guests can get Top Nav while clients get the Sidebar', 'Sidebar and Icon Rail add alignment, menu side and the account block', 'No action hooks, no template forks, no duplicated pages'],
    meta: ['Layouts editor', 'Per-audience', 'Live preview'],
  },
  {
    k: 'Homepage composer', h: 'Build the homepage\nfrom blocks.', V: VizBlocks,
    p: 'Pick blocks, drag to order, size them 1/1 to 1/3. Each block carries its own settings.',
    long: 'The client-area homepage is assembled from a block library rather than a fixed template. Toggle a block off, drag it to a new position, and choose how much of the row it occupies. Each block also exposes its own options — row counts, pagination, empty-state copy.',
    long2: 'The editor shows a live wireframe of the resulting grid as you arrange it, so the layout is decided visually rather than by trial and error on the live site. Blocks that support extra configuration open an inline accordion in place, matching the menu editor.',
    steps: [['Choose your blocks', 'Toggle any of the shipped blocks on or off.'], ['Drag to order', 'Grab the handle and reorder — the wireframe updates as you go.'], ['Set each width', 'Assign 1/1, 1/2, 1/3 or 2/3 per block to build the grid.']],
    caption: 'Drag to reorder, toggle to include',
    points: ['Drag-and-drop ordering with live wireframe preview', 'Width per block: 1/1, 1/2, 1/3 or 2/3', 'Per-block additional settings in an inline accordion', 'Blocks: Services, Domains, Invoices, Tickets, Announcements, Quick actions'],
    meta: ['Pages → Homepage', 'Drag to order', 'Per-block settings'],
  },
  {
    k: 'Basic SEO', h: 'Every page.\nEvery language.', V: VizSeo,
    p: 'Titles, descriptions and indexing per page — with a mass editor across all installed languages.',
    long: 'Each client-area page gets its own SEO title, meta description and indexing rule. Because WHMCS installs can run twenty or more languages, the editor also opens a mass view showing every language at once so a translator can work down the list in a single pass.',
    long2: 'Title and description carry live character counters at 64 and 160, so you can see the truncation point before publishing. Pages left empty inherit the WHMCS page title, which makes partial coverage safe.',
    steps: [['Open a page', 'Pick any client-area page in the Pages editor.'], ['Enable SEO settings', 'The title, description and indexing fields appear.'], ['Edit all languages', 'One button opens every language in a single scrollable view.']],
    caption: 'Title, description and indexing, per language',
    points: ['SEO title, meta description and Inherit / Allow / Disallow indexing per page', '“Edit all languages” view for bulk translation passes', 'Character counters at 64 and 160 as you type', 'Falls back to the WHMCS page title when left empty'],
    meta: ['Pages → SEO', 'All languages', 'Per page'],
  },
  {
    k: 'Styles', h: 'Change the colour,\nnot the template.', V: VizStyles, wide: true,
    p: 'Six shipped palettes. Pick one and every accent, link and active state in the client area follows it.',
    long: 'A style here is a palette and nothing more: Default, Emerald, Violet, Rose, Amber and Slate, each carrying nine colour values per mode. Activate one and it seeds those values into the colour editor as ordinary rows, so the preset is your starting point rather than a locked bundle — every row keeps its own picker afterwards.',
    long2: 'Because it is tokens in the database rather than edits in a template, a restyle survives every WHMCS update. Shape lives elsewhere on purpose: corner radius, shadows, button and form treatment are their own panels, so changing the brand colour never quietly changes the furniture.',
    steps: [['Pick a style', 'Default, Emerald, Violet, Rose, Amber or Slate — applied across the client area.'], ['Edit any row', 'The preset seeds the colour editor; every token stays editable in place.'], ['Go further', 'Typography, buttons, forms and elements are separate panels — 129 tokens in all.']],
    caption: 'One palette, every accent follows',
    points: ['Six shipped styles: Default, Emerald, Violet, Rose, Amber, Slate', 'Activating a style seeds its palette into editable rows', '133 tokens across colours, type, buttons, forms and elements', 'Dark mode runs across all six, as a mode rather than a seventh style'],
    meta: ['Styles editor', '6 styles', 'Light + dark'],
  },
  {
    k: 'Page templates', h: 'Four dashboards.\nOne page editor.', V: VizTemplates,
    p: 'The pages worth arguing over ship more than one design — the dashboard has four. Assign per page, then open the real page to check.',
    long: 'All 102 client-area pages are listed in one editor. Three of them carry a choice of design: the dashboard ships Default, Atrium, Bento and Minimal; the homepage ships Default, Portal and Simple; the login page ships Default and Split. The rest ship the one design they were drawn with.',
    long2: 'When a template carries its own options they appear directly beneath the selector; when it has none, the panel says so rather than leaving an empty box. A per-page Custom layout override is there for the pages that need to break from the site-wide setting.',
    steps: [['Select the page', 'Search or browse all 102 pages in the Pages editor.'], ['Choose a template', 'Where the page offers more than one, with its own settings below.'], ['Open the page', 'View page opens it on the site itself, not a mockup.']],
    caption: 'Default, Atrium, Bento and Minimal',
    points: ['Dashboard: Default, Atrium, Bento and Minimal', 'Homepage: Default, Portal and Simple · Login: Default and Split', 'Template-specific settings appear when the template has them', 'Per-page custom layout override, and per-page SEO'],
    meta: ['Pages editor', '102 pages', 'View page'],
  },
  {
    k: 'Typography', h: 'Type that\nbehaves.', V: VizFonts, wide: true,
    p: 'System, Google, or your own stack — and a full size scale, so one family never means one size.',
    long: 'Typography is a first-class token group. Choose the system stack, pick one of twelve curated Google fonts, or paste your own font-family declaration. Sizes are defined as a scale — from Extra Small through Display XL — so headings and body text stay in proportion when you change one value.',
    long2: 'Eighteen size steps and six weight slots, each stored as a token rather than written into a template. One family runs the whole client area; the scale is what does the work of separating a heading from a caption.',
    steps: [['Choose the source', 'System stack, one of twelve Google fonts, or your own custom stack.'], ['Set the scale', 'Body sizes (8 steps), headings h1–h6, and four display sizes.'], ['Map the weights', 'Six slots, each pointing at a weight from 100 to 900.']],
    caption: 'Same layout, three type stacks',
    points: ['System, twelve curated Google fonts, or a custom font stack', 'Full size scale: body (8 steps), headings (h1–h6), display (4 steps)', 'Six weight slots, each mapped from 100 to 900', 'One family across the client area — the scale carries the hierarchy'],
    meta: ['Styles → Typography', 'Google Fonts', '18 size steps'],
  },
];
function FeatureModal({ t, onClose }) {
  React.useEffect(() => {
    const k = (e) => { if (e.key === 'Escape') onClose(); };
    document.addEventListener('keydown', k);
    const prev = document.body.style.overflow;
    document.body.style.overflow = 'hidden';
    return () => { document.removeEventListener('keydown', k); document.body.style.overflow = prev; };
  }, [onClose]);
  return (
    <div className="hp-modal-scrim" onClick={onClose} role="presentation">
      <div className="hp-modal" role="dialog" aria-modal="true" aria-label={t.k} onClick={(e) => e.stopPropagation()}>
        <div className="hp-modal-stage">
          <div className="hp-modal-viz"><t.V /></div>
          <div className="hp-modal-caption">{t.caption}</div>
        </div>
        <div className="hp-modal-side">
          <div className="hp-modal-head">
            <div>
              <div className="k">{t.k}</div>
              <h3>{t.h.replace('\n', ' ')}</h3>
            </div>
            <button className="hp-modal-x" onClick={onClose} aria-label="Close">✕</button>
          </div>
          <div className="hp-modal-body">
            <p>{t.long}</p>
            <p>{t.long2}</p>
            <h4>How it works</h4>
            <div className="hp-modal-steps">
              {t.steps.map(([b, d], k) => (
                <div key={b} className="hp-modal-step">
                  <span className="n">{k + 1}</span>
                  <span className="t"><b>{b}.</b> {d}</span>
                </div>
              ))}
            </div>
            <h4>What you get</h4>
            <ul>{t.points.map((x) => <li key={x}>{x}</li>)}</ul>
            <div className="hp-modal-meta">{t.meta.map((m) => <span key={m}>{m}</span>)}</div>
          </div>
        </div>
      </div>
    </div>
  );
}
function Tiles() {
  const [open, setOpen] = React.useState(null);
  return (
    <section id="features" className="hp-sec" data-screen-label="Features">
      <div className="hp-wrap">
        <Up>
          <div className="hp-eyebrow">The feature set</div>
          <h2 className="hp-h2">Six levers, shipped in the theme.</h2>
          <p className="hp-lead">Every one of these is an admin setting — no child theme, no template edits, no lost work at the next WHMCS update. Tap the info icon on any card for the detail.</p>
        </Up>
        <div className="hp-tiles-section" style={{ marginTop: 34 }}>
          {TILES.map((t) => (
            <Up key={t.k} className={t.wide ? 'w2' : ''}>
              <article className={`hp-tile${t.wide ? ' w2' : ''}`}>
                <button className="hp-tile-info" onClick={() => setOpen(t)} aria-label={`More about ${t.k}`} title={`More about ${t.k}`}>i</button>
                <div className="tw-copy">
                  <div className="k">{t.k}</div>
                  <h3 style={{ whiteSpace: 'pre-line' }}>{t.h}</h3>
                  <p>{t.p}</p>
                </div>
                <div className="viz"><Safe name={t.k}><t.V /></Safe></div>
              </article>
            </Up>
          ))}
        </div>
      </div>
      {open && <FeatureModal t={open} onClose={() => setOpen(null)} />}
    </section>
  );
}

/* ── the Menu spotlight runs the real admin panel ──
   ../Hadrian by Caesarthemes/hadrian-admin-panel is the panel the module's
   design follows, and it is hash-routed with a hashchange listener, so #menu
   deep-links straight to its Menu page. Embedding it beats redrawing it: the
   tree, the item form and the three menus are the actual screens.
   MenuSpot stays as the fallback for the cases a frame cannot serve -- off a
   file:// URL, or with no network for the React and Babel the panel loads. */
/* The directory, with the trailing slash, not index.html: a static host that
   rewrites /x.html to /x normalises /dir/index.html all the way down to /dir,
   and a URL with no trailing slash makes the browser treat the last segment as
   a file -- so the panel's relative apple-admin.jsx resolves one directory too
   high and 404s, leaving an empty #root. Asking for the directory keeps the
   base where the assets are. */
const ADMIN_BASE = '../Hadrian by Caesarthemes/hadrian-admin-panel/';
const ADMIN_WIDTH = 1180;   // narrower than the client area: the panel is one column of cards
function AdminSpot({ view, dark, label }) {
  const state = React.useMemo(() => ({ admin: true, dark }), [dark]);
  return (
    <div className="sp-adminframe">
      <ThemeFrame
        page={`${ADMIN_BASE}#${view}`}
        state={state}
        width={ADMIN_WIDTH}
        alt={label}
        fallback={<MenuSpot />}
      />
    </div>
  );
}

/* ── .hp-spot: one block per feature, alternating side ── */
const SPOTS = [
  { id: 'menu', side: 'right', k: 'Menu manager', h: 'Three menus.\nEvery item, yours.', C: (p) => <AdminSpot view="menu/1" label="The Hadrian admin panel, Menu items" {...p} />,
    p: 'Main, Secondary and Footer menus, each with its own tree. Drag items into order, nest them as deep as you need, and give every one its own type, icon and audience.',
    li: ['Nested items with drag-and-drop ordering', 'Per-item visibility by layout and login state', 'Language variables or a custom string, per item'] },
  { id: 'composer', side: 'left', k: 'Homepage composer', h: 'Compose the page\nthey land on.', C: BlocksSpot,
    p: 'Pick the blocks that appear on the client homepage, drag them into order, and size each one from a full row down to a third. The preview is the page.',
    li: ['Up to eleven blocks, each with its own settings', 'Widths from 1/1 to 1/3, cycled in place', 'Toggle any block off without losing its setup'] },
  { id: 'seo', side: 'right', k: 'Multi-language SEO', h: 'Every language,\none pass.', C: SeoSpot,
    p: 'Titles, descriptions and indexing per page — and when a translation pass is due, the mass editor opens every installed language side by side instead of one at a time.',
    li: ['Per-page title, description and indexing', 'All installed WHMCS languages in one editor', 'Coverage shown per page, so nothing is missed'] },
];
function Spotlights({ dark }) {
  return (
    <>
      {SPOTS.map((s) => (
        <section key={s.id} id={s.id} className="hp-spot" data-side={s.side} data-screen-label={s.k}>
          <div className="hp-wrap">
            <div className="grid">
              <Up className="copy">
                <div className="hp-eyebrow">{s.k}</div>
                <h2 style={{ whiteSpace: 'pre-line' }}>{s.h}</h2>
                <p>{s.p}</p>
                <ul>{s.li.map((t) => <li key={t}>{t}</li>)}</ul>
                <a href="#demo" className="more">See it in the demo<span aria-hidden="true">›</span></a>
              </Up>
              <Up className="vis"><Safe name={s.k}><s.C dark={dark} /></Safe></Up>
            </div>
          </div>
        </section>
      ))}
    </>
  );
}

/* ── .hp-feature-tabs (layouts) ── */
const LAYOUTS = [
  { n: 'Top Nav', kind: 'top', h: 'Horizontal, centred, familiar.', p: 'A single top bar with optional icons. Content is centred — the layout every WHMCS client already recognises.', li: ['Optional top-nav icons', 'Content always centred', 'Mega-menu support', 'Best for marketing-led portals'] },
  { n: 'Sidebar', kind: 'side', h: 'A rail that holds structure.', p: 'Named navigation with section grouping. Content aligns left or centre, the menu can sit on either side, and the section sub-nav can be hidden globally with per-page exceptions.', li: ['Named items with icons', 'Left or centred content', 'Menu on the left or the right', 'Account block shown or hidden', 'Collapsible section sub-nav', 'Best for service-heavy accounts'] },
  { n: 'Icon Rail', kind: 'rail', h: 'Maximum room for the work.', p: 'An 80px strip of icons, each with its label under it, and a flyout panel on hover for the sections that have children. The narrowest chrome in the theme — everything else goes to content.', li: ['80px rail, against the sidebar’s 260px', 'Icon and label together, no hunting', 'Flyout panels on hover', 'Best for dashboards and dense tables'] },
];
function LayoutTabs() {
  const [i, setI] = React.useState(1);
  const L = LAYOUTS[i];
  return (
    <section id="layouts" className="hp-sec" data-screen-label="Layouts">
      <div className="hp-wrap hp-feature-tabs">
        <Up>
          <div className="hp-eyebrow">Layouts</div>
          <h2 className="hp-h2">Three navigations. Assign per audience.</h2>
          <p className="hp-lead">Guests can get Top Nav while clients get the Sidebar — every layout carries its own activation state per audience. Sidebar and Icon Rail add alignment, which side the menu sits on, and whether the account block shows; Top Nav is centred by design and takes none of them.</p>
        </Up>
        <div className="tabs" role="tablist">
          {LAYOUTS.map((l, k) => <button key={l.n} role="tab" aria-selected={k === i} onClick={() => setI(k)}>{l.n}</button>)}
        </div>
        <div className="panel">
          <div>
            <h3>{L.h}</h3>
            <p>{L.p}</p>
            <ul>{L.li.map((x) => <li key={x}>{x}</li>)}</ul>
          </div>
          <div key={i} style={{ animation: 'none' }}><VizLayout kind={L.kind} /></div>
        </div>
      </div>
    </section>
  );
}

/* ── .hp-founding · a popup, opened from the banner and the pricing block ── */
const FOUNDING_PTS = [
  { n: '01', h: 'Priority on the roadmap', p: 'Founding clients submit and rank requests in a shared board. What the group ranks highest gets built next — before anything on our own list.' },
  { n: '02', h: 'A direct line', p: 'A private channel to the developers, not a ticket queue. Bugs from founding installs jump the line.' },
  { n: '03', h: 'The launch price, for good', p: 'Your renewal stays at the founding rate for as long as the license stays active, however far the list price moves.' },
];
function Founding({ open, onClose }) {
  React.useEffect(() => {
    if (!open) return;
    const k = (e) => { if (e.key === 'Escape') onClose(); };
    document.addEventListener('keydown', k);
    const prev = document.body.style.overflow;
    document.body.style.overflow = 'hidden';
    return () => { document.removeEventListener('keydown', k); document.body.style.overflow = prev; };
  }, [open, onClose]);
  if (!open) return null;
  return (
    <div className="hp-fscrim" onClick={onClose} role="presentation">
      <div className="hp-founding card" role="dialog" aria-modal="true" aria-label="Founding licenses" onClick={(e) => e.stopPropagation()}>
        <button className="x" onClick={onClose} aria-label="Close">✕</button>
        <div className="head">
          <div>
            <div className="hp-eyebrow" style={{ color: 'inherit', opacity: .72 }}>Founding licenses</div>
            <h2>The first fifty<br />decide what we build next.</h2>
            <p>Hadrian ships with six feature levers today. What follows them is not decided yet — and founding clients decide it. Buy in the launch window and a single license is $20 instead of $99, held at that rate on every renewal, plus a vote on every release.</p>
            <div className="acts">
              <a href="#pricing" className="hp-btn solid" onClick={onClose}>Claim a founding license</a>
              <a href="#features" className="hp-btn ghost" onClick={onClose}>See what ships today<span aria-hidden="true">›</span></a>
            </div>
          </div>
          <div className="tally">
            <div className="off">$20<small>/yr</small></div>
            <div className="lbl">single license · was $99</div>
            <div className="bar"><span style={{ width: '32%' }}></span></div>
            <div className="left"><b>34 of 50</b> founding licenses left</div>
          </div>
        </div>
        <div className="pts">
          {FOUNDING_PTS.map((x) => (
            <div key={x.n} className="pt"><span className="n">{x.n}</span><b>{x.h}</b><p>{x.p}</p></div>
          ))}
        </div>
        <div className="foot">Founding pricing closes at 50 licenses or 31 October 2026, whichever comes first.</div>
      </div>
    </div>
  );
}

/* ── .hp-plans · two self-contained license cards ── */
const TIERS = [
  { id: 'single', t: 'Single license', p: '$20', was: '$99', per: 'per year', dom: 'Single Domain', badge: 'Best value',
    tip: 'One production domain, plus a development or staging copy of the same site at no extra cost.' },
  { id: 'five', t: 'Five licenses', p: '$99', was: '$250', per: 'per year', dom: 'Five Domains', badge: null,
    tip: 'Up to five production domains under one account, each with its own development copy.' },
];
function Plan({ x }) {
  return (
    <article className={`hp-plan${x.badge ? ' pop' : ''}`}>
      {x.badge && <span className="badge">{x.badge}</span>}
      <h3>{x.t}</h3>
      <div className="price"><b>{x.p}</b><s>{x.was}</s></div>
      <div className="per">{x.per}</div>
      <span className="rule"></span>
      <ul>
        <li><b>1 year</b> of support</li>
        <li><b>1 year</b> of updates</li>
        <li>License for a <b>{x.dom}</b>
          <span className="tip" tabIndex={0} role="button" aria-label={`About the ${x.dom} license`}>?<span className="bub">{x.tip}</span></span>
        </li>
        <li>License valid for a <b>lifetime</b></li>
      </ul>
      <a href="#" className="hp-btn solid">Buy {x.t}</a>
    </article>
  );
}
function Pricing({ onDemo, onFounding }) {
  return (
    <section id="pricing" className="hp-sec hp-pricing" style={{ paddingTop: 0 }} data-screen-label="Pricing">
      <div className="hp-wrap" style={{ textAlign: 'center' }}>
        <Up>
          <div className="hp-eyebrow">Pricing</div>
          <h2 className="hp-h2" style={{ marginLeft: 'auto', marginRight: 'auto' }}>One license. Everything in it.</h2>
          <button className="hp-foundtag" onClick={onFounding}><span>Founding price</span>up to 80% off while the first 50 last <i aria-hidden="true">›</i></button>
        </Up>
        <div className="hp-plans">
          {TIERS.map((x) => <Plan key={x.id} x={x} />)}
        </div>
        <div className="hp-pfoot">
          <button onClick={onDemo} className="hp-btn ghost">Try the demo first</button>
          <p>14-day refund policy. The theme keeps working after the year — renewal only extends support and updates.</p>
        </div>
      </div>
    </section>
  );
}

/* ── .hp-ext: marketplace tiles — illustrated icon, label, name, price, link ── */
function ArtAdmin() {
  return (
    <svg width="150" height="150" viewBox="0 0 150 150" fill="none" aria-hidden="true">
      <rect x="18" y="34" width="96" height="74" rx="12" fill="var(--color-accent)" opacity=".14" />
      <rect x="36" y="20" width="96" height="74" rx="12" fill="var(--color-accent)" />
      <rect x="50" y="36" width="52" height="7" rx="3.5" fill="#fff" opacity=".95" />
      <rect x="50" y="52" width="68" height="6" rx="3" fill="#fff" opacity=".55" />
      <rect x="50" y="66" width="40" height="6" rx="3" fill="#fff" opacity=".55" />
      <circle cx="112" cy="70" r="11" fill="#fff" />
      <path d="M107 70h10M112 65v10" stroke="var(--color-accent)" strokeWidth="2.4" strokeLinecap="round" />
      <rect x="44" y="112" width="62" height="8" rx="4" fill="var(--color-accent)" opacity=".28" />
    </svg>
  );
}
function ArtEmail() {
  return (
    <svg width="150" height="150" viewBox="0 0 150 150" fill="none" aria-hidden="true">
      <rect x="22" y="40" width="106" height="72" rx="12" fill="#5856d6" opacity=".16" />
      <path d="M28 52a10 10 0 0 1 10-10h74a10 10 0 0 1 10 10v46a10 10 0 0 1-10 10H38a10 10 0 0 1-10-10z" fill="#5856d6" />
      <path d="M32 54l43 30 43-30" stroke="#fff" strokeWidth="4.5" strokeLinecap="round" strokeLinejoin="round" fill="none" />
      <circle cx="112" cy="46" r="15" fill="#fff" />
      <path d="M112 40.5a5.5 5.5 0 1 0 3.9 9.4" stroke="#5856d6" strokeWidth="2.2" strokeLinecap="round" fill="none" />
      <circle cx="112" cy="46" r="2.4" fill="#5856d6" />
    </svg>
  );
}
function ArtInvoice() {
  return (
    <svg width="150" height="150" viewBox="0 0 150 150" fill="none" aria-hidden="true">
      <rect x="24" y="30" width="80" height="94" rx="10" fill="#0d9488" opacity=".16" />
      <path d="M42 22h60a8 8 0 0 1 8 8v98l-11-8-11 8-11-8-11 8-11-8-11 8V30a8 8 0 0 1 8-8z" fill="#0d9488" />
      <rect x="52" y="44" width="46" height="6" rx="3" fill="#fff" opacity=".95" />
      <rect x="52" y="60" width="46" height="5" rx="2.5" fill="#fff" opacity=".5" />
      <rect x="52" y="74" width="30" height="5" rx="2.5" fill="#fff" opacity=".5" />
      <circle cx="106" cy="98" r="16" fill="#fff" />
      <path d="M100 98l4.5 4.5L113 94" stroke="#0d9488" strokeWidth="3.2" strokeLinecap="round" strokeLinejoin="round" fill="none" />
    </svg>
  );
}
function ArtWebsite() {
  return (
    <svg width="150" height="150" viewBox="0 0 150 150" fill="none" aria-hidden="true">
      <rect x="20" y="40" width="104" height="76" rx="12" fill="#7c3aed" opacity=".16" />
      <rect x="32" y="24" width="98" height="74" rx="11" fill="#7c3aed" />
      <path d="M32 40h98" stroke="#fff" strokeWidth="2.4" opacity=".55" />
      <circle cx="41" cy="32" r="2.6" fill="#fff" opacity=".8" />
      <circle cx="49" cy="32" r="2.6" fill="#fff" opacity=".55" />
      <circle cx="57" cy="32" r="2.6" fill="#fff" opacity=".55" />
      <rect x="42" y="50" width="34" height="34" rx="5" fill="#fff" opacity=".95" />
      <rect x="82" y="50" width="38" height="7" rx="3.5" fill="#fff" opacity=".85" />
      <rect x="82" y="63" width="30" height="6" rx="3" fill="#fff" opacity=".5" />
      <rect x="82" y="75" width="38" height="9" rx="4.5" fill="#fff" opacity=".95" />
      <circle cx="112" cy="106" r="17" fill="#fff" />
      <path d="M105 106h14M112 99v14" stroke="#7c3aed" strokeWidth="3" strokeLinecap="round" />
    </svg>
  );
}
function ArtVote() {
  return (
    <svg width="112" height="112" viewBox="0 0 96 96" fill="none" aria-hidden="true">
      <circle cx="48" cy="48" r="44" stroke="currentColor" strokeWidth="2" strokeDasharray="7 8" opacity=".5" />
      <path d="M48 32v32M32 48h32" stroke="currentColor" strokeWidth="4" strokeLinecap="round" />
    </svg>
  );
}
const EXTS = [
  { id: 'admin', A: ArtAdmin, lbl: 'Included with the theme', h: 'Admin Panel', price: 'Free', note: 'with Hadrian', cta: 'Learn more', ribbon: null },
  { id: 'email', A: ArtEmail, lbl: 'Extension', h: 'Email Template Builder', price: 'Q4 2026', note: 'price at launch', cta: 'Get notified', ribbon: 'New' },
  { id: 'invoice', A: ArtInvoice, lbl: 'Extension', h: 'Invoice Builder', price: 'Q1 2027', note: 'price at launch', cta: 'Get notified', ribbon: null },
  { id: 'website', A: ArtWebsite, lbl: 'Extension', h: 'Website Builder', price: 'Q2 2027', note: 'price at launch', cta: 'Get notified', ribbon: null },
  { id: 'vote', A: ArtVote, lbl: 'Your request', h: "You decide what's next", em: 'Founding clients rank the roadmap. What the group ranks highest gets built first.', cta: 'See the founding offer', slot: true },
];
function Extensions({ onFounding }) {
  const rail = React.useRef(null);
  const [i, setI] = React.useState(0);
  const [pageable, setPageable] = React.useState(false);
  React.useEffect(() => {
    const measure = () => {
      const r = rail.current;
      setPageable(!!r && r.scrollWidth - r.clientWidth > 4);
    };
    measure();
    window.addEventListener('resize', measure);
    const t = setTimeout(measure, 400);
    return () => { window.removeEventListener('resize', measure); clearTimeout(t); };
  }, []);
  const go = (k) => {
    const n = Math.max(0, Math.min(EXTS.length - 1, k));
    setI(n);
    const r = rail.current; if (!r) return;
    const c = r.children[n]; if (!c) return;
    r.scrollTo({ left: Math.min(c.offsetLeft - 20, r.scrollWidth - r.clientWidth), behavior: 'smooth' });
  };
  const onScroll = () => {
    const r = rail.current; if (!r) return;
    const mid = r.scrollLeft + r.clientWidth / 2;
    let best = 0, dist = Infinity;
    Array.from(r.children).forEach((c, k) => {
      const d = Math.abs(c.offsetLeft + c.clientWidth / 2 - mid);
      if (d < dist) { dist = d; best = k; }
    });
    setI(best);
  };
  return (
    <section id="extensions" className="hp-sec hp-ext" style={{ paddingTop: 0 }} data-screen-label="Extensions">
      <div className="hp-wrap" style={{ textAlign: 'center' }}>
        <Up>
          <div className="hp-eyebrow">Extensions</div>
          <h2 className="hp-h2" style={{ marginLeft: 'auto', marginRight: 'auto' }}>The roadmap, in the open.</h2>
          <p className="lead">One ships with the theme. Two are being built now — and founding clients get a vote on which lands first.</p>
          <button className="explore" onClick={onFounding}>Explore all extensions <span aria-hidden="true">↗</span></button>
        </Up>
      </div>
      <div className="hp-extrail" ref={rail} onScroll={onScroll}>
        {EXTS.map((x) => (
          <article key={x.id} className={`hp-extcard${x.slot ? ' slot' : ''}`}>
            {x.ribbon && <span className="ribbon"><span>{x.ribbon}</span></span>}
            <span className="art"><x.A /></span>
            <div className="lbl">{x.lbl}</div>
            <h3>{x.h}</h3>
            {x.em ? <em>{x.em}</em> : <div className="price"><b>{x.price}</b> {x.note}</div>}
            <a href="#" className="more" onClick={(e) => { if (x.slot) { e.preventDefault(); onFounding(); } }}>{x.cta}</a>
          </article>
        ))}
      </div>
      {pageable && (
        <div className="hp-extdots">
          {EXTS.map((x, k) => <button key={x.id} onClick={() => go(k)} aria-current={k === i} aria-label={x.h} title={x.h}></button>)}
        </div>
      )}
    </section>
  );
}

/* ── .hp-faq (V1 style: flat accordion, accent plus icon) ── */
const FAQS = [
  ['Is the license per installation?', 'Yes — one license covers one WHMCS installation with unlimited client accounts. Additional installations need their own license.'],
  ['What happens when the license lapses?', 'The theme keeps working. You stop receiving updates and support until it is renewed.'],
  ['How long does installation take?', 'Upload the theme folder, activate it in WHMCS, and open the Hadrian admin panel. Most installs are done in under five minutes.'],
  ['Does it overwrite my WHMCS templates?', 'No. Hadrian installs alongside the default templates and can be deactivated at any time without data loss.'],
  ['Can guests and clients see different layouts?', 'Yes — every layout has separate activation states for guest and existing client, so the same URL can serve two experiences.'],
  ['Can I hide the section sidebar on specific pages?', 'Turn it off globally and add per-page exceptions, or set it directly on a page in the Pages editor — the page setting wins.'],
  ['How many languages does the SEO editor support?', 'Every language installed in WHMCS. The mass editor shows all of them at once for bulk edits.'],
  ['Will updates overwrite my settings?', 'No. Settings, styles and menus live in the database, not in template files.'],
  ['Is there a refund policy?', '14 days, no questions asked, for first-time purchases.'],
];
function Faq() {
  const [open, setOpen] = React.useState(0);
  return (
    <section id="faq" className="hp-sec" style={{ paddingTop: 0 }} data-screen-label="FAQ">
      <div className="hp-wrap hp-faq" style={{ maxWidth: 860 }}>
        <Up>
          <div style={{ textAlign: 'center', marginBottom: 40 }}>
            <div className="hp-eyebrow">FAQ</div>
            <h2 className="hp-h2" style={{ marginLeft: 'auto', marginRight: 'auto' }}>Questions, answered.</h2>
          </div>
        </Up>
        <div>
          {FAQS.map(([q, a], i) => (
            <div key={q} className={`hp-faq-item${open === i ? ' open' : ''}`}>
              <button className="q" onClick={() => setOpen(open === i ? -1 : i)} aria-expanded={open === i}>
                <span>{q}</span>
                <svg className="plus" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.6" strokeLinecap="round"><path d="M12 5v14M5 12h14" /></svg>
              </button>
              {open === i && <div className="a">{a}</div>}
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}

/* ── .hp-cta-immersive ── */
function Cta({ onDemo }) {
  return (
    <section id="demo" className="hp-cta-immersive" data-screen-label="CTA">
      <h2>See it running.</h2>
      <p>The full client area, live — pick a layout and a style in the demo builder.</p>
      <div style={{ display: 'flex', gap: 12, justifyContent: 'center', marginTop: 30, flexWrap: 'wrap' }}>
        <button onClick={onDemo} className="hp-btn solid" style={{ background: '#f5f5f7', color: '#1d1d1f', cursor: 'pointer', border: 'none' }}>Open the demo builder</button>
        <a href="Hadrian Documentation.html" className="hp-btn" style={{ border: '1px solid #3a3a3c', color: '#f5f5f7' }}>Read the docs<span aria-hidden="true">›</span></a>
      </div>
    </section>
  );
}

/* ── .hp-footer · V1 layout: brand column + four link columns ── */
function Footer() {
  const cols = [
    { h: 'Products', links: ['Hadrian Client Theme', 'Augustus Email', 'Trajan Website CMS', 'Smart Order'] },
    { h: 'In the admin panel', links: ['Styles', 'Layouts', 'Pages & SEO', 'Menu manager'] },
    { h: 'Resources', links: ['Documentation', 'Changelog', 'Live Demo', 'Support'] },
    { h: 'Company', links: ['About', 'Contact', 'Refund Policy', 'License Terms'] },
  ];
  return (
    <footer className="hp-footer" data-screen-label="Footer">
      <div className="hp-wrap">
        <div className="hp-footcols">
          <div className="brandcol">
            <a href="#top" className="brand">
              <span className="hp-mark"></span>
              <span className="word">Hadrian</span>
            </a>
            <p>A premium WHMCS client area theme by Caesarthemes — clarity, speed, and a refined design system.</p>
          </div>
          {cols.map((c) => (
            <div key={c.h}>
              <h5>{c.h}</h5>
              <ul>{c.links.map((l) => <li key={l}><a href="#">{l}</a></li>)}</ul>
            </div>
          ))}
        </div>
        <div className="hp-footbottom">
          <span>© 2026 Caesarthemes. All rights reserved.</span>
          <span className="legal">{['Privacy', 'Terms', 'Sitemap'].map((l) => <a key={l} href="#">{l}</a>)}</span>
        </div>
      </div>
    </footer>
  );
}

function App() {
  const [dark, setDark] = React.useState(() => { try { return localStorage.getItem('hadrian-lp5-theme') === 'dark'; } catch (e) { return false; } });
  const [demo, setDemo] = React.useState(false);
  const [founding, setFounding] = React.useState(false);
  const openFounding = React.useCallback(() => setFounding(true), []);
  const openDemo = React.useCallback(() => setDemo(true), []);
  React.useEffect(() => {
    document.documentElement.setAttribute('data-theme', dark ? 'dark' : 'light');
    try { localStorage.setItem('hadrian-lp5-theme', dark ? 'dark' : 'light'); } catch (e) {}
  }, [dark]);
  // The page is client-rendered, so a #features deep link from the About page
  // arrives before its target exists. Re-run the jump once the tree is mounted.
  React.useEffect(() => {
    const hash = location.hash.slice(1);
    if (!hash) return;
    const jump = () => {
      const el = document.getElementById(hash);
      if (el) el.scrollIntoView({ behavior: 'auto', block: 'start' });
    };
    jump();
    const t = setTimeout(jump, 120);
    return () => clearTimeout(t);
  }, []);
  return (
    <div className="hp" id="top">
      <Strip onFounding={openFounding} />
      <Utility dark={dark} onDark={() => setDark(!dark)} />
      <Nav dark={dark} onDark={() => setDark(!dark)} onDemo={openDemo} />
      <Hero onDemo={openDemo} dark={dark} />
      <Tiles />
      <Spotlights dark={dark} />
      <LayoutTabs />
      <Pricing onDemo={openDemo} onFounding={openFounding} />
      <Extensions onFounding={openFounding} />
      <Faq />
      <Cta onDemo={openDemo} />
      <Footer />
      <Founding open={founding} onClose={() => setFounding(false)} />
      <AccentPanel dark={dark} onDark={() => setDark(!dark)} />
      <DemoDrawer open={demo} onClose={() => setDemo(false)} />
    </div>
  );
}
ReactDOM.createRoot(document.getElementById('root')).render(<App />);
