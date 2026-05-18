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
     * Convert every `custom_link` menu item whose `config.url` matches a known
     * WHMCS page URL → `whmcs_page` item with `config.page` set to the
     * corresponding templatefile name. Idempotent + safe to re-run:
     *
     *   - Only matches items with an exact URL match against WhmcsDefaults.
     *   - Items pointing to cart deeplinks, external scripts, or unknown
     *     URLs stay as custom_link.
     *   - Already-whmcs_page items are skipped (the query filters by type).
     *
     * Used at upgrade time (MyTheme_upgrade) and from the admin Tools tab.
     * Returns the number of items converted.
     */
    public function migrateCustomLinksToWhmcsPages(): int
    {
        // Build url → templatefile lookup. First-wins for URLs shared by
        // alias templatefiles (e.g. supportticketslist + supporttickets both
        // resolve to supporttickets.php).
        $urlToPage = [];
        foreach (WhmcsDefaults::all() as $page => $defaults) {
            $url = (string)($defaults['url'] ?? '');
            if ($url === '' || $url === '/') continue;
            if (!isset($urlToPage[$url])) {
                $urlToPage[$url] = $page;
            }
        }

        $migrated = 0;
        $items = MenuItem::where('item_type', 'custom_link')->get();
        foreach ($items as $item) {
            $config = $item->config();
            if (!is_array($config)) $config = [];
            $url = trim((string)($config['url'] ?? ''));
            if ($url === '' || !isset($urlToPage[$url])) continue;

            // Convert: swap url for page, retype.
            $page = $urlToPage[$url];
            unset($config['url']);
            $config['page'] = $page;

            $item->item_type   = 'whmcs_page';
            $item->config_json = json_encode($config, JSON_FORCE_OBJECT);
            $item->save();
            $migrated++;
        }
        return $migrated;
    }

    /**
     * Hard-reset the factory preset menus to their preset definitions —
     * delete existing items and re-seed. Useful when the default item
     * list shipped in a code update and admins want it.
     *
     * Eligibility is by preset name substring:
     *   - "WHMCS Defaults"        — Client/Guest "Main Menu — WHMCS Defaults"
     *                                presets that ship parallel to the
     *                                editable Client/Guest Main Menus.
     *   - "Footer Secondary Menu" — singular legal-links preset; no
     *                                parallel "— WHMCS Defaults" sibling,
     *                                so resetting in place is the only path.
     *
     * Editable user-curated menus (Client Main Menu, Guest Main Menu,
     * Footer Menu) stay untouched — admins customise them and we never
     * stomp on that.
     */
    public function resetWhmcsDefaults(): int
    {
        $resetable = ['WHMCS Defaults', 'Footer Secondary Menu'];
        $count = 0;
        foreach (Presets::all() as $preset) {
            $name = (string)$preset['name'];
            $matches = false;
            foreach ($resetable as $needle) {
                if (str_contains($name, $needle)) {
                    $matches = true;
                    break;
                }
            }
            if (!$matches) {
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
