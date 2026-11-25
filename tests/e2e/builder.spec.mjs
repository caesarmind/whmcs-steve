// Tier 3c (builder) - Hadrian Page Builder, driven through its own editor.
//
// A SEPARATE addon module (hadrian_builder/, mounted at modules/addons/HadrianBuilder)
// that requires Hadrian. What is checked here is what only a browser and a
// real WHMCS can show:
//   - it plugs into Hadrian's admin without living inside it: a card on the
//     Extensions page, and no screen of its own. Its pages are listed, made,
//     replaced and deleted from Hadrian's Pages; only the editor is here
//   - a page built in the editor is served at its address, inside the theme,
//     with no rewrite rule added anywhere
//   - a draft is never public: saving does not change the live page, the
//     preview is for signed-in admins only, unpublishing takes the page down
//   - a price card shows the price WHMCS itself gives for the product
//   - a translation shows to a visitor browsing in that language
//   - a built page cannot take over an address WHMCS answers
//   - unless the admin says so: a built page can stand in for a theme page,
//     switched for the whole site or page by page, and switched back
//   - a built page is a row in Hadrian's Pages screen, and what is set there
//     (visibility, SEO) applies to it; the sitemap lists it only while live
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
// Where built pages are listed and made: the Built tab of Hadrian's Pages.
const PAGES = `${HADRIAN}&action=pages#tab=Built`;
const settingsOf = id => `${HADRIAN}&action=pages&sub=edit&page=built-${id}`;

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
const field = (page, label) => page.locator('#hbx-panel .hbx-field', { has: page.locator('.hbx-label', { hasText: new RegExp(`^${label}`) }) }).first();
const exact = label => new RegExp('^' + label.replace(/[.*+?^$()|[\]\\{}]/g, '\\$&') + '$');
// Add opens the section categories; its search finds a section by its name.
// A new section goes after the selected one, and its settings open.
const addSection = async (page, label) => {
  await page.locator('#hbx-addbtn').click();
  await page.locator('#hbx-palfilter').fill(label);
  await page.locator('.hbx-pal', { has: page.locator('strong', { hasText: exact(label) }) }).click();
  await expect(page.locator('.hbx-id-name'), 'its settings open').toHaveText(label);
  await settled(page);
};
// The list of sections on the page.
const layers = page => page.locator('#hbx-layersbtn').click();
const sectionTypes = page => page.evaluate(() => window.hbBuilder.state.doc.sections.map(s => s.type));

/** Make a page from the Built tab of Pages and land in its editor. Returns its id. */
async function createPage(page, name) {
  await page.goto(PAGES);
  const form = page.locator('[data-group-panel="Built"] [data-group-create]');
  await form.locator('input[name="name"]').fill(name);
  await form.getByRole('button', { name: 'Create page' }).click();
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
/** Delete a built page from its settings in Pages, where the button lives. */
async function deletePage(page, id) {
  await page.goto(settingsOf(id));
  page.once('dialog', dialog => dialog.accept());
  await page.locator('[data-page-extension-panel] [data-pb-delete]').click();
  await expect(page.locator('[data-ext-flash]')).toContainText('was deleted');
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
  // No tab of its own: it has no list screen, its pages are in Hadrian's Pages.
  await page.goto(`${HADRIAN}&action=settings`);
  await expect(page.locator('.mt-topnav-item', { hasText: /^Builder$/ }), 'Hadrian navigation has no Builder tab').toHaveCount(0);

  // It is still a module of its own, listed as one.
  await page.goto(`${HADRIAN}&action=extensions`);
  await expect(page.locator('.mt-card-title', { hasText: 'Page Builder' })).toBeVisible();

  // Its own address answers by opening the Built tab of Pages.
  await page.goto(MODULE);
  await expect(page).toHaveURL(/module=Hadrian&action=pages#tab=Built$/);
  const built = page.locator('[data-group-panel="Built"]');
  await expect(built, 'the Built tab is open').toBeVisible();
  await expect(built.locator('[data-group-create]'), 'with the form that makes a page').toBeVisible();
  await expect(built.locator('#pb-site'), 'and the switch for who serves the website').toBeVisible();

  // The editor is the one screen that is the module's own, drawn in Hadrian's shell.
  await createPage(page, 'E2E Shell');
  await expect(page).toHaveTitle('WHMCS - Hadrian Page Builder');
  await expect(page.locator('.mt-topnav-item.is-active'), 'it sits under Pages').toHaveText('Pages');
  await expect(page.locator('.hbx-bar .mt-back'), 'and leads back there').toHaveAttribute('href', '?module=Hadrian&action=pages#tab=Built');
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
  await expect(page.locator('.hbx-id-name')).toHaveText('Hero, split');
  await expect(frame(page).locator('#hbp-sel .hbp-tag'), 'and the page names it').toContainText('Hero, split');
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
    await layers(page);
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

  // Drag the first section below the last in Layers.
  await layers(page);
  await page.locator('.hbx-out').nth(0).dragTo(page.locator('.hbx-out').nth(2), { targetPosition: { x: 40, y: 34 } });
  await settled(page);
  expect(await sectionTypes(page)).toEqual(['final-cta', 'feature-cards', 'hero-split']);

  await page.locator('.hbx-out').nth(2).click();
  await expect(page.locator('.hbx-id-name')).toHaveText('Hero, split');
  await page.getByRole('button', { name: 'Duplicate section' }).click();
  await settled(page);
  expect((await sectionTypes(page)).length).toBe(4);

  // Hidden: still in the editor, marked, and gone from what a visitor would get.
  await layers(page);
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

test('sections by category, text found and typed on the page, and another look for this admin only', async ({ page, playwright }) => {
  const id = await createPage(page, 'E2E Editing');

  // Add: sections grouped by category, each with its colour chip; hovering one draws it.
  await page.locator('#hbx-addbtn').click();
  const categories = page.locator('.hbx-cat-card');
  expect(await categories.count(), 'every category is offered').toBeGreaterThan(5);
  await page.locator('.hbx-cat-card[data-cat="Call to action"]').click();
  const card = page.locator('.hbx-pal[data-type="final-cta"]');
  await card.hover();
  await expect(page.locator('#hbx-peek.is-on'), 'hovering a section shows it').toBeVisible();
  await expect(page.frameLocator('#hbx-peek-frame').locator('.hp-final-cta'), 'drawn by the theme, on its own').toHaveCount(1, { timeout: 15_000 });
  await card.click();
  await expect(page.locator('.hbx-id-name')).toHaveText('Closing call to action');
  await settled(page);

  // Clicking text on the selected section points at its setting.
  const headline = await field(page, 'Headline').locator('input').inputValue();
  await frame(page).locator('.hp-final-cta h2').click();
  await expect(page.locator('.hbx-field.is-flash'), 'the headline field is pointed at').toHaveAttribute('data-path', 'title');
  // Double-clicking it types on the page itself, and the field follows.
  await frame(page).locator('.hp-final-cta h2').dblclick();
  await page.keyboard.type('E2E typed on the page');
  await page.keyboard.press('Enter');
  await expect(field(page, 'Headline').locator('input')).toHaveValue('E2E typed on the page');
  await settled(page);
  await expect(frame(page).locator('.hp-final-cta h2'), 'and the redrawn page keeps it').toHaveText('E2E typed on the page');
  expect(headline).not.toBe('E2E typed on the page');

  // Preview with another style and navigation: drawn for this admin, saved nowhere.
  const bar = page.locator('#hbx-look');
  test.skip(await bar.isHidden(), 'this Hadrian cannot preview another look');
  const site = await page.evaluate(() => JSON.parse(document.getElementById('hbx-boot').textContent).looks.site);
  const style = await page.locator('select[data-look="style"] option').evaluateAll((o, s) => o.map(x => x.value).find(v => v !== s), site.style);
  const nav = await page.locator('select[data-look="nav"] option').evaluateAll((o, s) => o.map(x => x.value).find(v => v !== s), site.nav);
  await page.locator('select[data-look="style"]').selectOption(style);
  await page.locator('select[data-look="nav"]').selectOption(nav);
  await settled(page);
  await expect(bar, 'the bar says it is a preview').toHaveClass(/is-diff/);
  const src = await page.locator('#hbx-frame').getAttribute('src');
  expect(src, 'the preview carries a look token').toMatch(/hadrian_look=[a-f0-9]{32}/);
  await expect(frame(page).locator('body'), 'drawn with the other style').toHaveClass(new RegExp(`theme-${style}`));

  // The same address without this admin's session is nothing.
  const anon = await visitor(playwright);
  try {
    expect((await anon.get(src)).status(), 'no preview for a visitor, look or not').toBe(404);
  } finally {
    await anon.dispose();
  }
  // And this admin's own site still draws the saved look.
  const own = await page.request.get(`/hb-preview/${id}`);
  expect(await own.text(), 'without the token the saved style draws').toContain(`theme-${site.style}`);

  await page.locator('[data-look-reset]').click();
  await settled(page);
  expect(await page.locator('#hbx-frame').getAttribute('src'), 'back to the site look drops the token').not.toContain('hadrian_look=');
});

test("a page's sections can be edited as a list on its settings in Pages", async ({ page, playwright }) => {
  const id = await createPage(page, 'E2E List');
  await setAddress(page, 'e2e-list');
  await saveDraft(page);

  await page.goto(settingsOf(id));
  const card = page.locator('[data-page-extension-content] #hbc');
  await expect(card, 'the list sits at the top of the page\'s settings').toBeVisible();
  await expect(page.locator('#page-edit-form #hbc'), 'outside the settings form, so it never posts with Save changes').toHaveCount(0);
  await expect(card.locator('.hbc-empty')).toBeVisible();
  const rows = card.locator('.hbc-row');

  // Add two sections from the same categories as the visual editor.
  const addFromList = async (category, type) => {
    await card.locator('#hbc-add').click();
    await page.locator('#hbc-modal .hbx-cat-card[data-cat="' + category + '"]').click();
    await page.locator('#hbc-modal .hbx-pal[data-type="' + type + '"]').click();
    await expect(page.locator('#hbc-modal')).toBeHidden();
  };
  await addFromList('Hero', 'hero-split');
  await addFromList('Call to action', 'final-cta');
  await expect(rows).toHaveCount(2);
  await expect(card.locator('#hbc-status')).toHaveText('Unsaved changes');
  await expect(rows.nth(1), 'a new section opens to be edited').toHaveClass(/is-open/);

  // Open the first, type its headline: the row's name follows.
  await rows.nth(0).getByRole('button', { name: 'Edit Hero, split' }).click();
  await expect(rows.nth(1), 'one section open at a time').not.toHaveClass(/is-open/);
  await rows.nth(0).locator('.hbx-field[data-path="title"] input').fill('E2E edited as a list');
  await expect(rows.nth(0).locator('.hbc-sum')).toHaveText('E2E edited as a list');

  // Reorder, then save the draft and publish.
  await rows.nth(1).getByRole('button', { name: 'Move section up' }).click();
  expect(await page.evaluate(() => window.hbContent.state.doc.sections.map(s => s.type))).toEqual(['final-cta', 'hero-split']);

  // The row's switch hides a section and shows it again, without opening it.
  const shown = rows.nth(0).getByRole('checkbox', { name: /^Show .+ on the page$/ });
  await expect(shown).toBeChecked();
  await rows.nth(0).locator('.hbc-shown').click();
  await expect(rows.nth(0)).toHaveClass(/is-hidden/);
  await expect(rows.nth(0), 'the switch does not open the row').not.toHaveClass(/is-open/);
  expect(await page.evaluate(() => window.hbContent.state.doc.sections[0].hidden)).toBe(true);
  await rows.nth(0).locator('.hbc-shown').click();
  await expect(rows.nth(0).getByRole('checkbox', { name: /^Show .+ on the page$/ })).toBeChecked();

  await card.locator('#hbc-save').click();
  await expect(card.locator('#hbc-notice .mt-alert-success')).toContainText('Draft saved');
  await expect(card.locator('#hbc-status')).toHaveText('Draft');
  await page.reload();
  expect(await page.evaluate(() => window.hbContent.state.doc.sections.map(s => s.type)), 'the saved draft holds the list as left').toEqual(['final-cta', 'hero-split']);
  await expect(rows.nth(1).locator('.hbc-sum')).toHaveText('E2E edited as a list');

  await card.locator('#hbc-publish').click();
  await expect(card.locator('#hbc-notice .mt-alert-success')).toContainText('Published');
  await expect(card.locator('#hbc-status')).toHaveText('Published');
  const anon = await visitor(playwright);
  try {
    const html = await (await anon.get('/e2e-list')).text();
    expect(html, 'visitors get what was published from the list').toContain('E2E edited as a list');
    expect(html.indexOf('hp-final-cta'), 'in the order set there').toBeLessThan(html.indexOf('hp-hero-split'));
  } finally {
    await anon.dispose();
  }

  // The visual editor opens the same draft.
  await card.locator('#hbc-visual').click();
  await settled(page);
  expect(await sectionTypes(page)).toEqual(['final-cta', 'hero-split']);
  await expect(frame(page).locator('.hp-hero-split h1')).toHaveText('E2E edited as a list');
});

test('a price card shows the price WHMCS gives for the product', async ({ page }) => {
  const products = builder('products').filter(p => !p.free && p.price);
  test.skip(products.length === 0, 'the install has no priced product to show');
  const product = products[0];

  await createPage(page, 'E2E Pricing');
  await addSection(page, 'Pricing cards');
  await expect(frame(page).locator('.hb-note'), 'with no plan chosen the editor says why nothing shows').toContainText('nothing to show yet');

  await page.getByRole('button', { name: 'Add plan' }).click();
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
  const id = await createPage(page, 'E2E Replace');
  await addSection(page, 'Closing call to action');
  await field(page, 'Headline').locator('input').fill(MARK);
  await setAddress(page, 'e2e-replace');
  await publish(page);

  const anon = await visitor(playwright);
  const themePage = async () => (await anon.get('/announcements')).text();
  // What a page replaces is set on its settings in Pages; who serves the
  // website is set at the top of the Built tab.
  const panel = page.locator('[data-page-extension-panel]');
  const state = panel.locator('[data-pb-state]');
  const row = () => page.locator('[data-group-panel="Built"] [data-page-row]', { has: page.locator('.mt-pagerow-name', { hasText: 'E2E Replace' }) });
  const siteServedBy = async mode => {
    await page.goto(PAGES);
    await page.locator(`#pb-site button[value="${mode}"]`).click();
    await expect(page.locator('[data-ext-flash]')).toContainText(mode === 'builder' ? 'served by Page Builder' : 'served by the theme');
  };
  try {
    builder('mode', 'theme');
    await page.goto(PAGES);
    await expect(row().locator('[data-page-status]')).toHaveText('Published');

    // Point it at Announcements. The site is on Theme, so it only stands by.
    await page.goto(settingsOf(id));
    await expect(state, 'replaces nothing yet').toHaveCount(0);
    await panel.locator('select[name="replaces"]').selectOption('announcements');
    await expect(page.locator('[data-ext-flash]')).toContainText('now replaces Announcements');
    await expect(page, 'and stays on the page it was set on').toHaveURL(new RegExp(`page=built-${id}`));
    await expect(state).toHaveText('Standby');
    expect(await themePage(), 'site on Theme: the theme page shows').not.toContain(MARK);

    // Flip the site. Now the built page is what visitors get there.
    await siteServedBy('builder');
    await expect(row().locator('[data-page-status]')).toHaveText('Serving');
    await expect(page.locator('[data-group-panel="Support"] [data-page-row]', { has: page.locator('.mt-pagerow-name', { hasText: /^Announcements/ }) }).locator('[data-page-note]'),
      'the theme page it replaces says so on its own row').toHaveText('Replaced by E2E Replace');
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
    await page.goto(settingsOf(id));
    await expect(state).toHaveText('Serving');
    await panel.locator('select[name="replace_rule"]').selectOption('never');
    await expect(state).toHaveText('Standby');
    expect(await themePage(), 'rule Never: the theme page shows').not.toContain(MARK);

    // "Always" serves it even with the site back on Theme.
    await panel.locator('select[name="replace_rule"]').selectOption('always');
    await expect(state).toHaveText('Serving');
    await siteServedBy('theme');
    await expect(row().locator('[data-page-status]')).toHaveText('Serving');
    expect(await themePage(), 'rule Always, site on Theme: the built page shows').toContain(MARK);

    // Let go of it: the theme page is back with nothing lost.
    await page.goto(settingsOf(id));
    await panel.locator('select[name="replaces"]').selectOption('');
    await expect(page.locator('[data-ext-flash]')).toContainText('no longer replaces');
    expect(await themePage(), 'let go: the theme page shows').not.toContain(MARK);
  } finally {
    await anon.dispose();
    builder('mode', before);
  }
});

test("a built page is a row in Hadrian's Pages, and what is set there applies to it", async ({ page, playwright }) => {
  const MARK = 'E2E listed in Pages';
  const id = await createPage(page, 'E2E Listed');
  await addSection(page, 'Closing call to action');
  await field(page, 'Headline').locator('input').fill(MARK);
  await setAddress(page, 'e2e-listed');
  await saveDraft(page);

  const SETTINGS = settingsOf(id);
  const row = () => page.locator('[data-group-panel="Built"] [data-page-row]', { has: page.locator('.mt-pagerow-name', { hasText: 'E2E Listed' }) });
  const anon = await visitor(playwright);
  const saveSettings = async fill => {
    await page.goto(SETTINGS);
    await fill();
    await Promise.all([page.waitForURL(/flash=saved/), page.locator('select[name="visibility"]').evaluate(el => el.form.requestSubmit())]);
  };

  try {
    // A draft: listed, but not live and not in the sitemap.
    expect(builder('registry', String(id)), 'saving the draft gave it a row').toMatchObject({ url: 'e2e-listed', group: 'Built', published: false, inSitemap: false });
    await page.goto(PAGES);
    await expect(row().locator('[data-page-status]'), 'the list says it is a draft').toHaveText('Draft');
    await expect(row().locator('[data-page-content]'), 'and links to where its content is edited').toHaveAttribute('href', `?module=HadrianBuilder&action=edit&id=${id}`);

    // Published: live, and in the sitemap.
    await page.goto(`${MODULE}&action=edit&id=${id}`);
    await settled(page);
    await publish(page);
    expect(builder('registry', String(id)), 'publishing made it live').toMatchObject({ published: true, visibility: 'public', inSitemap: true });
    await page.goto(PAGES);
    await expect(row().locator('[data-page-status]')).toHaveText('Published');
    expect((await anon.get('/e2e-listed')).status(), 'a visitor reaches it').toBe(200);

    // Its settings screen is Hadrian's own page editor.
    await page.goto(SETTINGS);
    await expect(page.locator('[data-page-extension]'), 'which says where the content is made').toContainText('Page Builder');
    await expect(page.locator('select[name="area"] option').first(), 'a built page is part of the website').toHaveText('Automatic (Website)');

    // Visibility set in Pages is enforced on the built page.
    await saveSettings(() => page.locator('select[name="visibility"]').selectOption('auth'));
    const gated = await anon.get('/e2e-listed', { maxRedirects: 0 });
    expect(gated.status(), 'signed-out visitors are sent to sign in').toBe(302);
    expect(gated.headers().location, 'to the login page').toMatch(/login/);
    expect(builder('registry', String(id)).inSitemap, 'and the page leaves the sitemap').toBe(false);

    // Public again, with a description written in Pages.
    await saveSettings(async () => {
      await page.locator('select[name="visibility"]').selectOption('public');
      await page.locator('textarea[name^="seo_description["]').first().evaluate((el, v) => { el.value = v; }, 'E2E described in Pages');
    });
    const html = await (await anon.get('/e2e-listed')).text();
    expect(html, 'the page is back').toContain(MARK);
    expect(html, 'with the description set in Pages').toMatch(/<meta name="description" content="E2E described in Pages"/);

    // Unpublished: the row stays (so do its settings) but it is not live.
    await page.goto(`${MODULE}&action=edit&id=${id}`);
    await settled(page);
    page.once('dialog', dialog => dialog.accept());
    await page.locator('#hbx-pagebtn').click();
    await page.getByRole('button', { name: 'Take this page offline' }).click();
    await expect(page.locator('#hbx-status')).toHaveText('Draft');
    expect(builder('registry', String(id)), 'unpublishing takes it out of the sitemap').toMatchObject({ published: false, inSitemap: false });

    // Deleted from its settings: gone from the list, and its row with it.
    await deletePage(page, id);
    await expect(page, 'deleting lands back on the Built tab').toHaveURL(/action=pages&ext_ok=.*#tab=Built$/);
    await expect(row()).toHaveCount(0);
    expect(builder('registry', String(id)), 'its row went with it').toBeNull();
  } finally {
    await anon.dispose();
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

    for (const action of ['api-preview', 'api-save', 'api-content', 'api-publish', 'api-unpublish']) {
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

  for (const action of ['api-save', 'api-content', 'api-publish', 'api-unpublish', 'api-preview']) {
    const res = await page.request.post(`${MODULE}&action=${action}`, { data: { token: 'not-the-token', id, name: 'E2E Forged', slug: 'hb-e2e-forged', doc: boot.doc } });
    expect(res.status(), `${action} with a wrong token`).toBe(403);
    expect((await res.json()).ok).toBe(false);
  }
  // The form posts redirect back with an error instead of acting.
  await page.request.post(`${MODULE}&action=create`, { form: { token: 'not-the-token', name: 'E2E Forged' } });
  await page.request.post(`${MODULE}&action=delete`, { form: { token: 'not-the-token', id: String(id) } });
  expect(JSON.stringify(pages()), 'a forged write changed nothing').toBe(before);

  // With the real token, delete works and the page is gone.
  await deletePage(page, id);
  expect(pages().some(p => p.id === id)).toBe(false);
});
