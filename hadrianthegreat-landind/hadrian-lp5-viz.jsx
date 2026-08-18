// hadrian-lp5-viz.jsx — small UI visuals used inside the V2 blocks
const V = {
  bar: (w, o = .16, h = 6) => <span style={{ display: 'block', width: w, height: h, borderRadius: h / 2, background: 'var(--color-text-primary)', opacity: o }}></span>,
};
function Chrome({ label, children, pad = 12 }) {
  return (
    <div style={{ background: 'var(--color-surface-secondary)', border: '1px solid var(--color-border)', borderRadius: '12px 12px 0 0', overflow: 'hidden', borderBottom: 'none' }}>
      <div style={{ display: 'flex', gap: 4, alignItems: 'center', padding: '8px 12px', borderBottom: '1px solid var(--color-border)' }}>
        <i style={{ width: 7, height: 7, borderRadius: '50%', background: 'var(--color-border)' }}></i>
        <i style={{ width: 7, height: 7, borderRadius: '50%', background: 'var(--color-border)' }}></i>
        <i style={{ width: 7, height: 7, borderRadius: '50%', background: 'var(--color-border)' }}></i>
        {label && <span style={{ marginLeft: 8, fontSize: 9.5, color: 'var(--color-text-quaternary)' }}>{label}</span>}
      </div>
      <div style={{ padding: pad, background: 'var(--color-bg)' }}>{children}</div>
    </div>
  );
}
// Login-based layouts: guest vs client
function VizLogin() {
  // The point is the NAVIGATION, not the content: the same URL renders a top bar
  // for a stranger and a sidebar for a customer, so draw the chrome, not filler.
  const acc = 'var(--color-accent)';
  const bar = (w, o) => <span style={{ display: 'block', width: w, height: 5, borderRadius: 3, background: 'var(--color-text-primary)', opacity: o }}></span>;
  const side = (who, state, layout, tint) => (
    <div style={{ border: '1px solid var(--color-border)', borderRadius: 10, overflow: 'hidden', background: 'var(--color-surface)' }}>
      <div style={{ display: 'flex', alignItems: 'center', gap: 6, padding: '6px 9px', borderBottom: '1px solid var(--color-border)', background: 'var(--color-surface-secondary)' }}>
        <span style={{ width: 6, height: 6, borderRadius: '50%', background: tint }}></span>
        <span style={{ fontSize: 8, fontWeight: 800, letterSpacing: '.09em', textTransform: 'uppercase', color: 'var(--color-text-secondary)' }}>{state}</span>
        <span style={{ marginLeft: 'auto', fontSize: 8, fontWeight: 800, letterSpacing: '.05em', color: tint }}>{layout}</span>
      </div>
      {who === 'guest' ? (
        <div>
          {/* top nav: the whole navigation sits in one bar across the top */}
          <div style={{ background: acc, display: 'flex', alignItems: 'center', gap: 5, padding: '6px 9px' }}>
            <span style={{ width: 22, height: 5, borderRadius: 3, background: 'rgba(255,255,255,.95)' }}></span>
            {[0, 1, 2].map((k) => <span key={k} style={{ width: 15, height: 4, borderRadius: 2, background: 'rgba(255,255,255,.55)' }}></span>)}
            <span style={{ marginLeft: 'auto', width: 24, height: 9, borderRadius: 999, background: 'rgba(255,255,255,.95)' }}></span>
          </div>
          <div style={{ padding: 10, display: 'grid', gap: 5, justifyItems: 'center', minHeight: 74 }}>
            {bar('68%', .8)}{bar('84%', .16)}{bar('52%', .16)}
            <span style={{ marginTop: 3, width: 54, height: 13, borderRadius: 999, background: acc }}></span>
          </div>
        </div>
      ) : (
        <div style={{ display: 'grid', gridTemplateColumns: '34px 1fr', minHeight: 96 }}>
          {/* sidebar: the navigation moves down the left edge */}
          <div style={{ background: acc, padding: '8px 6px', display: 'grid', gap: 5, alignContent: 'start' }}>
            <span style={{ height: 5, borderRadius: 3, background: 'rgba(255,255,255,.95)' }}></span>
            {[0, 1, 2, 3].map((k) => <span key={k} style={{ height: 4, borderRadius: 2, background: 'rgba(255,255,255,.5)' }}></span>)}
          </div>
          <div style={{ padding: 9, display: 'grid', gap: 5 }}>
            <div style={{ display: 'flex', gap: 4 }}>
              {[0, 1, 2].map((k) => <div key={k} style={{ flex: 1, height: 20, borderRadius: 5, background: 'var(--color-surface-secondary)', border: '1px solid var(--color-border)' }}></div>)}
            </div>
            <div style={{ height: 30, borderRadius: 5, background: 'var(--color-surface-secondary)', border: '1px solid var(--color-border)' }}></div>
            {bar('62%', .14)}
          </div>
        </div>
      )}
    </div>
  );
  return (
    <Chrome label="one URL · the session picks the layout">
      <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 8 }}>
        {side('guest', 'Logged out', 'Top Nav', 'var(--color-accent)')}
        {side('client', 'Logged in', 'Sidebar', '#30d158')}
      </div>
    </Chrome>
  );
}
// Homepage block composer
function VizBlocks() {
  const [order, setOrder] = React.useState([0, 1, 2, 3]);
  const spans = ['1 / 1', '1 / 2', '1 / 2', '1 / 3'];
  React.useEffect(() => {
    const t = setInterval(() => setOrder((o) => [o[1], o[2], o[0], o[3]]), 2200);
    return () => clearInterval(t);
  }, []);
  const names = ['Services', 'Domains', 'Invoices', 'Tickets'];
  return (
    <Chrome label="drag · size · toggle">
      <div style={{ display: 'grid', gap: 6 }}>
        {order.map((i, pos) => (
          <div key={i} style={{ display: 'flex', alignItems: 'center', gap: 8, background: 'var(--color-surface)', border: '1px solid var(--color-border)', borderRadius: 7, padding: '8px 10px', transition: 'transform .5s var(--ease)' }}>
            <span style={{ display: 'grid', gap: 2 }}>{[0, 1, 2].map(k => <span key={k} style={{ width: 9, height: 1.5, background: 'var(--color-text-quaternary)', borderRadius: 1 }}></span>)}</span>
            <span style={{ flex: 1, fontSize: 10.5, fontWeight: 650, color: 'var(--color-text-primary)' }}>{names[i]}</span>
            <span style={{ fontSize: 8.5, fontWeight: 800, color: 'var(--color-accent)', background: 'var(--color-accent-light)', padding: '2px 6px', borderRadius: 4 }}>{spans[pos]}</span>
            <span style={{ width: 22, height: 12, borderRadius: 999, background: pos < 3 ? 'var(--color-accent)' : 'var(--color-border)', position: 'relative' }}><span style={{ position: 'absolute', top: 1.5, left: pos < 3 ? 11.5 : 1.5, width: 9, height: 9, borderRadius: '50%', background: '#fff', transition: 'left .3s' }}></span></span>
          </div>
        ))}
      </div>
    </Chrome>
  );
}
// SEO multi-language
function VizSeo() {
  const langs = ['English', 'Deutsch', 'Français', 'Español'];
  const [i, setI] = React.useState(0);
  React.useEffect(() => { const t = setInterval(() => setI((v) => (v + 1) % langs.length), 1800); return () => clearInterval(t); }, []);
  return (
    <Chrome label="edit all languages">
      <div style={{ display: 'flex', gap: 4, marginBottom: 8, flexWrap: 'wrap' }}>
        {langs.map((l, k) => <span key={l} style={{ fontSize: 8.5, fontWeight: 700, padding: '3px 8px', borderRadius: 999, background: k === i ? 'var(--color-accent)' : 'var(--color-surface)', color: k === i ? '#fff' : 'var(--color-text-tertiary)', border: '1px solid var(--color-border)', transition: 'all .3s' }}>{l}</span>)}
      </div>
      {/* the real editor: title and description per language, with the counters
          it actually ships (64 and 160) and the three indexing states */}
      <div style={{ background: 'var(--color-surface)', border: '1px solid var(--color-border)', borderRadius: 8, padding: 10, display: 'grid', gap: 7 }}>
        {[['SEO title', 'Cloud VPS Hosting — ' + langs[i], 64], ['Meta description', 'Deploy in 60 seconds on NVMe hardware.', 160]].map(([l, v, max]) => (
          <div key={l}>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'baseline' }}>
              <span style={{ fontSize: 8, fontWeight: 800, letterSpacing: '.08em', textTransform: 'uppercase', color: 'var(--color-text-tertiary)' }}>{l}</span>
              <span style={{ fontSize: 8, fontVariantNumeric: 'tabular-nums', color: String(v).length > max ? '#ff9f0a' : 'var(--color-text-quaternary)' }}>{String(v).length}/{max}</span>
            </div>
            <div style={{ marginTop: 3, fontSize: 10, color: 'var(--color-text-primary)', background: 'var(--color-surface-secondary)', border: '1px solid var(--color-border)', borderRadius: 6, padding: '5px 7px', whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis' }}>{v}</div>
          </div>
        ))}
        <div style={{ display: 'flex', gap: 4 }}>
          {['Inherit', 'Allow', 'Disallow'].map((n, k) => (
            <span key={n} style={{ fontSize: 8, fontWeight: 700, padding: '3px 8px', borderRadius: 999, background: k === 1 ? 'var(--color-accent)' : 'var(--color-surface-secondary)', color: k === 1 ? '#fff' : 'var(--color-text-tertiary)', border: '1px solid var(--color-border)' }}>{n}</span>
          ))}
        </div>
      </div>
    </Chrome>
  );
}
// Styles — the six shipped palettes, at their real accents. A style changes the
// colour and nothing else here, so the shapes deliberately hold still.
const VIZ_STYLES = [
  ['Default', '#0071e3'], ['Emerald', '#14b17d'], ['Violet', '#8c5cff'],
  ['Rose', '#ff2d6b'], ['Amber', '#f08a00'], ['Slate', '#64748b'],
];
function VizStyles() {
  const [i, setI] = React.useState(0);
  React.useEffect(() => { const t = setInterval(() => setI((v) => (v + 1) % VIZ_STYLES.length), 1700); return () => clearInterval(t); }, []);
  const acc = VIZ_STYLES[i][1];
  return (
    <Chrome label={VIZ_STYLES[i][0]}>
      <div style={{ display: 'grid', gap: 6 }}>
        {[0, 1].map((k) => (
          <div key={k} style={{ background: 'var(--color-surface)', border: '1px solid var(--color-border)', borderRadius: 12, boxShadow: '0 8px 20px -10px rgba(0,0,0,.2)', padding: 10, transition: 'all .5s var(--ease)', display: 'flex', alignItems: 'center', gap: 8 }}>
            <span style={{ width: 24, height: 24, borderRadius: 7, background: acc, transition: 'background .5s var(--ease)' }}></span>
            <span style={{ flex: 1, display: 'grid', gap: 4 }}>{V.bar('60%', .45, 5)}{V.bar('85%', .12, 4)}</span>
            <span style={{ padding: '4px 12px', borderRadius: 999, fontSize: 8.5, fontWeight: 700, background: acc, color: '#fff', transition: 'background .5s var(--ease)' }}>Manage</span>
          </div>
        ))}
      </div>
    </Chrome>
  );
}
// Font manager — the four sources the theme will take a family from
function VizFonts() {
  const MODES = [
    ['Default', 'San Francisco on Apple, bundled Inter elsewhere', 'var(--font)'],
    ['System fonts', "system-ui, -apple-system, 'Segoe UI', Roboto, sans-serif", 'system-ui,sans-serif'],
    ['Google Font', "'Roboto', system-ui, sans-serif", 'Georgia,serif'],
    ['Self-hosted', "'BrandSans' — drop the file into /assets/fonts/custom", 'ui-monospace,Menlo,monospace'],
  ];
  const [i, setI] = React.useState(0);
  React.useEffect(() => { const t = setInterval(() => setI((v) => (v + 1) % MODES.length), 2200); return () => clearInterval(t); }, []);
  return (
    <Chrome label="Styles → Typography · font family">
      <div style={{ display: 'grid', gap: 4 }}>
        {MODES.map(([name, detail], k) => {
          const on = k === i;
          return (
            <div key={name} style={{
              borderRadius: 8, border: '1px solid ' + (on ? 'color-mix(in srgb, var(--color-accent) 45%, transparent)' : 'var(--color-border)'),
              background: on ? 'var(--color-accent-light)' : 'var(--color-surface)',
              padding: '6px 9px', transition: 'background .3s ease, border-color .3s ease',
            }}>
              <div style={{ display: 'flex', alignItems: 'center', gap: 7 }}>
                <span style={{
                  width: 10, height: 10, borderRadius: '50%', flexShrink: 0,
                  border: '1.5px solid ' + (on ? 'var(--color-accent)' : 'var(--color-border)'),
                  background: on ? 'var(--color-accent)' : 'transparent',
                  boxShadow: on ? 'inset 0 0 0 1.5px var(--color-surface)' : 'none', transition: 'all .3s ease',
                }}></span>
                <span style={{ fontSize: 10.5, fontWeight: 650, color: 'var(--color-text-primary)' }}>{name}</span>
              </div>
              {/* the field that mode fills in */}
              {on && (
                <div style={{
                  marginTop: 5, marginLeft: 17, padding: '4px 7px', borderRadius: 6,
                  background: 'var(--color-surface)', border: '1px solid var(--color-border)',
                  fontSize: 8.5, fontFamily: 'ui-monospace,Menlo,monospace', color: 'var(--color-text-tertiary)',
                  whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis',
                }}>{detail}</div>
              )}
            </div>
          );
        })}
      </div>
      {/* and what the client area is set in as a result */}
      <div style={{ marginTop: 10, paddingTop: 9, borderTop: '1px solid var(--color-border)' }}>
        <div style={{ fontFamily: MODES[i][2], fontSize: 15, fontWeight: 700, letterSpacing: '-.02em', color: 'var(--color-text-primary)', transition: 'font-family .2s' }}>Good evening, Marcus</div>
        <div style={{ fontFamily: MODES[i][2], fontSize: 9.5, color: 'var(--color-text-tertiary)', marginTop: 3 }}>Three services renew this month.</div>
      </div>
    </Chrome>
  );
}

// Per-page layout override — a page can refuse the site-wide main menu or footer
function VizPageLayout() {
  const ROWS = [
    ['Dashboard', 'Site default', false],
    ['Shopping cart', 'Minimal menu', true],
    ['Checkout', 'No footer', true],
    ['Knowledgebase', 'Site default', false],
  ];
  return (
    <Chrome label="Pages → layout override">
      <div style={{ display: 'grid', gap: 4 }}>
        {ROWS.map(([page, val, over]) => (
          <div key={page} style={{
            display: 'flex', alignItems: 'center', gap: 8, padding: '7px 9px', borderRadius: 8,
            background: 'var(--color-surface)',
            border: '1px solid ' + (over ? 'color-mix(in srgb, var(--color-accent) 45%, transparent)' : 'var(--color-border)'),
          }}>
            <span style={{ flex: 1, fontSize: 10.5, fontWeight: 600, color: 'var(--color-text-primary)' }}>{page}</span>
            <span style={{
              fontSize: 8.5, fontWeight: 700, padding: '3px 8px', borderRadius: 999,
              background: over ? 'var(--color-accent)' : 'var(--color-surface-secondary)',
              color: over ? '#fff' : 'var(--color-text-tertiary)',
              border: '1px solid ' + (over ? 'var(--color-accent)' : 'var(--color-border)'),
            }}>{val}</span>
          </div>
        ))}
      </div>
      <div style={{ marginTop: 9, fontSize: 8.5, fontWeight: 650, color: 'var(--color-text-quaternary)' }}>
        Two rows overriding · the rest inherit
      </div>
    </Chrome>
  );
}

// The WHMCS sidebar — the panel WHMCS drops beside the content, on or off per page
function VizSubnav() {
  const [on, setOn] = React.useState(true);
  React.useEffect(() => { const t = setInterval(() => setOn((v) => !v), 2000); return () => clearInterval(t); }, []);
  return (
    <Chrome label={on ? 'Sidebar on' : 'Sidebar off — this page only'}>
      <div style={{ display: 'grid', gridTemplateColumns: on ? '86px 1fr' : '0px 1fr', gap: on ? 8 : 0, transition: 'grid-template-columns .4s ease, gap .4s ease' }}>
        {/* what WHMCS populates: a titled panel with its own links */}
        <div style={{ overflow: 'hidden', opacity: on ? 1 : 0, transition: 'opacity .3s ease' }}>
          <div style={{ border: '1px solid var(--color-border)', borderRadius: 8, background: 'var(--color-surface)', overflow: 'hidden' }}>
            <div style={{ fontSize: 7.5, fontWeight: 800, letterSpacing: '.08em', textTransform: 'uppercase', color: 'var(--color-text-tertiary)', padding: '6px 8px', borderBottom: '1px solid var(--color-border)' }}>Support</div>
            {[0, 1, 2].map((k) => (
              <div key={k} style={{ padding: '6px 8px', borderTop: k ? '1px solid var(--color-border)' : 'none', background: k === 0 ? 'var(--color-accent-light)' : 'transparent' }}>
                <span style={{ display: 'block', height: 4, borderRadius: 2, width: k === 0 ? '80%' : '64%', background: 'var(--color-text-primary)', opacity: k === 0 ? .55 : .2 }}></span>
              </div>
            ))}
          </div>
        </div>
        <div style={{ display: 'grid', gap: 5 }}>
          <div style={{ height: 13, width: '42%', borderRadius: 5, background: 'var(--color-text-primary)', opacity: .72 }}></div>
          <div style={{ height: 44, borderRadius: 8, background: 'var(--color-surface)', border: '1px solid var(--color-border)' }}></div>
          <div style={{ height: 30, borderRadius: 8, background: 'var(--color-surface)', border: '1px solid var(--color-border)' }}></div>
        </div>
      </div>
      <div style={{ display: 'flex', gap: 4, marginTop: 10 }}>
        {['Global: on', 'This page: off'].map((n, k) => (
          <span key={n} style={{
            fontSize: 8.5, fontWeight: 700, padding: '3px 8px', borderRadius: 999,
            background: (k === 0) === on ? 'var(--color-accent)' : 'var(--color-surface)',
            color: (k === 0) === on ? '#fff' : 'var(--color-text-tertiary)', border: '1px solid var(--color-border)',
          }}>{n}</span>
        ))}
      </div>
    </Chrome>
  );
}
// Hide sidebars
function VizSidebar() {
  const [on, setOn] = React.useState(true);
  React.useEffect(() => { const t = setInterval(() => setOn((v) => !v), 1900); return () => clearInterval(t); }, []);
  return (
    <Chrome label={on ? 'sub-nav shown' : 'sub-nav hidden'}>
      <div style={{ display: 'flex', gap: 6 }}>
        <div style={{ width: on ? 58 : 0, opacity: on ? 1 : 0, overflow: 'hidden', transition: 'all .5s var(--ease)', display: 'grid', gap: 4, flexShrink: 0 }}>
          {[.5, .16, .16, .16].map((o, k) => <div key={k} style={{ height: 12, borderRadius: 4, background: 'var(--color-text-primary)', opacity: o }}></div>)}
        </div>
        <div style={{ flex: 1, background: 'var(--color-surface)', border: '1px solid var(--color-border)', borderRadius: 8, padding: 10, display: 'grid', gap: 5, transition: 'all .5s var(--ease)' }}>
          {V.bar('45%', .5, 7)}
          <div style={{ display: 'flex', gap: 5, marginTop: 2 }}>{[0, 1, 2].map(k => <div key={k} style={{ flex: 1, height: 26, borderRadius: 5, background: 'var(--color-surface-secondary)' }}></div>)}</div>
          {V.bar('90%', .1)}{V.bar('70%', .1)}
        </div>
      </div>
    </Chrome>
  );
}
// Languages — WHMCS installs its whole set; this is the shortlist you actually sell in
function VizLanguages() {
  // a slice of the WHMCS language folder, in the order the admin lists them
  const LANGS = [
    ['English', 'en', true, true],
    ['Deutsch', 'de', true, false],
    ['Français', 'fr', true, false],
    ['Español', 'es', false, false],
    ['Português', 'pt', false, false],
    ['Nederlands', 'nl', false, false],
  ];
  const [on, setOn] = React.useState(() => LANGS.map((l) => l[2]));
  // the switcher fills as the rows come on, so the connection reads without a caption
  React.useEffect(() => {
    let i = 3;
    const t = setInterval(() => {
      setOn((v) => { const c = v.slice(); c[i] = !c[i]; return c; });
      i = i === 5 ? 3 : i + 1;
    }, 1500);
    return () => clearInterval(t);
  }, []);
  const live = LANGS.filter((l, i) => on[i]);
  return (
    <Chrome label={`${live.length} of ${LANGS.length} enabled`}>
      <div style={{ display: 'grid', gap: 4 }}>
        {LANGS.map(([n, code, , def], i) => (
          <div key={code} style={{
            display: 'flex', alignItems: 'center', gap: 8, padding: '6px 9px', borderRadius: 8,
            background: 'var(--color-surface)', border: '1px solid var(--color-border)',
            opacity: on[i] ? 1 : 0.55, transition: 'opacity .3s ease',
          }}>
            <span style={{ fontSize: 8, fontWeight: 800, letterSpacing: '.06em', textTransform: 'uppercase', color: 'var(--color-text-tertiary)', width: 16 }}>{code}</span>
            <span style={{ flex: 1, fontSize: 10.5, fontWeight: 600, color: 'var(--color-text-primary)' }}>{n}</span>
            {def && <span style={{ fontSize: 8, fontWeight: 800, letterSpacing: '.06em', textTransform: 'uppercase', color: 'var(--color-accent)' }}>Default</span>}
            <span style={{
              width: 22, height: 13, borderRadius: 999, padding: 2, display: 'flex',
              background: on[i] ? 'var(--color-accent)' : 'var(--color-border)', transition: 'background .3s ease',
            }}>
              <i style={{ width: 9, height: 9, borderRadius: '50%', background: '#fff', transform: on[i] ? 'translateX(9px)' : 'none', transition: 'transform .3s ease' }}></i>
            </span>
          </div>
        ))}
      </div>
      {/* what the client area's switcher ends up offering */}
      <div style={{ marginTop: 10, paddingTop: 9, borderTop: '1px solid var(--color-border)' }}>
        <div style={{ fontSize: 8, fontWeight: 800, letterSpacing: '.1em', textTransform: 'uppercase', color: 'var(--color-text-quaternary)', marginBottom: 6 }}>Client-area switcher</div>
        <div style={{ display: 'flex', gap: 4, flexWrap: 'wrap' }}>
          {live.map(([n, code]) => (
            <span key={code} style={{
              fontSize: 8.5, fontWeight: 700, padding: '3px 8px', borderRadius: 999,
              background: 'var(--color-surface)', border: '1px solid var(--color-border)', color: 'var(--color-text-secondary)',
            }}>{n}</span>
          ))}
        </div>
      </div>
    </Chrome>
  );
}
// Layout wireframes for the tabs block
function VizLayout({ kind }) {
  const acc = 'var(--color-accent)';
  return (
    <div className="hp-frame">
      <div className="hp-framebar"><i></i><i></i><i></i><span className="url">clients.example.com</span></div>
      <div style={{ display: 'grid', gridTemplateColumns: kind === 'top' ? '1fr' : (kind === 'side' ? '132px 1fr' : '80px 1fr'), minHeight: 280, background: 'var(--color-surface-secondary)' }}>
        {kind !== 'top' && (
          <div style={{ background: acc, padding: 14, display: 'flex', flexDirection: 'column', gap: 10, alignItems: kind === 'rail' ? 'center' : 'stretch' }}>
            {kind === 'side'
              ? [.95, .55, .55, .55, .55].map((o, k) => <span key={k} style={{ height: 9, borderRadius: 5, background: `rgba(255,255,255,${o})`, width: k ? '74%' : '90%' }}></span>)
              : [0, 1, 2, 3, 4].map((k) => <span key={k} style={{ width: 22, height: 22, borderRadius: 7, background: `rgba(255,255,255,${k ? .38 : .95})` }}></span>)}
          </div>
        )}
        <div>
          {kind === 'top' && (
            <div style={{ background: acc, display: 'flex', gap: 12, alignItems: 'center', padding: '12px 18px' }}>
              <span style={{ width: 70, height: 9, borderRadius: 5, background: 'rgba(255,255,255,.95)' }}></span>
              {[0, 1, 2, 3].map((k) => <span key={k} style={{ width: 42, height: 8, borderRadius: 4, background: `rgba(255,255,255,${k ? .5 : .95})` }}></span>)}
            </div>
          )}
          <div style={{ padding: 18 }}>
            <div style={{ width: '36%', height: 13, borderRadius: 6, background: 'var(--color-text-primary)', opacity: .75 }}></div>
            <div style={{ display: 'flex', gap: 8, marginTop: 14 }}>{[0, 1, 2, 3].map((k) => <div key={k} style={{ flex: 1, height: 52, borderRadius: 10, background: 'var(--color-surface)', border: '1px solid var(--color-border)' }}></div>)}</div>
            <div style={{ display: 'grid', gridTemplateColumns: '1.6fr 1fr', gap: 8, marginTop: 8 }}>
              <div style={{ height: 88, borderRadius: 10, background: 'var(--color-surface)', border: '1px solid var(--color-border)' }}></div>
              <div style={{ height: 88, borderRadius: 10, background: 'var(--color-surface)', border: '1px solid var(--color-border)' }}></div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
// Colour generator — one base, and the ramp the theme needs computed from it.
// The swatches below run the SAME color-mix the theme's tokens run, so what you
// see here is the derivation itself rather than a picture of one.
function VizPalette() {
  const BRANDS = [['#0071e3', 'Blue'], ['#14b17d', 'Emerald'], ['#8c5cff', 'Violet'], ['#ff2d6b', 'Rose'], ['#f08a00', 'Amber']];
  const [i, setI] = React.useState(0);
  React.useEffect(() => { const t = setInterval(() => setI((v) => (v + 1) % BRANDS.length), 2100); return () => clearInterval(t); }, []);
  const base = BRANDS[i][0];
  // exactly the steps apple-theme.css derives: four lighter, the base, one darker
  const SHADES = [
    ['lighter-4', `color-mix(in srgb, ${base}, #fff 92%)`],
    ['lighter-3', `color-mix(in srgb, ${base}, #fff 84%)`],
    ['lighter-2', `color-mix(in srgb, ${base}, #fff 70%)`],
    ['lighter', `color-mix(in srgb, ${base}, #fff 30%)`],
    ['base', base],
    ['darker', `color-mix(in srgb, ${base}, #000 22%)`],
  ];
  const FAMILIES = [['primary', base], ['secondary', '#64748b'], ['info', '#0a84ff'], ['success', '#30d158'], ['warning', '#ff9f0a'], ['danger', '#ff453a']];
  return (
    <Chrome label="6 families · 5 shades each">
      {/* the one value you set */}
      <div style={{ display: 'flex', alignItems: 'center', gap: 8, padding: '7px 9px', borderRadius: 8, background: 'var(--color-surface)', border: '1px solid var(--color-border)' }}>
        <span style={{ width: 18, height: 18, borderRadius: 5, background: base, transition: 'background .4s ease', flexShrink: 0 }}></span>
        <span style={{ fontSize: 10.5, fontWeight: 600, color: 'var(--color-text-primary)' }}>--brand-primary</span>
        <code style={{ marginLeft: 'auto', fontSize: 9.5, fontFamily: 'ui-monospace,Menlo,monospace', color: 'var(--color-text-tertiary)' }}>{base}</code>
      </div>
      {/* and everything that falls out of it */}
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(6, 1fr)', gap: 4, marginTop: 8 }}>
        {SHADES.map(([name, css]) => (
          <div key={name} style={{ display: 'grid', gap: 3, justifyItems: 'center' }}>
            <span style={{ width: '100%', height: 26, borderRadius: 6, background: css, border: '1px solid var(--color-border)', transition: 'background .4s ease' }}></span>
            <span style={{ fontSize: 7, fontWeight: 700, color: 'var(--color-text-quaternary)', whiteSpace: 'nowrap' }}>{name}</span>
          </div>
        ))}
      </div>
      <div style={{ marginTop: 10, paddingTop: 9, borderTop: '1px solid var(--color-border)', display: 'flex', alignItems: 'center', gap: 6 }}>
        {FAMILIES.map(([n, c]) => (
          <span key={n} title={'--brand-' + n} style={{ width: 13, height: 13, borderRadius: '50%', background: c, border: '1px solid var(--color-border)', transition: 'background .4s ease' }}></span>
        ))}
        <span style={{ marginLeft: 'auto', fontSize: 8.5, fontWeight: 650, color: 'var(--color-text-quaternary)' }}>every ramp recomputes live</span>
      </div>
    </Chrome>
  );
}

Object.assign(window, { Chrome, VizLogin, VizBlocks, VizSeo, VizStyles, VizPalette, VizFonts, VizPageLayout, VizSubnav, VizSidebar, VizLanguages, VizLayout });
