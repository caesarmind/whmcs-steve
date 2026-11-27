// AD-E Layouts screen (tests/FEATURES.md AD-35 to AD-42): every control on
// Addons > Hadrian > Layouts pressed the way an admin presses it, then proven
// in hadrian_settings and on the client area.
//
// The Layouts screen has no global Save. Each Activate row, option segment,
// flag toggle and Apply button is its own small form, so a test presses that
// control and waits for the redirect it answers with.

import fs from 'node:fs';
import path from 'node:path';
import { test, db, settings, useAuditBackup, adminUrl, flashText, noErrorText, setChecked } from './harness.mjs';
import { REPO_ROOT } from '../../lib/env.mjs';

useAuditBackup();
test.beforeEach(() => { settings.snapshot(); });
test.afterEach(() => { settings.restore(); });

const TPL = 'hadrian';
const str = v => [v, 'string'];
const ptr = (kind, who) => `${TPL}_active_layout_${kind}_${who}`;
const areaPtr = (kind, area) => `${TPL}_active_layout_${kind}_area_${area}`;
const LAYOUTS = (kind = 'main-menu') => adminUrl('layouts', { kind });
const THEME_DIR = path.join(REPO_ROOT, 'hadrian', 'templates', 'hadrian');

// An install that has never been in "by area" mode, with both visitor picks set.
const NEVER_BY_AREA = Object.fromEntries([
  `${TPL}_layout_mode`, `${TPL}_active_layout_main-menu`, `${TPL}_active_layout_footer`,
  ...['main-menu', 'footer'].flatMap(kind => ['website', 'client', 'order'].map(a => areaPtr(kind, a))),
].map(k => [k, null]));
const visitorPicks = (guest, client) => ({ ...NEVER_BY_AREA, [ptr('main-menu', 'guest')]: str(guest), [ptr('main-menu', 'client')]: str(client) });

const card = (page, kind, name) => page.locator(`[data-kind-panel="${kind}"] [data-lay-card="${name}"]`);

/** Do something that submits a form, and wait for the page that answers it. */
async function andWait(page, action) {
  await Promise.all([page.waitForNavigation({ waitUntil: 'domcontentloaded', timeout: 45_000 }), action()]);
}

/** Open a client page and return every attribute <body> carries. */
async function bodyOf(page, url) {
  await page.goto(url);
  return page.locator('body').evaluate(b => Object.fromEntries([...b.attributes].map(a => [a.name, a.value])));
}

// A flag toggle submits its form on change, so the page navigates while
// setChecked() reads the new state back; the state is checked after the reload.
const flip = (locator, on) => setChecked(locator, on).catch(() => null);

const json = v => { try { return v == null ? null : JSON.parse(v); } catch { return v; } };

// ------------------------------------------------------------ AD-35 modes

test('AD-35 By visitor and by area: switching back and forth loses nothing', async ({ admin, visit, proof }) => {
  proof.claim('The first switch to "Area" seeds each area from the visitor picks (guest for website and order, client for the client area); switching back and forth keeps both sets of picks.');
  settings.set(visitorPicks('top', 'rail'));
  const guest = await visit('guest');

  await admin.goto(LAYOUTS());
  await noErrorText(admin, proof, 'Layouts screen');
  proof.equal('by visitor, each card has two activation rows', await card(admin, 'main-menu', 'top').locator('[data-lay-row]').count(), 2);
  const before = db.settings(`${TPL}_active_layout_main-menu`);
  const modeBefore = db.setting(`${TPL}_layout_mode`);

  proof.step('Press "Area" in "Choose layouts by"');
  await andWait(admin, () => admin.locator('.mt-lay-mode-seg button[value="area"]').click());
  await proof.shot(admin, 'Layouts after switching to Area');
  const seeded = db.settings(`${TPL}_active_layout_main-menu`);
  proof.value('layout_mode', modeBefore, db.setting(`${TPL}_layout_mode`));
  proof.value('main-menu pointers', before, seeded);
  proof.equal('the mode is stored as "area"', db.setting(`${TPL}_layout_mode`), 'area');
  proof.equal('the website area starts from the guest pick', seeded[areaPtr('main-menu', 'website')], 'top');
  proof.equal('the order process starts from the guest pick', seeded[areaPtr('main-menu', 'order')], 'top');
  proof.equal('the client area starts from the client pick', seeded[areaPtr('main-menu', 'client')], 'rail');
  proof.check('the footer areas were seeded too', ['website', 'client', 'order'].every(a => !!db.setting(areaPtr('footer', a))),
    JSON.stringify(db.settings(`${TPL}_active_layout_footer_area`)));
  proof.equal('by area, each card has three activation rows', await card(admin, 'main-menu', 'top').locator('[data-lay-row]').count(), 3);
  proof.equal('a guest in the client area now gets the client-area pick', (await bodyOf(guest, '/submitticket.php'))['data-layout'], 'rail');

  proof.step('Activate Sidebar for the order process');
  await andWait(admin, () => card(admin, 'main-menu', 'sidebar').locator('button[data-lay-row="order"]').click());
  proof.equal('the order pick is stored as sidebar', db.setting(areaPtr('main-menu', 'order')), 'sidebar');
  const cart = await bodyOf(guest, '/cart.php?a=view');
  proof.equal('the cart draws the order pick', [cart['data-area'], cart['data-layout']], ['order', 'side']);

  proof.step('Press "Visitor"');
  await andWait(admin, () => admin.locator('.mt-lay-mode-seg button[value="audience"]').click());
  const back = db.settings(`${TPL}_active_layout_main-menu`);
  proof.value('main-menu pointers after going back to Visitor', seeded, back);
  proof.equal('the mode is stored as "audience"', db.setting(`${TPL}_layout_mode`), 'audience');
  proof.equal('the visitor picks are untouched', [back[ptr('main-menu', 'guest')], back[ptr('main-menu', 'client')]], ['top', 'rail']);
  proof.equal('the area picks are kept', back[areaPtr('main-menu', 'order')], 'sidebar');
  proof.equal('the cart is back on the guest pick', (await bodyOf(guest, '/cart.php?a=view'))['data-layout'], 'top');

  proof.step('Press "Area" again');
  await andWait(admin, () => admin.locator('.mt-lay-mode-seg button[value="area"]').click());
  proof.equal('the order pick made earlier survived (not re-seeded)', db.setting(areaPtr('main-menu', 'order')), 'sidebar');
  proof.check('the card shows Sidebar active for the order process', await card(admin, 'main-menu', 'sidebar').locator('.mt-lay-aud.is-on[data-lay-row="order"]').count() === 1);
  proof.equal('the cart draws it again', (await bodyOf(guest, '/cart.php?a=view'))['data-layout'], 'side');
  await proof.shot(guest, 'cart in area mode');
});

// ------------------------------------------------------ AD-36 activation

test('AD-36 Activate a layout for one audience', async ({ admin, visit, proof }) => {
  proof.claim('Activate stores the pick for that audience only, and the client area draws it for that audience.');
  settings.set(visitorPicks('sidebar', 'sidebar'));
  const guest = await visit('guest');
  const client = await visit('full');
  proof.equal('before: a guest gets the sidebar', (await bodyOf(guest, '/'))['data-layout'], 'side');

  await admin.goto(LAYOUTS());
  const before = [db.setting(ptr('main-menu', 'guest')), db.setting(ptr('main-menu', 'client'))];
  proof.step('Press Activate on the "Guest client" row of Top Navigation');
  await andWait(admin, () => card(admin, 'main-menu', 'top').locator('button[data-lay-row="guest"]').click());
  await proof.shot(card(admin, 'main-menu', 'top'), 'Top Navigation card after Activate');
  const after = [db.setting(ptr('main-menu', 'guest')), db.setting(ptr('main-menu', 'client'))];
  proof.value('guest, client pointers', before, after);
  proof.equal('only the guest pointer changed', after, ['top', 'sidebar']);
  proof.check('the card now marks Guest client active', await card(admin, 'main-menu', 'top').locator('.mt-lay-aud.is-on[data-lay-row="guest"]').count() === 1);
  proof.equal('a guest now gets the top navigation', (await bodyOf(guest, '/'))['data-layout'], 'top');
  await proof.shot(guest, 'guest homepage on top navigation');
  proof.equal('a signed-in client still gets the sidebar', (await bodyOf(client, '/clientarea.php'))['data-layout'], 'side');

  proof.step('Press Activate on the "Existing client" row of Topbar Minimal (a custom folder with its own stylesheet)');
  await andWait(admin, () => card(admin, 'main-menu', 'topbar-minimal').locator('button[data-lay-row="client"]').click());
  proof.equal('the client pointer is topbar-minimal', db.setting(ptr('main-menu', 'client')), 'topbar-minimal');
  const cb = await bodyOf(client, '/clientarea.php');
  proof.equal('the client area draws topbar-minimal', cb['data-layout'], 'topbar-minimal');
  const css = await client.locator('link[rel="stylesheet"][href*="core/layouts/main-menu/topbar-minimal/layout.css"]').count();
  proof.equal('the client page links core/layouts/main-menu/topbar-minimal/layout.css', css, 1);
  await guest.goto('/');
  proof.equal('the guest page does not link it', await guest.locator('link[href*="topbar-minimal/layout.css"]').count(), 0);
  await proof.shot(client, 'client dashboard on topbar-minimal');
});

test('AD-36 An unknown audience mirrors to the legacy key and both audience keys', async ({ admin, visit, proof }) => {
  proof.claim('A post naming no known audience (an old cached screen) writes the legacy pointer and both audience pointers.');
  settings.set(visitorPicks('sidebar', 'sidebar'));
  await admin.goto(LAYOUTS());
  const form = card(admin, 'main-menu', 'rail').locator('form:has(button[data-lay-row="guest"])');
  proof.step('Change the Icon Rail guest form\'s audience field to "everyone" in the page, then press Activate');
  await form.locator('input[name="audience"]').evaluate(i => { i.value = 'everyone'; });
  const before = db.settings(`${TPL}_active_layout_main-menu`);
  await andWait(admin, () => form.locator('button').click());
  const after = db.settings(`${TPL}_active_layout_main-menu`);
  proof.value('main-menu pointers', before, after);
  proof.equal('the legacy pointer is rail', after[`${TPL}_active_layout_main-menu`], 'rail');
  proof.equal('both audience pointers are rail', [after[ptr('main-menu', 'guest')], after[ptr('main-menu', 'client')]], ['rail', 'rail']);
  const guest = await visit('guest');
  proof.equal('a guest gets the rail', (await bodyOf(guest, '/'))['data-layout'], 'rail');
});

test('AD-36 An unknown layout is not stored', async ({ admin, proof }) => {
  proof.claim('Activate only accepts a layout that exists for the kind.');
  settings.set(visitorPicks('sidebar', 'sidebar'));
  await admin.goto(LAYOUTS());
  const form = card(admin, 'main-menu', 'top').locator('form:has(button[data-lay-row="guest"])');
  proof.step('Change the Top Navigation guest form\'s layout field to "no-such-layout", then press Activate');
  await form.locator('input[name="layout"]').evaluate(i => { i.value = 'no-such-layout'; });
  await andWait(admin, () => form.locator('button').click());
  proof.value('guest pointer', 'sidebar', db.setting(ptr('main-menu', 'guest')));
  proof.equal('the guest pointer is still sidebar', db.setting(ptr('main-menu', 'guest')), 'sidebar');
  await noErrorText(admin, proof, 'Layouts screen after the bad post');
});

// ---------------------------------------------------- AD-37 layout options

test('AD-37 Per-layout options are stored and reach the page', async ({ admin, visit, proof }) => {
  proof.claim('Each option segment on an active card stores its choice in <tpl>_layout_opts_<kind>_<layout>, and header.tpl turns it into a body attribute.');
  settings.set({ ...visitorPicks('sidebar', 'sidebar'), [`${TPL}_layout_opts_main-menu_sidebar`]: null });
  const guest = await visit('guest');
  const b0 = await bodyOf(guest, '/');
  proof.check('before: no data-sidebar-side, data-align or data-nav-profile', !b0['data-sidebar-side'] && !b0['data-align'] && !b0['data-nav-profile'], JSON.stringify(b0));

  await admin.goto(LAYOUTS());
  const seg = opt => card(admin, 'main-menu', 'sidebar').locator(`form.mt-seg:has(input[name="option"][value="${opt}"])`);
  const key = `${TPL}_layout_opts_main-menu_sidebar`;
  const steps = [['side', 'right', 'data-sidebar-side'], ['align', 'left', 'data-align'], ['profile', 'hide', 'data-nav-profile']];
  let stored = db.setting(key);
  for (const [opt, value, attr] of steps) {
    proof.step(`Press "${value}" in the Sidebar card's ${opt} option`);
    await andWait(admin, () => seg(opt).locator(`button[value="${value}"]`).click());
    const now = db.setting(key);
    proof.value(key, json(stored), json(now));
    proof.equal(`${opt} is stored as "${value}"`, json(now)?.[opt], value);
    proof.check(`the ${opt} segment shows "${value}" selected`, await seg(opt).locator(`button.on[value="${value}"]`).count() === 1);
    proof.equal(`the page carries ${attr}="${value}"`, (await bodyOf(guest, '/'))[attr], value);
    stored = now;
  }
  await proof.shot(card(admin, 'main-menu', 'sidebar'), 'Sidebar card options');
  await proof.shot(guest, 'guest page, sidebar on the right');
});

test('AD-37 An option value not in the declared choices is rejected', async ({ admin, proof }) => {
  proof.claim('saveLayoutOption ignores a value that is not one of the option\'s declared choices, and an option the layout does not declare.');
  settings.set({ ...visitorPicks('sidebar', 'sidebar'), [`${TPL}_layout_opts_main-menu_sidebar`]: [JSON.stringify({ side: 'left' }), 'json'] });
  const key = `${TPL}_layout_opts_main-menu_sidebar`;
  await admin.goto(LAYOUTS());
  const seg = card(admin, 'main-menu', 'sidebar').locator('form.mt-seg:has(input[name="option"][value="side"])');
  proof.step('Change the "Right" button\'s value to "diagonal" in the page and press it');
  await seg.locator('button[value="right"]').evaluate(b => { b.value = 'diagonal'; });
  await andWait(admin, () => seg.locator('button[value="diagonal"]').click());
  proof.value(key, { side: 'left' }, json(db.setting(key)));
  proof.equal('side is still "left"', json(db.setting(key)), { side: 'left' });

  proof.step('Change the option field to "evil" (an option the layout does not declare) and press "Left"');
  await admin.goto(LAYOUTS());
  // Hold the button first: renaming the hidden field changes its value
  // attribute, so the locator above stops matching the form.
  const left = await seg.locator('button[value="left"]').elementHandle();
  await seg.locator('input[name="option"]').evaluate(i => { i.value = 'evil'; });
  await andWait(admin, () => left.click());
  proof.equal('no "evil" key was written', json(db.setting(key)), { side: 'left' });
});

// ---------------------------------------------------- AD-38 header/footer flags

/** Where each flag shows on the client area. effect() returns a plain object; on/off are what it should be. */
const FLAGS = {
  hide_breadcrumb: {
    kind: 'main-menu', persona: 'full', url: '/clientarea.php?action=services',
    effect: async p => ({
      attr: await p.locator('body').getAttribute('data-hide-breadcrumb'),
      crumbsVisible: await p.locator('.ph-side-crumbs, .ph-breadcrumb').evaluateAll(els => els.some(e => getComputedStyle(e).display !== 'none' && e.getClientRects().length > 0)),
    }),
    off: { attr: null, crumbsVisible: true }, on: { attr: '1', crumbsVisible: false },
  },
  affixed_navigation: {
    kind: 'main-menu', persona: 'guest', url: '/', layout: 'top',
    effect: async p => {
      const attr = await p.locator('body').getAttribute('data-affixed-nav');
      // core-layout.js only tracks scroll direction when the attribute is on.
      for (const y of [200, 500, 900, 1300]) { await p.evaluate(v => window.scrollTo(0, v), y); await p.waitForTimeout(120); }
      await p.waitForTimeout(400);
      return { attr, scrollDownClass: await p.locator('body').evaluate(b => b.classList.contains('scroll-down')) };
    },
    off: { attr: null, scrollDownClass: false }, on: { attr: '1', scrollDownClass: true },
    note: 'core-layout.js initAffixedNav() looks for ".topbar, .ph-side-topbar" and core-layout.css hides ".topbar"; the Top Navigation bar is nav.homepage-nav (includes/partials/topnav.tpl) and no template renders a .topbar, so on the Top layout the script returns before listening.',
  },
  unpin_sidebar: {
    kind: 'main-menu', persona: 'guest', url: '/knowledgebase',
    effect: async p => ({
      attr: await p.locator('body').getAttribute('data-unpin-sidebar'),
      position: await p.locator('aside.sidebar').first().evaluate(e => getComputedStyle(e).position),
    }),
    off: { attr: null, position: 'fixed' }, on: { attr: '1', position: 'absolute' },
  },
  hide_language_switcher: {
    kind: 'main-menu', persona: 'guest', url: '/contact.php',
    effect: async p => ({ languageButtons: (await p.locator('[data-lang]').count()) > 0 }),
    off: { languageButtons: true }, on: { languageButtons: false },
  },
  hide_currency_selector: {
    kind: 'main-menu', persona: 'guest', url: '/contact.php',
    effect: async p => ({ currencyButtons: (await p.locator('[data-currency]').count()) > 0 }),
    off: { currencyButtons: true }, on: { currencyButtons: false },
  },
  hide_footer_socials: {
    kind: 'footer', persona: 'guest', url: '/',
    pre: { [ptr('footer', 'guest')]: str('extended-info'), footer_social_x: str('https://x.com/hadrian-audit') },
    effect: async p => ({ socials: await p.locator('.hp-footer-socials').count() }),
    off: { socials: 1 }, on: { socials: 0 },
  },
  back_to_top: {
    kind: 'footer', persona: 'guest', url: '/',
    effect: async p => ({ button: await p.locator('#mtBackToTop').count() }),
    off: { button: 0 }, on: { button: 1 },
  },
};

for (const [key, f] of Object.entries(FLAGS)) {
  test(`AD-38 Layouts flag "${key}" saves and changes the client area`, async ({ admin, visit, proof }) => {
    proof.claim(`The ${key} toggle on Layouts > ${f.kind === 'footer' ? 'Footer options' : 'Header'} stores 1 or 0, redirects back to the ${f.kind} tab, and the client area follows it.`);
    if (f.note) proof.note(f.note);
    const layout = f.layout || 'sidebar';
    settings.set({ ...visitorPicks(layout, layout), ...(f.pre || {}), [key]: ['0', 'bool'] });
    const client = await visit(f.persona);
    await client.goto(f.url);
    const effOff = await f.effect(client);
    proof.equal(`with ${key} off, on ${f.url}`, effOff, f.off);

    await admin.goto(LAYOUTS(f.kind));
    const form = admin.locator(`form.mt-flag-form:has(input[name="layout_flag"][value="${key}"])`);
    const box = form.locator('input[data-flag-toggle]');
    proof.check(`Layouts shows the ${key} toggle off`, (await box.count()) === 1 && !(await box.isChecked()));
    const before = db.setting(key);

    proof.step(`Switch ${key} on`);
    await andWait(admin, () => flip(box, true));
    const flash = await flashText(admin);
    await proof.shot(admin, `Layouts after switching ${key} on`);
    const on = db.setting(key);
    proof.value(key, before, on);
    proof.equal('stored as "1"', on, '1');
    proof.check(`redirected back to the ${f.kind} tab`, new RegExp(`kind=${f.kind}(&|$)`).test(admin.url()) && /flag=1/.test(admin.url()), admin.url());
    proof.check('the screen confirms the save', /saved/i.test(flash), `flash: ${flash}`);
    proof.check('the toggle is on after the reload', await admin.locator(`form.mt-flag-form:has(input[name="layout_flag"][value="${key}"]) input[data-flag-toggle]`).isChecked());

    await client.goto(f.url);
    proof.equal(`with ${key} on, on ${f.url}`, await f.effect(client), f.on);
    await proof.shot(client, `client area with ${key} on`);

    proof.step(`Switch ${key} off again`);
    await andWait(admin, () => flip(admin.locator(`form.mt-flag-form:has(input[name="layout_flag"][value="${key}"]) input[data-flag-toggle]`), false));
    proof.value(`${key} (second save)`, on, db.setting(key));
    proof.equal('stored as "0"', db.setting(key), '0');
    await client.goto(f.url);
    proof.equal(`with ${key} off again, on ${f.url}`, await f.effect(client), f.off);
  });
}

test('AD-38 Layouts flag form only accepts layout flags', async ({ admin, proof }) => {
  proof.claim('saveFlagAction writes only keys listed in SettingsController::LAYOUT_FLAGS; any other Settings flag named in the post is ignored.');
  settings.set({ free_label: ['0', 'bool'] });
  await admin.goto(LAYOUTS());
  const f = admin.locator('form.mt-flag-form:has(input[name="layout_flag"])').first();
  proof.step('Change the first flag form\'s layout_flag field to "free_label" and value to 1, then switch the toggle');
  await f.locator('input[name="layout_flag"]').evaluate(i => { i.value = 'free_label'; });
  await f.locator('input[name="value"]').evaluate(i => { i.value = '1'; });
  await andWait(admin, () => flip(f.locator('input[data-flag-toggle]'), true));
  proof.value('free_label', '0', db.setting('free_label'));
  proof.equal('free_label is still "0"', db.setting('free_label'), '0');
});

// --------------------------------------------------- AD-39 content width

test('AD-39 Content width: full and boxed, and a stored "fluid" reads as full', async ({ admin, visit, proof }) => {
  proof.claim('The Content width select stores boxed or full; full puts data-content-width="full" on <body> (no max width); boxed emits nothing; an old "fluid" shows as Full width.');
  settings.set({ content_width: str('boxed'), [`${TPL}_layout_vars`]: null });
  const guest = await visit('guest');
  const widthOf = async () => {
    const b = await bodyOf(guest, '/knowledgebase');
    return { attr: b['data-content-width'] ?? null, maxWidth: (await guest.locator('body').evaluate(e => getComputedStyle(e).getPropertyValue('--content-max-width').trim())) };
  };
  const w0 = await widthOf();
  proof.equal('boxed: no data-content-width attribute', w0.attr, null);
  proof.check('boxed: --content-max-width is a px value', /px$/.test(w0.maxWidth), w0.maxWidth);

  await admin.goto(LAYOUTS());
  const sel = admin.locator('select[name="content_width"]');
  proof.step('Pick "Full width" in Containers > Content width');
  await andWait(admin, () => sel.selectOption('full'));
  await proof.shot(admin.locator('select[name="content_width"]').locator('xpath=ancestor::*[contains(@class,"mt-row")][1]'), 'Content width row');
  proof.value('content_width', 'boxed', db.setting('content_width'));
  proof.equal('stored as "full"', db.setting('content_width'), 'full');
  const w1 = await widthOf();
  proof.equal('full: body carries data-content-width="full" and no max width', w1, { attr: 'full', maxWidth: 'none' });
  await proof.shot(guest, 'knowledgebase at full width');

  proof.step('Pick "Boxed" again');
  await andWait(admin, () => admin.locator('select[name="content_width"]').selectOption('boxed'));
  proof.equal('stored as "boxed"', db.setting('content_width'), 'boxed');
  proof.equal('boxed again: the attribute is gone', (await widthOf()).attr, null);

  proof.step('Store the retired "fluid" value and open the screen');
  settings.set({ content_width: str('fluid') });
  await admin.goto(LAYOUTS());
  proof.equal('the select shows Full width for a stored "fluid"', await admin.locator('select[name="content_width"]').inputValue(), 'full');
  const wf = await widthOf();
  proof.equal('the page treats "fluid" as full width', wf, { attr: 'fluid', maxWidth: 'none' });

  proof.step('Add a "giant" option to the select in the page and pick it');
  settings.set({ content_width: str('boxed') });
  await admin.goto(LAYOUTS());
  await admin.locator('select[name="content_width"]').evaluate(s => { const o = document.createElement('option'); o.value = 'giant'; o.textContent = 'giant'; s.appendChild(o); });
  await andWait(admin, () => admin.locator('select[name="content_width"]').selectOption('giant'));
  proof.equal('an unknown width is not stored', db.setting('content_width'), 'boxed');
});

// ------------------------------------------- AD-40 max width and side padding

test('AD-40 Maximum width and side padding merge into _layout_vars and reach the page', async ({ admin, visit, proof }) => {
  proof.claim('Apply on Maximum width and on Side padding each merge their value into <tpl>_layout_vars; the default removes it; the page gets :root{--content-max-width:..;--content-pad-x:..}.');
  const key = `${TPL}_layout_vars`;
  settings.set({ content_width: str('boxed'), [key]: null });
  const guest = await visit('guest');
  const styleOf = async () => { await guest.goto('/knowledgebase'); return guest.locator('style#hadrian-layout').evaluateAll(s => s.map(e => e.textContent).join('')); };
  proof.equal('no hadrian-layout <style> before', await styleOf(), '');

  const apply = async (field, value, { unbound = false } = {}) => {
    await admin.goto(LAYOUTS());
    const input = admin.locator(`input[name="${field}"]`);
    if (unbound) await input.evaluate(i => { i.removeAttribute('min'); i.removeAttribute('max'); i.removeAttribute('step'); });
    await input.fill(String(value));
    await andWait(admin, () => input.locator('xpath=ancestor::form[1]').locator('button[type="submit"]').click());
  };

  proof.step('Type 1400 in Maximum width and press Apply');
  await apply('content_max_width', 1400);
  let v = json(db.setting(key));
  proof.value(key, null, v);
  proof.equal('stored --content-max-width = 1400', v, { '--content-max-width': 1400 });
  proof.check('the page emits --content-max-width:1400px', (await styleOf()).includes('--content-max-width:1400px'), await styleOf());
  proof.equal('the screen shows 1400', await (await admin.goto(LAYOUTS()), admin.locator('input[name="content_max_width"]')).inputValue(), '1400');

  proof.step('Type 24 in Side padding and press Apply');
  await apply('content_pad_x', 24);
  const merged = json(db.setting(key));
  proof.value(key, v, merged);
  proof.equal('both values are kept (merge, not replace)', merged, { '--content-max-width': 1400, '--content-pad-x': 24 });
  const css = await styleOf();
  proof.check('the page emits both', css.includes('--content-max-width:1400px') && css.includes('--content-pad-x:24px'), css);
  await proof.shot(admin, 'Containers after two Applies');

  proof.step('Type the default, 1120, in Maximum width and press Apply');
  await apply('content_max_width', 1120);
  proof.equal('the default removes the max-width entry', json(db.setting(key)), { '--content-pad-x': 24 });
  proof.check('the page no longer sets --content-max-width', !(await styleOf()).includes('--content-max-width'));

  // Out-of-range values: the form says 640-2400 (max width) and 0-160 (padding);
  // the server checks core/config/layout.php's sizeMin/sizeMax (0-4000).
  proof.step('Remove the input\'s min/max in the page, type 3000 (above the form\'s 2400) and press Apply');
  await apply('content_max_width', 3000, { unbound: true });
  const v3000 = json(db.setting(key));
  proof.value(key + ' after 3000', { '--content-pad-x': 24 }, v3000);
  proof.equal('the server stores 3000: its bound is 4000, not the form\'s 2400', v3000?.['--content-max-width'], 3000);
  proof.check('and the page emits --content-max-width:3000px', (await styleOf()).includes('--content-max-width:3000px'));

  proof.step('Type 5000 (above the server\'s 4000) and press Apply');
  await apply('content_max_width', 5000, { unbound: true });
  proof.equal('out of range removes the entry', json(db.setting(key))?.['--content-max-width'], undefined);

  proof.step('Type 200 in Side padding (above the form\'s 160) and press Apply');
  await apply('content_pad_x', 200, { unbound: true });
  proof.equal('the server stores 200 padding', json(db.setting(key))?.['--content-pad-x'], 200);
  proof.check('and the page emits --content-pad-x:200px', (await styleOf()).includes('--content-pad-x:200px'));

  proof.step('Type -8 in Side padding and press Apply');
  await apply('content_pad_x', -8, { unbound: true });
  proof.equal('a negative value removes the entry', json(db.setting(key)), []);
  proof.note('The server bound is core/config/layout.php sizeMin 0 / sizeMax 4000 for both fields. The HTML min/max (640-2400, 0-160) is only a browser hint: a post outside it is stored and emitted.');
});

// --------------------------------------------------- AD-41 custom folders

test('AD-41 Custom layout folders are found, bad ones rejected with a reason', async ({ admin, visit, proof }) => {
  proof.claim('A folder dropped in core/layouts/main-menu/ appears as a card with a "Custom" badge; a broken one is listed with the reason it was rejected; reserved dataLayout tokens are blocked.');
  const root = path.join(THEME_DIR, 'core', 'layouts', 'main-menu');
  const made = {
    'audit-good': { 'layout.php': "<?php return ['displayName' => 'Audit Good', 'description' => 'Audit layout.', 'variables' => ['dataLayout' => 'audit-good']];\n", 'default.tpl': '<nav class="audit-good-nav" data-audit-good>Audit layout</nav>\n' },
    'audit-nomanifest': { 'default.tpl': '<nav></nav>\n' },
    'audit-notpl': { 'layout.php': "<?php return ['displayName' => 'X', 'variables' => ['dataLayout' => 'audit-notpl']];\n" },
    'audit-reserved': { 'layout.php': "<?php return ['displayName' => 'X', 'variables' => ['dataLayout' => 'side']];\n", 'default.tpl': '<nav></nav>\n' },
    'audit-badtoken': { 'layout.php': "<?php return ['displayName' => 'X', 'variables' => ['dataLayout' => 'Bad Token']];\n", 'default.tpl': '<nav></nav>\n' },
    'audit-notoken': { 'layout.php': "<?php return ['displayName' => 'X'];\n", 'default.tpl': '<nav></nav>\n' },
    'Audit_Bad': { 'layout.php': "<?php return ['displayName' => 'X', 'variables' => ['dataLayout' => 'audit-bad']];\n", 'default.tpl': '<nav></nav>\n' },
  };
  settings.set(visitorPicks('sidebar', 'sidebar'));
  try {
    for (const [dir, files] of Object.entries(made)) {
      fs.mkdirSync(path.join(root, dir), { recursive: true });
      for (const [f, body] of Object.entries(files)) fs.writeFileSync(path.join(root, dir, f), body);
    }
    proof.step('Drop seven folders into core/layouts/main-menu/ and open Layouts');
    await admin.goto(LAYOUTS());
    await noErrorText(admin, proof, 'Layouts screen');
    const warn = await admin.locator('.mt-alert-warning').innerText().catch(() => '');
    await proof.shot(admin.locator('.mt-alert-warning'), 'rejected folders notice');
    const reasons = {
      'audit-nomanifest': /No layout\.php/, 'audit-notpl': /No default\.tpl/, 'audit-reserved': /reserved/,
      'audit-badtoken': /must match/, 'audit-notoken': /must declare variables\.dataLayout/, 'Audit_Bad': /lowercase/,
    };
    for (const [dir, re] of Object.entries(reasons)) {
      const line = warn.split('\n').find(l => l.includes(`/${dir}/`)) || '';
      proof.check(`"${dir}" is listed with its reason`, re.test(line), line || warn.slice(0, 300));
    }
    proof.check('the good folder is not in the notice', !warn.includes('/audit-good/'));
    const good = card(admin, 'main-menu', 'audit-good');
    proof.equal('the good folder is a card', await good.count(), 1);
    proof.check('it wears the "Custom" badge', (await good.locator('.mt-badge', { hasText: 'Custom' }).count()) === 1);
    proof.check('a shipped layout does not', (await card(admin, 'main-menu', 'sidebar').locator('.mt-badge', { hasText: 'Custom' }).count()) === 0);
    proof.check('the rejected folders are not cards', (await admin.locator('[data-lay-card="audit-reserved"], [data-lay-card="audit-notpl"]').count()) === 0);
    await proof.shot(good, 'the Audit Good card');

    proof.step('Activate Audit Good for guests');
    await andWait(admin, () => card(admin, 'main-menu', 'audit-good').locator('button[data-lay-row="guest"]').click());
    proof.equal('the guest pointer is audit-good', db.setting(ptr('main-menu', 'guest')), 'audit-good');
    const guest = await visit('guest');
    const b = await bodyOf(guest, '/');
    proof.equal('a guest gets body[data-layout="audit-good"]', b['data-layout'], 'audit-good');
    proof.equal('and the folder\'s own default.tpl is drawn', await guest.locator('[data-audit-good]').count(), 1);
    await proof.shot(guest, 'guest homepage on the dropped-in layout');
  } finally {
    for (const dir of Object.keys(made)) fs.rmSync(path.join(root, dir), { recursive: true, force: true });
    settings.set(visitorPicks('sidebar', 'sidebar'));
    await admin.goto(LAYOUTS()).catch(() => {});   // rescan, so the cache forgets the folders
  }
  proof.check('after the folders are removed the card is gone', (await card(admin, 'main-menu', 'audit-good').count()) === 0);
});

// --------------------------------------------------- AD-42 live preview

test('AD-42 Live preview links open the client area with that layout, without activating it', async ({ admin, visit, proof }) => {
  proof.claim('Each main-menu card links to ?preview=1&layout=<dataLayout>; the link renders that layout and stores nothing. Footer cards have no link.');
  settings.set(visitorPicks('sidebar', 'sidebar'));
  await admin.goto(LAYOUTS());
  const expect = { sidebar: 'side', top: 'top', rail: 'rail', 'topbar-minimal': 'topbar-minimal' };
  for (const [name, token] of Object.entries(expect)) {
    const href = await card(admin, 'main-menu', name).locator('a.mt-lay-preview-btn').getAttribute('href');
    proof.check(`${name}: the link is /?preview=1&layout=${token}`, /\/\?preview=1&layout=/.test(href || '') && href.endsWith(`layout=${encodeURIComponent(token)}`), href);
  }
  proof.equal('footer cards have no preview link', await admin.locator('[data-kind-panel="footer"] a.mt-lay-preview-btn').count(), 0);
  await proof.shot(card(admin, 'main-menu', 'top'), 'Top Navigation card with its preview link');

  proof.step('Press "Live preview" on the Top Navigation card');
  const [popup] = await Promise.all([
    admin.context().waitForEvent('page'),
    card(admin, 'main-menu', 'top').locator('a.mt-lay-preview-btn').click(),
  ]);
  await popup.waitForLoadState('domcontentloaded');
  proof.check('it opened in a new tab on the client area', /[?&]preview=1/.test(popup.url()), popup.url());
  proof.equal('the preview renders the top layout', await popup.locator('body').getAttribute('data-layout'), 'top');
  await proof.shot(popup, 'preview tab');

  const guest = await visit('guest');
  const href = await card(admin, 'main-menu', 'rail').locator('a.mt-lay-preview-btn').getAttribute('href');
  proof.equal('a guest opening the rail link gets the rail', (await bodyOf(guest, href))['data-layout'], 'rail');
  proof.equal('the stored picks did not change', [db.setting(ptr('main-menu', 'guest')), db.setting(ptr('main-menu', 'client'))], ['sidebar', 'sidebar']);
  proof.equal('without ?preview a guest still gets the sidebar', (await bodyOf(guest, '/'))['data-layout'], 'side');
});
