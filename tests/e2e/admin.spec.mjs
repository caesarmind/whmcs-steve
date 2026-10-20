// Tier 3a (admin) - every Hadrian admin screen over HTTP as the test admin.
//
// Read views only. The screens are discovered at runtime where they take an
// id (each menu's editor, each style's editor) so a new menu or style is
// covered without editing this file. Nothing here POSTs, and the sub= actions
// that write (delete, seed, reset-defaults, remove, generate) are never hit.

import { test, expect } from '@playwright/test';
import { ADMIN_ACTIONS } from './routes.mjs';
import { session } from './helpers.mjs';
import { inspect, title } from './oracles.mjs';

const BASE = '/admin/addonmodules.php?module=Hadrian';

test.describe('admin', () => {
  let ctx;
  test.beforeAll(async () => { ctx = await session('admin'); });
  test.afterAll(async () => { await ctx?.dispose(); });

  async function check(url) {
    const res = await ctx.get(url, { maxRedirects: 0 });
    const html = await res.text();
    expect.soft(res.status(), `HTTP status (a 302 here usually means the admin session was lost)`).toBe(200);
    expect.soft(title(html), 'still inside the Hadrian addon').toBe('WHMCS - Hadrian');
    // The general oracles minus the client-area ones (no content-area, no
    // client sidebar, no data-auth in the WHMCS admin chrome).
    const { problems } = inspect(html);
    expect.soft(problems.filter(p => /error|Smarty|WHMCS/.test(p)), 'errors in the page').toEqual([]);
    // The addon's own wrapper must be there AND carry content: a template
    // that fails to compile leaves the WHMCS admin chrome with nothing in it.
    const wrap = html.match(/class="mt-wrap[^"]*"[\s\S]*$/);
    expect.soft(wrap, 'Hadrian admin wrapper (.mt-wrap) rendered').not.toBeNull();
    const text = (wrap?.[0] || '').replace(/<script[\s\S]*?<\/script>/g, '').replace(/<[^>]+>/g, ' ').replace(/\s+/g, ' ').trim();
    expect.soft(text.length, 'admin screen has content').toBeGreaterThan(200);
    return html;
  }

  for (const action of ADMIN_ACTIONS) {
    test(`action=${action}`, async () => { await check(`${BASE}&action=${action}`); });
  }

  test('every menu editor', async () => {
    test.setTimeout(5 * 60_000);   // visits every editor in one session (PHP serialises it)
    const html = await check(`${BASE}&action=menu`);
    const ids = [...new Set([...html.matchAll(/action=menu&(?:amp;)?sub=edit&(?:amp;)?id=(\d+)/g)].map(m => m[1]))];
    expect(ids.length, 'menu index links to at least one editor').toBeGreaterThan(0);
    for (const id of ids) await test.step(`menu id=${id}`, () => check(`${BASE}&action=menu&sub=edit&id=${id}`));
  });

  test('every style editor', async () => {
    test.setTimeout(5 * 60_000);   // visits every editor in one session (PHP serialises it)
    const html = await check(`${BASE}&action=styles`);
    const styles = [...new Set([...html.matchAll(/action=editStyle&(?:amp;)?style=([a-z0-9_-]+)/gi)].map(m => m[1]))];
    expect(styles.length, 'styles index links to at least one editor').toBeGreaterThan(0);
    for (const s of styles) await test.step(`style=${s}`, () => check(`${BASE}&action=editStyle&style=${s}`));
  });

  test('every page editor', async () => {
    test.setTimeout(5 * 60_000);   // visits every editor in one session (PHP serialises it)
    const html = await check(`${BASE}&action=pages`);
    const pages = [...new Set([...html.matchAll(/action=pages&(?:amp;)?sub=edit&(?:amp;)?page=([a-z0-9_-]+)/gi)].map(m => m[1]))];
    expect(pages.length, 'pages index links to at least one editor').toBeGreaterThan(0);
    for (const p of pages) await test.step(`page=${p}`, () => check(`${BASE}&action=pages&sub=edit&page=${p}`));
  });
});
