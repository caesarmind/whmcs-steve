/* build-landing.mjs — turn the landing into a folder you can upload
   ---------------------------------------------------------------------------
   The site runs on Babel-in-the-browser during development, which costs a
   visitor 4.2 MB of JavaScript (React dev 107 KB + ReactDOM dev 1,055 KB +
   Babel 3,064 KB) and a compile of 131 KB of JSX on every single view, before
   anything paints. That is a prototyping setup, not a shipping one.

   This compiles the JSX once, self-hosts React's production builds, and lays
   the three folders out as one document root:

       dist/
         index.html              the landing
         about.html
         assets/                 css, the compiled app, vendor React, images
         apple-client-area/      the hero embeds this
         hadrian-admin-panel/    the Menu spotlight embeds this

   Upload the CONTENTS of dist/ to your public_html. Nothing here needs Node or
   PHP on the server -- it is all static files.

   Run: node scripts/build-landing.mjs
*/
import { execFileSync } from 'node:child_process';
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

// HERE landed in Node 20; this has to run on 18 too
const HERE = path.dirname(fileURLToPath(import.meta.url));

const ROOT = path.resolve(HERE, '..');
const SRC = path.join(ROOT, 'hadrianthegreat-landind');
const OUT = path.join(ROOT, 'dist');
const say = (...a) => console.log(' ', ...a);

/* The landing sits at the document root once deployed, so its siblings move
   underneath it. Everything else about the source is unchanged. */
const PATHS = { clientArea: 'apple-client-area/', admin: 'hadrian-admin-panel/' };
/* Old file name -> new. The About page links to the landing nine times. */
const RENAME = {
  'Hadrian Landing Imperial.html': 'index.html',
  'Hadrian About.html': 'about.html',
};
/* Asset renames are kept apart from RENAME because the page list is derived
   from RENAME's keys -- a screens/*.png entry in there would be treated as a
   page to build. Both maps are applied wherever text is rewritten. */
const ASSET_RENAME = {};

/* ── what a crawler and a link preview see ────────────────────────────────
   SET THIS BEFORE LAUNCH. The canonical and og:url have to be absolute, so
   they cannot be derived from a relative build. */
const SITE = 'https://caesarthemes.com/hadrian/';   // <-- your URL, with the trailing slash
const META = {
  'index.html': {
    description: 'Hadrian is a WHMCS client area theme: three navigation layouts, six styles, four dashboard designs, a homepage composer, a menu manager and per-page SEO — every one an admin setting, not a template fork.',
    ogImage: 'assets/og.png',
  },
  'about.html': {
    description: 'Caesarthemes builds WHMCS themes that are configured, not forked. Hadrian is the first: a client area rebuilt around an admin panel rather than a set of files to edit.',
    ogImage: 'assets/og.png',
  },
};

/* The hero copy lives in a script tag in the page, and the static block below
   has to say the same thing, so it is read from there rather than restated
   here. Evaluating our own file, not anyone else's input. */
function heroCopy(html) {
  const m = html.match(/window\.HERO_COPY\s*=\s*(\{[\s\S]*?\});/);
  if (!m) return null;
  try { return new Function(`return ${m[1]}`)(); } catch (e) { return null; }
}

/* A crawler that does not run JavaScript, and every visitor for the few hundred
   milliseconds before React mounts, currently gets an empty <div id="root">.
   This puts the hero in it as real markup, using the same classes the JSX uses,
   so it renders identically and createRoot() simply replaces it on mount. Not a
   full prerender -- that would want a headless browser in the build -- but it is
   the part of the page worth indexing. */
function staticHero(copy) {
  if (!copy) return '';
  const esc = (t) => String(t).replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
  const stack = (copy.stack || []).map((t) => `<div>${esc(t)}</div>`).join('');
  return `<header class="hp-silicon-hero${copy.cls ? ' ' + copy.cls : ''}">
<div class="hp-wrap" style="text-align:center">
<div class="chip">${esc(copy.chip)}</div>
<h1 class="rom">${esc(copy.line1)}<br><span class="rom-2">${esc(copy.line2)}</span></h1>
${stack ? `<div class="rom-stack">${stack}</div>` : ''}
<p class="copy">${esc(copy.copy)}</p>
</div>
</header>`;
}

function seoTags(out, html, copy) {
  const m = META[out];
  if (!m) return '';
  const title = (html.match(/<title>([^<]*)<\/title>/) || [, ''])[1];
  const url = SITE + (out === 'index.html' ? '' : out);
  const img = SITE + m.ogImage;
  const t = (name, content, prop) => `<meta ${prop ? 'property' : 'name'}="${name}" content="${content.replace(/"/g, '&quot;')}">`;
  return [
    `<link rel="canonical" href="${url}">`,
    t('description', m.description),
    t('theme-color', '#0071e3'),
    t('og:type', 'website', true),
    t('og:site_name', 'Caesarthemes', true),
    t('og:title', title, true),
    t('og:description', m.description, true),
    t('og:url', url, true),
    t('og:image', img, true),
    t('og:image:width', '1200', true),
    t('og:image:height', '630', true),
    t('twitter:card', 'summary_large_image'),
    t('twitter:title', title),
    t('twitter:description', m.description),
    t('twitter:image', img),
    `<link rel="icon" href="assets/favicon.png" sizes="any">`,
    `<link rel="apple-touch-icon" href="assets/apple-touch-icon.png">`,
  ].join('\n');
}

const REACT = [
  ['react.production.min.js', 'https://unpkg.com/react@18.3.1/umd/react.production.min.js'],
  ['react-dom.production.min.js', 'https://unpkg.com/react-dom@18.3.1/umd/react-dom.production.min.js'],
];

// maxRetries: on Windows a server still serving dist/ holds handles open, and
// the first rmdir loses to it
/* The tag shapes the build rewrites, in one place: the two pages and the admin
   panel all strip the same CDN and text/babel tags. */
const RE_CDN = /<script src="https:\/\/unpkg\.com[\s\S]*?<\/script>\s*/g;
const RE_BABEL = /<script type="text\/babel"[\s\S]*?<\/script>\s*/g;
const RE_BABEL_SRC = /<script type="text\/babel" src="([^"]+)"/g;


/* Windows keeps a handle on every file a running server has served, so the
   first rmdir loses to it. Retry for a few seconds, then say plainly what is
   holding the folder rather than dumping an ENOTEMPTY stack. */
const rm = (p) => {
  try {
    fs.rmSync(p, { recursive: true, force: true, maxRetries: 40, retryDelay: 150 });
  } catch (e) {
    console.error(`\n  Could not clear ${path.relative(ROOT, p)} — something is holding it open.`);
    console.error('  Stop anything serving dist/ (a preview, a terminal, an open Explorer window) and run again.\n');
    process.exit(1);
  }
};
const mk = (p) => fs.mkdirSync(p, { recursive: true });
const copy = (from, to) => { mk(path.dirname(to)); fs.cpSync(from, to, { recursive: true }); };
const kb = (n) => `${(n / 1024).toFixed(0)} KB`;
const sizeOf = (p) => fs.statSync(p).size;

/* ── 1. the compiled app ──────────────────────────────────────────────────
   The five JSX files are classic scripts sharing one global scope, not
   modules, so concatenating them in the order the HTML lists them is exactly
   equivalent -- and safer than bundling, which would give each its own scope
   and break every cross-file reference. Only the JSX is transformed; the
   syntax the files use beyond that is native in every browser React 18
   supports, so there is nothing to down-level. */
function compile(files, dir = SRC) {
  const parts = files.map((f) => {
    // Through stdin, not as a path argument: this repo lives under a directory
    // with a space in it, and a shelled-out command splits that into two
    // filenames. No --bundle and no --format either -- a bare transform, so each
    // file keeps the top-level scope a classic script tag gave it.
    const source = fs.readFileSync(path.join(dir, f), 'utf8');
    const js = execFileSync('npx', ['--yes', 'esbuild', '--loader=jsx', '--jsx=transform'],
      { input: source, encoding: 'utf8', shell: true, maxBuffer: 32 * 1024 * 1024 });
    return `/* ${f} */
${js}`;
  });
  return parts.join('\n');
}

/* ── 2. the HTML ──────────────────────────────────────────────────────────
   Swap the three CDN script tags and the text/babel tags for one compiled
   file and self-hosted React, point the assets at assets/, tell the app where
   its siblings went, and rewrite the links the renames broke. */
/* Renames apply to markup and to compiled code alike -- the About page holds
   nine links to the landing inside its JSX, which no amount of HTML rewriting
   would have reached. */
function applyRenames(text) {
  for (const [from, to] of Object.entries({ ...RENAME, ...ASSET_RENAME })) {
    text = text.split(from).join(to).split(encodeURI(from)).join(to);
  }
  return text;
}
function rewriteHtml(html, jsName, outName) {
  const scripts = REACT.map(([f]) => `<script src="assets/${f}"></script>`).join('\n');
  html = html
    .replace(RE_CDN, '')
    .replace(RE_BABEL, '')
    .replace(/<link rel="stylesheet" href="([^"]+)">/g, '<link rel="stylesheet" href="assets/$1">')
    .replace('</head>', `${seoTags(outName, html, heroCopy(html))}
<script>window.HADRIAN_PATHS = ${JSON.stringify(PATHS)};</script>
</head>`)
    .replace('<div id="root"></div>', `<div id="root">${staticHero(heroCopy(html))}</div>`)
    .replace('</body>', `${scripts}\n<script src="assets/${jsName}"></script>\n</body>`);
  return applyRenames(html);
}

/* ── run ──────────────────────────────────────────────────────────────── */
console.log('\nBuilding the landing page for upload\n');
rm(OUT); mk(path.join(OUT, 'assets'));

// the two pages, and the scripts each one loads, in their own order
const pages = Object.keys(RENAME).map((file) => {
  const html = fs.readFileSync(path.join(SRC, file), 'utf8');
  const jsx = [...html.matchAll(RE_BABEL_SRC)].map((m) => m[1]);
  return { file, out: RENAME[file], html, jsx };
});

/* screens/ stays at the root, NOT under assets/: the JSX asks for
   "screens/sidebar-dashboard.png" relative to the page, and the page is the
   document root here. The images the CSS asks for do live in assets/, because
   they resolve relative to the stylesheet. Two different bases, both correct.

   The captures are 2880px wide and shown at about 890 -- and since the hero went
   live they are only the poster and the file:// fallback. Re-encoded to WebP at
   1600px they drop from 2.9 MB to about 340 KB with nothing visible lost. The
   rename is added to RENAME so the compiled JS follows, exactly as the page
   renames do. If the encoder cannot be reached the PNGs are copied as they are,
   because a heavy page beats a broken one. */
{
  const from = path.join(SRC, 'screens');
  const to = path.join(OUT, 'screens');
  mk(to);
  let before = 0, after = 0, encoded = 0;
  for (const f of fs.readdirSync(from).filter((n) => /\.png$/i.test(n))) {
    const src = path.join(from, f);
    const webp = f.replace(/\.png$/i, '.webp');
    before += sizeOf(src);
    try {
      // paths quoted by hand: shell:true does not quote for us, and this repo
      // sits under a directory with a space in it
      execFileSync('npx', ['--yes', 'sharp-cli', '-i', `"${src}"`, '-o', `"${path.join(to, webp)}"`,
        '-f', 'webp', '-q', '78', 'resize', '1600'],
        { stdio: 'ignore', shell: true, timeout: 180000 });
      if (!fs.existsSync(path.join(to, webp))) throw new Error('no output');
      ASSET_RENAME[`screens/${f}`] = `screens/${webp}`;
      after += sizeOf(path.join(to, webp));
      encoded++;
    } catch (e) {
      copy(src, path.join(to, f));
      after += sizeOf(path.join(to, f));
    }
  }
  say(encoded
    ? `screens/     ${encoded} re-encoded to webp — ${kb(before)} down to ${kb(after)}`
    : `screens/     copied as png (encoder unavailable) — ${kb(after)}`);
}

for (const p of pages) {
  const jsName = p.out.replace(/\.html$/, '.js');
  fs.writeFileSync(path.join(OUT, 'assets', jsName), applyRenames(compile(p.jsx)));
  fs.writeFileSync(path.join(OUT, p.out), rewriteHtml(p.html, jsName, p.out));
  say(`${p.out.padEnd(12)} ${p.jsx.length} jsx -> assets/${jsName}  ${kb(sizeOf(path.join(OUT, 'assets', jsName)))}`);
}

// css and images travel as they are
for (const f of fs.readdirSync(SRC)) {
  if (/\.(css|png|jpe?g|svg|webp|ico)$/i.test(f)) copy(path.join(SRC, f), path.join(OUT, 'assets', f));
}


/* ── the share image and the icons ────────────────────────────────────────
   og:image wants 1200x630; the captures are tall, so this takes the top of
   the sidebar dashboard, which is the part with the greeting and the figures.
   The icons come from the brand mark. All three go through the encoder that
   is already here, and are skipped with a note if it cannot be reached. */
{
  const shot = path.join(SRC, 'screens', 'sidebar-dashboard.png');
  const mark = path.join(SRC, 'caesar-silhouette.png');
  const jobs = [
    ['og.png', shot, ['resize', '1200', '630', '--position', 'top', '--fit', 'cover']],
    ['favicon.png', mark, ['resize', '64', '64', '--fit', 'contain', '--background', '#ffffff']],
    ['apple-touch-icon.png', mark, ['resize', '180', '180', '--fit', 'contain', '--background', '#ffffff']],
  ];
  const made = [];
  for (const [name, src, args] of jobs) {
    const dest = path.join(OUT, 'assets', name);
    try {
      execFileSync('npx', ['--yes', 'sharp-cli', '-i', `"${src}"`, '-o', `"${dest}"`, '-f', 'png', ...args],
        { stdio: 'ignore', shell: true, timeout: 180000 });
      if (fs.existsSync(dest)) made.push(`${name} ${kb(sizeOf(dest))}`);
    } catch (e) { /* noted below */ }
  }
  say(made.length ? `assets/      ${made.join(' · ')}` : 'assets/      og image and icons SKIPPED (encoder unavailable)');
}

// React, fetched once and served from your own domain
for (const [file, url] of REACT) {
  const dest = path.join(OUT, 'assets', file);
  const cache = path.join(ROOT, 'build', 'vendor', file);   // gitignored
  if (fs.existsSync(cache)) { copy(cache, dest); }
  else {
    const res = await fetch(url);
    if (!res.ok) throw new Error(`could not fetch ${url}: ${res.status}`);
    const buf = Buffer.from(await res.arrayBuffer());
    mk(path.dirname(cache)); fs.writeFileSync(cache, buf); fs.writeFileSync(dest, buf);
  }
  say(`assets/${file.padEnd(30)} ${kb(sizeOf(dest))}`);
}

// the two folders the page embeds, side by side beneath it
copy(path.join(ROOT, 'apple-client-area'), path.join(OUT, 'apple-client-area'));
copy(path.join(ROOT, 'Hadrian by Caesarthemes', 'hadrian-admin-panel'), path.join(OUT, 'hadrian-admin-panel'));
say('apple-client-area/ and hadrian-admin-panel/ copied');

/* The admin panel gets the same treatment. It is only ever loaded inside the
   Menu spotlight, but left as a Babel page it would pull 3 MB from unpkg the
   moment a visitor scrolled to that block -- on a live site, for one card. */
{
  const dir = path.join(OUT, 'hadrian-admin-panel');
  const html = fs.readFileSync(path.join(dir, 'index.html'), 'utf8');
  const jsx = [...html.matchAll(RE_BABEL_SRC)].map((m) => m[1]);
  fs.writeFileSync(path.join(dir, 'apple-admin.js'), compile(jsx, dir));
  for (const f of jsx) fs.rmSync(path.join(dir, f), { force: true });
  const scripts = REACT.map(([f]) => `<script src="../assets/${f}"></script>`).join('\n');
  fs.writeFileSync(path.join(dir, 'index.html'), html
    .replace(RE_CDN, '')
    .replace(RE_BABEL, '')
    .replace('</body>', `${scripts}\n<script src="apple-admin.js"></script>\n</body>`));
  say('hadrian-admin-panel/apple-admin.js'.padEnd(38) + kb(sizeOf(path.join(dir, 'apple-admin.js'))));
}

/* Walked in Node rather than shelled out to du, for the same reason the
   compile reads stdin: a path with a space in it does not survive a shell. */

/* The canonical and og:url are absolute and cannot be derived, so they are a
   constant at the top of this file -- which means they are also the easiest
   thing to ship wrong. Say so on every build until it is changed. */
if (SITE === 'https://caesarthemes.com/hadrian/') {
  console.log('  NOTE  SITE is still the placeholder URL. canonical, og:url and og:image');
  console.log('        point at https://caesarthemes.com/hadrian/ — set SITE at the top of');
  console.log('        this script to wherever this is actually going, then rebuild.');
}

const weigh = (dir) => fs.readdirSync(dir, { withFileTypes: true })
  .reduce((n, e) => n + (e.isDirectory() ? weigh(path.join(dir, e.name)) : sizeOf(path.join(dir, e.name))), 0);
console.log(`
  dist/ is ${(weigh(OUT) / 1024 / 1024).toFixed(1)} MB — upload its CONTENTS to public_html
`);
