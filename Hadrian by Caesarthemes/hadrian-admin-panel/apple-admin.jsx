// apple-admin.jsx — Apple-aesthetic Hadrian admin panel
// Same content as the luxe admin, restyled per the Apple style guide.

// ── Icons ────────────────────────────────────────────────────────────────
function AI({ d, size = 18, sw = 1.7, fill = 'none' }) {
  return <svg width={size} height={size} viewBox="0 0 24 24" fill={fill} stroke="currentColor" strokeWidth={sw} strokeLinecap="round" strokeLinejoin="round" dangerouslySetInnerHTML={{ __html: d }} />;
}
const AP = {
  doc: '<path d="M4 4h12a4 4 0 0 1 4 4v12H8a4 4 0 0 1-4-4z"/><path d="M4 16a4 4 0 0 1 4-4h12"/>',
  bug: '<circle cx="12" cy="13" r="5"/><path d="M12 8V5M9 6l-2-2M15 6l2-2M5 13H2M22 13h-3M7 18l-2 2M17 18l2 2"/>',
  sun: '<circle cx="12" cy="12" r="4"/><path d="M12 2v2M12 20v2M4 12H2M22 12h-2M5 5l1.5 1.5M17.5 17.5L19 19M19 5l-1.5 1.5M6.5 17.5L5 19"/>',
  moon: '<path d="M21 12.8A9 9 0 1 1 11.2 3a7 7 0 0 0 9.8 9.8z"/>',
  check: '<path d="M5 12l5 5L20 7"/>',
  up: '<path d="M12 19V5M5 12l7-7 7 7"/>',
  search: '<circle cx="11" cy="11" r="7"/><path d="M21 21l-4-4"/>',
  globe: '<circle cx="12" cy="12" r="9"/><path d="M3 12h18M12 3a15 15 0 0 1 0 18M12 3a15 15 0 0 0 0 18"/>',
};

// ── Shared primitives ────────────────────────────────────────────────────
function Toggle({ on, onChange }) {
  return (
    <button className={`ios-toggle ${on ? 'on' : ''}`} onClick={() => onChange(!on)} aria-pressed={on}>
      <span className="knob"></span>
    </button>
  );
}
// Custom styled select — themed popup list (native <option> can't be styled).
function AdmSelect({ value, onChange, options, placeholder, width = '100%' }) {
  const [open, setOpen] = React.useState(false);
  const ref = React.useRef(null);
  const opts = options.map((o) => Array.isArray(o) ? { value: o[0], label: o[1] } : (typeof o === 'string' ? { value: o, label: o } : o));
  const cur = opts.find((o) => o.value === value);
  React.useEffect(() => {
    if (!open) return;
    const onDoc = (e) => { if (ref.current && !ref.current.contains(e.target)) setOpen(false); };
    document.addEventListener('mousedown', onDoc);
    return () => document.removeEventListener('mousedown', onDoc);
  }, [open]);
  return (
    <div className="adm-cselect" ref={ref} style={{ width }}>
      <button type="button" className={`adm-cselect-btn ${open ? 'open' : ''}`} onClick={(e) => { e.stopPropagation(); setOpen((o) => !o); }}>
        <span className={cur ? '' : 'adm-cselect-ph'}>{cur ? cur.label : (placeholder || 'Select…')}</span>
        <span className="adm-cselect-chev">›</span>
      </button>
      {open && (
        <div className="adm-cselect-pop">
          {opts.map((o) => (
            <button type="button" key={o.value} className={`adm-cselect-opt ${o.value === value ? 'sel' : ''}`}
              onClick={(e) => { e.stopPropagation(); onChange(o.value); setOpen(false); }}>
              <span>{o.label}</span>
              {o.value === value && <span className="adm-cselect-check">✓</span>}
            </button>
          ))}
        </div>
      )}
    </div>
  );
}
function Badge({ children, tone = 'gray' }) { return <span className={`adm-badge ${tone}`}>{children}</span>; }
function SetRow({ title, help, control, sub }) {
  return (
    <div className="adm-setrow">
      <div style={{ flex: 1, minWidth: 0 }}>
        <div className="adm-setrow-title">{title}</div>
        {help && <div className="adm-setrow-help">{help}</div>}
        {sub && <div style={{ marginTop: 14 }}>{sub}</div>}
      </div>
      <div className="adm-setrow-ctrl">{control}</div>
    </div>
  );
}
function Section({ title, sub, tools, children }) {
  return (
    <div className="adm-section">
      {(title || tools) && (
        <div className="adm-section-head">
          <div>
            <h2 className="adm-section-title">{title}</h2>
            {sub && <div className="adm-section-sub">{sub}</div>}
          </div>
          {tools}
        </div>
      )}
      {children}
    </div>
  );
}
function PageHead({ eyebrow, title, sub, action }) {
  return (
    <div className="adm-head">
      <div className="adm-head-row">
        <div>
          {eyebrow && <div className="adm-eyebrow">{eyebrow}</div>}
          <h1 className="adm-title">{title}</h1>
          {sub && <p className="adm-sub">{sub}</p>}
        </div>
        {action}
      </div>
    </div>
  );
}
function Field({ label, hint, children }) {
  return (
    <div>
      {label && <label className="adm-label">{label}</label>}
      {children}
      {hint && <div className="adm-hint">{hint}</div>}
    </div>
  );
}

// ── INFO ─────────────────────────────────────────────────────────────────
function InfoPage() {
  const rows = [
    ['Theme Version', '1.0.0', <Badge tone="blue">Update available</Badge>],
    ['Registration Date', '14 May 2026'],
    ['Next Due Date', '14 May 2027'],
    ['Recurring Amount', '$59.00 USD / year'],
    ['Payment Method', 'Stripe'],
    ['Support & Updates', <Badge tone="green">Active</Badge>],
    ['License Key', <code className="adm-code">HDR-7K2N-X8FQ-J3LM-9YBP</code>],
    ['License Status', <Badge tone="green">Active</Badge>],
  ];
  return (
    <div>
      <PageHead eyebrow="Theme" title="Info" sub="Version, license, and subscription information for this theme." />
      <div className="adm-card">
        <Section title="Theme information">
          {rows.map((r) => (
            <div key={r[0]} className="adm-defrow">
              <div className="adm-defrow-label">{r[0]}</div>
              <div className="adm-defrow-value">{r[1]}{r[2]}</div>
            </div>
          ))}
        </Section>
      </div>
    </div>
  );
}

// ── SETTINGS ─────────────────────────────────────────────────────────────
function SaveBar({ onSave, onRestore, onCancel }) {
  const [msg, setMsg] = React.useState(null);
  const t = React.useRef(null);
  const flash = (m) => { clearTimeout(t.current); setMsg(m); t.current = setTimeout(() => setMsg(null), 2000); };
  return (
    <div className="adm-savebar">
      <button className="adm-savebar-quiet" onClick={() => { onRestore && onRestore(); flash('Defaults restored'); }}>Restore defaults</button>
      <span className="adm-savebar-div"></span>
      {msg && <span className="adm-savebar-msg">{msg}</span>}
      <button className="btn btn-outline" onClick={() => { onCancel && onCancel(); flash('Changes discarded'); }}>Cancel</button>
      <button className="btn btn-primary" onClick={() => { onSave && onSave(); flash('Saved ✓'); }}>Save changes</button>
    </div>
  );
}
function SettingsPage() {
  const [tab, setTab] = React.useState('general');
  const [s, setS] = React.useState({
    customLogoUrl: false, stickySidebars: true, gravatar: true, affixedNav: true,
    cookieBox: true, zeroAsFree: true, showStatusIcon: true, showClientId: false,
    sectionTitlesCaps: true, dynamicAjax: true, darkMode: true, topNavIcons: false,
    websiteSectionSidebar: true, orderCategorySidebar: true,
  });
  const [saved, setSaved] = React.useState(false);
  const [q, setQ] = React.useState('');
  const set = (k, v) => setS((p) => ({ ...p, [k]: v }));
  const save = () => { setSaved(true); setTimeout(() => setSaved(false), 2200); };

  const groups = [
    { id: 'brand', label: 'Branding & identity', icon: '<circle cx="13.5" cy="6.5" r="1.2"/><circle cx="17.5" cy="10.5" r="1.2"/><circle cx="8.5" cy="7.5" r="1.2"/><circle cx="6.5" cy="12.5" r="1.2"/><path d="M12 2C6.5 2 2 6.5 2 12s4.5 10 10 10c.9 0 1.6-.7 1.6-1.7 0-.4-.2-.8-.4-1.1-.3-.3-.4-.7-.4-1.1a1.6 1.6 0 0 1 1.7-1.7h2c3 0 5.5-2.5 5.5-5.6C22 6 17.5 2 12 2z"/>', items: [
      ['customLogoUrl', 'Custom Logo URL', 'Send visitors to a custom URL when they click the logo.'],
      ['gravatar', 'Gravatar Avatars', 'Show Gravatar-based avatars derived from user email.'],
      ['darkMode', 'Enable Dark Mode', 'Let visitors toggle a dark color scheme.'],
    ] },
    { id: 'nav', label: 'Navigation', icon: '<rect x="3" y="4" width="18" height="16" rx="2"/><path d="M3 9h18M9 20V9"/>', items: [
      ['affixedNav', 'Affixed Navigation', 'Pin the main navigation bar to the top when scrolling.'],
      ['stickySidebars', 'Sticky Sidebars', 'Keep sidebars pinned in view while scrolling long pages.'],
      ['topNavIcons', 'Top-Nav Icons', 'Show icons next to top-nav items.'],
    ] },
    { id: 'display', label: 'Display & formatting', icon: '<path d="M4 7V5h16v2M10 5v14M8 19h4"/><path d="M15 14v-1h5v1M17.5 13v6M16 19h3"/>', items: [
      ['sectionTitlesCaps', 'Capitalize Section Titles', 'Render section titles in uppercase.'],
      ['zeroAsFree', 'Display "0.00" as "Free"', 'Render zero-cost items with the word "Free".'],
      ['showStatusIcon', 'Show Status Icons', 'Show small status icons in product and service lists.'],
      ['showClientId', 'Show Client ID', 'Include the numeric client ID in the account dropdown.'],
    ] },
    { id: 'perf', label: 'Performance & privacy', icon: '<path d="M13 2L4.5 13H11l-1 9 8.5-11H12z"/>', items: [
      ['dynamicAjax', 'Dynamic AJAX Loading', 'Lazy-load supporting panels and lists where possible.'],
      ['cookieBox', 'Cookie Consent Box', 'Show a cookie/privacy consent banner to first-time visitors.'],
    ] },
  ];
  const matches = (t, h) => !q.trim() || (t + ' ' + h).toLowerCase().includes(q.trim().toLowerCase());
  const sidebarMatches = matches('Website Section Sidebar', 'Show the per-page section sub-nav (Account, Domain Tools, etc.) on client-area pages.');
  const noMatches = q.trim() && !sidebarMatches && groups.every((g) => !g.items.some(([k, t, h]) => matches(t, h)));
  const groupHead = { fontFamily: 'var(--font)', fontSize: 10.5, fontWeight: 700, letterSpacing: '0.1em', textTransform: 'uppercase', color: 'var(--color-text-tertiary)' };
  const GroupHead = ({ label, n, icon }) => (
    <div style={{ display: 'flex', alignItems: 'center', gap: 10, margin: '4px 0 8px' }}>
      <span style={{ width: 22, height: 22, borderRadius: 6, background: 'var(--color-accent-light)', color: 'var(--color-accent)', display: 'inline-flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0 }}>
        <AI d={icon} size={13} sw={1.8} />
      </span>
      <span style={groupHead}>{label}</span>
      <span style={{ flex: 1, height: 1, background: 'var(--color-border)' }}></span>
      <span style={{ fontFamily: 'var(--font)', fontSize: 11, color: 'var(--color-text-quaternary)' }}>{n}</span>
    </div>
  );

  return (
    <div>
      <PageHead eyebrow="Theme" title="Settings" sub="Theme-wide options. Save to apply." />
      <div className="adm-tabs">
        {[['general', 'General'], ['order', 'Order Process']].map(([id, l]) => (
          <button key={id} className={`adm-tab ${tab === id ? 'active' : ''}`} onClick={() => setTab(id)}>{l}</button>
        ))}
      </div>
      {saved && <div className="adm-alert success"><span className="adm-alert-ico"><AI d={AP.check} size={12} sw={3} /></span> Settings saved.</div>}
      {tab === 'general' && (
        <div style={{ display: 'flex', alignItems: 'center', gap: 10, background: 'var(--color-surface)', border: '1px solid var(--color-border)', borderRadius: 10, padding: '10px 14px', marginBottom: 16, maxWidth: 360, color: 'var(--color-text-tertiary)' }}>
          <AI d={AP.search} size={16} />
          <input value={q} onChange={(e) => setQ(e.target.value)} placeholder="Search settings…" style={{ flex: 1, border: 'none', outline: 'none', background: 'transparent', fontFamily: 'var(--font)', fontSize: 14, color: 'var(--color-text-primary)' }} />
          {q && <button onClick={() => setQ('')} style={{ border: 'none', background: 'transparent', cursor: 'pointer', color: 'var(--color-text-tertiary)', fontSize: 15 }}>✕</button>}
        </div>
      )}
      <div className="adm-card">
        <Section title={tab === 'general' ? 'General settings' : 'Order process settings'}>
          {tab === 'general' ? (
            <>
              {groups.map((g) => {
                const rows = g.items.filter(([k, t, h]) => matches(t, h));
                if (!rows.length) return null;
                return (
                  <div key={g.id} style={{ marginBottom: 22 }}>
                    <GroupHead label={g.label} n={rows.length} icon={g.icon} />
                    {rows.map(([k, t, h]) => <SetRow key={k} title={t} help={h} control={<Toggle on={s[k]} onChange={(v) => set(k, v)} />} />)}
                  </div>
                );
              })}
              {noMatches && (
                <div className="adm-empty"><div className="adm-empty-ico"><AI d={AP.search} size={22} /></div><div className="adm-empty-title">No settings match “{q}”</div><div className="adm-empty-text">Try a different term.</div></div>
              )}
              {sidebarMatches && <GroupHead label="Sidebars & sub-navigation" n={1} icon='<rect x="3" y="4" width="18" height="16" rx="2"/><path d="M9 4v16"/><path d="M5.5 8h1.5M5.5 11h1.5" stroke-width="1.3"/>' />}
              {sidebarMatches && <SetRow title="Website Section Sidebar" help="Show the per-page section sub-nav (Account, Domain Tools, etc.) on client-area pages." control={<Toggle on={s.websiteSectionSidebar} onChange={(v) => set('websiteSectionSidebar', v)} />} />}
              {sidebarMatches && s.websiteSectionSidebar && (
                <div style={{ display: 'flex', gap: 14, margin: '2px 0 6px', paddingLeft: 8 }}>
                  {/* connector rail */}
                  <div style={{ position: 'relative', width: 18, flexShrink: 0 }}>
                    <div style={{ position: 'absolute', left: 0, top: -10, bottom: 12, width: 2, background: 'var(--color-border)', borderRadius: 2 }}></div>
                    <div style={{ position: 'absolute', left: 0, top: 22, width: 14, height: 2, background: 'var(--color-border)', borderRadius: 2 }}></div>
                  </div>
                  <div style={{ flex: 1, minWidth: 0, background: 'var(--color-surface-secondary)', border: '1px solid var(--color-border)', borderRadius: 12, padding: 16 }}>
                    <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
                      <span style={{ fontFamily: 'var(--font)', fontSize: 10, fontWeight: 700, letterSpacing: '0.07em', textTransform: 'uppercase', color: 'var(--color-accent)', background: 'var(--color-accent-light)', padding: '3px 8px', borderRadius: 6 }}>Sub-setting</span>
                      <span style={{ fontFamily: 'var(--font)', fontSize: 14.5, fontWeight: 600, color: 'var(--color-text-primary)' }}>Per-page exceptions</span>
                    </div>
                    <div style={{ fontFamily: 'var(--font)', fontSize: 13, color: 'var(--color-text-secondary)', lineHeight: 1.55, margin: '7px 0 14px', maxWidth: 560 }}>Pages added here are exceptions — the section sub-nav is flipped on them (hidden when the toggle above is On, shown when Off). A page’s own setting in the Pages editor still wins.</div>
                    <PageChips />
                  </div>
                </div>
              )}
            </>
          ) : (
            <SetRow title="Order Category Sidebar" help="Show the Categories / Actions sidebar on cart pages." control={<Toggle on={s.orderCategorySidebar} onChange={(v) => set('orderCategorySidebar', v)} />} />
          )}
        </Section>
        <SaveBar onSave={save} />
      </div>
    </div>
  );
}

// ── LAYOUTS ──────────────────────────────────────────────────────────────
function PageChips() {
  const ALL = ['Account Dashboard', 'Profile', 'Security', 'Contacts', 'My Services', 'My Domains', 'Domain Tools', 'Billing', 'Invoices', 'Quotes', 'Support Tickets', 'Knowledgebase', 'Announcements', 'Downloads', 'Network Status', 'Affiliates'];
  const [picked, setPicked] = React.useState(['Domain Tools']);
  const [open, setOpen] = React.useState(false);
  const remaining = ALL.filter((p) => !picked.includes(p));
  return (
    <div style={{ position: 'relative', maxWidth: 560 }}>
      <div onClick={() => setOpen((o) => !o)} style={{ display: 'flex', flexWrap: 'wrap', gap: 8, alignItems: 'center', padding: '9px 12px', borderRadius: 10, border: `1px solid ${open ? 'var(--color-accent)' : 'var(--color-border)'}`, background: 'var(--color-surface)', minHeight: 44, cursor: 'pointer', boxShadow: open ? '0 0 0 4px rgba(0,113,227,0.15)' : 'none' }}>
        {picked.map((p) => (
          <span key={p} style={{ display: 'inline-flex', alignItems: 'center', gap: 6, padding: '4px 6px 4px 11px', borderRadius: 999, background: 'var(--color-accent-light)', color: 'var(--color-accent)', fontFamily: 'var(--font)', fontSize: 13, fontWeight: 600 }}>
            {p}
            <button onClick={(e) => { e.stopPropagation(); setPicked(picked.filter((x) => x !== p)); }} style={{ border: 'none', background: 'transparent', cursor: 'pointer', color: 'inherit', fontSize: 15, lineHeight: 1, padding: '0 2px' }}>×</button>
          </span>
        ))}
        <span style={{ fontFamily: 'var(--font)', fontSize: 13.5, color: 'var(--color-text-tertiary)' }}>{picked.length ? '+ add page' : 'Click to add pages…'}</span>
      </div>
      {open && (
        <div style={{ position: 'absolute', top: 'calc(100% + 6px)', left: 0, right: 0, zIndex: 20, maxHeight: 240, overflowY: 'auto', background: 'var(--color-surface)', border: '1px solid var(--color-border)', borderRadius: 12, boxShadow: '0 12px 32px rgba(0,0,0,0.16)', padding: 6 }}>
          {remaining.length === 0 ? <div style={{ fontFamily: 'var(--font)', fontSize: 13, color: 'var(--color-text-tertiary)', padding: '9px 12px' }}>All pages added.</div> : remaining.map((p) => (
            <button key={p} onClick={() => { setPicked([...picked, p]); setOpen(false); }} style={{ display: 'block', width: '100%', textAlign: 'left', border: 'none', background: 'transparent', cursor: 'pointer', padding: '9px 12px', borderRadius: 8, fontFamily: 'var(--font)', fontSize: 14, color: 'var(--color-text-primary)' }}
              onMouseEnter={(e) => (e.currentTarget.style.background = 'var(--color-surface-secondary)')} onMouseLeave={(e) => (e.currentTarget.style.background = 'transparent')}>{p}</button>
          ))}
        </div>
      )}
    </div>
  );
}
function Wire({ kind, active }) {
  const ink = active ? 'var(--color-accent)' : 'rgba(120,120,128,0.45)';
  const bg = active ? 'rgba(0,113,227,0.06)' : 'var(--color-surface-secondary)';
  const W = 150, H = 86;
  const f = (c) => <svg className="wire" width={W} height={H} viewBox={`0 0 ${W} ${H}`} style={{ background: bg }}>{c}</svg>;
  switch (kind) {
    case 'topnav': return f(<><rect x="0" y="0" width={W} height="16" fill={ink} /><rect x="8" y="6" width="20" height="4" rx="2" fill="#fff" opacity="0.9" /><rect x="66" y="6" width="12" height="4" rx="2" fill="#fff" opacity="0.55" /><rect x="82" y="6" width="12" height="4" rx="2" fill="#fff" opacity="0.55" /><rect x="14" y="26" width="64" height="6" rx="3" fill={ink} opacity="0.45" /><rect x="14" y="40" width="122" height="34" rx="5" fill={ink} opacity="0.13" /></>);
    case 'sidebar': return f(<><rect x="0" y="0" width="38" height={H} fill={ink} /><rect x="7" y="9" width="24" height="5" rx="2" fill="#fff" opacity="0.9" /><rect x="7" y="24" width="24" height="4" rx="2" fill="#fff" opacity="0.5" /><rect x="7" y="33" width="24" height="4" rx="2" fill="#fff" opacity="0.5" /><rect x="48" y="14" width="56" height="6" rx="3" fill={ink} opacity="0.45" /><rect x="48" y="28" width="90" height="46" rx="5" fill={ink} opacity="0.13" /></>);
    case 'iconrail': return f(<><rect x="0" y="0" width="18" height={H} fill={ink} /><circle cx="9" cy="13" r="4" fill="#fff" opacity="0.9" /><circle cx="9" cy="30" r="3" fill="#fff" opacity="0.5" /><circle cx="9" cy="43" r="3" fill="#fff" opacity="0.5" /><rect x="30" y="14" width="56" height="6" rx="3" fill={ink} opacity="0.45" /><rect x="30" y="28" width="106" height="46" rx="5" fill={ink} opacity="0.13" /></>);
    case 'extended': return f(<><rect x="0" y="0" width={W} height="16" fill={ink} /><rect x="8" y="6" width="20" height="4" rx="2" fill="#fff" opacity="0.9" /><rect x="0" y="16" width="50" height={H - 16} fill={ink} opacity="0.18" /><rect x="8" y="26" width="34" height="4" rx="2" fill={ink} opacity="0.4" /><rect x="8" y="35" width="34" height="4" rx="2" fill={ink} opacity="0.25" /><rect x="62" y="28" width="76" height="46" rx="5" fill={ink} opacity="0.13" /></>);
    case 'footer-default': return f(<><rect x="16" y="10" width="118" height="30" rx="5" fill={ink} opacity="0.11" /><rect x="0" y="52" width={W} height={H - 52} fill={ink} /><rect x="12" y="61" width="26" height="4" rx="2" fill="#fff" opacity="0.85" /><rect x="12" y="69" width="20" height="3" rx="1.5" fill="#fff" opacity="0.45" /><rect x="100" y="61" width="38" height="3" rx="1.5" fill="#fff" opacity="0.4" /></>);
    case 'footer-minimal': return f(<><rect x="16" y="10" width="118" height="44" rx="5" fill={ink} opacity="0.11" /><rect x="0" y="66" width={W} height={H - 66} fill={ink} /><rect x="12" y="74" width="24" height="4" rx="2" fill="#fff" opacity="0.85" /><rect x="104" y="74" width="34" height="4" rx="2" fill="#fff" opacity="0.4" /></>);
    case 'footer-columns': return f(<><rect x="16" y="10" width="118" height="22" rx="5" fill={ink} opacity="0.11" /><rect x="0" y="40" width={W} height={H - 40} fill={ink} />{[12, 46, 80, 114].map((x) => <g key={x}><rect x={x} y="49" width="18" height="3" rx="1.5" fill="#fff" opacity="0.8" /><rect x={x} y="57" width="16" height="2.5" rx="1" fill="#fff" opacity="0.4" /><rect x={x} y="63" width="16" height="2.5" rx="1" fill="#fff" opacity="0.4" /><rect x={x} y="69" width="16" height="2.5" rx="1" fill="#fff" opacity="0.4" /></g>)}</>);
    default: return f(null);
  }
}
function Picker({ options, value, onChange, cols, onPreview }) {
  return (
    <div className="adm-picker" style={{ gridTemplateColumns: `repeat(${cols}, 1fr)` }}>
      {options.map((o) => (
        <div key={o.id} className={`adm-picker-card ${value === o.id ? 'active' : ''}`} onClick={() => onChange(o.id)} style={{ cursor: 'pointer' }}>
          <Wire kind={o.wire} active={value === o.id} />
          <div className="adm-picker-meta">
            <div>
              <div className="adm-picker-name">{o.label}</div>
              <div className="adm-picker-sub">{o.sub}</div>
            </div>
            <span className="adm-radio">{value === o.id && <AI d={AP.check} size={10} sw={3.5} fill="none" />}</span>
          </div>
          {onPreview && <button onClick={(e) => { e.stopPropagation(); onPreview(o.id); }} className="adm-preview-btn">◱ Live preview ↗</button>}
        </div>
      ))}
    </div>
  );
}
function LayoutActivatePicker({ options, guest, client, align, onActivate, onAlign, onPreview }) {
  const Row = ({ id, aud, label, on }) => (
    <button onClick={(e) => { e.stopPropagation(); onActivate(aud, id); }} disabled={on}
      style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', width: '100%', padding: '7px 10px', borderRadius: 8, border: 'none', cursor: on ? 'default' : 'pointer', background: on ? 'var(--color-accent-light)' : 'var(--color-surface-secondary)', fontFamily: 'var(--font)', marginTop: 6 }}>
      <span style={{ fontSize: 12.5, fontWeight: 600, color: on ? 'var(--color-accent)' : 'var(--color-text-secondary)' }}>{label}</span>
      {on
        ? <span className="adm-badge green">Active</span>
        : <span style={{ fontSize: 12, fontWeight: 600, color: 'var(--color-text-tertiary)' }}>Activate</span>}
    </button>
  );
  return (
    <div className="adm-picker" style={{ gridTemplateColumns: 'repeat(3, 1fr)' }}>
      {options.map((o) => {
        const isG = guest === o.id, isC = client === o.id;
        const isTop = o.id === 'topnav';
        const showAlign = isG || isC;
        const aligns = isTop ? [['center', 'Center']] : [['left', 'Left'], ['center', 'Center']];
        const alignVal = isTop ? 'center' : align;
        return (
          <div key={o.id} className={`adm-picker-card ${(isG || isC) ? 'active' : ''}`} style={{ cursor: 'default' }}>
            <Wire kind={o.wire} active={isG || isC} />
            <div className="adm-picker-meta" style={{ display: 'block' }}>
              <div className="adm-picker-name">{o.label}</div>
              <div className="adm-picker-sub">{o.sub}</div>
              <Row id={o.id} aud="guest" label="Guest client" on={isG} />
              <Row id={o.id} aud="client" label="Existing client" on={isC} />
              {showAlign && (
                <div style={{ marginTop: 8, paddingTop: 8, borderTop: '1px solid var(--color-border)' }}>
                  <div style={{ fontSize: 11, fontWeight: 600, color: 'var(--color-text-tertiary)', marginBottom: 6 }}>Content alignment</div>
                  <div style={{ display: 'flex', background: 'var(--color-surface-secondary)', padding: 3, borderRadius: 8, gap: 3 }}>
                    {aligns.map(([aid, l]) => (
                      <button key={aid} onClick={(e) => { e.stopPropagation(); if (!isTop) onAlign(aid); }} style={{ flex: 1, padding: '6px 0', fontSize: 12, fontWeight: 600, border: 'none', borderRadius: 6, cursor: isTop ? 'default' : 'pointer', fontFamily: 'var(--font)', background: alignVal === aid ? 'var(--color-surface)' : 'transparent', color: alignVal === aid ? 'var(--color-accent)' : 'var(--color-text-secondary)', boxShadow: alignVal === aid ? '0 1px 3px rgba(0,0,0,0.08)' : 'none' }}>{l}</button>
                    ))}
                  </div>
                </div>
              )}
              <button onClick={(e) => { e.stopPropagation(); onPreview(o.id); }} className="adm-preview-btn" style={{ marginTop: 8 }}>◱ Live preview ↗</button>
            </div>
          </div>
        );
      })}
    </div>
  );
}
function LayoutsPage() {
  const [s, setS] = React.useState({ menuGuest: 'topnav', menuClient: 'sidebar', contentAlign: 'left', footer: 'footer-columns', contentWidth: 'boxed', stickyHeader: true, headerSearch: true, headerLang: true, headerCurrency: false, breadcrumbs: true, sidebarPos: 'left', sidebarSticky: true, backToTop: true, newsletter: false, social: true });
  const [saved, setSaved] = React.useState(false);
  const [tab, setTab] = React.useState('menu');
  const [preview, setPreview] = React.useState(null); // {mode, id}
  const openLivePreview = (mode, id) => {
    const base = 'https://demo.caesarthemes.com/hadrian';
    const url = `${base}?preview=1&${mode === 'menu' ? 'menu' : 'footer'}=${id}${mode === 'menu' ? `&align=${s.contentAlign}&sidebar=${s.sidebarPos}` : ''}`;
    window.open(url, '_blank', 'noopener');
  };
  const set = (k, v) => setS((p) => ({ ...p, [k]: v }));
  const save = () => { setSaved(true); setTimeout(() => setSaved(false), 2200); };
  const menuOpts = [
    { id: 'topnav', wire: 'topnav', label: 'Top Nav', sub: 'Horizontal bar' },
    { id: 'sidebar', wire: 'sidebar', label: 'Sidebar', sub: 'Left rail' },
    { id: 'iconrail', wire: 'iconrail', label: 'Icon Rail', sub: 'Compact icons' },
  ];
  const footerOpts = [
    { id: 'footer-default', wire: 'footer-default', label: 'Default', sub: 'Logo + links' },
    { id: 'footer-minimal', wire: 'footer-minimal', label: 'Minimal', sub: 'One line' },
    { id: 'footer-columns', wire: 'footer-columns', label: 'Columns', sub: 'Multi-column' },
  ];
  return (
    <div>
      <PageHead eyebrow="Theme" title="Layouts" sub="Choose how Hadrian arranges navigation, header, sidebar, and footer." />
      {saved && <div className="adm-alert success"><span className="adm-alert-ico"><AI d={AP.check} size={12} sw={3} /></span> Layout settings applied.</div>}
      <div className="adm-tabs">
        {[['menu', 'Main menu'], ['footer', 'Footer']].map(([id, l]) => <button key={id} className={`adm-tab ${tab === id ? 'active' : ''}`} onClick={() => setTab(id)}>{l}</button>)}
      </div>
      <div className="adm-card">
        {tab === 'menu' && <>
        <Section title="Main menu" sub="Serve a different navigation layout to guests and signed-in clients. Activate one per status.">
          <LayoutActivatePicker options={menuOpts} guest={s.menuGuest} client={s.menuClient} align={s.contentAlign} onActivate={(aud, id) => set(aud === 'guest' ? 'menuGuest' : 'menuClient', id)} onAlign={(v) => set('contentAlign', v)} onPreview={(id) => openLivePreview('menu', id)} />
        </Section>
        <Section title="Header">
          <SetRow title="Sticky header" help="Keep the header pinned to the top while scrolling." control={<Toggle on={s.stickyHeader} onChange={(v) => set('stickyHeader', v)} />} />
          <SetRow title="Search in header" help="Show a global search field in the header bar." control={<Toggle on={s.headerSearch} onChange={(v) => set('headerSearch', v)} />} />
          <SetRow title="Language switcher" help="Expose the language selector in the header." control={<Toggle on={s.headerLang} onChange={(v) => set('headerLang', v)} />} />
          <SetRow title="Currency selector" help="Let clients change display currency from the header." control={<Toggle on={s.headerCurrency} onChange={(v) => set('headerCurrency', v)} />} />
          <SetRow title="Breadcrumbs" help="Show a breadcrumb trail beneath the header on inner pages." control={<Toggle on={s.breadcrumbs} onChange={(v) => set('breadcrumbs', v)} />} />
        </Section>
        <Section title="Sidebar" sub="Applies when a sidebar-based menu is active.">
          <div className="adm-field-grid" style={{ marginBottom: 6 }}>
            <Field label="Position"><select className="adm-select" value={s.sidebarPos} onChange={(e) => set('sidebarPos', e.target.value)}><option value="left">Left</option><option value="right">Right</option></select></Field>
            <Field label="Default state"><select className="adm-select"><option>Collapsible</option><option>Always expanded</option></select></Field>
          </div>
          <SetRow title="Sticky sidebar" help="Pin the sidebar in view while the page scrolls." control={<Toggle on={s.sidebarSticky} onChange={(v) => set('sidebarSticky', v)} />} />
        </Section>
        <Section title="Containers">
          <Field label="Content width" hint="Boxed keeps long-form pages readable; full width suits data-dense dashboards.">
            <select className="adm-select" value={s.contentWidth} onChange={(e) => set('contentWidth', e.target.value)}>
              <option value="boxed">Boxed — centered, max 1200px</option>
              <option value="full">Full width — use the whole viewport</option>
              <option value="fluid">Fluid — padded but unbounded</option>
            </select>
          </Field>
        </Section>
        </>}
        {tab === 'footer' && <>
        <Section title="Footer" sub="The footer layout used across the client area.">
          <Picker options={footerOpts} value={s.footer} onChange={(v) => set('footer', v)} cols={3} onPreview={(id) => openLivePreview('footer', id)} />
          <div style={{ marginTop: 16 }}>
            <SetRow title="Back-to-top button" help="Show a floating button to scroll back to the top." control={<Toggle on={s.backToTop} onChange={(v) => set('backToTop', v)} />} />
            <SetRow title="Newsletter signup" help="Include an email-capture field in the footer." control={<Toggle on={s.newsletter} onChange={(v) => set('newsletter', v)} />} />
            <SetRow title="Social links" help="Render social icons from your Branding settings." control={<Toggle on={s.social} onChange={(v) => set('social', v)} />} />
          </div>
        </Section>
        </>}
        <SaveBar onSave={save} />
      </div>
      {preview && null}
    </div>
  );
}

function LayoutPreviewModal({ mode, layoutId, s, menuOpts, footerOpts, onClose }) {
  const [aud, setAud] = React.useState('client');
  const menuKind = mode === 'menu' ? layoutId : ((aud === 'guest' ? s.menuGuest : s.menuClient) || 'topnav');
  const footKind = mode === 'footer' ? layoutId : (s.footer || 'footer-default');
  const label = (opts, id) => (opts.find((o) => o.id === id) || {}).label || id;
  React.useEffect(() => {
    const onKey = (e) => e.key === 'Escape' && onClose();
    document.addEventListener('keydown', onKey);
    return () => document.removeEventListener('keydown', onKey);
  }, []);
  const bar = { display: 'flex', alignItems: 'center', gap: 8, padding: '10px 14px', background: 'var(--color-accent)' };
  const navItem = (op) => <span style={{ height: 8, borderRadius: 4, background: '#fff', opacity: op, display: 'block' }}></span>;

  // Frame content built from the active layouts
  const isSidebar = menuKind === 'sidebar' || menuKind === 'iconrail' || menuKind === 'extended';
  const railW = menuKind === 'iconrail' ? 56 : 210;
  const contentBox = (
    <div style={{ flex: 1, minWidth: 0, padding: 22, background: 'var(--color-bg)', display: 'flex', flexDirection: 'column', gap: 14, alignItems: s.contentAlign === 'center' && !isSidebar ? 'center' : 'stretch' }}>
      <div style={{ width: s.contentAlign === 'center' && !isSidebar ? '70%' : '40%', height: 14, borderRadius: 5, background: 'var(--color-text-primary)', opacity: 0.16 }}></div>
      <div style={{ display: 'flex', gap: 12, width: s.contentAlign === 'center' && !isSidebar ? '82%' : '100%' }}>
        {[0, 1, 2].map((i) => <div key={i} style={{ flex: 1, height: 74, borderRadius: 10, background: 'var(--color-surface)', border: '1px solid var(--color-border)' }}></div>)}
      </div>
      <div style={{ height: 120, borderRadius: 10, background: 'var(--color-surface)', border: '1px solid var(--color-border)', width: s.contentAlign === 'center' && !isSidebar ? '82%' : '100%' }}></div>
    </div>
  );

  return (
    <div onClick={onClose} style={{ position: 'fixed', inset: 0, zIndex: 200, background: 'rgba(0,0,0,0.45)', backdropFilter: 'blur(4px)', display: 'flex', alignItems: 'center', justifyContent: 'center', padding: 32 }}>
      <div onClick={(e) => e.stopPropagation()} style={{ width: 'min(920px, 96vw)', maxHeight: '90vh', overflow: 'hidden', background: 'var(--color-surface)', borderRadius: 18, boxShadow: '0 30px 80px rgba(0,0,0,0.4)', display: 'flex', flexDirection: 'column' }}>
        {/* modal head */}
        <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', padding: '16px 20px', borderBottom: '1px solid var(--color-border)' }}>
          <div>
            <div style={{ fontFamily: 'var(--font)', fontSize: 16, fontWeight: 600, color: 'var(--color-text-primary)' }}>Live preview</div>
            <div style={{ fontFamily: 'var(--font)', fontSize: 12.5, color: 'var(--color-text-tertiary)', marginTop: 2 }}>
              {mode === 'menu' ? `Menu: ${label(menuOpts, menuKind)} · content ${s.contentAlign}` : `Footer: ${label(footerOpts, footKind)}`}
            </div>
          </div>
          <div style={{ display: 'flex', gap: 10, alignItems: 'center' }}>
            <button onClick={onClose} style={{ width: 32, height: 32, borderRadius: '50%', border: '1px solid var(--color-border)', background: 'var(--color-surface)', cursor: 'pointer', color: 'var(--color-text-secondary)', fontSize: 16 }}>×</button>
          </div>
        </div>
        {/* browser mock */}
        <div style={{ padding: 20, overflow: 'auto', background: 'var(--color-surface-secondary)' }}>
          <div style={{ borderRadius: 12, overflow: 'hidden', border: '1px solid var(--color-border)', background: 'var(--color-bg)', boxShadow: '0 8px 30px rgba(0,0,0,0.12)' }}>
            <div style={{ display: 'flex', alignItems: 'center', gap: 6, padding: '9px 12px', background: 'var(--color-surface)', borderBottom: '1px solid var(--color-border)' }}>
              {['#ff5f57', '#febc2e', '#28c840'].map((c) => <span key={c} style={{ width: 10, height: 10, borderRadius: '50%', background: c }}></span>)}
              <div style={{ marginLeft: 10, flex: 1, height: 18, borderRadius: 5, background: 'var(--color-surface-secondary)' }}></div>
            </div>
            {/* top nav */}
            {menuKind === 'topnav' && (
              <div style={bar}>
                <div style={{ width: 60, height: 10, borderRadius: 4, background: '#fff' }}></div>
                <div style={{ flex: 1 }}></div>
                <div style={{ width: 44 }}>{navItem(0.9)}</div><div style={{ width: 44 }}>{navItem(0.6)}</div><div style={{ width: 44 }}>{navItem(0.6)}</div>
              </div>
            )}
            <div style={{ display: 'flex', minHeight: 250 }}>
              {isSidebar && (
                <div style={{ width: railW, background: 'var(--color-accent)', padding: menuKind === 'iconrail' ? '16px 0' : 16, display: 'flex', flexDirection: 'column', alignItems: menuKind === 'iconrail' ? 'center' : 'stretch', gap: 12, order: s.sidebarPos === 'right' ? 2 : 0 }}>
                  {menuKind === 'iconrail'
                    ? [0.95, 0.6, 0.6, 0.6].map((o, i) => <span key={i} style={{ width: 22, height: 22, borderRadius: 7, background: '#fff', opacity: o }}></span>)
                    : <><div style={{ width: 90, height: 11, borderRadius: 4, background: '#fff' }}></div>{[0.6, 0.6, 0.6, 0.6].map((o, i) => <div key={i} style={{ width: '78%', height: 8, borderRadius: 4, background: '#fff', opacity: o }}></div>)}</>}
                </div>
              )}
              {contentBox}
            </div>
            {/* footer */}
            <div style={{ background: 'var(--color-text-primary)', padding: footKind === 'footer-minimal' ? '16px 20px' : '22px 20px' }}>
              {footKind === 'footer-columns' ? (
                <div style={{ display: 'flex', gap: 30 }}>{[0, 1, 2, 3].map((c) => <div key={c} style={{ flex: 1, display: 'flex', flexDirection: 'column', gap: 7 }}><div style={{ width: '60%', height: 7, borderRadius: 3, background: '#fff', opacity: 0.85 }}></div>{[0.4, 0.4, 0.4].map((o, i) => <div key={i} style={{ width: '80%', height: 5, borderRadius: 2, background: '#fff', opacity: o }}></div>)}</div>)}</div>
              ) : footKind === 'footer-minimal' ? (
                <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}><div style={{ width: 80, height: 8, borderRadius: 3, background: '#fff', opacity: 0.85 }}></div><div style={{ width: 120, height: 6, borderRadius: 3, background: '#fff', opacity: 0.4 }}></div></div>
              ) : (
                <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start' }}><div style={{ display: 'flex', flexDirection: 'column', gap: 6 }}><div style={{ width: 70, height: 8, borderRadius: 3, background: '#fff', opacity: 0.85 }}></div><div style={{ width: 110, height: 5, borderRadius: 2, background: '#fff', opacity: 0.4 }}></div></div><div style={{ width: 140, height: 6, borderRadius: 3, background: '#fff', opacity: 0.4 }}></div></div>
              )}
            </div>
          </div>
          <div style={{ textAlign: 'center', fontFamily: 'var(--font)', fontSize: 12, color: 'var(--color-text-tertiary)', marginTop: 12 }}>Simplified preview · reflects the active {mode === 'menu' ? 'menu layout, content alignment, and sidebar position' : 'footer layout'}.</div>
        </div>
      </div>
    </div>
  );
}

// ── BRANDING ─────────────────────────────────────────────────────────────
function UploadTile({ label, variant, filled }) {
  return (
    <Field label={label}>
      <div className={`adm-upload ${filled ? 'filled' : ''}`}>
        {filled ? (
          <div style={{ display: 'flex', alignItems: 'center', gap: 12 }}>
            <span className="brand-mark" style={{ width: 40, height: 40, borderRadius: 10 }}></span>
            <span style={{ fontSize: 19, fontWeight: 600, letterSpacing: '-0.01em', color: 'var(--color-text-primary)' }}>Hadrian</span>
          </div>
        ) : (
          <div className="adm-upload-empty">
            <div className="adm-upload-ico"><AI d={AP.up} size={18} /></div>
            <div style={{ fontSize: 13, fontWeight: 600, color: 'var(--color-text-secondary)' }}>Click to upload</div>
            <div style={{ fontSize: 11, color: 'var(--color-text-tertiary)', marginTop: 3 }}>{variant}</div>
          </div>
        )}
      </div>
    </Field>
  );
}
function BrandingPage() {
  return (
    <div>
      <PageHead eyebrow="Theme" title="Branding" sub="Upload your logo and favicon. Each file is saved the moment you pick it." />
      <div className="adm-card">
        <Section title="Logo" sub="Used in the top-left of the client area. Provide light and dark versions.">
          <div className="adm-field-grid">
            <UploadTile label="Primary logo" variant="SVG / PNG · max 1 MB" filled />
            <UploadTile label="Inverted logo" variant="for dark backgrounds" filled />
          </div>
        </Section>
        <Section title="Favicon" sub="Browser-tab icon. A square 32×32 PNG works best.">
          <div style={{ display: 'grid', gridTemplateColumns: 'repeat(3,1fr)', gap: 18 }}>
            <UploadTile label="Favicon" variant="PNG / ICO · max 64 KB" filled />
            <UploadTile label="Apple touch icon" variant="180 × 180 PNG" />
            <UploadTile label="Email header logo" variant="600px wide PNG" />
          </div>
        </Section>
        <Section title="Brand info" sub="Used in footer, meta tags, and social cards.">
          <Field label="Footer description">
            <textarea className="adm-textarea" rows={3} defaultValue="Hadrian is a premium WHMCS client area theme — refined typography, modular layouts, and a dashboard built for clarity."></textarea>
          </Field>
          <div className="adm-field-grid" style={{ marginTop: 18 }}>
            <Field label="Website URL"><input className="adm-input" defaultValue="https://caesarthemes.com" /></Field>
            <Field label="Support email"><input className="adm-input" defaultValue="support@caesarthemes.com" /></Field>
            <Field label="Twitter / X"><input className="adm-input" defaultValue="https://x.com/caesarthemes" /></Field>
            <Field label="GitHub"><input className="adm-input" defaultValue="https://github.com/caesarthemes" /></Field>
          </div>
        </Section>
        <SaveBar />
      </div>
    </div>
  );
}

// ── TOOLS ────────────────────────────────────────────────────────────────
function ToolsPage() {
  const [flash, setFlash] = React.useState(null);
  const tools = [
    ['Clear template cache', 'Recompile Smarty templates on the next request.', 'Clear'],
    ['Refresh menu cache', 'Rebuild menu structure from the database.', 'Refresh'],
    ['Rebuild pages discovery', 'Re-scan core/pages/ for new page modules.', 'Rebuild'],
    ['Refresh license', 'Force a license-server callback to revalidate.', 'Refresh'],
    ['Generate Nginx / .htaccess rules', 'Build SEO redirect rules for your server config.', 'Generate'],
  ];
  return (
    <div>
      <PageHead eyebrow="Theme" title="Tools" sub="Operational utilities — cache flush, license refresh, htaccess generation." />
      {flash && <div className="adm-alert success"><span className="adm-alert-ico"><AI d={AP.check} size={12} sw={3} /></span> {flash}</div>}
      <div className="adm-card">
        <Section title="Maintenance">
          {tools.map(([t, h, b]) => <SetRow key={t} title={t} help={h} control={<button className="btn btn-outline" onClick={() => setFlash(`${t} completed successfully.`)}>{b}</button>} />)}
        </Section>
      </div>
    </div>
  );
}

function MenuPage({ open, embed }) {
  const [tab, setTab] = React.useState('main');
  const [saved, setSaved] = React.useState(false);
  const [items, setItems] = React.useState([
    { id: 1, type: 'page', label: 'Dashboard', depth: 0, visible: true },
    { id: 2, type: 'dropdown', label: 'Services', depth: 0, visible: true },
    { id: 21, type: 'page', label: 'My services', depth: 1, visible: true },
    { id: 22, type: 'page', label: 'Order new', depth: 1, visible: true },
    { id: 3, type: 'page', label: 'Domains', depth: 0, visible: true },
    { id: 4, type: 'page', label: 'Billing', depth: 0, visible: true },
    { id: 5, type: 'link', label: 'Support center', depth: 0, visible: true },
    { id: 6, type: 'divider', label: '', depth: 0, visible: true },
    { id: 7, type: 'account', label: 'My account', depth: 0, visible: true },
  ]);
  const [audience, setAudience] = React.useState('client');
  const [active, setActive] = React.useState(true);
  const allMenus = [
    { id: 1, loc: 'main', name: 'Primary client navigation', audience: 'client', items: items.length, active: true },
    { id: 2, loc: 'main', name: 'Guest navigation', audience: 'guest', items: 6, active: true },
    { id: 3, loc: 'main', name: 'Reseller navigation', audience: 'client', items: 9, active: false },
    { id: 4, loc: 'secondary', name: 'Account dropdown', audience: 'client', items: 7, active: true },
    { id: 5, loc: 'secondary', name: 'Top-bar links', audience: 'all', items: 3, active: false },
    { id: 6, loc: 'footer', name: 'Footer · Company', audience: 'all', items: 4, active: true },
    { id: 7, loc: 'footer', name: 'Footer · Legal', audience: 'all', items: 5, active: true },
    { id: 8, loc: 'footer', name: 'Footer · Guest', audience: 'guest', items: 3, active: false },
  ];
  const menus = allMenus.filter((m) => m.loc === tab);
  /* `open` comes from the #menu/<id> route, so the item editor can be linked to
     directly -- the landing page embeds it that way to show the tree. Absent, it
     opens on the menus list exactly as before. */
  const [selectedMenu, setSelectedMenu] = React.useState(open ? Number(open) : null);
  const selMenu = allMenus.find((m) => m.id === selectedMenu);
  const audClass = (a) => a === 'guest' ? 'orange' : a === 'all' ? 'gray' : 'blue';
  const audLabel = (a) => a === 'guest' ? 'Guest' : a === 'all' ? 'All' : 'Client';
  const [newType, setNewType] = React.useState('page');
  const [expanded, setExpanded] = React.useState(null);
  const updateItem = (id, key, value) => setItems((arr) => arr.map((it) => it.id === id ? { ...it, [key]: value } : it));

  const tones = { page: 'blue', link: 'gray', dropdown: 'orange', header: 'gray', divider: 'gray', account: 'blue' };
  const labels = { page: 'Page', link: 'Link', dropdown: 'Dropdown', header: 'Header', divider: 'Divider', account: 'Account' };

  const setVisible = (id, v) => setItems(items.map((it) => it.id === id ? { ...it, visible: v } : it));
  const remove = (id) => setItems(items.filter((it) => it.id !== id));
  const move = (i, dir) => {
    const j = i + dir;
    if (j < 0 || j >= items.length) return;
    const next = items.slice();
    [next[i], next[j]] = [next[j], next[i]];
    setItems(next);
  };
  const [dragIdx, setDragIdx] = React.useState(null);
  const [overIdx, setOverIdx] = React.useState(null);
  const onDrop = () => {
    if (dragIdx === null || overIdx === null || dragIdx === overIdx) { setDragIdx(null); setOverIdx(null); return; }
    const next = items.slice();
    const [moved] = next.splice(dragIdx, 1);
    // drop before the row we're hovering; account for removal shift
    let target = overIdx;
    if (dragIdx < overIdx) target -= 1;
    next.splice(target, 0, moved);
    setItems(next);
    setDragIdx(null); setOverIdx(null);
  };
  const addTop = () => { const item = { id: Date.now(), type: 'page', label: 'New page', depth: 0, visible: true }; setItems([...items, item]); setExpanded(item.id); };
  const addChildAfter = (i) => { const item = { id: Date.now(), type: 'page', label: 'New page', depth: 1, visible: true }; const next = items.slice(); next.splice(i + 1, 0, item); setItems(next); setExpanded(item.id); };
  const addBtnStyle = (depth) => ({ marginLeft: depth * 24, width: `calc(100% - ${depth * 24}px)`, display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 7, padding: '9px 12px', borderRadius: 10, border: '1px dashed var(--color-border)', background: 'transparent', cursor: 'pointer', fontFamily: 'var(--font)', fontSize: 13, fontWeight: 600, color: 'var(--color-accent)' });
  const save = () => { setSaved(true); setTimeout(() => setSaved(false), 2200); };

  const tabs = [{ id: 'main', label: 'Main' }, { id: 'secondary', label: 'Secondary' }, { id: 'footer', label: 'Footer' }];

  return (
    <div>
      {!selMenu && <PageHead eyebrow="Theme" title="Menu" sub="Build navigation menus and assign them to client or guest audiences — no hooks, no template edits." />}
      {selMenu && !embed && (
        <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', padding: '8px 0 4px' }}>
          <button onClick={() => setSelectedMenu(null)} style={{ background: 'none', border: 'none', cursor: 'pointer', color: 'var(--color-text-secondary)', fontFamily: 'var(--font)', fontSize: 14, fontWeight: 500 }}>‹ Menus</button>
          <SaveBar onSave={save} />
        </div>
      )}
      {selMenu && !embed && <PageHead eyebrow={`${selMenu.loc === 'main' ? 'Main' : selMenu.loc === 'secondary' ? 'Secondary' : 'Footer'} menu · ${audLabel(selMenu.audience)}`} title={selMenu.name} sub="Drag to reorder · expand an item to edit it." />}
      {!selMenu && (
        <div className="adm-tabs">
          {tabs.map((t) => <button key={t.id} className={`adm-tab ${tab === t.id ? 'active' : ''}`} onClick={() => setTab(t.id)}>{t.label}</button>)}
        </div>
      )}
      {saved && <div className="adm-alert success"><span className="adm-alert-ico"><AI d={AP.check} size={12} sw={3} /></span> Menu saved.</div>}

      {/* menus list */}
      {!selMenu && (
      <div className="adm-card pad">
        <Section title="Menus" sub="One active menu per audience. Inactive menus stay saved for later."
          tools={<button className="btn btn-primary" style={{ padding: '7px 16px', fontSize: 13 }}>+ New menu</button>}>
          <div style={{ display: 'grid', gridTemplateColumns: '1fr 110px 70px 90px', gap: 14, alignItems: 'center', padding: '0 14px 8px' }}>
            {['Menu', 'Audience', 'Items', 'Status'].map((h) => <span key={h} style={{ fontFamily: 'var(--font)', fontSize: 10, fontWeight: 700, letterSpacing: '0.1em', textTransform: 'uppercase', color: 'var(--color-text-quaternary)' }}>{h}</span>)}
          </div>
          <div style={{ display: 'flex', flexDirection: 'column', gap: 6 }}>
            {menus.map((m) => (
              <div key={m.id} onClick={() => setSelectedMenu(m.id)} style={{
                display: 'grid', gridTemplateColumns: '1fr 110px 70px 90px', gap: 14, alignItems: 'center',
                padding: '12px 14px', borderRadius: 10, cursor: 'pointer',
                background: 'var(--color-surface)', border: '1px solid var(--color-border)',
              }}
                onMouseEnter={(e) => { e.currentTarget.style.background = 'var(--color-surface-secondary)'; }}
                onMouseLeave={(e) => { e.currentTarget.style.background = 'var(--color-surface)'; }}>
                <span style={{ fontFamily: 'var(--font)', fontSize: 14, fontWeight: 600, color: 'var(--color-text-primary)' }}>{m.name}</span>
                <span><span className={`adm-badge ${audClass(m.audience)}`}>{audLabel(m.audience)}</span></span>
                <span style={{ fontFamily: 'var(--font)', fontSize: 13, color: 'var(--color-text-secondary)' }}>{m.items}</span>
                <span><span className={`adm-badge ${m.active ? 'green' : 'gray'}`}>{m.active ? 'Active' : 'Disabled'}</span></span>
              </div>
            ))}
          </div>
        </Section>
      </div>
      )}

      {selMenu && (
      <div style={{ display: 'grid', gridTemplateColumns: embed ? '1fr' : '1fr 300px', gap: 20, alignItems: 'start' }}>
        {/* items */}
        <div className="adm-card pad">
          <Section title={embed ? null : 'Menu items'} sub={embed ? null : 'Drag to reorder · toggle visibility · expand dropdowns'}>
            <div style={{ display: 'flex', flexDirection: 'column', gap: 6 }}>
              {items.map((it, i) => {
                const next = items[i + 1];
                const endChild = it.depth === 1 && (!next || next.depth < 1);
                return (
                <React.Fragment key={it.id}>
                {overIdx === i && dragIdx !== null && dragIdx !== i && (
                  <div style={{ height: 2, background: 'var(--color-accent)', borderRadius: 2, marginLeft: it.depth * 24, marginBottom: 2 }}></div>
                )}
                <div
                  draggable
                  onDragStart={(e) => { setDragIdx(i); e.dataTransfer.effectAllowed = 'move'; }}
                  onDragOver={(e) => { e.preventDefault(); if (overIdx !== i) setOverIdx(i); }}
                  onDrop={(e) => { e.preventDefault(); onDrop(); }}
                  onDragEnd={() => { setDragIdx(null); setOverIdx(null); }}
                  onClick={() => setExpanded(expanded === it.id ? null : it.id)} style={{
                  display: 'flex', alignItems: 'center', gap: 10,
                  padding: '10px 12px', borderRadius: expanded === it.id ? '10px 10px 0 0' : 10,
                  marginLeft: it.depth * 24, cursor: 'pointer',
                  background: expanded === it.id ? 'var(--color-accent-light)' : 'var(--color-surface)',
                  border: `1px solid ${expanded === it.id ? 'var(--color-accent)' : 'var(--color-border)'}`,
                  borderBottom: expanded === it.id ? 'none' : `1px solid var(--color-border)`,
                  opacity: dragIdx === i ? 0.4 : (it.visible ? 1 : 0.45),
                  transition: 'opacity 0.12s',
                }}>
                  <span style={{ cursor: 'grab', color: 'var(--color-text-quaternary)', fontSize: 13, userSelect: 'none' }} onClick={(e) => e.stopPropagation()} title="Drag to reorder">⠿</span>
                  <span style={{ color: 'var(--color-text-tertiary)', fontSize: 11, transition: 'transform 0.15s', transform: expanded === it.id ? 'rotate(90deg)' : 'none' }}>›</span>
                  <span className={`adm-badge ${tones[it.type]}`}>{labels[it.type]}</span>
                  <span style={{ flex: 1, fontFamily: 'var(--font)', fontSize: 13.5, fontWeight: 500, color: it.type === 'divider' ? 'var(--color-text-tertiary)' : 'var(--color-text-primary)', fontStyle: it.type === 'divider' ? 'italic' : 'normal' }}>
                    {it.type === 'divider' ? '— Divider —' : it.label}
                  </span>
                  <span onClick={(e) => e.stopPropagation()} style={{ display: 'flex', gap: 0 }}>
                    <button onClick={() => move(i, -1)} title="Move up" style={menuIconBtn}>↑</button>
                    <button onClick={() => move(i, 1)} title="Move down" style={menuIconBtn}>↓</button>
                    <button onClick={() => setVisible(it.id, !it.visible)} title={it.visible ? 'Hide' : 'Show'} style={{ ...menuIconBtn, color: it.visible ? 'var(--color-accent)' : 'var(--color-text-quaternary)' }}>{it.visible ? '◉' : '◯'}</button>
                    <button onClick={() => remove(it.id)} title="Delete" style={{ ...menuIconBtn, color: 'var(--red)' }}>✕</button>
                  </span>
                </div>
                {expanded === it.id && (
                  <div style={{ marginLeft: it.depth * 24, marginTop: -6, marginBottom: 4, padding: 20, background: 'var(--color-surface)', border: '1px solid var(--color-accent)', borderTop: '1px solid var(--color-border)', borderRadius: '0 0 12px 12px' }}>
                    <MenuRowEditor item={it} labels={labels} onChange={(k, v) => updateItem(it.id, k, v)} />
                  </div>
                )}
                {endChild && (
                  <button onClick={() => addChildAfter(i)} style={addBtnStyle(1)}>
                    <span style={{ fontSize: 15 }}>+</span> Add item
                  </button>
                )}
                </React.Fragment>
                );
              })}
              <button onClick={addTop} style={addBtnStyle(0)}>
                <span style={{ fontSize: 15 }}>+</span> Add item
              </button>
            </div>
          </Section>
        </div>

        {/* settings */}
        {!embed && (
        <div className="adm-card pad" style={{ position: 'sticky', top: 84 }}>
          <div style={{ fontFamily: 'var(--font)', fontSize: 17, fontWeight: 600, letterSpacing: '-0.01em', color: 'var(--color-text-primary)', marginBottom: 16 }}>Menu settings</div>
          <div style={{ marginBottom: 16 }}>
            <Field label="Display rule">
              <AdmSelect value={audience} onChange={setAudience} options={[['client', 'Existing client'], ['guest', 'Guest client'], ['all', 'All visitors']]} />
            </Field>
          </div>
          <SetRow title="Status" help="Active menus render on matching pages." control={<Toggle on={active} onChange={setActive} />} />
          <div style={{ marginTop: 16 }}>
            <div style={{ fontFamily: 'var(--font)', fontSize: 11.5, color: 'var(--color-text-tertiary)', lineHeight: 1.5 }}>Changes apply when you save from the bar below.</div>
          </div>
        </div>
        )}
      </div>
      )}
    </div>
  );
}

const menuIconBtn = { background: 'transparent', border: 'none', cursor: 'pointer', color: 'var(--color-text-tertiary)', fontSize: 13, padding: '4px 7px', borderRadius: 6, fontFamily: 'var(--font)' };

function MRadio({ on, onClick, children, hint }) {
  return (
    <button onClick={onClick} style={{ display: 'inline-flex', alignItems: 'center', gap: 9, background: 'transparent', border: 'none', cursor: 'pointer', padding: 0, fontFamily: 'var(--font)', fontSize: 13.5, fontWeight: 500, color: 'var(--color-text-primary)' }}>
      <span style={{ width: 18, height: 18, borderRadius: '50%', flexShrink: 0, border: `2px solid ${on ? 'var(--color-accent)' : 'var(--color-border-strong, #c7c7cc)'}`, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
        {on && <span style={{ width: 8, height: 8, borderRadius: '50%', background: 'var(--color-accent)' }}></span>}
      </span>
      {children}
      {hint && <InfoDot tip={hint} />}
    </button>
  );
}
function InfoDot({ tip }) {
  return (
    <span className="adm-infodot" tabIndex={0}>
      <span className="adm-infodot-ico">i</span>
      {tip && <span className="adm-infodot-tip">{tip}</span>}
    </span>
  );
}
function Collapse({ title, defaultOpen }) {
  const [open, setOpen] = React.useState(!!defaultOpen);
  return { open, node: (
    <button onClick={() => setOpen((o) => !o)} style={{ display: 'flex', alignItems: 'center', gap: 12, width: '100%', background: 'transparent', border: 'none', cursor: 'pointer', padding: '6px 0', textAlign: 'left', borderLeft: '3px solid var(--color-accent)', paddingLeft: 14 }}>
      <span style={{ flex: 1, fontFamily: 'var(--font)', fontSize: 16, fontWeight: 600, letterSpacing: '-0.01em', color: 'var(--color-text-primary)' }}>{title}</span>
      <span style={{ fontFamily: 'var(--font)', fontSize: 13, fontWeight: 500, color: 'var(--color-text-tertiary)' }}>{open ? 'Collapse' : 'Expand'}</span>
      <span style={{ color: 'var(--color-text-tertiary)', fontSize: 12, transition: 'transform 0.15s', transform: open ? 'rotate(180deg)' : 'none' }}>▾</span>
    </button>
  ), setOpen };
}

function MenuRowEditor({ item, labels, onChange }) {
  const [nameMode, setNameMode] = React.useState('custom');
  const [labelOpen, setLabelOpen] = React.useState(false);
  const [dispOpen, setDispOpen] = React.useState(false);
  const [layouts, setLayouts] = React.useState({ topnav: false, sidebar: false, iconrail: false });
  const [showInMenu, setShowInMenu] = React.useState(true);
  const [pageVal, setPageVal] = React.useState('');
  const [ddStyle, setDdStyle] = React.useState('classic');
  const isDivider = item.type === 'divider';
  const childLabel = item.depth === 1 ? 'Sub-menu item' : 'Menu item';

  const typeHelp = 'Changing the type hides fields that don’t apply. Existing label / icon / URL values are kept in case you switch back.';
  const lbl = { display: 'flex', alignItems: 'center', gap: 6, fontFamily: 'var(--font)', fontSize: 11.5, fontWeight: 500, color: 'var(--color-text-secondary)', marginBottom: 6 };
  const help = { fontFamily: 'var(--font)', fontSize: 11, color: 'var(--color-text-tertiary)', lineHeight: 1.45, marginTop: 6 };
  const linkBtn = { background: 'transparent', border: 'none', cursor: 'pointer', fontFamily: 'var(--font)', fontSize: 13, fontWeight: 600, color: 'var(--color-accent)', padding: 0 };

  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: 22 }}>
      {/* sub-item label */}
      <div style={{ display: 'flex', alignItems: 'center', gap: 9, fontFamily: 'var(--font)', fontSize: 13.5, fontWeight: 600, color: 'var(--color-text-primary)' }}>
        <span style={{ width: 6, height: 6, borderRadius: '50%', background: 'var(--color-accent)', flexShrink: 0 }}></span>
        {childLabel}
      </div>

      {/* primary card */}
      <div style={{ background: 'var(--color-surface-secondary)', borderRadius: 12, padding: 16, display: 'flex', flexDirection: 'column', gap: 14, fontSize: 13 }}>
        <div>
          <div style={lbl}>Type <InfoDot tip={typeHelp} /></div>
          <AdmSelect value={item.type} onChange={(v) => onChange('type', v)} options={Object.entries(labels).map(([v, l]) => [v, l])} />
          <div style={help}>{typeHelp}</div>
        </div>

        {!isDivider && (
          <>
            {item.type === 'page' && (
              <div>
                <div style={lbl}>Page <InfoDot tip="The built-in WHMCS page this item links to." /></div>
                <AdmSelect value={pageVal} onChange={setPageVal} placeholder="— Choose a page —" options={[['dashboard', 'Account dashboard'], ['services', 'My services'], ['domains', 'My domains'], ['billing', 'Billing'], ['support', 'Support center'], ['kb', 'Knowledgebase']]} />
              </div>
            )}
            {item.type === 'link' && (
              <div>
                <div style={lbl}>URL <InfoDot tip="Any internal path or external link, e.g. https://example.com." /></div>
                <input className="adm-input" style={{ width: '100%' }} placeholder="https://example.com" />
              </div>
            )}
            {item.type === 'dropdown' && (
              <div>
                <div style={lbl}>Dropdown style <InfoDot tip="Classic shows a simple list; Mega menu spans a wide multi-column panel." /></div>
                <AdmSelect value={ddStyle} onChange={setDdStyle} options={[['classic', 'Default (classic)'], ['mega', 'Mega menu']]} />
              </div>
            )}

            {/* Name */}
            <div>
              <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
                <div style={lbl}>Name <InfoDot tip="Use a Custom String, or a Language Variable key that translates across your installed languages." /></div>
                <button style={linkBtn} disabled={nameMode !== 'lang'} onClick={() => {}} title={nameMode === 'lang' ? 'Translate' : 'Switch to Language Variable to translate'}>
                  <span style={{ opacity: nameMode === 'lang' ? 1 : 0.4 }}>Translate</span>
                </button>
              </div>
              <div style={{ display: 'flex', flexDirection: 'column', gap: 10 }}>
                <MRadio on={nameMode === 'custom'} onClick={() => setNameMode('custom')} hint>Custom String</MRadio>
                {nameMode === 'custom' && (
                  <div style={{ borderLeft: '2px solid var(--color-border)', marginLeft: 8, paddingLeft: 16 }}>
                    <input className="adm-input" style={{ width: '100%' }} value={item.label} onChange={(e) => onChange('label', e.target.value)} placeholder="New item" />
                  </div>
                )}
                <MRadio on={nameMode === 'lang'} onClick={() => setNameMode('lang')} hint>Language Variable</MRadio>
                {nameMode === 'lang' && (
                  <div style={{ borderLeft: '2px solid var(--color-border)', marginLeft: 8, paddingLeft: 16 }}>
                    <input className="adm-input" style={{ width: '100%' }} value={item.label} onChange={(e) => onChange('label', e.target.value)} placeholder="new_whmcs_page" />
                    <div style={help}>Use a language variable so the label translates across your installed languages.</div>
                  </div>
                )}
              </div>
            </div>

            {/* Description */}
            <div>
              <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
                <div style={lbl}>Description</div>
                <button style={{ ...linkBtn, opacity: 0.4 }} disabled>Translate</button>
              </div>
              <textarea className="adm-textarea" rows={2} style={{ width: '100%' }} placeholder="Optional — shown in mega-menu and rail tooltips."></textarea>
            </div>

            {/* Icon — assign row */}
            <div>
              <div style={lbl}>Icon <InfoDot tip="Top-nav icons render only when the global Top-Nav Icons setting is on. Sidebar and rail layouts always show icons." /></div>
              <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 10, background: 'var(--color-surface)', border: '1px dashed var(--color-border)', borderRadius: 10, padding: '14px 16px' }}>
                <span style={{ fontFamily: 'var(--font)', fontSize: 13.5, color: 'var(--color-text-tertiary)' }}>No icon assigned</span>
                <button style={{ ...linkBtn, display: 'inline-flex', alignItems: 'center', gap: 6 }}>
                  <span style={{ fontSize: 15 }}>⊕</span> Assign icon
                </button>
              </div>
              <div style={help}>Top-nav icons render only when the global Top-Nav Icons setting is on. Sidebar and rail layouts always show icons.</div>
            </div>
          </>
        )}
      </div>

      {/* Menu Item Label (collapsible) */}
      {!isDivider && (
        <div>
          <button onClick={() => setLabelOpen((o) => !o)} style={{ display: 'flex', alignItems: 'center', gap: 9, width: '100%', background: 'transparent', border: 'none', cursor: 'pointer', padding: 0, textAlign: 'left' }}>
            <span style={{ width: 6, height: 6, borderRadius: '50%', background: labelOpen ? 'var(--color-accent)' : 'var(--color-text-quaternary)', flexShrink: 0 }}></span>
            <span style={{ flex: 1, fontFamily: 'var(--font)', fontSize: 13.5, fontWeight: 600, color: 'var(--color-text-primary)' }}>{childLabel} label</span>
            <span style={{ color: labelOpen ? 'var(--color-accent)' : 'var(--color-text-quaternary)', fontSize: 11, transition: 'transform 0.15s', transform: labelOpen ? 'rotate(90deg)' : 'none' }}>›</span>
          </button>
          {labelOpen && (
            <div style={{ marginTop: 12, background: 'var(--color-surface-secondary)', borderRadius: 12, padding: 16, display: 'flex', flexDirection: 'column', gap: 14, fontSize: 13 }}>
              <div style={{ display: 'flex', gap: 16, flexWrap: 'wrap' }}>
                <div><div style={lbl}>Text transform <InfoDot tip="Force the label case: leave as-is, ALL CAPS, or Capitalize Each Word." /></div><select className="adm-select" style={{ width: 160 }}><option>None</option><option>Uppercase</option><option>Capitalize</option></select></div>
                <div><div style={lbl}>Badge <InfoDot tip="A small pill shown next to the label, e.g. “New” or a count." /></div><input className="adm-input" style={{ width: 160 }} placeholder="e.g. New" /></div>
              </div>
              <SetRow title="Hide label text" help="Show only the icon (icon layouts)." control={<Toggle on={false} onChange={() => {}} />} />
            </div>
          )}
        </div>
      )}

      {/* Display settings (collapsible) */}
      <div>
        <button onClick={() => setDispOpen((o) => !o)} style={{ display: 'flex', alignItems: 'center', gap: 9, width: '100%', background: 'transparent', border: 'none', cursor: 'pointer', padding: 0, textAlign: 'left' }}>
          <span style={{ width: 6, height: 6, borderRadius: '50%', background: dispOpen ? 'var(--color-accent)' : 'var(--color-text-quaternary)', flexShrink: 0 }}></span>
          <span style={{ flex: 1, fontFamily: 'var(--font)', fontSize: 13.5, fontWeight: 600, color: 'var(--color-text-primary)' }}>{childLabel} display settings</span>
          <span style={{ color: dispOpen ? 'var(--color-accent)' : 'var(--color-text-quaternary)', fontSize: 11, transition: 'transform 0.15s', transform: dispOpen ? 'rotate(90deg)' : 'none' }}>›</span>
        </button>
        {dispOpen && (
          <div style={{ marginTop: 12, background: 'var(--color-surface-secondary)', borderRadius: 12, padding: 16, display: 'flex', flexDirection: 'column', gap: 14, fontSize: 13 }}>
            <div style={{ display: 'flex', gap: 40, flexWrap: 'wrap' }}>
              <div>
                <div style={lbl}>Position <InfoDot tip="Where this item sits in the menu: Auto follows source order, or pin it to the Start or End." /></div>
                <select className="adm-select" style={{ width: 150 }} defaultValue="auto"><option value="auto">Auto</option><option value="start">Start</option><option value="end">End</option></select>
              </div>
              <div>
                <div style={lbl}>Visible to (per-item) <InfoDot tip="Restrict this item to specific layouts. If none are ticked, it appears on all layouts." /></div>
                <div style={{ display: 'flex', gap: 16 }}>
                  {[['topnav', 'Top nav'], ['sidebar', 'Sidebar'], ['iconrail', 'Icon rail']].map(([id, l]) => (
                    <label key={id} style={{ display: 'inline-flex', alignItems: 'center', gap: 7, cursor: 'pointer', fontFamily: 'var(--font)', fontSize: 13, color: 'var(--color-text-secondary)' }}>
                      <input type="checkbox" checked={layouts[id]} onChange={(e) => setLayouts((p) => ({ ...p, [id]: e.target.checked }))} style={{ accentColor: 'var(--color-accent)', width: 15, height: 15 }} />{l}
                    </label>
                  ))}
                </div>
                <div style={help}>If none ticked, item shows on all layouts.</div>
              </div>
            </div>
            <div>
              <div style={lbl}>Custom CSS class <InfoDot tip="Adds a class to this item’s markup so you can target it from Custom CSS." /></div>
              <input className="adm-input" style={{ width: 280 }} placeholder="e.g. highlight-item" />
            </div>
            <SetRow title="Show in menu" help="Uncheck to keep the item saved but hidden from the rendered menu." control={<Toggle on={showInMenu} onChange={setShowInMenu} />} />
          </div>
        )}
      </div>
    </div>
  );
}

function PageRowEditor({ pg, onChange }) {
  const variants = [
    { id: 'Default', d: 'Standard layout, all options' },
    { id: 'Cards', d: 'Card-grid, great for lists' },
    { id: 'Compact', d: 'Tight spacing' },
    { id: 'Hero', d: 'Large hero header' },
  ];
  return (
    <div>
      <div style={{ fontFamily: 'var(--font)', fontSize: 11, fontWeight: 700, letterSpacing: '0.1em', textTransform: 'uppercase', color: 'var(--color-text-tertiary)', marginBottom: 10 }}>Template variant</div>
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(4, 1fr)', gap: 10, marginBottom: 18 }}>
        {variants.map((v) => (
          <button key={v.id} onClick={() => onChange('variant', v.id)} style={{
            textAlign: 'left', padding: 12, borderRadius: 10, cursor: 'pointer',
            background: pg.variant === v.id ? 'var(--color-accent-light)' : 'var(--color-surface)',
            border: `1px solid ${pg.variant === v.id ? 'var(--color-accent)' : 'var(--color-border)'}`,
          }}>
            <div style={{ fontFamily: 'var(--font)', fontSize: 13.5, fontWeight: 600, color: 'var(--color-text-primary)' }}>{v.id}</div>
            <div style={{ fontFamily: 'var(--font)', fontSize: 11, color: 'var(--color-text-tertiary)', marginTop: 3, lineHeight: 1.4 }}>{v.d}</div>
          </button>
        ))}
      </div>
      <div className="adm-field-grid">
        <Field label="Indexing">
          <select className="adm-select" value={pg.indexing} onChange={(e) => onChange('indexing', e.target.value)}>
            <option value="inherit">Inherit (follow global)</option>
            <option value="allow">Allow indexing</option>
            <option value="disallow">Disallow indexing</option>
          </select>
        </Field>
        <Field label="Visibility">
          <select className="adm-select" value={pg.visibility} onChange={(e) => onChange('visibility', e.target.value)}>
            <option value="public">Public — anyone</option>
            <option value="auth">Authenticated only</option>
            <option value="disabled">Disabled — 404</option>
          </select>
        </Field>
      </div>
      <div style={{ marginTop: 14 }}>
        <Field label="SEO title" hint={`${(pg.seoTitle || '').length}/64`}>
          <input className="adm-input" maxLength={64} value={pg.seoTitle || ''} onChange={(e) => onChange('seoTitle', e.target.value)} placeholder={pg.name} />
        </Field>
      </div>
      <div style={{ marginTop: 14 }}>
        <Field label="SEO description" hint={`${(pg.seoDesc || '').length}/160`}>
          <textarea className="adm-textarea" rows={2} maxLength={160} value={pg.seoDesc || ''} onChange={(e) => onChange('seoDesc', e.target.value)}></textarea>
        </Field>
      </div>
    </div>
  );
}

function PagesPage() {
  const [tab, setTab] = React.useState('all');
  const [selected, setSelected] = React.useState(null);
  const [saved, setSaved] = React.useState(false);
  const [q, setQ] = React.useState('');
  const [pages, setPages] = React.useState([
    { id: 20, group: 'home', name: 'Homepage', desc: 'Client-area landing page', variant: 'Hero', seo: true, indexing: 'allow', visibility: 'public' },
    { id: 1, group: 'account', name: 'Account dashboard', desc: 'Logged-in client home', variant: 'Default', seo: true, indexing: 'allow', visibility: 'auth' },
    { id: 2, group: 'account', name: 'Profile', desc: 'Edit personal details', variant: 'Default', seo: false, indexing: 'inherit', visibility: 'auth' },
    { id: 3, group: 'account', name: 'Security', desc: '2FA & password', variant: 'Default', seo: false, indexing: 'disallow', visibility: 'auth' },
    { id: 4, group: 'services', name: 'My services', desc: 'All purchased services', variant: 'Cards', seo: true, indexing: 'allow', visibility: 'auth' },
    { id: 5, group: 'services', name: 'Service detail', desc: 'Single service view', variant: 'Default', seo: false, indexing: 'inherit', visibility: 'auth' },
    { id: 6, group: 'order', name: 'Cart', desc: 'Shopping cart', variant: 'Compact', seo: true, indexing: 'allow', visibility: 'public' },
    { id: 7, group: 'order', name: 'Checkout', desc: 'Payment & review', variant: 'Default', seo: false, indexing: 'disallow', visibility: 'public' },
    { id: 8, group: 'order', name: 'Domain registration', desc: 'Pick & register a domain', variant: 'Hero', seo: true, indexing: 'allow', visibility: 'public' },
    { id: 9, group: 'support', name: 'Support center', desc: 'Knowledge base & tickets', variant: 'Default', seo: true, indexing: 'allow', visibility: 'public' },
    { id: 10, group: 'support', name: 'Open ticket', desc: 'Create a support ticket', variant: 'Default', seo: false, indexing: 'inherit', visibility: 'auth' },
  ]);
  const groups = { home: 'Homepage', account: 'Account', services: 'Services', order: 'Order', support: 'Support' };
  const tabs = [{ id: 'all', label: 'All' }, ...Object.entries(groups).map(([id, label]) => ({ id, label }))];
  const update = (id, k, v) => setPages((arr) => arr.map((p) => p.id === id ? { ...p, [k]: v } : p));
  const save = () => { setSaved(true); setTimeout(() => setSaved(false), 2200); };

  const idxTone = { allow: 'green', disallow: 'orange', inherit: 'gray' };
  const visTone = { public: 'green', auth: 'blue', disabled: 'orange' };
  const visLabel = { public: 'Public', auth: 'Auth only', disabled: 'Disabled' };

  const matchesQ = (p) => !q.trim() || (p.name + ' ' + p.desc).toLowerCase().includes(q.trim().toLowerCase());
  const visible = (tab === 'all' ? pages : pages.filter((p) => p.group === tab)).filter(matchesQ);
  const shownGroups = (tab === 'all' ? Object.keys(groups) : [tab]).filter((g) => visible.some((p) => p.group === g));

  const COLS = '1fr 92px 56px 92px 104px 18px';
  const selPage = pages.find((p) => p.id === selected);
  if (selPage) return (
    <PageDetail pg={selPage} groupLabel={groups[selPage.group]} onBack={() => setSelected(null)} onChange={(k, v) => update(selPage.id, k, v)} onSave={save} saved={saved} />
  );

  return (
    <div>
      <PageHead eyebrow="Theme" title="Pages" sub="Set the template variant, SEO, indexing, and visibility for each WHMCS page." />
      <div style={{ display: 'flex', alignItems: 'center', gap: 10, background: 'var(--color-surface)', border: '1px solid var(--color-border)', borderRadius: 10, padding: '10px 14px', marginBottom: 16, maxWidth: 360, color: 'var(--color-text-tertiary)' }}>
        <AI d={AP.search} size={16} />
        <input value={q} onChange={(e) => setQ(e.target.value)} placeholder="Search pages…" style={{ flex: 1, border: 'none', outline: 'none', background: 'transparent', fontFamily: 'var(--font)', fontSize: 14, color: 'var(--color-text-primary)' }} />
        {q && <button onClick={() => setQ('')} style={{ border: 'none', background: 'transparent', cursor: 'pointer', color: 'var(--color-text-tertiary)', fontSize: 15 }}>✕</button>}
      </div>
      <div className="adm-tabs">
        {tabs.map((t) => {
          const n = t.id === 'all' ? pages.length : pages.filter((p) => p.group === t.id).length;
          return <button key={t.id} className={`adm-tab ${tab === t.id ? 'active' : ''}`} onClick={() => setTab(t.id)}>{t.label} <span style={{ fontSize: 11, opacity: 0.6 }}>{n}</span></button>;
        })}
      </div>
      {saved && <div className="adm-alert success"><span className="adm-alert-ico"><AI d={AP.check} size={12} sw={3} /></span> Page settings saved.</div>}

      {shownGroups.length === 0 && (
        <div className="adm-card pad"><div className="adm-empty"><div className="adm-empty-ico"><AI d={AP.search} size={22} /></div><div className="adm-empty-title">No pages match "{q}"</div><div className="adm-empty-text">Try a different search term.</div></div></div>
      )}

      {shownGroups.map((g) => (
        <div key={g} className="adm-card pad" style={{ marginBottom: 18 }}>
          <Section title={`${groups[g]} pages`} sub={`${visible.filter((p) => p.group === g).length} pages`}>
            {/* column header */}
            <div style={{ display: 'grid', gridTemplateColumns: COLS, gap: 14, alignItems: 'center', padding: '0 14px 8px' }}>
              {['Page', 'Variant', 'SEO', 'Indexing', 'Visibility', ''].map((h, i) => (
                <span key={i} style={{ fontFamily: 'var(--font)', fontSize: 10, fontWeight: 700, letterSpacing: '0.1em', textTransform: 'uppercase', color: 'var(--color-text-quaternary)' }}>{h}</span>
              ))}
            </div>
            <div style={{ display: 'flex', flexDirection: 'column', gap: 6 }}>
              {visible.filter((p) => p.group === g).map((p) => (
                <div key={p.id} onClick={() => setSelected(p.id)} style={{
                  display: 'grid', gridTemplateColumns: COLS, gap: 14, alignItems: 'center',
                  padding: '12px 14px', borderRadius: 10, cursor: 'pointer',
                  background: 'var(--color-surface)', border: '1px solid var(--color-border)',
                }}
                  onMouseEnter={(e) => { e.currentTarget.style.background = 'var(--color-surface-secondary)'; }}
                  onMouseLeave={(e) => { e.currentTarget.style.background = 'var(--color-surface)'; }}>
                  <div style={{ minWidth: 0 }}>
                    <div style={{ fontFamily: 'var(--font)', fontSize: 14, fontWeight: 600, color: 'var(--color-text-primary)' }}>{p.name}</div>
                    <div style={{ fontFamily: 'var(--font)', fontSize: 12, color: 'var(--color-text-tertiary)', marginTop: 2, whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis' }}>{p.desc}</div>
                  </div>
                  <span style={{ fontFamily: 'var(--font)', fontSize: 12.5, color: 'var(--color-text-secondary)' }}>{p.variant}</span>
                  <span>{p.seo ? <span className="adm-badge blue">SEO</span> : <span style={{ color: 'var(--color-text-quaternary)' }}>—</span>}</span>
                  <span><span className={`adm-badge ${idxTone[p.indexing]}`}>{p.indexing}</span></span>
                  <span><span className={`adm-badge ${visTone[p.visibility]}`}>{visLabel[p.visibility]}</span></span>
                  <span style={{ color: 'var(--color-text-tertiary)', fontSize: 13, textAlign: 'right' }}>›</span>
                </div>
              ))}
            </div>
          </Section>
        </div>
      ))}
    </div>
  );
}

// Homepage block composer — pick, order, and size the blocks on the page.
// Each homepage type ships its own block set.
const HOME_W = { '1/1': 6, '2/3': 4, '1/2': 3, '1/3': 2 };
const HOME_BLOCKS = {
  Hero: [
    { id: 'welcome', n: 'Welcome band', on: true, w: '1/1' },
    { id: 'hero', n: 'Hero banner', on: true, w: '1/1' },
    { id: 'search', n: 'Domain search', on: true, w: '1/1' },
    { id: 'features', n: 'Feature strip', on: true, w: '1/1' },
    { id: 'products', n: 'Product cards', on: true, w: '2/3' },
    { id: 'login', n: 'Client login', on: true, w: '1/3' },
    { id: 'announce', n: 'Announcements', on: true, w: '1/2' },
    { id: 'status', n: 'Network status', on: true, w: '1/2' },
    { id: 'trust', n: 'Trust badges', on: false, w: '1/1' },
    { id: 'testimonials', n: 'Testimonials', on: false, w: '1/2' },
    { id: 'faq', n: 'FAQ', on: false, w: '1/2' },
    { id: 'cta', n: 'Support CTA', on: false, w: '1/1' },
  ],
  Storefront: [
    { id: 'promo', n: 'Promo banner', on: true, w: '1/1' },
    { id: 'groups', n: 'Product group tabs', on: true, w: '1/1' },
    { id: 'products', n: 'Product cards', on: true, w: '1/1' },
    { id: 'pricing', n: 'Pricing table', on: true, w: '2/3' },
    { id: 'cart', n: 'Cart summary', on: true, w: '1/3' },
    { id: 'compare', n: 'Feature comparison', on: false, w: '1/1' },
    { id: 'search', n: 'Domain search', on: true, w: '1/2' },
    { id: 'payments', n: 'Payment methods', on: true, w: '1/2' },
    { id: 'testimonials', n: 'Testimonials', on: false, w: '1/2' },
    { id: 'faq', n: 'FAQ', on: false, w: '1/2' },
  ],
  Portal: [
    { id: 'brand', n: 'Brand panel', on: true, w: '1/2' },
    { id: 'login', n: 'Client login', on: true, w: '1/2' },
    { id: 'register', n: 'Register CTA', on: true, w: '1/2' },
    { id: 'reset', n: 'Password reset link', on: true, w: '1/2' },
    { id: 'sso', n: 'Social / SSO buttons', on: false, w: '1/1' },
    { id: 'announce', n: 'Announcements', on: false, w: '1/2' },
    { id: 'status', n: 'Network status', on: true, w: '1/2' },
    { id: 'lang', n: 'Language switcher', on: true, w: '1/3' },
    { id: 'cta', n: 'Support CTA', on: false, w: '1/3' },
  ],
  'Domain search': [
    { id: 'search', n: 'Domain search', on: true, w: '1/1' },
    { id: 'tlds', n: 'Popular TLD strip', on: true, w: '1/1' },
    { id: 'transfer', n: 'Transfer domain', on: true, w: '1/2' },
    { id: 'bulk', n: 'Bulk search', on: true, w: '1/2' },
    { id: 'pricing', n: 'TLD pricing table', on: true, w: '2/3' },
    { id: 'whois', n: 'WHOIS lookup', on: false, w: '1/3' },
    { id: 'tools', n: 'Domain tools', on: false, w: '1/3' },
    { id: 'faq', n: 'Domain FAQ', on: false, w: '1/2' },
    { id: 'cta', n: 'Support CTA', on: false, w: '1/2' },
  ],
  Landing: [
    { id: 'hero', n: 'Hero banner', on: true, w: '1/1' },
    { id: 'logos', n: 'Logo wall', on: true, w: '1/1' },
    { id: 'features', n: 'Feature strip', on: true, w: '1/1' },
    { id: 'stats', n: 'Stats band', on: true, w: '1/1' },
    { id: 'products', n: 'Product cards', on: true, w: '1/1' },
    { id: 'pricing', n: 'Pricing table', on: true, w: '1/1' },
    { id: 'testimonials', n: 'Testimonials', on: true, w: '1/2' },
    { id: 'faq', n: 'FAQ', on: true, w: '1/2' },
    { id: 'newsletter', n: 'Newsletter signup', on: false, w: '1/2' },
    { id: 'cta', n: 'Support CTA', on: true, w: '1/1' },
  ],
  Redirect: [],
};
// Per-block settings, keyed by block id.
// t: 'seg' = segmented pills · 'swatch' = colour row · d = one-line description · tip = full story (InfoDot) · showIf = { k, v[] }
const BLOCK_OPTS = {
  welcome: [
    { k: 'style', t: 'seg', l: 'Band style', g: 'style', o: ['Gradient', 'Solid', 'Soft', 'Plain'], d: 'How the greeting panel is filled.', tip: 'Gradient is the shipped look — the accent deepened at one end and lightened at the other. Solid is a flat accent panel. Soft is a pale tint with dark text, for a lighter page. Plain drops the panel and sets the greeting on the page background.' },
    { k: 'width', t: 'seg', l: 'Band width', o: ['Boxed', 'Edge'], d: 'Boxed stays inside the content column; Edge runs full width.', tip: 'Edge runs the band to the full width of the content area with the text still aligned to the column — it reads as a header rather than a card.' },
    { k: 'buttons', t: 'seg', l: 'Band buttons', o: ['Right', 'Below', 'Off'], def: 'Off', d: 'Where Pay balance and Order a service sit.', tip: 'Right places the actions opposite the greeting. Below stacks them under it, for a narrow content column. Off hides them — the same actions stay reachable from the blocks underneath.' },
    { k: 'height', t: 'seg', l: 'Band height', o: ['Full', 'Slim'], d: 'Full: date, greeting and a line of copy. Slim: a one-line bar.', tip: 'Slim drops the copy line and tightens the padding to a one-line bar — the date and greeting on the left, buttons or the avatar on the right. Useful when the figures and blocks below are what the page is really for.' },
    { k: 'profile', t: 'seg', l: 'Band profile', o: ['Off', 'Avatar'], def: 'Avatar', d: 'Account monogram at the right of the band.', tip: 'The avatar opens the same account menu the topbar and sidebar use — details, users, payment methods, contacts, security and log out. It sits after the buttons, so set Band buttons to Off if you want the profile alone.' },
    { k: 'source', t: 'seg', l: 'Colour source', g: 'style', o: ['None', 'Theme', 'Custom'], def: 'Theme', d: 'Where the band colour comes from.', tip: 'Theme follows the colour set on Styles › Colors — every block using it changes when you change it there. Custom is fixed: it stays exactly as you set it, whatever the style does.' },
    { k: 'themecol', t: 'swatch', l: 'Theme colour', g: 'style', d: 'Moves with the preset.', o: ['#0a84ff', '#8ec9ff'], showIf: { k: 'source', v: ['Theme'] } },
    { k: 'customcol', t: 'swatch', l: 'Custom colour', g: 'style', d: 'Its own row on Styles › Colors.', o: ['#ffffff', '#5e5ce6', '#bf5af2', '#30d158', '#64d2ff', '#ff9f0a', '#ff453a', '#8e8e93', '#5856d6', '#248a3d', '#d2691e'], def: '#5e5ce6', showIf: { k: 'source', v: ['Custom'] } },
    { k: 'fill', t: 'seg', l: 'Fill', g: 'style', o: ['Solid', 'Wash', 'Gradient'], d: 'How the colour is applied.', tip: 'Text on a solid or gradient fill picks black or white automatically, whichever is legible on it.', showIf: { k: 'source', v: ['Theme', 'Custom'] } },
  ],
  hero: [{ k: 'style', t: 'select', l: 'Hero style', g: 'style', o: ['Image background', 'Gradient', 'Solid colour', 'Video'] }, { k: 'height', t: 'select', l: 'Height', o: ['Compact', 'Standard', 'Full screen'] }, { k: 'align', t: 'select', l: 'Text alignment', o: ['Left', 'Centre'] }, { k: 'cta2', t: 'toggle', l: 'Secondary button' }],
  search: [{ k: 'tabs', t: 'toggle', l: 'Register / transfer tabs' }, { k: 'suggest', t: 'toggle', l: 'Suggest alternatives' }, { k: 'placeholder', t: 'text', l: 'Placeholder text', ph: 'Find your perfect domain' }],
  features: [{ k: 'cols', t: 'select', l: 'Columns', o: ['2', '3', '4'] }, { k: 'icons', t: 'toggle', l: 'Show icons' }, { k: 'divider', t: 'toggle', l: 'Divider between items' }],
  products: [{ k: 'source', t: 'select', l: 'Product group', o: ['Featured', 'All groups', 'Shared hosting', 'VPS', 'Dedicated'] }, { k: 'cols', t: 'select', l: 'Columns', o: ['2', '3', '4'] }, { k: 'price', t: 'toggle', l: 'Show pricing' }, { k: 'cycle', t: 'toggle', l: 'Billing-cycle switcher' }],
  login: [{ k: 'remember', t: 'toggle', l: 'Remember me' }, { k: 'forgot', t: 'toggle', l: 'Forgot-password link' }, { k: 'sso', t: 'toggle', l: 'Social sign-in' }],
  announce: [{ k: 'limit', t: 'select', l: 'Items shown', o: ['1', '2', '3', '5'] }, { k: 'date', t: 'toggle', l: 'Show dates' }, { k: 'excerpt', t: 'toggle', l: 'Show excerpt' }],
  status: [{ k: 'src', t: 'select', l: 'Source', o: ['WHMCS network status', 'External status page'] }, { k: 'incidents', t: 'toggle', l: 'List open incidents' }],
  trust: [],  testimonials: [{ k: 'layout', t: 'select', l: 'Layout', o: ['Carousel', 'Grid', 'Single quote'] }, { k: 'avatars', t: 'toggle', l: 'Show avatars' }, { k: 'stars', t: 'toggle', l: 'Show star rating' }],
  faq: [{ k: 'style', t: 'select', l: 'Style', o: ['Accordion', 'Two columns'] }, { k: 'limit', t: 'select', l: 'Questions', o: ['4', '6', '8', 'All'] }],
  cta: [{ k: 'style', t: 'select', l: 'Style', o: ['Banner', 'Card', 'Inline'] }, { k: 'chat', t: 'toggle', l: 'Live-chat button' }],  promo: [{ k: 'dismiss', t: 'toggle', l: 'Dismissible' }, { k: 'countdown', t: 'toggle', l: 'Countdown timer' }, { k: 'text', t: 'text', l: 'Message', ph: 'Save 25% on annual plans' }],
  groups: [{ k: 'style', t: 'select', l: 'Style', o: ['Tabs', 'Pills', 'Sidebar'] }, { k: 'counts', t: 'toggle', l: 'Show product counts' }],
  pricing: [{ k: 'cycle', t: 'select', l: 'Default cycle', o: ['Monthly', 'Annually', 'Biennially'] }, { k: 'highlight', t: 'toggle', l: 'Highlight recommended' }, { k: 'save', t: 'toggle', l: 'Show annual savings' }],
  cart: [{ k: 'sticky', t: 'toggle', l: 'Sticky on scroll' }, { k: 'promo', t: 'toggle', l: 'Promo-code field' }],
  compare: [{ k: 'sticky', t: 'toggle', l: 'Sticky header row' }, { k: 'rows', t: 'select', l: 'Feature rows', o: ['Key features', 'All features'] }],
  payments: [],
  brand: [{ k: 'media', t: 'select', l: 'Panel media', o: ['Image', 'Gradient', 'Solid colour'] }, { k: 'logo', t: 'toggle', l: 'Show logo' }, { k: 'tagline', t: 'toggle', l: 'Show tagline' }],
  register: [{ k: 'style', t: 'select', l: 'Style', o: ['Link', 'Button', 'Card'] }],
  reset: [],
  sso: [{ k: 'providers', t: 'select', l: 'Providers', o: ['Google', 'Google + Facebook', 'All configured'] }],
  lang: [],
  tlds: [{ k: 'count', t: 'select', l: 'TLDs shown', o: ['5', '8', '12'] }, { k: 'price', t: 'toggle', l: 'Show prices' }],
  transfer: [{ k: 'epp', t: 'toggle', l: 'EPP code field' }, { k: 'bulk', t: 'toggle', l: 'Allow bulk transfer' }],
  bulk: [{ k: 'max', t: 'select', l: 'Max domains', o: ['10', '20', '50'] }],
  whois: [],
  tools: [{ k: 'set', t: 'select', l: 'Tools', o: ['DNS + nameservers', 'All domain tools'] }],
  logos: [{ k: 'count', t: 'select', l: 'Logos', o: ['4', '6', '8'] }, { k: 'grey', t: 'toggle', l: 'Greyscale' }, { k: 'marquee', t: 'toggle', l: 'Scrolling marquee' }],
  stats: [{ k: 'count', t: 'select', l: 'Stats', o: ['3', '4'] }, { k: 'animate', t: 'toggle', l: 'Count-up animation' }],
  newsletter: [{ k: 'consent', t: 'toggle', l: 'Consent checkbox' }, { k: 'ph', t: 'text', l: 'Placeholder', ph: 'you@company.com' }],
};
function OptSeg({ value, options, onChange }) {
  return (
    <span style={{ display: 'inline-flex', background: 'var(--color-surface-secondary)', border: '1px solid var(--color-border)', padding: 2, borderRadius: 8, gap: 2, flexShrink: 0 }}>
      {options.map((o) => (
        <button key={o} onClick={() => onChange(o)} style={{ padding: '4px 11px', fontSize: 11.5, fontWeight: 600, border: 'none', borderRadius: 6, cursor: 'pointer', fontFamily: 'var(--font)', background: value === o ? 'var(--color-surface)' : 'transparent', color: value === o ? 'var(--color-accent)' : 'var(--color-text-tertiary)', boxShadow: value === o ? '0 1px 3px rgba(0,0,0,0.1)' : 'none' }}>{o}</button>
      ))}
    </span>
  );
}
function SwatchRow({ value, options, onChange }) {
  return (
    <span style={{ display: 'inline-flex', gap: 8, flexWrap: 'wrap', justifyContent: 'flex-end', maxWidth: 260 }}>
      {options.map((c) => (
        <button key={c} onClick={() => onChange(c)} aria-label={c} style={{ width: 21, height: 21, borderRadius: '50%', cursor: 'pointer', background: c, border: c === '#ffffff' ? '1px solid var(--color-border)' : 'none', padding: 0, boxShadow: value === c ? '0 0 0 2px var(--color-surface), 0 0 0 4px var(--color-accent)' : 'none' }}></button>
      ))}
    </span>
  );
}
function HomeBlocks({ variant }) {
  const [blocks, setBlocks] = React.useState(HOME_BLOCKS[variant] || HOME_BLOCKS.Hero);
  const [drag, setDrag] = React.useState(null);
  const [over, setOver] = React.useState(null);
  const [open, setOpen] = React.useState(null);
  const [opts, setOpts] = React.useState({});
  const setOpt = (id, k, v) => setOpts((o) => ({ ...o, [`${id}.${k}`]: v }));
  const getOpt = (id, o) => {
    const key = `${id}.${o.k}`;
    if (key in opts) return opts[key];
    if ('def' in o) return o.def;
    return o.t === 'toggle' ? true : (o.o ? o.o[0] : '');
  };
  const set = (id, k, v) => setBlocks((a) => a.map((b) => b.id === id ? { ...b, [k]: v } : b));
  const move = (i, d) => setBlocks((a) => { const j = i + d; if (j < 0 || j >= a.length) return a; const n = a.slice(); [n[i], n[j]] = [n[j], n[i]]; return n; });
  const drop = (i) => setBlocks((a) => { if (drag == null || drag === i) return a; const n = a.slice(); const [m] = n.splice(drag, 1); n.splice(i, 0, m); return n; });
  const shown = blocks.filter((b) => b.on);

  if (!blocks.length) return (
    <div className="adm-card pad">
      <div style={{ fontFamily: 'var(--font)', fontSize: 11, fontWeight: 700, letterSpacing: '0.1em', textTransform: 'uppercase', color: 'var(--color-text-tertiary)', margin: '4px 0 12px' }}>Homepage blocks</div>
      <div style={{ fontFamily: 'var(--font)', fontSize: 13, color: 'var(--color-text-tertiary)', lineHeight: 1.5 }}>The <strong style={{ color: 'var(--color-text-secondary)' }}>Redirect</strong> type renders no blocks — visitors are sent straight to the target you picked above.</div>
    </div>
  );

  return (
    <div className="adm-card pad">
      <div style={{ fontFamily: 'var(--font)', fontSize: 11, fontWeight: 700, letterSpacing: '0.1em', textTransform: 'uppercase', color: 'var(--color-text-tertiary)', margin: '4px 0 12px' }}>Homepage blocks</div>
      <div style={{ fontFamily: 'var(--font)', fontSize: 12.5, color: 'var(--color-text-tertiary)', lineHeight: 1.5, marginBottom: 14 }}>Blocks available to the <strong style={{ color: 'var(--color-text-secondary)' }}>{variant}</strong> type. Choose which appear, drag to reorder, and set each one’s width.</div>

      {/* visual preview */}
      <div style={{ background: 'var(--color-surface-secondary)', border: '1px solid var(--color-border)', borderRadius: 12, padding: 12, marginBottom: 18 }}>
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(6, 1fr)', gap: 6 }}>
          {shown.map((b) => (
            <div key={b.id} style={{ gridColumn: `span ${HOME_W[b.w]}`, minHeight: b.w === '1/1' ? 44 : 56, background: 'var(--color-surface)', border: '1px solid var(--color-accent)', borderRadius: 8, display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', gap: 2, padding: 6, textAlign: 'center' }}>
              <span style={{ fontFamily: 'var(--font)', fontSize: 11, fontWeight: 600, color: 'var(--color-text-primary)', lineHeight: 1.2 }}>{b.n}</span>
              <span style={{ fontFamily: 'var(--font)', fontSize: 9.5, color: 'var(--color-accent)', fontWeight: 600 }}>{b.w}</span>
            </div>
          ))}
          {shown.length === 0 && <div style={{ gridColumn: 'span 6', padding: '18px 0', textAlign: 'center', fontFamily: 'var(--font)', fontSize: 12.5, color: 'var(--color-text-tertiary)' }}>No blocks enabled.</div>}
        </div>
      </div>

      {/* block rows */}
      <div style={{ display: 'flex', flexDirection: 'column', gap: 6 }}>
        {blocks.map((b, i) => {
          const bo = BLOCK_OPTS[b.id] || [];
          const isOpen = open === b.id;
          return (
          <React.Fragment key={b.id}>
          <div draggable
            onDragStart={() => setDrag(i)}
            onDragOver={(e) => { e.preventDefault(); setOver(i); }}
            onDrop={() => { drop(i); setDrag(null); setOver(null); }}
            onDragEnd={() => { setDrag(null); setOver(null); }}
            style={{ display: 'flex', alignItems: 'center', gap: 10, padding: '10px 12px', borderRadius: isOpen ? '10px 10px 0 0' : 10, background: isOpen ? 'var(--color-accent-light)' : 'var(--color-surface)', border: `1px solid ${isOpen ? 'var(--color-accent)' : (over === i && drag !== i ? 'var(--color-accent)' : 'var(--color-border)')}`, borderBottom: isOpen ? 'none' : '1px solid var(--color-border)', opacity: drag === i ? 0.4 : (b.on ? 1 : 0.5) }}>
            <span style={{ cursor: 'grab', color: 'var(--color-text-quaternary)', fontSize: 13, userSelect: 'none' }}>⠿</span>
            <button onClick={() => setOpen(isOpen ? null : b.id)} disabled={!bo.length}
              style={{ flex: 1, display: 'flex', alignItems: 'center', gap: 7, background: 'transparent', border: 'none', padding: 0, textAlign: 'left', cursor: bo.length ? 'pointer' : 'default' }}>
              <span style={{ width: 11, flexShrink: 0, color: isOpen ? 'var(--color-accent)' : 'var(--color-text-quaternary)', fontSize: 11, transition: 'transform 0.15s', transform: isOpen ? 'rotate(90deg)' : 'none', visibility: bo.length ? 'visible' : 'hidden' }}>›</span>
              <span style={{ fontFamily: 'var(--font)', fontSize: 13.5, fontWeight: 500, color: 'var(--color-text-primary)' }}>{b.n}</span>
              {bo.length > 0 && <span style={{ fontFamily: 'var(--font)', fontSize: 10, color: 'var(--color-text-quaternary)' }}>{bo.length} settings</span>}
            </button>
            <span style={{ display: 'flex', background: 'var(--color-surface-secondary)', padding: 2, borderRadius: 7, gap: 2 }}>
              {['1/1', '2/3', '1/2', '1/3'].map((w) => (
                <button key={w} onClick={() => set(b.id, 'w', w)} style={{ padding: '3px 8px', fontSize: 11, fontWeight: 600, border: 'none', borderRadius: 5, cursor: 'pointer', fontFamily: 'var(--font)', background: b.w === w ? 'var(--color-surface)' : 'transparent', color: b.w === w ? 'var(--color-accent)' : 'var(--color-text-tertiary)', boxShadow: b.w === w ? '0 1px 3px rgba(0,0,0,0.08)' : 'none' }}>{w}</button>
              ))}
            </span>
            <button onClick={() => move(i, -1)} title="Move up" style={{ background: 'transparent', border: 'none', cursor: 'pointer', color: 'var(--color-text-tertiary)', fontSize: 12, padding: '3px 5px' }}>↑</button>
            <button onClick={() => move(i, 1)} title="Move down" style={{ background: 'transparent', border: 'none', cursor: 'pointer', color: 'var(--color-text-tertiary)', fontSize: 12, padding: '3px 5px' }}>↓</button>
            <Toggle on={b.on} onChange={(v) => set(b.id, 'on', v)} />
          </div>
          {isOpen && (
            <div style={{ marginTop: -6, marginBottom: 4, padding: 20, background: 'var(--color-surface)', border: '1px solid var(--color-accent)', borderTop: '1px solid var(--color-border)', borderRadius: '0 0 12px 12px' }}>
              <div style={{ display: 'flex', alignItems: 'center', gap: 9, fontFamily: 'var(--font)', fontSize: 13.5, fontWeight: 600, color: 'var(--color-text-primary)', marginBottom: 14 }}>
                <span style={{ width: 6, height: 6, borderRadius: '50%', background: 'var(--color-accent)', flexShrink: 0 }}></span>
                <span>{`${b.n} settings`}</span>
              </div>
              <div style={{ background: 'var(--color-surface-secondary)', borderRadius: 12, padding: 10 }}>
                <div style={{ background: 'var(--color-surface)', border: '1px solid var(--color-border)', borderRadius: 10, overflow: 'hidden' }}>
                  {(() => {
                    const vis = bo.filter((o) => { if (!o.showIf) return true; const src = bo.find((x) => x.k === o.showIf.k); return src && o.showIf.v.includes(getOpt(b.id, src)); });
                    const secs = [
                      { h: 'Content & behaviour', ico: 'sliders', items: vis.filter((o) => o.g !== 'style') },
                      { h: 'Colour & style', ico: 'dots', items: vis.filter((o) => o.g === 'style') },
                    ].filter((s) => s.items.length);
                    const showHeads = secs.length > 1;
                    let row = 0;
                    return secs.map((s) => (
                      <React.Fragment key={s.h}>
                        {showHeads && (
                          <div style={{ display: 'flex', alignItems: 'center', gap: 7, padding: '7px 14px', background: 'var(--color-surface-secondary)', borderTop: row++ ? '1px solid var(--color-border)' : 'none' }}>
                            {s.ico === 'dots'
                              ? <span style={{ display: 'inline-flex', gap: 2 }}>{['#0a84ff', '#bf5af2', '#30d158'].map((c) => <span key={c} style={{ width: 7, height: 7, borderRadius: '50%', background: c }}></span>)}</span>
                              : <svg width="11" height="11" viewBox="0 0 24 24" fill="none" stroke="var(--color-text-tertiary)" strokeWidth="2.4" strokeLinecap="round"><path d="M4 6h16M4 12h16M4 18h16"/><circle cx="9" cy="6" r="2.4" fill="var(--color-surface-secondary)"/><circle cx="15" cy="12" r="2.4" fill="var(--color-surface-secondary)"/><circle cx="7" cy="18" r="2.4" fill="var(--color-surface-secondary)"/></svg>}
                            <span style={{ fontFamily: 'var(--font)', fontSize: 9.5, fontWeight: 700, letterSpacing: '0.12em', textTransform: 'uppercase', color: 'var(--color-text-tertiary)' }}>{s.h}</span>
                          </div>
                        )}
                        {s.items.map((o) => (
                          <div key={o.k} style={{ display: 'flex', alignItems: 'center', gap: 18, padding: '11px 14px', borderTop: row++ ? '1px solid var(--color-border)' : 'none' }}>
                      <div style={{ flex: 1, minWidth: 0 }}>
                        <div style={{ display: 'flex', alignItems: 'center', gap: 6, fontFamily: 'var(--font)', fontSize: 12.5, fontWeight: 600, color: 'var(--color-text-primary)' }}>{o.l}{o.tip && <InfoDot tip={o.tip} />}</div>
                        {o.d && <div style={{ fontFamily: 'var(--font)', fontSize: 11.5, color: 'var(--color-text-tertiary)', marginTop: 2, lineHeight: 1.45 }}>{o.d}</div>}
                      </div>
                      {o.t === 'toggle' && <Toggle on={getOpt(b.id, o)} onChange={(v) => setOpt(b.id, o.k, v)} />}
                      {o.t === 'select' && <AdmSelect width={170} value={getOpt(b.id, o)} onChange={(v) => setOpt(b.id, o.k, v)} options={o.o} />}
                      {o.t === 'text' && <input className="adm-input" style={{ width: 220 }} placeholder={o.ph} value={getOpt(b.id, o)} onChange={(e) => setOpt(b.id, o.k, e.target.value)} />}
                      {o.t === 'seg' && <OptSeg value={getOpt(b.id, o)} options={o.o} onChange={(v) => setOpt(b.id, o.k, v)} />}
                      {o.t === 'swatch' && <SwatchRow value={getOpt(b.id, o)} options={o.o} onChange={(v) => setOpt(b.id, o.k, v)} />}
                    </div>
                        ))}
                      </React.Fragment>
                    ));
                  })()}
                </div>
              </div>
            </div>
          )}
          </React.Fragment>
          );
        })}
      </div>
    </div>
  );
}

function PageDetail({ pg, groupLabel, onBack, onChange, onSave, saved }) {
  const isHome = pg.group === 'home';
  const variants = isHome ? [
    { id: 'Hero', d: 'Hero banner + feature strip' },
    { id: 'Storefront', d: 'Product cards, pricing-led' },
    { id: 'Portal', d: 'Login-first, minimal chrome' },
    { id: 'Domain search', d: 'Search bar front and centre' },
    { id: 'Landing', d: 'Long-form marketing sections' },
    { id: 'Redirect', d: 'Send straight to another page' },
  ] : [
    { id: 'Default', d: 'Standard layout, all options' },
    { id: 'Cards', d: 'Card-grid, great for lists' },
    { id: 'Compact', d: 'Tight spacing' },
    { id: 'Hero', d: 'Large hero header' },
  ];
  const tplSettings = isHome ? {
    Hero: [{ k: 'heroImg', type: 'toggle', label: 'Show hero image' }, { k: 'heroCta', type: 'select', label: 'Primary action', opts: ['Order now', 'Client login', 'Domain search', 'None'] }, { k: 'featureStrip', type: 'toggle', label: 'Feature strip below hero' }],
    Storefront: [{ k: 'cols', type: 'select', label: 'Product columns', opts: ['2', '3', '4'] }, { k: 'showPricing', type: 'toggle', label: 'Show pricing on cards' }, { k: 'groupFilter', type: 'toggle', label: 'Product group filter' }],
    Portal: [{ k: 'portalSide', type: 'select', label: 'Login form position', opts: ['Centre', 'Left', 'Right'] }, { k: 'portalBg', type: 'toggle', label: 'Background image' }],
    'Domain search': [{ k: 'tldStrip', type: 'toggle', label: 'Show popular TLD strip' }, { k: 'transferTab', type: 'toggle', label: 'Include transfer tab' }],
    Landing: [{ k: 'sections', type: 'select', label: 'Sections', opts: ['Features + pricing', 'Features + FAQ', 'Full (all sections)'] }, { k: 'testimonials', type: 'toggle', label: 'Testimonials block' }],
    Redirect: [{ k: 'redirectTo', type: 'select', label: 'Redirect to', opts: ['Client login', 'Account dashboard', 'Store', 'Knowledgebase'] }],
  } : {
    Default: [],
    Cards: [{ k: 'cols', type: 'select', label: 'Columns', opts: ['2', '3', '4'] }, { k: 'cardIcons', type: 'toggle', label: 'Show icons on cards' }],
    Compact: [{ k: 'density', type: 'select', label: 'Density', opts: ['Comfortable', 'Compact', 'Dense'] }],
    Hero: [{ k: 'heroImg', type: 'toggle', label: 'Show hero image' }, { k: 'heroBust', type: 'toggle', label: 'Show portrait bust' }],
  };
  const [tpl, setTpl] = React.useState({ cols: '3', cardIcons: true, density: 'Comfortable', heroImg: true, heroBust: false, heroCta: 'Order now', featureStrip: true, showPricing: true, groupFilter: false, portalSide: 'Centre', portalBg: true, tldStrip: true, transferTab: true, sections: 'Features + pricing', testimonials: false, redirectTo: 'Client login' });
  const [pageOpts, setPageOpts] = React.useState({ breadcrumbs: true, pageTitle: true, sidebar: true });
  const [customLayout, setCustomLayout] = React.useState(false);
  const [seoEnabled, setSeoEnabled] = React.useState(!!pg.seo);
  const SEO_LANGS = [['en', 'English'], ['es', 'Español'], ['de', 'Deutsch'], ['fr', 'Français'], ['it', 'Italiano'], ['pt', 'Português'], ['nl', 'Nederlands'], ['pl', 'Polski'], ['ru', 'Русский'], ['tr', 'Türkçe'], ['ar', 'العربية'], ['he', 'עברית'], ['sv', 'Svenska'], ['da', 'Dansk'], ['no', 'Norsk'], ['fi', 'Suomi'], ['cs', 'Čeština'], ['el', 'Ελληνικά'], ['ro', 'Română'], ['hu', 'Magyar'], ['uk', 'Українська'], ['zh', '中文'], ['ja', '日本語'], ['ko', '한국어'], ['hi', 'हिन्दी'], ['id', 'Bahasa'], ['th', 'ไทย'], ['vi', 'Tiếng Việt']];
  const [seoLang, setSeoLang] = React.useState('en');
  const [seoBulk, setSeoBulk] = React.useState(false);
  const [seoI18n, setSeoI18n] = React.useState({ en: { title: pg.seoTitle || '', desc: pg.seoDesc || '' } });
  const seoCur = seoI18n[seoLang] || { title: '', desc: '' };
  const setSeoField = (k, v) => setSeoI18n((s) => ({ ...s, [seoLang]: { ...(s[seoLang] || { title: '', desc: '' }), [k]: v } }));
  const translatedCount = SEO_LANGS.filter(([c]) => seoI18n[c] && (seoI18n[c].title || seoI18n[c].desc)).length;
  const setT = (k, v) => setTpl((s) => ({ ...s, [k]: v }));
  const setPO = (k, v) => setPageOpts((s) => ({ ...s, [k]: v }));
  const settings = tplSettings[pg.variant] || [];

  const SubHead = ({ children }) => <div style={{ fontFamily: 'var(--font)', fontSize: 11, fontWeight: 700, letterSpacing: '0.1em', textTransform: 'uppercase', color: 'var(--color-text-tertiary)', margin: '4px 0 12px' }}>{children}</div>;

  return (
    <div>
      <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', padding: '8px 0 4px' }}>
        <button onClick={onBack} style={{ background: 'none', border: 'none', cursor: 'pointer', color: 'var(--color-text-secondary)', fontFamily: 'var(--font)', fontSize: 14, fontWeight: 500, display: 'inline-flex', alignItems: 'center', gap: 6 }}>‹ Pages</button>
        <SaveBar onSave={onSave} />
      </div>
      <PageHead eyebrow={groupLabel} title={pg.name} sub={pg.desc} />
      {saved && <div className="adm-alert success"><span className="adm-alert-ico"><AI d={AP.check} size={12} sw={3} /></span> Page settings saved.</div>}

      <div style={{ display: 'grid', gridTemplateColumns: '1fr 300px', gap: 20, alignItems: 'start' }}>
        {/* main column */}
        <div style={{ display: 'flex', flexDirection: 'column', gap: 20 }}>
          {/* 1. Page template */}
          <div className="adm-card pad">
            <SubHead>Page template</SubHead>
            <div style={{ display: 'grid', gridTemplateColumns: 'repeat(2, 1fr)', gap: 10 }}>
              {variants.map((v) => (
                <button key={v.id} onClick={() => onChange('variant', v.id)} style={{
                  textAlign: 'left', padding: 14, borderRadius: 10, cursor: 'pointer',
                  background: pg.variant === v.id ? 'var(--color-accent-light)' : 'var(--color-surface)',
                  border: `1px solid ${pg.variant === v.id ? 'var(--color-accent)' : 'var(--color-border)'}`,
                }}>
                  <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
                    <span style={{ fontFamily: 'var(--font)', fontSize: 14, fontWeight: 600, color: 'var(--color-text-primary)' }}>{v.id}</span>
                    {pg.variant === v.id && <span className="adm-badge green">Active</span>}
                  </div>
                  <div style={{ fontFamily: 'var(--font)', fontSize: 12, color: 'var(--color-text-tertiary)', marginTop: 4, lineHeight: 1.4 }}>{v.d}</div>
                </button>
              ))}
            </div>

            <div style={{ borderTop: '1px solid var(--color-border)', margin: '20px 0 16px' }}></div>
            <SubHead>Template settings</SubHead>
            {settings.length === 0 ? (
              <div style={{ fontFamily: 'var(--font)', fontSize: 13, color: 'var(--color-text-tertiary)', padding: '4px 0' }}>There are no settings for the current option.</div>
            ) : (
              <div style={{ display: 'flex', flexDirection: 'column', gap: 4 }}>
                {settings.map((s) => s.type === 'toggle' ? (
                  <SetRow key={s.k} title={s.label} control={<Toggle on={tpl[s.k]} onChange={(v) => setT(s.k, v)} />} />
                ) : (
                  <SetRow key={s.k} title={s.label} control={
                    <select className="adm-select" style={{ width: 160 }} value={tpl[s.k]} onChange={(e) => setT(s.k, e.target.value)}>
                      {s.opts.map((o) => <option key={o} value={o}>{o}</option>)}
                    </select>
                  } />
                ))}
              </div>
            )}
          </div>

          {/* 2. Homepage blocks */}
          {isHome && <HomeBlocks key={pg.variant} variant={pg.variant} />}

          {/* 3. Page settings */}
          <div className="adm-card pad">
            <SubHead>Page settings</SubHead>            <SetRow title="Visibility" help="Who can reach this page." control={
              <select className="adm-select" style={{ width: 170 }} value={pg.visibility} onChange={(e) => onChange('visibility', e.target.value)}>
                <option value="public">Public — anyone</option>
                <option value="auth">Authenticated only</option>
                <option value="disabled">Disabled — 404</option>
              </select>
            } />
            <SetRow title="Show breadcrumbs" help="Display the breadcrumb trail on this page." control={<Toggle on={pageOpts.breadcrumbs} onChange={(v) => setPO('breadcrumbs', v)} />} />
            <SetRow title="Show page title" help="Render the page heading at the top." control={<Toggle on={pageOpts.pageTitle} onChange={(v) => setPO('pageTitle', v)} />} />
            <SetRow title="Show sidebar" help="Display the section sidebar on this page." control={<Toggle on={pageOpts.sidebar} onChange={(v) => setPO('sidebar', v)} />} />
          </div>
        </div>

        {/* sidebar */}
        <div style={{ display: 'flex', flexDirection: 'column', gap: 20 }}>
          {/* SEO */}
          <div className="adm-card pad">
            <SetRow title="SEO" help="Manage how this page appears in search." control={<Toggle on={seoEnabled} onChange={(v) => { setSeoEnabled(v); onChange('seo', v); }} />} />
            {seoEnabled && (
              <div style={{ marginTop: 14 }}>
                <Field label="Indexing">
                  <select className="adm-select" value={pg.indexing} onChange={(e) => onChange('indexing', e.target.value)}>
                    <option value="inherit">Inherit (follow global)</option>
                    <option value="allow">Allow indexing</option>
                    <option value="disallow">Disallow indexing</option>
                  </select>
                </Field>
                {/* Per-language SEO */}
                <div style={{ marginTop: 16, paddingTop: 14, borderTop: '1px solid var(--color-border)' }}>
                  <div style={{ display: 'flex', alignItems: 'center', gap: 8, marginBottom: 8 }}>
                    <span style={{ fontFamily: 'var(--font)', fontSize: 11.5, fontWeight: 500, color: 'var(--color-text-secondary)' }}>Language</span>
                    <InfoDot tip="Provide translated title and description per language. Untranslated languages fall back to English." />
                    <span style={{ marginLeft: 'auto', fontFamily: 'var(--font)', fontSize: 11.5, fontWeight: 600, color: 'var(--green-ink)' }}>{translatedCount}/{SEO_LANGS.length} translated</span>
                  </div>
                  <AdmSelect value={seoLang} onChange={setSeoLang} options={SEO_LANGS.map(([code, name]) => [code, (seoI18n[code] && (seoI18n[code].title || seoI18n[code].desc)) ? `${name}  ✓` : name])} />
                  <button className="adm-preview-btn" style={{ marginTop: 8, width: '100%', display: 'inline-flex', alignItems: 'center', justifyContent: 'center', gap: 6 }} onClick={() => setSeoBulk(true)}><AI d={AP.globe} size={13} /> Edit all languages</button>
                  <div style={{ marginTop: 14 }}>
                    <div style={{ display: 'flex', alignItems: 'center', gap: 6, marginBottom: 6 }}>
                      <span style={{ fontFamily: 'var(--font)', fontSize: 11.5, fontWeight: 500, color: 'var(--color-text-secondary)' }}>SEO title</span>
                      <InfoDot tip="The <title> tag and search-result headline for this page. Aim for 50–60 characters; longer titles get truncated by Google." />
                      <span style={{ marginLeft: 'auto', fontFamily: 'var(--font)', fontSize: 11, color: 'var(--color-text-quaternary)' }}>{seoCur.title.length}/64</span>
                    </div>
                    <input className="adm-input" style={{ width: '100%' }} maxLength={64} value={seoCur.title} onChange={(e) => setSeoField('title', e.target.value)} placeholder={seoLang === 'en' ? pg.name : 'Translate title…'} />
                  </div>
                  <div style={{ marginTop: 14 }}>
                    <div style={{ display: 'flex', alignItems: 'center', gap: 6, marginBottom: 6 }}>
                      <span style={{ fontFamily: 'var(--font)', fontSize: 11.5, fontWeight: 500, color: 'var(--color-text-secondary)' }}>SEO description</span>
                      <InfoDot tip="The meta description shown under the title in search results. Keep it under 160 characters — it doesn’t affect ranking, but it drives click-through." />
                      <span style={{ marginLeft: 'auto', fontFamily: 'var(--font)', fontSize: 11, color: 'var(--color-text-quaternary)' }}>{seoCur.desc.length}/160</span>
                    </div>
                    <textarea className="adm-textarea" style={{ width: '100%' }} rows={3} maxLength={160} value={seoCur.desc} onChange={(e) => setSeoField('desc', e.target.value)} placeholder={seoLang === 'en' ? '' : 'Translate description…'}></textarea>
                  </div>
                </div>
                <div style={{ marginTop: 14 }}>
                  <Field label="Social image URL"><input className="adm-input" placeholder="https://… (1200×630)" /></Field>
                </div>
              </div>
            )}
          </div>

          {/* Custom layout */}
          <div className="adm-card pad">
            <SetRow title={<span style={{ display: 'inline-flex', alignItems: 'center', gap: 6 }}>Custom layout <InfoDot tip="Override the site-wide Layouts settings for this page only — set its own main menu, footer, and content width." /></span>} help="Override the global layout for this page." control={<Toggle on={customLayout} onChange={setCustomLayout} />} />
            {customLayout && (
              <div style={{ marginTop: 14, display: 'flex', flexDirection: 'column', gap: 14 }}>
                <Field label="Main menu"><select className="adm-select"><option>Top nav</option><option>Sidebar</option><option>Icon rail</option><option>Extended</option></select></Field>
                <Field label="Footer"><select className="adm-select"><option>Default</option><option>Minimal</option><option>Columns</option></select></Field>
                <Field label="Content width"><select className="adm-select"><option>Boxed</option><option>Full width</option><option>Fluid</option></select></Field>
              </div>
            )}
          </div>
        </div>
      </div>
      {seoBulk && <SeoBulkModal langs={SEO_LANGS} data={seoI18n} pageName={pg.name} onChange={setSeoI18n} onClose={() => setSeoBulk(false)} />}
    </div>
  );
}

// All-languages SEO editor — every translation visible and editable at once.
function SeoBulkModal({ langs, data, pageName, onChange, onClose }) {
  const [q, setQ] = React.useState('');
  const [onlyMissing, setOnlyMissing] = React.useState(false);
  const [draft, setDraft] = React.useState(() => {
    const d = {};
    langs.forEach(([c]) => { d[c] = { title: (data[c] && data[c].title) || '', desc: (data[c] && data[c].desc) || '' }; });
    return d;
  });
  React.useEffect(() => {
    const onKey = (e) => e.key === 'Escape' && onClose();
    document.addEventListener('keydown', onKey);
    return () => document.removeEventListener('keydown', onKey);
  }, []);
  const setF = (code, k, v) => setDraft((s) => ({ ...s, [code]: { ...s[code], [k]: v } }));
  const filled = (c) => !!(draft[c] && (draft[c].title || draft[c].desc));
  const done = langs.filter(([c]) => filled(c)).length;
  const rows = langs.filter(([c, n]) => {
    if (onlyMissing && filled(c)) return false;
    if (!q.trim()) return true;
    const s = q.trim().toLowerCase();
    return n.toLowerCase().includes(s) || c.includes(s);
  });
  const copyEnToEmpty = () => {
    const en = draft.en || { title: '', desc: '' };
    setDraft((s) => {
      const next = { ...s };
      langs.forEach(([c]) => { if (c !== 'en' && !next[c].title && !next[c].desc) next[c] = { title: en.title, desc: en.desc }; });
      return next;
    });
  };
  const clearAll = () => setDraft((s) => { const n = { ...s }; langs.forEach(([c]) => { if (c !== 'en') n[c] = { title: '', desc: '' }; }); return n; });
  const apply = () => { onChange(draft); onClose(); };

  const COLS = '150px 1fr 1fr';
  const th = { fontFamily: 'var(--font)', fontSize: 10, fontWeight: 700, letterSpacing: '0.1em', textTransform: 'uppercase', color: 'var(--color-text-quaternary)' };
  const inp = { width: '100%', fontSize: 13, padding: '8px 10px', fontFamily: 'var(--font)', background: 'var(--color-surface)', border: '1px solid var(--color-border)', borderRadius: 8, color: 'var(--color-text-primary)', outline: 'none', resize: 'vertical' };

  return (
    <div onClick={onClose} style={{ position: 'fixed', inset: 0, zIndex: 200, background: 'rgba(0,0,0,0.45)', backdropFilter: 'blur(4px)', display: 'flex', alignItems: 'center', justifyContent: 'center', padding: 28 }}>
      <div onClick={(e) => e.stopPropagation()} style={{ width: 'min(1040px, 96vw)', maxHeight: '90vh', background: 'var(--color-surface)', borderRadius: 18, boxShadow: '0 30px 80px rgba(0,0,0,0.4)', display: 'flex', flexDirection: 'column', overflow: 'hidden' }}>
        {/* head */}
        <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', gap: 16, padding: '16px 20px', borderBottom: '1px solid var(--color-border)' }}>
          <div>
            <div style={{ fontFamily: 'var(--font)', fontSize: 16, fontWeight: 600, color: 'var(--color-text-primary)' }}>SEO translations — {pageName}</div>
            <div style={{ fontFamily: 'var(--font)', fontSize: 12.5, color: 'var(--color-text-tertiary)', marginTop: 2 }}>{done}/{langs.length} languages have content · empty languages fall back to English.</div>
          </div>
          <button onClick={onClose} style={{ width: 32, height: 32, borderRadius: '50%', border: '1px solid var(--color-border)', background: 'var(--color-surface)', cursor: 'pointer', color: 'var(--color-text-secondary)', fontSize: 16, flexShrink: 0 }}>×</button>
        </div>
        {/* toolbar */}
        <div style={{ display: 'flex', alignItems: 'center', gap: 10, padding: '12px 20px', borderBottom: '1px solid var(--color-border)', background: 'var(--color-surface-secondary)', flexWrap: 'wrap' }}>
          <input value={q} onChange={(e) => setQ(e.target.value)} placeholder="Filter languages…" style={{ ...inp, width: 200 }} />
          <label style={{ display: 'inline-flex', alignItems: 'center', gap: 7, cursor: 'pointer', fontFamily: 'var(--font)', fontSize: 12.5, color: 'var(--color-text-secondary)' }}>
            <input type="checkbox" checked={onlyMissing} onChange={(e) => setOnlyMissing(e.target.checked)} style={{ accentColor: 'var(--color-accent)', width: 15, height: 15 }} />
            Only missing
          </label>
          <div style={{ flex: 1 }}></div>
          <button className="btn btn-outline" style={{ padding: '7px 13px', fontSize: 12.5 }} onClick={copyEnToEmpty}>Copy English → empty</button>
          <button className="btn btn-outline" style={{ padding: '7px 13px', fontSize: 12.5 }} onClick={clearAll}>Clear translations</button>
        </div>
        {/* table */}
        <div style={{ overflow: 'auto', padding: '0 20px 8px' }}>
          <div style={{ display: 'grid', gridTemplateColumns: COLS, gap: 12, padding: '14px 0 8px', position: 'sticky', top: 0, background: 'var(--color-surface)', zIndex: 2 }}>
            <span style={th}>Language</span><span style={th}>SEO title</span><span style={th}>SEO description</span>
          </div>
          {rows.length === 0 && <div style={{ fontFamily: 'var(--font)', fontSize: 13, color: 'var(--color-text-tertiary)', padding: '18px 0' }}>No languages match.</div>}
          {rows.map(([code, name]) => (
            <div key={code} style={{ display: 'grid', gridTemplateColumns: COLS, gap: 12, alignItems: 'start', padding: '9px 0', borderTop: '1px solid var(--color-border)' }}>
              <div style={{ display: 'flex', alignItems: 'center', gap: 8, paddingTop: 8 }}>
                <span style={{ width: 7, height: 7, borderRadius: '50%', background: filled(code) ? 'var(--green)' : 'var(--color-text-quaternary)', flexShrink: 0 }}></span>
                <span style={{ fontFamily: 'var(--font)', fontSize: 13, fontWeight: 600, color: 'var(--color-text-primary)' }}>{name}</span>
                <span style={{ fontFamily: 'var(--font-mono, monospace)', fontSize: 10.5, color: 'var(--color-text-quaternary)', textTransform: 'uppercase' }}>{code}</span>
              </div>
              <div>
                <input value={draft[code].title} maxLength={64} onChange={(e) => setF(code, 'title', e.target.value)} placeholder={code === 'en' ? pageName : 'Falls back to English'} style={inp} />
                <div style={{ fontFamily: 'var(--font)', fontSize: 10.5, color: 'var(--color-text-quaternary)', marginTop: 3 }}>{draft[code].title.length}/64</div>
              </div>
              <div>
                <textarea value={draft[code].desc} rows={2} maxLength={160} onChange={(e) => setF(code, 'desc', e.target.value)} placeholder={code === 'en' ? '' : 'Falls back to English'} style={inp}></textarea>
                <div style={{ fontFamily: 'var(--font)', fontSize: 10.5, color: 'var(--color-text-quaternary)', marginTop: 3 }}>{draft[code].desc.length}/160</div>
              </div>
            </div>
          ))}
        </div>
        {/* foot */}
        <div style={{ display: 'flex', justifyContent: 'flex-end', gap: 10, padding: '14px 20px', borderTop: '1px solid var(--color-border)' }}>
          <button className="btn btn-outline" onClick={onClose}>Cancel</button>
          <button className="btn btn-primary" onClick={apply}>Apply translations</button>
        </div>
      </div>
    </div>
  );
}

function StyleTokenRow({ name, value }) {
  const [v, setV] = React.useState(value);
  return (
    <div style={{ display: 'flex', alignItems: 'center', gap: 10, padding: '7px 0' }}>
      <span style={{ flex: 1, fontFamily: 'var(--font)', fontSize: 12.5, color: 'var(--color-text-secondary)', fontWeight: 500 }}>{name}</span>
      <input type="color" value={v.startsWith('rgba') ? '#0071e3' : v} onChange={(e) => setV(e.target.value)} style={{ width: 28, height: 28, border: '1px solid var(--color-border)', borderRadius: 6, padding: 2, background: 'var(--color-surface)', cursor: 'pointer' }} />
      <input type="text" value={v} onChange={(e) => setV(e.target.value)} style={{ width: 120, padding: '5px 8px', fontFamily: 'var(--font-mono)', fontSize: 11, background: 'var(--color-surface)', border: '1px solid var(--color-border)', borderRadius: 6, color: 'var(--color-text-primary)', outline: 'none' }} />
    </div>
  );
}

function ColorTok({ n, v, d }) {
  const [val, setVal] = React.useState(v);
  const empty = !val;
  const hex = (() => {
    if (/^#[0-9a-f]{6}$/i.test(val)) return val;
    const m = (val || '').match(/rgba?\(\s*(\d+)\s*,\s*(\d+)\s*,\s*(\d+)/i);
    if (m) return '#' + [m[1], m[2], m[3]].map((x) => (+x).toString(16).padStart(2, '0')).join('');
    return '#888888';
  })();
  const onPick = (h) => {
    const m = (val || '').match(/rgba\(\s*\d+\s*,\s*\d+\s*,\s*\d+\s*,\s*([\d.]+)\s*\)/i);
    if (m) {
      const r = parseInt(h.slice(1, 3), 16), g = parseInt(h.slice(3, 5), 16), b = parseInt(h.slice(5, 7), 16);
      setVal(`rgba(${r},${g},${b},${m[1]})`);
    } else setVal(h);
  };
  return (
    <div style={{ minWidth: 0 }}>
      <div style={{ display: 'flex', alignItems: 'center', gap: 5, marginBottom: 6 }}>
        <span style={{ fontFamily: 'var(--font)', fontSize: 12.5, fontWeight: 600, color: 'var(--color-text-primary)' }}>{n}</span>
        {d && <InfoDot tip={d} />}
      </div>
      <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
        <label style={{ width: 26, height: 26, borderRadius: 8, flexShrink: 0, border: '1px solid var(--color-border)', cursor: 'pointer', position: 'relative', overflow: 'hidden', display: 'block', background: empty ? 'var(--color-surface) linear-gradient(135deg, transparent 46%, #ff3b30 46%, #ff3b30 54%, transparent 54%)' : val }} title="Open colour picker">
          <input type="color" value={hex} onChange={(e) => onPick(e.target.value)} style={{ position: 'absolute', inset: 0, opacity: 0, cursor: 'pointer', width: '100%', height: '100%' }} />
        </label>
        <input value={val} onChange={(e) => setVal(e.target.value)} placeholder={empty ? 'inherit' : ''} spellCheck={false} style={{ width: '100%', minWidth: 0, fontFamily: 'var(--font-mono)', fontSize: 11.5, padding: '7px 10px', border: '1px solid var(--color-border)', borderRadius: 8, background: 'var(--color-surface)', color: 'var(--color-text-primary)', outline: 'none' }} />
      </div>
    </div>
  );
}
function ColorsPanel({ mode, setMode }) {
  const L = mode === 'light';
  const pk = (l, dk) => (L ? l : dk);
  const [preset, setPreset] = React.useState('Default');
  const [brandCol, setBrandCol] = React.useState('#7c46fb');
  const [rebuild, setRebuild] = React.useState({ 'Brand': true, 'Neutrals': true, 'Status': false, 'Icons & blocks': false });
  const [tint, setTint] = React.useState(30);
  const [navStyle, setNavStyle] = React.useState('Light');
  const [genMsg, setGenMsg] = React.useState(null);
  const presets = [['Default', '#0071e3'], ['Emerald', '#30d158'], ['Violet', '#af52de'], ['Rose', '#ff2d55'], ['Amber', '#ff9f0a'], ['Slate', '#3f4a55']];
  const lbl = { fontFamily: 'var(--font)', fontSize: 10, fontWeight: 700, letterSpacing: '0.12em', textTransform: 'uppercase', color: 'var(--color-text-tertiary)' };
  const groups = [
    { g: 'Brand', t: [
      { n: 'Accent', v: pk('#0071e3', '#0a84ff'), d: 'Primary buttons, active states, focus rings.' },
      { n: 'Accent hover', v: pk('#0077ed', '#409cff'), d: 'Follows the Accent. Set a value only to break that link — the swatch shows stock, not the derived colour.' },
      { n: 'Accent tint', v: pk('rgba(0,113,227,0.08)', 'rgba(10,132,255,0.14)'), d: 'The translucent wash behind selected rows and pills.' },
      { n: 'On accent', v: '#ffffff', d: 'Text and icons sitting ON a filled accent surface. Stays light in both modes.' },
      { n: 'Link', v: pk('#0066cc', '#2997ff'), d: 'Follows the Accent: darker than it in light mode, equal in dark.' },
      { n: 'Link hover', v: pk('#0071e3', '#409cff'), d: 'Follows the Accent automatically.' },
    ] },
    { g: 'Surfaces', t: [
      { n: 'Page', v: pk('#fbfbfd', '#101013'), d: 'Behind everything.' },
      { n: 'Surface', v: pk('#ffffff', '#1c1c1e'), d: 'Cards, panels, tables.' },
      { n: 'Surface 2', v: pk('#f5f5f7', '#2c2c2e'), d: 'Insets on a card: fields, wells.' },
      { n: 'Surface 3', v: pk('#fafafc', '#232326'), d: 'The ordinal inverts: lighter than Surface 2 in light, darker in dark.' },
    ] },
    { g: 'Text', t: [
      { n: 'Primary', v: pk('#1d1d1f', '#f5f5f7'), d: 'Headings and body copy.' },
      { n: 'Secondary', v: pk('#6e6e73', '#a1a1a6') },
      { n: 'Tertiary', v: pk('#86868b', '#86868b'), d: 'Captions and meta — only ~3–4:1 on a light card, never for real text.' },
      { n: 'Quaternary', v: pk('#aeaeb2', '#636366'), d: 'Placeholders only.' },
    ] },
    { g: 'Borders', t: [
      { n: 'Border', v: pk('#e8e8eb', '#38383a') },
      { n: 'Border light', v: pk('#f0f0f3', '#2c2c2e') },
      { n: 'Card border', v: pk('rgba(0,0,0,0.04)', 'rgba(255,255,255,0.06)'), d: 'Translucent, so it tints whatever is behind the card.' },
    ] },
    { g: 'Status & badges', note: 'Hues stay put in both modes; the fills carry the alpha.', t: [
      { n: 'Success', v: '#00d34e', d: 'The dot or fill. Pair with Success text for the label.' },
      { n: 'Success text', v: pk('#008c34', '#30d158') },
      { n: 'Success fill', v: 'rgba(0,211,78,0.12)' },
      { n: 'Warning', v: '#ff9f09' },
      { n: 'Warning text', v: pk('#c27400', '#ffb340') },
      { n: 'Warning fill', v: 'rgba(255,159,9,0.14)' },
      { n: 'Danger', v: '#ff3b30' },
      { n: 'Danger text', v: pk('#d70814', '#ff6961') },
      { n: 'Danger fill', v: 'rgba(255,59,48,0.12)' },
      { n: 'Info', v: '#0071e3', d: 'Separate from the Accent on purpose — Info need not follow a rebrand.' },
      { n: 'Info fill', v: 'rgba(0,113,227,0.10)' },
      { n: 'Neutral', v: '#6e6e72' },
      { n: 'Neutral fill', v: 'rgba(142,142,147,0.14)' },
    ] },
    { g: 'Navigation & bars', extra: true, t: [
      { n: 'Sidebar colour', v: '', d: 'Shortcut: one colour, and every row below derives from it. Leave empty when using a style.' },
      { n: 'Sidebar background', v: pk('rgba(246,246,248,0.72)', 'rgba(22,22,23,0.72)'), d: 'Translucent — it hosts whatever scrolls under it.' },
      { n: 'Flyout panel', v: pk('#ffffff', '#1c1c1e'), d: 'The rail layout only. Not the sidebar itself.' },
      { n: 'Text', v: pk('#1d1d21', '#f5f5f7'), d: 'Set this whenever you darken the background, or the menu goes dark-on-dark.' },
      { n: 'Text soft', v: pk('#6e6e72', '#a1a1a6') },
      { n: 'Text muted', v: pk('#86868a', '#86868b'), d: 'Section labels and the user email.' },
      { n: 'Placeholder', v: pk('#aeaeb1', '#636366') },
      { n: 'Border', v: pk('#e8e8eb', '#38383a') },
      { n: 'Search field', v: pk('#f5f5f7', '#2c2c2e') },
      { n: 'Item hover', v: pk('rgba(0,0,0,0.05)', 'rgba(255,255,255,0.06)'), d: 'Sidebar only — the similarly named shared token is not editable here.' },
      { n: 'Item active', v: pk('rgba(0,0,0,0.08)', 'rgba(255,255,255,0.10)') },
      { n: 'Scrollbar', v: pk('rgba(0,0,0,0.20)', 'rgba(255,255,255,0.25)') },
      { n: 'Topbar background', v: pk('rgba(251,251,253,0.72)', 'rgba(16,16,19,0.72)'), d: 'Also translucent — keep some alpha or the frosted effect is lost.' },
    ] },
    { g: 'Icons & avatars', note: 'Same in both modes — they sit on a coloured chip, not the page.', t: [
      { n: 'Blue', v: '#0a84ff' }, { n: 'Purple', v: '#bf5af2' }, { n: 'Orange', v: '#ff9f0a' },
      { n: 'Green', v: '#30d158' }, { n: 'Red', v: '#ff453a' }, { n: 'Teal', v: '#64d2ff' },
      { n: 'Gray', v: '#8e8e93' }, { n: 'Indigo', v: '#5e5ce6' }, { n: 'Pink', v: '#ff375f' },
      { n: 'Avatar from', v: '#5e5ce6', d: 'The user monogram gradient, sidebar and topbar. Previously hardcoded and uncontrollable.' },
      { n: 'Avatar to', v: '#bf5af2' },
    ] },
    { g: 'Block accents', note: 'Free slots for painting dashboard blocks.', t: [
      { n: 'Block accent 1', v: '#991ecf' }, { n: 'Block accent 2', v: '#00988f' }, { n: 'Block accent 3', v: '#af7100' },
    ] },
  ];
  return (
    <div className="adm-card pad">
      <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', gap: 12, flexWrap: 'wrap' }}>
        <div style={{ fontFamily: 'var(--font)', fontSize: 17, fontWeight: 600, letterSpacing: '-0.01em', color: 'var(--color-text-primary)' }}>Color scheme</div>
        <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
          <span style={lbl}>Editing</span>
          <div style={{ display: 'inline-flex', background: 'var(--color-surface-secondary)', padding: 3, borderRadius: 8 }}>
            {['light', 'dark'].map((m) => <button key={m} onClick={() => setMode(m)} style={{ padding: '5px 14px', fontSize: 11, fontWeight: 600, border: 'none', borderRadius: 6, cursor: 'pointer', fontFamily: 'var(--font)', textTransform: 'capitalize', background: mode === m ? 'var(--color-surface)' : 'transparent', color: mode === m ? 'var(--color-accent)' : 'var(--color-text-secondary)' }}>{m}</button>)}
          </div>
        </div>
      </div>
      <div style={{ fontFamily: 'var(--font)', fontSize: 13, color: 'var(--color-text-secondary)', lineHeight: 1.55, margin: '8px 0 14px', maxWidth: 640 }}>Every token below is editable independently. Quick presets just cascade the brand fields (accent, hover, tint, link) — tweak any value after. Only changed tokens are saved, and they apply site-wide.</div>
      <div style={{ display: 'flex', flexWrap: 'wrap', gap: 8 }}>
        {presets.map(([n, c]) => (
          <button key={n} onClick={() => setPreset(n)} style={{ display: 'inline-flex', alignItems: 'center', gap: 8, padding: '6px 13px 6px 7px', background: preset === n ? 'var(--color-accent-light)' : 'var(--color-surface)', border: `1px solid ${preset === n ? 'transparent' : 'var(--color-border)'}`, borderRadius: 999, cursor: 'pointer', fontFamily: 'var(--font)', fontSize: 12, fontWeight: 600, color: preset === n ? 'var(--color-accent)' : 'var(--color-text-primary)' }}>
            <span style={{ width: 18, height: 18, borderRadius: '50%', background: c, display: 'inline-flex', alignItems: 'center', justifyContent: 'center' }}>{preset === n && <AI d={AP.check} size={9} sw={3.4} color="#fff" />}</span>{n}
          </button>
        ))}
      </div>

      {/* generate from one colour */}
      <div style={{ marginTop: 18, background: 'var(--color-surface-secondary)', borderRadius: 12, padding: '16px 18px' }}>
        <div style={{ fontFamily: 'var(--font)', fontSize: 14, fontWeight: 700, letterSpacing: '-0.01em', color: 'var(--color-text-primary)' }}>Generate from one colour</div>
        <div style={{ fontFamily: 'var(--font)', fontSize: 12, color: 'var(--color-text-secondary)', lineHeight: 1.55, margin: '5px 0 14px', maxWidth: 620 }}>Pick your brand colour and rebuild the whole palette around it. Lightness is preserved wherever contrast depends on it, and status colours keep their own hue — a warning stays amber whatever you pick. This writes the <b>{mode}</b> scope only — switch Editing to {L ? 'Dark' : 'Light'} and generate again to do the other one.</div>
        <div style={{ display: 'flex', alignItems: 'flex-end', gap: 22, flexWrap: 'wrap' }}>
          <div>
            <div style={{ ...lbl, marginBottom: 7 }}>Brand colour</div>
            <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
              <label style={{ width: 30, height: 30, borderRadius: 9, background: brandCol, border: '1px solid var(--color-border)', flexShrink: 0, cursor: 'pointer', position: 'relative', overflow: 'hidden', display: 'block' }} title="Open colour picker">
                <input type="color" value={/^#[0-9a-f]{6}$/i.test(brandCol) ? brandCol : '#7c46fb'} onChange={(e) => setBrandCol(e.target.value)} style={{ position: 'absolute', inset: 0, opacity: 0, cursor: 'pointer', width: '100%', height: '100%' }} />
              </label>
              <input value={brandCol} onChange={(e) => setBrandCol(e.target.value)} spellCheck={false} style={{ width: 96, fontFamily: 'var(--font-mono)', fontSize: 12, padding: '8px 10px', border: '1px solid var(--color-border)', borderRadius: 8, background: 'var(--color-surface)', color: 'var(--color-text-primary)', outline: 'none' }} />
            </div>
          </div>
          <div>
            <div style={{ ...lbl, marginBottom: 7 }}>What to rebuild</div>
            <div style={{ display: 'flex', flexWrap: 'wrap', gap: 6 }}>
              {Object.keys(rebuild).map((k) => (
                <button key={k} onClick={() => setRebuild({ ...rebuild, [k]: !rebuild[k] })} style={{ display: 'inline-flex', alignItems: 'center', gap: 6, padding: '7px 13px', borderRadius: 999, cursor: 'pointer', fontFamily: 'var(--font)', fontSize: 12, fontWeight: 600, border: `1px solid ${rebuild[k] ? 'var(--color-accent)' : 'var(--color-border)'}`, background: rebuild[k] ? 'var(--color-accent-light)' : 'var(--color-surface)', color: rebuild[k] ? 'var(--color-accent)' : 'var(--color-text-secondary)' }}>
                  {rebuild[k] && <AI d={AP.check} size={10} sw={3} />}{k}
                </button>
              ))}
            </div>
          </div>
          <div>
            <div style={{ ...lbl, marginBottom: 7 }}>Neutral tint <span style={{ color: 'var(--color-text-secondary)', letterSpacing: 0 }}>· {tint}%</span></div>
            <input type="range" min="0" max="100" step="5" value={tint} onChange={(e) => setTint(+e.target.value)} style={{ width: 170, accentColor: 'var(--color-accent)', display: 'block', margin: '9px 0' }} />
          </div>
          <div style={{ display: 'flex', gap: 8, marginLeft: 'auto' }}>
            <button className="btn btn-primary" onClick={() => setGenMsg(`Palette rebuilt from ${brandCol} — ${Object.keys(rebuild).filter((k) => rebuild[k]).join(', ').toLowerCase() || 'nothing selected'} (${mode}).`)}>Generate</button>
            <button className="btn" onClick={() => setGenMsg(null)}>Undo</button>
          </div>
        </div>
        {genMsg && <div style={{ marginTop: 12, fontFamily: 'var(--font)', fontSize: 12, fontWeight: 600, color: 'var(--color-accent)' }}>{genMsg} Undo restores the saved values.</div>}
      </div>

      {groups.map((g) => (
        <div key={g.g} style={{ marginTop: 20, background: 'var(--color-surface-secondary)', borderRadius: 12, padding: 10 }}>
          <div style={{ display: 'flex', alignItems: 'baseline', gap: 10, padding: '4px 8px 10px', flexWrap: 'wrap' }}>
            <span style={{ fontFamily: 'var(--font)', fontSize: 11, fontWeight: 700, letterSpacing: '0.1em', textTransform: 'uppercase', color: 'var(--color-text-primary)' }}>{g.g}</span>
            {g.note && <span style={{ fontFamily: 'var(--font)', fontSize: 11, color: 'var(--color-text-tertiary)' }}>{g.note}</span>}
          </div>
          <div style={{ background: 'var(--color-surface)', border: '1px solid var(--color-border)', borderRadius: 10, padding: '16px 16px 18px' }}>
            {g.extra && (
              <div style={{ display: 'flex', alignItems: 'center', gap: 10, marginBottom: 16 }}>
                <span style={lbl}>Style</span>
                {[['Light', '#f5f5f7'], ['Tinted', 'var(--color-accent-light)'], ['Brand', 'var(--color-accent)']].map(([n, c]) => (
                  <button key={n} onClick={() => setNavStyle(n)} style={{ display: 'inline-flex', alignItems: 'center', gap: 7, padding: '6px 12px 6px 7px', borderRadius: 999, cursor: 'pointer', fontFamily: 'var(--font)', fontSize: 12, fontWeight: 600, border: `1px solid ${navStyle === n ? 'var(--color-accent)' : 'var(--color-border)'}`, background: 'var(--color-surface)', color: navStyle === n ? 'var(--color-accent)' : 'var(--color-text-secondary)' }}>
                    <span style={{ width: 15, height: 15, borderRadius: '50%', background: c, border: '1px solid var(--color-border)' }}></span>{n}
                  </button>
                ))}
              </div>
            )}
            <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(200px, 1fr))', gap: '16px 20px' }}>
              {g.t.map((t) => <ColorTok key={mode + t.n} {...t} />)}
            </div>
          </div>
        </div>
      ))}
    </div>
  );
}
function StyleDetail({ style, onBack, onSave, saved }) {
  const [top, setTop] = React.useState('variables');
  const [subcat, setSubcat] = React.useState('colors');
  const [mode, setMode] = React.useState('light');
  const [darkPolicy, setDarkPolicy] = React.useState('optional');
  const subcats = ['Colors', 'Typography', 'General', 'Navigation', 'Buttons', 'Forms', 'Elements'];
  return (
    <div>
      <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', padding: '8px 0 4px' }}>
        <button onClick={onBack} style={{ background: 'none', border: 'none', cursor: 'pointer', color: 'var(--color-text-secondary)', fontFamily: 'var(--font)', fontSize: 14, fontWeight: 500 }}>‹ Styles</button>
        <SaveBar onSave={onSave} />
      </div>
      <PageHead eyebrow="Style" title={style.name} sub="Edit the color scheme, typography, and component variables for this style." />
      {saved && <div className="adm-alert success"><span className="adm-alert-ico"><AI d={AP.check} size={12} sw={3} /></span> Style saved.</div>}
      <div className="adm-tabs">
        {[['variables', 'Style variables'], ['css', 'Custom CSS']].map(([id, l]) => <button key={id} className={`adm-tab ${top === id ? 'active' : ''}`} onClick={() => setTop(id)}>{l}</button>)}
      </div>

      {top === 'variables' && (
        <div style={{ display: 'grid', gridTemplateColumns: '180px 1fr', gap: 20, alignItems: 'start' }}>
          {/* sub-nav */}
          <div className="adm-card pad" style={{ position: 'sticky', top: 84, padding: 10 }}>
            {subcats.map((s) => {
              const id = s.toLowerCase();
              return <button key={id} onClick={() => setSubcat(id)} style={{ width: '100%', textAlign: 'left', padding: '8px 12px', borderRadius: 8, marginBottom: 2, border: 'none', cursor: 'pointer', fontFamily: 'var(--font)', fontSize: 13.5, fontWeight: subcat === id ? 600 : 500, background: subcat === id ? 'var(--color-accent-light)' : 'transparent', color: subcat === id ? 'var(--color-accent)' : 'var(--color-text-secondary)' }}>{s}</button>;
            })}
          </div>

          {/* panel */}
          <div style={{ display: 'flex', flexDirection: 'column', gap: 20 }}>
            {subcat === 'colors' ? (
              <>
                <div className="adm-card pad">
                  <div style={{ fontFamily: 'var(--font)', fontSize: 11, fontWeight: 700, letterSpacing: '0.1em', textTransform: 'uppercase', color: 'var(--color-text-tertiary)', marginBottom: 12 }}>Dark mode</div>
                  <div style={{ fontFamily: 'var(--font)', fontSize: 13, color: 'var(--color-text-secondary)', marginBottom: 14, lineHeight: 1.5 }}>Choose how dark mode is handled. <strong>User choice</strong> exposes a visitor toggle; <strong>Forced</strong> always shows dark.</div>
                  <div style={{ display: 'inline-flex', background: 'var(--color-surface-secondary)', padding: 4, borderRadius: 999 }}>
                    {[['off', 'Off'], ['optional', 'User choice'], ['forced', 'Forced dark']].map(([id, l]) => (
                      <button key={id} onClick={() => setDarkPolicy(id)} style={{ padding: '7px 16px', fontSize: 12, fontWeight: 600, border: 'none', borderRadius: 999, cursor: 'pointer', fontFamily: 'var(--font)', background: darkPolicy === id ? 'var(--color-surface)' : 'transparent', color: darkPolicy === id ? 'var(--color-accent)' : 'var(--color-text-secondary)', boxShadow: darkPolicy === id ? '0 1px 3px rgba(0,0,0,0.08)' : 'none' }}>{l}</button>
                    ))}
                  </div>
                </div>
                <ColorsPanel mode={mode} setMode={setMode} />
              </>
            ) : (
              <StylePanel subcat={subcat} />
            )}
          </div>
        </div>
      )}

      {top === 'css' && (
        <div className="adm-card pad">
          <div style={{ fontFamily: 'var(--font)', fontSize: 17, fontWeight: 600, letterSpacing: '-0.01em', color: 'var(--color-text-primary)', marginBottom: 4 }}>Custom CSS</div>
          <div style={{ fontFamily: 'var(--font)', fontSize: 13, color: 'var(--color-text-tertiary)', marginBottom: 14 }}>Injected after the theme styles on every client-area page.</div>
          <textarea className="adm-textarea" rows={12} style={{ fontFamily: 'var(--font-mono)', fontSize: 12 }} placeholder={"/* Example */\n.btn-primary {\n  letter-spacing: 0.01em;\n}"}></textarea>
        </div>
      )}
    </div>
  );
}

function StylesPage() {
  const STYLES = [
    { id: 'imperial', name: 'Imperial', sub: 'Refined & editorial', primary: '#0071e3', accent: '#34aadc' },
    { id: 'aqueduct', name: 'Aqueduct', sub: 'Cool & architectural', primary: '#1f3a5f', accent: '#5ac8fa' },
    { id: 'forum', name: 'Forum', sub: 'Warm & approachable', primary: '#1f3d2e', accent: '#30d158' },
    { id: 'colosseum', name: 'Colosseum', sub: 'Bold & dramatic', primary: '#5b2a2a', accent: '#ff9f0a' },
  ];
  const [active, setActive] = React.useState('imperial');
  const [selected, setSelected] = React.useState(null);
  const [saved, setSaved] = React.useState(false);
  const save = () => { setSaved(true); setTimeout(() => setSaved(false), 2200); };
  const sel = STYLES.find((s) => s.id === selected);
  if (sel) return <StyleDetail style={sel} onBack={() => setSelected(null)} onSave={save} saved={saved} />;

  return (
    <div>
      <PageHead eyebrow="Theme" title="Styles" sub="Pick a style preset, then customize its colors, typography, and components. Dark mode lives inside a style." />
      <div className="adm-card pad">
        <Section title="Available styles" sub={`${STYLES.length} presets`}>
          <div style={{ display: 'grid', gridTemplateColumns: 'repeat(4, 1fr)', gap: 14 }}>
            {STYLES.map((s) => (
              <div key={s.id} style={{
                background: active === s.id ? 'var(--color-accent-light)' : 'var(--color-surface)',
                border: `1px solid ${active === s.id ? 'var(--color-accent)' : 'var(--color-border)'}`,
                borderRadius: 14, padding: 16,
              }}>
                <div style={{ display: 'flex', height: 48, borderRadius: 8, overflow: 'hidden', marginBottom: 14 }}>
                  <div style={{ flex: 2, background: s.primary }}></div>
                  <div style={{ flex: 1, background: s.accent }}></div>
                </div>
                <div style={{ fontFamily: 'var(--font)', fontSize: 16, fontWeight: 600, color: 'var(--color-text-primary)' }}>{s.name}</div>
                <div style={{ fontFamily: 'var(--font)', fontSize: 12, color: 'var(--color-text-tertiary)', marginTop: 2 }}>{s.sub}</div>
                <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginTop: 14 }}>
                  {active === s.id ? <span className="adm-badge green">Active</span> : <button onClick={() => setActive(s.id)} style={{ background: 'none', border: 'none', cursor: 'pointer', color: 'var(--color-text-secondary)', fontFamily: 'var(--font)', fontSize: 12.5, fontWeight: 600 }}>Activate</button>}
                  <button onClick={() => setSelected(s.id)} style={{ background: 'none', border: 'none', cursor: 'pointer', color: 'var(--color-accent)', fontFamily: 'var(--font)', fontSize: 12.5, fontWeight: 600 }}>Customize ›</button>
                </div>
              </div>
            ))}
          </div>
        </Section>
      </div>
    </div>
  );
}

function Tg({ def = true }) { const [v, setV] = React.useState(def); return <Toggle on={v} onChange={setV} />; }

function PxField({ label, value }) {
  const [v, setV] = React.useState(value);
  return (
    <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', gap: 12, padding: '7px 0' }}>
      <span style={{ fontFamily: 'var(--font)', fontSize: 13.5, color: 'var(--color-text-secondary)' }}>{label}</span>
      <div style={{ display: 'flex', alignItems: 'center', gap: 6 }}>
        <input className="adm-input" type="number" value={v} onChange={(e) => setV(e.target.value)} style={{ width: 64, textAlign: 'right' }} />
        <span style={{ fontFamily: 'var(--font)', fontSize: 12, color: 'var(--color-text-tertiary)', width: 14 }}>px</span>
      </div>
    </div>
  );
}
function WeightField({ name, value }) {
  const [v, setV] = React.useState(value);
  return (
    <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', gap: 12, padding: '9px 0' }}>
      <div style={{ display: 'flex', alignItems: 'baseline', gap: 14 }}>
        <span style={{ fontFamily: 'var(--font)', fontWeight: Number(v) || 400, fontSize: 21, lineHeight: 1, color: 'var(--color-text-primary)', width: 36 }}>Aa</span>
        <span style={{ fontFamily: 'var(--font)', fontSize: 13.5, color: 'var(--color-text-secondary)' }}>{name}</span>
      </div>
      <input className="adm-input" type="number" step="100" value={v} onChange={(e) => setV(e.target.value)} style={{ width: 72, textAlign: 'right' }} />
    </div>
  );
}

function StylePanel({ subcat }) {
  const Sel = ({ w = 180, children }) => <select className="adm-select" style={{ width: w }}>{children}</select>;
  const O = (arr) => arr.map((o) => <option key={o}>{o}</option>);
  const Card = ({ title, children }) => (
    <div className="adm-card pad">
      <div style={{ fontFamily: 'var(--font)', fontSize: 17, fontWeight: 600, letterSpacing: '-0.01em', color: 'var(--color-text-primary)', marginBottom: 6 }}>{title}</div>
      {children}
    </div>
  );
  const Sub = ({ children }) => <div style={{ fontFamily: 'var(--font)', fontSize: 10, fontWeight: 700, letterSpacing: '0.12em', textTransform: 'uppercase', color: 'var(--color-text-tertiary)', margin: '18px 0 6px' }}>{children}</div>;
  const grid = { display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '0 32px' };

  if (subcat === 'typography') return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: 20 }}>
      <Card title="Site">
        <div style={{ display: 'flex', flexDirection: 'column', gap: 16, marginTop: 4 }}>
          <Field label="Font family">
            <select className="adm-select" style={{ width: '100%' }} defaultValue="default">
              <option value="default">Default (San Francisco on Apple, bundled Inter on other platforms)</option>
              <option>Inter</option><option>SF Pro</option><option>Georgia</option><option>System UI</option>
            </select>
          </Field>
          <Field label="Google font" hint="Loads the chosen family from Google Fonts.">
            <select className="adm-select" style={{ width: '100%' }} defaultValue="">
              <option value="">— select a Google font —</option>
              {O(['Inter', 'Manrope', 'Roboto', 'Open Sans', 'Lato', 'Poppins', 'Source Sans 3', 'Work Sans'])}
            </select>
          </Field>
          <Field label="Custom font stack" hint="When set, overrides the options above.">
            <input className="adm-input" style={{ width: '100%' }} defaultValue="" placeholder="'My Font', Helvetica, Arial, sans-serif" />
          </Field>
        </div>
      </Card>

      <Card title="Font size">
        <Sub>Body</Sub>
        <div style={grid}>
          <PxField label="Extra Small" value={11} />
          <PxField label="Small" value={12} />
          <PxField label="Base" value={13} />
          <PxField label="Medium" value={14} />
          <PxField label="Large" value={15} />
          <PxField label="Extra Large" value={17} />
          <PxField label="Super Large" value={20} />
          <PxField label="3XL" value={24} />
        </div>
        <div style={{ borderTop: '1px solid var(--color-border)', marginTop: 12 }}></div>
        <Sub>Headings</Sub>
        <div style={grid}>
          <PxField label="Heading h6" value={18} />
          <PxField label="Heading h5" value={20} />
          <PxField label="Heading h4" value={26} />
          <PxField label="Heading h3" value={36} />
          <PxField label="Heading h2" value={40} />
          <PxField label="Heading h1" value={48} />
        </div>
        <div style={{ borderTop: '1px solid var(--color-border)', marginTop: 12 }}></div>
        <Sub>Display</Sub>
        <div style={grid}>
          <PxField label="Display Small" value={56} />
          <PxField label="Display" value={72} />
          <PxField label="Display Large" value={96} />
          <PxField label="Display XL" value={120} />
        </div>
      </Card>

      <Card title="Font weight">
        <div style={{ ...grid, marginTop: 4 }}>
          <WeightField name="Light" value={300} />
          <WeightField name="Base" value={400} />
          <WeightField name="Medium" value={500} />
          <WeightField name="Semibold" value={600} />
          <WeightField name="Bold" value={700} />
          <WeightField name="Black" value={900} />
        </div>
      </Card>
    </div>
  );
  if (subcat === 'general') return (
    <Card title="General">
      <SetRow title="Corner radius" help="Global rounding for cards, inputs, buttons." control={<Sel w={140}>{O(['Sharp', 'Small', 'Medium', 'Large', 'Pill'])}</Sel>} />
      <SetRow title="Content width" control={<Sel>{O(['Boxed', 'Full width', 'Fluid'])}</Sel>} />
      <SetRow title="Spacing density" control={<Sel w={150}>{O(['Compact', 'Comfortable', 'Spacious'])}</Sel>} />
      <SetRow title="Card shadows" help="Use soft shadows instead of borders." control={<Tg def={false} />} />
      <SetRow title="Motion & animation" help="Subtle transitions on hover and reveal." control={<Tg def={true} />} />
    </Card>
  );
  if (subcat === 'navigation') return (
    <Card title="Navigation">
      <SetRow title="Nav height" control={<Sel w={140}>{O(['Compact', 'Standard', 'Tall'])}</Sel>} />
      <SetRow title="Sticky navigation" help="Pin the nav to the top on scroll." control={<Tg def={true} />} />
      <SetRow title="Active indicator" control={<Sel w={150}>{O(['Underline', 'Pill', 'Side bar', 'None'])}</Sel>} />
      <SetRow title="Show icons" help="Display icons next to nav items." control={<Tg def={false} />} />
      <SetRow title="Dropdown style" control={<Sel w={140}>{O(['Classic', 'Mega menu'])}</Sel>} />
    </Card>
  );
  if (subcat === 'buttons') return (
    <Card title="Buttons">
      <SetRow title="Shape" control={<Sel w={140}>{O(['Pill', 'Rounded', 'Sharp'])}</Sel>} />
      <SetRow title="Size" control={<Sel w={140}>{O(['Small', 'Medium', 'Large'])}</Sel>} />
      <SetRow title="Uppercase labels" control={<Tg def={false} />} />
      <Sub>Colors</Sub>
      <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '0 24px' }}>
        <StyleTokenRow name="Primary fill" value="#0071e3" />
        <StyleTokenRow name="Primary text" value="#ffffff" />
        <StyleTokenRow name="Secondary fill" value="#f5f5f7" />
        <StyleTokenRow name="Secondary text" value="#1d1d1f" />
      </div>
    </Card>
  );
  if (subcat === 'forms') return (
    <Card title="Forms">
      <SetRow title="Input shape" control={<Sel w={140}>{O(['Rounded', 'Sharp', 'Pill'])}</Sel>} />
      <SetRow title="Input size" control={<Sel w={140}>{O(['Small', 'Medium', 'Large'])}</Sel>} />
      <SetRow title="Label position" control={<Sel w={140}>{O(['Above', 'Inline'])}</Sel>} />
      <SetRow title="Focus ring" help="Show a tinted glow on focused fields." control={<Tg def={true} />} />
      <Sub>Colors</Sub>
      <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '0 24px' }}>
        <StyleTokenRow name="Input border" value="#d2d2d7" />
        <StyleTokenRow name="Focus ring" value="rgba(0,113,227,0.15)" />
      </div>
    </Card>
  );
  // elements
  return (
    <Card title="Elements">
      <SetRow title="Card border" control={<Tg def={true} />} />
      <SetRow title="Card shadow" control={<Tg def={false} />} />
      <SetRow title="Table row stripes" control={<Tg def={false} />} />
      <SetRow title="Badge style" control={<Sel w={140}>{O(['Soft', 'Solid', 'Outline'])}</Sel>} />
      <SetRow title="Avatar shape" control={<Sel w={140}>{O(['Circle', 'Rounded', 'Square'])}</Sel>} />
    </Card>
  );
}

function Placeholder({ title }) {
  return (
    <div>
      <PageHead eyebrow="Theme" title={title} sub="This section follows the same shell and design vocabulary." />
      <div className="adm-card pad">
        <div className="adm-empty">
          <div className="adm-empty-ico"><AI d={AP.doc} size={22} /></div>
          <div className="adm-empty-title">Coming next</div>
          <div className="adm-empty-text">Info, Settings, Layouts, Branding, and Tools are fully built in this Apple direction. The rest will mirror them.</div>
        </div>
      </div>
    </div>
  );
}

// ── Shell + router ───────────────────────────────────────────────────────
const NAV = [
  { id: 'info', label: 'Info' }, { id: 'settings', label: 'Settings' },
  { id: 'styles', label: 'Styles' }, { id: 'layouts', label: 'Layouts' },
  { id: 'pages', label: 'Pages' }, { id: 'menu', label: 'Menu' },
  { id: 'branding', label: 'Branding' }, { id: 'extensions', label: 'Extensions' },
  { id: 'tools', label: 'Tools' },
];

function AppleAdmin() {
  /* #menu/1 -- a section, optionally a thing inside it */
  /* ?embed=1 renders the section on its own -- no brand bar, no nav, no page
     head -- so another page can frame one part of the panel without reaching
     into this app's DOM to hide the rest. */
  const embed = new URLSearchParams(location.search).get('embed') === '1';
  const route = () => ((location.hash || '#info').replace('#', '') || 'info').split('/');
  const [view, setView] = React.useState(() => route()[0]);
  const [sub, setSub] = React.useState(() => route()[1]);
  const [dark, setDark] = React.useState(() => { try { return localStorage.getItem('hadrian-aadm-theme') === 'dark'; } catch (e) { return false; } });
  React.useEffect(() => {
    const h = () => { const r = route(); setView(r[0]); setSub(r[1]); };
    window.addEventListener('hashchange', h); return () => window.removeEventListener('hashchange', h);
  }, []);
  React.useEffect(() => {
    document.documentElement.setAttribute('data-theme', dark ? 'dark' : 'light');
    try { localStorage.setItem('hadrian-aadm-theme', dark ? 'dark' : 'light'); } catch (e) {}
  }, [dark]);
  const go = (id) => { location.hash = `#${id}`; setView(id); setSub(undefined); };

  let page;
  switch (view) {
    case 'info': page = <InfoPage />; break;
    case 'settings': page = <SettingsPage />; break;
    case 'layouts': page = <LayoutsPage />; break;
    case 'branding': page = <BrandingPage />; break;
    case 'tools': page = <ToolsPage />; break;
    case 'menu': page = <MenuPage open={sub} embed={embed} />; break;
    case 'pages': page = <PagesPage />; break;
    case 'styles': page = <StylesPage />; break;
    default: page = <Placeholder title={NAV.find((n) => n.id === view)?.label || 'Section'} />;
  }

  if (embed) return <div className="admin adm-embedded"><div className="adm-body">{page}</div></div>;
  return (
    <div className="admin">
      <div className="adm-brandbar">
        <div className="adm-brand">
          <span className="brand-mark"></span>
          <div style={{ display: 'flex', flexDirection: 'column', lineHeight: 1.3 }}>
            <span className="adm-brand-name">Caesarthemes</span>
            <span className="adm-brand-sub">Hadrian · Client Theme</span>
          </div>
          <span className="adm-ver">v1.0.0</span>
        </div>
        <div className="adm-brandbar-right">
          <a href="#"><AI d={AP.doc} size={14} /> Docs</a>
          <a href="#"><AI d={AP.bug} size={14} /> Report bug</a>
          <button className="icon-btn" onClick={() => setDark(!dark)} aria-label="Toggle theme"><AI d={dark ? AP.sun : AP.moon} size={17} /></button>
        </div>
      </div>
      <div className="adm-nav">
        <div className="adm-nav-inner">
          {NAV.map((n) => (
            <button key={n.id} className={`adm-pill ${view === n.id ? 'active' : ''}`} onClick={() => go(n.id)}>{n.label}</button>
          ))}
        </div>
      </div>
      <div className="adm-body">{page}</div>
    </div>
  );
}

ReactDOM.createRoot(document.getElementById('root')).render(<AppleAdmin />);
