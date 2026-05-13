<?php
declare(strict_types=1);

namespace MyTheme\Menu;

/**
 * Static map of WHMCS templatefile → standard menu lang key + default label.
 *
 * Used by the menu builder's page picker to auto-populate label.whmcs (the
 * WHMCS lang-key reference) and label.custom.english (the fallback when the
 * lang key resolves to nothing) when an admin picks one of WHMCS's well-known
 * navbar destinations. Pages outside this list still appear in the picker;
 * they just don't get an auto-label.
 *
 * Lang keys are stable across WHMCS 7 → 9 — sourced from
 * lang/english.php's `nav*` entries.
 */
final class WhmcsDefaults
{
    /**
     * @return array<string, array{lang_key:string, default_label:string}>
     */
    public static function all(): array
    {
        return [
            // Core client area
            'clientareahome'       => ['lang_key' => 'navhome',           'default_label' => 'Home'],
            'clientareaproducts'   => ['lang_key' => 'navservices',       'default_label' => 'My Services'],
            'clientareadomains'    => ['lang_key' => 'navdomains',        'default_label' => 'My Domains'],
            'clientareainvoices'   => ['lang_key' => 'navinvoices',       'default_label' => 'My Invoices'],
            'clientareaquotes'     => ['lang_key' => 'navquotes',         'default_label' => 'Quotes'],
            'clientareadetails'    => ['lang_key' => 'navmyaccount',      'default_label' => 'My Details'],
            'clientareasecurity'   => ['lang_key' => 'navsecurity',       'default_label' => 'Security Settings'],
            'clientareaemails'     => ['lang_key' => 'navemails',         'default_label' => 'Email History'],
            'clientareaaddfunds'   => ['lang_key' => 'navaddfunds',       'default_label' => 'Add Funds'],

            // Support
            'supportticketslist'   => ['lang_key' => 'navtickets',        'default_label' => 'Tickets'],
            'supporttickets'       => ['lang_key' => 'navtickets',        'default_label' => 'Tickets'],
            'supportticketsubmit'  => ['lang_key' => 'navsubmitticket',   'default_label' => 'Open Ticket'],
            'submitticket'         => ['lang_key' => 'navsubmitticket',   'default_label' => 'Open Ticket'],
            'announcements'        => ['lang_key' => 'navannouncements',  'default_label' => 'Announcements'],
            'knowledgebase'        => ['lang_key' => 'navknowledgebase',  'default_label' => 'Knowledgebase'],
            'downloads'            => ['lang_key' => 'navdownloads',      'default_label' => 'Downloads'],
            'serverstatus'         => ['lang_key' => 'navnetworkissues', 'default_label' => 'Network Status'],

            // Public
            'contact'              => ['lang_key' => 'navcontact',        'default_label' => 'Contact Us'],
            'homepage'             => ['lang_key' => 'navhomepage',      'default_label' => 'Home'],

            // Authentication
            'login'                => ['lang_key' => 'navlogin',          'default_label' => 'Login'],
            'clientregister'       => ['lang_key' => 'navregister',       'default_label' => 'Register'],

            // Account / profile
            'user-password'        => ['lang_key' => 'navchangepassword', 'default_label' => 'Change Password'],
            'changepassword'       => ['lang_key' => 'navchangepassword', 'default_label' => 'Change Password'],
            'changepw'             => ['lang_key' => 'navchangepassword', 'default_label' => 'Change Password'],
            'account-contacts-manage' => ['lang_key' => 'navcontacts',    'default_label' => 'Contacts'],
            'clientareacontacts'   => ['lang_key' => 'navcontacts',       'default_label' => 'Contacts'],
            'account-user-management' => ['lang_key' => 'navusers',       'default_label' => 'Users'],
            'clientareausers'      => ['lang_key' => 'navusers',          'default_label' => 'Users'],

            // Billing
            'masspay'              => ['lang_key' => 'navmasspay',        'default_label' => 'Mass Payment'],
        ];
    }

    /**
     * Look up the defaults for a templatefile.
     *
     * @return array{lang_key:string, default_label:string}|null
     */
    public static function lookup(string $page): ?array
    {
        return self::all()[$page] ?? null;
    }
}
