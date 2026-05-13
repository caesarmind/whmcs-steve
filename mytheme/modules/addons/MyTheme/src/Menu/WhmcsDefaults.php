<?php
declare(strict_types=1);

namespace MyTheme\Menu;

/**
 * Single source of truth mapping a WHMCS templatefile to:
 *   - lang_key      — WHMCS lang/english.php nav* key for the label
 *   - default_label — English fallback label when no lang key is set
 *   - url           — the actual URL WHMCS routes that templatefile through
 *
 * Used by:
 *   - Menu builder page picker → auto-fill label.whmcs + label.custom.english
 *     when admin picks a well-known page
 *   - TreeRenderer::resolvePageUrl → render-time URL resolution for
 *     whmcs_page menu items (replaces the old hardcoded fallback table)
 *   - Presets → seeded WHMCS Defaults menu uses whmcs_page type with
 *     these names instead of custom_link + raw URL
 *
 * Lang keys are stable across WHMCS 7 → 9 — sourced from
 * lang/english.php's nav* entries.
 */
final class WhmcsDefaults
{
    /**
     * @return array<string, array{lang_key:string, default_label:string, url:string}>
     */
    public static function all(): array
    {
        return [
            // Core client area
            'clientareahome'       => ['lang_key' => 'navhome',           'default_label' => 'Home',              'url' => 'clientarea.php'],
            'clientareaproducts'   => ['lang_key' => 'navservices',       'default_label' => 'My Services',       'url' => 'clientarea.php?action=services'],
            'clientareadomains'    => ['lang_key' => 'navdomains',        'default_label' => 'My Domains',        'url' => 'clientarea.php?action=domains'],
            'clientareainvoices'   => ['lang_key' => 'navinvoices',       'default_label' => 'My Invoices',       'url' => 'clientarea.php?action=invoices'],
            'clientareaquotes'     => ['lang_key' => 'navquotes',         'default_label' => 'Quotes',            'url' => 'clientarea.php?action=quotes'],
            'clientareadetails'    => ['lang_key' => 'navmyaccount',      'default_label' => 'My Details',        'url' => 'clientarea.php?action=details'],
            'clientareasecurity'   => ['lang_key' => 'navsecurity',       'default_label' => 'Security Settings', 'url' => 'clientarea.php?action=security'],
            'clientareaemails'     => ['lang_key' => 'navemails',         'default_label' => 'Email History',     'url' => 'clientarea.php?action=emails'],
            'clientareaaddfunds'   => ['lang_key' => 'navaddfunds',       'default_label' => 'Add Funds',         'url' => 'clientarea.php?action=addfunds'],
            'masspay'              => ['lang_key' => 'navmasspay',        'default_label' => 'Mass Payment',      'url' => 'clientarea.php?action=masspay'],
            'managessl'            => ['lang_key' => '',                  'default_label' => 'Manage SSL Certificates', 'url' => 'clientarea.php?action=ssl'],

            // Support
            'supportticketslist'   => ['lang_key' => 'navtickets',        'default_label' => 'Tickets',           'url' => 'supporttickets.php'],
            'supporttickets'       => ['lang_key' => 'navtickets',        'default_label' => 'Tickets',           'url' => 'supporttickets.php'],
            'supportticketsubmit'  => ['lang_key' => 'navsubmitticket',   'default_label' => 'Open Ticket',       'url' => 'submitticket.php'],
            'submitticket'         => ['lang_key' => 'navsubmitticket',   'default_label' => 'Open Ticket',       'url' => 'submitticket.php'],
            'announcements'        => ['lang_key' => 'navannouncements',  'default_label' => 'Announcements',     'url' => 'announcements.php'],
            'knowledgebase'        => ['lang_key' => 'navknowledgebase',  'default_label' => 'Knowledgebase',     'url' => 'knowledgebase.php'],
            'downloads'            => ['lang_key' => 'navdownloads',      'default_label' => 'Downloads',         'url' => 'downloads.php'],
            'serverstatus'         => ['lang_key' => 'navnetworkissues', 'default_label' => 'Network Status',     'url' => 'serverstatus.php'],

            // Public
            'contact'              => ['lang_key' => 'navcontact',        'default_label' => 'Contact Us',        'url' => 'contact.php'],
            'homepage'             => ['lang_key' => 'navhomepage',      'default_label' => 'Home',               'url' => '/'],

            // Authentication
            'login'                => ['lang_key' => 'navlogin',          'default_label' => 'Login',             'url' => 'login.php'],
            'clientregister'       => ['lang_key' => 'navregister',       'default_label' => 'Register',          'url' => 'register.php'],

            // Account / profile (canonical + legacy URL aliases)
            'user-password'           => ['lang_key' => 'navchangepassword', 'default_label' => 'Change Password', 'url' => 'clientarea.php?action=changepw'],
            'changepassword'          => ['lang_key' => 'navchangepassword', 'default_label' => 'Change Password', 'url' => 'clientarea.php?action=changepw'],
            'changepw'                => ['lang_key' => 'navchangepassword', 'default_label' => 'Change Password', 'url' => 'clientarea.php?action=changepw'],
            'account-contacts-manage' => ['lang_key' => 'navcontacts',       'default_label' => 'Contacts',        'url' => 'clientarea.php?action=contacts'],
            'clientareacontacts'      => ['lang_key' => 'navcontacts',       'default_label' => 'Contacts',        'url' => 'clientarea.php?action=contacts'],
            'account-user-management' => ['lang_key' => 'navusers',          'default_label' => 'Users',           'url' => 'clientarea.php?action=users'],
            'clientareausers'         => ['lang_key' => 'navusers',          'default_label' => 'Users',           'url' => 'clientarea.php?action=users'],
            'account-paymentmethods'  => ['lang_key' => 'navpaymentmethods', 'default_label' => 'Payment Methods', 'url' => 'clientarea.php?action=paymentmethods'],

            // Shop / MarketConnect landing pages. Slugs match Nexus's
            // templates/nexus/store/<slug>/ directory naming so WHMCS routes
            // /store/<slug> straight to our index.tpl dispatcher.
            'store-sitelock'             => ['lang_key' => '', 'default_label' => 'Website Security',          'url' => 'store/sitelock'],
            'store-sitelockvpn'          => ['lang_key' => '', 'default_label' => 'SiteLock VPN',              'url' => 'store/sitelockvpn'],
            'store-socialbee'            => ['lang_key' => '', 'default_label' => 'SocialBee',                 'url' => 'store/socialbee'],
            'store-ssl'                  => ['lang_key' => '', 'default_label' => 'SSL Certificates',          'url' => 'store/ssl'],
            'store-threesixtymonitoring' => ['lang_key' => '', 'default_label' => 'Site & Server Monitoring', 'url' => 'store/threesixtymonitoring'],
            'store-nordvpn'              => ['lang_key' => '', 'default_label' => 'VPN',                       'url' => 'store/nordvpn'],
            'store-spamexperts'          => ['lang_key' => '', 'default_label' => 'E-mail Services',           'url' => 'store/spamexperts'],
            'store-ox'                   => ['lang_key' => '', 'default_label' => 'Professional Email',        'url' => 'store/ox'],
            'store-sitebuilder'          => ['lang_key' => '', 'default_label' => 'Site Builder',              'url' => 'store/sitebuilder'],
            'store-marketgoo'            => ['lang_key' => '', 'default_label' => 'SEO Tools',                 'url' => 'store/marketgoo'],
            'store-codeguard'            => ['lang_key' => '', 'default_label' => 'Website Backup',            'url' => 'store/codeguard'],
            'store-weebly'               => ['lang_key' => '', 'default_label' => 'Website Builder',           'url' => 'store/weebly'],
            'store-order'                => ['lang_key' => '', 'default_label' => 'Order summary',             'url' => 'store/order'],
            'store-not-found'            => ['lang_key' => '', 'default_label' => 'Store page not found',      'url' => 'store/not-found'],
        ];
    }

    /**
     * Look up the defaults for a templatefile.
     *
     * @return array{lang_key:string, default_label:string, url:string}|null
     */
    public static function lookup(string $page): ?array
    {
        return self::all()[$page] ?? null;
    }
}
