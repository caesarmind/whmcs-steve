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
  return (
    <Chrome label="same URL · two experiences">
      <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 8 }}>
        {[['Guest', 'var(--color-accent)'], ['Client', '#30d158']].map(([who, c]) => (
          <div key={who} style={{ background: 'var(--color-surface)', border: '1px solid var(--color-border)', borderRadius: 8, overflow: 'hidden' }}>
            <div style={{ background: c, padding: '5px 8px', fontSize: 8, fontWeight: 800, letterSpacing: '.1em', textTransform: 'uppercase', color: '#fff' }}>{who}</div>
            <div style={{ padding: 8, display: 'grid', gap: 5 }}>
              {who === 'Guest' ? <>{V.bar('70%', .5, 7)}{V.bar('90%', .12)}{V.bar('55%', .12)}<div style={{ height: 20, borderRadius: 5, background: c, opacity: .85, marginTop: 2 }}></div></>
                : <><div style={{ display: 'flex', gap: 4 }}>{[0, 1, 2].map(k => <div key={k} style={{ flex: 1, height: 22, borderRadius: 4, background: 'var(--color-surface-secondary)' }}></div>)}</div>{V.bar('80%', .12)}{V.bar('60%', .12)}{V.bar('70%', .12)}</>}
            </div>
          </div>
        ))}
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
// Fonts
function VizFonts() {
  const fonts = [['System', 'var(--font)'], ['Georgia', 'Georgia,serif'], ['Menlo', 'ui-monospace,Menlo,monospace']];
  const [i, setI] = React.useState(0);
  React.useEffect(() => { const t = setInterval(() => setI((v) => (v + 1) % 3), 1800); return () => clearInterval(t); }, []);
  return (
    <Chrome label={fonts[i][0]}>
      <div style={{ fontFamily: fonts[i][1], transition: 'font-family .2s' }}>
        <div style={{ fontSize: 22, fontWeight: 700, letterSpacing: '-.02em', color: 'var(--color-text-primary)', lineHeight: 1.1 }}>Good evening, Marcus</div>
        <div style={{ fontSize: 11.5, color: 'var(--color-text-tertiary)', marginTop: 6, lineHeight: 1.5 }}>Everything's running smoothly today. Three services renew this month.</div>
      </div>
      <div style={{ display: 'flex', gap: 4, marginTop: 10 }}>
        {fonts.map(([n], k) => <span key={n} style={{ fontSize: 8.5, fontWeight: 700, padding: '3px 8px', borderRadius: 999, background: k === i ? 'var(--color-text-primary)' : 'var(--color-surface)', color: k === i ? 'var(--color-bg)' : 'var(--color-text-tertiary)', border: '1px solid var(--color-border)' }}>{n}</span>)}
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
// Page templates
function VizTemplates() {
  const [i, setI] = React.useState(0);
  React.useEffect(() => { const t = setInterval(() => setI((v) => (v + 1) % 3), 1800); return () => clearInterval(t); }, []);
  // the dashboard's real designs — core/pages/clientareahome/{default,atrium,bento,minimal}
  const kinds = ['Default', 'Atrium', 'Bento'];
  return (
    <Chrome label={`${kinds[i]} template`}>
      <div style={{ display: 'grid', gap: 5 }}>
        {i === 0 && [0, 1, 2].map(k => <div key={k} style={{ height: 22, borderRadius: 6, background: 'var(--color-surface)', border: '1px solid var(--color-border)' }}></div>)}
        {i === 1 && <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 5 }}>{[0, 1, 2, 3].map(k => <div key={k} style={{ height: 34, borderRadius: 8, background: 'var(--color-surface)', border: '1px solid var(--color-border)' }}></div>)}</div>}
        {i === 2 && [0, 1, 2, 3, 4].map(k => <div key={k} style={{ height: 12, borderRadius: 3, background: 'var(--color-surface)', border: '1px solid var(--color-border)' }}></div>)}
      </div>
      <div style={{ display: 'flex', gap: 4, marginTop: 10 }}>
        {kinds.map((n, k) => <span key={n} style={{ fontSize: 8.5, fontWeight: 700, padding: '3px 8px', borderRadius: 999, background: k === i ? 'var(--color-accent)' : 'var(--color-surface)', color: k === i ? '#fff' : 'var(--color-text-tertiary)', border: '1px solid var(--color-border)' }}>{n}</span>)}
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
Object.assign(window, { Chrome, VizLogin, VizBlocks, VizSeo, VizStyles, VizFonts, VizSidebar, VizTemplates, VizLayout });
