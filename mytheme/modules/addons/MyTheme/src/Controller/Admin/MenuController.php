<?php
declare(strict_types=1);

namespace MyTheme\Controller\Admin;

use MyTheme\Controller\AbstractController;
use MyTheme\Database\Migrator;
use MyTheme\Menu\ItemTypes;
use MyTheme\Menu\Seeder;
use MyTheme\Models\Menu;
use MyTheme\Models\MenuItem;
use WHMCS\Database\Capsule;

/**
 * Admin: list, edit, save, delete menus + items.
 *
 * Routing — WHMCS calls _output($vars) which calls MainController which
 * dispatches based on ?action=. Sub-actions on this controller come in
 * via ?action=menu&sub=... (sub is read from $_GET['sub']):
 *
 *   index   → list of menus (filtered by ?tab=main|secondary|footer)
 *   edit    → editor for one menu (?id=N)
 *   save    → POST handler that rewrites the menu and its items
 *   delete  → DELETE menu (?id=N&confirm=1)
 *   seed    → re-run preset seeder (admin override)
 */
final class MenuController extends AbstractController
{
    public function __construct(array $params = [])
    {
        parent::__construct($params);
        $this->ensureMenuTables();
    }

    /**
     * Self-heal: if the menu tables don't exist (because the admin upgraded
     * MyTheme without going through _upgrade, which WHMCS doesn't reliably
     * fire on file-replace deploys), run migrations + seeder now. Idempotent.
     */
    private function ensureMenuTables(): void
    {
        try {
            if (Capsule::schema()->hasTable('mytheme_menus')) {
                return;
            }
            // Addon root = three dirs up from this file (src/Controller/Admin → addon root)
            $addonRoot = dirname(__DIR__, 3);
            (new Migrator($addonRoot))->migrate();
            (new Seeder())->run();
        } catch (\Throwable $e) {
            // Don't blow up the admin page if self-heal fails — let the
            // subsequent action() surface a meaningful error.
            error_log('MyTheme menu self-heal failed: ' . $e->getMessage());
        }
    }

    public function indexAction(): string
    {
        $tab = (string)($_GET['tab'] ?? 'main');
        if (!in_array($tab, ['main', 'secondary', 'footer'], true)) {
            $tab = 'main';
        }

        // Self-heal: if the tables exist but no presets are seeded, seed now.
        if (Menu::query()->count() === 0) {
            (new Seeder())->run();
        }

        $menus = Menu::where('location', $tab)
            ->orderBy('audience')
            ->orderBy('id')
            ->get()
            ->map(fn (Menu $m) => [
                'id'       => $m->id,
                'name'     => $m->name,
                'audience' => $m->audience,
                'active'   => (bool)$m->active,
                'version'  => $m->version,
                'changed'  => (bool)$m->changed_by_user,
                'item_count' => $m->items()->count(),
            ])
            ->all();

        // Diagnostic: what *would* render right now for each audience? Surfaces
        // empty-menu / no-active-menu states so the admin can spot why the
        // frontend looks wrong without having to log out + log in.
        $diag = [];
        foreach (['client', 'guest'] as $aud) {
            $picked = Menu::pick($tab, $aud);
            $diag[$aud] = [
                'picked_id'      => $picked->id ?? null,
                'picked_name'    => $picked->name ?? null,
                'picked_items'   => $picked ? $picked->topLevelItems()->count() : 0,
            ];
        }

        return $this->view('menu/index', [
            'menus'    => $menus,
            'tab'      => $tab,
            'diag'     => $diag,
            'flashMsg' => $_GET['flash'] ?? '',
        ]);
    }

    public function editAction(): string
    {
        $id = (int)($_GET['id'] ?? 0);
        $menu = Menu::find($id);
        if ($menu === null) {
            return $this->view('menu/error', ['error' => 'Menu not found.']);
        }

        // Flat-list view of all items, suitable for the drag-drop renderer.
        // Each row's "indent" is its depth — computed from parent traversal.
        $allItems = $menu->items()->orderBy('parent_id')->orderBy('position')->get()->keyBy('id');
        $tree     = $this->buildTree($allItems);

        return $this->view('menu/edit', [
            'menu'         => $menu,
            'tree'         => $tree,
            'itemTypes'    => ItemTypes::all(),
            'icons'        => \MyTheme\Menu\Icons::pickerList(),
            'iconsJson'    => json_encode(\MyTheme\Menu\Icons::all()),
            'flash'        => $_GET['flash'] ?? '',
        ]);
    }

    public function saveAction(): string
    {
        $id = (int)($_POST['id'] ?? 0);
        $menu = Menu::find($id);
        if ($menu === null) {
            return $this->view('menu/error', ['error' => 'Menu not found.']);
        }

        // Top-level menu fields
        $menu->name     = trim((string)($_POST['name'] ?? $menu->name));
        $menu->audience = (string)($_POST['audience'] ?? $menu->audience);
        $newActive      = !empty($_POST['active']);

        // Mutual exclusion (Lagom-equivalent): only one menu can be active
        // per (location, audience). Activating this one deactivates any
        // peers — admin doesn't have to remember to flip the old one off.
        if ($newActive && (!$menu->active || $menu->audience !== ($_POST['audience'] ?? $menu->audience))) {
            Menu::where('location', $menu->location)
                ->where('audience', $menu->audience)
                ->where('id', '!=', $menu->id)
                ->update(['active' => false]);
        }

        $menu->active = $newActive;
        $menu->changed_by_user = true;
        $menu->save();

        // Items — read from EITHER form-array fields (items[N][...]) OR the
        // legacy JSON hidden input. Form-array is preferred because the
        // browser serializes it natively — no JS required, no encoding/size
        // pitfalls. JSON path stays as a fallback so we don't regress while
        // the JS migration lands.
        $raw    = (string)($_POST['items_json'] ?? '[]');
        $delRaw = (string)($_POST['deleted_ids_json'] ?? '[]');

        $arrayItems = is_array($_POST['items'] ?? null) ? $_POST['items'] : null;
        if ($arrayItems !== null) {
            $payload = array_values($arrayItems); // PHP form-array → indexed
        } else {
            $payload = json_decode($raw, true);
            if (!is_array($payload)) $payload = [];
        }

        $deleted = is_array($_POST['deleted_ids'] ?? null)
            ? array_values($_POST['deleted_ids'])
            : json_decode($delRaw, true);
        if (!is_array($deleted)) $deleted = [];

        // Normalize form-array rows into the shape persistItems expects.
        // Form-array path sends label_json/config_json as strings + active
        // as "0"/"1" string. JSON path sends them as decoded structures.
        // After this loop the row is uniform regardless of source.
        foreach ($payload as $i => &$row) {
            if (!is_array($row)) continue;
            if (isset($row['label_json']) && !isset($row['label'])) {
                $d = json_decode((string)$row['label_json'], true);
                $row['label'] = is_array($d) ? $d : ['whmcs' => '', 'custom' => []];
            }
            if (isset($row['config_json']) && !isset($row['config'])) {
                $d = json_decode((string)$row['config_json'], true);
                $row['config'] = is_array($d) ? $d : [];
            }
            // Explicit string check — !empty('0') is true in PHP which would
            // flip a deactivated item back to active.
            if (isset($row['active'])) {
                $row['active'] = ($row['active'] === '1' || $row['active'] === 1 || $row['active'] === true);
            }
            // Empty-string parent_id (form-array top-level) → null sentinel
            if (isset($row['parent_id']) && $row['parent_id'] === '') {
                $row['parent_id'] = null;
            }
            // Empty-string id (form-array new item) → null sentinel
            if (isset($row['id']) && $row['id'] === '') {
                $row['id'] = null;
            }
        }
        unset($row);

        // Diagnostic: log the POST shape so we can prove what arrived.
        error_log(sprintf(
            '[MyTheme saveAction] menu_id=%d source=%s items_count=%d post_keys=%s items_json_len=%d',
            $menu->id,
            $arrayItems !== null ? 'form-array' : 'json',
            count($payload),
            implode(',', array_keys($_POST)),
            strlen($raw)
        ));

        // SAFETY: if the JS hadn't run (e.g. tree wasn't ingested) and we'd
        // somehow get an empty payload with no explicit deletions while the
        // DB still has items, ignore the items section entirely. The admin's
        // settings (name/audience/active) still save.
        $existingCount = MenuItem::where('menu_id', $menu->id)->count();
        if (empty($payload) && empty($deleted) && $existingCount > 0) {
            error_log('MyTheme menu save: skipping items section because both '
                . 'items_json and deleted_ids_json were empty. menu_id=' . $menu->id
                . ' raw=' . substr($raw, 0, 200));
            $this->redirect('?module=MyTheme&action=menu&sub=edit&id='
                . $menu->id . '&flash=settings-only');
        }

        $this->persistItems($menu->id, $payload, array_map('intval', $deleted));

        $this->redirect('?module=MyTheme&action=menu&sub=edit&id=' . $menu->id . '&flash=saved');
    }

    public function deleteAction(): string
    {
        $id = (int)($_GET['id'] ?? 0);
        if (empty($_GET['confirm'])) {
            return $this->view('menu/error', ['error' => 'Add &confirm=1 to actually delete.']);
        }
        $menu = Menu::find($id);
        if ($menu === null) {
            return $this->view('menu/error', ['error' => 'Menu not found.']);
        }
        $location = $menu->location;
        $menu->delete(); // cascades items via FK
        $this->redirect('?module=MyTheme&action=menu&tab=' . urlencode($location));
    }

    public function seedAction(): string
    {
        $seeded = (new Seeder())->run();
        $this->redirect('?module=MyTheme&action=menu&flash=seeded-' . $seeded);
    }

    public function resetDefaultsAction(): string
    {
        $reset = (new Seeder())->resetWhmcsDefaults();
        $this->redirect('?module=MyTheme&action=menu&flash=reset-defaults-' . $reset);
    }

    /**
     * Diagnostic — dumps the live state of a menu as JSON. Open in a tab
     * after a save attempt to see exactly what's in the DB. Doesn't auth-
     * gate further than the rest of the addon (admin-only via WHMCS).
     */
    public function diagnoseAction(): string
    {
        $id = (int)($_GET['id'] ?? 0);
        $menu = Menu::find($id);
        header('Content-Type: application/json');
        if ($menu === null) {
            echo json_encode(['error' => 'menu not found', 'id' => $id]);
            exit;
        }
        $items = MenuItem::where('menu_id', $menu->id)
            ->orderBy('parent_id')->orderBy('position')->get()
            ->map(fn (MenuItem $i) => [
                'id' => $i->id, 'parent_id' => $i->parent_id, 'position' => $i->position,
                'item_type' => $i->item_type, 'active' => (bool)$i->active,
                'label' => $i->label(), 'config' => $i->config(),
            ])->all();
        echo json_encode([
            'menu' => [
                'id' => $menu->id, 'name' => $menu->name, 'location' => $menu->location,
                'audience' => $menu->audience, 'active' => (bool)$menu->active,
                'changed_by_user' => (bool)$menu->changed_by_user, 'version' => $menu->version,
            ],
            'items_count' => count($items),
            'items' => $items,
        ], JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES);
        exit;
    }

    /**
     * Given a keyed collection of MenuItems, build a nested array:
     *   [['item' => MenuItem, 'children' => [['item' => …, 'children' => […]]]]
     */
    private function buildTree($items, ?int $parentId = null): array
    {
        $out = [];
        foreach ($items as $item) {
            if ((int)$item->parent_id === (int)$parentId || ($item->parent_id === null && $parentId === null)) {
                $out[] = [
                    'item'     => $item,
                    'children' => $this->buildTree($items, (int)$item->id),
                ];
            }
        }
        return $out;
    }

    /**
     * Apply changes to a menu's items.
     *
     * $payload: flat list of items the admin wants to keep / create / update.
     *   Each entry: ['id'?, 'parent_id'?, 'item_type', 'label', 'config',
     *                'active', 'position']
     *
     *   - id present + numeric → update existing item (id matches DB row)
     *   - id missing/null      → create new item
     *   - parent_id is either:
     *       null                       → top-level
     *       a numeric DB id            → child of that DB item
     *       a "new_X" temp string      → child of a sibling new item (resolved
     *                                    after first pass mints DB ids)
     *
     * $deletedIds: explicit list of DB ids to delete. CRITICAL — this is the
     * ONLY way items get deleted. The old "anything absent from payload gets
     * swept" behaviour was removed because a JS bug could wipe an entire menu.
     */
    private function persistItems(int $menuId, array $payload, array $deletedIds = []): void
    {
        $log = ['menu_id' => $menuId, 'payload_count' => count($payload), 'deleted_ids' => $deletedIds, 'created' => [], 'updated' => [], 'skipped' => [], 'errors' => []];

        // Delete explicitly-marked items first.
        if (!empty($deletedIds)) {
            $allToDelete = $this->collectDescendants($menuId, $deletedIds);
            $log['cascade_delete'] = $allToDelete;
            MenuItem::where('menu_id', $menuId)
                ->whereIn('id', $allToDelete)
                ->delete();
        }

        $idMap = [];
        $byKey = [];

        // Pass 1 — create/update each row, capture the resulting DB id
        foreach ($payload as $i => $row) {
            $type = (string)($row['item_type'] ?? '');
            if (!ItemTypes::exists($type)) {
                $log['skipped'][] = ['idx' => $i, 'reason' => 'unknown_type', 'type' => $type, 'id' => $row['id'] ?? null];
                continue;
            }
            // PHP's isset() returns false for null, so id:null in payload
            // correctly falls through to the 'new_X' branch.
            $key      = (isset($row['id']) && is_numeric($row['id']))
                        ? (string)(int)$row['id']
                        : 'new_' . $i;
            $label    = is_array($row['label']  ?? null) ? $row['label']  : ['whmcs' => '', 'custom' => []];
            $config   = is_array($row['config'] ?? null) ? $row['config'] : [];
            $position = (int)($row['position'] ?? $i);
            $active   = array_key_exists('active', $row) ? !empty($row['active']) : true;

            $dbId = is_numeric($key) ? (int)$key : null;
            $item = $dbId !== null ? MenuItem::where('menu_id', $menuId)->where('id', $dbId)->first() : null;

            try {
                if ($item === null) {
                    $item = MenuItem::create([
                        'menu_id'     => $menuId,
                        'parent_id'   => null,
                        'position'    => $position,
                        'item_type'   => $type,
                        'label_json'  => json_encode($label),
                        'config_json' => json_encode($config),
                        'active'      => $active,
                    ]);
                    $log['created'][] = ['idx' => $i, 'new_id' => $item->id, 'type' => $type];
                } else {
                    $item->position    = $position;
                    $item->item_type   = $type;
                    $item->label_json  = json_encode($label);
                    $item->config_json = json_encode($config);
                    $item->active      = $active;
                    $item->save();
                    $log['updated'][] = ['idx' => $i, 'id' => $item->id, 'type' => $type];
                }
                $idMap[$key] = $item->id;
                $byKey[$key] = ['item' => $item, 'parent_key' => $row['parent_id'] ?? null];
            } catch (\Throwable $e) {
                $log['errors'][] = ['idx' => $i, 'pass' => 1, 'msg' => $e->getMessage()];
            }
        }

        // Pass 2 — wire parent_id now that every node has a DB id
        foreach ($byKey as $entry) {
            try {
                $parentKey = $entry['parent_key'];
                if ($parentKey === null || $parentKey === '' || $parentKey === 0) {
                    $entry['item']->parent_id = null;
                } else {
                    $resolved = $idMap[(string)$parentKey] ?? null;
                    $entry['item']->parent_id = $resolved;
                }
                $entry['item']->save();
            } catch (\Throwable $e) {
                $log['errors'][] = ['id' => $entry['item']->id ?? '?', 'pass' => 2, 'msg' => $e->getMessage()];
            }
        }

        // No implicit sweep — items absent from payload remain in DB.
        error_log('[MyTheme persistItems] ' . json_encode($log, JSON_UNESCAPED_SLASHES));
    }

    /**
     * Given a set of root ids, collect all descendant ids in the same menu.
     * Used to enforce parent→child cascade for explicit deletes.
     */
    private function collectDescendants(int $menuId, array $rootIds): array
    {
        $all = array_map('intval', $rootIds);
        $frontier = $all;
        while (!empty($frontier)) {
            $childIds = MenuItem::where('menu_id', $menuId)
                ->whereIn('parent_id', $frontier)
                ->pluck('id')->all();
            $childIds = array_diff($childIds, $all);
            if (empty($childIds)) break;
            $all = array_merge($all, $childIds);
            $frontier = $childIds;
        }
        return $all;
    }
}
