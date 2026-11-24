// Tier 3c (builder) - Hadrian Page Builder, driven through its own editor.
//
// A SEPARATE addon module (hadrian_builder/, mounted at modules/addons/HadrianBuilder)
// that requires Hadrian. What is checked here is what only a browser and a
// real WHMCS can show:
//   - it plugs into Hadrian's admin (a tab, a card) without living inside it
//   - a page built in the editor is served at its address, inside the theme,
//     with no rewrite rule added anywhere
//   - a draft is never public: saving does not change the live page, the
//     preview is for signed-in admins only, unpublishing takes the page down
//   - a price card shows the price WHMCS itself gives for the product
//   - a translation shows to a visitor browsing in that language
//   - a built page cannot take over an address WHMCS answers
//   - unless the admin says so: a built page can stand in for a theme page,
//     switched for the whole site or page by page, and switched back
//   - nothing answers a visitor who is not signed in, and the writes are
//     CSRF-protected for one who is
//
// Runs in the `settings` project (one worker): it creates and publishes pages
// on the install the other tiers crawl. Every page it makes is named "E2E ..."
// and tests/php/builder.php clean removes them before and after.

import { test, expect } from '@playwright/test';
import { execFileSync } from 'node:child_process';
import path from 'node:path';
import { PHP, TESTS_DIR, BASE_URL, USER_AGENT } from '../lib/env.mjs';
import { loginAdmin } from './helpers.mjs';

const MODULE = '/admin/addonmodules.php?module=HadrianBuilder';
const HADRIAN = '/admin/addonmodules.php?module=Hadrian';

const builder = (...args) => JSON.parse(execFileSync(PHP, [path.join(TESTS_DIR, 'php', 'builder.php'), ...args], { encoding: 'utf8' }).trim());
const pages = () => builder('state');

test.describe.configure({ mode: 'default' });
test.beforeAll(() => { builder('clean'); });
test.beforeEach(async ({ page }) => { await loginAdmin(page.context().request); });
test.afterAll(() => { builder('clean'); });

/** The preview frame shows the document as it is now. */
const settled = page => page.waitForFunction(() => {
  const b = window.hbBuilder, f = document.getElementById('hbx-frame'), d = f && f.contentDocument;
  if (!b || !b.idle() || !d || !d.body) return false;
  return b.state.doc.sections.every(s => d.querySelector(`[data-hb-id="${s.id}"]`));
}, null, { timeout: 30_000 });

const frame = page => page.frameLocator('#hbx-frame');
const field = (page, label) => page.locator('#hbx-inspector .hbx-field', { has: page.locator('.hbx-label', { hasText: new RegExp(`^${label}`) }) }).first();
// The palette's groups are collapsed; the filter finds a section by its name.
const addSection = async (page, label) => {
  await page.locator('#hbx-palfilter').fill(label);
  await page.locator('.hbx-pal', { has: page.locator('strong', { hasText: new RegExp('^' + label.replace(/[.*+?^$()|[\]\\{}]/g, '\\$&') + '$') }) }).click();
  await page.locator('#hbx-palfilter').fill('');
  await settled(page);
};
const sectionTypes = page => page.evaluate(() => window.hbBuilder.state.doc.sections.map(s => s.type));

/** Make a page through the list screen and land in its editor. Returns its id. */
async function createPage(page, name) {
  await page.goto(MODULE);
  await page.locator('#pb-name').fill(name);
  await page.getByRole('button', { name: 'Create page' }).click();
  await expect(page.locator('#hbx')).toBeVisible();
  await settled(page);
  return page.evaluate(() => JSON.parse(document.getElementById('hbx-boot').textContent).id);
}
async function setAddress(page, slug) {
  await page.locator('#hbx-pagebtn').click();
  await page.locator('#hbx-page-slug').fill(slug);
}
async function saveDraft(page) {
  await page.locator('#hbx-save').click();
  await expect(page.locator('#hbx-notice .mt-alert-success')).toContainText('Draft saved');
}
async function publish(page) {
  await page.locator('#hbx-publish').click();
  await expect(page.locator('#hbx-notice .mt-alert-success')).toContainText('Published');
}
/** A visitor with no session at all. */
async function visitor(playwright) {
  return playwright.request.newContext({ baseURL: BASE_URL, userAgent: USER_AGENT });
}

test('it is its own module, and it plugs into the Hadrian admin', async ({ page }) => {
  await page.goto(`${HADRIAN}&action=settings`);
  const tab = page.locator('.mt-topnav-item', { hasText: /^Builder$/ });
  await expect(tab, 'Hadrian navigation has a Builder tab').toHaveCount(1);
  expect(await tab.getAttribute('href'), 'which leads to the other module, not to a Hadrian action').toBe('?module=HadrianBuilder');

  await page.goto(`${HADRIAN}&action=extensions`);
  await expect(page.locator('.mt-card-title', { hasText: 'Page Builder' })).toBeVisible();

  await page.goto(MODULE);
  await expect(page).toHaveTitle('WHMCS - Hadrian Page Builder');
  await expect(page.locator('.mt-page-title')).toHaveText('Page builder');
  await expect(page.locator('.mt-topnav-item.is-active')).toHaveText('Builder');
  // The shared header shows the theme's real version here too, as on Hadrian's own pages.
  await expect(page.locator('.mt-brand-ver'), 'the header carries the theme version').toHaveText(/^v\d+\.\d+/);
});

test('build a page in the editor, publish it, and visit it', async ({ page, playwright }) => {
  await createPage(page, 'E2E Landing');
  await expect(page.locator('#hbx-status')).toHaveText('Draft');
  await expect(frame(page).locator('.hb-note'), 'an empty page says so in the preview').toBeVisible();

  await addSection(page, 'Hero, split');
  await addSection(page, 'Feature cards');
  await addSection(page, 'Questions and answers');
  expect(await sectionTypes(page)).toEqual(['hero-split', 'feature-cards', 'faq']);

  // The preview is the theme's own page: header, footer and the section classes.
  await expect(frame(page).locator('.hp-hero-split h1')).toBeVisible();
  await expect(frame(page).locator('.hp-feature-card')).toHaveCount(6);
  // "Desktop" lays the page out at desktop width, scaled to fit beside the panels.
  expect(await page.locator('#hbx-frame').evaluate(f => f.contentWindow.innerWidth), 'the frame is desktop-wide').toBe(1280);
  await page.locator('#hbx-device button[data-v="mobile"]').click();
  expect(await page.locator('#hbx-frame').evaluate(f => f.contentWindow.innerWidth), 'and phone-wide on Mobile').toBe(390);
  await page.locator('#hbx-device button[data-v="desktop"]').click();
  expect(await frame(page).locator('body').getAttribute('data-tpl'), 'drawn through the theme').toBe('module-page');

  // Clicking a section in the preview selects it; typing changes the preview.
  await frame(page).locator('.hp-hero-split h1').click();
  await expect(page.locator('.hbx-insp-title')).toHaveText('Hero, split');
  await field(page, 'Headline').locator('input').fill('E2E headline one');
  await settled(page);
  await expect(frame(page).locator('.hp-hero-split h1')).toHaveText('E2E headline one');
  await expect(page.locator('#hbx-status')).toHaveText('Unsaved changes');

  // A new page is offered an address made from its name.
  await page.locator('#hbx-pagebtn').click();
  await expect(page.locator('#hbx-page-slug')).toHaveValue('e2e-landing');

  // Without one, publishing says what is missing instead of failing quietly.
  await page.locator('#hbx-page-slug').fill('');
  await page.locator('#hbx-publish').click();
  await expect(page.locator('#hbx-notice .mt-alert-danger')).toContainText('address');
  await expect(page.locator('.hbx-error')).toContainText('address');

  // A bad address is refused with the rule.
  await page.locator('#hbx-page-slug').fill('Not A Slug!');
  await page.locator('#hbx-save').click();
  await expect(page.locator('.hbx-error')).toContainText('lowercase letters');

  await page.locator('#hbx-page-slug').fill('hb-e2e-landing');
  await publish(page);
  await expect(page.locator('#hbx-status')).toHaveText('Published');
  await expect(page.locator('#hbx-view')).toHaveAttribute('href', '/hb-e2e-landing');

  // A visitor with no session gets the page, in the theme, with no editor markers.
  const anon = await visitor(playwright);
  try {
    const res = await anon.get('/hb-e2e-landing');
    expect(res.status(), 'the published page answers 200').toBe(200);
    const html = await res.text();
    expect(html).toContain('E2E headline one');
    expect(html, 'inside the theme').toContain('data-tpl="module-page"');
    expect(html, 'full-width like the store landings').toContain('data-bleed="1"');
    expect(html, 'no editor markers on the live page').not.toContain('data-hb-id');
    expect(html, 'the page title is in the document title').toContain('<title>E2E Landing');

    // WHMCS's other URL mode reaches the same page.
    expect((await anon.get('/index.php?rp=/hb-e2e-landing')).status()).toBe(200);
    // An address nobody built is still WHMCS's own not-found page.
    expect((await anon.get('/hb-e2e-nothing-here')).status()).toBe(404);

    // A draft is never public. Change the headline and save: the live page keeps the old one.
    await page.locator('.hbx-out', { hasText: 'Hero, split' }).click();
    await field(page, 'Headline').locator('input').fill('E2E headline two');
    await settled(page);
    await saveDraft(page);
    await expect(page.locator('#hbx-status')).toHaveText('Published, draft is newer');
    let live = await (await anon.get('/hb-e2e-landing')).text();
    expect(live, 'visitors still get what was published').toContain('E2E headline one');
    expect(live).not.toContain('E2E headline two');

    // The preview address is the draft, for a signed-in admin only.
    const id = await page.evaluate(() => window.hbBuilder.state.doc && JSON.parse(document.getElementById('hbx-boot').textContent).id);
    expect((await anon.get(`/hb-preview/${id}`)).status(), 'no preview for a visitor').toBe(404);
    const preview = await page.request.get(`/hb-preview/${id}`);
    expect(preview.status()).toBe(200);
    expect(await preview.text()).toContain('E2E headline two');
    expect(preview.headers()['x-robots-tag'], 'previews are not for search engines').toContain('noindex');

    await publish(page);
    live = await (await anon.get('/hb-e2e-landing')).text();
    expect(live, 'publishing puts the draft live').toContain('E2E headline two');

    // Taking it offline gives the address back to WHMCS's not-found page.
    page.once('dialog', d => d.accept());
    await page.locator('#hbx-pagebtn').click();
    await page.getByRole('button', { name: 'Take this page offline' }).click();
    await expect(page.locator('#hbx-status')).toHaveText('Draft');
    expect((await anon.get('/hb-e2e-landing')).status(), 'offline means 404').toBe(404);
  } finally {
    await anon.dispose();
  }
});

test('reorder, hide, duplicate, remove, and undo', async ({ page }) => {
  await createPage(page, 'E2E Structure');
  await addSection(page, 'Hero, split');
  await addSection(page, 'Feature cards');
  await addSection(page, 'Closing call to action');
  expect(await sectionTypes(page)).toEqual(['hero-split', 'feature-cards', 'final-cta']);

  // Move the selected (last) section up one.
  await page.getByRole('button', { name: 'Move section up' }).click();
  await settled(page);
  expect(await sectionTypes(page)).toEqual(['hero-split', 'final-cta', 'feature-cards']);
  const order = await frame(page).locator('[data-hb-type]').evaluateAll(nodes => nodes.map(n => n.getAttribute('data-hb-type')));
  expect(order, 'the preview follows').toEqual(['hero-split', 'final-cta', 'feature-cards']);

  // Drag the first section below the last in the outline.
  await page.locator('.hbx-out').nth(0).dragTo(page.locator('.hbx-out').nth(2), { targetPosition: { x: 40, y: 34 } });
  await settled(page);
  expect(await sectionTypes(page)).toEqual(['final-cta', 'feature-cards', 'hero-split']);

  await page.getByRole('button', { name: 'Duplicate section' }).click();
  await settled(page);
  expect((await sectionTypes(page)).length).toBe(4);

  // Hidden: still in the editor, marked, and gone from what a visitor would get.
  await page.locator('.hbx-out').nth(0).hover();
  await page.locator('.hbx-out').nth(0).getByRole('button', { name: 'Hide from the page' }).click();
  await settled(page);
  await expect(frame(page).locator('.hb-is-hidden')).toHaveCount(1);

  await page.locator('.hbx-out').nth(1).hover();
  await page.locator('.hbx-out').nth(1).getByRole('button', { name: 'Remove section' }).click();
  await settled(page);
  expect((await sectionTypes(page)).length).toBe(3);

  // Undo walks back through each step; redo goes forward again.
  await page.locator('#hbx-undo').click();
  await settled(page);
  expect((await sectionTypes(page)).length, 'undo brings the removed section back').toBe(4);
  await page.locator('#hbx-undo').click();
  await settled(page);
  await expect(frame(page).locator('.hb-is-hidden'), 'undo shows the hidden section again').toHaveCount(0);
  await page.locator('#hbx-redo').click();
  await settled(page);
  await expect(frame(page).locator('.hb-is-hidden')).toHaveCount(1);
});

test('a price card shows the price WHMCS gives for the product', async ({ page }) => {
  const products = builder('products').filter(p => !p.free && p.price);
  test.skip(products.length === 0, 'the install has no priced product to show');
  const product = products[0];

  await createPage(page, 'E2E Pricing');
  await addSection(page, 'Pricing cards');
  await expect(frame(page).locator('.hb-note'), 'with no plan chosen the editor says why nothing shows').toContainText('nothing to show yet');

  await page.getByRole('button', { name: '+ Add plan' }).click();
  await field(page, 'Product').locator('select').selectOption(String(product.id));
  await settled(page);

  const card = frame(page).locator('.hp-price-card');
  await expect(card).toHaveCount(1);
  await expect(card.locator('.label')).toContainText(product.name);
  await expect(card.locator('.price'), 'the amount is WHMCS\'s, not typed').toHaveText(product.price);
  expect(await card.locator('.buy').getAttribute('href'), 'the button orders that product').toBe(`/cart.php?a=add&pid=${product.id}`);

  // Nothing about the price is stored in the page.
  const stored = await page.evaluate(() => JSON.stringify(window.hbBuilder.state.doc));
  expect(stored).not.toContain(product.price);
});

test('a translation shows to a visitor browsing in that language', async ({ page, playwright }) => {
  await createPage(page, 'E2E Translated');
  const languages = await page.locator('#hbx-lang option').evaluateAll(o => o.map(x => x.value));
  test.skip(languages.length < 2, 'the install offers one language only');
  const other = languages[1];

  await addSection(page, 'Closing call to action');
  await field(page, 'Headline').locator('input').fill('E2E default headline');
  await page.locator('#hbx-lang').selectOption(other);
  // The default text is offered as the placeholder while translating.
  await expect(field(page, 'Headline').locator('input')).toHaveValue('');
  await expect(field(page, 'Headline').locator('input')).toHaveAttribute('placeholder', 'E2E default headline');
  await field(page, 'Headline').locator('input').fill('E2E other headline');
  await settled(page);
  await expect(frame(page).locator('.hp-final-cta h2'), 'the preview switches language with the editor').toHaveText('E2E other headline');

  await setAddress(page, 'hb-e2e-translated');
  await publish(page);

  const anon = await visitor(playwright);
  try {
    expect(await (await anon.get('/hb-e2e-translated')).text(), 'the default language gets the default text').toContain('E2E default headline');
    const translated = await (await anon.get(`/hb-e2e-translated?language=${other}`)).text();
    expect(translated, `a visitor browsing in ${other} gets the translation`).toContain('E2E other headline');
  } finally {
    await anon.dispose();
  }
});

test('a built page cannot take over an address WHMCS answers', async ({ page, playwright }) => {
  await createPage(page, 'E2E Shadow');
  await addSection(page, 'Closing call to action');
  await field(page, 'Headline').locator('input').fill('E2E must not replace WHMCS');
  await setAddress(page, 'knowledgebase');
  await publish(page);

  const anon = await visitor(playwright);
  try {
    const html = await (await anon.get('/knowledgebase')).text();
    expect(html, 'WHMCS still serves its own knowledgebase there').not.toContain('E2E must not replace WHMCS');
    expect(html).not.toContain('data-tpl="module-page"');
  } finally {
    await anon.dispose();
  }
});

test('a built page replaces a theme page when the site, or the page, says so', async ({ page, playwright }) => {
  const MARK = 'E2E replaces announcements';
  const before = builder('mode').mode;
  await createPage(page, 'E2E Replace');
  await addSection(page, 'Closing call to action');
  await field(page, 'Headline').locator('input').fill(MARK);
  await setAddress(page, 'e2e-replace');
  await publish(page);

  const anon = await visitor(playwright);
  const themePage = async () => (await anon.get('/announcements')).text();
  const row = () => page.locator('tr', { has: page.locator('.mt-pb-name', { hasText: 'E2E Replace' }) });
  try {
    builder('mode', 'theme');
    await page.goto(MODULE);
    await expect(row().locator('.mt-badge')).toHaveText('Published');

    // Point it at Announcements. The site is on Theme, so it only stands by.
    await row().locator('select[name="replaces"]').selectOption('announcements');
    await expect(page.locator('.mt-alert-success')).toContainText('now replaces Announcements');
    await expect(row().locator('.mt-badge')).toHaveText('Standby');
    expect(await themePage(), 'site on Theme: the theme page shows').not.toContain(MARK);

    // Flip the site. Now the built page is what visitors get there.
    await page.locator('#pb-site button[value="builder"]').click();
    await expect(row().locator('.mt-badge')).toHaveText('Serving');
    const html = await themePage();
    expect(html, 'site on Page Builder: the built page shows').toContain(MARK);
    expect(html, 'drawn through the theme').toContain('data-tpl="module-page"');
    expect((await anon.get('/announcements')).status(), 'as a normal page').toBe(200);

    // Only the front door: a view inside the page, and a page with no
    // replacement, are still the theme's.
    expect(await (await anon.get('/announcements?page=2')).text(), 'page 2 is the theme').not.toContain(MARK);
    expect(await (await anon.get('/knowledgebase')).text(), 'an unreplaced page is the theme').not.toContain(MARK);
    // And it keeps its own address throughout.
    expect(await (await anon.get('/e2e-replace')).text()).toContain(MARK);

    // The exception: "Never" keeps this one page on the theme.
    await row().locator('select[name="replace_rule"]').selectOption('never');
    await expect(row().locator('.mt-badge')).toHaveText('Standby');
    expect(await themePage(), 'rule Never: the theme page shows').not.toContain(MARK);

    // "Always" serves it even with the site back on Theme.
    await row().locator('select[name="replace_rule"]').selectOption('always');
    await page.locator('#pb-site button[value="theme"]').click();
    await expect(row().locator('.mt-badge')).toHaveText('Serving');
    expect(await themePage(), 'rule Always, site on Theme: the built page shows').toContain(MARK);

    // Unpublished, it cannot serve; the theme page is back with nothing lost.
    await row().locator('select[name="replaces"]').selectOption('');
    await expect(page.locator('.mt-alert-success')).toContainText('no longer replaces');
    expect(await themePage(), 'let go: the theme page shows').not.toContain(MARK);
  } finally {
    await anon.dispose();
    builder('mode', before);
  }
});

test('nothing answers a visitor who is not signed in', async ({ page, playwright }) => {
  const id = await createPage(page, 'E2E Guarded');
  const before = JSON.stringify(pages());

  // WHMCS loads an addon's hooks.php BEFORE it checks the admin login, so an
  // endpoint dispatched from there would run for anyone. These are dispatched
  // from _output() instead. An anonymous visitor has a session and a valid
  // CSRF token of their own, so the token alone would not stop them.
  const anon = await visitor(playwright);
  try {
    const login = await (await anon.get('/admin/login.php')).text();
    const token = (login.match(/name="token" value="([^"]+)"/) || [])[1];
    expect(token, 'an anonymous session has a CSRF token of its own').toBeTruthy();

    for (const action of ['api-preview', 'api-save', 'api-publish', 'api-unpublish']) {
      const res = await anon.post(`${MODULE}&action=${action}`, { data: { token, id, name: 'E2E Hijacked', slug: 'hb-e2e-hijack', doc: { sections: [] } }, maxRedirects: 0 });
      expect(res.status(), `${action} for an anonymous visitor`).toBe(302);
      expect(res.headers()['location'], `${action} goes to the login page`).toContain('login.php');
    }
    for (const action of ['create', 'delete']) {
      const res = await anon.post(`${MODULE}&action=${action}`, { form: { token, id: String(id), name: 'E2E Hijacked' }, maxRedirects: 0 });
      expect(res.status(), `${action} for an anonymous visitor`).toBe(302);
      expect(res.headers()['location']).toContain('login.php');
    }
    expect(JSON.stringify(pages()), 'nothing was created, changed or deleted').toBe(before);
  } finally {
    await anon.dispose();
  }
});

test('every write is refused without the admin CSRF token', async ({ page }) => {
  const id = await createPage(page, 'E2E Token');
  const boot = JSON.parse(await page.locator('#hbx-boot').textContent());
  expect(boot.token, 'the page was given a token').toMatch(/^[a-f0-9]{20,}$/);
  const before = JSON.stringify(pages());

  for (const action of ['api-save', 'api-publish', 'api-unpublish', 'api-preview']) {
    const res = await page.request.post(`${MODULE}&action=${action}`, { data: { token: 'not-the-token', id, name: 'E2E Forged', slug: 'hb-e2e-forged', doc: boot.doc } });
    expect(res.status(), `${action} with a wrong token`).toBe(403);
    expect((await res.json()).ok).toBe(false);
  }
  // The form posts redirect back with an error instead of acting.
  await page.request.post(`${MODULE}&action=create`, { form: { token: 'not-the-token', name: 'E2E Forged' } });
  await page.request.post(`${MODULE}&action=delete`, { form: { token: 'not-the-token', id: String(id) } });
  expect(JSON.stringify(pages()), 'a forged write changed nothing').toBe(before);

  // With the real token, delete works and the page is gone from the list.
  page.once('dialog', d => d.accept());
  await page.goto(MODULE);
  await page.locator('tr', { hasText: 'E2E Token' }).getByRole('button', { name: 'Delete' }).click();
  await expect(page.locator('.mt-alert-success')).toContainText('was deleted');
  expect(pages().some(p => p.id === id)).toBe(false);
});
