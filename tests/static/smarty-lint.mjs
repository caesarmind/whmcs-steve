// Heuristic Smarty safety linter for the Hadrian admin templates.
// We can't compile Smarty without WHMCS, so this catches the two failure modes
// that poison the WHMCS compile cache:
//   1) unbalanced block tags ({if}/{foreach}/{literal}/{section}/{capture}/{strip})
//   2) auto-literal-breaking "{" in <style>/<script> that is NOT inside {literal}
//      (a "{" immediately followed by a non-space char is parsed by Smarty as a tag;
//       safe CSS uses ".foo { ... }" with a space after the brace).
import { readFileSync, readdirSync, statSync } from 'node:fs';
import { resolve, join } from 'node:path';

const ROOT = resolve(process.argv[2] || 'hadrian/modules/addons/Hadrian/views/adminarea');

function walk(dir) {
  const out = [];
  for (const e of readdirSync(dir)) {
    const p = join(dir, e);
    if (statSync(p).isDirectory()) out.push(...walk(p));
    else if (e.endsWith('.tpl')) out.push(p);
  }
  return out;
}

// Block tags that must balance {tag}...{/tag}
const BLOCKS = ['literal', 'if', 'foreach', 'section', 'capture', 'strip', 'function', 'while', 'block', 'nocache', 'for', 'setscope'];
// Valid Smarty open-token prefixes (a "{" followed by one of these is intentional Smarty)
const VALID = [/^\{\s/, /^\{\$/, /^\{\//, /^\{\*/, /^\{if[\s(]/, /^\{else/, /^\{elseif[\s(]/, /^\{foreach[\s ]/, /^\{foreachelse/, /^\{include[\s ]/, /^\{assign[\s ]/, /^\{capture[\s ]/, /^\{strip\}/, /^\{\/strip\}/, /^\{literal\}/, /^\{\/literal\}/, /^\{ldelim\}/, /^\{rdelim\}/, /^\{section[\s ]/, /^\{php\}/, /^\{function[\s ]/, /^\{block[\s ]/, /^\{nocache\}/, /^\{while[\s ]/, /^\{for[\s ]/, /^\{=/, /^\{"/, /^\{'/];

function stripComments(src) {
  // Blank out {* ... *} Smarty comments (keep newlines) so tag-words inside a
  // comment (e.g. "wrap in {literal}") are not miscounted as real tags.
  return src.replace(/\{\*[\s\S]*?\*\}/g, (m) => m.replace(/[^\n]/g, ' '));
}
function stripLiteral(src) {
  // Replace {literal}...{/literal} contents with spaces (keep length/lines) so the
  // brace-safety scan ignores them, while still counting the literal tags themselves.
  return src.replace(/\{literal\}([\s\S]*?)\{\/literal\}/g, (m, inner) =>
    '{literal}' + inner.replace(/[^\n]/g, ' ') + '{/literal}');
}

function lineOf(src, idx) { return src.slice(0, idx).split('\n').length; }

let totalIssues = 0;
const files = walk(ROOT).sort();
for (const file of files) {
  const raw = readFileSync(file, 'utf8');
  const src = stripComments(raw);
  const rel = file.replace(ROOT + '\\', '').replace(ROOT + '/', '').replace(/\\/g, '/');
  const issues = [];

  // 1) block-tag balance
  for (const tag of BLOCKS) {
    const open = (src.match(new RegExp('\\{' + tag + '(?=[\\s}(/])', 'g')) || []).length;
    const close = (src.match(new RegExp('\\{/' + tag + '\\}', 'g')) || []).length;
    // {if} can be opened as {if ...}; {foreach ...}; count opens that are NOT closes
    if (tag === 'if') {
      const opensIf = (src.match(/\{if[\s(]/g) || []).length;
      const closeIf = (src.match(/\{\/if\}/g) || []).length;
      if (opensIf !== closeIf) issues.push(`unbalanced {if}: ${opensIf} open vs ${closeIf} close`);
      continue;
    }
    if (open !== close) issues.push(`unbalanced {${tag}}: ${open} open vs ${close} close`);
  }

  // 2) auto-literal danger inside <style>/<script> regions outside {literal}
  const masked = stripLiteral(src);
  const blockRe = /<(style|script)\b[^>]*>([\s\S]*?)<\/\1>/gi;
  let m;
  while ((m = blockRe.exec(masked)) !== null) {
    const inner = m[2];
    const base = m.index + m[0].indexOf(inner);
    // find "{" not followed by whitespace and not a valid Smarty construct
    for (let i = 0; i < inner.length; i++) {
      if (inner[i] !== '{') continue;
      const rest = inner.slice(i, i + 14);
      if (/^\{\s/.test(rest)) continue;                 // "{ " auto-literal safe
      if (rest[1] === '}') continue;                    // "{}" empty literal (tolerated on this install)
      if (rest[1] === undefined) continue;
      if (VALID.some(re => re.test(rest))) continue;     // intentional Smarty tag
      // "{" followed by non-space, not a known tag -> would break Smarty parse
      issues.push(`line ${lineOf(masked, base + i)}: risky "{${(inner[i+1]||'').replace(/\n/,'\\n')}" in <${m[1]}> outside {literal} (auto-literal break)`);
      if (issues.length > 40) break;
    }
  }

  if (issues.length) {
    totalIssues += issues.length;
    console.log(`\nFAIL  ${rel}`);
    issues.slice(0, 12).forEach(s => console.log('   - ' + s));
    if (issues.length > 12) console.log(`   ... +${issues.length - 12} more`);
  }
}

console.log(`\n${files.length} templates scanned, ${totalIssues} issue(s).`);
process.exit(totalIssues ? 1 : 0);
