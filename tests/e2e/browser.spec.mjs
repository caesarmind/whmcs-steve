// Tier 3b - real Chromium. What HTTP checks cannot see:
//
//   - JavaScript errors (console errors, uncaught exceptions)
//   - CSS/JS/images/fonts that 404 or fail to load
//   - the layout actually laid out: side (260px sidebar), rail (80px rail),
//     top (neither) - measured, not inferred from a class name
//   - horizontal overflow at desktop and phone widths
//   - text you cannot read: heading/body contrast under 3:1 against its real
//     background (dark-on-dark after a dark-mode token mistake reads as 1.1:1)
//
// Every page runs in all three layouts x light/dark, in one signed-in
// browser context per page so the login cost is paid once.

import { test, expect } from '@playwright/test';
import { BASE_URL } from '../lib/env.mjs';
import { fx, loginClient } from './helpers.mjs';
import { measure } from './page-checks.mjs';

const id = fx.ids;
const PAGES = {
  guest: [
    // Not /cart.php: WHMCS 302s it to the store and drops the query string,
    // so ?layout= never arrives. The store page it lands on is listed instead.
    '/', `/index.php?rp=/store/${id.productGroupSlug}`, `/index.php?rp=/store/${id.productPath}`,
    '/cart.php?a=view', '/login', '/register.php', '/announcements.php', '/index.php?rp=/domain/pricing', '/contact.php',
  ],
  full: [
    '/clientarea.php', '/clientarea.php?action=services', `/clientarea.php?action=productdetails&id=${id.serviceId}`,
    '/clientarea.php?action=invoices', `/viewinvoice.php?id=${id.invoiceId}`, '/supporttickets.php',
    `/viewticket.php?tid=${id.ticketTid}&c=${id.ticketC}`, '/clientarea.php?action=domains',
    `/clientarea.php?action=domaindetails&id=${id.domainId}`, '/index.php?rp=/user/security', '/affiliates.php',
    '/clientarea.php?action=details', '/index.php?rp=/account/paymentmethods',
  ],
  empty: ['/clientarea.php', '/clientarea.php?action=services', '/clientarea.php?action=invoices', '/supporttickets.php'],
};
const LAYOUTS = ['side', 'top', 'rail'];
const THEMES = ['light', 'dark'];

const withParams = (url, params) => url + (url.includes('?') ? '&' : '?') + new URLSearchParams(params);

for (const [persona, pages] of Object.entries(PAGES)) {
  test.describe(persona, () => {
    for (const url of pages) {
      test(url, async ({ page, context }) => {
        test.setTimeout(3 * 60_000);
        await loginClient(context.request, persona);

        const problems = [];
        let where = '';
        page.on('console', m => { if (m.type() === 'error') problems.push(`${where} console error: ${m.text().slice(0, 200)}`); });
        page.on('pageerror', e => problems.push(`${where} uncaught exception: ${e.message.slice(0, 200)}`));
        page.on('response', r => {
          if (r.url().startsWith(BASE_URL) && r.status() >= 400) problems.push(`${where} ${r.status()} ${r.url().replace(BASE_URL, '')}`);
        });
        page.on('requestfailed', r => {
          if (r.url().startsWith(BASE_URL)) problems.push(`${where} request failed: ${r.url().replace(BASE_URL, '')} (${r.failure()?.errorText})`);
        });

        for (const theme of THEMES) {
          await context.addCookies([{ name: 'mt_theme', value: theme, url: BASE_URL }]);
          for (const layout of LAYOUTS) {
            where = `[${layout}/${theme}]`;
            await page.goto(withParams(url, { preview: 1, layout }), { waitUntil: 'load' });
            // WHMCS redirects legacy URLs (announcements.php -> rp=/announcements,
            // cart.php -> the store) and drops the query string on the way, so
            // the override never arrives. Re-apply it where we actually landed.
            if (!page.url().includes(`layout=${layout}`)) {
              await page.goto(withParams(page.url(), { preview: 1, layout }), { waitUntil: 'load' });
            }
            const m = await page.evaluate(measure);
            const vw = page.viewportSize().width;

            if (m.layout !== layout) problems.push(`${where} body[data-layout]="${m.layout}"`);
            if (m.theme !== theme) problems.push(`${where} html[data-theme]="${m.theme}"`);
            if (!m.content) problems.push(`${where} .content-area is not visible`);
            if (layout === 'side' && !(m.sidebar?.width >= 220 && m.sidebar?.width <= 320)) problems.push(`${where} sidebar width ${m.sidebar?.width} (expected ~260)`);
            if (layout === 'side' && m.rail) problems.push(`${where} rail visible in side layout`);
            if (layout === 'rail' && !(m.rail?.width >= 64 && m.rail?.width <= 96)) problems.push(`${where} rail width ${m.rail?.width} (expected ~80)`);
            if (layout === 'rail' && m.sidebar) problems.push(`${where} sidebar visible in rail layout`);
            if (layout === 'top' && (m.sidebar || m.rail)) problems.push(`${where} side navigation visible in top layout`);
            // Content may be narrower than the space it has (it is capped by the
            // container-width token, 1120px by default) - that is design. What
            // must never happen is navigation sitting ON TOP of it.
            const nav = m.sidebar || m.rail;
            if (m.content && nav && m.content.left < nav.right - 1) problems.push(`${where} navigation overlaps content (nav ends at ${nav.right}px, content starts at ${m.content.left}px)`);
            if (m.content && m.content.right > vw + 1) problems.push(`${where} content runs off the right edge (${m.content.right}px > ${vw}px)`);
            if (m.overflowX > 1) problems.push(`${where} horizontal overflow of ${m.overflowX}px`);
            for (const c of m.contrast) if (c.ratio < 3) problems.push(`${where} unreadable text (${c.ratio}:1) in ${c.sel}: "${c.text}"`);
          }
        }

        // One phone-width pass in the admin-default layout.
        where = '[375px]';
        await page.setViewportSize({ width: 375, height: 760 });
        await page.goto(url, { waitUntil: 'load' });
        const phone = await page.evaluate(measure);
        if (phone.overflowX > 1) problems.push(`${where} horizontal overflow of ${phone.overflowX}px at phone width`);

        expect([...new Set(problems)]).toEqual([]);
      });
    }
  });
}
