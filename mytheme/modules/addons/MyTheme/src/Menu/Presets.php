<?php
declare(strict_types=1);

namespace MyTheme\Menu;

/**
 * Preset menu definitions — the 4 menus Lagom ships with, matched name-for-name
 * so muscle memory transfers when admins move from Lagom.
 *
 * Storage shape per preset:
 *   name       — display name in the admin builder
 *   location   — main | secondary | footer
 *   audience   — client | guest | all
 *   active     — whether this preset is on by default
 *   items      — recursive tree, each node is:
 *                [type=>..., label=>['whmcs'=>..., 'custom'=>[...]],
 *                 config=>[...], children=>[...]]
 *
 * The two "WHMCS Defaults" presets contain ONE item: a whmcs_default
 * passthrough that surfaces whatever WHMCS's own primary navbar renders.
 * That's why they don't need a long item list to maintain — they auto-track
 * the WHMCS-shipped navigation.
 */
final class Presets
{
    public static function all(): array
    {
        return [
            self::clientMain(),
            self::clientWhmcsDefaults(),
            self::guestMain(),
            self::guestWhmcsDefaults(),
        ];
    }

    private static function label(string $whmcsKey, string $english): array
    {
        return ['whmcs' => $whmcsKey, 'custom' => ['english' => $english]];
    }

    private static function clientMain(): array
    {
        return [
            'name'     => 'Client Main Menu',
            'location' => 'main',
            'audience' => 'client',
            'active'   => true,
            'items'    => [
                ['type' => ItemTypes::WHMCS_PAGE, 'label' => self::label('navhome',  'Home'),
                 'config' => ['page' => 'clientareahome', 'icon' => 'home']],
                ['type' => ItemTypes::WHMCS_PAGE, 'label' => self::label('navservices', 'Services'),
                 'config' => ['page' => 'clientareaproducts', 'icon' => 'server']],
                ['type' => ItemTypes::WHMCS_PAGE, 'label' => self::label('navdomains',  'Domains'),
                 'config' => ['page' => 'clientareadomains', 'icon' => 'globe']],
                ['type' => ItemTypes::WHMCS_PAGE, 'label' => self::label('navbilling',  'Billing'),
                 'config' => ['page' => 'clientareainvoices', 'icon' => 'credit-card']],
                ['type' => ItemTypes::WHMCS_PAGE, 'label' => self::label('navsupport',  'Support'),
                 'config' => ['page' => 'supporttickets', 'icon' => 'life-buoy']],
                ['type' => ItemTypes::ACCOUNT_DROPDOWN,
                 'label' => self::label('accounttab', 'Account'),
                 'config' => ['position_side' => 'right', 'icon' => 'user'],
                 'children' => [
                    ['type' => ItemTypes::WHMCS_PAGE, 'label' => self::label('accountdetails', 'Account Details'),
                     'config' => ['page' => 'clientareadetails']],
                    ['type' => ItemTypes::CUSTOM_LINK, 'label' => self::label('logout', 'Logout'),
                     'config' => ['url' => 'logout.php']],
                 ]],
            ],
        ];
    }

    private static function clientWhmcsDefaults(): array
    {
        return [
            'name'     => 'Client Main Menu — WHMCS Defaults',
            'location' => 'main',
            'audience' => 'client',
            'active'   => false,
            'items'    => [
                ['type' => ItemTypes::WHMCS_DEFAULT, 'label' => self::label('', 'WHMCS Default Navigation'), 'config' => []],
            ],
        ];
    }

    private static function guestMain(): array
    {
        return [
            'name'     => 'Guest Main Menu',
            'location' => 'main',
            'audience' => 'guest',
            'active'   => true,
            'items'    => [
                ['type' => ItemTypes::CUSTOM_LINK,    'label' => self::label('', 'Home'),
                 'config' => ['url' => '/', 'icon' => 'home']],
                ['type' => ItemTypes::DROPDOWN_PARENT,
                 'label' => self::label('navhostingproducts', 'Hosting'),
                 'config' => ['dropdown_style' => 'default'],
                 'children' => [
                    ['type' => ItemTypes::CUSTOM_LINK, 'label' => self::label('', 'Shared Hosting'),
                     'config' => ['url' => 'cart.php?gid=shared']],
                    ['type' => ItemTypes::CUSTOM_LINK, 'label' => self::label('', 'VPS'),
                     'config' => ['url' => 'cart.php?gid=vps']],
                    ['type' => ItemTypes::CUSTOM_LINK, 'label' => self::label('', 'Dedicated'),
                     'config' => ['url' => 'cart.php?gid=dedicated']],
                 ]],
                ['type' => ItemTypes::DROPDOWN_PARENT,
                 'label' => self::label('navdomains', 'Domains'),
                 'config' => [],
                 'children' => [
                    ['type' => ItemTypes::CUSTOM_LINK, 'label' => self::label('domainregister', 'Register a New Domain'),
                     'config' => ['url' => 'cart.php?a=add&domain=register']],
                    ['type' => ItemTypes::CUSTOM_LINK, 'label' => self::label('domaintransfer', 'Transfer Domains to Us'),
                     'config' => ['url' => 'cart.php?a=add&domain=transfer']],
                    ['type' => ItemTypes::DIVIDER, 'label' => self::label('', ''), 'config' => []],
                    ['type' => ItemTypes::CUSTOM_LINK, 'label' => self::label('', 'Domain Pricing'),
                     'config' => ['url' => 'domainchecker.php']],
                 ]],
                ['type' => ItemTypes::DROPDOWN_PARENT,
                 'label' => self::label('navsupport', 'Support'),
                 'config' => [],
                 'children' => [
                    ['type' => ItemTypes::WHMCS_PAGE, 'label' => self::label('contact', 'Contact Us'),
                     'config' => ['page' => 'contact']],
                    ['type' => ItemTypes::DIVIDER, 'label' => self::label('', ''), 'config' => []],
                    ['type' => ItemTypes::WHMCS_PAGE, 'label' => self::label('networkissues', 'Network Status'),
                     'config' => ['page' => 'serverstatus']],
                    ['type' => ItemTypes::WHMCS_PAGE, 'label' => self::label('knowledgebase', 'Knowledgebase'),
                     'config' => ['page' => 'knowledgebase']],
                    ['type' => ItemTypes::WHMCS_PAGE, 'label' => self::label('announcementstitle', 'Announcements'),
                     'config' => ['page' => 'announcements']],
                 ]],
                ['type' => ItemTypes::LOGIN_BUTTON, 'label' => self::label('login', 'Login'),
                 'config' => ['position_side' => 'right', 'style' => 'primary']],
                ['type' => ItemTypes::CUSTOM_LINK, 'label' => self::label('register', 'Register'),
                 'config' => ['url' => 'register.php', 'position_side' => 'right']],
                ['type' => ItemTypes::LANGUAGE, 'label' => self::label('chooselanguage', 'Language'),
                 'config' => ['position_side' => 'right']],
            ],
        ];
    }

    private static function guestWhmcsDefaults(): array
    {
        return [
            'name'     => 'Guest Main Menu — WHMCS Defaults',
            'location' => 'main',
            'audience' => 'guest',
            'active'   => false,
            'items'    => [
                ['type' => ItemTypes::WHMCS_DEFAULT, 'label' => self::label('', 'WHMCS Default Navigation'), 'config' => []],
            ],
        ];
    }
}
