// What "broken" means for a rendered page.
//
// Every rule here is a bug that has actually shipped or nearly shipped. A page
// can return HTTP 200 and still be broken in each of these ways, which is why
// a status-code check alone found none of them.

const text = html => html
  .replace(/<script[\s\S]*?<\/script>/gi, ' ')
  .replace(/<style[\s\S]*?<\/style>/gi, ' ')
  .replace(/<[^>]+>/g, ' ')
  .replace(/&nbsp;/g, ' ')
  .replace(/\s+/g, ' ')
  .trim();

/** Inner HTML of the first <div class="content-area"> (balanced), or null. */
export function contentArea(html) {
  const open = html.search(/<div class="content-area[ "]/);
  if (open < 0) return null;
  const startTagEnd = html.indexOf('>', open) + 1;
  const re = /<\/?div\b[^>]*>/g;
  re.lastIndex = open;
  let depth = 0, m;
  while ((m = re.exec(html))) {
    depth += m[0][1] === '/' ? -1 : 1;
    if (depth === 0) return html.slice(startTagEnd, m.index);
  }
  return html.slice(startTagEnd);
}

export const attr = (html, name) => (html.match(new RegExp(`${name}="([^"]*)"`)) || [])[1] ?? null;

/**
 * Pages render BOTH their when-full and when-empty markup and pick one at
 * runtime: an inline script sets body[data-data] and core-layout.css hides
 * the other (`body[data-data="empty"] .when-full { display:none }`). Judge
 * only the variant a visitor actually sees - otherwise an empty-state page is
 * blamed for the blank heading inside its hidden "full" header.
 */
export function visibleVariant(html) {
  const state = (html.match(/setAttribute\(\s*'data-data'\s*,\s*'(full|empty)'\s*\)/) || [])[1];
  if (!state) return html;
  const hide = state === 'empty' ? 'when-full' : 'when-empty';
  let out = html, m;
  const open = new RegExp(`<([a-z][a-z0-9]*)\\b[^>]*\\bclass="[^"]*\\b${hide}\\b[^"]*"[^>]*>`, 'i');
  for (let guard = 0; guard < 50 && (m = out.match(open)); guard++) {
    const tag = m[1].toLowerCase(), start = m.index;
    const re = new RegExp(`<\\/?${tag}\\b[^>]*>`, 'gi');
    re.lastIndex = start;
    let depth = 0, end = out.length, t;
    while ((t = re.exec(out))) { depth += t[0][1] === '/' ? -1 : 1; if (depth === 0) { end = t.index + t[0].length; break; } }
    out = out.slice(0, start) + out.slice(end);
  }
  return out;
}
export const title = html => ((html.match(/<title>([^<]*)<\/title>/) || [])[1] || '').trim();

/**
 * @returns {{problems: string[], tpl: string|null, auth: string|null, title: string}}
 */
export function inspect(html, { expectAuth } = {}) {
  const problems = [];
  const t = title(html);
  const tpl = attr(html, 'data-tpl');
  const auth = attr(html, 'data-auth');

  // 1. WHMCS's own error screens. A template that throws at RUNTIME (the
  //    count('') TypeError in locale-btn.tpl) lands here.
  if (/^(Oops!|Critical Error|Security Warning|WHMCS - Invalid License)/.test(t)) problems.push(`WHMCS error screen: "${t}"`);

  // 2. PHP / Smarty error text leaking into the page.
  const err = html.match(/<b>(Fatal error|Parse error|Warning|Notice|Deprecated)<\/b>:[^<]{0,120}|Uncaught (?:Error|TypeError|Exception)[^<]{0,120}|Stack trace:|Syntax error in template[^<"]{0,120}/);
  if (err) problems.push(`PHP/Smarty error in output: ${err[0].slice(0, 160)}`);

  // 3. Blank content area: the template failed to COMPILE and WHMCS swallowed
  //    it - full header and footer, HTTP 200, nothing in between. This is how
  //    Security Settings and Affiliates were broken for months (e6547a5).
  const ca = contentArea(html);
  if (ca !== null) {
    const words = text(ca);
    const controls = /<(input|select|textarea|button|form|table|iframe|img|svg)\b/i.test(ca);
    if (words.length < 15 && !controls) problems.push(`blank content area (${ca.length} bytes, ${words.length} chars of text)`);
  }

  // 4. Smarty source leaking through as text.
  const visible = text(html);
  const leak = visible.match(/\{\$[a-zA-Z_][^}]{0,40}\}|\{\/?(if|foreach|literal)\b[^}]{0,30}\}/);
  if (leak) problems.push(`unrendered Smarty in page text: ${leak[0]}`);

  // 5. Theme strings missing: when the addon's hooks do not load,
  //    $hadrianLang is empty and these render as nothing at all.
  if (/<h1[^>]*>\s*<\/h1>/.test(visibleVariant(html))) problems.push('empty <h1> (theme language strings not loaded?)');
  if (/data-locale-open/.test(html) && /aria-label=""[^>]*data-locale-open|data-locale-open[^>]*aria-label=""/.test(html)) {
    problems.push('locale button has an empty aria-label (theme language strings not loaded?)');
  }

  // 6. Sidebar items with no icon draw a placeholder dot (783646a, 279787b).
  const dots = [...html.matchAll(/class="sidebar-item[^"]*"[^>]*>\s*<div class="sidebar-item-icon[^"]*">\s*<svg[^>]*><circle cx="12" cy="12" r="3"\/><\/svg>/g)].length;
  if (dots) problems.push(`${dots} sidebar menu item(s) render the placeholder dot instead of an icon`);

  // 7. A class name with a stray leading/trailing hyphen is a status string
  //    that was not trimmed: WHMCS renders " Closed " with spaces, and
  //    |lower|replace:' ':'-' turned it into "-closed-" - no CSS rule matched
  //    and every closed-ticket check failed (closed tickets kept Close).
  const stray = new Set();
  for (const m of html.matchAll(/class="([^"]*)"/g)) {
    for (const tok of m[1].split(/\s+/)) if (/^-[a-z]|[a-z]-$/.test(tok)) stray.add(tok);
  }
  if (stray.size) problems.push(`class name(s) with a stray hyphen (untrimmed status text?): ${[...stray].join(' ')}`);

  // 8. Signed out when we should be signed in (or the reverse). A state-
  //    changing GET without its CSRF token signs the customer out (8f7e5f2).
  if (expectAuth && auth && auth !== expectAuth) problems.push(`expected data-auth="${expectAuth}", got "${auth}"`);

  return { problems, tpl, auth, title: t };
}
