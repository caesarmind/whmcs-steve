// Tier 3c (settings) - every Hadrian admin write needs the WHMCS admin token.
//
// WHMCS does not check it for an addon (measured on 9.0.8: a signed-in
// admin's POST with no token reaches the addon and is acted on). Without the
// check, any website an admin visits while signed in could change Hadrian's
// settings through their browser; Styles -> Custom CSS writes into every
// client page. Security review 2026-10, finding Cand-A.
//
// Two halves:
//   - each write, sent WITHOUT the token or with a wrong one, is refused and
//     changes nothing (a fingerprint of every table the admin writes)
//   - the same screens, used normally in a browser, still save
//
// In the settings project (one worker, its own run.mjs step): the second half
// really saves. hadrian_settings is snapshot and restored around every test.

import { test, expect } from '@playwright/test';
import { execFileSync } from 'node:child_process';
import path from 'node:path';
import { PHP, TESTS_DIR } from '../lib/env.mjs';
import { loginAdmin } from './helpers.mjs';

const H = '/admin/addonmodules.php?module=Hadrian';
const php = (script, ...args) => execFileSync(PHP, [path.join(TESTS_DIR, 'php', script), ...args], { encoding: 'utf8' }).trim();
const fingerprint = () => JSON.parse(php('admin-state.php', 'hash'));
const setting = key => JSON.parse(php('admin-state.php', 'get', key));

test.beforeAll(() => { php('settings.php', 'snapshot'); });
test.beforeEach(async ({ page }) => { await loginAdmin(page.context().request); });
test.afterEach(() => { php('settings.php', 'restore'); php('settings.php', 'snapshot'); });
test.afterAll(() => { php('settings.php', 'restore'); });

// Each of these WOULD change something if it were accepted (or, where marked,
// is harmless either way and only the refusal is being proved). The routes
// that cannot be replayed safely even once -- reset-defaults, seed&force=1 --
// share this code path and are pinned by the GET_WRITES test below.
const POSTS = [
  ['settings',                         { hide_breadcrumb: '1' }],
  ['editStyle&style=default&tab=custom-css', { mt_custom_css_save: '1', style: 'default', custom_css: 'body{outline:9px solid red}' }],
  ['layouts',                          { content_width: 'wide' }],
  ['sitemap&sub=save',                 { frequency: 'daily' }],
  ['menu&sub=create',                  { location: 'main' }],
  ['menu&sub=save',                    { id: '0' }],                    // harmless: no such menu
  ['pages&sub=save',                   { page: 'no-such-page' }],        // harmless: unknown page
  ['branding&sub=remove',              { field: 'logo_light' }],
  ['branding',                         {}],                              // harmless: no files
  ['styles',                           {}],                              // harmless: no style named
  ['tools',                            { tool: 'clear_template_cache' }], // harmless: a cache
  ['license',                          {}],                              // harmless: no key sent
  ['setup',                            { setup_do: 'license', license_key: 'forged-key' }],
  ['setup',                            { setup_do: 'install' }],        // harmless: adds only what is missing
  ['setup',                            { setup_do: 'golive' }],
  ['setup',                            { setup_do: 'switchback' }],
];
const GETS = [
  'menu&sub=seed',
  'menu&sub=create&tab=main',
  'menu&sub=delete&id=999999&confirm=1',                               // harmless: no such menu
  'sitemap&sub=generate',
];

test('every write is refused without the token, and changes nothing', async ({ page }) => {
  await page.goto(`${H}&action=settings`);
  const before = fingerprint();

  for (const [route, form] of POSTS) {
    for (const token of [undefined, 'not-the-token']) {
      const res = await page.request.post(`${H}&action=${route}`, { form: token ? { ...form, token } : form, maxRedirects: 0 });
      expect.soft(res.status(), `POST ${route} ${token ? 'with a wrong token' : 'with no token'}`).toBe(403);
      expect.soft(await res.text(), `POST ${route}: the admin is told nothing was saved`).toContain('Nothing was changed');
    }
  }
  for (const route of GETS) {
    for (const suffix of ['', '&token=not-the-token']) {
      const res = await page.request.get(`${H}&action=${route}${suffix}`, { maxRedirects: 0 });
      expect.soft(res.status(), `GET ${route} ${suffix ? 'with a wrong token' : 'with no token'}`).toBe(403);
    }
  }
  // The JSON endpoints answer in JSON.
  const json = await page.request.post(`${H}&action=media&sub=list`, {
    form: { collection: 'library' }, headers: { 'X-Requested-With': 'XMLHttpRequest' }, maxRedirects: 0,
  });
  expect.soft(json.status()).toBe(403);
  expect.soft((await json.json()).ok).toBe(false);

  expect(fingerprint(), 'not one row of settings, pages, menus or the licence changed').toEqual(before);
});

test('the routes that change state with a GET are exactly the ones that ask for a token', () => {
  // Pins the list in AdminCsrf::GET_WRITES against the links in the views.
  // A new state-changing link must carry &token= AND be listed, or it is
  // either broken (listed, no token) or open (token, not listed).
  const out = execFileSync(PHP, ['-r', `
    require ${JSON.stringify(path.join(TESTS_DIR, '..', 'hadrian', 'modules', 'addons', 'Hadrian', 'src', 'Helpers', 'AdminCsrf.php'))};
    echo json_encode(Hadrian\\Helpers\\AdminCsrf::GET_WRITES);
  `], { encoding: 'utf8' });
  expect(JSON.parse(out)).toEqual({
    menu: ['seed', 'reset-defaults', 'create', 'delete'],
    sitemap: ['generate'],
  });
});

test('the screens still save when used normally', async ({ page }) => {
  test.setTimeout(120_000);
  const ok = async url => {
    await expect(page.locator('.mt-page-title').first(), `${url}: not refused`).not.toHaveText('Not saved');
  };

  // Settings: the whole form, saved as it is.
  await page.goto(`${H}&action=settings`);
  await page.locator('.mt-savebar button[type="submit"]').click();
  await page.waitForLoadState('load');
  await ok('settings');

  // Custom CSS: the worst case if forged, so prove a real save lands.
  await page.goto(`${H}&action=editStyle&style=default&tab=custom-css`);
  const marker = `/* admin-csrf.spec ${Date.now()} */`;
  await page.locator('textarea[name="custom_css"]').fill(marker);
  await page.locator('.mt-custom-css .mt-savebar button[type="submit"]').click();
  await page.waitForLoadState('load');
  await ok('custom css');
  expect(setting('hadrian_custom_css'), 'the CSS was stored').toBe(marker);

  // Layouts: one segmented option, which submits its own little form.
  await page.goto(`${H}&action=layouts`);
  const seg = page.locator('form.mt-seg').first();
  if (await seg.count()) {
    await seg.locator('button[type="submit"]:not(.on)').first().click();
    await page.waitForLoadState('load');
    await ok('layouts');
  }

  // Sitemap: save (which also regenerates), then the Generate link.
  await page.goto(`${H}&action=sitemap`);
  await page.locator('#sitemap-form .mt-savebar button[type="submit"]').click();
  await page.waitForLoadState('load');
  await ok('sitemap save');
  await page.locator('a', { hasText: 'Generate now' }).click();
  await page.waitForLoadState('load');
  await ok('sitemap generate');

  // Setup: "Run now" is only drawn while the database is behind, so send what
  // the button sends, with the token WHMCS put in the page's own form. It adds
  // only what is missing, so it is safe on an install that is up to date.
  await page.goto(`${H}&action=setup`);
  const setupToken = await page.locator('#mt-setup-license input[name="token"]').inputValue();
  const ran = await page.request.post(`${H}&action=setup`, { form: { setup_do: 'install', token: setupToken }, maxRedirects: 0 });
  expect(ran.status(), 'setup install: accepted, then redirected').toBe(302);
  expect(ran.headers()['location'] || '', 'setup install: confirmed').toContain('done=installed');
  await page.goto(`${H}&action=setup&done=installed`);
  await expect(page.locator('.mt-alert-success')).toContainText('up to date');

  // Tools.
  await page.goto(`${H}&action=tools`);
  await page.locator('button[name="tool"][value="clear_template_cache"]').click();
  await expect(page.locator('.mt-alert-success')).toContainText('Cleared');

  // Menus: a link (GET with token), a form (POST), and delete by its link shape.
  await page.goto(`${H}&action=menu`);
  await page.locator('a', { hasText: 'Re-seed presets' }).first().click();
  await expect(page).toHaveURL(/flash=seeded-/);
  await page.locator('button', { hasText: '+ New menu' }).click();
  await expect(page).toHaveURL(/sub=edit&id=\d+&flash=created/);
  const id = page.url().match(/id=(\d+)/)[1];
  // No delete link exists in the UI; build one the way the seed links are
  // built, with the page's own token (the one WHMCS put in the editor form).
  const token = await page.locator('form#menuForm input[name="token"]').inputValue();
  await page.goto(`${H}&action=menu&sub=delete&id=${id}&confirm=1&token=${encodeURIComponent(token)}`);
  await ok('menu delete');
  await page.goto(`${H}&action=menu`);
  await expect(page.locator(`a[href*="sub=edit&id=${id}"]`), 'the new menu was deleted').toHaveCount(0);
});
