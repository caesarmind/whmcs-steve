#!/usr/bin/env node
/**
 * migrate-widths.mjs
 *
 * Replaces hardcoded container `max-width: Npx` DECLARATIONS with the
 * --w-* container-scale tokens (core-theme.css), so the admin's single
 * "Maximum width" number moves every page-level container in proportion
 * instead of only the outer content column.
 *
 * Mirrors migrate-typography.mjs, with three deliberate differences:
 *
 *  1. EXACT MATCHES ONLY. Typography snaps to the nearest step; widths do not.
 *     Snapping 980px -> 1024px is a real visual change on a live site, so
 *     off-scale values are REPORTED for a human call, never rewritten.
 *
 *  2. DECLARATIONS ONLY, never @media conditions. `@media (max-width: 900px)`
 *     is a breakpoint, not a container -- tokenising it would break responsive
 *     behaviour outright (and a var() is not even valid in a media condition).
 *     The trailing `;` in the pattern is what separates the two: declarations
 *     end in a semicolon, media conditions end in `)`.
 *
 *  3. Values BELOW 880px are out of scope entirely. Those are measure
 *     constraints (forms, modals, prose columns) that must NOT scale.
 *
 * Usage:
 *   node hadrian/scripts/migrate-widths.mjs          # dry run, prints a plan
 *   node hadrian/scripts/migrate-widths.mjs --write  # apply
 */
import fs from 'node:fs';
import path from 'node:path';

const ROOT = 'templates/hadrian/assets/css';
const WRITE = process.argv.includes('--write');

// Only values that resolve EXACTLY to a token at the default --w-base (1120px).
const EXACT = {
  1200: '--w-wide',
  1120: '--w-base',
  1024: '--w-prose',
  880:  '--w-narrow',
};

// theme.css is gitignored and not deployed - editing it is pure noise.
const SKIP = new Set(['theme.css']);

const files = [];
(function walk(dir) {
  for (const e of fs.readdirSync(dir, { withFileTypes: true })) {
    const p = path.join(dir, e.name);
    if (e.isDirectory()) walk(p);
    else if (e.name.endsWith('.css') && !SKIP.has(e.name)) files.push(p);
  }
})(ROOT);

// max-width: Npx ;   (declaration form - trailing semicolon is load-bearing)
//
// (?<!-) is NOT optional. Without it this also matches the token DEFINITION
// `--content-max-width: 1120px;` and rewrites it to var(--w-base) -- which,
// since --w-base is defined as var(--content-max-width), is a circular
// reference that CSS invalidates, resolving the entire container scale to
// `none`. That happened on the first run and silently broke every tokenised
// width; the lookbehind is what makes the pattern mean "the max-width
// property", not "any property whose name ends in max-width".
const DECL = /(?<!-)(max-width:\s*)(\d{3,4})(px\s*;)/g;

let replaced = 0, skipped = 0, touched = 0;
const outliers = new Map();

for (const f of files) {
  const src = fs.readFileSync(f, 'utf8');
  let hits = 0;
  const out = src.replace(DECL, (m, pre, num, post) => {
    const n = Number(num);
    if (n < 880) return m;                       // measure width - leave alone
    const tok = EXACT[n];
    if (!tok) {                                  // off-scale - report, do not touch
      skipped++;
      const k = `${n}px`;
      outliers.set(k, (outliers.get(k) || []).concat(f));
      return m;
    }
    hits++; replaced++;
    return `${pre}var(${tok})${post.replace(/^px/, '')}`;
  });
  if (hits) {
    touched++;
    if (WRITE) fs.writeFileSync(f, out);
    console.log(`${WRITE ? 'wrote' : 'would write'}  ${hits.toString().padStart(3)}  ${f}`);
  }
}

console.log(`\n${WRITE ? 'Replaced' : 'Would replace'} ${replaced} declaration(s) across ${touched} file(s).`);

if (outliers.size) {
  console.log(`\nLEFT ALONE - ${skipped} off-scale value(s) needing a human call:`);
  for (const [val, fs_] of [...outliers].sort((a, b) => b[1].length - a[1].length)) {
    console.log(`  ${val.padEnd(8)} x${fs_.length}`);
    [...new Set(fs_)].forEach(f => console.log(`      ${f}`));
  }
  console.log('\n  Each is within ~10% of a token. Snapping them IS a visual change,');
  console.log('  so decide per value rather than letting a script guess.');
}
if (!WRITE) console.log('\nDry run. Re-run with --write to apply.');
