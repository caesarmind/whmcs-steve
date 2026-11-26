// One test run at a time against the local site.
//
// The settings tier and its neighbours change what every request sees:
// settings, the email header, active addons, menus. `--workers 1` keeps them
// apart inside one run, but nothing kept two runs apart, and with several
// terminals (or several Claude sessions) testing this checkout at once, one
// run's email "stands down" removed Hadrian from ActiveAddonModules under
// another run's builder test, and one run emptied the other's Playwright
// output folder mid-test.
//
// The lock is tests/.local/site.lock: the holder's pid, command and start
// time. run.mjs takes it for every tier that needs the site, Playwright's
// globalSetup (lib/warmup.mjs) for a direct `playwright test`, and the
// coverage runner for its junction swap. The holder's token goes to its child
// processes in HADRIAN_SITE_LOCK_TOKEN, which lets them through: Playwright
// under run.mjs, the PHP drivers a spec runs (tests/php/site-lock.php). A lock
// whose process is gone is stale and is taken over.
//
// A second run waits, saying who holds the lock. --no-wait (run.mjs), or
// HADRIAN_SITE_LOCK_WAIT=0, refuses instead; HADRIAN_SITE_LOCK_WAIT=<minutes>
// changes how long it waits before giving up (default 60).

import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import { spawnSync } from 'node:child_process';
import { LOCAL_DIR, REPORTS_DIR, REPO_ROOT } from './env.mjs';

export const LOCK_FILE = path.join(LOCAL_DIR, 'site.lock');
export const TOKEN_ENV = 'HADRIAN_SITE_LOCK_TOKEN';
const POLL_MS = 2000;
const NOTE_EVERY_MS = 60_000;
// The lock is created empty and written a moment later. An unreadable lock
// younger than this is one being written; an older one is junk.
const WRITE_GRACE_MS = 10_000;

export class SiteLockBusy extends Error {
  constructor(holder, why) {
    super(`The local site is in use by another test run (${describe(holder)}):\n  ${holder?.command || '?'}\n${why}. Lock: ${rel(LOCK_FILE)}`);
    this.holder = holder;
  }
}

const rel = p => path.relative(REPO_ROOT, p).replace(/\\/g, '/');
const sleep = ms => new Promise(r => setTimeout(r, ms));
function dur(ms) {
  const s = Math.round(ms / 1000);
  return s < 60 ? `${s}s` : s < 3600 ? `${Math.floor(s / 60)}m ${s % 60}s` : `${Math.floor(s / 3600)}h ${Math.floor((s % 3600) / 60)}m`;
}
function describe(lock) {
  if (!lock || lock.unreadable) return 'a lock that is still being written';
  const at = new Date(lock.startedAt);
  const when = Number.isNaN(at.getTime()) ? '?' : `${at.toTimeString().slice(0, 8)}, ${dur(Date.now() - at.getTime())} ago`;
  return `pid ${lock.pid}, started ${when}`;
}

/** What this process was started as, with repo paths made relative. */
function commandLine() {
  const args = process.argv.slice(1).map(a => {
    if (!path.isAbsolute(a)) return a;
    const r = path.relative(REPO_ROOT, a);
    return r.startsWith('..') ? a : r.replace(/\\/g, '/');
  });
  return ['node', ...args].join(' ').slice(0, 400);
}

/** The current lock, null when there is none. */
export function readLock() {
  let raw = '';
  try { raw = fs.readFileSync(LOCK_FILE, 'utf8'); } catch (e) { if (e.code === 'ENOENT') return null; }
  try { const l = JSON.parse(raw); if (l && Number.isInteger(l.pid)) return l; } catch {}
  // Empty (being written), junk, or briefly unreadable: judged by its age.
  let mtimeMs = Date.now();
  try { mtimeMs = fs.statSync(LOCK_FILE).mtimeMs; } catch (e) { if (e.code === 'ENOENT') return null; }
  return { unreadable: true, raw, mtimeMs };
}

/**
 * Is process `pid` still running, and still the program that wrote the lock?
 * Windows hands pids out again quickly, so a killed run's pid can come back
 * as some other program: then the image name no longer matches.
 */
export function pidAlive(pid, exe = '') {
  if (!Number.isInteger(pid) || pid <= 0) return false;
  if (pid === process.pid) return true;
  try { process.kill(pid, 0); } catch (e) { if (e.code === 'ESRCH') return false; }
  if (process.platform === 'win32' && exe) {
    const r = spawnSync('tasklist', ['/FI', `PID eq ${pid}`, '/FO', 'CSV', '/NH'], { encoding: 'utf8', windowsHide: true });
    if (r.status === 0) {
      const m = (r.stdout || '').match(new RegExp(`^"([^"]+)","${pid}"`, 'm'));
      return !!m && m[1].toLowerCase() === String(exe).toLowerCase();
    }
  }
  return true;
}

const isStale = lock => (lock.unreadable ? Date.now() - lock.mtimeMs > WRITE_GRACE_MS : !pidAlive(lock.pid, lock.exe));

function waitSetting(wait) {
  const env = process.env.HADRIAN_SITE_LOCK_WAIT;
  const minutes = env === undefined || env === '' ? 60 : Number(env);
  if (wait === false || minutes === 0) return { wait: false, timeoutMs: 0, why: wait === false ? 'Not waiting (--no-wait)' : 'Not waiting (HADRIAN_SITE_LOCK_WAIT=0)' };
  return { wait: true, timeoutMs: (Number.isFinite(minutes) && minutes > 0 ? minutes : 60) * 60_000 };
}

/**
 * Take the site lock, waiting for another run to finish first.
 *
 * Returns { nested, release }. `nested` is true when an ancestor holds the
 * lock (Playwright under run.mjs): nothing is taken, release does nothing.
 * Otherwise the lock is released on release() or when the process exits.
 * Throws SiteLockBusy when it does not wait, or waits past the limit.
 */
export async function acquireSiteLock({ wait, log = m => console.log(m) } = {}) {
  const inherited = process.env[TOKEN_ENV];
  if (inherited) {
    const held = readLock();
    if (held?.token === inherited && pidAlive(held.pid, held.exe)) return { nested: true, holder: held, waitedMs: 0, release() {} };
  }
  const { wait: willWait, timeoutMs, why } = waitSetting(wait);
  const me = {
    pid: process.pid, ppid: process.ppid, exe: path.basename(process.execPath),
    token: `${process.pid}-${crypto.randomBytes(8).toString('hex')}`,
    command: commandLine(), cwd: process.cwd(), startedAt: new Date().toISOString(),
  };
  fs.mkdirSync(LOCAL_DIR, { recursive: true });
  const t0 = Date.now();
  let shown = null, noted = 0;
  for (;;) {
    // startedAt is when the lock was taken, not when this run began waiting.
    me.startedAt = new Date().toISOString();
    try { fs.writeFileSync(LOCK_FILE, JSON.stringify(me, null, 2) + '\n', { flag: 'wx' }); break; }
    catch (e) { if (e.code !== 'EEXIST') throw e; }
    const held = readLock();
    if (!held) continue;                       // released between the two calls
    if (isStale(held)) {
      // Read it once more right before removing it, so a lock another
      // waiter has just taken over is not removed as well.
      const again = readLock();
      if (again && (again.token ?? again.raw) === (held.token ?? held.raw)) {
        try { fs.unlinkSync(LOCK_FILE); } catch {}
        log(held.unreadable
          ? `site lock: removed an unreadable ${rel(LOCK_FILE)}`
          : `site lock: took over a stale lock, pid ${held.pid} is no longer running (${held.command || '?'})`);
      }
      continue;
    }
    if (!willWait) throw new SiteLockBusy(held, why);
    if (Date.now() - t0 > timeoutMs) throw new SiteLockBusy(held, `Gave up after waiting ${dur(timeoutMs)} (HADRIAN_SITE_LOCK_WAIT=<minutes> sets the limit)`);
    if (shown !== (held.token ?? held.raw)) {
      shown = held.token ?? held.raw; noted = Date.now();
      log(`Waiting for the local site: another test run is using it (${describe(held)}):\n  ${held.command || '?'}\n`
        + `  Runs that use the site go one at a time, so this one starts when that one ends.\n`
        + `  To refuse instead: run.mjs --no-wait, or HADRIAN_SITE_LOCK_WAIT=0 for any run.`);
    } else if (Date.now() - noted >= NOTE_EVERY_MS) {
      noted = Date.now();
      log(`  still waiting for the site lock (${dur(Date.now() - t0)})`);
    }
    await sleep(POLL_MS);
  }
  process.env[TOKEN_ENV] = me.token;
  let released = false;
  const release = () => {
    if (released) return;
    released = true;
    process.removeListener('exit', release);
    if (readLock()?.token === me.token) { try { fs.unlinkSync(LOCK_FILE); } catch {} }
  };
  process.on('exit', release);
  const waitedMs = Date.now() - t0;
  if (shown) log(`site lock: taken after waiting ${dur(waitedMs)}`);
  return { nested: false, holder: me, waitedMs, release };
}

// ------------------------------------------------- Playwright output folders
// Playwright empties its outputDir when a run starts, so two invocations
// sharing one deleted each other's traces mid-test. Each invocation gets its
// own: <tag>-<pid of the Playwright runner>. Called from the config, which the
// runner loads before it starts its workers; the id goes into the environment
// so every worker computes the same folder.
export const OUTPUT_ROOT = path.join(REPORTS_DIR, 'output');
const RUN_ENV = 'HADRIAN_PW_RUN';

export function playwrightOutputDir(tag) {
  process.env[RUN_ENV] ||= String(process.pid);
  return path.join(OUTPUT_ROOT, `${tag}-${process.env[RUN_ENV]}`);
}

/** Remove the output folders of Playwright runs that have ended. */
export function pruneOutputDirs() {
  let entries = [];
  try { entries = fs.readdirSync(OUTPUT_ROOT, { withFileTypes: true }); } catch { return; }
  const exe = path.basename(process.execPath);
  for (const e of entries) {
    const pid = Number((e.name.match(/-(\d+)$/) || [])[1]);
    if (!e.isDirectory() || !pid || String(pid) === process.env[RUN_ENV] || pidAlive(pid, exe)) continue;
    try { fs.rmSync(path.join(OUTPUT_ROOT, e.name), { recursive: true, force: true }); } catch {}
  }
}
