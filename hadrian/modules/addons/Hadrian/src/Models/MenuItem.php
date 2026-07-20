<?php
declare(strict_types=1);

namespace Hadrian\Models;

use Hadrian\Helpers\LocaleHelper;
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
    public const LABEL_MODE_CUSTOM = 'custom';
    public const LABEL_MODE_WHMCS  = 'whmcs';

    /**
     * Which label source the admin picked, stored as label_json.mode.
     * Rows saved before that key existed are DERIVED, and the derivation
     * reproduces the previous resolution order exactly, so no live label moves.
     */
    public function labelMode(): string
    {
        $label = $this->label();
        $mode  = (string)($label['mode'] ?? '');
        if ($mode === self::LABEL_MODE_CUSTOM || $mode === self::LABEL_MODE_WHMCS) {
            return $mode;
        }
        $custom = is_array($label['custom'] ?? null) ? $label['custom'] : [];
        foreach ($custom as $val) {
            if (is_string($val) && $val !== '') {
                return self::LABEL_MODE_CUSTOM;
            }
        }
        return trim((string)($label['whmcs'] ?? '')) !== ''
            ? self::LABEL_MODE_WHMCS
            : self::LABEL_MODE_CUSTOM;
    }

    /**
     * Human label for a CLIENT-FACING render.
     *
     *   mode = whmcs  : $_LANG[key], else the raw key. Terminal on purpose --
     *                   never falls back to custom, so a mistyped key is
     *                   visibly wrong rather than silently masked.
     *   mode = custom : custom[$locale] -> $_LANG[key] -> custom['english'] -> key
     *
     * $_LANG stays as rung 2 of the custom chain deliberately: seeded rows carry
     * BOTH a key and custom.english, so dropping it would pin a French visitor
     * to English forever.
     *
     * $locale is NULLABLE, not required. TreeRenderer wraps its calls in
     * catch (\Throwable), so a required argument would turn an ArgumentCountError
     * into a silently DROPPED nav item rather than a visible error.
     */
    public function resolvedLabel(?string $locale = null): string
    {
        $locale = strtolower(trim((string)($locale ?? LocaleHelper::current())));
        if ($locale === '') {
            $locale = 'english';
        }

        $label    = $this->label();
        $custom   = is_array($label['custom'] ?? null) ? $label['custom'] : [];
        $whmcsKey = trim((string)($label['whmcs'] ?? ''));
        $lang     = is_array($GLOBALS['_LANG'] ?? null) ? $GLOBALS['_LANG'] : [];

        if ($this->labelMode() === self::LABEL_MODE_WHMCS && $whmcsKey !== '') {
            if (!empty($lang[$whmcsKey]) && is_string($lang[$whmcsKey])) {
                return (string)$lang[$whmcsKey];
            }
            return $whmcsKey;
        }

        if (!empty($custom[$locale]) && is_string($custom[$locale])) {
            return (string)$custom[$locale];
        }
        if ($whmcsKey !== '' && !empty($lang[$whmcsKey]) && is_string($lang[$whmcsKey])) {
            return (string)$lang[$whmcsKey];
        }
        if (!empty($custom['english']) && is_string($custom['english'])) {
            return (string)$custom['english'];
        }
        return $whmcsKey;
    }

    /**
     * Label for the ADMIN menu tree. Never reads $GLOBALS['_LANG'] -- in the
     * admin area that global holds the ADMIN language file, not the client one,
     * so resolvedLabel() here would print the wrong string. Mirrors the editor's
     * JS rowLabelFor(), so a row label does not jump between page load and the
     * first keystroke.
     */
    public function editorLabel(): string
    {
        $label  = $this->label();
        $custom = is_array($label['custom'] ?? null) ? $label['custom'] : [];
        if (!empty($custom['english']) && is_string($custom['english'])) {
            return (string)$custom['english'];
        }
        $whmcsKey = trim((string)($label['whmcs'] ?? ''));
        return $whmcsKey !== '' ? $whmcsKey : '(no label)';
    }
}
