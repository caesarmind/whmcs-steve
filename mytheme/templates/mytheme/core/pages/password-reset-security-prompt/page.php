<?php
/**
 * Page-level metadata for the password-reset-security-prompt templatefile.
 *
 * WHMCS routes /pwreset.php step 2 through this templatefile name. Forwards
 * to the canonical pwreset implementation but exposes a separate Pages-tab
 * entry so admins can set variant, SEO and layout overrides for this step
 * independently.
 */
return [
    'display_name'   => 'Password reset — Step 2: security question',
    'group'          => 'Authentication',
    'type'           => 'public',
    'listDisplay'    => true,
    'description'    => 'Step 2 of the password reset flow — visitor answers a security question.',
    'defaultVariant' => 'default',
    'seoDefaults'    => [
        'indexing' => 'disallow',
        'title'    => 'Reset your password — security question',
    ],
];
