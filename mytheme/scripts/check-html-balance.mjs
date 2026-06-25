#!/usr/bin/env node
// Manual heuristic: count opening vs closing container tags per page tpl.
// Smarty {if}/{foreach} branches normally open+close a tag within the same
// branch, so raw counts should match; mismatches are flagged for human review
// (may be a legit cross-branch open/close, or a real unclosed container).
import fs from 'node:fs';

const ROOT = 'templates/hadrian/core/pages';
const TAGS = ['div','form','table','aside','section','ul','ol','select','tbody','thead','dl'];
const pages = fs.readdirSync(ROOT).filter(p => fs.existsSync(`${ROOT}/${p}/default/default.tpl`));

let flags = 0;
for (const p of pages) {
  let s = fs.readFileSync(`${ROOT}/${p}/default/default.tpl`, 'utf8');
  s = s.replace(/\{literal\}[\s\S]*?\{\/literal\}/g, ' ').replace(/\{\*[\s\S]*?\*\}/g, ' ');
  const issues = [];
  for (const t of TAGS) {
    const open = (s.match(new RegExp(`<${t}(\\s|>)`, 'g')) || []).length;
    const close = (s.match(new RegExp(`</${t}>`, 'g')) || []).length;
    if (open !== close) issues.push(`<${t}> ${open}/${close}`);
  }
  if (issues.length) { console.log(`${p}: ${issues.join(', ')}`); flags++; }
}
console.log(`\n${pages.length} pages checked; ${flags} with container-count mismatch (review).`);
