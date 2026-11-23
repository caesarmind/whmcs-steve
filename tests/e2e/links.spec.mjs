// Tier 3a (crawl) - follow every link the theme renders and judge each page.
//
// The route table covers the pages we know about; this covers the ones we do
// not - a menu entry added in the admin, a link a template builds by hand.
// It fails on:
//   - a broken link (4xx/5xx) anywhere in the theme's navigation
//   - any oracle finding on a page reached by a link
//   - a link that SIGNS THE CUSTOMER OUT. This is how the crawl found the
//     Close Ticket link (8f7e5f2): a state-changing GET without its CSRF
//     token, which WHMCS answers by destroying the session.
//
// Which links are followed (and which never are) lives in crawl-rules.mjs,
// shared with the coverage runner.

import { test, expect } from '@playwright/test';
import { BASE_URL } from '../lib/env.mjs';
import { session } from './helpers.mjs';
import { inspect } from './oracles.mjs';
import { triage } from './known-issues.mjs';
import { linksOf } from './crawl-rules.mjs';

const MAX_PAGES = Number(process.env.HADRIAN_CRAWL_MAX || 150);

for (const persona of ['guest', 'full']) {
  test(`crawl as ${persona}`, async () => {
    test.setTimeout(10 * 60_000);
    const ctx = await session(persona);
    const expectAuth = persona === 'guest' ? 'out' : 'in';
    const seen = new Set();
    const queue = [['/', '(start)'], ...(persona === 'guest' ? [] : [['/clientarea.php', '(start)']])];
    const findings = [];

    while (queue.length && seen.size < MAX_PAGES) {
      const [url, from] = queue.shift();
      if (seen.has(url)) continue;
      seen.add(url);

      let res;
      try {
        res = await ctx.get(url, { timeout: 45_000 });
      } catch (e) {
        // A redirect loop surfaces here ("Max redirect count exceeded"); in a
        // browser it is the "too many redirects" error page.
        findings.push(`${url}  (linked from ${from}): request failed - ${e.message.split('\n')[0]}`);
        continue;
      }
      const html = await res.text();
      if (res.status() >= 400) { findings.push(`${res.status()}  ${url}  (linked from ${from})`); continue; }

      const { problems, auth } = inspect(html, { expectAuth });
      for (const p of problems) findings.push(`${url}  (linked from ${from}): ${p}`);
      if (auth && auth !== expectAuth) {
        findings.push(`following ${url} (linked from ${from}) signed the ${persona} session OUT`);
        break; // everything after this would be judged as the wrong persona
      }

      for (const next of linksOf(html, url, BASE_URL)) if (!seen.has(next)) queue.push([next, url]);
    }
    await ctx.dispose();

    test.info().annotations.push({ type: 'pages crawled', description: String(seen.size) });
    const { fresh } = triage(findings, test.info());
    expect(fresh, `${fresh.length} new finding(s) across ${seen.size} crawled pages`).toEqual([]);
  });
}
