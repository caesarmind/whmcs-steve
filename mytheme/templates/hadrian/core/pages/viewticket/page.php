<?php
/**
 * Page-level metadata for viewticket (View Support Ticket).
 *
 * Read by:
 *   - PageController (admin UI for selecting variants and editing pageoptions)
 *   - Hooks::resolveCurrentPage at render time
 */
return [
    'display_name' => 'View Ticket',
    'group'        => 'Support',
    'type'         => 'client-portal',
    'listDisplay'  => true,
    'description'  => 'Single-ticket conversation view with reply composer and sidebar ticket info.',
];
