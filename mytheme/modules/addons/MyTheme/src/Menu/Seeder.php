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
            // wipe) or if $force is set.
            $itemCount = $existing->items()->count();
            if ($force || $itemCount === 0) {
                $this->seedItems($existing->id, $preset['items'] ?? [], null);
                $seeded++;
            }
        }
        return $seeded;
    }

    private function existingMenu(string $name, string $location): ?Menu
    {
        return Menu::where('name', $name)->where('location', $location)->first();
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
