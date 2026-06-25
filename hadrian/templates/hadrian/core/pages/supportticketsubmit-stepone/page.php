<?php
/**
 * Page-level metadata for the supportticketsubmit-stepone templatefile.
 *
 * WHMCS routes /submitticket.php step 1 through this templatefile name.
 * Forwards to the canonical supportticketsubmit implementation but exposes a
 * separate Pages-tab entry so admins can set variant, SEO and layout
 * overrides for this step independently.
 */
return [
    'display_name'   => 'Submit ticket — Step 1: department',
    'group'          => 'Support',
    'type'           => 'public',
    'listDisplay'    => true,
    'description'    => 'Step 1 of the submit-ticket flow — visitor picks a department and fills the initial form.',
    'defaultVariant' => 'default',
    'seoDefaults'    => [
        'indexing' => 'disallow',
    ],
];
