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

    /**
     * Full WHMCS-default client primary nav, matching Lagom's preset shape
     * AND matching the apple-client-area mockup's section labels:
     *   Header(Home) · Home
     *   Header(Services) · Services▾
     *   Header(Domains) · Domains▾
     *   Header(Billing) · Billing▾
     *   Header(Support) · Support▾
     *   Header(Account) · Affiliates · Open Ticket (right)
     *
     * Headers render as the uppercase section dividers
     * (.sidebar-section-label / .nav-section). Admins can rearrange or
     * delete them via the menu builder — they're just regular items.
     */
    private static function clientWhmcsDefaults(): array
    {
        return [
            'name'     => 'Client Main Menu — WHMCS Defaults',
            'location' => 'main',
            'audience' => 'client',
            'active'   => false,
            'items'    => [
                ['type' => ItemTypes::HEADER, 'label' => self::label('', 'Home'), 'config' => []],
                ['type' => ItemTypes::CUSTOM_LINK, 'label' => self::label('navhome', 'Home'),
                 'config' => ['url' => 'clientarea.php', 'icon' => 'home']],

                ['type' => ItemTypes::HEADER, 'label' => self::label('navservices', 'Services'), 'config' => []],
                ['type' => ItemTypes::DROPDOWN_PARENT,
                 'label' => self::label('navservices', 'Services'),
                 'config' => ['icon' => 'server'],
                 'children' => [
                    ['type' => ItemTypes::CUSTOM_LINK, 'label' => self::label('navservices', 'My Services'),
                     'config' => ['url' => 'clientarea.php?action=services', 'icon' => 'server']],
                    ['type' => ItemTypes::DIVIDER, 'label' => self::label('', ''), 'config' => []],
                    ['type' => ItemTypes::CUSTOM_LINK, 'label' => self::label('domainrenewals', 'Renew Services'),
                     'config' => ['url' => 'cart.php?gid=renewals', 'icon' => 'refresh']],
                    ['type' => ItemTypes::CUSTOM_LINK, 'label' => self::label('ordernew', 'Order New Services'),
                     'config' => ['url' => 'cart.php', 'icon' => 'cart']],
                    ['type' => ItemTypes::CUSTOM_LINK, 'label' => self::label('orderaddons', 'View Available Addons'),
                     'config' => ['url' => 'cart.php?gid=addons', 'icon' => 'puzzle']],
                 ]],

                ['type' => ItemTypes::HEADER, 'label' => self::label('navdomains', 'Domains'), 'config' => []],
                ['type' => ItemTypes::DROPDOWN_PARENT,
                 'label' => self::label('navdomains', 'Domains'),
                 'config' => ['icon' => 'globe'],
                 'children' => [
                    ['type' => ItemTypes::CUSTOM_LINK, 'label' => self::label('navdomains', 'My Domains'),
                     'config' => ['url' => 'clientarea.php?action=domains', 'icon' => 'globe']],
                    ['type' => ItemTypes::DIVIDER, 'label' => self::label('', ''), 'config' => []],
                    ['type' => ItemTypes::CUSTOM_LINK, 'label' => self::label('domainrenewals', 'Domain Renewals'),
                     'config' => ['url' => 'cart.php?a=add&domain=renewal', 'icon' => 'refresh']],
                    ['type' => ItemTypes::CUSTOM_LINK, 'label' => self::label('domainregister', 'Register a New Domain'),
                     'config' => ['url' => 'cart.php?a=add&domain=register', 'icon' => 'plus']],
                    ['type' => ItemTypes::CUSTOM_LINK, 'label' => self::label('domaintransfer', 'Transfer Domains to Us'),
                     'config' => ['url' => 'cart.php?a=add&domain=transfer', 'icon' => 'transfer']],
                    ['type' => ItemTypes::CUSTOM_LINK, 'label' => self::label('', 'Website & Security'),
                     'config' => ['url' => 'cart.php?gid=websitesecurity', 'icon' => 'shield']],
                    ['type' => ItemTypes::CUSTOM_LINK, 'label' => self::label('', 'MarketConnect Products'),
                     'config' => ['url' => 'cart.php?gid=marketconnect', 'icon' => 'package']],
                    ['type' => ItemTypes::DIVIDER, 'label' => self::label('', ''), 'config' => []],
                    ['type' => ItemTypes::CUSTOM_LINK, 'label' => self::label('', 'Manage SSL Certificates'),
                     'config' => ['url' => 'clientarea.php?action=ssl', 'icon' => 'lock']],
                 ]],

                ['type' => ItemTypes::HEADER, 'label' => self::label('billingtab', 'Billing'), 'config' => []],
                ['type' => ItemTypes::DROPDOWN_PARENT,
                 'label' => self::label('billingtab', 'Billing'),
                 'config' => ['icon' => 'credit-card'],
                 'children' => [
                    ['type' => ItemTypes::CUSTOM_LINK, 'label' => self::label('navinvoices', 'My Invoices'),
                     'config' => ['url' => 'clientarea.php?action=invoices', 'icon' => 'invoice']],
                    ['type' => ItemTypes::CUSTOM_LINK, 'label' => self::label('navquotes', 'My Quotes'),
                     'config' => ['url' => 'clientarea.php?action=quotes', 'icon' => 'quote']],
                    ['type' => ItemTypes::DIVIDER, 'label' => self::label('', ''), 'config' => []],
                    ['type' => ItemTypes::CUSTOM_LINK, 'label' => self::label('masspayment', 'Mass Payment'),
                     'config' => ['url' => 'clientarea.php?action=masspay&all=true', 'icon' => 'wallet']],
                    ['type' => ItemTypes::CUSTOM_LINK, 'label' => self::label('paymentmethods', 'Payment Methods'),
                     'config' => ['url' => 'clientarea.php?action=paymentmethods', 'icon' => 'credit-card']],
                    ['type' => ItemTypes::CUSTOM_LINK, 'label' => self::label('addfunds', 'Add Funds'),
                     'config' => ['url' => 'clientarea.php?action=addfunds', 'icon' => 'plus-circle']],
                 ]],

                ['type' => ItemTypes::HEADER, 'label' => self::label('navsupport', 'Support'), 'config' => []],
                ['type' => ItemTypes::DROPDOWN_PARENT,
                 'label' => self::label('navsupport', 'Support'),
                 'config' => ['icon' => 'life-buoy'],
                 'children' => [
                    ['type' => ItemTypes::CUSTOM_LINK, 'label' => self::label('navtickets', 'Tickets'),
                     'config' => ['url' => 'supporttickets.php', 'icon' => 'support']],
                    ['type' => ItemTypes::CUSTOM_LINK, 'label' => self::label('announcementstitle', 'Announcements'),
                     'config' => ['url' => 'announcements.php', 'icon' => 'megaphone']],
                    ['type' => ItemTypes::CUSTOM_LINK, 'label' => self::label('knowledgebase', 'Knowledgebase'),
                     'config' => ['url' => 'knowledgebase.php', 'icon' => 'book']],
                    ['type' => ItemTypes::CUSTOM_LINK, 'label' => self::label('downloadstitle', 'Downloads'),
                     'config' => ['url' => 'downloads.php', 'icon' => 'download']],
                    ['type' => ItemTypes::CUSTOM_LINK, 'label' => self::label('networkstatus', 'Network Status'),
                     'config' => ['url' => 'serverstatus.php', 'icon' => 'status']],
                    ['type' => ItemTypes::CUSTOM_LINK, 'label' => self::label('opennewticket', 'Open Ticket'),
                     'config' => ['url' => 'submitticket.php', 'icon' => 'plus']],
                 ]],

                ['type' => ItemTypes::HEADER, 'label' => self::label('accounttab', 'Account'), 'config' => []],
                ['type' => ItemTypes::CUSTOM_LINK, 'label' => self::label('affiliatesnav', 'Affiliates'),
                 'config' => ['url' => 'affiliates.php', 'icon' => 'star']],

                ['type' => ItemTypes::CUSTOM_LINK, 'label' => self::label('opennewticket', 'Open Ticket'),
                 'config' => ['url' => 'submitticket.php', 'icon' => 'plus', 'position_side' => 'right']],
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

    /**
     * Full WHMCS-default guest primary nav — the items WHMCS itself surfaces
     * for unauthenticated visitors plus the standard Login / Register / Language CTAs.
     */
    private static function guestWhmcsDefaults(): array
    {
        return [
            'name'     => 'Guest Main Menu — WHMCS Defaults',
            'location' => 'main',
            'audience' => 'guest',
            'active'   => false,
            'items'    => [
                ['type' => ItemTypes::HEADER, 'label' => self::label('', 'Shop'), 'config' => []],
                ['type' => ItemTypes::CUSTOM_LINK, 'label' => self::label('navhome', 'Home'),
                 'config' => ['url' => '/', 'icon' => 'home']],

                ['type' => ItemTypes::CUSTOM_LINK, 'label' => self::label('orderproducts', 'Browse Products'),
                 'config' => ['url' => 'cart.php', 'icon' => 'shop']],

                ['type' => ItemTypes::HEADER, 'label' => self::label('navdomains', 'Domains'), 'config' => []],
                ['type' => ItemTypes::DROPDOWN_PARENT,
                 'label' => self::label('navdomains', 'Domains'),
                 'config' => ['icon' => 'globe'],
                 'children' => [
                    ['type' => ItemTypes::CUSTOM_LINK, 'label' => self::label('domainregister', 'Register a Domain'),
                     'config' => ['url' => 'cart.php?a=add&domain=register', 'icon' => 'plus']],
                    ['type' => ItemTypes::CUSTOM_LINK, 'label' => self::label('domaintransfer', 'Transfer Domain'),
                     'config' => ['url' => 'cart.php?a=add&domain=transfer', 'icon' => 'transfer']],
                    ['type' => ItemTypes::DIVIDER, 'label' => self::label('', ''), 'config' => []],
                    ['type' => ItemTypes::CUSTOM_LINK, 'label' => self::label('', 'Domain Pricing'),
                     'config' => ['url' => 'cart.php?a=add&domain=register', 'icon' => 'tag']],
                 ]],

                ['type' => ItemTypes::HEADER, 'label' => self::label('navsupport', 'Information'), 'config' => []],
                ['type' => ItemTypes::DROPDOWN_PARENT,
                 'label' => self::label('navsupport', 'Support'),
                 'config' => ['icon' => 'life-buoy'],
                 'children' => [
                    ['type' => ItemTypes::CUSTOM_LINK, 'label' => self::label('contactus', 'Contact Us'),
                     'config' => ['url' => 'contact.php', 'icon' => 'envelope']],
                    ['type' => ItemTypes::CUSTOM_LINK, 'label' => self::label('networkstatus', 'Network Status'),
                     'config' => ['url' => 'serverstatus.php', 'icon' => 'status']],
                    ['type' => ItemTypes::CUSTOM_LINK, 'label' => self::label('knowledgebase', 'Knowledgebase'),
                     'config' => ['url' => 'knowledgebase.php', 'icon' => 'book']],
                    ['type' => ItemTypes::CUSTOM_LINK, 'label' => self::label('announcementstitle', 'Announcements'),
                     'config' => ['url' => 'announcements.php', 'icon' => 'megaphone']],
                 ]],

                ['type' => ItemTypes::LOGIN_BUTTON, 'label' => self::label('login', 'Login'),
                 'config' => ['position_side' => 'right', 'style' => 'primary', 'icon' => 'transfer']],
                ['type' => ItemTypes::CUSTOM_LINK, 'label' => self::label('register', 'Register'),
                 'config' => ['url' => 'register.php', 'position_side' => 'right', 'icon' => 'user']],
                ['type' => ItemTypes::LANGUAGE, 'label' => self::label('chooselanguage', 'Language'),
                 'config' => ['position_side' => 'right', 'icon' => 'globe']],
            ],
        ];
    }
}
