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
// Links that change state on purpose are never followed - see SKIP. Anything
// carrying a token= is skipped too: a CSRF token in a link means "this does
// something", and the crawl must never do things to the fixtures.

import { test, expect } from '@playwright/test';
import { BASE_URL } from '../lib/env.mjs';
import { session } from './helpers.mjs';
import { inspect } from './oracles.mjs';
import { triage } from './known-issues.mjs';

const SKIP = [
  /logout|dologout/i,            // ends the session by design
  /[?&]token=/i,                  // carries a CSRF token => mutates something
  /closeticket|markasread|dismiss|regenerate/i,
  /[?&]a=(add|remove|empty|update|checkout)/i, /sub=(delete|remove|save)/i,
  /[?&](language|currency)=/i,   // flips session settings for later pages
  /switchaccount|\/user\/accounts\/\d/i,
  /dl\.php|\.pdf$|dosinglesignon|\/sso|aff\.php|link\.php|\/admin/i,
  /action=cancel|paynow|masspay|[?&]download/i,
];
const ASSET = /\.(css|js|png|jpe?g|gif|svg|ico|webp|woff2?|ttf|xml|txt|zip)$/i;
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

      // Resolve the way a browser does: against <base href> when the page has
      // one (header.tpl always emits it), not against the page's own URL.
      // Ignoring it turns every relative link on a path-style route such as
      // /index.php/user/security into a phantom 404.
      const baseHref = (html.match(/<base\s+href="([^"]+)"/i) || [])[1];
      const resolveFrom = baseHref ? new URL(baseHref.replace(/&amp;/g, '&'), BASE_URL + url).href : BASE_URL + url;
      for (const m of html.matchAll(/<a\b[^>]*\bhref="([^"#][^"]*)"/g)) {
        const raw = m[1].replace(/&amp;/g, '&');
        if (/^(mailto|tel|javascript|data):/i.test(raw)) continue;
        let u;
        try { u = new URL(raw, resolveFrom); } catch { continue; }
        if (u.origin !== BASE_URL || ASSET.test(u.pathname)) continue;
        const next = u.pathname + u.search;
        if (!seen.has(next) && !SKIP.some(re => re.test(next))) queue.push([next, url]);
      }
    }
    await ctx.dispose();

    test.info().annotations.push({ type: 'pages crawled', description: String(seen.size) });
    const { fresh } = triage(findings, test.info());
    expect(fresh, `${fresh.length} new finding(s) across ${seen.size} crawled pages`).toEqual([]);
  });
}
