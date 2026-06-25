<?php
/**
 * Per-variant settings for homepage/portal.
 *
 * The original Apple "portal-style" homepage: domain-search hero + quick-link
 * grids (products, self-service, account). Preserved as a switchable variant
 * when the marketing landing became the default. Select it in the admin
 * Pages tab to restore the portal homepage.
 *
 * Read at runtime as $hadrian.pages.homepage.config.<key>
 */
return [
    'display_name' => 'Portal',
    'description'  => 'Domain-search hero + quick-link grids (products, self-service, account).',
    'settings'     => [
        'heroTitle' => [
            'type'    => 'text',
            'name'    => 'heroTitle',
            'label'   => 'Hero title',
            'default' => '',
            'tooltip' => 'Override the hero heading. Leave blank to fall back to the default.',
        ],
        'heroSubtitle' => [
            'type'    => 'text',
            'name'    => 'heroSubtitle',
            'label'   => 'Hero subtitle',
            'default' => 'Manage your services, domains and billing in one place.',
            'tooltip' => 'Short tagline rendered under the hero title.',
        ],
        'showQuickLinks' => [
            'type'    => 'checkbox',
            'name'    => 'showQuickLinks',
            'label'   => 'Show quick-link grid',
            'default' => true,
            'tooltip' => 'Renders the quick-link grids below the hero.',
        ],
        'showAnnouncements' => [
            'type'    => 'checkbox',
            'name'    => 'showAnnouncements',
            'label'   => 'Show recent announcements',
            'default' => true,
            'tooltip' => 'Lists up to three latest announcements at the bottom of the page.',
        ],
    ],
];
