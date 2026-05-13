<?php
/**
 * Page-level metadata for the supportticketsubmit-steptwo templatefile.
 *
 * WHMCS routes /submitticket.php step 2 through this templatefile name.
 * Forwards to the canonical supportticketsubmit implementation but exposes a
 * separate Pages-tab entry so admins can set variant, SEO and layout
 * overrides for this step independently.
 */
return [
    'display_name'   => 'Submit ticket — Step 2: confirm',
    'group'          => 'Support',
    'type'           => 'public',
    'listDisplay'    => true,
    'description'    => 'Step 2 of the submit-ticket flow — visitor reviews custom fields and confirms.',
    'defaultVariant' => 'default',
    'seoDefaults'    => [
        'indexing' => 'disallow',
    ],
];
