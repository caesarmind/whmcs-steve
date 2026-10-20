#!/usr/bin/env node
// php -l every PHP file in the addon and the theme, with the same PHP the
// local WHMCS runs. A parse error in the addon takes out the admin and every
// client page whose hooks load it, and production finds out first.

import fs from 'node:fs';
import path from 'node:path';
import { spawn } from 'node:child_process';
import { PHP } from '../lib/env.mjs';

const roots = ['hadrian/modules/addons/Hadrian', 'hadrian/templates/hadrian'];
const files = [];
const walk = d => {
  for (const e of fs.readdirSync(d, { withFileTypes: true })) {
    const p = path.join(d, e.name);
    if (e.isDirectory()) { if (!['vendor', 'node_modules'].includes(e.name)) walk(p); continue; }
    if (e.name.endsWith('.php')) files.push(p);
  }
};
roots.forEach(r => fs.existsSync(r) && walk(r));

const lint = f => new Promise(res => {
  const c = spawn(PHP, ['-l', f], { stdio: ['ignore', 'pipe', 'pipe'] });
  let out = '';
  c.stdout.on('data', d => (out += d));
  c.stderr.on('data', d => (out += d));
  c.on('close', code => res({ f, code, out: out.trim() }));
});

// Eight at a time: php -l is process-start bound, not CPU bound.
const results = [];
for (let i = 0; i < files.length; i += 8) results.push(...await Promise.all(files.slice(i, i + 8).map(lint)));

const bad = results.filter(r => r.code !== 0);
for (const b of bad) console.log(`FAIL ${b.f.replace(/\\/g, '/')}\n     ${b.out.split('\n')[0]}`);
console.log(`${files.length} PHP file(s) linted with ${path.basename(path.dirname(PHP))}; ${bad.length} failed`);
process.exit(bad.length ? 1 : 0);
