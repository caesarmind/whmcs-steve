<?php
return [
    'display_name' => 'Default',
    'description'  => 'Category view — sub-nav + in-category search + article-row list.',
    'preview'      => 'thumb.png',
    'settings'     => [
        'showSearch' => [
            'type'    => 'checkbox',
            'name'    => 'showSearch',
            'label'   => 'Show in-category search',
            'default' => true,
            'tooltip' => 'Renders the search input above the article-row list (posts to the same page with ?search=).',
        ],
        'showSubcategories' => [
            'type'    => 'checkbox',
            'name'    => 'showSubcategories',
            'label'   => 'Show sub-categories',
            'default' => true,
            'tooltip' => 'Renders any direct child categories above the article list.',
        ],
    ],
];
