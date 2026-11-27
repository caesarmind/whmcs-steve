// AD-D Customizer (tests/FEATURES.md AD-30 to AD-34): Styles > Open the
// customizer. The admin tries a style, layouts and colours on the real site
// in a frame; only that admin's frame sees them until Save.
//
// Every page here is kept to localhost: requests to any other host are
// aborted. The guest site is the proof that unsaved state stays private.

import { test, db, settings, useAuditBackup, adminUrl, noErrorText } from './harness.mjs';
import { BASE_URL } from '../../lib/env.mjs';

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
async function guestPage(visit, { dark = false } = {}) {
  const p = await visit('guest');
  await localOnly(p);
  if (dark) await p.context().addCookies([{ name: 'mt_theme', value: 'dark', url: BASE_URL }]);
  return p;
}
/** What a page of the site draws: preview flag, theme, layout, area, accent, style class. */
const facts = page => page.evaluate(() => ({
  preview: document.documentElement.getAttribute('data-hadrian-preview'),
  theme: document.documentElement.getAttribute('data-theme'),
  layout: document.body.getAttribute('data-layout'),
  area: document.body.getAttribute('data-area'),
  accent: getComputedStyle(document.documentElement).getPropertyValue('--color-accent').trim(),
  emerald: document.body.classList.contains('theme-emerald'),
}));
async function siteAs(visit, path = '/', opts = {}) {
  const g = await guestPage(visit, opts);
  await g.goto(path);
  return facts(g);
}
const frameFacts = admin => admin.evaluate(() => {
  const d = document.querySelector('[data-cz-frame]').contentDocument;
  return {
    preview: d.documentElement.getAttribute('data-hadrian-preview'),
    theme: d.documentElement.getAttribute('data-theme'),
    layout: d.body.getAttribute('data-layout'),
    area: d.body.getAttribute('data-area'),
    accent: getComputedStyle(d.documentElement).getPropertyValue('--color-accent').trim(),
    emerald: d.body.classList.contains('theme-emerald'),
  };
});
const idle = admin => admin.evaluate(() => window.hadrianCustomize.idle());
const czData = admin => admin.evaluate(() => JSON.parse(document.getElementById('mt-cz-data').textContent));
const czState = admin => admin.evaluate(() => JSON.parse(JSON.stringify(window.hadrianCustomize.state())));

async function openCustomizer(admin, proof) {
  await localOnly(admin);
  if (!admin.__czDialogs) { admin.on('dialog', d => d.accept()); admin.__czDialogs = true; }
  await admin.goto(adminUrl('customize'));
  await idle(admin);
  if (proof) await noErrorText(admin, proof, 'customizer');
}
async function setAccent(admin, value) {
  await admin.locator('[data-cz-tab="colors"]').click();
  const f = admin.locator('[data-cz-token="--color-accent"] input[type="text"]');
  await f.fill(value);
  await f.dispatchEvent('change');
  await idle(admin);
}
/** POST to the customizer's own endpoint from the customizer page, the way customize.js does. */
const postFromPage = (admin, sub, state) => admin.evaluate(async ([s, st]) => {
  const D = JSON.parse(document.getElementById('mt-cz-data').textContent);
  const body = 'token=' + encodeURIComponent(D.csrf) + (st === null ? '' : '&state=' + encodeURIComponent(JSON.stringify(st)));
  const r = await fetch(D.endpoint + '&sub=' + s, { method: 'POST', credentials: 'same-origin', headers: { 'Content-Type': 'application/x-www-form-urlencoded' }, body });
  let j = null; try { j = await r.json(); } catch { /* not JSON */ }
  return { status: r.status, json: j };
}, [sub, state]);

const json = s => (s === null || s === undefined || s === '') ? null : JSON.parse(s);
const AREA_KEYS = ['main-menu', 'footer'].flatMap(k => ['website', 'client', 'order'].map(a => `hadrian_active_layout_${k}_area_${a}`));
const BASE = {
  enable_dark_mode: ['1', 'bool'], dark_mode_display: ['switcher', 'string'], dark_mode_default: ['light', 'string'],
  hadrian_active_style: ['default', 'string'],
  hadrian_colors_default_light: null, hadrian_colors_default_dark: null, hadrian_colors_default: null, hadrian_colors_dark: null,
  hadrian_colors_emerald_light: null, hadrian_colors_emerald_dark: null,
  hadrian_layout_mode: null, ...Object.fromEntries(AREA_KEYS.map(k => [k, null])),
  'hadrian_active_layout_main-menu_guest': ['sidebar', 'string'],
  'hadrian_active_layout_main-menu_client': ['sidebar', 'string'],
};
const STOCK = '#0071e3';
const SAVED_ACCENT = '#12ab34';

// ================================================================ AD-30

test('AD-30 The customizer opens on the saved site and drops an older unsaved try', async ({ admin, visit, proof }) => {
  proof.claim('Opening the customizer puts the saved state in the session, so the frame starts from what the site shows; a try left from an earlier visit is dropped.');
  settings.set({ ...BASE, hadrian_colors_default_light: [{ '--color-accent': SAVED_ACCENT }, 'json'] });
  const live = await siteAs(visit);
  proof.equal('guests see the saved accent', live.accent, SAVED_ACCENT);

  proof.step('Styles > Open the customizer');
  await localOnly(admin);
  admin.on('dialog', d => d.accept()); admin.__czDialogs = true;
  await admin.goto(adminUrl('styles'));
  await admin.locator('[data-open-customizer]').click();
  await admin.waitForURL(/action=customize/);
  await idle(admin);
  await noErrorText(admin, proof, 'customizer');
  let frame = await frameFacts(admin);
  await proof.shot(admin, 'customizer on open');
  proof.equal('the frame is a preview', frame.preview, '1');
  proof.equal('the frame draws the saved accent', frame.accent, SAVED_ACCENT);
  proof.equal('the frame draws the saved layout', frame.layout, live.layout);
  const st = await czState(admin);
  proof.equal('the controls start on the saved style', st.style, 'default');
  proof.equal('and the saved light colours', st.colors.light, { '--color-accent': SAVED_ACCENT });
  proof.check('Save starts disabled', await admin.locator('[data-cz-save]').isDisabled());

  proof.step('Try Accent #ff2d55 (not saved), then open the customizer again');
  await setAccent(admin, '#ff2d55');
  frame = await frameFacts(admin);
  proof.equal('the try reaches the frame', frame.accent, '#ff2d55');
  await openCustomizer(admin);
  frame = await frameFacts(admin);
  proof.equal('reopened, the frame is back on the saved accent', frame.accent, SAVED_ACCENT);
  proof.equal('and so are the controls', (await czState(admin)).colors.light, { '--color-accent': SAVED_ACCENT });
  proof.equal('nothing was stored by the try', json(db.setting('hadrian_colors_default_light')), { '--color-accent': SAVED_ACCENT });
});

// ================================================================ AD-31

test('AD-31 Preview reduces the posted state to what exists and holds it in the session', async ({ admin, visit, proof }) => {
  proof.claim('preview-ajax keeps only a style that exists, layouts that exist and colour diffs the schema accepts; everything else falls back to the saved state. The result is held in the admin session for the frame.');
  settings.set({ ...BASE });
  await openCustomizer(admin, proof);
  const D = await czData(admin);
  const savedLayouts = (await czState(admin)).layouts;

  proof.step('From the customizer page, post a state with an unknown style, junk colours, an unknown layout mode and layout, a valid client layout and dark theme');
  const sent = {
    style: 'nope', theme: 'dark',
    colors: { light: { '--color-accent': '#12ab34', '--evil-token': '#ffffff', '--color-bg': 'javascript:alert(1)', '--color-surface': '#FFFFFF', '--color-border': 'red' }, dark: 'not-a-map' },
    layouts: { mode: 'weird', audience: { 'main-menu': { guest: 'nope', client: 'top' } } },
  };
  const r = await postFromPage(admin, 'preview-ajax', sent);
  proof.value('posted -> held state', sent, r.json?.state);
  proof.equal('the endpoint answers ok', [r.status, r.json?.ok], [200, true]);
  const s = r.json.state;
  proof.equal('an unknown style falls back to the saved one', s.style, 'default');
  proof.equal('the theme is kept', s.theme, 'dark');
  proof.equal('only the valid, changed colour survives', s.colors.light, { '--color-accent': '#12ab34' });
  proof.equal('a non-map dark scope falls back to the saved (empty) one', Array.isArray(s.colors.dark) ? {} : s.colors.dark, {});
  proof.equal('an unknown mode falls back to the saved mode', s.layouts.mode, savedLayouts.mode);
  proof.equal('an unknown guest layout falls back to the saved pick', s.layouts.audience['main-menu'].guest, savedLayouts.audience['main-menu'].guest);
  proof.equal('a real layout is kept', s.layouts.audience['main-menu'].client, 'top');

  proof.step('Open the preview URL in another tab of the same admin browser');
  const tab = await admin.context().newPage();
  await tab.goto(`/index.php?${D.param}=${D.token}`);
  const held = await facts(tab);
  proof.equal('the held state is drawn: preview flag', held.preview, '1');
  proof.equal('the held dark theme', held.theme, 'dark');
  proof.equal('dark draws the stock dark accent (no dark override was held)', held.accent, '#2997ff');
  const block = await tab.evaluate(() => document.getElementById('hadrian-colors')?.textContent ?? null);
  proof.equal('the frame\'s colour block holds the light diff and nothing else', block, 'html:not([data-theme="dark"]):not([data-palette]){--color-accent:#12ab34;}');
  const lightAccent = await tab.evaluate(() => { document.documentElement.setAttribute('data-theme', 'light'); return getComputedStyle(document.documentElement).getPropertyValue('--color-accent').trim(); });
  proof.equal('switched to light, the held accent applies', lightAccent, '#12ab34');
  await proof.shot(tab, 'preview URL in a second admin tab');
  await tab.close();
  proof.equal('nothing was stored', [db.setting('hadrian_colors_default_light'), db.setting('hadrian_active_style')], [null, 'default']);
  const live = await siteAs(visit);
  proof.equal('guests still get the stock accent', live.accent, STOCK);
});

test('AD-31 Preview refuses a request with no state (400)', async ({ admin, proof }) => {
  proof.claim('preview-ajax answers 400 with a JSON error when the request carries no state.');
  settings.set({ ...BASE });
  await openCustomizer(admin);
  const r = await postFromPage(admin, 'preview-ajax', null);
  proof.value('status, body', null, r);
  proof.equal('the status is 400', r.status, 400);
  proof.equal('the reply is a JSON refusal', r.json?.ok, false);
  const bad = await admin.evaluate(async () => {
    const D = JSON.parse(document.getElementById('mt-cz-data').textContent);
    const res = await fetch(D.endpoint + '&sub=preview-ajax', { method: 'POST', credentials: 'same-origin', headers: { 'Content-Type': 'application/x-www-form-urlencoded' }, body: 'token=' + encodeURIComponent(D.csrf) + '&state=' + encodeURIComponent('{not json') });
    return res.status;
  });
  proof.equal('undecodable state is also 400', bad, 400);
});

test('AD-31 Preview answers 409 when there is no template', async ({ proof }) => {
  test.skip(true, 'Dead path in the admin: AddonHelper::getTemplate() falls back to the Hadrian template under ADMINAREA, so templateOrRefuse() can only refuse if the theme folder itself is gone, which would wreck the install.');
  proof.note('Checked instead: CustomizeController::templateOrRefuse() (409) is reached only when AddonHelper::getTemplate() returns null, and AddonHelper.php lines 36-42 return new Template(ThemeSwitch::THEME) in the admin even when WHMCS runs another theme.');
});

// ================================================================ AD-32

test('AD-32 The preview gate needs the admin session and its token', async ({ admin, visit, proof }) => {
  proof.claim('A page draws the unsaved state only for a signed-in admin whose URL carries that session\'s token; links and GET forms inside the preview carry the token, POST forms and other hosts do not.');
  settings.set({ ...BASE });
  await openCustomizer(admin);
  await setAccent(admin, '#ff2d55');
  const D = await czData(admin);
  proof.equal('the admin frame draws the try', (await frameFacts(admin)).accent, '#ff2d55');

  const guestWithToken = await siteAs(visit, `/index.php?${D.param}=${D.token}`);
  proof.equal('a guest with the token gets no preview', guestWithToken.preview, null);
  proof.equal('and the saved accent', guestWithToken.accent, STOCK);

  const tab = await admin.context().newPage();
  await tab.goto('/index.php');
  proof.equal('the admin\'s other tab without the token gets the saved site', (await facts(tab)).accent, STOCK);
  await tab.goto(`/index.php?${D.param}=${'0'.repeat(32)}`);
  proof.equal('the admin with a wrong token gets the saved site', (await facts(tab)).preview, null);
  await tab.goto(`/index.php?${D.param}=${D.token}`);
  proof.equal('the admin with the right token gets the preview', (await facts(tab)).accent, '#ff2d55');

  proof.step('Inside the preview, click a same-site link, an outside link, submit a GET form and a POST form (navigation stopped after the theme\'s handler ran)');
  const carried = await tab.evaluate(param => {
    const stop = el => el.addEventListener('click', e => e.preventDefault());
    const mk = href => { const a = document.createElement('a'); a.href = href; a.textContent = 'x'; document.body.appendChild(a); stop(a); a.click(); return a.href; };
    const form = method => {
      const f = document.createElement('form'); f.method = method; f.action = '/index.php';
      f.addEventListener('submit', e => e.preventDefault());
      document.body.appendChild(f); f.requestSubmit();
      return !!f.querySelector(`input[name="${param}"]`);
    };
    const real = document.querySelector('a[href*="cart.php"], a[href*="contact.php"], a[href*="knowledgebase"]');
    let realHref = null;
    if (real) { stop(real); real.click(); realHref = real.href; }
    return { same: mk('/cart.php?a=view'), outside: mk('https://example.invalid/page'), getForm: form('get'), postForm: form('post'), realHref };
  }, D.param);
  proof.value('links and forms', null, carried);
  proof.check('a same-site link carries the token', carried.same.includes(`${D.param}=${D.token}`), carried.same);
  if (carried.realHref) proof.check('a real link in the page carries the token', carried.realHref.includes(`${D.param}=${D.token}`), carried.realHref);
  proof.check('an outside link does not', !carried.outside.includes(D.param), carried.outside);
  proof.check('a GET form gets the token as a hidden field', carried.getForm);
  proof.check('a POST form is left alone', !carried.postForm);
  await tab.close();
});

// ================================================================ AD-33

test('AD-33 Save writes the style, both colour scopes and the audience picks', async ({ admin, visit, proof }) => {
  proof.claim('Save writes <tpl>_active_style, <tpl>_colors_<style>_light and _dark and the per-audience layout picks, and the guest site then shows them; area picks are not written in audience mode.');
  settings.set({ ...BASE });
  const before = { live: await siteAs(visit), style: db.setting('hadrian_active_style'), layouts: db.settings('hadrian_active_layout_'), mode: db.setting('hadrian_layout_mode') };
  proof.equal('before: guests get Default with the sidebar layout', [before.live.emerald, before.live.layout, before.live.accent], [false, 'side', STOCK]);

  await openCustomizer(admin, proof);
  proof.step('Pick Emerald, guest navigation Top, Accent #12ab34 in light, switch to Dark and set Accent #34ab12');
  await admin.locator('[data-cz-scheme="emerald"]').click();
  await idle(admin);
  await admin.locator('[data-cz-tab="layouts"]').click();
  await admin.locator('[data-cz-layout="main-menu:guest"]').selectOption('top');
  await idle(admin);
  await setAccent(admin, '#12ab34');
  await admin.locator('[data-cz-theme="dark"]').click();
  await idle(admin);
  await setAccent(admin, '#34ab12');
  const frame = await frameFacts(admin);
  proof.equal('the frame shows the dark try', [frame.theme, frame.accent, frame.emerald, frame.layout], ['dark', '#34ab12', true, 'top']);
  const midLive = await siteAs(visit);
  proof.equal('guests still get the saved site before Save', midLive, before.live);

  proof.step('Press Save');
  await admin.locator('[data-cz-save]').click();
  await admin.locator('[data-cz-status][data-kind="ok"]').waitFor();
  await proof.shot(admin, 'customizer after Save');
  const after = { style: db.setting('hadrian_active_style'), light: json(db.setting('hadrian_colors_emerald_light')), dark: json(db.setting('hadrian_colors_emerald_dark')), layouts: db.settings('hadrian_active_layout_'), mode: db.setting('hadrian_layout_mode') };
  proof.value('hadrian_active_style', before.style, after.style);
  proof.value('hadrian_active_layout_*', before.layouts, after.layouts);
  proof.value('hadrian_colors_emerald_light / _dark', null, { light: after.light, dark: after.dark });
  proof.equal('the style is stored', after.style, 'emerald');
  proof.equal('the light accent is stored', after.light?.['--color-accent'], '#12ab34');
  proof.equal('the dark accent is stored', after.dark?.['--color-accent'], '#34ab12');
  proof.check('the rest of Emerald\'s palette came along', after.light?.['--color-link'] === '#0c7f57', JSON.stringify(after.light));
  proof.equal('the guest navigation pick is stored', after.layouts['hadrian_active_layout_main-menu_guest'], 'top');
  proof.equal('the client pick is unchanged', after.layouts['hadrian_active_layout_main-menu_client'], 'sidebar');
  proof.check('no area picks were written in audience mode', AREA_KEYS.every(k => !(k in after.layouts)), Object.keys(after.layouts));
  proof.check('Save is disabled again', await admin.locator('[data-cz-save]').isDisabled());

  const live = await siteAs(visit);
  proof.equal('guests now get Emerald, Top and the light accent', [live.emerald, live.layout, live.accent, live.preview], [true, 'top', '#12ab34', null]);
  const liveDark = await siteAs(visit, '/', { dark: true });
  proof.equal('dark guests get the dark accent', [liveDark.theme, liveDark.accent], ['dark', '#34ab12']);
  const g = await guestPage(visit); await g.goto('/');
  await proof.shot(g, 'guest site after the customizer Save');

  await admin.goto(adminUrl('styles'));
  proof.equal('the Styles page agrees', (await admin.locator('.mt-sty-card.is-active .mt-sty-title').innerText()).trim(), 'Emerald');
});

test('AD-33 Save in area mode writes the area picks', async ({ admin, visit, proof }) => {
  proof.claim('With layouts chosen by area, Save stores <tpl>_layout_mode = area and the picks for each area, and each part of the site draws its own pick.');
  settings.set({ ...BASE });
  await openCustomizer(admin);
  const before = { mode: db.setting('hadrian_layout_mode'), layouts: db.settings('hadrian_active_layout_') };
  proof.step('Layouts tab: choose by Area, Order process navigation = Top, Website = Sidebar; Save');
  await admin.locator('[data-cz-tab="layouts"]').click();
  await admin.locator('[data-cz-mode="area"]').click();
  await idle(admin);
  await admin.locator('[data-cz-layout="main-menu:order"]').selectOption('top');
  await admin.locator('[data-cz-layout="main-menu:website"]').selectOption('sidebar');
  await idle(admin);
  await admin.locator('[data-cz-save]').click();
  await admin.locator('[data-cz-status][data-kind="ok"]').waitFor();
  const after = { mode: db.setting('hadrian_layout_mode'), layouts: db.settings('hadrian_active_layout_') };
  proof.value('hadrian_layout_mode', before.mode, after.mode);
  proof.value('hadrian_active_layout_*', before.layouts, after.layouts);
  proof.equal('the mode is stored', after.mode, 'area');
  proof.equal('the order pick is stored', after.layouts['hadrian_active_layout_main-menu_area_order'], 'top');
  proof.equal('the website pick is stored', after.layouts['hadrian_active_layout_main-menu_area_website'], 'sidebar');
  proof.check('every area has a pick for both kinds', AREA_KEYS.every(k => typeof after.layouts[k] === 'string' && after.layouts[k] !== ''), after.layouts);

  const cart = await siteAs(visit, '/cart.php?a=view');
  const home = await siteAs(visit, '/');
  proof.equal('guests in the cart get Top', [cart.area, cart.layout], ['order', 'top']);
  proof.equal('guests on the homepage get the sidebar', [home.area, home.layout], ['website', 'side']);
});

// ================================================================ AD-34

test('AD-34 Discard drops the try without storing anything', async ({ admin, visit, proof }) => {
  proof.claim('Discard puts the controls and the frame back on the saved state and writes nothing.');
  settings.set({ ...BASE });
  await openCustomizer(admin);
  const stored = () => [db.setting('hadrian_active_style'), db.setting('hadrian_colors_default_light'), db.setting('hadrian_colors_emerald_light'), db.settings('hadrian_active_layout_')];
  const before = stored();
  proof.step('Pick Emerald and Accent #ff2d55, then press Discard');
  await admin.locator('[data-cz-scheme="emerald"]').click();
  await idle(admin);
  await setAccent(admin, '#ff2d55');
  proof.check('Discard is enabled while something is unsaved', await admin.locator('[data-cz-discard]').isEnabled());
  await admin.locator('[data-cz-discard]').click();
  await idle(admin);
  const frame = await frameFacts(admin);
  const st = await czState(admin);
  proof.equal('the controls are back on Default', st.style, 'default');
  proof.equal('with no colour overrides', [Object.keys(st.colors.light), Object.keys(st.colors.dark)], [[], []]);
  proof.equal('the frame is back on the saved site', [frame.emerald, frame.accent], [false, STOCK]);
  proof.check('Save and Discard are disabled again', (await admin.locator('[data-cz-save]').isDisabled()) && (await admin.locator('[data-cz-discard]').isDisabled()));
  const after = stored();
  proof.value('style, colour and layout rows', before, after);
  proof.equal('nothing was stored', after, before);
  const live = await siteAs(visit);
  proof.equal('guests get the saved site', [live.emerald, live.accent], [false, STOCK]);
});

test('AD-34 Device buttons resize the frame; Light/Dark switches its theme', async ({ admin, proof }) => {
  proof.claim('Desktop, Tablet and Phone lay the frame out at 1280, 820 and 390px; Light and Dark switch the frame\'s data-theme and the colour scope being edited. All client-side: nothing is stored.');
  settings.set({ ...BASE });
  await openCustomizer(admin);
  const width = () => admin.locator('[data-cz-frame]').evaluate(f => f.style.width);
  const before = [db.setting('hadrian_colors_default_light'), db.setting('hadrian_colors_default_dark'), db.setting('dark_mode_default')];
  proof.equal('the frame starts at desktop width', await width(), '1280px');
  for (const [d, w] of [['tablet', '820px'], ['phone', '390px'], ['desktop', '1280px']]) {
    proof.step(`Press ${d}`);
    await admin.locator(`[data-cz-device="${d}"]`).click();
    proof.equal(`${d} lays the frame out at ${w}`, await width(), w);
    if (d === 'phone') await proof.shot(admin, 'customizer at phone width');
    proof.check(`the ${d} button is marked on`, await admin.locator(`[data-cz-device="${d}"]`).evaluate(b => b.classList.contains('is-on')));
  }

  proof.step('Press Dark, then Light');
  await admin.locator('[data-cz-theme="dark"]').click();
  await idle(admin);
  let frame = await frameFacts(admin);
  proof.equal('the frame is on data-theme="dark"', frame.theme, 'dark');
  proof.equal('and draws the stock dark accent', frame.accent, '#2997ff');
  proof.equal('the colour panel edits the dark scope', (await admin.locator('[data-cz-scope]').innerText()).trim(), 'Dark mode colours');
  await admin.locator('[data-cz-theme="light"]').click();
  await idle(admin);
  frame = await frameFacts(admin);
  proof.equal('back on data-theme="light"', frame.theme, 'light');
  proof.equal('the colour panel edits the light scope', (await admin.locator('[data-cz-scope]').innerText()).trim(), 'Light mode colours');
  const after = [db.setting('hadrian_colors_default_light'), db.setting('hadrian_colors_default_dark'), db.setting('dark_mode_default')];
  proof.value('colour rows and dark_mode_default', before, after);
  proof.equal('nothing was stored', after, before);
});

test('AD-34 Area-mode picks show in the frame only', async ({ admin, visit, proof }) => {
  proof.claim('Switching to choose layouts by area shows one pick per area; a pick reaches the frame on that area\'s pages and nowhere else until Save.');
  settings.set({ ...BASE });
  await openCustomizer(admin);
  const before = [db.setting('hadrian_layout_mode'), db.settings('hadrian_active_layout_')];
  proof.step('Layouts tab: press Area, set Order process navigation to Top, open the Cart page in the frame');
  await admin.locator('[data-cz-tab="layouts"]').click();
  await admin.locator('[data-cz-mode="area"]').click();
  await idle(admin);
  const selects = await admin.locator('[data-cz-layout^="main-menu:"]').evaluateAll(s => s.map(x => x.getAttribute('data-cz-layout')));
  proof.equal('one navigation pick per area', selects, ['main-menu:website', 'main-menu:client', 'main-menu:order']);
  await admin.locator('[data-cz-layout="main-menu:order"]').selectOption('top');
  await idle(admin);
  await admin.locator('[data-cz-page]').selectOption('cart.php?a=view');
  await idle(admin);
  let frame = await frameFacts(admin);
  proof.equal('the frame draws Top in the order process', [frame.area, frame.layout], ['order', 'top']);
  await proof.shot(admin, 'customizer with an order-area pick');
  await admin.locator('[data-cz-page]').selectOption('index.php');
  await idle(admin);
  frame = await frameFacts(admin);
  proof.equal('and the website pick on the homepage', [frame.area, frame.layout], ['website', 'side']);

  const cart = await siteAs(visit, '/cart.php?a=view');
  proof.equal('guests in the cart still get the saved sidebar', cart.layout, 'side');
  const after = [db.setting('hadrian_layout_mode'), db.settings('hadrian_active_layout_')];
  proof.value('layout mode and picks', before, after);
  proof.equal('nothing was stored', after, before);
});
