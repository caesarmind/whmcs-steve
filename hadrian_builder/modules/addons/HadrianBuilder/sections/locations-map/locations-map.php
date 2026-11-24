<?php
/**
 * Server locations as pulsing pins over a world map. Each pin is placed by
 * two percentages, measured from the left and top edges of the map.
 * Markup and classes: the theme's hp-locations-map-section block, with its
 * hp-world-map frame and hp-map-pin pins.
 */
return [
    'label'  => 'Locations on a map',
    'hint'   => 'Pulsing pins over a world map',
    'group'  => 'Locations',
    'order'  => 440,
    'fields' => [
        ['key' => 'title', 'type' => 'text', 'label' => 'Heading', 'translatable' => true, 'default' => ['_' => 'Where our servers are']],
        ['key' => 'subtitle', 'type' => 'text', 'label' => 'Subheading', 'translatable' => true,
            'default' => ['_' => 'Six regions today, with more on the way.']],
        ['key' => 'dark', 'type' => 'toggle', 'label' => 'Dark background', 'default' => true],
        ['key' => 'map', 'type' => 'image', 'label' => 'Map image', 'default' => '',
            'help' => 'A plain world map outline, dark shapes on a clear background. It is shown faintly behind the pins. Without one the pins sit on a dotted grid.'],
        ['key' => 'showLabels', 'type' => 'toggle', 'label' => 'Show place names', 'default' => true],
        ['key' => 'pins', 'type' => 'list', 'label' => 'Pins', 'max' => 24, 'itemLabel' => 'name', 'addLabel' => 'Add pin',
            'fields' => [
                ['key' => 'name', 'type' => 'text', 'label' => 'Name', 'translatable' => true, 'default' => ['_' => 'New location']],
                ['key' => 'x', 'type' => 'number', 'label' => 'Across', 'min' => 0, 'max' => 100, 'unit' => '%', 'default' => 50,
                    'help' => 'Distance from the left edge of the map, 0 to 100.'],
                ['key' => 'y', 'type' => 'number', 'label' => 'Down', 'min' => 0, 'max' => 100, 'unit' => '%', 'default' => 50,
                    'help' => 'Distance from the top edge of the map, 0 to 100.'],
            ],
            'default' => [
                ['name' => ['_' => 'New York'], 'x' => 25, 'y' => 35],
                ['name' => ['_' => 'Sao Paulo'], 'x' => 36, 'y' => 71],
                ['name' => ['_' => 'Frankfurt'], 'x' => 52, 'y' => 27],
                ['name' => ['_' => 'Singapore'], 'x' => 80, 'y' => 57],
                ['name' => ['_' => 'Tokyo'], 'x' => 89, 'y' => 32],
                ['name' => ['_' => 'Sydney'], 'x' => 88, 'y' => 76],
            ]],
    ],
];
