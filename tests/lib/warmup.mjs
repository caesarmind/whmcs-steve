// Playwright globalSetup: compile WHMCS's template cache SEQUENTIALLY before
// parallel workers start - but only when the cache is cold.
//
// Why: on Windows, Smarty cannot replace a compiled template atomically
// (smarty_internal_runtime_writefile.php, the _IS_WINDOWS branch unlinks and
// then renames). With a cold templates_c, concurrent requests read half-written
// files and get truncated pages: measured 5-7 of 8 concurrent cold requests
// broken, 0 of 48 once warm. Linux renames atomically, so this is a property
// of the local stack, not a production bug - but without this, the first run
// after a deploy or a cache clear fails at random.

import fs from 'node:fs';
import path from 'node:path';
import { BASE_URL, USER_AGENT, WHMCS_ROOT, REPO_ROOT, LOCAL_DIR, credentials } from './env.mjs';
import { acquireSiteLock, pruneOutputDirs, SiteLockBusy } from './site-lock.mjs';

const COLD_BELOW = 120;   // compiled files; a warm run leaves ~250+
const STAMP = path.join(LOCAL_DIR, 'warmup-stamp.json');

/** Newest mtime across every template the stack serves from this checkout. */
function newestTemplate() {
  let max = 0;
  const walk = d => {
    let entries = [];
    try { entries = fs.readdirSync(d, { withFileTypes: true }); } catch { return; }
    for (const e of entries) {
      const p = path.join(d, e.name);
      if (e.isDirectory()) { if (e.name !== 'node_modules') walk(p); }
      else if (e.name.endsWith('.tpl')) max = Math.max(max, fs.statSync(p).mtimeMs);
    }
  };
  ['hadrian/templates/hadrian', 'hadrian_cart', 'hadrian/modules/addons/Hadrian/views'].forEach(d => walk(path.join(REPO_ROOT, d)));
  return max;
}

async function get(url, cookie = '') {
  const r = await fetch(BASE_URL + url, { headers: { 'user-agent': USER_AGENT, cookie }, redirect: 'follow' });
  return { r, html: await r.text() };
}

export default async function warmup() {
  // One run at a time against the site (site-lock.mjs). Under run.mjs this
  // finds run.mjs's lock and takes nothing; a direct `playwright test` takes
  // it here, and lets go when the Playwright process exits.
  try { await acquireSiteLock(); }
  catch (e) {
    if (!(e instanceof SiteLockBusy)) throw e;
    const busy = new Error(e.message);
    busy.stack = e.message; // the message says it all; no code frame
    throw busy;
  }
  pruneOutputDirs();

  const dir = path.join(WHMCS_ROOT, 'templates_c');
  let n = 0;
  try { n = fs.readdirSync(dir).filter(f => f.endsWith('.php')).length; } catch { return; }
  // Warm when the whole cache is cold (fresh install, cache cleared) OR when
  // any template changed since the last warm-up - the common case of "I just
  // edited a .tpl and ran the tests", where that one file would otherwise be
  // compiled by several workers at once.
  const newest = newestTemplate();
  let last = 0;
  try { last = JSON.parse(fs.readFileSync(STAMP, 'utf8')).newest || 0; } catch {}
  const reason = n < COLD_BELOW ? `templates_c was cold (${n} files)` : newest > last ? 'templates changed since the last run' : null;
  if (!reason) return;

  const { ROUTES } = await import('../e2e/routes.mjs');
  const t0 = Date.now();
  // Guest pass, then a signed-in pass (most client templates are only
  // compiled when a client asks for them).
  for (const r of ROUTES.filter(r => r.personas.includes('guest'))) await get(r.url).catch(() => {});
  // ?preview=1 pulls in partials nothing else renders (the layout state-chip
  // and each layout's own chrome). The browser tier loads every page that way,
  // so without this those partials were first compiled by several workers at
  // once - a truncated store page (83 KB of 145 KB) was the symptom.
  for (const layout of ['side', 'top', 'rail']) {
    for (const u of ['/', `/index.php?rp=/store/${(await import('./env.mjs')).fixtures()?.ids?.productGroupSlug || 'shared-hosting'}`, '/login']) {
      await get(u + (u.includes('?') ? '&' : '?') + `preview=1&layout=${layout}`).catch(() => {});
    }
  }

  const p = credentials()?.personas?.full;
  if (p) {
    const jar = {};
    const cookie = () => Object.entries(jar).map(([k, v]) => `${k}=${v}`).join('; ');
    const keep = r => { for (const c of r.headers.getSetCookie?.() || []) { const [kv] = c.split(';'); const i = kv.indexOf('='); jar[kv.slice(0, i)] = kv.slice(i + 1); } };
    const login = await fetch(BASE_URL + '/login', { headers: { 'user-agent': USER_AGENT } }); keep(login);
    const token = ((await login.text()).match(/name="token" value="([^"]+)"/) || [])[1];
    const post = await fetch(BASE_URL + '/index.php?rp=/login', {
      method: 'POST', redirect: 'manual',
      headers: { 'user-agent': USER_AGENT, cookie: cookie(), 'content-type': 'application/x-www-form-urlencoded' },
      body: new URLSearchParams({ username: p.email, password: p.password, token }),
    });
    keep(post);
    for (const r of ROUTES.filter(r => r.personas.some(x => x !== 'guest'))) {
      const res = await fetch(BASE_URL + r.url, { headers: { 'user-agent': USER_AGENT, cookie: cookie() } }).catch(() => null);
      if (res) { keep(res); await res.text(); }
    }
    // Signed-in preview chrome (sidebar user card, rail flyouts, top bar).
    for (const layout of ['side', 'top', 'rail']) {
      const res = await fetch(BASE_URL + `/clientarea.php?preview=1&layout=${layout}`, { headers: { 'user-agent': USER_AGENT, cookie: cookie() } }).catch(() => null);
      if (res) { keep(res); await res.text(); }
    }
  }
  fs.mkdirSync(LOCAL_DIR, { recursive: true });
  fs.writeFileSync(STAMP, JSON.stringify({ newest, at: new Date().toISOString() }));
  console.log(`[warmup] ${reason}; compiled sequentially in ${((Date.now() - t0) / 1000).toFixed(1)}s`);
}
