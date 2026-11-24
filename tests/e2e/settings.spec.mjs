// Tier 3c (settings) - every admin setting, layout and page variant, switched
// on for real and checked in Chromium.
//
// The other tiers only ever see the settings the local admin happens to have
// saved - all defaults on this install - so a setting that broke a page, or
// stopped doing anything, was invisible to them. Each test here:
//   1. writes the setting straight into hadrian_settings / hadrian_pages
//      (tests/php/settings.php; snapshot taken before, restored after EVERY
//      test, and by the preflight if a run dies halfway)
//   2. loads the pages it affects and asserts the EFFECT (an attribute, an
//      element, a changed price label), not merely that the page loads
//   3. judges those pages like the browser tier: oracles, JS errors, failed
//      assets, overflow, unreadable text
//
// One worker, in its own run.mjs step (--workers=1): a changed setting is
// visible to every request, so nothing else may run against the site at the
// same time. Not 'serial' mode: one failing setting must not skip the rest.

import { test, expect } from '@playwright/test';
import { execFileSync } from 'node:child_process';
import path from 'node:path';
import { PHP, TESTS_DIR, BASE_URL } from '../lib/env.mjs';
import { fx, loginClient, loginAdmin } from './helpers.mjs';
import { watch, judge } from './page-checks.mjs';

const id = fx.ids;

const php = (...args) => execFileSync(PHP, [path.join(TESTS_DIR, 'php', 'settings.php'), ...args], { encoding: 'utf8' });
const set = obj => php('set', JSON.stringify(obj));
const variant = obj => php('variant', JSON.stringify(obj));
const on = ['1', 'bool'], off = ['0', 'bool'];
const str = v => [v, 'string'];

test.beforeAll(() => { php('snapshot'); });
test.afterEach(() => { php('restore'); php('snapshot'); });   // every test starts from the original settings
test.afterAll(() => { php('restore'); });

const bodyAttr = (page, name) => page.evaluate(n => document.body.getAttribute(n), name);

/** Load each url as `persona`, judge it, fail on anything found. */
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

// ---------------------------------------------------------------- body flags
// Flags that header.tpl turns into a body attribute for the CSS to act on.
const BODY_FLAGS = [
  ['hide_breadcrumb', 'data-hide-breadcrumb', '1', 'full', '/clientarea.php?action=services'],
  ['affixed_navigation', 'data-affixed-nav', '1', 'guest', '/'],
  ['unpin_sidebar', 'data-unpin-sidebar', '1', 'full', '/clientarea.php'],
  ['hide_cycle_discounts', 'data-hide-discounts', '1', 'guest', `/cart.php?a=add&pid=${id.serverProductId}`],
  ['free_label', 'data-free-label', '1', 'guest', '/index.php?rp=/store/openpanel-hosting'],
];
for (const [flag, attr, value, persona, url] of BODY_FLAGS) {
  test(`${flag}: on sets ${attr}, off leaves it out`, async ({ page, context }) => {
    await loginClient(context.request, persona);
    set({ [flag]: on });
    await page.goto(url);
    expect(await bodyAttr(page, attr), `${flag} on`).toBe(value);
    await clean(page, context, persona, [url]);
    set({ [flag]: off });
    await page.goto(url);
    expect(await bodyAttr(page, attr), `${flag} off`).toBeNull();
  });
}

for (const layout of ['sidebar', 'top']) {
  test(`hide_breadcrumb: no trail drawn in the ${layout} layout`, async ({ page, context }) => {
    // Two render sites: .ph-side-crumbs (side/rail topbar) and .ph-breadcrumb (top nav).
    await loginClient(context.request, 'full');
    set({ 'hadrian_active_layout_main-menu_client': str(layout) });
    const visibleCrumbs = () => page.evaluate(() => [...document.querySelectorAll('.ph-breadcrumb, .ph-side-crumbs')]
      .filter(e => e.getBoundingClientRect().height > 0 && getComputedStyle(e).visibility !== 'hidden').length);
    await page.goto('/clientarea.php?action=services');
    expect(await visibleCrumbs(), 'a trail to hide by default').toBeGreaterThan(0);
    set({ hide_breadcrumb: on });
    await page.goto('/clientarea.php?action=services');
    expect(await visibleCrumbs()).toBe(0);
  });
}

test('unpin_sidebar: the sidebar scrolls with the page', async ({ page, context }) => {
  await loginClient(context.request, 'full');
  const pos = () => page.evaluate(() => { const s = document.querySelector('.sidebar'); return s && getComputedStyle(s).position; });
  await page.goto('/clientarea.php');
  const pinned = await pos();
  test.skip(!pinned, 'no sidebar in the active layout');
  set({ unpin_sidebar: on });
  await page.goto('/clientarea.php');
  expect(await pos(), `pinned it was "${pinned}"`).not.toBe(pinned);
});

test('capitalize_titles: off stops uppercasing the homepage eyebrows', async ({ page }) => {
  // Scope is marketing/store section labels only: the sidebar's group labels
  // and the locale modal stay uppercase by design (SettingsController FLAGS).
  const upper = () => page.evaluate(() => [...document.querySelectorAll('.content-area *')]
    .filter(e => e.children.length === 0 && e.textContent.trim() && getComputedStyle(e).textTransform === 'uppercase').length);
  await page.goto('/');
  expect(await bodyAttr(page, 'data-capitalize-titles')).toBeNull();
  const before = await upper();
  expect(before, 'the homepage has uppercase eyebrows to begin with').toBeGreaterThan(0);
  set({ capitalize_titles: off });
  await page.goto('/');
  expect(await bodyAttr(page, 'data-capitalize-titles')).toBe('0');
  expect(await upper(), `uppercase labels before: ${before}`).toBe(0);
});

test('free_label: free plans read "Free" instead of 0.00', async ({ page }) => {
  const priceText = () => page.locator('.content-area').innerText();
  await page.goto('/index.php?rp=/store/openpanel-hosting');
  expect(await priceText()).toMatch(/0\.00/);
  set({ free_label: on });
  await page.goto('/index.php?rp=/store/openpanel-hosting');
  const text = await priceText();
  expect(text).toMatch(/free/i);   // WHMCS's own $LANG.orderfree: "FREE!"
  expect(text, 'no "0.00" left once relabelled').not.toMatch(/\$0\.00/);
});

test('service_controls_outside: card titles move outside the card', async ({ page, context }) => {
  await loginClient(context.request, 'full');
  set({ service_controls_outside: on });
  await page.goto('/clientarea.php?action=services');
  expect(await bodyAttr(page, 'data-svc-layout')).toBe('outside');
  await clean(page, context, 'full', ['/clientarea.php?action=services', '/clientarea.php?action=domains', '/supporttickets.php', '/clientarea.php?action=details']);
});

for (const width of ['boxed', 'full']) {
  test(`content_width=${width}`, async ({ page, context }) => {
    set({ content_width: str(width) });
    await page.goto('/');
    expect(await bodyAttr(page, 'data-content-width')).toBe(width === 'boxed' ? null : width);
    await clean(page, context, 'full', ['/clientarea.php', '/clientarea.php?action=invoices']);
  });
}

// ---------------------------------------------------------------- elements
test('cookie_box: shows after its delay, at the chosen position, and stays dismissed', async ({ page }) => {
  await page.goto('/');
  await expect(page.locator('#mtCookieBar')).toHaveCount(0);
  set({ cookie_box: on, cookie_box_position: str('bottom-right'), cookie_box_button: str('Got it') });
  await page.goto('/');
  const bar = page.locator('#mtCookieBar');
  await expect(bar).toBeVisible({ timeout: 6000 });
  await expect(bar).toHaveClass(/mt-cookie-bar--bottom-right/);
  await expect(bar.locator('[data-cookie-accept]')).toHaveText('Got it');
  await bar.locator('[data-cookie-accept]').click();
  await expect(bar).toBeHidden();
  await page.reload();
  await page.waitForTimeout(2500);
  await expect(page.locator('#mtCookieBar'), 'dismissed bar does not come back').toBeHidden();
});

test('back_to_top: appears after scrolling and scrolls back up', async ({ page }) => {
  await page.goto('/');
  await expect(page.locator('#mtBackToTop')).toHaveCount(0);
  set({ back_to_top: on });
  await page.goto('/');
  const btn = page.locator('#mtBackToTop');
  await expect(btn).toBeHidden();
  await page.mouse.wheel(0, 2500);
  await expect(btn).toBeVisible();
  await btn.click();
  await expect.poll(() => page.evaluate(() => scrollY), { timeout: 5000 }).toBeLessThan(10);
});

test('enable_alternate_links: hreflang links in the head, only when on', async ({ page }) => {
  const count = () => page.locator('head link[rel="alternate"][hreflang]').count();
  set({ enable_alternate_links: on });
  await page.goto('/');
  expect(await count()).toBeGreaterThan(1);
  set({ enable_alternate_links: off });
  await page.goto('/');
  expect(await count()).toBe(0);
});

test('hide_language_switcher + hide_currency_selector: no locale button', async ({ page }) => {
  await page.goto('/');
  expect(await page.locator('[data-locale-open]').count(), 'locale button by default').toBeGreaterThan(0);
  set({ hide_language_switcher: on, hide_currency_selector: on });
  await page.goto('/');
  expect(await page.locator('[data-locale-open]').count()).toBe(0);
});

test('custom_language_list: the chooser lists only the chosen languages', async ({ page }) => {
  set({ custom_language_list: on, custom_language_codes: [['english', 'french'], 'json'] });
  await page.goto('/');
  await page.locator('[data-locale-open]:visible').first().click();
  const items = page.locator('#localeModal .locale-modal-body [data-lang], #localeModal .locale-modal-body a[href*="language="], #localeModal .locale-modal-body button[value]');
  await expect(page.locator('#localeModal .locale-modal-panel')).toBeVisible();
  const texts = (await items.allInnerTexts()).map(t => t.trim()).filter(Boolean);
  expect(texts.length, `listed: ${texts.join(', ')}`).toBe(2);
});

test('topnav_show_icons: top-nav items get icons', async ({ page }) => {
  set({ 'hadrian_active_layout_main-menu_guest': str('top') });
  const icons = () => page.evaluate(() => [...document.querySelectorAll('.only-top a')].filter(a => a.getBoundingClientRect().width > 0 && a.querySelector('svg')).length);
  await page.goto('/');
  expect(await bodyAttr(page, 'data-layout')).toBe('top');
  const without = await icons();
  set({ topnav_show_icons: on });
  await page.goto('/');
  expect(await icons(), `icons before: ${without}`).toBeGreaterThan(without);
});

test('cart_subnav off: no category sidebar on the order form', async ({ page }) => {
  const url = `/index.php?rp=/store/${id.productGroupSlug}`;
  const subnav = () => page.locator('.subnav-card:visible').count();
  await page.goto(url);
  const before = await subnav();
  set({ cart_subnav: off });
  await page.goto(url);
  expect(await subnav(), `sub-nav cards before: ${before}`).toBe(0);
  expect(before).toBeGreaterThan(0);
});

test('website_subnav off: no section sub-nav on client pages', async ({ page, context }) => {
  await loginClient(context.request, 'full');
  const url = '/index.php?rp=/user/profile';
  const subnav = () => page.locator('.subnav-card:visible').count();
  await page.goto(url);
  const before = await subnav();
  set({ website_subnav: off });
  await page.goto(url);
  expect(await subnav(), `sub-nav cards before: ${before}`).toBe(0);
  expect(before).toBeGreaterThan(0);
});

test('enable_dynamic_ajax: every data table loads its rows over AJAX', async ({ page, context }) => {
  test.setTimeout(3 * 60_000);
  set({ enable_dynamic_ajax: on });
  await loginClient(context.request, 'full');
  const w = watch(page);
  for (const [url, table] of [
    ['/clientarea.php?action=services', 'table[data-mt-action]'], ['/clientarea.php?action=domains', '#domTable'],
    ['/clientarea.php?action=invoices', '#invTable'], ['/clientarea.php?action=quotes', 'table[data-mt-action]'],
    ['/clientarea.php?action=emails', '#emTable'], ['/supporttickets.php', 'table[data-mt-action]'],
  ]) {
    w.label(`[${url}]`);
    await page.goto(url);
    const t = page.locator(table).first();
    await expect(t, `${url}: AJAX table`).toHaveAttribute('data-mt-action', /table/);
    await expect.poll(() => t.locator('tbody tr').count(), { message: `${url}: rows arrive`, timeout: 15_000 }).toBeGreaterThan(0);
    await expect(t.locator('tbody'), `${url}: no error row`).not.toContainText(/error|failed|invalid/i);
  }
  expect(w.problems).toEqual([]);
});

// ---------------------------------------------------------------- dark mode
test('enable_dark_mode off: no switch, and a saved "dark" is ignored', async ({ page, context }) => {
  set({ enable_dark_mode: off });
  await loginClient(context.request, 'full');
  await context.addCookies([{ name: 'mt_theme', value: 'dark', url: BASE_URL }]);
  await page.goto('/clientarea.php');
  await expect(page.locator('html')).toHaveAttribute('data-theme', 'light');
  await page.locator('.sidebar-user:visible, .topbar-avatar:visible').first().click();
  await expect(page.locator('.toggle-switch:visible')).toHaveCount(0);
});

test('dark_mode_display=forced + default dark: dark for everyone, no switch', async ({ page, context }) => {
  set({ dark_mode_display: str('forced'), dark_mode_default: str('dark') });
  await context.addCookies([{ name: 'mt_theme', value: 'light', url: BASE_URL }]);
  await page.goto('/');
  await expect(page.locator('html'), 'forced dark beats a saved "light"').toHaveAttribute('data-theme', 'dark');
  await clean(page, context, 'full', ['/clientarea.php', '/clientarea.php?action=services', '/viewinvoice.php?id=' + id.invoiceId]);
});

test('dark_mode_default=dark with the switch: new visitors start dark', async ({ page }) => {
  set({ dark_mode_default: str('dark') });
  await page.goto('/');
  await expect(page.locator('html')).toHaveAttribute('data-theme', 'dark');
});

// ---------------------------------------------------------------- order process
test.describe('order process (server products)', () => {
  const url = `/cart.php?a=add&pid=${id.serverProductId}`;
  const reach = async page => {
    await page.goto(url);
    if (!/a=confproduct/.test(page.url())) await page.waitForURL(/a=confproduct/);
  };

  test('defaults: hostname, root password and nameservers are asked for', async ({ page }) => {
    await reach(page);
    await expect(page.locator('input[name=hostname]')).toBeVisible();
    await expect(page.locator('input[name=rootpw]')).toBeVisible();
    await expect(page.locator('input[name=ns1prefix]')).toBeVisible();
  });

  test('op_hide_hostname=all: hostname + root pw hidden but still submitted, auto-filled', async ({ page }) => {
    set({ op_hide_hostname: str('all') });
    await reach(page);
    await expect(page.locator('input[name=hostname]')).toBeHidden();
    await expect(page.locator('input[name=hostname]')).not.toHaveValue('');
    await expect(page.locator('input[name=rootpw]')).not.toHaveValue('');
    await expect(page.locator('input[name=ns1prefix]')).toBeVisible();
  });

  test('op_hide_nameservers=all: nameservers hidden, hostname still asked', async ({ page }) => {
    set({ op_hide_nameservers: str('all') });
    await reach(page);
    await expect(page.locator('input[name=ns1prefix]')).toBeHidden();
    await expect(page.locator('input[name=hostname]')).toBeVisible();
  });

  test('op_hide_*=selected only applies to the listed groups', async ({ page }) => {
    set({ op_hide_hostname: str('selected'), op_hide_hostname_groups: [[String(id.serverGroupId + 999)], 'json'] });
    await reach(page);
    await expect(page.locator('input[name=hostname]'), 'group not listed: still shown').toBeVisible();
    set({ op_hide_hostname_groups: [[String(id.serverGroupId)], 'json'] });
    await reach(page);
    await expect(page.locator('input[name=hostname]'), 'group listed: hidden').toBeHidden();
  });

  test('op_custom_hostname: the generated hostname follows prefix/suffix/length', async ({ page }) => {
    set({ op_hide_hostname: str('all'), op_custom_hostname: on, op_custom_hostname_interfix: str('8'),
      op_custom_hostname_prefix: str('srv'), op_custom_hostname_suffix: str('.hadrian.test'), op_custom_hostname_chars: [['numbers'], 'json'] });
    await reach(page);
    await expect(page.locator('input[name=hostname]')).toHaveValue(/^[0-9]{8}\.srv\.hadrian\.test$/);
  });

  test('op_root_pw_strength: a strength meter that reacts to the root password', async ({ page }) => {
    await reach(page);
    await expect(page.locator('#cpPwMeter')).toHaveCount(0);
    set({ op_root_pw_strength: on });
    await reach(page);
    await expect(page.locator('#cpPwMeter')).toBeVisible();
    await expect(page.locator('input[name=rootpwstrength]'), 'the server-side check is asked for').toHaveValue('true');
    const pw = page.locator('#inputRootpw');
    await pw.fill('abc');
    const weak = await page.locator('#cpPwLabel').innerText();
    await pw.fill('Tr0ub4dor&3-Horse!');
    await expect(page.locator('#cpPwLabel'), `weak label was "${weak}"`).not.toHaveText(weak);
  });
});

// ---------------------------------------------------------------- layouts
const MENU_LAYOUTS = [['sidebar', 'side'], ['top', 'top'], ['rail', 'rail'], ['topbar-minimal', 'topbar-minimal']];
for (const [layout, token] of MENU_LAYOUTS) {
  test(`main-menu layout "${layout}" as the active layout, guest and client`, async ({ page, context }) => {
    test.setTimeout(3 * 60_000);
    set({ 'hadrian_active_layout_main-menu_guest': str(layout), 'hadrian_active_layout_main-menu_client': str(layout) });
    await page.goto('/');
    expect(await bodyAttr(page, 'data-layout'), 'guest').toBe(token);
    await clean(page, context, 'guest', ['/', '/login', `/index.php?rp=/store/${id.productGroupSlug}`]);
    await clean(page, context, 'full', ['/clientarea.php', '/clientarea.php?action=services', '/supporttickets.php', '/cart.php?a=view']);
    expect(await bodyAttr(page, 'data-layout'), 'client').toBe(token);
    await page.setViewportSize({ width: 375, height: 760 });
    await clean(page, context, 'full', ['/clientarea.php']);
  });
}

// ------------------------------------------------------- layouts by area
// A site picks its layouts by visitor (guest / client, the default, which the
// tests above cover) or by area: website, client area, order process.
const seen = async (page, url) => { await page.goto(url); return [await bodyAttr(page, 'data-area'), await bodyAttr(page, 'data-layout')]; };
// An install that has never been in "by area" mode: no mode row, no area picks.
// These tests start from it explicitly so they do not depend on whether someone
// tried the switch on this install before.
const NEVER_BY_AREA = Object.fromEntries([
  'hadrian_layout_mode',
  ...['main-menu', 'footer'].flatMap(kind => ['website', 'client', 'order'].map(area => `hadrian_active_layout_${kind}_area_${area}`)),
].map(key => [key, null]));

test('layouts by area: each part of the site draws its own pick, whoever is looking', async ({ page, context }) => {
  test.setTimeout(3 * 60_000);
  set({
    hadrian_layout_mode: str('area'),
    'hadrian_active_layout_main-menu_area_website': str('top'),
    'hadrian_active_layout_main-menu_area_client': str('sidebar'),
    'hadrian_active_layout_main-menu_area_order': str('rail'),
    // The visitor picks stay stored and must not apply in this mode.
    'hadrian_active_layout_main-menu_guest': str('topbar-minimal'),
    'hadrian_active_layout_main-menu_client': str('topbar-minimal'),
  });
  const store = `/index.php?rp=/store/${id.productGroupSlug}`;

  expect(await seen(page, '/'), 'guest, homepage').toEqual(['website', 'top']);
  expect(await seen(page, '/knowledgebase'), 'guest, a page read before signing in').toEqual(['website', 'top']);
  expect(await seen(page, '/login'), 'guest, sign-in').toEqual(['website', 'top']);
  expect(await seen(page, '/submitticket.php'), 'guest, a portal page').toEqual(['client', 'side']);
  expect(await seen(page, store), 'guest, product listing on a store route').toEqual(['order', 'rail']);
  expect(await seen(page, '/cart.php?a=view'), 'guest, cart').toEqual(['order', 'rail']);
  await clean(page, context, 'guest', ['/', '/knowledgebase', '/submitticket.php', store]);

  await loginClient(context.request, 'full');
  expect(await seen(page, '/clientarea.php'), 'client, dashboard').toEqual(['client', 'side']);
  expect(await seen(page, '/cart.php?a=view'), 'client, cart').toEqual(['order', 'rail']);
  expect(await seen(page, store), 'client, product listing').toEqual(['order', 'rail']);
  await clean(page, context, 'full', ['/clientarea.php', '/cart.php?a=view']);
});

test('layouts by area: a page names its area and the mode is off by default', async ({ page }) => {
  // No mode stored: the area is still reported, and the visitor pick applies everywhere.
  set({ ...NEVER_BY_AREA, 'hadrian_active_layout_main-menu_guest': str('top'), 'hadrian_active_layout_main-menu_area_website': str('rail') });
  expect(await seen(page, '/'), 'homepage').toEqual(['website', 'top']);
  expect(await seen(page, '/knowledgebase'), 'knowledgebase').toEqual(['website', 'top']);
  expect(await seen(page, '/submitticket.php'), 'a portal page').toEqual(['client', 'top']);
  expect(await seen(page, '/cart.php?a=view'), 'cart').toEqual(['order', 'top']);
});

test('Layouts admin: switching to "by area" starts each area from what its visitors saw', async ({ page, context, browser }) => {
  test.setTimeout(3 * 60_000);
  set({ ...NEVER_BY_AREA, 'hadrian_active_layout_main-menu_guest': str('top'), 'hadrian_active_layout_main-menu_client': str('rail') });
  await loginAdmin(context.request);
  const LAYOUTS = '/admin/addonmodules.php?module=Hadrian&action=layouts';
  const card = name => page.locator(`[data-kind-panel="main-menu"] [data-lay-card="${name}"]`);
  const active = (name, row) => card(name).locator(`.mt-lay-aud.is-on[data-lay-row="${row}"]`);

  // The site is checked from a second, signed-out browser: a signed-in admin
  // counts as an existing client, so the admin's own tab cannot show what a
  // guest gets.
  const guestContext = await browser.newContext({ baseURL: BASE_URL });
  const guest = await guestContext.newPage();
  try {
    await page.goto(LAYOUTS);
    await expect(card('top').locator('[data-lay-row]'), 'by visitor: two rows a card').toHaveCount(2);
    await expect(active('top', 'guest')).toBeVisible();
    await expect(active('rail', 'client')).toBeVisible();
    expect(await seen(guest, '/'), 'guest, before').toEqual(['website', 'top']);
    expect(await seen(page, '/cart.php?a=view'), 'the admin is served as an existing client').toEqual(['order', 'rail']);

    await page.goto(LAYOUTS);
    await page.locator('.mt-lay-mode-seg button[value="area"]').click();
    await expect(card('top').locator('[data-lay-row]'), 'by area: three rows a card').toHaveCount(3);
    // Each area starts from what its visitors saw: guest pick for the website
    // and the order process, client pick for the client area.
    await expect(active('top', 'website')).toBeVisible();
    await expect(active('top', 'order')).toBeVisible();
    await expect(active('rail', 'client')).toBeVisible();
    expect(await seen(guest, '/'), 'the site did not change for a guest').toEqual(['website', 'top']);
    expect(await seen(guest, '/cart.php?a=view')).toEqual(['order', 'top']);
    expect(await seen(guest, '/knowledgebase'), 'a guest reading the knowledgebase stays on the website pick').toEqual(['website', 'top']);
    expect(await seen(guest, '/submitticket.php'), 'the client area now has one pick for everyone').toEqual(['client', 'rail']);

    // One click gives the order process a layout of its own.
    await card('sidebar').locator('button[data-lay-row="order"]').click();
    await expect(active('sidebar', 'order')).toBeVisible();
    await expect(active('top', 'order'), 'a pick is exclusive within its area').toHaveCount(0);
    expect(await seen(guest, '/cart.php?a=view'), 'checkout follows the new pick').toEqual(['order', 'side']);
    expect(await seen(guest, '/'), 'the website keeps its own').toEqual(['website', 'top']);
    expect(await seen(page, '/cart.php?a=view'), 'and it no longer depends on who is looking').toEqual(['order', 'side']);

    // Back to "by visitor": the earlier picks are still there.
    await page.goto(LAYOUTS);
    await page.locator('.mt-lay-mode-seg button[value="audience"]').click();
    await expect(card('top').locator('[data-lay-row]')).toHaveCount(2);
    await expect(active('top', 'guest')).toBeVisible();
    await expect(active('rail', 'client')).toBeVisible();
    expect(await seen(guest, '/cart.php?a=view'), 'a guest in the cart is back on the guest pick').toEqual(['order', 'top']);
    expect(await seen(guest, '/submitticket.php'), 'and on a portal page too').toEqual(['client', 'top']);

    // Returning to "by area" finds the picks made there, not a fresh copy.
    await page.locator('.mt-lay-mode-seg button[value="area"]').click();
    await expect(active('sidebar', 'order'), 'the order pick from before survived').toBeVisible();
  } finally {
    await guestContext.close();
  }
});

test('Pages admin: an admin can move a page to another area', async ({ page, context, browser }) => {
  test.setTimeout(3 * 60_000);
  set({
    ...NEVER_BY_AREA,
    hadrian_layout_mode: str('area'),
    'hadrian_active_layout_main-menu_area_website': str('top'),
    'hadrian_active_layout_main-menu_area_client': str('rail'),
    'hadrian_active_layout_main-menu_area_order': str('sidebar'),
  });
  await loginAdmin(context.request);
  const EDIT = '/admin/addonmodules.php?module=Hadrian&action=pages&sub=edit&page=knowledgebase';
  const guestContext = await browser.newContext({ baseURL: BASE_URL });
  const guest = await guestContext.newPage();
  const area = page.locator('select[name="area"]');
  const save = async value => {
    await page.goto(EDIT);
    await area.selectOption(value);
    await Promise.all([page.waitForURL(/flash=saved/), area.evaluate(el => el.form.requestSubmit())]);
  };
  try {
    await page.goto(EDIT);
    await expect(area, 'nothing picked: the page follows its own rules').toHaveValue('');
    await expect(area.locator('option').first(), 'and the editor says where that puts it').toHaveText('Automatic (Website)');
    expect(await seen(guest, '/knowledgebase')).toEqual(['website', 'top']);

    await save('client');
    await page.goto(EDIT);
    await expect(area, 'the pick is stored').toHaveValue('client');
    expect(await seen(guest, '/knowledgebase'), 'the page moved to the client area and took its layout').toEqual(['client', 'rail']);
    expect(await seen(guest, '/'), 'other pages are untouched').toEqual(['website', 'top']);

    await save('');
    expect(await seen(guest, '/knowledgebase'), 'Automatic puts it back').toEqual(['website', 'top']);
  } finally {
    await guestContext.close();
  }
});

// ---------------------------------------------------------- menus by area
// A location shows the active menu for the visitor (guest / client) unless an
// area was given a menu of its own on the Menu page. Menu items are named
// mt-<item id>, so two different menus never share a name.
const menuItems = async (page, url) => {
  await page.goto(url);
  return page.locator('aside.sidebar [data-nav], aside.sidebar [data-group]')
    .evaluateAll(els => els.map(el => el.getAttribute('data-nav') ?? el.getAttribute('data-group')));
};

test('Menu admin: an area can be given a menu of its own', async ({ page, context, browser }) => {
  test.setTimeout(4 * 60_000);
  set({
    ...NEVER_BY_AREA,
    menus_by_area: null,
    'hadrian_active_layout_main-menu_guest': str('sidebar'),
    'hadrian_active_layout_main-menu_client': str('sidebar'),
  });
  await loginAdmin(context.request);
  const MENUS = '/admin/addonmodules.php?module=Hadrian&action=menu&tab=main';
  const CART = '/cart.php?a=view';
  const guestContext = await browser.newContext({ baseURL: BASE_URL });
  const guest = await guestContext.newPage();
  const clientContext = await browser.newContext({ baseURL: BASE_URL });
  await loginClient(clientContext.request, 'full');
  const client = await clientContext.newPage();
  const pick = area => page.locator(`select[data-menu-area="${area}"]`);
  const save = async (area, choice) => {
    await page.goto(MENUS);
    await pick(area).selectOption(choice);
    await Promise.all([page.waitForURL(/flash=areas-saved/), pick(area).evaluate(el => el.form.requestSubmit())]);
  };
  const rows = page.locator('.mt-table tbody tr');
  try {
    await page.goto(MENUS);
    for (const area of ['website', 'client', 'order']) {
      await expect(pick(area), `${area} starts on the visitor rule`).toHaveValue('0');
    }
    // A menu that is switched off, preferably a guest one: an area's menu
    // needs neither the Active switch nor a matching audience.
    const listed = await rows.evaluateAll(trs => trs.map((tr, index) => ({
      index,
      name: tr.querySelector('.mt-table-name a').textContent.trim(),
      audience: tr.children[1].textContent.trim(),
      active: tr.classList.contains('is-active'),
    })));
    const spare = listed.find(r => !r.active && r.audience === 'Guest') ?? listed.find(r => !r.active);
    expect(spare, 'the install has a menu that is switched off').toBeTruthy();

    const before = {
      home: await menuItems(guest, '/'),
      portal: await menuItems(guest, '/submitticket.php'),
      cart: await menuItems(guest, CART),
      clientCart: await menuItems(client, CART),
    };
    expect(before.home.length, 'the guest menu has items').toBeGreaterThan(0);
    expect(before.cart, 'by visitor, a guest sees one menu everywhere').toEqual(before.home);

    await save('order', { label: spare.name });
    await expect(pick('order'), 'the pick is stored').not.toHaveValue('0');
    await expect(rows.nth(spare.index).locator('[data-menu-area-badge]'), 'the list says where the menu is used').toHaveText('Order process');
    await expect(rows.nth(spare.index).getByText('Disabled'), 'and stops calling it disabled').toHaveCount(0);

    const guestCart = await menuItems(guest, CART);
    expect(guestCart.length, 'the order process draws its own menu').toBeGreaterThan(0);
    expect(guestCart.filter(name => before.cart.includes(name)), 'a different menu: none of the earlier items').toEqual([]);
    const clientCart = await menuItems(client, CART);
    expect(clientCart.length, 'a client in the cart gets it too').toBeGreaterThan(0);
    expect(clientCart.filter(name => before.clientCart.includes(name)), 'not the client menu any more').toEqual([]);
    expect(await menuItems(guest, '/'), 'the website still follows the visitor').toEqual(before.home);
    expect(await menuItems(guest, '/submitticket.php'), 'and so does the client area').toEqual(before.portal);
    await clean(guest, guestContext, 'guest', [CART, '/']);

    await save('order', '0');
    expect(await menuItems(guest, CART), '"By visitor" puts the area back').toEqual(before.cart);
    await page.goto(MENUS);
    await expect(rows.nth(spare.index).locator('[data-menu-area-badge]')).toHaveCount(0);
  } finally {
    await guestContext.close();
    await clientContext.close();
  }
});

// ------------------------------------------------------------ the customizer
// Admin: Styles -> Open the customizer. A scheme, layouts and colours are
// tried on the real site in a frame; nothing is written until Save, and until
// then only the admin's own frame shows it.
const accentOf = page => page.evaluate(() => getComputedStyle(document.documentElement).getPropertyValue('--color-accent').trim());
const siteFacts = async (page, url = '/') => {
  await page.goto(url);
  return {
    preview: await page.evaluate(() => document.documentElement.getAttribute('data-hadrian-preview')),
    layout: await bodyAttr(page, 'data-layout'),
    accent: await accentOf(page),
  };
};

test('Customizer: changes show in the frame only, and reach the site on Save', async ({ page, context, browser }) => {
  test.setTimeout(5 * 60_000);
  set({
    ...NEVER_BY_AREA,
    hadrian_active_style: str('default'),
    hadrian_colors_default_light: null,
    hadrian_colors_default_dark: null,
    hadrian_colors_emerald_light: null,
    hadrian_colors_emerald_dark: null,
    'hadrian_active_layout_main-menu_guest': str('sidebar'),
    'hadrian_active_layout_main-menu_client': str('sidebar'),
  });
  await loginAdmin(context.request);
  const guestContext = await browser.newContext({ baseURL: BASE_URL });
  const guest = await guestContext.newPage();
  const errors = [];
  page.on('pageerror', e => errors.push(e.message));
  // Leaving with unsaved changes asks first; this test leaves on purpose.
  page.on('dialog', dialog => dialog.accept());

  const idle = () => page.evaluate(() => window.hadrianCustomize.idle());
  const frame = () => page.evaluate(() => {
    const d = document.querySelector('[data-cz-frame]').contentDocument;
    return {
      preview: d.documentElement.getAttribute('data-hadrian-preview'),
      theme: d.documentElement.getAttribute('data-theme'),
      layout: d.body.getAttribute('data-layout'),
      area: d.body.getAttribute('data-area'),
      accent: getComputedStyle(d.documentElement).getPropertyValue('--color-accent').trim(),
    };
  });
  const loads = () => page.evaluate(() => window.hadrianCustomize.loads());
  const save = page.locator('[data-cz-save]');

  try {
    const live = await siteFacts(guest);
    expect(live, 'the site before').toEqual({ preview: null, layout: 'side', accent: '#0071e3' });

    await page.goto('/admin/addonmodules.php?module=Hadrian&action=styles');
    await page.locator('[data-open-customizer]').click();
    await idle();
    expect(await frame(), 'the frame opens on what is saved').toMatchObject({ preview: '1', layout: 'side', area: 'website', accent: '#0071e3' });
    await expect(save, 'nothing to save yet').toBeDisabled();

    // A scheme.
    await page.locator('[data-cz-scheme="emerald"]').click();
    await idle();
    const emerald = (await frame()).accent;
    expect(emerald, 'the frame draws the scheme being tried').not.toBe('#0071e3');
    await expect(save).toBeEnabled();

    // A layout.
    await page.locator('[data-cz-tab="layouts"]').click();
    await page.locator('[data-cz-layout="main-menu:guest"]').selectOption('top');
    await idle();
    expect(await frame(), 'the admin sees the guest layout in the frame').toMatchObject({ layout: 'top', accent: emerald });

    // A colour: repainted in place, no reload.
    await page.locator('[data-cz-tab="colors"]').click();
    const before = await loads();
    const accent = page.locator('[data-cz-token="--color-accent"] input[type="text"]');
    await accent.fill('#ff2d55');
    await accent.dispatchEvent('change');
    expect((await frame()).accent, 'the colour is live at once').toBe('#ff2d55');
    expect(await loads(), 'without reloading the frame').toBe(before);
    await idle();

    // Following a link inside the frame stays in the preview.
    await page.locator('[data-cz-page]').selectOption('cart.php?a=view');
    await idle();
    expect(await frame(), 'another page, same unsaved state').toMatchObject({ preview: '1', area: 'order', layout: 'top', accent: '#ff2d55' });

    // Nobody else sees any of it.
    expect(await siteFacts(guest), 'a visitor still gets the saved site').toEqual(live);
    const token = await page.evaluate(() => JSON.parse(document.getElementById('mt-cz-data').textContent).token);
    expect(await siteFacts(guest, `/index.php?hadrian_customize=${token}`), 'the token alone, without the admin session, does nothing').toEqual(live);
    await page.goto('/');
    expect(await bodyAttr(page, 'data-layout'), 'the admin, outside the frame, gets the saved site too').toBe('side');
    expect(await accentOf(page)).toBe('#0071e3');
    await clean(guest, guestContext, 'guest', ['/']);

    // Reopening starts from what is saved, not from an old try.
    await page.goto('/admin/addonmodules.php?module=Hadrian&action=customize');
    await idle();
    expect(await frame(), 'a fresh visit starts from the saved site').toMatchObject({ layout: 'side', accent: '#0071e3' });

    // Now for real.
    await page.locator('[data-cz-scheme="emerald"]').click();
    await page.locator('[data-cz-tab="layouts"]').click();
    await page.locator('[data-cz-layout="main-menu:guest"]').selectOption('top');
    await page.locator('[data-cz-tab="colors"]').click();
    await accent.fill('#ff2d55');
    await accent.dispatchEvent('change');
    await idle();
    await save.click();
    await expect(page.locator('[data-cz-status]'), 'the save is confirmed').toHaveAttribute('data-kind', 'ok');
    await expect(save, 'and nothing is left unsaved').toBeDisabled();

    expect(await siteFacts(guest), 'the site now shows it').toEqual({ preview: null, layout: 'top', accent: '#ff2d55' });
    await clean(guest, guestContext, 'guest', ['/', '/cart.php?a=view']);

    // The Styles and Layouts pages read the same rows.
    await page.goto('/admin/addonmodules.php?module=Hadrian&action=styles');
    await expect(page.locator('.mt-sty-card.is-active .mt-sty-title'), 'the Styles page agrees').toHaveText('Emerald');
    await page.goto('/admin/addonmodules.php?module=Hadrian&action=editStyle&style=emerald&subcat=colors');
    await expect(page.locator('input[name="c[--color-accent]"]').first(), 'and so does its Colors panel').toHaveValue(/#ff2d55/i);
    expect(errors, 'no script errors on the way').toEqual([]);
  } finally {
    await guestContext.close();
  }
});

const FOOTERS = [['default', 'hp-footer-slim'], ['extended', 'hp-footer-extended'], ['extended-info', 'hp-footer-extended-info']];
for (const [footer, cls] of FOOTERS) {
  test(`footer layout "${footer}"`, async ({ page, context }) => {
    set({ hadrian_active_layout_footer_guest: str(footer), hadrian_active_layout_footer_client: str(footer),
      footer_social_x: str('https://x.com/hadrian-test'), footer_social_github: str('https://github.com/hadrian-test'),
      footer_description: str('Hosting for people who build things (test fixture).') });
    await page.goto('/');
    await expect(page.locator(`footer.${cls}`)).toHaveCount(1);
    await clean(page, context, 'guest', ['/', '/contact.php']);
    await clean(page, context, 'full', ['/clientarea.php']);
  });
}

test('extended-info footer: socials shown, and hidden by hide_footer_socials', async ({ page }) => {
  set({ hadrian_active_layout_footer_guest: str('extended-info'), footer_social_x: str('https://x.com/hadrian-test') });
  const social = () => page.locator('footer a[href="https://x.com/hadrian-test"]').count();
  await page.goto('/');
  expect(await social()).toBe(1);
  set({ hide_footer_socials: on });
  await page.goto('/');
  expect(await social()).toBe(0);
});

// ---------------------------------------------------------------- page variants
const VARIANTS = [
  ['clientareahome', 'atrium', '.at-band', 'full', '/clientarea.php'],
  ['clientareahome', 'bento', '.bn-grid', 'full', '/clientarea.php'],
  ['clientareahome', 'minimal', '.min-greeting', 'full', '/clientarea.php'],
  ['clientareahome', 'atrium', '.at-band', 'empty', '/clientarea.php'],
  ['clientareahome', 'bento', '.bn-grid', 'empty', '/clientarea.php'],
  ['clientareahome', 'minimal', '.min-greeting', 'empty', '/clientarea.php'],
  ['homepage', 'portal', '.ph-hero', 'guest', '/'],
  ['homepage', 'portal', '.ph-hero', 'full', '/'],
  ['login', 'beacon', '.mt-bcn', 'guest', '/login'],
  ['login', 'split', '.mt-loginscreen', 'guest', '/login'],
];
for (const [pageName, v, marker, persona, url] of VARIANTS) {
  test(`variant ${pageName}/${v} as ${persona}, light and dark`, async ({ page, context }) => {
    variant({ [pageName]: v });
    // The first request after a switch compiles the variant; on Windows a
    // compile racing a second request can hand out a truncated page. Warm it.
    await context.request.get(url).catch(() => {});
    await context.request.get('/login').catch(() => {});
    await loginClient(context.request, persona);
    for (const theme of ['light', 'dark']) {
      await context.addCookies([{ name: 'mt_theme', value: theme, url: BASE_URL }]);
      await page.goto(url);
      await expect(page.locator(marker).first(), `${v} renders its own markup`).toBeAttached();
      await clean(page, context, persona, [url]);
    }
    await page.setViewportSize({ width: 375, height: 760 });
    await clean(page, context, persona, [url]);
  });
}

test('login variants: signing in works from each', async ({ page }) => {
  test.setTimeout(2 * 60_000);
  const { creds } = await import('./helpers.mjs');
  for (const v of ['default', 'beacon', 'split']) {
    variant({ login: v });
    await page.context().clearCookies();
    await page.goto('/login');
    await page.locator('input[name=username]:visible').fill(creds.personas.full.email);
    await page.locator('input[name=password]:visible').fill(creds.personas.full.password);
    await page.locator('form:has(input[name=password]) [type=submit]:visible').first().click();
    await page.waitForURL(/clientarea\.php/, { timeout: 30_000 });
    expect(await page.evaluate(() => document.body.dataset.auth), `signed in from the ${v} variant`).toBe('in');
  }
});
