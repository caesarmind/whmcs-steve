<?php
/**
 * Page-level metadata for the custom page.
 *
 * Read by the admin Pages tab (SEO/variant/visibility/layout editor) and by
 * Hooks::resolveCurrentPage at render time. The page is auto-discovered from
 * this directory; no code registration is required beyond these files.
 */
return [
    'display_name' => 'Custom Page',
    'group'        => 'Public',
    'type'         => 'public',
    'listDisplay'  => true,
    'description'  => 'Example custom page: theme header + footer, fully custom content inside.',
    'seoDefaults'  => [
        'indexing'    => 'allow',
        'title'       => 'Custom Page',
        'description' => 'A custom page built on the Hostnodes theme.',
    ],
];
