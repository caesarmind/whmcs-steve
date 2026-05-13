<?php
declare(strict_types=1);

namespace MyTheme\Controller\Admin;

use MyTheme\Controller\AbstractController;
use MyTheme\Database\Migrator;
use MyTheme\Helpers\AddonHelper;
use MyTheme\Menu\ItemTypes;
use MyTheme\Menu\Seeder;
use MyTheme\Models\Menu;
use MyTheme\Models\MenuItem;
use MyTheme\Template\PagesCache;
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

        // Predict whether a save with the current item count will exceed
        // PHP's max_input_vars limit. Each item submits 7 form-array fields
        // (id, item_type, parent_id, position, label_json, config_json,
        // active) plus the menu-level fields. Lagom uses a similar check.
        $itemCount        = $allItems->count();
        $estimatedVars    = ($itemCount * 7) + 10; // 10 for menu-level fields + safety margin
        $maxInputVars     = (int)(ini_get('max_input_vars') ?: 1000);
        $inputVarsWarning = ($estimatedVars > ($maxInputVars - 50));

        // Power the WHMCS-page picker drawer in the item editor. Grouped + sorted
        // by Pages-tab order so the menu builder mirrors the admin Pages layout.
        $pagesByGroup = [];
        $template = AddonHelper::getTemplate();
        if ($template !== null) {
            PagesCache::ensure($template); // self-heal on first use after activation
            foreach ($template->getAllPageMeta() as $meta) {
                $pagesByGroup[$meta['group']][] = $meta;
            }
            foreach ($pagesByGroup as &$bucket) {
                usort($bucket, fn ($a, $b) => strcmp($a['display_name'], $b['display_name']));
            }
            unset($bucket);
            $groupOrder = ['Public' => 1, 'Authentication' => 2, 'Client Area' => 3, 'Account' => 4, 'Billing' => 5, 'Support' => 6];
            uksort($pagesByGroup, function ($a, $b) use ($groupOrder) {
                $oa = $groupOrder[$a] ?? 99;
                $ob = $groupOrder[$b] ?? 99;
                return $oa === $ob ? strcmp($a, $b) : $oa <=> $ob;
            });
        }

        return $this->view('menu/edit', [
            'menu'             => $menu,
            'tree'             => $tree,
            'itemTypes'        => ItemTypes::all(),
            'icons'            => \MyTheme\Menu\Icons::pickerList(),
            'iconsJson'        => json_encode(\MyTheme\Menu\Icons::all()),
            'pagesByGroup'     => $pagesByGroup,
            'flash'            => $_GET['flash'] ?? '',
            'itemCount'        => $itemCount,
            'estimatedVars'    => $estimatedVars,
            'maxInputVars'     => $maxInputVars,
            'inputVarsWarning' => $inputVarsWarning,
        ]);
    }

    public function saveAction(): string
    {
        $id = (int)($_POST['id'] ?? 0);
        $menu = Menu::find($id);
        if ($menu === null) {
            return $this->view('menu/error', ['error' => 'Menu not found.']);
        }

        // LAGOM-STYLE GUARDRAIL — hard-fail the save if PHP's max_input_vars
        // is close to being exceeded. Without this guard, PHP silently
        // truncates the form-array mid-submit (drops trailing keys without
        // raising an error), and items lose their label / URL data on save.
        //
        // Lagom does this check at the very top of their saveAction. We
        // follow the same pattern: count terminal input vars across
        // $_REQUEST + $_COOKIE, refuse the save if we're within 100 of the
        // host limit, and tell the admin to raise `max_input_vars` in
        // php.ini. No half-saved data, no silent corruption — just a clear
        // "your host config needs raising" message.
        $maxInputVars  = (int)(ini_get('max_input_vars') ?: 1000);
        $terminalCount = $this->countTerminals([$_REQUEST, $_COOKIE]);
        if ($maxInputVars - 100 < $terminalCount) {
            error_log(sprintf(
                '[MyTheme saveAction] REFUSED save — max_input_vars too low. '
                . 'limit=%d, terminal_count=%d, menu_id=%d',
                $maxInputVars, $terminalCount, $menu->id
            ));
            $this->redirect(sprintf(
                '?module=MyTheme&action=menu&sub=edit&id=%d&flash=max-input-vars-exceeded&limit=%d&count=%d',
                $menu->id, $maxInputVars, $terminalCount
            ));
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

        // Items — read from form-array (items[N][...]). The legacy items_json
        // hidden input is only used if the form-array is completely absent
        // (JS-disabled scenario). With the max_input_vars guard above, we
        // know the form-array won't be truncated mid-submit.
        //
        // WHMCS 9 htmlspecialchars-encodes every POST value, including
        // items_json. Decode before json_decode for the fallback path too.
        $raw         = htmlspecialchars_decode((string)($_POST['items_json'] ?? '[]'), ENT_QUOTES);
        $arrayItems  = is_array($_POST['items'] ?? null) ? $_POST['items'] : null;
        $usedSource  = 'json';
        if ($arrayItems !== null) {
            $payload    = array_values($arrayItems);
            $usedSource = 'form-array';
        } else {
            $payload = json_decode($raw, true);
            if (!is_array($payload)) $payload = [];
        }


        // Normalize form-array rows into the shape persistItems expects.
        // Form-array path sends label_json/config_json as strings + active
        // as "0"/"1" string. JSON path sends them as decoded structures.
        // After this loop the row is uniform regardless of source.
        //
        // CRITICAL: WHMCS 9's admin request handler runs htmlspecialchars()
        // on all incoming POST values before user code sees them. So our
        // form-array JSON strings arrive as &quot;-encoded, and json_decode
        // returns null on those — the entire save then silently writes
        // empty labels/configs to the DB. Lagom hit the same wall and
        // decodes via htmlspecialchars_decode() before json_decode. Same
        // fix here for both label_json and config_json.
        foreach ($payload as $i => &$row) {
            if (!is_array($row)) continue;
            if (isset($row['label_json']) && !isset($row['label'])) {
                $jsonStr = htmlspecialchars_decode((string)$row['label_json'], ENT_QUOTES);
                $d = json_decode($jsonStr, true);
                $row['label'] = is_array($d) ? $d : ['whmcs' => '', 'custom' => []];
            }
            if (isset($row['config_json']) && !isset($row['config'])) {
                $jsonStr = htmlspecialchars_decode((string)$row['config_json'], ENT_QUOTES);
                $d = json_decode($jsonStr, true);
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
            '[MyTheme saveAction] menu_id=%d source=%s items_count=%d post_keys=%s items_json_len=%d max_input_vars=%s',
            $menu->id,
            $usedSource,
            count($payload),
            implode(',', array_keys($_POST)),
            strlen($raw),
            ini_get('max_input_vars') ?: 'unknown'
        ));
        // SAFETY: if the JS hadn't run (e.g. tree wasn't ingested) and we'd
        // get an empty payload while the DB still has items, REFUSE to wipe.
        // With delete-all-then-recreate, an empty payload would otherwise
        // nuke the entire menu. The admin's settings (name/audience/active)
        // still save above; only the items section is skipped.
        $existingCount = MenuItem::where('menu_id', $menu->id)->count();
        if (empty($payload) && $existingCount > 0) {
            error_log('MyTheme menu save: refused to wipe menu items because '
                . 'payload was empty. menu_id=' . $menu->id
                . ' raw=' . substr($raw, 0, 200));
            $this->redirect('?module=MyTheme&action=menu&sub=edit&id='
                . $menu->id . '&flash=empty-payload-rejected');
        }

        $this->persistItems($menu->id, $payload);

        $this->redirect('?module=MyTheme&action=menu&sub=edit&id=' . $menu->id . '&flash=saved');
    }

    /**
     * Recursively count terminal (non-array) values in a nested array.
     * Used to estimate the PHP input-var count against max_input_vars.
     * Matches Lagom's count_terminals implementation.
     */
    private function countTerminals(array $a): int
    {
        $count = 0;
        foreach ($a as $val) {
            if (is_array($val)) {
                $count += $this->countTerminals($val);
            } else {
                $count++;
            }
        }
        return $count;
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
     * Apply the payload as the complete new state of the menu's items.
     *
     * Lagom-style delete-all-then-recreate — every save is a full state
     * replacement. We previously used update-in-place, which required
     * tracking which items were edited, which were new, which were
     * deleted (via deletedIds), plus guard logic to refuse empty
     * overwrites. That accumulated complexity caused the "edit didn't
     * persist" bug (Home2 → Home), among others.
     *
     * With delete-all the only path is "create from payload" — IDs
     * change every save, but nothing in this codebase references items
     * by stable id (frontend uses mt-{id} purely as a CSS hook,
     * regenerated each render). The saveAction's "empty payload =
     * refuse to save items" check is the only safety net needed.
     *
     * $payload: flat list of items the admin wants the menu to contain.
     *   Each entry: ['id'?, 'parent_id'?, 'item_type', 'label', 'config',
     *                'active', 'position']
     *   - id present + numeric → key for parent_id resolution (DB id
     *                            from the previous save; the new row
     *                            will get a fresh auto-increment id)
     *   - id missing/null      → brand-new entry; key is 'new_X'
     *   - parent_id is null    → top-level
     *   - parent_id numeric    → was a child of that pre-save DB id;
     *                            we resolve to the matching new id
     *   - parent_id 'new_X'    → child of a sibling new item (resolved
     *                            after pass 1 mints fresh ids)
     */
    private function persistItems(int $menuId, array $payload): void
    {
        $log = [
            'menu_id'       => $menuId,
            'payload_count' => count($payload),
            'created'       => [],
            'skipped'       => [],
            'errors'        => [],
        ];

        // Delete all existing items for this menu. FK ON DELETE CASCADE
        // in the schema would handle descendants if they were in a
        // separate table — they're not (single mytheme_menu_items table),
        // so this WHERE menu_id wipes the entire menu's items in one go.
        MenuItem::where('menu_id', $menuId)->delete();

        $idMap = [];   // old key → new DB id (for parent_id resolution)
        $byKey = [];   // new-row reference keyed by old key

        // Pass 1 — create each item with parent_id=NULL initially.
        foreach ($payload as $i => $row) {
            $type = (string)($row['item_type'] ?? '');
            if (!ItemTypes::exists($type)) {
                $log['skipped'][] = ['idx' => $i, 'reason' => 'unknown_type', 'type' => $type];
                continue;
            }
            $key      = (isset($row['id']) && is_numeric($row['id']))
                        ? (string)(int)$row['id']
                        : 'new_' . $i;
            $label    = is_array($row['label']  ?? null) ? $row['label']  : ['whmcs' => '', 'custom' => []];
            $config   = is_array($row['config'] ?? null) ? $row['config'] : [];
            $position = (int)($row['position'] ?? $i);
            $active   = array_key_exists('active', $row) ? !empty($row['active']) : true;

            // Defensive default: a brand-new item with no meaningful
            // label gets a "New <type>" placeholder so admins see
            // something editable rather than an invisible row.
            if (!is_numeric($row['id'] ?? null) && !$this->isMeaningfulLabel($label)) {
                $typeLabel = ItemTypes::meta($type)['label'] ?? $type;
                $label = ['whmcs' => '', 'custom' => ['english' => 'New ' . strtolower($typeLabel)]];
            }

            try {
                $item = MenuItem::create([
                    'menu_id'     => $menuId,
                    'parent_id'   => null,
                    'position'    => $position,
                    'item_type'   => $type,
                    // JSON_FORCE_OBJECT ensures empty PHP arrays encode as
                    // "{}" (object) instead of "[]" (array). Otherwise the
                    // JS↔PHP round-trip corrupts label.custom into an
                    // array, and subsequent drawer edits to .english
                    // get silently dropped by JSON.stringify.
                    'label_json'  => json_encode($label,  JSON_FORCE_OBJECT),
                    'config_json' => json_encode($config, JSON_FORCE_OBJECT),
                    'active'      => $active,
                ]);
                $idMap[$key] = $item->id;
                $byKey[$key] = ['item' => $item, 'parent_key' => $row['parent_id'] ?? null];
                $log['created'][] = ['idx' => $i, 'key' => $key, 'new_id' => $item->id, 'type' => $type];
            } catch (\Throwable $e) {
                $log['errors'][] = ['idx' => $i, 'pass' => 1, 'msg' => $e->getMessage()];
            }
        }

        // Pass 2 — wire parent_id using the old-key → new-id map.
        foreach ($byKey as $entry) {
            try {
                $parentKey = $entry['parent_key'];
                if ($parentKey === null || $parentKey === '' || $parentKey === 0 || $parentKey === '0') {
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

        error_log('[MyTheme persistItems] ' . json_encode($log, JSON_UNESCAPED_SLASHES));
    }

    /**
     * Label is "meaningful" if it has either a non-empty whmcs key or at
     * least one non-empty custom translation. Used only to decide whether
     * to apply the "New <type>" placeholder to a brand-new item that
     * arrived without a label.
     */
    private function isMeaningfulLabel(array $label): bool
    {
        if (!empty($label['whmcs'])) {
            return true;
        }
        $custom = $label['custom'] ?? [];
        if (!is_array($custom)) {
            return false;
        }
        foreach ($custom as $val) {
            if (is_string($val) && $val !== '') {
                return true;
            }
        }
        return false;
    }
}
