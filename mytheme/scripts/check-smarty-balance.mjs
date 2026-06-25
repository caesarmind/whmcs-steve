#!/usr/bin/env node
// Manual structural check: verify Smarty block-tag balance in every page tpl +
// dispatcher. Unbalanced {if}/{foreach}/{section}/{literal} or {* *} is the #1
// cause of a blank .content-area on WHMCS. We strip {literal} bodies and comments
// first (their inner { } are not Smarty), then count opens vs closes.
import fs from 'node:fs';

const ROOT = 'templates/hadrian';
const pages = fs.readdirSync(`${ROOT}/core/pages`).filter(p =>
  fs.existsSync(`${ROOT}/core/pages/${p}/default/default.tpl`));

let problems = [];
let checked = 0;

function analyse(label, raw) {
  // {literal} balance on the raw text
  const litOpen = (raw.match(/\{literal\}/g) || []).length;
  const litClose = (raw.match(/\{\/literal\}/g) || []).length;
  // comment balance
  const cOpen = (raw.match(/\{\*/g) || []).length;
  const cClose = (raw.match(/\*\}/g) || []).length;
  // strip literal bodies + comments before counting block tags
  let s = raw.replace(/\{literal\}[\s\S]*?\{\/literal\}/g, ' ')
             .replace(/\{\*[\s\S]*?\*\}/g, ' ');
  const n = re => (s.match(re) || []).length;
  const ifO = n(/\{if[\s(]/g) + n(/\{if\}/g);
  const ifC = n(/\{\/if\}/g);
  const feO = n(/\{foreach[\s(]/g) + n(/\{foreach\}/g);
  const feC = n(/\{\/foreach\}/g);
  const secO = n(/\{section\s/g), secC = n(/\{\/section\}/g);
  const errs = [];
  if (ifO !== ifC) errs.push(`{if} ${ifO} vs {/if} ${ifC}`);
  if (feO !== feC) errs.push(`{foreach} ${feO} vs {/foreach} ${feC}`);
  if (secO !== secC) errs.push(`{section} ${secO} vs {/section} ${secC}`);
  if (litOpen !== litClose) errs.push(`{literal} ${litOpen} vs {/literal} ${litClose}`);
  if (cOpen !== cClose) errs.push(`{* ${cOpen} vs *} ${cClose}`);
  if (errs.length) problems.push(`${label}: ${errs.join('; ')}`);
  checked++;
}

for (const p of pages) {
  analyse(`${p}/default.tpl`, fs.readFileSync(`${ROOT}/core/pages/${p}/default/default.tpl`, 'utf8'));
  const disp = `${ROOT}/${p}.tpl`;
  if (fs.existsSync(disp)) analyse(`${p}.tpl (dispatcher)`, fs.readFileSync(disp, 'utf8'));
}

console.log(`Checked ${checked} files.`);
if (problems.length) {
  console.log(`\nIMBALANCED (${problems.length}):`);
  problems.forEach(p => console.log('  FAIL ' + p));
  process.exit(1);
} else {
  console.log('All Smarty block tags balanced.');
}
