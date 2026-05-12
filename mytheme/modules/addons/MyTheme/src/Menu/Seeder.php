<?php
declare(strict_types=1);

namespace MyTheme\Menu;

use MyTheme\Models\Menu;
use MyTheme\Models\MenuItem;

/**
 * Idempotent preset seeding. Called from MyTheme::_activate() and on every
 * boot if the menus tables are empty (handles fresh installs that skipped the
 * activate step — e.g. an admin running migrations directly).
 *
 * Seeding rules:
 *   - If a menu with the same (name, location) exists AND has items, SKIP.
 *     The admin may have customised the items; never overwrite them.
 *   - If a menu with the same (name, location) exists but has NO items
 *     (e.g. they were accidentally wiped by an earlier save bug), top up
 *     the items section from the preset definition. Menu-level fields
 *     (active, audience) are left as-is in this case.
 *   - If no menu with the (name, location) exists, create it fresh.
 *   - Items are inserted in tree order so parent_id can reference IDs that
 *     already exist.
 */
final class Seeder
{
    public function run(bool $force = false): int
    {
        $seeded = 0;
        foreach (Presets::all() as $preset) {
            $existing = $this->existingMenu($preset['name'], $preset['location']);
            if ($existing === null) {
                $this->seedOne($preset);
                $seeded++;
                continue;
            }
            // Menu exists. Re-seed items only if it's empty (recover from
            // a wipe) or if $force is set.
            $itemCount = $existing->items()->count();
            if ($force || $itemCount === 0) {
                $this->seedItems($existing->id, $preset['items'] ?? [], null);

                // For empty-menu recovery: also restore the preset's
                // intended active state. If the admin's "Save" bug
                // deactivated the menu when it wiped the items, this
                // brings the state back to factory defaults. If the
                // active state was already correct (e.g. admin truly
                // wanted it off), the preset's matching value applies.
                if ($itemCount === 0) {
                    $existing->active = !empty($preset['active']);
                    $existing->changed_by_user = false;
                    $existing->save();

                    // Enforce mutual exclusion just like saveAction does
                    if ($existing->active) {
                        Menu::where('location', $existing->location)
                            ->where('audience', $existing->audience)
                            ->where('id', '!=', $existing->id)
                            ->update(['active' => false]);
                    }
                }
                $seeded++;
            }
        }
        return $seeded;
    }

    private function existingMenu(string $name, string $location): ?Menu
    {
        return Menu::where('name', $name)->where('location', $location)->first();
    }

    /**
     * Hard-reset the two "WHMCS Defaults" preset menus to their preset
     * definitions — delete existing items and re-seed. Useful when the
     * default item list shipped in a code update and admins want it.
     * User-customised menus (the non-defaults ones) are untouched.
     */
    public function resetWhmcsDefaults(): int
    {
        $count = 0;
        foreach (Presets::all() as $preset) {
            if (!str_contains((string)$preset['name'], 'WHMCS Defaults')) {
                continue;
            }
            $existing = $this->existingMenu($preset['name'], $preset['location']);
            if ($existing === null) {
                $this->seedOne($preset);
                $count++;
                continue;
            }
            // Wipe items + re-seed from preset
            MenuItem::where('menu_id', $existing->id)->delete();
            $this->seedItems($existing->id, $preset['items'] ?? [], null);
            $count++;
        }
        return $count;
    }

    private function seedOne(array $preset): void
    {
        $menu = Menu::create([
            'name'            => $preset['name'],
            'location'        => $preset['location'],
            'audience'        => $preset['audience'],
            'active'          => !empty($preset['active']),
            'version'         => '1.0',
            'changed_by_user' => false,
        ]);

        $this->seedItems($menu->id, $preset['items'] ?? [], null);
    }

    private function seedItems(int $menuId, array $items, ?int $parentId): void
    {
        $position = 0;
        foreach ($items as $node) {
            $row = MenuItem::create([
                'menu_id'     => $menuId,
                'parent_id'   => $parentId,
                'position'    => $position++,
                'item_type'   => (string)$node['type'],
                'label_json'  => json_encode($node['label']  ?? ['whmcs' => '', 'custom' => []]),
                'config_json' => json_encode($node['config'] ?? new \stdClass()),
                'active'      => true,
            ]);

            if (!empty($node['children']) && is_array($node['children'])) {
                $this->seedItems($menuId, $node['children'], $row->id);
            }
        }
    }
}
