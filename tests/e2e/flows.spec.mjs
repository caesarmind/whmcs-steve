// Tier 3b (flows) - use the site the way a customer does, in real Chromium.
//
// Each flow drives the UI (clicks the card, not the hidden radio; waits for
// the URL the theme navigates to) and fails on ANY JavaScript error along the
// way. Records they create are removed by tests/php/fixtures.php on the next
// run: customers flow+<n>@demo.hadrian.test, tickets titled "[flow] ...".

import { test, expect } from '@playwright/test';
import { fx, creds, loginClient } from './helpers.mjs';

const id = fx.ids;

// One at a time. Flows create orders and tickets, and two of them reach the
// checkout together otherwise - which, right after checkout.tpl changes, makes
// both requests compile it at once (see lib/warmup.mjs on Windows Smarty).
test.describe.configure({ mode: 'serial' });

/** Collect JS errors for the whole test; assert none at the end. */
function watchErrors(page) {
  const errors = [];
  page.on('pageerror', e => errors.push(`uncaught: ${e.message}`));
  page.on('console', m => { if (m.type() === 'error') errors.push(`console: ${m.text().slice(0, 200)}`); });
  return errors;
}
const tpl = page => page.evaluate(() => document.body.dataset.tpl);
const auth = page => page.evaluate(() => document.body.dataset.auth);

test('a new customer buys a product through the order form', async ({ page }) => {
  test.setTimeout(3 * 60_000);
  const errors = watchErrors(page);

  // Store -> product. Business has a setup fee, so the invoice total proves
  // pricing made it all the way through.
  await page.goto(`/index.php?rp=/store/${id.productGroupSlug}`);
  expect(await tpl(page)).toBe('products');
  await page.locator('a[id^=product]').first().click();
  expect(await tpl(page)).toBe('configureproductdomain');

  // Domain step: "use my own domain" - no registrar involved.
  await page.locator('label:has(input[name=domainoption][value=owndomain])').click();
  await expect(page.locator('input[name=domainoption][value=owndomain]')).toBeChecked();
  const dom = page.locator('#frmProductDomain input[type=text]:visible');
  await dom.nth(0).fill('hadrian-flow-test');
  await dom.nth(1).fill('com');
  await page.locator('button.dp-continue').click();
  await page.waitForURL(/a=confproduct/);
  expect(await tpl(page)).toBe('configureproduct');

  // Configure -> cart. The button posts by AJAX and the theme then navigates.
  await page.locator('#btnCompleteProductConfig').click();
  await page.waitForURL(/a=view/);
  expect(await tpl(page)).toBe('viewcart');
  await expect(page.locator('.topbar-cart-btn').first(), 'cart badge counts the item').toHaveText(/1/);

  // Checkout as a brand new customer.
  await page.locator('#checkout').click();
  await page.waitForURL(/a=checkout/);
  const f = page.locator('#frmCheckout');
  const email = `flow+${Date.now()}@demo.hadrian.test`;
  await f.locator('[name=firstname]').fill('Flo');
  await f.locator('[name=lastname]').fill('Testcase');
  await f.locator('[name=email]').fill(email);
  // The phone field is intl-tel-input (loaded from a CDN). Until it has
  // initialised it has not added the dial code WHMCS validates against, and
  // the order is refused with "Your phone number is not valid". A person never
  // types that fast; wait for the widget the way they implicitly do.
  await expect(f.locator('.iti').first(), 'phone widget initialised').toBeAttached({ timeout: 20_000 });
  await f.locator('[name=phonenumber]').fill('2025550143');   // national number; the dial code is a hidden field
  await f.locator('[name=address1]').fill('1 Test Street');
  await f.locator('[name=city]').fill('Austin');
  const state = f.locator('[name=state]');
  if (await state.evaluate(e => e.tagName) === 'SELECT') await state.selectOption({ index: 1 }); else await state.fill('TX');
  await f.locator('[name=postcode]').fill('78701');
  await f.locator('[name=password]').fill('FlowTest!2026x');
  await f.locator('[name=password2]').fill('FlowTest!2026x');
  await expect(f.locator('input[name=paymentmethod][value=banktransfer]')).toBeChecked();
  await page.locator('#btnCompleteOrder').click();

  // Bank transfer: WHMCS goes straight to the new invoice, signed in.
  await page.waitForURL(/viewinvoice\.php\?id=\d+/, { timeout: 45_000 });
  expect(await tpl(page)).toBe('viewinvoice');
  expect(await auth(page), 'the new customer is signed in after checkout').toBe('in');
  await expect(page.locator('.content-area')).toContainText('Unpaid');
  await expect(page.locator('.content-area')).toContainText('Flo Testcase');

  expect(errors).toEqual([]);
});

test('checkout still works when the phone widget\'s CDN is unreachable', async ({ page }) => {
  // intl-tel-input and its utils.js come from cdn.jsdelivr.net. An ad blocker,
  // a corporate proxy or a CDN outage takes them away; the order form must
  // degrade to a plain phone field, not refuse the order.
  test.setTimeout(3 * 60_000);
  await page.route(/cdn\.jsdelivr\.net/, r => r.abort());

  await page.goto(`/index.php?rp=/store/${id.productGroupSlug}`);
  await page.locator('a[id^=product]').first().click();
  await page.locator('label:has(input[name=domainoption][value=owndomain])').click();
  const dom = page.locator('#frmProductDomain input[type=text]:visible');
  await dom.nth(0).fill('hadrian-flow-nocdn');
  await dom.nth(1).fill('com');
  await page.locator('button.dp-continue').click();
  await page.waitForURL(/a=confproduct/);
  await page.locator('#btnCompleteProductConfig').click();
  await page.waitForURL(/a=view/);
  await page.locator('#checkout').click();
  await page.waitForURL(/a=checkout/);

  const f = page.locator('#frmCheckout');
  await expect(f.locator('.iti'), 'no widget without its CDN').toHaveCount(0);
  await f.locator('[name=firstname]').fill('Nocdn');
  await f.locator('[name=lastname]').fill('Testcase');
  await f.locator('[name=email]').fill(`flow+nocdn${Date.now()}@demo.hadrian.test`);
  await f.locator('[name=phonenumber]').fill('2025550143');
  await f.locator('[name=address1]').fill('1 Test Street');
  await f.locator('[name=city]').fill('Austin');
  const state = f.locator('[name=state]');
  if (await state.evaluate(e => e.tagName) === 'SELECT') await state.selectOption({ index: 1 }); else await state.fill('TX');
  await f.locator('[name=postcode]').fill('78701');
  await f.locator('[name=password]').fill('FlowTest!2026x');
  await f.locator('[name=password2]').fill('FlowTest!2026x');
  await page.locator('#btnCompleteOrder').click();
  await page.waitForURL(/viewinvoice\.php\?id=\d+/, { timeout: 45_000 });
  expect(await auth(page)).toBe('in');
});

test('signing in: a wrong password is refused, the right one lands in the client area', async ({ page }) => {
  const errors = watchErrors(page);
  const p = creds.personas.full;

  await page.goto('/login');
  expect(await tpl(page)).toBe('login');
  await page.locator('input[name=username]').fill(p.email);
  await page.locator('input[name=password]').fill('definitely-not-the-password');
  await page.locator('form:has(input[name=password]) [type=submit]').first().click();
  await page.waitForLoadState('load');
  expect(await auth(page), 'wrong password must not sign in').toBe('out');
  await expect(page.locator('.content-area, main').first(), 'an error is shown').toContainText(/incorrect|invalid|failed|wrong/i);

  await page.locator('input[name=username]').fill(p.email);
  await page.locator('input[name=password]').fill(p.password);
  await page.locator('form:has(input[name=password]) [type=submit]').first().click();
  await page.waitForURL(/clientarea\.php/);
  expect(await auth(page)).toBe('in');
  expect(await tpl(page)).toBe('clientareahome');

  expect(errors).toEqual([]);
});

test('a customer opens a ticket and closes it from the ticket page', async ({ page, context }) => {
  // Regression test for 8f7e5f2: the Close link carried no CSRF token, so
  // WHMCS signed the customer out and left the ticket open.
  const errors = watchErrors(page);
  await loginClient(context.request, 'full');

  await page.goto('/submitticket.php');
  expect(await tpl(page)).toBe('supportticketsubmit-stepone');
  await page.locator(`label:has(input[name=deptid][value="${id.deptId}"])`).click();
  await page.locator('form:has(input[name=deptid]) [type=submit]').first().click();
  await page.waitForURL(/step=2/);

  const subject = `[flow] ticket ${Date.now()}`;
  await page.locator('[name=subject]').fill(subject);
  await page.locator('[name=message]').fill('Opened by the Hadrian test suite. Safe to delete.');
  await page.locator('form:has([name=subject]) [type=submit]').first().click();
  // WHMCS answers with a "Ticket Created #ABC-123456" confirmation whose URL
  // carries no step marker, so wait for the page, not the URL.
  const view = page.locator('.content-area a[href*="viewticket.php"]').first();
  await expect(view, 'confirmation links to the new ticket').toBeVisible({ timeout: 30_000 });
  await expect(page.locator('.content-area')).toContainText(/Ticket Created/i);
  await view.click();
  await page.waitForURL(/viewticket/);
  expect(await tpl(page)).toBe('viewticket');
  await expect(page.locator('.content-area')).toContainText(subject.replace('[flow] ', ''));

  page.once('dialog', d => d.accept());   // "Close this ticket?"
  await page.locator('a.tk-close-btn').click();
  await page.waitForLoadState('load');
  expect(await auth(page), 'closing a ticket must not sign the customer out').toBe('in');
  expect(await tpl(page)).toBe('viewticket');
  await expect(page.locator('a.tk-close-btn'), 'Close is gone once the ticket is closed').toHaveCount(0);

  expect(errors).toEqual([]);
});

test('dark mode: the profile-menu switch flips the theme and it survives a reload', async ({ page, context }) => {
  const errors = watchErrors(page);
  await loginClient(context.request, 'full');
  await context.addCookies([{ name: 'mt_theme', value: 'light', url: page.context()._options?.baseURL || 'http://localhost:8088' }]);
  await page.goto('/clientarea.php');
  expect(await page.getAttribute('html', 'data-theme')).toBe('light');

  await page.locator('.sidebar-user:visible, .topbar-avatar:visible').first().click();
  const toggle = page.locator('.toggle-switch:visible').first();
  await expect(toggle).toBeVisible();
  await toggle.click();
  await expect(page.locator('html')).toHaveAttribute('data-theme', 'dark');

  await page.reload();
  await expect(page.locator('html'), 'the choice is remembered (server-rendered, no flash)').toHaveAttribute('data-theme', 'dark');

  expect(errors).toEqual([]);
});

test('the language & currency chooser opens, lists languages and closes', async ({ page }) => {
  const errors = watchErrors(page);
  await page.goto('/');
  const modal = page.locator('#localeModal');
  await page.locator('[data-locale-open]:visible').first().click();
  await expect(modal.locator('.locale-modal-panel')).toBeVisible();
  expect(await modal.locator('.locale-modal-body button, .locale-modal-body a').count(), 'languages are listed').toBeGreaterThan(1);
  await page.locator('#localeModalClose').click();
  await expect(modal.locator('.locale-modal-panel')).toBeHidden();
  expect(errors).toEqual([]);
});
