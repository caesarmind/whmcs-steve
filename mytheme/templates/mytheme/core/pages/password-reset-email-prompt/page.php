<?php
/**
 * Page-level metadata for the password-reset-email-prompt templatefile.
 *
 * WHMCS routes /pwreset.php step 1 through this templatefile name. Forwards
 * to the canonical pwreset implementation but exposes a separate Pages-tab
 * entry so admins can set variant, SEO and layout overrides for this step
 * independently.
 */
return [
    'display_name'   => 'Password reset — Step 1: email',
    'group'          => 'Authentication',
    'type'           => 'public',
    'listDisplay'    => true,
    'description'    => 'Step 1 of the password reset flow — visitor enters their email address.',
    'defaultVariant' => 'default',
    'seoDefaults'    => [
        'indexing' => 'disallow',
        'title'    => 'Reset your password',
    ],
];
