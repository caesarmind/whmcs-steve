<?php
/**
 * Server locations as a compact row of pills: a short code and a place name.
 * Markup and classes: the theme's hp-locations-compact block.
 */
return [
    'label'  => 'Locations, compact',
    'hint'   => 'Locations as a row of small pills',
    'group'  => 'Locations',
    'order'  => 420,
    'fields' => [
        ['key' => 'title', 'type' => 'text', 'label' => 'Heading', 'translatable' => true, 'default' => ['_' => 'Regions you can order in']],
        ['key' => 'subtitle', 'type' => 'text', 'label' => 'Subheading', 'translatable' => true,
            'default' => ['_' => 'All of them are managed from the same account.']],
        ['key' => 'items', 'type' => 'list', 'label' => 'Locations', 'max' => 30, 'itemLabel' => 'name', 'addLabel' => 'Add location',
            'fields' => [
                ['key' => 'code', 'type' => 'text', 'label' => 'Short code', 'translatable' => true, 'default' => ['_' => ''],
                    'help' => 'Two or three letters shown before the name, such as a country code. Leave empty to hide it.'],
                ['key' => 'name', 'type' => 'text', 'label' => 'Name', 'translatable' => true, 'default' => ['_' => 'New location']],
            ],
            'default' => [
                ['code' => ['_' => 'DE'], 'name' => ['_' => 'Frankfurt']],
                ['code' => ['_' => 'NL'], 'name' => ['_' => 'Amsterdam']],
                ['code' => ['_' => 'GB'], 'name' => ['_' => 'London']],
                ['code' => ['_' => 'US'], 'name' => ['_' => 'New York']],
                ['code' => ['_' => 'US'], 'name' => ['_' => 'Dallas']],
                ['code' => ['_' => 'CA'], 'name' => ['_' => 'Montreal']],
                ['code' => ['_' => 'SG'], 'name' => ['_' => 'Singapore']],
                ['code' => ['_' => 'JP'], 'name' => ['_' => 'Tokyo']],
                ['code' => ['_' => 'AU'], 'name' => ['_' => 'Sydney']],
            ]],
    ],
];
