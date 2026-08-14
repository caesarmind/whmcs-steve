// Programmatic responsive audit for Tier A pages.
// For each (page × layout × breakpoint), navigates to the live preview and
// detects:
//   - horizontal overflow (documentElement.scrollWidth > clientWidth)
//   - elements whose right edge exceeds the viewport (the actual offenders)
//   - off-screen fixed/absolute elements
// Outputs:
//   screenshots/_audit/overflow.json     (raw findings, every combination)
//   screenshots/_audit/overflow.md       (ranked human summary)

const { chromium } = require('playwright');
const fs = require('fs');
const path = require('path');

const BASE = 'http://localhost:3002';
const OUT_DIR = path.join(__dirname, '..', 'screenshots', '_audit');
fs.mkdirSync(OUT_DIR, { recursive: true });

const PAGES = [
  'clientareahome', 'clientareaproducts', 'clientareadomains',
  'clientareainvoices', 'clientareaquotes', 'supportticketslist',
  'viewticket', 'clientareadetails', 'clientareasecurity',
  'clientareaproductdetails', 'viewinvoice', 'viewquote',
];
const LAYOUTS = ['top', 'side', 'rail'];
const BREAKPOINTS = [1440, 1280, 1024, 768, 480, 375];

// Run inside the browser context per page. Returns a finding object.
function probe() {
  const html = document.documentElement;
  const vw = html.clientWidth;
  const docW = html.scrollWidth;
  const overflowPx = Math.max(0, docW - vw);

  // Walk all elements; collect those whose right > vw + 1 (1px tolerance for sub-pixel)
  // Skip nodes that are children of an already-flagged offender to keep the list tight.
  const offenders = [];
  const flagged = new Set();
  const all = document.querySelectorAll('body *');
  for (const el of all) {
    if (el.offsetParent === null) {
      // Hidden or display:none → still might be position:fixed; check explicitly
      const cs = getComputedStyle(el);
      if (cs.display === 'none' || cs.visibility === 'hidden') continue;
      if (cs.position !== 'fixed') continue;
    }
    // Skip if any ancestor is already flagged (we want the outermost overflower)
    let p = el.parentElement, skip = false;
    while (p) { if (flagged.has(p)) { skip = true; break; } p = p.parentElement; }
    if (skip) continue;

    const rect = el.getBoundingClientRect();
    if (rect.width === 0 || rect.height === 0) continue;
    if (rect.right <= vw + 1) continue;
    // Ignore elements that are intentionally off-screen left-aligned (e.g. `left: -9999px`)
    if (rect.left < -1000) continue;

    flagged.add(el);
    const sel = (() => {
      const tag = el.tagName.toLowerCase();
      const id = el.id ? `#${el.id}` : '';
      const cls = (el.className && typeof el.className === 'string')
        ? '.' + el.className.trim().split(/\s+/).slice(0, 3).join('.')
        : '';
      return `${tag}${id}${cls}`;
    })();
    offenders.push({
      sel,
      left: Math.round(rect.left),
      right: Math.round(rect.right),
      width: Math.round(rect.width),
      overBy: Math.round(rect.right - vw),
    });
    if (offenders.length >= 12) break; // cap per page
  }

  return { vw, docW, overflowPx, offenders };
}

(async () => {
  const browser = await chromium.launch();
  const context = await browser.newContext({ deviceScaleFactor: 1 });
  const page = await context.newPage();

  const all = [];
  for (const slug of PAGES) {
    for (const layout of LAYOUTS) {
      for (const width of BREAKPOINTS) {
        await page.setViewportSize({ width, height: 800 });
        const url = `${BASE}/${slug}?layout=${layout}`;
        let navOk = true;
        try {
          await page.goto(url, { waitUntil: 'networkidle', timeout: 30000 });
        } catch (e) {
          // Try again with a more lenient wait condition
          try {
            await page.goto(url, { waitUntil: 'domcontentloaded', timeout: 15000 });
          } catch (e2) {
            navOk = false;
            console.warn(`  ${slug}/${layout} @ ${width}: nav failed, skipping`);
          }
        }
        if (!navOk) {
          all.push({ page: slug, layout, width, vw: width, docW: width, overflowPx: 0, offenders: [], skipped: true });
          continue;
        }
        try {
          await page.evaluate(() => {
            const chip = document.querySelector('.state-chip, [data-state-chip]');
            if (chip) chip.style.display = 'none';
          });
          await page.waitForTimeout(400);
          const finding = await page.evaluate(probe);
          all.push({ page: slug, layout, width, ...finding });
          const tag = finding.overflowPx > 0 ? `OVERFLOW ${finding.overflowPx}px` : 'ok';
          console.log(`  ${slug}/${layout} @ ${width} → ${tag}`);
        } catch (e) {
          console.warn(`  ${slug}/${layout} @ ${width}: probe failed (${e.message.split('\n')[0]})`);
          all.push({ page: slug, layout, width, vw: width, docW: width, overflowPx: 0, offenders: [], probeFailed: true });
        }
      }
    }
  }

  await browser.close();

  // Raw JSON
  fs.writeFileSync(path.join(OUT_DIR, 'overflow.json'), JSON.stringify(all, null, 2));

  // ---- Ranked Markdown summary ----
  const lines = [];
  lines.push('# Tier A overflow audit', '');
  lines.push(`Captured: ${new Date().toISOString()}`, '');

  // 1. Worst combinations (sorted by overflow px)
  const offenders = all.filter(r => r.overflowPx > 0)
    .sort((a, b) => b.overflowPx - a.overflowPx);
  lines.push('## 1. Combinations with horizontal overflow', '');
  if (offenders.length === 0) {
    lines.push('_No horizontal overflow detected._', '');
  } else {
    lines.push('| page | layout | width | overflow | top offending element |');
    lines.push('|------|--------|-------|----------|------------------------|');
    for (const r of offenders) {
      const top = r.offenders[0];
      const topStr = top ? `\`${top.sel}\` (${top.width}w, +${top.overBy}px)` : '';
      lines.push(`| ${r.page} | ${r.layout} | ${r.width} | **${r.overflowPx}px** | ${topStr} |`);
    }
    lines.push('');
  }

  // 2. Worst pages (sum of overflow across all combos)
  const byPage = {};
  for (const r of all) {
    byPage[r.page] = byPage[r.page] || { combos: 0, total: 0, max: 0 };
    if (r.overflowPx > 0) {
      byPage[r.page].combos++;
      byPage[r.page].total += r.overflowPx;
      byPage[r.page].max = Math.max(byPage[r.page].max, r.overflowPx);
    }
  }
  const pageRank = Object.entries(byPage)
    .filter(([, v]) => v.combos > 0)
    .sort((a, b) => b[1].total - a[1].total);
  lines.push('## 2. Worst pages (cumulative overflow across all 18 combos)', '');
  if (pageRank.length === 0) {
    lines.push('_All pages clean._', '');
  } else {
    lines.push('| page | combos w/ overflow | total px | worst combo px |');
    lines.push('|------|--------------------|----------|----------------|');
    for (const [p, v] of pageRank) {
      lines.push(`| ${p} | ${v.combos} / 18 | ${v.total} | ${v.max} |`);
    }
    lines.push('');
  }

  // 3. Most common offending selectors (across all combos)
  const selCount = {};
  for (const r of all) {
    for (const o of r.offenders) {
      selCount[o.sel] = (selCount[o.sel] || 0) + 1;
    }
  }
  const selRank = Object.entries(selCount).sort((a, b) => b[1] - a[1]).slice(0, 20);
  lines.push('## 3. Most common offending selectors (top 20)', '');
  if (selRank.length === 0) {
    lines.push('_No offenders flagged._', '');
  } else {
    lines.push('| count | selector |');
    lines.push('|-------|----------|');
    for (const [s, c] of selRank) lines.push(`| ${c} | \`${s}\` |`);
    lines.push('');
  }

  // 4. Per-breakpoint summary
  const byBp = {};
  for (const r of all) {
    byBp[r.width] = byBp[r.width] || { total: 0, count: 0 };
    if (r.overflowPx > 0) {
      byBp[r.width].count++;
      byBp[r.width].total += r.overflowPx;
    }
  }
  lines.push('## 4. Severity by breakpoint', '');
  lines.push('| width | combos w/ overflow | total px |');
  lines.push('|-------|--------------------|----------|');
  for (const w of BREAKPOINTS) {
    const v = byBp[w] || { total: 0, count: 0 };
    lines.push(`| ${w} | ${v.count} / 36 | ${v.total} |`);
  }
  lines.push('');

  fs.writeFileSync(path.join(OUT_DIR, 'overflow.md'), lines.join('\n'));
  console.log('\nWrote: screenshots/_audit/overflow.json + overflow.md');
})();
