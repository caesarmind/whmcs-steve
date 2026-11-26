// Tier 3c (settings) - the client-area and order-form features of
// tests/FEATURES.md (TH-*, OF-*) that only show once a setting, a page row or
// a buyer file is changed. Each test title starts with the feature IDs it covers.
//
// Same contract as settings.spec.mjs:
//   - settings and page rows go straight into the tables through
//     tests/php/settings.php (snapshot before, restored after EVERY test and by
//     the preflight if a run dies halfway); WHMCS settings through
//     tests/php/whmcs-config.php, put back in a finally
//   - buyer files (lang overrides, overwrites, a theme extension, a WHMCS hook)
//     are created by the test and removed after every test; heal() also removes
//     them, and restores theme.json, before the first test, so a killed run
//     cannot leave them behind
//   - one worker, never beside the smoke/browser tiers (run.mjs does that)
//
// The confirmed bugs in FEATURES.md (TH-58/75/76, OF-21/22 and the rest) are
// covered by known-bugs.spec.mjs and the static checkers, not here.

import { test, expect } from '@playwright/test';
import fs from 'node:fs';
import path from 'node:path';
import { execFileSync } from 'node:child_process';
import { PHP, TESTS_DIR, REPO_ROOT, WHMCS_ROOT, BASE_URL, LOCAL_DIR } from '../lib/env.mjs';
import { fx, loginClient, loginAdmin } from './helpers.mjs';
import { watch, judge } from './page-checks.mjs';
import { inspect } from './oracles.mjs';

const id = fx.ids;

const settingsPhp = (...args) => execFileSync(PHP, [path.join(TESTS_DIR, 'php', 'settings.php'), ...args], { encoding: 'utf8' });
const set = obj => settingsPhp('set', JSON.stringify(obj));
const variant = obj => settingsPhp('variant', JSON.stringify(obj));
const pageRow = obj => settingsPhp('page', JSON.stringify(obj));
const whmcsConfig = (...a) => execFileSync(PHP, [path.join(TESTS_DIR, 'php', 'whmcs-config.php'), ...a], { encoding: 'utf8' }).trim();
const on = ['1', 'bool'], off = ['0', 'bool'];
const str = v => [v, 'string'];
const json = v => [v, 'json'];

const tpl = page => page.evaluate(() => document.body.dataset.tpl);
const bodyAttr = (page, name) => page.evaluate(n => document.body.getAttribute(n), name);
const rootVar = (page, name) => page.evaluate(n => getComputedStyle(document.documentElement).getPropertyValue(n).trim(), name);

// ------------------------------------------------------------ buyer files
const THEME = path.join(REPO_ROOT, 'hadrian', 'templates', 'hadrian');
const FILES = {
  langEnglish: path.join(THEME, 'core', 'lang', 'overrides', 'english.php'),
  langFrench:  path.join(THEME, 'core', 'lang', 'overrides', 'french.php'),
  kbOverwrite: path.join(THEME, 'core', 'pages', 'knowledgebase', 'overwrites', 'overwrites.tpl'),
  footer:      path.join(THEME, 'overwrites', 'footer.tpl'),
  extension:   path.join(THEME, 'core', 'extensions', 'hadrian-test', 'hadrian-test.php'),
  favicon:     path.join(THEME, 'assets', 'img', 'branding', 'hadrian-test-favicon.png'),
  hook:        path.join(WHMCS_ROOT, 'includes', 'hooks', 'hadrian_test_output.php'),
};
// Folders a test may have created. Removed only when empty, so a buyer's own
// files in them are never touched.
const DIRS = [
  path.join(THEME, 'core', 'lang', 'overrides'),
  path.join(THEME, 'core', 'pages', 'knowledgebase', 'overwrites'),
  path.join(THEME, 'overwrites'),
  path.join(THEME, 'core', 'extensions', 'hadrian-test'),
  path.join(THEME, 'core', 'extensions'),
];
const THEME_JSON = path.join(THEME, 'theme.json');
const THEME_JSON_BAK = path.join(LOCAL_DIR, 'theme.json.bak');
// Files that existed before this spec ran are not ours to delete.
const PREEXISTING = new Set(Object.values(FILES).filter(f => fs.existsSync(f) && !fs.existsSync(path.join(LOCAL_DIR, 'theme-settings.owned'))));

function heal() {
  const owned = path.join(LOCAL_DIR, 'theme-settings.owned');
  const list = fs.existsSync(owned) ? fs.readFileSync(owned, 'utf8').split('\n').filter(Boolean) : [];
  for (const f of list) fs.rmSync(f, { force: true });
  fs.rmSync(owned, { force: true });
  for (const d of DIRS) { try { fs.rmdirSync(d); } catch {} }
  if (fs.existsSync(THEME_JSON_BAK)) { fs.copyFileSync(THEME_JSON_BAK, THEME_JSON); fs.rmSync(THEME_JSON_BAK); }
}
/** Write a buyer file for this test; heal() removes it. */
function buyerFile(file, content) {
  if (PREEXISTING.has(file)) throw new Error(`${file} already exists on this install - not overwriting a buyer's file`);
  fs.mkdirSync(path.dirname(file), { recursive: true });
  fs.writeFileSync(file, content);
  fs.mkdirSync(LOCAL_DIR, { recursive: true });
  fs.appendFileSync(path.join(LOCAL_DIR, 'theme-settings.owned'), file + '\n');
}
/** Change theme.json for this test; heal() restores the exact bytes. */
function editThemeJson(mutate) {
  if (!fs.existsSync(THEME_JSON_BAK)) fs.copyFileSync(THEME_JSON, THEME_JSON_BAK);
  const manifest = JSON.parse(fs.readFileSync(THEME_JSON_BAK, 'utf8'));
  mutate(manifest);
  fs.writeFileSync(THEME_JSON, JSON.stringify(manifest, null, 2));
}
// PHP's opcache revalidates a changed file after revalidate_freq (2 s by
// default); a file rewritten within that window can still run its old copy.
const opcacheSettle = page => page.waitForTimeout(2200);

test.beforeAll(() => { heal(); settingsPhp('snapshot'); });
test.afterEach(() => { heal(); settingsPhp('restore'); settingsPhp('snapshot'); });
test.afterAll(() => { heal(); settingsPhp('restore'); });

/** Load each url as `persona`, judge it like the browser tier, fail on anything found. */
async function clean(page, context, persona, urls) {
  await loginClient(context.request, persona);
  const w = watch(page);
  const problems = [];
  for (const url of urls) {
    w.label(`[${url}]`);
    problems.push(...(await judge(page, url, { expectAuth: persona === 'guest' ? 'out' : 'in' })).problems);
  }
  expect([...new Set([...problems, ...w.problems])]).toEqual([]);
}

const head = page => page.evaluate(() => {
  const m = sel => document.head.querySelector(sel)?.getAttribute('content') ?? null;
  return {
    title: document.title, desc: m('meta[name="description"]'), robots: m('meta[name="robots"]'),
    ogTitle: m('meta[property="og:title"]'), ogDesc: m('meta[property="og:description"]'), ogImage: m('meta[property="og:image"]'),
    twCard: m('meta[name="twitter:card"]'), twTitle: m('meta[name="twitter:title"]'), twDesc: m('meta[name="twitter:description"]'), twImage: m('meta[name="twitter:image"]'),
  };
});

// ================================================================== TH-R
test.describe('TH-R Visibility gate', () => {
  test('TH-123 auth: a guest is sent to sign in, a signed-in client sees the page', async ({ page, context }) => {
    pageRow({ knowledgebase: { visibility: 'auth' } });
    // The route itself: WHMCS answers knowledgebase.php with its own 301 to it.
    const r = await context.request.get('/index.php?rp=/knowledgebase', { maxRedirects: 0 });
    expect(r.status(), 'a redirect, not the page').toBe(302);
    expect(r.headers().location).toMatch(/login/);
    await page.goto('/knowledgebase.php');
    expect(await tpl(page)).toBe('login');
    await loginClient(context.request, 'full');
    await page.goto('/knowledgebase.php');
    expect(await tpl(page)).toBe('knowledgebase');
  });

  test('TH-123 disabled: a 404 for guests and clients, the page for a signed-in admin', async ({ page, context, browser }) => {
    pageRow({ knowledgebase: { visibility: 'disabled' } });
    for (const persona of ['guest', 'full']) {
      await loginClient(context.request, persona);
      const res = await page.goto('/knowledgebase.php');
      expect(res.status(), `${persona}: not found`).toBe(404);
      expect(await tpl(page), persona).toBe('error/page-not-found');
    }
    const adminCtx = await browser.newContext({ baseURL: BASE_URL, userAgent: (await page.evaluate(() => navigator.userAgent)) });
    try {
      await loginAdmin(adminCtx.request);
      const adminPage = await adminCtx.newPage();
      const res = await adminPage.goto('/knowledgebase.php');
      expect(res.status(), 'a signed-in admin can still check the page').toBe(200);
      expect(await tpl(adminPage)).toBe('knowledgebase');
    } finally {
      await adminCtx.close();
    }
  });

  test('TH-123 exemptions: sign-in and order pages ignore it, so nobody is locked out', async ({ page }) => {
    pageRow({ login: { visibility: 'disabled' }, viewcart: { visibility: 'disabled' }, 'password-reset-container': { visibility: 'auth' } });
    await page.goto('/login');
    expect(await tpl(page), 'the sign-in page (Authentication group) always renders').toBe('login');
    await page.goto('/cart.php?a=view');
    expect(await tpl(page), 'the cart (Order Process) always renders').toBe('viewcart');
    await page.goto('/index.php?rp=/password/reset');
    expect(await tpl(page), 'password reset stays reachable for guests').toBe('password-reset-container');
  });
});

// ================================================================== TH-B
test.describe('TH-B SEO and head', () => {
  test('TH-09 TH-10 TH-14 a page\'s SEO title, description and social image reach every tag', async ({ page }) => {
    await page.goto('/knowledgebase.php');
    const before = await head(page);
    expect(before.twCard, 'no image: the small card').toBe('summary');
    expect(before.ogImage).toBeNull();
    expect(before.title, 'default: "page - company"').toMatch(/\S — \S/);

    pageRow({ knowledgebase: {
      seo_title: { english: 'Help centre (hadrian-test)', french: 'Centre d\'aide (hadrian-test)' },
      seo_description: { english: 'Answers to common questions (hadrian-test).' },
      seo_image: 'https://cdn.example.test/og-help.png',
    } });
    await page.goto('/knowledgebase.php');
    const h = await head(page);
    expect(h.title, 'a custom title is used as typed, no company suffix').toBe('Help centre (hadrian-test)');
    expect([h.ogTitle, h.twTitle], 'og and twitter titles match the <title>').toEqual([h.title, h.title]);
    expect(h.desc).toBe('Answers to common questions (hadrian-test).');
    expect([h.ogDesc, h.twDesc]).toEqual([h.desc, h.desc]);
    expect([h.ogImage, h.twImage]).toEqual(['https://cdn.example.test/og-help.png', 'https://cdn.example.test/og-help.png']);
    expect(h.twCard, 'an image: the large card').toBe('summary_large_image');

    try {
      await page.goto('/knowledgebase.php?language=french');
      expect((await head(page)).title, 'each language gets its own title').toBe('Centre d\'aide (hadrian-test)');
      expect((await head(page)).desc, 'no French description: the English one is used').toBe('Answers to common questions (hadrian-test).');
    } finally {
      await page.goto('/knowledgebase.php?language=english');
    }
  });

  test('TH-11 robots noindex only when the page says disallow', async ({ page }) => {
    await page.goto('/knowledgebase.php');
    expect((await head(page)).robots, 'inherit: no robots tag').toBeNull();
    pageRow({ knowledgebase: { indexing: 'disallow' } });
    await page.goto('/knowledgebase.php');
    expect((await head(page)).robots).toBe('noindex, nofollow');
    pageRow({ knowledgebase: { indexing: 'allow' } });
    await page.goto('/knowledgebase.php');
    expect((await head(page)).robots).toBeNull();
  });

  test('TH-11 the password-reset page is noindex by default', async ({ page }) => {
    // core/pages/password-reset-container/page.php declares seoDefaults.indexing
    // = disallow: a reset form has no business in a search index.
    await page.goto('/index.php?rp=/password/reset');
    expect((await head(page)).robots).toBe('noindex, nofollow');
  });

  test('TH-15 hreflang alternates follow the custom language list', async ({ page }) => {
    set({ enable_alternate_links: on, custom_language_list: on, custom_language_codes: json(['english', 'french']) });
    await page.goto('/knowledgebase.php');
    const alts = await page.locator('head link[rel="alternate"][hreflang]').evaluateAll(ls => ls.map(l => [l.hreflang, l.href]));
    const langs = alts.map(a => a[0]);
    expect(langs, alts.join(' | ')).toContain('x-default');
    expect(langs.length, `only x-default + the two chosen languages: ${langs}`).toBe(3);
    expect(alts.filter(a => a[0] !== 'x-default').every(a => /language=(english|french)/.test(a[1])), 'each alternate names its language').toBe(true);
  });

  test('TH-17 favicon tags only with an uploaded favicon; apple-touch-icon also needs a square logo', async ({ page, context }) => {
    await page.goto('/');
    expect(await page.locator('head link[rel="icon"]').count(), 'no favicon uploaded: no tag').toBe(0);
    // A 1x1 PNG.
    buyerFile(FILES.favicon, Buffer.from('iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==', 'base64'));
    set({ favicon: str('hadrian-test-favicon.png') });
    await page.goto('/');
    const href = await page.locator('head link[rel="icon"]').getAttribute('href');
    expect(href).toMatch(/\/templates\/hadrian\/assets\/img\/branding\/hadrian-test-favicon\.png$/);
    expect((await context.request.get(new URL(href, BASE_URL).href)).status(), 'the favicon URL serves the file').toBe(200);
    expect(await page.locator('head link[rel="shortcut icon"]').count()).toBe(1);
    expect(await page.locator('head link[rel="apple-touch-icon"]').count(), 'no square logo: no touch icon').toBe(0);
    set({ logo_square_light: str('hadrian-test-favicon.png') });
    await page.goto('/');
    expect(await page.locator('head link[rel="apple-touch-icon"]').count()).toBe(1);
  });
});

// ================================================================== TH-C
test.describe('TH-C Layouts', () => {
  test('TH-21 a page can pin its own main-menu and footer layout', async ({ page, context }) => {
    await loginClient(context.request, 'full');
    await page.goto('/clientarea.php');
    const globalLayout = await bodyAttr(page, 'data-layout');
    expect(globalLayout, 'this install draws the sidebar by default').toBe('side');
    pageRow({ clientareaproducts: { settings: { layout_overrides: { 'main-menu': 'top', footer: 'extended-info' } } } });
    await page.goto('/clientarea.php?action=services');
    expect(await bodyAttr(page, 'data-layout'), 'the services page draws its own pick').toBe('top');
    await expect(page.locator('footer.hp-footer-extended-info')).toHaveCount(1);
    await page.goto('/clientarea.php');
    expect(await bodyAttr(page, 'data-layout'), 'other pages keep the global pick').toBe(globalLayout);
    await expect(page.locator('footer.hp-footer-extended-info')).toHaveCount(0);
    await clean(page, context, 'full', ['/clientarea.php?action=services']);
  });

  test('TH-21 an override naming a layout that does not exist is ignored', async ({ page, context }) => {
    await loginClient(context.request, 'full');
    pageRow({ clientareaproducts: { settings: { layout_overrides: { 'main-menu': 'no-such-layout' } } } });
    await page.goto('/clientarea.php?action=services');
    expect(await bodyAttr(page, 'data-layout')).toBe('side');
  });

  test('TH-22 sidebar options: content alignment, which side, and the account block', async ({ page, context }) => {
    await loginClient(context.request, 'full');
    await page.goto('/clientarea.php');
    expect(await bodyAttr(page, 'data-sidebar-side'), 'left by default: no attribute').toBeNull();
    await expect(page.locator('.sidebar .sidebar-footer')).toBeVisible();
    set({ 'hadrian_layout_opts_main-menu_sidebar': json({ align: 'left', side: 'right', profile: 'hide' }) });
    await page.goto('/clientarea.php');
    expect(await bodyAttr(page, 'data-align')).toBe('left');
    expect(await bodyAttr(page, 'data-sidebar-side')).toBe('right');
    expect(await bodyAttr(page, 'data-nav-profile')).toBe('hide');
    const box = await page.locator('.sidebar').boundingBox();
    const vw = page.viewportSize().width;
    expect(Math.round(box.x + box.width), 'the sidebar sits on the right edge').toBeGreaterThanOrEqual(vw - 2);
    await expect(page.locator('.sidebar .sidebar-footer'), 'account block hidden').toBeHidden();
    await expect(page.locator('.topbar-avatar:visible, .ph-side-topbar [class*="avatar"]:visible').first(), 'the topbar keeps an avatar').toBeVisible();
    await clean(page, context, 'full', ['/clientarea.php', '/clientarea.php?action=services']);
  });

  test('TH-22 rail options: the rail moves right and drops its account block', async ({ page, context }) => {
    await loginClient(context.request, 'full');
    set({ 'hadrian_active_layout_main-menu_client': str('rail'), 'hadrian_layout_opts_main-menu_rail': json({ side: 'right', profile: 'hide' }) });
    await page.goto('/clientarea.php');
    expect(await bodyAttr(page, 'data-layout')).toBe('rail');
    const box = await page.locator('.ph-rail').boundingBox();
    expect(Math.round(box.x + box.width)).toBeGreaterThanOrEqual(page.viewportSize().width - 2);
    await expect(page.locator('.ph-rail > .profile-dropdown-wrapper')).toBeHidden();
  });

  test('TH-26 container tokens: max width and padding reach :root', async ({ page }) => {
    set({ hadrian_layout_vars: json({ '--content-max-width': 900, '--content-pad-x': 24, '--not-a-token': 5 }) });
    await page.goto('/knowledgebase.php');
    expect(await rootVar(page, '--content-max-width')).toBe('900px');
    expect(await rootVar(page, '--content-pad-x')).toBe('24px');
    const style = await page.locator('style#hadrian-layout').innerText();
    expect(style, 'an unknown token is dropped').not.toContain('--not-a-token');
    set({ hadrian_layout_vars: json({ '--content-max-width': 99999 }) });
    await page.goto('/knowledgebase.php');
    expect(await rootVar(page, '--content-max-width'), 'out of range: the default stays').toBe('1120px');
  });
});

// ================================================================== TH-D
test.describe('TH-D Navigation chrome', () => {
  test('TH-38 affixed navigation: the bar slides away on the way down and back on the way up', async ({ page, context }) => {
    await loginClient(context.request, 'full');
    set({ affixed_navigation: on });
    // At 900px and below the side layout's topbar is the bar that moves.
    await page.setViewportSize({ width: 820, height: 640 });
    await page.goto('/clientarea.php?action=services');
    await page.evaluate(() => { document.body.style.minHeight = '5000px'; });
    const bar = page.locator('.ph-side-topbar');
    const shifted = () => bar.evaluate(e => new DOMMatrixReadOnly(getComputedStyle(e).transform).m42);
    await page.mouse.wheel(0, 900);
    await expect.poll(() => page.evaluate(() => document.body.classList.contains('scroll-down')), { timeout: 5000 }).toBe(true);
    await expect.poll(shifted, { message: 'hidden above the viewport' }).toBeLessThan(0);
    await page.mouse.wheel(0, -400);
    await expect.poll(() => page.evaluate(() => document.body.classList.contains('scroll-up')), { timeout: 5000 }).toBe(true);
    await expect.poll(shifted, { message: 'back in view' }).toBe(0);
  });
});

// ================================================================== TH-E
test.describe('TH-E Sub-nav and card treatment', () => {
  test('TH-40 website sub-nav: the exception list flips the global, the page field beats both', async ({ page, context }) => {
    await loginClient(context.request, 'full');
    const profile = '/index.php?rp=/user/profile', password = '/index.php?rp=/user/password';
    const cards = () => page.locator('.subnav-card:visible').count();
    await page.goto(profile);
    expect(await cards(), 'the profile page has a sub-nav').toBeGreaterThan(0);

    set({ subnav_pages_website: json(['user-profile']) });
    await page.goto(profile);
    expect(await bodyAttr(page, 'data-subnav-website'), 'listed: flipped off').toBe('off');
    expect(await cards()).toBe(0);
    await page.goto(password);
    expect(await bodyAttr(page, 'data-subnav-website'), 'not listed: unchanged').toBeNull();

    pageRow({ 'user-profile': { settings: { subnav: 'on' } } });
    await page.goto(profile);
    expect(await bodyAttr(page, 'data-subnav-website'), 'the page field beats the list').toBeNull();

    set({ website_subnav: off, subnav_pages_website: json([]) });
    await page.goto(profile);
    expect(await bodyAttr(page, 'data-subnav-website'), 'and beats the global').toBeNull();
    await page.goto(password);
    expect(await bodyAttr(page, 'data-subnav-website')).toBe('off');
  });

  test('TH-41 order sub-nav: the exception list hides the category rail on one cart page', async ({ page }) => {
    set({ subnav_pages_order: json(['viewcart']) });
    await page.goto('/cart.php?a=view');
    expect(await bodyAttr(page, 'data-subnav-order')).toBe('off');
    await page.goto(`/index.php?rp=/store/${id.productGroupSlug}`);
    expect(await bodyAttr(page, 'data-subnav-order')).toBeNull();
  });

  // Services and emails follow the setting. Domains, invoices, quotes, tickets,
  // add funds, the dashboard and the store pages pin their own layout with a
  // body script (their bespoke cards break outside), so they can't show it.
  test('TH-42 card controls: the exception list and the page field', async ({ page, context }) => {
    await loginClient(context.request, 'full');
    set({ svc_layout_pages: json(['clientareaproducts']) });
    await page.goto('/clientarea.php?action=services');
    expect(await bodyAttr(page, 'data-svc-layout'), 'listed: outside').toBe('outside');
    await page.goto('/clientarea.php?action=emails');
    expect(await bodyAttr(page, 'data-svc-layout'), 'not listed: inside').toBeNull();

    pageRow({ clientareaproducts: { settings: { svclayout: 'inside' } } });
    await page.goto('/clientarea.php?action=services');
    expect(await bodyAttr(page, 'data-svc-layout'), 'the page field beats the list').toBeNull();

    set({ svc_layout_pages: json([]), service_controls_outside: on });
    pageRow({ clientareaproducts: { settings: { svclayout: 'inherit' } }, clientareaemails: { settings: { svclayout: 'inside' } } });
    await page.goto('/clientarea.php?action=emails');
    expect(await bodyAttr(page, 'data-svc-layout'), 'and beats the global').toBeNull();
    await page.goto('/clientarea.php?action=services');
    expect(await bodyAttr(page, 'data-svc-layout'), 'no field: the global').toBe('outside');
  });
});

// ================================================================== TH-F
test.describe('TH-F Global settings', () => {
  test('TH-46 "Free" label on the services list and the service page', async ({ page, context }) => {
    // Service 16 of the full persona is a 0.00 one-time product.
    await loginClient(context.request, 'full');
    const row = () => page.locator('.content-area tr, .content-area [class*="row"]').filter({ has: page.locator('a[href*="id=16"], [data-href*="id=16"], [onclick*="id=16"]') }).first();
    await page.goto('/clientarea.php?action=services');
    await expect(row()).toContainText(/0\.00/);
    set({ free_label: on });
    await page.goto('/clientarea.php?action=services');
    await expect(row()).toContainText(/free/i);
    await expect(row()).not.toContainText(/\$0\.00/);
    await page.goto('/clientarea.php?action=productdetails&id=16');
    await expect(page.locator('.content-area')).toContainText(/free/i);
  });

  test('TH-47 OF-06 OF-15 hiding cycle discounts removes the Save badges in the store and on configure', async ({ page }) => {
    const store = `/index.php?rp=/store/${id.productGroupSlug}`;
    await page.goto(store);
    const saving = page.locator('.st-cycle-saving');
    await expect(saving, 'a plan with monthly and annual prices has a saving').toBeVisible();
    await expect(saving).toContainText(/\d+\s?%/);
    await page.goto('/cart.php?a=add&pid=14');
    await page.waitForLoadState('load');
    if (await tpl(page) === 'configureproductdomain') {
      await page.locator('label:has(input[name=domainoption][value=owndomain])').click();
      const dom = page.locator('#frmProductDomain input[type=text]:visible');
      await dom.nth(0).fill('hadrian-save-test');
      await dom.nth(1).fill('com');
      await page.locator('button.dp-continue').click();
      await page.waitForURL(/a=confproduct/);
    }
    const confUrl = page.url();
    await expect(page.locator('.cp-cycle-save').first(), 'configure shows a Save pill on a cheaper cycle').toBeVisible();

    set({ hide_cycle_discounts: on });
    await page.goto(store);
    await expect(page.locator('.st-cycle-saving')).toHaveCount(0);
    await page.goto(confUrl);
    await expect(page.locator('.cp-cycle-save:visible')).toHaveCount(0);
    await page.goto('/cart.php?a=empty');
  });

  test('TH-48 cookie message per language, then the default language, then the built-in text', async ({ page }) => {
    const msg = () => page.locator('#mtCookieBar .mt-cookie-bar__msg').innerText();
    set({ cookie_box: on, cookie_box_message: json({ english: 'EN cookie notice (hadrian-test)', french: 'Avis cookies FR (hadrian-test)' }) });
    try {
      await page.goto('/?language=english');
      await expect(page.locator('#mtCookieBar')).toBeVisible({ timeout: 6000 });
      expect(await msg()).toBe('EN cookie notice (hadrian-test)');
      await page.goto('/?language=french');
      await expect(page.locator('#mtCookieBar')).toBeVisible({ timeout: 6000 });
      expect(await msg()).toBe('Avis cookies FR (hadrian-test)');
      await page.goto('/?language=german');
      await expect(page.locator('#mtCookieBar')).toBeVisible({ timeout: 6000 });
      expect(await msg(), 'no German text: the site\'s default language').toBe('EN cookie notice (hadrian-test)');
      set({ cookie_box_message: json({}) });
      await page.goto('/?language=english');
      await expect(page.locator('#mtCookieBar')).toBeVisible({ timeout: 6000 });
      const builtIn = await msg();
      expect(builtIn.length, 'the theme\'s own message').toBeGreaterThan(10);
      expect(builtIn).not.toContain('hadrian-test');
    } finally {
      await page.goto('/?language=english');
    }
  });
});

// ================================================================== TH-G
test.describe('TH-G Dark mode', () => {
  test('TH-54 forced light: a saved dark choice is ignored and there is no switch', async ({ page, context }) => {
    set({ dark_mode_display: str('forced'), dark_mode_default: str('light') });
    await loginClient(context.request, 'full');
    await context.addCookies([{ name: 'mt_theme', value: 'dark', url: BASE_URL }]);
    await page.goto('/clientarea.php');
    await expect(page.locator('html')).toHaveAttribute('data-theme', 'light');
    await page.locator('.sidebar-user:visible, .topbar-avatar:visible').first().click();
    await expect(page.locator('.toggle-switch:visible')).toHaveCount(0);
    await page.reload();
    await expect(page.locator('html'), 'and the JS does not bring the saved choice back').toHaveAttribute('data-theme', 'light');
  });
});

// ================================================================== TH-H
test.describe('TH-H Styles and tokens', () => {
  test('TH-57 every light preset is activated from the Styles screen and paints its own accent', async ({ page, context, browser }) => {
    // Through the admin, not the table: Activate also copies the preset's
    // colours into its stored scopes (StylesController::seedStyleColors),
    // and that copy is what the client side paints from.
    test.setTimeout(3 * 60_000);
    const styles = ['default', 'emerald', 'violet', 'rose', 'amber', 'slate'];
    set(Object.fromEntries(styles.flatMap(s => [[`hadrian_colors_${s}_light`, null], [`hadrian_colors_${s}_dark`, null], [`hadrian_colors_${s}`, null]])));
    const adminCtx = await browser.newContext({ baseURL: BASE_URL, userAgent: await page.evaluate(() => navigator.userAgent) });
    try {
      await loginAdmin(adminCtx.request);
      const admin = await adminCtx.newPage();
      await admin.goto('/admin/addonmodules.php?module=Hadrian&action=styles');
      const cards = await admin.locator('label.mt-sty-card input[name=style]').evaluateAll(is => is.map(i => i.value));
      expect(cards, 'the dark preset is a mode, not a card').not.toContain('dark');
      expect(cards).toEqual(expect.arrayContaining(styles));
      const accent = {};
      for (const style of styles) {
        await Promise.all([admin.waitForLoadState('load'), admin.locator(`label.mt-sty-card:has(input[value="${style}"])`).click()]);
        await admin.waitForURL(/action=styles/);
        await expect(admin.locator('.mt-sty-card.is-active input[name=style]'), `${style} is the active card`).toHaveValue(style);
        await page.goto('/knowledgebase.php');
        await expect(page.locator('body'), style).toHaveClass(new RegExp(`(^|\\s)theme-${style}(\\s|$)`));
        accent[style] = await rootVar(page, '--color-accent');
      }
      expect(new Set(Object.values(accent)).size, `each preset has its own accent: ${JSON.stringify(accent)}`).toBe(styles.length);
    } finally {
      await adminCtx.close();
    }
    set({ hadrian_active_style: str('dark') });
    await page.goto('/knowledgebase.php');
    await expect(page.locator('body'), 'a stored "dark" style falls back to default').toHaveClass(/(^|\s)theme-default(\s|$)/);
  });

  test('TH-59 typography: Google fonts with their weights, a heading font and sizes', async ({ page }) => {
    await page.route(/fonts\.(googleapis|gstatic)\.com/, r => r.abort());
    set({ hadrian_typography: json({
      fontFamily: { mode: 'google', google: 'Roboto', googleWeights: [700, 400, 9999] },
      headingFamily: { mode: 'google', google: 'Lora', googleWeights: [600] },
      sizes: { '--text-base': 15, '--text-lg': 0 }, lineHeights: { '--lh-body': 1.6, '--lh-tight': 9 },
    }) });
    await page.goto('/knowledgebase.php');
    const hrefs = await page.locator('head link[rel="stylesheet"][href*="fonts.googleapis.com"]').evaluateAll(ls => ls.map(l => l.getAttribute('href')));
    expect(hrefs, 'weights sorted, out-of-range dropped').toContain('https://fonts.googleapis.com/css2?family=Roboto:wght@400;700&display=swap');
    expect(hrefs).toContain('https://fonts.googleapis.com/css2?family=Lora:wght@600&display=swap');
    expect(await rootVar(page, '--font-family')).toMatch(/^'?Roboto'?,/);
    expect(await rootVar(page, '--font-family-heading')).toMatch(/Lora/);
    expect(await rootVar(page, '--text-base')).toBe('15px');
    expect(await rootVar(page, '--text-lg'), 'a zero size is ignored: the default stays').toBe('15px');
    expect(await rootVar(page, '--lh-body')).toBe('1.6');
    expect(await page.evaluate(() => getComputedStyle(document.body).fontFamily)).toMatch(/Roboto/);

    set({ hadrian_typography: json({ fontFamily: { mode: 'system' } }) });
    await page.goto('/knowledgebase.php');
    expect(await page.locator('head link[href*="fonts.googleapis.com"]').count(), 'system fonts: nothing from Google').toBe(0);
    expect(await rootVar(page, '--font-family')).toMatch(/system-ui|-apple-system|BlinkMacSystemFont/);
  });

  test('TH-61 custom CSS is printed in the head and cannot close its <style>', async ({ page }) => {
    set({ hadrian_custom_css: str('body{outline:3px solid rgb(1, 2, 3)}</style><script>window.__mtInjected=1</script><style>') });
    await page.goto('/knowledgebase.php');
    const css = page.locator('head style#hadrian-custom-css');
    await expect(css).toHaveCount(1);
    expect(await page.evaluate(() => getComputedStyle(document.body).outlineColor)).toBe('rgb(1, 2, 3)');
    expect(await page.evaluate(() => window.__mtInjected), 'the script inside the CSS never ran').toBeUndefined();
    const last = await page.evaluate(() => { const s = [...document.head.querySelectorAll('style')]; return s[s.length - 1]?.id; });
    expect(last, 'printed after the theme\'s own token blocks, so it wins').toBe('hadrian-custom-css');
  });
});

// ================================================================== TH-J
test.describe('TH-J Languages', () => {
  test('TH-67 a theme-string override wins; a broken override is skipped', async ({ page }) => {
    buyerFile(FILES.langEnglish, "<?php\nreturn ['common' => ['localeChoose' => 'Choose a language (hadrian-test override)']];\n");
    buyerFile(FILES.langFrench, "<?php\nreturn ['common' => ['localeChoose' => \n");   // a syntax error
    await opcacheSettle(page);
    try {
      // The footer locale button (partials/locale-btn.tpl) carries the string
      // as hidden text after the visible "English / USD", so the spoken name
      // starts with what is on screen (WCAG 2.5.3); an aria-label would hide it.
      await page.goto('/?language=english');
      await expect(page.locator('button.locale-btn .sr-only').first()).toContainText('Choose a language (hadrian-test override)');
      const res = await page.goto('/?language=french');
      expect(res.status()).toBe(200);
      expect(inspect(await page.content()).problems, 'the broken file breaks nothing').toEqual([]);
      const label = await page.locator('button.locale-btn .sr-only').first().textContent();
      expect(label.trim().length).toBeGreaterThan(0);
      expect(label).not.toContain('hadrian-test');
    } finally {
      await page.goto('/?language=english');
    }
  });

  test('TH-69 the language and currency parts of the locale button hide independently', async ({ page }) => {
    const btn = page.locator('.locale-btn').first();
    set({ hide_currency_selector: on });
    await page.goto('/?language=english');
    await expect(btn).toBeVisible();
    await expect(btn, 'language still named').toContainText(/English/i);
    await expect(btn, 'no currency').not.toContainText(/USD/);
    set({ hide_currency_selector: off, hide_language_switcher: on });
    await page.goto('/?language=english');
    if (await page.locator('.locale-btn').count()) {
      await expect(btn, 'language hidden').not.toContainText(/English/i);
    }
  });
});

// ================================================================== TH-K
test.describe('TH-K Page variants', () => {
  test('TH-72 overwrites.tpl replaces a page body over any variant', async ({ page }) => {
    buyerFile(FILES.kbOverwrite, '<div id="mt-test-overwrite"><h1>Our own help page (hadrian-test)</h1></div>\n');
    await page.goto('/knowledgebase.php');
    expect(await tpl(page)).toBe('knowledgebase');
    await expect(page.locator('#mt-test-overwrite')).toBeVisible();
    await expect(page.locator('.content-area input[name=search], .content-area input[type=search]'), 'the default body is gone').toHaveCount(0);
    expect(inspect(await page.content()).problems).toEqual([]);
  });

  test('TH-04 the full-page option drops the portal chrome on a Default page', async ({ page, context }) => {
    await loginClient(context.request, 'full');
    pageRow({ clientareahome: { settings: { options: { full_page: '1' } } } });
    await page.goto('/clientarea.php');
    expect(await tpl(page)).toBe('clientareahome');
    await expect(page.locator('body')).toHaveClass(/mt-login-fullpage/);
    for (const sel of ['.sidebar', '.ph-rail', '.ph-side-topbar', 'footer[class*="hp-footer"]', '#localeModal']) {
      await expect(page.locator(sel), `${sel} is not drawn`).toHaveCount(0);
    }
    await page.goto('/clientarea.php?action=services');
    await expect(page.locator('.sidebar'), 'other pages keep it').toHaveCount(1);
  });

  test('TH-74 dashboard variants read their own options', async ({ page, context }) => {
    test.setTimeout(2 * 60_000);
    await loginClient(context.request, 'full');
    const warm = async () => { await context.request.get('/clientarea.php').catch(() => {}); };

    variant({ clientareahome: 'atrium' }); await warm();
    pageRow({ clientareahome: { settings: { options: { atr_section_titles__atrium: 'outside', atr_hero_style__atrium: 'gradient' } } } });
    await page.goto('/clientarea.php');
    expect(await bodyAttr(page, 'data-at-title')).toBe('outside');
    await expect(page.locator('[data-at-style="gradient"]')).toHaveCount(1);

    variant({ clientareahome: 'bento' }); await warm();
    pageRow({ clientareahome: { settings: { options: { bnt_section_titles__bento: 'outside', bnt_hero_style__bento: 'solid' } } } });
    await page.goto('/clientarea.php');
    expect(await bodyAttr(page, 'data-bn-title')).toBe('outside');
    await expect(page.locator('[data-at-style="solid"]'), 'bento keeps its own band settings').toHaveCount(1);

    variant({ clientareahome: 'minimal' }); await warm();
    await page.goto('/clientarea.php');
    await expect(page.locator('.min-actions'), 'quick actions by default').toHaveCount(1);
    pageRow({ clientareahome: { settings: { options: { min_section_titles__minimal: 'inside', min_show_actions__minimal: '0' } } } });
    await page.goto('/clientarea.php');
    expect(await bodyAttr(page, 'data-min-title')).toBe('inside');
    await expect(page.locator('.min-actions')).toHaveCount(0);
  });

  test('TH-74 bento "Identity card beside the greeting" changes the dashboard', async ({ page, context }) => {
    test.fail(true, 'BUG: bnt_account is offered in Pages (bento.php:101) but bento.tpl:53-54 only assigns $bnAcct and nothing reads it since the identity card moved into the welcome band');
    await loginClient(context.request, 'full');
    variant({ clientareahome: 'bento' });
    await context.request.get('/clientarea.php').catch(() => {});
    const body = async () => (await page.locator('.content-area').innerHTML()).replace(/\s+/g, ' ');
    await page.goto('/clientarea.php');
    const before = await body();
    pageRow({ clientareahome: { settings: { options: { bnt_account__bento: '0' } } } });
    await page.goto('/clientarea.php');
    expect(await body()).not.toBe(before);
  });
});

// The hero title and subtitle half of TH-75 (bug 8) is in
// known-bugs.spec.mjs. These are the five section switches beside them: the
// Pages screen offers them (homepage/page.php supportedOptions), the docs
// describe them, and no template reads them.
const HOMEPAGE_SECTIONS = [
  ['show_domain_search', 'form.ph-domain-form'],
  ['show_products', 'section.hp-pricing-segmented'],
  ['show_features', 'section#how.hp-icon-grid'],
  ['show_news', 'section.hp-announce-grid'],
  ['show_cta', 'section.hp-cta-immersive'],
];
test.describe('TH-K Homepage section switches', () => {
  // Not under test.fail(): if a section went missing for another reason, the
  // switch tests below would "fail as expected" and hide it.
  test('TH-75 the Modern homepage draws all five switchable sections by default', async ({ page }) => {
    await page.goto('/');
    for (const [option, section] of HOMEPAGE_SECTIONS) await expect(page.locator(section), option).toHaveCount(1);
  });
  for (const [option, section] of HOMEPAGE_SECTIONS) {
    test(`TH-75 ${option} off hides ${section} on the Modern homepage`, async ({ page }) => {
      test.fail(true, `BUG: ${option} is offered in Pages (core/pages/homepage/page.php supportedOptions) but homepage/default/default.tpl never reads it, so the section always shows`);
      await page.goto('/');
      await expect(page.locator(section), 'the section is there by default').toHaveCount(1);
      pageRow({ homepage: { settings: { options: { [option]: '0' } } } });
      await page.goto('/');
      await expect(page.locator(section)).toHaveCount(0);
    });
  }
});

// ================================================================== TH-A
test.describe('TH-A Page shell', () => {
  test('TH-06 hook output lands in the head, right after <body> opens, and before the scripts', async ({ page }) => {
    buyerFile(FILES.hook, `<?php
// Written by tests/e2e/theme-settings.spec.mjs for one test, removed after it.
add_hook('ClientAreaHeadOutput', 99, function () { return '<meta name="hadrian-test-head" content="1">'; });
add_hook('ClientAreaHeaderOutput', 1, function () { return '<div id="hadrian-test-header"></div>'; });
add_hook('ClientAreaFooterOutput', 1, function () { return '<div id="hadrian-test-footer"></div>'; });
`);
    await opcacheSettle(page);
    await page.goto('/knowledgebase.php');
    const where = await page.evaluate(() => {
      const meta = document.head.querySelector('meta[name="hadrian-test-head"]');
      const css = document.head.querySelector('link[href*="core-theme.css"]');
      const header = document.getElementById('hadrian-test-header');
      const footer = document.getElementById('hadrian-test-footer');
      const script = document.querySelector('script[src*="core-layout.js"]');
      return {
        meta: !!meta, metaAfterCss: !!(meta && css && (css.compareDocumentPosition(meta) & Node.DOCUMENT_POSITION_FOLLOWING)),
        headerFirst: document.body.firstElementChild?.id === 'hadrian-test-header' || [...document.body.children].slice(0, 3).some(e => e.id === 'hadrian-test-header'),
        footer: !!footer, footerBeforeScripts: !!(footer && script && (footer.compareDocumentPosition(script) & Node.DOCUMENT_POSITION_FOLLOWING)),
      };
    });
    expect(where).toEqual({ meta: true, metaAfterCss: true, headerFirst: true, footer: true, footerBeforeScripts: true });
  });

  test('TH-07 overwrites/footer.tpl replaces the whole footer', async ({ page }) => {
    buyerFile(FILES.footer, '    </div>\n</div>\n<footer id="mt-test-footer">Our own footer (hadrian-test)</footer>\n</body>\n</html>\n');
    await page.goto('/knowledgebase.php');
    await expect(page.locator('#mt-test-footer')).toBeVisible();
    await expect(page.locator('footer[class*="hp-footer"]'), 'the theme footer is not drawn').toHaveCount(0);
    await expect(page.locator('script[src*="core-layout.js"]'), 'nor its scripts: the overwrite owns the whole footer').toHaveCount(0);
  });

  test('TH-124 a theme extension adds head and footer output only while theme.json lists it', async ({ page }) => {
    buyerFile(FILES.extension, `<?php
// Written by tests/e2e/theme-settings.spec.mjs for one test, removed after it.
return [
    'headOutput'   => function ($vars) { return '<meta name="hadrian-test-ext" content="' . htmlspecialchars((string)($vars['templatefile'] ?? ''), ENT_QUOTES) . '">'; },
    'footerOutput' => function ($vars) { return '<div id="hadrian-test-ext-footer"></div>'; },
];
`);
    await page.goto('/knowledgebase.php');
    await expect(page.locator('head meta[name="hadrian-test-ext"]'), 'not listed: not loaded').toHaveCount(0);
    editThemeJson(m => { (m.provides ||= {}).extensions = ['hadrian-test']; });
    await opcacheSettle(page);
    await page.goto('/knowledgebase.php');
    await expect(page.locator('head meta[name="hadrian-test-ext"]')).toHaveAttribute('content', 'knowledgebase');
    await expect(page.locator('#hadrian-test-ext-footer')).toHaveCount(1);
  });
});

// ================================================================== OF
test.describe('OF order-process settings in the cart', () => {
  const serverUrl = `/cart.php?a=add&pid=${id.serverProductId}`;
  async function configureServer(page, { hostname = 'srv1.hadrian-test.com', rootpw = 'Tr0ub4dor&3-Horse!' } = {}) {
    await page.goto(serverUrl);
    if (!/a=confproduct/.test(page.url())) await page.waitForURL(/a=confproduct/);
    if (await page.locator('input[name=hostname]').isVisible()) await page.locator('input[name=hostname]').fill(hostname);
    if (await page.locator('input[name=rootpw]').isVisible()) await page.locator('input[name=rootpw]').fill(rootpw);
    for (const [n, v] of [['ns1prefix', 'ns1'], ['ns2prefix', 'ns2']]) {
      const f = page.locator(`input[name=${n}]`);
      if (await f.isVisible()) await f.fill(v);
    }
    await page.locator('#btnCompleteProductConfig').click();
  }

  test('OF-24 OF-26 with the hostname hidden, WHMCS accepts the generated hostname and password', async ({ page }) => {
    set({ op_hide_hostname: str('all'), op_custom_hostname: on, op_custom_hostname_interfix: str('10'),
      op_custom_hostname_prefix: str('vps'), op_custom_hostname_suffix: str('.hadrian.test'), op_custom_hostname_chars: json(['numbers']) });
    try {
      await configureServer(page);
      await page.waitForURL(/a=view/, { timeout: 30_000 });
      expect(await tpl(page)).toBe('viewcart');
      await expect(page.locator('.ct-product-domain').first(), 'the generated hostname is on the order').toHaveText(/^[0-9]{10}\.vps\.hadrian\.test$/);
    } finally {
      await page.goto('/cart.php?a=empty');
    }
  });

  test('OF-27 the root-password strength check refuses a weak password on the server', async ({ page }) => {
    set({ op_root_pw_strength: on });
    try {
      await configureServer(page, { rootpw: 'abc' });
      await expect(page.locator('.content-area'), 'the hook\'s message is shown').toContainText(/root password is too weak/i, { timeout: 20_000 });
      expect(page.url(), 'still on the configure step').toMatch(/a=confproduct/);
      await page.locator('input[name=rootpw]').fill('Tr0ub4dor&3-Horse!');
      await page.locator('#btnCompleteProductConfig').click();
      await page.waitForURL(/a=view/, { timeout: 30_000 });
    } finally {
      await page.goto('/cart.php?a=empty');
    }
  });

  test('OF-28 "hide on checkout" drops the hostname line from the cart for matching groups', async ({ page }) => {
    try {
      await configureServer(page, { hostname: 'srv-visible.hadrian-test.com' });
      await page.waitForURL(/a=view/, { timeout: 30_000 });
      const line = page.locator('.ct-product-domain');
      await expect(line.first()).toHaveText('srv-visible.hadrian-test.com');
      set({ op_hide_hostname_checkout: on, op_hide_hostname: str('selected'), op_hide_hostname_groups: json([String(id.serverGroupId + 999)]) });
      await page.reload();
      await expect(line, 'another group listed: still shown').toHaveCount(1);
      set({ op_hide_hostname_groups: json([String(id.serverGroupId)]) });
      await page.reload();
      await expect(line, 'this group listed: hidden').toHaveCount(0);
      set({ op_hide_hostname: str('all') });
      await page.reload();
      await expect(line).toHaveCount(0);
      set({ op_hide_hostname_checkout: off });
      await page.reload();
      await expect(line, 'the checkout flag alone decides').toHaveCount(1);
    } finally {
      await page.goto('/cart.php?a=empty');
    }
  });

  test('OF-88 the "Free" label in the cart and the checkout summary', async ({ page }) => {
    test.setTimeout(2 * 60_000);
    set({ free_label: on });
    try {
      await page.goto('/index.php?rp=/store/openpanel-hosting');
      await page.locator('a[id^=product]').first().click();
      await page.waitForLoadState('load');
      if (await tpl(page) === 'configureproductdomain') {
        await page.locator('label:has(input[name=domainoption][value=owndomain])').click();
        const dom = page.locator('#frmProductDomain input[type=text]:visible');
        await dom.nth(0).fill('hadrian-free-label');
        await dom.nth(1).fill('com');
        await page.locator('button.dp-continue').click();
      }
      await page.waitForURL(/a=(confproduct|view)/);
      if (/a=confproduct/.test(page.url())) {
        await page.locator('#btnCompleteProductConfig').click();
        await page.waitForURL(/a=view/);
      }
      const card = page.locator('.ct-product').first();
      await expect(card).toContainText(/free/i);
      await expect(card, 'the line reads Free, not $0.00').not.toContainText(/\$0\.00/);
      await page.locator('#checkout').click();
      await page.waitForURL(/a=checkout/);
      await expect(page.locator('#frmCheckout')).toBeAttached();
      const aside = page.locator('[class*="summary"]').filter({ hasText: /openpanel|free/i }).first();
      await expect(aside, 'the checkout summary names it Free too').toContainText(/free/i);
    } finally {
      await page.goto('/cart.php?a=empty');
    }
  });
});
