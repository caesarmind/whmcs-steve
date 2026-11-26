// Generates apple-client-area/promo-*.html from one template + a per-season config.
// Usage (from the repo root): node scripts/build-promo-pages.mjs apple-client-area
import fs from 'node:fs';
import path from 'node:path';

const root = process.argv[2];
// Sale pages are distraction-free landings: no site menu, no subnav, no footer
// link columns. The only thing borrowed from the site chrome is the brand mark.
const src = fs.readFileSync(path.join(root, 'cloud-hosting.html'), 'utf8');
const logoMatch = src.match(/<a href="index.html" class="nav-logo">(<svg[\s\S]*?<\/svg>)<\/a>/);
if (!logoMatch) throw new Error('could not find the brand mark in cloud-hosting.html');
const LOGO = logoMatch[1];

const I = {
  snowflake: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round"><path d="M12 2v20M3.34 7l17.32 10M3.34 17L20.66 7"/><path d="M9.5 3.5L12 6l2.5-2.5M9.5 20.5L12 18l2.5 2.5M3.6 10.2l3.4-.9-.9-3.4M20.4 13.8l-3.4.9.9 3.4M6.1 17.6l.9-3.4-3.4-.9M17.9 6.4l-.9 3.4 3.4.9"/></svg>',
  gift: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="8" width="18" height="4" rx="1"/><path d="M5 12v8a1 1 0 001 1h12a1 1 0 001-1v-8M12 8v13"/><path d="M12 8S10.5 3.5 8 3.5A2.25 2.25 0 008 8M12 8s1.5-4.5 4-4.5A2.25 2.25 0 0116 8"/></svg>',
  tag: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round"><path d="M20.6 13.4l-7.2 7.2a2 2 0 01-2.8 0L3 13V3h10l7.6 7.6a2 2 0 010 2.8z"/><circle cx="7.5" cy="7.5" r="1.2" fill="currentColor"/><path d="M9.5 15.5l5-5M10.3 11.3h.01M14.7 15.7h.01"/></svg>',
  bolt: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M13 2L4 14h7l-1 8 9-12h-7l1-8z"/></svg>',
  star: '<svg viewBox="0 0 24 24" fill="currentColor"><path d="M12 2.5l2.9 6 6.6.9-4.8 4.6 1.2 6.5L12 17.4l-5.9 3.1 1.2-6.5L2.5 9.4l6.6-.9z"/></svg>',
  globe: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="9"/><path d="M3 12h18M12 3a14 14 0 010 18M12 3a14 14 0 000 18"/></svg>',
  cloud: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round"><path d="M7 18a4.5 4.5 0 01-.6-8.96A6 6 0 0118 8.5a4.75 4.75 0 01-.5 9.5z"/></svg>',
  server: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="4" width="18" height="7" rx="2"/><rect x="3" y="13" width="18" height="7" rx="2"/><path d="M7 7.5h.01M7 16.5h.01"/></svg>',
  clock: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="9"/><path d="M12 7v5l3 2"/></svg>',
};

const SEASONS = [
  {
    file: 'promo-winter-sale.html', promo: 'winter', name: 'Winter Sale',
    ends: '2027-01-31T23:59:59', off: 25, transferOff: 15,
    ended: 'The Winter Sale has ended.', eyebrow: 'Limited-time offer', h1: 'Winter Sale.', sub: 'Warm prices for the cold months.',
    lead: 'Hosting, domains and servers at their lowest prices of the season. Lock in the discount for your whole first term.',
    art: I.snowflake, chip2: I.star,
    bandTitle: 'The thaw is coming.', bandText: 'These prices end when the season does. Order now to keep them for your first term.',
    finalTitle: 'Start the year<br>on a faster site.', finalText: 'Every plan in the sale, one discount, no codes to remember.',
  },
  {
    file: 'promo-christmas-sale.html', promo: 'holiday', name: 'Christmas Sale',
    ends: '2026-12-26T23:59:59', off: 30, transferOff: 20,
    ended: 'The Christmas Sale has ended.', eyebrow: 'Holiday offer', h1: 'Christmas Sale.', sub: 'A gift for your website.',
    lead: 'Our holiday prices cover every hosting plan, domain transfer and dedicated server. Wrap one up for yourself or someone you build sites for.',
    art: I.gift, chip2: I.star,
    bandTitle: 'Free migration with every plan.', bandText: 'Order during the sale and our team moves your existing site for you, at no cost.',
    finalTitle: 'Unwrap a faster<br>website this year.', finalText: 'The holiday discount applies automatically at checkout.',
  },
  {
    file: 'promo-cyber-monday.html', promo: 'cyber', name: 'Cyber Monday',
    ends: '2026-11-30T23:59:59', off: 40, transferOff: 25,
    ended: 'Cyber Monday is over.', eyebrow: 'One day only', h1: 'Cyber Monday.', sub: 'Our deepest prices of the year.',
    lead: 'For one day, every hosting plan and dedicated server is marked down. When the clock hits zero, prices go back to normal.',
    art: I.tag, chip2: I.bolt,
    bandTitle: 'Hours, not days.', bandText: 'Cyber Monday pricing disappears at midnight. Anything in your cart before then keeps the discount.',
    finalTitle: 'Last call for<br>Cyber Monday.', finalText: 'One discount on everything. Gone at midnight.',
  },
];

const TERMS = { 36: 0.85, 24: 0.92, 12: 1 };
const money = (n) => n.toFixed(2);

const SHARED = [
  { id: 'shared-single', name: 'Single', tag: 'One site, done right. For a portfolio, blog or shop that is just getting started.', base: 2.99,
    feats: ['1 website', '15 GB NVMe storage', 'Unmetered bandwidth', 'Unlimited email accounts', 'Free SSL certificate'] },
  { id: 'shared-premium', name: 'Premium', tag: 'Room for every site you run, with backups you can trigger yourself.', base: 4.99, featured: true,
    feats: ['Unlimited websites', '50 GB NVMe storage', 'Unmetered bandwidth', 'Unlimited email and databases', 'Free SSL certificate', 'On-demand backups'] },
  { id: 'shared-business', name: 'Business', tag: 'More power and a faster queue when you need help.', base: 6.99,
    feats: ['Unlimited websites', '100 GB NVMe storage', 'Unmetered bandwidth', 'Unlimited email and databases', 'Free SSL certificate', 'Daily backups', 'Priority support'] },
];
const WP = [
  { id: 'wp-starter', name: 'WP Starter', tag: 'Managed WordPress for a single site.', base: 3.49,
    feats: ['1 WordPress site', '20 GB NVMe storage', 'Automatic core updates', 'Server-side caching', 'Free SSL certificate'] },
  { id: 'wp-plus', name: 'WP Plus', tag: 'Staging and daily backups for sites that earn money.', base: 5.99, featured: true,
    feats: ['5 WordPress sites', '60 GB NVMe storage', 'Automatic core and plugin updates', 'One-click staging', 'Daily backups', 'Free SSL certificate'] },
  { id: 'wp-business', name: 'WP Business', tag: 'For agencies running many client sites.', base: 8.99,
    feats: ['Unlimited WordPress sites', '120 GB NVMe storage', 'Automatic core and plugin updates', 'One-click staging', 'Daily backups', 'Priority support'] },
];
const RESELLER = [
  { id: 'reseller-30', name: 'Reseller 30', base: 19.99, feats: ['30 cPanel accounts', '60 GB SSD storage', '3 TB bandwidth', 'White-label nameservers', 'Free SSL certificates'] },
  { id: 'reseller-60', name: 'Reseller 60', base: 29.99, featured: true, feats: ['60 cPanel accounts', '90 GB SSD storage', '6 TB bandwidth', 'White-label nameservers', 'Free SSL certificates'] },
  { id: 'reseller-80', name: 'Reseller 80', base: 44.99, feats: ['80 cPanel accounts', '140 GB SSD storage', '9 TB bandwidth', 'White-label nameservers', 'Free SSL certificates'] },
  { id: 'reseller-100', name: 'Reseller 100', base: 59.99, feats: ['100 cPanel accounts', '200 GB SSD storage', '12 TB bandwidth', 'White-label nameservers', 'Free SSL certificates'] },
];
const SERVERS = [
  { id: 'ds-e3', cpu: 'Intel Xeon E3-1230 v6', cores: '4 cores, 3.5 GHz', ram: '16 GB', disk: '1 x 240 GB', diskType: 'SSD', bw: '20 TB', base: 40 },
  { id: 'ds-e2134', cpu: 'Intel Xeon E-2134', cores: '4 cores, 3.5 GHz', ram: '16 GB', disk: '2 x 240 GB', diskType: 'SSD', bw: '30 TB', base: 49 },
  { id: 'ds-e2236', cpu: 'Intel Xeon E-2236', cores: '6 cores, 3.4 GHz', ram: '32 GB', disk: '2 x 480 GB', diskType: 'NVMe', bw: '30 TB', base: 65, best: true },
  { id: 'ds-e2288g', cpu: 'Intel Xeon E-2288G', cores: '8 cores, 3.7 GHz', ram: '64 GB', disk: '2 x 960 GB', diskType: 'NVMe', bw: '30 TB', base: 89 },
  { id: 'ds-ryzen', cpu: 'AMD Ryzen 9 5950X', cores: '16 cores, 3.4 GHz', ram: '128 GB', disk: '2 x 1.92 TB', diskType: 'NVMe', bw: '50 TB', base: 129 },
  { id: 'ds-epyc', cpu: 'AMD EPYC 7443P', cores: '24 cores, 2.85 GHz', ram: '256 GB', disk: '2 x 3.84 TB', diskType: 'NVMe', bw: '50 TB', base: 189 },
];
const TLDS = [ ['com', 12.99], ['net', 14.99], ['org', 13.99], ['io', 39.99], ['co', 24.99], ['dev', 15.99] ];

function countdown(extra = '') {
  const u = (k, l) => `<div class="pr-cd-unit"><span class="pr-cd-num" data-cd="${k}">00</span><span class="pr-cd-label">${l}</span></div>`;
  return `<div class="pr-countdown${extra}" data-countdown role="timer" aria-label="Time left in the sale">
                ${u('d', 'Days')}<span class="pr-cd-sep" aria-hidden="true">:</span>${u('h', 'Hours')}<span class="pr-cd-sep" aria-hidden="true">:</span>${u('m', 'Minutes')}<span class="pr-cd-sep" aria-hidden="true">:</span>${u('s', 'Seconds')}
            </div>`;
}

function termSwitch(group) {
  return `<div class="pr-terms" role="radiogroup" aria-label="Billing term">
            <label><input type="radio" name="term-${group}" value="36" checked>3 years</label>
            <label><input type="radio" name="term-${group}" value="24">2 years</label>
            <label><input type="radio" name="term-${group}" value="12">1 year</label>
        </div>`;
}

function termCard(p, group, off) {
  const attrs = Object.entries(TERMS).map(([m, k]) => {
    const was = p.base * k; const now = was * (1 - off / 100);
    return `data-price-${m}="${money(now)}" data-was-${m}="${money(was)}"`;
  }).join(' ');
  const was = p.base * TERMS[36]; const now = was * (1 - off / 100);
  const href = `cart.html?a=add&amp;pid=${p.id}`;
  return `<div class="hp-price-card${p.featured ? ' highlight' : ''}" data-plan-group="${group}" ${attrs}>
                <div class="label${p.featured ? ' featured' : ''}">${p.featured ? 'Most popular' : '&nbsp;'}</div>
                <h3>${p.name}</h3>
                <p class="pr-plan-tag">${p.tag}</p>
                <div class="pr-was-row"><s class="pr-was">$${money(was)}</s><span class="pr-save">Save ${off}%</span></div>
                <span class="price">$${money(now)}</span><span class="per">/mo for 36 months</span>
                <a class="buy" href="${href}&amp;billingcycle=triennially" data-href="${href}">Order now</a>
                <ul>${p.feats.map((f) => `<li>${f}</li>`).join('')}</ul>
            </div>`;
}

function monthlyCard(p, off) {
  const now = p.base * (1 - off / 100);
  return `<div class="hp-price-card${p.featured ? ' highlight' : ''}">
                <div class="label${p.featured ? ' featured' : ''}">${p.featured ? 'Most popular' : '&nbsp;'}</div>
                <h3>${p.name}</h3>
                <div class="pr-was-row"><s class="pr-was">$${money(p.base)}</s><span class="pr-save">Save ${off}%</span></div>
                <span class="price">$${money(now)}</span><span class="per">/mo, billed monthly</span>
                <a class="buy" href="cart.html?a=add&amp;pid=${p.id}">Order now</a>
                <ul>${p.feats.map((f) => `<li>${f}</li>`).join('')}</ul>
            </div>`;
}

function serverRow(s, off) {
  const now = s.base * (1 - off / 100);
  return `<div class="pr-server">
                <div class="pr-server-cpu">${s.cpu}${s.best ? '<span class="pr-best">Best value</span>' : ''}<small>${s.cores}</small></div>
                <div class="pr-spec">${s.ram}<small>Memory</small></div>
                <div class="pr-spec">${s.disk}<small>${s.diskType} storage</small></div>
                <div class="pr-spec">${s.bw}<small>1 Gbps transfer</small></div>
                <div class="pr-server-price"><s>$${money(s.base)}</s> <strong>$${money(now)}</strong><span>/mo</span></div>
                <a class="pr-btn" href="cart.html?a=add&amp;pid=${s.id}">Order</a>
            </div>`;
}

function page(c) {
  const off = c.off;
  return `<!DOCTYPE html>
<html lang="en" data-theme="light">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${c.name} - WHMCS by Apple</title>
    <link rel="stylesheet" href="css/apple-theme.css">
    <link rel="stylesheet" href="css/apple-layout.css?v=23">
    <link rel="stylesheet" href="css/apple-promo.css?v=2">
</head>
<!-- Generated from one template shared by promo-winter-sale.html, promo-christmas-sale.html
     and promo-cyber-monday.html by scripts/build-promo-pages.mjs. Edit the script and rerun it
     rather than editing these files by hand.
     data-promo picks the season look; data-promo-ends drives every countdown
     (preview the ended state with ?ends=2000-01-01 or the Data: Empty chip). -->
<body class="homepage-layout" data-promo="${c.promo}" data-promo-ends="${c.ends}">
<div data-include="partials/state-chip.html"></div>

<!-- Offer bar: brand mark (not a link), the offer, the clock, one action.
     No site menu on purpose; every link out of the page is a way to lose the order. -->
<header class="pr-bar">
    <div class="pr-bar-inner">
        <span class="pr-bar-brand" aria-label="WHMCS">${LOGO}</span>
        <span class="pr-bar-offer"><b>${c.name}</b><span class="pr-bar-dot" aria-hidden="true"></span><span class="pr-bar-rest">${off}% off hosting and servers</span></span>
        <span class="pr-bar-timer when-full">Ends in <b data-cd-compact>--</b></span>
        <a href="#hosting" class="pr-bar-btn when-full">Shop the sale</a>
    </div>
</header>

<main class="when-full">

    <!-- 1. Hero: season art, headline, live countdown -->
    <section class="pr-hero" id="overview">
        <div class="pr-hero-inner">
            <div>
                <p class="pr-eyebrow">${c.eyebrow}</p>
                <h1>${c.h1}</h1>
                <p class="pr-sub">${c.sub}</p>
                <p class="pr-lead">${c.lead}</p>
                ${countdown()}
                <p class="pr-ends" data-ends-label="Sale ends %s."></p>
                <div class="pr-cta-row">
                    <a href="#hosting" class="pr-btn">Shop the sale</a>
                </div>
            </div>
            <div class="pr-art" aria-hidden="true">
                <div class="pr-art-tile">${c.art}</div>
                <div class="pr-art-chip c1">${off}%<small>off</small></div>
                <div class="pr-art-chip c2">${c.chip2}</div>
            </div>
        </div>
    </section>

    <!-- 2. What is on sale -->
    <section class="pr-section lifted">
        <div class="pr-container">
            <div class="pr-cats">
                <div class="pr-cat">
                    <div class="pr-cat-icon">${I.globe}</div>
                    <h3>Domains</h3>
                    <div class="pr-cat-off">${c.transferOff}% off</div>
                    <p>Move your domains to us for less, with a free year added to the registration.</p>
                    <a href="#domains">Transfer a domain &rsaquo;</a>
                </div>
                <div class="pr-cat">
                    <div class="pr-cat-icon">${I.cloud}</div>
                    <h3>Hosting</h3>
                    <div class="pr-cat-off">${off}% off</div>
                    <p>Shared, WordPress and reseller plans, discounted for your whole first term.</p>
                    <a href="#hosting">See hosting plans &rsaquo;</a>
                </div>
                <div class="pr-cat">
                    <div class="pr-cat-icon">${I.server}</div>
                    <h3>Servers</h3>
                    <div class="pr-cat-off">${off}% off</div>
                    <p>Dedicated hardware with full root access, set up within one business day.</p>
                    <a href="#servers">See servers &rsaquo;</a>
                </div>
            </div>
        </div>
    </section>

    <!-- 3. Domain transfers -->
    <section class="pr-section" id="domains">
        <div class="pr-container">
            <div class="pr-head">
                <p class="pr-eyebrow">Domain transfers</p>
                <h2>Bring your domains. <span class="pr-accent">Save ${c.transferOff}%.</span></h2>
                <p>Transfers include a year of renewal, free WHOIS privacy and DNS management.</p>
            </div>
            <div class="pr-tlds">
                ${TLDS.map(([t, p]) => `<div class="pr-tld">
                    <div class="pr-tld-name">.${t}</div>
                    <div class="pr-tld-price"><s>$${money(p)}</s>$${money(p * (1 - c.transferOff / 100))}/yr</div>
                    <a href="cart-domain-transfer.html">Transfer &rsaquo;</a>
                </div>`).join('\n                ')}
            </div>
        </div>
    </section>

    <!-- 4. Shared hosting -->
    <section class="pr-section lifted" id="hosting">
        <div class="pr-container">
            <div class="pr-head">
                <p class="pr-eyebrow">Shared hosting</p>
                <h2>Fast hosting. <span class="pr-accent">${off}% off.</span></h2>
                <p>NVMe storage, free SSL and a control panel you already know.</p>
            </div>
            ${termSwitch('shared')}
            <div class="pr-plans">
            ${SHARED.map((p) => termCard(p, 'shared', off)).join('\n            ')}
            </div>
        </div>
    </section>

    <!-- 5. Reminder band -->
    <div class="pr-band-wrap" style="padding-top: 96px;">
        <div class="pr-band">
            <div>
                <h3>${c.bandTitle}</h3>
                <p>${c.bandText}</p>
            </div>
            ${countdown()}
        </div>
    </div>

    <!-- 6. WordPress hosting -->
    <section class="pr-section" id="wordpress">
        <div class="pr-container">
            <div class="pr-head">
                <p class="pr-eyebrow">WordPress hosting</p>
                <h2>WordPress, managed. <span class="pr-accent">${off}% off.</span></h2>
                <p>We handle updates, caching and backups so you can work on the site itself.</p>
            </div>
            ${termSwitch('wordpress')}
            <div class="pr-plans">
            ${WP.map((p) => termCard(p, 'wordpress', off)).join('\n            ')}
            </div>
        </div>
    </section>

    <!-- 7. Reseller hosting -->
    <section class="pr-section lifted" id="reseller">
        <div class="pr-container">
            <div class="pr-head">
                <p class="pr-eyebrow">Reseller hosting</p>
                <h2>Host your clients. <span class="pr-accent">Keep more margin.</span></h2>
                <p>White-label cPanel accounts at ${off}% off, for as long as you stay on the plan you pick today.</p>
            </div>
            <div class="pr-plans four">
            ${RESELLER.map((p) => monthlyCard(p, off)).join('\n            ')}
            </div>
        </div>
    </section>

    <!-- 8. Dedicated servers -->
    <section class="pr-section" id="servers">
        <div class="pr-container">
            <div class="pr-head">
                <p class="pr-eyebrow">Dedicated servers</p>
                <h2>Hardware of your own. <span class="pr-accent">${off}% off.</span></h2>
                <p>Every server includes full root access, a dedicated IPv4 address and DDoS protection.</p>
            </div>
            <div class="pr-servers">
            ${SERVERS.map((s) => serverRow(s, off)).join('\n            ')}
            </div>
        </div>
    </section>

    <!-- 9. Questions people ask before they buy on a sale -->
    <section class="pr-section lifted" id="faq">
        <div class="pr-container pr-faq">
            <div class="pr-head">
                <h2>Before you order.</h2>
            </div>
            <details class="hp-faq-item"><summary>Do I need a coupon code?</summary><div class="faq-body">No. The ${c.name} price is already applied to every plan on this page and carries through to checkout.</div></details>
            <details class="hp-faq-item"><summary>What do I pay when my plan renews?</summary><div class="faq-body">The discount covers your first billing term. After that the plan renews at the regular price, which is the struck-through price shown on each card. Picking a longer term keeps the sale price for longer.</div></details>
            <details class="hp-faq-item"><summary>When does the sale end?</summary><div class="faq-body" data-ends-label="Orders placed before %s get the sale price. The clock on this page counts down to that moment and does not reset."></div></details>
            <details class="hp-faq-item"><summary>Can I upgrade later?</summary><div class="faq-body">Yes. You can move to a bigger plan at any time from your client area. Upgrades are billed at the regular price for the remaining time on your term.</div></details>
        </div>
    </section>

    <!-- 10. Final call -->
    <section class="hp-final-cta pr-final">
        <p class="pr-eyebrow">${c.name}</p>
        <h2>${c.finalTitle}</h2>
        <p>${c.finalText}</p>
        ${countdown()}
        <div>
            <a href="#hosting" class="btn">Shop the sale</a>
        </div>
    </section>

</main>

<!-- Sale over (time ran out, or the Data: Empty chip) -->
<section class="pr-ended when-empty">
    <div class="pr-ended-card">
        <div class="pr-ended-icon">${I.clock}</div>
        <h2>${c.ended}</h2>
        <p>Thanks to everyone who joined in. Our regular plans are still here, and the next sale will be announced on this page.</p>
        <div class="pr-cta-row">
            <a href="store.html" class="pr-btn">Browse products</a>
            <a href="announcements.html" class="pr-link">Read announcements &rsaquo;</a>
        </div>
    </div>
</section>

<!-- Footer: the offer terms and the two legal links a checkout page must reach. Nothing else. -->
<footer class="pr-foot">
    <div class="pr-foot-inner">
        <p>${c.name} prices apply to new orders placed before the sale ends and cover the first billing term only. Renewals are charged at the regular price shown struck through. Domain transfer pricing includes one year of renewal. Discounts cannot be combined with other promotions. Prices in USD, tax not included.</p>
        <div class="pr-foot-bottom">
            <span>Copyright &copy; 2026 Hostnodes LLC.</span>
            <span><a href="#" target="_blank" rel="noopener">Terms of Service</a><a href="#" target="_blank" rel="noopener">Privacy Policy</a></span>
        </div>
    </div>
</footer>

<script src="js/apple-theme.js"></script>
<script src="js/apple-layout.js?v=23"></script>
<script src="js/apple-promo.js?v=2"></script>
</body>
</html>
`;
}

for (const c of SEASONS) {
  fs.writeFileSync(path.join(root, c.file), page(c));
  console.log('wrote', c.file);
}
