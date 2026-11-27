// Tier 3c (settings) - the addon's JSON endpoints, driven the way an admin
// drives them: the Branding page's upload tiles and the media picker.
//
// These endpoints used to be answered from hooks.php, before WHMCS's admin
// login check, so anyone could reach them (security review 2026-10, C1). They
// now run inside Hadrian_output(). This spec proves the move kept them
// working for a signed-in admin; admin.spec.mjs proves an anonymous visitor
// is turned away.
//
// In the settings project (one worker, its own run.mjs step): a logo upload
// changes what every client page shows. Everything uploaded is removed again
// through the same UI, and the storage folders are checked to be as they were.

import { test, expect } from '@playwright/test';
import fs from 'node:fs';
import path from 'node:path';
import { REPO_ROOT } from '../lib/env.mjs';
import { loginAdmin } from './helpers.mjs';

const H = '/admin/addonmodules.php?module=Hadrian';
const IMG = path.join(REPO_ROOT, 'hadrian', 'templates', 'hadrian', 'assets', 'img');
// A valid 2x2 PNG: passes the uploader's MIME, extension and image checks.
const PNG = Buffer.from(
  'iVBORw0KGgoAAAANSUhEUgAAAAIAAAACCAYAAABytg0kAAAAFElEQVR4nGNgKHz8HwQYwETh4/8AbjEMn1ZYZjYAAAAASUVORK5CYII=',
  'base64',
);
const listing = dir => (fs.existsSync(dir) ? fs.readdirSync(dir).filter(f => !f.startsWith('.')).sort() : []);
const jsonFrom = (page, sub) => page.waitForResponse(r => r.url().includes(`sub=${sub}`) && r.request().method() === 'POST');

test.beforeEach(async ({ page }) => { await loginAdmin(page.context().request); });

test('branding: a logo uploads and removes through the page', async ({ page }) => {
  const before = listing(path.join(IMG, 'branding'));
  await page.goto(`${H}&action=branding`);
  const tile = page.locator('.mt-branding-tile[data-field="logo_light"]');
  await expect(tile).toBeVisible();
  await expect(tile.locator('img'), 'this test expects an empty slot; restore it first').toHaveCount(0);
  // A run that died between upload and remove leaves the logo behind; this
  // makes the next run fail loudly here instead of quietly testing a replace.

  const uploaded = jsonFrom(page, 'upload-ajax');
  await page.locator('#upload-logo_light').setInputFiles({ name: 'test-logo.png', mimeType: 'image/png', buffer: PNG });
  const up = await uploaded;
  expect(up.status(), await up.text()).toBe(200);
  const upBody = await up.json();
  expect(upBody.ok, JSON.stringify(upBody)).toBe(true);
  await expect(tile.locator('img'), 'the tile shows the new logo').toHaveCount(1);
  expect(listing(path.join(IMG, 'branding')).length, 'the file is on disk').toBe(before.length + 1);

  const removed = jsonFrom(page, 'remove-ajax');
  page.once('dialog', d => d.accept());          // "Remove the Light logo file?"
  await tile.locator('[data-remove="logo_light"]').click({ force: true });   // the overlay button appears on hover
  const rm = await removed;
  expect(rm.status(), await rm.text()).toBe(200);
  expect((await rm.json()).ok).toBe(true);
  await expect(tile.locator('img'), 'the tile is empty again').toHaveCount(0);
  expect(listing(path.join(IMG, 'branding')), 'and the file is gone').toEqual(before);
});

test('media picker: lists, uploads and deletes', async ({ page }) => {
  const before = listing(path.join(IMG, 'media'));
  await page.goto(`${H}&action=pages`);
  const edit = await page.locator('a[href*="action=pages"][href*="sub=edit"]').first().getAttribute('href');
  expect(edit, 'the Pages screen links to an editor').toBeTruthy();
  await page.goto(`${H}${edit.replace(/^\?module=Hadrian/, '')}`);

  const listed = jsonFrom(page, 'list');
  await page.locator('.mt-media-well').first().click();
  const list = await listed;
  expect(list.status(), await list.text()).toBe(200);
  expect((await list.json()).ok).toBe(true);
  await expect(page.locator('#mt-media-modal')).toBeVisible();

  const uploaded = jsonFrom(page, 'upload');
  await page.locator('#mt-media-file').setInputFiles({ name: 'test-media.png', mimeType: 'image/png', buffer: PNG });
  const up = await uploaded;
  expect(up.status(), await up.text()).toBe(200);
  const item = (await up.json()).item;
  expect(item?.name, 'the upload returns its stored name').toBeTruthy();
  const tile = page.locator(`.mt-media-tile[data-name="${item.name}"]`);
  await expect(tile, 'the new image appears in the library').toBeVisible();

  const deleted = jsonFrom(page, 'delete');
  await tile.hover();
  await tile.locator('.mt-media-del').click();
  await tile.locator('.mt-media-confirm button', { hasText: 'Delete' }).click();
  const del = await deleted;
  expect(del.status(), await del.text()).toBe(200);
  expect((await del.json()).results?.[item.name]).toBe('deleted');
  await expect(tile).toHaveCount(0);
  expect(listing(path.join(IMG, 'media')), 'the library folder is as it was').toEqual(before);
});

// A picture with enough detail that re-encoding it at a lower quality is
// clearly smaller, drawn in the page so the test needs no image file.
const photo = page => page.evaluate(async () => {
  const c = document.createElement('canvas');
  c.width = 1400; c.height = 900;
  const g = c.getContext('2d');
  for (let i = 0; i < 400; i++) {
    g.fillStyle = `hsl(${(i * 47) % 360} 80% ${30 + (i * 13) % 50}%)`;
    g.beginPath();
    g.arc((i * 211) % 1400, (i * 97) % 900, 20 + (i * 31) % 160, 0, 7);
    g.fill();
  }
  const blob = await new Promise(r => c.toBlob(r, 'image/jpeg', 0.98));
  return Array.from(new Uint8Array(await blob.arrayBuffer()));
});
const mediaIdle = page => page.waitForFunction(() => window.hadrianMedia && window.hadrianMedia.idle());

test('media screen: upload, optimise, rename, where it is used, delete', async ({ page }) => {
  test.setTimeout(120_000);
  const dir = path.join(IMG, 'media');
  const before = listing(dir);
  const originals = () => listing(path.join(dir, '.originals'));
  const originalsBefore = originals();

  await page.goto(`${H}&action=media`);
  await mediaIdle(page);
  await expect(page.locator('.mt-topnav-item.is-active'), 'Media has its own tab').toHaveText('Media');
  await expect(page.locator('#mt-ml-opt-toggle'), 'new uploads are optimised unless switched off').toBeChecked();

  // Upload: the photo comes back smaller, with its original set aside.
  const bytes = Buffer.from(await photo(page));
  const uploaded = jsonFrom(page, 'upload');
  await page.locator('#mt-ml-file').setInputFiles({ name: 'e2e hero photo.jpg', mimeType: 'image/jpeg', buffer: bytes });
  const up = await (await uploaded).json();
  expect(up.ok, JSON.stringify(up)).toBe(true);
  const name = up.item.name;
  expect(up.optimized, 'the upload was optimised').toBe(true);
  expect(up.item.bytes, 'and is smaller than what was sent').toBeLessThan(bytes.length * 0.8);
  expect([up.item.w, up.item.h], 'its size is recorded').toEqual([1400, 900]);
  expect(fs.statSync(path.join(dir, name)).size, 'the file on disk is the smaller one').toBe(up.item.bytes);
  expect(fs.statSync(path.join(dir, '.originals', name)).size, 'the original is kept, untouched').toBe(bytes.length);
  await mediaIdle(page);

  const tile = page.locator(`.mt-ml-tile[data-name="${name}"]`);
  await expect(tile, 'it is in the grid under the name it was uploaded with').toContainText('e2e hero photo');
  await expect(tile.locator('.mt-ml-flag'), 'and flagged as not used yet').toHaveText('Unused');
  await expect(page.locator('#mt-ml-detail'), 'its details are open').toContainText('Optimised');
  await expect(page.locator('#mt-ml-url'), 'with an absolute address to copy').toHaveValue(new RegExp(`^https?://.+/assets/img/media/${name}$`));

  // Rename: the name changes, the file does not.
  const renamed = jsonFrom(page, 'rename');
  await page.locator('#mt-ml-name').fill('E2E hero');
  await page.locator('#mt-ml-name').press('Enter');
  expect((await (await renamed).json()).item.label).toBe('E2E hero');
  await expect(tile).toContainText('E2E hero');
  expect(fs.existsSync(path.join(dir, name)), 'the file keeps its own name').toBe(true);

  // Restore, then optimise again from the details.
  const restored = jsonFrom(page, 'restore');
  await page.locator('#mt-ml-detail button', { hasText: 'Restore original' }).click();
  expect((await (await restored).json()).item.bytes, 'restore puts back every byte').toBe(bytes.length);
  expect(originals(), 'and nothing is left set aside').toEqual(originalsBefore);
  const optimized = jsonFrom(page, 'optimize');
  await page.locator('#mt-ml-detail button', { hasText: /^Optimise$/ }).click();
  expect((await (await optimized).json()).results[name].status).toBe('optimized');
  await mediaIdle(page);

  // Use it as a page's social image: Media now says where, and the picker
  // refuses to delete it.
  await page.goto(`${H}&action=pages`);
  const edit = await page.locator('a[href*="action=pages"][href*="sub=edit"]').first().getAttribute('href');
  const EDIT = `${H}${edit.replace(/^\?module=Hadrian/, '')}`;
  const setSocial = async value => {
    await page.goto(EDIT);
    const field = page.locator('input[name="seo_social_image"]');
    const was = await field.inputValue();
    await field.evaluate((el, v) => { el.value = v; }, value);
    await Promise.all([page.waitForURL(/flash=saved/), field.evaluate(el => el.form.requestSubmit())]);
    return was;
  };
  const socialBefore = await setSocial(up.item.absUrl);
  try {
    await page.goto(`${H}&action=media`);
    await mediaIdle(page);
    await expect(tile.locator('.mt-ml-flag'), 'no longer flagged unused').toHaveCount(0);
    await tile.click();
    await expect(page.locator('#mt-ml-detail .mt-ml-usedlist a'), 'the details link to the page that uses it').toHaveAttribute('href', /action=pages&sub=edit&page=/);
    await page.locator('#mt-ml-show [data-show="unused"]').click();
    await expect(tile, 'the Unused filter leaves it out').toHaveCount(0);
    await page.locator('#mt-ml-show [data-show="used"]').click();
    await expect(tile, 'and In use shows it').toBeVisible();

    const token = await page.evaluate(() => JSON.parse(document.getElementById('mt-ml-data').textContent).token);
    const kept = await page.request.post(`${H}&action=media&sub=delete`, {
      form: { collection: 'library', 'name[]': name, token }, headers: { 'X-Requested-With': 'XMLHttpRequest' },
    });
    const keptBody = await kept.json();
    expect(keptBody.results[name], 'a delete that does not say "anyway" keeps an image in use').toBe('in-use');
    expect(keptBody.usage[name][0].where, 'and says where').toContain('Social image');
    expect(fs.existsSync(path.join(dir, name))).toBe(true);

    // The screen warns, names the place, and deletes on "Delete anyway".
    await page.locator('#mt-ml-detail .mt-ml-del').click();
    const dialog = page.locator('#mt-ml-dialog');
    await expect(dialog).toContainText('This image is in use');
    await expect(dialog).toContainText('Social image');
    const deleted = jsonFrom(page, 'delete');
    await dialog.locator('#mt-ml-dialog-yes', { hasText: 'Delete anyway' }).click();
    expect((await (await deleted).json()).results[name]).toBe('deleted');
    await expect(tile).toHaveCount(0);
  } finally {
    await setSocial(socialBefore);
  }

  expect(listing(dir), 'the library folder is as it was').toEqual(before);
  expect(originals(), 'and so is the folder of originals').toEqual(originalsBefore);
});

test('media screen: the optimise switch is saved, and an upload then stays as sent', async ({ page }) => {
  const dir = path.join(IMG, 'media');
  const before = listing(dir);
  await page.goto(`${H}&action=media`);
  await mediaIdle(page);
  const toggle = page.locator('#mt-ml-opt-toggle');
  const set = async on => {
    if ((await toggle.isChecked()) === on) return;
    const saved = jsonFrom(page, 'settings');
    await toggle.evaluate(el => el.click());      // the input itself is visually hidden behind its track
    expect((await (await saved).json()).optimizeUploads).toBe(on);
  };
  const was = await toggle.isChecked();
  try {
    await set(false);
    await page.reload();
    await mediaIdle(page);
    await expect(toggle, 'off survives a reload').not.toBeChecked();

    const bytes = Buffer.from(await photo(page));
    const uploaded = jsonFrom(page, 'upload');
    await page.locator('#mt-ml-file').setInputFiles({ name: 'e2e-as-sent.jpg', mimeType: 'image/jpeg', buffer: bytes });
    const up = await (await uploaded).json();
    expect(up.optimized, 'not optimised').toBe(false);
    expect(up.item.bytes, 'stored byte for byte').toBe(bytes.length);
    await mediaIdle(page);

    // Ticked and deleted through the bulk bar.
    const tile = page.locator(`.mt-ml-tile[data-name="${up.item.name}"]`);
    await tile.locator('.mt-ml-pick input').check({ force: true });
    await expect(page.locator('#mt-ml-bulk-count')).toHaveText('1 image selected');
    await page.locator('#mt-ml-bulk-del').click();
    const deleted = jsonFrom(page, 'delete');
    await page.locator('#mt-ml-dialog-yes').click();
    expect((await (await deleted).json()).deleted).toBe(1);
    await expect(tile).toHaveCount(0);
  } finally {
    await set(was);
  }
  expect(listing(dir), 'the library folder is as it was').toEqual(before);
});

test('media screen: quality and largest size are saved and used', async ({ page }) => {
  const dir = path.join(IMG, 'media');
  const before = listing(dir);
  await page.goto(`${H}&action=media`);
  await mediaIdle(page);
  const quality = page.locator('#mt-ml-quality');
  const edge = page.locator('#mt-ml-maxedge');
  const was = { quality: await quality.inputValue(), edge: await edge.inputValue() };
  const pick = async (select, value) => {
    if ((await select.inputValue()) === value) return;
    const saved = jsonFrom(page, 'settings');
    await select.selectOption(value);
    return (await saved).json();
  };
  const token = () => page.evaluate(() => JSON.parse(document.getElementById('mt-ml-data').textContent).token);
  try {
    expect((await pick(quality, '70')).quality, 'the answer carries the saved quality').toBe(70);
    expect((await pick(edge, '1600')).maxEdge).toBe(1600);
    await page.reload();
    await mediaIdle(page);
    await expect(quality, 'quality survives a reload').toHaveValue('70');
    await expect(edge, 'so does the largest size').toHaveValue('1600');

    // A value that is not one of the choices is refused and changes nothing.
    const bad = await page.request.post(`${H}&action=media&sub=settings`, {
      form: { collection: 'library', quality: '5', token: await token() }, headers: { 'X-Requested-With': 'XMLHttpRequest' },
    });
    expect(bad.status(), 'quality 5 is not offered').toBe(422);
    await page.reload();
    await mediaIdle(page);
    await expect(quality).toHaveValue('70');

    // An upload is scaled to the size that was set. (The optimise switch is
    // on by default; the test above restores it.)
    const big = Buffer.from(await page.evaluate(async () => {
      const c = document.createElement('canvas');
      c.width = 2400; c.height = 1200;
      const g = c.getContext('2d');
      for (let i = 0; i < 300; i++) {
        g.fillStyle = `hsl(${(i * 61) % 360} 75% ${25 + (i * 17) % 55}%)`;
        g.fillRect((i * 173) % 2400, (i * 89) % 1200, 60 + (i * 29) % 300, 40 + (i * 23) % 200);
      }
      const blob = await new Promise(r => c.toBlob(r, 'image/jpeg', 0.97));
      return Array.from(new Uint8Array(await blob.arrayBuffer()));
    }));
    const uploaded = jsonFrom(page, 'upload');
    await page.locator('#mt-ml-file').setInputFiles({ name: 'e2e-wide.jpg', mimeType: 'image/jpeg', buffer: big });
    const up = await (await uploaded).json();
    expect(up.optimized, JSON.stringify(up)).toBe(true);
    expect([up.item.w, up.item.h], 'scaled to 1600 on its longest side').toEqual([1600, 800]);
    await mediaIdle(page);

    await page.locator(`.mt-ml-tile[data-name="${up.item.name}"]`).click();
    await page.locator('#mt-ml-detail .mt-ml-del').click();
    const deleted = jsonFrom(page, 'delete');
    await page.locator('#mt-ml-dialog-yes').click();
    expect((await (await deleted).json()).deleted).toBe(1);
  } finally {
    await page.goto(`${H}&action=media`);
    await mediaIdle(page);
    await pick(quality, was.quality);
    await pick(edge, was.edge);
  }
  expect(listing(dir), 'the library folder is as it was').toEqual(before);
});

test('a signed-in admin still needs the CSRF token', async ({ page }) => {
  // Another site cannot make an admin's browser do this: it has no token.
  await page.goto(`${H}&action=branding`);
  for (const [sub, form, extra] of [
    ['action=media&sub=list', { collection: 'library', token: 'not-the-token' }, { 'X-Requested-With': 'XMLHttpRequest' }],
    ['action=media&sub=delete', { collection: 'library', 'name[]': 'x.png' }, { 'X-Requested-With': 'XMLHttpRequest' }],
    ['action=media&sub=rename', { collection: 'library', name: 'x.png', label: 'x' }, { 'X-Requested-With': 'XMLHttpRequest' }],
    ['action=media&sub=optimize', { collection: 'library', name: 'x.png', token: 'not-the-token' }, { 'X-Requested-With': 'XMLHttpRequest' }],
    ['action=media&sub=restore', { collection: 'library', name: 'x.png' }, { 'X-Requested-With': 'XMLHttpRequest' }],
    ['action=media&sub=settings', { collection: 'library', optimize: '0', token: 'not-the-token' }, { 'X-Requested-With': 'XMLHttpRequest' }],
    ['action=branding&sub=upload-ajax', { field: 'logo_light', token: 'not-the-token' }, {}],
    ['action=branding&sub=remove-ajax', { field: 'logo_light' }, {}],
  ]) {
    const res = await page.request.post(`${H}&${sub}`, { form, headers: extra, maxRedirects: 0 });
    expect(res.status(), `${sub} without a valid token`).toBe(403);
    expect((await res.json()).ok).toBe(false);
  }
});
