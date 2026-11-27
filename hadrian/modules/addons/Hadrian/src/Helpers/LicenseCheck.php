<?php
declare(strict_types=1);

namespace Hadrian\Helpers;

/**
 * Admin-side license status check.
 *
 * The buyer-side license hook is the enforcement point. This is only for the
 * admin status display. Both ask the same licence server, whose replies are
 * RSA-signed: this file carries the PUBLIC key, checks the signature, and
 * checks that the reply answers this request (our token and our key). A
 * public key cannot sign, so shipping it in this readable file is safe.
 *
 * It POSTs to the FIXED vendor endpoint, never to a URL derived from the
 * request: $_SERVER['HTTP_HOST'] is the buyer's own domain. The request BODY
 * mirrors the hook's (same domain + directory), because the licence server
 * has write side effects - a reissued licence locks to the calling
 * environment - so a mismatched identity here could consume the reissue or
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
    /** The licence server - the same endpoint the buyer-side hook posts to
        (HOSTNODES_VERIFY_URL there). Keep the two in lockstep. */
    private const VERIFY_URL = 'https://license.hostnodes.com/hostnodes-licensing/verify.php';

    /** The public half of the licence server's key pair (HOSTNODES_PUBLIC_KEY
        in the hook). It can check a signature, never make one. */
    private const PUBLIC_KEY = <<<'PEM'
-----BEGIN PUBLIC KEY-----
MIIBojANBgkqhkiG9w0BAQEFAAOCAY8AMIIBigKCAYEA1Xc4TAYa4OugGLYuuQOi
F++s9+LDiykDdDvjjAzBNn0rLFBE2JUCDSnF9c8vyUEJztjvIGri1+oeZCtrNi9g
4w1NqPJAN/gAN/OHTwOvOUOZZoJP2e3D2w7ZBlB4hgIiQVhqBd3iaHy683fQuSO2
Om/QbnTteDygbpVv/jicf7g0xUBPZYRFdv8M0ZDhzpcyxVhGLyOpJ4J8gxorzscx
0lZmM8ce6oxXimFx0pWYD3c22FNkQ4USTvfsHdWU9dcvRxSNb1rcbs91Ol+nAbK7
NskBE1iycpEBBPvI4RyFj6FmpdaL+yXtPCVVt2Q8apXCSz8mKoLL2ZlqWiAexDuK
4xh/RnKcm+FEUp7rfE1pRrPDGV5M6z7x9a70gnkiRKaoYj4E0oGN36T3fOwE2NvG
kiPX8eL5uJPeHOnnOBqQr95+AYIeqlpurEd8t+hGdFC9Sgq5JLf6wzenJY0do7UV
c1DD57OWE8MdxBToE3FqjxmBvWJM9JRFmLxfLXv5NDAnAgMBAAE=
-----END PUBLIC KEY-----
PEM;

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

        $host  = (string) ($_SERVER['HTTP_HOST'] ?? '');
        $nonce = bin2hex(random_bytes(16));
        $resp  = self::post(self::VERIFY_URL, [
            'licensekey'  => $key,
            'domain'      => $host,
            'ip'          => (string) ($_SERVER['SERVER_ADDR'] ?? ''),
            'dir'         => self::installDir(),
            'check_token' => $nonce,
            'product'     => 'hadrian',
            'version'     => self::installedRelease(),
        ]);

        // No answer, or a server-side fault (an unsigned 503): the "could not
        // verify right now" alert, never cached, so the next view retries.
        if ($resp === null) {
            return ['active' => false, 'status' => 'Unreachable', 'data' => []];
        }

        $data = self::open($resp, $nonce, $key);
        if ($data === null) {
            return ['active' => false, 'status' => 'Unknown', 'data' => []];
        }

        $status = (string) ($data['status'] ?? 'Invalid');
        $result = ['active' => $status === 'Active', 'status' => $status, 'data' => $data];
        self::writeCache($key, $result);
        return $result;
    }

    /**
     * The folder this install is bound to: the real path of includes/hooks with
     * forward slashes. The theme hook sends exactly the same string, so both
     * checks match the one binding on Windows and behind symlinks too.
     */
    private static function installDir(): string
    {
        $dir  = (defined('ROOTDIR') ? ROOTDIR : '') . '/includes/hooks';
        $real = realpath($dir);
        return str_replace('\\', '/', $real !== false ? $real : $dir);
    }

    // --------------------------------------------------------------- the reply

    /** The payload of a reply signed by the licence server for this request, or null. */
    private static function open(string $resp, string $nonce, string $key): ?array
    {
        if (!function_exists('openssl_verify')) {
            return null;
        }
        $env  = json_decode($resp, true);
        $body = is_array($env) ? ($env['payload'] ?? null) : null;
        $sig  = is_array($env) ? base64_decode((string) ($env['signature'] ?? ''), true) : false;
        if (!is_string($body) || $sig === false || $sig === ''
            || openssl_verify($body, $sig, self::PUBLIC_KEY, OPENSSL_ALGO_SHA256) !== 1) {
            return null;
        }
        $data = json_decode($body, true);
        if (!is_array($data)
            || !hash_equals($nonce, (string) ($data['nonce'] ?? ''))
            || !hash_equals($key, (string) ($data['key'] ?? ''))) {
            return null;
        }
        return $data;
    }

    /** The theme release this site runs, from the release.json a build stamps in. */
    private static function installedRelease(): string
    {
        $root = defined('ROOTDIR') ? ROOTDIR : '';
        $file = $root . '/templates/hadrian/release.json';
        // A git deploy has no release.json (the build stamps it in), and WHMCS
        // logs a warning for a missing file even when @ hides it.
        $mark = is_file($file) ? json_decode((string) @file_get_contents($file), true) : null;
        return is_array($mark) ? (string) ($mark['release'] ?? '') : '';
    }

    // ------------------------------------------------------------------ cache

    private static function cacheFile(): string
    {
        // Distinct from the enforcement hook's cache - the two answer different
        // questions and expire on different clocks. One per install: the temp
        // folder is shared by every WHMCS on the server, and a file keyed only
        // by licence key showed one install's "Active" on another's screen.
        return sys_get_temp_dir() . '/hn_admin_license_status_' . substr(sha1(self::installDir()), 0, 16) . '.json';
    }

    /**
     * Drop the enforcement hook's cached answer so the next page view asks the
     * licence server again (after a key is saved). The hook names its cache
     * after this install's hooks folder; ask it when it is loaded, and also
     * remove the single shared file older hooks used.
     */
    public static function dropSiteCache(): void
    {
        $file = function_exists('hostnodes_license_cachefile')
            ? (string) \hostnodes_license_cachefile()
            : sys_get_temp_dir() . '/hn_theme_license_' . substr(sha1(self::installDir()), 0, 16) . '.json';
        // is_file first: WHMCS logs a warning even when @ hides it.
        foreach ([$file, sys_get_temp_dir() . '/hn_theme_license.json'] as $f) {
            if (is_file($f)) {
                @unlink($f);
            }
        }
    }

    /** @return array{active:bool,status:string,data:array}|null */
    private static function readCache(string $key): ?array
    {
        $raw = is_file(self::cacheFile()) ? @file_get_contents(self::cacheFile()) : false;
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
