#!/usr/bin/env node
/**
 * Assert every colors.php default equals the literal declared in
 * apple-theme.css, for BOTH scopes.
 *
 * Why this exists. The admin shows a token's schema default as the baseline and
 * only persists values that DIFFER from it. So a default that drifts from the
 * CSS breaks the panel in both directions at once: a buyer's edit that happens
 * to match the real CSS value is silently discarded as "unchanged", and a
 * value equal to the stale default is stored as an override that changes
 * nothing. Neither failure is visible in the UI -- you find out from a support
 * ticket. colors.php's own header has always said the two must mirror; this is
 * the first thing that checks it.
 *
 * This is precisely the check Lagom never wrote: their schema IS the CSS
 * comment, so they cannot desync, but they also have no validator and a stray
 * typo in an annotation silently deletes a control.
 *
 * Usage: node scripts/check-color-defaults.mjs   (exit 1 on any mismatch)
 */
import { readFileSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import { dirname, join } from 'node:path';

const ROOT = join(dirname(fileURLToPath(import.meta.url)), '..');
const CSS = join(ROOT, 'templates/hadrian/assets/css/apple-theme.css');
const PHP = join(ROOT, 'templates/hadrian/core/config/colors.php');

const css = readFileSync(CSS, 'utf8');
const php = readFileSync(PHP, 'utf8');

/** Pull one declaration block by its opening selector. */
function block(selector) {
  const i = css.indexOf(selector);
  if (i === -1) throw new Error(`selector not found: ${selector}`);
  const open = css.indexOf('{', i);
  let depth = 0;
  for (let j = open; j < css.length; j++) {
    if (css[j] === '{') depth++;
    else if (css[j] === '}') { depth--; if (!depth) return css.slice(open + 1, j); }
  }
  throw new Error(`unbalanced block: ${selector}`);
}

/** token -> literal, for one block. Comments stripped so they cannot match. */
function tokens(text) {
  const out = new Map();
  const clean = text.replace(/\/\*[\s\S]*?\*\//g, '');
  for (const m of clean.matchAll(/(--[a-z0-9_-]+)\s*:\s*([^;]+);/g)) {
    out.set(m[1], m[2].trim());
  }
  return out;
}

const light = tokens(block(':root {'));
const dark = tokens(block('html[data-theme="dark"] {'));

// Parse the schema rows. Deliberately regex over the PHP rather than shelling
// out to php -- this runs in CI where PHP may not exist.
const rows = [...php.matchAll(
  /\['var'\s*=>\s*'(--[a-z0-9_-]+)'.*?'light'\s*=>\s*'([^']*)'\s*,\s*'dark'\s*=>\s*'([^']*)'/g,
)];

if (!rows.length) {
  console.error('FAIL  parsed zero tokens from colors.php - the row shape changed');
  process.exit(1);
}

const norm = (s) => s.replace(/\s+/g, '').toLowerCase();

/**
 * Resolve a value through var() chains within a scope.
 *
 * Many tokens are declared as `var(--other)` on purpose -- the whole sidebar
 * ink set defaults to the page token it replaced, which is what makes it a
 * no-op and what makes dark mode re-derive for free. Comparing the literal
 * text would flag every one of those, so follow the chain to the colour a
 * browser would actually compute. `scope` is consulted first so a dark
 * redeclaration wins, then light, matching how the cascade resolves on <html>.
 */
function resolve(value, scope, depth = 0) {
  if (depth > 10) return value; // cycle guard
  // The fallback may itself contain parens -- var(--x, rgba(0,0,0,.15)) -- so it
  // is captured greedily against the trailing ')'. A non-greedy [^)]+ silently
  // failed to match those and reported the raw var() text as a mismatch.
  const m = /^var\(\s*(--[a-z0-9_-]+)\s*(?:,\s*(.+))?\)$/s.exec(value.trim());
  if (!m) return value;
  // A token declared ONLY inside @supports (the --_sb-* tint set) is absent from
  // the blocks we parsed, so we take the fallback -- which is exactly what a
  // browser does while --sidebar-color is unset, since each derived token is
  // then invalid-at-computed-value-time. Same answer, and the reason it is the
  // same answer is the whole point of the tint design.
  const next = scope.get(m[1]) ?? light.get(m[1]) ?? m[2];
  return next === undefined ? value : resolve(next, scope, depth + 1);
}

let fail = 0;
const missing = [];
const skipped = [];

for (const [, name, wantLight, wantDark] of rows) {
  // A token with an EMPTY default is intentionally undeclared in the CSS. That
  // is the --sidebar-color contract: every derived sidebar token references it,
  // so its absence is what makes the tint feature off-by-default. Asserting it
  // were declared would break the very mechanism.
  if (wantLight === '' && wantDark === '') { skipped.push(name); continue; }
  const rawLight = light.get(name);
  if (rawLight === undefined) { missing.push(name); continue; }
  const gotLight = resolve(rawLight, light);
  // Not every token is redeclared in the dark block; those inherit the :root
  // declaration, which may itself be a var() that resolves differently there.
  const gotDark = resolve(dark.get(name) ?? rawLight, dark);
  if (norm(gotLight) !== norm(wantLight)) {
    console.error(`FAIL  ${name} light: colors.php '${wantLight}' vs CSS '${gotLight}'`);
    fail++;
  }
  if (norm(gotDark) !== norm(wantDark)) {
    console.error(`FAIL  ${name} dark: colors.php '${wantDark}' vs CSS '${gotDark}'`);
    fail++;
  }
}

for (const name of missing) {
  console.error(`FAIL  ${name} is in colors.php but declared nowhere in apple-theme.css :root`);
  fail++;
}

console.log(`${rows.length - skipped.length} tokens checked against both scopes; ${fail} mismatch(es).`
  + (skipped.length ? ` ${skipped.length} intentionally undeclared: ${skipped.join(', ')}.` : ''));
process.exit(fail ? 1 : 0);
