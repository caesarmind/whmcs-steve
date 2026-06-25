<?php
/**
 * Page-level metadata for homepage.
 *
 * Read by:
 *   - PageController (admin UI for selecting variants and editing pageoptions)
 *   - Hooks::resolveCurrentPage at render time
 */
return [
    'display_name' => 'Homepage',
    'group'        => 'Public',
    'type'         => 'public',
    'listDisplay'  => true,
    'description'  => 'Public landing rendered when /index.php is hit (logged-in users go to dashboard).',
];
