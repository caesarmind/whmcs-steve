#!/usr/bin/env node
/**
 * migrate-colors.mjs
 *
 * Replaces hardcoded color literals (hex + rgb/rgba) across the theme's
 * hand-authored CSS with `var(--token)` references, mapping each value to the
 * design-system token whose LIGHT default equals it (core-theme.css :root).
 *
 * Why it's safe: every token's light default == the value it replaces, so
 * light mode renders byte-identically; the only change is that the color
 * becomes admin-editable (Styles > Colors) and now adapts in dark mode.
 *
 * Idempotent: never matches inside an existing var(), only standalone literals
 * in value position (lookbehind on : , ( whitespace; skips selectors/data-URIs).
 *
 * Usage:
 *   node migrate-colors.mjs            # dry-run: report mapped + unmapped
 *   node migrate-colors.mjs --write    # apply replacements
 *   node migrate-colors.mjs --unmapped # dry-run, list only the distinct
 *                                      # unmapped colors (new-token candidates)
 */
import { readFileSync, writeFileSync, readdirSync, statSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import { dirname, join, resolve, basename } from 'node:path';

const __dirname = dirname(fileURLToPath(import.meta.url));
const CSS_DIR = resolve(__dirname, '../templates/hadrian/assets/css');

const args = process.argv.slice(2);
const WRITE = args.includes('--write');
const UNMAPPED_ONLY = args.includes('--unmapped');

// Build artifacts (compiled from SCSS) + the unused/gitignored bundle — skip.
const SKIP = new Set(['theme.css', 'site.css']);

/**
 * value (normalized) -> token name. LIGHT defaults from core-theme.css :root.
 * Ambiguous values (same hex for >1 token) resolve to the canonical/primary
 * token; light-mode output is identical either way, so this only decides which
 * panel control governs it + its dark-mode value.
 */
const TOKEN_MAP = {
  '#fbfbfd': 'color-bg',
  '#ffffff': 'color-surface',
  '#f5f5f7': 'color-surface-secondary',
  '#fafafa': 'color-surface-tertiary',
  '#e8e8ed': 'color-border',            // also --sidebar-icon-bg
  '#f0f0f5': 'color-border-light',
  '#1d1d1f': 'color-text-primary',
  '#6e6e73': 'color-text-secondary',    // also --color-gray-text
  '#86868b': 'color-text-tertiary',
  '#aeaeb2': 'color-text-quaternary',
  '#0071e3': 'color-accent',            // also link-hover, blue-text
  '#0077ed': 'color-accent-hover',
  '#0066cc': 'color-link',
  '#30d158': 'color-green',
  '#248a3d': 'color-green-text',
  '#ff9f0a': 'color-orange',
  '#c27400': 'color-orange-text',
  '#ff3b30': 'color-red',
  '#d70015': 'color-red-text',
  'rgba(0,113,227,0.08)': 'color-accent-light',   // also blue-bg
  'rgba(0,0,0,0.04)': 'color-border-card',        // also sidebar-item-hover
  'rgba(0,0,0,0.06)': 'sidebar-item-active',
  'rgba(48,209,88,0.1)': 'color-green-bg',
  'rgba(255,159,10,0.1)': 'color-orange-bg',
  'rgba(255,59,48,0.1)': 'color-red-bg',
  'rgba(142,142,147,0.12)': 'color-gray-bg',
  'rgba(246,246,248,0.8)': 'sidebar-bg',
  'rgba(251,251,253,0.72)': 'topbar-bg',
};

// Normalize a color literal for map lookup: lowercase, expand #rgb -> #rrggbb,
// collapse rgb/rgba whitespace + trailing-zero alpha (0.10 -> 0.1, .08 -> 0.08).
function normalize(raw) {
  let s = raw.trim().toLowerCase();
  if (s[0] === '#') {
    let h = s.slice(1);
    if (h.length === 3) h = h[0] + h[0] + h[1] + h[1] + h[2] + h[2];
    return '#' + h;
  }
  const m = s.match(/^rgba?\(([^)]*)\)$/);
  if (m) {
    const parts = m[1].split(',').map(p => p.trim());
    const nums = parts.map((p, i) => (i === 3 ? String(parseFloat(p)) : String(parseInt(p, 10))));
    return (nums.length === 4 ? 'rgba(' : 'rgb(') + nums.join(',') + ')';
  }
  return s;
}

// Color literals in value position: hex (3/4/6/8) or rgb()/rgba().
// Lookbehind keeps us off ID selectors / data-URIs; not preceded by a word char or %.
const HEX = /(?<=[\s:,(])#[0-9a-fA-F]{3,8}\b(?!\s*\{)/g;
const FUNC = /(?<=[\s:,(])rgba?\([^)]*\)/gi;

function walk(dir) {
  const out = [];
  for (const name of readdirSync(dir)) {
    const p = join(dir, name);
    if (statSync(p).isDirectory()) out.push(...walk(p));
    else if (name.endsWith('.css') && !SKIP.has(name)) out.push(p);
  }
  return out;
}

const files = walk(CSS_DIR);
const mappedTally = {};   // "#1d1d1f -> color-text-primary" -> count
const unmappedTally = {}; // "#123456" -> count
let filesChanged = 0;
let totalRepl = 0;

// Is the color at `offset` the VALUE of a custom-property definition
// (`--foo: <color>`)? If so we must NOT tokenize it — that would create a
// circular `--foo: var(--foo)`. Scan back to the start of the declaration
// (previous { } or ;) and check whether the property name begins with `--`.
function inCustomPropDef(str, offset) {
  let i = offset;
  while (i > 0 && str[i - 1] !== '{' && str[i - 1] !== '}' && str[i - 1] !== ';') i--;
  return /(^|[\s;{])--[\w-]+\s*:/.test(str.slice(i, offset));
}

function processColor(raw, offset, str) {
  if (inCustomPropDef(str, offset)) return raw; // leave token DEFINITIONS intact
  const norm = normalize(raw);
  const token = TOKEN_MAP[norm];
  if (!token) {
    unmappedTally[norm] = (unmappedTally[norm] || 0) + 1;
    return raw;
  }
  mappedTally[`${norm} -> --${token}`] = (mappedTally[`${norm} -> --${token}`] || 0) + 1;
  totalRepl++;
  return `var(--${token})`;
}

for (const file of files) {
  const original = readFileSync(file, 'utf8');
  const out = original
    .replace(FUNC, (m, off, str) => processColor(m, off, str))
    .replace(HEX, (m, off, str) => processColor(m, off, str));
  if (out !== original) {
    filesChanged++;
    if (WRITE) writeFileSync(file, out, 'utf8');
  }
}

const sortEntries = o => Object.entries(o).sort((a, b) => b[1] - a[1]);
console.log(`\n=== migrate-colors (${WRITE ? 'WRITE' : 'DRY-RUN'}) ===`);
console.log(`CSS dir: ${CSS_DIR}`);
console.log(`Files scanned: ${files.length}, files changed: ${filesChanged}, mapped replacements: ${totalRepl}`);

const unmapped = sortEntries(unmappedTally);
const unmappedTotal = unmapped.reduce((a, [, c]) => a + c, 0);
console.log(`Distinct UNMAPPED colors: ${unmapped.length} (${unmappedTotal} occurrences)\n`);

if (!UNMAPPED_ONLY) {
  console.log('-- mapped (count) --');
  for (const [k, c] of sortEntries(mappedTally)) console.log(`  ${String(c).padStart(4)}  ${k}`);
}
console.log('\n-- UNMAPPED distinct colors (new-token candidates, count) --');
for (const [k, c] of unmapped) console.log(`  ${String(c).padStart(4)}  ${k}`);
if (!WRITE) console.log('\n(dry-run — no files written; pass --write to apply mapped replacements)');
