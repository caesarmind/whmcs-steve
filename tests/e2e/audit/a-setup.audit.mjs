// AD-A Setup and Info (tests/FEATURES.md AD-01 to AD-10): the default landing,
// the Info page, the "Setup not finished" banner, where the version comes from,
// the Setup checklist and its four buttons (Run now, Save & check, Make Hadrian
// live, Switch back) and the preview link. Every button is pressed on the real
// Setup screen; the proof is tblconfiguration, the files on disk and what a
// guest sees.
//
// Local facts this file works with (read, not assumed, in each test):
//   - the site runs Hadrian live (Template=hadrian, OrderFormTemplate=hadrian_cart)
//   - no licence key is stored, and includes/hooks/hostnodes_theme_license.php
//     is not installed, so the checklist is blocked and "Make Hadrian live"
//     is refused. Going live for real needs an Active key from the licence
//     server, so that path is skipped below with the reason.
//
// Preconditions the screen cannot set (an earlier go-live on record, a theme
// that is not live, a fresh install) are written by a small local PHP helper
// at the bottom of this file. Every one is put back by the test that made it,
// and useAuditBackup() is the backstop.

import { test, db, php, useAuditBackup, adminUrl, submit, flashText, noErrorText, html } from './harness.mjs';
import { spawnSync } from 'node:child_process';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import { PHP, TESTS_DIR, REPO_ROOT, WHMCS_ROOT } from '../../lib/env.mjs';

useAuditBackup();

// ------------------------------------------------------------ local helpers

const HELPER = path.join(os.tmpdir(), 'hadrian-audit-a-setup-helper.php');
const HELPER_PHP = String.raw`<?php
declare(strict_types=1);
require_once $argv[1];
hadrian_site_lock_guard('a-setup.audit.mjs helper');
$root = getenv('WHMCS_ROOT') ?: 'C:/laragon/www/whmcs';
chdir($root);
require_once $root . '/init.php';
use WHMCS\Database\Capsule as DB;
$sys = (string) DB::table('tblconfiguration')->where('setting', 'SystemURL')->value('value');
if (!preg_match('~^https?://(localhost|127\.0\.0\.1)([:/]|$)~i', $sys)) { fwrite(STDERR, "REFUSING: not a local install\n"); exit(2); }
$cmd = json_decode((string) $argv[2], true);
$out = null;
switch ($cmd['do'] ?? '') {
    case 'config':
        foreach (($cmd['set'] ?? []) as $k => $v) {
            if ($v === null) { DB::table('tblconfiguration')->where('setting', $k)->delete(); }
            else { DB::table('tblconfiguration')->updateOrInsert(['setting' => $k], ['value' => (string) $v]); }
        }
        $out = [];
        foreach (($cmd['get'] ?? []) as $k) { $out[$k] = DB::table('tblconfiguration')->where('setting', $k)->value('value'); }
        break;
    case 'wipe-install':
        DB::table('hadrian_menu_items')->delete();
        DB::table('hadrian_menus')->delete();
        DB::table('hadrian_settings')->whereIn('setting', ['hadrian_menu_presets_seeded', 'hadrian_pages_discovered', 'hadrian_layouts_discovered'])->delete();
        $out = ['menus' => DB::table('hadrian_menus')->count()];
        break;
    case 'presets':
        $out = count(\Hadrian\Menu\Presets::all());
        break;
    case 'addon-version':
        $out = DB::table('tbladdonmodules')->where('module', 'Hadrian')->where('setting', 'version')->value('value');
        break;
}
echo json_encode($out, JSON_UNESCAPED_SLASHES), "\n";
`;

function helper(cmd) {
  fs.writeFileSync(HELPER, HELPER_PHP);
  const r = spawnSync(PHP, [HELPER, path.join(TESTS_DIR, 'php', 'site-lock.php'), JSON.stringify(cmd)], { encoding: 'utf8', timeout: 120_000, env: process.env });
  if (r.status !== 0) throw new Error(`local helper ${cmd.do} exited ${r.status}:\n${r.stdout}${r.stderr}`);
  return JSON.parse(r.stdout.trim().split('\n').pop());
}

const LIVE_KEYS = ['Template', 'OrderFormTemplate', 'hadrian_setup_prev_template', 'hadrian_setup_prev_orderform'];
const liveRows = () => helper({ do: 'config', get: LIVE_KEYS });
const setRows = set => helper({ do: 'config', set, get: LIVE_KEYS });

// What the file started with, so every test can be checked against it and
// put back to exactly that.
let START = null;
test.beforeAll(() => { START = liveRows(); });
test.afterEach(() => {
  const now = liveRows();
  if (JSON.stringify(now) !== JSON.stringify(START)) setRows(START);
});

/** Which client-area theme (and order form) a page was rendered with, from its asset paths. */
function themeOf(body, orderforms = false) {
  const re = orderforms ? /\/templates\/orderforms\/([A-Za-z0-9_-]+)\//g : /\/templates\/(?!orderforms\/)([A-Za-z0-9_-]+)\//g;
  const n = {};
  for (const m of body.matchAll(re)) n[m[1]] = (n[m[1]] || 0) + 1;
  const top = Object.entries(n).sort((a, b) => b[1] - a[1])[0];
  return top ? top[0] : null;
}

/** GET as this page's context; retry a truncated page (Windows Smarty right after a theme change). */
async function fetchPage(page, url) {
  let r;
  for (let i = 0; i < 4; i++) {
    r = await html(page, url);
    if (/<\/html>/i.test(r.body)) return r;
    await new Promise(res => setTimeout(res, 1500));
  }
  return r;
}

const coreVersion = () => {
  const src = fs.readFileSync(path.join(REPO_ROOT, 'hadrian', 'templates', 'hadrian', 'core', 'hadrian.php'), 'utf8');
  return src.match(/'version'\s*=>\s*'([^']+)'/)[1];
};
const addonFileVersion = () => fs.readFileSync(path.join(REPO_ROOT, 'hadrian', 'modules', 'addons', 'Hadrian', 'Hadrian.php'), 'utf8').match(/'version'\s*=>\s*'([^']+)'/)[1];

const rowState = (admin, key) => admin.locator(`[data-setup-row="${key}"]`).getAttribute('data-setup-state');
const rowDetail = async (admin, key) => (await admin.locator(`[data-setup-row="${key}"] .mt-setup-detail`).innerText()).trim();
const groupBadge = async (admin, key) => (await admin.locator(`#mt-setup-${key} .mt-section-header .mt-badge`).innerText()).trim();

// Licence-server budget, shared with k-tools.audit.mjs: at most 2 calls per run.
const BUDGET = path.join(os.tmpdir(), 'hadrian-audit-licence-calls.json');
const RUN = process.env.HADRIAN_SITE_LOCK_TOKEN || `ppid-${process.ppid}`;
const callsUsed = () => { try { const b = JSON.parse(fs.readFileSync(BUDGET, 'utf8')); return b.run === RUN ? b.count : 0; } catch { return 0; } };
const spend = n => fs.writeFileSync(BUDGET, JSON.stringify({ run: RUN, count: callsUsed() + n, at: new Date().toISOString() }));

const FAKE_KEY = 'HN-AUDIT-NOT-A-KEY';
const ADMIN_CACHE = path.join(os.tmpdir(), 'hn_admin_license_status.json');
const THEME_CACHE = path.join(os.tmpdir(), 'hn_theme_license.json');
const readMaybe = f => { try { return fs.readFileSync(f); } catch { return null; } };
const putBack = (f, bytes) => { if (bytes === null) { try { fs.unlinkSync(f); } catch {} } else fs.writeFileSync(f, bytes); };

// ------------------------------------------------------------------- AD-01

test('AD-01 The bare addon URL lands on Info while Hadrian is live', async ({ admin, proof }) => {
  proof.claim('Addons > Hadrian with no action shows Info when the theme is live and no migration is pending.');
  const rows = liveRows();
  proof.equal('the site is live on Hadrian before the test', rows.Template, 'hadrian');

  proof.step('Open addonmodules.php?module=Hadrian with no action');
  await admin.goto(adminUrl(''));
  await noErrorText(admin, proof, 'default landing');
  const title = (await admin.locator('h1.mt-page-title').first().innerText()).trim();
  proof.check('the landing page is Info', /^Info\b/.test(title), `h1: ${title}`);
  proof.check('the Info tab is the active one', (await admin.locator('.mt-topnav-item.is-active').innerText()).trim() === 'Info');
  await proof.shot(admin, 'bare addon URL while live');
});

test('AD-01 The bare addon URL lands on Setup while Hadrian is not the site theme', async ({ admin, proof }) => {
  proof.claim('While Template is another theme, the bare addon URL shows the Setup checklist instead of Info.');
  proof.step('Precondition: set Template to twenty-one (as if Hadrian had never been switched on)');
  const before = liveRows();
  const pre = setRows({ Template: 'twenty-one' });
  proof.value('Template', before.Template, pre.Template);

  await admin.goto(adminUrl(''));
  await noErrorText(admin, proof, 'default landing');
  const title = (await admin.locator('h1.mt-page-title').first().innerText()).trim();
  proof.check('the landing page is Setup', /^Setup\b/.test(title), `h1: ${title}`);
  proof.check('the Go live group says visitors see twenty-one', /twenty-one/.test(await rowDetail(admin, 'live-theme')), await rowDetail(admin, 'live-theme'));
  await proof.shot(admin, 'bare addon URL while not live');

  proof.step('Open ?action=info explicitly');
  await admin.goto(adminUrl('info'));
  proof.check('?action=info still gives Info', /^Info\b/.test((await admin.locator('h1.mt-page-title').first().innerText()).trim()));
  proof.limit('The "migrations pending" half of the rule is not driven here: it needs a Hadrian migration un-run on a live install. tests/static/test-setup.php covers the checklist side.');
});

test('AD-01 An unknown action falls back to the default landing', async ({ admin, proof }) => {
  proof.claim('?action=<anything unknown> renders the index (Info while live) instead of an error.');
  proof.step('Open ?action=audit-no-such-screen');
  await admin.goto(adminUrl('auditNoSuchScreen'));
  await noErrorText(admin, proof, 'unknown action');
  const title = (await admin.locator('h1.mt-page-title').first().innerText()).trim();
  proof.check('the unknown action renders Info', /^Info\b/.test(title), `h1: ${title}`);
  await proof.shot(admin, 'unknown action');
});

// ------------------------------------------------------------------- AD-02

test('AD-02 Info shows the theme version and the "No key" licence state', async ({ admin, proof }) => {
  proof.claim('Info shows the version from core/hadrian.php and the licence badge, key and details; with no key stored it says "No key set" and "Not set".');
  const key = db.config('hadrian_license_key');
  proof.check('no licence key is stored on this install', key === null || key === '', key ? 'a key is stored' : 'none');
  const version = coreVersion();

  await admin.goto(adminUrl('info'));
  await noErrorText(admin, proof, 'Info');
  const dd = admin.locator('.mt-deflist').first().locator('dd').first();
  const shown = (await dd.innerText()).trim();
  proof.check(`Theme Version shows ${version} (core/hadrian.php)`, shown.startsWith(version), `shown: ${shown}`);

  const lic = admin.locator('.mt-section').nth(1);
  const badge = (await lic.locator('dd').first().innerText()).trim();
  proof.equal('the licence status badge reads "No key set"', badge, 'No key set');
  const keyText = (await lic.locator('dt:has-text("License Key") + dd').innerText()).trim();
  proof.equal('the licence key reads "Not set"', keyText, 'Not set');
  for (const dt of ['Product', 'Registration Date', 'Next Due Date', 'Billing Cycle', 'Valid Domain(s)']) {
    proof.check(`no "${dt}" row without a licence reply`, (await lic.locator(`dt:text-is("${dt}")`).count()) === 0);
  }
  proof.check('no "Version ... available" badge', (await admin.locator('.mt-badge-primary:has-text("available")').count()) === 0);
  await proof.shot(admin, 'Info with no key');
  proof.note('InfoController now sets newVersion from the signed reply (latest_version vs version), so the FEATURES wording "New version flag never set" is out of date: it is set when the licence server reports a newer release. Without a server answer it stays unset, which is what this test sees.');
  proof.note('The licence badge, product, dates and domains need a signed reply. The 15-minute cache is shown in the AD-07 test: Info answered from hn_admin_license_status.json without rewriting it.');
  proof.limit('Active, Expired, Revoked and the product/date rows need a real licence-server answer and are not shown here.');
});

// ------------------------------------------------------------------- AD-03

test('AD-03 "Setup is not finished" shows on every screen but Setup while setup is open', async ({ admin, proof }) => {
  proof.claim('While setup needs attention the header says "Setup is not finished" on every Hadrian screen except Setup; once live it is gone.');
  const BANNER = '.mt-body > .mt-alert-info:has-text("Setup is not finished")';
  const screens = ['info', 'settings', 'styles', 'layouts', 'menu', 'tools', 'extensions', 'license'];

  proof.step('While live: open each screen');
  for (const s of ['info', 'settings', 'tools']) {
    await admin.goto(adminUrl(s));
    proof.check(`no banner on ${s} while live`, (await admin.locator(BANNER).count()) === 0);
  }

  proof.step('Precondition: Template = twenty-one, then open each screen and Setup');
  setRows({ Template: 'twenty-one' });
  for (const s of screens) {
    await admin.goto(adminUrl(s));
    const n = await admin.locator(BANNER).count();
    proof.check(`the banner shows on ${s}`, n === 1, `found ${n}`);
    if (s === 'settings') await proof.shot(admin, 'Settings with the banner');
  }
  const link = await admin.locator(`${BANNER} a`).getAttribute('href');
  proof.check('the banner links to Setup', /action=setup/.test(link || ''), link);
  await admin.goto(adminUrl('setup'));
  proof.check('no banner on Setup itself', (await admin.locator(BANNER).count()) === 0);
  await proof.shot(admin, 'Setup has no banner');
});

// ------------------------------------------------------------------- AD-04

test('AD-04 The header pill, Info, Setup and the discovery caches all read core/hadrian.php', async ({ admin, proof }) => {
  const v = coreVersion();
  const addonV = addonFileVersion();
  proof.claim(`Every version the admin shows, and the cache invalidation, come from core/hadrian.php (${v}); Hadrian.php's ${addonV} is not shown.`);
  proof.note(`FEATURES quotes 1.1.242 for core/hadrian.php; the file now says ${v}. Hadrian.php says ${addonV}; theme.json carries its own version too.`);

  await admin.goto(adminUrl('info'));
  const pill = (await admin.locator('.mt-brand-ver').innerText()).trim();
  proof.equal('the header pill reads v<core/hadrian.php version>', pill, `v${v}`);
  await proof.shot(admin.locator('.mt-brandbar'), 'header pill');
  proof.check('Info Theme Version reads the same', (await admin.locator('.mt-deflist dd').first().innerText()).trim().startsWith(v));

  await admin.goto(adminUrl('setup'));
  const files = await rowDetail(admin, 'theme');
  proof.equal('the Setup Files row reads "Version <core version>"', files, `Version ${v}`);
  proof.check(`Hadrian.php's ${addonV} appears nowhere on Setup or in the header`, !(await admin.locator('body').innerText()).includes(addonV));

  const stored = db.settings('hadrian_');
  const pages = JSON.parse(stored.hadrian_pages_discovered || '{}');
  const layouts = JSON.parse(stored.hadrian_layouts_discovered || '{}');
  proof.equal('the pages discovery cache is keyed to the core version', pages.version, v);
  proof.equal('the layouts discovery cache is keyed to the core version', layouts.version, v);
  const addonRow = helper({ do: 'addon-version' });
  proof.equal(`tbladdonmodules records Hadrian.php's version (${addonV}), which nothing above reads`, addonRow, addonV);
});

// ------------------------------------------------------------------- AD-05

test('AD-05 The checklist has five groups and each takes its worst row', async ({ admin, proof }) => {
  proof.claim('Setup lists Files, Requirements, Database, License and Go live, and each group badge is the worst state among its rows.');
  await admin.goto(adminUrl('setup'));
  await noErrorText(admin, proof, 'Setup');
  const groups = await admin.locator('.mt-panel > section.mt-section').evaluateAll(secs => secs.map(s => ({
    id: s.id,
    title: s.querySelector('.mt-section-title')?.textContent.trim(),
    badge: s.querySelector('.mt-section-header .mt-badge')?.textContent.trim(),
    rows: [...s.querySelectorAll('[data-setup-row]')].map(r => ({ key: r.dataset.setupRow, state: r.dataset.setupState })),
  })));
  proof.equal('the groups, in order', groups.map(g => g.title), ['Files', 'Requirements', 'Database', 'License', 'Go live']);
  const rank = { ok: 0, warn: 1, todo: 2, fail: 3 };
  const word = { ok: 'Ready', warn: 'Check', todo: 'To do', fail: 'Problem' };
  for (const g of groups) {
    const worst = g.rows.reduce((w, r) => (rank[r.state] > rank[w] ? r.state : w), 'ok');
    proof.equal(`${g.title}: badge "${g.badge}" is its worst row (${worst})`, g.badge, word[worst]);
  }
  proof.note(`Rows seen: ${groups.map(g => `${g.title}[${g.rows.map(r => `${r.key}=${r.state}`).join(', ')}]`).join(' ')}`);
  await proof.shot(admin, 'Setup checklist', { fullPage: true });
});

test('AD-05 A missing order form is a warning, not a stop', async ({ admin, proof }) => {
  test.setTimeout(300_000);
  proof.claim('With templates/orderforms/hadrian_cart gone, the Files group warns ("Check") and Go live has no order-form row.');
  const link = path.join(WHMCS_ROOT, 'templates', 'orderforms', 'hadrian_cart');
  const moved = `${link}.audit-moved`;
  proof.check('the cart folder is there before the test', fs.existsSync(link));
  await admin.goto(adminUrl('setup'));
  const before = await rowState(admin, 'cart');
  try {
    proof.step('Rename templates/orderforms/hadrian_cart aside (a junction into the repo) and reload Setup');
    fs.renameSync(link, moved);
    // mod_php's realpath cache (realpath_cache_ttl, 120 s by default) keeps
    // resolving the old junction path to its target, which still exists, so
    // Setup can read "Uploaded" for up to two minutes. Reload until it lapses.
    const t0 = Date.now();
    let after = 'ok';
    while (Date.now() - t0 < 170_000) {
      await admin.goto(adminUrl('setup'));
      after = await rowState(admin, 'cart');
      if (after !== 'ok') break;
      await admin.waitForTimeout(10_000);
    }
    proof.note(`The Order form row changed ${Math.round((Date.now() - t0) / 1000)} s after the rename (PHP realpath cache on the junction).`);
    await noErrorText(admin, proof, 'Setup without the cart');
    proof.value('Files > Order form state', before, after);
    proof.equal('the Order form row warns', after, 'warn');
    proof.check('it says the client area can go live without it', /can go live without it/.test(await rowDetail(admin, 'cart')), await rowDetail(admin, 'cart'));
    proof.check('the Go live group has no order-form row', (await admin.locator('[data-setup-row="live-cart"]').count()) === 0);
    await proof.shot(admin.locator('#mt-setup-files'), 'Files without the cart');
  } finally {
    if (!fs.existsSync(link) && fs.existsSync(moved)) fs.renameSync(moved, link);
  }
  proof.check('the cart folder is back', fs.existsSync(path.join(link, 'checkout.tpl')));
});

test('AD-05 Folders from different releases are a problem', async ({ admin, proof }) => {
  proof.claim('When one folder carries a release.json mark and the others carry another (or none), Files shows a Release row in "Problem".');
  const mark = path.join(REPO_ROOT, 'hadrian', 'templates', 'hadrian', 'release.json');
  proof.check('the theme folder has no release.json (a source checkout)', !fs.existsSync(mark));
  await admin.goto(adminUrl('setup'));
  proof.check('no Release row on an unmarked checkout', (await admin.locator('[data-setup-row="release"]').count()) === 0);
  try {
    proof.step('Write templates/hadrian/release.json with {"release":"9.9.9-audit"} and reload Setup');
    fs.writeFileSync(mark, JSON.stringify({ release: '9.9.9-audit' }));
    await admin.goto(adminUrl('setup'));
    proof.equal('the Release row is a problem', await rowState(admin, 'release'), 'fail');
    const d = await rowDetail(admin, 'release');
    proof.check('it names each folder and its mark', /theme 9\.9\.9-audit/.test(d) && /order form unmarked/.test(d) && /addon unmarked/.test(d), d);
    proof.equal('the Files group reads Problem', await groupBadge(admin, 'files'), 'Problem');
    await proof.shot(admin.locator('#mt-setup-files'), 'mismatched release');
  } finally {
    try { fs.unlinkSync(mark); } catch {}
  }
  proof.check('release.json is removed again', !fs.existsSync(mark));
});

// ------------------------------------------------------------------- AD-06

test('AD-06 Run now creates the menus, caches and upload .htaccess, then redirects to done=installed', async ({ admin, proof }) => {
  proof.claim('On an install missing its menus, discovery caches and branding .htaccess, Run now creates all of them and confirms with done=installed.');
  const hta = path.join(WHMCS_ROOT, 'templates', 'hadrian', 'assets', 'img', 'branding', '.htaccess');
  const htaBytes = readMaybe(hta);
  const presets = helper({ do: 'presets' });
  try {
    proof.step('Precondition: delete every menu, the preset record and both discovery caches; move the branding .htaccess aside');
    helper({ do: 'wipe-install' });
    if (htaBytes) fs.unlinkSync(hta);
    const menusBefore = db.menus().length;
    const cacheBefore = db.settings('hadrian_');
    proof.equal('no menus before', menusBefore, 0);
    proof.check('no discovery caches before', !cacheBefore.hadrian_pages_discovered && !cacheBefore.hadrian_layouts_discovered);
    proof.check('no branding .htaccess before', !fs.existsSync(hta));

    await admin.goto(adminUrl('setup'));
    proof.equal('Database > Default menus is "To do"', await rowState(admin, 'menus'), 'todo');
    const btn = admin.locator('#mt-setup-database button:has-text("Run now")');
    proof.check('the Run now button is offered', (await btn.count()) === 1);
    await proof.shot(admin.locator('#mt-setup-database'), 'Database before Run now');

    proof.step('Press Run now');
    await submit(admin, btn);
    proof.check('the screen redirected to done=installed', /[?&]done=installed\b/.test(admin.url()), admin.url());
    const flash = await flashText(admin);
    proof.check('it says "The database is up to date."', /The database is up to date\./.test(flash), flash);
    await proof.shot(admin, 'Setup after Run now');

    const menus = db.menus();
    proof.value('menus', menusBefore, menus.length);
    proof.equal(`every preset menu was created (${presets})`, menus.length, presets);
    proof.check('the presets have items', menus.every(m => m.items > 0), menus.map(m => `${m.name}:${m.items}`).join(', '));
    const cacheAfter = db.settings('hadrian_');
    const pages = JSON.parse(cacheAfter.hadrian_pages_discovered || '{}');
    const layouts = JSON.parse(cacheAfter.hadrian_layouts_discovered || '{}');
    proof.value('hadrian_pages_discovered pages', null, (pages.pages || []).length);
    proof.check('the pages cache was rebuilt for this version', pages.version === coreVersion() && (pages.pages || []).length > 0);
    proof.check('the layouts cache was rebuilt for this version', layouts.version === coreVersion());
    proof.check('the branding .htaccess was written again', fs.existsSync(hta));
    proof.check('it turns PHP off in the upload folder', /php_flag engine off/.test(fs.readFileSync(hta, 'utf8')));
    proof.equal('Database > Default menus is Ready', await rowState(admin, 'menus'), 'ok');
    proof.check('the Run now button is gone', (await admin.locator('#mt-setup-database button:has-text("Run now")').count()) === 0);
    proof.limit('Pending migrations are not created here (that needs an un-run migration on a live install); the Migrator is shown to be idempotent by "Tables: Up to date" staying ok.');
  } finally {
    proof.step('Put the menus, caches and .htaccess back exactly as they were');
    php('audit-state.php', 'restore');
    php('audit-state.php', 'backup');
    if (htaBytes) fs.writeFileSync(hta, htaBytes);
  }
  proof.check('the original menus are back', db.menus().length > 0);
});

// ------------------------------------------------------------------- AD-07

test('AD-07 Save & check trims and stores the key, drops the site cache and asks the server afresh', async ({ admin, visit, proof }) => {
  proof.claim('The Setup licence form trims the key, stores hadrian_license_key, deletes hn_theme_license.json and checks the new key without using the cache.');
  const startKey = db.config('hadrian_license_key');
  const adminCache = readMaybe(ADMIN_CACHE);
  const themeCache = readMaybe(THEME_CACHE);
  proof.value('hadrian_license_key is set (value never recorded)', startKey !== null && startKey !== '', startKey !== null && startKey !== '');
  proof.note(`Before: hn_theme_license.json ${themeCache ? 'exists' : 'absent'}, hn_admin_license_status.json ${adminCache ? 'exists' : 'absent'} (in ${os.tmpdir()}).`);
  test.skip(startKey !== null && startKey !== '', 'A real key is stored; this test only ever saves the fake key over an empty one.');
  test.skip(callsUsed() >= 2, 'The licence-server budget for this run (2 calls) is spent.');

  try {
    await admin.goto(adminUrl('setup'));
    proof.equal('License row is "To do" with no key', await rowState(admin, 'license'), 'todo');
    const input = admin.locator('#mt-setup-license-key');
    proof.equal('the key field is empty', await input.inputValue(), '');

    proof.step(`Type "  ${FAKE_KEY}  " (with spaces) and press Save & check`);
    await input.fill(`  ${FAKE_KEY}  `);
    spend(1);
    const t0 = Date.now();
    await submit(admin, admin.locator('#mt-setup-license button[type="submit"]'));
    proof.check('the screen redirected to done=license', /[?&]done=license\b/.test(admin.url()), admin.url());
    proof.check('it says "License key saved."', /License key saved\./.test(await flashText(admin)), await flashText(admin));
    const stored = db.config('hadrian_license_key');
    proof.value('hadrian_license_key', startKey, stored);
    proof.equal('the key was stored trimmed', stored, FAKE_KEY);
    proof.check('hn_theme_license.json was deleted', !fs.existsSync(THEME_CACHE));

    // A signed reply is cached for this key; an unsigned or failed one is not,
    // and then the redirect's page view asked the server a second time.
    let cache = null;
    try { cache = JSON.parse(fs.readFileSync(ADMIN_CACHE, 'utf8')); } catch {}
    const fresh = cache && cache.key === FAKE_KEY && fs.statSync(ADMIN_CACHE).mtimeMs >= t0 - 2000;
    if (!fresh) spend(1);
    proof.note(fresh
      ? `The server answered with a signed reply ("${cache.result.status}"); it was written to the admin cache, so the redirect's page view used it.`
      : 'The reply was not cached (unsigned or unreachable), so the page view after the redirect asked the server again: 2 calls used.');
    if (fresh) proof.check('the server was asked during Save: the admin cache was written for the new key after the click', fresh);
    proof.limit('A cache miss and the forced fresh check look the same from outside when the key changes; the fresh flag (SetupController::handle -> SetupProbe::facts(freshLicense: true)) is read from the code.');

    const state = await rowState(admin, 'license');
    const detail = await rowDetail(admin, 'license');
    proof.value('License row state', 'todo', state);
    proof.check('the fake key is not Active', state !== 'ok', `${state}: ${detail}`);
    proof.note(`The fake key reads "${state}": ${detail}`);
    await proof.shot(admin.locator('#mt-setup-license'), 'License after saving the fake key');

    if (fresh) {
      proof.step('Open Info: with the answer cached it must not ask again');
      const mtime = fs.statSync(ADMIN_CACHE).mtimeMs;
      const sha = fs.readFileSync(ADMIN_CACHE, 'utf8');
      await admin.goto(adminUrl('info'));
      const badge = (await admin.locator('.mt-section').nth(1).locator('dd').first().innerText()).trim();
      proof.note(`Info badge for the fake key: "${badge}"`);
      proof.check('Info shows the stored key', (await admin.locator('dt:has-text("License Key") + dd code').innerText()).trim() === FAKE_KEY);
      proof.check('Info answered from the 15-minute cache (file not rewritten)', fs.statSync(ADMIN_CACHE).mtimeMs === mtime && fs.readFileSync(ADMIN_CACHE, 'utf8') === sha);
      await proof.shot(admin, 'Info with the fake key');
    }

    proof.step('Clear the field and press Save & check (no key: no server call)');
    await admin.goto(adminUrl('setup'));
    await admin.locator('#mt-setup-license-key').fill('   ');
    await submit(admin, admin.locator('#mt-setup-license button[type="submit"]'));
    proof.equal('a blank key is stored as ""', db.config('hadrian_license_key'), '');
    proof.equal('License row is "To do" again', await rowState(admin, 'license'), 'todo');
  } finally {
    helper({ do: 'config', set: { hadrian_license_key: startKey } });
    putBack(ADMIN_CACHE, adminCache);
    putBack(THEME_CACHE, themeCache);
  }
  proof.equal('hadrian_license_key is back to what it was', db.config('hadrian_license_key'), startKey);
  proof.note(`Licence-server calls used in this run so far: ${callsUsed()}.`);
});

// ------------------------------------------------------------- AD-08 / AD-09

test('AD-09 Switch back restores the earlier theme for guests, then Go live is refused while setup is blocked', async ({ admin, visit, proof }) => {
  proof.claim('Switch back puts Template and OrderFormTemplate back to what an earlier go-live replaced and forgets the record; guests then see that theme.');
  proof.step('Precondition: the record a go-live from twenty-one / standard_cart leaves behind');
  const start = liveRows();
  proof.equal('the site starts on Hadrian', [start.Template, start.OrderFormTemplate], ['hadrian', 'hadrian_cart']);
  setRows({ hadrian_setup_prev_template: 'twenty-one', hadrian_setup_prev_orderform: 'standard_cart' });

  const guest = await visit('guest');
  const g0 = await fetchPage(guest, '/index.php');
  const c0 = await fetchPage(guest, '/cart.php');
  proof.equal('a guest sees Hadrian before', themeOf(g0.body), 'hadrian');
  proof.equal('a guest orders through hadrian_cart before', themeOf(c0.body, true), 'hadrian_cart');

  await admin.goto(adminUrl('setup'));
  const back = admin.locator('#mt-setup-golive button:has-text("Switch back to twenty-one")');
  proof.check('Setup offers "Switch back to twenty-one"', (await back.count()) === 1);
  await proof.shot(admin.locator('#mt-setup-golive'), 'Go live before Switch back');

  proof.step('Press "Switch back to twenty-one"');
  await submit(admin, back);
  proof.check('the screen redirected to done=back', /[?&]done=back\b/.test(admin.url()), admin.url());
  proof.check('it says "The earlier theme is back in place."', /The earlier theme is back in place\./.test(await flashText(admin)));
  await proof.shot(admin, 'Setup after Switch back');
  const after = liveRows();
  proof.value('Template / OrderFormTemplate', [start.Template, start.OrderFormTemplate], [after.Template, after.OrderFormTemplate]);
  proof.equal('Template is twenty-one again', after.Template, 'twenty-one');
  proof.equal('OrderFormTemplate is standard_cart again', after.OrderFormTemplate, 'standard_cart');
  proof.equal('the go-live record is forgotten', [after.hadrian_setup_prev_template, after.hadrian_setup_prev_orderform], [null, null]);

  const guest2 = await visit('guest');
  const g1 = await fetchPage(guest2, '/index.php');
  const c1 = await fetchPage(guest2, '/cart.php');
  proof.equal('a guest now sees twenty-one', themeOf(g1.body), 'twenty-one');
  proof.equal('a guest now orders through standard_cart', themeOf(c1.body, true), 'standard_cart');
  await guest2.goto('/index.php');
  await proof.shot(guest2, 'guest home after Switch back');

  proof.step('Go live: the button is disabled while License is "To do" and the hook is missing; force the post anyway');
  proof.equal('the checklist reads License "To do"', await rowState(admin, 'license'), 'todo');
  const live = admin.locator('#mt-setup-golive button:has-text("Make Hadrian live")');
  proof.check('"Make Hadrian live" is shown disabled', (await live.count()) === 1 && (await live.isDisabled()));
  await live.evaluate(b => b.removeAttribute('disabled'));
  await submit(admin, live);
  const refusal = await flashText(admin);
  proof.check('the server refuses: "Hadrian was not switched on"', /Hadrian was not switched on/.test(refusal), refusal);
  proof.equal('Template is still twenty-one', liveRows().Template, 'twenty-one');
  await proof.shot(admin, 'Go live refused');

  proof.step('Put Hadrian back with the local helper (Go live cannot pass here) and check every row is exactly as it started');
  const end = setRows({ Template: start.Template, OrderFormTemplate: start.OrderFormTemplate, hadrian_setup_prev_template: start.hadrian_setup_prev_template, hadrian_setup_prev_orderform: start.hadrian_setup_prev_orderform });
  proof.equal('all four rows end exactly as they started', end, start);
  const guest3 = await visit('guest');
  proof.equal('a guest sees Hadrian again', themeOf((await fetchPage(guest3, '/index.php')).body), 'hadrian');
  proof.note('Go live could not be proven to switch Hadrian back on through the screen: this install has no licence key and no includes/hooks/hostnodes_theme_license.php, so the checklist is blocked. The refusal is the correct behaviour. Hadrian was put back with tblconfiguration writes instead.');
});

test('AD-09 Switch back only touches rows that still point at Hadrian', async ({ admin, proof }) => {
  proof.claim('If the order form was changed in General Settings after go-live, Switch back leaves it alone and only restores the client area theme.');
  const start = liveRows();
  proof.step('Precondition: Template=hadrian, OrderFormTemplate=premium_comparison (picked since), record twenty-one / standard_cart');
  setRows({ OrderFormTemplate: 'premium_comparison', hadrian_setup_prev_template: 'twenty-one', hadrian_setup_prev_orderform: 'standard_cart' });
  await admin.goto(adminUrl('setup'));
  await submit(admin, admin.locator('#mt-setup-golive button:has-text("Switch back")'));
  const after = liveRows();
  proof.value('Template / OrderFormTemplate', ['hadrian', 'premium_comparison'], [after.Template, after.OrderFormTemplate]);
  proof.equal('Template went back to twenty-one', after.Template, 'twenty-one');
  proof.equal('the order form the admin picked is kept', after.OrderFormTemplate, 'premium_comparison');
  proof.equal('both records are forgotten', [after.hadrian_setup_prev_template, after.hadrian_setup_prev_orderform], [null, null]);
  await proof.shot(admin, 'after a partial Switch back');
  proof.equal('rows end as they started', setRows(start), start);
});

test('AD-09 Switch back refuses, changing nothing, when an earlier folder is gone', async ({ admin, proof }) => {
  proof.claim('If the earlier order form folder no longer exists, Switch back refuses before changing either row.');
  const start = liveRows();
  proof.step('Precondition: record twenty-one (present) and an order form "audit_gone_cart" (no folder)');
  setRows({ hadrian_setup_prev_template: 'twenty-one', hadrian_setup_prev_orderform: 'audit_gone_cart' });
  await admin.goto(adminUrl('setup'));
  await submit(admin, admin.locator('#mt-setup-golive button:has-text("Switch back")'));
  const msg = await flashText(admin);
  proof.check('it says the earlier order form is no longer there', /audit_gone_cart" is no longer in templates\/orderforms/.test(msg), msg);
  const after = liveRows();
  proof.equal('Template was not touched (both folders are checked first)', after.Template, 'hadrian');
  proof.equal('OrderFormTemplate was not touched', after.OrderFormTemplate, 'hadrian_cart');
  proof.equal('the record is kept for another try', [after.hadrian_setup_prev_template, after.hadrian_setup_prev_orderform], ['twenty-one', 'audit_gone_cart']);
  await proof.shot(admin, 'Switch back refused');
  proof.equal('rows end as they started', setRows(start), start);
});

test('AD-09 With no earlier theme on record there is no Switch back, and a forced one is refused', async ({ admin, proof }) => {
  proof.claim('Without a record the button is not offered; a switchback post says there is nothing to switch back to.');
  const start = liveRows();
  proof.equal('no go-live record on this install', [start.hadrian_setup_prev_template, start.hadrian_setup_prev_orderform], [null, null]);
  await admin.goto(adminUrl('setup'));
  proof.check('no Switch back button', (await admin.locator('#mt-setup-golive button:has-text("Switch back")').count()) === 0);
  proof.step('Change the licence form\'s setup_do to "switchback" in the page and submit it');
  await admin.locator('#mt-setup-license input[name="setup_do"]').evaluate(i => { i.value = 'switchback'; });
  await submit(admin, admin.locator('#mt-setup-license button[type="submit"]'));
  const msg = await flashText(admin);
  proof.check('it says there is no earlier theme on record', /There is no earlier theme on record/.test(msg), msg);
  proof.equal('nothing changed', liveRows(), start);
  await proof.shot(admin, 'forced switchback refused');
});

test('AD-08 Go live sets Template and the order form and remembers the old values', async ({ proof }) => {
  proof.claim('With nothing "To do" or "Problem", Make Hadrian live sets Template=hadrian, OrderFormTemplate=hadrian_cart (cart complete) and records what they held.');
  const key = db.config('hadrian_license_key');
  const hook = fs.existsSync(path.join(WHMCS_ROOT, 'includes', 'hooks', 'hostnodes_theme_license.php'));
  proof.note(`Blockers on this install: licence key ${key ? 'set' : 'not set'} (License = "To do"), includes/hooks/hostnodes_theme_license.php ${hook ? 'present' : 'missing'} (Files = "Problem").`);
  proof.note('The refusal half of AD-08 is proven in "AD-09 Switch back restores ... then Go live is refused": the button is disabled and a forced post is refused with Template unchanged.');
  proof.note('The success branch is covered by tests/static/test-setup.php ("switching" section: goLive from twenty-one/standard_cart, remembering both, cart only when complete).');
  test.skip(true, 'Needs a live licence server: going live requires an Active key from license.hostnodes.com (and the enforcement hook, which calls that server on every page). Faking the answer is not allowed.');
});

test('AD-08 Go live and Switch back refuse a setup_do this page does not know', async ({ admin, proof }) => {
  proof.claim('A Setup post with an unknown setup_do changes nothing and says so.');
  const start = liveRows();
  const key = db.config('hadrian_license_key');
  await admin.goto(adminUrl('setup'));
  await admin.locator('#mt-setup-license input[name="setup_do"]').evaluate(i => { i.value = 'audit-nonsense'; });
  await submit(admin, admin.locator('#mt-setup-license button[type="submit"]'));
  const msg = await flashText(admin);
  proof.check('it says "Nothing was changed"', /Nothing was changed/.test(msg), msg);
  proof.equal('the live rows are unchanged', liveRows(), start);
  proof.equal('the licence key was not written', db.config('hadrian_license_key'), key);
});

// ------------------------------------------------------------------- AD-10

test('AD-10 "Preview first" opens the site in Hadrian for this browser only', async ({ admin, visit, proof }) => {
  proof.claim('While Hadrian is not live, Setup links to index.php?systpl=hadrian (plus carttpl=hadrian_cart when the cart is complete); that browser sees Hadrian, other visitors do not.');
  const start = liveRows();
  proof.step('Precondition: Template=twenty-one, OrderFormTemplate=standard_cart');
  setRows({ Template: 'twenty-one', OrderFormTemplate: 'standard_cart' });
  await admin.goto(adminUrl('setup'));
  const a = admin.locator('#mt-setup-golive a:has-text("Preview first")');
  proof.check('Setup shows "Preview first"', (await a.count()) === 1);
  const href = await a.getAttribute('href');
  const sys = db.config('SystemURL').replace(/\/$/, '');
  proof.equal('the link is SystemURL/index.php?systpl=hadrian&carttpl=hadrian_cart', href, `${sys}/index.php?systpl=hadrian&carttpl=hadrian_cart`);
  proof.equal('it opens in a new tab', await a.getAttribute('target'), '_blank');
  await proof.shot(admin.locator('#mt-setup-golive'), 'Preview first');

  proof.step('Open the link as a guest, then the cart in the same browser');
  const previewer = await visit('guest');
  const p1 = await fetchPage(previewer, href.replace(sys, ''));
  proof.equal('the preview renders Hadrian', themeOf(p1.body), 'hadrian');
  const p2 = await fetchPage(previewer, '/cart.php');
  proof.equal('the same browser orders through hadrian_cart', themeOf(p2.body, true), 'hadrian_cart');
  await previewer.goto('/index.php');
  await proof.shot(previewer, 'previewing browser');

  const other = await visit('guest');
  const o1 = await fetchPage(other, '/index.php');
  proof.equal('another guest still sees twenty-one', themeOf(o1.body), 'twenty-one');
  proof.equal('Template is unchanged by the preview', liveRows().Template, 'twenty-one');
  proof.equal('rows end as they started', setRows(start), start);
});
