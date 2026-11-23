// Which links a crawl may follow. Shared by links.spec.mjs and the coverage
// runner (tests/coverage/run.mjs), so both walk the same pages.
//
// Links that change state on purpose are never followed. Anything carrying a
// token= is skipped too: a CSRF token in a link means "this does something",
// and a crawl must never do things to the fixtures.

export const SKIP = [
  /logout|dologout/i,            // ends the session by design
  /[?&]token=/i,                  // carries a CSRF token => mutates something
  /closeticket|markasread|dismiss|regenerate/i,
  /[?&]a=(add|remove|empty|update|checkout)/i, /sub=(delete|remove|save)/i,
  /[?&](language|currency)=/i,   // flips session settings for later pages
  /switchaccount|\/user\/accounts\/\d/i,
  /dl\.php|\.pdf$|dosinglesignon|\/sso|aff\.php|link\.php|\/admin/i,
  /action=cancel|paynow|masspay|[?&]download/i,
];
export const ASSET = /\.(css|js|png|jpe?g|gif|svg|ico|webp|woff2?|ttf|xml|txt|zip)$/i;

/** Same-origin, followable links of a page, resolved the way a browser does. */
export function linksOf(html, url, baseUrl) {
  // Resolve against <base href> when the page has one (header.tpl always
  // emits it), not against the page's own URL. Ignoring it turns every
  // relative link on a path-style route such as /index.php/user/security
  // into a phantom 404.
  const baseHref = (html.match(/<base\s+href="([^"]+)"/i) || [])[1];
  const resolveFrom = baseHref ? new URL(baseHref.replace(/&amp;/g, '&'), baseUrl + url).href : baseUrl + url;
  const out = [];
  for (const m of html.matchAll(/<a\b[^>]*\bhref="([^"#][^"]*)"/g)) {
    const raw = m[1].replace(/&amp;/g, '&');
    if (/^(mailto|tel|javascript|data):/i.test(raw)) continue;
    let u;
    try { u = new URL(raw, resolveFrom); } catch { continue; }
    if (u.origin !== baseUrl || ASSET.test(u.pathname)) continue;
    const next = u.pathname + u.search;
    if (!SKIP.some(re => re.test(next))) out.push(next);
  }
  return out;
}
