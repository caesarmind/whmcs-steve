<?php
declare(strict_types=1);

namespace Hadrian\Menu;

use Hadrian\Models\Menu;
use Hadrian\Models\MenuItem;

/**
 * Idempotent preset seeding. Called from Hadrian::_activate() and on every
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
            // a wipe) or if $force is set. When forcing, WIPE the existing
            // items first so we replace rather than append -- otherwise every
            // item duplicates on each force re-sync.
            $itemCount = $existing->items()->count();
            if ($force || $itemCount === 0) {
                if ($force) {
                    MenuItem::where('menu_id', $existing->id)->delete();
                }
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
     * corresponding templatefile name.
     *
     * WHAT IT WILL NOT TOUCH, and why. The governing rule is that a conversion
     * must never take away something the editor can no longer give back --
     * an item left as a custom_link still works, so declining is always the
     * cheaper mistake:
     *
     *   - No exact URL match against WhmcsDefaults. Cart deeplinks, external
     *     links and anything carrying an extra query param (Mass Payment's
     *     `&all=true`) stay put.
     *   - The target page is not in the picker. MenuPages::ELIGIBLE is a
     *     CURATED subset, not every WhmcsDefaults entry: of the 37 distinct
     *     convertible URLs, 13 resolve to a page with no tile -- every store/*
     *     one -- so a converted item could not be shown or re-pointed in the
     *     drawer. (Count them AFTER first-wins, not by listing unpickable page
     *     keys: clientarea.php?action=changepw is claimed by user-password,
     *     changepassword and changepw, and the pickable one wins.)
     *   - The item opens in a new tab. TreeRenderer applies config.target for
     *     any item type, but the "Open in new tab" checkbox lives in the
     *     custom_link-only section of the drawer (edit.tpl:372-378), so
     *     converting would leave a new-tab link with no control to turn it off.
     *   - Already-whmcs_page items (the query filters by type).
     *
     * config.url is KEPT, not deleted. The drawer tells the admin "Existing
     * label / icon / URL values are kept in case you switch back"
     * (edit.tpl:329); unsetting it made that false -- flipping the type back
     * gave an empty URL field that saved a dead link. Nothing reads config.url
     * on a whmcs_page item (TreeRenderer resolves from config.page), so
     * carrying it costs nothing and keeps the promise true.
     *
     * Genuinely idempotent: a second pass finds no custom_link items left that
     * pass the guards above.
     *
     * Called from MenuController::ensureMenuPagesMigration() (marker-gated,
     * once per install) and from ToolsController by POST. It is NO LONGER
     * called from Hadrian_upgrade -- see the note there.
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
            // '/' is excluded deliberately, not by oversight. It is the site
            // root, and a menu item pointing there means "home" in a way that
            // is not necessarily the `homepage` templatefile -- the shipped
            // presets themselves use customLink(..., '/') for exactly that.
            // Auto-claiming every '/' link for one page is a guess, and the
            // guess is not worth making when the link already works.
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

            $page = $urlToPage[$url];

            // The picker cannot offer this page, so the drawer could neither
            // display nor re-point the converted item. Same eligibility rule
            // the picker itself uses, rather than a second list to keep in sync.
            if (!MenuPages::isEligible($page)) continue;

            // Opens in a new tab. The behaviour survives the type flip; the
            // control that governs it does not.
            if (trim((string)($config['target'] ?? '')) !== '') continue;

            // Retype, and KEEP config.url -- see the docblock. Nothing reads it
            // on a whmcs_page, and it is what lets the admin switch the type
            // back and still have their URL, as the drawer promises.
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
