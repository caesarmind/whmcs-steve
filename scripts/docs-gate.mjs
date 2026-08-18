/* docs-gate.mjs -- the docs correctness gate, wired to a PostToolUse hook.
   ---------------------------------------------------------------------------
   Reads a Claude Code hook payload on stdin, and if the edited file belongs to
   the documentation, runs the full gate:

     1. build with the PRODUCTION base (/docs)   <- the step that matters
     2. check-docs      (dead links, dead anchors, missing images, metadata)
     3. test-docs-parser (18 regression cases)
     4. rebuild with --base=   so the :3100 preview keeps working

   Step 1 is the point. A --base= build cannot catch a link written as
   /client-theme/styles/ that needs to be /docs/client-theme/styles/ -- those
   resolve fine at a root and 404 in production, so the bug hides in exactly the
   place you would look for it. Step 4 exists so the gate does not silently
   leave the local preview pointing at /docs.

   Exit 2 on failure: PostToolUse treats that as a blocking error and feeds the
   output back, so a broken link is raised at the edit that caused it rather
   than at upload time.

   Manual run:  echo '{"tool_input":{"file_path":"hadrian-documentation/content/x.md"}}' | node scripts/docs-gate.mjs
*/
import { execFileSync } from 'node:child_process';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const ROOT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');

/* Only these paths are worth ~6s of rebuild. Everything else exits silently --
   a hook that fires on every edit in the repo would be a tax, not a safety net. */
const WATCHED = /(hadrian-documentation[\/](content|assets)[\/])|(scripts[\/](build|check|test)-docs)/;

const stdin = await new Promise((resolve) => {
  let d = '';
  process.stdin.setEncoding('utf8');
  process.stdin.on('data', (c) => { d += c; });
  process.stdin.on('end', () => resolve(d));
  setTimeout(() => resolve(d), 2000).unref();     // never hang the turn
});

let file = '';
try {
  const p = JSON.parse(stdin || '{}');
  file = p?.tool_input?.file_path || p?.tool_response?.filePath || '';
} catch (e) { /* not a hook payload -- fall through and do nothing */ }

if (!file || !WATCHED.test(file)) process.exit(0);

const run = (args) =>
  execFileSync(process.execPath, args, { cwd: ROOT, encoding: 'utf8', stdio: ['ignore', 'pipe', 'pipe'] });

try {
  run(['scripts/build-docs.mjs']);                 // production base
  const check = run(['scripts/check-docs.mjs']);
  const tests = run(['scripts/test-docs-parser.mjs']);
  run(['scripts/build-docs.mjs', '--base=']);      // restore the preview build

  const passed = (tests.match(/(\d+)\/(\d+) passed/) || [])[0] || 'tests ok';
  process.stdout.write(`docs gate: ${check.trim().split('\n').pop().trim()} | ${passed}\n`);
  process.exit(0);
} catch (e) {
  const out = `${e.stdout || ''}${e.stderr || ''}`.trim();
  process.stderr.write(`docs gate FAILED after editing ${file}\n\n${out}\n`);
  try { run(['scripts/build-docs.mjs', '--base=']); } catch (e2) { /* preview restore is best effort */ }
  process.exit(2);
}
