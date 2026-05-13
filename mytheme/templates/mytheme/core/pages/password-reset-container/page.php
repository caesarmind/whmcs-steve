<?php
/**
 * Page-level metadata for the password-reset-container templatefile.
 *
 * WHMCS routes /pwreset.php landing through this templatefile name. Forwards
 * to the canonical pwreset implementation but exposes a separate Pages-tab
 * entry so admins can set variant, SEO and layout overrides for the landing
 * state independently from the email-prompt / security-prompt / change-prompt
 * steps.
 */
return [
    'display_name'   => 'Password reset — Landing',
    'group'          => 'Authentication',
    'type'           => 'public',
    'listDisplay'    => true,
    'description'    => 'WHMCS /pwreset.php landing — wrapper / status after submitting email.',
    'defaultVariant' => 'default',
    'seoDefaults'    => [
        'indexing'    => 'disallow',
        'title'       => 'Reset your password',
        'description' => 'Reset your account password.',
    ],
];
