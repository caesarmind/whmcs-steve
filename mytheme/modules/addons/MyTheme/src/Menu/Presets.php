<?php
declare(strict_types=1);

namespace MyTheme\Menu;

/**
 * Preset menu definitions — the 4 menus shipped with MyTheme. Matched
 * name-for-name with Lagom's presets so muscle memory transfers when admins
 * move from Lagom.
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
 * TYPE SELECTION POLICY
 *   - whmcs_page  — when the URL maps to a real WHMCS client-area templatefile
 *                   (Home → clientareahome, Tickets → supportticketslist, etc.).
 *                   The URL is resolved at render time via WhmcsDefaults so a
 *                   single edit there propagates to every preset.
 *   - custom_link — order-form / cart deeplinks (cart.php?a=add&domain=…),
 *                   external URLs (logout.php, affiliates.php), and group-
 *                   specific cart filters (cart.php?gid=shared). These do
 *                   NOT route through a client-area templatefile so they
 *                   can't be whmcs_page.
 *   - dropdown_parent — pure container that groups children under a label.
 *   - header / divider / login_button / language / account_dropdown — special types.
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
            self::footerDefaults(),
        ];
    }

    private static function label(string $whmcsKey, string $english): array
    {
        return ['whmcs' => $whmcsKey, 'custom' => ['english' => $english]];
    }

    /**
     * Shorthand for a whmcs_page item — picks the lang_key + default_label
     * from WhmcsDefaults so the preset stays consistent with the picker
     * and the URL resolver.
     */
    private static function whmcsPage(string $templatefile, ?string $iconOverride = null): array
    {
        $d = WhmcsDefaults::lookup($templatefile)
            ?? ['lang_key' => '', 'default_label' => ucwords(str_replace(['-', '_'], ' ', $templatefile))];
        $config = ['page' => $templatefile];
        if ($iconOverride !== null) {
            $config['icon'] = $iconOverride;
        }
        return [
            'type'   => ItemTypes::WHMCS_PAGE,
            'label'  => self::label($d['lang_key'], $d['default_label']),
            'config' => $config,
        ];
    }

    /** Shorthand for a custom_link item — cart deeplinks, external URLs, etc. */
    private static function customLink(string $langKey, string $english, string $url, ?string $icon = null, ?string $positionSide = null): array
    {
        $config = ['url' => $url];
        if ($icon !== null) $config['icon'] = $icon;
        if ($positionSide !== null) $config['position_side'] = $positionSide;
        return [
            'type'   => ItemTypes::CUSTOM_LINK,
            'label'  => self::label($langKey, $english),
            'config' => $config,
        ];
    }

    private static function clientMain(): array
    {
        return [
            'name'     => 'Client Main Menu',
            'location' => 'main',
            'audience' => 'client',
            'active'   => true,
            'items'    => [
                self::whmcsPage('clientareahome'),
                self::whmcsPage('clientareaproducts'),
                self::whmcsPage('clientareadomains'),
                self::whmcsPage('clientareainvoices'),
                self::whmcsPage('supportticketslist'),
                ['type' => ItemTypes::ACCOUNT_DROPDOWN,
                 'label' => self::label('accounttab', 'Account'),
                 'config' => ['position_side' => 'right'],
                 'children' => [
                    self::whmcsPage('clientareadetails'),
                    self::customLink('logout', 'Logout', 'logout.php'),
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
                self::whmcsPage('clientareahome', 'home'),

                ['type' => ItemTypes::HEADER, 'label' => self::label('navservices', 'Services'), 'config' => []],
                ['type' => ItemTypes::DROPDOWN_PARENT,
                 'label' => self::label('navservices', 'Services'),
                 'config' => ['icon' => 'server'],
                 'children' => [
                    self::whmcsPage('clientareaproducts', 'server'),
                    ['type' => ItemTypes::DIVIDER, 'label' => self::label('', ''), 'config' => []],
                    // Order-form deeplinks — these are NOT client-area templatefiles, so they
                    // stay custom_link. WHMCS routes them through the order-form theme.
                    self::customLink('domainrenewals', 'Renew Services',   'cart.php?gid=renewals',  'refresh'),
                    self::customLink('ordernew',       'Order New Services','cart.php',              'cart'),
                    self::customLink('orderaddons',    'View Available Addons','cart.php?gid=addons','puzzle'),
                 ]],

                ['type' => ItemTypes::HEADER, 'label' => self::label('navdomains', 'Domains'), 'config' => []],
                ['type' => ItemTypes::DROPDOWN_PARENT,
                 'label' => self::label('navdomains', 'Domains'),
                 'config' => ['icon' => 'globe'],
                 'children' => [
                    self::whmcsPage('clientareadomains', 'globe'),
                    ['type' => ItemTypes::DIVIDER, 'label' => self::label('', ''), 'config' => []],
                    // Cart deeplinks — order-form routes, stay custom_link.
                    self::customLink('domainrenewals', 'Domain Renewals',          'cart.php?a=add&domain=renewal',  'refresh'),
                    self::customLink('domainregister', 'Register a New Domain',    'cart.php?a=add&domain=register', 'plus'),
                    self::customLink('domaintransfer', 'Transfer Domains to Us',   'cart.php?a=add&domain=transfer', 'transfer'),
                    self::customLink('',               'Website & Security',       'cart.php?gid=websitesecurity',   'shield'),
                    self::customLink('',               'MarketConnect Products',   'cart.php?gid=marketconnect',     'package'),
                    ['type' => ItemTypes::DIVIDER, 'label' => self::label('', ''), 'config' => []],
                    self::whmcsPage('managessl', 'lock'),
                 ]],

                ['type' => ItemTypes::HEADER, 'label' => self::label('billingtab', 'Billing'), 'config' => []],
                ['type' => ItemTypes::DROPDOWN_PARENT,
                 'label' => self::label('billingtab', 'Billing'),
                 'config' => ['icon' => 'credit-card'],
                 'children' => [
                    self::whmcsPage('clientareainvoices', 'invoice'),
                    self::whmcsPage('clientareaquotes',   'quote'),
                    ['type' => ItemTypes::DIVIDER, 'label' => self::label('', ''), 'config' => []],
                    // Mass Payment with &all=true is a specific entrypoint, not the canonical
                    // WhmcsDefaults URL. Keep as custom_link to preserve the param.
                    self::customLink('masspayment', 'Mass Payment', 'clientarea.php?action=masspay&all=true', 'wallet'),
                    self::whmcsPage('account-paymentmethods', 'credit-card'),
                    self::whmcsPage('clientareaaddfunds', 'plus-circle'),
                 ]],

                ['type' => ItemTypes::HEADER, 'label' => self::label('navsupport', 'Support'), 'config' => []],
                ['type' => ItemTypes::DROPDOWN_PARENT,
                 'label' => self::label('navsupport', 'Support'),
                 'config' => ['icon' => 'life-buoy'],
                 'children' => [
                    self::whmcsPage('supportticketslist', 'support'),
                    self::whmcsPage('announcements',      'megaphone'),
                    self::whmcsPage('knowledgebase',      'book'),
                    self::whmcsPage('downloads',          'download'),
                    self::whmcsPage('serverstatus',       'status'),
                    self::whmcsPage('supportticketsubmit','plus'),
                 ]],

                ['type' => ItemTypes::HEADER, 'label' => self::label('accounttab', 'Account'), 'config' => []],
                // Affiliates isn't in our page scope — stays custom_link.
                self::customLink('affiliatesnav', 'Affiliates', 'affiliates.php', 'star'),

                // Right-rail CTA — re-uses the supportticketsubmit page.
                ['type' => ItemTypes::WHMCS_PAGE,
                 'label' => self::label('opennewticket', 'Open Ticket'),
                 'config' => ['page' => 'supportticketsubmit', 'icon' => 'plus', 'position_side' => 'right']],
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
                self::customLink('', 'Home', '/', 'home'),
                ['type' => ItemTypes::DROPDOWN_PARENT,
                 'label' => self::label('navhostingproducts', 'Hosting'),
                 'config' => ['dropdown_style' => 'default'],
                 'children' => [
                    // Group-specific cart filters — custom_link.
                    self::customLink('', 'Shared Hosting', 'cart.php?gid=shared'),
                    self::customLink('', 'VPS',            'cart.php?gid=vps'),
                    self::customLink('', 'Dedicated',      'cart.php?gid=dedicated'),
                 ]],
                ['type' => ItemTypes::DROPDOWN_PARENT,
                 'label' => self::label('navdomains', 'Domains'),
                 'config' => [],
                 'children' => [
                    self::customLink('domainregister', 'Register a New Domain',  'cart.php?a=add&domain=register'),
                    self::customLink('domaintransfer', 'Transfer Domains to Us', 'cart.php?a=add&domain=transfer'),
                    ['type' => ItemTypes::DIVIDER, 'label' => self::label('', ''), 'config' => []],
                    // /domainchecker.php isn't a client-area templatefile.
                    self::customLink('', 'Domain Pricing', 'domainchecker.php'),
                 ]],
                ['type' => ItemTypes::DROPDOWN_PARENT,
                 'label' => self::label('navsupport', 'Support'),
                 'config' => [],
                 'children' => [
                    self::whmcsPage('contact'),
                    ['type' => ItemTypes::DIVIDER, 'label' => self::label('', ''), 'config' => []],
                    self::whmcsPage('serverstatus'),
                    self::whmcsPage('knowledgebase'),
                    self::whmcsPage('announcements'),
                 ]],
                ['type' => ItemTypes::LOGIN_BUTTON, 'label' => self::label('login', 'Login'),
                 'config' => ['position_side' => 'right', 'style' => 'primary']],
                ['type' => ItemTypes::WHMCS_PAGE,
                 'label' => self::label('register', 'Register'),
                 'config' => ['page' => 'clientregister', 'position_side' => 'right']],
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
                self::customLink('navhome', 'Home', '/', 'home'),
                self::customLink('orderproducts', 'Browse Products', 'cart.php', 'shop'),

                ['type' => ItemTypes::HEADER, 'label' => self::label('navdomains', 'Domains'), 'config' => []],
                ['type' => ItemTypes::DROPDOWN_PARENT,
                 'label' => self::label('navdomains', 'Domains'),
                 'config' => ['icon' => 'globe'],
                 'children' => [
                    self::customLink('domainregister', 'Register a Domain',     'cart.php?a=add&domain=register', 'plus'),
                    self::customLink('domaintransfer', 'Transfer Domain',       'cart.php?a=add&domain=transfer', 'transfer'),
                    ['type' => ItemTypes::DIVIDER, 'label' => self::label('', ''), 'config' => []],
                    self::customLink('', 'Domain Pricing', 'cart.php?a=add&domain=register', 'tag'),
                 ]],

                ['type' => ItemTypes::HEADER, 'label' => self::label('navsupport', 'Information'), 'config' => []],
                ['type' => ItemTypes::DROPDOWN_PARENT,
                 'label' => self::label('navsupport', 'Support'),
                 'config' => ['icon' => 'life-buoy'],
                 'children' => [
                    self::whmcsPage('contact',       'envelope'),
                    self::whmcsPage('serverstatus',  'status'),
                    self::whmcsPage('knowledgebase', 'book'),
                    self::whmcsPage('announcements', 'megaphone'),
                 ]],

                ['type' => ItemTypes::LOGIN_BUTTON, 'label' => self::label('login', 'Login'),
                 'config' => ['position_side' => 'right', 'style' => 'primary', 'icon' => 'transfer']],
                ['type' => ItemTypes::WHMCS_PAGE,
                 'label' => self::label('register', 'Register'),
                 'config' => ['page' => 'clientregister', 'position_side' => 'right', 'icon' => 'user']],
                ['type' => ItemTypes::LANGUAGE, 'label' => self::label('chooselanguage', 'Language'),
                 'config' => ['position_side' => 'right', 'icon' => 'globe']],
            ],
        ];
    }

    /**
     * Footer menu — pre-seeded from the apple-client-area sitelock-vpn
     * homepage-style landing footer (5 columns of links). Audience is 'all'
     * because the footer renders for both logged-in clients and guests.
     *
     * Columns are dropdown_parent items (label = column title, children =
     * the links). HEADER doesn't accept children, and the footer renderer
     * walks the same tree shape as the sidebar — DROPDOWN_PARENT is the
     * only built-in container that maps cleanly to "column with items".
     *
     * Link targets prefer whmcs_page when the linked page maps to a known
     * templatefile (so URLs flow through WhmcsDefaults and stay consistent
     * with the rest of the menu system). Items the WHMCS install doesn't
     * own — Newsroom, Careers, Legal, Community — stay as custom_link with
     * a placeholder href so admins can wire them up in the builder.
     */
    private static function footerDefaults(): array
    {
        return [
            'name'     => 'Footer Menu',
            'location' => 'footer',
            'audience' => 'all',
            'active'   => true,
            'items'    => [
                ['type' => ItemTypes::DROPDOWN_PARENT,
                 'label' => self::label('', 'Shop & Learn'),
                 'config' => [],
                 'children' => [
                    self::customLink('', 'Cloud Hosting',     'cart.php?gid=shared'),
                    self::customLink('', 'VPS',               'cart.php?gid=vps'),
                    self::customLink('', 'Dedicated Servers', 'cart.php?gid=dedicated'),
                    self::customLink('', 'Domains',           'cart.php?a=add&domain=register'),
                    self::whmcsPage('store-ssl'),
                    self::customLink('', 'Email',             'cart.php?gid=email'),
                 ]],

                ['type' => ItemTypes::DROPDOWN_PARENT,
                 'label' => self::label('', 'Security & Tools'),
                 'config' => [],
                 'children' => [
                    self::whmcsPage('store-ssl'),
                    ['type' => ItemTypes::WHMCS_PAGE,
                     'label' => self::label('', 'Email Services'),
                     'config' => ['page' => 'store-spamexperts']],
                    self::whmcsPage('store-sitelock'),
                    self::whmcsPage('store-codeguard'),
                    self::whmcsPage('store-marketgoo'),
                    self::customLink('', 'XOVI Now', '#'),
                    ['type' => ItemTypes::WHMCS_PAGE,
                     'label' => self::label('', '360 Monitoring'),
                     'config' => ['page' => 'store-threesixtymonitoring']],
                    self::whmcsPage('store-sitelockvpn'),
                    ['type' => ItemTypes::WHMCS_PAGE,
                     'label' => self::label('', 'NordVPN'),
                     'config' => ['page' => 'store-nordvpn']],
                    self::whmcsPage('store-socialbee'),
                 ]],

                ['type' => ItemTypes::DROPDOWN_PARENT,
                 'label' => self::label('accounttab', 'Account'),
                 'config' => [],
                 'children' => [
                    ['type' => ItemTypes::WHMCS_PAGE,
                     'label' => self::label('login', 'Sign in'),
                     'config' => ['page' => 'login']],
                    ['type' => ItemTypes::WHMCS_PAGE,
                     'label' => self::label('createaccount', 'Create an account'),
                     'config' => ['page' => 'clientregister']],
                    ['type' => ItemTypes::WHMCS_PAGE,
                     'label' => self::label('billingtab', 'Billing'),
                     'config' => ['page' => 'clientareainvoices']],
                    self::customLink('', 'Refer a friend', 'affiliates.php'),
                 ]],

                ['type' => ItemTypes::DROPDOWN_PARENT,
                 'label' => self::label('navsupport', 'Support'),
                 'config' => [],
                 'children' => [
                    self::whmcsPage('knowledgebase'),
                    ['type' => ItemTypes::WHMCS_PAGE,
                     'label' => self::label('contactus', 'Contact us'),
                     'config' => ['page' => 'contact']],
                    ['type' => ItemTypes::WHMCS_PAGE,
                     'label' => self::label('networkstatus', 'Network status'),
                     'config' => ['page' => 'serverstatus']],
                    self::customLink('', 'Community', '#'),
                 ]],

                ['type' => ItemTypes::DROPDOWN_PARENT,
                 'label' => self::label('', 'About WHMCS'),
                 'config' => [],
                 'children' => [
                    self::customLink('', 'Newsroom',    '#'),
                    self::customLink('', 'Careers',     '#'),
                    self::customLink('', 'Legal',       '#'),
                    self::customLink('', 'Environment', '#'),
                 ]],
            ],
        ];
    }
}
