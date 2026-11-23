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
  // One retry: right after a template changes, Windows Smarty can hand the
  // first request a truncated page (see lib/warmup.mjs) - one without its form.
  for (let attempt = 0; ; attempt++) {
    const html = await (await ctx.get(url)).text();
    // Already signed in: WHMCS answers /login with the dashboard.
    if (/<body[^>]*data-auth="in"/.test(html)) return null;
    const m = html.match(/name="token" value="([^"]+)"/);
    if (m) return m[1];
    if (attempt) throw new Error(`no CSRF token on ${url} (${html.length} bytes, twice)`);
    await new Promise(r => setTimeout(r, 1500));
  }
}

/** Log `ctx` (an APIRequestContext, or a BrowserContext's .request) in. */
export async function loginClient(ctx, persona) {
  if (persona === 'guest') return;
  const p = creds.personas[persona];
  if (!p) throw new Error(`persona ${persona} is not seeded`);
  const t = await token(ctx, '/login');
  if (t === null) return;   // this context is signed in already
  await ctx.post('/index.php?rp=/login', { form: { username: p.email, password: p.password, token: t } });
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

// ------------------------------------------------------------------ mail
import { MAILPIT_URL } from '../lib/env.mjs';
import crypto from 'node:crypto';

/**
 * The newest message to `to` that arrived after `since` (ms), from Mailpit.
 * Polls: WHMCS hands mail to sendmail synchronously, but give it a moment.
 * Returns { subject, text, html, links } or throws after `timeout`.
 */
export async function mailTo(to, since, { timeout = 20_000 } = {}) {
  const deadline = Date.now() + timeout;
  for (;;) {
    const list = await (await fetch(`${MAILPIT_URL}/api/v1/search?query=${encodeURIComponent('to:' + to)}&limit=5`)).json();
    const hit = (list.messages || []).find(m => Date.parse(m.Created) >= since - 2000);
    if (hit) {
      const m = await (await fetch(`${MAILPIT_URL}/api/v1/message/${hit.ID}`)).json();
      const body = `${m.Text || ''}\n${m.HTML || ''}`;
      return { subject: m.Subject, text: m.Text || '', html: m.HTML || '', links: [...new Set(body.match(/https?:\/\/[^\s"'<>]+/g) || [])].map(l => l.replace(/&amp;/g, '&')) };
    }
    if (Date.now() > deadline) throw new Error(`no mail to ${to} within ${timeout / 1000}s (is Mailpit running?)`);
    await new Promise(r => setTimeout(r, 750));
  }
}

/** RFC 6238 TOTP (SHA-1, 6 digits, 30 s) for a base32 secret, as WHMCS's TOTP module expects. */
export function totp(secret, at = Date.now()) {
  const alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ234567';
  let bits = '';
  for (const ch of secret.replace(/[\s=]/g, '').toUpperCase()) bits += alphabet.indexOf(ch).toString(2).padStart(5, '0');
  const key = Buffer.from(bits.match(/.{8}/g).map(b => parseInt(b, 2)));
  const counter = Buffer.alloc(8);
  counter.writeBigUInt64BE(BigInt(Math.floor(at / 1000 / 30)));
  const h = crypto.createHmac('sha1', key).update(counter).digest();
  const o = h[h.length - 1] & 15;
  return String(((h.readUInt32BE(o) & 0x7fffffff) % 1_000_000)).padStart(6, '0');
}
