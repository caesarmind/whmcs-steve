<?php
declare(strict_types=1);

namespace MyTheme\Helpers;

/**
 * Parses templates/<slug>/theme.json — replaces filesystem-scan discovery.
 *
 * theme.json shape:
 *   {
 *     "name": "mytheme",
 *     "version": "1.0.0",
 *     "displayName": "MyTheme",
 *     "provides": {
 *       "styles":     ["default", "dark"],
 *       "layouts":    { "main-menu": ["top", "sidebar"], "footer": ["default"] },
 *       "pages":      ["clientareahome", ...],
 *       "extensions": [],
 *       "widgets":    []
 *     },
 *     "requires": { "whmcs": ">=9.0", "php": ">=8.3", "ioncube": true }
 *   }
 */
final class ThemeManifest
{
    /** @var array<string, array> */
    private static array $cache = [];

    public static function load(string $path): array
    {
        if (isset(self::$cache[$path])) {
            return self::$cache[$path];
        }

        if (!file_exists($path)) {
            throw new \RuntimeException("theme.json not found at {$path}");
        }

        $raw  = (string)file_get_contents($path);
        $data = json_decode($raw, associative: true);
        if (!is_array($data)) {
            throw new \RuntimeException("theme.json at {$path} is not valid JSON: " . json_last_error_msg());
        }

        // Normalize defaults — every key the engine reads must exist
        $data['provides'] = array_merge(
            [
                'styles'     => [],
                'layouts'    => ['main-menu' => [], 'footer' => []],
                'pages'      => [],
                'extensions' => [],
                'widgets'    => [],
            ],
            $data['provides'] ?? []
        );

        return self::$cache[$path] = $data;
    }

    /** Loads core/<kind>/<name>/<file>.php — returns array, [] when missing. */
    public static function loadVariantMeta(string $path): array
    {
        if (!file_exists($path)) {
            return [];
        }
        $data = require $path;
        return is_array($data) ? $data : [];
    }
}
