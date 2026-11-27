// AD-I Branding screen (tests/FEATURES.md AD-70 to AD-73): the five image
// slots, Replace and Remove, the form fallback with JavaScript off, and the
// Brand Info text fields, each driven through Addons > Hadrian > Branding and
// proven in hadrian_settings, in the branding folder on disk and on a guest
// page (the header, the rail, the head or the footer).
//
// Functional only: every upload is an ordinary image an admin might pick.
// Guard and tamper cases (CSRF, forged fields, script-bearing SVGs) are
// admin-csrf.spec / admin-uploads.spec territory and are not repeated here.
//
// Every file uploaded here is removed again through the tile's Remove button;
// afterEach also deletes anything a failed test left in the folder, and the
// last test proves the folder lists exactly what it listed when the file began.

import fs from 'node:fs';
import path from 'node:path';
import zlib from 'node:zlib';
import crypto from 'node:crypto';
import { test, db, settings, useAuditBackup, adminUrl, submit, flashText, noErrorText } from './harness.mjs';
import { REPO_ROOT, BASE_URL, USER_AGENT } from '../../lib/env.mjs';
import { loginAdmin } from '../helpers.mjs';

useAuditBackup();

const BRAND_DIR = path.join(REPO_ROOT, 'hadrian', 'templates', 'hadrian', 'assets', 'img', 'branding');
const REL = name => `templates/hadrian/assets/img/branding/${name}`;
const listing = () => (fs.existsSync(BRAND_DIR) ? fs.readdirSync(BRAND_DIR).sort() : []);
let START = null;

// Put the folder back the way the file found it: anything not listed at the
// start goes. Only ever deletes files this run added.
function sweep() {
  if (!START) return;
  for (const f of listing()) {
    if (!START.includes(f)) fs.rmSync(path.join(BRAND_DIR, f), { force: true, recursive: true });
  }
}

test.beforeAll(() => { START = listing(); });
test.beforeEach(() => { settings.snapshot(); });
test.afterEach(() => { settings.restore(); sweep(); });

// ------------------------------------------------------------- sample files

const sha1 = buf => crypto.createHash('sha1').update(buf).digest('hex');

/** A real RGB PNG, w x h. noise=true fills it with random pixels, so it does not compress. */
function png(w, h, { noise = false, rgb = [10, 132, 255] } = {}) {
  const chunk = (type, data) => {
    const len = Buffer.alloc(4); len.writeUInt32BE(data.length);
    const td = Buffer.concat([Buffer.from(type), data]);
    const crc = Buffer.alloc(4); crc.writeUInt32BE(zlib.crc32(td) >>> 0);
    return Buffer.concat([len, td, crc]);
  };
  const ihdr = Buffer.alloc(13);
  ihdr.writeUInt32BE(w, 0); ihdr.writeUInt32BE(h, 4); ihdr[8] = 8; ihdr[9] = 2;
  const row = 1 + w * 3;
  const raw = Buffer.alloc(row * h);
  for (let y = 0; y < h; y++) {
    if (noise) crypto.randomFillSync(raw, y * row + 1, w * 3);
    else for (let x = 0; x < w; x++) raw.set(rgb, y * row + 1 + x * 3);
  }
  return Buffer.concat([Buffer.from([0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a]), chunk('IHDR', ihdr),
    chunk('IDAT', zlib.deflateSync(raw, { level: noise ? 0 : 9 })), chunk('IEND', Buffer.alloc(0))]);
}

const PNG_A = png(120, 40, { rgb: [10, 132, 255] });   // a wide logo
const PNG_B = png(120, 40, { rgb: [255, 69, 58] });    // a different one, for Replace
const PNG_SQ = png(64, 64, { rgb: [48, 209, 88] });    // a square mark
const PNG_SQ2 = png(64, 64, { rgb: [255, 214, 10] });  // the other square variant
const PNG_ICON = png(32, 32, { rgb: [94, 92, 230] });  // a favicon
const BIG = png(320, 320, { noise: true });            // ~300 KB: over the favicon cap, under the logo caps
const SVG_OK = Buffer.from('<svg xmlns="http://www.w3.org/2000/svg" width="120" height="40"><rect width="120" height="40" fill="#0a84ff"/></svg>');
const GIF = Buffer.from('R0lGODlhAQABAIAAAAAAAP///yH5BAEAAAAALAAAAAABAAEAAAIBRAA7', 'base64');

const SLOTS = {
  logo_light:        'Logo (light backgrounds)',
  logo_dark:         'Logo (dark backgrounds)',
  logo_square_light: 'Square logo (light)',
  logo_square_dark:  'Square logo (dark)',
  favicon:           'Favicon',
};
const ALL_SLOTS_EMPTY = Object.fromEntries(Object.keys(SLOTS).map(k => [k, ['', 'string']]));

// The layouts a guest sees, fixed so every effect has one known place to show.
const layout = mainMenu => ({
  hadrian_layout_mode: ['audience', 'string'],
  'hadrian_active_layout_main-menu_guest': [mainMenu, 'string'],
  hadrian_active_layout_footer_guest: ['extended-info', 'string'],
  hide_footer_socials: ['0', 'bool'],
});

// Where each slot shows on the guest homepage. at(n) matches the stored name
// n, or any branding file when n is null.
const at = n => (n ? `$="/branding/${n}"` : '*="/branding/"');
const WHERE = {
  logo_light: {
    menu: 'top', file: PNG_A, says: 'the top navigation logo is the new file',
    sel: n => `.nav-logo img[src${at(n)}]`,
  },
  logo_dark: {
    menu: 'top', file: PNG_B, says: 'the footer\'s dark-mode logo is the new file',
    sel: n => `footer img.hp-footer-brand-logo.is-dark[src${at(n)}]`,
  },
  logo_square_light: {
    menu: 'rail', file: PNG_SQ, says: 'the rail logo is the new file',
    sel: n => `.ph-rail-logo img[src${at(n)}]`,
  },
  logo_square_dark: {
    menu: 'rail', file: PNG_SQ2, pair: ['logo_square_light', PNG_SQ],
    says: 'the rail logo swaps to the new file in dark mode (data-logo-dark)',
    sel: n => `.ph-rail-logo img[data-logo-dark${at(n)}]`,
  },
  favicon: {
    menu: 'top', file: PNG_ICON, says: 'the head carries <link rel="icon"> to the new file',
    sel: n => `head link[rel="icon"][href${at(n)}]`,
  },
};

// ------------------------------------------------------------------ helpers

const ajax = (page, sub) => page.waitForResponse(r => r.url().includes(`sub=${sub}`) && r.request().method() === 'POST');
const tileOf = (page, field) => page.locator(`.mt-branding-tile[data-field="${field}"]`);
const hex32 = /^[0-9a-f]{32}\.(png|jpg|webp|svg|ico)$/;

/** Pick a file on a tile the way an admin does; returns the JSON reply and its status. */
async function pick(page, field, name, buffer, mimeType = 'image/png') {
  const answered = ajax(page, 'upload-ajax');
  await page.locator(`#upload-${field}`).setInputFiles({ name, mimeType, buffer });
  const res = await answered;
  const body = await res.json().catch(() => null);
  if (body?.ok) await tileOf(page, field).locator('img').waitFor();
  else await tileOf(page, field).locator('.mt-upload-error').waitFor().catch(() => {});
  return { status: res.status(), body };
}

/** Press Remove on a filled tile and accept the browser's confirm. */
async function remove(page, field) {
  const removed = ajax(page, 'remove-ajax');
  page.once('dialog', d => d.accept());
  await tileOf(page, field).locator(`[data-remove="${field}"]`).click({ force: true });
  const res = await removed;
  const body = await res.json().catch(() => null);
  await tileOf(page, field).locator('.mt-upload').waitFor();
  return { status: res.status(), body };
}

/** How many elements on the guest homepage match a selector. */
async function guestCount(visit, sel) {
  const g = await visit('guest');
  await g.goto('/index.php');
  return { g, n: await g.locator(sel).count() };
}

// ------------------------------------------------------------------- AD-70

for (const [field, label] of Object.entries(SLOTS)) {
  test(`AD-70 Upload to "${label}" (${field}): stored, on disk, used by the client area, then removed`, async ({ admin, visit, proof }) => {
    const w = WHERE[field];
    proof.claim(`A PNG picked on the "${label}" tile is saved under a random name, stored in hadrian_settings.${field}, and the guest page uses it: ${w.says}.`);
    settings.set({ ...ALL_SLOTS_EMPTY, ...layout(w.menu) });
    const filesBefore = listing();

    await admin.goto(adminUrl('branding'));
    await noErrorText(admin, proof, 'Branding screen');
    proof.check('the tile starts empty', (await tileOf(admin, field).locator('img').count()) === 0);

    let pairName = '';
    if (w.pair) {
      const [pf, pbuf] = w.pair;
      proof.step(`Set up: pick a PNG on "${SLOTS[pf]}" first, so the two square variants differ`);
      const p = await pick(admin, pf, `audit-${pf}.png`, pbuf);
      proof.check(`the ${pf} upload was accepted`, p.body?.ok === true, p.body);
      pairName = p.body.filename;
    }

    const before = db.setting(field);
    const { n: n0 } = await guestCount(visit, w.sel(null));
    proof.equal('before: the guest page shows no uploaded file in that place', n0, 0);

    proof.step(`Pick audit-${field}.png on the "${label}" tile`);
    const up = await pick(admin, field, `audit-${field}.png`, w.file);
    proof.equal('the upload answers 200 with ok: true', [up.status, up.body?.ok], [200, true]);
    const name = up.body.filename;
    proof.check('the stored name is random hex, not the uploaded name', hex32.test(name), name);
    proof.check('the screen says it was saved', /Saved "/.test(await admin.locator('#mt-branding-status').innerText()));
    await proof.shot(tileOf(admin, field), 'tile after the upload');

    const after = db.setting(field);
    proof.value(field, before, after);
    proof.equal(`hadrian_settings.${field} holds the new file name`, after, name);
    const onDisk = db.file(REL(name));
    proof.check('the file is in the branding folder, byte for byte what was picked', onDisk.exists && onDisk.sha1 === sha1(w.file), onDisk);
    proof.equal('exactly the new file(s) were added to the folder', listing().filter(f => !filesBefore.includes(f)).sort(), [name, pairName].filter(Boolean).sort());

    await admin.reload();
    proof.equal('the tile still shows the image after a reload', await tileOf(admin, field).locator(`img[src$="/branding/${name}"]`).count(), 1);

    const { g, n } = await guestCount(visit, w.sel(name));
    proof.equal(`on the guest homepage, ${w.says}`, n, 1);
    await proof.shot(g, 'guest page using the new file');

    proof.step('Press Remove on the tile (and on the paired tile) to clean up');
    const rm = await remove(admin, field);
    proof.equal('Remove answers ok', rm.body?.ok, true);
    proof.equal('the file is gone again', db.file(REL(name)).exists, false);
    if (w.pair) await remove(admin, w.pair[0]);
    proof.equal('the folder is back to how this test found it', listing(), filesBefore);
  });
}

test('AD-70 Replacing a slot stores the new file and deletes the old one', async ({ admin, visit, proof }) => {
  proof.claim('A second upload to a filled slot points the setting at the new file and deletes the previous file from disk once the new one has landed.');
  settings.set({ ...ALL_SLOTS_EMPTY, ...layout('top') });
  const filesBefore = listing();
  await admin.goto(adminUrl('branding'));

  proof.step('Pick a first PNG on "Logo (light backgrounds)"');
  const first = await pick(admin, 'logo_light', 'first.png', PNG_A);
  const a = first.body.filename;
  proof.check('the first file is stored and on disk', db.setting('logo_light') === a && db.file(REL(a)).exists, a);

  proof.step('Press Replace on the filled tile and pick a second, different PNG');
  proof.equal('the filled tile offers Replace', await tileOf(admin, 'logo_light').locator('label', { hasText: 'Replace' }).count(), 1);
  const second = await pick(admin, 'logo_light', 'second.png', PNG_B);
  const b = second.body?.filename;
  proof.check('the second upload was accepted under a new name', second.body?.ok === true && b !== a, second.body);
  proof.value('logo_light', a, db.setting('logo_light'));
  proof.equal('the setting now names the second file', db.setting('logo_light'), b);
  proof.equal('the second file is on disk', db.file(REL(b)).exists, true);
  proof.equal('the first file is gone from disk', db.file(REL(a)).exists, false);
  proof.equal('the folder holds only the second file beyond its start state', listing().filter(f => !filesBefore.includes(f)), [b]);
  await proof.shot(tileOf(admin, 'logo_light'), 'tile after the replace');

  const g = await visit('guest');
  await g.goto('/index.php');
  proof.equal('the guest header logo is the second file', await g.locator(`.nav-logo img[src$="/branding/${b}"]`).count(), 1);
  proof.equal('and nothing points at the first any more', await g.locator(`[src*="${a}"], [href*="${a}"], [data-logo-dark*="${a}"]`).count(), 0);

  await remove(admin, 'logo_light');
  proof.equal('cleanup: the folder is back to its start', listing(), filesBefore);
});

test('AD-70 Each slot has its own size cap: a 300 KB PNG is too big for the favicon but fine as a square logo', async ({ admin, proof }) => {
  proof.claim('The favicon takes at most 256 KB and the square logos 1 MB: the same 300 KB image is refused on the favicon tile, with the reason shown on the tile, and accepted on a square-logo tile.');
  settings.set(ALL_SLOTS_EMPTY);
  const filesBefore = listing();
  await admin.goto(adminUrl('branding'));

  proof.step(`Pick big.png (${BIG.length} bytes, 320 x 320) on the Favicon tile`);
  const fav = await pick(admin, 'favicon', 'big.png', BIG);
  proof.equal('the favicon upload answers 422 with ok: false', [fav.status, fav.body?.ok], [422, false]);
  proof.check('the reason gives the 256 KB limit', /too large.*Limit is 256 KB/i.test(fav.body?.error || ''), fav.body?.error);
  const shown = await tileOf(admin, 'favicon').locator('.mt-upload-error').innerText().catch(() => '');
  proof.check('the favicon tile shows the reason', /Limit is 256 KB/.test(shown), shown);
  await proof.shot(tileOf(admin, 'favicon'), 'favicon tile refusing the file');
  proof.equal('the favicon setting is still empty', db.setting('favicon'), '');
  proof.equal('nothing was added to the folder', listing(), filesBefore);

  proof.step('Pick the same file on the "Square logo (light)" tile');
  const sq = await pick(admin, 'logo_square_light', 'big.png', BIG);
  proof.equal('the square logo takes it: 200 with ok: true', [sq.status, sq.body?.ok], [200, true]);
  proof.equal('and stores it', db.setting('logo_square_light'), sq.body.filename);
  await remove(admin, 'logo_square_light');
  proof.equal('cleanup: the folder is back to its start', listing(), filesBefore);
});

test('AD-70 A logo slot takes an SVG and refuses a GIF', async ({ admin, proof }) => {
  proof.claim('The logo slots accept PNG, JPG, WebP and SVG: a plain SVG is stored as .svg, and a GIF is refused with "Unsupported file type (image/gif)".');
  settings.set(ALL_SLOTS_EMPTY);
  const filesBefore = listing();
  await admin.goto(adminUrl('branding'));

  proof.step('Pick mark.svg on "Logo (dark backgrounds)"');
  const svg = await pick(admin, 'logo_dark', 'mark.svg', SVG_OK, 'image/svg+xml');
  proof.equal('the SVG answers 200 with ok: true', [svg.status, svg.body?.ok], [200, true]);
  proof.check('it is stored with an .svg extension', /^[0-9a-f]{32}\.svg$/.test(svg.body.filename), svg.body.filename);
  proof.equal('hadrian_settings.logo_dark names it', db.setting('logo_dark'), svg.body.filename);

  proof.step('Pick anim.gif on "Logo (light backgrounds)"');
  const gif = await pick(admin, 'logo_light', 'anim.gif', GIF, 'image/gif');
  proof.equal('the GIF answers 422 with ok: false', [gif.status, gif.body?.ok], [422, false]);
  proof.check('the reason names the type', /Unsupported file type \(image\/gif\)/.test(gif.body?.error || ''), gif.body?.error);
  await proof.shot(admin.locator('.mt-upload-pair').first(), 'full logo tiles after the SVG and the GIF');
  proof.equal('the light logo setting stayed empty', db.setting('logo_light'), '');

  await remove(admin, 'logo_dark');
  proof.equal('cleanup: the folder is back to its start', listing(), filesBefore);
});

// ------------------------------------------------------------------- AD-71

test('AD-71 Remove deletes the file, clears the setting, and the client area stops using it', async ({ admin, visit, proof }) => {
  proof.claim('Remove on a filled tile deletes the file from the branding folder and stores an empty value; the guest page no longer points at it.');
  settings.set({ ...ALL_SLOTS_EMPTY, ...layout('top') });
  const filesBefore = listing();
  await admin.goto(adminUrl('branding'));
  const up = await pick(admin, 'favicon', 'icon.png', PNG_ICON);
  const name = up.body.filename;
  proof.check('set up: a favicon is stored and on disk', db.setting('favicon') === name && db.file(REL(name)).exists, name);
  const { n: n0 } = await guestCount(visit, `link[rel="icon"][href$="/branding/${name}"]`);
  proof.equal('set up: the guest head links to it', n0, 1);

  proof.step('Press Remove on the Favicon tile and accept "Remove the Favicon file?"');
  let asked = '';
  admin.once('dialog', d => { asked = d.message(); });
  const rm = await remove(admin, 'favicon');
  proof.equal('remove-ajax answers 200 with ok: true', [rm.status, rm.body?.ok], [200, true]);
  proof.check('the screen asked "Remove the Favicon file?" first', /Remove the Favicon file\?/.test(asked), asked);
  await proof.shot(tileOf(admin, 'favicon'), 'tile after Remove');

  const after = db.setting('favicon');
  proof.value('favicon', name, after);
  proof.equal('the setting is now empty', after, '');
  proof.equal('the file is gone from disk', db.file(REL(name)).exists, false);
  proof.equal('the folder is back to how this test found it', listing(), filesBefore);
  const { g, n } = await guestCount(visit, `[href*="${name}"], [src*="${name}"]`);
  proof.equal('the guest page no longer points at it', n, 0);
  proof.equal('and the head carries no favicon link', await g.locator('head link[rel="icon"]').count(), 0);
  await admin.reload();
  proof.equal('the tile is empty after a reload', await tileOf(admin, 'favicon').locator('img').count(), 0);
});

// ------------------------------------------------------------------- AD-72

/** A page with JavaScript off, signed in as the admin: the form fallback path. */
async function noJsAdmin(browser) {
  const ctx = await browser.newContext({ baseURL: BASE_URL, userAgent: USER_AGENT, javaScriptEnabled: false, viewport: { width: 1280, height: 900 } });
  await loginAdmin(ctx.request);
  return { ctx, page: await ctx.newPage() };
}
const SAVE = '.mt-savebar button[type="submit"]';

/** Remove whatever the no-JS posts stored, through the normal (JS) screen. */
async function removeFilled(admin) {
  await admin.goto(adminUrl('branding'));
  for (const field of Object.keys(SLOTS)) {
    if ((await tileOf(admin, field).locator('img').count()) > 0) await remove(admin, field);
  }
}

test('AD-72 Form fallback: two files in one post both save, and the screen says "Saved."', async ({ admin, browser, proof }) => {
  proof.claim('With JavaScript off, files picked on several tiles go up in one form post when Save is pressed; each lands, and the screen says "Saved."');
  settings.set(ALL_SLOTS_EMPTY);
  const filesBefore = listing();
  const { ctx, page } = await noJsAdmin(browser);
  try {
    await page.goto(adminUrl('branding'));
    proof.step('With JavaScript off, pick a PNG on the light logo and one on the favicon, then press "Save brand info"');
    await page.locator('#upload-logo_light').setInputFiles({ name: 'a.png', mimeType: 'image/png', buffer: PNG_A });
    await page.locator('#upload-favicon').setInputFiles({ name: 'b.png', mimeType: 'image/png', buffer: PNG_ICON });
    await submit(page, SAVE);
    const flash = await flashText(page);
    await proof.shot(page, 'Branding after the form post');
    proof.check('the screen says "Saved."', /Saved\./.test(flash), flash);
    const light = db.setting('logo_light');
    const fav = db.setting('favicon');
    proof.value('logo_light, favicon', ['', ''], [light, fav]);
    proof.check('both slots now hold random file names', hex32.test(light || '') && hex32.test(fav || ''), { light, fav });
    proof.check('both files are on disk', db.file(REL(light)).exists && db.file(REL(fav)).exists);
    proof.equal('both tiles show their image', await page.locator('.mt-branding-tile img').count(), 2);
  } finally { await ctx.close(); }
  await removeFilled(admin);
  proof.equal('cleanup: the folder is back to its start', listing(), filesBefore);
});

test('AD-72 Form fallback: one file that fits and one that does not say "Partially saved"', async ({ admin, browser, proof }) => {
  proof.claim('A form post where one file is accepted and one is refused saves the good one, leaves the other slot as it was, says "Partially saved." and shows the reason under the refused tile.');
  settings.set(ALL_SLOTS_EMPTY);
  const filesBefore = listing();
  const { ctx, page } = await noJsAdmin(browser);
  try {
    await page.goto(adminUrl('branding'));
    proof.step('Pick a PNG on the dark logo and a 300 KB PNG on the favicon (cap 256 KB), press Save');
    await page.locator('#upload-logo_dark').setInputFiles({ name: 'ok.png', mimeType: 'image/png', buffer: PNG_B });
    await page.locator('#upload-favicon').setInputFiles({ name: 'big.png', mimeType: 'image/png', buffer: BIG });
    await submit(page, SAVE);
    const flash = await flashText(page);
    await proof.shot(page, 'Branding after the mixed post');
    proof.check('the screen says "Partially saved."', /Partially saved/.test(flash), flash);
    proof.check('the dark logo was stored', hex32.test(db.setting('logo_dark') || ''), db.setting('logo_dark'));
    proof.equal('the favicon slot is still empty', db.setting('favicon'), '');
    const err = await tileOf(page, 'favicon').locator('.mt-upload-error').innerText().catch(() => '');
    proof.check('the favicon tile says why', /too large.*256 KB/i.test(err), err);
  } finally { await ctx.close(); }
  await removeFilled(admin);
  proof.equal('cleanup: the folder is back to its start', listing(), filesBefore);
});

test('AD-72 Form fallback: a post whose only file is refused says "Nothing saved"', async ({ browser, proof }) => {
  proof.claim('A form post whose every file is refused stores nothing and says "Nothing saved."');
  settings.set(ALL_SLOTS_EMPTY);
  const filesBefore = listing();
  const { ctx, page } = await noJsAdmin(browser);
  try {
    await page.goto(adminUrl('branding'));
    proof.step('Pick a 300 KB PNG on the favicon (cap 256 KB), press Save');
    await page.locator('#upload-favicon').setInputFiles({ name: 'big.png', mimeType: 'image/png', buffer: BIG });
    await submit(page, SAVE);
    const flash = await flashText(page);
    await proof.shot(page, 'Branding after the refused post');
    proof.check('the screen says "Nothing saved."', /Nothing saved/.test(flash), flash);
    proof.equal('the favicon is still empty', db.setting('favicon'), '');
    proof.equal('the folder is unchanged', listing(), filesBefore);
  } finally { await ctx.close(); }
});

test('AD-72 Form fallback: a post with nothing new writes nothing and shows no banner', async ({ browser, proof }) => {
  proof.claim('Saving with no file picked and the text fields unchanged writes nothing (flash "noop") and shows no banner.');
  settings.set(ALL_SLOTS_EMPTY);
  const before = db.hash();
  const { ctx, page } = await noJsAdmin(browser);
  try {
    await page.goto(adminUrl('branding'));
    proof.step('Press Save with nothing picked and nothing typed');
    await submit(page, SAVE);
    const alerts = await page.locator('.mt-alert-success, .mt-alert-warning, .mt-alert-danger').count();
    await proof.shot(page, 'Branding after the empty post');
    proof.equal('no Saved / Partially saved / Nothing saved banner is shown', alerts, 0);
    proof.equal('no Hadrian table changed (db.hash)', db.hash(), before);
  } finally { await ctx.close(); }
});

// ------------------------------------------------------------------- AD-73

const BRAND_SAVE = '.mt-savebar button[type="submit"]';
const TEXT_KEYS = ['footer_description', 'footer_social_x', 'footer_social_linkedin', 'footer_social_facebook', 'footer_social_github', 'footer_social_youtube', 'footer_social_instagram'];
const NO_BRAND_INFO = Object.fromEntries(TEXT_KEYS.map(k => [k, ['', 'string']]));

test('AD-73 Brand Info: the description and social links reach the footer, and a blank field clears', async ({ admin, visit, proof }) => {
  proof.claim('The footer description and social URLs typed on Branding are stored on "Save brand info" and drawn in the "Extended Footer + Info" footer; emptying a field clears the setting and the link leaves the footer.');
  settings.set({ ...NO_BRAND_INFO, ...layout('top') });
  const g = await visit('guest');
  await g.goto('/index.php');
  proof.equal('set up: the guest footer is the Info layout (it has the tagline)', await g.locator('.hp-footer-tagline').count(), 1);
  const defaultTagline = (await g.locator('.hp-footer-tagline').innerText()).trim();
  proof.equal('before: the footer has no social links', await g.locator('a.hp-footer-social').count(), 0);

  const desc = 'Audit hosting on fast hardware and honest prices.';
  await admin.goto(adminUrl('branding'));
  proof.step('Type a description, an X URL and a GitHub URL, press "Save brand info"');
  await admin.locator('#bi-footer_description').fill(desc);
  await admin.locator('#bi-footer_social_x').fill('https://x.com/hadrian-audit');
  await admin.locator('#bi-footer_social_github').fill('https://github.com/hadrian-audit');
  await submit(admin, BRAND_SAVE);
  const flash = await flashText(admin);
  await proof.shot(admin, 'Branding after Save brand info');
  proof.check('the screen says "Saved."', /Saved\./.test(flash), flash);

  const stored = { d: db.setting('footer_description'), x: db.setting('footer_social_x'), gh: db.setting('footer_social_github') };
  proof.value('footer_description, footer_social_x, footer_social_github', { d: '', x: '', gh: '' }, stored);
  proof.equal('all three are stored as typed', stored, { d: desc, x: 'https://x.com/hadrian-audit', gh: 'https://github.com/hadrian-audit' });
  proof.equal('the fields show the saved values after the reload', await admin.locator('#bi-footer_social_x').inputValue(), 'https://x.com/hadrian-audit');

  await g.goto('/index.php');
  proof.equal('the footer tagline is the description', (await g.locator('.hp-footer-tagline').innerText()).trim(), desc);
  proof.equal('the footer links to the X URL', await g.locator('a.hp-footer-social[href="https://x.com/hadrian-audit"]').count(), 1);
  proof.equal('the footer links to the GitHub URL', await g.locator('a.hp-footer-social[href="https://github.com/hadrian-audit"]').count(), 1);
  await proof.shot(g.locator('footer').last(), 'guest footer with the brand info');

  proof.step('Empty the X field and the description, press "Save brand info"');
  await admin.locator('#bi-footer_social_x').fill('');
  await admin.locator('#bi-footer_description').fill('');
  await submit(admin, BRAND_SAVE);
  const cleared = { d: db.setting('footer_description'), x: db.setting('footer_social_x') };
  proof.value('footer_description, footer_social_x (emptied)', { d: desc, x: 'https://x.com/hadrian-audit' }, cleared);
  proof.equal('a blank field clears the setting', cleared, { d: '', x: '' });
  proof.equal('GitHub kept its value', db.setting('footer_social_github'), 'https://github.com/hadrian-audit');
  await g.goto('/index.php');
  proof.equal('the X link left the footer', await g.locator('a.hp-footer-social[href="https://x.com/hadrian-audit"]').count(), 0);
  proof.equal('the GitHub link stayed', await g.locator('a.hp-footer-social[href="https://github.com/hadrian-audit"]').count(), 1);
  proof.equal('the tagline is back to the theme default', (await g.locator('.hp-footer-tagline').innerText()).trim(), defaultTagline);
});

test('AD-73 Brand Info refuses a social link that is not http(s) and keeps the stored one', async ({ admin, proof }) => {
  proof.claim('A social link that is not an http(s) URL is refused with "Must be a valid http(s) URL." shown under the field, and the value already stored is kept.');
  settings.set({ ...NO_BRAND_INFO, footer_social_linkedin: ['https://linkedin.com/company/keep', 'string'] });
  await admin.goto(adminUrl('branding'));
  proof.step('Type ftp://files.example.com/brand in LinkedIn, press "Save brand info"');
  await admin.locator('#bi-footer_social_linkedin').fill('ftp://files.example.com/brand');
  await submit(admin, BRAND_SAVE);
  const flash = await flashText(admin);
  await proof.shot(admin, 'Branding after the refused link');
  proof.check('the screen says nothing was saved', /Nothing saved/.test(flash), flash);
  const err = await admin.locator('#bi-footer_social_linkedin ~ .mt-upload-error').innerText().catch(() => '');
  proof.equal('LinkedIn shows "Must be a valid http(s) URL."', err.trim(), 'Must be a valid http(s) URL.');
  proof.value('footer_social_linkedin', 'https://linkedin.com/company/keep', db.setting('footer_social_linkedin'));
  proof.equal('the stored LinkedIn link is kept', db.setting('footer_social_linkedin'), 'https://linkedin.com/company/keep');
});

test('AD-73 Brand Info caps the description at 280 characters', async ({ admin, visit, proof }) => {
  proof.claim('The description field stops at 280 characters; a longer one posted anyway is refused with "Too long (max 280 characters)." and exactly 280 is stored whole and shown in the footer.');
  settings.set({ ...NO_BRAND_INFO, ...layout('top'), footer_description: ['Before the cap test.', 'string'] });
  await admin.goto(adminUrl('branding'));
  const box = admin.locator('#bi-footer_description');
  proof.equal('the textarea carries maxlength="280"', await box.getAttribute('maxlength'), '280');
  const long = ('Hadrian audit tagline ').repeat(20).slice(0, 281);
  proof.step('Type 281 characters into the description');
  await box.fill(long);
  proof.equal('the field itself keeps only 280', (await box.inputValue()).length, 280);

  proof.step('Lift the textarea maxlength, type 281 characters again, press "Save brand info"');
  await box.evaluate(el => el.removeAttribute('maxlength'));
  await box.fill(long);
  await submit(admin, BRAND_SAVE);
  const err = await admin.locator('#bi-footer_description ~ .mt-upload-error').innerText().catch(() => '');
  await proof.shot(admin, 'Branding after 281 characters');
  proof.equal('the field says "Too long (max 280 characters)."', err.trim(), 'Too long (max 280 characters).');
  proof.value('footer_description (281 posted)', 'Before the cap test.', db.setting('footer_description'));
  proof.equal('the stored description is unchanged', db.setting('footer_description'), 'Before the cap test.');

  proof.step('Type exactly 280 characters, press "Save brand info"');
  const exact = long.slice(0, 279) + 'x';
  await admin.locator('#bi-footer_description').fill(exact);
  await submit(admin, BRAND_SAVE);
  proof.equal('280 characters are stored whole', db.setting('footer_description'), exact);
  const g = await visit('guest');
  await g.goto('/index.php');
  proof.equal('the footer shows all 280', (await g.locator('.hp-footer-tagline').innerText()).trim(), exact.trim());
});

// ------------------------------------------------------------------ cleanup

test('AD-70 Every upload is gone: the branding folder matches its start', async ({ proof }) => {
  proof.claim('After all the uploads above, the branding folder lists exactly the files it listed when this file began.');
  proof.equal('the folder listing equals the starting listing', listing(), START);
  proof.note(`start listing: ${JSON.stringify(START)}`);
});
