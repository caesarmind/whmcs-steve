// AD-C Styles (tests/FEATURES.md AD-20 to AD-29, AD-92): the Styles page and
// the style editor's panels, each changed through Addons > Hadrian > Styles,
// then proven in the database and in the CSS a guest's client area gets.
//
// Guests and the admin page never reach a host other than localhost: every
// request to another host is aborted, and pages whose HTML would load a Google
// font are read as HTML (no rendering) rather than opened in the browser.

import fs from 'node:fs';
import path from 'node:path';
import { test, db, settings, useAuditBackup, adminUrl, submit, flashText, noErrorText, html, setChecked } from './harness.mjs';
import { BASE_URL, TESTS_DIR } from '../../lib/env.mjs';

useAuditBackup();
test.beforeEach(() => { settings.snapshot(); });
test.afterEach(() => { settings.restore(); });

// ---------------------------------------------------------------- helpers

const isLocal = u => ['localhost', '127.0.0.1', '[::1]'].includes(u.hostname);
const guarded = new WeakSet();
async function localOnly(page) {
  const ctx = page.context();
  if (guarded.has(ctx)) return;
  guarded.add(ctx);
  await ctx.route(u => !isLocal(u), r => r.abort());
}
async function go(page, url) {
  await localOnly(page);
  await page.goto(url);
}
/** A guest page that only ever talks to localhost; `dark` sets the visitor's own dark-mode cookie. */
async function guestPage(visit, { dark = false } = {}) {
  const p = await visit('guest');
  await localOnly(p);
  if (dark) await p.context().addCookies([{ name: 'mt_theme', value: 'dark', url: BASE_URL }]);
  return p;
}
/** Custom properties on <html>, as the guest's browser computes them. */
const rootVars = (page, names) => page.evaluate(ns => {
  const cs = getComputedStyle(document.documentElement);
  const o = { 'data-theme': document.documentElement.getAttribute('data-theme') };
  for (const n of ns) o[n] = cs.getPropertyValue(n).trim();
  return o;
}, names);
/** Open `path` as a guest and return the custom properties (and data-theme). */
async function guestVars(visit, names, { dark = false, path: p = '/' } = {}) {
  const g = await guestPage(visit, { dark });
  await g.goto(p);
  return { page: g, vars: await rootVars(g, names) };
}
/** Text of an inline <style id=...> in the guest's head, or null. */
const styleText = (page, id) => page.evaluate(i => document.getElementById(i)?.textContent ?? null, id);
/** The computed colour a CSS expression resolves to on this page (rgb()). */
const resolveColor = (page, expr) => page.evaluate(e => {
  const d = document.createElement('div');
  d.style.background = e;
  document.body.appendChild(d);
  const c = getComputedStyle(d).backgroundColor;
  d.remove();
  return c;
}, expr);
const json = s => (s === null || s === undefined || s === '') ? null : JSON.parse(s);
const keys = o => (o && typeof o === 'object') ? Object.keys(o).sort() : [];
const sorted = o => (o && typeof o === 'object' && !Array.isArray(o)) ? Object.fromEntries(Object.keys(o).sort().map(k => [k, sorted(o[k])])) : o;

const EDIT = (subcat, params = {}) => adminUrl('editStyle', { style: 'default', subcat, ...params });
const panel = (page, name) => page.locator(`[data-panel="${name}"]`);
const saveOf = (page, name) => panel(page, name).locator('.mt-savebar button[type="submit"]');
const colorsForm = page => page.locator('form.mt-colors');

const DARK_ON = { enable_dark_mode: ['1', 'bool'], dark_mode_display: ['switcher', 'string'], dark_mode_default: ['light', 'string'] };
const CLEAN_DEFAULT = {
  hadrian_active_style: ['default', 'string'],
  hadrian_colors_default_light: null, hadrian_colors_default_dark: null,
  hadrian_colors_default: null, hadrian_colors_dark: null,
};
const STOCK = { accentLight: '#0071e3', accentDark: '#2997ff' };
const EMERALD = { light: '#14b17d', dark: '#35b685' };

// ================================================================ AD-20

test('AD-20 Activating a style sets the pointer, seeds its palette and repaints the site', async ({ admin, visit, proof }) => {
  proof.claim('Activating a shipped style stores <tpl>_active_style, seeds that style\'s light and dark palette from its manifest, and the client area takes the style\'s body class and colours.');
  settings.set({ ...DARK_ON, ...CLEAN_DEFAULT, hadrian_colors_emerald_light: null, hadrian_colors_emerald_dark: null });

  let g = await guestVars(visit, ['--color-accent']);
  proof.equal('before: guests get the stock accent', g.vars['--color-accent'], STOCK.accentLight);
  proof.check('before: <body> has no theme-emerald class', !(await g.page.locator('body').getAttribute('class')).includes('theme-emerald'));

  await go(admin, adminUrl('styles'));
  await noErrorText(admin, proof, 'Styles page');
  const before = { active: db.setting('hadrian_active_style'), light: db.setting('hadrian_colors_emerald_light'), dark: db.setting('hadrian_colors_emerald_dark') };
  const card = name => admin.locator('label.mt-sty-card', { has: admin.locator(`input[name="style"][value="${name}"]`) });
  proof.check('the Styles page lists Emerald and does not offer the dark-mode entry as a style',
    (await card('emerald').count()) === 1 && (await card('dark').count()) === 0);

  proof.step('Click the Emerald card on Styles (its radio submits the form)');
  await submit(admin, card('emerald').locator('.mt-sty-title'));
  await proof.shot(admin, 'Styles after activating Emerald');
  const after = { active: db.setting('hadrian_active_style'), light: json(db.setting('hadrian_colors_emerald_light')), dark: json(db.setting('hadrian_colors_emerald_dark')) };
  proof.value('hadrian_active_style', before.active, after.active);
  proof.value('hadrian_colors_emerald_light', before.light, after.light);
  proof.value('hadrian_colors_emerald_dark', before.dark, after.dark);
  proof.equal('the pointer now names emerald', after.active, 'emerald');
  proof.equal('the light palette was seeded from the manifest', after.light?.['--color-accent'], EMERALD.light);
  proof.equal('the dark palette was seeded from the manifest', after.dark?.['--color-accent'], EMERALD.dark);
  proof.check('the Emerald card is now the active one', await card('emerald').evaluate(n => n.classList.contains('is-active')));

  g = await guestVars(visit, ['--color-accent']);
  proof.equal('guests now get the Emerald accent', g.vars['--color-accent'], EMERALD.light);
  proof.check('<body> carries the style\'s theme-emerald class', (await g.page.locator('body').getAttribute('class')).includes('theme-emerald'));
  await proof.shot(g.page, 'guest homepage on Emerald');
  const gd = await guestVars(visit, ['--color-accent'], { dark: true });
  proof.equal('a dark-mode guest is on data-theme="dark"', gd.vars['data-theme'], 'dark');
  proof.equal('and gets the Emerald dark accent', gd.vars['--color-accent'], EMERALD.dark);

  proof.step('Edit the seeded light row by hand, switch to Default and back to Emerald');
  settings.set({ hadrian_colors_emerald_light: [{ '--color-accent': '#123456' }, 'json'] });
  await go(admin, adminUrl('styles'));
  await submit(admin, card('default').locator('.mt-sty-title'));
  proof.equal('Default is active again', db.setting('hadrian_active_style'), 'default');
  g = await guestVars(visit, ['--color-accent']);
  proof.equal('guests are back on the stock accent', g.vars['--color-accent'], STOCK.accentLight);
  await submit(admin, card('emerald').locator('.mt-sty-title'));
  const reseed = json(db.setting('hadrian_colors_emerald_light'));
  proof.value('hadrian_colors_emerald_light after the second activation', { '--color-accent': '#123456' }, reseed);
  proof.equal('the second activation did not seed over the edited row', reseed, { '--color-accent': '#123456' });
  g = await guestVars(visit, ['--color-accent']);
  proof.equal('guests get the edited colour, not the manifest one', g.vars['--color-accent'], '#123456');

  proof.step('Put Default back through the Styles page');
  await submit(admin, card('default').locator('.mt-sty-title'));
  proof.equal('Default is active', db.setting('hadrian_active_style'), 'default');
});

test('AD-20 Activation refuses a style the theme does not ship', async ({ admin, visit, proof }) => {
  proof.claim('Only shipped styles can be activated: a posted name that is not a style folder leaves <tpl>_active_style alone.');
  settings.set({ ...CLEAN_DEFAULT });
  await go(admin, adminUrl('styles'));
  const before = db.setting('hadrian_active_style');
  proof.step('Rename the Emerald radio to "notastyle" in the page, then click its card');
  // A radio's value property is its value attribute, so find the card again by the new value.
  await admin.locator('input[name="style"][value="emerald"]').evaluate(el => { el.value = 'notastyle'; });
  await submit(admin, admin.locator('label.mt-sty-card', { has: admin.locator('input[name="style"][value="notastyle"]') }).locator('.mt-sty-title'));
  const after = db.setting('hadrian_active_style');
  proof.value('hadrian_active_style', before, after);
  proof.equal('the pointer is still default', after, 'default');
  proof.equal('no colour row was written for the bogus name', db.setting('hadrian_colors_notastyle_light'), null);
  const g = await guestVars(visit, ['--color-accent']);
  proof.equal('guests still get the stock accent', g.vars['--color-accent'], STOCK.accentLight);
});

test('AD-20 Activation migrates legacy colour keys first', async ({ admin, visit, proof }) => {
  proof.claim('Pre-refactor colours (<tpl>_colors_default, <tpl>_colors_dark) are folded into the per-scope rows, and a legacy "dark" pointer is retired to default.');
  settings.set({ ...DARK_ON, ...CLEAN_DEFAULT,
    hadrian_active_style: ['dark', 'string'],
    hadrian_colors_default: [{ '--color-accent': '#aa1144' }, 'json'],
    hadrian_colors_dark: [{ '--color-accent': '#ff88aa' }, 'json'] });
  const before = db.settings('hadrian_colors_default');
  proof.step('Open Styles, then activate Emerald and Default again');
  await go(admin, adminUrl('styles'));
  const pointer = db.setting('hadrian_active_style');
  proof.equal('opening Styles retired the legacy "dark" pointer', pointer, 'default');
  const card = name => admin.locator('label.mt-sty-card', { has: admin.locator(`input[name="style"][value="${name}"]`) }).locator('.mt-sty-title');
  await submit(admin, card('emerald'));
  await submit(admin, card('default'));
  proof.equal('Default is active again', db.setting('hadrian_active_style'), 'default');
  const after = db.settings('hadrian_colors_default');
  proof.value('hadrian_colors_default*', before, after);
  proof.equal('light colours moved to _colors_default_light', json(after.hadrian_colors_default_light), { '--color-accent': '#aa1144' });
  proof.equal('dark colours moved to _colors_default_dark', json(db.setting('hadrian_colors_default_dark')), { '--color-accent': '#ff88aa' });
  const g = await guestVars(visit, ['--color-accent']);
  proof.equal('guests keep the migrated light colour', g.vars['--color-accent'], '#aa1144');
  const gd = await guestVars(visit, ['--color-accent'], { dark: true });
  proof.equal('and the migrated dark colour', gd.vars['--color-accent'], '#ff88aa');
});

// ================================================================ AD-21

test('AD-21 Style cards show each style\'s saved colours, and only its own', async ({ admin, proof }) => {
  proof.claim('The swatch on each Styles card is built from that style\'s saved light colours (falling back to its manifest), so saving one style\'s accent changes its card and no other.');
  settings.set({ ...CLEAN_DEFAULT, hadrian_colors_rose_light: null, hadrian_colors_rose_dark: null, hadrian_colors_emerald_light: null, hadrian_colors_emerald_dark: null });
  const band = async name => {
    const sw = admin.locator('label.mt-sty-card', { has: admin.locator(`input[name="style"][value="${name}"]`) }).locator('.mt-sty-swatch i');
    return sw.nth(1).evaluate(n => getComputedStyle(n).backgroundColor);
  };
  await go(admin, adminUrl('styles'));
  const before = { rose: await band('rose'), emerald: await band('emerald'), default: await band('default') };
  proof.equal('Emerald\'s card shows its manifest accent', before.emerald, 'rgb(20, 177, 125)');
  proof.equal('Default\'s card shows the stock accent', before.default, 'rgb(0, 113, 227)');

  proof.step('Customize Rose: set its Accent to #12ab34 on the Colors panel and Save');
  await go(admin, adminUrl('editStyle', { style: 'rose', subcat: 'colors' }));
  await colorsForm(admin).locator('input[name="c[--color-accent]"]').fill('#12ab34');
  await submit(admin, saveOf(admin, 'colors'));
  proof.equal('the rose light row stores the accent', json(db.setting('hadrian_colors_rose_light'))?.['--color-accent'], '#12ab34');

  await go(admin, adminUrl('styles'));
  const after = { rose: await band('rose'), emerald: await band('emerald'), default: await band('default') };
  proof.value('accent band per card', before, after);
  await proof.shot(admin.locator('.mt-sty-grid'), 'style cards after saving Rose');
  proof.equal('Rose\'s card now shows the saved accent', after.rose, 'rgb(18, 171, 52)');
  proof.equal('Emerald\'s card is unchanged', after.emerald, before.emerald);
  proof.equal('Default\'s card is unchanged', after.default, before.default);
});

// ================================================================ AD-22

test('AD-22 Style editor allow-lists subcat, tab and style', async ({ admin, proof }) => {
  proof.claim('An unknown ?subcat= falls back to Colors, an unknown ?tab= to Style Variables, and ?style= naming a style that does not ship resolves to default.');
  settings.set({ ...CLEAN_DEFAULT });
  const visible = async name => !(await panel(admin, name).evaluate(n => n.hidden));

  await go(admin, adminUrl('editStyle', { style: 'default', subcat: 'typography' }));
  await noErrorText(admin, proof, 'style editor');
  proof.check('?subcat=typography opens the Typography panel', await visible('typography') && !(await visible('colors')));

  proof.step('Open ?subcat=site (a retired panel)');
  await go(admin, adminUrl('editStyle', { style: 'default', subcat: 'site' }));
  proof.check('an unknown subcat shows the Colors panel instead of a blank page', await visible('colors'));
  proof.equal('and Colors is the highlighted rail item', await admin.locator('.mt-subcat.is-active').getAttribute('data-subcat'), 'colors');

  proof.step('Open ?tab=settings (a retired tab)');
  await go(admin, adminUrl('editStyle', { style: 'default', tab: 'settings' }));
  proof.equal('an unknown tab lands on Style Variables', (await admin.locator('.mt-tabs > a.mt-tab.is-active').innerText()).trim(), 'Style Variables');
  proof.check('with the panels rendered', (await admin.locator('[data-panel="colors"]').count()) === 1);

  proof.step('Open ?tab=custom-css');
  await go(admin, adminUrl('editStyle', { style: 'default', tab: 'custom-css' }));
  proof.check('the Custom CSS tab shows its textarea', (await admin.locator('textarea[name="custom_css"]').count()) === 1);

  proof.step('Open ?style=retired-preset');
  await go(admin, adminUrl('editStyle', { style: 'retired-preset', subcat: 'colors' }));
  proof.equal('the Colors form posts style=default', await colorsForm(admin).locator('input[name="style"]').inputValue(), 'default');
  proof.check('the heading names Default', /^Default/.test((await admin.locator('h1.mt-page-title').innerText()).trim()));

  proof.step('Open ?style=emerald');
  await go(admin, adminUrl('editStyle', { style: 'emerald', subcat: 'colors' }));
  proof.equal('a shipped style is kept', await colorsForm(admin).locator('input[name="style"]').inputValue(), 'emerald');
  await proof.shot(admin, 'style editor for Emerald');
});

test('AD-22 Opening the style editor runs the colour and navigation migrations', async ({ admin, visit, proof }) => {
  proof.claim('A GET of the style editor folds legacy colour keys into the per-scope rows and moves navigation sizes out of <tpl>_layout_vars into <tpl>_navigation_vars.');
  settings.set({ ...CLEAN_DEFAULT,
    hadrian_colors_dark: [{ '--color-accent': '#445566' }, 'json'],
    hadrian_layout_vars: [{ '--sidebar-width': 300, '--content-max-width': 1000 }, 'json'],
    hadrian_navigation_vars: null });
  const before = { dark: db.setting('hadrian_colors_default_dark'), nav: db.setting('hadrian_navigation_vars'), layout: json(db.setting('hadrian_layout_vars')) };
  let g = await guestVars(visit, ['--sidebar-width', '--content-max-width']);
  proof.equal('before: guests already get the legacy sidebar width (read-time fold)', g.vars['--sidebar-width'], '300px');

  proof.step('Open Styles > Customize (style editor), no Save');
  await go(admin, EDIT('colors'));
  const after = { dark: json(db.setting('hadrian_colors_default_dark')), nav: json(db.setting('hadrian_navigation_vars')), layout: json(db.setting('hadrian_layout_vars')) };
  proof.value('colours, navigation and layout rows', before, after);
  proof.equal('legacy _colors_dark copied to _colors_default_dark', after.dark, { '--color-accent': '#445566' });
  proof.equal('--sidebar-width moved to _navigation_vars', after.nav, { '--sidebar-width': 300 });
  proof.equal('_layout_vars keeps only the content key', after.layout, { '--content-max-width': 1000 });
  proof.equal('the Navigation panel shows 300', await admin.locator('input[name="nav[--sidebar-width]"]').inputValue(), '300');

  g = await guestVars(visit, ['--sidebar-width', '--content-max-width']);
  proof.equal('guests still get 300px', g.vars['--sidebar-width'], '300px');
  proof.equal('and the content width stays put', g.vars['--content-max-width'], '1000px');
});

// ================================================================ AD-23

test('AD-23 Colours save writes light and dark together, and the site follows', async ({ admin, visit, proof }) => {
  proof.claim('One Save on the Colors panel stores both scopes; light reaches html:not([data-theme=dark]) and dark reaches html[data-theme=dark] on the client.');
  settings.set({ ...DARK_ON, ...CLEAN_DEFAULT });
  let g = await guestVars(visit, ['--color-accent']);
  let gd = await guestVars(visit, ['--color-accent'], { dark: true });
  proof.equal('before: light accent is stock', g.vars['--color-accent'], STOCK.accentLight);
  proof.equal('before: dark accent is stock', gd.vars['--color-accent'], STOCK.accentDark);

  await go(admin, EDIT('colors'));
  await noErrorText(admin, proof, 'Colors panel');
  const form = colorsForm(admin);
  const accent = form.locator('input[name="c[--color-accent]"]');
  const before = { light: db.setting('hadrian_colors_default_light'), dark: db.setting('hadrian_colors_default_dark') };

  proof.step('Type #12ab34 into Accent (Light), switch the panel to Dark, type #34ab12, press Save changes');
  await accent.fill('#12ab34');
  await form.locator('[data-scope-set="dark"]').click();
  proof.equal('the Dark switch swapped the dark value into the field', await form.locator('input[name="scope"]').inputValue(), 'dark');
  await accent.fill('#34ab12');
  await submit(admin, saveOf(admin, 'colors'));
  await proof.shot(admin, 'Colors after Save');
  const flash = await flashText(admin);
  const after = { light: json(db.setting('hadrian_colors_default_light')), dark: json(db.setting('hadrian_colors_default_dark')) };
  proof.value('hadrian_colors_default_light / _dark', before, after);
  proof.check('the screen confirms "Colors saved"', /Colors saved/i.test(flash), flash);
  proof.equal('light row stores the light accent', after.light?.['--color-accent'], '#12ab34');
  proof.equal('dark row stores the dark accent', after.dark?.['--color-accent'], '#34ab12');

  g = await guestVars(visit, ['--color-accent']);
  proof.equal('a light guest gets #12ab34', g.vars['--color-accent'], '#12ab34');
  proof.equal('a real .btn-primary paints with it', await g.page.evaluate(() => {
    const b = document.createElement('a'); b.className = 'btn btn-primary'; b.textContent = 'x'; document.body.appendChild(b);
    return getComputedStyle(b).backgroundColor;
  }), 'rgb(18, 171, 52)');
  await proof.shot(g.page, 'guest after the light save');
  gd = await guestVars(visit, ['--color-accent'], { dark: true });
  proof.equal('a dark guest gets #34ab12', gd.vars['--color-accent'], '#34ab12');

  proof.step('Press "Restore defaults" in the save bar, then Save changes');
  await panel(admin, 'colors').locator('#mt-colors-reset').click();
  await submit(admin, saveOf(admin, 'colors'));
  const reset = { light: json(db.setting('hadrian_colors_default_light')), dark: json(db.setting('hadrian_colors_default_dark')) };
  proof.value('rows after Restore defaults + Save', after, reset);
  proof.equal('both rows are empty', [keys(reset.light), keys(reset.dark)], [[], []]);
  g = await guestVars(visit, ['--color-accent']);
  gd = await guestVars(visit, ['--color-accent'], { dark: true });
  proof.equal('light guests are back on stock', g.vars['--color-accent'], STOCK.accentLight);
  proof.equal('dark guests are back on stock', gd.vars['--color-accent'], STOCK.accentDark);
});

test('AD-23 Colours save keeps only schema tokens with a valid value that differs from default', async ({ admin, visit, proof }) => {
  proof.claim('Hex, rgb() and hsl() values that differ from the default are kept; bad hex, named colours, CSS injection, unknown tokens and values equal to the default are dropped silently.');
  settings.set({ ...CLEAN_DEFAULT });
  await go(admin, EDIT('colors'));
  const form = colorsForm(admin);
  proof.step('Write the values into the form fields in the page (no input events), add an unknown c[--evil-token] field, press Save');
  await form.evaluate(f => {
    const set = (n, v) => { f.querySelector(`input[name="c[${n}]"]`).value = v; };
    set('--color-accent', 'notacolor');
    set('--color-bg', 'rgb(1,2,3)');
    set('--color-surface', '#fff;}body{display:none}');
    set('--color-border', 'red');
    set('--color-link', 'hsl(120, 50%, 40%)');
    set('--color-text-primary', '#1D1D1F');
    set('--color-surface-secondary', '#zzz');
    const i = document.createElement('input'); i.type = 'hidden'; i.name = 'c[--evil-token]'; i.value = '#ffffff'; f.appendChild(i);
  });
  const before = db.setting('hadrian_colors_default_light');
  await submit(admin, saveOf(admin, 'colors'));
  const after = json(db.setting('hadrian_colors_default_light'));
  proof.value('hadrian_colors_default_light', before, after);
  proof.equal('only the valid, changed rgb() and hsl() values were stored', sorted(after), { '--color-bg': 'rgb(1,2,3)', '--color-link': 'hsl(120, 50%, 40%)' });
  proof.equal('the untouched dark scope stores nothing', keys(json(db.setting('hadrian_colors_default_dark'))), []);

  const { page: g, vars } = await guestVars(visit, ['--color-bg', '--color-link', '--color-surface', '--color-accent']);
  proof.equal('guests get --color-bg rgb(1,2,3)', vars['--color-bg'], 'rgb(1,2,3)');
  proof.equal('<body> paints with it', await g.evaluate(() => getComputedStyle(document.body).backgroundColor), 'rgb(1, 2, 3)');
  proof.equal('guests get the hsl() link', vars['--color-link'], 'hsl(120, 50%, 40%)');
  proof.equal('the injected surface value never reached the page', vars['--color-surface'], '#ffffff');
  proof.equal('the bad accent left the stock one', vars['--color-accent'], STOCK.accentLight);
  const block = await styleText(g, 'hadrian-colors');
  proof.check('#hadrian-colors carries no injected rule or unknown token', !/display|evil|red/.test(block || ''), block);
});

// ================================================================ AD-24

test('AD-24 Reset to preset deletes the rows and re-seeds the shipped palette', async ({ admin, visit, proof }) => {
  proof.claim('"Reset to the <Style> preset" deletes both scope rows of that style and seeds them again from its manifest.');
  settings.set({ ...DARK_ON, ...CLEAN_DEFAULT, hadrian_active_style: ['emerald', 'string'],
    hadrian_colors_emerald_light: [{ '--color-accent': '#12ab34' }, 'json'],
    hadrian_colors_emerald_dark: [{ '--color-accent': '#222222' }, 'json'] });
  let g = await guestVars(visit, ['--color-accent']);
  proof.equal('before: guests get the edited Emerald accent', g.vars['--color-accent'], '#12ab34');

  await go(admin, adminUrl('editStyle', { style: 'emerald', subcat: 'colors' }));
  const before = { light: json(db.setting('hadrian_colors_emerald_light')), dark: json(db.setting('hadrian_colors_emerald_dark')) };
  proof.step('Press "Reset to the Emerald preset" and accept the confirm');
  admin.once('dialog', d => d.accept());
  await submit(admin, colorsForm(admin).locator('button[name="mt_colors_preset_reset"]'));
  const flash = await flashText(admin);
  await proof.shot(admin, 'Colors after the preset reset');
  const after = { light: json(db.setting('hadrian_colors_emerald_light')), dark: json(db.setting('hadrian_colors_emerald_dark')) };
  proof.value('hadrian_colors_emerald_light / _dark', before, after);
  proof.check('the screen says the preset was restored', /restored to its preset/i.test(flash), flash);
  proof.equal('light accent re-seeded from the manifest', after.light?.['--color-accent'], EMERALD.light);
  proof.equal('dark accent re-seeded from the manifest', after.dark?.['--color-accent'], EMERALD.dark);
  proof.check('the light row is the full shipped palette, not just the accent', keys(after.light).length >= 9, keys(after.light));
  proof.equal('the form shows the preset accent', await colorsForm(admin).locator('input[name="c[--color-accent]"]').inputValue(), EMERALD.light);

  g = await guestVars(visit, ['--color-accent']);
  const gd = await guestVars(visit, ['--color-accent'], { dark: true });
  proof.equal('guests get the shipped light accent', g.vars['--color-accent'], EMERALD.light);
  proof.equal('dark guests get the shipped dark accent', gd.vars['--color-accent'], EMERALD.dark);
});

test('AD-24 Reset to the Default preset also deletes the legacy keys', async ({ admin, visit, proof }) => {
  proof.claim('For Default the reset also deletes the pre-refactor <tpl>_colors_default and <tpl>_colors_dark, so an upgraded install does not fall back to them.');
  settings.set({ ...DARK_ON, ...CLEAN_DEFAULT,
    hadrian_colors_default_light: [{ '--color-accent': '#abcdef' }, 'json'],
    hadrian_colors_default_dark: [{ '--color-accent': '#fedcba' }, 'json'],
    hadrian_colors_default: [{ '--color-accent': '#abcdef' }, 'json'],
    hadrian_colors_dark: [{ '--color-accent': '#fedcba' }, 'json'] });
  let g = await guestVars(visit, ['--color-accent']);
  proof.equal('before: guests get the stored accent', g.vars['--color-accent'], '#abcdef');

  await go(admin, EDIT('colors'));
  const before = { ...db.settings('hadrian_colors_default'), hadrian_colors_dark: db.setting('hadrian_colors_dark') };
  proof.step('Press "Reset to the Default preset" and accept the confirm');
  admin.once('dialog', d => d.accept());
  await submit(admin, colorsForm(admin).locator('button[name="mt_colors_preset_reset"]'));
  const after = { ...db.settings('hadrian_colors_default'), hadrian_colors_dark: db.setting('hadrian_colors_dark') };
  proof.value('the four default colour rows', before, after);
  proof.equal('all four rows are gone (Default ships no palette to re-seed)', after, { hadrian_colors_dark: null });

  g = await guestVars(visit, ['--color-accent']);
  const gd = await guestVars(visit, ['--color-accent'], { dark: true });
  proof.equal('guests are on the stock light accent, not the legacy one', g.vars['--color-accent'], STOCK.accentLight);
  proof.equal('dark guests are on the stock dark accent', gd.vars['--color-accent'], STOCK.accentDark);
  proof.equal('no #hadrian-colors block is printed', await styleText(g.page, 'hadrian-colors'), null);
});

// ================================================================ AD-25

test('AD-25 Quick presets, Generate and Undo fill the form and store nothing', async ({ admin, proof }) => {
  proof.claim('A quick preset chip and "Generate from one colour" rewrite the fields client-side, Undo puts them back, and nothing is stored until Save.');
  settings.set({ ...CLEAN_DEFAULT });
  await go(admin, EDIT('colors'));
  const form = colorsForm(admin);
  const accent = form.locator('input[name="c[--color-accent]"]');
  const stored = () => [db.setting('hadrian_colors_default_light'), db.setting('hadrian_colors_default_dark')];
  const storedBefore = stored();
  proof.equal('the Accent field starts on stock', await accent.inputValue(), STOCK.accentLight);

  const chips = form.locator('.mt-scheme[data-accent]');
  let chip = null; let want = '';
  for (let i = 0; i < await chips.count(); i++) {
    const a = (await chips.nth(i).getAttribute('data-accent')).toLowerCase();
    if (a.replace('#', '') !== STOCK.accentLight.slice(1)) { chip = chips.nth(i); want = a.startsWith('#') ? a : '#' + a; break; }
  }
  proof.check('the panel offers a quick preset other than stock', chip !== null);
  proof.step(`Click the quick preset chip for ${want}`);
  await chip.click();
  proof.equal('the Accent field takes the preset colour', (await accent.inputValue()).toLowerCase(), want);
  proof.check('the chip is marked active', await chip.evaluate(n => n.classList.contains('is-active')));

  proof.step('Type #12ab34 as the brand colour and press Generate');
  const bg = form.locator('input[name="c[--color-bg]"]');
  const bgBefore = await bg.inputValue();
  await form.locator('.mt-gen-seed').fill('#12ab34');
  await form.locator('.mt-gen-run').click();
  const gen = (await accent.inputValue()).toLowerCase();
  const near = (a, b) => [1, 3, 5].every(i => Math.abs(parseInt(a.slice(i, i + 2), 16) - parseInt(b.slice(i, i + 2), 16)) <= 2);
  proof.check('Generate wrote the seed into Accent', /^#[0-9a-f]{6}$/.test(gen) && near(gen, '#12ab34'), gen);
  proof.check('and rebuilt the neutrals around it (Page changed)', (await bg.inputValue()) !== bgBefore, `${bgBefore} -> ${await bg.inputValue()}`);
  proof.check('the report is shown', await form.locator('.mt-gen-report').isVisible());
  proof.check('Undo is enabled', await form.locator('.mt-gen-undo').isEnabled());
  await proof.shot(form.locator('.mt-gen'), 'the generator after Generate');

  proof.step('Press Undo');
  await form.locator('.mt-gen-undo').click();
  proof.equal('Accent is back on the preset colour', (await accent.inputValue()).toLowerCase(), want);
  proof.equal('Page is back where it was', await bg.inputValue(), bgBefore);
  proof.check('Undo is disabled again', await form.locator('.mt-gen-undo').isDisabled());
  const storedAfter = stored();
  proof.value('hadrian_colors_default_light / _dark', storedBefore, storedAfter);
  proof.equal('nothing was stored without Save', storedAfter, storedBefore);
});

test('AD-25 Presets and Generate fill the light and dark palettes together', async ({ admin, proof }) => {
  proof.claim('Quick presets and the generator fill both scopes at once (the dark accent derived from the light one), and the panel says so: Generate "fills in the light and dark palettes together".');
  settings.set({ ...CLEAN_DEFAULT });
  await go(admin, EDIT('colors'));
  const form = colorsForm(admin);
  const darkTwin = () => form.locator('input.mt-color-other[data-var="--color-accent"]').inputValue();
  const lede = (await form.locator('.mt-gen-lede').innerText()).replace(/\s+/g, ' ');
  proof.check('the lede says both palettes are filled', /light and dark/i.test(lede) && !/light scope only/i.test(lede), lede);

  const d0 = await darkTwin();
  proof.step('In the Light scope, press Generate with #12ab34');
  await form.locator('.mt-gen-seed').fill('#12ab34');
  await form.locator('.mt-gen-run').click();
  const d1 = await darkTwin();
  proof.step('Reload, click a quick preset chip in the Light scope');
  await go(admin, EDIT('colors'));
  await colorsForm(admin).locator('.mt-scheme[data-accent]').last().click();
  const d2 = await colorsForm(admin).locator('input.mt-color-other[data-var="--color-accent"]').inputValue();
  proof.value('dark Accent (hidden twin): start, after Generate, after a preset', d0, [d1, d2]);
  proof.note('includes/footer.tpl runs the generator recipe for both scopes (runScope(activeDark,false); runScope(!activeDark,true)) and applyAccentPreset() propagates the accent into the dark twin; the panel copy now says so.');
  proof.check('Generate in Light also filled the dark Accent', d1 !== d0, `dark accent ${d0} -> ${d1}`);
  proof.check('a preset in Light also filled the dark Accent', d2 !== d0, `dark accent ${d0} -> ${d2}`);
});

// ================================================================ AD-26

test('AD-26 Typography keeps sizes, weights and line heights only in bounds and not default', async ({ admin, visit, proof }) => {
  proof.claim('Typography Save stores a size, weight or line height only when it is inside the schema bounds (sizes 8-160, weights from the option list, line heights 0.8-3.0) and differs from the default; the client gets the stored ones as :root custom properties.');
  settings.set({ hadrian_typography: null });
  let g = await guestVars(visit, ['--text-base', '--fw-bold', '--lh-normal', '--text-xs']);
  proof.equal('before: --text-base is the stock 13px', g.vars['--text-base'], '13px');

  await go(admin, EDIT('typography'));
  await noErrorText(admin, proof, 'Typography panel');
  const form = admin.locator('form.mt-typography');
  proof.step('Base 15px, Bold 800, Normal line height 1.6; and, past the field limits: Extra Small 500px, Light weight 350, Tight line height 5; Small and Snug left at default; Save');
  await form.evaluate(f => { f.noValidate = true; });
  await form.locator('input[name="size_text-base"]').fill('15');
  await form.locator('select[name="weight_fw-bold"]').selectOption('800');
  await form.locator('input[name="lh_lh-normal"]').fill('1.6');
  await form.locator('input[name="size_text-xs"]').fill('500');
  await form.locator('select[name="weight_fw-light"]').evaluate(s => { s.add(new Option('350', '350')); s.value = '350'; });
  await form.locator('input[name="lh_lh-tight"]').fill('5');
  const before = db.setting('hadrian_typography');
  await submit(admin, saveOf(admin, 'typography'));
  const flash = await flashText(admin);
  await proof.shot(admin, 'Typography after Save');
  const after = json(db.setting('hadrian_typography'));
  proof.value('hadrian_typography', before, after);
  proof.check('the screen confirms the save', /Typography saved/i.test(flash), flash);
  proof.equal('only the in-bounds, changed values were stored', after, { sizes: { '--text-base': 15 }, weights: { '--fw-bold': 800 }, lineHeights: { '--lh-normal': 1.6 } });

  g = await guestVars(visit, ['--text-base', '--fw-bold', '--lh-normal', '--text-xs', '--fw-light', '--lh-tight']);
  proof.equal('guests get --text-base 15px', g.vars['--text-base'], '15px');
  proof.equal('guests get --fw-bold 800', g.vars['--fw-bold'], '800');
  proof.equal('guests get --lh-normal 1.6', g.vars['--lh-normal'], '1.6');
  proof.equal('the out-of-range size stayed stock', g.vars['--text-xs'], '11px');
  proof.equal('the bad weight stayed stock', g.vars['--fw-light'], '300');
  proof.check('#hadrian-typography carries the three values', /--text-base:15px/.test(await styleText(g.page, 'hadrian-typography')));

  proof.step('Put the three back to their defaults and Save');
  await form.locator('input[name="size_text-base"]').fill('13');
  await form.locator('select[name="weight_fw-bold"]').selectOption('700');
  await form.locator('input[name="lh_lh-normal"]').fill('1.47059');
  await submit(admin, saveOf(admin, 'typography'));
  const reset = json(db.setting('hadrian_typography'));
  proof.value('hadrian_typography (second save)', after, reset);
  proof.equal('nothing is stored', keys(reset), []);
  g = await guestVars(visit, ['--text-base', '--fw-bold']);
  proof.equal('guests are back on 13px', g.vars['--text-base'], '13px');
  proof.equal('no #hadrian-typography block is printed', await styleText(g.page, 'hadrian-typography'), null);
});

test('AD-26 Typography Google body and heading font are checked against the catalog', async ({ admin, visit, proof }) => {
  proof.claim('A Google family for the body or the headings is stored only when the catalog knows it, with the weights it ships; the client then links fonts.googleapis.com and sets --font-family / --font-family-heading.');
  settings.set({ hadrian_typography: null });
  await go(admin, EDIT('typography'));
  const form = admin.locator('form.mt-typography');
  proof.step('Pick Google Font "Roboto" for the body and "Lora" for headings (the pickers write their hidden fields), Save');
  await form.locator('input[name="ff_google"]').evaluate(el => { el.value = 'Roboto'; el.dispatchEvent(new Event('change', { bubbles: true })); });
  await form.locator('input[name="hf_google"]').evaluate(el => { el.value = 'Lora'; el.dispatchEvent(new Event('change', { bubbles: true })); });
  proof.check('picking a family selected the Google Font mode', await form.locator('input[name="ff_mode"][value="google"]').isChecked());
  const before = db.setting('hadrian_typography');
  await submit(admin, saveOf(admin, 'typography'));
  const after = json(db.setting('hadrian_typography'));
  proof.value('hadrian_typography', before, after);
  proof.equal('the body family is stored', after?.fontFamily?.google, 'Roboto');
  proof.equal('and the theme weights Roboto ships', after?.fontFamily?.googleWeights, [300, 400, 500, 600, 700]);
  proof.equal('the heading family is stored', after?.headingFamily?.google, 'Lora');

  const guest = await guestPage(visit);
  let page = await html(guest, '/');
  const css = (page.body.match(/<style id="hadrian-typography">([^<]*)<\/style>/) || [])[1] || '';
  proof.note(`stored stack: ${after?.fontFamily?.stack}; emitted block: ${css}`);
  proof.check('the guest head links Roboto from fonts.googleapis.com', /fonts\.googleapis\.com\/css2\?family=Roboto:wght@300;400;500;600;700&amp;display=swap/.test(page.body));
  proof.check('and Lora', /fonts\.googleapis\.com\/css2\?family=Lora:wght@/.test(page.body));
  proof.check('--font-family-heading names Lora over the body font', css.includes("--font-family-heading:'Lora', var(--font-family)"), css);
  proof.limit('The Google-font page is read as HTML, not rendered, so no request leaves localhost; the computed font for a rendered page is proven with the system and self-hosted modes in the next test.');
  proof.equal('the stack is stored as the picker wrote it', after?.fontFamily?.stack, "'Roboto', system-ui, sans-serif");
  proof.check('--font-family names Roboto', css.includes("--font-family:'Roboto', system-ui, sans-serif"), css);
});

test('AD-26 Typography drops a Google family the catalog does not know', async ({ admin, visit, proof }) => {
  proof.claim('An unknown Google family name is not stored, and the client links no Google font for it.');
  settings.set({ hadrian_typography: [{ fontFamily: { mode: 'google', google: 'Roboto', googleWeights: [300, 400, 500, 600, 700] }, headingFamily: { mode: 'google', google: 'Lora' } }, 'json'] });
  const after = json(db.setting('hadrian_typography'));
  const guest = await guestPage(visit);
  let page = await html(guest, '/');
  proof.check('before: the guest head links Roboto', /family=Roboto:wght@/.test(page.body));
  await go(admin, EDIT('typography'));
  const form = admin.locator('form.mt-typography');
  proof.step('Pick "Not A Real Font Xyz" for the body, set headings back to "Same as body text", Save');
  await form.locator('input[name="ff_google"]').evaluate(el => { el.value = 'Not A Real Font Xyz'; el.dispatchEvent(new Event('change', { bubbles: true })); });
  await setChecked(form.locator('input[name="hf_mode"][value="body"]'));
  await submit(admin, saveOf(admin, 'typography'));
  const after2 = json(db.setting('hadrian_typography'));
  proof.value('hadrian_typography (unknown family)', after, after2);
  proof.check('an unknown family is not stored', !after2?.fontFamily, JSON.stringify(after2));
  proof.check('and the heading font is cleared', !after2?.headingFamily, JSON.stringify(after2));
  page = await html(guest, '/');
  proof.check('the guest head no longer links any Google font', !/fonts\.googleapis\.com\/css2/.test(page.body));
  proof.check('and never names the unknown family', !page.body.includes('Not A Real Font'));
});

test('AD-26 Typography system stack and self-hosted name reach the rendered page', async ({ admin, visit, proof }) => {
  proof.claim('System mode stores the typed stack; self-hosted mode stores the face name with everything but letters, digits, space, _ and - removed; <body> renders in the result.');
  settings.set({ hadrian_typography: null });
  await go(admin, EDIT('typography'));
  const form = admin.locator('form.mt-typography');
  proof.step('Choose "System fonts", type "Georgia, serif" as its stack, Save');
  await setChecked(form.locator('input[name="ff_mode"][value="system"]'));
  await form.locator('input[name="ff_system"]').fill('Georgia, serif');
  await submit(admin, saveOf(admin, 'typography'));
  const sys = json(db.setting('hadrian_typography'));
  proof.value('hadrian_typography', null, sys);
  proof.equal('system mode and the stack are stored', sys?.fontFamily, { mode: 'system', stack: 'Georgia, serif' });
  let g = await guestVars(visit, ['--font-family']);
  proof.equal('guests get --font-family Georgia, serif', g.vars['--font-family'], 'Georgia, serif');
  proof.equal('<body> renders in it', await g.page.evaluate(() => getComputedStyle(document.body).fontFamily), 'Georgia, serif');

  proof.step('Choose "Default" and Save');
  await setChecked(form.locator('input[name="ff_mode"][value="default"]'));
  await submit(admin, saveOf(admin, 'typography'));
  const back = json(db.setting('hadrian_typography'));
  proof.value('hadrian_typography (Default)', sys, back);
  proof.equal('nothing is stored for Default', keys(back), []);
  g = await guestVars(visit, ['--font-family']);
  proof.check('guests are back on the stock stack', g.vars['--font-family'].startsWith('-apple-system'), g.vars['--font-family']);
});

test('AD-26 Typography self-hosted face name is sanitised and drives the rendered font', async ({ admin, visit, proof }) => {
  proof.claim('Self-hosted mode stores the face name with everything but letters, digits, space, _ and - removed, and <body> renders with that name first so the @font-face for it can match.');
  settings.set({ hadrian_typography: null });
  await go(admin, EDIT('typography'));
  const form = admin.locator('form.mt-typography');
  const sys = null;
  let g;
  proof.step('Choose "Self-hosted font", type "Brand<script>Sans!", Save');
  await setChecked(form.locator('input[name="ff_mode"][value="folder"]'));
  await form.locator('input[name="ff_folder"]').fill('Brand<script>Sans!');
  await submit(admin, saveOf(admin, 'typography'));
  const fold = json(db.setting('hadrian_typography'));
  proof.value('hadrian_typography (self-hosted)', sys, fold);
  const name = fold?.fontFamily?.folder || '';
  proof.equal('self-hosted mode is stored', fold?.fontFamily?.mode, 'folder');
  proof.check('the stored face name holds only letters, digits, space, _ and -', /^[A-Za-z0-9 _-]+$/.test(name) && name.startsWith('Brand') && name.endsWith('Sans'), name);
  g = await guestVars(visit, ['--font-family']);
  proof.check('guests get a --font-family with no markup in it', !/[<>!]/.test(g.vars['--font-family']) && g.vars['--font-family'].includes(name), g.vars['--font-family']);
  const bodyFont = await g.page.evaluate(() => getComputedStyle(document.body).fontFamily);
  proof.note(`stored stack: ${fold?.fontFamily?.stack}; guest --font-family: ${g.vars['--font-family']}`);
  proof.equal('<body> renders with the stored face name as its first family (so the @font-face can match)', bodyFont.split(',')[0].trim().replace(/^["']|["']$/g, ''), name);
});

// ---------------------------------------------- Google Fonts catalog file
// AD-26 (missing catalog) and AD-27 change core/config/google-fonts.json for
// the length of one test. The original bytes are kept in tests/.local and put
// back in `finally`; a copy left by a crashed run is restored first.
const CATALOG = path.resolve(TESTS_DIR, '..', 'hadrian', 'templates', 'hadrian', 'core', 'config', 'google-fonts.json');
const CATALOG_BAK = path.join(TESTS_DIR, '.local', 'audit-google-fonts.json.bak');
function healCatalog() {
  if (fs.existsSync(CATALOG_BAK)) { fs.copyFileSync(CATALOG_BAK, CATALOG); fs.unlinkSync(CATALOG_BAK); }
}
async function withCatalog(text, fn) {
  healCatalog();
  const original = fs.readFileSync(CATALOG);
  fs.writeFileSync(CATALOG_BAK, original);
  try {
    fs.writeFileSync(CATALOG, text(original.toString('utf8')));
    await fn();
  } finally {
    fs.writeFileSync(CATALOG, original);
    fs.unlinkSync(CATALOG_BAK);
  }
  if (!fs.readFileSync(CATALOG).equals(original)) throw new Error('google-fonts.json was not restored byte for byte');
}
test.beforeAll(healCatalog);

test('AD-26 Typography accepts any Google family name when the catalog is missing', async ({ admin, visit, proof }) => {
  proof.claim('With no catalog to check against, any Google family name passes the save (the picker has nothing to allowlist).');
  settings.set({ hadrian_typography: null });
  await withCatalog(() => '{"families":"gone"}', async () => {
    await go(admin, EDIT('typography'));
    const count = await admin.locator('[data-fontpick]').first().getAttribute('data-count');
    proof.equal('the picker reports an empty catalog', count, '0');
    proof.step('With the catalog emptied, pick "Made Up Family" as the body Google font, Save');
    const form = admin.locator('form.mt-typography');
    await form.locator('input[name="ff_google"]').evaluate(el => { el.value = 'Made Up Family'; el.dispatchEvent(new Event('change', { bubbles: true })); });
    await submit(admin, saveOf(admin, 'typography'));
  });
  const after = json(db.setting('hadrian_typography'));
  proof.value('hadrian_typography', null, after);
  proof.equal('the unknown family was stored', after?.fontFamily?.google, 'Made Up Family');
  proof.check('without a weights list (no catalog row to read it from)', !after?.fontFamily?.googleWeights, JSON.stringify(after));
  const guest = await guestPage(visit);
  const page = await html(guest, '/');
  proof.check('the guest head links it with the configured weight scale', /family=Made%20Up%20Family:wght@300;400;500;600;700/.test(page.body));
  proof.note('google-fonts.json was replaced for this test only and restored byte for byte afterwards.');
});

// ================================================================ AD-27

test('AD-27 Google Fonts catalog rows are re-validated on read', async ({ admin, proof }) => {
  proof.claim('Every catalog row is re-checked when the Styles page reads it: a family name outside [A-Za-z0-9 ], a category outside the five slugs, or a weight outside 100-900 never reaches the picker or the save allowlist.');
  settings.set({ hadrian_typography: null });
  const island = () => admin.locator('script[data-fontpick-catalog]').evaluate(s => JSON.parse(s.textContent));

  await go(admin, EDIT('typography'));
  const shipped = await island();
  const fileRows = JSON.parse(fs.readFileSync(CATALOG, 'utf8')).families.length;
  proof.equal('untouched, the picker carries every shipped row', shipped.length, fileRows);
  const cats = new Set(['sans', 'serif', 'display', 'hand', 'mono']);
  proof.check('every shipped row passes the read checks', shipped.every(r => /^[A-Za-z0-9][A-Za-z0-9 ]*$/.test(r[0]) && cats.has(r[1]) && r[2].every(w => w >= 100 && w <= 900)));

  const tampered = [
    '["Evil</script><img src=x>","sans",[400],0]',
    '["Weird Category","notacat",[400],0]',
    '["Audit Weights Font","serif",[50,400,1200,"700"],1]',
  ];
  await withCatalog(t => t.replace(/\n  \]\n\}\s*$/, ',\n    ' + tampered.join(',\n    ') + '\n  ]\n}\n'), async () => {
    proof.step('Append three tampered rows to google-fonts.json and reopen Typography');
    await go(admin, EDIT('typography'));
    const rows = await island();
    const byName = n => rows.find(r => r[0] === n);
    proof.equal('one of the three rows survived', rows.length, fileRows + 1);
    proof.check('the row with markup in its name was dropped', !rows.some(r => /Evil|[<>]/.test(r[0])));
    proof.check('the row with an unknown category was dropped', !byName('Weird Category'));
    proof.equal('the valid row kept only weights 100-900', byName('Audit Weights Font')?.[2], [400, 700]);
    proof.equal('the picker count says so', await admin.locator('[data-fontpick]').first().getAttribute('data-count'), String(fileRows + 1));

    proof.step('Try to save the dropped "Weird Category" as the body font, then the surviving "Audit Weights Font"');
    const form = admin.locator('form.mt-typography');
    const pick = v => form.locator('input[name="ff_google"]').evaluate((el, val) => { el.value = val; el.dispatchEvent(new Event('change', { bubbles: true })); }, v);
    await pick('Weird Category');
    await submit(admin, saveOf(admin, 'typography'));
    const t1 = json(db.setting('hadrian_typography'));
    proof.check('a dropped row is not allowlisted by the save', !t1?.fontFamily, JSON.stringify(t1));
    await pick('Audit Weights Font');
    await submit(admin, saveOf(admin, 'typography'));
    const t2 = json(db.setting('hadrian_typography'));
    proof.value('hadrian_typography', t1, t2);
    proof.equal('the surviving row is accepted', t2?.fontFamily?.google, 'Audit Weights Font');
    proof.equal('with its validated weights resolved at save', t2?.fontFamily?.googleWeights, [400, 700]);
  });
  proof.note('google-fonts.json was changed for this test only and restored byte for byte afterwards.');
});

// ================================================================ AD-28

test('AD-28 General panel: valid, in-range, changed values only; Reset all puts it back', async ({ admin, visit, proof }) => {
  proof.claim('Styles > General stores only a known shadow key or an in-range number that differs from the default (px, em, ms with the curve re-attached); an out-of-range value or an unknown key is dropped silently.');
  settings.set({ hadrian_general: null });
  let g = await guestVars(visit, ['--radius-md', '--shadow-card', '--btn-pad-y', '--transition-fast', '--radius-sm']);
  proof.equal('before: --radius-md is 12px', g.vars['--radius-md'], '12px');

  await go(admin, EDIT('general'));
  await noErrorText(admin, proof, 'General panel');
  const form = admin.locator('form.mt-general');
  proof.step('Medium radius 20, Card shadow None, Button pad Y 0.9, Fast 300; out of range: Small radius 5000, Custom shadow strength 90; unknown key "evil" for Card hover; Save');
  await form.evaluate(f => { f.noValidate = true; });
  await form.locator('[name="gen[--radius-md]"]').fill('20');
  await form.locator('[name="gen[--shadow-card]"]').selectOption('none');
  await form.locator('[name="gen[--btn-pad-y]"]').fill('0.9');
  await form.locator('[name="gen[--transition-fast]"]').fill('300');
  await form.locator('[name="gen[--radius-sm]"]').fill('5000');
  await form.locator('[name="gen[--shadow-custom-strength]"]').evaluate(el => { el.max = '100'; el.value = '90'; });
  await form.locator('[name="gen[--shadow-card-hover]"]').evaluate(s => { s.add(new Option('evil', 'evil')); s.value = 'evil'; });
  const before = db.setting('hadrian_general');
  await submit(admin, saveOf(admin, 'general'));
  const after = json(db.setting('hadrian_general'));
  proof.value('hadrian_general', before, after);
  await proof.shot(admin, 'General after Save');
  proof.equal('the four valid changes were stored, nothing else', keys(after), ['--btn-pad-y', '--radius-md', '--shadow-card', '--transition-fast']);
  proof.equal('radius stored as 20px', after['--radius-md'], '20px');
  proof.equal('shadow stored as its css', after['--shadow-card'], 'none');
  proof.equal('em stored with its unit', after['--btn-pad-y'], '0.9em');
  proof.check('motion stored with the curve re-attached', /^300ms cubic-bezier\(/.test(after['--transition-fast']), after['--transition-fast']);

  g = await guestVars(visit, ['--radius-md', '--shadow-card', '--btn-pad-y', '--radius-sm', '--shadow-card-hover']);
  proof.equal('guests get --radius-md 20px', g.vars['--radius-md'], '20px');
  proof.equal('guests get --shadow-card none', g.vars['--shadow-card'], 'none');
  proof.equal('guests get --btn-pad-y 0.9em', g.vars['--btn-pad-y'], '0.9em');
  proof.equal('the out-of-range radius stayed stock', g.vars['--radius-sm'], '8px');

  proof.step('Press "Reset all to default", then Save');
  await panel(admin, 'general').locator('#mt-general-reset').click();
  await submit(admin, saveOf(admin, 'general'));
  const reset = json(db.setting('hadrian_general'));
  proof.value('hadrian_general (after reset)', after, reset);
  proof.equal('nothing is stored', keys(reset), []);
  g = await guestVars(visit, ['--radius-md']);
  proof.equal('guests are back on 12px', g.vars['--radius-md'], '12px');
});

test('AD-28 Buttons panel: known option keys only, and the buttons repaint', async ({ admin, visit, proof }) => {
  proof.claim('Styles > Buttons stores a size scale key or a matrix colour key only when it is one the schema knows and differs from the default; the client maps it to --btn-* custom properties.');
  settings.set({ hadrian_buttons: null });
  await go(admin, EDIT('buttons'));
  const form = admin.locator('form.mt-buttons');
  proof.step('Primary background = Danger, Medium radius = Small; unknown keys: Medium font size "huge", Default background "evil"; Save');
  await form.locator('select[name="v[primary][bg]"]').selectOption('danger');
  await form.locator('select[name="size[--btn-radius]"]').selectOption('sm');
  await form.locator('select[name="size[--btn-font-size]"]').evaluate(s => { s.add(new Option('huge', 'huge')); s.value = 'huge'; });
  await form.locator('select[name="v[default][bg]"]').evaluate(s => { s.add(new Option('evil', 'evil')); s.value = 'evil'; });
  const before = db.setting('hadrian_buttons');
  await submit(admin, saveOf(admin, 'buttons'));
  const after = json(db.setting('hadrian_buttons'));
  proof.value('hadrian_buttons', before, after);
  proof.equal('only the two valid changes were stored', after, { sizes: { '--btn-radius': 'sm' }, variants: { primary: { bg: 'danger' } } });

  const g = await guestPage(visit);
  await g.goto('/');
  const facts = await g.evaluate(() => {
    const b = document.createElement('a'); b.className = 'btn btn-primary'; b.textContent = 'x'; document.body.appendChild(b);
    const probe = document.createElement('div'); probe.style.background = 'var(--brand-danger)'; document.body.appendChild(probe);
    const r = document.createElement('div'); r.style.borderRadius = 'var(--radius-sm)'; document.body.appendChild(r);
    const cs = getComputedStyle(b);
    return { bg: cs.backgroundColor, danger: getComputedStyle(probe).backgroundColor, radius: cs.borderTopLeftRadius, sm: getComputedStyle(r).borderTopLeftRadius, font: getComputedStyle(document.documentElement).getPropertyValue('--btn-font-size').trim() };
  });
  proof.equal('a .btn-primary paints in the danger colour', facts.bg, facts.danger);
  proof.equal('and takes the small radius', facts.radius, facts.sm);
  proof.check('#hadrian-buttons carries no unknown key', !/huge|evil/.test(await styleText(g, 'hadrian-buttons') || ''));

  proof.step('Press "Reset all to default", then Save');
  await panel(admin, 'buttons').locator('#mt-buttons-reset').click();
  await submit(admin, saveOf(admin, 'buttons'));
  proof.equal('nothing is stored', keys(json(db.setting('hadrian_buttons'))), []);
  await g.goto('/');
  proof.equal('no #hadrian-buttons block is printed', await styleText(g, 'hadrian-buttons'), null);
});

test('AD-28 Forms panel: valid keys and in-range px only', async ({ admin, visit, proof }) => {
  proof.claim('Styles > Forms stores a known colour key, a known scale key, or an in-range px size that differs from the default; out-of-range px is dropped.');
  settings.set({ hadrian_forms: null });
  await go(admin, EDIT('forms'));
  const form = admin.locator('form.mt-forms');
  proof.step('Input background = Surface 2, Input radius = Medium; checkbox size 1500px (past 999); Save');
  await form.evaluate(f => { f.noValidate = true; });
  await form.locator('select[name="c[--input-bg]"]').selectOption('surface-2');
  await form.locator('select[name="size[--input-radius]"]').selectOption('md');
  await form.locator('input[name="size[--icheck-size]"]').fill('1500');
  const before = db.setting('hadrian_forms');
  await submit(admin, saveOf(admin, 'forms'));
  const after = json(db.setting('hadrian_forms'));
  proof.value('hadrian_forms', before, after);
  proof.equal('only the two valid changes were stored', after, { sizes: { '--input-radius': 'md' }, colors: { '--input-bg': 'surface-2' } });

  const g = await guestPage(visit);
  await g.goto('/');
  const facts = await g.evaluate(() => {
    const i = document.createElement('input'); i.className = 'form-input'; document.body.appendChild(i);
    const p = document.createElement('div'); p.style.background = 'var(--color-surface-secondary)'; p.style.borderRadius = 'var(--radius-md)'; document.body.appendChild(p);
    return { bg: getComputedStyle(i).backgroundColor, want: getComputedStyle(p).backgroundColor,
      radius: getComputedStyle(document.documentElement).getPropertyValue('--input-radius').trim(), md: getComputedStyle(p).borderTopLeftRadius,
      icheck: getComputedStyle(document.documentElement).getPropertyValue('--icheck-size').trim() };
  });
  proof.equal('a .form-input paints in Surface 2', facts.bg, facts.want);
  proof.equal('--input-radius resolves to the medium radius', facts.radius, facts.md);
  proof.equal('the out-of-range checkbox size stayed stock', facts.icheck, '18px');

  proof.step('Press "Reset all to default", then Save');
  await panel(admin, 'forms').locator('#mt-forms-reset').click();
  await submit(admin, saveOf(admin, 'forms'));
  proof.equal('nothing is stored', keys(json(db.setting('hadrian_forms'))), []);
});

test('AD-28 Elements panel: an out-of-range padding resets to default', async ({ admin, visit, proof }) => {
  proof.claim('Styles > Elements stores known scale keys and in-range px; posting an out-of-range px later drops it, so the token goes back to its default.');
  settings.set({ hadrian_elements: null });
  await go(admin, EDIT('elements'));
  const form = admin.locator('form.mt-elements');
  proof.step('Card padding 32, Card radius None, Card shadow "evil" (unknown); Save');
  await form.locator('input[name="size[--card-pad]"]').fill('32');
  await form.locator('select[name="size[--card-radius]"]').selectOption('none');
  await form.locator('select[name="size[--card-shadow]"]').evaluate(s => { s.add(new Option('evil', 'evil')); s.value = 'evil'; });
  const before = db.setting('hadrian_elements');
  await submit(admin, saveOf(admin, 'elements'));
  const after = json(db.setting('hadrian_elements'));
  proof.value('hadrian_elements', before, after);
  proof.equal('padding and radius stored, the unknown shadow dropped', sorted(after), { sizes: { '--card-pad': 32, '--card-radius': 'none' } });

  const g = await guestPage(visit);
  await g.goto('/');
  const card = () => g.evaluate(() => {
    const c = document.createElement('div'); c.className = 'card'; const b = document.createElement('div'); b.className = 'card-body'; c.appendChild(b); document.body.appendChild(c);
    return { pad: getComputedStyle(b).paddingBottom, radius: getComputedStyle(c).borderTopLeftRadius };
  });
  let facts = await card();
  proof.equal('a .card-body pads 32px', facts.pad, '32px');
  proof.equal('a .card has square corners', facts.radius, '0px');

  proof.step('Card padding 1000 (past 999), Save');
  await form.evaluate(f => { f.noValidate = true; });
  await form.locator('input[name="size[--card-pad]"]').fill('1000');
  await submit(admin, saveOf(admin, 'elements'));
  const after2 = json(db.setting('hadrian_elements'));
  proof.value('hadrian_elements (out of range)', after, after2);
  proof.equal('the padding is no longer stored', after2, { sizes: { '--card-radius': 'none' } });
  await g.goto('/');
  facts = await card();
  proof.equal('a .card-body is back on 24px', facts.pad, '24px');
});

test('AD-28 Navigation panel: migrates legacy values, keeps in-range px only', async ({ admin, visit, proof }) => {
  proof.claim('Styles > Navigation moves legacy nav sizes out of <tpl>_layout_vars, stores in-range px that differ from the default in <tpl>_navigation_vars, and drops out-of-range values.');
  settings.set({ hadrian_navigation_vars: null, hadrian_layout_vars: [{ '--sidebar-width': 280, '--content-pad-x': 40 }, 'json'] });
  await go(admin, EDIT('navigation'));
  const migrated = { nav: json(db.setting('hadrian_navigation_vars')), layout: json(db.setting('hadrian_layout_vars')) };
  proof.equal('opening the panel moved --sidebar-width to _navigation_vars', migrated.nav, { '--sidebar-width': 280 });
  proof.equal('and left only the content key in _layout_vars', migrated.layout, { '--content-pad-x': 40 });

  const form = admin.locator('form.mt-navigation');
  proof.step('Sidebar width 300, Logo height 5000 (past 4000), Save');
  await form.evaluate(f => { f.noValidate = true; });
  await form.locator('input[name="nav[--sidebar-width]"]').fill('300');
  await form.locator('input[name="nav[--nav-logo-height]"]').fill('5000');
  await submit(admin, saveOf(admin, 'navigation'));
  const after = json(db.setting('hadrian_navigation_vars'));
  proof.value('hadrian_navigation_vars', migrated.nav, after);
  proof.equal('only the in-range width was stored', after, { '--sidebar-width': 300 });
  const g = await guestVars(visit, ['--sidebar-width', '--nav-logo-height', '--content-pad-x']);
  proof.equal('guests get --sidebar-width 300px', g.vars['--sidebar-width'], '300px');
  proof.equal('the out-of-range logo height stayed stock', g.vars['--nav-logo-height'], '28px');
  proof.equal('the content padding stayed in _layout_vars and still applies', g.vars['--content-pad-x'], '40px');
  await proof.shot(g.page, 'guest with a 300px sidebar');

  proof.step('Press "Reset all to default", then Save');
  await panel(admin, 'navigation').locator('#mt-navigation-reset').click();
  await submit(admin, saveOf(admin, 'navigation'));
  proof.equal('nothing is stored', keys(json(db.setting('hadrian_navigation_vars'))), []);
  const g2 = await guestVars(visit, ['--sidebar-width']);
  proof.equal('guests are back on 260px', g2.vars['--sidebar-width'], '260px');
});

// ================================================================ AD-29

test('AD-29 Custom CSS keeps child combinators, quotes and ampersands as typed', async ({ admin, visit, proof }) => {
  proof.claim('The Custom CSS box is stored raw, so >, quotes and & survive the save, the textarea round-trips them and the client gets working CSS.');
  settings.set({ hadrian_custom_css: null });
  await go(admin, adminUrl('editStyle', { style: 'default', tab: 'custom-css' }));
  const css = 'body > .audit-x{outline:2px solid rgb(4,5,6)}\n.audit-x::after{content:"a&b"}';
  proof.step('Type a rule with a child combinator and one with quotes and an ampersand, press Save CSS');
  const before = db.setting('hadrian_custom_css');
  await admin.locator('textarea[name="custom_css"]').fill(css);
  await submit(admin, '.mt-custom-css .mt-savebar button[type="submit"]');
  const after = db.setting('hadrian_custom_css');
  const shown = await admin.locator('textarea[name="custom_css"]').inputValue();
  const g = await guestPage(visit);
  await g.goto('/');
  const printed = await styleText(g, 'hadrian-custom-css');
  const applied = await g.evaluate(() => {
    const d = document.createElement('div'); d.className = 'audit-x'; document.body.appendChild(d);
    return { outline: getComputedStyle(d).outlineStyle, after: getComputedStyle(d, '::after').content };
  });
  proof.value('hadrian_custom_css', before, after);
  proof.note(`textarea after the reload: ${shown}; guest <style>: ${printed}; .audit-x outline/::after: ${JSON.stringify(applied)}`);
  // A browser submits a textarea's line breaks as \r\n; that is the form
  // encoding, not a change to what was typed.
  proof.equal('the stored value is exactly what was typed (line endings aside)', String(after ?? '').replace(/\r\n/g, '\n'), css);
  proof.equal('the textarea shows what was typed', shown.replace(/\r\n/g, '\n'), css);
  proof.equal('a child-combinator rule applies on the guest page', applied.outline, 'solid');
  proof.equal('the quoted content survives', applied.after, '"a&b"');
});

test('AD-29 Custom CSS is stored and reaches every client page', async ({ admin, visit, proof }) => {
  proof.claim('The Custom CSS box is stored in <tpl>_custom_css and printed in <style id="hadrian-custom-css"> on client pages; emptying it removes the block.');
  settings.set({ hadrian_custom_css: null });
  await go(admin, adminUrl('editStyle', { style: 'default', tab: 'custom-css' }));
  await noErrorText(admin, proof, 'Custom CSS tab');
  const css = 'body{outline:3px solid rgb(1,2,3)}';
  proof.step('Type body{outline:3px solid rgb(1,2,3)} and press Save CSS');
  const before = db.setting('hadrian_custom_css');
  await admin.locator('textarea[name="custom_css"]').fill(css);
  await submit(admin, '.mt-custom-css .mt-savebar button[type="submit"]');
  const flash = await flashText(admin);
  await proof.shot(admin, 'Custom CSS after Save');
  const after = db.setting('hadrian_custom_css');
  proof.value('hadrian_custom_css', before, after);
  proof.check('the screen confirms the save', /Custom CSS saved/i.test(flash), flash);
  proof.equal('the stored value is what was typed', after, css);

  const g = await guestPage(visit);
  await g.goto('/');
  proof.equal('the guest page prints it', await styleText(g, 'hadrian-custom-css'), css);
  const o = await g.evaluate(() => { const cs = getComputedStyle(document.body); return `${cs.outlineWidth} ${cs.outlineStyle} ${cs.outlineColor}`; });
  proof.equal('<body> renders the outline', o, '3px solid rgb(1, 2, 3)');
  await proof.shot(g, 'guest with the custom outline');

  proof.step('Empty the box and Save CSS');
  await admin.locator('textarea[name="custom_css"]').fill('');
  await submit(admin, '.mt-custom-css .mt-savebar button[type="submit"]');
  proof.equal('the stored value is empty', db.setting('hadrian_custom_css'), '');
  await g.goto('/');
  proof.equal('no custom CSS block is printed', await styleText(g, 'hadrian-custom-css'), null);
  proof.equal('the outline is gone', await g.evaluate(() => getComputedStyle(document.body).outlineStyle), 'none');
});

// ================================================================ AD-92

test('AD-92 A light-only colour stays out of dark mode and palette previews', async ({ admin, visit, proof }) => {
  proof.claim('The light block is printed under html:not([data-theme="dark"]):not([data-palette]), so a token overridden only in light does not leak into dark mode or into a ?palette= preview.');
  settings.set({ ...DARK_ON, ...CLEAN_DEFAULT });
  await go(admin, EDIT('colors'));
  proof.step('Set Accent and Primary text in the Light scope only (fields written in the page, the dark twins untouched), Save');
  await colorsForm(admin).evaluate(f => {
    f.querySelector('input[name="c[--color-accent]"]').value = '#12ab34';
    f.querySelector('input[name="c[--color-text-primary]"]').value = '#101112';
  });
  await submit(admin, saveOf(admin, 'colors'));
  const light = json(db.setting('hadrian_colors_default_light'));
  const dark = json(db.setting('hadrian_colors_default_dark'));
  proof.value('hadrian_colors_default_light / _dark', null, { light, dark });
  proof.equal('the light row holds both tokens', sorted(light), { '--color-accent': '#12ab34', '--color-text-primary': '#101112' });
  proof.equal('the dark row is empty', keys(dark), []);

  const g = await guestVars(visit, ['--color-accent', '--color-text-primary']);
  const block = await styleText(g.page, 'hadrian-colors');
  proof.equal('the block is scoped to light, with no dark block', block, 'html:not([data-theme="dark"]):not([data-palette]){--color-accent:#12ab34;--color-text-primary:#101112;}');
  proof.equal('light guests get the override', g.vars['--color-accent'], '#12ab34');
  const gd = await guestVars(visit, ['--color-accent', '--color-text-primary'], { dark: true });
  proof.equal('dark guests keep the stock dark accent', gd.vars['--color-accent'], STOCK.accentDark);
  proof.equal('and the stock dark text colour', gd.vars['--color-text-primary'], '#f5f5f7');
  const gp = await guestVars(visit, ['--color-accent'], { path: '/?palette=emerald' });
  proof.check('a ?palette= preview is drawn by the palette, not the light override', gp.vars['--color-accent'] !== '#12ab34', gp.vars['--color-accent']);
});

test('AD-92 An empty per-scope row falls back to the legacy keys', async ({ visit, proof }) => {
  proof.claim('When <tpl>_colors_<style>_light (or _dark) is missing or empty, the client reads the pre-refactor <tpl>_colors_<style> (or <tpl>_colors_dark) instead.');
  proof.note('No admin screen writes legacy keys any more (opening Styles migrates them), so this state is set in the database and only the client output is proven.');
  settings.set({ ...DARK_ON, ...CLEAN_DEFAULT,
    hadrian_colors_default_light: [[], 'json'],
    hadrian_colors_default: [{ '--color-accent': '#aa1144' }, 'json'],
    hadrian_colors_dark: [{ '--color-accent': '#ff88aa' }, 'json'] });
  const g = await guestVars(visit, ['--color-accent']);
  proof.equal('light guests get the legacy light colour', g.vars['--color-accent'], '#aa1144');
  const gd = await guestVars(visit, ['--color-accent'], { dark: true });
  proof.equal('dark guests get the legacy dark colour', gd.vars['--color-accent'], '#ff88aa');
  settings.set({ hadrian_colors_default_light: [{ '--color-accent': '#123456' }, 'json'] });
  const g2 = await guestVars(visit, ['--color-accent']);
  proof.equal('a non-empty per-scope row wins over the legacy key', g2.vars['--color-accent'], '#123456');
});
