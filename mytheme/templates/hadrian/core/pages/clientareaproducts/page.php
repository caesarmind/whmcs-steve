<?php
/**
 * Page-level metadata for clientareaproducts (My Products & Services).
 *
 * Read by:
 *   - PageController (admin UI for selecting variants and editing pageoptions)
 *   - Hooks::resolveCurrentPage at render time
 */
return [
    'display_name' => 'My Services',
    'group'        => 'Client Area',
    'type'         => 'client-portal',
    'listDisplay'  => true,
    'description'  => 'Logged-in services list — filter by status, search, and manage products.',
];
