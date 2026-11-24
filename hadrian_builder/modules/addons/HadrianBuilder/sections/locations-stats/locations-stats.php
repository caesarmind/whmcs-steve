<?php
/**
 * A dark band about network reach: a row of region names with status dots
 * above a row of figures.
 * Markup and classes: the theme's hp-locations-visual block.
 */
return [
    'label'  => 'Locations with numbers',
    'hint'   => 'Region names above a row of figures',
    'group'  => 'Locations',
    'order'  => 430,
    'fields' => [
        ['key' => 'title', 'type' => 'text', 'label' => 'Heading', 'translatable' => true, 'default' => ['_' => 'Close to your visitors']],
        ['key' => 'subtitle', 'type' => 'text', 'label' => 'Subheading', 'translatable' => true,
            'default' => ['_' => 'Our network answers each request from a region nearby.']],
        ['key' => 'regions', 'type' => 'lines', 'label' => 'Regions', 'translatable' => true,
            'default' => ['_' => "North America\nEurope\nAsia\nOceania"],
            'help' => 'One region per line. Each is shown with a green dot.'],
        ['key' => 'stats', 'type' => 'list', 'label' => 'Figures', 'max' => 6, 'itemLabel' => 'label', 'addLabel' => 'Add figure',
            'fields' => [
                ['key' => 'value', 'type' => 'text', 'label' => 'Figure', 'translatable' => true, 'default' => ['_' => '0']],
                ['key' => 'label', 'type' => 'text', 'label' => 'Label', 'translatable' => true, 'default' => ['_' => 'New figure']],
            ],
            'default' => [
                ['value' => ['_' => '9'], 'label' => ['_' => 'Regions']],
                ['value' => ['_' => '4'], 'label' => ['_' => 'Continents']],
                ['value' => ['_' => '10 Gbps'], 'label' => ['_' => 'Uplinks']],
                ['value' => ['_' => '24/7'], 'label' => ['_' => 'Network monitoring']],
            ]],
    ],
];
