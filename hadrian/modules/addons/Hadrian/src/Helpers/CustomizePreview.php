<?php
declare(strict_types=1);

namespace Hadrian\Helpers;

/**
 * The customizer's unsaved state, and the gate that lets the client theme
 * draw it for the admin who is editing and for nobody else.
 *
 * The customizer (admin: Styles -> Open the customizer) shows the real site
 * in a frame beside its controls. What the admin picks there is not written
 * to the settings until they press Save. Until then it lives in their PHP
 * session, and the theme reads it from there for requests that carry the
 * session's preview token:
 *
 *   /index.php?hadrian_customize=<token>
 *
 * Two things must both hold for a request to be a preview (active()):
 *   - the session belongs to a signed-in admin, and
 *   - the URL carries the token stored in that same session.
 * A visitor cannot meet the first, and another tab of the same admin does
 * not meet the second, so the live site keeps rendering what is saved.
 *
 * State shape, as normalise() returns it:
 *
 *   style    string                       the scheme to draw
 *   theme    'light' | 'dark'
 *   colors   ['light' => [var => value], 'dark' => [...]]   diffs from the schema
 *   layouts  ['mode'     => 'audience' | 'area',
 *             'audience' => [kind => ['guest' => name, 'client' => name]],
 *             'area'     => [kind => ['website' => name, 'client' => name, 'order' => name]]]
 */
final class CustomizePreview
{
    public const PARAM = 'hadrian_customize';

    private const SESSION = 'hadrianCustomize';

    public const KINDS = ['main-menu', 'footer'];

    private static ?bool $active = null;

    // ------------------------------------------------------------ the gate

    /** Is this request a preview the theme should honour? */
    public static function active(): bool
    {
        if (self::$active !== null) {
            return self::$active;
        }
        $given  = $_GET[self::PARAM] ?? '';
        $stored = $_SESSION[self::SESSION]['token'] ?? '';
        return self::$active = is_string($given) && $given !== ''
            && is_string($stored) && $stored !== ''
            && (int)($_SESSION['adminid'] ?? 0) > 0
            && hash_equals($stored, $given)
            && is_array($_SESSION[self::SESSION]['state'] ?? null);
    }

    /** Forget the memoised answer. For tests, which change the request. */
    public static function reset(): void
    {
        self::$active = null;
    }

    // ----------------------------------------------- what the theme reads

    /** The scheme to draw, or null when this is not a preview. */
    public static function style(): ?string
    {
        $style = self::state()['style'] ?? null;
        return is_string($style) && $style !== '' ? $style : null;
    }

    /** 'light' or 'dark', or null when this is not a preview. */
    public static function theme(): ?string
    {
        $theme = self::state()['theme'] ?? null;
        return in_array($theme, ['light', 'dark'], true) ? $theme : null;
    }

    /**
     * The colour overrides to draw for a scope, or null when this is not a
     * preview. An empty array is an answer: the scheme at its schema defaults.
     *
     * @return array<string,string>|null
     */
    public static function colors(string $scope): ?array
    {
        $state = self::state();
        if ($state === []) {
            return null;
        }
        $rows = $state['colors'][$scope === 'dark' ? 'dark' : 'light'] ?? [];
        return is_array($rows) ? $rows : [];
    }

    /**
     * The layout to draw, or null when this is not a preview or the preview
     * names a layout that does not exist.
     *
     * @param list<string> $valid layouts of this kind that exist
     */
    public static function layout(string $kind, string $audience, string $area, array $valid): ?string
    {
        $layouts = self::state()['layouts'] ?? null;
        if (!is_array($layouts)) {
            return null;
        }
        $pick = ($layouts['mode'] ?? '') === LayoutPointers::MODE_AREA
            ? ($layouts['area'][$kind][PageArea::valid($area) ? $area : PageArea::CLIENT] ?? null)
            : ($layouts['audience'][$kind][$audience === 'client' ? 'client' : 'guest'] ?? null);
        return is_string($pick) && in_array($pick, $valid, true) ? $pick : null;
    }

    /** @return array<string,mixed> the state when this is a preview, [] otherwise */
    private static function state(): array
    {
        return self::active() ? (array)$_SESSION[self::SESSION]['state'] : [];
    }

    // ------------------------------------------------ what the admin writes

    /** This admin session's preview token, made on first use. */
    public static function token(): string
    {
        $token = $_SESSION[self::SESSION]['token'] ?? '';
        if (!is_string($token) || !preg_match('/^[a-f0-9]{32}$/', $token)) {
            $token = bin2hex(random_bytes(16));
            $_SESSION[self::SESSION] = ['token' => $token, 'state' => $_SESSION[self::SESSION]['state'] ?? null];
        }
        return $token;
    }

    /** @param array<string,mixed> $state a state normalise() returned */
    public static function put(array $state): void
    {
        $token = self::token();
        $_SESSION[self::SESSION] = ['token' => $token, 'state' => $state];
    }

    /**
     * Reduce whatever the browser sent to a state that is safe to draw and
     * to save: a scheme that exists, layouts that exist, colours the schema
     * knows with values that pass. Anything else falls back to $fallback,
     * the saved state.
     *
     * @param array<string,mixed> $raw
     * @param array{styles: list<string>, layouts: array<string, list<string>>, colors: array<string,mixed>} $known
     * @param array<string,mixed> $fallback a normalised state
     * @return array<string,mixed>
     */
    public static function normalise(array $raw, array $known, array $fallback): array
    {
        $style = is_string($raw['style'] ?? null) && in_array($raw['style'], $known['styles'], true)
            ? $raw['style']
            : (string)$fallback['style'];

        $theme = ($raw['theme'] ?? '') === 'dark' ? 'dark' : (($raw['theme'] ?? '') === 'light' ? 'light' : (string)$fallback['theme']);

        $colors = [];
        foreach (['light', 'dark'] as $scope) {
            $rows = $raw['colors'][$scope] ?? null;
            $colors[$scope] = is_array($rows)
                ? ColorTokens::diff($rows, $known['colors'], $scope)
                : (array)($fallback['colors'][$scope] ?? []);
        }

        $rawLayouts = is_array($raw['layouts'] ?? null) ? $raw['layouts'] : [];
        $layouts = [
            'mode' => in_array($rawLayouts['mode'] ?? null, [LayoutPointers::MODE_AUDIENCE, LayoutPointers::MODE_AREA], true)
                ? $rawLayouts['mode']
                : (string)$fallback['layouts']['mode'],
        ];
        $slots = ['audience' => LayoutPointers::AUDIENCES, 'area' => array_keys(PageArea::LABELS)];
        foreach ($slots as $by => $names) {
            foreach (self::KINDS as $kind) {
                foreach ($names as $slot) {
                    $pick = $rawLayouts[$by][$kind][$slot] ?? null;
                    $layouts[$by][$kind][$slot] = is_string($pick) && in_array($pick, $known['layouts'][$kind] ?? [], true)
                        ? $pick
                        : (string)$fallback['layouts'][$by][$kind][$slot];
                }
            }
        }

        return ['style' => $style, 'theme' => $theme, 'colors' => $colors, 'layouts' => $layouts];
    }

    // ------------------------------------------------------ inside the frame

    /**
     * Printed at the foot of a previewed page. It marks the document as a
     * preview and keeps the visitor inside it: a link or a GET form to the
     * same site carries the token along, so clicking through the framed site
     * keeps showing the unsaved state. A POST form is left alone; whatever it
     * leads to is the live site, and the customizer says so.
     */
    public static function footerScript(): string
    {
        if (!self::active()) {
            return '';
        }
        $param = json_encode(self::PARAM);
        $token = json_encode((string)$_SESSION[self::SESSION]['token']);
        return <<<HTML
<script id="hadrian-customize-frame">
(function () {
  var P = {$param}, T = {$token};
  document.documentElement.setAttribute('data-hadrian-preview', '1');
  function carry(href) {
    try {
      var u = new URL(href, location.href);
      if (u.origin !== location.origin || /\\/admin\\//.test(u.pathname)) return null;
      u.searchParams.set(P, T);
      return u.href;
    } catch (e) { return null; }
  }
  document.addEventListener('click', function (e) {
    var a = e.target && e.target.closest ? e.target.closest('a[href]') : null;
    if (!a || e.defaultPrevented) return;
    var raw = a.getAttribute('href') || '';
    if (raw === '' || raw.charAt(0) === '#' || /^(javascript|mailto|tel):/i.test(raw)) return;
    var next = carry(a.href);
    if (next) { a.href = next; a.removeAttribute('target'); }
  }, true);
  document.addEventListener('submit', function (e) {
    var f = e.target;
    if (!f || (f.method || 'get').toLowerCase() !== 'get' || f.querySelector('input[name="' + P + '"]')) return;
    if (!carry(f.action || location.href)) return;
    var i = document.createElement('input');
    i.type = 'hidden'; i.name = P; i.value = T;
    f.appendChild(i);
  }, true);
})();
</script>
HTML;
    }
}
