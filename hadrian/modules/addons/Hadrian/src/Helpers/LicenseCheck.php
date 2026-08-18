<?php
declare(strict_types=1);

namespace Hadrian\Helpers;

/**
 * Admin-side license status check.
 *
 * The buyer-side license hook is the enforcement point. This is only for the
 * admin status display, so it calls the Licensing Manager's verify endpoint
 * directly over HTTPS and trusts the TLS response (it does not re-check the
 * HMAC - verifying it would mean shipping the product secret inside this
 * readable file). It POSTs to the FIXED vendor endpoint, never to a URL
 * derived from the request: $_SERVER['HTTP_HOST'] is the buyer's own domain
 * on every install but ours, where no verify.php exists. The request BODY
 * still mirrors the hook's (same domain + directory), because verify.php has
 * write side effects - a Reissued license locks to the calling environment
 * verbatim - so a mismatched identity here could consume the reissue or
 * create a false directory conflict.
 *
 * Results are cached briefly (tmp file, CACHE_TTL) so browsing the admin does
 * not hammer the vendor endpoint - every uncached hit is a log row and a
 * lastaccess update over there. Saving a key passes $fresh = true to bypass
 * the cache; failures (Unreachable/Unknown) are never cached, so the next
 * page view retries.
 *
 * Self-contained on purpose: WHMCS does not reliably expose the hook's functions
 * inside the admin addon context, so we must not depend on them here.
 */
final class LicenseCheck
{
    /** The Licensing Manager - the same endpoint the buyer-side hook posts to
        (HOSTNODES_VERIFY_URL there). Keep the two in lockstep. */
    private const VERIFY_URL = 'https://bill.hostnodes.com/modules/servers/licensing/verify.php';

    /** How long a successful check may be reused before re-asking. */
    private const CACHE_TTL = 900; // 15 min

    /** @return array{active:bool,status:string,data:array} */
    public static function status(string $key, bool $fresh = false): array
    {
        $key = trim($key);
        if ($key === '') {
            return ['active' => false, 'status' => 'No key', 'data' => []];
        }

        if (!$fresh && ($cached = self::readCache($key)) !== null) {
            return $cached;
        }

        $host = (string) ($_SERVER['HTTP_HOST'] ?? '');
        $resp = self::post(self::VERIFY_URL, [
            'licensekey'  => $key,
            'domain'      => $host,
            'ip'          => (string) ($_SERVER['SERVER_ADDR'] ?? ''),
            'dir'         => (defined('ROOTDIR') ? ROOTDIR : '') . '/includes/hooks',
            'check_token' => bin2hex(random_bytes(8)),
        ]);

        if ($resp === null) {
            return ['active' => false, 'status' => 'Unreachable', 'data' => []];
        }

        $env  = json_decode($resp, true);
        $data = is_array($env) ? json_decode((string) ($env['payload'] ?? ''), true) : null;
        if (!is_array($data)) {
            return ['active' => false, 'status' => 'Unknown', 'data' => []];
        }

        $status = (string) ($data['status'] ?? 'Invalid');

        // 'Error' is the Licensing Manager's catch-all for a server-side fault
        // (its unknown-key answer is 'Invalid'). Treat it like an outage: the
        // "could not verify right now" alert, and never cached, so the next
        // page view retries instead of pinning a transient hiccup for 15 min.
        if ($status === 'Error') {
            return ['active' => false, 'status' => 'Unreachable', 'data' => []];
        }

        $result = ['active' => $status === 'Active', 'status' => $status, 'data' => $data];
        self::writeCache($key, $result);
        return $result;
    }

    // ------------------------------------------------------------------ cache

    private static function cacheFile(): string
    {
        // Distinct from the enforcement hook's hn_theme_license.json - the two
        // caches answer different questions and expire on different clocks.
        return sys_get_temp_dir() . '/hn_admin_license_status.json';
    }

    /** @return array{active:bool,status:string,data:array}|null */
    private static function readCache(string $key): ?array
    {
        $raw = @file_get_contents(self::cacheFile());
        if ($raw === false) {
            return null;
        }
        $cache = json_decode($raw, true);
        if (
            !is_array($cache)
            || ($cache['key'] ?? null) !== $key      // key changed -> stale
            || (int) ($cache['expires'] ?? 0) < time()
            || !is_array($cache['result'] ?? null)
        ) {
            return null;
        }
        $r = $cache['result'];
        return [
            'active' => (bool) ($r['active'] ?? false),
            'status' => (string) ($r['status'] ?? 'Unknown'),
            'data'   => is_array($r['data'] ?? null) ? $r['data'] : [],
        ];
    }

    private static function writeCache(string $key, array $result): void
    {
        @file_put_contents(self::cacheFile(), (string) json_encode([
            'key'     => $key,
            'expires' => time() + self::CACHE_TTL,
            'result'  => $result,
        ]), LOCK_EX);
    }

    // -------------------------------------------------------------- transport

    private static function post(string $url, array $fields): ?string
    {
        if (!function_exists('curl_init')) {
            return null;
        }
        $ch = curl_init($url);
        curl_setopt_array($ch, [
            CURLOPT_RETURNTRANSFER => true,
            CURLOPT_POST           => true,
            CURLOPT_POSTFIELDS     => http_build_query($fields),
            CURLOPT_TIMEOUT        => 8,
            CURLOPT_CONNECTTIMEOUT => 5,
            CURLOPT_SSL_VERIFYPEER => true,
            CURLOPT_SSL_VERIFYHOST => 2,
        ]);
        $out  = curl_exec($ch);
        $code = curl_getinfo($ch, CURLINFO_HTTP_CODE);
        curl_close($ch);
        return ($out !== false && $code === 200) ? (string) $out : null;
    }
}
