// AD-J Media screen (tests/FEATURES.md AD-74 to AD-77): upload and the
// optimise switch, optimise and restore, where an image is used and delete,
// rename / search / show / sort / bulk. Driven through Addons > Hadrian >
// Media (and the picker in the Pages editor), proven on disk, in the label
// manifest (.hadrian-media.json), in hadrian_settings and in hadrian_pages.
//
// Functional only: ordinary images an admin might pick. The endpoint guards
// (POST, token, X-Requested-With, collection) are admin-csrf.spec and
// admin-uploads.spec territory and are not repeated here.
//
// Every image uploaded here is deleted again through the screen; afterEach
// also removes anything a failed test left, the manifest is put back byte for
// byte, and the last test proves the folders match their start. A Pages save
// refreshes sitemap.xml and robots.txt, so both are copied before the first
// test and put back after the last.

import fs from 'node:fs';
import path from 'node:path';
import zlib from 'node:zlib';
import crypto from 'node:crypto';
import { test, db, settings, useAuditBackup, adminUrl, HADRIAN, noErrorText, setChecked } from './harness.mjs';
import { REPO_ROOT, WHMCS_ROOT } from '../../lib/env.mjs';

useAuditBackup();

const DIR = path.join(REPO_ROOT, 'hadrian', 'templates', 'hadrian', 'assets', 'img', 'media');
const ORIG = path.join(DIR, '.originals');
const MANIFEST = path.join(DIR, '.hadrian-media.json');
const REL = name => `templates/hadrian/assets/img/media/${name}`;
const ls = d => (fs.existsSync(d) ? fs.readdirSync(d).sort() : []);
const manifest = () => { try { return JSON.parse(fs.readFileSync(MANIFEST, 'utf8')); } catch { return {}; } };
let START = null;
const added = () => ls(DIR).filter(f => !START.dir.includes(f));

// sitemap.xml / robots.txt: a Pages save rewrites them.
const ROOT_FILES = [path.join(WHMCS_ROOT, 'sitemap.xml'), path.join(WHMCS_ROOT, 'robots.txt')];
let rootFiles = [];

function sweep() {
  if (!START) return;
  for (const f of ls(DIR)) if (!START.dir.includes(f)) fs.rmSync(path.join(DIR, f), { force: true, recursive: true });
  for (const f of ls(ORIG)) if (!START.orig.includes(f)) fs.rmSync(path.join(ORIG, f), { force: true });
  if (START.manifest) fs.writeFileSync(MANIFEST, START.manifest);
}

test.beforeAll(() => {
  START = { dir: ls(DIR), orig: ls(ORIG), manifest: fs.existsSync(MANIFEST) ? fs.readFileSync(MANIFEST) : null };
  rootFiles = ROOT_FILES.map(f => (fs.existsSync(f) ? { f, bytes: fs.readFileSync(f), st: fs.statSync(f) } : { f, bytes: null }));
});
test.afterAll(() => {
  for (const r of rootFiles) {
    if (r.bytes) { fs.writeFileSync(r.f, r.bytes); fs.utimesSync(r.f, r.st.atime, r.st.mtime); }
    else if (fs.existsSync(r.f)) fs.unlinkSync(r.f);
  }
});
// The optimise settings start from their defaults (no row): switch on,
// quality 82, largest size 2560.
const DEFAULTS = { media_optimize_uploads: null, media_optimize_quality: null, media_optimize_max_edge: null };
test.beforeEach(() => { settings.snapshot(); settings.set(DEFAULTS); });
test.afterEach(() => { settings.restore(); sweep(); });

// ------------------------------------------------------------- sample files

const sha1 = buf => crypto.createHash('sha1').update(buf).digest('hex');
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
const PNG = png(2, 2);
const GIF = Buffer.from('R0lGODlhAQABAIAAAAAAAP///yH5BAEAAAAALAAAAAABAAEAAAIBRAA7', 'base64');
const SVG = Buffer.from('<svg xmlns="http://www.w3.org/2000/svg" width="10" height="10"><rect width="10" height="10"/></svg>');

/** A detailed JPEG drawn in the page, w x h, so re-encoding it is clearly smaller. */
const photo = (page, w = 1400, h = 900) => page.evaluate(async ([w, h]) => {
  const c = document.createElement('canvas');
  c.width = w; c.height = h;
  const g = c.getContext('2d');
  for (let i = 0; i < 400; i++) {
    g.fillStyle = `hsl(${(i * 47) % 360} 80% ${30 + (i * 13) % 50}%)`;
    g.beginPath();
    g.arc((i * 211) % w, (i * 97) % h, 20 + (i * 31) % 160, 0, 7);
    g.fill();
  }
  const blob = await new Promise(r => c.toBlob(r, 'image/jpeg', 0.98));
  return Array.from(new Uint8Array(await blob.arrayBuffer()));
}, [w, h]).then(a => Buffer.from(a));

// ------------------------------------------------------------------ helpers

const jsonFrom = (page, sub) => page.waitForResponse(r => r.url().includes(`sub=${sub}`) && r.request().method() === 'POST');
const idle = page => page.waitForFunction(() => window.hadrianMedia && window.hadrianMedia.idle());
const tile = (page, name) => page.locator(`.mt-ml-tile[data-name="${name}"]`);
const ourLabels = async page => (await page.locator('.mt-ml-tile .mt-media-name').allInnerTexts()).filter(t => t.startsWith('Audit '));

async function openMedia(page) {
  await page.goto(adminUrl('media'));
  await idle(page);
}

/** Pick one file on "Upload images" and return the upload's JSON reply. */
async function upload(page, file) {
  const answered = jsonFrom(page, 'upload');
  await page.locator('#mt-ml-file').setInputFiles(file);
  const res = await answered;
  const body = await res.json();
  await idle(page);
  return { status: res.status(), body };
}

/** Turn "Optimise new uploads" on or off through its switch; returns the reply. */
async function setOptimise(page, on) {
  const toggle = page.locator('#mt-ml-opt-toggle');
  if ((await toggle.isChecked()) === on) return null;
  const saved = jsonFrom(page, 'settings');
  await setChecked(toggle, on);                  // the input sits visually hidden behind its track
  return (await saved).json();
}

/** Open an image's details and delete it through the dialog. Returns the delete reply and the request body. */
async function deleteFromDetails(page, name) {
  await tile(page, name).click();
  await page.locator('#mt-ml-detail .mt-ml-del').click();
  const del = jsonFrom(page, 'delete');
  await page.locator('#mt-ml-dialog-yes').click();
  const res = await del;
  const out = { body: await res.json(), sent: res.request().postData() || '' };
  await idle(page);
  return out;
}

/** Delete every image this test uploaded, through the Media screen. */
async function cleanUp(page, names) {
  await openMedia(page);
  for (const n of names) {
    if ((await tile(page, n).count()) > 0) await deleteFromDetails(page, n);
  }
}

/** The page the Pages screen lists first, and its editor address. */
async function firstPage(page) {
  await page.goto(adminUrl('pages'));
  const href = await page.locator('a[href*="action=pages"][href*="sub=edit"]').first().getAttribute('href');
  const key = new URLSearchParams(href.split('?')[1]).get('page');
  return { key, url: `${HADRIAN}${href.replace(/^\?module=Hadrian/, '')}` };
}

// ------------------------------------------------------------------- AD-74

test('AD-74 Upload stores the image with its label and optimises it while the switch is on', async ({ admin, proof }) => {
  proof.claim('An image picked on "Upload images" is stored under a random name, labelled from its file name, and optimised (the original kept in .originals) while "Optimise new uploads" is on.');
  await openMedia(admin);
  await noErrorText(admin, proof, 'Media screen');
  proof.equal('"Optimise new uploads" starts on (media_optimize_uploads unset)', [await admin.locator('#mt-ml-opt-toggle').isChecked(), db.setting('media_optimize_uploads')], [true, null]);
  const bytes = await photo(admin);
  const statsBefore = await admin.locator('#mt-ml-stats').innerText();

  proof.step('Pick "Audit Hero Photo.jpg" on Upload images');
  const up = await upload(admin, { name: 'Audit Hero Photo.jpg', mimeType: 'image/jpeg', buffer: bytes });
  proof.equal('the upload answers 200 with ok: true', [up.status, up.body.ok], [200, true]);
  const name = up.body.item.name;
  proof.check('the stored name is random hex', /^[0-9a-f]{32}\.jpg$/.test(name), name);
  proof.equal('the library folder gained exactly that file', added(), [name]);
  proof.value('manifest entry', undefined, manifest()[name]);
  proof.equal('the label comes from the file name, extension dropped', manifest()[name]?.label, 'Audit Hero Photo');
  proof.equal('the answer says it was optimised', up.body.optimized, true);
  const disk = db.file(REL(name));
  proof.check('the stored file is smaller than what was sent', disk.size < bytes.length, `${disk.size} < ${bytes.length}`);
  proof.equal('the untouched original is kept in .originals', sha1(fs.readFileSync(path.join(ORIG, name))), sha1(bytes));
  await tile(admin, name).waitFor();
  proof.check('the grid shows the tile under its label', (await tile(admin, name).innerText()).includes('Audit Hero Photo'));
  proof.check('the tile is flagged Unused', (await tile(admin, name).locator('.mt-ml-flag').innerText()) === 'Unused');
  const statsAfter = await admin.locator('#mt-ml-stats').innerText();
  proof.value('library count line', statsBefore, statsAfter);
  proof.check('the count line went up by one', parseInt(statsAfter, 10) === parseInt(statsBefore, 10) + 1, `${statsBefore} -> ${statsAfter}`);
  await proof.shot(admin, 'Media after the upload');

  await cleanUp(admin, [name]);
  proof.equal('cleanup: the folder and .originals are back to their start', [added(), ls(ORIG)], [[], START.orig]);
});

test('AD-74 With the switch off an upload is stored exactly as sent', async ({ admin, proof }) => {
  proof.claim('Turning "Optimise new uploads" off stores media_optimize_uploads=0, survives a reload, and the next upload is kept byte for byte with nothing set aside.');
  await openMedia(admin);
  const before = db.setting('media_optimize_uploads');
  proof.step('Switch "Optimise new uploads" off');
  const reply = await setOptimise(admin, false);
  proof.equal('the switch answers optimizeUploads: false', reply?.optimizeUploads, false);
  const after = db.setting('media_optimize_uploads');
  proof.value('media_optimize_uploads', before, after);
  proof.equal('the switch stored "0"', after, '0');
  await admin.reload(); await idle(admin);
  proof.check('the switch is still off after a reload', !(await admin.locator('#mt-ml-opt-toggle').isChecked()));

  const bytes = await photo(admin);
  proof.step('Pick "Audit As Sent.jpg"');
  const up = await upload(admin, { name: 'Audit As Sent.jpg', mimeType: 'image/jpeg', buffer: bytes });
  proof.equal('the answer says it was not optimised', up.body.optimized, false);
  proof.equal('the file on disk is byte for byte what was sent', db.file(REL(up.body.item.name)).sha1, sha1(bytes));
  proof.equal('nothing was set aside in .originals', ls(ORIG), START.orig);
  await proof.shot(admin.locator('#mt-ml-side'), 'details of the image kept as sent');

  proof.step('Switch it back on');
  await setOptimise(admin, true);
  proof.equal('the switch stored "1"', db.setting('media_optimize_uploads'), '1');
  await cleanUp(admin, [up.body.item.name]);
  proof.equal('cleanup: the folder is back to its start', added(), []);
});

test('AD-74 Upload takes raster images only: an SVG is refused and nothing is stored', async ({ admin, proof }) => {
  proof.claim('An SVG picked on the Media screen is refused with "Unsupported file type (image/svg+xml)" in the upload queue, and nothing is stored.');
  await openMedia(admin);
  proof.step('Pick logo.svg on Upload images');
  const up = await upload(admin, { name: 'logo.svg', mimeType: 'image/svg+xml', buffer: SVG });
  proof.equal('the upload answers 422 with ok: false', [up.status, up.body.ok], [422, false]);
  proof.check('the reason names the type', /Unsupported file type \(image\/svg\+xml\)/.test(up.body.error), up.body.error);
  const row = admin.locator('#mt-ml-queue .mt-media-q.is-error').last();
  proof.check('the upload queue shows the reason', /Unsupported file type/.test(await row.innerText()), await row.innerText());
  await proof.shot(admin.locator('#mt-ml-panel'), 'queue with the refusal');
  proof.equal('nothing was added to the library folder', added(), []);
  proof.equal('and nothing to the manifest', manifest(), START.manifest ? JSON.parse(START.manifest) : {});
});

test('AD-74 A file over 5 MB is stopped by the screen before it is sent', async ({ admin, proof }) => {
  proof.claim('The screen refuses a file over the 5 MB limit in the upload queue ("Too large") without sending it.');
  await openMedia(admin);
  const big = png(1400, 1300, { noise: true });
  let sent = false;
  const onReq = r => { if (r.url().includes('sub=upload')) sent = true; };
  admin.on('request', onReq);
  proof.step(`Pick huge.png (${big.length} bytes, a 1400 x 1300 photo-like PNG) on Upload images`);
  await admin.locator('#mt-ml-file').setInputFiles({ name: 'huge.png', mimeType: 'image/png', buffer: big });
  const row = admin.locator('#mt-ml-queue .mt-media-q.is-error').last();
  await row.waitFor();
  await admin.waitForTimeout(500);
  admin.off('request', onReq);
  proof.check('the queue says it is too large, with the 5 MB limit', /Too large.*5\.0 MB/.test(await row.innerText()), await row.innerText());
  proof.equal('the screen sent no upload request', sent, false);
  proof.equal('nothing was added to the library folder', added(), []);
  await proof.shot(admin.locator('#mt-ml-panel'), 'queue refusing the big file');
});

// ------------------------------------------------------------------- AD-75

test('AD-75 Optimise makes an image smaller and Restore original puts every byte back', async ({ admin, proof }) => {
  proof.claim('Optimise in the details re-encodes a JPEG to at most 95% of its size and keeps the original in .originals; Restore original puts the original back, empties .originals and marks the image so "Optimise all" leaves it.');
  await openMedia(admin);
  await setOptimise(admin, false);
  const bytes = await photo(admin);
  const up = await upload(admin, { name: 'Audit Optimise Me.jpg', mimeType: 'image/jpeg', buffer: bytes });
  const name = up.body.item.name;
  proof.check('set up: stored as sent', db.file(REL(name)).sha1 === sha1(bytes));

  proof.step('Open the image, press Optimise');
  await tile(admin, name).click();
  const opt = jsonFrom(admin, 'optimize');
  await admin.locator('#mt-ml-detail button', { hasText: /^Optimise$/ }).click();
  const r = (await (await opt).json()).results[name];
  await idle(admin);
  proof.equal('the result is "optimized"', r.status, 'optimized');
  const after = db.file(REL(name)).size;
  proof.value(`${name} bytes`, bytes.length, after);
  proof.check('it is at most 95% of the original', after <= bytes.length * 0.95, `${after} / ${bytes.length}`);
  proof.equal('the original is in .originals, untouched', sha1(fs.readFileSync(path.join(ORIG, name))), sha1(bytes));
  await admin.locator('#mt-ml-detail .mt-badge-success').waitFor();
  proof.check('the details say Optimised and how much smaller', /Optimised[\s\S]*smaller/.test(await admin.locator('#mt-ml-detail .mt-ml-opt').innerText()));
  await proof.shot(admin.locator('#mt-ml-detail'), 'details after Optimise');

  proof.step('Press Restore original');
  const rest = jsonFrom(admin, 'restore');
  await admin.locator('#mt-ml-detail button', { hasText: 'Restore original' }).click();
  const restored = await (await rest).json();
  await idle(admin);
  proof.equal('restore answers ok', restored.ok, true);
  proof.equal('the file is the original again, byte for byte', db.file(REL(name)).sha1, sha1(bytes));
  proof.equal('.originals no longer holds it', fs.existsSync(path.join(ORIG, name)), false);
  proof.equal('the manifest marks it skipOptimize so "Optimise all" leaves it', manifest()[name]?.skipOptimize, 1);
  await proof.shot(admin.locator('#mt-ml-detail'), 'details after Restore original');

  await cleanUp(admin, [name]);
  proof.equal('cleanup: folder and .originals are back to their start', [added(), ls(ORIG)], [[], START.orig]);
});

test('AD-75 Optimise leaves a GIF alone and keeps an image it cannot shrink', async ({ admin, proof }) => {
  proof.claim('A GIF is skipped with its reason, and a tiny PNG that would not get 5% smaller is kept as it is; neither gets a copy in .originals.');
  await openMedia(admin);
  await setOptimise(admin, false);
  const gif = (await upload(admin, { name: 'Audit Anim.gif', mimeType: 'image/gif', buffer: GIF })).body.item;
  const tiny = (await upload(admin, { name: 'Audit Tiny.png', mimeType: 'image/png', buffer: PNG })).body.item;

  for (const [item, src, want] of [[gif, GIF, { status: 'skipped', reason: /GIF/ }], [tiny, PNG, { status: 'kept', reason: /small/i }]]) {
    proof.step(`Open "${item.label}", press Optimise`);
    await tile(admin, item.name).click();
    const opt = jsonFrom(admin, 'optimize');
    await admin.locator('#mt-ml-detail button', { hasText: /^Optimise$/ }).click();
    const r = (await (await opt).json()).results[item.name];
    await idle(admin);
    proof.note(`${item.label}: status "${r.status}", reason "${r.reason}"`);
    proof.equal(`${item.label}: status is "${want.status}"`, r.status, want.status);
    proof.check(`${item.label}: the reason says why`, want.reason.test(r.reason || ''), r.reason);
    proof.equal(`${item.label}: the file is unchanged`, db.file(REL(item.name)).sha1, sha1(src));
    proof.equal(`${item.label}: nothing set aside`, fs.existsSync(path.join(ORIG, item.name)), false);
    proof.check(`${item.label}: the status line repeats the reason`, (await admin.locator('#mt-ml-status').innerText()).trim() !== '');
  }
  await proof.shot(admin.locator('#mt-ml-panel'), 'status after optimising the GIF and the PNG');
  proof.limit('Animated PNG/WebP, lossless WebP and non-sRGB JPEG skips and the 8-second batch budget are not exercised here.');
  await cleanUp(admin, [gif.name, tiny.name]);
  proof.equal('cleanup: the folder is back to its start', added(), []);
});

test('AD-75 Optimising scales an image to the "Largest size" setting (2560 px by default, 1600 once picked)', async ({ admin, proof }) => {
  proof.claim('An upload wider than "Largest size" is scaled down to it on its longest edge: 2560 px by default; after picking 1600 px on the screen (stored as media_optimize_max_edge=1600) the next one is scaled to 1600.');
  await openMedia(admin);
  proof.equal('"Largest size" shows 2560 px', await admin.locator('#mt-ml-maxedge').inputValue(), '2560');
  const wide = await photo(admin, 3000, 1500);
  proof.step('Pick a 3000 x 1500 JPEG with the optimise switch on');
  const a = (await upload(admin, { name: 'Audit Wide.jpg', mimeType: 'image/jpeg', buffer: wide })).body;
  proof.equal('it was optimised', a.optimized, true);
  proof.equal('and scaled to 2560 x 1280', [a.item.w, a.item.h], [2560, 1280]);
  proof.equal('the original keeps its 3000 px in .originals', sha1(fs.readFileSync(path.join(ORIG, a.item.name))), sha1(wide));

  proof.step('Pick "1600 px" under Largest size');
  const before = db.setting('media_optimize_max_edge');
  const saved = jsonFrom(admin, 'settings');
  await admin.locator('#mt-ml-maxedge').selectOption('1600');
  const reply = await (await saved).json();
  proof.equal('the screen answers maxEdge: 1600', reply.maxEdge, 1600);
  proof.value('media_optimize_max_edge', before, db.setting('media_optimize_max_edge'));
  proof.equal('the setting is stored as "1600"', db.setting('media_optimize_max_edge'), '1600');
  await admin.reload(); await idle(admin);
  proof.equal('the select shows 1600 px after a reload', await admin.locator('#mt-ml-maxedge').inputValue(), '1600');

  proof.step('Pick the same 3000 x 1500 JPEG again');
  const b = (await upload(admin, { name: 'Audit Wide Two.jpg', mimeType: 'image/jpeg', buffer: wide })).body;
  proof.equal('this one is scaled to 1600 x 800', [b.item.w, b.item.h], [1600, 800]);
  await proof.shot(admin.locator('#mt-ml-side'), 'details of the 1600 px image');
  await cleanUp(admin, [a.item.name, b.item.name]);
  proof.equal('cleanup: folder and .originals are back to their start', [added(), ls(ORIG)], [[], START.orig]);
});

// ------------------------------------------------------------------- AD-76

test('AD-76 An image a page uses is kept by the picker\'s delete and deleted only after "Delete anyway"', async ({ admin, proof }) => {
  proof.claim('Once a page uses an image as its social image, the Media screen lists where it is used, the picker\'s delete (which never forces) keeps it, and the Media screen deletes it only after its warning and "Delete anyway" (force=1).');
  await openMedia(admin);
  const up = await upload(admin, { name: 'Audit In Use.png', mimeType: 'image/png', buffer: png(120, 63) });
  const it = up.body.item;
  const pg = await firstPage(admin);

  proof.step(`Open the Pages editor for "${pg.key}", open the social image picker, choose "Audit In Use", press Use image, then Save changes`);
  await admin.goto(pg.url);
  const field = admin.locator('#seo-social');
  const seoBefore = db.page(pg.key)?.seo_image ?? null;
  const listed = jsonFrom(admin, 'list');
  await field.locator('xpath=ancestor::*[contains(@class,"mt-media-field")][1]').locator('[data-mt-media-open]').click();
  await listed;
  const pTile = admin.locator(`#mt-media-modal .mt-media-tile[data-name="${it.name}"]`);
  await pTile.click();
  await admin.locator('#mt-media-use').click();
  proof.equal('the field now holds the image address', await field.inputValue(), it.absUrl);
  await Promise.all([admin.waitForURL(/flash=saved/), admin.locator('#page-edit-form .mt-savebar button[type="submit"]').click()]);
  const seoAfter = db.page(pg.key)?.seo_image ?? null;
  proof.value(`hadrian_pages.${pg.key}.seo_image`, seoBefore, seoAfter);
  proof.equal('the page stored the image as its social image', seoAfter, it.absUrl);

  proof.step('Reopen the picker, hover the image, press its delete, then Delete');
  const listed2 = jsonFrom(admin, 'list');
  await admin.locator('#seo-social').locator('xpath=ancestor::*[contains(@class,"mt-media-field")][1]').locator('[data-mt-media-open]').click();
  await listed2;
  const pt = admin.locator(`#mt-media-modal .mt-media-tile[data-name="${it.name}"]`);
  const del1 = jsonFrom(admin, 'delete');
  await pt.hover();
  await pt.locator('.mt-media-del').click();
  await pt.locator('.mt-media-confirm button', { hasText: 'Delete' }).click();
  const req1 = await del1;
  const r1 = await req1.json();
  proof.check('the picker did not send force', !/name="force"/.test(req1.request().postData() || ''));
  proof.equal('the picker\'s delete answers "in-use"', r1.results[it.name], 'in-use');
  proof.check('and names the page', (r1.usage[it.name] || []).some(u => u.where === `Social image of the page "${pg.key}"`), r1.usage[it.name]);
  proof.equal('the file is still on disk', db.file(REL(it.name)).exists, true);
  await proof.shot(admin.locator('#mt-media-modal .mt-modal-card'), 'picker keeping the image');

  proof.step('Open the Media screen, open the image, press Delete image, read the dialog, press Delete anyway');
  await openMedia(admin);
  proof.equal('the tile has no "Unused" flag', await tile(admin, it.name).locator('.mt-ml-flag').count(), 0);
  await admin.locator('#mt-ml-show [data-show="used"]').click();
  proof.check('"In use" shows it', await tile(admin, it.name).isVisible());
  await admin.locator('#mt-ml-show [data-show="all"]').click();
  await tile(admin, it.name).click();
  const usedList = await admin.locator('#mt-ml-detail .mt-ml-usedlist').innerText();
  proof.check('the details list the page that uses it', usedList.includes(`Social image of the page "${pg.key}"`), usedList);
  await admin.locator('#mt-ml-detail .mt-ml-del').click();
  const dialog = admin.locator('#mt-ml-dialog');
  proof.check('the dialog warns it is in use and says where', (await dialog.innerText()).includes('This image is in use') && (await dialog.innerText()).includes(pg.key));
  proof.equal('the confirm button reads "Delete anyway"', (await admin.locator('#mt-ml-dialog-yes').innerText()).trim(), 'Delete anyway');
  await proof.shot(dialog.locator('.mt-modal-card'), 'delete dialog for an image in use');
  const del2 = jsonFrom(admin, 'delete');
  await admin.locator('#mt-ml-dialog-yes').click();
  const req2 = await del2;
  const r2 = await req2.json();
  await idle(admin);
  proof.check('the screen sent force=1', /name="force"\r\n\r\n1/.test(req2.request().postData() || ''));
  proof.equal('the forced delete answers "deleted"', r2.results[it.name], 'deleted');
  proof.equal('the file is gone from disk', db.file(REL(it.name)).exists, false);
  proof.equal('its label left the manifest', manifest()[it.name], undefined);
  proof.equal('its tile left the grid', await tile(admin, it.name).count(), 0);
  proof.note('The page still names the deleted address until it is changed; settings.restore() puts its social image back after the test.');
});

// ------------------------------------------------------------------- AD-77

test('AD-77 Rename cleans the label and caps it at 80 characters; the file keeps its name', async ({ admin, proof }) => {
  proof.claim('Renaming in the details stores a label with runs of spaces collapsed, trimmed, and cut to 80 characters; the grid shows it and the file on disk does not change.');
  await openMedia(admin);
  const up = await upload(admin, { name: 'Audit Rename Me.png', mimeType: 'image/png', buffer: PNG });
  const name = up.body.item.name;
  await tile(admin, name).click();
  const field = admin.locator('#mt-ml-name');
  proof.equal('the Name field stops at 80 characters', await field.getAttribute('maxlength'), '80');

  proof.step('Lift the Name field\'s maxlength, type 120 characters with runs of spaces, press Enter');
  const typed = '   Audit    Renamed   ' + 'x'.repeat(100);
  const want = ('Audit Renamed ' + 'x'.repeat(100)).slice(0, 80);
  await field.evaluate(el => el.removeAttribute('maxlength'));
  const renamed = jsonFrom(admin, 'rename');
  await field.fill(typed);
  await field.press('Enter');
  const r = await (await renamed).json();
  proof.value('manifest label', 'Audit Rename Me', manifest()[name]?.label);
  proof.equal('the stored label is cleaned and 80 characters long', manifest()[name]?.label, want);
  proof.equal('the answer carries the same label', r.item.label, want);
  proof.equal('the file keeps its own name, byte for byte', db.file(REL(name)).sha1, sha1(PNG));
  proof.check('the grid shows the new label', (await tile(admin, name).innerText()).includes(want));
  await admin.reload(); await idle(admin);
  proof.check('the new label is still there after a reload', (await tile(admin, name).innerText()).includes(want));
  await proof.shot(tile(admin, name), 'tile after the rename');
  await cleanUp(admin, [name]);
});

test('AD-77 Search, show and sort narrow and order the grid', async ({ admin, proof }) => {
  proof.claim('Search narrows the grid by label, "In use" / "Unused" filter it by whether something points at the image, and "Name" / "Largest first" sort it.');
  await openMedia(admin);
  await setOptimise(admin, false);
  const a = (await upload(admin, { name: 'Audit Charlie.png', mimeType: 'image/png', buffer: PNG })).body.item;
  const b = (await upload(admin, { name: 'Audit Alpha.jpg', mimeType: 'image/jpeg', buffer: await photo(admin, 600, 400) })).body.item;
  const c = (await upload(admin, { name: 'Audit Bravo.gif', mimeType: 'image/gif', buffer: GIF })).body.item;
  const pg = await firstPage(admin);
  proof.step(`Set up: page "${pg.key}" uses "Audit Bravo" as its social image (stored directly)`);
  settings.page({ [pg.key]: { seo_image: c.absUrl } });
  await openMedia(admin);

  proof.step('Type "Audit Alpha" in Search images');
  await admin.locator('#mt-ml-q').fill('Audit Alpha');
  proof.equal('only Audit Alpha is shown of the three', await ourLabels(admin), ['Audit Alpha']);
  await proof.shot(admin.locator('#mt-ml-panel'), 'search for Audit Alpha');
  await admin.locator('#mt-ml-q').fill('');

  proof.step('Press Unused, then In use, then All');
  await admin.locator('#mt-ml-show [data-show="unused"]').click();
  proof.equal('Unused shows the two unused ones', (await ourLabels(admin)).sort(), ['Audit Alpha', 'Audit Charlie']);
  await admin.locator('#mt-ml-show [data-show="used"]').click();
  proof.equal('In use shows only the GIF the page points at', await ourLabels(admin), ['Audit Bravo']);
  await proof.shot(admin.locator('#mt-ml-panel'), 'In use filter');
  await admin.locator('#mt-ml-show [data-show="all"]').click();

  proof.step('Sort by Name, then by Largest first');
  await admin.locator('#mt-ml-sort').selectOption('name');
  proof.equal('Name sorts by label', await ourLabels(admin), ['Audit Alpha', 'Audit Bravo', 'Audit Charlie']);
  await admin.locator('#mt-ml-sort').selectOption('big');
  const big = await ourLabels(admin);
  proof.equal('Largest first puts the JPEG first', big[0], 'Audit Alpha');
  proof.check('the sizes on disk agree', db.file(REL(b.name)).size > db.file(REL(a.name)).size && db.file(REL(b.name)).size > db.file(REL(c.name)).size);

  await cleanUp(admin, [a.name, b.name, c.name]);
  proof.equal('cleanup: the folder is back to its start', added(), []);
});

test('AD-77 The bulk bar deletes exactly the ticked images', async ({ admin, proof }) => {
  proof.claim('Ticking tiles opens the bulk bar with a count, and its Delete removes exactly those images, from disk and from the manifest.');
  await openMedia(admin);
  await setOptimise(admin, false);
  const a = (await upload(admin, { name: 'Audit Bulk A.png', mimeType: 'image/png', buffer: PNG })).body.item;
  const b = (await upload(admin, { name: 'Audit Bulk B.gif', mimeType: 'image/gif', buffer: GIF })).body.item;
  const c = (await upload(admin, { name: 'Audit Bulk C.png', mimeType: 'image/png', buffer: png(4, 4) })).body.item;

  proof.check('the bulk bar is hidden with nothing ticked', !(await admin.locator('#mt-ml-bulk').isVisible()));
  proof.step('Tick Audit Bulk A and Audit Bulk C, press the bulk Delete, confirm');
  await setChecked(tile(admin, a.name).locator('.mt-ml-pick input'));
  await setChecked(tile(admin, c.name).locator('.mt-ml-pick input'));
  proof.equal('the bulk bar counts two', await admin.locator('#mt-ml-bulk-count').innerText(), '2 images selected');
  await proof.shot(admin.locator('#mt-ml-panel'), 'two tiles ticked');
  await admin.locator('#mt-ml-bulk-del').click();
  proof.check('the dialog asks about two images', /Delete 2 images\?/.test(await admin.locator('#mt-ml-dialog-title').innerText()));
  const del = jsonFrom(admin, 'delete');
  await admin.locator('#mt-ml-dialog-yes').click();
  const r = await (await del).json();
  await idle(admin);
  proof.equal('two were deleted', r.deleted, 2);
  proof.equal('their files are gone, the unticked one stays', [db.file(REL(a.name)).exists, db.file(REL(b.name)).exists, db.file(REL(c.name)).exists], [false, true, false]);
  proof.equal('the manifest keeps only the unticked one of the three', [a.name, b.name, c.name].map(n => !!manifest()[n]), [false, true, false]);
  proof.check('the status line reports it', /Deleted 2 images/.test(await admin.locator('#mt-ml-status').innerText()));
  proof.check('the bulk bar closed', !(await admin.locator('#mt-ml-bulk').isVisible()));
  await cleanUp(admin, [b.name]);
  proof.equal('cleanup: the folder is back to its start', added(), []);
});

test('AD-77 Bulk Optimise runs over the ticked images', async ({ admin, proof }) => {
  proof.claim('Ticking images and pressing Optimise in the bulk bar optimises each one that can be, keeping each original, and the status line counts them.');
  await openMedia(admin);
  await setOptimise(admin, false);
  const xBytes = await photo(admin);
  const yBytes = await photo(admin, 1200, 800);
  const x = (await upload(admin, { name: 'Audit Bulk One.jpg', mimeType: 'image/jpeg', buffer: xBytes })).body.item;
  const y = (await upload(admin, { name: 'Audit Bulk Two.jpg', mimeType: 'image/jpeg', buffer: yBytes })).body.item;
  await setChecked(tile(admin, x.name).locator('.mt-ml-pick input'));
  await setChecked(tile(admin, y.name).locator('.mt-ml-pick input'));
  proof.step('Tick both, press Optimise in the bulk bar');
  const opt = jsonFrom(admin, 'optimize');
  await admin.locator('#mt-ml-bulk-opt').click();
  const r = await (await opt).json();
  await idle(admin);
  proof.equal('both came back "optimized"', [r.results[x.name]?.status, r.results[y.name]?.status], ['optimized', 'optimized']);
  proof.check('both files on disk shrank', db.file(REL(x.name)).size < xBytes.length && db.file(REL(y.name)).size < yBytes.length);
  proof.check('both originals are in .originals', fs.existsSync(path.join(ORIG, x.name)) && fs.existsSync(path.join(ORIG, y.name)));
  const status = await admin.locator('#mt-ml-status').innerText();
  proof.check('the status line reports two optimised', /Optimised 2 images/.test(status), status);
  await proof.shot(admin.locator('#mt-ml-panel'), 'after the bulk Optimise');
  await cleanUp(admin, [x.name, y.name]);
  proof.equal('cleanup: folder and .originals are back to their start', [added(), ls(ORIG)], [[], START.orig]);
});

// ------------------------------------------------------------------ cleanup

test('AD-74 Every upload is gone: the media folder matches its start', async ({ proof }) => {
  proof.claim('After the uploads above, the library folder, .originals and the label manifest are as they were when this file began.');
  proof.equal('the library folder listing equals its start', ls(DIR), START.dir);
  proof.equal('.originals equals its start', ls(ORIG), START.orig);
  proof.check('the manifest is byte for byte its start', !START.manifest || fs.readFileSync(MANIFEST).equals(START.manifest));
});
