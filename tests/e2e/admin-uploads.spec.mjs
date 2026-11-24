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
  'iVBORw0KGgoAAAANSUhEUgAAAAIAAAACCAYAAABytg0kAAAAEklEQVR4nGNgYPj/n4GBgQEAFgAD/0v7cCcAAAAASUVORK5CYII=',
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

test('a signed-in admin still needs the CSRF token', async ({ page }) => {
  // Another site cannot make an admin's browser do this: it has no token.
  await page.goto(`${H}&action=branding`);
  for (const [sub, form, extra] of [
    ['action=media&sub=list', { collection: 'library', token: 'not-the-token' }, { 'X-Requested-With': 'XMLHttpRequest' }],
    ['action=media&sub=delete', { collection: 'library', 'name[]': 'x.png' }, { 'X-Requested-With': 'XMLHttpRequest' }],
    ['action=branding&sub=upload-ajax', { field: 'logo_light', token: 'not-the-token' }, {}],
    ['action=branding&sub=remove-ajax', { field: 'logo_light' }, {}],
  ]) {
    const res = await page.request.post(`${H}&${sub}`, { form, headers: extra, maxRedirects: 0 });
    expect(res.status(), `${sub} without a valid token`).toBe(403);
    expect((await res.json()).ok).toBe(false);
  }
});
