<?php
/**
 * Page-level metadata for clientareadetails (Account Details).
 *
 * Read by:
 *   - PageController (admin UI for selecting variants and editing pageoptions)
 *   - Hooks::resolveCurrentPage at render time
 */
return [
    'display_name' => 'Account Details',
    'group'        => 'Client Area',
    'type'         => 'client-portal',
    'listDisplay'  => true,
    'description'  => 'Account settings — personal info, billing address and email preferences.',
];
