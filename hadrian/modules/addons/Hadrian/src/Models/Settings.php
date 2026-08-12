<?php
declare(strict_types=1);

namespace Hadrian\Models;

/**
 * Wrapper around the `hadrian_settings` table — ONE typed table for all
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
        $row = \WHMCS\Database\Capsule::table('hadrian_settings')
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
        $exists = \WHMCS\Database\Capsule::table('hadrian_settings')
            ->where('setting', $key)->exists();

        $row = [
            'setting'    => $key,
            'value'      => $serialized,
            'value_type' => $type,
            'updated_at' => date('Y-m-d H:i:s'),
        ];

        if ($exists) {
            \WHMCS\Database\Capsule::table('hadrian_settings')
                ->where('setting', $key)
                ->update($row);
        } else {
            $row['created_at'] = $row['updated_at'];
            \WHMCS\Database\Capsule::table('hadrian_settings')->insert($row);
        }

        self::$cache[$key] = $value;
    }

    /**
     * Remove a setting entirely, so the next read falls through to its default.
     *
     * Distinct from setValue($key, null) or setValue($key, [], 'json'), and the
     * difference is load-bearing: several call sites treat ROW EXISTENCE as the
     * sentinel rather than the value. StylesController::hasStoredColors is the
     * one that matters -- an empty row means "the buyer cleared every token",
     * which must survive re-seeding, while NO row means "never seeded", which is
     * what lets a preset write its palette. Only a real delete can say the
     * second thing.
     */
    public static function deleteValue(string $key): void
    {
        \WHMCS\Database\Capsule::table('hadrian_settings')
            ->where('setting', $key)
            ->delete();
        unset(self::$cache[$key]);
    }

    /** @return array<string, mixed> */
    public static function all(): array
    {
        $rows = \WHMCS\Database\Capsule::table('hadrian_settings')
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
