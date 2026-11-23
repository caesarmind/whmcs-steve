#!/usr/bin/env node
// Every form WHMCS's own templates post is posted the same way by Hadrian.
//
// Each Hadrian page template replaces a stock one (twenty-one for the client
// area, standard_cart for the order form). WHMCS's controllers read exactly the
// stock forms: the same route, the same field names. Forms that drifted broke
// whole features with no error anywhere:
//   - two-factor-challenge: no action -> posted to /login/challenge -> 405,
//     nobody with 2FA could sign in
//   - account-paymentmethods-manage: wrong routes and field names (ccname,
//     cccvv, no type / billingcontact) -> no card could be added
//
// For every stock form with an id, Hadrian's template of the same name must
// have the form (same id, or failing that the one posting to the same place)
//   - posting to the same route / script     (else: FAIL)
//   - carrying every field the stock form posts, counting the theme partials it
//     {include}s                              (else: FAIL)
// A stock form with no Hadrian counterpart is reported as a note, and
// deliberate departures are listed in ACCEPTED with the reason.
//
// Needs the WHMCS install for the stock templates (WHMCS_ROOT); skipped without it.

import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const REPO = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..', '..');
const WHMCS = process.env.WHMCS_ROOT || 'C:/laragon/www/whmcs';
const STOCK = { client: path.join(WHMCS, 'templates', 'twenty-one'), cart: path.join(WHMCS, 'templates', 'orderforms', 'standard_cart') };
if (!fs.existsSync(STOCK.client)) { console.log(`skipped: no stock templates under ${WHMCS} (set WHMCS_ROOT)`); process.exit(0); }

const IGNORE = new Set(['token']);   // WHMCS injects the CSRF token into POST forms itself
const ACCEPTED = {
  'cart/configureproductdomain#frmProductDomain': 'message/tlds/maxLength/filter belong to stock\'s inline AI suggestion box; Hadrian\'s domain step offers exact register/transfer/own-domain only',
  'cart/configureproductdomain#frmProductDomainSelections': 'the IDN language selector was dropped on purpose (configureproductdomain.tpl header: "edge case for follow-up"); IDN names are validated server-side',
  'cart/domainregister#frmDomainChecker': 'stock renders ONE form whose fields depend on the AI/classic mode; Hadrian renders both tabs, and the CAPTCHA input joins the form through form="frmDomainChecker" outside it',
};

const walk = (d, out = []) => { if (!fs.existsSync(d)) return out; for (const e of fs.readdirSync(d, { withFileTypes: true })) { const p = path.join(d, e.name); if (e.isDirectory()) walk(p, out); else if (e.name.endsWith('.tpl')) out.push(p); } return out; };
const strip = s => s.replace(/\{\*[\s\S]*?\*\}/g, '').replace(/\{literal\}[\s\S]*?\{\/literal\}/g, '');
const NAME = /\bname="([a-zA-Z_][\w]*)(?:\[[^\]]*\])?"/g;
const INCLUDE = /\{include\s+file=["'][^"']*?((?:includes|core)\/[^"'`]+\.tpl)["']/g;

/** Field names in a chunk of template, following {include}s into the theme's own partials. */
function namesIn(body, depth = 0) {
  const names = new Set([...body.matchAll(NAME)].map(n => n[1]));
  if (depth < 3) {
    for (const inc of body.matchAll(INCLUDE)) {
      for (const root of [path.join(REPO, 'hadrian_cart'), path.join(REPO, 'hadrian/templates/hadrian')]) {
        const p = path.join(root, inc[1]);
        if (fs.existsSync(p)) { for (const n of namesIn(strip(fs.readFileSync(p, 'utf8')), depth + 1)) names.add(n); break; }
      }
    }
  }
  return names;
}

/** Every form: { ids, action, names }. An id set inside an {if} still counts. */
function forms(src, followIncludes) {
  const out = [];
  for (const m of src.matchAll(/<form\b([\s\S]*?)>([\s\S]*?)<\/form>/gi)) {
    const attrs = m[1];
    out.push({
      ids: [...attrs.matchAll(/\bid="([^"{}]+)"/g)].map(x => x[1]),
      action: (attrs.match(/\baction="([^"]*)"/) || [])[1] ?? null,
      names: followIncludes ? namesIn(m[2]) : new Set([...m[2].matchAll(NAME)].map(n => n[1])),
    });
  }
  return out;
}

/** What a form posts to, comparably: a route name, a script, or "self". */
function target(action) {
  if (action === null || action.trim() === '' || /PHP_SELF|\{\$smarty\.server/.test(action)) return 'self';
  const route = action.match(/routePath\(\s*'([^']+)'/);
  if (route) return `route:${route[1]}`;
  const script = action.match(/([a-z]+\.php)/i);
  return script ? `script:${script[1].toLowerCase()}` : `other:${action.slice(0, 40)}`;
}

const pairs = [];
for (const f of fs.readdirSync(STOCK.client).filter(f => f.endsWith('.tpl'))) {
  const ours = walk(path.join(REPO, 'hadrian/templates/hadrian/core/pages', f.slice(0, -4)));
  if (ours.length) pairs.push([f.slice(0, -4), path.join(STOCK.client, f), ours]);
}
for (const f of fs.readdirSync(STOCK.cart).filter(f => f.endsWith('.tpl'))) {
  const ours = path.join(REPO, 'hadrian_cart', f);
  if (fs.existsSync(ours)) pairs.push([`cart/${f.slice(0, -4)}`, path.join(STOCK.cart, f), [ours]]);
}

const problems = [], notes = [];
let compared = 0;
for (const [page, stockFile, ourFiles] of pairs) {
  const theirs = forms(strip(fs.readFileSync(stockFile, 'utf8')), false).filter(t => t.ids.length);
  const mine = ourFiles.flatMap(f => forms(strip(fs.readFileSync(f, 'utf8')), true));
  for (const t of theirs) {
    const key = `${page}#${t.ids[0]}`;
    if (ACCEPTED[key]) continue;
    const m = mine.find(x => x.ids.includes(t.ids[0]))
      || (target(t.action) !== 'self' && mine.find(x => target(x.action) === target(t.action)));
    if (!m) { notes.push(`${key}: no counterpart in Hadrian's template (restructured - verify by a flow)`); continue; }
    compared++;
    const a = target(t.action), b = target(m.action);
    if (a !== b && a !== 'self') problems.push(`${key}: posts to ${b}, WHMCS's posts to ${a}`);
    const missing = [...t.names].filter(n => !IGNORE.has(n) && !m.names.has(n));
    if (missing.length) problems.push(`${key}: missing field(s) WHMCS reads: ${missing.join(', ')}`);
  }
}

for (const n of notes) console.log('note  ' + n);
for (const p of problems) console.error('FAIL  ' + p);
console.log(problems.length
  ? `FAILED: ${problems.length} form contract problem(s) across ${compared} forms compared with WHMCS's own`
  : `ok: ${compared} forms post the same route and fields as WHMCS's own (${notes.length} restructured, see notes)`);
process.exit(problems.length ? 1 : 0);
