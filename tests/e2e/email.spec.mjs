// Tier 3c (email) - Hadrian Email Templates, driven through its own admin UI.
//
// A SEPARATE addon module (hadrian_email/, mounted at modules/addons/HadrianEmail)
// that requires Hadrian. What is checked here is what only a browser and a real
// inbox can show:
//   - it plugs into Hadrian's admin (a tab, a card) without living inside it
//   - "Turn on" really changes what WHMCS sends, and "Turn off" really gives
//     WHMCS's own mail settings back, byte for byte
//   - the block builder: select, type, drag, publish - and the email that
//     arrives in Mailpit carries the design
//   - nothing answers a visitor who is not signed in, and the writes are
//     CSRF-protected for one who is
//   - with Hadrian deactivated the module stands down
//
// Runs in the `settings` project, so in its own run.mjs step with one worker:
// the takeover changes the header of EVERY email the install sends, and the
// flows tier reads emailed links from that same inbox. Every test starts from,
// and the suite ends on, tests/php/email.php reset.

import { test, expect } from '@playwright/test';
import { execFileSync, spawnSync } from 'node:child_process';
import path from 'node:path';
import { PHP, TESTS_DIR, BASE_URL, USER_AGENT } from '../lib/env.mjs';
import { fx, creds, loginAdmin, mailTo } from './helpers.mjs';

const MODULE = '/admin/addonmodules.php?module=HadrianEmail';
const HADRIAN = '/admin/addonmodules.php?module=Hadrian';
const full = creds.personas.full;

const php = (script, ...args) => execFileSync(PHP, [path.join(TESTS_DIR, 'php', script), ...args], { encoding: 'utf8' }).trim();
const email = (...args) => { const out = php('email.php', ...args); return out.startsWith('{') ? JSON.parse(out) : out; };
const state = () => email('state');

test.describe.configure({ mode: 'default' });
let mailMark = '0';
test.beforeAll(() => { email('reset'); email('snapshot'); mailMark = String(email('mail-mark')); });
test.beforeEach(async ({ page }) => { await loginAdmin(page.context().request); });
test.afterEach(() => { email('reset'); });
test.afterAll(() => {
  // The emails sent here are in the test client's email history. Left there,
  // the smoke crawl opens them and follows their links.
  email('mail-clean', mailMark);
  const r = email('reset');
  // The promise the module makes to an admin: switch it off and WHMCS is as it was.
  expect(r.mailSame, "WHMCS's global email header, footer and CSS are back to what they were").toBe(true);
  expect(r.rowSame, 'the WHMCS email template is back to what it was').toBe(true);
});

/** The builder has drawn every block of its document into the preview frame. */
const settled = page => page.waitForFunction(() => {
  const f = document.getElementById('hxb-frame'), d = f && f.contentDocument;
  if (!d || !d.body || document.querySelector('.hxb-busy')) return false;
  return window.hxBuilder.state.doc.blocks.every(b => b.type === 'spacer' || d.querySelector(`[data-hx-block="${b.id}"]`));
}, null, { timeout: 20_000 });

const blockTypes = page => page.evaluate(() => window.hxBuilder.state.doc.blocks.map(b => b.type));

test('it is its own module, and it plugs into the Hadrian admin', async ({ page }) => {
  // Hadrian's pages show a tab for it...
  await page.goto(`${HADRIAN}&action=settings`);
  const tab = page.locator('.mt-topnav-item', { hasText: /^Email$/ });
  await expect(tab, 'Hadrian navigation has an Email tab').toHaveCount(1);
  expect(await tab.getAttribute('href'), 'which leads to the other module, not to a Hadrian action').toBe('?module=HadrianEmail');

  // ...and a card on Extensions.
  await page.goto(`${HADRIAN}&action=extensions`);
  await expect(page.locator('.mt-card-title', { hasText: 'Email Templates' })).toBeVisible();

  // Its page is a different WHMCS addon, drawn in Hadrian's shell.
  await page.goto(MODULE);
  await expect(page).toHaveTitle('WHMCS - Hadrian Email Templates');
  await expect(page.locator('.mt-page-title')).toHaveText('Email templates');
  await expect(page.locator('.mt-topnav-item.is-active')).toHaveText('Email');
  expect(await page.locator('[data-mt-em-row]').count(), 'lists the client-facing WHMCS emails').toBeGreaterThan(40);
  await expect(page.locator('[data-mt-em-row]', { hasText: 'New Order Notification' }), 'admin notifications are not offered').toHaveCount(0);
});

test('turning it on changes what WHMCS sends; turning it off gives WHMCS back', async ({ page }) => {
  await page.goto(MODULE);
  await expect(page.locator('.mt-em-state .mt-row-label')).toHaveText('Hadrian email is off');
  await page.getByRole('button', { name: 'Turn on' }).click();
  await expect(page.locator('.mt-alert-success')).toContainText('Hadrian email is on');

  let s = state();
  expect(s.enabled).toBe(true);
  expect(s.headerGuard && s.footerGuard, 'WHMCS holds guarded placeholders, not a bare merge field').toBe(true);
  expect(s.designs.filter(d => d.kind === 'layout').length, 'the default layout was saved so it can be edited').toBe(1);

  const since = Date.now();
  expect(email('send', 'Client Signup Email', String(full.clientId)).result).toBe('success');
  const mail = await mailTo(full.email, since);
  expect(mail.html, 'wrapped in the layout').toContain('class="hx-container"');
  expect(mail.html, 'the WHMCS text is still the body').toContain('Dear ');
  expect(mail.html, 'language and direction are set from the recipient').toMatch(/<html lang="en" dir="ltr"/);
  expect(mail.html, 'nothing unrendered reaches the inbox').not.toMatch(/\{\$|\{if |\{\/if\}|hx-if/);

  page.once('dialog', d => d.accept());
  await page.getByRole('button', { name: 'Turn off' }).click();
  await expect(page.locator('.mt-alert-success')).toContainText('Hadrian email is off');
  s = state();
  expect(s.enabled).toBe(false);
  expect(s.headerGuard || s.footerGuard, 'placeholders are gone').toBe(false);
});

test('the builder: select, edit, drag, publish - and the inbox gets the design', async ({ page }) => {
  test.setTimeout(120_000);
  email('enable');
  await page.goto(`${MODULE}&action=builder&target=${encodeURIComponent('Invoice Created')}`);
  await settled(page);
  await expect(page.locator('#hxb-status')).toHaveText('Not saved yet');
  await expect(page.locator('#hxb-notice')).toContainText('starter design');

  const overlay = await page.locator('#hxb-overlay').boundingBox();
  const at = r => ({ x: overlay.x + r.left + 30, y: overlay.y + r.top + r.height / 2 });

  // Select the heading on the canvas and retitle it with a merge field.
  let rects = await page.evaluate(() => window.hxBuilder.rects());
  await page.mouse.click(at(rects[0]).x, at(rects[0]).y);
  await expect(page.locator('.hxb-insp-title')).toHaveText('Heading');
  await page.locator('#hxb-inspector input.mt-input').first().fill('Invoice {$invoice_num} from the test suite');
  await page.waitForFunction(() => /Invoice 3187 from the test suite/.test(document.getElementById('hxb-frame').contentDocument?.body?.innerText || ''));

  // Drag a Callout from the palette to just above the third block.
  const before = await blockTypes(page);
  rects = await page.evaluate(() => window.hxBuilder.rects());
  const pal = await page.locator('.hxb-pal[data-type="callout"]').boundingBox();
  await page.mouse.move(pal.x + pal.width / 2, pal.y + pal.height / 2);
  await page.mouse.down();
  await page.mouse.move(pal.x + pal.width / 2 + 30, pal.y + 30, { steps: 4 });
  await page.mouse.move(overlay.x + overlay.width / 2, overlay.y + rects[2].top + 2, { steps: 12 });
  await expect(page.locator('.hxb-line'), 'an insertion line shows where it will land').toHaveCount(1);
  await page.mouse.up();
  await settled(page);
  const after = await blockTypes(page);
  expect(after, 'the block landed where the line was').toEqual([...before.slice(0, 2), 'callout', ...before.slice(2)]);

  // The new block is selected: write its text in the rich editor.
  await expect(page.locator('.hxb-insp-title')).toHaveText('Callout');
  const rich = page.locator('#hxb-inspector .hxb-rich').first();
  await rich.click();
  await page.keyboard.press('ControlOrMeta+a');
  await page.keyboard.type('Paid by card? Nothing to do.');
  await settled(page);

  // Keyboard reordering, for people who do not drag.
  await page.locator('#hxb-overlay').focus();
  await page.keyboard.press('Alt+ArrowUp');
  await settled(page);
  expect((await blockTypes(page)).indexOf('callout'), 'Alt+Up moved it up one').toBe(1);

  // Publish.
  await page.locator('#hxb-publish').click();
  await expect(page.locator('#hxb-notice .mt-alert-success')).toContainText('Published to the "Invoice Created" email template');
  await expect(page.locator('#hxb-status')).toHaveText('Published');

  const since = Date.now();
  expect(email('send', 'Invoice Created', String(fx.ids.invoiceId)).result, 'WHMCS could compile the published body').toBe('success');
  const mail = await mailTo(full.email, since);
  expect(mail.html, 'the retitled heading, with the merge field filled in by WHMCS').toMatch(/Invoice \d+ from the test suite/);
  expect(mail.html, 'the dragged-in callout').toContain('Paid by card? Nothing to do.');
  expect(mail.html, 'the button block').toContain('hx-btn');
  expect(mail.html, 'inside the layout').toContain('class="hx-container"');
  expect(mail.html).not.toMatch(/\{\$|\{if |\{\/if\}/);

  // Back on the overview it reads as published, and removing the design
  // puts the WHMCS template back.
  await page.goto(MODULE);
  // By the row's own key, not by text: "Credit Card Invoice Created" also
  // contains "Invoice Created" and sorts first.
  const row = page.locator('[data-mt-em-row^="invoice created "]');
  await expect(row.locator('.mt-badge')).toHaveText('Published');
  const hashPublished = state().templateHash;
  page.once('dialog', d => d.accept());
  await row.getByRole('button', { name: 'Remove design' }).click();
  await expect(page.locator('.mt-alert-success')).toContainText('back to its WHMCS template');
  expect(state().templateHash, 'the template row changed back').not.toBe(hashPublished);
  expect(state().designs.filter(d => d.kind === 'message')).toEqual([]);
});

test('an email with no starter keeps its text, and an emptied design still takes a drop', async ({ page }) => {
  // No starter exists for this one: its WHMCS body is carried over.
  await page.goto(`${MODULE}&action=builder&target=${encodeURIComponent('Credit Card Expiring Soon')}`);
  await settled(page);
  await expect(page.locator('#hxb-notice')).toContainText('current WHMCS text was carried over');
  expect((await blockTypes(page)).length, 'imported as at least one block').toBeGreaterThan(0);

  // Empty it. The canvas must still say where a block would go.
  while ((await blockTypes(page)).length) {
    await page.locator('.hxb-out').first().click();
    await page.locator('#hxb-overlay').focus();
    await page.keyboard.press('Delete');
  }
  await page.waitForFunction(() => !document.querySelector('.hxb-busy') && !!document.querySelector('.hxb-empty'));
  await expect(page.locator('.hxb-empty')).toContainText('Add a block to start designing it');

  const overlay = await page.locator('#hxb-overlay').boundingBox();
  const hint = await page.locator('.hxb-empty').boundingBox();
  const pal = await page.locator('.hxb-pal[data-type="text"]').boundingBox();
  await page.mouse.move(pal.x + pal.width / 2, pal.y + pal.height / 2);
  await page.mouse.down();
  await page.mouse.move(pal.x + 40, pal.y + 40, { steps: 4 });
  await page.mouse.move(hint.x + hint.width / 2, hint.y + hint.height / 2, { steps: 10 });
  await expect(page.locator('.hxb-line')).toHaveCount(1);
  const line = await page.locator('.hxb-line').boundingBox();
  expect(line.y, 'the insertion line sits inside the content area').toBeGreaterThan(overlay.y + 40);
  await page.mouse.up();
  await settled(page);
  expect(await blockTypes(page)).toEqual(['text']);
  expect(state().designs, 'nothing was saved by merely editing').toEqual([]);
});

test('the layout builder saves, and a saved layout is live straight away', async ({ page }) => {
  email('enable');
  await page.goto(`${MODULE}&action=builder&layout=1`);
  await settled(page);
  expect(await blockTypes(page)).toEqual(['header', 'content', 'footer']);

  // The content slot is fixed: it can be selected but not deleted.
  await page.locator('.hxb-out', { hasText: 'Email content' }).click();
  await expect(page.locator('#hxb-inspector .hxb-ico[title="Delete"]')).toHaveCount(0);

  // Give the header a tagline.
  await page.locator('.hxb-out', { hasText: 'Header' }).click();
  await page.locator('#hxb-inspector .hxb-field', { hasText: 'Tagline' }).locator('input').fill('Hosting that answers the phone');
  await settled(page);
  await page.locator('#hxb-save').click();
  await expect(page.locator('#hxb-notice .mt-alert-success')).toContainText('Emails sent from now on use it');

  const since = Date.now();
  email('send', 'Client Signup Email', String(full.clientId));
  const mail = await mailTo(full.email, since);
  expect(mail.html).toContain('Hosting that answers the phone');
});

test('six designs: picking one on the Email page changes the next email', async ({ page }) => {
  email('enable');
  await page.goto(MODULE);
  await expect(page.locator('.mt-em-design')).toHaveCount(6);
  await expect(page.locator('[data-mt-em-design-group="classic"] .mt-em-design')).toHaveCount(3);
  await expect(page.locator('[data-mt-em-design-group="client"] .mt-em-design')).toHaveCount(3);
  await expect(page.locator('.mt-em-design.is-active h3')).toHaveText('Card');
  for (const id of ['card', 'banner', 'letter', 'page', 'panel', 'notice']) {
    await expect(page.locator(`[data-mt-em-design="${id}"] iframe`), `${id} has a live preview`).toHaveCount(1);
  }

  // Banner: an accent band carrying the email's own subject.
  await page.locator('[data-mt-em-design="banner"] button', { hasText: 'Use Banner' }).click();
  await expect(page.locator('.mt-alert-success')).toContainText('The Banner design is in use');
  await expect(page.locator('.mt-em-design.is-active h3')).toHaveText('Banner');
  let since = Date.now();
  expect(email('send', 'Invoice Created', String(fx.ids.invoiceId)).result).toBe('success');
  let mail = await mailTo(full.email, since);
  expect(mail.html, 'the band').toContain('class="hx-band"');
  expect(mail.html, 'with this email\'s WHMCS subject as its title').toMatch(/class="hx-title[^"]*"[^>]*>Customer Invoice</);
  expect(mail.html).not.toMatch(/\{\$|hx-if|hx_subject/);

  // Letter: no card, the page is the surface colour.
  await page.locator('[data-mt-em-design="letter"] button', { hasText: 'Use Letter' }).click();
  await expect(page.locator('.mt-em-design.is-active h3')).toHaveText('Letter');
  since = Date.now();
  email('send', 'Invoice Created', String(fx.ids.invoiceId));
  mail = await mailTo(full.email, since);
  expect(mail.html).toContain('<body class="hx-surface"');
  expect(mail.html).not.toContain('class="hx-band"');
  expect(mail.html, 'no card around the message').not.toMatch(/class="hx-content hx-surface/);

  // Page: headed like a client-area page. Section from the template's type,
  // status pill from what "Invoice Created" means, both in WHMCS's own words.
  await page.locator('[data-mt-em-design="page"] button', { hasText: 'Use Page' }).click();
  await expect(page.locator('.mt-em-design.is-active h3')).toHaveText('Page');
  since = Date.now();
  email('send', 'Invoice Created', String(fx.ids.invoiceId));
  mail = await mailTo(full.email, since);
  expect(mail.html, 'the section').toMatch(/text-transform:uppercase;[^"]*">Billing</);
  expect(mail.html, 'the title').toMatch(/class="hx-title[^"]*"[^>]*>Customer Invoice</);
  expect(mail.html, 'the status pill').toMatch(/class="hx-tint-warning hx-ink-warning"[^>]*>Unpaid</);
  expect(mail.html).not.toMatch(/\{\$|hx-if|hx_/);

  // Back to the default, so later tests start where they expect.
  await page.locator('[data-mt-em-design="card"] button', { hasText: 'Use Card' }).click();
  await expect(page.locator('.mt-em-design.is-active h3')).toHaveText('Card');
});

test('the builder switches design and keeps what was written', async ({ page }) => {
  await page.goto(`${MODULE}&action=builder&layout=1`);
  await settled(page);
  // Something of the admin's own, to prove it survives the switch.
  await page.locator('.hxb-out', { hasText: 'Header' }).click();
  await page.locator('#hxb-inspector .hxb-field', { hasText: 'Tagline' }).locator('input').fill('Hosting that answers the phone');
  await settled(page);
  await page.keyboard.press('Escape');
  await page.locator('#hxb-overlay').click({ position: { x: 4, y: 4 } });   // empty space: deselect
  await expect(page.locator('.hxb-design.is-active strong')).toHaveText('Card');

  await page.locator('.hxb-design[data-design="banner"]').click();
  await settled(page);
  const frame = page.frameLocator('#hxb-frame');
  await expect(frame.locator('.hx-band'), 'the preview shows the band').toHaveCount(1);
  await expect(frame.locator('.hx-title'), 'with a sample subject').toHaveText('Invoice #3187 is ready');
  await expect(frame.locator('.hx-band'), 'and the tagline carried over').toContainText('Hosting that answers the phone');
  await expect(page.locator('#hxb-status')).not.toHaveText('Saved');

  await page.locator('.hxb-design[data-design="letter"]').click();
  await settled(page);
  await expect(frame.locator('.hx-band')).toHaveCount(0);
  await expect(frame.locator('body.hx-surface')).toHaveCount(1);
});

test('dark and right-to-left previews come from the same design', async ({ page }) => {
  await page.goto(`${MODULE}&action=builder&layout=1`);
  await settled(page);
  await page.locator('#hxb-scheme button[data-v="dark"]').click();
  await page.waitForFunction(() => {
    const b = document.getElementById('hxb-frame').contentDocument?.body;
    return !!b && getComputedStyle(b).backgroundColor !== 'rgb(251, 251, 253)';
  });
  const bg = await page.evaluate(() => getComputedStyle(document.getElementById('hxb-frame').contentDocument.body).backgroundColor);
  const [r, g, b] = bg.match(/\d+/g).map(Number);
  expect(r + g + b, `dark preview has a dark page background (${bg})`).toBeLessThan(200);

  // Right to left, when the install has such a language. Asked of the API
  // directly so the test does not depend on which languages the site offers.
  const boot = JSON.parse(await page.locator('#hxb-boot').textContent());
  const rtl = boot.languages.find(l => l.rtl);
  test.skip(!rtl, 'no right-to-left language installed in this WHMCS');
  const res = await page.request.post(`${MODULE}&action=api-preview`, {
    data: { token: boot.token, kind: 'layout', doc: boot.doc, lang: rtl.code },
  });
  const html = (await res.json()).html;
  expect(html).toMatch(/<html lang="[a-z-]+" dir="rtl"/);
  expect(html, 'start-aligned text is right-aligned').toMatch(/text-align:right/);
});

test('nothing answers a visitor who is not signed in', async ({ playwright }) => {
  // WHMCS loads an addon's hooks.php BEFORE it checks the admin login, so an
  // endpoint dispatched from there runs for anyone on the internet. These are
  // dispatched from _output() instead. An anonymous visitor does have a
  // session and a valid CSRF token for it (the login form carries one), so
  // the token alone would not have stopped this.
  const anon = await playwright.request.newContext({ baseURL: BASE_URL, userAgent: USER_AGENT });
  try {
    const login = await (await anon.get('/admin/login.php')).text();
    const token = (login.match(/name="token" value="([^"]+)"/) || [])[1];
    expect(token, 'an anonymous session has a CSRF token of its own').toBeTruthy();
    const doc = { blocks: [{ type: 'header' }, { type: 'content' }, { type: 'footer' }] };

    for (const action of ['api-preview', 'api-save', 'api-publish', 'api-restore']) {
      const res = await anon.post(`${MODULE}&action=${action}`, { data: { token, kind: 'layout', doc, id: 1 }, maxRedirects: 0 });
      expect(res.status(), `${action} for an anonymous visitor`).toBe(302);
      expect(res.headers()['location'], `${action} goes to the login page`).toContain('login.php');
    }
    for (const action of ['enable', 'disable', 'settings', 'reapply', 'delete']) {
      const res = await anon.post(`${MODULE}&action=${action}`, { form: { token, id: '1' }, maxRedirects: 0 });
      expect(res.status(), `${action} for an anonymous visitor`).toBe(302);
      expect(res.headers()['location']).toContain('login.php');
    }
    const s = state();
    expect(s.enabled, 'nothing was switched on').toBe(false);
    expect(s.designs, 'nothing was saved').toEqual([]);
  } finally {
    await anon.dispose();
  }
});

test('every write is refused without the admin CSRF token', async ({ page }) => {
  await page.goto(`${MODULE}&action=builder&layout=1`);
  const boot = JSON.parse(await page.locator('#hxb-boot').textContent());
  expect(boot.token, 'the page was given a token').toMatch(/^[a-f0-9]{20,}$/);

  for (const action of ['api-save', 'api-publish', 'api-restore', 'api-preview']) {
    const res = await page.request.post(`${MODULE}&action=${action}`, { data: { token: 'not-the-token', kind: 'layout', doc: boot.doc, id: 1 } });
    expect(res.status(), `${action} with a wrong token`).toBe(403);
    expect((await res.json()).ok).toBe(false);
  }
  // The form posts redirect back with an error instead of acting.
  await page.request.post(`${MODULE}&action=enable`, { form: { token: 'not-the-token' } });
  expect(state().enabled, 'a forged "Turn on" did nothing').toBe(false);
  expect(state().designs, 'a forged save created nothing').toEqual([]);
});

test('with Hadrian deactivated the module stands down', async ({ page }) => {
  const cfg = (...args) => php('whmcs-config.php', ...args);
  const active = JSON.parse(cfg('get', 'ActiveAddonModules'));
  try {
    cfg('set', 'ActiveAddonModules', active.split(',').filter(m => m.trim() !== 'Hadrian').join(','));
    await page.goto(MODULE);
    await expect(page.locator('body')).toContainText('Hadrian Email Templates needs Hadrian');
    await expect(page.locator('body')).toContainText('installed but not activated');
    await expect(page.getByRole('button', { name: 'Turn on' }), 'it cannot be turned on').toHaveCount(0);

    // Nor by posting the action directly.
    const token = await page.evaluate(() => (document.querySelector('input[name="token"]') || {}).value || '');
    await page.request.post(`${MODULE}&action=enable`, { form: { token } });
    expect(state().enabled).toBe(false);
    expect(state().headerGuard, "WHMCS's own header is untouched").toBe(false);
  } finally {
    cfg('set', 'ActiveAddonModules', active);
  }
});

test('the engine against live WHMCS: takeover, fallback, publish, drift, restore', () => {
  test.setTimeout(180_000);
  const r = spawnSync(PHP, [path.join(TESTS_DIR, 'php', 'email-live.php')], { encoding: 'utf8' });
  const failed = (r.stdout || '').split('\n').filter(l => l.includes('FAIL'));
  expect(failed, r.stdout + r.stderr).toEqual([]);
  expect(r.status, r.stdout + r.stderr).toBe(0);
});
