#!/usr/bin/env node
// scripts/package.mjs -- build the release zip a buyer extracts at their WHMCS root.
//
//   node hadrian/scripts/package.mjs --hooks <dir> [--version 1.8.0]
//   npm run package -- --hooks <dir>
//
// The zip mirrors a WHMCS install, so installing is "extract here":
//
//   templates/hadrian/                    <- hadrian/templates/hadrian
//   templates/orderforms/hadrian_cart/    <- hadrian_cart          (repo root)
//   modules/addons/Hadrian/               <- hadrian/modules/addons/Hadrian
//   includes/hooks/                       <- the two license files in --hooks
//
// What goes in is what git tracks, read from the working tree. So a generated
// stylesheet, an editor backup or anything else git ignores never reaches a
// buyer, and the zip matches what a push to main deploys. Because of that it
// refuses to run while those folders have uncommitted changes or new files
// git has not been told about.
//
// One release version. The number comes from --version, or "version" in
// hadrian/package.json. It is written into the PACKAGED copies of
// Hadrian.php, core/hadrian.php and theme.json, and into a release.json in
// each of the three folders, which the addon's Setup page compares to catch a
// half-finished upload. The working tree is never changed: its own numbers
// keep doing their day job (core/hadrian.php is the CSS cache-buster and is
// bumped far more often than releases happen).
//
// Options
//   --hooks <dir>        folder holding hostnodes_theme_license.php and
//                        hostnodes_license_config.php. Required.
//   --version <x.y.z>    release version. Default: hadrian/package.json.
//   --out <dir>          where the zip and the stage folder go. Default: hadrian/dist.
//   --allow-dirty        package uncommitted work too (test builds only): tracked
//                        files as they are on disk, plus untracked files git
//                        does not ignore.
//   --allow-plain-hook   accept a license hook that is not encoded (test builds
//                        only: in plain form the licence check can simply be edited out).
//   --stage-only         stop after staging and stamping, so the PHP in
//                        <out>/stage can be encoded.
//   --from-stage         pick up an existing <out>/stage: hash it and zip it.
//
// No dependencies: the zip is written with node:zlib, so this runs on a
// machine with no `zip` binary and no npm install.

import { execFileSync } from 'node:child_process';
import { existsSync, mkdirSync, readFileSync, readdirSync, rmSync, statSync, writeFileSync } from 'node:fs';
import { dirname, join, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';
import zlib from 'node:zlib';
import { writeIntegrityHashes } from './inject-integrity-hashes.mjs';

const here = dirname(fileURLToPath(import.meta.url));
const hadrianRoot = resolve(here, '..');
const repoRoot = resolve(hadrianRoot, '..');

/** What ships, and where it lands under the WHMCS root. */
const SOURCES = [
  { name: 'theme', from: 'hadrian/templates/hadrian', to: 'templates/hadrian', skip: [] },
  { name: 'order form', from: 'hadrian_cart', to: 'templates/orderforms/hadrian_cart', skip: [/^_archive\//, /^README\.md$/] },
  { name: 'addon', from: 'hadrian/modules/addons/Hadrian', to: 'modules/addons/Hadrian', skip: [/^src\/Helpers\/IntegrityHashes\.php$/] },
];
const HOOKS_TO = 'includes/hooks';
const HOOK_FILES = ['hostnodes_theme_license.php', 'hostnodes_license_config.php'];
/** The licence hook, which must ship encoded so its check cannot be edited out. */
const SECRET_HOOK = 'hostnodes_theme_license.php';

/** Never shipped, wherever they sit. */
const SKIP_ANYWHERE = [/\.scss$/i, /\.map$/i, /\.ts$/i, /(^|\/)\.gitignore$/, /(^|\/)\.gitkeep$/, /(^|\/)\.DS_Store$/, /(^|\/)Thumbs\.db$/i, /^release\.json$/];

/** Text files are stored with LF, the way git holds them, whatever this checkout's line endings are. */
const TEXT = /\.(php|tpl|css|js|mjs|json|ya?ml|html?|svg|txt|md|xml)$|(^|\/)\.htaccess$/i;

const fail = message => { console.error(`\nPackaging stopped: ${message}`); process.exit(1); };

// ------------------------------------------------------------------- options
const argv = process.argv.slice(2);
const flag = name => argv.includes(name);
const opt = name => { const i = argv.indexOf(name); return i >= 0 && argv[i + 1] && !argv[i + 1].startsWith('--') ? argv[i + 1] : null; };

const outDir = resolve(opt('--out') || join(hadrianRoot, 'dist'));
const stage = join(outDir, 'stage');
const version = opt('--version') || JSON.parse(readFileSync(join(hadrianRoot, 'package.json'), 'utf8')).version;
if (!/^\d+\.\d+\.\d+(-[0-9A-Za-z.]+)?$/.test(version || '')) {
  fail(`"${version}" is not a release version. Use three numbers, such as 1.8.0 (--version, or "version" in hadrian/package.json).`);
}
if (flag('--stage-only') && flag('--from-stage')) fail('--stage-only and --from-stage cannot be used together.');

// --------------------------------------------------------------------- stage
if (!flag('--from-stage')) {
  const hooksDir = opt('--hooks');
  if (!hooksDir) {
    fail(`--hooks <dir> is required: the folder that holds ${HOOK_FILES.join(' and ')}.`);
  }
  for (const file of HOOK_FILES) {
    if (!existsSync(join(hooksDir, file))) fail(`${file} is not in ${resolve(hooksDir)}.`);
  }
  // Looked at, never printed.
  if (!looksEncoded(readFileSync(join(hooksDir, SECRET_HOOK))) && !flag('--allow-plain-hook')) {
    fail(`${SECRET_HOOK} is not encoded. In plain form anyone can edit the licence check out of it, so it must not go into a release. `
       + 'Encode it first, or pass --allow-plain-hook for a test build that will not be given to anyone.');
  }

  const dirty = git(['status', '--porcelain', '--', ...SOURCES.map(s => s.from)]).split('\n').filter(Boolean);
  if (dirty.length && !flag('--allow-dirty')) {
    fail(`${dirty.length} uncommitted change(s) in the folders that ship:\n`
       + dirty.slice(0, 8).map(l => `    ${l}`).join('\n') + (dirty.length > 8 ? `\n    ... and ${dirty.length - 8} more` : '')
       + '\n  A release is built from committed files. Commit or stash them, or pass --allow-dirty for a test build.');
  }

  rmSync(stage, { recursive: true, force: true });
  let count = 0;
  for (const source of SOURCES) {
    const listed = git(['ls-files', '-z', ...(flag('--allow-dirty') ? ['--cached', '--others', '--exclude-standard'] : []), '--', source.from])
      .split('\0').filter(Boolean);
    let kept = 0;
    for (const path of [...new Set(listed)]) {
      const rel = path.slice(source.from.length + 1);
      if ([...SKIP_ANYWHERE, ...source.skip].some(re => re.test(rel))) continue;
      const abs = join(repoRoot, path);
      if (!existsSync(abs)) continue; // deleted on disk, only reachable with --allow-dirty
      put(join(stage, source.to, rel), stored(rel, readFileSync(abs)));
      kept++;
    }
    if (!kept) fail(`nothing to package for the ${source.name}: git lists no files under ${source.from}.`);
    console.log(`  ${source.to.padEnd(36)} ${String(kept).padStart(4)} files`);
    count += kept;
  }
  // Byte for byte: an encoded file must not have its line endings touched.
  for (const file of HOOK_FILES) {
    put(join(stage, HOOKS_TO, file), readFileSync(join(hooksDir, file)));
  }
  console.log(`  ${HOOKS_TO.padEnd(36)} ${String(HOOK_FILES.length).padStart(4)} files`);

  stamp();
  console.log(`  release ${version} stamped into the addon, the theme and the order form`);

  if (flag('--stage-only')) {
    console.log(`\nStaged in ${stage}\nEncode the PHP there, then run this again with --from-stage.`);
    process.exit(0);
  }
} else if (!existsSync(stage)) {
  fail(`there is no stage folder at ${stage}. Run without --from-stage first.`);
}

// ------------------------------------------------------------ hash and check
// Last change to the tree, so the hashes describe the files a buyer receives.
try {
  writeIntegrityHashes(stage, () => {});
} catch (e) {
  fail(e.message);
}
verify();

// ----------------------------------------------------------------------- zip
const files = walk(stage).sort();
const zipPath = join(outDir, `Hadrian-${version}.zip`);
writeZip(zipPath, files.map(rel => ({ name: rel, data: readFileSync(join(stage, rel)) })));
console.log(`\nHadrian ${version}: ${files.length} files, ${(statSync(zipPath).size / 1024 / 1024).toFixed(2)} MB`);
for (const top of [...SOURCES.map(s => s.to), HOOKS_TO]) {
  console.log(`  ${(top + '/').padEnd(37)} ${String(files.filter(f => f.startsWith(top + '/')).length).padStart(4)} files`);
}
console.log(`\n${zipPath}`);

// ================================================================= functions

function git(args) {
  try {
    return execFileSync('git', ['-c', 'core.quotepath=off', ...args], { cwd: repoRoot, encoding: 'utf8', maxBuffer: 64 * 1024 * 1024 });
  } catch (e) {
    fail(`git ${args[0]} did not run (${e.message.split('\n')[0]}). This script lists the files to ship with git.`);
  }
}

/**
 * Has this PHP file been through ionCube or SourceGuardian? Judged by the
 * loader stub an encoder puts at the top, not by the word appearing somewhere:
 * the plain license hook says "ionCube" in a comment, and several plain files
 * here carry a "will be ionCube-encoded" note.
 */
function looksEncoded(buf) {
  const head = buf.subarray(0, 4096).toString('latin1');
  return /^<\?php\s*\/\/0[0-9a-f]{3,}/i.test(head)
      || /extension_loaded\(\s*['"]ionCube Loader['"]\s*\)/.test(head)
      || /function_exists\(\s*['"]sg_load['"]\s*\)/.test(head);
}

function put(path, data) {
  mkdirSync(dirname(path), { recursive: true });
  writeFileSync(path, data);
}

/** The bytes to ship: text with LF line endings, everything else untouched. */
function stored(rel, buf) {
  if (!TEXT.test(rel) || buf.includes(0)) return buf;
  return Buffer.from(buf.toString('latin1').replace(/\r\n/g, '\n'), 'latin1');
}

/** Write the release version into the staged copies. Each edit must hit exactly one place. */
function stamp() {
  const once = (rel, pattern, what) => {
    const path = join(stage, rel);
    const src = readFileSync(path, 'utf8');
    const hits = src.match(new RegExp(pattern.source, pattern.flags.replace('g', '') + 'g')) || [];
    if (hits.length !== 1) fail(`expected one ${what} in ${rel}, found ${hits.length}. The version was not stamped.`);
    writeFileSync(path, src.replace(pattern, `$1${version}$3`));
  };
  once('modules/addons/Hadrian/Hadrian.php', /('version'\s*=>\s*')([^']*)(')/, "'version' => '...'");
  once('templates/hadrian/core/hadrian.php', /('version'\s*=>\s*')([^']*)(')/, "'version' => '...'");
  // Two spaces of indent at most: a "version" nested inside another key is not this one.
  once('templates/hadrian/theme.json', /(^[ \t]{0,2}"version"\s*:\s*")([^"]*)(")/m, 'top-level "version"');

  // The vendor name has one source, the addon's src/Brand.php; theme.json is
  // static JSON, so its "author" is copied from there at build time.
  const brand = readFileSync(join(stage, 'modules/addons/Hadrian/src/Brand.php'), 'utf8')
    .replace(/\/\*[\s\S]*?\*\//g, '').replace(/\/\/.*$/gm, '');
  const vendor = brand.match(/const\s+VENDOR\s*=\s*'([^']*)'/)?.[1];
  if (!vendor) fail('no VENDOR constant in modules/addons/Hadrian/src/Brand.php. The author was not stamped.');
  const themeJson = join(stage, 'templates/hadrian/theme.json');
  const theme = readFileSync(themeJson, 'utf8');
  const authorRe = /(^[ \t]{0,2}"author"\s*:\s*)"[^"]*"/m;
  if (!authorRe.test(theme)) fail('expected a top-level "author" in templates/hadrian/theme.json. The author was not stamped.');
  writeFileSync(themeJson, theme.replace(authorRe, `$1${JSON.stringify(vendor)}`));

  const mark = JSON.stringify({ release: version, built: new Date().toISOString().slice(0, 10) }) + '\n';
  for (const source of SOURCES) put(join(stage, source.to, 'release.json'), mark);
}

/** The staged tree is what the install guide describes, and carries one version. */
function verify() {
  const need = [
    ...SOURCES.map(s => `${s.to}/release.json`),
    ...HOOK_FILES.map(f => `${HOOKS_TO}/${f}`),
    'templates/hadrian/theme.json', 'templates/hadrian/core/hadrian.php', 'templates/hadrian/header.tpl',
    'templates/orderforms/hadrian_cart/theme.yaml', 'templates/orderforms/hadrian_cart/products.tpl',
    'modules/addons/Hadrian/Hadrian.php', 'modules/addons/Hadrian/hooks.php',
    'modules/addons/Hadrian/src/Helpers/IntegrityHashes.php',
  ];
  const missing = need.filter(rel => !existsSync(join(stage, rel)));
  if (missing.length) fail(`the staged release is incomplete. Missing:\n${missing.map(m => `    ${m}`).join('\n')}`);

  const read = rel => readFileSync(join(stage, rel), 'utf8');
  // A PHP file that was encoded after staging (--from-stage) cannot be read
  // back; it was stamped before it was encoded, so it is taken as given.
  const phpVersion = rel => {
    const src = read(rel);
    return looksEncoded(Buffer.from(src, 'utf8')) ? version : (src.match(/'version'\s*=>\s*'([^']*)'/) || [])[1];
  };
  const found = {
    'Hadrian.php': phpVersion('modules/addons/Hadrian/Hadrian.php'),
    'core/hadrian.php': phpVersion('templates/hadrian/core/hadrian.php'),
    'theme.json': JSON.parse(read('templates/hadrian/theme.json')).version,
    ...Object.fromEntries(SOURCES.map(s => [`${s.to}/release.json`, JSON.parse(read(`${s.to}/release.json`)).release])),
  };
  const wrong = Object.entries(found).filter(([, v]) => v !== version);
  if (wrong.length) fail(`these do not carry version ${version}: ${wrong.map(([k, v]) => `${k} (${v})`).join(', ')}.`);
}

/** Every file under dir, as forward-slash paths relative to it. */
function walk(dir, prefix = '') {
  const out = [];
  for (const entry of readdirSync(dir, { withFileTypes: true })) {
    const rel = prefix ? `${prefix}/${entry.name}` : entry.name;
    if (entry.isDirectory()) out.push(...walk(join(dir, entry.name), rel));
    else if (entry.isFile()) out.push(rel);
  }
  return out;
}

/**
 * A plain .zip: deflate, UTF-8 names, no zip64 (a release is a few megabytes).
 * Entries are files only; every unzip tool creates the folders they name.
 */
function writeZip(path, entries) {
  if (entries.length > 65535) fail('too many files for a plain zip.');
  const now = new Date();
  const dosTime = (now.getHours() << 11) | (now.getMinutes() << 5) | (now.getSeconds() >> 1);
  const dosDate = ((now.getFullYear() - 1980) << 9) | ((now.getMonth() + 1) << 5) | now.getDate();
  const UNIX_FILE = ((0o100644 << 16) >>> 0);   // rw-r--r-- when extracted on Linux

  const chunks = [];
  const central = [];
  let offset = 0;
  for (const { name, data } of entries) {
    const nameBuf = Buffer.from(name, 'utf8');
    const deflated = zlib.deflateRawSync(data, { level: 9 });
    const method = deflated.length < data.length ? 8 : 0;
    const body = method === 8 ? deflated : data;
    const crc = zlib.crc32(data);

    const local = Buffer.alloc(30);
    local.writeUInt32LE(0x04034b50, 0);
    local.writeUInt16LE(20, 4);          // version needed
    local.writeUInt16LE(0x0800, 6);      // names are UTF-8
    local.writeUInt16LE(method, 8);
    local.writeUInt16LE(dosTime, 10);
    local.writeUInt16LE(dosDate, 12);
    local.writeUInt32LE(crc, 14);
    local.writeUInt32LE(body.length, 18);
    local.writeUInt32LE(data.length, 22);
    local.writeUInt16LE(nameBuf.length, 26);
    local.writeUInt16LE(0, 28);

    const dir = Buffer.alloc(46);
    dir.writeUInt32LE(0x02014b50, 0);
    dir.writeUInt16LE((3 << 8) | 20, 4); // made on Unix, so the mode below is honoured
    dir.writeUInt16LE(20, 6);
    dir.writeUInt16LE(0x0800, 8);
    dir.writeUInt16LE(method, 10);
    dir.writeUInt16LE(dosTime, 12);
    dir.writeUInt16LE(dosDate, 14);
    dir.writeUInt32LE(crc, 16);
    dir.writeUInt32LE(body.length, 20);
    dir.writeUInt32LE(data.length, 24);
    dir.writeUInt16LE(nameBuf.length, 28);
    dir.writeUInt32LE(UNIX_FILE, 38);
    dir.writeUInt32LE(offset, 42);

    chunks.push(local, nameBuf, body);
    central.push(dir, nameBuf);
    offset += local.length + nameBuf.length + body.length;
  }

  const centralBuf = Buffer.concat(central);
  if (offset + centralBuf.length > 0xffffffff) fail('the release is too large for a plain zip.');
  const end = Buffer.alloc(22);
  end.writeUInt32LE(0x06054b50, 0);
  end.writeUInt16LE(entries.length, 8);
  end.writeUInt16LE(entries.length, 10);
  end.writeUInt32LE(centralBuf.length, 12);
  end.writeUInt32LE(offset, 16);

  mkdirSync(dirname(path), { recursive: true });
  writeFileSync(path, Buffer.concat([...chunks, centralBuf, end]));
}
