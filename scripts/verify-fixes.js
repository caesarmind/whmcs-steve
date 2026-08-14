// Re-audit and re-capture the specific (page, layout, width) combos that were
// flagged before to confirm the fixes landed.

const { chromium } = require('playwright');
const fs = require('fs');
const path = require('path');

const BASE = 'http://localhost:3002';
const OUT_ROOT = path.join(__dirname, '..', 'screenshots');

// (page, layout, width) combos to verify.
const TARGETS = [
  // 1024 right-rail squeeze (fix #3)
  ['clientareaproducts', 'side', 1024],
  ['clientareadomains', 'side', 1024],
  ['clientareainvoices', 'side', 1024],
  ['supportticketslist', 'side', 1024],
  ['clientareaquotes', 'side', 1024],
  // mobile card-stack for quotes (fix #1) — verify across all 3 layouts at 375 + 480
  ['clientareaquotes', 'top', 480],
  ['clientareaquotes', 'top', 375],
  ['clientareaquotes', 'side', 480],
  ['clientareaquotes', 'side', 375],
  ['clientareaquotes', 'rail', 480],
  ['clientareaquotes', 'rail', 375],
  // Mobile nav fallback (fix #4) — at <=900 with side/rail, the topbar nav
  // should now appear. Spot check at 375 across a couple of pages.
  ['clientareahome', 'side', 375],
  ['clientareahome', 'rail', 375],
  ['clientareadomains', 'side', 375],
];

function probe() {
  const html = document.documentElement;
  const vw = html.clientWidth;
  const docW = html.scrollWidth;
  return { vw, docW, overflowPx: Math.max(0, docW - vw) };
}

(async () => {
  const browser = await chromium.launch();
  const context = await browser.newContext({ deviceScaleFactor: 1 });
  const page = await context.newPage();

  const findings = [];
  for (const [slug, layout, width] of TARGETS) {
    await page.setViewportSize({ width, height: 800 });
    const url = `${BASE}/${slug}?layout=${layout}`;
    try {
      await page.goto(url, { waitUntil: 'networkidle', timeout: 15000 });
    } catch (e) {
      console.warn(`  ${slug}/${layout} @ ${width}: nav timeout`);
    }
    await page.evaluate(() => {
      const chip = document.querySelector('.state-chip, [data-state-chip]');
      if (chip) chip.style.display = 'none';
    });
    await page.waitForTimeout(500);
    const { overflowPx } = await page.evaluate(probe);
    const dir = path.join(OUT_ROOT, slug, layout);
    fs.mkdirSync(dir, { recursive: true });
    const out = path.join(dir, `${width}.png`);
    await page.screenshot({ path: out, fullPage: true });
    findings.push({ slug, layout, width, overflowPx });
    const tag = overflowPx > 0 ? `OVERFLOW ${overflowPx}px` : 'ok';
    console.log(`  ${slug}/${layout} @ ${width} → ${tag}`);
  }

  await browser.close();
  console.log('\n--- summary ---');
  for (const f of findings) {
    console.log(`  ${f.slug}/${f.layout} @ ${f.width} → ${f.overflowPx > 0 ? 'OVERFLOW ' + f.overflowPx + 'px' : 'ok'}`);
  }
})();
