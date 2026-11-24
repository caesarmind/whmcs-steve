<?php
/**
 * A band with a turning globe and a short row of figures under it.
 * Markup and classes: the theme's hp-locations-globe block.
 */
return [
    'label'  => 'Locations, globe',
    'hint'   => 'A turning globe above a few figures',
    'group'  => 'Locations',
    'order'  => 450,
    'fields' => [
        ['key' => 'title', 'type' => 'text', 'label' => 'Heading', 'translatable' => true, 'default' => ['_' => 'One network, many regions']],
        ['key' => 'subtitle', 'type' => 'text', 'label' => 'Subheading', 'translatable' => true,
            'default' => ['_' => 'Host near your customers and still reach everyone else quickly.']],
        ['key' => 'stats', 'type' => 'list', 'label' => 'Figures', 'max' => 4, 'itemLabel' => 'label', 'addLabel' => 'Add figure',
            'fields' => [
                ['key' => 'value', 'type' => 'text', 'label' => 'Figure', 'translatable' => true, 'default' => ['_' => '0']],
                ['key' => 'label', 'type' => 'text', 'label' => 'Label', 'translatable' => true, 'default' => ['_' => 'New figure']],
            ],
            'default' => [
                ['value' => ['_' => '9'], 'label' => ['_' => 'Server regions']],
                ['value' => ['_' => '60+'], 'label' => ['_' => 'Countries with customers']],
                ['value' => ['_' => '40'], 'label' => ['_' => 'Network peers']],
            ]],
    ],
];
