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
 *   - If a menu with the same name + location already exists, SKIP. Never
 *     overwrite a user's customisation.
 *   - Items are inserted in tree order so parent_id can reference IDs that
 *     already exist.
 */
final class Seeder
{
    public function run(bool $force = false): int
    {
        $seeded = 0;
        foreach (Presets::all() as $preset) {
            if (!$force && $this->presetExists($preset['name'], $preset['location'])) {
                continue;
            }
            $this->seedOne($preset);
            $seeded++;
        }
        return $seeded;
    }

    private function presetExists(string $name, string $location): bool
    {
        return Menu::where('name', $name)->where('location', $location)->exists();
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
