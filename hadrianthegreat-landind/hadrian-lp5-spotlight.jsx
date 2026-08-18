// hadrian-lp5-spotlight.jsx — deep-dive visuals for the single-feature blocks
const SP = { grip: <span className="grip">{[0,1,2].map(r => <i key={r}></i>)}</span> };

/* Menu manager, simplified — one flat list whose only job is to show that the
   order is yours to drag. The full MenuSpot below carries the three menus, the
   nesting and the per-item settings; this keeps the same pointer-drag logic and
   drops everything that competes with the point. */
const MENU_SIMPLE = [
  ['Dashboard', 0],
  ['Services', 0],
  ['Cloud VPS', 1],
  ['Business Hosting', 1],
  ['Domains', 0],
  ['Billing', 0],
  ['Invoices', 1],
  ['Support', 0],
];
function MenuSpotSimple() {
  const [items, setItems] = React.useState(MENU_SIMPLE);
  const [drag, setDrag] = React.useState(null);
  const listRef = React.useRef(null);
  const rowsRef = React.useRef([]);
  const teardown = React.useRef(null);

  const move = (arr, from, to) => {
    if (from < 0 || from >= arr.length) return arr.slice();
    const c = arr.slice();
    c.splice(Math.max(0, Math.min(to, c.length - 1)), 0, c.splice(from, 1)[0]);
    return c;
  };
  // a drag that outlives the component would leave two window listeners bound
  // to a detached list
  React.useEffect(() => () => { if (teardown.current) teardown.current(); }, []);

  const onDown = (e, i) => {
    if (e.button != null && e.button !== 0) return;
    e.preventDefault();
    const rows = rowsRef.current;
    if (!rows[i]) return;
    if (e.currentTarget && e.currentTarget.focus) e.currentTarget.focus();
    const box = rows[i].getBoundingClientRect();
    const offset = e.clientY - box.top;
    setDrag({ from: i, to: i, y: box.top, h: box.height, offset, left: box.left, width: box.width });
    const onMove = (ev) => {
      if (!listRef.current) return;
      const listBox = listRef.current.getBoundingClientRect();
      const y = ev.clientY - offset;
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
        if (d && d.to !== d.from) { setItems((t) => move(t, d.from, d.to)); }
        return null;
      });
    };
    const onCancel = () => { stop(); setDrag(null); };
    teardown.current = () => { stop(); setDrag(null); };
    window.addEventListener('pointermove', onMove);
    window.addEventListener('pointerup', onUp);
    window.addEventListener('pointercancel', onCancel);
  };

  const shown = drag ? move(items.map((r, i) => [r, i]), drag.from, drag.to) : items.map((r, i) => [r, i]);
  return (
    <div className="sp-mock">
      <div className="sp-bar"><i></i><i></i><i></i><span className="u">admin — Hadrian · Menu</span></div>
      <div className={`sp-body sp-menu sp-menu-lite${drag ? ' dragging' : ''}`}>
        <div className="tree" ref={listRef}>
          {shown.map(([[n, depth], orig]) => {
            const lifted = drag && orig === drag.from;
            return (
              <div
                key={n}
                ref={(el) => { rowsRef.current[orig] = el || null; }}
                className={`row${lifted ? ' lift' : ''}${depth ? ' sub' : ''}`}
                style={lifted
                  ? { margin: 0, position: 'fixed', left: drag.left, width: drag.width, top: drag.y, zIndex: 20 }
                  : { marginLeft: depth * 22 }}
                onPointerDown={(e) => onDown(e, orig)}
                role="button"
                tabIndex={0}
                aria-label={`${n} — drag, or use arrow keys, to reorder`}
                onKeyDown={(e) => {
                  if (e.key === 'ArrowUp' && orig > 0) { e.preventDefault(); setItems((t) => move(t, orig, orig - 1)); }
                  if (e.key === 'ArrowDown' && orig < items.length - 1) { e.preventDefault(); setItems((t) => move(t, orig, orig + 1)); }
                }}
              >
                {SP.grip}
                <span className="n">{n}</span>
              </div>
            );
          })}
        </div>
      </div>
    </div>
  );
}

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

/* Homepage composer — the admin list on the left, and on the right the actual
   Bento dashboard from ../apple-client-area, mounted live. Every row writes the
   same LAYOUT object that page's own layout map writes (through the hnComposer
   bridge it exposes), so the preview is not a drawing of the page: it is the
   page. Off a server the frame can't boot — CanvasPreview stands in. */
/* Atrium's nine cards, on the same six-column footprint the composer speaks:
   a card takes a full row, two thirds, a half or a third, and carries its own
   fill and hue. Two page parts — the welcome band and the figures strip — span
   the row by design and only switch on or off. */
const SIZES = [['full', '1/1'], ['twothirds', '2/3'], ['half', '1/2'], ['third', '1/3']];
const FILLS = [['plain', 'White'], ['tint', 'Tint'], ['accent', 'Accent'], ['gradient', 'Gradient']];
const TONES = ['default', 'blue', 'emerald', 'violet', 'rose', 'amber', 'slate'];
const TONE_HEX = { blue: '#0071e3', emerald: '#14b17d', violet: '#8c5cff', rose: '#ff2d6b', amber: '#f08a00', slate: '#64748b' };
const TONE_NAME = { default: 'Theme accent', blue: 'Blue', emerald: 'Emerald', violet: 'Violet', rose: 'Rose', amber: 'Amber', slate: 'Slate' };
const STYLE_NAME = { plain: 'White', tint: 'Tint', accent: 'Accent', gradient: 'Gradient' };
const CX_FRAME_W = 1400;   // Atrium collapses its fractions at 900px; this clears it easily
const HP_BLOCKS = [
  { k: 'hero',   n: 'Welcome band',    part: true, on: true, style: 'gradient', size: 'full' },
  { k: 'stats',  n: 'Summary figures', part: true, on: false },   // Atrium ships this row off
  { k: 'svc',    n: 'Services',        w: 'twothirds', on: true },
  { k: 'dom',    n: 'Domains',         w: 'twothirds', on: true },
  { k: 'inv',    n: 'Recent invoices', w: 'twothirds', on: true },
  { k: 'tkt',    n: 'Support tickets', w: 'twothirds', on: true },
  { k: 'due',    n: 'Unpaid invoice',  w: 'third', on: true, style: 'accent', color: 'rose' },
  { k: 'credit', n: 'Account credit',  w: 'third', on: true },
  { k: 'news',   n: 'Announcements',   w: 'third', on: true },
  { k: 'pay',    n: 'Payment methods', w: 'third', on: false },
  { k: 'act',    n: 'Quick actions',   w: 'third', on: true },
].map((b) => ({ style: 'plain', color: 'default', ...b }));
/* a row names only what has moved off default, so an untouched card reads "2 settings" */
const settingCount = (b) => (b.k === 'hero' ? 3 : b.part ? 0 : 2);
const SIZE_NAME = { full: 'Full', slim: 'Slim' };
function summarise(b) {
  if (b.k === 'hero') {
    const out = [];
    if (b.style !== 'gradient') out.push(STYLE_NAME[b.style]);
    if (b.color !== 'default') out.push(TONE_NAME[b.color]);
    if (b.size !== 'full') out.push(SIZE_NAME[b.size]);
    return out.length ? out.join(' · ') : '3 settings';
  }
  if (b.part) return 'Spans the row';
  const out = [];
  if (b.style !== 'plain') out.push(STYLE_NAME[b.style]);
  if (b.color !== 'default') out.push(TONE_NAME[b.color]);
  return out.length ? out.join(' · ') : '2 settings';
}
const moveAt = (arr, from, to) => {
  if (from < 0 || from >= arr.length) return arr.slice();
  const c = arr.slice();
  c.splice(Math.max(0, Math.min(to, c.length - 1)), 0, c.splice(from, 1)[0]);
  return c;
};

/* A short guided run, so the block explains itself to someone who has not
   worked out that the rows are live. Every step is an ordinary edit — the same
   one a click would make — and the first touch anywhere in the list stops it. */
const byKey = (bs, k, fn) => bs.map((b) => (b.k === k ? fn(b) : b));
const keyAt = (bs, k) => bs.findIndex((b) => b.k === k);
const TOUR = [
  { k: 'svc', t: 'Give Services the full row',        run: (bs) => byKey(bs, 'svc', (b) => ({ ...b, w: 'full' })) },
  { k: 'due', t: 'Paint the unpaid invoice violet', open: true, run: (bs) => byKey(bs, 'due', (b) => ({ ...b, style: 'gradient', color: 'violet' })) },
  { k: 'pay', t: 'Switch Payment methods back on',    run: (bs) => byKey(bs, 'pay', (b) => ({ ...b, on: true })) },
  { k: 'tkt', t: 'Lift Support tickets to the top',   run: (bs) => moveAt(bs, keyAt(bs, 'tkt'), 2) },
  { k: 'news',t: 'Half a row for Announcements',      run: (bs) => byKey(bs, 'news', (b) => ({ ...b, w: 'half' })) },
  { k: null,  t: 'Your turn — drag a row, or click a width', run: (bs) => bs, hold: 2600 },
];

function toLayout(blocks) {
  const patch = { order: [], off: {}, width: {}, color: {}, style: {}, parts: {} };
  blocks.forEach((b) => {
    if (b.part) {
      patch.parts[b.k] = b.on;
      if (b.k === 'hero') {
        if (b.color !== 'default') patch.color.hero = b.color;
        if (b.style !== 'gradient') patch.style.hero = b.style;
        patch.heroSize = b.size;
      }
      return;
    }
    patch.order.push(b.k);
    if (!b.on) patch.off[b.k] = true;
    patch.width[b.k] = b.w;
    if (b.color !== 'default') patch.color[b.k] = b.color;
    if (b.style !== 'plain') patch.style[b.k] = b.style;
  });
  return patch;
}

/* ── the stand-in, for when the frame can't boot (file://, a failed fetch) ── */
const PV = {
  svc: [['staging.lockworth.com', 'Business Hosting', 'Suspended', 'warn'], ['mail-relay-02.hostnodes.io', 'SMTP Relay', 'Pending', 'warn'], ['db-02.hostnodes.io', 'Managed MySQL', 'Active', 'ok']],
  dom: [['lockworth.io', 'in 9 days', 'Expiring', 'warn'], ['hostnodes.io', 'renews Jun 2', 'Active', 'ok'], ['petey.dev', 'renews Jan 22', 'Active', 'ok']],
  inv: [['#10247', 'due Jun 1', '$18.00'], ['#10231', 'paid May 2', '$18.00'], ['#10218', 'paid Apr 2', '$12.00']],
  tkt: [['Re: Backup schedule', 'Technical · 2h ago', 'Awaiting you', 'info'], ['SSL won’t install on staging', 'Technical · 4h ago', 'Awaiting you', 'info'], ['Invoice #10247 charged twice', 'Billing · yesterday', 'Awaiting you', 'info']],
  news: [['Scheduled network maintenance', '3 days ago'], ['Two-factor authentication is available', '9 days ago']],
  act: [['New order', 'Browse the catalogue'], ['Register a domain', 'Or transfer one in'], ['Open a ticket', 'We answer in minutes']],
};
function PvRows({ src, status }) {
  return src.map(([n, sub, st, cls]) => (
    <div className="r" key={n}>
      <span className="nm">{n}<em>{sub}</em></span>
      {status && st ? <i className={'st ' + cls}>{st}</i> : null}
    </div>
  ));
}
function PvBody({ b }) {
  switch (b.k) {
    case 'hero':
      return (
        <div className="hd">
          <div>
            <div className="eyebrow">Tuesday · 2 June</div>
            <div className="big">Welcome back, Petey.</div>
          </div>
          <span className="av">LW</span>
        </div>
      );
    case 'stats':
      return (
        <div className="figs">
          {[['8', 'services'], ['7', 'domains'], ['10', 'tickets'], ['$18', 'due']].map(([v, l]) => (
            <span key={l}><b>{v}</b><em>{l}</em></span>
          ))}
        </div>
      );
    case 'due':
      return (
        <>
          <div className="hd"><div className="big">$18.00</div><span className="eyebrow">due Jun 1</span></div>
          <div className="field"><span className="pay">Pay now</span></div>
        </>
      );
    case 'credit':
      return (
        <>
          <div className="hd"><div className="big">$40.00</div><span className="eyebrow">on account</span></div>
          <div className="ft">Applied to your next invoice</div>
        </>
      );
    case 'pay':
      return <div className="who"><span className="av">VISA</span><span className="nm">Ending 4242<em>expires 09 / 28</em></span></div>;
    case 'inv':
      return PV.inv.map(([n, d, a]) => (
        <div className="r" key={n}><span className="nm">Invoice {n}<em>{d}</em></span><i className="amt">{a}</i></div>
      ));
    case 'act':
      return PV.act.map(([n, d]) => <div className="r" key={n}><span className="nm">{n}<em>{d}</em></span><span className="lnk">›</span></div>);
    case 'news':
      return PV.news.map(([n, d]) => <div className="r" key={n}><span className="nm">{n}<em>{d}</em></span></div>);
    default:
      return <PvRows src={PV[b.k] || []} status />;
  }
}
const SPAN = { full: 6, twothirds: 4, half: 3, third: 2 };
function CanvasPreview({ blocks }) {
  const live = blocks.filter((b) => b.on);
  return (
    <div className="cx-canvas">
      <div className="cx-grid">
        {live.map((b) => (
          <div
            key={b.k}
            className={'cx-b' + (b.part ? ' part' : '') + (b.style === 'plain' ? '' : ' s-' + b.style)}
            style={{ gridColumn: 'span ' + (b.part ? 6 : SPAN[b.w]), '--blk': TONE_HEX[b.color] || 'var(--color-accent)' }}
          >
            <div className="k">{b.n}</div>
            <PvBody b={b} />
          </div>
        ))}
      </div>
      {!live.length && <div className="cx-empty">Every card is switched off — turn one back on.</div>}
    </div>
  );
}

function ComposerSpot({ dark }) {
  const [blocks, setBlocks] = React.useState(HP_BLOCKS);
  const [open, setOpen] = React.useState(null);
  const [step, setStep] = React.useState(-1);        // -1 idle, else index into TOUR
  const [hint, setHint] = React.useState(null);      // the row the current step is acting on
  const tourAt = React.useRef(null);
  const played = React.useRef(false);
  const [drag, setDrag] = React.useState(null);
  const listRef = React.useRef(null);
  const rowsRef = React.useRef([]);
  const stageRef = React.useRef(null);
  const teardown = React.useRef(null);
  const frameState = React.useMemo(() => ({ layout: 'top', dark }), [dark]);

  // a drag that outlives the component would leave two window listeners bound
  // to a detached list
  React.useEffect(() => () => { if (teardown.current) teardown.current(); }, []);

  /* ── the guided run ─────────────────────────────────────────────────────── */
  const stopTour = React.useCallback(() => {
    clearTimeout(tourAt.current);
    tourAt.current = null;
    setStep(-1);
    setHint(null);
  }, []);
  const runStep = React.useCallback((i) => {
    if (i >= TOUR.length) { stopTour(); return; }
    const s = TOUR[i];
    setStep(i);
    setHint(s.k);
    setOpen(s.open ? s.k : null);
    setBlocks((prev) => s.run(prev));
    tourAt.current = setTimeout(() => runStep(i + 1), s.hold || 1700);
  }, [stopTour]);
  const startTour = React.useCallback(() => {
    clearTimeout(tourAt.current);
    setBlocks(HP_BLOCKS);       // replay from the same place every time
    setOpen(null);
    tourAt.current = setTimeout(() => runStep(0), 450);
    setStep(-2);                // arming: the button reads as running straight away
  }, [runStep]);
  // play once, when the block is actually on screen and the frame has settled
  React.useEffect(() => {
    const el = listRef.current;
    if (!el || played.current) return;
    if (typeof IntersectionObserver === 'undefined') return;
    let reduce = false;
    try { reduce = window.matchMedia('(prefers-reduced-motion: reduce)').matches; } catch (e) {}
    if (reduce) return;         // the button is still there for anyone who wants it
    const io = new IntersectionObserver((es) => {
      es.forEach((e) => {
        if (!e.isIntersecting || played.current) return;
        played.current = true;
        io.disconnect();
        startTour();
      });
    }, { threshold: 0.4 });
    io.observe(el);
    return () => io.disconnect();
  }, [startTour]);
  React.useEffect(() => () => clearTimeout(tourAt.current), []);

  /* Strip the page down to the part this admin screen owns. The mounted page is
     a whole client area — nav, breadcrumb, footer, its own dev chip — and none
     of that is the composer's to arrange, so the frame shows the content column
     alone: the band, the alert strip and the block grid. Injected from here
     rather than built into the page, because it is this embed's framing, not a
     mode the client area has. */
  const CROP = [
    'body > * { display: none !important; }',
    'body > .ph-main-wrap { display: block !important; padding: 0 !important; margin: 0 !important; }',
    '.ph-main-wrap > *:not(.content-area) { display: none !important; }',
    '.content-area { max-width: none !important; width: auto !important; margin: 0 !important; padding: 22px !important; }',
  ].join('\n');

  /* push the rows into the mounted dashboard. The frame boots asynchronously
     and ThemeFrame owns the <iframe>, so reach for it and retry until the page
     has published its bridge. */
  React.useEffect(() => {
    let tries = 0, timer = null, fits = [];
    const push = () => {
      const host = stageRef.current;
      const f = host && host.querySelector('iframe');
      let api = null, doc = null;
      try { doc = f && f.contentDocument; api = f && f.contentWindow && f.contentWindow.hnComposer; } catch (e) { api = null; }
      if (api && api.write) {
        if (doc && doc.head && !doc.getElementById('cx-crop')) {
          const st = doc.createElement('style');
          st.id = 'cx-crop';
          st.textContent = CROP;
          doc.head.appendChild(st);
        }
        api.write(toLayout(blocks));
        /* The panel is scaled, so a fixed height either crops the last block or
           leaves a band of empty page under it — and which one depends on how
           many blocks are switched on. Take the height from the composed page
           instead, once its re-render has settled. */
        fits.forEach(clearTimeout);
        fits = [80, 420].map((ms) => setTimeout(() => {
          const area = doc && doc.querySelector('.content-area');
          const box = host && host.getBoundingClientRect();
          if (!area || !box || box.width < 2) return;
          const scale = box.width / CX_FRAME_W;
          const want = Math.round(area.scrollHeight * scale) + 2;
          /* The panel grows with the composition, but only to the height of the
             admin list beside it — past that the two sides stop lining up and the
             section runs away down the page. A taller page scrolls in the frame. */
          const aside = listRef.current && listRef.current.parentElement;
          const cap = Math.max(420, Math.min(820, aside ? Math.round(aside.getBoundingClientRect().height) : 640));
          host.style.height = Math.max(360, Math.min(cap, want)) + 'px';
          host.classList.toggle('is-scroll', want > cap + 1);
        }, ms));
        return;
      }
      if (++tries < 100) timer = setTimeout(push, 120);
    };
    push();
    return () => { clearTimeout(timer); fits.forEach(clearTimeout); };
  }, [blocks]);

  const onDown = (e, i) => {
    if (e.button != null && e.button !== 0) return;
    // the row is wall-to-wall controls; a press on one is a click, not a drag
    if (e.target.closest && e.target.closest('button')) return;
    if (blocks[i] && blocks[i].part) return;   // the band and the strip do not move
    e.preventDefault();
    const rows = rowsRef.current;
    if (!rows[i]) return;
    if (e.currentTarget && e.currentTarget.focus) e.currentTarget.focus();
    const box = rows[i].getBoundingClientRect();
    const offset = e.clientY - box.top;
    setDrag({ from: i, to: i, y: box.top, left: box.left, width: box.width, offset });
    const onMove = (ev) => {
      if (!listRef.current) return;
      const listBox = listRef.current.getBoundingClientRect();
      // the lifted row is excluded, or it anchors `to` and upward drags stall.
      // Every other row counts, the pinned pair included: `to` ends on the last
      // row whose midpoint the pointer has passed, and skipping the two at the
      // top would leave an upward drag with nothing to resolve against. The
      // clamp below is what keeps a block out of the pinned slots.
      let to = i;
      rows.forEach((r, k) => { if (!r || k === i) return; const bx = r.getBoundingClientRect(); if (ev.clientY > bx.top + bx.height / 2) to = k; });
      const y = Math.max(listBox.top - 8, Math.min(ev.clientY - offset, listBox.bottom - box.height + 8));
      setDrag((d) => (d ? { ...d, to: Math.max(to, 2), y } : d));
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
        if (d && d.to !== d.from) setBlocks((prev) => moveAt(prev, d.from, d.to));
        return null;
      });
    };
    const onCancel = () => { stop(); setDrag(null); };
    teardown.current = () => { stop(); setDrag(null); };
    window.addEventListener('pointermove', onMove);
    window.addEventListener('pointerup', onUp);
    window.addEventListener('pointercancel', onCancel);
  };

  const patch = (i, k, v) => setBlocks((prev) => prev.map((b, j) => (j === i ? { ...b, [k]: v } : b)));
  const nudge = (i, dir) => {
    const to = i + dir;
    if (to < 2 || to >= blocks.length || blocks[i].part) return;   // rows 0-1 are the fixed parts
    setBlocks((prev) => moveAt(prev, i, to));
  };
  const shown = drag ? moveAt(blocks.map((b, i) => [b, i]), drag.from, drag.to) : blocks.map((b, i) => [b, i]);
  const movable = blocks.filter((b) => !b.part);
  const live = movable.filter((b) => b.on);

  return (
    <div className="sp-composer">
      <div className="cx-side">
        <div className="cx-head">
          <span className="tag">WHMCS admin</span>
          <span className="cap">Homepage composer</span>
          <button
            className={'cx-tour' + (step > -1 || step === -2 ? ' on' : '')}
            onClick={() => (step === -1 ? startTour() : stopTour())}
            aria-live="polite"
          >
            <i className="dot" aria-hidden="true"></i>
            {step > -1 ? TOUR[step].t : step === -2 ? 'Starting…' : 'Watch it work'}
          </button>
        </div>
        {/* the first touch anywhere in the list hands control back */}
        <div className={'cx-list' + (drag ? ' dragging' : '')} ref={listRef} onPointerDownCapture={stopTour}>
          {shown.map(([b, orig]) => {
            const lifted = drag && orig === drag.from;
            return (
              <div
                key={b.k}
                ref={(el) => { rowsRef.current[orig] = el || null; }}
                className={'cx-item' + (b.on ? '' : ' off') + (b.part ? ' pinned' : '') + (lifted ? ' lift' : '') + (hint === b.k ? ' hint' : '')}
                style={lifted ? { position: 'fixed', left: drag.left, width: drag.width, top: drag.y, zIndex: 30, margin: 0 } : undefined}
                onPointerDown={(e) => onDown(e, orig)}
                tabIndex={0}
                aria-label={b.part ? b.n + ' — a fixed part of the page' : b.n + ' — drag, or use arrow keys, to reorder'}
                onKeyDown={(e) => {
                  if (e.key === 'ArrowUp') { e.preventDefault(); nudge(orig, -1); }
                  if (e.key === 'ArrowDown') { e.preventDefault(); nudge(orig, 1); }
                }}
              >
                <div className="cx-row">
                  <span className="grip" aria-hidden="true" title={b.part ? 'Spans the row, at the top of the page' : undefined}>{[0, 1, 2].map((r) => <i key={r}></i>)}</span>
                  {settingCount(b) ? (
                    <button
                      className={'cx-dis' + (open === b.k ? ' open' : '')}
                      onClick={() => setOpen(open === b.k ? null : b.k)}
                      aria-expanded={open === b.k}
                      aria-label={(open === b.k ? 'Hide' : 'Show') + ' ' + b.n + ' settings'}
                    >›</button>
                  ) : <span className="cx-dis" aria-hidden="true"></span>}
                  <span className="cx-nm">{b.n}</span>
                  <span className="cx-w">
                    {SIZES.map(([v, label]) => (
                      <button
                        key={v}
                        onClick={() => patch(orig, 'w', v)}
                        aria-pressed={b.part ? v === 'full' : b.w === v}
                        disabled={!!b.part}
                        title={b.part ? b.n + ' always spans the row' : 'Set ' + b.n + ' to ' + label}
                      >{label}</button>
                    ))}
                  </span>
                  <span className="cx-mv">
                    <button onClick={() => nudge(orig, -1)} disabled={!!b.part} aria-label={'Move ' + b.n + ' up'}>↑</button>
                    <button onClick={() => nudge(orig, 1)} disabled={!!b.part} aria-label={'Move ' + b.n + ' down'}>↓</button>
                  </span>
                  <button className={'cx-sw' + (b.on ? ' on' : '')} onClick={() => patch(orig, 'on', !b.on)} aria-pressed={b.on} aria-label={(b.on ? 'Hide' : 'Show') + ' ' + b.n}><i></i></button>
                </div>
                {open === b.k && (
                  <div className="cx-opts">
                    <span className="ol">Style</span>
                    {FILLS.map(([v, label]) => (
                      <button key={v} className="cx-opt" onClick={() => patch(orig, 'style', v)} aria-pressed={b.style === v}>{label}</button>
                    ))}
                    <span className="ol">Colour</span>
                    <span className="cx-sws">
                      {TONES.map((t) => (
                        <button
                          key={t}
                          onClick={() => patch(orig, 'color', t)}
                          aria-pressed={b.color === t}
                          title={TONE_NAME[t]}
                          style={{ background: TONE_HEX[t] || 'var(--color-accent)' }}
                        ></button>
                      ))}
                    </span>
                    {b.k === 'hero' && <span className="ol">Size</span>}
                    {b.k === 'hero' && ['full', 'slim'].map((v) => (
                      <button key={v} className="cx-opt" onClick={() => patch(orig, 'size', v)} aria-pressed={b.size === v}>{SIZE_NAME[v]}</button>
                    ))}
                  </div>
                )}
              </div>
            );
          })}
        </div>
        <div className="cx-foot">{live.length} of {movable.length} cards shown · drag a row, or focus one and press ↑ ↓</div>
      </div>

      <div className="cx-side">
        <div className="cx-head"><span className="tag live">Client homepage</span><span className="cap">what your clients land on</span></div>
        <div className="cx-stage" ref={stageRef}>
          <ThemeFrame
            page={CA_BASE + 'clientareahome-v18.html'}
            state={frameState}
            width={CX_FRAME_W}
            alt="The Atrium dashboard, composed by the settings on the left"
            fallback={<CanvasPreview blocks={blocks} />}
          />
        </div>
      </div>
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
Object.assign(window, { MenuSpot, ComposerSpot, SeoSpot });
