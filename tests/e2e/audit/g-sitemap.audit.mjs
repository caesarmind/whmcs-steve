// AD-G Sitemap screen (tests/FEATURES.md AD-55 to AD-59): Addons > Hadrian >
// Sitemap driven in the browser, proven in sitemap_settings and in the two
// files it writes to the WHMCS root, sitemap.xml and robots.txt.
//
// Both files are copied byte for byte to tests/.local/audit-sitemap-backup/
// before the first test and put back (with their mtimes) after the last; a
// file that did not exist before is deleted again. sitemap_settings and the
// Pages rows live in hadrian_settings / hadrian_pages, which useAuditBackup()
// and settings.snapshot()/restore() cover.

import fs from 'node:fs';
import path from 'node:path';
import { spawnSync } from 'node:child_process';
import { test, db, php, settings, useAuditBackup, adminUrl, submit, flashText, noErrorText, setChecked } from './harness.mjs';
import { WHMCS_ROOT, LOCAL_DIR, PHP, BASE_URL } from '../../lib/env.mjs';

useAuditBackup();

// ------------------------------------------------------------ file backup

const SITEMAP = path.join(WHMCS_ROOT, 'sitemap.xml');
const ROBOTS = path.join(WHMCS_ROOT, 'robots.txt');
const BACKUP_DIR = path.join(LOCAL_DIR, 'audit-sitemap-backup');
const BACKUP_META = path.join(BACKUP_DIR, 'meta.json');

function backupFiles() {
  if (fs.existsSync(BACKUP_META)) restoreFiles();          // a run that died halfway heals first
  fs.mkdirSync(BACKUP_DIR, { recursive: true });
  const meta = {};
  for (const f of [SITEMAP, ROBOTS]) {
    const name = path.basename(f);
    if (fs.existsSync(f)) {
      fs.copyFileSync(f, path.join(BACKUP_DIR, name));
      const st = fs.statSync(f);
      meta[name] = { exists: true, atime: st.atimeMs, mtime: st.mtimeMs };
    } else {
      meta[name] = { exists: false };
    }
  }
  fs.writeFileSync(BACKUP_META, JSON.stringify(meta));
}

function restoreFiles() {
  const meta = JSON.parse(fs.readFileSync(BACKUP_META, 'utf8'));
  for (const f of [SITEMAP, ROBOTS]) {
    const name = path.basename(f);
    const m = meta[name];
    if (m && m.exists) {
      fs.copyFileSync(path.join(BACKUP_DIR, name), f);
      fs.utimesSync(f, new Date(m.atime), new Date(m.mtime));
      fs.unlinkSync(path.join(BACKUP_DIR, name));
    } else if (fs.existsSync(f)) {
      fs.unlinkSync(f);
    }
  }
  fs.unlinkSync(BACKUP_META);
}

let hashBefore = null;
test.beforeAll(() => { backupFiles(); hashBefore = db.hash(); });
test.afterAll(() => {
  restoreFiles();
  const after = db.hash();
  if (JSON.stringify(after) !== JSON.stringify(hashBefore)) {
    throw new Error(`the Hadrian tables were not put back: before ${JSON.stringify(hashBefore)}, after ${JSON.stringify(after)}`);
  }
});
test.beforeEach(() => { settings.snapshot(); });
test.afterEach(() => { settings.restore(); });

// ----------------------------------------------------------------- helpers

const BASE = BASE_URL.replace(/\/$/, '');
const SAVE = '#sitemap-form .mt-savebar button[type="submit"]';
const MARK = 'hadrian sitemap generator start';
const read = f => (fs.existsSync(f) ? fs.readFileSync(f, 'utf8') : null);
const locs = xml => [...String(xml || '').matchAll(/<loc>([^<]*)<\/loc>/g)].map(m => m[1].replace(/&amp;/g, '&'));
const freqs = xml => [...String(xml || '').matchAll(/<changefreq>([^<]*)<\/changefreq>/g)].map(m => m[1]);
const cfg = () => { const v = db.setting('sitemap_settings'); return v ? JSON.parse(v) : null; };
const ageFile = (f, secondsAgo = 3600) => { const t = new Date(Date.now() - secondsAgo * 1000); fs.utimesSync(f, t, t); };
const count = (list, re) => list.filter(u => re.test(u)).length;

const RE = {
  groups: /\?rp=\/store\/[^/]+$/,
  announcements: /\?rp=\/announcements\/\d+\//,
  knowledgebase: /\?rp=\/knowledgebase\/\d+\//,
  downloads: /\?rp=\/download\//,
};

/** Run PHP with WHMCS booted (local helper: the harness has no generic driver). */
function phpEval(body) {
  const code = `chdir(${JSON.stringify(WHMCS_ROOT)}); require 'init.php'; require_once 'modules/addons/Hadrian/autoload.php';
    $u = (string) \\WHMCS\\Database\\Capsule::table('tblconfiguration')->where('setting', 'SystemURL')->value('value');
    if (!preg_match('~^https?://(localhost|127\\.0\\.0\\.1)([:/]|$)~i', $u)) { fwrite(STDERR, 'REFUSING: not a local install'); exit(2); }
    $out = (function () { ${body} })();
    echo "\\n", json_encode($out, JSON_UNESCAPED_SLASHES), "\\n";`;
  const r = spawnSync(PHP, ['-r', code], { encoding: 'utf8', timeout: 120_000 });
  if (r.status !== 0) throw new Error(`phpEval exited ${r.status}: ${r.stdout}${r.stderr}`);
  return JSON.parse(r.stdout.trim().split('\n').pop());
}

async function openSitemap(admin) {
  await admin.goto(adminUrl('sitemap'));
  await admin.locator('#sitemap-form').waitFor();
}

async function setToggle(admin, name, on) {
  const box = admin.locator(`#sitemap-form input[type="checkbox"][name="${name}"]`);
  // The input is hidden off-screen inside .mt-toggle; setChecked clicks it (click/input/change fire).
  if ((await setChecked(box, on)) !== on) throw new Error(`could not set ${name} to ${on}`);
}

/** Open the screen, set each control, press "Save & generate". Returns the flash. */
async function saveWith(admin, changes = {}) {
  await openSitemap(admin);
  for (const [k, v] of Object.entries(changes)) {
    if (k === 'frequency') await admin.locator('select[name="frequency"]').selectOption(v);
    else await setToggle(admin, k, v);
  }
  await submit(admin, SAVE);
  return flashText(admin);
}

const DEFAULTS = { enabled: true, robots: true, productGroups: true, announcements: true, knowledgebase: true, downloads: false, frequency: 'weekly' };

// ------------------------------------------------------------------ AD-55

/**
 * One boolean through the screen: from its default to the other value and
 * back, proving the stored key and what sitemap.xml lists each time.
 */
async function booleanRoundTrip({ admin, proof }, key, label, effect) {
  proof.claim(`"${label}" on the Sitemap screen is stored as sitemap_settings.${key} and sitemap.xml follows it on Save.`);
  proof.step('Press "Save & generate" with the shipped defaults, so the files start from a known state');
  await saveWith(admin, DEFAULTS);
  const cfg0 = cfg();
  const xml0 = read(SITEMAP);
  effect(proof, xml0, DEFAULTS[key], 'with the default');

  const flipped = !DEFAULTS[key];
  proof.step(`${flipped ? 'Tick' : 'Untick'} "${label}" and press "Save & generate"`);
  const flash = await saveWith(admin, { [key]: flipped });
  await proof.shot(admin, `Sitemap screen after saving ${key}=${flipped}`);
  await noErrorText(admin, proof, 'Sitemap screen');
  const cfg1 = cfg();
  proof.value(`sitemap_settings.${key}`, cfg0[key], cfg1[key]);
  proof.equal(`Save stored ${key} as ${flipped}`, cfg1[key], flipped);
  proof.check('the screen reports that the files were written', /Wrote sitemap\.xml/.test(flash), `flash: ${flash}`);
  proof.check(`the box shows ${flipped ? 'ticked' : 'unticked'} when the screen reloads`,
    (await admin.locator(`#sitemap-form input[name="${key}"]`).isChecked()) === flipped);
  const xml1 = read(SITEMAP);
  effect(proof, xml1, flipped, 'after the save');

  proof.step(`Set "${label}" back and press "Save & generate"`);
  await saveWith(admin, { [key]: DEFAULTS[key] });
  const cfg2 = cfg();
  proof.value(`sitemap_settings.${key} (set back)`, cfg1[key], cfg2[key]);
  proof.equal(`Save stored ${key} as ${DEFAULTS[key]} again`, cfg2[key], DEFAULTS[key]);
  effect(proof, read(SITEMAP), DEFAULTS[key], 'set back');
}

test('AD-55 "Enable sitemap" off empties the Hadrian block of sitemap.xml and the Sitemap: line', async ({ admin, proof }) => {
  await booleanRoundTrip({ admin, proof }, 'enabled', 'Enable sitemap', (p, xml, on, when) => {
    const list = locs(xml);
    if (on) {
      p.check(`${when}: sitemap.xml carries the Hadrian block and lists the site root`, xml.includes(MARK) && list.includes(`${BASE}/`), `${list.length} urls`);
      p.check(`${when}: robots.txt names the sitemap`, /^Sitemap: .*\/sitemap\.xml$/m.test(read(ROBOTS)));
    } else {
      p.check(`${when}: sitemap.xml has no Hadrian block and no URLs`, !xml.includes(MARK) && list.length === 0, `${list.length} urls`);
      p.check(`${when}: robots.txt no longer names the sitemap`, !/^Sitemap:/m.test(read(ROBOTS)), read(ROBOTS));
    }
  });
});

test('AD-55 "Manage robots.txt" off leaves robots.txt untouched', async ({ admin, proof }) => {
  proof.claim('"Manage robots.txt" is stored as sitemap_settings.robots; off, Save does not write robots.txt; on, it rewrites the Hadrian block.');
  await saveWith(admin, DEFAULTS);
  const cfg0 = cfg();
  const sentinel = '# hadrian sitemap generator start\nDisallow: /audit-sentinel-block/\n# hadrian sitemap generator end\n';
  fs.writeFileSync(ROBOTS, 'User-agent: AuditBot\nDisallow: /audit-hand-written/\n\n' + sentinel);
  ageFile(ROBOTS);
  const before = db.file('robots.txt');

  proof.step('Untick "Manage robots.txt" and press "Save & generate"');
  const flash = await saveWith(admin, { robots: false });
  await proof.shot(admin, 'Sitemap screen after robots off');
  const cfg1 = cfg();
  proof.value('sitemap_settings.robots', cfg0.robots, cfg1.robots);
  proof.equal('Save stored robots as false', cfg1.robots, false);
  proof.check('the flash names sitemap.xml only', /Wrote sitemap\.xml to/.test(flash) && !/robots\.txt/.test(flash), flash);
  const after = db.file('robots.txt');
  proof.value('robots.txt sha1, mtime', before, after);
  proof.equal('robots.txt is byte for byte what it was', after.sha1, before.sha1);
  proof.equal('robots.txt was not rewritten (mtime unchanged)', after.mtime, before.mtime);

  proof.step('Tick it again and press "Save & generate"');
  await saveWith(admin, { robots: true });
  proof.equal('Save stored robots as true', cfg().robots, true);
  const robots = read(ROBOTS);
  proof.check('robots.txt was rewritten: the old block is gone', !robots.includes('/audit-sentinel-block/'), robots);
  proof.check('and the new block names the sitemap', /^Sitemap: .*\/sitemap\.xml$/m.test(robots), robots);
});

for (const [key, label, re] of [
  ['productGroups', 'Product groups', RE.groups],
  ['announcements', 'Announcements', RE.announcements],
  ['knowledgebase', 'Knowledge base', RE.knowledgebase],
  ['downloads', 'Downloads', RE.downloads],
]) {
  test(`AD-55 "${label}" decides whether sitemap.xml lists them`, async ({ admin, proof }) => {
    await booleanRoundTrip({ admin, proof }, key, label, (p, xml, on, when) => {
      const n = count(locs(xml), re);
      p.check(`${when} (${key}=${on}): sitemap.xml lists ${on ? 'some' : 'no'} ${label.toLowerCase()} addresses`, on ? n > 0 : n === 0, `${n} matching ${re}`);
    });
  });
}

test('AD-55 Change frequency is stored and written into every <changefreq>; an unknown value falls back to weekly', async ({ admin, proof }) => {
  proof.claim('The frequency select is stored as sitemap_settings.frequency, every URL in sitemap.xml carries it, and a value outside the seven allowed ones is stored as "weekly".');
  await saveWith(admin, DEFAULTS);
  const cfg0 = cfg();
  proof.step('Pick "Daily" and press "Save & generate"');
  await saveWith(admin, { frequency: 'daily' });
  await proof.shot(admin, 'Sitemap screen after Daily');
  const cfg1 = cfg();
  proof.value('sitemap_settings.frequency', cfg0.frequency, cfg1.frequency);
  proof.equal('Save stored frequency "daily"', cfg1.frequency, 'daily');
  const f1 = freqs(read(SITEMAP));
  proof.check('every <changefreq> in sitemap.xml is "daily"', f1.length > 0 && f1.every(f => f === 'daily'), `${f1.length} entries: ${[...new Set(f1)]}`);
  proof.equal('the select shows Daily when the screen reloads', await admin.locator('select[name="frequency"]').inputValue(), 'daily');

  proof.step('Add an option "fortnightly" to the select in the page, pick it, press Save');
  await openSitemap(admin);
  await admin.locator('select[name="frequency"]').evaluate(s => { const o = document.createElement('option'); o.value = 'fortnightly'; o.textContent = 'Fortnightly'; s.appendChild(o); s.value = 'fortnightly'; });
  await submit(admin, SAVE);
  const cfg2 = cfg();
  proof.value('sitemap_settings.frequency (bad value posted)', cfg1.frequency, cfg2.frequency);
  proof.equal('the unknown value was stored as "weekly"', cfg2.frequency, 'weekly');
  const f2 = freqs(read(SITEMAP));
  proof.check('every <changefreq> is "weekly" again', f2.length > 0 && f2.every(f => f === 'weekly'), [...new Set(f2)].join(','));
});

// ------------------------------------------------------------------ AD-56

test('AD-56 Generate now rewrites sitemap.xml and the robots.txt block, keeping what is outside the markers', async ({ admin, proof }) => {
  proof.claim('Generate now writes sitemap.xml and the marked block of robots.txt from the saved settings; <url> entries and robots lines outside the markers survive.');
  await saveWith(admin, DEFAULTS);

  proof.step('Write a sitemap.xml with a hand-added <url> outside the markers and a stale Hadrian block, and a robots.txt with hand-written lines and a stale block; age both by an hour');
  fs.writeFileSync(SITEMAP, `<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
  <url><loc>${BASE}/audit-hand-added</loc><changefreq>yearly</changefreq><priority>0.1</priority></url>
<!-- hadrian sitemap generator start --><url><loc>${BASE}/audit-stale-entry</loc><changefreq>never</changefreq><priority>0.1</priority></url><!-- hadrian sitemap generator end -->
</urlset>
`);
  fs.writeFileSync(ROBOTS, 'User-agent: AuditBot\nDisallow: /audit-hand-written/\n\n# hadrian sitemap generator start\nDisallow: /audit-stale-block/\n# hadrian sitemap generator end\n');
  ageFile(SITEMAP); ageFile(ROBOTS);
  const xmlBefore = db.file('sitemap.xml');
  const robotsBefore = db.file('robots.txt');

  await openSitemap(admin);
  proof.step('Press "Generate now"');
  await submit(admin, admin.locator('a.mt-btn', { hasText: 'Generate now' }));
  const flash = await flashText(admin);
  await proof.shot(admin, 'Sitemap screen after Generate now');
  proof.check('the screen reports both files written', /Wrote sitemap\.xml and robots\.txt/.test(flash), flash);

  const xmlAfter = db.file('sitemap.xml');
  const robotsAfter = db.file('robots.txt');
  proof.value('sitemap.xml sha1, mtime', xmlBefore, xmlAfter);
  proof.check('sitemap.xml mtime moved forward', xmlAfter.mtime > xmlBefore.mtime, `${xmlBefore.mtime} -> ${xmlAfter.mtime}`);
  proof.check('sitemap.xml content changed', xmlAfter.sha1 !== xmlBefore.sha1);
  const list = locs(read(SITEMAP));
  proof.check('the hand-added <url> outside the markers survived', list.includes(`${BASE}/audit-hand-added`), list.slice(0, 5).join(' '));
  proof.check('the stale entry inside the old block is gone', !list.includes(`${BASE}/audit-stale-entry`));
  proof.check('the new block lists the site root and the rest', list.includes(`${BASE}/`) && list.length > 10, `${list.length} urls`);
  proof.equal('there is exactly one Hadrian block', read(SITEMAP).split(MARK).length - 1, 1);

  proof.value('robots.txt sha1, mtime', robotsBefore, robotsAfter);
  proof.check('robots.txt mtime moved forward', robotsAfter.mtime > robotsBefore.mtime);
  const robots = read(ROBOTS);
  proof.check('the hand-written robots lines survived', robots.includes('User-agent: AuditBot\nDisallow: /audit-hand-written/'), robots);
  proof.check('the stale block line is gone', !robots.includes('/audit-stale-block/'), robots);
  proof.check('the new block names the sitemap', robots.includes(`Sitemap: ${BASE}/sitemap.xml`), robots);
  proof.equal('robots.txt has exactly one Hadrian block', robots.split(MARK).length - 1, 1);
  proof.note('Not atomic (FEATURES.md): sitemap.xml and robots.txt are written with two plain file_put_contents calls (SitemapGenerator::write), so a failure between them leaves one new and one old. Not provoked here.');
});

test('AD-56 Generate now uses the saved settings, not the toggles on screen', async ({ admin, proof }) => {
  proof.claim('"Generate now uses the saved settings" (screen help text): an unsaved toggle does not change what is written.');
  await saveWith(admin, DEFAULTS);
  await openSitemap(admin);
  proof.step('Untick Announcements on screen, do not save, press "Generate now"');
  await setToggle(admin, 'announcements', false);
  await submit(admin, admin.locator('a.mt-btn', { hasText: 'Generate now' }));
  proof.equal('sitemap_settings.announcements is still true', cfg().announcements, true);
  proof.check('sitemap.xml still lists announcements', count(locs(read(SITEMAP)), RE.announcements) > 0);
  proof.check('the box is ticked again after the reload', await admin.locator('#sitemap-form input[name="announcements"]').isChecked());
});

// ------------------------------------------------------------------ AD-57

test('AD-57 A page set to "Disallow indexing" leaves sitemap.xml and gets Disallow lines, the routed one ending in $', async ({ admin, proof }) => {
  proof.claim('Knowledgebase set to Disallow in Pages: its address leaves sitemap.xml, robots.txt disallows the script and the routed address with a trailing $, and single articles stay listed.');
  await saveWith(admin, DEFAULTS);
  const kbHome = `${BASE}/index.php?rp=/knowledgebase`;
  const before = locs(read(SITEMAP));
  proof.check('to begin with the knowledgebase is listed at its routed address, not knowledgebase.php', before.includes(kbHome) && !before.includes(`${BASE}/knowledgebase.php`));
  proof.check('announcements likewise', before.includes(`${BASE}/index.php?rp=/announcements`) && !before.includes(`${BASE}/announcements.php`));
  const rowBefore = db.page('knowledgebase');

  proof.step('Pages > Knowledgebase: pick "Disallow indexing", press Save changes; then Sitemap > Generate now');
  await admin.goto(adminUrl('pages', { sub: 'edit', page: 'knowledgebase' }));
  await admin.locator('select[name="indexing"]').selectOption('disallow');
  await submit(admin, '#page-edit-form .mt-savebar button[type="submit"]');
  const rowAfter = db.page('knowledgebase');
  proof.value('hadrian_pages.indexing (knowledgebase)', rowBefore.indexing, rowAfter.indexing);
  await openSitemap(admin);
  await submit(admin, admin.locator('a.mt-btn', { hasText: 'Generate now' }));

  const list = locs(read(SITEMAP));
  const robots = read(ROBOTS);
  await proof.shot(admin, 'Sitemap screen after Generate now');
  proof.check('the knowledgebase address left sitemap.xml', !list.includes(kbHome));
  proof.check('single articles are still listed (a Disallow is not a prefix ban on them)', count(list, RE.knowledgebase) > 0);
  proof.check('robots.txt disallows the script', /^Disallow: \/knowledgebase\.php$/m.test(robots), robots);
  proof.check('and the routed address, ending in $', /^Disallow: \/index\.php\?rp=\/knowledgebase\$$/m.test(robots), robots);
});

test('AD-57 Hidden product groups, private and translated KB rows and hidden download categories are left out', async ({ admin, proof }) => {
  proof.claim('sitemap.xml lists only public content: hidden groups, private articles, translation rows and hidden categories are left out.');
  await saveWith(admin, { ...DEFAULTS, downloads: true });
  const list = locs(read(SITEMAP));
  const data = phpEval(`
    $q = fn($t) => \\WHMCS\\Database\\Capsule::table($t);
    return [
      'groups'  => $q('tblproductgroups')->get(['id', 'slug', 'hidden'])->all(),
      'kb'      => $q('tblknowledgebase')->get(['id', 'private', 'parentid'])->all(),
      'kbcats'  => $q('tblknowledgebasecats')->get(['id', 'hidden', 'catid'])->all(),
      'dlcats'  => $q('tbldownloadcats')->get(['id', 'hidden'])->all(),
    ];`);
  const on = v => v === 1 || v === '1' || v === 'on';
  const groupListed = slug => list.some(u => u.endsWith(`/store/${slug}`));
  const kbListed = id => list.some(u => new RegExp(`\\?rp=/knowledgebase/${id}/[^/]+\\.html$`).test(u));
  const dlListed = id => list.some(u => new RegExp(`\\?rp=/download/category/${id}/`).test(u));
  for (const g of data.groups) proof.equal(`product group ${g.slug} (hidden=${g.hidden}) listed = ${!on(g.hidden)}`, groupListed(g.slug), !on(g.hidden));
  for (const a of data.kb) {
    const want = !on(a.private) && !(Number(a.parentid) > 0);
    proof.equal(`KB article ${a.id} (private=${JSON.stringify(a.private)}, parentid=${a.parentid}) listed = ${want}`, kbListed(a.id), want);
  }
  for (const c of data.dlcats) proof.equal(`download category ${c.id} (hidden=${c.hidden}) listed = ${!on(c.hidden)}`, dlListed(c.id), !on(c.hidden));
  proof.limit('This install has no hidden group, private article or translation row, so these checks only prove the visible side. The driver test below makes those rows on purpose.');
});

test('AD-57 Content rules against rows made for the purpose (tests/php/sitemap.php check)', async ({ proof }) => {
  proof.claim('The generator leaves out hidden, private and translation rows and follows changes, checked against rows the driver creates and removes.');
  proof.step('Run tests/php/sitemap.php check (it backs up and restores both files itself)');
  const results = php('sitemap.php', 'check');
  proof.check('the driver ran its checks', Array.isArray(results) && results.length > 20, `${results.length} checks`);
  const failed = results.filter(r => !r.ok);
  for (const r of results.filter(r => /hidden|private|translat|Disallow|\$/i.test(r.name))) proof.check(r.name, r.ok, r.detail || '');
  proof.check('every driver check passed', failed.length === 0, failed.map(r => `${r.name}: ${r.detail || ''}`).join('; '));
  proof.limit('Supplementary: this drives SitemapGenerator in PHP, not through the screen. The screen-driven proofs are the two tests above.');
});

// ------------------------------------------------------------------ AD-58

test('AD-58 Saving a page in Pages rewrites sitemap.xml and robots.txt without opening Sitemap', async ({ admin, proof }) => {
  proof.claim('Once the sitemap is set up, a page saved in Pages with a different indexing rewrites both files by itself.');
  await saveWith(admin, DEFAULTS);
  const address = `${BASE}/contact.php`;
  proof.check('Contact is listed to begin with', locs(read(SITEMAP)).includes(address));
  ageFile(SITEMAP); ageFile(ROBOTS);
  const xmlBefore = db.file('sitemap.xml');
  const robotsBefore = db.file('robots.txt');

  proof.step('Pages > Contact: pick "Disallow indexing", press Save changes (Sitemap screen not opened)');
  await admin.goto(adminUrl('pages', { sub: 'edit', page: 'contact' }));
  const sel = admin.locator('select[name="indexing"]');
  const was = await sel.inputValue();
  await sel.selectOption('disallow');
  await submit(admin, '#page-edit-form .mt-savebar button[type="submit"]');
  await proof.shot(admin, 'Pages > Contact after Save');
  proof.value('hadrian_pages.indexing (contact)', was, db.page('contact').indexing);
  const xmlAfter = db.file('sitemap.xml');
  proof.value('sitemap.xml sha1, mtime', xmlBefore, xmlAfter);
  proof.check('sitemap.xml was rewritten', xmlAfter.mtime > xmlBefore.mtime && xmlAfter.sha1 !== xmlBefore.sha1);
  proof.check('Contact left sitemap.xml', !locs(read(SITEMAP)).includes(address));
  proof.check('robots.txt was rewritten', db.file('robots.txt').mtime > robotsBefore.mtime);
  proof.check('and disallows /contact.php', /^Disallow: \/contact\.php$/m.test(read(ROBOTS)), read(ROBOTS));

  proof.step('Set it back and press Save changes');
  await admin.goto(adminUrl('pages', { sub: 'edit', page: 'contact' }));
  await admin.locator('select[name="indexing"]').selectOption(was);
  await submit(admin, '#page-edit-form .mt-savebar button[type="submit"]');
  proof.check('Contact is listed again', locs(read(SITEMAP)).includes(address));
  proof.check('and no longer disallowed', !/^Disallow: \/contact\.php$/m.test(read(ROBOTS)));
  proof.limit('The other triggers (module publish, AnnouncementAdd/Edit, daily cron) are not driven here; tests/php/sitemap.php check covers announcements and module pages.');
});

test('AD-58 A Pages save that changes nothing the files list leaves them alone', async ({ admin, proof }) => {
  proof.claim('The refresh rewrites a file only when its content would differ.');
  await saveWith(admin, DEFAULTS);
  ageFile(SITEMAP); ageFile(ROBOTS);
  const xmlBefore = db.file('sitemap.xml');
  const robotsBefore = db.file('robots.txt');
  proof.step('Pages > Contact: press Save changes without changing anything');
  await admin.goto(adminUrl('pages', { sub: 'edit', page: 'contact' }));
  await submit(admin, '#page-edit-form .mt-savebar button[type="submit"]');
  const xmlAfter = db.file('sitemap.xml');
  const robotsAfter = db.file('robots.txt');
  proof.value('sitemap.xml mtime', xmlBefore.mtime, xmlAfter.mtime);
  proof.equal('sitemap.xml untouched (mtime)', xmlAfter.mtime, xmlBefore.mtime);
  proof.equal('robots.txt untouched (mtime)', robotsAfter.mtime, robotsBefore.mtime);
});

test('AD-58 Before the sitemap is set up, a Pages save writes nothing', async ({ admin, proof }) => {
  proof.claim('Nothing is written until an admin has saved the Sitemap settings or generated the files once.');
  proof.step('Remove sitemap_settings and leave files with no Hadrian markers (hand-written content only)');
  phpEval(`\\WHMCS\\Database\\Capsule::table('hadrian_settings')->where('setting', 'sitemap_settings')->delete(); return true;`);
  fs.writeFileSync(SITEMAP, `<?xml version="1.0" encoding="UTF-8"?>\n<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9"><url><loc>${BASE}/audit-only</loc></url></urlset>\n`);
  fs.writeFileSync(ROBOTS, 'User-agent: *\nDisallow: /audit-only/\n');
  ageFile(SITEMAP); ageFile(ROBOTS);
  const xmlBefore = db.file('sitemap.xml');
  const robotsBefore = db.file('robots.txt');
  proof.check('no sitemap_settings row', db.setting('sitemap_settings') === null);

  proof.step('Pages > Contact: pick "Disallow indexing", press Save changes');
  await admin.goto(adminUrl('pages', { sub: 'edit', page: 'contact' }));
  await admin.locator('select[name="indexing"]').selectOption('disallow');
  await submit(admin, '#page-edit-form .mt-savebar button[type="submit"]');
  proof.equal('Contact was saved as disallow', db.page('contact').indexing, 'disallow');
  proof.value('sitemap.xml sha1', xmlBefore.sha1, db.file('sitemap.xml').sha1);
  proof.equal('sitemap.xml is byte for byte what it was', db.file('sitemap.xml').sha1, xmlBefore.sha1);
  proof.equal('robots.txt is byte for byte what it was', db.file('robots.txt').sha1, robotsBefore.sha1);
  proof.check('still no sitemap_settings row', db.setting('sitemap_settings') === null);
});

// ------------------------------------------------------------------ AD-59

test('AD-59 "Last written" shows the sitemap.xml mtime, "Not generated yet" without the file', async ({ admin, proof }) => {
  proof.claim('The Generate panel shows when sitemap.xml was last written, or "Not generated yet." when there is none.');
  await saveWith(admin, DEFAULTS);
  const fixed = new Date('2026-01-02T03:04:30Z');
  fs.utimesSync(SITEMAP, fixed, fixed);
  const expected = phpEval(`return date('Y-m-d H:i', filemtime(ROOTDIR . '/sitemap.xml'));`);
  proof.step(`Set sitemap.xml mtime to ${fixed.toISOString()} and open the Sitemap screen`);
  await openSitemap(admin);
  const panel = admin.locator('.mt-section', { hasText: 'Generate' }).filter({ has: admin.locator('a', { hasText: 'Generate now' }) });
  const text = await panel.innerText();
  await proof.shot(panel, 'Generate panel with a known mtime');
  proof.check(`the panel says "Last written: ${expected}"`, text.includes(`Last written: ${expected}`), text.slice(0, 200));

  proof.step('Remove sitemap.xml and reload');
  fs.unlinkSync(SITEMAP);
  await openSitemap(admin);
  const text2 = await panel.innerText();
  await proof.shot(panel, 'Generate panel with no sitemap.xml');
  proof.check('the panel says "Not generated yet."', text2.includes('Not generated yet.'), text2.slice(0, 200));
});

test('AD-59 Preview XML opens the sitemap for the toggles on screen and writes nothing', async ({ admin, proof }) => {
  proof.claim('Preview XML answers with the XML for the settings as they are on screen, in a new tab, and saves and writes nothing.');
  await saveWith(admin, DEFAULTS);
  const before = db.file('sitemap.xml');
  const cfgBefore = cfg();
  await openSitemap(admin);
  proof.step('Untick Knowledge base on screen (no save), press Preview XML');
  await setToggle(admin, 'knowledgebase', false);
  const [tab, res] = await Promise.all([
    admin.waitForEvent('popup'),
    admin.context().waitForEvent('response', r => /sub=preview/.test(r.url())),
    admin.locator('[data-sitemap-preview]').click(),
  ]);
  const xml = await res.text();
  await tab.waitForLoadState('domcontentloaded').catch(() => {});
  await proof.shot(tab, 'Preview XML tab');
  proof.equal('the preview answers 200', res.status(), 200);
  proof.check('as an XML document, not an admin page', /application\/xml/.test(res.headers()['content-type'] || '') && xml.trimStart().startsWith('<?xml') && !xml.includes('mt-wrap'));
  proof.check('with Knowledge base off on screen it lists no KB addresses', count(locs(xml), RE.knowledgebase) === 0);
  proof.check('and still lists the rest', locs(xml).includes(`${BASE}/`) && count(locs(xml), RE.announcements) > 0);
  await tab.close();
  const after = db.file('sitemap.xml');
  proof.value('sitemap.xml sha1, mtime', before, after);
  proof.equal('sitemap.xml was not written', after, before);
  proof.equal('sitemap_settings was not saved', cfg(), cfgBefore);
});

test('AD-59 The "web root isn\'t writable" banner appears only when PHP cannot write the root', async ({ admin, proof }) => {
  proof.claim('A warning banner says generation will fail when the web root is not writable by PHP.');
  await openSitemap(admin);
  const banner = admin.locator('.mt-alert-warning', { hasText: "isn't writable" });
  proof.equal('with a writable root, no banner', await banner.count(), 0);

  proof.step('Set the read-only attribute on the WHMCS root folder (PHP is_writable() then answers false on Windows), reload, then clear it');
  const dir = WHMCS_ROOT.replace(/\//g, '\\');
  const set = spawnSync('attrib', ['+r', dir], { encoding: 'utf8', shell: false });
  try {
    proof.check('attrib +r ran', set.status === 0, set.stderr || set.stdout);
    await openSitemap(admin);
    const n = await banner.count();
    await proof.shot(admin, 'Sitemap screen with a read-only root');
    proof.equal('the banner is shown', n, 1);
  } finally {
    spawnSync('attrib', ['-r', dir], { encoding: 'utf8' });
  }
  await openSitemap(admin);
  proof.equal('with the attribute cleared, the banner is gone again', await banner.count(), 0);
  proof.limit('On Windows the folder read-only attribute does not stop file writes, so this proves the banner, not that generation then fails.');
});
