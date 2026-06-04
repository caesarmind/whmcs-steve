<?php
declare(strict_types=1);

namespace MyTheme\Helpers;

/**
 * Admin-side license status check.
 *
 * The buyer-side license hook is the enforcement point. This is only for the
 * admin status display, so it calls the Licensing Manager's verify endpoint
 * directly over HTTPS and trusts the TLS response (it does not re-check the HMAC).
 * It mirrors the hook's request (same domain + directory) so it never creates a
 * new binding or a false directory conflict.
 *
 * Self-contained on purpose: WHMCS does not reliably expose the hook's functions
 * inside the admin addon context, so we must not depend on them here.
 */
final class LicenseCheck
{
    /** @return array{active:bool,status:string,data:array} */
    public static function status(string $key): array
    {
        $key = trim($key);
        if ($key === '') {
            return ['active' => false, 'status' => 'No key', 'data' => []];
        }

        $host = (string) ($_SERVER['HTTP_HOST'] ?? '');
        $resp = self::post('https://' . $host . '/modules/servers/licensing/verify.php', [
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
        return ['active' => $status === 'Active', 'status' => $status, 'data' => $data];
    }

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
