// Canonical-JSON + RS256 signing — the exact contract MyTheme's License.php verifies.
//
// PHP client (License::canonicalArray + canonicalJson) does:
//   - assoc arrays: ksort() recursively
//   - lists: preserve order
//   - json_encode(..., JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE)
//   - openssl_verify(canonical, sig, pubkey, OPENSSL_ALGO_SHA256)  // RSA PKCS#1 v1.5
//
// Node's crypto.sign('sha256', ...) on an RSA key defaults to PKCS#1 v1.5 padding,
// and JSON.stringify (no spacing) leaves '/' and unicode unescaped — so the bytes
// match PHP's json_encode with those flags for our ASCII/string-only payloads.
import crypto from 'node:crypto';

/** Recursively sort object keys; preserve array order. Mirrors License::canonicalArray. */
export function canonicalize(value) {
  if (Array.isArray(value)) return value.map(canonicalize);
  if (value && typeof value === 'object') {
    const out = {};
    for (const k of Object.keys(value).sort()) out[k] = canonicalize(value[k]);
    return out;
  }
  return value;
}

export function canonicalJson(payload) {
  return JSON.stringify(canonicalize(payload));
}

export function signPayload(payload, privateKeyPem) {
  return crypto
    .sign('sha256', Buffer.from(canonicalJson(payload), 'utf8'), { key: privateKeyPem })
    .toString('base64');
}

export function verifyPayload(payload, signatureB64, publicKeyPem) {
  return crypto.verify(
    'sha256',
    Buffer.from(canonicalJson(payload), 'utf8'),
    { key: publicKeyPem },
    Buffer.from(signatureB64, 'base64'),
  );
}
