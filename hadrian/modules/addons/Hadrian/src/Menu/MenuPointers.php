<?php
declare(strict_types=1);

namespace Hadrian\Menu;

use Hadrian\Helpers\PageArea;
use Hadrian\Models\Menu;
use Hadrian\Models\Settings;

/**
 * Which menu a location shows in each area of the site.
 *
 * Out of the box a location (main, secondary, footer, footer-secondary) shows
 * the active menu for whoever is looking: one for guests, one for signed-in
 * clients. That stays the rule wherever nothing is picked here, so an install
 * that never opens this panel renders exactly as before.
 *
 * An admin can instead give an area (PageArea: website, client area, order
 * process) a menu of its own. A site with a top bar on its website and a
 * sidebar in the portal wants different links in the two, and a checkout often
 * wants fewer.
 *
 * A menu picked for an area is shown to everyone there, so its own audience
 * (client / guest) and its Active switch are not consulted. Those two decide
 * the by-visitor pick and nothing else. What still applies is each item's own
 * audience: a "Sign in" item marked for guests stays hidden from a client.
 *
 * Stored as one JSON setting, location => area => menu id:
 *
 *   menus_by_area   {"main": {"website": 12, "order": 15}, "footer": {...}}
 *
 * Menus are not per template (hadrian_menus has no template column), so
 * neither is this.
 */
final class MenuPointers
{
    public const LOCATIONS = ['main', 'secondary', 'footer', 'footer-secondary'];

    private const KEY = 'menus_by_area';

    /**
     * Every pick, with anything malformed dropped.
     *
     * @return array<string, array<string, int>> location => area => menu id
     */
    public static function all(): array
    {
        $stored = Settings::getValue(self::KEY, []);
        if (!is_array($stored)) {
            return [];
        }
        $out = [];
        foreach (self::LOCATIONS as $location) {
            foreach (array_keys(PageArea::LABELS) as $area) {
                $id = (int)($stored[$location][$area] ?? 0);
                if ($id > 0) {
                    $out[$location][$area] = $id;
                }
            }
        }
        return $out;
    }

    /** The menu picked for an area, or 0 when the area follows the visitor. */
    public static function forArea(string $location, string $area): int
    {
        return self::all()[$location][$area] ?? 0;
    }

    /**
     * Pick a menu for an area; 0 (or less) puts the area back on the
     * by-visitor rule. The caller checks that the menu exists and belongs to
     * the location: this class only refuses a location or area it does not
     * know.
     */
    public static function setForArea(string $location, string $area, int $menuId): void
    {
        if (!in_array($location, self::LOCATIONS, true) || !PageArea::valid($area)) {
            return;
        }
        $all = self::all();
        if ($menuId > 0) {
            $all[$location][$area] = $menuId;
        } else {
            unset($all[$location][$area]);
        }
        self::store($all);
    }

    /** Drop every pick of a menu, for when the menu is deleted. */
    public static function forget(int $menuId): void
    {
        $all     = self::all();
        $changed = false;
        foreach ($all as $location => $areas) {
            foreach ($areas as $area => $id) {
                if ($id === $menuId) {
                    unset($all[$location][$area]);
                    $changed = true;
                }
            }
        }
        if ($changed) {
            self::store($all);
        }
    }

    /**
     * The areas a menu is picked for, in the order the admin lists them.
     *
     * @return list<string>
     */
    public static function areasOf(int $menuId, string $location): array
    {
        $out = [];
        foreach (self::all()[$location] ?? [] as $area => $id) {
            if ($id === $menuId) {
                $out[] = $area;
            }
        }
        return $out;
    }

    /**
     * The menu to draw.
     *
     * Returns the menu and the audience its items should be filtered for. The
     * second value is null for the by-visitor pick, which leaves the renderer
     * to its long-standing rule (a menu filed under Client filters as a
     * client). For an area's own menu it is the real visitor, because that
     * menu is shown to guests and clients alike.
     *
     * A pick naming a menu that no longer exists, or one that has since moved
     * to another location, falls back to the by-visitor rule; the stored pick
     * is left alone.
     *
     * @param string|null $area null when the area is not known (no theme page
     *                          was resolved for this request)
     * @return array{0: ?Menu, 1: ?string}
     */
    public static function pick(string $location, ?string $area, string $audience): array
    {
        $id = $area !== null ? self::forArea($location, $area) : 0;
        if ($id > 0) {
            $menu = Menu::query()->where('id', $id)->where('location', $location)->first();
            if ($menu !== null) {
                return [$menu, $audience];
            }
        }
        return [Menu::pick($location, $audience), null];
    }

    /** @param array<string, array<string, int>> $all */
    private static function store(array $all): void
    {
        Settings::setValue(self::KEY, array_filter($all), 'json');
    }
}
