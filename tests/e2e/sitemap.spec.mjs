// Tier 3c (sitemap) - sitemap.xml and robots.txt, the files Hadrian keeps in
// the WHMCS root.
//
// Three things are checked:
//   - what the files list, and when they are rewritten, against rows made for
//     the purpose (tests/php/sitemap.php check): a hidden product group, a
//     translated and a private knowledgebase article, hidden categories, a
//     module's page, a new announcement. The files must follow a change
//     without anyone opening the Sitemap tab, and must not be touched when
//     nothing they list has changed, or before the site has set them up.
//   - the same through the admin: saving a page in Pages with indexing
//     switched off takes it out of sitemap.xml and into robots.txt.
//   - a built page standing in for a theme page answers at two addresses; both
//     name one canonical address, the one WHMCS sends visitors to.
//
// Runs in the `settings` project (one worker): it rewrites two files in the
// web root of the install the other tiers crawl, and puts them back.

import { test, expect } from '@playwright/test';
import { execFileSync } from 'node:child_process';
import path from 'node:path';
import { PHP, TESTS_DIR, BASE_URL } from '../lib/env.mjs';
import { loginAdmin } from './helpers.mjs';

const HADRIAN = '/admin/addonmodules.php?module=Hadrian';
const sitemap = (...args) => JSON.parse(execFileSync(PHP, [path.join(TESTS_DIR, 'php', 'sitemap.php'), ...args], { encoding: 'utf8' }).trim().split('\n').pop());

test.describe.configure({ mode: 'default' });
test.beforeEach(async ({ page }) => { await loginAdmin(page.context().request); });

test('the sitemap lists what visitors can reach, and follows changes', async () => {
  const results = sitemap('check');
  expect(results.length, 'the checks ran').toBeGreaterThan(20);
  for (const r of results) {
    expect.soft(r.ok, r.name + (r.detail ? ` (${r.detail})` : '')).toBe(true);
  }
});

test('a built page standing in for a theme page has one canonical address', async () => {
  const r = sitemap('standin');
  test.skip(!!r.skipped, r.skipped || '');

  // On its own, a built page is its own canonical address.
  expect(r.alone.status).toBe(200);
  expect(r.alone.canonical, 'not standing in: it names itself').toMatch(/\/e2e-stand-in$/);

  // Standing in for Announcements, the same content answers at two addresses.
  expect(r.own.built && r.served.built, 'both addresses show the built page').toBe(true);
  expect(r.served.canonical, 'the theme page\'s address names an address').not.toBe('');
  expect(r.own.canonical, 'and its own address names the same one, not itself').toBe(r.served.canonical);
  expect(r.own.canonical).not.toMatch(/e2e-stand-in/);
  expect(r.own.ogUrl, 'og:url agrees').toBe(r.own.canonical);

  // That address is where WHMCS itself sends a visitor, not one that redirects.
  expect(r.redirect.status, 'announcements.php only redirects').toBe(301);
  expect(r.own.canonical.endsWith(r.redirect.location), `the canonical is where it redirects to (${r.redirect.location})`).toBe(true);
});

test('saving a page in Pages rewrites sitemap.xml and robots.txt', async ({ page }) => {
  sitemap('backup');
  try {
    // The site has set its sitemap up: Save on the Sitemap tab.
    const listed = sitemap('begin');
    const target = listed.find(p => p.url && !/^built-/.test(p.page));
    expect(target, 'a theme page with an address is in the sitemap').toBeTruthy();
    const address = `${BASE_URL.replace(/\/$/, '')}/${target.url.replace(/^\//, '')}`;
    expect(sitemap('files').urls, 'it is listed to begin with').toContain(address);

    const save = async indexing => {
      await page.goto(`${HADRIAN}&action=pages&sub=edit&page=${encodeURIComponent(target.page)}`);
      const select = page.locator('select[name="indexing"]');
      const before = await select.inputValue();
      await select.selectOption(indexing);
      await Promise.all([page.waitForURL(/flash=saved/), select.evaluate(el => el.form.requestSubmit())]);
      return before;
    };

    const before = await save('disallow');
    let files = sitemap('files');
    expect(files.urls, 'switched to "Disallow indexing", it leaves the sitemap on save').not.toContain(address);
    expect(files.disallow, 'and robots.txt disallows it').toContain('/' + target.url.replace(/^\//, ''));

    await save(before);
    files = sitemap('files');
    expect(files.urls, 'set back, it is listed again').toContain(address);
    expect(files.disallow, 'and no longer disallowed').not.toContain('/' + target.url.replace(/^\//, ''));
  } finally {
    sitemap('restore');
  }
});
