// Tier 3b (sweep) - every smoke route in a real browser, at three widths.
//
// browser.spec.mjs measures 26 key pages in every layout x theme. This covers
// the other side: EVERY page the smoke tier knows (routes.mjs), in the
// production layout, at desktop (1280), tablet (768) and phone (375) widths -
// JS errors, failed assets, horizontal overflow, unreadable text, and at
// desktop width the accessibility basics (unnamed buttons/links, unlabelled
// fields, images without alt).
//
// One browser context per persona: the login cost is paid once per persona.

import { test, expect } from '@playwright/test';
import { ROUTES } from './routes.mjs';
import { loginClient } from './helpers.mjs';
import { watch, judge } from './page-checks.mjs';

const WIDTHS = [1280, 768, 375];
const byPersona = {};
for (const r of ROUTES) {
  if (r.tpl === null) continue;                 // standalone popups / fragments: no page chrome to measure
  for (const p of r.personas) (byPersona[p] ||= []).push(r);
}

for (const [persona, routes] of Object.entries(byPersona)) {
  test.describe(`sweep as ${persona}`, () => {
    for (const r of routes) {
      test(`${r.name || r.tpl}  ${r.url}`, async ({ page, context }) => {
        test.setTimeout(2 * 60_000);
        await loginClient(context.request, persona);
        const w = watch(page);
        const problems = [];
        for (const width of WIDTHS) {
          await page.setViewportSize({ width, height: width < 768 ? 760 : 900 });
          w.label(`[${width}px]`);
          const res = await judge(page, r.url, { where: `[${width}px]`, expectAuth: persona === 'guest' ? 'out' : 'in', a11y: width === 1280 });
          problems.push(...res.problems);
        }
        expect([...new Set([...problems, ...w.problems])]).toEqual([]);
      });
    }
  });
}
