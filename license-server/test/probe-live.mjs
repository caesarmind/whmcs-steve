// Read-only probe of a live MyThemeLicensing verify endpoint.
// Sends a BOGUS key (so no license is touched, no TOFU binding) and reports:
//   - is the module deployed / reachable
//   - does it return our JSON+signature shape
//   - does the signature verify against the DEV public key embedded in License.php
//
//   node test/probe-live.mjs [https://host/modules/servers/MyThemeLicensing/verify.php]
import https from 'node:https';
import http from 'node:http';
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { verifyPayload } from '../sign.mjs';

const DIR = path.dirname(fileURLToPath(import.meta.url));
const PUB = fs.readFileSync(path.join(DIR, '..', 'keys', 'dev-public.pem'), 'utf8');
const ENDPOINT = process.argv[2] || 'https://bill.hostnodes.com/modules/servers/MyThemeLicensing/verify.php';
const KEY      = process.argv[3] || 'PROBE-INVALID-KEY-DOES-NOT-EXIST';
const DOMAIN   = process.argv[4] || 'probe.invalid.test';

function post(endpoint, fields) {
  const body = new URLSearchParams(fields).toString();
  const u = new URL(endpoint);
  const lib = u.protocol === 'http:' ? http : https;
  return new Promise((res, rej) => {
    const req = lib.request(
      { hostname: u.hostname, port: u.port || undefined, path: u.pathname + u.search, method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded', 'Content-Length': Buffer.byteLength(body) } },
      (x) => { let d = ''; x.on('data', (c) => (d += c)); x.on('end', () => res({ status: x.statusCode, ct: x.headers['content-type'] || '', loc: x.headers['location'] || '', body: d })); },
    );
    req.on('error', rej);
    req.setTimeout(15000, () => req.destroy(new Error('timeout')));
    req.write(body); req.end();
  });
}

const nonce = 'probe-nonce-0001';
console.log('Probing:', ENDPOINT, '\n' + '-'.repeat(72));
try {
  console.log('key:', KEY, '| domain:', DOMAIN, '\n');
  const r = await post(ENDPOINT, {
    licensekey: KEY, domain: DOMAIN,
    nonce, version: '1.1.103', template: 'mytheme',
  });
  console.log('HTTP status :', r.status);
  console.log('Content-Type:', r.ct);
  if (r.loc) console.log('Location    :', r.loc);
  console.log('Body (first 240):', r.body.slice(0, 240).replace(/\n/g, ' '));
  try {
    const data = JSON.parse(r.body);
    console.log('JSON keys   :', Object.keys(data).join(', '));
    if (data.signature && 'nonce_echo' in data) {
      const { signature, ...payload } = data;
      console.log('nonce echo  :', data.nonce_echo === nonce ? 'matches' : 'MISMATCH');
      console.log('sig vs DEV public key:',
        verifyPayload(payload, signature, PUB)
          ? 'VERIFIES — server uses the dev keypair'
          : 'does NOT verify — server signs with a DIFFERENT key (I need ITS public key for License.php)');
    } else {
      console.log('No signature/nonce_echo — not our module response.');
    }
  } catch {
    console.log('=> Not JSON. Likely 404 (module not at this path) or an error/HTML page.');
  }
} catch (e) {
  console.log('Request failed:', e.message, '\n(network blocked from here, or host/path wrong)');
}
