<?php
/**
 * A heading over a row of large figures, each with a title and a line of text.
 * Markup and classes: the theme's hp-feature-bignum block.
 */
return [
    'label'  => 'Big numbers',
    'hint'   => 'Large figures with a short explanation',
    'group'  => 'Features',
    'order'  => 360,
    'fields' => [
        ['key' => 'title', 'type' => 'text', 'label' => 'Heading', 'translatable' => true, 'default' => ['_' => 'The numbers we watch']],
        ['key' => 'subtitle', 'type' => 'text', 'label' => 'Subheading', 'translatable' => true, 'default' => ['_' => 'Taken from our own servers and checked every month.']],
        ['key' => 'items', 'type' => 'list', 'label' => 'Figures', 'max' => 6, 'itemLabel' => 'title', 'addLabel' => 'Add figure',
            'fields' => [
                ['key' => 'value', 'type' => 'text', 'label' => 'Figure', 'translatable' => true, 'default' => ['_' => '100%'],
                    'help' => 'Shown very large. Keep it to about six characters.'],
                ['key' => 'title', 'type' => 'text', 'label' => 'Title', 'translatable' => true, 'default' => ['_' => 'Figure title']],
                ['key' => 'text', 'type' => 'textarea', 'label' => 'Text', 'translatable' => true, 'default' => ['_' => '']],
            ],
            'default' => [
                ['value' => ['_' => '99.9%'], 'title' => ['_' => 'Uptime target'], 'text' => ['_' => 'Measured on every server, every month.']],
                ['value' => ['_' => '24/7'], 'title' => ['_' => 'Monitoring'], 'text' => ['_' => 'Someone is watching the servers day and night.']],
                ['value' => ['_' => '5 min'], 'title' => ['_' => 'Typical setup'], 'text' => ['_' => 'Most accounts are ready before the welcome email lands.']],
            ]],
    ],
];
