// In-browser checks shared by browser.spec, settings.spec and variants: what a
// real page looks like once laid out, and what broke while it loaded.

import { BASE_URL } from '../lib/env.mjs';
import { inspect } from './oracles.mjs';

/** Everything measured in the page, in one round trip. Runs IN the page. */
export const measure = () => {
  const box = sel => {
    const e = document.querySelector(sel);
    if (!e) return null;
    const cs = getComputedStyle(e), r = e.getBoundingClientRect();
    return cs.display === 'none' || cs.visibility === 'hidden' || r.width === 0
      ? null : { width: Math.round(r.width), left: Math.round(r.left), right: Math.round(r.right) };
  };
  const rgb = s => (s.match(/[\d.]+/g) || []).map(Number);
  const lum = ([r, g, b]) => [r, g, b].map(v => { v /= 255; return v <= 0.03928 ? v / 12.92 : ((v + 0.055) / 1.055) ** 2.4; })
    .reduce((a, v, i) => a + v * [0.2126, 0.7152, 0.0722][i], 0);
  const bgOf = el => {
    for (let e = el; e; e = e.parentElement) {
      const c = rgb(getComputedStyle(e).backgroundColor);
      if (c.length >= 3 && (c[3] === undefined || c[3] > 0.5)) return c;
    }
    return document.documentElement.dataset.theme === 'dark' ? [0, 0, 0] : [255, 255, 255];
  };
  const contrastOf = sel => {
    const el = [...document.querySelectorAll(sel)].find(e => e.textContent.trim().length > 2 && e.getBoundingClientRect().width > 0);
    if (!el) return null;
    const a = lum(rgb(getComputedStyle(el).color)), b = lum(bgOf(el));
    return { sel, text: el.textContent.trim().slice(0, 40), ratio: Math.round(((Math.max(a, b) + 0.05) / (Math.min(a, b) + 0.05)) * 100) / 100 };
  };
  // Accessibility basics, no library: controls a screen reader cannot name.
  const visible = e => { const r = e.getBoundingClientRect(), cs = getComputedStyle(e); return r.width > 0 && r.height > 0 && cs.visibility !== 'hidden' && cs.display !== 'none'; };
  const named = e => (e.getAttribute('aria-label') || e.getAttribute('aria-labelledby') || e.getAttribute('title') || e.textContent || '').trim().length > 0
    || [...e.querySelectorAll('img[alt], svg[aria-label], [aria-label]')].some(i => (i.getAttribute('alt') || i.getAttribute('aria-label') || '').trim());
  const labelled = e => !!(e.getAttribute('aria-label') || e.getAttribute('aria-labelledby') || e.getAttribute('title') || e.getAttribute('placeholder')
    || (e.id && document.querySelector(`label[for="${CSS.escape(e.id)}"]`)) || e.closest('label'));
  const where = e => `${e.tagName.toLowerCase()}${e.id ? '#' + e.id : ''}${e.className && typeof e.className === 'string' ? '.' + e.className.trim().split(/\s+/).slice(0, 2).join('.') : ''}`;
  const a11y = [
    ...[...document.querySelectorAll('button, a[href]')].filter(e => visible(e) && !named(e)).map(e => `unnamed ${e.tagName === 'A' ? 'link' : 'button'} ${where(e)}`),
    ...[...document.querySelectorAll('input:not([type=hidden]):not([type=submit]):not([type=button]), select, textarea')].filter(e => visible(e) && !labelled(e)).map(e => `unlabelled field ${where(e)}[name=${e.name}]`),
    ...[...document.querySelectorAll('img:not([alt])')].filter(visible).map(e => `image without alt ${where(e)} ${(e.getAttribute('src') || '').slice(-40)}`),
  ];
  return {
    a11y: [...new Set(a11y)].slice(0, 12),
    layout: document.body.dataset.layout,
    theme: document.documentElement.dataset.theme,
    sidebar: box('.sidebar'), rail: box('.ph-rail'), content: box('.content-area'),
    topVisible: [...document.querySelectorAll('.only-top')].some(e => e.getBoundingClientRect().width > 0),
    overflowX: document.documentElement.scrollWidth - innerWidth,
    contrast: [contrastOf('.content-area h1, .page-header h1, h1'), contrastOf('.content-area p, .content-area td, .content-area label')].filter(Boolean),
  };
};

/**
 * Start collecting what goes wrong on `page`: console errors, uncaught
 * exceptions, same-origin responses >= 400, failed requests. `label()` sets
 * the prefix later problems are reported under.
 */
export function watch(page) {
  const problems = [];
  let where = '';
  page.on('console', m => { if (m.type() === 'error') problems.push(`${where} console error: ${m.text().slice(0, 200)}`); });
  page.on('pageerror', e => problems.push(`${where} uncaught exception: ${e.message.slice(0, 200)}`));
  page.on('response', r => { if (r.url().startsWith(BASE_URL) && r.status() >= 400) problems.push(`${where} ${r.status()} ${r.url().replace(BASE_URL, '')}`); });
  page.on('requestfailed', r => { if (r.url().startsWith(BASE_URL)) problems.push(`${where} request failed: ${r.url().replace(BASE_URL, '')} (${r.failure()?.errorText})`); });
  return { problems, label: w => { where = w; } };
}

/**
 * Load `url` and judge it: the HTML oracles, plus overflow, a visible content
 * area and readable text. Returns { problems, html, m }.
 */
export async function judge(page, url, { where = url, expectAuth, a11y = false } = {}) {
  await page.goto(url, { waitUntil: 'load' });
  const html = await page.content();
  const problems = inspect(html, { expectAuth }).problems.map(p => `${where}: ${p}`);
  const m = await page.evaluate(measure);
  const vw = page.viewportSize().width;
  if (m.overflowX > 1) problems.push(`${where}: horizontal overflow of ${m.overflowX}px`);
  if (m.content && m.content.right > vw + 1) problems.push(`${where}: content runs off the right edge (${m.content.right}px > ${vw}px)`);
  for (const c of m.contrast) if (c.ratio < 3) problems.push(`${where}: unreadable text (${c.ratio}:1) in ${c.sel}: "${c.text}"`);
  if (a11y) for (const a of m.a11y) problems.push(`${where}: ${a}`);
  return { problems, html, m };
}
