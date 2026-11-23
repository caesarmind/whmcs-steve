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
import { fx, loginClient } from './helpers.mjs';
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
