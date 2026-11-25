#!/usr/bin/env node
// Accessibility markup in the client-facing templates, read from source.
//
// Plan: docs/accessibility-hadrian-plan.md (phase 0). The a11y tier (axe in a
// browser) sees only the pages and states the suite visits; this sees every
// template, including branches no test reaches. Four heuristics:
//
//   icon-only-control   a <button> or <a> whose content is only icons (svg, <i>,
//                       an image with empty alt) and that has no aria-label,
//                       aria-labelledby or title: a screen reader announces
//                       "button" and nothing else (WCAG 4.1.2, 2.4.4)
//   literal-name        aria-label="..." or alt="..." written in English in the
//                       template instead of coming from a language file, so it
//                       never translates (WCAG 3.1.2 for every other language)
//   svg-not-hidden      an inline <svg> with no aria-hidden, no role and no
//                       aria-label: decorative icons must be hidden, meaningful
//                       ones named (WCAG 1.1.1)
//   unlabelled-field    an input, select or textarea with no <label for>, no
//                       wrapping <label> and no aria-label(ledby). A placeholder
//                       is not a label (WCAG 1.3.1, 3.3.2, 4.1.2)
//   icon-only-label     a <label> whose content is only an icon. The field is
//                       "labelled" on paper but its name falls back to the
//                       placeholder, which axe accepts and a person cannot see
//                       once they type (the checkout's .field-icon labels)
//
// These are regexes over Smarty source, so a few hits are wrong (a label that
// lives in an included file, an attribute with a ">" in a Smarty condition).
// That is why the result is compared with a baseline instead of required to be
// zero: tests/static/a11y-markup-baseline.json holds file -> rule -> count for
// what exists today. The check fails when a file gains a finding, and also when
// one drops below its baseline, so each fix shrinks the baseline in the same
// change and nothing can quietly grow back.
//
//   node tests/static/check-a11y-markup.mjs            compare with the baseline
//   node tests/static/check-a11y-markup.mjs --update   rewrite the baseline
//   node tests/static/check-a11y-markup.mjs --list <rule> [file]   print each hit

import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const REPO_ROOT = path.dirname(path.dirname(path.dirname(fileURLToPath(import.meta.url))));
const BASELINE = path.join(REPO_ROOT, 'tests', 'static', 'a11y-markup-baseline.json');

// Client-facing templates only. The admin addon's screens are a back-office
// tool and out of scope (plan, "Target").
const ROOTS = [
  'hadrian/templates/hadrian',
  'hadrian_cart',
  'hadrian_builder/modules/addons/HadrianBuilder/sections',
];
const SKIP_DIR = new Set(['_archive', 'node_modules', 'vendor']);

function walk(dir, out = []) {
  for (const e of fs.readdirSync(dir, { withFileTypes: true })) {
    const p = path.join(dir, e.name);
    if (e.isDirectory()) { if (!SKIP_DIR.has(e.name)) walk(p, out); }
    else if (e.name.endsWith('.tpl')) out.push(p);
  }
  return out;
}

const lineOf = (src, i) => src.slice(0, i).split('\n').length;
const attr = (tag, name) => new RegExp(`\\s${name}\\s*=`, 'i').test(tag);
// Smarty that renders nothing visible: logic, comments, captures.
const SMARTY_LOGIC = /\{\/?(?:if|else|elseif|foreach|foreachelse|section|assign|capture|strip|literal)\b[^}]*\}|\{\*[\s\S]*?\*\}/g;

function scan(src) {
  const hits = { 'icon-only-control': [], 'literal-name': [], 'svg-not-hidden': [], 'unlabelled-field': [], 'icon-only-label': [] };
  // Smarty comments can hold whole commented-out blocks of markup.
  const code = src.replace(/\{\*[\s\S]*?\*\}/g, m => m.replace(/[^\n]/g, ' '));

  // icon-only-control
  for (const m of code.matchAll(/<(button|a)\b([^>]*)>([\s\S]*?)<\/\1\s*>/gi)) {
    const [, , attrs, inner] = m;
    if (attr(attrs, 'aria-label') || attr(attrs, 'aria-labelledby') || attr(attrs, 'title')) continue;
    if (!/<svg\b|<i\b|<img\b/i.test(inner)) continue;
    const left = inner
      .replace(/<svg\b[\s\S]*?<\/svg>/gi, '')
      .replace(/<i\b[^>]*>\s*<\/i>/gi, '')
      .replace(/<img\b[^>]*\balt\s*=\s*""[^>]*>/gi, '')
      .replace(SMARTY_LOGIC, '')
      .replace(/<(?!img\b)[^>]+>/gi, '')
      .trim();
    // Anything left (text, a {$variable}, an image with real alt) can name it.
    if (left === '') hits['icon-only-control'].push([lineOf(code, m.index), m[0].slice(0, 90)]);
  }

  // icon-only-label
  for (const m of code.matchAll(/<label\b([^>]*)>([\s\S]*?)<\/label\s*>/gi)) {
    const inner = m[2];
    if (!/<svg\b|<i\b/i.test(inner) || /<(input|select|textarea)\b/i.test(inner)) continue;
    const left = inner.replace(/<svg\b[\s\S]*?<\/svg>/gi, '').replace(/<i\b[^>]*>\s*<\/i>/gi, '')
      .replace(SMARTY_LOGIC, '').replace(/<[^>]+>/g, '').trim();
    if (left === '') hits['icon-only-label'].push([lineOf(code, m.index), m[0].slice(0, 90)]);
  }

  // literal-name
  for (const m of code.matchAll(/\s(aria-label|alt)\s*=\s*"([^"]*)"/gi)) {
    const v = m[2];
    if (v.includes('{') || !/[a-z]/i.test(v)) continue;
    hits['literal-name'].push([lineOf(code, m.index), `${m[1]}="${v.slice(0, 60)}"`]);
  }

  // svg-not-hidden
  for (const m of code.matchAll(/<svg\b([^>]*)>/gi)) {
    const a = m[1];
    if (attr(a, 'aria-hidden') || attr(a, 'role') || attr(a, 'aria-label') || attr(a, 'aria-labelledby')) continue;
    hits['svg-not-hidden'].push([lineOf(code, m.index), m[0].slice(0, 70)]);
  }

  // unlabelled-field
  const fors = new Set([...code.matchAll(/<label\b[^>]*\sfor\s*=\s*"([^"]+)"/gi)].map(m => m[1]));
  for (const m of code.matchAll(/<(input|select|textarea)\b([^>]*)>/gi)) {
    const [, tag, a] = m;
    if (tag.toLowerCase() === 'input') {
      const type = (a.match(/\stype\s*=\s*"([^"]*)"/i) || [, 'text'])[1].toLowerCase();
      if (['hidden', 'submit', 'button', 'image', 'reset'].includes(type)) continue;
    }
    if (attr(a, 'aria-label') || attr(a, 'aria-labelledby')) continue;
    const idv = (a.match(/\sid\s*=\s*"([^"]+)"/i) || [])[1];
    if (idv && fors.has(idv)) continue;
    // Inside an open <label>...</label>?
    const before = code.slice(0, m.index);
    const opens = (before.match(/<label\b/gi) || []).length, closes = (before.match(/<\/label\s*>/gi) || []).length;
    if (opens > closes) continue;
    hits['unlabelled-field'].push([lineOf(code, m.index), m[0].slice(0, 90)]);
  }
  return hits;
}

// ------------------------------------------------------------------ run
const argv = process.argv.slice(2);
const files = ROOTS.flatMap(r => fs.existsSync(path.join(REPO_ROOT, r)) ? walk(path.join(REPO_ROOT, r)) : []);
const found = {};
const detail = {};
for (const f of files) {
  const rel = path.relative(REPO_ROOT, f).replace(/\\/g, '/');
  const hits = scan(fs.readFileSync(f, 'utf8'));
  for (const [rule, list] of Object.entries(hits)) if (list.length) {
    (found[rel] ||= {})[rule] = list.length;
    (detail[rel] ||= {})[rule] = list;
  }
}
const totals = {};
for (const rules of Object.values(found)) for (const [r, n] of Object.entries(rules)) totals[r] = (totals[r] || 0) + n;
const totalLine = Object.entries(totals).map(([r, n]) => `${r} ${n}`).join(', ');

if (argv[0] === '--list') {
  const [, rule, only] = argv;
  for (const [file, rules] of Object.entries(detail)) {
    if (only && !file.includes(only)) continue;
    for (const [line, text] of rules[rule] || []) console.log(`${file}:${line}  ${text.replace(/\s+/g, ' ')}`);
  }
  process.exit(0);
}

if (argv[0] === '--update') {
  const sorted = Object.fromEntries(Object.entries(found).sort(([a], [b]) => a.localeCompare(b)).map(([f, r]) => [f, Object.fromEntries(Object.entries(r).sort())]));
  fs.writeFileSync(BASELINE, JSON.stringify({
    note: 'Accessibility markup findings accepted for now: file -> rule -> count. Written by `node tests/static/check-a11y-markup.mjs --update`; it may only shrink.',
    totals, files: sorted,
  }, null, 2) + '\n');
  console.log(`baseline written: ${files.length} templates, ${totalLine}`);
  process.exit(0);
}

let base;
try { base = JSON.parse(fs.readFileSync(BASELINE, 'utf8')).files; }
catch { console.log(`FAIL no baseline at ${path.relative(REPO_ROOT, BASELINE)} - run with --update`); process.exit(1); }

const worse = [], better = [];
for (const file of new Set([...Object.keys(found), ...Object.keys(base)])) {
  const now = found[file] || {}, was = base[file] || {};
  for (const rule of new Set([...Object.keys(now), ...Object.keys(was)])) {
    const n = now[rule] || 0, b = was[rule] || 0;
    if (n > b) {
      const where = (detail[file]?.[rule] || []).slice(0, 3).map(([l, t]) => `\n      line ${l}: ${t.replace(/\s+/g, ' ')}`).join('');
      worse.push(`${file}: ${rule} ${b} -> ${n}${where}`);
    } else if (n < b) better.push(`${file}: ${rule} ${b} -> ${n}`);
  }
}
for (const w of worse) console.log('FAIL ' + w);
for (const b of better) console.log('FIXED ' + b + '  (shrink the baseline: --update)');
console.log(`${files.length} templates; ${totalLine}; ${worse.length} worse, ${better.length} better than the baseline`);
process.exit(worse.length || better.length ? 1 : 0);
