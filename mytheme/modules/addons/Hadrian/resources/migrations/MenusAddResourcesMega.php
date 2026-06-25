<?php
declare(strict_types=1);

namespace Hadrian\Resources\Migrations;

use Hadrian\Models\Menu;
use Hadrian\Models\MenuItem;

/**
 * Append a "Resources" mega menu to the active Guest Main + Client Main
 * menus on existing installs. Without this, the new preset definitions
 * only land on fresh installs because the Seeder skips menus that
 * already have items.
 *
 * Idempotent: if a top-level item whose English label contains
 * "Resources" already exists in the target menu, the migration leaves
 * the menu alone. So re-running it (or installing on a setup that
 * already received the new preset via fresh-seed) is a no-op.
 *
 * Insertion: appends after the last left-side item, i.e. before the
 * first item carrying config.position_side="right". That keeps
 * Login/Register/Language pinned to the right of the Resources mega in
 * the topnav.
 */
final class MenusAddResourcesMega
{
    public function up(): void
    {
        if (!\WHMCS\Database\Capsule::schema()->hasTable('hadrian_menu_items')) {
            return;
        }
        $this->appendResourcesMega('Guest Main Menu',  'guest',  $this->guestResources());
        $this->appendResourcesMega('Client Main Menu', 'client', $this->clientResources());
    }

    public function down(): void
    {
        if (!\WHMCS\Database\Capsule::schema()->hasTable('hadrian_menu_items')) {
            return;
        }
        foreach (['Guest Main Menu', 'Client Main Menu'] as $name) {
            $menu = $this->findMenu($name, $name === 'Guest Main Menu' ? 'guest' : 'client');
            if ($menu === null) {
                continue;
            }
            $existing = $this->findResourcesItem($menu->id);
            if ($existing !== null) {
                // FK on parent_id isn't set in the schema -- clean up children manually.
                MenuItem::where('parent_id', $existing->id)->delete();
                $existing->delete();
            }
        }
    }

    private function findMenu(string $name, string $audience): ?Menu
    {
        return Menu::where('name', $name)
            ->where('location', 'main')
            ->where('audience', $audience)
            ->first();
    }

    private function findResourcesItem(int $menuId): ?MenuItem
    {
        return MenuItem::where('menu_id', $menuId)
            ->whereNull('parent_id')
            ->where('item_type', 'dropdown_parent')
            ->get()
            ->first(function ($item) {
                $label = json_decode((string)$item->label_json, true) ?: [];
                $en = $label['custom']['english'] ?? '';
                return stripos((string)$en, 'Resources') !== false;
            });
    }

    private function appendResourcesMega(string $menuName, string $audience, array $children): void
    {
        $menu = $this->findMenu($menuName, $audience);
        if ($menu === null) {
            return;
        }
        if ($this->findResourcesItem($menu->id) !== null) {
            return;
        }

        // Decide insertion position: before the first right-side item
        // (Login/Register/Language for guests; Account for clients).
        // Bump every right-side item's position by 1 to make room.
        $rightItems = MenuItem::where('menu_id', $menu->id)
            ->whereNull('parent_id')
            ->orderBy('position')
            ->get()
            ->filter(function ($it) {
                $cfg = json_decode((string)$it->config_json, true) ?: [];
                return ($cfg['position_side'] ?? '') === 'right';
            });
        if ($rightItems->isNotEmpty()) {
            $insertAt = (int)$rightItems->first()->position;
            // Shift right-side items down by 1 to make a slot.
            foreach ($rightItems as $it) {
                $it->position = (int)$it->position + 1;
                $it->save();
            }
        } else {
            $maxPos  = (int)MenuItem::where('menu_id', $menu->id)->whereNull('parent_id')->max('position');
            $insertAt = $maxPos + 1;
        }

        $parent = MenuItem::create([
            'menu_id'     => $menu->id,
            'parent_id'   => null,
            'position'    => $insertAt,
            'item_type'   => 'dropdown_parent',
            'label_json'  => json_encode(['whmcs' => '', 'custom' => ['english' => 'Resources']], JSON_FORCE_OBJECT),
            'config_json' => json_encode(['icon' => 'book', 'dropdown_style' => 'mega'], JSON_FORCE_OBJECT),
            'active'      => true,
        ]);

        foreach ($children as $i => $child) {
            $config = $child['config'] ?? [];
            MenuItem::create([
                'menu_id'     => $menu->id,
                'parent_id'   => $parent->id,
                'position'    => $i,
                'item_type'   => $child['type'],
                'label_json'  => json_encode($child['label'], JSON_FORCE_OBJECT),
                'config_json' => json_encode($config, JSON_FORCE_OBJECT),
                'active'      => true,
            ]);
        }
    }

    // ── Children shapes, mirrors Presets.php's new definitions ──

    private function guestResources(): array
    {
        return [
            $this->header('Learn'),
            $this->whmcsPage('knowledgebase', 'book',      'Knowledge Base'),
            $this->whmcsPage('announcements', 'megaphone', 'Announcements'),

            $this->header('Status'),
            $this->whmcsPage('serverstatus', 'status', 'Server Status'),
            $this->customLink('Network map', '/network', 'globe'),

            $this->header('Connect'),
            $this->whmcsPage('contact', 'envelope', 'Contact'),
            $this->customLink('Affiliates', 'affiliates.php', 'star'),
        ];
    }

    private function clientResources(): array
    {
        return [
            $this->header('Documentation'),
            $this->whmcsPage('knowledgebase', 'book',      'Knowledge Base'),
            $this->whmcsPage('announcements', 'megaphone', 'Announcements'),

            $this->header('Tools'),
            $this->whmcsPage('downloads',    'download', 'Downloads'),
            $this->whmcsPage('serverstatus', 'status',   'Server Status'),

            $this->header('Support'),
            $this->whmcsPage('contact',             'envelope', 'Contact'),
            $this->whmcsPage('supportticketsubmit', 'plus',     'Open Ticket'),
        ];
    }

    // Migration-local item builders -- can't reuse Presets's private statics,
    // and we want zero coupling to the live WhmcsDefaults lookup so this
    // migration is reproducible regardless of future preset edits.

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

    private function customLink(string $english, string $url, string $icon): array
    {
        return [
            'type'   => 'custom_link',
            'label'  => ['whmcs' => '', 'custom' => ['english' => $english]],
            'config' => ['url' => $url, 'icon' => $icon],
        ];
    }
}
