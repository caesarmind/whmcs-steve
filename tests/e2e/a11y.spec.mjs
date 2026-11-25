// Tier "a11y" - WCAG 2.2 A + AA, measured with axe-core in real Chromium.
//
// Plan: docs/accessibility-hadrian-plan.md (phase 0). What this does:
//
//   pages     every route in routes.mjs, as each of its personas, in the
//             sidebar layout, light and dark
//   cart      the order steps that need a cart with something in it
//             (configure, cart, checkout), guest and signed in
//   layouts   a handful of pages in each main-menu layout (sidebar, top, rail,
//             topbar-minimal), light and dark, because the chrome differs
//   320px     a handful of pages at 320 CSS px (WCAG 1.4.10 reflow), where
//             horizontal overflow is reported as a finding of its own
//
// Layouts are switched through the stored layout pointers, the way a real
// install picks them, NOT with ?preview=1&layout=: preview renders the chrome
// of every layout at once, so axe would report landmarks and ids twice.
// That changes what every request sees, so this runs alone (run.mjs: one
// worker, after the other site tiers), with settings snapshot and restore.
//
// The site does not pass yet. Every finding that exists today is listed in
// tests/e2e/a11y-baseline.json as page -> rule -> number of elements. A run
// fails on:
//   - a rule that is not in the baseline for that page (a new kind of problem)
//   - more elements failing a rule than the baseline allows
//   - a page that is not in the baseline at all
//   - a rule the baseline lists that no longer occurs (fixed: take it out, so
//     it cannot come back unnoticed)
// Fewer elements than the baseline is reported, not failed.
//
//   HADRIAN_A11Y_UPDATE=1   rewrite the baseline entries of every page scanned
//                           (do this after a fix, and review the diff)
//
// Every scan's full detail (rule, impact, the failing elements) is written to
// tests/reports/a11y-detail/<test>.json for reading; `node tests/lib/a11y-summary.mjs`
// turns those into tests/reports/a11y-summary.md.

import { test, expect } from '@playwright/test';
import { AxeBuilder } from '@axe-core/playwright';
import { execFileSync } from 'node:child_process';
import fs from 'node:fs';
import path from 'node:path';
import { PHP, TESTS_DIR, REPORTS_DIR, BASE_URL } from '../lib/env.mjs';
import { fx, loginClient } from './helpers.mjs';
import { ROUTES } from './routes.mjs';

const id = fx.ids;
const TAGS = ['wcag2a', 'wcag2aa', 'wcag21a', 'wcag21aa', 'wcag22aa', 'best-practice'];
const BASELINE_FILE = path.join(TESTS_DIR, 'e2e', 'a11y-baseline.json');
// Not reports/a11y: that is the HTML report's folder for this tier, which
// Playwright empties when it writes the report.
const DETAIL_DIR = path.join(REPORTS_DIR, 'a11y-detail');
const UPDATE = process.env.HADRIAN_A11Y_UPDATE === '1';

const php = (...args) => execFileSync(PHP, [path.join(TESTS_DIR, 'php', 'settings.php'), ...args], { encoding: 'utf8' });
const str = v => [v, 'string'];

// Pick the layout by visitor, never by area, whatever this install was left on.
const NEVER_BY_AREA = Object.fromEntries([
  'hadrian_layout_mode',
  ...['main-menu', 'footer'].flatMap(kind => ['website', 'client', 'order'].map(area => `hadrian_active_layout_${kind}_area_${area}`)),
].map(key => [key, null]));
const useLayout = layout => php('set', JSON.stringify({
  ...NEVER_BY_AREA,
  'hadrian_active_layout_main-menu_guest': str(layout),
  'hadrian_active_layout_main-menu_client': str(layout),
}));

test.beforeAll(() => { php('snapshot'); });
test.afterAll(() => { php('restore'); });

// ------------------------------------------------------------------ scanning

const readBaseline = () => {
  try { return JSON.parse(fs.readFileSync(BASELINE_FILE, 'utf8')); } catch { return { pages: {} }; }
};

/**
 * Load the page and run axe. Returns { key, counts, detail }. `tpl` is the
 * template the page must render: scanning a sign-in form or a redirect in its
 * place would write the wrong page's findings into the baseline.
 */
async function scan(page, url, key, { theme, tpl, has }) {
  await page.goto(url, { waitUntil: 'load' });
  // Let the page's own scripts settle (tables, tabs, the cart summary).
  await page.waitForLoadState('networkidle', { timeout: 5_000 }).catch(() => {});
  const shown = await page.evaluate(() => ({
    theme: document.documentElement.dataset.theme || 'light',
    tpl: document.body?.dataset.tpl || null,
    layout: document.body?.dataset.layout || null,
    overflowX: document.documentElement.scrollWidth - innerWidth,
  }));
  if (tpl && ![tpl].flat().includes(shown.tpl)) {
    throw new Error(`${key}: ${url} rendered data-tpl="${shown.tpl}", expected ${[tpl].flat().join(' or ')} - not scanned`);
  }
  if (has && !(await page.locator(has).count())) throw new Error(`${key}: ${url} has no ${has} - not scanned`);
  const r = await new AxeBuilder({ page }).withTags(TAGS).analyze();

  const counts = {};
  const detail = { key, url: page.url().replace(BASE_URL, ''), ...shown, violations: [], incomplete: r.incomplete.map(v => ({ id: v.id, nodes: v.nodes.length })) };
  for (const v of r.violations) {
    counts[v.id] = v.nodes.length;
    detail.violations.push({
      id: v.id, impact: v.impact, help: v.help, helpUrl: v.helpUrl,
      tags: v.tags.filter(t => /^wcag\d|^best-practice$/.test(t)),
      nodes: v.nodes.map(n => ({ target: n.target.join(' '), html: n.html.slice(0, 300), summary: (n.failureSummary || '').slice(0, 400) })),
    });
  }
  // Checks of our own, reported like axe rules.
  if (shown.theme !== theme) counts['hadrian-theme-not-applied'] = 1;
  return { key, counts, detail };
}

/** Compare one test's scans with the baseline (or rewrite it), then fail on what is new. */
function settle(testInfo, scans) {
  fs.mkdirSync(DETAIL_DIR, { recursive: true });
  const slug = testInfo.titlePath.slice(1).join(' ').replace(/[^a-z0-9]+/gi, '-').replace(/^-|-$/g, '').toLowerCase();
  fs.writeFileSync(path.join(DETAIL_DIR, `${slug}.json`), JSON.stringify(scans.map(s => s.detail), null, 2));

  if (UPDATE) {
    // Single worker: read-modify-write is safe.
    const b = readBaseline();
    for (const s of scans) b.pages[s.key] = Object.fromEntries(Object.entries(s.counts).sort());
    b.pages = Object.fromEntries(Object.entries(b.pages).sort(([a], [z]) => a.localeCompare(z)));
    fs.writeFileSync(BASELINE_FILE, JSON.stringify({
      note: 'Accessibility findings accepted for now: page -> axe rule -> failing elements. Written by HADRIAN_A11Y_UPDATE=1 (tests/e2e/a11y.spec.mjs); shrink it, never grow it by hand.',
      axe: '4.14.0', tags: TAGS, pages: b.pages,
    }, null, 2) + '\n');
    return;
  }

  const base = readBaseline().pages;
  const problems = [];
  for (const s of scans) {
    const allowed = base[s.key];
    if (!allowed) { problems.push(`${s.key}: not in the baseline - scan it with HADRIAN_A11Y_UPDATE=1 once its findings are understood`); continue; }
    for (const [rule, n] of Object.entries(s.counts)) {
      const v = s.detail.violations.find(x => x.id === rule);
      const first = v ? ` - ${v.help}; first: ${v.nodes[0]?.target}` : '';
      if (!(rule in allowed)) problems.push(`${s.key}: NEW ${rule}${v ? ` (${v.impact})` : ''} on ${n} element(s)${first}`);
      else if (n > allowed[rule]) problems.push(`${s.key}: MORE ${rule}: ${n} element(s), baseline allows ${allowed[rule]}${first}`);
      else if (n < allowed[rule]) testInfo.annotations.push({ type: 'a11y improved', description: `${s.key}: ${rule} ${allowed[rule]} -> ${n}` });
    }
    for (const rule of Object.keys(allowed)) {
      if (!(rule in s.counts)) problems.push(`${s.key}: FIXED ${rule} no longer occurs - take it out of the baseline (HADRIAN_A11Y_UPDATE=1)`);
    }
  }
  expect(problems).toEqual([]);
}

const themed = async (context, theme) => context.addCookies([{ name: 'mt_theme', value: theme, url: BASE_URL }]);

// ------------------------------------------------------------------- pages

// Fragments and token-consuming links are not pages a visitor reads.
const SKIP = new Set(['markdown guide', 'user-verify-email']);
const routeName = r => r.name || [r.tpl].flat()[0];
const PAGES = ROUTES.filter(r => !SKIP.has(routeName(r)));
{
  const seen = new Set();
  for (const r of PAGES) for (const p of r.personas) {
    const k = `${p} ${routeName(r)}`;
    if (seen.has(k)) throw new Error(`a11y.spec: two routes are both called "${k}" - give one a name in routes.mjs`);
    seen.add(k);
  }
}

test.describe('pages', () => {
  test.beforeAll(() => { useLayout('sidebar'); });
  for (const r of PAGES) for (const persona of r.personas) {
    test(`${persona} ${routeName(r)}`, async ({ page, context }, testInfo) => {
      await loginClient(context.request, persona);
      const scans = [];
      for (const theme of ['light', 'dark']) {
        await themed(context, theme);
        scans.push(await scan(page, r.url, `sidebar/${theme} | ${persona} | ${routeName(r)}`, { theme, tpl: r.tpl }));
      }
      settle(testInfo, scans);
    });
  }
});

// -------------------------------------------------------------------- cart

/**
 * The cart OF-89 in order.spec builds: an SSL certificate (no configure step,
 * no domain) and a server (hostname, root password and nameserver fields).
 */
async function fillCart(page) {
  await page.goto('/cart.php?a=add&pid=21');
  await page.waitForURL(/a=(confproduct|view)/);
  if (/a=confproduct/.test(page.url())) {
    await page.locator('#btnCompleteProductConfig').click();
    await page.waitForURL(/a=view/);
  }
  await page.goto('/cart.php?a=add&pid=19');
  await page.waitForURL(/a=confproduct/);
  await page.locator('#inputHostname').fill('server1.hadrian-test.example');
  await page.locator('#inputRootpw').fill('Root!Pass-2026x');
  await page.locator('#inputNs1prefix').fill('ns1');
  await page.locator('#inputNs2prefix').fill('ns2');
  await page.locator('#btnCompleteProductConfig').click();
  await page.waitForURL(/a=view/);
  await expect(page.locator('[data-cart-item^="product-"]')).toHaveCount(2);
}

test.describe('cart', () => {
  test.beforeAll(() => { useLayout('sidebar'); });
  for (const persona of ['guest', 'full']) {
    test(`${persona} order steps with an item`, async ({ page, context }, testInfo) => {
      test.setTimeout(3 * 60_000);
      await loginClient(context.request, persona);
      await fillCart(page);
      const steps = [
        ['configure', '/cart.php?a=confproduct&i=1', 'configureproduct'],
        ['cart', '/cart.php?a=view', 'viewcart'],
        // WHMCS renders the checkout with $templatefile still "viewcart".
        ['checkout', '/cart.php?a=checkout', 'viewcart', '#frmCheckout'],
        ['product domain step', `/cart.php?a=add&pid=${id.productId}`, 'configureproductdomain'],
      ];
      const scans = [];
      for (const theme of ['light', 'dark']) {
        await themed(context, theme);
        for (const [name, url, tpl, has] of steps) scans.push(await scan(page, url, `sidebar/${theme} | ${persona} | cart: ${name}`, { theme, tpl, has }));
      }
      settle(testInfo, scans);
    });
  }
});

// ----------------------------------------------------------------- layouts

// [persona, name, url, template]
const CHROME_PAGES = [
  ['guest', 'homepage', '/', 'homepage'],
  ['guest', 'login', '/login', 'login'],
  ['guest', 'store group', `/index.php?rp=/store/${id.productGroupSlug}`, 'products'],
  ['guest', 'viewcart', '/cart.php?a=view', 'viewcart'],
  ['full', 'clientareahome', '/clientarea.php', 'clientareahome'],
  ['full', 'clientareaproducts', '/clientarea.php?action=services', 'clientareaproducts'],
];

for (const layout of ['top', 'rail', 'topbar-minimal']) {
  test.describe(`layout ${layout}`, () => {
    test.beforeAll(() => { useLayout(layout); });
    for (const [persona, name, url, tpl] of CHROME_PAGES) {
      test(`${persona} ${name}`, async ({ page, context }, testInfo) => {
        await loginClient(context.request, persona);
        const scans = [];
        for (const theme of ['light', 'dark']) {
          await themed(context, theme);
          scans.push(await scan(page, url, `${layout}/${theme} | ${persona} | ${name}`, { theme, tpl }));
        }
        settle(testInfo, scans);
      });
    }
  });
}

// ------------------------------------------------------------------- 320px

test.describe('320px', () => {
  test.use({ viewport: { width: 320, height: 640 } });
  test.beforeAll(() => { useLayout('sidebar'); });
  const NARROW = [...CHROME_PAGES,
    ['guest', 'clientregister', '/register.php', 'clientregister'],
    ['full', 'clientareainvoices', '/clientarea.php?action=invoices', 'clientareainvoices'],
    ['full', 'viewinvoice', `/viewinvoice.php?id=${id.invoiceId}`, 'viewinvoice'],
    ['full', 'viewticket', `/viewticket.php?tid=${id.ticketTid}&c=${id.ticketC}`, 'viewticket'],
  ];
  for (const [persona, name, url, tpl] of NARROW) {
    test(`${persona} ${name}`, async ({ page, context }, testInfo) => {
      await loginClient(context.request, persona);
      await themed(context, 'light');
      const s = await scan(page, url, `sidebar/light/320px | ${persona} | ${name}`, { theme: 'light', tpl });
      // WCAG 1.4.10: one column, no sideways scrolling, at 320 CSS px.
      if (s.detail.overflowX > 1) s.counts['hadrian-reflow-320'] = 1;
      settle(testInfo, [s]);
    });
  }
});
