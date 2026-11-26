// Confirmed bugs from tests/FEATURES.md ("Bugs found while building this
// list"), each written as the test it should pass once fixed.
//
// Every test first checks that its scenario was set up (a failure there fails
// the run like any other test), then calls test.fail() and asserts what the
// code SHOULD do. run.mjs reports an expected failure as a known issue, so an
// open bug never blocks the pre-push gate; when a fix makes the assertion
// pass, the run fails until the test.fail() line is removed, and the test
// stays behind as a regression test.
//
// Bugs 3, 6 and 7 need no site: tests/static/test-extension-page-rows.php,
// tests/e2e/colour-scope.spec.mjs and tests/static/check-root-paths.mjs.
// Bugs 1 and 2 are fixed; their tests moved to tests/php/email-live.php
// ("a saved edit stays a draft until it is published"). Bugs 4, 5 and 8 are
// fixed; their tests below stay as regression tests, with no test.fail().
//
// Settings project, one worker: these rename the live guest menu and save
// page settings, which every other tier would see.

import { test, expect } from '@playwright/test';
import { execFileSync, spawnSync } from 'node:child_process';
import path from 'node:path';
import { PHP, TESTS_DIR } from '../lib/env.mjs';
import { loginAdmin } from './helpers.mjs';

const HADRIAN = '/admin/addonmodules.php?module=Hadrian';

/** tests/php/known-bugs.php: sets a scenario up and reports what happened. */
const drive = (...args) => {
  const r = spawnSync(PHP, [path.join(TESTS_DIR, 'php', 'known-bugs.php'), ...args], { encoding: 'utf8', timeout: 120_000 });
  if (r.status !== 0) throw new Error(`known-bugs.php ${args[0]} could not set the scenario up (exit ${r.status}):\n${r.stdout}${r.stderr}`);
  return JSON.parse(r.stdout.trim().split('\n').pop());
};
const settings = (...args) => execFileSync(PHP, [path.join(TESTS_DIR, 'php', 'settings.php'), ...args], { encoding: 'utf8' });
const json = s => { try { return JSON.parse(s); } catch { return null; } };

// ------------------------------------------------------------------- bug 4
// Fixed 2026-11-25. PagesController cut SEO text at 200 and 400 BYTES; a cut
// inside a character made json_encode() fail and the column was stored as
// "0", losing the text for every language. It now cuts by characters.
test('long SEO text in Japanese survives Save in Pages (bug 4)', async ({ page }) => {
  await loginAdmin(page.context().request);
  settings('snapshot');
  try {
    const editor = `${HADRIAN}&action=pages&sub=edit&page=contact`;
    await page.goto(editor);
    const desc = page.locator('textarea[name^="seo_description["]').first();
    const lang = (await desc.getAttribute('name')).match(/\[(.+)\]/)[1];
    const title = page.locator(`input[name="seo_title[${lang}]"]`);
    const text = 'お問い合わせページの説明文です。検索結果に表示されます。'.repeat(20);
    // The description as far as its box lets an admin type: 160 characters, 480 bytes.
    const typedDesc = text.slice(0, Number(await desc.getAttribute('maxlength')) || 160);
    // A title longer than the server keeps, as a form posted without the
    // browser's maxlength sends it: 250 characters, 750 bytes.
    const typedTitle = text.slice(0, 250);
    expect(Buffer.byteLength(typedDesc), 'longer than the old 400-byte cut').toBeGreaterThan(400);

    // The boxes can sit in a hidden language tab; set them the way typing would.
    for (const [el, v] of [[desc, typedDesc], [title, typedTitle]]) {
      await el.evaluate((n, val) => { n.value = val; n.dispatchEvent(new Event('input', { bubbles: true })); }, v);
    }
    await Promise.all([page.waitForURL(/flash=saved/), desc.evaluate(el => el.form.requestSubmit())]);
    const row = drive('page-row', 'contact');
    expect(json(row.seo_description)?.[lang], `the whole description is stored (column holds ${JSON.stringify(row.seo_description)})`).toBe(typedDesc);
    expect(json(row.seo_title)?.[lang], 'the title is stored, cut at 200 characters').toBe(typedTitle.slice(0, 200));

    // Back in the editor, the counter counts characters, not bytes.
    await page.goto(editor);
    const counter = desc.locator('xpath=ancestor::div[contains(@class,"mt-field")][1]//span[contains(@class,"mt-charcount")]');
    await expect(counter).toHaveText(`${typedDesc.length}/160`);
  } finally {
    settings('restore');
  }
});

// ------------------------------------------------------------------- bug 5
// Fixed 2026-11-25. The seeder finds presets by name, so on every visit to the
// Menu screen a renamed preset was created again, active, and Menu::pick()
// served the copy instead of the admin's menu. It now remembers the presets it
// made; only Re-seed presets brings one back, and inactive if the slot is taken.
test('a renamed preset menu stays the menu visitors see (bug 5)', async ({ page }) => {
  await loginAdmin(page.context().request);
  // The way an admin gets to the menu editor: through the Menu screen, which
  // runs the seeder and so records the presets before anything is renamed.
  await page.goto(`${HADRIAN}&action=menu`);
  const s = drive('menu-rename');
  try {
    // Opening the Menu screen runs the preset seeder (MenuController::ensureMenuTables).
    await page.goto(`${HADRIAN}&action=menu`);
    await expect(page.locator('body'), 'the Menu screen lists the renamed menu').toContainText(s.renamed);
    let now = drive('menu-state', JSON.stringify(s));
    expect(now.pickedId, `signed-out visitors get "${now.pickedName}"`).toBe(s.id);
    expect(now.copies, 'the preset was not created again').toEqual([]);

    // Asked for, the preset comes back, as the docs promise, but not live.
    await page.locator('a', { hasText: 'Re-seed presets' }).first().click();
    await expect(page).toHaveURL(/flash=seeded-/);
    now = drive('menu-state', JSON.stringify(s));
    expect(now.copies.length, 'Re-seed presets brings the shipped preset back').toBe(1);
    expect(now.activeCopies, '...switched off, because the slot has a live menu').toBe(0);
    expect(now.pickedId, `...so visitors still get the renamed menu, not "${now.pickedName}"`).toBe(s.id);
  } finally {
    const back = drive('menu-restore', JSON.stringify(s));
    expect(back.restored, `the guest main menu was put back: ${JSON.stringify(back)}`).toBe(true);
  }
});

// ------------------------------------------------------------------- bug 8
test('the homepage hero shows the title and subtitle set in Pages (bug 8)', async ({ request }) => {
  settings('snapshot');
  try {
    const title = 'Hero title set by a test';
    const subtitle = 'Hero subtitle <i>set</i> by a test';
    settings('page', JSON.stringify({ homepage: { variant: 'default', settings: { options: { heroTitle: title, heroSubtitle: subtitle } } } }));
    const res = await request.get('/index.php');
    expect(res.status()).toBe(200);
    const html = await res.text();
    expect(html, 'the Modern homepage rendered for a guest').toMatch(/<body[^>]*data-tpl="homepage"/);

    // Fixed 2026-11-25: the template read .config.*, which is never built.
    expect(html, 'the hero title').toMatch(new RegExp(`<h1>${title}</h1>`));
    expect(html, 'the hero subtitle, printed as text').toContain('Hero subtitle &lt;i&gt;set&lt;/i&gt; by a test');
    expect(html, 'the subtitle is not printed as markup').not.toContain(subtitle);

    // Classic reads the same two settings (since 2026-11-25).
    settings('page', JSON.stringify({ homepage: { variant: 'portal' } }));
    const classic = await (await request.get('/index.php')).text();
    expect(classic, 'the Classic homepage rendered').toContain('class="ph-hero"');
    expect(classic, 'the Classic hero title').toMatch(new RegExp(`<h1>${title}</h1>`));
    expect(classic, 'the Classic hero subtitle, printed as text').toContain('<p>Hero subtitle &lt;i&gt;set&lt;/i&gt; by a test</p>');
  } finally {
    settings('restore');
  }
});
