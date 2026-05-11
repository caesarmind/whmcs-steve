<?php
/**
 * Page-level metadata for announcements (Announcements list).
 *
 * Read by:
 *   - PageController (admin UI for selecting variants and editing pageoptions)
 *   - Hooks::resolveCurrentPage at render time
 */
return [
    'display_name' => 'Announcements',
    'group'        => 'Support',
    'type'         => 'public',
    'listDisplay'  => true,
    'description'  => 'Public announcements list — product updates, network notices, news.',
];
