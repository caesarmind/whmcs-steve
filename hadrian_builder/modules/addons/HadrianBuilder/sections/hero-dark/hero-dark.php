<?php
/**
 * Hero on a dark band: a headline, a line of text and a row of large
 * numbers with a caption under each.
 * Markup and classes: the theme's hp-hero-dark block.
 */
return [
    'label'  => 'Hero, dark with numbers',
    'hint'   => 'Dark band with a row of key numbers',
    'group'  => 'Hero',
    'order'  => 120,
    'fields' => [
        ['key' => 'title', 'type' => 'text', 'label' => 'Headline', 'translatable' => true, 'default' => ['_' => 'Servers with room to grow']],
        ['key' => 'text', 'type' => 'textarea', 'label' => 'Text', 'translatable' => true,
            'default' => ['_' => 'Virtual servers on fast disks, ready a minute after you order.']],
        ['key' => 'stats', 'type' => 'list', 'label' => 'Numbers', 'max' => 6, 'itemLabel' => 'label', 'addLabel' => 'Add number',
            'fields' => [
                ['key' => 'value', 'type' => 'text', 'label' => 'Number', 'translatable' => true, 'default' => ['_' => '0'],
                    'help' => 'Keep it short: a figure, or a word such as "Daily".'],
                ['key' => 'label', 'type' => 'text', 'label' => 'Caption', 'translatable' => true, 'default' => ['_' => 'Caption']],
            ],
            'default' => [
                ['value' => ['_' => '1 min'], 'label' => ['_' => 'Setup time']],
                ['value' => ['_' => 'NVMe'], 'label' => ['_' => 'Storage']],
                ['value' => ['_' => 'Daily'], 'label' => ['_' => 'Backups']],
                ['value' => ['_' => '24/7'], 'label' => ['_' => 'Support']],
            ]],
    ],
];
