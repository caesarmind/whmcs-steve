#!/usr/bin/env node
// Every page, variant and cart template is either tested or has a stated
// reason why not. See tests/e2e/coverage.mjs for the statuses.
//
//   node tests/static/check-coverage.mjs           check + one-line score
//   node tests/static/check-coverage.mjs --list    also list every gap by status
//
// Fails on:
//   - a page folder, variant or cart template that is neither rendered by a
//     test nor listed in coverage.mjs (someone added it without deciding)
//   - a coverage.mjs entry for something a test now renders (stale: remove it)
//   - a coverage.mjs entry for something that does not exist (renamed/deleted)
//
// Static on purpose: it reads routes.mjs and flows.spec.mjs as text instead
// of importing them, because they need the running site's fixtures.

import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath, pathToFileURL } from 'node:url';

const TESTS = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');
const REPO = path.resolve(TESTS, '..');
const PAGES_DIR = path.join(REPO, 'hadrian', 'templates', 'hadrian', 'core', 'pages');
const CART_DIR = path.join(REPO, 'hadrian_cart');
const list = process.argv.includes('--list');

const { PAGES, VARIANTS, CART } = await import(pathToFileURL(path.join(TESTS, 'e2e', 'coverage.mjs')).href);

// --- what the tests render -------------------------------------------------
const read = f => fs.readFileSync(path.join(TESTS, 'e2e', f), 'utf8');
const rendered = new Set();
for (const m of read('routes.mjs').matchAll(/tpl:\s*(\[[^\]]*\]|'[^']*')/g)) {
  for (const t of m[1].matchAll(/'([^']+)'/g)) rendered.add(t[1]);
}
// A route whose page has no data-tpl (a standalone popup) names what it covers.
for (const m of read('routes.mjs').matchAll(/covers:\s*'([^']+)'/g)) rendered.add(m[1]);
// expect(await tpl(page)).toBe('x'), expect(await tpl(page), 'why').toBe('x'), expect(got.tpl).toBe('x')
for (const m of ['flows.spec.mjs', 'flows-more.spec.mjs'].map(read).join('\n').matchAll(/(?:tpl\(page\)(?:,\s*[^)]*)?\)|got\.tpl\))\.toBe\('([^']+)'\)/g)) rendered.add(m[1]);
// Page variants the settings tier switches on and renders: ['page', 'variant', '.marker', persona, url]
for (const m of read('settings.spec.mjs').matchAll(/\['([a-z0-9-]+)', '([a-z0-9-]+)', '[.#][^']+', '(?:guest|full|empty)'/g)) rendered.add(`${m[1]}/${m[2]}`);

// --- what exists -----------------------------------------------------------
const dirs = d => fs.readdirSync(d, { withFileTypes: true }).filter(e => e.isDirectory()).map(e => e.name);
const pages = dirs(PAGES_DIR).sort();
const variants = [];
for (const p of pages) {
  const meta = path.join(PAGES_DIR, p, 'page.php');
  const def = (fs.existsSync(meta) && (fs.readFileSync(meta, 'utf8').match(/'defaultVariant'\s*=>\s*'([^']+)'/) || [])[1]) || 'default';
  for (const v of dirs(path.join(PAGES_DIR, p))) {
    if (v === def || v === 'overwrites') continue;
    if (fs.existsSync(path.join(PAGES_DIR, p, v, `${v}.tpl`))) variants.push(`${p}/${v}`);
  }
}
// Page folders that other page folders {include}: supportticketslist is one
// line that includes supporttickets, the password-reset steps include pwreset.
// An included page renders whenever its includer does, so it counts as tested
// through it - and must never be marked legacy.
const includedBy = {};
const walkTpl = (d, out = []) => { for (const e of fs.readdirSync(d, { withFileTypes: true })) { const p = path.join(d, e.name); if (e.isDirectory()) walkTpl(p, out); else if (e.name.endsWith('.tpl')) out.push(p); } return out; };
for (const p of pages) {
  for (const f of walkTpl(path.join(PAGES_DIR, p))) {
    for (const m of fs.readFileSync(f, 'utf8').matchAll(/core\/pages\/([a-z0-9-]+)\//g)) {
      if (m[1] !== p) (includedBy[m[1]] ||= new Set()).add(p);
    }
  }
}
const viaInclude = p => [...(includedBy[p] || [])].find(q => rendered.has(q));

const cart = fs.readdirSync(CART_DIR).filter(f => f.endsWith('.tpl')).map(f => f.slice(0, -4)).sort();

// --- judge -----------------------------------------------------------------
const problems = [];
const tally = { tested: 0, todo: 0, inner: 0, local: 0, legacy: 0 };
const gaps = { todo: [], inner: [], local: [], legacy: [] };

function judge(kind, name, isRendered, entry) {
  if (isRendered) {
    if (entry) problems.push(`${kind} "${name}" is rendered by a test now - remove its entry from tests/e2e/coverage.mjs`);
    tally.tested++;
    return;
  }
  if (!entry) { problems.push(`${kind} "${name}" is not tested and not listed in tests/e2e/coverage.mjs - add a route or an entry`); return; }
  if (!(entry.status in gaps)) { problems.push(`${kind} "${name}" has unknown status "${entry.status}"`); return; }
  tally[entry.status]++;
  gaps[entry.status].push(`${kind} ${name}${entry.step ? ` [step ${entry.step}]` : ''}: ${entry.needs || entry.in || entry.stub || entry.why || ''}`);
}

for (const p of pages) {
  if (PAGES[p]?.status === 'legacy' && includedBy[p]) {
    problems.push(`page "${p}" is marked legacy but ${[...includedBy[p]].join(', ')} include it - it is live`);
  }
  judge('page', p, rendered.has(p) || !!viaInclude(p), PAGES[p]);
}
// A variant is only "tested" once a test selects it; nothing does yet, so the
// rendered set never contains "page/variant" names.
for (const v of variants) judge('variant', v, rendered.has(v), VARIANTS[v]);
for (const t of cart) judge('cart', t, rendered.has(t), CART[t]);

for (const [map, kind, have] of [[PAGES, 'page', pages], [VARIANTS, 'variant', variants], [CART, 'cart', cart]]) {
  for (const k of Object.keys(map)) if (!have.includes(k)) problems.push(`coverage.mjs lists ${kind} "${k}", which does not exist - remove it`);
}

// --- report ----------------------------------------------------------------
const total = Object.values(tally).reduce((a, b) => a + b, 0);
const reachable = total - tally.local - tally.legacy - tally.inner;
if (list) {
  for (const [status, items] of Object.entries(gaps)) {
    if (!items.length) continue;
    console.log(`\n${status} (${items.length})`);
    for (const i of items) console.log(`  ${i}`);
  }
  console.log('');
}
for (const p of problems) console.error(`FAIL  ${p}`);
console.log(`${problems.length ? 'FAILED' : 'ok'}: ${tally.tested}/${reachable} testable templates rendered by a test ` +
  `(${Math.round((100 * tally.tested) / reachable)}%); ${tally.todo} todo, ${tally.inner} inner, ${tally.local} local-only, ${tally.legacy} legacy`);
process.exit(problems.length ? 1 : 0);
