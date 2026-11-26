#!/usr/bin/env node
// No URL in the theme or the order form may assume WHMCS sits at the web root.
// Bug 7 in tests/FEATURES.md, fixed 2026-11-25; this keeps it fixed.
//
// WHMCS can live in a folder (https://example.com/billing/). A script that
// calls '/cart.php' then talks to whatever owns the root of the domain, so
// the order form's Review cart button and its promo check stop working. The
// local stack runs at the root, which is why no site test can see it.
//
// Flags a quoted path that starts at the root and names a WHMCS script:
// '/cart.php', "/clientarea.php?...", '/index.php/...'. A path built from the
// install's own root ({$WEB_ROOT}/cart.php, $WEB_ROOT|cat:'/cart.php',
// WHMCS.utils.getRouteUrl('/domain/check'), or in JS WEB_ROOT or whmcsBaseUrl
// + '/cart.php' on the same line) is fine and is not flagged.
//
//   node tests/static/check-root-paths.mjs
//
// Output protocol (tests/README.md, "Known bugs"): files listed in KNOWN are
// reported as "KNOWN BUG ..." without failing the run; a new file fails it,
// and so does a KNOWN file that no longer has any, until its entry is removed.

import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const ROOT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..', '..');
const DIRS = ['hadrian_cart', 'hadrian/templates/hadrian'];
const SKIP = new Set(['_archive', 'node_modules']);

// file -> why it is listed. Remove an entry once its file is fixed. Empty
// since 2026-11-25, when configureproduct.tpl (Review cart, its redirect, the
// promo check) and configureproductdomain.tpl (the own-domain fallback) were
// moved onto WEB_ROOT / whmcsBaseUrl.
const KNOWN = {};

const ROOT_PATH = /(['"])\/(?:[a-z][\w-]*\.php|index\.php\/)[^'"]*\1/gi;

const files = [];
const walk = dir => {
  for (const e of fs.readdirSync(dir, { withFileTypes: true })) {
    if (SKIP.has(e.name)) continue;
    const p = path.join(dir, e.name);
    if (e.isDirectory()) walk(p);
    else if (/\.(tpl|js)$/.test(e.name) && !/\.min\.js$/.test(e.name)) files.push(p);
  }
};
for (const d of DIRS) walk(path.join(ROOT, d));

const found = {};
for (const file of files) {
  const rel = path.relative(ROOT, file).split(path.sep).join('/');
  const lines = fs.readFileSync(file, 'utf8').split('\n');
  lines.forEach((line, i) => {
    for (const m of line.matchAll(ROOT_PATH)) {
      const before = line.slice(0, m.index);
      // Joined onto the install's root by Smarty, or resolved by WHMCS's own helper.
      if (/(\|cat:|WEB_ROOT\}?|getRouteUrl\()\s*$/.test(before)) continue;
      // Joined in JS onto the root the theme sets on cart pages, on this same
      // line: (WEB_ROOT || '') + '/cart.php'. A variable from elsewhere is not
      // enough: the bug this guards was routeBase + '...' with a base nobody set.
      if (/\b(WEB_ROOT|whmcsBaseUrl)\b/.test(before) && /\+\s*$/.test(before)) continue;
      (found[rel] ??= []).push(`${rel}:${i + 1}  ${m[0]}`);
    }
  });
}

let fail = 0;
let known = 0;
for (const [rel, hits] of Object.entries(found)) {
  if (KNOWN[rel]) {
    known++;
    console.log(`KNOWN BUG root-paths ${rel}: ${KNOWN[rel]} (${hits.length} call(s)) - tests/FEATURES.md bug 7`);
    for (const h of hits) console.log(`      ${h}`);
    continue;
  }
  fail++;
  console.log(`FAIL  ${rel}: a URL from the web root breaks WHMCS installed in a folder`);
  for (const h of hits) console.log(`      ${h}`);
  console.log(`      Build it from the install's root instead: {$WEB_ROOT}/cart.php in Smarty, or a JS variable set from it.`);
}
for (const rel of Object.keys(KNOWN)) {
  if (!found[rel]) {
    fail++;
    console.log(`FIXED root-paths ${rel}: no root paths left. Remove it from KNOWN in tests/static/check-root-paths.mjs and bug 7 from tests/FEATURES.md.`);
  }
}

console.log(`${files.length} files scanned, ${fail} failed${known ? `, ${known} known bug(s) still reproduce` : ''}`);
process.exit(fail ? 1 : 0);
