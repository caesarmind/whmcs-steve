# MyThemeLicensing — WHMCS server module (the issuer, Lagom-style)

This is the **issuer** side of Hadrian licensing, structured the way Lagom's
`RSLicensing` is: a WHMCS **server (provisioning) module**. A license becomes a
normal WHMCS product, so the billing lifecycle drives the license status for
free (unpaid → suspended → the theme reacts; cancelled → theme falls back).

> **Seller-side only.** This never ships to buyers and is **not** in the theme
> deploy path. You install it once, on the WHMCS you sell Hadrian from.

```
MyThemeLicensing/
├─ MyThemeLicensing.php   server module: MetaData/ConfigOptions/CreateAccount/…
├─ verify.php             the call-home endpoint (RSA-signs responses)
├─ clientarea.tpl         customer license panel
├─ licenses.dev.json      dev "sales DB" (used only when no WHMCS is detected)
├─ lib/Signer.php         RS256 over canonical JSON (matches the client exactly)
├─ lib/LicenseStore.php   WHMCS-backed store + dev file store + auto-detect
└─ keys/                  signing keys (private key must NOT be web-reachable)
```

## How a license flows (production)

1. **You** create a WHMCS Product that uses the *MyTheme / Hadrian Licensing*
   server module. Set its config options: `Features` and `Max Domains`.
2. A customer orders it → `CreateAccount()` generates a key (`HADRIAN-…`) into the
   `mod_mytheme_licenses` table and shows it in their client area.
3. The customer enters that key in **their** WHMCS: *Addons → MyTheme → License*.
4. Their theme POSTs to `verify.php`, which looks up the service, maps the WHMCS
   status, binds the calling domain (trust-on-first-use, up to `Max Domains`),
   and returns an **RSA-signed** answer the theme verifies.

**WHMCS status → license_status:**

| WHMCS `domainstatus` | returned `license_status` | theme |
|---|---|---|
| Active | Active | renders |
| Suspended | Suspended | renders (don't punish mid-grace) |
| Terminated / Cancelled | Cancelled | falls back to six/standard_cart |
| Fraud | Banned | falls back |
| Pending / unknown | Invalid | 30-day grace then falls back |

## Install (on your seller WHMCS)

1. Copy the `MyThemeLicensing/` folder to `modules/servers/MyThemeLicensing/`.
2. Put your **production** RSA private key at `keys/private.pem` (the matching
   public key goes in the theme's `License.php`). Better: store the key outside
   the webroot and adjust the path in `verify.php`. The bundled `keys/.htaccess`
   denies web access as a backstop.
3. Create the licensing Product (server module = *MyTheme / Hadrian Licensing*).
4. In the theme, set `License::$licenseServerUrl` to this endpoint's public URL:
   `https://billing.hostnodes.com/modules/servers/MyThemeLicensing/verify.php`

The `mod_mytheme_licenses` table is created automatically on first order.

## Dev testing (no WHMCS needed)

`make_store()` falls back to `licenses.dev.json` when it can't find a WHMCS
install, so you can exercise the real endpoint with PHP's built-in server:

```bash
php -S 127.0.0.1:8790 -t license-server/whmcs-module/MyThemeLicensing
# then point a client at http://127.0.0.1:8790/verify.php
LICENSE_URL=http://127.0.0.1:8790/verify.php php license-server/test/client-sim.php
```

The dev keypair (`license-server/keys/`) is reused, and its public half is
already embedded in `License.php`, so signatures verify end to end.

## Security notes

- Serve `verify.php` over **HTTPS** (the client enforces strict TLS).
- The **private key never leaves the server**; only the public key ships in the theme.
- Forgery resistance is asymmetric (RSA signature) — unlike WHMCS/Lagom's shared
  MD5 secret, extracting the buyer-side files does not let an attacker mint licenses.
- Domain binding is trust-on-first-use up to `Max Domains`; reset it with the
  admin **Reset Domains** button if a customer migrates.
