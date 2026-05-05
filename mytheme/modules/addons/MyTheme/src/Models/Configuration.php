<?php
declare(strict_types=1);

namespace MyTheme\Models;

/**
 * Thin wrapper around tblconfiguration (WHMCS-native key/value store).
 * Used for: license state, active template selection, ActiveAddonModules.
 *
 * Theme-specific settings go in `mytheme_settings` — see Models\Settings.
 */
final class Configuration
{
    public static function getValue(string $key): ?string
    {
        $row = \WHMCS\Database\Capsule::table('tblconfiguration')
            ->where('setting', $key)
            ->first(['value']);
        return $row->value ?? null;
    }

    public static function setValue(string $key, string $value): void
    {
        $exists = \WHMCS\Database\Capsule::table('tblconfiguration')
            ->where('setting', $key)
            ->exists();

        if ($exists) {
            \WHMCS\Database\Capsule::table('tblconfiguration')
                ->where('setting', $key)
                ->update(['value' => $value]);
        } else {
            \WHMCS\Database\Capsule::table('tblconfiguration')
                ->insert(['setting' => $key, 'value' => $value]);
        }
    }

    public static function deleteValue(string $key): void
    {
        \WHMCS\Database\Capsule::table('tblconfiguration')
            ->where('setting', $key)
            ->delete();
    }
}
