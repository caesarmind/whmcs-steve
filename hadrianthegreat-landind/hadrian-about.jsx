// hadrian-about.jsx — About Caesarthemes
function Nav() {
  return (
    <nav className="homepage-nav">
      <div className="inner">
        <a href="Hadrian Landing Imperial.html" className="brand">
          <span className="hp-mark"></span>
          <span className="word">Hadrian</span>
        </a>
        <div className="links">
          <a href="Hadrian Landing Imperial.html#features">Features</a>
          <a href="Hadrian Landing Imperial.html#layouts">Layouts</a>
          <a href="Hadrian Landing Imperial.html#extensions">Extensions</a>
          <a href="Hadrian Landing Imperial.html#pricing">Pricing</a>
          <a href="#" className="on">About</a>
        </div>
        <div className="acts">
          <a href="Hadrian Documentation.html" className="hp-btn ghost">Documentation</a>
          <a href="Hadrian Landing Imperial.html#pricing" className="hp-btn solid">Get Hadrian</a>
        </div>
      </div>
    </nav>
  );
}
function Hero() {
  return (
    <header className="ab-hero" data-screen-label="About hero">
      <div className="hp-wrap">
        <div className="hp-eyebrow">About</div>
        <h1>We build the WHMCS<br />client area we wanted.</h1>
        <p>Caesarthemes is a small studio working on one thing: the part of WHMCS your customers actually see. We started because every portal we inherited looked the same, and every change to one meant editing template files that the next update would overwrite.</p>
      </div>
    </header>
  );
}
function Story() {
  return (
    <section className="ab-story" data-screen-label="Story">
      <div className="hp-wrap">
        <div className="grid">
          <div>
            <h2 className="hp-h2">Why Hadrian exists.</h2>
          </div>
          <div className="prose">
            <p>Hosting is a crowded market and the client area is where a customer spends their whole relationship with you — renewals, invoices, tickets, upgrades. It is also the part almost nobody gets to change, because changing it has always meant forking templates and re-forking them after every release.</p>
            <p>Hadrian moves that work into settings. Layouts, styles, menus, the homepage, per-page SEO and a full token editor all live in the database and survive upgrades. Nothing in the theme requires you to open a <code>.tpl</code> file, and nothing you configure is lost when WHMCS ships a new version.</p>
            <p>The theme is named for the emperor who is remembered less for conquest than for what he built and consolidated — walls, roads, a rebuilt Pantheon. That felt closer to the job than another abstract product name.</p>
          </div>
        </div>
      </div>
    </section>
  );
}
const PRINCIPLES = [
  { n: '01', h: 'Everything is a setting', p: 'If a host would reasonably want it different, it belongs in the admin panel — not in a template file, not in a child theme, not in a support ticket.' },
  { n: '02', h: 'Upgrades must be boring', p: 'Configuration lives in the database. A WHMCS release should never cost you a weekend of re-applying customisations.' },
  { n: '03', h: 'Restraint over decoration', p: 'A billing portal is a working tool. We ship six deliberate palettes rather than fifty options, and default to the quietest one that still feels considered.' },
  { n: '04', h: 'Say what it does', p: 'No feature counts we cannot demonstrate, no screenshots that are not the real product, no claims about other people’s software we have not measured.' },
];
function Principles() {
  return (
    <section className="ab-principles" data-screen-label="Principles">
      <div className="hp-wrap">
        <div className="hp-eyebrow">How we work</div>
        <h2 className="hp-h2">Four rules we hold to.</h2>
        <div className="grid">
          {PRINCIPLES.map((x) => (
            <div key={x.n} className="p">
              <span className="n">{x.n}</span>
              <h3>{x.h}</h3>
              <p>{x.p}</p>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}
const WORK = [
  { s: 'Available now', h: 'Hadrian Client Theme', p: 'The client area, rebuilt: three navigation layouts, six styles, four dashboard designs, a homepage composer, menu manager and multi-language SEO.', href: 'Hadrian Landing Imperial.html' },
  { s: 'In development', h: 'Email Template Builder', p: 'WHMCS notification emails composed from blocks, inheriting your brand tokens, with per-language content in one editor.', href: null },
  { s: 'In development', h: 'Invoice Builder', p: 'The invoice PDF and the on-screen invoice designed from the same block set as the homepage composer.', href: null },
  { s: 'In development', h: 'Website Builder', p: 'The public side of the same install — pages, sections and navigation, sharing Hadrian’s design tokens.', href: null },
];
function Work() {
  return (
    <section className="ab-work" data-screen-label="What we make">
      <div className="hp-wrap">
        <div className="hp-eyebrow">What we make</div>
        <h2 className="hp-h2">One theme, and what<br />grows around it.</h2>
        <div className="rows">
          {WORK.map((w) => (
            <article key={w.h} className="row">
              <span className={`st${w.s === 'Available now' ? ' now' : ''}`}>{w.s}</span>
              <div className="c">
                <h3>{w.h}</h3>
                <p>{w.p}</p>
              </div>
              {w.href
                ? <a href={w.href} className="go">See it<span aria-hidden="true">›</span></a>
                : <span className="soon">Roadmap</span>}
            </article>
          ))}
        </div>
      </div>
    </section>
  );
}
function Founding() {
  return (
    <section className="ab-found" data-screen-label="Founding clients">
      <div className="hp-wrap">
        <div className="card">
          <div>
            <div className="hp-eyebrow" style={{ color: 'inherit', opacity: .72 }}>Founding clients</div>
            <h2>The first fifty set the order of the roadmap.</h2>
            <p>We would rather build what fifty hosts actually need than guess at a feature list. Founding clients rank requests in a shared board, get a direct line to the developers, and keep the launch rate on every renewal.</p>
            <div className="acts">
              <a href="Hadrian Landing Imperial.html#pricing" className="hp-btn solid">See the offer</a>
              <a href="#contact" className="hp-btn ghost">Talk to us<span aria-hidden="true">›</span></a>
            </div>
          </div>
          <div className="tally">
            <div className="off">$20<small>/yr</small></div>
            <div className="lbl">single license · was $99</div>
            <div className="bar"><span style={{ width: '32%' }}></span></div>
            <div className="left"><b>34 of 50</b> founding licenses left</div>
          </div>
        </div>
      </div>
    </section>
  );
}
function Contact() {
  const rows = [
    ['Sales and licensing', 'sales@caesarthemes.com'],
    ['Support', 'support@caesarthemes.com'],
    ['Everything else', 'hello@caesarthemes.com'],
  ];
  return (
    <section id="contact" className="ab-contact" data-screen-label="Contact">
      <div className="hp-wrap">
        <div className="grid">
          <div>
            <div className="hp-eyebrow">Contact</div>
            <h2 className="hp-h2">Talk to the people<br />who build it.</h2>
            <p className="lead">There is no support tier between you and the developers. Ask a pre-sales question, request a feature, or send us your current client area and we will tell you honestly whether Hadrian helps.</p>
          </div>
          <div className="rows">
            {rows.map(([l, v]) => (
              <div key={l} className="r">
                <span className="l">{l}</span>
                <a href={`mailto:${v}`}>{v}</a>
              </div>
            ))}
            <div className="r">
              <span className="l">Marketplace</span>
              <a href="#">WHMCS Marketplace listing</a>
            </div>
          </div>
        </div>
      </div>
    </section>
  );
}
function Footer() {
  const cols = [
    { h: 'Products', links: ['Hadrian Client Theme', 'Email Template Builder', 'Invoice Builder', 'Website Builder'] },
    { h: 'Resources', links: ['Documentation', 'Changelog', 'Live Demo', 'Support'] },
    { h: 'Company', links: ['About', 'Contact', 'Refund Policy', 'License Terms'] },
    { h: 'Legal', links: ['Privacy', 'Terms', 'Sitemap'] },
  ];
  return (
    <footer className="hp-footer" data-screen-label="Footer">
      <div className="hp-wrap">
        <div className="hp-footcols">
          <div className="brandcol">
            <a href="Hadrian Landing Imperial.html" className="brand">
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
          <span className="legal"><a href="#">Privacy</a><a href="#">Terms</a><a href="#">Sitemap</a></span>
        </div>
      </div>
    </footer>
  );
}
function About() {
  const [dark, setDark] = React.useState(() => { try { return localStorage.getItem('hadrian-lp5-theme') === 'dark'; } catch (e) { return false; } });
  // The landing stores a style *id* under `hadrian-style`, not a colour, and it
  // stores the mode under `hadrian-lp5-theme` — so carry both across, and write
  // the mode back, or a toggle here is lost on reload.
  const ACCENTS = { blue: '#0071e3', emerald: '#14b17d', violet: '#8c5cff', rose: '#ff2d6b', amber: '#f08a00', slate: '#64748b' };
  React.useEffect(() => {
    document.documentElement.setAttribute('data-theme', dark ? 'dark' : 'light');
    try { localStorage.setItem('hadrian-lp5-theme', dark ? 'dark' : 'light'); } catch (e) {}
    try {
      const a = ACCENTS[localStorage.getItem('hadrian-style')];
      if (a) {
        const r = document.documentElement;
        r.style.setProperty('--color-accent', a);
        r.style.setProperty('--color-accent-hover', a);
        r.style.setProperty('--color-accent-light', `color-mix(in srgb, ${a} 12%, transparent)`);
        r.style.setProperty('--color-link', a);
      }
    } catch (e) {}
  }, [dark]);
  return (
    <div className="hp ab">
      <Nav />
      <Hero />
      <Story />
      <Principles />
      <Work />
      <Founding />
      <Contact />
      <Footer />
      <button className="ab-mode" onClick={() => setDark(!dark)} aria-label="Toggle dark mode">{dark ? '☀' : '☾'}</button>
    </div>
  );
}
ReactDOM.createRoot(document.getElementById('root')).render(<About />);
