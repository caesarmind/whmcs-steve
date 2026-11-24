<?php
/**
 * A hub location joined to the other locations by moving dashed lines, over
 * a world map. Each point is placed by two percentages, measured from the
 * left and top edges of the map.
 * Markup and classes: the theme's hp-locations-connect block, with its
 * hp-connect-viz frame (line, hub and node) and hp-map-pin labels.
 */
return [
    'label'  => 'Locations, connection map',
    'hint'   => 'A hub joined to other locations by lines',
    'group'  => 'Locations',
    'order'  => 460,
    'fields' => [
        ['key' => 'title', 'type' => 'text', 'label' => 'Heading', 'translatable' => true, 'default' => ['_' => 'Every region linked to the next']],
        ['key' => 'subtitle', 'type' => 'text', 'label' => 'Subheading', 'translatable' => true,
            'default' => ['_' => 'Traffic between our locations stays on our own network.']],
        ['key' => 'map', 'type' => 'image', 'label' => 'Map image', 'default' => '',
            'help' => 'A plain world map outline, dark shapes on a clear background. It is shown faintly behind the lines. Without one the points sit on a dotted grid.'],
        ['key' => 'hubName', 'type' => 'text', 'label' => 'Hub name', 'translatable' => true, 'default' => ['_' => 'Frankfurt, hub'],
            'help' => 'The location every line starts from.'],
        ['key' => 'hubX', 'type' => 'number', 'label' => 'Hub, across', 'min' => 0, 'max' => 100, 'unit' => '%', 'default' => 52,
            'help' => 'Distance from the left edge of the map, 0 to 100.'],
        ['key' => 'hubY', 'type' => 'number', 'label' => 'Hub, down', 'min' => 0, 'max' => 100, 'unit' => '%', 'default' => 27,
            'help' => 'Distance from the top edge of the map, 0 to 100.'],
        ['key' => 'nodes', 'type' => 'list', 'label' => 'Connected locations', 'max' => 16, 'itemLabel' => 'name', 'addLabel' => 'Add location',
            'fields' => [
                ['key' => 'name', 'type' => 'text', 'label' => 'Name', 'translatable' => true, 'default' => ['_' => 'New location']],
                ['key' => 'x', 'type' => 'number', 'label' => 'Across', 'min' => 0, 'max' => 100, 'unit' => '%', 'default' => 50,
                    'help' => 'Distance from the left edge of the map, 0 to 100.'],
                ['key' => 'y', 'type' => 'number', 'label' => 'Down', 'min' => 0, 'max' => 100, 'unit' => '%', 'default' => 50,
                    'help' => 'Distance from the top edge of the map, 0 to 100.'],
            ],
            'default' => [
                ['name' => ['_' => 'Seattle'], 'x' => 15, 'y' => 28],
                ['name' => ['_' => 'New York'], 'x' => 25, 'y' => 35],
                ['name' => ['_' => 'Sao Paulo'], 'x' => 36, 'y' => 71],
                ['name' => ['_' => 'Singapore'], 'x' => 80, 'y' => 57],
                ['name' => ['_' => 'Tokyo'], 'x' => 89, 'y' => 32],
                ['name' => ['_' => 'Sydney'], 'x' => 88, 'y' => 76],
            ]],
    ],
];
