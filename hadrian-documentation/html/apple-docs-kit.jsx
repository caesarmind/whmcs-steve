// apple-docs.jsx — Hadrian documentation site, Apple direction.
// Sidebar nav + article + on-this-page TOC, light/dark. Depends on apple-theme.css.

const F = 'var(--font)';
const FM = 'var(--font-mono, ui-monospace, SFMono-Regular, Menlo, monospace)';
const blue = '#0071e3';

// ── Caesar mark (tinted img, no CSS mask) ────────────────────────────────
const _tc = {};
let _silP = null;
function loadSil() { if (!_silP) _silP = new Promise((res, rej) => { const im = new Image(); im.onload = () => res(im); im.onerror = rej; im.src = 'caesar-silhouette.png'; }); return _silP; }
async function buildTint(c) { if (_tc[c]) return _tc[c]; const im = await loadSil(); const cv = document.createElement('canvas'); cv.width = im.naturalWidth || 512; cv.height = im.naturalHeight || 512; const x = cv.getContext('2d'); x.drawImage(im, 0, 0, cv.width, cv.height); x.globalCompositeOperation = 'source-in'; x.fillStyle = c; x.fillRect(0, 0, cv.width, cv.height); const d = cv.toDataURL('image/png'); _tc[c] = d; return d; }
function useTint(c) { const [s, set] = React.useState(_tc[c]); React.useEffect(() => { let on = true; buildTint(c).then((d) => on && set(d)); return () => { on = false; }; }, [c]); return s; }
function Mark({ size = 26, tile = '#1d1d1f', bust = '#f5f5f7', radius }) {
  const src = useTint(bust);
  return (
    <span style={{ width: size, height: size, borderRadius: radius != null ? radius : size * 0.26, background: tile, position: 'relative', overflow: 'hidden', display: 'inline-block', flexShrink: 0 }}>
      {src && <img src={src} alt="" style={{ position: 'absolute', left: '7%', top: '7%', width: '86%', height: '86%', objectFit: 'contain' }} />}
    </span>
  );
}

// ── Inline content renderers ─────────────────────────────────────────────
function AI({ d, size = 18, sw = 1.7 }) { return <svg width={size} height={size} viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth={sw} strokeLinecap="round" strokeLinejoin="round" dangerouslySetInnerHTML={{ __html: d }} />; }
const IC = {
  search: '<circle cx="11" cy="11" r="7"/><path d="M21 21l-4-4"/>',
  book: '<path d="M4 5a2 2 0 0 1 2-2h12v18H6a2 2 0 0 1-2-2z"/><path d="M18 17H6"/>',
  rocket: '<path d="M5 15c-1.5 1.5-2 5-2 5s3.5-.5 5-2"/><path d="M9 11a8 8 0 0 1 8-8c1 0 3 0 3 0s0 2 0 3a8 8 0 0 1-8 8z"/><circle cx="14.5" cy="9.5" r="1.5"/>',
  palette: '<circle cx="13.5" cy="6.5" r="1.3"/><circle cx="17.5" cy="10.5" r="1.3"/><circle cx="8.5" cy="7.5" r="1.3"/><circle cx="6.5" cy="12.5" r="1.3"/><path d="M12 2C6.5 2 2 6.5 2 12s4.5 10 10 10c.9 0 1.6-.7 1.6-1.7 0-.4-.2-.8-.4-1.1-.3-.3-.4-.7-.4-1.1a1.6 1.6 0 0 1 1.7-1.7h2c3 0 5.5-2.5 5.5-5.6C22 6 17.5 2 12 2z"/>',
  layout: '<rect x="3" y="3" width="18" height="18" rx="2"/><path d="M3 9h18M9 21V9"/>',
  cart: '<circle cx="9" cy="20" r="1"/><circle cx="18" cy="20" r="1"/><path d="M2 3h3l2.5 12.5a2 2 0 0 0 2 1.5h7a2 2 0 0 0 2-1.5L22 7H6"/>',
  puzzle: '<path d="M10 3v3a2 2 0 0 0 4 0V3h4a1 1 0 0 1 1 1v4h-3a2 2 0 0 0 0 4h3v4a1 1 0 0 1-1 1h-4v-3a2 2 0 0 0-4 0v3H6a1 1 0 0 1-1-1v-4h3a2 2 0 0 0 0-4H5V4a1 1 0 0 1 1-1z"/>',
  plug: '<path d="M9 2v6M15 2v6M7 8h10v3a5 5 0 0 1-10 0z"/><path d="M12 16v6"/>',
  mail: '<rect x="3" y="5" width="18" height="14" rx="2"/><path d="M3 7l9 6 9-6"/>',
  doc: '<path d="M14 3H7a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h10a2 2 0 0 0 2-2V8z"/><path d="M14 3v5h5"/>',
  sun: '<circle cx="12" cy="12" r="4"/><path d="M12 2v2M12 20v2M4 12H2M22 12h-2M5 5l1.5 1.5M17.5 17.5L19 19M19 5l-1.5 1.5M6.5 17.5L5 19"/>',
  moon: '<path d="M21 12.8A9 9 0 1 1 11.2 3a7 7 0 0 0 9.8 9.8z"/>',
};

function H2({ id, children }) { return <h2 id={id} style={{ fontFamily: F, fontSize: 28, fontWeight: 600, letterSpacing: '-0.025em', color: 'var(--color-text-primary)', margin: '52px 0 18px', scrollMarginTop: 80 }}>{children}</h2>; }
function H3({ id, children }) { return <h3 id={id} style={{ fontFamily: F, fontSize: 20, fontWeight: 600, letterSpacing: '-0.015em', color: 'var(--color-text-primary)', margin: '34px 0 12px', scrollMarginTop: 80 }}>{children}</h3>; }
function P({ children }) { return <p style={{ fontFamily: F, fontSize: 16, lineHeight: 1.7, color: 'var(--color-text-secondary)', margin: '0 0 18px' }}>{children}</p>; }
function UL({ items }) {
  return (
    <ul style={{ margin: '0 0 20px', padding: 0, listStyle: 'none', display: 'flex', flexDirection: 'column', gap: 10 }}>
      {items.map((it, i) => (
        <li key={i} style={{ fontFamily: F, fontSize: 15.5, lineHeight: 1.6, color: 'var(--color-text-secondary)', display: 'flex', gap: 12 }}>
          <span style={{ flexShrink: 0, marginTop: 8, width: 6, height: 6, borderRadius: '50%', background: blue }}></span>
          <span dangerouslySetInnerHTML={{ __html: it }}></span>
        </li>
      ))}
    </ul>
  );
}
function Steps({ items }) {
  return (
    <ol style={{ margin: '0 0 22px', padding: 0, listStyle: 'none', display: 'flex', flexDirection: 'column', gap: 14, counterReset: 'step' }}>
      {items.map((it, i) => (
        <li key={i} style={{ display: 'flex', gap: 14, alignItems: 'flex-start' }}>
          <span style={{ flexShrink: 0, width: 26, height: 26, borderRadius: '50%', background: 'var(--color-accent-light)', color: blue, fontFamily: F, fontSize: 13, fontWeight: 700, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>{i + 1}</span>
          <span style={{ fontFamily: F, fontSize: 15.5, lineHeight: 1.6, color: 'var(--color-text-secondary)', paddingTop: 2 }} dangerouslySetInnerHTML={{ __html: it }}></span>
        </li>
      ))}
    </ol>
  );
}
function Callout({ kind = 'info', title, children }) {
  const map = { info: [blue, 'var(--color-accent-light)', 'i'], tip: ['#1f8a5b', 'rgba(48,209,88,0.12)', '✓'], warn: ['#b8860b', 'rgba(255,159,10,0.14)', '!'] };
  const [c, bg, glyph] = map[kind];
  return (
    <div style={{ display: 'flex', gap: 14, padding: '16px 18px', background: bg, borderRadius: 12, margin: '0 0 22px' }}>
      <span style={{ flexShrink: 0, width: 24, height: 24, borderRadius: '50%', background: c, color: '#fff', display: 'flex', alignItems: 'center', justifyContent: 'center', fontFamily: F, fontWeight: 700, fontSize: 13 }}>{glyph}</span>
      <div style={{ fontFamily: F, fontSize: 14.5, lineHeight: 1.6, color: 'var(--color-text-primary)' }}>
        {title && <strong style={{ display: 'block', marginBottom: 2 }}>{title}</strong>}
        <span style={{ color: 'var(--color-text-secondary)' }}>{children}</span>
      </div>
    </div>
  );
}
function Code({ children, lang }) {
  return (
    <div style={{ margin: '0 0 22px', borderRadius: 12, overflow: 'hidden', border: '1px solid var(--color-border)' }}>
      {lang && <div style={{ fontFamily: FM, fontSize: 11, color: 'var(--color-text-tertiary)', padding: '8px 16px', borderBottom: '1px solid var(--color-border)', background: 'var(--color-surface-secondary)', letterSpacing: '0.04em', textTransform: 'uppercase' }}>{lang}</div>}
      <pre style={{ margin: 0, padding: 16, background: 'var(--color-surface)', overflowX: 'auto' }}><code style={{ fontFamily: FM, fontSize: 13, lineHeight: 1.65, color: 'var(--color-text-primary)', whiteSpace: 'pre' }}>{children}</code></pre>
    </div>
  );
}
function Shot({ label }) {
  return (
    <div style={{ margin: '0 0 22px', borderRadius: 12, border: '1px solid var(--color-border)', background: 'var(--color-surface-secondary)', height: 220, display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', gap: 10 }}>
      <span style={{ width: 40, height: 40, borderRadius: 10, background: 'var(--color-surface)', border: '1px solid var(--color-border)', display: 'flex', alignItems: 'center', justifyContent: 'center', color: 'var(--color-text-tertiary)' }}><AI d={IC.layout} size={20} /></span>
      <span style={{ fontFamily: F, fontSize: 13, color: 'var(--color-text-tertiary)' }}>{label}</span>
    </div>
  );
}
function PropTable({ rows }) {
  return (
    <div style={{ margin: '0 0 22px', borderRadius: 12, border: '1px solid var(--color-border)', overflow: 'hidden' }}>
      <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr 2fr', background: 'var(--color-surface-secondary)', borderBottom: '1px solid var(--color-border)' }}>
        {['Setting', 'Default', 'Description'].map((h) => <span key={h} style={{ fontFamily: F, fontSize: 11, fontWeight: 700, letterSpacing: '0.08em', textTransform: 'uppercase', color: 'var(--color-text-tertiary)', padding: '12px 16px' }}>{h}</span>)}
      </div>
      {rows.map((r, i) => (
        <div key={i} style={{ display: 'grid', gridTemplateColumns: '1fr 1fr 2fr', borderTop: i ? '1px solid var(--color-border)' : 'none' }}>
          <span style={{ fontFamily: FM, fontSize: 13, color: blue, padding: '12px 16px' }}>{r[0]}</span>
          <span style={{ fontFamily: FM, fontSize: 13, color: 'var(--color-text-tertiary)', padding: '12px 16px' }}>{r[1]}</span>
          <span style={{ fontFamily: F, fontSize: 14, color: 'var(--color-text-secondary)', padding: '12px 16px', lineHeight: 1.5 }}>{r[2]}</span>
        </div>
      ))}
    </div>
  );
}

Object.assign(window, { F, FM, blue, Mark, AI, IC, H2, H3, P, UL, Steps, Callout, Code, Shot, PropTable });
