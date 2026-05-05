<?php
declare(strict_types=1);

namespace MyTheme\Template;

use MyTheme\Helpers\IntegrityHashes;
use MyTheme\Models\Configuration;

/**
 * License client — PHP 8.1+ / WHMCS 9 compatible.
 *
 * Improvements over typical commercial-theme implementations:
 *   - HMAC-SHA256 (not MD5) for the local cache MAC, verified with hash_equals
 *   - JSON encoding (not unserialize → no RCE class on MAC bypass)
 *   - Strict TLS verification on the callback
 *   - Per-request nonce with echo verification (anti-replay)
 *   - signed_at timestamp validation (≤ 24h tolerance)
 *   - Server-asserted allowed_domains (not just SERVER_NAME pinning)
 *   - LicenseState enum (PHP 8.1+ backed enum)
 *   - Banner UI rendered via .tpl files
 *   - readonly properties on all immutable state
 */
final class License
{
    /**
     * RSA public key (PEM) of the license server.
     *
     * REPLACE THIS PLACEHOLDER before encoding for production.
     * Generate the keypair with:
     *   openssl genrsa -out private.pem 4096
     *   openssl rsa -in private.pem -pubout -out public.pem
     */
    private const LICENSE_SERVER_PUBLIC_KEY = <<<'PEM'
-----BEGIN PUBLIC KEY-----
REPLACE_WITH_YOUR_RSA_PUBLIC_KEY_BEFORE_ENCODING
-----END PUBLIC KEY-----
PEM;

    /** Where to POST license checks. Override per environment. */
    public static string $licenseServerUrl = 'https://licensing.your-domain.com/';

    private const GRACE_DAYS               = 30;
    private const WARNING_BEFORE_DAYS      = 3;
    private const CACHE_TTL_HOURS          = 24;
    private const MAX_RESPONSE_AGE_SECONDS = 86400;
    private const HTTP_TIMEOUT             = 15;

    public readonly string   $licenseKeyName;
    public readonly string   $templateName;
    private readonly string  $secretKey;
    private readonly Template $template;

    private readonly string $cfgKeyLicense;
    private readonly string $cfgKeyData;
    private readonly string $cfgKeyWarning;
    private readonly string $cfgKeyHour;
    private readonly string $cfgKeyDomain;

    /** Decoded cache from tblconfiguration. Empty array on first run. */
    private array $cache = [];

    public function __construct(string $licenseKeyName, string $secretKey, Template $template)
    {
        IntegrityHashes::verifyOrDie(__FILE__);

        $this->licenseKeyName = $licenseKeyName;
        $this->secretKey      = $secretKey;
        $this->template       = $template;
        $this->templateName   = $template->getName();

        $this->cfgKeyLicense = $licenseKeyName;
        $this->cfgKeyData    = $licenseKeyName . '-data';
        $this->cfgKeyWarning = $licenseKeyName . '-warning';
        $this->cfgKeyHour    = $licenseKeyName . '-hour';
        $this->cfgKeyDomain  = 'MyTheme-license-domain';

        // Dev-mode short-circuit: skip network entirely. Set in core/<slug>.php.
        if ($template->devMode) {
            return;
        }

        $this->ensureCheckHour();
        $this->loadCache();
        $this->maybeRefresh();
    }

    public function isActive(): bool
    {
        if ($this->template->devMode) {
            return true;
        }
        return LicenseState::tryFromString($this->cache['license_status'] ?? null)
            ->shouldRender();
    }

    public function isDevMode(): bool
    {
        return $this->template->devMode;
    }

    public function getLicenseKey(): string
    {
        return (string)Configuration::getValue($this->cfgKeyLicense);
    }

    public function setLicenseKey(string $key): void
    {
        Configuration::setValue($this->cfgKeyLicense, $key);
        Configuration::deleteValue($this->cfgKeyData);   // force re-check
    }

    public function refreshNow(): array
    {
        return $this->refresh(forceFresh: true);
    }

    public function getDashboardBanner(): ?string
    {
        if ($this->template->devMode) {
            return \MyTheme\View\ViewHelper::renderAdminPartial('license/banner', [
                'state'   => 'DEV_MODE',
                'days'    => null,
                'message' => 'Development mode is active — license checks are bypassed. Set dev_mode to false in templates/' . $this->templateName . '/core/' . $this->templateName . '.php before encoding for production.',
                'key'     => $this->getLicenseKey(),
            ]);
        }

        $state   = LicenseState::tryFromString($this->cache['license_status'] ?? null);
        $expires = isset($this->cache['expires']) ? (int)$this->cache['expires'] : null;
        $days    = $expires !== null ? max(0.0, ($expires - time()) / 86400) : null;
        $message = Configuration::getValue($this->cfgKeyWarning) ?: null;

        if (!$state->shouldShowBanner($days, $message)) {
            return null;
        }

        return \MyTheme\View\ViewHelper::renderAdminPartial('license/banner', [
            'state'   => $state->name,
            'days'    => $days !== null ? (int)$days : null,
            'message' => $message,
            'key'     => $this->getLicenseKey(),
        ]);
    }

    // ---------------------------------------------------------------- internals

    private function ensureCheckHour(): void
    {
        $hour = Configuration::getValue($this->cfgKeyHour);
        if ($hour === null || $hour === '') {
            $hour = sprintf('%02d:%02d', random_int(4, 23), random_int(0, 59));
            Configuration::setValue($this->cfgKeyHour, $hour);
        }
    }

    private function loadCache(): void
    {
        $blob = Configuration::getValue($this->cfgKeyData);
        if ($blob === null || $blob === '') {
            return;
        }

        $decoded = $this->decode($blob);
        if ($decoded === null) {
            Configuration::deleteValue($this->cfgKeyData);
            return;
        }

        if (!isset($decoded['cached_at']) || (time() - (int)$decoded['cached_at']) > self::MAX_RESPONSE_AGE_SECONDS) {
            return;
        }

        $this->cache = $decoded;
    }

    private function maybeRefresh(): void
    {
        if ($this->shouldRefresh()) {
            $this->refresh(forceFresh: false);
        }
    }

    private function shouldRefresh(): bool
    {
        if ($this->cache === []) {
            return true;
        }

        $lastChecked = (int)($this->cache['cached_at'] ?? 0);
        $hoursAgo    = (time() - $lastChecked) / 3600;
        if ($hoursAgo >= self::CACHE_TTL_HOURS) {
            return true;
        }

        $hour        = Configuration::getValue($this->cfgKeyHour) ?: '04:00';
        $todayHourTs = (int)strtotime(date('Y-m-d') . ' ' . $hour);
        return $lastChecked < $todayHourTs && time() >= $todayHourTs;
    }

    private function refresh(bool $forceFresh): array
    {
        $key = $this->getLicenseKey();
        if ($key === '') {
            $this->setState(LicenseState::INVALID, 'No license key set');
            return [];
        }

        $domain = $_SERVER['SERVER_NAME'] ?? '';
        if ($domain === '') {
            // CLI / cron mode — defer to cached value
            return $this->cache;
        }

        Configuration::setValue($this->cfgKeyDomain, $domain);

        $nonce = bin2hex(random_bytes(16));
        $body  = http_build_query([
            'licensekey' => $key,
            'domain'     => $domain,
            'ip'         => $_SERVER['SERVER_ADDR'] ?? '',
            'dir'        => realpath(__DIR__ . '/../../../../../') ?: '',
            'version'    => $this->template->getVersion(),
            'template'   => $this->templateName,
            'clientdate' => date('Y-m-d'),
            'nonce'      => $nonce,
        ]);

        $response = $this->httpPost(self::$licenseServerUrl . 'check', $body);
        if ($response === null) {
            return $this->cache;   // network failure — keep current
        }

        $verified = $this->verifyResponse($response, $nonce);
        if ($verified === null) {
            $this->setState(LicenseState::INVALID, 'Server response failed verification');
            return $this->cache;
        }

        $this->cache = [
            'license_status'  => $verified['license_status'] ?? 'Unknown',
            'expires'         => isset($verified['expires']) ? strtotime($verified['expires']) : null,
            'allowed_domains' => $verified['allowed_domains'] ?? [],
            'features'        => $verified['features'] ?? [],
            'cached_at'       => time(),
        ];

        if (!in_array($domain, $this->cache['allowed_domains'], strict: true)) {
            $this->setState(LicenseState::INVALID, 'Domain not authorized for this license');
        }

        $this->writeCache();
        $this->applyEnforcement();

        return $this->cache;
    }

    private function httpPost(string $url, string $body): ?string
    {
        if (!function_exists('curl_init')) {
            return null;
        }

        $ch = curl_init();
        curl_setopt_array($ch, [
            CURLOPT_URL            => $url,
            CURLOPT_POST           => true,
            CURLOPT_POSTFIELDS     => $body,
            CURLOPT_RETURNTRANSFER => true,
            CURLOPT_TIMEOUT        => self::HTTP_TIMEOUT,
            CURLOPT_SSL_VERIFYHOST => 2,
            CURLOPT_SSL_VERIFYPEER => true,
            CURLOPT_FOLLOWLOCATION => false,
        ]);

        $response = curl_exec($ch);
        $code     = curl_getinfo($ch, CURLINFO_HTTP_CODE);
        curl_close($ch);

        return ($response === false || $code !== 200) ? null : (string)$response;
    }

    /**
     * Server response shape:
     *   { license_status, expires, allowed_domains, features,
     *     nonce_echo, signed_at, signature }
     * Signature covers the JSON canonicalised (sorted keys, no whitespace) MINUS the signature field.
     */
    private function verifyResponse(string $rawJson, string $expectedNonce): ?array
    {
        $data = json_decode($rawJson, associative: true);
        if (!is_array($data)
            || !isset($data['signature'], $data['nonce_echo'], $data['signed_at'])
        ) {
            return null;
        }

        // 1. Nonce (replay protection)
        if (!hash_equals($expectedNonce, (string)$data['nonce_echo'])) {
            return null;
        }

        // 2. Recency (clock-skew tolerant)
        $signedAt = (int)strtotime((string)$data['signed_at']);
        if ($signedAt === 0 || abs(time() - $signedAt) > self::MAX_RESPONSE_AGE_SECONDS) {
            return null;
        }

        // 3. Signature
        $signature = base64_decode((string)$data['signature'], strict: true);
        if ($signature === false) {
            return null;
        }
        $payload = $data;
        unset($payload['signature']);
        $canonical = self::canonicalJson($payload);

        $publicKey = openssl_pkey_get_public(self::LICENSE_SERVER_PUBLIC_KEY);
        if ($publicKey === false) {
            return null;
        }

        return openssl_verify($canonical, $signature, $publicKey, OPENSSL_ALGO_SHA256) === 1
            ? $data
            : null;
    }

    /** Canonical JSON: sorted keys (recursively, but preserving list order), no whitespace. */
    private static function canonicalJson(array $data): string
    {
        return (string)json_encode(
            self::canonicalArray($data),
            JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE
        );
    }

    private static function canonicalArray(array $a): array
    {
        if (array_is_list($a)) {
            foreach ($a as &$v) {
                if (is_array($v)) {
                    $v = self::canonicalArray($v);
                }
            }
            return $a;
        }
        ksort($a);
        foreach ($a as &$v) {
            if (is_array($v)) {
                $v = self::canonicalArray($v);
            }
        }
        return $a;
    }

    private function decode(string $blob): ?array
    {
        $parts = explode('|', $blob);
        if (count($parts) !== 2) {
            return null;
        }
        [$payloadB64, $mac] = $parts;

        $expectedMac = hash_hmac('sha256', $payloadB64, $this->secretKey);
        if (!hash_equals($expectedMac, $mac)) {
            return null;
        }

        $payload = base64_decode($payloadB64, strict: true);
        if ($payload === false) {
            return null;
        }
        $decoded = json_decode($payload, associative: true);
        return is_array($decoded) ? $decoded : null;
    }

    private function writeCache(): void
    {
        $payload    = (string)json_encode($this->cache, JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE);
        $payloadB64 = base64_encode($payload);
        $mac        = hash_hmac('sha256', $payloadB64, $this->secretKey);
        Configuration::setValue($this->cfgKeyData, $payloadB64 . '|' . $mac);
    }

    private function setState(LicenseState $state, string $message = ''): void
    {
        $this->cache['license_status'] = $state->value;
        if ($message !== '') {
            Configuration::setValue($this->cfgKeyWarning, $message);
        }
    }

    private function applyEnforcement(): void
    {
        $state = LicenseState::tryFromString($this->cache['license_status'] ?? null);

        if ($state->shouldDeactivateImmediately()) {
            $this->deactivateTemplate();
            return;
        }

        if ($state->shouldStartGrace()) {
            $deactivateAt = (int)($this->cache['deactivation_date'] ?? (time() + self::GRACE_DAYS * 86400));
            $warnFrom     = (int)($this->cache['warning_from']      ?? (time() + (self::GRACE_DAYS - self::WARNING_BEFORE_DAYS) * 86400));

            $this->cache['deactivation_date'] = $deactivateAt;
            $this->cache['warning_from']      = $warnFrom;
            $this->writeCache();

            if (time() >= $deactivateAt) {
                $this->deactivateTemplate();
            }
        }
    }

    private function deactivateTemplate(): void
    {
        if (Configuration::getValue('Template') === $this->templateName) {
            Configuration::setValue('Template', 'six');
        }
        if (Configuration::getValue('OrderFormTemplate') === $this->templateName) {
            Configuration::setValue('OrderFormTemplate', 'standard_cart');
        }
    }
}
