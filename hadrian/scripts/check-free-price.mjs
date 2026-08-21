#!/usr/bin/env node
/**
 * check-free-price.mjs
 *
 * The "0.00" -> "Free" feature has THREE implementations that must agree:
 *
 *   1. includes/common/price.tpl        (Smarty, for server-rendered prices)
 *   2. src/Helpers/PriceHelper.php      (PHP, for the AJAX data tables)
 *   3. initFreePriceLabels() in
 *      assets/js/core-layout.js        (JS, for the order form's client-side
 *                                        price rewrites)
 *
 * Lagom's equivalent is duplicated inline across ~10 templates plus a JS
 * copy, which is exactly how such checks drift apart. This asserts all three
 * still classify every case identically.
 *
 * None of the three is simulated from a hardcoded copy: the regexes are
 * EXTRACTED from price.tpl and the isZero() body is EXTRACTED from
 * core-layout.js, so editing either without updating the expectations here
 * fails the check.
 *
 * The PHP path runs only when a `php` binary is reachable; otherwise it is
 * skipped with a notice (the Smarty and JS assertions still run).
 *
 * Usage:  node scripts/check-free-price.mjs      (from hadrian/)
 * Exit:   0 all agree, 1 on any mismatch.
 */
import { readFileSync, writeFileSync, unlinkSync } from 'node:fs';
import { execFileSync } from 'node:child_process';
import { resolve, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';
import { tmpdir } from 'node:os';

const root = resolve(dirname(fileURLToPath(import.meta.url)), '..');
const TPL = resolve(root, 'templates/hadrian/includes/common/price.tpl');
const PHP = resolve(root, 'modules/addons/Hadrian/src/Helpers/PriceHelper.php');
const JS  = resolve(root, 'templates/hadrian/assets/js/core-layout.js');

// [input, expectedFree, description]
const CASES = [
  ['$0.00',      true,  'plain zero, prefix currency'],
  ['0.00',       true,  'bare zero'],
  ['0,00',       true,  'comma decimal (EU)'],
  ['0.000',      true,  'three-decimal currency (BHD/KWD)'],
  ['-0.00',      true,  'negative zero'],
  ['0.00 USD',   true,  'suffix currency code'],
  ['&nbsp;0.00', true,  'nbsp entity separator'],
  ['EUR 0,00',   true,  'prefix code + comma decimal'],
  ['$0',         true,  'zero, no decimals'],
  ['$10.00',     false, 'ten'],
  ['$0.01',      false, 'one cent'],
  ['$100.00',    false, 'hundred'],
  ['$1,000.00',  false, 'thousands separator'],
  ['0.10',       false, 'ten cents'],
  ['-',          false, 'no digits at all'],
  ['',           false, 'empty'],
  ['N/A',        false, 'non-numeric text'],
];

let failures = 0;
const fail = (msg) => { console.error(`  FAIL  ${msg}`); failures++; };

// ---------------------------------------------------------------- Smarty side
// Pull the two regex_replace patterns straight out of the template so this
// check tracks the real implementation rather than a copy of it.
const tpl = readFileSync(TPL, 'utf8');
const patterns = [...tpl.matchAll(/regex_replace:'\/(.+?)\/':'(.*?)'/g)]
  .map((m) => ({ re: new RegExp(m[1], 'g'), to: m[2] }));

if (patterns.length !== 2) {
  fail(`expected 2 regex_replace filters in price.tpl, found ${patterns.length} -- ` +
       `the template changed shape; update this checker.`);
} else {
  const smartyIsFree = (price) => {
    const digits  = String(price).replace(patterns[0].re, patterns[0].to);
    const nonZero = digits.replace(patterns[1].re, patterns[1].to);
    return digits !== '' && nonZero === '';
  };
  for (const [input, want, desc] of CASES) {
    const got = smartyIsFree(input);
    if (got !== want) {
      fail(`smarty: '${input}' -> ${got ? 'FREE' : 'price'}, expected ` +
           `${want ? 'FREE' : 'price'}  (${desc})`);
    }
  }
}

// -------------------------------------------------------------------- JS side
// initFreePriceLabels() in core-layout.js carries a third copy of the test,
// for the order form's client-side price rewrites. Extract its isZero() body
// verbatim rather than restating the logic here.
const js = readFileSync(JS, 'utf8');
const isZeroSrc = js.match(/function isZero\(text\) \{([\s\S]*?)\n {8}\}/);
if (!isZeroSrc) {
  fail('could not find isZero() in core-layout.js — did initFreePriceLabels change shape?');
} else {
  const jsIsFree = new Function('text', isZeroSrc[1]);
  for (const [input, want, desc] of CASES) {
    let got;
    try { got = jsIsFree(input); } catch (e) { fail(`js threw on '${input}': ${e.message}`); continue; }
    if (Boolean(got) !== want) {
      fail(`js: '${input}' -> ${got ? 'FREE' : 'price'}, expected ${want ? 'FREE' : 'price'}  (${desc})`);
    }
  }
}

// ------------------------------------------------------------------- PHP side
let phpBin = null;
for (const cand of ['php', 'php.exe']) {
  try { execFileSync(cand, ['-v'], { stdio: 'ignore' }); phpBin = cand; break; } catch { /* next */ }
}

if (!phpBin) {
  console.log('  note: no `php` on PATH -- PHP-side assertions skipped.');
} else {
  const probe = resolve(tmpdir(), 'hadrian-free-price-probe.php');
  writeFileSync(probe, `<?php
require ${JSON.stringify(PHP)};
$cases = json_decode(${JSON.stringify(JSON.stringify(CASES.map((c) => c[0])))}, true);
$out = [];
foreach ($cases as $c) { $out[] = \\Hadrian\\Helpers\\PriceHelper::isFree($c) ? 1 : 0; }
// numeric inputs matter too -- that is the fmtMoney path
foreach ([0.0, 0, -0.0, 0.001, 10.5] as $n) { $out[] = \\Hadrian\\Helpers\\PriceHelper::isFree($n) ? 1 : 0; }
echo json_encode($out);
`, 'utf8');

  try {
    const raw = execFileSync(phpBin, [probe], { encoding: 'utf8' });
    const got = JSON.parse(raw);
    CASES.forEach(([input, want, desc], i) => {
      if (Boolean(got[i]) !== want) {
        fail(`php: '${input}' -> ${got[i] ? 'FREE' : 'price'}, expected ` +
             `${want ? 'FREE' : 'price'}  (${desc})`);
      }
    });
    // numeric tail: 0.0, 0, -0.0 free; 0.001, 10.5 not
    const numericWant = [true, true, true, false, false];
    numericWant.forEach((want, j) => {
      const got_ = Boolean(got[CASES.length + j]);
      if (got_ !== want) { fail(`php numeric #${j} -> ${got_}, expected ${want}`); }
    });
  } catch (e) {
    fail(`could not run the PHP probe: ${e.message}`);
  } finally {
    try { unlinkSync(probe); } catch { /* best effort */ }
  }
}

if (failures === 0) {
  console.log(`Checked ${CASES.length} price cases` +
              `${phpBin ? ' against the Smarty, JS and PHP paths' : ' (Smarty + JS paths)'}.`);
  console.log('"0.00" -> "Free" implementations agree.');
} else {
  console.error(`\n${failures} mismatch(es).`);
  process.exit(1);
}
