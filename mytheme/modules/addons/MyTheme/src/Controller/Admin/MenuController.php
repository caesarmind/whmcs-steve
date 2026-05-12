<?php
declare(strict_types=1);

namespace MyTheme\Controller\Admin;

use MyTheme\Controller\AbstractController;
use MyTheme\Menu\ItemTypes;
use MyTheme\Menu\Seeder;
use MyTheme\Models\Menu;
use MyTheme\Models\MenuItem;

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

        return $this->view('menu/index', [
            'menus' => $menus,
            'tab'   => $tab,
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
            'menu'      => $menu,
            'tree'      => $tree,
            'itemTypes' => ItemTypes::all(),
            'flash'     => $_GET['flash'] ?? '',
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
        $menu->active   = !empty($_POST['active']);
        $menu->changed_by_user = true;
        $menu->save();

        // Items — POSTed as a JSON-encoded flat list with parent_id+position.
        // This is simpler than Lagom's nested-array reconstruction.
        $payload = json_decode((string)($_POST['items_json'] ?? '[]'), true);
        if (!is_array($payload)) {
            $payload = [];
        }
        $this->persistItems($menu->id, $payload);

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
     * Rewrites the menu's items to match $payload — a flat list of:
     *   ['id'?, 'parent_id'?, 'item_type', 'label', 'config', 'active']
     * Existing items with matching ids are updated; new ids ("new_X") are
     * created; items present in DB but absent from payload are deleted.
     */
    private function persistItems(int $menuId, array $payload): void
    {
        $existingIds = MenuItem::where('menu_id', $menuId)->pluck('id')->all();
        $keepIds     = [];
        $idMap       = []; // payload-local id → DB id (for parent resolution on new items)

        // Two-pass: first create/update without parent (to mint DB ids),
        // then set parent_id once all ids are known.
        $byKey = [];
        foreach ($payload as $i => $row) {
            $key      = (string)($row['id'] ?? ('new_' . $i));
            $type     = (string)($row['item_type'] ?? '');
            if (!ItemTypes::exists($type)) {
                continue;
            }
            $label    = is_array($row['label']  ?? null) ? $row['label']  : ['whmcs' => '', 'custom' => []];
            $config   = is_array($row['config'] ?? null) ? $row['config'] : [];
            $position = (int)($row['position'] ?? $i);
            $active   = !empty($row['active'] ?? true);

            $dbId = is_numeric($key) ? (int)$key : null;
            $item = $dbId !== null ? MenuItem::find($dbId) : null;

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
            } else {
                $item->position    = $position;
                $item->item_type   = $type;
                $item->label_json  = json_encode($label);
                $item->config_json = json_encode($config);
                $item->active      = $active;
                $item->save();
            }
            $keepIds[]    = $item->id;
            $idMap[$key]  = $item->id;
            $byKey[$key]  = ['item' => $item, 'parent_key' => $row['parent_id'] ?? null];
        }

        // Second pass — wire parent_id now that every node has a DB id
        foreach ($byKey as $entry) {
            $parentKey = $entry['parent_key'];
            if ($parentKey === null || $parentKey === '' || $parentKey === 0) {
                $entry['item']->parent_id = null;
            } else {
                $resolved = $idMap[(string)$parentKey] ?? null;
                $entry['item']->parent_id = $resolved;
            }
            $entry['item']->save();
        }

        // Sweep — anything in DB but not in payload gets dropped
        $toDelete = array_diff($existingIds, $keepIds);
        if (!empty($toDelete)) {
            MenuItem::whereIn('id', $toDelete)->delete();
        }
    }
}
