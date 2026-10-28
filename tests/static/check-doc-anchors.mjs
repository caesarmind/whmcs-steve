/* check-doc-anchors.mjs -- every admin "Learn more" link must land somewhere.
   ---------------------------------------------------------------------------
   The admin panel deep-links into the customer docs: includes/doclink.tpl and
   includes/tip.tpl both take article="<slug>" anchor="<id>" and build
   docs.hadrianthegreat.com/client-theme/<article>/#<anchor>.

   Nothing enforced that the anchor exists. Rename a heading in the docs and the
   link still renders, still looks right, and quietly drops the reader at the
   top of the page instead of the setting they clicked -- the failure is
   invisible from either side, which is exactly why it needs a check.

   This reads the anchors out of the admin templates (literal attributes AND the
   {assign var=...Anchor value='...'} indirection the Settings page uses per row),
   then greps the BUILT docs for a matching id="".

   It builds the docs itself first (node scripts/build-docs.mjs --base=, into
   the gitignored hadrian-documentation/dist): dist/ is absent on a fresh
   checkout, and a stale one would pass anchors the source has since renamed.
   The ids do not depend on --base; that is only the local-preview base.

     node tests/static/check-doc-anchors.mjs
*/
import fs from 'node:fs';
import path from 'node:path';
import { spawnSync } from 'node:child_process';
import { fileURLToPath } from 'node:url';

const HERE = path.dirname(fileURLToPath(import.meta.url));
const ROOT = path.resolve(HERE, '..', '..');
const VIEWS = path.join(ROOT, 'hadrian', 'modules', 'addons', 'Hadrian', 'views', 'adminarea');
const DIST = path.join(ROOT, 'hadrian-documentation', 'dist', 'client-theme');

/* Build first - see the header. About a second. */
const build = spawnSync(process.execPath, [path.join(ROOT, 'scripts', 'build-docs.mjs'), '--base='], { cwd: ROOT, encoding: 'utf8' });
if (build.status !== 0) {
  console.log('  docs build FAILED - nothing to check the anchors against:');
  for (const line of `${build.stdout || ''}${build.stderr || ''}`.trim().split('\n').slice(-20)) console.log('   ' + line);
  process.exit(1);
}

function walk(dir, out = []) {
  for (const e of fs.readdirSync(dir, { withFileTypes: true })) {
    const p = path.join(dir, e.name);
    if (e.isDirectory()) walk(p, out);
    else if (e.name.endsWith('.tpl')) out.push(p);
  }
  return out;
}

/* One template can reference several articles. Anchors assigned to a variable
   are collected per FILE and paired with every article that file links to --
   the Settings page is the only user of the pattern today and links to exactly
   one article, so this stays exact rather than merely conservative. */
const refs = [];   // {file, article, anchor}
const problems = [];

for (const file of walk(VIEWS)) {
  const src = fs.readFileSync(file, 'utf8');
  const rel = path.relative(ROOT, file);

  // article="x" ... anchor="y" on one include line (either attribute order)
  for (const line of src.split('\n')) {
    const art = line.match(/article="([a-z0-9-]+)"/);
    if (!art) continue;
    const anc = line.match(/anchor="([a-z0-9-]+)"/);
    if (anc) refs.push({ file: rel, article: art[1], anchor: anc[1] });
  }

  // {assign var=mtRowAnchor value='...'} - the per-row indirection
  const assigned = [...src.matchAll(/\{assign\s+var=\w*[Aa]nchor\s+value='([a-z0-9-]+)'\}/g)].map((m) => m[1]);
  if (assigned.length) {
    const articles = [...new Set([...src.matchAll(/article="([a-z0-9-]+)"/g)].map((m) => m[1]))];
    if (articles.length !== 1) {
      problems.push(`${rel}: assigns anchors but links ${articles.length} articles - cannot pair them`);
    } else {
      for (const a of assigned) refs.push({ file: rel, article: articles[0], anchor: a });
    }
  }
}

if (!refs.length) problems.push('no admin doc links found at all - did the views move?');

/* Cache each built article's ids once. */
const idCache = new Map();
function idsFor(article) {
  if (idCache.has(article)) return idCache.get(article);
  const html = path.join(DIST, article, 'index.html');
  const ids = fs.existsSync(html)
    ? new Set([...fs.readFileSync(html, 'utf8').matchAll(/\bid="([^"]+)"/g)].map((m) => m[1]))
    : null;
  idCache.set(article, ids);
  return ids;
}

const seen = new Set();
let checked = 0;
for (const { file, article, anchor } of refs) {
  const key = `${article}#${anchor}`;
  if (seen.has(key)) continue;
  seen.add(key);
  checked++;
  const ids = idsFor(article);
  if (ids === null) {
    problems.push(`${file}: links article "${article}" - no built page at dist/client-theme/${article}/`);
  } else if (!ids.has(anchor)) {
    problems.push(`${file}: /${article}/#${anchor} - no heading with that id`);
  }
}

console.log(`  ${checked} unique admin doc link(s) checked across ${idCache.size} article(s)`);
if (problems.length) {
  console.log(`  ${problems.length} FAILED:`);
  for (const p of problems) console.log(`   - ${p}`);
  process.exit(1);
}
console.log('  All checks passed.');
