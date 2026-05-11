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
    'type'         => 'public',
    'listDisplay'  => true,
    'description'  => 'Single-announcement article view with category chip, body, and back/share footer.',
];
