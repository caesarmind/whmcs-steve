// Minimal dev license server for MyTheme / Hadrian.
//
//   node server.mjs           # listens on http://127.0.0.1:8787/  (POST /check)
//   PORT=9000 node server.mjs
//
// It speaks MyTheme License.php's protocol: form-encoded POST in, RSA-signed JSON out.
// "Sales DB" is licenses.json (edit by hand or via `node issue.mjs`). For production,
// replace loadDb()/lookup with a query against your real store (WHMCS licensing tables,
// billing DB, etc.) — see README.md "Path to production".
import http from 'node:http';
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { signPayload } from './sign.mjs';

const DIR = path.dirname(fileURLToPath(import.meta.url));
const PORT = process.env.PORT || 8787;
const PRIVATE_KEY = fs.readFileSync(path.join(DIR, 'keys', 'dev-private.pem'), 'utf8');
const DB_PATH = path.join(DIR, 'licenses.json');

const loadDb = () => JSON.parse(fs.readFileSync(DB_PATH, 'utf8'));

function readBody(req) {
  return new Promise((resolve) => {
    let data = '';
    req.on('data', (c) => (data += c));
    req.on('end', () => resolve(Object.fromEntries(new URLSearchParams(data))));
  });
}

/** Build the 6-field license payload the client expects (before the signature is added). */
function buildPayload(fields, rec) {
  const nowIso = new Date().toISOString();
  if (!rec) {
    return {
      license_status: 'Invalid', // unknown key
      expires: '',
      allowed_domains: [],
      features: [],
      nonce_echo: fields.nonce || '',
      signed_at: nowIso,
    };
  }
  return {
    license_status: rec.status, // Active | Suspended | Expired | Cancelled | Banned
    expires: rec.expires || '',
    allowed_domains: rec.allowed_domains || [],
    features: rec.features || [],
    nonce_echo: fields.nonce || '',
    signed_at: nowIso,
  };
}

const server = http.createServer(async (req, res) => {
  const url = (req.url || '').split('?')[0];
  if (req.method === 'GET' && url === '/health') {
    res.writeHead(200, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({ ok: true, keys: Object.keys(loadDb()).length }));
    return;
  }
  if (req.method !== 'POST' || url !== '/check') {
    res.writeHead(404, { 'Content-Type': 'text/plain' });
    res.end('Not found — POST /check');
    return;
  }

  const fields = await readBody(req);
  let rec = null;
  try {
    rec = loadDb()[fields.licensekey] || null;
  } catch (e) {
    res.writeHead(500); res.end('license db error'); return;
  }

  const payload = buildPayload(fields, rec);
  const signature = signPayload(payload, PRIVATE_KEY);

  res.writeHead(200, { 'Content-Type': 'application/json' });
  res.end(JSON.stringify({ ...payload, signature }));

  console.log(
    `[check] key=${fields.licensekey || '(none)'} domain=${fields.domain || '(none)'} ` +
      `nonce=${(fields.nonce || '').slice(0, 8)}… -> ${payload.license_status}`,
  );
});

server.listen(PORT, '127.0.0.1', () =>
  console.log(`MyTheme license server: http://127.0.0.1:${PORT}/  (POST /check, GET /health)`),
);
