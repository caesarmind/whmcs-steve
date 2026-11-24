<?php
/**
 * Two large tiles side by side, each with an eyebrow, a heading, a line of
 * text, up to two links and an icon or a picture at the bottom.
 * Markup and classes: the theme's hp-tiles-hero-pair block.
 */
return [
    'label'  => 'Two large tiles',
    'hint'   => 'Two big tiles side by side',
    'group'  => 'Product tiles',
    'order'  => 1010,
    'fields' => [
        ['key' => 'tiles', 'type' => 'list', 'label' => 'Tiles', 'max' => 2, 'itemLabel' => 'title', 'addLabel' => 'Add tile',
            'fields' => [
                ['key' => 'eyebrow', 'type' => 'text', 'label' => 'Eyebrow', 'translatable' => true, 'default' => ['_' => '']],
                ['key' => 'title', 'type' => 'text', 'label' => 'Heading', 'translatable' => true, 'default' => ['_' => 'Tile heading']],
                ['key' => 'text', 'type' => 'textarea', 'label' => 'Text', 'translatable' => true, 'default' => ['_' => '']],
                ['key' => 'tone', 'type' => 'select', 'label' => 'Colour', 'default' => 'sky',
                    'options' => ['sky' => 'Sky blue', 'graphite' => 'Graphite']],
                ['key' => 'primaryLabel', 'type' => 'text', 'label' => 'Link text', 'translatable' => true, 'default' => ['_' => '']],
                ['key' => 'primaryLink', 'type' => 'link', 'label' => 'Link', 'default' => ''],
                ['key' => 'secondaryLabel', 'type' => 'text', 'label' => 'Second link text', 'translatable' => true, 'default' => ['_' => '']],
                ['key' => 'secondaryLink', 'type' => 'link', 'label' => 'Second link', 'default' => ''],
                ['key' => 'icon', 'type' => 'icon', 'label' => 'Icon', 'default' => '',
                    'help' => 'Drawn large at the bottom of the tile when there is no image.'],
                ['key' => 'image', 'type' => 'image', 'label' => 'Image', 'default' => '',
                    'help' => 'Shown at the bottom of the tile in place of the icon.'],
                ['key' => 'imageAlt', 'type' => 'text', 'label' => 'Image description', 'translatable' => true, 'default' => ['_' => '']],
            ],
            'default' => [
                ['eyebrow' => ['_' => 'Shared hosting'], 'title' => ['_' => 'Publish a site this afternoon'],
                    'text' => ['_' => 'Pick a plan, point your domain and upload. We look after the server.'], 'tone' => 'sky',
                    'primaryLabel' => ['_' => 'See plans'], 'primaryLink' => 'cart.php',
                    'secondaryLabel' => ['_' => 'Ask a question'], 'secondaryLink' => 'contact.php',
                    'icon' => 'cloud', 'image' => '', 'imageAlt' => ['_' => '']],
                ['eyebrow' => ['_' => 'Cloud servers'], 'title' => ['_' => 'Room to grow into'],
                    'text' => ['_' => 'Add memory, cores or disk space as your project gets busier.'], 'tone' => 'graphite',
                    'primaryLabel' => ['_' => 'Configure a server'], 'primaryLink' => 'cart.php',
                    'secondaryLabel' => ['_' => ''], 'secondaryLink' => '',
                    'icon' => 'server', 'image' => '', 'imageAlt' => ['_' => '']],
            ]],
    ],
];
