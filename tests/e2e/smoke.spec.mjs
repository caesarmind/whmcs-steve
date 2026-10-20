// Tier 3a - every route x persona over HTTP, judged by the oracles.
// No browser: this is the fast tier the pre-push gate leans on.

import { test, expect } from '@playwright/test';
import { ROUTES } from './routes.mjs';
import { session } from './helpers.mjs';
import { inspect } from './oracles.mjs';

const byPersona = {};
for (const r of ROUTES) for (const p of r.personas) (byPersona[p] ||= []).push(r);

for (const [persona, routes] of Object.entries(byPersona)) {
  test.describe(`${persona}`, () => {
    let ctx;
    test.beforeAll(async () => { ctx = await session(persona); });
    test.afterAll(async () => { await ctx?.dispose(); });

    for (const r of routes) {
      test(`${r.name || r.tpl}  ${r.url}`, async () => {
        const res = await ctx.get(r.url, { timeout: 45_000 });
        const html = await res.text();
        const got = inspect(html, { expectAuth: persona === 'guest' ? 'out' : 'in' });
        const want = [].concat(r.tpl);

        expect.soft(res.status(), `HTTP status for ${r.url}`).toBe(200);
        expect.soft(want, `rendered template (data-tpl) - a mismatch means a redirect or the wrong page`).toContain(got.tpl);
        expect.soft(got.problems, `oracle findings on ${r.url}`).toEqual([]);
      });
    }
  });
}
