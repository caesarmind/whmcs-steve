<?php
/**
 * Per-variant settings for homepage/default.
 *
 * Read at runtime as $myTheme.pages.homepage.config.<key>
 */
return [
    'display_name' => 'Default',
    'description'  => 'Hero heading + sign-in / open-account CTAs and quick-link grid.',
    'preview'      => 'thumb.png',
    'settings'     => [
        'heroTitle' => [
            'type'    => 'text',
            'name'    => 'heroTitle',
            'label'   => 'Hero title',
            'default' => '',
            'tooltip' => 'Override the hero heading. Leave blank to fall back to the company name.',
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
            'tooltip' => 'Renders the four-tile quick-link grid below the hero (Services / Support / Knowledgebase / Network status).',
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
