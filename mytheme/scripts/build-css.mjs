#!/usr/bin/env node
// scripts/build-css.mjs — compile SCSS sources to minified CSS.
//
// Run: npm run build:css
//      npm run build:css -- --watch

import { compile } from 'sass';
import postcss from 'postcss';
import autoprefixer from 'autoprefixer';
import cssnano from 'cssnano';
import { readFileSync, writeFileSync, watch } from 'node:fs';
import { resolve, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';

const __dirname = dirname(fileURLToPath(import.meta.url));
const root = resolve(__dirname, '..');
const themeDir = resolve(root, 'templates/mytheme');

const ENTRIES = [
  { src: `${themeDir}/assets/scss/theme.scss`,     out: `${themeDir}/assets/css/theme.css` },
  { src: `${themeDir}/assets/scss/site.scss`,      out: `${themeDir}/assets/css/site.css` },
  // Add theme-rtl.scss / site-rtl.scss when you author them
];

const isWatch = process.argv.includes('--watch');
const isDev   = process.env.NODE_ENV === 'development';

const post = postcss([
  autoprefixer(),
  ...(isDev ? [] : [cssnano({ preset: 'default' })]),
]);

async function buildOne({ src, out }) {
  try {
    const result = compile(src, {
      style: isDev ? 'expanded' : 'compressed',
      sourceMap: isDev,
    });
    const processed = await post.process(result.css, {
      from: src,
      to: out,
      map: isDev ? { inline: false } : false,
    });
    writeFileSync(out, processed.css);
    if (processed.map) {
      writeFileSync(out + '.map', processed.map.toString());
    }
    console.log(`  ✓ ${src.replace(root + '/', '')} → ${out.replace(root + '/', '')}`);
  } catch (e) {
    console.error(`  ✗ ${src.replace(root + '/', '')}: ${e.message}`);
    if (!isWatch) process.exit(1);
  }
}

async function buildAll() {
  console.log('Building CSS...');
  for (const entry of ENTRIES) {
    await buildOne(entry);
  }
  console.log('Done.');
}

await buildAll();

if (isWatch) {
  console.log('Watching for changes...');
  watch(`${themeDir}/assets/scss`, { recursive: true }, async (event, filename) => {
    if (filename?.endsWith('.scss')) {
      console.log(`\nChanged: ${filename}`);
      await buildAll();
    }
  });
}
