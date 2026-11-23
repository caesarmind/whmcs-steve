#!/usr/bin/env node
// Every {$x@iteration} / @index / @first / @last / @total / @show names the
// ITEM variable of a {foreach} that encloses it.
//
// Smarty tracks those properties on the item only. In
//   {foreach $product.features as $feature => $value}{if $feature@iteration <= 4}
// $feature is the KEY, so $feature@iteration is undefined: PHP logs a warning
// per item and the expression is null, `null <= 4` is true, and the "first
// four features" cap silently never applied - every plan card listed every
// feature. WHMCS logged it 248 times; nothing on the page said so.
//
// Static: scans hadrian/templates/hadrian and hadrian_cart.

import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const REPO = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..', '..');
const ROOTS = ['hadrian/templates/hadrian', 'hadrian_cart'].map(r => path.join(REPO, r));
const walk = (d, out = []) => {
  for (const e of fs.readdirSync(d, { withFileTypes: true })) {
    const p = path.join(d, e.name);
    if (e.isDirectory()) { if (e.name !== '_archive' && e.name !== 'node_modules') walk(p, out); }
    else if (e.name.endsWith('.tpl')) out.push(p);
  }
  return out;
};

const problems = [];
let uses = 0;
for (const file of ROOTS.flatMap(r => walk(r))) {
  const src = fs.readFileSync(file, 'utf8')
    .replace(/\{\*[\s\S]*?\*\}/g, m => m.replace(/[^\n]/g, ' '))                  // comments, keep line numbers
    .replace(/\{literal\}[\s\S]*?\{\/literal\}/g, m => m.replace(/[^\n]/g, ' '));
  const stack = [];   // { item, key, line }
  const lineOf = i => src.slice(0, i).split('\n').length;
  const tagRe = /\{(\/?)(foreach|function)\b([^}]*)\}|\$([A-Za-z_]\w*)@(iteration|index|first|last|total|show)\b/g;
  for (const m of src.matchAll(tagRe)) {
    if (m[2] === 'function') { if (m[1]) stack.splice(0); continue; }   // functions get their own scope
    if (m[2] === 'foreach') {
      if (m[1]) { stack.pop(); continue; }
      const a = m[3];
      let item = null, key = null, mm;
      if ((mm = a.match(/\bas\s+\$(\w+)\s*=>\s*\$(\w+)/))) { key = mm[1]; item = mm[2]; }
      else if ((mm = a.match(/\bas\s+\$(\w+)/))) { item = mm[1]; }
      else { item = (a.match(/\bitem\s*=\s*["']?(\w+)/) || [])[1] || null; key = (a.match(/\bkey\s*=\s*["']?(\w+)/) || [])[1] || null; }
      stack.push({ item, key, line: lineOf(m.index) });
      continue;
    }
    uses++;
    const name = m[4], prop = m[5];
    const rel = path.relative(REPO, file).replace(/\\/g, '/');
    if (stack.some(f => f.item === name)) continue;
    const asKey = [...stack].reverse().find(f => f.key === name);
    problems.push(asKey
      ? `${rel}:${lineOf(m.index)}  $${name}@${prop} - $${name} is the KEY of the foreach on line ${asKey.line}; use $${asKey.item}@${prop}`
      : `${rel}:${lineOf(m.index)}  $${name}@${prop} outside any {foreach} over $${name}`);
  }
}

for (const p of problems) console.error('FAIL  ' + p);
console.log(problems.length ? `FAILED: ${problems.length} of ${uses} loop-property uses are undefined` : `ok: all ${uses} loop-property uses name an enclosing foreach item`);
process.exit(problems.length ? 1 : 0);
