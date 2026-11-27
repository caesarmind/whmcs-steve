// AD-B Settings screen (tests/FEATURES.md AD-11 to AD-19, AD-91, AD-93): each
// control changed through Addons > Hadrian > Settings, then proven in the
// database and on the client area.

import { test, expect, db, settings, useAuditBackup, adminUrl, submit, flashText, noErrorText, setChecked } from './harness.mjs';
import { BASE_URL } from '../../lib/env.mjs';
import { fx } from '../helpers.mjs';

useAuditBackup();
test.beforeEach(() => { settings.snapshot(); });
test.afterEach(() => { settings.restore(); });

const SAVE = '.mt-savebar button[type="submit"]';
const id = fx.ids;

test('AD-11 Save turns a General flag on and off ("0.00 -> Free")', async ({ admin, visit, proof }) => {
  proof.claim('Every flag on the General tab is stored as 1 or 0 from whether its box was ticked, and the client area follows it.');
  settings.set({ free_label: ['0', 'bool'] });

  const guest = await visit('guest');
  await guest.goto('/cart.php');
  const before = await guest.locator('body').getAttribute('data-free-label');
  proof.check('with the flag off, the order form carries no data-free-label', before === null, `data-free-label=${before}`);

  await admin.goto(adminUrl('settings'));
  await noErrorText(admin, proof, 'Settings screen');
  const box = admin.locator('input[type="checkbox"][name="free_label"]');
  proof.check('Settings shows the "0.00 -> Free" box unticked', !(await box.isChecked()));
  const storedBefore = db.setting('free_label');

  proof.step('Tick "0.00 -> Free" on Settings > General and press Save changes');
  await setChecked(box, true);
  await proof.shot(admin.locator('input[name="free_label"]').locator('xpath=ancestor::*[contains(@class,"mt-row")][1]'), 'the ticked row');
  await submit(admin, SAVE);
  const flash = await flashText(admin);
  await proof.shot(admin, 'Settings after Save');
  const storedOn = db.setting('free_label');
  proof.value('free_label', storedBefore, storedOn);
  proof.equal('Save stored the flag as "1"', storedOn, '1');
  proof.check('the screen confirms the save', /saved/i.test(flash) || (await box.isChecked()), `flash: ${flash}`);
  proof.check('the box is ticked when the screen reloads', await admin.locator('input[name="free_label"]').isChecked());

  await guest.goto('/cart.php');
  const after = await guest.locator('body').getAttribute('data-free-label');
  proof.equal('the order form now carries data-free-label="1"', after, '1');
  await proof.shot(guest, 'order form after the flag went on');

  proof.step('Untick it again and press Save changes');
  await setChecked(admin.locator('input[name="free_label"]'), false);
  await submit(admin, SAVE);
  const storedOff = db.setting('free_label');
  proof.value('free_label (second save)', storedOn, storedOff);
  proof.equal('Save stored the flag as "0"', storedOff, '0');
  await guest.goto('/cart.php');
  proof.check('the order form no longer carries data-free-label', (await guest.locator('body').getAttribute('data-free-label')) === null);
  proof.limit('This proves the flag reaches the page. Whether the cart prints "Free" for a 0.00 price is OF-coverage (order.spec).');
});

test('AD-11 Saving Settings leaves the Layouts-page flags alone', async ({ admin, proof }) => {
  proof.claim('Flags that live on the Layouts screen (Hide Breadcrumb and six more) are skipped by the Settings save, so it never writes 0 over them.');
  settings.set({ hide_breadcrumb: ['1', 'bool'], back_to_top: ['1', 'bool'] });
  const before = { hide_breadcrumb: db.setting('hide_breadcrumb'), back_to_top: db.setting('back_to_top') };

  await admin.goto(adminUrl('settings'));
  proof.check('Hide Breadcrumb is not on the Settings form', (await admin.locator('input[name="hide_breadcrumb"]').count()) === 0);
  proof.step('Press Save changes on Settings > General without touching anything');
  await submit(admin, SAVE);
  const after = { hide_breadcrumb: db.setting('hide_breadcrumb'), back_to_top: db.setting('back_to_top') };
  proof.value('hide_breadcrumb, back_to_top', before, after);
  proof.equal('both Layouts flags are still "1"', after, { hide_breadcrumb: '1', back_to_top: '1' });
});

// ------------------------------------------------------------------ helpers

const bodyAttr = (page, name) => page.evaluate(n => document.body.getAttribute(n), name);
const htmlAttr = (page, name) => page.evaluate(n => document.documentElement.getAttribute(n), name);
/** The nearest .mt-row (not .mt-row-sub / .mt-row-label) around a control. */
const rowOf = loc => loc.locator('xpath=ancestor::*[contains(concat(" ", normalize-space(@class), " "), " mt-row ")][1]');
const jsonSetting = key => { const v = db.setting(key); try { return JSON.parse(v); } catch { return v; } };

function expectState(proof, label, actual, expected) {
  if (typeof expected === 'function') proof.check(label, expected(actual), `saw ${JSON.stringify(actual)}`);
  else proof.equal(label, actual, expected);
}

/** Tick or untick one flag on the Settings screen, press Save, prove the stored value. */
async function saveFlag(admin, proof, key, on, { tab = 'general' } = {}) {
  await admin.goto(adminUrl('settings', { tab }));
  const box = admin.locator(`input[type="checkbox"][name="${key}"]`);
  const label = ((await rowOf(box).locator('.mt-row-label').first().innerText()).split('\n')[0] || key).trim();
  const before = db.setting(key);
  proof.step(`${on ? 'Tick' : 'Untick'} "${label}" on Settings > ${tab === 'order' ? 'Order Process' : 'General'} and press Save changes`);
  await setChecked(box, on);
  await submit(admin, SAVE);
  const after = db.setting(key);
  proof.value(key, before, after);
  proof.equal(`Save stored ${key} as "${on ? 1 : 0}"`, after, on ? '1' : '0');
  proof.check(`the "${label}" box is ${on ? 'ticked' : 'unticked'} when the screen reloads`,
    (await admin.locator(`input[type="checkbox"][name="${key}"]`).isChecked()) === on);
  return after;
}

/** Add extra fields to a form container, the way a stale or tampered form would post them. */
async function inject(container, fields) {
  await container.evaluate((el, list) => {
    for (const [tag, name, value] of list) {
      const n = document.createElement(tag === 'textarea' ? 'textarea' : 'input');
      if (tag === 'checkbox') { n.type = 'checkbox'; n.checked = true; } else if (tag !== 'textarea') n.type = 'hidden';
      n.name = name; n.value = value;
      n.setAttribute('data-audit-injected', '1');
      el.appendChild(n);
    }
  }, fields);
}

/** Add an option to a <select> and select it, so the form posts a value the control never offers. */
async function forceOption(select, value) {
  await select.evaluate((s, v) => { const o = document.createElement('option'); o.value = v; o.textContent = v; s.appendChild(o); s.value = v; }, value);
}

/** Pick an option in a [data-chip-picker] widget through its own dropdown. */
async function pickChip(wrap, code) {
  await wrap.locator('.mt-multi').click();
  await wrap.locator(`.mt-multi-option[data-code="${code}"]`).click();
  await wrap.page().keyboard.press('Escape');
}

async function localeItems(page) {
  await page.locator('[data-locale-open]:visible').first().click();
  await page.locator('#localeModal .locale-modal-panel').waitFor({ state: 'visible' });
  const items = page.locator('#localeModal .locale-modal-body [data-lang], #localeModal .locale-modal-body a[href*="language="], #localeModal .locale-modal-body button[value]');
  return (await items.allInnerTexts()).map(t => t.trim()).filter(Boolean);
}

const confUrl = `/cart.php?a=add&pid=${id.serverProductId}`;
async function reachConfigure(page) {
  await page.goto(confUrl);
  if (!/a=confproduct/.test(page.url())) await page.waitForURL(/a=confproduct/);
}

// ---------------------------------------------------- AD-11 every flag alone
//
// Each entry: the flag, the state the test starts from (set directly, as the
// precondition), where its effect shows, how to read it, and what it must read
// with the flag on and off. The test then switches it through the screen and
// back, proving the stored value and the effect at each step.

const FLAG_TESTS = [
  {
    key: 'cookie_box', label: 'Cookie Box', start: '0', persona: 'guest', url: '/',
    claim: 'Ticking Cookie Box draws the consent bar for first-time visitors; unticking removes it.',
    read: async p => {
      const inPage = await p.locator('#mtCookieBar').count();
      const shown = inPage ? await p.locator('#mtCookieBar').waitFor({ state: 'visible', timeout: 6000 }).then(() => true, () => false) : false;
      return { inPage, shown };
    },
    on: { inPage: 1, shown: true }, onSays: 'the home page draws the cookie bar and shows it after its delay',
    off: { inPage: 0, shown: false }, offSays: 'the home page has no cookie bar',
  },
  {
    key: 'enable_alternate_links', label: 'Enable Alternate Links', start: '1', persona: 'guest', url: '/',
    claim: 'Enable Alternate Links puts one <link rel="alternate" hreflang> per language in the head; off, there are none.',
    read: p => p.locator('head link[rel="alternate"][hreflang]').count(),
    on: n => n > 1, onSays: 'the head carries hreflang alternate links',
    off: 0, offSays: 'the head carries no hreflang alternate links',
  },
  {
    key: 'capitalize_titles', label: 'Section Titles Capitalization', start: '1', persona: 'guest', url: '/',
    claim: 'Section Titles Capitalization uppercases the homepage eyebrows; off sets body[data-capitalize-titles="0"] and they keep their own case.',
    read: async p => ({
      attr: await bodyAttr(p, 'data-capitalize-titles'),
      upper: (await p.evaluate(() => [...document.querySelectorAll('.content-area *')]
        .filter(e => e.children.length === 0 && e.textContent.trim() && getComputedStyle(e).textTransform === 'uppercase').length)) > 0,
    }),
    on: { attr: null, upper: true }, onSays: 'the homepage has uppercase section labels and no data-capitalize-titles',
    off: { attr: '0', upper: false }, offSays: 'body carries data-capitalize-titles="0" and no label is uppercased',
  },
  {
    key: 'hide_cycle_discounts', label: 'Hide Billing Cycle Discounts', start: '0', persona: 'guest', url: confUrl,
    claim: 'Hide Billing Cycle Discounts sets body[data-hide-discounts="1"] on the configure step, and the "Save X%" pills are not shown.',
    settle: async p => { if (!/a=confproduct/.test(p.url())) await p.waitForURL(/a=confproduct/); },
    read: async p => ({
      attr: await bodyAttr(p, 'data-hide-discounts'),
      pills: await p.locator('.cp-cycle-save:visible').count(),
    }),
    on: v => v.attr === '1' && v.pills === 0, onSays: 'the configure step carries data-hide-discounts="1" and shows no "Save X%" pill',
    off: v => v.attr === null, offSays: 'the configure step carries no data-hide-discounts',
    finish: (proof, seen) => {
      const offPills = seen.filter(s => s.state === false).map(s => s.value.pills);
      proof.note(`"Save X%" pills visible with the flag off: ${offPills.join(', ')}`);
      if (offPills.every(n => n === 0)) proof.limit('The test product shows no "Save X%" pill even with the flag off (no discounted cycle), so only the body attribute is proven, not a pill disappearing.');
    },
  },
  {
    key: 'enable_dynamic_ajax', label: 'Enable Dynamic AJAX Loading', start: '0', persona: 'full', url: '/clientarea.php?action=services',
    claim: 'Enable Dynamic AJAX Loading turns the services table into a server-side table (data-mt-action) whose rows arrive over AJAX; off, the rows are rendered into the page.',
    read: async p => {
      const t = p.locator('#svcTable');
      const action = await t.getAttribute('data-mt-action');
      const rows = await expect.poll(() => t.locator('tbody tr').count(), { timeout: 15_000 }).toBeGreaterThan(0).then(() => true, () => false);
      const bad = /error|failed|invalid/i.test(await t.locator('tbody').innerText().catch(() => ''));
      return { action, rows, bad };
    },
    on: { action: 'tableServices', rows: true, bad: false }, onSays: 'the services table asks for tableServices over AJAX and its rows arrive',
    off: { action: null, rows: true, bad: false }, offSays: 'the services table has no data-mt-action and its rows are in the page',
  },
  {
    key: 'custom_language_list', label: 'Custom Language List', start: '0', persona: 'guest', url: '/',
    setup: { custom_language_codes: [['english', 'french'], 'json'] },
    claim: 'Custom Language List limits the locale chooser to the chosen languages (English and French here); off, every installed language is listed.',
    read: async p => (await localeItems(p)).length,
    on: 2, onSays: 'the locale chooser lists exactly the two chosen languages',
    off: n => n > 2, offSays: 'the locale chooser lists every installed language',
  },
  {
    key: 'enable_dark_mode', label: 'Enable Dark Mode', start: '1', persona: 'guest', url: '/',
    setup: { dark_mode_display: ['switcher', 'string'], dark_mode_default: ['light', 'string'] },
    prepare: p => p.context().addCookies([{ name: 'mt_theme', value: 'dark', url: BASE_URL }]),
    claim: 'Enable Dark Mode lets a visitor\'s saved "dark" choice apply; off, the site is light for everyone and data-dark-mode is "off".',
    read: async p => ({ theme: await htmlAttr(p, 'data-theme'), mode: await htmlAttr(p, 'data-dark-mode') }),
    on: { theme: 'dark', mode: 'switcher' }, onSays: 'a visitor who chose dark gets <html data-theme="dark" data-dark-mode="switcher">',
    off: { theme: 'light', mode: 'off' }, offSays: 'the same visitor gets <html data-theme="light" data-dark-mode="off">',
  },
  {
    key: 'topnav_show_icons', label: 'Top-Nav Icons', start: '0', persona: 'guest', url: '/',
    setup: { 'hadrian_active_layout_main-menu_guest': ['top', 'string'] },
    claim: 'Top-Nav Icons draws an icon next to the top-navigation items that have one; off, none are drawn.',
    read: async p => ({
      layout: await bodyAttr(p, 'data-layout'),
      icons: (await p.locator('.nav-item-icon, .nav-dropdown-item-icon, .nav-mega-item--icon').count()) > 0,
    }),
    on: { layout: 'top', icons: true }, onSays: 'the top navigation draws menu icons',
    off: { layout: 'top', icons: false }, offSays: 'the top navigation draws no menu icons',
  },
  {
    key: 'cart_subnav', label: 'Order Category Sidebar', start: '1', persona: 'guest', tab: 'order', url: `/index.php?rp=/store/${id.productGroupSlug}`,
    claim: 'Order Category Sidebar (Order Process tab) shows the Categories / Actions sidebar on the order form; off sets body[data-subnav-order="off"] and the sidebar is gone.',
    read: async p => ({ attr: await bodyAttr(p, 'data-subnav-order'), cards: (await p.locator('.subnav-card:visible').count()) > 0 }),
    on: { attr: null, cards: true }, onSays: 'the store page shows the category sidebar',
    off: { attr: 'off', cards: false }, offSays: 'the store page carries data-subnav-order="off" and shows no sidebar',
  },
  {
    key: 'website_subnav', label: 'Website Section Sidebar', start: '1', persona: 'full', url: '/index.php?rp=/user/profile',
    claim: 'Website Section Sidebar shows the section sub-nav on client-area pages; off sets body[data-subnav-website="off"] and it is gone.',
    read: async p => ({ attr: await bodyAttr(p, 'data-subnav-website'), cards: (await p.locator('.subnav-card:visible').count()) > 0 }),
    on: { attr: null, cards: true }, onSays: 'the profile page shows the section sub-nav',
    off: { attr: 'off', cards: false }, offSays: 'the profile page carries data-subnav-website="off" and shows no sub-nav',
  },
  {
    key: 'service_controls_outside', label: 'Card Titles Outside the Box', start: '0', persona: 'full', url: '/clientarea.php?action=services',
    claim: 'Card Titles Outside the Box sets body[data-svc-layout="outside"] on card pages; off, the attribute is absent (titles inside).',
    read: p => bodyAttr(p, 'data-svc-layout'),
    on: 'outside', onSays: 'the services page carries data-svc-layout="outside"',
    off: v => v !== 'outside', offSays: 'the services page is not data-svc-layout="outside"',
  },
];

for (const f of FLAG_TESTS) {
  test(`AD-11 Save turns "${f.label}" (${f.key}) ${f.start === '1' ? 'off and back on' : 'on and back off'}`, async ({ admin, visit, proof }) => {
    proof.claim(f.claim);
    settings.set({ ...(f.setup || {}), [f.key]: [f.start, 'bool'] });
    const startOn = f.start === '1';
    const page = await visit(f.persona);
    if (f.prepare) await f.prepare(page);
    const look = async () => {
      await page.goto(f.url);
      if (f.settle) await f.settle(page);
      return f.read(page);
    };
    const expected = on => (on ? f.on : f.off);
    const says = on => (on ? f.onSays : f.offSays);
    const seen = [];

    const v0 = await look();
    seen.push({ state: startOn, value: v0 });
    expectState(proof, `before the Save, with the flag ${startOn ? 'on' : 'off'}: ${says(startOn)}`, v0, expected(startOn));

    await saveFlag(admin, proof, f.key, !startOn, { tab: f.tab });
    await noErrorText(admin, proof, 'Settings screen');
    await proof.shot(rowOf(admin.locator(`input[name="${f.key}"]`)), `the ${f.key} row after Save`);
    const v1 = await look();
    seen.push({ state: !startOn, value: v1 });
    expectState(proof, `after the Save turned it ${!startOn ? 'on' : 'off'}: ${says(!startOn)}`, v1, expected(!startOn));
    await proof.shot(page, `${f.persona} page with ${f.key} ${!startOn ? 'on' : 'off'}`);

    await saveFlag(admin, proof, f.key, startOn, { tab: f.tab });
    const v2 = await look();
    seen.push({ state: startOn, value: v2 });
    expectState(proof, `after switching it back ${startOn ? 'on' : 'off'}: ${says(startOn)}`, v2, expected(startOn));
    await proof.shot(page, `${f.persona} page with ${f.key} back ${startOn ? 'on' : 'off'}`);
    if (f.finish) f.finish(proof, seen);
  });
}

test('AD-11 Saving from one tab keeps the flags of the other tab', async ({ admin, proof }) => {
  proof.claim('Both tabs are one form: the hidden tab\'s rows still post, so saving from Order Process keeps the General flags and the other way round.');
  settings.set({ cookie_box: ['1', 'bool'], enable_alternate_links: ['0', 'bool'], cart_subnav: ['0', 'bool'], op_root_pw_strength: ['1', 'bool'] });
  const read = () => ({
    cookie_box: db.setting('cookie_box'), enable_alternate_links: db.setting('enable_alternate_links'),
    cart_subnav: db.setting('cart_subnav'), op_root_pw_strength: db.setting('op_root_pw_strength'),
  });
  const want = { cookie_box: '1', enable_alternate_links: '0', cart_subnav: '0', op_root_pw_strength: '1' };
  const before = read();

  proof.step('Open Settings > Order Process and press Save changes without touching anything');
  await admin.goto(adminUrl('settings', { tab: 'order' }));
  proof.check('the General rows are not visible on the Order Process tab', !(await rowOf(admin.locator('input[name="cookie_box"]')).isVisible()));
  await submit(admin, SAVE);
  const afterOrder = read();
  proof.value('flags after saving from Order Process', before, afterOrder);
  proof.equal('every flag kept its value', afterOrder, want);

  proof.step('Open Settings > General and press Save changes without touching anything');
  await admin.goto(adminUrl('settings', { tab: 'general' }));
  await submit(admin, SAVE);
  const afterGeneral = read();
  proof.value('flags after saving from General', afterOrder, afterGeneral);
  proof.equal('every flag still kept its value', afterGeneral, want);
  await proof.shot(admin, 'Settings after the second Save');
});

// ------------------------------------------------------------- AD-12 search

test('AD-12 Search filters the rows, finds synonyms, and Enter never submits the form', async ({ admin, proof }) => {
  proof.claim('The settings search filters the rows by label, help and synonyms ("gdpr" finds Cookie Box), and Enter in any search box on the page does not submit the settings form.');
  await admin.goto(adminUrl('settings'));
  const visibleRows = async () => (await admin.locator('[data-set-row]:visible').allInnerTexts()).map(t => t.split('\n')[0].trim());
  const all = await visibleRows();
  proof.check('with no search, the General tab shows several rows', all.length > 5, all.join(' | '));

  const posts = [];
  admin.on('request', r => { if (r.method() === 'POST') posts.push(r.url()); });
  const urlBefore = admin.url();
  const box = admin.locator('#mt-set-search');

  proof.step('Type "gdpr" in the settings search');
  await box.fill('gdpr');
  const gdpr = await visibleRows();
  proof.equal('"gdpr" leaves exactly one row', gdpr.length, 1);
  proof.check('that row is Cookie Box', /cookie box/i.test(gdpr[0] || ''), gdpr.join(' | '));
  proof.check('the result line says one setting matches', /1 setting matches/i.test(await admin.locator('#mt-set-searchinfo').innerText()));
  await proof.shot(admin, 'search for gdpr');

  proof.step('Type "hreflang" instead');
  await box.fill('hreflang');
  const href = await visibleRows();
  proof.check('"hreflang" finds Enable Alternate Links', href.length === 1 && /alternate links/i.test(href[0]), href.join(' | '));

  proof.step('Press Enter in the settings search');
  await box.press('Enter');
  await admin.waitForTimeout(1500);
  proof.equal('Enter in the settings search sent no POST', posts, []);
  proof.equal('the page did not move', admin.url(), urlBefore);

  proof.step('Clear the search; open the Website Section Sidebar page picker inside the form, type in its search and press Enter');
  await box.fill('');
  proof.equal('clearing the search brings every row back', (await visibleRows()).length, all.length);
  const wrap = admin.locator('[data-chip-picker]').filter({ has: admin.locator('input[name="subnav_pages_website[]"]') });
  await wrap.locator('.mt-multi').click();
  const inner = wrap.locator('.mt-multi-search-wrap input');
  await inner.fill('client');
  await inner.press('Enter');
  await admin.waitForTimeout(1500);
  proof.equal('Enter in a picker search inside the form sent no POST', posts, []);
  proof.equal('the page still did not move', admin.url(), urlBefore);
});

test('AD-12 The tabs switch by reloading the screen on the chosen tab', async ({ admin, proof }) => {
  proof.claim('General and Order Process are links: picking one reloads Settings with &tab=, showing that tab\'s rows only.');
  await admin.goto(adminUrl('settings'));
  proof.check('General shows Cookie Box', await rowOf(admin.locator('input[name="cookie_box"]')).isVisible());
  proof.check('General hides Hide Product Nameservers', !(await rowOf(admin.locator('input[name="op_hide_nameservers_enabled"]')).isVisible()));

  proof.step('Click the Order Process tab');
  await Promise.all([admin.waitForNavigation({ waitUntil: 'domcontentloaded' }), admin.locator('.mt-tabs a', { hasText: 'Order Process' }).click()]);
  proof.check('the address now has tab=order', /[?&]tab=order\b/.test(admin.url()), admin.url());
  proof.check('the heading reads Order Process Settings', /order process settings/i.test(await admin.locator('.mt-section-title').first().innerText()));
  proof.check('Order Process shows Hide Product Nameservers', await rowOf(admin.locator('input[name="op_hide_nameservers_enabled"]')).isVisible());
  proof.check('Order Process hides Cookie Box', !(await rowOf(admin.locator('input[name="cookie_box"]')).isVisible()));
  proof.check('the Order Process tab is marked active', /is-active/.test(await admin.locator('.mt-tabs a', { hasText: 'Order Process' }).getAttribute('class')));
  await proof.shot(admin, 'Order Process tab');

  proof.step('Click the General tab');
  await Promise.all([admin.waitForNavigation({ waitUntil: 'domcontentloaded' }), admin.locator('.mt-tabs a', { hasText: 'General' }).click()]);
  proof.check('the address now has tab=general', /[?&]tab=general\b/.test(admin.url()), admin.url());
  proof.check('Cookie Box is back', await rowOf(admin.locator('input[name="cookie_box"]')).isVisible());
});

test('AD-12 Search finds a setting that lives on the other tab', async ({ admin, proof }) => {
  proof.claim('The search box filters across both tabs (index.tpl: "It filters across BOTH tabs"), so an Order Process setting can be found from General.');
  await admin.goto(adminUrl('settings'));
  proof.step('On the General tab, type "nameservers" in the settings search');
  await admin.locator('#mt-set-search').fill('nameservers');
  const info = await admin.locator('#mt-set-searchinfo').innerText();
  proof.note(`result line: "${info}"`);
  await proof.shot(admin, 'search for nameservers from General');
  const visible = await admin.locator('[data-set-row]:visible').count();
  proof.check('the result line counts the Order Process row', /1 setting matches/i.test(info), info);
  proof.check('the Hide Product Nameservers row is visible to the admin', visible === 1 && await rowOf(admin.locator('input[name="op_hide_nameservers_enabled"]')).isVisible(),
    `${visible} row(s) visible; the row keeps .mt-tab-off (display:none !important) while searching`);
});

// ---------------------------------------------------------- AD-13 dark mode

test('AD-13 Dark mode "Forced" + "Dark" saved through the screen locks every visitor to dark', async ({ admin, visit, proof }) => {
  proof.claim('Choose Display Type and Choose Default Mode store the picked values, and Forced + Dark makes the site dark even for a visitor who saved "light".');
  settings.set({ enable_dark_mode: ['1', 'bool'], dark_mode_display: ['switcher', 'string'], dark_mode_default: ['light', 'string'] });
  const guest = await visit('guest');
  await guest.context().addCookies([{ name: 'mt_theme', value: 'light', url: BASE_URL }]);
  const look = async () => { await guest.goto('/'); return { theme: await htmlAttr(guest, 'data-theme'), mode: await htmlAttr(guest, 'data-dark-mode') }; };
  proof.equal('before: a visitor who chose light sees light with the switcher', await look(), { theme: 'light', mode: 'switcher' });

  const before = { display: db.setting('dark_mode_display'), def: db.setting('dark_mode_default') };
  await admin.goto(adminUrl('settings'));
  proof.step('Pick "Forced" and "Dark" under Enable Dark Mode and press Save changes');
  await admin.locator('#mt-dark-display').selectOption('forced');
  await admin.locator('#mt-dark-default').selectOption('dark');
  await proof.shot(admin.locator('#mt-darkmode-sub'), 'dark mode options');
  await submit(admin, SAVE);
  const after = { display: db.setting('dark_mode_display'), def: db.setting('dark_mode_default') };
  proof.value('dark_mode_display, dark_mode_default', before, after);
  proof.equal('Save stored forced and dark', after, { display: 'forced', def: 'dark' });
  proof.equal('the screen shows Forced after the reload', await admin.locator('#mt-dark-display').inputValue(), 'forced');

  proof.equal('the same visitor now gets dark, forced', await look(), { theme: 'dark', mode: 'forced' });
  await proof.shot(guest, 'home page forced dark');
});

test('AD-13 Dark mode options outside the allow-list fall back to switcher and light', async ({ admin, visit, proof }) => {
  proof.claim('dark_mode_display only takes switcher|forced and dark_mode_default only light|dark; anything else is stored as switcher / light.');
  settings.set({ enable_dark_mode: ['1', 'bool'], dark_mode_display: ['forced', 'string'], dark_mode_default: ['dark', 'string'] });
  const before = { display: db.setting('dark_mode_display'), def: db.setting('dark_mode_default') };

  await admin.goto(adminUrl('settings'));
  proof.step('Make the two selects post "auto" and "sepia" (values they do not offer) and press Save changes');
  await forceOption(admin.locator('#mt-dark-display'), 'auto');
  await forceOption(admin.locator('#mt-dark-default'), 'sepia');
  await submit(admin, SAVE);
  const after = { display: db.setting('dark_mode_display'), def: db.setting('dark_mode_default') };
  proof.value('dark_mode_display, dark_mode_default', before, after);
  proof.equal('"auto" was stored as switcher and "sepia" as light', after, { display: 'switcher', def: 'light' });

  const guest = await visit('guest');
  await guest.goto('/');
  proof.equal('a new visitor gets light with the switcher', { theme: await htmlAttr(guest, 'data-theme'), mode: await htmlAttr(guest, 'data-dark-mode') }, { theme: 'light', mode: 'switcher' });
});

// ------------------------------------------- AD-14 card controls exceptions

test('AD-14 Card controls exception list keeps only the pages that support it', async ({ admin, visit, proof }) => {
  proof.claim('svc_layout_pages is filtered to Template::SVC_LAYOUT_PAGES; a listed page flips the global inside/outside choice.');
  settings.set({ service_controls_outside: ['0', 'bool'], svc_layout_pages: [[], 'json'] });
  const client = await visit('full');
  await client.goto('/clientarea.php?action=services');
  proof.equal('before: the services page has no data-svc-layout (titles inside)', await bodyAttr(client, 'data-svc-layout'), null);

  const before = jsonSetting('svc_layout_pages');
  await admin.goto(adminUrl('settings'));
  const wrap = admin.locator('[data-chip-picker]').filter({ has: admin.locator('input[name="svc_layout_pages[]"]') });
  proof.step('Pick "clientareaproducts" in the Card Titles exceptions picker');
  await pickChip(wrap, 'clientareaproducts');
  proof.step('Also make the form post "clientareadomains" (a real page without the CSS), "not-a-page" and "../../configuration"');
  await inject(wrap.locator('.mt-multi-inputs'), [
    ['checkbox', 'svc_layout_pages[]', 'clientareadomains'], ['checkbox', 'svc_layout_pages[]', 'not-a-page'], ['checkbox', 'svc_layout_pages[]', '../../configuration'],
  ]);
  await proof.shot(rowOf(admin.locator('input[name="service_controls_outside"]')), 'card titles row');
  await submit(admin, SAVE);
  const after = jsonSetting('svc_layout_pages');
  proof.value('svc_layout_pages', before, after);
  proof.equal('only clientareaproducts was stored', after, ['clientareaproducts']);

  await client.goto('/clientarea.php?action=services');
  proof.equal('the listed services page flips to data-svc-layout="outside"', await bodyAttr(client, 'data-svc-layout'), 'outside');
  await proof.shot(client, 'services page with the exception');
  await client.goto('/clientarea.php?action=domains');
  const dom = await bodyAttr(client, 'data-svc-layout');
  // The global is "inside". The server emits no attribute for it, and the
  // domains page's own body script writes "inside" explicitly; both mean the same.
  proof.check('the domains page (dropped from the list) keeps the global: inside (no attribute or "inside")', dom === null || dom === 'inside', `data-svc-layout=${dom}`);
});

// -------------------------------------------------- AD-15 sub-nav exceptions

test('AD-15 Sub-nav exception lists keep only valid pages of their own scope', async ({ admin, visit, proof }) => {
  proof.claim('subnav_pages_website keeps only client-area pages and subnav_pages_order only order pages; a listed page flips its global sidebar toggle.');
  settings.set({ website_subnav: ['1', 'bool'], cart_subnav: ['1', 'bool'], subnav_pages_website: [[], 'json'], subnav_pages_order: [[], 'json'] });
  const client = await visit('full');
  const guest = await visit('guest');
  await client.goto('/clientarea.php');
  await guest.goto('/cart.php');
  proof.equal('before: the client dashboard has no data-subnav-website', await bodyAttr(client, 'data-subnav-website'), null);
  proof.equal('before: the store page has no data-subnav-order', await bodyAttr(guest, 'data-subnav-order'), null);
  proof.equal('the dashboard is templatefile clientareahome', await bodyAttr(client, 'data-tpl'), 'clientareahome');
  proof.equal('the store page is templatefile products', await bodyAttr(guest, 'data-tpl'), 'products');

  const before = { website: jsonSetting('subnav_pages_website'), order: jsonSetting('subnav_pages_order') };
  await admin.goto(adminUrl('settings'));
  const web = admin.locator('[data-chip-picker]').filter({ has: admin.locator('input[name="subnav_pages_website[]"]') });
  proof.check('the website picker offers clientareahome', (await web.locator('.mt-multi-option[data-code="clientareahome"]').count()) === 1);
  proof.step('Pick "clientareahome" in the Website Section Sidebar exceptions; make the form also post "viewcart" (an order page) and "nope"');
  await pickChip(web, 'clientareahome');
  await inject(web.locator('.mt-multi-inputs'), [['checkbox', 'subnav_pages_website[]', 'viewcart'], ['checkbox', 'subnav_pages_website[]', 'nope']]);
  // The order picker lives on the Order Process tab (CSS-hidden here) but is
  // the same form; its hidden checkbox is the field the dropdown drives.
  proof.step('Tick "products" in the Order Category Sidebar exceptions (same form, other tab); also post "clientareahome" (a website page) and "nope"');
  const ord = admin.locator('[data-chip-picker]').filter({ has: admin.locator('input[name="subnav_pages_order[]"]') });
  await ord.locator('input[value="products"]').evaluate(n => { n.checked = true; });
  await inject(ord.locator('.mt-multi-inputs'), [['checkbox', 'subnav_pages_order[]', 'clientareahome'], ['checkbox', 'subnav_pages_order[]', 'nope']]);
  await submit(admin, SAVE);
  const after = { website: jsonSetting('subnav_pages_website'), order: jsonSetting('subnav_pages_order') };
  proof.value('subnav_pages_website, subnav_pages_order', before, after);
  proof.equal('website list kept only clientareahome, order list only products', after, { website: ['clientareahome'], order: ['products'] });
  await proof.shot(admin, 'Settings after Save');

  await client.goto('/clientarea.php');
  proof.equal('the listed dashboard flips the website sidebar off', await bodyAttr(client, 'data-subnav-website'), 'off');
  await guest.goto('/cart.php');
  proof.equal('the listed store page flips the order sidebar off', await bodyAttr(guest, 'data-subnav-order'), 'off');
  await proof.shot(guest, 'store page with the order sidebar flipped off');
  proof.limit('The order picker sits on the hidden Order Process tab, so its hidden checkbox was ticked directly; the dropdown itself is exercised on the website picker.');
});

// ------------------------------------------------- AD-16 custom languages

test('AD-16 Custom language list keeps only installed languages', async ({ admin, visit, proof }) => {
  proof.claim('custom_language_codes is lowercased, de-duplicated and filtered to the languages installed in /lang/, and the locale chooser lists exactly those.');
  settings.set({ custom_language_list: ['0', 'bool'], custom_language_codes: [[], 'json'] });
  const before = jsonSetting('custom_language_codes');

  await admin.goto(adminUrl('settings'));
  proof.step('Tick Custom Language List, then pick English and French in its language picker');
  await setChecked(admin.locator('input[name="custom_language_list"]'), true);
  await admin.locator('#mt-lang-multi').click();
  await admin.locator('#mt-lang-options .mt-multi-option[data-code="english"]').click();
  await admin.locator('#mt-lang-options .mt-multi-option[data-code="french"]').click();
  await admin.keyboard.press('Escape');
  await proof.shot(admin.locator('#mt-language-picker'), 'language picker');
  proof.step('Make the form also post "klingon", "FRENCH", "" and "../../configuration"');
  await inject(admin.locator('#mt-lang-inputs'), [
    ['checkbox', 'custom_language_codes[]', 'klingon'], ['checkbox', 'custom_language_codes[]', 'FRENCH'],
    ['checkbox', 'custom_language_codes[]', ''], ['checkbox', 'custom_language_codes[]', '../../configuration'],
  ]);
  await submit(admin, SAVE);
  const after = jsonSetting('custom_language_codes');
  proof.value('custom_language_codes', before, after);
  proof.equal('only english and french were stored', after, ['english', 'french']);
  proof.equal('custom_language_list was stored on', db.setting('custom_language_list'), '1');

  const guest = await visit('guest');
  await guest.goto('/');
  const items = await localeItems(guest);
  proof.equal('the locale chooser lists two languages', items.length, 2);
  proof.check('they are English and French', items.some(t => /english/i.test(t)) && items.some(t => /fran|french/i.test(t)), items.join(', '));
  await proof.shot(guest, 'locale chooser');
  proof.limit('hreflang links are not filtered by this list (FEATURES.md AD-16 lists hreflang as untested); not checked here.');
});

// ---------------------------------------------------------- AD-17 cookie box

test('AD-17 Cookie box: messages per language, position allow-listed, empty button falls back to "Continue"', async ({ admin, visit, proof }) => {
  proof.claim('cookie_box_message keeps only installed languages with non-empty text; cookie_box_position only takes bottom-left|bottom-right|bottom; an empty button label is stored as "Continue". Visitors see their language\'s message, else the default language\'s.');
  settings.set({ cookie_box: ['0', 'bool'], cookie_box_message: [[], 'json'], cookie_box_position: ['bottom-right', 'string'], cookie_box_button: ['Got it', 'string'] });
  const EN = 'Audit cookie message in English';
  const FR = 'Message cookie audit en francais';
  const before = { message: db.setting('cookie_box_message'), position: db.setting('cookie_box_position'), button: db.setting('cookie_box_button') };

  await admin.goto(adminUrl('settings'));
  proof.step('Tick Cookie Box; type an English message, switch the message language to French and type a French one, set Spanish to spaces');
  await setChecked(admin.locator('input[name="cookie_box"]'), true);
  await admin.locator('textarea[name="cookie_box_message[english]"]').fill(EN);
  await admin.locator('#mt-cookie-lang').selectOption('french');
  await admin.locator('textarea[name="cookie_box_message[french]"]').fill(FR);
  await admin.locator('#mt-cookie-lang').selectOption('spanish');
  await admin.locator('textarea[name="cookie_box_message[spanish]"]').fill('   ');
  proof.step('Empty the button label; make the position select post "top" and the form post a message for "klingon"');
  await admin.locator('#mt-cookie-btn').fill('');
  await forceOption(admin.locator('#mt-cookie-pos'), 'top');
  await inject(admin.locator('[data-cookie-msg-i18n]'), [['textarea', 'cookie_box_message[klingon]', 'Qapla']]);
  await proof.shot(admin.locator('#mt-cookiebox-sub'), 'cookie box options');
  await submit(admin, SAVE);

  const after = { message: db.setting('cookie_box_message'), position: db.setting('cookie_box_position'), button: db.setting('cookie_box_button') };
  proof.value('cookie_box_message, position, button', before, after);
  proof.equal('the message map kept English and French only', JSON.parse(after.message || 'null'), { english: EN, french: FR });
  proof.equal('position "top" was stored as bottom-left', after.position, 'bottom-left');
  proof.equal('the empty button label was stored as "Continue"', after.button, 'Continue');

  const bar = async (url) => {
    const g = await visit('guest');
    await g.goto(url);
    const b = g.locator('#mtCookieBar');
    return { page: g, cls: await b.getAttribute('class'), msg: (await b.locator('.mt-cookie-bar__msg').textContent() || '').trim(), btn: (await b.locator('[data-cookie-accept]').textContent() || '').trim() };
  };
  const en = await bar('/');
  proof.check('the bar sits bottom-left', /mt-cookie-bar--bottom-left\b/.test(en.cls || ''), en.cls);
  proof.equal('an English visitor reads the English message', en.msg, EN);
  proof.equal('the button reads "Continue"', en.btn, 'Continue');
  await en.page.locator('#mtCookieBar').waitFor({ state: 'visible', timeout: 6000 }).catch(() => {});
  await proof.shot(en.page, 'English cookie bar');
  const fr = await bar('/?language=french');
  proof.equal('a French visitor reads the French message', fr.msg, FR);
  await fr.page.locator('#mtCookieBar').waitFor({ state: 'visible', timeout: 6000 }).catch(() => {});
  await proof.shot(fr.page, 'French cookie bar');
  const es = await bar('/?language=spanish');
  proof.equal('a Spanish visitor (no message stored) falls back to the default language\'s message', es.msg, EN);
});

// ------------------------------------------------- AD-18 dynamic tables API

test('AD-18 Dynamic tables endpoint: 401 with no client, 403 with the flag off, rows once it is on', async ({ admin, visit, proof }) => {
  proof.claim('POST mtAction=tableServices answers 401 for a guest, 403 for a signed-in client while Enable Dynamic AJAX Loading is off, and DataTables JSON once the admin turns it on.');
  settings.set({ enable_dynamic_ajax: ['0', 'bool'] });
  const form = { mtAction: 'tableServices', draw: '1', start: '0', length: '10' };
  const guest = await visit('guest');
  const client = await visit('full');
  const call = async (page) => {
    const r = await page.context().request.post('/clientarea.php', { form, maxRedirects: 0 });
    let json = null;
    try { json = JSON.parse(await r.text()); } catch {}
    return { status: r.status(), json };
  };

  const g0 = await call(guest);
  proof.equal('a guest gets 401', g0.status, 401);
  proof.equal('with {"error":"Unauthorized"}', g0.json, { error: 'Unauthorized' });
  const c0 = await call(client);
  proof.equal('a signed-in client gets 403 while the flag is off', c0.status, 403);
  proof.equal('with {"error":"Feature disabled"}', c0.json, { error: 'Feature disabled' });

  await saveFlag(admin, proof, 'enable_dynamic_ajax', true);
  const c1 = await call(client);
  proof.equal('with the flag on, the client gets 200', c1.status, 200);
  proof.check('and a DataTables reply with a data array', c1.json && Array.isArray(c1.json.data), JSON.stringify(c1.json).slice(0, 200));
  proof.note(`rows returned: ${c1.json && Array.isArray(c1.json.data) ? c1.json.data.length : 'n/a'}`);
  const g1 = await call(guest);
  proof.equal('a guest still gets 401 with the flag on', g1.status, 401);

  await saveFlag(admin, proof, 'enable_dynamic_ajax', false);
  const c2 = await call(client);
  proof.equal('after switching it off again, the client gets 403', c2.status, 403);
  await proof.shot(admin, 'Settings after the last Save');
});

// ------------------------------------------------ AD-19 order process

test('AD-19 Save turns "Hide Product Nameservers" (op_hide_nameservers) on for all products and back off', async ({ admin, visit, proof }) => {
  proof.claim('Hide Product Nameservers stores off|all|selected; with "All Products" the NS1/NS2 prefix fields are hidden on the configure step, and off brings them back.');
  settings.set({ op_hide_nameservers: ['off', 'string'], op_hide_hostname: ['off', 'string'] });
  const guest = await visit('guest');
  const look = async () => { await reachConfigure(guest); return { ns: await guest.locator('input[name=ns1prefix]').isVisible(), host: await guest.locator('input[name=hostname]').isVisible() }; };
  proof.equal('before: nameserver and hostname fields are asked for', await look(), { ns: true, host: true });

  const before = db.setting('op_hide_nameservers');
  await admin.goto(adminUrl('settings', { tab: 'order' }));
  proof.step('Tick Hide Product Nameservers, leave "Apply to" on All Products and press Save changes');
  await setChecked(admin.locator('input[name="op_hide_nameservers_enabled"]'), true);
  await admin.locator('#op-ns-mode').selectOption('all');
  await proof.shot(admin.locator('#op-ns-sub'), 'nameserver options');
  await submit(admin, SAVE);
  const on = db.setting('op_hide_nameservers');
  proof.value('op_hide_nameservers', before, on);
  proof.equal('Save stored "all"', on, 'all');
  proof.equal('the configure step hides the nameserver fields and still asks for the hostname', await look(), { ns: false, host: true });
  await proof.shot(guest, 'configure step without nameservers');

  await admin.goto(adminUrl('settings', { tab: 'order' }));
  proof.step('Untick it and press Save changes');
  await setChecked(admin.locator('input[name="op_hide_nameservers_enabled"]'), false);
  await submit(admin, SAVE);
  const off = db.setting('op_hide_nameservers');
  proof.value('op_hide_nameservers (second save)', on, off);
  proof.equal('Save stored "off"', off, 'off');
  proof.equal('the nameserver fields are back', await look(), { ns: true, host: true });
});

test('AD-19 Save turns "Hide Product Hostname" (op_hide_hostname) on for selected groups, keeping only existing group IDs', async ({ admin, visit, proof }) => {
  proof.claim('Hide Product Hostname with "Selected Product Groups" stores the picked group IDs filtered to existing groups, and hides hostname + root password for products in them; off shows them again.');
  settings.set({ op_hide_hostname: ['off', 'string'], op_hide_hostname_groups: [[], 'json'], op_hide_nameservers: ['off', 'string'] });
  const guest = await visit('guest');
  const look = async () => {
    await reachConfigure(guest);
    return { host: await guest.locator('input[name=hostname]').isVisible(), pw: await guest.locator('input[name=rootpw]').isVisible() };
  };
  proof.equal('before: hostname and root password are asked for', await look(), { host: true, pw: true });

  const before = { mode: db.setting('op_hide_hostname'), groups: jsonSetting('op_hide_hostname_groups') };
  await admin.goto(adminUrl('settings', { tab: 'order' }));
  proof.step(`Tick Hide Product Hostname, choose "Selected Product Groups" and pick group ${id.serverGroupId} in the group picker`);
  await setChecked(admin.locator('input[name="op_hide_hostname_enabled"]'), true);
  await admin.locator('#op-host-mode').selectOption('selected');
  const picker = admin.locator('#op-host-groups [data-chip-picker]');
  await pickChip(picker, String(id.serverGroupId));
  proof.step('Make the form also post group IDs 999999 and "abc", which do not exist');
  await inject(picker.locator('.mt-multi-inputs'), [['checkbox', 'op_hide_hostname_groups[]', '999999'], ['checkbox', 'op_hide_hostname_groups[]', 'abc']]);
  await proof.shot(admin.locator('#op-host-sub'), 'hostname options');
  await submit(admin, SAVE);
  const on = { mode: db.setting('op_hide_hostname'), groups: jsonSetting('op_hide_hostname_groups') };
  proof.value('op_hide_hostname, op_hide_hostname_groups', before, on);
  proof.equal('Save stored "selected" with only the existing group', on, { mode: 'selected', groups: [String(id.serverGroupId)] });
  proof.equal('a product in that group no longer shows hostname or root password', await look(), { host: false, pw: false });
  proof.check('the hidden hostname is still filled in for WHMCS', (await guest.locator('input[name=hostname]').inputValue()) !== '');
  await proof.shot(guest, 'configure step without hostname');

  await admin.goto(adminUrl('settings', { tab: 'order' }));
  proof.step('Untick Hide Product Hostname and press Save changes');
  await setChecked(admin.locator('input[name="op_hide_hostname_enabled"]'), false);
  await submit(admin, SAVE);
  const off = db.setting('op_hide_hostname');
  proof.value('op_hide_hostname (second save)', on.mode, off);
  proof.equal('Save stored "off"', off, 'off');
  proof.equal('hostname and root password are asked for again', await look(), { host: true, pw: true });
});

test('AD-19 Save turns "Use Custom Hostname" (op_custom_hostname) on and off; the domain gets its leading dot and a short length is raised to 8', async ({ admin, visit, proof }) => {
  proof.claim('With the hostname hidden, Use Custom Hostname builds it as <random>.<zone><domain> from the fields; the domain is stored with a leading dot, the random length is clamped to 8-50, the character set is limited to upper/lower/numbers. Off: "a random string is used" (the admin help text).');
  settings.set({
    op_hide_hostname: ['all', 'string'], op_custom_hostname: ['0', 'bool'], op_custom_hostname_prefix: ['', 'string'],
    op_custom_hostname_interfix: ['20', 'int'], op_custom_hostname_suffix: ['', 'string'], op_custom_hostname_chars: [['upper', 'lower', 'numbers'], 'json'],
  });
  const keys = ['op_custom_hostname', 'op_custom_hostname_prefix', 'op_custom_hostname_interfix', 'op_custom_hostname_suffix', 'op_custom_hostname_chars'];
  const read = () => Object.fromEntries(keys.map(k => [k, k.endsWith('chars') ? jsonSetting(k) : db.setting(k)]));
  const guest = await visit('guest');
  const hostname = async () => {
    await reachConfigure(guest);
    const f = guest.locator('input[name=hostname]');
    await expect.poll(() => f.inputValue(), { timeout: 10_000 }).not.toBe('');
    return f.inputValue();
  };
  const before = read();

  await admin.goto(adminUrl('settings', { tab: 'order' }));
  proof.step('Tick Use Custom Hostname; zone "srv", random length "3", domain "hadrian.test" (no dot); untick Uppercase and Lowercase; make the form also post the character set "symbols"; press Save changes');
  await setChecked(admin.locator('input[name="op_custom_hostname"]'), true);
  await admin.locator('#op-host-prefix').fill('srv');
  await admin.locator('#op-host-interfix').fill('3');
  await admin.locator('#op-host-suffix').fill('hadrian.test');
  await setChecked(admin.locator('input[name="op_custom_hostname_chars[]"][value="upper"]'), false);
  await setChecked(admin.locator('input[name="op_custom_hostname_chars[]"][value="lower"]'), false);
  await inject(admin.locator('.mt-chipset'), [['checkbox', 'op_custom_hostname_chars[]', 'symbols']]);
  await proof.shot(admin.locator('#op-customhost-fields'), 'custom hostname fields');
  await submit(admin, SAVE);
  const on = read();
  proof.value('custom hostname settings', before, on);
  proof.equal('Save stored the flag on, zone "srv", length raised to 8, domain ".hadrian.test", numbers only', on, {
    op_custom_hostname: '1', op_custom_hostname_prefix: 'srv', op_custom_hostname_interfix: '8', op_custom_hostname_suffix: '.hadrian.test', op_custom_hostname_chars: ['numbers'],
  });
  const hOn = await hostname();
  proof.check('the generated hostname is 8 digits + ".srv.hadrian.test"', /^[0-9]{8}\.srv\.hadrian\.test$/.test(hOn), hOn);

  await admin.goto(adminUrl('settings', { tab: 'order' }));
  proof.step('Untick Use Custom Hostname and press Save changes');
  await setChecked(admin.locator('input[name="op_custom_hostname"]'), false);
  await submit(admin, SAVE);
  const off = db.setting('op_custom_hostname');
  proof.value('op_custom_hostname (second save)', on.op_custom_hostname, off);
  proof.equal('Save stored "0"', off, '0');
  const hOff = await hostname();
  proof.note(`hostname with the flag off: ${hOff}`);
  proof.check('with it off, the random block is no longer limited to numbers', /[A-Za-z]/.test(hOff.split('.')[0]), hOff);
  proof.check('with it off, the zone and domain fields are not used ("a random string is used")', !/\.srv\.hadrian\.test$/.test(hOff), hOff);
});

test('AD-19 Order Process validation: random length above 50 is stored as 50, an unknown "Apply to" as "all", no character set as none', async ({ admin, visit, proof }) => {
  proof.claim('op_custom_hostname_interfix is clamped to 50 at the top, an "Apply to" mode outside all|selected is stored as "all", and an empty character set stays empty (which the cart treats as all three).');
  settings.set({
    op_hide_hostname: ['all', 'string'], op_hide_nameservers: ['off', 'string'], op_custom_hostname: ['1', 'bool'],
    op_custom_hostname_prefix: ['', 'string'], op_custom_hostname_suffix: ['.hadrian.test', 'string'], op_custom_hostname_interfix: ['20', 'int'],
    op_custom_hostname_chars: [['numbers'], 'json'],
  });
  const before = { interfix: db.setting('op_custom_hostname_interfix'), ns: db.setting('op_hide_nameservers'), chars: jsonSetting('op_custom_hostname_chars') };
  await admin.goto(adminUrl('settings', { tab: 'order' }));
  proof.step('Random length "99"; untick Numbers so no character set is ticked; tick Hide Product Nameservers and make "Apply to" post "some"; press Save changes');
  await admin.locator('#op-host-interfix').fill('99');
  await setChecked(admin.locator('input[name="op_custom_hostname_chars[]"][value="numbers"]'), false);
  await setChecked(admin.locator('input[name="op_hide_nameservers_enabled"]'), true);
  await forceOption(admin.locator('#op-ns-mode'), 'some');
  await submit(admin, SAVE);
  const after = { interfix: db.setting('op_custom_hostname_interfix'), ns: db.setting('op_hide_nameservers'), chars: jsonSetting('op_custom_hostname_chars') };
  proof.value('interfix, op_hide_nameservers, chars', before, after);
  proof.equal('99 was stored as 50, "some" as "all", the character set as []', after, { interfix: '50', ns: 'all', chars: [] });
  proof.equal('the screen shows 50 after the reload', await admin.locator('#op-host-interfix').inputValue(), '50');

  const guest = await visit('guest');
  await reachConfigure(guest);
  const f = guest.locator('input[name=hostname]');
  await expect.poll(() => f.inputValue(), { timeout: 10_000 }).not.toBe('');
  const h = await f.inputValue();
  proof.check('the hidden hostname has a 50-character random block before ".hadrian.test"', /^[A-Za-z0-9]{50}\.hadrian\.test$/.test(h), h);
  proof.equal('"all" hides the nameserver fields', await guest.locator('input[name=ns1prefix]').isVisible(), false);
});

test('AD-19 Save turns "Hide on Checkout page" (op_hide_hostname_checkout) on and off', async ({ admin, visit, proof }) => {
  proof.claim('With Hide Product Hostname on, Hide on Checkout page also drops the hostname line under the product in the cart; off brings the line back.');
  test.setTimeout(240_000);
  settings.set({ op_hide_hostname: ['off', 'string'], op_hide_hostname_checkout: ['0', 'bool'], op_hide_nameservers: ['off', 'string'], op_root_pw_strength: ['0', 'bool'] });
  const guest = await visit('guest');
  try {
    proof.step('As a guest, configure the server product with hostname srv-visible.hadrian-test.com and go to the cart');
    await reachConfigure(guest);
    await guest.locator('input[name=hostname]').fill('srv-visible.hadrian-test.com');
    await guest.locator('input[name=rootpw]').fill('Tr0ub4dor&3-Horse!');
    for (const [n, v] of [['ns1prefix', 'ns1'], ['ns2prefix', 'ns2']]) {
      const fld = guest.locator(`input[name=${n}]`);
      if (await fld.isVisible()) await fld.fill(v);
    }
    await guest.locator('#btnCompleteProductConfig').click();
    await guest.waitForURL(/a=view/, { timeout: 30_000 });
    const line = guest.locator('.ct-product-domain');
    proof.equal('before: the cart shows the hostname under the product', (await line.first().textContent() || '').trim(), 'srv-visible.hadrian-test.com');

    const before = { mode: db.setting('op_hide_hostname'), checkout: db.setting('op_hide_hostname_checkout') };
    await admin.goto(adminUrl('settings', { tab: 'order' }));
    proof.step('Tick Hide Product Hostname (All Products) and, inside it, Hide on Checkout page; press Save changes');
    await setChecked(admin.locator('input[name="op_hide_hostname_enabled"]'), true);
    await admin.locator('#op-host-mode').selectOption('all');
    await setChecked(admin.locator('input[name="op_hide_hostname_checkout"]'), true);
    await proof.shot(admin.locator('#op-host-sub'), 'hostname options');
    await submit(admin, SAVE);
    const on = { mode: db.setting('op_hide_hostname'), checkout: db.setting('op_hide_hostname_checkout') };
    proof.value('op_hide_hostname, op_hide_hostname_checkout', before, on);
    proof.equal('Save stored all and "1"', on, { mode: 'all', checkout: '1' });
    await guest.reload();
    proof.equal('the cart no longer shows the hostname line', await line.count(), 0);
    await proof.shot(guest, 'cart without the hostname line');

    await admin.goto(adminUrl('settings', { tab: 'order' }));
    proof.step('Untick Hide on Checkout page and press Save changes');
    await setChecked(admin.locator('input[name="op_hide_hostname_checkout"]'), false);
    await submit(admin, SAVE);
    const off = db.setting('op_hide_hostname_checkout');
    proof.value('op_hide_hostname_checkout (second save)', on.checkout, off);
    proof.equal('Save stored "0"', off, '0');
    await guest.reload();
    proof.equal('the hostname line is back', await line.count(), 1);
  } finally {
    await guest.goto('/cart.php?a=empty').catch(() => {});
  }
});

test('AD-19 Save turns "Enable Password Strength For Root Password Field" (op_root_pw_strength) on and off', async ({ admin, visit, proof }) => {
  proof.claim('The root-password strength option adds a strength meter and the rootpwstrength field to the configure step; off removes both.');
  settings.set({ op_root_pw_strength: ['0', 'bool'], op_hide_hostname: ['off', 'string'] });
  const guest = await visit('guest');
  const look = async () => {
    await reachConfigure(guest);
    return { meter: await guest.locator('#cpPwMeter').count(), field: await guest.locator('input[name=rootpwstrength]').count() };
  };
  proof.equal('before: no meter and no rootpwstrength field', await look(), { meter: 0, field: 0 });

  await saveFlag(admin, proof, 'op_root_pw_strength', true, { tab: 'order' });
  proof.equal('the configure step has the meter and the rootpwstrength field', await look(), { meter: 1, field: 1 });
  proof.equal('rootpwstrength asks the server to check', await guest.locator('input[name=rootpwstrength]').inputValue(), 'true');
  await guest.locator('#inputRootpw').fill('abc');
  const weak = (await guest.locator('#cpPwLabel').innerText()).trim();
  await guest.locator('#inputRootpw').fill('Tr0ub4dor&3-Horse!');
  const strong = (await guest.locator('#cpPwLabel').innerText()).trim();
  proof.check('the meter label changes between a weak and a strong password', weak !== '' && weak !== strong, `${weak} -> ${strong}`);
  await proof.shot(guest, 'root password meter');

  await saveFlag(admin, proof, 'op_root_pw_strength', false, { tab: 'order' });
  proof.equal('after switching it off: no meter, no rootpwstrength field', await look(), { meter: 0, field: 0 });
});

// ---------------------------------------------------- AD-91 payload to cart

test('AD-91 The order form follows $hadrian.addonSettings after a Settings save', async ({ admin, visit, proof }) => {
  proof.claim('$hadrian.addonSettings carries the saved settings to the hadrian_cart order form: free_label turns a 0.00 price into "Free" in the cart\'s own price partial, op_root_pw_strength adds the cart\'s meter.');
  settings.set({ free_label: ['0', 'bool'], op_root_pw_strength: ['0', 'bool'], op_hide_hostname: ['off', 'string'] });
  const guest = await visit('guest');
  const store = '/index.php?rp=/store/openpanel-hosting';
  const priceText = async () => { await guest.goto(store); return guest.locator('.content-area').innerText(); };

  const t0 = await priceText();
  // A zero price token: "0.00" not preceded by a digit (so "10.00" does not count).
  const ZERO = /(?<![\d.,])0\.00(?!\d)/;
  proof.check('before: the store page prints a 0.00 price', ZERO.test(t0), t0.match(/.{0,30}0\.00.{0,30}/)?.[0] || '');
  await reachConfigure(guest);
  proof.equal('before: no root-password meter', await guest.locator('#cpPwMeter').count(), 0);

  await saveFlag(admin, proof, 'free_label', true);
  await saveFlag(admin, proof, 'op_root_pw_strength', true, { tab: 'order' });

  const t1 = await priceText();
  proof.check('the store page now prints "Free"', /free/i.test(t1));
  proof.check('no 0.00 price is left on the store page', !ZERO.test(t1), t1.match(/.{0,30}(?<![\d.,])0\.00.{0,30}/)?.[0] || '');
  await proof.shot(guest, 'store page with Free');
  await reachConfigure(guest);
  proof.equal('the configure step now has the root-password meter', await guest.locator('#cpPwMeter').count(), 1);
  proof.limit('Other payload members named in the row (mtBrand, menus, dark-mode values) are proven elsewhere: dark mode in AD-11/AD-13 here, branding and menus in their own sections.');
});

// ------------------------------------------------------ AD-93 admin dark

test('AD-93 Admin dark mode toggles, is kept in localStorage and is applied before the page paints', async ({ admin, proof }) => {
  proof.claim('The admin theme button flips #mt-admin-root between light and dark, stores the choice in localStorage "hadrian-admin-theme", and the header script applies it on the next load before the page finishes parsing.');
  await admin.addInitScript(() => {
    document.addEventListener('DOMContentLoaded', () => {
      const r = document.getElementById('mt-admin-root');
      window.__auditThemeAtDcl = r ? r.getAttribute('data-theme') : null;
    });
  });
  await admin.goto(adminUrl('settings'));
  await admin.evaluate(() => localStorage.removeItem('hadrian-admin-theme'));
  await admin.reload();
  const root = admin.locator('#mt-admin-root');
  const ls = () => admin.evaluate(() => localStorage.getItem('hadrian-admin-theme'));
  const bg = () => root.evaluate(el => getComputedStyle(el).backgroundColor);
  const lsBefore = await ls();
  proof.equal('with nothing stored, the admin is light', await root.getAttribute('data-theme'), 'light');
  const lightBg = await bg();

  proof.step('Click the light/dark button in the admin header');
  await admin.locator('#mt-theme-toggle').click();
  proof.equal('the admin root is now dark', await root.getAttribute('data-theme'), 'dark');
  const lsDark = await ls();
  proof.value('localStorage hadrian-admin-theme', lsBefore, lsDark);
  proof.equal('localStorage holds "dark"', lsDark, 'dark');
  proof.check('the background colour changed', (await bg()) !== lightBg, `${lightBg} -> ${await bg()}`);

  proof.step('Reload the page');
  await admin.reload();
  proof.equal('after the reload the admin root is dark', await root.getAttribute('data-theme'), 'dark');
  proof.equal('it was already dark when the HTML finished parsing (DOMContentLoaded)', await admin.evaluate(() => window.__auditThemeAtDcl), 'dark');
  await proof.shot(admin, 'admin dark after reload');

  proof.step('Click the button again and reload');
  await admin.locator('#mt-theme-toggle').click();
  const lsLight = await ls();
  proof.value('localStorage hadrian-admin-theme (second click)', lsDark, lsLight);
  proof.equal('localStorage holds "light"', lsLight, 'light');
  await admin.reload();
  proof.equal('after the reload the admin root is light again', await root.getAttribute('data-theme'), 'light');
  proof.limit('"No flash" is proven at the DOM level (dark before DOMContentLoaded, set by the inline header script right after the root opens), not by capturing painted frames.');
});
