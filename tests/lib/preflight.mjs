// Preflight: prove the environment is the one we think it is BEFORE testing
// the theme. Each check carries the fix, because a red preflight is a setup
// problem, not a theme bug, and should say what to run.

import fs from 'node:fs';
import { spawnSync } from 'node:child_process';
import { BASE_URL, PHP, JUNCTIONS, TESTS_DIR, REPO_ROOT } from './env.mjs';
import path from 'node:path';

const same = (a, b) => path.resolve(a).toLowerCase() === path.resolve(b).toLowerCase();

function php(script) {
  const r = spawnSync(PHP, [path.join(TESTS_DIR, 'php', script)], { encoding: 'utf8', cwd: REPO_ROOT });
  return { status: r.status, out: (r.stdout || '').trim(), err: (r.stderr || '').trim() };
}

export async function preflight({ ensureFixtures = true } = {}) {
  const checks = [];
  const add = (name, ok, detail, fix) => checks.push({ name, ok, detail, fix });

  // 1. Is anything listening?
  let up = false;
  try {
    // 90s, not 15: the first request after Apache starts cold boots WHMCS and
    // compiles templates, and took longer than 15s right after START-SERVER.
    const r = await fetch(BASE_URL + '/', { redirect: 'manual', signal: AbortSignal.timeout(90000) });
    up = r.status > 0;
    add('stack reachable', up, `${BASE_URL} -> HTTP ${r.status}`, 'Start it: scripts/local-stack/START-SERVER.bat');
  } catch (e) {
    add('stack reachable', false, `${BASE_URL} -> ${e.cause?.code || e.message}`, 'Start it: scripts/local-stack/START-SERVER.bat');
  }
  if (!up) return { ok: false, checks };

  // 2. The junctions point at THIS checkout.
  for (const j of JUNCTIONS) {
    let real = null;
    try { real = fs.realpathSync(j.link); } catch {}
    add(`serves this checkout: ${path.basename(j.target)}`, !!real && same(real, j.target),
      real ? `${j.link} -> ${real}` : `${j.link} missing`,
      'Re-create the junction (scripts/local-stack/README.md, "The repo is mounted, not copied")');
  }

  // 3. WHMCS configuration.
  const p = php('preflight.php');
  let s = null;
  try { s = JSON.parse(p.out); } catch {}
  if (!s || s.ok === false) {
    add('WHMCS boots', false, s?.error || p.err || p.out.slice(0, 200), 'Check C:/laragon/www/whmcs-local-error.log');
    return { ok: false, checks };
  }
  add('install/ removed', !s.installDirPresent, s.installDirPresent ? 'install/ still present - every page shows "Security Warning"' : 'ok',
    'Delete C:/laragon/www/whmcs/install');
  if (s.installDirPresent) return { ok: false, checks, state: s };

  add('SystemURL is this server', same(s.systemUrl.replace(/\/$/, ''), BASE_URL) || s.systemUrl.replace(/\/$/, '') === BASE_URL,
    s.systemUrl, 'Set SystemURL in tblconfiguration');
  add('client template = hadrian', s.template === 'hadrian', s.template, 'php scripts/local-stack/post-install.php');
  add('order form = hadrian_cart', s.orderFormTemplate === 'hadrian_cart', s.orderFormTemplate, 'php scripts/local-stack/post-install.php');
  add('addon active', s.activeAddonModules.includes('Hadrian'), s.activeAddonModules.join(',') || '(none)', 'php scripts/local-stack/post-install.php');
  add('addon hooks load', s.addonModulesHooks.includes('Hadrian'), s.addonModulesHooks.join(',') || '(empty - every $hadrianLang string renders blank)',
    'php scripts/local-stack/post-install.php');
  add('addon tables migrated', s.hadrianTables >= 5, `${s.hadrianTables} hadrian_* tables, ${s.hadrianMenus} menus`, 'php scripts/local-stack/post-install.php');
  add('demo data seeded', s.counts.clients > 0 && s.counts.products > 0, JSON.stringify(s.counts), 'php scripts/local-stack/seed-demo-data.php');
  add('a payment gateway is active', s.paymentGateways.length > 0, s.paymentGateways.join(',') || '(none - checkout cannot complete)',
    'Activate banktransfer (scripts/local-stack/README.md)');

  // 4. Personas + ids. Idempotent: ensures, never resets.
  if (ensureFixtures && checks.every(c => c.ok)) {
    const f = php('fixtures.php');
    add('fixtures ensured', f.status === 0, f.status === 0 ? f.out.split('\n').slice(0, 4).join(' | ') : (f.err || f.out).slice(0, 300),
      'php scripts/local-stack/seed-demo-data.php, then re-run');
  }

  return { ok: checks.every(c => c.ok), checks, state: s };
}
