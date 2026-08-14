// hadrian-lp5-demos.jsx — "Live Demos" slide-over: pick a layout + a style, open a preview
const DEMO_LAYOUTS = [
  { id: 'top', n: 'Top Nav', d: 'Horizontal bar · centred content' },
  { id: 'side', n: 'Sidebar', d: 'Left rail · left or centred' },
  { id: 'rail', n: 'Icon Rail', d: 'Compact icons · widest content' },
];
/* The six styles the module actually ships — names and accents straight out of
   core/config/colors.php. A style is a palette here; corner radius, shadow and
   button shape are theme-global panels, not part of a preset. Dark is a mode
   that runs across all six, so it is a switch rather than a seventh card. */
const DEMO_STYLES = [
  { id: 'blue', n: 'Default', d: 'The stock blue', c: '#0071e3', badge: 'Shipped default' },
  { id: 'emerald', n: 'Emerald', d: 'Green, low chroma', c: '#14b17d', badge: null },
  { id: 'violet', n: 'Violet', d: 'Cool, high chroma', c: '#8c5cff', badge: null },
  { id: 'rose', n: 'Rose', d: 'Warm and loud', c: '#ff2d6b', badge: null },
  { id: 'amber', n: 'Amber', d: 'Warm and quiet', c: '#f08a00', badge: null },
  { id: 'slate', n: 'Slate', d: 'Neutral, near-monochrome', c: '#64748b', badge: null },
];
/* Every preview opens the real client area from ../apple-client-area.
   The params steer it, and the same values are written into the theme's own
   boot keys first, because a static host that rewrites /x.html to /x drops the
   query string on the redirect and the page would otherwise open at defaults. */
const DEMO_BASE = '../apple-client-area/clientareahome.html';
// preview=off, not preview=1 — apple-layout.js only accepts 0|off|false|hide|none,
// and anything else leaves the dev state chip sitting on top of the demo
const demoHref = (s, layout, theme) => `${DEMO_BASE}?layout=${layout}&palette=${s.id}&preview=off&theme=${theme}`;
function demoHandoff(s, layout, theme) {
  try {
    localStorage.setItem('hn.layout', layout);
    localStorage.setItem('hn.palette', s.id);
    localStorage.setItem('apple-theme', theme);
  } catch (e) {}
}

/* Layout wireframe thumbnail (the "Choose Layout" row) */
function DemoWire({ kind, on }) {
  const b = on ? 'var(--color-accent)' : 'color-mix(in srgb,var(--color-accent) 34%,transparent)';
  const box = (w, h, o = 1) => <span style={{ display: 'block', width: w, height: h, borderRadius: 2, background: b, opacity: o }}></span>;
  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: 4, width: '100%', height: '100%', padding: 8, boxSizing: 'border-box' }}>
      {kind === 'top' && (
        <>
          <div style={{ display: 'flex', gap: 4, alignItems: 'center' }}>{box(22, 5)}{box(14, 4, .6)}{box(14, 4, .6)}{box(14, 4, .6)}<span style={{ flex: 1 }}></span>{box(12, 4, .4)}</div>
          <div style={{ display: 'flex', gap: 4, marginTop: 4 }}>{[0, 1, 2, 3].map(k => <span key={k} style={{ flex: 1, height: 13, borderRadius: 2, background: b, opacity: .3 }}></span>)}</div>
          <div style={{ display: 'flex', gap: 4, flex: 1 }}><span style={{ flex: 2, borderRadius: 2, background: b, opacity: .22 }}></span><span style={{ flex: 1, borderRadius: 2, background: b, opacity: .22 }}></span></div>
        </>
      )}
      {kind !== 'top' && (
        <div style={{ display: 'flex', gap: 5, flex: 1 }}>
          <div style={{ width: kind === 'side' ? 26 : 11, display: 'flex', flexDirection: 'column', gap: 3 }}>
            {[.95, .5, .5, .5, .5].map((o, k) => <span key={k} style={{ height: kind === 'side' ? 4 : 8, borderRadius: 2, background: b, opacity: o }}></span>)}
          </div>
          <div style={{ flex: 1, display: 'flex', flexDirection: 'column', gap: 4 }}>
            <div style={{ display: 'flex', gap: 4, alignItems: 'center' }}>{box(20, 4)}<span style={{ flex: 1 }}></span>{box(10, 4, .4)}</div>
            <div style={{ display: 'flex', gap: 4 }}>{[0, 1, 2, 3].map(k => <span key={k} style={{ flex: 1, height: 13, borderRadius: 2, background: b, opacity: .3 }}></span>)}</div>
            <div style={{ display: 'flex', gap: 4, flex: 1 }}><span style={{ flex: 2, borderRadius: 2, background: b, opacity: .22 }}></span><span style={{ flex: 1, borderRadius: 2, background: b, opacity: .22 }}></span></div>
          </div>
        </div>
      )}
    </div>
  );
}

/* Mini client-area mock used in the "Choose Style" cards. Surfaces and text
   take the real tokens out of core/config/colors.php; the accent is the style's
   own. Radius and shadow are theme-global panels, so they do not vary by style. */
function DemoMock({ layout, style, dark }) {
  const acc = style.c;
  const bg = dark ? '#1c1c1e' : '#fbfbfd';
  const surf = dark ? '#2c2c2e' : '#ffffff';
  const line = dark ? '#3a3a3c' : '#e8e8ed';
  const ink = dark ? '#f5f5f7' : '#1d1d1f';
  const ink3 = dark ? '#8e8e93' : '#86868b';
  const card = { background: surf, border: `1px solid ${line}`, borderRadius: 7, boxShadow: dark ? 'none' : '0 3px 8px -4px rgba(0,0,0,.25)' };
  const stats = [['12', 'Services'], ['3', 'Domains'], ['$72', 'Due'], ['2', 'Tickets']];
  const navItems = ['Services', 'Domains', 'Billing', 'Support'];
  return (
    <div style={{ background: bg, height: 190, display: 'flex', flexDirection: layout === 'top' ? 'column' : 'row', overflow: 'hidden', fontFamily: 'var(--font)' }}>
      {layout === 'top' && (
        <div style={{ background: acc, display: 'flex', alignItems: 'center', gap: 8, padding: '7px 10px', flexShrink: 0 }}>
          <span style={{ width: 8, height: 8, borderRadius: 2, background: '#fff' }}></span>
          <span style={{ fontSize: 6.5, fontWeight: 800, color: '#fff' }}>hadrian</span>
          {navItems.map((n) => <span key={n} style={{ fontSize: 5.5, fontWeight: 600, color: 'rgba(255,255,255,.85)' }}>{n}</span>)}
          <span style={{ flex: 1 }}></span>
          <span style={{ width: 9, height: 9, borderRadius: '50%', background: 'rgba(255,255,255,.4)' }}></span>
        </div>
      )}
      {layout !== 'top' && (
        <div style={{ width: layout === 'side' ? 46 : 20, background: acc, padding: layout === 'side' ? '8px 6px' : '8px 0', display: 'flex', flexDirection: 'column', gap: 6, alignItems: layout === 'rail' ? 'center' : 'stretch', flexShrink: 0 }}>
          <span style={{ width: 9, height: 9, borderRadius: 2, background: '#fff', alignSelf: layout === 'rail' ? 'center' : 'flex-start', marginBottom: 2 }}></span>
          {layout === 'side'
            ? navItems.map((n, k) => <span key={n} style={{ fontSize: 5, fontWeight: k ? 500 : 700, color: `rgba(255,255,255,${k ? .7 : 1})` }}>{n}</span>)
            : [0, 1, 2, 3].map((k) => <span key={k} style={{ width: 9, height: 9, borderRadius: 2, background: `rgba(255,255,255,${k ? .45 : .95})` }}></span>)}
        </div>
      )}
      <div style={{ flex: 1, minWidth: 0, padding: 9, display: 'flex', flexDirection: 'column', gap: 5 }}>
        <div>
          <div style={{ fontSize: 4.5, fontWeight: 700, letterSpacing: '.1em', textTransform: 'uppercase', color: ink3 }}>Tuesday · 2 June</div>
          <div style={{ fontSize: 9, fontWeight: 700, letterSpacing: '-.02em', color: ink, marginTop: 1.5 }}>Good evening, Marcus</div>
        </div>
        <div style={{ display: 'flex', gap: 4 }}>
          {stats.map(([v, l]) => (
            <div key={l} style={{ ...card, flex: 1, padding: '5px 6px' }}>
              <div style={{ fontSize: 9, fontWeight: 700, letterSpacing: '-.03em', color: acc, lineHeight: 1 }}>{v}</div>
              <div style={{ fontSize: 4, color: ink3, marginTop: 2, textTransform: 'uppercase', letterSpacing: '.08em', fontWeight: 700 }}>{l}</div>
            </div>
          ))}
        </div>
        <div style={{ display: 'flex', gap: 4, flex: 1, minHeight: 0 }}>
          <div style={{ ...card, flex: 2, padding: 6, display: 'flex', flexDirection: 'column', gap: 3 }}>
            <div style={{ fontSize: 5, fontWeight: 700, color: ink }}>Services</div>
            {['Cloud VPS — Pro', 'Business Hosting', 'SSL — Wildcard'].map((n, k) => (
              <div key={n} style={{ display: 'flex', alignItems: 'center', gap: 4, borderTop: k ? `1px solid ${line}` : 'none', paddingTop: k ? 3 : 0 }}>
                <span style={{ flex: 1, fontSize: 4.5, color: ink, fontWeight: 600 }}>{n}</span>
                <span style={{ width: 4, height: 4, borderRadius: '50%', background: k === 2 ? '#ff9f0a' : '#30d158' }}></span>
              </div>
            ))}
          </div>
          <div style={{ ...card, flex: 1, padding: 6, display: 'flex', flexDirection: 'column', gap: 3 }}>
            <div style={{ fontSize: 5, fontWeight: 700, color: ink }}>Invoices</div>
            {['#1048', '#1042'].map((n, k) => (
              <div key={n} style={{ display: 'flex', justifyContent: 'space-between', gap: 3, borderTop: k ? `1px solid ${line}` : 'none', paddingTop: k ? 3 : 0 }}>
                <span style={{ fontSize: 4.5, color: ink, fontWeight: 600 }}>{n}</span>
                <span style={{ fontSize: 4.5, color: ink3 }}>{k ? '$48' : '$72'}</span>
              </div>
            ))}
            <span style={{ marginTop: 'auto', textAlign: 'center', fontSize: 4.5, fontWeight: 700, padding: '3px 0', borderRadius: 999, background: acc, color: '#fff' }}>Pay now</span>
          </div>
        </div>
      </div>
    </div>
  );
}

function DemoDrawer({ open, onClose }) {
  const [layout, setLayout] = React.useState('side');
  const [mode, setMode] = React.useState('light');
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
    <div className="hp-drawer-scrim" onClick={onClose} role="presentation">
      <aside className="hp-drawer" role="dialog" aria-modal="true" aria-label="Live Demos" onClick={(e) => e.stopPropagation()}>
        <div className="hp-drawer-head">
          <h2>Live Demos</h2>
          <button className="hp-drawer-x" onClick={onClose} aria-label="Close">✕</button>
        </div>
        <div className="hp-drawer-body">
          <h3 className="hp-drawer-h">Choose Layout</h3>
          <p className="hp-drawer-sub">The navigation the demo loads with. Each layout can be assigned per audience in admin.</p>
          <div className="hp-wire-row">
            {DEMO_LAYOUTS.map((l) => (
              <button key={l.id} className="hp-wire" aria-pressed={layout === l.id} onClick={() => setLayout(l.id)} title={l.d}>
                <span className="hp-wire-art"><DemoWire kind={l.id} on={layout === l.id} /></span>
                <span className="hp-wire-n">{l.n}</span>
                <span className="hp-wire-d">{l.d}</span>
              </button>
            ))}
          </div>

          <h3 className="hp-drawer-h" style={{ marginTop: 38 }}>Choose Style</h3>
          <p className="hp-drawer-sub">
            Six shipped styles. A style is the palette — the navigation treatment and the
            component shapes are their own settings. Each preview opens in the{' '}
            <b>{DEMO_LAYOUTS.find((l) => l.id === layout).n}</b> layout you picked.
          </p>
          <div className="hp-drawer-modes" role="group" aria-label="Colour mode">
            {[['light', 'Light'], ['dark', 'Dark']].map(([id, n]) => (
              <button key={id} aria-pressed={mode === id} onClick={() => setMode(id)}>{n}</button>
            ))}
          </div>
          <div className="hp-style-grid">
            {DEMO_STYLES.map((s) => (
              <article key={s.id} className="hp-style-card">
                {s.badge && <span className="hp-style-badge">{s.badge}</span>}
                <div className="hp-style-shot"><DemoMock layout={layout} style={s} dark={mode === 'dark'} /></div>
                <div className="hp-style-foot">
                  <div>
                    <div className="n">{s.n}</div>
                    <div className="d">{s.d}</div>
                  </div>
                  <a className="hp-style-btn" href={demoHref(s, layout, mode)} onClick={() => demoHandoff(s, layout, mode)}>Live Preview</a>
                </div>
              </article>
            ))}
          </div>
          <div className="hp-drawer-note">Demos run on sample data. Admin-side settings, styles and menus are shown in the <a href="../Hadrian by Caesarthemes/hadrian-admin-panel/index.html">Hadrian admin panel</a>.</div>
        </div>
      </aside>
    </div>
  );
}
Object.assign(window, { DemoDrawer, DemoWire, DemoMock, DEMO_LAYOUTS, DEMO_STYLES });
