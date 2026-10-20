// Tier 4 (ADVISORY) - visual regression.
//
// Screenshots key pages in light and dark and compares them against approved
// baselines. A difference is a question for a human ("did I mean to change
// this?"), never a failure of the run: run.mjs reports it and moves on.
//
//   first run          baselines are written (tests/.local/visual, gitignored -
//                      they are specific to this machine's fonts and GPU)
//   later runs         differences are reported with a side-by-side diff
//   run.mjs --approve  accepts the current look as the new baseline
//
// Dates and amounts move between runs, so the page's data regions are masked
// and a small per-pixel tolerance absorbs anti-aliasing (150 pixels total).

import { test, expect } from '@playwright/test';
import { fx, loginClient } from './helpers.mjs';

const id = fx.ids;
const SHOTS = [
  ['guest', 'home', '/'],
  ['guest', 'store', `/index.php?rp=/store/${id.productGroupSlug}`],
  ['guest', 'login', '/login'],
  ['guest', 'register', '/register.php'],
  ['full', 'dashboard', '/clientarea.php'],
  ['full', 'services', '/clientarea.php?action=services'],
  ['full', 'service-details', `/clientarea.php?action=productdetails&id=${id.serviceId}`],
  ['full', 'invoices', '/clientarea.php?action=invoices'],
  ['full', 'invoice', `/viewinvoice.php?id=${id.invoiceId}`],
  ['full', 'ticket', `/viewticket.php?tid=${id.ticketTid}&c=${id.ticketC}`],
  ['full', 'security', '/index.php?rp=/user/security'],
  ['empty', 'dashboard-empty', '/clientarea.php'],
];

// Anything whose content legitimately changes between runs.
// The captcha image is random on every load (home and register).
const MASK = '.mt-captcha-img, [class*="captcha"] img, time, [datetime], .date, [class*="-date"], [class*="date-"], [class*="due"], [class*="amount"], [class*="price"], .status-pill, .notification-count, .tk-time';

for (const theme of ['light', 'dark']) {
  for (const [persona, name, url] of SHOTS) {
    test(`${name} (${theme})`, async ({ page, context, baseURL }) => {
      await loginClient(context.request, persona);
      await context.addCookies([{ name: 'mt_theme', value: theme, url: baseURL }]);
      await page.goto(url, { waitUntil: 'load' });
      await page.evaluate(() => document.fonts?.ready);
      await expect(page).toHaveScreenshot(`${persona}-${name}-${theme}.png`, {
        fullPage: true,
        animations: 'disabled',
        caret: 'hide',
        mask: [page.locator(MASK)],
        // An absolute budget, not a ratio: 1% of a full-page shot is ~25,000
        // pixels - more than a recoloured heading occupies, so a ratio let a
        // real visual change through. threshold 0.2 absorbs anti-aliasing.
        maxDiffPixels: 150,
        threshold: 0.2,
      });
    });
  }
}
