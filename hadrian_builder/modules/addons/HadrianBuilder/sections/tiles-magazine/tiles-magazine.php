<?php
/**
 * One large tile beside a two-by-two grid of up to four small ones.
 * Markup and classes: the theme's hp-tiles-magazine block (mag-big and
 * hp-mag-small).
 */
return [
    'label'  => 'Tiles, one large and four small',
    'hint'   => 'A large tile beside four small ones',
    'group'  => 'Product tiles',
    'order'  => 1020,
    'fields' => [
        ['key' => 'eyebrow', 'type' => 'text', 'label' => 'Large tile: eyebrow', 'translatable' => true, 'default' => ['_' => 'Managed hosting']],
        ['key' => 'title', 'type' => 'text', 'label' => 'Large tile: heading', 'translatable' => true, 'default' => ['_' => 'Hosting with the upkeep done']],
        ['key' => 'text', 'type' => 'textarea', 'label' => 'Large tile: text', 'translatable' => true,
            'default' => ['_' => 'Updates, backups and monitoring are taken care of on every plan.']],
        ['key' => 'linkLabel', 'type' => 'text', 'label' => 'Large tile: link text', 'translatable' => true, 'default' => ['_' => 'Compare plans']],
        ['key' => 'link', 'type' => 'link', 'label' => 'Large tile: link', 'default' => 'cart.php'],
        ['key' => 'icon', 'type' => 'icon', 'label' => 'Large tile: icon', 'default' => 'rocket',
            'help' => 'Drawn large at the bottom of the tile when there is no image.'],
        ['key' => 'image', 'type' => 'image', 'label' => 'Large tile: image', 'default' => '',
            'help' => 'Shown at the bottom of the tile in place of the icon.'],
        ['key' => 'imageAlt', 'type' => 'text', 'label' => 'Large tile: image description', 'translatable' => true, 'default' => ['_' => '']],
        ['key' => 'items', 'type' => 'list', 'label' => 'Small tiles', 'max' => 4, 'itemLabel' => 'title', 'addLabel' => 'Add small tile',
            'fields' => [
                ['key' => 'eyebrow', 'type' => 'text', 'label' => 'Eyebrow', 'translatable' => true, 'default' => ['_' => '']],
                ['key' => 'title', 'type' => 'text', 'label' => 'Heading', 'translatable' => true, 'default' => ['_' => 'Tile heading']],
                ['key' => 'text', 'type' => 'text', 'label' => 'Text', 'translatable' => true, 'default' => ['_' => '']],
                ['key' => 'link', 'type' => 'link', 'label' => 'Link', 'default' => '',
                    'help' => 'Where the heading leads. Leave empty for a heading that is not a link.'],
                ['key' => 'tone', 'type' => 'select', 'label' => 'Colour', 'default' => 'light',
                    'options' => ['light' => 'Light', 'dark' => 'Dark', 'cream' => 'Cream', 'plum' => 'Plum']],
                ['key' => 'icon', 'type' => 'icon', 'label' => 'Icon', 'default' => ''],
            ],
            'default' => [
                ['eyebrow' => ['_' => 'Domains'], 'title' => ['_' => 'Register or transfer'], 'text' => ['_' => 'Hundreds of extensions.'],
                    'link' => 'cart.php?a=add&domain=register', 'tone' => 'cream', 'icon' => 'globe'],
                ['eyebrow' => ['_' => 'Backups'], 'title' => ['_' => 'Restore in a click'], 'text' => ['_' => 'A copy kept every night.'],
                    'link' => '', 'tone' => 'plum', 'icon' => 'refresh'],
                ['eyebrow' => ['_' => 'Email'], 'title' => ['_' => 'Mail on your domain'], 'text' => ['_' => 'Webmail and a spam filter.'],
                    'link' => '', 'tone' => 'light', 'icon' => 'mail'],
                ['eyebrow' => ['_' => 'Support'], 'title' => ['_' => 'Help at any hour'], 'text' => ['_' => 'Tickets answered day and night.'],
                    'link' => 'contact.php', 'tone' => 'dark', 'icon' => 'chat'],
            ]],
    ],
];
