#!/usr/bin/env node
// Deploy-safety gate for the i18n tokenization sweep. For every changed .tpl:
//   1. INTERNAL Smarty block-tag balance ({if}/{foreach}/{section}/{literal}/{* *})
//      after stripping {literal} bodies + comments -- an imbalance blanks the page.
//   2. Every {$hadrianLang.group.key} reference resolves to a key in the lang file.
// Pure fs (no git -> cross-shell safe). Usage:
//   node hadrian/scripts/check-i18n-safety.mjs <file.tpl> [file.tpl ...]
//   node hadrian/scripts/check-i18n-safety.mjs $(git diff --name-only -- '*.tpl')
import fs from 'node:fs';

const files = process.argv.slice(2);
const LANGF = 'hadrian/templates/hadrian/core/lang/english.php';
const langRaw = fs.readFileSync(LANGF, 'utf8');
const haveKey = k => new RegExp(`'${k}'\\s*=>`).test(langRaw);

let fail = 0, n = 0;
for (const f of files) {
  if (!f.endsWith('.tpl') || !fs.existsSync(f)) continue;
  n++;
  const raw = fs.readFileSync(f, 'utf8');
  // noComments: strip {* *} first so a comment that merely MENTIONS a tag
  // (e.g. "runs inside a {literal} block") is not counted as a real tag.
  const noComments = raw.replace(/\{\*[\s\S]*?\*\}/g, ' ');
  const s = noComments.replace(/\{literal\}[\s\S]*?\{\/literal\}/g, ' ');
  const c = re => (s.match(re) || []).length;
  const checks = [
    ['{if}/{/if}',          c(/\{if[\s(]/g) + c(/\{if\}/g),       c(/\{\/if\}/g)],
    ['{foreach}/{/foreach}',c(/\{foreach[\s(]/g) + c(/\{foreach\}/g), c(/\{\/foreach\}/g)],
    ['{section}/{/section}',c(/\{section\s/g),                    c(/\{\/section\}/g)],
    ['{literal}/{/literal}',(noComments.match(/\{literal\}/g)||[]).length,(noComments.match(/\{\/literal\}/g)||[]).length],
    ['{* *}',               (raw.match(/\{\*/g)||[]).length,      (raw.match(/\*\}/g)||[]).length],
  ];
  for (const [name, o, cl] of checks) {
    if (o !== cl) { console.log(`IMBALANCE  ${f}: ${name} -> ${o} open vs ${cl} close`); fail = 1; }
  }
  // NESTED {* *}: Smarty comments do not nest, so an inner close ends the
  // outer block early and everything after it renders as literal text on the
  // page. The count check above cannot see this -- a nested pair balances.
  for (const m of raw.matchAll(/\{\*([\s\S]*?)\*\}/g)) {
    if (m[1].includes('{*')) {
      const line = raw.slice(0, m.index).split('\n').length;
      console.log(`NESTEDCOMM ${f}:${line}: a {* *} comment contains another {* -- comments do not nest, so the rest of the block leaks onto the page as text`);
      fail = 1;
    }
  }
  for (const m of raw.matchAll(/hadrianLang\.([a-zA-Z]+)\.([a-zA-Z0-9]+)/g)) {
    if (!haveKey(m[2])) { console.log(`BADREF     ${f}: $hadrianLang.${m[1]}.${m[2]} (key '${m[2]}' not in lang file)`); fail = 1; }
  }
}
console.log(`--- checked ${n} changed .tpl file(s); ` + (fail ? 'ISSUES FOUND (above)' : 'OK: internally balanced + all hadrianLang refs resolve'));
process.exit(fail);
