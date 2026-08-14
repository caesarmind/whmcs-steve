// Responsive screenshot capture for Tier A pages, across the three layout
// variants exposed by the state-chip (top nav / left sidebar / icon rail).
// Runs against the local `apple-client-area` preview server (port 3002).
// Outputs: screenshots/<page>/<layout>/<width>.png (full-page).

const { chromium } = require('playwright');
const fs = require('fs');
const path = require('path');

const BASE = 'http://localhost:3002';
const OUT_ROOT = path.join(__dirname, '..', 'screenshots');

const PAGES = [
  'clientareahome',
  'clientareaproducts',
  'clientareadomains',
  'clientareainvoices',
  'clientareaquotes',
  'supportticketslist',
  'viewticket',
  'clientareadetails',
  'clientareasecurity',
  'clientareaproductdetails',
  'viewinvoice',
  'viewquote',
];

// Layout values match what apple-layout.js applies via `?layout=` query param
// (and stores in localStorage). See apple-layout.js: applyLayout('top'|'side'|'rail').
const LAYOUTS = ['top', 'side', 'rail'];

const BREAKPOINTS = [
  { width: 1440, height: 900 },
  { width: 1280, height: 800 },
  { width: 1024, height: 768 },
  { width: 768,  height: 1024 },
  { width: 480,  height: 800 },
  { width: 375,  height: 812 },
];

(async () => {
  const browser = await chromium.launch();
  const context = await browser.newContext({ deviceScaleFactor: 1 });
  const page = await context.newPage();

  for (const slug of PAGES) {
    for (const layout of LAYOUTS) {
      const dir = path.join(OUT_ROOT, slug, layout);
      fs.mkdirSync(dir, { recursive: true });

      for (const bp of BREAKPOINTS) {
        await page.setViewportSize({ width: bp.width, height: bp.height });
        const url = `${BASE}/${slug}?layout=${layout}`;
        try {
          await page.goto(url, { waitUntil: 'networkidle', timeout: 15000 });
        } catch (e) {
          console.warn(`  ${slug}/${layout} @ ${bp.width}: nav timeout, continuing`);
        }
        // Hide the floating state-chip so it doesn't cover content in full-page shots
        await page.evaluate(() => {
          const chip = document.querySelector('.state-chip, [data-state-chip]');
          if (chip) chip.style.display = 'none';
        });
        // Settle: partials are injected client-side via data-include; give them a beat
        await page.waitForTimeout(500);
        const out = path.join(dir, `${bp.width}.png`);
        await page.screenshot({ path: out, fullPage: true });
        console.log(`  ${slug}/${layout} @ ${bp.width} -> ${path.relative(process.cwd(), out)}`);
      }
    }
  }

  await browser.close();
  console.log('Done.');
})();
