<?php
/**
 * Page-level metadata for the legacy /clientarea.php?action=contacts URL.
 *
 * Forwards to the canonical account-contacts-manage implementation but
 * exposes a separate Pages-tab entry so admins can set variant, SEO and
 * layout overrides for this WHMCS templatefile independently.
 */
return [
    'display_name'   => 'Contacts (legacy URL)',
    'group'          => 'Account',
    'type'           => 'client-portal',
    'listDisplay'    => true,
    'description'    => 'Legacy URL alias for account-contacts-manage.',
    'defaultVariant' => 'default',
    'seoDefaults'    => [
        'indexing' => 'disallow',
    ],
];
