<?php
declare(strict_types=1);

namespace Hadrian\Helpers;

/**
 * The rules a colour token has to pass before it is stored or drawn.
 *
 * Written for the customizer, which previews and saves colours outside the
 * Styles pages. StylesController (save) and Service\Hooks (emit) each carry
 * an older private copy of the same two checks; the three must stay in step,
 * and tests/static/test-customize.php compares them.
 *
 * A value reaches a <style> block as written, so the accepted shapes are
 * deliberately narrow: hex, and comma-form rgb()/rgba()/hsl()/hsla().
 */
final class ColorTokens
{
    /**
     * Tokens in the colour schema that are not colours, with the one shape
     * each may take. Kept short and anchored: every entry is a value that
     * reaches a stylesheet without the colour check.
     */
    public const NON_COLOR_TOKENS = [
        '--sidebar-grad-angle' => '/^\d{1,3}deg$/',
    ];

    /** A hex (#rgb, #rgba, #rrggbb, #rrggbbaa) or rgb()/rgba()/hsl()/hsla() value. */
    public static function isColor(string $v): bool
    {
        $v = trim($v);
        return (bool)(
            preg_match('/^#([0-9a-fA-F]{3,4}|[0-9a-fA-F]{6}|[0-9a-fA-F]{8})$/', $v)
            || preg_match('/^rgba?\(\s*\d{1,3}\s*,\s*\d{1,3}\s*,\s*\d{1,3}\s*(,\s*(?:0|1|0?\.\d+)\s*)?\)$/i', $v)
            || preg_match('/^hsla?\(\s*\d{1,3}\s*,\s*\d{1,3}%\s*,\s*\d{1,3}%\s*(,\s*(?:0|1|0?\.\d+)\s*)?\)$/i', $v)
        );
    }

    /** True when $var is a declared non-colour token and $v fits its shape. */
    public static function isNonColorToken(string $var, string $v): bool
    {
        $pattern = self::NON_COLOR_TOKENS[$var] ?? null;
        return $pattern !== null && (bool)preg_match($pattern, trim($v));
    }

    /** May this value be stored for this token? */
    public static function accepts(string $var, string $v): bool
    {
        return self::isColor($v) || self::isNonColorToken($var, $v);
    }

    /** Loose equality for "was it changed?": case and whitespace do not count. */
    public static function norm(string $v): string
    {
        return strtolower((string)preg_replace('/\s+/', '', $v));
    }

    /**
     * The schema as one flat map.
     *
     * @param array<string,mixed> $cfg core/config/colors.php
     * @return array<string, array{var:string,label:string,group:string,light:string,dark:string}>
     */
    public static function schema(array $cfg): array
    {
        $out = [];
        foreach ((array)($cfg['groups'] ?? []) as $group => $tokens) {
            foreach ((array)$tokens as $t) {
                $var = (string)($t['var'] ?? '');
                if (!preg_match('/^--[a-z0-9-]+$/', $var)) {
                    continue;
                }
                $light = (string)($t['light'] ?? '');
                $out[$var] = [
                    'var'   => $var,
                    'label' => (string)($t['label'] ?? $var),
                    'group' => (string)$group,
                    'light' => $light,
                    'dark'  => (string)($t['dark'] ?? $light),
                ];
            }
        }
        return $out;
    }

    /**
     * Reduce a set of values to what is worth storing for one scope: tokens
     * the schema knows, with a value that passes, that differ from the
     * scope's default. An untouched token stores nothing, so the theme's own
     * CSS (and what it derives) keeps applying to it.
     *
     * This is the filter StylesController applies when the Colors panel is
     * saved and when a style's palette is seeded, so a row written through
     * here cannot be told from one written there.
     *
     * @param array<string,mixed> $values var => value
     * @param array<string,mixed> $cfg    core/config/colors.php
     * @return array<string,string>
     */
    public static function diff(array $values, array $cfg, string $scope): array
    {
        $scope = $scope === 'dark' ? 'dark' : 'light';
        $out   = [];
        foreach (self::schema($cfg) as $var => $token) {
            if (!isset($values[$var]) || !is_scalar($values[$var])) {
                continue;
            }
            $val = trim((string)$values[$var]);
            if ($val === '' || !self::accepts($var, $val)) {
                continue;
            }
            if (self::norm($val) === self::norm($token[$scope])) {
                continue;
            }
            $out[$var] = $val;
        }
        return $out;
    }

    /**
     * The <style> body for a pair of stored scopes, with the selectors
     * Service\Hooks::buildColorsHead uses (its comment explains each one).
     * The customizer rewrites the same block in the preview frame as colours
     * are edited, so the two must produce the same text.
     *
     * @param array<string,string> $light
     * @param array<string,string> $dark
     */
    public static function css(array $light, array $dark): string
    {
        $out = '';
        foreach ([self::SELECTOR_LIGHT => $light, self::SELECTOR_DARK => $dark] as $selector => $rows) {
            $decls = '';
            foreach ($rows as $var => $val) {
                $var = (string)$var;
                if (preg_match('/^--[a-z0-9-]+$/', $var) && self::accepts($var, (string)$val)) {
                    $decls .= $var . ':' . trim((string)$val) . ';';
                }
            }
            if ($decls !== '') {
                $out .= $selector . '{' . $decls . '}';
            }
        }
        return $out;
    }

    public const SELECTOR_LIGHT = 'html:not([data-theme="dark"]):not([data-palette])';
    public const SELECTOR_DARK  = 'html[data-theme="dark"]';
}
