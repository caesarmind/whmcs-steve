<?php
/**
 * Hero on a soft colour gradient, with a row of small cards under the
 * headline. Each card is an icon, a title and a short line.
 * Markup and classes: the theme's hp-hero-gradient block.
 */
return [
    'label'  => 'Hero, gradient with cards',
    'hint'   => 'Colour gradient with small cards below',
    'group'  => 'Hero',
    'order'  => 125,
    'fields' => [
        ['key' => 'colour', 'type' => 'select', 'label' => 'Colour', 'default' => 'blue',
            'options' => ['blue' => 'Blue', 'green' => 'Green', 'purple' => 'Purple', 'rose' => 'Rose', 'graphite' => 'Grey']],
        ['key' => 'title', 'type' => 'text', 'label' => 'Headline', 'translatable' => true, 'default' => ['_' => 'Protection for every site']],
        ['key' => 'text', 'type' => 'textarea', 'label' => 'Text', 'translatable' => true,
            'default' => ['_' => 'Certificates, backups and monitoring, set up for you on day one.']],
        ['key' => 'cards', 'type' => 'list', 'label' => 'Cards', 'max' => 6, 'itemLabel' => 'label', 'addLabel' => 'Add card',
            'fields' => [
                ['key' => 'icon', 'type' => 'icon', 'label' => 'Icon', 'default' => 'check'],
                ['key' => 'label', 'type' => 'text', 'label' => 'Title', 'translatable' => true, 'default' => ['_' => 'Card title']],
                ['key' => 'sub', 'type' => 'text', 'label' => 'Line under the title', 'translatable' => true, 'default' => ['_' => '']],
            ],
            'default' => [
                ['icon' => 'lock', 'label' => ['_' => 'Free SSL'], 'sub' => ['_' => 'On every domain']],
                ['icon' => 'database', 'label' => ['_' => 'Nightly backups'], 'sub' => ['_' => 'Restore in a few clicks']],
                ['icon' => 'activity', 'label' => ['_' => 'Monitoring'], 'sub' => ['_' => 'Around the clock']],
            ]],
    ],
];
