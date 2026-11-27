// AD-L Cross-cutting admin features (tests/FEATURES.md AD-89, AD-94, AD-95,
// AD-96): the migration self-heal on the Menu, Pages and Sitemap screens, the
// "docs" and "Learn more" links landing on real headings in the built docs,
// the Addons-menu flyout listing the same sections as Hadrian's top nav, and
// the bridge the Page Builder uses to tell the Media screen where its images
// are used (MediaUsage::register).
//
// What these tests change and put back: a hadrian_migrations row (put back by
// the Menu screen itself, and by useAuditBackup() in any case), one built page
// and its library image (deleted again), and sitemap.xml / robots.txt, which
// the Pages and Sitemap screens may refresh (copied before, put back after).

import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import { spawnSync } from 'node:child_process';
import { test, db, php, settings, useAuditBackup, adminUrl, HADRIAN, noErrorText } from './harness.mjs';
import { PHP, TESTS_DIR, REPO_ROOT, WHMCS_ROOT } from '../../lib/env.mjs';

useAuditBackup();
test.beforeEach(() => { settings.snapshot(); });
test.afterEach(() => { settings.restore(); });

const ROOT_FILES = [path.join(WHMCS_ROOT, 'sitemap.xml'), path.join(WHMCS_ROOT, 'robots.txt')];
let rootFiles = [];
test.beforeAll(() => {
  rootFiles = ROOT_FILES.map(f => (fs.existsSync(f) ? { f, bytes: fs.readFileSync(f), st: fs.statSync(f) } : { f, bytes: null }));
});
test.afterAll(() => {
  for (const r of rootFiles) {
    if (r.bytes) { fs.writeFileSync(r.f, r.bytes); fs.utimesSync(r.f, r.st.atime, r.st.mtime); }
    else if (fs.existsSync(r.f)) fs.unlinkSync(r.f);
  }
});

// ------------------------------------------------------------ local helper

const HELPER = path.join(os.tmpdir(), 'hadrian-audit-l-cross-helper.php');
const HELPER_PHP = String.raw`<?php
declare(strict_types=1);
require_once $argv[1];
hadrian_site_lock_guard('l-cross.audit.mjs helper');
$root = getenv('WHMCS_ROOT') ?: 'C:/laragon/www/whmcs';
chdir($root);
require_once $root . '/init.php';
use WHMCS\Database\Capsule as DB;
$sys = (string) DB::table('tblconfiguration')->where('setting', 'SystemURL')->value('value');
if (!preg_match('~^https?://(localhost|127\.0\.0\.1)([:/]|$)~i', $sys)) { fwrite(STDERR, "REFUSING: not a local install\n"); exit(2); }
$cmd = json_decode((string) $argv[2], true);
$out = null;
switch ($cmd['do'] ?? '') {
    case 'migrations':
        $out = DB::table('hadrian_migrations')->orderBy('id')->get(['name', 'ran_at'])->all();
        break;
    case 'forget-migration':
        // Make one migration pending again: drop its row, nothing else.
        $out = DB::table('hadrian_migrations')->where('name', (string) $cmd['name'])->delete();
        break;
    case 'put-migration':
        // Put a row back as it was, if it is still missing.
        if (!DB::table('hadrian_migrations')->where('name', (string) $cmd['name'])->exists()) {
            DB::table('hadrian_migrations')->insert(['name' => (string) $cmd['name'], 'ran_at' => (string) $cmd['ran_at']]);
            $out = 'inserted';
        } else {
            $out = 'present';
        }
        break;
    case 'pending':
        require_once $root . '/modules/addons/Hadrian/autoload.php';
        $out = (new Hadrian\Database\Migrator($root . '/modules/addons/Hadrian'))->pending();
        break;
    case 'location-enum':
        $col = DB::select("SHOW COLUMNS FROM hadrian_menus LIKE 'location'");
        $out = $col ? (string) $col[0]->Type : null;
        break;
    case 'drop-built-page':
        // Cleanup for the page builder.php seed made: the row and its
        // registry row, nothing else.
        $id = (int) $cmd['id'];
        $out = [
            'page' => DB::table('hadrian_builder_pages')->where('id', $id)->delete(),
            'registry' => DB::table('hadrian_pages')->where('page', 'built-' . $id)->delete(),
        ];
        // And its image, if a failed test left it in the library.
        $img = (string) ($cmd['image'] ?? '');
        if (preg_match('/^[0-9a-f]{32}\.png$/', $img)) {
            require_once $root . '/modules/addons/Hadrian/autoload.php';
            $file = Hadrian\Helpers\MediaLibrary::file($img);
            if ($file !== null) { unlink($file['path']); }
            Hadrian\Helpers\MediaLibrary::forget('library', $img);
            $out['image'] = $file !== null ? 'removed' : 'already gone';
        }
        break;
    default:
        fwrite(STDERR, "unknown command\n"); exit(1);
}
echo json_encode($out, JSON_UNESCAPED_SLASHES), "\n";
`;
function helper(cmd) {
  fs.writeFileSync(HELPER, HELPER_PHP);
  const r = spawnSync(PHP, [HELPER, path.join(TESTS_DIR, 'php', 'site-lock.php'), JSON.stringify(cmd)], { encoding: 'utf8', timeout: 120_000, env: process.env });
  if (r.status !== 0) throw new Error(`helper ${cmd.do} exited ${r.status}:\n${r.stdout}${r.stderr}`);
  return JSON.parse(r.stdout.trim().split('\n').pop());
}

const SETUP_NOTICE = '.mt-alert', NOTICE_TEXT = /Setup is not finished/;
const setupNotice = async page => (await page.locator(SETUP_NOTICE).filter({ hasText: NOTICE_TEXT }).count()) > 0;

// ------------------------------------------------------------------- AD-89

const MIGRATION = 'MenusAddFooterSecondary';   // an ALTER that sets the enum it already has: safe to run again

for (const screen of ['menu', 'pages', 'sitemap']) {
  test(`AD-89 A pending migration is applied by opening the ${screen === 'menu' ? 'Menu' : screen === 'pages' ? 'Pages' : 'Sitemap'} screen`, async ({ admin, proof }) => {
    const label = screen[0].toUpperCase() + screen.slice(1);
    proof.claim(`The ${label} screen runs the Migrator on every visit: a migration whose row is missing from hadrian_migrations runs again and is recorded, and the "Setup is not finished" notice goes away.`);
    const rows0 = helper({ do: 'migrations' });
    const row0 = rows0.find(r => r.name === MIGRATION);
    proof.check(`set up: ${MIGRATION} is recorded as run`, !!row0, rows0.map(r => r.name));
    proof.equal('set up: nothing is pending', helper({ do: 'pending' }), []);
    try {
      proof.step(`Make ${MIGRATION} pending: delete its hadrian_migrations row (put back at the end)`);
      helper({ do: 'forget-migration', name: MIGRATION });
      proof.equal(`the Migrator now lists ${MIGRATION} as pending`, helper({ do: 'pending' }), [MIGRATION]);

      proof.step('Open the Branding screen (which does not migrate)');
      await admin.goto(adminUrl('branding'));
      proof.check('every Hadrian screen now says "Setup is not finished"', await setupNotice(admin));
      await proof.shot(admin, 'Branding with the setup notice');
      proof.equal('opening Branding did not run it', helper({ do: 'pending' }), [MIGRATION]);

      proof.step(`Open the ${label} screen`);
      await admin.goto(adminUrl(screen));
      await noErrorText(admin, proof, `${label} screen`);
      const rows1 = helper({ do: 'migrations' });
      const row1 = rows1.find(r => r.name === MIGRATION);
      proof.value(`hadrian_migrations.${MIGRATION}`, null, row1 || null);
      proof.check(`${MIGRATION} is recorded again`, !!row1, rows1.map(r => r.name));
      proof.check('with a later ran_at than before, so it ran on this visit', row1 && row1.ran_at > row0.ran_at, { before: row0.ran_at, after: row1?.ran_at });
      proof.equal('nothing is pending any more', helper({ do: 'pending' }), []);
      proof.check('the hadrian_menus.location enum still has footer-secondary', /'footer-secondary'/.test(helper({ do: 'location-enum' }) || ''));
      proof.check(`the ${label} screen shows no setup notice`, !(await setupNotice(admin)));
      await proof.shot(admin, `${label} screen after the self-heal`);
      await admin.goto(adminUrl('branding'));
      proof.check('the notice is gone from the other screens too', !(await setupNotice(admin)));
    } finally {
      helper({ do: 'put-migration', name: MIGRATION, ran_at: row0.ran_at });
    }
    proof.limit('The footer-menu re-seed on client pages when no footer menu exists is not exercised (it would need every footer menu deleted).');
  });
}

// ------------------------------------------------------------------- AD-94

const DOCS = path.join(REPO_ROOT, 'hadrian-documentation');
const DIST = path.join(DOCS, 'dist', 'client-theme');
const DOCS_BASE = 'https://docs.hadrianthegreat.com/client-theme/';

function newest(dir) {
  let t = 0;
  for (const e of fs.readdirSync(dir, { withFileTypes: true })) {
    const p = path.join(dir, e.name);
    t = Math.max(t, e.isDirectory() ? newest(p) : fs.statSync(p).mtimeMs);
  }
  return t;
}

/** Does the built article have a heading with this id? */
function headingIn(article, anchor) {
  const file = path.join(DIST, article, 'index.html');
  if (!fs.existsSync(file)) return { file: false, heading: false };
  if (!anchor) return { file: true, heading: true };
  const html = fs.readFileSync(file, 'utf8');
  const esc = anchor.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
  return { file: true, heading: new RegExp(`<h[1-6][^>]*\\sid="${esc}"`).test(html) };
}

test('AD-94 The "docs" and "Learn more" links on Settings, Branding and Media land on headings in the built docs', async ({ admin, proof }) => {
  proof.claim('Every docs link (includes/doclink.tpl) and every tip "Learn more" link (includes/tip.tpl) on the Settings, Branding and Media screens points at an article in the built docs and, where it names an anchor, at a heading with that id.');
  const srcNewest = newest(path.join(DOCS, 'content', 'client-theme'));
  const builtOldest = Math.min(...fs.readdirSync(DIST).filter(d => fs.existsSync(path.join(DIST, d, 'index.html'))).map(d => fs.statSync(path.join(DIST, d, 'index.html')).mtimeMs));
  proof.check('the built docs are newer than every docs source file (not stale)', builtOldest >= srcNewest,
    `oldest built page ${new Date(builtOldest).toISOString()}, newest source ${new Date(srcNewest).toISOString()}`);

  const links = [];
  for (const screen of ['settings', 'branding', 'media']) {
    await admin.goto(adminUrl(screen));
    const found = await admin.evaluate(() => [
      ...[...document.querySelectorAll('#mt-admin-root a.mt-doclink')].map(a => ({ kind: 'docs', href: a.getAttribute('href') })),
      ...[...document.querySelectorAll('#mt-admin-root .mt-tip[data-tip-href]')].map(b => ({ kind: 'Learn more', href: b.getAttribute('data-tip-href') })),
    ]);
    proof.check(`the ${screen} screen has doc links`, found.length > 0, `${found.length}`);
    for (const l of found) links.push({ ...l, screen });
  }

  proof.step('On Settings, hover a tip that has a doc link and read its popup');
  await admin.goto(adminUrl('settings'));
  const tip = admin.locator('.mt-tip[data-tip-href]:visible').first();
  const tipHref = await tip.getAttribute('data-tip-href');
  await tip.hover();
  const learn = admin.locator('.mt-tip-pop .mt-tip-link');
  await learn.waitFor({ state: 'visible' });
  proof.equal('the popup shows "Learn more"', (await learn.innerText()).trim(), 'Learn more');
  proof.equal('pointing at the tip\'s docs address', await learn.getAttribute('href'), tipHref);
  await proof.shot(admin.locator('.mt-tip-pop'), 'tip popup with Learn more');

  const uniq = [...new Map(links.map(l => [l.href, l])).values()];
  const bad = [];
  for (const l of uniq) {
    if (!l.href.startsWith(DOCS_BASE)) { bad.push(`${l.screen} ${l.kind}: ${l.href} (not under the docs base)`); continue; }
    const [p, anchor = ''] = l.href.slice(DOCS_BASE.length).split('#');
    const article = p.replace(/\/$/, '');
    const h = headingIn(article, anchor);
    if (!h.file) bad.push(`${l.screen} ${l.kind}: ${l.href} (no built article "${article}")`);
    else if (!h.heading) bad.push(`${l.screen} ${l.kind}: ${l.href} (no heading id="${anchor}" in ${article})`);
  }
  proof.note(`${uniq.length} distinct links checked (${links.length} on the three screens): ${uniq.map(l => l.href.slice(DOCS_BASE.length)).join(', ')}`);
  proof.equal('every link lands on an article and a heading that exist', bad, []);
  proof.limit('"Every setting has a docs heading" (the other half of AD-94) is a static source check, covered by tests/static/check-settings-doc-coverage.php, not repeated here.');
});

// ------------------------------------------------------------------- AD-95

test('AD-95 The Addons > Hadrian flyout lists the same sections as Hadrian\'s top nav, and its links work', async ({ admin, proof }) => {
  proof.claim('On any admin page, Addons > Hadrian opens a flyout with Hadrian\'s sections and its extension modules, the same set and addresses as the top nav on Hadrian\'s own screens; Hadrian\'s admin CSS is inlined in the head of Hadrian\'s screens only.');
  const actionOf = href => { try { return new URL(href, 'http://x/admin/').searchParams.get('action') || 'index'; } catch { return null; } };
  const moduleOf = href => { try { return new URL(href, 'http://x/admin/').searchParams.get('module'); } catch { return null; } };

  await admin.goto(adminUrl('branding'));
  const top = await admin.locator('.mt-topnav-item').evaluateAll(as => as.map(a => ({ label: a.textContent.trim(), href: a.getAttribute('href') })));
  // The HTML parser turns CRLF into LF, so compare with newlines normalised.
  const lf = s => s.replace(/\r\n?/g, '\n').trim();
  const css = await admin.evaluate(() => { const s = document.querySelector('head style#mt-admin-css'); return s ? s.textContent : ''; });
  const cssFile = fs.readFileSync(path.join(REPO_ROOT, 'hadrian', 'modules', 'addons', 'Hadrian', 'views', 'adminarea', 'assets', 'css', 'admin.css'), 'utf8');
  proof.check('Hadrian\'s screen carries <style id="mt-admin-css"> in the head, holding admin.css as it is on disk', lf(css) === lf(cssFile) && css.length > 1000, `${lf(css).length} chars inline, admin.css ${lf(cssFile).length}`);

  proof.step('Open a WHMCS admin page outside Hadrian (Clients), hover Addons, then Hadrian');
  await admin.goto('/admin/clients.php');
  proof.equal('a non-Hadrian admin page does not carry Hadrian\'s admin CSS', await admin.locator('head style#mt-admin-css').count(), 0);
  proof.equal('it does carry the flyout data and script', await admin.locator('#hn-addons-flyout-data, #hn-addons-flyout-js').count(), 2);
  const fly = admin.locator('ul.hn-addons-flyout');
  proof.equal('the flyout was built under the Addons menu', await fly.count(), 1);
  const items = await fly.locator(':scope > li > a').evaluateAll(as => as.map(a => ({ label: a.textContent.trim(), href: a.href, head: a.parentElement.classList.contains('hn-flyout-head') })));
  await admin.locator('#Menu-Addons').hover();
  await admin.locator('#Menu-Addons').locator('xpath=..').locator('a[href$="addonmodules.php?module=Hadrian"]:not(.hn-addons-flyout a)').hover();
  const shown = await fly.isVisible();
  await proof.shot(admin, 'Addons > Hadrian flyout open');
  proof.check('hovering Addons > Hadrian shows the flyout', shown);

  // Hadrian's own sections: label and action must match, as a set.
  const own = l => moduleOf(l.href) === 'Hadrian';
  const topOwn = top.filter(own).map(l => `${l.label} -> ${actionOf(l.href)}`).sort();
  const flyOwn = items.filter(l => own(l) && l.label !== 'Open Hadrian').map(l => `${l.label} -> ${actionOf(l.href)}`).sort();
  proof.note(`top nav: ${topOwn.join(', ')}`);
  proof.note(`flyout: ${flyOwn.join(', ')}`);
  proof.equal('the flyout lists exactly Hadrian\'s top-nav sections, with the same addresses', flyOwn, topOwn);
  // Extension tabs: every module tab in the top nav is in the flyout, by address.
  const topExt = top.filter(l => !own(l)).map(l => l.href.replace(/^\?/, '')).sort();
  const flyExt = items.filter(l => !own(l)).map(l => (l.href.split('?')[1] || '')).sort();
  proof.check('every extension tab in the top nav is in the flyout', topExt.every(h => flyExt.includes(h)), { topExt, flyExt });
  proof.equal('"Open Hadrian" heads the flyout and goes to the Hadrian landing page', [items[0]?.label, moduleOf(items[0]?.href), actionOf(items[0]?.href)], ['Open Hadrian', 'Hadrian', 'index']);

  proof.step('Click "Media" in the flyout');
  await Promise.all([admin.waitForURL(/action=media/), fly.locator('a', { hasText: /^Media$/ }).click()]);
  proof.equal('it opens Hadrian\'s Media screen, with the Media tab active', (await admin.locator('.mt-topnav-item.is-active').innerText()).trim(), 'Media');
  proof.limit('The flyout\'s narrow-screen tap toggle is not exercised.');
});

// ------------------------------------------------------------------- AD-96

test('AD-96 MediaUsage::register: an image a built page uses shows as used on the Media screen and needs "Delete anyway"', async ({ admin, proof }) => {
  proof.claim('The Page Builder registers its pages with Hadrian (Bridge::registerMediaSource -> MediaUsage::register), so an image placed on a built page is listed under "Used in" on Hadrian\'s Media screen, left out of "Unused", and warned about before a delete.');
  proof.step('Set up: make a draft built page holding one new library image (tests/php/builder.php seed)');
  const seed = php('builder.php', 'seed', 'E2E Audit Bridge Page');
  proof.check('the seed made a page and an image', seed && seed.id > 0 && /^[0-9a-f]{32}\.png$/.test(seed.image || ''), seed);
  const REL = `templates/hadrian/assets/img/media/${seed.image}`;
  try {
    proof.equal('the image is on disk', db.file(REL).exists, true);

    proof.step('Open the Media screen and the image\'s details');
    await admin.goto(adminUrl('media'));
    await admin.waitForFunction(() => window.hadrianMedia && window.hadrianMedia.idle());
    const t = admin.locator(`.mt-ml-tile[data-name="${seed.image}"]`);
    await t.waitFor();
    proof.equal('the tile carries no "Unused" flag', await t.locator('.mt-ml-flag').count(), 0);
    await admin.locator('#mt-ml-show [data-show="unused"]').click();
    proof.equal('"Unused" leaves it out', await t.count(), 0);
    await admin.locator('#mt-ml-show [data-show="used"]').click();
    proof.equal('"In use" shows it', await t.count(), 1);
    await t.click();
    const used = admin.locator('#mt-ml-detail .mt-ml-usedlist a');
    const where = (await used.allInnerTexts()).map(s => s.trim());
    const href = await used.first().getAttribute('href');
    proof.check('"Used in" names the built page', where.includes('Built page "E2E Audit Bridge Page"'), where);
    proof.check('and links into the Page Builder editor for it', new RegExp(`module=HadrianBuilder.*action=edit.*id=${seed.id}\\b`).test(href || ''), href);
    await proof.shot(admin.locator('#mt-ml-side'), 'details naming the built page');

    proof.step('Press Delete image; read the dialog; press Delete anyway');
    await admin.locator('#mt-ml-detail .mt-ml-del').click();
    const dialog = admin.locator('#mt-ml-dialog');
    const text = await dialog.innerText();
    proof.check('the dialog warns it is in use on the built page', text.includes('This image is in use') && text.includes('Built page "E2E Audit Bridge Page"'), text);
    await proof.shot(dialog.locator('.mt-modal-card'), 'delete warning naming the built page');
    const del = admin.waitForResponse(r => r.url().includes('sub=delete') && r.request().method() === 'POST');
    await admin.locator('#mt-ml-dialog-yes', { hasText: 'Delete anyway' }).click();
    proof.equal('the forced delete answers "deleted"', (await (await del).json()).results[seed.image], 'deleted');
    proof.equal('the image is gone from disk', db.file(REL).exists, false);
  } finally {
    const dropped = helper({ do: 'drop-built-page', id: seed.id, image: seed.image });
    proof.note(`cleanup: removed the seeded page (${JSON.stringify(dropped)})`);
  }
  proof.limit('Only MediaUsage::register is proven here; the other bridge functions in the AD-96 row (Extensions, ExtensionPages, SiteLook, LocaleHelper, Menu::pick, TreeRenderer, Settings::getValue) are left to builder.spec / email.spec.');
});
