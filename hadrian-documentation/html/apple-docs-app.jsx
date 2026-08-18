// apple-docs-app.jsx — docs shell: topbar + sidebar + article + TOC.

function Topbar({ dark, onToggle, query, setQuery }) {
  return (
    <div style={{ position: 'sticky', top: 0, zIndex: 40, height: 60, background: 'color-mix(in srgb, var(--color-bg) 86%, transparent)', backdropFilter: 'saturate(180%) blur(20px)', WebkitBackdropFilter: 'saturate(180%) blur(20px)', borderBottom: '1px solid var(--color-border)', display: 'flex', alignItems: 'center', gap: 20, padding: '0 24px' }}>
      <div style={{ display: 'flex', alignItems: 'center', gap: 10, width: 220, flexShrink: 0 }}>
        <Mark size={26} radius={7} />
        <span style={{ fontFamily: F, fontSize: 19, fontWeight: 600, letterSpacing: '-0.02em', color: 'var(--color-text-primary)' }}>Hadrian</span>
        <span style={{ fontFamily: F, fontSize: 12, fontWeight: 600, color: 'var(--color-text-tertiary)', background: 'var(--color-surface-secondary)', border: '1px solid var(--color-border)', borderRadius: 6, padding: '2px 7px' }}>Docs</span>
      </div>
      <div style={{ flex: 1, maxWidth: 420, display: 'flex', alignItems: 'center', gap: 9, height: 38, padding: '0 14px', background: 'var(--color-surface)', border: '1px solid var(--color-border)', borderRadius: 10, color: 'var(--color-text-tertiary)' }}>
        <AI d={IC.search} size={16} />
        <input value={query} onChange={(e) => setQuery(e.target.value)} placeholder="Search the docs…" style={{ flex: 1, border: 'none', outline: 'none', background: 'transparent', fontFamily: F, fontSize: 14, color: 'var(--color-text-primary)' }} />
        {query && <button onClick={() => setQuery('')} style={{ border: 'none', background: 'transparent', cursor: 'pointer', color: 'var(--color-text-tertiary)', fontSize: 15 }}>✕</button>}
      </div>
      <div style={{ flex: 1 }}></div>
      <button onClick={onToggle} aria-label="Toggle theme" style={{ background: 'var(--color-surface)', border: '1px solid var(--color-border)', borderRadius: 999, width: 38, height: 38, display: 'flex', alignItems: 'center', justifyContent: 'center', cursor: 'pointer', color: 'var(--color-text-primary)' }}>
        <AI d={dark ? IC.sun : IC.moon} size={17} />
      </button>
    </div>
  );
}

function Rail({ product, onPick }) {
  return (
    <div style={{ width: 92, flexShrink: 0, position: 'sticky', top: 60, alignSelf: 'flex-start', height: 'calc(100vh - 60px)', borderRight: '1px solid var(--color-border)', background: 'var(--color-surface-secondary)', padding: '20px 8px', display: 'flex', flexDirection: 'column', gap: 6 }}>
      {PRODUCTS.map((p) => {
        const on = p.id === product;
        return (
          <button key={p.id} onClick={() => onPick(p.id)} title={p.name}
            style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 6, padding: '12px 4px', borderRadius: 12, border: 'none', cursor: 'pointer', background: on ? 'var(--color-surface)' : 'transparent', boxShadow: on ? '0 1px 6px rgba(0,0,0,0.08)' : 'none', position: 'relative' }}>
            <span style={{ width: 40, height: 40, borderRadius: 11, display: 'flex', alignItems: 'center', justifyContent: 'center', background: on ? 'var(--color-accent-light)' : 'var(--color-surface)', border: '1px solid var(--color-border)', color: on ? blue : 'var(--color-text-secondary)' }}>
              <AI d={IC[p.icon]} size={20} />
            </span>
            <span style={{ fontFamily: F, fontSize: 10.5, fontWeight: 600, lineHeight: 1.2, textAlign: 'center', color: on ? blue : 'var(--color-text-tertiary)' }}>{p.name}</span>
            {p.coming && <span style={{ position: 'absolute', top: 8, right: 12, width: 6, height: 6, borderRadius: '50%', background: '#ff9f0a' }}></span>}
          </button>
        );
      })}
    </div>
  );
}

function Sidebar({ product, current, onNav, query }) {
  const prod = PRODUCTS.find((p) => p.id === product);
  const groups = [];
  prod.articles.forEach((k) => {
    const a = ARTICLES[k];
    if (query && !(`${a.title} ${a.lead}`.toLowerCase().includes(query.toLowerCase()))) return;
    let g = groups.find((x) => x.name === a.group);
    if (!g) { g = { name: a.group, items: [] }; groups.push(g); }
    g.items.push([k, a]);
  });
  return (
    <nav style={{ width: 232, flexShrink: 0, position: 'sticky', top: 60, alignSelf: 'flex-start', height: 'calc(100vh - 60px)', overflowY: 'auto', padding: '26px 16px 40px', borderRight: '1px solid var(--color-border)' }}>
      <div style={{ display: 'flex', alignItems: 'center', gap: 8, padding: '0 12px', marginBottom: 22 }}>
        <span style={{ fontFamily: F, fontSize: 17, fontWeight: 600, letterSpacing: '-0.02em', color: 'var(--color-text-primary)' }}>{prod.name}</span>
        {prod.coming && <span style={{ fontFamily: F, fontSize: 10, fontWeight: 700, letterSpacing: '0.06em', textTransform: 'uppercase', color: '#b8860b', background: 'rgba(255,159,10,0.14)', borderRadius: 6, padding: '2px 7px' }}>Soon</span>}
      </div>
      {groups.length === 0 && <div style={{ fontFamily: F, fontSize: 13, color: 'var(--color-text-tertiary)', padding: '8px 12px' }}>No matches.</div>}
      {groups.map((g) => (
        <div key={g.name} style={{ marginBottom: 24 }}>
          <div style={{ fontFamily: F, fontSize: 11, fontWeight: 700, letterSpacing: '0.1em', textTransform: 'uppercase', color: 'var(--color-text-tertiary)', padding: '0 12px', marginBottom: 8 }}>{g.name}</div>
          {g.items.map(([k, a]) => (
            <button key={k} onClick={() => onNav(k)} style={{ width: '100%', textAlign: 'left', display: 'flex', alignItems: 'center', gap: 10, padding: '8px 12px', borderRadius: 8, border: 'none', cursor: 'pointer', marginBottom: 1, fontFamily: F, fontSize: 14, fontWeight: current === k ? 600 : 500, background: current === k ? 'var(--color-accent-light)' : 'transparent', color: current === k ? blue : 'var(--color-text-secondary)' }}>
              <AI d={IC[a.icon]} size={16} /> {a.title}
            </button>
          ))}
        </div>
      ))}
    </nav>
  );
}

function Toc({ article, active }) {
  if (!article.toc) return <div style={{ width: 200, flexShrink: 0 }}></div>;
  return (
    <div style={{ width: 200, flexShrink: 0, position: 'sticky', top: 60, alignSelf: 'flex-start', padding: '40px 20px', display: 'flex', flexDirection: 'column', gap: 2 }}>
      <div style={{ fontFamily: F, fontSize: 11, fontWeight: 700, letterSpacing: '0.1em', textTransform: 'uppercase', color: 'var(--color-text-tertiary)', marginBottom: 10 }}>On this page</div>
      {article.toc.map(([id, label]) => (
        <a key={id} href={`#${id}`} onClick={(e) => { e.preventDefault(); const el = document.getElementById(id); if (el) window.scrollTo({ top: el.getBoundingClientRect().top + window.scrollY - 76, behavior: 'smooth' }); }}
          style={{ fontFamily: F, fontSize: 13.5, lineHeight: 1.5, padding: '4px 10px', borderLeft: `2px solid ${active === id ? blue : 'var(--color-border)'}`, color: active === id ? blue : 'var(--color-text-tertiary)', textDecoration: 'none', fontWeight: active === id ? 600 : 400 }}>{label}</a>
      ))}
    </div>
  );
}

function App() {
  const [product, setProduct] = React.useState(PRODUCTS[0].id);
  const [cur, setCur] = React.useState(PRODUCTS[0].articles[0]);
  const [query, setQuery] = React.useState('');
  const [active, setActive] = React.useState('');
  const [dark, setDark] = React.useState(() => { try { return localStorage.getItem('hadrian-docs-theme') === 'dark'; } catch (e) { return false; } });
  React.useEffect(() => { document.documentElement.setAttribute('data-theme', dark ? 'dark' : 'light'); try { localStorage.setItem('hadrian-docs-theme', dark ? 'dark' : 'light'); } catch (e) {} }, [dark]);

  const prod = PRODUCTS.find((p) => p.id === product);
  const keys = prod.articles;
  const a = ARTICLES[cur];
  const idx = keys.indexOf(cur);
  const prev = idx > 0 ? keys[idx - 1] : null;
  const next = idx < keys.length - 1 ? keys[idx + 1] : null;

  const nav = (k) => { setCur(k); window.scrollTo({ top: 0 }); };
  const pickProduct = (pid) => { const p = PRODUCTS.find((x) => x.id === pid); setProduct(pid); setCur(p.articles[0]); setQuery(''); window.scrollTo({ top: 0 }); };

  // scroll-spy for TOC
  React.useEffect(() => {
    setActive(a.toc ? a.toc[0][0] : '');
    const onScroll = () => {
      if (!a.toc) return;
      let best = a.toc[0][0];
      for (const [id] of a.toc) { const el = document.getElementById(id); if (el && el.getBoundingClientRect().top <= 120) best = id; }
      setActive(best);
    };
    window.addEventListener('scroll', onScroll, { passive: true });
    return () => window.removeEventListener('scroll', onScroll);
  }, [cur]);

  return (
    <div style={{ minHeight: '100vh', background: 'var(--color-bg)' }}>
      <Topbar dark={dark} onToggle={() => setDark(!dark)} query={query} setQuery={setQuery} />
      <div style={{ display: 'flex' }}>
        <Rail product={product} onPick={pickProduct} />
        <Sidebar product={product} current={cur} onNav={nav} query={query} />
        <main style={{ flex: 1, minWidth: 0, padding: '44px 56px 80px', maxWidth: 880, margin: '0 auto' }}>
          <div style={{ fontFamily: F, fontSize: 13, fontWeight: 600, color: blue, marginBottom: 10 }}>{prod.name} · {a.group}</div>
          <h1 style={{ fontFamily: F, fontSize: 40, fontWeight: 600, letterSpacing: '-0.03em', color: 'var(--color-text-primary)', margin: '0 0 16px', lineHeight: 1.05 }}>{a.title}</h1>
          <p style={{ fontFamily: F, fontSize: 19, lineHeight: 1.6, color: 'var(--color-text-secondary)', margin: '0 0 12px' }}>{a.lead}</p>
          <div style={{ height: 1, background: 'var(--color-border)', margin: '28px 0 36px' }}></div>
          {a.body()}
          <div style={{ display: 'flex', justifyContent: 'space-between', gap: 16, marginTop: 56, paddingTop: 28, borderTop: '1px solid var(--color-border)' }}>
            {prev ? <button onClick={() => nav(prev)} style={navBtn}><span style={dim}>← Previous</span><span style={strong}>{ARTICLES[prev].title}</span></button> : <span></span>}
            {next ? <button onClick={() => nav(next)} style={{ ...navBtn, textAlign: 'right', alignItems: 'flex-end' }}><span style={dim}>Next →</span><span style={strong}>{ARTICLES[next].title}</span></button> : <span></span>}
          </div>
        </main>
        <Toc article={a} active={active} />
      </div>
    </div>
  );
}
const navBtn = { display: 'flex', flexDirection: 'column', gap: 4, padding: '14px 18px', borderRadius: 12, border: '1px solid var(--color-border)', background: 'var(--color-surface)', cursor: 'pointer', minWidth: 160 };
const dim = { fontFamily: F, fontSize: 12.5, color: 'var(--color-text-tertiary)' };
const strong = { fontFamily: F, fontSize: 15, fontWeight: 600, color: 'var(--color-text-primary)' };

ReactDOM.createRoot(document.getElementById('root')).render(<App />);
