// Admin audit harness: every Hadrian admin feature driven through the real
// admin screen in Chromium, with proof that it changed what it says it changes.
//
// A test here does what an admin does (open the screen, change the control,
// press Save), then proves three things and records each one:
//   1. what was stored: the database value before and after (db.*)
//   2. what it does: the client area or the file on disk, before and after
//   3. what the admin saw: screenshots of the screen and of the effect
// tests/lib/admin-audit-report.mjs turns the records into the report.
//
// Files are named <section>.audit.mjs so no other Playwright project matches
// them; they run in the admin-audit project, one worker, because every test
// changes what the whole site sees. Each file backs up everything the admin
// can write in beforeAll and puts it back in afterAll (useAuditBackup()), and
// tests that change settings also snapshot/restore around themselves.

import { test as base, expect } from '@playwright/test';
import { spawnSync } from 'node:child_process';
import fs from 'node:fs';
import path from 'node:path';
import { PHP, TESTS_DIR, REPORTS_DIR, BASE_URL, USER_AGENT } from '../../lib/env.mjs';
import { loginAdmin, loginClient } from '../helpers.mjs';

export { expect };
export const HADRIAN = '/admin/addonmodules.php?module=Hadrian';
export const PROOF_DIR = path.join(REPORTS_DIR, 'admin-audit');

// ------------------------------------------------------------- PHP drivers

/** Run tests/php/<script> and parse the last line of its output as JSON. */
export function php(script, ...args) {
  const r = spawnSync(PHP, [path.join(TESTS_DIR, 'php', script), ...args.map(String)], {
    encoding: 'utf8', timeout: 180_000, env: process.env,
  });
  if (r.status !== 0) throw new Error(`${script} ${args.join(' ')} exited ${r.status}:\n${r.stdout}${r.stderr}`);
  const last = r.stdout.trim().split('\n').pop();
  try { return JSON.parse(last); } catch { return last; }
}

/** Read-only views of what the admin writes (tests/php/audit-state.php). */
export const db = {
  setting: key => php('audit-state.php', 'setting', key),
  settings: prefix => php('audit-state.php', 'settings', prefix),
  config: key => php('audit-state.php', 'config', key),
  page: (page, tpl = 'hadrian') => php('audit-state.php', 'page', page, tpl),
  menus: () => php('audit-state.php', 'menus'),
  menu: id => php('audit-state.php', 'menu', id),
  file: rel => php('audit-state.php', 'file', rel),
  /** sha1 per table of everything the admin can write (tests/php/admin-state.php). */
  hash: () => php('admin-state.php', 'hash'),
};

/** tests/php/settings.php: snapshot and restore hadrian_settings + hadrian_pages; set values directly. */
export const settings = {
  snapshot: () => php('settings.php', 'snapshot'),
  restore: () => php('settings.php', 'restore'),
  set: obj => php('settings.php', 'set', JSON.stringify(obj)),
  page: obj => php('settings.php', 'page', JSON.stringify(obj)),
  variant: obj => php('settings.php', 'variant', JSON.stringify(obj)),
};

/** Back up every Hadrian table and config row for the whole file, restore after. */
export function useAuditBackup() {
  base.beforeAll(() => { php('audit-state.php', 'backup'); });
  base.afterAll(() => { php('audit-state.php', 'restore'); });
}

// ---------------------------------------------------------------- browsers

async function newContext(browser) {
  return browser.newContext({ baseURL: BASE_URL, userAgent: USER_AGENT, viewport: { width: 1280, height: 900 }, ignoreHTTPSErrors: true });
}

/**
 * Fixtures:
 *   admin   - a Page signed in to the WHMCS admin as the test admin
 *   visit   - visit(persona) -> a fresh Page for 'guest' or a seeded client persona
 *   proof   - the recorder for this test (see Proof)
 */
export const test = base.extend({
  admin: async ({ browser }, use) => {
    const ctx = await newContext(browser);
    await loginAdmin(ctx.request);
    const page = await ctx.newPage();
    await use(page);
    await ctx.close();
  },
  visit: async ({ browser }, use) => {
    const opened = [];
    await use(async (persona = 'guest') => {
      const ctx = await newContext(browser);
      opened.push(ctx);
      if (persona !== 'guest') await loginClient(ctx.request, persona);
      return ctx.newPage();
    });
    for (const c of opened) await c.close();
  },
  proof: async ({}, use, testInfo) => {
    const p = new Proof(testInfo);
    await use(p);
    p.save(testInfo);
  },
});

// ------------------------------------------------------------------ proof

const slug = s => String(s).toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/^-|-$/g, '').slice(0, 60);
const short = v => {
  const s = typeof v === 'string' ? v : JSON.stringify(v);
  return s === undefined ? 'undefined' : s.length > 600 ? s.slice(0, 600) + ` ... (${s.length} chars)` : s;
};

/**
 * Records what a test did and what it proved. Test titles start with the
 * feature ID from tests/FEATURES.md ("AD-11 ..."); several tests may share one.
 *
 *   proof.claim('Save stores every flag as 1 or 0')     what the feature promises
 *   proof.step('Untick "Hide breadcrumb", press Save')   what the test did, in order
 *   proof.value('hide_breadcrumb', before, after)        a stored value before and after
 *   proof.check('breadcrumb gone for guests', ok, 'detail')  one proven fact; throws if !ok
 *   proof.equal('label', actual, expected)               check() with a comparison
 *   await proof.shot(page, 'after save')                 screenshot (page or locator)
 *   proof.note('why something could not be checked')
 *   proof.limit('what this test does NOT prove')
 */
export class Proof {
  constructor(testInfo) {
    this.title = testInfo.title;
    const m = testInfo.title.match(/^((?:AD|PB|EM)-\d+)/);
    this.id = m ? m[1] : 'AD-??';
    this.file = path.relative(TESTS_DIR, testInfo.file).replace(/\\/g, '/');
    this.dir = path.join(PROOF_DIR, this.id);
    this.base = slug(testInfo.title.replace(/^\S+\s*/, ''));
    this.claims = []; this.steps = []; this.values = []; this.checks = []; this.shots = []; this.notes = []; this.limits = [];
    this.testInfo = testInfo;
  }
  claim(text) { this.claims.push(text); return this; }
  step(text) { this.steps.push(text); return this; }
  note(text) { this.notes.push(text); return this; }
  limit(text) { this.limits.push(text); return this; }
  value(label, before, after) {
    const changed = JSON.stringify(before) !== JSON.stringify(after);
    this.values.push({ label, before: short(before), after: short(after), changed });
    return changed;
  }
  check(label, ok, detail = '') {
    this.checks.push({ label, ok: !!ok, detail: detail ? short(detail) : '' });
    if (!ok) throw new Error(`Proof failed: ${label}${detail ? ` (${short(detail)})` : ''}`);
    return this;
  }
  equal(label, actual, expected) {
    const ok = JSON.stringify(actual) === JSON.stringify(expected);
    return this.check(label, ok, ok ? `= ${short(actual)}` : `got ${short(actual)}, expected ${short(expected)}`);
  }
  async shot(target, label, opts = {}) {
    fs.mkdirSync(this.dir, { recursive: true });
    const n = String(this.shots.length + 1).padStart(2, '0');
    const file = path.join(this.dir, `${this.base}-${n}-${slug(label)}.png`);
    const isPage = typeof target.goto === 'function';
    try {
      if (isPage) await target.screenshot({ path: file, fullPage: opts.fullPage ?? false, timeout: 15_000 });
      else await target.screenshot({ path: file, timeout: 15_000 });
      this.shots.push({ label, file: path.relative(PROOF_DIR, file).replace(/\\/g, '/') });
      await this.testInfo.attach(label, { path: file, contentType: 'image/png' });
    } catch (e) {
      this.notes.push(`screenshot "${label}" failed: ${e.message.split('\n')[0]}`);
    }
    return file;
  }
  save(testInfo) {
    fs.mkdirSync(this.dir, { recursive: true });
    const rec = {
      id: this.id, title: this.title, file: this.file,
      status: testInfo.status, expectedStatus: testInfo.expectedStatus,
      error: testInfo.error ? String(testInfo.error.message || testInfo.error).split('\n').slice(0, 6).join('\n') : null,
      annotations: testInfo.annotations, durationMs: testInfo.duration, at: new Date().toISOString(),
      claims: this.claims, steps: this.steps, values: this.values, checks: this.checks,
      shots: this.shots, notes: this.notes, limits: this.limits,
    };
    fs.writeFileSync(path.join(this.dir, `${this.base}.json`), JSON.stringify(rec, null, 2));
  }
}

// ----------------------------------------------------------------- helpers

/** Open a Hadrian admin screen: adminUrl('settings', { tab: 'general' }). */
export const adminUrl = (action, params = {}) =>
  `${HADRIAN}${action ? `&action=${action}` : ''}${Object.entries(params).map(([k, v]) => `&${k}=${encodeURIComponent(v)}`).join('')}`;

/** Submit a form the way the Save button does and wait for the page that answers it. */
export async function submit(page, buttonOrForm) {
  const el = typeof buttonOrForm === 'string' ? page.locator(buttonOrForm).first() : buttonOrForm;
  const tag = await el.evaluate(n => n.tagName);
  await Promise.all([
    page.waitForNavigation({ waitUntil: 'domcontentloaded', timeout: 45_000 }),
    tag === 'FORM' ? el.evaluate(f => f.requestSubmit()) : el.click(),
  ]);
}

/**
 * Tick or untick a checkbox or radio that a Hadrian toggle hides off-screen.
 * Playwright's check() refuses those ("outside of the viewport"); this clicks
 * the input itself, which is what the toggle's label does, so the browser
 * fires click/input/change and any data-toggle-target reveal runs as usual.
 */
export async function setChecked(locator, on = true) {
  await locator.first().evaluate((el, v) => { if (el.checked !== v) el.click(); }, on);
  return locator.first().isChecked();
}

/** The text of the flash/alert the admin screen shows after a save, or ''. */
export async function flashText(page) {
  const loc = page.locator('.mt-alert, .mt-flash, .alert, [role="alert"], [role="status"]').filter({ hasText: /\S/ });
  return (await loc.allInnerTexts()).map(s => s.trim()).filter(Boolean).join(' | ');
}

/** Fetch a page's HTML as a persona without a browser (fast effect checks). */
export async function html(page, url) {
  const r = await page.context().request.get(url);
  return { status: r.status(), body: await r.text(), url: r.url() };
}

/** Make sure no PHP warning or Smarty error text reached the page. */
export async function noErrorText(page, proof, where = 'page') {
  const t = await page.locator('body').innerText().catch(() => '');
  const bad = t.match(/(Fatal error|Warning:|Notice:|Deprecated:|Smarty[^\n]{0,40}error|Uncaught )[^\n]{0,160}/);
  proof.check(`no PHP or Smarty error text on the ${where}`, !bad, bad ? bad[0] : '');
}
