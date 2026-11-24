<?php
declare(strict_types=1);

namespace Hadrian\Helpers;

use Hadrian\Models\Settings;

/**
 * Which layout is active, and for whom.
 *
 * A site picks its layouts one of two ways (the "mode"):
 *
 *   audience  one pick for guests and one for signed-in clients. This is how
 *             Hadrian has always worked and stays the default, so an install
 *             that never opens the switch renders exactly as before.
 *   area      one pick each for the website, the client area and the order
 *             process (see PageArea), whoever is looking.
 *
 * Settings keys, per template and per kind (main-menu, footer):
 *   <tpl>_layout_mode                       audience | area
 *   <tpl>_active_layout_<kind>_guest        audience mode
 *   <tpl>_active_layout_<kind>_client       audience mode
 *   <tpl>_active_layout_<kind>              legacy single pick (audience fallback)
 *   <tpl>_active_layout_<kind>_area_<area>  area mode
 *
 * The two sets of picks are stored side by side and never overwrite each
 * other, so switching mode and back loses nothing.
 *
 * The admin Layouts page (which card wears "Active") and the client render
 * (which layout is drawn) both resolve through this class. They used to carry
 * a copy each, with a comment asking that the two be kept in step.
 */
final class LayoutPointers
{
    public const MODE_AUDIENCE = 'audience';
    public const MODE_AREA     = 'area';

    public const AUDIENCES = ['guest', 'client'];

    /** The layout a kind falls back to when nothing valid is stored. */
    public const DEFAULT_BY_KIND = ['main-menu' => 'sidebar', 'footer' => 'extended'];

    public static function defaultFor(string $kind): string
    {
        return self::DEFAULT_BY_KIND[$kind] ?? 'default';
    }

    public static function mode(string $tpl): string
    {
        return (string)Settings::getValue($tpl . '_layout_mode', self::MODE_AUDIENCE) === self::MODE_AREA
            ? self::MODE_AREA
            : self::MODE_AUDIENCE;
    }

    /**
     * Switch how layouts are picked.
     *
     * The first switch to area mode starts each area from what most of its
     * visitors see today: the website and the order process take the guest
     * pick, the client area takes the client pick. A guest on the homepage or
     * in the cart and a client in the portal see no difference.
     *
     * What does change is that a pick stops depending on who is looking: a
     * guest on a client-area page (knowledgebase, login) now gets the client
     * area's pick, and a signed-in client on the website gets the website's.
     * Where the two audience picks were the same layout, nothing changes.
     *
     * @param array<string, list<string>> $validByKind kind => layouts that exist
     */
    public static function setMode(string $tpl, string $mode, array $validByKind): void
    {
        $mode = $mode === self::MODE_AREA ? self::MODE_AREA : self::MODE_AUDIENCE;
        if ($mode === self::MODE_AREA) {
            foreach ($validByKind as $kind => $valid) {
                foreach (array_keys(PageArea::LABELS) as $area) {
                    if ((string)Settings::getValue(self::areaKey($tpl, $kind, $area), '') !== '') {
                        continue;       // already picked on an earlier visit to this mode
                    }
                    $from = $area === PageArea::CLIENT ? 'client' : 'guest';
                    Settings::setValue(self::areaKey($tpl, $kind, $area), self::forAudience($tpl, $kind, $from, $valid));
                }
            }
        }
        Settings::setValue($tpl . '_layout_mode', $mode);
    }

    /**
     * The layout to draw for this request.
     *
     * @param list<string> $valid layouts of this kind that exist
     */
    public static function resolve(string $tpl, string $kind, string $audience, string $area, array $valid): string
    {
        return self::mode($tpl) === self::MODE_AREA
            ? self::forArea($tpl, $kind, $area, $valid)
            : self::forAudience($tpl, $kind, $audience, $valid);
    }

    /**
     * Audience pick: the per-audience key, then the legacy single key, then
     * the default for the kind.
     *
     * @param list<string> $valid
     */
    public static function forAudience(string $tpl, string $kind, string $audience, array $valid): string
    {
        $audience = $audience === 'client' ? 'client' : 'guest';
        $value    = (string)Settings::getValue($tpl . '_active_layout_' . $kind . '_' . $audience, '');
        if ($value === '') {
            $value = (string)Settings::getValue($tpl . '_active_layout_' . $kind, self::defaultFor($kind));
        }
        return self::orDefault($value, $kind, $valid);
    }

    /**
     * Area pick, then the default for the kind.
     *
     * @param list<string> $valid
     */
    public static function forArea(string $tpl, string $kind, string $area, array $valid): string
    {
        if (!PageArea::valid($area)) {
            $area = PageArea::CLIENT;
        }
        return self::orDefault((string)Settings::getValue(self::areaKey($tpl, $kind, $area), ''), $kind, $valid);
    }

    public static function setForAudience(string $tpl, string $kind, string $audience, string $layout): void
    {
        if (in_array($audience, self::AUDIENCES, true)) {
            Settings::setValue($tpl . '_active_layout_' . $kind . '_' . $audience, $layout);
        }
    }

    public static function setForArea(string $tpl, string $kind, string $area, string $layout): void
    {
        if (PageArea::valid($area)) {
            Settings::setValue(self::areaKey($tpl, $kind, $area), $layout);
        }
    }

    public static function areaKey(string $tpl, string $kind, string $area): string
    {
        return $tpl . '_active_layout_' . $kind . '_area_' . $area;
    }

    /**
     * A pick that names a layout which no longer exists (a deleted custom
     * folder, a renamed one) resolves to the default. The stored value is
     * left alone, so putting the folder back restores the pick.
     *
     * @param list<string> $valid
     */
    private static function orDefault(string $value, string $kind, array $valid): string
    {
        return in_array($value, $valid, true) ? $value : self::defaultFor($kind);
    }
}
