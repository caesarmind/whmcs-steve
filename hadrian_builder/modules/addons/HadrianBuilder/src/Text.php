<?php
declare(strict_types=1);

namespace HadrianBuilder;

/**
 * Small text helpers shared by validation and rendering.
 *
 * A translatable value is a map keyed by WHMCS language name, with "_"
 * holding the default: {"_": "Get started", "french": "Commencer"}. That is
 * the same shape Hadrian Email Templates uses.
 */
final class Text
{
    /** The text for one language, falling back to the default. */
    public static function pick(mixed $value, string $lang): string
    {
        if (is_scalar($value)) {
            return (string)$value;
        }
        if (!is_array($value)) {
            return '';
        }
        $lang = strtolower($lang);
        if ($lang !== '' && $lang !== '_' && isset($value[$lang]) && is_scalar($value[$lang]) && (string)$value[$lang] !== '') {
            return (string)$value[$lang];
        }
        return is_scalar($value['_'] ?? null) ? (string)$value['_'] : '';
    }

    /** One line of plain text: control characters out, newlines to spaces, cut to length. */
    public static function line(string $s, int $max): string
    {
        $s = trim((string)preg_replace('/[\x00-\x08\x0B\x0C\x0E-\x1F]/', '', $s));
        $s = (string)preg_replace('/\s*[\r\n]+\s*/', ' ', $s);
        return self::cut($s, $max);
    }

    /** Plain text that keeps its line breaks. */
    public static function block(string $s, int $max): string
    {
        $s = (string)preg_replace('/[\x00-\x08\x0B\x0C\x0E-\x1F]/', '', $s);
        $s = str_replace(["\r\n", "\r"], "\n", $s);
        $s = (string)preg_replace('/\n{3,}/', "\n\n", $s);
        return self::cut(trim($s), $max);
    }

    public static function cut(string $s, int $max): string
    {
        return function_exists('mb_substr') ? mb_substr($s, 0, $max) : substr($s, 0, $max);
    }

    /**
     * A link a page may carry.
     *
     * Kept as typed: web, mail and phone links, an in-page anchor, a path from
     * the site root, or a path relative to WHMCS such as "cart.php?gid=2"
     * (the renderer puts the WHMCS address in front of that last kind).
     * Anything that could run script is refused.
     */
    public static function link(string $s): string
    {
        $s = self::line($s, 2000);
        if ($s === '' || preg_match('/^\s*(javascript|data|vbscript|file):/i', $s)) {
            return '';
        }
        if (preg_match('/^(https?:\/\/|mailto:|tel:|#)/i', $s)) {
            return $s;
        }
        if (str_starts_with($s, '/')) {
            return str_starts_with($s, '//') ? '' : $s;
        }
        if (preg_match('/^[a-z0-9.-]+\.[a-z]{2,}(\/|$)/i', $s) && !preg_match('/\.(php|html?)(\?|#|$)/i', $s)) {
            return 'https://' . $s;       // a bare domain: the admin meant a web address
        }
        return preg_match('/^[A-Za-z0-9][A-Za-z0-9_.\/?&=%#:+,;~-]*$/', $s) ? $s : '';
    }

    /** An image address: absolute http(s), or a path from the site root. */
    public static function image(string $s): string
    {
        $s = self::line($s, 2000);
        if ($s === '') {
            return '';
        }
        if (preg_match('/^https?:\/\//i', $s) || (str_starts_with($s, '/') && !str_starts_with($s, '//'))) {
            return $s;
        }
        return '';
    }

    /**
     * A page address under the site root: "hosting" or "about/team".
     * Returns '' when the input cannot be made into one.
     */
    public static function slug(string $s): string
    {
        $s = strtolower(trim($s));
        $s = trim((string)preg_replace('/[\s_]+/', '-', $s), '/');
        if ($s === '' || strlen($s) > 120) {
            return '';
        }
        $parts = explode('/', $s);
        if (count($parts) > 3) {
            return '';
        }
        foreach ($parts as $part) {
            if (!preg_match('/^[a-z0-9]+(?:-[a-z0-9]+)*$/', $part)) {
                return '';
            }
        }
        return $s;
    }

    /** An in-page anchor id: "pricing". '' when empty or not usable. */
    public static function anchor(string $s): string
    {
        $s = strtolower(trim($s, " \t\n\r#"));
        return preg_match('/^[a-z][a-z0-9-]{0,40}$/', $s) ? $s : '';
    }
}
