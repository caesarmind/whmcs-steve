<?php
/**
 * Page-level metadata for the legacy /changepassword URL.
 *
 * Forwards to the canonical user-password implementation but exposes a
 * separate Pages-tab entry so admins can set variant, SEO and layout
 * overrides for this WHMCS templatefile independently.
 */
return [
    'display_name'   => 'Change password (legacy URL)',
    'group'          => 'Account',
    'type'           => 'client-portal',
    'listDisplay'    => true,
    'description'    => 'Legacy /changepassword URL — same form as user-password.',
    'defaultVariant' => 'default',
    'seoDefaults'    => [
        'indexing' => 'disallow',
    ],
];
