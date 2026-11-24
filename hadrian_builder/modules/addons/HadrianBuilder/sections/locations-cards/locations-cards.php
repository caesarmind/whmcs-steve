<?php
/**
 * Server locations as a grid of light cards: a short code, a place name and
 * a detail line.
 * Markup and classes: the theme's hp-locations-section block.
 */
return [
    'label'  => 'Locations, cards',
    'hint'   => 'A card for each server location',
    'group'  => 'Locations',
    'order'  => 400,
    'fields' => [
        ['key' => 'title', 'type' => 'text', 'label' => 'Heading', 'translatable' => true, 'default' => ['_' => 'Servers near your visitors']],
        ['key' => 'subtitle', 'type' => 'text', 'label' => 'Subheading', 'translatable' => true,
            'default' => ['_' => 'Pick the region closest to the people who use your site.']],
        ['key' => 'items', 'type' => 'list', 'label' => 'Locations', 'max' => 12, 'itemLabel' => 'name', 'addLabel' => 'Add location',
            'help' => 'Cards sit four to a row.',
            'fields' => [
                ['key' => 'code', 'type' => 'text', 'label' => 'Short code', 'translatable' => true, 'default' => ['_' => ''],
                    'help' => 'Two or three letters shown above the name, such as a country code. Leave empty to hide it.'],
                ['key' => 'name', 'type' => 'text', 'label' => 'Name', 'translatable' => true, 'default' => ['_' => 'New location']],
                ['key' => 'detail', 'type' => 'text', 'label' => 'Detail', 'translatable' => true, 'default' => ['_' => ''],
                    'help' => 'The country or region.'],
            ],
            'default' => [
                ['code' => ['_' => 'DE'], 'name' => ['_' => 'Frankfurt'], 'detail' => ['_' => 'Germany']],
                ['code' => ['_' => 'US'], 'name' => ['_' => 'Chicago'], 'detail' => ['_' => 'United States']],
                ['code' => ['_' => 'SG'], 'name' => ['_' => 'Singapore'], 'detail' => ['_' => 'Southeast Asia']],
                ['code' => ['_' => 'AU'], 'name' => ['_' => 'Sydney'], 'detail' => ['_' => 'Australia']],
            ]],
    ],
];
