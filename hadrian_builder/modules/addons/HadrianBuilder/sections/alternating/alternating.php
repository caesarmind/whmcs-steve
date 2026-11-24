<?php
/**
 * Rows of text beside an image, with the image switching sides on each row.
 * Markup and classes: the theme's hp-alternating block.
 */
return [
    'label'  => 'Alternating rows',
    'hint'   => 'Text beside an image, sides switching each row',
    'group'  => 'Features',
    'order'  => 30,
    'fields' => [
        ['key' => 'rows', 'type' => 'list', 'label' => 'Rows', 'max' => 8, 'itemLabel' => 'title', 'addLabel' => 'Add row',
            'fields' => [
                ['key' => 'eyebrow', 'type' => 'text', 'label' => 'Eyebrow', 'translatable' => true, 'default' => ['_' => '']],
                ['key' => 'title', 'type' => 'text', 'label' => 'Title', 'translatable' => true, 'default' => ['_' => 'Row title']],
                ['key' => 'text', 'type' => 'textarea', 'label' => 'Text', 'translatable' => true, 'default' => ['_' => '']],
                ['key' => 'image', 'type' => 'image', 'label' => 'Image', 'default' => ''],
                ['key' => 'imageAlt', 'type' => 'text', 'label' => 'Image description', 'translatable' => true, 'default' => ['_' => '']],
                ['key' => 'tone', 'type' => 'select', 'label' => 'Panel when there is no image', 'default' => 'plain',
                    'options' => ['plain' => 'Light', 'dark' => 'Dark', 'accent' => 'Blue', 'green' => 'Green']],
            ],
            'default' => [
                ['eyebrow' => ['_' => 'Performance'], 'title' => ['_' => 'Built on fast hardware'],
                    'text' => ['_' => 'Every plan runs on NVMe storage with caching switched on from day one.'],
                    'image' => '', 'imageAlt' => ['_' => ''], 'tone' => 'plain'],
                ['eyebrow' => ['_' => 'Security'], 'title' => ['_' => 'Protected without extra work'],
                    'text' => ['_' => 'SSL, a firewall and malware scanning are part of the service, not a line on the invoice.'],
                    'image' => '', 'imageAlt' => ['_' => ''], 'tone' => 'dark'],
            ]],
    ],
];
