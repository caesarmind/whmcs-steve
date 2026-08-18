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
  const links = [['#features', 'Features', true], ['#extensions', 'Extensions', false], ['#pricing', 'Pricing', false], ['#faq', 'FAQ', false]];
  return (
    <nav className="homepage-nav">
      <div className="inner">
        <a href="#top" className="brand">
          <img className="hp-brand-logo" src={CA_BASE + 'img/branding/hadrian-logo.png'} alt="Hadrian" />
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
/* One brand application for the whole document. Both the hero's colour rail and
   the floating style panel call this, so picking a colour in either place retints
   the site itself - not just the demo frame - and the two controls stay in step
   through the shared 'hadrian-style' key. */
function applyBrandToSite(id) {
  const st = STYLES.find((s) => s.id === id) || STYLES[0];
  const r = document.documentElement;
  r.style.setProperty('--color-accent', st.brand);
  r.style.setProperty('--color-accent-hover', st.brand);
  r.style.setProperty('--color-accent-light', `color-mix(in srgb, ${st.brand} 12%, transparent)`);
  r.style.setProperty('--color-link', st.brand);
  r.style.setProperty('--on-accent-tint', `color-mix(in srgb, ${st.brand} 74%, #000)`);
  r.style.setProperty('--color-chrome', st.chrome);
  r.style.setProperty('--color-chrome-ink', st.ink);
  try { localStorage.setItem('hadrian-style', st.id); } catch (e) {}
}
function AccentPanel({ dark, onDark }) {
  const [open, setOpen] = React.useState(false);
  const [i, setI] = React.useState(0);
  const apply = (st) => applyBrandToSite(st.id);
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
  { id: 'dashboard', t: 'Dashboard', src: 'clientareahome-v18.html', variants: 'dashboard' },
  { id: 'homepage', t: 'Homepage', src: 'homepage.html', variants: 'homepage' },
  // no in-page aside: the services table is the point of this page, and the
  // sub-nav repeats links the main navigation already carries
  { id: 'services', t: 'Services', src: 'clientareaproducts.html', subnav: 'off' },
  { id: 'store', t: 'Store', src: 'store.html', variants: 'store' },
  // the module ships two sign-in designs, and Split brings its own chrome
  { id: 'login', t: 'Login', src: 'login.html', auth: 'out', variants: 'login' },
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
  { id: 'atrium', t: 'Atrium', band: true, f: 'clientareahome-v18.html',
    s: 'A welcome band, then an asymmetric two-column body: the collections you read down the wide side, the things you act on down the narrow one. Width assigns a block to a column rather than sizing it on a grid, so reordering moves a block within its column.' },
  { id: 'bento', t: 'Bento', band: true, f: 'clientareahome-v17.html',
    s: 'A bento grid of self-contained cards. Each collection gets its own tile with a count and its rows, arranged two-up on a six-column grid. Adds an attention strip that pulls the few things needing action out of the many rows, and an identity card beside the greeting.' },
  { id: 'minimal', t: 'Minimal', f: 'clientareahome-v15.html',
    s: 'A quieter dashboard: greeting, four summary tiles, quick actions, then services, domains, invoices, tickets and announcements as plain rows on one surface. No panel grid or account sub-nav aside.' },
  { id: 'default', t: 'Classic', f: 'clientareahome-v9.html',
    s: 'The familiar shape: a greeting hero over plain tables, one after another.' },
];
/* The three sign-in designs, from core/pages/login/. Names are ours: the module
   describes only its split, and these read better as a set. Default goes last --
   it is the plain fallback, and the two full-bleed designs are what a buyer is
   here to see -- so Split leads and is what the page opens on.
   Split and Marquee both drop every partial but the state chip: no portal nav,
   no sidebar, no footer. Hence shell: false, which greys out the layout and tone
   controls rather than leaving them to no-op. Default keeps the full chrome.
   (The mockup holds two further splits, v2 and v3, not offered here.) */
const HF_LOGINS = [
  { id: 'split', t: 'Split', f: 'login-v5.html', shell: false, tones: true,
    s: 'Full-bleed two columns: the sign-in form on one side, the latest announcements as cards on the other, both on the theme’s own calm surfaces.' },
  { id: 'marquee', t: 'Marquee', f: 'login-v4.html', shell: false,
    s: 'A welcome band across the top, the sign-in card beneath it, and the latest announcements in a grid below — the closest of the three to the dashboard’s own shape.' },
  { id: 'default', t: 'Default', f: 'login.html',
    s: 'The sign-in form on a card in the middle of the page, with the portal navigation, sidebar and footer still around it.' },
];
/* Welcome band styles. The module and the mockup grew these separately and use
   different words for the same fills, so the labels are the module's -- what a
   buyer sees in the Pages editor -- and the values are the mockup's attribute:

     module data-at-style   mockup data-hero-tone   what it is
     gradient  (default)    gradient  (base)        the shipped accent gradient
     light                  light                   surface + a hairline, no colour
     soft                   tinted                  a pale wash of the accent
     solid                  brand                   filled with the accent
     plain                  --                      no panel at all; mockup lacks it

   The mockup also carries dark and graphite, which the module does not ship, so
   they are not offered. Only Atrium and Bento have a band at all. */
const HF_BANDS = [
  { id: 'gradient', t: 'Gradient', s: 'The shipped accent gradient' },
  { id: 'light', t: 'Light', s: 'Surface and a hairline, no colour' },
  { id: 'tinted', t: 'Soft', s: 'A pale wash of the accent' },
  { id: 'brand', t: 'Solid', s: 'Filled with the accent' },
];

/* The storefront pages the theme ships, under the Store tab. All seven now carry
   the portal chrome -- four of them were homepage-layout with no layout engine
   loaded at all, and were converted to match the two that already had it -- so
   every one answers the layout and tone controls. Their marketing nav is marked
   only-top, so it shows under Top Nav and gives way to the sidebar or rail.
   Labels are the ones the pages are known by rather than their headlines,
   which are marketing sentences. */
const HF_STORE = [
  { id: 'ssl', t: 'SSL Certificates', f: 'ssl-certificates.html',
    s: 'Trusted certificates by validation level, from domain validation up to extended and wildcard.' },
  { id: 'security', t: 'Website Security', f: 'website-security.html',
    s: 'SiteLock malware scanning — automatic scans and reputation protection, sold as a storefront page.' },
  { id: 'backup', t: 'Website Backup', f: 'website-backup.html',
    s: 'CodeGuard daily automated backups, against viruses, hackers and your own code breaking the site.' },
  { id: 'seo', t: 'SEO Tools', f: 'seo-tools.html',
    s: 'marketgoo SEO tools — visibility, traffic and the reporting that goes with them.' },
  { id: 'monitoring', t: '360 Monitoring', f: 'monitoring-360.html',
    s: 'Uptime and performance checks from global probes, with a free assessment on the way in.' },
  { id: 'nordvpn', t: 'NordVPN', f: 'nordvpn.html',
    s: 'Connection encryption and IP concealment, sold alongside the hosting.' },
];
/* Which list a page's design picker draws from, and what that picker is called. */
const HF_HOMEPAGES = [
  { id: 'default', t: 'Modern', f: 'homepage.html', auth: 'out',
    s: 'A marketing-led landing page: a full-width hero, the product range, pricing and the proof a stranger needs before signing up. What a visitor meets before they have an account.' },
  { id: 'portal', t: 'Classic', f: 'portal-home.html',
    s: 'The WHMCS portal home, kept: domain search across the top, the product tiles beneath it, and the client’s own navigation around it. What a signed-in client lands on.' },
];
const HF_VARIANTS = {
  dashboard: { lbl: 'Dashboard design', list: HF_DESIGNS },
  homepage: { lbl: 'Homepage Designs', list: HF_HOMEPAGES },
  login: { lbl: 'Sign-in design', list: HF_LOGINS },
  store: { lbl: 'Storefront page', list: HF_STORE },
};
const hfVariant = (set, id) => set.list.find((d) => d.id === id) || set.list[0];

/* A prompt over the band itself rather than another control on the stage.
   It waits until the frame has settled, points at the thing it is offering to
   change, and is gone the moment it is used or dismissed -- so the hero keeps
   four controls and still tells a visitor the band is a setting.
   Shown once per visit: an offer that keeps coming back is an interruption.
   1.6s, not longer: the frame settles near 1.3s, so this lands just after the
   band paints and while a visitor is still looking at it. */
/* Where the band actually is, in the parent's coordinates.
   The frame is laid out at 1440 and transform-scaled, so a rect read inside it
   has to be multiplied by that scale to mean anything out here. Measured rather
   than assumed: the band sits lower in the Top Nav layout than in the Sidebar
   one, and the scale changes with the viewport, so a fixed offset would drift
   off the band on half the combinations. Returns null while the frame is still
   booting, which keeps the prompt hidden until there is something to point at. */
function useBandAnchor(active) {
  const [pos, setPos] = React.useState(null);
  React.useEffect(() => {
    if (!active) { setPos(null); return; }
    let stop = false;
    const measure = () => {
      if (stop) return;
      const art = document.querySelector('.hf-art');
      const frame = art && art.querySelector('.hf-frame');
      if (!art || !frame) return setPos(null);
      let band = null;
      try { band = frame.contentDocument.querySelector('.dash-hero, .at-hero, .lp-hero'); } catch (e) {}
      if (!band) return setPos(null);
      const scale = frame.getBoundingClientRect().width / (frame.offsetWidth || CA_WIDTH);
      const b = band.getBoundingClientRect();
      const artW = art.getBoundingClientRect().width;
      // BELOW the band, not on it. On it, the prompt covered most of a compact
      // band -- 78px tall against a 25px cue with its inset -- and hid the very
      // thing it was offering to change. Under it, the band is always whole and
      // the prompt overlays the row of blocks beneath, which are not the subject.
      setPos({
        top: Math.max(6, b.bottom * scale + 10),
        right: Math.max(6, artW - b.right * scale),
      });
    };
    measure();
    const t = setInterval(measure, 500);      // the frame scrolls and rescales under it
    window.addEventListener('resize', measure);
    return () => { stop = true; clearInterval(t); window.removeEventListener('resize', measure); };
  }, [active]);
  return pos;
}

/* ── the block prompt ──────────────────────────────────────────────────────
   The same offer, made about a block instead of the band. It points at the
   Domains card because that card is the clearest example of the two settings
   it carries: where its title sits, and what colour it is painted.

   Both are the module's own. Titles ride v18's data-card-titles (the Atrium
   dashboard reinvented this privately -- its cards are .dash-card and match
   none of the generic data-svc-layout selectors, so the shared chip is hidden
   on this page). Colour rides data-blk-paint + data-blk-fill, the mechanism
   the shipped theme stores in the section-layout DSL, with the same paint keys
   and the same solid | tint | grad fills. */
const HF_PAINTS = [
  { id: 'accent',  t: 'Accent' },
  { id: 'quiet',   t: 'Passive' },
  { id: 'neutral', t: 'Neutral' },
  { id: 'indigo',  t: 'Indigo' },
  { id: 'green',   t: 'Green' },
  { id: 'orange',  t: 'Orange' },
  { id: 'red',     t: 'Red' },
  { id: 'teal',    t: 'Teal' },
];
const HF_FILLS = [['solid', 'Solid'], ['tint', 'Tint'], ['grad', 'Gradient']];

/* Same measuring trick as the band, pointed at the Domains card. Anchored to
   its top-right rather than below it: the card is tall and the rows under it
   are the subject, so sitting beside the head keeps both visible. */
function useBlockAnchor(active) {
  const [pos, setPos] = React.useState(null);
  React.useEffect(() => {
    if (!active) { setPos(null); return; }
    let stop = false;
    const measure = () => {
      if (stop) return;
      const art = document.querySelector('.hf-art');
      const frame = art && art.querySelector('.hf-frame');
      if (!art || !frame) return setPos(null);
      let card = null;
      try { card = frame.contentDocument.querySelector('[data-block="dom"]'); } catch (e) {}
      if (!card) return setPos(null);
      const scale = frame.getBoundingClientRect().width / (frame.offsetWidth || CA_WIDTH);
      const b = card.getBoundingClientRect();
      const artW = art.getBoundingClientRect().width;
      setPos({
        top: Math.max(6, b.top * scale + 10),
        right: Math.max(6, artW - b.right * scale + 10),
      });
    };
    measure();
    const t = setInterval(measure, 500);
    window.addEventListener('resize', measure);
    return () => { stop = true; clearInterval(t); window.removeEventListener('resize', measure); };
  }, [active]);
  return pos;
}

function HFBlockToast({ titles, onTitles, paint, fill, onPaint, onFill, open, onOpen, onClose, pos }) {
  return (
    <div className="hf-toast" style={pos ? { top: pos.top, right: pos.right } : undefined} role="region" aria-label="Block style">
      {!open ? (
        <button className="hf-toast-cue" onClick={onOpen}>
          <span className="dot" aria-hidden="true"></span>
          <span>Change this block</span>
          <span className="go" aria-hidden="true">›</span>
        </button>
      ) : (
        <div className="hf-toast-panel">
          <div className="hd">
            <b>Domains block</b>
            <button onClick={onClose} aria-label="Close">✕</button>
          </div>
          <div className="row" role="radiogroup" aria-label="Card title">
            <span>Title</span>
            <span className="seg">
              <button role="radio" aria-checked={titles === 'inside'} className={titles === 'inside' ? 'on' : ''}
                      onClick={() => onTitles('inside')}>Inside</button>
              <button role="radio" aria-checked={titles === 'outside'} className={titles === 'outside' ? 'on' : ''}
                      onClick={() => onTitles('outside')}>Outside</button>
            </span>
          </div>
          {/* No paint is a real choice, not the absence of one -- the card keeps
              the page surface, which is what every block ships as. */}
          <div className="row" role="radiogroup" aria-label="Block colour">
            <span>Colour</span>
            <span className="sw">
              <button role="radio" aria-checked={!paint} className={`none${!paint ? ' on' : ''}`}
                      title="No fill" onClick={() => onPaint(null)} />
              {HF_PAINTS.map((c) => (
                <button key={c.id} role="radio" aria-checked={paint === c.id}
                        className={`p-${c.id}${paint === c.id ? ' on' : ''}`}
                        title={c.t} onClick={() => onPaint(c.id)} />
              ))}
            </span>
          </div>
          <div className="row" role="radiogroup" aria-label="Fill">
            <span>Fill</span>
            <span className="seg">
              {HF_FILLS.map(([id, t]) => (
                <button key={id} role="radio" aria-checked={fill === id} disabled={!paint}
                        className={fill === id ? 'on' : ''}
                        title={paint ? t : 'Pick a colour first'}
                        onClick={() => onFill(id)}>{t}</button>
              ))}
            </span>
          </div>
        </div>
      )}
    </div>
  );
}

function HFBandToast({ band, onPick, onClose, open, onOpen, pos, size, onSize }) {
  return (
    <div className={`hf-toast${open ? ' open' : ''}`} style={pos ? { top: pos.top, right: pos.right } : undefined} role="region" aria-label="Welcome band style">
      {!open ? (
        <button className="hf-toast-cue" onClick={onOpen}>
          <span className="dot" aria-hidden="true"></span>
          <span>Change this band</span>
          <span className="go" aria-hidden="true">›</span>
        </button>
      ) : (
        <div className="hf-toast-panel">
          <div className="hd">
            <b>Welcome band</b>
            <button onClick={onClose} aria-label="Close">✕</button>
          </div>
          <div className="opts" role="radiogroup" aria-label="Band style">
            {HF_BANDS.map((b) => (
              <button key={b.id} role="radio" aria-checked={band === b.id}
                      className={band === b.id ? 'on' : ''} title={b.s}
                      onClick={() => onPick(b.id)}>{b.t}</button>
            ))}
          </div>
          {/* The module calls this Band height, full|slim. "Compact" is the
              clearer word for what slim does: it drops the copy line and
              tightens the padding to a one-line bar. */}
          <div className="row" role="radiogroup" aria-label="Band height">
            <span>Height</span>
            <span className="seg">
              <button role="radio" aria-checked={size === 'full'}
                      className={size === 'full' ? 'on' : ''}
                      onClick={() => onSize('full')}>Full</button>
              <button role="radio" aria-checked={size === 'slim'}
                      className={size === 'slim' ? 'on' : ''}
                      onClick={() => onSize('slim')}>Compact</button>
            </span>
          </div>
        </div>
      )}
    </div>
  );
}

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
/* What the stage is, and what it is not. The chips name the parts of the panel
   the hero has no room for; each one is a real section further down the page. */
const HF_BEYOND = ['40+ pages', '120+ tokens', 'Custom CSS', 'Menu builder', 'Homepage composer', 'Multi-language SEO'];
function HeroMore({ onDemo }) {
  return (
    <div className="hf-more">
      <p className="hf-more-line">
        Three pages, three layouts, three styles — <b>and that is what fits in a hero.</b> The
        theme has forty more pages, a token editor, and builders for menus and the homepage.{' '}
        <button type="button" className="hf-more-demo" onClick={onDemo}>
          Open the demo
          <svg viewBox="0 0 24 24" width="12" height="12" fill="none" stroke="currentColor" strokeWidth="2.2" strokeLinecap="round" strokeLinejoin="round" aria-hidden="true"><path d="M7 17L17 7M9 7h8v8" /></svg>
        </button>
      </p>
      <ul className="hf-beyond">
        {HF_BEYOND.map((t) => <li key={t}>{t}</li>)}
      </ul>
    </div>
  );
}
function HeroStage({ dark, onDemo }) {
  // off a file:// URL nothing can embed, so offer only the pages we hold a capture of
  const pages = React.useMemo(() => (CA_EMBEDDABLE ? HF_PAGES : HF_PAGES.filter((p) => hfPoster(p.id, 'side'))), []);
  const [page, setPage] = React.useState(pages[0].id);
  const [lay, setLay] = React.useState('side');
  const [tone, setTone] = React.useState('light');
  // one remembered pick per page that ships more than one design, so leaving the
  // page and coming back does not reset the choice
  const [variant, setVariant] = React.useState({ dashboard: 'atrium', homepage: 'default', login: 'split', store: 'nordvpn' });
  const [band, setBand] = React.useState('gradient');
  const [bandSize, setBandSize] = React.useState('full');
  // null = not yet offered, 'cue' = the nudge is up, 'open' = the options are,
  // 'done' = used or dismissed and not coming back this visit
  const [toast, setToast] = React.useState(null);
  // the block prompt, its own state machine on the same four values
  const [blkToast, setBlkToast] = React.useState(null);
  const [blkTitles, setBlkTitles] = React.useState('inside');
  const [blkPaint, setBlkPaint] = React.useState(null);
  const [blkFill, setBlkFill] = React.useState('solid');
  const [palette, setPalette] = React.useState('blue');
  const pg = pages.find((p) => p.id === page) || pages[0];
  const pal = HF_PALETTES.find((p) => p.id === palette) || HF_PALETTES[0];
  // the two pages that ship more than one design: the dashboard's four, the login's two
  const vset = pg.variants ? HF_VARIANTS[pg.variants] : null;
  const dsn = vset ? hfVariant(vset, variant[pg.variants]) : null;
  const src = dsn ? dsn.f : pg.src;
  // A design may bring its own shell: Split is full-bleed and suppresses the
  // portal nav, sidebar and footer, leaving the layout and tone controls with
  // nothing to act on. Disable them there rather than let them silently no-op.
  const hasShell = !dsn || dsn.shell !== false;
  // a top bar has no side menu to retone
  // Split has no sidebar but its brand panel is the page's coloured field, and it
  // takes the same four treatments, so the tone rail drives that instead. Marquee
  // tones its whole background the same way but ships no gradient, so it is left
  // out rather than offered a treatment that does nothing.
  const panelToned = !!(dsn && dsn.tones);
  const toneable = panelToned || (lay !== 'top' && hasShell);
  const toneLbl = panelToned ? 'Panel tone' : 'Sidebar tone';
  // why the layout and tone controls are off, in the words of whichever design is
  // showing: a full-bleed sign-in has no chrome at all, a storefront page has its
  // own marketing nav instead of the portal's.
  const shellWhy = !dsn ? '' : dsn.marketing
    ? `${dsn.t} is a storefront page — it carries its own marketing nav, not the portal chrome`
    : `${dsn.t} is full-bleed — it carries no portal navigation`;
  const layIds = CA_EMBEDDABLE ? HF_LAYOUTS.map((l) => l.wire) : Object.keys(HF_SHOTS[pg.id] || { side: 1 });
  const layId = layIds.indexOf(lay) === -1 ? (layIds[0] || 'top') : lay;
  const reel = useHFReel({ layIds, layId, setLay, palette, setPalette });
  // Only where there is a band to change, and only once: the timer starts on
  // mount rather than per design, so switching dashboards does not re-offer it.
  const hasBand = !!(dsn && dsn.band);
  const bandPos = useBandAnchor(hasBand && (toast === 'cue' || toast === 'open'));
  // Only Atrium carries the .dash-card family the paint CSS and data-card-titles
  // are written against, so the prompt is offered there and nowhere else.
  const hasBlocks = !!(dsn && dsn.id === 'atrium');
  // and never while the band prompt is up: two prompts over one frame is clutter
  const bandBusy = toast === 'cue' || toast === 'open';
  const blkPos = useBlockAnchor(hasBlocks && (blkToast === 'cue' || blkToast === 'open'));
  React.useEffect(() => {
    if (!hasBand || toast !== null) return;
    const t = setTimeout(() => setToast((s) => (s === null ? 'cue' : s)), 1600);
    return () => clearTimeout(t);
  }, [hasBand, toast]);
  // The block prompt waits for the band prompt to be gone, then offers itself.
  React.useEffect(() => {
    if (!hasBlocks || blkToast !== null || bandBusy) return;
    const t = setTimeout(() => setBlkToast((v) => (v === null ? 'cue' : v)), 1400);
    return () => clearTimeout(t);
  }, [hasBlocks, blkToast, bandBusy]);
  const state = React.useMemo(() => ({
    layout: layId, palette, sidebar: toneable ? tone : 'light', dark, auth: (dsn && dsn.auth) || pg.auth || 'in',
    // Fixed, not offered: the hero shows the top bar the way the demo is set
    // up, rather than making a visitor assemble it. Change these three, not a
    // control -- they are the same values the state chip writes.
    menu: 'center', toplinks: 'show', crumbs: 'none',
    subnav: pg.subnav || 'on',
    cardTitles: hasBlocks ? blkTitles : null,
    blkPaint: hasBlocks ? blkPaint : null,
    blkFill: hasBlocks && blkPaint ? blkFill : null,
    panel: panelToned ? tone : null,
    band: dsn && dsn.band ? band : null,
    bandSize: dsn && dsn.band ? bandSize : null,
  }), [layId, palette, tone, toneable, dark, pg.auth, pg.subnav, dsn, panelToned, band, bandSize, hasBlocks, blkTitles, blkPaint, blkFill]);
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
      {vset && (
        <div className="hf-designs">
          <span className="hf-lbl">{vset.lbl}</span>
          <span className="hf-seg" role="tablist" aria-label={vset.lbl}>
            {vset.list.map((d) => (
              <button key={d.id} role="tab" aria-selected={dsn.id === d.id}
                      onClick={reel.manual(() => setVariant((v) => ({ ...v, [pg.variants]: d.id })))}>{d.t}</button>
            ))}
          </span>
          <p className="hf-designnote">{dsn ? dsn.s : ''}</p>
        </div>
      )}
      <div className="hf-picker" role="tablist" aria-label="Navigation layout">
        {HF_LAYOUTS.filter((p) => layIds.indexOf(p.wire) !== -1).map((p) => (
          <button key={p.wire} role="tab" aria-selected={hasShell && layId === p.wire} disabled={!hasShell}
                  onClick={reel.manual(() => setLay(p.wire))} title={hasShell ? p.t : shellWhy}>
            <HFWire kind={p.wire} active={layId === p.wire} />
            <b>{p.t}</b><span>{p.s}</span>
          </button>
        ))}
      </div>
      <div className="hf-stage">
        <div className="hf-rail left" role="tablist" aria-label={toneLbl}>
          <span className="hf-lbl">{toneLbl}</span>
          {HF_TONES.map((x) => (
            <button key={x.id} role="tab" aria-selected={toneable && tone === x.id} disabled={!toneable} title={toneable ? x.t : (hasShell ? 'Top Nav has no side menu to retone' : shellWhy)} onClick={reel.manual(() => setTone(x.id))}>
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
            {hasBand && (toast === 'cue' || toast === 'open') && (
              <HFBandToast
                pos={bandPos}
                open={toast === 'open'}
                band={band}
                onOpen={reel.manual(() => setToast('open'))}
                onClose={() => setToast('done')}
                onPick={reel.manual((v) => setBand(v))}
                size={bandSize}
                onSize={reel.manual((v) => setBandSize(v))}
              />
            )}
            {hasBlocks && !bandBusy && (blkToast === 'cue' || blkToast === 'open') && (
              <HFBlockToast
                pos={blkPos}
                open={blkToast === 'open'}
                titles={blkTitles}
                paint={blkPaint}
                fill={blkFill}
                onOpen={reel.manual(() => setBlkToast('open'))}
                onClose={() => setBlkToast('done')}
                onTitles={reel.manual((v) => setBlkTitles(v))}
                onPaint={reel.manual((v) => setBlkPaint(v))}
                onFill={reel.manual((v) => setBlkFill(v))}
              />
            )}
          </div>
        </div>
        <div className="hf-rail right" role="tablist" aria-label="Brand colour">
          <span className="hf-lbl">Brand colour</span>
          {HF_PALETTES.map((x) => (
            <button key={x.id} role="tab" aria-selected={palette === x.id} onClick={reel.manual(() => { setPalette(x.id); applyBrandToSite(x.id); })} title={x.t}>
              <span className="pair"><i style={{ background: hfChrome(toneable ? tone : 'light', x.c, dark, x.id) }}></i><i style={{ background: x.c }}></i></span><em><b>{x.t}</b></em>
            </button>
          ))}
        </div>
      </div>
      <div className="hf-note">{CA_EMBEDDABLE ? 'The real client area, live — scroll inside the window ↓' : 'Serve this folder over http to run the client area live in the window'}</div>
      <HeroMore onDemo={onDemo} />
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
      <Safe name="HeroStage"><HeroStage dark={dark} onDemo={onDemo} /></Safe>
    </header>
  );
}

/* ── .hp-tiles-section.rich ── */
const TILES = [
  {
    k: 'Login-based layouts', h: 'Different layout\nfor guests and clients.', V: VizLogin, wide: true,
    p: 'Every layout carries its own switch for logged-out and logged-in visitors. Give guests the top nav and clients the sidebar — one URL, decided from the WHMCS session, no hooks and no second theme.',
    long: 'Every layout in Hadrian carries two independent activation states — one for guest visitors and one for signed-in clients. The same URL can therefore serve a marketing-led page to a stranger and a dense account dashboard to a customer, decided at render time from the WHMCS session.',
    long2: 'That means no duplicated pages to keep in sync, and no conditional blocks bolted into a template. A host can run a Top Nav marketing shell for acquisition and a Sidebar dashboard for retention, and change either one without touching the other.',
    steps: [['Pick a layout', 'Open Layouts and choose Top Nav, Sidebar or Icon Rail.'], ['Set the two states', 'Toggle Guest client and Existing client independently — Active or Inactive.'], ['Preview it live', 'The preview button opens the real client area, not a mockup.']],
    caption: 'Logged out gets the top nav; logged in gets the sidebar',
    points: ['Every layout has its own Active / Inactive switch per audience', 'Guests can get Top Nav while clients get the Sidebar', 'Sidebar and Icon Rail add alignment, menu side and the account block', 'No action hooks, no template forks, no duplicated pages'],
    meta: ['Layouts editor', 'Per-audience', 'Live preview'],
  },
  {
    k: 'Colour generator', h: 'Set one brand colour.\nThe rest matches it.', V: VizPalette,
    p: 'Paste your hex once. Every shade the client area needs — hovers, tints, borders, states — is computed from it, six families deep, so matching your brand stops being a job.',
    long: 'Colour in Hadrian is a ramp, not a list of values to fill in. Six families — primary, secondary, info, success, warning and danger — each carry four lighter steps and one darker, and every one of those thirty shades is derived from its family base with color-mix rather than stored. --brand-primary follows the theme accent, so setting your brand colour recomputes the whole primary ramp on the spot.',
    long2: 'That is what makes a rebrand cheap: buttons, hovers, focus rings, tinted backgrounds and borders all point at derived tokens, so they move together and stay in proportion instead of drifting apart. Any single token can still be overridden by hand when a brand guideline demands an exact value — the derivation is the default, not a cage.',
    steps: [['Set the base', 'Your brand hex on --brand-primary, in Styles → Colors.'], ['The ramp recomputes', 'Four lighter steps and one darker, live, with no rebuild.'], ['Override if you must', 'Any individual token stays editable where an exact value is required.']],
    caption: 'One base, and the thirty shades that fall out of it',
    points: ['Six families: primary, secondary, info, success, warning, danger', 'Five shades per family — four lighter, one darker — thirty in all', 'Derived with color-mix, so a base change recomputes the ramp live', 'Any single token can still be overridden by hand'],
    meta: ['Styles → Colors', '6 families', '30 derived shades'],
  },
  {
    k: 'Basic SEO', h: 'SEO title and description,\nper page and language.', V: VizSeo,
    p: 'Titles, descriptions and indexing per page — with a mass editor across all installed languages.',
    long: 'Each client-area page gets its own SEO title, meta description and indexing rule. Because WHMCS installs can run twenty or more languages, the editor also opens a mass view showing every language at once so a translator can work down the list in a single pass.',
    long2: 'Title and description carry live character counters at 64 and 160, so you can see the truncation point before publishing. Pages left empty inherit the WHMCS page title, which makes partial coverage safe.',
    steps: [['Open a page', 'Pick any client-area page in the Pages editor.'], ['Enable SEO settings', 'The title, description and indexing fields appear.'], ['Edit all languages', 'One button opens every language in a single scrollable view.']],
    caption: 'Title, description and indexing, per language',
    points: ['SEO title, meta description and Inherit / Allow / Disallow indexing per page', '“Edit all languages” view for bulk translation passes', 'Character counters at 64 and 160 as you type', 'Falls back to the WHMCS page title when left empty'],
    meta: ['Pages → SEO', 'All languages', 'Per page'],
  },
  {
    k: 'Per-page layout', h: 'Give one page\na different layout.', V: VizPageLayout,
    p: 'A page that needs different chrome says so on its own row. Override the main menu or the footer for that page; every other page carries on inheriting the site-wide setting.',
    long: 'Layouts are set site-wide, which is right until one page needs to behave differently — a checkout that should not offer the full menu, a landing page that should not carry the footer. Each page in the Pages editor holds its own layout_overrides: a main-menu choice and a footer choice, either of which can be left on the site default.',
    long2: 'An override is stored against that page alone, so the site-wide setting stays the source of truth for everything else. Change the global layout later and every inheriting page follows; the overridden ones keep the exception you set deliberately.',
    steps: [['Open the page', 'Any of the client-area pages in the Pages editor.'], ['Override what it needs', 'Main menu, footer, or both — the rest stays on the site default.'], ['Leave the rest alone', 'Pages with no override follow the site-wide layout, as before.']],
    caption: 'Two pages overriding, the rest inheriting',
    points: ['Per-page override for the main menu and for the footer', 'Stored per page — the site-wide setting stays the default', 'Pages with no override follow global changes automatically', 'Set in the Pages editor, beside that page’s SEO and options'],
    meta: ['Pages editor', 'Main menu + footer', 'Per page'],
  },
  {
    k: 'WHMCS sidebar', h: 'Turn the sidebar\non or off, per page.', V: VizSubnav,
    p: 'WHMCS drops a sidebar beside the content on page after page. Switch it off across a whole scope, list the exceptions, or let a single page answer for itself.',
    long: 'WHMCS builds a sidebar for most client-area pages — the support panel, the knowledgebase categories, the service actions — and drops it beside the content whether that page needs it or not. Hadrian makes that a setting rather than a given: the sidebar runs on two independent scopes, the order flow and the website pages, each with its own switch.',
    long2: 'Per page, three answers are possible: inherit the global, force it on, or force it off. An exception list in Settings flips the global for the pages you name, which covers the handful of pages that want the opposite of everything else. The most specific answer wins, so a page can always overrule both.',
    steps: [['Set the global', 'One switch per scope — the order flow, the website pages.'], ['Name the exceptions', 'A page picker in Settings flips the global for the pages you list.'], ['Or answer on the page', 'The page’s own field — inherit, on, off — beats both.']],
    caption: 'Sidebar on globally, and one page saying otherwise',
    points: ['Two scopes: the order flow and the website pages, each with its own switch', 'Per-page field: inherit, force on, or force off', 'Exception list in Settings flips the global for named pages', 'Most specific wins: page field > exception list > global'],
    meta: ['Settings → Sidebar', '2 scopes', 'Per-page override'],
  },
  {
    k: 'Languages', h: 'Choose which languages\nclients can pick.', V: VizLanguages,
    p: 'WHMCS installs its whole language set whether you use it or not. Switch on the ones you want and the client-area switcher offers only those.',
    long: 'A WHMCS install carries more than twenty languages out of the box, and the client area offers every one of them in its switcher — including the dozen you have never translated a product description into. This is a shortlist: each installed language gets a row, and only the ones switched on reach the front end.',
    long2: 'One of them is the default, which is what a guest sees before they choose anything and what the switcher falls back to. Switching a language off hides it from the switcher; it does not touch the WHMCS files, so nothing is lost and turning it back on restores it exactly.',
    steps: [['See what is installed', 'Every language in the WHMCS lang folder, listed as it comes.'], ['Switch off the ones you do not sell in', 'They disappear from the client-area switcher.'], ['Set the default', 'What a guest lands on, and what the switcher falls back to.']],
    caption: 'Enabled languages, and the switcher they produce',
    points: ['Every installed WHMCS language, enabled or disabled per language', 'One default — what a guest sees before choosing', 'The client-area switcher lists only the enabled ones', 'Nothing is deleted: switching a language back on restores it'],
    meta: ['Settings → Languages', 'Per language', 'Default language'],
  },
  {
    k: 'Font manager', h: 'Change the font,\nor add your own.', V: VizFonts, wide: true,
    p: 'Four sources, one radio group: the bundled default, the visitor’s own system font, a Google font, or a font file of yours. Whichever you pick, the size scale underneath does not move.',
    long: 'The family comes from one of four places. Default uses the bundled stack — San Francisco on Apple, Inter elsewhere. System fonts hands the page to whatever the visitor’s OS ships, so nothing downloads at all. Google Font picks from the curated list and writes the stack for you. Self-hosted takes a face name and a font file you drop into /assets/fonts/custom — your licensed brand face, served from your own server.',
    long2: 'Each mode carries the exact stack string it will write, so you can see what lands in the CSS rather than trusting it. The self-hosted mode can also keep San Francisco on Apple devices and use your face everywhere else, which is how most brand guidelines actually read once you get to the small print.',
    steps: [['Pick the source', 'Default, system fonts, a Google font, or your own file.'], ['Name it', 'The Google family from the list, or the face name for a self-hosted file.'], ['Check the stack', 'Each mode shows the font-family declaration it writes.']],
    caption: 'Four sources for one family',
    points: ['Default: the bundled stack — San Francisco on Apple, Inter elsewhere', 'System fonts: the visitor’s own OS face, nothing downloaded', 'Google Font: chosen from the curated list, stack written for you', 'Self-hosted: your own file in /assets/fonts/custom, optionally Apple-exempt'],
    meta: ['Styles → Typography', '4 sources', 'Self-hosted fonts'],
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
          <h2 className="hp-h2">Seven levers, shipped in the theme.</h2>
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
const ADMIN_BASE = (CA_PATHS.admin || '../Hadrian by Caesarthemes/hadrian-admin-panel/');
const ADMIN_WIDTH = 760;   // the item list alone, so nearer life size than the full panel
function AdminSpot({ view, dark, label }) {
  const state = React.useMemo(() => ({ admin: true, dark }), [dark]);
  return (
    <div className="sp-adminframe">
      <ThemeFrame
        page={`${ADMIN_BASE}?embed=1#${view}`}
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
  { id: 'menu', side: 'right', k: 'Menu manager', h: 'Three menus.\nEvery item, yours.', C: MenuSpotSimple,
    p: 'Main, Secondary and Footer menus, each with its own tree. Drag items into order, nest them as deep as you need, and give every one its own type, icon and audience.',
    li: ['Nested items with drag-and-drop ordering', 'Per-item visibility by layout and login state', 'Language variables or a custom string, per item'] },
  { id: 'composer', side: 'left', wide: true, k: 'Homepage composer', h: 'Compose the page\nthey land on.', C: ComposerSpot,
    p: 'Pick the cards that appear on the client homepage, drag them into order, size each one from a full row down to a third, and give it a fill and a colour. The preview is the page.',
    li: ['Nine cards to reorder, plus the band and the figures', 'Four widths — 1/1 · 2/3 · 1/2 · 1/3 — set per card', 'A fill and a colour per card, and any card switched off'] },
];
function Spotlights({ dark }) {
  return (
    <>
      {SPOTS.map((s) => {
        const link = <a href="#demo" className="more">See it in the demo<span aria-hidden="true">›</span></a>;
        const copy = (
          <Up className="copy">
            <div className="hp-eyebrow">{s.k}</div>
            <h2 style={{ whiteSpace: 'pre-line' }}>{s.h}</h2>
            <p>{s.p}</p>
            <ul>{s.li.map((t) => <li key={t}>{t}</li>)}</ul>
            {/* centred copy needs the rule above the link to span the column, and
                a border on the inline link would only span the words */}
            {s.wide ? <div className="cta">{link}</div> : link}
          </Up>
        );
        const vis = <Up className="vis"><Safe name={s.k}><s.C dark={dark} /></Safe></Up>;
        return (
          <section key={s.id} id={s.id} className="hp-spot" data-side={s.side} data-wide={s.wide ? '' : undefined} data-screen-label={s.k}>
            <div className="hp-wrap">
              {s.wide ? <>{copy}{vis}</> : <div className="grid">{copy}{vis}</div>}
            </div>
          </section>
        );
      })}
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
              <img className="hp-brand-logo" src={CA_BASE + 'img/branding/hadrian-logo.png'} alt="Hadrian" />
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
