// AD-H Menu screens (tests/FEATURES.md AD-60 to AD-69): Addons > Hadrian >
// Menu (list, editor, Menus by area, the preset tools) driven in the browser,
// proven in hadrian_menus / hadrian_menu_items and in what the client area
// renders for a guest or the `full` client.
//
// Every test changes menus, so each one starts from the state the file began
// with: afterEach restores the useAuditBackup() snapshot and takes it again.
// afterAll proves with db.hash() that the menus came back exactly.

import { spawnSync } from 'node:child_process';
import { test, db, php, useAuditBackup, adminUrl, submit, flashText, noErrorText, setChecked } from './harness.mjs';
import { WHMCS_ROOT, PHP } from '../../lib/env.mjs';

useAuditBackup();
let hashBefore = null;
test.beforeAll(() => { hashBefore = db.hash(); });
test.afterEach(() => { php('audit-state.php', 'restore'); php('audit-state.php', 'backup'); });
test.afterAll(() => {
  const after = db.hash();
  if (JSON.stringify(after) !== JSON.stringify(hashBefore)) {
    throw new Error(`menus were not put back: before ${JSON.stringify(hashBefore)}, after ${JSON.stringify(after)}`);
  }
});

// ----------------------------------------------------------------- helpers

const SAVE = '#menuForm .mt-savebar button[type="submit"]';
const PRESET_COUNTS = {
  'Client Main Menu': 29, 'Client Main Menu — WHMCS Defaults': 44, 'Guest Main Menu': 37,
  'Guest Main Menu — WHMCS Defaults': 24, 'Footer Menu': 34, 'Footer Secondary Menu': 5,
};
const esc = s => s.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');

/** Run PHP with WHMCS booted, for test setup and read-only lookups the harness has no driver for. */
function phpEval(body) {
  const code = `chdir(${JSON.stringify(WHMCS_ROOT)}); require 'init.php'; require_once 'modules/addons/Hadrian/autoload.php';
    $u = (string) \\WHMCS\\Database\\Capsule::table('tblconfiguration')->where('setting', 'SystemURL')->value('value');
    if (!preg_match('~^https?://(localhost|127\\.0\\.0\\.1)([:/]|$)~i', $u)) { fwrite(STDERR, 'REFUSING: not a local install'); exit(2); }
    $T = fn($t) => \\WHMCS\\Database\\Capsule::table($t);
    $out = (function () use ($T) { ${body} })();
    echo "\\n", json_encode($out, JSON_UNESCAPED_SLASHES), "\\n";`;
  const r = spawnSync(PHP, ['-r', code], { encoding: 'utf8', timeout: 120_000 });
  if (r.status !== 0) throw new Error(`phpEval exited ${r.status}: ${r.stdout}${r.stderr}`);
  return JSON.parse(r.stdout.trim().split('\n').pop());
}

const menuNamed = (name, location) => db.menus().find(m => m.name === name && (!location || m.location === location));
const itemsOf = id => (db.menu(id)?.items || []).map(r => ({
  ...r, label: JSON.parse(r.label_json || '{}'), config: (() => { const c = JSON.parse(r.config_json || '{}'); return Array.isArray(c) ? {} : c; })(),
}));
const english = it => it?.label?.custom?.english ?? '';
const topLevel = list => list.filter(i => i.parent_id === null).sort((a, b) => a.position - b.position);
const areaPicks = () => { const v = db.setting('menus_by_area'); return v ? JSON.parse(v) : {}; };
const itemCountRaw = id => phpEval(`return $T('hadrian_menu_items')->where('menu_id', ${Number(id)})->count();`);

async function openList(admin, tab = 'main') {
  await admin.goto(adminUrl('menu', { tab }));
  await admin.locator('.mt-page-title', { hasText: 'Menu' }).waitFor();
}
async function openEditor(admin, id) {
  await admin.goto(adminUrl('menu', { sub: 'edit', id }));
  await admin.locator('#menuForm').waitFor();
}
const acceptDialogs = page => page.on('dialog', d => d.accept().catch(() => {}));

/** The editor row whose name reads exactly `label`. */
const row = (admin, label) => admin.locator('#mtMenuTree .mt-menu-item-row')
  .filter({ has: admin.locator('.mt-menu-name', { hasText: new RegExp(`^\\s*${esc(label)}\\s*$`) }) });

async function openRow(admin, label) {
  const r = row(admin, label).first();
  await r.locator('[data-action="toggle-item"]').click();
  await admin.locator('#mtItemDrawer').waitFor({ state: 'visible' });
}

/** Expand a collapsible section of the open item panel ("label" or "display"). */
async function openSub(admin, name) {
  const sub = admin.locator(`#mtItemDrawer .mt-menu-sub[data-sub="${name}"]`);
  if (await sub.locator(':scope > .mt-menu-sub-body').isHidden()) await sub.locator(':scope > .mt-menu-sub-h').click();
}

/** "Add As" <type>, then "+ Add item" at the root (or the add-child button of `parent`). */
async function addItem(admin, type, { label, url, newTab, parent } = {}) {
  await admin.locator('#mtAddType').selectOption(type);
  if (parent) await row(admin, parent).first().locator('.mt-menu-btn-add').click();
  else await admin.locator('#mtAddBtn').click();
  await admin.locator('#mtItemDrawer').waitFor({ state: 'visible' });
  if (label !== undefined) await admin.locator('#drawerLabelEn').fill(label);
  if (url !== undefined) await admin.locator('#drawerUrl').fill(url);
  if (newTab) await setChecked(admin.locator('#mtItemDrawer input[data-drawer-field="config.target"]'), true);
}

/** Turn a hidden .mt-toggle checkbox on (harness setChecked: click/input/change fire). */
async function switchOn(box) {
  if (!(await setChecked(box, true))) throw new Error('the switch did not turn on');
}

async function saveEditor(admin) {
  await submit(admin, SAVE);
  return admin.url();
}

/** + New menu on a tab; returns the new menu id from the editor address. */
async function newMenu(admin, tab) {
  await openList(admin, tab);
  await submit(admin, admin.locator('button', { hasText: '+ New menu' }));
  const id = Number(new URL(admin.url()).searchParams.get('id'));
  return id;
}

async function home(visit, persona = 'guest', url = '/index.php') {
  const p = await visit(persona);
  await p.goto(url);
  return p;
}

// ------------------------------------------------------------------ AD-60

test('AD-60 Opening the Menu screen restores a preset whose items were wiped', async ({ admin, visit, proof }) => {
  proof.claim('Every Menu request runs the preset seeder: a preset menu with no items is refilled from the preset and switched back to its shipped status.');
  const fs = menuNamed('Footer Secondary Menu', 'footer-secondary');
  const guest = await home(visit);
  const link = () => guest.locator('.hp-footer-bottom-links a', { hasText: 'Cookie Policy' });
  proof.check('to begin with the guest footer shows "Cookie Policy"', (await link().count()) === 1);

  proof.step('Delete every item of Footer Secondary Menu and switch it off (setup, in the database)');
  phpEval(`$T('hadrian_menu_items')->where('menu_id', ${fs.id})->delete(); $T('hadrian_menus')->where('id', ${fs.id})->update(['active' => 0]); return true;`);
  const wiped = db.menu(fs.id);
  await guest.reload();
  proof.check('with the items gone, the footer no longer shows it', (await link().count()) === 0);

  proof.step('Open Addons > Hadrian > Menu');
  await openList(admin, 'footer-secondary');
  await proof.shot(admin, 'Menu list after the self-heal');
  const healed = db.menu(fs.id);
  proof.value('Footer Secondary Menu items, active', { items: wiped.items.length, active: wiped.menu.active }, { items: healed.items.length, active: healed.menu.active });
  proof.equal('the preset items are back', healed.items.length, PRESET_COUNTS['Footer Secondary Menu']);
  proof.equal('the menu is active again, as shipped', Number(healed.menu.active), 1);
  proof.equal('and marked as not edited by the admin', Number(healed.menu.changed_by_user), 0);
  await guest.reload();
  proof.check('the guest footer shows "Cookie Policy" again', (await link().count()) === 1);
  await proof.shot(guest.locator('.hp-footer-bottom'), 'guest footer after the self-heal');
});

test('AD-60 A preset the admin renamed is not created again by the self-heal', async ({ admin, visit, proof }) => {
  proof.claim('Renaming a preset in the editor and opening the Menu screen again does not bring the shipped preset back (bug 5).');
  const gm = menuNamed('Guest Main Menu', 'main');
  const countBefore = db.menus().length;
  await openEditor(admin, gm.id);
  proof.step('Editor: change the name to "Guest Main Menu (audit)" and press Save changes');
  await admin.locator('#menuForm input[name="name"]').fill('Guest Main Menu (audit)');
  await saveEditor(admin);
  proof.check('the editor confirms the save', /flash=saved/.test(admin.url()), admin.url());
  proof.step('Open the Menu list twice (each request runs the seeder)');
  await openList(admin, 'main');
  await openList(admin, 'main');
  await proof.shot(admin, 'Menu list after the rename');
  const menus = db.menus();
  const renamed = menus.find(m => m.id === gm.id);
  proof.value('menu name', gm.name, renamed.name);
  proof.equal('no new "Guest Main Menu" was created', menus.filter(m => m.name === 'Guest Main Menu' && m.location === 'main').length, 0);
  proof.equal('the number of menus is unchanged', menus.length, countBefore);
  proof.equal('the renamed menu is still active', Number(renamed.active), 1);
  const homeItem = topLevel(itemsOf(gm.id)).find(i => i.item_type === 'custom_link');
  const guest = await home(visit);
  proof.check('guests still get the renamed menu (its first link is in the sidebar)', (await guest.locator(`a[data-nav="mt-${homeItem.id}"]`).count()) > 0, `mt-${homeItem.id}`);
});

test('AD-60 The one-time conversion turns a custom link to a known WHMCS page into a page link', async ({ admin, visit, proof }) => {
  proof.claim('On the first Menu request after an upgrade, custom links whose URL is a known pickable WHMCS page become whmcs_page items (URL kept); new-tab and unknown links stay; it runs once.');
  const fs = menuNamed('Footer Secondary Menu', 'footer-secondary');
  proof.step('Reset hadrian_menu_migration_version to 0 and add three custom links to Footer Secondary Menu (setup, in the database)');
  const ids = phpEval(`
    $T('hadrian_settings')->updateOrInsert(['setting' => 'hadrian_menu_migration_version'], ['value' => '0']);
    $now = date('Y-m-d H:i:s');
    $mk = function ($label, $cfg, $pos) use ($T, $now) {
      return $T('hadrian_menu_items')->insertGetId(['menu_id' => ${fs.id}, 'parent_id' => null, 'position' => $pos, 'item_type' => 'custom_link',
        'label_json' => json_encode(['whmcs' => '', 'custom' => ['english' => $label]]), 'config_json' => json_encode($cfg), 'active' => 1, 'created_at' => $now, 'updated_at' => $now]);
    };
    return ['plain' => $mk('Audit Contact', ['url' => 'contact.php'], 10), 'blank' => $mk('Audit Contact New Tab', ['url' => 'contact.php', 'target' => '_blank'], 11), 'ext' => $mk('Audit External', ['url' => 'https://example.com/audit'], 12)];`);
  const before = itemsOf(fs.id).filter(i => Object.values(ids).includes(i.id)).map(i => [i.id, i.item_type]);

  proof.step('Open Addons > Hadrian > Menu');
  await openList(admin, 'footer-secondary');
  await proof.shot(admin, 'Menu list after the conversion ran');
  const after = Object.fromEntries(itemsOf(fs.id).filter(i => Object.values(ids).includes(i.id)).map(i => [i.id, i]));
  proof.value('item types', before, Object.values(after).map(i => [i.id, i.item_type]));
  proof.equal('the plain contact.php link is now a whmcs_page', after[ids.plain].item_type, 'whmcs_page');
  proof.equal('pointing at the contact page', after[ids.plain].config.page, 'contact');
  proof.equal('with its URL kept', after[ids.plain].config.url, 'contact.php');
  proof.equal('the new-tab link stayed a custom_link', after[ids.blank].item_type, 'custom_link');
  proof.equal('the external link stayed a custom_link', after[ids.ext].item_type, 'custom_link');
  proof.equal('the marker is set to 1', db.setting('hadrian_menu_migration_version'), '1');
  const guest = await home(visit);
  proof.check('the converted item still links to contact.php for guests', (await guest.locator('.hp-footer-bottom-links a[href="contact.php"]', { hasText: 'Audit Contact' }).count()) >= 1);
  proof.limit('Pending migrations (Migrator) are not provoked: dropping a migration row would rerun DDL on the live install.');
});

// ------------------------------------------------------------------ AD-61

test('AD-61 The Menu list shows one table per location with the right rows, counts and status', async ({ admin, proof }) => {
  proof.claim('Four location tabs, each listing that location\'s menus with item count and Active/Disabled status.');
  const all = db.menus();
  for (const tab of ['main', 'secondary', 'footer', 'footer-secondary']) {
    await openList(admin, tab);
    await noErrorText(admin, proof, `Menu list (${tab})`);
    proof.check(`the ${tab} tab is the active tab`, (await admin.locator('a.mt-tab.is-active[href*="action=menu&tab="]').getAttribute('href')).endsWith(`tab=${tab}`));
    const want = all.filter(m => m.location === tab);
    const rows = admin.locator('.mt-table tbody tr');
    proof.equal(`${tab}: one row per menu in that location`, await rows.count(), want.length);
    if (!want.length) {
      proof.check(`${tab}: the empty state offers to seed`, (await admin.locator('.mt-empty', { hasText: 'No menus yet' }).count()) === 1);
      continue;
    }
    for (const m of want) {
      const r = rows.filter({ has: admin.locator(`a[href$="sub=edit&id=${m.id}"]`) });
      const text = (await r.innerText()).replace(/\s+/g, ' ');
      proof.check(`${tab}: "${m.name}" shows ${m.items} items and ${Number(m.active) ? 'Active' : 'Disabled'}`,
        text.includes(`${m.items} items`) && text.includes(Number(m.active) ? 'Active' : 'Disabled'), text);
    }
    if (tab === 'main') await proof.shot(admin, 'Menu list, Main tab');
  }
  proof.limit('Area badges on a row are proven in AD-65.');
});

// ------------------------------------------------------------------ AD-62

test('AD-62 "+ New menu" creates a blank inactive menu in that location and opens the editor', async ({ admin, proof }) => {
  proof.claim('+ New menu on a tab creates "New menu" in that location, inactive with no items, and opens it in the editor.');
  const before = db.menus().filter(m => m.location === 'footer').length;
  proof.step('Menu > Footer tab: press "+ New menu"');
  const id = await newMenu(admin, 'footer');
  await proof.shot(admin, 'editor of the new menu');
  proof.check('the editor of the new menu opened', /sub=edit/.test(admin.url()) && /flash=created/.test(admin.url()) && id > 0, admin.url());
  proof.check('the editor says it was created', (await flashText(admin)).includes('Menu created'), await flashText(admin));
  const m = db.menu(id);
  proof.value('footer menus', before, db.menus().filter(x => x.location === 'footer').length);
  proof.equal('stored as "New menu" in footer, audience client, inactive', { name: m.menu.name, location: m.menu.location, audience: m.menu.audience, active: Number(m.menu.active) },
    { name: 'New menu', location: 'footer', audience: 'client', active: 0 });
  proof.equal('with no items', m.items.length, 0);
  proof.equal('the name field shows "New menu"', await admin.locator('#menuForm input[name="name"]').inputValue(), 'New menu');
  proof.check('the editor shows the empty state', (await admin.locator('[data-empty-state]').count()) === 1);
});

// ------------------------------------------------------------------ AD-63

test('AD-63 Deleting a menu removes its items and forgets its area picks', async ({ admin, visit, proof }) => {
  proof.claim('GET delete with confirm=1 and the token removes the menu, its items cascade, and an area that showed it goes back to "By visitor".');
  acceptDialogs(admin);
  const id = await newMenu(admin, 'main');
  await addItem(admin, 'custom_link', { label: 'Audit Delete Me', url: '/audit-delete-me' });
  await saveEditor(admin);
  proof.equal('the menu has one item', db.menu(id).items.length, 1);

  await openList(admin, 'main');
  await admin.locator('select[name="area_menu[website]"]').selectOption(String(id));
  await submit(admin, admin.locator('form[action*="sub=areas"] button[type="submit"]'));
  proof.equal('it is picked for the Website area', areaPicks().main?.website, id);
  const guest = await home(visit);
  proof.check('guests on the website see its item', (await guest.locator('a[href="/audit-delete-me"]').count()) > 0);

  const token = new URL((await admin.locator('a', { hasText: 'Re-seed presets' }).getAttribute('href')), 'http://x/').searchParams.get('token');
  proof.step('Open sub=delete without confirm=1');
  await admin.goto(adminUrl('menu', { sub: 'delete', id, token }));
  proof.check('without confirm=1 the screen refuses', (await admin.locator('body').innerText()).includes('confirm=1'));
  proof.check('and the menu is still there', db.menu(id) !== null);

  proof.step('Open sub=delete with confirm=1 and the admin token (the screen has no Delete link)');
  const itemsBefore = itemCountRaw(id);
  await admin.goto(adminUrl('menu', { sub: 'delete', id, confirm: 1, token }));
  await proof.shot(admin, 'Menu list after delete');
  proof.check('it lands back on the Main tab', /action=menu&tab=main/.test(admin.url()), admin.url());
  proof.equal('the menu row is gone', db.menu(id), null);
  proof.value('hadrian_menu_items rows for the menu', itemsBefore, itemCountRaw(id));
  proof.equal('its items went with it', itemCountRaw(id), 0);
  proof.equal('the Website pick is forgotten', areaPicks().main?.website ?? 0, 0);
  proof.equal('the list no longer links to it', await admin.locator(`a[href$="sub=edit&id=${id}"]`).count(), 0);
  await guest.reload();
  proof.check('guests are back on the by-visitor menu', (await guest.locator('a[href="/audit-delete-me"]').count()) === 0);
  proof.note('No Delete control exists in the UI (FEATURES.md); the address is the one admin-csrf.spec builds.');
});

// ------------------------------------------------------------------ AD-64

test('AD-64 Re-seed presets brings a renamed preset back, switched off because its slot is live', async ({ admin, visit, proof }) => {
  proof.claim('Re-seed fills in missing presets; a renamed one comes back inactive when its slot already has a live menu.');
  const gm = menuNamed('Guest Main Menu', 'main');
  await openEditor(admin, gm.id);
  await admin.locator('#menuForm input[name="name"]').fill('Guest Main Menu (audit)');
  await saveEditor(admin);
  const countBefore = db.menus().length;

  await openList(admin, 'main');
  proof.step('Menu list: press "Re-seed presets"');
  await submit(admin, admin.locator('a', { hasText: 'Re-seed presets' }));
  const flash = await flashText(admin);
  await proof.shot(admin, 'Menu list after Re-seed');
  proof.check('the screen reports one preset re-seeded', flash.includes('Re-seeded 1 preset(s).'), flash);
  const menus = db.menus();
  const copy = menus.find(m => m.name === 'Guest Main Menu' && m.location === 'main');
  proof.value('menus', countBefore, menus.length);
  proof.check('a "Guest Main Menu" exists again', !!copy);
  proof.equal('with the preset items', copy.items, PRESET_COUNTS['Guest Main Menu']);
  proof.equal('switched off', Number(copy.active), 0);
  proof.equal('the renamed menu is still active', Number(menus.find(m => m.id === gm.id).active), 1);
  const ownHome = topLevel(itemsOf(gm.id)).find(i => i.item_type === 'custom_link');
  const copyHome = topLevel(itemsOf(copy.id)).find(i => i.item_type === 'custom_link');
  const guest = await home(visit);
  proof.check('guests still get the renamed menu', (await guest.locator(`a[data-nav="mt-${ownHome.id}"]`).count()) > 0);
  proof.check('not the re-seeded copy', (await guest.locator(`a[data-nav="mt-${copyHome.id}"]`).count()) === 0);
});

test('AD-64 Re-seed presets with every preset complete changes nothing', async ({ admin, proof }) => {
  proof.claim('With nothing missing or empty, Re-seed says so and writes nothing.');
  const before = db.hash();
  await openList(admin, 'main');
  await submit(admin, admin.locator('a', { hasText: 'Re-seed presets' }));
  const flash = await flashText(admin);
  await proof.shot(admin, 'Menu list after a no-op Re-seed');
  proof.check('the screen says every preset was already complete', flash.includes('every preset was already complete'), flash);
  const after = db.hash();
  proof.value('menus + items hash', before.menus + '/' + before.menu_items, after.menus + '/' + after.menu_items);
  proof.equal('menus and items are untouched', [after.menus, after.menu_items], [before.menus, before.menu_items]);
});

test('AD-64 Force re-sync to presets rebuilds every preset menu and leaves the admin\'s own menus', async ({ admin, visit, proof }) => {
  proof.claim('Force re-sync wipes and reseeds the items of every preset menu; menus that are not presets are not touched.');
  acceptDialogs(admin);
  const own = await newMenu(admin, 'footer');
  await addItem(admin, 'custom_link', { label: 'Audit Own Item', url: '/audit-own' });
  await saveEditor(admin);
  const fs = menuNamed('Footer Secondary Menu', 'footer-secondary');
  await openEditor(admin, fs.id);
  await openRow(admin, 'Cookie Policy');
  await admin.locator('#drawerLabelEn').fill('Audit Cookies');
  await saveEditor(admin);
  proof.check('setup: Cookie Policy was renamed', itemsOf(fs.id).some(i => english(i) === 'Audit Cookies'));
  const guest = await home(visit);
  proof.check('the guest footer shows "Audit Cookies"', (await guest.locator('.hp-footer-bottom-links a', { hasText: 'Audit Cookies' }).count()) === 1);

  await openList(admin, 'main');
  proof.step('Menu list: press "Force re-sync to presets" and confirm');
  await submit(admin, admin.locator('a', { hasText: 'Force re-sync to presets' }));
  const flash = await flashText(admin);
  await proof.shot(admin, 'Menu list after Force re-sync');
  proof.check('the screen reports all six presets re-seeded', flash.includes('Re-seeded 6 preset(s).'), flash);
  for (const [name, n] of Object.entries(PRESET_COUNTS)) {
    const m = db.menus().find(x => x.name === name);
    proof.equal(`"${name}" has exactly its ${n} preset items`, m?.items, n);
  }
  const fsItems = itemsOf(fs.id);
  proof.check('"Cookie Policy" is back, "Audit Cookies" gone', fsItems.some(i => english(i) === 'Cookie Policy') && !fsItems.some(i => english(i) === 'Audit Cookies'));
  proof.check('the admin\'s own menu kept its item', itemsOf(own).some(i => english(i) === 'Audit Own Item'));
  await guest.reload();
  proof.check('the guest footer shows "Cookie Policy" again', (await guest.locator('.hp-footer-bottom-links a', { hasText: 'Cookie Policy' }).count()) === 1);
});

test('AD-64 Reset WHMCS Defaults rebuilds the two Defaults menus and Footer Secondary only', async ({ admin, proof }) => {
  proof.claim('Reset WHMCS Defaults wipes and reseeds the WHMCS Defaults presets and Footer Secondary Menu, and leaves the curated menus (Footer Menu, Client/Guest Main Menu) alone.');
  acceptDialogs(admin);
  const gd = menuNamed('Guest Main Menu — WHMCS Defaults', 'main');
  const fs = menuNamed('Footer Secondary Menu', 'footer-secondary');
  const fm = menuNamed('Footer Menu', 'footer');

  proof.step('Editor: delete the first item of "Guest Main Menu — WHMCS Defaults", save');
  await openEditor(admin, gd.id);
  await admin.locator('#mtMenuTree ul.mt-menu-list > li.mt-menu-item').first().locator(':scope > .mt-menu-item-row [data-action="delete-item"]').click();
  await saveEditor(admin);
  const gdEdited = db.menu(gd.id).items.length;
  proof.check('setup: the Defaults menu lost items', gdEdited < PRESET_COUNTS['Guest Main Menu — WHMCS Defaults'], `${gdEdited} items`);
  proof.step('Editor: rename "Cookie Policy" in Footer Secondary and "VPS" in Footer Menu, save each');
  await openEditor(admin, fs.id);
  await openRow(admin, 'Cookie Policy');
  await admin.locator('#drawerLabelEn').fill('Audit Cookies');
  await saveEditor(admin);
  await openEditor(admin, fm.id);
  await openRow(admin, 'VPS');
  await admin.locator('#drawerLabelEn').fill('Audit VPS');
  await saveEditor(admin);
  proof.check('setup: Footer Menu now has "Audit VPS"', itemsOf(fm.id).some(i => english(i) === 'Audit VPS'));

  await openList(admin, 'main');
  proof.step('Menu list: press "Reset WHMCS Defaults" and confirm');
  await submit(admin, admin.locator('a', { hasText: 'Reset WHMCS Defaults' }));
  await proof.shot(admin, 'Menu list after Reset WHMCS Defaults');
  const gdAfter = db.menu(gd.id).items.length;
  proof.value('Guest Main Menu — WHMCS Defaults items', gdEdited, gdAfter);
  proof.equal('the Guest Defaults menu has its preset items again', gdAfter, PRESET_COUNTS['Guest Main Menu — WHMCS Defaults']);
  proof.equal('the Client Defaults menu has its preset items', db.menus().find(m => m.name === 'Client Main Menu — WHMCS Defaults').items, PRESET_COUNTS['Client Main Menu — WHMCS Defaults']);
  proof.check('Footer Secondary has "Cookie Policy" again', itemsOf(fs.id).some(i => english(i) === 'Cookie Policy') && !itemsOf(fs.id).some(i => english(i) === 'Audit Cookies'));
  proof.check('Footer Menu (curated) still has "Audit VPS"', itemsOf(fm.id).some(i => english(i) === 'Audit VPS'));
  proof.check('the redirect carries the count', /flash=reset-defaults-3/.test(admin.url()), admin.url());
  const flash = await flashText(admin);
  proof.check('the screen tells the admin how many presets were reset', /Reset 3 WHMCS Defaults preset/.test(flash), `flash shown: "${flash}"`);
});

// ------------------------------------------------------------------ AD-65

test('AD-65 Menus by area: an area\'s pick is what that area renders, for guests and clients', async ({ admin, visit, proof }) => {
  proof.claim('Picking a menu for an area stores it in menus_by_area; everyone in that area sees it; other areas keep the by-visitor menu; a menu from another location is refused; "By visitor" clears it.');
  const gd = menuNamed('Guest Main Menu — WHMCS Defaults', 'main');
  const cm = menuNamed('Client Main Menu', 'main');
  const probe = topLevel(itemsOf(gd.id)).find(i => ['custom_link', 'whmcs_page'].includes(i.item_type) && (i.config.audience ?? 'all') === 'all');
  const clientProbe = topLevel(itemsOf(cm.id)).find(i => i.item_type === 'whmcs_page');
  const sel = `a[data-nav="mt-${probe.id}"]`;
  const guest = await home(visit);
  proof.check('before: guests on the homepage do not see the Defaults menu', (await guest.locator(sel).count()) === 0);
  const before = areaPicks();

  proof.step('Menu > Main: set Website to "Guest Main Menu — WHMCS Defaults", press "Save menus by area"');
  await openList(admin, 'main');
  await admin.locator('select[name="area_menu[website]"]').selectOption(String(gd.id));
  await submit(admin, admin.locator('form[action*="sub=areas"] button[type="submit"]'));
  const flash = await flashText(admin);
  await proof.shot(admin, 'Menu list after Save menus by area');
  proof.value('menus_by_area', before, areaPicks());
  proof.equal('stored as main.website = the Defaults menu id', areaPicks().main?.website, gd.id);
  proof.check('the screen confirms', flash.includes('Menus by area saved.'), flash);
  const badge = admin.locator('.mt-table tbody tr').filter({ has: admin.locator(`a[href$="sub=edit&id=${gd.id}"]`) }).locator('[data-menu-area-badge]');
  proof.equal('its row carries a "Website" badge', (await badge.allInnerTexts()).map(s => s.trim()), ['Website']);

  await guest.reload();
  proof.check('guests on the homepage now see the Defaults menu', (await guest.locator(sel).count()) > 0, sel);
  await proof.shot(guest, 'guest homepage with the Website pick');
  const client = await home(visit, 'full');
  proof.check('so does the full client on the homepage', (await client.locator(sel).count()) > 0);
  await client.goto('/clientarea.php');
  proof.check('in the client area the client keeps the by-visitor Client Main Menu', (await client.locator(`a[data-nav="mt-${clientProbe.id}"]`).count()) > 0 && (await client.locator(sel).count()) === 0);

  proof.step('Add the Footer Menu id as an option of the Order process select in the page, pick it, save');
  const fm = menuNamed('Footer Menu', 'footer');
  await admin.locator('select[name="area_menu[order]"]').evaluate((s, id) => { const o = document.createElement('option'); o.value = String(id); o.textContent = 'x'; s.appendChild(o); s.value = String(id); }, fm.id);
  await submit(admin, admin.locator('form[action*="sub=areas"] button[type="submit"]'));
  proof.equal('a menu from another location is not stored for the area', areaPicks().main?.order ?? 0, 0);

  proof.step('Set Website back to "By visitor" and save');
  await admin.locator('select[name="area_menu[website]"]').selectOption('0');
  await submit(admin, admin.locator('form[action*="sub=areas"] button[type="submit"]'));
  proof.equal('the Website pick is cleared', areaPicks().main?.website ?? 0, 0);
  await guest.reload();
  proof.check('guests are back on the Guest Main Menu', (await guest.locator(sel).count()) === 0);
});

// ------------------------------------------------------------------ AD-66

test('AD-66 Activating a menu turns off its peers in the slot and the client renders it', async ({ admin, visit, proof }) => {
  proof.claim('Saving a menu with Status on turns off every other menu with the same location and audience; that slot then renders the new menu.');
  const before = Object.fromEntries(db.menus().filter(m => m.location === 'main').map(m => [m.name, Number(m.active)]));
  const id = await newMenu(admin, 'main');
  proof.step('New menu (Main, Existing Client): add a custom link "Audit Slot Link", tick Status, press Save changes');
  await addItem(admin, 'custom_link', { label: 'Audit Slot Link', url: '/audit-slot-link' });
  await switchOn(admin.locator('#menuForm input[name="active"]'));
  await saveEditor(admin);
  await proof.shot(admin, 'editor after activating');
  const after = Object.fromEntries(db.menus().filter(m => m.location === 'main').map(m => [m.name, Number(m.active)]));
  proof.value('main menus active', before, after);
  proof.equal('the new menu is active', Number(db.menu(id).menu.active), 1);
  proof.equal('Client Main Menu was switched off', after['Client Main Menu'], 0);
  proof.equal('the guest slot is untouched', after['Guest Main Menu'], before['Guest Main Menu']);
  const stored = itemsOf(id);
  proof.equal('the item was stored', stored.map(i => [i.item_type, english(i), i.config.url]), [['custom_link', 'Audit Slot Link', '/audit-slot-link']]);

  const client = await home(visit, 'full', '/clientarea.php');
  const link = client.locator('a[href="/audit-slot-link"]', { hasText: 'Audit Slot Link' });
  proof.check('the full client sees "Audit Slot Link" in the menu', (await link.count()) > 0);
  await proof.shot(client, 'client area with the new menu');
  const old = topLevel(itemsOf(menuNamed('Client Main Menu', 'main').id)).find(i => i.item_type === 'whmcs_page');
  proof.check('and no longer the Client Main Menu', (await client.locator(`a[data-nav="mt-${old.id}"]`).count()) === 0);
  const guest = await home(visit);
  proof.check('guests do not see it', (await guest.locator('a[href="/audit-slot-link"]').count()) === 0);
});

test('AD-66 Moving an active menu to the other audience turns off that slot\'s peers', async ({ admin, proof }) => {
  proof.claim('saveAction deactivates peers when a menu becomes active in a slot, including when an active menu changes audience (MenuController comment: "or audience changed").');
  const id = await newMenu(admin, 'main');
  await addItem(admin, 'custom_link', { label: 'Audit Move', url: '/audit-move' });
  await switchOn(admin.locator('#menuForm input[name="active"]'));
  await saveEditor(admin);
  const gm = menuNamed('Guest Main Menu', 'main');
  proof.equal('setup: the guest menu is active', Number(gm.active), 1);
  proof.step('Editor of the active client menu: set Display Rule to "Guest Client", press Save changes');
  await openEditor(admin, id);
  await admin.locator('#menu-audience').selectOption('guest');
  await saveEditor(admin);
  const m = db.menu(id).menu;
  proof.equal('the menu is now an active guest menu', [m.audience, Number(m.active)], ['guest', 1]);
  const guestActive = db.menus().filter(x => x.location === 'main' && x.audience === 'guest' && Number(x.active) === 1).map(x => x.name);
  proof.value('active guest main menus', ['Guest Main Menu'], guestActive);
  proof.equal('Guest Main Menu was switched off', Number(db.menus().find(x => x.id === gm.id).active), 0);
});

test('AD-66 Save is refused when the browser sends an empty item list', async ({ admin, proof }) => {
  proof.claim('With items in the database and none posted, Save refuses to wipe the items and says so.');
  acceptDialogs(admin);
  const id = await newMenu(admin, 'main');
  await addItem(admin, 'custom_link', { label: 'Audit Keep Me', url: '/audit-keep' });
  await saveEditor(admin);
  const before = db.menu(id).items;
  proof.step('Editor: delete the only item (confirm), press Save changes');
  await openEditor(admin, id);
  await row(admin, 'Audit Keep Me').locator('[data-action="delete-item"]').click();
  await saveEditor(admin);
  await proof.shot(admin, 'editor after the refused save');
  proof.check('the editor reports the refusal', /flash=empty-payload-rejected/.test(admin.url()) && (await admin.locator('.mt-flash-warn', { hasText: 'Save refused' }).count()) === 1, admin.url());
  const after = db.menu(id).items;
  proof.value('items', before.map(i => i.id), after.map(i => i.id));
  proof.equal('the item is still stored', after.map(i => i.id), before.map(i => i.id));
});

test('AD-66 Save is refused near max_input_vars, and the editor warns first', async ({ admin, proof }) => {
  proof.claim('A menu large enough to approach max_input_vars shows a warning in the editor, and Save is refused with nothing changed.');
  const id = await newMenu(admin, 'footer');
  proof.step('Give the new menu 136 custom links (setup, in the database): about 960 fields per save against max_input_vars');
  phpEval(`$now = date('Y-m-d H:i:s'); $rows = [];
    for ($i = 0; $i < 136; $i++) { $rows[] = ['menu_id' => ${id}, 'parent_id' => null, 'position' => $i, 'item_type' => 'custom_link',
      'label_json' => json_encode(['whmcs' => '', 'custom' => ['english' => 'Bulk ' . $i]]), 'config_json' => json_encode(['url' => '/bulk-' . $i]), 'active' => 1, 'created_at' => $now, 'updated_at' => $now]; }
    $T('hadrian_menu_items')->insert($rows); return ini_get('max_input_vars');`);
  const before = db.menu(id).items.map(i => i.id);
  await openEditor(admin, id);
  const warn = admin.locator('.mt-flash-warn', { hasText: 'Heads up' });
  proof.check('the editor warns before saving', (await warn.count()) === 1, (await warn.allInnerTexts()).join(''));
  proof.step('Press Save changes');
  await saveEditor(admin);
  await proof.shot(admin, 'editor after the refused save');
  proof.check('the save is refused', /flash=max-input-vars-exceeded/.test(admin.url()) && (await admin.locator('.mt-flash-warn', { hasText: 'max_input_vars too low' }).count()) === 1, admin.url());
  const after = db.menu(id).items.map(i => i.id);
  proof.equal('no item was deleted or recreated', after, before);
  proof.note('The warning starts at (items*7+10) > max_input_vars-150 (850 here), before the refusal at terminal count > max_input_vars-100 (900), so a menu is warned about before it can be refused.');
});

test('AD-66 A blank name keeps the old one and an unknown Display Rule is refused', async ({ admin, proof }) => {
  proof.claim('Saving a blank name keeps the menu\'s name, and a Display Rule other than client, guest or all is not stored, so the menu never ends up nameless or matching no visitor.');
  const id = await newMenu(admin, 'footer');
  proof.step('Editor: clear the name, add an option "bogus" to Display Rule and pick it, press Save changes');
  await admin.locator('#menuForm input[name="name"]').fill('');
  await admin.locator('#menu-audience').evaluate(s => { const o = document.createElement('option'); o.value = 'bogus'; o.textContent = 'bogus'; s.appendChild(o); s.value = 'bogus'; });
  await saveEditor(admin);
  await proof.shot(admin, 'editor after saving a blank name');
  const m = db.menu(id).menu;
  proof.value('name, audience', ['New menu', 'client'], [m.name, m.audience]);
  proof.equal('the blank name kept the old name', m.name, 'New menu');
  proof.equal('the unknown audience was refused and the old one kept', m.audience, 'client');
});

// ------------------------------------------------------------------ AD-67

test('AD-67 Custom URL item: add, rename and reorder, then the footer shows it', async ({ admin, visit, proof }) => {
  proof.claim('A custom link added, renamed and moved in the editor is stored with its label, URL, new-tab flag and position, and the guest footer shows it in that place.');
  const fs = menuNamed('Footer Secondary Menu', 'footer-secondary');
  await openEditor(admin, fs.id);
  proof.step('Footer Secondary editor: Add As Custom Link, + Add item, label "Audit Link A", URL /audit-custom-url, Open in new tab; Save');
  await addItem(admin, 'custom_link', { label: 'Audit Link A', url: '/audit-custom-url', newTab: true });
  await saveEditor(admin);
  let it = itemsOf(fs.id).find(i => english(i) === 'Audit Link A');
  proof.check('stored as a custom_link with URL and target', it && it.item_type === 'custom_link' && it.config.url === '/audit-custom-url' && it.config.target === '_blank', JSON.stringify(it?.config));
  proof.equal('as the last top-level item', topLevel(itemsOf(fs.id)).map(english).indexOf('Audit Link A'), 5);

  proof.step('Reopen: rename it to "Audit Link Renamed", press Move up twice, Save');
  await openEditor(admin, fs.id);
  await openRow(admin, 'Audit Link A');
  await admin.locator('#drawerLabelEn').fill('Audit Link Renamed');
  await row(admin, 'Audit Link Renamed').locator('[data-action="move-up"]').click();
  await row(admin, 'Audit Link Renamed').locator('[data-action="move-up"]').click();
  await proof.shot(admin.locator('#mtMenuTree'), 'editor tree before Save');
  await saveEditor(admin);
  const order = topLevel(itemsOf(fs.id)).map(english);
  proof.value('Footer Secondary order', ['Privacy Policy', 'Terms of Use', 'Cookie Policy', 'Sitemap', 'Accessibility', 'Audit Link A'], order);
  proof.check('the old label is gone', !order.includes('Audit Link A'));
  proof.equal('the renamed item is now third from the end (position 3)', order.indexOf('Audit Link Renamed'), 3);
  it = itemsOf(fs.id).find(i => english(i) === 'Audit Link Renamed');
  proof.equal('URL and target survived the second save', [it.config.url, it.config.target], ['/audit-custom-url', '_blank']);

  const guest = await home(visit);
  const links = guest.locator('.hp-footer-bottom-links a');
  const texts = (await links.allInnerTexts()).map(s => s.trim());
  await proof.shot(guest.locator('.hp-footer-bottom'), 'guest footer with the new link');
  proof.equal('the footer link is fourth, as in the editor', texts.indexOf('Audit Link Renamed'), 3);
  const a = guest.locator('.hp-footer-bottom-links a', { hasText: 'Audit Link Renamed' });
  proof.equal('with its URL and new-tab target', [await a.getAttribute('href'), await a.getAttribute('target')], ['/audit-custom-url', '_blank']);
});

test('AD-67 Page link item: the page picker links the item to a WHMCS page and its language key', async ({ admin, visit, proof }) => {
  proof.claim('Picking a page in the WHMCS Page picker stores config.page and the page\'s language key, and the client renders the page\'s address.');
  const fs = menuNamed('Footer Secondary Menu', 'footer-secondary');
  await openEditor(admin, fs.id);
  proof.step('Footer Secondary editor: Add As WHMCS Page, + Add item, open the page picker, pick "Contact", Save');
  await addItem(admin, 'whmcs_page');
  await admin.locator('#drawerPagePickerBtn').click();
  await admin.locator('#drawerPagePickerList .mt-page-picker-tile[data-page-name="contact"]').click();
  await proof.shot(admin.locator('li.mt-menu-item.is-open'), 'the new page item');
  await saveEditor(admin);
  const it = itemsOf(fs.id).find(i => i.item_type === 'whmcs_page');
  proof.check('a whmcs_page item was stored', !!it, JSON.stringify(itemsOf(fs.id).map(i => i.item_type)));
  proof.equal('pointing at the contact page', it.config.page, 'contact');
  proof.equal('labelled by its language key', [it.label.whmcs, it.label.mode], ['navcontact', 'whmcs']);
  const guest = await home(visit);
  const a = guest.locator('.hp-footer-bottom-links a[href="contact.php"]');
  proof.equal('the guest footer links to contact.php', await a.count(), 1);
  const text = (await a.innerText()).trim();
  proof.check('with a real label, not the placeholder', text !== '' && !/^New /.test(text), text);
  proof.note(`Rendered label: "${text}".`);
});

test('AD-67 Dropdown with a child, both added in one save', async ({ admin, visit, proof }) => {
  proof.claim('A dropdown and a child added under it in the same editing session are stored as parent and child, and the footer shows the child in the dropdown\'s column.');
  const fm = menuNamed('Footer Menu', 'footer');
  await openEditor(admin, fm.id);
  proof.step('Footer Menu editor: Add As Dropdown, + Add item, label "Audit Column"; Add As Custom Link, its + button, label "Audit Child", URL /audit-child; Save');
  await addItem(admin, 'dropdown_parent', { label: 'Audit Column' });
  await addItem(admin, 'custom_link', { label: 'Audit Child', url: '/audit-child', parent: 'Audit Column' });
  await proof.shot(admin.locator('#mtMenuTree'), 'editor tree before Save');
  await saveEditor(admin);
  const all = itemsOf(fm.id);
  const parent = all.find(i => english(i) === 'Audit Column');
  const child = all.find(i => english(i) === 'Audit Child');
  proof.value('Audit Child parent_id', 'the dropdown id', child?.parent_id);
  proof.check('both rows were stored', !!parent && !!child);
  const guest = await home(visit);
  const col = guest.locator('.hp-footer-col').filter({ has: guest.locator('h4', { hasText: 'Audit Column' }) });
  const shown = await col.locator('a[href="/audit-child"]').count();
  proof.note(`dropdown id ${parent?.id}, child id ${child?.id}, child parent_id ${child?.parent_id}; footer column shows the child: ${shown > 0}`);
  proof.equal('the child is stored under the dropdown', child?.parent_id, parent?.id);
  proof.check('the footer shows "Audit Child" in the "Audit Column" column', shown > 0);
});

test('AD-67 Dropdown child added to a dropdown saved earlier', async ({ admin, visit, proof }) => {
  proof.claim('A child added under an already saved dropdown is stored under it and rendered in its column.');
  const fm = menuNamed('Footer Menu', 'footer');
  await openEditor(admin, fm.id);
  await addItem(admin, 'dropdown_parent', { label: 'Audit Column Two' });
  await saveEditor(admin);
  proof.step('Reopen the Footer Menu editor: Add As Custom Link, the + of "Audit Column Two", label "Audit Child Two", URL /audit-child-two; Save');
  await openEditor(admin, fm.id);
  await addItem(admin, 'custom_link', { label: 'Audit Child Two', url: '/audit-child-two', parent: 'Audit Column Two' });
  await saveEditor(admin);
  const all = itemsOf(fm.id);
  const parent = all.find(i => english(i) === 'Audit Column Two');
  const child = all.find(i => english(i) === 'Audit Child Two');
  proof.equal('the child is stored under the dropdown', child?.parent_id, parent?.id);
  const guest = await home(visit);
  const col = guest.locator('.hp-footer-col').filter({ has: guest.locator('h4', { hasText: 'Audit Column Two' }) });
  await proof.shot(col, 'footer column with the child');
  proof.check('the footer column lists "Audit Child Two"', (await col.locator('a[href="/audit-child-two"]', { hasText: 'Audit Child Two' }).count()) === 1);
});

test('AD-67 Per-item audience "Clients only" hides the item from guests', async ({ admin, visit, proof }) => {
  proof.claim('An item set to "Clients only" under Display Settings is absent for guests and present for the full client.');
  const fs = menuNamed('Footer Secondary Menu', 'footer-secondary');
  await openEditor(admin, fs.id);
  proof.step('Footer Secondary editor: add custom link "Audit Clients Only", Display Settings > Visible To = Clients only, Save');
  await addItem(admin, 'custom_link', { label: 'Audit Clients Only', url: '/audit-clients-only' });
  await openSub(admin, 'display');
  await admin.locator('#drawerAudience').selectOption('client');
  await saveEditor(admin);
  const it = itemsOf(fs.id).find(i => english(i) === 'Audit Clients Only');
  proof.equal('config.audience stored as "client"', it?.config.audience, 'client');
  const sel = '.hp-footer-bottom-links a[href="/audit-clients-only"]';
  const guest = await home(visit);
  proof.equal('guests do not see it', await guest.locator(sel).count(), 0);
  const client = await home(visit, 'full');
  proof.equal('the full client does', await client.locator(sel).count(), 1);
  await proof.shot(client.locator('.hp-footer-bottom'), 'client footer with the clients-only link');
  proof.limit('Icons, translations and per-item layouts are stored by the same drawer path; not proven one by one here.');
});

// ------------------------------------------------------------------ AD-68

test('AD-68 Description, badge, text transform, hide label and CSS class are stored and rendered', async ({ admin, visit, proof }) => {
  proof.claim('The editor stores description, badge, text transform, hide label and CSS class, and the client renders each: the description as the tooltip, a badge pill, the label transformed, the label visually hidden beside the icon (still in the accessible name), the class on the link. Each is checked on the guest sidebar.');
  const gm = menuNamed('Guest Main Menu', 'main');
  await openEditor(admin, gm.id);
  proof.step('Guest Main Menu editor: add custom link "Audit Extras"; Description, Label > Text Transform Uppercase, Badge "AUDITBADGE", Hide Label Text on; Display Settings > CSS class "audit-css-class"; Save');
  await addItem(admin, 'custom_link', { label: 'Audit Extras', url: '/audit-extras' });
  await admin.locator('#drawerDescription').fill('Audit description text');
  await openSub(admin, 'label');
  await admin.locator('#drawerTextTransform').selectOption('uppercase');
  await admin.locator('#drawerBadge').fill('AUDITBADGE');
  await switchOn(admin.locator('#mtItemDrawer input[data-drawer-field="config.hide_label"]'));
  await openSub(admin, 'display');
  await admin.locator('#drawerCss').fill('audit-css-class');
  await proof.shot(admin.locator('li.mt-menu-item.is-open'), 'the item panel before Save');
  await saveEditor(admin);
  const it = itemsOf(gm.id).find(i => english(i) === 'Audit Extras');
  proof.equal('all five are stored in config_json', {
    description: it?.config.description, text_transform: it?.config.text_transform, badge: it?.config.badge, hide_label: it?.config.hide_label, css_class: it?.config.css_class,
  }, { description: 'Audit description text', text_transform: 'uppercase', badge: 'AUDITBADGE', hide_label: true, css_class: 'audit-css-class' });

  const guest = await home(visit);
  const a = guest.locator(`a[data-nav="mt-${it.id}"]`).first();
  proof.equal('the item is in the guest sidebar', await a.count(), 1);
  await proof.shot(a, 'the rendered sidebar item');
  const seen = await a.evaluate(el => {
    // The element that holds the label text itself (not the badge).
    const label = [...el.querySelectorAll('span')].find(s => s.textContent.trim() === 'Audit Extras') || null;
    const box = label ? label.getBoundingClientRect() : null;
    const badge = el.querySelector('.mt-nav-badge');
    return {
      cls: el.className, html: el.outerHTML, title: el.getAttribute('title'),
      transform: label ? getComputedStyle(label).textTransform : getComputedStyle(el).textTransform,
      labelHidden: !!box && box.width <= 1 && box.height <= 1,
      labelInDom: !!label,
      badgeText: badge ? badge.textContent.trim() : '',
      badgeShown: !!badge && badge.getBoundingClientRect().width > 1,
    };
  });
  const rendered = {
    description: seen.title === 'Audit description text',
    badge: seen.badgeText === 'AUDITBADGE' && seen.badgeShown,
    text_transform: seen.transform === 'uppercase',
    hide_label: seen.labelInDom && seen.labelHidden,
    css_class: /\baudit-css-class\b/.test(seen.cls),
  };
  for (const [k, v] of Object.entries(rendered)) proof.note(`${k}: ${v ? 'rendered' : 'NOT rendered'}`);
  proof.note(`rendered markup: ${seen.html.replace(/\s+/g, ' ').slice(0, 300)}`);
  const missing = Object.entries(rendered).filter(([, v]) => !v).map(([k]) => k);
  proof.check('the client renders all five saved fields', missing.length === 0, `not rendered: ${missing.join(', ')}`);
});

// ------------------------------------------------------------------ AD-69

test('AD-69 Diagnose answers with the stored menu and its items as JSON', async ({ admin, proof }) => {
  proof.claim('?sub=diagnose&id=N dumps the menu and every item as JSON, matching the database; an unknown id answers an error object.');
  const fs = menuNamed('Footer Secondary Menu', 'footer-secondary');
  const stored = db.menu(fs.id);
  proof.step('Open sub=diagnose&id=<Footer Secondary Menu> as the admin');
  const res = await admin.goto(adminUrl('menu', { sub: 'diagnose', id: fs.id }));
  const body = await res.text();
  await proof.shot(admin, 'diagnose output');
  let json = null;
  try { json = JSON.parse(body); } catch { /* recorded below */ }
  proof.check('the answer is JSON and nothing else', json !== null, body.slice(0, 200));
  proof.check('sent as application/json', /application\/json/.test(res.headers()['content-type'] || ''), res.headers()['content-type']);
  proof.equal('menu fields match the row', { id: json.menu.id, name: json.menu.name, location: json.menu.location, audience: json.menu.audience, active: json.menu.active },
    { id: stored.menu.id, name: stored.menu.name, location: stored.menu.location, audience: stored.menu.audience, active: !!Number(stored.menu.active) });
  proof.equal('items_count matches', json.items_count, stored.items.length);
  proof.equal('the same item ids, types and labels', json.items.map(i => [i.id, i.item_type, i.label.custom?.english]).sort(),
    stored.items.map(i => [i.id, i.item_type, JSON.parse(i.label_json).custom?.english]).sort());
  const res2 = await admin.goto(adminUrl('menu', { sub: 'diagnose', id: 999999 }));
  const j2 = JSON.parse(await res2.text());
  proof.equal('an unknown id answers {error, id}', j2, { error: 'menu not found', id: 999999 });
  proof.note('No link to Diagnose exists in the UI; it is reached by address.');
});
