<?php
/**
 * Page-level metadata for login.
 *
 * Read by:
 *   - PageController (admin UI for selecting variants and editing pageoptions)
 *   - Hooks::resolveCurrentPage at render time
 */
return [
    'display_name' => 'Sign in',
    'group'        => 'Authentication',
    'type'         => 'public',
    'listDisplay'  => true,
    'description'  => 'Logged-out client area login form (also rendered for /login.php).',
];
