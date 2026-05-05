#!/usr/bin/env node
// scripts/package.mjs — bundle a distributable zip.
//
// Run: npm run package

import { execSync } from 'node:child_process';
import { existsSync, mkdirSync, readFileSync } from 'node:fs';
import { resolve, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';

const __dirname = dirname(fileURLToPath(import.meta.url));
const root = resolve(__dirname, '..');

const pkg = JSON.parse(readFileSync(resolve(root, 'package.json'), 'utf8'));
const version = pkg.version;

const distDir = resolve(root, 'dist');
if (!existsSync(distDir)) mkdirSync(distDir, { recursive: true });

const zipName = `MyTheme-${version}.zip`;
const zipPath = resolve(distDir, zipName);

console.log(`Packaging ${zipName}...`);

// Excludes: source files, build artifacts, anything not needed by buyers
const excludes = [
  'node_modules/*',
  'scripts/*',
  'dist/*',
  '.git/*',
  '.gitignore',
  'package*.json',
  'docs/*',
  'README.md',
  'BUILD.md',
  'LICENSING-SETUP.md',
  '**/*.scss',
  '**/*.map',
  '**/*.ts',
];

const excludeArgs = excludes.map(p => `-x "${p}"`).join(' ');

try {
  // Requires `zip` on PATH (built-in on macOS/Linux; install on Windows)
  execSync(
    `zip -r "${zipPath}" modules templates ${excludeArgs}`,
    { cwd: root, stdio: 'inherit' }
  );
  console.log(`\n✓ ${zipPath}`);
} catch (e) {
  console.error('Packaging failed. Is `zip` available on PATH?');
  process.exit(1);
}
