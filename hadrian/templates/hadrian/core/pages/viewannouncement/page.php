<?php
/**
 * Page-level metadata for viewannouncement (View Announcement).
 *
 * Read by:
 *   - PageController (admin UI for selecting variants and editing pageoptions)
 *   - Hooks::resolveCurrentPage at render time
 */
return [
    'display_name' => 'View Announcement',
    'group'        => 'Support',
    // Read by visitors who have not signed in, so it sits with the website
    // when layouts are chosen by area.
    'area'         => 'website',
    'type'         => 'public',
    'listDisplay'  => true,
    'description'  => 'Single-announcement article view with category chip, body, and back/share footer.',
];
