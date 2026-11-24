<?php
/**
 * Steps listed down the page, each with its number, a title and a line.
 * The numbers are counted for you.
 * Markup and classes: the theme's hp-features-numbered block.
 */
return [
    'label'  => 'Numbered steps',
    'hint'   => 'Steps in order, numbered for you',
    'group'  => 'Features',
    'order'  => 310,
    'fields' => [
        ['key' => 'title', 'type' => 'text', 'label' => 'Heading', 'translatable' => true, 'default' => ['_' => 'Online in three steps']],
        ['key' => 'items', 'type' => 'list', 'label' => 'Steps', 'max' => 10, 'itemLabel' => 'title', 'addLabel' => 'Add step',
            'fields' => [
                ['key' => 'title', 'type' => 'text', 'label' => 'Title', 'translatable' => true, 'default' => ['_' => 'Step title']],
                ['key' => 'text', 'type' => 'textarea', 'label' => 'Text', 'translatable' => true, 'default' => ['_' => '']],
            ],
            'default' => [
                ['title' => ['_' => 'Pick a plan'], 'text' => ['_' => 'Start small. You can move up whenever you need more room.']],
                ['title' => ['_' => 'Point your domain'], 'text' => ['_' => 'Register a new name or bring one you already own.']],
                ['title' => ['_' => 'Put your site online'], 'text' => ['_' => 'Your account is ready a few minutes after you pay.']],
            ]],
    ],
];
