// hadrian-lp5-spotlight.jsx — deep-dive visuals for the single-feature blocks
const SP = { grip: <span className="grip">{[0,1,2].map(r => <i key={r}></i>)}</span> };

/* Menu manager — three menus, a nested tree, real pointer drag-and-drop */
const MENU_TREES = {
  Main: [['Dashboard',0],['Services',0],['Cloud VPS',1],['Business Hosting',1],['SSL Certificates',1],['Domains',0],['Billing',0],['Invoices',1],['My account',0]],
  Secondary: [['Knowledge base',0],['Announcements',0],['Network status',0],['Contact us',0]],
  Footer: [['About us',0],['Terms of service',0],['Privacy policy',0],['Legal',1],['Refund policy',1]],
};
function MenuSpot() {
  const menus = Object.keys(MENU_TREES);
  const [m, setM] = React.useState('Main');
  const [trees, setTrees] = React.useState(MENU_TREES);
  const [sel, setSel] = React.useState(1);
  const [drag, setDrag] = React.useState(null); // {from, to, y, h}
  const listRef = React.useRef(null);
  const rowsRef = React.useRef([]);
  const teardown = React.useRef(null);
  const tree = trees[m];
  const active = tree[Math.min(sel, tree.length - 1)];

  // Bounds-checked: an out-of-range `from` splices out undefined and reinserts it,
  // which the destructure in `shown` below would throw on — taking the whole page
  // with it, since one throw unmounts the root.
  const move = (arr, from, to) => {
    if (from < 0 || from >= arr.length) return arr.slice();
    const c = arr.slice();
    c.splice(Math.max(0, Math.min(to, c.length - 1)), 0, c.splice(from, 1)[0]);
    return c;
  };

  // A drag that outlives its menu is exactly that out-of-range case: switching
  // tabs swaps in a shorter tree while `from` still points into the old one.
  React.useEffect(() => { setDrag(null); }, [m]);
  // and a drag that outlives the component leaves two window listeners running
  // against a detached list
  React.useEffect(() => () => { if (teardown.current) teardown.current(); }, []);

  const onDown = (e, i) => {
    if (e.button != null && e.button !== 0) return;
    e.preventDefault();
    const rows = rowsRef.current;
    if (!rows[i]) return;
    if (e.currentTarget && e.currentTarget.focus) e.currentTarget.focus();
    const box = rows[i].getBoundingClientRect();
    const startY = e.clientY;
    const offset = startY - box.top;
    setDrag({ from: i, to: i, y: box.top, h: box.height, offset, left: box.left, width: box.width });
    const onMove = (ev) => {
      if (!listRef.current) return;
      const listBox = listRef.current.getBoundingClientRect();
      const y = ev.clientY - offset;
      // land on whichever row's midpoint the pointer has passed — skipping the
      // lifted row itself, which otherwise anchors `to` and blocks upward drags
      let to = i;
      rows.forEach((r, k) => { if (!r || k === i) return; const b = r.getBoundingClientRect(); if (ev.clientY > b.top + b.height / 2) to = k; });
      setDrag((d) => (d ? { ...d, to, y: Math.max(listBox.top - 6, Math.min(y, listBox.bottom - box.height + 6)) } : d));
    };
    const stop = () => {
      window.removeEventListener('pointermove', onMove);
      window.removeEventListener('pointerup', onUp);
      window.removeEventListener('pointercancel', onCancel);
      teardown.current = null;
    };
    const onUp = () => {
      stop();
      setDrag((d) => {
        if (d && d.to !== d.from) {
          setTrees((t) => ({ ...t, [m]: move(t[m], d.from, d.to) }));
          setSel(d.to);
        } else if (d) setSel(d.from);
        return null;
      });
    };
    // a cancelled pointer (touch interrupted, browser gesture) never sends pointerup,
    // and a drag left set is what puts `from` out of range on the next tab switch
    const onCancel = () => { stop(); setDrag(null); };
    teardown.current = () => { stop(); setDrag(null); };
    window.addEventListener('pointermove', onMove);
    window.addEventListener('pointerup', onUp);
    window.addEventListener('pointercancel', onCancel);
  };

  // the order shown while dragging: the lifted row pulled out and reinserted
  const shown = drag ? move(tree.map((r, i) => [r, i]), drag.from, drag.to) : tree.map((r, i) => [r, i]);
  return (
    <div className="sp-mock">
      <div className="sp-bar"><i></i><i></i><i></i><span className="u">admin — Hadrian · Menu</span></div>
      <div className={`sp-body sp-menu${drag ? ' dragging' : ''}`}>
        <div className="tabs">
          {menus.map((n) => (
            <button key={n} aria-selected={n === m} onClick={() => { setM(n); setSel(0); }}>{n}</button>
          ))}
        </div>
        <div className="cols">
          <div className="tree" ref={listRef}>
            {shown.map(([[n, depth], orig], i) => {
              const lifted = drag && orig === drag.from;
              return (
                <div
                  key={n}
                  ref={(el) => { rowsRef.current[orig] = el || null; }}
                  className={`row${orig === Math.min(sel, tree.length - 1) && !drag ? ' on' : ''}${lifted ? ' lift' : ''}`}
                  style={lifted
                    ? { margin: 0, position: 'fixed', left: drag.left, width: drag.width, top: drag.y, zIndex: 20 }
                    : { marginLeft: depth * 20 }}
                  onPointerDown={(e) => onDown(e, orig)}
                  role="button"
                  tabIndex={0}
                  onKeyDown={(e) => {
                    if (e.key === 'ArrowUp' && orig > 0) { e.preventDefault(); setTrees((t) => ({ ...t, [m]: move(t[m], orig, orig - 1) })); setSel(orig - 1); }
                    if (e.key === 'ArrowDown' && orig < tree.length - 1) { e.preventDefault(); setTrees((t) => ({ ...t, [m]: move(t[m], orig, orig + 1) })); setSel(orig + 1); }
                    if (e.key === 'Enter' || e.key === ' ') { e.preventDefault(); setSel(orig); }
                  }}
                >
                  {SP.grip}
                  <span className="n">{n}</span>
                  <span className="t">{depth ? 'Sub-item' : 'Page'}</span>
                </div>
              );
            })}
            <div className="add">+ Add item</div>
          </div>
          <div className="side">
            <div className="lbl">Item settings</div>
            <div className="f"><em>Label</em><span>{active[0]}</span></div>
            <div className="f"><em>Type</em><span>{active[1] ? 'Sub-item' : 'WHMCS page'}</span></div>
            <div className="f"><em>Icon</em><span>Chosen</span></div>
            <div className="f"><em>Visible to</em><span>Clients</span></div>
            <div className="chips">{['Top nav','Sidebar','Rail'].map((c, k) => <span key={c} className={k < 2 ? 'on' : ''}>{c}</span>)}</div>
            <div className="hint">Drag a handle to reorder · ↑ ↓ with focus</div>
          </div>
        </div>
      </div>
    </div>
  );
}

/* Homepage composer — a Block Manager popup with pointer drag-and-drop */
const HP_BLOCKS = [
  // the Atrium dashboard's eleven blocks, at the widths it ships them with
  { n: 'Welcome band', w: '1/1', on: true },
  { n: 'Summary figures', w: '1/1', on: true },
  { n: 'Services', w: '2/3', on: true },
  { n: 'Domains', w: '2/3', on: true },
  { n: 'Recent invoices', w: '2/3', on: true },
  { n: 'Announcements', w: '1/3', on: true },
  { n: 'Amount due', w: '1/3', on: true },
  { n: 'Account credit', w: '1/3', on: true },
  { n: 'Payment methods', w: '1/3', on: false },
  { n: 'Support', w: '1/3', on: true },
  { n: 'Quick actions', w: '1/3', on: false },
];
const SPAN = (w) => (w === '1/1' ? 6 : w === '2/3' ? 4 : w === '1/2' ? 3 : 2);
const SIZES = ['1/1', '2/3', '1/2', '1/3'];
const moveAt = (arr, from, to) => {
  if (from < 0 || from >= arr.length) return arr.slice();
  const c = arr.slice();
  c.splice(Math.max(0, Math.min(to, c.length - 1)), 0, c.splice(from, 1)[0]);
  return c;
};

function BlockManager({ blocks, setBlocks, onClose }) {
  const [drag, setDrag] = React.useState(null);
  const listRef = React.useRef(null);
  const rowsRef = React.useRef([]);
  const teardown = React.useRef(null);
  React.useEffect(() => {
    const k = (e) => { if (e.key === 'Escape') onClose(); };
    document.addEventListener('keydown', k);
    const prev = document.body.style.overflow;
    document.body.style.overflow = 'hidden';
    return () => { document.removeEventListener('keydown', k); document.body.style.overflow = prev; };
  }, [onClose]);
  // Esc closes this popup, and it can be pressed mid-drag: without this the two
  // window listeners outlive the list and throw on every pointer move after.
  React.useEffect(() => () => { if (teardown.current) teardown.current(); }, []);

  const onDown = (e, i) => {
    if (e.button != null && e.button !== 0) return;
    e.preventDefault();
    const rows = rowsRef.current;
    if (!rows[i]) return;
    if (e.currentTarget && e.currentTarget.focus) e.currentTarget.focus();
    const box = rows[i].getBoundingClientRect();
    const offset = e.clientY - box.top;
    setDrag({ from: i, to: i, y: box.top, h: box.height, left: box.left, width: box.width, offset });
    const onMove = (ev) => {
      if (!listRef.current) return;
      const listBox = listRef.current.getBoundingClientRect();
      // the lifted row is excluded, or it anchors `to` and upward drags stall
      let to = i;
      rows.forEach((r, k) => { if (!r || k === i) return; const b = r.getBoundingClientRect(); if (ev.clientY > b.top + b.height / 2) to = k; });
      const y = Math.max(listBox.top - 8, Math.min(ev.clientY - offset, listBox.bottom - box.height + 8));
      setDrag((d) => (d ? { ...d, to, y } : d));
    };
    const stop = () => {
      window.removeEventListener('pointermove', onMove);
      window.removeEventListener('pointerup', onUp);
      window.removeEventListener('pointercancel', onCancel);
      teardown.current = null;
    };
    const onCancel = () => { stop(); setDrag(null); };
    const onUp = () => {
      stop();
      setDrag((d) => {
        if (d && d.to !== d.from) setBlocks((prev) => moveAt(prev, d.from, d.to));
        return null;
      });
    };
    teardown.current = () => { stop(); setDrag(null); };
    window.addEventListener('pointermove', onMove);
    window.addEventListener('pointerup', onUp);
    window.addEventListener('pointercancel', onCancel);
  };
  const cycle = (i) => setBlocks((prev) => prev.map((b, k) => k === i ? { ...b, w: SIZES[(SIZES.indexOf(b.w) + 1) % SIZES.length] } : b));
  const toggle = (i) => setBlocks((prev) => prev.map((b, k) => k === i ? { ...b, on: !b.on } : b));
  const nudge = (i, dir) => { const to = i + dir; if (to < 0 || to >= blocks.length) return; setBlocks((prev) => moveAt(prev, i, to)); };
  const shown = drag ? moveAt(blocks.map((b, i) => [b, i]), drag.from, drag.to) : blocks.map((b, i) => [b, i]);
  const live = blocks.filter((b) => b.on);
  return (
    <div className="bm-scrim" onClick={onClose} role="presentation">
      <div className="bm" role="dialog" aria-modal="true" aria-label="Block manager" onClick={(e) => e.stopPropagation()}>
        <div className="bm-head">
          <div>
            <h3>Block manager</h3>
            <p>Drag to reorder, click a width to resize, switch a block off to hide it.</p>
          </div>
          <button className="bm-x" onClick={onClose} aria-label="Close">✕</button>
        </div>
        <div className={`bm-body${drag ? ' dragging' : ''}`}>
          <div className="bm-list" ref={listRef}>
            <div className="bm-lbl">Blocks · {live.length} of {blocks.length} shown</div>
            {shown.map(([b, orig], i) => {
              const lifted = drag && orig === drag.from;
              return (
                <div
                  key={b.n}
                  ref={(el) => { rowsRef.current[orig] = el || null; }}
                  className={`bm-row${b.on ? '' : ' off'}${lifted ? ' lift' : ''}`}
                  style={lifted ? { position: 'fixed', left: drag.left, width: drag.width, top: drag.y, zIndex: 30, margin: 0 } : undefined}
                  onPointerDown={(e) => { if (!e.target.closest('button')) onDown(e, orig); }}
                  tabIndex={0}
                  onKeyDown={(e) => {
                    if (e.key === 'ArrowUp') { e.preventDefault(); nudge(orig, -1); }
                    if (e.key === 'ArrowDown') { e.preventDefault(); nudge(orig, 1); }
                  }}
                >
                  <span className="grip" aria-hidden="true">{[0, 1, 2].map((r) => <i key={r}></i>)}</span>
                  <span className="n">{b.n}</span>
                  <button className="w" onClick={() => cycle(orig)} title="Cycle width">{b.w}</button>
                  <button className={`sw${b.on ? ' on' : ''}`} onClick={() => toggle(orig)} aria-pressed={b.on} aria-label={`${b.on ? 'Hide' : 'Show'} ${b.n}`}><i></i></button>
                </div>
              );
            })}
          </div>
          <div className="bm-prev">
            <div className="bm-lbl">Live preview</div>
            <div className="bm-grid">
              {live.map((b) => <div key={b.n} className="cell" style={{ gridColumn: `span ${SPAN(b.w)}` }}><span>{b.n}</span></div>)}
            </div>
            <div className="bm-hint">Drag a row · ↑ ↓ with focus · Esc to close</div>
          </div>
        </div>
        <div className="bm-foot">
          <button className="ghost" onClick={() => setBlocks(HP_BLOCKS)}>Restore defaults</button>
          <button className="solid" onClick={onClose}>Save changes</button>
        </div>
      </div>
    </div>
  );
}

function BlocksSpot() {
  const [blocks, setBlocks] = React.useState(HP_BLOCKS);
  const [open, setOpen] = React.useState(false);
  const live = blocks.filter((b) => b.on);
  return (
    <div className="sp-mock">
      <div className="sp-bar"><i></i><i></i><i></i><span className="u">admin — Hadrian · Homepage</span></div>
      <div className="sp-body sp-blocks2">
        <div className="hd">
          <span className="t">Homepage blocks</span>
          <button className="manage" onClick={() => setOpen(true)}>
            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.9" strokeLinecap="round"><path d="M4 7h11M19 7h1M4 17h5M13 17h7" /><circle cx="17" cy="7" r="2.2" /><circle cx="11" cy="17" r="2.2" /></svg>
            Manage blocks
          </button>
        </div>
        <div className="bgrid">
          {live.map((b) => <div key={b.n} className="cell" style={{ gridColumn: `span ${SPAN(b.w)}` }}><span>{b.n}</span><i>{b.w}</i></div>)}
        </div>
        <div className="ft">{live.length} of {blocks.length} blocks shown</div>
      </div>
      {open && <BlockManager blocks={blocks} setBlocks={setBlocks} onClose={() => setOpen(false)} />}
    </div>
  );
}

/* Multi-language SEO — every installed language in one editor */
const SEO_LANGS = [
  { c: 'EN', n: 'English', t: 'Cloud VPS Hosting — Fast NVMe Servers' },
  { c: 'DE', n: 'Deutsch', t: 'Cloud-VPS-Hosting — Schnelle NVMe-Server' },
  { c: 'FR', n: 'Français', t: 'Hébergement Cloud VPS — Serveurs NVMe' },
  { c: 'ES', n: 'Español', t: 'Hosting Cloud VPS — Servidores NVMe' },
  { c: 'IT', n: 'Italiano', t: 'Hosting Cloud VPS — Server NVMe veloci' },
  { c: 'PL', n: 'Polski', t: 'Hosting Cloud VPS — Szybkie serwery NVMe' },
];
function SeoSpot() {
  const [sel, setSel] = React.useState(1);
  return (
    <div className="sp-mock">
      <div className="sp-bar"><i></i><i></i><i></i><span className="u">admin — Hadrian · Pages · SEO</span></div>
      <div className="sp-body sp-seo">
        <div className="head">
          <span className="pg">Store · Cloud VPS</span>
          <span className="all">Editing all languages</span>
        </div>
        <div className="rows">
          {SEO_LANGS.map((l, i) => (
            <button key={l.c} className={`row${i === sel ? ' on' : ''}`} onClick={() => setSel(i)}>
              <span className="c">{l.c}</span>
              <span className="v">{l.t}</span>
              <span className="ok" aria-hidden="true">✓</span>
            </button>
          ))}
        </div>
        <div className="foot">
          <span><em>Meta description</em> set in {SEO_LANGS.length} of {SEO_LANGS.length} languages</span>
          <span className="idx">Indexing: allowed</span>
        </div>
      </div>
    </div>
  );
}
Object.assign(window, { MenuSpot, BlocksSpot, SeoSpot });
