<?php
/**
 * Server locations as cards on a dark band, each with a region and a
 * latency figure.
 * Markup and classes: the theme's hp-locations-dark block.
 */
return [
    'label'  => 'Locations, dark with latency',
    'hint'   => 'Dark location cards with a response time',
    'group'  => 'Locations',
    'order'  => 410,
    'fields' => [
        ['key' => 'title', 'type' => 'text', 'label' => 'Heading', 'translatable' => true, 'default' => ['_' => 'Choose where your server runs']],
        ['key' => 'subtitle', 'type' => 'text', 'label' => 'Subheading', 'translatable' => true,
            'default' => ['_' => 'The same hardware in every region. You pick one when you order.']],
        ['key' => 'items', 'type' => 'list', 'label' => 'Locations', 'max' => 12, 'itemLabel' => 'name', 'addLabel' => 'Add location',
            'help' => 'Cards sit four to a row.',
            'fields' => [
                ['key' => 'code', 'type' => 'text', 'label' => 'Short code', 'translatable' => true, 'default' => ['_' => ''],
                    'help' => 'Two or three letters shown above the name, such as a country code. Leave empty to hide it.'],
                ['key' => 'name', 'type' => 'text', 'label' => 'Name', 'translatable' => true, 'default' => ['_' => 'New location']],
                ['key' => 'detail', 'type' => 'text', 'label' => 'Region', 'translatable' => true, 'default' => ['_' => '']],
                ['key' => 'latency', 'type' => 'text', 'label' => 'Latency', 'translatable' => true, 'default' => ['_' => ''],
                    'help' => 'A typical response time you have measured, such as "18 ms". Leave empty to hide it.'],
            ],
            'default' => [
                ['code' => ['_' => 'GB'], 'name' => ['_' => 'London'], 'detail' => ['_' => 'Europe'], 'latency' => ['_' => '12 ms']],
                ['code' => ['_' => 'US'], 'name' => ['_' => 'Dallas'], 'detail' => ['_' => 'North America'], 'latency' => ['_' => '24 ms']],
                ['code' => ['_' => 'JP'], 'name' => ['_' => 'Tokyo'], 'detail' => ['_' => 'Asia'], 'latency' => ['_' => '38 ms']],
                ['code' => ['_' => 'BR'], 'name' => ['_' => 'Sao Paulo'], 'detail' => ['_' => 'South America'], 'latency' => ['_' => '52 ms']],
            ]],
    ],
];
