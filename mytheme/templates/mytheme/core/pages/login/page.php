<?php
/**
 * Page-level metadata for login.
 *
 * Read by:
 *   - PagesController (admin UI for picking variants and editing per-page options)
 *   - Hooks::resolveCurrentPage at render time
 *
 * Required fields (kept for compatibility with existing tools):
 *   display_name, group, type, description, listDisplay
 *
 * Optional fields (the admin Pages editor surfaces them when present):
 *   defaultVariant   — variant when admin hasn't picked one
 *   supportedOptions — keyed map of option specs the editor renders
 *   seoDefaults      — fallback values when no admin override exists
 *
 * Fields default sensibly when absent; only declare what differs from defaults.
 */
return [
    'display_name'  => 'Sign in',
    'group'         => 'Authentication',
    'type'          => 'public',
    'listDisplay'   => true,
    'description'   => 'Logged-out client area login form (also rendered for /login.php).',

    'defaultVariant' => 'default',

    'supportedOptions' => [
        'full_page' => [
            'type'    => 'bool',
            'label'   => 'Full Page',
            'help'    => 'Hide the standard navbar and footer.',
            'default' => false,
        ],
        'show_logo' => [
            'type'    => 'bool',
            'label'   => 'Show Logo',
            'help'    => 'Show the brand logo at the top of the page.',
            'default' => true,
        ],
    ],

    'seoDefaults' => [
        'indexing'    => 'allow',
        'title'       => 'Sign in — Client Area',
        'description' => 'Sign in to manage your services, billing and support.',
    ],
];
