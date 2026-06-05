<?php
declare(strict_types=1);

namespace MyTheme\Helpers;

use MyTheme\Models\Settings;

/**
 * Locale / language list helpers.
 *
 * Centralises two concerns:
 *   1. Discover what language files are installed in WHMCS root /lang/.
 *   2. Resolve the *effective* list of language codes to show clients,
 *      respecting the admin's "Custom Language List" toggle + curated codes.
 *
 * Used by SettingsController (admin form) and Hooks (front-of-house Smarty
 * injection) so the discovery + filter logic stays in one place.
 */
final class LocaleHelper
{
    /** Setting key for the admin-curated locale list (JSON array). */
    public const LIST_KEY = 'custom_language_codes';

    /** Setting key for the toggle that enables the curated list. */
    public const TOGGLE_KEY = 'custom_language_list';

    /**
     * Lowercased language codes (e.g. "english", "french") for every .php
     * file under <whmcs_root>/lang/. Sorted alphabetically.
     *
     * @return list<string>
     */
    public static function detectInstalled(): array
    {
        // Cope with both production (ROOTDIR defined) and CLI/test contexts
        // (fallback walks up from src/Helpers/ to addon root, then assumes
        // the addon lives at <root>/modules/addons/MyTheme).
        $root = defined('ROOTDIR') ? ROOTDIR : dirname(__DIR__, 5);
        $files = glob($root . DIRECTORY_SEPARATOR . 'lang' . DIRECTORY_SEPARATOR . '*.php') ?: [];
        $codes = [];
        foreach ($files as $file) {
            $name = pathinfo($file, PATHINFO_FILENAME);
            if ($name === '' || $name[0] === '.') {
                continue;
            }
            $codes[] = strtolower($name);
        }
        $codes = array_values(array_unique($codes));
        sort($codes);
        return $codes;
    }

    /**
     * The list of language codes the client-facing locale chooser should
     * show. Falls back to the installed list when the admin hasn't curated
     * one (or the curated list is empty/stale).
     *
     * @return list<string>
     */
    public static function effectiveList(): array
    {
        $installed = self::detectInstalled();
        $useCustom = (bool)Settings::getValue(self::TOGGLE_KEY, false);
        if (!$useCustom) {
            return $installed;
        }

        $raw = Settings::getValue(self::LIST_KEY, []);
        if (!is_array($raw) || $raw === []) {
            return $installed;
        }

        $installedSet = array_flip($installed);
        $out = [];
        foreach ($raw as $code) {
            if (!is_string($code)) {
                continue;
            }
            $code = strtolower($code);
            if (isset($installedSet[$code])) {
                $out[] = $code;
            }
        }
        // De-dupe while keeping the admin-chosen order.
        return array_values(array_unique($out));
    }

    /**
     * Map a WHMCS language name (the lowercased /lang/<name>.php filename, e.g.
     * "english", "portuguese-br") to a BCP-47 / ISO-639 hreflang code. Returns
     * null for names we don't recognise, so callers skip them rather than emit
     * a broken hreflang attribute.
     *
     * Covers WHMCS's shipped language set; extend as new files are added.
     */
    public static function codeFor(string $name): ?string
    {
        static $map = [
            'arabic' => 'ar', 'azerbaijani' => 'az', 'bulgarian' => 'bg',
            'bengali' => 'bn', 'bosnian' => 'bs', 'catalan' => 'ca',
            'chinese' => 'zh-cn', 'chinese-traditional' => 'zh-tw', 'croatian' => 'hr',
            'czech' => 'cs', 'danish' => 'da', 'dutch' => 'nl', 'english' => 'en',
            'estonian' => 'et', 'farsi' => 'fa', 'persian' => 'fa', 'finnish' => 'fi',
            'french' => 'fr', 'georgian' => 'ka', 'german' => 'de', 'greek' => 'el',
            'hebrew' => 'he', 'hindi' => 'hi', 'hungarian' => 'hu', 'indonesian' => 'id',
            'italian' => 'it', 'japanese' => 'ja', 'kazakh' => 'kk', 'khmer' => 'km',
            'korean' => 'ko', 'latvian' => 'lv', 'lithuanian' => 'lt', 'macedonian' => 'mk',
            'malay' => 'ms', 'mongolian' => 'mn', 'norwegian' => 'nb', 'polish' => 'pl',
            'portuguese' => 'pt', 'portuguese-br' => 'pt-br', 'brazilian-portuguese' => 'pt-br',
            'romanian' => 'ro', 'russian' => 'ru', 'serbian' => 'sr', 'slovak' => 'sk',
            'slovenian' => 'sl', 'spanish' => 'es', 'spanish-co' => 'es-co', 'swedish' => 'sv',
            'thai' => 'th', 'turkish' => 'tr', 'ukrainian' => 'uk', 'vietnamese' => 'vi',
            'albanian' => 'sq', 'armenian' => 'hy', 'belarusian' => 'be', 'icelandic' => 'is',
        ];
        return $map[strtolower(trim($name))] ?? null;
    }
}
