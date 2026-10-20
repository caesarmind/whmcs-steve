#!/usr/bin/env node
// Every CSS file that ships must be pure ASCII.
//
// On this WHMCS install, Unicode box-drawing characters in a CSS comment made
// Chrome skip whole sections of the stylesheet - no error anywhere, just
// rules that silently stopped applying. Escape non-ASCII in values (\2014)
// and keep comments plain.

import fs from 'node:fs';
import { execFileSync } from 'node:child_process';

// TRACKED files only - those are what the deploy Action ships. A gitignored
// stray (hadrian/.../theme.css is one: an unused leftover) never reaches the
// server and must not fail the run.
const files = execFileSync('git', ['ls-files', '--', 'hadrian/templates/hadrian/*.css', 'hadrian_cart/*.css'], { encoding: 'utf8' })
  .split('\n').filter(Boolean);
const bad = [];
const n = files.length;

for (const p of files) {
  if (!fs.existsSync(p)) continue; // deleted in the working tree
  fs.readFileSync(p, 'utf8').split('\n').forEach((line, i) => {
    const m = line.match(/[^\x00-\x7F]/);
    if (m) bad.push(`${p}:${i + 1}  U+${m[0].codePointAt(0).toString(16).toUpperCase().padStart(4, '0')}  ${line.trim().slice(0, 70)}`);
  });
}

for (const b of bad.slice(0, 40)) console.log('FAIL ' + b);
if (bad.length > 40) console.log(`... and ${bad.length - 40} more`);
console.log(`${n} CSS file(s) scanned; ${bad.length} non-ASCII line(s)`);
process.exit(bad.length ? 1 : 0);
