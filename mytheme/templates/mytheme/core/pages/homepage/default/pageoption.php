<?php
/**
 * Per-variant settings for homepage/default (the marketing landing).
 *
 * Apple "Hosting, redesigned" public homepage: marketing hero with a working
 * domain search, then stats, cPanel comparison, isolation, OpenPanel spotlight,
 * data centers, white-label/dev tools, audience columns, pricing, reviews, CTA.
 * (The previous domain-search portal homepage is preserved as the 'portal'
 * variant — switch to it in the admin Pages tab.)
 *
 * Read at runtime as $myTheme.pages.homepage.config.<key>
 */
return [
    'display_name' => 'Marketing landing',
    'description'  => 'Apple-style hosting marketing homepage (hero + domain search, pricing, reviews).',
    'settings'     => [
        'heroTitle' => [
            'type'    => 'text',
            'name'    => 'heroTitle',
            'label'   => 'Hero title',
            'default' => '',
            'tooltip' => 'Override the big hero heading. Leave blank to use the default ("Hosting, redesigned.").',
        ],
        'heroSubtitle' => [
            'type'    => 'text',
            'name'    => 'heroSubtitle',
            'label'   => 'Hero subtitle',
            'default' => '',
            'tooltip' => 'Override the tagline under the hero heading. Leave blank to use the default.',
        ],
    ],
];
