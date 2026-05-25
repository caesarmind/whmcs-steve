#!/usr/bin/env node
/**
 * migrate-typography.mjs
 *
 * Replaces hardcoded `font-size: Npx` and `font-weight: NNN` across the theme
 * CSS with `var(--token)` references, snapping each value to the nearest step
 * of the canonical scale defined in apple-theme.css :root.
 *
 * Idempotent: the regexes only match numeric literals, never existing var().
 * Line-heights are intentionally left as unitless ratios.
 *
 * Usage:
 *   node migrate-typography.mjs                 # dry-run: report only
 *   node migrate-typography.mjs --write         # apply size + weight
 *   node migrate-typography.mjs --write --prop=weight   # weights only
 *   node migrate-typography.mjs --prop=size     # dry-run, sizes only
 */
import { readFileSync, writeFileSync, readdirSync, statSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import { dirname, join, resolve } from 'node:path';

const __dirname = dirname(fileURLToPath(import.meta.url));
const CSS_DIR = resolve(__dirname, '../templates/mytheme/assets/css');

const args = process.argv.slice(2);
const WRITE = args.includes('--write');
const propArg = (args.find(a => a.startsWith('--prop=')) || '--prop=both').split('=')[1];

// Canonical snap targets: px -> token. The script snaps any font-size to the
// nearest of these (ties round up to the larger step).
const SIZE_TARGETS = [
  [11, 'text-xs'], [12, 'text-sm'], [13, 'text-base'], [14, 'text-md'],
  [15, 'text-lg'], [17, 'text-xl'], [18, 'text-h6'], [20, 'text-2xl'],
  [24, 'text-3xl'], [26, 'text-h4'], [36, 'text-h3'], [40, 'text-h2'],
  [48, 'text-h1'], [56, 'text-display-sm'], [72, 'text-display'],
  [96, 'text-display-lg'], [120, 'text-display-xl'],
];
const WEIGHT_TARGETS = [
  [300, 'fw-light'], [400, 'fw-normal'], [500, 'fw-medium'],
  [600, 'fw-semibold'], [700, 'fw-bold'], [900, 'fw-black'],
];

function nearest(value, targets) {
  let best = targets[0];
  let bestDiff = Infinity;
  for (const t of targets) {
    const diff = Math.abs(t[0] - value);
    // ties (diff equal) round up to the larger px target
    if (diff < bestDiff || (diff === bestDiff && t[0] > best[0])) {
      best = t; bestDiff = diff;
    }
  }
  return best;
}

function walk(dir) {
  const out = [];
  for (const name of readdirSync(dir)) {
    const p = join(dir, name);
    if (statSync(p).isDirectory()) out.push(...walk(p));
    else if (name.endsWith('.css')) out.push(p);
  }
  return out;
}

const files = walk(CSS_DIR);
const sizeTally = {};   // "13px->text-base" -> count
const weightTally = {};
let filesChanged = 0;
let totalRepl = 0;

for (const file of files) {
  let css = readFileSync(file, 'utf8');
  const before = css;

  if (propArg === 'size' || propArg === 'both') {
    css = css.replace(/font-size:\s*(\d+(?:\.\d+)?)px/g, (m, num) => {
      const [px, token] = nearest(parseFloat(num), SIZE_TARGETS);
      const key = `${num}px -> --${token} (${px}px)`;
      sizeTally[key] = (sizeTally[key] || 0) + 1;
      totalRepl++;
      return `font-size: var(--${token})`;
    });
  }
  if (propArg === 'weight' || propArg === 'both') {
    css = css.replace(/font-weight:\s*(\d{3})\b/g, (m, num) => {
      const [w, token] = nearest(parseInt(num, 10), WEIGHT_TARGETS);
      const key = `${num} -> --${token}`;
      weightTally[key] = (weightTally[key] || 0) + 1;
      totalRepl++;
      return `font-weight: var(--${token})`;
    });
  }

  if (css !== before) {
    filesChanged++;
    if (WRITE) writeFileSync(file, css, 'utf8');
  }
}

const sortEntries = o => Object.entries(o).sort((a, b) => b[1] - a[1]);
console.log(`\n=== migrate-typography (${WRITE ? 'WRITE' : 'DRY-RUN'}, prop=${propArg}) ===`);
console.log(`CSS dir: ${CSS_DIR}`);
console.log(`Files scanned: ${files.length}, files changed: ${filesChanged}, replacements: ${totalRepl}\n`);
if (propArg !== 'weight') {
  console.log('-- font-size snaps (count) --');
  for (const [k, c] of sortEntries(sizeTally)) console.log(`  ${String(c).padStart(4)}  ${k}`);
}
if (propArg !== 'size') {
  console.log('\n-- font-weight snaps (count) --');
  for (const [k, c] of sortEntries(weightTally)) console.log(`  ${String(c).padStart(4)}  ${k}`);
}
if (!WRITE) console.log('\n(no files written — pass --write to apply)');
