<?php
/**
 * One feature given a whole panel: text and a few figures on the left, a
 * picture or a large icon on the right.
 * Markup and classes: the theme's hp-feature-spotlight block.
 */
return [
    'label'  => 'Feature spotlight',
    'hint'   => 'One feature with figures and a picture',
    'group'  => 'Features',
    'order'  => 340,
    'fields' => [
        ['key' => 'eyebrow', 'type' => 'text', 'label' => 'Eyebrow', 'translatable' => true, 'default' => ['_' => 'Storage'],
            'help' => 'The short line above the heading. Leave empty to hide it.'],
        ['key' => 'title', 'type' => 'text', 'label' => 'Heading', 'translatable' => true, 'default' => ['_' => 'Disks that keep up with your site']],
        ['key' => 'text', 'type' => 'textarea', 'label' => 'Text', 'translatable' => true,
            'default' => ['_' => 'Every plan runs on NVMe drives. Pages, searches and checkouts come back faster than they do on older disks.']],
        ['key' => 'stats', 'type' => 'list', 'label' => 'Figures', 'max' => 4, 'itemLabel' => 'value', 'addLabel' => 'Add figure',
            'fields' => [
                ['key' => 'value', 'type' => 'text', 'label' => 'Figure', 'translatable' => true, 'default' => ['_' => '']],
                ['key' => 'label', 'type' => 'text', 'label' => 'Caption', 'translatable' => true, 'default' => ['_' => '']],
            ],
            'default' => [
                ['value' => ['_' => 'NVMe'], 'label' => ['_' => 'on every plan']],
                ['value' => ['_' => 'Daily'], 'label' => ['_' => 'backups']],
                ['value' => ['_' => '24/7'], 'label' => ['_' => 'monitoring']],
            ]],
        ['key' => 'image', 'type' => 'image', 'label' => 'Image', 'default' => ''],
        ['key' => 'imageAlt', 'type' => 'text', 'label' => 'Image description', 'translatable' => true, 'default' => ['_' => ''],
            'help' => 'Read aloud by screen readers. Leave empty for a purely decorative image.'],
        ['key' => 'icon', 'type' => 'icon', 'label' => 'Icon when there is no image', 'default' => 'drive'],
    ],
];
