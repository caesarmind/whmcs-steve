# MyTheme / Hadrian — dev license server

A minimal license server that speaks the exact protocol `MyTheme\Template\License`
(`mytheme/modules/addons/MyTheme/src/Template/License.php`) verifies: a form-encoded
`POST /check` in, an **RSA-signed JSON** response out.

> **This directory is NOT a deploy path.** Only `mytheme/**` and `mytheme_cart/**`
> are uploaded to the live WHMCS. The private key under `keys/` stays local and is
> gitignored. This is a *development/testing* server; see "Path to production" below.

## Quick start

```bash
cd license-server
node server.mjs                 # http://127.0.0.1:8787/  (POST /check, GET /health)

# in another shell:
node test/test-handshake.mjs    # acts as the client, runs valid/invalid/cancelled/tamper/replay
php  test/verify.php            # real PHP openssl_verify proof (License.php will accept it)

# issue/update a dev key:
node issue.mjs ACME-2026-AAaa Active 2027-06-04T00:00:00Z "acme.com,www.acme.com" dark-mode
```

The keypair already exists (`keys/dev-private.pem` / `keys/dev-public.pem`) and the
public half is embedded in `License.php`. `$License::$licenseServerUrl` points at
`http://127.0.0.1:8787/` for dev.

## Protocol

**Request** (form-encoded POST body the client sends):

| field | meaning |
|---|---|
| `licensekey` | the key entered in the admin License tab |
| `domain` | `$_SERVER['SERVER_NAME']` of the buyer's install |
| `ip`, `dir`, `version`, `template`, `clientdate` | telemetry / binding |
| `nonce` | per-request 16-byte hex (anti-replay) |

**Response** (JSON; the signature covers every field *except* `signature`):

```json
{
  "license_status": "Active",
  "expires": "2027-06-04T00:00:00Z",
  "allowed_domains": ["bill.hostnodes.com"],
  "features": ["dark-mode", "cms-pages"],
  "nonce_echo": "<echo of request nonce>",
  "signed_at": "2026-06-04T12:00:00.000Z",
  "signature": "<base64 RS256 over canonical(payload-without-signature)>"
}
```

Canonical JSON = keys sorted recursively, lists kept in order, no whitespace
(`sign.mjs` mirrors `License::canonicalArray`). The client checks, in order:
nonce echo → `signed_at` within 24h → RSA signature → `domain ∈ allowed_domains`.

## License states (what the theme does)

| `license_status` | Theme behavior |
|---|---|
| `Active` / `Suspended` / `Expired` | renders |
| `Cancelled` / `Banned` | deactivates immediately (falls back to `six`) |
| `Unknown` / `Invalid` | 30-day grace, then deactivates |

## How this compares to the WHMCS Licensing Addon (and Lagom)

The WHMCS **Licensing Addon** is the canonical pattern every commercial WHMCS theme
descends from. Its `check_license()` sample (`modules/servers/licensing/check_sample_code.php`):

- Sends `licensekey`, `domain`, `ip`, `dir`, and a `check_token` =
  `time() . md5(mt_rand() . licensekey)` (their nonce).
- Parses a `<key>value</key>` response with `/<(.*?)>([^<]+)<\/\1>/i`.
- **Integrity = symmetric MD5**: `md5hash == md5($licensing_secret_key . $check_token)`.
- Caches a **local key**: `serialize → base64 → prepend md5(date.secret) → strrev →
  append md5(data.secret) → wordwrap(80)`, re-checked every `localkeydays` (15) with
  `allowcheckfaildays` (5) of grace.

**Lagom** (`RSThemes`) is a near-verbatim clone of that addon — same `strrev`/`md5`/
`wordwrap(80)` local-key encoding — with an RSA layer added (it `openssl_public_decrypt`s
the response against an embedded certificate). Same MD5 cache, same `unserialize()`.

**This implementation** keeps the WHMCS *shape* (call-home, nonce, cached local key,
grace window) but upgrades the crypto, because the WHMCS/Lagom design has two weaknesses:

| | WHMCS addon / Lagom | This server + client |
|---|---|---|
| Response trust | symmetric **MD5** with an embedded shared secret (extractable after decode → forgeable) | **RSA signature** — server holds the private key; client only needs the public key |
| Local cache | `md5` MAC + `unserialize()` | **HMAC-SHA256** (`hash_equals`) + `json_decode` (no object-injection class) |
| Replay | `check_token` (plain) | `nonce` bound into the signed payload |
| Transport | `CURLOPT_SSL_VERIFYPEER = false` (Lagom) | strict TLS verify |

So you get the WHMCS lifecycle conventions without the MD5/`unserialize` footguns.

## Path to production

1. Generate a **production** keypair; keep the private key off this repo. Replace
   `LICENSE_SERVER_PUBLIC_KEY` in `License.php` with the new public key.
2. Point `License::$licenseServerUrl` at your real **https** licensing endpoint.
3. Back the lookup with a real store. Two good options (the doc's recommendation):
   - **WHMCS-backed**: keep selling/suspending/cancelling licenses in the WHMCS
     **Licensing Addon** you already run, and have this signing server read its
     tables (or call it) — WHMCS = system of record, this = the RSA signer.
   - **WHMCS server module**: port `server.mjs` into
     `modules/servers/MyThemeLicensing/verify.php` (exactly what RS Studio did with
     `RSLicensing` for Lagom).
4. Generate a unique per-template `secret_key`, set `dev_mode = false`, run
   `build:integrity`, and ionCube-encode `src/` + `core/<slug>.php`.

## Sources

- [WHMCS 9.0 — Software Licensing addon](https://docs.whmcs.com/9-0/addon-modules/software-licensing/)
- [WHMCS Licensing Addon integration sample (`check.php`)](https://github.com/hrace009/WHMCS-Licensing-Addon-Integration-Code-Sample/blob/master/check.php)
- [Build, License & Distribute Software | WHMCS](https://www.whmcs.com/software-licensing/)
