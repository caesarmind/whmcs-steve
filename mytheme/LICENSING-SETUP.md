# Licensing Setup

The theme calls back to a license server you operate. This document explains what to set up.

For commercial distribution, licensing is load-bearing: the template must not render normal pages unless the addon is active and the license layer exposes `$myTheme.license.canRender`.

## Architecture

```
buyer's WHMCS install
        │
        │ 1. License key entered in admin
        ▼
modules/addons/MyTheme/src/Template/License.php
        │
        │ 2. POST https://licensing.<your-domain>/check
        │    Body: {licensekey, domain, ip, dir, version, template, clientdate, nonce}
        ▼
your license server (separate project — NOT in this scaffold)
        │
        │ 3. Verify license key against your sales DB
        │    Verify domain matches purchased license
        │    Generate signed JSON response with sigalg=RS256
        ▼
returns: {status, expires, allowed_domains, features, nonce_echo, signed_at, signature}
        │
        │ 4. License client verifies signature with embedded RSA public key
        │    Verifies nonce matches what was sent
        │    Verifies signed_at is within 24h
        │    Verifies $_SERVER["SERVER_NAME"] is in allowed_domains
        │    Caches result for 24h with HMAC-SHA256 MAC
        ▼
theme renders normally OR falls back to "six" template
```

There is also a template-level guard in `templates/mytheme/header.tpl`. If the addon is missing or `$myTheme.license.canRender` is not present, the theme renders only a license-required screen. This prevents the plain template folder from being useful without the encoded addon.

## What you need to set up

### 1. Generate an RSA keypair (one per product line)

```bash
openssl genrsa -out license-server-private.pem 4096
openssl rsa -in license-server-private.pem -pubout -out license-server-public.pem
```

- **Private key**: stays on your license server, never leaves
- **Public key**: embedded in `modules/addons/MyTheme/src/Template/License.php` — replace the `LICENSE_SERVER_PUBLIC_KEY` constant placeholder

### 2. Set the license server URL

Edit `modules/addons/MyTheme/src/Template/License.php`:

```php
public static $licenseServerUrl = 'https://licensing.your-domain.com/';
```

The license client will POST to `{licenseServerUrl}check`.

### 3. Generate a per-template secret key

Each template under `templates/<slug>/` has a `core/<slug>.php` file with a `secret_key`. This is used as the HMAC-SHA256 key for the local cache.

```bash
# 32 random bytes, hex-encoded
node -e "console.log(require('crypto').randomBytes(32).toString('hex'))"
```

Put the result in `templates/mytheme/core/mytheme.php`:

```php
<?php
return [
    'secret_key'   => '<paste-hex-here>',
    'display_name' => 'MyTheme',
    'version'      => '1.0.0',
    'preview'      => 'core/thumb.svg',
    'functions'    => [...],
];
```

**This file MUST be ionCube-encoded for production.** The plain version is for development only.

### 4. Build your license server

The server has to:
- Accept `POST /check` with form-encoded body
- Look up the license key in your sales DB (e.g. WHMCS itself, billing system, custom)
- Verify the buyer's domain matches the purchased license's authorized domains
- Build a JSON response:

```json
{
  "status": "Active",
  "license_status": "Active",
  "expires": "2027-04-29T00:00:00Z",
  "allowed_domains": ["customer.com", "www.customer.com"],
  "features": ["dark-mode", "cms-pages"],
  "nonce_echo": "<echo what client sent>",
  "signed_at": "2026-04-29T12:00:00Z"
}
```

- Sign it: `signature = base64(rsa_sign(canonical_json, private_key, RS256))`
- Return: `{...response..., "signature": "<b64-sig>"}`

The **canonical JSON** for signing must be deterministic — sort keys alphabetically, no whitespace. The client does the same when verifying.

### 5. Recommended license server stacks

- **WHMCS itself + a custom server module** under `modules/servers/MyThemeLicensing/verify.php`. This is what RS Studio does for Lagom — keeps all licensing inside WHMCS.
- **Standalone Node/Go/Python service** if you want decoupling. ~200 lines of code total.

A reference Node implementation is sketched in `docs/license-server-reference.md` (TODO — write this when you're ready).

## License states

| `license_status` | Theme behavior |
|---|---|
| `Active` | Render normally |
| `Suspended` | Render normally (suspended = unpaid invoice; don't punish customer mid-grace) |
| `Expired` | Render normally with banner (let renewal flow work) |
| `Cancelled` | Deactivate immediately, fall back to `six` |
| `Banned` | Deactivate immediately |
| `Unknown` / `Invalid` | Start 30-day grace; deactivate after |

Codified in `src/Template/LicenseState.php` (the enum, not stringly-typed like Lagom).

For a stricter subscription product, change `LicenseState::shouldRender()` so only `Active` returns `true`. For a lifetime-use product with renewable support, keeping `Expired` renderable is acceptable because the license still exists, but support/updates can be denied by the license server.

## Production hardening checklist

- Set `templates/mytheme/core/mytheme.php` `dev_mode` to `false`.
- Replace the placeholder RSA public key in `License.php`.
- Replace `License::$licenseServerUrl` with the real licensing endpoint.
- Generate a unique per-template `secret_key`.
- Encode `modules/addons/MyTheme/src`, protected helpers, and `templates/mytheme/core/mytheme.php`.
- Regenerate integrity hashes after all production edits.
- Verify the template does not render in these cases:
        - addon disabled;
        - addon active but license key empty;
        - invalid domain;
        - invalid server signature;
        - cancelled/banned license.

## Local cache

The client caches the server response in `tblconfiguration` row `MyTheme-<slug>-license-data`:

- Payload is `json_encode([fields])` (NOT `serialize` — eliminates `unserialize()` RCE class)
- MAC is `hash_hmac('sha256', $payload, $secretKey)`
- Verified with `hash_equals` (constant time)
- TTL: 24h, randomized check hour (per `tblconfiguration` row `MyTheme-<slug>-license-hour`)

## Anti-tamper

The integrity-hash check (sha256 of `License.php`, `LicenseHelper.php`, `Template.php`, etc.) is automatic — see [BUILD.md § Integrity hashes](BUILD.md#integrity-hashes-the-load-bearing-anti-tamper).

A buyer who patches `License.php` to skip the network call will trip the integrity stub injected at the top of *other* encoded files (e.g. `Template.php`), and every page will render an "Access has been blocked!" page until they restore the file.

## Threat model — what this protects against and what it doesn't

**Protects against:**
- Casual reuse without a paid license (file-share-and-go)
- Naive domain hopping (license tied to domain)
- Local cache tampering (MAC mismatch → re-fetch from server → reject)
- Single-file patching of license code (chained integrity check trips on other files)
- Replay of captured server response (nonce mismatch)

**Does NOT protect against:**
- A motivated attacker with ionCube decoder access (they can decode, patch every integrity stub, re-encode). This is true for all PHP licensing.
- Server-side license server compromise (they get your private key)
- Buyer running with their own domain ↔ license valid (this is the *intended* path; you sell the license)

The point isn't to make piracy impossible. The point is to make piracy slower and more obvious than buying. That's what this scaffold targets.

## When a customer's license fails

Banner shown on every admin page, fallback to default template, customer's services break.

You'll get a support ticket. Diagnostics:

```sql
SELECT setting, value FROM tblconfiguration
  WHERE setting LIKE 'MyTheme-%';
```

Check:
- `MyTheme-<slug>-license` — the key
- `MyTheme-<slug>-license-data` — the encoded blob
- `MyTheme-<slug>-license-warning` — the warning message
- `MyTheme-license-domain` — captured `$_SERVER['SERVER_NAME']`

If the domain captured doesn't match what they purchased, that's the issue.
