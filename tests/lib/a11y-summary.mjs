#!/usr/bin/env node
// One readable report from the a11y tier's per-test detail files.
//
//   node tests/lib/a11y-summary.mjs            -> tests/reports/a11y-summary.md
//
// Reads tests/reports/a11y-detail/*.json (written by e2e/a11y.spec.mjs on every run)
// and groups the findings by rule: how many pages, how many elements, which
// variants (layout / colour mode / width), and a few example elements. Rules
// are ordered by impact, then by how many pages they hit.

import fs from 'node:fs';
import path from 'node:path';
import { REPORTS_DIR } from './env.mjs';

const DIR = path.join(REPORTS_DIR, 'a11y-detail');
const OUT = path.join(REPORTS_DIR, 'a11y-summary.md');
const IMPACT = { critical: 0, serious: 1, moderate: 2, minor: 3, undefined: 4 };

if (!fs.existsSync(DIR)) { console.error(`no ${DIR}: run the a11y tier first (node tests/run.mjs --tier a11y)`); process.exit(2); }

const scans = fs.readdirSync(DIR).filter(f => f.endsWith('.json'))
  .flatMap(f => JSON.parse(fs.readFileSync(path.join(DIR, f), 'utf8')));

const rules = new Map();
for (const s of scans) {
  const [variant, persona, name] = s.key.split(' | ');
  for (const v of s.violations) {
    const r = rules.get(v.id) || { id: v.id, impact: v.impact, help: v.help, helpUrl: v.helpUrl, tags: v.tags, pages: new Set(), variants: new Set(), elements: 0, examples: new Map() };
    r.pages.add(`${persona} ${name}`);
    r.variants.add(variant);
    r.elements += v.nodes.length;
    for (const n of v.nodes) if (r.examples.size < 6 && !r.examples.has(n.target)) r.examples.set(n.target, { page: `${persona} ${name}`, html: n.html });
    rules.set(v.id, r);
  }
  if (s.overflowX > 1 && /320px/.test(variant)) {
    const r = rules.get('hadrian-reflow-320') || { id: 'hadrian-reflow-320', impact: 'serious', help: 'Content scrolls sideways at 320 CSS px (WCAG 1.4.10)', tags: ['wcag21aa'], pages: new Set(), variants: new Set(), elements: 0, examples: new Map() };
    r.pages.add(`${persona} ${name}`); r.variants.add(variant); r.elements++;
    r.examples.set(`${persona} ${name}`, { page: `${persona} ${name}`, html: `overflow ${s.overflowX}px` });
    rules.set(r.id, r);
  }
}

const list = [...rules.values()].sort((a, b) => (IMPACT[a.impact] - IMPACT[b.impact]) || (b.pages.size - a.pages.size));
const pagesScanned = new Set(scans.map(s => s.key.split(' | ').slice(1).join(' '))).size;
const md = [
  `# Accessibility scan summary`,
  ``,
  `${scans.length} scans of ${pagesScanned} pages, axe-core 4.14.0, WCAG 2.2 A + AA plus best practice. Generated ${new Date().toISOString().slice(0, 16).replace('T', ' ')}.`,
  ``,
  `| Rule | Impact | Pages | Elements | WCAG | What it means |`,
  `|-|-|-|-|-|-|`,
  ...list.map(r => `| \`${r.id}\` | ${r.impact || '-'} | ${r.pages.size} | ${r.elements} | ${r.tags.filter(t => t !== 'best-practice').join(' ') || 'best practice'} | ${r.help} |`),
  ``,
  ...list.flatMap(r => [
    `## ${r.id}`,
    ``,
    `${r.help}${r.helpUrl ? ` ([rule](${r.helpUrl}))` : ''}. ${r.pages.size} page(s), ${r.elements} element(s) across all variants.`,
    ``,
    `Variants: ${[...r.variants].sort().join(', ')}`,
    ``,
    `Examples:`,
    ``,
    ...[...r.examples].map(([target, e]) => `- \`${target}\` on ${e.page}: \`${e.html.replace(/`/g, "'").replace(/\s+/g, ' ').slice(0, 160)}\``),
    ``,
  ]),
].join('\n');

fs.writeFileSync(OUT, md);
console.log(`${list.length} rules failing across ${pagesScanned} pages -> ${path.relative(process.cwd(), OUT)}`);
for (const r of list.slice(0, 20)) console.log(`  ${(r.impact || '-').padEnd(9)} ${r.id.padEnd(34)} ${String(r.pages.size).padStart(4)} pages ${String(r.elements).padStart(6)} elements`);
