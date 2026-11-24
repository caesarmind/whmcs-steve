<?php
/**
 * A band of large figures side by side, each with a short label.
 * Markup and classes: the theme's hp-stats-strip block.
 */
return [
    'label'  => 'Numbers strip',
    'hint'   => 'A row of large figures with labels',
    'group'  => 'Trust and numbers',
    'order'  => 700,
    'fields' => [
        ['key' => 'items', 'type' => 'list', 'label' => 'Figures', 'max' => 6, 'itemLabel' => 'label', 'addLabel' => 'Add figure',
            'fields' => [
                ['key' => 'value', 'type' => 'text', 'label' => 'Figure', 'translatable' => true, 'default' => ['_' => '0'],
                    'help' => 'Keep it short: a number, a percentage or one word.'],
                ['key' => 'label', 'type' => 'text', 'label' => 'Label', 'translatable' => true, 'default' => ['_' => 'New figure']],
            ],
            'default' => [
                ['value' => ['_' => '24/7'], 'label' => ['_' => 'Support from our own team']],
                ['value' => ['_' => '15 min'], 'label' => ['_' => 'Typical first reply']],
                ['value' => ['_' => '30 days'], 'label' => ['_' => 'Money-back period']],
                ['value' => ['_' => '14'], 'label' => ['_' => 'Daily backups kept']],
            ]],
    ],
];
