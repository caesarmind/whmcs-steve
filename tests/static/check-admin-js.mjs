// Parse every inline <script> in the admin views.
//
// The admin's behaviour lives in ~1200 lines of inline JS inside .tpl files.
// Nothing else checks it: smarty-lint reads tags, check-html-balance counts
// containers, and a syntax error in there takes out the page it is on with no
// server-side symptom at all -- the template renders fine and the controls
// simply stop working.
//
// Smarty interpolations are replaced with a literal before parsing, so this
// checks the JS the browser would receive rather than the template source.
//
// KNOWN NOISE, and worth knowing before trusting a run: the flattener is a
// regex, not a Smarty parser, so a tag containing braces of its own defeats it.
// branding/index.tpl and includes/header.tpl both fail for that reason and did
// so before this script existed -- verified against HEAD. Read the count as
// "did MY file start failing", not as a clean bill for the whole tree.
//
//   node tests/static/check-admin-js.mjs
import { readFileSync, readdirSync, existsSync } from 'node:fs';
import { join } from 'node:path';

// Node 18 has no fs.globSync, so walk it.
const walk = d => readdirSync(d, { withFileTypes: true }).flatMap(e =>
  e.isDirectory() ? walk(join(d, e.name)) : (e.name.endsWith('.tpl') ? [join(d, e.name)] : []));
// Hadrian Email Templates and Hadrian Page Builder are separate addons with
// admin views of their own.
const files = ['hadrian/modules/addons/Hadrian/views/adminarea', 'hadrian_email/modules/addons/HadrianEmail/views', 'hadrian_builder/modules/addons/HadrianBuilder/views']
  .filter(d => existsSync(d)).flatMap(walk);
let bad = 0, checked = 0;

for (const f of files) {
  // Drop Smarty comments first. branding/index.tpl has a {* ... *} note that
  // says "inside <style>/<script> blocks", and the <script> regex below opened
  // a block on that prose and parsed the comment as JavaScript.
  const src = readFileSync(f, 'utf8').replace(/\{\*[\s\S]*?\*\}/g, '');
  // {literal} regions are passed to the browser verbatim, so a <script> that
  // sits inside one must not have its braces flattened: includes/header.tpl
  // wraps a minified one-liner whose "{try{var ..." looked like a Smarty tag.
  const literal = [...src.matchAll(/\{literal\}([\s\S]*?)\{\/literal\}/g)]
    .map(m => [m.index, m.index + m[0].length]);
  const inLiteral = at => literal.some(([s, e]) => at > s && at < e);
  // Only inline JS. An external src= has no body to check, and a non-JS
  // payload is not JS: pages/edit.tpl carries a type="application/json" block
  // whose Smarty default is a literal {}, and parsing that as JS reported a
  // syntax error in something that was never JavaScript.
  const blocks = [...src.matchAll(/<script([^>]*)>([\s\S]*?)<\/script>/g)]
    .filter(m => !/\bsrc=/.test(m[1]))
    .filter(m => !/\btype=/.test(m[1]) || /\btype=["']text\/javascript["']/.test(m[1]))
    .map(m => ({ body: m[2], literal: inLiteral(m.index) }));
  blocks.forEach(({ body: b, literal: verbatim }, i) => {
    const js = verbatim ? b : b
      .replace(/\{literal\}|\{\/literal\}/g, '')
      // {$var}, {$a.b|escape}, {if ...}, {/if} -- anything Smarty, outside
      // {literal}, becomes a harmless literal so the parser sees valid JS.
      .replace(/\{\/?[$a-zA-Z][^{}]*\}/g, 'null');
    if (!js.trim()) return;
    checked++;
    try {
      new Function(js);
    } catch (e) {
      bad++;
      console.log(`FAIL ${f} script[${i}]: ${e.message}`);
    }
  });
}
console.log(`${checked} inline script block(s) parsed across ${files.length} templates; ${bad} with syntax errors`);
process.exit(bad ? 1 : 0);
