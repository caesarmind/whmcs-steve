#!/usr/bin/env node
// Hadrian test suite - one entry point for every tier.
//
//   node tests/run.mjs                       everything (visual is advisory)
//   node tests/run.mjs --gate                what the pre-push hook runs: every BLOCKING tier
//   node tests/run.mjs --tier static,compile no site needed - seconds
//   node tests/run.mjs --tier smoke          HTTP: every page x persona, admin screens, link crawl
//   node tests/run.mjs --tier browser        Chromium: layouts, dark mode, JS errors, user flows
//   node tests/run.mjs --tier settings       every admin setting, layout and page variant, switched on for real
//   node tests/run.mjs --tier visual         screenshot comparison (advisory)
//   node tests/run.mjs --approve             accept the current look as the visual baseline
//   node tests/run.mjs --open                open the HTML report when done
//
// Exit 0 = nothing blocking failed. Exit 1 = a blocking check failed.
// Exit 2 = the environment is not ready (preflight) - a setup problem, not a theme bug.

import fs from 'node:fs';
import path from 'node:path';
import { spawn, execFileSync } from 'node:child_process';
import { CHECKS, COMPILE } from './lib/registry.mjs';
import { preflight, staticPreflight } from './lib/preflight.mjs';
import { REPO_ROOT, TESTS_DIR, REPORTS_DIR, BASE_URL, PHP, readJson } from './lib/env.mjs';
import { KNOWN_ISSUES } from './e2e/known-issues.mjs';

const argv = process.argv.slice(2);
const flag = f => argv.includes(f);
const opt = name => { const i = argv.indexOf(name); return i >= 0 ? argv[i + 1] : null; };

const ALL = ['static', 'compile', 'smoke', 'browser', 'settings', 'visual'];
const tiers = new Set(opt('--tier') ? opt('--tier').split(',') : flag('--gate') ? ['static', 'compile', 'smoke', 'browser', 'settings'] : ALL);
for (const t of tiers) if (!ALL.includes(t)) { console.error(`unknown tier "${t}" (use ${ALL.join(', ')})`); process.exit(2); }
if (flag('--approve')) tiers.add('visual');

const tty = process.stdout.isTTY;
const c = (n, s) => (tty ? `\x1b[${n}m${s}\x1b[0m` : s);
const green = s => c(32, s), red = s => c(31, s), yellow = s => c(33, s), dim = s => c(2, s), bold = s => c(1, s);
const t0 = Date.now();
const secs = ms => `${(ms / 1000).toFixed(1)}s`;

fs.mkdirSync(REPORTS_DIR, { recursive: true });
const summary = { startedAt: new Date().toISOString(), baseUrl: BASE_URL, tiers: [...tiers], commit: null, sections: [] };
try { summary.commit = execFileSync('git', ['rev-parse', '--short', 'HEAD'], { cwd: REPO_ROOT, encoding: 'utf8' }).trim(); } catch {}

function run(cmd, args, { cwd = REPO_ROOT, env = {} } = {}) {
  return new Promise(res => {
    const started = Date.now();
    const child = spawn(cmd, args, { cwd, env: { ...process.env, ...env }, stdio: ['ignore', 'pipe', 'pipe'] });
    let out = '';
    child.stdout.on('data', d => (out += d));
    child.stderr.on('data', d => (out += d));
    child.on('error', e => res({ code: 127, out: String(e), ms: Date.now() - started }));
    child.on('close', code => res({ code, out, ms: Date.now() - started }));
  });
}
const lastLine = s => (s.trim().split('\n').filter(l => l.trim()).pop() || '').replace(/\x1b\[[0-9;]*m/g, '').slice(0, 110);

console.log(bold(`Hadrian test suite`) + dim(`  ${[...tiers].join(' + ')}  @ ${summary.commit || '?'}  ${BASE_URL}`));

// ------------------------------------------------------------- preflight
// The static tier needs no site, but four of its checkers need the Smarty that
// `composer install -d tests/static` provides; every other tier needs the local
// stack. Both are environment problems, not theme bugs: exit 2, with the fix.
const needsSite = ['compile', 'smoke', 'browser', 'settings', 'visual'].some(t => tiers.has(t));
if (needsSite || tiers.has('static')) {
  console.log('\n' + bold('Preflight'));
  const checks = tiers.has('static') ? staticPreflight() : [];
  if (needsSite) checks.push(...(await preflight({ ensureFixtures: ['smoke', 'browser', 'settings', 'visual'].some(t => tiers.has(t)) })).checks);
  const pfOk = checks.every(ch => ch.ok);
  for (const ch of checks) console.log(`  ${ch.ok ? green('ok  ') : red('FAIL')}  ${ch.name.padEnd(36)} ${dim(ch.detail.slice(0, 80))}`);
  summary.sections.push({ name: 'Preflight', blocking: true, ok: pfOk, items: checks.map(ch => ({ name: ch.name, ok: ch.ok, detail: ch.detail, fix: ch.fix })) });
  if (!pfOk) {
    console.log('\n' + red('Environment not ready - nothing was tested.'));
    for (const ch of checks.filter(x => !x.ok)) console.log(`  ${ch.name}: ${yellow(ch.fix)}`);
    writeReport(); process.exit(2);
  }
}

// ---------------------------------------------------------------- static
async function runChecks(title, list) {
  console.log('\n' + bold(title));
  const items = [];
  const queue = [...list];
  const worker = async () => {
    while (queue.length) {
      const ch = queue.shift();
      const [cmd, ...args] = typeof ch.cmd === 'function' ? ch.cmd() : ch.cmd;
      const r = await run(cmd, args, { cwd: ch.cwd });
      items.push({ ...ch, ok: r.code === 0, ms: r.ms, detail: lastLine(r.out), output: r.out.replace(/\x1b\[[0-9;]*m/g, '').slice(-6000) });
    }
  };
  await Promise.all(Array.from({ length: 4 }, worker));
  const order = new Map(list.map((ch, i) => [ch.id, i]));
  items.sort((a, b) => order.get(a.id) - order.get(b.id));
  for (const it of items) {
    const mark = it.skipped ? dim('skip') : it.ok ? green('ok  ') : it.blocking ? red('FAIL') : yellow('warn');
    console.log(`  ${mark}  ${it.title.padEnd(44)} ${dim((it.ms ? secs(it.ms).padStart(6) + '  ' : '        ') + (it.detail || ''))}`);
  }
  const failed = items.filter(i => !i.ok && i.blocking);
  for (const f of failed) console.log('\n' + red(`  --- ${f.title} ---`) + '\n' + f.output.split('\n').slice(-25).map(l => '    ' + l).join('\n'));
  summary.sections.push({ name: title, blocking: true, ok: failed.length === 0,
    items: items.map(({ cmd, cwd, output, ...rest }) => ({ ...rest, output: rest.ok ? undefined : output })) });
  return failed.length === 0;
}

let ok = true;
if (tiers.has('static')) ok = (await runChecks('Static checks', CHECKS)) && ok;
if (tiers.has('compile')) ok = (await runChecks('Compile (WHMCS Smarty)', [COMPILE])) && ok;

// --------------------------------------------------------- playwright tiers
async function playwright(projects, tag, extra = []) {
  const args = [path.join(TESTS_DIR, 'node_modules', '@playwright', 'test', 'cli.js'), 'test', '--config', path.join(TESTS_DIR, 'playwright.config.mjs'),
    ...projects.flatMap(p => ['--project', p]), '--reporter', 'line,html,json', ...extra];
  const r = await run(process.execPath, args, { cwd: TESTS_DIR, env: {
    HADRIAN_REPORT_TAG: tag, PLAYWRIGHT_JSON_OUTPUT_NAME: path.join(REPORTS_DIR, `${tag}.json`), PLAYWRIGHT_HTML_OUTPUT_DIR: path.join(REPORTS_DIR, tag), PLAYWRIGHT_HTML_OPEN: 'never',
  } });
  const json = readJson(path.join(REPORTS_DIR, `${tag}.json`), { suites: [] });
  const tests = [];
  const walk = (s, trail) => {
    for (const sp of s.specs || []) for (const t of sp.tests) {
      const last = t.results.at(-1) || {};
      let status = last.status || 'skipped';
      let errors = (last.errors || []).map(e => (e.message || '').replace(/\x1b\[[0-9;]*m/g, '').split('\n').slice(0, 14).join('\n'));
      const annotations = [...(t.annotations || [])];
      // test.fail('BUG: ...'): the test proves a known bug, so failing is the
      // expected outcome and is reported as a known issue. Passing means the bug
      // was fixed, and the run fails until the test.fail() line is removed.
      if (t.expectedStatus === 'failed') {
        const why = annotations.find(a => a.type === 'fail')?.description || 'known bug';
        if (status === 'failed' || status === 'timedOut') { status = 'passed'; errors = []; annotations.push({ type: 'known issue', description: `${sp.title}: ${why}` }); }
        else if (status === 'passed') { status = 'failed'; errors = [`marked test.fail() (${why}) but it passed: the bug looks fixed, remove the test.fail() line`]; }
      }
      tests.push({ project: t.projectName, title: [...trail, sp.title].filter(Boolean).join(' > '), file: sp.file, status, ms: last.duration, errors, annotations });
    }
    for (const ch of s.suites || []) walk(ch, s.file && !trail.length ? [ch.title] : [...trail, ch.title]);
  };
  for (const s of json.suites) walk(s, []);
  return { code: r.code, out: r.out, tests, ms: r.ms, tag };
}

function reportTests(title, res, { blocking }) {
  const byProject = {};
  for (const t of res.tests) (byProject[t.project] ||= { passed: 0, failed: 0, skipped: 0 })[t.status === 'passed' ? 'passed' : t.status === 'skipped' ? 'skipped' : 'failed']++;
  console.log('\n' + bold(title) + dim(`  ${secs(res.ms)}`));
  for (const [p, n] of Object.entries(byProject)) {
    console.log(`  ${n.failed ? (blocking ? red('FAIL') : yellow('diff')) : green('ok  ')}  ${p.padEnd(10)} ${n.passed} passed${n.failed ? ', ' + n.failed + (blocking ? ' failed' : ' differ') : ''}${n.skipped ? ', ' + n.skipped + ' skipped' : ''}`);
  }
  const failed = res.tests.filter(t => !['passed', 'skipped'].includes(t.status));
  for (const f of failed.slice(0, 25)) console.log(`\n  ${blocking ? red('x') : yellow('~')} [${f.project}] ${f.title}\n` + f.errors.join('\n').split('\n').slice(0, 10).map(l => '      ' + l).join('\n'));
  if (failed.length > 25) console.log(dim(`  ... and ${failed.length - 25} more - see the report`));
  if (!res.tests.length) console.log(red('  no test results - Playwright output:\n') + res.out.split('\n').slice(-20).map(l => '    ' + l).join('\n'));
  const known = res.tests.flatMap(t => t.annotations.filter(a => a.type === 'known issue').map(a => a.description));
  summary.sections.push({ name: title, blocking, ok: failed.length === 0 && res.tests.length > 0, report: path.basename(REPORTS_DIR) + '/' + (res.tag || 'site') + '/index.html',
    items: res.tests.map(t => ({ name: `[${t.project}] ${t.title}`, ok: ['passed', 'skipped'].includes(t.status), skipped: t.status === 'skipped', ms: t.ms, detail: t.errors.join('\n').slice(0, 1500) })), known });
  return blocking ? failed.length === 0 && res.tests.length > 0 : true;
}

// What WHMCS logs while the site tiers run. It swallows most template failures
// (a missing {include}, $key@iteration, an array offset on null) into its own
// logs and still answers 200 with a normal-looking page - the log is the only
// place they show. Read after the site tiers below.
const usesSite = ['smoke', 'browser', 'settings', 'visual'].some(t => tiers.has(t));
let logMark = null;
if (usesSite) {
  const r = await run(PHP, [path.join(TESTS_DIR, 'php', 'whmcs-log.php'), 'mark']);
  try { logMark = JSON.parse(r.out.trim().split('\n').pop()); } catch {}
}

const site = ['smoke', 'browser'].filter(t => tiers.has(t));
if (site.length) ok = reportTests('Site tests', await playwright(site, 'site'), { blocking: true }) && ok;
// Settings change what every request sees, so they run alone, after the rest.
if (tiers.has('settings')) ok = reportTests('Settings, layouts and variants', await playwright(['settings'], 'settings', ['--workers', '1']), { blocking: true }) && ok;
if (tiers.has('visual')) {
  // The flows just created (and closed) a ticket for the full persona, with a
  // timestamped subject that lands on its dashboard. Clean up first so the
  // screenshots are always of the same seeded data.
  await run(PHP, [path.join(TESTS_DIR, 'php', 'fixtures.php')]);
  const res = await playwright(['visual'], 'visual', [`--update-snapshots=${flag('--approve') ? 'all' : 'missing'}`]);
  reportTests(flag('--approve') ? 'Visual (baselines approved)' : 'Visual (advisory)', res, { blocking: false });
}

if (logMark) {
  const r = await run(PHP, [path.join(TESTS_DIR, 'php', 'whmcs-log.php'), 'since', String(logMark.activity), String(logMark.error)]);
  let findings = [];
  try { findings = JSON.parse(r.out.trim().split('\n').pop()); } catch { findings = [{ count: 1, log: 'runner', message: `could not read the WHMCS logs: ${lastLine(r.out)}` }]; }
  const line = f => `${f.source ? `${f.source}${f.line ? ` (compiled line ${f.line})` : ''}: ` : ''}${f.message.slice(0, 220)}  [x${f.count}]`;
  const knownLog = findings.filter(f => KNOWN_ISSUES.some(k => k.logMatch?.test(line(f))));
  const fresh = findings.filter(f => !knownLog.includes(f));
  console.log('\n' + bold('WHMCS logs during this run') + dim('  theme errors WHMCS swallowed instead of showing'));
  console.log(fresh.length ? fresh.map(f => `  ${red('x')} ${line(f)}`).join('\n') : `  ${green('ok  ')}  nothing logged about the theme`);
  summary.sections.push({ name: 'WHMCS logs during this run', blocking: true, ok: fresh.length === 0,
    items: fresh.length ? fresh.map(f => ({ name: line(f), ok: false })) : [{ name: 'tblactivitylog + tblerrorlog: nothing about the theme', ok: true }],
    known: knownLog.map(line) });
  ok = fresh.length === 0 && ok;
}

// ----------------------------------------------------------------- known issues
const known = summary.sections.flatMap(s => s.known || []);
if (known.length) {
  console.log('\n' + bold('Known issues') + dim(' (reported, not blocking - see tests/e2e/known-issues.mjs and the test.fail() lines)'));
  for (const k of KNOWN_ISSUES) console.log(`  ${yellow('!')} ${k.id}: ${k.what.slice(0, 150)}...`);
  for (const k of [...new Set(known)].filter(k => !KNOWN_ISSUES.some(e => k.startsWith(e.id)))) console.log(`  ${yellow('!')} ${k.slice(0, 200)}`);
}

summary.finishedAt = new Date().toISOString();
summary.ok = ok;
writeReport();
console.log('\n' + (ok ? green(bold('PASSED')) : red(bold('FAILED'))) + dim(`  in ${secs(Date.now() - t0)}  -  report: tests/reports/index.html`));
if (flag('--open')) { try { spawn(process.platform === 'win32' ? 'cmd' : 'open', process.platform === 'win32' ? ['/c', 'start', '', path.join(REPORTS_DIR, 'index.html')] : [path.join(REPORTS_DIR, 'index.html')], { detached: true, stdio: 'ignore' }).unref(); } catch {} }
process.exit(ok ? 0 : 1);

// --------------------------------------------------------------- HTML report
function writeReport() {
  fs.writeFileSync(path.join(REPORTS_DIR, 'summary.json'), JSON.stringify(summary, null, 2));
  const esc = s => String(s ?? '').replace(/[&<>"]/g, ch => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;' }[ch]));
  const sec = s => {
    const bad = s.items.filter(i => !i.ok);
    const badge = s.ok ? '<span class="b ok">pass</span>' : s.blocking ? '<span class="b fail">fail</span>' : '<span class="b warn">review</span>';
    const rows = s.items.map(i => `<tr class="${i.skipped ? 'skip' : i.ok ? '' : s.blocking ? 'fail' : 'warn'}"><td>${i.skipped ? '&ndash;' : i.ok ? '&#10003;' : '&#10007;'}</td><td>${esc(i.name || i.title)}${i.why ? `<div class="why">${esc(i.why)}</div>` : ''}${!i.ok && i.fix ? `<div class="fix">Fix: <code>${esc(i.fix)}</code></div>` : ''}${!i.ok && (i.detail || i.output) ? `<pre>${esc(i.output || i.detail)}</pre>` : ''}</td><td class="n">${i.ms ? (i.ms / 1000).toFixed(1) + 's' : ''}</td></tr>`).join('');
    return `<section><h2>${esc(s.name)} ${badge}<span class="cnt">${s.items.length - bad.length}/${s.items.length}</span></h2>${s.report ? `<p><a href="${esc(s.report.replace(/^reports\//, ''))}">Open the detailed Playwright report &rarr;</a></p>` : ''}${s.known?.length ? `<div class="known"><b>Known issues (not blocking)</b><ul>${[...new Set(s.known)].map(k => `<li>${esc(k)}</li>`).join('')}</ul></div>` : ''}<details${bad.length ? ' open' : ''}><summary>${bad.length ? bad.length + ' problem(s)' : 'all ' + s.items.length + ' passed'}</summary><table>${rows}</table></details></section>`;
  };
  const html = `<!doctype html><html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>Hadrian test report</title><style>
:root{--bg:#fbfbfd;--fg:#1d1d1f;--mut:#6e6e73;--card:#fff;--line:#e5e5ea;--ok:#1d8a3a;--fail:#c4302b;--warn:#a86400;--okbg:#e7f6eb;--failbg:#fdecea;--warnbg:#fff4e0}
@media (prefers-color-scheme:dark){:root{--bg:#000;--fg:#f5f5f7;--mut:#a1a1a6;--card:#1c1c1e;--line:#38383a;--ok:#30d158;--fail:#ff6961;--warn:#ffb340;--okbg:#0f2a17;--failbg:#3a1512;--warnbg:#3a2a0e}}
body{margin:0;background:var(--bg);color:var(--fg);font:15px/1.5 -apple-system,BlinkMacSystemFont,"Segoe UI",system-ui,sans-serif}
main{max-width:980px;margin:0 auto;padding:32px 16px 64px}h1{font-size:28px;margin:0 0 4px}.meta{color:var(--mut);margin:0 0 24px}
.verdict{display:inline-block;padding:6px 14px;border-radius:999px;font-weight:600;margin-bottom:24px}.verdict.ok{background:var(--okbg);color:var(--ok)}.verdict.fail{background:var(--failbg);color:var(--fail)}
section{background:var(--card);border:1px solid var(--line);border-radius:14px;padding:16px 20px;margin:0 0 16px}h2{font-size:17px;margin:0 0 8px;display:flex;gap:10px;align-items:center}
.b{font-size:12px;padding:2px 8px;border-radius:999px;font-weight:600}.b.ok{background:var(--okbg);color:var(--ok)}.b.fail{background:var(--failbg);color:var(--fail)}.b.warn{background:var(--warnbg);color:var(--warn)}
.cnt{margin-left:auto;color:var(--mut);font-weight:400;font-size:14px}table{width:100%;border-collapse:collapse;margin-top:8px}td{border-top:1px solid var(--line);padding:6px 4px;vertical-align:top}
td:first-child{width:22px;color:var(--ok)}tr.fail td:first-child{color:var(--fail)}tr.warn td:first-child{color:var(--warn)}tr.skip{color:var(--mut)}.n{text-align:right;color:var(--mut);white-space:nowrap;width:60px}
pre{white-space:pre-wrap;word-break:break-word;background:var(--bg);border:1px solid var(--line);border-radius:8px;padding:8px;font-size:12px;max-height:320px;overflow:auto}
.why,.fix{color:var(--mut);font-size:13px}.known{background:var(--warnbg);border-radius:10px;padding:8px 12px;margin:8px 0;font-size:14px}summary{cursor:pointer;color:var(--mut)}a{color:inherit}
</style></head><body><main><h1>Hadrian test report</h1><p class="meta">${esc(summary.startedAt)} &middot; commit ${esc(summary.commit || '?')} &middot; ${esc(summary.baseUrl)} &middot; tiers: ${esc(summary.tiers.join(', '))}</p>
<div class="verdict ${summary.ok === false ? 'fail' : 'ok'}">${summary.ok === false ? 'FAILED' : summary.ok ? 'PASSED' : 'incomplete'}</div>
${summary.sections.map(sec).join('')}</main></body></html>`;
  fs.writeFileSync(path.join(REPORTS_DIR, 'index.html'), html);
}
