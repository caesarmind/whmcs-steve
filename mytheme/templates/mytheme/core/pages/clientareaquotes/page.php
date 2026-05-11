<?php
/**
 * Page-level metadata for clientareaquotes (My Quotes).
 *
 * Read by:
 *   - PageController (admin UI for selecting variants and editing pageoptions)
 *   - Hooks::resolveCurrentPage at render time
 */
return [
    'display_name' => 'My Quotes',
    'group'        => 'Billing',
    'type'         => 'client-portal',
    'listDisplay'  => true,
    'description'  => 'Logged-in quotes list — proposals delivered by sales, sortable, with status filter.',
];
