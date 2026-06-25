#!/usr/bin/env node
// Manual check: every literal CSS class used in a page tpl should be defined in
// the page's own CSS, the global theme CSS (apple-theme/apple-layout), or be a
// known runtime/state/utility class. Flags likely typos (used but never defined).
import fs from 'node:fs';

const ROOT = 'templates/hadrian';
const CSSDIR = `${ROOT}/assets/css`;

// classes added at runtime by JS, global toggles, or generic utilities
const ALLOW = new Set([
  'when-full','when-empty','only-in','only-out','only-top','only-side','only-rail','only-inner',
  'active','checked','show','hidden','selected','current','disabled','open','loading','done',
  'danger','ok','warn','error','info','success','primary','secondary',
  'sorting','sorting_asc','sorting_desc','dataTable',
  'client-area-layout','ph-main-wrap','content-area','homepage-nav','ph-breadcrumb',
  'card','card-header','card-title','card-body','card-action',
  'btn-primary','btn-secondary','btn-danger','btn-group',
  'form-group','form-label','form-input','form-textarea','form-select','form-hint','form-checkbox','form-radio-group',
  'page-header','page-subtitle','page-eyebrow','eyebrow','page-header-row','page-header-text','page-actions',
  'status-pill','subnav-card','subnav-item','subnav-heading','subnav-count','svc-table-card',
  'auth-link','masq-chip','spacer','dot','big','due','muted','grand','total','first','last',
]);

const globalCss = ['apple-theme.css','apple-layout.css']
  .map(f => { try { return fs.readFileSync(`${CSSDIR}/${f}`,'utf8'); } catch { return ''; } }).join('\n');
const globalDefined = new Set([...globalCss.matchAll(/\.([a-zA-Z][\w-]*)/g)].map(m => m[1]));

const pages = fs.readdirSync(`${ROOT}/core/pages`).filter(p =>
  fs.existsSync(`${ROOT}/core/pages/${p}/default/default.tpl`) &&
  fs.existsSync(`${CSSDIR}/pages/${p}.css`));

let totalFlags = 0;
for (const p of pages) {
  const tpl = fs.readFileSync(`${ROOT}/core/pages/${p}/default/default.tpl`,'utf8');
  const css = fs.readFileSync(`${CSSDIR}/pages/${p}.css`,'utf8');
  const pageDefined = new Set([...css.matchAll(/\.([a-zA-Z][\w-]*)/g)].map(m => m[1]));

  // collect literal class tokens from class="..." (strip Smarty {...} first)
  const used = new Set();
  for (const m of tpl.matchAll(/class\s*=\s*"([^"]*)"/g)) {
    const cleaned = m[1].replace(/\{[^}]*\}/g, ' ');
    for (const tok of cleaned.split(/\s+/)) {
      if (tok && /^[a-zA-Z][\w-]*$/.test(tok)) used.add(tok);
    }
  }
  const missing = [...used].filter(c =>
    !pageDefined.has(c) && !globalDefined.has(c) && !ALLOW.has(c));
  if (missing.length) {
    console.log(`${p}: ${missing.join(', ')}`);
    totalFlags += missing.length;
  }
}
console.log(`\n${pages.length} pages checked, ${totalFlags} class(es) used-but-undefined (review for typos).`);
