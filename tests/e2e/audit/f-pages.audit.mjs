// AD-F Pages screen (tests/FEATURES.md AD-43 to AD-54): the Pages list and
// the page editor driven the way an admin drives them (pick a template card,
// change a control, press Save changes), then proven in the hadrian_pages row
// and on the client area.

import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import { spawnSync } from 'node:child_process';
import { test, db, settings, php, useAuditBackup, adminUrl, html, noErrorText, setChecked } from './harness.mjs';
import { PHP, WHMCS_ROOT, BASE_URL } from '../../lib/env.mjs';

useAuditBackup();
test.beforeEach(() => { settings.snapshot(); });
test.afterEach(() => { settings.restore(); });

const TPL = 'hadrian';
const str = v => [v, 'string'];
const EDIT = page => adminUrl('pages', { sub: 'edit', page });
const LIST = adminUrl('pages');
const SAVE = '#page-edit-form .mt-savebar button[type="submit"]';
const json = v => { try { return v == null ? null : JSON.parse(v); } catch { return v; } };
const rowOf = page => {
  const r = db.page(page);
  if (r) { r.settings = json(r.settings); r.seo_title = json(r.seo_title); r.seo_description = json(r.seo_description); }
  return r;
};

/**
 * Local driver: run a PHP body against the booted WHMCS install and return
 * what it returns, as JSON. For the few things no tests/php driver offers
 * (deleting one registry row, asking MediaUsage, reading the colour schema).
 * Refuses unless SystemURL is localhost, like every driver.
 */
function phpEval(body) {
  const file = path.join(os.tmpdir(), `hadrian-audit-f-${process.pid}-${Date.now()}.php`);
  fs.writeFileSync(file, `<?php
chdir(${JSON.stringify(WHMCS_ROOT)});
require_once 'init.php';
// init.php may already have loaded it through the other side of the junction;
// a second require_once by a different path is a "Cannot redeclare" fatal.
if (!function_exists('HadrianAutoload') && !class_exists('Hadrian\\\\Helpers\\\\AddonHelper', false)) { require_once 'modules/addons/Hadrian/autoload.php'; }
$u = (string) \\WHMCS\\Database\\Capsule::table('tblconfiguration')->where('setting', 'SystemURL')->value('value');
if (!preg_match('~^https?://(localhost|127\\.0\\.0\\.1)([:/]|$)~i', $u)) { fwrite(STDERR, "not a local install\\n"); exit(2); }
$fn = function () { ${body} };
echo "\\n", json_encode($fn(), JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE), "\\n";
`);
  try {
    const r = spawnSync(PHP, [file], { encoding: 'utf8', timeout: 120_000, cwd: WHMCS_ROOT });
    if (r.status !== 0) throw new Error(`phpEval exited ${r.status}: ${r.stdout}${r.stderr}`);
    return JSON.parse(r.stdout.trim().split('\n').pop());
  } finally {
    fs.rmSync(file, { force: true });
  }
}

/** Press Save changes in the page editor and wait for the saved page. */
async function save(admin, proof) {
  await Promise.all([admin.waitForURL(/flash=saved/, { timeout: 45_000 }), admin.locator(SAVE).click()]);
  if (proof) await noErrorText(admin, proof, 'page editor after Save');
}

async function bodyOf(page, url) {
  await page.goto(url);
  return page.locator('body').evaluate(b => Object.fromEntries([...b.attributes].map(a => [a.name, a.value])));
}

/** The attributes on <body> in the raw server HTML, before any script runs. */
async function rawBody(page, url) {
  const r = await html(page, url);
  const tag = (r.body.match(/<body\b[^>]*>/i) || [''])[0];
  const attrs = {};
  for (const m of tag.matchAll(/([a-z-]+)="([^"]*)"/gi)) attrs[m[1]] = m[2];
  return { status: r.status, url: r.url, attrs };
}

/** Pick a value in a <select> the form does not offer, the way a hand-edited form would post it. */
async function forceSelect(admin, selector, value) {
  await admin.locator(selector).evaluate((s, v) => {
    const o = document.createElement('option'); o.value = v; o.textContent = v; s.appendChild(o); s.value = v;
  }, value);
}

// ------------------------------------------------------- AD-43 self-heal

test('AD-43 Opening the Pages list re-seeds a missing row and imports legacy settings', async ({ admin, proof }) => {
  proof.claim('The Pages list rebuilds the page and layout caches and runs PageRegistry::sync, which seeds a row for any page that has none, importing the legacy <tpl>_page_variant_/<tpl>_page_options_ settings.');
  settings.set({
    [`${TPL}_page_variant_login`]: str('split'),
    [`${TPL}_page_options_login`]: [JSON.stringify({ visibility: 'public', indexing: 'disallow', seo: { title: 'Legacy audit title' } }), 'json'],
  });
  proof.step('Delete the hadrian_pages row of "login" and the page and layout caches (php driver)');
  const gone = phpEval(`
    $n = \\WHMCS\\Database\\Capsule::table('hadrian_pages')->where('template', 'hadrian')->where('page', 'login')->delete();
    $c = \\WHMCS\\Database\\Capsule::table('hadrian_settings')->whereIn('setting', ['hadrian_pages_discovered', 'hadrian_layouts_discovered'])->delete();
    return ['rows' => $n, 'caches' => $c];`);
  proof.check('the row was deleted', gone.rows === 1, JSON.stringify(gone));
  const before = rowOf('login');
  proof.equal('no login row before the list is opened', before, null);

  proof.step('Open Addons > Hadrian > Pages');
  await admin.goto(LIST);
  await noErrorText(admin, proof, 'Pages list');
  await proof.shot(admin, 'Pages list');
  const after = rowOf('login');
  proof.value('hadrian_pages login row', before, after && { variant: after.variant, indexing: after.indexing, seo_title: after.seo_title });
  proof.check('the login row is back', !!after);
  proof.equal('the legacy variant was imported', after?.variant, 'split');
  proof.equal('the legacy indexing was imported', after?.indexing, 'disallow');
  proof.equal('the legacy SEO title was imported', after?.seo_title, 'Legacy audit title');
  proof.check('the page cache was rebuilt', db.setting('hadrian_pages_discovered') !== null);
  proof.check('the layout cache was rebuilt', db.setting('hadrian_layouts_discovered') !== null);
  proof.check('the list shows the login row', (await admin.locator('[data-page-row][data-key="login"]').count()) === 1);
  proof.limit('Migrator::migrate() runs on the same hit, but every migration has already run on this install, so the test cannot show it doing work.');
});

// ----------------------------------------------------------- AD-44 list UI

test('AD-44 Pages list: views, search, system pages, badges and Open links', async ({ admin, visit, proof }) => {
  proof.claim('The list shows one row per page with area views and counts, a search, a system-page toggle, change badges (template, signed-in only, own layout), and an Open link to the page\'s public address.');
  settings.variant({ login: 'split' });
  settings.page({ knowledgebase: { visibility: 'auth', settings: { layout_overrides: { 'main-menu': 'top', footer: null } } } });
  await admin.goto(LIST);
  await noErrorText(admin, proof, 'Pages list');
  const rows = admin.locator('[data-page-row]');
  const total = await rows.count();
  proof.check('the list has rows', total > 30, `${total} rows`);
  const nonSystem = await admin.locator('[data-page-row]:not([data-system])').count();
  proof.equal('"All pages" counts every row that is not a system page', Number(await admin.locator('[data-count-for="all"]').innerText()), nonSystem);
  const areaSum = await admin.locator('[data-count-for="website"], [data-count-for="client"], [data-count-for="order"]').allInnerTexts();
  proof.equal('the three area counts add up to "All pages"', areaSum.reduce((a, n) => a + Number(n), 0), nonSystem);
  proof.step('Press the "Client area" view');
  await admin.locator('button[data-view="client"]').click();
  const areas = await rows.evaluateAll(rs => [...new Set(rs.filter(r => !r.hidden).map(r => r.getAttribute('data-area')))]);
  proof.equal('the view shows client-area pages only', areas, ['client']);
  await admin.locator('button[data-view="all"]').click();

  const sysCount = await admin.locator('[data-page-row][data-system]').count();
  proof.check('system pages exist and are hidden by default', sysCount > 0 && !(await admin.locator('[data-page-row][data-key="two-factor-challenge"]').isVisible()), `${sysCount} system rows`);
  proof.step('Switch "Show system pages" on');
  await setChecked(admin.locator('#mt-pages-showsys'), true);
  proof.check('two-factor-challenge is shown', await admin.locator('[data-page-row][data-key="two-factor-challenge"]').isVisible());
  await setChecked(admin.locator('#mt-pages-showsys'), false);

  proof.step('Type "knowledge" in the search box');
  await admin.locator('#mt-pages-search').fill('knowledge');
  const shown = await rows.evaluateAll(rs => rs.filter(r => !r.hidden).map(r => r.getAttribute('data-key')));
  proof.check('only matching rows are shown, the knowledgebase among them', shown.length > 0 && shown.includes('knowledgebase') && shown.length < total, shown.join(', '));
  await proof.shot(admin, 'list filtered by search');
  await admin.locator('#mt-pages-search').fill('');

  const kb = admin.locator('[data-page-row][data-key="knowledgebase"]');
  proof.check('knowledgebase carries the "Signed-in only" badge', (await kb.locator('[data-page-change="auth"]').innerText()).includes('Signed-in only'));
  proof.check('knowledgebase carries the "Own layout" badge', (await kb.locator('[data-page-change="layout"]').count()) === 1);
  const login = admin.locator('[data-page-row][data-key="login"]');
  proof.check('login carries the "Template: ..." badge', /Template:/.test(await login.locator('[data-page-change="template"]').innerText()));
  proof.step('Press "Changed by you"');
  await admin.locator('button[data-view="changed"]').click();
  const changed = await rows.evaluateAll(rs => rs.filter(r => !r.hidden).map(r => [r.getAttribute('data-key'), r.hasAttribute('data-changed')]));
  proof.check('the view lists the changed pages', changed.some(([k]) => k === 'knowledgebase') && changed.some(([k]) => k === 'login'), changed.map(c => c[0]).join(', '));
  proof.check('and only pages marked as changed', changed.length < nonSystem && changed.every(([, c]) => c), `${changed.length} of ${nonSystem}`);
  await proof.shot(admin, 'Changed by you');
  await admin.locator('button[data-view="all"]').click();

  const open = admin.locator('[data-page-row][data-key="contact"] a[data-page-open]');
  const href = await open.getAttribute('href');
  proof.check('contact has an Open link to its public address', /contact\.php$/.test(href || ''), href);
  proof.equal('it opens in a new tab', await open.getAttribute('target'), '_blank');
  const guest = await visit('guest');
  const r = await html(guest, href);
  proof.equal('the address answers 200 for a guest', r.status, 200);
  const notes = await admin.locator('[data-page-note]').allInnerTexts();
  proof.note(`"Replaced by" notes on this install: ${notes.length ? notes.join(' | ') : 'none (no extension page stands in for a theme page here)'}`);
});

// ------------------------------------------------------- AD-45 variant pick

test('AD-45 Picking a template card and saving switches the page\'s markup', async ({ admin, visit, proof }) => {
  proof.claim('The template pick is stored as the row\'s variant and the client page renders that variant\'s .tpl.');
  settings.variant({ login: 'default' });
  const guest = await visit('guest');
  await guest.goto('/login');
  proof.check('before: /login renders the Default card', (await guest.locator('.auth-card').count()) === 1 && (await guest.locator('.mt-loginscreen').count()) === 0);

  await admin.goto(EDIT('login'));
  await noErrorText(admin, proof, 'login editor');
  const before = rowOf('login').variant;
  proof.step('Press the "Split + Announcements" template card');
  const split = admin.locator('label.mt-variant:has(input[name="variant"][value="split"])');
  await split.click();
  proof.check('the card says it is selected and needs Save', /Selected/.test(await split.locator('.mt-badge').innerText()));
  await proof.shot(admin.locator('.mt-variant-grid'), 'template cards after the click');
  proof.step('Press Save changes');
  await save(admin, proof);
  const after = rowOf('login').variant;
  proof.value('variant', before, after);
  proof.equal('stored variant is "split"', after, 'split');
  proof.check('the editor marks Split active', /Active/.test(await admin.locator('label.mt-variant:has(input[value="split"]) .mt-badge').innerText()));
  await guest.goto('/login');
  proof.check('/login now renders the split screen', (await guest.locator('.mt-loginscreen').count()) === 1 && (await guest.locator('.auth-card').count()) === 0);
  proof.check('and is full-bleed', /mt-login-fullpage/.test(await guest.locator('body').getAttribute('class')));
  await proof.shot(guest, 'login on the split template');

  proof.step('Press the "Beacon" card and Save');
  await admin.locator('label.mt-variant:has(input[name="variant"][value="beacon"])').click();
  await save(admin);
  proof.equal('stored variant is "beacon"', rowOf('login').variant, 'beacon');
  await guest.goto('/login');
  proof.equal('/login renders the Beacon screen', await guest.locator('.mt-bcn').count(), 1);
});

test('AD-45 A stale stored variant falls back to the default, and an unknown one is not stored', async ({ admin, visit, proof }) => {
  proof.claim('Only variants on disk are accepted on save; a stored variant whose folder is gone shows and renders as the default.');
  settings.variant({ login: 'removed-variant' });
  await admin.goto(EDIT('login'));
  proof.check('the editor marks Default active for a stale stored variant', await admin.locator('label.mt-variant.is-active:has(input[value="default"])').count() === 1);
  const guest = await visit('guest');
  await guest.goto('/login');
  proof.equal('the page renders the default template', await guest.locator('.auth-card').count(), 1);

  proof.step('Change the Split card\'s radio value to "evil" in the page, pick it and Save');
  await admin.locator('input[name="variant"][value="split"]').evaluate(r => { r.value = 'evil'; r.checked = true; });
  await save(admin);
  proof.value('variant', 'removed-variant', rowOf('login').variant);
  proof.equal('an unknown variant is stored as the page default', rowOf('login').variant, 'default');
});

// ----------------------------------------------------- AD-46 template options

test('AD-46 Template options save as key__variant, typed, allow-listed and carried through', async ({ admin, visit, proof }) => {
  proof.claim('Variant options are stored as <key>__<variant>, page options under their own key; bools are booleans, selects are allow-listed, options not on the form keep their stored value; the page reads them as $hadrian.pages.login.options.*.');
  settings.variant({ login: 'split' });
  settings.page({ login: { settings: { options: { bcn_field_style__beacon: 'solid', info_right: false } } } });
  const guest = await visit('guest');
  await guest.goto('/login');
  const ls0 = guest.locator('.mt-loginscreen');
  proof.equal('before: the split panel is "light" and on the left', [await ls0.getAttribute('data-ls-style'), /is-info-right/.test(await ls0.getAttribute('class'))], ['light', false]);

  await admin.goto(EDIT('login'));
  const before = rowOf('login').settings.options;
  proof.step('Set Panel style to "gradient", switch "Info panel on the right" on');
  await admin.locator('select[name="option[spl_panel_style__split]"]').selectOption('gradient');
  await setChecked(admin.locator('input[type="checkbox"][name="option[info_right]"]'), true);
  proof.step('Remove Beacon\'s "Field style" select from the page (as a screen that does not render it would), then Save');
  await admin.locator('select[name="option[bcn_field_style__beacon]"]').evaluate(s => s.remove());
  await save(admin, proof);
  await proof.shot(admin, 'login editor after Save');
  const opts = rowOf('login').settings.options;
  proof.value('settings.options', before, opts);
  proof.equal('spl_panel_style__split is stored as "gradient"', opts.spl_panel_style__split, 'gradient');
  proof.check('no bare spl_panel_style key is written', !('spl_panel_style' in opts));
  proof.equal('info_right is stored as boolean true', opts.info_right, true);
  proof.equal('show_logo is a boolean too', typeof opts.show_logo, 'boolean');
  proof.equal('Beacon\'s option, not on the form, kept its stored value', opts.bcn_field_style__beacon, 'solid');
  await guest.goto('/login');
  const ls = guest.locator('.mt-loginscreen');
  proof.equal('the split panel is now gradient', await ls.getAttribute('data-ls-style'), 'gradient');
  proof.check('and on the right', /is-info-right/.test(await ls.getAttribute('class')));
  await proof.shot(guest, 'login with the new options');

  proof.step('Add "evil" to the Panel style select in the page, pick it and Save');
  await admin.goto(EDIT('login'));
  await forceSelect(admin, 'select[name="option[spl_panel_style__split]"]', 'evil');
  await save(admin);
  proof.equal('a value not on the list is stored as the option default', rowOf('login').settings.options.spl_panel_style__split, 'light');
});

test('AD-46 An int option is coerced to a number', async ({ admin, proof }) => {
  proof.claim('An option declared int is stored as an integer, whatever the form posts.');
  settings.variant({ clientareahome: 'minimal' });
  await admin.goto(EDIT('clientareahome'));
  const input = admin.locator('input[name="option[min_visible_rows__minimal]"]');
  proof.step('Make "Rows shown" a text field in the page, type "7abc" and Save');
  await input.evaluate(i => { i.type = 'text'; i.value = '7abc'; });
  await save(admin, proof);
  const v = rowOf('clientareahome').settings.options.min_visible_rows__minimal;
  proof.value('min_visible_rows__minimal', '7abc', v);
  proof.equal('stored as the integer 7', v, 7);
});

// --------------------------------------------------- AD-47 section builder

test('AD-47 Section options: the builder is scoped to its variant and its swatches are resolved', async ({ admin, visit, proof }) => {
  proof.claim('Each "sections" option is handed to the builder with its own variant\'s in-block options only and with colour swatches resolved from the colour schema; the saved layout string drives the dashboard.');
  settings.variant({ clientareahome: 'minimal' });
  settings.page({ clientareahome: { settings: { options: { min_sections__minimal: '', bnt_sections__bento: 'services:1/1,tickets:1/2' } } } });
  await admin.goto(EDIT('clientareahome'));
  await noErrorText(admin, proof, 'dashboard editor');
  const specs = JSON.parse(await admin.locator('#mtSectionSpecs').textContent());
  proof.check('the builder gets a spec for each variant\'s sections option', !!specs.min_sections__minimal && !!specs.bnt_sections__bento, Object.keys(specs).join(', '));
  proof.equal('the minimal spec belongs to minimal', specs.min_sections__minimal.variant, 'minimal');
  const inBlockKeys = spec => Object.values(spec.inBlock || {}).flatMap(o => Object.keys(o));
  const bentoIn = inBlockKeys(specs.bnt_sections__bento);
  proof.check('bento\'s in-block options are all bento\'s own', bentoIn.length > 0 && bentoIn.every(k => k.endsWith('__bento')), bentoIn.join(', '));
  for (const [k, spec] of Object.entries(specs)) {
    const own = inBlockKeys(spec);
    proof.check(`${k}: no other variant's in-block options`, own.every(o => o.endsWith('__' + spec.variant)), own.join(', '));
  }
  const expected = phpEval(`
    $t = \\Hadrian\\Helpers\\AddonHelper::getTemplate();
    $cfg = \\Hadrian\\Helpers\\ThemeManifest::loadVariantMeta($t->getFullPath() . '/core/config/colors.php');
    $d = [];
    foreach (($cfg['groups'] ?? []) as $tokens) { foreach ($tokens as $tk) { if (isset($tk['var'])) { $d[$tk['var']] = (string)($tk['light'] ?? ''); } } }
    $active = (string)\\Hadrian\\Models\\Settings::getValue('hadrian_active_style', 'default');
    if ($active === 'dark' || $active === '') { $active = 'default'; }
    $s = \\Hadrian\\Models\\Settings::getValue('hadrian_colors_' . $active . '_light', null);
    if (!is_array($s) || $s === []) { $s = \\Hadrian\\Models\\Settings::getValue('hadrian_colors_' . $active, []); }
    $s = is_array($s) ? $s : [];
    return ['accent' => (string)($s['--color-accent'] ?? $d['--color-accent'] ?? ''), 'green' => (string)($s['--color-icon-green'] ?? $d['--color-icon-green'] ?? '')];`);
  const paints = specs.min_sections__minimal.paints;
  proof.equal('the Accent swatch is the resolved --color-accent', paints.accent?.swatch, expected.accent);
  proof.equal('the Green swatch is the resolved --color-icon-green', paints.green?.swatch, expected.green);
  proof.check('every swatch is a colour, not a token name', Object.values(paints).every(p => /^#[0-9a-f]{6}$/i.test(p.swatch) || /^rgba?\(/.test(p.swatch)), JSON.stringify(paints).slice(0, 300));

  const layout = 'tickets:1/2::green_tint,services:1/1,domains:off,invoices:1/2,announcements:off,domainreg:off,profile:off';
  proof.step(`Set the Minimal dashboard sections to "${layout}" (the builder's own field) and Save`);
  await admin.locator('[name="option[min_sections__minimal]"]').evaluate((i, v) => { i.value = v; }, layout);
  await save(admin, proof);
  const opts = rowOf('clientareahome').settings.options;
  proof.value('min_sections__minimal', '', opts.min_sections__minimal);
  proof.equal('the layout string is stored under the minimal key', opts.min_sections__minimal, layout);
  // The bento builder re-serialises a non-empty layout on every Save (edit.tpl:
  // dirty = stored value is non-empty), appending the catalogue entries the
  // string left out at their factory widths. Same arrangement, longer string.
  const bento = String(opts.bnt_sections__bento || '').split(',').map(e => e.split(':').slice(0, 2).join(':'));
  const bentoKeys = Object.keys(specs.bnt_sections__bento.sections || {});
  proof.check('bento\'s own arrangement is kept: services full width before tickets half width', bento.indexOf('services:1/1') >= 0 && bento.indexOf('services:1/1') < bento.indexOf('tickets:1/2'), opts.bnt_sections__bento);
  proof.check('and it holds only bento\'s own sections', bento.every(e => bentoKeys.includes(e.split(':')[0])), opts.bnt_sections__bento);
  proof.note(`Saving with Minimal selected rewrote bento's stored layout from "services:1/1,tickets:1/2" to "${opts.bnt_sections__bento}": the unselected template's builder re-serialises any non-empty value on submit (views/adminarea/pages/edit.tpl:1246 and :1281). It lists the same arrangement in full.`);

  const client = await visit('full');
  await client.goto('/clientarea.php');
  const secs = await client.locator('.min-grid-custom > .min-section').evaluateAll(els => els.map(e => [e.dataset.sec, e.dataset.blkPaint || '', e.dataset.blkFill || '']));
  proof.equal('the dashboard draws the visible sections in the saved order, the off ones gone, tickets painted green tint', secs, [['tickets', 'green', 'tint'], ['services', '', ''], ['invoices', '', '']]);
  await proof.shot(client, 'dashboard with the saved section layout', { fullPage: true });
  proof.limit('The layout string is set on the builder\'s own form field rather than by dragging cards; the drag UI is covered by builder.spec.');
  // Last, so the facts above are all recorded: the promise is that a save on
  // one template leaves the other template's sections option as stored.
  proof.equal('bento\'s stored layout is untouched by a save on Minimal', opts.bnt_sections__bento, 'services:1/1,tickets:1/2');
});

// ------------------------------------------------------- AD-48 visibility

test('AD-48 Visibility: public, signed-in only and disabled', async ({ admin, visit, proof }) => {
  proof.claim('Visibility is allow-listed to public, auth and disabled; auth sends a guest to sign in, disabled answers 404 to everyone but a signed-in admin.');
  const guest = await visit('guest');
  const client = await visit('full');
  proof.equal('before: a guest gets the knowledgebase', (await html(guest, '/knowledgebase')).status, 200);
  const setVis = async v => {
    await admin.goto(EDIT('knowledgebase'));
    await admin.locator('select[name="visibility"]').selectOption(v);
    await save(admin, proof);
  };

  proof.step('Set Visibility to "Authenticated only" and Save');
  await setVis('auth');
  proof.value('visibility', 'public', rowOf('knowledgebase').visibility);
  proof.equal('stored as "auth"', rowOf('knowledgebase').visibility, 'auth');
  await guest.goto('/knowledgebase');
  proof.check('a guest is sent to the sign-in page', /login/i.test(guest.url()) || (await guest.locator('body').getAttribute('data-tpl')) === 'login', guest.url());
  await proof.shot(guest, 'guest sent to sign in');
  const cb = await bodyOf(client, '/knowledgebase');
  proof.check('a signed-in client gets the page', /knowledgebase/.test(cb['data-tpl'] || ''), JSON.stringify(cb['data-tpl']));

  proof.step('Set Visibility to "Disabled (404)" and Save');
  await setVis('disabled');
  proof.equal('stored as "disabled"', rowOf('knowledgebase').visibility, 'disabled');
  proof.equal('a guest gets 404', (await html(guest, '/knowledgebase')).status, 404);
  proof.equal('a signed-in client gets 404', (await html(client, '/knowledgebase')).status, 404);
  const adminView = await html(admin, '/knowledgebase');
  proof.equal('a signed-in admin still sees it', adminView.status, 200);

  proof.step('Set Visibility back to "Public" and Save');
  await setVis('public');
  proof.equal('a guest gets the page again', (await html(guest, '/knowledgebase')).status, 200);

  proof.step('Add "secret" to the Visibility select in the page, pick it and Save');
  await admin.goto(EDIT('knowledgebase'));
  await forceSelect(admin, 'select[name="visibility"]', 'secret');
  await save(admin);
  proof.equal('an unknown visibility is stored as "public"', rowOf('knowledgebase').visibility, 'public');
});

test('AD-48 Visibility is offered on an exempt page, where it does nothing', async ({ admin, visit, proof }) => {
  proof.claim('Sign-in and the other exempt pages still show the Visibility select; saving "Disabled" there is stored but the page keeps answering.');
  await admin.goto(EDIT('login'));
  proof.check('the login editor offers Visibility', await admin.locator('select[name="visibility"]').isVisible());
  await admin.locator('select[name="visibility"]').selectOption('disabled');
  await save(admin, proof);
  proof.equal('stored as "disabled"', rowOf('login').visibility, 'disabled');
  const guest = await visit('guest');
  const r = await html(guest, '/login');
  proof.equal('a guest still gets the sign-in page', r.status, 200);
  proof.note('VisibilityGate::decide returns null for the Authentication group, the EXEMPT_PAGES and Template::ORDER_PAGES, so the select on those editors stores a value that never applies. The tooltip says so; the select is not hidden.');
});

// ----------------------------------------- AD-49 sub-nav, area, controls

test('AD-49 Section sub-nav per page overrides the global toggle', async ({ admin, visit, proof }) => {
  proof.claim('Sub-nav is allow-listed to inherit/on/off; off puts data-subnav-website="off" on the page, on removes it even when the global toggle is off.');
  settings.set({ website_subnav: ['1', 'bool'], subnav_pages_website: [JSON.stringify([]), 'json'] });
  const guest = await visit('guest');
  proof.equal('before (inherit, global on): no data-subnav-website', (await rawBody(guest, '/knowledgebase')).attrs['data-subnav-website'], undefined);
  const setSub = async v => { await admin.goto(EDIT('knowledgebase')); await admin.locator('select[name="subnav"]').selectOption(v); await save(admin, proof); };

  proof.step('Set Section sub-nav to "Off" and Save');
  await setSub('off');
  proof.value('settings.subnav', 'inherit', rowOf('knowledgebase').settings.subnav);
  proof.equal('stored as "off"', rowOf('knowledgebase').settings.subnav, 'off');
  proof.equal('the page carries data-subnav-website="off"', (await rawBody(guest, '/knowledgebase')).attrs['data-subnav-website'], 'off');
  proof.equal('another page does not', (await rawBody(guest, '/contact.php')).attrs['data-subnav-website'], undefined);

  proof.step('Switch the global Website sub-nav off, set the page to "On" and Save');
  settings.set({ website_subnav: ['0', 'bool'] });
  await setSub('on');
  proof.equal('stored as "on"', rowOf('knowledgebase').settings.subnav, 'on');
  proof.equal('the page shows its sub-nav (no attribute)', (await rawBody(guest, '/knowledgebase')).attrs['data-subnav-website'], undefined);
  proof.equal('while other pages follow the global off', (await rawBody(guest, '/contact.php')).attrs['data-subnav-website'], 'off');

  proof.step('Add "sideways" to the select in the page, pick it and Save');
  await admin.goto(EDIT('knowledgebase'));
  await forceSelect(admin, 'select[name="subnav"]', 'sideways');
  await save(admin);
  proof.equal('an unknown value is stored as "inherit"', rowOf('knowledgebase').settings.subnav, 'inherit');
});

test('AD-49 Area per page, with empty meaning automatic', async ({ admin, visit, proof }) => {
  proof.claim('Area is allow-listed to website/client/order; the page carries data-area for its pick; empty is automatic.');
  const guest = await visit('guest');
  proof.equal('before: the knowledgebase is in the website area', (await bodyOf(guest, '/knowledgebase'))['data-area'], 'website');
  await admin.goto(EDIT('knowledgebase'));
  proof.equal('the select starts on Automatic', await admin.locator('select[name="area"]').inputValue(), '');
  proof.step('Set Area to "Client area" and Save');
  await admin.locator('select[name="area"]').selectOption('client');
  await save(admin, proof);
  proof.value('settings.area', '', rowOf('knowledgebase').settings.area);
  proof.equal('stored as "client"', rowOf('knowledgebase').settings.area, 'client');
  proof.equal('the page carries data-area="client"', (await bodyOf(guest, '/knowledgebase'))['data-area'], 'client');
  await proof.shot(guest, 'knowledgebase moved to the client area');

  proof.step('Add "mars" to the select in the page, pick it and Save');
  await forceSelect(admin, 'select[name="area"]', 'mars');
  await save(admin);
  proof.equal('an unknown area is stored as "" (automatic)', rowOf('knowledgebase').settings.area, '');
  proof.equal('the page is back in the website area', (await bodyOf(guest, '/knowledgebase'))['data-area'], 'website');
});

test('AD-49 Controls placement per page', async ({ admin, visit, proof }) => {
  proof.claim('Controls placement is allow-listed to inherit/inside/outside, offered only on the list pages, and outside puts data-svc-layout="outside" on that page.');
  settings.set({ service_controls_outside: ['0', 'bool'], svc_layout_pages: [JSON.stringify([]), 'json'] });
  await admin.goto(EDIT('knowledgebase'));
  proof.equal('not offered on a page without list controls', await admin.locator('select[name="svclayout"]').count(), 0);
  const client = await visit('full');
  const url = '/clientarea.php?action=services';
  proof.equal('before: the services list has no data-svc-layout', (await rawBody(client, url)).attrs['data-svc-layout'], undefined);

  await admin.goto(EDIT('clientareaproducts'));
  proof.step('Set Controls placement to "Outside the card" and Save');
  await admin.locator('select[name="svclayout"]').selectOption('outside');
  await save(admin, proof);
  proof.value('settings.svclayout', 'inherit', rowOf('clientareaproducts').settings.svclayout);
  proof.equal('stored as "outside"', rowOf('clientareaproducts').settings.svclayout, 'outside');
  proof.equal('the services list carries data-svc-layout="outside"', (await rawBody(client, url)).attrs['data-svc-layout'], 'outside');
  proof.equal('the invoices list does not', (await rawBody(client, '/clientarea.php?action=invoices')).attrs['data-svc-layout'], undefined);
  await client.goto(url);
  await proof.shot(client, 'services list, controls outside');

  proof.step('Switch the global placement to outside, set the page to "Inside the card" and Save');
  settings.set({ service_controls_outside: ['1', 'bool'] });
  await admin.locator('select[name="svclayout"]').selectOption('inside');
  await save(admin);
  proof.equal('the page stays inside', (await rawBody(client, url)).attrs['data-svc-layout'], undefined);
  proof.equal('the invoices list follows the global outside', (await rawBody(client, '/clientarea.php?action=invoices')).attrs['data-svc-layout'], 'outside');

  proof.step('Add "diagonal" to the select in the page, pick it and Save');
  await forceSelect(admin, 'select[name="svclayout"]', 'diagonal');
  await save(admin);
  proof.equal('an unknown value is stored as "inherit"', rowOf('clientareaproducts').settings.svclayout, 'inherit');
});

// -------------------------------------------- AD-50 indexing and public URL

test('AD-50 Indexing and public URL: meta robots, sitemap.xml and robots.txt follow the save', async ({ admin, visit, proof }) => {
  proof.claim('Indexing is allow-listed; "Disallow" adds a noindex meta tag and Save rewrites sitemap.xml and robots.txt; the URL is trimmed and cut to 255 characters with nothing else checked.');
  php('sitemap.php', 'backup');
  const files0 = { sitemap: db.file('sitemap.xml'), robots: db.file('robots.txt') };
  try {
    const listed = php('sitemap.php', 'begin');
    const target = listed.find(p => p.page === 'contact') || listed.find(p => p.url && !/^built-/.test(p.page) && !['announcements', 'knowledgebase'].includes(p.page));
    proof.check('a theme page with an address is in the sitemap', !!target, JSON.stringify(listed.slice(0, 5)));
    const address = `${BASE_URL}/${target.url.replace(/^\//, '')}`;
    const pathPart = '/' + target.url.replace(/^\//, '');
    proof.check('it is listed to begin with', php('sitemap.php', 'files').urls.includes(address));
    const guest = await visit('guest');
    const robotsMeta = async () => { await guest.goto(pathPart); return guest.locator('meta[name="robots"]').getAttribute('content').catch(() => null); };
    await guest.goto(pathPart);
    proof.equal('no robots meta before', await guest.locator('meta[name="robots"]').count(), 0);

    await admin.goto(EDIT(target.page));
    const indexingBefore = await admin.locator('select[name="indexing"]').inputValue();
    proof.step(`Set Indexing to "Disallow indexing" on ${target.page} and Save`);
    await admin.locator('select[name="indexing"]').selectOption('disallow');
    await save(admin, proof);
    proof.value('indexing', indexingBefore, rowOf(target.page).indexing);
    proof.equal('stored as "disallow"', rowOf(target.page).indexing, 'disallow');
    proof.equal('the page carries <meta name="robots" content="noindex, nofollow">', await robotsMeta(), 'noindex, nofollow');
    let files = php('sitemap.php', 'files');
    proof.check('sitemap.xml no longer lists it', !files.urls.includes(address), address);
    proof.check('robots.txt disallows it', files.disallow.includes(pathPart), files.disallow.join(' '));
    await proof.shot(guest, 'page with noindex');

    proof.step(`Set Indexing back to "${indexingBefore}" and Save`);
    await admin.locator('select[name="indexing"]').selectOption(indexingBefore);
    await save(admin);
    files = php('sitemap.php', 'files');
    proof.check('it is listed again', files.urls.includes(address));
    proof.check('and no longer disallowed', !files.disallow.includes(pathPart));

    proof.step('Add "nofollow-ish" to the Indexing select in the page, pick it and Save');
    await forceSelect(admin, 'select[name="indexing"]', 'nofollow-ish');
    await save(admin);
    proof.equal('an unknown indexing value is stored as "inherit"', rowOf(target.page).indexing, 'inherit');

    proof.step('Remove the URL field\'s maxlength in the page, type "/" + 300 characters with spaces around, and Save');
    const urlBefore = rowOf(target.page).url;
    const long = 'audit-' + 'x'.repeat(300);
    await admin.locator('input[name="url"]').evaluate((i, v) => { i.removeAttribute('maxlength'); i.value = v; }, `   /${long}   `);
    await save(admin);
    const stored = rowOf(target.page).url;
    proof.value('url', urlBefore, stored);
    proof.equal('stored trimmed, without the leading slash and cut to 255 characters', stored, ('/' + long).slice(0, 255).replace(/^\//, ''));
    proof.step('Type "odd path?x=1" and Save');
    await admin.locator('input[name="url"]').fill('odd path?x=1');
    await save(admin);
    proof.equal('nothing else is checked: the value is stored as typed', rowOf(target.page).url, 'odd path?x=1');
    proof.step('Put the address back and Save');
    await admin.locator('input[name="url"]').fill(urlBefore || '');
    await save(admin);
    proof.equal('the address is back', rowOf(target.page).url, urlBefore);
  } finally {
    php('sitemap.php', 'restore');
  }
  const files1 = { sitemap: db.file('sitemap.xml'), robots: db.file('robots.txt') };
  proof.equal('sitemap.xml and robots.txt are back as they were', [files1.sitemap.sha1 ?? null, files1.robots.sha1 ?? null], [files0.sitemap.sha1 ?? null, files0.robots.sha1 ?? null]);
});

// ------------------------------------------------- AD-51 SEO title/description

test('AD-51 SEO title and description reach <title> and the meta description', async ({ admin, visit, proof }) => {
  proof.claim('Title and description are stored per effective language, capped at 200 and 400 characters, empty maps are stored as null, and the page prints them in <title>, meta description and og:title.');
  await admin.goto(EDIT('contact'));
  const lang = await admin.locator('#seo-langs').getAttribute('data-default-lang');
  const title = admin.locator(`input[name="seo_title[${lang}]"]`);
  const desc = admin.locator(`textarea[name="seo_description[${lang}]"]`);
  const setVal = (loc, v) => loc.evaluate((n, val) => { n.removeAttribute('maxlength'); n.value = val; n.dispatchEvent(new Event('input', { bubbles: true })); }, v);
  const before = rowOf('contact');

  proof.step(`Type an SEO title and description for ${lang}, and a title for "klingon" (not a language of this install), then Save`);
  await setVal(title, 'Audit SEO title & co');
  await setVal(desc, 'Audit SEO description for the contact page.');
  await admin.locator('#page-edit-form').evaluate(f => { const i = document.createElement('input'); i.type = 'hidden'; i.name = 'seo_title[klingon]'; i.value = 'nuqneH'; f.appendChild(i); });
  await save(admin, proof);
  const after = rowOf('contact');
  proof.value('seo_title, seo_description', [before.seo_title, before.seo_description], [after.seo_title, after.seo_description]);
  proof.equal(`the title is stored for ${lang}`, after.seo_title?.[lang], 'Audit SEO title & co');
  proof.check('the klingon title was not stored', !('klingon' in (after.seo_title || {})), JSON.stringify(after.seo_title));
  proof.equal(`the description is stored for ${lang}`, after.seo_description?.[lang], 'Audit SEO description for the contact page.');
  const guest = await visit('guest');
  await guest.goto('/contact.php');
  proof.equal('<title> is the SEO title', await guest.title(), 'Audit SEO title & co');
  proof.equal('meta description is the SEO description', await guest.locator('meta[name="description"]').getAttribute('content'), 'Audit SEO description for the contact page.');
  proof.equal('og:title agrees', await guest.locator('meta[property="og:title"]').getAttribute('content'), 'Audit SEO title & co');

  proof.step('Type a 250-character title and a 450-character description and Save');
  await setVal(admin.locator(`input[name="seo_title[${lang}]"]`), 'T'.repeat(250));
  await setVal(admin.locator(`textarea[name="seo_description[${lang}]"]`), 'D'.repeat(450));
  await save(admin);
  const capped = rowOf('contact');
  proof.equal('the title is cut to 200 characters', capped.seo_title?.[lang]?.length, 200);
  proof.equal('the description is cut to 400 characters', capped.seo_description?.[lang]?.length, 400);

  proof.step('Empty every language\'s title and description and Save');
  await admin.locator('input[name^="seo_title["], textarea[name^="seo_description["]').evaluateAll(els => els.forEach(e => { e.value = ''; }));
  await save(admin);
  const empty = db.page('contact');
  proof.equal('an empty title map is stored as null', empty.seo_title, null);
  proof.equal('an empty description map is stored as null', empty.seo_description, null);
  await guest.goto('/contact.php');
  proof.check('the page falls back to its default title', (await guest.title()) !== 'T'.repeat(200) && (await guest.title()).length > 0, await guest.title());
  await proof.shot(guest, 'contact page after SEO cleared');
});

// ------------------------------------------------------- AD-52 social image

test('AD-52 Social image reaches og:image, is cut at 500 and is counted as a media use', async ({ admin, visit, proof }) => {
  proof.claim('The Social image URL field (a media picker) is stored up to 500 characters, printed as og:image, and MediaUsage reports it as a use of that library file.');
  await admin.goto(EDIT('contact'));
  const input = admin.locator('#seo-social');
  proof.check('the field is a media picker', (await input.getAttribute('data-mt-media')) !== null && (await input.getAttribute('data-mt-media-value')) === 'url');
  const file = 'audit-social-image.png';
  const url = `${BASE_URL}/templates/hadrian/assets/img/media/${file}`;
  proof.step(`Type ${url} in Social image URL and Save`);
  await input.evaluate((i, v) => { i.value = v; i.dispatchEvent(new Event('input', { bubbles: true })); }, url);
  const before = rowOf('contact').seo_image;
  await save(admin, proof);
  const stored = rowOf('contact').seo_image;
  proof.value('seo_image', before, stored);
  proof.equal('stored as typed', stored, url);
  const guest = await visit('guest');
  await guest.goto('/contact.php');
  proof.equal('og:image is the URL', await guest.locator('meta[property="og:image"]').getAttribute('content'), url);
  proof.equal('twitter:card switches to summary_large_image', await guest.locator('meta[name="twitter:card"]').getAttribute('content'), 'summary_large_image');
  const usage = phpEval(`return \\Hadrian\\Helpers\\MediaUsage::of([${JSON.stringify(file)}]);`);
  proof.check('MediaUsage counts the file as used by the contact page', JSON.stringify(usage).includes('Social image of the page \\"contact\\"'), JSON.stringify(usage));

  proof.step('Remove the field\'s maxlength in the page, type a 600-character URL and Save');
  await admin.locator('#seo-social').evaluate(i => { i.removeAttribute('maxlength'); i.value = 'https://localhost/' + 'i'.repeat(582); });
  await save(admin);
  proof.equal('the image URL is cut to 500 characters', rowOf('contact').seo_image.length, 500);
  proof.step('Clear the field and Save');
  await admin.locator('#seo-social').evaluate(i => { i.value = ''; });
  await save(admin);
  await guest.goto('/contact.php');
  proof.equal('no og:image once cleared', await guest.locator('meta[property="og:image"]').count(), 0);
});

// --------------------------------------------------- AD-53 layout override

test('AD-53 A page can use its own layout while the others keep the site\'s', async ({ admin, visit, proof }) => {
  proof.claim('Custom layout per page must be a real layout; the page draws it while other pages keep the site pick; Inherit (empty) goes back.');
  settings.set({
    [`${TPL}_layout_mode`]: null,
    [`${TPL}_active_layout_main-menu_guest`]: str('sidebar'), [`${TPL}_active_layout_main-menu_client`]: str('sidebar'),
    [`${TPL}_active_layout_footer_guest`]: str('extended'), [`${TPL}_active_layout_footer_client`]: str('extended'),
  });
  const guest = await visit('guest');
  const look = async url => { const b = await bodyOf(guest, url); return [b['data-layout'], await guest.locator('footer.hp-footer').getAttribute('class')]; };
  proof.equal('before: the knowledgebase has the sidebar and the extended footer', await look('/knowledgebase'), ['side', 'hp-footer hp-footer-extended']);

  await admin.goto(EDIT('knowledgebase'));
  proof.step('Set Custom layout: main menu "Top", footer "Default", and Save');
  await admin.locator('select[name="layout_main_menu"]').selectOption('top');
  await admin.locator('select[name="layout_footer"]').selectOption('default');
  await save(admin, proof);
  const lo = rowOf('knowledgebase').settings.layout_overrides;
  proof.value('settings.layout_overrides', { 'main-menu': null, footer: null }, lo);
  proof.equal('both overrides are stored', lo, { 'main-menu': 'top', footer: 'default' });
  proof.equal('the knowledgebase draws top navigation and the slim footer', await look('/knowledgebase'), ['top', 'hp-footer hp-footer-slim']);
  await proof.shot(guest, 'knowledgebase with its own layout');
  proof.equal('the contact page keeps the site layout', await look('/contact.php'), ['side', 'hp-footer hp-footer-extended']);

  proof.step('Add "no-such-layout" to the main-menu select in the page, pick it and Save');
  await forceSelect(admin, 'select[name="layout_main_menu"]', 'no-such-layout');
  await save(admin);
  proof.equal('an unknown layout is stored as null (inherit)', rowOf('knowledgebase').settings.layout_overrides['main-menu'], null);
  proof.step('Set the footer back to Inherit and Save');
  await admin.locator('select[name="layout_footer"]').selectOption('');
  await save(admin);
  proof.equal('both overrides are null', rowOf('knowledgebase').settings.layout_overrides, { 'main-menu': null, footer: null });
  proof.equal('the knowledgebase is back on the site layout', await look('/knowledgebase'), ['side', 'hp-footer hp-footer-extended']);
});

// ------------------------------------------------------ AD-54 extension pages

test('AD-54 Extension pages get rows and leave with their pages', async ({ admin, proof }) => {
  proof.claim('A page an extension module (Page Builder) reports gets a registry row and a list row with its status; the module owns url and published; a row whose page is gone is deleted on the next list visit.');
  let id = null;
  try {
    let seeded;
    try { seeded = php('builder.php', 'seed', 'E2E Audit extension page', 'e2e-audit-ext'); } catch (e) {
      test.skip(true, `Hadrian Page Builder is not mounted: ${e.message.split('\n')[0]}`);
    }
    id = seeded.id;
    const key = `built-${id}`;
    proof.step('Make a draft built page (builder.php seed) and open the Pages list');
    await admin.goto(LIST);
    await noErrorText(admin, proof, 'Pages list');
    const row = rowOf(key);
    proof.check('the built page has a registry row', !!row, key);
    proof.equal('the module owns its address', row?.url, 'e2e-audit-ext');
    proof.equal('a draft is not published', Number(row?.published), 0);
    const listRow = admin.locator(`[data-page-row][data-key="${key}"]`);
    await admin.locator('#mt-pages-search').fill('e2e audit extension');
    proof.equal('the list shows it', await listRow.count(), 1);
    proof.check('marked "Built"', (await listRow.locator('.mt-pl-built').count()) === 1);
    const status = await listRow.locator('[data-page-status]').innerText().catch(() => '');
    proof.check('with its status badge', status.trim().length > 0, status);
    proof.check('and an "Edit content" link into the module', (await listRow.locator('a[data-page-content]').count()) === 1);
    await proof.shot(listRow, 'built page row');

    proof.step('Delete the built page in the module\'s own table only (php driver), then open the Pages list again');
    phpEval(`return \\WHMCS\\Database\\Capsule::table('hadrian_builder_pages')->where('id', ${Number(id)})->delete();`);
    proof.check('its registry row is still there before the visit', !!rowOf(key));
    await admin.goto(LIST);
    proof.equal('the visit deleted the row of the page that is gone', rowOf(key), null);
    proof.limit('The other half of the promise (a module whose listing FAILED keeps its rows) cannot be caused from the browser; tests/php/test-extension-page-rows covers it.');
  } finally {
    try { php('builder.php', 'clean'); } catch { /* not mounted */ }
  }
});
