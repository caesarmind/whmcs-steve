#!/usr/bin/env node
// scripts/build-js.mjs — bundle theme JS with esbuild.
//
// Run: npm run build:js

import { build, context } from 'esbuild';
import { resolve, dirname } from 'node:path';
import { fileURLToPath, } from 'node:url';
import { existsSync, mkdirSync } from 'node:fs';

const __dirname = dirname(fileURLToPath(import.meta.url));
const root = resolve(__dirname, '..');
const themeDir = resolve(root, 'templates/mytheme');
const srcDir = `${themeDir}/assets/js/src`;
const distDir = `${themeDir}/assets/js/dist`;

if (!existsSync(distDir)) mkdirSync(distDir, { recursive: true });

const isWatch = process.argv.includes('--watch');
const isDev   = process.env.NODE_ENV === 'development';

const config = {
  entryPoints: existsSync(`${srcDir}/theme.js`)
    ? [`${srcDir}/theme.js`]
    : [],   // empty until you write some JS
  bundle: true,
  outfile: `${distDir}/theme.js`,
  minify: !isDev,
  sourcemap: isDev,
  target: ['es2020'],
  logLevel: 'info',
};

if (config.entryPoints.length === 0) {
  console.log('No JS entry points yet — create templates/mytheme/assets/js/src/theme.js to start.');
  process.exit(0);
}

if (isWatch) {
  const ctx = await context(config);
  await ctx.watch();
  console.log('Watching JS...');
} else {
  await build(config);
  console.log('JS build done.');
}
