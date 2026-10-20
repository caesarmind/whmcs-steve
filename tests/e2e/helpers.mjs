// Sessions for specs.
//
// Every worker logs in for ITSELF. WHMCS rotates the session id, so a single
// saved session shared across parallel workers gets invalidated by whichever
// worker triggers the rotation first, and the rest are silently signed out -
// which reads as a flaky theme bug. A login is ~0.5s; a private session per
// worker is cheap insurance.

import { request } from '@playwright/test';
import { BASE_URL, USER_AGENT, credentials, fixtures } from '../lib/env.mjs';

export const creds = credentials();
export const fx = fixtures();

async function token(ctx, url) {
  const html = await (await ctx.get(url)).text();
  const m = html.match(/name="token" value="([^"]+)"/);
  if (!m) throw new Error(`no CSRF token on ${url}`);
  return m[1];
}

/** Log `ctx` (an APIRequestContext, or a BrowserContext's .request) in. */
export async function loginClient(ctx, persona) {
  if (persona === 'guest') return;
  const p = creds.personas[persona];
  if (!p) throw new Error(`persona ${persona} is not seeded`);
  await ctx.post('/index.php?rp=/login', { form: { username: p.email, password: p.password, token: await token(ctx, '/login') } });
}

export async function loginAdmin(ctx) {
  await ctx.post('/admin/dologin.php', {
    form: { username: creds.admin.username, password: creds.admin.password, token: await token(ctx, '/admin/login.php') },
    maxRedirects: 0,
  });
}

export async function session(persona) {
  const ctx = await request.newContext({ baseURL: BASE_URL, userAgent: USER_AGENT });
  if (persona === 'admin') await loginAdmin(ctx); else await loginClient(ctx, persona);
  return ctx;
}
