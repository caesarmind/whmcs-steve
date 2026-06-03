<?php
/**
 * Page-level metadata for the password-reset-change-prompt templatefile.
 *
 * WHMCS routes /pwreset.php step 3 through this templatefile name. Forwards
 * to the canonical pwreset implementation but exposes a separate Pages-tab
 * entry so admins can set variant, SEO and layout overrides for this step
 * independently.
 */
return [
    'display_name'   => 'Password reset — Step 3: new password',
    'group'          => 'Authentication',
    'type'           => 'public',
    // Hidden from the admin Pages grid — include-only step dispatcher that forwards
    // to the shared pwreset implementation. The single "Password Reset" (pwreset)
    // row represents the whole flow. Still renders + editable via direct edit URL.
    'listDisplay'    => false,
    'description'    => 'Step 3 of the password reset flow — visitor picks a new password.',
    'defaultVariant' => 'default',
    'seoDefaults'    => [
        'indexing' => 'disallow',
        'title'    => 'Choose a new password',
    ],
];
