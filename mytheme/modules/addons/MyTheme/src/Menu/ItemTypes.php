<?php
declare(strict_types=1);

namespace MyTheme\Menu;

/**
 * Item-type registry. Each constant maps to:
 *   - A row's `item_type` column value
 *   - A label shown in the admin builder
 *   - A renderer in TreeRenderer::renderItem()'s switch
 *   - A "config schema" hint (see MenuItem docblock for the JSON shapes)
 *
 * Adding a new type:
 *   1. Add a constant below
 *   2. Add an entry to ItemTypes::all() with label + supports flags
 *   3. Add a case to TreeRenderer::renderItem()
 *   4. Add a per-type drawer in views/adminarea/menu/edit.tpl
 */
final class ItemTypes
{
    public const WHMCS_PAGE       = 'whmcs_page';
    public const CUSTOM_LINK      = 'custom_link';
    public const DIVIDER          = 'divider';
    public const HEADER           = 'header';
    public const DROPDOWN_PARENT  = 'dropdown_parent';
    public const LANGUAGE         = 'language';
    public const CURRENCY         = 'currency';
    public const LOGIN_BUTTON     = 'login_button';
    public const ACCOUNT_DROPDOWN = 'account_dropdown';
    public const WHMCS_DEFAULT    = 'whmcs_default';

    /**
     * Returns the metadata each builder dropdown / drawer needs:
     *   label         → human label in the admin "+ Add item" picker
     *   accepts_url   → admin shows a URL field
     *   accepts_page  → admin shows the WHMCS page picker
     *   accepts_children → can hold sub-items (only true for dropdown_parent)
     *   guest_only    → audience-locked, hides for clients
     *   client_only   → audience-locked, hides for guests
     */
    public static function all(): array
    {
        return [
            self::WHMCS_PAGE       => ['label' => 'WHMCS Page',        'accepts_page' => true,  'accepts_children' => false],
            self::CUSTOM_LINK      => ['label' => 'Custom Link',       'accepts_url' => true,   'accepts_children' => false],
            self::DROPDOWN_PARENT  => ['label' => 'Dropdown',          'accepts_children' => true],
            self::HEADER           => ['label' => 'Section Header',    'accepts_children' => false],
            self::DIVIDER          => ['label' => 'Divider',           'accepts_children' => false],
            self::LANGUAGE         => ['label' => 'Language Switcher', 'accepts_children' => false],
            self::CURRENCY         => ['label' => 'Currency Switcher', 'accepts_children' => false],
            self::LOGIN_BUTTON     => ['label' => 'Login Button',      'accepts_children' => false, 'guest_only' => true],
            self::ACCOUNT_DROPDOWN => ['label' => 'Account Dropdown',  'accepts_children' => false, 'client_only' => true],
            self::WHMCS_DEFAULT    => ['label' => 'WHMCS Default Navigation (pass-through)', 'accepts_children' => false],
        ];
    }

    public static function meta(string $type): array
    {
        return self::all()[$type] ?? ['label' => $type, 'accepts_children' => false];
    }

    public static function exists(string $type): bool
    {
        return array_key_exists($type, self::all());
    }
}
