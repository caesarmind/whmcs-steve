// AD-K Extensions, Tools, Templates and Licence (tests/FEATURES.md AD-79 to
// AD-84, AD-87, AD-88): every Tools button pressed on the real screen and
// proven on disk or in the database before and after; the Templates list and
// show views; the Licence page's Save & check with a fake key; the licence
// state mapping; and the dormant revert-to-six code.
//
// The licence server is asked at most twice per run across this file and
// a-setup.audit.mjs (a shared counter in the temp folder), only ever with the
// fake key HN-AUDIT-NOT-A-KEY.

import { test, db, useAuditBackup, settings, adminUrl, submit, flashText, noErrorText } from './harness.mjs';
import { spawnSync } from 'node:child_process';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import { PHP, TESTS_DIR, REPO_ROOT, WHMCS_ROOT } from '../../lib/env.mjs';

useAuditBackup();
test.beforeEach(() => { settings.snapshot(); });
test.afterEach(() => { settings.restore(); });

// ------------------------------------------------------------ local helpers

const HELPER = path.join(os.tmpdir(), 'hadrian-audit-k-tools-helper.php');
const HELPER_PHP = String.raw`<?php
declare(strict_types=1);
require_once $argv[1];
hadrian_site_lock_guard('k-tools.audit.mjs helper');
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
    case 'config-like':
        $out = DB::table('tblconfiguration')->where('setting', 'like', (string) $cmd['like'])->orderBy('setting')->pluck('value', 'setting');
        break;
    case 'judge':
        // The real SetupChecks class with only the licence fact given: no
        // SetupProbe, so nothing here can reach the network.
        $out = [];
        foreach ($cmd['statuses'] as $s) {
            $groups = \Hadrian\Helpers\SetupChecks::evaluate(['license' => ['key' => 'x', 'status' => $s, 'active' => $s === 'Active']]);
            foreach ($groups as $g) {
                if ($g['key'] === 'license') { $out[$s] = ['state' => $g['rows'][0]['state'], 'detail' => $g['rows'][0]['detail']]; }
            }
        }
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

const readRepo = rel => fs.readFileSync(path.join(REPO_ROOT, rel), 'utf8');
const coreVersion = () => readRepo('hadrian/templates/hadrian/core/hadrian.php').match(/'version'\s*=>\s*'([^']+)'/)[1];
const themeJson = () => JSON.parse(readRepo('hadrian/templates/hadrian/theme.json'));

/** Files in a folder with their mtimes (name -> ms). */
function listDir(dir) {
  const out = {};
  if (!fs.existsSync(dir)) return out;
  for (const f of fs.readdirSync(dir)) {
    const p = path.join(dir, f);
    try { const s = fs.statSync(p); if (s.isFile()) out[f] = s.mtimeMs; } catch {}
  }
  return out;
}

const TOOL = name => `button[name="tool"][value="${name}"]`;

// Licence-server budget, shared with a-setup.audit.mjs: at most 2 calls per run.
const BUDGET = path.join(os.tmpdir(), 'hadrian-audit-licence-calls.json');
const RUN = process.env.HADRIAN_SITE_LOCK_TOKEN || `ppid-${process.ppid}`;
const callsUsed = () => { try { const b = JSON.parse(fs.readFileSync(BUDGET, 'utf8')); return b.run === RUN ? b.count : 0; } catch { return 0; } };
const spend = n => fs.writeFileSync(BUDGET, JSON.stringify({ run: RUN, count: callsUsed() + n, at: new Date().toISOString() }));

const FAKE_KEY = 'HN-AUDIT-NOT-A-KEY';
const ADMIN_CACHE = path.join(os.tmpdir(), 'hn_admin_license_status.json');
const THEME_CACHE = path.join(os.tmpdir(), 'hn_theme_license.json');
const readMaybe = f => { try { return fs.readFileSync(f); } catch { return null; } };
const putBack = (f, bytes) => { if (bytes === null) { try { fs.unlinkSync(f); } catch {} } else fs.writeFileSync(f, bytes); };

// ------------------------------------------------------------------- AD-79

test('AD-79 Extensions lists the registered modules and the theme.json extensions', async ({ admin, proof }) => {
  proof.claim('The Extensions page lists every extension module that registered itself (with a nav tab unless it asked for none) and the theme extensions theme.json declares.');
  const declared = themeJson().provides?.extensions ?? [];
  proof.note(`theme.json provides.extensions = ${JSON.stringify(declared)}`);

  await admin.goto(adminUrl('extensions'));
  await noErrorText(admin, proof, 'Extensions');
  const cards = await admin.locator('.mt-panel').filter({ has: admin.locator('.mt-section-title', { hasText: 'Modules' }) })
    .locator('.mt-card').evaluateAll(cs => cs.map(c => ({
      name: c.querySelector('.mt-card-title')?.textContent.trim(),
      badge: c.querySelector('.mt-badge')?.textContent.replace(/\s+/g, ' ').trim(),
      href: c.querySelector('a')?.getAttribute('href'),
    })));
  proof.note(`Module cards: ${JSON.stringify(cards)}`);

  const builderV = readRepo('hadrian_builder/modules/addons/HadrianBuilder/src/AdminController.php').match(/const VERSION\s*=\s*'([^']+)'/)?.[1];
  const email = cards.find(c => c.name === 'Email Templates');
  const builder = cards.find(c => c.name === 'Page Builder');
  proof.check('Email Templates (HadrianEmail hooks.php) is listed as Active v1.0.0', email && /Active/.test(email.badge) && /v1\.0\.0/.test(email.badge), JSON.stringify(email));
  proof.check('its Open link goes to ?module=HadrianEmail', email && /^\?module=HadrianEmail/.test(email.href || ''), email?.href);
  proof.check(`Page Builder is listed${builderV ? ` as v${builderV}` : ''}`, builder && (!builderV || builder.badge.includes(`v${builderV}`)), JSON.stringify(builder));

  const tabs = (await admin.locator('.mt-topnav-item').allInnerTexts()).map(s => s.trim());
  proof.check('Email has a nav tab', tabs.includes('Email'), tabs.join(', '));
  proof.check('Page Builder asked for no tab and has none', !tabs.includes('Builder'), tabs.join(', '));

  const themePanel = admin.locator('.mt-section-title', { hasText: 'Theme extensions' });
  proof.equal('theme-extension cards match theme.json', await themePanel.count() ? await admin.locator('.mt-panel').filter({ has: themePanel }).locator('.mt-card').count() : 0, declared.length);
  await proof.shot(admin, 'Extensions');
  proof.limit('Registration comes from the companion modules\' hooks.php on each request; deactivating one in WHMCS is not exercised here.');
});

// ------------------------------------------------------------------- AD-80

test('AD-80 Clear template cache empties the addon compile folder and nothing else', async ({ admin, proof }) => {
  proof.claim('Tools > Clear deletes the Hadrian admin\'s own compiled templates (temp/hadrian-smarty) and leaves WHMCS templates_c alone.');
  const own = path.join(os.tmpdir(), 'hadrian-smarty');
  const whmcs = path.join(WHMCS_ROOT, 'templates_c');

  proof.step('Open Settings (compiles its templates), then Tools');
  await admin.goto(adminUrl('settings'));
  await admin.goto(adminUrl('tools'));
  await noErrorText(admin, proof, 'Tools');
  const before = listDir(own);
  const whmcsBefore = listDir(whmcs);
  const settingsCompiled = Object.keys(before).filter(f => /\.file\.index\.tpl\.php$/.test(f)).length;
  proof.check('the compile folder holds files before', Object.keys(before).length > 0, `${Object.keys(before).length} files`);

  proof.step('Press Clear');
  const t0 = Date.now();
  await submit(admin, TOOL('clear_template_cache'));
  const msg = await flashText(admin);
  await proof.shot(admin, 'Tools after Clear');
  const n = Number((msg.match(/Cleared (\d+) compiled admin templates/) || [])[1]);
  proof.equal('the message counts every file that was there', n, Object.keys(before).length);
  const after = listDir(own);
  proof.value('files in temp/hadrian-smarty', Object.keys(before).length, Object.keys(after).length);
  const survivors = Object.entries(after).filter(([, m]) => m < t0 - 1000).map(([f]) => f);
  proof.equal('no file older than the click survived', survivors, []);
  proof.note(`${Object.keys(after).length} files are back: the ones the answering Tools page compiled again. ${settingsCompiled} index.tpl compilations were present before.`);
  const lost = Object.keys(whmcsBefore).filter(f => !(f in listDir(whmcs)));
  proof.equal('WHMCS templates_c lost no file', lost, []);
  proof.check('the message names the admin scope', /compiled admin templates/.test(msg), msg);
});

// ------------------------------------------------------------------- AD-81

test('AD-81 Rebuild discovery rewrites the page and layout caches and reports the counts', async ({ admin, proof }) => {
  proof.claim('Tools > Rebuild scans the theme again, overwrites hadrian_pages_discovered and hadrian_layouts_discovered, and reports how many pages and custom layouts it found.');
  proof.step('Precondition: a stale pages cache ("audit-sentinel", version 0-audit)');
  settings.set({ hadrian_pages_discovered: [{ version: '0-audit', signature: 'audit', pages: ['audit-sentinel'], generated_at: '2000-01-01T00:00:00+00:00' }, 'json'] });

  await admin.goto(adminUrl('tools'));
  const before = db.settings('hadrian_');
  const pagesBefore = JSON.parse(before.hadrian_pages_discovered || '{}');
  const layoutsBefore = JSON.parse(before.hadrian_layouts_discovered || '{}');
  proof.note(`Pages cache after opening Tools: version ${pagesBefore.version}, ${(pagesBefore.pages || []).length} pages, generated ${pagesBefore.generated_at}`);

  proof.step('Press Rebuild');
  await submit(admin, TOOL('rebuild_pages_cache'));
  const msg = await flashText(admin);
  await proof.shot(admin, 'Tools after Rebuild');
  const after = db.settings('hadrian_');
  const pages = JSON.parse(after.hadrian_pages_discovered || '{}');
  const layouts = JSON.parse(after.hadrian_layouts_discovered || '{}');
  proof.value('hadrian_pages_discovered (version, count, generated_at)', [pagesBefore.version, (pagesBefore.pages || []).length, pagesBefore.generated_at], [pages.version, (pages.pages || []).length, pages.generated_at]);
  proof.value('hadrian_layouts_discovered generated_at', layoutsBefore.generated_at, layouts.generated_at);
  proof.check('the stale sentinel is gone', !(pages.pages || []).includes('audit-sentinel'));
  proof.equal('the pages cache carries the theme version', pages.version, coreVersion());
  proof.check('both caches were written by this click', pages.generated_at !== pagesBefore.generated_at && layouts.generated_at !== layoutsBefore.generated_at);
  const m = msg.match(/Discovery rebuilt\D+(\d+) pages, (\d+) custom layout/);
  proof.check('the message reports counts', !!m, msg);
  proof.equal('the reported page count is what was stored', Number(m[1]), pages.pages.length);
  const custom = Object.values(layouts.layouts || {}).reduce((n, kind) => n + Object.keys(kind || {}).length, 0);
  proof.equal('the reported custom-layout count is what was stored', Number(m[2]), custom);
});

// ------------------------------------------------------------------- AD-82

test('AD-82 Refresh licence is a no-op in dev mode and uses its own key', async ({ admin, proof }) => {
  proof.claim('Tools > Refresh calls the dormant Template\\License, which in dev mode does nothing; it keys on Hadrian-hadrian-license, not hadrian_license_key.');
  const core = readRepo('hadrian/templates/hadrian/core/hadrian.php');
  const dev = /'dev_mode'\s*=>\s*true/.test(core);
  proof.check('core/hadrian.php ships dev_mode => true', dev);
  const rowsBefore = helper({ do: 'config-like', like: 'Hadrian-%license%' });
  const keyBefore = db.config('hadrian_license_key');
  const adminCache = readMaybe(ADMIN_CACHE);

  await admin.goto(adminUrl('tools'));
  proof.step('Press Refresh');
  await submit(admin, TOOL('refresh_license'));
  const msg = await flashText(admin);
  await proof.shot(admin, 'Tools after Refresh');
  proof.check('it says dev mode makes it a no-op', /Development mode active/.test(msg) && /no-op/.test(msg), msg);
  const rowsAfter = helper({ do: 'config-like', like: 'Hadrian-%license%' });
  proof.value('Hadrian-*license* config rows', rowsBefore, rowsAfter);
  proof.equal('no Template\\License row was written', rowsAfter, rowsBefore);
  proof.equal('hadrian_license_key is untouched', db.config('hadrian_license_key'), keyBefore);
  proof.check('the admin licence cache was not touched', String(readMaybe(ADMIN_CACHE)) === String(adminCache));
  proof.note('Template\\License reads the key from tblconfiguration "Hadrian-hadrian-license" (Template::license()), a different row from the hadrian_license_key the Setup and Licence screens write. Its server URL is the placeholder https://licensing.your-domain.com/ and its public key a placeholder, so outside dev mode refreshNow() could never verify.');
});

// ------------------------------------------------------------------- AD-83

test('AD-83 Templates lists each template with canActivate', async ({ admin, proof }) => {
  proof.claim('?action=templates lists every templates/ folder with a theme.json and a core/<slug>.php, with Active/Ready or "License invalid" from canActivate.');
  await admin.goto(adminUrl('templates'));
  await noErrorText(admin, proof, 'Templates');
  const cards = await admin.locator('.mt-card').evaluateAll(cs => cs.map(c => ({
    title: c.querySelector('.mt-card-title')?.textContent.trim(),
    meta: c.querySelector('.mt-card-meta')?.textContent.trim(),
    badge: c.querySelector('.mt-badge')?.textContent.trim(),
    link: c.querySelector('a')?.getAttribute('href'),
  })));
  const eligible = fs.readdirSync(path.join(WHMCS_ROOT, 'templates')).filter(d => {
    const p = path.join(WHMCS_ROOT, 'templates', d);
    return fs.existsSync(path.join(p, 'theme.json')) && fs.existsSync(path.join(p, 'core', `${d}.php`));
  });
  proof.note(`Cards: ${JSON.stringify(cards)}; folders with theme.json + core/<slug>.php: ${eligible.join(', ')}`);
  proof.equal('one card per eligible folder', cards.length, eligible.length);
  const h = cards.find(c => /hadrian/i.test(c.title));
  proof.check(`Hadrian shows Version ${coreVersion()}`, h && h.meta === `Version ${coreVersion()}`, JSON.stringify(h));
  proof.equal('Hadrian is Active (live, and canActivate is true in dev mode)', h?.badge, 'Active');
  proof.check('it links to the template view', /action=template&templateName=hadrian/.test(h?.link || ''), h?.link);
  await proof.shot(admin, 'Templates');
});

test('AD-83 Template show renders the theme and opens only a listed template', async ({ admin, proof }) => {
  proof.claim('?action=template&templateName=hadrian shows its styles, layouts and pages; any name the template list does not offer is refused with a plain error that names no server path and never reaches the filesystem lookup.');
  const tj = themeJson();
  await admin.goto(adminUrl('template', { templateName: 'hadrian' }));
  await noErrorText(admin, proof, 'template view');
  proof.check(`the header shows v${coreVersion()}`, (await admin.locator('.mt-page-meta').innerText()).trim() === `v${coreVersion()}`);
  const counts = await admin.locator('.mt-section-count').allInnerTexts();
  proof.equal('the Styles count matches theme.json', counts[0].trim(), String((tj.provides?.styles || []).length));
  await proof.shot(admin, 'template view');

  for (const name of ['six', '../templates/hadrian', 'audit-missing']) {
    proof.step(`Open templateName=${name}`);
    await admin.goto(adminUrl('template', { templateName: name }));
    await noErrorText(admin, proof, `template view for ${name}`);
    const e = (await admin.locator('.mt-alert-danger').innerText()).trim();
    proof.check(`"${name}" is refused as not a Hadrian template`, /There is no Hadrian template called/.test(e), e);
    proof.check(`the refusal for "${name}" prints no server path`, !/[A-Za-z]:[\/]|\/(home|var|usr|srv)\//.test(e) && !/core\//.test(e), e);
    if (name.startsWith('..')) await proof.shot(admin, 'template view with ../');
  }
});

// ------------------------------------------------------------------- AD-84

test('AD-84 Licence page shows "No key" and stores a blank save as no key', async ({ admin, proof }) => {
  proof.claim('With no key the Licence page says "No license key."; Save & check stores the trimmed value.');
  const start = db.config('hadrian_license_key');
  test.skip(start !== null && start !== '', 'A real key is stored; this test never overwrites one.');
  try {
    await admin.goto(adminUrl('license'));
    await noErrorText(admin, proof, 'Licence page');
    proof.check('the page says "No license key."', /No license key\./.test(await flashText(admin)), await flashText(admin));
    proof.equal('the key field is empty', await admin.locator('#mt-license-key').inputValue(), '');
    proof.step('Type spaces only and press Save & check');
    await admin.locator('#mt-license-key').fill('    ');
    await submit(admin, '.mt-savebar button[type="submit"]');
    const stored = db.config('hadrian_license_key');
    proof.value('hadrian_license_key', start, stored);
    proof.equal('spaces are trimmed to an empty key', stored, '');
    proof.check('the page still says "No license key."', /No license key\./.test(await flashText(admin)));
    await proof.shot(admin, 'Licence page, no key');
  } finally {
    helper({ do: 'config', set: { hadrian_license_key: start } });
  }
  proof.equal('hadrian_license_key is back to what it was', db.config('hadrian_license_key'), start);
});

test('AD-84 Licence page Save & check asks the server about a fake key and shows its state', async ({ admin, proof }) => {
  proof.claim('Save & check stores the key, drops hn_theme_license.json, checks it fresh and shows the matching alert; a key that is not valid reads "Not active" (or "Could not verify" when the server cannot be read).');
  const start = db.config('hadrian_license_key');
  test.skip(start !== null && start !== '', 'A real key is stored; this test never overwrites one.');
  test.skip(callsUsed() >= 2, 'The licence-server budget for this run (2 calls) was spent by a-setup.audit.mjs (AD-07).');
  const adminCache = readMaybe(ADMIN_CACHE);
  const themeCache = readMaybe(THEME_CACHE);
  proof.note(`Before: hn_theme_license.json ${themeCache ? 'exists' : 'absent'}, hn_admin_license_status.json ${adminCache ? 'exists' : 'absent'}.`);
  try {
    await admin.goto(adminUrl('license'));
    proof.step(`Type " ${FAKE_KEY} " and press Save & check`);
    await admin.locator('#mt-license-key').fill(` ${FAKE_KEY} `);
    spend(1);
    const t0 = Date.now();
    await submit(admin, '.mt-savebar button[type="submit"]');
    const stored = db.config('hadrian_license_key');
    proof.value('hadrian_license_key', start, stored);
    proof.equal('the key is stored trimmed', stored, FAKE_KEY);
    proof.check('hn_theme_license.json was deleted', !fs.existsSync(THEME_CACHE));
    const alert = await flashText(admin);
    proof.note(`The page shows: ${alert}`);
    proof.check('the fake key is not reported active', !/License active/.test(alert), alert);
    proof.check('the alert is "Not active" or "Could not verify right now"', /Not active\.|Could not verify right now/.test(alert), alert);
    let cache = null;
    try { cache = JSON.parse(fs.readFileSync(ADMIN_CACHE, 'utf8')); } catch {}
    const signed = cache && cache.key === FAKE_KEY && fs.statSync(ADMIN_CACHE).mtimeMs >= t0 - 2000;
    proof.note(signed ? `Signed reply "${cache.result.status}" was cached for 15 minutes.` : 'No signed reply: nothing was cached (Unreachable/Unknown are never cached).');
    await proof.shot(admin, 'Licence page with the fake key');

    proof.step('Clear the key (no key: no server call) and save');
    await admin.locator('#mt-license-key').fill('');
    await submit(admin, '.mt-savebar button[type="submit"]');
    proof.equal('the key is now empty', db.config('hadrian_license_key'), '');
    proof.check('the page says "No license key." again', /No license key\./.test(await flashText(admin)));
  } finally {
    helper({ do: 'config', set: { hadrian_license_key: start } });
    putBack(ADMIN_CACHE, adminCache);
    putBack(THEME_CACHE, themeCache);
  }
  proof.equal('hadrian_license_key is back to what it was', db.config('hadrian_license_key'), start);
  proof.note(`Licence-server calls used in this run: ${callsUsed()}.`);
});

test('AD-84 Licence states that need a real server answer', async ({ proof }) => {
  proof.claim('Active, Expired, Revoked, Unverified and "Reissued falls to Not active" on the Licence page.');
  const tpl = readRepo('hadrian/modules/addons/Hadrian/views/adminarea/license/index.tpl');
  proof.note('license/index.tpl branches: active -> "License active."; No key; Suspended|Expired; Banned|Cancelled|Revoked; Unreachable|Unknown -> "Could not verify right now"; anything else (Reissued included) -> "Not active."');
  proof.check('the template has no branch for "Reissued", so it falls to Not active', !/Reissued/.test(tpl));
  test.skip(true, 'Needs a live licence server answer for a real key in each state; faking the signed reply is not allowed.');
});

// ------------------------------------------------------------------- AD-87

test('AD-87 Licence state mapping through the screens: No key', async ({ admin, proof }) => {
  proof.claim('No key: Setup License row "To do", Info "No key set", Licence page "No license key.".');
  const key = db.config('hadrian_license_key');
  test.skip(key !== null && key !== '', 'A key is stored.');
  await admin.goto(adminUrl('setup'));
  proof.equal('Setup License row is todo', await admin.locator('[data-setup-row="license"]').getAttribute('data-setup-state'), 'todo');
  await proof.shot(admin.locator('#mt-setup-license'), 'Setup License, no key');
  await admin.goto(adminUrl('info'));
  proof.equal('Info badge', (await admin.locator('.mt-section').nth(1).locator('dd').first().innerText()).trim(), 'No key set');
  await admin.goto(adminUrl('license'));
  proof.check('Licence page alert', /No license key\./.test(await flashText(admin)));
  proof.note('The fake key\'s state through the screens is in AD-07 (Setup, Info) and AD-84 (Licence page).');
});

test('AD-87 SetupChecks maps every licence status as promised', async ({ proof }) => {
  proof.claim('Active ok; No key todo; Expired and Suspended warn; Unreachable, Unknown and Error warn; Banned, Cancelled and Revoked fail.');
  proof.step('Run tests/static/test-setup.php (no WHMCS, no network)');
  const r = spawnSync(PHP, [path.join(TESTS_DIR, 'static', 'test-setup.php')], { encoding: 'utf8', timeout: 60_000 });
  const tail = r.stdout.trim().split('\n').pop();
  proof.check('tests/static/test-setup.php passes', r.status === 0, tail);

  proof.step('Ask the real SetupChecks class about each status (only the licence fact; nothing calls the server)');
  const want = { Active: 'ok', 'No key': 'todo', Expired: 'warn', Suspended: 'warn', Unreachable: 'warn', Unknown: 'warn', Error: 'warn', Banned: 'fail', Cancelled: 'fail', Revoked: 'fail', Invalid: 'fail' };
  const got = helper({ do: 'judge', statuses: Object.keys(want) });
  proof.note(`States: ${Object.entries(got).map(([s, v]) => `${s}=${v.state}`).join(', ')}`);
  const lc = readRepo('hadrian/modules/addons/Hadrian/src/Helpers/LicenseCheck.php');
  proof.check('LicenseCheck returns Unreachable and Unknown before writeCache (never cached)', /return \['active' => false, 'status' => 'Unreachable'/.test(lc) && /return \['active' => false, 'status' => 'Unknown'/.test(lc) && lc.indexOf("'Unknown'") < lc.indexOf('self::writeCache($key, $result)'));
  if (got.Error?.state !== 'warn') {
    proof.note(`"Error" is not handled anywhere in SetupChecks::license(): it falls to the default branch and reads "${got.Error?.detail}". Info and the Licence page also show it as "Not active". LicenseCheck caches any signed status, so a signed "Error" would be cached for 15 minutes.`);
  }
  for (const [s, st] of Object.entries(want)) proof.equal(`${s} -> ${st}`, got[s]?.state, st);
  proof.limit('These are the mapping function\'s answers, not server replies: Active, Expired, Revoked and the rest cannot be produced on this install without a real key.');
});

// ------------------------------------------------------------------- AD-88

test('AD-88 Revert to six and the dashboard banner never run', async ({ proof }) => {
  proof.claim('License::deactivateTemplate (revert to six/standard_cart), the adminHooks.php configgeneral guard and the dashboard banner exist but nothing in the repo runs them; HOSTNODES_ENFORCE is not in repo code.');
  const A = 'hadrian/modules/addons/Hadrian';
  const lic = readRepo(`${A}/src/Template/License.php`);
  const core = readRepo('hadrian/templates/hadrian/core/hadrian.php');

  // Every PHP file of the four products, outside vendor and the dist build.
  const files = [];
  const walk = dir => {
    for (const e of fs.readdirSync(path.join(REPO_ROOT, dir), { withFileTypes: true })) {
      const rel = `${dir}/${e.name}`;
      if (e.isDirectory()) { if (!['vendor', 'node_modules', 'dist', '.git'].includes(e.name)) walk(rel); }
      else if (/\.(php|tpl)$/.test(e.name)) files.push(rel);
    }
  };
  for (const d of ['hadrian/modules', 'hadrian/templates', 'hadrian_cart', 'hadrian_email/modules', 'hadrian_builder/modules']) walk(d);
  const grep = re => files.filter(f => re.test(readRepo(f)));

  const loadsAdminHooks = grep(/adminHooks\.php/).filter(f => !f.endsWith('IntegrityHashes.php'));
  proof.equal('no file includes adminHooks.php (WHMCS only loads an addon\'s hooks.php)', loadsAdminHooks, []);
  const callers = grep(/deactivateTemplate\s*\(/);
  proof.equal('deactivateTemplate() is only referenced inside License.php', callers, [`${A}/src/Template/License.php`]);
  proof.check('inside License.php it is reached only from applyEnforcement(), called only at the end of refresh()', (lic.match(/applyEnforcement\(\)/g) || []).length === 2);
  proof.check('the License constructor returns before any refresh in dev mode', /if \(\$template->devMode\) \{\s*return;\s*\}/.test(lic));
  proof.check('core/hadrian.php ships dev_mode => true', /'dev_mode'\s*=>\s*true/.test(core));
  proof.check('Tools > Refresh skips refreshNow() in dev mode', /isDevMode\(\)\)\s*\{\s*return \[true, 'Development mode active/.test(readRepo(`${A}/src/Controller/Admin/ToolsController.php`)));
  proof.equal('getDashboardBanner() has no caller (banner.tpl names it only in a comment)', grep(/getDashboardBanner\s*\(/).filter(f => f.endsWith('.php')), [`${A}/src/Template/License.php`]);
  proof.equal('HOSTNODES_ENFORCE appears in no repo source file (only the built dist/stage hook)', grep(/HOSTNODES_ENFORCE/), []);
  proof.check('even outside dev mode the server URL is a placeholder', /licensing\.your-domain\.com/.test(lic));
  proof.note('Checked by reading the code (this test): adminHooks.php is not required by hooks.php, Hadrian.php or anything else, so its configgeneral.php rewrite to six never runs; deactivateTemplate is private and only applyEnforcement calls it, which only refresh() calls, which the constructor skips in dev mode and Tools skips in dev mode; getDashboardBanner has no caller; HOSTNODES_ENFORCE lives only in hadrian/dist/stage/includes/hooks/hostnodes_theme_license.php, a build output.');
  test.skip(true, 'Dead code path: nothing in the repo runs it (proven by reading the code above). Exercising it would mean editing product code.');
});
