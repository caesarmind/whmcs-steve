/* check-release-package.mjs -- the release zip is what the install guide says it is.
   ---------------------------------------------------------------------------
   Builds a throwaway release from the working tree with
   hadrian/scripts/package.mjs and reads it back with PHP's ZipArchive
   (release-zip-dump.php), a second implementation, because the zip is written
   by hand-rolled code. Then:

     - the four folders a buyer uploads are there, and nothing sits outside them
     - nothing that must never ship is in it (SCSS, source maps, the cart's
       archive, anything an admin uploaded on Branding or in the media library)
     - one version: Hadrian.php, core/hadrian.php, theme.json and the three
       release.json marks all carry the number the build was given
     - every file the addon's Setup page looks for on a buyer's server is in
       the zip, so a fresh upload of this zip passes its own Files step
     - the integrity hashes describe the zipped files, byte for byte: a wrong
       hash blocks the buyer's whole site
     - text is stored with LF, whatever this checkout's line endings are
     - the install guide still names each of the four upload targets

   The license files are stand-ins made here; the real ones live in another
   repository and carry a secret this check has no business reading.

     node tests/static/check-release-package.mjs
*/
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import { spawnSync } from 'node:child_process';
import { fileURLToPath } from 'node:url';
import { PHP } from '../lib/env.mjs';

const HERE = path.dirname(fileURLToPath(import.meta.url));
const ROOT = path.resolve(HERE, '..', '..');
const VERSION = '0.0.1';
const ROOTS = ['templates/hadrian/', 'templates/orderforms/hadrian_cart/', 'modules/addons/Hadrian/', 'includes/hooks/'];
const NEVER = [/\.scss$/, /\.map$/, /\/_archive\//, /\/assets\/img\/(branding|media)\//, /(^|\/)\.gitignore$/];

const tmp = fs.mkdtempSync(path.join(os.tmpdir(), 'hadrian-release-check-'));
const problems = [];
const bad = msg => problems.push(msg);

try {
  // Stand-in license files. The first carries the loader line an encoder
  // writes, which is what the packager looks for before it will ship one.
  const hooks = path.join(tmp, 'hooks');
  fs.mkdirSync(hooks);
  fs.writeFileSync(path.join(hooks, 'hostnodes_theme_license.php'), "<?php //0046a\nif(!extension_loaded('ionCube Loader')){die('stand-in');}\r\n");
  fs.writeFileSync(path.join(hooks, 'hostnodes_license_config.php'), "<?php\ndefine('HOSTNODES_LICENSE_KEY', '');\n");

  const built = spawnSync(process.execPath, [
    path.join(ROOT, 'hadrian', 'scripts', 'package.mjs'),
    '--out', tmp, '--hooks', hooks, '--version', VERSION, '--allow-dirty',
  ], { cwd: ROOT, encoding: 'utf8' });
  if (built.status !== 0) {
    console.log('  the release did not build:');
    for (const line of `${built.stdout || ''}${built.stderr || ''}`.trim().split('\n').slice(-12)) console.log('   ' + line);
    process.exit(1);
  }

  const zip = path.join(tmp, `Hadrian-${VERSION}.zip`);
  const dumped = spawnSync(PHP, [path.join(HERE, 'release-zip-dump.php'), zip], { encoding: 'utf8', maxBuffer: 64 * 1024 * 1024 });
  if (dumped.status !== 0) {
    console.log(`  PHP could not read the zip: ${(dumped.stderr || dumped.stdout || '').trim().split('\n').slice(-3).join(' | ')}`);
    process.exit(1);
  }
  const { entries, contents, crlf, probe } = JSON.parse(dumped.stdout);
  const names = Object.keys(entries);

  // Layout.
  for (const root of ROOTS) {
    if (!names.some(n => n.startsWith(root))) bad(`nothing under ${root}`);
  }
  const stray = names.filter(n => !ROOTS.some(root => n.startsWith(root)));
  if (stray.length) bad(`outside the four folders: ${stray.slice(0, 5).join(', ')}`);
  const never = names.filter(n => NEVER.some(re => re.test(n)));
  if (never.length) bad(`must never ship: ${never.slice(0, 5).join(', ')}`);

  // One version.
  const carried = {
    'Hadrian.php': (contents['modules/addons/Hadrian/Hadrian.php'].match(/'version'\s*=>\s*'([^']*)'/) || [])[1],
    'core/hadrian.php': (contents['templates/hadrian/core/hadrian.php'].match(/'version'\s*=>\s*'([^']*)'/) || [])[1],
    'theme.json': JSON.parse(contents['templates/hadrian/theme.json']).version,
    'theme release.json': JSON.parse(contents['templates/hadrian/release.json'] || '{}').release,
    'cart release.json': JSON.parse(contents['templates/orderforms/hadrian_cart/release.json'] || '{}').release,
    'addon release.json': JSON.parse(contents['modules/addons/Hadrian/release.json'] || '{}').release,
  };
  for (const [where, v] of Object.entries(carried)) {
    if (v !== VERSION) bad(`${where} carries "${v}", not ${VERSION}`);
  }

  // What the Setup page will look for.
  for (const file of [...probe.theme, ...probe.cart, probe.hook]) {
    if (!(file in entries)) bad(`the Setup page checks for ${file}, and the zip does not have it`);
  }

  // Integrity hashes against the zipped bytes.
  const hashes = [...(contents['modules/addons/Hadrian/src/Helpers/IntegrityHashes.php'] || '').matchAll(/'([^']+)'\s*=>\s*'([0-9a-f]{64})'/g)];
  if (!hashes.length) bad('IntegrityHashes.php carries no hashes');
  for (const [, file, hash] of hashes) {
    if (entries[file] !== hash) bad(`integrity hash for ${file} does not match the file in the zip`);
  }

  if (crlf.length) bad(`${crlf.length} text file(s) stored with CRLF, e.g. ${crlf[0]}`);

  // The guide and the zip describe the same four uploads.
  const guide = fs.readFileSync(path.join(ROOT, 'hadrian-documentation', 'content', 'client-theme', '02-installation.md'), 'utf8');
  for (const target of ['/templates/', '/modules/addons/', '/templates/orderforms/', '/includes/hooks/', 'hostnodes_theme_license.php']) {
    if (!guide.includes(target)) bad(`02-installation.md no longer mentions ${target}`);
  }

  if (problems.length) {
    for (const p of problems) console.log('  FAIL  ' + p);
    console.log(`\n  ${problems.length} problem(s) in the release zip.`);
    process.exit(1);
  }
  console.log(`  ${names.length} files in four folders, one version, ${hashes.length} integrity hashes match, ${probe.theme.length + probe.cart.length + 1} Setup files present`);
} finally {
  fs.rmSync(tmp, { recursive: true, force: true });
}
