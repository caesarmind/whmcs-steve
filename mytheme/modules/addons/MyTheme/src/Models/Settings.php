<?php
declare(strict_types=1);

namespace MyTheme\Models;

/**
 * Wrapper around the `mytheme_settings` table — ONE typed table for all
 * theme-specific settings.
 */
final class Settings
{
    /** @var array<string, mixed> */
    private static array $cache = [];

    public static function getValue(string $key, mixed $default = null): mixed
    {
        if (array_key_exists($key, self::$cache)) {
            return self::$cache[$key];
        }
        $row = \WHMCS\Database\Capsule::table('mytheme_settings')
            ->where('setting', $key)
            ->first(['value', 'value_type']);

        if ($row === null) {
            return self::$cache[$key] = $default;
        }
        return self::$cache[$key] = self::cast($row->value, $row->value_type ?? 'string');
    }

    public static function setValue(string $key, mixed $value, string $type = 'string'): void
    {
        $serialized = $type === 'json' ? (string)json_encode($value) : (string)$value;
        $exists = \WHMCS\Database\Capsule::table('mytheme_settings')
            ->where('setting', $key)->exists();

        $row = [
            'setting'    => $key,
            'value'      => $serialized,
            'value_type' => $type,
            'updated_at' => date('Y-m-d H:i:s'),
        ];

        if ($exists) {
            \WHMCS\Database\Capsule::table('mytheme_settings')
                ->where('setting', $key)
                ->update($row);
        } else {
            $row['created_at'] = $row['updated_at'];
            \WHMCS\Database\Capsule::table('mytheme_settings')->insert($row);
        }

        self::$cache[$key] = $value;
    }

    /** @return array<string, mixed> */
    public static function all(): array
    {
        $rows = \WHMCS\Database\Capsule::table('mytheme_settings')
            ->get(['setting', 'value', 'value_type']);
        $out = [];
        foreach ($rows as $row) {
            $out[$row->setting] = self::cast($row->value, $row->value_type ?? 'string');
        }
        return $out;
    }

    private static function cast(mixed $raw, string $type): mixed
    {
        return match ($type) {
            'int'   => (int)$raw,
            'bool'  => $raw === '1' || $raw === 'true',
            'json'  => self::tryJsonDecode((string)$raw),
            default => (string)$raw,
        };
    }

    private static function tryJsonDecode(string $raw): mixed
    {
        $decoded = json_decode($raw, associative: true);
        return json_last_error() === JSON_ERROR_NONE ? $decoded : null;
    }
}
