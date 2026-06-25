<?php
/**
 * Page-level metadata for clientareasecurity (Security Settings).
 *
 * Read by:
 *   - PageController (admin UI for selecting variants and editing pageoptions)
 *   - Hooks::resolveCurrentPage at render time
 */
return [
    'display_name' => 'Security Settings',
    'group'        => 'Client Area',
    'type'         => 'client-portal',
    'listDisplay'  => true,
    'description'  => 'Two-factor authentication, login alerts and active sessions.',
];
