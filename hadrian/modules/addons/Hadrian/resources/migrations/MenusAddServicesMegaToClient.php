<?php
declare(strict_types=1);

namespace Hadrian\Resources\Migrations;

use Hadrian\Models\Menu;
use Hadrian\Models\MenuItem;

/**
 * Backfill a "Services" mega menu into the active Client Main Menu on
 * existing installs. The preset definition gained a Services mega at
 * the top of clientMain so fresh installs ship with both Services and
 * Resources megas side-by-side; this migration brings the same shape
 * to menus that were already seeded before the preset change.
 *
 * Idempotent — if a top-level item whose English label contains
 * "Services" (and is a dropdown_parent) already exists, the migration
 * leaves the menu alone.
 *
 * Insertion: positioned right after Home (clientareahome). Bumps the
 * position of every subsequent top-level item by 1 to keep ordering
 * stable.
 */
final class MenusAddServicesMegaToClient
{
    public function up(): void
    {
        if (!\WHMCS\Database\Capsule::schema()->hasTable('hadrian_menu_items')) {
            return;
        }

        $menu = Menu::where('name', 'Client Main Menu')
            ->where('audience', 'client')
            ->where('location', 'main')
            ->first();
        if ($menu === null) {
            return;
        }
        if ($this->hasServicesMega($menu->id)) {
            return;
        }

        $homePosition = $this->positionOfHome($menu->id);
        $insertAt     = $homePosition === null ? 0 : $homePosition + 1;

        // Shift every top-level item at or below the insertion slot by +1.
        MenuItem::where('menu_id', $menu->id)
            ->whereNull('parent_id')
            ->where('position', '>=', $insertAt)
            ->orderBy('position', 'desc')
            ->get()
            ->each(function ($it) {
                $it->position = (int)$it->position + 1;
                $it->save();
            });

        $parent = MenuItem::create([
            'menu_id'     => $menu->id,
            'parent_id'   => null,
            'position'    => $insertAt,
            'item_type'   => 'dropdown_parent',
            'label_json'  => json_encode(['whmcs' => 'navservices', 'custom' => ['english' => 'Services']], JSON_FORCE_OBJECT),
            'config_json' => json_encode(['icon' => 'server', 'dropdown_style' => 'mega'], JSON_FORCE_OBJECT),
            'active'      => true,
        ]);

        foreach ($this->children() as $i => $child) {
            MenuItem::create([
                'menu_id'     => $menu->id,
                'parent_id'   => $parent->id,
                'position'    => $i,
                'item_type'   => $child['type'],
                'label_json'  => json_encode($child['label'], JSON_FORCE_OBJECT),
                'config_json' => json_encode($child['config'] ?? [], JSON_FORCE_OBJECT),
                'active'      => true,
            ]);
        }
    }

    public function down(): void
    {
        if (!\WHMCS\Database\Capsule::schema()->hasTable('hadrian_menu_items')) {
            return;
        }
        $menu = Menu::where('name', 'Client Main Menu')
            ->where('audience', 'client')
            ->where('location', 'main')
            ->first();
        if ($menu === null) {
            return;
        }
        $services = $this->findServicesItem($menu->id);
        if ($services === null) {
            return;
        }
        $removedPosition = (int)$services->position;
        MenuItem::where('parent_id', $services->id)->delete();
        $services->delete();
        // Re-pack positions so subsequent items slide back up by 1.
        MenuItem::where('menu_id', $menu->id)
            ->whereNull('parent_id')
            ->where('position', '>', $removedPosition)
            ->orderBy('position', 'asc')
            ->get()
            ->each(function ($it) {
                $it->position = (int)$it->position - 1;
                $it->save();
            });
    }

    private function hasServicesMega(int $menuId): bool
    {
        return $this->findServicesItem($menuId) !== null;
    }

    private function findServicesItem(int $menuId): ?MenuItem
    {
        return MenuItem::where('menu_id', $menuId)
            ->whereNull('parent_id')
            ->where('item_type', 'dropdown_parent')
            ->get()
            ->first(function ($item) {
                $label = json_decode((string)$item->label_json, true) ?: [];
                $en    = $label['custom']['english'] ?? '';
                $key   = $label['whmcs'] ?? '';
                return stripos((string)$en,  'Services') !== false
                    || stripos((string)$key, 'navservices') !== false;
            });
    }

    /**
     * Position of the top-level Home item (clientareahome). Used as the
     * anchor — Services slots in right after it.
     */
    private function positionOfHome(int $menuId): ?int
    {
        $home = MenuItem::where('menu_id', $menuId)
            ->whereNull('parent_id')
            ->where('item_type', 'whmcs_page')
            ->get()
            ->first(function ($item) {
                $config = json_decode((string)$item->config_json, true) ?: [];
                return ($config['page'] ?? '') === 'clientareahome';
            });
        return $home === null ? null : (int)$home->position;
    }

    private function children(): array
    {
        return [
            $this->header('Manage'),
            $this->whmcsPage('clientareaproducts', 'server',  'My Services'),
            $this->customLink('Renew services', 'cart.php?gid=renewals', 'refresh', 'domainrenewals'),

            $this->header('Order'),
            $this->customLink('Order new services',     'cart.php',             'cart',   'ordernew'),
            $this->customLink('View available add-ons', 'cart.php?gid=addons',  'puzzle', 'orderaddons'),

            $this->header('Shop'),
            $this->customLink('Hosting plans',    'cart.php?gid=shared', 'server', ''),
            $this->customLink('VPS & Dedicated',  'cart.php?gid=vps',    'server', ''),
            $this->customLink('SSL Certificates', 'cart.php?gid=ssl',    'lock',   ''),
        ];
    }

    private function header(string $english): array
    {
        return [
            'type'   => 'header',
            'label'  => ['whmcs' => '', 'custom' => ['english' => $english]],
            'config' => [],
        ];
    }

    private function whmcsPage(string $page, string $icon, string $english): array
    {
        return [
            'type'   => 'whmcs_page',
            'label'  => ['whmcs' => '', 'custom' => ['english' => $english]],
            'config' => ['page' => $page, 'icon' => $icon],
        ];
    }

    private function customLink(string $english, string $url, string $icon, string $whmcsKey): array
    {
        return [
            'type'   => 'custom_link',
            'label'  => ['whmcs' => $whmcsKey, 'custom' => ['english' => $english]],
            'config' => ['url' => $url, 'icon' => $icon],
        ];
    }
}
