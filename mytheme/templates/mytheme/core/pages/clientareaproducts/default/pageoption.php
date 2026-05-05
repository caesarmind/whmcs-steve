<?php
/**
 * Per-variant settings for clientareaproducts/default.
 *
 * Read at runtime as $myTheme.pages.clientareaproducts.config.<key>
 */
return [
    'display_name' => 'Default',
    'description'  => 'Service grid with status filters sidebar and Apple-style cards.',
    'preview'      => 'thumb.png',
    'settings'     => [
        'viewMode' => [
            'type'    => 'select',
            'name'    => 'viewMode',
            'label'   => 'View mode',
            'default' => 'grid',
            'options' => ['grid', 'list'],
            'tooltip' => 'Grid = card layout (3 across). List = compact rows with manage button.',
        ],
        'gridCols' => [
            'type'    => 'select',
            'name'    => 'gridCols',
            'label'   => 'Grid columns',
            'default' => '3',
            'options' => ['2', '3', '4'],
            'tooltip' => 'How many cards per row at desktop width (only applies to grid view).',
        ],
        'showFilters' => [
            'type'    => 'checkbox',
            'name'    => 'showFilters',
            'label'   => 'Show status filters',
            'default' => true,
            'tooltip' => 'Renders the status filter card (All / Active / Pending / Suspended …) in the left aside.',
        ],
        'showActions' => [
            'type'    => 'checkbox',
            'name'    => 'showActions',
            'label'   => 'Show actions card',
            'default' => true,
            'tooltip' => 'Renders the "Place a new order / View available addons" links in the left aside.',
        ],
        'showSearch' => [
            'type'    => 'checkbox',
            'name'    => 'showSearch',
            'label'   => 'Show search bar',
            'default' => true,
            'tooltip' => 'Renders the search input in the toolbar above the service grid.',
        ],
        'showPromo' => [
            'type'    => 'checkbox',
            'name'    => 'showPromo',
            'label'   => 'Show promo slider',
            'default' => false,
            'tooltip' => 'Renders the promo slider below the filter cards.',
        ],
    ],
];
