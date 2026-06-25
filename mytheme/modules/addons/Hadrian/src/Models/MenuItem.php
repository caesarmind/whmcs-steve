<?php
declare(strict_types=1);

namespace Hadrian\Models;

use Illuminate\Database\Eloquent\Collection;
use Illuminate\Database\Eloquent\Model;

/**
 * One entry inside a Menu. Tree shape: parent_id NULL = root,
 * parent_id = parent item's id otherwise. Position orders siblings.
 *
 * label_json shape (matches Lagom's `title` column):
 *   {"whmcs": "navHome",  "custom": {"english": "Home", "french": "Accueil"}}
 *   - "whmcs" key: pulls from $LANG when non-empty
 *   - "custom" map: per-locale override (current locale wins; English fallback)
 *
 * config_json shape (per item_type — examples):
 *   whmcs_page:     {"page": "clientareahome"}
 *   custom_link:    {"url": "https://example.com", "target": "_blank"}
 *   dropdown_parent:{"dropdown_style": "default|mega"}
 *   header:         {} (just a label)
 *   divider:        {} (no config)
 *   language:       {} (rendered by switcher)
 *   currency:       {}
 *   login_button:   {"style": "primary"}
 *   account_dropdown: {}
 *   whmcs_default:  {} (passes through native $primaryNavbar items)
 *
 * Shared optional config keys (any item_type may set):
 *   "icon":          (string) font-awesome/SVG class
 *   "css_class":     (string) extra CSS class
 *   "position_side": ("left"|"right") — visual alignment on horizontal nav
 *   "audience":      ("client"|"guest"|"all") — per-item override
 *   "theme_layouts": ["top","side","rail"] — which layouts show this item
 */
class MenuItem extends Model
{
    protected $table = 'hadrian_menu_items';

    protected $fillable = [
        'menu_id', 'parent_id', 'position', 'item_type',
        'label_json', 'config_json', 'active',
    ];

    protected $casts = [
        'active'    => 'boolean',
        'parent_id' => 'integer',
        'position'  => 'integer',
    ];

    public function menu()
    {
        return $this->belongsTo(Menu::class, 'menu_id');
    }

    public function parent()
    {
        return $this->belongsTo(MenuItem::class, 'parent_id');
    }

    public function children()
    {
        return $this->hasMany(MenuItem::class, 'parent_id')->orderBy('position');
    }

    /**
     * Decoded label data. Returns ['whmcs' => ..., 'custom' => ['english' => ..., ...]].
     */
    public function label(): array
    {
        $raw = json_decode((string)$this->label_json, true);
        return is_array($raw) ? $raw : ['whmcs' => '', 'custom' => []];
    }

    /**
     * Decoded config data.
     */
    public function config(): array
    {
        $raw = json_decode((string)$this->config_json, true);
        return is_array($raw) ? $raw : [];
    }

    /**
     * Resolve the human-readable label for the current locale.
     * Order of preference:
     *   1. custom[<currentLocale>] if non-empty
     *   2. $GLOBALS['_LANG'][whmcsKey] (WHMCS lang key)
     *   3. custom.english fallback
     *   4. The raw whmcs key as a last resort (so we never render blank)
     */
    public function resolvedLabel(string $locale = 'english'): string
    {
        $label = $this->label();
        $custom = $label['custom'] ?? [];
        if (!empty($custom[$locale])) {
            return (string)$custom[$locale];
        }
        $whmcsKey = (string)($label['whmcs'] ?? '');
        if ($whmcsKey !== '') {
            $lang = $GLOBALS['_LANG'] ?? [];
            if (!empty($lang[$whmcsKey])) {
                return (string)$lang[$whmcsKey];
            }
        }
        if (!empty($custom['english'])) {
            return (string)$custom['english'];
        }
        return $whmcsKey;
    }
}
