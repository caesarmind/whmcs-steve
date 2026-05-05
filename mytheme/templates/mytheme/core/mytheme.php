<?php
declare(strict_types=1);

/**
 * Per-template config — provides the secret_key used by License for
 * HMAC of the local cache, and a dev_mode flag for testing without a license server.
 *
 * THIS FILE WILL BE IONCUBE-ENCODED FOR PRODUCTION.
 *
 * Generate a fresh secret_key with:
 *   node -e "console.log(require('crypto').randomBytes(32).toString('hex'))"
 *
 * If you ship multiple templates (e.g. mytheme-lite, mytheme-pro), each
 * gets its own secret_key. Don't reuse keys across products.
 *
 * ──────────────────────────────────────────────────────────────────────────
 *  ⚠️  DEV MODE
 * ──────────────────────────────────────────────────────────────────────────
 *  When `dev_mode` is true:
 *    - License client skips the remote callback (no network round-trips)
 *    - canActivate() always returns true (template is treated as licensed)
 *    - Admin License tab shows a "Development mode" banner
 *
 *  REQUIRED before encoding for production:
 *    1. Set `dev_mode` to false
 *    2. Replace `secret_key` with 64 random hex chars (see command above)
 *    3. Replace LICENSE_SERVER_PUBLIC_KEY in src/Template/License.php
 *    4. Set $licenseServerUrl to your real licensing endpoint
 * ──────────────────────────────────────────────────────────────────────────
 */
return [
    'secret_key'   => 'REPLACE_WITH_64_HEX_CHARS_BEFORE_ENCODING_FOR_PRODUCTION',
    'display_name' => 'MyTheme',
    'version'      => '1.0.0',
    'description'  => 'A modern WHMCS client area theme',
    'preview'      => 'core/thumb.svg',
    'dev_mode'     => true,                  // ← FLIP TO false BEFORE PRODUCTION
    'functions'    => [
        'styles'   => true,
        'layouts'  => true,
        'pages'    => true,
        'settings' => true,
    ],
];
