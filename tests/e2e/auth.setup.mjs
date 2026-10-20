// Log every persona and the test admin in once, over plain HTTP, and save
// each session for the specs to reuse. Credentials come from
// .local/credentials.json, which tests/php/fixtures.php generates.
//
// The checks after each login are deliberate: a login that "succeeds" but
// lands back on the sign-in form would otherwise surface later as dozens of
// page failures that all look like theme bugs.

import { test as setup, expect, request } from '@playwright/test';
import fs from 'node:fs';
import path from 'node:path';
import { BASE_URL, USER_AGENT, credentials, authStatePath } from '../lib/env.mjs';

const creds = credentials();

async function tokenFrom(ctx, url) {
  const html = await (await ctx.get(url)).text();
  const m = html.match(/name="token" value="([^"]+)"/);
  if (!m) throw new Error(`no CSRF token on ${url}`);
  return m[1];
}

async function save(ctx, name) {
  fs.mkdirSync(path.dirname(authStatePath(name)), { recursive: true });
  await ctx.storageState({ path: authStatePath(name) });
}

setup('credentials exist', async () => {
  expect(creds, 'run: php tests/php/fixtures.php (run.mjs does this in preflight)').toBeTruthy();
});

setup('guest session', async () => {
  const ctx = await request.newContext({ baseURL: BASE_URL, userAgent: USER_AGENT });
  await ctx.get('/');
  await save(ctx, 'guest');
  await ctx.dispose();
});

for (const name of ['full', 'empty', 'suspended']) {
  setup(`client login: ${name}`, async () => {
    const p = creds.personas[name];
    setup.skip(!p, `persona ${name} not seeded`);
    const ctx = await request.newContext({ baseURL: BASE_URL, userAgent: USER_AGENT });
    const token = await tokenFrom(ctx, '/login');
    const res = await ctx.post('/index.php?rp=/login', {
      form: { username: p.email, password: p.password, token }, maxRedirects: 5,
    });
    const html = await res.text();
    expect(html, `${name} should be signed in after login`).toContain('data-auth="in"');
    await save(ctx, name);
    await ctx.dispose();
  });
}

setup('admin login', async () => {
  const ctx = await request.newContext({ baseURL: BASE_URL, userAgent: USER_AGENT });
  const token = await tokenFrom(ctx, '/admin/login.php');
  await ctx.post('/admin/dologin.php', {
    form: { username: creds.admin.username, password: creds.admin.password, token }, maxRedirects: 0,
  });
  const res = await ctx.get('/admin/addonmodules.php?module=Hadrian', { maxRedirects: 0 });
  expect(res.status(), 'admin session should reach the Hadrian addon').toBe(200);
  expect(await res.text()).toContain('<title>WHMCS - Hadrian</title>');
  await save(ctx, 'admin');
  await ctx.dispose();
});
