<?php
/**
 * Page-level metadata for the legacy /clientarea.php?action=users URL.
 *
 * Forwards to the canonical account-user-management implementation but
 * exposes a separate Pages-tab entry so admins can set variant, SEO and
 * layout overrides for this WHMCS templatefile independently.
 */
return [
    'display_name'   => 'Users (legacy URL)',
    'group'          => 'Account',
    'type'           => 'client-portal',
    'listDisplay'    => true,
    'description'    => 'Legacy URL alias for account-user-management.',
    'defaultVariant' => 'default',
    'seoDefaults'    => [
        'indexing' => 'disallow',
    ],
];
