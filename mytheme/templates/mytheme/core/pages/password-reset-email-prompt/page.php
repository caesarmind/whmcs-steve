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
    // Hidden from the admin Pages grid — include-only step dispatcher that forwards
    // to the shared pwreset implementation. The single "Password Reset" (pwreset)
    // row represents the whole flow. Still renders + editable via direct edit URL.
    'listDisplay'    => false,
    'description'    => 'Step 1 of the password reset flow — visitor enters their email address.',
    'defaultVariant' => 'default',
    'seoDefaults'    => [
        'indexing' => 'disallow',
        'title'    => 'Reset your password',
    ],
];
