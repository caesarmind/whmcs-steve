<?php
/**
 * Coloured tiles, one per product or service: an eyebrow, a heading, a line
 * of text, up to two links and an optional picture.
 * Markup and classes: the theme's hp-tiles-section block, plain (two large
 * tiles per row) or with its `rich` or `grid-3` modifier.
 */
return [
    'label'  => 'Product tiles',
    'hint'   => 'Coloured tiles in rows of two or three',
    'group'  => 'Product tiles',
    'order'  => 1000,
    'fields' => [
        ['key' => 'layout', 'type' => 'select', 'label' => 'Layout', 'default' => 'grid-3',
            'options' => ['rows' => 'Two large tiles per row', 'rich' => 'Three per row, tall', 'grid-3' => 'Three per row, compact'],
            'help' => 'The large and tall layouts leave room under the text for a picture.'],
        ['key' => 'tiles', 'type' => 'list', 'label' => 'Tiles', 'max' => 12, 'itemLabel' => 'title', 'addLabel' => 'Add tile',
            'fields' => [
                ['key' => 'eyebrow', 'type' => 'text', 'label' => 'Eyebrow', 'translatable' => true, 'default' => ['_' => '']],
                ['key' => 'title', 'type' => 'text', 'label' => 'Heading', 'translatable' => true, 'default' => ['_' => 'Tile heading']],
                ['key' => 'text', 'type' => 'textarea', 'label' => 'Text', 'translatable' => true, 'default' => ['_' => '']],
                ['key' => 'tone', 'type' => 'select', 'label' => 'Colour', 'default' => 'light',
                    'options' => ['light' => 'Light', 'dark' => 'Dark', 'sky' => 'Sky blue', 'cream' => 'Cream', 'plum' => 'Plum', 'graphite' => 'Graphite']],
                ['key' => 'primaryLabel', 'type' => 'text', 'label' => 'Link text', 'translatable' => true, 'default' => ['_' => '']],
                ['key' => 'primaryLink', 'type' => 'link', 'label' => 'Link', 'default' => ''],
                ['key' => 'secondaryLabel', 'type' => 'text', 'label' => 'Second link text', 'translatable' => true, 'default' => ['_' => '']],
                ['key' => 'secondaryLink', 'type' => 'link', 'label' => 'Second link', 'default' => ''],
                ['key' => 'image', 'type' => 'image', 'label' => 'Image', 'default' => '',
                    'help' => 'Shown under the text. Leave empty for a tile with text only.'],
                ['key' => 'imageAlt', 'type' => 'text', 'label' => 'Image description', 'translatable' => true, 'default' => ['_' => '']],
            ],
            'default' => [
                ['eyebrow' => ['_' => 'Web hosting'], 'title' => ['_' => 'A home for your site'],
                    'text' => ['_' => 'NVMe storage, free SSL and a backup every night.'], 'tone' => 'light',
                    'primaryLabel' => ['_' => 'See plans'], 'primaryLink' => 'cart.php',
                    'secondaryLabel' => ['_' => ''], 'secondaryLink' => '', 'image' => '', 'imageAlt' => ['_' => '']],
                ['eyebrow' => ['_' => 'Virtual servers'], 'title' => ['_' => 'A server of your own'],
                    'text' => ['_' => 'Root access, and cores and memory nobody else shares.'], 'tone' => 'dark',
                    'primaryLabel' => ['_' => 'Compare servers'], 'primaryLink' => 'cart.php',
                    'secondaryLabel' => ['_' => ''], 'secondaryLink' => '', 'image' => '', 'imageAlt' => ['_' => '']],
                ['eyebrow' => ['_' => 'Domains'], 'title' => ['_' => 'Register a domain'],
                    'text' => ['_' => 'Search hundreds of extensions and renew them in one place.'], 'tone' => 'sky',
                    'primaryLabel' => ['_' => 'Search domains'], 'primaryLink' => 'cart.php?a=add&domain=register',
                    'secondaryLabel' => ['_' => ''], 'secondaryLink' => '', 'image' => '', 'imageAlt' => ['_' => '']],
                ['eyebrow' => ['_' => 'SSL'], 'title' => ['_' => 'A padlock on every page'],
                    'text' => ['_' => 'Certificates issued and renewed without a ticket.'], 'tone' => 'cream',
                    'primaryLabel' => ['_' => 'View certificates'], 'primaryLink' => 'cart.php',
                    'secondaryLabel' => ['_' => ''], 'secondaryLink' => '', 'image' => '', 'imageAlt' => ['_' => '']],
                ['eyebrow' => ['_' => 'Email'], 'title' => ['_' => 'Mail on your own domain'],
                    'text' => ['_' => 'Mailboxes with webmail and a spam filter included.'], 'tone' => 'plum',
                    'primaryLabel' => ['_' => 'See email plans'], 'primaryLink' => 'cart.php',
                    'secondaryLabel' => ['_' => ''], 'secondaryLink' => '', 'image' => '', 'imageAlt' => ['_' => '']],
                ['eyebrow' => ['_' => 'Support'], 'title' => ['_' => 'People who answer'],
                    'text' => ['_' => 'Write at any hour and a technician replies.'], 'tone' => 'graphite',
                    'primaryLabel' => ['_' => 'Contact us'], 'primaryLink' => 'contact.php',
                    'secondaryLabel' => ['_' => ''], 'secondaryLink' => '', 'image' => '', 'imageAlt' => ['_' => '']],
            ]],
    ],
];
