<?php
declare(strict_types=1);

namespace HadrianBuilder;

/**
 * This module's own key/value settings: `hadrian_builder_settings`.
 *
 * Deliberately not Hadrian's settings table: Hadrian can be deactivated with
 * "Database Clear" on, which drops its tables, and it hands every row of its
 * own table to every client-area page.
 *
 * Values are JSON-encoded, so a bool comes back a bool and an array an array.
 */
final class Store
{
    public const TABLE = 'hadrian_builder_settings';

    /** @var array<string, mixed> */
    private static array $cache = [];

    public static function get(string $key, mixed $default = null): mixed
    {
        if (array_key_exists($key, self::$cache)) {
            return self::$cache[$key] ?? $default;
        }
        try {
            $raw = \WHMCS\Database\Capsule::table(self::TABLE)->where('setting', $key)->value('value');
        } catch (\Throwable $e) {
            // Table missing (files present, never activated): behave as if
            // nothing was ever saved, and do not cache the miss.
            return $default;
        }
        $value = $raw === null ? null : json_decode((string)$raw, true);
        self::$cache[$key] = $value;
        return $value ?? $default;
    }

    public static function set(string $key, mixed $value): void
    {
        \WHMCS\Database\Capsule::table(self::TABLE)->updateOrInsert(
            ['setting' => $key],
            [
                'value'      => json_encode($value, JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE | JSON_INVALID_UTF8_SUBSTITUTE),
                'updated_at' => date('Y-m-d H:i:s'),
            ]
        );
        self::$cache[$key] = $value;
    }

    public static function flush(): void
    {
        self::$cache = [];
    }
}
