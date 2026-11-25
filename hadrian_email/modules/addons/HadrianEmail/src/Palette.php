<?php
declare(strict_types=1);

namespace HadrianEmail;

/**
 * The theme's colours, resolved to literal hex for both modes.
 *
 * The client area never needs this: core-theme.css resolves tokens in the
 * browser, with var() chains, color-mix() and relative hsl(). An email client
 * does none of that, so the same answer has to be worked out here.
 *
 * Three things the browser does that this repeats by hand:
 *   - stored-over-default: an override row beats core/config/colors.php
 *   - "follows": --color-link is derived from --color-accent unless the buyer
 *     set a link colour of their own (core-theme.css, the hsl(from ...) block)
 *   - alpha: translucent tokens are composited onto the surface they sit on,
 *     because rgba() backgrounds are not safe in Outlook
 */
final class Palette
{
    /** Email role => theme token. */
    public const TOKENS = [
        'bg'       => '--color-bg',
        'surface'  => '--color-surface',
        'surface2' => '--color-surface-secondary',
        'text'     => '--color-text-primary',
        'muted'    => '--color-text-secondary',
        'faint'    => '--color-text-tertiary',
        'accent'   => '--color-accent',
        'onAccent' => '--color-on-accent',
        'link'     => '--color-link',
        'border'   => '--color-border',
        'success'  => '--color-green-text',
        'warning'  => '--color-orange-text',
        'danger'   => '--color-red-text',
    ];

    /** Translucent washes, flattened onto the surface. */
    private const TINTS = [
        'accentTint'  => '--color-accent-light',
        'successTint' => '--color-green-bg',
        'warningTint' => '--color-orange-bg',
        'dangerTint'  => '--color-red-bg',
    ];

    /**
     * Mirrors core/config/colors.php. Only used when the active WHMCS template
     * is not a Hadrian template, so an email still has a sane palette.
     */
    private const FALLBACK = [
        '--color-bg'                => ['#fbfbfd', '#1c1c1e'],
        '--color-surface'           => ['#ffffff', '#2c2c2e'],
        '--color-surface-secondary' => ['#f5f5f7', '#3a3a3c'],
        '--color-text-primary'      => ['#1d1d1f', '#f5f5f7'],
        '--color-text-secondary'    => ['#636368', '#b8b8bd'],
        '--color-text-tertiary'     => ['#6e6e73', '#a6a6ab'],
        '--color-accent'            => ['#0071e3', '#2997ff'],
        '--color-on-accent'         => ['#ffffff', '#ffffff'],
        '--color-link'              => ['#0066cc', '#52abff'],
        '--color-border'            => ['#e8e8ed', '#3a3a3c'],
        '--color-green-text'        => ['#207b37', '#45d669'],
        '--color-orange-text'       => ['#9c5d00', '#ffab28'],
        '--color-red-text'          => ['#d20015', '#ff7a72'],
        '--color-accent-light'      => ['rgba(0,113,227,0.08)', 'rgba(41,151,255,0.12)'],
        '--color-green-bg'          => ['rgba(48,209,88,0.10)', 'rgba(48,209,88,0.16)'],
        '--color-orange-bg'         => ['rgba(255,159,10,0.10)', 'rgba(255,159,10,0.16)'],
        '--color-red-bg'            => ['rgba(255,59,48,0.10)', 'rgba(255,59,48,0.16)'],
    ];

    /**
     * @return array{light: array<string,string>, dark: array<string,string>}
     */
    public static function resolve(?string $templateSlug = null): array
    {
        $slug = $templateSlug ?? Bridge::templateSlug();
        $cfg  = Bridge::colorsConfig($slug);

        $active = trim((string)Bridge::setting($slug . '_active_style', 'default'));
        if ($active === '' || $active === 'dark') {
            $active = 'default';
        }

        // Same key order as Hadrian's own Hooks::buildColorsHead: the per-scope key first,
        // then the pre-refactor key, so an install that has not been migrated
        // gets the colours its client area is actually showing.
        $read = static function (array $keys) use ($slug): array {
            foreach ($keys as $k) {
                $v = Bridge::setting($slug . $k, null);
                if (is_array($v) && $v !== []) {
                    return $v;
                }
            }
            return [];
        };

        return self::compute(
            self::defaultsFrom($cfg),
            $read(['_colors_' . $active . '_light', '_colors_' . $active]),
            $read(['_colors_' . $active . '_dark', '_colors_dark'])
        );
    }

    /**
     * Pure: no database, no files. This is the part the static test drives.
     *
     * @param array<string, array{0:string,1:string}> $defaults  var => [light, dark]
     * @param array<string, mixed> $storedLight
     * @param array<string, mixed> $storedDark
     * @return array{light: array<string,string>, dark: array<string,string>}
     */
    public static function compute(array $defaults, array $storedLight, array $storedDark): array
    {
        $defaults = $defaults + self::FALLBACK;
        $out = [];
        foreach (['light' => [$storedLight, 0], 'dark' => [$storedDark, 1]] as $mode => [$stored, $i]) {
            $raw = static function (string $var) use ($stored, $defaults, $i): string {
                $v = $stored[$var] ?? null;
                if (is_string($v) && trim($v) !== '') {
                    return trim($v);
                }
                return (string)($defaults[$var][$i] ?? self::FALLBACK[$var][$i] ?? '');
            };
            $fallback = static fn(string $var): string => self::FALLBACK[$var][$i] ?? '#000000';

            // Opaque bases first: everything translucent is flattened onto them.
            $bg      = self::toHex($raw('--color-bg'), null) ?? $fallback('--color-bg');
            $surface = self::toHex($raw('--color-surface'), $bg) ?? $fallback('--color-surface');

            $p = ['bg' => $bg, 'surface' => $surface];
            foreach (self::TOKENS as $role => $var) {
                if (isset($p[$role])) {
                    continue;
                }
                $p[$role] = self::toHex($raw($var), $surface)
                    ?? self::toHex($fallback($var), $surface)
                    ?? '#000000';
            }

            // Link follows the accent unless the buyer chose a link colour.
            $hasLink   = is_string($stored['--color-link'] ?? null) && trim((string)$stored['--color-link']) !== '';
            $hasAccent = is_string($stored['--color-accent'] ?? null) && trim((string)$stored['--color-accent']) !== '';
            if (!$hasLink && $hasAccent) {
                $p['link'] = $mode === 'light' ? self::shiftLightness($p['accent'], -4.51) : $p['accent'];
            }

            foreach (self::TINTS as $role => $var) {
                $p[$role] = self::toHex($raw($var), $surface)
                    ?? self::toHex($fallback($var), $surface)
                    ?? $p['surface2'];
            }
            // The tint follows the accent too: a green accent with the stock
            // blue wash behind it is the first thing a buyer would notice.
            if ($hasAccent && !isset($stored['--color-accent-light'])) {
                $p['accentTint'] = self::mix($p['accent'], $surface, $mode === 'light' ? 0.08 : 0.12);
            }
            $out[$mode] = $p;
        }
        return $out;
    }

    /**
     * @param array<string,mixed> $cfg  the decoded colors.php
     * @return array<string, array{0:string,1:string}>
     */
    public static function defaultsFrom(array $cfg): array
    {
        $out = [];
        foreach (($cfg['groups'] ?? []) as $tokens) {
            foreach ((array)$tokens as $t) {
                if (is_array($t) && isset($t['var'])) {
                    $out[(string)$t['var']] = [(string)($t['light'] ?? ''), (string)($t['dark'] ?? '')];
                }
            }
        }
        return $out;
    }

    // ------------------------------------------------------------ colour maths

    /**
     * Any supported notation to #rrggbb. A translucent colour is composited
     * onto $over; with no $over it is treated as opaque. Returns null for
     * notations this cannot read (hsl(), color-mix(), named colours), so the
     * caller can fall back instead of emitting a guess.
     */
    public static function toHex(string $value, ?string $over): ?string
    {
        $rgba = self::parse($value);
        if ($rgba === null) {
            return null;
        }
        [$r, $g, $b, $a] = $rgba;
        if ($a < 1 && $over !== null) {
            $base = self::parse($over);
            if ($base !== null) {
                $r = $r * $a + $base[0] * (1 - $a);
                $g = $g * $a + $base[1] * (1 - $a);
                $b = $b * $a + $base[2] * (1 - $a);
            }
        }
        return self::hex((int)round($r), (int)round($g), (int)round($b));
    }

    /** @return array{0:float,1:float,2:float,3:float}|null */
    private static function parse(string $value): ?array
    {
        $v = strtolower(trim($value));
        if (preg_match('/^#([0-9a-f]{3,8})$/', $v, $m)) {
            $h = $m[1];
            if (strlen($h) === 3 || strlen($h) === 4) {
                $h = implode('', array_map(static fn($c) => $c . $c, str_split($h)));
            }
            if (strlen($h) !== 6 && strlen($h) !== 8) {
                return null;
            }
            $a = strlen($h) === 8 ? hexdec(substr($h, 6, 2)) / 255 : 1.0;
            return [(float)hexdec(substr($h, 0, 2)), (float)hexdec(substr($h, 2, 2)), (float)hexdec(substr($h, 4, 2)), (float)$a];
        }
        if (preg_match('/^rgba?\(\s*([\d.]+)[\s,]+([\d.]+)[\s,]+([\d.]+)(?:\s*[,\/]\s*([\d.]+%?))?\s*\)$/', $v, $m)) {
            $a = 1.0;
            if (isset($m[4]) && $m[4] !== '') {
                $a = str_ends_with($m[4], '%') ? (float)$m[4] / 100 : (float)$m[4];
            }
            return [
                max(0.0, min(255.0, (float)$m[1])),
                max(0.0, min(255.0, (float)$m[2])),
                max(0.0, min(255.0, (float)$m[3])),
                max(0.0, min(1.0, $a)),
            ];
        }
        return null;
    }

    private static function hex(int $r, int $g, int $b): string
    {
        return sprintf('#%02x%02x%02x', max(0, min(255, $r)), max(0, min(255, $g)), max(0, min(255, $b)));
    }

    /** $amount of $a over $b, both #rrggbb. */
    public static function mix(string $a, string $b, float $amount): string
    {
        $pa = self::parse($a) ?? [0.0, 0.0, 0.0, 1.0];
        $pb = self::parse($b) ?? [255.0, 255.0, 255.0, 1.0];
        return self::hex(
            (int)round($pa[0] * $amount + $pb[0] * (1 - $amount)),
            (int)round($pa[1] * $amount + $pb[1] * (1 - $amount)),
            (int)round($pa[2] * $amount + $pb[2] * (1 - $amount))
        );
    }

    /** WCAG 2 contrast ratio between two #rrggbb colours, 1 to 21. */
    public static function contrast(string $a, string $b): float
    {
        $lum = static function (string $hex): float {
            $p = self::parse($hex) ?? [0.0, 0.0, 0.0, 1.0];
            $c = array_map(static function (float $v): float {
                $v /= 255;
                return $v <= 0.03928 ? $v / 12.92 : (($v + 0.055) / 1.055) ** 2.4;
            }, [$p[0], $p[1], $p[2]]);
            return 0.2126 * $c[0] + 0.7152 * $c[1] + 0.0722 * $c[2];
        };
        [$hi, $lo] = [max($lum($a), $lum($b)), min($lum($a), $lum($b))];
        return ($hi + 0.05) / ($lo + 0.05);
    }

    /**
     * $bg, nudged darker (for light text) or lighter (for dark text) until
     * $fg on it reaches $target contrast. Unchanged when it already does.
     * Used where text sits on a fill the buyer chose, such as the accent
     * band: a dark-mode accent is usually a lighter blue, and white on it
     * falls to about 3:1.
     */
    public static function readableUnder(string $bg, string $fg, float $target = 4.5): string
    {
        $fgIsLight = self::contrast($fg, '#000000') > self::contrast($fg, '#ffffff');
        $step      = $fgIsLight ? -3.0 : 3.0;
        for ($i = 0; $i < 25 && self::contrast($bg, $fg) < $target; $i++) {
            $bg = self::shiftLightness($bg, $step);
        }
        return $bg;
    }

    /** Move HSL lightness by $points (percentage points), as hsl(from c h s calc(l + n)) does. */
    public static function shiftLightness(string $hex, float $points): string
    {
        $p = self::parse($hex);
        if ($p === null) {
            return $hex;
        }
        [$r, $g, $b] = [$p[0] / 255, $p[1] / 255, $p[2] / 255];
        $max = max($r, $g, $b);
        $min = min($r, $g, $b);
        $l   = ($max + $min) / 2;
        $h   = 0.0;
        $s   = 0.0;
        if ($max !== $min) {
            $d = $max - $min;
            $s = $l > 0.5 ? $d / (2 - $max - $min) : $d / ($max + $min);
            $h = match (true) {
                $max === $r => (($g - $b) / $d) + ($g < $b ? 6 : 0),
                $max === $g => (($b - $r) / $d) + 2,
                default     => (($r - $g) / $d) + 4,
            };
            $h /= 6;
        }
        $l = max(0.0, min(1.0, $l + $points / 100));

        if ($s == 0.0) {
            $v = (int)round($l * 255);
            return self::hex($v, $v, $v);
        }
        $q = $l < 0.5 ? $l * (1 + $s) : $l + $s - $l * $s;
        $t = 2 * $l - $q;
        $chan = static function (float $x) use ($q, $t): float {
            $x = $x < 0 ? $x + 1 : ($x > 1 ? $x - 1 : $x);
            return match (true) {
                $x < 1 / 6 => $t + ($q - $t) * 6 * $x,
                $x < 1 / 2 => $q,
                $x < 2 / 3 => $t + ($q - $t) * (2 / 3 - $x) * 6,
                default    => $t,
            };
        };
        return self::hex(
            (int)round($chan($h + 1 / 3) * 255),
            (int)round($chan($h) * 255),
            (int)round($chan($h - 1 / 3) * 255)
        );
    }
}
