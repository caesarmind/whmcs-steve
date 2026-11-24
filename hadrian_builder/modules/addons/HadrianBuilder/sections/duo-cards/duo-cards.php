<?php
/**
 * Two dark cards side by side: a paragraph that opens in bold, above a picture
 * that runs off the edge of the card.
 * Markup and classes: the theme's hp-duo-feature block.
 */
return [
    'label'  => 'Two dark cards',
    'hint'   => 'Two dark cards, text above a picture',
    'group'  => 'Features',
    'order'  => 370,
    'fields' => [
        ['key' => 'cards', 'type' => 'list', 'label' => 'Cards', 'max' => 4, 'itemLabel' => 'lead', 'addLabel' => 'Add card',
            'help' => 'Two to a row.',
            'fields' => [
                ['key' => 'lead', 'type' => 'text', 'label' => 'Opening words', 'translatable' => true, 'default' => ['_' => 'Opening words.'],
                    'help' => 'Shown in bold at the start of the paragraph.'],
                ['key' => 'text', 'type' => 'textarea', 'label' => 'Text', 'translatable' => true, 'default' => ['_' => '']],
                ['key' => 'image', 'type' => 'image', 'label' => 'Image', 'default' => '',
                    'help' => 'A wide screenshot works best. Without one the card shows a plain panel.'],
                ['key' => 'imageAlt', 'type' => 'text', 'label' => 'Image description', 'translatable' => true, 'default' => ['_' => '']],
            ],
            'default' => [
                ['lead' => ['_' => 'Your sites, on their own resources.'],
                    'text' => ['_' => 'Each account gets its own share of CPU and memory, so a busy neighbour cannot slow your pages down. Check the usage graphs in your control panel whenever you like.'],
                    'image' => '', 'imageAlt' => ['_' => '']],
                ['lead' => ['_' => 'Updates you can try first.'],
                    'text' => ['_' => 'Test a plugin or theme update on a staging copy of your site. When it looks right, push it live, and roll back if it does not.'],
                    'image' => '', 'imageAlt' => ['_' => '']],
            ]],
    ],
];
