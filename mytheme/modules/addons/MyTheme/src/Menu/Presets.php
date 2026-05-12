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
        // Use direct URLs everywhere — templatefile-style names like
        // "clientareahome" aren't valid routePath() names in WHMCS 9, so
        // routePath() returns the literal "/index.php/route-not-defined"
        // which makes every menu link broken.
        return [
            'name'     => 'Client Main Menu',
            'location' => 'main',
            'audience' => 'client',
            'active'   => true,
            'items'    => [
                ['type' => ItemTypes::CUSTOM_LINK, 'label' => self::label('navhome',  'Home'),
                 'config' => ['url' => 'clientarea.php']],
                ['type' => ItemTypes::CUSTOM_LINK, 'label' => self::label('navservices', 'Services'),
                 'config' => ['url' => 'clientarea.php?action=services']],
                ['type' => ItemTypes::CUSTOM_LINK, 'label' => self::label('navdomains',  'Domains'),
                 'config' => ['url' => 'clientarea.php?action=domains']],
                ['type' => ItemTypes::CUSTOM_LINK, 'label' => self::label('navbilling',  'Billing'),
                 'config' => ['url' => 'clientarea.php?action=invoices']],
                ['type' => ItemTypes::CUSTOM_LINK, 'label' => self::label('navsupport',  'Support'),
                 'config' => ['url' => 'supporttickets.php']],
                ['type' => ItemTypes::ACCOUNT_DROPDOWN,
                 'label' => self::label('accounttab', 'Account'),
                 'config' => ['position_side' => 'right'],
                 'children' => [
                    ['type' => ItemTypes::CUSTOM_LINK, 'label' => self::label('accountdetails', 'Account Details'),
                     'config' => ['url' => 'clientarea.php?action=details']],
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
                    ['type' => ItemTypes::CUSTOM_LINK, 'label' => self::label('contact', 'Contact Us'),
                     'config' => ['url' => 'contact.php']],
                    ['type' => ItemTypes::DIVIDER, 'label' => self::label('', ''), 'config' => []],
                    ['type' => ItemTypes::CUSTOM_LINK, 'label' => self::label('networkissues', 'Network Status'),
                     'config' => ['url' => 'serverstatus.php']],
                    ['type' => ItemTypes::CUSTOM_LINK, 'label' => self::label('knowledgebase', 'Knowledgebase'),
                     'config' => ['url' => 'knowledgebase.php']],
                    ['type' => ItemTypes::CUSTOM_LINK, 'label' => self::label('announcementstitle', 'Announcements'),
                     'config' => ['url' => 'announcements.php']],
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
