// End-to-end handshake test: acts as MyTheme's License.php client against the running
// server, then verifies each response with the SAME logic License::verifyResponse uses.
// If a row says ACCEPT here, the PHP client will accept it too (proven separately by
// verify.php, which runs the real openssl_verify).
//
//   node server.mjs &            # in another shell
//   node test/test-handshake.mjs
import http from 'node:http';
import fs from 'node:fs';
import crypto from 'node:crypto';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { verifyPayload } from '../sign.mjs';

const DIR = path.dirname(fileURLToPath(import.meta.url));
const PUBLIC_KEY = fs.readFileSync(path.join(DIR, '..', 'keys', 'dev-public.pem'), 'utf8');
const BASE = process.env.LICENSE_URL || 'http://127.0.0.1:8787/';

function post(fields) {
  const body = new URLSearchParams(fields).toString();
  return new Promise((resolve, reject) => {
    const req = http.request(
      BASE + 'check',
      { method: 'POST', headers: { 'Content-Type': 'application/x-www-form-urlencoded', 'Content-Length': Buffer.byteLength(body) } },
      (res) => {
        let data = '';
        res.on('data', (c) => (data += c));
        res.on('end', () => resolve(data));
      },
    );
    req.on('error', reject);
    req.write(body);
    req.end();
  });
}

const eq = (a, b) => {
  const x = Buffer.from(String(a));
  const y = Buffer.from(String(b));
  return x.length === y.length && crypto.timingSafeEqual(x, y); // mirror PHP hash_equals
};

/** Faithful port of License::verifyResponse + the post-verify domain check. */
function clientVerify(rawJson, expectedNonce, domain) {
  let data;
  try { data = JSON.parse(rawJson); } catch { return { ok: false, why: 'bad json' }; }
  if (!data || !data.signature || !data.nonce_echo || !data.signed_at) return { ok: false, why: 'missing fields' };
  if (!eq(expectedNonce, data.nonce_echo)) return { ok: false, why: 'nonce mismatch (replay)' };
  const signedAt = Date.parse(data.signed_at);
  if (Number.isNaN(signedAt) || Math.abs(Date.now() - signedAt) > 86400 * 1000) return { ok: false, why: 'stale signed_at' };
  const { signature, ...payload } = data;
  if (!verifyPayload(payload, signature, PUBLIC_KEY)) return { ok: false, why: 'signature invalid' };
  const domainOk = Array.isArray(data.allowed_domains) && data.allowed_domains.includes(domain);
  return { ok: true, status: data.license_status, domainOk, expires: data.expires || '(none)' };
}

const nonce = () => crypto.randomBytes(16).toString('hex');

function render(verdict) {
  if (!verdict.ok) return `REJECT (${verdict.why})`;
  const dom = verdict.domainOk ? 'domain OK' : 'DOMAIN NOT AUTHORIZED -> client forces Invalid';
  return `ACCEPT  status=${verdict.status}  ${dom}`;
}

const run = async () => {
  console.log(`\nMyTheme license handshake test  (server: ${BASE})\n${'-'.repeat(72)}`);
  const cases = [];

  // 1. Valid key + authorized domain -> the happy path (theme renders)
  {
    const n = nonce();
    const raw = await post({ licensekey: 'HOSTNODES-DEV-ACTIVE-0001', domain: 'bill.hostnodes.com', nonce: n, version: '1.1.103' });
    cases.push(['valid key + good domain', render(clientVerify(raw, n, 'bill.hostnodes.com'))]);
    fs.writeFileSync(path.join(DIR, 'sample-response.json'), raw); // for the PHP gold-standard test
    fs.writeFileSync(path.join(DIR, 'sample-nonce.txt'), n);
  }

  // 2. Valid key but WRONG domain -> signature OK, but client forces Invalid
  {
    const n = nonce();
    const raw = await post({ licensekey: 'HOSTNODES-DEV-ACTIVE-0001', domain: 'pirate.example', nonce: n, version: '1.1.103' });
    cases.push(['valid key + wrong domain', render(clientVerify(raw, n, 'pirate.example'))]);
  }

  // 3. Unknown key -> server returns Invalid (still signed)
  {
    const n = nonce();
    const raw = await post({ licensekey: 'NOPE-NOT-A-REAL-KEY', domain: 'bill.hostnodes.com', nonce: n, version: '1.1.103' });
    cases.push(['unknown key', render(clientVerify(raw, n, 'bill.hostnodes.com'))]);
  }

  // 4. Cancelled key -> Cancelled (client deactivates immediately)
  {
    const n = nonce();
    const raw = await post({ licensekey: 'HOSTNODES-DEV-CANCELLED', domain: 'bill.hostnodes.com', nonce: n, version: '1.1.103' });
    cases.push(['cancelled key', render(clientVerify(raw, n, 'bill.hostnodes.com'))]);
  }

  // 5. Tampered response -> flip one signature char -> signature must fail
  {
    const n = nonce();
    const raw = await post({ licensekey: 'HOSTNODES-DEV-ACTIVE-0001', domain: 'bill.hostnodes.com', nonce: n, version: '1.1.103' });
    const obj = JSON.parse(raw);
    obj.license_status = 'Active'; // pretend an attacker forces Active...
    obj.allowed_domains = ['pirate.example']; // ...on their own domain
    cases.push(['tampered payload (forged Active)', render(clientVerify(JSON.stringify(obj), n, 'pirate.example'))]);
  }

  // 6. Replay -> response for nonce A checked against nonce B
  {
    const nA = nonce();
    const raw = await post({ licensekey: 'HOSTNODES-DEV-ACTIVE-0001', domain: 'bill.hostnodes.com', nonce: nA, version: '1.1.103' });
    cases.push(['replay (nonce mismatch)', render(clientVerify(raw, nonce(), 'bill.hostnodes.com'))]);
  }

  for (const [name, verdict] of cases) console.log(`  ${name.padEnd(34)} ${verdict}`);
  console.log(`${'-'.repeat(72)}\nSaved a valid response to test/sample-response.json for the PHP openssl_verify proof.\n`);
};

run().catch((e) => { console.error('test error:', e.message); process.exit(1); });
