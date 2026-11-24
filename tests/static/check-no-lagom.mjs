#!/usr/bin/env node
// Hadrian's add-on products are written from scratch. This check fails when a
// product folder carries text that could only have come from Lagom's code.
//
// Lagom is read as a reference for behaviour: its files (decoded or shipped)
// stay outside the repo and nothing is pasted from them. Two rule sets:
//
//   identifiers  Lagom's namespace, table prefix, constants and data keys.
//                Checked in every product folder below.
//   name         the words "Lagom", "RSThemes" or "RS Studio" anywhere, even
//                in a comment. Checked in STRICT folders, whose source
//                customers read.
//
// Usage:
//   node tests/static/check-no-lagom.mjs            scan the product folders
//   node tests/static/check-no-lagom.mjs <folder>   scan one folder, strict
//
// Files are read from disk, not from `git ls-files`: a product folder is
// untracked for most of its development, which is when a paste would land.

import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const REPO_ROOT = path.dirname(path.dirname(path.dirname(fileURLToPath(import.meta.url))));

// Folder -> strict? Add each new product here when its folder is created.
const PRODUCTS = [
  { dir: 'hadrian_builder', strict: true },
  { dir: 'hadrian_email', strict: false },
];

const IDENTIFIERS = [
  [/rsthemes_/i, 'Lagom table prefix'],
  [/RSThemes\\/, 'Lagom namespace'],
  [/RSTHEMES_DIR/, 'Lagom constant'],
  [/rsstudio/i, 'RS Studio domain or name'],
  [/lagom2|lagompage|lagom-cms/i, 'Lagom template or asset name'],
  [/custom_page_template|pageurlshort/, 'Lagom page routing name'],
  [/predefined_section|expired_promo/, 'Lagom section data key'],
  [/group_forced|container_collapse/, 'Lagom section config key'],
  [/pages_sections_cache|page_sections_lang/, 'Lagom table name'],
];
const NAME = [[/lagom|rsthemes|rs\s?studio/i, 'mentions Lagom by name']];

const TEXT_EXT = new Set(['.php', '.tpl', '.js', '.mjs', '.css', '.scss', '.json', '.md', '.html', '.txt', '.sql', '.xml', '.yml', '.yaml', '']);
const SKIP_DIR = new Set(['node_modules', 'vendor', '.git']);

function walk(dir, out = []) {
  for (const e of fs.readdirSync(dir, { withFileTypes: true })) {
    const p = path.join(dir, e.name);
    if (e.isDirectory()) { if (!SKIP_DIR.has(e.name)) walk(p, out); }
    else if (TEXT_EXT.has(path.extname(e.name).toLowerCase())) out.push(p);
  }
  return out;
}

const arg = process.argv[2];
const targets = arg
  ? [{ dir: path.resolve(arg), strict: true }]
  : PRODUCTS.map(p => ({ ...p, dir: path.join(REPO_ROOT, p.dir) }));

const bad = [];
let scanned = 0;
const notes = [];

for (const t of targets) {
  const label = path.relative(REPO_ROOT, t.dir) || t.dir;
  if (!fs.existsSync(t.dir)) { notes.push(`${label}: not created yet`); continue; }
  const rules = t.strict ? [...IDENTIFIERS, ...NAME] : IDENTIFIERS;
  for (const file of walk(t.dir)) {
    scanned++;
    fs.readFileSync(file, 'utf8').split('\n').forEach((line, i) => {
      const hit = rules.find(([re]) => re.test(line));
      if (hit) bad.push(`${path.relative(REPO_ROOT, file).replace(/\\/g, '/')}:${i + 1}  ${hit[1]}  ${line.trim().slice(0, 70)}`);
    });
  }
}

for (const b of bad.slice(0, 40)) console.log('FAIL ' + b);
if (bad.length > 40) console.log(`... and ${bad.length - 40} more`);
for (const n of notes) console.log('note ' + n);
console.log(`${scanned} file(s) scanned; ${bad.length} line(s) carry Lagom text`);
process.exit(bad.length ? 1 : 0);
