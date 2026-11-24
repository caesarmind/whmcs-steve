<?php
/**
 * Rows that pair a picture with a short callout: a coloured badge, a sentence
 * that opens in bold, and two lines of detail. The picture switches sides on
 * each row.
 * Markup and classes: the theme's hp-chip-spec block.
 */
return [
    'label'  => 'Spec callouts',
    'hint'   => 'A picture beside a badge and a short spec',
    'group'  => 'Features',
    'order'  => 375,
    'fields' => [
        ['key' => 'rows', 'type' => 'list', 'label' => 'Rows', 'max' => 6, 'itemLabel' => 'badge', 'addLabel' => 'Add row',
            'fields' => [
                ['key' => 'badge', 'type' => 'text', 'label' => 'Badge', 'translatable' => true, 'default' => ['_' => 'Plan name']],
                ['key' => 'tone', 'type' => 'select', 'label' => 'Badge colour', 'default' => 'green',
                    'options' => ['green' => 'Green', 'blue' => 'Blue']],
                ['key' => 'lead', 'type' => 'text', 'label' => 'Opening words', 'translatable' => true, 'default' => ['_' => ''],
                    'help' => 'Shown in bold at the start of the sentence.'],
                ['key' => 'text', 'type' => 'textarea', 'label' => 'Text', 'translatable' => true, 'default' => ['_' => '']],
                ['key' => 'metaTitle', 'type' => 'text', 'label' => 'Detail, first line', 'translatable' => true, 'default' => ['_' => '']],
                ['key' => 'metaText', 'type' => 'text', 'label' => 'Detail, second line', 'translatable' => true, 'default' => ['_' => '']],
                ['key' => 'image', 'type' => 'image', 'label' => 'Image', 'default' => '',
                    'help' => 'Without one the row shows a dark panel.'],
                ['key' => 'imageAlt', 'type' => 'text', 'label' => 'Image description', 'translatable' => true, 'default' => ['_' => '']],
            ],
            'default' => [
                ['badge' => ['_' => 'Starter'], 'tone' => 'green', 'lead' => ['_' => 'Starter hosting'],
                    'text' => ['_' => 'is for a first site, a portfolio or a small shop. We run the server and you run the site.'],
                    'metaTitle' => ['_' => 'Good for one or two sites'], 'metaText' => ['_' => 'Move up later without moving anything'],
                    'image' => '', 'imageAlt' => ['_' => '']],
                ['badge' => ['_' => 'VPS'], 'tone' => 'blue', 'lead' => ['_' => 'A virtual server'],
                    'text' => ['_' => 'gives developers and agencies their own CPU, memory and root access, for shops and apps that need the room.'],
                    'metaTitle' => ['_' => 'Linux, in the distribution you pick'], 'metaText' => ['_' => 'Resize it when traffic grows'],
                    'image' => '', 'imageAlt' => ['_' => '']],
            ]],
    ],
];
