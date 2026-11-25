// Tier 3b (client-area features) - one behavioural test per TH-* feature in
// tests/FEATURES.md that can be exercised without changing a setting.
//
// Each test performs the feature (clicks the control, saves the form, follows
// the link) and asserts what changed. Smoke and sweep already prove the pages
// load; nothing here repeats that alone.
//
// Ground rules, because the smoke, browser and order specs run beside this one
// against the same WHMCS:
//   - no setting is written (hadrian_settings, hadrian_pages, tblconfiguration,
//     menus). Layout and preview variants come from ?preview=1 URL params.
//   - a write that is not undone by itself goes to a throwaway customer,
//     flow+ca-<n>@demo.hadrian.test, made and deleted by tests/php/client-area.php
//     (tests/php/fixtures.php removes any a crashed run leaves behind).
//   - a write to a shared persona (domain auto-renew, the empty persona's
//     verification token, KB vote counters, ticket feedback) is put back in a
//     finally block.
//
// Known theme bugs are kept as test.fail('BUG: ...'): the suite reports them
// and fails once they are fixed, so the marker has to be removed then.

import { test, expect } from '@playwright/test';
import { execFileSync } from 'node:child_process';
import path from 'node:path';
import crypto from 'node:crypto';
import { BASE_URL, PHP, TESTS_DIR } from '../lib/env.mjs';
import { fx, creds, loginClient, mailTo, totp } from './helpers.mjs';
import { inspect } from './oracles.mjs';
import { measure } from './page-checks.mjs';

const id = fx.ids;
test.describe.configure({ mode: 'default' });

// ------------------------------------------------------------------ helpers

/** tests/php/client-area.php: records the spec owns, and values it restores. */
const ca = (...args) => {
  const out = execFileSync(PHP, [path.join(TESTS_DIR, 'php', 'client-area.php'), ...args.map(String)], { encoding: 'utf8' }).trim();
  return JSON.parse(out.split('\n').pop());
};

function watchErrors(page) {
  const errors = [];
  page.on('pageerror', e => errors.push(`uncaught: ${e.message}`));
  page.on('console', m => { if (m.type() === 'error') errors.push(`console: ${m.text().slice(0, 200)}`); });
  return errors;
}
const tpl = page => page.evaluate(() => document.body.dataset.tpl);
const auth = page => page.evaluate(() => document.body.dataset.auth);
const bodyAttr = (page, name) => page.evaluate(n => document.body.getAttribute(n), name);
const meta = (page, sel) => page.locator(sel).first().getAttribute('content');
const csrf = async ctx => ((await (await ctx.get('/clientarea.php')).text()).match(/name="token" value="([^"]+)"/) || [])[1];

/** Sign in through the form, the way a customer does. */
async function signIn(page, email, password, { remember = false } = {}) {
  await page.goto('/login');
  await page.locator('#loginEmail').fill(email);
  await page.locator('#loginPassword').fill(password);
  if (remember) await page.locator('input[name=rememberme]').check();
  await page.locator('.auth-form [type=submit]').click();
  await page.waitForLoadState('load');
}

/** Sign a request context in with an arbitrary user (throwaway customers). */
async function loginAs(ctx, email, password) {
  const html = await (await ctx.get('/login')).text();
  const token = (html.match(/name="token" value="([^"]+)"/) || [])[1];
  await ctx.post('/index.php?rp=/login', { form: { username: email, password, token } });
}

/**
 * A brand new customer for tests that change account state. Signed in on
 * `context` unless signIn is false. Call .remove() in a finally block.
 */
async function throwaway(context, { signIn: doSignIn = true, service = false } = {}) {
  const email = `flow+ca-${Date.now().toString(36)}${crypto.randomBytes(2).toString('hex')}@demo.hadrian.test`;
  const password = `Ca!${crypto.randomBytes(9).toString('base64url')}9x`;
  const { clientId, userId } = ca('make-client', email, password);
  const t = { email, password, clientId, userId, remove: () => ca('delete-client', clientId) };
  if (service) t.serviceId = ca('add-service', clientId).serviceId;
  if (doSignIn) await loginAs(context.request, email, password);
  return t;
}

// ======================================================================= TH-A
test.describe('TH-A Page shell', () => {
  test('TH-02 body state attributes follow sign-in and the page', async ({ page }) => {
    const errors = watchErrors(page);
    await page.goto('/');
    expect(await bodyAttr(page, 'data-auth')).toBe('out');
    expect(await bodyAttr(page, 'data-tpl')).toBe('homepage');
    expect(await bodyAttr(page, 'data-area')).toBe('website');
    expect(await bodyAttr(page, 'data-layout')).toBe('side');
    expect(await bodyAttr(page, 'data-active-nav')).toBe('');
    // The active style's bodyClass (core/styles/default/style.php) reaches <body>.
    await expect(page.locator('body')).toHaveClass(/\btheme-default\b/);

    await signIn(page, creds.personas.full.email, creds.personas.full.password);
    expect(await bodyAttr(page, 'data-auth'), 'signing in flips data-auth').toBe('in');
    expect(await bodyAttr(page, 'data-tpl')).toBe('clientareahome');
    expect(await bodyAttr(page, 'data-area')).toBe('client');
    expect(await bodyAttr(page, 'data-active-nav')).toBe('dashboard');

    await page.goto('/clientarea.php?action=services');
    expect(await bodyAttr(page, 'data-tpl')).toBe('clientareaproducts');
    expect(await bodyAttr(page, 'data-active-nav')).toBe('services');
    expect(await bodyAttr(page, 'data-page-title'), 'data-page-title carries WHMCS $pagetitle').toBeTruthy();
    await page.goto(`/viewinvoice.php?id=${id.invoiceId}`);
    expect(await bodyAttr(page, 'data-active-nav')).toBe('invoices');
    expect(errors).toEqual([]);
  });

  test('TH-03 base href, and the cart globals only on order-form pages', async ({ page }) => {
    await page.goto('/clientarea.php');
    expect(await page.locator('base').getAttribute('href'), 'base href is the install root').toBe(`${BASE_URL}/`);
    // Relative links resolve against it (the menu ships relative hrefs).
    expect(await page.evaluate(() => new URL('clientarea.php', document.baseURI).href)).toBe(`${BASE_URL}/clientarea.php`);
    expect(await page.evaluate(() => typeof window.whmcsBaseUrl), 'no cart globals outside the order form').toBe('undefined');

    await page.goto('/cart.php');
    const g = await page.evaluate(() => ({
      token: typeof csrfToken === 'string' ? csrfToken.length : 0,
      base: window.whmcsBaseUrl,
      jq: typeof window.jQuery === 'function' && window.jQuery.fn.jquery,
      modal: typeof window.jQuery?.fn?.modal,
      tooltip: typeof window.jQuery?.fn?.tooltip,
      multiselect: typeof window.jQuery?.fn?.multiselect,
    }));
    expect(g.token, 'csrfToken global').toBeGreaterThan(10);
    expect(g.base).toBe(BASE_URL);
    expect(g.jq).toBe('3.7.1');
    expect(g.modal, 'Bootstrap 4 is loaded').toBe('function');
    expect(g.tooltip).toBe('function');
    expect(g.multiselect, 'bootstrap-multiselect is loaded').toBe('function');
  });

  test('TH-05 verify-email banner: resend and dismiss over AJAX (empty persona)', async ({ page, context }) => {
    const p = creds.personas.empty;
    await loginClient(context.request, 'empty');
    try {
      await page.goto('/clientarea.php');
      const banner = page.locator('#mtVerifyBanner');
      await expect(banner, 'an unverified user sees the banner').toBeVisible();

      const since = Date.now();
      const [resend] = await Promise.all([
        page.waitForResponse(r => /email\/verify\/resend|verification\/resend|user\/verification/.test(r.url()) && r.request().method() === 'POST'),
        banner.locator('[data-mt-resend]').click(),
      ]);
      expect(resend.status()).toBe(200);
      expect((await resend.json()).success, 'WHMCS accepted the resend').toBeTruthy();
      await expect(banner.locator('[data-mt-resend]'), 'the button reports the result').toHaveText(/sent/i);
      await expect(banner.locator('[data-mt-resend]')).toBeDisabled();
      const mail = await mailTo(p.email, since);
      expect(mail.links.some(l => /user\/verify\//.test(l)), `a verification link in "${mail.subject}"`).toBe(true);

      const [dismiss] = await Promise.all([
        page.waitForResponse(r => /dismiss/.test(r.url()) && r.request().method() === 'POST'),
        banner.locator('[data-mt-dismiss]').click(),
      ]);
      expect(dismiss.status()).toBe(200);
      await expect(banner, 'dismissed at once').toHaveCount(0);
      await page.reload();
      await expect(page.locator('#mtVerifyBanner'), 'and it stays dismissed for the session').toHaveCount(0);
      expect(await auth(page)).toBe('in');
    } finally {
      ca('reset-verify', p.email);   // no pending token: the banner stays stable for the other tests
    }
  });

  test('TH-05 network-issue banner links to server status', async ({ page, context }) => {
    // scenarios.php seeds an "Investigating" issue, so the warning banner shows.
    await loginClient(context.request, 'full');
    await page.goto('/clientarea.php');
    const banner = page.locator('.network-issue-alert');
    await expect(banner).toBeVisible();
    await expect(banner).toContainText(/aware|issue/i);
    await banner.locator('a').click();
    await page.waitForURL(/serverstatus\.php/);
    expect(await tpl(page)).toBe('serverstatus');
  });
});

// ======================================================================= TH-B
test.describe('TH-B SEO and head', () => {
  test('TH-12 canonical and og:url drop a currency or language parameter', async ({ page }) => {
    await page.goto('/contact.php?currency=1');
    const canonical = await page.locator('link[rel=canonical]').getAttribute('href');
    expect(canonical).toBe(`${BASE_URL}/contact.php`);
    expect(await meta(page, 'meta[property="og:url"]'), 'og:url is the same address').toBe(canonical);
    await page.goto('/contact.php?language=english');
    expect(await page.locator('link[rel=canonical]').getAttribute('href')).toBe(`${BASE_URL}/contact.php`);
  });

  test('TH-12 canonical with several query parameters strips both and keeps the rest intact', async ({ page }) => {
    test.fail(true, 'BUG: Hooks.php:3203-3207 (resolveSeoContext) parses $_SERVER[REQUEST_URI], which WHMCS has HTML-escaped (& is &amp;), so every parameter after the first keeps an "amp;" prefix: language/currency are not stripped and the canonical reads ?amp%3Blanguage=english');
    await page.goto('/contact.php?currency=1&language=english');
    expect(await page.locator('link[rel=canonical]').getAttribute('href')).toBe(`${BASE_URL}/contact.php`);
    expect(await meta(page, 'meta[property="og:url"]')).toBe(`${BASE_URL}/contact.php`);
  });

  test('TH-12 canonical keeps a WHMCS route (rp=/...) spelled the way the site links it', async ({ page }) => {
    test.fail(true, 'BUG: Hooks.php:3222 (resolveSeoContext) rebuilds the query with http_build_query, so rp=/knowledgebase/1/x.html becomes rp=%2Fknowledgebase%2F1%2Fx.html - a second spelling of every routed page');
    const route = `/index.php?rp=/knowledgebase/${id.kbArticleId}/x.html`;
    await page.goto(route);
    expect(await tpl(page)).toBe('knowledgebasearticle');
    expect(await page.locator('link[rel=canonical]').getAttribute('href')).toBe(`${BASE_URL}${route}`);
  });

  test('TH-13 og:type is article on an announcement and a KB article, website elsewhere', async ({ page }) => {
    const cases = [
      [`/index.php?rp=/announcements/${id.announcementId}/x.html`, 'viewannouncement', 'article'],
      [`/index.php?rp=/knowledgebase/${id.kbArticleId}/x.html`, 'knowledgebasearticle', 'article'],
      ['/announcements.php', 'announcements', 'website'],
      ['/knowledgebase.php', 'knowledgebase', 'website'],
      ['/', 'homepage', 'website'],
      ['/contact.php', 'contact', 'website'],
    ];
    for (const [url, want, type] of cases) {
      await page.goto(url);
      expect(await tpl(page), url).toBe(want);
      expect(await meta(page, 'meta[property="og:type"]'), `og:type on ${want}`).toBe(type);
    }
  });

  test('TH-16 html lang follows the language the visitor picks', async ({ page }) => {
    try {
      await page.goto('/?language=german');
      await expect(page.locator('html')).toHaveAttribute('lang', /^de/);
      await page.goto('/knowledgebase.php');   // the session keeps it
      await expect(page.locator('html')).toHaveAttribute('lang', /^de/);
      await page.goto('/?language=french');
      await expect(page.locator('html')).toHaveAttribute('lang', /^fr/);
    } finally {
      await page.goto('/?language=english');
    }
    await expect(page.locator('html')).toHaveAttribute('lang', /^en/);
  });
});

// ======================================================================= TH-C
test.describe('TH-C Layouts', () => {
  test('TH-23 ?preview=1 shows the state chip and switches layouts live; outside preview the params do nothing', async ({ page, context }) => {
    const errors = watchErrors(page);
    await loginClient(context.request, 'full');

    // Outside preview: one layout's chrome, no chip, the params ignored.
    const params = 'layout=top&align=left&sidebarside=right&navprofile=hide&svclayout=outside';
    await page.goto(`/clientarea.php?action=services&${params}`);
    expect(await bodyAttr(page, 'data-layout')).toBe('side');
    for (const a of ['data-align', 'data-sidebar-side', 'data-nav-profile']) {
      expect(await bodyAttr(page, a), `${a} needs ?preview=1`).toBeNull();
    }
    expect(await bodyAttr(page, 'data-svc-layout'), 'svclayout needs ?preview=1').not.toBe('outside');
    await expect(page.locator('.state-chip')).toHaveCount(0);
    await expect(page.locator('.ph-rail'), 'only the picked layout renders').toHaveCount(0);
    await expect(page.locator('.homepage-nav')).toHaveCount(0);

    // Preview: all three render, the chip appears, the URL picks the layout.
    await page.goto(`/clientarea.php?action=services&preview=1&${params}`);
    await expect(page.locator('.state-chip')).toBeVisible();
    await expect(page.locator('.ph-rail')).toHaveCount(1);
    await expect(page.locator('.sidebar')).toHaveCount(1);
    await expect(page.locator('.homepage-nav')).toHaveCount(1);
    expect(await bodyAttr(page, 'data-layout')).toBe('top');
    await expect(page.locator('.homepage-nav')).toBeVisible();
    expect(await bodyAttr(page, 'data-align')).toBe('left');
    expect(await bodyAttr(page, 'data-sidebar-side')).toBe('right');
    expect(await bodyAttr(page, 'data-nav-profile')).toBe('hide');
    // The server honours ?svclayout= in preview (header.tpl). core-layout.js
    // then re-applies its own svcLayout param (camelCase), so read the HTML.
    const served = await (await context.request.get(`/clientarea.php?action=services&preview=1&${params}`)).text();
    expect(served).toMatch(/<body[^>]*data-svc-layout="outside"/);
    const plain = await (await context.request.get(`/clientarea.php?action=services&${params}`)).text();
    expect(plain).not.toMatch(/<body[^>]*data-svc-layout="outside"/);

    // The chip switches live, without a reload.
    await page.locator('.state-chip [data-layout-set=rail]').click();
    expect(await bodyAttr(page, 'data-layout')).toBe('rail');
    await expect(page.locator('.ph-rail')).toBeVisible();
    await expect(page.locator('.homepage-nav')).toBeHidden();
    await expect(page.locator('.state-chip [data-layout-set=rail]')).toHaveClass(/active/);
    await page.locator('.state-chip [data-layout-set=side]').click();
    await expect(page.locator('.sidebar')).toBeVisible();

    // An unknown token is refused (allow-list), the server's own layout stays.
    await page.goto('/clientarea.php?preview=1&layout=no-such-layout');
    await page.evaluate(() => localStorage.removeItem('hn.layout'));
    await page.goto('/clientarea.php?preview=1&layout=no-such-layout');
    expect(await bodyAttr(page, 'data-layout')).toBe('side');
    expect(errors).toEqual([]);
  });
});

// ======================================================================= TH-D
test.describe('TH-D Navigation chrome', () => {
  test('TH-27 sidebar: company-name brand, KB search box, collapsible groups, account block or sign-in', async ({ page, context }) => {
    const errors = watchErrors(page);
    await page.goto('/knowledgebase.php');
    const sb = page.locator('aside.sidebar');
    // No logo uploaded on the local install: the company name stands in.
    await expect(sb.locator('.sidebar-brand')).toHaveText('Company Name');
    await expect(sb.locator('.sidebar-footer a[href$="login.php"]'), 'guests get Login').toBeVisible();
    await expect(sb.locator('.sidebar-footer a[href$="register.php"]'), 'and Create account').toBeVisible();
    await expect(sb.locator('.sidebar-search-input'), 'a KB search box').toBeVisible();

    await loginClient(context.request, 'full');
    await page.goto('/clientarea.php');
    await expect(sb.locator('.sidebar-user-name')).toHaveText('Mara Okonkwo');
    await expect(sb.locator('.sidebar-user-email')).toHaveText(creds.personas.full.email);
    await expect(sb.locator('.sidebar-footer a[href$="login.php"]')).toHaveCount(0);

    // A group opens and closes on its toggle.
    const group = sb.locator('.sidebar-group').filter({ hasText: 'Resources' });
    const link = group.locator('.sidebar-group-items a', { hasText: 'Knowledgebase' });
    await expect(group).not.toHaveClass(/\bopen\b/);
    await group.locator('.sidebar-group-toggle').click();
    await expect(group).toHaveClass(/\bopen\b/);
    await expect(link).toBeVisible();
    await group.locator('.sidebar-group-toggle').click();
    await expect(group).not.toHaveClass(/\bopen\b/);
    await expect(link).toBeHidden();
    expect(errors).toEqual([]);
  });

  test('TH-27 sidebar KB search box finds articles', async ({ page }) => {
    test.fail(true, 'BUG: sidebar.tpl:144 sends a GET to knowledgebase.php?search=..., which WHMCS 9 301s to /knowledgebase and drops the query; WHMCS searches by POST to routePath(knowledgebase-search) (stock twenty-one header.tpl:90)');
    await page.goto('/contact.php');
    const box = page.locator('aside.sidebar .sidebar-search-input');
    await box.fill('nameservers');
    await box.press('Enter');
    await page.waitForLoadState('load');
    await expect(page.locator('.content-area'), 'the matching article is listed').toContainText('How do I point my domain at my hosting?', { timeout: 5000 });
    await expect(page.locator('.content-area')).not.toContainText('Uploading your website with SFTP');
  });

  test('TH-28 sidebar badges show the client\'s real counts', async ({ page, context }) => {
    await loginClient(context.request, 'full');
    await page.goto('/clientarea.php');
    const badges = await page.locator('aside.sidebar .sidebar-item-badge').count();
    // The badge source is a per-item Menu Manager field (config.badge_source);
    // none of the seeded menus sets one, and this spec may not edit menus.
    test.skip(badges === 0, 'no item in the active client menu has a badge source (hadrian_menu_items.config_json.badge_source); needs a menu edit');
    const counts = { services: '4', domains: '1', invoices: '2' };
    for (const b of await page.locator('aside.sidebar .sidebar-item:has(.sidebar-item-badge)').all()) {
      const text = await b.innerText();
      const key = Object.keys(counts).find(k => text.toLowerCase().includes(k));
      if (key) await expect(b.locator('.sidebar-item-badge')).toHaveText(counts[key]);
    }
  });

  test('TH-29 sidebar group open state is remembered across pages', async ({ page, context }) => {
    test.fail(true, 'BUG: sidebar.tpl:201-221 (inline script) binds the group toggle first and sets data-mt-bound, so core-layout.js:638 (initSidebarGroups) skips the handler that writes localStorage hn.sidebarGroups - the open state is restored but never saved');
    await loginClient(context.request, 'full');
    await page.goto('/clientarea.php');
    const group = page.locator('aside.sidebar .sidebar-group').filter({ hasText: 'Resources' });
    await group.locator('.sidebar-group-toggle').click();
    await expect(group).toHaveClass(/\bopen\b/);
    const saved = await page.evaluate(() => JSON.parse(localStorage.getItem('hn.sidebarGroups') || '[]'));
    expect(saved, 'the open group is saved').toContain(await group.getAttribute('data-group'));
    await page.goto('/clientarea.php?action=invoices');
    await expect(page.locator('aside.sidebar .sidebar-group').filter({ hasText: 'Resources' }), 'and reopened on the next page').toHaveClass(/\bopen\b/);
  });

  test('TH-30 top nav: mega and classic dropdowns, sign-in, locale switcher, no icons by default', async ({ page }) => {
    const errors = watchErrors(page);
    await page.goto('/?preview=1&layout=top&screenshot=1');   // screenshot=1 hides the preview chip, which covers the bar at 1280px
    const nav = page.locator('nav.homepage-nav');
    await expect(nav).toBeVisible();

    // Panels fade with opacity + pointer-events (core-theme.css .nav-dropdown-menu).
    const shown = loc => loc.evaluate(e => getComputedStyle(e).opacity === '1' && getComputedStyle(e).pointerEvents !== 'none');
    const mega = nav.locator('.nav-dropdown-wrap--mega').filter({ hasText: 'Hosting' }).first();
    expect(await shown(mega.locator('.nav-dropdown-menu--mega')), 'closed until hovered').toBe(false);
    await mega.locator('.nav-dropdown-toggle').hover();
    await expect.poll(() => shown(mega.locator('.nav-dropdown-menu--mega')), { message: 'mega panel opens on hover' }).toBe(true);
    await expect(mega.locator('.nav-mega-col h4').first(), 'headers become columns').toHaveText('Web Hosting');
    await expect(mega.locator('.nav-mega-item', { hasText: 'Shared Hosting' })).toHaveAttribute('href', /cart\.php\?gid=shared/);

    const classic = nav.locator('.nav-dropdown-wrap:not(.nav-dropdown-wrap--mega)').filter({ hasText: 'Domains' }).first();
    await classic.locator('.nav-dropdown-toggle').hover();
    await expect.poll(() => shown(classic.locator('.nav-dropdown-menu'))).toBe(true);
    expect(await shown(mega.locator('.nav-dropdown-menu--mega')), 'moving away closes the other').toBe(false);
    await expect(classic.locator('.nav-dropdown-divider'), 'a divider item').toHaveCount(1);
    await classic.locator('.nav-dropdown-item', { hasText: 'Domain Pricing' }).click();
    await page.waitForURL(/domain\/pricing/);
    expect(await tpl(page)).toBe('domain-pricing');

    await page.goto('/?preview=1&layout=top&screenshot=1');   // screenshot=1 hides the preview chip, which covers the bar at 1280px
    await expect(nav.locator('.nav-signin'), 'guests get a sign-in link').toHaveAttribute('href', /login\.php$/);
    await expect(nav.locator('.nav-item-icon'), 'topnav_show_icons is off: no icons').toHaveCount(0);
    await nav.locator('.nav-locale .locale-btn').click();
    await expect(page.locator('#localeModal')).toHaveClass(/\bopen\b/);
    expect(errors).toEqual([]);
  });

  test('TH-31 icon rail: 3 guest / 5 client flyouts open on hover, click and focus, close after the bridge delay', async ({ page, context }) => {
    const errors = watchErrors(page);
    await page.goto('/?preview=1&layout=rail');
    // A <nav> since the accessibility work (it is the main menu), not an <aside>.
    const rail = page.locator('nav.ph-rail');
    await expect(rail).toBeVisible();
    await expect(rail.locator('.ph-rail-item[data-rail]:visible'), 'three flyouts for guests').toHaveCount(3);

    await loginClient(context.request, 'full');
    await page.goto('/clientarea.php?preview=1&layout=rail');
    await expect(rail.locator('.ph-rail-item[data-rail]:visible'), 'five flyouts for clients').toHaveCount(5);
    const panel = page.locator('.ph-rail-panel');

    await rail.locator('[data-rail=billing]').hover();
    await expect(page.locator('body')).toHaveClass(/rail-panel-open/);
    await expect(panel).toBeVisible();
    await expect(panel.locator('.ph-rail-panel-group[data-panel=billing]')).toHaveClass(/active/);
    await expect(panel.locator('.ph-rail-panel-group.active a[href*="action=invoices"]')).toBeVisible();
    // Crossing from the button to the panel keeps it open (180 ms bridge).
    await panel.locator('.ph-rail-panel-group.active a').first().hover();
    await page.waitForTimeout(400);
    await expect(page.locator('body')).toHaveClass(/rail-panel-open/);
    // Leaving both closes it.
    await page.mouse.move(900, 500);
    await expect(page.locator('body')).not.toHaveClass(/rail-panel-open/, { timeout: 2000 });

    await rail.locator('[data-rail=support]').click();
    await expect(panel.locator('.ph-rail-panel-group[data-panel=support]')).toHaveClass(/active/);
    await page.mouse.move(900, 500);
    await expect(page.locator('body')).not.toHaveClass(/rail-panel-open/, { timeout: 2000 });
    await rail.locator('[data-rail=domains-in]').focus();
    await expect(panel.locator('.ph-rail-panel-group[data-panel=domains-in]'), 'keyboard focus opens it too').toHaveClass(/active/);
    expect(errors).toEqual([]);
  });

  test('TH-32 mobile drawer: hamburger opens it; Esc, backdrop, a link and resizing close it', async ({ page, context }) => {
    const errors = watchErrors(page);
    await loginClient(context.request, 'full');
    await page.setViewportSize({ width: 390, height: 800 });
    await page.goto('/clientarea.php');
    const body = page.locator('body');
    const drawer = page.locator('aside.sidebar');
    const burger = page.locator('.ph-mobile-toggle');
    const inView = () => drawer.evaluate(e => { const r = e.getBoundingClientRect(); return r.right > 0 && r.left < innerWidth; });
    await expect(burger).toBeVisible();
    expect(await inView(), 'the drawer starts off-canvas').toBe(false);

    await burger.click();
    await expect(body).toHaveClass(/\bnav-open\b/);
    await expect(burger).toHaveAttribute('aria-expanded', 'true');
    await expect.poll(inView, { message: 'the drawer slides in' }).toBe(true);
    await page.keyboard.press('Escape');
    await expect(body).not.toHaveClass(/\bnav-open\b/);
    await expect(burger).toHaveAttribute('aria-expanded', 'false');

    await burger.click();
    await expect(body).toHaveClass(/\bnav-open\b/);
    await page.locator('.ph-nav-backdrop').click({ position: { x: 370, y: 400 } });
    await expect(body, 'a backdrop tap closes it').not.toHaveClass(/\bnav-open\b/);

    await burger.click();
    await drawer.locator('.sidebar-close').click();
    await expect(body, 'the drawer\'s own close button').not.toHaveClass(/\bnav-open\b/);

    await burger.click();
    await page.setViewportSize({ width: 1280, height: 860 });
    await expect(body, 'resizing back to desktop drops the drawer').not.toHaveClass(/\bnav-open\b/);

    await page.setViewportSize({ width: 390, height: 800 });
    await burger.click();
    await drawer.locator('.sidebar-item', { hasText: 'Invoices' }).click();
    await page.waitForURL(/action=invoices/);
    await expect(body, 'following a link leaves it closed').not.toHaveClass(/\bnav-open\b/);

    // The top layout borrows the same drawer from its own hamburger.
    await page.goto('/clientarea.php?preview=1&layout=top');
    await page.locator('.homepage-nav .nav-mobile-toggle').click();
    await expect(body).toHaveClass(/\bnav-open\b/);
    await expect.poll(inView).toBe(true);
    expect(errors).toEqual([]);
  });

  test('TH-33 profile dropdown: click, Enter and Space open it; outside click and Esc close it', async ({ page, context }) => {
    const errors = watchErrors(page);
    await loginClient(context.request, 'full');
    await page.goto('/clientarea.php');
    const trigger = page.locator('.sidebar-user');
    const menu = page.locator('#profileDropdownSidebar');
    await expect(menu).not.toHaveClass(/\bopen\b/);

    await trigger.click();
    await expect(menu).toHaveClass(/\bopen\b/);
    await expect(menu.locator('a[href*="action=details"]')).toBeVisible();
    await expect(menu.locator('a[href*="/user/security"]')).toBeVisible();
    await expect(menu.locator('.toggle-switch'), 'the dark-mode switch (switcher mode)').toBeVisible();
    await expect(menu.locator('a.danger[href$="logout.php"]'), 'sign out').toBeVisible();
    await page.locator('.content-area h1').first().click();
    await expect(menu, 'outside click closes it').not.toHaveClass(/\bopen\b/);

    await trigger.focus();
    await page.keyboard.press('Enter');
    await expect(menu, 'Enter opens it (role=button div)').toHaveClass(/\bopen\b/);
    await page.keyboard.press('Escape');
    await expect(menu, 'Esc closes it').not.toHaveClass(/\bopen\b/);
    await trigger.focus();
    await page.keyboard.press(' ');
    await expect(menu, 'Space opens it').toHaveClass(/\bopen\b/);
    expect(await page.evaluate(() => scrollY), 'Space did not scroll the page').toBe(0);

    // Opening the topbar one closes the sidebar one (one menu at a time).
    await page.locator('#sideUserWrap .topbar-avatar').click();
    await expect(page.locator('#profileDropdownSide')).toHaveClass(/\bopen\b/);
    await expect(menu).not.toHaveClass(/\bopen\b/);
    await page.locator('#profileDropdownSide a[href*="/user/profile"]').click();
    await page.waitForURL(/user\/profile/);
    expect(await tpl(page)).toBe('user-profile');
    expect(errors).toEqual([]);
  });

  test('TH-34 notifications: the dot and the alerts list for a client with alerts, the empty message without', async ({ page, context, browser }) => {
    const errors = watchErrors(page);
    await loginClient(context.request, 'full');
    await page.goto('/clientarea.php');
    const wrap = page.locator('#sideNotifyWrap');
    const dd = page.locator('#notificationDropdownSide');
    await expect(wrap.locator('.topbar-notification-dot'), 'unpaid invoices raise the dot').toHaveCount(1);
    await wrap.locator('button').click();
    await expect(dd).toHaveClass(/\bopen\b/);
    const items = dd.locator('a.notification-item');
    await expect(items.first()).toBeVisible();
    await expect(dd).toContainText(/overdue invoice/i);
    // Severity maps to a colour: WHMCS's warning alert is orange.
    await expect(items.filter({ hasText: /overdue/i }).locator('.notification-dot-indicator')).toHaveClass(/orange/);
    await page.locator('.content-area h1').first().click();
    await expect(dd).not.toHaveClass(/\bopen\b/);
    await wrap.locator('button').click();
    await items.filter({ hasText: /overdue/i }).click();
    await page.waitForURL(/action=masspay/);
    expect(await tpl(page)).toBe('masspay');
    expect(errors).toEqual([]);

    const ctx2 = await browser.newContext();
    try {
      await loginClient(ctx2.request, 'empty');
      const p2 = await ctx2.newPage();
      await p2.goto('/clientarea.php');
      await expect(p2.locator('#sideNotifyWrap .topbar-notification-dot'), 'no alerts, no dot').toHaveCount(0);
      await p2.locator('#sideNotifyWrap button').click();
      await expect(p2.locator('#notificationDropdownSide')).toHaveClass(/\bopen\b/);
      await expect(p2.locator('#notificationDropdownSide .notification-item')).toHaveText(/no notifications/i);
    } finally { await ctx2.close(); }
  });

  test('TH-35 cart badge counts what is in the session cart, on every page', async ({ page, context }) => {
    await loginClient(context.request, 'full');
    await context.request.get('/cart.php?a=empty');
    await page.goto('/clientarea.php');
    await expect(page.locator('.topbar-cart-badge'), 'empty cart: no badge').toHaveCount(0);
    try {
      // Add a domain registration by HTTP, as the cart's own AJAX call does.
      const name = `hadrian-badge-${Date.now().toString(36)}.com`;
      const token = await csrf(context.request);
      const r = await context.request.post('/cart.php', { form: { a: 'addToCart', domain: name, token, whois: '0', sideorder: '0' } });
      expect(r.ok()).toBe(true);
      await page.goto('/clientarea.php');
      await expect(page.locator('.topbar-cart-badge:visible'), 'the badge counts the item on a non-cart page').toHaveText('1');
      await expect(page.locator('.topbar-cart-badge:visible')).toHaveAttribute('aria-label', /1/);
      await page.goto('/knowledgebase.php');
      await expect(page.locator('.topbar-cart-badge:visible')).toHaveText('1');
    } finally {
      await context.request.get('/cart.php?a=empty');
    }
    await page.goto('/clientarea.php');
    await expect(page.locator('.topbar-cart-badge')).toHaveCount(0);
  });

  test('TH-36 breadcrumb: "< Home" on the top layout, crumbs in the topbar on side and rail', async ({ page, context }) => {
    await loginClient(context.request, 'full');
    await page.goto('/clientarea.php?action=invoices&preview=1&layout=top');
    const back = page.locator('.ph-breadcrumb-back');
    await expect(back).toBeVisible();
    await expect(page.locator('.ph-side-crumbs')).toBeHidden();
    await back.locator('a.ph-back-link').click();
    await page.waitForURL(u => new URL(u).pathname === '/');
    expect(await tpl(page)).toBe('homepage');
    await page.goto('/?preview=1&layout=top&screenshot=1');   // screenshot=1 hides the preview chip, which covers the bar at 1280px
    await expect(page.locator('.ph-breadcrumb-back'), 'no "back to Home" on Home').toHaveCount(0);

    for (const layout of ['side', 'rail']) {
      await page.goto(`/contact.php?preview=1&layout=${layout}`);
      const crumbs = page.locator('.ph-side-crumbs');
      await expect(crumbs, layout).toBeVisible();
      await expect(crumbs.locator('.current')).toHaveText(/Contact Us/);
      await expect(page.locator('.ph-breadcrumb-back')).toBeHidden();
    }
    await page.goto('/clientarea.php?action=invoices');
    await page.locator('.ph-side-crumbs a').click();
    await page.waitForURL(u => new URL(u).pathname === '/');
  });

  test('TH-36 topbar crumb names the client-area page (My Invoices, My Domains)', async ({ page, context }) => {
    test.fail(true, 'BUG: core-layout.js:819 (applyPageTitle) overwrites the crumb label header.tpl:230-259 renders ("My Invoices") with body[data-page-title], which is WHMCS $pagetitle "Client Area" on every clientarea.php page');
    await loginClient(context.request, 'full');
    for (const [url, label] of [['/clientarea.php?action=invoices', 'My Invoices'], ['/clientarea.php?action=domains', 'My Domains']]) {
      await page.goto(url);
      await expect(page.locator('.ph-side-crumbs .current')).toHaveText(label, { timeout: 3000 });
    }
  });

  test('TH-37 active nav: the rail marks the current section', async ({ page, context }) => {
    await loginClient(context.request, 'full');
    for (const [url, nav] of [['/clientarea.php', 'dashboard'], ['/clientarea.php?action=services', 'services'], ['/clientarea.php?action=domains', 'domains']]) {
      await page.goto(`${url}${url.includes('?') ? '&' : '?'}preview=1&layout=rail`);
      await expect(page.locator(`.ph-rail-item[data-nav="${nav}"]`), nav).toHaveClass(/\bactive\b/);
      await expect(page.locator('.ph-rail-item.active[data-nav]'), 'only one').toHaveCount(1);
    }
  });

  test('TH-37 active nav: the sidebar marks the current page', async ({ page, context }) => {
    test.fail(true, 'BUG: core-layout.js:802 (applyActiveNav) matches [data-nav="<data-active-nav>"], but sidebar.tpl:93 prints data-nav="mt-<menu item id>" (TreeRenderer.php:218), so on the sidebar and top layouts no item is ever highlighted');
    await loginClient(context.request, 'full');
    await page.goto('/clientarea.php?action=invoices');
    expect(await bodyAttr(page, 'data-active-nav')).toBe('invoices');
    await expect(page.locator('aside.sidebar .sidebar-item[href*="action=invoices"]')).toHaveClass(/\bactive\b/);
  });
});

// ======================================================================= TH-E
test.describe('TH-E Preview parameters', () => {
  test('TH-43 preview-only URL parameters change nothing without ?preview=1', async ({ page, context }) => {
    test.fail(true, 'BUG: header.tpl:131-227 reads ?subnav ?subnavside ?data ?tiles ?form ?plan ?product ?palette with no $mt_preview gate (unlike ?layout and ?align at :70 and :99), so any link can recolour the site (html[data-palette]) or hide a page\'s side column (body[data-subnav=off])');
    await loginClient(context.request, 'full');
    await page.goto('/clientarea.php?action=details');
    const accent = () => page.evaluate(() => getComputedStyle(document.documentElement).getPropertyValue('--color-accent').trim());
    const before = await accent();
    const aside = page.locator('.acct-split > aside');
    await expect(aside).toBeVisible();

    await page.goto('/clientarea.php?action=details&palette=rose&subnav=off&subnavside=left&tiles=b&form=a&plan=c&product=a');
    expect(await page.evaluate(() => document.documentElement.getAttribute('data-palette')), '?palette').toBeNull();
    expect(await accent(), 'the accent colour is untouched').toBe(before);
    await expect(aside, '?subnav=off must not hide the side column').toBeVisible();
    for (const a of ['data-subnav-side', 'data-tiles', 'data-form', 'data-plan', 'data-product']) {
      expect(await bodyAttr(page, a), a).toBeNull();
    }
  });

  test('TH-44 demo rows appear only with ?preview=1 and only when there is no real data', async ({ page, context, browser }) => {
    await loginClient(context.request, 'empty');
    for (const [url, demo] of [['/clientarea.php?action=emails', 'Welcome to Hostnodes'], ['/index.php?rp=/clientarea/ssl-certificates/manage', 'hendersondesign.com']]) {
      await page.goto(url);
      expect(await bodyAttr(page, 'data-data'), `${url}: the empty persona has none`).toBe('empty');
      await expect(page.locator('.content-area')).not.toContainText(demo);
      await page.goto(`${url}${url.includes('?') ? '&' : '?'}preview=1`);
      // core-layout.js drops the attribute for "full" (only "empty" is a CSS state).
      expect(await bodyAttr(page, 'data-data'), `${url}?preview=1 fills the page`).not.toBe('empty');
      await expect(page.locator('.content-area')).toContainText(demo);
    }
    // Real data always wins over the demo rows.
    const ctx2 = await browser.newContext();
    try {
      await loginClient(ctx2.request, 'full');
      const p2 = await ctx2.newPage();
      await p2.goto('/clientarea.php?action=emails&preview=1');
      await expect(p2.locator('#emTable tbody tr[data-href*="viewemail.php"]').first(), 'the client\'s own emails').toBeVisible();
      await expect(p2.locator('.content-area')).not.toContainText('Domain hendersondesign.com renewal notice');
    } finally { await ctx2.close(); }
  });
});

// ======================================================================= TH-F
test.describe('TH-F Global overlays', () => {
  test('TH-50 a valueless [data-dismiss] removes its notice', async ({ page, context }) => {
    const errors = watchErrors(page);
    await loginClient(context.request, 'full');
    await page.goto('/clientarea.php');
    const notice = page.locator('.notice').filter({ hasText: /overdue invoice/i });
    await expect(notice).toBeVisible();
    await notice.locator('[data-dismiss]').click();
    await expect(notice, 'the X removes the notice').toHaveCount(0);
    expect(page.url(), 'and does not navigate').toMatch(/clientarea\.php$/);
    expect(errors).toEqual([]);
  });

  test('TH-51 the eye button shows and hides the password', async ({ page }) => {
    await page.goto('/login');
    const pw = page.locator('#loginPassword');
    await pw.fill('not-a-real-password');
    await expect(pw).toHaveAttribute('type', 'password');
    await page.locator('.auth-form .password-toggle').click();
    await expect(pw, 'shown').toHaveAttribute('type', 'text');
    await expect(pw).toHaveValue('not-a-real-password');
    await page.locator('.auth-form .password-toggle').click();
    await expect(pw, 'hidden again').toHaveAttribute('type', 'password');
  });

  test('TH-51 the dark logo swaps in with the theme', async ({ page }) => {
    await page.goto('/');
    const n = await page.locator('img[data-logo-dark]').count();
    test.skip(n === 0, 'no separate dark logo is uploaded on this install (Branding); uploading one is a settings change');
    const img = page.locator('img[data-logo-dark]').first();
    const dark = await img.getAttribute('data-logo-dark');
    await page.evaluate(() => toggleDarkMode());
    await expect(img).toHaveAttribute('src', dark);
  });
});

// ======================================================================= TH-G
test.describe('TH-G Dark mode (this install: switcher, default light)', () => {
  test('TH-53 the mt_theme cookie is rendered by the server, so there is no flash', async ({ page, context }) => {
    await context.addCookies([{ name: 'mt_theme', value: 'dark', url: BASE_URL }]);
    const html = await (await context.request.get('/')).text();
    expect(html, 'server-rendered dark').toMatch(/<html[^>]*data-theme="dark"[^>]*data-dark-mode="switcher"/);
    await page.goto('/knowledgebase.php');
    await expect(page.locator('html')).toHaveAttribute('data-theme', 'dark');
    await context.addCookies([{ name: 'mt_theme', value: 'light', url: BASE_URL }]);
    await page.goto('/knowledgebase.php');
    await expect(page.locator('html')).toHaveAttribute('data-theme', 'light');
    // A value outside the allow-list falls back to the default.
    await context.addCookies([{ name: 'mt_theme', value: 'purple', url: BASE_URL }]);
    expect(await (await context.request.get('/')).text()).toMatch(/<html[^>]*data-theme="light"/);
  });

  test('TH-53 a choice saved in the old apple-theme localStorage key is migrated once to the cookie', async ({ page, context }) => {
    await page.goto('/');
    expect((await context.cookies()).find(c => c.name === 'mt_theme')).toBeUndefined();
    await page.evaluate(() => localStorage.setItem('apple-theme', 'dark'));
    await page.reload();
    await expect(page.locator('html'), 'the legacy choice is applied').toHaveAttribute('data-theme', 'dark');
    expect((await context.cookies()).find(c => c.name === 'mt_theme')?.value, 'and written to the cookie').toBe('dark');
    expect(await (await context.request.get('/')).text(), 'so the next page is dark from the server').toMatch(/<html[^>]*data-theme="dark"/);
  });

  test('TH-55 signed-out visitors get a moon button that flips and remembers the theme', async ({ page, context }) => {
    const errors = watchErrors(page);
    await context.addCookies([{ name: 'mt_theme', value: 'light', url: BASE_URL }]);
    await page.goto('/contact.php');
    const moon = page.locator('.ph-side-topbar button[aria-label="Toggle theme"]');
    await expect(moon, 'inner topbar (side layout)').toBeVisible();
    await moon.click();
    await expect(page.locator('html')).toHaveAttribute('data-theme', 'dark');
    expect(page.url(), 'the # link does not navigate').toMatch(/contact.php$/);
    expect((await context.cookies()).find(c => c.name === 'mt_theme')?.value).toBe('dark');
    await page.reload();
    await expect(page.locator('html')).toHaveAttribute('data-theme', 'dark');

    await page.goto('/contact.php?preview=1&layout=top');
    const topMoon = page.locator('.homepage-nav .topbar-btn.only-out[aria-label="Toggle theme"]');
    await expect(topMoon, 'top nav').toBeVisible();
    await topMoon.click();
    await expect(page.locator('html')).toHaveAttribute('data-theme', 'light');
    expect((await context.cookies()).find(c => c.name === 'mt_theme')?.value).toBe('light');
    expect(errors).toEqual([]);
  });

  test('TH-56 text stays readable (3:1) in dark mode on client pages', async ({ page, context }) => {
    await loginClient(context.request, 'full');
    await context.addCookies([{ name: 'mt_theme', value: 'dark', url: BASE_URL }]);
    const problems = [];
    for (const url of ['/clientarea.php', '/clientarea.php?action=invoices', `/viewinvoice.php?id=${id.invoiceId}`,
      `/viewticket.php?tid=${id.ticketTid}&c=${id.ticketC}`, '/knowledgebase.php', '/index.php?rp=/user/profile', '/submitticket.php']) {
      await page.goto(url);
      expect(await page.getAttribute('html', 'data-theme'), url).toBe('dark');
      const m = await page.evaluate(measure);
      expect(m.contrast.length, `${url}: something was measured`).toBeGreaterThan(0);
      for (const c of m.contrast) if (c.ratio < c.min) problems.push(`${url}: ${c.ratio}:1 in ${c.sel} "${c.text}"`);
    }
    expect(problems).toEqual([]);
  });
});

// ======================================================================= TH-I
test.describe('TH-I Menus (what the current menus render)', () => {
  test('TH-62 guest menu: link, dropdown, mega, header, divider, login and language items each render and work', async ({ page }) => {
    const errors = watchErrors(page);
    await page.goto('/knowledgebase.php');
    const sb = page.locator('aside.sidebar .sidebar-nav');
    await expect(sb.locator('a.sidebar-item[href="/"]', { hasText: 'Home' }), 'custom link').toBeVisible();
    const hosting = sb.locator('.sidebar-group').filter({ hasText: 'Hosting' }).first();
    await hosting.locator('.sidebar-group-toggle').click();
    await expect(hosting.locator('.sidebar-group-section').first(), 'header item').toHaveText('Web Hosting');
    const support = sb.locator('.sidebar-group').filter({ hasText: 'Support' }).first();
    await expect(support.locator('hr.sidebar-group-divider'), 'divider item').toHaveCount(1);
    await expect(sb.locator('a.sidebar-item-login'), 'login button item').toHaveAttribute('href', /login/);
    await sb.locator('a.sidebar-item-switcher[data-switcher=language]').click();
    await expect(page.locator('#localeModal'), 'language item opens the chooser').toHaveClass(/\bopen\b/);
    expect(page.url(), 'without jumping to #').not.toMatch(/#$/);
    await page.keyboard.press('Escape');
    await expect(page.locator('#localeModal')).not.toHaveClass(/\bopen\b/);

    // Top layout: the same items as mega and classic dropdowns.
    await page.goto('/contact.php?preview=1&layout=top');
    const nav = page.locator('nav.homepage-nav');
    await expect(nav.locator('.nav-dropdown-wrap--mega'), 'dropdown_style mega').toHaveCount(2);
    await expect(nav.locator('.nav-dropdown-wrap:not(.nav-dropdown-wrap--mega)'), 'classic dropdowns').toHaveCount(2);
    await expect(nav.locator('.nav-dropdown-section, .nav-mega-col h4').first()).toBeAttached();

    // Footer and footer-secondary menus.
    await expect(page.locator('footer .hp-footer-col h4').first(), 'Footer menu columns').toBeVisible();
    await expect(page.locator('footer .hp-footer-col h4', { hasText: 'Support' })).toHaveCount(1);
    await expect(page.locator('footer .hp-footer-bottom-links a', { hasText: 'Privacy Policy' }), 'Footer Secondary menu').toBeVisible();
    expect(errors).toEqual([]);
  });

  test('TH-62 client menu: whmcs_page links, dropdown groups and the account dropdown', async ({ page, context }) => {
    await loginClient(context.request, 'full');
    await page.goto('/clientarea.php');
    const sb = page.locator('aside.sidebar .sidebar-nav');
    await expect(sb.locator('a.sidebar-item[href="clientarea.php?action=invoices"]'), 'whmcs_page item').toBeVisible();
    await expect(sb.locator('a.sidebar-item-login'), 'no login item for clients').toHaveCount(0);
    const account = sb.locator('.sidebar-group').filter({ hasText: 'Account' });
    await account.locator('.sidebar-group-toggle').click();
    await expect(account.locator('a', { hasText: 'My Details' }), 'account_dropdown children').toBeVisible();
    await account.locator('a', { hasText: 'My Details' }).click();
    await page.waitForURL(/action=details/);
    expect(await tpl(page)).toBe('clientareadetails');
    // On the top layout a signed-in client gets no Login item either.
    await page.goto('/clientarea.php?preview=1&layout=top');
    await expect(page.locator('nav.homepage-nav .nav-cta')).toHaveCount(0);
  });
});

// ======================================================================= TH-J
test.describe('TH-J Languages', () => {
  test('TH-70 locale modal: Apply reloads with ?language=, no currency grid on a one-currency install', async ({ page }) => {
    const errors = watchErrors(page);
    try {
      await page.goto('/');
      const modal = page.locator('#localeModal');
      await page.locator('[data-locale-open]:visible').first().click();
      await expect(modal).toHaveClass(/\bopen\b/);
      await expect(modal.locator('[data-lang].active'), 'the current language is marked').toHaveAttribute('data-lang', 'english');
      await expect(modal.locator('[data-lang=german]'), 'native names').toHaveText('Deutsch');
      await expect(modal.locator('[data-currency]'), 'one currency: no currency grid').toHaveCount(0);

      // Apply with no change just closes.
      await page.locator('#localeApply').click();
      await expect(modal).not.toHaveClass(/\bopen\b/);
      expect(page.url()).not.toMatch(/language=/);

      await page.locator('[data-locale-open]:visible').first().click();
      await modal.locator('[data-lang=german]').click();
      await expect(modal.locator('[data-lang=german]')).toHaveClass(/active/);
      await Promise.all([page.waitForURL(/language=german/), page.locator('#localeApply').click()]);
      await expect(page.locator('html')).toHaveAttribute('lang', /^de/);
      await expect(page.locator('.locale-btn').first(), 'the button names the new language').toContainText('Deutsch');
    } finally {
      await page.goto('/?language=english');
    }
    expect(errors).toEqual([]);
  });

  test('TH-71 a WHMCS error page in a right-to-left language loads all its stylesheets', async ({ page }) => {
    test.fail(true, 'BUG: includes/common/head.tpl:6-8 links assets/css/theme-rtl.css for theme.json rtlLanguages, and the file does not exist (404). Its first line links theme.css, which hadrian/.gitignore:2 ignores, so a release 404s that one too');
    const missing = [];
    page.on('response', r => { if (r.request().resourceType() === 'stylesheet' && r.status() >= 400) missing.push(`${r.status()} ${r.url()}`); });
    try {
      await page.goto('/?language=arabic');
      await page.goto('/index.php?rp=/no-such-page-for-rtl');
      expect(await tpl(page)).toBe('error/page-not-found');
      await expect(page.locator('html')).toHaveAttribute('lang', /^ar/);
      expect(missing).toEqual([]);
    } finally {
      await page.goto('/?language=english');
    }
  });
});

// ======================================================================= TH-K
test.describe('TH-K Dashboard', () => {
  test('TH-73 dashboard: tiles count the client\'s records and lead to them; services panel', async ({ page, context }) => {
    const errors = watchErrors(page);
    await loginClient(context.request, 'full');
    await page.goto('/clientarea.php');
    const tiles = page.locator('.tile-variant[data-variant=a] .tile');
    const value = label => tiles.filter({ hasText: label }).locator('.tile-value');
    // The full persona: 4 active services, 1 domain, 2 unpaid invoices (#42, #49), 1 open ticket.
    await expect(value('Services')).toHaveText('4');
    await expect(value('Domains')).toHaveText('1');
    await expect(value('Unpaid Invoices')).toHaveText('2');
    await expect(value('Support')).toHaveText('1');
    await expect(page.locator('.tile-variant[data-variant=b]'), 'only the chosen tile variant shows').toBeHidden();

    const svc = page.locator('a.mt-svc-item');
    await expect(svc).toHaveCount(4);
    await svc.filter({ hasText: 'test.com' }).click();
    await page.waitForURL(/action=productdetails&id=\d+/);
    expect(await tpl(page)).toBe('clientareaproductdetails');

    await page.goto('/clientarea.php');
    await value('Unpaid Invoices').click();
    await page.waitForURL(/action=invoices/);
    expect(await tpl(page)).toBe('clientareainvoices');
    expect(errors).toEqual([]);
  });

  test('TH-73 dashboard register-domain box hands the typed name to the order form', async ({ page, context }) => {
    test.fail(true, 'BUG: clientareahome/default/default.tpl:497-501 posts the name as "search" (formaction cart.php?a=add&domain=register); the order form only reads "query", so the cart opens with an empty search and the name is lost (same for Transfer)');
    await loginClient(context.request, 'full');
    await page.goto('/clientarea.php');
    const name = `hadrian-dash-${Date.now().toString(36)}`;
    await page.locator('#rdInput').fill(name);
    await page.locator('#rdForm button[name=register]').click();
    await page.waitForURL(/domain=register/);
    expect(await tpl(page)).toBe('domainregister');
    await expect(page.locator('.content-area'), 'the cart searches for the name typed on the dashboard').toContainText(name, { timeout: 10_000 });
  });
});

// ======================================================================= TH-L
test.describe('TH-L Shared components', () => {
  test('TH-78 the page picks its full or empty variant from real counts', async ({ page, context, browser }) => {
    await loginClient(context.request, 'full');
    for (const url of ['/clientarea.php', '/clientarea.php?action=services', '/clientarea.php?action=invoices']) {
      await page.goto(url);
      expect(await page.content(), `${url}: the inline script reports real data`).toMatch(/setAttribute\(\s*'data-data',\s*'full'\s*\)/);
      expect(await bodyAttr(page, 'data-data'), url).not.toBe('empty');
      for (const empty of await page.locator('.content-area .when-empty').all()) await expect(empty, `${url}: no empty state`).toBeHidden();
      if (await page.locator('.content-area .when-full').count()) await expect(page.locator('.content-area .when-full').first()).toBeVisible();
    }
    const ctx2 = await browser.newContext();
    try {
      await loginClient(ctx2.request, 'empty');
      const p2 = await ctx2.newPage();
      // (Not the dashboard: it counts announcements as content, so it is never empty.)
      for (const url of ['/clientarea.php?action=services', '/clientarea.php?action=invoices', '/supporttickets.php', '/clientarea.php?action=domains']) {
        await p2.goto(url);
        expect(await p2.evaluate(() => document.body.dataset.data), url).toBe('empty');
        // The services list draws its own empty card instead of .when-empty.
        if (await p2.locator('.content-area .when-empty').count()) await expect(p2.locator('.content-area .when-empty').first(), `${url}: the empty state shows`).toBeVisible();
        for (const full of await p2.locator('.content-area .when-full').all()) await expect(full, `${url}: no full-state block`).toBeHidden();
        await expect(p2.locator('.content-area'), `${url}: says there is nothing yet`).toContainText(/no |don't have|yet/i);
      }
    } finally { await ctx2.close(); }
  });

  // --- TH-79: the list-table engine in client mode (enable_dynamic_ajax off) ---
  const realRows = (page, table) => page.locator(`#${table} tbody tr:not(:has(td.dataTables_empty))`);
  const clearTableState = page => page.evaluate(() => { for (const k of Object.keys(localStorage)) if (k.startsWith('DataTables_')) localStorage.removeItem(k); });

  test('TH-79 header sort reorders the rows (tickets by subject with the URL kept in step, emails by subject)', async ({ page, context }) => {
    await loginClient(context.request, 'full');
    await page.goto('/supporttickets.php');
    await clearTableState(page);
    await page.reload();
    const subjects = () => page.locator('#tkTable tbody tr[data-href]').evaluateAll(trs => trs.map(t => t.cells[0].innerText.trim()));
    await page.locator('#tkTable thead th').nth(0).click();
    await expect.poll(() => page.url()).toMatch(/orderby=subject&sort=(ASC|DESC)/);
    const first = await subjects();
    expect(first.length, 'the full persona has several tickets').toBeGreaterThan(1);
    await page.locator('#tkTable thead th').nth(0).click();
    await expect.poll(subjects, { message: 'the second click reverses the order' }).toEqual([...first].reverse());
    await clearTableState(page);

    await page.goto('/clientarea.php?action=emails');
    const em = () => page.locator('#emTable tbody tr[data-href]').evaluateAll(trs => trs.map(t => t.getAttribute('data-subject').toLowerCase()));
    await page.locator('#emTable thead th').nth(1).click();
    await expect.poll(em, { message: 'emails by subject, A to Z' }).toEqual([...(await em())].sort((a, b) => (a < b ? -1 : a > b ? 1 : 0)));
    await clearTableState(page);
  });

  test('TH-79 TH-83 the services list sorts from its column titles', async ({ page, context }) => {
    test.fail(true, 'BUG: clientareaproducts/default/default.tpl:129-132 draws the visible column titles as .svc-sort buttons outside the table with no click handler, while the DataTables header that does sort (:149-152) is hidden (0 px tall): the services list cannot be sorted');
    await loginClient(context.request, 'full');
    await page.goto('/clientarea.php?action=services');
    await clearTableState(page);
    await page.reload();
    const prices = () => page.locator('#svcTable tbody tr[data-href]').evaluateAll(trs => trs.map(t => Number(t.cells[1].getAttribute('data-order'))));
    const sorted = [...(await prices())].sort((a, b) => a - b);
    try {
      await page.locator('.content-area .hl-cell .svc-sort[data-sort=price]').click();
      await expect.poll(prices, { message: 'Pricing sorts the rows', timeout: 3000 }).toEqual(sorted);
    } finally { await clearTableState(page); }
  });

  test('TH-79 TH-96 invoices sort by amount and due date', async ({ page, context }) => {
    test.fail(true, 'BUG: clientareainvoices/default/default.tpl:162-164,172-173 take the sort keys from _sort_amount / _sort_due_raw, which WHMCS\'s own $invoices rows do not carry: Amount sorts on data-order="0" and Due Date on "", so those headers change the arrow and nothing else (Invoice Date sorts its dd/mm/yyyy text)');
    await loginClient(context.request, 'full');
    await page.goto('/clientarea.php?action=invoices');
    await clearTableState(page);
    await page.reload();
    const ids = () => page.locator('#invTable tbody tr[data-href]').evaluateAll(trs => trs.map(t => t.cells[0].innerText.trim()));
    try {
      await page.locator('#invTable thead th').nth(3).click();
      await expect.poll(ids, { message: 'by amount, ascending: -1.00 first, 190.00 last', timeout: 3000 }).toEqual(['#16', '#49', '#2', '#42', '#1']);
    } finally { await clearTableState(page); }
  });

  test('TH-79 TH-96 invoices list: search, kebab, row click', async ({ page, context }) => {
    const errors = watchErrors(page);
    await loginClient(context.request, 'full');
    await page.goto('/clientarea.php?action=invoices');
    await clearTableState(page);
    await page.reload();
    const rows = realRows(page, 'invTable');
    await expect(rows).toHaveCount(5);
    await page.locator('[data-mt-search][data-mt-for=invTable]').fill('59.88');
    await expect(rows).toHaveCount(1);
    await expect(rows.first()).toContainText(`#${id.unpaidInvoiceId}`);
    await page.locator('[data-mt-search][data-mt-for=invTable]').fill('no-such-invoice');
    await expect(rows).toHaveCount(0);
    await expect(page.locator('#invTable td.dataTables_empty'), 'an empty-result row').toHaveCount(1);
    await page.locator('[data-mt-search][data-mt-for=invTable]').fill('');
    await expect(rows).toHaveCount(5);

    // Kebab: opens, Esc closes.
    const kebab = rows.first().locator('[data-mt-kebab]');
    await kebab.locator('[data-mt-kebab-btn]').click();
    await expect(kebab).toHaveClass(/\bopen\b/);
    await expect(kebab.locator('[data-mt-kebab-btn]')).toHaveAttribute('aria-expanded', 'true');
    await page.keyboard.press('Escape');
    await expect(kebab).not.toHaveClass(/\bopen\b/);

    // A click on the row (not on a control) opens the invoice.
    const target = (await rows.first().getAttribute('data-href')).replace(/^.*\//, '');
    await rows.first().locator('td').nth(1).click();
    await page.waitForURL(u => (u.pathname + u.search).endsWith(target));
    expect(await tpl(page)).toBe('viewinvoice');
    await page.goto('/clientarea.php?action=invoices');
    await clearTableState(page);
    expect(errors).toEqual([]);
  });

  test('TH-79 TH-83 status tabs filter the services and domains lists', async ({ page, context }) => {
    await loginClient(context.request, 'full');
    await page.goto('/clientarea.php?action=services');
    await clearTableState(page);
    await page.reload();
    await page.locator('[data-mt-for=svcTable][data-mt-filter=Active]').click();
    await expect(page.locator('[data-mt-for=svcTable][data-mt-filter=Active]')).toHaveClass(/active/);
    await expect(realRows(page, 'svcTable')).toHaveCount(4);
    await page.goto('/clientarea.php?action=domains');
    await page.locator('[data-mt-for=domTable][data-mt-filter=Active]').click();
    await expect(realRows(page, 'domTable')).toHaveCount(1);
    await clearTableState(page);
  });

  test('TH-79 TH-96 TH-106 status tabs filter the invoices, quotes and tickets lists', async ({ page, context }) => {
    test.fail(true, 'BUG: dynamic-tables.js:347-352 (applyClientFilter) anchors ^\\s*<status>\\s*$ on the status column, but invoices/quotes/tickets give that <td> a data-order (clientareainvoices default.tpl:175, clientareaquotes :160, supporttickets :155), so DataTables types the column "string" and filters on the raw <span class="status-pill"> HTML: every tab shows "No matching records found"');
    await loginClient(context.request, 'full');
    await page.goto('/clientarea.php?action=invoices');
    await clearTableState(page);
    await page.reload();
    try {
      await page.locator('[data-mt-for=invTable][data-mt-filter=Unpaid]').click();
      await expect(realRows(page, 'invTable'), 'Unpaid: #42 and #49').toHaveCount(2, { timeout: 3000 });
      await page.locator('[data-mt-for=invTable][data-mt-filter=Paid]').click();
      await expect(realRows(page, 'invTable'), '"Paid" is not "Unpaid"').toHaveCount(3, { timeout: 3000 });
      await page.goto('/clientarea.php?action=quotes');
      await page.locator('[data-mt-for=qtTable][data-mt-filter=Delivered]').click();
      await expect(realRows(page, 'qtTable')).toHaveCount(1, { timeout: 3000 });
      await page.goto('/supporttickets.php');
      await page.locator('[data-mt-for=tkTable][data-mt-filter=Closed]').click();
      await expect(realRows(page, 'tkTable').first()).toBeVisible({ timeout: 3000 });
    } finally { await clearTableState(page); }
  });

  test('TH-79 list state (search, page size) survives a reload', async ({ page, context }) => {
    await loginClient(context.request, 'full');
    await page.goto('/clientarea.php?action=services');
    await clearTableState(page);
    await page.reload();
    await page.locator('[data-mt-search][data-mt-for=svcTable]').fill('test.com');
    await expect(realRows(page, 'svcTable')).toHaveCount(1);
    await page.locator('[data-dt-length][data-mt-for=svcTable]').selectOption('25');
    await page.waitForTimeout(500);   // DataTables saves state on draw
    await page.reload();
    await expect(page.locator('[data-mt-search][data-mt-for=svcTable]'), 'the search text is restored').toHaveValue('test.com');
    await expect(realRows(page, 'svcTable')).toHaveCount(1);
    await expect(page.locator('[data-dt-length][data-mt-for=svcTable]'), 'and the page size').toHaveValue('25');
    await clearTableState(page);
    await page.reload();
    await expect(realRows(page, 'svcTable'), 'cleared state shows everything again').toHaveCount(4);
  });

  test('TH-79 services, domains, tickets and quotes lists search, kebab and open rows', async ({ page, context }) => {
    const errors = watchErrors(page);
    await loginClient(context.request, 'full');
    await page.goto('/clientarea.php?action=services');
    await clearTableState(page);
    await page.reload();
    const svc = realRows(page, 'svcTable');
    await expect(svc).toHaveCount(4);
    await page.locator('[data-mt-search][data-mt-for=svcTable]').fill('VPS');
    await expect(svc).toHaveCount(1);
    const k = svc.first().locator('[data-mt-kebab]');
    await k.locator('[data-mt-kebab-btn]').click();
    await expect(k.locator('a[href*="action=cancel"]'), 'kebab: request cancellation').toBeVisible();
    await page.locator('.content-area h1').click();
    await expect(k, 'outside click closes it').not.toHaveClass(/\bopen\b/);
    await page.locator('[data-mt-search][data-mt-for=svcTable]').fill('');

    await page.goto('/clientarea.php?action=domains');
    const dom = realRows(page, 'domTable');
    await expect(dom).toHaveCount(1);
    await page.locator('[data-mt-search][data-mt-for=domTable]').fill('no-such-domain-anywhere');
    await expect(dom).toHaveCount(0);
    await page.locator('[data-mt-search][data-mt-for=domTable]').fill('');
    await expect(dom).toHaveCount(1);

    await page.goto('/supporttickets.php');
    const tk = realRows(page, 'tkTable');
    await page.locator('[data-mt-search][data-mt-for=tkTable]').fill('SSL certificate');
    await expect(tk).toHaveCount(1);
    await tk.first().locator('td').first().click();
    await page.waitForURL(/viewticket\.php\?tid=/);
    expect(await tpl(page)).toBe('viewticket');

    await page.goto('/clientarea.php?action=quotes');
    const qt = realRows(page, 'qtTable');
    await expect(qt).toHaveCount(1);
    await qt.first().locator('td').first().click();
    await page.waitForURL(/viewquote\.php\?id=/);
    expect(await tpl(page)).toBe('viewquote');
    await clearTableState(page);
    expect(errors).toEqual([]);
  });

  test('TH-79 page size and pager reach every email in the history', async ({ page, context }) => {
    test.fail(true, 'BUG: the theme ships no theme.yaml with properties.serverSidePagination: false (stock twenty-one/theme.yaml:6), so WHMCS sends client-area lists 10 rows at a time and dynamic-tables.js (client mode) pages only those 10 - an 11th email, invoice or service is unreachable ("Showing 1-10 of 10", no ?page= links)');
    await loginClient(context.request, 'full');
    const second = await (await context.request.get('/clientarea.php?action=emails&page=2')).text();
    const onPage2 = (second.match(/<tr data-href=/g) || []).length;
    expect(onPage2, 'the full persona has more than 10 emails').toBeGreaterThan(0);
    await page.goto('/clientarea.php?action=emails');
    await page.locator('[data-dt-length][data-mt-for=emTable]').selectOption('-1');
    await expect(realRows(page, 'emTable'), 'View all lists every email').toHaveCount(10 + onPage2);
  });

  test('TH-80 the image CAPTCHA is on the guest forms WHMCS protects, and not for signed-in clients', async ({ page, context }) => {
    // CaptchaSetting = offloggedin, CaptchaForms unset (WHMCS defaults: register, contact, ticket on; login off).
    for (const url of ['/register.php', '/contact.php']) {
      await page.goto(url);
      const img = page.locator('.content-area img.mt-captcha-img');
      await expect(img, url).toBeVisible();
      await expect.poll(() => img.evaluate(i => i.complete && i.naturalWidth > 0), { message: `${url}: the image loads` }).toBe(true);
      await expect(page.locator('.content-area input.mt-captcha-code[name=code]')).toHaveAttribute('maxlength', '6');
    }
    await page.goto('/login');
    await expect(page.locator('.mt-captcha-img'), 'login captcha is off by default').toHaveCount(0);

    await loginClient(context.request, 'full');
    for (const url of ['/contact.php', `/submitticket.php?step=2&deptid=${id.deptId}`]) {
      await page.goto(url);
      await expect(page.locator('.mt-captcha-img'), `${url}: none when signed in`).toHaveCount(0);
    }
  });

  test('TH-82 Generate Password fills both password fields with the same strong password', async ({ page, context }) => {
    // "Copy & insert" also copies; a real browser allows that on a click.
    await context.grantPermissions(['clipboard-read', 'clipboard-write'], { origin: BASE_URL });
    const errors = watchErrors(page);
    await page.goto('/register.php');
    await page.locator('.generate-password').click();
    const modal = page.locator('#crGpModal');
    await expect(modal).toBeVisible();
    const out = page.locator('#crGpOutput');
    await expect(out).toHaveValue(/^.{16}$/);
    await page.locator('#crGpLength').fill('24');
    await expect(out, 'the length control regenerates').toHaveValue(/^.{24}$/);
    await page.locator('#crGpRegen').click();
    const pwd = await out.inputValue();
    expect(pwd).toHaveLength(24);
    await page.locator('#crGpInsert').click();
    await expect(modal).toBeHidden();
    await expect(page.locator('#cr-pw1')).toHaveValue(pwd);
    await expect(page.locator('#cr-pw2')).toHaveValue(pwd);
    expect(await page.evaluate(() => navigator.clipboard.readText()), 'and it is on the clipboard').toBe(pwd);
    expect(new Set(pwd).size, 'not a repeated character').toBeGreaterThan(8);
    await page.locator('.generate-password').click();
    await page.keyboard.press('Escape');
    await expect(modal, 'Esc closes it').toBeHidden();
    await expect(page.locator('#cr-pw1'), 'and leaves the fields alone').toHaveValue(pwd);
    expect(errors).toEqual([]);
  });
});

// ======================================================================= TH-M
test.describe('TH-M Services', () => {
  test('TH-83 services list: tabs only for statuses present, search, row opens the service', async ({ page, context, browser }) => {
    await loginClient(context.request, 'full');
    await page.goto('/clientarea.php?action=services');
    await page.evaluate(() => { for (const k of Object.keys(localStorage)) if (k.startsWith('DataTables_')) localStorage.removeItem(k); });
    await page.reload();
    // All four of the full persona's services are Active: All + Active, nothing else.
    await expect(page.locator('[data-mt-for=svcTable][data-mt-filter]')).toHaveCount(2);
    await page.locator('[data-mt-for=svcTable][data-mt-filter=Active]').click();
    await expect(page.locator('#svcTable tbody tr[data-href]')).toHaveCount(4);
    await page.locator('[data-mt-search][data-mt-for=svcTable]').fill('riverbend');
    await expect(page.locator('#svcTable tbody tr[data-href]')).toHaveCount(2);
    await page.locator('#svcTable tbody tr[data-href]').filter({ hasText: 'Business' }).locator('td').nth(2).click();
    await page.waitForURL(new RegExp(`action=productdetails&id=${id.serviceId}$`));
    expect(await tpl(page)).toBe('clientareaproductdetails');
    await page.evaluate(() => { for (const k of Object.keys(localStorage)) if (k.startsWith('DataTables_')) localStorage.removeItem(k); });

    const ctx2 = await browser.newContext();
    try {
      await loginClient(ctx2.request, 'suspended');
      const p2 = await ctx2.newPage();
      await p2.goto('/clientarea.php?action=services');
      await expect(p2.locator('[data-mt-for=svcTable][data-mt-filter=Suspended]'), 'a Suspended tab when one is suspended').toHaveCount(1);
      await p2.locator('[data-mt-for=svcTable][data-mt-filter=Suspended]').click();
      for (const r of await p2.locator('#svcTable tbody tr[data-href]').all()) await expect(r.locator('.status-pill')).toHaveText('Suspended');
    } finally { await ctx2.close(); }
  });

  test('TH-84 service details: status, configurable options, custom field, addon, billing and the side menu', async ({ page, context }) => {
    const errors = watchErrors(page);
    await loginClient(context.request, 'full');
    await page.goto(`/clientarea.php?action=productdetails&id=${id.serviceId}`);
    const ca$ = page.locator('.content-area');
    await expect(ca$.locator('h1')).toHaveText('Business');
    await expect(ca$.locator('.status-pill').first()).toHaveText('Active');
    await expect(page.locator('#pd-configoptions')).toContainText('Data centre');
    await expect(page.locator('#pd-configoptions')).toContainText('London');
    await expect(page.locator('#pd-customfields'), 'product custom field').toContainText('Project name');
    await expect(page.locator('#pd-addons')).toContainText('Priority support (hadrian-test)');
    await expect(page.locator('#pd-billing')).toContainText(/Recurring Amount[\s\S]*Annually/);
    await expect(page.locator('.pd-alert-warn'), 'no pending-cancellation notice').toHaveCount(0);
    await page.locator('.subnav-item', { hasText: 'Addons' }).click();
    await expect.poll(() => page.url()).toMatch(/#pd-addons$/);
    await page.locator('.subnav-item-danger', { hasText: /cancellation/i }).click();
    await page.waitForURL(/action=cancel&id=/);
    expect(await tpl(page)).toBe('clientareacancelrequest');
    expect(errors).toEqual([]);
  });

  test('TH-87 upgrade: the current plan is named, the offered plan reaches the summary with its name', async ({ page, context }) => {
    await loginClient(context.request, 'full');
    await page.goto(`/clientarea.php?action=productdetails&id=${id.serviceId}`);
    await page.locator('#pd-manage a[href*="upgrade.php?type=package"]').first().click();
    await page.waitForURL(/upgrade\.php/);
    expect(await tpl(page)).toBe('upgrade');
    await expect(page.locator('.content-area'), 'the current configuration').toContainText('Shared Hosting - Business');
    // WHMCS offers only the other plans (Business -> Professional on the fixture).
    await expect(page.locator('form.up-st-plan .st-plan-name', { hasText: 'Business' })).toHaveCount(0);
    const other = page.locator('form.up-st-plan:not(.current)').first();
    const name = (await other.locator('.st-plan-name').innerText()).trim();
    await other.locator('[type=submit]').click();
    await page.waitForLoadState('load');
    expect(await tpl(page)).toBe('upgradesummary');
    await expect(page.locator('.content-area')).toContainText(name);
  });

  test('TH-88 TH-84 a cancellation request is submitted and the service then shows it as pending', async ({ page, context }) => {
    const t = await throwaway(context, { service: true });
    try {
      await page.goto(`/clientarea.php?action=productdetails&id=${t.serviceId}`);
      await page.locator('.pd-manage-cancel').click();
      await page.waitForURL(/action=cancel/);
      await page.locator('#cancellationreason').fill('client-area.spec: testing the cancellation form');
      await page.locator('#type').selectOption({ index: 0 });
      await page.locator('.content-area form [type=submit].btn-danger').click();
      await page.waitForLoadState('load');
      await expect(page.locator('.cr-notice-title'), 'the confirmation').toBeVisible();
      expect(ca('client', t.clientId).cancelRequests, 'WHMCS recorded the request').toBe(1);
      await page.locator('.cr-notice a.btn-primary').click();
      await page.waitForURL(/action=productdetails/);
      await expect(page.locator('.pd-alert-warn'), 'pending-cancellation notice').toBeVisible();
      await expect(page.locator('.pd-manage-cancel'), 'no second request offered').toHaveCount(0);
    } finally { t.remove(); }
  });
});

test.describe('TH-M Services (SSL)', () => {
  test('TH-90 SSL certificates list the client\'s certificate with its status and renewal date', async ({ page, context }) => {
    // configuressl-* and usage billing need an SSL / usage module (coverage.mjs: local).
    await loginClient(context.request, 'full');
    await page.goto('/index.php?rp=/clientarea/ssl-certificates/manage');
    expect(await tpl(page)).toBe('managessl');
    const row = page.locator('.content-area tr').filter({ hasText: 'riverbendstudio.co.uk' }).first();
    await expect(row).toContainText('DV SSL');
    await expect(row.locator('.ssl-pill')).toHaveText(/active/i);
    await expect(row.locator('.ssl-date')).toHaveText(/\d{2}\/\d{2}\/\d{4}/);
    await expect(page.locator('.content-area a', { hasText: /order new certificate/i })).toHaveAttribute('href', /cart\.php\?gid=ssl/);
  });
});

// ======================================================================= TH-N
test.describe('TH-N Domains', () => {
  test('TH-91 bulk bar appears when a domain is ticked and goes when it is unticked', async ({ page, context }) => {
    await loginClient(context.request, 'full');
    await page.goto('/clientarea.php?action=domains');
    const boxes = page.locator('#domainForm input[name="domids[]"]');
    await expect(page.locator('#bulk')).toBeHidden();
    await boxes.first().check();
    await expect(page.locator('#bulk')).toBeVisible();
    await boxes.first().uncheck();
    await expect(page.locator('#bulk'), 'unticking hides it again').toBeHidden();
  });

  test('TH-92 domain details: auto-renew off and on again, nameservers saved, tabs switch', async ({ page, context }) => {
    const errors = watchErrors(page);
    const before = ca('domain', id.domainId);
    await loginClient(context.request, 'full');
    try {
      await page.goto(`/clientarea.php?action=domaindetails&id=${id.domainId}`);
      await page.locator('[data-dd-tab=autorenew]').click();
      const panel = page.locator('[data-dd-panel=autorenew]');
      await expect(panel).toHaveClass(/active/);
      await expect(panel.locator('.dd-status-tag')).toHaveClass(/dd-tag-on/);
      await panel.locator('button.dd-danger-btn').click();
      await page.waitForLoadState('load');
      await expect(panel, 'the #tabAutorenew hash reopens the tab').toHaveClass(/active/);
      await expect(panel.locator('.dd-alert-success')).toBeVisible();
      await expect(panel.locator('.dd-status-tag'), 'auto-renew is now off').toHaveClass(/dd-tag-off/);
      expect(ca('domain', id.domainId).donotrenew).toBe(1);
      await panel.locator('button.btn-primary').click();
      await page.waitForLoadState('load');
      await expect(panel.locator('.dd-status-tag'), 'and on again').toHaveClass(/dd-tag-on/);
      expect(ca('domain', id.domainId).donotrenew).toBe(0);

      await page.locator('[data-dd-tab=nameservers]').click();
      const ns = page.locator('[data-dd-panel=nameservers]');
      await ns.locator('input[name=nschoice][value=custom]').check();
      await ns.locator('#inputNs3').fill('ns3.hadrian-test.example');
      await ns.locator('button[type=submit].btn-primary').click();
      await page.waitForLoadState('load');
      await expect(ns).toHaveClass(/active/);
      await expect(ns.locator('.dd-alert-success'), 'the stub registrar accepted the nameservers').toBeVisible();
      await expect(ns.locator('.dd-alert-error')).toHaveCount(0);

      await page.locator('[data-dd-tab=overview]').click();
      await page.locator('[data-dd-jump=nameservers]').click();
      await expect(ns, 'the overview shortcut jumps to the tab').toHaveClass(/active/);
      await expect(page.locator('[data-dd-tab=reglock]'), '.uk domains have no registrar lock in WHMCS').toHaveCount(0);
      expect(errors).toEqual([]);
    } finally {
      ca('set-domain', id.domainId, JSON.stringify({ donotrenew: before.donotrenew }));
    }
  });

  test('TH-93 DNS and email forwarding forms save through the registrar', async ({ page, context }) => {
    const errors = watchErrors(page);
    await loginClient(context.request, 'full');
    await page.goto(`/clientarea.php?action=domaindns&domainid=${id.domainId}`);
    const dns = page.locator('form.dns-card');
    await dns.locator('input[name="dnsrecordhost[]"]').last().fill('spec');
    await dns.locator('select[name="dnsrecordtype[]"]').last().selectOption('TXT');
    await dns.locator('input[name="dnsrecordaddress[]"]').last().fill('v=spec1');
    await dns.locator('button[type=submit].btn-primary').click();
    await page.waitForLoadState('load');
    expect(await tpl(page)).toBe('clientareadomaindns');
    expect(await auth(page)).toBe('in');
    await expect(page.locator('.dns-alert-error'), 'no registrar error').toHaveCount(0);
    await expect(page.locator('input[name="dnsrecordaddress[]"][value="192.0.2.10"]'), 'the records are read back').toHaveCount(1);

    await page.goto(`/clientarea.php?action=domainemailforwarding&domainid=${id.domainId}`);
    await page.locator('input[name=emailforwarderprefixnew]').fill('spec');
    await page.locator('input[name=emailforwarderforwardtonew]').fill('spec@demo.hadrian.test');
    await page.locator('form.ef-card button[type=submit]').click();
    await page.waitForLoadState('load');
    expect(await tpl(page)).toBe('clientareadomainemailforwarding');
    await expect(page.locator('.ef-alert-error')).toHaveCount(0);
    await expect(page.locator('input[name="emailforwarderprefix[0]"]')).toHaveValue('hello');
    expect(errors).toEqual([]);
  });

  test('TH-93 WHOIS contacts save, and the EPP code is shown and copied', async ({ page, context }) => {
    await context.grantPermissions(['clipboard-read', 'clipboard-write'], { origin: BASE_URL });
    await loginClient(context.request, 'full');
    await page.goto(`/clientarea.php?action=domaincontacts&domainid=${id.domainId}`);
    await page.locator('[data-ci-tab=Technical]').click();
    await expect(page.locator('input[name="contactdetails[Technical][First Name]"]')).toBeVisible();
    await page.locator('[data-ci-tab=Registrant]').click();
    await page.locator('input[name="contactdetails[Registrant][Address 2]"]').fill('Studio 4');
    await page.locator('#frmDomainContactModification [type=submit]').click();
    await page.waitForLoadState('load');
    expect(await tpl(page)).toBe('clientareadomaincontactinfo');
    await expect(page.locator('.ci-alert-success')).toBeVisible();

    await page.goto(`/clientarea.php?action=domaingetepp&domainid=${id.domainId}`);
    await expect(page.locator('#eppCode')).toHaveText('HADRIAN-TEST-EPP-0000');
    await page.locator('[data-epp-copy]').click();
    await expect.poll(() => page.evaluate(() => navigator.clipboard.readText())).toBe('HADRIAN-TEST-EPP-0000');
  });

  test('TH-93 registering a glue record stays on the page and reports the registrar result', async ({ page, context }) => {
    test.fail(true, 'BUG: clientareadomainregisterns/default/default.tpl:27,50,77 post to ?action=registerns, which WHMCS answers with a redirect to the dashboard (its action is domainregisterns, stock twenty-one clientareadomainregisterns.tpl:9); the sub-nav links at :104 and getepp :68 (action=registerns / action=getepp) land on the dashboard too');
    await loginClient(context.request, 'full');
    await page.goto(`/clientarea.php?action=domainregisterns&domainid=${id.domainId}`);
    expect(await tpl(page)).toBe('clientareadomainregisterns');
    await page.locator('#rns-reg-ns').fill('ns9');
    await page.locator('#rns-reg-ip').fill('192.0.2.99');
    await page.locator('form.rns-card:has(#rns-reg-ns) [type=submit]').click();
    await page.waitForLoadState('load');
    expect(await tpl(page), 'still on the glue-records page').toBe('clientareadomainregisterns');
  });

  test('TH-94 domain addon: disabling ID protection goes through the confirmation step', async ({ page, context }) => {
    const before = ca('domain', id.domainId);
    await loginClient(context.request, 'full');
    try {
      await page.goto(`/clientarea.php?action=domaindetails&id=${id.domainId}#tabAddons`);
      const addons = page.locator('[data-dd-panel=addons]');
      await expect(addons).toHaveClass(/active/);
      await addons.locator('form:has(input[name=disable][value=idprotect]) button[type=submit]').click();
      await page.waitForLoadState('load');
      expect(await tpl(page)).toBe('clientareadomainaddons');
      await expect(page.locator('.da-confirm'), 'asks first').toBeVisible();
      expect(ca('domain', id.domainId).idprotection, 'nothing changes before confirming').toBe(1);
      await page.locator('form.da-form button.da-danger-btn').click();
      await page.waitForLoadState('load');
      await expect(page.locator('.da-alert-success')).toBeVisible();
      expect(ca('domain', id.domainId).idprotection).toBe(0);
      await page.goto(`/clientarea.php?action=domaindetails&id=${id.domainId}#tabAddons`);
      await expect(page.locator('[data-dd-panel=addons] input[name=disable][value=idprotect]'), 'the addon tab now offers it, not Disable').toHaveCount(0);
    } finally {
      ca('set-domain', id.domainId, JSON.stringify({ idprotection: before.idprotection }));
    }
  });

  test('TH-95 domain pricing lists the TLDs with their register, transfer and renew prices', async ({ page }) => {
    await page.goto('/index.php?rp=/domain/pricing');
    const body = page.locator('.content-area');
    for (const [tld, reg] of [['.com', '12.99'], ['.io', '39.00'], ['.co.uk', '8.99']]) {
      const row = body.locator('tr, [class*=row]').filter({ hasText: tld }).filter({ hasText: reg }).first();
      await expect(row, `${tld} at ${reg}`).toBeVisible();
    }
    await expect(body.locator('tr, [class*=row]').filter({ hasText: '.com' }).filter({ hasText: '13.99' }).first(), '.com renews at 13.99').toBeVisible();
  });
});

// ======================================================================= TH-O
test.describe('TH-O Billing', () => {
  test('TH-97 mass pay totals the unpaid invoices and creates one invoice for them', async ({ page, context }) => {
    const t = await throwaway(context);
    try {
      ca('make-invoice', t.clientId, 'banktransfer', 10);
      ca('make-invoice', t.clientId, 'banktransfer', 15);
      await page.goto('/clientarea.php?action=masspay&all=true');
      expect(await tpl(page)).toBe('masspay');
      await expect(page.locator('.mp-summary-value')).toHaveText(/25\.00/);
      await expect(page.locator('input[name="invoiceids[]"]')).toHaveCount(2);
      await page.locator('.mp-submit').click();
      await page.waitForLoadState('load');
      expect(await tpl(page), 'WHMCS hands over to the gateway page').toBe('forwardpage');
      // Its Cancel link names the new combined invoice.
      await page.locator('.content-area a.btn-secondary[href*="viewinvoice.php?id="]').click();
      await page.waitForURL(/viewinvoice\.php\?id=\d+/);
      expect(await tpl(page)).toBe('viewinvoice');
      await expect(page.locator('.content-area')).toContainText('$25.00 USD');
    } finally { t.remove(); }
  });

  test('TH-97 mass pay by bank transfer moves on from "Please wait" to the invoice', async ({ page, context }) => {
    test.fail(true, 'BUG: forwardpage.tpl:30-37 only auto-submits a <form> found in the gateway $code; Bank Transfer\'s $code is text, so the page says "redirecting" and spins for ever. Stock twenty-one forwardpage.tpl adds a fallback form to viewinvoice.php?id= that its timer submits');
    const t = await throwaway(context);
    try {
      ca('make-invoice', t.clientId, 'banktransfer', 10);
      ca('make-invoice', t.clientId, 'banktransfer', 15);
      await page.goto('/clientarea.php?action=masspay&all=true');
      await page.locator('.mp-submit').click();
      await page.waitForURL(/viewinvoice\.php\?id=\d+/, { timeout: 12_000 });
    } finally { t.remove(); }
  });

  test('TH-98 view invoice: line items, PDF, payment method switch, apply credit to the ledger', async ({ page, context }) => {
    const errors = watchErrors(page);
    const t = await throwaway(context);
    try {
      const { invoiceId } = ca('make-invoice', t.clientId, 'banktransfer', 12.5);
      ca('add-credit', t.clientId, 5);
      await page.goto(`/viewinvoice.php?id=${invoiceId}`);
      const c = page.locator('.content-area');
      await expect(c).toContainText('client-area.spec test charge');
      await expect(c).toContainText('$12.50 USD');

      const pdf = await context.request.get(await page.locator('a.inv-action[href*="dl.php?type=i"]').getAttribute('href'));
      expect(pdf.headers()['content-type'], 'Download is a PDF').toMatch(/pdf/);
      expect((await pdf.body()).subarray(0, 4).toString()).toBe('%PDF');

      // Switching the gateway resubmits the form and the pay button follows it.
      await expect(page.locator('#btnPayNow')).toHaveCount(0);
      await page.locator('#frmInvGateway input[value=offlinecc]').check();
      await page.waitForLoadState('load');
      await expect(page.locator('#frmInvGateway input[value=offlinecc]')).toBeChecked();
      await expect(page.locator('#btnPayNow'), 'a card gateway offers Pay Now').toBeVisible();

      await expect(c).toContainText(/credit balance is \$5\.00/i);
      await page.locator('.content-area form:has([name=creditamount]) [type=submit]').click();
      await page.waitForLoadState('load');
      await expect(c.locator('table').filter({ hasText: 'Ledger' }).or(c), 'the ledger lists the credit').toContainText(/Credit Note|Credit/);
      await expect(c).toContainText('$7.50 USD');
      expect(errors).toEqual([]);
    } finally { t.remove(); }
  });

  test('TH-98 "Amount due" shows what is still owed after a part payment', async ({ page, context }) => {
    test.fail(true, 'BUG: viewinvoice/default/default.tpl:86-87 and :289-290 label {$total} as "Amount due"; after credit or a part payment the customer is still told the full total ($12.50) while {$balance} ($7.50) is what is owed');
    const t = await throwaway(context);
    try {
      const { invoiceId } = ca('make-invoice', t.clientId, 'banktransfer', 12.5);
      ca('add-credit', t.clientId, 5);
      await page.goto(`/viewinvoice.php?id=${invoiceId}`);
      await page.locator('.content-area form:has([name=creditamount]) [type=submit]').click();
      await page.waitForLoadState('load');
      await expect(page.locator('.inv-aside-summary-value').first()).toHaveText(/7\.50/);
    } finally { t.remove(); }
  });

  test('TH-99 paying an invoice with the offline card: card form, number formatting, recorded for manual processing', async ({ page, context }) => {
    const errors = watchErrors(page);
    const t = await throwaway(context);
    try {
      const { invoiceId } = ca('make-invoice', t.clientId, 'offlinecc', 12.5);
      await page.goto(`/viewinvoice.php?id=${invoiceId}`);
      await page.locator('#btnPayNow').click();
      await page.waitForURL(/invoice\/\d+\/pay/);
      expect(await tpl(page)).toBe('invoice-payment');
      await expect(page.locator('.content-area')).toContainText(`#${invoiceId}`);
      await page.locator('#inputCardNumber').pressSequentially('4111111111111111');
      await expect(page.locator('#inputCardNumber')).toHaveValue('4111 1111 1111 1111');
      await page.locator('#inputCardExpiry').pressSequentially('1230');
      await expect(page.locator('#inputCardExpiry')).toHaveValue('12 / 30');
      // Without a CVC WHMCS refuses, and the form keeps what was typed.
      await page.locator('#btnSubmit').click();
      await page.waitForLoadState('load');
      expect(await tpl(page)).toBe('invoice-payment');
      await expect(page.locator('.content-area')).toContainText(/CVC|CVV/i);
      await page.locator('#inputCardCvv').fill('123');
      await page.locator('#btnSubmit').click();
      await page.waitForURL(/viewinvoice\.php\?id=\d+&offlinepaid=true/);
      await expect(page.locator('.content-area'), 'WHMCS records it for manual processing').toContainText(/processed manually/i);
      expect(errors).toEqual([]);
    } finally { t.remove(); }
  });

  test('TH-100 add funds: presets fill the amount, the minimum is enforced, a valid amount makes an invoice', async ({ page, context }) => {
    const t = await throwaway(context);
    try {
      await page.goto('/clientarea.php?action=addfunds');
      await page.locator('.af-preset[data-amt="25.00"]').click();
      await expect(page.locator('#af-amount')).toHaveValue('25.00');
      await expect(page.locator('.af-preset[data-amt="25.00"]')).toHaveClass(/active/);
      await page.locator('#af-amount').fill('5');
      await page.locator('form.af-form [type=submit]').click();
      await page.waitForLoadState('load');
      expect(await tpl(page)).toBe('clientareaaddfunds');
      await expect(page.locator('.content-area'), 'below the $10 minimum').toContainText(/minimum/i);
      await page.locator('#af-amount').fill('20');
      await page.locator('form.af-form [type=submit]').click();
      await page.waitForLoadState('load');
      // Bank Transfer: WHMCS makes the invoice and shows the gateway hand-off page.
      if (await tpl(page) === 'forwardpage') await page.locator('.content-area a.btn-secondary[href*="viewinvoice.php?id="]').click();
      await page.waitForURL(/viewinvoice\.php\?id=\d+/);
      await expect(page.locator('.content-area')).toContainText('$20.00 USD');
    } finally { t.remove(); }
  });

  test('TH-101 quotes: Accept posts with the token and marks the quote accepted; the PDF downloads', async ({ page, context }) => {
    const t = await throwaway(context);
    try {
      const { quoteId } = ca('make-quote', t.clientId);
      await page.goto('/clientarea.php?action=quotes');
      const row = page.locator('#qtTable tbody tr[data-href]').first();
      await row.locator('[data-mt-kebab-btn]').click();
      await row.locator(`a[href*="viewquote.php?id=${quoteId}"]`).filter({ hasText: /accept/i }).first().click();
      await page.waitForURL(new RegExp(`viewquote\\.php\\?id=${quoteId}`));
      const pdf = await context.request.get(`/dl.php?type=q&id=${quoteId}`);
      expect(pdf.headers()['content-type']).toMatch(/pdf/);
      page.once('dialog', d => d.accept());
      await page.locator('form#accept [type=submit]').click();
      await page.waitForLoadState('load');
      expect(await auth(page)).toBe('in');
      // WHMCS asks to agree to the terms when TOS is on; otherwise it accepts at once.
      const tos = page.locator('input[name=agreetos]');
      if (await tos.count()) { await tos.check(); await page.locator('form#accept [type=submit], .modal [type=submit]').first().click(); await page.waitForLoadState('load'); }
      expect(ca('client', t.clientId).quoteStage).toBe('Accepted');
      await expect(page.locator('form#accept'), 'no second Accept').toHaveCount(0);
    } finally { t.remove(); }
  });

  test('TH-102 payment methods: a new card can be made the default', async ({ page, context }) => {
    const t = await throwaway(context);
    try {
      for (const label of ['spec card one', 'spec card two']) {
        await page.goto('/index.php?rp=/account/paymentmethods/add');
        await page.locator('#inputDescription').fill(label);
        await page.locator('#inputCardNumber').pressSequentially(label.endsWith('one') ? '4111111111111111' : '5555555555554444');
        await page.locator('#inputCardExpiry').pressSequentially('1230');
        if (await page.locator('#inputCardCvc, #inputCardCvv').count()) await page.locator('#inputCardCvc, #inputCardCvv').first().fill('123');
        await page.locator('#btnSubmit').click();
        await page.waitForURL(/rp=\/account\/paymentmethods(?!\/add)/);
      }
      const row = page.locator('[class*="pm-row"]').filter({ hasText: 'spec card two' }).first();
      await expect(row).toBeVisible();
      const setDefault = row.locator('[data-pm-setdefault]');
      await expect(setDefault, 'the second card is not the default yet').toHaveCount(1);
      await setDefault.click();
      await page.waitForLoadState('load');
      expect(await auth(page)).toBe('in');
      await expect(page.locator('[class*="pm-row"]').filter({ hasText: 'spec card two' }).first().locator('[data-pm-setdefault]'), 'now it is').toHaveCount(0);
    } finally { t.remove(); }
  });

  test('TH-103 email history: the list opens the message', async ({ page, context }) => {
    await loginClient(context.request, 'full');
    // The fixture emails can sit on WHMCS's second page of 10, so open them by id.
    await page.goto(`/viewemail.php?id=${id.emailId}`);
    await expect(page.locator('body'), 'the body of the message').toContainText('Hello Mara,');
    await expect(page.locator('body')).toContainText('Welcome to Hostnodes (test fixture)');
    expect(inspect(await page.content()).problems).toEqual([]);
    await page.goto('/clientarea.php?action=emails');
    const link = page.locator('#emTable a[href*="viewemail.php"]').first();
    const href = await link.getAttribute('href');
    const own = (await (await context.request.get(href)).text()).replace(/<[^>]+>/g, ' ').replace(/\s+/g, ' ').trim();
    await link.click();
    await page.waitForURL(u => u.href.endsWith(href.replace(/^\//, '')));
    expect((await page.locator('body').innerText()).length, 'the clicked email has content').toBeGreaterThan(20);
    expect(own.length).toBeGreaterThan(20);
  });

  test('TH-103 email history opens the message in a popup and keeps the list', async ({ page, context }) => {
    test.fail(true, 'BUG: clientareaemails/default/default.tpl:72-77 (and dynamic-tables.js row click) load viewemail.php in the same tab, a bare document with no navigation; the template header and stock twenty-one open it with popupWindow()');
    await loginClient(context.request, 'full');
    await page.goto('/clientarea.php?action=emails');
    const popup = context.waitForEvent('page', { timeout: 5000 });
    await page.locator('#emTable tbody tr[data-href]').first().locator('td').first().click();
    const win = await popup;
    await win.waitForLoadState('load');
    expect(win.url()).toMatch(/viewemail\.php\?id=\d+/);
    expect(page.url(), 'the list stays open').toMatch(/action=emails/);
  });
});

// ======================================================================= TH-P
test.describe('TH-P Support', () => {
  test('TH-104 TH-105 a ticket with urgency, related service and an attachment; the attachment is on the ticket', async ({ page, context }) => {
    test.setTimeout(2 * 60_000);
    const errors = watchErrors(page);
    // A throwaway customer, so the full persona's open-ticket count stays put.
    const t = await throwaway(context, { service: true });
    try {
      await page.goto('/submitticket.php');
      expect(await tpl(page)).toBe('supportticketsubmit-stepone');
      await page.locator(`label:has(input[name=deptid][value="${id.deptId}"])`).click();
      await page.locator('form:has(input[name=deptid]) [type=submit]').first().click();
      await page.waitForURL(/step=2/);
      const subject = `[flow] ca attachment ${Date.now()}`;
      await page.locator('#tk-subject').fill(subject);
      await page.locator('#tk-priority').selectOption({ label: 'High' });
      await page.locator('#tk-service').selectOption({ index: 1 });
      await page.locator('#tk-message').fill('Sent by client-area.spec with an attachment. Safe to delete.');
      // "Add More" adds a second file row, its remove button takes it away again.
      await page.locator('#tk-attach-add').click();
      await expect(page.locator('.tk-attach-row')).toHaveCount(2);
      await page.locator('.tk-attach-row').nth(1).locator('.tk-attach-remove').click();
      await expect(page.locator('.tk-attach-row')).toHaveCount(1);
      await page.locator('input[name="attachments[]"]').first().setInputFiles({ name: 'spec-note.txt', mimeType: 'text/plain', buffer: Buffer.from('client-area.spec attachment\n') });
      await page.locator('form.tk-submit-form [type=submit]').click();
      const view = page.locator('.content-area a[href*="viewticket.php"]').first();
      await expect(view).toBeVisible({ timeout: 30_000 });
      expect(await tpl(page)).toBe('supportticketsubmit-confirm');
      await view.click();
      await page.waitForURL(/viewticket/);
      const c = page.locator('.content-area');
      await expect(c).toContainText(subject.replace('[flow] ', ''));
      await expect(c, 'urgency').toContainText('High');
      await expect(c.locator('a', { hasText: 'spec-note.txt' }), 'the attachment is listed and linked').toBeVisible();
      const file = await context.request.get(await c.locator('a', { hasText: 'spec-note.txt' }).first().getAttribute('href'));
      expect(await file.text()).toContain('client-area.spec attachment');
      expect(errors).toEqual([]);
    } finally { t.remove(); }
  });

  test('TH-104 knowledgebase suggestions appear while the ticket message is typed', async ({ page, context }) => {
    test.fail(true, 'BUG: SupportTicketKBSuggestions is on, but supportticketsubmit/default/default.tpl has no suggestions container and never posts submitticket.php action=getkbarticles (stock twenty-one supportticketsubmit-steptwo.tpl:109 + scripts.js:22816); WHMCS answers that call with matches, nobody asks');
    await loginClient(context.request, 'full');
    await page.goto(`/submitticket.php?step=2&deptid=${id.deptId}`);
    await page.locator('#tk-subject').fill('Domain question');
    await page.locator('#tk-message').pressSequentially('How do I point my domain nameservers at my hosting?', { delay: 20 });
    await expect(page.locator('.content-area a[href*="displayarticle&id=1"], .content-area a[href*="knowledgebase/1/"]').filter({ hasText: /point my domain/i }).first(), 'the matching article is suggested').toBeVisible({ timeout: 8000 });
  });

  test('TH-105 a missing ticket and a closed ticket show their states, not a usable ticket', async ({ page, context }) => {
    await loginClient(context.request, 'full');
    await page.goto('/viewticket.php?tid=NOPE-000000&c=x');
    expect(await tpl(page)).toBe('viewticket');
    expect(await bodyAttr(page, 'data-data')).toBe('empty');
    await expect(page.locator('a.tk-close-btn'), 'no Close for no ticket').toBeHidden();
    await expect(page.locator('textarea[name=replymessage]'), 'no reply box').toBeHidden();
    await expect(page.locator('.content-area .when-empty').first()).toBeVisible();

    await page.goto(`/viewticket.php?tid=${id.closedTicketTid}&c=${id.closedTicketC}`);
    await expect(page.locator('.content-area .status-pill').first()).toHaveText(/closed/i);
    await expect(page.locator('a.tk-close-btn'), 'a closed ticket cannot be closed again').toHaveCount(0);
    await expect(page.locator('.content-area')).toContainText('Done - your site is live on the new server.');
  });

  test('TH-106 ticket feedback: rate the closed ticket and see the thanks', async ({ page, context }) => {
    test.fail(true, 'BUG: ticketfeedback/default/default.tpl:91 posts the feedback to ticketfeedback.php, which does not exist (WHMCS answers with its 404 page), so no feedback can be sent. Stock twenty-one ticketfeedback.tpl:58 posts to viewticket.php (PHP_SELF) with tid, c and feedback=1');
    await loginClient(context.request, 'full');
    try {
      await page.goto(`/viewticket.php?tid=${id.closedTicketTid}&c=${id.closedTicketC}&feedback=1`);
      expect(await tpl(page)).toBe('ticketfeedback');
      const form = page.locator('form[action*="ticketfeedback.php"]');
      // A rating per staff member who replied; the fixture's reply has none, so only the comment box.
      const stars = form.locator('input[type=radio][name^="rate["]');
      if (await stars.count()) await stars.last().check({ force: true });
      await form.locator('textarea[name="comments[generic]"]').fill('client-area.spec feedback');
      await form.locator('[type=submit]').click();
      await page.waitForLoadState('load');
      expect(await tpl(page)).toBe('ticketfeedback');
      await expect(page.locator('form[action*="ticketfeedback.php"]'), 'the form is gone once rated').toHaveCount(0);
      await expect(page.locator('.content-area')).toContainText(/thank/i);
    } finally {
      ca('delete-feedback', id.closedTicketTid);   // so the form shows again for the next test
    }
  });

  test('TH-106 the markdown guide fragment renders for the editor', async ({ context }) => {
    await loginClient(context.request, 'full');
    const r = await context.request.get('/submitticket.php?action=markdown');
    expect(r.headers()['content-type']).toMatch(/json/);
    const { body } = await r.json();
    expect(body, 'WHMCS wraps the rendered guide in JSON').toMatch(/\*\*|<code|<table/i);
    expect(inspect(`<html><body>${body}</body></html>`).problems).toEqual([]);
  });
});

// ======================================================================= TH-Q
test.describe('TH-Q Content, account, sign-in', () => {
  test('TH-107 knowledgebase: categories, an article, a helpful vote that counts once', async ({ page }) => {
    const before = ca('kb', id.kbArticleId);
    try {
      await page.goto('/knowledgebase.php');
      await page.locator('a.kb-card', { hasText: 'Getting started' }).click();
      await page.waitForURL(/knowledgebase\/\d+|displaycat/);
      expect(await tpl(page)).toBe('knowledgebasecat');
      await expect(page.locator('.content-area')).toContainText('Uploading your website with SFTP');
      await page.locator('.content-area a', { hasText: 'How do I point my domain at my hosting?' }).first().click();
      await page.waitForLoadState('load');
      expect(await tpl(page)).toBe('knowledgebasearticle');
      await expect(page.locator('.content-area')).toContainText('ns1.example.com');
      await page.locator('.helpful-btn.yes').click();
      await page.waitForLoadState('load');
      await expect(page.locator('.helpful-thanks'), 'thanked').toBeVisible();
      await expect(page.locator('.helpful-btn'), 'and cannot vote again').toHaveCount(0);
      const after = ca('kb', id.kbArticleId);
      expect(after.useful).toBe(before.useful + 1);
      expect(after.votes).toBe(before.votes + 1);
    } finally {
      ca('set-kb', id.kbArticleId, JSON.stringify({ useful: before.useful, votes: before.votes }));
    }
  });

  test('TH-107 the knowledgebase search box finds articles', async ({ page }) => {
    test.fail(true, 'BUG: knowledgebase/default/default.tpl:80 and knowledgebasecat/default/default.tpl:66 GET knowledgebase.php?search=..., which WHMCS 9 301s to /knowledgebase without the query; WHMCS searches by POST to routePath(knowledgebase-search) (stock twenty-one knowledgebase.tpl:1)');
    await page.goto('/index.php?rp=/knowledgebase');
    await page.locator('form.kb-hero-search input[name=search]').fill('nameservers');
    await page.locator('form.kb-hero-search input[name=search]').press('Enter');
    await page.waitForLoadState('load');
    await expect(page.locator('.content-area')).toContainText('How do I point my domain at my hosting?');
    await expect(page.locator('.content-area'), 'only the match').not.toContainText('Uploading your website with SFTP', { timeout: 3000 });
  });

  test('TH-107 announcements: open one and copy its link', async ({ page, context }) => {
    await context.grantPermissions(['clipboard-read', 'clipboard-write'], { origin: BASE_URL });
    await page.goto('/index.php?rp=/announcements');
    await page.locator(`.content-area a[href$="announcements.php?id=${id.announcementId}"]`).first().click();
    await page.waitForLoadState('load');
    expect(await tpl(page)).toBe('viewannouncement');
    await page.locator('[data-copy-link]').click();
    await expect.poll(() => page.evaluate(() => navigator.clipboard.readText())).toBe(page.url());
    await expect(page.locator('[data-copy-link]'), 'the button confirms').toContainText(/copied/i);
  });

  test('TH-107 the announcements RSS link serves the feed', async ({ page, context }) => {
    test.fail(true, 'BUG: announcements/default/default.tpl:64,82 and viewannouncement/default/default.tpl:78 link announcements.php?rss=true, which WHMCS 9 301s to the HTML announcements page; the feed is routePath(announcement-rss) = index.php?rp=/announcements/rss');
    await page.goto('/index.php?rp=/announcements');
    const href = await page.locator('a', { hasText: /rss/i }).first().getAttribute('href');
    const r = await context.request.get(href);
    expect(r.headers()['content-type']).toMatch(/rss|xml/);
  });

  test('TH-107 downloads: a category lists its file and the file downloads', async ({ page, context }) => {
    const before = ca('download', id.downloadId).downloads;
    try {
      await page.goto('/downloads.php');
      await page.locator('.content-area a', { hasText: 'Guides' }).first().click();
      await page.waitForLoadState('load');
      expect(await tpl(page)).toBe('downloadscat');
      const link = page.locator('a.dl-dl-btn').first();
      await expect(page.locator('.content-area')).toContainText('Getting started guide');
      const r = await context.request.get(await link.getAttribute('href'));
      expect(r.status()).toBe(200);
      expect(await r.text()).toContain('Hadrian test download');
    } finally { ca('set-download', id.downloadId, before); }
  });

  test('TH-108 server status: the issue tabs filter open, scheduled and resolved issues', async ({ page, context }) => {
    await loginClient(context.request, 'full');
    await page.goto('/serverstatus.php');
    const c = page.locator('.content-area');
    await expect(c).toContainText('Degraded email delivery');
    await page.locator('.ss-filter-tab', { hasText: /resolved/i }).click();
    await page.waitForURL(/view=resolved/);
    await expect(page.locator('.ss-filter-tab.active')).toContainText(/resolved/i);
    await expect(c).toContainText('Network outage in Frankfurt');
    await expect(c).not.toContainText('Degraded email delivery');
    await page.locator('.ss-filter-tab', { hasText: /scheduled/i }).click();
    await page.waitForURL(/view=scheduled/);
    await expect(c).toContainText('Scheduled maintenance: London storage');
    await expect(c).not.toContainText('Network outage in Frankfurt');
  });

  test('TH-109 TH-80 guest contact form refuses a send without the CAPTCHA and keeps what was typed', async ({ page }) => {
    await page.goto('/contact.php');
    await page.locator('#ct-name').fill('Guest Flowtest');
    await page.locator('#ct-email').fill('flow+contactguest@demo.hadrian.test');
    await page.locator('#ct-subject').fill('[flow] guest contact');
    await page.locator('#ct-message').fill('Sent by client-area.spec without solving the CAPTCHA.');
    await page.locator('input.mt-captcha-code').fill('000000');
    await page.locator('form.ct-form [type=submit]').click();
    await page.waitForLoadState('load');
    expect(await tpl(page)).toBe('contact');
    await expect(page.locator('.content-area'), 'the CAPTCHA error').toContainText(/characters|verification|captcha|incorrect/i);
    await expect(page.locator('#ct-name')).toHaveValue('Guest Flowtest');
    await expect(page.locator('#ct-message')).toHaveValue(/without solving/);
  });

  test('TH-111 account details save and read back', async ({ page, context }) => {
    const t = await throwaway(context);
    try {
      await page.goto('/clientarea.php?action=details');
      await page.locator('#ad-addr2').fill('Suite 9');
      await page.locator('#ad-city').fill('Dallas');
      await page.locator('.content-area form[action*="action=details"] [type=submit]').click();
      await page.waitForLoadState('load');
      await page.goto('/clientarea.php?action=details');
      await expect(page.locator('#ad-addr2')).toHaveValue('Suite 9');
      await expect(page.locator('#ad-city')).toHaveValue('Dallas');
      expect(ca('client', t.clientId).address2).toBe('Suite 9');
    } finally { t.remove(); }
  });

  test('TH-111 saving account details confirms the save and reports a refused one', async ({ page, context }) => {
    test.fail(true, 'BUG: clientareadetails/default/default.tpl never prints $successful or $errormessage (stock twenty-one clientareadetails.tpl:1-6 does), so a save gives no confirmation and a save WHMCS refuses (e.g. a required field left blank) fails silently');
    const t = await throwaway(context);
    try {
      await page.goto('/clientarea.php?action=details');
      await page.locator('#ad-addr2').fill('Suite 10');
      await page.locator('.content-area form[action*="action=details"] [type=submit]').click();
      await page.waitForLoadState('load');
      await expect(page.locator('.content-area'), 'a saved notice').toContainText(/saved successfully/i, { timeout: 3000 });
      // A blank first name gets past the browser (required removed) and WHMCS refuses it.
      await page.locator('#ad-first').evaluate(e => { e.removeAttribute('required'); e.value = ''; });
      await page.locator('.content-area form[action*="action=details"] [type=submit]').click();
      await page.waitForLoadState('load');
      await expect(page.locator('.content-area'), 'the refusal is explained').toContainText(/first name/i, { timeout: 3000 });
    } finally { t.remove(); }
  });

  test('TH-111 account details email preferences are saved and shown', async ({ page, context }) => {
    test.fail(true, 'BUG: clientareadetails/default/default.tpl:160-185 hardcodes the preference boxes (invoice/support/product/domain always checked, affiliate never) and posts them as emailoptout_<type>, which WHMCS 9 ignores; it reads email_preferences[<type>] (stock twenty-one clientareadetails.tpl:172-173). A customer cannot change or even see their email preferences');
    const t = await throwaway(context);
    try {
      await page.goto('/clientarea.php?action=details');
      await page.locator('#ad-pref-domain').uncheck();
      await page.locator('.content-area form[action*="action=details"] [type=submit]').click();
      await page.waitForLoadState('load');
      await page.goto('/clientarea.php?action=details');
      await expect(page.locator('#ad-pref-domain'), 'domain emails stay off').not.toBeChecked({ timeout: 3000 });
    } finally { t.remove(); }
  });

  test('TH-81 the phone field shows a stored number as national digits with its country dial code', async ({ page, context }) => {
    const errors = watchErrors(page);
    await loginClient(context.request, 'full');
    // The fixture contact's number is stored as +44.1179460001.
    await page.goto(`/index.php?rp=/account/contacts&contactid=${id.contactId}`);
    const f = page.locator('form.ct-form');
    await expect(f.locator('.iti'), 'intl-tel-input initialised').toBeAttached({ timeout: 20_000 });
    await expect(f.locator('input[name=country-calling-code-phonenumber]'), 'the hidden dial code').toHaveValue('44');
    await expect(f.locator('#ct-phone'), 'the national number, not "+44.117..."').toHaveValue(/^0?117\s?946\s?0001$/);
    await expect(f.locator('.iti__selected-dial-code, .iti__selected-flag').first()).toBeAttached();
    expect(errors).toEqual([]);
  });

  test('TH-111 TH-81 adding a contact creates it', async ({ page, context }) => {
    test.fail(true, 'BUG: account-contacts-new/default/default.tpl:63 posts the new contact to routePath(account-contacts-save) with contactid=new; WHMCS replies "Contact updated successfully!" and creates nothing. Stock twenty-one account-contacts-new.tpl:37 posts to routePath(account-contacts-new)');
    const t = await throwaway(context);
    try {
      await page.goto('/index.php?rp=/account/contacts');
      expect(await tpl(page)).toBe('account-contacts-new');
      const f = page.locator('form.ct-form');
      await expect(f.locator('.iti')).toBeAttached({ timeout: 20_000 });
      await f.locator('select[name=country]').selectOption('GB');
      await expect(f.locator('input[name=country-calling-code-phonenumber]'), 'the dial code follows the country').toHaveValue('44');
      await f.locator('#ct-first').fill('Pat');
      await f.locator('#ct-last').fill('Contact');
      await f.locator('#ct-email').fill(`flow+ca-contact${Date.now()}@demo.hadrian.test`);
      await f.locator('#ct-phone').fill('7400 123456');
      await f.locator('#ct-phone').blur();
      await f.locator('#ct-addr1').fill('1 Spec Street');
      await f.locator('#ct-city').fill('Leeds');
      await f.locator('#ct-state').fill('West Yorkshire');
      await f.locator('#ct-zip').fill('LS1 1AA');
      await f.locator('[type=submit][name=save]').click();
      await page.waitForLoadState('load');
      expect(ca('client', t.clientId).contacts, 'the contact was created').toBe(1);
    } finally { t.remove(); }
  });

  test('TH-111 a contact is edited and deleted', async ({ page, context }) => {
    const errors = watchErrors(page);
    const t = await throwaway(context);
    try {
      const { contactId } = ca('add-contact', t.clientId);
      await page.goto(`/index.php?rp=/account/contacts&contactid=${contactId}`);
      expect(await tpl(page)).toBe('account-contacts-manage');
      await expect(page.locator('#ct-first')).toHaveValue('Pat');
      await page.locator('#ct-city').fill('York');
      await page.locator('form.ct-form [type=submit][name=save]').click();
      await page.waitForLoadState('load');
      await expect(page.locator('.ct-alert-success')).toBeVisible();
      await page.goto(`/index.php?rp=/account/contacts&contactid=${contactId}`);
      await expect(page.locator('#ct-city'), 'the edit is saved').toHaveValue('York');

      page.once('dialog', d => d.accept());
      await page.locator('[data-ct-delete]').click();
      await page.waitForLoadState('load');
      expect(await auth(page)).toBe('in');
      expect(ca('client', t.clientId).contacts, 'and deleted').toBe(0);
      expect(errors).toEqual([]);
    } finally { t.remove(); }
  });

  test('TH-81 re-saving a contact keeps its phone number intact', async ({ page, context }) => {
    test.fail(true, 'BUG: account-contacts-manage/default/default.tpl:232 (and account-contacts-new :200) show the number in intl-tel-input\'s national format with the trunk prefix ("07400 123456") and submit that, so saving the contact for any reason stores +44.07400 123456 for +44.7400123456. Stock twenty-one shows "7400 123456" and stores +44.7400 123456');
    const t = await throwaway(context);
    try {
      const { contactId } = ca('add-contact', t.clientId);   // +44.7400123456
      await page.goto(`/index.php?rp=/account/contacts&contactid=${contactId}`);
      await expect(page.locator('form.ct-form .iti')).toBeAttached({ timeout: 20_000 });
      await page.locator('#ct-city').fill('York');
      await page.locator('form.ct-form [type=submit][name=save]').click();
      await page.waitForLoadState('load');
      const html = await (await context.request.get(`/index.php?rp=/account/contacts&contactid=${contactId}`)).text();
      const stored = (html.match(/id="ct-phone"[^>]*value="([^"]*)"|value="([^"]*)"[^>]*id="ct-phone"/) || []).slice(1).join('');
      expect(stored.replace(/\D/g, ''), `stored "${stored}"`).toBe('447400123456');
    } finally { t.remove(); }
  });

  test('TH-111 TH-114 invite a user, they accept, their permissions are changed', async ({ page, context, browser }) => {
    test.setTimeout(3 * 60_000);
    const owner = await throwaway(context);
    const ctx2 = await browser.newContext();
    const guest = await throwaway(ctx2);
    const toggle = key => page.locator(`label.perm-toggle:has(input[name="perms[${key}]"])`);
    try {
      await page.goto('/index.php?rp=/account/users');
      await page.locator('[data-um-invite-open]').click();
      const since = Date.now();
      await page.locator('#umInviteEmail').fill(guest.email);
      await page.locator('input[name=permissions][value=choose]').check();
      await page.locator('input[name="perms[profile]"]').check();
      await page.locator('input[name="perms[invoices]"]').check();
      await page.locator('form.um-modal-form [type=submit]').click();
      await page.waitForLoadState('load');
      await expect(page.locator('.um-row-invite', { hasText: guest.email }), 'listed as pending').toBeVisible();
      expect(ca('client', owner.clientId).invites).toBe(1);

      const mail = await mailTo(guest.email, since);
      const link = mail.links.find(l => /invite\//.test(l));
      expect(link, `invite link in "${mail.subject}"`).toBeTruthy();
      const p2 = await ctx2.newPage();
      await p2.goto(link.replace(/^https?:\/\/[^/]+/, BASE_URL));
      expect(await p2.evaluate(() => document.body.dataset.tpl)).toBe('user-invite-accept');
      await p2.locator('form.uia-actions [type=submit]').click();
      await p2.waitForLoadState('load');
      expect(await p2.evaluate(() => document.body.dataset.auth)).toBe('in');

      await page.reload();
      await expect(page.locator('.um-row-invite'), 'no longer pending').toHaveCount(0);
      const row = page.locator('.um-row:not(.um-row-owner)', { hasText: guest.email });
      await expect(row).toBeVisible();
      const permsUrl = await row.locator('a.um-row-btn[href*="permissions"]').getAttribute('href');
      await row.locator('a.um-row-btn[href*="permissions"]').click();
      await page.waitForLoadState('load');
      expect(await tpl(page)).toBe('account-user-permissions');
      await expect(page.locator('input[name="perms[invoices]"]'), 'the invite\'s permissions').toBeChecked();
      await expect(page.locator('input[name="perms[tickets]"]')).not.toBeChecked();
      await toggle('invoices').click();
      await toggle('tickets').click();
      await expect(page.locator('input[name="perms[invoices]"]')).not.toBeChecked();
      await page.locator('.content-area form [type=submit]').click();
      await page.waitForLoadState('load');
      await page.goto(permsUrl);
      await expect(page.locator('input[name="perms[invoices]"]'), 'saved: invoices off').not.toBeChecked();
      await expect(page.locator('input[name="perms[tickets]"]'), 'saved: tickets on').toBeChecked();
    } finally {
      // Records first: on a timeout the context close throws and nothing after it runs.
      owner.remove();
      guest.remove();
      await ctx2.close();
    }
  });

  test('TH-111 a pending invite can be cancelled', async ({ page, context }) => {
    const t = await throwaway(context);
    try {
      await page.goto('/index.php?rp=/account/users');
      await page.locator('[data-um-invite-open]').click();
      await page.locator('#umInviteEmail').fill(`flow+ca-invitee${Date.now()}@demo.hadrian.test`);
      await page.locator('form.um-modal-form [type=submit]').click();
      await page.waitForLoadState('load');
      await expect(page.locator('.um-row-invite')).toHaveCount(1);
      page.once('dialog', d => d.accept());
      await page.locator('[data-um-cancel-invite]').click();
      await page.waitForLoadState('load');
      await expect(page.locator('.um-row-invite'), 'gone').toHaveCount(0);
      expect(ca('client', t.clientId).invites).toBe(0);
    } finally { t.remove(); }
  });

  test('TH-111 profile name change is saved', async ({ page, context }) => {
    const t = await throwaway(context);
    try {
      await page.goto('/index.php?rp=/user/profile');
      await page.locator('#up-first').fill('Robin');
      await page.locator('form[action*="profile/save"] [type=submit]').click();
      await page.waitForLoadState('load');
      await expect(page.locator('.up-alert-success')).toBeVisible();
      await expect(page.locator('#up-first')).toHaveValue('Robin');
      expect(ca('client', t.clientId).firstname).toBe('Robin');
      await expect(page.locator('aside.sidebar .sidebar-user-name'), 'the sidebar shows the client, not the user').toHaveText('Casey Flowtest');
    } finally { t.remove(); }
  });

  test('TH-111 Change Password changes the password', async ({ page, context }) => {
    test.fail(true, 'BUG: user-password/default/default.tpl:55 posts to clientarea.php?action=changepw, which WHMCS 9 302s to /user/password without processing it: no message, and the old password still works. Stock twenty-one user-password.tpl:7 posts to routePath(user-password)');
    const t = await throwaway(context);
    try {
      const fresh = `Ca!${crypto.randomBytes(9).toString('base64url')}7z`;
      await page.goto('/index.php?rp=/user/password');
      await page.locator('#cp-existing').fill(t.password);
      await page.locator('#cp-new').fill(fresh);
      await page.locator('#cp-confirm').fill(fresh);
      await page.locator('form.cp-form [type=submit]').click();
      await page.waitForLoadState('load');
      await context.clearCookies();
      await signIn(page, t.email, fresh);
      expect(await auth(page), 'the new password signs in').toBe('in');
    } finally { t.remove(); }
  });

  test('TH-112 two-factor: turn TOTP on, then off again with the password', async ({ page, context }) => {
    test.setTimeout(2 * 60_000);
    const t = await throwaway(context);
    try {
      await page.goto('/index.php?rp=/user/security');
      await page.locator('[data-tfa-open][data-tfa-url*="enable"]').click();
      const modal = page.locator('.tfa-modal.open');
      const next = modal.locator('[data-tfa-submit]');
      await modal.locator('.twofa-module').filter({ hasText: /time based/i }).first().click();
      await next.click();
      await expect(modal.locator('.tfa-modal-body')).toContainText(/[A-Z2-7]{16,}/, { timeout: 20_000 });
      const secret = (await modal.locator('.tfa-modal-body').innerText()).replace(/\s+/g, ' ').match(/\b([A-Z2-7]{16,})\b/)[1];
      await modal.locator('.tfa-modal-body input[type=text]:visible, .tfa-modal-body input[name=key]').first().fill(totp(secret));
      await (await next.isVisible() ? next : modal.locator('.tfa-modal-body [type=submit]').first()).click();
      await expect(modal.locator('.tfa-modal-body')).toContainText(/backup code/i, { timeout: 20_000 });
      await next.click();
      await page.waitForLoadState('load');
      await expect(page.locator('.tfa-status-pill.on')).toBeVisible();
      expect(ca('client', t.clientId).secondFactor).toBe('totp');

      await page.locator('[data-tfa-open][data-tfa-url*="disable"]').click();
      const off = page.locator('.tfa-modal.open');
      await off.locator('.tfa-modal-body input[type=password]').first().fill(t.password, { timeout: 20_000 });
      await off.locator('[data-tfa-submit]').click();
      await expect(off.locator('.tfa-modal-body')).toContainText(/disabled|turned off|success/i, { timeout: 20_000 });
      if (await off.locator('[data-tfa-submit]').isVisible()) await off.locator('[data-tfa-submit]').click();
      await page.goto('/index.php?rp=/user/security');
      await expect(page.locator('.tfa-status-pill.on'), 'two-factor is off').toHaveCount(0);
      expect(ca('client', t.clientId).secondFactor).toBe('');
      // Signing in again asks for no code.
      await context.clearCookies();
      await signIn(page, t.email, t.password);
      expect(await tpl(page)).toBe('clientareahome');
    } finally { t.remove(); }
  });

  test('TH-113 a user on two accounts switches between them', async ({ page }) => {
    const p = creds.personas.multi;
    await signIn(page, p.email, p.password);
    if (await tpl(page) !== 'user-switch-account') await page.goto('/index.php?rp=/user/accounts');
    await page.locator(`.sw-row[data-sw-id="${creds.personas.suspended.clientId}"]`).click();
    await page.waitForLoadState('load');
    expect(await tpl(page)).toBe('clientareahome');
    const nameA = await page.locator('aside.sidebar .sidebar-user-name').innerText();
    await page.locator('.sidebar-user').click();
    await page.locator('#profileDropdownSidebar a[href*="/user/accounts"]').click();
    await page.waitForLoadState('load');
    expect(await tpl(page)).toBe('user-switch-account');
    await page.locator(`.sw-row[data-sw-id="${creds.personas.full.clientId}"]`).click();
    await page.waitForLoadState('load');
    await expect(page.locator('aside.sidebar .sidebar-user-name'), 'now the other account').not.toHaveText(nameA);
    await expect(page.locator('.tile-variant[data-variant=a] .tile', { hasText: 'Domains' }).locator('.tile-value'), 'its records').toHaveText('1');
  });

  test('TH-114 TH-05 verifying the email address: the emailed link confirms it and the banner goes', async ({ page, context }) => {
    const t = await throwaway(context);
    try {
      await page.goto('/clientarea.php');
      await expect(page.locator('#mtVerifyBanner')).toBeVisible();
      const since = Date.now();
      await page.locator('#mtVerifyBanner [data-mt-resend]').click();
      await expect(page.locator('#mtVerifyBanner [data-mt-resend]')).toHaveText(/sent/i);
      const mail = await mailTo(t.email, since);
      const link = mail.links.find(l => /user\/verify\//.test(l));
      expect(link).toBeTruthy();
      await page.goto(link.replace(/^https?:\/\/[^/]+/, BASE_URL));
      expect(await tpl(page)).toBe('user-verify-email');
      await expect(page.locator('.content-area')).toContainText(/verified|success|thank/i);
      expect(ca('client', t.clientId).verified).toBe(true);
      await page.goto('/clientarea.php');
      await expect(page.locator('#mtVerifyBanner'), 'no banner once verified').toHaveCount(0);
    } finally { t.remove(); }
  });

  /** Opt the throwaway out through the link WHMCS mails; returns that link. */
  async function optOut(page, t) {
    const since = Date.now();
    ca('send-unsubscribe', t.clientId);
    const mail = await mailTo(t.email, since);
    const link = mail.links.find(l => /rp=\/subscription.*action=optout/.test(l));
    expect(link, `an opt-out link in "${mail.subject}"`).toBeTruthy();
    await page.goto(link.replace(/^https?:\/\/[^/]+/, BASE_URL));
    return link;
  }

  test('TH-115 marketing emails: the emailed opt-out link unsubscribes; a tampered link is refused', async ({ page, context }) => {
    const t = await throwaway(context, { signIn: false });
    try {
      expect(ca('client', t.clientId).marketing).toBe(1);
      const link = await optOut(page, t);
      expect(await tpl(page)).toBe('subscription-manage');
      await expect(page.locator('.sm-title')).toHaveText(/unsubscribed/i);
      await expect(page.locator('.sm-ico.warn')).toBeVisible();
      expect(ca('client', t.clientId).marketing, 'opted out').toBe(0);
      await page.goto(link.replace(/^https?:\/\/[^/]+/, BASE_URL).replace(/key=[0-9a-f]+/, 'key=0000'));
      expect(await tpl(page)).toBe('subscription-manage');
      await expect(page.locator('.sm-ico.error'), 'the error state').toBeVisible();
    } finally { t.remove(); }
  });

  test('TH-115 an unsubscribed customer can join the mailing list again from Account Details', async ({ page, context }) => {
    test.fail(true, 'BUG: clientareadetails/default/default.tpl has no "Join our mailing list" (marketingoptin) control for $showMarketingEmailOptIn (stock twenty-one clientareadetails.tpl:182-187 has), yet subscription-manage/default/default.tpl sends opted-out customers to Account Details to re-subscribe');
    const t = await throwaway(context);
    try {
      await optOut(page, t);
      expect(ca('client', t.clientId).marketing).toBe(0);
      await page.locator('.sm-text a[href*="action=details"]').click();
      await page.waitForLoadState('load');
      expect(await tpl(page)).toBe('clientareadetails');
      await page.locator('input[name=marketingoptin]').check({ timeout: 3000 });
      await page.locator('.content-area form[action*="action=details"] [type=submit]').click();
      await page.waitForLoadState('load');
      expect(ca('client', t.clientId).marketing, 'subscribed again').toBe(1);
    } finally { t.remove(); }
  });

  test('TH-116 affiliates: the referral link copies; with the affiliate system off a customer is told so', async ({ page, context, browser }) => {
    test.setTimeout(2 * 60_000);
    await context.grantPermissions(['clipboard-read', 'clipboard-write'], { origin: BASE_URL });
    await loginClient(context.request, 'full');
    await page.goto('/affiliates.php');
    expect(await tpl(page)).toBe('affiliates');
    const link = await page.locator('#affRefLink').inputValue();
    expect(link).toMatch(/aff\.php\?aff=\d+$/);
    await page.locator('.aff-copy-btn').click();
    await expect.poll(() => page.evaluate(() => navigator.clipboard.readText())).toBe(link);
    await expect(page.locator('.aff-copy-btn'), 'the button confirms').toHaveText(/copied/i);
    await expect(page.locator('.aff-withdraw-btn'), 'nothing to withdraw below the payout minimum').toBeDisabled();

    // AffiliateEnabled is off on this install (a setting), so sign-up shows the
    // "not offered" state instead of the Activate button.
    const ctx2 = await browser.newContext();
    try {
      await loginClient(ctx2.request, 'empty');
      const p2 = await ctx2.newPage();
      await p2.goto('/affiliates.php');
      expect(await p2.evaluate(() => document.body.dataset.tpl)).toBe('affiliatessignup');
      await expect(p2.locator('.aff-disabled-title')).toBeVisible();
      await expect(p2.locator('form.aff-signup-form'), 'no sign-up while the system is off').toHaveCount(0);
    } finally { await ctx2.close(); }
  });

  test('TH-117 sign in with "remember me" survives losing the session cookie; Sign Out ends it', async ({ page, context }) => {
    const t = await throwaway(context, { signIn: false });
    try {
      await signIn(page, t.email, t.password, { remember: true });
      expect(await auth(page)).toBe('in');
      const later = Date.now() / 1000 + 20 * 86400;
      const jar = await context.cookies();
      const remember = jar.filter(c => c.expires > later);
      expect(remember.length, `a long-lived cookie (${jar.map(c => c.name).join(', ')})`).toBeGreaterThan(0);
      // Drop the session cookie(s): only the remember-me cookie is left.
      await context.clearCookies();
      await context.addCookies(remember);
      await page.goto('/clientarea.php');
      expect(await auth(page), 'signed back in from the remember-me cookie').toBe('in');

      await page.locator('.sidebar-user').click();
      await page.locator('#profileDropdownSidebar a[href$="logout.php"]').click();
      await page.waitForLoadState('load');
      expect(await auth(page)).toBe('out');
      await page.goto('/clientarea.php');
      expect(await auth(page), 'and the remember-me cookie no longer signs in').toBe('out');
      expect(await tpl(page)).toBe('login');
    } finally { t.remove(); }
  });

  test('TH-118 TH-80 the sign-up form refuses a guest without the CAPTCHA and keeps the entries', async ({ page }) => {
    await page.goto('/register.php');
    const f = page.locator('#frmRegister');
    await f.locator('#cr-first').fill('Reg');
    await f.locator('#cr-last').fill('Captcha');
    await f.locator('#cr-email').fill(`flow+cap${Date.now()}@demo.hadrian.test`);
    await f.locator('#cr-phone').fill('2025550143');
    await f.locator('#cr-addr1').fill('1 Test Street');
    await f.locator('#cr-city').fill('Austin');
    await f.locator('#cr-state').fill('TX');
    await f.locator('#cr-zip').fill('78701');
    await f.locator('#cr-pw1').fill('FlowTest!2026x');
    await f.locator('#cr-pw2').fill('FlowTest!2026x');
    await f.locator('input.mt-captcha-code').fill('000000');
    await f.locator('.cr-submit').click();
    await page.waitForLoadState('load');
    expect(await tpl(page)).toBe('clientregister');
    expect(await auth(page), 'no account without the CAPTCHA').toBe('out');
    await expect(page.locator('.content-area')).toContainText(/characters|verification|captcha|incorrect/i);
    await expect(page.locator('#cr-first'), 'entries kept').toHaveValue('Reg');
    await expect(page.locator('#cr-city')).toHaveValue('Austin');
  });

  test('TH-119 password reset: an emailed link sets a new password; a forged link is refused', async ({ page, context }) => {
    test.setTimeout(2 * 60_000);
    const t = await throwaway(context, { signIn: false });
    try {
      await page.goto('/index.php?rp=/password/reset/redeem/not-a-real-token');
      await page.waitForLoadState('load');
      await expect(page.locator('input[type=password]:visible'), 'a forged link offers no new-password form').toHaveCount(0);

      await page.goto('/index.php?rp=/password/reset');
      const since = Date.now();
      await page.locator('#pw-email').fill(t.email);
      await page.locator('form.pw-form [type=submit]').click();
      await page.waitForLoadState('load');
      await expect(page.locator('.content-area, main').first()).toContainText(/email|sent|check/i);
      const mail = await mailTo(t.email, since);
      const link = mail.links.find(l => /password\/reset\/redeem/.test(l));
      expect(link).toBeTruthy();
      await page.goto(link.replace(/^https?:\/\/[^/]+/, BASE_URL));
      const fresh = `Ca!${crypto.randomBytes(9).toString('base64url')}5q`;
      await page.locator('input[type=password]:visible').first().fill(fresh);
      await page.locator('input[type=password]:visible').nth(1).fill(fresh);
      await page.locator('form:has(input[type=password]) [type=submit]:visible').first().click();
      await page.waitForLoadState('load');
      expect(await auth(page)).toBe('in');
      await context.clearCookies();
      await signIn(page, t.email, fresh);
      expect(await auth(page)).toBe('in');
      // The link is single-use.
      await context.clearCookies();
      await page.goto(link.replace(/^https?:\/\/[^/]+/, BASE_URL));
      await expect(page.locator('input[type=password]:visible'), 'a used link is refused').toHaveCount(0);
    } finally { t.remove(); }
  });
});

// ======================================================================= TH-R
test.describe('TH-R Error and dead-end pages', () => {
  test('TH-120 an unknown address renders the theme\'s 404 page inside the chrome, and Back to home works', async ({ page, context }) => {
    const r = await page.goto('/index.php?rp=/no-such-page');
    expect(r.status()).toBe(404);
    expect(await tpl(page)).toBe('error/page-not-found');
    await expect(page.locator('.error-page h1')).toHaveText(/not found/i);
    await expect(page.locator('aside.sidebar'), 'with the site navigation').toBeVisible();
    await page.locator('.error-page a.btn-primary').click();
    await page.waitForURL(u => new URL(u).pathname === '/');
    expect(await tpl(page)).toBe('homepage');

    const r2 = await page.goto('/no-such-file.php');
    expect(r2.status()).toBe(404);
    expect(await tpl(page), 'a missing .php file too').toBe('error/page-not-found');

    await loginClient(context.request, 'full');
    await page.goto('/index.php?rp=/no-such-page');
    expect(await auth(page), 'a signed-in client stays signed in on it').toBe('in');
    await expect(page.locator('.error-page h1')).toBeVisible();
  });

  test('TH-121 access denied and download denied explain themselves and lead back', async ({ page, context, browser }) => {
    await loginClient(context.request, 'full');
    await page.goto(`/dl.php?type=d&id=${id.restrictedDownloadId}`);
    expect(await tpl(page)).toBe('downloaddenied');
    await expect(page.locator('.content-area h1')).toBeVisible();
    const ctx2 = await browser.newContext();
    try {
      await loginClient(ctx2.request, 'subuser');
      const p2 = await ctx2.newPage();
      await p2.goto('/clientarea.php?action=invoices');
      expect(await p2.evaluate(() => document.body.dataset.tpl)).toBe('access-denied');
      expect(await p2.evaluate(() => document.body.dataset.auth), 'still signed in').toBe('in');
      const back = p2.locator('.content-area a.btn-primary, .content-area a.btn-secondary').first();
      await expect(back).toBeVisible();
      await back.click();
      await p2.waitForLoadState('load');
      expect(await p2.evaluate(() => document.body.dataset.tpl)).not.toBe('access-denied');
    } finally { await ctx2.close(); }
  });
});
