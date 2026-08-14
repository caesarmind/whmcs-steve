<?php
declare(strict_types=1);

namespace MyThemeLicensing;

/**
 * RS256 over canonical JSON — byte-for-byte the contract that
 * MyTheme\Template\License::verifyResponse() checks on the buyer side.
 *
 * canonicalArray() is copied verbatim from the client so the signed bytes match
 * exactly: assoc arrays ksort()ed recursively, lists kept in order, then
 * json_encode with JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE.
 */
final class Signer
{
    public static function sign(array $payload, string $privateKeyPem): string
    {
        $key = openssl_pkey_get_private($privateKeyPem);
        if ($key === false) {
            throw new \RuntimeException('MyThemeLicensing: invalid/unreadable private key');
        }
        openssl_sign(self::canonicalJson($payload), $signature, $key, OPENSSL_ALGO_SHA256);
        return base64_encode($signature);
    }

    public static function canonicalJson(array $data): string
    {
        return (string) json_encode(
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
}
