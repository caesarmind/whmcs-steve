// Order form (hadrian_cart) - one behavioural test per OF-* feature in
// tests/FEATURES.md that can be exercised on the local stack without changing a
// Hadrian or WHMCS setting.
//
// "Behavioural": the test does what a customer does (clicks the card, picks the
// option, types the card number) and checks the result against the fixture
// prices from tests/php/scenarios.php - the live summary, the cart, the checkout
// summary and, after a checkout, the invoice WHMCS created.
//
// Data the fixtures do not have comes from tests/php/order.php: throwaway
// customers flow+buyer<n>@demo.hadrian.test with account credit, saved cards or
// a renewable domain (deleted in a finally, and by tests/php/fixtures.php on
// every full run), read-backs of the orders and invoices a checkout made, and a
// promo code that discounts (the fixture's HADRIAN10 applies to nothing).
// Catalogue flags (Featured, stock) and that promo code exist only inside the
// one test that needs them, restored or deleted in a finally.
//
// Guests use "my own domain" on the domain step; most signed-in tests register
// instead. (The own-domain check used to sign customers out: bug 37 in
// tests/FEATURES.md, fixed, with its own test below.)
//
// A test marked test.fail(true, 'BUG: ...') reproduces a real defect in the
// order form; it passes while the bug is there and fails once it is fixed, so
// the mark has to be removed then.

import { test, expect } from '@playwright/test';
import { execFileSync } from 'node:child_process';
import crypto from 'node:crypto';
import path from 'node:path';
import { BASE_URL, PHP, TESTS_DIR } from '../lib/env.mjs';
import { loginClient } from './helpers.mjs';
import { inspect } from './oracles.mjs';
import { measure } from './page-checks.mjs';

// One after another in one worker: checkouts are heavy, and the catalogue
// flips must not overlap. Not 'serial': one failure must not skip the rest.
test.describe.configure({ mode: 'default' });

// ------------------------------------------------------------------ helpers
const BUYER_PW = 'Order!' + crypto.randomBytes(9).toString('base64url');
// A spec-owned promo code (created and deleted per test): the fixture's
// HADRIAN10 has an empty "applies to", so it never discounts anything.
const PROMO = 'ORDERSPEC10';
const orderPhp = (...args) => JSON.parse(execFileSync(PHP, [path.join(TESTS_DIR, 'php', 'order.php'), ...args], {
  encoding: 'utf8', env: { ...process.env, ORDER_BUYER_PASSWORD: BUYER_PW },
}).trim());

/** A throwaway customer (flow+buyer<n>@demo.hadrian.test) with a known password. */
function newBuyer({ credit = 0, card = false, expiredCard = false, closedAccount = false, country = 'US', domain } = {}) {
  const args = ['buyer', `--credit=${credit}`, `--country=${country}`];
  if (card) args.push('--card');
  if (expiredCard) args.push('--expired-card');
  if (closedAccount) args.push('--closed-account');
  if (domain) args.push(`--domain=${domain}`);
  return { ...orderPhp(...args), password: BUYER_PW };
}
function dropClients(...ids) {
  const list = ids.flat().filter(Boolean).map(String);
  if (!list.length) return;
  try { orderPhp('delete', ...list); } catch (e) { console.warn(`order.php delete ${list}: ${e.message}`); }
}

function watchErrors(page) {
  const errors = [];
  page.on('pageerror', e => errors.push(`uncaught: ${e.message}`));
  page.on('console', m => { if (m.type() === 'error') errors.push(`console: ${m.text().slice(0, 200)}`); });
  return errors;
}
const tpl = page => page.evaluate(() => document.body.dataset.tpl);
const auth = page => page.evaluate(() => document.body.dataset.auth);
/** "$1,234.56 USD" -> 1234.56 */
const money = s => Number(String(s).replace(/[^0-9.-]/g, ''));
const usd = n => `$${n.toFixed(2)}`;
const re = s => new RegExp(s.replace(/[.*+?^${}()|[\]\\]/g, '\\$&'));
const stamp = () => Date.now().toString(36);

async function signIn(page, buyer) {
  await page.goto('/login');
  await page.locator('input[name=username]:visible').fill(buyer.email);
  await page.locator('input[name=password]:visible').fill(buyer.password);
  await page.locator('form:has(input[name=password]) [type=submit]:visible').first().click();
  await page.waitForURL(/clientarea\.php|user\/accounts/);
  // A user on two accounts (the closed-account buyer) picks one first.
  if (/user\/accounts/.test(page.url())) {
    await page.locator(`.sw-row[data-sw-id="${buyer.clientId}"]`).click();
    await page.waitForURL(/clientarea\.php/);
  }
  expect(await auth(page), 'signed in').toBe('in');
}

/** Product domain step, "use my own domain": the check adds the plan and opens its configure step. */
async function ownDomain(page, pid, sld, tld = 'com') {
  await page.goto(`/cart.php?a=add&pid=${pid}`);
  expect(await tpl(page)).toBe('configureproductdomain');
  await page.locator('label:has(input[name=domainoption][value=owndomain])').click();
  const panel = page.locator('.dp-panel[data-panel=owndomain]');
  await panel.locator('[data-input=sld]').fill(sld);
  await panel.locator('[data-input=tld]').fill(tld);
  await page.locator('button.dp-continue').click();
  await page.waitForURL(/a=confproduct/);
  expect(await tpl(page)).toBe('configureproduct');
}

/** Product domain step, "register a new domain": checked by WHMCS, then posted. */
async function registerWithProduct(page, pid, sld, tld = '.com') {
  await page.goto(`/cart.php?a=add&pid=${pid}`);
  expect(await tpl(page)).toBe('configureproductdomain');
  await page.locator('label:has(input[name=domainoption][value=register])').click();
  const panel = page.locator('.dp-panel[data-panel=register]');
  await panel.locator('[data-input=sld]').fill(sld);
  await panel.locator('[data-input=tld]').selectOption(tld);
  await page.locator('button.dp-continue').click();
  await page.waitForURL(/a=confproduct/);
}

const dueToday = page => page.locator('#producttotal .total-due-today .amt');

/** Configure -> cart through the AJAX commit. */
async function reviewCart(page) {
  await page.locator('#btnCompleteProductConfig').click();
  await page.waitForURL(/a=view/);
  expect(await tpl(page)).toBe('viewcart');
}

/** Products that skip configure (SSL: one cycle, no options) land straight in the cart. */
async function addStraightToCart(page, pid) {
  await page.goto(`/cart.php?a=add&pid=${pid}`);
  await page.waitForURL(/a=(confproduct|view)/);
  if (/a=confproduct/.test(page.url())) await reviewCart(page);
}

async function toCheckout(page) {
  await page.goto('/cart.php?a=view');
  await page.locator('#checkout').click();
  await page.waitForURL(/a=checkout/);
  await expect(page.locator('#frmCheckout'), 'the checkout form').toBeAttached();
}

/** New-customer fields on the checkout (Create account tab). */
async function fillNewCustomer(page, { email, country = 'US', phone = '2025550143' }) {
  const f = page.locator('#frmCheckout');
  await f.locator('[name=firstname]').fill('Order');
  await f.locator('[name=lastname]').fill('Spectest');
  await f.locator('[name=email]').fill(email);
  await expect(f.locator('.iti').first(), 'phone widget initialised').toBeAttached({ timeout: 20_000 });
  if (country !== 'US') {
    await f.locator('#inputCountry').selectOption(country);
  }
  await f.locator('[name=phonenumber]').fill(phone);
  await f.locator('[name=address1]').fill(country === 'GB' ? '10 Downing Lane' : '1 Test Street');
  await f.locator('[name=city]').fill(country === 'GB' ? 'Bristol' : 'Austin');
  const state = f.locator('[name=state]:visible').first();
  if (await state.evaluate(e => e.tagName) === 'SELECT') await state.selectOption({ index: 1 }); else await state.fill(country === 'GB' ? 'Bristol' : 'TX');
  await f.locator('[name=postcode]').fill(country === 'GB' ? 'BS1 4DJ' : '78701');
  await f.locator('[name=password]').fill('FlowTest!2026x');
  await f.locator('[name=password2]').fill('FlowTest!2026x');
}

async function completeOrder(page, landing = /viewinvoice\.php\?id=\d+|a=complete/) {
  await page.locator('#btnCompleteOrder').click();
  await page.waitForURL(landing, { timeout: 60_000 });
}
const invoiceIdOf = page => Number((page.url().match(/viewinvoice\.php\?id=(\d+)/) || [])[1]);

/** Contrast of the first visible element matching `sel` against its painted background. Runs in the page. */
const contrastIn = sels => {
  const rgb = s => (s.match(/[\d.]+/g) || []).map(Number);
  const lum = ([r, g, b]) => [r, g, b].map(v => { v /= 255; return v <= 0.03928 ? v / 12.92 : ((v + 0.055) / 1.055) ** 2.4; })
    .reduce((a, v, i) => a + v * [0.2126, 0.7152, 0.0722][i], 0);
  const bgOf = el => {
    for (let e = el; e; e = e.parentElement) {
      const c = rgb(getComputedStyle(e).backgroundColor);
      if (c.length >= 3 && (c[3] === undefined || c[3] > 0.5)) return c;
    }
    return document.documentElement.dataset.theme === 'dark' ? [0, 0, 0] : [255, 255, 255];
  };
  return sels.map(sel => {
    const el = [...document.querySelectorAll(sel)].find(e => e.textContent.trim().length > 1 && e.getBoundingClientRect().width > 0);
    if (!el) return { sel, missing: true };
    const a = lum(rgb(getComputedStyle(el).color)), b = lum(bgOf(el));
    return { sel, ratio: Math.round(((Math.max(a, b) + 0.05) / (Math.min(a, b) + 0.05)) * 100) / 100, bg: Math.round(lum(bgOf(el)) * 100) / 100 };
  });
};

// Every test leaves an empty cart behind (the session dies with the context,
// but a cart left half-built is the next bug report's red herring).
test.afterEach(async ({ page }) => {
  await page.goto('/cart.php?a=empty').catch(() => {});
});

// ==================================================================== OF-A
test.describe('OF-A Browse', () => {
  test('OF-01 OF-02 plan grid: one card per product, tag line before the list, heading fallback, Order Now opens that plan', async ({ page }) => {
    const errors = watchErrors(page);
    for (const url of ['/index.php?rp=/store/shared-hosting', '/cart.php?gid=6']) {
      await page.goto(url);
      expect(await tpl(page)).toBe('products');
      const cards = page.locator('.plan-variant.v-a .st-plan');
      await expect(cards, `${url}: one card per product`).toHaveCount(3);
      await expect(page.locator('.plan-variant.v-b'), 'only the shipped design is shown').toBeHidden();
      await expect(page.locator('#cat-title'), 'no headline: the group name').toHaveText('Shared Hosting');
      await expect(page.locator('#cat-desc')).toHaveText('Hosting is what makes your site visible on the web.');
      await expect(page.locator('#product13-name')).toHaveText('Single');
      await expect(page.locator('#product14-name')).toHaveText('Professional');
      await expect(page.locator('#product15-name')).toHaveText('Business');
      // Tag line = the description before its <ul>; the list alone is the body.
      await expect(page.locator('#product13-description')).toHaveText('Everything you need to launch your first site.');
      await expect(page.locator('#product13 .st-plan-features li')).toHaveCount(6);
      await expect(page.locator('#product13 .st-plan-features')).not.toContainText('Everything you need');
    }
    // A group with a headline shows the headline instead of its name.
    await page.goto('/index.php?rp=/store/openpanel-hosting');
    await expect(page.locator('#cat-title')).toHaveText('OpenPanel test products');

    await page.goto('/index.php?rp=/store/shared-hosting');
    const order = page.locator('#product14-order-button');
    await expect(order).toHaveAttribute('href', /professional|pid=14/);
    await order.click();
    await page.waitForLoadState('load');
    expect(await tpl(page)).toBe('configureproductdomain');
    await expect(page.locator('#frmProductDomain input[name=pid]')).toHaveValue('14');
    expect(errors).toEqual([]);
  });

  test('OF-03 OF-04 the store without a group, or with an unknown one, lands on the first group', async ({ page }) => {
    for (const url of ['/cart.php', '/cart.php?gid=99999', '/index.php?rp=/store/no-such-group']) {
      await page.goto(url);
      expect(page.url(), url).toMatch(/rp=\/store\/shared-hosting/);
      expect(await tpl(page)).toBe('products');
      await expect(page.locator('.plan-variant.v-a .st-plan')).toHaveCount(3);
      await expect(page.locator('#order-standard_cart .alert-danger'), 'no error alert').toHaveCount(0);
    }
  });

  test('OF-05 billing-cycle pills: offered cycles only, Annual first, per-month price, billed line and setup fee follow', async ({ page }) => {
    const errors = watchErrors(page);
    await page.goto('/index.php?rp=/store/shared-hosting');
    const sw = page.locator('[data-cycle-switcher]');
    for (const c of ['monthly', 'annually', 'biennially']) await expect(sw.locator(`button[data-cycle=${c}]`)).toBeVisible();
    await expect(sw.locator('button[data-cycle=annually]'), 'starts on Annual').toHaveClass(/active/);
    const single = page.locator('#product13');
    const amount = single.locator('[data-price-display]'), period = single.locator('[data-period-display]'), billed = single.locator('[data-billed-display]');
    // Annual 35.88 shown per month: 2.99 /mo, billed annually.
    await expect(amount).toHaveText('2.99');
    await expect(period).toHaveText('/mo');
    await expect(billed).toBeVisible();
    await expect(billed).toHaveText('Billed annually · $35.88/year');
    await sw.locator('button[data-cycle=monthly]').click();
    await expect(sw.locator('button[data-cycle=monthly]')).toHaveClass(/active/);
    await expect(amount).toHaveText('3.74');
    await expect(billed).toBeHidden();
    await sw.locator('button[data-cycle=biennially]').click();
    await expect(amount, '66.96 over 24 months').toHaveText('2.79');
    await expect(billed).toHaveText('Billed every 2 years · $66.96');
    await expect(page.locator('#product15 [data-price-display]'), '215.76 / 24').toHaveText('8.99');

    // A group without biennial prices hides that pill; the setup fee follows the cycle.
    await page.goto('/index.php?rp=/store/dedicated-servers');
    await expect(sw.locator('button[data-cycle=biennially]')).toBeHidden();
    await expect(page.locator('#product19 [data-price-display]'), '890 / 12').toHaveText('74.17');
    await expect(page.locator('#product19 [data-setup-display]')).toHaveText('+ $49.00 Setup Fee');
    await sw.locator('button[data-cycle=monthly]').click();
    await expect(page.locator('#product19 [data-price-display]')).toHaveText('89.00');
    await expect(page.locator('#product20 [data-setup-display]')).toHaveText('+ $99.00 Setup Fee');

    // Sold yearly only: no Monthly pill, and the card keeps its yearly price.
    await page.goto('/index.php?rp=/store/ssl-certificates');
    await expect(sw.locator('button[data-cycle=monthly]')).toBeHidden();
    await expect(sw.locator('button[data-cycle=annually]')).toHaveClass(/active/);
    await expect(page.locator('#product21 [data-price-display]')).toHaveText('15.00');
    await expect(page.locator('#product21 [data-period-display]')).toHaveText('/yr');
    await expect(page.locator('#product21 [data-billed-display]')).toBeHidden();
    expect(errors).toEqual([]);
  });

  test('OF-06 the Annual pill carries the real saving', async ({ page }) => {
    // Shared: 1 - 35.88/(3.74*12) = 20%, the same for all three plans.
    await page.goto('/index.php?rp=/store/shared-hosting');
    await expect(page.locator('.st-cycle-saving')).toBeVisible();
    await expect(page.locator('.st-cycle-saving')).toHaveText('Save 20%');
    // Dedicated: 1 - 890/(89*12) = 17%.
    await page.goto('/index.php?rp=/store/dedicated-servers');
    await expect(page.locator('.st-cycle-saving')).toHaveText('Save 17%');
  });

  test('OF-07 the Most popular badge appears only on a product flagged Featured', async ({ page }) => {
    await page.goto('/index.php?rp=/store/dedicated-servers');
    await expect(page.locator('.plan-variant.v-a .st-plan-badge'), 'no product flagged: no badge').toHaveCount(0);
    await expect(page.locator('.plan-variant.v-a .st-plan-cta.secondary')).toHaveCount(0);
    const before = orderPhp('product', '20', 'is_featured', '1');
    try {
      await page.reload();
      await expect(page.locator('.plan-variant.v-a .st-plan-badge')).toHaveCount(1);
      await expect(page.locator('#product20')).toHaveClass(/featured/);
      await expect(page.locator('#product20 .st-plan-badge')).toHaveText('Most popular');
      await expect(page.locator('#product19-order-button'), 'the other plan gets the secondary button').toHaveClass(/secondary/);
      await expect(page.locator('#product20-order-button')).not.toHaveClass(/secondary/);
    } finally {
      orderPhp('product', '20', 'is_featured', String(before));
    }
  });

  test('OF-08 OF-80 setup fee, "starting from", stock left, and the cart error page for an out-of-stock plan', async ({ page }) => {
    const errors = watchErrors(page);
    // Starting from: only plans with configurable options (14, 15).
    await page.goto('/index.php?rp=/store/shared-hosting');
    await expect(page.locator('#product14-price')).toContainText('Starting from');
    await expect(page.locator('#product15-price')).toContainText('Starting from');
    await expect(page.locator('#product13-price')).not.toContainText('Starting from');

    const stock = orderPhp('product', '19', 'stockcontrol', '1');
    const qty = orderPhp('product', '19', 'qty', '3');
    try {
      await page.goto('/index.php?rp=/store/dedicated-servers');
      await expect(page.locator('#product19')).toContainText('3 Available');
      await expect(page.locator('#product20')).not.toContainText('Available');
      await expect(page.locator('#product19 [data-setup-display]')).toHaveText('+ $49.00 Setup Fee');

      orderPhp('product', '19', 'qty', '0');
      await page.goto('/cart.php?a=add&pid=19');
      expect(await tpl(page)).toBe('error');
      await expect(page.locator('.order-error-hero h1')).toBeVisible();
      await expect(page.locator('.order-error-hero, .order-error-body').first()).toContainText(/stock/i);
      await expect(page.locator('.order-error-actions a[href="javascript:history.go(-1)"]')).toBeVisible();
      await expect(page.locator('.order-error-actions a[href$="submitticket.php"]')).toBeVisible();
      expect(inspect(await page.content()).problems).toEqual([]);
    } finally {
      orderPhp('product', '19', 'qty', String(qty));
      orderPhp('product', '19', 'stockcontrol', String(stock));
    }
    expect(errors).toEqual([]);
  });

  test('OF-10 plan designs B to H are picked with ?plan= under ?preview=1', async ({ page }) => {
    const errors = watchErrors(page);
    for (const v of 'bcdefgh') {
      await page.goto(`/index.php?rp=/store/shared-hosting&preview=1&plan=${v}`);
      await expect(page.locator('body')).toHaveAttribute('data-plan', v);
      await expect(page.locator(`.plan-variant.v-${v}`), `design ${v}`).toBeVisible();
      await expect(page.locator(`.plan-variant.v-${v}`)).toContainText('Professional');
      await expect(page.locator('.plan-variant:visible'), `only design ${v}`).toHaveCount(1);
    }
    await expect(page.locator('.plan-variant.v-c')).toBeHidden();
    await page.goto('/index.php?rp=/store/shared-hosting&preview=1&plan=c');
    await expect(page.locator('.plan-variant.v-c .st-row')).toHaveCount(3);
    await expect(page.locator('.plan-variant.v-c a.st-row-cta').first()).toHaveAttribute('href', /single|pid=13/);
    // "all" is the chip's reset: back to the shipped design A.
    await page.goto('/index.php?rp=/store/shared-hosting&preview=1&plan=all');
    await expect(page.locator('.plan-variant.v-a')).toBeVisible();
    await expect(page.locator('.plan-variant:visible')).toHaveCount(1);
    expect(errors).toEqual([]);
  });

  test('OF-11 category rail: every group and action, the current group active, links that go there', async ({ page }) => {
    const errors = watchErrors(page);
    await page.goto('/index.php?rp=/store/dedicated-servers');
    const rail = page.locator('#order-standard_cart aside').first();
    await expect(rail.locator('.subnav-heading')).toHaveText(['Categories', 'Actions']);
    await expect(rail.locator('.subnav-card').first().locator('a.subnav-item')).toHaveCount(6);
    await expect(rail.locator('.subnav-item.active')).toHaveCount(1);
    await expect(rail.locator('.subnav-item.active')).toContainText('Dedicated Servers');
    await rail.locator('a.subnav-item', { hasText: 'SSL Certificates' }).click();
    await page.waitForURL(/ssl-certificates/);
    await expect(rail.locator('.subnav-item.active')).toContainText('SSL Certificates');
    await expect(page.locator('.plan-variant.v-a .st-plan')).toHaveCount(2);
    // Actions: register, transfer, and View Cart to the cart.
    await expect(rail.locator('a.subnav-item[href$="a=add&domain=register"]')).toBeVisible();
    await expect(rail.locator('a.subnav-item[href$="a=add&domain=transfer"]')).toBeVisible();
    await addStraightToCart(page, 21);
    await page.goto('/index.php?rp=/store/ssl-certificates');
    await rail.locator('a.subnav-item[href$="a=view"]').click();
    await page.waitForURL(/a=view/);
    await expect(page.locator('[data-cart-item="product-0"] .ct-product-title')).toHaveText('DV SSL');
    expect(errors).toEqual([]);
  });

  test('OF-12 the collapsed category select navigates at phone width', async ({ page, context }) => {
    test.fail(true, 'BUG: sidebar-categories-selector.tpl:43 calls selectChangeNavigate(), which only WHMCS\'s six/twenty-one whmcs.js define; neither the theme nor standard_cart\'s scripts.min.js (which common.tpl:30-31 says provides it) does, so picking a category throws "selectChangeNavigate is not defined" and nothing happens');
    const errors = watchErrors(page);
    await loginClient(context.request, 'full');
    await page.setViewportSize({ width: 375, height: 760 });
    await page.goto('/cart.php?gid=addons');
    expect(await tpl(page)).toBe('addons');
    const select = page.locator('.sidebar-collapsed select').first();
    await expect(select).toBeVisible();
    await select.selectOption({ label: 'VPS Hosting' });
    await page.waitForURL(/vps-hosting/, { timeout: 10_000 });
    expect(errors).toEqual([]);
  });

  test('OF-12 the collapsed category selects stay hidden on a desktop-width page', async ({ page, context }) => {
    test.fail(true, 'BUG: addons.tpl:30, complete.tpl:23, error.tpl:34, fraudcheck.tpl:34, domain-renewals.tpl:76 and service-renewals.tpl:67 include sidebar-categories-collapsed.tpl, and no CSS hides .sidebar-collapsed above 880px (style.min.css:765 only hides it with the sub-nav off): the Categories and Actions panels show twice at 1280px');
    await loginClient(context.request, 'full');
    await page.goto('/cart.php?gid=addons');
    await expect(page.locator('#order-standard_cart aside').first(), 'the full rail').toBeVisible();
    await expect(page.locator('.sidebar-collapsed').first()).toBeHidden({ timeout: 3000 });
  });
});

// ==================================================================== OF-B
test.describe('OF-B Configure product', () => {
  test('OF-13 the selected-plan hero names the plan and the domain, and links back to both steps', async ({ page }) => {
    await ownDomain(page, 14, 'hadrian-hero');
    await expect(page.locator('.cp-plan-hero-name')).toHaveText('Professional');
    await expect(page.locator('.cp-plan-hero-desc')).toContainText('Built for growing businesses');
    await expect(page.locator('.cp-plan-hero-domain-name')).toHaveText('hadrian-hero.com');
    await expect(page.locator('.cp-plan-hero-domain a.cp-plan-hero-change')).toHaveAttribute('href', /a=add&pid=14$/);
    const changePlan = page.locator('.cp-plan-hero > a.cp-plan-hero-change');
    await expect(changePlan).toHaveAttribute('href', /cart\.php\?gid=6$/);
    await changePlan.click();
    await page.waitForLoadState('load');
    expect(await tpl(page)).toBe('products');
    await expect(page.locator('#cat-title')).toHaveText('Shared Hosting');
  });

  test('OF-13 an own domain is marked "Included" on the configure step', async ({ page }) => {
    test.fail(true, 'BUG: configureproduct.tpl:143 tests $domainoption, which WHMCS does not assign on the configure step, so the "Included" badge never renders');
    await ownDomain(page, 14, 'hadrian-included');
    await expect(page.locator('.cp-plan-hero-domain-name')).toHaveText('hadrian-included.com');
    await expect(page.locator('.cp-plan-hero-domain-badge')).toHaveText('Included', { timeout: 3000 });
  });

  test('OF-14 billing-cycle cards: each cycle priced, a change re-prices the plan and its options', async ({ page }) => {
    const errors = watchErrors(page);
    await ownDomain(page, 14, 'hadrian-cycles');
    const card = c => page.locator(`label.cp-cycle-opt:has(input[value=${c}])`);
    await expect(page.locator('input[name=billingcycle]')).toHaveCount(3);
    await expect(card('monthly').locator('.cp-cycle-price')).toContainText('6.24');
    await expect(card('annually').locator('.cp-cycle-price')).toContainText('59.88');
    await expect(card('biennially').locator('.cp-cycle-price')).toContainText('107.76');
    await expect(card('monthly').locator('input')).toBeChecked();
    await expect(dueToday(page)).toHaveText('$6.24');
    await expect(page.locator('#inputConfigOption1 option[value="3"]')).toHaveText(/\$2\.00/);

    await card('annually').click();
    await expect(page.locator('#producttotal .summary-row').first()).toContainText('Professional · annually');
    await expect(dueToday(page)).toHaveText('$59.88');
    // updateConfigurableOptions re-renders the options at the new cycle's prices.
    await expect(page.locator('#inputConfigOption1 option[value="3"]')).toHaveText(/\$24\.00/);
    await page.locator('#inputConfigOption1').selectOption('3');
    await expect(dueToday(page), '59.88 + 24.00').toHaveText('$83.88');
    expect(errors).toEqual([]);
  });

  test('OF-16 OF-18 OF-20 a dropdown, a yes/no option and an add-on each change the live summary by their price', async ({ page }) => {
    const errors = watchErrors(page);
    await ownDomain(page, 14, 'hadrian-options');
    const summary = page.locator('#producttotal');
    await expect(dueToday(page)).toHaveText('$6.24');
    await expect(summary).toContainText('Professional · monthly');
    await expect(summary).toContainText('Data centre: London');
    await expect(summary).toContainText('Daily backups: No');

    // Dropdown: New York +2.00 a month.
    await page.locator('#inputConfigOption1').selectOption('3');
    await expect(dueToday(page)).toHaveText('$8.24');
    await expect(summary.locator('.summary-row-sub', { hasText: 'Data centre: New York' })).toContainText('$2.00');

    // Yes/no: Daily backups +3.00.
    await expect(page.locator('.cp-opt-row', { hasText: 'Daily backups' }).locator('.cp-opt-desc')).toContainText('$3.00');
    await page.locator('label.cp-toggle').click();
    await expect(page.locator('#inputConfigOption2')).toBeChecked();
    await expect(dueToday(page)).toHaveText('$11.24');
    await expect(summary.locator('.summary-row-sub', { hasText: 'Daily backups: Yes' })).toContainText('$3.00');

    // Add-on: Priority support 9.00 a month.
    const addon = page.locator('label.st-addon', { hasText: 'Priority support (hadrian-test)' });
    await expect(addon.locator('.st-addon-tier-price')).toHaveText(/\$9\.00 USD Monthly/);
    await addon.click();
    await expect(addon.locator('input[name="addons[1]"]')).toBeChecked();
    await expect(dueToday(page)).toHaveText('$20.24');
    await expect(summary.locator('.summary-row-sub', { hasText: '+ Priority support (hadrian-test)' })).toContainText('$9.00');
    await expect(summary.locator('.summary-totals .summary-row', { hasText: 'Monthly' })).toContainText('$20.24');

    // And back off again.
    await addon.click();
    await expect(dueToday(page)).toHaveText('$11.24');
    await page.locator('label.cp-toggle').click();
    await expect(dueToday(page)).toHaveText('$8.24');
    expect(errors).toEqual([]);
  });

  test('OF-16 the quantity slider can be dragged to add IPv4 addresses', async ({ page }) => {
    test.fail(true, 'BUG: configureproduct.tpl:442-468 mounts the ion.rangeSlider in .cp-opt-control, which has no width (style.min.css:2605 only sets flex-shrink:0), so the slider is 0px wide and cannot be moved');
    await ownDomain(page, 14, 'hadrian-slider');
    await expect(dueToday(page)).toHaveText('$6.24');
    const line = page.locator('.cp-opt-row', { hasText: 'Extra IPv4 addresses' }).locator('.irs-line');
    const box = await line.boundingBox();
    expect(box?.width ?? 0, 'the slider track is laid out').toBeGreaterThan(100);
    // Drag the handle to the 4 mark of 0..10.
    const handle = page.locator('.irs-slider.single').first();
    const h = await handle.boundingBox();
    await page.mouse.move(h.x + h.width / 2, h.y + h.height / 2);
    await page.mouse.down();
    await page.mouse.move(box.x + box.width * 0.4, h.y + h.height / 2, { steps: 8 });
    await page.mouse.up();
    const n = Number(await page.locator('#inputConfigOption3').inputValue());
    expect(n).toBeGreaterThan(0);
    await expect(dueToday(page)).toHaveText(usd(6.24 + 1.5 * n));
  });

  test('OF-17 the product custom field shows its label and help text and is optional', async ({ page }) => {
    await ownDomain(page, 15, 'hadrian-fields');
    const field = page.locator('.cp-field', { has: page.locator('label[for=customfield1]') });
    await expect(field.locator('label')).toHaveText(/^Project name\s*$/);
    await expect(field.locator('.cp-field-help')).toHaveText('Shown on your invoices');
    await expect(field.locator('input[name="customfield[1]"]')).toBeVisible();
    // Not required: an empty field does not stop the cart.
    await reviewCart(page);
    await expect(page.locator('[data-cart-item="product-0"]')).toContainText('Business');
  });

  test('OF-21 Review cart shows the validation banner, then commits once the error is fixed', async ({ page }) => {
    const errors = watchErrors(page);
    // A server product with no hostname or root password: WHMCS refuses it.
    await page.goto('/cart.php?a=add&pid=16');
    await page.waitForURL(/a=confproduct/);
    expect(await tpl(page)).toBe('configureproduct');
    await page.locator('#btnCompleteProductConfig').click();
    const banner = page.locator('#cpInlineBanner');
    await expect(banner).toBeVisible();
    await expect(banner).toHaveClass(/cp-alert-error/);
    await expect(banner).toContainText(/hostname/i);
    expect(page.url()).toMatch(/a=confproduct/);
    await expect(page.locator('#btnCompleteProductConfig'), 'enabled again').toBeEnabled();

    await page.locator('#inputHostname').fill('server1.hadrian-test.example');
    await page.locator('#inputRootpw').fill('Root!Pass-2026x');
    await page.locator('#inputNs1prefix').fill('ns1');
    await page.locator('#inputNs2prefix').fill('ns2');
    await reviewCart(page);
    const card = page.locator('[data-cart-item="product-0"]');
    await expect(card).toContainText('VPS 2 GB');
    await expect(card.locator('.ct-product-domain')).toHaveText('server1.hadrian-test.example');
    expect(errors).toEqual([]);
  });

  test('OF-22 a promo code on the configure step: refused, no items qualify, accepted, then re-priced after a change', async ({ page }) => {
    const errors = watchErrors(page);
    orderPhp('promo', PROMO, '10', '14');
    try {
      await ownDomain(page, 14, 'hadrian-promo');
      await expect(dueToday(page)).toHaveText('$6.24');
      const banner = page.locator('#cpInlineBanner');

      await page.locator('#promocode').fill('NOT-A-REAL-CODE');
      await page.locator('.cp-promo-apply').click();
      await expect(banner).toHaveClass(/cp-alert-error/);
      await expect(banner.locator('.cp-alert-title')).toHaveText('Promo code');
      expect(page.url()).toMatch(/a=confproduct/);

      // The fixture code discounts nothing ("applies to" is empty): the info banner.
      await page.locator('#promocode').fill('HADRIAN10');
      await page.locator('.cp-promo-apply').click();
      await expect(banner).toHaveClass(/cp-alert-info/);
      await expect(banner.locator('.cp-alert-body')).toContainText(/no items qualify/i);

      await page.locator('#promocode').fill(PROMO);
      await page.locator('.cp-promo-apply').click();
      await expect(banner).toHaveClass(/cp-alert-success/);
      const promoRow = page.locator('#producttotal [data-promo-row="1"]');
      await expect(promoRow).toBeVisible();
      await expect(promoRow.locator('.pull-left')).toContainText('10%');
      await expect(promoRow.locator('.pull-right')).toHaveText(/\$0\.62/);
      await expect(dueToday(page), '6.24 - 10%').toHaveText(/\$5\.62/);

      // Changing the plan re-fetches the cart-wide discount: 10% of 8.24.
      await page.locator('#inputConfigOption1').selectOption('3');
      await expect(promoRow.locator('.pull-right')).toHaveText(/\$0\.82/);
      await expect(dueToday(page)).toHaveText(/\$7\.42/);
      // It reached the cart too.
      await reviewCart(page);
      await expect(page.locator('#discount')).toHaveText(/\$0\.82/);
      await expect(page.locator('#totalDueToday')).toHaveText(/\$7\.42/);
      await page.goto('/cart.php?a=removepromo');
      expect(errors).toEqual([]);
    } finally {
      orderPhp('promo-delete', PROMO);
    }
  });
});

// ==================================================================== OF-D
test.describe('OF-D Product domain step', () => {
  test('OF-29 option cards: register, transfer and own domain, each with its own panel', async ({ page }) => {
    const errors = watchErrors(page);
    await page.goto('/cart.php?a=add&pid=14');
    expect(await tpl(page)).toBe('configureproductdomain');
    const options = await page.locator('input[name=domainoption]').evaluateAll(es => es.map(e => e.value));
    expect(options).toEqual(['register', 'transfer', 'owndomain']);
    await expect(page.locator('input[name=domainoption][value=register]'), 'TLDs are priced: register first').toBeChecked();
    await expect(page.locator('.dp-panel.is-active')).toHaveAttribute('data-panel', 'register');
    const tlds = await page.locator('.dp-panel[data-panel=register] [data-input=tld] option').evaluateAll(es => es.map(e => e.value));
    expect(tlds).toEqual(expect.arrayContaining(['.com', '.net', '.org', '.co.uk', '.io', '.dev']));
    for (const opt of ['transfer', 'owndomain', 'register']) {
      await page.locator(`label:has(input[name=domainoption][value=${opt}])`).click();
      await expect(page.locator('.dp-panel.is-active'), opt).toHaveAttribute('data-panel', opt);
      await expect(page.locator('.dp-panel.is-active')).toHaveCount(1);
    }
    expect(errors).toEqual([]);
  });

  test('OF-30 an invalid own domain is refused on the domain step with an inline error', async ({ page }) => {
    await page.goto('/cart.php?a=add&pid=14');
    await page.locator('label:has(input[name=domainoption][value=owndomain])').click();
    const panel = page.locator('.dp-panel[data-panel=owndomain]');
    await panel.locator('[data-input=sld]').fill('x y');
    await panel.locator('[data-input=tld]').fill('com');
    await page.locator('button.dp-continue').click();
    await expect(panel.locator('[data-hadrian-domain-error]')).toBeVisible({ timeout: 10_000 });
    await expect(panel.locator('[data-hadrian-domain-error]')).toContainText(/not valid/i);
    expect(await tpl(page)).toBe('configureproductdomain');
  });

  test('OF-30 a signed-in customer who uses their own domain stays signed in', async ({ page }) => {
    const buyer = newBuyer();
    try {
      await signIn(page, buyer);
      await page.goto('/cart.php?a=add&pid=14');
      await page.locator('label:has(input[name=domainoption][value=owndomain])').click();
      const panel = page.locator('.dp-panel[data-panel=owndomain]');
      await panel.locator('[data-input=sld]').fill(`hadrian-own-${stamp()}`);
      await panel.locator('[data-input=tld]').fill('com');
      await page.locator('button.dp-continue').click();
      await page.waitForURL(/a=confproduct/);
      expect(await auth(page), 'still signed in on the configure step').toBe('in');
    } finally {
      dropClients(buyer.clientId);
    }
  });

  test('OF-30 choosing "use my own domain" keeps what is already in the cart', async ({ page }) => {
    await addStraightToCart(page, 21);
    await expect(page.locator('[data-cart-item^="product-"]')).toHaveCount(1);
    await ownDomain(page, 14, `hadrian-keep-${stamp()}`);
    await reviewCart(page);
    await expect(page.locator('[data-cart-item^="product-"] .ct-product-title')).toHaveText(['DV SSL', 'Professional'], { timeout: 3000 });
  });

  test('OF-31 OF-35 register through the product: the form posts the contract and the cart gets the registration', async ({ page }) => {
    const errors = watchErrors(page);
    const name = `hadrian-reg-${stamp()}`;
    await page.goto('/cart.php?a=add&pid=14');
    await page.locator('label:has(input[name=domainoption][value=register])').click();
    const panel = page.locator('.dp-panel[data-panel=register]');
    await panel.locator('[data-input=sld]').fill(name);
    await panel.locator('[data-input=tld]').selectOption('.net');
    const [post] = await Promise.all([
      page.waitForRequest(r => r.method() === 'POST' && /cart\.php\?a=add&pid=14&domainselect=1/.test(r.url())),
      page.locator('button.dp-continue').click(),
    ]);
    const body = new URLSearchParams(post.postData());
    expect(body.get('domainoption')).toBe('register');
    expect(body.getAll('domains[]')).toEqual([`${name}.net`]);
    expect(body.get('pid')).toBe('14');
    await page.waitForURL(/a=confproduct/);
    expect(await tpl(page)).toBe('configureproduct');
    await expect(page.locator('.cp-plan-hero-domain-name')).toHaveText(`${name}.net`);
    await reviewCart(page);
    const domainCard = page.locator('[data-cart-item="domain-0"]');
    await expect(domainCard.locator('.ct-product-title')).toHaveText(`${name}.net`);
    await expect(domainCard.locator('.ct-product-eyebrow')).toHaveText('Domain Registration');
    await expect(domainCard.locator('.ct-product-price .amount')).toHaveText(/\$14\.49/);
    await expect(page.locator('#subtotal'), '6.24 + 14.49').toHaveText(/\$20\.73/);
    expect(errors).toEqual([]);
  });

  test('OF-31 OF-34 a mistyped name under Register is refused on the domain step, not added to the cart', async ({ page }) => {
    await page.goto('/cart.php?a=add&pid=14');
    await page.locator('label:has(input[name=domainoption][value=register])').click();
    const panel = page.locator('.dp-panel[data-panel=register]');
    await panel.locator('[data-input=sld]').fill('x y');
    await page.locator('button.dp-continue').click();
    await page.waitForLoadState('load');
    await page.waitForTimeout(2000);
    expect(await tpl(page), 'still on the domain step').toBe('configureproductdomain');
    await expect(page.locator('#order-standard_cart .alert-danger, .dp-error').first()).toBeVisible();
  });

  test('OF-31 a name that is already taken is refused under Register', async ({ page }) => {
    // WHMCS's own lookup answers this one (google.com is registered).
    await page.goto('/cart.php?a=add&pid=14');
    await page.locator('label:has(input[name=domainoption][value=register])').click();
    const panel = page.locator('.dp-panel[data-panel=register]');
    await panel.locator('[data-input=sld]').fill('google');
    await panel.locator('[data-input=tld]').selectOption('.com');
    await page.locator('button.dp-continue').click();
    await expect(panel.locator('[data-hadrian-domain-error]')).toContainText(/google\.com is unavailable/i, { timeout: 15_000 });
    expect(await tpl(page)).toBe('configureproductdomain');
  });

  test('OF-32 a name that is not registered anywhere is refused under Transfer', async ({ page }) => {
    await page.goto('/cart.php?a=add&pid=13');
    await page.locator('label:has(input[name=domainoption][value=transfer])').click();
    const panel = page.locator('.dp-panel[data-panel=transfer]');
    await panel.locator('[data-input=sld]').fill(`hadrian-xfer-${stamp()}`);
    await panel.locator('[data-input=tld]').selectOption('.com');
    await page.locator('button.dp-continue').click();
    await expect(panel.locator('[data-hadrian-domain-error]')).toContainText(/does not appear to be registered/i, { timeout: 15_000 });
    expect(await tpl(page)).toBe('configureproductdomain');
  });

  test('OF-32 OF-47 OF-51 transfer through the product: Checkout first asks for the EPP code, refuses it empty, then goes on', async ({ page }) => {
    const errors = watchErrors(page);
    // A transfer needs a name that is registered elsewhere: WHMCS's lookup
    // refuses any other (standard_cart does the same). Nothing is ordered.
    const name = 'google';
    await page.goto('/cart.php?a=add&pid=13');
    await page.locator('label:has(input[name=domainoption][value=transfer])').click();
    const panel = page.locator('.dp-panel[data-panel=transfer]');
    await panel.locator('[data-input=sld]').fill(name);
    await panel.locator('[data-input=tld]').selectOption('.com');
    await page.locator('button.dp-continue').click();
    await page.waitForURL(/a=confproduct/, { timeout: 15_000 });
    await reviewCart(page);
    const card = page.locator('[data-cart-item="domain-0"]');
    await expect(card.locator('.ct-product-eyebrow')).toHaveText('Domain Transfer');
    await expect(card.locator('.ct-cycle-value'), 'a transfer has no period select').toHaveText(/^1 /);
    await expect(card.locator('.ct-product-price .amount')).toHaveText(/\$12\.99/);
    // Checkout sends the customer to the domain step for the EPP code first.
    await page.locator('#checkout').click();
    await page.waitForURL(/a=confdomains/);
    expect(await tpl(page)).toBe('configuredomains');
    await expect(page.locator('.cd-domain-head-name')).toHaveText(`${name}.com`);
    await expect(page.locator('.badge-ok'), 'the domain has hosting in this cart').toBeVisible();
    await expect(page.locator('.cd-nameservers-card'), 'no nameservers: hosting provides them').toHaveCount(0);
    const epp = page.locator('input[name="epp[0]"]');
    await expect(epp).toBeVisible();
    await page.locator('.cd-footer button[type=submit]').click();
    await page.waitForLoadState('load');
    await expect(page.locator('#frmConfigureDomains .alert-danger'), 'an empty EPP code is refused').toBeVisible();
    await expect(page.locator('#frmConfigureDomains .alert-danger li').first()).not.toBeEmpty();
    await page.locator('input[name="epp[0]"]').fill('EPP-ORDER-SPEC');
    await page.locator('.cd-footer button[type=submit]').click();
    await page.waitForURL(/a=(checkout|view)/);
    await page.goto('/cart.php?a=confdomains');
    await expect(page.locator('input[name="epp[0]"]'), 'the code is kept').toHaveValue('EPP-ORDER-SPEC');
    expect(errors).toEqual([]);
  });

  test('OF-33 a domain already in the cart is offered as an option for the next plan', async ({ page, context }) => {
    const errors = watchErrors(page);
    const name = `hadrian-incart-${stamp()}`;
    // A registration with no plan yet (signed in: the checker has no captcha then).
    await loginClient(context.request, 'full');
    await addDomainOnly(page, `${name}.com`);
    await page.goto('/cart.php?a=add&pid=14');
    const options = await page.locator('input[name=domainoption]').evaluateAll(es => es.map(e => e.value));
    expect(options[0], 'listed first').toBe('incart');
    await page.locator('label:has(input[name=domainoption][value=incart])').click();
    await expect(page.locator('.dp-panel.is-active')).toHaveAttribute('data-panel', 'incart');
    const select = page.locator('.dp-panel[data-panel=incart] [data-input=incartsld]');
    await expect(select).toBeVisible();
    await expect(select.locator('option')).toHaveText([`${name}.com`]);
    expect(errors).toEqual([]);
  });

  test('OF-33 choosing the domain already in the cart attaches it to the plan', async ({ page, context }) => {
    const name = `hadrian-incart-${stamp()}`;
    await loginClient(context.request, 'full');
    await addDomainOnly(page, `${name}.com`);
    await page.goto('/cart.php?a=add&pid=14');
    await page.locator('label:has(input[name=domainoption][value=incart])').click();
    await page.locator('.dp-panel[data-panel=incart] button.dp-search-cta').click();
    await page.waitForURL(/a=confproduct/);
    await expect(page.locator('.cp-plan-hero-domain-name')).toHaveText(`${name}.com`, { timeout: 3000 });
    await reviewCart(page);
    await expect(page.locator('[data-cart-item="product-0"] .ct-product-domain')).toHaveText(`${name}.com`);
  });

  test('OF-36 the AJAX domain-options fragment answers for a register lookup', async ({ page }) => {
    // domainoptions.tpl is WHMCS's legacy availability fragment; nothing in the
    // cart calls it any more, but cart.php still renders it on request.
    await page.goto('/cart.php?a=add&pid=14');
    const html = await page.evaluate(async () => {
      const r = await fetch('/cart.php', { method: 'POST', headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        body: new URLSearchParams({ a: 'domainoptions', sld: 'hadrian-options-fragment', tld: '.com', checktype: 'register', ajax: '1', token: window.csrfToken }) });
      return { status: r.status, body: await r.text() };
    });
    expect(html.status).toBe(200);
    expect(html.body).not.toMatch(/Smarty|Fatal|Exception/);
  });
});

// ==================================================================== OF-E
test.describe('OF-E Domain register, transfer, search', () => {
  test('OF-38 the captcha is printed once, inside the live search form, for guests only', async ({ page, context }) => {
    await page.goto('/cart.php?a=add&domain=register');
    expect(await tpl(page)).toBe('domainregister');
    await expect(page.locator('#captchaContainer')).toHaveCount(1);
    await expect(page.locator('#frmDomainChecker #captchaContainer')).toHaveCount(1);
    await loginClient(context.request, 'full');
    await page.reload();
    expect(await auth(page)).toBe('in');
    await expect(page.locator('#captchaContainer'), 'no captcha when signed in').toHaveCount(0);
  });

  test('OF-39 filters: TLD list mirrors the hidden select, keeps one, length pills and safe search', async ({ page, context }) => {
    const errors = watchErrors(page);
    await loginClient(context.request, 'full');
    await page.goto('/cart.php?a=add&domain=register');
    const panel = page.locator('[data-dr-filters-panel]');
    await expect(panel).toBeHidden();
    await page.locator('[data-dr-filters-toggle]').click();
    await expect(panel).toBeVisible();
    const selected = () => page.locator('.dr-tld-source').evaluate(s => [...s.selectedOptions].map(o => o.value));
    const count = page.locator('[data-dr-tld-count]');
    const start = await selected();
    expect(start.length).toBeGreaterThan(0);
    await expect(count).toHaveText(String(start.length));
    // Untick every selected TLD: the last one stays.
    for (const t of start) await page.locator(`.dr-tld-option[data-tld="${t}"]`).click();
    expect(await selected(), 'at least one TLD stays').toEqual([start[start.length - 1]]);
    await expect(count).toHaveText('1');
    // Tick one back on.
    const other = await page.locator('.dr-tld-option:not(.active)').first().getAttribute('data-tld');
    await page.locator(`.dr-tld-option[data-tld="${other}"]`).click();
    await expect(page.locator(`.dr-tld-option[data-tld="${other}"]`)).toHaveAttribute('aria-checked', 'true');
    expect(await selected()).toContain(other);
    // Search narrows the list.
    await page.locator('[data-dr-tld-search]').fill('co.uk');
    await expect(page.locator('.dr-tld-option:visible')).toHaveCount(1);
    await page.locator('[data-dr-tld-search]').fill('');
    // Length pill -> hidden maxLength select.
    const pill = page.locator('.dr-length-pill').nth(1);
    await pill.click();
    await expect(pill).toHaveClass(/active/);
    expect(await page.locator('.dr-length-source').inputValue()).toBe(await pill.getAttribute('data-len'));
    // Safe search is the real input the form submits.
    const safe = page.locator('input[name=filter]');
    const was = await safe.isChecked();
    await page.locator('label.dr-safesearch').click();
    expect(await safe.isChecked()).toBe(!was);
    await page.keyboard.press('Escape');
    await expect(panel).toBeHidden();
    expect(errors).toEqual([]);
  });

  test('OF-40 search results: available with its price, an unsold TLD flagged, and add to cart', async ({ page, context }) => {
    // Smart search is on locally: the Classic tab copies the query into the AI
    // form and WHMCS answers through its smart lookup, which reports every name
    // available (the stub registrar's "taken" answer is never consulted), so
    // the taken and invalid states cannot be produced on this stack.
    test.setTimeout(2 * 60_000);
    const errors = watchErrors(page);
    await loginClient(context.request, 'full');
    await page.goto('/cart.php?a=add&domain=register');
    expect(await tpl(page)).toBe('domainregister');
    await page.locator('[role=tab][data-mode=classic]').click();
    await expect(page.locator('.dr-search')).toHaveAttribute('data-search-mode', 'classic');
    const result = page.locator('#primaryLookupResult');
    const id = stamp();

    await classicSearch(page, `hadrian-${id}.xyz`);
    await expect(result.locator('.domain-tld-unavailable')).toBeVisible({ timeout: 30_000 });

    const name = `hadrian-avail-${id}.com`;
    await classicSearch(page, name);
    await expect(result.locator('.domain-available')).toContainText(name, { timeout: 30_000 });
    await expect(result.locator('.domain-tld-unavailable')).toBeHidden();
    await expect(result.locator('.domain-price .price')).toContainText('$12.99');
    const add = result.locator('.btn-add-to-cart');
    await expect(add.locator('.to-add')).toBeVisible();
    await Promise.all([
      page.waitForResponse(r => /cart\.php/.test(r.url()) && r.request().method() === 'POST', { timeout: 30_000 }),
      add.click(),
    ]);
    await expect(add.locator('.added')).toBeVisible();

    await page.goto('/cart.php?a=view');
    await expect(page.locator('[data-cart-item^="domain-"] .ct-product-title')).toHaveText(name);
    await expect(page.locator('[data-cart-item^="domain-"] .ct-product-price .amount')).toHaveText(/\$12\.99/);
    expect(errors).toEqual([]);
  });

  test('OF-42 ?query= searches on load', async () => {
    test.skip(true, 'smart domain search is on locally (a WHMCS setting): WHMCS passes ?query= only as $lookupTerm, which the smart-mode form never reads (stock standard_cart behaves the same), so nothing is searched on load and $invalid is never set');
  });

  test('OF-43 the TLD pricing table: register, transfer and renew per TLD with their periods', async ({ page }) => {
    await page.goto('/cart.php?a=add&domain=register');
    const row = tld => page.locator('.dr-pricing-row:not(.no-tlds)').filter({ has: page.locator('strong', { hasText: new RegExp(`^\\.${tld.replace('.', '\\.')}$`) }) });
    for (const [tld, reg, renew] of [['com', '12.99', '13.99'], ['net', '14.49', '15.49'], ['co.uk', '8.99', '9.99'], ['dev', '15.00', '16.00']]) {
      const cols = row(tld).locator('.col-4');
      await expect(cols.nth(0), `.${tld} register`).toContainText(`$${reg}`);
      await expect(cols.nth(0)).toContainText('1 Year');
      await expect(cols.nth(1), `.${tld} transfer`).toContainText(`$${reg}`);
      await expect(cols.nth(2), `.${tld} renew`).toContainText(`$${renew}`);
    }
    await expect(row('co.uk').locator('.tld-sale-group')).toHaveText(/sale/i);
    await expect(page.locator('.dr-tld-filters a[data-category]')).toHaveCount(2);
  });

  test('OF-43 a TLD category filter narrows the pricing table and stays on the page', async ({ page }) => {
    test.fail(true, 'BUG: domainregister.tpl:486 renders the category filters as <a href="#"> and :603 clicks the first one, but the handler that filters .tld-row lives in WHMCS\'s twenty-one scripts.js, which the order form does not load: nothing is filtered, and with the theme\'s <base href> the click navigates to the site root');
    await page.goto('/cart.php?a=add&domain=register');
    await page.locator('.dr-tld-filters a[data-category="Other"]').click();
    await page.waitForLoadState('load');
    expect(await tpl(page), 'still on the domain page').toBe('domainregister');
    await expect(page.locator('.dr-pricing-row:not(.no-tlds):visible')).toHaveCount(1);
    await expect(page.locator('.dr-pricing-row:not(.no-tlds):visible strong')).toHaveText('.dev');
  });

  test('OF-44 transfer page: no captcha signed in, empty submit stopped, an unregistered name refused inline', async ({ page, context }) => {
    const errors = watchErrors(page);
    await loginClient(context.request, 'full');
    await page.goto('/cart.php?a=add&domain=transfer');
    expect(await tpl(page)).toBe('domaintransfer');
    await expect(page.locator('#captchaContainer'), 'signed in: no captcha').toHaveCount(0);

    // An empty submit is stopped in the browser: no request.
    let posted = 0;
    page.on('request', r => { if (r.method() === 'POST' && /cart\.php$/.test(r.url())) posted++; });
    await page.locator('#btnTransferDomain').click();
    await expect(page.locator('#inputTransferDomain')).toBeFocused();
    expect(posted).toBe(0);

    // Only a registered name can be transferred. WHMCS's lookup on this stack
    // reports every name unregistered (the stub registrar's "taken" answer is
    // not consulted), so the AJAX add always ends in the inline refusal here;
    // the success path (to configure domains, EPP kept) is OF-32's.
    await page.locator('#inputTransferDomain').fill(`hadrian-free-${stamp()}.com`);
    await page.locator('#inputAuthCode').fill('EPP-FREE-1');
    await Promise.all([
      page.waitForResponse(r => /cart\.php$/.test(r.url()) && /addDomainTransfer/.test(r.request().postData() || ''), { timeout: 30_000 }),
      page.locator('#btnTransferDomain').click(),
    ]);
    await expect(page.locator('#transferUnavailable')).toBeVisible();
    await expect(page.locator('#transferUnavailable')).toContainText(/isn't registered|not registered/i);
    expect(page.url()).toMatch(/domain=transfer/);
    await expect(page.locator('#btnTransferDomain'), 'usable again').toBeEnabled();
    expect(errors).toEqual([]);
  });

  test('OF-45 several domains are added one after another', async ({ page, context }) => {
    test.setTimeout(2 * 60_000);
    await loginClient(context.request, 'full');
    await page.goto('/cart.php?a=add&domain=register');
    await page.locator('[role=tab][data-mode=classic]').click();
    const id = stamp();
    const names = [`hadrian-first-${id}.com`, `hadrian-second-${id}.net`];
    for (const name of names) {
      await classicSearch(page, name);
      await expect(page.locator('#primaryLookupResult .domain-available')).toContainText(name, { timeout: 30_000 });
      const add = page.locator('#primaryLookupResult .btn-add-to-cart');
      await expect(add.locator('.to-add'), 'the button is reset for the next name').toBeVisible();
      await Promise.all([
        page.waitForResponse(r => /cart\.php/.test(r.url()) && r.request().method() === 'POST', { timeout: 30_000 }),
        add.click(),
      ]);
      await expect(add.locator('.added')).toBeVisible();
    }
    await page.goto('/cart.php?a=view');
    await expect(page.locator('[data-cart-item^="domain-"] .ct-product-title')).toHaveText(names);
    await expect(page.locator('#subtotal'), '12.99 + 14.49').toHaveText(/\$27\.48/);
  });
});

// ==================================================================== OF-F
/** A Classic-tab search, once the previous lookup has finished (the live search button is disabled until then). */
async function classicSearch(page, query) {
  await expect(page.locator('#btnCheckAvailability')).toBeEnabled({ timeout: 30_000 });
  await expect(page.locator('#btnCheckAvailability')).not.toHaveClass(/disabled/);
  await page.locator('#dr-alt-domain').fill(query);
  await page.locator('#dr-alt-btnClassic').click();
}

/** Signed in as `full`: a domain-only registration through the checker (no captcha). */
async function addDomainOnly(page, name) {
  await page.goto('/cart.php?a=add&domain=register');
  await page.locator('[role=tab][data-mode=classic]').click();
  await classicSearch(page, name);
  const add = page.locator('#primaryLookupResult .btn-add-to-cart');
  await expect(page.locator('#primaryLookupResult .domain-available')).toContainText(name, { timeout: 30_000 });
  await expect(add.locator('.to-add')).toBeVisible();
  await Promise.all([
    page.waitForResponse(r => /cart\.php/.test(r.url()) && r.request().method() === 'POST', { timeout: 30_000 }),
    add.click(),
  ]);
  await expect(add.locator('.added')).toBeVisible();
}

test.describe('OF-F Domain configuration', () => {
  test('OF-46 OF-48 OF-50 OF-51 domain card: period, no hosting, priced add-ons and nameservers reach the cart', async ({ page, context }) => {
    test.setTimeout(2 * 60_000);
    const errors = watchErrors(page);
    await loginClient(context.request, 'full');
    const name = `hadrian-cd-${stamp()}.com`;
    await addDomainOnly(page, name);
    await page.goto('/cart.php?a=confdomains');
    expect(await tpl(page)).toBe('configuredomains');
    const card = page.locator('.cd-domain-card').first();
    await expect(card.locator('.cd-domain-head-name')).toHaveText(name);
    await expect(card.locator('.cd-field', { hasText: 'Registration Period' }).locator('.cd-field-static')).toHaveText(/^1 /);
    await expect(card.locator('a.badge-warn'), 'no hosting: a link to the store').toHaveAttribute('href', /cart\.php$/);
    await expect(card.locator('input[name="epp[0]"]'), 'no EPP for a registration').toHaveCount(0);

    const dns = card.locator('.panel-addon', { hasText: 'DNS Management' });
    const idp = card.locator('.panel-addon', { hasText: 'ID Protection' });
    const fwd = card.locator('.panel-addon', { hasText: 'Email Forwarding' });
    await expect(dns.locator('.panel-price')).toHaveText(/\$2\.00 USD \/ 1/);
    await expect(idp.locator('.panel-price')).toHaveText(/\$4\.00 USD \/ 1/);
    await expect(fwd.locator('.panel-price')).toHaveText(/\$1\.50 USD \/ 1/);
    await dns.click();
    await idp.click();
    await expect(dns).toHaveClass(/panel-addon-selected/);
    await expect(idp).toHaveClass(/panel-addon-selected/);
    await expect(fwd).not.toHaveClass(/panel-addon-selected/);

    // Nameservers: shown because the domain has no hosting, prefilled with the defaults.
    await expect(page.locator('#inputNs1')).toHaveValue('ns1.example.com');
    for (const n of [1, 2, 3, 4, 5]) await expect(page.locator(`#inputNs${n}`)).toBeVisible();
    // A malformed nameserver is listed as an error and nothing is saved.
    await page.locator('#inputNs1').fill('not a nameserver!');
    await page.locator('.cd-footer button[type=submit]').click();
    await page.waitForLoadState('load');
    if (/a=confdomains/.test(page.url())) {
      await expect(page.locator('#frmConfigureDomains .alert-danger')).toBeVisible();
      await page.locator('#inputNs1').fill('ns1.hadrian-test.example');
      await page.locator('.cd-footer button[type=submit]').click();
    }
    await page.waitForURL(/a=view/);
    const line = page.locator('[data-cart-item="domain-0"]');
    await expect(line.locator('.ct-product-domain')).toContainText('DNS Management');
    await expect(line.locator('.ct-product-domain')).toContainText('ID Protection');
    await expect(line.locator('.ct-product-domain')).not.toContainText('Email Forwarding');
    await expect(line.locator('.ct-product-price .amount'), '12.99 + 2.00 + 4.00').toHaveText(/\$18\.99/);
    expect(errors).toEqual([]);
  });

  test('OF-49 a .co.uk registration asks for its registry fields', async ({ page, context }) => {
    await loginClient(context.request, 'full');
    const name = `hadrian-uk-${stamp()}.co.uk`;
    await addDomainOnly(page, name);
    await page.goto('/cart.php?a=confdomains');
    const card = page.locator('.cd-domain-card', { hasText: name });
    await expect(card.locator('.cd-fields .cd-field').first()).toBeVisible();
    await expect(card.locator('.cd-fields')).toContainText(/Legal Type/i);
    await expect(card.locator('.panel-addon', { hasText: 'DNS Management' }).locator('.panel-price')).toHaveText(/\$2\.00/);
  });

  test('OF-56 OF-48 the cart period select re-prices the domain and its add-ons', async ({ page, context }) => {
    test.setTimeout(2 * 60_000);
    const errors = watchErrors(page);
    await loginClient(context.request, 'full');
    const name = `hadrian-period-${stamp()}.com`;
    await addDomainOnly(page, name);
    await page.goto('/cart.php?a=view');
    const select = page.locator(`[data-cart-item="domain-0"] select.ct-cycle-value`);
    await expect(select.locator('option')).toHaveCount(3);
    await expect(select.locator('option').nth(1)).toHaveText(/2 Years @ \$25\.98/);
    await Promise.all([
      page.waitForResponse(r => /cart\.php/.test(r.url()) && r.request().method() === 'POST', { timeout: 30_000 }),
      select.selectOption({ index: 1 }),
    ]);
    await expect(page.locator(`[data-cart-item="domain-0"] .ct-product-price .amount`)).toHaveText(/\$25\.98/);
    await page.reload();
    await expect(page.locator('#subtotal'), 'kept after a reload').toHaveText(/\$25\.98/);
    await page.goto('/cart.php?a=confdomains');
    await expect(page.locator('.cd-domain-card').first().locator('.cd-field-static').first()).toHaveText(/^2 /);
    await expect(page.locator('.panel-addon', { hasText: 'DNS Management' }).locator('.panel-price'), '2.00 a year x 2').toHaveText(/\$4\.00 USD \/ 2/);
    expect(errors).toEqual([]);
  });
});

// ==================================================================== OF-G
test.describe('OF-G Cart', () => {
  test('OF-54 OF-55 OF-60 OF-61 remove one item and empty the cart through their modals', async ({ page }) => {
    const errors = watchErrors(page);
    await addStraightToCart(page, 21);
    await addStraightToCart(page, 22);
    await page.goto('/cart.php?a=view');
    await expect(page.locator('[data-cart-item^="product-"]')).toHaveCount(2);
    // No hook or gateway output on this install: no empty "Last chance" card.
    await expect(page.locator('.ct-recommend')).toHaveCount(0);
    await expect(page.locator('.ct-hookout')).toHaveCount(0);

    await page.locator('[data-cart-item="product-0"] .ct-product-remove').click();
    const remove = page.locator('#modalRemoveItem');
    await expect(remove).toBeVisible();
    await expect(page.locator('#inputRemoveItemType')).toHaveValue('p');
    await expect(page.locator('#inputRemoveItemRef')).toHaveValue('0');
    await remove.locator('button[type=submit]').click();
    await page.waitForLoadState('load');
    await expect(page.locator('[data-cart-item^="product-"]')).toHaveCount(1);
    await expect(page.locator('[data-cart-item^="product-"] .ct-product-title')).toHaveText('Wildcard SSL');
    await expect(page.locator('#totalDueToday')).toHaveText(/\$95\.00/);

    await page.locator('#btnEmptyCart').click();
    const empty = page.locator('#modalEmptyCart');
    await expect(empty).toBeVisible();
    await empty.locator('button[type=submit]').click();
    await page.waitForLoadState('load');
    expect(await tpl(page)).toBe('viewcart');
    await expect(page.locator('body')).toHaveAttribute('data-data', 'empty');
    await expect(page.locator('.vc-when-empty .ct-empty')).toBeVisible();
    await expect(page.locator('.vc-when-full')).toBeHidden();
    await expect(page.locator('.ct-empty-actions a').nth(0)).toHaveAttribute('href', /cart\.php$/);
    await expect(page.locator('.ct-empty-actions a').nth(1)).toHaveAttribute('href', /a=add&domain=register/);
    await expect(page.locator('#btnEmptyCart')).toHaveCount(0);
    expect(errors).toEqual([]);
  });

  test('OF-52 OF-53 a configured product card lists its options and add-ons, and Edit reopens them', async ({ page }) => {
    const errors = watchErrors(page);
    await ownDomain(page, 15, 'hadrian-edit');
    await page.locator('#inputConfigOption1').selectOption('2');
    await expect(dueToday(page)).toHaveText('$12.49');
    await page.locator('label.st-addon').click();
    await expect(dueToday(page)).toHaveText('$21.49');
    await reviewCart(page);
    const card = page.locator('[data-cart-item="product-0"]');
    await expect(card.locator('.ct-product-title')).toHaveText('Business');
    await expect(card.locator('.ct-product-domain')).toHaveText('hadrian-edit.com');
    await expect(card.locator('.ct-addon-row', { hasText: 'Data centre' })).toContainText('Frankfurt');
    await expect(card.locator('.ct-addon-row', { hasText: 'Daily backups' })).toContainText('No');
    await expect(card.locator('.ct-addon-row', { hasText: 'Priority support (hadrian-test)' })).toContainText('$9.00');
    await expect(card.locator('.ct-cycle-value')).toHaveText('Monthly');
    await expect(page.locator('#totalDueToday')).toHaveText(/\$21\.49/);

    await card.locator('.ct-manage-addons a').click();
    await page.waitForURL(/a=confproduct&i=0/);
    expect(await tpl(page)).toBe('configureproduct');
    await expect(page.locator('#inputConfigOption1')).toHaveValue('2');
    await expect(page.locator('input[name="addons[1]"]')).toBeChecked();
    await expect(dueToday(page)).toHaveText('$21.49');
    expect(errors).toEqual([]);
  });

  test('OF-57 promo banners: refused, applied without a discount, accepted as a pill with its discount, removed', async ({ page }) => {
    const errors = watchErrors(page);
    orderPhp('promo', PROMO, '10', '21');
    try {
      await addStraightToCart(page, 21);
      await page.goto('/cart.php?a=view');
      const apply = async code => {
        await page.locator('#inputPromotionCode').fill(code);
        await page.locator('button[name=validatepromo]').click();
        await page.waitForLoadState('load');
      };
      await apply('NOT-A-REAL-CODE');
      await expect(page.locator('.vc-alert.warn')).toBeVisible();
      await expect(page.locator('.vc-alert.warn')).not.toBeEmpty();
      await expect(page.locator('.applied-pill')).toHaveCount(0);

      // HADRIAN10 is valid but discounts nothing in this catalogue.
      await apply('HADRIAN10');
      await expect(page.locator('.vc-alert.info')).toBeVisible();
      await expect(page.locator('.applied-pill')).toContainText('HADRIAN10');
      await expect(page.locator('#totalDueToday')).toHaveText(/\$15\.00/);
      await page.locator('a.ct-promo-remove').click();
      await page.waitForLoadState('load');

      await apply(PROMO);
      await expect(page.locator('.vc-alert.ok')).toBeVisible();
      await expect(page.locator('.applied-pill')).toContainText(PROMO);
      await expect(page.locator('.ct-totals-row.discount .label')).toContainText('10%');
      await expect(page.locator('#discount'), '10% of 15.00').toHaveText(/\$1\.50/);
      await expect(page.locator('#totalDueToday')).toHaveText(/\$13\.50/);
      await page.locator('a.ct-promo-remove').click();
      await page.waitForLoadState('load');
      await expect(page.locator('.applied-pill')).toHaveCount(0);
      await expect(page.locator('#discount')).toHaveCount(0);
      await expect(page.locator('#inputPromotionCode')).toBeVisible();
      await expect(page.locator('#totalDueToday')).toHaveText(/\$15\.00/);
      expect(errors).toEqual([]);
    } finally {
      orderPhp('promo-delete', PROMO);
    }
  });

  test('OF-58 OF-59 a GB guest estimates 20% VAT on the domain, and the totals add up', async ({ page }) => {
    const errors = watchErrors(page);
    // Product 14 is not taxed; domain registrations are (TaxDomains).
    await registerWithProduct(page, 14, `hadrian-tax-${stamp()}`);
    await reviewCart(page);
    await expect(page.locator('#subtotal')).toHaveText(/\$19\.23/);
    await expect(page.locator('#taxTotal1'), 'no tax for the default country').toHaveCount(0);
    await page.locator('.ct-tab[data-tab=tax]').click();
    const panel = page.locator('.ct-tab-panel[data-panel=tax]');
    await expect(panel).toBeVisible();
    await panel.locator('#inputCountry').selectOption('GB');
    await panel.locator('[type=submit]').click();
    await page.waitForLoadState('load');
    const taxRow = page.locator('.ct-totals-row', { has: page.locator('#taxTotal1') });
    await expect(taxRow.locator('.label')).toHaveText(/VAT \(hadrian-test\) @ 20(\.00)?%/);
    await expect(page.locator('#taxTotal1'), '20% of 12.99').toHaveText(/\$2\.60/);
    await expect(page.locator('#totalDueToday')).toHaveText(/\$21\.83/);
    await expect(page.locator('#recurringMonthly .cost')).toHaveText(/\$6\.24/);
    await expect(page.locator('#recurringAnnually')).toBeVisible();

    // With 10% off both items: due today = subtotal - discount + tax, to the cent.
    orderPhp('promo', PROMO, '10', '14,D.com');
    try {
      await page.locator('#inputPromotionCode').fill(PROMO);
      await page.locator('button[name=validatepromo]').click();
      await page.waitForLoadState('load');
      const sub = money(await page.locator('#subtotal').innerText());
      const disc = Math.abs(money(await page.locator('#discount').innerText()));
      const tax = money(await page.locator('#taxTotal1').innerText());
      const total = money(await page.locator('#totalDueToday').innerText());
      expect(sub).toBeCloseTo(19.23, 2);
      expect(disc, '10% of 6.24 + 10% of 12.99').toBeCloseTo(0.62 + 1.30, 2);
      expect(tax).toBeGreaterThan(0);
      expect(Math.round((sub - disc + tax) * 100)).toBe(Math.round(total * 100));
      await page.goto('/cart.php?a=removepromo');
      expect(errors).toEqual([]);
    } finally {
      orderPhp('promo-delete', PROMO);
    }
  });
});

// ==================================================================== OF-H
test.describe('OF-H Checkout', () => {
  test('OF-62 OF-64 OF-65 OF-71 OF-75 a GB guest checks out: phone follows the country, the total gains VAT, the invoice carries it', async ({ page }) => {
    test.setTimeout(3 * 60_000);
    const errors = watchErrors(page);
    const name = `hadrian-vat-${stamp()}`;
    let clientId;
    try {
      await registerWithProduct(page, 14, name);
      await reviewCart(page);
      await toCheckout(page);
      // The WHMCS stubs scripts.min.js needs are in place.
      expect(await page.evaluate(() => [typeof WHMCS.payment.event.gatewayInit, typeof WHMCS.utils, WHMCS.jqClient === window.jQuery, typeof recalctotals])).toEqual(['function', 'object', true, 'function']);
      const banner = page.locator('.co-payment-card #totalCartPrice');
      await expect(banner).toHaveText(/\$19\.23/);

      const email = `flow+vat${Date.now()}@demo.hadrian.test`;
      await Promise.all([
        page.waitForResponse(r => /a=getCartTotal/.test(r.url()), { timeout: 30_000 }),
        fillNewCustomer(page, { email, country: 'GB', phone: '2079460123' }),
      ]);
      // Phone: the country moved the dial code to +44 (hidden field WHMCS reads).
      expect(await page.evaluate(() => window.intlTelInputGlobals.getInstance(document.getElementById('inputPhone')).getSelectedCountryData().iso2)).toBe('gb');
      await expect(page.locator('input[name=country-calling-code-phonenumber]')).toHaveValue('44');
      // Live total: 19.23 + 20% of 12.99.
      await expect(banner).toHaveText(/\$21\.83/);

      await page.locator('select[name="customfield[2]"]').selectOption('A friend');
      const notes = `order.spec note ${stamp()}`;
      await page.locator('textarea[name=notes]').fill(notes);
      const optin = page.locator('input[name=marketingoptin]');
      const hadOptin = (await optin.count()) > 0;
      if (hadOptin) { if (!(await optin.isChecked())) await page.locator('.co-mailing-toggle').click(); await expect(optin).toBeChecked(); }
      await expect(page.locator('input[name=paymentmethod][value=banktransfer]')).toBeChecked();
      await completeOrder(page, /viewinvoice\.php\?id=\d+/);
      expect(await tpl(page)).toBe('viewinvoice');
      expect(await auth(page)).toBe('in');

      const inv = orderPhp('invoice', String(invoiceIdOf(page)));
      clientId = inv.userid;
      expect(inv.subtotal).toBeCloseTo(19.23, 2);
      expect(inv.tax).toBeCloseTo(2.6, 2);
      expect(inv.taxrate).toBeCloseTo(20, 2);
      expect(inv.total).toBeCloseTo(21.83, 2);
      expect(inv.items.find(i => i.type === 'DomainRegister')).toMatchObject({ amount: 12.99, taxed: true });
      expect(inv.items.find(i => i.type === 'Hosting')).toMatchObject({ amount: 6.24, taxed: false });
      const client = orderPhp('client', String(clientId));
      expect(client.country).toBe('GB');
      expect(client.phonenumber).toBe('+44.2079460123');
      expect(client.customFields['How did you hear about us?']).toBe('A friend');
      if (hadOptin) expect(client.marketingOptIn, 'the mailing-list opt-in was saved').toBe(true);
      const ord = orderPhp('orders', String(clientId))[0];
      expect(ord.notes).toBe(notes);
      expect(errors).toEqual([]);
    } finally {
      dropClients(clientId);
    }
  });

  test('OF-75 the checkout summary total and VAT line follow the country', async ({ page }) => {
    test.fail(true, 'BUG: CartTotalUpdater.js updates only the first #totalCartPrice (payment.tpl:28); summary-aside.tpl:55-60 and :71 print the tax line and #totalDueToday once, server-side, so the sidebar keeps the pre-VAT total');
    await registerWithProduct(page, 14, `hadrian-aside-${stamp()}`);
    await reviewCart(page);
    await toCheckout(page);
    await Promise.all([
      page.waitForResponse(r => /a=getCartTotal/.test(r.url()), { timeout: 30_000 }),
      page.locator('#frmCheckout #inputCountry').selectOption('GB'),
    ]);
    await expect(page.locator('.co-payment-card #totalCartPrice')).toHaveText(/\$21\.83/);
    await expect(page.locator('.co-summary-total .value'), 'the sidebar total agrees').toHaveText(/\$21\.83/, { timeout: 5000 });
    await expect(page.locator('.co-summary-list #taxTotal1')).toHaveText(/\$2\.60/);
  });

  test('OF-63 OF-67 OF-68 the Sign-in tab: wrong password shown inline, right one signs in, the account picker toggles, the order is placed on that account', async ({ page }) => {
    test.setTimeout(3 * 60_000);
    const errors = watchErrors(page);
    const buyer = newBuyer();
    try {
      await addStraightToCart(page, 21);
      await toCheckout(page);
      await expect(page.locator('#inputCustType')).toHaveValue('new');
      await expect(page.locator('#containerNewUserSecurity')).toBeVisible();
      await page.locator('.co-auth-tab[data-atab=signin]').click();
      await expect(page.locator('#inputCustType')).toHaveValue('existing');
      await expect(page.locator('#containerExistingUserSignin')).toBeVisible();
      await expect(page.locator('#containerNewUserSignup')).toBeHidden();
      await expect(page.locator('#containerNewUserSecurity'), 'no password fields for an existing customer').toBeHidden();
      await expect(page.locator('.marketing-email-optin')).toBeHidden();
      await expect(page.locator('#containerExistingUserSignin a.co-forgot-link')).toHaveAttribute('href', /pwreset\.php$/);

      await page.locator('#inputLoginEmail').fill(buyer.email);
      await page.locator('#inputLoginPassword').fill('definitely-not-it');
      await page.locator('#btnExistingLogin').click();
      await expect(page.locator('#existingLoginMessage')).toBeVisible({ timeout: 20_000 });
      await expect(page.locator('#existingLoginMessage')).not.toBeEmpty();
      expect(await auth(page)).toBe('out');

      // Back and forth: Create restores the new-customer extras.
      await page.locator('.co-auth-tab[data-atab=create]').click();
      await expect(page.locator('#inputCustType')).toHaveValue('new');
      await expect(page.locator('#containerNewUserSecurity')).toBeVisible();
      await page.locator('.co-auth-tab[data-atab=signin]').click();

      await page.locator('#inputLoginPassword').fill(buyer.password);
      await page.locator('#btnExistingLogin').click();
      await expect(page.locator('#containerExistingAccountSelect'), 'reloaded signed in').toBeVisible({ timeout: 30_000 });
      expect(await auth(page)).toBe('in');
      await expect(page.locator(`#account${buyer.clientId}`)).toBeChecked();
      await expect(page.locator('.co-summary-list')).toContainText('DV SSL');
      // OF-68: "Create a new account" reveals the sign-up fields; picking the account again hides them.
      const picker = page.locator('#containerExistingAccountSelect');
      const accountSelect = () => page.waitForResponse(r => /cart\/account\/select/.test(r.url()), { timeout: 30_000 });
      await Promise.all([accountSelect(), picker.locator('label:has(input.account-select[value=new])').click()]);
      await expect(page.locator('#containerNewUserSignup')).toBeVisible();
      await expect(page.locator('#inputCustType')).toHaveValue('add');
      await Promise.all([accountSelect(), picker.locator(`label[for=account${buyer.clientId}]`).click()]);
      await expect(page.locator('#containerNewUserSignup')).toBeHidden();
      await expect(page.locator('#inputCustType')).toHaveValue('account');
      await expect(page.locator('#btnCompleteOrder')).not.toHaveClass(/disabled/, { timeout: 20_000 });
      await expect(page.locator('input[name=paymentmethod][value=banktransfer]')).toBeChecked();
      await completeOrder(page, /viewinvoice\.php\?id=\d+/);
      expect(orderPhp('invoice', String(invoiceIdOf(page))).userid).toBe(buyer.clientId);
      expect(errors).toEqual([]);
    } finally {
      dropClients(buyer.clientId);
    }
  });

  test('OF-66 the password generator: length checked, generated password inserted into both fields', async ({ page }) => {
    const errors = watchErrors(page);
    await addStraightToCart(page, 21);
    await toCheckout(page);
    await page.locator('.generate-password').click();
    const modal = page.locator('#modalGeneratePassword');
    await expect(modal).toBeVisible();
    await expect(page.locator('#inputGeneratePasswordOutput')).toHaveValue(/^.{12}$/);
    // Under 8: the field's min=8 stops the submit in the browser; nothing is generated.
    const before = await page.locator('#inputGeneratePasswordOutput').inputValue();
    await page.locator('#inputGeneratePasswordLength').fill('7');
    await modal.locator('button[type=submit]').click();
    expect(await page.locator('#inputGeneratePasswordLength').evaluate(e => e.validity.rangeUnderflow)).toBe(true);
    await expect(page.locator('#inputGeneratePasswordOutput')).toHaveValue(before);
    await page.locator('#inputGeneratePasswordLength').fill('20');
    await modal.locator('button[type=submit]').click();
    await expect(page.locator('#generatePwLengthError')).toBeHidden();
    const pw = await page.locator('#inputGeneratePasswordOutput').inputValue();
    expect(pw).toHaveLength(20);
    await page.locator('#btnGeneratePasswordInsert').click();
    await expect(modal).toBeHidden();
    await expect(page.locator('#inputNewPassword1')).toHaveValue(pw);
    await expect(page.locator('#inputNewPassword2')).toHaveValue(pw);
    await expect(page.locator('#passwordStrengthTextLabel')).toContainText(/strong/i);
    expect(errors).toEqual([]);
  });

  test('OF-68 OF-72 OF-77 signed in: account picker with a closed account, full credit pays the order', async ({ page }) => {
    test.setTimeout(3 * 60_000);
    const errors = watchErrors(page);
    const buyer = newBuyer({ credit: 50, closedAccount: true });
    try {
      await signIn(page, buyer);
      await addStraightToCart(page, 21);
      await toCheckout(page);
      const picker = page.locator('#containerExistingAccountSelect');
      await expect(picker).toBeVisible();
      await expect(page.locator(`#account${buyer.clientId}`)).toBeChecked();
      await expect(page.locator(`#account${buyer.closedClientId}`), 'a closed account cannot be picked').toBeDisabled();
      await expect(picker.locator('.account', { has: page.locator(`#account${buyer.closedClientId}`) })).toContainText('Closed');
      await expect(page.locator('#containerNewUserSignup')).toBeHidden();
      await expect(picker.locator('input.account-select[value=new]')).toBeEnabled();

      // Credit covers the order: "no further payment", no gateway to pick.
      const credit = page.locator('#applyCreditContainer');
      await expect(credit).toBeVisible();
      await expect(credit).toContainText('$50.00');
      await expect(page.locator('#useCreditOnCheckout')).toBeChecked();
      await expect(page.locator('#spanFullCredit')).toBeVisible();
      await expect(page.locator('#spanFullCredit')).toContainText('$15.00');
      await expect(page.locator('#spanUseCredit')).toBeHidden();
      await expect(page.locator('#paymentGatewaysContainer')).toBeHidden();
      await completeOrder(page, /a=complete/);
      expect(await tpl(page)).toBe('complete');
      await expect(page.locator('.order-confirmation span')).toHaveText(/^\d+$/);
      await expect(page.locator('.alert-warning', { hasText: /unpaid|not.*paid/i }), 'paid: no unpaid notice').toHaveCount(0);
      await expect(page.locator('.order-complete-cta a')).toHaveAttribute('href', /clientarea\.php$/);
      const ord = orderPhp('orders', String(buyer.clientId))[0];
      const inv = orderPhp('invoice', String(ord.invoiceid));
      expect(inv.status).toBe('Paid');
      expect(inv.total).toBeCloseTo(15, 2);
      expect(orderPhp('client', String(buyer.clientId)).credit).toBeCloseTo(35, 2);
      expect(errors).toEqual([]);
    } finally {
      dropClients(buyer.clientId, buyer.closedClientId);
    }
  });

  test('OF-16 OF-17 OF-18 OF-20 OF-52 OF-70 OF-72 OF-74 signed in: options, field and add-on reach the invoice; partial credit, the rest by bank transfer', async ({ page }) => {
    test.setTimeout(4 * 60_000);
    const errors = watchErrors(page);
    const buyer = newBuyer({ credit: 10 });
    const name = `hadrian-full-${stamp()}`;
    try {
      await signIn(page, buyer);
      // Register, not own domain: see the OF-30 sign-out bug.
      await registerWithProduct(page, 15, name);
      expect(await auth(page)).toBe('in');
      await expect(dueToday(page)).toHaveText('$12.49');
      await page.locator('#inputConfigOption1').selectOption('3');
      await expect(dueToday(page)).toHaveText('$14.49');
      await page.locator('label.cp-toggle').click();
      await expect(dueToday(page)).toHaveText('$17.49');
      await page.locator('label.st-addon').click();
      await expect(dueToday(page)).toHaveText('$26.49');
      await page.locator('input[name="customfield[1]"]').fill('Hadrian Test Project');
      await reviewCart(page);

      // Cart: product card with its options and add-on, the domain, the totals.
      const card = page.locator('[data-cart-item="product-0"]');
      await expect(card.locator('.ct-addon-row', { hasText: 'Data centre' })).toContainText('New York');
      await expect(card.locator('.ct-addon-row', { hasText: 'Daily backups' })).toContainText('Yes');
      await expect(card.locator('.ct-addon-row', { hasText: 'Priority support (hadrian-test)' })).toContainText('$9.00');
      await expect(page.locator('[data-cart-item="domain-0"] .ct-product-price .amount')).toHaveText(/\$12\.99/);
      await expect(page.locator('#totalDueToday'), '26.49 + 12.99').toHaveText(/\$39\.48/);
      await expect(page.locator('.ct-tab[data-tab=tax]'), 'no tax estimate when signed in').toHaveCount(0);

      await page.locator('#checkout').click();
      await page.waitForURL(/a=checkout/);
      // Checkout summary.
      const aside = page.locator('.co-summary-card');
      await expect(aside.locator('.co-summary-line', { hasText: 'Business' })).toBeVisible();
      await expect(aside.locator('.co-summary-line', { hasText: `${name}.com` })).toContainText('$12.99');
      await expect(aside.locator('#subtotal')).toHaveText(/\$39\.48/);
      await expect(aside.locator('#totalDueToday')).toHaveText(/\$39\.48/);
      await expect(page.locator('#btnCompleteOrder')).toHaveAttribute('form', 'frmCheckout');
      expect(await page.locator('#frmCheckout #btnCompleteOrder').count(), 'the button sits outside the form').toBe(0);
      // Registrant contact: "add new" reveals the contact fields.
      const contact = page.locator('#inputDomainContact');
      await expect(contact).toBeVisible();
      await contact.selectOption('addingnew');
      await expect(page.locator('#domainRegistrantInputFields')).toBeVisible();
      await contact.selectOption('');
      await expect(page.locator('#domainRegistrantInputFields')).toBeHidden();

      // Partial credit: apply 10.00, the rest by bank transfer.
      await expect(page.locator('#spanUseCredit')).toBeVisible();
      await expect(page.locator('#spanUseCredit')).toContainText('$10.00');
      await expect(page.locator('#spanFullCredit')).toBeHidden();
      await page.locator('label:has(#useCreditOnCheckout)').click();
      await expect(page.locator('#useCreditOnCheckout')).toBeChecked();
      await expect(page.locator('#paymentGatewaysContainer'), 'a gateway is still needed').toBeVisible();
      await page.locator('label:has(input[name=paymentmethod][value=banktransfer])').click();
      const notes = `order.spec partial ${stamp()}`;
      await page.locator('textarea[name=notes]').fill(notes);
      await completeOrder(page, /viewinvoice\.php\?id=\d+/);
      const invoiceId = invoiceIdOf(page);
      await expect(page.locator('.content-area')).toContainText('$10.00');

      const inv = orderPhp('invoice', String(invoiceId));
      expect(inv.userid).toBe(buyer.clientId);
      expect(inv.total).toBeCloseTo(39.48, 2);
      expect(inv.paid, 'credit applied').toBeCloseTo(10, 2);
      expect(inv.balance).toBeCloseTo(29.48, 2);
      const hosting = inv.items.find(i => i.type === 'Hosting');
      expect(hosting.amount, '12.49 + 2.00 + 3.00').toBeCloseTo(17.49, 2);
      expect(hosting.description).toContain('New York');
      expect(hosting.description).toMatch(/Daily backups: Yes/);
      expect(hosting.description).toContain('Project name: Hadrian Test Project');
      expect(inv.items.find(i => /Priority support/.test(i.description))?.amount).toBeCloseTo(9, 2);
      expect(inv.items.find(i => i.type === 'DomainRegister')?.amount).toBeCloseTo(12.99, 2);
      const ord = orderPhp('orders', String(buyer.clientId))[0];
      expect(ord.notes).toBe(notes);
      expect(orderPhp('client', String(buyer.clientId)).credit).toBeCloseTo(0, 2);
      // (The complete page's unpaid-invoice notice is not reachable here:
      // AutoRedirectoInvoice=gateway sends an unpaid order straight to its invoice.)
      expect(errors).toEqual([]);
    } finally {
      dropClients(buyer.clientId);
    }
  });

  test('OF-73 a new card on the Offline Credit Card gateway', async ({ page }) => {
    test.setTimeout(3 * 60_000);
    const errors = watchErrors(page);
    const buyer = newBuyer();
    try {
      await signIn(page, buyer);
      await addStraightToCart(page, 21);
      await toCheckout(page);
      await expect(page.locator('#creditCardInputFields')).toBeHidden();
      await page.locator('label:has(input[name=paymentmethod][value=offlinecc])').click();
      await expect(page.locator('#creditCardInputFields')).toBeVisible();
      await expect(page.locator('#new'), 'no saved cards: a new one').toBeChecked();
      await expect(page.locator('#newCardInfo')).toBeVisible();
      await page.locator('#inputCardNumber').pressSequentially('4111111111111111', { delay: 40 });
      await expect(page.locator('#inputCardNumber')).toHaveValue('4111 1111 1111 1111');
      await expect(page.locator('#inputCardNumber')).toHaveClass(/visa/);
      await page.locator('#inputCardExpiry').pressSequentially('1230', { delay: 40 });
      await expect(page.locator('#inputCardExpiry')).toHaveValue('12 / 30');
      await page.locator('#inputCardCVV').fill('123');
      await completeOrder(page, /viewinvoice\.php\?id=\d+/);
      const inv = orderPhp('invoice', String(invoiceIdOf(page)));
      expect(inv.paymentmethod).toBe('offlinecc');
      expect(inv.status).toBe('Unpaid');
      expect(inv.total).toBeCloseTo(15, 2);
      expect(errors).toEqual([]);
    } finally {
      dropClients(buyer.clientId);
    }
  });

  test('OF-73 a saved card: brand shown, expired card disabled, CVV asked, order placed', async ({ page }) => {
    test.setTimeout(3 * 60_000);
    const errors = watchErrors(page);
    const buyer = newBuyer({ card: true, expiredCard: true });
    try {
      await signIn(page, buyer);
      await addStraightToCart(page, 21);
      await toCheckout(page);
      await page.locator('label:has(input[name=paymentmethod][value=offlinecc])').click();
      const cards = page.locator('#existingCardsContainer');
      await expect(cards).toBeVisible();
      const live = cards.locator(`.paymethod-info[data-paymethod-id="${buyer.payMethodId}"]`);
      await expect(live.locator('.pm-card-visual')).toHaveClass(/visa/);
      await expect(live.locator('.pm-card-name')).toHaveText('Visa-1111');
      await expect(page.locator(`#ccinfo-${buyer.payMethodId}`)).toBeChecked();
      await expect(page.locator(`#ccinfo-${buyer.expiredPayMethodId}`)).toBeDisabled();
      await expect(cards.locator(`.paymethod-info[data-paymethod-id="${buyer.expiredPayMethodId}"] .pm-expired-pill`)).toHaveText('Expired');
      await expect(page.locator('#newCardInfo')).toBeHidden();
      await expect(page.locator('#inputCardCVV2')).toBeVisible();
      await page.locator('#inputCardCVV2').fill('123');
      await completeOrder(page, /viewinvoice\.php\?id=\d+/);
      const inv = orderPhp('invoice', String(invoiceIdOf(page)));
      expect(inv.paymentmethod).toBe('offlinecc');
      expect(inv.userid).toBe(buyer.clientId);
      expect(errors).toEqual([]);
    } finally {
      dropClients(buyer.clientId);
    }
  });

  test('OF-74 a mistyped card number is flagged on the field and Complete Order stays usable', async ({ page }) => {
    test.fail(true, 'BUG: scripts.min.js validateCheckoutCreditCardInput calls jQuery.fn.setInputError/showInputError, which neither the theme nor checkout.tpl defines (its stubs at checkout.tpl:137-174 cover WHMCS.payment only): the check throws, no field error shows and the form posts anyway');
    const errors = watchErrors(page);
    const buyer = newBuyer();
    try {
      await signIn(page, buyer);
      await addStraightToCart(page, 21);
      await toCheckout(page);
      await page.locator('label:has(input[name=paymentmethod][value=offlinecc])').click();
      await page.locator('#inputCardNumber').pressSequentially('4111111111111112', { delay: 40 });
      await page.locator('#inputCardExpiry').pressSequentially('1230', { delay: 40 });
      await page.locator('#inputCardCVV').fill('123');
      await page.locator('#btnCompleteOrder').click();
      await expect(page.locator('#cardNumberContainer .field-error-msg')).toBeVisible({ timeout: 5000 });
      await expect(page.locator('#btnCompleteOrder')).toBeEnabled();
      expect(page.url()).toMatch(/a=checkout/);
      expect(errors).toEqual([]);
    } finally {
      dropClients(buyer.clientId);
    }
  });
});

// ==================================================================== OF-J
test.describe('OF-J Renewals and addons', () => {
  test('OF-82 OF-84 a domain renewal: period priced, added by AJAX to the summary and the cart, removed again', async ({ page }) => {
    test.setTimeout(2 * 60_000);
    const errors = watchErrors(page);
    // The full persona's domain is past the 180-day advance-renewal limit; a
    // throwaway buyer gets a .com that expires in 20 days.
    const domain = `hadrian-renew-${stamp()}.com`;
    const buyer = newBuyer({ domain });
    try {
      await signIn(page, buyer);
      await page.goto('/cart.php?gid=renewals');
      expect(await tpl(page)).toBe('domain-renewals');
      const row = page.locator(`.domain-renewal[data-domain="${domain}"]`);
      await expect(row).toBeVisible();
      await expect(row.locator('.domain-renewal-expiry-date')).not.toBeEmpty();
      await expect(row.locator('.renewal-pill'), 'expiring within 30 days').toHaveClass(/renewal-pill--warn/);
      await expect(row.locator('.renewal-pill')).toContainText(/\d+/);
      const select = row.locator('select.select-renewal-pricing');
      await expect(select.locator('option'), '.com renews at 13.99 a year').toHaveText([/1 .*\$13\.99/, /2 .*\$27\.98/, /3 .*\$41\.97/]);
      await expect(page.locator('#producttotal')).toContainText('$0.00');

      // Two years, added by AJAX: the summary follows.
      await select.selectOption({ index: 1 });
      const add = row.locator('.btn-add-renewal-to-cart');
      await Promise.all([
        page.waitForResponse(r => /cart\/domain\/renew\/add/.test(r.url()), { timeout: 30_000 }),
        add.click(),
      ]);
      await expect(add.locator('.added')).toBeVisible();
      await expect(page.locator('#producttotal')).toContainText(domain);
      await expect(page.locator('#producttotal .total-due-today .amt')).toHaveText(/\$27\.98/);

      await page.locator('#btnGoToCart').click();
      await page.waitForURL(/a=view/);
      const card = page.locator('[data-cart-item^="domrenew-"]');
      await expect(card.locator('.ct-product-eyebrow')).toHaveText('Domain Renewal');
      await expect(card.locator('.ct-product-title')).toHaveText(domain);
      await expect(card.locator('.ct-cycle-value')).toHaveText(/^2 /);
      await expect(card.locator('.ct-product-price .amount')).toHaveText(/\$27\.98/);
      await expect(page.locator('#totalDueToday')).toHaveText(/\$27\.98/);
      await card.locator('.ct-product-remove').click();
      await expect(page.locator('#modalRemoveItem')).toBeVisible();
      await expect(page.locator('#inputRemoveItemRenewalType')).toHaveValue('domain');
      await page.locator('#modalRemoveItem button[type=submit]').click();
      await page.waitForLoadState('load');
      await expect(page.locator('[data-cart-item^="domrenew-"]')).toHaveCount(0);
      await expect(page.locator('body')).toHaveAttribute('data-data', 'empty');
      expect(errors).toEqual([]);
    } finally {
      dropClients(buyer.clientId);
    }
  });

  test('OF-84 the checkout summary lists a renewal it charges for', async ({ page }) => {
    test.fail(true, 'BUG: includes/checkout/summary-aside.tpl:26-43 loops products, domains and addons only; a renewal is in the subtotal but has no line');
    const domain = `hadrian-renew-${stamp()}.com`;
    const buyer = newBuyer({ domain });
    try {
      await signIn(page, buyer);
      await page.goto('/cart.php?gid=renewals');
      await Promise.all([
        page.waitForResponse(r => /cart\/domain\/renew\/add/.test(r.url()), { timeout: 30_000 }),
        page.locator(`.domain-renewal[data-domain="${domain}"] .btn-add-renewal-to-cart`).click(),
      ]);
      await toCheckout(page);
      await expect(page.locator('.co-summary-card #subtotal')).toHaveText(/\$13\.99/);
      await expect(page.locator('.co-summary-list .co-summary-line', { hasText: domain })).toBeVisible({ timeout: 3000 });
    } finally {
      dropClients(buyer.clientId);
    }
  });

  test('OF-83 service renewals: the non-renewable services sit behind the show/hide toggle with their reason', async ({ page, context }) => {
    // No service on this stack is renewable (WHMCS lists them all as not
    // eligible), so the add-to-cart path cannot be produced here.
    const errors = watchErrors(page);
    await loginClient(context.request, 'full');
    await page.goto('/index.php?rp=/service-renewals');
    expect(await tpl(page)).toBe('service-renewals');
    const hidden = page.locator('#serviceRenewals .service-renewal[data-is-renewable="false"]');
    expect(await hidden.count()).toBeGreaterThan(0);
    await expect(hidden.first()).toBeHidden();
    await expect(page.locator('#hideShowServiceRenewalButton .to-show')).toBeVisible();
    await page.locator('#hideShowServiceRenewalButton').click();
    await expect(hidden.first()).toBeVisible();
    await expect(hidden.first().locator('.div-renewal-ineligible').first()).not.toBeEmpty();
    await expect(hidden.first().locator('.renewal-pill').first()).toBeVisible();
    await expect(page.locator('#serviceRenewals .service-renewal[data-is-renewable="false"] .btn-add-renewal-to-cart')).toHaveCount(0);
    await expect(page.locator('#hideShowServiceRenewalButton .to-hide')).toBeVisible();
    await page.locator('#hideShowServiceRenewalButton').click();
    await expect(hidden.first()).toBeHidden();
    await expect(page.locator('#producttotal')).toContainText('$0.00');
    expect(errors).toEqual([]);
  });

  test('OF-85 the addons page adds an add-on for one of the customer\'s services', async ({ page, context }) => {
    const errors = watchErrors(page);
    await loginClient(context.request, 'full');
    await page.goto('/cart.php?gid=addons');
    expect(await tpl(page)).toBe('addons');
    const card = page.locator('.product', { hasText: 'Priority support (hadrian-test)' });
    await expect(card).toBeVisible();
    await expect(card.locator('.product-desc')).toContainText('Replies within one hour');
    await expect(card.locator('.price'), 'the lowest price: monthly').toContainText('$9.00 USD');
    const select = card.locator('select[name=productid]');
    // Only the customer's services on the add-on's products (13, 14, 15) are offered.
    const services = (await select.locator('option').allInnerTexts()).map(t => t.trim());
    expect(services.length).toBeGreaterThan(0);
    for (const s of services) expect(s).toMatch(/^(Single|Professional|Business)\b/);
    expect(services.join('|')).not.toMatch(/VPS|SSL/);
    await select.selectOption({ index: 0 });
    await card.locator('button[type=submit]').click();
    await page.waitForURL(/a=(view|confproduct)/);
    await page.goto('/cart.php?a=view');
    const line = page.locator('[data-cart-item^="addon-"]');
    await expect(line.locator('.ct-product-eyebrow')).toHaveText('Addon');
    await expect(line.locator('.ct-product-title')).toHaveText('Priority support (hadrian-test)');
    await expect(line.locator('.ct-product-domain')).toContainText(services[0].split(' - ')[0]);
    // Billed on the service's own cycle: these services are annual, so 99.00.
    await expect(line.locator('.ct-cycle-value')).toHaveText('Annually');
    await expect(line.locator('.ct-product-price .amount')).toHaveText(/\$99\.00/);
    await expect(page.locator('#totalDueToday')).toHaveText(/\$99\.00/);
    expect(errors).toEqual([]);
  });
});

// ==================================================================== OF-K
test.describe('OF-K Cross-cutting', () => {
  test('OF-86 OF-87 every cart page loads the cart assets with ?v= and forces card controls inside', async ({ page }) => {
    // Eight cart pages in a row: about 15 s alone, over the 60 s default beside
    // the other browser specs.
    test.setTimeout(3 * 60_000);
    const assets = new Map();
    page.on('response', r => {
      const u = r.url();
      if (/hadrian_cart\/css\/(style\.min|custom)\.css|standard_cart\/js\/scripts\.min\.js/.test(u)) assets.set(u.replace(BASE_URL, ''), r.status());
    });
    await addStraightToCart(page, 21);
    const pages = ['/index.php?rp=/store/shared-hosting', '/cart.php?a=add&pid=14', '/cart.php?a=view', '/cart.php?a=checkout',
      '/cart.php?a=add&domain=register', '/cart.php?a=add&domain=transfer'];
    for (const url of pages) {
      await page.goto(url);
      await expect(page.locator('body'), url).toHaveAttribute('data-svc-layout', 'inside');
    }
    await ownDomain(page, 14, 'hadrian-assets');
    await expect(page.locator('body')).toHaveAttribute('data-svc-layout', 'inside');
    const urls = [...assets.keys()];
    for (const want of ['/css/style.min.css?v=', '/css/custom.css?v=', '/standard_cart/js/scripts.min.js?v=']) {
      expect(urls.some(u => u.includes(want)), want).toBe(true);
    }
    for (const [u, status] of assets) expect(status, u).toBeLessThan(400);
  });

  test('OF-89 checkout, configure and domain pages in light and dark: theme applied, text readable', async ({ page, context }) => {
    test.setTimeout(5 * 60_000);
    // A cart with no domain in it (a domain would send later adds to the domain
    // step).
    await addStraightToCart(page, 21);
    await page.goto('/cart.php?a=add&pid=19');
    await page.waitForURL(/a=confproduct/);
    await page.locator('#inputHostname').fill('server1.hadrian-test.example');
    await page.locator('#inputRootpw').fill('Root!Pass-2026x');
    await page.locator('#inputNs1prefix').fill('ns1');
    await page.locator('#inputNs2prefix').fill('ns2');
    await reviewCart(page);
    await expect(page.locator('[data-cart-item^="product-"]')).toHaveCount(2);
    const targets = [
      ['/cart.php?a=confproduct&i=1', ['.cp-section-title', '.cp-cycle-title', '#producttotal .summary-row']],
      ['/cart.php?a=checkout', ['.co-section-title', '.co-summary-head h2', '.co-summary-line .label']],
      ['/cart.php?a=add&domain=register', ['.st-page-header h1', '.dr-section-head h2']],
      ['/cart.php?a=add&domain=transfer', ['.st-page-header h1', '.dt-section-head h2']],
      ['/cart.php?a=add&pid=13', ['.st-page-header h1', '.dp-option-title']],
    ];
    const bg = {};
    const problems = [];
    for (const theme of ['light', 'dark']) {
      await context.addCookies([{ name: 'mt_theme', value: theme, url: BASE_URL }]);
      for (const [url, sels] of targets) {
        await page.goto(url);
        if (/confproduct/.test(url)) await expect(page.locator('#producttotal .total-due-today')).toBeVisible({ timeout: 30_000 });
        const m = await page.evaluate(measure);
        if (m.theme !== theme) problems.push(`${theme} ${url}: html[data-theme]="${m.theme}"`);
        if (m.overflowX > 1) problems.push(`${theme} ${url}: horizontal overflow ${m.overflowX}px`);
        for (const c of m.contrast) if (c.ratio < 3) problems.push(`${theme} ${url}: unreadable ${c.sel} (${c.ratio}:1)`);
        for (const c of await page.evaluate(contrastIn, sels)) {
          if (c.missing) problems.push(`${theme} ${url}: ${c.sel} not found`);
          else if (c.ratio < 4.5) problems.push(`${theme} ${url}: ${c.sel} contrast ${c.ratio}:1`);
          else (bg[url] ??= {})[theme] = c.bg;
        }
      }
    }
    expect(problems).toEqual([]);
    // Dark is a real switch: the cards' background got darker on every page.
    for (const [url, b] of Object.entries(bg)) expect(b.dark, url).toBeLessThan(b.light);
  });

  test('OF-90 with the jQuery CDN blocked a guest can still choose a plan, configure it and check out', async ({ page }) => {
    test.setTimeout(3 * 60_000);
    await page.route(/code\.jquery\.com/, r => r.abort());
    await page.goto('/index.php?rp=/store/shared-hosting');
    expect(await page.evaluate(() => typeof window.jQuery)).toBe('undefined');
    // The plan grid and its cycle pills are plain JS.
    await expect(page.locator('.plan-variant.v-a .st-plan')).toHaveCount(3);
    await page.locator('[data-cycle-switcher] button[data-cycle=monthly]').click();
    await expect(page.locator('#product13 [data-price-display]')).toHaveText('3.74');
    await page.locator('#product13-order-button').click();
    await page.waitForLoadState('load');
    expect(await tpl(page)).toBe('configureproductdomain');
    await page.locator('label:has(input[name=domainoption][value=owndomain])').click();
    await expect(page.locator('.dp-panel.is-active')).toHaveAttribute('data-panel', 'owndomain');
    const panel = page.locator('.dp-panel[data-panel=owndomain]');
    await panel.locator('[data-input=sld]').fill('hadrian-nojquery');
    await panel.locator('[data-input=tld]').fill('com');
    await page.locator('button.dp-continue').click();
    await page.waitForURL(/a=confproduct/, { timeout: 30_000 });
    await reviewCart(page);
    await expect(page.locator('[data-cart-item="product-0"] .ct-product-title')).toHaveText('Single');
    await page.locator('#checkout').click();
    await page.waitForURL(/a=checkout/);
    const f = page.locator('#frmCheckout');
    await f.locator('[name=firstname]').fill('Nojq');
    await f.locator('[name=lastname]').fill('Spectest');
    await f.locator('[name=email]').fill(`flow+nojq${Date.now()}@demo.hadrian.test`);
    await f.locator('[name=phonenumber]').fill('2025550143');
    await f.locator('[name=address1]').fill('1 Test Street');
    await f.locator('[name=city]').fill('Austin');
    await f.locator('[name=state]:visible').first().fill('TX');
    await f.locator('[name=postcode]').fill('78701');
    await f.locator('[name=password]').fill('FlowTest!2026x');
    await f.locator('[name=password2]').fill('FlowTest!2026x');
    await completeOrder(page, /viewinvoice\.php\?id=\d+/);
    const inv = orderPhp('invoice', String(invoiceIdOf(page)));
    try {
      expect(await auth(page)).toBe('in');
      // Configure starts on the plan's first cycle (monthly); the store pill only changes the display.
      expect(inv.total).toBeCloseTo(3.74, 2);
      expect(inv.items[0].description).toContain('hadrian-nojquery.com');
    } finally {
      dropClients(inv.userid);
    }
  });

  test('OF-91 the cart canonical and hreflang drop currency and language', async ({ page }) => {
    test.fail(true, 'BUG: Hooks.php:3203-3207 (resolveSeoContext) parses $_SERVER[REQUEST_URI], which reaches it HTML-escaped (&amp;): parse_str yields keys such as "amp;currency", so currency and language are not stripped and the canonical of every URL with two or more parameters reads ?a=add&amp%3Bdomain=register (hreflang then carries language twice)');
    await page.goto('/cart.php?a=add&domain=register&currency=1&language=english');
    expect(await tpl(page)).toBe('domainregister');
    const canonical = await page.locator('link[rel=canonical]').getAttribute('href');
    expect(canonical).toBe(`${BASE_URL}/cart.php?a=add&domain=register`);
    await expect(page.locator('meta[property="og:url"]')).toHaveAttribute('content', canonical);
    for (const href of await page.locator('link[rel=alternate][hreflang]').evaluateAll(ls => ls.map(l => l.href))) {
      expect(href).not.toMatch(/currency=/);
      expect((href.match(/language=/g) || []).length, href).toBeLessThanOrEqual(1);
    }
  });

  test('OF-93 ?plan= does not change a live store page without ?preview=1', async ({ page }) => {
    test.fail(true, 'BUG: hadrian/templates/hadrian/header.tpl:206-211 reads ?plan= without the $mt_preview gate, so any visitor link with ?plan=b swaps the live plan grid for a preview design');
    await page.goto('/index.php?rp=/store/shared-hosting&plan=b');
    await expect(page.locator('body')).not.toHaveAttribute('data-plan', /./);
    await expect(page.locator('.plan-variant.v-a')).toBeVisible();
    await expect(page.locator('.plan-variant.v-b')).toBeHidden();
  });

  test('OF-93 ?data=empty does not hide the live transfer form without ?preview=1', async ({ page }) => {
    test.fail(true, 'BUG: hadrian/templates/hadrian/header.tpl:183-186 reads ?data= without the $mt_preview gate; on domaintransfer.tpl (:50, :270) body[data-data=empty] hides the transfer form');
    await page.goto('/cart.php?a=add&domain=transfer&data=empty');
    await expect(page.locator('#frmDomainTransfer')).toBeVisible();
  });

  test('OF-95 the order form refuses direct requests for template source', async ({ request }) => {
    const base = '/templates/orderforms/hadrian_cart';
    for (const f of ['products.tpl', 'includes/checkout/payment.tpl', 'README.md', 'theme.yaml']) {
      const r = await request.get(`${base}/${f}`);
      expect(r.status(), f).toBe(403);
      expect(await r.text(), f).not.toContain('{include');
    }
    for (const f of ['css/style.min.css', 'css/custom.css']) {
      expect((await request.get(`${base}/${f}`)).status(), f).toBe(200);
    }
  });
});
