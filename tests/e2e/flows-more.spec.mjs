// Tier 3b (flows, continued) - the journeys flows.spec.mjs does not cover.
//
// Same rules: drive the UI (click what a customer clicks, wait for where the
// theme takes them), fail on ANY JavaScript error, and leave no trace the next
// run can trip over - records are either removed in the test (a card added is
// deleted again) or by tests/php/fixtures.php (flow+... customers, [flow]
// tickets), and personas whose state a flow changes are reset there
// (twofactor: 2FA off; resettable: known password).
//
// Emailed links (password reset) are read from Mailpit, which the preflight
// starts; tests/e2e/helpers.mjs mailTo().

import { test, expect } from '@playwright/test';
import { BASE_URL } from '../lib/env.mjs';
import { fx, creds, loginClient, mailTo, totp } from './helpers.mjs';
import { inspect } from './oracles.mjs';
import { execFileSync } from 'node:child_process';
import path from 'node:path';
import { PHP, TESTS_DIR } from '../lib/env.mjs';

const whmcsConfig = (...a) => execFileSync(PHP, [path.join(TESTS_DIR, 'php', 'whmcs-config.php'), ...a], { encoding: 'utf8' }).trim();

/** After the domain step: WHMCS skips "configure" when a product has nothing to
 *  configure (a free plan with no options), so either page may come next. */
async function configureThenCart(page) {
  await page.waitForURL(/a=(confproduct|view)/);
  if (/a=confproduct/.test(page.url())) {
    await page.locator('#btnCompleteProductConfig').click();
    await page.waitForURL(/a=view/);
  }
}

const id = fx.ids;
// One at a time (run.mjs and the config keep flows to a single worker's
// order), but not 'serial': one failing journey must not skip the others.
test.describe.configure({ mode: 'default' });

function watchErrors(page) {
  const errors = [];
  page.on('pageerror', e => errors.push(`uncaught: ${e.message}`));
  page.on('console', m => { if (m.type() === 'error') errors.push(`console: ${m.text().slice(0, 200)}`); });
  return errors;
}
const tpl = page => page.evaluate(() => document.body.dataset.tpl);
const auth = page => page.evaluate(() => document.body.dataset.auth);
const signIn = async (page, email, password) => {
  await page.goto('/login');
  await page.locator('input[name=username]:visible').fill(email);
  await page.locator('input[name=password]:visible').fill(password);
  await page.locator('form:has(input[name=password]) [type=submit]:visible').first().click();
  await page.waitForLoadState('load');
};

// ------------------------------------------------------------------ billing
test('a customer adds a card, edits it and removes it again', async ({ page, context }) => {
  // Offline Credit Card on the local stack; 4111... is the standard test number.
  test.setTimeout(2 * 60_000);
  const errors = watchErrors(page);
  await loginClient(context.request, 'full');

  await page.goto('/index.php?rp=/account/paymentmethods/add');
  expect(await tpl(page)).toBe('account-paymentmethods-manage');
  await expect(page.locator('#frmManagePaymentMethod')).toHaveAttribute('action', /paymentmethods\/add/);
  await expect(page.locator('input[name=type][value=localcard]')).toBeChecked();
  await expect(page.locator('input[name=billingcontact]:checked'), 'a billing address is chosen').toHaveCount(1);
  const label = `flow card ${Date.now()}`;
  await page.locator('#inputDescription').fill(label);
  await page.locator('#inputCardNumber').pressSequentially('4111111111111111');
  await expect(page.locator('#inputCardNumber'), 'number is grouped as it is typed').toHaveValue('4111 1111 1111 1111');
  await page.locator('#inputCardExpiry').pressSequentially('1230');
  await expect(page.locator('#inputCardExpiry')).toHaveValue('12 / 30');
  if (await page.locator('#inputCardCvc').count()) await page.locator('#inputCardCvc').fill('123');
  await page.locator('#btnSubmit').click();
  await page.waitForURL(/rp=\/account\/paymentmethods(?!\/add)/);
  expect(await tpl(page)).toBe('account-paymentmethods');
  const row = page.locator('.content-area').getByText(label);
  await expect(row, 'the new card is listed').toBeVisible();

  // Edit: the row's Edit link opens the same form in edit mode.
  const rowBox = page.locator('[class*="pm-row"]').filter({ hasText: label }).first();
  await rowBox.locator('a[href*="/account/paymentmethods/"]:not([data-pm-delete]):not([data-pm-setdefault])').first().click();
  await page.waitForLoadState('load');
  expect(await tpl(page)).toBe('account-paymentmethods-manage');
  // routePath('account-paymentmethods-save', id) is the method's own URL, POSTed.
  await expect(page.locator('#frmManagePaymentMethod')).toHaveAttribute('action', /paymentmethods\/\d+$/);
  await expect(page.locator('input[name=type][value=localcard]')).toBeDisabled();
  await expect(page.locator('#inputDescription')).toHaveValue(label);

  // Remove it from the list (POST with the CSRF token, after a confirm).
  await page.goto('/index.php?rp=/account/paymentmethods');
  page.once('dialog', d => d.accept());
  await page.locator('[class*="pm-row"]').filter({ hasText: label }).first().locator('[data-pm-delete]').click();
  await page.waitForLoadState('load');
  expect(await auth(page), 'deleting must not sign the customer out').toBe('in');
  await expect(page.locator('.content-area').getByText(label)).toHaveCount(0);
  expect(errors).toEqual([]);
});

test('the quote list sends "Accept" to the quote page, not a token-less GET', async ({ page, context }) => {
  // Regression: the menu item was a GET to viewquote.php?...&action=accept with no
  // CSRF token, which WHMCS answers by signing the customer out.
  await loginClient(context.request, 'full');
  await page.goto('/clientarea.php?action=quotes');
  const accept = page.locator(`a[href*="viewquote.php?id=${id.quoteId}"]`).filter({ hasText: /accept/i });
  await expect(accept).toHaveAttribute('href', /#accept$/);
  await page.goto(await accept.getAttribute('href'));
  expect(await auth(page)).toBe('in');
  await expect(page.locator('form#accept[method=post]')).toBeAttached();
  await expect(page.locator('form#accept input[name=token]'), 'WHMCS injects the token into POST forms').toHaveCount(1);
});

test('mass pay lists every unpaid invoice and totals them', async ({ page, context }) => {
  await loginClient(context.request, 'full');
  await page.goto('/clientarea.php?action=invoices');
  await page.goto('/clientarea.php?action=masspay&all=true');
  expect(await tpl(page)).toBe('masspay');
  const text = await page.locator('.content-area').innerText();
  expect(text).toMatch(new RegExp(`#\\s*${id.unpaidInvoiceId}\\b`));
  expect(text).toMatch(new RegExp(`#\\s*${id.overdueInvoiceId}\\b`));
  await expect(page.locator('input[name=paymentmethod]:checked')).toHaveCount(1);
});

// ------------------------------------------------------------------ services
test('upgrading a service: choose a plan, see the summary', async ({ page, context }) => {
  const errors = watchErrors(page);
  await loginClient(context.request, 'full');
  await page.goto(`/clientarea.php?action=productdetails&id=${id.serviceId}`);
  await page.locator(`a[href*="upgrade.php?type=package&id=${id.serviceId}"]`).first().click();
  await page.waitForURL(/upgrade\.php/);
  expect(await tpl(page)).toBe('upgrade');
  const plan = page.locator('form.up-st-plan:not(.current)').first();
  await expect(plan, 'another plan is offered').toBeVisible();
  await plan.locator('[type=submit]').click();
  await page.waitForLoadState('load');
  expect(await tpl(page)).toBe('upgradesummary');
  const html = await page.content();
  expect(inspect(html).problems).toEqual([]);
  expect(errors).toEqual([]);
});

test('changing a service\'s configurable options reaches the summary', async ({ page, context }) => {
  await loginClient(context.request, 'full');
  await page.goto(`/upgrade.php?type=configoptions&id=${id.serviceId}`);
  expect(await tpl(page)).toBe('upgrade');
  const select = page.locator('select[name^="configoption"]').first();
  await expect(select, 'the fixture\'s config options are offered').toBeVisible();
  await select.selectOption({ index: 2 });
  await page.locator('form:has(select[name^="configoption"]) [type=submit]').first().click();
  await page.waitForLoadState('load');
  expect(await tpl(page)).toBe('upgradesummary');
});

test('the /upgrade route renders the configure step', async ({ context }) => {
  // WHMCS's newer upgrade entry point (MarketConnect / service upgrades) is a
  // POST; the theme never links to it, but WHMCS does from its own emails.
  await loginClient(context.request, 'full');
  const page0 = await (await context.request.get('/clientarea.php')).text();
  const token = (page0.match(/name="token" value="([^"]+)"/) || [])[1];
  const r = await context.request.post('/index.php?rp=/upgrade', { form: { token, isproduct: '1', serviceid: String(id.serviceId) } });
  const got = inspect(await r.text(), { expectAuth: 'in' });
  expect(got.tpl).toBe('upgrade-configure');
  expect(got.problems).toEqual([]);
});

// ------------------------------------------------------------------ order form
test('registering a domain through the cart: search, add, configure, cart', async ({ page, context }) => {
  test.setTimeout(2 * 60_000);
  const errors = watchErrors(page);
  await loginClient(context.request, 'full');   // signed in: no captcha on the checker
  await page.goto('/cart.php?a=add&domain=register');
  expect(await tpl(page)).toBe('domainregister');
  const name = `hadrian-flow-${Date.now().toString(36)}`;
  // The Classic tab: an exact name, checked through the stub registrar.
  await page.locator('[role=tab][data-mode=classic]').click();
  await page.locator('input[name=domain]:visible').first().fill(name + '.com');
  await page.locator('#dr-alt-btnClassic:visible, #btnCheckAvailability:visible').first().click();
  const add = page.locator('.btn-add-to-cart:visible').first();
  await expect(add, 'the stub registrar says it is available').toBeVisible({ timeout: 30_000 });
  // The add is an AJAX POST to cart.php: wait for its answer, or (under load)
  // the next page can be asked for before the domain is in the session.
  await Promise.all([
    page.waitForResponse(r => /cart\.php/.test(r.url()) && r.request().method() === 'POST', { timeout: 30_000 }),
    add.click(),
  ]);
  await page.goto('/cart.php?a=confdomains');
  expect(await tpl(page)).toBe('configuredomains');
  await expect(page.locator('.content-area')).toContainText(name + '.com');
  await page.locator('.content-area form [type=submit].btn-primary, .content-area button.btn-primary[type=submit]').first().click();
  await page.waitForURL(/a=view/);
  expect(await tpl(page)).toBe('viewcart');
  await expect(page.locator('.content-area')).toContainText(name + '.com');
  // Leave an empty cart behind.
  await page.goto('/cart.php?a=empty');
  expect(errors).toEqual([]);
});

test('promo code: applied, shown as a discount, removed again', async ({ page }) => {
  test.setTimeout(2 * 60_000);
  await page.goto(`/cart.php?a=add&pid=${id.productId}`);
  await page.waitForLoadState('load');
  if (await tpl(page) === 'configureproductdomain') {
    await page.locator('label:has(input[name=domainoption][value=owndomain])').click();
    const dom = page.locator('#frmProductDomain input[type=text]:visible');
    await dom.nth(0).fill('hadrian-promo-test');
    await dom.nth(1).fill('com');
    await page.locator('button.dp-continue').click();
  }
  await configureThenCart(page);
  const totalBefore = await page.locator('#totalCartPrice, [class*="total"]').first().innerText();
  await page.locator('#inputPromotionCode').fill('HADRIAN10');
  await page.locator('form:has(#inputPromotionCode) [type=submit], [name=validatepromo]').first().click();
  await page.waitForLoadState('load');
  await expect(page.locator('.content-area'), 'promo applied').toContainText(/HADRIAN10/i);
  const totalAfter = await page.locator('#totalCartPrice, [class*="total"]').first().innerText();
  expect(totalAfter, 'the total changes').not.toBe(totalBefore);
  await page.locator('a[href*="removepromo"]').first().click();
  await page.waitForLoadState('load');
  await expect(page.locator('.content-area')).not.toContainText(/HADRIAN10/i);
  // Remove the product: back to an empty cart.
  page.once('dialog', d => d.accept());
  await page.locator('.ct-product-remove, a[href*="a=remove"]').first().click();
  await page.waitForLoadState('load');
  await page.goto('/cart.php?a=view');
  expect(await tpl(page)).toBe('viewcart');
});

test('a free product checks out to the order-complete page', async ({ page }) => {
  test.setTimeout(3 * 60_000);
  const errors = watchErrors(page);
  await page.goto('/index.php?rp=/store/openpanel-hosting');
  await page.locator('a[id^=product]').first().click();
  await page.waitForLoadState('load');
  if (await tpl(page) === 'configureproductdomain') {
    await page.locator('label:has(input[name=domainoption][value=owndomain])').click();
    const dom = page.locator('#frmProductDomain input[type=text]:visible');
    await dom.nth(0).fill('hadrian-free-flow');
    await dom.nth(1).fill('com');
    await page.locator('button.dp-continue').click();
  }
  await configureThenCart(page);
  await page.locator('#checkout').click();
  await page.waitForURL(/a=checkout/);
  // WHMCS renders the checkout through viewcart.tpl's $checkout branch, which
  // includes checkout.tpl - so data-tpl stays "viewcart". The form is the proof.
  await expect(page.locator('#frmCheckout'), 'the checkout form').toBeAttached();
  const f = page.locator('#frmCheckout');
  await f.locator('[name=firstname]').fill('Free');
  await f.locator('[name=lastname]').fill('Flowtest');
  await f.locator('[name=email]').fill(`flow+free${Date.now()}@demo.hadrian.test`);
  await expect(f.locator('.iti').first()).toBeAttached({ timeout: 20_000 });
  await f.locator('[name=phonenumber]').fill('2025550143');
  await f.locator('[name=address1]').fill('1 Test Street');
  await f.locator('[name=city]').fill('Austin');
  const state = f.locator('[name=state]');
  if (await state.evaluate(e => e.tagName) === 'SELECT') await state.selectOption({ index: 1 }); else await state.fill('TX');
  await f.locator('[name=postcode]').fill('78701');
  await f.locator('[name=password]').fill('FlowTest!2026x');
  await f.locator('[name=password2]').fill('FlowTest!2026x');
  await page.locator('#btnCompleteOrder').click();
  await page.waitForURL(/a=complete|viewinvoice/, { timeout: 45_000 });
  expect(await tpl(page), 'a free order needs no payment: straight to "complete"').toBe('complete');
  expect(inspect(await page.content(), { expectAuth: 'in' }).problems).toEqual([]);
  expect(errors).toEqual([]);
});

// ------------------------------------------------------------------ account
test('signing up through register.php lands signed in on the dashboard', async ({ page }) => {
  test.setTimeout(2 * 60_000);
  const errors = watchErrors(page);
  // WHMCS puts a CAPTCHA on sign-up for visitors (CaptchaSetting offloggedin).
  // A test must not solve one: switch the registration CAPTCHA off for this
  // run only. The smoke tier still renders register.php WITH it.
  const captchaForms = JSON.parse(whmcsConfig('get', 'CaptchaForms'));
  whmcsConfig('set', 'CaptchaForms', JSON.stringify({ checkoutCompletion: true, domainChecker: true, registration: false, contactUs: true, submitTicket: true, login: false }));
  test.info().annotations.push({ type: 'note', description: 'registration CAPTCHA off for this test only' });
  try {
  await page.goto('/register.php');
  expect(await tpl(page)).toBe('clientregister');
  const f = page.locator('form:has([name=password2])').first();
  await f.locator('[name=firstname]').fill('Reg');
  await f.locator('[name=lastname]').fill('Flowtest');
  await f.locator('[name=email]').fill(`flow+reg${Date.now()}@demo.hadrian.test`);
  if (await f.locator('.iti').count()) await expect(f.locator('.iti').first()).toBeAttached();
  await f.locator('[name=phonenumber]').fill('2025550143');
  await f.locator('[name=address1]').fill('1 Test Street');
  await f.locator('[name=city]').fill('Austin');
  const state = f.locator('[name=state]');
  if (await state.evaluate(e => e.tagName) === 'SELECT') await state.selectOption({ index: 1 }); else await state.fill('TX');
  await f.locator('[name=postcode]').fill('78701');
  await f.locator('[name=password]').fill('FlowTest!2026x');
  await f.locator('[name=password2]').fill('FlowTest!2026x');
  const tos = f.locator('[name=accepttos]');
  if (await tos.count()) await tos.check();
  await f.locator('[type=submit]').last().click();
  await page.waitForURL(/clientarea\.php/, { timeout: 45_000 });
  expect(await auth(page)).toBe('in');
  expect(await tpl(page)).toBe('clientareahome');
  expect(errors).toEqual([]);
  } finally {
    if (captchaForms === null) whmcsConfig('unset', 'CaptchaForms'); else whmcsConfig('set', 'CaptchaForms', captchaForms);
  }
});

test('password reset by email: request, follow the link, set a new password, sign in', async ({ page }) => {
  test.setTimeout(2 * 60_000);
  const p = creds.personas.resettable;
  const errors = watchErrors(page);
  await page.goto('/index.php?rp=/password/reset');
  expect(await tpl(page)).toBe('password-reset-container');
  const since = Date.now();
  await page.locator('input[name=email]:visible').fill(p.email);
  await page.locator('form:has(input[name=email]) [type=submit]:visible').first().click();
  await page.waitForLoadState('load');
  const mail = await mailTo(p.email, since);
  const link = mail.links.find(l => /password\/reset\/redeem/.test(l));
  expect(link, `reset link in "${mail.subject}"`).toBeTruthy();
  await page.goto(link.replace(/^https?:\/\/[^/]+/, BASE_URL));
  await page.waitForLoadState('load');
  expect(await tpl(page)).toBe('password-reset-container');
  const fresh = 'FlowReset!' + Date.now().toString(36);
  await page.locator('input[name=newpassword]:visible, input[type=password]:visible').first().fill(fresh);
  await page.locator('input[name=confirmnewpassword]:visible, input[type=password]:visible').nth(1).fill(fresh);
  await page.locator('form:has(input[type=password]) [type=submit]:visible').first().click();
  await page.waitForLoadState('load');
  // WHMCS signs the customer straight in after a reset.
  expect(await auth(page), 'signed in after the reset').toBe('in');
  await page.context().clearCookies();
  await signIn(page, p.email, fresh);
  expect(await auth(page), 'the new password works').toBe('in');
  expect(errors).toEqual([]);
});

test('two-factor: turn TOTP on, sign in with a code, then with a backup code', async ({ page, context }) => {
  // Regression: the method picker had no button to continue (WHMCS's steps carry
  // none; its own modal draws one in a footer), so nobody could turn 2FA on -
  // and the backup code was taken away by a reload 1.8 s after it appeared.
  test.setTimeout(3 * 60_000);
  const p = creds.personas.twofactor;
  const errors = watchErrors(page);
  await signIn(page, p.email, p.password);
  await page.goto('/index.php?rp=/user/security');
  expect(await tpl(page)).toBe('user-security');

  await page.locator('[data-tfa-open][data-tfa-url*="enable"]').click();
  const modal = page.locator('.tfa-modal.open');
  const next = modal.locator('[data-tfa-submit]');
  await modal.locator('.twofa-module').filter({ hasText: /time based/i }).first().click();
  await expect(next, 'the picker can be continued from').toBeVisible();
  await next.click();
  await expect(modal.locator('.tfa-modal-body')).toContainText(/[A-Z2-7]{16,}/, { timeout: 20_000 });
  const secret = (await modal.locator('.tfa-modal-body').innerText()).replace(/\s+/g, ' ').match(/\b([A-Z2-7]{16,})\b/)[1];
  await modal.locator('.tfa-modal-body input[type=text]:visible, .tfa-modal-body input[name=key]').first().fill(totp(secret));
  await (await next.isVisible() ? next : modal.locator('.tfa-modal-body [type=submit]').first()).click();
  await expect(modal.locator('.tfa-modal-body'), 'the backup code is shown').toContainText(/backup code/i, { timeout: 20_000 });
  await page.waitForTimeout(3000);
  await expect(modal, 'and stays up until the customer closes it').toBeVisible();
  const backup = (await modal.locator('.tfa-modal-body').innerText()).match(/\b([a-z0-9]{4}\s?[a-z0-9]{4}\s?[a-z0-9]{4}\s?[a-z0-9]{4})\b/i)?.[1]?.replace(/\s/g, '');
  expect(backup, 'backup code').toBeTruthy();
  await expect(next).toHaveText(/close/i);
  await next.click();
  await page.waitForLoadState('load');
  await expect(page.locator('.tfa-status-pill.on'), 'the status card says enabled').toBeVisible();

  // Sign in again: the challenge, answered with a code from a NEW 30 s window.
  await context.clearCookies();
  await signIn(page, p.email, p.password);
  expect(await tpl(page)).toBe('two-factor-challenge');
  await page.waitForTimeout(31_000 - (Date.now() % 30_000));
  await page.locator('input[name=key]:visible, .content-area input[type=text]:visible').first().fill(totp(secret));
  await page.locator('.content-area form [type=submit]:visible').first().click();
  await page.waitForLoadState('load');
  expect(await auth(page), 'signed in with the TOTP code').toBe('in');

  // With the backup code: WHMCS issues a new one on the next page.
  await context.clearCookies();
  await signIn(page, p.email, p.password);
  expect(await tpl(page)).toBe('two-factor-challenge');
  await page.locator('.content-area a, .content-area button').filter({ hasText: /backup/i }).first().click();
  await page.locator('.content-area input[type=text]:visible, input[name=code]:visible').first().fill(backup);
  await page.locator('.content-area form:visible [type=submit]').first().click();
  await page.waitForLoadState('load');
  expect(await tpl(page)).toBe('two-factor-new-backup-code');
  expect(inspect(await page.content(), { expectAuth: 'in' }).problems).toEqual([]);
  expect(errors).toEqual([]);
});

test('a user on two accounts picks one, and is asked before a link switches account', async ({ page }) => {
  const p = creds.personas.multi;
  await signIn(page, p.email, p.password);
  if (await tpl(page) !== 'user-switch-account') await page.goto('/index.php?rp=/user/accounts');
  expect(await tpl(page)).toBe('user-switch-account');
  await page.locator(`.sw-row[data-sw-id="${creds.personas.full.clientId}"]`).click();
  await page.waitForLoadState('load');
  expect(await tpl(page), 'switched into the account').toBe('clientareahome');
  // An invoice that belongs to the OTHER account.
  await page.goto(`/viewinvoice.php?id=${id.suspendedInvoiceId}`);
  await page.waitForLoadState('load');
  expect(inspect(await page.content(), { expectAuth: 'in' }).problems).toEqual([]);
  const form = page.locator('form[action*="user/accounts"]:has(input[name=id])');
  await expect(form, 'the forced switch asks first').toHaveCount(1);
  await form.locator('[type=submit]').click();
  await page.waitForLoadState('load');
  expect(await auth(page)).toBe('in');
});

test('choosing Arabic switches the language without breaking the layout', async ({ page }) => {
  // Hadrian has no right-to-left stylesheet (Lagom sets dir="rtl" only when it
  // ships theme-rtl.css), so this checks the translation renders cleanly LTR.
  const errors = watchErrors(page);
  await page.goto('/?language=arabic');
  await expect(page.locator('html')).toHaveAttribute('lang', /^ar/);
  const overflow = await page.evaluate(() => document.documentElement.scrollWidth - innerWidth);
  expect(overflow, 'no horizontal overflow in Arabic').toBeLessThanOrEqual(1);
  expect(inspect(await page.content()).problems).toEqual([]);
  await page.goto('/?language=english');
  expect(errors).toEqual([]);
});

test('the contact form sends a message (signed in: no CAPTCHA on this install)', async ({ page, context }) => {
  const errors = watchErrors(page);
  await loginClient(context.request, 'full');
  await page.goto('/contact.php');
  const f = page.locator('form:has([name=message])').first();
  // WHMCS only fills name/email back in after a failed post (stock does the same).
  await f.locator('[name=name]').fill('Contact Flowtest');
  await f.locator('[name=email]').fill('flow+contact@demo.hadrian.test');
  await f.locator('[name=subject]').fill('[flow] contact form');
  await f.locator('[name=message]').fill('Sent by the Hadrian test suite.');
  await f.locator('[type=submit]').first().click();
  await page.waitForLoadState('load');
  await expect(page.locator('.content-area').first()).toContainText(/sent|thank|success/i);
  expect(errors).toEqual([]);
});

test('bulk domain management: tick a domain, pick an action, reach WHMCS\'s bulk page', async ({ page, context }) => {
  // Regression: the list had no checkboxes or #domainForm, and the sub-nav's
  // "Bulk Management" pointed at a non-existent action (it landed on the dashboard).
  const errors = watchErrors(page);
  await loginClient(context.request, 'full');
  await page.goto('/clientarea.php?action=domains');
  await expect(page.locator('#bulk'), 'no toolbar until a domain is ticked').toBeHidden();
  await page.locator('#domainForm input[name="domids[]"]').first().check();
  await expect(page.locator('#bulk')).toBeVisible();
  expect(page.url(), 'ticking does not open the domain').toMatch(/action=domains/);
  await page.locator('#bulk [data-bulk=nameservers]').click();
  await page.waitForLoadState('load');
  expect(await tpl(page)).toBe('bulkdomainmanagement');
  expect(inspect(await page.content(), { expectAuth: 'in' }).problems).toEqual([]);
  expect(errors).toEqual([]);
});

test('a domain page opens the tab its link names (#tabNameservers)', async ({ page, context }) => {
  await loginClient(context.request, 'full');
  await page.goto(`/clientarea.php?action=domaindetails&id=${id.domainId}#tabNameservers`);
  await expect(page.locator('[data-dd-panel=nameservers]')).toHaveClass(/active/);
  await expect(page.locator('input[name=ns1]')).toBeVisible();
});

test('a customer replies to a ticket with the editor', async ({ page, context }) => {
  const errors = watchErrors(page);
  await loginClient(context.request, 'full');
  await page.goto(`/viewticket.php?tid=${id.ticketTid}&c=${id.ticketC}`);
  const reply = `[flow] reply ${Date.now()}`;
  await page.locator('textarea[name=replymessage]').fill(reply);
  await page.locator('form:has(textarea[name=replymessage]) [type=submit]').first().click();
  await page.waitForLoadState('load');
  expect(await auth(page)).toBe('in');
  await expect(page.locator('.content-area')).toContainText(reply);
  expect(errors).toEqual([]);
});
