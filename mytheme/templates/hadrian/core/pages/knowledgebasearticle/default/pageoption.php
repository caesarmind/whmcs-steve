<?php
return [
    'display_name' => 'Default',
    'description'  => 'Article view with helpful vote (Yes/No), popular articles sidebar, related rows.',
    'preview'      => 'thumb.png',
    'settings'     => [
        'showHelpful' => [
            'type'    => 'checkbox',
            'name'    => 'showHelpful',
            'label'   => 'Show "Was this helpful?" voting',
            'default' => true,
            'tooltip' => 'Renders the Yes / No vote buttons + cumulative count under the article body.',
        ],
        'showRelated' => [
            'type'    => 'checkbox',
            'name'    => 'showRelated',
            'label'   => 'Show related articles',
            'default' => true,
            'tooltip' => 'Renders the related-articles list at the bottom of the article card.',
        ],
        'showPopularAside' => [
            'type'    => 'checkbox',
            'name'    => 'showPopularAside',
            'label'   => 'Show popular articles in sidebar',
            'default' => true,
            'tooltip' => 'Renders the "Most popular" list in the left aside, alongside the support sub-nav.',
        ],
    ],
];
