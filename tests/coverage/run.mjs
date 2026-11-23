#!/usr/bin/env node
// Template branch coverage: which {if}/{else}/{foreach} branches of the theme
// and the order form does a test run actually execute?
//
//   node tests/coverage/run.mjs            instrument, visit, report, restore
//   node tests/coverage/run.mjs --restore  only put the junctions back (after a crash)
//
// How (see instrument.mjs for the markers):
//   1. copy templates/hadrian and hadrian_cart to tests/.local/cov/ and
//      instrument every .tpl in the copy - the checkout is never touched
//   2. point the local install's two template junctions at the copies and
//      clear WHMCS's compiled-template cache
//   3. visit every route x persona in routes.mjs, then crawl as guest and
//      full, one request at a time (Windows Smarty + a cold cache)
//   4. ALWAYS put the junctions back and clear the cache again - otherwise
//      Smarty keeps serving the instrumented compiled files
//   5. write tests/reports/coverage/index.html and coverage.json
//
// Never run it while another suite run is going: for its duration the local
// site serves instrumented templates. The preflight's junction check fails
// (exit 2) if a crashed run left them swapped; --restore fixes that.

import fs from 'node:fs';
import path from 'node:path';
import { execFileSync } from 'node:child_process';
import { REPO_ROOT, LOCAL_DIR, REPORTS_DIR, WHMCS_ROOT, BASE_URL, JUNCTIONS, PHP } from '../lib/env.mjs';
import { instrument, strip, MARK } from './instrument.mjs';

const COV_DIR = path.join(LOCAL_DIR, 'cov');
const OUT_DIR = path.join(REPORTS_DIR, 'coverage');
const MAX_CRAWL = Number(process.env.HADRIAN_CRAWL_MAX || 150);

// The two junctions that serve templates (the addon's PHP is not instrumented).
const SWAPS = JUNCTIONS.filter(j => /templates/.test(j.link)).map(j => ({
  ...j, copy: path.join(COV_DIR, path.basename(j.target)),
}));

const norm = p => path.resolve(p).toLowerCase();
const targetOf = link => { try { return fs.readlinkSync(link); } catch { return null; } };

function relink(link, to) {
  const st = fs.lstatSync(link, { throwIfNoEntry: false });
  // Only ever remove a junction - never a real directory.
  if (st && !st.isSymbolicLink()) throw new Error(`${link} is a real directory, not a junction - refusing to touch it`);
  if (st) execFileSync('cmd', ['/c', 'rmdir', link]);
  execFileSync('cmd', ['/c', 'mklink', '/J', link, to], { stdio: 'ignore' });
}

function clearCompiled() {
  const d = path.join(WHMCS_ROOT, 'templates_c');
  for (const f of fs.readdirSync(d)) if (f.endsWith('.php') && f !== 'index.php') fs.rmSync(path.join(d, f), { force: true });
}

// A junction swap does not take effect at once. Each Apache worker keeps the
// path it resolved in PHP's realpath cache for realpath_cache_ttl (120 s
// here), so for up to two minutes after a swap some requests still read the
// OLD directory - and compile it into templates_c, where it stays. That is
// how an instrumented header.tpl once outlived a restore and broke the next
// suite run's crawl. So after every swap: clear the compiled cache and probe
// the home page until it serves the state we want, clearing again each time.
// One clean probe is not proof: mpm_winnt serves from many threads and each
// has its own realpath cache, so also wait out the whole TTL since the swap.
const TTL_MS = (Number(execFileSync(PHP, ['-r', 'echo (int) ini_get("realpath_cache_ttl");'], { encoding: 'utf8' })) || 120) * 1000 + 5000;

async function settle(wantMarkers, label) {
  const swappedAt = Date.now();
  const deadline = swappedAt + TTL_MS + 80_000;
  for (let n = 0; ; n++) {
    clearCompiled();
    let has = null;
    try { has = /@@hc:\d+@@/.test(await (await fetch(BASE_URL + '/', { signal: AbortSignal.timeout(60_000) })).text()); } catch {}
    if (has === wantMarkers && Date.now() - swappedAt >= TTL_MS) {
      console.log(`  ${label}: settled after ${Math.round((Date.now() - swappedAt) / 1000)}s (realpath cache TTL)`); clearCompiled(); return;
    }
    if (Date.now() > deadline) throw new Error(`${label}: the site still serves ${wantMarkers ? 'un' : ''}instrumented templates after 200s`);
    await new Promise(r => setTimeout(r, 5000));
  }
}

async function restore() {
  for (const s of SWAPS) {
    const t = targetOf(s.link);
    if (!t || norm(t) !== norm(s.target)) relink(s.link, s.target);
  }
  await settle(false, 'restore');
}

if (process.argv.includes('--restore')) { await restore(); console.log('junctions restored, compiled cache cleared'); process.exit(0); }

// --- 1. instrument a copy ----------------------------------------------------
for (const s of SWAPS) {
  const t = targetOf(s.link);
  if (!t || (norm(t) !== norm(s.target) && norm(t) !== norm(s.copy))) {
    console.error(`${s.link} points at ${t}, not this checkout - fix that first (see the preflight)`); process.exit(2);
  }
}
fs.rmSync(COV_DIR, { recursive: true, force: true });
let nextId = 0;
const points = [];
let skippedInCapture = 0;
for (const s of SWAPS) {
  fs.cpSync(s.target, s.copy, { recursive: true });
  const walk = d => {
    for (const e of fs.readdirSync(d, { withFileTypes: true })) {
      const p = path.join(d, e.name);
      if (e.isDirectory()) { walk(p); continue; }
      // invoicepdf/quotepdf.tpl are PHP (TCPDF), not Smarty: a marker would be a PHP syntax error.
      if (!e.name.endsWith('.tpl') || /pdf\.tpl$/.test(e.name)) continue;
      const rel = path.relative(REPO_ROOT, path.join(s.target, path.relative(s.copy, p))).replace(/\\/g, '/');
      const r = instrument(fs.readFileSync(p, 'utf8'), rel, () => ++nextId);
      fs.writeFileSync(p, r.out);
      points.push(...r.points);
      skippedInCapture += r.skipped;
    }
  };
  walk(s.copy);
}
console.log(`instrumented ${new Set(points.map(p => p.file)).size} templates, ${points.length} branches (${skippedInCapture} inside {capture}, not measured)`);

// --- 2..4. swap, visit, restore -------------------------------------------------
const hits = new Map();            // id -> first URL that hit it
const pageErrors = [];
let visited = 0;
try {
  for (const s of SWAPS) relink(s.link, s.copy);
  await settle(true, 'swap');

  const { session } = await import('../e2e/helpers.mjs');
  const { ROUTES } = await import('../e2e/routes.mjs');
  const { inspect } = await import('../e2e/oracles.mjs');
  const { linksOf } = await import('../e2e/crawl-rules.mjs');

  const record = (html, url, persona) => {
    visited++;
    for (const m of html.matchAll(MARK)) if (!hits.has(+m[1])) hits.set(+m[1], `${persona} ${url}`);
    const clean = strip(html);
    // Instrumentation must not change behaviour. A page that errors here but
    // not in the normal suite means a marker broke a template.
    const errs = inspect(clean).problems.filter(p => /error|Smarty/i.test(p));
    for (const e of errs) pageErrors.push(`${persona} ${url}: ${e}`);
    return clean;
  };

  // --probe <url> [persona]: save one raw instrumented page and stop. For
  // debugging the instrumentation itself.
  const probe = process.argv.indexOf('--probe');
  if (probe > 0) {
    const ctx = await session(process.argv[probe + 2] || 'guest');
    const raw = await (await ctx.get(process.argv[probe + 1], { timeout: 90_000 })).text();
    fs.writeFileSync(path.join(LOCAL_DIR, 'cov-probe.html'), raw);
    console.log(`saved tests/.local/cov-probe.html (${raw.length} bytes, ${[...raw.matchAll(MARK)].length} markers)`);
    await ctx.dispose();
    throw Object.assign(new Error('probe done'), { probe: true });
  }

  const byPersona = {};
  for (const r of ROUTES) for (const p of r.personas) (byPersona[p] ||= []).push(r.url);
  for (const [persona, urls] of Object.entries(byPersona)) {
    const ctx = await session(persona);
    for (const url of urls) {
      try { record(await (await ctx.get(url, { timeout: 90_000 })).text(), url, persona); }
      catch (e) { pageErrors.push(`${persona} ${url}: request failed - ${e.message.split('\n')[0]}`); }
    }
    process.stdout.write(`  routes as ${persona}: ${urls.length}\n`);
    await ctx.dispose();
  }

  for (const persona of ['guest', 'full']) {
    const ctx = await session(persona);
    const seen = new Set();
    const queue = ['/', ...(persona === 'guest' ? [] : ['/clientarea.php'])];
    while (queue.length && seen.size < MAX_CRAWL) {
      const url = queue.shift();
      if (seen.has(url)) continue;
      seen.add(url);
      let html;
      try { html = await (await ctx.get(url, { timeout: 90_000 })).text(); } catch { continue; }
      const clean = record(html, url, persona);
      if (persona !== 'guest' && /data-auth="out"/.test(clean)) break;   // signed out: stop
      for (const next of linksOf(clean, url, BASE_URL)) if (!seen.has(next)) queue.push(next);
    }
    process.stdout.write(`  crawl as ${persona}: ${seen.size} pages\n`);
    await ctx.dispose();
  }
} catch (e) {
  if (!e.probe) throw e;
} finally {
  await restore();
  console.log('junctions restored, compiled cache cleared');
}
if (process.argv.includes('--probe')) process.exit(0);

// --- 5. report ------------------------------------------------------------------
const files = new Map();
for (const p of points) {
  const f = files.get(p.file) || { file: p.file, total: 0, hit: 0, missed: [] };
  f.total++;
  if (hits.has(p.id)) f.hit++; else f.missed.push(p);
  files.set(p.file, f);
}
const all = [...files.values()];
const rendered = all.filter(f => f.hit > 0);
const total = points.length, hit = hits.size;
const pct = (a, b) => (b ? Math.round((1000 * a) / b) / 10 : 0);
const summary = {
  generatedAt: new Date().toISOString(), visited,
  templates: { total: all.length, rendered: rendered.length },
  branches: { total, hit, pct: pct(hit, total), skippedInCapture },
  // Branches in templates that rendered at all: the gap a new FIXTURE closes.
  // Branches in templates that never rendered: the gap a new ROUTE closes.
  inRenderedTemplates: { total: rendered.reduce((a, f) => a + f.total, 0), hit: rendered.reduce((a, f) => a + f.hit, 0) },
  pageErrors,
  hitBy: Object.fromEntries(hits),
  files: all.sort((a, b) => b.missed.length - a.missed.length).map(f => ({ ...f, missed: f.missed.map(({ id, line, kind, cond }) => ({ id, line, kind, cond })) })),
};
fs.mkdirSync(OUT_DIR, { recursive: true });
fs.writeFileSync(path.join(OUT_DIR, 'coverage.json'), JSON.stringify(summary, null, 2));
writeHtml(summary);

// Sentinel. Every page renders header.tpl, so zero hits there means WHMCS
// served compiled templates from before the swap (seen once on 2026-11-11,
// straight after a full suite run; cause not pinned down). Numbers from such
// a run under-report silently - refuse them.
const header = all.find(f => f.file.endsWith('templates/hadrian/header.tpl'));
if (visited && header && header.hit === 0) {
  console.error('\nheader.tpl recorded no hits: the site served stale compiled templates. Run it again.');
  process.exit(1);
}

const ir = summary.inRenderedTemplates;
console.log(`\n${visited} page loads`);
console.log(`templates rendered: ${rendered.length}/${all.length}`);
console.log(`branches hit:       ${hit}/${total} (${summary.branches.pct}%)`);
console.log(`  in templates that rendered: ${ir.hit}/${ir.total} (${pct(ir.hit, ir.total)}%)`);
if (pageErrors.length) { console.log(`\n${pageErrors.length} page error(s) under instrumentation:`); for (const e of pageErrors.slice(0, 15)) console.log('  ' + e); }
console.log(`\nreport: tests/reports/coverage/index.html`);

function writeHtml(s) {
  const esc = v => String(v ?? '').replace(/[&<>"]/g, ch => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;' }[ch]));
  const bar = (a, b) => `<span class="bar"><i style="width:${pct(a, b)}%"></i></span>`;
  const rows = s.files.map(f => `<details${f.hit === 0 ? ' class="none"' : ''}><summary><code>${esc(f.file)}</code>${bar(f.hit, f.total)}<span class="n">${f.hit}/${f.total}</span></summary>` +
    (f.missed.length ? `<table>${f.missed.map(m => `<tr><td class="n">${m.line}</td><td>${esc(m.kind)}</td><td><code>${esc(m.cond)}</code></td></tr>`).join('')}</table>` : '<p>every branch hit</p>') + '</details>').join('');
  fs.writeFileSync(path.join(OUT_DIR, 'index.html'), `<!doctype html><html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>Template coverage</title><style>
:root{--bg:#fbfbfd;--fg:#1d1d1f;--mut:#6e6e73;--card:#fff;--line:#e5e5ea;--ok:#1d8a3a;--none:#c4302b}
@media (prefers-color-scheme:dark){:root{--bg:#000;--fg:#f5f5f7;--mut:#a1a1a6;--card:#1c1c1e;--line:#38383a;--ok:#30d158;--none:#ff6961}}
body{margin:0;background:var(--bg);color:var(--fg);font:14px/1.5 -apple-system,BlinkMacSystemFont,"Segoe UI",system-ui,sans-serif}main{max-width:1080px;margin:0 auto;padding:32px 16px}
h1{font-size:26px;margin:0 0 4px}.meta{color:var(--mut)}details{background:var(--card);border:1px solid var(--line);border-radius:10px;margin:6px 0;padding:6px 12px}
summary{display:flex;gap:12px;align-items:center;cursor:pointer}summary code{flex:1;overflow-wrap:anywhere}details.none summary code{color:var(--none)}
.bar{width:140px;height:6px;background:var(--line);border-radius:3px;overflow:hidden;flex:none}.bar i{display:block;height:100%;background:var(--ok)}
.n{color:var(--mut);white-space:nowrap;text-align:right}table{width:100%;border-collapse:collapse;margin:6px 0}td{border-top:1px solid var(--line);padding:3px 6px;vertical-align:top}td code{overflow-wrap:anywhere}
.stats{display:flex;gap:24px;flex-wrap:wrap;margin:16px 0}.stats b{display:block;font-size:22px}
</style></head><body><main><h1>Template branch coverage</h1><p class="meta">${esc(s.generatedAt)} &middot; ${s.visited} page loads &middot; sorted by branches missed; red = template never rendered</p>
<div class="stats"><div><b>${s.branches.pct}%</b>branches hit (${s.branches.hit}/${s.branches.total})</div><div><b>${s.templates.rendered}/${s.templates.total}</b>templates rendered</div><div><b>${pct(s.inRenderedTemplates.hit, s.inRenderedTemplates.total)}%</b>branches hit in rendered templates</div></div>
${s.pageErrors.length ? `<h2>Errors under instrumentation</h2><ul>${s.pageErrors.map(e => `<li>${esc(e)}</li>`).join('')}</ul>` : ''}
${rows}</main></body></html>`);
}
