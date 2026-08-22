#!/usr/bin/env node
/**
 * Assert every admin-panel schema default equals the literal declared in the
 * CSS -- for colors.php in BOTH scopes, and for the seven size/shape schemas in
 * the :root scope they emit into.
 *
 * Why this exists. The admin shows a token's schema default as the baseline and
 * only persists values that DIFFER from it. So a default that drifts from the
 * CSS breaks the panel in both directions at once: a buyer's edit that happens
 * to match the real CSS value is silently discarded as "unchanged", and a
 * value equal to the stale default is stored as an override that changes
 * nothing. Neither failure is visible in the UI -- you find out from a support
 * ticket. Every one of these files says in its own header that the two must
 * mirror; this is the thing that checks it.
 *
 * This is precisely the check Lagom never wrote: their schema IS the CSS
 * comment, so they cannot desync, but they also have no validator and a stray
 * typo in an annotation silently deletes a control.
 *
 * The name is historical -- it started as a colours-only check and the file
 * keeps its name so the CI invocation and the docs that reference it stay
 * valid. It now covers all eight config schemas.
 *
 * Usage: node scripts/check-color-defaults.mjs   (exit 1 on any mismatch)
 */
import { readFileSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import { dirname, join } from 'node:path';

const ROOT = join(dirname(fileURLToPath(import.meta.url)), '..');
const THEME = join(ROOT, 'templates/hadrian');
const CORE_CSS = 'assets/css/core-theme.css';
const CONFIG_DIR = 'core/config';

/* ===================== CSS side ============================================
   Unchanged machinery: pull a declaration block, map token -> literal, and
   follow var() chains. Every config below resolves through THIS resolver --
   there is deliberately only one, because a second one would be the next thing
   to drift. */

/** Pull one declaration block by its opening selector. */
function block(css, selector, optional = false) {
  const i = css.indexOf(selector);
  if (i === -1) {
    if (optional) return null;
    throw new Error(`selector not found: ${selector}`);
  }
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

/**
 * Resolve a value through var() chains within a scope.
 *
 * Many tokens are declared as `var(--other)` on purpose -- the whole sidebar
 * ink set defaults to the page token it replaced, which is what makes it a
 * no-op and what makes dark mode re-derive for free. Comparing the literal
 * text would flag every one of those, so follow the chain to the colour a
 * browser would actually compute. `scope` is consulted first so a dark
 * redeclaration wins, then `base` (the :root map), matching how the cascade
 * resolves on <html>. `base` is a parameter rather than a closed-over global
 * because a config may add CSS files of its own -- see navigation.php, whose
 * --tbm-bar-height is declared in a layout's own stylesheet.
 */
function resolve(value, scope, base, depth = 0) {
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
  const next = scope.get(m[1]) ?? base.get(m[1]) ?? m[2];
  return next === undefined ? value : resolve(next, scope, base, depth + 1);
}

/**
 * Build the {light, dark} token maps a config is checked against. core-theme.css
 * always comes first; a config's own extra stylesheets are layered over it, so a
 * layout that declares its own token is checked against the value it really
 * ships rather than being waved through as "undeclared".
 */
function scopesFor(extraCss = []) {
  const light = new Map();
  const dark = new Map();
  for (const rel of [CORE_CSS, ...extraCss]) {
    const css = readFileSync(join(THEME, rel), 'utf8');
    for (const [k, v] of tokens(block(css, ':root {'))) light.set(k, v);
    const d = block(css, 'html[data-theme="dark"] {', true);
    if (d) for (const [k, v] of tokens(d)) dark.set(k, v);
  }
  return { light, dark };
}

/* ===================== PHP side ============================================
   Deliberately regex over the PHP rather than shelling out to php -- this runs
   in CI where PHP may not exist. Two aligned copies of the source are built:
   `code` has comments blanked (so a token named in prose cannot be parsed as a
   row) and `mask` has comments AND string bodies blanked, so bracket matching
   cannot be thrown by a '[' inside a label. They are the same length, so an
   index found in one is valid in the other. */

function parsePhp(src) {
  const code = [...src];
  const mask = [...src];
  const blank = (from, to) => { for (let j = from; j < to; j++) { code[j] = ' '; mask[j] = ' '; } };
  let i = 0;
  while (i < src.length) {
    const c = src[i];
    if (c === '/' && src[i + 1] === '*') {
      const end = src.indexOf('*/', i + 2);
      const stop = end === -1 ? src.length : end + 2;
      blank(i, stop); i = stop; continue;
    }
    if (c === '/' && src[i + 1] === '/') {
      let j = i; while (j < src.length && src[j] !== '\n') j++;
      blank(i, j); i = j; continue;
    }
    // Strings are consumed BEFORE comment detection can look inside them,
    // because the scan is sequential -- that is what makes a '//' in a URL or a
    // '/*' in a label safe.
    if (c === "'" || c === '"') {
      let j = i + 1; mask[i] = ' ';
      while (j < src.length) {
        if (src[j] === '\\') { mask[j] = ' '; mask[j + 1] = ' '; j += 2; continue; }
        if (src[j] === c) break;
        mask[j] = ' '; j++;
      }
      mask[j] = ' '; i = j + 1; continue;
    }
    i++;
  }
  return { code: code.join(''), mask: mask.join('') };
}

/** Span of the `[ ... ]` that opens at or after `from`. Indices are absolute. */
function bracket(ctx, from) {
  const open = ctx.mask.indexOf('[', from);
  if (open === -1) return null;
  let depth = 0;
  for (let j = open; j < ctx.mask.length; j++) {
    if (ctx.mask[j] === '[') depth++;
    else if (ctx.mask[j] === ']') { depth--; if (!depth) return { open, close: j }; }
  }
  return null;
}

/** Span of the array assigned to a named key: `'name' => [ ... ]`. */
function namedArray(ctx, name, range) {
  const re = new RegExp(`'${name}'\\s*=>\\s*\\[`, 'g');
  re.lastIndex = range ? range.open : 0;
  const hay = range ? ctx.code.slice(0, range.close) : ctx.code;
  const m = re.exec(hay);
  return m ? bracket(ctx, m.index) : null;
}

/** Every `'name' => [...]` directly inside `range`, in order. */
function namedArrays(ctx, range) {
  const out = new Map();
  const re = /'([A-Za-z][A-Za-z0-9]*)'\s*=>\s*\[/g;
  re.lastIndex = range.open + 1;
  let m;
  while ((m = re.exec(ctx.code.slice(0, range.close))) !== null) {
    const span = bracket(ctx, m.index);
    if (!span) break;
    out.set(m[1], span);
    re.lastIndex = span.close; // skip the nesting: only siblings, never children
  }
  return out;
}

const DEFAULT_RE = /'default'\s*=>\s*(?:'([^']*)'|"([^"]*)"|([+-]?[\d.]+))/;
const pick = (m) => (m ? (m[1] ?? m[2] ?? m[3]) : undefined);

/**
 * Rows of the shape `['var' => '--token', ... 'default' => X]` inside `range`.
 * The scan starts AT the range's own '[' on purpose: typography's `fontFamily`
 * is a single row whose opening bracket IS the section's, and this lets the one
 * scanner read it without a special case.
 */
function varRows(ctx, range) {
  const out = [];
  const re = /\[\s*'var'\s*=>\s*'(--[a-z0-9_-]+)'/g;
  re.lastIndex = range.open;
  let m;
  while ((m = re.exec(ctx.code.slice(0, range.close + 1))) !== null) {
    const span = bracket(ctx, m.index);
    if (!span) break;
    const row = ctx.code.slice(span.open, span.close + 1);
    out.push({
      var: m[1],
      type: /'type'\s*=>\s*'([a-z]+)'/.exec(row)?.[1],
      scale: /'scale'\s*=>\s*'([A-Za-z]+)'/.exec(row)?.[1],
      def: pick(DEFAULT_RE.exec(row)),
    });
    re.lastIndex = span.close;
  }
  return out;
}

/** key -> css, for a `colorOptions` / `shadowOptions` / one `scales` entry. */
function optionCss(ctx, range) {
  const out = new Map();
  const re = /\[\s*'key'\s*=>\s*'([^']+)'/g;
  re.lastIndex = range.open + 1;
  let m;
  while ((m = re.exec(ctx.code.slice(0, range.close))) !== null) {
    const span = bracket(ctx, m.index);
    if (!span) break;
    const css = /'css'\s*=>\s*'([^']*)'/.exec(ctx.code.slice(span.open, span.close + 1));
    if (css) out.set(m[1], css[1]);
    re.lastIndex = span.close;
  }
  return out;
}

/* ===================== expectation ========================================= */

/**
 * The CSS value the emitter would write for a field left at its default. This
 * mirrors Hooks::build*Head exactly -- px/em append the unit, ms re-attaches the
 * authored easing curve, scale/preset keys resolve through the config's own
 * option map. Getting this wrong in either direction is the bug the script
 * exists to catch, so it is one function rather than one per config.
 */
function expected(field, maps, kind) {
  const type = kind ?? field.type ?? 'px';
  const lookup = (map, what) => {
    const css = map?.get(field.def);
    if (css === undefined) throw new Error(`${field.var}: no ${what} '${field.def}'`);
    return css;
  };
  switch (type) {
    case 'scale':  return lookup(maps.scales.get(field.scale), `${field.scale} scale key`);
    case 'preset': return lookup(maps.presets, 'preset key');
    case 'color':  return lookup(maps.colorOptions, 'colour key');
    case 'ms':     return `${field.def}ms ${maps.easing}`;
    case 'em':     return `${field.def}em`;
    case 'px':     return `${field.def}px`;
    // Unitless: the --lh-* ramp, the --fw-* weights, and --font-family, all of
    // which the emitter writes verbatim.
    case 'raw':    return String(field.def);
    default: throw new Error(`${field.var}: unknown field type '${type}'`);
  }
}

/* ===================== the registry ========================================
   One entry per schema. `sections` names the arrays that hold checkable rows;
   `kind` overrides the row's own 'type' for sections whose rows do not carry
   one (typography's ramps, forms' colour groups).

   SCOPE. colors.php declares a per-mode pair and is checked against :root AND
   [data-theme="dark"]. Every other schema declares ONE default and its emitter
   writes into :root only, so :root is the whole contract -- and checking dark
   would be actively wrong: the dark block deliberately re-declares
   --shadow-card / --shadow-card-hover / --shadow-dropdown to flatter stacks,
   which is a design decision, not a drifted default.

   `undeclared` is the per-config form of the --sidebar-color contract: tokens
   the CSS intentionally never declares. Prefer `extraCss` when the token is
   merely declared SOMEWHERE ELSE -- that still checks the value. */
const CONFIGS = [
  {
    file: 'colors.php',
    scopes: 'both',
    // Handled by its own row parser: the defaults are a light/dark PAIR, not a
    // single `default`, and they are literal colours, so the comparison has to
    // run through resolve() on the CSS side to reach a hex it can match.
    colors: true,
  },
  {
    file: 'layout.php',
    sections: [{ name: 'sizeGroups' }],
  },
  {
    file: 'navigation.php',
    sections: [{ name: 'groups' }],
    // --tbm-bar-height is declared in the Topbar Minimal layout's own
    // stylesheet, not core-theme.css, so that deleting that example layout
    // leaves no dangling core token. Reading the file keeps the value checked.
    extraCss: ['core/layouts/main-menu/topbar-minimal/layout.css'],
  },
  {
    file: 'general.php',
    sections: [{ name: 'groups' }],
    presets: 'shadowOptions',
    easing: true,
  },
  {
    file: 'typography.php',
    sections: [
      { name: 'fontFamily', kind: 'raw' },
      { name: 'sizeGroups', kind: 'px' },
      { name: 'lineHeights', kind: 'raw' },
      { name: 'weights', kind: 'raw' },
    ],
  },
  {
    file: 'buttons.php',
    sections: [{ name: 'sizeTiers' }],
    variants: true,
  },
  {
    file: 'forms.php',
    sections: [{ name: 'sizeGroups' }, { name: 'colorGroups', kind: 'color' }],
  },
  {
    file: 'elements.php',
    sections: [{ name: 'sizeGroups' }],
  },
];

/* ===================== the run ============================================= */

const norm = (s) => String(s).replace(/\s+/g, '').toLowerCase();

/** Every checkable {var, want} pair a config declares. */
function checksFor(cfg, ctx) {
  const all = { open: 0, close: ctx.code.length - 1 };
  // The maps a `default` may resolve THROUGH, read out of the same file. They
  // are collected into their own object rather than hung off cfg, so the
  // registry stays a plain declaration and nothing in it changes type mid-run.
  const scalesRange = namedArray(ctx, 'scales', all);
  const colorRange = namedArray(ctx, 'colorOptions', all);
  const presetRange = cfg.presets ? namedArray(ctx, cfg.presets, all) : null;
  const maps = {
    scales: scalesRange
      ? new Map([...namedArrays(ctx, scalesRange)].map(([k, r]) => [k, optionCss(ctx, r)]))
      : new Map(),
    colorOptions: colorRange ? optionCss(ctx, colorRange) : new Map(),
    presets: presetRange ? optionCss(ctx, presetRange) : new Map(),
    easing: cfg.easing ? (/'easing'\s*=>\s*'([^']*)'/.exec(ctx.code)?.[1] ?? '') : '',
  };

  const out = [];
  for (const sec of cfg.sections ?? []) {
    const range = namedArray(ctx, sec.name, all);
    if (!range) throw new Error(`${cfg.file}: section '${sec.name}' not found`);
    const rows = varRows(ctx, range);
    if (!rows.length) throw new Error(`${cfg.file}: section '${sec.name}' parsed zero rows`);
    for (const row of rows) out.push({ var: row.var, want: expected(row, maps, sec.kind) });
  }

  // The button colour MATRIX: nine variants x eight slots, each storing a
  // colorOptions key, emitted as --btn-<variant>-<slot>. Same contract as a
  // field default, different shape, so it gets its own reader.
  if (cfg.variants) {
    const range = namedArray(ctx, 'variants', all);
    const re = /\[\s*'key'\s*=>\s*'([a-z0-9-]+)'/g;
    re.lastIndex = range.open + 1;
    let m;
    while ((m = re.exec(ctx.code.slice(0, range.close))) !== null) {
      const span = bracket(ctx, m.index);
      const slots = namedArray(ctx, 'slots', span);
      const body = ctx.code.slice(slots.open, slots.close);
      for (const s of body.matchAll(/'([a-z-]+)'\s*=>\s*'([a-z0-9-]+)'/g)) {
        out.push({
          var: `--btn-${m[1]}-${s[1]}`,
          want: expected({ var: s[1], def: s[2] }, maps, 'color'),
        });
      }
      re.lastIndex = span.close;
    }
  }
  return out;
}

let fail = 0;
const lines = [];

for (const cfg of CONFIGS) {
  const path = join(THEME, CONFIG_DIR, cfg.file);
  const ctx = parsePhp(readFileSync(path, 'utf8'));
  const { light, dark } = scopesFor(cfg.extraCss);
  const skipped = [];
  const equivalent = [];
  let checked = 0;

  if (cfg.colors) {
    // Original two-scope path, unchanged in behaviour.
    const rows = [...ctx.code.matchAll(
      /\['var'\s*=>\s*'(--[a-z0-9_-]+)'.*?'light'\s*=>\s*'([^']*)'\s*,\s*'dark'\s*=>\s*'([^']*)'/g,
    )];
    if (!rows.length) {
      console.error('FAIL  parsed zero tokens from colors.php - the row shape changed');
      process.exit(1);
    }
    for (const [, name, wantLight, wantDark] of rows) {
      // A token with an EMPTY default is intentionally undeclared in the CSS.
      // That is the --sidebar-color contract: every derived sidebar token
      // references it, so its absence is what makes the tint feature
      // off-by-default. Asserting it were declared would break the mechanism.
      if (wantLight === '' && wantDark === '') { skipped.push(name); continue; }
      const rawLight = light.get(name);
      if (rawLight === undefined) {
        console.error(`FAIL  ${cfg.file} ${name} is declared nowhere in core-theme.css :root`);
        fail++; continue;
      }
      checked++;
      const gotLight = resolve(rawLight, light, light);
      // Not every token is redeclared in the dark block; those inherit the :root
      // declaration, which may itself be a var() that resolves differently there.
      const gotDark = resolve(dark.get(name) ?? rawLight, dark, light);
      if (norm(gotLight) !== norm(wantLight)) {
        console.error(`FAIL  ${cfg.file} ${name} light: '${wantLight}' vs CSS '${gotLight}'`);
        fail++;
      }
      if (norm(gotDark) !== norm(wantDark)) {
        console.error(`FAIL  ${cfg.file} ${name} dark: '${wantDark}' vs CSS '${gotDark}'`);
        fail++;
      }
    }
  } else {
    // A structural break -- a section renamed, a `default` pointing at a scale
    // key that no longer exists -- must read as a FAIL line, not as a Node stack
    // trace, and must not stop the other configs from being reported. Silently
    // skipping it is the one thing that must never happen: a validator that goes
    // green because it parsed nothing is worse than no validator.
    let found;
    try {
      found = checksFor(cfg, ctx);
    } catch (e) {
      console.error(`FAIL  ${cfg.file} could not be parsed: ${e.message}`);
      fail++;
      lines.push(`  ${cfg.file.padEnd(16)} NOT CHECKED (parse failure)`);
      continue;
    }
    for (const { var: name, want } of found) {
      if ((cfg.undeclared ?? []).includes(name)) { skipped.push(name); continue; }
      const got = light.get(name);
      if (got === undefined) {
        console.error(`FAIL  ${cfg.file} ${name} is declared nowhere in :root`);
        fail++; continue;
      }
      checked++;
      if (norm(got) === norm(want)) continue;
      // A REFERENCE mismatch that computes the same today: the schema would emit
      // var(--radius-lg) where the CSS ships var(--radius-md), and both are 12px
      // right now. The panel behaves correctly until someone edits the General
      // scale, at which point the control stops matching its own default -- so
      // it is reported, but it is not a broken build.
      if (norm(resolve(got, light, light)) === norm(resolve(want, light, light))) {
        equivalent.push(`${name} (CSS '${got}' vs schema '${want}')`);
        continue;
      }
      console.error(`FAIL  ${cfg.file} ${name}: schema '${want}' vs CSS '${got}'`);
      fail++;
    }
  }

  lines.push(`  ${cfg.file.padEnd(16)} ${String(checked).padStart(3)} tokens`
    + ` (${cfg.scopes === 'both' ? 'both scopes' : ':root'})`
    + (skipped.length ? `; ${skipped.length} intentionally undeclared: ${skipped.join(', ')}` : '')
    + (equivalent.length ? `; ${equivalent.length} equivalent-but-different reference: ${equivalent.join(', ')}` : ''));
}

console.log('Schema defaults vs CSS literals:');
for (const l of lines) console.log(l);
console.log(`${fail} mismatch(es).`);
process.exit(fail ? 1 : 0);
