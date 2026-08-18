/* test-docs-parser.mjs -- regression tests for the markdown parser
   ---------------------------------------------------------------------------
   Every case here is a bug that shipped once. The parser is hand-written and
   has no upstream test suite to inherit, so this file is the only thing
   stopping a future edit from quietly reintroducing one.

   Three of these used to HANG the build -- an infinite loop with no output and
   no error -- so each case runs in its own child process with a timeout rather
   than in-process, where a hang would take the test runner down with it.

   Run: node scripts/test-docs-parser.mjs
*/
import { execFileSync } from 'node:child_process';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import { fileURLToPath, pathToFileURL } from 'node:url';

const HERE = path.dirname(fileURLToPath(import.meta.url));
const BUILDER = path.join(HERE, 'build-docs.mjs');

/* The builder ends in a bare build() call, so it cannot be imported for its
   parts. A copy with that line swapped for an export can. */
const TMP = fs.mkdtempSync(path.join(os.tmpdir(), 'hadrian-docs-test-'));
const MODULE = path.join(TMP, 'parser.mjs');
fs.writeFileSync(
  MODULE,
  fs.readFileSync(BUILDER, 'utf8').replace(/^build\(\);\s*$/m, 'export { render, inline };')
);

/* A file:// URL, not a bare path: on Windows an import specifier of
   "C:/..." is read as a protocol and throws ERR_UNSUPPORTED_ESM_URL_SCHEME. */
const RUNNER = path.join(TMP, 'run.mjs');
fs.writeFileSync(RUNNER, `
import { render, inline } from ${JSON.stringify(pathToFileURL(MODULE).href)};
const body = JSON.parse(process.argv[2]);
const mode = process.argv[3];
const out = mode === 'inline' ? inline(body) : (() => {
  const r = render(body, 'test');
  return JSON.stringify({ html: r.html, toc: r.toc, text: r.text });
})();
process.stdout.write(out);
`);

const CASES = [
  // --- hangs -------------------------------------------------------------
  { name: 'fence with an info string', mode: 'block',
    input: '```php title="config.php"\n$x = 1;\n```\n',
    want: (o) => o.html.includes('doc-codeblock-lang">php<') && o.html.includes('$x = 1;') },

  { name: 'unknown ::: directive', mode: 'block',
    input: ':::note\nhello\n:::\n\n## After\n',
    want: (o) => o.toc.length === 1 && o.toc[0][1] === 'After' },

  { name: 'stray top-level :::', mode: 'block',
    input: ':::\n\n## After\n',
    want: (o) => o.toc.length === 1 },

  // --- wrong output ------------------------------------------------------
  { name: 'multi-parameter link href is escaped once', mode: 'inline',
    input: '[pay](https://x.com/a?b=1&c=2)',
    want: (s) => s.includes('b=1&amp;c=2') && !s.includes('&amp;amp;') },

  { name: 'javascript: URL is not linkified', mode: 'inline',
    input: '[click](javascript:alert(1))',
    want: (s) => !s.includes('<a href="javascript:') },

  { name: 'glob patterns are not italicised', mode: 'inline',
    input: 'Use *.php and *.css files',
    want: (s) => s.includes('*.php') && !s.includes('<em>') },

  { name: 'real emphasis still works', mode: 'inline',
    input: 'that is *important* here',
    want: (s) => s.includes('<em>important</em>') },

  { name: 'code span protects its contents', mode: 'inline',
    input: 'run `npm run **build**` now',
    want: (s) => s.includes('npm run **build**') && !s.includes('<strong>') },

  { name: 'a number between spaces is not a placeholder', mode: 'inline',
    input: 'set `x` to 3 or 4',
    want: (s) => s.includes('to 3 or 4') },

  { name: ':::shot inside a container does not swallow the article', mode: 'block',
    input: ':::info Title\nBefore.\n:::shot A picture\nAfter.\n:::\n\n## Later\n\nBody.\n',
    want: (o) => o.toc.length === 1 && o.toc[0][1] === 'Later' },

  { name: 'unclosed container recovers at the next heading', mode: 'block',
    input: ':::info Unclosed\nInside.\n\n## Should appear\n\nBody.\n',
    want: (o) => o.toc.length === 1 && o.toc[0][1] === 'Should appear' },

  { name: 'callout keeps prose that precedes its bullets', mode: 'block',
    input: ':::tip\nA sentence that matters.\n- a bullet\n:::\n',
    want: (o) => o.html.includes('A sentence that matters') && o.html.includes('<li>') },

  { name: 'duplicate headings get distinct ids', mode: 'block',
    input: '## Overview\n\nOne.\n\n## Overview\n\nTwo.\n',
    want: (o) => o.toc[0][0] === 'overview' && o.toc[1][0] === 'overview-2' },

  { name: 'nested containers close at the right :::', mode: 'block',
    input: ':::info Outer\nText.\n:::\n\n## After\n',
    want: (o) => o.toc.length === 1 && o.html.includes('doc-callout-info') },

  { name: 'CRLF input parses like LF', mode: 'block',
    input: '## Heading\r\n\r\nA paragraph.\r\n',
    want: (o) => o.toc.length === 1 && o.html.includes('A paragraph.') },

  { name: 'props table renders a real table with scoped headers', mode: 'block',
    input: ':::props\n| Setting | Default | Description |\n| --- | --- | --- |\n| `a` | `b` | c |\n:::\n',
    want: (o) => o.html.includes('<th scope="col">Setting</th>') && o.html.includes('data-label="Default"') },

  { name: 'steps are numbered and keep inline markup', mode: 'block',
    input: ':::steps\n1. Go to **Settings**.\n2. Click `Save`.\n:::\n',
    want: (o) => o.html.includes('<strong>Settings</strong>') && o.html.includes('doc-step-n">2<') },

  { name: 'HTML in prose is escaped, not rendered', mode: 'block',
    input: 'A <script>alert(1)</script> tag.\n',
    want: (o) => o.html.includes('&lt;script&gt;') && !o.html.includes('<script>') },
];

let failed = 0;
for (const c of CASES) {
  let raw;
  try {
    raw = execFileSync(process.execPath, [RUNNER, JSON.stringify(c.input), c.mode],
      { encoding: 'utf8', timeout: 5000, stdio: ['ignore', 'pipe', 'pipe'] });
  } catch (e) {
    const why = e.signal === 'SIGTERM' || e.killed ? 'HANG (killed after 5s)' : `threw: ${String(e.stderr || e.message).split('\n')[0]}`;
    console.error(`  FAIL  ${c.name}\n          ${why}`);
    failed++;
    continue;
  }

  const value = c.mode === 'inline' ? raw : JSON.parse(raw);
  let ok = false;
  try { ok = c.want(value); } catch (e) { ok = false; }
  if (ok) {
    console.log(`  ok    ${c.name}`);
  } else {
    console.error(`  FAIL  ${c.name}\n          got: ${(c.mode === 'inline' ? raw : raw).slice(0, 200)}`);
    failed++;
  }
}

fs.rmSync(TMP, { recursive: true, force: true });

console.log(`\n  ${CASES.length - failed}/${CASES.length} passed`);
process.exit(failed ? 1 : 0);
